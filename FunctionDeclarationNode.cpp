#include "FunctionDeclarationNode.h"
#include "ASTVisitor.h"
#include "utils.h"

#include <iostream>
#include <llvm/IR/Function.h>

#include "ParameterNode.h"
#include "BlockNode.h"

void FunctionDeclarationNode::accept(ASTVisitor& visitor) {
    visitor.visit(*this);
}

llvm::Value* FunctionDeclarationNode::codegen() {
    std::vector<llvm::Type*> paramTypes;

    for (auto& param : this->parameters) {
        paramTypes.push_back(codeGenerator->getLLVMType(param->getType().get()));
    }

    llvm::Type* returnType = codeGenerator->getLLVMType(this->returnType.get());
    if (!returnType) {
        std::cerr << "Error: Not supported the return type of '" << this->name << "'" << std::endl;
        return nullptr;
    }
    llvm::FunctionType* funcType = llvm::FunctionType::get(returnType, paramTypes, false);
    // 함수를 둘러싸고 있는 이름공간이 있을 경우 이름공간 접두사 추가
    std::string funcName = [&]() {
        if (codeGenerator->scopes.empty()) {
            return "_" + this->name;
        }
        else {
            return join(codeGenerator->scopes, "#") + "#" + this->name;
        }
        }();

    llvm::Function* function = llvm::Function::Create(funcType, llvm::Function::ExternalLinkage, this->name, codeGenerator->module.get());

    // TODO: 심볼 테이블에 함수 심볼 추가
    // TODO: 지금까지 symboltable에 함수 심볼을 추가하고, 기존 심볼 테이블의 정보를 계승받는 새로운 심볼 테이블을 만들어서, 거기에 함수 내부 변수등이 선언되어 들어가도록 함
    Symbol* functionSymbol = new FunctionSymbol(this->name, this->getType(), function, false, SymbolType::FUNCTION);
    codeGenerator->symbolTable.addSymbol(this->name, functionSymbol);
    codeGenerator->symbolTable.setCurrentSymbol(functionSymbol);
    codeGenerator->symbolTable.enterScope();

    // 함수 인자 심볼 추가
    int cnt = 0;
    for (auto& arg : this->parameters) {
        Symbol* paramSymbol = new Symbol(arg->name, arg->getType(), function->getArg(cnt), false, SymbolType::VARIABLE);
        codeGenerator->symbolTable.addSymbol(arg->name, paramSymbol);
        cnt += 1;
    }

    // block start
    llvm::BasicBlock* bb = llvm::BasicBlock::Create(codeGenerator->context, "entry", function);
    codeGenerator->builder.SetInsertPoint(bb);
    this->body->codegen();
    // block end
    // body에 return이 있을 것이므로 여기서 리턴 코드를 추가하지 않음

    codeGenerator->symbolTable.exitScope();

    return nullptr;
}