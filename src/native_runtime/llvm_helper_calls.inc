std::string llvmCallArgumentValueDefinition() {
    std::string output = R"(define ptr @llvmCallArgumentValue(ptr %arg.tokens, i32 %arg.start, i32 %arg.rawEnd, ptr %arg.resultName, i32 %arg.index) {
entry:
  %end = call i32 @trimExpressionEnd(ptr %arg.tokens, i32 %arg.start, i32 %arg.rawEnd)
  %empty = icmp sle i32 %end, %arg.start
  br i1 %empty, label %empty.return, label %integer.check
empty.return:
  ret ptr @.str.callarg.value.zero
integer.check:
  %kind = call i8 @tokenKindAt(ptr %arg.tokens, i32 %arg.start)
  %integer.kind = call i8 @kindInteger()
  %is.integer = icmp eq i8 %kind, %integer.kind
  %single.end = add i32 %arg.start, 1
  %single = icmp eq i32 %end, %single.end
  %integer = and i1 %is.integer, %single
  br i1 %integer, label %integer.return, label %char.check
integer.return:
  %integer.text = call ptr @tokenTextAt(ptr %arg.tokens, i32 %arg.start)
  ret ptr %integer.text
char.check:
  %char.kind = call i8 @kindChar()
  %is.char = icmp eq i8 %kind, %char.kind
  %char = and i1 %is.char, %single
  br i1 %char, label %char.return, label %bool.check
char.return:
  %char.text = call ptr @tokenTextAt(ptr %arg.tokens, i32 %arg.start)
  %char.value = call ptr @llvmCharI8Value(ptr %char.text)
  ret ptr %char.value
bool.check:
  %bool.kind = call i8 @kindBool()
  %is.bool = icmp eq i8 %kind, %bool.kind
  %bool = and i1 %is.bool, %single
  br i1 %bool, label %bool.return, label %temporary.return
bool.return:
  %bool.text = call ptr @tokenTextAt(ptr %arg.tokens, i32 %arg.start)
  ret ptr %bool.text
temporary.return:
  %prefix = call ptr @csec_string_concat(ptr %arg.resultName, ptr @.str.callarg.value.arg)
  %index.i64 = sext i32 %arg.index to i64
  %index.text = call ptr @csec_to_string_i64(i64 %index.i64)
  %result = call ptr @csec_string_concat(ptr %prefix, ptr %index.text)
  ret ptr %result
}

)";
    output += llvmStringGlobal(".str.callarg.value.zero", "0");
    output += llvmStringGlobal(".str.callarg.value.arg", ".arg");
    return output;
}

std::string llvmGenerateCallArgumentLoadI32Definition() {
    std::string output = R"(define ptr @generateLLVMCallArgumentLoadI32(ptr %arg.tokens, i32 %arg.start, i32 %arg.rawEnd, ptr %arg.resultName) {
entry:
  %end = call i32 @trimExpressionEnd(ptr %arg.tokens, i32 %arg.start, i32 %arg.rawEnd)
  %empty = icmp sle i32 %end, %arg.start
  br i1 %empty, label %empty.return, label %string.check
empty.return:
  %e1 = call ptr @csec_string_concat(ptr @.str.callargload.prefix, ptr %arg.resultName)
  %e2 = call ptr @csec_string_concat(ptr %e1, ptr @.str.callargload.add.prefix)
  %empty.result = call ptr @csec_string_concat(ptr %e2, ptr @.str.callargload.zero)
  ret ptr %empty.result
string.check:
  %kind = call i8 @tokenKindAt(ptr %arg.tokens, i32 %arg.start)
  %string.kind = call i8 @kindString()
  %is.string = icmp eq i8 %kind, %string.kind
  %single.end = add i32 %arg.start, 1
  %single = icmp eq i32 %end, %single.end
  %string = and i1 %is.string, %single
  br i1 %string, label %string.return, label %integer.check
string.return:
  %text = call ptr @tokenTextAt(ptr %arg.tokens, i32 %arg.start)
  %bytes = call i32 @csec_llvm_string_literal_byte_length(ptr %text)
  %bytes.i64 = sext i32 %bytes to i64
  %bytes.text = call ptr @csec_to_string_i64(i64 %bytes.i64)
  %start.i64 = sext i32 %arg.start to i64
  %start.text = call ptr @csec_to_string_i64(i64 %start.i64)
  %s1 = call ptr @csec_string_concat(ptr @.str.callargload.prefix, ptr %arg.resultName)
  %s2 = call ptr @csec_string_concat(ptr %s1, ptr @.str.callargload.gep.left)
  %s3 = call ptr @csec_string_concat(ptr %s2, ptr %bytes.text)
  %s4 = call ptr @csec_string_concat(ptr %s3, ptr @.str.callargload.gep.middle)
  %s5 = call ptr @csec_string_concat(ptr %s4, ptr %start.text)
  %result = call ptr @csec_string_concat(ptr %s5, ptr @.str.callargload.gep.right)
  ret ptr %result
integer.check:
  %integer.kind = call i8 @kindInteger()
  %is.integer = icmp eq i8 %kind, %integer.kind
  %integer = and i1 %is.integer, %single
  br i1 %integer, label %integer.return, label %char.check
integer.return:
  %integer.text = call ptr @tokenTextAt(ptr %arg.tokens, i32 %arg.start)
  %i1 = call ptr @csec_string_concat(ptr @.str.callargload.prefix, ptr %arg.resultName)
  %i2 = call ptr @csec_string_concat(ptr %i1, ptr @.str.callargload.add.prefix)
  %integer.result = call ptr @csec_string_concat(ptr %i2, ptr %integer.text)
  ret ptr %integer.result
char.check:
  %char.kind = call i8 @kindChar()
  %is.char = icmp eq i8 %kind, %char.kind
  %char = and i1 %is.char, %single
  br i1 %char, label %char.return, label %identifier.check
char.return:
  %char.text = call ptr @tokenTextAt(ptr %arg.tokens, i32 %arg.start)
  %char.value = call ptr @llvmCharI8Value(ptr %char.text)
  %c1 = call ptr @csec_string_concat(ptr @.str.callargload.prefix, ptr %arg.resultName)
  %c2 = call ptr @csec_string_concat(ptr %c1, ptr @.str.callargload.add.prefix)
  %char.result = call ptr @csec_string_concat(ptr %c2, ptr %char.value)
  ret ptr %char.result
identifier.check:
  %identifier.kind = call i8 @kindIdentifier()
  %is.identifier = icmp eq i8 %kind, %identifier.kind
  %identifier = and i1 %is.identifier, %single
  br i1 %identifier, label %identifier.return, label %expression.type
identifier.return:
  %name = call ptr @tokenTextAt(ptr %arg.tokens, i32 %arg.start)
  %value.type = call ptr @lookupVisibleValueType(ptr %arg.tokens, i32 %arg.start, ptr %name)
  %load = call ptr @llvmLoadForValueType(ptr %arg.tokens, i32 %arg.start, ptr %name, ptr %value.type, ptr %arg.resultName)
  ret ptr %load
expression.type:
  %argument.type = call ptr @llvmCallArgumentType(ptr %arg.tokens, i32 %arg.start, i32 %end)
  %pointer.argument = call i1 @strEq(ptr %argument.type, ptr @.str.callargload.ptr)
  br i1 %pointer.argument, label %pointer.expression.return, label %expression.return
pointer.expression.return:
  %pointer.expression = call ptr @generateLLVMExpressionPtr(ptr %arg.tokens, i32 %arg.start, i32 %end, ptr %arg.resultName)
  ret ptr %pointer.expression
expression.return:
  %expression = call ptr @generateLLVMExpressionI32(ptr %arg.tokens, i32 %arg.start, i32 %end, ptr %arg.resultName)
  ret ptr %expression
}

)";
    output += llvmStringGlobal(".str.callargload.prefix", "  ");
    output += llvmStringGlobal(".str.callargload.zero", "0\n");
    output += llvmStringGlobal(".str.callargload.gep.left", " = getelementptr inbounds [");
    output += llvmStringGlobal(".str.callargload.gep.middle", " x i8], ptr @.str.");
    output += llvmStringGlobal(".str.callargload.gep.right", ", i32 0, i32 0\n");
    output += llvmStringGlobal(".str.callargload.add.prefix", " = add i32 0, ");
    output += llvmStringGlobal(".str.callargload.ptr", "ptr");
    return output;
}

