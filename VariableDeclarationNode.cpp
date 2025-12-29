#include "VariableDeclarationNode.h"
#include "ASTVisitor.h"

#include <iostream>
#include <llvm/IR/Value.h>
#include <llvm/IR/Constants.h>
#include <llvm/IR/DerivedTypes.h>

void VariableDeclarationNode::accept(ASTVisitor& visitor) {
    visitor.visit(*this);
}

llvm::Value* VariableDeclarationNode::codegen() {
    llvm::Value* initValue = nullptr;
    if (this->initializer) {
        initValue = this->initializer->codegen();
        if (!initValue) {
            return nullptr;
        }
    }
    else {
        initValue = llvm::Constant::getNullValue(codeGenerator->getLLVMType(type.get()));
    }

    if (this->type->getKind() == Type::Kind::UNKNOWN && initValue != nullptr) {
        // �ʱ�ȭ ���� Ÿ������ ���� Ÿ�� �߷�
        if (initValue->getType()->isIntegerTy(32)) {
            this->type = std::make_shared<BasicType>("Int");
        }
        else if (initValue->getType()->isFloatTy()) {
            this->type = std::make_shared<BasicType>("Float");
        }
        else if (initValue->getType()->isDoubleTy()) {
            this->type = std::make_shared<BasicType>("Double");
        }
        else if (initValue->getType()->isStructTy()) {
            std::string structName = initValue->getType()->getStructName().str();
            this->type = std::make_shared<ClassType>(structName);
        }
        // string type
        else if (initValue->getType()->isPointerTy() &&
            initValue->getType()->isIntegerTy(1)) {
            this->type = std::make_shared<BasicType>("String");
        }
        /*else if (initValue->getType()->isPointerTy()) {
            this->type = std::make_shared<PointerType>(std::make_shared<UnknownType>());
         }*/
        else {
            std::cerr << "Error: Unable to infer variable type for '" << name << "'" << std::endl;
            return nullptr;
        }
    }

    llvm::Type* varType = codeGenerator->getLLVMType(type.get());
    if (!varType) {
        std::cerr << "Error: Unsupported variable type '" << type->getName() << "'" << std::endl;
        return nullptr;
    }

    llvm::AllocaInst* alloc = codeGenerator->builder.CreateAlloca(varType, nullptr, name.c_str());

    codeGenerator->builder.CreateStore(initValue, alloc);

    Symbol* symbol = new Symbol(name, type, alloc, isMutable, SymbolType::VARIABLE);
    codeGenerator->symbolTable.addSymbol(name, symbol);

    return alloc;
}