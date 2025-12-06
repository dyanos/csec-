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


enum class ASTNodeType {
    PROGRAM,
    IMPORT,
    OBJECT_DECLARATION,
    CLASS_DECLARATION,
    FUNCTION_DECLARATION,
    PARAMETER,
    BLOCK,
    EXPRESSION,
    VARIABLE_DECLARATION,
    CALL_EXPRESSION,
    METHOD_CALL,
    CLASS_INSTANCE_CREATION,
    ARRAY_CREATION_EXPRESSION,
    ASSIGNMENT_EXPRESSION,
    UNARY_EXPRESSION,
    CASTING_EXPRESSION,
    POSTFIX_EXPRESSION,
    PREFIX_EXPRESSION,
    FUNCTION_CALL,
    ARRAY_CREATION,
    ARRAY_ACCESS,
    ACCESS_FIELD,
    IF_STATEMENT,
    FOR_STATEMENT,
    MATCH_EXPRESSION,
    RANGE_EXPRESSION,
    BINARY_EXPRESSION,
    RETURN_STATEMENT,
    UNIT,
    IDENTIFIER,
    VALUE,
    ASSIGNMENT,
    CLASS_BODY
};

//
class ASTVisitor;
class CodeGenerator;

class ASTNode {
public:
    ASTNodeType nodeType;
    static CodeGenerator* codeGenerator;
    std::shared_ptr<Type> type;

    virtual ~ASTNode() = default;
    virtual void accept(ASTVisitor& visitor) = 0;
    virtual llvm::Value* codegen() = 0;
    virtual std::shared_ptr<Type> getType() = 0;
};

class ProgramNode : public ASTNode {
public:
    ProgramNode() {
        nodeType = ASTNodeType::PROGRAM;
    }

    std::vector<std::shared_ptr<ASTNode>> statements;

    void accept(ASTVisitor& visitor) override;
    llvm::Value* codegen() override;
	std::shared_ptr<Type> getType() override {
		return nullptr;
	}
};

class ImportNode : public ASTNode {
public:
    ImportNode() {
        nodeType = ASTNodeType::IMPORT;
    }

    std::vector<std::string> path;

    void accept(ASTVisitor& visitor) override;
    llvm::Value* codegen() override;

    std::shared_ptr<Type> getType() override {
        return nullptr;
    }
};

class ObjectDeclarationNode : public ASTNode {
public:
    ObjectDeclarationNode() {
        nodeType = ASTNodeType::OBJECT_DECLARATION;
    }

    std::string name;
    std::shared_ptr<ASTNode> body;

    void accept(ASTVisitor& visitor) override;
    llvm::Value* codegen() override;
    std::shared_ptr<Type> getType() override {
        return nullptr;
    }
};

class ClassBodyNode;

class ParameterNode : public ASTNode {
public:
    ParameterNode() {
        nodeType = ASTNodeType::PARAMETER;
    }

    std::string name;
    std::shared_ptr<Type> type;

    void accept(ASTVisitor& visitor) override;

    llvm::Value* codegen() override;

    std::shared_ptr<Type> getType() override {
        return type;
    }
};

class FunctionDeclarationNode : public ASTNode {
public:
    FunctionDeclarationNode() {
        nodeType = ASTNodeType::FUNCTION_DECLARATION;
    }

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

class ClassDeclarationNode : public ASTNode {
public:
    ClassDeclarationNode() {
        nodeType = ASTNodeType::CLASS_DECLARATION;
    }

    std::string name;
    std::vector<std::shared_ptr<ParameterNode>> constructorParams;
    std::string superClassName;
    std::shared_ptr<ClassBodyNode> body;

    void accept(ASTVisitor& visitor) override;
    llvm::Value* codegen() override;

    void declareMethod(FunctionDeclarationNode *method, ClassSymbol *classSymbol);

    std::shared_ptr<Type> getType() override {
        return nullptr;
    }
};

class BlockNode : public ASTNode {
public:
    BlockNode() {
        nodeType = ASTNodeType::BLOCK;
    }

    std::vector<std::shared_ptr<ASTNode>> statements;

    void accept(ASTVisitor& visitor) override;

    llvm::Value* codegen() override;

    std::shared_ptr<Type> getType() override {
        return nullptr;
    }
};

class ExpressionNode : public ASTNode {
public:
    ExpressionNode() {
        nodeType = ASTNodeType::EXPRESSION;
    }

    std::string value;

    void accept(ASTVisitor& visitor) override;

