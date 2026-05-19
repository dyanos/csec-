#include "codegen.h"

#include "TemplateDeclarationNode.h"
#include "FunctionDeclarationNode.h"
#include "ClassDeclarationNode.h"
#include "ASTVisitor.h"

#include <iostream>

void TemplateDeclarationNode::accept(ASTVisitor& visitor) {
    visitor.visit(*this);
}

llvm::Value* TemplateDeclarationNode::codegen() {
    // Template declarations don't generate code immediately.
    // Store in the symbol table as a TemplateSymbol for later instantiation.
    auto& cg = CodeGenerator::getInstance();

    auto* funcDecl = dynamic_cast<FunctionDeclarationNode*>(declaration.get());
    if (funcDecl) {
        auto* existing = cg.symbolTable.lookup(funcDecl->name);
        if (existing && existing->symbolType == SymbolType::TEMPLATE) {
            auto* templateSymbol = dynamic_cast<TemplateSymbol*>(existing);
            if (templateSymbol) {
                templateSymbol->typeParameters = typeParameters;
                templateSymbol->templateParams.clear();
                for (auto& p : templateParams) templateSymbol->templateParams.push_back(TemplateParam(p));
                templateSymbol->declaration = declaration->clone();
            }
        }
        else {
            auto templateSymbol = std::make_unique<TemplateSymbol>();
            templateSymbol->name = funcDecl->name;
            templateSymbol->symbolType = SymbolType::TEMPLATE;
            templateSymbol->typeParameters = typeParameters;
            for (auto& p : templateParams) templateSymbol->templateParams.push_back(TemplateParam(p));
            templateSymbol->declaration = declaration->clone();
            cg.symbolTable.addSymbol(funcDecl->name, std::move(templateSymbol));
        }
        return nullptr;
    }

    auto* classDecl = dynamic_cast<ClassDeclarationNode*>(declaration.get());
    if (classDecl) {
        auto* existing = cg.symbolTable.lookup(classDecl->name);
        if (existing && existing->symbolType == SymbolType::TEMPLATE) {
            auto* templateSymbol = dynamic_cast<TemplateSymbol*>(existing);
            if (templateSymbol) {
                templateSymbol->typeParameters = typeParameters;
                templateSymbol->templateParams.clear();
                for (auto& p : templateParams) templateSymbol->templateParams.push_back(TemplateParam(p));
                templateSymbol->declaration = declaration->clone();
            }
        }
        else {
            auto templateSymbol = std::make_unique<TemplateSymbol>();
            templateSymbol->name = classDecl->name;
            templateSymbol->symbolType = SymbolType::TEMPLATE;
            templateSymbol->typeParameters = typeParameters;
            for (auto& p : templateParams) templateSymbol->templateParams.push_back(TemplateParam(p));
            templateSymbol->declaration = declaration->clone();
            cg.symbolTable.addSymbol(classDecl->name, std::move(templateSymbol));
        }
        return nullptr;
    }

    std::cerr << "Error: Template declaration must wrap a function or class" << std::endl;
    return nullptr;
}
