#include "ReturnStatementNode.h"
#include "ASTVisitor.h"

#include <iostream>


void ReturnStatementNode::accept(ASTVisitor& visitor) {
    visitor.visit(*this);
}

llvm::Value* ReturnStatementNode::codegen() {
    llvm::Value* returnValue = nullptr;
    if (expression) {
        returnValue = expression->codegen();
    }

    llvm::Function* currentFunction = codeGenerator->builder.GetInsertBlock()->getParent();
    llvm::Type* returnType = currentFunction->getReturnType();

    if (returnType->isVoidTy()) {
        codeGenerator->builder.CreateRetVoid();
    }
    else {
        if (!returnValue) {
            std::cerr << "Error: Return statement with no value in function returning non-void type" << std::endl;
            return nullptr;
        }

        if (returnValue->getType() != returnType) {
            std::cerr << "Error: Return value type does not match function return type" << std::endl;
            return nullptr;
        }

        codeGenerator->builder.CreateRet(returnValue);
    }

    return nullptr;
}