std::string llvmGenerateCallArgumentLoadsI32Definition() {
    std::string output = R"(define ptr @generateLLVMCallArgumentLoadsI32(ptr %arg.tokens, i32 %arg.argsStart, i32 %arg.argsEnd, ptr %arg.resultName) {
entry:
  %first = call i32 @skipTrivia(ptr %arg.tokens, i32 %arg.argsStart)
  %end = call i32 @trimExpressionEnd(ptr %arg.tokens, i32 %first, i32 %arg.argsEnd)
  %empty = icmp sge i32 %first, %end
  br i1 %empty, label %empty.return, label %last.find
empty.return:
  ret ptr @.str.callargloads.empty
last.find:
  %last = call i32 @findTopLevelOperator(ptr %arg.tokens, i32 %first, i32 %end, i32 12)
  %one = icmp slt i32 %last, %first
  br i1 %one, label %one.return, label %second.find
one.return:
  %name = call ptr @csec_string_concat(ptr %arg.resultName, ptr @.str.callargloads.arg0)
  %one.result = call ptr @generateLLVMCallArgumentLoadI32(ptr %arg.tokens, i32 %first, i32 %end, ptr %name)
  ret ptr %one.result
second.find:
  %second.comma = call i32 @findTopLevelOperator(ptr %arg.tokens, i32 %first, i32 %last, i32 12)
  %two = icmp slt i32 %second.comma, %first
  br i1 %two, label %two.return, label %first.find
two.return:
  %name0 = call ptr @csec_string_concat(ptr %arg.resultName, ptr @.str.callargloads.arg0)
  %left = call ptr @generateLLVMCallArgumentLoadI32(ptr %arg.tokens, i32 %first, i32 %last, ptr %name0)
  %second.start.raw = add i32 %last, 1
  %second.start = call i32 @skipTrivia(ptr %arg.tokens, i32 %second.start.raw)
  %name1 = call ptr @csec_string_concat(ptr %arg.resultName, ptr @.str.callargloads.arg1)
  %right = call ptr @generateLLVMCallArgumentLoadI32(ptr %arg.tokens, i32 %second.start, i32 %end, ptr %name1)
  %two.result = call ptr @csec_string_concat(ptr %left, ptr %right)
  ret ptr %two.result
first.find:
  %first.comma = call i32 @findTopLevelOperator(ptr %arg.tokens, i32 %first, i32 %second.comma, i32 12)
  %three = icmp slt i32 %first.comma, %first
  br i1 %three, label %three.return, label %four.return
three.return:
  %name0.3 = call ptr @csec_string_concat(ptr %arg.resultName, ptr @.str.callargloads.arg0)
  %part0 = call ptr @generateLLVMCallArgumentLoadI32(ptr %arg.tokens, i32 %first, i32 %second.comma, ptr %name0.3)
  %second.start.raw.3 = add i32 %second.comma, 1
  %second.start.3 = call i32 @skipTrivia(ptr %arg.tokens, i32 %second.start.raw.3)
  %name1.3 = call ptr @csec_string_concat(ptr %arg.resultName, ptr @.str.callargloads.arg1)
  %part1 = call ptr @generateLLVMCallArgumentLoadI32(ptr %arg.tokens, i32 %second.start.3, i32 %last, ptr %name1.3)
  %third.start.raw = add i32 %last, 1
  %third.start = call i32 @skipTrivia(ptr %arg.tokens, i32 %third.start.raw)
  %name2.3 = call ptr @csec_string_concat(ptr %arg.resultName, ptr @.str.callargloads.arg2)
  %part2 = call ptr @generateLLVMCallArgumentLoadI32(ptr %arg.tokens, i32 %third.start, i32 %end, ptr %name2.3)
  %join0 = call ptr @csec_string_concat(ptr %part0, ptr %part1)
  %result3 = call ptr @csec_string_concat(ptr %join0, ptr %part2)
  ret ptr %result3
four.return:
  %name0.4 = call ptr @csec_string_concat(ptr %arg.resultName, ptr @.str.callargloads.arg0)
  %part0.4 = call ptr @generateLLVMCallArgumentLoadI32(ptr %arg.tokens, i32 %first, i32 %first.comma, ptr %name0.4)
  %second.start.raw.4 = add i32 %first.comma, 1
  %second.start.4 = call i32 @skipTrivia(ptr %arg.tokens, i32 %second.start.raw.4)
  %name1.4 = call ptr @csec_string_concat(ptr %arg.resultName, ptr @.str.callargloads.arg1)
  %part1.4 = call ptr @generateLLVMCallArgumentLoadI32(ptr %arg.tokens, i32 %second.start.4, i32 %second.comma, ptr %name1.4)
  %third.start.raw.4 = add i32 %second.comma, 1
  %third.start.4 = call i32 @skipTrivia(ptr %arg.tokens, i32 %third.start.raw.4)
  %name2.4 = call ptr @csec_string_concat(ptr %arg.resultName, ptr @.str.callargloads.arg2)
  %part2.4 = call ptr @generateLLVMCallArgumentLoadI32(ptr %arg.tokens, i32 %third.start.4, i32 %last, ptr %name2.4)
  %fourth.start.raw = add i32 %last, 1
  %fourth.start = call i32 @skipTrivia(ptr %arg.tokens, i32 %fourth.start.raw)
  %name3.4 = call ptr @csec_string_concat(ptr %arg.resultName, ptr @.str.callargloads.arg3)
  %part3.4 = call ptr @generateLLVMCallArgumentLoadI32(ptr %arg.tokens, i32 %fourth.start, i32 %end, ptr %name3.4)
  %join1 = call ptr @csec_string_concat(ptr %part0.4, ptr %part1.4)
  %join2 = call ptr @csec_string_concat(ptr %join1, ptr %part2.4)
  %result4 = call ptr @csec_string_concat(ptr %join2, ptr %part3.4)
  ret ptr %result4
}

)";
    output += llvmStringGlobal(".str.callargloads.empty", "");
    output += llvmStringGlobal(".str.callargloads.arg0", ".arg0");
    output += llvmStringGlobal(".str.callargloads.arg1", ".arg1");
    output += llvmStringGlobal(".str.callargloads.arg2", ".arg2");
    output += llvmStringGlobal(".str.callargloads.arg3", ".arg3");
    return output;
}

std::string llvmGenerateAssignmentI32Definition() {
    std::string output = R"(define ptr @generateLLVMAssignmentI32(ptr %arg.tokens, i32 %arg.start, i32 %arg.end) {
entry:
  %op = call i32 @findTopLevelOperator(ptr %arg.tokens, i32 %arg.start, i32 %arg.end, i32 1)
  %has.op = icmp sgt i32 %op, %arg.start
  br i1 %has.op, label %kind.check, label %empty.return
kind.check:
  %kind = call i8 @tokenKindAt(ptr %arg.tokens, i32 %arg.start)
  %identifier.kind = call i8 @kindIdentifier()
  %is.identifier = icmp eq i8 %kind, %identifier.kind
  br i1 %is.identifier, label %assignment.check, label %empty.return
assignment.check:
  %op.text = call ptr @tokenTextAt(ptr %arg.tokens, i32 %op)
  %equals = call i1 @strEq(ptr %op.text, ptr @.str.assignment.i32.equals)
  br i1 %equals, label %assignment.return, label %arrow.check
arrow.check:
  %arrow = call i1 @strEq(ptr %op.text, ptr @.str.assignment.i32.arrow)
  br i1 %arrow, label %assignment.return, label %empty.return
assignment.return:
  %name = call ptr @tokenTextAt(ptr %arg.tokens, i32 %arg.start)
  %storage = call ptr @lookupVisibleStorageName(ptr %arg.tokens, i32 %arg.start, ptr %name)
  %start.i64 = sext i32 %arg.start to i64
  %start.text = call ptr @csec_to_string_i64(i64 %start.i64)
  %a1 = call ptr @csec_string_concat(ptr @.str.assignment.i32.percent, ptr %name)
  %a2 = call ptr @csec_string_concat(ptr %a1, ptr @.str.assignment.i32.result)
  %result.name = call ptr @csec_string_concat(ptr %a2, ptr %start.text)
  %rhs.start = add i32 %op, 1
  %expression = call ptr @generateLLVMExpressionI32(ptr %arg.tokens, i32 %rhs.start, i32 %arg.end, ptr %result.name)
  %s1 = call ptr @csec_string_concat(ptr %expression, ptr @.str.assignment.i32.store)
  %s2 = call ptr @csec_string_concat(ptr %s1, ptr %result.name)
  %s3 = call ptr @csec_string_concat(ptr %s2, ptr @.str.assignment.i32.to)
  %assignment.result = call ptr @csec_string_concat(ptr %s3, ptr %storage)
  ret ptr %assignment.result
empty.return:
  ret ptr @.str.assignment.i32.empty
}

)";
    output += llvmStringGlobal(".str.assignment.i32.equals", "=");
    output += llvmStringGlobal(".str.assignment.i32.arrow", "<-");
    output += llvmStringGlobal(".str.assignment.i32.percent", "%");
    output += llvmStringGlobal(".str.assignment.i32.result", ".assign.");
    output += llvmStringGlobal(".str.assignment.i32.store", "  store i32 ");
    output += llvmStringGlobal(".str.assignment.i32.to", ", ptr %");
    output += llvmStringGlobal(".str.assignment.i32.empty", "");
    return output;
}

