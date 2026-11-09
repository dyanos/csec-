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
   = icmp eq i32 0, 0
   = load i32, ptr %ch
  %ret.226 = or i1 %ret.226.left, %ret.226.right
  ; bool operands %btmp, %btmp
  ret i1 %ret.226
}

define i1 @isDigit(i8 %arg.ch) {
entry:
  %ch = alloca i8
  store i8 %arg.ch, ptr %ch
   = load i32, ptr %ch
   = load i32, ptr %ch
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
   = icmp eq i32 0, 0
   = load i32, ptr %ch
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
   = load ptr, ptr %text
  ret ptr 
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
   = add i32 0, 0
  ret i1 %ret.3006
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
   = load i32, ptr %paren
   = load i32, ptr %brace
   = and i1 .left, .right
  ; bool operands %btmp, %btmp
   = load i32, ptr %bracket
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
  %ret.3917 = icmp eq i32 0, 0
  ret i1 %ret.3917
}

define ptr @topLevelDeclKind(ptr %arg.tokens, i32 %arg.ordinal) {
entry:
  %tokens = alloca ptr
  store ptr %arg.tokens, ptr %tokens
  %ordinal = alloca i32
  store i32 %arg.ordinal, ptr %ordinal
   = getelementptr inbounds [8 x i8], ptr @.str.0, i32 0, i32 0
  ret ptr 
}

define ptr @topLevelDeclName(ptr %arg.tokens, i32 %arg.ordinal) {
entry:
  %tokens = alloca ptr
  store ptr %arg.tokens, ptr %tokens
  %ordinal = alloca i32
  store i32 %arg.ordinal, ptr %ordinal
   = getelementptr inbounds [12 x i8], ptr @.str.0, i32 0, i32 0
  ret ptr 
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
   = getelementptr inbounds [11 x i8], ptr @.str.0, i32 0, i32 0
  ret ptr 
}

define ptr @appendExpressionUntil(ptr %arg.tokens, i32 %arg.start, i32 %arg.end) {
entry:
  %tokens = alloca ptr
  store ptr %arg.tokens, ptr %tokens
  %start = alloca i32
  store i32 %arg.start, ptr %start
  %end = alloca i32
  store i32 %arg.end, ptr %end
   = load ptr, ptr %output
  ret ptr 
}

define i1 @tokenIsTopLevelOperator(ptr %arg.tokens, i32 %arg.ordinal, i32 %arg.group) {
entry:
  %tokens = alloca ptr
  store ptr %arg.tokens, ptr %tokens
  %ordinal = alloca i32
  store i32 %arg.ordinal, ptr %ordinal
  %group = alloca i32
  store i32 %arg.group, ptr %group
  %ret.5970 = icmp eq i1 false, true
  ret i1 %ret.5970
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
   = getelementptr inbounds [8 x i8], ptr @.str.0, i32 0, i32 0
  ret ptr 
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
   = getelementptr inbounds [1 x i8], ptr @.str.0, i32 0, i32 0
  ret ptr 
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
   = getelementptr inbounds [1 x i8], ptr @.str.0, i32 0, i32 0
  ret ptr 
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
  .right = getelementptr inbounds [2 x i8], ptr @.str.10594, i32 0, i32 0
   = call ptr @csec_string_concat(ptr .left, ptr .right)
  ret ptr 
}

define ptr @generateBodyAST(ptr %arg.tokens, i32 %arg.bodyStart, i32 %arg.bodyEnd) {
entry:
  %tokens = alloca ptr
  store ptr %arg.tokens, ptr %tokens
  %bodyStart = alloca i32
  store i32 %arg.bodyStart, ptr %bodyStart
  %bodyEnd = alloca i32
  store i32 %arg.bodyEnd, ptr %bodyEnd
   = load ptr, ptr %output
  ret ptr 
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
   = load ptr, ptr %output
  ret ptr 
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
   = load ptr, ptr %typeName
  ret ptr 
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
   = getelementptr inbounds [6 x i8], ptr @.str.0, i32 0, i32 0
  ret ptr 
}

define ptr @lookupFunctionReturnType(ptr %arg.tokens, ptr %arg.name) {
entry:
  %tokens = alloca ptr
  store ptr %arg.tokens, ptr %tokens
  %name = alloca ptr
  store ptr %arg.name, ptr %name
   = getelementptr inbounds [8 x i8], ptr @.str.0, i32 0, i32 0
  ret ptr 
}

define ptr @inferExpressionType(ptr %arg.tokens, i32 %arg.rawStart, i32 %arg.rawEnd) {
entry:
  %tokens = alloca ptr
  store ptr %arg.tokens, ptr %tokens
  %rawStart = alloca i32
  store i32 %arg.rawStart, ptr %rawStart
  %rawEnd = alloca i32
  store i32 %arg.rawEnd, ptr %rawEnd
   = getelementptr inbounds [8 x i8], ptr @.str.0, i32 0, i32 0
  ret ptr 
}

define ptr @declaredLocalType(ptr %arg.tokens, i32 %arg.start, i32 %arg.end) {
entry:
  %tokens = alloca ptr
  store ptr %arg.tokens, ptr %tokens
  %start = alloca i32
  store i32 %arg.start, ptr %start
  %end = alloca i32
  store i32 %arg.end, ptr %end
   = getelementptr inbounds [1 x i8], ptr @.str.0, i32 0, i32 0
  ret ptr 
}

define ptr @localDeclarationType(ptr %arg.tokens, i32 %arg.start, i32 %arg.end) {
entry:
  %tokens = alloca ptr
  store ptr %arg.tokens, ptr %tokens
  %start = alloca i32
  store i32 %arg.start, ptr %start
  %end = alloca i32
  store i32 %arg.end, ptr %end
   = getelementptr inbounds [8 x i8], ptr @.str.0, i32 0, i32 0
  ret ptr 
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
   = load ptr, ptr %output
  ret ptr 
}

define ptr @generateFunctionParamSymbols(ptr %arg.tokens, ptr %arg.functionName, i32 %arg.declStart) {
entry:
  %tokens = alloca ptr
  store ptr %arg.tokens, ptr %tokens
  %functionName = alloca ptr
  store ptr %arg.functionName, ptr %functionName
  %declStart = alloca i32
  store i32 %arg.declStart, ptr %declStart
   = load ptr, ptr %output
  ret ptr 
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
   = getelementptr inbounds [7 x i8], ptr @.str.0, i32 0, i32 0
  ret ptr 
}

define ptr @classMemberName(ptr %arg.tokens, i32 %arg.ordinal) {
entry:
  %tokens = alloca ptr
  store ptr %arg.tokens, ptr %tokens
  %ordinal = alloca i32
  store i32 %arg.ordinal, ptr %ordinal
   = getelementptr inbounds [9 x i8], ptr @.str.0, i32 0, i32 0
  ret ptr 
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
   = load ptr, ptr %output
  ret ptr 
}

define ptr @generateClassMemberAST(ptr %arg.tokens, i32 %arg.bodyStart, i32 %arg.bodyEnd) {
entry:
  %tokens = alloca ptr
  store ptr %arg.tokens, ptr %tokens
  %bodyStart = alloca i32
  store i32 %arg.bodyStart, ptr %bodyStart
  %bodyEnd = alloca i32
  store i32 %arg.bodyEnd, ptr %bodyEnd
   = load ptr, ptr %output
  ret ptr 
}

define ptr @templateParameterSummary(ptr %arg.tokens, i32 %arg.ordinal) {
entry:
  %tokens = alloca ptr
  store ptr %arg.tokens, ptr %tokens
  %ordinal = alloca i32
  store i32 %arg.ordinal, ptr %ordinal
   = load ptr, ptr %output
  ret ptr 
}

define ptr @templateTargetKind(ptr %arg.tokens, i32 %arg.ordinal) {
entry:
  %tokens = alloca ptr
  store ptr %arg.tokens, ptr %tokens
  %ordinal = alloca i32
  store i32 %arg.ordinal, ptr %ordinal
   = getelementptr inbounds [1 x i8], ptr @.str.0, i32 0, i32 0
  ret ptr 
}

define ptr @attributeSummary(ptr %arg.tokens, i32 %arg.ordinal) {
entry:
  %tokens = alloca ptr
  store ptr %arg.tokens, ptr %tokens
  %ordinal = alloca i32
  store i32 %arg.ordinal, ptr %ordinal
   = load ptr, ptr %output
  ret ptr 
}

define ptr @externalSymbolKind(ptr %arg.tokens, i32 %arg.ordinal) {
entry:
  %tokens = alloca ptr
  store ptr %arg.tokens, ptr %tokens
  %ordinal = alloca i32
  store i32 %arg.ordinal, ptr %ordinal
   = load ptr, ptr %kind
  ret ptr 
}

define ptr @generateSymbolTable(ptr %arg.tokens) {
entry:
  %tokens = alloca ptr
  store ptr %arg.tokens, ptr %tokens
   = load ptr, ptr %output
  ret ptr 
}

define ptr @generateAST(ptr %arg.tokens) {
entry:
  %tokens = alloca ptr
  store ptr %arg.tokens, ptr %tokens
   = load ptr, ptr %output
  ret ptr 
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
   = load ptr, ptr %output
  ret ptr 
}

define ptr @cTypeName(ptr %arg.typeName) {
entry:
  %typeName = alloca ptr
  store ptr %arg.typeName, ptr %typeName
   = getelementptr inbounds [6 x i8], ptr @.str.0, i32 0, i32 0
  ret ptr 
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
   = load ptr, ptr %output
  ret ptr 
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
  .right = getelementptr inbounds [3 x i8], ptr @.str.17000, i32 0, i32 0
   = call ptr @csec_string_concat(ptr .left, ptr .right)
  ret ptr 
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
   = getelementptr inbounds [1 x i8], ptr @.str.0, i32 0, i32 0
  ret ptr 
}

define ptr @irTypeName(ptr %arg.typeName) {
entry:
  %typeName = alloca ptr
  store ptr %arg.typeName, ptr %typeName
   = getelementptr inbounds [4 x i8], ptr @.str.0, i32 0, i32 0
  ret ptr 
}

