#pragma once


// ast.h
#pragma once

#include "type.h"
#include "token.h"
#include "symbol.h"

#include <string>
#include <vector>
#include <memory>
#include <llvm/IR/Value.h>
#include <llvm/IR/DerivedTypes.h>

//
class ASTVisitor;
class CodeGenerator;

class ASTNode {
public:
    static CodeGenerator* codeGenerator;
    std::shared_ptr<Type> type;

    virtual ~ASTNode() = default;
    virtual void accept(ASTVisitor& visitor) = 0;
    virtual llvm::Value* codegen() = 0;
    virtual std::shared_ptr<Type> getType() = 0;
};

class ProgramNode : public ASTNode {
public:
    std::vector<std::shared_ptr<ASTNode>> statements;

    void accept(ASTVisitor& visitor) override;
    llvm::Value* codegen() override;
	std::shared_ptr<Type> getType() override {
		return nullptr;
	}
};

class ImportNode : public ASTNode {
public:
    std::vector<std::string> path;

    void accept(ASTVisitor& visitor) override;
    llvm::Value* codegen() override;

    std::shared_ptr<Type> getType() override {
        return nullptr;
    }
};

class ObjectDeclarationNode : public ASTNode {
public:
    std::string name;
    std::shared_ptr<ASTNode> body;

    void accept(ASTVisitor& visitor) override;
    llvm::Value* codegen() override;
    std::shared_ptr<Type> getType() override {
        return nullptr;
    }
};

class ClassBodyNode;
class ParameterNode;

class ClassDeclarationNode : public ASTNode {
public:
    std::string name;
    std::vector<std::shared_ptr<ParameterNode>> constructorParams;
    std::string superClassName;
    std::shared_ptr<ClassBodyNode> body;

    void accept(ASTVisitor& visitor) override;
    llvm::Value* codegen() override;

    std::shared_ptr<Type> getType() override {
        return nullptr;
    }

private:
    std::vector<llvm::Type*> createFieldTypes();
    llvm::StructType* createClassType(const std::vector<llvm::Type*>& fieldTypes);
    ClassSymbol createClassSymbol(llvm::StructType* classType);
    void addFieldsToClassSymbol(ClassSymbol& classSymbol, const std::vector<llvm::Type*>& fieldTypes);
    void addClassSymbolToTable(const ClassSymbol& classSymbol);
    void generateMethodCode();
};

class FunctionDeclarationNode : public ASTNode {
public:
    std::string name;
    std::vector<std::shared_ptr<class ParameterNode>> parameters;
    std::shared_ptr<Type> returnType;
    std::shared_ptr<class BlockNode> body;

    void accept(ASTVisitor& visitor) override;

    llvm::Value* codegen() override;
    std::shared_ptr<Type> getType() override {
        return nullptr;
    }
};

class ParameterNode : public ASTNode {
public:
    std::string name;
    std::shared_ptr<Type> type;

    void accept(ASTVisitor& visitor) override;

    llvm::Value* codegen() override;

    std::shared_ptr<Type> getType() override {
        return nullptr;
    }
};

class BlockNode : public ASTNode {
public:
    std::vector<std::shared_ptr<ASTNode>> statements;

    void accept(ASTVisitor& visitor) override;

    llvm::Value* codegen() override;

    std::shared_ptr<Type> getType() override {
        return nullptr;
    }
};

class ExpressionNode : public ASTNode {
public:
    std::string value;

    void accept(ASTVisitor& visitor) override;

    llvm::Value* codegen() override;
    std::shared_ptr<Type> getType() override;
};

class VariableDeclarationNode : public ASTNode {
public:
    std::string name;
    std::shared_ptr<Type> type;
    std::shared_ptr<ASTNode> initializer;
    bool isMutable;
	bool isField = false;   // 클래스 필드인지 여부

    void accept(ASTVisitor& visitor) override;
    llvm::Value* codegen() override;

    std::shared_ptr<Type> getType() override {
        return nullptr;
    }
};

