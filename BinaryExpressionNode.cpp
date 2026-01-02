#include "codegen.h"
#include "BinaryExpressionNode.h"
#include "ASTVisitor.h"

#include <iostream>


void BinaryExpressionNode::accept(ASTVisitor& visitor) {
    visitor.visit(*this);
}

/*bool isStringTypeFromLLVM(llvm::Value* value, CodeGenerator* codeGenerator) {
    return value->getType()->isPointerTy() && ((llvm::PointerType*)value->getType())->isValidElementType(llvm::Type::getInt8Ty(CodeGenerator::getInstance().context));
}*/

llvm::Value* BinaryExpressionNode::codegen() {
    llvm::Value* leftValue = left->codegen();
    llvm::Value* rightValue = right->codegen();
    if (!leftValue || !rightValue) {
        return nullptr;
    }

    if (leftValue->getType()->isPointerTy()) {
        leftValue = CodeGenerator::getInstance().builder.CreateLoad(CodeGenerator::getInstance().getLLVMType(left->getType().get()), leftValue, "loadtmp");
    }
    if (rightValue->getType()->isPointerTy()) {
        rightValue = CodeGenerator::getInstance().builder.CreateLoad(CodeGenerator::getInstance().getLLVMType(right->getType().get()), rightValue, "loadtmp");
    }

    if (op == "+") {
        // If leftvalue and rightvalue are both numerical primitives type, perform numerical addition.
        // If leftvalue and rightvalue are both objects based on class, perform method call.
        // If leftvalue and rightvalue are different types, perform type casting and then addition.
        // First, we need to check if leftValue and rightValue are both numerical primitives type.
        if (left->getType()->getName() == right->getType()->getName()) {
            if (left->getType()->isIntegerTy()) {
                return CodeGenerator::getInstance().builder.CreateAdd(leftValue, rightValue, "addtmp");
            }
            else if (left->getType()->isFloatTy()) {
                return CodeGenerator::getInstance().builder.CreateFAdd(leftValue, rightValue, "faddtmp");
            }
            else {
                std::cerr << "Type error: Operator '" << op << "' not applicable to type '" << left->getType()->getName() << "' and '" << right->getType()->getName() << "'" << std::endl;
                return nullptr;
            }
        }
        else {
            // TODO: ��� ������ ��� �� �����ڰ� ������ �Ǿ� �ִ��� Ȯ�� �� �ش� �޼ҵ� ȣ��
            // ���ٸ�, �Ʒ� ���� �߻�
            std::cerr << "Type error: Left and right expressions have different types for operator '" << op << "'" << std::endl;
            return nullptr;
        }
    }
    else if (op == "-") {
        if (left->getType()->getName() == right->getType()->getName()) {
            if (left->getType()->isIntegerTy()) {
                return CodeGenerator::getInstance().builder.CreateSub(leftValue, rightValue, "subtmp");
            }
            else if (left->getType()->isFloatTy()) {
                return CodeGenerator::getInstance().builder.CreateFSub(leftValue, rightValue, "fsubtmp");
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
                return CodeGenerator::getInstance().builder.CreateMul(leftValue, rightValue, "subtmp");
            }
            else if (left->getType()->isFloatTy()) {
                return CodeGenerator::getInstance().builder.CreateFMul(leftValue, rightValue, "fsubtmp");
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
                return CodeGenerator::getInstance().builder.CreateSDiv(leftValue, rightValue, "subtmp");
            }
            else if (left->getType()->isFloatTy()) {
                return CodeGenerator::getInstance().builder.CreateFDiv(leftValue, rightValue, "fsubtmp");
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
        return CodeGenerator::getInstance().builder.CreateICmpSGT(leftValue, rightValue, "gttmp");
    }
    else if (op == "<") {
        return CodeGenerator::getInstance().builder.CreateICmpSLT(leftValue, rightValue, "lttmp");
    }
    else if (op == "==") {
        return CodeGenerator::getInstance().builder.CreateICmpEQ(leftValue, rightValue, "eqtmp");
    }
    else if (op == ">=") {
        return CodeGenerator::getInstance().builder.CreateICmpSGE(leftValue, rightValue, "getmp");
    }
    else if (op == "<=") {
        return CodeGenerator::getInstance().builder.CreateICmpSLE(leftValue, rightValue, "letmp");
    }
    else {
        std::cerr << "Unsupported binary operator: " << op << std::endl;
        return nullptr;
    }
}

std::unique_ptr<Type> BinaryExpressionNode::getType() {
    if (type) return type->clone();

    auto leftType = left->getType();
    auto rightType = right->getType();

    if (!leftType->equals(rightType)) {
        std::cerr << "Type error: Left and right expressions have different types" << std::endl;
        return std::make_unique<UnknownType>();
    }

    if (op == "+" || op == "-" || op == "*" || op == "/") {
        if (leftType->getName() == "Int" || leftType->getName() == "Float" || leftType->getName() == "Double") {
            // ���� raw �����͸� �̿��� �� ��ü�� ������ �ʰ�,
            // ������� ���� �ִ� shared_ptr�� �״�� �����Ͽ� Ÿ���� ����.
            return left->getType();
        }
        else {
            std::cerr << "Type error: Operator '" << op << "' not applicable to type '" << leftType->getName() << "'" << std::endl;
            return std::make_unique<UnknownType>();
        }
    }
    else {
        // �ٸ� ������ �߰� �� ó�� ����
    }

    return std::make_unique<UnknownType>();
}