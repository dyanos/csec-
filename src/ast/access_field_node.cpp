#include "ast.h"
#include "codegen.h"
#include <iostream>

AccessFieldNode::AccessFieldNode() {
    nodeType = ASTNodeType::ACCESS_FIELD;
}

AccessFieldNode::AccessFieldNode(std::shared_ptr<ASTNode> base, std::shared_ptr<ASTNode> field)
    : base(base), field(field) {
    nodeType = ASTNodeType::ACCESS_FIELD;
}

void AccessFieldNode::accept(ASTVisitor& visitor) {
    visitor.visit(*this);
}

llvm::Value* AccessFieldNode::codegen() {
    auto leftValue = base;
    auto rightValue = field;
    if (!leftValue || !rightValue) {
        return nullptr;
    }

    if (!dynamic_cast<IdentifierNode*>(leftValue.get())) {
        std::cerr << "Error: Base must be an identifier" << std::endl;
        return nullptr;
    }

    auto baseType = ((IdentifierNode*)leftValue.get())->getType();
    if (!baseType || baseType->kind != TypeKind::CLASS) {
        std::cerr << "Error: Base must be a class type" << std::endl;
        return nullptr;
    }

    auto classSymbol = codeGenerator->symbolTable.lookupClass(baseType->name);
    if (!classSymbol) {
        std::cerr << "Error: Class '" << baseType->name << "' not found" << std::endl;
        return nullptr;
    }

    auto thisSymbol = codeGenerator->symbolTable.lookup(((IdentifierNode*)leftValue.get())->value);
    if (!thisSymbol) {
        std::cerr << "Error: Base object not found" << std::endl;
        return nullptr;
    }

    auto targetName = ((IdentifierNode*)rightValue.get())->value;
    
    int fieldIndex = findFieldIndex(classSymbol, targetName);
    if (fieldIndex == -1) {
        std::cerr << "Error: Field '" << targetName << "' not found in class '" 
                  << baseType->name << "'" << std::endl;
        return nullptr;
    }

    return codeGenerator->builder.CreateStructGEP(
        codeGenerator->getLLVMType(field->getType()), 
        thisSymbol->value,
        fieldIndex + 1,
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

std::shared_ptr<Type> AccessFieldNode::getType() {
    return field->getType();
} 