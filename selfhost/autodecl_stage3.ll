; ModuleID = 'csec.selfhost'
source_filename = "csec.selfhost"

declare ptr @csec_token_append_owned()
declare ptr @csec_token_builder_new()
declare ptr @csec_token_builder_append()
declare ptr @csec_token_builder_finish()
declare ptr @csec_tokenize_source()
declare ptr @csec_token_kind_at()
declare ptr @csec_token_text_at()
declare ptr @csec_token_is()
declare ptr @csec_expand_imports()
declare ptr @csec_string_builder_new_file()
declare ptr @csec_lex_quoted()
declare ptr @csec_lex_number()
declare ptr @csec_lex_identifier()
declare ptr @csec_digit_value()
declare ptr @csec_lex_line_comment()
declare ptr @csec_lex_block_comment()
define i8 @kindIdentifier() {
entry:
  ret i8 0
}

define i8 @kindKeyword() {
entry:
  ret i8 0
}

define i8 @kindInteger() {
entry:
  ret i8 0
}

define i8 @kindFloat() {
entry:
  ret i8 0
}

define i8 @kindString() {
entry:
  ret i8 0
}

define i8 @kindRegex() {
entry:
  ret i8 0
}

define i8 @kindChar() {
entry:
  ret i8 0
}

define i8 @kindBool() {
entry:
  ret i8 0
}

define i8 @kindOperator() {
entry:
  ret i8 0
}

define i8 @kindComment() {
entry:
  ret i8 0
}

define i8 @kindEof() {
entry:
  ret i8 0
}

define i1 @isWhitespace(i8 %arg.ch) {
entry:
  %space = icmp eq i8 %arg.ch, 32
  %newline = icmp eq i8 %arg.ch, 10
  %carriage = icmp eq i8 %arg.ch, 13
  %tab = icmp eq i8 %arg.ch, 9
  %space.or.newline = or i1 %space, %newline
  %carriage.or.tab = or i1 %carriage, %tab
  %ret = or i1 %space.or.newline, %carriage.or.tab
  ret i1 %ret
}

define i1 @isDigit(i8 %arg.ch) {
entry:
  %lower = icmp sge i8 %arg.ch, 48
  %upper = icmp sle i8 %arg.ch, 57
  %ret = and i1 %lower, %upper
  ret i1 %ret
}

define i32 @digitValue(i8 %arg.ch) {
entry:
  %ret = call i32 @csec_digit_value(i8 %arg.ch)
  ret i32 %ret
}

define i32 @toInt(ptr %arg.text) {
entry:
  %ret = call i32 @csec_to_int(ptr %arg.text)
  ret i32 %ret
}

define i1 @isAlpha(i8 %arg.ch) {
entry:
  %lower = icmp sge i8 %arg.ch, 97
  %lower.end = icmp sle i8 %arg.ch, 122
  %lower.match = and i1 %lower, %lower.end
  %upper = icmp sge i8 %arg.ch, 65
  %upper.end = icmp sle i8 %arg.ch, 90
  %upper.match = and i1 %upper, %upper.end
  %ret = or i1 %lower.match, %upper.match
  ret i1 %ret
}

define i1 @isIdentifierStart(i8 %arg.ch) {
entry:
  %alpha = call i1 @isAlpha(i8 %arg.ch)
  %underscore = icmp eq i8 %arg.ch, 95
  %ret = or i1 %alpha, %underscore
  ret i1 %ret
}

define i1 @isIdentifierPart(i8 %arg.ch) {
entry:
  %start = call i1 @isIdentifierStart(i8 %arg.ch)
  %digit = call i1 @isDigit(i8 %arg.ch)
  %ret = or i1 %start, %digit
  ret i1 %ret
}

define i1 @strEq(ptr %arg.left, ptr %arg.right) {
entry:
  %left.length = call i64 @csec_string_length(ptr %arg.left)
  %right.length = call i64 @csec_string_length(ptr %arg.right)
  %same.length = icmp eq i64 %left.length, %right.length
  %prefix = call i32 @csec_string_starts_with(ptr %arg.left, ptr %arg.right)
  %same.text = icmp ne i32 %prefix, 0
  %ret = and i1 %same.length, %same.text
  ret i1 %ret
}

define i1 @isKeyword(ptr %arg.text) {
entry:
  %keyword = call i32 @csec_is_keyword(ptr %arg.text)
  %ret = icmp ne i32 %keyword, 0
  ret i1 %ret
}

define ptr @appendToken(ptr %arg.tokens, i8 %arg.kind, ptr %arg.text) {
entry:
  %ret = call ptr @csec_token_append_owned(ptr %arg.tokens, i8 %arg.kind, ptr %arg.text)
  ret ptr %ret
}

define i32 @appendTokenTo(i64 %arg.builder, i8 %arg.kind, ptr %arg.text) {
entry:
  %ret = call i32 @csec_token_builder_append(i64 %arg.builder, i8 %arg.kind, ptr %arg.text)
  ret i32 %ret
}

define i1 @twoChars(ptr %arg.source, i32 %arg.index, ptr %arg.text) {
entry:
  %length = call i64 @csec_string_length(ptr %arg.source)
  %last = add i32 %arg.index, 1
  %last64 = sext i32 %last to i64
  %in.range = icmp slt i64 %last64, %length
  br i1 %in.range, label %compare, label %false
compare:
  %source0 = call i8 @csec_string_char_at(ptr %arg.source, i32 %arg.index)
  %text0 = call i8 @csec_string_char_at(ptr %arg.text, i32 0)
  %first = icmp eq i8 %source0, %text0
  %source1 = call i8 @csec_string_char_at(ptr %arg.source, i32 %last)
  %text1 = call i8 @csec_string_char_at(ptr %arg.text, i32 1)
  %second = icmp eq i8 %source1, %text1
  %ret = and i1 %first, %second
  ret i1 %ret
false:
  ret i1 false
}

define i1 @threeChars(ptr %arg.source, i32 %arg.index, ptr %arg.text) {
entry:
  %length = call i64 @csec_string_length(ptr %arg.source)
  %last = add i32 %arg.index, 2
  %last64 = sext i32 %last to i64
  %in.range = icmp slt i64 %last64, %length
  br i1 %in.range, label %compare, label %false
compare:
  %source0 = call i8 @csec_string_char_at(ptr %arg.source, i32 %arg.index)
  %text0 = call i8 @csec_string_char_at(ptr %arg.text, i32 0)
  %first = icmp eq i8 %source0, %text0
  %index1 = add i32 %arg.index, 1
  %source1 = call i8 @csec_string_char_at(ptr %arg.source, i32 %index1)
  %text1 = call i8 @csec_string_char_at(ptr %arg.text, i32 1)
  %second = icmp eq i8 %source1, %text1
  %source2 = call i8 @csec_string_char_at(ptr %arg.source, i32 %last)
  %text2 = call i8 @csec_string_char_at(ptr %arg.text, i32 2)
  %third = icmp eq i8 %source2, %text2
  %first.two = and i1 %first, %second
  %ret = and i1 %first.two, %third
  ret i1 %ret
false:
  ret i1 false
}

define i32 @lexIdentifier(ptr %arg.source, i32 %arg.index) {
entry:
  %ret = call i32 @csec_lex_identifier(ptr %arg.source, i32 %arg.index)
  ret i32 %ret
}

define i32 @lexNumber(ptr %arg.source, i32 %arg.index) {
entry:
  %ret = call i32 @csec_lex_number(ptr %arg.source, i32 %arg.index)
  ret i32 %ret
}

define i32 @lexQuoted(ptr %arg.source, i32 %arg.index) {
entry:
  %ret = call i32 @csec_lex_quoted(ptr %arg.source, i32 %arg.index)
  ret i32 %ret
}

define i32 @lexLineComment(ptr %arg.source, i32 %arg.index) {
entry:
  %ret = call i32 @csec_lex_line_comment(ptr %arg.source, i32 %arg.index)
  ret i32 %ret
}

define i32 @lexBlockComment(ptr %arg.source, i32 %arg.index) {
entry:
  %ret = call i32 @csec_lex_block_comment(ptr %arg.source, i32 %arg.index)
  ret i32 %ret
}

declare i32 @csec_operator_length(ptr, i32)

define i32 @operatorLength(ptr %arg.source, i32 %arg.index) {
entry:
  %ret = call i32 @csec_operator_length(ptr %arg.source, i32 %arg.index)
  ret i32 %ret
}

@.str.repair.r.eturn = private unnamed_addr constant [6 x i8] c"eturn\00"
@.str.repair.r.return = private unnamed_addr constant [7 x i8] c"return\00"
@.str.repair.r.atio = private unnamed_addr constant [5 x i8] c"atio\00"
@.str.repair.r.ratio = private unnamed_addr constant [6 x i8] c"ratio\00"
@.str.repair.r.educe = private unnamed_addr constant [6 x i8] c"educe\00"
@.str.repair.r.reduce = private unnamed_addr constant [7 x i8] c"reduce\00"
@.str.repair.r.ange = private unnamed_addr constant [5 x i8] c"ange\00"
@.str.repair.r.range = private unnamed_addr constant [6 x i8] c"range\00"
@.str.repair.r.egex = private unnamed_addr constant [5 x i8] c"egex\00"
@.str.repair.r.regex = private unnamed_addr constant [6 x i8] c"regex\00"
@.str.repair.r.Regex = private unnamed_addr constant [6 x i8] c"Regex\00"

define ptr @repairLeadingRTokenText(ptr %arg.text) {
entry:
  %case0 = call i32 @csec_string_equals(ptr %arg.text, ptr @.str.repair.r.eturn)
  %is0 = icmp ne i32 %case0, 0
  br i1 %is0, label %return0, label %check1
return0:
  ret ptr @.str.repair.r.return
check1:
  %case1 = call i32 @csec_string_equals(ptr %arg.text, ptr @.str.repair.r.atio)
  %is1 = icmp ne i32 %case1, 0
  br i1 %is1, label %return1, label %check2
return1:
  ret ptr @.str.repair.r.ratio
check2:
  %case2 = call i32 @csec_string_equals(ptr %arg.text, ptr @.str.repair.r.educe)
  %is2 = icmp ne i32 %case2, 0
  br i1 %is2, label %return2, label %check3
return2:
  ret ptr @.str.repair.r.reduce
check3:
  %case3 = call i32 @csec_string_equals(ptr %arg.text, ptr @.str.repair.r.ange)
  %is3 = icmp ne i32 %case3, 0
  br i1 %is3, label %return3, label %check4
return3:
  ret ptr @.str.repair.r.range
check4:
  %case4 = call i32 @csec_string_equals(ptr %arg.text, ptr @.str.repair.r.egex)
  %is4 = icmp ne i32 %case4, 0
  br i1 %is4, label %return4, label %check5
return4:
  ret ptr @.str.repair.r.regex
check5:
  %case5 = call i32 @csec_string_equals(ptr %arg.text, ptr @.str.repair.r.Regex)
  %is5 = icmp ne i32 %case5, 0
  br i1 %is5, label %return5, label %fallback
return5:
  ret ptr @.str.repair.r.Regex
fallback:
  ret ptr %arg.text
}

define ptr @slice(ptr %arg.source, i32 %arg.start, i32 %arg.end) {
entry:
  %valid = icmp sgt i32 %arg.end, %arg.start
  br i1 %valid, label %slice, label %empty
slice:
  %length = sub i32 %arg.end, %arg.start
  %ret = call ptr @csec_string_substring(ptr %arg.source, i32 %arg.start, i32 %length)
  ret ptr %ret
empty:
  ret ptr null
}

define ptr @tokenize(ptr %arg.source) {
entry:
  %ret = call ptr @csec_tokenize_source(ptr %arg.source)
  ret ptr %ret
}

define ptr @tokenizeSlow(ptr %arg.source) {
entry:
  %ret = call ptr @csec_tokenize_source(ptr %arg.source)
  ret ptr %ret
}

define i32 @lineStart(ptr %arg.tokens, i32 %arg.ordinal) {
entry:
  %ret = call i32 @csec_line_start(ptr %arg.tokens, i32 %arg.ordinal)
  ret i32 %ret
}

define i32 @lineEnd(ptr %arg.tokens, i32 %arg.start) {
entry:
  %ret = call i32 @csec_line_end(ptr %arg.tokens, i32 %arg.start)
  ret i32 %ret
}

define i8 @tokenKindAt(ptr %arg.tokens, i32 %arg.ordinal) {
entry:
  %ret = call i8 @csec_token_kind_at(ptr %arg.tokens, i32 %arg.ordinal)
  ret i8 %ret
}

define ptr @tokenTextAt(ptr %arg.tokens, i32 %arg.ordinal) {
entry:
  %ret = call ptr @csec_token_text_at(ptr %arg.tokens, i32 %arg.ordinal)
  ret ptr %ret
}

define i1 @tokenIs(ptr %arg.tokens, i32 %arg.ordinal, i8 %arg.kind, ptr %arg.text) {
entry:
  %token.is = call i32 @csec_token_is(ptr %arg.tokens, i32 %arg.ordinal, i8 %arg.kind, ptr %arg.text)
  %token.is.bool = icmp ne i32 %token.is, 0
  ret i1 %token.is.bool
}

define i32 @skipTrivia(ptr %arg.tokens, i32 %arg.ordinal) {
entry:
  br label %loop
loop:
  %cursor = phi i32 [ %arg.ordinal, %entry ], [ %next, %body ]
  %kind = call i8 @csec_token_kind_at(ptr %arg.tokens, i32 %cursor)
  %is.comment = icmp eq i8 %kind, 77
  br i1 %is.comment, label %body, label %exit
body:
  %next = add i32 %cursor, 1
  br label %loop
exit:
  ret i32 %cursor
}

declare ptr @csec_lookup_function_return_type()
declare ptr @csec_advance_statement()
declare ptr @csec_advance_top_level_decl()
declare ptr @csec_find_decl_body_start()
declare ptr @csec_find_decl_body_end()
declare ptr @csec_function_param_end()
declare ptr @csec_function_llvm_param_list()
declare ptr @csec_function_llvm_param_allocas()
declare ptr @csec_llvm_name_with_number()
declare ptr @csec_function_return_type_at()
define i1 @validateBalanced(ptr %arg.tokens) {
entry:
  %valid = call i32 @csec_validate_balanced(ptr %arg.tokens)
  %ret = icmp ne i32 %valid, 0
  ret i1 %ret
}

define i1 @startsTopLevelDeclaration(ptr %arg.tokens, i32 %arg.ordinal) {
entry:
  %valid = call i32 @csec_starts_top_level_declaration(ptr %arg.tokens, i32 %arg.ordinal)
  %ret = icmp ne i32 %valid, 0
  ret i1 %ret
}

define i1 @validateTopLevel(ptr %arg.tokens) {
entry:
  %valid = call i32 @csec_validate_top_level(ptr %arg.tokens)
  %ret = icmp ne i32 %valid, 0
  ret i1 %ret
}

define i1 @parseProgram(ptr %arg.tokens) {
entry:
  %balanced = call i1 @validateBalanced(ptr %arg.tokens)
  br i1 %balanced, label %validate, label %invalid
validate:
  %ret = call i1 @validateTopLevel(ptr %arg.tokens)
  ret i1 %ret
invalid:
  ret i1 false
}

define ptr @topLevelDeclKind(ptr %arg.tokens, i32 %arg.ordinal) {
entry:
  %ret = call ptr @csec_top_level_decl_kind(ptr %arg.tokens, i32 %arg.ordinal)
  ret ptr %ret
}

define ptr @topLevelDeclName(ptr %arg.tokens, i32 %arg.ordinal) {
entry:
  %ret = call ptr @csec_top_level_decl_name(ptr %arg.tokens, i32 %arg.ordinal)
  ret ptr %ret
}

define i32 @advanceTopLevelDecl(ptr %arg.tokens, i32 %arg.ordinal) {
entry:
  %ret = call i32 @csec_advance_top_level_decl(ptr %arg.tokens, i32 %arg.ordinal)
  ret i32 %ret
}

define i32 @advanceTopLevelDeclSlow(ptr %arg.tokens, i32 %arg.ordinal) {
entry:
  %ret = call i32 @csec_advance_top_level_decl(ptr %arg.tokens, i32 %arg.ordinal)
  ret i32 %ret
}

define i32 @findDeclBodyStart(ptr %arg.tokens, i32 %arg.ordinal) {
entry:
  %ret = call i32 @csec_find_decl_body_start(ptr %arg.tokens, i32 %arg.ordinal)
  ret i32 %ret
}

define i32 @findDeclBodyStartSlow(ptr %arg.tokens, i32 %arg.ordinal) {
entry:
  %ret = call i32 @csec_find_decl_body_start(ptr %arg.tokens, i32 %arg.ordinal)
  ret i32 %ret
}

define i32 @findDeclBodyEnd(ptr %arg.tokens, i32 %arg.bodyStart) {
entry:
  %ret = call i32 @csec_find_decl_body_end(ptr %arg.tokens, i32 %arg.bodyStart)
  ret i32 %ret
}

