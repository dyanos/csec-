#include "codegen.h"

#include "ReturnStatementNode.h"
#include "ASTVisitor.h"
#include "type_utils.h"

#include <iostream>


void ReturnStatementNode::accept(ASTVisitor& visitor) {
    visitor.visit(*this);
}

llvm::Value* ReturnStatementNode::codegen() {
    auto& cg = CodeGenerator::getInstance();
    llvm::Value* returnValue = nullptr;
    if (expression) {
        returnValue = expression->codegen();
    }

    llvm::Function* currentFunction = cg.builder.GetInsertBlock()->getParent();
    llvm::Type* returnType = currentFunction->getReturnType();

    if (returnType->isVoidTy()) {
        cg.emitAllCleanups();
        cg.builder.CreateRetVoid();
    }
    else {
        if (!returnValue) {
            std::cerr << "Error: Return statement with no value in function returning non-void type" << std::endl;
            return nullptr;
        }

        returnValue = coerceValueToLLVMType(returnValue, returnType);
        if (!returnValue || returnValue->getType() != returnType) {
            std::cerr << "Error: Return value type does not match function return type" << std::endl;
            return nullptr;
        }

        cg.emitAllCleanupsExcept(returnValue);
        cg.builder.CreateRet(returnValue);
    }

    return nullptr;
}
