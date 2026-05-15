#include "codegen.h"
#include "BinaryExpressionNode.h"
#include "ASTVisitor.h"

#include <iostream>


void BinaryExpressionNode::accept(ASTVisitor& visitor) {
    visitor.visit(*this);
}

/*bool isStringTypeFromLLVM(llvm::Value* value, CodeGenerator* codeGenerator) {
    return value->getType()->isPointerTy() && (static_cast<llvm::PointerType*>(value->getType()))->isValidElementType(llvm::Type::getInt8Ty(CodeGenerator::getInstance().context));
}*/

// Helper: generate Complex arithmetic
static llvm::Value* codegenComplexOp(const std::string& op, llvm::Value* leftValue, llvm::Value* rightValue) {
    auto& builder = CodeGenerator::getInstance().builder;
    auto& context = CodeGenerator::getInstance().context;
    auto* complexTy = leftValue->getType();

    llvm::Value* aRe = builder.CreateExtractValue(leftValue, {0}, "a_re");
    llvm::Value* aIm = builder.CreateExtractValue(leftValue, {1}, "a_im");
    llvm::Value* bRe = builder.CreateExtractValue(rightValue, {0}, "b_re");
    llvm::Value* bIm = builder.CreateExtractValue(rightValue, {1}, "b_im");

    llvm::Value* result = llvm::UndefValue::get(complexTy);

    if (op == "+") {
        result = builder.CreateInsertValue(result, builder.CreateFAdd(aRe, bRe, "re_add"), {0});
        result = builder.CreateInsertValue(result, builder.CreateFAdd(aIm, bIm, "im_add"), {1});
    } else if (op == "-") {
        result = builder.CreateInsertValue(result, builder.CreateFSub(aRe, bRe, "re_sub"), {0});
        result = builder.CreateInsertValue(result, builder.CreateFSub(aIm, bIm, "im_sub"), {1});
    } else if (op == "*") {
        // (ac-bd, ad+bc)
        llvm::Value* ac = builder.CreateFMul(aRe, bRe, "ac");
        llvm::Value* bd = builder.CreateFMul(aIm, bIm, "bd");
        llvm::Value* ad = builder.CreateFMul(aRe, bIm, "ad");
        llvm::Value* bc = builder.CreateFMul(aIm, bRe, "bc");
        result = builder.CreateInsertValue(result, builder.CreateFSub(ac, bd, "re_mul"), {0});
        result = builder.CreateInsertValue(result, builder.CreateFAdd(ad, bc, "im_mul"), {1});
    } else if (op == "/") {
        // ((ac+bd)/(c^2+d^2), (bc-ad)/(c^2+d^2))
        llvm::Value* cc = builder.CreateFMul(bRe, bRe, "cc");
        llvm::Value* dd = builder.CreateFMul(bIm, bIm, "dd");
        llvm::Value* denom = builder.CreateFAdd(cc, dd, "denom");
        llvm::Value* ac = builder.CreateFMul(aRe, bRe, "ac");
        llvm::Value* bd = builder.CreateFMul(aIm, bIm, "bd");
        llvm::Value* bc = builder.CreateFMul(aIm, bRe, "bc");
        llvm::Value* ad = builder.CreateFMul(aRe, bIm, "ad");
        result = builder.CreateInsertValue(result, builder.CreateFDiv(builder.CreateFAdd(ac, bd, "acbd"), denom, "re_div"), {0});
        result = builder.CreateInsertValue(result, builder.CreateFDiv(builder.CreateFSub(bc, ad, "bcad"), denom, "im_div"), {1});
    }
    return result;
}