define i32 @findDeclBodyEndSlow(ptr %arg.tokens, i32 %arg.bodyStart) {
entry:
  %ret = call i32 @csec_find_decl_body_end(ptr %arg.tokens, i32 %arg.bodyStart)
  ret i32 %ret
}

declare ptr @csec_statement_kind(ptr, i32)

define ptr @statementKind(ptr %arg.tokens, i32 %arg.ordinal) {
entry:
  %ret = call ptr @csec_statement_kind(ptr %arg.tokens, i32 %arg.ordinal)
  ret ptr %ret
}

define ptr @appendExpressionUntil(ptr %arg.tokens, i32 %arg.start, i32 %arg.end) {
entry:
  %ret = call ptr @csec_append_expression_until(ptr %arg.tokens, i32 %arg.start, i32 %arg.end)
  ret ptr %ret
}

define i1 @tokenIsTopLevelOperator(ptr %arg.tokens, i32 %arg.ordinal, i32 %arg.group) {
entry:
  %valid = call i32 @csec_token_is_top_level_operator(ptr %arg.tokens, i32 %arg.ordinal, i32 %arg.group)
  %ret = icmp ne i32 %valid, 0
  ret i1 %ret
}

define i32 @findTopLevelOperator(ptr %arg.tokens, i32 %arg.start, i32 %arg.end, i32 %arg.group) {
entry:
  %ret = call i32 @csec_find_top_level_operator(ptr %arg.tokens, i32 %arg.start, i32 %arg.end, i32 %arg.group)
  ret i32 %ret
}

define i32 @findTopLevelMatch(ptr %arg.tokens, i32 %arg.start, i32 %arg.end) {
entry:
  %ret = call i32 @csec_find_top_level_match(ptr %arg.tokens, i32 %arg.start, i32 %arg.end)
  ret i32 %ret
}

define i32 @findClosingToken(ptr %arg.tokens, i32 %arg.openOrdinal, i32 %arg.end, ptr %arg.openText, ptr %arg.closeText) {
entry:
  %ret = call i32 @csec_find_closing_token(ptr %arg.tokens, i32 %arg.openOrdinal, i32 %arg.end, ptr %arg.openText, ptr %arg.closeText)
  ret i32 %ret
}

define i32 @trimExpressionEnd(ptr %arg.tokens, i32 %arg.start, i32 %arg.end) {
entry:
  br label %trim.loop
trim.loop:
  %last = phi i32 [ %arg.end, %entry ], [ %previous, %trim.comment ]
  %has.previous = icmp sgt i32 %last, %arg.start
  br i1 %has.previous, label %trim.inspect, label %trim.check
trim.inspect:
  %index = sub i32 %last, 1
  %kind = call i8 @csec_token_kind_at(ptr %arg.tokens, i32 %index)
  %is.comment = icmp eq i8 %kind, 77
  br i1 %is.comment, label %trim.comment, label %trim.check
trim.comment:
  %previous = sub i32 %last, 1
  br label %trim.loop
trim.check:
  %has.token = icmp sgt i32 %last, %arg.start
  br i1 %has.token, label %trim.semicolon, label %trim.return
trim.semicolon:
  %candidate = sub i32 %last, 1
  %is.semicolon = call i32 @csec_token_is(ptr %arg.tokens, i32 %candidate, i8 79, ptr @.str.trim.semicolon)
  %has.semicolon = icmp ne i32 %is.semicolon, 0
  br i1 %has.semicolon, label %trim.without.semicolon, label %trim.return
trim.without.semicolon:
  %result = sub i32 %last, 1
  ret i32 %result
trim.return:
  ret i32 %last
}

@.str.trim.semicolon = private unnamed_addr constant [2 x i8] c";\00"

declare ptr @csec_expression_leaf_kind(ptr, i32, i32)

define ptr @expressionLeafKind(ptr %arg.tokens, i32 %arg.start, i32 %arg.end) {
entry:
  %ret = call ptr @csec_expression_leaf_kind(ptr %arg.tokens, i32 %arg.start, i32 %arg.end)
  ret ptr %ret
}

define i32 @findTokenTextInRange(ptr %arg.tokens, i32 %arg.start, i32 %arg.end, ptr %arg.text) {
entry:
  %ret = call i32 @csec_find_token_text_in_range(ptr %arg.tokens, i32 %arg.start, i32 %arg.end, ptr %arg.text)
  ret i32 %ret
}

@.str.count.match.case = private unnamed_addr constant [5 x i8] c"case\00"

define i32 @countMatchCases(ptr %arg.tokens, i32 %arg.matchOrdinal, i32 %arg.end) {
entry:
  %open = call i32 @findTokenTextInRange(ptr %arg.tokens, i32 %arg.matchOrdinal, i32 %arg.end, ptr @.str.open.brace)
  %has.open = icmp sge i32 %open, 0
  br i1 %has.open, label %find.close, label %empty
find.close:
  %close = call i32 @findClosingToken(ptr %arg.tokens, i32 %open, i32 %arg.end, ptr @.str.open.brace, ptr @.str.close.brace)
  %first = add i32 %open, 1
  br label %loop
loop:
  %cursor = phi i32 [ %first, %find.close ], [ %next, %body ]
  %count = phi i32 [ 0, %find.close ], [ %updated, %body ]
  %before.close = icmp slt i32 %cursor, %close
  br i1 %before.close, label %inspect, label %done
inspect:
  %kind = call i8 @csec_token_kind_at(ptr %arg.tokens, i32 %cursor)
  %is.eof = icmp eq i8 %kind, 69
  br i1 %is.eof, label %done, label %body
body:
  %case.raw = call i32 @csec_token_is(ptr %arg.tokens, i32 %cursor, i8 75, ptr @.str.count.match.case)
  %is.case = icmp ne i32 %case.raw, 0
  %increment = zext i1 %is.case to i32
  %updated = add i32 %count, %increment
  %next = add i32 %cursor, 1
  br label %loop
done:
  ret i32 %count
empty:
  ret i32 0
}

@.str.open.brace = private unnamed_addr constant [2 x i8] c"{\00"
@.str.close.brace = private unnamed_addr constant [2 x i8] c"}\00"

define i32 @findStatementParenStart(ptr %arg.tokens, i32 %arg.start, i32 %arg.end) {
entry:
  %ret = call i32 @csec_find_statement_paren_start(ptr %arg.tokens, i32 %arg.start, i32 %arg.end)
  ret i32 %ret
}

define i32 @findStatementParenEnd(ptr %arg.tokens, i32 %arg.start, i32 %arg.end) {
entry:
  %ret = call i32 @csec_find_statement_paren_end(ptr %arg.tokens, i32 %arg.start, i32 %arg.end)
  ret i32 %ret
}

define i32 @findStatementBlockStart(ptr %arg.tokens, i32 %arg.start, i32 %arg.end) {
entry:
  %ret = call i32 @csec_find_statement_block_start(ptr %arg.tokens, i32 %arg.start, i32 %arg.end)
  ret i32 %ret
}

define i32 @findStatementBlockEnd(ptr %arg.tokens, i32 %arg.start, i32 %arg.end) {
entry:
  %ret = call i32 @csec_find_statement_block_end(ptr %arg.tokens, i32 %arg.start, i32 %arg.end)
  ret i32 %ret
}

@.str.statement.header.empty = private unnamed_addr constant [1 x i8] c"\00"

define ptr @statementHeaderExpression(ptr %arg.tokens, i32 %arg.start, i32 %arg.end) {
entry:
  %open = call i32 @findStatementParenStart(ptr %arg.tokens, i32 %arg.start, i32 %arg.end)
  %close = call i32 @findStatementParenEnd(ptr %arg.tokens, i32 %arg.start, i32 %arg.end)
  %has.open = icmp sge i32 %open, 0
  %after.open = icmp sgt i32 %close, %open
  %valid = and i1 %has.open, %after.open
  br i1 %valid, label %body, label %empty
body:
  %body.start = add i32 %open, 1
  %ret = call ptr @appendExpressionUntil(ptr %arg.tokens, i32 %body.start, i32 %close)
  ret ptr %ret
empty:
  ret ptr @.str.statement.header.empty
}

define i32 @countCommaSeparated(ptr %arg.tokens, i32 %arg.start, i32 %arg.end) {
entry:
  %ret = call i32 @csec_count_comma_separated(ptr %arg.tokens, i32 %arg.start, i32 %arg.end)
  ret i32 %ret
}

define i32 @findLastTopLevelToken(ptr %arg.tokens, i32 %arg.start, i32 %arg.end, ptr %arg.text) {
entry:
  %ret = call i32 @csec_find_last_top_level_token(ptr %arg.tokens, i32 %arg.start, i32 %arg.end, ptr %arg.text)
  ret i32 %ret
}

@.str.postfix.summary.empty = private unnamed_addr constant [1 x i8] c"\00"

define ptr @summarizePostfixExpression(ptr %arg.tokens, i32 %arg.start, i32 %arg.end) {
entry:
  ret ptr @.str.postfix.summary.empty
}

define i32 @findLambdaArrow(ptr %arg.tokens, i32 %arg.start, i32 %arg.end) {
entry:
  ret i32 -1
}

define ptr @lambdaCaptureSummary(ptr %arg.tokens, i32 %arg.start, i32 %arg.end) {
entry:
  %close = call i32 @findClosingToken(ptr %arg.tokens, i32 %arg.start, i32 %arg.end, ptr @.str.lambda.capture.open, ptr @.str.lambda.capture.close)
  %minimum = add i32 %arg.start, 1
  %has.capture = icmp sgt i32 %close, %minimum
  br i1 %has.capture, label %capture, label %none
capture:
  %first = add i32 %arg.start, 1
  %ret.capture = call ptr @appendExpressionUntil(ptr %arg.tokens, i32 %first, i32 %close)
  ret ptr %ret.capture
none:
  %ret.none = getelementptr inbounds [5 x i8], ptr @.str.lambda.none, i32 0, i32 0
  ret ptr %ret.none
}

@.str.lambda.capture.open = private unnamed_addr constant [2 x i8] c"[\00"
@.str.lambda.capture.close = private unnamed_addr constant [2 x i8] c"]\00"
@.str.lambda.none = private unnamed_addr constant [5 x i8] c"none\00"

define i32 @lambdaParameterCount(ptr %arg.tokens, i32 %arg.start, i32 %arg.end) {
entry:
  %capture.close = call i32 @findClosingToken(ptr %arg.tokens, i32 %arg.start, i32 %arg.end, ptr @.str.lambda.params.capture.open, ptr @.str.lambda.params.capture.close)
  %capture.valid = icmp sge i32 %capture.close, 0
  br i1 %capture.valid, label %params.start, label %empty
params.start:
  %after.capture = add i32 %capture.close, 1
  %params.open = call i32 @skipTrivia(ptr %arg.tokens, i32 %after.capture)
  %is.open.raw = call i32 @csec_token_is(ptr %arg.tokens, i32 %params.open, i8 79, ptr @.str.lambda.params.open)
  %is.open = icmp ne i32 %is.open.raw, 0
  br i1 %is.open, label %params.end, label %empty
params.end:
  %params.close = call i32 @findClosingToken(ptr %arg.tokens, i32 %params.open, i32 %arg.end, ptr @.str.lambda.params.open, ptr @.str.lambda.params.close)
  %first = add i32 %params.open, 1
  %ret = call i32 @countCommaSeparated(ptr %arg.tokens, i32 %first, i32 %params.close)
  ret i32 %ret
empty:
  ret i32 0
}

@.str.lambda.params.capture.open = private unnamed_addr constant [2 x i8] c"[\00"
@.str.lambda.params.capture.close = private unnamed_addr constant [2 x i8] c"]\00"
@.str.lambda.params.open = private unnamed_addr constant [2 x i8] c"(\00"
@.str.lambda.params.close = private unnamed_addr constant [2 x i8] c")\00"

define ptr @summarizeLambdaExpression(ptr %arg.tokens, i32 %arg.start, i32 %arg.end) {
entry:
  %open.raw = call i32 @csec_token_is(ptr %arg.tokens, i32 %arg.start, i8 79, ptr @.str.lambda.summary.open)
  %open = icmp ne i32 %open.raw, 0
  br i1 %open, label %arrow.check, label %empty
arrow.check:
  %arrow = call i32 @findLambdaArrow(ptr %arg.tokens, i32 %arg.start, i32 %arg.end)
  %valid = icmp sge i32 %arrow, 0
  br i1 %valid, label %summary, label %empty
summary:
  %capture = call ptr @lambdaCaptureSummary(ptr %arg.tokens, i32 %arg.start, i32 %arg.end)
  %params = call i32 @lambdaParameterCount(ptr %arg.tokens, i32 %arg.start, i32 %arg.end)
  %params.i64 = sext i32 %params to i64
  %params.text = call ptr @csec_to_string_i64(i64 %params.i64)
  %s1 = call ptr @csec_string_concat(ptr @.str.lambda.summary.prefix, ptr %capture)
  %s2 = call ptr @csec_string_concat(ptr %s1, ptr @.str.lambda.summary.params)
  %s3 = call ptr @csec_string_concat(ptr %s2, ptr %params.text)
  ret ptr %s3
empty:
  ret ptr @.str.lambda.summary.empty
}

@.str.lambda.summary.open = private unnamed_addr constant [2 x i8] c"[\00"
@.str.lambda.summary.prefix = private unnamed_addr constant [21 x i8] c"Expr lambda capture=\00"
@.str.lambda.summary.params = private unnamed_addr constant [9 x i8] c" params=\00"
@.str.lambda.summary.empty = private unnamed_addr constant [1 x i8] c"\00"

define ptr @generateExpressionAST(ptr %arg.tokens, i32 %arg.rawStart, i32 %arg.rawEnd) {
entry:
  %ret = call ptr @csec_generate_expression_ast(ptr %arg.tokens, i32 %arg.rawStart, i32 %arg.rawEnd)
  ret ptr %ret
}

define i32 @advanceStatement(ptr %arg.tokens, i32 %arg.ordinal, i32 %arg.bodyEnd) {
entry:
  %ret = call i32 @csec_advance_statement(ptr %arg.tokens, i32 %arg.ordinal, i32 %arg.bodyEnd)
  ret i32 %ret
}

define i32 @advanceStatementSlow(ptr %arg.tokens, i32 %arg.ordinal, i32 %arg.bodyEnd) {
entry:
  %ret = call i32 @csec_advance_statement(ptr %arg.tokens, i32 %arg.ordinal, i32 %arg.bodyEnd)
  ret i32 %ret
}

define ptr @generateStatementAST(ptr %arg.tokens, i32 %arg.start, i32 %arg.end) {
entry:
  %ret = call ptr @csec_generate_statement_ast(ptr %arg.tokens, i32 %arg.start, i32 %arg.end)
  ret ptr %ret
}

define ptr @generateBodyAST(ptr %arg.tokens, i32 %arg.bodyStart, i32 %arg.bodyEnd) {
entry:
  %ret = call ptr @csec_generate_body_ast(ptr %arg.tokens, i32 %arg.bodyStart, i32 %arg.bodyEnd)
  ret ptr %ret
}

define i32 @findFunctionParamStart(ptr %arg.tokens, i32 %arg.declStart) {
entry:
  %ret = call i32 @csec_find_function_param_start(ptr %arg.tokens, i32 %arg.declStart)
  ret i32 %ret
}

define i32 @findFunctionReturnTypeStart(ptr %arg.tokens, i32 %arg.declStart) {
entry:
  %param.start = call i32 @findFunctionParamStart(ptr %arg.tokens, i32 %arg.declStart)
  %valid.start = icmp sge i32 %param.start, 0
  br i1 %valid.start, label %find.end, label %missing
find.end:
  %decl.end = call i32 @advanceTopLevelDecl(ptr %arg.tokens, i32 %arg.declStart)
  %param.end = call i32 @findClosingToken(ptr %arg.tokens, i32 %param.start, i32 %decl.end, ptr @.str.fn.return.open, ptr @.str.fn.return.close)
  %valid.end = icmp sge i32 %param.end, 0
  br i1 %valid.end, label %colon.check, label %missing
colon.check:
  %after = add i32 %param.end, 1
  %colon.raw = call i32 @csec_token_is(ptr %arg.tokens, i32 %after, i8 79, ptr @.str.fn.return.colon)
  %colon = icmp ne i32 %colon.raw, 0
  br i1 %colon, label %found, label %missing
found:
  %ret = add i32 %param.end, 2
  ret i32 %ret
missing:
  ret i32 -1
}

@.str.fn.return.open = private unnamed_addr constant [2 x i8] c"(\00"
@.str.fn.return.close = private unnamed_addr constant [2 x i8] c")\00"
@.str.fn.return.colon = private unnamed_addr constant [2 x i8] c":\00"

define ptr @collectTypeName(ptr %arg.tokens, i32 %arg.start, i32 %arg.end) {
entry:
  %ret = call ptr @csec_collect_type_name(ptr %arg.tokens, i32 %arg.start, i32 %arg.end)
  ret ptr %ret
}

