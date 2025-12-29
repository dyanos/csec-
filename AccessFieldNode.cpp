#include "AccessFieldNode.h"
#include "ASTVisitor.h"
#include "utils.h"

#include "IdentifierNode.h"

#include <iostream>


void AccessFieldNode::accept(ASTVisitor& visitor) {
    visitor.visit(*this);
}

llvm::Value* AccessFieldNode::codegen() {
    auto leftValue = base;
    auto rightValue = field;
    if (!leftValue || !rightValue) {
        return nullptr;
    }

    // base가 IdentifierNode가 아닐 수 있으므로 타입 체크 필요
    if (!dynamic_cast<IdentifierNode*>(leftValue.get())) {
        std::cerr << "Error: Base must be an identifier" << std::endl;
        return nullptr;
    }

    auto baseType = ((IdentifierNode*)leftValue.get())->getType();
    if (!baseType || baseType->getKind() != Type::Kind::CLASS) {
        std::cerr << "Error: Base must be a class type" << std::endl;
        return nullptr;
    }

    auto classSymbolOpt = codeGenerator->symbolTable.lookupClass(baseType->getName());
    if (!classSymbolOpt) {
        std::cerr << "Error: Class '" << baseType->getName() << "' not found" << std::endl;
        return nullptr;
    }

    auto classSymbol = *classSymbolOpt;

    auto thisSymbolOpt = codeGenerator->symbolTable.lookup(((IdentifierNode*)leftValue.get())->value);
    if (!thisSymbolOpt) {
        std::cerr << "Error: Base object not found" << std::endl;
        return nullptr;
    }

    auto thisSymbol = *thisSymbolOpt;

    auto targetName = ((IdentifierNode*)rightValue.get())->value;

    // 필드 위치 찾기를 별도 함수로 분리
    int fieldIndex = findFieldIndex(classSymbol, targetName);
    if (fieldIndex == -1) {
        std::cerr << "Error: Field '" << targetName << "' not found in class '"
            << baseType->getName() << "'" << std::endl;
        return nullptr;
    }

    return codeGenerator->builder.CreateStructGEP(
        codeGenerator->getLLVMType(field->getType().get()),
        thisSymbol->value,
        fieldIndex + 1, // +1 for this pointer
        targetName
    );
}

// 필드 인덱스를 찾는 헬퍼 함수 추가
int AccessFieldNode::findFieldIndex(ClassSymbol* classSymbol, const std::string& fieldName) {
    int idx = 0;

    // 생성 파라미터에서 검색
    for (auto& field : classSymbol->constructorParams) {
        if (field.first == fieldName) {
            return idx;
        }
        idx++;
    }

    // 일반 필드에서 검색
    for (auto& field : classSymbol->fields) {
        if (field.first == fieldName) {
            return idx;
        }
        idx++;
    }

    return -1;
}

std::shared_ptr<Type> AccessFieldNode::getType() {
    // left의 type과 동일
    return field->getType();
}