// Get or create __gcd_i64(i64, i64) -> i64 in the module
static llvm::Function* getOrCreateGcdI64(llvm::Module& module, llvm::LLVMContext& context) {
    if (auto* f = module.getFunction("__gcd_i64")) return f;

    auto* i64Ty = llvm::Type::getInt64Ty(context);
    auto* funcTy = llvm::FunctionType::get(i64Ty, {i64Ty, i64Ty}, false);
    auto* func = llvm::Function::Create(funcTy, llvm::Function::InternalLinkage, "__gcd_i64", module);

    auto* entryBB = llvm::BasicBlock::Create(context, "entry", func);
    auto* loopBB = llvm::BasicBlock::Create(context, "loop", func);
    auto* bodyBB = llvm::BasicBlock::Create(context, "body", func);
    auto* exitBB = llvm::BasicBlock::Create(context, "exit", func);

    llvm::IRBuilder<> b(context);
    auto args = func->arg_begin();
    llvm::Value* aArg = &*args++;
    llvm::Value* bArg = &*args++;

    // entry: abs(a), abs(b)
    b.SetInsertPoint(entryBB);
    llvm::Value* aNeg = b.CreateICmpSLT(aArg, llvm::ConstantInt::get(i64Ty, 0));
    llvm::Value* aAbs = b.CreateSelect(aNeg, b.CreateNeg(aArg), aArg, "a_abs");
    llvm::Value* bNeg = b.CreateICmpSLT(bArg, llvm::ConstantInt::get(i64Ty, 0));
    llvm::Value* bAbs = b.CreateSelect(bNeg, b.CreateNeg(bArg), bArg, "b_abs");
    b.CreateBr(loopBB);

    // loop: Euclidean algorithm
    b.SetInsertPoint(loopBB);
    auto* xPhi = b.CreatePHI(i64Ty, 2, "x");
    auto* yPhi = b.CreatePHI(i64Ty, 2, "y");
    llvm::Value* isZero = b.CreateICmpEQ(yPhi, llvm::ConstantInt::get(i64Ty, 0));
    b.CreateCondBr(isZero, exitBB, bodyBB);

    // body: rem = x % y; x = y; y = rem
    b.SetInsertPoint(bodyBB);
    llvm::Value* rem = b.CreateSRem(xPhi, yPhi, "rem");
    b.CreateBr(loopBB);

    xPhi->addIncoming(aAbs, entryBB);
    xPhi->addIncoming(yPhi, bodyBB);
    yPhi->addIncoming(bAbs, entryBB);
    yPhi->addIncoming(rem, bodyBB);

    // exit: return x
    b.SetInsertPoint(exitBB);
    b.CreateRet(xPhi);

    return func;
}

// Helper: generate Rational arithmetic
static llvm::Value* codegenRationalOp(const std::string& op, llvm::Value* leftValue, llvm::Value* rightValue) {
    auto& cg = CodeGenerator::getInstance();
    auto& builder = cg.builder;
    auto* rationalTy = leftValue->getType();

    llvm::Value* aN = builder.CreateExtractValue(leftValue, {0}, "a_num");
    llvm::Value* aD = builder.CreateExtractValue(leftValue, {1}, "a_den");
    llvm::Value* bN = builder.CreateExtractValue(rightValue, {0}, "b_num");
    llvm::Value* bD = builder.CreateExtractValue(rightValue, {1}, "b_den");

    llvm::Value* num = nullptr;
    llvm::Value* den = nullptr;

    if (op == "+") {
        // (ad+bc, bd)
        llvm::Value* ad = builder.CreateMul(aN, bD, "ad");
        llvm::Value* bc = builder.CreateMul(bN, aD, "bc");
        num = builder.CreateAdd(ad, bc, "num_add");
        den = builder.CreateMul(aD, bD, "den_add");
    } else if (op == "-") {
        // (ad-bc, bd)
        llvm::Value* ad = builder.CreateMul(aN, bD, "ad");
        llvm::Value* bc = builder.CreateMul(bN, aD, "bc");
        num = builder.CreateSub(ad, bc, "num_sub");
        den = builder.CreateMul(aD, bD, "den_sub");
    } else if (op == "*") {
        // (ac, bd)
        num = builder.CreateMul(aN, bN, "num_mul");
        den = builder.CreateMul(aD, bD, "den_mul");
    } else if (op == "/") {
        // (ad, bc)
        num = builder.CreateMul(aN, bD, "num_div");
        den = builder.CreateMul(aD, bN, "den_div");
    }

    if (!num || !den) {
        std::cerr << "Type error: unsupported Rational operator '" << op << "'" << std::endl;
        return nullptr;
    }

    // GCD normalization
    llvm::Function* gcdFunc = getOrCreateGcdI64(*cg.module, cg.context);
    llvm::Value* g = builder.CreateCall(gcdFunc, {num, den}, "gcd");
    auto* i64Ty = llvm::Type::getInt64Ty(cg.context);
    llvm::Value* one = llvm::ConstantInt::get(i64Ty, 1);
    llvm::Value* gIsZero = builder.CreateICmpEQ(g, llvm::ConstantInt::get(i64Ty, 0));
    g = builder.CreateSelect(gIsZero, one, g, "gcd_safe");
    num = builder.CreateSDiv(num, g, "num_reduced");
    den = builder.CreateSDiv(den, g, "den_reduced");

    // Sign normalization: if den < 0, negate both
    llvm::Value* denNeg = builder.CreateICmpSLT(den, llvm::ConstantInt::get(i64Ty, 0));
    num = builder.CreateSelect(denNeg, builder.CreateNeg(num), num, "num_sign");
    den = builder.CreateSelect(denNeg, builder.CreateNeg(den), den, "den_sign");

    llvm::Value* result = llvm::UndefValue::get(rationalTy);
    result = builder.CreateInsertValue(result, num, {0});
    result = builder.CreateInsertValue(result, den, {1});
    return result;
}

