#include "codegen.h"
#include "LambdaExpressionNode.h"
#include "ASTVisitor.h"
#include "ParameterNode.h"
#include "IdentifierNode.h"
#include "BinaryExpressionNode.h"
#include "UnaryExpressionNode.h"
#include "ReturnStatementNode.h"
#include "BlockNode.h"
#include "IfStatementNode.h"
#include "WhileStatementNode.h"
#include "CallExpressionNode.h"
#include "FunctionCallNode.h"
#include "AssignmentExpressionNode.h"
#include "AccessFieldNode.h"
#include "ArrayAccessNode.h"

#include <iostream>
#include <set>
#include <llvm/IR/Function.h>
#include <llvm/IR/Constants.h>

namespace {
std::unique_ptr<Type> usableLambdaType(std::unique_ptr<Type> type) {
    if (!type || type->getKind() == Type::Kind::UNKNOWN) {
        return std::make_unique<BasicType>("Int");
    }
    return type;
}

// Collect the identifier names referenced anywhere in a lambda body. Used to detect free
// variables (captures). Handles the expression and statement nodes that appear in lambda bodies;
// an unrecognized node contributes nothing, which can only under-report a capture.
void collectReferencedIdentifiers(ASTNode* node, std::set<std::string>& names) {
    if (!node) return;
    if (auto* ident = dynamic_cast<IdentifierNode*>(node)) {
        names.insert(ident->value);
    } else if (auto* binary = dynamic_cast<BinaryExpressionNode*>(node)) {
        collectReferencedIdentifiers(binary->left.get(), names);
        collectReferencedIdentifiers(binary->right.get(), names);
    } else if (auto* unary = dynamic_cast<UnaryExpressionNode*>(node)) {
        collectReferencedIdentifiers(unary->expression.get(), names);
    } else if (auto* ret = dynamic_cast<ReturnStatementNode*>(node)) {
        collectReferencedIdentifiers(ret->expression.get(), names);
    } else if (auto* block = dynamic_cast<BlockNode*>(node)) {
        for (auto& stmt : block->statements) collectReferencedIdentifiers(stmt.get(), names);
    } else if (auto* ifStmt = dynamic_cast<IfStatementNode*>(node)) {
        collectReferencedIdentifiers(ifStmt->condition.get(), names);
        collectReferencedIdentifiers(ifStmt->thenBlock.get(), names);
        collectReferencedIdentifiers(ifStmt->elseBlock.get(), names);
    } else if (auto* whileStmt = dynamic_cast<WhileStatementNode*>(node)) {
        collectReferencedIdentifiers(whileStmt->condition.get(), names);
        collectReferencedIdentifiers(whileStmt->body.get(), names);
    } else if (auto* call = dynamic_cast<CallExpressionNode*>(node)) {
        collectReferencedIdentifiers(call->callee.get(), names);
        for (auto& arg : call->arguments) collectReferencedIdentifiers(arg.get(), names);
    } else if (auto* fcall = dynamic_cast<FunctionCallNode*>(node)) {
        for (auto& arg : fcall->arguments) collectReferencedIdentifiers(arg.get(), names);
    } else if (auto* assign = dynamic_cast<AssignmentExpressionNode*>(node)) {
        collectReferencedIdentifiers(assign->left.get(), names);
        collectReferencedIdentifiers(assign->right.get(), names);
    } else if (auto* access = dynamic_cast<AccessFieldNode*>(node)) {
        collectReferencedIdentifiers(access->base.get(), names);
    } else if (auto* arr = dynamic_cast<ArrayAccessNode*>(node)) {
        collectReferencedIdentifiers(arr->array.get(), names);
        collectReferencedIdentifiers(arr->index.get(), names);
    }
}

llvm::Value* defaultReturnValue(llvm::Type* type) {
    auto& cg = CodeGenerator::getInstance();
    if (!type || type->isVoidTy()) {
        return nullptr;
    }
    if (type->isIntegerTy()) {
        return llvm::ConstantInt::get(type, 0, true);
    }
    if (type->isFloatingPointTy()) {
        return llvm::ConstantFP::get(type, 0.0);
    }
    if (type->isPointerTy()) {
        return llvm::ConstantPointerNull::get(llvm::cast<llvm::PointerType>(type));
    }
    return llvm::Constant::getNullValue(type);
}
}