std::string llvmGenerateAssignmentI64Definition() {
    std::string output = R"(define ptr @generateLLVMAssignmentI64(ptr %arg.tokens, i32 %arg.start, i32 %arg.end) {
entry:
  %op = call i32 @findTopLevelOperator(ptr %arg.tokens, i32 %arg.start, i32 %arg.end, i32 1)
  %has.op = icmp sgt i32 %op, %arg.start
  br i1 %has.op, label %kind.check, label %empty.return
kind.check:
  %kind = call i8 @tokenKindAt(ptr %arg.tokens, i32 %arg.start)
  %identifier.kind = call i8 @kindIdentifier()
  %is.identifier = icmp eq i8 %kind, %identifier.kind
  br i1 %is.identifier, label %assignment.check, label %empty.return
assignment.check:
  %op.text = call ptr @tokenTextAt(ptr %arg.tokens, i32 %op)
  %equals = call i1 @strEq(ptr %op.text, ptr @.str.assignment.i64.equals)
  br i1 %equals, label %assignment.return, label %arrow.check
arrow.check:
  %arrow = call i1 @strEq(ptr %op.text, ptr @.str.assignment.i64.arrow)
  br i1 %arrow, label %assignment.return, label %empty.return
assignment.return:
  %name = call ptr @tokenTextAt(ptr %arg.tokens, i32 %arg.start)
  %storage = call ptr @lookupVisibleStorageName(ptr %arg.tokens, i32 %arg.start, ptr %name)
  %start.i64 = sext i32 %arg.start to i64
  %start.text = call ptr @csec_to_string_i64(i64 %start.i64)
  %a1 = call ptr @csec_string_concat(ptr @.str.assignment.i64.percent, ptr %name)
  %a2 = call ptr @csec_string_concat(ptr %a1, ptr @.str.assignment.i64.result)
  %result.name = call ptr @csec_string_concat(ptr %a2, ptr %start.text)
  %rhs.start = add i32 %op, 1
  %expression = call ptr @generateLLVMExpressionI64(ptr %arg.tokens, i32 %rhs.start, i32 %arg.end, ptr %result.name)
  %s1 = call ptr @csec_string_concat(ptr %expression, ptr @.str.assignment.i64.store)
  %s2 = call ptr @csec_string_concat(ptr %s1, ptr %result.name)
  %s3 = call ptr @csec_string_concat(ptr %s2, ptr @.str.assignment.i64.to)
  %assignment.result = call ptr @csec_string_concat(ptr %s3, ptr %storage)
  ret ptr %assignment.result
empty.return:
  ret ptr @.str.assignment.i64.empty
}

)";
    output += llvmStringGlobal(".str.assignment.i64.equals", "=");
    output += llvmStringGlobal(".str.assignment.i64.arrow", "<-");
    output += llvmStringGlobal(".str.assignment.i64.percent", "%");
    output += llvmStringGlobal(".str.assignment.i64.result", ".lassign.");
    output += llvmStringGlobal(".str.assignment.i64.store", "  store i64 ");
    output += llvmStringGlobal(".str.assignment.i64.to", ", ptr %");
    output += llvmStringGlobal(".str.assignment.i64.empty", "");
    return output;
}

std::string llvmRuntimeCallNameDefinition() {
    return R"RUNTIMENAMELLVM(define ptr @llvmRuntimeCallName(ptr %arg.name) {
entry:
  %count = call i1 @strEq(ptr %arg.name, ptr @.str.runtime.name.count)
  br i1 %count, label %count.return, label %arg.check
count.return:
  ret ptr @.str.runtime.name.count.native
arg.check:
  %arg = call i1 @strEq(ptr %arg.name, ptr @.str.runtime.name.arg)
  br i1 %arg, label %arg.return, label %identity.return
arg.return:
  ret ptr @.str.runtime.name.arg.native
identity.return:
  ret ptr %arg.name
}

@.str.runtime.name.count = private unnamed_addr constant [20 x i8] c"commandLineArgCount\00"
@.str.runtime.name.count.native = private unnamed_addr constant [28 x i8] c"csec_command_line_arg_count\00"
@.str.runtime.name.arg = private unnamed_addr constant [15 x i8] c"commandLineArg\00"
@.str.runtime.name.arg.native = private unnamed_addr constant [22 x i8] c"csec_command_line_arg\00"
)RUNTIMENAMELLVM";
}

std::string llvmGenerateLocalI32Definition() {
    return R"LOCALI32LLVM(define ptr @generateLLVMLocalI32(ptr %arg.tokens, i32 %arg.start, i32 %arg.end) {
entry:
  %initializer = call i32 @findTopLevelOperator(ptr %arg.tokens, i32 %arg.start, i32 %arg.end, i32 1)
  %name.index = add i32 %arg.start, 1
  %name = call ptr @tokenTextAt(ptr %arg.tokens, i32 %name.index)
  %start.i64 = sext i32 %arg.start to i64
  %start.text = call ptr @csec_to_string_i64(i64 %start.i64)
  %storage.a = call ptr @csec_string_concat(ptr %name, ptr @.str.local.i32.addr)
  %storage = call ptr @csec_string_concat(ptr %storage.a, ptr %start.text)
  %init.a = call ptr @csec_string_concat(ptr @.str.local.i32.percent, ptr %name)
  %init.b = call ptr @csec_string_concat(ptr %init.a, ptr @.str.local.i32.init)
  %init = call ptr @csec_string_concat(ptr %init.b, ptr %start.text)
  %has.initializer = icmp sge i32 %initializer, %arg.start
  br i1 %has.initializer, label %with.initializer, label %without.initializer
with.initializer:
  %expr.start = add i32 %initializer, 1
  %expr = call ptr @generateLLVMExpressionI32(ptr %arg.tokens, i32 %expr.start, i32 %arg.end, ptr %init)
  %a1 = call ptr @csec_string_concat(ptr @.str.local.i32.prefix, ptr %storage)
  %a2 = call ptr @csec_string_concat(ptr %a1, ptr @.str.local.i32.alloca)
  %a3 = call ptr @csec_string_concat(ptr %a2, ptr %expr)
  %a4 = call ptr @csec_string_concat(ptr %a3, ptr @.str.local.i32.store)
  %a5 = call ptr @csec_string_concat(ptr %a4, ptr %init)
  %a6 = call ptr @csec_string_concat(ptr %a5, ptr @.str.local.i32.to)
  %result = call ptr @csec_string_concat(ptr %a6, ptr %storage)
  ret ptr %result
without.initializer:
  %b1 = call ptr @csec_string_concat(ptr @.str.local.i32.prefix, ptr %storage)
  %b2 = call ptr @csec_string_concat(ptr %b1, ptr @.str.local.i32.alloca)
  %b3 = call ptr @csec_string_concat(ptr %b2, ptr @.str.local.i32.zero)
  %fallback = call ptr @csec_string_concat(ptr %b3, ptr %storage)
  ret ptr %fallback
}

@.str.local.i32.addr = private unnamed_addr constant [7 x i8] c".addr.\00"
@.str.local.i32.percent = private unnamed_addr constant [2 x i8] c"%\00"
@.str.local.i32.init = private unnamed_addr constant [7 x i8] c".init.\00"
@.str.local.i32.prefix = private unnamed_addr constant [4 x i8] c"  %\00"
@.str.local.i32.alloca = private unnamed_addr constant [15 x i8] c" = alloca i32\0A\00"
@.str.local.i32.store = private unnamed_addr constant [13 x i8] c"  store i32 \00"
@.str.local.i32.to = private unnamed_addr constant [8 x i8] c", ptr %\00"
@.str.local.i32.zero = private unnamed_addr constant [21 x i8] c"  store i32 0, ptr %\00"
)LOCALI32LLVM";
}

std::string llvmGenerateLocalI64Definition() {
    return R"LOCALI64LLVM(define ptr @generateLLVMLocalI64(ptr %arg.tokens, i32 %arg.start, i32 %arg.end) {
entry:
  %initializer = call i32 @findTopLevelOperator(ptr %arg.tokens, i32 %arg.start, i32 %arg.end, i32 1)
  %name.index = add i32 %arg.start, 1
  %name = call ptr @tokenTextAt(ptr %arg.tokens, i32 %name.index)
  %start.i64 = sext i32 %arg.start to i64
  %start.text = call ptr @csec_to_string_i64(i64 %start.i64)
  %storage.a = call ptr @csec_string_concat(ptr %name, ptr @.str.local.i64.addr)
  %storage = call ptr @csec_string_concat(ptr %storage.a, ptr %start.text)
  %init.a = call ptr @csec_string_concat(ptr @.str.local.i64.percent, ptr %name)
  %init.b = call ptr @csec_string_concat(ptr %init.a, ptr @.str.local.i64.init)
  %init = call ptr @csec_string_concat(ptr %init.b, ptr %start.text)
  %has.initializer = icmp sge i32 %initializer, %arg.start
  br i1 %has.initializer, label %with.initializer, label %without.initializer
with.initializer:
  %expr.start = add i32 %initializer, 1
  %expr = call ptr @generateLLVMExpressionI64(ptr %arg.tokens, i32 %expr.start, i32 %arg.end, ptr %init)
  %a1 = call ptr @csec_string_concat(ptr @.str.local.i64.prefix, ptr %storage)
  %a2 = call ptr @csec_string_concat(ptr %a1, ptr @.str.local.i64.alloca)
  %a3 = call ptr @csec_string_concat(ptr %a2, ptr %expr)
  %a4 = call ptr @csec_string_concat(ptr %a3, ptr @.str.local.i64.store)
  %a5 = call ptr @csec_string_concat(ptr %a4, ptr %init)
  %a6 = call ptr @csec_string_concat(ptr %a5, ptr @.str.local.i64.to)
  %result = call ptr @csec_string_concat(ptr %a6, ptr %storage)
  ret ptr %result
without.initializer:
  %b1 = call ptr @csec_string_concat(ptr @.str.local.i64.prefix, ptr %storage)
  %b2 = call ptr @csec_string_concat(ptr %b1, ptr @.str.local.i64.alloca)
  %b3 = call ptr @csec_string_concat(ptr %b2, ptr @.str.local.i64.zero)
  %fallback = call ptr @csec_string_concat(ptr %b3, ptr %storage)
  ret ptr %fallback
}

