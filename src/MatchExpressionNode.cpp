#include "codegen.h"

#include "MatchExpressionNode.h"
#include "ASTVisitor.h"
#include "UnitNode.h"
#include "ValueNode.h"

#include <llvm/IR/Constants.h>
#include <llvm/IR/DerivedTypes.h>
#include <llvm/IR/Function.h>
#include <llvm/IR/Instructions.h>

namespace {
llvm::Function* getOrCreateStringMatchRuntime(
    CodeGenerator& cg,
    const std::string& name,
    llvm::Type* i32Ty,
    llvm::Type* i8PtrTy) {
    cg.requireSystemNative();
    if (auto* function = cg.module->getFunction(name)) {
        return function;
    }

    return llvm::Function::Create(
        llvm::FunctionType::get(i32Ty, { i8PtrTy, i8PtrTy }, false),
        llvm::Function::ExternalLinkage,
        name,
        cg.module.get());
}

llvm::Value* asCStringPointer(CodeGenerator& cg, llvm::Value* value) {
    auto* i8PtrTy = llvm::PointerType::getUnqual(llvm::Type::getInt8Ty(cg.context));
    if (!value) {
        return llvm::ConstantPointerNull::get(i8PtrTy);
    }
    if (value->getType() == i8PtrTy) {
        return value;
    }
    if (value->getType()->isPointerTy()) {
        return cg.builder.CreateBitCast(value, i8PtrTy, "match.str.ptr");
    }
    return llvm::ConstantPointerNull::get(i8PtrTy);
}
}

void MatchExpressionNode::accept(ASTVisitor& visitor) {
    visitor.visit(*this);
}

llvm::Value* MatchExpressionNode::codegen() {
    auto& cg = CodeGenerator::getInstance();

    llvm::Value* matchValue = expression ? expression->codegen() : nullptr;
    if (!matchValue) {
        return nullptr;
    }

    auto* currentBlock = cg.builder.GetInsertBlock();
    if (!currentBlock) {
        return nullptr;
    }

    llvm::Function* function = currentBlock->getParent();
    llvm::BasicBlock* mergeBB = llvm::BasicBlock::Create(cg.context, "match.end", function);

    llvm::Type* resultLLVMType = nullptr;
    if (type && type->getKind() != Type::Kind::UNKNOWN) {
        resultLLVMType = cg.getLLVMType(type.get());
    }

    llvm::PHINode* phi = nullptr;
    if (resultLLVMType && !resultLLVMType->isVoidTy()) {
        phi = llvm::PHINode::Create(resultLLVMType, static_cast<unsigned>(cases.size()), "match.result", mergeBB);
    }

    llvm::BasicBlock* nextTestBB = currentBlock;

    for (size_t i = 0; i < cases.size(); ++i) {
        auto& casePair = cases[i];
        auto* caseBB = llvm::BasicBlock::Create(cg.context, "match.case", function);
        const bool isWildcard = dynamic_cast<UnitNode*>(casePair.first.get()) != nullptr;
        llvm::BasicBlock* nextBB = (i + 1 < cases.size())
            ? llvm::BasicBlock::Create(cg.context, "match.next", function)
            : mergeBB;

        cg.builder.SetInsertPoint(nextTestBB);
        if (!cg.builder.GetInsertBlock()->getTerminator()) {
            if (isWildcard) {
                cg.builder.CreateBr(caseBB);
            }
            else {
                llvm::Value* caseValue = casePair.first ? casePair.first->codegen() : nullptr;
                if (!caseValue) {
                    return nullptr;
                }

                llvm::Value* condition = nullptr;
                auto* patternValue = dynamic_cast<ValueNode*>(casePair.first.get());
                const bool isStringPattern = patternValue &&
                    (patternValue->valueType == TokenType::STRING_LITERAL ||
                     patternValue->valueType == TokenType::REGEX_LITERAL);
                if (isStringPattern) {
                    auto* i32Ty = llvm::Type::getInt32Ty(cg.context);
                    auto* i8PtrTy = llvm::PointerType::getUnqual(llvm::Type::getInt8Ty(cg.context));
                    const char* runtimeName = patternValue->valueType == TokenType::REGEX_LITERAL
                        ? "csec_string_regex_match"
                        : "csec_string_equals";
                    llvm::Value* raw = cg.builder.CreateCall(
                        getOrCreateStringMatchRuntime(cg, runtimeName, i32Ty, i8PtrTy),
                        { asCStringPointer(cg, matchValue), asCStringPointer(cg, caseValue) },
                        "match.str.raw");
                    condition = cg.builder.CreateICmpNE(raw, llvm::ConstantInt::get(i32Ty, 0), "match.cond");
                }
                else {
                    condition = cg.builder.CreateICmpEQ(matchValue, caseValue, "match.cond");
                }
                cg.builder.CreateCondBr(condition, caseBB, nextBB);
            }
        }

        cg.builder.SetInsertPoint(caseBB);
        llvm::Value* caseResult = casePair.second ? casePair.second->codegen() : nullptr;
        if (!caseResult && phi) {
            return nullptr;
        }

        auto* finishedCaseBB = cg.builder.GetInsertBlock();
        if (!finishedCaseBB->getTerminator()) {
            if (phi) {
                phi->addIncoming(caseResult, finishedCaseBB);
            }
            cg.builder.CreateBr(mergeBB);
        }

        nextTestBB = nextBB;
    }

    cg.builder.SetInsertPoint(mergeBB);
    if (phi) {
        return phi;
    }

    return llvm::Constant::getNullValue(llvm::Type::getInt32Ty(cg.context));
}