// Helper: generate Quaternion arithmetic
static llvm::Value* codegenQuaternionOp(const std::string& op, llvm::Value* leftValue, llvm::Value* rightValue) {
    auto& builder = CodeGenerator::getInstance().builder;
    auto* quatTy = leftValue->getType();

    llvm::Value* aw = builder.CreateExtractValue(leftValue, {0}, "a_w");
    llvm::Value* ax = builder.CreateExtractValue(leftValue, {1}, "a_x");
    llvm::Value* ay = builder.CreateExtractValue(leftValue, {2}, "a_y");
    llvm::Value* az = builder.CreateExtractValue(leftValue, {3}, "a_z");
    llvm::Value* bw = builder.CreateExtractValue(rightValue, {0}, "b_w");
    llvm::Value* bx = builder.CreateExtractValue(rightValue, {1}, "b_x");
    llvm::Value* by = builder.CreateExtractValue(rightValue, {2}, "b_y");
    llvm::Value* bz = builder.CreateExtractValue(rightValue, {3}, "b_z");

    llvm::Value* result = llvm::UndefValue::get(quatTy);

    if (op == "+") {
        result = builder.CreateInsertValue(result, builder.CreateFAdd(aw, bw, "w_res"), {0});
        result = builder.CreateInsertValue(result, builder.CreateFAdd(ax, bx, "x_res"), {1});
        result = builder.CreateInsertValue(result, builder.CreateFAdd(ay, by, "y_res"), {2});
        result = builder.CreateInsertValue(result, builder.CreateFAdd(az, bz, "z_res"), {3});
    } else if (op == "-") {
        result = builder.CreateInsertValue(result, builder.CreateFSub(aw, bw, "w_res"), {0});
        result = builder.CreateInsertValue(result, builder.CreateFSub(ax, bx, "x_res"), {1});
        result = builder.CreateInsertValue(result, builder.CreateFSub(ay, by, "y_res"), {2});
        result = builder.CreateInsertValue(result, builder.CreateFSub(az, bz, "z_res"), {3});
    } else if (op == "*") {
        // Hamilton product
        // w = aw*bw - ax*bx - ay*by - az*bz
        llvm::Value* rw = builder.CreateFSub(
            builder.CreateFSub(
                builder.CreateFSub(builder.CreateFMul(aw, bw), builder.CreateFMul(ax, bx)),
                builder.CreateFMul(ay, by)),
            builder.CreateFMul(az, bz), "q_w");
        // x = aw*bx + ax*bw + ay*bz - az*by
        llvm::Value* rx = builder.CreateFSub(
            builder.CreateFAdd(
                builder.CreateFAdd(builder.CreateFMul(aw, bx), builder.CreateFMul(ax, bw)),
                builder.CreateFMul(ay, bz)),
            builder.CreateFMul(az, by), "q_x");
        // y = aw*by - ax*bz + ay*bw + az*bx
        llvm::Value* ry = builder.CreateFAdd(
            builder.CreateFAdd(
                builder.CreateFSub(builder.CreateFMul(aw, by), builder.CreateFMul(ax, bz)),
                builder.CreateFMul(ay, bw)),
            builder.CreateFMul(az, bx), "q_y");
        // z = aw*bz + ax*by - ay*bx + az*bw
        llvm::Value* rz = builder.CreateFAdd(
            builder.CreateFSub(
                builder.CreateFAdd(builder.CreateFMul(aw, bz), builder.CreateFMul(ax, by)),
                builder.CreateFMul(ay, bx)),
            builder.CreateFMul(az, bw), "q_z");
        result = builder.CreateInsertValue(result, rw, {0});
        result = builder.CreateInsertValue(result, rx, {1});
        result = builder.CreateInsertValue(result, ry, {2});
        result = builder.CreateInsertValue(result, rz, {3});
    }
    return result;
}

