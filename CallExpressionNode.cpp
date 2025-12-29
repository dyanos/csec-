#include "CallExpressionNode.h"
#include "ASTVisitor.h"

#include <iostream>

void CallExpressionNode::accept(ASTVisitor& visitor) {
	visitor.visit(*this);
}

llvm::Value* CallExpressionNode::codegen() {
	auto name = callee->codegen()->getName();
	//std::cout << "name: " << name.str() << std::endl;
	llvm::Function* function = codeGenerator->module->getFunction(name);
	if (!function) {
		std::cerr << "Function not found: " << name.str() << std::endl;
		return nullptr;
	}

	std::vector<llvm::Value*> args;
	for (auto& arg : arguments) {
		args.push_back(arg->codegen());
	}

	return codeGenerator->builder.CreateCall(function, args, "calltmp");
}

std::shared_ptr<Type> CallExpressionNode::getType() {
	if (type) return type;

	auto name = callee->codegen()->getName();
	llvm::Function* function = codeGenerator->module->getFunction(name);
	if (!function) {
		std::cerr << "Function not found: " << name.str() << std::endl;
		type = std::make_shared<UnknownType>();
		return type;
	}

	//llvm::Type* returnType = function->getReturnType();
	//type = codeGenerator->getLLVMType(returnType);

	return std::make_shared<BasicType>("");
}