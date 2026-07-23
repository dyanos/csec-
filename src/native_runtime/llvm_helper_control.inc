std::string llvmBlockEndsWithTopLevelReturnDefinition() {
    std::string output = R"(define i1 @llvmBlockEndsWithTopLevelReturn(ptr %arg.tokens, i32 %arg.bodyStart, i32 %arg.bodyEnd) {
entry:
  %first = call i32 @skipTrivia(ptr %arg.tokens, i32 %arg.bodyStart)
  br label %loop
loop:
  %cursor = phi i32 [ %first, %entry ], [ %next.cursor, %body ]
  %result = phi i1 [ false, %entry ], [ %is.return, %body ]
  %before.end = icmp slt i32 %cursor, %arg.bodyEnd
  br i1 %before.end, label %eof.check, label %done
eof.check:
  %kind = call i8 @tokenKindAt(ptr %arg.tokens, i32 %cursor)
  %eof.kind = call i8 @kindEof()
  %is.eof = icmp eq i8 %kind, %eof.kind
  br i1 %is.eof, label %done, label %body
body:
  %next = call i32 @advanceStatement(ptr %arg.tokens, i32 %cursor, i32 %arg.bodyEnd)
  %statement = call ptr @statementKind(ptr %arg.tokens, i32 %cursor)
  %is.return = call i1 @strEq(ptr %statement, ptr @.str.block.return)
  %next.cursor = call i32 @skipTrivia(ptr %arg.tokens, i32 %next)
  br label %loop
done:
  ret i1 %result
}

)";
    output += llvmStringGlobal(".str.block.return", "return");
    return output;
}

std::string llvmGenerateExpressionF64Definition() {
    std::string output = R"(define ptr @generateLLVMExpressionF64(ptr %arg.tokens, i32 %arg.start, i32 %arg.rawEnd, ptr %arg.resultName) {
entry:
  %end = call i32 @trimExpressionEnd(ptr %arg.tokens, i32 %arg.start, i32 %arg.rawEnd)
  %empty = icmp sle i32 %end, %arg.start
  br i1 %empty, label %zero.return, label %literal.check
zero.return:
  %z1 = call ptr @csec_string_concat(ptr @.str.expr.f64.prefix, ptr %arg.resultName)
  %zero.result = call ptr @csec_string_concat(ptr %z1, ptr @.str.expr.f64.zero)
  ret ptr %zero.result
literal.check:
  %kind = call i8 @tokenKindAt(ptr %arg.tokens, i32 %arg.start)
  %float.kind = call i8 @kindFloat()
  %is.float = icmp eq i8 %kind, %float.kind
  %integer.kind = call i8 @kindInteger()
  %is.integer = icmp eq i8 %kind, %integer.kind
  %number = or i1 %is.float, %is.integer
  %single.end = add i32 %arg.start, 1
  %single = icmp eq i32 %end, %single.end
  %literal = and i1 %number, %single
  br i1 %literal, label %literal.return, label %identifier.check
literal.return:
  %text = call ptr @tokenTextAt(ptr %arg.tokens, i32 %arg.start)
  %l1 = call ptr @csec_string_concat(ptr @.str.expr.f64.prefix, ptr %arg.resultName)
  %l2 = call ptr @csec_string_concat(ptr %l1, ptr @.str.expr.f64.fadd)
  %literal.result = call ptr @csec_string_concat(ptr %l2, ptr %text)
  ret ptr %literal.result
identifier.check:
  %identifier.kind = call i8 @kindIdentifier()
  %is.identifier = icmp eq i8 %kind, %identifier.kind
  br i1 %is.identifier, label %identifier.next, label %operator.find
identifier.next:
  %name = call ptr @tokenTextAt(ptr %arg.tokens, i32 %arg.start)
  br i1 %single, label %identifier.return, label %call.check
identifier.return:
  %storage = call ptr @lookupVisibleStorageName(ptr %arg.tokens, i32 %arg.start, ptr %name)
  %i1 = call ptr @csec_string_concat(ptr @.str.expr.f64.prefix, ptr %arg.resultName)
  %i2 = call ptr @csec_string_concat(ptr %i1, ptr @.str.expr.f64.load)
  %identifier.result = call ptr @csec_string_concat(ptr %i2, ptr %storage)
  ret ptr %identifier.result
call.check:
  %open.index = add i32 %arg.start, 1
  %before.end = icmp slt i32 %open.index, %end
  br i1 %before.end, label %open.check, label %operator.find
open.check:
  %operator.kind = call i8 @kindOperator()
  %open.raw = call i32 @tokenIs(ptr %arg.tokens, i32 %open.index, i8 %operator.kind, ptr @.str.expr.f64.open)
  %open = icmp ne i32 %open.raw, 0
  br i1 %open, label %close.check, label %operator.find
close.check:
  %close = call i32 @findClosingToken(ptr %arg.tokens, i32 %open.index, i32 %end, ptr @.str.expr.f64.open, ptr @.str.expr.f64.close)
  %last = sub i32 %end, 1
  %is.call = icmp eq i32 %close, %last
  br i1 %is.call, label %call.return, label %operator.find
call.return:
  %args.start = add i32 %arg.start, 2
  %loads = call ptr @generateLLVMCallArgumentLoadsI32(ptr %arg.tokens, i32 %args.start, i32 %last, ptr %arg.resultName)
  %arguments = call ptr @generateLLVMCallArgumentListI32(ptr %arg.tokens, i32 %args.start, i32 %last, ptr %arg.resultName)
  %callee = call ptr @llvmRuntimeCallName(ptr %name)
  %c1 = call ptr @csec_string_concat(ptr %loads, ptr @.str.expr.f64.prefix)
  %c2 = call ptr @csec_string_concat(ptr %c1, ptr %arg.resultName)
  %c3 = call ptr @csec_string_concat(ptr %c2, ptr @.str.expr.f64.call)
  %c4 = call ptr @csec_string_concat(ptr %c3, ptr %callee)
  %c5 = call ptr @csec_string_concat(ptr %c4, ptr @.str.expr.f64.open)
  %c6 = call ptr @csec_string_concat(ptr %c5, ptr %arguments)
  %call.result = call ptr @csec_string_concat(ptr %c6, ptr @.str.expr.f64.close.nl)
  ret ptr %call.result
operator.find:
  %op = call i32 @expressionTopLevelOperator(ptr %arg.tokens, i32 %arg.start, i32 %end)
  %has.op = icmp sgt i32 %op, %arg.start
  br i1 %has.op, label %operator.check, label %zero.return
operator.check:
  %op.text = call ptr @tokenTextAt(ptr %arg.tokens, i32 %op)
  %add = call i1 @strEq(ptr %op.text, ptr @.str.expr.f64.add.symbol)
  br i1 %add, label %binary.add, label %sub.check
sub.check:
  %sub = call i1 @strEq(ptr %op.text, ptr @.str.expr.f64.sub.symbol)
  br i1 %sub, label %binary.sub, label %mul.check
mul.check:
  %mul = call i1 @strEq(ptr %op.text, ptr @.str.expr.f64.mul.symbol)
  br i1 %mul, label %binary.mul, label %div.check
div.check:
  %div = call i1 @strEq(ptr %op.text, ptr @.str.expr.f64.div.symbol)
  br i1 %div, label %binary.div, label %zero.return
binary.add:
  br label %binary
binary.sub:
  br label %binary
binary.mul:
  br label %binary
binary.div:
  br label %binary
binary:
  %mnemonic = phi ptr [ @.str.expr.f64.fadd.name, %binary.add ], [ @.str.expr.f64.fsub.name, %binary.sub ], [ @.str.expr.f64.fmul.name, %binary.mul ], [ @.str.expr.f64.fdiv.name, %binary.div ]
  %left.name = call ptr @csec_string_concat(ptr %arg.resultName, ptr @.str.expr.f64.left)
  %left = call ptr @generateLLVMExpressionF64(ptr %arg.tokens, i32 %arg.start, i32 %op, ptr %left.name)
  %right.start = add i32 %op, 1
  %right.name = call ptr @csec_string_concat(ptr %arg.resultName, ptr @.str.expr.f64.right)
  %right = call ptr @generateLLVMExpressionF64(ptr %arg.tokens, i32 %right.start, i32 %end, ptr %right.name)
  %b1 = call ptr @csec_string_concat(ptr %left, ptr %right)
  %b2 = call ptr @csec_string_concat(ptr %b1, ptr @.str.expr.f64.prefix)
  %b3 = call ptr @csec_string_concat(ptr %b2, ptr %arg.resultName)
  %b4 = call ptr @csec_string_concat(ptr %b3, ptr @.str.expr.f64.operator.prefix)
  %b5 = call ptr @csec_string_concat(ptr %b4, ptr %mnemonic)
  %b6 = call ptr @csec_string_concat(ptr %b5, ptr @.str.expr.f64.operator.middle)
  %b7 = call ptr @csec_string_concat(ptr %b6, ptr %left.name)
  %b8 = call ptr @csec_string_concat(ptr %b7, ptr @.str.expr.f64.operator.comma)
  %binary.result = call ptr @csec_string_concat(ptr %b8, ptr %right.name)
  ret ptr %binary.result
}

)";
    output += llvmStringGlobal(".str.expr.f64.prefix", "  ");
    output += llvmStringGlobal(".str.expr.f64.zero", " = fadd double 0.000000e+00, 0.000000e+00\n");
    output += llvmStringGlobal(".str.expr.f64.fadd", " = fadd double 0.000000e+00, ");
    output += llvmStringGlobal(".str.expr.f64.load", " = load double, ptr %");
    output += llvmStringGlobal(".str.expr.f64.open", "(");
    output += llvmStringGlobal(".str.expr.f64.close", ")");
    output += llvmStringGlobal(".str.expr.f64.close.nl", ")\n");
    output += llvmStringGlobal(".str.expr.f64.call", " = call double @");
    output += llvmStringGlobal(".str.expr.f64.add.symbol", "+");
    output += llvmStringGlobal(".str.expr.f64.sub.symbol", "-");
    output += llvmStringGlobal(".str.expr.f64.mul.symbol", "*");
    output += llvmStringGlobal(".str.expr.f64.div.symbol", "/");
    output += llvmStringGlobal(".str.expr.f64.fadd.name", "fadd");
    output += llvmStringGlobal(".str.expr.f64.fsub.name", "fsub");
    output += llvmStringGlobal(".str.expr.f64.fmul.name", "fmul");
    output += llvmStringGlobal(".str.expr.f64.fdiv.name", "fdiv");
    output += llvmStringGlobal(".str.expr.f64.left", ".left");
    output += llvmStringGlobal(".str.expr.f64.right", ".right");
    output += llvmStringGlobal(".str.expr.f64.operator.prefix", " = ");
    output += llvmStringGlobal(".str.expr.f64.operator.middle", " double ");
    output += llvmStringGlobal(".str.expr.f64.operator.comma", ", ");
    return output;
}