llvm::Value* BinaryExpressionNode::codegen() {
    llvm::Value* leftValue = left->codegen();
    if (!leftValue) return nullptr;

    if (leftValue->getType()->isPointerTy()) {
        auto& cg = CodeGenerator::getInstance();
        auto leftType = left->getType();
        if (!leftType) {
            std::cerr << "Type error: Cannot determine type of left operand" << std::endl;
            return nullptr;
        }
        leftValue = cg.builder.CreateLoad(cg.getLLVMType(leftType.get()), leftValue, "loadtmp");
    }

    // Short-circuit logical AND
    if (op == "and") {
        auto& cg = CodeGenerator::getInstance();
        llvm::Function* func = cg.builder.GetInsertBlock()->getParent();

        llvm::Value* leftBool = leftValue;
        if (!leftBool->getType()->isIntegerTy(1)) {
            if (leftBool->getType()->isIntegerTy()) {
                leftBool = cg.builder.CreateICmpNE(leftBool, llvm::ConstantInt::get(leftBool->getType(), 0), "tobool");
            }
            else if (leftBool->getType()->isFloatingPointTy()) {
                leftBool = cg.builder.CreateFCmpONE(leftBool, llvm::ConstantFP::get(leftBool->getType(), 0.0), "tobool");
            }
            else {
                std::cerr << "Type error: Operator 'and' requires numeric or boolean operands" << std::endl;
                return nullptr;
            }
        }

        llvm::Value* resultPtr = cg.builder.CreateAlloca(llvm::Type::getInt1Ty(cg.context), nullptr, "and_result");
        cg.builder.CreateStore(llvm::ConstantInt::getFalse(cg.context), resultPtr);

        llvm::BasicBlock* rhsBB = llvm::BasicBlock::Create(cg.context, "and_rhs", func);
        llvm::BasicBlock* mergeBB = llvm::BasicBlock::Create(cg.context, "and_end", func);

        cg.builder.CreateCondBr(leftBool, rhsBB, mergeBB);

        cg.builder.SetInsertPoint(rhsBB);
        llvm::Value* rv = right->codegen();
        if (!rv) return nullptr;
        if (rv->getType()->isPointerTy()) {
            rv = cg.builder.CreateLoad(cg.getLLVMType(right->getType().get()), rv, "loadtmp");
        }
        llvm::Value* rightBool = rv;
        if (!rightBool->getType()->isIntegerTy(1)) {
            if (rightBool->getType()->isIntegerTy()) {
                rightBool = cg.builder.CreateICmpNE(rightBool, llvm::ConstantInt::get(rightBool->getType(), 0), "tobool");
            }
            else if (rightBool->getType()->isFloatingPointTy()) {
                rightBool = cg.builder.CreateFCmpONE(rightBool, llvm::ConstantFP::get(rightBool->getType(), 0.0), "tobool");
            }
            else {
                std::cerr << "Type error: Operator 'and' requires numeric or boolean operands" << std::endl;
                return nullptr;
            }
        }
        cg.builder.CreateStore(rightBool, resultPtr);
        if (!cg.builder.GetInsertBlock()->getTerminator()) {
            cg.builder.CreateBr(mergeBB);
        }

        cg.builder.SetInsertPoint(mergeBB);
        return cg.builder.CreateLoad(llvm::Type::getInt1Ty(cg.context), resultPtr, "and_val");
    }

    // Short-circuit logical OR
    if (op == "or") {
        auto& cg = CodeGenerator::getInstance();
        llvm::Function* func = cg.builder.GetInsertBlock()->getParent();

        llvm::Value* leftBool = leftValue;
        if (!leftBool->getType()->isIntegerTy(1)) {
            if (leftBool->getType()->isIntegerTy()) {
                leftBool = cg.builder.CreateICmpNE(leftBool, llvm::ConstantInt::get(leftBool->getType(), 0), "tobool");
            }
            else if (leftBool->getType()->isFloatingPointTy()) {
                leftBool = cg.builder.CreateFCmpONE(leftBool, llvm::ConstantFP::get(leftBool->getType(), 0.0), "tobool");
            }
            else {
                std::cerr << "Type error: Operator 'or' requires numeric or boolean operands" << std::endl;
                return nullptr;
            }
        }

        llvm::Value* resultPtr = cg.builder.CreateAlloca(llvm::Type::getInt1Ty(cg.context), nullptr, "or_result");
        cg.builder.CreateStore(llvm::ConstantInt::getTrue(cg.context), resultPtr);

        llvm::BasicBlock* rhsBB = llvm::BasicBlock::Create(cg.context, "or_rhs", func);
        llvm::BasicBlock* mergeBB = llvm::BasicBlock::Create(cg.context, "or_end", func);

        cg.builder.CreateCondBr(leftBool, mergeBB, rhsBB);

        cg.builder.SetInsertPoint(rhsBB);
        llvm::Value* rv = right->codegen();
        if (!rv) return nullptr;
        if (rv->getType()->isPointerTy()) {
            rv = cg.builder.CreateLoad(cg.getLLVMType(right->getType().get()), rv, "loadtmp");
        }
        llvm::Value* rightBool = rv;
        if (!rightBool->getType()->isIntegerTy(1)) {
            if (rightBool->getType()->isIntegerTy()) {
                rightBool = cg.builder.CreateICmpNE(rightBool, llvm::ConstantInt::get(rightBool->getType(), 0), "tobool");
            }
            else if (rightBool->getType()->isFloatingPointTy()) {
                rightBool = cg.builder.CreateFCmpONE(rightBool, llvm::ConstantFP::get(rightBool->getType(), 0.0), "tobool");
            }
            else {
                std::cerr << "Type error: Operator 'or' requires numeric or boolean operands" << std::endl;
                return nullptr;
            }
        }
        cg.builder.CreateStore(rightBool, resultPtr);
        if (!cg.builder.GetInsertBlock()->getTerminator()) {
            cg.builder.CreateBr(mergeBB);
        }

        cg.builder.SetInsertPoint(mergeBB);
        return cg.builder.CreateLoad(llvm::Type::getInt1Ty(cg.context), resultPtr, "or_val");
    }

    llvm::Value* rightValue = right->codegen();
    if (!rightValue) return nullptr;

    if (rightValue->getType()->isPointerTy()) {
        auto& cg = CodeGenerator::getInstance();
        auto rightType = right->getType();
        if (!rightType) {
            std::cerr << "Type error: Cannot determine type of right operand" << std::endl;
            return nullptr;
        }
        rightValue = cg.builder.CreateLoad(cg.getLLVMType(rightType.get()), rightValue, "loadtmp");
    }

    // Struct type arithmetic (Complex, Rational, Quaternion)
    std::string leftTypeName = left->getType() ? left->getType()->getName() : "";
    std::string rightTypeName = right->getType() ? right->getType()->getName() : "";
    if (leftTypeName == rightTypeName) {
        if (leftTypeName == "Complex" && (op == "+" || op == "-" || op == "*" || op == "/")) {
            return codegenComplexOp(op, leftValue, rightValue);
        }
        if (leftTypeName == "Rational" && (op == "+" || op == "-" || op == "*" || op == "/")) {
            return codegenRationalOp(op, leftValue, rightValue);
        }
        if (leftTypeName == "Quaternion" && (op == "+" || op == "-" || op == "*")) {
            return codegenQuaternionOp(op, leftValue, rightValue);
        }
        if (leftTypeName == "Quaternion" && op == "/") {
            std::cerr << "Type error: Quaternion division is not supported (division is undefined for quaternions)" << std::endl;
            return nullptr;
        }
    }

    auto& cg = CodeGenerator::getInstance();

    if (op == "+") {
        if (leftTypeName == rightTypeName) {
            if (left->getType()->isIntegerTy()) {
                return cg.builder.CreateAdd(leftValue, rightValue, "addtmp");
            }
            else if (left->getType()->isFloatTy() || left->getType()->isDoubleTy()) {
                return cg.builder.CreateFAdd(leftValue, rightValue, "faddtmp");
            }
            else {
                std::cerr << "Type error: Operator '" << op << "' not applicable to type '" << leftTypeName << "' and '" << rightTypeName << "'" << std::endl;
                return nullptr;
            }
        }
        else {
            std::cerr << "Type error: Left and right expressions have different types for operator '" << op << "'" << std::endl;
            return nullptr;
        }
    }
    else if (op == "-") {
        if (leftTypeName == rightTypeName) {
            if (left->getType()->isIntegerTy()) {
                return cg.builder.CreateSub(leftValue, rightValue, "subtmp");
            }
            else if (left->getType()->isFloatTy() || left->getType()->isDoubleTy()) {
                return cg.builder.CreateFSub(leftValue, rightValue, "fsubtmp");
            }
            else {
                std::cerr << "Type error: Operator '" << op << "' not applicable to type '" << leftTypeName << "' and '" << rightTypeName << "'" << std::endl;
                return nullptr;
            }
        }
        else {
            std::cerr << "Type error: Operator '" << op << "' not applicable to type '" << leftTypeName << "' and '" << rightTypeName << "'" << std::endl;
            return nullptr;
        }
    }
    else if (op == "*") {
        if (leftTypeName == rightTypeName) {
            if (left->getType()->isIntegerTy()) {
                return cg.builder.CreateMul(leftValue, rightValue, "multmp");
            }
            else if (left->getType()->isFloatTy() || left->getType()->isDoubleTy()) {
                return cg.builder.CreateFMul(leftValue, rightValue, "fmultmp");
            }
            else {
                std::cerr << "Type error: Operator '" << op << "' not applicable to type '" << leftTypeName << "' and '" << rightTypeName << "'" << std::endl;
                return nullptr;
            }
        }
        else {
            std::cerr << "Type error: Operator '" << op << "' not applicable to type '" << leftTypeName << "' and '" << rightTypeName << "'" << std::endl;
            return nullptr;
        }
    }
    else if (op == "/") {
        if (leftTypeName == rightTypeName) {
            if (left->getType()->isIntegerTy()) {
                return cg.builder.CreateSDiv(leftValue, rightValue, "divtmp");
            }
            else if (left->getType()->isFloatTy() || left->getType()->isDoubleTy()) {
                return cg.builder.CreateFDiv(leftValue, rightValue, "fdivtmp");
            }
            else {
                std::cerr << "Type error: Operator '" << op << "' not applicable to type '" << leftTypeName << "' and '" << rightTypeName << "'" << std::endl;
                return nullptr;
            }
        }
        else {
            std::cerr << "Type error: Operator '" << op << "' not applicable to type '" << leftTypeName << "' and '" << rightTypeName << "'" << std::endl;
            return nullptr;
        }
    }
    else if (op == "%") {
        if (leftTypeName == rightTypeName) {
            if (left->getType()->isIntegerTy()) {
                return cg.builder.CreateSRem(leftValue, rightValue, "modtmp");
            }
            else if (left->getType()->isFloatTy() || left->getType()->isDoubleTy()) {
                return cg.builder.CreateFRem(leftValue, rightValue, "fmodtmp");
            }
            else {
                std::cerr << "Type error: Operator '" << op << "' not applicable to type '" << leftTypeName << "' and '" << rightTypeName << "'" << std::endl;
                return nullptr;
            }
        }
        else {
            std::cerr << "Type error: Operator '" << op << "' not applicable to type '" << leftTypeName << "' and '" << rightTypeName << "'" << std::endl;
            return nullptr;
        }
    }
    else if (op == "&") {
        if (leftTypeName != rightTypeName || !left->getType()->isIntegerTy()) {
            std::cerr << "Type error: Operator '" << op << "' requires same integer operand types" << std::endl;
            return nullptr;
        }
        return cg.builder.CreateAnd(leftValue, rightValue, "andtmp");
    }
    else if (op == "|") {
        if (leftTypeName != rightTypeName || !left->getType()->isIntegerTy()) {
            std::cerr << "Type error: Operator '" << op << "' requires same integer operand types" << std::endl;
            return nullptr;
        }
        return cg.builder.CreateOr(leftValue, rightValue, "ortmp");
    }
    else if (op == "xor") {
        if (leftTypeName != rightTypeName || !left->getType()->isIntegerTy()) {
            std::cerr << "Type error: Operator '" << op << "' requires same integer operand types" << std::endl;
            return nullptr;
        }
        return cg.builder.CreateXor(leftValue, rightValue, "xortmp");
    }
    else if (op == "<<") {
        if (leftTypeName != rightTypeName || !left->getType()->isIntegerTy()) {
            std::cerr << "Type error: Operator '" << op << "' requires same integer operand types" << std::endl;
            return nullptr;
        }
        return cg.builder.CreateShl(leftValue, rightValue, "shltmp");
    }
    else if (op == ">>") {
        if (leftTypeName != rightTypeName || !left->getType()->isIntegerTy()) {
            std::cerr << "Type error: Operator '" << op << "' requires same integer operand types" << std::endl;
            return nullptr;
        }
        return cg.builder.CreateAShr(leftValue, rightValue, "ashrtmp");
    }
    else if (op == ">" || op == "<" || op == "==" || op == "!=" || op == ">=" || op == "<=") {
        const bool isFloatCompare = left->getType()->isFloatTy() || left->getType()->isDoubleTy();
        if (isFloatCompare) {
            if (op == ">") return cg.builder.CreateFCmpOGT(leftValue, rightValue, "gttmp");
            if (op == "<") return cg.builder.CreateFCmpOLT(leftValue, rightValue, "lttmp");
            if (op == "==") return cg.builder.CreateFCmpOEQ(leftValue, rightValue, "eqtmp");
            if (op == "!=") return cg.builder.CreateFCmpONE(leftValue, rightValue, "netmp");
            if (op == ">=") return cg.builder.CreateFCmpOGE(leftValue, rightValue, "getmp");
            if (op == "<=") return cg.builder.CreateFCmpOLE(leftValue, rightValue, "letmp");
        }
        else {
            if (op == ">") return cg.builder.CreateICmpSGT(leftValue, rightValue, "gttmp");
            if (op == "<") return cg.builder.CreateICmpSLT(leftValue, rightValue, "lttmp");
            if (op == "==") return cg.builder.CreateICmpEQ(leftValue, rightValue, "eqtmp");
            if (op == "!=") return cg.builder.CreateICmpNE(leftValue, rightValue, "netmp");
            if (op == ">=") return cg.builder.CreateICmpSGE(leftValue, rightValue, "getmp");
            if (op == "<=") return cg.builder.CreateICmpSLE(leftValue, rightValue, "letmp");
        }
        std::cerr << "Unsupported comparison operator: " << op << std::endl;
        return nullptr;
    }

    std::cerr << "Type error: unsupported operator '" << op << "'" << std::endl;
    return nullptr;
}