define ptr @functionReturnType(ptr %arg.tokens, i32 %arg.declStart) {
entry:
  %ret = call ptr @csec_function_return_type_at(ptr %arg.tokens, i32 %arg.declStart)
  ret ptr %ret
}

define ptr @functionReturnTypeSlow(ptr %arg.tokens, i32 %arg.declStart) {
entry:
  %ret = call ptr @csec_function_return_type_at(ptr %arg.tokens, i32 %arg.declStart)
  ret ptr %ret
}

define i32 @countFunctionParams(ptr %arg.tokens, i32 %arg.declStart) {
entry:
  %ret = call i32 @csec_count_function_params(ptr %arg.tokens, i32 %arg.declStart)
  ret i32 %ret
}

define ptr @typeSummary(ptr %arg.tokens, i32 %arg.start, i32 %arg.end) {
entry:
  %open.raw = call i32 @csec_token_is(ptr %arg.tokens, i32 %arg.start, i8 79, ptr @.str.type.summary.open)
  %open = icmp ne i32 %open.raw, 0
  br i1 %open, label %find.close, label %fallback
find.close:
  %close = call i32 @findClosingToken(ptr %arg.tokens, i32 %arg.start, i32 %arg.end, ptr @.str.type.summary.open, ptr @.str.type.summary.close)
  %valid.close = icmp sgt i32 %close, %arg.start
  br i1 %valid.close, label %arrow.check, label %fallback
arrow.check:
  %after.close = add i32 %close, 1
  %arrow.raw = call i32 @csec_token_is(ptr %arg.tokens, i32 %after.close, i8 79, ptr @.str.type.summary.arrow)
  %arrow = icmp ne i32 %arrow.raw, 0
  br i1 %arrow, label %function, label %fallback
function:
  %params.start = add i32 %arg.start, 1
  %params = call i32 @countCommaSeparated(ptr %arg.tokens, i32 %params.start, i32 %close)
  %params.i64 = sext i32 %params to i64
  %params.text = call ptr @csec_to_string_i64(i64 %params.i64)
  %returns.start = add i32 %close, 2
  %returns = call ptr @collectTypeName(ptr %arg.tokens, i32 %returns.start, i32 %arg.end)
  %s1 = call ptr @csec_string_concat(ptr @.str.type.summary.prefix, ptr %params.text)
  %s2 = call ptr @csec_string_concat(ptr %s1, ptr @.str.type.summary.returns)
  %ret = call ptr @csec_string_concat(ptr %s2, ptr %returns)
  ret ptr %ret
fallback:
  %fallback.ret = call ptr @collectTypeName(ptr %arg.tokens, i32 %arg.start, i32 %arg.end)
  ret ptr %fallback.ret
}

@.str.type.summary.open = private unnamed_addr constant [2 x i8] c"(\00"
@.str.type.summary.close = private unnamed_addr constant [2 x i8] c")\00"
@.str.type.summary.arrow = private unnamed_addr constant [3 x i8] c"=>\00"
@.str.type.summary.prefix = private unnamed_addr constant [21 x i8] c"FunctionType params=\00"
@.str.type.summary.returns = private unnamed_addr constant [10 x i8] c" returns=\00"

declare ptr @csec_declared_value_type(ptr, i32, i32)

define ptr @declaredValueType(ptr %arg.tokens, i32 %arg.declStart, i32 %arg.declEnd) {
entry:
  %ret = call ptr @csec_declared_value_type(ptr %arg.tokens, i32 %arg.declStart, i32 %arg.declEnd)
  ret ptr %ret
}

define ptr @lookupFunctionReturnType(ptr %arg.tokens, ptr %arg.name) {
entry:
  %ret = call ptr @csec_lookup_function_return_type(ptr %arg.tokens, ptr %arg.name)
  ret ptr %ret
}

declare ptr @csec_infer_expression_type(ptr, i32, i32)

define ptr @inferExpressionType(ptr %arg.tokens, i32 %arg.rawStart, i32 %arg.rawEnd) {
entry:
  %ret = call ptr @csec_infer_expression_type(ptr %arg.tokens, i32 %arg.rawStart, i32 %arg.rawEnd)
  ret ptr %ret
}

declare ptr @csec_declared_local_type(ptr, i32, i32)

define ptr @declaredLocalType(ptr %arg.tokens, i32 %arg.start, i32 %arg.end) {
entry:
  %ret = call ptr @csec_declared_local_type(ptr %arg.tokens, i32 %arg.start, i32 %arg.end)
  ret ptr %ret
}

@.str.local.type.unknown = private unnamed_addr constant [8 x i8] c"unknown\00"

define ptr @localDeclarationType(ptr %arg.tokens, i32 %arg.start, i32 %arg.end) {
entry:
  %explicit = call ptr @declaredLocalType(ptr %arg.tokens, i32 %arg.start, i32 %arg.end)
  %has.type = call i32 @csec_string_length(ptr %explicit)
  %present = icmp sgt i32 %has.type, 0
  br i1 %present, label %typed, label %fallback
typed:
  ret ptr %explicit
fallback:
  ret ptr @.str.local.type.unknown
}

@.str.function.scope.symbols.empty = private unnamed_addr constant [1 x i8] c"\00"

define ptr @generateFunctionScopeSymbols(ptr %arg.tokens, ptr %arg.functionName, i32 %arg.bodyStart, i32 %arg.bodyEnd) {
entry:
  ret ptr @.str.function.scope.symbols.empty
}

@.str.function.param.symbols.empty = private unnamed_addr constant [1 x i8] c"\00"

define ptr @generateFunctionParamSymbols(ptr %arg.tokens, ptr %arg.functionName, i32 %arg.declStart) {
entry:
  ret ptr @.str.function.param.symbols.empty
}

@.str.class.member.override = private unnamed_addr constant [9 x i8] c"override\00"
@.str.class.member.unsafe = private unnamed_addr constant [7 x i8] c"unsafe\00"
@.str.class.member.constexpr = private unnamed_addr constant [10 x i8] c"constexpr\00"

define i32 @classMemberStart(ptr %arg.tokens, i32 %arg.ordinal) {
entry:
  %override.raw = call i32 @csec_token_is(ptr %arg.tokens, i32 %arg.ordinal, i8 75, ptr @.str.class.member.override)
  %unsafe.raw = call i32 @csec_token_is(ptr %arg.tokens, i32 %arg.ordinal, i8 75, ptr @.str.class.member.unsafe)
  %constexpr.raw = call i32 @csec_token_is(ptr %arg.tokens, i32 %arg.ordinal, i8 75, ptr @.str.class.member.constexpr)
  %override = icmp ne i32 %override.raw, 0
  %unsafe = icmp ne i32 %unsafe.raw, 0
  %constexpr = icmp ne i32 %constexpr.raw, 0
  %modifier = or i1 %override, %unsafe
  %skip = or i1 %modifier, %constexpr
  br i1 %skip, label %advanced, label %plain
advanced:
  %next = add i32 %arg.ordinal, 1
  ret i32 %next
plain:
  ret i32 %arg.ordinal
}

declare ptr @csec_class_member_kind(ptr, i32)

define ptr @classMemberKind(ptr %arg.tokens, i32 %arg.ordinal) {
entry:
  %ret = call ptr @csec_class_member_kind(ptr %arg.tokens, i32 %arg.ordinal)
  ret ptr %ret
}

declare ptr @csec_class_member_name(ptr, i32)

define ptr @classMemberName(ptr %arg.tokens, i32 %arg.ordinal) {
entry:
  %ret = call ptr @csec_class_member_name(ptr %arg.tokens, i32 %arg.ordinal)
  ret ptr %ret
}

@.str.class.member.symbols.empty = private unnamed_addr constant [1 x i8] c"\00"

define ptr @generateClassMemberSymbols(ptr %arg.tokens, ptr %arg.className, i32 %arg.bodyStart, i32 %arg.bodyEnd) {
entry:
  ret ptr @.str.class.member.symbols.empty
}

@.str.class.member.ast.empty = private unnamed_addr constant [1 x i8] c"\00"

define ptr @generateClassMemberAST(ptr %arg.tokens, i32 %arg.bodyStart, i32 %arg.bodyEnd) {
entry:
  ret ptr @.str.class.member.ast.empty
}

@.str.summary.templateParameterSummary.empty = private unnamed_addr constant [1 x i8] c"\00"

define ptr @templateParameterSummary(ptr %arg.tokens, i32 %arg.ordinal) {
entry:
  ret ptr @.str.summary.templateParameterSummary.empty
}

@.str.summary.templateTargetKind.empty = private unnamed_addr constant [1 x i8] c"\00"

define ptr @templateTargetKind(ptr %arg.tokens, i32 %arg.ordinal) {
entry:
  ret ptr @.str.summary.templateTargetKind.empty
}

@.str.summary.attributeSummary.empty = private unnamed_addr constant [1 x i8] c"\00"

define ptr @attributeSummary(ptr %arg.tokens, i32 %arg.ordinal) {
entry:
  ret ptr @.str.summary.attributeSummary.empty
}

@.str.summary.externalSymbolKind.empty = private unnamed_addr constant [1 x i8] c"\00"

define ptr @externalSymbolKind(ptr %arg.tokens, i32 %arg.ordinal) {
entry:
  ret ptr @.str.summary.externalSymbolKind.empty
}

define ptr @generateSymbolTable(ptr %arg.tokens) {
entry:
  %ret = call ptr @csec_generate_symbol_table(ptr %arg.tokens)
  ret ptr %ret
}

@.str.ast.empty = private unnamed_addr constant [1 x i8] c"\00"

define ptr @generateAST(ptr %arg.tokens) {
entry:
  ret ptr @.str.ast.empty
}

declare ptr @csec_string_builder_new()
declare ptr @csec_string_builder_append()
declare ptr @csec_string_builder_finish()
declare ptr @csec_string_builder_write_to_file()
declare ptr @csec_llvm_string_literal_bytes()
declare ptr @csec_llvm_string_literal_byte_length()
declare ptr @csec_enclosing_function_decl_start()
declare ptr @csec_enclosing_function_body_start()
declare ptr @csec_enclosing_function_body_end()
declare ptr @csec_llvm_lexer_helper_definition()
declare i32 @csec_parse_return_integer_in_range(ptr, i32, i32)

define i32 @parseReturnIntegerInRange(ptr %arg.tokens, i32 %arg.start, i32 %arg.end) {
entry:
  %ret = call i32 @csec_parse_return_integer_in_range(ptr %arg.tokens, i32 %arg.start, i32 %arg.end)
  ret i32 %ret
}

define ptr @appendCExpression(ptr %arg.tokens, i32 %arg.start, i32 %arg.rawEnd) {
entry:
  %ret = call ptr @csec_generate_c_expression(ptr %arg.tokens, i32 %arg.start, i32 %arg.rawEnd)
  ret ptr %ret
}

declare ptr @csec_c_type_name(ptr)

define ptr @cTypeName(ptr %arg.typeName) {
entry:
  %ret = call ptr @csec_c_type_name(ptr %arg.typeName)
  ret ptr %ret
}

define ptr @generateCBody(ptr %arg.tokens, i32 %arg.bodyStart, i32 %arg.bodyEnd, ptr %arg.indent) {
entry:
  %ret = call ptr @csec_generate_c_body(ptr %arg.tokens, i32 %arg.bodyStart, i32 %arg.bodyEnd, ptr %arg.indent)
  ret ptr %ret
}

@.str.c.statement.empty = private unnamed_addr constant [1 x i8] c"\00"

define ptr @generateCStatement(ptr %arg.tokens, i32 %arg.start, i32 %arg.end, ptr %arg.indent) {
entry:
  ret ptr @.str.c.statement.empty
}

define i32 @parseMainReturnInt(ptr %arg.tokens) {
entry:
  ret i32 0
}

define ptr @generateMainExecutionC(ptr %arg.tokens) {
entry:
  ret ptr null
}

define ptr @irTypeName(ptr %arg.typeName) {
entry:
  %ret = call ptr @csec_ir_type_name(ptr %arg.typeName)
  ret ptr %ret
}

define ptr @irOperatorName(ptr %arg.text) {
entry:
  %ret = call ptr @csec_ir_operator_name(ptr %arg.text)
  ret ptr %ret
}

define i32 @expressionTopLevelOperator(ptr %arg.tokens, i32 %arg.start, i32 %arg.end) {
entry:
  %ret = call i32 @csec_expression_top_level_operator(ptr %arg.tokens, i32 %arg.start, i32 %arg.end)
  ret i32 %ret
}

define ptr @generateIRExpression(ptr %arg.tokens, i32 %arg.rawStart, i32 %arg.rawEnd) {
entry:
  %start = call i32 @skipTrivia(ptr %arg.tokens, i32 %arg.rawStart)
  %end = call i32 @trimExpressionEnd(ptr %arg.tokens, i32 %start, i32 %arg.rawEnd)
  %nonempty = icmp sgt i32 %end, %start
  br i1 %nonempty, label %classify, label %empty
empty:
  %empty.value = getelementptr inbounds [5 x i8], ptr @.str.ir.expr.void, i32 0, i32 0
  ret ptr %empty.value
classify:
  %type.name = call ptr @inferExpressionType(ptr %arg.tokens, i32 %start, i32 %end)
  %ir.type = call ptr @irTypeName(ptr %type.name)
  %op = call i32 @expressionTopLevelOperator(ptr %arg.tokens, i32 %start, i32 %end)
  %has.op = icmp sgt i32 %op, %start
  br i1 %has.op, label %binary, label %identifier.check
binary:
  %op.text = call ptr @csec_token_text_at(ptr %arg.tokens, i32 %op)
  %op.name = call ptr @irOperatorName(ptr %op.text)
  %b1 = call ptr @csec_string_concat(ptr %op.name, ptr @.str.ir.expr.space)
  %b2 = call ptr @csec_string_concat(ptr %b1, ptr %ir.type)
  %b3 = call ptr @csec_string_concat(ptr %b2, ptr @.str.ir.expr.open)
  %left = call ptr @appendExpressionUntil(ptr %arg.tokens, i32 %start, i32 %op)
  %b4 = call ptr @csec_string_concat(ptr %b3, ptr %left)
  %b5 = call ptr @csec_string_concat(ptr %b4, ptr @.str.ir.expr.middle)
  %right.start = add i32 %op, 1
  %right = call ptr @appendExpressionUntil(ptr %arg.tokens, i32 %right.start, i32 %end)
  %b6 = call ptr @csec_string_concat(ptr %b5, ptr %right)
  %b7 = call ptr @csec_string_concat(ptr %b6, ptr @.str.ir.expr.close)
  ret ptr %b7
identifier.check:
  %kind = call i8 @csec_token_kind_at(ptr %arg.tokens, i32 %start)
  %is.identifier = icmp eq i8 %kind, 73
  br i1 %is.identifier, label %call.check, label %fallback
call.check:
  %next = add i32 %start, 1
  %before.end = icmp slt i32 %next, %end
  br i1 %before.end, label %open.check, label %single.check
open.check:
  %is.open.raw = call i32 @csec_token_is(ptr %arg.tokens, i32 %next, i8 79, ptr @.str.ir.expr.paren.open)
  %is.open = icmp ne i32 %is.open.raw, 0
  br i1 %is.open, label %close.check, label %single.check
close.check:
  %close = call i32 @findClosingToken(ptr %arg.tokens, i32 %next, i32 %end, ptr @.str.ir.expr.paren.open, ptr @.str.ir.expr.paren.close)
  %last = sub i32 %end, 1
  %is.call = icmp eq i32 %close, %last
  br i1 %is.call, label %call, label %single.check
call:
  %c1 = call ptr @csec_string_concat(ptr @.str.ir.expr.call, ptr %ir.type)
  %c2 = call ptr @csec_string_concat(ptr %c1, ptr @.str.ir.expr.at)
  %name = call ptr @csec_token_text_at(ptr %arg.tokens, i32 %start)
  %c3 = call ptr @csec_string_concat(ptr %c2, ptr %name)
  %c4 = call ptr @csec_string_concat(ptr %c3, ptr @.str.ir.expr.paren.open)
  %args.start = add i32 %start, 2
  %args = call ptr @appendExpressionUntil(ptr %arg.tokens, i32 %args.start, i32 %last)
  %c5 = call ptr @csec_string_concat(ptr %c4, ptr %args)
  %c6 = call ptr @csec_string_concat(ptr %c5, ptr @.str.ir.expr.paren.close)
  ret ptr %c6
single.check:
  %single.end = add i32 %start, 1
  %is.single = icmp eq i32 %end, %single.end
  br i1 %is.single, label %single, label %fallback
single:
  %s1 = call ptr @csec_string_concat(ptr @.str.ir.expr.load, ptr %ir.type)
  %s2 = call ptr @csec_string_concat(ptr %s1, ptr @.str.ir.expr.load.middle)
  %single.name = call ptr @csec_token_text_at(ptr %arg.tokens, i32 %start)
  %s3 = call ptr @csec_string_concat(ptr %s2, ptr %single.name)
  ret ptr %s3
fallback:
  %f1 = call ptr @csec_string_concat(ptr %ir.type, ptr @.str.ir.expr.space)
  %f2 = call ptr @appendExpressionUntil(ptr %arg.tokens, i32 %start, i32 %end)
  %f3 = call ptr @csec_string_concat(ptr %f1, ptr %f2)
  ret ptr %f3
}