class ClassBodyNode : public ASTNode {
public:
    std::vector<std::shared_ptr<VariableDeclarationNode>> fields;
    std::vector<std::shared_ptr<FunctionDeclarationNode>> methods;

    void accept(ASTVisitor& visitor) override;
    llvm::Value* codegen() override;

    std::shared_ptr<Type> getType() override {
        return nullptr;
    }

    std::shared_ptr<FunctionDeclarationNode> getMethod(const std::string& name) {
        for (auto method : methods) {
            if (method->name == name) {
                return method;
            }
        }
        return nullptr;
    }
};

class IfStatementNode : public ASTNode {
public:
    std::shared_ptr<ASTNode> condition;
    std::shared_ptr<BlockNode> thenBlock;
    std::shared_ptr<BlockNode> elseBlock;  // else

    void accept(ASTVisitor& visitor) override;
    llvm::Value* codegen() override;

    std::shared_ptr<Type> getType() override {
        return nullptr;
    }
};

class ForStatementNode : public ASTNode {
public:
    std::string variable;
    std::shared_ptr<ASTNode> iterableExpr;
    bool isRange = false;
    bool isInclusive = true;  // `to`̸ true, `until`̸ false
    std::shared_ptr<BlockNode> body;

    void accept(ASTVisitor& visitor) override;
    llvm::Value* codegen() override;

    std::shared_ptr<Type> getType() override {
        return nullptr;
    }
};

// MatchExpressionNode ̸
class MatchExpressionNode : public ASTNode {
public:
    std::shared_ptr<ASTNode> expression;
    std::vector<std::pair<std::shared_ptr<ASTNode>, std::shared_ptr<ASTNode>>> cases;

    void accept(ASTVisitor& visitor) override;
    llvm::Value* codegen() override;

    std::shared_ptr<Type> getType() override {
        return nullptr;
    }
};

class RangeExpressionNode : public ASTNode {
public:
    std::shared_ptr<ASTNode> startExpr;
    std::shared_ptr<ASTNode> endExpr;
    bool isInclusive;  // `to`̸ true, `until`̸ false

    void accept(ASTVisitor& visitor) override;
    llvm::Value* codegen() override;

    std::shared_ptr<Type> getType() override {
        return nullptr;
    }
};

class BinaryExpressionNode : public ASTNode {
public:
    std::shared_ptr<ASTNode> left;
    std::string op;
    std::shared_ptr<ASTNode> right;

    void accept(ASTVisitor& visitor) override;
    llvm::Value* codegen() override;
    std::shared_ptr<Type> getType() override;
};

class AssignmentNode : public ASTNode {
public:
    std::string name;
    std::shared_ptr<ASTNode> expression;

    void accept(ASTVisitor& visitor) override;
    llvm::Value* codegen() override;

    std::shared_ptr<Type> getType() override {
        return nullptr;
    }
};

class ReturnStatementNode : public ASTNode {
public:
    std::shared_ptr<ASTNode> expression;

    void accept(ASTVisitor& visitor) override;
    llvm::Value* codegen() override;

    std::shared_ptr<Type> getType() override {
        return nullptr;
    }
};

class UnitNode : public ASTNode {
public:
    UnitNode() {}

    void accept(ASTVisitor& visitor) override;
	llvm::Value* codegen() override {
		return nullptr;
	}

    std::shared_ptr<Type> getType() override {
        return nullptr;
    }
};

class IdentifierNode : public ASTNode {
public:
	std::string value;

    IdentifierNode(const std::string& value) : value(value) {}

	void accept(ASTVisitor& visitor) override;
	llvm::Value* codegen() override;
	std::shared_ptr<Type> getType() override;
};

enum class ValueType {
	NONE, INT, FLOAT, STRING
};

class ValueNode : public ASTNode {
public:
	std::string value;
	TokenType valueType = TokenType::UNKNOWN;

    ValueNode(const std::string& value, TokenType type) : value(value), valueType(type) {}

	void accept(ASTVisitor& visitor) override;
	llvm::Value* codegen() override;
	std::shared_ptr<Type> getType() override;
};