@.str.local.i64.addr = private unnamed_addr constant [7 x i8] c".addr.\00"
@.str.local.i64.percent = private unnamed_addr constant [2 x i8] c"%\00"
@.str.local.i64.init = private unnamed_addr constant [8 x i8] c".linit.\00"
@.str.local.i64.prefix = private unnamed_addr constant [4 x i8] c"  %\00"
@.str.local.i64.alloca = private unnamed_addr constant [15 x i8] c" = alloca i64\0A\00"
@.str.local.i64.store = private unnamed_addr constant [13 x i8] c"  store i64 \00"
@.str.local.i64.to = private unnamed_addr constant [8 x i8] c", ptr %\00"
@.str.local.i64.zero = private unnamed_addr constant [21 x i8] c"  store i64 0, ptr %\00"
)LOCALI64LLVM";
}

std::string llvmGenerateLocalF64Definition() {
    return R"LOCALF64LLVM(define ptr @generateLLVMLocalF64(ptr %arg.tokens, i32 %arg.start, i32 %arg.end) {
entry:
  %initializer = call i32 @findTopLevelOperator(ptr %arg.tokens, i32 %arg.start, i32 %arg.end, i32 1)
  %name.index = add i32 %arg.start, 1
  %name = call ptr @tokenTextAt(ptr %arg.tokens, i32 %name.index)
  %start.i64 = sext i32 %arg.start to i64
  %start.text = call ptr @csec_to_string_i64(i64 %start.i64)
  %storage.a = call ptr @csec_string_concat(ptr %name, ptr @.str.local.f64.addr)
  %storage = call ptr @csec_string_concat(ptr %storage.a, ptr %start.text)
  %init.a = call ptr @csec_string_concat(ptr @.str.local.f64.percent, ptr %name)
  %init.b = call ptr @csec_string_concat(ptr %init.a, ptr @.str.local.f64.init)
  %init = call ptr @csec_string_concat(ptr %init.b, ptr %start.text)
  %has.initializer = icmp sge i32 %initializer, %arg.start
  br i1 %has.initializer, label %with.initializer, label %without.initializer
with.initializer:
  %expr.start = add i32 %initializer, 1
  %expr = call ptr @generateLLVMExpressionF64(ptr %arg.tokens, i32 %expr.start, i32 %arg.end, ptr %init)
  %a1 = call ptr @csec_string_concat(ptr @.str.local.f64.prefix, ptr %storage)
  %a2 = call ptr @csec_string_concat(ptr %a1, ptr @.str.local.f64.alloca)
  %a3 = call ptr @csec_string_concat(ptr %a2, ptr %expr)
  %a4 = call ptr @csec_string_concat(ptr %a3, ptr @.str.local.f64.store)
  %a5 = call ptr @csec_string_concat(ptr %a4, ptr %init)
  %a6 = call ptr @csec_string_concat(ptr %a5, ptr @.str.local.f64.to)
  %result = call ptr @csec_string_concat(ptr %a6, ptr %storage)
  ret ptr %result
without.initializer:
  %b1 = call ptr @csec_string_concat(ptr @.str.local.f64.prefix, ptr %storage)
  %b2 = call ptr @csec_string_concat(ptr %b1, ptr @.str.local.f64.alloca)
  %b3 = call ptr @csec_string_concat(ptr %b2, ptr @.str.local.f64.zero)
  %fallback = call ptr @csec_string_concat(ptr %b3, ptr %storage)
  ret ptr %fallback
}

@.str.local.f64.addr = private unnamed_addr constant [7 x i8] c".addr.\00"
@.str.local.f64.percent = private unnamed_addr constant [2 x i8] c"%\00"
@.str.local.f64.init = private unnamed_addr constant [8 x i8] c".finit.\00"
@.str.local.f64.prefix = private unnamed_addr constant [4 x i8] c"  %\00"
@.str.local.f64.alloca = private unnamed_addr constant [18 x i8] c" = alloca double\0A\00"
@.str.local.f64.store = private unnamed_addr constant [16 x i8] c"  store double \00"
@.str.local.f64.to = private unnamed_addr constant [8 x i8] c", ptr %\00"
@.str.local.f64.zero = private unnamed_addr constant [35 x i8] c"  store double 0.000000e+00, ptr %\00"
)LOCALF64LLVM";
}

