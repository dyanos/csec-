; ModuleID = 'csec.selfhost'
source_filename = "csec.selfhost"

declare i64 @csec_string_length(ptr)
declare i8 @csec_string_char_at(ptr, i32)

declare i64 @csec_string_builder_new()
declare i32 @csec_string_builder_append(i64, ptr)
declare ptr @csec_string_builder_finish(i64)
declare i32 @csec_string_builder_write_to_file(i64, ptr)
declare void @csec_set_command_line_args(i32, ptr)
declare i32 @csec_command_line_arg_count()
declare ptr @csec_command_line_arg(i32)
declare ptr @csec_file_read_all_text(ptr)
declare i32 @csec_file_write_all_text(ptr, ptr)
declare void @csec_print_string(ptr)
declare void @csec_print_newline()
declare ptr @csec_string_concat(ptr, ptr)
declare i32 @csec_string_starts_with(ptr, ptr)
declare ptr @csec_string_substring(ptr, i32, i32)
declare ptr @csec_to_string_i64(i64)
declare ptr @csec_to_string_char(i8)
declare ptr @csec_token_append_owned(ptr, i8, ptr)
declare i64 @csec_token_builder_new()
declare i32 @csec_token_builder_append(i64, i8, ptr)
declare ptr @csec_token_builder_finish(i64)
declare ptr @csec_tokenize_source(ptr)
declare i8 @csec_token_kind_at(ptr, i32)
declare ptr @csec_token_text_at(ptr, i32)
declare i32 @csec_token_is(ptr, i32, i8, ptr)
declare i32 @csec_advance_statement(ptr, i32, i32)
declare i32 @csec_advance_top_level_decl(ptr, i32)
declare i32 @csec_find_decl_body_start(ptr, i32)
declare i32 @csec_find_decl_body_end(ptr, i32)
declare i32 @csec_function_param_end(ptr, i32)
declare ptr @csec_function_llvm_param_list(ptr, i32)
declare ptr @csec_function_llvm_param_allocas(ptr, i32)
declare ptr @csec_llvm_name_with_number(ptr, i32)
declare ptr @csec_function_return_type_at(ptr, i32)
declare i32 @csec_enclosing_function_decl_start(ptr, i32)
declare i32 @csec_enclosing_function_body_start(ptr, i32)
declare i32 @csec_enclosing_function_body_end(ptr, i32)
declare ptr @csec_lookup_function_return_type(ptr, ptr)
declare ptr @csec_expand_imports(ptr)

define i8 @kindIdentifier() {
entry:
  ret i8 73
}

define i8 @kindKeyword() {
entry:
  ret i8 75
}

define i8 @kindInteger() {
entry:
  ret i8 78
}

define i8 @kindFloat() {
entry:
  ret i8 70
}

define i8 @kindString() {
entry:
  ret i8 83
}

define i8 @kindRegex() {
entry:
  ret i8 82
}

define i8 @kindChar() {
entry:
  ret i8 67
}

define i8 @kindBool() {
entry:
  ret i8 66
}

define i8 @kindOperator() {
entry:
  ret i8 79
}

define i8 @kindComment() {
entry:
  ret i8 77
}

define i8 @kindEof() {
entry:
  ret i8 69
}

define i1 @isWhitespace(i8 %arg.ch) {
entry:
  %ch = alloca i8
  store i8 %arg.ch, ptr %ch
  %ret.226.left = icmp eq i32 0, 0
  %ret.226.right.left.i8 = load i8, ptr %ch
  %ret.226.right = icmp eq i8 %ret.226.right.left.i8, 0
  %ret.226 = or i1 %ret.226.left, %ret.226.right
  ; bool operands %btmp, %btmp
  ret i1 %ret.226
}

define i1 @isDigit(i8 %arg.ch) {
entry:
  %ch = alloca i8
  store i8 %arg.ch, ptr %ch
  %ret.259.left.left.i8 = load i8, ptr %ch
  %ret.259.left = icmp sge i8 %ret.259.left.left.i8, 48
  %ret.259.right.left.i8 = load i8, ptr %ch
  %ret.259.right = icmp sle i8 %ret.259.right.left.i8, 57
  %ret.259 = and i1 %ret.259.left, %ret.259.right
  ; bool operands %btmp, %btmp
  ret i1 %ret.259
}

define i32 @digitValue(i8 %arg.ch) {
entry:
  %ch = alloca i8
  store i8 %arg.ch, ptr %ch
  ret i32 0
}

define i32 @toInt(ptr %arg.text) {
entry:
  %text = alloca ptr
  store ptr %arg.text, ptr %text
  ret i32 0
}

define i1 @isAlpha(i8 %arg.ch) {
entry:
  %ch = alloca i8
  store i8 %arg.ch, ptr %ch
  %ret.473 = icmp eq i32 0, 0
  ret i1 %ret.473
}

define i1 @isIdentifierStart(i8 %arg.ch) {
entry:
  %ch = alloca i8
  store i8 %arg.ch, ptr %ch
  %ret.505.left = icmp eq i32 0, 0
  %ret.505.right.left.i8 = load i8, ptr %ch
  %ret.505.right = icmp eq i8 %ret.505.right.left.i8, 95
  %ret.505 = or i1 %ret.505.left, %ret.505.right
  ; bool operands %btmp, %btmp
  ret i1 %ret.505
}

define i1 @isIdentifierPart(i8 %arg.ch) {
entry:
  %ch = alloca i8
  store i8 %arg.ch, ptr %ch
  %ret.526 = icmp eq i32 0, 0
  ret i1 %ret.526
}

define i1 @strEq(ptr %arg.left, ptr %arg.right) {
entry:
  %left = alloca ptr
  store ptr %arg.left, ptr %left
  %right = alloca ptr
  store ptr %arg.right, ptr %right
  %ret.552 = icmp eq i32 0, 0
  ret i1 %ret.552
}

define i1 @isKeyword(ptr %arg.text) {
entry:
  %text = alloca ptr
  store ptr %arg.text, ptr %text
  %ret.579 = icmp eq i32 0, 0
  ret i1 %ret.579
}

define ptr @appendToken(ptr %arg.tokens, i8 %arg.kind, ptr %arg.text) {
entry:
  %tokens = alloca ptr
  store ptr %arg.tokens, ptr %tokens
  %kind = alloca i8
  store i8 %arg.kind, ptr %kind
  %text = alloca ptr
  store ptr %arg.text, ptr %text
  ret ptr null
}

define i32 @appendTokenTo(i64 %arg.builder, i8 %arg.kind, ptr %arg.text) {
entry:
  %builder = alloca i64
  store i64 %arg.builder, ptr %builder
  %kind = alloca i8
  store i8 %arg.kind, ptr %kind
  %text = alloca ptr
  store ptr %arg.text, ptr %text
  ret i32 0
}

define i1 @twoChars(ptr %arg.source, i32 %arg.index, ptr %arg.text) {
entry:
  %source = alloca ptr
  store ptr %arg.source, ptr %source
  %index = alloca i32
  store i32 %arg.index, ptr %index
  %text = alloca ptr
  store ptr %arg.text, ptr %text
  %ret.1015 = icmp eq i32 0, 0
  ret i1 %ret.1015
}

define i1 @threeChars(ptr %arg.source, i32 %arg.index, ptr %arg.text) {
entry:
  %source = alloca ptr
  store ptr %arg.source, ptr %source
  %index = alloca i32
  store i32 %arg.index, ptr %index
  %text = alloca ptr
  store ptr %arg.text, ptr %text
  %ret.1080 = icmp eq i32 0, 0
  ret i1 %ret.1080
}

define i32 @lexIdentifier(ptr %arg.source, i32 %arg.index) {
entry:
  %source = alloca ptr
  store ptr %arg.source, ptr %source
  %index = alloca i32
  store i32 %arg.index, ptr %index
  ret i32 0
}

define i32 @lexNumber(ptr %arg.source, i32 %arg.index) {
entry:
  %source = alloca ptr
  store ptr %arg.source, ptr %source
  %index = alloca i32
  store i32 %arg.index, ptr %index
  ret i32 0
}

define i32 @lexQuoted(ptr %arg.source, i32 %arg.index) {
entry:
  %source = alloca ptr
  store ptr %arg.source, ptr %source
  %index = alloca i32
  store i32 %arg.index, ptr %index
  ret i32 0
}

define i32 @lexLineComment(ptr %arg.source, i32 %arg.index) {
entry:
  %source = alloca ptr
  store ptr %arg.source, ptr %source
  %index = alloca i32
  store i32 %arg.index, ptr %index
  ret i32 0
}

define i32 @lexBlockComment(ptr %arg.source, i32 %arg.index) {
entry:
  %source = alloca ptr
  store ptr %arg.source, ptr %source
  %index = alloca i32
  store i32 %arg.index, ptr %index
  ret i32 0
}

define i32 @operatorLength(ptr %arg.source, i32 %arg.index) {
entry:
  %source = alloca ptr
  store ptr %arg.source, ptr %source
  %index = alloca i32
  store i32 %arg.index, ptr %index
  ret i32 0
}

define ptr @repairLeadingRTokenText(ptr %arg.text) {
entry:
  %text = alloca ptr
  store ptr %arg.text, ptr %text
  %ret.1921 = load ptr, ptr %text
  ret ptr %ret.1921
}

define ptr @slice(ptr %arg.source, i32 %arg.start, i32 %arg.end) {
entry:
  %source = alloca ptr
  store ptr %arg.source, ptr %source
  %start = alloca i32
  store i32 %arg.start, ptr %start
  %end = alloca i32
  store i32 %arg.end, ptr %end
  ret ptr null
}

define ptr @tokenize(ptr %arg.source) {
entry:
  %source = alloca ptr
  store ptr %arg.source, ptr %source
  ret ptr null
}

define ptr @tokenizeSlow(ptr %arg.source) {
entry:
  %source = alloca ptr
  store ptr %arg.source, ptr %source
  ret ptr null
}

define i32 @lineStart(ptr %arg.tokens, i32 %arg.ordinal) {
entry:
  %tokens = alloca ptr
  store ptr %arg.tokens, ptr %tokens
  %ordinal = alloca i32
  store i32 %arg.ordinal, ptr %ordinal
  ret i32 0
}

define i32 @lineEnd(ptr %arg.tokens, i32 %arg.start) {
entry:
  %tokens = alloca ptr
  store ptr %arg.tokens, ptr %tokens
  %start = alloca i32
  store i32 %arg.start, ptr %start
  ret i32 0
}

define i8 @tokenKindAt(ptr %arg.tokens, i32 %arg.ordinal) {
entry:
  %tokens = alloca ptr
  store ptr %arg.tokens, ptr %tokens
  %ordinal = alloca i32
  store i32 %arg.ordinal, ptr %ordinal
  ret i8 0
}

define ptr @tokenTextAt(ptr %arg.tokens, i32 %arg.ordinal) {
entry:
  %tokens = alloca ptr
  store ptr %arg.tokens, ptr %tokens
  %ordinal = alloca i32
  store i32 %arg.ordinal, ptr %ordinal
  ret ptr null
}

define i1 @tokenIs(ptr %arg.tokens, i32 %arg.ordinal, i8 %arg.kind, ptr %arg.text) {
entry:
  %tokens = alloca ptr
  store ptr %arg.tokens, ptr %tokens
  %ordinal = alloca i32
  store i32 %arg.ordinal, ptr %ordinal
  %kind = alloca i8
  store i8 %arg.kind, ptr %kind
  %text = alloca ptr
  store ptr %arg.text, ptr %text
  %token.is = call i32 @csec_token_is(ptr %arg.tokens, i32 %arg.ordinal, i8 %arg.kind, ptr %arg.text)
  %token.is.bool = icmp ne i32 %token.is, 0
  ret i1 %token.is.bool
}

define i32 @skipTrivia(ptr %arg.tokens, i32 %arg.ordinal) {
entry:
  %tokens = alloca ptr
  store ptr %arg.tokens, ptr %tokens
  %ordinal = alloca i32
  store i32 %arg.ordinal, ptr %ordinal
  ret i32 0
}

define i1 @validateBalanced(ptr %arg.tokens) {
entry:
  %tokens = alloca ptr
  store ptr %arg.tokens, ptr %tokens
  %ret.3435.left.left.left.i32 = load i32, ptr %paren.addr.3238
  %ret.3435.left.right.left.i32 = load i32, ptr %brace.addr.3245
  %ret.3435.left = and i1 %ret.3435.left.left, %ret.3435.left.right
  ; bool operands %btmp, %btmp
  %ret.3435.right.left.i32 = load i32, ptr %bracket.addr.3252
  %ret.3435 = and i1 %ret.3435.left, %ret.3435.right
  ; bool operands %btmp, %btmp
  ret i1 %ret.3435
}

define i1 @startsTopLevelDeclaration(ptr %arg.tokens, i32 %arg.ordinal) {
entry:
  %tokens = alloca ptr
  store ptr %arg.tokens, ptr %tokens
  %ordinal = alloca i32
  store i32 %arg.ordinal, ptr %ordinal
  %ret.3520 = icmp eq i32 0, 0
  ret i1 %ret.3520
}

define i1 @validateTopLevel(ptr %arg.tokens) {
entry:
  %tokens = alloca ptr
  store ptr %arg.tokens, ptr %tokens
  %ret.3903 = icmp eq i1 true, true
  ret i1 %ret.3903
}

define i1 @parseProgram(ptr %arg.tokens) {
entry:
  %tokens = alloca ptr
  store ptr %arg.tokens, ptr %tokens
  %ret.3943 = icmp eq i32 0, 0
  ret i1 %ret.3943
}

define ptr @topLevelDeclKind(ptr %arg.tokens, i32 %arg.ordinal) {
entry:
  %tokens = alloca ptr
  store ptr %arg.tokens, ptr %tokens
  %ordinal = alloca i32
  store i32 %arg.ordinal, ptr %ordinal
  %ret.4222 = getelementptr inbounds [8 x i8], ptr @.str.0, i32 0, i32 0
  ret ptr %ret.4222
}

define ptr @topLevelDeclName(ptr %arg.tokens, i32 %arg.ordinal) {
entry:
  %tokens = alloca ptr
  store ptr %arg.tokens, ptr %tokens
  %ordinal = alloca i32
  store i32 %arg.ordinal, ptr %ordinal
  %ret.4516 = getelementptr inbounds [12 x i8], ptr @.str.0, i32 0, i32 0
  ret ptr %ret.4516
}

define i32 @advanceTopLevelDecl(ptr %arg.tokens, i32 %arg.ordinal) {
entry:
  %tokens = alloca ptr
  store ptr %arg.tokens, ptr %tokens
  %ordinal = alloca i32
  store i32 %arg.ordinal, ptr %ordinal
  ret i32 0
}

define i32 @advanceTopLevelDeclSlow(ptr %arg.tokens, i32 %arg.ordinal) {
entry:
  %tokens = alloca ptr
  store ptr %arg.tokens, ptr %tokens
  %ordinal = alloca i32
  store i32 %arg.ordinal, ptr %ordinal
  ret i32 0
}

define i32 @findDeclBodyStart(ptr %arg.tokens, i32 %arg.ordinal) {
entry:
  %tokens = alloca ptr
  store ptr %arg.tokens, ptr %tokens
  %ordinal = alloca i32
  store i32 %arg.ordinal, ptr %ordinal
  ret i32 0
}

define i32 @findDeclBodyStartSlow(ptr %arg.tokens, i32 %arg.ordinal) {
entry:
  %tokens = alloca ptr
  store ptr %arg.tokens, ptr %tokens
  %ordinal = alloca i32
  store i32 %arg.ordinal, ptr %ordinal
  ret i32 0
}

define i32 @findDeclBodyEnd(ptr %arg.tokens, i32 %arg.bodyStart) {
entry:
  %tokens = alloca ptr
  store ptr %arg.tokens, ptr %tokens
  %bodyStart = alloca i32
  store i32 %arg.bodyStart, ptr %bodyStart
  ret i32 0
}

define i32 @findDeclBodyEndSlow(ptr %arg.tokens, i32 %arg.bodyStart) {
entry:
  %tokens = alloca ptr
  store ptr %arg.tokens, ptr %tokens
  %bodyStart = alloca i32
  store i32 %arg.bodyStart, ptr %bodyStart
  ret i32 0
}

define ptr @statementKind(ptr %arg.tokens, i32 %arg.ordinal) {
entry:
  %tokens = alloca ptr
  store ptr %arg.tokens, ptr %tokens
  %ordinal = alloca i32
  store i32 %arg.ordinal, ptr %ordinal
  %ret.5403 = getelementptr inbounds [11 x i8], ptr @.str.0, i32 0, i32 0
  ret ptr %ret.5403
}

define ptr @appendExpressionUntil(ptr %arg.tokens, i32 %arg.start, i32 %arg.end) {
entry:
  %tokens = alloca ptr
  store ptr %arg.tokens, ptr %tokens
  %start = alloca i32
  store i32 %arg.start, ptr %start
  %end = alloca i32
  store i32 %arg.end, ptr %end
  %ret.5491 = load ptr, ptr %output.addr.5432
  ret ptr %ret.5491
}

