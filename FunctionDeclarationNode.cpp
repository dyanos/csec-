#include "codegen.h"

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
    if (this->isExternal) {
        // 외부 함수인 경우 심볼 테이블에만 추가하고 코드 생성은 하지 않음
        Symbol* functionSymbol = new FunctionSymbol(this->name, this->getType().get(), nullptr, true, SymbolType::FUNCTION);
        CodeGenerator::getInstance().symbolTable.addSymbol(this->name, functionSymbol);
        llvm::FunctionType* funcType = llvm::FunctionType::get(
            CodeGenerator::getInstance().getLLVMType(this->returnType.get()),
            false);
        llvm::Function * function = llvm::Function::Create(
            funcType,
            llvm::Function::ExternalLinkage,
            this->name,
            CodeGenerator::getInstance().module.get()
		);
		return function;
	}

    std::vector<llvm::Type*> paramTypes;

    for (auto& param : this->parameters) {
        paramTypes.push_back(CodeGenerator::getInstance().getLLVMType(param->getType().get()));
    }

    llvm::Type* returnType = CodeGenerator::getInstance().getLLVMType(this->returnType.get());
    if (!returnType) {
        std::cerr << "Error: Not supported the return type of '" << this->name << "'" << std::endl;
        return nullptr;
    }
    llvm::FunctionType* funcType = llvm::FunctionType::get(returnType, paramTypes, false);
    // 함수를 둘러싸고 있는 이름공간이 있을 경우 이름공간 접두사 추가
    std::string funcName = [&]() {
        if (CodeGenerator::getInstance().scopes.empty()) {
            return "_" + this->name;
        }
        else {
            return join(CodeGenerator::getInstance().scopes, "#") + "#" + this->name;
        }
        }();

    llvm::Function* function = llvm::Function::Create(funcType, llvm::Function::ExternalLinkage, this->name, CodeGenerator::getInstance().module.get());

    // TODO: 심볼 테이블에 함수 심볼 추가
    // TODO: 지금까지 symboltable에 함수 심볼을 추가하고, 기존 심볼 테이블의 정보를 계승받는 새로운 심볼 테이블을 만들어서, 거기에 함수 내부 변수등이 선언되어 들어가도록 함
    Symbol* functionSymbol = new FunctionSymbol(this->name, this->getType().get(), function, false, SymbolType::FUNCTION);
    CodeGenerator::getInstance().symbolTable.addSymbol(this->name, functionSymbol);
    CodeGenerator::getInstance().symbolTable.setCurrentSymbol(functionSymbol);
    CodeGenerator::getInstance().symbolTable.enterScope();

    // 함수 인자 심볼 추가
    int cnt = 0;
    for (auto& arg : this->parameters) {
        Symbol* paramSymbol = new Symbol(((ParameterNode*)arg.get())->name, arg->getType().get(), function->getArg(cnt), false, SymbolType::VARIABLE);
        CodeGenerator::getInstance().symbolTable.addSymbol(((ParameterNode*)arg.get())->name, paramSymbol);
        cnt += 1;
    }

    // block start
    llvm::BasicBlock* bb = llvm::BasicBlock::Create(CodeGenerator::getInstance().context, "entry", function);
    CodeGenerator::getInstance().builder.SetInsertPoint(bb);
    this->body->codegen();
    // block end
    // body에 return이 있을 것이므로 여기서 리턴 코드를 추가하지 않음

    CodeGenerator::getInstance().symbolTable.exitScope();

    return nullptr;
}