define ptr @irOperatorName(ptr %arg.text) {
entry:
  %text = alloca ptr
  store ptr %arg.text, ptr %text
   = load ptr, ptr %text
  ret ptr 
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
  .left.left.left.left.left.left.left.right = getelementptr inbounds [3 x i8], ptr @.str.18771, i32 0, i32 0
  .left.left.left.left.left.left.left = call ptr @csec_string_concat(ptr .left.left.left.left.left.left.left.left, ptr .left.left.left.left.left.left.left.right)
  .left.left.left.left.left.left.right = getelementptr inbounds [10 x i8], ptr @.str.18773, i32 0, i32 0
  .left.left.left.left.left.left = call ptr @csec_string_concat(ptr .left.left.left.left.left.left.left, ptr .left.left.left.left.left.left.right)
  .left.left.left.left.left.right = load ptr, ptr %irType
  .left.left.left.left.left = call ptr @csec_string_concat(ptr .left.left.left.left.left.left, ptr .left.left.left.left.left.right)
  .left.left.left.left.right = getelementptr inbounds [6 x i8], ptr @.str.18777, i32 0, i32 0
  .left.left.left.left = call ptr @csec_string_concat(ptr .left.left.left.left.left, ptr .left.left.left.left.right)
  .left.left.left.right = load ptr, ptr %name
  .left.left.left = call ptr @csec_string_concat(ptr .left.left.left.left, ptr .left.left.left.right)
  .left.left.right = getelementptr inbounds [7 x i8], ptr @.str.18781, i32 0, i32 0
  .left.left = call ptr @csec_string_concat(ptr .left.left.left, ptr .left.left.right)
  .left.right = load ptr, ptr %name
  .left = call ptr @csec_string_concat(ptr .left.left, ptr .left.right)
  .right = getelementptr inbounds [2 x i8], ptr @.str.18785, i32 0, i32 0
   = call ptr @csec_string_concat(ptr .left, ptr .right)
  ret ptr 
}

define ptr @generateIRParamList(ptr %arg.tokens, i32 %arg.declStart) {
entry:
  %tokens = alloca ptr
  store ptr %arg.tokens, ptr %tokens
  %declStart = alloca i32
  store i32 %arg.declStart, ptr %declStart
   = load ptr, ptr %output
  ret ptr 
}

define ptr @generateIRFlatBody(ptr %arg.tokens, i32 %arg.bodyStart, i32 %arg.bodyEnd) {
entry:
  %tokens = alloca ptr
  store ptr %arg.tokens, ptr %tokens
  %bodyStart = alloca i32
  store i32 %arg.bodyStart, ptr %bodyStart
  %bodyEnd = alloca i32
  store i32 %arg.bodyEnd, ptr %bodyEnd
   = load ptr, ptr %output
  ret ptr 
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
   = getelementptr inbounds [27 x i8], ptr @.str.0, i32 0, i32 0
  ret ptr 
}

define ptr @generateIRIf(ptr %arg.tokens, i32 %arg.start, i32 %arg.end) {
entry:
  %tokens = alloca ptr
  store ptr %arg.tokens, ptr %tokens
  %start = alloca i32
  store i32 %arg.start, ptr %start
  %end = alloca i32
  store i32 %arg.end, ptr %end
  .left.left.left.left.left.right = getelementptr inbounds [21 x i8], ptr @.str.19771, i32 0, i32 0
  .left.left.left.left.left = call ptr @csec_string_concat(ptr .left.left.left.left.left.left, ptr .left.left.left.left.left.right)
  .left.left.left.left.right = load ptr, ptr %labelSeed
  .left.left.left.left = call ptr @csec_string_concat(ptr .left.left.left.left.left, ptr .left.left.left.left.right)
  .left.left.left.right = getelementptr inbounds [2 x i8], ptr @.str.19775, i32 0, i32 0
  .left.left.left = call ptr @csec_string_concat(ptr .left.left.left.left, ptr .left.left.left.right)
  .left.left.right = getelementptr inbounds [7 x i8], ptr @.str.19777, i32 0, i32 0
  .left.left = call ptr @csec_string_concat(ptr .left.left.left, ptr .left.left.right)
  .left.right = load ptr, ptr %labelSeed
  .left = call ptr @csec_string_concat(ptr .left.left, ptr .left.right)
  .right = getelementptr inbounds [3 x i8], ptr @.str.19781, i32 0, i32 0
   = call ptr @csec_string_concat(ptr .left, ptr .right)
  ret ptr 
}

define ptr @generateIRWhile(ptr %arg.tokens, i32 %arg.start, i32 %arg.end) {
entry:
  %tokens = alloca ptr
  store ptr %arg.tokens, ptr %tokens
  %start = alloca i32
  store i32 %arg.start, ptr %start
  %end = alloca i32
  store i32 %arg.end, ptr %end
  .left.left.left.left.left.right = getelementptr inbounds [25 x i8], ptr @.str.19957, i32 0, i32 0
  .left.left.left.left.left = call ptr @csec_string_concat(ptr .left.left.left.left.left.left, ptr .left.left.left.left.left.right)
  .left.left.left.left.right = load ptr, ptr %labelSeed
  .left.left.left.left = call ptr @csec_string_concat(ptr .left.left.left.left.left, ptr .left.left.left.left.right)
  .left.left.left.right = getelementptr inbounds [2 x i8], ptr @.str.19961, i32 0, i32 0
  .left.left.left = call ptr @csec_string_concat(ptr .left.left.left.left, ptr .left.left.left.right)
  .left.left.right = getelementptr inbounds [10 x i8], ptr @.str.19963, i32 0, i32 0
  .left.left = call ptr @csec_string_concat(ptr .left.left.left, ptr .left.left.right)
  .left.right = load ptr, ptr %labelSeed
  .left = call ptr @csec_string_concat(ptr .left.left, ptr .left.right)
  .right = getelementptr inbounds [3 x i8], ptr @.str.19967, i32 0, i32 0
   = call ptr @csec_string_concat(ptr .left, ptr .right)
  ret ptr 
}

define ptr @generateIRFor(ptr %arg.tokens, i32 %arg.start, i32 %arg.end) {
entry:
  %tokens = alloca ptr
  store ptr %arg.tokens, ptr %tokens
  %start = alloca i32
  store i32 %arg.start, ptr %start
  %end = alloca i32
  store i32 %arg.end, ptr %end
  .left.left.left.left.left.right = getelementptr inbounds [23 x i8], ptr @.str.20194, i32 0, i32 0
  .left.left.left.left.left = call ptr @csec_string_concat(ptr .left.left.left.left.left.left, ptr .left.left.left.left.left.right)
  .left.left.left.left.right = load ptr, ptr %labelSeed
  .left.left.left.left = call ptr @csec_string_concat(ptr .left.left.left.left.left, ptr .left.left.left.left.right)
  .left.left.left.right = getelementptr inbounds [2 x i8], ptr @.str.20198, i32 0, i32 0
  .left.left.left = call ptr @csec_string_concat(ptr .left.left.left.left, ptr .left.left.left.right)
  .left.left.right = getelementptr inbounds [8 x i8], ptr @.str.20200, i32 0, i32 0
  .left.left = call ptr @csec_string_concat(ptr .left.left.left, ptr .left.left.right)
  .left.right = load ptr, ptr %labelSeed
  .left = call ptr @csec_string_concat(ptr .left.left, ptr .left.right)
  .right = getelementptr inbounds [3 x i8], ptr @.str.20204, i32 0, i32 0
   = call ptr @csec_string_concat(ptr .left, ptr .right)
  ret ptr 
}

define ptr @generateIRBody(ptr %arg.tokens, i32 %arg.bodyStart, i32 %arg.bodyEnd) {
entry:
  %tokens = alloca ptr
  store ptr %arg.tokens, ptr %tokens
  %bodyStart = alloca i32
  store i32 %arg.bodyStart, ptr %bodyStart
  %bodyEnd = alloca i32
  store i32 %arg.bodyEnd, ptr %bodyEnd
   = load ptr, ptr %output
  ret ptr 
}

define ptr @generateIRDeclarations(ptr %arg.tokens) {
entry:
  %tokens = alloca ptr
  store ptr %arg.tokens, ptr %tokens
   = load ptr, ptr %output
  ret ptr 
}

define ptr @generateIR(ptr %arg.tokens) {
entry:
  %tokens = alloca ptr
  store ptr %arg.tokens, ptr %tokens
  .left.left.right = getelementptr inbounds [12 x i8], ptr @.str.20974, i32 0, i32 0
  .left.left = call ptr @csec_string_concat(ptr .left.left.left, ptr .left.left.right)
  .left.right = load ptr, ptr %returnValue
  .left = call ptr @csec_string_concat(ptr .left.left, ptr .left.right)
  .right = getelementptr inbounds [2 x i8], ptr @.str.20978, i32 0, i32 0
   = call ptr @csec_string_concat(ptr .left, ptr .right)
  ret ptr 
}

define ptr @generateLLVMMainBody(ptr %arg.tokens) {
entry:
  %tokens = alloca ptr
  store ptr %arg.tokens, ptr %tokens
  .left.left.left = getelementptr inbounds [8 x i8], ptr @.str.21002, i32 0, i32 0
  .left.left.right = getelementptr inbounds [10 x i8], ptr @.str.21004, i32 0, i32 0
  .left.left = call ptr @csec_string_concat(ptr .left.left.left, ptr .left.left.right)
  .left.right = load ptr, ptr %returnValue
  .left = call ptr @csec_string_concat(ptr .left.left, ptr .left.right)
  .right = getelementptr inbounds [2 x i8], ptr @.str.21008, i32 0, i32 0
   = call ptr @csec_string_concat(ptr .left, ptr .right)
  ret ptr 
}

define ptr @llvmCharI8Value(ptr %arg.text) {
entry:
  %text = alloca ptr
  store ptr %arg.text, ptr %text
   = getelementptr inbounds [2 x i8], ptr @.str.0, i32 0, i32 0
  ret ptr 
}