@.str.ir.expr.void = private unnamed_addr constant [5 x i8] c"void\00"
@.str.ir.expr.space = private unnamed_addr constant [2 x i8] c" \00"
@.str.ir.expr.open = private unnamed_addr constant [3 x i8] c" (\00"
@.str.ir.expr.middle = private unnamed_addr constant [5 x i8] c"), (\00"
@.str.ir.expr.close = private unnamed_addr constant [2 x i8] c")\00"
@.str.ir.expr.paren.open = private unnamed_addr constant [2 x i8] c"(\00"
@.str.ir.expr.paren.close = private unnamed_addr constant [2 x i8] c")\00"
@.str.ir.expr.call = private unnamed_addr constant [6 x i8] c"call \00"
@.str.ir.expr.at = private unnamed_addr constant [2 x i8] c"@\00"
@.str.ir.expr.load = private unnamed_addr constant [6 x i8] c"load \00"
@.str.ir.expr.load.middle = private unnamed_addr constant [8 x i8] c", ptr %\00"

define ptr @generateIRAssignment(ptr %arg.tokens, i32 %arg.start, i32 %arg.end) {
entry:
  %op = call i32 @findTopLevelOperator(ptr %arg.tokens, i32 %arg.start, i32 %arg.end, i32 1)
  %valid.op = icmp sgt i32 %op, %arg.start
  br i1 %valid.op, label %kind, label %invalid
kind:
  %kind.value = call i8 @csec_token_kind_at(ptr %arg.tokens, i32 %arg.start)
  %is.identifier = icmp eq i8 %kind.value, 73
  br i1 %is.identifier, label %assignment, label %invalid
assignment:
  %name = call ptr @csec_token_text_at(ptr %arg.tokens, i32 %arg.start)
  %op.text = call ptr @csec_token_text_at(ptr %arg.tokens, i32 %op)
  %rhs.start = add i32 %op, 1
  %rhs = call ptr @generateIRExpression(ptr %arg.tokens, i32 %rhs.start, i32 %arg.end)
  %equals.raw = call i32 @csec_string_equals(ptr %op.text, ptr @.str.ir.assign.equals)
  %left.raw = call i32 @csec_string_equals(ptr %op.text, ptr @.str.ir.assign.left)
  %equals = icmp ne i32 %equals.raw, 0
  %left = icmp ne i32 %left.raw, 0
  %is.store = or i1 %equals, %left
  br i1 %is.store, label %store, label %compound
store:
  %s1 = call ptr @csec_string_concat(ptr @.str.ir.assign.store, ptr %rhs)
  %s2 = call ptr @csec_string_concat(ptr %s1, ptr @.str.ir.assign.ptr)
  %s3 = call ptr @csec_string_concat(ptr %s2, ptr %name)
  %s4 = call ptr @csec_string_concat(ptr %s3, ptr @.str.ir.assign.nl)
  ret ptr %s4
compound:
  %type.name = call ptr @inferExpressionType(ptr %arg.tokens, i32 %rhs.start, i32 %arg.end)
  %ir.type = call ptr @irTypeName(ptr %type.name)
  %operator = call ptr @csec_string_substring(ptr %op.text, i32 0, i32 1)
  %binary = call ptr @irOperatorName(ptr %operator)
  %a1 = call ptr @csec_string_concat(ptr @.str.ir.assign.old, ptr %name)
  %a2 = call ptr @csec_string_concat(ptr %a1, ptr @.str.ir.assign.load)
  %a3 = call ptr @csec_string_concat(ptr %a2, ptr %ir.type)
  %a4 = call ptr @csec_string_concat(ptr %a3, ptr @.str.ir.assign.ptr)
  %a5 = call ptr @csec_string_concat(ptr %a4, ptr %name)
  %a6 = call ptr @csec_string_concat(ptr %a5, ptr @.str.ir.assign.nl)
  %b1 = call ptr @csec_string_concat(ptr @.str.ir.assign.new, ptr %name)
  %b2 = call ptr @csec_string_concat(ptr %b1, ptr @.str.ir.assign.eqspace)
  %b3 = call ptr @csec_string_concat(ptr %b2, ptr %binary)
  %b4 = call ptr @csec_string_concat(ptr %b3, ptr @.str.ir.expr.space)
  %b5 = call ptr @csec_string_concat(ptr %b4, ptr %ir.type)
  %b6 = call ptr @csec_string_concat(ptr %b5, ptr @.str.ir.assign.oldref)
  %b7 = call ptr @csec_string_concat(ptr %b6, ptr %name)
  %b8 = call ptr @csec_string_concat(ptr %b7, ptr @.str.ir.expr.middle)
  %trimmed = call i32 @trimExpressionEnd(ptr %arg.tokens, i32 %rhs.start, i32 %arg.end)
  %raw = call ptr @appendExpressionUntil(ptr %arg.tokens, i32 %rhs.start, i32 %trimmed)
  %b9 = call ptr @csec_string_concat(ptr %b8, ptr %raw)
  %b10 = call ptr @csec_string_concat(ptr %b9, ptr @.str.ir.expr.close)
  %b11 = call ptr @csec_string_concat(ptr %b10, ptr @.str.ir.assign.nl)
  %c1 = call ptr @csec_string_concat(ptr @.str.ir.assign.store, ptr %ir.type)
  %c2 = call ptr @csec_string_concat(ptr %c1, ptr @.str.ir.assign.newref)
  %c3 = call ptr @csec_string_concat(ptr %c2, ptr %name)
  %c4 = call ptr @csec_string_concat(ptr %c3, ptr @.str.ir.assign.ptr)
  %c5 = call ptr @csec_string_concat(ptr %c4, ptr %name)
  %c6 = call ptr @csec_string_concat(ptr %c5, ptr @.str.ir.assign.nl)
  %result1 = call ptr @csec_string_concat(ptr %a6, ptr %b11)
  %result2 = call ptr @csec_string_concat(ptr %result1, ptr %c6)
  ret ptr %result2
invalid:
  ret ptr @.str.ir.assign.empty
}

@.str.ir.assign.empty = private unnamed_addr constant [1 x i8] c"\00"
@.str.ir.assign.equals = private unnamed_addr constant [2 x i8] c"=\00"
@.str.ir.assign.left = private unnamed_addr constant [3 x i8] c"<-\00"
@.str.ir.assign.store = private unnamed_addr constant [11 x i8] c"    store \00"
@.str.ir.assign.ptr = private unnamed_addr constant [8 x i8] c", ptr %\00"
@.str.ir.assign.nl = private unnamed_addr constant [2 x i8] c"\0A\00"
@.str.ir.assign.old = private unnamed_addr constant [10 x i8] c"    %old.\00"
@.str.ir.assign.load = private unnamed_addr constant [9 x i8] c" = load \00"
@.str.ir.assign.new = private unnamed_addr constant [10 x i8] c"    %new.\00"
@.str.ir.assign.eqspace = private unnamed_addr constant [4 x i8] c" = \00"
@.str.ir.assign.oldref = private unnamed_addr constant [7 x i8] c" %old.\00"
@.str.ir.assign.newref = private unnamed_addr constant [7 x i8] c" %new.\00"

define ptr @generateIRParamList(ptr %arg.tokens, i32 %arg.declStart) {
entry:
  %ret = call ptr @csec_function_llvm_param_list(ptr %arg.tokens, i32 %arg.declStart)
  ret ptr %ret
}

@.str.ir.flat.body.empty = private unnamed_addr constant [1 x i8] c"\00"

define ptr @generateIRFlatBody(ptr %arg.tokens, i32 %arg.bodyStart, i32 %arg.bodyEnd) {
entry:
  ret ptr @.str.ir.flat.body.empty
}

define ptr @generateIRElseFlatBody(ptr %arg.tokens, i32 %arg.possibleElse, i32 %arg.end, i1 %arg.hasElse) {
entry:
  br i1 %arg.hasElse, label %else.entry, label %no.else
no.else:
  ret ptr @.str.ir.else.none
else.entry:
  %after.else = add i32 %arg.possibleElse, 1
  %else.body.start = call i32 @skipTrivia(ptr %arg.tokens, i32 %after.else)
  %brace.raw = call i32 @csec_token_is(ptr %arg.tokens, i32 %else.body.start, i8 79, ptr @.str.ir.else.open)
  %brace = icmp ne i32 %brace.raw, 0
  br i1 %brace, label %brace.body, label %if.check
brace.body:
  %else.end = call i32 @findClosingToken(ptr %arg.tokens, i32 %else.body.start, i32 %arg.end, ptr @.str.ir.else.open, ptr @.str.ir.else.close)
  %valid = icmp sgt i32 %else.end, %else.body.start
  br i1 %valid, label %flat, label %malformed
flat:
  %body.start = add i32 %else.body.start, 1
  %ret.flat = call ptr @generateIRFlatBody(ptr %arg.tokens, i32 %body.start, i32 %else.end)
  ret ptr %ret.flat
if.check:
  %if.raw = call i32 @csec_token_is(ptr %arg.tokens, i32 %else.body.start, i8 75, ptr @.str.ir.else.if)
  %is.if = icmp ne i32 %if.raw, 0
  br i1 %is.if, label %else.if, label %malformed
else.if:
  ret ptr @.str.ir.else.if.body
malformed:
  ret ptr @.str.ir.else.malformed
}

@.str.ir.else.none = private unnamed_addr constant [20 x i8] c"    ; no else body\0A\00"
@.str.ir.else.open = private unnamed_addr constant [2 x i8] c"{\00"
@.str.ir.else.close = private unnamed_addr constant [2 x i8] c"}\00"
@.str.ir.else.if = private unnamed_addr constant [3 x i8] c"if\00"
@.str.ir.else.if.body = private unnamed_addr constant [20 x i8] c"    ; else-if body\0A\00"
@.str.ir.else.malformed = private unnamed_addr constant [27 x i8] c"    ; malformed else body\0A\00"

define ptr @generateIRIf(ptr %arg.tokens, i32 %arg.start, i32 %arg.end) {
entry:
  %open = call i32 @findStatementParenStart(ptr %arg.tokens, i32 %arg.start, i32 %arg.end)
  %close = call i32 @findStatementParenEnd(ptr %arg.tokens, i32 %arg.start, i32 %arg.end)
  %then.open = call i32 @findStatementBlockStart(ptr %arg.tokens, i32 %arg.start, i32 %arg.end)
  %then.close = call i32 @findClosingToken(ptr %arg.tokens, i32 %then.open, i32 %arg.end, ptr @.str.ir.if.brace.open, ptr @.str.ir.if.brace.close)
  %open.ok = icmp sge i32 %open, 0
  %close.ok = icmp sgt i32 %close, %open
  %then.open.ok = icmp sge i32 %then.open, 0
  %then.close.ok = icmp sgt i32 %then.close, %then.open
  %ok.1 = and i1 %open.ok, %close.ok
  %ok.2 = and i1 %then.open.ok, %then.close.ok
  %ok = and i1 %ok.1, %ok.2
  br i1 %ok, label %build, label %malformed
malformed:
  ret ptr @.str.ir.if.malformed
build:
  %seed.i64 = sext i32 %arg.start to i64
  %seed = call ptr @csec_to_string_i64(i64 %seed.i64)
  %after.then = add i32 %then.close, 1
  %possible.else = call i32 @skipTrivia(ptr %arg.tokens, i32 %after.then)
  %before.end = icmp slt i32 %possible.else, %arg.end
  br i1 %before.end, label %else.test, label %else.none
else.test:
  %else.raw = call i32 @csec_token_is(ptr %arg.tokens, i32 %possible.else, i8 75, ptr @.str.ir.if.else.keyword)
  %else.bool = icmp ne i32 %else.raw, 0
  br label %else.join
else.none:
  br label %else.join
else.join:
  %has.else = phi i1 [ %else.bool, %else.test ], [ false, %else.none ]
  %expr.start = add i32 %open, 1
  %condition = call ptr @generateIRExpression(ptr %arg.tokens, i32 %expr.start, i32 %close)
  %then.start = add i32 %then.open, 1
  %then.body = call ptr @generateIRFlatBody(ptr %arg.tokens, i32 %then.start, i32 %then.close)
  %else.body = call ptr @generateIRElseFlatBody(ptr %arg.tokens, i32 %possible.else, i32 %arg.end, i1 %has.else)
  %a1 = call ptr @csec_string_concat(ptr @.str.ir.if.cond, ptr %seed)
  %a2 = call ptr @csec_string_concat(ptr %a1, ptr @.str.ir.if.equals)
  %a3 = call ptr @csec_string_concat(ptr %a2, ptr %condition)
  %a4 = call ptr @csec_string_concat(ptr %a3, ptr @.str.ir.if.newline)
  %a5 = call ptr @csec_string_concat(ptr %a4, ptr @.str.ir.if.branch)
  %a6 = call ptr @csec_string_concat(ptr %a5, ptr %seed)
  %a7 = call ptr @csec_string_concat(ptr %a6, ptr @.str.ir.if.then)
  %a8 = call ptr @csec_string_concat(ptr %a7, ptr %seed)
  %a9 = call ptr @csec_string_concat(ptr %a8, ptr @.str.ir.if.else)
  %a10 = call ptr @csec_string_concat(ptr %a9, ptr %seed)
  %a11 = call ptr @csec_string_concat(ptr %a10, ptr @.str.ir.if.colon)
  %a12 = call ptr @csec_string_concat(ptr %a11, ptr %then.body)
  %a13 = call ptr @csec_string_concat(ptr %a12, ptr @.str.ir.if.end.branch)
  %a14 = call ptr @csec_string_concat(ptr %a13, ptr %seed)
  %a15 = call ptr @csec_string_concat(ptr %a14, ptr @.str.ir.if.newline)
  %a16 = call ptr @csec_string_concat(ptr %a15, ptr @.str.ir.if.else.label)
  %a17 = call ptr @csec_string_concat(ptr %a16, ptr %seed)
  %a18 = call ptr @csec_string_concat(ptr %a17, ptr @.str.ir.if.colon)
  %a19 = call ptr @csec_string_concat(ptr %a18, ptr %else.body)
  %a20 = call ptr @csec_string_concat(ptr %a19, ptr @.str.ir.if.end.branch)
  %a21 = call ptr @csec_string_concat(ptr %a20, ptr %seed)
  %a22 = call ptr @csec_string_concat(ptr %a21, ptr @.str.ir.if.newline)
  %a23 = call ptr @csec_string_concat(ptr %a22, ptr @.str.ir.if.end.label)
  %a24 = call ptr @csec_string_concat(ptr %a23, ptr %seed)
  %ret = call ptr @csec_string_concat(ptr %a24, ptr @.str.ir.if.colon)
  ret ptr %ret
}

