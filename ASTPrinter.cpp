#include "ast.h"
#include "utils.h"

#include <iostream>

class ASTPrinter : public ASTVisitor {
public:
    void visit(ProgramNode& node) override {
        for (auto& stmt : node.statements) {
            stmt->accept(*this);
        }
    }

    void visit(ObjectDeclarationNode& node) override {
        std::cout << "ObjectDeclaration: " << node.name << std::endl;
        if (node.body) {
            node.body->accept(*this);
        }
    }

    void visit(FunctionDeclarationNode& node) override {
        std::cout << "FunctionDeclaration: " << node.name << std::endl;
        std::cout << "Parameters:" << std::endl;
        for (auto& param : node.parameters) {
            param->accept(*this);
        }
        if (node.body) {
            node.body->accept(*this);
        }
    }

    void visit(ParameterNode& node) override {
        std::cout << "- " << node.name << ": " << node.type << std::endl;
    }

    void visit(BlockNode& node) override {
        std::cout << "Block:" << std::endl;
        for (auto& stmt : node.statements) {
            stmt->accept(*this);
        }
    }

    void visit(ExpressionNode& node) override {
        std::cout << "Expression: " << node.value << std::endl;
    }

    void visit(IfStatementNode& node) override {
        std::cout << "IfStatement:" << std::endl;
        std::cout << "Condition:" << std::endl;
        node.condition->accept(*this);
        std::cout << "Then Block:" << std::endl;
        node.thenBlock->accept(*this);
        if (node.elseBlock) {
            std::cout << "Else Block:" << std::endl;
            node.elseBlock->accept(*this);
        }
    }

    void visit(ForStatementNode& node) override {
        std::cout << "ForStatement:" << std::endl;
        std::cout << "Variable: " << node.variable << std::endl;
        std::cout << "Collection:" << std::endl;
        //node.collection->accept(*this);
        std::cout << "Body:" << std::endl;
        node.body->accept(*this);
    }

    void visit(MatchExpressionNode& node) {
        std::cout << "MatchExpression:" << std::endl;
        std::cout << "Expression:" << std::endl;
        node.expression->accept(*this);
        std::cout << "Cases:" << std::endl;
        for (auto& c : node.cases) {
            std::cout << "Case:" << std::endl;
            c.first->accept(*this);  // ����
            std::cout << "Result:" << std::endl;
            c.second->accept(*this); // ��� ǥ����
        }
    }

    void visit(ImportNode& node) override {
        std::cout << "Import: " << join(node.path, ".") << std::endl;
    }

    void visit(RangeExpressionNode& node) override {
        std::cout << "RangeExpression:" << std::endl;
        std::cout << "Start:" << std::endl;
        node.startExpr->accept(*this);
        std::cout << "End:" << std::endl;
        node.endExpr->accept(*this);
        /*if (node.step) {
            std::cout << "Step:" << std::endl;
            node.step->accept(*this);
        }*/
    }

    void visit(BinaryExpressionNode& node) override {
        std::cout << "BinaryExpression:" << std::endl;
        std::cout << "Left:" << std::endl;
        node.left->accept(*this);
        std::cout << "Operator: " << node.op << std::endl;
        std::cout << "Right:" << std::endl;
        node.right->accept(*this);
    }

    void visit(AssignmentNode& node) override {
        std::cout << "Assignment:" << std::endl;
        std::cout << "Left:" << node.name << std::endl;
        std::cout << "Right:" << std::endl;
        node.expression->accept(*this);
    }

    void visit(ClassBodyNode& node) override {
        std::cout << "ClassBody:" << std::endl;
        std::cout << "Fields:" << std::endl;
		for (auto& field : node.fields) {
			field->accept(*this);
		}
        std::cout << "Methods:" << std::endl;
        for (auto& member : node.methods) {
            member->accept(*this);
        }
    }

    void visit(ReturnStatementNode& node) override {
        std::cout << "ReturnStatement:" << std::endl;
        if (node.expression) {
            node.expression->accept(*this);
        }
    }

    void visit(NewCallExpressionNode& node) override {
        std::cout << "NewCallExpression:" << std::endl;
        std::cout << "Type: " << node.type << std::endl;
        std::cout << "Arguments:" << std::endl;
        for (auto& arg : node.arguments) {
            arg->accept(*this);
        }
    }

    void visit(NewArrayExpressionNode& node) override {
        std::cout << "NewArrayExpression:" << std::endl;
        std::cout << "Type: " << node.type << std::endl;
        std::cout << "Size:" << std::endl;
		for (auto& size : node.sizes) {
			size->accept(*this);
		}
    }

    void visit(AssignmentExpressionNode& node) override {
        std::cout << "AssignmentExpression:" << std::endl;
        std::cout << "Left:" << std::endl;
        node.left->accept(*this);
        std::cout << "Operator: =" << std::endl;
        std::cout << "Right:" << std::endl;
        node.right->accept(*this);
    }

    void visit(UnaryExpressionNode& node) override {
        std::cout << "UnaryExpression:" << std::endl;
        std::cout << "Operator: " << node.op << std::endl;
        std::cout << "Expression:" << std::endl;
        node.expression->accept(*this);
    }

	void visit(CastingExpressionNode& node) override {
		std::cout << "CastingExpression:" << std::endl;
		std::cout << "Type: " << node.type << std::endl;
		std::cout << "Expression:" << std::endl;
		node.expression->accept(*this);
	}

    void visit(PostfixExpressionNode& node) override {
        std::cout << "PostfixExpression:" << std::endl;
        std::cout << "Expression:" << std::endl;
        node.expression->accept(*this);
        std::cout << "Operator: " << node.op << std::endl;
    }

    void visit(PrefixExpressionNode& node) override {
        std::cout << "PrefixExpression:" << std::endl;
        std::cout << "Operator: " << node.op << std::endl;
        std::cout << "Expression:" << std::endl;
        node.expression->accept(*this);
    }

    void visit(UnitNode& node) override {
        std::cout << "Unit" << std::endl;
    }

    void visit(IdentifierNode& node) override {
        std::cout << "Identifier: " << node.value << std::endl;
    }

    void visit(ValueNode& node) override {
        std::cout << "Value: " << node.value << std::endl;
    }
};