    llvm::Value* codegen() override;
    std::shared_ptr<Type> getType() override;
};

class VariableDeclarationNode : public ASTNode {
public:
    VariableDeclarationNode() {
        nodeType = ASTNodeType::VARIABLE_DECLARATION;
    }

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
    ClassBodyNode() {
        nodeType = ASTNodeType::CLASS_BODY;
    }

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
    IfStatementNode() {
        nodeType = ASTNodeType::IF_STATEMENT;
    }

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
    ForStatementNode() {
        nodeType = ASTNodeType::FOR_STATEMENT;
    }

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
    MatchExpressionNode() {
        nodeType = ASTNodeType::MATCH_EXPRESSION;
    }

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
    RangeExpressionNode() {
        nodeType = ASTNodeType::RANGE_EXPRESSION;
    }

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
    BinaryExpressionNode() {
        nodeType = ASTNodeType::BINARY_EXPRESSION;
    }

    std::shared_ptr<ASTNode> left;
    std::string op;
    std::shared_ptr<ASTNode> right;

    void accept(ASTVisitor& visitor) override;
    llvm::Value* codegen() override;
    std::shared_ptr<Type> getType() override;
};

class AssignmentNode : public ASTNode {
public:
    AssignmentNode() {
        nodeType = ASTNodeType::ASSIGNMENT;
    }

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
    ReturnStatementNode() {
        nodeType = ASTNodeType::RETURN_STATEMENT;
    }

    std::shared_ptr<ASTNode> expression;

    void accept(ASTVisitor& visitor) override;
    llvm::Value* codegen() override;

    std::shared_ptr<Type> getType() override {
        return nullptr;
    }
};

class UnitNode : public ASTNode {
public:
    UnitNode() {
        nodeType = ASTNodeType::UNIT;
    }

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
    IdentifierNode(const std::string& value) : value(value) {
        nodeType = ASTNodeType::IDENTIFIER;
    }

	std::string value;

	void accept(ASTVisitor& visitor) override;
	llvm::Value* codegen() override;
	std::shared_ptr<Type> getType() override;
};

enum class ValueType {
	NONE, INT, FLOAT, STRING
};

class ValueNode : public ASTNode {
public:
    ValueNode() {
        nodeType = ASTNodeType::VALUE;
    }

	std::string value;
	TokenType valueType = TokenType::UNKNOWN;

    ValueNode(const std::string& value, TokenType type) : value(value), valueType(type) {}

	void accept(ASTVisitor& visitor) override;
	llvm::Value* codegen() override;
	std::shared_ptr<Type> getType() override;
};

class CallExpressionNode : public ASTNode {
public:
    CallExpressionNode() {
        nodeType = ASTNodeType::CALL_EXPRESSION;
    }

	std::shared_ptr<ASTNode> callee;
	std::vector<std::shared_ptr<ASTNode>> arguments;

	void accept(ASTVisitor& visitor) override;
	llvm::Value* codegen() override;
	std::shared_ptr<Type> getType() override;
};

class MethodCallNode : public ASTNode {
public:
    MethodCallNode() {
        nodeType = ASTNodeType::METHOD_CALL;
    }

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

	ClassInstanceCreationNode() {
        nodeType = ASTNodeType::CLASS_INSTANCE_CREATION;
    }
    ClassInstanceCreationNode(const std::string& className, std::vector<std::shared_ptr<ASTNode>> arguments)
        : className(className), arguments(arguments) {
        nodeType = ASTNodeType::CLASS_INSTANCE_CREATION;
    }

    void accept(ASTVisitor& visitor) override;
    llvm::Value* codegen() override;
    std::shared_ptr<Type> getType() override;
};

// TODO: 나중에 이 노드는 new operator 사용법 때문에 ClassInstanceCreationNode로 통합될 예정
class ArrayCreationExpressionNode : public ExpressionNode {
public:
    std::string typeName;
    std::vector<std::shared_ptr<ASTNode>> sizes;

	ArrayCreationExpressionNode() {
        nodeType = ASTNodeType::ARRAY_CREATION_EXPRESSION;
    }
    ArrayCreationExpressionNode(const std::string& typeName, const std::vector<std::shared_ptr<ASTNode>>& sizes)
        : typeName(typeName), sizes(sizes) {
        nodeType = ASTNodeType::ARRAY_CREATION_EXPRESSION;
    }

