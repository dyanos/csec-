#include "codegen.h"
#include "ReduceStatementNode.h"
#include "ASTVisitor.h"
#include "ArrayLiteralNode.h"

#include <iostream>
#include <llvm/IR/Function.h>
#include <llvm/IR/Constants.h>

void ReduceStatementNode::accept(ASTVisitor& visitor) {
    visitor.visit(*this);
}

llvm::Value* ReduceStatementNode::codegen() {
    auto& cg = CodeGenerator::getInstance();
    llvm::Function* function = cg.builder.GetInsertBlock()->getParent();

    llvm::Value* arrayPtr = iterableExpr->codegen();
    if (!arrayPtr) return nullptr;

    auto iterType = iterableExpr->getType();
    if (!iterType) return nullptr;

    // Extract element type and array size
    llvm::Type* elementType = nullptr;
    int arraySize = 0;
    bool sizeKnown = false;

    if (auto* arrType = dynamic_cast<ArrayType*>(iterType.get())) {
        elementType = cg.getLLVMType(arrType->elementType.get());
        arraySize = arrType->size;
        sizeKnown = true;
    } else if (auto* genType = dynamic_cast<GenericType*>(iterType.get())) {
        if (genType->baseType && genType->baseType->getName() == "Array" && !genType->typeArguments.empty()) {
            elementType = cg.getLLVMType(genType->typeArguments[0].get());
            if (iterableExpr && iterableExpr->nodeType == ASTNodeType::ARRAY_LITERAL) {
                auto* arrayLiteral = static_cast<ArrayLiteralNode*>(iterableExpr.get());
                arraySize = static_cast<int>(arrayLiteral->elements.size());
                sizeKnown = true;
            }
        }
    }

    // Accept both array values and pointers-to-array by decaying to element pointer.
    if (auto* llvmArrayTy = llvm::dyn_cast<llvm::ArrayType>(arrayPtr->getType())) {
        if (!elementType) {
            elementType = llvmArrayTy->getElementType();
        }
        if (!sizeKnown) {
            arraySize = static_cast<int>(llvmArrayTy->getNumElements());
            sizeKnown = true;
        }
        llvm::Value* tmpArray = cg.builder.CreateAlloca(llvmArrayTy, nullptr, "reduce_arr_tmp");
        cg.builder.CreateStore(arrayPtr, tmpArray);
        llvm::Value* zero = cg.builder.getInt32(0);
        arrayPtr = cg.builder.CreateInBoundsGEP(llvmArrayTy, tmpArray, { zero, zero }, "reduce_arr_decay");
    }
    else if (arrayPtr->getType()->isPointerTy() && elementType && sizeKnown) {
        auto* llvmArrayTy = llvm::ArrayType::get(elementType, arraySize);
        llvm::Value* zero = cg.builder.getInt32(0);
        arrayPtr = cg.builder.CreateInBoundsGEP(llvmArrayTy, arrayPtr, { zero, zero }, "reduce_arr_decay");
    }

    if (!elementType || !sizeKnown || arraySize < 0) {
        std::cerr << "Error: Cannot determine array element type or size for reduce" << std::endl;
        return nullptr;
    }

    // Evaluate initial value and create accumulator
    llvm::Value* initValue = initialValue ? initialValue->codegen() : nullptr;
    if (!initValue) {
        std::cerr << "Error: Reduce requires an initial value" << std::endl;
        return nullptr;
    }

    // Allocate all variables before the loop
    llvm::Value* accPtr = cg.builder.CreateAlloca(initValue->getType(), nullptr, "acc");
    cg.builder.CreateStore(initValue, accPtr);
    llvm::Value* counterPtr = cg.builder.CreateAlloca(cg.builder.getInt32Ty(), nullptr, "reduce_i");
    cg.builder.CreateStore(cg.builder.getInt32(0), counterPtr);
    llvm::Value* varPtr = cg.builder.CreateAlloca(elementType, nullptr, variable + "_ptr");

    // Bind loop variable and accumulator in scope (once, outside loop)
    cg.symbolTable.enterScope();
    std::unique_ptr<Type> varType;
    if (auto* arrType = dynamic_cast<ArrayType*>(iterType.get())) {
        varType = arrType->elementType->clone();
    } else {
        varType = std::make_unique<UnknownType>();
    }
    cg.symbolTable.addSymbol(variable, std::make_unique<Symbol>(
        variable, std::move(varType), varPtr, false, SymbolType::VARIABLE));

    // Expose accumulator as "$acc" so body can reference it
    auto initValType = initialValue->getType();
    auto accType = initValType ? initValType->clone() : std::make_unique<UnknownType>();
    cg.symbolTable.addSymbol("$acc", std::make_unique<Symbol>(
        "$acc", std::move(accType), accPtr, true, SymbolType::VARIABLE));

    // Enforce reduce body type to match accumulator type
    auto initType = initialValue->getType();
    auto bodyType = body ? body->getType() : nullptr;
    if (initType && bodyType && !bodyType->equals(initType)) {
        std::cerr << "Type error: reduce body result type must match accumulator type" << std::endl;
        cg.symbolTable.exitScope();
        return nullptr;
    }

    llvm::BasicBlock* condBB = llvm::BasicBlock::Create(cg.context, "reducecond", function);
    llvm::BasicBlock* bodyBB = llvm::BasicBlock::Create(cg.context, "reducebody", function);
    llvm::BasicBlock* afterBB = llvm::BasicBlock::Create(cg.context, "afterreduce", function);

    cg.builder.CreateBr(condBB);

    // Condition
    cg.builder.SetInsertPoint(condBB);
    llvm::Value* counter = cg.builder.CreateLoad(cg.builder.getInt32Ty(), counterPtr, "i");
    llvm::Value* cond = cg.builder.CreateICmpSLT(counter, cg.builder.getInt32(arraySize), "reducecmp");
    cg.builder.CreateCondBr(cond, bodyBB, afterBB);

    // Body
    cg.builder.SetInsertPoint(bodyBB);
    llvm::Value* idx = cg.builder.CreateLoad(cg.builder.getInt32Ty(), counterPtr, "idx");

    // Load current element and store into loop variable
    llvm::Value* elemPtr = cg.builder.CreateGEP(elementType, arrayPtr, idx, "elemptr");
    llvm::Value* elemValue = cg.builder.CreateLoad(elementType, elemPtr, "elem");
    cg.builder.CreateStore(elemValue, varPtr);

    // Evaluate body (should produce new accumulator value)
    llvm::Value* bodyResult = body->codegen();
    if (!bodyResult) {
        std::cerr << "Error: reduce body evaluation failed" << std::endl;
        cg.symbolTable.exitScope();
        return nullptr;
    }

    // Update accumulator
    if (bodyResult->getType()->isPointerTy()) {
        bodyResult = cg.builder.CreateLoad(initValue->getType(), bodyResult, "reduce_body_load");
    }
    if (bodyResult->getType() != initValue->getType()) {
        std::cerr << "Type error: reduce body result type must match accumulator type" << std::endl;
        cg.symbolTable.exitScope();
        return nullptr;
    }
    cg.builder.CreateStore(bodyResult, accPtr);

    // Increment counter
    llvm::Value* nextIdx = cg.builder.CreateAdd(idx, cg.builder.getInt32(1), "next_i");
    cg.builder.CreateStore(nextIdx, counterPtr);
    cg.builder.CreateBr(condBB);

    // After — return accumulated value
    cg.builder.SetInsertPoint(afterBB);
    cg.symbolTable.exitScope();

    return cg.builder.CreateLoad(initValue->getType(), accPtr, "reduceval");
}
