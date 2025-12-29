#include "PostfixExpressionNode.h"
#include "ASTVisitor.h"

#include <iostream>
#include <llvm/IR/Constants.h>

void PostfixExpressionNode::accept(ASTVisitor& visitor) {
    visitor.visit(*this);
}

llvm::Value* PostfixExpressionNode::codegen() {
    llvm::Value* value = expression->codegen();
    if (!value) {
        std::cerr << "Error: Unary expression failed" << std::endl;
        return nullptr;
    }

    if (op == "++") {
        // increment
        // byte, char, word, short, int, long, long long, float, double, long double만 가능하도록 변경
        if (value->getType()->isIntegerTy(1)) { // byte

            return codeGenerator->builder.CreateAdd(value, llvm::ConstantInt::get(codeGenerator->context, llvm::APInt(1, 1)), "inc");
        }
        else if (value->getType()->isIntegerTy(8)) { // char
            return codeGenerator->builder.CreateAdd(value, llvm::ConstantInt::get(codeGenerator->context, llvm::APInt(8, 1)), "inc");
        }
        else if (value->getType()->isIntegerTy(16)) { // word, short
            return codeGenerator->builder.CreateAdd(value, llvm::ConstantInt::get(codeGenerator->context, llvm::APInt(16, 1)), "inc");
        }
        else if (value->getType()->isIntegerTy(32)) { // int
            return codeGenerator->builder.CreateAdd(value, llvm::ConstantInt::get(codeGenerator->context, llvm::APInt(32, 1)), "inc");
        }
        else if (value->getType()->isIntegerTy(64)) { // long, long long
            return codeGenerator->builder.CreateAdd(value, llvm::ConstantInt::get(codeGenerator->context, llvm::APInt(64, 1)), "inc");
        }
        else if (value->getType()->isFloatTy()) { // float
            return codeGenerator->builder.CreateFAdd(value, llvm::ConstantFP::get(codeGenerator->context, llvm::APFloat(1.0)), "inc");
        }
        else if (value->getType()->isDoubleTy()) { // double
            return codeGenerator->builder.CreateFAdd(value, llvm::ConstantFP::get(codeGenerator->context, llvm::APFloat(1.0)), "inc");
        }
        else if (value->getType()->isStructTy()) {
            // 구조체일 경우 구조체 안에 '++' 연산자가 정의되어 있는지 확인 후 사용할 수 있다면, 사용
            auto classType = llvm::cast<llvm::StructType>(value->getType());
            auto classSymbolOpt = codeGenerator->symbolTable.lookupClass(classType->getName().str());

            if (classSymbolOpt) {
                auto classSymbol = *classSymbolOpt;
                auto method = classSymbol->getMethod("operator--");
                if (method) {
                    // '++' 연산자 메서드 호출
                    std::vector<llvm::Value*> args;
                    return codeGenerator->builder.CreateCall(llvm::FunctionCallee(method->function), args, "inc");
                }
                else {
                    std::cerr << "Error: '++' operator not defined for class " << classType->getName().str() << std::endl;
                    return nullptr;
                }
            }
            else {
                std::cerr << "Error: Class symbol not found for type " << classType->getName().str() << std::endl;
                return nullptr;
            }
        }
        else {
            std::cerr << "Error: Increment operator not applicable to type" << std::endl;
            return nullptr;
        }
    }
    else if (op == "--") {
        // decrement
        // byte, char, word, short, int, long, long long, float, double, long double만 가능하도록 변경
        if (value->getType()->isIntegerTy(1)) { // byte
            return codeGenerator->builder.CreateSub(value, llvm::ConstantInt::get(codeGenerator->context, llvm::APInt(1, 1)), "dec");
        }
        else if (value->getType()->isIntegerTy(8)) { // char
            return codeGenerator->builder.CreateSub(value, llvm::ConstantInt::get(codeGenerator->context, llvm::APInt(8, 1)), "dec");
        }
        else if (value->getType()->isIntegerTy(16)) { // word, short
            return codeGenerator->builder.CreateSub(value, llvm::ConstantInt::get(codeGenerator->context, llvm::APInt(16, 1)), "dec");
        }
        else if (value->getType()->isIntegerTy(32)) { // int
            return codeGenerator->builder.CreateSub(value, llvm::ConstantInt::get(codeGenerator->context, llvm::APInt(32, 1)), "dec");
        }
        else if (value->getType()->isIntegerTy(64)) { // long, long long
            return codeGenerator->builder.CreateSub(value, llvm::ConstantInt::get(codeGenerator->context, llvm::APInt(64, 1)), "dec");
        }
        else if (value->getType()->isFloatTy()) { // float
            return codeGenerator->builder.CreateFSub(value, llvm::ConstantFP::get(codeGenerator->context, llvm::APFloat(1.0)), "dec");
        }
        else if (value->getType()->isDoubleTy()) { // double
            return codeGenerator->builder.CreateFSub(value, llvm::ConstantFP::get(codeGenerator->context, llvm::APFloat(1.0)), "dec");
        }
        else if (value->getType()->isStructTy()) {
            // 구조체일 경우 구조체 안에 '++' 연산자가 정의되어 있는지 확인 후 사용할 수 있다면, 사용
            auto classType = llvm::cast<llvm::StructType>(value->getType());
            auto classSymbolOpt = codeGenerator->symbolTable.lookupClass(classType->getName().str());

            if (classSymbolOpt) {
                auto classSymbol = *classSymbolOpt;
                auto method = classSymbol->getMethod("operator++");
                if (method) {
                    // '++' 연산자 메서드 호출
                    std::vector<llvm::Value*> args;
                    return codeGenerator->builder.CreateCall(llvm::FunctionCallee(method->function), args, "inc");
                }
                else {
                    std::cerr << "Error: '++' operator not defined for class " << classType->getName().str() << std::endl;
                    return nullptr;
                }
            }
            else {
                std::cerr << "Error: Class symbol not found for type " << classType->getName().str() << std::endl;
                return nullptr;
            }
        }
        else {
            std::cerr << "Error: Increment operator not applicable to type" << std::endl;
            return nullptr;
        }
    }
    else {
        std::cerr << "Unsupported unary operator: " << op << std::endl;
    }

    return nullptr;
}

std::shared_ptr<Type> PostfixExpressionNode::getType() {
    auto res = this->codegen();
    if (res->getType()->isVoidTy()) {
        return std::make_shared<BasicType>("Void");
    }
    else if (res->getType()->isStructTy()) {
        return std::make_shared<ClassType>(res->getType()->getStructName().str());
    }
    else if (res->getType()->isIntegerTy(1)) {
        return std::make_shared<BasicType>("Bool");
    }
    else if (res->getType()->isIntegerTy(8)) {
        return std::make_shared<BasicType>("Byte");
    }
    else if (res->getType()->isIntegerTy(16)) {
        return std::make_shared<BasicType>("Short");
    }
    else if (res->getType()->isIntegerTy(32)) {
        return std::make_shared<BasicType>("Int");
    }
    else if (res->getType()->isIntegerTy(64)) {
        return std::make_shared<BasicType>("Long");
    }
    else if (res->getType()->isFloatTy()) {
        return std::make_shared<BasicType>("Float");
    }
    else if (res->getType()->isDoubleTy()) {
        return std::make_shared<BasicType>("Double");
    }
    else {
        return std::make_shared<UnknownType>();
    }
}