define i1 @tokenIsTopLevelOperator(ptr %arg.tokens, i32 %arg.ordinal, i32 %arg.group) {
entry:
  %tokens = alloca ptr
  store ptr %arg.tokens, ptr %tokens
  %ordinal = alloca i32
  store i32 %arg.ordinal, ptr %ordinal
  %group = alloca i32
  store i32 %arg.group, ptr %group
  %ret.5991 = icmp eq i1 false, true
  ret i1 %ret.5991
}

define i32 @findTopLevelOperator(ptr %arg.tokens, i32 %arg.start, i32 %arg.end, i32 %arg.group) {
entry:
  %tokens = alloca ptr
  store ptr %arg.tokens, ptr %tokens
  %start = alloca i32
  store i32 %arg.start, ptr %start
  %end = alloca i32
  store i32 %arg.end, ptr %end
  %group = alloca i32
  store i32 %arg.group, ptr %group
  ret i32 0
}

define i32 @findTopLevelMatch(ptr %arg.tokens, i32 %arg.start, i32 %arg.end) {
entry:
  %tokens = alloca ptr
  store ptr %arg.tokens, ptr %tokens
  %start = alloca i32
  store i32 %arg.start, ptr %start
  %end = alloca i32
  store i32 %arg.end, ptr %end
  ret i32 0
}

define i32 @findClosingToken(ptr %arg.tokens, i32 %arg.openOrdinal, i32 %arg.end, ptr %arg.openText, ptr %arg.closeText) {
entry:
  %tokens = alloca ptr
  store ptr %arg.tokens, ptr %tokens
  %openOrdinal = alloca i32
  store i32 %arg.openOrdinal, ptr %openOrdinal
  %end = alloca i32
  store i32 %arg.end, ptr %end
  %openText = alloca ptr
  store ptr %arg.openText, ptr %openText
  %closeText = alloca ptr
  store ptr %arg.closeText, ptr %closeText
  ret i32 0
}

define i32 @trimExpressionEnd(ptr %arg.tokens, i32 %arg.start, i32 %arg.end) {
entry:
  %tokens = alloca ptr
  store ptr %arg.tokens, ptr %tokens
  %start = alloca i32
  store i32 %arg.start, ptr %start
  %end = alloca i32
  store i32 %arg.end, ptr %end
  ret i32 0
}

define ptr @expressionLeafKind(ptr %arg.tokens, i32 %arg.start, i32 %arg.end) {
entry:
  %tokens = alloca ptr
  store ptr %arg.tokens, ptr %tokens
  %start = alloca i32
  store i32 %arg.start, ptr %start
  %end = alloca i32
  store i32 %arg.end, ptr %end
  %ret.6907 = getelementptr inbounds [8 x i8], ptr @.str.0, i32 0, i32 0
  ret ptr %ret.6907
}

define i32 @findTokenTextInRange(ptr %arg.tokens, i32 %arg.start, i32 %arg.end, ptr %arg.text) {
entry:
  %tokens = alloca ptr
  store ptr %arg.tokens, ptr %tokens
  %start = alloca i32
  store i32 %arg.start, ptr %start
  %end = alloca i32
  store i32 %arg.end, ptr %end
  %text = alloca ptr
  store ptr %arg.text, ptr %text
  ret i32 0
}

define i32 @countMatchCases(ptr %arg.tokens, i32 %arg.matchOrdinal, i32 %arg.end) {
entry:
  %tokens = alloca ptr
  store ptr %arg.tokens, ptr %tokens
  %matchOrdinal = alloca i32
  store i32 %arg.matchOrdinal, ptr %matchOrdinal
  %end = alloca i32
  store i32 %arg.end, ptr %end
  ret i32 0
}

define i32 @findStatementParenStart(ptr %arg.tokens, i32 %arg.start, i32 %arg.end) {
entry:
  %tokens = alloca ptr
  store ptr %arg.tokens, ptr %tokens
  %start = alloca i32
  store i32 %arg.start, ptr %start
  %end = alloca i32
  store i32 %arg.end, ptr %end
  ret i32 0
}

define i32 @findStatementParenEnd(ptr %arg.tokens, i32 %arg.start, i32 %arg.end) {
entry:
  %tokens = alloca ptr
  store ptr %arg.tokens, ptr %tokens
  %start = alloca i32
  store i32 %arg.start, ptr %start
  %end = alloca i32
  store i32 %arg.end, ptr %end
  ret i32 0
}

define i32 @findStatementBlockStart(ptr %arg.tokens, i32 %arg.start, i32 %arg.end) {
entry:
  %tokens = alloca ptr
  store ptr %arg.tokens, ptr %tokens
  %start = alloca i32
  store i32 %arg.start, ptr %start
  %end = alloca i32
  store i32 %arg.end, ptr %end
  ret i32 0
}

define i32 @findStatementBlockEnd(ptr %arg.tokens, i32 %arg.start, i32 %arg.end) {
entry:
  %tokens = alloca ptr
  store ptr %arg.tokens, ptr %tokens
  %start = alloca i32
  store i32 %arg.start, ptr %start
  %end = alloca i32
  store i32 %arg.end, ptr %end
  ret i32 0
}

define ptr @statementHeaderExpression(ptr %arg.tokens, i32 %arg.start, i32 %arg.end) {
entry:
  %tokens = alloca ptr
  store ptr %arg.tokens, ptr %tokens
  %start = alloca i32
  store i32 %arg.start, ptr %start
  %end = alloca i32
  store i32 %arg.end, ptr %end
  %ret.7406 = getelementptr inbounds [1 x i8], ptr @.str.0, i32 0, i32 0
  ret ptr %ret.7406
}

define i32 @countCommaSeparated(ptr %arg.tokens, i32 %arg.start, i32 %arg.end) {
entry:
  %tokens = alloca ptr
  store ptr %arg.tokens, ptr %tokens
  %start = alloca i32
  store i32 %arg.start, ptr %start
  %end = alloca i32
  store i32 %arg.end, ptr %end
  ret i32 0
}

define i32 @findLastTopLevelToken(ptr %arg.tokens, i32 %arg.start, i32 %arg.end, ptr %arg.text) {
entry:
  %tokens = alloca ptr
  store ptr %arg.tokens, ptr %tokens
  %start = alloca i32
  store i32 %arg.start, ptr %start
  %end = alloca i32
  store i32 %arg.end, ptr %end
  %text = alloca ptr
  store ptr %arg.text, ptr %text
  ret i32 0
}

define ptr @summarizePostfixExpression(ptr %arg.tokens, i32 %arg.start, i32 %arg.end) {
entry:
  %tokens = alloca ptr
  store ptr %arg.tokens, ptr %tokens
  %start = alloca i32
  store i32 %arg.start, ptr %start
  %end = alloca i32
  store i32 %arg.end, ptr %end
  %ret.8116 = getelementptr inbounds [1 x i8], ptr @.str.0, i32 0, i32 0
  ret ptr %ret.8116
}

define i32 @findLambdaArrow(ptr %arg.tokens, i32 %arg.start, i32 %arg.end) {
entry:
  %tokens = alloca ptr
  store ptr %arg.tokens, ptr %tokens
  %start = alloca i32
  store i32 %arg.start, ptr %start
  %end = alloca i32
  store i32 %arg.end, ptr %end
  ret i32 0
}

define ptr @lambdaCaptureSummary(ptr %arg.tokens, i32 %arg.start, i32 %arg.end) {
entry:
  %tokens = alloca ptr
  store ptr %arg.tokens, ptr %tokens
  %start = alloca i32
  store i32 %arg.start, ptr %start
  %end = alloca i32
  store i32 %arg.end, ptr %end
  ret ptr null
}

define i32 @lambdaParameterCount(ptr %arg.tokens, i32 %arg.start, i32 %arg.end) {
entry:
  %tokens = alloca ptr
  store ptr %arg.tokens, ptr %tokens
  %start = alloca i32
  store i32 %arg.start, ptr %start
  %end = alloca i32
  store i32 %arg.end, ptr %end
  ret i32 0
}

define ptr @summarizeLambdaExpression(ptr %arg.tokens, i32 %arg.start, i32 %arg.end) {
entry:
  %tokens = alloca ptr
  store ptr %arg.tokens, ptr %tokens
  %start = alloca i32
  store i32 %arg.start, ptr %start
  %end = alloca i32
  store i32 %arg.end, ptr %end
  ret ptr null
}

define ptr @generateExpressionAST(ptr %arg.tokens, i32 %arg.rawStart, i32 %arg.rawEnd) {
entry:
  %tokens = alloca ptr
  store ptr %arg.tokens, ptr %tokens
  %rawStart = alloca i32
  store i32 %arg.rawStart, ptr %rawStart
  %rawEnd = alloca i32
  store i32 %arg.rawEnd, ptr %rawEnd
  ret ptr null
}

define i32 @advanceStatement(ptr %arg.tokens, i32 %arg.ordinal, i32 %arg.bodyEnd) {
entry:
  %tokens = alloca ptr
  store ptr %arg.tokens, ptr %tokens
  %ordinal = alloca i32
  store i32 %arg.ordinal, ptr %ordinal
  %bodyEnd = alloca i32
  store i32 %arg.bodyEnd, ptr %bodyEnd
  ret i32 0
}

define i32 @advanceStatementSlow(ptr %arg.tokens, i32 %arg.ordinal, i32 %arg.bodyEnd) {
entry:
  %tokens = alloca ptr
  store ptr %arg.tokens, ptr %tokens
  %ordinal = alloca i32
  store i32 %arg.ordinal, ptr %ordinal
  %bodyEnd = alloca i32
  store i32 %arg.bodyEnd, ptr %bodyEnd
  ret i32 0
}

define ptr @generateStatementAST(ptr %arg.tokens, i32 %arg.start, i32 %arg.end) {
entry:
  %tokens = alloca ptr
  store ptr %arg.tokens, ptr %tokens
  %start = alloca i32
  store i32 %arg.start, ptr %start
  %end = alloca i32
  store i32 %arg.end, ptr %end
  %ret.10603.right = getelementptr inbounds [2 x i8], ptr @.str.10615, i32 0, i32 0
  %ret.10603 = call ptr @csec_string_concat(ptr %ret.10603.left, ptr %ret.10603.right)
  ret ptr %ret.10603
}

define ptr @generateBodyAST(ptr %arg.tokens, i32 %arg.bodyStart, i32 %arg.bodyEnd) {
entry:
  %tokens = alloca ptr
  store ptr %arg.tokens, ptr %tokens
  %bodyStart = alloca i32
  store i32 %arg.bodyStart, ptr %bodyStart
  %bodyEnd = alloca i32
  store i32 %arg.bodyEnd, ptr %bodyEnd
  %ret.10727 = load ptr, ptr %output.addr.10636
  ret ptr %ret.10727
}

define i32 @findFunctionParamStart(ptr %arg.tokens, i32 %arg.declStart) {
entry:
  %tokens = alloca ptr
  store ptr %arg.tokens, ptr %tokens
  %declStart = alloca i32
  store i32 %arg.declStart, ptr %declStart
  ret i32 0
}

define i32 @findFunctionReturnTypeStart(ptr %arg.tokens, i32 %arg.declStart) {
entry:
  %tokens = alloca ptr
  store ptr %arg.tokens, ptr %tokens
  %declStart = alloca i32
  store i32 %arg.declStart, ptr %declStart
  ret i32 0
}

define ptr @collectTypeName(ptr %arg.tokens, i32 %arg.start, i32 %arg.end) {
entry:
  %tokens = alloca ptr
  store ptr %arg.tokens, ptr %tokens
  %start = alloca i32
  store i32 %arg.start, ptr %start
  %end = alloca i32
  store i32 %arg.end, ptr %end
  %ret.11044 = load ptr, ptr %output.addr.10959
  ret ptr %ret.11044
}

define ptr @functionReturnType(ptr %arg.tokens, i32 %arg.declStart) {
entry:
  %tokens = alloca ptr
  store ptr %arg.tokens, ptr %tokens
  %declStart = alloca i32
  store i32 %arg.declStart, ptr %declStart
  ret ptr null
}

define ptr @functionReturnTypeSlow(ptr %arg.tokens, i32 %arg.declStart) {
entry:
  %tokens = alloca ptr
  store ptr %arg.tokens, ptr %tokens
  %declStart = alloca i32
  store i32 %arg.declStart, ptr %declStart
  %ret.11147 = load ptr, ptr %typeName.addr.11120
  ret ptr %ret.11147
}

define i32 @countFunctionParams(ptr %arg.tokens, i32 %arg.declStart) {
entry:
  %tokens = alloca ptr
  store ptr %arg.tokens, ptr %tokens
  %declStart = alloca i32
  store i32 %arg.declStart, ptr %declStart
  ret i32 0
}

define ptr @typeSummary(ptr %arg.tokens, i32 %arg.start, i32 %arg.end) {
entry:
  %tokens = alloca ptr
  store ptr %arg.tokens, ptr %tokens
  %start = alloca i32
  store i32 %arg.start, ptr %start
  %end = alloca i32
  store i32 %arg.end, ptr %end
  ret ptr null
}

define ptr @declaredValueType(ptr %arg.tokens, i32 %arg.declStart, i32 %arg.declEnd) {
entry:
  %tokens = alloca ptr
  store ptr %arg.tokens, ptr %tokens
  %declStart = alloca i32
  store i32 %arg.declStart, ptr %declStart
  %declEnd = alloca i32
  store i32 %arg.declEnd, ptr %declEnd
  %ret.11507 = getelementptr inbounds [6 x i8], ptr @.str.0, i32 0, i32 0
  ret ptr %ret.11507
}

define ptr @lookupFunctionReturnType(ptr %arg.tokens, ptr %arg.name) {
entry:
  %tokens = alloca ptr
  store ptr %arg.tokens, ptr %tokens
  %name = alloca ptr
  store ptr %arg.name, ptr %name
  %ret.11645 = getelementptr inbounds [8 x i8], ptr @.str.0, i32 0, i32 0
  ret ptr %ret.11645
}

define ptr @inferExpressionType(ptr %arg.tokens, i32 %arg.rawStart, i32 %arg.rawEnd) {
entry:
  %tokens = alloca ptr
  store ptr %arg.tokens, ptr %tokens
  %rawStart = alloca i32
  store i32 %arg.rawStart, ptr %rawStart
  %rawEnd = alloca i32
  store i32 %arg.rawEnd, ptr %rawEnd
  %ret.12274 = getelementptr inbounds [8 x i8], ptr @.str.0, i32 0, i32 0
  ret ptr %ret.12274
}

define ptr @declaredLocalType(ptr %arg.tokens, i32 %arg.start, i32 %arg.end) {
entry:
  %tokens = alloca ptr
  store ptr %arg.tokens, ptr %tokens
  %start = alloca i32
  store i32 %arg.start, ptr %start
  %end = alloca i32
  store i32 %arg.end, ptr %end
  %ret.12390 = getelementptr inbounds [1 x i8], ptr @.str.0, i32 0, i32 0
  ret ptr %ret.12390
}

define ptr @localDeclarationType(ptr %arg.tokens, i32 %arg.start, i32 %arg.end) {
entry:
  %tokens = alloca ptr
  store ptr %arg.tokens, ptr %tokens
  %start = alloca i32
  store i32 %arg.start, ptr %start
  %end = alloca i32
  store i32 %arg.end, ptr %end
  %ret.12475 = getelementptr inbounds [8 x i8], ptr @.str.0, i32 0, i32 0
  ret ptr %ret.12475
}

define ptr @generateFunctionScopeSymbols(ptr %arg.tokens, ptr %arg.functionName, i32 %arg.bodyStart, i32 %arg.bodyEnd) {
entry:
  %tokens = alloca ptr
  store ptr %arg.tokens, ptr %tokens
  %functionName = alloca ptr
  store ptr %arg.functionName, ptr %functionName
  %bodyStart = alloca i32
  store i32 %arg.bodyStart, ptr %bodyStart
  %bodyEnd = alloca i32
  store i32 %arg.bodyEnd, ptr %bodyEnd
  %ret.12797 = load ptr, ptr %output.addr.12501
  ret ptr %ret.12797
}

define ptr @generateFunctionParamSymbols(ptr %arg.tokens, ptr %arg.functionName, i32 %arg.declStart) {
entry:
  %tokens = alloca ptr
  store ptr %arg.tokens, ptr %tokens
  %functionName = alloca ptr
  store ptr %arg.functionName, ptr %functionName
  %declStart = alloca i32
  store i32 %arg.declStart, ptr %declStart
  %ret.13028 = load ptr, ptr %output.addr.12874
  ret ptr %ret.13028
}

define i32 @classMemberStart(ptr %arg.tokens, i32 %arg.ordinal) {
entry:
  %tokens = alloca ptr
  store ptr %arg.tokens, ptr %tokens
  %ordinal = alloca i32
  store i32 %arg.ordinal, ptr %ordinal
  ret i32 0
}

define ptr @classMemberKind(ptr %arg.tokens, i32 %arg.ordinal) {
entry:
  %tokens = alloca ptr
  store ptr %arg.tokens, ptr %tokens
  %ordinal = alloca i32
  store i32 %arg.ordinal, ptr %ordinal
  %ret.13184 = getelementptr inbounds [7 x i8], ptr @.str.0, i32 0, i32 0
  ret ptr %ret.13184
}