define ptr @llvmI32Value(ptr %arg.tokens, i32 %arg.start, i32 %arg.rawEnd) {
entry:
  %tokens = alloca ptr
  store ptr %arg.tokens, ptr %tokens
  %start = alloca i32
  store i32 %arg.start, ptr %start
  %rawEnd = alloca i32
  store i32 %arg.rawEnd, ptr %rawEnd
   = getelementptr inbounds [5 x i8], ptr @.str.0, i32 0, i32 0
  ret ptr 
}

define ptr @lookupFunctionParamType(ptr %arg.tokens, i32 %arg.limit, ptr %arg.name) {
entry:
  %tokens = alloca ptr
  store ptr %arg.tokens, ptr %tokens
  %limit = alloca i32
  store i32 %arg.limit, ptr %limit
  %name = alloca ptr
  store ptr %arg.name, ptr %name
   = getelementptr inbounds [8 x i8], ptr @.str.0, i32 0, i32 0
  ret ptr 
}

define ptr @lookupVisibleValueType(ptr %arg.tokens, i32 %arg.limit, ptr %arg.name) {
entry:
  %tokens = alloca ptr
  store ptr %arg.tokens, ptr %tokens
  %limit = alloca i32
  store i32 %arg.limit, ptr %limit
  %name = alloca ptr
  store ptr %arg.name, ptr %name
   = load ptr, ptr %found
  ret ptr 
}

define ptr @lookupVisibleStorageName(ptr %arg.tokens, i32 %arg.limit, ptr %arg.name) {
entry:
  %tokens = alloca ptr
  store ptr %arg.tokens, ptr %tokens
  %limit = alloca i32
  store i32 %arg.limit, ptr %limit
  %name = alloca ptr
  store ptr %arg.name, ptr %name
   = load ptr, ptr %found
  ret ptr 
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
  .left.left.left.left = getelementptr inbounds [2 x i8], ptr @.str.22431, i32 0, i32 0
  .left.left.left.right = load ptr, ptr %resultName
  .left.left.left = call ptr @csec_string_concat(ptr .left.left.left.left, ptr .left.left.left.right)
  .left.left.right = getelementptr inbounds [18 x i8], ptr @.str.22435, i32 0, i32 0
  .left.left = call ptr @csec_string_concat(ptr .left.left.left, ptr .left.left.right)
  .left.right = load ptr, ptr %storageName
  .left = call ptr @csec_string_concat(ptr .left.left, ptr .left.right)
  .right = getelementptr inbounds [2 x i8], ptr @.str.22439, i32 0, i32 0
   = call ptr @csec_string_concat(ptr .left, ptr .right)
  ret ptr 
}

define ptr @generateLLVMLoadIfIdentifier(ptr %arg.tokens, i32 %arg.start, i32 %arg.rawEnd) {
entry:
  %tokens = alloca ptr
  store ptr %arg.tokens, ptr %tokens
  %start = alloca i32
  store i32 %arg.start, ptr %start
  %rawEnd = alloca i32
  store i32 %arg.rawEnd, ptr %rawEnd
   = getelementptr inbounds [1 x i8], ptr @.str.0, i32 0, i32 0
  ret ptr 
}

define ptr @llvmI1Value(ptr %arg.tokens, i32 %arg.start, i32 %arg.rawEnd) {
entry:
  %tokens = alloca ptr
  store ptr %arg.tokens, ptr %tokens
  %start = alloca i32
  store i32 %arg.start, ptr %start
  %rawEnd = alloca i32
  store i32 %arg.rawEnd, ptr %rawEnd
   = getelementptr inbounds [6 x i8], ptr @.str.0, i32 0, i32 0
  ret ptr 
}

define ptr @generateLLVMLoadBoolIfIdentifier(ptr %arg.tokens, i32 %arg.start, i32 %arg.rawEnd) {
entry:
  %tokens = alloca ptr
  store ptr %arg.tokens, ptr %tokens
  %start = alloca i32
  store i32 %arg.start, ptr %start
  %rawEnd = alloca i32
  store i32 %arg.rawEnd, ptr %rawEnd
   = getelementptr inbounds [1 x i8], ptr @.str.0, i32 0, i32 0
  ret ptr 
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
  .left.left = load ptr, ptr %resultName
  .left.right = getelementptr inbounds [4 x i8], ptr @.str.22884, i32 0, i32 0
  .left = call ptr @csec_string_concat(ptr .left.left, ptr .left.right)
  .right = load ptr, ptr %index
   = call ptr @csec_string_concat(ptr .left, ptr .right)
  ret ptr 
}

define ptr @llvmCallArgumentType(ptr %arg.tokens, i32 %arg.start, i32 %arg.rawEnd) {
entry:
  %tokens = alloca ptr
  store ptr %arg.tokens, ptr %tokens
  %start = alloca i32
  store i32 %arg.start, ptr %start
  %rawEnd = alloca i32
  store i32 %arg.rawEnd, ptr %rawEnd
   = getelementptr inbounds [4 x i8], ptr @.str.0, i32 0, i32 0
  ret ptr 
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
  .left.left = load ptr, ptr %resultName
  .left.right = getelementptr inbounds [4 x i8], ptr @.str.23445, i32 0, i32 0
  .left = call ptr @csec_string_concat(ptr .left.left, ptr .left.right)
  .right = load ptr, ptr %index
   = call ptr @csec_string_concat(ptr .left, ptr .right)
  ret ptr 
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
  .left.left = getelementptr inbounds [2 x i8], ptr @.str.25309, i32 0, i32 0
  .left.right = load ptr, ptr %resultName
  .left = call ptr @csec_string_concat(ptr .left.left, ptr .left.right)
  .right = getelementptr inbounds [17 x i8], ptr @.str.25313, i32 0, i32 0
   = call ptr @csec_string_concat(ptr .left, ptr .right)
  ret ptr 
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
   = load ptr, ptr %output
  ret ptr 
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
   = load ptr, ptr %output
  ret ptr 
}

define ptr @llvmRuntimeCallName(ptr %arg.name) {
entry:
  %name = alloca ptr
  store ptr %arg.name, ptr %name
   = load ptr, ptr %name
  ret ptr 
}

define i1 @llvmCallReturnsChar(ptr %arg.tokens, ptr %arg.name) {
entry:
  %tokens = alloca ptr
  store ptr %arg.tokens, ptr %tokens
  %name = alloca ptr
  store ptr %arg.name, ptr %name
  %ret.26160 = icmp eq i1 false, true
  ret i1 %ret.26160
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
  .left.left = getelementptr inbounds [2 x i8], ptr @.str.27022, i32 0, i32 0
  .left.right = load ptr, ptr %resultName
  .left = call ptr @csec_string_concat(ptr .left.left, ptr .left.right)
  .right = getelementptr inbounds [17 x i8], ptr @.str.27026, i32 0, i32 0
   = call ptr @csec_string_concat(ptr .left, ptr .right)
  ret ptr 
}

define ptr @generateLLVMLocalI32(ptr %arg.tokens, i32 %arg.start, i32 %arg.end) {
entry:
  %tokens = alloca ptr
  store ptr %arg.tokens, ptr %tokens
  %start = alloca i32
  store i32 %arg.start, ptr %start
  %end = alloca i32
  store i32 %arg.end, ptr %end
  .left.left.left.left.left = getelementptr inbounds [3 x i8], ptr @.str.27140, i32 0, i32 0
  .left.left.left.left.right = load ptr, ptr %storageName
  .left.left.left.left = call ptr @csec_string_concat(ptr .left.left.left.left.left, ptr .left.left.left.left.right)
  .left.left.left.right = getelementptr inbounds [15 x i8], ptr @.str.27144, i32 0, i32 0
  .left.left.left = call ptr @csec_string_concat(ptr .left.left.left.left, ptr .left.left.left.right)
  .left.left.right = getelementptr inbounds [20 x i8], ptr @.str.27146, i32 0, i32 0
  .left.left = call ptr @csec_string_concat(ptr .left.left.left, ptr .left.left.right)
  .left.right = load ptr, ptr %storageName
  .left = call ptr @csec_string_concat(ptr .left.left, ptr .left.right)
  .right = getelementptr inbounds [2 x i8], ptr @.str.27150, i32 0, i32 0
   = call ptr @csec_string_concat(ptr .left, ptr .right)
  ret ptr 
}

define ptr @llvmI64Value(ptr %arg.tokens, i32 %arg.start, i32 %arg.rawEnd) {
entry:
  %tokens = alloca ptr
  store ptr %arg.tokens, ptr %tokens
  %start = alloca i32
  store i32 %arg.start, ptr %start
  %rawEnd = alloca i32
  store i32 %arg.rawEnd, ptr %rawEnd
   = getelementptr inbounds [6 x i8], ptr @.str.0, i32 0, i32 0
  ret ptr 
}

define ptr @generateLLVMLoadI64IfIdentifier(ptr %arg.tokens, i32 %arg.start, i32 %arg.rawEnd) {
entry:
  %tokens = alloca ptr
  store ptr %arg.tokens, ptr %tokens
  %start = alloca i32
  store i32 %arg.start, ptr %start
  %rawEnd = alloca i32
  store i32 %arg.rawEnd, ptr %rawEnd
   = getelementptr inbounds [1 x i8], ptr @.str.0, i32 0, i32 0
  ret ptr 
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
  .left.left = getelementptr inbounds [2 x i8], ptr @.str.27778, i32 0, i32 0
  .left.right = load ptr, ptr %resultName
  .left = call ptr @csec_string_concat(ptr .left.left, ptr .left.right)
  .right = getelementptr inbounds [17 x i8], ptr @.str.27782, i32 0, i32 0
   = call ptr @csec_string_concat(ptr .left, ptr .right)
  ret ptr 
}