std::string llvmGenerateExpressionPtrDefinition() {
    std::string output = R"(define ptr @csecGenerateLLVMStringOperand(ptr %arg.tokens, i32 %arg.start, i32 %arg.rawEnd, ptr %arg.resultName) {
entry:
  %end = call i32 @trimExpressionEnd(ptr %arg.tokens, i32 %arg.start, i32 %arg.rawEnd)
  %kind = call i8 @tokenKindAt(ptr %arg.tokens, i32 %arg.start)
  %single.end = add i32 %arg.start, 1
  %single = icmp eq i32 %end, %single.end
  %string.kind = call i8 @kindString()
  %is.string = icmp eq i8 %kind, %string.kind
  %string = and i1 %is.string, %single
  br i1 %string, label %ptr.return, label %identifier.check
identifier.check:
  %identifier.kind = call i8 @kindIdentifier()
  %is.identifier = icmp eq i8 %kind, %identifier.kind
  br i1 %is.identifier, label %identifier.next, label %char.check
identifier.next:
  %name = call ptr @tokenTextAt(ptr %arg.tokens, i32 %arg.start)
  br i1 %single, label %identifier.single, label %identifier.complex
identifier.single:
  %type = call ptr @lookupVisibleValueType(ptr %arg.tokens, i32 %arg.start, ptr %name)
  %ir.type = call ptr @irTypeName(ptr %type)
  %ptr = call i1 @strEq(ptr %ir.type, ptr @.str.expr.ptr.ptr)
  br i1 %ptr, label %ptr.return, label %identifier.char.check
identifier.char.check:
  %character = call i1 @strEq(ptr %type, ptr @.str.expr.ptr.char)
  br i1 %character, label %char.identifier, label %i32.return
identifier.complex:
  %open.index = add i32 %arg.start, 1
  %operator.kind = call i8 @kindOperator()
  %open.raw = call i32 @tokenIs(ptr %arg.tokens, i32 %open.index, i8 %operator.kind, ptr @.str.expr.ptr.open)
  %open = icmp ne i32 %open.raw, 0
  br i1 %open, label %call.close.check, label %substring.check
call.close.check:
  %close = call i32 @findClosingToken(ptr %arg.tokens, i32 %open.index, i32 %end, ptr @.str.expr.ptr.open, ptr @.str.expr.ptr.close)
  %last = sub i32 %end, 1
  %is.call = icmp eq i32 %close, %last
  br i1 %is.call, label %call.type.check, label %substring.check
call.type.check:
  %return.type = call ptr @lookupFunctionReturnType(ptr %arg.tokens, ptr %name)
  %call.ir.type = call ptr @irTypeName(ptr %return.type)
  %call.ptr = call i1 @strEq(ptr %call.ir.type, ptr @.str.expr.ptr.ptr)
  br i1 %call.ptr, label %ptr.return, label %i32.return
substring.check:
  %dot.raw = call i32 @tokenIs(ptr %arg.tokens, i32 %open.index, i8 %operator.kind, ptr @.str.expr.ptr.dot)
  %dot = icmp ne i32 %dot.raw, 0
  br i1 %dot, label %substring.name.check, label %plus.check
substring.name.check:
  %substring.index = add i32 %arg.start, 2
  %substring.raw = call i32 @tokenIs(ptr %arg.tokens, i32 %substring.index, i8 %identifier.kind, ptr @.str.expr.ptr.substring)
  %substring = icmp ne i32 %substring.raw, 0
  br i1 %substring, label %ptr.return, label %plus.check
char.check:
  %char.kind = call i8 @kindChar()
  %is.char = icmp eq i8 %kind, %char.kind
  %char = and i1 %is.char, %single
  br i1 %char, label %char.literal, label %plus.check
char.literal:
  %text = call ptr @tokenTextAt(ptr %arg.tokens, i32 %arg.start)
  %value = call ptr @llvmCharI8Value(ptr %text)
  %c1 = call ptr @csec_string_concat(ptr @.str.expr.ptr.prefix, ptr %arg.resultName)
  %c2 = call ptr @csec_string_concat(ptr %c1, ptr @.str.expr.ptr.char.call)
  %c3 = call ptr @csec_string_concat(ptr %c2, ptr %text)
  %char.result = call ptr @csec_string_concat(ptr %c3, ptr @.str.expr.ptr.char.close)
  ret ptr %char.result
char.identifier:
  %storage = call ptr @lookupVisibleStorageName(ptr %arg.tokens, i32 %arg.start, ptr %name)
  %c4 = call ptr @csec_string_concat(ptr @.str.expr.ptr.prefix, ptr %arg.resultName)
  %c5 = call ptr @csec_string_concat(ptr %c4, ptr @.str.expr.ptr.char.load)
  %c6 = call ptr @csec_string_concat(ptr %c5, ptr %storage)
  %c7 = call ptr @csec_string_concat(ptr %c6, ptr @.str.expr.ptr.char.nl)
  %c8 = call ptr @csec_string_concat(ptr %c7, ptr @.str.expr.ptr.prefix)
  %c9 = call ptr @csec_string_concat(ptr %c8, ptr %arg.resultName)
  %c10 = call ptr @csec_string_concat(ptr %c9, ptr @.str.expr.ptr.char.call)
  %c11 = call ptr @csec_string_concat(ptr %c10, ptr %arg.resultName)
  %char.identifier.result = call ptr @csec_string_concat(ptr %c11, ptr @.str.expr.ptr.char.value.close)
  ret ptr %char.identifier.result
plus.check:
  %plus = call i32 @expressionTopLevelOperator(ptr %arg.tokens, i32 %arg.start, i32 %end)
  %has.plus = icmp sgt i32 %plus, %arg.start
  br i1 %has.plus, label %plus.text.check, label %i32.return
plus.text.check:
  %plus.text = call ptr @tokenTextAt(ptr %arg.tokens, i32 %plus)
  %is.plus = call i1 @strEq(ptr %plus.text, ptr @.str.expr.ptr.plus)
  br i1 %is.plus, label %ptr.return, label %i32.return
ptr.return:
  %ptr.code = call ptr @generateLLVMExpressionPtr(ptr %arg.tokens, i32 %arg.start, i32 %end, ptr %arg.resultName)
  ret ptr %ptr.code
i32.return:
  %i32.name = call ptr @csec_string_concat(ptr %arg.resultName, ptr @.str.expr.ptr.i32)
  %i32.code = call ptr @generateLLVMExpressionI32(ptr %arg.tokens, i32 %arg.start, i32 %end, ptr %i32.name)
  %i64.name = call ptr @csec_string_concat(ptr %arg.resultName, ptr @.str.expr.ptr.i64)
  %n1 = call ptr @csec_string_concat(ptr %i32.code, ptr @.str.expr.ptr.prefix)
  %n2 = call ptr @csec_string_concat(ptr %n1, ptr %i64.name)
  %n3 = call ptr @csec_string_concat(ptr %n2, ptr @.str.expr.ptr.sext)
  %n4 = call ptr @csec_string_concat(ptr %n3, ptr %i32.name)
  %n5 = call ptr @csec_string_concat(ptr %n4, ptr @.str.expr.ptr.to.i64)
  %n6 = call ptr @csec_string_concat(ptr %n5, ptr @.str.expr.ptr.prefix)
  %n7 = call ptr @csec_string_concat(ptr %n6, ptr %arg.resultName)
  %n8 = call ptr @csec_string_concat(ptr %n7, ptr @.str.expr.ptr.i64.call)
  %n9 = call ptr @csec_string_concat(ptr %n8, ptr %i64.name)
  %numeric.result = call ptr @csec_string_concat(ptr %n9, ptr @.str.expr.ptr.close.nl)
  ret ptr %numeric.result
}