define ptr @classMemberName(ptr %arg.tokens, i32 %arg.ordinal) {
entry:
  %tokens = alloca ptr
  store ptr %arg.tokens, ptr %tokens
  %ordinal = alloca i32
  store i32 %arg.ordinal, ptr %ordinal
  %ret.13312 = getelementptr inbounds [9 x i8], ptr @.str.0, i32 0, i32 0
  ret ptr %ret.13312
}

define ptr @generateClassMemberSymbols(ptr %arg.tokens, ptr %arg.className, i32 %arg.bodyStart, i32 %arg.bodyEnd) {
entry:
  %tokens = alloca ptr
  store ptr %arg.tokens, ptr %tokens
  %className = alloca ptr
  store ptr %arg.className, ptr %className
  %bodyStart = alloca i32
  store i32 %arg.bodyStart, ptr %bodyStart
  %bodyEnd = alloca i32
  store i32 %arg.bodyEnd, ptr %bodyEnd
  %ret.13530 = load ptr, ptr %output.addr.13338
  ret ptr %ret.13530
}

define ptr @generateClassMemberAST(ptr %arg.tokens, i32 %arg.bodyStart, i32 %arg.bodyEnd) {
entry:
  %tokens = alloca ptr
  store ptr %arg.tokens, ptr %tokens
  %bodyStart = alloca i32
  store i32 %arg.bodyStart, ptr %bodyStart
  %bodyEnd = alloca i32
  store i32 %arg.bodyEnd, ptr %bodyEnd
  %ret.13641 = load ptr, ptr %output.addr.13552
  ret ptr %ret.13641
}

define ptr @templateParameterSummary(ptr %arg.tokens, i32 %arg.ordinal) {
entry:
  %tokens = alloca ptr
  store ptr %arg.tokens, ptr %tokens
  %ordinal = alloca i32
  store i32 %arg.ordinal, ptr %ordinal
  %ret.13852 = load ptr, ptr %output.addr.13721
  ret ptr %ret.13852
}

define ptr @templateTargetKind(ptr %arg.tokens, i32 %arg.ordinal) {
entry:
  %tokens = alloca ptr
  store ptr %arg.tokens, ptr %tokens
  %ordinal = alloca i32
  store i32 %arg.ordinal, ptr %ordinal
  %ret.14028 = getelementptr inbounds [1 x i8], ptr @.str.0, i32 0, i32 0
  ret ptr %ret.14028
}

define ptr @attributeSummary(ptr %arg.tokens, i32 %arg.ordinal) {
entry:
  %tokens = alloca ptr
  store ptr %arg.tokens, ptr %tokens
  %ordinal = alloca i32
  store i32 %arg.ordinal, ptr %ordinal
  %ret.14145 = load ptr, ptr %output.addr.14076
  ret ptr %ret.14145
}

define ptr @externalSymbolKind(ptr %arg.tokens, i32 %arg.ordinal) {
entry:
  %tokens = alloca ptr
  store ptr %arg.tokens, ptr %tokens
  %ordinal = alloca i32
  store i32 %arg.ordinal, ptr %ordinal
  %ret.14217 = load ptr, ptr %kind.addr.14163
  ret ptr %ret.14217
}

define ptr @generateSymbolTable(ptr %arg.tokens) {
entry:
  %tokens = alloca ptr
  store ptr %arg.tokens, ptr %tokens
  %ret.14774 = load ptr, ptr %output.addr.14244
  ret ptr %ret.14774
}

define ptr @generateAST(ptr %arg.tokens) {
entry:
  %tokens = alloca ptr
  store ptr %arg.tokens, ptr %tokens
  %ret.15158 = load ptr, ptr %output.addr.14801
  ret ptr %ret.15158
}

define i32 @parseReturnIntegerInRange(ptr %arg.tokens, i32 %arg.start, i32 %arg.end) {
entry:
  %tokens = alloca ptr
  store ptr %arg.tokens, ptr %tokens
  %start = alloca i32
  store i32 %arg.start, ptr %start
  %end = alloca i32
  store i32 %arg.end, ptr %end
  ret i32 0
}

define ptr @appendCExpression(ptr %arg.tokens, i32 %arg.start, i32 %arg.rawEnd) {
entry:
  %tokens = alloca ptr
  store ptr %arg.tokens, ptr %tokens
  %start = alloca i32
  store i32 %arg.start, ptr %start
  %rawEnd = alloca i32
  store i32 %arg.rawEnd, ptr %rawEnd
  %ret.15547 = load ptr, ptr %output.addr.15392
  ret ptr %ret.15547
}

define ptr @cTypeName(ptr %arg.typeName) {
entry:
  %typeName = alloca ptr
  store ptr %arg.typeName, ptr %typeName
  %ret.15701 = getelementptr inbounds [6 x i8], ptr @.str.0, i32 0, i32 0
  ret ptr %ret.15701
}

define ptr @generateCBody(ptr %arg.tokens, i32 %arg.bodyStart, i32 %arg.bodyEnd, ptr %arg.indent) {
entry:
  %tokens = alloca ptr
  store ptr %arg.tokens, ptr %tokens
  %bodyStart = alloca i32
  store i32 %arg.bodyStart, ptr %bodyStart
  %bodyEnd = alloca i32
  store i32 %arg.bodyEnd, ptr %bodyEnd
  %indent = alloca ptr
  store ptr %arg.indent, ptr %indent
  %ret.16729 = load ptr, ptr %output.addr.15727
  ret ptr %ret.16729
}

define ptr @generateCStatement(ptr %arg.tokens, i32 %arg.start, i32 %arg.end, ptr %arg.indent) {
entry:
  %tokens = alloca ptr
  store ptr %arg.tokens, ptr %tokens
  %start = alloca i32
  store i32 %arg.start, ptr %start
  %end = alloca i32
  store i32 %arg.end, ptr %end
  %indent = alloca ptr
  store ptr %arg.indent, ptr %indent
  %ret.17009.right = getelementptr inbounds [3 x i8], ptr @.str.17021, i32 0, i32 0
  %ret.17009 = call ptr @csec_string_concat(ptr %ret.17009.left, ptr %ret.17009.right)
  ret ptr %ret.17009
}

define i32 @parseMainReturnInt(ptr %arg.tokens) {
entry:
  %tokens = alloca ptr
  store ptr %arg.tokens, ptr %tokens
  ret i32 0
}

define ptr @generateMainExecutionC(ptr %arg.tokens) {
entry:
  %tokens = alloca ptr
  store ptr %arg.tokens, ptr %tokens
  %ret.17418 = getelementptr inbounds [1 x i8], ptr @.str.0, i32 0, i32 0
  ret ptr %ret.17418
}

define ptr @irTypeName(ptr %arg.typeName) {
entry:
  %typeName = alloca ptr
  store ptr %arg.typeName, ptr %typeName
  %ret.17599 = getelementptr inbounds [4 x i8], ptr @.str.0, i32 0, i32 0
  ret ptr %ret.17599
}

define ptr @irOperatorName(ptr %arg.text) {
entry:
  %text = alloca ptr
  store ptr %arg.text, ptr %text
  %ret.17984 = load ptr, ptr %text
  ret ptr %ret.17984
}

define i32 @expressionTopLevelOperator(ptr %arg.tokens, i32 %arg.start, i32 %arg.end) {
entry:
  %tokens = alloca ptr
  store ptr %arg.tokens, ptr %tokens
  %start = alloca i32
  store i32 %arg.start, ptr %start
  %end = alloca i32
  store i32 %arg.end, ptr %end
  ret i32 0
}

define ptr @generateIRExpression(ptr %arg.tokens, i32 %arg.rawStart, i32 %arg.rawEnd) {
entry:
  %tokens = alloca ptr
  store ptr %arg.tokens, ptr %tokens
  %rawStart = alloca i32
  store i32 %arg.rawStart, ptr %rawStart
  %rawEnd = alloca i32
  store i32 %arg.rawEnd, ptr %rawEnd
  ret ptr null
}

define ptr @generateIRAssignment(ptr %arg.tokens, i32 %arg.start, i32 %arg.end) {
entry:
  %tokens = alloca ptr
  store ptr %arg.tokens, ptr %tokens
  %start = alloca i32
  store i32 %arg.start, ptr %start
  %end = alloca i32
  store i32 %arg.end, ptr %end
  %ret.18736.left.left.left.left.left.left.left.right = getelementptr inbounds [3 x i8], ptr @.str.18792, i32 0, i32 0
  %ret.18736.left.left.left.left.left.left.left = call ptr @csec_string_concat(ptr %ret.18736.left.left.left.left.left.left.left.left, ptr %ret.18736.left.left.left.left.left.left.left.right)
  %ret.18736.left.left.left.left.left.left.right = getelementptr inbounds [10 x i8], ptr @.str.18794, i32 0, i32 0
  %ret.18736.left.left.left.left.left.left = call ptr @csec_string_concat(ptr %ret.18736.left.left.left.left.left.left.left, ptr %ret.18736.left.left.left.left.left.left.right)
  %ret.18736.left.left.left.left.left.right = load ptr, ptr %irType.addr.18697
  %ret.18736.left.left.left.left.left = call ptr @csec_string_concat(ptr %ret.18736.left.left.left.left.left.left, ptr %ret.18736.left.left.left.left.left.right)
  %ret.18736.left.left.left.left.right = getelementptr inbounds [6 x i8], ptr @.str.18798, i32 0, i32 0
  %ret.18736.left.left.left.left = call ptr @csec_string_concat(ptr %ret.18736.left.left.left.left.left, ptr %ret.18736.left.left.left.left.right)
  %ret.18736.left.left.left.right = load ptr, ptr %name.addr.18612
  %ret.18736.left.left.left = call ptr @csec_string_concat(ptr %ret.18736.left.left.left.left, ptr %ret.18736.left.left.left.right)
  %ret.18736.left.left.right = getelementptr inbounds [7 x i8], ptr @.str.18802, i32 0, i32 0
  %ret.18736.left.left = call ptr @csec_string_concat(ptr %ret.18736.left.left.left, ptr %ret.18736.left.left.right)
  %ret.18736.left.right = load ptr, ptr %name.addr.18612
  %ret.18736.left = call ptr @csec_string_concat(ptr %ret.18736.left.left, ptr %ret.18736.left.right)
  %ret.18736.right = getelementptr inbounds [2 x i8], ptr @.str.18806, i32 0, i32 0
  %ret.18736 = call ptr @csec_string_concat(ptr %ret.18736.left, ptr %ret.18736.right)
  ret ptr %ret.18736
}

define ptr @generateIRParamList(ptr %arg.tokens, i32 %arg.declStart) {
entry:
  %tokens = alloca ptr
  store ptr %arg.tokens, ptr %tokens
  %declStart = alloca i32
  store i32 %arg.declStart, ptr %declStart
  %ret.19040 = load ptr, ptr %output.addr.18867
  ret ptr %ret.19040
}

define ptr @generateIRFlatBody(ptr %arg.tokens, i32 %arg.bodyStart, i32 %arg.bodyEnd) {
entry:
  %tokens = alloca ptr
  store ptr %arg.tokens, ptr %tokens
  %bodyStart = alloca i32
  store i32 %arg.bodyStart, ptr %bodyStart
  %bodyEnd = alloca i32
  store i32 %arg.bodyEnd, ptr %bodyEnd
  %ret.19433 = load ptr, ptr %output.addr.19062
  ret ptr %ret.19433
}

define ptr @generateIRElseFlatBody(ptr %arg.tokens, i32 %arg.possibleElse, i32 %arg.end, i1 %arg.hasElse) {
entry:
  %tokens = alloca ptr
  store ptr %arg.tokens, ptr %tokens
  %possibleElse = alloca i32
  store i32 %arg.possibleElse, ptr %possibleElse
  %end = alloca i32
  store i32 %arg.end, ptr %end
  %hasElse = alloca i1
  store i1 %arg.hasElse, ptr %hasElse
  %ret.19558 = getelementptr inbounds [28 x i8], ptr @.str.0, i32 0, i32 0
  ret ptr %ret.19558
}

define ptr @generateIRIf(ptr %arg.tokens, i32 %arg.start, i32 %arg.end) {
entry:
  %tokens = alloca ptr
  store ptr %arg.tokens, ptr %tokens
  %start = alloca i32
  store i32 %arg.start, ptr %start
  %end = alloca i32
  store i32 %arg.end, ptr %end
  %ret.19718.left.left.left.left.left.right = getelementptr inbounds [21 x i8], ptr @.str.19792, i32 0, i32 0
  %ret.19718.left.left.left.left.left = call ptr @csec_string_concat(ptr %ret.19718.left.left.left.left.left.left, ptr %ret.19718.left.left.left.left.left.right)
  %ret.19718.left.left.left.left.right = load ptr, ptr %labelSeed.addr.19663
  %ret.19718.left.left.left.left = call ptr @csec_string_concat(ptr %ret.19718.left.left.left.left.left, ptr %ret.19718.left.left.left.left.right)
  %ret.19718.left.left.left.right = getelementptr inbounds [2 x i8], ptr @.str.19796, i32 0, i32 0
  %ret.19718.left.left.left = call ptr @csec_string_concat(ptr %ret.19718.left.left.left.left, ptr %ret.19718.left.left.left.right)
  %ret.19718.left.left.right = getelementptr inbounds [7 x i8], ptr @.str.19798, i32 0, i32 0
  %ret.19718.left.left = call ptr @csec_string_concat(ptr %ret.19718.left.left.left, ptr %ret.19718.left.left.right)
  %ret.19718.left.right = load ptr, ptr %labelSeed.addr.19663
  %ret.19718.left = call ptr @csec_string_concat(ptr %ret.19718.left.left, ptr %ret.19718.left.right)
  %ret.19718.right = getelementptr inbounds [3 x i8], ptr @.str.19802, i32 0, i32 0
  %ret.19718 = call ptr @csec_string_concat(ptr %ret.19718.left, ptr %ret.19718.right)
  ret ptr %ret.19718
}

define ptr @generateIRWhile(ptr %arg.tokens, i32 %arg.start, i32 %arg.end) {
entry:
  %tokens = alloca ptr
  store ptr %arg.tokens, ptr %tokens
  %start = alloca i32
  store i32 %arg.start, ptr %start
  %end = alloca i32
  store i32 %arg.end, ptr %end
  %ret.19915.left.left.left.left.left.right = getelementptr inbounds [25 x i8], ptr @.str.19978, i32 0, i32 0
  %ret.19915.left.left.left.left.left = call ptr @csec_string_concat(ptr %ret.19915.left.left.left.left.left.left, ptr %ret.19915.left.left.left.left.left.right)
  %ret.19915.left.left.left.left.right = load ptr, ptr %labelSeed.addr.19906
  %ret.19915.left.left.left.left = call ptr @csec_string_concat(ptr %ret.19915.left.left.left.left.left, ptr %ret.19915.left.left.left.left.right)
  %ret.19915.left.left.left.right = getelementptr inbounds [2 x i8], ptr @.str.19982, i32 0, i32 0
  %ret.19915.left.left.left = call ptr @csec_string_concat(ptr %ret.19915.left.left.left.left, ptr %ret.19915.left.left.left.right)
  %ret.19915.left.left.right = getelementptr inbounds [10 x i8], ptr @.str.19984, i32 0, i32 0
  %ret.19915.left.left = call ptr @csec_string_concat(ptr %ret.19915.left.left.left, ptr %ret.19915.left.left.right)
  %ret.19915.left.right = load ptr, ptr %labelSeed.addr.19906
  %ret.19915.left = call ptr @csec_string_concat(ptr %ret.19915.left.left, ptr %ret.19915.left.right)
  %ret.19915.right = getelementptr inbounds [3 x i8], ptr @.str.19988, i32 0, i32 0
  %ret.19915 = call ptr @csec_string_concat(ptr %ret.19915.left, ptr %ret.19915.right)
  ret ptr %ret.19915
}

define ptr @generateIRFor(ptr %arg.tokens, i32 %arg.start, i32 %arg.end) {
entry:
  %tokens = alloca ptr
  store ptr %arg.tokens, ptr %tokens
  %start = alloca i32
  store i32 %arg.start, ptr %start
  %end = alloca i32
  store i32 %arg.end, ptr %end
  %ret.20144.left.left.left.left.left.right = getelementptr inbounds [23 x i8], ptr @.str.20215, i32 0, i32 0
  %ret.20144.left.left.left.left.left = call ptr @csec_string_concat(ptr %ret.20144.left.left.left.left.left.left, ptr %ret.20144.left.left.left.left.left.right)
  %ret.20144.left.left.left.left.right = load ptr, ptr %labelSeed.addr.20135
  %ret.20144.left.left.left.left = call ptr @csec_string_concat(ptr %ret.20144.left.left.left.left.left, ptr %ret.20144.left.left.left.left.right)
  %ret.20144.left.left.left.right = getelementptr inbounds [2 x i8], ptr @.str.20219, i32 0, i32 0
  %ret.20144.left.left.left = call ptr @csec_string_concat(ptr %ret.20144.left.left.left.left, ptr %ret.20144.left.left.left.right)
  %ret.20144.left.left.right = getelementptr inbounds [8 x i8], ptr @.str.20221, i32 0, i32 0
  %ret.20144.left.left = call ptr @csec_string_concat(ptr %ret.20144.left.left.left, ptr %ret.20144.left.left.right)
  %ret.20144.left.right = load ptr, ptr %labelSeed.addr.20135
  %ret.20144.left = call ptr @csec_string_concat(ptr %ret.20144.left.left, ptr %ret.20144.left.right)
  %ret.20144.right = getelementptr inbounds [3 x i8], ptr @.str.20225, i32 0, i32 0
  %ret.20144 = call ptr @csec_string_concat(ptr %ret.20144.left, ptr %ret.20144.right)
  ret ptr %ret.20144
}

