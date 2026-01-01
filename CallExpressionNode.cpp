#include "codegen.h"
#include "CallExpressionNode.h"
#include "ASTVisitor.h"

#include <iostream>

void CallExpressionNode::accept(ASTVisitor& visitor) {
	visitor.visit(*this);
}

llvm::Value* CallExpressionNode::codegen() {
	auto name = callee->codegen()->getName();
	//std::cout << "name: " << name.str() << std::endl;
	llvm::Function* function = CodeGenerator::getInstance().module->getFunction(name);
	if (!function) {
		std::cerr << "Function not found: " << name.str() << std::endl;
		return nullptr;
	}

	std::vector<llvm::Value*> args;
	for (auto& arg : arguments) {
		args.push_back(arg->codegen());
	}

	return CodeGenerator::getInstance().builder.CreateCall(function, args, "calltmp");
}

std::unique_ptr<Type> CallExpressionNode::getType() {
	if (type) return std::make_unique<Type>(type.get());

	auto name = callee->codegen()->getName();
	llvm::Function* function = CodeGenerator::getInstance().module->getFunction(name);
	if (!function) {
		std::cerr << "Function not found: " << name.str() << std::endl;
		return std::make_unique<UnknownType>();
	}

	//llvm::Type* returnType = function->getReturnType();
	//type = CodeGenerator::getInstance().getLLVMType(returnType);

	return std::make_unique<BasicType>("");
}