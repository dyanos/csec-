#include "ast.h"
#include "codegen.h"
#include "utils.h"
#include <iostream>

void BinaryExpressionNode::accept(ASTVisitor& visitor) {
    visitor.visit(*this);
}

llvm::Value* BinaryExpressionNode::codegen() {
    llvm::Value* leftValue = left->codegen();
    llvm::Value* rightValue = right->codegen();
    if (!leftValue || !rightValue) {
        return nullptr;
    }

    if (op == "+") {
        // String concatenation or pointer arithmetic
        if (isStringTypeFromLLVM(leftValue, codeGenerator) && rightValue->getType()->isIntegerTy()) {
            llvm::Value* int64Pointer = codeGenerator->builder.CreatePtrToInt(rightValue, llvm::Type::getInt64Ty(codeGenerator->context), "int64Pointer");
            llvm::Value* resultPointer = codeGenerator->builder.CreateAdd(int64Pointer, leftValue, "resultPointer");
            return codeGenerator->builder.CreateIntToPtr(resultPointer, llvm::Type::getInt8Ty(codeGenerator->context), "resultPointer");
        }
        else if (isStringTypeFromLLVM(rightValue, codeGenerator) && leftValue->getType()->isIntegerTy()) {
            llvm::Value* int64Pointer = codeGenerator->builder.CreatePtrToInt(rightValue, llvm::Type::getInt64Ty(codeGenerator->context), "int64Pointer");
            llvm::Value* resultPointer = codeGenerator->builder.CreateAdd(int64Pointer, leftValue, "resultPointer");
            return resultPointer;
        }
        else if (isStringTypeFromLLVM(leftValue, codeGenerator) && isStringTypeFromLLVM(rightValue, codeGenerator)) {
            llvm::Value* intToString = codeGenerator->builder.CreateCall(codeGenerator->module->getFunction("toString"), rightValue, "intToString");
            return codeGenerator->builder.CreateCall(codeGenerator->module->getFunction("operator+"), {leftValue, intToString}, "concattmp");
        }
        else {
            // Numeric addition
            if (leftValue->getType()->isIntegerTy() && rightValue->getType()->isIntegerTy()) {
                return codeGenerator->builder.CreateAdd(leftValue, rightValue, "addtmp");
            }
            else if (leftValue->getType()->isFloatingPointTy() && rightValue->getType()->isFloatingPointTy()) {
                return codeGenerator->builder.CreateFAdd(leftValue, rightValue, "faddtmp");
            }
            // String concatenation
            else if (isStringTypeFromLLVM(leftValue, codeGenerator) && isStringTypeFromLLVM(rightValue, codeGenerator)) {
                return codeGenerator->builder.CreateCall(codeGenerator->module->getFunction("operator+"), {leftValue, rightValue}, "concattmp");
            }
            // Type conversion and addition
            else if (leftValue->getType() == rightValue->getType()) {
                llvm::Function* constructor = codeGenerator->module->getFunction(left->type->name);
                if (!constructor) {
                    std::cerr << "Error: Constructor not found for type '" << right->type->name << "' from " << left->type->name << std::endl;
                    return nullptr;
                }
                llvm::Value* convertedValue = codeGenerator->builder.CreateCall(constructor, {rightValue}, "casttmp");
                return codeGenerator->builder.CreateCall(codeGenerator->module->getFunction("operator+"), {leftValue, convertedValue}, "addtmp");
            }
            else {
                std::cerr << "Type error: Operator '" << op << "' not applicable to type '" << left->type->name << "' and '" << right->type->name << "'" << std::endl;
                return nullptr;
            }
        }
    }
    // ... 다른 연산자들에 대한 처리 ...

    std::cerr << "Unsupported binary operator: " << op << std::endl;
    return nullptr;
}

std::shared_ptr<Type> BinaryExpressionNode::getType() {
    if (type) return type;

    auto leftType = left->getType();
    auto rightType = right->getType();

    if (!leftType->equals(rightType)) {
        std::cerr << "Type error: Left and right expressions have different types" << std::endl;
        type = std::make_shared<UnknownType>();
        return type;
    }

    if (op == "+" || op == "-" || op == "*" || op == "/") {
        if (leftType->name == "Int" || leftType->name == "Float" || leftType->name == "Double") {
            type = leftType;
            return type;
        }
        else {
            std::cerr << "Type error: Operator '" << op << "' not applicable to type '" << leftType->name << "'" << std::endl;
            type = std::make_shared<UnknownType>();
            return type;
        }
    }

    type = std::make_shared<UnknownType>();
    return type;
} 
