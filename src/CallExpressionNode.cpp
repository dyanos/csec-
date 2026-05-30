#include "codegen.h"
#include "CallExpressionNode.h"
#include "ASTVisitor.h"
#include "IdentifierNode.h"

#include <iostream>

void CallExpressionNode::accept(ASTVisitor& visitor) {
	visitor.visit(*this);
}

llvm::Value* CallExpressionNode::codegen() {
	if (!callee) {
		std::cerr << "Error: Missing callee in call expression" << std::endl;
		return nullptr;
	}

	std::string name;
	if (auto* id = dynamic_cast<IdentifierNode*>(callee.get())) {
		name = id->value;
	}
	else {
		llvm::Value* calleeValue = callee->codegen();
		if (!calleeValue) {
			return nullptr;
		}
		name = calleeValue->getName().str();
	}

	llvm::Function* function = CodeGenerator::getInstance().module->getFunction(name);
	if (!function) {
		std::cerr << "Function not found: " << name << std::endl;
		return nullptr;
	}

	std::vector<llvm::Value*> args;
	for (auto& arg : arguments) {
		llvm::Value* argValue = arg->codegen();
		if (!argValue) {
			return nullptr;
		}
		args.push_back(argValue);
	}

	if (!function->isVarArg() && args.size() != function->arg_size()) {
		std::cerr << "Error: argument count mismatch for '" << name << "'" << std::endl;
		return nullptr;
	}

	return CodeGenerator::getInstance().builder.CreateCall(function, args, function->getReturnType()->isVoidTy() ? "" : "calltmp");
}

std::unique_ptr<Type> CallExpressionNode::getType() {
	if (type) return type->clone();
	if (!callee) return std::make_unique<UnknownType>();

	// Try to get return type from callee's FunctionType in symbol table
	auto calleeType = callee->getType();
	if (calleeType && calleeType->getKind() == Type::Kind::FUNCTION) {
		auto* funcType = static_cast<FunctionType*>(calleeType.get());
		if (funcType->returnType) {
			return funcType->returnType->clone();
		}
	}

	// Fallback: look up LLVM function and map return type
	std::string name;
	if (auto* id = dynamic_cast<IdentifierNode*>(callee.get())) {
		name = id->value;
	}
	else {
		std::cerr << "Error: Unsupported callee in call expression type resolution" << std::endl;
		return std::make_unique<UnknownType>();
	}

	llvm::Function* function = CodeGenerator::getInstance().module->getFunction(name);
	if (!function) {
		std::cerr << "Function not found: " << name << std::endl;
		return std::make_unique<UnknownType>();
	}

	llvm::Type* retType = function->getReturnType();

	if (retType->isIntegerTy(32)) return std::make_unique<BasicType>("Int");
	if (retType->isIntegerTy(64)) return std::make_unique<BasicType>("Long");
	if (retType->isIntegerTy(16)) return std::make_unique<BasicType>("Short");
	if (retType->isIntegerTy(8)) return std::make_unique<BasicType>("Byte");
	if (retType->isIntegerTy(1)) return std::make_unique<BasicType>("Boolean");
	if (retType->isFloatTy()) return std::make_unique<BasicType>("Float");
	if (retType->isDoubleTy()) return std::make_unique<BasicType>("Double");
	if (retType->isVoidTy()) return std::make_unique<BasicType>("Unit");

	return std::make_unique<UnknownType>();
}