define ptr @generateLLVMLocalI64(ptr %arg.tokens, i32 %arg.start, i32 %arg.end) {
entry:
  %tokens = alloca ptr
  store ptr %arg.tokens, ptr %tokens
  %start = alloca i32
  store i32 %arg.start, ptr %start
  %end = alloca i32
  store i32 %arg.end, ptr %end
  .left.left.left.left.left = getelementptr inbounds [3 x i8], ptr @.str.27896, i32 0, i32 0
  .left.left.left.left.right = load ptr, ptr %storageName
  .left.left.left.left = call ptr @csec_string_concat(ptr .left.left.left.left.left, ptr .left.left.left.left.right)
  .left.left.left.right = getelementptr inbounds [15 x i8], ptr @.str.27900, i32 0, i32 0
  .left.left.left = call ptr @csec_string_concat(ptr .left.left.left.left, ptr .left.left.left.right)
  .left.left.right = getelementptr inbounds [20 x i8], ptr @.str.27902, i32 0, i32 0
  .left.left = call ptr @csec_string_concat(ptr .left.left.left, ptr .left.left.right)
  .left.right = load ptr, ptr %storageName
  .left = call ptr @csec_string_concat(ptr .left.left, ptr .left.right)
  .right = getelementptr inbounds [2 x i8], ptr @.str.27906, i32 0, i32 0
   = call ptr @csec_string_concat(ptr .left, ptr .right)
  ret ptr 
}

define ptr @llvmF64Value(ptr %arg.tokens, i32 %arg.start, i32 %arg.rawEnd) {
entry:
  %tokens = alloca ptr
  store ptr %arg.tokens, ptr %tokens
  %start = alloca i32
  store i32 %arg.start, ptr %start
  %rawEnd = alloca i32
  store i32 %arg.rawEnd, ptr %rawEnd
   = getelementptr inbounds [6 x i8], ptr @.str.0, i32 0, i32 0
  ret ptr 
}

define ptr @generateLLVMLoadF64IfIdentifier(ptr %arg.tokens, i32 %arg.start, i32 %arg.rawEnd) {
entry:
  %tokens = alloca ptr
  store ptr %arg.tokens, ptr %tokens
  %start = alloca i32
  store i32 %arg.start, ptr %start
  %rawEnd = alloca i32
  store i32 %arg.rawEnd, ptr %rawEnd
   = getelementptr inbounds [1 x i8], ptr @.str.0, i32 0, i32 0
  ret ptr 
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
  .left.left = getelementptr inbounds [2 x i8], ptr @.str.28560, i32 0, i32 0
  .left.right = load ptr, ptr %resultName
  .left = call ptr @csec_string_concat(ptr .left.left, ptr .left.right)
  .right = getelementptr inbounds [43 x i8], ptr @.str.28564, i32 0, i32 0
   = call ptr @csec_string_concat(ptr .left, ptr .right)
  ret ptr 
}

define ptr @generateLLVMLocalF64(ptr %arg.tokens, i32 %arg.start, i32 %arg.end) {
entry:
  %tokens = alloca ptr
  store ptr %arg.tokens, ptr %tokens
  %start = alloca i32
  store i32 %arg.start, ptr %start
  %end = alloca i32
  store i32 %arg.end, ptr %end
  .left.left.left.left.left = getelementptr inbounds [3 x i8], ptr @.str.28678, i32 0, i32 0
  .left.left.left.left.right = load ptr, ptr %storageName
  .left.left.left.left = call ptr @csec_string_concat(ptr .left.left.left.left.left, ptr .left.left.left.left.right)
  .left.left.left.right = getelementptr inbounds [18 x i8], ptr @.str.28682, i32 0, i32 0
  .left.left.left = call ptr @csec_string_concat(ptr .left.left.left.left, ptr .left.left.left.right)
  .left.left.right = getelementptr inbounds [34 x i8], ptr @.str.28684, i32 0, i32 0
  .left.left = call ptr @csec_string_concat(ptr .left.left.left, ptr .left.left.right)
  .left.right = load ptr, ptr %storageName
  .left = call ptr @csec_string_concat(ptr .left.left, ptr .left.right)
  .right = getelementptr inbounds [2 x i8], ptr @.str.28688, i32 0, i32 0
   = call ptr @csec_string_concat(ptr .left, ptr .right)
  ret ptr 
}

define ptr @generateLLVMLocalPtr(ptr %arg.tokens, i32 %arg.start, i32 %arg.end) {
entry:
  %tokens = alloca ptr
  store ptr %arg.tokens, ptr %tokens
  %start = alloca i32
  store i32 %arg.start, ptr %start
  %end = alloca i32
  store i32 %arg.end, ptr %end
  .left.left.left.left.left = getelementptr inbounds [3 x i8], ptr @.str.29064, i32 0, i32 0
  .left.left.left.left.right = load ptr, ptr %storageName
  .left.left.left.left = call ptr @csec_string_concat(ptr .left.left.left.left.left, ptr .left.left.left.left.right)
  .left.left.left.right = getelementptr inbounds [15 x i8], ptr @.str.29068, i32 0, i32 0
  .left.left.left = call ptr @csec_string_concat(ptr .left.left.left.left, ptr .left.left.left.right)
  .left.left.right = getelementptr inbounds [23 x i8], ptr @.str.29070, i32 0, i32 0
  .left.left = call ptr @csec_string_concat(ptr .left.left.left, ptr .left.left.right)
  .left.right = load ptr, ptr %storageName
  .left = call ptr @csec_string_concat(ptr .left.left, ptr .left.right)
  .right = getelementptr inbounds [2 x i8], ptr @.str.29074, i32 0, i32 0
   = call ptr @csec_string_concat(ptr .left, ptr .right)
  ret ptr 
}

define ptr @generateLLVMLocalI8(ptr %arg.tokens, i32 %arg.start, i32 %arg.end) {
entry:
  %tokens = alloca ptr
  store ptr %arg.tokens, ptr %tokens
  %start = alloca i32
  store i32 %arg.start, ptr %start
  %end = alloca i32
  store i32 %arg.end, ptr %end
  .left.left.left.left.left = getelementptr inbounds [3 x i8], ptr @.str.29583, i32 0, i32 0
  .left.left.left.left.right = load ptr, ptr %storageName
  .left.left.left.left = call ptr @csec_string_concat(ptr .left.left.left.left.left, ptr .left.left.left.left.right)
  .left.left.left.right = getelementptr inbounds [14 x i8], ptr @.str.29587, i32 0, i32 0
  .left.left.left = call ptr @csec_string_concat(ptr .left.left.left.left, ptr .left.left.left.right)
  .left.left.right = getelementptr inbounds [19 x i8], ptr @.str.29589, i32 0, i32 0
  .left.left = call ptr @csec_string_concat(ptr .left.left.left, ptr .left.left.right)
  .left.right = load ptr, ptr %storageName
  .left = call ptr @csec_string_concat(ptr .left.left, ptr .left.right)
  .right = getelementptr inbounds [2 x i8], ptr @.str.29593, i32 0, i32 0
   = call ptr @csec_string_concat(ptr .left, ptr .right)
  ret ptr 
}

define ptr @generateLLVMAssignmentF64(ptr %arg.tokens, i32 %arg.start, i32 %arg.end) {
entry:
  %tokens = alloca ptr
  store ptr %arg.tokens, ptr %tokens
  %start = alloca i32
  store i32 %arg.start, ptr %start
  %end = alloca i32
  store i32 %arg.end, ptr %end
   = getelementptr inbounds [1 x i8], ptr @.str.0, i32 0, i32 0
  ret ptr 
}

define ptr @generateLLVMAssignmentPtr(ptr %arg.tokens, i32 %arg.start, i32 %arg.end) {
entry:
  %tokens = alloca ptr
  store ptr %arg.tokens, ptr %tokens
  %start = alloca i32
  store i32 %arg.start, ptr %start
  %end = alloca i32
  store i32 %arg.end, ptr %end
   = getelementptr inbounds [1 x i8], ptr @.str.0, i32 0, i32 0
  ret ptr 
}

define ptr @generateLLVMAssignmentI8(ptr %arg.tokens, i32 %arg.start, i32 %arg.end) {
entry:
  %tokens = alloca ptr
  store ptr %arg.tokens, ptr %tokens
  %start = alloca i32
  store i32 %arg.start, ptr %start
  %end = alloca i32
  store i32 %arg.end, ptr %end
   = getelementptr inbounds [1 x i8], ptr @.str.0, i32 0, i32 0
  ret ptr 
}