define ptr @generateIRBody(ptr %arg.tokens, i32 %arg.bodyStart, i32 %arg.bodyEnd) {
entry:
  %tokens = alloca ptr
  store ptr %arg.tokens, ptr %tokens
  %bodyStart = alloca i32
  store i32 %arg.bodyStart, ptr %bodyStart
  %bodyEnd = alloca i32
  store i32 %arg.bodyEnd, ptr %bodyEnd
  %ret.20671 = load ptr, ptr %output.addr.20246
  ret ptr %ret.20671
}

define ptr @generateIRDeclarations(ptr %arg.tokens) {
entry:
  %tokens = alloca ptr
  store ptr %arg.tokens, ptr %tokens
  %ret.20941 = load ptr, ptr %output.addr.20685
  ret ptr %ret.20941
}

define ptr @generateIR(ptr %arg.tokens) {
entry:
  %tokens = alloca ptr
  store ptr %arg.tokens, ptr %tokens
  %ret.20978.left.left.right = getelementptr inbounds [12 x i8], ptr @.str.20995, i32 0, i32 0
  %ret.20978.left.left = call ptr @csec_string_concat(ptr %ret.20978.left.left.left, ptr %ret.20978.left.left.right)
  %ret.20978.left.right = load ptr, ptr %returnValue.addr.20968
  %ret.20978.left = call ptr @csec_string_concat(ptr %ret.20978.left.left, ptr %ret.20978.left.right)
  %ret.20978.right = getelementptr inbounds [2 x i8], ptr @.str.20999, i32 0, i32 0
  %ret.20978 = call ptr @csec_string_concat(ptr %ret.20978.left, ptr %ret.20978.right)
  ret ptr %ret.20978
}

define ptr @generateLLVMMainBody(ptr %arg.tokens) {
entry:
  %tokens = alloca ptr
  store ptr %arg.tokens, ptr %tokens
  %ret.21022.left.left.left = getelementptr inbounds [8 x i8], ptr @.str.21023, i32 0, i32 0
  %ret.21022.left.left.right = getelementptr inbounds [10 x i8], ptr @.str.21025, i32 0, i32 0
  %ret.21022.left.left = call ptr @csec_string_concat(ptr %ret.21022.left.left.left, ptr %ret.21022.left.left.right)
  %ret.21022.left.right = load ptr, ptr %returnValue.addr.21012
  %ret.21022.left = call ptr @csec_string_concat(ptr %ret.21022.left.left, ptr %ret.21022.left.right)
  %ret.21022.right = getelementptr inbounds [2 x i8], ptr @.str.21029, i32 0, i32 0
  %ret.21022 = call ptr @csec_string_concat(ptr %ret.21022.left, ptr %ret.21022.right)
  ret ptr %ret.21022
}

define ptr @llvmCharI8Value(ptr %arg.text) {
entry:
  %text = alloca ptr
  store ptr %arg.text, ptr %text
  %ret.21475 = getelementptr inbounds [2 x i8], ptr @.str.0, i32 0, i32 0
  ret ptr %ret.21475
}

define ptr @llvmI32Value(ptr %arg.tokens, i32 %arg.start, i32 %arg.rawEnd) {
entry:
  %tokens = alloca ptr
  store ptr %arg.tokens, ptr %tokens
  %start = alloca i32
  store i32 %arg.start, ptr %start
  %rawEnd = alloca i32
  store i32 %arg.rawEnd, ptr %rawEnd
  %ret.21618 = getelementptr inbounds [5 x i8], ptr @.str.0, i32 0, i32 0
  ret ptr %ret.21618
}

define ptr @lookupFunctionParamType(ptr %arg.tokens, i32 %arg.limit, ptr %arg.name) {
entry:
  %tokens = alloca ptr
  store ptr %arg.tokens, ptr %tokens
  %limit = alloca i32
  store i32 %arg.limit, ptr %limit
  %name = alloca ptr
  store ptr %arg.name, ptr %name
  %ret.21843 = getelementptr inbounds [8 x i8], ptr @.str.0, i32 0, i32 0
  ret ptr %ret.21843
}

define ptr @lookupVisibleValueType(ptr %arg.tokens, i32 %arg.limit, ptr %arg.name) {
entry:
  %tokens = alloca ptr
  store ptr %arg.tokens, ptr %tokens
  %limit = alloca i32
  store i32 %arg.limit, ptr %limit
  %name = alloca ptr
  store ptr %arg.name, ptr %name
  %ret.22100 = load ptr, ptr %found.addr.21937
  ret ptr %ret.22100
}

define ptr @lookupVisibleStorageName(ptr %arg.tokens, i32 %arg.limit, ptr %arg.name) {
entry:
  %tokens = alloca ptr
  store ptr %arg.tokens, ptr %tokens
  %limit = alloca i32
  store i32 %arg.limit, ptr %limit
  %name = alloca ptr
  store ptr %arg.name, ptr %name
  %ret.22472 = load ptr, ptr %found.addr.22253
  ret ptr %ret.22472
}

define ptr @llvmLoadForValueType(ptr %arg.tokens, i32 %arg.limit, ptr %arg.name, ptr %arg.valueType, ptr %arg.resultName) {
entry:
  %tokens = alloca ptr
  store ptr %arg.tokens, ptr %tokens
  %limit = alloca i32
  store i32 %arg.limit, ptr %limit
  %name = alloca ptr
  store ptr %arg.name, ptr %name
  %valueType = alloca ptr
  store ptr %arg.valueType, ptr %valueType
  %resultName = alloca ptr
  store ptr %arg.resultName, ptr %resultName
  %ret.22629.left.left.left.left = getelementptr inbounds [2 x i8], ptr @.str.22630, i32 0, i32 0
  %ret.22629.left.left.left.right = load ptr, ptr %resultName
  %ret.22629.left.left.left = call ptr @csec_string_concat(ptr %ret.22629.left.left.left.left, ptr %ret.22629.left.left.left.right)
  %ret.22629.left.left.right = getelementptr inbounds [18 x i8], ptr @.str.22634, i32 0, i32 0
  %ret.22629.left.left = call ptr @csec_string_concat(ptr %ret.22629.left.left.left, ptr %ret.22629.left.left.right)
  %ret.22629.left.right = load ptr, ptr %storageName.addr.22502
  %ret.22629.left = call ptr @csec_string_concat(ptr %ret.22629.left.left, ptr %ret.22629.left.right)
  %ret.22629.right = getelementptr inbounds [2 x i8], ptr @.str.22638, i32 0, i32 0
  %ret.22629 = call ptr @csec_string_concat(ptr %ret.22629.left, ptr %ret.22629.right)
  ret ptr %ret.22629
}

define ptr @generateLLVMLoadIfIdentifier(ptr %arg.tokens, i32 %arg.start, i32 %arg.rawEnd) {
entry:
  %tokens = alloca ptr
  store ptr %arg.tokens, ptr %tokens
  %start = alloca i32
  store i32 %arg.start, ptr %start
  %rawEnd = alloca i32
  store i32 %arg.rawEnd, ptr %rawEnd
  %ret.22793 = getelementptr inbounds [1 x i8], ptr @.str.0, i32 0, i32 0
  ret ptr %ret.22793
}

define ptr @llvmI1Value(ptr %arg.tokens, i32 %arg.start, i32 %arg.rawEnd) {
entry:
  %tokens = alloca ptr
  store ptr %arg.tokens, ptr %tokens
  %start = alloca i32
  store i32 %arg.start, ptr %start
  %rawEnd = alloca i32
  store i32 %arg.rawEnd, ptr %rawEnd
  %ret.22902 = getelementptr inbounds [6 x i8], ptr @.str.0, i32 0, i32 0
  ret ptr %ret.22902
}

define ptr @generateLLVMLoadBoolIfIdentifier(ptr %arg.tokens, i32 %arg.start, i32 %arg.rawEnd) {
entry:
  %tokens = alloca ptr
  store ptr %arg.tokens, ptr %tokens
  %start = alloca i32
  store i32 %arg.start, ptr %start
  %rawEnd = alloca i32
  store i32 %arg.rawEnd, ptr %rawEnd
  %ret.22996 = getelementptr inbounds [1 x i8], ptr @.str.0, i32 0, i32 0
  ret ptr %ret.22996
}

define ptr @llvmI32CallArgumentValue(ptr %arg.tokens, i32 %arg.start, i32 %arg.rawEnd, ptr %arg.resultName, i32 %arg.index) {
entry:
  %tokens = alloca ptr
  store ptr %arg.tokens, ptr %tokens
  %start = alloca i32
  store i32 %arg.start, ptr %start
  %rawEnd = alloca i32
  store i32 %arg.rawEnd, ptr %rawEnd
  %resultName = alloca ptr
  store ptr %arg.resultName, ptr %resultName
  %index = alloca i32
  store i32 %arg.index, ptr %index
  %ret.23080.left.left = load ptr, ptr %resultName
  %ret.23080.left.right = getelementptr inbounds [4 x i8], ptr @.str.23083, i32 0, i32 0
  %ret.23080.left = call ptr @csec_string_concat(ptr %ret.23080.left.left, ptr %ret.23080.left.right)
  %ret.23080.right = load ptr, ptr %index
  %ret.23080 = call ptr @csec_string_concat(ptr %ret.23080.left, ptr %ret.23080.right)
  ret ptr %ret.23080
}

define ptr @llvmCallArgumentType(ptr %arg.tokens, i32 %arg.start, i32 %arg.rawEnd) {
entry:
  %tokens = alloca ptr
  store ptr %arg.tokens, ptr %tokens
  %start = alloca i32
  store i32 %arg.start, ptr %start
  %rawEnd = alloca i32
  store i32 %arg.rawEnd, ptr %rawEnd
  %ret.23496 = getelementptr inbounds [4 x i8], ptr @.str.0, i32 0, i32 0
  ret ptr %ret.23496
}

define ptr @llvmCallArgumentValue(ptr %arg.tokens, i32 %arg.start, i32 %arg.rawEnd, ptr %arg.resultName, i32 %arg.index) {
entry:
  %tokens = alloca ptr
  store ptr %arg.tokens, ptr %tokens
  %start = alloca i32
  store i32 %arg.start, ptr %start
  %rawEnd = alloca i32
  store i32 %arg.rawEnd, ptr %rawEnd
  %resultName = alloca ptr
  store ptr %arg.resultName, ptr %resultName
  %index = alloca i32
  store i32 %arg.index, ptr %index
  %ret.23641.left.left = load ptr, ptr %resultName
  %ret.23641.left.right = getelementptr inbounds [4 x i8], ptr @.str.23644, i32 0, i32 0
  %ret.23641.left = call ptr @csec_string_concat(ptr %ret.23641.left.left, ptr %ret.23641.left.right)
  %ret.23641.right = load ptr, ptr %index
  %ret.23641 = call ptr @csec_string_concat(ptr %ret.23641.left, ptr %ret.23641.right)
  ret ptr %ret.23641
}

define ptr @generateLLVMCallArgumentLoadI32(ptr %arg.tokens, i32 %arg.start, i32 %arg.rawEnd, ptr %arg.resultName) {
entry:
  %tokens = alloca ptr
  store ptr %arg.tokens, ptr %tokens
  %start = alloca i32
  store i32 %arg.start, ptr %start
  %rawEnd = alloca i32
  store i32 %arg.rawEnd, ptr %rawEnd
  %resultName = alloca ptr
  store ptr %arg.resultName, ptr %resultName
  %ret.25507.left.left = getelementptr inbounds [2 x i8], ptr @.str.25508, i32 0, i32 0
  %ret.25507.left.right = load ptr, ptr %resultName
  %ret.25507.left = call ptr @csec_string_concat(ptr %ret.25507.left.left, ptr %ret.25507.left.right)
  %ret.25507.right = getelementptr inbounds [17 x i8], ptr @.str.25512, i32 0, i32 0
  %ret.25507 = call ptr @csec_string_concat(ptr %ret.25507.left, ptr %ret.25507.right)
  ret ptr %ret.25507
}

define ptr @generateLLVMCallArgumentLoadsI32(ptr %arg.tokens, i32 %arg.argsStart, i32 %arg.argsEnd, ptr %arg.resultName) {
entry:
  %tokens = alloca ptr
  store ptr %arg.tokens, ptr %tokens
  %argsStart = alloca i32
  store i32 %arg.argsStart, ptr %argsStart
  %argsEnd = alloca i32
  store i32 %arg.argsEnd, ptr %argsEnd
  %resultName = alloca ptr
  store ptr %arg.resultName, ptr %resultName
  %ret.25872 = load ptr, ptr %output.addr.25579
  ret ptr %ret.25872
}

define ptr @generateLLVMCallArgumentListI32(ptr %arg.tokens, i32 %arg.argsStart, i32 %arg.argsEnd, ptr %arg.resultName) {
entry:
  %tokens = alloca ptr
  store ptr %arg.tokens, ptr %tokens
  %argsStart = alloca i32
  store i32 %arg.argsStart, ptr %argsStart
  %argsEnd = alloca i32
  store i32 %arg.argsEnd, ptr %argsEnd
  %resultName = alloca ptr
  store ptr %arg.resultName, ptr %resultName
  %ret.26238 = load ptr, ptr %output.addr.25940
  ret ptr %ret.26238
}

define ptr @llvmRuntimeCallName(ptr %arg.name) {
entry:
  %name = alloca ptr
  store ptr %arg.name, ptr %name
  %ret.26280 = load ptr, ptr %name
  ret ptr %ret.26280
}

define i1 @llvmCallReturnsChar(ptr %arg.tokens, ptr %arg.name) {
entry:
  %tokens = alloca ptr
  store ptr %arg.tokens, ptr %tokens
  %name = alloca ptr
  store ptr %arg.name, ptr %name
  %ret.26359 = icmp eq i1 false, true
  ret i1 %ret.26359
}

define ptr @generateLLVMExpressionI32(ptr %arg.tokens, i32 %arg.start, i32 %arg.rawEnd, ptr %arg.resultName) {
entry:
  %tokens = alloca ptr
  store ptr %arg.tokens, ptr %tokens
  %start = alloca i32
  store i32 %arg.start, ptr %start
  %rawEnd = alloca i32
  store i32 %arg.rawEnd, ptr %rawEnd
  %resultName = alloca ptr
  store ptr %arg.resultName, ptr %resultName
  %ret.27220.left.left = getelementptr inbounds [2 x i8], ptr @.str.27221, i32 0, i32 0
  %ret.27220.left.right = load ptr, ptr %resultName
  %ret.27220.left = call ptr @csec_string_concat(ptr %ret.27220.left.left, ptr %ret.27220.left.right)
  %ret.27220.right = getelementptr inbounds [17 x i8], ptr @.str.27225, i32 0, i32 0
  %ret.27220 = call ptr @csec_string_concat(ptr %ret.27220.left, ptr %ret.27220.right)
  ret ptr %ret.27220
}

define ptr @generateLLVMLocalI32(ptr %arg.tokens, i32 %arg.start, i32 %arg.end) {
entry:
  %tokens = alloca ptr
  store ptr %arg.tokens, ptr %tokens
  %start = alloca i32
  store i32 %arg.start, ptr %start
  %end = alloca i32
  store i32 %arg.end, ptr %end
  %ret.27338.left.left.left.left.left = getelementptr inbounds [3 x i8], ptr @.str.27339, i32 0, i32 0
  %ret.27338.left.left.left.left.right = load ptr, ptr %storageName.addr.27276
  %ret.27338.left.left.left.left = call ptr @csec_string_concat(ptr %ret.27338.left.left.left.left.left, ptr %ret.27338.left.left.left.left.right)
  %ret.27338.left.left.left.right = getelementptr inbounds [15 x i8], ptr @.str.27343, i32 0, i32 0
  %ret.27338.left.left.left = call ptr @csec_string_concat(ptr %ret.27338.left.left.left.left, ptr %ret.27338.left.left.left.right)
  %ret.27338.left.left.right = getelementptr inbounds [20 x i8], ptr @.str.27345, i32 0, i32 0
  %ret.27338.left.left = call ptr @csec_string_concat(ptr %ret.27338.left.left.left, ptr %ret.27338.left.left.right)
  %ret.27338.left.right = load ptr, ptr %storageName.addr.27276
  %ret.27338.left = call ptr @csec_string_concat(ptr %ret.27338.left.left, ptr %ret.27338.left.right)
  %ret.27338.right = getelementptr inbounds [2 x i8], ptr @.str.27349, i32 0, i32 0
  %ret.27338 = call ptr @csec_string_concat(ptr %ret.27338.left, ptr %ret.27338.right)
  ret ptr %ret.27338
}

