#include "AttributeNode.h"
#include "ASTVisitor.h"

#include <iostream>

#include "IdentifierNode.h"
#include "FunctionCallNode.h"
#include "FunctionDeclarationNode.h"
#include "ValueNode.h"
#include "codegen.h"

namespace {
std::string stringArgument(const FunctionCallNode* call, size_t index) {
    if (!call || index >= call->arguments.size()) {
        return "";
    }
    auto* valueNode = dynamic_cast<ValueNode*>(call->arguments[index].get());
    if (!valueNode || valueNode->valueType != TokenType::STRING_LITERAL) {
        return "";
    }
    return valueNode->value;
}

void addUnique(std::vector<std::string>& values, const std::string& value) {
    if (value.empty()) return;
    for (const auto& existing : values) {
        if (existing == value) return;
    }
    values.push_back(value);
}
}

void AttributeNode::accept(ASTVisitor& visitor) {
    visitor.visit(*this);
}

llvm::Value* AttributeNode::codegen() {
    auto applyToTarget = [&]() {
        return target ? target->codegen() : nullptr;
    };

    if (auto* callNode = dynamic_cast<FunctionCallNode*>(this->expr.get())) {
        if (callNode->functionName == "DllImport" || callNode->functionName == "StaticLibraryImport") {
            std::string library = stringArgument(callNode, 0);
            std::string symbol = stringArgument(callNode, 1);
            if (auto* function = dynamic_cast<FunctionDeclarationNode*>(this->target.get())) {
                function->dllImportLibrary = library;
                function->externalSymbolName = symbol;
                function->isExternal = true;
            }
            addUnique(CodeGenerator::getInstance().externalLinkLibraries, library);
            return applyToTarget();
        }
        if (callNode->functionName == "LinkPath") {
            addUnique(CodeGenerator::getInstance().externalLinkPaths, stringArgument(callNode, 0));
            return applyToTarget();
        }
    }

    // Node가 IdentifierNode이라고 하더라도 FunctionCall로 취급
    switch (this->expr->nodeType) {
    case ASTNodeType::FUNCTION_CALL:
        return this->expr->codegen();

    case ASTNodeType::IDENTIFIER:
    {
        auto identifierNode = dynamic_cast<IdentifierNode*>(this->expr.get());
        if (!identifierNode) {
            std::cerr << "Error: Invalid identifier node" << std::endl;
            return nullptr;
        }

        // Attribute 종류에 따른 처리
        if (identifierNode->value == "DllImport") {
            // 이거 다음의 함수는 외부 DLL에서 가져오는 함수로 처리
            if (auto* function = dynamic_cast<FunctionDeclarationNode*>(this->target.get())) {
                function->isExternal = true;
            }
        }
        else if (identifierNode->value == "StaticLibraryImport") {
            // 이거 다음의 함수는 외부 Static Library에서 가져오는 함수로 처리
        }
        else if (identifierNode->value == "Native") {
            // 이거 다음의 함수는 네이티브 함수로 처리 = Compiler에서 지원하는 함수
        }
        else {
            // 나머지는 사용자 지정으로 할 예정
        }
    }
    break;

    default:
        std::cerr << "Error: Unsupported expression type in AttributeNode" << std::endl;
        break;
    }

    return applyToTarget();
}
