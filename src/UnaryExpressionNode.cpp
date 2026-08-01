#include "codegen.h"

#include "UnaryExpressionNode.h"
#include "ASTVisitor.h"

#include <iostream>

#include <llvm/IR/Constants.h>


void UnaryExpressionNode::accept(ASTVisitor& visitor)
{
	visitor.visit(*this);
}

llvm::Value* UnaryExpressionNode::codegen()
{
	llvm::Value* value = expression->codegen();
	if (!value) {
		std::cerr << "Error: Unary expression failed" << std::endl;
		return nullptr;
	}

	if (op == "-") {
		// Floating-point values need FP negation; CreateNeg is integer-only and asserts on a
		// double/float operand (e.g. the literal `-1.0`).
		if (value->getType()->isFloatingPointTy()) {
			return CodeGenerator::getInstance().builder.CreateFNeg(value, "fnegtmp");
		}
		return CodeGenerator::getInstance().builder.CreateNeg(value, "negtmp");
	}
	else if (op == "+") {
		return value;
	}
	else if (op == "!") {
		return CodeGenerator::getInstance().builder.CreateNot(value, "nottmp");
	}
	else if (op == "~") {
		// bitwise not
		return CodeGenerator::getInstance().builder.CreateNot(value, "bnottmp");
	}
	else if (op == "*") {
		if (!value->getType()->isPointerTy()) {
			std::cerr << "Error: Cannot dereference non-pointer value" << std::endl;
			return nullptr;
		}
		auto resultType = getType();
		auto* llvmResultType = CodeGenerator::getInstance().getLLVMType(resultType.get());
		if (!llvmResultType) {
			std::cerr << "Error: Unsupported raw pointer dereference type" << std::endl;
			return nullptr;
		}
		return CodeGenerator::getInstance().builder.CreateLoad(llvmResultType, value, "deref");
	}
	else if (op == "++") {
		// increment
		// byte, char, word, short, int, long, long long, float, double, long double만 가능하도록 변경
		if (value->getType()->isIntegerTy(1)) { // byte
			return CodeGenerator::getInstance().builder.CreateAdd(value, llvm::ConstantInt::get(CodeGenerator::getInstance().context, llvm::APInt(1, 1)), "inc");
		}
		else if (value->getType()->isIntegerTy(8)) { // char
			return CodeGenerator::getInstance().builder.CreateAdd(value, llvm::ConstantInt::get(CodeGenerator::getInstance().context, llvm::APInt(8, 1)), "inc");
		}
		else if (value->getType()->isIntegerTy(16)) { // word, short
			return CodeGenerator::getInstance().builder.CreateAdd(value, llvm::ConstantInt::get(CodeGenerator::getInstance().context, llvm::APInt(16, 1)), "inc");
		}
		else if (value->getType()->isIntegerTy(32)) { // int
			return CodeGenerator::getInstance().builder.CreateAdd(value, llvm::ConstantInt::get(CodeGenerator::getInstance().context, llvm::APInt(32, 1)), "inc");
		}
		else if (value->getType()->isIntegerTy(64)) { // long, long long
			return CodeGenerator::getInstance().builder.CreateAdd(value, llvm::ConstantInt::get(CodeGenerator::getInstance().context, llvm::APInt(64, 1)), "inc");
		}
		else if (value->getType()->isFloatTy()) { // float
			return CodeGenerator::getInstance().builder.CreateFAdd(value, llvm::ConstantFP::get(CodeGenerator::getInstance().context, llvm::APFloat(1.0)), "inc");
		}
		else if (value->getType()->isDoubleTy()) { // double
			return CodeGenerator::getInstance().builder.CreateFAdd(value, llvm::ConstantFP::get(CodeGenerator::getInstance().context, llvm::APFloat(1.0)), "inc");
		}
		else {
			std::cerr << "Error: Increment operator not applicable to type" << std::endl;
			return nullptr;
		}
	}
	else if (op == "--") {
		// decrement
		// byte, char, word, short, int, long, long long, float, double, long double만 가능하도록 변경
		if (value->getType()->isIntegerTy(1)) { // byte

			return CodeGenerator::getInstance().builder.CreateSub(value, llvm::ConstantInt::get(CodeGenerator::getInstance().context, llvm::APInt(1, 1)), "dec");
		}
		else if (value->getType()->isIntegerTy(8)) { // char
			return CodeGenerator::getInstance().builder.CreateSub(value, llvm::ConstantInt::get(CodeGenerator::getInstance().context, llvm::APInt(8, 1)), "dec");
		}
		else if (value->getType()->isIntegerTy(16)) { // word, short
			return CodeGenerator::getInstance().builder.CreateSub(value, llvm::ConstantInt::get(CodeGenerator::getInstance().context, llvm::APInt(16, 1)), "dec");
		}
		else if (value->getType()->isIntegerTy(32)) { // int
			return CodeGenerator::getInstance().builder.CreateSub(value, llvm::ConstantInt::get(CodeGenerator::getInstance().context, llvm::APInt(32, 1)), "dec");
		}
		else if (value->getType()->isIntegerTy(64)) { // long, long long
			return CodeGenerator::getInstance().builder.CreateSub(value, llvm::ConstantInt::get(CodeGenerator::getInstance().context, llvm::APInt(64, 1)), "dec");
		}
		else if (value->getType()->isFloatTy()) { // float
			return CodeGenerator::getInstance().builder.CreateFSub(value, llvm::ConstantFP::get(CodeGenerator::getInstance().context, llvm::APFloat(1.0)), "dec");
		}
		else if (value->getType()->isDoubleTy()) { // double
			return CodeGenerator::getInstance().builder.CreateFSub(value, llvm::ConstantFP::get(CodeGenerator::getInstance().context, llvm::APFloat(1.0)), "dec");
		}
		else if (value->getType()->isStructTy()) {
			// 구조체일 경우 구조체 안에 '++' 연산자가 정의되어 있는지 확인 후 사용할 수 있다면, 사용
			auto classType = llvm::cast<llvm::StructType>(value->getType());
			auto classSymbolOpt = CodeGenerator::getInstance().symbolTable.lookupClass(classType->getName().str());

			if (classSymbolOpt) {
				auto* classSymbol = classSymbolOpt;
				auto method = classSymbol->getMethod("operator++");
				if (method) {
					// '++' 연산자 메서드 호출
					std::vector<llvm::Value*> args;
					return CodeGenerator::getInstance().builder.CreateCall(llvm::FunctionCallee(method->function), args, "inc");
				}
				else {
					std::cerr << "Error: '++' operator not defined for class " << classType->getName().str() << std::endl;
					return nullptr;
				}
			}
			else {
				std::cerr << "Error: Class symbol not found for type " << classType->getName().str() << std::endl;
				return nullptr;
			}
		}
		else {
			std::cerr << "Error: Increment operator not applicable to type" << std::endl;
			return nullptr;
		}
	}
	else {
		std::cerr << "Unsupported unary operator: " << op << std::endl;
	}

	return nullptr;
}

std::unique_ptr<Type> UnaryExpressionNode::getType() {
    auto exprType = expression ? expression->getType() : std::make_unique<UnknownType>();
    if (!exprType) {
        return std::make_unique<UnknownType>();
    }
    if (op == "!") {
        return std::make_unique<BasicType>("Boolean");
    }
    if (op == "+" || op == "-" || op == "~" || op == "++" || op == "--") {
        return exprType->clone();
    }
    if (op == "*") {
        auto unsafePointerType = dynamic_cast<UnsafePointerType*>(exprType.get());
        if (unsafePointerType && unsafePointerType->baseType) {
            return unsafePointerType->baseType->clone();
        }
    }
    return std::make_unique<UnknownType>();
}
