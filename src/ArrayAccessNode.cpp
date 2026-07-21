#include "codegen.h"
#include "ArrayAccessNode.h"
#include "ASTVisitor.h"
#include "TensorRuntime.h"

#include <iostream>
#include <vector>

namespace {
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

    auto arrayTypeInfo = array->getType();
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
    std::unique_ptr<Type> currentType = array->getType();
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

        llvm::Type* elementType = cg.getLLVMType(elementTypeInfo.get());
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

llvm::Value* ArrayAccessNode::codegenElementPointer() {
    auto& cg = CodeGenerator::getInstance();
    if (!array) return nullptr;
    llvm::Value* currentValue = array->codegen();
    std::unique_ptr<Type> currentType = array->getType();
    if (!currentValue || !currentType || indices.empty()) return nullptr;

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
        llvm::Type* elementType = cg.getLLVMType(elementTypeInfo.get());
        llvm::Value* indexValue = spec->index->codegen();
        if (!elementType || !indexValue) return nullptr;
        llvm::Value* element = cg.builder.CreateGEP(elementType, currentValue, indexValue, "arrayelem.addr");
        if (position + 1 == indices.size()) return element;
        currentValue = cg.builder.CreateLoad(elementType, element, "arrayelem.nested");
        currentType = std::move(elementTypeInfo);
    }
    return nullptr;
}