@.str.ir.if.malformed = private unnamed_addr constant [20 x i8] c"    ; malformed if\0A\00"
@.str.ir.if.brace.open = private unnamed_addr constant [2 x i8] c"{\00"
@.str.ir.if.brace.close = private unnamed_addr constant [2 x i8] c"}\00"
@.str.ir.if.else.keyword = private unnamed_addr constant [5 x i8] c"else\00"
@.str.ir.if.cond = private unnamed_addr constant [11 x i8] c"    %cond.\00"
@.str.ir.if.equals = private unnamed_addr constant [4 x i8] c" = \00"
@.str.ir.if.newline = private unnamed_addr constant [2 x i8] c"\0A\00"
@.str.ir.if.branch = private unnamed_addr constant [17 x i8] c"    br i1 %cond.\00"
@.str.ir.if.then = private unnamed_addr constant [18 x i8] c", label %if.then.\00"
@.str.ir.if.else = private unnamed_addr constant [18 x i8] c", label %if.else.\00"
@.str.ir.if.colon = private unnamed_addr constant [3 x i8] c":\0A\00"
@.str.ir.if.end.branch = private unnamed_addr constant [22 x i8] c"    br label %if.end.\00"
@.str.ir.if.else.label = private unnamed_addr constant [9 x i8] c"if.else.\00"
@.str.ir.if.end.label = private unnamed_addr constant [8 x i8] c"if.end.\00"
define ptr @generateIRWhile(ptr %arg.tokens, i32 %arg.start, i32 %arg.end) {
entry:
  %open = call i32 @findStatementParenStart(ptr %arg.tokens, i32 %arg.start, i32 %arg.end)
  %close = call i32 @findStatementParenEnd(ptr %arg.tokens, i32 %arg.start, i32 %arg.end)
  %body.open = call i32 @findStatementBlockStart(ptr %arg.tokens, i32 %arg.start, i32 %arg.end)
  %body.close = call i32 @findClosingToken(ptr %arg.tokens, i32 %body.open, i32 %arg.end, ptr @.str.ir.while.brace.open, ptr @.str.ir.while.brace.close)
  %open.ok = icmp sge i32 %open, 0
  %close.ok = icmp sgt i32 %close, %open
  %body.open.ok = icmp sge i32 %body.open, 0
  %body.close.ok = icmp sgt i32 %body.close, %body.open
  %ok.1 = and i1 %open.ok, %close.ok
  %ok.2 = and i1 %body.open.ok, %body.close.ok
  %ok = and i1 %ok.1, %ok.2
  br i1 %ok, label %build, label %bad
bad:
  ret ptr @.str.ir.while.bad
build:
  %seed.i64 = sext i32 %arg.start to i64
  %seed = call ptr @csec_to_string_i64(i64 %seed.i64)
  %expr.start = add i32 %open, 1
  %expr = call ptr @generateIRExpression(ptr %arg.tokens, i32 %expr.start, i32 %close)
  %body.start = add i32 %body.open, 1
  %body = call ptr @generateIRFlatBody(ptr %arg.tokens, i32 %body.start, i32 %body.close)
  %a1 = call ptr @csec_string_concat(ptr @.str.ir.while.branch, ptr %seed)
  %a2 = call ptr @csec_string_concat(ptr %a1, ptr @.str.ir.while.nl)
  %a3 = call ptr @csec_string_concat(ptr %a2, ptr @.str.ir.while.cond.label)
  %a4 = call ptr @csec_string_concat(ptr %a3, ptr %seed)
  %a5 = call ptr @csec_string_concat(ptr %a4, ptr @.str.ir.while.colon)
  %a6 = call ptr @csec_string_concat(ptr %a5, ptr @.str.ir.while.value)
  %a7 = call ptr @csec_string_concat(ptr %a6, ptr %seed)
  %a8 = call ptr @csec_string_concat(ptr %a7, ptr @.str.ir.while.equals)
  %a9 = call ptr @csec_string_concat(ptr %a8, ptr %expr)
  %a10 = call ptr @csec_string_concat(ptr %a9, ptr @.str.ir.while.nl)
  %a11 = call ptr @csec_string_concat(ptr %a10, ptr @.str.ir.while.test)
  %a12 = call ptr @csec_string_concat(ptr %a11, ptr %seed)
  %a13 = call ptr @csec_string_concat(ptr %a12, ptr @.str.ir.while.body.label)
  %a14 = call ptr @csec_string_concat(ptr %a13, ptr %seed)
  %a15 = call ptr @csec_string_concat(ptr %a14, ptr @.str.ir.while.end.label)
  %a16 = call ptr @csec_string_concat(ptr %a15, ptr %seed)
  %a17 = call ptr @csec_string_concat(ptr %a16, ptr @.str.ir.while.nl)
  %a18 = call ptr @csec_string_concat(ptr %a17, ptr @.str.ir.while.body.name)
  %a19 = call ptr @csec_string_concat(ptr %a18, ptr %seed)
  %a20 = call ptr @csec_string_concat(ptr %a19, ptr @.str.ir.while.colon)
  %a21 = call ptr @csec_string_concat(ptr %a20, ptr %body)
  %a22 = call ptr @csec_string_concat(ptr %a21, ptr @.str.ir.while.branch)
  %a23 = call ptr @csec_string_concat(ptr %a22, ptr %seed)
  %a24 = call ptr @csec_string_concat(ptr %a23, ptr @.str.ir.while.nl)
  %a25 = call ptr @csec_string_concat(ptr %a24, ptr @.str.ir.while.end.name)
  %a26 = call ptr @csec_string_concat(ptr %a25, ptr %seed)
  %ret = call ptr @csec_string_concat(ptr %a26, ptr @.str.ir.while.colon)
  ret ptr %ret
}

@.str.ir.while.bad = private unnamed_addr constant [23 x i8] c"    ; malformed while\0A\00"
@.str.ir.while.brace.open = private unnamed_addr constant [2 x i8] c"{\00"
@.str.ir.while.brace.close = private unnamed_addr constant [2 x i8] c"}\00"
@.str.ir.while.branch = private unnamed_addr constant [26 x i8] c"    br label %while.cond.\00"
@.str.ir.while.nl = private unnamed_addr constant [2 x i8] c"\0A\00"
@.str.ir.while.cond.label = private unnamed_addr constant [12 x i8] c"while.cond.\00"
@.str.ir.while.colon = private unnamed_addr constant [3 x i8] c":\0A\00"
@.str.ir.while.value = private unnamed_addr constant [16 x i8] c"    %whilecond.\00"
@.str.ir.while.equals = private unnamed_addr constant [4 x i8] c" = \00"
@.str.ir.while.test = private unnamed_addr constant [22 x i8] c"    br i1 %whilecond.\00"
@.str.ir.while.body.label = private unnamed_addr constant [21 x i8] c", label %while.body.\00"
@.str.ir.while.end.label = private unnamed_addr constant [20 x i8] c", label %while.end.\00"
@.str.ir.while.body.name = private unnamed_addr constant [12 x i8] c"while.body.\00"
@.str.ir.while.end.name = private unnamed_addr constant [11 x i8] c"while.end.\00"
define ptr @generateIRFor(ptr %arg.tokens, i32 %arg.start, i32 %arg.end) {
entry:
  %open = call i32 @findStatementParenStart(ptr %arg.tokens, i32 %arg.start, i32 %arg.end)
  %close = call i32 @findStatementParenEnd(ptr %arg.tokens, i32 %arg.start, i32 %arg.end)
  %body.open = call i32 @findStatementBlockStart(ptr %arg.tokens, i32 %arg.start, i32 %arg.end)
  %body.close = call i32 @findClosingToken(ptr %arg.tokens, i32 %body.open, i32 %arg.end, ptr @.str.ir.for.brace.open, ptr @.str.ir.for.brace.close)
  %open.ok = icmp sge i32 %open, 0
  %close.ok = icmp sgt i32 %close, %open
  %body.open.ok = icmp sge i32 %body.open, 0
  %body.close.ok = icmp sgt i32 %body.close, %body.open
  %ok.1 = and i1 %open.ok, %close.ok
  %ok.2 = and i1 %body.open.ok, %body.close.ok
  %ok = and i1 %ok.1, %ok.2
  br i1 %ok, label %arrow.find, label %malformed
malformed:
  ret ptr @.str.ir.for.malformed
arrow.find:
  %iterator.index = add i32 %open, 1
  %arrow = call i32 @findTokenTextInRange(ptr %arg.tokens, i32 %iterator.index, i32 %close, ptr @.str.ir.for.arrow)
  %arrow.ok = icmp sge i32 %arrow, 0
  br i1 %arrow.ok, label %build, label %source.malformed
source.malformed:
  ret ptr @.str.ir.for.source.malformed
build:
  %seed.i64 = sext i32 %arg.start to i64
  %seed = call ptr @csec_to_string_i64(i64 %seed.i64)
  %iterator = call ptr @tokenTextAt(ptr %arg.tokens, i32 %iterator.index)
  %expr.start = add i32 %arrow, 1
  %expr = call ptr @generateIRExpression(ptr %arg.tokens, i32 %expr.start, i32 %close)
  %body.start = add i32 %body.open, 1
  %body = call ptr @generateIRFlatBody(ptr %arg.tokens, i32 %body.start, i32 %body.close)
  %a1 = call ptr @csec_string_concat(ptr @.str.ir.for.source, ptr %expr)
  %a2 = call ptr @csec_string_concat(ptr %a1, ptr @.str.ir.for.nl)
  %a3 = call ptr @csec_string_concat(ptr %a2, ptr @.str.ir.for.local)
  %a4 = call ptr @csec_string_concat(ptr %a3, ptr %iterator)
  %a5 = call ptr @csec_string_concat(ptr %a4, ptr @.str.ir.for.alloca)
  %a6 = call ptr @csec_string_concat(ptr %a5, ptr @.str.ir.for.branch)
  %a7 = call ptr @csec_string_concat(ptr %a6, ptr %seed)
  %a8 = call ptr @csec_string_concat(ptr %a7, ptr @.str.ir.for.nl)
  %a9 = call ptr @csec_string_concat(ptr %a8, ptr @.str.ir.for.cond)
  %a10 = call ptr @csec_string_concat(ptr %a9, ptr %seed)
  %a11 = call ptr @csec_string_concat(ptr %a10, ptr @.str.ir.for.colon)
  %a12 = call ptr @csec_string_concat(ptr %a11, ptr @.str.ir.for.next)
  %a13 = call ptr @csec_string_concat(ptr %a12, ptr %iterator)
  %a14 = call ptr @csec_string_concat(ptr %a13, ptr @.str.ir.for.nl)
  %a15 = call ptr @csec_string_concat(ptr %a14, ptr @.str.ir.for.test)
  %a16 = call ptr @csec_string_concat(ptr %a15, ptr %seed)
  %a17 = call ptr @csec_string_concat(ptr %a16, ptr @.str.ir.for.body.label)
  %a18 = call ptr @csec_string_concat(ptr %a17, ptr %seed)
  %a19 = call ptr @csec_string_concat(ptr %a18, ptr @.str.ir.for.end.label)
  %a20 = call ptr @csec_string_concat(ptr %a19, ptr %seed)
  %a21 = call ptr @csec_string_concat(ptr %a20, ptr @.str.ir.for.nl)
  %a22 = call ptr @csec_string_concat(ptr %a21, ptr @.str.ir.for.body)
  %a23 = call ptr @csec_string_concat(ptr %a22, ptr %seed)
  %a24 = call ptr @csec_string_concat(ptr %a23, ptr @.str.ir.for.colon)
  %a25 = call ptr @csec_string_concat(ptr %a24, ptr %body)
  %a26 = call ptr @csec_string_concat(ptr %a25, ptr @.str.ir.for.branch)
  %a27 = call ptr @csec_string_concat(ptr %a26, ptr %seed)
  %a28 = call ptr @csec_string_concat(ptr %a27, ptr @.str.ir.for.nl)
  %a29 = call ptr @csec_string_concat(ptr %a28, ptr @.str.ir.for.end)
  %a30 = call ptr @csec_string_concat(ptr %a29, ptr %seed)
  %ret = call ptr @csec_string_concat(ptr %a30, ptr @.str.ir.for.colon)
  ret ptr %ret
}

@.str.ir.for.malformed = private unnamed_addr constant [21 x i8] c"    ; malformed for\0A\00"
@.str.ir.for.source.malformed = private unnamed_addr constant [28 x i8] c"    ; malformed for source\0A\00"
@.str.ir.for.brace.open = private unnamed_addr constant [2 x i8] c"{\00"
@.str.ir.for.brace.close = private unnamed_addr constant [2 x i8] c"}\00"
@.str.ir.for.arrow = private unnamed_addr constant [3 x i8] c"<-\00"
@.str.ir.for.source = private unnamed_addr constant [18 x i8] c"    ; for source \00"
@.str.ir.for.nl = private unnamed_addr constant [2 x i8] c"\0A\00"
@.str.ir.for.local = private unnamed_addr constant [6 x i8] c"    %\00"
@.str.ir.for.alloca = private unnamed_addr constant [15 x i8] c" = alloca ptr\0A\00"
@.str.ir.for.branch = private unnamed_addr constant [24 x i8] c"    br label %for.cond.\00"
@.str.ir.for.cond = private unnamed_addr constant [10 x i8] c"for.cond.\00"
@.str.ir.for.colon = private unnamed_addr constant [3 x i8] c":\0A\00"
@.str.ir.for.next = private unnamed_addr constant [21 x i8] c"    ; iterator next \00"
@.str.ir.for.test = private unnamed_addr constant [24 x i8] c"    br i1 %for.hasnext.\00"
@.str.ir.for.body.label = private unnamed_addr constant [19 x i8] c", label %for.body.\00"
@.str.ir.for.end.label = private unnamed_addr constant [18 x i8] c", label %for.end.\00"
@.str.ir.for.body = private unnamed_addr constant [10 x i8] c"for.body.\00"
@.str.ir.for.end = private unnamed_addr constant [9 x i8] c"for.end.\00"
@.str.ir.body.empty = private unnamed_addr constant [1 x i8] c"\00"

define ptr @generateIRBody(ptr %arg.tokens, i32 %arg.bodyStart, i32 %arg.bodyEnd) {
entry:
  ret ptr @.str.ir.body.empty
}

@.str.ir.declarations.empty = private unnamed_addr constant [1 x i8] c"\00"

define ptr @generateIRDeclarations(ptr %arg.tokens) {
entry:
  ret ptr @.str.ir.declarations.empty
}

@.str.ir.module.empty = private unnamed_addr constant [1 x i8] c"\00"

define ptr @generateIR(ptr %arg.tokens) {
entry:
  ret ptr @.str.ir.module.empty
}

@.str.llvm.main.body.empty = private unnamed_addr constant [1 x i8] c"\00"

define ptr @generateLLVMMainBody(ptr %arg.tokens) {
entry:
  ret ptr @.str.llvm.main.body.empty
}

define ptr @llvmCharI8Value(ptr %arg.text) {
entry:
  ret ptr null
}

define ptr @llvmI32Value(ptr %arg.tokens, i32 %arg.start, i32 %arg.rawEnd) {
entry:
  ret ptr null
}

define ptr @lookupFunctionParamType(ptr %arg.tokens, i32 %arg.limit, ptr %arg.name) {
entry:
  ret ptr null
}

define ptr @lookupVisibleValueType(ptr %arg.tokens, i32 %arg.limit, ptr %arg.name) {
entry:
  %ret = call ptr @csec_lookup_visible_value_type(ptr %arg.tokens, i32 %arg.limit, ptr %arg.name)
  ret ptr %ret
}

define ptr @lookupVisibleStorageName(ptr %arg.tokens, i32 %arg.limit, ptr %arg.name) {
entry:
  %ret = call ptr @csec_lookup_visible_storage_name(ptr %arg.tokens, i32 %arg.limit, ptr %arg.name)
  ret ptr %ret
}

define ptr @llvmLoadForValueType(ptr %arg.tokens, i32 %arg.limit, ptr %arg.name, ptr %arg.valueType, ptr %arg.resultName) {
entry:
  %storage = call ptr @lookupVisibleStorageName(ptr %arg.tokens, i32 %arg.limit, ptr %arg.name)
  %is.bool = call i1 @strEq(ptr %arg.valueType, ptr @.str.load.type.boolean)
  br i1 %is.bool, label %bool, label %char.check
bool:
  %b1 = call ptr @csec_string_concat(ptr @.str.load.prefix, ptr %arg.resultName)
  %b2 = call ptr @csec_string_concat(ptr %b1, ptr @.str.load.i1)
  %b3 = call ptr @csec_string_concat(ptr %b2, ptr %storage)
  %b4 = call ptr @csec_string_concat(ptr %b3, ptr @.str.load.newline)
  ret ptr %b4
char.check:
  %is.char = call i1 @strEq(ptr %arg.valueType, ptr @.str.load.type.char)
  br i1 %is.char, label %char, label %double.check
char:
  %c1 = call ptr @csec_string_concat(ptr @.str.load.prefix, ptr %arg.resultName)
  %c2 = call ptr @csec_string_concat(ptr %c1, ptr @.str.load.i8)
  %c3 = call ptr @csec_string_concat(ptr %c2, ptr %storage)
  %c4 = call ptr @csec_string_concat(ptr %c3, ptr @.str.load.newline)
  ret ptr %c4
double.check:
  %is.double = call i1 @strEq(ptr %arg.valueType, ptr @.str.load.type.double)
  br i1 %is.double, label %double, label %long.check
double:
  %d1 = call ptr @csec_string_concat(ptr @.str.load.prefix, ptr %arg.resultName)
  %d2 = call ptr @csec_string_concat(ptr %d1, ptr @.str.load.double)
  %d3 = call ptr @csec_string_concat(ptr %d2, ptr %storage)
  %d4 = call ptr @csec_string_concat(ptr %d3, ptr @.str.load.newline)
  ret ptr %d4
long.check:
  %is.long = call i1 @strEq(ptr %arg.valueType, ptr @.str.load.type.long)
  br i1 %is.long, label %long, label %pointer.check
long:
  %l1 = call ptr @csec_string_concat(ptr @.str.load.prefix, ptr %arg.resultName)
  %l2 = call ptr @csec_string_concat(ptr %l1, ptr @.str.load.i64)
  %l3 = call ptr @csec_string_concat(ptr %l2, ptr %storage)
  %l4 = call ptr @csec_string_concat(ptr %l3, ptr @.str.load.newline)
  ret ptr %l4
pointer.check:
  %llvm.type = call ptr @irTypeName(ptr %arg.valueType)
  %is.pointer = call i1 @strEq(ptr %llvm.type, ptr @.str.load.type.ptr)
  br i1 %is.pointer, label %pointer, label %integer
pointer:
  %p1 = call ptr @csec_string_concat(ptr @.str.load.prefix, ptr %arg.resultName)
  %p2 = call ptr @csec_string_concat(ptr %p1, ptr @.str.load.ptr)
  %p3 = call ptr @csec_string_concat(ptr %p2, ptr %storage)
  %p4 = call ptr @csec_string_concat(ptr %p3, ptr @.str.load.newline)
  ret ptr %p4
integer:
  %i1 = call ptr @csec_string_concat(ptr @.str.load.prefix, ptr %arg.resultName)
  %i2 = call ptr @csec_string_concat(ptr %i1, ptr @.str.load.i32)
  %i3 = call ptr @csec_string_concat(ptr %i2, ptr %storage)
  %i4 = call ptr @csec_string_concat(ptr %i3, ptr @.str.load.newline)
  ret ptr %i4
}

