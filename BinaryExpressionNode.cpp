#include "BinaryExpressionNode.h"
#include "ASTVisitor.h"

#include <iostream>


void BinaryExpressionNode::accept(ASTVisitor& visitor) {
    visitor.visit(*this);
}

/*bool isStringTypeFromLLVM(llvm::Value* value, CodeGenerator* codeGenerator) {
    return value->getType()->isPointerTy() && ((llvm::PointerType*)value->getType())->isValidElementType(llvm::Type::getInt8Ty(codeGenerator->context));
}*/

llvm::Value* BinaryExpressionNode::codegen() {
    llvm::Value* leftValue = left->codegen();
    llvm::Value* rightValue = right->codegen();
    if (!leftValue || !rightValue) {
        return nullptr;
    }

    if (leftValue->getType()->isPointerTy()) {
        leftValue = codeGenerator->builder.CreateLoad(codeGenerator->getLLVMType(left->getType().get()), leftValue, "loadtmp");
    }
    if (rightValue->getType()->isPointerTy()) {
        rightValue = codeGenerator->builder.CreateLoad(codeGenerator->getLLVMType(right->getType().get()), rightValue, "loadtmp");
    }

    if (op == "+") {
        // If leftvalue and rightvalue are both numerical primitives type, perform numerical addition.
        // If leftvalue and rightvalue are both objects based on class, perform method call.
        // If leftvalue and rightvalue are different types, perform type casting and then addition.
        // First, we need to check if leftValue and rightValue are both numerical primitives type.
        if (left->getType()->getName() == right->getType()->getName()) {
            if (left->getType()->isIntegerTy()) {
                return codeGenerator->builder.CreateAdd(leftValue, rightValue, "addtmp");
            }
            else if (left->getType()->isFloatTy()) {
                return codeGenerator->builder.CreateFAdd(leftValue, rightValue, "faddtmp");
            }
            else {
                std::cerr << "Type error: Operator '" << op << "' not applicable to type '" << left->getType()->getName() << "' and '" << right->getType()->getName() << "'" << std::endl;
                return nullptr;
            }
        }
        else {
            // TODO: 상속 관계일 경우 비교 연산자가 재정의 되어 있는지 확인 후 해당 메소드 호출
            // 없다면, 아래 오류 발생
            std::cerr << "Type error: Left and right expressions have different types for operator '" << op << "'" << std::endl;
            return nullptr;
        }
    }
    else if (op == "-") {
        if (left->getType()->getName() == right->getType()->getName()) {
            if (left->getType()->isIntegerTy()) {
                return codeGenerator->builder.CreateSub(leftValue, rightValue, "subtmp");
            }
            else if (left->getType()->isFloatTy()) {
                return codeGenerator->builder.CreateFSub(leftValue, rightValue, "fsubtmp");
            }
            else {
                std::cerr << "Type error: Operator '" << op << "' not applicable to type '" << left->getType()->getName() << "' and '" << right->getType()->getName() << "'" << std::endl;
                return nullptr;
            }
        }
        else {
            std::cerr << "Type error: Operator '" << op << "' not applicable to type '" << left->type->getName() << "' and '" << right->type->getName() << "'" << std::endl;
            return nullptr;
        }
    }
    else if (op == "*") {
        if (left->getType()->getName() == right->getType()->getName()) {
            if (left->getType()->isIntegerTy()) {
                return codeGenerator->builder.CreateMul(leftValue, rightValue, "subtmp");
            }
            else if (left->getType()->isFloatTy()) {
                return codeGenerator->builder.CreateFMul(leftValue, rightValue, "fsubtmp");
            }
            else {
                std::cerr << "Type error: Operator '" << op << "' not applicable to type '" << left->getType()->getName() << "' and '" << right->getType()->getName() << "'" << std::endl;
                return nullptr;
            }
        }
        else {
            std::cerr << "Type error: Operator '" << op << "' not applicable to type '" << left->type->getName() << "' and '" << right->type->getName() << "'" << std::endl;
            return nullptr;
        }
    }
    else if (op == "/") {
        if (left->getType()->getName() == right->getType()->getName()) {
            if (left->getType()->isIntegerTy()) {
                // signed?
                return codeGenerator->builder.CreateSDiv(leftValue, rightValue, "subtmp");
            }
            else if (left->getType()->isFloatTy()) {
                return codeGenerator->builder.CreateFDiv(leftValue, rightValue, "fsubtmp");
            }
            else {
                std::cerr << "Type error: Operator '" << op << "' not applicable to type '" << left->getType()->getName() << "' and '" << right->getType()->getName() << "'" << std::endl;
                return nullptr;
            }
        }
        else {
            std::cerr << "Type error: Operator '" << op << "' not applicable to type '" << left->type->getName() << "' and '" << right->type->getName() << "'" << std::endl;
            return nullptr;
        }
    }
    else if (op == ">") {
        return codeGenerator->builder.CreateICmpSGT(leftValue, rightValue, "gttmp");
    }
    else if (op == "<") {
        return codeGenerator->builder.CreateICmpSLT(leftValue, rightValue, "lttmp");
    }
    else if (op == "==") {
        return codeGenerator->builder.CreateICmpEQ(leftValue, rightValue, "eqtmp");
    }
    else if (op == ">=") {
        return codeGenerator->builder.CreateICmpSGE(leftValue, rightValue, "getmp");
    }
    else if (op == "<=") {
        return codeGenerator->builder.CreateICmpSLE(leftValue, rightValue, "letmp");
    }
    else {
        std::cerr << "Unsupported binary operator: " << op << std::endl;
        return nullptr;
    }
}

std::shared_ptr<Type> BinaryExpressionNode::getType() {
    if (type) return type;

    auto leftType = left->getType().get();
    auto rightType = right->getType().get();

    if (!leftType->equals(rightType)) {
        std::cerr << "Type error: Left and right expressions have different types" << std::endl;
        type = std::make_shared<UnknownType>();
        return type;
    }

    if (op == "+" || op == "-" || op == "*" || op == "/") {
        if (leftType->getName() == "Int" || leftType->getName() == "Float" || leftType->getName() == "Double") {
            // 기존 raw 포인터를 이용해 새 객체를 만들지 않고,
            // 서브식이 갖고 있는 shared_ptr을 그대로 재사용하여 타입을 설정.
            type = left->getType();
            return type;
        }
        else {
            std::cerr << "Type error: Operator '" << op << "' not applicable to type '" << leftType->getName() << "'" << std::endl;
            type = std::make_shared<UnknownType>();
            return type;
        }
    }
    else {
        // 다른 연산자 추가 시 처리 예정
    }

    type = std::make_shared<UnknownType>();
    return type;
}