define ptr @generateLLVMExpressionPtr(ptr %arg.tokens, i32 %arg.start, i32 %arg.rawEnd, ptr %arg.resultName) {
entry:
  %end = call i32 @trimExpressionEnd(ptr %arg.tokens, i32 %arg.start, i32 %arg.rawEnd)
  %empty = icmp sle i32 %end, %arg.start
  br i1 %empty, label %empty.return, label %string.check
empty.return:
  %e1 = call ptr @csec_string_concat(ptr @.str.expr.ptr.prefix, ptr %arg.resultName)
  %empty.result = call ptr @csec_string_concat(ptr %e1, ptr @.str.expr.ptr.null)
  ret ptr %empty.result
string.check:
  %kind = call i8 @tokenKindAt(ptr %arg.tokens, i32 %arg.start)
  %string.kind = call i8 @kindString()
  %is.string = icmp eq i8 %kind, %string.kind
  %single.end = add i32 %arg.start, 1
  %single = icmp eq i32 %end, %single.end
  %string = and i1 %is.string, %single
  br i1 %string, label %string.return, label %identifier.check
string.return:
  %text = call ptr @tokenTextAt(ptr %arg.tokens, i32 %arg.start)
  %bytes = call i32 @csec_llvm_string_literal_byte_length(ptr %text)
  %bytes.i64 = sext i32 %bytes to i64
  %bytes.text = call ptr @csec_to_string_i64(i64 %bytes.i64)
  %start.i64 = sext i32 %arg.start to i64
  %start.text = call ptr @csec_to_string_i64(i64 %start.i64)
  %s1 = call ptr @csec_string_concat(ptr @.str.expr.ptr.prefix, ptr %arg.resultName)
  %s2 = call ptr @csec_string_concat(ptr %s1, ptr @.str.expr.ptr.gep.a)
  %s3 = call ptr @csec_string_concat(ptr %s2, ptr %bytes.text)
  %s4 = call ptr @csec_string_concat(ptr %s3, ptr @.str.expr.ptr.gep.b)
  %s5 = call ptr @csec_string_concat(ptr %s4, ptr %start.text)
  %string.result = call ptr @csec_string_concat(ptr %s5, ptr @.str.expr.ptr.gep.c)
  ret ptr %string.result
identifier.check:
  %identifier.kind = call i8 @kindIdentifier()
  %is.identifier = icmp eq i8 %kind, %identifier.kind
  br i1 %is.identifier, label %identifier.next, label %plus.find
identifier.next:
  %name = call ptr @tokenTextAt(ptr %arg.tokens, i32 %arg.start)
  br i1 %single, label %identifier.return, label %call.check
identifier.return:
  %storage = call ptr @lookupVisibleStorageName(ptr %arg.tokens, i32 %arg.start, ptr %name)
  %i1 = call ptr @csec_string_concat(ptr @.str.expr.ptr.prefix, ptr %arg.resultName)
  %i2 = call ptr @csec_string_concat(ptr %i1, ptr @.str.expr.ptr.load)
  %identifier.result = call ptr @csec_string_concat(ptr %i2, ptr %storage)
  ret ptr %identifier.result
call.check:
  %open.index = add i32 %arg.start, 1
  %operator.kind = call i8 @kindOperator()
  %open.raw = call i32 @tokenIs(ptr %arg.tokens, i32 %open.index, i8 %operator.kind, ptr @.str.expr.ptr.open)
  %open = icmp ne i32 %open.raw, 0
  br i1 %open, label %call.close.check, label %substring.check
call.close.check:
  %close = call i32 @findClosingToken(ptr %arg.tokens, i32 %open.index, i32 %end, ptr @.str.expr.ptr.open, ptr @.str.expr.ptr.close)
  %last = sub i32 %end, 1
  %is.call = icmp eq i32 %close, %last
  br i1 %is.call, label %call.return, label %substring.check
call.return:
  %args.start = add i32 %arg.start, 2
  %loads = call ptr @generateLLVMCallArgumentLoadsI32(ptr %arg.tokens, i32 %args.start, i32 %last, ptr %arg.resultName)
  %arguments = call ptr @generateLLVMCallArgumentListI32(ptr %arg.tokens, i32 %args.start, i32 %last, ptr %arg.resultName)
  %callee = call ptr @llvmRuntimeCallName(ptr %name)
  %c1 = call ptr @csec_string_concat(ptr %loads, ptr @.str.expr.ptr.prefix)
  %c2 = call ptr @csec_string_concat(ptr %c1, ptr %arg.resultName)
  %c3 = call ptr @csec_string_concat(ptr %c2, ptr @.str.expr.ptr.call)
  %c4 = call ptr @csec_string_concat(ptr %c3, ptr %callee)
  %c5 = call ptr @csec_string_concat(ptr %c4, ptr @.str.expr.ptr.open)
  %c6 = call ptr @csec_string_concat(ptr %c5, ptr %arguments)
  %call.result = call ptr @csec_string_concat(ptr %c6, ptr @.str.expr.ptr.close.nl)
  ret ptr %call.result
substring.check:
  %dot.raw = call i32 @tokenIs(ptr %arg.tokens, i32 %open.index, i8 %operator.kind, ptr @.str.expr.ptr.dot)
  %dot = icmp ne i32 %dot.raw, 0
  br i1 %dot, label %substring.name.check, label %plus.find
substring.name.check:
  %substring.index = add i32 %arg.start, 2
  %substring.raw = call i32 @tokenIs(ptr %arg.tokens, i32 %substring.index, i8 %identifier.kind, ptr @.str.expr.ptr.substring)
  %substring = icmp ne i32 %substring.raw, 0
  br i1 %substring, label %substring.open.check, label %plus.find
substring.open.check:
  %substring.open.index = add i32 %arg.start, 3
  %substring.open.raw = call i32 @tokenIs(ptr %arg.tokens, i32 %substring.open.index, i8 %operator.kind, ptr @.str.expr.ptr.open)
  %substring.open = icmp ne i32 %substring.open.raw, 0
  br i1 %substring.open, label %substring.close.check, label %plus.find
substring.close.check:
  %substring.close = call i32 @findClosingToken(ptr %arg.tokens, i32 %substring.open.index, i32 %end, ptr @.str.expr.ptr.open, ptr @.str.expr.ptr.close)
  %substring.last = sub i32 %end, 1
  %substring.complete = icmp eq i32 %substring.close, %substring.last
  br i1 %substring.complete, label %substring.comma.find, label %plus.find
substring.comma.find:
  %arguments.start = add i32 %arg.start, 4
  %comma = call i32 @findTokenTextInRange(ptr %arg.tokens, i32 %arguments.start, i32 %substring.last, ptr @.str.expr.ptr.comma)
  %has.comma = icmp sgt i32 %comma, %arguments.start
  br i1 %has.comma, label %substring.return, label %plus.find
substring.return:
  %storage.name = call ptr @lookupVisibleStorageName(ptr %arg.tokens, i32 %arg.start, ptr %name)
  %object.name = call ptr @csec_string_concat(ptr %arg.resultName, ptr @.str.expr.ptr.object)
  %start.name = call ptr @csec_string_concat(ptr %arg.resultName, ptr @.str.expr.ptr.start)
  %length.name = call ptr @csec_string_concat(ptr %arg.resultName, ptr @.str.expr.ptr.length)
  %object.prefix = call ptr @csec_string_concat(ptr @.str.expr.ptr.prefix, ptr %object.name)
  %object.code = call ptr @csec_string_concat(ptr %object.prefix, ptr @.str.expr.ptr.object.load)
  %object.result = call ptr @csec_string_concat(ptr %object.code, ptr %storage.name)
  %start.code = call ptr @generateLLVMExpressionI32(ptr %arg.tokens, i32 %arguments.start, i32 %comma, ptr %start.name)
  %length.start = add i32 %comma, 1
  %length.code = call ptr @generateLLVMExpressionI32(ptr %arg.tokens, i32 %length.start, i32 %substring.last, ptr %length.name)
  %u1 = call ptr @csec_string_concat(ptr %object.result, ptr %start.code)
  %u2 = call ptr @csec_string_concat(ptr %u1, ptr %length.code)
  %u3 = call ptr @csec_string_concat(ptr %u2, ptr @.str.expr.ptr.prefix)
  %u4 = call ptr @csec_string_concat(ptr %u3, ptr %arg.resultName)
  %u5 = call ptr @csec_string_concat(ptr %u4, ptr @.str.expr.ptr.substring.call)
  %u6 = call ptr @csec_string_concat(ptr %u5, ptr %object.name)
  %u7 = call ptr @csec_string_concat(ptr %u6, ptr @.str.expr.ptr.substring.middle)
  %u8 = call ptr @csec_string_concat(ptr %u7, ptr %start.name)
  %u9 = call ptr @csec_string_concat(ptr %u8, ptr @.str.expr.ptr.substring.middle)
  %u10 = call ptr @csec_string_concat(ptr %u9, ptr %length.name)
  %substring.result = call ptr @csec_string_concat(ptr %u10, ptr @.str.expr.ptr.close.nl)
  ret ptr %substring.result
plus.find:
  %op = call i32 @expressionTopLevelOperator(ptr %arg.tokens, i32 %arg.start, i32 %end)
  %has.op = icmp sgt i32 %op, %arg.start
  br i1 %has.op, label %plus.check, label %fallback
plus.check:
  %op.text = call ptr @tokenTextAt(ptr %arg.tokens, i32 %op)
  %plus = call i1 @strEq(ptr %op.text, ptr @.str.expr.ptr.plus)
  br i1 %plus, label %plus.return, label %fallback
plus.return:
  %left.name = call ptr @csec_string_concat(ptr %arg.resultName, ptr @.str.expr.ptr.left)
  %left = call ptr @csecGenerateLLVMStringOperand(ptr %arg.tokens, i32 %arg.start, i32 %op, ptr %left.name)
  %right.start = add i32 %op, 1
  %right.name = call ptr @csec_string_concat(ptr %arg.resultName, ptr @.str.expr.ptr.right)
  %right = call ptr @csecGenerateLLVMStringOperand(ptr %arg.tokens, i32 %right.start, i32 %end, ptr %right.name)
  %p1 = call ptr @csec_string_concat(ptr %left, ptr %right)
  %p2 = call ptr @csec_string_concat(ptr %p1, ptr @.str.expr.ptr.prefix)
  %p3 = call ptr @csec_string_concat(ptr %p2, ptr %arg.resultName)
  %p4 = call ptr @csec_string_concat(ptr %p3, ptr @.str.expr.ptr.concat)
  %p5 = call ptr @csec_string_concat(ptr %p4, ptr %left.name)
  %p6 = call ptr @csec_string_concat(ptr %p5, ptr @.str.expr.ptr.concat.middle)
  %p7 = call ptr @csec_string_concat(ptr %p6, ptr %right.name)
  %plus.result = call ptr @csec_string_concat(ptr %p7, ptr @.str.expr.ptr.close.nl)
  ret ptr %plus.result
fallback:
  %f1 = call ptr @csec_string_concat(ptr @.str.expr.ptr.prefix, ptr %arg.resultName)
  %fallback.result = call ptr @csec_string_concat(ptr %f1, ptr @.str.expr.ptr.null)
  ret ptr %fallback.result
}

)";
    output += llvmStringGlobal(".str.expr.ptr.prefix", "  ");
    output += llvmStringGlobal(".str.expr.ptr.null", " = inttoptr i64 0 to ptr\n");
    output += llvmStringGlobal(".str.expr.ptr.ptr", "ptr");
    output += llvmStringGlobal(".str.expr.ptr.char", "Char");
    output += llvmStringGlobal(".str.expr.ptr.open", "(");
    output += llvmStringGlobal(".str.expr.ptr.close", ")");
    output += llvmStringGlobal(".str.expr.ptr.close.nl", ")\n");
    output += llvmStringGlobal(".str.expr.ptr.dot", ".");
    output += llvmStringGlobal(".str.expr.ptr.substring", "substring");
    output += llvmStringGlobal(".str.expr.ptr.plus", "+");
    output += llvmStringGlobal(".str.expr.ptr.i32", ".i32");
    output += llvmStringGlobal(".str.expr.ptr.i64", ".i64");
    output += llvmStringGlobal(".str.expr.ptr.sext", " = sext i32 ");
    output += llvmStringGlobal(".str.expr.ptr.to.i64", " to i64\n");
    output += llvmStringGlobal(".str.expr.ptr.i64.call", " = call ptr @csec_to_string_i64(i64 ");
    output += llvmStringGlobal(".str.expr.ptr.gep.a", " = getelementptr inbounds [");
    output += llvmStringGlobal(".str.expr.ptr.gep.b", " x i8], ptr @.str.");
    output += llvmStringGlobal(".str.expr.ptr.gep.c", ", i32 0, i32 0\n");
    output += llvmStringGlobal(".str.expr.ptr.load", " = load ptr, ptr %");
    output += llvmStringGlobal(".str.expr.ptr.call", " = call ptr @");
    output += llvmStringGlobal(".str.expr.ptr.comma", ",");
    output += llvmStringGlobal(".str.expr.ptr.object", ".obj");
    output += llvmStringGlobal(".str.expr.ptr.start", ".start");
    output += llvmStringGlobal(".str.expr.ptr.length", ".length");
    output += llvmStringGlobal(".str.expr.ptr.object.load", " = load ptr, ptr %");
    output += llvmStringGlobal(".str.expr.ptr.substring.call", " = call ptr @csec_string_substring(ptr ");
    output += llvmStringGlobal(".str.expr.ptr.substring.middle", ", i32 ");
    output += llvmStringGlobal(".str.expr.ptr.left", ".left");
    output += llvmStringGlobal(".str.expr.ptr.right", ".right");
    output += llvmStringGlobal(".str.expr.ptr.concat", " = call ptr @csec_string_concat(ptr ");
    output += llvmStringGlobal(".str.expr.ptr.concat.middle", ", ptr ");
    output += llvmStringGlobal(".str.expr.ptr.char.call", " = call ptr @csec_to_string_char(i8 ");
    output += llvmStringGlobal(".str.expr.ptr.char.close", ")\n");
    output += llvmStringGlobal(".str.expr.ptr.char.load", " = load i8, ptr %");
    output += llvmStringGlobal(".str.expr.ptr.char.nl", "\n");
    output += llvmStringGlobal(".str.expr.ptr.char.value.close", ")\n");
    return output;
}