@.str.load.type.boolean = private unnamed_addr constant [8 x i8] c"Boolean\00"
@.str.load.type.char = private unnamed_addr constant [5 x i8] c"Char\00"
@.str.load.type.double = private unnamed_addr constant [7 x i8] c"Double\00"
@.str.load.type.long = private unnamed_addr constant [5 x i8] c"Long\00"
@.str.load.type.ptr = private unnamed_addr constant [4 x i8] c"ptr\00"
@.str.load.prefix = private unnamed_addr constant [3 x i8] c"  \00"
@.str.load.i1 = private unnamed_addr constant [18 x i8] c" = load i1, ptr %\00"
@.str.load.i8 = private unnamed_addr constant [18 x i8] c" = load i8, ptr %\00"
@.str.load.double = private unnamed_addr constant [22 x i8] c" = load double, ptr %\00"
@.str.load.i64 = private unnamed_addr constant [19 x i8] c" = load i64, ptr %\00"
@.str.load.ptr = private unnamed_addr constant [19 x i8] c" = load ptr, ptr %\00"
@.str.load.i32 = private unnamed_addr constant [19 x i8] c" = load i32, ptr %\00"
@.str.load.newline = private unnamed_addr constant [2 x i8] c"\0A\00"
define ptr @generateLLVMLoadIfIdentifier(ptr %arg.tokens, i32 %arg.start, i32 %arg.rawEnd) {
entry:
  ret ptr null
}

define ptr @llvmI1Value(ptr %arg.tokens, i32 %arg.start, i32 %arg.rawEnd) {
entry:
  ret ptr null
}

define ptr @generateLLVMLoadBoolIfIdentifier(ptr %arg.tokens, i32 %arg.start, i32 %arg.rawEnd) {
entry:
  ret ptr null
}

define ptr @llvmI32CallArgumentValue(ptr %arg.tokens, i32 %arg.start, i32 %arg.rawEnd, ptr %arg.resultName, i32 %arg.index) {
entry:
  %end = call i32 @trimExpressionEnd(ptr %arg.tokens, i32 %arg.start, i32 %arg.rawEnd)
  %empty = icmp sle i32 %end, %arg.start
  br i1 %empty, label %empty.return, label %integer.check
empty.return:
  ret ptr @.str.i32.callarg.zero
integer.check:
  %kind = call i8 @tokenKindAt(ptr %arg.tokens, i32 %arg.start)
  %integer.kind = call i8 @kindInteger()
  %is.integer = icmp eq i8 %kind, %integer.kind
  %single.end = add i32 %arg.start, 1
  %single = icmp eq i32 %end, %single.end
  %integer = and i1 %is.integer, %single
  br i1 %integer, label %integer.return, label %temporary.return
integer.return:
  %text = call ptr @tokenTextAt(ptr %arg.tokens, i32 %arg.start)
  ret ptr %text
temporary.return:
  %a = call ptr @csec_string_concat(ptr %arg.resultName, ptr @.str.i32.callarg.arg)
  %index.i64 = sext i32 %arg.index to i64
  %index.text = call ptr @csec_to_string_i64(i64 %index.i64)
  %result = call ptr @csec_string_concat(ptr %a, ptr %index.text)
  ret ptr %result
}

@.str.i32.callarg.zero = private unnamed_addr constant [2 x i8] c"0\00"
@.str.i32.callarg.arg = private unnamed_addr constant [5 x i8] c".arg\00"
define ptr @llvmCallArgumentType(ptr %arg.tokens, i32 %arg.start, i32 %arg.rawEnd) {
entry:
  ret ptr null
}