std::string llvmGenerateLocalI8Definition() {
    std::string output = R"(define ptr @generateLLVMLocalI8(ptr %arg.tokens, i32 %arg.start, i32 %arg.end) {
entry:
  %initializer = call i32 @findTopLevelOperator(ptr %arg.tokens, i32 %arg.start, i32 %arg.end, i32 1)
  %name.index = add i32 %arg.start, 1
  %name = call ptr @tokenTextAt(ptr %arg.tokens, i32 %name.index)
  %start.i64 = sext i32 %arg.start to i64
  %start.text = call ptr @csec_to_string_i64(i64 %start.i64)
  %storage.a = call ptr @csec_string_concat(ptr %name, ptr @.str.local.i8.addr)
  %storage = call ptr @csec_string_concat(ptr %storage.a, ptr %start.text)
  %init.a = call ptr @csec_string_concat(ptr @.str.local.i8.percent, ptr %name)
  %init.b = call ptr @csec_string_concat(ptr %init.a, ptr @.str.local.i8.init)
  %init = call ptr @csec_string_concat(ptr %init.b, ptr %start.text)
  %has.initializer = icmp sge i32 %initializer, %arg.start
  br i1 %has.initializer, label %inspect.initializer, label %fallback
inspect.initializer:
  %expr.start.raw = add i32 %initializer, 1
  %expr.start = call i32 @skipTrivia(ptr %arg.tokens, i32 %expr.start.raw)
  %expr.end = call i32 @trimExpressionEnd(ptr %arg.tokens, i32 %expr.start, i32 %arg.end)
  %kind = call i8 @tokenKindAt(ptr %arg.tokens, i32 %expr.start)
  %char.kind = call i8 @kindChar()
  %is.char = icmp eq i8 %kind, %char.kind
  %single.end = add i32 %expr.start, 1
  %is.single = icmp eq i32 %expr.end, %single.end
  %char.literal = and i1 %is.char, %is.single
  br i1 %char.literal, label %char.return, label %identifier.check
char.return:
  %char.text = call ptr @tokenTextAt(ptr %arg.tokens, i32 %expr.start)
  %char.value = call ptr @llvmCharI8Value(ptr %char.text)
  %c1 = call ptr @csec_string_concat(ptr @.str.local.i8.prefix, ptr %storage)
  %c2 = call ptr @csec_string_concat(ptr %c1, ptr @.str.local.i8.alloca)
  %c3 = call ptr @csec_string_concat(ptr %c2, ptr @.str.local.i8.store)
  %c4 = call ptr @csec_string_concat(ptr %c3, ptr %char.value)
  %c5 = call ptr @csec_string_concat(ptr %c4, ptr @.str.local.i8.to)
  %char.result = call ptr @csec_string_concat(ptr %c5, ptr %storage)
  ret ptr %char.result
identifier.check:
  %identifier.kind = call i8 @kindIdentifier()
  %is.identifier = icmp eq i8 %kind, %identifier.kind
  br i1 %is.identifier, label %identifier.single.check, label %fallback
identifier.single.check:
  br i1 %is.single, label %identifier.return, label %charat.check
identifier.return:
  %source.name = call ptr @tokenTextAt(ptr %arg.tokens, i32 %expr.start)
  %source.storage = call ptr @lookupVisibleStorageName(ptr %arg.tokens, i32 %expr.start, ptr %source.name)
  %i1 = call ptr @csec_string_concat(ptr @.str.local.i8.prefix, ptr %storage)
  %i2 = call ptr @csec_string_concat(ptr %i1, ptr @.str.local.i8.alloca)
  %i3 = call ptr @csec_string_concat(ptr %i2, ptr @.str.local.i8.prefix)
  %i4 = call ptr @csec_string_concat(ptr %i3, ptr %init)
  %i5 = call ptr @csec_string_concat(ptr %i4, ptr @.str.local.i8.load)
  %i6 = call ptr @csec_string_concat(ptr %i5, ptr %source.storage)
  %i7 = call ptr @csec_string_concat(ptr %i6, ptr @.str.local.i8.store)
  %i8 = call ptr @csec_string_concat(ptr %i7, ptr %init)
  %i9 = call ptr @csec_string_concat(ptr %i8, ptr @.str.local.i8.to)
  %identifier.result = call ptr @csec_string_concat(ptr %i9, ptr %storage)
  ret ptr %identifier.result
charat.check:
  %dot.index = add i32 %expr.start, 1
  %method.index = add i32 %expr.start, 2
  %open.index = add i32 %expr.start, 3
  %minimum.end = add i32 %expr.start, 4
  %has.charat = icmp slt i32 %minimum.end, %expr.end
  br i1 %has.charat, label %charat.tokens, label %call.check
charat.tokens:
  %operator.kind = call i8 @kindOperator()
  %dot.raw = call i32 @tokenIs(ptr %arg.tokens, i32 %dot.index, i8 %operator.kind, ptr @.str.local.i8.dot)
  %dot = icmp ne i32 %dot.raw, 0
  %method.raw = call i32 @tokenIs(ptr %arg.tokens, i32 %method.index, i8 %identifier.kind, ptr @.str.local.i8.charat)
  %method = icmp ne i32 %method.raw, 0
  %open.raw = call i32 @tokenIs(ptr %arg.tokens, i32 %open.index, i8 %operator.kind, ptr @.str.local.i8.open)
  %open = icmp ne i32 %open.raw, 0
  %charat.a = and i1 %dot, %method
  %charat.b = and i1 %charat.a, %open
  br i1 %charat.b, label %charat.close, label %call.check
charat.close:
  %close = call i32 @findClosingToken(ptr %arg.tokens, i32 %open.index, i32 %expr.end, ptr @.str.local.i8.open, ptr @.str.local.i8.close)
  %last = sub i32 %expr.end, 1
  %is.charat = icmp eq i32 %close, %last
  br i1 %is.charat, label %charat.return, label %call.check
charat.return:
  %object.name = call ptr @tokenTextAt(ptr %arg.tokens, i32 %expr.start)
  %object.storage = call ptr @lookupVisibleStorageName(ptr %arg.tokens, i32 %expr.start, ptr %object.name)
  %index.start = add i32 %expr.start, 4
  %index.a = call ptr @csec_string_concat(ptr %init, ptr @.str.local.i8.index)
  %index.code = call ptr @generateLLVMExpressionI32(ptr %arg.tokens, i32 %index.start, i32 %last, ptr %index.a)
  %o1 = call ptr @csec_string_concat(ptr @.str.local.i8.prefix, ptr %storage)
  %o2 = call ptr @csec_string_concat(ptr %o1, ptr @.str.local.i8.alloca)
  %o3 = call ptr @csec_string_concat(ptr %o2, ptr @.str.local.i8.prefix)
  %o4 = call ptr @csec_string_concat(ptr %o3, ptr %init)
  %o5 = call ptr @csec_string_concat(ptr %o4, ptr @.str.local.i8.object.load)
  %o6 = call ptr @csec_string_concat(ptr %o5, ptr %object.storage)
  %o7 = call ptr @csec_string_concat(ptr %o6, ptr %index.code)
  %o8 = call ptr @csec_string_concat(ptr %o7, ptr @.str.local.i8.prefix)
  %o9 = call ptr @csec_string_concat(ptr %o8, ptr %init)
  %o10 = call ptr @csec_string_concat(ptr %o9, ptr @.str.local.i8.call.prefix)
  %object.value = call ptr @csec_string_concat(ptr %init, ptr @.str.local.i8.object)
  %o11 = call ptr @csec_string_concat(ptr %o10, ptr %object.value)
  %o12 = call ptr @csec_string_concat(ptr %o11, ptr @.str.local.i8.call.middle)
  %o13 = call ptr @csec_string_concat(ptr %o12, ptr %index.a)
  %o14 = call ptr @csec_string_concat(ptr %o13, ptr @.str.local.i8.close)
  %o15 = call ptr @csec_string_concat(ptr %o14, ptr @.str.local.i8.store)
  %o16 = call ptr @csec_string_concat(ptr %o15, ptr %init)
  %o17 = call ptr @csec_string_concat(ptr %o16, ptr @.str.local.i8.to)
  %charat.result = call ptr @csec_string_concat(ptr %o17, ptr %storage)
  ret ptr %charat.result
call.check:
  %call.open.index = add i32 %expr.start, 1
  %call.before.end = icmp slt i32 %call.open.index, %expr.end
  br i1 %call.before.end, label %call.open.check, label %fallback
call.open.check:
  %operator.kind.call = call i8 @kindOperator()
  %call.open.raw = call i32 @tokenIs(ptr %arg.tokens, i32 %call.open.index, i8 %operator.kind.call, ptr @.str.local.i8.open)
  %call.open = icmp ne i32 %call.open.raw, 0
  br i1 %call.open, label %call.close.check, label %fallback
call.close.check:
  %call.close = call i32 @findClosingToken(ptr %arg.tokens, i32 %call.open.index, i32 %expr.end, ptr @.str.local.i8.open, ptr @.str.local.i8.close)
  %call.last = sub i32 %expr.end, 1
  %is.call = icmp eq i32 %call.close, %call.last
  br i1 %is.call, label %call.return, label %fallback
call.return:
  %callee = call ptr @tokenTextAt(ptr %arg.tokens, i32 %expr.start)
  %args.start = add i32 %expr.start, 2
  %args.loads = call ptr @generateLLVMCallArgumentLoadsI32(ptr %arg.tokens, i32 %args.start, i32 %call.last, ptr %init)
  %args.list = call ptr @generateLLVMCallArgumentListI32(ptr %arg.tokens, i32 %args.start, i32 %call.last, ptr %init)
  %callee.native = call ptr @llvmRuntimeCallName(ptr %callee)
  %q1 = call ptr @csec_string_concat(ptr @.str.local.i8.prefix, ptr %storage)
  %q2 = call ptr @csec_string_concat(ptr %q1, ptr @.str.local.i8.alloca)
  %q3 = call ptr @csec_string_concat(ptr %q2, ptr %args.loads)
  %q4 = call ptr @csec_string_concat(ptr %q3, ptr @.str.local.i8.prefix)
  %q5 = call ptr @csec_string_concat(ptr %q4, ptr %init)
  %q6 = call ptr @csec_string_concat(ptr %q5, ptr @.str.local.i8.call.at)
  %q7 = call ptr @csec_string_concat(ptr %q6, ptr %callee.native)
  %q8 = call ptr @csec_string_concat(ptr %q7, ptr @.str.local.i8.open)
  %q9 = call ptr @csec_string_concat(ptr %q8, ptr %args.list)
  %q10 = call ptr @csec_string_concat(ptr %q9, ptr @.str.local.i8.close)
  %q11 = call ptr @csec_string_concat(ptr %q10, ptr @.str.local.i8.store)
  %q12 = call ptr @csec_string_concat(ptr %q11, ptr %init)
  %q13 = call ptr @csec_string_concat(ptr %q12, ptr @.str.local.i8.to)
  %call.result = call ptr @csec_string_concat(ptr %q13, ptr %storage)
  ret ptr %call.result
fallback:
  %f1 = call ptr @csec_string_concat(ptr @.str.local.i8.prefix, ptr %storage)
  %f2 = call ptr @csec_string_concat(ptr %f1, ptr @.str.local.i8.alloca)
  %f3 = call ptr @csec_string_concat(ptr %f2, ptr @.str.local.i8.zero)
  %fallback.result = call ptr @csec_string_concat(ptr %f3, ptr %storage)
  ret ptr %fallback.result
}

)";
    output += llvmStringGlobal(".str.local.i8.addr", ".addr.");
    output += llvmStringGlobal(".str.local.i8.percent", "%");
    output += llvmStringGlobal(".str.local.i8.init", ".cinit.");
    output += llvmStringGlobal(".str.local.i8.prefix", "  %");
    output += llvmStringGlobal(".str.local.i8.alloca", " = alloca i8\n");
    output += llvmStringGlobal(".str.local.i8.store", "  store i8 ");
    output += llvmStringGlobal(".str.local.i8.to", ", ptr %");
    output += llvmStringGlobal(".str.local.i8.zero", "  store i8 0, ptr %");
    output += llvmStringGlobal(".str.local.i8.load", " = load i8, ptr %");
    output += llvmStringGlobal(".str.local.i8.dot", ".");
    output += llvmStringGlobal(".str.local.i8.charat", "charAt");
    output += llvmStringGlobal(".str.local.i8.open", "(");
    output += llvmStringGlobal(".str.local.i8.close", ")");
    output += llvmStringGlobal(".str.local.i8.index", ".index");
    output += llvmStringGlobal(".str.local.i8.object", ".obj");
    output += llvmStringGlobal(".str.local.i8.object.load", " = load ptr, ptr %");
    output += llvmStringGlobal(".str.local.i8.call.prefix", " = call i8 @csec_string_char_at(ptr ");
    output += llvmStringGlobal(".str.local.i8.call.middle", ", i32 ");
    output += llvmStringGlobal(".str.local.i8.call.at", " = call i8 @");
    return output;
}

