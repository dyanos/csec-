#include "codegen.h"
#include "CastingExpressionNode.h"
#include "ASTVisitor.h"

#include <iostream>

void CastingExpressionNode::accept(ASTVisitor& visitor) {
    visitor.visit(*this);
}

llvm::Value* CastingExpressionNode::codegen() {
    if (!expression || !typeNode) return nullptr;
    auto& cg = CodeGenerator::getInstance();
    llvm::Value* exprValue = expression->codegen();
    if (!exprValue) return nullptr;

    auto srcType = expression->getType();
    auto dstType = typeNode->getType();
    if (!srcType || !dstType) return nullptr;

    llvm::Type* sourceLLVMType = cg.getLLVMType(srcType.get());
    if (exprValue->getType()->isPointerTy() && sourceLLVMType) {
        exprValue = cg.builder.CreateLoad(sourceLLVMType, exprValue, "cast_load");
    }

    llvm::Type* targetLLVMType = cg.getLLVMType(dstType.get());
    if (!targetLLVMType) return nullptr;

    // Same type, no cast needed
    if (exprValue->getType() == targetLLVMType) return exprValue;

    bool srcIsInt = srcType->isIntegerTy();
    bool srcIsFloat = srcType->isFloatTy();
    bool srcIsDouble = srcType->isDoubleTy();
    bool dstIsInt = dstType->isIntegerTy();
    bool dstIsFloat = dstType->isFloatTy();
    bool dstIsDouble = dstType->isDoubleTy();

    // Int -> Float/Double
    if (srcIsInt && (dstIsFloat || dstIsDouble)) {
        if (!exprValue->getType()->isIntegerTy()) return nullptr;
        return cg.builder.CreateSIToFP(exprValue, targetLLVMType, "sitofp");
    }
    // Float/Double -> Int
    if ((srcIsFloat || srcIsDouble) && dstIsInt) {
        if (!exprValue->getType()->isFloatingPointTy()) return nullptr;
        return cg.builder.CreateFPToSI(exprValue, targetLLVMType, "fptosi");
    }
    // Float -> Double
    if (srcIsFloat && dstIsDouble) {
        return cg.builder.CreateFPExt(exprValue, targetLLVMType, "fpext");
    }
    // Double -> Float
    if (srcIsDouble && dstIsFloat) {
        return cg.builder.CreateFPTrunc(exprValue, targetLLVMType, "fptrunc");
    }
    // Int size conversion (e.g. Int -> Long, Long -> Short)
    if (srcIsInt && dstIsInt) {
        unsigned srcBits = exprValue->getType()->getIntegerBitWidth();
        unsigned dstBits = targetLLVMType->getIntegerBitWidth();
        if (srcBits < dstBits) {
            return cg.builder.CreateSExt(exprValue, targetLLVMType, "sext");
        }
        else {
            return cg.builder.CreateTrunc(exprValue, targetLLVMType, "trunc");
        }
    }

    std::cerr << "Error: Unsupported cast from '" << srcType->getName() << "' to '" << dstType->getName() << "'" << std::endl;
    return nullptr;
}

std::unique_ptr<Type> CastingExpressionNode::getType() {
    if (typeNode) return typeNode->getType();
    return std::make_unique<UnknownType>();
}