class CallExpressionNode : public ASTNode {
public:
	std::shared_ptr<ASTNode> callee;
	std::vector<std::shared_ptr<ASTNode>> arguments;

	void accept(ASTVisitor& visitor) override;
	llvm::Value* codegen() override;
	std::shared_ptr<Type> getType() override;
};

class MethodCallNode : public ASTNode {
public:
    std::shared_ptr<ASTNode> object;  // 메서드를 호출하는 객체
    std::string methodName;
    std::vector<std::shared_ptr<ASTNode>> arguments;

    void accept(ASTVisitor& visitor) override;
    llvm::Value* codegen() override;
    std::shared_ptr<Type> getType() override;
};

class ClassInstanceCreationNode : public ASTNode {
public:
    std::string className;
    std::vector<std::shared_ptr<ASTNode>> arguments;

	ClassInstanceCreationNode() {}
    ClassInstanceCreationNode(const std::string& className, std::vector<std::shared_ptr<ASTNode>> arguments)
        : className(className), arguments(arguments) {}

    void accept(ASTVisitor& visitor) override;
    llvm::Value* codegen() override;
    std::shared_ptr<Type> getType() override;
};

// TODO: 나중에 이 노드는 new operator 사용법 때문에 ClassInstanceCreationNode로 통합될 예정
class ArrayCreationExpressionNode : public ExpressionNode {
public:
    std::string typeName;
    std::vector<std::shared_ptr<ASTNode>> sizes;

	ArrayCreationExpressionNode() {}
    ArrayCreationExpressionNode(const std::string& typeName, const std::vector<std::shared_ptr<ASTNode>>& sizes)
        : typeName(typeName), sizes(sizes) {}

    void accept(ASTVisitor& visitor) override;
    llvm::Value* codegen() override;
    std::shared_ptr<Type> getType() override;
};

class AssignmentExpressionNode : public ASTNode {
public:
	std::shared_ptr<ASTNode> left;
	std::shared_ptr<ASTNode> right;

    AssignmentExpressionNode() {}
	AssignmentExpressionNode(std::shared_ptr<ASTNode> left, std::shared_ptr<ASTNode> right)
		: left(left), right(right) {};

    void accept(ASTVisitor& visitor) override;
    llvm::Value* codegen() override;
    std::shared_ptr<Type> getType() override;
};

class UnaryExpressionNode : public ASTNode {
public:
	std::string op;
	std::shared_ptr<ASTNode> expression;

	UnaryExpressionNode() {}
	UnaryExpressionNode(const std::string& op, std::shared_ptr<ASTNode> expression)
		: op(op), expression(expression) {}

	void accept(ASTVisitor& visitor) override;
	llvm::Value* codegen() override;
	std::shared_ptr<Type> getType() override;
};

class CastingExpressionNode : public ASTNode {
public:
	std::shared_ptr<ASTNode> expression;
	std::shared_ptr<ASTNode> type;

	CastingExpressionNode() {}
	CastingExpressionNode(std::shared_ptr<ASTNode> expression, std::shared_ptr<ASTNode> type)
		: expression(expression), type(type) {}

	void accept(ASTVisitor& visitor) override;
	llvm::Value* codegen() override;
	std::shared_ptr<Type> getType() override;
};

class PostfixExpressionNode : public ASTNode {
public:
    std::string op;
    std::shared_ptr<ASTNode> expression;

    PostfixExpressionNode() {}
    PostfixExpressionNode(const std::string& op, std::shared_ptr<ASTNode> expression)
        : op(op), expression(expression) {}

    void accept(ASTVisitor& visitor) override;
    llvm::Value* codegen() override;
    std::shared_ptr<Type> getType() override;
};

class PrefixExpressionNode : public ASTNode {
public:
    std::string op;
    std::shared_ptr<ASTNode> expression;

    PrefixExpressionNode() {}
    PrefixExpressionNode(const std::string& op, std::shared_ptr<ASTNode> expression)
        : op(op), expression(expression) {}