std::string llvmGenerateLocalI1Definition() {
    std::string output = R"(define ptr @generateLLVMLocalI1(ptr %arg.tokens, i32 %arg.start, i32 %arg.end) {
entry:
  %initializer = call i32 @findTopLevelOperator(ptr %arg.tokens, i32 %arg.start, i32 %arg.end, i32 1)
  %name.index = add i32 %arg.start, 1
  %name = call ptr @tokenTextAt(ptr %arg.tokens, i32 %name.index)
  %start.i64 = sext i32 %arg.start to i64
  %start.text = call ptr @csec_to_string_i64(i64 %start.i64)
  %storage.a = call ptr @csec_string_concat(ptr %name, ptr @.str.local.i1.addr)
  %storage = call ptr @csec_string_concat(ptr %storage.a, ptr %start.text)
  %init.a = call ptr @csec_string_concat(ptr @.str.local.i1.percent, ptr %name)
  %init.b = call ptr @csec_string_concat(ptr %init.a, ptr @.str.local.i1.init)
  %init = call ptr @csec_string_concat(ptr %init.b, ptr %start.text)
  %has.initializer = icmp sge i32 %initializer, %arg.start
  br i1 %has.initializer, label %with.initializer, label %without.initializer
with.initializer:
  %expr.start = add i32 %initializer, 1
  %expr = call ptr @generateLLVMExpressionI1(ptr %arg.tokens, i32 %expr.start, i32 %arg.end, ptr %init)
  %a1 = call ptr @csec_string_concat(ptr @.str.local.i1.prefix, ptr %storage)
  %a2 = call ptr @csec_string_concat(ptr %a1, ptr @.str.local.i1.alloca)
  %a3 = call ptr @csec_string_concat(ptr %a2, ptr %expr)
  %a4 = call ptr @csec_string_concat(ptr %a3, ptr @.str.local.i1.store)
  %a5 = call ptr @csec_string_concat(ptr %a4, ptr %init)
  %a6 = call ptr @csec_string_concat(ptr %a5, ptr @.str.local.i1.to)
  %result = call ptr @csec_string_concat(ptr %a6, ptr %storage)
  ret ptr %result
without.initializer:
  %b1 = call ptr @csec_string_concat(ptr @.str.local.i1.prefix, ptr %storage)
  %b2 = call ptr @csec_string_concat(ptr %b1, ptr @.str.local.i1.alloca)
  %b3 = call ptr @csec_string_concat(ptr %b2, ptr @.str.local.i1.false)
  %fallback = call ptr @csec_string_concat(ptr %b3, ptr %storage)
  ret ptr %fallback
}

)";
    output += llvmStringGlobal(".str.local.i1.addr", ".addr.");
    output += llvmStringGlobal(".str.local.i1.percent", "%");
    output += llvmStringGlobal(".str.local.i1.init", ".binit.");
    output += llvmStringGlobal(".str.local.i1.prefix", "  %");
    output += llvmStringGlobal(".str.local.i1.alloca", " = alloca i1\n");
    output += llvmStringGlobal(".str.local.i1.store", "  store i1 ");
    output += llvmStringGlobal(".str.local.i1.to", ", ptr %");
    output += llvmStringGlobal(".str.local.i1.false", "  store i1 false, ptr %");
    return output;
}