define ptr @llvmCallArgumentValue(ptr %arg.tokens, i32 %arg.start, i32 %arg.rawEnd, ptr %arg.resultName, i32 %arg.index) {
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

@.str.callarg.value.zero = private unnamed_addr constant [2 x i8] c"0\00"
@.str.callarg.value.arg = private unnamed_addr constant [5 x i8] c".arg\00"
define ptr @generateLLVMCallArgumentLoadI32(ptr %arg.tokens, i32 %arg.start, i32 %arg.rawEnd, ptr %arg.resultName) {
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

@.str.callargload.prefix = private unnamed_addr constant [3 x i8] c"  \00"
@.str.callargload.zero = private unnamed_addr constant [3 x i8] c"0\0A\00"
@.str.callargload.gep.left = private unnamed_addr constant [28 x i8] c" = getelementptr inbounds [\00"
@.str.callargload.gep.middle = private unnamed_addr constant [19 x i8] c" x i8], ptr @.str.\00"
@.str.callargload.gep.right = private unnamed_addr constant [16 x i8] c", i32 0, i32 0\0A\00"
@.str.callargload.add.prefix = private unnamed_addr constant [15 x i8] c" = add i32 0, \00"
@.str.callargload.ptr = private unnamed_addr constant [4 x i8] c"ptr\00"
define ptr @generateLLVMCallArgumentLoadsI32(ptr %arg.tokens, i32 %arg.argsStart, i32 %arg.argsEnd, ptr %arg.resultName) {
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

@.str.callargloads.empty = private unnamed_addr constant [1 x i8] c"\00"
@.str.callargloads.arg0 = private unnamed_addr constant [6 x i8] c".arg0\00"
@.str.callargloads.arg1 = private unnamed_addr constant [6 x i8] c".arg1\00"
@.str.callargloads.arg2 = private unnamed_addr constant [6 x i8] c".arg2\00"
@.str.callargloads.arg3 = private unnamed_addr constant [6 x i8] c".arg3\00"
define ptr @generateLLVMCallArgumentListI32(ptr %arg.tokens, i32 %arg.argsStart, i32 %arg.argsEnd, ptr %arg.resultName) {
entry:
  %first = call i32 @skipTrivia(ptr %arg.tokens, i32 %arg.argsStart)
  %end = call i32 @trimExpressionEnd(ptr %arg.tokens, i32 %first, i32 %arg.argsEnd)
  %empty = icmp sge i32 %first, %end
  br i1 %empty, label %empty.return, label %last.find
empty.return:
  ret ptr @.str.callargs.empty
last.find:
  %last = call i32 @findTopLevelOperator(ptr %arg.tokens, i32 %first, i32 %end, i32 12)
  %one = icmp slt i32 %last, %first
  br i1 %one, label %one.return, label %second.find
one.return:
  %one.type = call ptr @llvmCallArgumentType(ptr %arg.tokens, i32 %first, i32 %end)
  %one.value = call ptr @llvmCallArgumentValue(ptr %arg.tokens, i32 %first, i32 %end, ptr %arg.resultName, i32 0)
  %one.join = call ptr @csec_string_concat(ptr %one.type, ptr @.str.callargs.space)
  %one.result = call ptr @csec_string_concat(ptr %one.join, ptr %one.value)
  ret ptr %one.result
second.find:
  %second.comma = call i32 @findTopLevelOperator(ptr %arg.tokens, i32 %first, i32 %last, i32 12)
  %two = icmp slt i32 %second.comma, %first
  br i1 %two, label %two.return, label %first.find
two.return:
  %second.start.raw = add i32 %last, 1
  %second.start = call i32 @skipTrivia(ptr %arg.tokens, i32 %second.start.raw)
  %two.type0 = call ptr @llvmCallArgumentType(ptr %arg.tokens, i32 %first, i32 %last)
  %two.value0 = call ptr @llvmCallArgumentValue(ptr %arg.tokens, i32 %first, i32 %last, ptr %arg.resultName, i32 0)
  %two.type1 = call ptr @llvmCallArgumentType(ptr %arg.tokens, i32 %second.start, i32 %end)
  %two.value1 = call ptr @llvmCallArgumentValue(ptr %arg.tokens, i32 %second.start, i32 %end, ptr %arg.resultName, i32 1)
  %two.a = call ptr @csec_string_concat(ptr %two.type0, ptr @.str.callargs.space)
  %two.b = call ptr @csec_string_concat(ptr %two.a, ptr %two.value0)
  %two.c = call ptr @csec_string_concat(ptr %two.b, ptr @.str.callargs.comma)
  %two.d = call ptr @csec_string_concat(ptr %two.c, ptr %two.type1)
  %two.e = call ptr @csec_string_concat(ptr %two.d, ptr @.str.callargs.space)
  %two.result = call ptr @csec_string_concat(ptr %two.e, ptr %two.value1)
  ret ptr %two.result
first.find:
  %first.comma = call i32 @findTopLevelOperator(ptr %arg.tokens, i32 %first, i32 %second.comma, i32 12)
  %three = icmp slt i32 %first.comma, %first
  br i1 %three, label %three.return, label %four.return
three.return:
  %three.start1.raw = add i32 %second.comma, 1
  %three.start1 = call i32 @skipTrivia(ptr %arg.tokens, i32 %three.start1.raw)
  %three.start2.raw = add i32 %last, 1
  %three.start2 = call i32 @skipTrivia(ptr %arg.tokens, i32 %three.start2.raw)
  %three.type0 = call ptr @llvmCallArgumentType(ptr %arg.tokens, i32 %first, i32 %second.comma)
  %three.value0 = call ptr @llvmCallArgumentValue(ptr %arg.tokens, i32 %first, i32 %second.comma, ptr %arg.resultName, i32 0)
  %three.type1 = call ptr @llvmCallArgumentType(ptr %arg.tokens, i32 %three.start1, i32 %last)
  %three.value1 = call ptr @llvmCallArgumentValue(ptr %arg.tokens, i32 %three.start1, i32 %last, ptr %arg.resultName, i32 1)
  %three.type2 = call ptr @llvmCallArgumentType(ptr %arg.tokens, i32 %three.start2, i32 %end)
  %three.value2 = call ptr @llvmCallArgumentValue(ptr %arg.tokens, i32 %three.start2, i32 %end, ptr %arg.resultName, i32 2)
  %three.a = call ptr @csec_string_concat(ptr %three.type0, ptr @.str.callargs.space)
  %three.b = call ptr @csec_string_concat(ptr %three.a, ptr %three.value0)
  %three.c = call ptr @csec_string_concat(ptr %three.b, ptr @.str.callargs.comma)
  %three.d = call ptr @csec_string_concat(ptr %three.c, ptr %three.type1)
  %three.e = call ptr @csec_string_concat(ptr %three.d, ptr @.str.callargs.space)
  %three.f = call ptr @csec_string_concat(ptr %three.e, ptr %three.value1)
  %three.g = call ptr @csec_string_concat(ptr %three.f, ptr @.str.callargs.comma)
  %three.h = call ptr @csec_string_concat(ptr %three.g, ptr %three.type2)
  %three.i = call ptr @csec_string_concat(ptr %three.h, ptr @.str.callargs.space)
  %three.result = call ptr @csec_string_concat(ptr %three.i, ptr %three.value2)
  ret ptr %three.result
four.return:
  %four.start1.raw = add i32 %first.comma, 1
  %four.start1 = call i32 @skipTrivia(ptr %arg.tokens, i32 %four.start1.raw)
  %four.start2.raw = add i32 %second.comma, 1
  %four.start2 = call i32 @skipTrivia(ptr %arg.tokens, i32 %four.start2.raw)
  %four.start3.raw = add i32 %last, 1
  %four.start3 = call i32 @skipTrivia(ptr %arg.tokens, i32 %four.start3.raw)
  %four.type0 = call ptr @llvmCallArgumentType(ptr %arg.tokens, i32 %first, i32 %first.comma)
  %four.value0 = call ptr @llvmCallArgumentValue(ptr %arg.tokens, i32 %first, i32 %first.comma, ptr %arg.resultName, i32 0)
  %four.type1 = call ptr @llvmCallArgumentType(ptr %arg.tokens, i32 %four.start1, i32 %second.comma)
  %four.value1 = call ptr @llvmCallArgumentValue(ptr %arg.tokens, i32 %four.start1, i32 %second.comma, ptr %arg.resultName, i32 1)
  %four.type2 = call ptr @llvmCallArgumentType(ptr %arg.tokens, i32 %four.start2, i32 %last)
  %four.value2 = call ptr @llvmCallArgumentValue(ptr %arg.tokens, i32 %four.start2, i32 %last, ptr %arg.resultName, i32 2)
  %four.type3 = call ptr @llvmCallArgumentType(ptr %arg.tokens, i32 %four.start3, i32 %end)
  %four.value3 = call ptr @llvmCallArgumentValue(ptr %arg.tokens, i32 %four.start3, i32 %end, ptr %arg.resultName, i32 3)
  %four.a = call ptr @csec_string_concat(ptr %four.type0, ptr @.str.callargs.space)
  %four.b = call ptr @csec_string_concat(ptr %four.a, ptr %four.value0)
  %four.c = call ptr @csec_string_concat(ptr %four.b, ptr @.str.callargs.comma)
  %four.d = call ptr @csec_string_concat(ptr %four.c, ptr %four.type1)
  %four.e = call ptr @csec_string_concat(ptr %four.d, ptr @.str.callargs.space)
  %four.f = call ptr @csec_string_concat(ptr %four.e, ptr %four.value1)
  %four.g = call ptr @csec_string_concat(ptr %four.f, ptr @.str.callargs.comma)
  %four.h = call ptr @csec_string_concat(ptr %four.g, ptr %four.type2)
  %four.i = call ptr @csec_string_concat(ptr %four.h, ptr @.str.callargs.space)
  %four.j = call ptr @csec_string_concat(ptr %four.i, ptr %four.value2)
  %four.k = call ptr @csec_string_concat(ptr %four.j, ptr @.str.callargs.comma)
  %four.l = call ptr @csec_string_concat(ptr %four.k, ptr %four.type3)
  %four.m = call ptr @csec_string_concat(ptr %four.l, ptr @.str.callargs.space)
  %four.result = call ptr @csec_string_concat(ptr %four.m, ptr %four.value3)
  ret ptr %four.result
}

@.str.callargs.empty = private unnamed_addr constant [1 x i8] c"\00"
@.str.callargs.space = private unnamed_addr constant [2 x i8] c" \00"
@.str.callargs.comma = private unnamed_addr constant [3 x i8] c", \00"
define ptr @llvmRuntimeCallName(ptr %arg.name) {
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
define i1 @llvmCallReturnsChar(ptr %arg.tokens, ptr %arg.name) {
entry:
  ret i1 false
}

define ptr @generateLLVMExpressionI32(ptr %arg.tokens, i32 %arg.start, i32 %arg.rawEnd, ptr %arg.resultName) {
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

@.str.expr.i32.prefix = private unnamed_addr constant [3 x i8] c"  \00"
@.str.expr.i32.zero = private unnamed_addr constant [17 x i8] c" = add i32 0, 0\0A\00"
@.str.expr.i32.add = private unnamed_addr constant [15 x i8] c" = add i32 0, \00"
@.str.expr.i32.char = private unnamed_addr constant [5 x i8] c"Char\00"
@.str.expr.i32.char.load = private unnamed_addr constant [18 x i8] c" = load i8, ptr %\00"
@.str.expr.i32.zext = private unnamed_addr constant [12 x i8] c" = zext i8 \00"
@.str.expr.i32.char.to.i32 = private unnamed_addr constant [11 x i8] c".c to i32\0A\00"
@.str.expr.i32.i32.load = private unnamed_addr constant [19 x i8] c" = load i32, ptr %\00"
@.str.expr.i32.dot = private unnamed_addr constant [2 x i8] c".\00"
@.str.expr.i32.length = private unnamed_addr constant [7 x i8] c"length\00"
@.str.expr.i32.charat = private unnamed_addr constant [7 x i8] c"charAt\00"
@.str.expr.i32.open = private unnamed_addr constant [2 x i8] c"(\00"
@.str.expr.i32.close = private unnamed_addr constant [2 x i8] c")\00"
@.str.expr.i32.close.nl = private unnamed_addr constant [3 x i8] c")\0A\00"
@.str.expr.i32.object = private unnamed_addr constant [5 x i8] c".obj\00"
@.str.expr.i32.index = private unnamed_addr constant [7 x i8] c".index\00"
@.str.expr.i32.object.load = private unnamed_addr constant [19 x i8] c" = load ptr, ptr %\00"
@.str.expr.i32.length.call = private unnamed_addr constant [37 x i8] c" = call i64 @csec_string_length(ptr \00"
@.str.expr.i32.trunc = private unnamed_addr constant [14 x i8] c" = trunc i64 \00"
@.str.expr.i32.i64.to.i32 = private unnamed_addr constant [13 x i8] c".i64 to i32\0A\00"
@.str.expr.i32.charat.call = private unnamed_addr constant [37 x i8] c" = call i8 @csec_string_char_at(ptr \00"
@.str.expr.i32.charat.middle = private unnamed_addr constant [7 x i8] c", i32 \00"
@.str.expr.i32.i8.to.i32 = private unnamed_addr constant [12 x i8] c".i8 to i32\0A\00"
@.str.expr.i32.call.i32 = private unnamed_addr constant [14 x i8] c" = call i32 @\00"
@.str.expr.i32.left = private unnamed_addr constant [6 x i8] c".left\00"
@.str.expr.i32.right = private unnamed_addr constant [7 x i8] c".right\00"
@.str.expr.i32.operator.prefix = private unnamed_addr constant [4 x i8] c" = \00"
@.str.expr.i32.operator.middle = private unnamed_addr constant [6 x i8] c" i32 \00"
@.str.expr.i32.operator.comma = private unnamed_addr constant [3 x i8] c", \00"
define ptr @generateLLVMLocalI32(ptr %arg.tokens, i32 %arg.start, i32 %arg.end) {
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
define ptr @llvmI64Value(ptr %arg.tokens, i32 %arg.start, i32 %arg.rawEnd) {
entry:
  ret ptr null
}

define ptr @generateLLVMLoadI64IfIdentifier(ptr %arg.tokens, i32 %arg.start, i32 %arg.rawEnd) {
entry:
  ret ptr null
}

define ptr @generateLLVMExpressionI64(ptr %arg.tokens, i32 %arg.start, i32 %arg.rawEnd, ptr %arg.resultName) {
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

@.str.expr.i64.prefix = private unnamed_addr constant [3 x i8] c"  \00"
@.str.expr.i64.zero = private unnamed_addr constant [17 x i8] c" = add i64 0, 0\0A\00"
@.str.expr.i64.add = private unnamed_addr constant [15 x i8] c" = add i64 0, \00"
@.str.expr.i64.load = private unnamed_addr constant [19 x i8] c" = load i64, ptr %\00"
@.str.expr.i64.open = private unnamed_addr constant [2 x i8] c"(\00"
@.str.expr.i64.close = private unnamed_addr constant [2 x i8] c")\00"
@.str.expr.i64.close.nl = private unnamed_addr constant [3 x i8] c")\0A\00"
@.str.expr.i64.call = private unnamed_addr constant [14 x i8] c" = call i64 @\00"
@.str.expr.i64.left = private unnamed_addr constant [6 x i8] c".left\00"
@.str.expr.i64.right = private unnamed_addr constant [7 x i8] c".right\00"
@.str.expr.i64.operator.prefix = private unnamed_addr constant [4 x i8] c" = \00"
@.str.expr.i64.operator.middle = private unnamed_addr constant [6 x i8] c" i64 \00"
@.str.expr.i64.operator.comma = private unnamed_addr constant [3 x i8] c", \00"
define ptr @generateLLVMLocalI64(ptr %arg.tokens, i32 %arg.start, i32 %arg.end) {
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
define ptr @llvmF64Value(ptr %arg.tokens, i32 %arg.start, i32 %arg.rawEnd) {
entry:
  ret ptr null
}

define ptr @generateLLVMLoadF64IfIdentifier(ptr %arg.tokens, i32 %arg.start, i32 %arg.rawEnd) {
entry:
  ret ptr null
}

define ptr @generateLLVMExpressionF64(ptr %arg.tokens, i32 %arg.start, i32 %arg.rawEnd, ptr %arg.resultName) {
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

@.str.expr.f64.prefix = private unnamed_addr constant [3 x i8] c"  \00"
@.str.expr.f64.zero = private unnamed_addr constant [43 x i8] c" = fadd double 0.000000e+00, 0.000000e+00\0A\00"
@.str.expr.f64.fadd = private unnamed_addr constant [30 x i8] c" = fadd double 0.000000e+00, \00"
@.str.expr.f64.load = private unnamed_addr constant [22 x i8] c" = load double, ptr %\00"
@.str.expr.f64.open = private unnamed_addr constant [2 x i8] c"(\00"
@.str.expr.f64.close = private unnamed_addr constant [2 x i8] c")\00"
@.str.expr.f64.close.nl = private unnamed_addr constant [3 x i8] c")\0A\00"
@.str.expr.f64.call = private unnamed_addr constant [17 x i8] c" = call double @\00"
@.str.expr.f64.add.symbol = private unnamed_addr constant [2 x i8] c"+\00"
@.str.expr.f64.sub.symbol = private unnamed_addr constant [2 x i8] c"-\00"
@.str.expr.f64.mul.symbol = private unnamed_addr constant [2 x i8] c"*\00"
@.str.expr.f64.div.symbol = private unnamed_addr constant [2 x i8] c"/\00"
@.str.expr.f64.fadd.name = private unnamed_addr constant [5 x i8] c"fadd\00"
@.str.expr.f64.fsub.name = private unnamed_addr constant [5 x i8] c"fsub\00"
@.str.expr.f64.fmul.name = private unnamed_addr constant [5 x i8] c"fmul\00"
@.str.expr.f64.fdiv.name = private unnamed_addr constant [5 x i8] c"fdiv\00"
@.str.expr.f64.left = private unnamed_addr constant [6 x i8] c".left\00"
@.str.expr.f64.right = private unnamed_addr constant [7 x i8] c".right\00"
@.str.expr.f64.operator.prefix = private unnamed_addr constant [4 x i8] c" = \00"
@.str.expr.f64.operator.middle = private unnamed_addr constant [9 x i8] c" double \00"
@.str.expr.f64.operator.comma = private unnamed_addr constant [3 x i8] c", \00"
define ptr @generateLLVMLocalF64(ptr %arg.tokens, i32 %arg.start, i32 %arg.end) {
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
define ptr @generateLLVMLocalI8(ptr %arg.tokens, i32 %arg.start, i32 %arg.end) {
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

@.str.local.i8.addr = private unnamed_addr constant [7 x i8] c".addr.\00"
@.str.local.i8.percent = private unnamed_addr constant [2 x i8] c"%\00"
@.str.local.i8.init = private unnamed_addr constant [8 x i8] c".cinit.\00"
@.str.local.i8.prefix = private unnamed_addr constant [4 x i8] c"  %\00"
@.str.local.i8.alloca = private unnamed_addr constant [14 x i8] c" = alloca i8\0A\00"
@.str.local.i8.store = private unnamed_addr constant [12 x i8] c"  store i8 \00"
@.str.local.i8.to = private unnamed_addr constant [8 x i8] c", ptr %\00"
@.str.local.i8.zero = private unnamed_addr constant [20 x i8] c"  store i8 0, ptr %\00"
@.str.local.i8.load = private unnamed_addr constant [18 x i8] c" = load i8, ptr %\00"
@.str.local.i8.dot = private unnamed_addr constant [2 x i8] c".\00"
@.str.local.i8.charat = private unnamed_addr constant [7 x i8] c"charAt\00"
@.str.local.i8.open = private unnamed_addr constant [2 x i8] c"(\00"
@.str.local.i8.close = private unnamed_addr constant [2 x i8] c")\00"
@.str.local.i8.index = private unnamed_addr constant [7 x i8] c".index\00"
@.str.local.i8.object = private unnamed_addr constant [5 x i8] c".obj\00"
@.str.local.i8.object.load = private unnamed_addr constant [19 x i8] c" = load ptr, ptr %\00"
@.str.local.i8.call.prefix = private unnamed_addr constant [37 x i8] c" = call i8 @csec_string_char_at(ptr \00"
@.str.local.i8.call.middle = private unnamed_addr constant [7 x i8] c", i32 \00"
@.str.local.i8.call.at = private unnamed_addr constant [13 x i8] c" = call i8 @\00"
define ptr @generateLLVMAssignmentF64(ptr %arg.tokens, i32 %arg.start, i32 %arg.end) {
entry:
  ret ptr null
}

define ptr @generateLLVMAssignmentPtr(ptr %arg.tokens, i32 %arg.start, i32 %arg.end) {
entry:
  ret ptr null
}

define ptr @generateLLVMAssignmentI8(ptr %arg.tokens, i32 %arg.start, i32 %arg.end) {
entry:
  ret ptr null
}

define ptr @generateLLVMAssignmentI32(ptr %arg.tokens, i32 %arg.start, i32 %arg.end) {
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

@.str.assignment.i32.equals = private unnamed_addr constant [2 x i8] c"=\00"
@.str.assignment.i32.arrow = private unnamed_addr constant [3 x i8] c"<-\00"
@.str.assignment.i32.percent = private unnamed_addr constant [2 x i8] c"%\00"
@.str.assignment.i32.result = private unnamed_addr constant [9 x i8] c".assign.\00"
@.str.assignment.i32.store = private unnamed_addr constant [13 x i8] c"  store i32 \00"
@.str.assignment.i32.to = private unnamed_addr constant [8 x i8] c", ptr %\00"
@.str.assignment.i32.empty = private unnamed_addr constant [1 x i8] c"\00"
define ptr @generateLLVMAssignmentI64(ptr %arg.tokens, i32 %arg.start, i32 %arg.end) {
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

@.str.assignment.i64.equals = private unnamed_addr constant [2 x i8] c"=\00"
@.str.assignment.i64.arrow = private unnamed_addr constant [3 x i8] c"<-\00"
@.str.assignment.i64.percent = private unnamed_addr constant [2 x i8] c"%\00"
@.str.assignment.i64.result = private unnamed_addr constant [10 x i8] c".lassign.\00"
@.str.assignment.i64.store = private unnamed_addr constant [13 x i8] c"  store i64 \00"
@.str.assignment.i64.to = private unnamed_addr constant [8 x i8] c", ptr %\00"
@.str.assignment.i64.empty = private unnamed_addr constant [1 x i8] c"\00"
define ptr @generateLLVMConditionI1(ptr %arg.tokens, i32 %arg.start, i32 %arg.rawEnd, ptr %arg.resultName) {
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

@.str.condition.open = private unnamed_addr constant [2 x i8] c"(\00"
@.str.condition.close = private unnamed_addr constant [2 x i8] c")\00"
@.str.condition.not = private unnamed_addr constant [2 x i8] c"!\00"
@.str.condition.not.name = private unnamed_addr constant [5 x i8] c".not\00"
@.str.condition.prefix = private unnamed_addr constant [3 x i8] c"  \00"
@.str.condition.xor = private unnamed_addr constant [11 x i8] c" = xor i1 \00"
@.str.condition.left = private unnamed_addr constant [10 x i8] c".left.i32\00"
@.str.condition.right = private unnamed_addr constant [11 x i8] c".right.i32\00"
@.str.condition.icmp = private unnamed_addr constant [9 x i8] c" = icmp \00"
@.str.condition.i32 = private unnamed_addr constant [6 x i8] c" i32 \00"
@.str.condition.comma = private unnamed_addr constant [3 x i8] c", \00"
@.str.condition.true = private unnamed_addr constant [5 x i8] c"true\00"
@.str.condition.true.code = private unnamed_addr constant [26 x i8] c" = icmp eq i1 true, true\0A\00"
@.str.condition.false.code = private unnamed_addr constant [27 x i8] c" = icmp eq i1 false, true\0A\00"
@.str.condition.load = private unnamed_addr constant [18 x i8] c" = load i1, ptr %\00"
@.str.condition.call = private unnamed_addr constant [13 x i8] c" = call i1 @\00"
@.str.condition.close.nl = private unnamed_addr constant [3 x i8] c")\0A\00"
@.str.condition.fallback = private unnamed_addr constant [21 x i8] c" = icmp eq i32 0, 0\0A\00"
define ptr @generateLLVMExpressionI1(ptr %arg.tokens, i32 %arg.start, i32 %arg.rawEnd, ptr %arg.resultName) {
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

@.str.expr.i1.prefix = private unnamed_addr constant [3 x i8] c"  \00"
@.str.expr.i1.false = private unnamed_addr constant [27 x i8] c" = icmp eq i1 false, true\0A\00"
@.str.expr.i1.true = private unnamed_addr constant [5 x i8] c"true\00"
@.str.expr.i1.true.code = private unnamed_addr constant [26 x i8] c" = icmp eq i1 true, true\0A\00"
@.str.expr.i1.open = private unnamed_addr constant [2 x i8] c"(\00"
@.str.expr.i1.close = private unnamed_addr constant [2 x i8] c")\00"
@.str.expr.i1.not = private unnamed_addr constant [2 x i8] c"!\00"
@.str.expr.i1.not.name = private unnamed_addr constant [5 x i8] c".not\00"
@.str.expr.i1.xor = private unnamed_addr constant [11 x i8] c" = xor i1 \00"
@.str.expr.i1.not.suffix = private unnamed_addr constant [8 x i8] c", true\0A\00"
@.str.expr.i1.load = private unnamed_addr constant [18 x i8] c" = load i1, ptr %\00"
@.str.expr.i1.left = private unnamed_addr constant [6 x i8] c".left\00"
@.str.expr.i1.right = private unnamed_addr constant [7 x i8] c".right\00"
@.str.expr.i1.or = private unnamed_addr constant [10 x i8] c" = or i1 \00"
@.str.expr.i1.and = private unnamed_addr constant [11 x i8] c" = and i1 \00"
@.str.expr.i1.comma = private unnamed_addr constant [3 x i8] c", \00"
define ptr @generateLLVMLocalI1(ptr %arg.tokens, i32 %arg.start, i32 %arg.end) {
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

@.str.local.i1.addr = private unnamed_addr constant [7 x i8] c".addr.\00"
@.str.local.i1.percent = private unnamed_addr constant [2 x i8] c"%\00"
@.str.local.i1.init = private unnamed_addr constant [8 x i8] c".binit.\00"
@.str.local.i1.prefix = private unnamed_addr constant [4 x i8] c"  %\00"
@.str.local.i1.alloca = private unnamed_addr constant [14 x i8] c" = alloca i1\0A\00"
@.str.local.i1.store = private unnamed_addr constant [12 x i8] c"  store i1 \00"
@.str.local.i1.to = private unnamed_addr constant [8 x i8] c", ptr %\00"
@.str.local.i1.false = private unnamed_addr constant [24 x i8] c"  store i1 false, ptr %\00"
define ptr @generateLLVMAssignmentI1(ptr %arg.tokens, i32 %arg.start, i32 %arg.end) {
entry:
  ret ptr null
}

define i1 @llvmBlockEndsWithTopLevelReturn(ptr %arg.tokens, i32 %arg.bodyStart, i32 %arg.bodyEnd) {
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

@.str.block.return = private unnamed_addr constant [7 x i8] c"return\00"
define ptr @csecGenerateLLVMStringOperand(ptr %arg.tokens, i32 %arg.start, i32 %arg.rawEnd, ptr %arg.resultName) {
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

@.str.expr.ptr.prefix = private unnamed_addr constant [3 x i8] c"  \00"
@.str.expr.ptr.null = private unnamed_addr constant [26 x i8] c" = inttoptr i64 0 to ptr\0A\00"
@.str.expr.ptr.ptr = private unnamed_addr constant [4 x i8] c"ptr\00"
@.str.expr.ptr.char = private unnamed_addr constant [5 x i8] c"Char\00"
@.str.expr.ptr.open = private unnamed_addr constant [2 x i8] c"(\00"
@.str.expr.ptr.close = private unnamed_addr constant [2 x i8] c")\00"
@.str.expr.ptr.close.nl = private unnamed_addr constant [3 x i8] c")\0A\00"
@.str.expr.ptr.dot = private unnamed_addr constant [2 x i8] c".\00"
@.str.expr.ptr.substring = private unnamed_addr constant [10 x i8] c"substring\00"
@.str.expr.ptr.plus = private unnamed_addr constant [2 x i8] c"+\00"
@.str.expr.ptr.i32 = private unnamed_addr constant [5 x i8] c".i32\00"
@.str.expr.ptr.i64 = private unnamed_addr constant [5 x i8] c".i64\00"
@.str.expr.ptr.sext = private unnamed_addr constant [13 x i8] c" = sext i32 \00"
@.str.expr.ptr.to.i64 = private unnamed_addr constant [9 x i8] c" to i64\0A\00"
@.str.expr.ptr.i64.call = private unnamed_addr constant [37 x i8] c" = call ptr @csec_to_string_i64(i64 \00"
@.str.expr.ptr.gep.a = private unnamed_addr constant [28 x i8] c" = getelementptr inbounds [\00"
@.str.expr.ptr.gep.b = private unnamed_addr constant [19 x i8] c" x i8], ptr @.str.\00"
@.str.expr.ptr.gep.c = private unnamed_addr constant [16 x i8] c", i32 0, i32 0\0A\00"
@.str.expr.ptr.load = private unnamed_addr constant [19 x i8] c" = load ptr, ptr %\00"
@.str.expr.ptr.call = private unnamed_addr constant [14 x i8] c" = call ptr @\00"
@.str.expr.ptr.comma = private unnamed_addr constant [2 x i8] c",\00"
@.str.expr.ptr.object = private unnamed_addr constant [5 x i8] c".obj\00"
@.str.expr.ptr.start = private unnamed_addr constant [7 x i8] c".start\00"
@.str.expr.ptr.length = private unnamed_addr constant [8 x i8] c".length\00"
@.str.expr.ptr.object.load = private unnamed_addr constant [19 x i8] c" = load ptr, ptr %\00"
@.str.expr.ptr.substring.call = private unnamed_addr constant [40 x i8] c" = call ptr @csec_string_substring(ptr \00"
@.str.expr.ptr.substring.middle = private unnamed_addr constant [7 x i8] c", i32 \00"
@.str.expr.ptr.left = private unnamed_addr constant [6 x i8] c".left\00"
@.str.expr.ptr.right = private unnamed_addr constant [7 x i8] c".right\00"
@.str.expr.ptr.concat = private unnamed_addr constant [37 x i8] c" = call ptr @csec_string_concat(ptr \00"
@.str.expr.ptr.concat.middle = private unnamed_addr constant [7 x i8] c", ptr \00"
@.str.expr.ptr.char.call = private unnamed_addr constant [37 x i8] c" = call ptr @csec_to_string_char(i8 \00"
@.str.expr.ptr.char.close = private unnamed_addr constant [3 x i8] c")\0A\00"
@.str.expr.ptr.char.load = private unnamed_addr constant [18 x i8] c" = load i8, ptr %\00"
@.str.expr.ptr.char.nl = private unnamed_addr constant [2 x i8] c"\0A\00"
@.str.expr.ptr.char.value.close = private unnamed_addr constant [3 x i8] c")\0A\00"
define ptr @generateLLVMLocalPtr(ptr %arg.tokens, i32 %arg.start, i32 %arg.end) {
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

@.str.local.ptr.addr = private unnamed_addr constant [7 x i8] c".addr.\00"
@.str.local.ptr.percent = private unnamed_addr constant [2 x i8] c"%\00"
@.str.local.ptr.init = private unnamed_addr constant [8 x i8] c".pinit.\00"
@.str.local.ptr.prefix = private unnamed_addr constant [4 x i8] c"  %\00"
@.str.local.ptr.alloca = private unnamed_addr constant [15 x i8] c" = alloca ptr\0A\00"
@.str.local.ptr.store = private unnamed_addr constant [13 x i8] c"  store ptr \00"
@.str.local.ptr.to = private unnamed_addr constant [8 x i8] c", ptr %\00"
@.str.local.ptr.null = private unnamed_addr constant [24 x i8] c"  store ptr null, ptr %\00"
define i1 @llvmExpressionLooksPtr(ptr %arg.tokens, i32 %arg.start, i32 %arg.rawEnd) {
entry:
  ret i1 false
}

declare ptr @csec_generate_llvm_flat_body_i32(ptr, i32, i32)

define ptr @generateLLVMFlatBodyI32(ptr %arg.tokens, i32 %arg.bodyStart, i32 %arg.bodyEnd) {
entry:
  %ret = call ptr @csec_generate_llvm_flat_body_i32(ptr %arg.tokens, i32 %arg.bodyStart, i32 %arg.bodyEnd)
  ret ptr %ret
}

define ptr @generateLLVMIfI32(ptr %arg.tokens, i32 %arg.start, i32 %arg.end) {
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

@.str.llvm.if.bad = private unnamed_addr constant [18 x i8] c"  ; malformed if\0A\00"
@.str.llvm.if.brace.open = private unnamed_addr constant [2 x i8] c"{\00"
@.str.llvm.if.brace.close = private unnamed_addr constant [2 x i8] c"}\00"
@.str.llvm.if.condition.name = private unnamed_addr constant [7 x i8] c"%cond.\00"
@.str.llvm.if.branch = private unnamed_addr constant [15 x i8] c"  br i1 %cond.\00"
@.str.llvm.if.then.label = private unnamed_addr constant [18 x i8] c", label %if.then.\00"
@.str.llvm.if.else.label = private unnamed_addr constant [18 x i8] c", label %if.else.\00"
@.str.llvm.if.nl = private unnamed_addr constant [2 x i8] c"\0A\00"
@.str.llvm.if.then.name = private unnamed_addr constant [9 x i8] c"if.then.\00"
@.str.llvm.if.else.name = private unnamed_addr constant [9 x i8] c"if.else.\00"
@.str.llvm.if.end.name = private unnamed_addr constant [8 x i8] c"if.end.\00"
@.str.llvm.if.colon = private unnamed_addr constant [3 x i8] c":\0A\00"
@.str.llvm.if.end.branch = private unnamed_addr constant [20 x i8] c"  br label %if.end.\00"
define ptr @generateLLVMWhileI32(ptr %arg.tokens, i32 %arg.start, i32 %arg.end) {
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

@.str.llvm.while.bad = private unnamed_addr constant [21 x i8] c"  ; malformed while\0A\00"
@.str.llvm.while.brace.open = private unnamed_addr constant [2 x i8] c"{\00"
@.str.llvm.while.brace.close = private unnamed_addr constant [2 x i8] c"}\00"
@.str.llvm.while.condition.name = private unnamed_addr constant [12 x i8] c"%whilecond.\00"
@.str.llvm.while.initial.branch = private unnamed_addr constant [24 x i8] c"  br label %while.cond.\00"
@.str.llvm.while.condition.label = private unnamed_addr constant [12 x i8] c"while.cond.\00"
@.str.llvm.while.body.label = private unnamed_addr constant [21 x i8] c", label %while.body.\00"
@.str.llvm.while.end.label = private unnamed_addr constant [20 x i8] c", label %while.end.\00"
@.str.llvm.while.body.name = private unnamed_addr constant [12 x i8] c"while.body.\00"
@.str.llvm.while.end.name = private unnamed_addr constant [11 x i8] c"while.end.\00"
@.str.llvm.while.colon = private unnamed_addr constant [3 x i8] c":\0A\00"
@.str.llvm.while.nl = private unnamed_addr constant [2 x i8] c"\0A\00"
@.str.llvm.while.test = private unnamed_addr constant [20 x i8] c"  br i1 %whilecond.\00"
define ptr @generateLLVMForI32(ptr %arg.tokens, i32 %arg.start, i32 %arg.end) {
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

@.str.llvm.for.bad = private unnamed_addr constant [19 x i8] c"  ; malformed for\0A\00"
@.str.llvm.for.brace.open = private unnamed_addr constant [2 x i8] c"{\00"
@.str.llvm.for.brace.close = private unnamed_addr constant [2 x i8] c"}\00"
@.str.llvm.for.arrow = private unnamed_addr constant [3 x i8] c"<-\00"
@.str.llvm.for.to = private unnamed_addr constant [3 x i8] c"to\00"
@.str.llvm.for.dots = private unnamed_addr constant [3 x i8] c"..\00"
@.str.llvm.for.percent = private unnamed_addr constant [2 x i8] c"%\00"
@.str.llvm.for.start = private unnamed_addr constant [7 x i8] c".start\00"
@.str.llvm.for.end = private unnamed_addr constant [5 x i8] c".end\00"
@.str.llvm.for.slt = private unnamed_addr constant [4 x i8] c"slt\00"
@.str.llvm.for.sle = private unnamed_addr constant [4 x i8] c"sle\00"
@.str.llvm.for.alloca.a = private unnamed_addr constant [4 x i8] c"  %\00"
@.str.llvm.for.alloca.b = private unnamed_addr constant [15 x i8] c" = alloca i32\0A\00"
@.str.llvm.for.store.a = private unnamed_addr constant [14 x i8] c"  store i32 %\00"
@.str.llvm.for.store.b = private unnamed_addr constant [8 x i8] c", ptr %\00"
@.str.llvm.for.cond.label = private unnamed_addr constant [22 x i8] c"  br label %for.cond.\00"
@.str.llvm.for.colon = private unnamed_addr constant [3 x i8] c":\0A\00"
@.str.llvm.for.value.a = private unnamed_addr constant [4 x i8] c"  %\00"
@.str.llvm.for.value.b = private unnamed_addr constant [23 x i8] c".val = load i32, ptr %\00"
@.str.llvm.for.compare.a = private unnamed_addr constant [12 x i8] c"  %forcond.\00"
@.str.llvm.for.compare.b = private unnamed_addr constant [9 x i8] c" = icmp \00"
@.str.llvm.for.compare.c = private unnamed_addr constant [7 x i8] c" i32 %\00"
@.str.llvm.for.branch.a = private unnamed_addr constant [8 x i8] c".val, %\00"
@.str.llvm.for.branch.b = private unnamed_addr constant [23 x i8] c".end\0A  br i1 %forcond.\00"
@.str.llvm.for.branch.c = private unnamed_addr constant [19 x i8] c", label %for.body.\00"
@.str.llvm.for.body.label = private unnamed_addr constant [10 x i8] c"for.body.\00"
@.str.llvm.for.end.label = private unnamed_addr constant [9 x i8] c"for.end.\00"
@.str.llvm.for.step.a = private unnamed_addr constant [4 x i8] c"  %\00"
@.str.llvm.for.step.b = private unnamed_addr constant [7 x i8] c".step.\00"
@.str.llvm.for.step.c = private unnamed_addr constant [19 x i8] c" = load i32, ptr %\00"
@.str.llvm.for.step.d = private unnamed_addr constant [5 x i8] c"\0A  %\00"
@.str.llvm.for.step.e = private unnamed_addr constant [7 x i8] c".next.\00"
@.str.llvm.for.step.f = private unnamed_addr constant [13 x i8] c" = add i32 %\00"
@.str.llvm.for.step.g = private unnamed_addr constant [7 x i8] c".step.\00"
@.str.llvm.for.cond.branch = private unnamed_addr constant [18 x i8] c", 1\0A  store i32 %\00"
@.str.llvm.for.nl = private unnamed_addr constant [7 x i8] c".next.\00"
define ptr @generateLLVMReturnI32(ptr %arg.tokens, i32 %arg.bodyStart, i32 %arg.bodyEnd) {
entry:
  ret ptr null
}

define ptr @generateLLVMDottedStatementCall(ptr %arg.tokens, i32 %arg.cursor, i32 %arg.next) {
entry:
  ret ptr null
}

declare ptr @csec_llvm_main_body_fallback()

define ptr @generateLLVMMainBodyFromRange(ptr %arg.tokens, i32 %arg.bodyStart, i32 %arg.bodyEnd) {
entry:
  %ret = call ptr @csec_llvm_main_body_fallback()
  ret ptr %ret
}

define ptr @generateLLVMParamList(ptr %arg.tokens, i32 %arg.declStart) {
entry:
  %ret = call ptr @csec_function_llvm_param_list(ptr %arg.tokens, i32 %arg.declStart)
  ret ptr %ret
}

define ptr @generateLLVMParamListSlow(ptr %arg.tokens, i32 %arg.declStart) {
entry:
  %ret = call ptr @csec_function_llvm_param_list(ptr %arg.tokens, i32 %arg.declStart)
  ret ptr %ret
}

define ptr @generateLLVMParamAllocas(ptr %arg.tokens, i32 %arg.declStart) {
entry:
  %ret = call ptr @csec_function_llvm_param_allocas(ptr %arg.tokens, i32 %arg.declStart)
  ret ptr %ret
}

define ptr @generateLLVMParamAllocasSlow(ptr %arg.tokens, i32 %arg.declStart) {
entry:
  %ret = call ptr @csec_function_llvm_param_allocas(ptr %arg.tokens, i32 %arg.declStart)
  ret ptr %ret
}

declare ptr @csec_llvm_body_fallback(i32)

define ptr @generateLLVMBooleanBodyFromRange(ptr %arg.tokens, i32 %arg.bodyStart, i32 %arg.bodyEnd) {
entry:
  %ret = call ptr @csec_llvm_body_fallback(i32 1)
  ret ptr %ret
}

define ptr @generateLLVMCharBodyFromRange(ptr %arg.tokens, i32 %arg.bodyStart, i32 %arg.bodyEnd) {
entry:
  %ret = call ptr @csec_llvm_body_fallback(i32 2)
  ret ptr %ret
}

define ptr @generateLLVMDoubleBodyFromRange(ptr %arg.tokens, i32 %arg.bodyStart, i32 %arg.bodyEnd) {
entry:
  %ret = call ptr @csec_llvm_body_fallback(i32 3)
  ret ptr %ret
}

define ptr @generateLLVMLongBodyFromRange(ptr %arg.tokens, i32 %arg.bodyStart, i32 %arg.bodyEnd) {
entry:
  %ret = call ptr @csec_llvm_body_fallback(i32 4)
  ret ptr %ret
}

define i32 @llvmStringLiteralByteLength(ptr %arg.text) {
entry:
  %ret = call i32 @csec_llvm_string_literal_byte_length(ptr %arg.text)
  ret i32 %ret
}

define ptr @generateLLVMPointerBodyFromRange(ptr %arg.tokens, i32 %arg.bodyStart, i32 %arg.bodyEnd) {
entry:
  %ret = call ptr @csec_llvm_body_fallback(i32 5)
  ret ptr %ret
}

define ptr @generateLLVMVoidBodyFromRange(ptr %arg.tokens, i32 %arg.bodyStart, i32 %arg.bodyEnd) {
entry:
  ret ptr null
}

define ptr @llvmStringLiteralBytes(ptr %arg.text) {
entry:
  ret ptr null
}

define ptr @generateLLVMStringLiteralGlobals(ptr %arg.tokens) {
entry:
  ret ptr null
}

define ptr @generateLLVMFunctionDefinition(ptr %arg.tokens, i32 %arg.declStart) {
entry:
  ret ptr null
}

declare i32 @csec_generate_llvm_module_into(ptr, i64)

define i32 @generateLLVMModuleInto(ptr %arg.tokens, i64 %arg.builder) {
entry:
  %ret = call i32 @csec_generate_llvm_module_into(ptr %arg.tokens, i64 %arg.builder)
  ret i32 %ret
}

define ptr @generateLLVMModule(ptr %arg.tokens) {
entry:
  %valid = call i1 @parseProgram(ptr %arg.tokens)
  br i1 %valid, label %build, label %empty
build:
  %builder = call i64 @csec_string_builder_new()
  %written = call i32 @generateLLVMModuleInto(ptr %arg.tokens, i64 %builder)
  %result = call ptr @csec_string_builder_finish(i64 %builder)
  ret ptr %result
empty:
  ret ptr null
}

define ptr @generateExecutionC(ptr %arg.tokens) {
entry:
  ret ptr null
}

define ptr @trimAscii(ptr %arg.text) {
entry:
  ret ptr null
}

define i1 @stringEndsWith(ptr %arg.text, ptr %arg.suffix) {
entry:
  ret i1 false
}

define ptr @parentDirectory(ptr %arg.path) {
entry:
  ret ptr null
}

declare ptr @csec_replace_dots_with_slash(ptr)

define ptr @replaceDotsWithSlash(ptr %arg.text) {
entry:
  %ret = call ptr @csec_replace_dots_with_slash(ptr %arg.text)
  ret ptr %ret
}

declare ptr @csec_import_target_from_line(ptr)

define ptr @importTargetFromLine(ptr %arg.line) {
entry:
  %ret = call ptr @csec_import_target_from_line(ptr %arg.line)
  ret ptr %ret
}

declare ptr @csec_import_candidate(ptr)

define ptr @importCandidate(ptr %arg.target) {
entry:
  %ret = call ptr @csec_import_candidate(ptr %arg.target)
  ret ptr %ret
}

declare ptr @csec_resolve_import_path(ptr, ptr)

define ptr @resolveImportPath(ptr %arg.currentPath, ptr %arg.target) {
entry:
  %ret = call ptr @csec_resolve_import_path(ptr %arg.currentPath, ptr %arg.target)
  ret ptr %ret
}

define ptr @expandImportsFromFile(ptr %arg.path, ptr %arg.seen) {
entry:
  %ret = call ptr @csec_expand_imports(ptr %arg.path)
  ret ptr %ret
}

define ptr @compileSource(ptr %arg.source, ptr %arg.mode) {
entry:
  ret ptr null
}

define i32 @compileFile(ptr %arg.inputPath, ptr %arg.outputPath, ptr %arg.mode) {
entry:
  %llvm.raw = call i32 @csec_string_starts_with(ptr %arg.mode, ptr @.str.driver.llvm)
  %llvm = icmp ne i32 %llvm.raw, 0
  br i1 %llvm, label %build, label %unsupported
build:
  %source = call ptr @csec_expand_imports(ptr %arg.inputPath)
  %builder = call i64 @csec_string_builder_new_file(ptr %arg.outputPath)
  %ready = icmp ne i64 %builder, 0
  br i1 %ready, label %generate, label %failed
generate:
  %tokens = call ptr @tokenize(ptr %source)
  %generated = call i32 @generateLLVMModuleInto(ptr %tokens, i64 %builder)
  %success = icmp eq i32 %generated, 0
  br i1 %success, label %write, label %return.generated
write:
  %written = call i32 @csec_string_builder_write_to_file(i64 %builder, ptr %arg.outputPath)
  ret i32 %written
return.generated:
  ret i32 %generated
failed:
  ret i32 1
unsupported:
  ret i32 1
}

@.str.driver.llvm = private unnamed_addr constant [5 x i8] c"llvm\00"

define i32 @main() {
entry:
  ret i32 0
}