    void accept(ASTVisitor& visitor) override;
    llvm::Value* codegen() override;
    std::shared_ptr<Type> getType() override;
};

class FunctionCallNode : public ASTNode {
public:
    std::string functionName;
    std::vector<std::shared_ptr<ASTNode>> arguments;

    void accept(ASTVisitor& visitor) override;
    llvm::Value* codegen() override;
    std::shared_ptr<Type> getType() override;
};

class ArrayCreationNode : public ASTNode {
public:
    std::shared_ptr<GenericType> arrayType;
    std::vector<std::shared_ptr<ASTNode>> elements;

    void accept(ASTVisitor& visitor) override;
    llvm::Value* codegen() override;
    std::shared_ptr<Type> getType() override {
        return arrayType;
    }
};

class ArrayAccessNode : public ASTNode {
public:
    std::shared_ptr<ASTNode> array;
    std::shared_ptr<ASTNode> index;

    void accept(ASTVisitor& visitor) override;
    llvm::Value* codegen() override;
    std::shared_ptr<Type> getType() override {
        // 배열의 요소 타입 반환
        auto arrayType = std::dynamic_pointer_cast<GenericType>(array->getType());
        if (arrayType && arrayType->typeArguments.size() == 1) {
            return arrayType->typeArguments[0];
        }
        else {
            return std::make_shared<UnknownType>();
        }
    }
};

class AccessFieldNode : public ASTNode {
public:
    std::shared_ptr<ASTNode> base;
    std::shared_ptr<ASTNode> field;

    AccessFieldNode(std::shared_ptr<ASTNode> left, std::shared_ptr<ASTNode> right)
        : base(left), field(right) {}

    void accept(ASTVisitor& visitor) override;
    llvm::Value* codegen() override;
    std::shared_ptr<Type> getType() override;
};

// ASTVisitor Ŭ���� ����
class ASTVisitor {
public:
    virtual void visit(ProgramNode& node) = 0;

    virtual void visit(ImportNode& node) = 0;
    virtual void visit(ClassDeclarationNode& node) = 0;
    virtual void visit(ObjectDeclarationNode& node) = 0;
    virtual void visit(FunctionDeclarationNode& node) = 0;

    virtual void visit(ParameterNode& node) = 0;
    virtual void visit(BlockNode& node) = 0;
    virtual void visit(ExpressionNode& node) = 0;

    // ���ο� �湮 �Լ���
    virtual void visit(VariableDeclarationNode& node) = 0;
	virtual void visit(CallExpressionNode& node) = 0;
	virtual void visit(MethodCallNode& node) = 0;
    virtual void visit(IfStatementNode& node) = 0;
    virtual void visit(ForStatementNode& node) = 0;
    virtual void visit(MatchExpressionNode& node) = 0;
	virtual void visit(RangeExpressionNode& node) = 0;
	virtual void visit(BinaryExpressionNode& node) = 0;
	virtual void visit(AssignmentNode& node) = 0;
	virtual void visit(ClassBodyNode& node) = 0;
	virtual void visit(ReturnStatementNode& node) = 0;
    virtual void visit(ClassInstanceCreationNode& node) = 0;
	virtual void visit(ArrayCreationExpressionNode& node) = 0;
	virtual void visit(AssignmentExpressionNode& node) = 0;
	virtual void visit(UnaryExpressionNode& node) = 0;
	virtual void visit(CastingExpressionNode& node) = 0;
	virtual void visit(PostfixExpressionNode& node) = 0;
	virtual void visit(PrefixExpressionNode& node) = 0;

    virtual void visit(UnitNode& node) = 0;
    virtual void visit(IdentifierNode& node) = 0;
	virtual void visit(ValueNode& node) = 0;
	virtual void visit(FunctionCallNode& node) = 0;
	virtual void visit(ArrayCreationNode& node) = 0;
	virtual void visit(ArrayAccessNode& node) = 0;
	virtual void visit(AccessFieldNode& node) = 0;
};


