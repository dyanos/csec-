#include "codegen.h"
#include "AssignmentExpressionNode.h"
#include "ASTVisitor.h"
#include "IdentifierNode.h"
#include "ArrayAccessNode.h"
#include "type_utils.h"

#include <iostream>

void AssignmentExpressionNode::accept(ASTVisitor& visitor) {
    visitor.visit(*this);
}

llvm::Value* AssignmentExpressionNode::codegen() {
    llvm::Value* leftValue = left->codegen();
    llvm::Value* rightValue = right->codegen();
    if (!leftValue || !rightValue) {
        std::cerr << "Error: Assignment failed" << std::endl;
        return nullptr;
    }

    llvm::Value* targetPtr = leftValue;
    if (auto* id = dynamic_cast<IdentifierNode*>(left.get())) {
        auto symbolOpt = CodeGenerator::getInstance().symbolTable.lookup(id->value);
        if (!symbolOpt || !symbolOpt->value) {
            std::cerr << "Error: Invalid assignment target" << std::endl;
            return nullptr;
        }
        targetPtr = symbolOpt->value;
        if (isStructClassType(symbolOpt->type.get())) {
            llvm::Type* targetType = CodeGenerator::getInstance().getLLVMType(symbolOpt->type.get());
            rightValue = coerceValueToLLVMType(rightValue, targetType);
            if (!rightValue || rightValue->getType() != targetType) {
                std::cerr << "Type error: Assignment value does not match struct variable '" << id->value << "'" << std::endl;
                return nullptr;
            }
        }
    }
    else if (auto* access = dynamic_cast<ArrayAccessNode*>(left.get())) {
        targetPtr = access->codegenElementPointer();
        if (!targetPtr) {
            std::cerr << "Error: Invalid array assignment target" << std::endl;
            return nullptr;
        }
    }

    if (!targetPtr->getType()->isPointerTy()) {
        std::cerr << "Error: Left-hand side of assignment is not assignable" << std::endl;
        return nullptr;
    }

    llvm::Type* targetType = CodeGenerator::getInstance().getLLVMType(left->getType().get());
    rightValue = coerceValueToLLVMType(rightValue, targetType);
    if (!rightValue || !targetType || rightValue->getType() != targetType) {
        std::cerr << "Type error: Assignment value does not match its target type" << std::endl;
        return nullptr;
    }

    if (op == "+=" || op == "-=" || op == "*=" || op == "/=" || op == "%=") {
        llvm::Value* oldValue = CodeGenerator::getInstance().builder.CreateLoad(targetType, targetPtr, "assign.old");
        if (targetType->isFloatingPointTy()) {
            if (op == "+=") rightValue = CodeGenerator::getInstance().builder.CreateFAdd(oldValue, rightValue, "assign.next");
            else if (op == "-=") rightValue = CodeGenerator::getInstance().builder.CreateFSub(oldValue, rightValue, "assign.next");
            else if (op == "*=") rightValue = CodeGenerator::getInstance().builder.CreateFMul(oldValue, rightValue, "assign.next");
            else if (op == "/=") rightValue = CodeGenerator::getInstance().builder.CreateFDiv(oldValue, rightValue, "assign.next");
            else {
                std::cerr << "Type error: Remainder assignment is not supported for floating-point values" << std::endl;
                return nullptr;
            }
        } else if (op == "+=") rightValue = CodeGenerator::getInstance().builder.CreateAdd(oldValue, rightValue, "assign.next");
        else if (op == "-=") rightValue = CodeGenerator::getInstance().builder.CreateSub(oldValue, rightValue, "assign.next");
        else if (op == "*=") rightValue = CodeGenerator::getInstance().builder.CreateMul(oldValue, rightValue, "assign.next");
        else if (op == "/=") rightValue = CodeGenerator::getInstance().builder.CreateSDiv(oldValue, rightValue, "assign.next");
        else rightValue = CodeGenerator::getInstance().builder.CreateSRem(oldValue, rightValue, "assign.next");
    }
    CodeGenerator::getInstance().builder.CreateStore(rightValue, targetPtr);
    return rightValue;
}

std::unique_ptr<Type> AssignmentExpressionNode::getType() {
    return left->getType();
}
