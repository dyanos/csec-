#include "ObjectDeclarationNode.h"
#include "ASTVisitor.h"
#include "BlockNode.h"
#include "AttributeNode.h"
#include "FunctionDeclarationNode.h"
#include "VariableDeclarationNode.h"
#include "codegen.h"

#include <iostream>

void ObjectDeclarationNode::accept(ASTVisitor& visitor) {
    visitor.visit(*this);
}

llvm::Value* ObjectDeclarationNode::codegen() {
    auto& cg = CodeGenerator::getInstance();
    auto* symbol = cg.symbolTable.lookup(name);
    auto* savedCurrentSymbol = cg.symbolTable.getCurrentSymbol();
    cg.symbolTable.saveCurrentSymbol();
    cg.symbolTable.setCurrentSymbol(symbol);
    cg.symbolTable.enterScope();
    cg.scopes.push_back(name);

    llvm::Value* last = nullptr;
    if (auto* block = dynamic_cast<BlockNode*>(body.get())) {
        for (auto& stmt : block->statements) {
            if (!stmt) {
                continue;
            }

            if (dynamic_cast<FunctionDeclarationNode*>(stmt.get()) ||
                dynamic_cast<VariableDeclarationNode*>(stmt.get())) {
                last = stmt->codegen();
                continue;
            }

            if (auto* attr = dynamic_cast<AttributeNode*>(stmt.get())) {
                if (attr->target &&
                    (dynamic_cast<FunctionDeclarationNode*>(attr->target.get()) ||
                     dynamic_cast<VariableDeclarationNode*>(attr->target.get()))) {
                    last = attr->target->codegen();
                }
            }
        }
    }
    else if (body) {
        last = body->codegen();
    }

    if (!cg.scopes.empty()) {
        cg.scopes.pop_back();
    }
    cg.symbolTable.exitScope();
    cg.symbolTable.popCurrentSymbol();
    cg.symbolTable.setCurrentSymbol(savedCurrentSymbol);
    return last;
}