std::string llvmGenerateLocalPtrDefinition() {
    std::string output = R"(define ptr @generateLLVMLocalPtr(ptr %arg.tokens, i32 %arg.start, i32 %arg.end) {
entry:
  %initializer = call i32 @findTopLevelOperator(ptr %arg.tokens, i32 %arg.start, i32 %arg.end, i32 1)
  %name.index = add i32 %arg.start, 1
  %name = call ptr @tokenTextAt(ptr %arg.tokens, i32 %name.index)
  %start.i64 = sext i32 %arg.start to i64
  %start.text = call ptr @csec_to_string_i64(i64 %start.i64)
  %storage.a = call ptr @csec_string_concat(ptr %name, ptr @.str.local.ptr.addr)
  %storage = call ptr @csec_string_concat(ptr %storage.a, ptr %start.text)
  %init.a = call ptr @csec_string_concat(ptr @.str.local.ptr.percent, ptr %name)
  %init.b = call ptr @csec_string_concat(ptr %init.a, ptr @.str.local.ptr.init)
  %init = call ptr @csec_string_concat(ptr %init.b, ptr %start.text)
  %has.initializer = icmp sge i32 %initializer, %arg.start
  br i1 %has.initializer, label %with.initializer, label %without.initializer
with.initializer:
  %expr.start = add i32 %initializer, 1
  %expr = call ptr @generateLLVMExpressionPtr(ptr %arg.tokens, i32 %expr.start, i32 %arg.end, ptr %init)
  %a1 = call ptr @csec_string_concat(ptr @.str.local.ptr.prefix, ptr %storage)
  %a2 = call ptr @csec_string_concat(ptr %a1, ptr @.str.local.ptr.alloca)
  %a3 = call ptr @csec_string_concat(ptr %a2, ptr %expr)
  %a4 = call ptr @csec_string_concat(ptr %a3, ptr @.str.local.ptr.store)
  %a5 = call ptr @csec_string_concat(ptr %a4, ptr %init)
  %a6 = call ptr @csec_string_concat(ptr %a5, ptr @.str.local.ptr.to)
  %result = call ptr @csec_string_concat(ptr %a6, ptr %storage)
  ret ptr %result
without.initializer:
  %b1 = call ptr @csec_string_concat(ptr @.str.local.ptr.prefix, ptr %storage)
  %b2 = call ptr @csec_string_concat(ptr %b1, ptr @.str.local.ptr.alloca)
  %b3 = call ptr @csec_string_concat(ptr %b2, ptr @.str.local.ptr.null)
  %fallback = call ptr @csec_string_concat(ptr %b3, ptr %storage)
  ret ptr %fallback
}

)";
    output += llvmStringGlobal(".str.local.ptr.addr", ".addr.");
    output += llvmStringGlobal(".str.local.ptr.percent", "%");
    output += llvmStringGlobal(".str.local.ptr.init", ".pinit.");
    output += llvmStringGlobal(".str.local.ptr.prefix", "  %");
    output += llvmStringGlobal(".str.local.ptr.alloca", " = alloca ptr\n");
    output += llvmStringGlobal(".str.local.ptr.store", "  store ptr ");
    output += llvmStringGlobal(".str.local.ptr.to", ", ptr %");
    output += llvmStringGlobal(".str.local.ptr.null", "  store ptr null, ptr %");
    return output;
}

std::string llvmGenerateLLVMIfI32Definition() {
    std::string output = R"(define ptr @generateLLVMIfI32(ptr %arg.tokens, i32 %arg.start, i32 %arg.end) {
entry:
  %open = call i32 @findStatementParenStart(ptr %arg.tokens, i32 %arg.start, i32 %arg.end)
  %close = call i32 @findStatementParenEnd(ptr %arg.tokens, i32 %arg.start, i32 %arg.end)
  %then.open = call i32 @findStatementBlockStart(ptr %arg.tokens, i32 %arg.start, i32 %arg.end)
  %then.close = call i32 @findClosingToken(ptr %arg.tokens, i32 %then.open, i32 %arg.end, ptr @.str.llvm.if.brace.open, ptr @.str.llvm.if.brace.close)
  %open.ok = icmp sge i32 %open, 0
  %close.ok = icmp sgt i32 %close, %open
  %body.ok = icmp sgt i32 %then.close, %then.open
  %ok.a = and i1 %open.ok, %close.ok
  %ok = and i1 %ok.a, %body.ok
  br i1 %ok, label %build, label %bad
bad:
  ret ptr @.str.llvm.if.bad
build:
  %seed.i64 = sext i32 %arg.start to i64
  %seed = call ptr @csec_to_string_i64(i64 %seed.i64)
  %condition.name.a = call ptr @csec_string_concat(ptr @.str.llvm.if.condition.name, ptr %seed)
  %expr.start = add i32 %open, 1
  %condition = call ptr @generateLLVMExpressionI1(ptr %arg.tokens, i32 %expr.start, i32 %close, ptr %condition.name.a)
  %body.start = add i32 %then.open, 1
  %body = call ptr @generateLLVMFlatBodyI32(ptr %arg.tokens, i32 %body.start, i32 %then.close)
  %a1 = call ptr @csec_string_concat(ptr %condition, ptr @.str.llvm.if.branch)
  %a2 = call ptr @csec_string_concat(ptr %a1, ptr %seed)
  %a3 = call ptr @csec_string_concat(ptr %a2, ptr @.str.llvm.if.then.label)
  %a4 = call ptr @csec_string_concat(ptr %a3, ptr %seed)
  %a5 = call ptr @csec_string_concat(ptr %a4, ptr @.str.llvm.if.else.label)
  %a6 = call ptr @csec_string_concat(ptr %a5, ptr %seed)
  %a7 = call ptr @csec_string_concat(ptr %a6, ptr @.str.llvm.if.nl)
  %a8 = call ptr @csec_string_concat(ptr %a7, ptr @.str.llvm.if.then.name)
  %a9 = call ptr @csec_string_concat(ptr %a8, ptr %seed)
  %a10 = call ptr @csec_string_concat(ptr %a9, ptr @.str.llvm.if.colon)
  %a11 = call ptr @csec_string_concat(ptr %a10, ptr %body)
  %a12 = call ptr @csec_string_concat(ptr %a11, ptr @.str.llvm.if.end.branch)
  %a13 = call ptr @csec_string_concat(ptr %a12, ptr %seed)
  %a14 = call ptr @csec_string_concat(ptr %a13, ptr @.str.llvm.if.nl)
  %a15 = call ptr @csec_string_concat(ptr %a14, ptr @.str.llvm.if.else.name)
  %a16 = call ptr @csec_string_concat(ptr %a15, ptr %seed)
  %a17 = call ptr @csec_string_concat(ptr %a16, ptr @.str.llvm.if.colon)
  %a18 = call ptr @csec_string_concat(ptr %a17, ptr @.str.llvm.if.end.branch)
  %a19 = call ptr @csec_string_concat(ptr %a18, ptr %seed)
  %a20 = call ptr @csec_string_concat(ptr %a19, ptr @.str.llvm.if.nl)
  %a21 = call ptr @csec_string_concat(ptr %a20, ptr @.str.llvm.if.end.name)
  %a22 = call ptr @csec_string_concat(ptr %a21, ptr %seed)
  %result = call ptr @csec_string_concat(ptr %a22, ptr @.str.llvm.if.colon)
  ret ptr %result
}

)";
    output += llvmStringGlobal(".str.llvm.if.bad", "  ; malformed if\n");
    output += llvmStringGlobal(".str.llvm.if.brace.open", "{");
    output += llvmStringGlobal(".str.llvm.if.brace.close", "}");
    output += llvmStringGlobal(".str.llvm.if.condition.name", "%cond.");
    output += llvmStringGlobal(".str.llvm.if.branch", "  br i1 %cond.");
    output += llvmStringGlobal(".str.llvm.if.then.label", ", label %if.then.");
    output += llvmStringGlobal(".str.llvm.if.else.label", ", label %if.else.");
    output += llvmStringGlobal(".str.llvm.if.nl", "\n");
    output += llvmStringGlobal(".str.llvm.if.then.name", "if.then.");
    output += llvmStringGlobal(".str.llvm.if.else.name", "if.else.");
    output += llvmStringGlobal(".str.llvm.if.end.name", "if.end.");
    output += llvmStringGlobal(".str.llvm.if.colon", ":\n");
    output += llvmStringGlobal(".str.llvm.if.end.branch", "  br label %if.end.");
    return output;
}