void LambdaExpressionNode::accept(ASTVisitor& visitor) {
    visitor.visit(*this);
}

llvm::Value* LambdaExpressionNode::codegen() {
    auto& cg = CodeGenerator::getInstance();
    std::vector<llvm::Type*> paramTypes;

    // Add regular arguments
    for (auto& arg : arguments) {
        auto paramType = usableLambdaType(arg ? arg->getType() : nullptr);
        auto* argType = cg.getLLVMType(paramType.get());
        if (!argType) {
            std::cerr << "Error: Invalid lambda parameter type" << std::endl;
            return nullptr;
        }
        paramTypes.push_back(argType);
    }

    // Determine return type
    auto bodyType = usableLambdaType(body ? body->getType() : nullptr);
    llvm::Type* returnType = bodyType ? cg.getLLVMType(bodyType.get()) : nullptr;
    if (!returnType) returnType = llvm::Type::getInt32Ty(cg.context);

    // Create anonymous function
    llvm::FunctionType* funcType = llvm::FunctionType::get(returnType, paramTypes, false);

    static int lambdaCount = 0;
    std::string lambdaName = "__lambda_" + std::to_string(lambdaCount++);

    llvm::Function* lambdaFunc = llvm::Function::Create(
        funcType, llvm::Function::InternalLinkage, lambdaName, cg.module.get());

    // Save current insert point
    llvm::BasicBlock* savedBB = cg.builder.GetInsertBlock();

    // Create entry block
    llvm::BasicBlock* entry = llvm::BasicBlock::Create(cg.context, "entry", lambdaFunc);
    cg.builder.SetInsertPoint(entry);

    cg.symbolTable.enterScope();

    int argIdx = 0;
    // Bind arguments
    for (size_t i = 0; i < arguments.size(); ++i) {
        auto* paramNode = static_cast<ParameterNode*>(arguments[i].get());
        auto paramType = usableLambdaType(arguments[i] ? arguments[i]->getType() : nullptr);
        cg.symbolTable.addSymbol(paramNode->name, std::make_unique<Symbol>(
            paramNode->name, std::move(paramType), lambdaFunc->getArg(argIdx), false, SymbolType::VARIABLE));
        argIdx++;
    }

    // The direct compiler represents a lambda as a bare function pointer with no closure
    // environment, so it cannot capture outer variables. Detect a body that references an outer
    // variable (or an explicit/by-reference capture) and fail with a clear error instead of
    // emitting a function that refers to another frame's allocas (invalid IR that hangs the
    // verifier). The self-host path implements closures and handles these.
    {
        std::set<std::string> paramNames;
        for (auto& arg : arguments) {
            if (auto* paramNode = dynamic_cast<ParameterNode*>(arg.get())) {
                paramNames.insert(paramNode->name);
            }
        }
        std::set<std::string> referenced;
        collectReferencedIdentifiers(body.get(), referenced);
        bool capturesOuter = capturesByReference || !captureVariables.empty();
        for (const auto& referencedName : referenced) {
            if (paramNames.count(referencedName)) continue;
            auto* symbol = cg.symbolTable.lookup(referencedName);
            if (symbol && (symbol->symbolType == SymbolType::VARIABLE || symbol->symbolType == SymbolType::FIELD)) {
                capturesOuter = true;
                break;
            }
        }
        if (capturesOuter) {
            std::cerr << "Error: capturing lambdas are not supported by the direct compiler; "
                         "compile through the self-host path" << std::endl;
            cg.symbolTable.exitScope();
            cg.builder.SetInsertPoint(savedBB);
            lambdaFunc->eraseFromParent();
            return nullptr;
        }
    }

    // Generate body
    llvm::Value* bodyValue = nullptr;
    if (captureVariables.empty()) {
        bodyValue = body->codegen();
    }

    // Add return if block has no terminator
    if (!cg.builder.GetInsertBlock()->getTerminator()) {
        if (bodyValue && !returnType->isVoidTy()) {
            cg.builder.CreateRet(bodyValue);
        }
        else if (!returnType->isVoidTy()) {
            cg.builder.CreateRet(defaultReturnValue(returnType));
        }
        else {
            cg.builder.CreateRetVoid();
        }
    }

    cg.symbolTable.exitScope();

    // Restore insert point
    cg.builder.SetInsertPoint(savedBB);

    return lambdaFunc;
}
