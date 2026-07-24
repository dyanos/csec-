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
#include "type_utils.h"

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
    auto* opaquePtr = llvm::PointerType::getUnqual(cg.context);

    // Determine the captured variables at the enclosing scope (before entering the lambda scope).
    // An explicit capture list is used verbatim; `[=]`/`[&]` capture every free variable of the
    // body that resolves to an outer local.
    std::set<std::string> paramNames;
    for (auto& arg : arguments) {
        if (auto* paramNode = dynamic_cast<ParameterNode*>(arg.get())) paramNames.insert(paramNode->name);
    }
    std::vector<std::string> capturedNames;
    {
        std::set<std::string> candidates;
        if (!captureVariables.empty()) {
            for (const auto& capture : captureVariables) candidates.insert(capture);
        } else {
            std::set<std::string> referenced;
            collectReferencedIdentifiers(body.get(), referenced);
            for (const auto& name : referenced) {
                if (paramNames.count(name)) continue;
                auto* symbol = cg.symbolTable.lookup(name);
                if (symbol && (symbol->symbolType == SymbolType::VARIABLE || symbol->symbolType == SymbolType::FIELD)) {
                    candidates.insert(name);
                }
            }
        }
        for (const auto& name : candidates) capturedNames.push_back(name);
    }

    struct Captured {
        std::string name;
        llvm::Value* outerValue;
        llvm::Type* fieldType;
        std::unique_ptr<Type> semanticType;
    };
    std::vector<Captured> captured;
    std::vector<llvm::Type*> envFieldTypes;
    for (const auto& name : capturedNames) {
        auto* symbol = cg.symbolTable.lookup(name);
        if (!symbol || !symbol->value) continue;
        llvm::Type* fieldType = capturesByReference ? opaquePtr : getABIStorageType(symbol->type.get());
        if (!fieldType) fieldType = llvm::Type::getInt32Ty(cg.context);
        Captured entry;
        entry.name = name;
        entry.outerValue = symbol->value;
        entry.fieldType = fieldType;
        entry.semanticType = symbol->type ? symbol->type->clone() : std::make_unique<UnknownType>();
        captured.push_back(std::move(entry));
        envFieldTypes.push_back(fieldType);
    }
    // Every lambda is represented uniformly as a { code, env } closure whose function takes the
    // environment pointer first, even when it captures nothing (empty environment). This gives
    // lambda values one representation, so a function-type parameter can be called the same way
    // whether or not the lambda it received captures anything.
    llvm::StructType* envType = llvm::StructType::get(cg.context, envFieldTypes);

    std::vector<llvm::Type*> paramTypes;
    paramTypes.push_back(opaquePtr);
    for (auto& arg : arguments) {
        auto paramType = usableLambdaType(arg ? arg->getType() : nullptr);
        auto* argType = cg.getLLVMType(paramType.get());
        if (!argType) {
            std::cerr << "Error: Invalid lambda parameter type" << std::endl;
            return nullptr;
        }
        paramTypes.push_back(argType);
    }

    auto bodyType = usableLambdaType(body ? body->getType() : nullptr);
    llvm::Type* returnType = bodyType ? cg.getLLVMType(bodyType.get()) : nullptr;
    if (!returnType) returnType = llvm::Type::getInt32Ty(cg.context);

    llvm::FunctionType* funcType = llvm::FunctionType::get(returnType, paramTypes, false);
    static int lambdaCount = 0;
    std::string lambdaName = "__lambda_" + std::to_string(lambdaCount++);
    llvm::Function* lambdaFunc = llvm::Function::Create(
        funcType, llvm::Function::InternalLinkage, lambdaName, cg.module.get());

    llvm::BasicBlock* savedBB = cg.builder.GetInsertBlock();
    auto savedPoint = cg.builder.GetInsertPoint();
    llvm::BasicBlock* entry = llvm::BasicBlock::Create(cg.context, "entry", lambdaFunc);
    cg.builder.SetInsertPoint(entry);
    cg.symbolTable.enterScope();

    // Bind captured variables from the environment argument.
    {
        llvm::Value* envArg = lambdaFunc->getArg(0);
        for (size_t i = 0; i < captured.size(); ++i) {
            llvm::Value* slot = cg.builder.CreateStructGEP(envType, envArg, static_cast<unsigned>(i), captured[i].name + ".cap");
            if (capturesByReference) {
                // The slot holds a pointer to the outer variable; bind the name to that storage.
                llvm::Value* storage = cg.builder.CreateLoad(opaquePtr, slot, captured[i].name + ".ref");
                cg.symbolTable.addSymbol(captured[i].name, std::make_unique<Symbol>(
                    captured[i].name, captured[i].semanticType->clone(), storage, true, SymbolType::VARIABLE));
            } else {
                // The slot holds the captured value; copy it into a local so the name is an lvalue.
                llvm::Value* localCopy = cg.builder.CreateAlloca(captured[i].fieldType, nullptr, captured[i].name);
                llvm::Value* value = cg.builder.CreateLoad(captured[i].fieldType, slot, captured[i].name + ".val");
                cg.builder.CreateStore(value, localCopy);
                cg.symbolTable.addSymbol(captured[i].name, std::make_unique<Symbol>(
                    captured[i].name, captured[i].semanticType->clone(), localCopy, false, SymbolType::VARIABLE));
            }
        }
    }

    // Bind declared parameters (after the environment argument).
    const unsigned argBase = 1u;
    for (size_t i = 0; i < arguments.size(); ++i) {
        auto* paramNode = static_cast<ParameterNode*>(arguments[i].get());
        auto paramType = usableLambdaType(arguments[i] ? arguments[i]->getType() : nullptr);
        cg.symbolTable.addSymbol(paramNode->name, std::make_unique<Symbol>(
            paramNode->name, std::move(paramType), lambdaFunc->getArg(argBase + static_cast<unsigned>(i)), false, SymbolType::VARIABLE));
    }

    llvm::Value* bodyValue = body ? body->codegen() : nullptr;
    if (!cg.builder.GetInsertBlock()->getTerminator()) {
        if (bodyValue && !returnType->isVoidTy()) cg.builder.CreateRet(bodyValue);
        else if (!returnType->isVoidTy()) cg.builder.CreateRet(defaultReturnValue(returnType));
        else cg.builder.CreateRetVoid();
    }

    cg.symbolTable.exitScope();
    cg.builder.SetInsertPoint(savedBB, savedPoint);

    // Build the { code, env } closure. Fill the environment with the captured values (by value)
    // or the outer variables' addresses (by reference); an empty environment for a lambda that
    // captures nothing.
    llvm::Value* environment = cg.builder.CreateAlloca(envType, nullptr, "lambda.env");
    for (size_t i = 0; i < captured.size(); ++i) {
        llvm::Value* slot = cg.builder.CreateStructGEP(envType, environment, static_cast<unsigned>(i), captured[i].name + ".store");
        if (capturesByReference) {
            cg.builder.CreateStore(captured[i].outerValue, slot);
        } else {
            llvm::Value* value = cg.builder.CreateLoad(captured[i].fieldType, captured[i].outerValue, captured[i].name + ".take");
            cg.builder.CreateStore(value, slot);
        }
    }
    llvm::StructType* closureType = llvm::StructType::get(cg.context, { opaquePtr, opaquePtr });
    llvm::Value* closure = cg.builder.CreateAlloca(closureType, nullptr, "lambda.closure");
    cg.builder.CreateStore(lambdaFunc, cg.builder.CreateStructGEP(closureType, closure, 0, "closure.code"));
    cg.builder.CreateStore(environment, cg.builder.CreateStructGEP(closureType, closure, 1, "closure.env"));
    return closure;
}
