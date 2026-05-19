#include "codegen.h"
#include "AccessFieldNode.h"
#include "ASTVisitor.h"
#include "utils.h"

#include "IdentifierNode.h"

#include <iostream>

void AccessFieldNode::accept(ASTVisitor& visitor) {
    visitor.visit(*this);
}

llvm::Value* AccessFieldNode::codegen() {
    if (!this->base || !this->field) {
        return nullptr;
    }

    auto* baseIdentifier = dynamic_cast<IdentifierNode*>(this->base.get());
    if (!baseIdentifier) {
        std::cerr << "Error: Base must be an identifier" << std::endl;
        return nullptr;
    }

    auto* fieldIdentifier = dynamic_cast<IdentifierNode*>(this->field.get());
    if (!fieldIdentifier) {
        std::cerr << "Error: Field must be an identifier" << std::endl;
        return nullptr;
    }

    auto baseType = baseIdentifier->getType();
    if (!baseType || baseType->getKind() != Type::Kind::CLASS) {
        std::cerr << "Error: Base must be a class type" << std::endl;
        return nullptr;
    }

    auto* classSymbol = CodeGenerator::getInstance().symbolTable.lookupClass(baseType->getName());
    if (!classSymbol) {
        std::cerr << "Error: Class '" << baseType->getName() << "' not found" << std::endl;
        return nullptr;
    }

    auto* thisSymbol = CodeGenerator::getInstance().symbolTable.lookup(baseIdentifier->value);
    if (!thisSymbol) {
        std::cerr << "Error: Base object not found" << std::endl;
        return nullptr;
    }

    auto* structType = llvm::dyn_cast<llvm::StructType>(classSymbol->classType);
    if (!structType) {
        std::cerr << "Error: Class '" << baseType->getName() << "' has invalid LLVM struct type" << std::endl;
        return nullptr;
    }

    llvm::Value* basePtr = thisSymbol->value;
    if (!basePtr || !basePtr->getType()->isPointerTy()) {
        std::cerr << "Error: Base object value is not a pointer" << std::endl;
        return nullptr;
    }

    auto* targetPtrType = llvm::PointerType::getUnqual(structType);
    if (basePtr->getType() != targetPtrType) {
        basePtr = CodeGenerator::getInstance().builder.CreateBitCast(basePtr, targetPtrType, "obj.cast");
    }

    auto targetName = fieldIdentifier->value;

    int fieldIndex = findFieldIndex(classSymbol, targetName);
    if (fieldIndex == -1) {
        std::cerr << "Error: Field '" << targetName << "' not found in class '"
            << baseType->getName() << "'" << std::endl;
        return nullptr;
    }

    return CodeGenerator::getInstance().builder.CreateStructGEP(
        structType,
        basePtr,
        static_cast<unsigned>(fieldIndex),
        targetName
    );
}

int AccessFieldNode::findFieldIndex(ClassSymbol* classSymbol, const std::string& fieldName) {
    int idx = 0;

    for (auto& field : classSymbol->constructorParams) {
        if (field.first == fieldName) {
            return idx;
        }
        idx++;
    }

    for (auto& field : classSymbol->fields) {
        if (field.first == fieldName) {
            return idx;
        }
        idx++;
    }

    return -1;
}

std::unique_ptr<Type> AccessFieldNode::getType() {
    if (!field) return std::make_unique<UnknownType>();
    return field->getType();
}