std::string llvmGenerateLLVMWhileI32Definition() {
    std::string output = R"(define ptr @generateLLVMWhileI32(ptr %arg.tokens, i32 %arg.start, i32 %arg.end) {
entry:
  %open = call i32 @findStatementParenStart(ptr %arg.tokens, i32 %arg.start, i32 %arg.end)
  %close = call i32 @findStatementParenEnd(ptr %arg.tokens, i32 %arg.start, i32 %arg.end)
  %body.open = call i32 @findStatementBlockStart(ptr %arg.tokens, i32 %arg.start, i32 %arg.end)
  %body.close = call i32 @findClosingToken(ptr %arg.tokens, i32 %body.open, i32 %arg.end, ptr @.str.llvm.while.brace.open, ptr @.str.llvm.while.brace.close)
  %open.ok = icmp sge i32 %open, 0
  %close.ok = icmp sgt i32 %close, %open
  %body.ok = icmp sgt i32 %body.close, %body.open
  %ok.a = and i1 %open.ok, %close.ok
  %ok = and i1 %ok.a, %body.ok
  br i1 %ok, label %build, label %bad
bad:
  ret ptr @.str.llvm.while.bad
build:
  %seed.i64 = sext i32 %arg.start to i64
  %seed = call ptr @csec_to_string_i64(i64 %seed.i64)
  %condition.name.a = call ptr @csec_string_concat(ptr @.str.llvm.while.condition.name, ptr %seed)
  %expr.start = add i32 %open, 1
  %condition = call ptr @generateLLVMExpressionI1(ptr %arg.tokens, i32 %expr.start, i32 %close, ptr %condition.name.a)
  %body.start = add i32 %body.open, 1
  %body = call ptr @generateLLVMFlatBodyI32(ptr %arg.tokens, i32 %body.start, i32 %body.close)
  %a1 = call ptr @csec_string_concat(ptr @.str.llvm.while.initial.branch, ptr %seed)
  %a2 = call ptr @csec_string_concat(ptr %a1, ptr @.str.llvm.while.nl)
  %a3 = call ptr @csec_string_concat(ptr %a2, ptr @.str.llvm.while.condition.label)
  %a4 = call ptr @csec_string_concat(ptr %a3, ptr %seed)
  %a5 = call ptr @csec_string_concat(ptr %a4, ptr @.str.llvm.while.colon)
  %a6 = call ptr @csec_string_concat(ptr %a5, ptr %condition)
  %a7 = call ptr @csec_string_concat(ptr %a6, ptr @.str.llvm.while.test)
  %a8 = call ptr @csec_string_concat(ptr %a7, ptr %seed)
  %a9 = call ptr @csec_string_concat(ptr %a8, ptr @.str.llvm.while.body.label)
  %a10 = call ptr @csec_string_concat(ptr %a9, ptr %seed)
  %a11 = call ptr @csec_string_concat(ptr %a10, ptr @.str.llvm.while.end.label)
  %a12 = call ptr @csec_string_concat(ptr %a11, ptr %seed)
  %a13 = call ptr @csec_string_concat(ptr %a12, ptr @.str.llvm.while.nl)
  %a14 = call ptr @csec_string_concat(ptr %a13, ptr @.str.llvm.while.body.name)
  %a15 = call ptr @csec_string_concat(ptr %a14, ptr %seed)
  %a16 = call ptr @csec_string_concat(ptr %a15, ptr @.str.llvm.while.colon)
  %a17 = call ptr @csec_string_concat(ptr %a16, ptr %body)
  %a18 = call ptr @csec_string_concat(ptr %a17, ptr @.str.llvm.while.initial.branch)
  %a19 = call ptr @csec_string_concat(ptr %a18, ptr %seed)
  %a20 = call ptr @csec_string_concat(ptr %a19, ptr @.str.llvm.while.nl)
  %a21 = call ptr @csec_string_concat(ptr %a20, ptr @.str.llvm.while.end.name)
  %a22 = call ptr @csec_string_concat(ptr %a21, ptr %seed)
  %result = call ptr @csec_string_concat(ptr %a22, ptr @.str.llvm.while.colon)
  ret ptr %result
}

)";
    output += llvmStringGlobal(".str.llvm.while.bad", "  ; malformed while\n");
    output += llvmStringGlobal(".str.llvm.while.brace.open", "{");
    output += llvmStringGlobal(".str.llvm.while.brace.close", "}");
    output += llvmStringGlobal(".str.llvm.while.condition.name", "%whilecond.");
    output += llvmStringGlobal(".str.llvm.while.initial.branch", "  br label %while.cond.");
    output += llvmStringGlobal(".str.llvm.while.condition.label", "while.cond.");
    output += llvmStringGlobal(".str.llvm.while.body.label", ", label %while.body.");
    output += llvmStringGlobal(".str.llvm.while.end.label", ", label %while.end.");
    output += llvmStringGlobal(".str.llvm.while.body.name", "while.body.");
    output += llvmStringGlobal(".str.llvm.while.end.name", "while.end.");
    output += llvmStringGlobal(".str.llvm.while.colon", ":\n");
    output += llvmStringGlobal(".str.llvm.while.nl", "\n");
    output += llvmStringGlobal(".str.llvm.while.test", "  br i1 %whilecond.");
    return output;
}