define ptr @llvmI64Value(ptr %arg.tokens, i32 %arg.start, i32 %arg.rawEnd) {
entry:
  %tokens = alloca ptr
  store ptr %arg.tokens, ptr %tokens
  %start = alloca i32
  store i32 %arg.start, ptr %start
  %rawEnd = alloca i32
  store i32 %arg.rawEnd, ptr %rawEnd
  %ret.27459 = getelementptr inbounds [6 x i8], ptr @.str.0, i32 0, i32 0
  ret ptr %ret.27459
}

define ptr @generateLLVMLoadI64IfIdentifier(ptr %arg.tokens, i32 %arg.start, i32 %arg.rawEnd) {
entry:
  %tokens = alloca ptr
  store ptr %arg.tokens, ptr %tokens
  %start = alloca i32
  store i32 %arg.start, ptr %start
  %rawEnd = alloca i32
  store i32 %arg.rawEnd, ptr %rawEnd
  %ret.27557 = getelementptr inbounds [1 x i8], ptr @.str.0, i32 0, i32 0
  ret ptr %ret.27557
}

define ptr @generateLLVMExpressionI64(ptr %arg.tokens, i32 %arg.start, i32 %arg.rawEnd, ptr %arg.resultName) {
entry:
  %tokens = alloca ptr
  store ptr %arg.tokens, ptr %tokens
  %start = alloca i32
  store i32 %arg.start, ptr %start
  %rawEnd = alloca i32
  store i32 %arg.rawEnd, ptr %rawEnd
  %resultName = alloca ptr
  store ptr %arg.resultName, ptr %resultName
  %ret.27976.left.left = getelementptr inbounds [2 x i8], ptr @.str.27977, i32 0, i32 0
  %ret.27976.left.right = load ptr, ptr %resultName
  %ret.27976.left = call ptr @csec_string_concat(ptr %ret.27976.left.left, ptr %ret.27976.left.right)
  %ret.27976.right = getelementptr inbounds [17 x i8], ptr @.str.27981, i32 0, i32 0
  %ret.27976 = call ptr @csec_string_concat(ptr %ret.27976.left, ptr %ret.27976.right)
  ret ptr %ret.27976
}

define ptr @generateLLVMLocalI64(ptr %arg.tokens, i32 %arg.start, i32 %arg.end) {
entry:
  %tokens = alloca ptr
  store ptr %arg.tokens, ptr %tokens
  %start = alloca i32
  store i32 %arg.start, ptr %start
  %end = alloca i32
  store i32 %arg.end, ptr %end
  %ret.28094.left.left.left.left.left = getelementptr inbounds [3 x i8], ptr @.str.28095, i32 0, i32 0
  %ret.28094.left.left.left.left.right = load ptr, ptr %storageName.addr.28032
  %ret.28094.left.left.left.left = call ptr @csec_string_concat(ptr %ret.28094.left.left.left.left.left, ptr %ret.28094.left.left.left.left.right)
  %ret.28094.left.left.left.right = getelementptr inbounds [15 x i8], ptr @.str.28099, i32 0, i32 0
  %ret.28094.left.left.left = call ptr @csec_string_concat(ptr %ret.28094.left.left.left.left, ptr %ret.28094.left.left.left.right)
  %ret.28094.left.left.right = getelementptr inbounds [20 x i8], ptr @.str.28101, i32 0, i32 0
  %ret.28094.left.left = call ptr @csec_string_concat(ptr %ret.28094.left.left.left, ptr %ret.28094.left.left.right)
  %ret.28094.left.right = load ptr, ptr %storageName.addr.28032
  %ret.28094.left = call ptr @csec_string_concat(ptr %ret.28094.left.left, ptr %ret.28094.left.right)
  %ret.28094.right = getelementptr inbounds [2 x i8], ptr @.str.28105, i32 0, i32 0
  %ret.28094 = call ptr @csec_string_concat(ptr %ret.28094.left, ptr %ret.28094.right)
  ret ptr %ret.28094
}

define ptr @llvmF64Value(ptr %arg.tokens, i32 %arg.start, i32 %arg.rawEnd) {
entry:
  %tokens = alloca ptr
  store ptr %arg.tokens, ptr %tokens
  %start = alloca i32
  store i32 %arg.start, ptr %start
  %rawEnd = alloca i32
  store i32 %arg.rawEnd, ptr %rawEnd
  %ret.28228 = getelementptr inbounds [6 x i8], ptr @.str.0, i32 0, i32 0
  ret ptr %ret.28228
}

define ptr @generateLLVMLoadF64IfIdentifier(ptr %arg.tokens, i32 %arg.start, i32 %arg.rawEnd) {
entry:
  %tokens = alloca ptr
  store ptr %arg.tokens, ptr %tokens
  %start = alloca i32
  store i32 %arg.start, ptr %start
  %rawEnd = alloca i32
  store i32 %arg.rawEnd, ptr %rawEnd
  %ret.28326 = getelementptr inbounds [1 x i8], ptr @.str.0, i32 0, i32 0
  ret ptr %ret.28326
}

define ptr @generateLLVMExpressionF64(ptr %arg.tokens, i32 %arg.start, i32 %arg.rawEnd, ptr %arg.resultName) {
entry:
  %tokens = alloca ptr
  store ptr %arg.tokens, ptr %tokens
  %start = alloca i32
  store i32 %arg.start, ptr %start
  %rawEnd = alloca i32
  store i32 %arg.rawEnd, ptr %rawEnd
  %resultName = alloca ptr
  store ptr %arg.resultName, ptr %resultName
  %ret.28758.left.left = getelementptr inbounds [2 x i8], ptr @.str.28759, i32 0, i32 0
  %ret.28758.left.right = load ptr, ptr %resultName
  %ret.28758.left = call ptr @csec_string_concat(ptr %ret.28758.left.left, ptr %ret.28758.left.right)
  %ret.28758.right = getelementptr inbounds [43 x i8], ptr @.str.28763, i32 0, i32 0
  %ret.28758 = call ptr @csec_string_concat(ptr %ret.28758.left, ptr %ret.28758.right)
  ret ptr %ret.28758
}

define ptr @generateLLVMLocalF64(ptr %arg.tokens, i32 %arg.start, i32 %arg.end) {
entry:
  %tokens = alloca ptr
  store ptr %arg.tokens, ptr %tokens
  %start = alloca i32
  store i32 %arg.start, ptr %start
  %end = alloca i32
  store i32 %arg.end, ptr %end
  %ret.28876.left.left.left.left.left = getelementptr inbounds [3 x i8], ptr @.str.28877, i32 0, i32 0
  %ret.28876.left.left.left.left.right = load ptr, ptr %storageName.addr.28814
  %ret.28876.left.left.left.left = call ptr @csec_string_concat(ptr %ret.28876.left.left.left.left.left, ptr %ret.28876.left.left.left.left.right)
  %ret.28876.left.left.left.right = getelementptr inbounds [18 x i8], ptr @.str.28881, i32 0, i32 0
  %ret.28876.left.left.left = call ptr @csec_string_concat(ptr %ret.28876.left.left.left.left, ptr %ret.28876.left.left.left.right)
  %ret.28876.left.left.right = getelementptr inbounds [34 x i8], ptr @.str.28883, i32 0, i32 0
  %ret.28876.left.left = call ptr @csec_string_concat(ptr %ret.28876.left.left.left, ptr %ret.28876.left.left.right)
  %ret.28876.left.right = load ptr, ptr %storageName.addr.28814
  %ret.28876.left = call ptr @csec_string_concat(ptr %ret.28876.left.left, ptr %ret.28876.left.right)
  %ret.28876.right = getelementptr inbounds [2 x i8], ptr @.str.28887, i32 0, i32 0
  %ret.28876 = call ptr @csec_string_concat(ptr %ret.28876.left, ptr %ret.28876.right)
  ret ptr %ret.28876
}

define ptr @generateLLVMLocalI8(ptr %arg.tokens, i32 %arg.start, i32 %arg.end) {
entry:
  %tokens = alloca ptr
  store ptr %arg.tokens, ptr %tokens
  %start = alloca i32
  store i32 %arg.start, ptr %start
  %end = alloca i32
  store i32 %arg.end, ptr %end
  %ret.29395.left.left.left.left.left = getelementptr inbounds [3 x i8], ptr @.str.29396, i32 0, i32 0
  %ret.29395.left.left.left.left.right = load ptr, ptr %storageName.addr.28938
  %ret.29395.left.left.left.left = call ptr @csec_string_concat(ptr %ret.29395.left.left.left.left.left, ptr %ret.29395.left.left.left.left.right)
  %ret.29395.left.left.left.right = getelementptr inbounds [14 x i8], ptr @.str.29400, i32 0, i32 0
  %ret.29395.left.left.left = call ptr @csec_string_concat(ptr %ret.29395.left.left.left.left, ptr %ret.29395.left.left.left.right)
  %ret.29395.left.left.right = getelementptr inbounds [19 x i8], ptr @.str.29402, i32 0, i32 0
  %ret.29395.left.left = call ptr @csec_string_concat(ptr %ret.29395.left.left.left, ptr %ret.29395.left.left.right)
  %ret.29395.left.right = load ptr, ptr %storageName.addr.28938
  %ret.29395.left = call ptr @csec_string_concat(ptr %ret.29395.left.left, ptr %ret.29395.left.right)
  %ret.29395.right = getelementptr inbounds [2 x i8], ptr @.str.29406, i32 0, i32 0
  %ret.29395 = call ptr @csec_string_concat(ptr %ret.29395.left, ptr %ret.29395.right)
  ret ptr %ret.29395
}

define ptr @generateLLVMAssignmentF64(ptr %arg.tokens, i32 %arg.start, i32 %arg.end) {
entry:
  %tokens = alloca ptr
  store ptr %arg.tokens, ptr %tokens
  %start = alloca i32
  store i32 %arg.start, ptr %start
  %end = alloca i32
  store i32 %arg.end, ptr %end
  %ret.29558 = getelementptr inbounds [1 x i8], ptr @.str.0, i32 0, i32 0
  ret ptr %ret.29558
}

define ptr @generateLLVMAssignmentPtr(ptr %arg.tokens, i32 %arg.start, i32 %arg.end) {
entry:
  %tokens = alloca ptr
  store ptr %arg.tokens, ptr %tokens
  %start = alloca i32
  store i32 %arg.start, ptr %start
  %end = alloca i32
  store i32 %arg.end, ptr %end
  %ret.29947 = getelementptr inbounds [1 x i8], ptr @.str.0, i32 0, i32 0
  ret ptr %ret.29947
}

define ptr @generateLLVMAssignmentI8(ptr %arg.tokens, i32 %arg.start, i32 %arg.end) {
entry:
  %tokens = alloca ptr
  store ptr %arg.tokens, ptr %tokens
  %start = alloca i32
  store i32 %arg.start, ptr %start
  %end = alloca i32
  store i32 %arg.end, ptr %end
  %ret.30468 = getelementptr inbounds [1 x i8], ptr @.str.0, i32 0, i32 0
  ret ptr %ret.30468
}

define ptr @generateLLVMAssignmentI32(ptr %arg.tokens, i32 %arg.start, i32 %arg.end) {
entry:
  %tokens = alloca ptr
  store ptr %arg.tokens, ptr %tokens
  %start = alloca i32
  store i32 %arg.start, ptr %start
  %end = alloca i32
  store i32 %arg.end, ptr %end
  %ret.30650.left.left.left.left.left.left.left.left.left.left.left.left.left.left.left.right = getelementptr inbounds [6 x i8], ptr @.str.30699, i32 0, i32 0
  %ret.30650.left.left.left.left.left.left.left.left.left.left.left.left.left.left.left = call ptr @csec_string_concat(ptr %ret.30650.left.left.left.left.left.left.left.left.left.left.left.left.left.left.left.left, ptr %ret.30650.left.left.left.left.left.left.left.left.left.left.left.left.left.left.left.right)
  %ret.30650.left.left.left.left.left.left.left.left.left.left.left.left.left.left.right = load ptr, ptr %name.addr.30528
  %ret.30650.left.left.left.left.left.left.left.left.left.left.left.left.left.left = call ptr @csec_string_concat(ptr %ret.30650.left.left.left.left.left.left.left.left.left.left.left.left.left.left.left, ptr %ret.30650.left.left.left.left.left.left.left.left.left.left.left.left.left.left.right)
  %ret.30650.left.left.left.left.left.left.left.left.left.left.left.left.left.right = getelementptr inbounds [5 x i8], ptr @.str.30703, i32 0, i32 0
  %ret.30650.left.left.left.left.left.left.left.left.left.left.left.left.left = call ptr @csec_string_concat(ptr %ret.30650.left.left.left.left.left.left.left.left.left.left.left.left.left.left, ptr %ret.30650.left.left.left.left.left.left.left.left.left.left.left.left.left.right)
  %ret.30650.left.left.left.left.left.left.left.left.left.left.left.left.right = load ptr, ptr %start
  %ret.30650.left.left.left.left.left.left.left.left.left.left.left.left = call ptr @csec_string_concat(ptr %ret.30650.left.left.left.left.left.left.left.left.left.left.left.left.left, ptr %ret.30650.left.left.left.left.left.left.left.left.left.left.left.left.right)
  %ret.30650.left.left.left.left.left.left.left.left.left.left.left.right = getelementptr inbounds [3 x i8], ptr @.str.30707, i32 0, i32 0
  %ret.30650.left.left.left.left.left.left.left.left.left.left.left = call ptr @csec_string_concat(ptr %ret.30650.left.left.left.left.left.left.left.left.left.left.left.left, ptr %ret.30650.left.left.left.left.left.left.left.left.left.left.left.right)
  %ret.30650.left.left.left.left.left.left.left.left.left.left.right = load ptr, ptr %name.addr.30528
  %ret.30650.left.left.left.left.left.left.left.left.left.left = call ptr @csec_string_concat(ptr %ret.30650.left.left.left.left.left.left.left.left.left.left.left, ptr %ret.30650.left.left.left.left.left.left.left.left.left.left.right)
  %ret.30650.left.left.left.left.left.left.left.left.left.right = getelementptr inbounds [5 x i8], ptr @.str.30711, i32 0, i32 0
  %ret.30650.left.left.left.left.left.left.left.left.left = call ptr @csec_string_concat(ptr %ret.30650.left.left.left.left.left.left.left.left.left.left, ptr %ret.30650.left.left.left.left.left.left.left.left.left.right)
  %ret.30650.left.left.left.left.left.left.left.left.right = load ptr, ptr %start
  %ret.30650.left.left.left.left.left.left.left.left = call ptr @csec_string_concat(ptr %ret.30650.left.left.left.left.left.left.left.left.left, ptr %ret.30650.left.left.left.left.left.left.left.left.right)
  %ret.30650.left.left.left.left.left.left.left.right = getelementptr inbounds [2 x i8], ptr @.str.30715, i32 0, i32 0
  %ret.30650.left.left.left.left.left.left.left = call ptr @csec_string_concat(ptr %ret.30650.left.left.left.left.left.left.left.left, ptr %ret.30650.left.left.left.left.left.left.left.right)
  %ret.30650.left.left.left.left.left.left.right = getelementptr inbounds [13 x i8], ptr @.str.30717, i32 0, i32 0
  %ret.30650.left.left.left.left.left.left = call ptr @csec_string_concat(ptr %ret.30650.left.left.left.left.left.left.left, ptr %ret.30650.left.left.left.left.left.left.right)
  %ret.30650.left.left.left.left.left.right = load ptr, ptr %name.addr.30528
  %ret.30650.left.left.left.left.left = call ptr @csec_string_concat(ptr %ret.30650.left.left.left.left.left.left, ptr %ret.30650.left.left.left.left.left.right)
  %ret.30650.left.left.left.left.right = getelementptr inbounds [6 x i8], ptr @.str.30721, i32 0, i32 0
  %ret.30650.left.left.left.left = call ptr @csec_string_concat(ptr %ret.30650.left.left.left.left.left, ptr %ret.30650.left.left.left.left.right)
  %ret.30650.left.left.left.right = load ptr, ptr %start
  %ret.30650.left.left.left = call ptr @csec_string_concat(ptr %ret.30650.left.left.left.left, ptr %ret.30650.left.left.left.right)
  %ret.30650.left.left.right = getelementptr inbounds [7 x i8], ptr @.str.30725, i32 0, i32 0
  %ret.30650.left.left = call ptr @csec_string_concat(ptr %ret.30650.left.left.left, ptr %ret.30650.left.left.right)
  %ret.30650.left.right = load ptr, ptr %storageName.addr.30540
  %ret.30650.left = call ptr @csec_string_concat(ptr %ret.30650.left.left, ptr %ret.30650.left.right)
  %ret.30650.right = getelementptr inbounds [2 x i8], ptr @.str.30729, i32 0, i32 0
  %ret.30650 = call ptr @csec_string_concat(ptr %ret.30650.left, ptr %ret.30650.right)
  ret ptr %ret.30650
}

