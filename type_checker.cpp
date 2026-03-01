// type_checker.cpp

#include "type_checker.h"

#include <iostream>

#include "all_ast.h"

namespace {
bool isResolvedType(const std::unique_ptr<Type>& type) {
    return type && type->getKind() != Type::Kind::UNKNOWN;
}
}

void TypeChecker::reportError(const std::string& message) {
    ++errorCount;
    std::cerr << message << std::endl;
}

void TypeChecker::checkTypeResolved(const std::unique_ptr<Type>& type, const std::string& context) {
    if (!isResolvedType(type)) {
        reportError("Type error: Failed to resolve type for " + context);
    }
}

void TypeChecker::visit(VariableDeclarationNode& node) {
    if (node.initializer) {
        node.initializer->accept(*this);
        auto initType = node.initializer->getType();

        if (node.type) {
            if (isResolvedType(node.type) && isResolvedType(initType) && !node.type->equals(initType)) {
                reportError(
                    "Type error: Variable '" + node.name + "' declared as '" +
                    node.type->getName() + "' but initialized with '" + initType->getName() + "'");
            }
        }
        else {
            node.type = initType ? initType->clone() : std::make_unique<UnknownType>();
        }
    }
    else if (!node.type) {
        reportError("Type error: Variable '" + node.name + "' has no type and no initializer");
        node.type = std::make_unique<UnknownType>();
    }
}

void TypeChecker::visit(FunctionDeclarationNode& node) {
    for (auto& param : node.parameters) {
        if (param) {
            param->accept(*this);
        }
    }

    if (node.body) {
        node.body->accept(*this);
        auto bodyType = node.body->getType();

        if (node.returnType) {
            if (isResolvedType(node.returnType) && isResolvedType(bodyType) && !node.returnType->equals(bodyType)) {
                reportError(
                    "Type error: Function '" + node.name + "' declared to return '" +
                    node.returnType->getName() + "' but returns '" + bodyType->getName() + "'");
            }
        }
        else if (isResolvedType(bodyType)) {
            node.returnType = bodyType->clone();
        }
    }
}

void TypeChecker::visit(ExpressionNode& node) {
    checkTypeResolved(node.getType(), "expression");
}

void TypeChecker::visit(BinaryExpressionNode& node) {
    if (node.left) {
        node.left->accept(*this);
    }
    if (node.right) {
        node.right->accept(*this);
    }
    checkTypeResolved(node.getType(), "binary expression");
}

void TypeChecker::visit(ProgramNode& node) {
    for (auto& stmt : node.statements) {
        if (stmt) {
            stmt->accept(*this);
        }
    }
}

void TypeChecker::visit(ClassDeclarationNode& node) {
    for (auto& param : node.constructorParams) {
        if (param) {
            param->accept(*this);
        }
    }
    if (node.body) {
        node.body->accept(*this);
    }
}

void TypeChecker::visit(ObjectDeclarationNode& node) {
    if (node.body) {
        node.body->accept(*this);
    }
}

void TypeChecker::visit(IfStatementNode& node) {
    if (node.condition) {
        node.condition->accept(*this);
        checkTypeResolved(node.condition->getType(), "if condition");
    }
    if (node.thenBlock) {
        node.thenBlock->accept(*this);
    }
    if (node.elseBlock) {
        node.elseBlock->accept(*this);
    }
}

void TypeChecker::visit(ForStatementNode& node) {
    if (node.iterableExpr) {
        node.iterableExpr->accept(*this);
    }
    if (node.body) {
        node.body->accept(*this);
    }
}

void TypeChecker::visit(ReturnStatementNode& node) {
    if (node.expression) {
        node.expression->accept(*this);
        checkTypeResolved(node.expression->getType(), "return expression");
    }
}

void TypeChecker::visit(BlockNode& node) {
    for (auto& stmt : node.statements) {
        if (stmt) {
            stmt->accept(*this);
        }
    }
}

void TypeChecker::visit(AssignmentNode& node) {
    if (node.expression) {
        node.expression->accept(*this);
    }
}

void TypeChecker::visit(ClassBodyNode& node) {
    for (auto& field : node.fields) {
        if (field) {
            field->accept(*this);
        }
    }
    for (auto& method : node.methods) {
        if (method) {
            method->accept(*this);
        }
    }
}

void TypeChecker::visit(ParameterNode& node) {
    checkTypeResolved(node.getType(), "parameter");
}

void TypeChecker::visit(MatchExpressionNode& node) {
    if (node.expression) {
        node.expression->accept(*this);
    }
    for (auto& casePair : node.cases) {
        if (casePair.first) {
            casePair.first->accept(*this);
        }
        if (casePair.second) {
            casePair.second->accept(*this);
        }
    }
}

void TypeChecker::visit(RangeExpressionNode& node) {
    if (node.startExpr) {
        node.startExpr->accept(*this);
    }
    if (node.endExpr) {
        node.endExpr->accept(*this);
    }
}

void TypeChecker::visit(ImportNode& node) {
    (void)node;
}

void TypeChecker::visit(UnitNode& node) {
    (void)node;
}

void TypeChecker::visit(CallExpressionNode& node) {
    if (node.callee) {
        node.callee->accept(*this);
    }
    for (auto& arg : node.arguments) {
        if (arg) {
            arg->accept(*this);
        }
    }
    checkTypeResolved(node.getType(), "call expression");
}

