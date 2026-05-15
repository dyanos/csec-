#include "codegen.h"

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
        initValue = llvm::Constant::getNullValue(CodeGenerator::getInstance().getLLVMType(type.get()));
    }

    if (this->type->getKind() == Type::Kind::UNKNOWN && initValue != nullptr) {
        // �ʱ�ȭ ���� Ÿ������ ���� Ÿ�� �߷�
        if (initValue->getType()->isIntegerTy(32)) {
            this->type = std::make_unique<BasicType>("Int");
        }
        else if (initValue->getType()->isFloatTy()) {
            this->type = std::make_unique<BasicType>("Float");
        }
        else if (initValue->getType()->isDoubleTy()) {
            this->type = std::make_unique<BasicType>("Double");
        }
        else if (initValue->getType()->isStructTy()) {
            std::string structName = initValue->getType()->getStructName().str();
            this->type = std::make_unique<ClassType>(structName);
        }
        // string type
        else if (initValue->getType()->isPointerTy() &&
            initValue->getType()->isIntegerTy(1)) {
            this->type = std::make_unique<BasicType>("String");
        }
        /*else if (initValue->getType()->isPointerTy()) {
            this->type = std::make_shared<PointerType>(std::make_shared<UnknownType>());
         }*/
        else {
            std::cerr << "Error: Unable to infer variable type for '" << name << "'" << std::endl;
            return nullptr;
        }
    }

    llvm::Type* varType = CodeGenerator::getInstance().getLLVMType(type.get());
    if (!varType) {
        std::cerr << "Error: Unsupported variable type '" << type->getName() << "'" << std::endl;
        return nullptr;
    }

    llvm::AllocaInst* alloc = CodeGenerator::getInstance().builder.CreateAlloca(varType, nullptr, name.c_str());

    CodeGenerator::getInstance().builder.CreateStore(initValue, alloc);

    CodeGenerator::getInstance().symbolTable.addSymbol(
        name,
        std::make_unique<Symbol>(name, type->clone(), alloc, isMutable, SymbolType::VARIABLE));

    return alloc;
}
