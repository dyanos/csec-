#include "codegen.h"
#include "ArrayAccessNode.h"
#include "ASTVisitor.h"
#include "TensorRuntime.h"
#include "type_utils.h"

#include <iostream>
#include <vector>

namespace {
// A nested array element (`Array[Array[T]]` / `ArrayType` of arrays) is stored as a pointer to its
// element buffer, not inline. When indexing through such an intermediate level, the value loaded is
// that pointer, so the load/GEP type must be an opaque pointer rather than `getLLVMType`'s inline
// `[N x T]` aggregate — otherwise the next index GEPs on a non-pointer aggregate and asserts.
bool elementIsArrayLike(const Type* type) {
    if (!type) return false;
    if (dynamic_cast<const ArrayType*>(type) != nullptr) return true;
    if (type->getKind() == Type::Kind::GENERIC && type->getName() == "Array") return true;
    return false;
}

llvm::Value* toTensorIndex(CodeGenerator& cg, llvm::Value* value) {
    if (!value) return nullptr;
    auto* i64Ty = llvm::Type::getInt64Ty(cg.context);
    if (value->getType() == i64Ty) return value;
    if (value->getType()->isIntegerTy()) {
        unsigned bits = value->getType()->getIntegerBitWidth();
        if (bits < 64) return cg.builder.CreateSExt(value, i64Ty, "tensor.index.sext");
        if (bits > 64) return cg.builder.CreateTrunc(value, i64Ty, "tensor.index.trunc");
    }
    if (value->getType()->isFloatingPointTy()) {
        return cg.builder.CreateFPToSI(value, i64Ty, "tensor.index.fptosi");
    }
    return value;
}
}

void ArrayAccessNode::accept(ASTVisitor& visitor) {
    visitor.visit(*this);
}

llvm::Value* ArrayAccessNode::codegen() {
    auto& cg = CodeGenerator::getInstance();
    llvm::Value* arrayValue = array->codegen();
    if (!arrayValue) {
        return nullptr;
    }

    std::vector<ArrayIndexSpec*> specs;
    for (auto& spec : indices) {
        specs.push_back(spec.get());
    }
    if (specs.empty() && index) {
        auto fallback = std::make_unique<ArrayIndexSpec>();
        fallback->index = index->clone();
        specs.push_back(fallback.get());
        indices.push_back(std::move(fallback));
    }

    auto arrayTypeInfo = stripBorrow(array->getType());
    if (arrayTypeInfo && TensorRuntime::isTensorTypeName(arrayTypeInfo->getName())) {
        std::vector<bool> isSlice;
        std::vector<llvm::Value*> starts;
        std::vector<llvm::Value*> ends;
        std::vector<llvm::Value*> steps;
        size_t tensorRank = specs.size();
        if (auto* tensorType = dynamic_cast<GenericType*>(arrayTypeInfo.get())) {
            if (tensorType->typeArguments.size() > 1) {
                tensorRank = tensorType->typeArguments.size() - 1;
            }
        }

        for (size_t axis = 0; axis < tensorRank; ++axis) {
            auto* spec = axis < specs.size() ? specs[axis] : nullptr;
            if (!spec) {
                isSlice.push_back(true);
                starts.push_back(nullptr);
                ends.push_back(nullptr);
                steps.push_back(nullptr);
                continue;
            }
            isSlice.push_back(spec && spec->isSlice);
            if (spec && spec->isSlice) {
                starts.push_back(spec->start ? toTensorIndex(cg, spec->start->codegen()) : nullptr);
                ends.push_back(spec->end ? toTensorIndex(cg, spec->end->codegen()) : nullptr);
                steps.push_back(spec->step ? toTensorIndex(cg, spec->step->codegen()) : nullptr);
            }
            else {
                llvm::Value* scalarIndex = spec && spec->index ? toTensorIndex(cg, spec->index->codegen()) : nullptr;
                starts.push_back(scalarIndex);
                ends.push_back(nullptr);
                steps.push_back(nullptr);
            }
        }

        return TensorRuntime::sliceTensor(cg, arrayValue, isSlice, starts, ends, steps);
    }

    llvm::Value* currentValue = arrayValue;
    std::unique_ptr<Type> currentType = stripBorrow(array->getType());
    for (auto* spec : specs) {
        if (!spec || spec->isSlice) {
            std::cerr << "Error: Slice syntax is only supported for Tensor values" << std::endl;
            return nullptr;
        }

        llvm::Value* indexValue = spec->index ? spec->index->codegen() : nullptr;
        if (!indexValue) {
            return nullptr;
        }

        std::unique_ptr<Type> elementTypeInfo;
        if (auto* arrayType = dynamic_cast<ArrayType*>(currentType.get())) {
            elementTypeInfo = arrayType->elementType ? arrayType->elementType->clone() : nullptr;
        }
        else if (auto* genericType = dynamic_cast<GenericType*>(currentType.get())) {
            if (genericType->typeArguments.size() == 1 && genericType->typeArguments[0]) {
                elementTypeInfo = genericType->typeArguments[0]->clone();
            }
        }

        if (!elementTypeInfo) {
            elementTypeInfo = getType();
        }

        llvm::Type* elementType = elementIsArrayLike(elementTypeInfo.get())
            ? static_cast<llvm::Type*>(llvm::PointerType::getUnqual(cg.context))
            : cg.getLLVMType(elementTypeInfo.get());
        if (!elementType) {
            std::cerr << "Error: Invalid array element type" << std::endl;
            return nullptr;
        }

        llvm::Value* elemPtr = cg.builder.CreateGEP(elementType, currentValue, indexValue, "arrayelem");
        currentValue = cg.builder.CreateLoad(elementType, elemPtr, "arrayload");
        currentType = std::move(elementTypeInfo);
    }

    return currentValue;
}