void TypeChecker::visit(MethodCallNode& node) {
    if (node.object) {
        node.object->accept(*this);
    }
    for (auto& arg : node.arguments) {
        if (arg) {
            arg->accept(*this);
        }
    }
    checkTypeResolved(node.getType(), "method call");
}

void TypeChecker::visit(IdentifierNode& node) {
    checkTypeResolved(node.getType(), "identifier '" + node.value + "'");
}

void TypeChecker::visit(ValueNode& node) {
    checkTypeResolved(node.getType(), "value literal");
}

void TypeChecker::visit(FunctionCallNode& node) {
    for (auto& arg : node.arguments) {
        if (arg) {
            arg->accept(*this);
        }
    }
    checkTypeResolved(node.getType(), "function call '" + node.functionName + "'");
}

void TypeChecker::visit(ArrayAccessNode& node) {
    if (node.array) {
        node.array->accept(*this);
    }
    if (node.index) {
        node.index->accept(*this);
    }
    checkTypeResolved(node.getType(), "array access");
}

void TypeChecker::visit(ArrayCreationNode& node) {
    for (auto& element : node.elements) {
        if (element) {
            element->accept(*this);
        }
    }
    checkTypeResolved(node.getType(), "array creation");
}

void TypeChecker::visit(AccessFieldNode& node) {
    if (node.base) {
        node.base->accept(*this);
    }
    if (node.field) {
        node.field->accept(*this);
    }
    checkTypeResolved(node.getType(), "field access");
}

void TypeChecker::visit(ClassInstanceCreationNode& node) {
    for (auto& arg : node.arguments) {
        if (arg) {
            arg->accept(*this);
        }
    }
    checkTypeResolved(node.getType(), "class instance creation");
}

void TypeChecker::visit(ArrayCreationExpressionNode& node) {
    for (auto& sizeExpr : node.sizes) {
        if (sizeExpr) {
            sizeExpr->accept(*this);
        }
    }
    checkTypeResolved(node.getType(), "array creation expression");
}

void TypeChecker::visit(AssignmentExpressionNode& node) {
    if (node.left) {
        node.left->accept(*this);
    }
    if (node.right) {
        node.right->accept(*this);
    }
    checkTypeResolved(node.getType(), "assignment expression");
}

void TypeChecker::visit(UnaryExpressionNode& node) {
    if (node.expression) {
        node.expression->accept(*this);
    }
    checkTypeResolved(node.getType(), "unary expression");
}

void TypeChecker::visit(CastingExpressionNode& node) {
    if (node.expression) {
        node.expression->accept(*this);
    }
    if (node.typeNode) {
        node.typeNode->accept(*this);
    }
    checkTypeResolved(node.getType(), "casting expression");
}

void TypeChecker::visit(PostfixExpressionNode& node) {
    if (node.expression) {
        node.expression->accept(*this);
    }
    checkTypeResolved(node.getType(), "postfix expression");
}

void TypeChecker::visit(PrefixExpressionNode& node) {
    if (node.expression) {
        node.expression->accept(*this);
    }
    checkTypeResolved(node.getType(), "prefix expression");
}

void TypeChecker::visit(AttributeNode& node) {
    if (node.expr) {
        node.expr->accept(*this);
    }
    if (node.target) {
        node.target->accept(*this);
    }
}

void TypeChecker::visit(LambdaExpressionNode& node) {
    for (auto& arg : node.arguments) {
        if (arg) {
            arg->accept(*this);
        }
    }
    if (node.body) {
        node.body->accept(*this);
    }
    checkTypeResolved(node.getType(), "lambda expression");
}

void TypeChecker::visit(MapStatementNode& node) {
    if (node.iterableExpr) {
        node.iterableExpr->accept(*this);
    }
    if (node.body) {
        node.body->accept(*this);
    }
    checkTypeResolved(node.getType(), "map statement");
}

void TypeChecker::visit(PMapStatementNode& node) {
    if (node.iterableExpr) {
        node.iterableExpr->accept(*this);
    }
    if (node.body) {
        node.body->accept(*this);
    }
    checkTypeResolved(node.getType(), "pmap statement");
}

void TypeChecker::visit(ReduceStatementNode& node) {
    if (node.iterableExpr) {
        node.iterableExpr->accept(*this);
    }
    if (node.body) {
        node.body->accept(*this);
    }
    if (node.initialValue) {
        node.initialValue->accept(*this);
    }
    checkTypeResolved(node.getType(), "reduce statement");
}

void TypeChecker::visit(FilterStatementNode& node) {
    if (node.iterableExpr) {
        node.iterableExpr->accept(*this);
    }
    if (node.body) {
        node.body->accept(*this);
    }
    checkTypeResolved(node.getType(), "filter statement");
}

void TypeChecker::visit(WhileStatementNode& node) {
    if (node.condition) {
        node.condition->accept(*this);
        checkTypeResolved(node.condition->getType(), "while condition");
    }
    if (node.body) {
        node.body->accept(*this);
    }
}

void TypeChecker::visit(ArrayLiteralNode& node) {
    for (auto& element : node.elements) {
        if (element) {
            element->accept(*this);
        }
    }
    checkTypeResolved(node.getType(), "array literal");
}

void TypeChecker::visit(TemplateDeclarationNode& node) {
    if (node.templateParams.empty() && node.typeParameters.empty()) {
        reportError("Type error: Template declaration has no type parameters");
    }
    if (node.declaration) {
        node.declaration->accept(*this);
    }
}