std::unique_ptr<Type> BinaryExpressionNode::getType() {
    if (type) return type->clone();

    auto leftType = left->getType();
    auto rightType = right->getType();

    if (!leftType || !rightType) {
        std::cerr << "Type error: Cannot determine type of operand in binary expression" << std::endl;
        return std::make_unique<UnknownType>();
    }

    if (!leftType->equals(rightType)) {
        std::cerr << "Type error: Left and right expressions have different types" << std::endl;
        return std::make_unique<UnknownType>();
    }

    if (op == "+" || op == "-" || op == "*" || op == "/" || op == "%") {
        if (leftType->getName() == "Int" || leftType->getName() == "Float" || leftType->getName() == "Double"
            || leftType->getName() == "Long" || leftType->getName() == "Natural" || leftType->getName() == "Integer"
            || leftType->getName() == "Real" || leftType->getName() == "Complex" || leftType->getName() == "Rational"
            || leftType->getName() == "Quaternion") {
            return left->getType();
        }
        else {
            std::cerr << "Type error: Operator '" << op << "' not applicable to type '" << leftType->getName() << "'" << std::endl;
            return std::make_unique<UnknownType>();
        }
    }
    else if (op == ">" || op == "<" || op == "==" || op == "!=" || op == ">=" || op == "<=") {
        return std::make_unique<BasicType>("Boolean");
    }
    else if (op == "and" || op == "or") {
        return std::make_unique<BasicType>("Boolean");
    }
    else if (op == "xor" || op == "&" || op == "|" || op == "<<" || op == ">>") {
        if (!leftType->isIntegerTy()) {
            std::cerr << "Type error: Operator '" << op << "' requires integer operand type" << std::endl;
            return std::make_unique<UnknownType>();
        }
        return left->getType();
    }

    return std::make_unique<UnknownType>();
}