llvm::Value* ArrayAccessNode::codegenSliceAssign(llvm::Value* rhs, const Type* rhsType) {
    auto& cg = CodeGenerator::getInstance();
    if (!array || !rhs) return nullptr;
    auto arrayType = stripBorrow(array->getType());
    if (!arrayType || !TensorRuntime::isTensorTypeName(arrayType->getName())) {
        std::cerr << "Error: slice assignment is only supported for Tensor values" << std::endl;
        return nullptr;
    }
    // Single-axis section: `t[:]`, `t[i:j]`, `t[i:j:k]`. Multi-axis section assignment is not supported.
    if (indices.size() != 1 || !indices[0] || !indices[0]->isSlice) {
        std::cerr << "Error: only a single-axis tensor section can be assigned" << std::endl;
        return nullptr;
    }
    ArrayIndexSpec* spec = indices[0].get();

    llvm::Value* tensor = array->codegen();
    if (!tensor) return nullptr;
    auto* i64Ty = llvm::Type::getInt64Ty(cg.context);
    auto* f64Ty = llvm::Type::getDoubleTy(cg.context);
    llvm::Value* count = TensorRuntime::loadCount(cg, tensor);
    llvm::Value* data = TensorRuntime::loadData(cg, tensor);

    // Section bounds default to the whole array (`t[:]` = 0 .. count step 1).
    llvm::Value* start = spec->start ? toTensorIndex(cg, spec->start->codegen())
                                     : llvm::ConstantInt::get(i64Ty, 0);
    llvm::Value* end = spec->end ? toTensorIndex(cg, spec->end->codegen()) : count;
    llvm::Value* step = spec->step ? toTensorIndex(cg, spec->step->codegen())
                                   : llvm::ConstantInt::get(i64Ty, 1);

    // Element count of the section: ceil((end - start) / step).
    llvm::Value* span = cg.builder.CreateSub(end, start, "slice.span");
    llvm::Value* n = cg.builder.CreateSDiv(
        cg.builder.CreateAdd(span, cg.builder.CreateSub(step, llvm::ConstantInt::get(i64Ty, 1))),
        step, "slice.n");

    const bool rhsIsTensor = rhsType && TensorRuntime::isTensorTypeName(rhsType->getName());
    llvm::Value* rhsData = rhsIsTensor ? TensorRuntime::loadData(cg, rhs) : nullptr;
    llvm::Value* scalar = rhsIsTensor ? nullptr : TensorRuntime::toDouble(cg, rhs);

    TensorRuntime::emitCountedLoop(cg, n, "slice.assign", [&](llvm::Value* k) {
        llvm::Value* idx = cg.builder.CreateAdd(start, cg.builder.CreateMul(k, step, "slice.k.step"), "slice.idx");
        llvm::Value* dst = cg.builder.CreateGEP(f64Ty, data, idx, "slice.dst");
        llvm::Value* value = scalar;
        if (rhsIsTensor) {
            value = cg.builder.CreateLoad(f64Ty, cg.builder.CreateGEP(f64Ty, rhsData, k, "slice.src"), "slice.srcval");
        }
        cg.builder.CreateStore(value, dst);
    });
    return rhs;
}

llvm::Value* ArrayAccessNode::codegenElementPointer() {
    auto& cg = CodeGenerator::getInstance();
    if (!array) return nullptr;
    llvm::Value* currentValue = array->codegen();
    std::unique_ptr<Type> currentType = stripBorrow(array->getType());
    if (!currentValue || !currentType || indices.empty()) return nullptr;

    // Tensor element write `t[i, j, ...] = v`: tensors are a { rank, dims, count, data } struct, not
    // a flat buffer, so compute the address into `data` via the same row-major linear index the read
    // path uses. Requires a full scalar index per axis (no slices).
    if (TensorRuntime::isTensorTypeName(currentType->getName())) {
        std::vector<llvm::Value*> tensorIndices;
        for (auto& spec : indices) {
            if (!spec || spec->isSlice || !spec->index) return nullptr;
            llvm::Value* idx = toTensorIndex(cg, spec->index->codegen());
            if (!idx) return nullptr;
            tensorIndices.push_back(idx);
        }
        return TensorRuntime::elementPointer(cg, currentValue, tensorIndices);
    }

    for (size_t position = 0; position < indices.size(); ++position) {
        ArrayIndexSpec* spec = indices[position].get();
        if (!spec || spec->isSlice || !spec->index) return nullptr;
        std::unique_ptr<Type> elementTypeInfo;
        if (auto* arrayType = dynamic_cast<ArrayType*>(currentType.get())) {
            if (arrayType->elementType) elementTypeInfo = arrayType->elementType->clone();
        }
        else if (auto* genericType = dynamic_cast<GenericType*>(currentType.get())) {
            if (genericType->typeArguments.size() == 1 && genericType->typeArguments[0]) {
                elementTypeInfo = genericType->typeArguments[0]->clone();
            }
        }
        if (!elementTypeInfo) return nullptr;
        llvm::Type* elementType = elementIsArrayLike(elementTypeInfo.get())
            ? static_cast<llvm::Type*>(llvm::PointerType::getUnqual(cg.context))
            : cg.getLLVMType(elementTypeInfo.get());
        llvm::Value* indexValue = spec->index->codegen();
        if (!elementType || !indexValue) return nullptr;
        llvm::Value* element = cg.builder.CreateGEP(elementType, currentValue, indexValue, "arrayelem.addr");
        if (position + 1 == indices.size()) return element;
        currentValue = cg.builder.CreateLoad(elementType, element, "arrayelem.nested");
        currentType = std::move(elementTypeInfo);
    }
    return nullptr;
}