std::string llvmGenerateExpressionI32Definition() {
    std::string output = R"(define ptr @generateLLVMExpressionI32(ptr %arg.tokens, i32 %arg.start, i32 %arg.rawEnd, ptr %arg.resultName) {
entry:
  %end = call i32 @trimExpressionEnd(ptr %arg.tokens, i32 %arg.start, i32 %arg.rawEnd)
  %empty = icmp sle i32 %end, %arg.start
  br i1 %empty, label %zero.return, label %integer.check
zero.return:
  %z1 = call ptr @csec_string_concat(ptr @.str.expr.i32.prefix, ptr %arg.resultName)
  %zero.result = call ptr @csec_string_concat(ptr %z1, ptr @.str.expr.i32.zero)
  ret ptr %zero.result
integer.check:
  %kind = call i8 @tokenKindAt(ptr %arg.tokens, i32 %arg.start)
  %integer.kind = call i8 @kindInteger()
  %is.integer = icmp eq i8 %kind, %integer.kind
  %single.end = add i32 %arg.start, 1
  %single = icmp eq i32 %end, %single.end
  %integer = and i1 %is.integer, %single
  br i1 %integer, label %integer.return, label %char.check
integer.return:
  %integer.text = call ptr @tokenTextAt(ptr %arg.tokens, i32 %arg.start)
  %i1 = call ptr @csec_string_concat(ptr @.str.expr.i32.prefix, ptr %arg.resultName)
  %i2 = call ptr @csec_string_concat(ptr %i1, ptr @.str.expr.i32.add)
  %integer.result = call ptr @csec_string_concat(ptr %i2, ptr %integer.text)
  ret ptr %integer.result
char.check:
  %char.kind = call i8 @kindChar()
  %is.char = icmp eq i8 %kind, %char.kind
  %char = and i1 %is.char, %single
  br i1 %char, label %char.return, label %identifier.check
char.return:
  %char.text = call ptr @tokenTextAt(ptr %arg.tokens, i32 %arg.start)
  %char.value = call ptr @llvmCharI8Value(ptr %char.text)
  %c1 = call ptr @csec_string_concat(ptr @.str.expr.i32.prefix, ptr %arg.resultName)
  %c2 = call ptr @csec_string_concat(ptr %c1, ptr @.str.expr.i32.add)
  %char.result = call ptr @csec_string_concat(ptr %c2, ptr %char.value)
  ret ptr %char.result
identifier.check:
  %identifier.kind = call i8 @kindIdentifier()
  %is.identifier = icmp eq i8 %kind, %identifier.kind
  br i1 %is.identifier, label %identifier.next, label %operator.find
identifier.next:
  %name = call ptr @tokenTextAt(ptr %arg.tokens, i32 %arg.start)
  br i1 %single, label %identifier.return, label %length.check
identifier.return:
  %value.type = call ptr @lookupVisibleValueType(ptr %arg.tokens, i32 %arg.start, ptr %name)
  %is.char.type = call i1 @strEq(ptr %value.type, ptr @.str.expr.i32.char)
  br i1 %is.char.type, label %identifier.char, label %identifier.i32
identifier.char:
  %storage.char = call ptr @lookupVisibleStorageName(ptr %arg.tokens, i32 %arg.start, ptr %name)
  %h1 = call ptr @csec_string_concat(ptr @.str.expr.i32.prefix, ptr %arg.resultName)
  %h2 = call ptr @csec_string_concat(ptr %h1, ptr @.str.expr.i32.char.load)
  %h3 = call ptr @csec_string_concat(ptr %h2, ptr %storage.char)
  %h4 = call ptr @csec_string_concat(ptr %h3, ptr @.str.expr.i32.prefix)
  %h5 = call ptr @csec_string_concat(ptr %h4, ptr %arg.resultName)
  %h6 = call ptr @csec_string_concat(ptr %h5, ptr @.str.expr.i32.zext)
  %h7 = call ptr @csec_string_concat(ptr %h6, ptr %arg.resultName)
  %identifier.char.result = call ptr @csec_string_concat(ptr %h7, ptr @.str.expr.i32.char.to.i32)
  ret ptr %identifier.char.result
identifier.i32:
  %storage.i32 = call ptr @lookupVisibleStorageName(ptr %arg.tokens, i32 %arg.start, ptr %name)
  %j1 = call ptr @csec_string_concat(ptr @.str.expr.i32.prefix, ptr %arg.resultName)
  %j2 = call ptr @csec_string_concat(ptr %j1, ptr @.str.expr.i32.i32.load)
  %identifier.i32.result = call ptr @csec_string_concat(ptr %j2, ptr %storage.i32)
  ret ptr %identifier.i32.result
length.check:
  %dot.index = add i32 %arg.start, 1
  %length.index = add i32 %arg.start, 2
  %operator.kind = call i8 @kindOperator()
  %dot.raw = call i32 @tokenIs(ptr %arg.tokens, i32 %dot.index, i8 %operator.kind, ptr @.str.expr.i32.dot)
  %dot = icmp ne i32 %dot.raw, 0
  %length.raw = call i32 @tokenIs(ptr %arg.tokens, i32 %length.index, i8 %identifier.kind, ptr @.str.expr.i32.length)
  %length = icmp ne i32 %length.raw, 0
  %is.length = and i1 %dot, %length
  br i1 %is.length, label %length.return, label %charat.check
length.return:
  %length.storage = call ptr @lookupVisibleStorageName(ptr %arg.tokens, i32 %arg.start, ptr %name)
  %l1 = call ptr @csec_string_concat(ptr @.str.expr.i32.prefix, ptr %arg.resultName)
  %l2 = call ptr @csec_string_concat(ptr %l1, ptr @.str.expr.i32.object.load)
  %l3 = call ptr @csec_string_concat(ptr %l2, ptr %length.storage)
  %l4 = call ptr @csec_string_concat(ptr %l3, ptr @.str.expr.i32.prefix)
  %l5 = call ptr @csec_string_concat(ptr %l4, ptr %arg.resultName)
  %l6 = call ptr @csec_string_concat(ptr %l5, ptr @.str.expr.i32.length.call)
  %object.name = call ptr @csec_string_concat(ptr %arg.resultName, ptr @.str.expr.i32.object)
  %l7 = call ptr @csec_string_concat(ptr %l6, ptr %object.name)
  %l8 = call ptr @csec_string_concat(ptr %l7, ptr @.str.expr.i32.prefix)
  %l9 = call ptr @csec_string_concat(ptr %l8, ptr %arg.resultName)
  %l10 = call ptr @csec_string_concat(ptr %l9, ptr @.str.expr.i32.trunc)
  %l11 = call ptr @csec_string_concat(ptr %l10, ptr %arg.resultName)
  %length.result = call ptr @csec_string_concat(ptr %l11, ptr @.str.expr.i32.i64.to.i32)
  ret ptr %length.result
charat.check:
  %open.index = add i32 %arg.start, 3
  %minimum.end = add i32 %arg.start, 4
  %has.charat = icmp slt i32 %minimum.end, %end
  br i1 %has.charat, label %charat.tokens, label %call.check
charat.tokens:
  %charat.raw = call i32 @tokenIs(ptr %arg.tokens, i32 %length.index, i8 %identifier.kind, ptr @.str.expr.i32.charat)
  %charat = icmp ne i32 %charat.raw, 0
  %open.raw = call i32 @tokenIs(ptr %arg.tokens, i32 %open.index, i8 %operator.kind, ptr @.str.expr.i32.open)
  %open = icmp ne i32 %open.raw, 0
  %charat.a = and i1 %dot, %charat
  %charat.b = and i1 %charat.a, %open
  br i1 %charat.b, label %charat.close, label %call.check
charat.close:
  %close = call i32 @findClosingToken(ptr %arg.tokens, i32 %open.index, i32 %end, ptr @.str.expr.i32.open, ptr @.str.expr.i32.close)
  %last = sub i32 %end, 1
  %is.charat = icmp eq i32 %close, %last
  br i1 %is.charat, label %charat.return, label %call.check
charat.return:
  %charat.storage = call ptr @lookupVisibleStorageName(ptr %arg.tokens, i32 %arg.start, ptr %name)
  %index.start = add i32 %arg.start, 4
  %index.name = call ptr @csec_string_concat(ptr %arg.resultName, ptr @.str.expr.i32.index)
  %index.code = call ptr @generateLLVMExpressionI32(ptr %arg.tokens, i32 %index.start, i32 %last, ptr %index.name)
  %q1 = call ptr @csec_string_concat(ptr @.str.expr.i32.prefix, ptr %arg.resultName)
  %q2 = call ptr @csec_string_concat(ptr %q1, ptr @.str.expr.i32.object.load)
  %q3 = call ptr @csec_string_concat(ptr %q2, ptr %charat.storage)
  %q4 = call ptr @csec_string_concat(ptr %q3, ptr %index.code)
  %q5 = call ptr @csec_string_concat(ptr %q4, ptr @.str.expr.i32.prefix)
  %q6 = call ptr @csec_string_concat(ptr %q5, ptr %arg.resultName)
  %q7 = call ptr @csec_string_concat(ptr %q6, ptr @.str.expr.i32.charat.call)
  %object.name.charat = call ptr @csec_string_concat(ptr %arg.resultName, ptr @.str.expr.i32.object)
  %q8 = call ptr @csec_string_concat(ptr %q7, ptr %object.name.charat)
  %q9 = call ptr @csec_string_concat(ptr %q8, ptr @.str.expr.i32.charat.middle)
  %q10 = call ptr @csec_string_concat(ptr %q9, ptr %index.name)
  %q11 = call ptr @csec_string_concat(ptr %q10, ptr @.str.expr.i32.close)
  %q12 = call ptr @csec_string_concat(ptr %q11, ptr @.str.expr.i32.prefix)
  %q13 = call ptr @csec_string_concat(ptr %q12, ptr %arg.resultName)
  %q14 = call ptr @csec_string_concat(ptr %q13, ptr @.str.expr.i32.zext)
  %q15 = call ptr @csec_string_concat(ptr %q14, ptr %arg.resultName)
  %charat.result = call ptr @csec_string_concat(ptr %q15, ptr @.str.expr.i32.i8.to.i32)
  ret ptr %charat.result
call.check:
  %call.open.index = add i32 %arg.start, 1
  %call.before.end = icmp slt i32 %call.open.index, %end
  br i1 %call.before.end, label %call.open.check, label %operator.find
call.open.check:
  %call.open.raw = call i32 @tokenIs(ptr %arg.tokens, i32 %call.open.index, i8 %operator.kind, ptr @.str.expr.i32.open)
  %call.open = icmp ne i32 %call.open.raw, 0
  br i1 %call.open, label %call.close.check, label %operator.find
call.close.check:
  %call.close = call i32 @findClosingToken(ptr %arg.tokens, i32 %call.open.index, i32 %end, ptr @.str.expr.i32.open, ptr @.str.expr.i32.close)
  %call.last = sub i32 %end, 1
  %is.call = icmp eq i32 %call.close, %call.last
  br i1 %is.call, label %call.return, label %operator.find
call.return:
  %callee = call ptr @tokenTextAt(ptr %arg.tokens, i32 %arg.start)
  %args.start = add i32 %arg.start, 2
  %loads = call ptr @generateLLVMCallArgumentLoadsI32(ptr %arg.tokens, i32 %args.start, i32 %call.last, ptr %arg.resultName)
  %arguments = call ptr @generateLLVMCallArgumentListI32(ptr %arg.tokens, i32 %args.start, i32 %call.last, ptr %arg.resultName)
  %native.callee = call ptr @llvmRuntimeCallName(ptr %callee)
  %r1 = call ptr @csec_string_concat(ptr %loads, ptr @.str.expr.i32.prefix)
  %r2 = call ptr @csec_string_concat(ptr %r1, ptr %arg.resultName)
  %r3 = call ptr @csec_string_concat(ptr %r2, ptr @.str.expr.i32.call.i32)
  %r4 = call ptr @csec_string_concat(ptr %r3, ptr %native.callee)
  %r5 = call ptr @csec_string_concat(ptr %r4, ptr @.str.expr.i32.open)
  %r6 = call ptr @csec_string_concat(ptr %r5, ptr %arguments)
  %call.result = call ptr @csec_string_concat(ptr %r6, ptr @.str.expr.i32.close.nl)
  ret ptr %call.result
operator.find:
  %op = call i32 @expressionTopLevelOperator(ptr %arg.tokens, i32 %arg.start, i32 %end)
  %has.op = icmp sgt i32 %op, %arg.start
  br i1 %has.op, label %operator.return, label %zero.return
operator.return:
  %op.text = call ptr @tokenTextAt(ptr %arg.tokens, i32 %op)
  %mnemonic = call ptr @irOperatorName(ptr %op.text)
  %left.name = call ptr @csec_string_concat(ptr %arg.resultName, ptr @.str.expr.i32.left)
  %left = call ptr @generateLLVMExpressionI32(ptr %arg.tokens, i32 %arg.start, i32 %op, ptr %left.name)
  %right.start = add i32 %op, 1
  %right.name = call ptr @csec_string_concat(ptr %arg.resultName, ptr @.str.expr.i32.right)
  %right = call ptr @generateLLVMExpressionI32(ptr %arg.tokens, i32 %right.start, i32 %end, ptr %right.name)
  %b1 = call ptr @csec_string_concat(ptr %left, ptr %right)
  %b2 = call ptr @csec_string_concat(ptr %b1, ptr @.str.expr.i32.prefix)
  %b3 = call ptr @csec_string_concat(ptr %b2, ptr %arg.resultName)
  %b4 = call ptr @csec_string_concat(ptr %b3, ptr @.str.expr.i32.operator.prefix)
  %b5 = call ptr @csec_string_concat(ptr %b4, ptr %mnemonic)
  %b6 = call ptr @csec_string_concat(ptr %b5, ptr @.str.expr.i32.operator.middle)
  %b7 = call ptr @csec_string_concat(ptr %b6, ptr %left.name)
  %b8 = call ptr @csec_string_concat(ptr %b7, ptr @.str.expr.i32.operator.comma)
  %binary.result = call ptr @csec_string_concat(ptr %b8, ptr %right.name)
  ret ptr %binary.result
}

)";
    output += llvmStringGlobal(".str.expr.i32.prefix", "  ");
    output += llvmStringGlobal(".str.expr.i32.zero", " = add i32 0, 0\n");
    output += llvmStringGlobal(".str.expr.i32.add", " = add i32 0, ");
    output += llvmStringGlobal(".str.expr.i32.char", "Char");
    output += llvmStringGlobal(".str.expr.i32.char.load", " = load i8, ptr %");
    output += llvmStringGlobal(".str.expr.i32.zext", " = zext i8 ");
    output += llvmStringGlobal(".str.expr.i32.char.to.i32", ".c to i32\n");
    output += llvmStringGlobal(".str.expr.i32.i32.load", " = load i32, ptr %");
    output += llvmStringGlobal(".str.expr.i32.dot", ".");
    output += llvmStringGlobal(".str.expr.i32.length", "length");
    output += llvmStringGlobal(".str.expr.i32.charat", "charAt");
    output += llvmStringGlobal(".str.expr.i32.open", "(");
    output += llvmStringGlobal(".str.expr.i32.close", ")");
    output += llvmStringGlobal(".str.expr.i32.close.nl", ")\n");
    output += llvmStringGlobal(".str.expr.i32.object", ".obj");
    output += llvmStringGlobal(".str.expr.i32.index", ".index");
    output += llvmStringGlobal(".str.expr.i32.object.load", " = load ptr, ptr %");
    output += llvmStringGlobal(".str.expr.i32.length.call", " = call i64 @csec_string_length(ptr ");
    output += llvmStringGlobal(".str.expr.i32.trunc", " = trunc i64 ");
    output += llvmStringGlobal(".str.expr.i32.i64.to.i32", ".i64 to i32\n");
    output += llvmStringGlobal(".str.expr.i32.charat.call", " = call i8 @csec_string_char_at(ptr ");
    output += llvmStringGlobal(".str.expr.i32.charat.middle", ", i32 ");
    output += llvmStringGlobal(".str.expr.i32.i8.to.i32", ".i8 to i32\n");
    output += llvmStringGlobal(".str.expr.i32.call.i32", " = call i32 @");
    output += llvmStringGlobal(".str.expr.i32.left", ".left");
    output += llvmStringGlobal(".str.expr.i32.right", ".right");
    output += llvmStringGlobal(".str.expr.i32.operator.prefix", " = ");
    output += llvmStringGlobal(".str.expr.i32.operator.middle", " i32 ");
    output += llvmStringGlobal(".str.expr.i32.operator.comma", ", ");
    return output;
}