define ptr @generateLLVMAssignmentI64(ptr %arg.tokens, i32 %arg.start, i32 %arg.end) {
entry:
  %tokens = alloca ptr
  store ptr %arg.tokens, ptr %tokens
  %start = alloca i32
  store i32 %arg.start, ptr %start
  %end = alloca i32
  store i32 %arg.end, ptr %end
  %ret.30910.left.left.left.left.left.left.left.left.left.left.left.left.left.left.left.right = getelementptr inbounds [6 x i8], ptr @.str.30959, i32 0, i32 0
  %ret.30910.left.left.left.left.left.left.left.left.left.left.left.left.left.left.left = call ptr @csec_string_concat(ptr %ret.30910.left.left.left.left.left.left.left.left.left.left.left.left.left.left.left.left, ptr %ret.30910.left.left.left.left.left.left.left.left.left.left.left.left.left.left.left.right)
  %ret.30910.left.left.left.left.left.left.left.left.left.left.left.left.left.left.right = load ptr, ptr %name.addr.30788
  %ret.30910.left.left.left.left.left.left.left.left.left.left.left.left.left.left = call ptr @csec_string_concat(ptr %ret.30910.left.left.left.left.left.left.left.left.left.left.left.left.left.left.left, ptr %ret.30910.left.left.left.left.left.left.left.left.left.left.left.left.left.left.right)
  %ret.30910.left.left.left.left.left.left.left.left.left.left.left.left.left.right = getelementptr inbounds [6 x i8], ptr @.str.30963, i32 0, i32 0
  %ret.30910.left.left.left.left.left.left.left.left.left.left.left.left.left = call ptr @csec_string_concat(ptr %ret.30910.left.left.left.left.left.left.left.left.left.left.left.left.left.left, ptr %ret.30910.left.left.left.left.left.left.left.left.left.left.left.left.left.right)
  %ret.30910.left.left.left.left.left.left.left.left.left.left.left.left.right = load ptr, ptr %start
  %ret.30910.left.left.left.left.left.left.left.left.left.left.left.left = call ptr @csec_string_concat(ptr %ret.30910.left.left.left.left.left.left.left.left.left.left.left.left.left, ptr %ret.30910.left.left.left.left.left.left.left.left.left.left.left.left.right)
  %ret.30910.left.left.left.left.left.left.left.left.left.left.left.right = getelementptr inbounds [3 x i8], ptr @.str.30967, i32 0, i32 0
  %ret.30910.left.left.left.left.left.left.left.left.left.left.left = call ptr @csec_string_concat(ptr %ret.30910.left.left.left.left.left.left.left.left.left.left.left.left, ptr %ret.30910.left.left.left.left.left.left.left.left.left.left.left.right)
  %ret.30910.left.left.left.left.left.left.left.left.left.left.right = load ptr, ptr %name.addr.30788
  %ret.30910.left.left.left.left.left.left.left.left.left.left = call ptr @csec_string_concat(ptr %ret.30910.left.left.left.left.left.left.left.left.left.left.left, ptr %ret.30910.left.left.left.left.left.left.left.left.left.left.right)
  %ret.30910.left.left.left.left.left.left.left.left.left.right = getelementptr inbounds [6 x i8], ptr @.str.30971, i32 0, i32 0
  %ret.30910.left.left.left.left.left.left.left.left.left = call ptr @csec_string_concat(ptr %ret.30910.left.left.left.left.left.left.left.left.left.left, ptr %ret.30910.left.left.left.left.left.left.left.left.left.right)
  %ret.30910.left.left.left.left.left.left.left.left.right = load ptr, ptr %start
  %ret.30910.left.left.left.left.left.left.left.left = call ptr @csec_string_concat(ptr %ret.30910.left.left.left.left.left.left.left.left.left, ptr %ret.30910.left.left.left.left.left.left.left.left.right)
  %ret.30910.left.left.left.left.left.left.left.right = getelementptr inbounds [2 x i8], ptr @.str.30975, i32 0, i32 0
  %ret.30910.left.left.left.left.left.left.left = call ptr @csec_string_concat(ptr %ret.30910.left.left.left.left.left.left.left.left, ptr %ret.30910.left.left.left.left.left.left.left.right)
  %ret.30910.left.left.left.left.left.left.right = getelementptr inbounds [13 x i8], ptr @.str.30977, i32 0, i32 0
  %ret.30910.left.left.left.left.left.left = call ptr @csec_string_concat(ptr %ret.30910.left.left.left.left.left.left.left, ptr %ret.30910.left.left.left.left.left.left.right)
  %ret.30910.left.left.left.left.left.right = load ptr, ptr %name.addr.30788
  %ret.30910.left.left.left.left.left = call ptr @csec_string_concat(ptr %ret.30910.left.left.left.left.left.left, ptr %ret.30910.left.left.left.left.left.right)
  %ret.30910.left.left.left.left.right = getelementptr inbounds [7 x i8], ptr @.str.30981, i32 0, i32 0
  %ret.30910.left.left.left.left = call ptr @csec_string_concat(ptr %ret.30910.left.left.left.left.left, ptr %ret.30910.left.left.left.left.right)
  %ret.30910.left.left.left.right = load ptr, ptr %start
  %ret.30910.left.left.left = call ptr @csec_string_concat(ptr %ret.30910.left.left.left.left, ptr %ret.30910.left.left.left.right)
  %ret.30910.left.left.right = getelementptr inbounds [7 x i8], ptr @.str.30985, i32 0, i32 0
  %ret.30910.left.left = call ptr @csec_string_concat(ptr %ret.30910.left.left.left, ptr %ret.30910.left.left.right)
  %ret.30910.left.right = load ptr, ptr %storageName.addr.30800
  %ret.30910.left = call ptr @csec_string_concat(ptr %ret.30910.left.left, ptr %ret.30910.left.right)
  %ret.30910.right = getelementptr inbounds [2 x i8], ptr @.str.30989, i32 0, i32 0
  %ret.30910 = call ptr @csec_string_concat(ptr %ret.30910.left, ptr %ret.30910.right)
  ret ptr %ret.30910
}

define ptr @generateLLVMConditionI1(ptr %arg.tokens, i32 %arg.start, i32 %arg.rawEnd, ptr %arg.resultName) {
entry:
  %tokens = alloca ptr
  store ptr %arg.tokens, ptr %tokens
  %start = alloca i32
  store i32 %arg.start, ptr %start
  %rawEnd = alloca i32
  store i32 %arg.rawEnd, ptr %rawEnd
  %resultName = alloca ptr
  store ptr %arg.resultName, ptr %resultName
  %ret.31813.left.left = getelementptr inbounds [2 x i8], ptr @.str.31814, i32 0, i32 0
  %ret.31813.left.right = load ptr, ptr %resultName
  %ret.31813.left = call ptr @csec_string_concat(ptr %ret.31813.left.left, ptr %ret.31813.left.right)
  %ret.31813.right = getelementptr inbounds [21 x i8], ptr @.str.31818, i32 0, i32 0
  %ret.31813 = call ptr @csec_string_concat(ptr %ret.31813.left, ptr %ret.31813.right)
  ret ptr %ret.31813
}

define ptr @generateLLVMExpressionI1(ptr %arg.tokens, i32 %arg.start, i32 %arg.rawEnd, ptr %arg.resultName) {
entry:
  %tokens = alloca ptr
  store ptr %arg.tokens, ptr %tokens
  %start = alloca i32
  store i32 %arg.start, ptr %start
  %rawEnd = alloca i32
  store i32 %arg.rawEnd, ptr %rawEnd
  %resultName = alloca ptr
  store ptr %arg.resultName, ptr %resultName
  ret ptr null
}

define ptr @generateLLVMLocalI1(ptr %arg.tokens, i32 %arg.start, i32 %arg.end) {
entry:
  %tokens = alloca ptr
  store ptr %arg.tokens, ptr %tokens
  %start = alloca i32
  store i32 %arg.start, ptr %start
  %end = alloca i32
  store i32 %arg.end, ptr %end
  %ret.32955.left.left.left.left.left = getelementptr inbounds [3 x i8], ptr @.str.32956, i32 0, i32 0
  %ret.32955.left.left.left.left.right = load ptr, ptr %storageName.addr.32893
  %ret.32955.left.left.left.left = call ptr @csec_string_concat(ptr %ret.32955.left.left.left.left.left, ptr %ret.32955.left.left.left.left.right)
  %ret.32955.left.left.left.right = getelementptr inbounds [14 x i8], ptr @.str.32960, i32 0, i32 0
  %ret.32955.left.left.left = call ptr @csec_string_concat(ptr %ret.32955.left.left.left.left, ptr %ret.32955.left.left.left.right)
  %ret.32955.left.left.right = getelementptr inbounds [23 x i8], ptr @.str.32962, i32 0, i32 0
  %ret.32955.left.left = call ptr @csec_string_concat(ptr %ret.32955.left.left.left, ptr %ret.32955.left.left.right)
  %ret.32955.left.right = load ptr, ptr %storageName.addr.32893
  %ret.32955.left = call ptr @csec_string_concat(ptr %ret.32955.left.left, ptr %ret.32955.left.right)
  %ret.32955.right = getelementptr inbounds [2 x i8], ptr @.str.32966, i32 0, i32 0
  %ret.32955 = call ptr @csec_string_concat(ptr %ret.32955.left, ptr %ret.32955.right)
  ret ptr %ret.32955
}

define ptr @generateLLVMAssignmentI1(ptr %arg.tokens, i32 %arg.start, i32 %arg.end) {
entry:
  %tokens = alloca ptr
  store ptr %arg.tokens, ptr %tokens
  %start = alloca i32
  store i32 %arg.start, ptr %start
  %end = alloca i32
  store i32 %arg.end, ptr %end
  %ret.33118 = getelementptr inbounds [1 x i8], ptr @.str.0, i32 0, i32 0
  ret ptr %ret.33118
}

define i1 @llvmBlockEndsWithTopLevelReturn(ptr %arg.tokens, i32 %arg.bodyStart, i32 %arg.bodyEnd) {
entry:
  %tokens = alloca ptr
  store ptr %arg.tokens, ptr %tokens
  %bodyStart = alloca i32
  store i32 %arg.bodyStart, ptr %bodyStart
  %bodyEnd = alloca i32
  store i32 %arg.bodyEnd, ptr %bodyEnd
  %ret.33228 = load i1, ptr %result.addr.33152
  ret i1 %ret.33228
}

define ptr @generateLLVMExpressionPtr(ptr %arg.tokens, i32 %arg.start, i32 %arg.rawEnd, ptr %arg.resultName) {
entry:
  %tokens = alloca ptr
  store ptr %arg.tokens, ptr %tokens
  %start = alloca i32
  store i32 %arg.start, ptr %start
  %rawEnd = alloca i32
  store i32 %arg.rawEnd, ptr %rawEnd
  %resultName = alloca ptr
  store ptr %arg.resultName, ptr %resultName
  %ret.34680.left.left = getelementptr inbounds [2 x i8], ptr @.str.34681, i32 0, i32 0
  %ret.34680.left.right = load ptr, ptr %resultName
  %ret.34680.left = call ptr @csec_string_concat(ptr %ret.34680.left.left, ptr %ret.34680.left.right)
  %ret.34680.right = getelementptr inbounds [26 x i8], ptr @.str.34685, i32 0, i32 0
  %ret.34680 = call ptr @csec_string_concat(ptr %ret.34680.left, ptr %ret.34680.right)
  ret ptr %ret.34680
}

define ptr @generateLLVMLocalPtr(ptr %arg.tokens, i32 %arg.start, i32 %arg.end) {
entry:
  %tokens = alloca ptr
  store ptr %arg.tokens, ptr %tokens
  %start = alloca i32
  store i32 %arg.start, ptr %start
  %end = alloca i32
  store i32 %arg.end, ptr %end
  %ret.34824.left.left.left.left.left = getelementptr inbounds [3 x i8], ptr @.str.34825, i32 0, i32 0
  %ret.34824.left.left.left.left.right = load ptr, ptr %storageName.addr.34736
  %ret.34824.left.left.left.left = call ptr @csec_string_concat(ptr %ret.34824.left.left.left.left.left, ptr %ret.34824.left.left.left.left.right)
  %ret.34824.left.left.left.right = getelementptr inbounds [15 x i8], ptr @.str.34829, i32 0, i32 0
  %ret.34824.left.left.left = call ptr @csec_string_concat(ptr %ret.34824.left.left.left.left, ptr %ret.34824.left.left.left.right)
  %ret.34824.left.left.right = getelementptr inbounds [23 x i8], ptr @.str.34831, i32 0, i32 0
  %ret.34824.left.left = call ptr @csec_string_concat(ptr %ret.34824.left.left.left, ptr %ret.34824.left.left.right)
  %ret.34824.left.right = load ptr, ptr %storageName.addr.34736
  %ret.34824.left = call ptr @csec_string_concat(ptr %ret.34824.left.left, ptr %ret.34824.left.right)
  %ret.34824.right = getelementptr inbounds [2 x i8], ptr @.str.34835, i32 0, i32 0
  %ret.34824 = call ptr @csec_string_concat(ptr %ret.34824.left, ptr %ret.34824.right)
  ret ptr %ret.34824
}

define i1 @llvmExpressionLooksPtr(ptr %arg.tokens, i32 %arg.start, i32 %arg.rawEnd) {
entry:
  %tokens = alloca ptr
  store ptr %arg.tokens, ptr %tokens
  %start = alloca i32
  store i32 %arg.start, ptr %start
  %rawEnd = alloca i32
  store i32 %arg.rawEnd, ptr %rawEnd
  %ret.35179 = icmp eq i1 false, true
  ret i1 %ret.35179
}

define ptr @generateLLVMFlatBodyI32(ptr %arg.tokens, i32 %arg.bodyStart, i32 %arg.bodyEnd) {
entry:
  %tokens = alloca ptr
  store ptr %arg.tokens, ptr %tokens
  %bodyStart = alloca i32
  store i32 %arg.bodyStart, ptr %bodyStart
  %bodyEnd = alloca i32
  store i32 %arg.bodyEnd, ptr %bodyEnd
  %ret.37400 = load ptr, ptr %output.addr.35201
  ret ptr %ret.37400
}