define ptr @generateLLVMAssignmentI32(ptr %arg.tokens, i32 %arg.start, i32 %arg.end) {
entry:
  %tokens = alloca ptr
  store ptr %arg.tokens, ptr %tokens
  %start = alloca i32
  store i32 %arg.start, ptr %start
  %end = alloca i32
  store i32 %arg.end, ptr %end
  .left.left.left.left.left.left.left.left.left.left.left.left.left.left.left.right = getelementptr inbounds [6 x i8], ptr @.str.30886, i32 0, i32 0
  .left.left.left.left.left.left.left.left.left.left.left.left.left.left.left = call ptr @csec_string_concat(ptr .left.left.left.left.left.left.left.left.left.left.left.left.left.left.left.left, ptr .left.left.left.left.left.left.left.left.left.left.left.left.left.left.left.right)
  .left.left.left.left.left.left.left.left.left.left.left.left.left.left.right = load ptr, ptr %name
  .left.left.left.left.left.left.left.left.left.left.left.left.left.left = call ptr @csec_string_concat(ptr .left.left.left.left.left.left.left.left.left.left.left.left.left.left.left, ptr .left.left.left.left.left.left.left.left.left.left.left.left.left.left.right)
  .left.left.left.left.left.left.left.left.left.left.left.left.left.right = getelementptr inbounds [5 x i8], ptr @.str.30890, i32 0, i32 0
  .left.left.left.left.left.left.left.left.left.left.left.left.left = call ptr @csec_string_concat(ptr .left.left.left.left.left.left.left.left.left.left.left.left.left.left, ptr .left.left.left.left.left.left.left.left.left.left.left.left.left.right)
  .left.left.left.left.left.left.left.left.left.left.left.left.right = load ptr, ptr %start
  .left.left.left.left.left.left.left.left.left.left.left.left = call ptr @csec_string_concat(ptr .left.left.left.left.left.left.left.left.left.left.left.left.left, ptr .left.left.left.left.left.left.left.left.left.left.left.left.right)
  .left.left.left.left.left.left.left.left.left.left.left.right = getelementptr inbounds [3 x i8], ptr @.str.30894, i32 0, i32 0
  .left.left.left.left.left.left.left.left.left.left.left = call ptr @csec_string_concat(ptr .left.left.left.left.left.left.left.left.left.left.left.left, ptr .left.left.left.left.left.left.left.left.left.left.left.right)
  .left.left.left.left.left.left.left.left.left.left.right = load ptr, ptr %name
  .left.left.left.left.left.left.left.left.left.left = call ptr @csec_string_concat(ptr .left.left.left.left.left.left.left.left.left.left.left, ptr .left.left.left.left.left.left.left.left.left.left.right)
  .left.left.left.left.left.left.left.left.left.right = getelementptr inbounds [5 x i8], ptr @.str.30898, i32 0, i32 0
  .left.left.left.left.left.left.left.left.left = call ptr @csec_string_concat(ptr .left.left.left.left.left.left.left.left.left.left, ptr .left.left.left.left.left.left.left.left.left.right)
  .left.left.left.left.left.left.left.left.right = load ptr, ptr %start
  .left.left.left.left.left.left.left.left = call ptr @csec_string_concat(ptr .left.left.left.left.left.left.left.left.left, ptr .left.left.left.left.left.left.left.left.right)
  .left.left.left.left.left.left.left.right = getelementptr inbounds [2 x i8], ptr @.str.30902, i32 0, i32 0
  .left.left.left.left.left.left.left = call ptr @csec_string_concat(ptr .left.left.left.left.left.left.left.left, ptr .left.left.left.left.left.left.left.right)
  .left.left.left.left.left.left.right = getelementptr inbounds [13 x i8], ptr @.str.30904, i32 0, i32 0
  .left.left.left.left.left.left = call ptr @csec_string_concat(ptr .left.left.left.left.left.left.left, ptr .left.left.left.left.left.left.right)
  .left.left.left.left.left.right = load ptr, ptr %name
  .left.left.left.left.left = call ptr @csec_string_concat(ptr .left.left.left.left.left.left, ptr .left.left.left.left.left.right)
  .left.left.left.left.right = getelementptr inbounds [6 x i8], ptr @.str.30908, i32 0, i32 0
  .left.left.left.left = call ptr @csec_string_concat(ptr .left.left.left.left.left, ptr .left.left.left.left.right)
  .left.left.left.right = load ptr, ptr %start
  .left.left.left = call ptr @csec_string_concat(ptr .left.left.left.left, ptr .left.left.left.right)
  .left.left.right = getelementptr inbounds [7 x i8], ptr @.str.30912, i32 0, i32 0
  .left.left = call ptr @csec_string_concat(ptr .left.left.left, ptr .left.left.right)
  .left.right = load ptr, ptr %storageName
  .left = call ptr @csec_string_concat(ptr .left.left, ptr .left.right)
  .right = getelementptr inbounds [2 x i8], ptr @.str.30916, i32 0, i32 0
   = call ptr @csec_string_concat(ptr .left, ptr .right)
  ret ptr 
}

define ptr @generateLLVMAssignmentI64(ptr %arg.tokens, i32 %arg.start, i32 %arg.end) {
entry:
  %tokens = alloca ptr
  store ptr %arg.tokens, ptr %tokens
  %start = alloca i32
  store i32 %arg.start, ptr %start
  %end = alloca i32
  store i32 %arg.end, ptr %end
  .left.left.left.left.left.left.left.left.left.left.left.left.left.left.left.right = getelementptr inbounds [6 x i8], ptr @.str.31146, i32 0, i32 0
  .left.left.left.left.left.left.left.left.left.left.left.left.left.left.left = call ptr @csec_string_concat(ptr .left.left.left.left.left.left.left.left.left.left.left.left.left.left.left.left, ptr .left.left.left.left.left.left.left.left.left.left.left.left.left.left.left.right)
  .left.left.left.left.left.left.left.left.left.left.left.left.left.left.right = load ptr, ptr %name
  .left.left.left.left.left.left.left.left.left.left.left.left.left.left = call ptr @csec_string_concat(ptr .left.left.left.left.left.left.left.left.left.left.left.left.left.left.left, ptr .left.left.left.left.left.left.left.left.left.left.left.left.left.left.right)
  .left.left.left.left.left.left.left.left.left.left.left.left.left.right = getelementptr inbounds [6 x i8], ptr @.str.31150, i32 0, i32 0
  .left.left.left.left.left.left.left.left.left.left.left.left.left = call ptr @csec_string_concat(ptr .left.left.left.left.left.left.left.left.left.left.left.left.left.left, ptr .left.left.left.left.left.left.left.left.left.left.left.left.left.right)
  .left.left.left.left.left.left.left.left.left.left.left.left.right = load ptr, ptr %start
  .left.left.left.left.left.left.left.left.left.left.left.left = call ptr @csec_string_concat(ptr .left.left.left.left.left.left.left.left.left.left.left.left.left, ptr .left.left.left.left.left.left.left.left.left.left.left.left.right)
  .left.left.left.left.left.left.left.left.left.left.left.right = getelementptr inbounds [3 x i8], ptr @.str.31154, i32 0, i32 0
  .left.left.left.left.left.left.left.left.left.left.left = call ptr @csec_string_concat(ptr .left.left.left.left.left.left.left.left.left.left.left.left, ptr .left.left.left.left.left.left.left.left.left.left.left.right)
  .left.left.left.left.left.left.left.left.left.left.right = load ptr, ptr %name
  .left.left.left.left.left.left.left.left.left.left = call ptr @csec_string_concat(ptr .left.left.left.left.left.left.left.left.left.left.left, ptr .left.left.left.left.left.left.left.left.left.left.right)
  .left.left.left.left.left.left.left.left.left.right = getelementptr inbounds [6 x i8], ptr @.str.31158, i32 0, i32 0
  .left.left.left.left.left.left.left.left.left = call ptr @csec_string_concat(ptr .left.left.left.left.left.left.left.left.left.left, ptr .left.left.left.left.left.left.left.left.left.right)
  .left.left.left.left.left.left.left.left.right = load ptr, ptr %start
  .left.left.left.left.left.left.left.left = call ptr @csec_string_concat(ptr .left.left.left.left.left.left.left.left.left, ptr .left.left.left.left.left.left.left.left.right)
  .left.left.left.left.left.left.left.right = getelementptr inbounds [2 x i8], ptr @.str.31162, i32 0, i32 0
  .left.left.left.left.left.left.left = call ptr @csec_string_concat(ptr .left.left.left.left.left.left.left.left, ptr .left.left.left.left.left.left.left.right)
  .left.left.left.left.left.left.right = getelementptr inbounds [13 x i8], ptr @.str.31164, i32 0, i32 0
  .left.left.left.left.left.left = call ptr @csec_string_concat(ptr .left.left.left.left.left.left.left, ptr .left.left.left.left.left.left.right)
  .left.left.left.left.left.right = load ptr, ptr %name
  .left.left.left.left.left = call ptr @csec_string_concat(ptr .left.left.left.left.left.left, ptr .left.left.left.left.left.right)
  .left.left.left.left.right = getelementptr inbounds [7 x i8], ptr @.str.31168, i32 0, i32 0
  .left.left.left.left = call ptr @csec_string_concat(ptr .left.left.left.left.left, ptr .left.left.left.left.right)
  .left.left.left.right = load ptr, ptr %start
  .left.left.left = call ptr @csec_string_concat(ptr .left.left.left.left, ptr .left.left.left.right)
  .left.left.right = getelementptr inbounds [7 x i8], ptr @.str.31172, i32 0, i32 0
  .left.left = call ptr @csec_string_concat(ptr .left.left.left, ptr .left.left.right)
  .left.right = load ptr, ptr %storageName
  .left = call ptr @csec_string_concat(ptr .left.left, ptr .left.right)
  .right = getelementptr inbounds [2 x i8], ptr @.str.31176, i32 0, i32 0
   = call ptr @csec_string_concat(ptr .left, ptr .right)
  ret ptr 
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
  .left.left = getelementptr inbounds [2 x i8], ptr @.str.31802, i32 0, i32 0
  .left.right = load ptr, ptr %resultName
  .left = call ptr @csec_string_concat(ptr .left.left, ptr .left.right)
  .right = getelementptr inbounds [21 x i8], ptr @.str.31806, i32 0, i32 0
   = call ptr @csec_string_concat(ptr .left, ptr .right)
  ret ptr 
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
  .left.left.left.left.left = getelementptr inbounds [3 x i8], ptr @.str.32390, i32 0, i32 0
  .left.left.left.left.right = load ptr, ptr %storageName
  .left.left.left.left = call ptr @csec_string_concat(ptr .left.left.left.left.left, ptr .left.left.left.left.right)
  .left.left.left.right = getelementptr inbounds [14 x i8], ptr @.str.32394, i32 0, i32 0
  .left.left.left = call ptr @csec_string_concat(ptr .left.left.left.left, ptr .left.left.left.right)
  .left.left.right = getelementptr inbounds [23 x i8], ptr @.str.32396, i32 0, i32 0
  .left.left = call ptr @csec_string_concat(ptr .left.left.left, ptr .left.left.right)
  .left.right = load ptr, ptr %storageName
  .left = call ptr @csec_string_concat(ptr .left.left, ptr .left.right)
  .right = getelementptr inbounds [2 x i8], ptr @.str.32400, i32 0, i32 0
   = call ptr @csec_string_concat(ptr .left, ptr .right)
  ret ptr 
}

define ptr @generateLLVMAssignmentI1(ptr %arg.tokens, i32 %arg.start, i32 %arg.end) {
entry:
  %tokens = alloca ptr
  store ptr %arg.tokens, ptr %tokens
  %start = alloca i32
  store i32 %arg.start, ptr %start
  %end = alloca i32
  store i32 %arg.end, ptr %end
   = getelementptr inbounds [1 x i8], ptr @.str.0, i32 0, i32 0
  ret ptr 
}

