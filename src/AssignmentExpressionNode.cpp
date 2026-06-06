#include "codegen.h"
#include "AssignmentExpressionNode.h"
#include "ASTVisitor.h"
#include "IdentifierNode.h"
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

    if (!targetPtr->getType()->isPointerTy()) {
        std::cerr << "Error: Left-hand side of assignment is not assignable" << std::endl;
        return nullptr;
    }

    CodeGenerator::getInstance().builder.CreateStore(rightValue, targetPtr);
    return rightValue;
}

std::unique_ptr<Type> AssignmentExpressionNode::getType() {
    return left->getType();
}