define ptr @generateLLVMIfI32(ptr %arg.tokens, i32 %arg.start, i32 %arg.end) {
entry:
  %tokens = alloca ptr
  store ptr %arg.tokens, ptr %tokens
  %start = alloca i32
  store i32 %arg.start, ptr %start
  %end = alloca i32
  store i32 %arg.end, ptr %end
  %ret.37731.left.left.left.left.left.left.left.left.left.left.left.left.left.left.left.left.left.left.left.right = getelementptr inbounds [14 x i8], ptr @.str.37747, i32 0, i32 0
  %ret.37731.left.left.left.left.left.left.left.left.left.left.left.left.left.left.left.left.left.left.left = call ptr @csec_string_concat(ptr %ret.37731.left.left.left.left.left.left.left.left.left.left.left.left.left.left.left.left.left.left.left.left, ptr %ret.37731.left.left.left.left.left.left.left.left.left.left.left.left.left.left.left.left.left.left.left.right)
  %ret.37731.left.left.left.left.left.left.left.left.left.left.left.left.left.left.left.left.left.left.right = load ptr, ptr %labelSeed.addr.37505
  %ret.37731.left.left.left.left.left.left.left.left.left.left.left.left.left.left.left.left.left.left = call ptr @csec_string_concat(ptr %ret.37731.left.left.left.left.left.left.left.left.left.left.left.left.left.left.left.left.left.left.left, ptr %ret.37731.left.left.left.left.left.left.left.left.left.left.left.left.left.left.left.left.left.left.right)
  %ret.37731.left.left.left.left.left.left.left.left.left.left.left.left.left.left.left.left.left.right = getelementptr inbounds [17 x i8], ptr @.str.37751, i32 0, i32 0
  %ret.37731.left.left.left.left.left.left.left.left.left.left.left.left.left.left.left.left.left = call ptr @csec_string_concat(ptr %ret.37731.left.left.left.left.left.left.left.left.left.left.left.left.left.left.left.left.left.left, ptr %ret.37731.left.left.left.left.left.left.left.left.left.left.left.left.left.left.left.left.left.right)
  %ret.37731.left.left.left.left.left.left.left.left.left.left.left.left.left.left.left.left.right = load ptr, ptr %labelSeed.addr.37505
  %ret.37731.left.left.left.left.left.left.left.left.left.left.left.left.left.left.left.left = call ptr @csec_string_concat(ptr %ret.37731.left.left.left.left.left.left.left.left.left.left.left.left.left.left.left.left.left, ptr %ret.37731.left.left.left.left.left.left.left.left.left.left.left.left.left.left.left.left.right)
  %ret.37731.left.left.left.left.left.left.left.left.left.left.left.left.left.left.left.right = getelementptr inbounds [17 x i8], ptr @.str.37755, i32 0, i32 0
  %ret.37731.left.left.left.left.left.left.left.left.left.left.left.left.left.left.left = call ptr @csec_string_concat(ptr %ret.37731.left.left.left.left.left.left.left.left.left.left.left.left.left.left.left.left, ptr %ret.37731.left.left.left.left.left.left.left.left.left.left.left.left.left.left.left.right)
  %ret.37731.left.left.left.left.left.left.left.left.left.left.left.left.left.left.right = load ptr, ptr %labelSeed.addr.37505
  %ret.37731.left.left.left.left.left.left.left.left.left.left.left.left.left.left = call ptr @csec_string_concat(ptr %ret.37731.left.left.left.left.left.left.left.left.left.left.left.left.left.left.left, ptr %ret.37731.left.left.left.left.left.left.left.left.left.left.left.left.left.left.right)
  %ret.37731.left.left.left.left.left.left.left.left.left.left.left.left.left.right = getelementptr inbounds [2 x i8], ptr @.str.37759, i32 0, i32 0
  %ret.37731.left.left.left.left.left.left.left.left.left.left.left.left.left = call ptr @csec_string_concat(ptr %ret.37731.left.left.left.left.left.left.left.left.left.left.left.left.left.left, ptr %ret.37731.left.left.left.left.left.left.left.left.left.left.left.left.left.right)
  %ret.37731.left.left.left.left.left.left.left.left.left.left.left.left.right = getelementptr inbounds [8 x i8], ptr @.str.37761, i32 0, i32 0
  %ret.37731.left.left.left.left.left.left.left.left.left.left.left.left = call ptr @csec_string_concat(ptr %ret.37731.left.left.left.left.left.left.left.left.left.left.left.left.left, ptr %ret.37731.left.left.left.left.left.left.left.left.left.left.left.left.right)
  %ret.37731.left.left.left.left.left.left.left.left.left.left.left.right = load ptr, ptr %labelSeed.addr.37505
  %ret.37731.left.left.left.left.left.left.left.left.left.left.left = call ptr @csec_string_concat(ptr %ret.37731.left.left.left.left.left.left.left.left.left.left.left.left, ptr %ret.37731.left.left.left.left.left.left.left.left.left.left.left.right)
  %ret.37731.left.left.left.left.left.left.left.left.left.left.right = getelementptr inbounds [3 x i8], ptr @.str.37765, i32 0, i32 0
  %ret.37731.left.left.left.left.left.left.left.left.left.left = call ptr @csec_string_concat(ptr %ret.37731.left.left.left.left.left.left.left.left.left.left.left, ptr %ret.37731.left.left.left.left.left.left.left.left.left.left.right)
  %ret.37731.left.left.left.left.left.left.left.left.left.right = load ptr, ptr %thenBody.addr.37528
  %ret.37731.left.left.left.left.left.left.left.left.left = call ptr @csec_string_concat(ptr %ret.37731.left.left.left.left.left.left.left.left.left.left, ptr %ret.37731.left.left.left.left.left.left.left.left.left.right)
  %ret.37731.left.left.left.left.left.left.left.left.right = load ptr, ptr %thenBranch.addr.37544
  %ret.37731.left.left.left.left.left.left.left.left = call ptr @csec_string_concat(ptr %ret.37731.left.left.left.left.left.left.left.left.left, ptr %ret.37731.left.left.left.left.left.left.left.left.right)
  %ret.37731.left.left.left.left.left.left.left.right = getelementptr inbounds [8 x i8], ptr @.str.37771, i32 0, i32 0
  %ret.37731.left.left.left.left.left.left.left = call ptr @csec_string_concat(ptr %ret.37731.left.left.left.left.left.left.left.left, ptr %ret.37731.left.left.left.left.left.left.left.right)
  %ret.37731.left.left.left.left.left.left.right = load ptr, ptr %labelSeed.addr.37505
  %ret.37731.left.left.left.left.left.left = call ptr @csec_string_concat(ptr %ret.37731.left.left.left.left.left.left.left, ptr %ret.37731.left.left.left.left.left.left.right)
  %ret.37731.left.left.left.left.left.right = getelementptr inbounds [3 x i8], ptr @.str.37775, i32 0, i32 0
  %ret.37731.left.left.left.left.left = call ptr @csec_string_concat(ptr %ret.37731.left.left.left.left.left.left, ptr %ret.37731.left.left.left.left.left.right)
  %ret.37731.left.left.left.left.right = load ptr, ptr %elseBody.addr.37574
  %ret.37731.left.left.left.left = call ptr @csec_string_concat(ptr %ret.37731.left.left.left.left.left, ptr %ret.37731.left.left.left.left.right)
  %ret.37731.left.left.left.right = load ptr, ptr %elseBranch.addr.37581
  %ret.37731.left.left.left = call ptr @csec_string_concat(ptr %ret.37731.left.left.left.left, ptr %ret.37731.left.left.left.right)
  %ret.37731.left.left.right = getelementptr inbounds [7 x i8], ptr @.str.37781, i32 0, i32 0
  %ret.37731.left.left = call ptr @csec_string_concat(ptr %ret.37731.left.left.left, ptr %ret.37731.left.left.right)
  %ret.37731.left.right = load ptr, ptr %labelSeed.addr.37505
  %ret.37731.left = call ptr @csec_string_concat(ptr %ret.37731.left.left, ptr %ret.37731.left.right)
  %ret.37731.right = getelementptr inbounds [3 x i8], ptr @.str.37785, i32 0, i32 0
  %ret.37731 = call ptr @csec_string_concat(ptr %ret.37731.left, ptr %ret.37731.right)
  ret ptr %ret.37731
}

define ptr @generateLLVMWhileI32(ptr %arg.tokens, i32 %arg.start, i32 %arg.end) {
entry:
  %tokens = alloca ptr
  store ptr %arg.tokens, ptr %tokens
  %start = alloca i32
  store i32 %arg.start, ptr %start
  %end = alloca i32
  store i32 %arg.end, ptr %end
  %ret.37944.left.left.left.left.left.left.left.left.left.left.left.left.left.left.right = getelementptr inbounds [19 x i8], ptr @.str.37972, i32 0, i32 0
  %ret.37944.left.left.left.left.left.left.left.left.left.left.left.left.left.left = call ptr @csec_string_concat(ptr %ret.37944.left.left.left.left.left.left.left.left.left.left.left.left.left.left.left, ptr %ret.37944.left.left.left.left.left.left.left.left.left.left.left.left.left.left.right)
  %ret.37944.left.left.left.left.left.left.left.left.left.left.left.left.left.right = load ptr, ptr %labelSeed.addr.37889
  %ret.37944.left.left.left.left.left.left.left.left.left.left.left.left.left = call ptr @csec_string_concat(ptr %ret.37944.left.left.left.left.left.left.left.left.left.left.left.left.left.left, ptr %ret.37944.left.left.left.left.left.left.left.left.left.left.left.left.left.right)
  %ret.37944.left.left.left.left.left.left.left.left.left.left.left.left.right = getelementptr inbounds [20 x i8], ptr @.str.37976, i32 0, i32 0
  %ret.37944.left.left.left.left.left.left.left.left.left.left.left.left = call ptr @csec_string_concat(ptr %ret.37944.left.left.left.left.left.left.left.left.left.left.left.left.left, ptr %ret.37944.left.left.left.left.left.left.left.left.left.left.left.left.right)
  %ret.37944.left.left.left.left.left.left.left.left.left.left.left.right = load ptr, ptr %labelSeed.addr.37889
  %ret.37944.left.left.left.left.left.left.left.left.left.left.left = call ptr @csec_string_concat(ptr %ret.37944.left.left.left.left.left.left.left.left.left.left.left.left, ptr %ret.37944.left.left.left.left.left.left.left.left.left.left.left.right)
  %ret.37944.left.left.left.left.left.left.left.left.left.left.right = getelementptr inbounds [19 x i8], ptr @.str.37980, i32 0, i32 0
  %ret.37944.left.left.left.left.left.left.left.left.left.left = call ptr @csec_string_concat(ptr %ret.37944.left.left.left.left.left.left.left.left.left.left.left, ptr %ret.37944.left.left.left.left.left.left.left.left.left.left.right)
  %ret.37944.left.left.left.left.left.left.left.left.left.right = load ptr, ptr %labelSeed.addr.37889
  %ret.37944.left.left.left.left.left.left.left.left.left = call ptr @csec_string_concat(ptr %ret.37944.left.left.left.left.left.left.left.left.left.left, ptr %ret.37944.left.left.left.left.left.left.left.left.left.right)
  %ret.37944.left.left.left.left.left.left.left.left.right = getelementptr inbounds [2 x i8], ptr @.str.37984, i32 0, i32 0
  %ret.37944.left.left.left.left.left.left.left.left = call ptr @csec_string_concat(ptr %ret.37944.left.left.left.left.left.left.left.left.left, ptr %ret.37944.left.left.left.left.left.left.left.left.right)
  %ret.37944.left.left.left.left.left.left.left.right = getelementptr inbounds [11 x i8], ptr @.str.37986, i32 0, i32 0
  %ret.37944.left.left.left.left.left.left.left = call ptr @csec_string_concat(ptr %ret.37944.left.left.left.left.left.left.left.left, ptr %ret.37944.left.left.left.left.left.left.left.right)
  %ret.37944.left.left.left.left.left.left.right = load ptr, ptr %labelSeed.addr.37889
  %ret.37944.left.left.left.left.left.left = call ptr @csec_string_concat(ptr %ret.37944.left.left.left.left.left.left.left, ptr %ret.37944.left.left.left.left.left.left.right)
  %ret.37944.left.left.left.left.left.right = getelementptr inbounds [3 x i8], ptr @.str.37990, i32 0, i32 0
  %ret.37944.left.left.left.left.left = call ptr @csec_string_concat(ptr %ret.37944.left.left.left.left.left.left, ptr %ret.37944.left.left.left.left.left.right)
  %ret.37944.left.left.left.left.right = load ptr, ptr %body.addr.37898
  %ret.37944.left.left.left.left = call ptr @csec_string_concat(ptr %ret.37944.left.left.left.left.left, ptr %ret.37944.left.left.left.left.right)
  %ret.37944.left.left.left.right = load ptr, ptr %continueBranch.addr.37914
  %ret.37944.left.left.left = call ptr @csec_string_concat(ptr %ret.37944.left.left.left.left, ptr %ret.37944.left.left.left.right)
  %ret.37944.left.left.right = getelementptr inbounds [10 x i8], ptr @.str.37996, i32 0, i32 0
  %ret.37944.left.left = call ptr @csec_string_concat(ptr %ret.37944.left.left.left, ptr %ret.37944.left.left.right)
  %ret.37944.left.right = load ptr, ptr %labelSeed.addr.37889
  %ret.37944.left = call ptr @csec_string_concat(ptr %ret.37944.left.left, ptr %ret.37944.left.right)
  %ret.37944.right = getelementptr inbounds [3 x i8], ptr @.str.38000, i32 0, i32 0
  %ret.37944 = call ptr @csec_string_concat(ptr %ret.37944.left, ptr %ret.37944.right)
  ret ptr %ret.37944
}

define ptr @generateLLVMForI32(ptr %arg.tokens, i32 %arg.start, i32 %arg.end) {
entry:
  %tokens = alloca ptr
  store ptr %arg.tokens, ptr %tokens
  %start = alloca i32
  store i32 %arg.start, ptr %start
  %end = alloca i32
  store i32 %arg.end, ptr %end
  %ret.38336.left.left.left.left.left.left.left.left.left.left.left.left.left.left.left.left.left.left.left.left.left.left.left.right = getelementptr inbounds [11 x i8], ptr @.str.38409, i32 0, i32 0
  %ret.38336.left.left.left.left.left.left.left.left.left.left.left.left.left.left.left.left.left.left.left.left.left.left.left = call ptr @csec_string_concat(ptr %ret.38336.left.left.left.left.left.left.left.left.left.left.left.left.left.left.left.left.left.left.left.left.left.left.left.left, ptr %ret.38336.left.left.left.left.left.left.left.left.left.left.left.left.left.left.left.left.left.left.left.left.left.left.left.right)
  %ret.38336.left.left.left.left.left.left.left.left.left.left.left.left.left.left.left.left.left.left.left.left.left.left.right = load ptr, ptr %labelSeed.addr.38196
  %ret.38336.left.left.left.left.left.left.left.left.left.left.left.left.left.left.left.left.left.left.left.left.left.left = call ptr @csec_string_concat(ptr %ret.38336.left.left.left.left.left.left.left.left.left.left.left.left.left.left.left.left.left.left.left.left.left.left.left, ptr %ret.38336.left.left.left.left.left.left.left.left.left.left.left.left.left.left.left.left.left.left.left.left.left.left.right)
  %ret.38336.left.left.left.left.left.left.left.left.left.left.left.left.left.left.left.left.left.left.left.left.left.right = getelementptr inbounds [8 x i8], ptr @.str.38413, i32 0, i32 0
  %ret.38336.left.left.left.left.left.left.left.left.left.left.left.left.left.left.left.left.left.left.left.left.left = call ptr @csec_string_concat(ptr %ret.38336.left.left.left.left.left.left.left.left.left.left.left.left.left.left.left.left.left.left.left.left.left.left, ptr %ret.38336.left.left.left.left.left.left.left.left.left.left.left.left.left.left.left.left.left.left.left.left.left.right)
  %ret.38336.left.left.left.left.left.left.left.left.left.left.left.left.left.left.left.left.left.left.left.left.right = load ptr, ptr %compareOp.addr.38205
  %ret.38336.left.left.left.left.left.left.left.left.left.left.left.left.left.left.left.left.left.left.left.left = call ptr @csec_string_concat(ptr %ret.38336.left.left.left.left.left.left.left.left.left.left.left.left.left.left.left.left.left.left.left.left.left, ptr %ret.38336.left.left.left.left.left.left.left.left.left.left.left.left.left.left.left.left.left.left.left.left.right)
  %ret.38336.left.left.left.left.left.left.left.left.left.left.left.left.left.left.left.left.left.left.left.right = getelementptr inbounds [6 x i8], ptr @.str.38417, i32 0, i32 0
  %ret.38336.left.left.left.left.left.left.left.left.left.left.left.left.left.left.left.left.left.left.left = call ptr @csec_string_concat(ptr %ret.38336.left.left.left.left.left.left.left.left.left.left.left.left.left.left.left.left.left.left.left.left, ptr %ret.38336.left.left.left.left.left.left.left.left.left.left.left.left.left.left.left.left.left.left.left.right)
  %ret.38336.left.left.left.left.left.left.left.left.left.left.left.left.left.left.left.left.left.left.right = load ptr, ptr %iteratorName.addr.38124
  %ret.38336.left.left.left.left.left.left.left.left.left.left.left.left.left.left.left.left.left.left = call ptr @csec_string_concat(ptr %ret.38336.left.left.left.left.left.left.left.left.left.left.left.left.left.left.left.left.left.left.left, ptr %ret.38336.left.left.left.left.left.left.left.left.left.left.left.left.left.left.left.left.left.left.right)
  %ret.38336.left.left.left.left.left.left.left.left.left.left.left.left.left.left.left.left.left.right = getelementptr inbounds [7 x i8], ptr @.str.38421, i32 0, i32 0
  %ret.38336.left.left.left.left.left.left.left.left.left.left.left.left.left.left.left.left.left = call ptr @csec_string_concat(ptr %ret.38336.left.left.left.left.left.left.left.left.left.left.left.left.left.left.left.left.left.left, ptr %ret.38336.left.left.left.left.left.left.left.left.left.left.left.left.left.left.left.left.left.right)
  %ret.38336.left.left.left.left.left.left.left.left.left.left.left.left.left.left.left.left.right = load ptr, ptr %iteratorName.addr.38124
  %ret.38336.left.left.left.left.left.left.left.left.left.left.left.left.left.left.left.left = call ptr @csec_string_concat(ptr %ret.38336.left.left.left.left.left.left.left.left.left.left.left.left.left.left.left.left.left, ptr %ret.38336.left.left.left.left.left.left.left.left.left.left.left.left.left.left.left.left.right)
  %ret.38336.left.left.left.left.left.left.left.left.left.left.left.left.left.left.left.right = getelementptr inbounds [6 x i8], ptr @.str.38425, i32 0, i32 0
  %ret.38336.left.left.left.left.left.left.left.left.left.left.left.left.left.left.left = call ptr @csec_string_concat(ptr %ret.38336.left.left.left.left.left.left.left.left.left.left.left.left.left.left.left.left, ptr %ret.38336.left.left.left.left.left.left.left.left.left.left.left.left.left.left.left.right)
  %ret.38336.left.left.left.left.left.left.left.left.left.left.left.left.left.left.right = getelementptr inbounds [17 x i8], ptr @.str.38427, i32 0, i32 0
  %ret.38336.left.left.left.left.left.left.left.left.left.left.left.left.left.left = call ptr @csec_string_concat(ptr %ret.38336.left.left.left.left.left.left.left.left.left.left.left.left.left.left.left, ptr %ret.38336.left.left.left.left.left.left.left.left.left.left.left.left.left.left.right)
  %ret.38336.left.left.left.left.left.left.left.left.left.left.left.left.left.right = load ptr, ptr %labelSeed.addr.38196
  %ret.38336.left.left.left.left.left.left.left.left.left.left.left.left.left = call ptr @csec_string_concat(ptr %ret.38336.left.left.left.left.left.left.left.left.left.left.left.left.left.left, ptr %ret.38336.left.left.left.left.left.left.left.left.left.left.left.left.left.right)
  %ret.38336.left.left.left.left.left.left.left.left.left.left.left.left.right = getelementptr inbounds [18 x i8], ptr @.str.38431, i32 0, i32 0
  %ret.38336.left.left.left.left.left.left.left.left.left.left.left.left = call ptr @csec_string_concat(ptr %ret.38336.left.left.left.left.left.left.left.left.left.left.left.left.left, ptr %ret.38336.left.left.left.left.left.left.left.left.left.left.left.left.right)
  %ret.38336.left.left.left.left.left.left.left.left.left.left.left.right = load ptr, ptr %labelSeed.addr.38196
  %ret.38336.left.left.left.left.left.left.left.left.left.left.left = call ptr @csec_string_concat(ptr %ret.38336.left.left.left.left.left.left.left.left.left.left.left.left, ptr %ret.38336.left.left.left.left.left.left.left.left.left.left.left.right)
  %ret.38336.left.left.left.left.left.left.left.left.left.left.right = getelementptr inbounds [17 x i8], ptr @.str.38435, i32 0, i32 0
  %ret.38336.left.left.left.left.left.left.left.left.left.left = call ptr @csec_string_concat(ptr %ret.38336.left.left.left.left.left.left.left.left.left.left.left, ptr %ret.38336.left.left.left.left.left.left.left.left.left.left.right)
  %ret.38336.left.left.left.left.left.left.left.left.left.right = load ptr, ptr %labelSeed.addr.38196
  %ret.38336.left.left.left.left.left.left.left.left.left = call ptr @csec_string_concat(ptr %ret.38336.left.left.left.left.left.left.left.left.left.left, ptr %ret.38336.left.left.left.left.left.left.left.left.left.right)
  %ret.38336.left.left.left.left.left.left.left.left.right = getelementptr inbounds [2 x i8], ptr @.str.38439, i32 0, i32 0
  %ret.38336.left.left.left.left.left.left.left.left = call ptr @csec_string_concat(ptr %ret.38336.left.left.left.left.left.left.left.left.left, ptr %ret.38336.left.left.left.left.left.left.left.left.right)
  %ret.38336.left.left.left.left.left.left.left.right = getelementptr inbounds [9 x i8], ptr @.str.38441, i32 0, i32 0
  %ret.38336.left.left.left.left.left.left.left = call ptr @csec_string_concat(ptr %ret.38336.left.left.left.left.left.left.left.left, ptr %ret.38336.left.left.left.left.left.left.left.right)
  %ret.38336.left.left.left.left.left.left.right = load ptr, ptr %labelSeed.addr.38196
  %ret.38336.left.left.left.left.left.left = call ptr @csec_string_concat(ptr %ret.38336.left.left.left.left.left.left.left, ptr %ret.38336.left.left.left.left.left.left.right)
  %ret.38336.left.left.left.left.left.right = getelementptr inbounds [3 x i8], ptr @.str.38445, i32 0, i32 0
  %ret.38336.left.left.left.left.left = call ptr @csec_string_concat(ptr %ret.38336.left.left.left.left.left.left, ptr %ret.38336.left.left.left.left.left.right)
  %ret.38336.left.left.left.left.right = load ptr, ptr %body.addr.38244
  %ret.38336.left.left.left.left = call ptr @csec_string_concat(ptr %ret.38336.left.left.left.left.left, ptr %ret.38336.left.left.left.left.right)
  %ret.38336.left.left.left.right = load ptr, ptr %stepBranch.addr.38260
  %ret.38336.left.left.left = call ptr @csec_string_concat(ptr %ret.38336.left.left.left.left, ptr %ret.38336.left.left.left.right)
  %ret.38336.left.left.right = getelementptr inbounds [8 x i8], ptr @.str.38451, i32 0, i32 0
  %ret.38336.left.left = call ptr @csec_string_concat(ptr %ret.38336.left.left.left, ptr %ret.38336.left.left.right)
  %ret.38336.left.right = load ptr, ptr %labelSeed.addr.38196
  %ret.38336.left = call ptr @csec_string_concat(ptr %ret.38336.left.left, ptr %ret.38336.left.right)
  %ret.38336.right = getelementptr inbounds [3 x i8], ptr @.str.38455, i32 0, i32 0
  %ret.38336 = call ptr @csec_string_concat(ptr %ret.38336.left, ptr %ret.38336.right)
  ret ptr %ret.38336
}