define i1 @llvmBlockEndsWithTopLevelReturn(ptr %arg.tokens, i32 %arg.bodyStart, i32 %arg.bodyEnd) {
entry:
  %tokens = alloca ptr
  store ptr %arg.tokens, ptr %tokens
  %bodyStart = alloca i32
  store i32 %arg.bodyStart, ptr %bodyStart
  %bodyEnd = alloca i32
  store i32 %arg.bodyEnd, ptr %bodyEnd
  %ret.32662 = load i1, ptr %result
  ret i1 %ret.32662
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
  .left.left = getelementptr inbounds [2 x i8], ptr @.str.34115, i32 0, i32 0
  .left.right = load ptr, ptr %resultName
  .left = call ptr @csec_string_concat(ptr .left.left, ptr .left.right)
  .right = getelementptr inbounds [26 x i8], ptr @.str.34119, i32 0, i32 0
   = call ptr @csec_string_concat(ptr .left, ptr .right)
  ret ptr 
}

define i1 @llvmExpressionLooksPtr(ptr %arg.tokens, i32 %arg.start, i32 %arg.rawEnd) {
entry:
  %tokens = alloca ptr
  store ptr %arg.tokens, ptr %tokens
  %start = alloca i32
  store i32 %arg.start, ptr %start
  %rawEnd = alloca i32
  store i32 %arg.rawEnd, ptr %rawEnd
  %ret.34463 = icmp eq i1 false, true
  ret i1 %ret.34463
}

define ptr @generateLLVMFlatBodyI32(ptr %arg.tokens, i32 %arg.bodyStart, i32 %arg.bodyEnd) {
entry:
  %tokens = alloca ptr
  store ptr %arg.tokens, ptr %tokens
  %bodyStart = alloca i32
  store i32 %arg.bodyStart, ptr %bodyStart
  %bodyEnd = alloca i32
  store i32 %arg.bodyEnd, ptr %bodyEnd
   = load ptr, ptr %output
  ret ptr 
}

define ptr @generateLLVMIfI32(ptr %arg.tokens, i32 %arg.start, i32 %arg.end) {
entry:
  %tokens = alloca ptr
  store ptr %arg.tokens, ptr %tokens
  %start = alloca i32
  store i32 %arg.start, ptr %start
  %end = alloca i32
  store i32 %arg.end, ptr %end
  .left.left.left.left.left.left.left.left.left.left.left.left.left.left.left.left.left.left.left.right = getelementptr inbounds [14 x i8], ptr @.str.37031, i32 0, i32 0
  .left.left.left.left.left.left.left.left.left.left.left.left.left.left.left.left.left.left.left = call ptr @csec_string_concat(ptr .left.left.left.left.left.left.left.left.left.left.left.left.left.left.left.left.left.left.left.left, ptr .left.left.left.left.left.left.left.left.left.left.left.left.left.left.left.left.left.left.left.right)
  .left.left.left.left.left.left.left.left.left.left.left.left.left.left.left.left.left.left.right = load ptr, ptr %labelSeed
  .left.left.left.left.left.left.left.left.left.left.left.left.left.left.left.left.left.left = call ptr @csec_string_concat(ptr .left.left.left.left.left.left.left.left.left.left.left.left.left.left.left.left.left.left.left, ptr .left.left.left.left.left.left.left.left.left.left.left.left.left.left.left.left.left.left.right)
  .left.left.left.left.left.left.left.left.left.left.left.left.left.left.left.left.left.right = getelementptr inbounds [17 x i8], ptr @.str.37035, i32 0, i32 0
  .left.left.left.left.left.left.left.left.left.left.left.left.left.left.left.left.left = call ptr @csec_string_concat(ptr .left.left.left.left.left.left.left.left.left.left.left.left.left.left.left.left.left.left, ptr .left.left.left.left.left.left.left.left.left.left.left.left.left.left.left.left.left.right)
  .left.left.left.left.left.left.left.left.left.left.left.left.left.left.left.left.right = load ptr, ptr %labelSeed
  .left.left.left.left.left.left.left.left.left.left.left.left.left.left.left.left = call ptr @csec_string_concat(ptr .left.left.left.left.left.left.left.left.left.left.left.left.left.left.left.left.left, ptr .left.left.left.left.left.left.left.left.left.left.left.left.left.left.left.left.right)
  .left.left.left.left.left.left.left.left.left.left.left.left.left.left.left.right = getelementptr inbounds [17 x i8], ptr @.str.37039, i32 0, i32 0
  .left.left.left.left.left.left.left.left.left.left.left.left.left.left.left = call ptr @csec_string_concat(ptr .left.left.left.left.left.left.left.left.left.left.left.left.left.left.left.left, ptr .left.left.left.left.left.left.left.left.left.left.left.left.left.left.left.right)
  .left.left.left.left.left.left.left.left.left.left.left.left.left.left.right = load ptr, ptr %labelSeed
  .left.left.left.left.left.left.left.left.left.left.left.left.left.left = call ptr @csec_string_concat(ptr .left.left.left.left.left.left.left.left.left.left.left.left.left.left.left, ptr .left.left.left.left.left.left.left.left.left.left.left.left.left.left.right)
  .left.left.left.left.left.left.left.left.left.left.left.left.left.right = getelementptr inbounds [2 x i8], ptr @.str.37043, i32 0, i32 0
  .left.left.left.left.left.left.left.left.left.left.left.left.left = call ptr @csec_string_concat(ptr .left.left.left.left.left.left.left.left.left.left.left.left.left.left, ptr .left.left.left.left.left.left.left.left.left.left.left.left.left.right)
  .left.left.left.left.left.left.left.left.left.left.left.left.right = getelementptr inbounds [8 x i8], ptr @.str.37045, i32 0, i32 0
  .left.left.left.left.left.left.left.left.left.left.left.left = call ptr @csec_string_concat(ptr .left.left.left.left.left.left.left.left.left.left.left.left.left, ptr .left.left.left.left.left.left.left.left.left.left.left.left.right)
  .left.left.left.left.left.left.left.left.left.left.left.right = load ptr, ptr %labelSeed
  .left.left.left.left.left.left.left.left.left.left.left = call ptr @csec_string_concat(ptr .left.left.left.left.left.left.left.left.left.left.left.left, ptr .left.left.left.left.left.left.left.left.left.left.left.right)
  .left.left.left.left.left.left.left.left.left.left.right = getelementptr inbounds [3 x i8], ptr @.str.37049, i32 0, i32 0
  .left.left.left.left.left.left.left.left.left.left = call ptr @csec_string_concat(ptr .left.left.left.left.left.left.left.left.left.left.left, ptr .left.left.left.left.left.left.left.left.left.left.right)
  .left.left.left.left.left.left.left.left.left.right = load ptr, ptr %thenBody
  .left.left.left.left.left.left.left.left.left = call ptr @csec_string_concat(ptr .left.left.left.left.left.left.left.left.left.left, ptr .left.left.left.left.left.left.left.left.left.right)
  .left.left.left.left.left.left.left.left.right = load ptr, ptr %thenBranch
  .left.left.left.left.left.left.left.left = call ptr @csec_string_concat(ptr .left.left.left.left.left.left.left.left.left, ptr .left.left.left.left.left.left.left.left.right)
  .left.left.left.left.left.left.left.right = getelementptr inbounds [8 x i8], ptr @.str.37055, i32 0, i32 0
  .left.left.left.left.left.left.left = call ptr @csec_string_concat(ptr .left.left.left.left.left.left.left.left, ptr .left.left.left.left.left.left.left.right)
  .left.left.left.left.left.left.right = load ptr, ptr %labelSeed
  .left.left.left.left.left.left = call ptr @csec_string_concat(ptr .left.left.left.left.left.left.left, ptr .left.left.left.left.left.left.right)
  .left.left.left.left.left.right = getelementptr inbounds [3 x i8], ptr @.str.37059, i32 0, i32 0
  .left.left.left.left.left = call ptr @csec_string_concat(ptr .left.left.left.left.left.left, ptr .left.left.left.left.left.right)
  .left.left.left.left.right = load ptr, ptr %elseBody
  .left.left.left.left = call ptr @csec_string_concat(ptr .left.left.left.left.left, ptr .left.left.left.left.right)
  .left.left.left.right = load ptr, ptr %elseBranch
  .left.left.left = call ptr @csec_string_concat(ptr .left.left.left.left, ptr .left.left.left.right)
  .left.left.right = getelementptr inbounds [7 x i8], ptr @.str.37065, i32 0, i32 0
  .left.left = call ptr @csec_string_concat(ptr .left.left.left, ptr .left.left.right)
  .left.right = load ptr, ptr %labelSeed
  .left = call ptr @csec_string_concat(ptr .left.left, ptr .left.right)
  .right = getelementptr inbounds [3 x i8], ptr @.str.37069, i32 0, i32 0
   = call ptr @csec_string_concat(ptr .left, ptr .right)
  ret ptr 
}