std::string llvmGenerateLLVMForI32Definition() {
    std::string output = R"(define ptr @generateLLVMForI32(ptr %arg.tokens, i32 %arg.start, i32 %arg.end) {
entry:
  %open = call i32 @findStatementParenStart(ptr %arg.tokens, i32 %arg.start, i32 %arg.end)
  %close = call i32 @findStatementParenEnd(ptr %arg.tokens, i32 %arg.start, i32 %arg.end)
  %body.open = call i32 @findStatementBlockStart(ptr %arg.tokens, i32 %arg.start, i32 %arg.end)
  %body.close = call i32 @findClosingToken(ptr %arg.tokens, i32 %body.open, i32 %arg.end, ptr @.str.llvm.for.brace.open, ptr @.str.llvm.for.brace.close)
  %iterator.index = add i32 %open, 1
  %iterator = call ptr @tokenTextAt(ptr %arg.tokens, i32 %iterator.index)
  %arrow = call i32 @findTokenTextInRange(ptr %arg.tokens, i32 %iterator.index, i32 %close, ptr @.str.llvm.for.arrow)
  %range = call i32 @findTopLevelOperator(ptr %arg.tokens, i32 %arrow, i32 %close, i32 5)
  %valid.open = icmp sge i32 %open, 0
  %valid.arrow = icmp sgt i32 %arrow, %iterator.index
  %valid.range = icmp sgt i32 %range, %arrow
  %valid.a = and i1 %valid.open, %valid.arrow
  %valid = and i1 %valid.a, %valid.range
  br i1 %valid, label %build, label %bad
bad:
  ret ptr @.str.llvm.for.bad
build:
  %seed.i64 = sext i32 %arg.start to i64
  %seed = call ptr @csec_to_string_i64(i64 %seed.i64)
  %start.name.a = call ptr @csec_string_concat(ptr @.str.llvm.for.percent, ptr %iterator)
  %start.name.b = call ptr @csec_string_concat(ptr %start.name.a, ptr @.str.llvm.for.start)
  %end.name.a = call ptr @csec_string_concat(ptr @.str.llvm.for.percent, ptr %iterator)
  %end.name.b = call ptr @csec_string_concat(ptr %end.name.a, ptr @.str.llvm.for.end)
  %start.expr = add i32 %arrow, 1
  %start.code = call ptr @generateLLVMExpressionI32(ptr %arg.tokens, i32 %start.expr, i32 %range, ptr %start.name.b)
  %end.expr = add i32 %range, 1
  %end.code = call ptr @generateLLVMExpressionI32(ptr %arg.tokens, i32 %end.expr, i32 %close, ptr %end.name.b)
  %body.start = add i32 %body.open, 1
  %body = call ptr @generateLLVMFlatBodyI32(ptr %arg.tokens, i32 %body.start, i32 %body.close)
  %op.text = call ptr @tokenTextAt(ptr %arg.tokens, i32 %range)
  %inclusive.to = call i1 @strEq(ptr %op.text, ptr @.str.llvm.for.to)
  %inclusive.dots = call i1 @strEq(ptr %op.text, ptr @.str.llvm.for.dots)
  %inclusive = or i1 %inclusive.to, %inclusive.dots
  br i1 %inclusive, label %sle, label %slt
sle:
  br label %emit
slt:
  br label %emit
emit:
  %comparison = phi ptr [ @.str.llvm.for.sle, %sle ], [ @.str.llvm.for.slt, %slt ]
  %a1 = call ptr @csec_string_concat(ptr @.str.llvm.for.alloca.a, ptr %iterator)
  %a2 = call ptr @csec_string_concat(ptr %a1, ptr @.str.llvm.for.alloca.b)
  %a3 = call ptr @csec_string_concat(ptr %a2, ptr %start.code)
  %a4 = call ptr @csec_string_concat(ptr %a3, ptr @.str.llvm.for.store.a)
  %a5 = call ptr @csec_string_concat(ptr %a4, ptr %iterator)
  %a6 = call ptr @csec_string_concat(ptr %a5, ptr @.str.llvm.for.store.b)
  %a7 = call ptr @csec_string_concat(ptr %a6, ptr %start.name.b)
  %a8 = call ptr @csec_string_concat(ptr %a7, ptr @.str.llvm.for.cond.label)
  %a9 = call ptr @csec_string_concat(ptr %a8, ptr %seed)
  %a10 = call ptr @csec_string_concat(ptr %a9, ptr @.str.llvm.for.colon)
  %a11 = call ptr @csec_string_concat(ptr %a10, ptr @.str.llvm.for.value.a)
  %a12 = call ptr @csec_string_concat(ptr %a11, ptr %iterator)
  %a13 = call ptr @csec_string_concat(ptr %a12, ptr @.str.llvm.for.value.b)
  %a14 = call ptr @csec_string_concat(ptr %a13, ptr %iterator)
  %a15 = call ptr @csec_string_concat(ptr %a14, ptr %end.code)
  %a16 = call ptr @csec_string_concat(ptr %a15, ptr @.str.llvm.for.compare.a)
  %a17 = call ptr @csec_string_concat(ptr %a16, ptr %seed)
  %a18 = call ptr @csec_string_concat(ptr %a17, ptr %comparison)
  %a19 = call ptr @csec_string_concat(ptr %a18, ptr @.str.llvm.for.compare.b)
  %a20 = call ptr @csec_string_concat(ptr %a19, ptr %iterator)
  %a21 = call ptr @csec_string_concat(ptr %a20, ptr @.str.llvm.for.compare.c)
  %a22 = call ptr @csec_string_concat(ptr %a21, ptr %iterator)
  %a23 = call ptr @csec_string_concat(ptr %a22, ptr @.str.llvm.for.branch.a)
  %a24 = call ptr @csec_string_concat(ptr %a23, ptr %seed)
  %a25 = call ptr @csec_string_concat(ptr %a24, ptr @.str.llvm.for.branch.b)
  %a26 = call ptr @csec_string_concat(ptr %a25, ptr %seed)
  %a27 = call ptr @csec_string_concat(ptr %a26, ptr @.str.llvm.for.branch.c)
  %a28 = call ptr @csec_string_concat(ptr %a27, ptr %seed)
  %a29 = call ptr @csec_string_concat(ptr %a28, ptr @.str.llvm.for.body.label)
  %a30 = call ptr @csec_string_concat(ptr %a29, ptr %seed)
  %a31 = call ptr @csec_string_concat(ptr %a30, ptr @.str.llvm.for.colon)
  %a32 = call ptr @csec_string_concat(ptr %a31, ptr %body)
  %a33 = call ptr @csec_string_concat(ptr %a32, ptr @.str.llvm.for.step.a)
  %a34 = call ptr @csec_string_concat(ptr %a33, ptr %iterator)
  %a35 = call ptr @csec_string_concat(ptr %a34, ptr @.str.llvm.for.step.b)
  %a36 = call ptr @csec_string_concat(ptr %a35, ptr %seed)
  %a37 = call ptr @csec_string_concat(ptr %a36, ptr @.str.llvm.for.step.c)
  %a38 = call ptr @csec_string_concat(ptr %a37, ptr %iterator)
  %a39 = call ptr @csec_string_concat(ptr %a38, ptr @.str.llvm.for.step.d)
  %a40 = call ptr @csec_string_concat(ptr %a39, ptr %seed)
  %a41 = call ptr @csec_string_concat(ptr %a40, ptr @.str.llvm.for.step.e)
  %a42 = call ptr @csec_string_concat(ptr %a41, ptr %iterator)
  %a43 = call ptr @csec_string_concat(ptr %a42, ptr @.str.llvm.for.step.f)
  %a44 = call ptr @csec_string_concat(ptr %a43, ptr %seed)
  %a45 = call ptr @csec_string_concat(ptr %a44, ptr @.str.llvm.for.step.g)
  %a46 = call ptr @csec_string_concat(ptr %a45, ptr %iterator)
  %a47 = call ptr @csec_string_concat(ptr %a46, ptr @.str.llvm.for.cond.branch)
  %a48 = call ptr @csec_string_concat(ptr %a47, ptr %seed)
  %a49 = call ptr @csec_string_concat(ptr %a48, ptr @.str.llvm.for.nl)
  %a50 = call ptr @csec_string_concat(ptr %a49, ptr @.str.llvm.for.end.label)
  %a51 = call ptr @csec_string_concat(ptr %a50, ptr %seed)
  %result = call ptr @csec_string_concat(ptr %a51, ptr @.str.llvm.for.colon)
  ret ptr %result
}

)";
    output += llvmStringGlobal(".str.llvm.for.bad", "  ; malformed for\n");
    output += llvmStringGlobal(".str.llvm.for.brace.open", "{"); output += llvmStringGlobal(".str.llvm.for.brace.close", "}");
    output += llvmStringGlobal(".str.llvm.for.arrow", "<-"); output += llvmStringGlobal(".str.llvm.for.to", "to"); output += llvmStringGlobal(".str.llvm.for.dots", "..");
    output += llvmStringGlobal(".str.llvm.for.percent", "%"); output += llvmStringGlobal(".str.llvm.for.start", ".start"); output += llvmStringGlobal(".str.llvm.for.end", ".end");
    output += llvmStringGlobal(".str.llvm.for.slt", "slt"); output += llvmStringGlobal(".str.llvm.for.sle", "sle");
    output += llvmStringGlobal(".str.llvm.for.alloca.a", "  %"); output += llvmStringGlobal(".str.llvm.for.alloca.b", " = alloca i32\n");
    output += llvmStringGlobal(".str.llvm.for.store.a", "  store i32 %"); output += llvmStringGlobal(".str.llvm.for.store.b", ", ptr %");
    output += llvmStringGlobal(".str.llvm.for.cond.label", "  br label %for.cond."); output += llvmStringGlobal(".str.llvm.for.colon", ":\n");
    output += llvmStringGlobal(".str.llvm.for.value.a", "  %"); output += llvmStringGlobal(".str.llvm.for.value.b", ".val = load i32, ptr %");
    output += llvmStringGlobal(".str.llvm.for.compare.a", "  %forcond."); output += llvmStringGlobal(".str.llvm.for.compare.b", " = icmp "); output += llvmStringGlobal(".str.llvm.for.compare.c", " i32 %");
    output += llvmStringGlobal(".str.llvm.for.branch.a", ".val, %"); output += llvmStringGlobal(".str.llvm.for.branch.b", ".end\n  br i1 %forcond."); output += llvmStringGlobal(".str.llvm.for.branch.c", ", label %for.body.");
    output += llvmStringGlobal(".str.llvm.for.body.label", "for.body."); output += llvmStringGlobal(".str.llvm.for.end.label", "for.end.");
    output += llvmStringGlobal(".str.llvm.for.step.a", "  %"); output += llvmStringGlobal(".str.llvm.for.step.b", ".step."); output += llvmStringGlobal(".str.llvm.for.step.c", " = load i32, ptr %"); output += llvmStringGlobal(".str.llvm.for.step.d", "\n  %"); output += llvmStringGlobal(".str.llvm.for.step.e", ".next."); output += llvmStringGlobal(".str.llvm.for.step.f", " = add i32 %"); output += llvmStringGlobal(".str.llvm.for.step.g", ".step.");
    output += llvmStringGlobal(".str.llvm.for.cond.branch", ", 1\n  store i32 %"); output += llvmStringGlobal(".str.llvm.for.nl", ".next.");
    return output;
}

std::string llvmControlFlowDefinition(const char* name) {
    if (std::strcmp(name, "generateLLVMIfI32") == 0) return llvmGenerateLLVMIfI32Definition();
    if (std::strcmp(name, "generateLLVMWhileI32") == 0) return llvmGenerateLLVMWhileI32Definition();
    return llvmGenerateLLVMForI32Definition();
}