define ptr @generateLLVMReturnI32(ptr %arg.tokens, i32 %arg.bodyStart, i32 %arg.bodyEnd) {
entry:
  %tokens = alloca ptr
  store ptr %arg.tokens, ptr %tokens
  %bodyStart = alloca i32
  store i32 %arg.bodyStart, ptr %bodyStart
  %bodyEnd = alloca i32
  store i32 %arg.bodyEnd, ptr %bodyEnd
  %ret.38594 = getelementptr inbounds [14 x i8], ptr @.str.0, i32 0, i32 0
  ret ptr %ret.38594
}

define ptr @generateLLVMDottedStatementCall(ptr %arg.tokens, i32 %arg.cursor, i32 %arg.next) {
entry:
  %tokens = alloca ptr
  store ptr %arg.tokens, ptr %tokens
  %cursor = alloca i32
  store i32 %arg.cursor, ptr %cursor
  %next = alloca i32
  store i32 %arg.next, ptr %next
  %ret.38976 = getelementptr inbounds [1 x i8], ptr @.str.0, i32 0, i32 0
  ret ptr %ret.38976
}

define ptr @generateLLVMMainBodyFromRange(ptr %arg.tokens, i32 %arg.bodyStart, i32 %arg.bodyEnd) {
entry:
  %tokens = alloca ptr
  store ptr %arg.tokens, ptr %tokens
  %bodyStart = alloca i32
  store i32 %arg.bodyStart, ptr %bodyStart
  %bodyEnd = alloca i32
  store i32 %arg.bodyEnd, ptr %bodyEnd
  %ret.39845.left = load ptr, ptr %output.addr.38998
  %ret.39845.right = getelementptr inbounds [13 x i8], ptr @.str.39848, i32 0, i32 0
  %ret.39845 = call ptr @csec_string_concat(ptr %ret.39845.left, ptr %ret.39845.right)
  ret ptr %ret.39845
}

define ptr @generateLLVMParamList(ptr %arg.tokens, i32 %arg.declStart) {
entry:
  %tokens = alloca ptr
  store ptr %arg.tokens, ptr %tokens
  %declStart = alloca i32
  store i32 %arg.declStart, ptr %declStart
  ret ptr null
}

define ptr @generateLLVMParamListSlow(ptr %arg.tokens, i32 %arg.declStart) {
entry:
  %tokens = alloca ptr
  store ptr %arg.tokens, ptr %tokens
  %declStart = alloca i32
  store i32 %arg.declStart, ptr %declStart
  %ret.40099 = load ptr, ptr %output.addr.39943
  ret ptr %ret.40099
}

define ptr @generateLLVMParamAllocas(ptr %arg.tokens, i32 %arg.declStart) {
entry:
  %tokens = alloca ptr
  store ptr %arg.tokens, ptr %tokens
  %declStart = alloca i32
  store i32 %arg.declStart, ptr %declStart
  ret ptr null
}

define ptr @generateLLVMParamAllocasSlow(ptr %arg.tokens, i32 %arg.declStart) {
entry:
  %tokens = alloca ptr
  store ptr %arg.tokens, ptr %tokens
  %declStart = alloca i32
  store i32 %arg.declStart, ptr %declStart
  %ret.40370 = load ptr, ptr %output.addr.40206
  ret ptr %ret.40370
}

define ptr @generateLLVMBooleanBodyFromRange(ptr %arg.tokens, i32 %arg.bodyStart, i32 %arg.bodyEnd) {
entry:
  %tokens = alloca ptr
  store ptr %arg.tokens, ptr %tokens
  %bodyStart = alloca i32
  store i32 %arg.bodyStart, ptr %bodyStart
  %bodyEnd = alloca i32
  store i32 %arg.bodyEnd, ptr %bodyEnd
  %ret.41069.left = load ptr, ptr %output.addr.40404
  %ret.41069.right = getelementptr inbounds [16 x i8], ptr @.str.41072, i32 0, i32 0
  %ret.41069 = call ptr @csec_string_concat(ptr %ret.41069.left, ptr %ret.41069.right)
  ret ptr %ret.41069
}

define ptr @generateLLVMCharBodyFromRange(ptr %arg.tokens, i32 %arg.bodyStart, i32 %arg.bodyEnd) {
entry:
  %tokens = alloca ptr
  store ptr %arg.tokens, ptr %tokens
  %bodyStart = alloca i32
  store i32 %arg.bodyStart, ptr %bodyStart
  %bodyEnd = alloca i32
  store i32 %arg.bodyEnd, ptr %bodyEnd
  %ret.41427.left = load ptr, ptr %output.addr.41105
  %ret.41427.right = getelementptr inbounds [12 x i8], ptr @.str.41430, i32 0, i32 0
  %ret.41427 = call ptr @csec_string_concat(ptr %ret.41427.left, ptr %ret.41427.right)
  ret ptr %ret.41427
}

define ptr @generateLLVMDoubleBodyFromRange(ptr %arg.tokens, i32 %arg.bodyStart, i32 %arg.bodyEnd) {
entry:
  %tokens = alloca ptr
  store ptr %arg.tokens, ptr %tokens
  %bodyStart = alloca i32
  store i32 %arg.bodyStart, ptr %bodyStart
  %bodyEnd = alloca i32
  store i32 %arg.bodyEnd, ptr %bodyEnd
  %ret.41683.left = load ptr, ptr %output.addr.41463
  %ret.41683.right = getelementptr inbounds [27 x i8], ptr @.str.41686, i32 0, i32 0
  %ret.41683 = call ptr @csec_string_concat(ptr %ret.41683.left, ptr %ret.41683.right)
  ret ptr %ret.41683
}

define ptr @generateLLVMLongBodyFromRange(ptr %arg.tokens, i32 %arg.bodyStart, i32 %arg.bodyEnd) {
entry:
  %tokens = alloca ptr
  store ptr %arg.tokens, ptr %tokens
  %bodyStart = alloca i32
  store i32 %arg.bodyStart, ptr %bodyStart
  %bodyEnd = alloca i32
  store i32 %arg.bodyEnd, ptr %bodyEnd
  %ret.41924.left = load ptr, ptr %output.addr.41719
  %ret.41924.right = getelementptr inbounds [13 x i8], ptr @.str.41927, i32 0, i32 0
  %ret.41924 = call ptr @csec_string_concat(ptr %ret.41924.left, ptr %ret.41924.right)
  ret ptr %ret.41924
}

define i32 @llvmStringLiteralByteLength(ptr %arg.text) {
entry:
  %text = alloca ptr
  store ptr %arg.text, ptr %text
  ret i32 0
}

define ptr @generateLLVMPointerBodyFromRange(ptr %arg.tokens, i32 %arg.bodyStart, i32 %arg.bodyEnd) {
entry:
  %tokens = alloca ptr
  store ptr %arg.tokens, ptr %tokens
  %bodyStart = alloca i32
  store i32 %arg.bodyStart, ptr %bodyStart
  %bodyEnd = alloca i32
  store i32 %arg.bodyEnd, ptr %bodyEnd
  %ret.42806.left = load ptr, ptr %output.addr.42040
  %ret.42806.right = getelementptr inbounds [16 x i8], ptr @.str.42809, i32 0, i32 0
  %ret.42806 = call ptr @csec_string_concat(ptr %ret.42806.left, ptr %ret.42806.right)
  ret ptr %ret.42806
}

define ptr @generateLLVMVoidBodyFromRange(ptr %arg.tokens, i32 %arg.bodyStart, i32 %arg.bodyEnd) {
entry:
  %tokens = alloca ptr
  store ptr %arg.tokens, ptr %tokens
  %bodyStart = alloca i32
  store i32 %arg.bodyStart, ptr %bodyStart
  %bodyEnd = alloca i32
  store i32 %arg.bodyEnd, ptr %bodyEnd
  %ret.42925.left = load ptr, ptr %output.addr.42842
  %ret.42925.right = getelementptr inbounds [12 x i8], ptr @.str.42928, i32 0, i32 0
  %ret.42925 = call ptr @csec_string_concat(ptr %ret.42925.left, ptr %ret.42925.right)
  ret ptr %ret.42925
}

define ptr @llvmStringLiteralBytes(ptr %arg.text) {
entry:
  %text = alloca ptr
  store ptr %arg.text, ptr %text
  ret ptr null
}

define ptr @generateLLVMStringLiteralGlobals(ptr %arg.tokens) {
entry:
  %tokens = alloca ptr
  store ptr %arg.tokens, ptr %tokens
  ret ptr null
}

define ptr @generateLLVMFunctionDefinition(ptr %arg.tokens, i32 %arg.declStart) {
entry:
  %tokens = alloca ptr
  store ptr %arg.tokens, ptr %tokens
  %declStart = alloca i32
  store i32 %arg.declStart, ptr %declStart
  %ret.44092 = getelementptr inbounds [1 x i8], ptr @.str.0, i32 0, i32 0
  ret ptr %ret.44092
}

define i32 @generateLLVMModuleInto(ptr %arg.tokens, i64 %arg.builder) {
entry:
  %tokens = alloca ptr
  store ptr %arg.tokens, ptr %tokens
  %builder = alloca i64
  store i64 %arg.builder, ptr %builder
  ret i32 0
}

define ptr @generateLLVMModule(ptr %arg.tokens) {
entry:
  %tokens = alloca ptr
  store ptr %arg.tokens, ptr %tokens
  %ret.45157.right = getelementptr inbounds [3 x i8], ptr @.str.45167, i32 0, i32 0
  %ret.45157 = call ptr @csec_string_concat(ptr %ret.45157.left, ptr %ret.45157.right)
  ret ptr %ret.45157
}

define ptr @generateExecutionC(ptr %arg.tokens) {
entry:
  %tokens = alloca ptr
  store ptr %arg.tokens, ptr %tokens
  ret ptr null
}

define ptr @trimAscii(ptr %arg.text) {
entry:
  %text = alloca ptr
  store ptr %arg.text, ptr %text
  ret ptr null
}

define i1 @stringEndsWith(ptr %arg.text, ptr %arg.suffix) {
entry:
  %text = alloca ptr
  store ptr %arg.text, ptr %text
  %suffix = alloca ptr
  store ptr %arg.suffix, ptr %suffix
  %ret.45358 = icmp eq i32 0, 0
  ret i1 %ret.45358
}

define ptr @parentDirectory(ptr %arg.path) {
entry:
  %path = alloca ptr
  store ptr %arg.path, ptr %path
  %ret.45436 = getelementptr inbounds [2 x i8], ptr @.str.0, i32 0, i32 0
  ret ptr %ret.45436
}

define ptr @replaceDotsWithSlash(ptr %arg.text) {
entry:
  %text = alloca ptr
  store ptr %arg.text, ptr %text
  %ret.45517 = load ptr, ptr %output.addr.45457
  ret ptr %ret.45517
}

define ptr @importTargetFromLine(ptr %arg.line) {
entry:
  %line = alloca ptr
  store ptr %arg.line, ptr %line
  %ret.45747 = load ptr, ptr %rest.addr.45611
  ret ptr %ret.45747
}

define ptr @importCandidate(ptr %arg.target) {
entry:
  %target = alloca ptr
  store ptr %arg.target, ptr %target
  %ret.45775.left = load ptr, ptr %target
  %ret.45775.right = getelementptr inbounds [5 x i8], ptr @.str.45778, i32 0, i32 0
  %ret.45775 = call ptr @csec_string_concat(ptr %ret.45775.left, ptr %ret.45775.right)
  ret ptr %ret.45775
}

define ptr @resolveImportPath(ptr %arg.currentPath, ptr %arg.target) {
entry:
  %currentPath = alloca ptr
  store ptr %arg.currentPath, ptr %currentPath
  %target = alloca ptr
  store ptr %arg.target, ptr %target
  %ret.45904 = load ptr, ptr %fromBase.addr.45815
  ret ptr %ret.45904
}

define ptr @expandImportsFromFile(ptr %arg.path, ptr %arg.seen) {
entry:
  %path = alloca ptr
  store ptr %arg.path, ptr %path
  %seen = alloca ptr
  store ptr %arg.seen, ptr %seen
  %ret.46188 = load ptr, ptr %output.addr.45994
  ret ptr %ret.46188
}

define ptr @compileSource(ptr %arg.source, ptr %arg.mode) {
entry:
  %source = alloca ptr
  store ptr %arg.source, ptr %source
  %mode = alloca ptr
  store ptr %arg.mode, ptr %mode
  ret ptr null
}

define i32 @compileFile(ptr %arg.inputPath, ptr %arg.outputPath, ptr %arg.mode) {
entry:
  %inputPath = alloca ptr
  store ptr %arg.inputPath, ptr %inputPath
  %outputPath = alloca ptr
  store ptr %arg.outputPath, ptr %outputPath
  %mode = alloca ptr
  store ptr %arg.mode, ptr %mode
  ret i32 0
}

define i32 @csec_user_main() {
entry:
  ret i32 0
}

define i32 @main(i32 %argc, ptr %argv) {
entry:
  call void @csec_set_command_line_args(i32 %argc, ptr %argv)
  %ret = call i32 @csec_user_main()
  ret i32 %ret
}