define ptr @generateLLVMWhileI32(ptr %arg.tokens, i32 %arg.start, i32 %arg.end) {
entry:
  %tokens = alloca ptr
  store ptr %arg.tokens, ptr %tokens
  %start = alloca i32
  store i32 %arg.start, ptr %start
  %end = alloca i32
  store i32 %arg.end, ptr %end
  .left.left.left.left.left.left.left.left.left.left.left.left.left.left.right = getelementptr inbounds [19 x i8], ptr @.str.37256, i32 0, i32 0
  .left.left.left.left.left.left.left.left.left.left.left.left.left.left = call ptr @csec_string_concat(ptr .left.left.left.left.left.left.left.left.left.left.left.left.left.left.left, ptr .left.left.left.left.left.left.left.left.left.left.left.left.left.left.right)
  .left.left.left.left.left.left.left.left.left.left.left.left.left.right = load ptr, ptr %labelSeed
  .left.left.left.left.left.left.left.left.left.left.left.left.left = call ptr @csec_string_concat(ptr .left.left.left.left.left.left.left.left.left.left.left.left.left.left, ptr .left.left.left.left.left.left.left.left.left.left.left.left.left.right)
  .left.left.left.left.left.left.left.left.left.left.left.left.right = getelementptr inbounds [20 x i8], ptr @.str.37260, i32 0, i32 0
  .left.left.left.left.left.left.left.left.left.left.left.left = call ptr @csec_string_concat(ptr .left.left.left.left.left.left.left.left.left.left.left.left.left, ptr .left.left.left.left.left.left.left.left.left.left.left.left.right)
  .left.left.left.left.left.left.left.left.left.left.left.right = load ptr, ptr %labelSeed
  .left.left.left.left.left.left.left.left.left.left.left = call ptr @csec_string_concat(ptr .left.left.left.left.left.left.left.left.left.left.left.left, ptr .left.left.left.left.left.left.left.left.left.left.left.right)
  .left.left.left.left.left.left.left.left.left.left.right = getelementptr inbounds [19 x i8], ptr @.str.37264, i32 0, i32 0
  .left.left.left.left.left.left.left.left.left.left = call ptr @csec_string_concat(ptr .left.left.left.left.left.left.left.left.left.left.left, ptr .left.left.left.left.left.left.left.left.left.left.right)
  .left.left.left.left.left.left.left.left.left.right = load ptr, ptr %labelSeed
  .left.left.left.left.left.left.left.left.left = call ptr @csec_string_concat(ptr .left.left.left.left.left.left.left.left.left.left, ptr .left.left.left.left.left.left.left.left.left.right)
  .left.left.left.left.left.left.left.left.right = getelementptr inbounds [2 x i8], ptr @.str.37268, i32 0, i32 0
  .left.left.left.left.left.left.left.left = call ptr @csec_string_concat(ptr .left.left.left.left.left.left.left.left.left, ptr .left.left.left.left.left.left.left.left.right)
  .left.left.left.left.left.left.left.right = getelementptr inbounds [11 x i8], ptr @.str.37270, i32 0, i32 0
  .left.left.left.left.left.left.left = call ptr @csec_string_concat(ptr .left.left.left.left.left.left.left.left, ptr .left.left.left.left.left.left.left.right)
  .left.left.left.left.left.left.right = load ptr, ptr %labelSeed
  .left.left.left.left.left.left = call ptr @csec_string_concat(ptr .left.left.left.left.left.left.left, ptr .left.left.left.left.left.left.right)
  .left.left.left.left.left.right = getelementptr inbounds [3 x i8], ptr @.str.37274, i32 0, i32 0
  .left.left.left.left.left = call ptr @csec_string_concat(ptr .left.left.left.left.left.left, ptr .left.left.left.left.left.right)
  .left.left.left.left.right = load ptr, ptr %body
  .left.left.left.left = call ptr @csec_string_concat(ptr .left.left.left.left.left, ptr .left.left.left.left.right)
  .left.left.left.right = load ptr, ptr %continueBranch
  .left.left.left = call ptr @csec_string_concat(ptr .left.left.left.left, ptr .left.left.left.right)
  .left.left.right = getelementptr inbounds [10 x i8], ptr @.str.37280, i32 0, i32 0
  .left.left = call ptr @csec_string_concat(ptr .left.left.left, ptr .left.left.right)
  .left.right = load ptr, ptr %labelSeed
  .left = call ptr @csec_string_concat(ptr .left.left, ptr .left.right)
  .right = getelementptr inbounds [3 x i8], ptr @.str.37284, i32 0, i32 0
   = call ptr @csec_string_concat(ptr .left, ptr .right)
  ret ptr 
}

define ptr @generateLLVMForI32(ptr %arg.tokens, i32 %arg.start, i32 %arg.end) {
entry:
  %tokens = alloca ptr
  store ptr %arg.tokens, ptr %tokens
  %start = alloca i32
  store i32 %arg.start, ptr %start
  %end = alloca i32
  store i32 %arg.end, ptr %end
  .left.left.left.left.left.left.left.left.left.left.left.left.left.left.left.left.left.left.left.left.left.left.left.right = getelementptr inbounds [11 x i8], ptr @.str.37693, i32 0, i32 0
  .left.left.left.left.left.left.left.left.left.left.left.left.left.left.left.left.left.left.left.left.left.left.left = call ptr @csec_string_concat(ptr .left.left.left.left.left.left.left.left.left.left.left.left.left.left.left.left.left.left.left.left.left.left.left.left, ptr .left.left.left.left.left.left.left.left.left.left.left.left.left.left.left.left.left.left.left.left.left.left.left.right)
  .left.left.left.left.left.left.left.left.left.left.left.left.left.left.left.left.left.left.left.left.left.left.right = load ptr, ptr %labelSeed
  .left.left.left.left.left.left.left.left.left.left.left.left.left.left.left.left.left.left.left.left.left.left = call ptr @csec_string_concat(ptr .left.left.left.left.left.left.left.left.left.left.left.left.left.left.left.left.left.left.left.left.left.left.left, ptr .left.left.left.left.left.left.left.left.left.left.left.left.left.left.left.left.left.left.left.left.left.left.right)
  .left.left.left.left.left.left.left.left.left.left.left.left.left.left.left.left.left.left.left.left.left.right = getelementptr inbounds [8 x i8], ptr @.str.37697, i32 0, i32 0
  .left.left.left.left.left.left.left.left.left.left.left.left.left.left.left.left.left.left.left.left.left = call ptr @csec_string_concat(ptr .left.left.left.left.left.left.left.left.left.left.left.left.left.left.left.left.left.left.left.left.left.left, ptr .left.left.left.left.left.left.left.left.left.left.left.left.left.left.left.left.left.left.left.left.left.right)
  .left.left.left.left.left.left.left.left.left.left.left.left.left.left.left.left.left.left.left.left.right = load ptr, ptr %compareOp
  .left.left.left.left.left.left.left.left.left.left.left.left.left.left.left.left.left.left.left.left = call ptr @csec_string_concat(ptr .left.left.left.left.left.left.left.left.left.left.left.left.left.left.left.left.left.left.left.left.left, ptr .left.left.left.left.left.left.left.left.left.left.left.left.left.left.left.left.left.left.left.left.right)
  .left.left.left.left.left.left.left.left.left.left.left.left.left.left.left.left.left.left.left.right = getelementptr inbounds [6 x i8], ptr @.str.37701, i32 0, i32 0
  .left.left.left.left.left.left.left.left.left.left.left.left.left.left.left.left.left.left.left = call ptr @csec_string_concat(ptr .left.left.left.left.left.left.left.left.left.left.left.left.left.left.left.left.left.left.left.left, ptr .left.left.left.left.left.left.left.left.left.left.left.left.left.left.left.left.left.left.left.right)
  .left.left.left.left.left.left.left.left.left.left.left.left.left.left.left.left.left.left.right = load ptr, ptr %iteratorName
  .left.left.left.left.left.left.left.left.left.left.left.left.left.left.left.left.left.left = call ptr @csec_string_concat(ptr .left.left.left.left.left.left.left.left.left.left.left.left.left.left.left.left.left.left.left, ptr .left.left.left.left.left.left.left.left.left.left.left.left.left.left.left.left.left.left.right)
  .left.left.left.left.left.left.left.left.left.left.left.left.left.left.left.left.left.right = getelementptr inbounds [7 x i8], ptr @.str.37705, i32 0, i32 0
  .left.left.left.left.left.left.left.left.left.left.left.left.left.left.left.left.left = call ptr @csec_string_concat(ptr .left.left.left.left.left.left.left.left.left.left.left.left.left.left.left.left.left.left, ptr .left.left.left.left.left.left.left.left.left.left.left.left.left.left.left.left.left.right)
  .left.left.left.left.left.left.left.left.left.left.left.left.left.left.left.left.right = load ptr, ptr %iteratorName
  .left.left.left.left.left.left.left.left.left.left.left.left.left.left.left.left = call ptr @csec_string_concat(ptr .left.left.left.left.left.left.left.left.left.left.left.left.left.left.left.left.left, ptr .left.left.left.left.left.left.left.left.left.left.left.left.left.left.left.left.right)
  .left.left.left.left.left.left.left.left.left.left.left.left.left.left.left.right = getelementptr inbounds [6 x i8], ptr @.str.37709, i32 0, i32 0
  .left.left.left.left.left.left.left.left.left.left.left.left.left.left.left = call ptr @csec_string_concat(ptr .left.left.left.left.left.left.left.left.left.left.left.left.left.left.left.left, ptr .left.left.left.left.left.left.left.left.left.left.left.left.left.left.left.right)
  .left.left.left.left.left.left.left.left.left.left.left.left.left.left.right = getelementptr inbounds [17 x i8], ptr @.str.37711, i32 0, i32 0
  .left.left.left.left.left.left.left.left.left.left.left.left.left.left = call ptr @csec_string_concat(ptr .left.left.left.left.left.left.left.left.left.left.left.left.left.left.left, ptr .left.left.left.left.left.left.left.left.left.left.left.left.left.left.right)
  .left.left.left.left.left.left.left.left.left.left.left.left.left.right = load ptr, ptr %labelSeed
  .left.left.left.left.left.left.left.left.left.left.left.left.left = call ptr @csec_string_concat(ptr .left.left.left.left.left.left.left.left.left.left.left.left.left.left, ptr .left.left.left.left.left.left.left.left.left.left.left.left.left.right)
  .left.left.left.left.left.left.left.left.left.left.left.left.right = getelementptr inbounds [18 x i8], ptr @.str.37715, i32 0, i32 0
  .left.left.left.left.left.left.left.left.left.left.left.left = call ptr @csec_string_concat(ptr .left.left.left.left.left.left.left.left.left.left.left.left.left, ptr .left.left.left.left.left.left.left.left.left.left.left.left.right)
  .left.left.left.left.left.left.left.left.left.left.left.right = load ptr, ptr %labelSeed
  .left.left.left.left.left.left.left.left.left.left.left = call ptr @csec_string_concat(ptr .left.left.left.left.left.left.left.left.left.left.left.left, ptr .left.left.left.left.left.left.left.left.left.left.left.right)
  .left.left.left.left.left.left.left.left.left.left.right = getelementptr inbounds [17 x i8], ptr @.str.37719, i32 0, i32 0
  .left.left.left.left.left.left.left.left.left.left = call ptr @csec_string_concat(ptr .left.left.left.left.left.left.left.left.left.left.left, ptr .left.left.left.left.left.left.left.left.left.left.right)
  .left.left.left.left.left.left.left.left.left.right = load ptr, ptr %labelSeed
  .left.left.left.left.left.left.left.left.left = call ptr @csec_string_concat(ptr .left.left.left.left.left.left.left.left.left.left, ptr .left.left.left.left.left.left.left.left.left.right)
  .left.left.left.left.left.left.left.left.right = getelementptr inbounds [2 x i8], ptr @.str.37723, i32 0, i32 0
  .left.left.left.left.left.left.left.left = call ptr @csec_string_concat(ptr .left.left.left.left.left.left.left.left.left, ptr .left.left.left.left.left.left.left.left.right)
  .left.left.left.left.left.left.left.right = getelementptr inbounds [9 x i8], ptr @.str.37725, i32 0, i32 0
  .left.left.left.left.left.left.left = call ptr @csec_string_concat(ptr .left.left.left.left.left.left.left.left, ptr .left.left.left.left.left.left.left.right)
  .left.left.left.left.left.left.right = load ptr, ptr %labelSeed
  .left.left.left.left.left.left = call ptr @csec_string_concat(ptr .left.left.left.left.left.left.left, ptr .left.left.left.left.left.left.right)
  .left.left.left.left.left.right = getelementptr inbounds [3 x i8], ptr @.str.37729, i32 0, i32 0
  .left.left.left.left.left = call ptr @csec_string_concat(ptr .left.left.left.left.left.left, ptr .left.left.left.left.left.right)
  .left.left.left.left.right = load ptr, ptr %body
  .left.left.left.left = call ptr @csec_string_concat(ptr .left.left.left.left.left, ptr .left.left.left.left.right)
  .left.left.left.right = load ptr, ptr %stepBranch
  .left.left.left = call ptr @csec_string_concat(ptr .left.left.left.left, ptr .left.left.left.right)
  .left.left.right = getelementptr inbounds [8 x i8], ptr @.str.37735, i32 0, i32 0
  .left.left = call ptr @csec_string_concat(ptr .left.left.left, ptr .left.left.right)
  .left.right = load ptr, ptr %labelSeed
  .left = call ptr @csec_string_concat(ptr .left.left, ptr .left.right)
  .right = getelementptr inbounds [3 x i8], ptr @.str.37739, i32 0, i32 0
   = call ptr @csec_string_concat(ptr .left, ptr .right)
  ret ptr 
}