std::string llvmGenerateExpressionI64Definition() {
    std::string output = R"(define ptr @generateLLVMExpressionI64(ptr %arg.tokens, i32 %arg.start, i32 %arg.rawEnd, ptr %arg.resultName) {
entry:
  %end = call i32 @trimExpressionEnd(ptr %arg.tokens, i32 %arg.start, i32 %arg.rawEnd)
  %empty = icmp sle i32 %end, %arg.start
  br i1 %empty, label %zero.return, label %integer.check
zero.return:
  %z1 = call ptr @csec_string_concat(ptr @.str.expr.i64.prefix, ptr %arg.resultName)
  %zero.result = call ptr @csec_string_concat(ptr %z1, ptr @.str.expr.i64.zero)
  ret ptr %zero.result
integer.check:
  %kind = call i8 @tokenKindAt(ptr %arg.tokens, i32 %arg.start)
  %integer.kind = call i8 @kindInteger()
  %is.integer = icmp eq i8 %kind, %integer.kind
  %single.end = add i32 %arg.start, 1
  %single = icmp eq i32 %end, %single.end
  %integer = and i1 %is.integer, %single
  br i1 %integer, label %integer.return, label %identifier.check
integer.return:
  %integer.text = call ptr @tokenTextAt(ptr %arg.tokens, i32 %arg.start)
  %i1 = call ptr @csec_string_concat(ptr @.str.expr.i64.prefix, ptr %arg.resultName)
  %i2 = call ptr @csec_string_concat(ptr %i1, ptr @.str.expr.i64.add)
  %integer.result = call ptr @csec_string_concat(ptr %i2, ptr %integer.text)
  ret ptr %integer.result
identifier.check:
  %identifier.kind = call i8 @kindIdentifier()
  %is.identifier = icmp eq i8 %kind, %identifier.kind
  br i1 %is.identifier, label %identifier.next, label %operator.find
identifier.next:
  %name = call ptr @tokenTextAt(ptr %arg.tokens, i32 %arg.start)
  br i1 %single, label %identifier.return, label %call.check
identifier.return:
  %storage = call ptr @lookupVisibleStorageName(ptr %arg.tokens, i32 %arg.start, ptr %name)
  %n1 = call ptr @csec_string_concat(ptr @.str.expr.i64.prefix, ptr %arg.resultName)
  %n2 = call ptr @csec_string_concat(ptr %n1, ptr @.str.expr.i64.load)
  %identifier.result = call ptr @csec_string_concat(ptr %n2, ptr %storage)
  ret ptr %identifier.result
call.check:
  %open.index = add i32 %arg.start, 1
  %before.end = icmp slt i32 %open.index, %end
  br i1 %before.end, label %open.check, label %operator.find
open.check:
  %operator.kind = call i8 @kindOperator()
  %open.raw = call i32 @tokenIs(ptr %arg.tokens, i32 %open.index, i8 %operator.kind, ptr @.str.expr.i64.open)
  %open = icmp ne i32 %open.raw, 0
  br i1 %open, label %close.check, label %operator.find
close.check:
  %close = call i32 @findClosingToken(ptr %arg.tokens, i32 %open.index, i32 %end, ptr @.str.expr.i64.open, ptr @.str.expr.i64.close)
  %last = sub i32 %end, 1
  %is.call = icmp eq i32 %close, %last
  br i1 %is.call, label %call.return, label %operator.find
call.return:
  %args.start = add i32 %arg.start, 2
  %loads = call ptr @generateLLVMCallArgumentLoadsI32(ptr %arg.tokens, i32 %args.start, i32 %last, ptr %arg.resultName)
  %arguments = call ptr @generateLLVMCallArgumentListI32(ptr %arg.tokens, i32 %args.start, i32 %last, ptr %arg.resultName)
  %callee = call ptr @llvmRuntimeCallName(ptr %name)
  %c1 = call ptr @csec_string_concat(ptr %loads, ptr @.str.expr.i64.prefix)
  %c2 = call ptr @csec_string_concat(ptr %c1, ptr %arg.resultName)
  %c3 = call ptr @csec_string_concat(ptr %c2, ptr @.str.expr.i64.call)
  %c4 = call ptr @csec_string_concat(ptr %c3, ptr %callee)
  %c5 = call ptr @csec_string_concat(ptr %c4, ptr @.str.expr.i64.open)
  %c6 = call ptr @csec_string_concat(ptr %c5, ptr %arguments)
  %call.result = call ptr @csec_string_concat(ptr %c6, ptr @.str.expr.i64.close.nl)
  ret ptr %call.result
operator.find:
  %op = call i32 @expressionTopLevelOperator(ptr %arg.tokens, i32 %arg.start, i32 %end)
  %has.op = icmp sgt i32 %op, %arg.start
  br i1 %has.op, label %operator.return, label %zero.return
operator.return:
  %op.text = call ptr @tokenTextAt(ptr %arg.tokens, i32 %op)
  %mnemonic = call ptr @irOperatorName(ptr %op.text)
  %left.name = call ptr @csec_string_concat(ptr %arg.resultName, ptr @.str.expr.i64.left)
  %left = call ptr @generateLLVMExpressionI64(ptr %arg.tokens, i32 %arg.start, i32 %op, ptr %left.name)
  %right.start = add i32 %op, 1
  %right.name = call ptr @csec_string_concat(ptr %arg.resultName, ptr @.str.expr.i64.right)
  %right = call ptr @generateLLVMExpressionI64(ptr %arg.tokens, i32 %right.start, i32 %end, ptr %right.name)
  %b1 = call ptr @csec_string_concat(ptr %left, ptr %right)
  %b2 = call ptr @csec_string_concat(ptr %b1, ptr @.str.expr.i64.prefix)
  %b3 = call ptr @csec_string_concat(ptr %b2, ptr %arg.resultName)
  %b4 = call ptr @csec_string_concat(ptr %b3, ptr @.str.expr.i64.operator.prefix)
  %b5 = call ptr @csec_string_concat(ptr %b4, ptr %mnemonic)
  %b6 = call ptr @csec_string_concat(ptr %b5, ptr @.str.expr.i64.operator.middle)
  %b7 = call ptr @csec_string_concat(ptr %b6, ptr %left.name)
  %b8 = call ptr @csec_string_concat(ptr %b7, ptr @.str.expr.i64.operator.comma)
  %binary.result = call ptr @csec_string_concat(ptr %b8, ptr %right.name)
  ret ptr %binary.result
}

)";
    output += llvmStringGlobal(".str.expr.i64.prefix", "  ");
    output += llvmStringGlobal(".str.expr.i64.zero", " = add i64 0, 0\n");
    output += llvmStringGlobal(".str.expr.i64.add", " = add i64 0, ");
    output += llvmStringGlobal(".str.expr.i64.load", " = load i64, ptr %");
    output += llvmStringGlobal(".str.expr.i64.open", "(");
    output += llvmStringGlobal(".str.expr.i64.close", ")");
    output += llvmStringGlobal(".str.expr.i64.close.nl", ")\n");
    output += llvmStringGlobal(".str.expr.i64.call", " = call i64 @");
    output += llvmStringGlobal(".str.expr.i64.left", ".left");
    output += llvmStringGlobal(".str.expr.i64.right", ".right");
    output += llvmStringGlobal(".str.expr.i64.operator.prefix", " = ");
    output += llvmStringGlobal(".str.expr.i64.operator.middle", " i64 ");
    output += llvmStringGlobal(".str.expr.i64.operator.comma", ", ");
    return output;
}

