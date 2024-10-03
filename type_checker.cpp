// type_checker.cpp

#include "type_checker.h"
#include <iostream>

void TypeChecker::visit(VariableDeclarationNode& node) {
    if (node.initializer) {
        node.initializer->accept(*this);
        auto initType = node.initializer->getType();

        // 변수의 타입과 초기화 식의 타입 비교
        if (node.type) {
            // 변수 선언 시 타입이 명시된 경우
            if (!node.type->equals(initType)) {
                std::cerr << "Type error: Variable '" << node.name << "' declared as '" << node.type->name << "' but initialized with '" << initType->name << "'" << std::endl;
            }
        } else {
            // 타입이 명시되지 않은 경우 초기화 식의 타입으로 설정
            node.type = initType;
        }
    } else {
        if (!node.type) {
            std::cerr << "Type error: Variable '" << node.name << "' has no type and no initializer" << std::endl;
            node.type = std::make_shared<UnknownType>();
        }
    }
}

void TypeChecker::visit(FunctionDeclarationNode& node) {
    // 파라미터 타입 검사
    for (auto& param : node.parameters) {
        if (!param->type) {
            std::cerr << "Type error: Parameter '" << param->name << "' has no type" << std::endl;
            param->type = std::make_shared<UnknownType>();
        }
    }

    // 함수 본문 타입 검사
    if (node.body) {
        node.body->accept(*this);
        auto bodyType = node.body->getType();

        // 반환 타입과 함수 본문의 타입 비교
        if (node.returnType) {
            if (!node.returnType->equals(bodyType)) {
                std::cerr << "Type error: Function '" << node.name << "' declared to return '" << node.returnType->name << "' but returns '" << bodyType->name << "'" << std::endl;
            }
        } else {
            // 반환 타입이 명시되지 않은 경우 함수 본문의 타입으로 설정
            node.returnType = bodyType;
        }
    }
}

void TypeChecker::visit(ExpressionNode& node) {
    node.getType();
}

void TypeChecker::visit(BinaryExpressionNode& node) {
    node.getType();
}

// 기타 필요한 방문 함수 구현
void TypeChecker::visit(ProgramNode& node) {
    node.getType();
}

void TypeChecker::visit(ClassDeclarationNode& node) {
    node.getType();
}

void TypeChecker::visit(ObjectDeclarationNode& node) {
    node.getType();
}

void TypeChecker::visit(IfStatementNode& node) {
    node.getType();
}

void TypeChecker::visit(ForStatementNode& node) {
    node.getType();
}

void TypeChecker::visit(ReturnStatementNode& node) {
    node.getType();
}

void TypeChecker::visit(BlockNode& node) {
    node.getType();
}

void TypeChecker::visit(AssignmentNode& node) {
    node.getType();
}

void TypeChecker::visit(ClassBodyNode& node) {
    node.getType();
}

void TypeChecker::visit(ParameterNode& node) {
    node.getType();
}

void TypeChecker::visit(MatchExpressionNode& node) {
    node.getType();
}

void TypeChecker::visit(RangeExpressionNode& node) {
    node.getType();
}

void TypeChecker::visit(ImportNode& node) {
    node.getType();
}

void TypeChecker::visit(UnitNode& node) {
    node.getType();
}

void TypeChecker::visit(CallExpressionNode& node) {
    node.getType();
}

void TypeChecker::visit(MethodCallNode& node) {
	node.getType();
}

void TypeChecker::visit(IdentifierNode& node) {
    node.getType();
}

void TypeChecker::visit(ValueNode& node) {
    node.getType();
}

void TypeChecker::visit(FunctionCallNode& node) {
	node.getType();
}

void TypeChecker::visit(ArrayAccessNode& node)
{
	node.getType();
}

void TypeChecker::visit(ArrayCreationNode& node)
{
	node.getType();
}

void TypeChecker::visit(AccessFieldNode& node)
{
    node.getType();
}

void TypeChecker::visit(ClassInstanceCreationNode& node) {
    node.getType();
}

void TypeChecker::visit(ArrayCreationExpressionNode& node) {
    node.getType();
}

void TypeChecker::visit(AssignmentExpressionNode& node) {
    node.getType();
}

void TypeChecker::visit(UnaryExpressionNode& node) {
    node.getType();
}

void TypeChecker::visit(CastingExpressionNode& node) {
	node.getType();
}

void TypeChecker::visit(PostfixExpressionNode& node) {
    node.getType();
}

void TypeChecker::visit(PrefixExpressionNode& node) {
    node.getType();
}