define ptr @generateLLVMReturnI32(ptr %arg.tokens, i32 %arg.bodyStart, i32 %arg.bodyEnd) {
entry:
  %tokens = alloca ptr
  store ptr %arg.tokens, ptr %tokens
  %bodyStart = alloca i32
  store i32 %arg.bodyStart, ptr %bodyStart
  %bodyEnd = alloca i32
  store i32 %arg.bodyEnd, ptr %bodyEnd
   = getelementptr inbounds [13 x i8], ptr @.str.0, i32 0, i32 0
  ret ptr 
}

define ptr @generateLLVMDottedStatementCall(ptr %arg.tokens, i32 %arg.cursor, i32 %arg.next) {
entry:
  %tokens = alloca ptr
  store ptr %arg.tokens, ptr %tokens
  %cursor = alloca i32
  store i32 %arg.cursor, ptr %cursor
  %next = alloca i32
  store i32 %arg.next, ptr %next
   = getelementptr inbounds [1 x i8], ptr @.str.0, i32 0, i32 0
  ret ptr 
}

define ptr @generateLLVMMainBodyFromRange(ptr %arg.tokens, i32 %arg.bodyStart, i32 %arg.bodyEnd) {
entry:
  %tokens = alloca ptr
  store ptr %arg.tokens, ptr %tokens
  %bodyStart = alloca i32
  store i32 %arg.bodyStart, ptr %bodyStart
  %bodyEnd = alloca i32
  store i32 %arg.bodyEnd, ptr %bodyEnd
  .left = load ptr, ptr %output
  .right = getelementptr inbounds [13 x i8], ptr @.str.39132, i32 0, i32 0
   = call ptr @csec_string_concat(ptr .left, ptr .right)
  ret ptr 
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
   = load ptr, ptr %output
  ret ptr 
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
   = load ptr, ptr %output
  ret ptr 
}

define ptr @generateLLVMBooleanBodyFromRange(ptr %arg.tokens, i32 %arg.bodyStart, i32 %arg.bodyEnd) {
entry:
  %tokens = alloca ptr
  store ptr %arg.tokens, ptr %tokens
  %bodyStart = alloca i32
  store i32 %arg.bodyStart, ptr %bodyStart
  %bodyEnd = alloca i32
  store i32 %arg.bodyEnd, ptr %bodyEnd
  .left = load ptr, ptr %output
  .right = getelementptr inbounds [16 x i8], ptr @.str.40356, i32 0, i32 0
   = call ptr @csec_string_concat(ptr .left, ptr .right)
  ret ptr 
}

define ptr @generateLLVMCharBodyFromRange(ptr %arg.tokens, i32 %arg.bodyStart, i32 %arg.bodyEnd) {
entry:
  %tokens = alloca ptr
  store ptr %arg.tokens, ptr %tokens
  %bodyStart = alloca i32
  store i32 %arg.bodyStart, ptr %bodyStart
  %bodyEnd = alloca i32
  store i32 %arg.bodyEnd, ptr %bodyEnd
  .left = load ptr, ptr %output
  .right = getelementptr inbounds [12 x i8], ptr @.str.40714, i32 0, i32 0
   = call ptr @csec_string_concat(ptr .left, ptr .right)
  ret ptr 
}

define ptr @generateLLVMDoubleBodyFromRange(ptr %arg.tokens, i32 %arg.bodyStart, i32 %arg.bodyEnd) {
entry:
  %tokens = alloca ptr
  store ptr %arg.tokens, ptr %tokens
  %bodyStart = alloca i32
  store i32 %arg.bodyStart, ptr %bodyStart
  %bodyEnd = alloca i32
  store i32 %arg.bodyEnd, ptr %bodyEnd
  .left = load ptr, ptr %output
  .right = getelementptr inbounds [27 x i8], ptr @.str.40970, i32 0, i32 0
   = call ptr @csec_string_concat(ptr .left, ptr .right)
  ret ptr 
}

define ptr @generateLLVMLongBodyFromRange(ptr %arg.tokens, i32 %arg.bodyStart, i32 %arg.bodyEnd) {
entry:
  %tokens = alloca ptr
  store ptr %arg.tokens, ptr %tokens
  %bodyStart = alloca i32
  store i32 %arg.bodyStart, ptr %bodyStart
  %bodyEnd = alloca i32
  store i32 %arg.bodyEnd, ptr %bodyEnd
  .left = load ptr, ptr %output
  .right = getelementptr inbounds [13 x i8], ptr @.str.41211, i32 0, i32 0
   = call ptr @csec_string_concat(ptr .left, ptr .right)
  ret ptr 
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
  .left = load ptr, ptr %output
  .right = getelementptr inbounds [16 x i8], ptr @.str.42093, i32 0, i32 0
   = call ptr @csec_string_concat(ptr .left, ptr .right)
  ret ptr 
}

define ptr @generateLLVMVoidBodyFromRange(ptr %arg.tokens, i32 %arg.bodyStart, i32 %arg.bodyEnd) {
entry:
  %tokens = alloca ptr
  store ptr %arg.tokens, ptr %tokens
  %bodyStart = alloca i32
  store i32 %arg.bodyStart, ptr %bodyStart
  %bodyEnd = alloca i32
  store i32 %arg.bodyEnd, ptr %bodyEnd
  .left = load ptr, ptr %output
  .right = getelementptr inbounds [12 x i8], ptr @.str.42212, i32 0, i32 0
   = call ptr @csec_string_concat(ptr .left, ptr .right)
  ret ptr 
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
   = getelementptr inbounds [1 x i8], ptr @.str.0, i32 0, i32 0
  ret ptr 
}

define i64 @generateLLVMModuleBuilder(ptr %arg.tokens) {
entry:
  %tokens = alloca ptr
  store ptr %arg.tokens, ptr %tokens
  %ret = load i64, ptr %builder
  ret i64 %ret
}

define ptr @generateLLVMModule(ptr %arg.tokens) {
entry:
  %tokens = alloca ptr
  store ptr %arg.tokens, ptr %tokens
  ret ptr null
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
  %ret.44333 = icmp eq i32 0, 0
  ret i1 %ret.44333
}

define ptr @parentDirectory(ptr %arg.path) {
entry:
  %path = alloca ptr
  store ptr %arg.path, ptr %path
   = getelementptr inbounds [2 x i8], ptr @.str.0, i32 0, i32 0
  ret ptr 
}

define ptr @replaceDotsWithSlash(ptr %arg.text) {
entry:
  %text = alloca ptr
  store ptr %arg.text, ptr %text
   = load ptr, ptr %output
  ret ptr 
}

define ptr @importTargetFromLine(ptr %arg.line) {
entry:
  %line = alloca ptr
  store ptr %arg.line, ptr %line
   = load ptr, ptr %rest
  ret ptr 
}

define ptr @importCandidate(ptr %arg.target) {
entry:
  %target = alloca ptr
  store ptr %arg.target, ptr %target
  .left = load ptr, ptr %target
  .right = getelementptr inbounds [5 x i8], ptr @.str.44753, i32 0, i32 0
   = call ptr @csec_string_concat(ptr .left, ptr .right)
  ret ptr 
}

define ptr @resolveImportPath(ptr %arg.currentPath, ptr %arg.target) {
entry:
  %currentPath = alloca ptr
  store ptr %arg.currentPath, ptr %currentPath
  %target = alloca ptr
  store ptr %arg.target, ptr %target
   = load ptr, ptr %fromBase
  ret ptr 
}

define ptr @expandImportsFromFile(ptr %arg.path, ptr %arg.seen) {
entry:
  %path = alloca ptr
  store ptr %arg.path, ptr %path
  %seen = alloca ptr
  store ptr %arg.seen, ptr %seen
   = load ptr, ptr %output
  ret ptr 
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