std::string llvmGenerateConditionI1Definition() {
    std::string output = R"(define ptr @generateLLVMConditionI1(ptr %arg.tokens, i32 %arg.start, i32 %arg.rawEnd, ptr %arg.resultName) {
entry:
  %end = call i32 @trimExpressionEnd(ptr %arg.tokens, i32 %arg.start, i32 %arg.rawEnd)
  %operator.kind = call i8 @kindOperator()
  %open.raw = call i32 @tokenIs(ptr %arg.tokens, i32 %arg.start, i8 %operator.kind, ptr @.str.condition.open)
  %open = icmp ne i32 %open.raw, 0
  br i1 %open, label %paren.close, label %not.check
paren.close:
  %close = call i32 @findClosingToken(ptr %arg.tokens, i32 %arg.start, i32 %end, ptr @.str.condition.open, ptr @.str.condition.close)
  %last = sub i32 %end, 1
  %wrapped = icmp eq i32 %close, %last
  br i1 %wrapped, label %paren.return, label %not.check
paren.return:
  %inner.start = add i32 %arg.start, 1
  %inner = call ptr @generateLLVMConditionI1(ptr %arg.tokens, i32 %inner.start, i32 %last, ptr %arg.resultName)
  ret ptr %inner
not.check:
  %not.raw = call i32 @tokenIs(ptr %arg.tokens, i32 %arg.start, i8 %operator.kind, ptr @.str.condition.not)
  %not = icmp ne i32 %not.raw, 0
  br i1 %not, label %not.return, label %comparison.find
not.return:
  %not.name = call ptr @csec_string_concat(ptr %arg.resultName, ptr @.str.condition.not.name)
  %not.start = add i32 %arg.start, 1
  %not.code = call ptr @generateLLVMConditionI1(ptr %arg.tokens, i32 %not.start, i32 %end, ptr %not.name)
  %n1 = call ptr @csec_string_concat(ptr %not.code, ptr @.str.condition.prefix)
  %n2 = call ptr @csec_string_concat(ptr %n1, ptr %arg.resultName)
  %n3 = call ptr @csec_string_concat(ptr %n2, ptr @.str.condition.xor)
  %not.result = call ptr @csec_string_concat(ptr %n3, ptr %not.name)
  ret ptr %not.result
comparison.find:
  %op = call i32 @findTopLevelOperator(ptr %arg.tokens, i32 %arg.start, i32 %end, i32 4)
  %has.op = icmp sgt i32 %op, %arg.start
  br i1 %has.op, label %comparison.return, label %bool.check
comparison.return:
  %op.text = call ptr @tokenTextAt(ptr %arg.tokens, i32 %op)
  %mnemonic = call ptr @irOperatorName(ptr %op.text)
  %mnemonic.length.i64 = call i64 @csec_string_length(ptr %mnemonic)
  %mnemonic.length = trunc i64 %mnemonic.length.i64 to i32
  %predicate.length = sub i32 %mnemonic.length, 5
  %predicate = call ptr @csec_string_substring(ptr %mnemonic, i32 5, i32 %predicate.length)
  %left.name = call ptr @csec_string_concat(ptr %arg.resultName, ptr @.str.condition.left)
  %left = call ptr @generateLLVMExpressionI32(ptr %arg.tokens, i32 %arg.start, i32 %op, ptr %left.name)
  %right.start = add i32 %op, 1
  %right.name = call ptr @csec_string_concat(ptr %arg.resultName, ptr @.str.condition.right)
  %right = call ptr @generateLLVMExpressionI32(ptr %arg.tokens, i32 %right.start, i32 %end, ptr %right.name)
  %c1 = call ptr @csec_string_concat(ptr %left, ptr %right)
  %c2 = call ptr @csec_string_concat(ptr %c1, ptr @.str.condition.prefix)
  %c3 = call ptr @csec_string_concat(ptr %c2, ptr %arg.resultName)
  %c4 = call ptr @csec_string_concat(ptr %c3, ptr @.str.condition.icmp)
  %c5 = call ptr @csec_string_concat(ptr %c4, ptr %predicate)
  %c6 = call ptr @csec_string_concat(ptr %c5, ptr @.str.condition.i32)
  %c7 = call ptr @csec_string_concat(ptr %c6, ptr %left.name)
  %c8 = call ptr @csec_string_concat(ptr %c7, ptr @.str.condition.comma)
  %comparison.result = call ptr @csec_string_concat(ptr %c8, ptr %right.name)
  ret ptr %comparison.result
bool.check:
  %kind = call i8 @tokenKindAt(ptr %arg.tokens, i32 %arg.start)
  %bool.kind = call i8 @kindBool()
  %is.bool = icmp eq i8 %kind, %bool.kind
  %single.end = add i32 %arg.start, 1
  %single = icmp eq i32 %end, %single.end
  %bool = and i1 %is.bool, %single
  br i1 %bool, label %bool.return, label %identifier.check
bool.return:
  %bool.text = call ptr @tokenTextAt(ptr %arg.tokens, i32 %arg.start)
  %is.true = call i1 @strEq(ptr %bool.text, ptr @.str.condition.true)
  br i1 %is.true, label %true.return, label %false.return
true.return:
  %t1 = call ptr @csec_string_concat(ptr @.str.condition.prefix, ptr %arg.resultName)
  %true.result = call ptr @csec_string_concat(ptr %t1, ptr @.str.condition.true.code)
  ret ptr %true.result
false.return:
  %f1 = call ptr @csec_string_concat(ptr @.str.condition.prefix, ptr %arg.resultName)
  %false.result = call ptr @csec_string_concat(ptr %f1, ptr @.str.condition.false.code)
  ret ptr %false.result
identifier.check:
  %identifier.kind = call i8 @kindIdentifier()
  %is.identifier = icmp eq i8 %kind, %identifier.kind
  br i1 %is.identifier, label %identifier.next, label %fallback
identifier.next:
  %name = call ptr @tokenTextAt(ptr %arg.tokens, i32 %arg.start)
  br i1 %single, label %identifier.return, label %call.check
identifier.return:
  %storage = call ptr @lookupVisibleStorageName(ptr %arg.tokens, i32 %arg.start, ptr %name)
  %i1 = call ptr @csec_string_concat(ptr @.str.condition.prefix, ptr %arg.resultName)
  %i2 = call ptr @csec_string_concat(ptr %i1, ptr @.str.condition.load)
  %identifier.result = call ptr @csec_string_concat(ptr %i2, ptr %storage)
  ret ptr %identifier.result
call.check:
  %open.index = add i32 %arg.start, 1
  %before.end = icmp slt i32 %open.index, %end
  br i1 %before.end, label %call.open.check, label %fallback
call.open.check:
  %call.open.raw = call i32 @tokenIs(ptr %arg.tokens, i32 %open.index, i8 %operator.kind, ptr @.str.condition.open)
  %call.open = icmp ne i32 %call.open.raw, 0
  br i1 %call.open, label %call.close.check, label %fallback
call.close.check:
  %call.close = call i32 @findClosingToken(ptr %arg.tokens, i32 %open.index, i32 %end, ptr @.str.condition.open, ptr @.str.condition.close)
  %call.last = sub i32 %end, 1
  %is.call = icmp eq i32 %call.close, %call.last
  br i1 %is.call, label %call.return, label %fallback
call.return:
  %args.start = add i32 %arg.start, 2
  %loads = call ptr @generateLLVMCallArgumentLoadsI32(ptr %arg.tokens, i32 %args.start, i32 %call.last, ptr %arg.resultName)
  %arguments = call ptr @generateLLVMCallArgumentListI32(ptr %arg.tokens, i32 %args.start, i32 %call.last, ptr %arg.resultName)
  %callee = call ptr @llvmRuntimeCallName(ptr %name)
  %r1 = call ptr @csec_string_concat(ptr %loads, ptr @.str.condition.prefix)
  %r2 = call ptr @csec_string_concat(ptr %r1, ptr %arg.resultName)
  %r3 = call ptr @csec_string_concat(ptr %r2, ptr @.str.condition.call)
  %r4 = call ptr @csec_string_concat(ptr %r3, ptr %callee)
  %r5 = call ptr @csec_string_concat(ptr %r4, ptr @.str.condition.open)
  %r6 = call ptr @csec_string_concat(ptr %r5, ptr %arguments)
  %call.result = call ptr @csec_string_concat(ptr %r6, ptr @.str.condition.close.nl)
  ret ptr %call.result
fallback:
  %x1 = call ptr @csec_string_concat(ptr @.str.condition.prefix, ptr %arg.resultName)
  %fallback.result = call ptr @csec_string_concat(ptr %x1, ptr @.str.condition.fallback)
  ret ptr %fallback.result
}

)";
    output += llvmStringGlobal(".str.condition.open", "(");
    output += llvmStringGlobal(".str.condition.close", ")");
    output += llvmStringGlobal(".str.condition.not", "!");
    output += llvmStringGlobal(".str.condition.not.name", ".not");
    output += llvmStringGlobal(".str.condition.prefix", "  ");
    output += llvmStringGlobal(".str.condition.xor", " = xor i1 ");
    output += llvmStringGlobal(".str.condition.left", ".left.i32");
    output += llvmStringGlobal(".str.condition.right", ".right.i32");
    output += llvmStringGlobal(".str.condition.icmp", " = icmp ");
    output += llvmStringGlobal(".str.condition.i32", " i32 ");
    output += llvmStringGlobal(".str.condition.comma", ", ");
    output += llvmStringGlobal(".str.condition.true", "true");
    output += llvmStringGlobal(".str.condition.true.code", " = icmp eq i1 true, true\n");
    output += llvmStringGlobal(".str.condition.false.code", " = icmp eq i1 false, true\n");
    output += llvmStringGlobal(".str.condition.load", " = load i1, ptr %");
    output += llvmStringGlobal(".str.condition.call", " = call i1 @");
    output += llvmStringGlobal(".str.condition.close.nl", ")\n");
    output += llvmStringGlobal(".str.condition.fallback", " = icmp eq i32 0, 0\n");
    return output;
}