    void accept(ASTVisitor& visitor) override;
    llvm::Value* codegen() override;
    std::shared_ptr<Type> getType() override;
};

class AssignmentExpressionNode : public ASTNode {
public:
	std::shared_ptr<ASTNode> left;
	std::shared_ptr<ASTNode> right;

    AssignmentExpressionNode() {
        nodeType = ASTNodeType::ASSIGNMENT_EXPRESSION;
    }
	AssignmentExpressionNode(std::shared_ptr<ASTNode> left, std::shared_ptr<ASTNode> right)
		: left(left), right(right) {
        nodeType = ASTNodeType::ASSIGNMENT_EXPRESSION;
    }

    void accept(ASTVisitor& visitor) override;
    llvm::Value* codegen() override;
    std::shared_ptr<Type> getType() override;
};

class UnaryExpressionNode : public ASTNode {
public:
	std::string op;
	std::shared_ptr<ASTNode> expression;

	UnaryExpressionNode() {
        nodeType = ASTNodeType::UNARY_EXPRESSION;
    }
	UnaryExpressionNode(const std::string& op, std::shared_ptr<ASTNode> expression)
		: op(op), expression(expression) {
        nodeType = ASTNodeType::UNARY_EXPRESSION;
    }

	void accept(ASTVisitor& visitor) override;
	llvm::Value* codegen() override;
	std::shared_ptr<Type> getType() override;
};

class CastingExpressionNode : public ASTNode {
public:
	std::shared_ptr<ASTNode> expression;
	std::shared_ptr<ASTNode> type;

    CastingExpressionNode() {
        nodeType = ASTNodeType::CASTING_EXPRESSION;
    }
	CastingExpressionNode(std::shared_ptr<ASTNode> expression, std::shared_ptr<ASTNode> type)
		: expression(expression), type(type) {
        nodeType = ASTNodeType::CASTING_EXPRESSION;
    }

	void accept(ASTVisitor& visitor) override;
	llvm::Value* codegen() override;
	std::shared_ptr<Type> getType() override;
};

class PostfixExpressionNode : public ASTNode {
public:
    std::string op;
    std::shared_ptr<ASTNode> expression;

    PostfixExpressionNode() {
        nodeType = ASTNodeType::POSTFIX_EXPRESSION;
    }
    PostfixExpressionNode(const std::string& op, std::shared_ptr<ASTNode> expression)
        : op(op), expression(expression) {
        nodeType = ASTNodeType::POSTFIX_EXPRESSION;
    }

    void accept(ASTVisitor& visitor) override;
    llvm::Value* codegen() override;
    std::shared_ptr<Type> getType() override;
};

class PrefixExpressionNode : public ASTNode {
public:
    std::string op;
    std::shared_ptr<ASTNode> expression;

    PrefixExpressionNode() {
        nodeType = ASTNodeType::PREFIX_EXPRESSION;
    }
    PrefixExpressionNode(const std::string& op, std::shared_ptr<ASTNode> expression)
        : op(op), expression(expression) {
        nodeType = ASTNodeType::PREFIX_EXPRESSION;
    }

    void accept(ASTVisitor& visitor) override;
    llvm::Value* codegen() override;
    std::shared_ptr<Type> getType() override;
};

class FunctionCallNode : public ASTNode {
public:
    FunctionCallNode() {
        nodeType = ASTNodeType::FUNCTION_CALL;
    }

    std::string functionName;
    std::vector<std::shared_ptr<ASTNode>> arguments;

    void accept(ASTVisitor& visitor) override;
    llvm::Value* codegen() override;
    std::shared_ptr<Type> getType() override;
};

class ArrayCreationNode : public ASTNode {
public:
    ArrayCreationNode() {
        nodeType = ASTNodeType::ARRAY_CREATION;
    }

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
    ArrayAccessNode() {
        nodeType = ASTNodeType::ARRAY_ACCESS;
    }

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

    AccessFieldNode() {
        nodeType = ASTNodeType::ACCESS_FIELD;
	}
    AccessFieldNode(std::shared_ptr<ASTNode> base, std::shared_ptr<ASTNode> field)
        : base(base), field(field) {
        nodeType = ASTNodeType::ACCESS_FIELD;
	}

    void accept(ASTVisitor& visitor) override;
    llvm::Value* codegen() override;
    std::shared_ptr<Type> getType() override;

    int findFieldIndex(ClassSymbol* classSymbol, const std::string& fieldName);
};

// ASTVisitor Ŭ
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

    // 오브젝트 멤버 변수 방문
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


