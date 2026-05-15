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
    auto& cg = CodeGenerator::getInstance();

    llvm::Value* initValue = nullptr;
    if (this->initializer) {
        initValue = this->initializer->codegen();
        if (!initValue) {
            return nullptr;
        }
    }
    else {
        initValue = llvm::Constant::getNullValue(cg.getLLVMType(type.get()));
    }

    if (this->type->getKind() == Type::Kind::UNKNOWN && initValue != nullptr) {
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
        // string type (opaque pointer)
        else if (initValue->getType()->isPointerTy()) {
            this->type = std::make_unique<BasicType>("String");
        }
        else {
            std::cerr << "Error: Unable to infer variable type for '" << name << "'" << std::endl;
            return nullptr;
        }
    }

    // constexpr: use constant value directly, no alloca
    if (this->isConstexpr) {
        auto* constVal = llvm::dyn_cast<llvm::Constant>(initValue);
        if (!constVal) {
            std::cerr << "Error: constexpr variable '" << name << "' must have a constant initializer" << std::endl;
            return nullptr;
        }
        cg.symbolTable.addSymbol(
            name,
            std::make_unique<Symbol>(name, type->clone(), constVal, false, SymbolType::VARIABLE));
        return constVal;
    }

    llvm::Type* varType = cg.getLLVMType(type.get());
    if (!varType) {
        std::cerr << "Error: Unsupported variable type '" << type->getName() << "'" << std::endl;
        return nullptr;
    }

    llvm::AllocaInst* alloc = cg.builder.CreateAlloca(varType, nullptr, name.c_str());

    cg.builder.CreateStore(initValue, alloc);

    cg.symbolTable.addSymbol(
        name,
        std::make_unique<Symbol>(name, type->clone(), alloc, isMutable, SymbolType::VARIABLE));

    return alloc;
}