std::string llvmGenerateExpressionI1Definition() {
    std::string output = R"(define ptr @generateLLVMExpressionI1(ptr %arg.tokens, i32 %arg.start, i32 %arg.rawEnd, ptr %arg.resultName) {
entry:
  %end = call i32 @trimExpressionEnd(ptr %arg.tokens, i32 %arg.start, i32 %arg.rawEnd)
  %empty = icmp sle i32 %end, %arg.start
  br i1 %empty, label %false.return, label %paren.check
false.return:
  %f1 = call ptr @csec_string_concat(ptr @.str.expr.i1.prefix, ptr %arg.resultName)
  %false.result = call ptr @csec_string_concat(ptr %f1, ptr @.str.expr.i1.false)
  ret ptr %false.result
paren.check:
  %operator.kind = call i8 @kindOperator()
  %open.raw = call i32 @tokenIs(ptr %arg.tokens, i32 %arg.start, i8 %operator.kind, ptr @.str.expr.i1.open)
  %open = icmp ne i32 %open.raw, 0
  br i1 %open, label %paren.close, label %not.check
paren.close:
  %close = call i32 @findClosingToken(ptr %arg.tokens, i32 %arg.start, i32 %end, ptr @.str.expr.i1.open, ptr @.str.expr.i1.close)
  %last = sub i32 %end, 1
  %wrapped = icmp eq i32 %close, %last
  br i1 %wrapped, label %paren.return, label %not.check
paren.return:
  %inner.start = add i32 %arg.start, 1
  %inner = call ptr @generateLLVMExpressionI1(ptr %arg.tokens, i32 %inner.start, i32 %last, ptr %arg.resultName)
  ret ptr %inner
not.check:
  %not.raw = call i32 @tokenIs(ptr %arg.tokens, i32 %arg.start, i8 %operator.kind, ptr @.str.expr.i1.not)
  %not = icmp ne i32 %not.raw, 0
  br i1 %not, label %not.return, label %bool.check
not.return:
  %not.name = call ptr @csec_string_concat(ptr %arg.resultName, ptr @.str.expr.i1.not.name)
  %not.start = add i32 %arg.start, 1
  %not.code = call ptr @generateLLVMExpressionI1(ptr %arg.tokens, i32 %not.start, i32 %end, ptr %not.name)
  %n1 = call ptr @csec_string_concat(ptr %not.code, ptr @.str.expr.i1.prefix)
  %n2 = call ptr @csec_string_concat(ptr %n1, ptr %arg.resultName)
  %n3 = call ptr @csec_string_concat(ptr %n2, ptr @.str.expr.i1.xor)
  %n4 = call ptr @csec_string_concat(ptr %n3, ptr %not.name)
  %not.result = call ptr @csec_string_concat(ptr %n4, ptr @.str.expr.i1.not.suffix)
  ret ptr %not.result
bool.check:
  %kind = call i8 @tokenKindAt(ptr %arg.tokens, i32 %arg.start)
  %bool.kind = call i8 @kindBool()
  %is.bool = icmp eq i8 %kind, %bool.kind
  %single.end = add i32 %arg.start, 1
  %single = icmp eq i32 %end, %single.end
  %bool = and i1 %is.bool, %single
  br i1 %bool, label %bool.return, label %identifier.check
bool.return:
  %bool.text = call ptr @tokenTextAt(ptr %arg.tokens, i32 %arg.start)
  %is.true = call i1 @strEq(ptr %bool.text, ptr @.str.expr.i1.true)
  br i1 %is.true, label %true.return, label %false.value.return
true.return:
  %t1 = call ptr @csec_string_concat(ptr @.str.expr.i1.prefix, ptr %arg.resultName)
  %true.result = call ptr @csec_string_concat(ptr %t1, ptr @.str.expr.i1.true.code)
  ret ptr %true.result
false.value.return:
  %v1 = call ptr @csec_string_concat(ptr @.str.expr.i1.prefix, ptr %arg.resultName)
  %value.false.result = call ptr @csec_string_concat(ptr %v1, ptr @.str.expr.i1.false)
  ret ptr %value.false.result
identifier.check:
  %identifier.kind = call i8 @kindIdentifier()
  %is.identifier = icmp eq i8 %kind, %identifier.kind
  %identifier = and i1 %is.identifier, %single
  br i1 %identifier, label %identifier.return, label %or.find
identifier.return:
  %name = call ptr @tokenTextAt(ptr %arg.tokens, i32 %arg.start)
  %storage = call ptr @lookupVisibleStorageName(ptr %arg.tokens, i32 %arg.start, ptr %name)
  %i1 = call ptr @csec_string_concat(ptr @.str.expr.i1.prefix, ptr %arg.resultName)
  %i2 = call ptr @csec_string_concat(ptr %i1, ptr @.str.expr.i1.load)
  %identifier.result = call ptr @csec_string_concat(ptr %i2, ptr %storage)
  ret ptr %identifier.result
or.find:
  %or.op = call i32 @findTopLevelOperator(ptr %arg.tokens, i32 %arg.start, i32 %end, i32 2)
  %has.or = icmp sgt i32 %or.op, %arg.start
  br i1 %has.or, label %or.return, label %and.find
or.return:
  %or.left.name = call ptr @csec_string_concat(ptr %arg.resultName, ptr @.str.expr.i1.left)
  %or.left = call ptr @generateLLVMExpressionI1(ptr %arg.tokens, i32 %arg.start, i32 %or.op, ptr %or.left.name)
  %or.right.start = add i32 %or.op, 1
  %or.right.name = call ptr @csec_string_concat(ptr %arg.resultName, ptr @.str.expr.i1.right)
  %or.right = call ptr @generateLLVMExpressionI1(ptr %arg.tokens, i32 %or.right.start, i32 %end, ptr %or.right.name)
  %o1 = call ptr @csec_string_concat(ptr %or.left, ptr %or.right)
  %o2 = call ptr @csec_string_concat(ptr %o1, ptr @.str.expr.i1.prefix)
  %o3 = call ptr @csec_string_concat(ptr %o2, ptr %arg.resultName)
  %o4 = call ptr @csec_string_concat(ptr %o3, ptr @.str.expr.i1.or)
  %o5 = call ptr @csec_string_concat(ptr %o4, ptr %or.left.name)
  %o6 = call ptr @csec_string_concat(ptr %o5, ptr @.str.expr.i1.comma)
  %or.result = call ptr @csec_string_concat(ptr %o6, ptr %or.right.name)
  ret ptr %or.result
and.find:
  %and.op = call i32 @findTopLevelOperator(ptr %arg.tokens, i32 %arg.start, i32 %end, i32 3)
  %has.and = icmp sgt i32 %and.op, %arg.start
  br i1 %has.and, label %and.return, label %condition.return
and.return:
  %and.left.name = call ptr @csec_string_concat(ptr %arg.resultName, ptr @.str.expr.i1.left)
  %and.left = call ptr @generateLLVMExpressionI1(ptr %arg.tokens, i32 %arg.start, i32 %and.op, ptr %and.left.name)
  %and.right.start = add i32 %and.op, 1
  %and.right.name = call ptr @csec_string_concat(ptr %arg.resultName, ptr @.str.expr.i1.right)
  %and.right = call ptr @generateLLVMExpressionI1(ptr %arg.tokens, i32 %and.right.start, i32 %end, ptr %and.right.name)
  %a1 = call ptr @csec_string_concat(ptr %and.left, ptr %and.right)
  %a2 = call ptr @csec_string_concat(ptr %a1, ptr @.str.expr.i1.prefix)
  %a3 = call ptr @csec_string_concat(ptr %a2, ptr %arg.resultName)
  %a4 = call ptr @csec_string_concat(ptr %a3, ptr @.str.expr.i1.and)
  %a5 = call ptr @csec_string_concat(ptr %a4, ptr %and.left.name)
  %a6 = call ptr @csec_string_concat(ptr %a5, ptr @.str.expr.i1.comma)
  %and.result = call ptr @csec_string_concat(ptr %a6, ptr %and.right.name)
  ret ptr %and.result
condition.return:
  %condition = call ptr @generateLLVMConditionI1(ptr %arg.tokens, i32 %arg.start, i32 %end, ptr %arg.resultName)
  ret ptr %condition
}

)";
    output += llvmStringGlobal(".str.expr.i1.prefix", "  ");
    output += llvmStringGlobal(".str.expr.i1.false", " = icmp eq i1 false, true\n");
    output += llvmStringGlobal(".str.expr.i1.true", "true");
    output += llvmStringGlobal(".str.expr.i1.true.code", " = icmp eq i1 true, true\n");
    output += llvmStringGlobal(".str.expr.i1.open", "(");
    output += llvmStringGlobal(".str.expr.i1.close", ")");
    output += llvmStringGlobal(".str.expr.i1.not", "!");
    output += llvmStringGlobal(".str.expr.i1.not.name", ".not");
    output += llvmStringGlobal(".str.expr.i1.xor", " = xor i1 ");
    output += llvmStringGlobal(".str.expr.i1.not.suffix", ", true\n");
    output += llvmStringGlobal(".str.expr.i1.load", " = load i1, ptr %");
    output += llvmStringGlobal(".str.expr.i1.left", ".left");
    output += llvmStringGlobal(".str.expr.i1.right", ".right");
    output += llvmStringGlobal(".str.expr.i1.or", " = or i1 ");
    output += llvmStringGlobal(".str.expr.i1.and", " = and i1 ");
    output += llvmStringGlobal(".str.expr.i1.comma", ", ");
    return output;
}

