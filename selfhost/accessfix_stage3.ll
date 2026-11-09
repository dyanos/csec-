; ModuleID = 'csec.selfhost'
source_filename = "csec.selfhost"

declare i64 @csec_string_length(ptr)
declare i8 @csec_string_char_at(ptr, i32)

declare i32 @csec_lex_quoted(ptr, i32)
declare i32 @csec_lex_number(ptr, i32)
declare i32 @csec_lex_identifier(ptr, i32)
declare i32 @csec_lex_line_comment(ptr, i32)
declare i32 @csec_lex_block_comment(ptr, i32)
declare i32 @csec_digit_value(i8)
declare i32 @csec_is_keyword(ptr)
declare i32 @csec_to_int(ptr)
declare i32 @csec_line_start(ptr, i32)
declare i32 @csec_line_end(ptr, i32)
declare i32 @csec_validate_balanced(ptr)
declare i32 @csec_starts_top_level_declaration(ptr, i32)
declare i32 @csec_validate_top_level(ptr)
declare ptr @csec_top_level_decl_kind(ptr, i32)
declare ptr @csec_top_level_decl_name(ptr, i32)
declare i32 @csec_count_function_params(ptr, i32)
declare i32 @csec_token_is_top_level_operator(ptr, i32, i32)
declare i32 @csec_find_top_level_operator(ptr, i32, i32, i32)
declare i32 @csec_find_top_level_match(ptr, i32, i32)
declare i32 @csec_find_lambda_arrow(ptr, i32, i32)
declare ptr @csec_generate_symbol_table(ptr)
declare ptr @csec_append_expression_until(ptr, i32, i32)
declare ptr @csec_generate_expression_ast(ptr, i32, i32)
declare ptr @csec_generate_statement_ast(ptr, i32, i32)
declare ptr @csec_generate_body_ast(ptr, i32, i32)
declare i32 @csec_find_function_param_start(ptr, i32)
declare ptr @csec_generate_c_body(ptr, i32, i32, ptr)
declare ptr @csec_ir_operator_name(ptr)
declare i32 @csec_expression_top_level_operator(ptr, i32, i32)
declare i32 @csec_find_token_text_in_range(ptr, i32, i32, ptr)
declare i32 @csec_find_closing_token(ptr, i32, i32, ptr, ptr)
declare i32 @csec_find_statement_paren_start(ptr, i32, i32)
declare i32 @csec_find_statement_paren_end(ptr, i32, i32)
declare i32 @csec_find_statement_block_start(ptr, i32, i32)
declare i32 @csec_find_statement_block_end(ptr, i32, i32)
declare i32 @csec_count_comma_separated(ptr, i32, i32)
declare i32 @csec_find_last_top_level_token(ptr, i32, i32, ptr)
declare ptr @csec_llvm_lexer_helper_definition(ptr)
declare i64 @csec_string_builder_new()
declare i64 @csec_string_builder_new_file(ptr)
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
declare i32 @csec_string_equals(ptr, ptr)
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
declare ptr @csec_llvm_string_literal_bytes(ptr)
declare ptr @csec_function_return_type_at(ptr, i32)
declare i32 @csec_enclosing_function_decl_start(ptr, i32)
declare i32 @csec_enclosing_function_body_start(ptr, i32)
declare i32 @csec_enclosing_function_body_end(ptr, i32)
declare ptr @csec_lookup_function_return_type(ptr, ptr)
declare ptr @csec_expand_imports(ptr)

@.str.332 = private unnamed_addr constant [3 x i8] c"\0D\00"
@.str.585 = private unnamed_addr constant [7 x i8] c"import\00"
@.str.592 = private unnamed_addr constant [6 x i8] c"class\00"
@.str.599 = private unnamed_addr constant [8 x i8] c"extends\00"
@.str.606 = private unnamed_addr constant [7 x i8] c"object\00"
@.str.613 = private unnamed_addr constant [9 x i8] c"external\00"
@.str.620 = private unnamed_addr constant [4 x i8] c"def\00"
@.str.627 = private unnamed_addr constant [9 x i8] c"operator\00"
@.str.634 = private unnamed_addr constant [9 x i8] c"override\00"
@.str.641 = private unnamed_addr constant [7 x i8] c"return\00"
@.str.648 = private unnamed_addr constant [4 x i8] c"val\00"
@.str.655 = private unnamed_addr constant [4 x i8] c"var\00"
@.str.662 = private unnamed_addr constant [3 x i8] c"if\00"
@.str.669 = private unnamed_addr constant [5 x i8] c"else\00"
@.str.676 = private unnamed_addr constant [4 x i8] c"for\00"
@.str.683 = private unnamed_addr constant [6 x i8] c"while\00"
@.str.690 = private unnamed_addr constant [6 x i8] c"match\00"
@.str.697 = private unnamed_addr constant [5 x i8] c"case\00"
@.str.704 = private unnamed_addr constant [4 x i8] c"map\00"
@.str.711 = private unnamed_addr constant [5 x i8] c"pmap\00"
@.str.718 = private unnamed_addr constant [7 x i8] c"filter\00"
@.str.725 = private unnamed_addr constant [7 x i8] c"reduce\00"
@.str.732 = private unnamed_addr constant [8 x i8] c"preduce\00"
@.str.739 = private unnamed_addr constant [9 x i8] c"template\00"
@.str.746 = private unnamed_addr constant [9 x i8] c"typename\00"
@.str.753 = private unnamed_addr constant [4 x i8] c"new\00"
@.str.760 = private unnamed_addr constant [5 x i8] c"this\00"
@.str.767 = private unnamed_addr constant [6 x i8] c"super\00"
@.str.774 = private unnamed_addr constant [7 x i8] c"unsafe\00"
@.str.781 = private unnamed_addr constant [9 x i8] c"unatomic\00"
@.str.788 = private unnamed_addr constant [10 x i8] c"constexpr\00"
@.str.795 = private unnamed_addr constant [4 x i8] c"box\00"
@.str.802 = private unnamed_addr constant [4 x i8] c"mut\00"
@.str.809 = private unnamed_addr constant [5 x i8] c"null\00"
@.str.816 = private unnamed_addr constant [6 x i8] c"inner\00"
@.str.823 = private unnamed_addr constant [6 x i8] c"outer\00"
@.str.830 = private unnamed_addr constant [7 x i8] c"tensor\00"
@.str.837 = private unnamed_addr constant [3 x i8] c"to\00"
@.str.844 = private unnamed_addr constant [6 x i8] c"until\00"
@.str.851 = private unnamed_addr constant [4 x i8] c"and\00"
@.str.858 = private unnamed_addr constant [3 x i8] c"or\00"
@.str.865 = private unnamed_addr constant [4 x i8] c"xor\00"
@.str.872 = private unnamed_addr constant [4 x i8] c"ode\00"
@.str.879 = private unnamed_addr constant [9 x i8] c"molecule\00"
@.str.886 = private unnamed_addr constant [4 x i8] c"cfd\00"
@.str.893 = private unnamed_addr constant [8 x i8] c"protein\00"
@.str.900 = private unnamed_addr constant [4 x i8] c"cpu\00"
@.str.907 = private unnamed_addr constant [7 x i8] c"openmp\00"
@.str.914 = private unnamed_addr constant [4 x i8] c"gpu\00"
@.str.921 = private unnamed_addr constant [5 x i8] c"simd\00"
@.str.1266 = private unnamed_addr constant [3 x i8] c"[@\00"
@.str.1282 = private unnamed_addr constant [3 x i8] c"=>\00"
@.str.1291 = private unnamed_addr constant [3 x i8] c"<-\00"
@.str.1300 = private unnamed_addr constant [3 x i8] c"->\00"
@.str.1309 = private unnamed_addr constant [3 x i8] c"<=\00"
@.str.1318 = private unnamed_addr constant [3 x i8] c">=\00"
@.str.1327 = private unnamed_addr constant [3 x i8] c"==\00"
@.str.1336 = private unnamed_addr constant [3 x i8] c"&&\00"
@.str.1345 = private unnamed_addr constant [3 x i8] c"||\00"
@.str.1354 = private unnamed_addr constant [3 x i8] c"++\00"
@.str.1363 = private unnamed_addr constant [3 x i8] c"--\00"
@.str.1372 = private unnamed_addr constant [3 x i8] c"!=\00"
@.str.1381 = private unnamed_addr constant [3 x i8] c"+=\00"
@.str.1390 = private unnamed_addr constant [3 x i8] c"-=\00"
@.str.1399 = private unnamed_addr constant [3 x i8] c"*=\00"
@.str.1408 = private unnamed_addr constant [3 x i8] c"/=\00"
@.str.1417 = private unnamed_addr constant [3 x i8] c"%=\00"
@.str.1426 = private unnamed_addr constant [3 x i8] c"<<\00"
@.str.1435 = private unnamed_addr constant [3 x i8] c">>\00"
@.str.1444 = private unnamed_addr constant [3 x i8] c"..\00"
@.str.1453 = private unnamed_addr constant [3 x i8] c"$$\00"
@.str.1462 = private unnamed_addr constant [3 x i8] c"**\00"
@.str.1490 = private unnamed_addr constant [6 x i8] c"eturn\00"
@.str.1495 = private unnamed_addr constant [7 x i8] c"return\00"
@.str.1504 = private unnamed_addr constant [5 x i8] c"atio\00"
@.str.1509 = private unnamed_addr constant [6 x i8] c"ratio\00"
@.str.1518 = private unnamed_addr constant [6 x i8] c"educe\00"
@.str.1523 = private unnamed_addr constant [7 x i8] c"reduce\00"
@.str.1532 = private unnamed_addr constant [5 x i8] c"ange\00"
@.str.1537 = private unnamed_addr constant [6 x i8] c"range\00"
@.str.1546 = private unnamed_addr constant [5 x i8] c"egex\00"
@.str.1551 = private unnamed_addr constant [6 x i8] c"regex\00"
@.str.1560 = private unnamed_addr constant [6 x i8] c"Regex\00"
@.str.1565 = private unnamed_addr constant [6 x i8] c"Regex\00"
@.str.1598 = private unnamed_addr constant [1 x i8] c"\00"
@.str.1676 = private unnamed_addr constant [1 x i8] c"\00"
@.str.1727 = private unnamed_addr constant [3 x i8] c"//\00"
@.str.1754 = private unnamed_addr constant [3 x i8] c"/*\00"
@.str.1817 = private unnamed_addr constant [2 x i8] c"r\00"
@.str.1839 = private unnamed_addr constant [2 x i8] c"R\00"
@.str.1866 = private unnamed_addr constant [5 x i8] c"true\00"
@.str.1873 = private unnamed_addr constant [6 x i8] c"false\00"
@.str.2207 = private unnamed_addr constant [2 x i8] c".\00"
@.str.2214 = private unnamed_addr constant [2 x i8] c"e\00"
@.str.2221 = private unnamed_addr constant [2 x i8] c"E\00"
@.str.2294 = private unnamed_addr constant [2 x i8] c"r\00"
@.str.2317 = private unnamed_addr constant [2 x i8] c"R\00"
@.str.2344 = private unnamed_addr constant [5 x i8] c"true\00"
@.str.2351 = private unnamed_addr constant [6 x i8] c"false\00"
@.str.2454 = private unnamed_addr constant [6 x i8] c"<eof>\00"
@.str.2959 = private unnamed_addr constant [2 x i8] c"(\00"
@.str.2976 = private unnamed_addr constant [2 x i8] c")\00"
@.str.2993 = private unnamed_addr constant [2 x i8] c"{\00"
@.str.3010 = private unnamed_addr constant [2 x i8] c"}\00"
@.str.3027 = private unnamed_addr constant [2 x i8] c"[\00"
@.str.3044 = private unnamed_addr constant [2 x i8] c"]\00"
@.str.3159 = private unnamed_addr constant [3 x i8] c"[@\00"
@.str.3179 = private unnamed_addr constant [7 x i8] c"import\00"
@.str.3186 = private unnamed_addr constant [6 x i8] c"class\00"
@.str.3193 = private unnamed_addr constant [7 x i8] c"object\00"
@.str.3200 = private unnamed_addr constant [9 x i8] c"external\00"
@.str.3207 = private unnamed_addr constant [4 x i8] c"def\00"
@.str.3214 = private unnamed_addr constant [9 x i8] c"template\00"
@.str.3221 = private unnamed_addr constant [4 x i8] c"val\00"
@.str.3228 = private unnamed_addr constant [4 x i8] c"var\00"
@.str.3235 = private unnamed_addr constant [7 x i8] c"unsafe\00"
@.str.3242 = private unnamed_addr constant [9 x i8] c"unatomic\00"
@.str.3249 = private unnamed_addr constant [10 x i8] c"constexpr\00"
@.str.3394 = private unnamed_addr constant [2 x i8] c"(\00"
@.str.3411 = private unnamed_addr constant [2 x i8] c")\00"
@.str.3428 = private unnamed_addr constant [2 x i8] c"{\00"
@.str.3445 = private unnamed_addr constant [2 x i8] c"}\00"
@.str.3482 = private unnamed_addr constant [2 x i8] c"[\00"
@.str.3499 = private unnamed_addr constant [2 x i8] c"]\00"
@.str.3516 = private unnamed_addr constant [2 x i8] c";\00"
@.str.3585 = private unnamed_addr constant [33 x i8] c"selfhost/selfhost_llvm_trace.txt\00"
@.str.3587 = private unnamed_addr constant [9 x i8] c"balanced\00"
@.str.3640 = private unnamed_addr constant [3 x i8] c"[@\00"
@.str.3645 = private unnamed_addr constant [10 x i8] c"attribute\00"
@.str.3663 = private unnamed_addr constant [8 x i8] c"unknown\00"
@.str.3672 = private unnamed_addr constant [9 x i8] c"external\00"
@.str.3696 = private unnamed_addr constant [6 x i8] c"class\00"
@.str.3701 = private unnamed_addr constant [15 x i8] c"external-class\00"
@.str.3710 = private unnamed_addr constant [7 x i8] c"object\00"
@.str.3715 = private unnamed_addr constant [16 x i8] c"external-object\00"
@.str.3724 = private unnamed_addr constant [4 x i8] c"def\00"
@.str.3729 = private unnamed_addr constant [18 x i8] c"external-function\00"
@.str.3733 = private unnamed_addr constant [9 x i8] c"external\00"
@.str.3742 = private unnamed_addr constant [7 x i8] c"unsafe\00"
@.str.3749 = private unnamed_addr constant [9 x i8] c"unatomic\00"
@.str.3756 = private unnamed_addr constant [10 x i8] c"constexpr\00"
@.str.3777 = private unnamed_addr constant [9 x i8] c"template\00"
@.str.3782 = private unnamed_addr constant [9 x i8] c"template\00"
@.str.3791 = private unnamed_addr constant [7 x i8] c"import\00"
@.str.3796 = private unnamed_addr constant [7 x i8] c"import\00"
@.str.3805 = private unnamed_addr constant [6 x i8] c"class\00"
@.str.3810 = private unnamed_addr constant [6 x i8] c"class\00"
@.str.3819 = private unnamed_addr constant [7 x i8] c"object\00"
@.str.3824 = private unnamed_addr constant [7 x i8] c"object\00"
@.str.3833 = private unnamed_addr constant [4 x i8] c"def\00"
@.str.3838 = private unnamed_addr constant [9 x i8] c"function\00"
@.str.3847 = private unnamed_addr constant [4 x i8] c"val\00"
@.str.3852 = private unnamed_addr constant [6 x i8] c"value\00"
@.str.3861 = private unnamed_addr constant [4 x i8] c"var\00"
@.str.3866 = private unnamed_addr constant [9 x i8] c"variable\00"
@.str.3870 = private unnamed_addr constant [8 x i8] c"unknown\00"
@.str.3905 = private unnamed_addr constant [15 x i8] c"external-class\00"
@.str.3912 = private unnamed_addr constant [16 x i8] c"external-object\00"
@.str.3919 = private unnamed_addr constant [18 x i8] c"external-function\00"
@.str.3940 = private unnamed_addr constant [9 x i8] c"template\00"
@.str.3992 = private unnamed_addr constant [2 x i8] c"<\00"
@.str.4009 = private unnamed_addr constant [2 x i8] c">\00"
@.str.4046 = private unnamed_addr constant [11 x i8] c"<template>\00"
@.str.4055 = private unnamed_addr constant [7 x i8] c"import\00"
@.str.4076 = private unnamed_addr constant [9 x i8] c"function\00"
@.str.4093 = private unnamed_addr constant [9 x i8] c"operator\00"
@.str.4098 = private unnamed_addr constant [9 x i8] c"operator\00"
@.str.4127 = private unnamed_addr constant [6 x i8] c"class\00"
@.str.4134 = private unnamed_addr constant [7 x i8] c"object\00"
@.str.4141 = private unnamed_addr constant [6 x i8] c"value\00"
@.str.4148 = private unnamed_addr constant [9 x i8] c"variable\00"
@.str.4164 = private unnamed_addr constant [12 x i8] c"<anonymous>\00"
@.str.4308 = private unnamed_addr constant [2 x i8] c"(\00"
@.str.4326 = private unnamed_addr constant [2 x i8] c")\00"
@.str.4344 = private unnamed_addr constant [2 x i8] c"{\00"
@.str.4362 = private unnamed_addr constant [2 x i8] c"}\00"
@.str.4401 = private unnamed_addr constant [2 x i8] c"[\00"
@.str.4419 = private unnamed_addr constant [2 x i8] c"]\00"
@.str.4437 = private unnamed_addr constant [2 x i8] c";\00"
@.str.4560 = private unnamed_addr constant [2 x i8] c"{\00"
@.str.4582 = private unnamed_addr constant [2 x i8] c";\00"
@.str.4712 = private unnamed_addr constant [2 x i8] c"{\00"
@.str.4730 = private unnamed_addr constant [2 x i8] c"}\00"
@.str.4818 = private unnamed_addr constant [7 x i8] c"return\00"
@.str.4823 = private unnamed_addr constant [7 x i8] c"return\00"
@.str.4832 = private unnamed_addr constant [4 x i8] c"val\00"
@.str.4837 = private unnamed_addr constant [6 x i8] c"value\00"
@.str.4846 = private unnamed_addr constant [4 x i8] c"var\00"
@.str.4851 = private unnamed_addr constant [9 x i8] c"variable\00"
@.str.4860 = private unnamed_addr constant [3 x i8] c"if\00"
@.str.4865 = private unnamed_addr constant [3 x i8] c"if\00"
@.str.4874 = private unnamed_addr constant [4 x i8] c"for\00"
@.str.4879 = private unnamed_addr constant [4 x i8] c"for\00"
@.str.4888 = private unnamed_addr constant [6 x i8] c"while\00"
@.str.4893 = private unnamed_addr constant [6 x i8] c"while\00"
@.str.4902 = private unnamed_addr constant [4 x i8] c"map\00"
@.str.4907 = private unnamed_addr constant [4 x i8] c"map\00"
@.str.4916 = private unnamed_addr constant [5 x i8] c"pmap\00"
@.str.4921 = private unnamed_addr constant [5 x i8] c"pmap\00"
@.str.4930 = private unnamed_addr constant [7 x i8] c"reduce\00"
@.str.4935 = private unnamed_addr constant [7 x i8] c"reduce\00"
@.str.4944 = private unnamed_addr constant [8 x i8] c"preduce\00"
@.str.4949 = private unnamed_addr constant [8 x i8] c"preduce\00"
@.str.4958 = private unnamed_addr constant [7 x i8] c"filter\00"
@.str.4963 = private unnamed_addr constant [7 x i8] c"filter\00"
@.str.4972 = private unnamed_addr constant [4 x i8] c"def\00"
@.str.4977 = private unnamed_addr constant [9 x i8] c"function\00"
@.str.4986 = private unnamed_addr constant [7 x i8] c"object\00"
@.str.4991 = private unnamed_addr constant [7 x i8] c"object\00"
@.str.5000 = private unnamed_addr constant [7 x i8] c"unsafe\00"
@.str.5005 = private unnamed_addr constant [7 x i8] c"unsafe\00"
@.str.5014 = private unnamed_addr constant [9 x i8] c"unatomic\00"
@.str.5019 = private unnamed_addr constant [9 x i8] c"unatomic\00"
@.str.5028 = private unnamed_addr constant [10 x i8] c"constexpr\00"
@.str.5033 = private unnamed_addr constant [10 x i8] c"constexpr\00"
@.str.5047 = private unnamed_addr constant [4 x i8] c"eof\00"
@.str.5051 = private unnamed_addr constant [11 x i8] c"expression\00"
@.str.5084 = private unnamed_addr constant [1 x i8] c"\00"
@.str.5128 = private unnamed_addr constant [2 x i8] c" \00"
@.str.5202 = private unnamed_addr constant [2 x i8] c"=\00"
@.str.5209 = private unnamed_addr constant [3 x i8] c"<-\00"
@.str.5216 = private unnamed_addr constant [3 x i8] c"+=\00"
@.str.5223 = private unnamed_addr constant [3 x i8] c"-=\00"
@.str.5230 = private unnamed_addr constant [3 x i8] c"*=\00"
@.str.5237 = private unnamed_addr constant [3 x i8] c"/=\00"
@.str.5244 = private unnamed_addr constant [3 x i8] c"%=\00"
@.str.5267 = private unnamed_addr constant [3 x i8] c"or\00"
@.str.5283 = private unnamed_addr constant [3 x i8] c"||\00"
@.str.5290 = private unnamed_addr constant [2 x i8] c"|\00"
@.str.5315 = private unnamed_addr constant [4 x i8] c"and\00"
@.str.5330 = private unnamed_addr constant [3 x i8] c"&&\00"
@.str.5354 = private unnamed_addr constant [4 x i8] c"xor\00"
@.str.5369 = private unnamed_addr constant [2 x i8] c"^\00"
@.str.5392 = private unnamed_addr constant [2 x i8] c"&\00"
@.str.5414 = private unnamed_addr constant [3 x i8] c"==\00"
@.str.5421 = private unnamed_addr constant [3 x i8] c"!=\00"
@.str.5428 = private unnamed_addr constant [2 x i8] c"<\00"
@.str.5435 = private unnamed_addr constant [2 x i8] c">\00"
@.str.5442 = private unnamed_addr constant [3 x i8] c"<=\00"
@.str.5449 = private unnamed_addr constant [3 x i8] c">=\00"
@.str.5471 = private unnamed_addr constant [3 x i8] c"<<\00"
@.str.5478 = private unnamed_addr constant [3 x i8] c">>\00"
@.str.5501 = private unnamed_addr constant [3 x i8] c"..\00"
@.str.5517 = private unnamed_addr constant [3 x i8] c"to\00"
@.str.5524 = private unnamed_addr constant [6 x i8] c"until\00"
@.str.5548 = private unnamed_addr constant [2 x i8] c"+\00"
@.str.5555 = private unnamed_addr constant [2 x i8] c"-\00"
@.str.5577 = private unnamed_addr constant [2 x i8] c"*\00"
@.str.5584 = private unnamed_addr constant [2 x i8] c"/\00"
@.str.5591 = private unnamed_addr constant [2 x i8] c"%\00"
@.str.5598 = private unnamed_addr constant [2 x i8] c"@\00"
@.str.5620 = private unnamed_addr constant [6 x i8] c"inner\00"
@.str.5627 = private unnamed_addr constant [6 x i8] c"outer\00"
@.str.5634 = private unnamed_addr constant [7 x i8] c"tensor\00"
@.str.5656 = private unnamed_addr constant [2 x i8] c",\00"
@.str.5755 = private unnamed_addr constant [2 x i8] c")\00"
@.str.5773 = private unnamed_addr constant [2 x i8] c"(\00"
@.str.5791 = private unnamed_addr constant [2 x i8] c"}\00"
@.str.5809 = private unnamed_addr constant [2 x i8] c"{\00"
@.str.5827 = private unnamed_addr constant [2 x i8] c"]\00"
@.str.5845 = private unnamed_addr constant [2 x i8] c"[\00"
@.str.5993 = private unnamed_addr constant [2 x i8] c"(\00"
@.str.6011 = private unnamed_addr constant [2 x i8] c")\00"
@.str.6029 = private unnamed_addr constant [2 x i8] c"{\00"
@.str.6047 = private unnamed_addr constant [2 x i8] c"}\00"
@.str.6065 = private unnamed_addr constant [2 x i8] c"[\00"
@.str.6083 = private unnamed_addr constant [2 x i8] c"]\00"
@.str.6119 = private unnamed_addr constant [6 x i8] c"match\00"
@.str.6352 = private unnamed_addr constant [2 x i8] c";\00"
@.str.6392 = private unnamed_addr constant [6 x i8] c"empty\00"
@.str.6417 = private unnamed_addr constant [8 x i8] c"integer\00"
@.str.6430 = private unnamed_addr constant [6 x i8] c"float\00"
@.str.6443 = private unnamed_addr constant [7 x i8] c"string\00"
@.str.6456 = private unnamed_addr constant [6 x i8] c"regex\00"
@.str.6469 = private unnamed_addr constant [5 x i8] c"char\00"
@.str.6482 = private unnamed_addr constant [5 x i8] c"bool\00"
@.str.6495 = private unnamed_addr constant [11 x i8] c"identifier\00"
@.str.6525 = private unnamed_addr constant [5 x i8] c"this\00"
@.str.6530 = private unnamed_addr constant [5 x i8] c"this\00"
@.str.6539 = private unnamed_addr constant [6 x i8] c"super\00"
@.str.6544 = private unnamed_addr constant [6 x i8] c"super\00"
@.str.6553 = private unnamed_addr constant [4 x i8] c"new\00"
@.str.6558 = private unnamed_addr constant [4 x i8] c"new\00"
@.str.6567 = private unnamed_addr constant [6 x i8] c"match\00"
@.str.6572 = private unnamed_addr constant [6 x i8] c"match\00"
@.str.6577 = private unnamed_addr constant [8 x i8] c"unknown\00"
@.str.6689 = private unnamed_addr constant [2 x i8] c"{\00"
@.str.6716 = private unnamed_addr constant [2 x i8] c"{\00"
@.str.6718 = private unnamed_addr constant [2 x i8] c"}\00"
@.str.6767 = private unnamed_addr constant [5 x i8] c"case\00"
@.str.6816 = private unnamed_addr constant [2 x i8] c"(\00"
@.str.6873 = private unnamed_addr constant [2 x i8] c"(\00"
@.str.6875 = private unnamed_addr constant [2 x i8] c")\00"
@.str.6929 = private unnamed_addr constant [2 x i8] c"{\00"
@.str.6942 = private unnamed_addr constant [2 x i8] c"{\00"
@.str.6999 = private unnamed_addr constant [2 x i8] c"{\00"
@.str.7001 = private unnamed_addr constant [2 x i8] c"}\00"
@.str.7076 = private unnamed_addr constant [1 x i8] c"\00"
@.str.7193 = private unnamed_addr constant [2 x i8] c"(\00"
@.str.7211 = private unnamed_addr constant [2 x i8] c")\00"
@.str.7229 = private unnamed_addr constant [2 x i8] c"[\00"
@.str.7247 = private unnamed_addr constant [2 x i8] c"]\00"
@.str.7265 = private unnamed_addr constant [2 x i8] c"{\00"
@.str.7283 = private unnamed_addr constant [2 x i8] c"}\00"
@.str.7301 = private unnamed_addr constant [2 x i8] c",\00"
@.str.7427 = private unnamed_addr constant [2 x i8] c")\00"
@.str.7445 = private unnamed_addr constant [2 x i8] c"(\00"
@.str.7463 = private unnamed_addr constant [2 x i8] c"]\00"
@.str.7481 = private unnamed_addr constant [2 x i8] c"[\00"
@.str.7499 = private unnamed_addr constant [2 x i8] c"}\00"
@.str.7517 = private unnamed_addr constant [2 x i8] c"{\00"
@.str.7593 = private unnamed_addr constant [1 x i8] c"\00"
@.str.7610 = private unnamed_addr constant [2 x i8] c")\00"
@.str.7627 = private unnamed_addr constant [2 x i8] c"(\00"
@.str.7638 = private unnamed_addr constant [18 x i8] c"Expr call target=\00"
@.str.7649 = private unnamed_addr constant [7 x i8] c" argc=\00"
@.str.7680 = private unnamed_addr constant [2 x i8] c"]\00"
@.str.7697 = private unnamed_addr constant [2 x i8] c"[\00"
@.str.7708 = private unnamed_addr constant [19 x i8] c"Expr index target=\00"
@.str.7719 = private unnamed_addr constant [7 x i8] c" argc=\00"
@.str.7749 = private unnamed_addr constant [2 x i8] c".\00"
@.str.7760 = private unnamed_addr constant [13 x i8] c"Expr member \00"
@.str.7771 = private unnamed_addr constant [2 x i8] c".\00"
@.str.7786 = private unnamed_addr constant [1 x i8] c"\00"
@.str.7820 = private unnamed_addr constant [2 x i8] c"[\00"
@.str.7822 = private unnamed_addr constant [2 x i8] c"]\00"
@.str.7864 = private unnamed_addr constant [2 x i8] c"(\00"
@.str.7886 = private unnamed_addr constant [2 x i8] c"(\00"
@.str.7888 = private unnamed_addr constant [2 x i8] c")\00"
@.str.7929 = private unnamed_addr constant [3 x i8] c"->\00"
@.str.7973 = private unnamed_addr constant [2 x i8] c"[\00"
@.str.7975 = private unnamed_addr constant [2 x i8] c"]\00"
@.str.7988 = private unnamed_addr constant [5 x i8] c"none\00"
@.str.8035 = private unnamed_addr constant [2 x i8] c"[\00"
@.str.8037 = private unnamed_addr constant [2 x i8] c"]\00"
@.str.8078 = private unnamed_addr constant [2 x i8] c"(\00"
@.str.8099 = private unnamed_addr constant [2 x i8] c"(\00"
@.str.8101 = private unnamed_addr constant [2 x i8] c")\00"
@.str.8148 = private unnamed_addr constant [2 x i8] c"[\00"
@.str.8153 = private unnamed_addr constant [1 x i8] c"\00"
@.str.8178 = private unnamed_addr constant [1 x i8] c"\00"
@.str.8182 = private unnamed_addr constant [21 x i8] c"Expr lambda capture=\00"
@.str.8193 = private unnamed_addr constant [9 x i8] c" params=\00"
@.str.8257 = private unnamed_addr constant [11 x i8] c"Expr empty\00"
@.str.8270 = private unnamed_addr constant [6 x i8] c"Expr \00"
@.str.8281 = private unnamed_addr constant [2 x i8] c" \00"
@.str.8342 = private unnamed_addr constant [18 x i8] c"Expr match cases=\00"
@.str.8353 = private unnamed_addr constant [3 x i8] c" [\00"
@.str.8364 = private unnamed_addr constant [2 x i8] c"]\00"
@.str.8379 = private unnamed_addr constant [2 x i8] c"(\00"
@.str.8396 = private unnamed_addr constant [2 x i8] c"(\00"
@.str.8398 = private unnamed_addr constant [2 x i8] c")\00"
@.str.8411 = private unnamed_addr constant [13 x i8] c"Expr group (\00"
@.str.8426 = private unnamed_addr constant [2 x i8] c")\00"
@.str.8454 = private unnamed_addr constant [13 x i8] c"Expr assign \00"
@.str.8463 = private unnamed_addr constant [3 x i8] c" [\00"
@.str.8474 = private unnamed_addr constant [4 x i8] c"] [\00"
@.str.8487 = private unnamed_addr constant [2 x i8] c"]\00"
@.str.8511 = private unnamed_addr constant [13 x i8] c"Expr binary \00"
@.str.8520 = private unnamed_addr constant [3 x i8] c" [\00"
@.str.8531 = private unnamed_addr constant [4 x i8] c"] [\00"
@.str.8544 = private unnamed_addr constant [2 x i8] c"]\00"
@.str.8568 = private unnamed_addr constant [13 x i8] c"Expr binary \00"
@.str.8577 = private unnamed_addr constant [3 x i8] c" [\00"
@.str.8588 = private unnamed_addr constant [4 x i8] c"] [\00"
@.str.8601 = private unnamed_addr constant [2 x i8] c"]\00"
@.str.8625 = private unnamed_addr constant [13 x i8] c"Expr binary \00"
@.str.8634 = private unnamed_addr constant [3 x i8] c" [\00"
@.str.8645 = private unnamed_addr constant [4 x i8] c"] [\00"
@.str.8658 = private unnamed_addr constant [2 x i8] c"]\00"
@.str.8682 = private unnamed_addr constant [13 x i8] c"Expr binary \00"
@.str.8691 = private unnamed_addr constant [3 x i8] c" [\00"
@.str.8702 = private unnamed_addr constant [4 x i8] c"] [\00"
@.str.8715 = private unnamed_addr constant [2 x i8] c"]\00"
@.str.8739 = private unnamed_addr constant [14 x i8] c"Expr compare \00"
@.str.8748 = private unnamed_addr constant [3 x i8] c" [\00"
@.str.8759 = private unnamed_addr constant [4 x i8] c"] [\00"
@.str.8772 = private unnamed_addr constant [2 x i8] c"]\00"
@.str.8796 = private unnamed_addr constant [12 x i8] c"Expr shift \00"
@.str.8805 = private unnamed_addr constant [3 x i8] c" [\00"
@.str.8816 = private unnamed_addr constant [4 x i8] c"] [\00"
@.str.8829 = private unnamed_addr constant [2 x i8] c"]\00"
@.str.8853 = private unnamed_addr constant [12 x i8] c"Expr range \00"
@.str.8862 = private unnamed_addr constant [3 x i8] c" [\00"
@.str.8873 = private unnamed_addr constant [4 x i8] c"] [\00"
@.str.8886 = private unnamed_addr constant [2 x i8] c"]\00"
@.str.8910 = private unnamed_addr constant [13 x i8] c"Expr binary \00"
@.str.8919 = private unnamed_addr constant [3 x i8] c" [\00"
@.str.8930 = private unnamed_addr constant [4 x i8] c"] [\00"
@.str.8943 = private unnamed_addr constant [2 x i8] c"]\00"
@.str.8967 = private unnamed_addr constant [13 x i8] c"Expr binary \00"
@.str.8976 = private unnamed_addr constant [3 x i8] c" [\00"
@.str.8987 = private unnamed_addr constant [4 x i8] c"] [\00"
@.str.9000 = private unnamed_addr constant [2 x i8] c"]\00"
@.str.9024 = private unnamed_addr constant [13 x i8] c"Expr tensor \00"
@.str.9033 = private unnamed_addr constant [3 x i8] c" [\00"
@.str.9044 = private unnamed_addr constant [4 x i8] c"] [\00"
@.str.9057 = private unnamed_addr constant [2 x i8] c"]\00"
@.str.9083 = private unnamed_addr constant [2 x i8] c"!\00"
@.str.9095 = private unnamed_addr constant [2 x i8] c"-\00"
@.str.9107 = private unnamed_addr constant [2 x i8] c"+\00"
@.str.9119 = private unnamed_addr constant [2 x i8] c"~\00"
@.str.9131 = private unnamed_addr constant [2 x i8] c"*\00"
@.str.9143 = private unnamed_addr constant [2 x i8] c"&\00"
@.str.9155 = private unnamed_addr constant [3 x i8] c"<-\00"
@.str.9167 = private unnamed_addr constant [3 x i8] c"++\00"
@.str.9179 = private unnamed_addr constant [3 x i8] c"--\00"
@.str.9185 = private unnamed_addr constant [12 x i8] c"Expr unary \00"
@.str.9194 = private unnamed_addr constant [3 x i8] c" [\00"
@.str.9207 = private unnamed_addr constant [2 x i8] c"]\00"
@.str.9243 = private unnamed_addr constant [3 x i8] c"++\00"
@.str.9257 = private unnamed_addr constant [3 x i8] c"--\00"
@.str.9263 = private unnamed_addr constant [14 x i8] c"Expr postfix \00"
@.str.9274 = private unnamed_addr constant [3 x i8] c" [\00"
@.str.9287 = private unnamed_addr constant [2 x i8] c"]\00"
@.str.9348 = private unnamed_addr constant [2 x i8] c"(\00"
@.str.9361 = private unnamed_addr constant [2 x i8] c"(\00"
@.str.9363 = private unnamed_addr constant [2 x i8] c")\00"
@.str.9372 = private unnamed_addr constant [11 x i8] c"Expr call \00"
@.str.9381 = private unnamed_addr constant [2 x i8] c"(\00"
@.str.9396 = private unnamed_addr constant [2 x i8] c")\00"
@.str.9411 = private unnamed_addr constant [2 x i8] c"[\00"
@.str.9416 = private unnamed_addr constant [18 x i8] c"Expr array count=\00"
@.str.9431 = private unnamed_addr constant [3 x i8] c" [\00"
@.str.9446 = private unnamed_addr constant [2 x i8] c"]\00"
@.str.9471 = private unnamed_addr constant [4 x i8] c"new\00"
@.str.9476 = private unnamed_addr constant [10 x i8] c"Expr new \00"
@.str.9512 = private unnamed_addr constant [6 x i8] c"match\00"
@.str.9517 = private unnamed_addr constant [11 x i8] c"Expr match\00"
@.str.9521 = private unnamed_addr constant [6 x i8] c"Expr \00"
@.str.9532 = private unnamed_addr constant [2 x i8] c" \00"
@.str.9669 = private unnamed_addr constant [2 x i8] c"(\00"
@.str.9686 = private unnamed_addr constant [2 x i8] c")\00"
@.str.9703 = private unnamed_addr constant [2 x i8] c"{\00"
@.str.9720 = private unnamed_addr constant [2 x i8] c"}\00"
@.str.9790 = private unnamed_addr constant [3 x i8] c"if\00"
@.str.9803 = private unnamed_addr constant [5 x i8] c"else\00"
@.str.9833 = private unnamed_addr constant [3 x i8] c"if\00"
@.str.9860 = private unnamed_addr constant [2 x i8] c"{\00"
@.str.9877 = private unnamed_addr constant [2 x i8] c"{\00"
@.str.9879 = private unnamed_addr constant [2 x i8] c"}\00"
@.str.9910 = private unnamed_addr constant [2 x i8] c"[\00"
@.str.9927 = private unnamed_addr constant [2 x i8] c"]\00"
@.str.9944 = private unnamed_addr constant [2 x i8] c";\00"
@.str.10014 = private unnamed_addr constant [7 x i8] c"return\00"
@.str.10019 = private unnamed_addr constant [15 x i8] c"  Stmt return \00"
@.str.10032 = private unnamed_addr constant [3 x i8] c"\0A\00"
@.str.10041 = private unnamed_addr constant [6 x i8] c"value\00"
@.str.10048 = private unnamed_addr constant [9 x i8] c"variable\00"
@.str.10076 = private unnamed_addr constant [8 x i8] c"  Stmt \00"
@.str.10080 = private unnamed_addr constant [2 x i8] c" \00"
@.str.10091 = private unnamed_addr constant [4 x i8] c" = \00"
@.str.10104 = private unnamed_addr constant [3 x i8] c"\0A\00"
@.str.10108 = private unnamed_addr constant [8 x i8] c"  Stmt \00"
@.str.10112 = private unnamed_addr constant [2 x i8] c" \00"
@.str.10123 = private unnamed_addr constant [3 x i8] c"\0A\00"
@.str.10132 = private unnamed_addr constant [3 x i8] c"if\00"
@.str.10139 = private unnamed_addr constant [4 x i8] c"for\00"
@.str.10146 = private unnamed_addr constant [6 x i8] c"while\00"
@.str.10153 = private unnamed_addr constant [4 x i8] c"map\00"
@.str.10160 = private unnamed_addr constant [5 x i8] c"pmap\00"
@.str.10167 = private unnamed_addr constant [7 x i8] c"reduce\00"
@.str.10174 = private unnamed_addr constant [8 x i8] c"preduce\00"
@.str.10181 = private unnamed_addr constant [7 x i8] c"filter\00"
@.str.10186 = private unnamed_addr constant [8 x i8] c"  Stmt \00"
@.str.10190 = private unnamed_addr constant [3 x i8] c" (\00"
@.str.10201 = private unnamed_addr constant [4 x i8] c")\0A\00"
@.str.10210 = private unnamed_addr constant [7 x i8] c"unsafe\00"
@.str.10217 = private unnamed_addr constant [9 x i8] c"unatomic\00"
@.str.10224 = private unnamed_addr constant [10 x i8] c"constexpr\00"
@.str.10229 = private unnamed_addr constant [8 x i8] c"  Stmt \00"
@.str.10233 = private unnamed_addr constant [3 x i8] c"\0A\00"
@.str.10242 = private unnamed_addr constant [9 x i8] c"function\00"
@.str.10249 = private unnamed_addr constant [7 x i8] c"object\00"
@.str.10254 = private unnamed_addr constant [8 x i8] c"  Stmt \00"
@.str.10258 = private unnamed_addr constant [2 x i8] c" \00"
@.str.10269 = private unnamed_addr constant [3 x i8] c"\0A\00"
@.str.10273 = private unnamed_addr constant [19 x i8] c"  Stmt expression \00"
@.str.10284 = private unnamed_addr constant [3 x i8] c"\0A\00"
@.str.10310 = private unnamed_addr constant [1 x i8] c"\00"
@.str.10370 = private unnamed_addr constant [15 x i8] c"  Stmt error\0A\00"
@.str.10447 = private unnamed_addr constant [2 x i8] c"(\00"
@.str.10467 = private unnamed_addr constant [2 x i8] c"{\00"
@.str.10480 = private unnamed_addr constant [2 x i8] c";\00"
@.str.10557 = private unnamed_addr constant [2 x i8] c"(\00"
@.str.10559 = private unnamed_addr constant [2 x i8] c")\00"
@.str.10588 = private unnamed_addr constant [2 x i8] c":\00"
@.str.10633 = private unnamed_addr constant [1 x i8] c"\00"
@.str.10671 = private unnamed_addr constant [2 x i8] c"{\00"
@.str.10678 = private unnamed_addr constant [2 x i8] c"=\00"
@.str.10685 = private unnamed_addr constant [2 x i8] c";\00"
@.str.10692 = private unnamed_addr constant [2 x i8] c",\00"
@.str.10774 = private unnamed_addr constant [5 x i8] c"Unit\00"
@.str.10813 = private unnamed_addr constant [5 x i8] c"Unit\00"
@.str.10875 = private unnamed_addr constant [2 x i8] c"(\00"
@.str.10877 = private unnamed_addr constant [2 x i8] c")\00"
@.str.10928 = private unnamed_addr constant [2 x i8] c",\00"
@.str.10980 = private unnamed_addr constant [2 x i8] c"(\00"
@.str.10997 = private unnamed_addr constant [2 x i8] c"(\00"
@.str.10999 = private unnamed_addr constant [2 x i8] c")\00"
@.str.11020 = private unnamed_addr constant [3 x i8] c"=>\00"
@.str.11025 = private unnamed_addr constant [21 x i8] c"FunctionType params=\00"
@.str.11038 = private unnamed_addr constant [10 x i8] c" returns=\00"
@.str.11119 = private unnamed_addr constant [2 x i8] c":\00"
@.str.11148 = private unnamed_addr constant [2 x i8] c"=\00"
@.str.11161 = private unnamed_addr constant [2 x i8] c";\00"
@.str.11166 = private unnamed_addr constant [6 x i8] c"infer\00"
@.str.11177 = private unnamed_addr constant [6 x i8] c"infer\00"
@.str.11213 = private unnamed_addr constant [8 x i8] c"unknown\00"
@.str.11266 = private unnamed_addr constant [9 x i8] c"function\00"
@.str.11273 = private unnamed_addr constant [18 x i8] c"external-function\00"
@.str.11315 = private unnamed_addr constant [8 x i8] c"unknown\00"
@.str.11370 = private unnamed_addr constant [5 x i8] c"Unit\00"
@.str.11395 = private unnamed_addr constant [4 x i8] c"Int\00"
@.str.11408 = private unnamed_addr constant [7 x i8] c"Double\00"
@.str.11421 = private unnamed_addr constant [7 x i8] c"String\00"
@.str.11434 = private unnamed_addr constant [6 x i8] c"Regex\00"
@.str.11447 = private unnamed_addr constant [5 x i8] c"Char\00"
@.str.11460 = private unnamed_addr constant [8 x i8] c"Boolean\00"
@.str.11487 = private unnamed_addr constant [9 x i8] c"Function\00"
@.str.11512 = private unnamed_addr constant [8 x i8] c"unknown\00"
@.str.11539 = private unnamed_addr constant [8 x i8] c"Boolean\00"
@.str.11563 = private unnamed_addr constant [8 x i8] c"Boolean\00"
@.str.11587 = private unnamed_addr constant [8 x i8] c"Boolean\00"
@.str.11704 = private unnamed_addr constant [6 x i8] c"Range\00"
@.str.11822 = private unnamed_addr constant [4 x i8] c"new\00"
@.str.11851 = private unnamed_addr constant [2 x i8] c"[\00"
@.str.11856 = private unnamed_addr constant [6 x i8] c"Array\00"
@.str.11879 = private unnamed_addr constant [10 x i8] c"Expr call\00"
@.str.11903 = private unnamed_addr constant [11 x i8] c"Expr index\00"
@.str.11908 = private unnamed_addr constant [8 x i8] c"unknown\00"
@.str.11917 = private unnamed_addr constant [12 x i8] c"Expr member\00"
@.str.11922 = private unnamed_addr constant [8 x i8] c"unknown\00"
@.str.11940 = private unnamed_addr constant [8 x i8] c"unknown\00"
@.str.11944 = private unnamed_addr constant [8 x i8] c"unknown\00"
@.str.12002 = private unnamed_addr constant [2 x i8] c":\00"
@.str.12031 = private unnamed_addr constant [2 x i8] c"=\00"
@.str.12044 = private unnamed_addr constant [2 x i8] c";\00"
@.str.12049 = private unnamed_addr constant [1 x i8] c"\00"
@.str.12060 = private unnamed_addr constant [1 x i8] c"\00"
@.str.12145 = private unnamed_addr constant [8 x i8] c"unknown\00"
@.str.12175 = private unnamed_addr constant [1 x i8] c"\00"
@.str.12243 = private unnamed_addr constant [6 x i8] c"value\00"
@.str.12250 = private unnamed_addr constant [9 x i8] c"variable\00"
@.str.12258 = private unnamed_addr constant [9 x i8] c"  Local \00"
@.str.12262 = private unnamed_addr constant [2 x i8] c".\00"
@.str.12273 = private unnamed_addr constant [6 x i8] c" mut=\00"
@.str.12277 = private unnamed_addr constant [7 x i8] c" type=\00"
@.str.12288 = private unnamed_addr constant [3 x i8] c"\0A\00"
@.str.12298 = private unnamed_addr constant [3 x i8] c"if\00"
@.str.12305 = private unnamed_addr constant [6 x i8] c"while\00"
@.str.12312 = private unnamed_addr constant [4 x i8] c"for\00"
@.str.12319 = private unnamed_addr constant [4 x i8] c"map\00"
@.str.12326 = private unnamed_addr constant [5 x i8] c"pmap\00"
@.str.12333 = private unnamed_addr constant [7 x i8] c"reduce\00"
@.str.12340 = private unnamed_addr constant [8 x i8] c"preduce\00"
@.str.12347 = private unnamed_addr constant [7 x i8] c"filter\00"
@.str.12355 = private unnamed_addr constant [9 x i8] c"  Block \00"
@.str.12359 = private unnamed_addr constant [2 x i8] c".\00"
@.str.12363 = private unnamed_addr constant [9 x i8] c" header=\00"
@.str.12374 = private unnamed_addr constant [3 x i8] c"\0A\00"
@.str.12417 = private unnamed_addr constant [10 x i8] c"  Assign \00"
@.str.12421 = private unnamed_addr constant [2 x i8] c".\00"
@.str.12430 = private unnamed_addr constant [5 x i8] c" op=\00"
@.str.12439 = private unnamed_addr constant [7 x i8] c" type=\00"
@.str.12452 = private unnamed_addr constant [3 x i8] c"\0A\00"
@.str.12508 = private unnamed_addr constant [1 x i8] c"\00"
@.str.12529 = private unnamed_addr constant [2 x i8] c"(\00"
@.str.12531 = private unnamed_addr constant [2 x i8] c")\00"
@.str.12548 = private unnamed_addr constant [1 x i8] c"\00"
@.str.12587 = private unnamed_addr constant [8 x i8] c"unknown\00"
@.str.12603 = private unnamed_addr constant [2 x i8] c":\00"
@.str.12625 = private unnamed_addr constant [9 x i8] c"  Param \00"
@.str.12629 = private unnamed_addr constant [2 x i8] c".\00"
@.str.12638 = private unnamed_addr constant [7 x i8] c" type=\00"
@.str.12642 = private unnamed_addr constant [3 x i8] c"\0A\00"
@.str.12662 = private unnamed_addr constant [2 x i8] c",\00"
@.str.12685 = private unnamed_addr constant [2 x i8] c",\00"
@.str.12727 = private unnamed_addr constant [9 x i8] c"override\00"
@.str.12740 = private unnamed_addr constant [7 x i8] c"unsafe\00"
@.str.12753 = private unnamed_addr constant [10 x i8] c"constexpr\00"
@.str.12805 = private unnamed_addr constant [4 x i8] c"def\00"
@.str.12810 = private unnamed_addr constant [7 x i8] c"method\00"
@.str.12825 = private unnamed_addr constant [4 x i8] c"val\00"
@.str.12830 = private unnamed_addr constant [6 x i8] c"field\00"
@.str.12845 = private unnamed_addr constant [4 x i8] c"var\00"
@.str.12850 = private unnamed_addr constant [14 x i8] c"mutable-field\00"
@.str.12854 = private unnamed_addr constant [7 x i8] c"member\00"
@.str.12895 = private unnamed_addr constant [4 x i8] c"def\00"
@.str.12913 = private unnamed_addr constant [9 x i8] c"operator\00"
@.str.12918 = private unnamed_addr constant [9 x i8] c"operator\00"
@.str.12953 = private unnamed_addr constant [4 x i8] c"val\00"
@.str.12966 = private unnamed_addr constant [4 x i8] c"var\00"
@.str.12982 = private unnamed_addr constant [9 x i8] c"<member>\00"
@.str.13012 = private unnamed_addr constant [1 x i8] c"\00"
@.str.13104 = private unnamed_addr constant [7 x i8] c"method\00"
@.str.13112 = private unnamed_addr constant [10 x i8] c"  Method \00"
@.str.13116 = private unnamed_addr constant [2 x i8] c".\00"
@.str.13120 = private unnamed_addr constant [9 x i8] c" params=\00"
@.str.13129 = private unnamed_addr constant [10 x i8] c" returns=\00"
@.str.13138 = private unnamed_addr constant [3 x i8] c"\0A\00"
@.str.13148 = private unnamed_addr constant [6 x i8] c"field\00"
@.str.13155 = private unnamed_addr constant [14 x i8] c"mutable-field\00"
@.str.13163 = private unnamed_addr constant [9 x i8] c"  Field \00"
@.str.13167 = private unnamed_addr constant [2 x i8] c".\00"
@.str.13171 = private unnamed_addr constant [6 x i8] c" mut=\00"
@.str.13175 = private unnamed_addr constant [7 x i8] c" type=\00"
@.str.13186 = private unnamed_addr constant [3 x i8] c"\0A\00"
@.str.13226 = private unnamed_addr constant [1 x i8] c"\00"
@.str.13280 = private unnamed_addr constant [10 x i8] c"  Member \00"
@.str.13289 = private unnamed_addr constant [2 x i8] c" \00"
@.str.13298 = private unnamed_addr constant [3 x i8] c"\0A\00"
@.str.13341 = private unnamed_addr constant [9 x i8] c"template\00"
@.str.13346 = private unnamed_addr constant [1 x i8] c"\00"
@.str.13367 = private unnamed_addr constant [2 x i8] c"<\00"
@.str.13378 = private unnamed_addr constant [1 x i8] c"\00"
@.str.13395 = private unnamed_addr constant [1 x i8] c"\00"
@.str.13421 = private unnamed_addr constant [2 x i8] c">\00"
@.str.13437 = private unnamed_addr constant [9 x i8] c"typename\00"
@.str.13450 = private unnamed_addr constant [6 x i8] c"class\00"
@.str.13458 = private unnamed_addr constant [7 x i8] c" type \00"
@.str.13495 = private unnamed_addr constant [8 x i8] c" value \00"
@.str.13552 = private unnamed_addr constant [9 x i8] c"template\00"
@.str.13557 = private unnamed_addr constant [1 x i8] c"\00"
@.str.13608 = private unnamed_addr constant [2 x i8] c"<\00"
@.str.13626 = private unnamed_addr constant [2 x i8] c">\00"
@.str.13663 = private unnamed_addr constant [4 x i8] c"def\00"
@.str.13668 = private unnamed_addr constant [9 x i8] c"function\00"
@.str.13677 = private unnamed_addr constant [6 x i8] c"class\00"
@.str.13682 = private unnamed_addr constant [6 x i8] c"class\00"
@.str.13698 = private unnamed_addr constant [1 x i8] c"\00"
@.str.13728 = private unnamed_addr constant [3 x i8] c"[@\00"
@.str.13733 = private unnamed_addr constant [1 x i8] c"\00"
@.str.13750 = private unnamed_addr constant [1 x i8] c"\00"
@.str.13776 = private unnamed_addr constant [2 x i8] c"]\00"
@.str.13793 = private unnamed_addr constant [2 x i8] c" \00"
@.str.13850 = private unnamed_addr constant [18 x i8] c"external-function\00"
@.str.13855 = private unnamed_addr constant [9 x i8] c"function\00"
@.str.13864 = private unnamed_addr constant [15 x i8] c"external-class\00"
@.str.13869 = private unnamed_addr constant [6 x i8] c"class\00"
@.str.13878 = private unnamed_addr constant [16 x i8] c"external-object\00"
@.str.13883 = private unnamed_addr constant [7 x i8] c"object\00"
@.str.13910 = private unnamed_addr constant [22 x i8] c"error: parse failed\0A\00"
@.str.13918 = private unnamed_addr constant [10 x i8] c"Symbols\0A\00"
@.str.13988 = private unnamed_addr constant [9 x i8] c"function\00"
@.str.13995 = private unnamed_addr constant [18 x i8] c"external-function\00"
@.str.14003 = private unnamed_addr constant [17 x i8] c"Symbol function \00"
@.str.14007 = private unnamed_addr constant [9 x i8] c" params=\00"
@.str.14016 = private unnamed_addr constant [10 x i8] c" returns=\00"
@.str.14025 = private unnamed_addr constant [3 x i8] c"\0A\00"
@.str.14033 = private unnamed_addr constant [18 x i8] c"external-function\00"
@.str.14041 = private unnamed_addr constant [21 x i8] c"  External function \00"
@.str.14045 = private unnamed_addr constant [3 x i8] c"\0A\00"
@.str.14120 = private unnamed_addr constant [6 x i8] c"value\00"
@.str.14127 = private unnamed_addr constant [9 x i8] c"variable\00"
@.str.14135 = private unnamed_addr constant [8 x i8] c"Symbol \00"
@.str.14139 = private unnamed_addr constant [2 x i8] c" \00"
@.str.14143 = private unnamed_addr constant [7 x i8] c" type=\00"
@.str.14154 = private unnamed_addr constant [3 x i8] c"\0A\00"
@.str.14164 = private unnamed_addr constant [9 x i8] c"template\00"
@.str.14172 = private unnamed_addr constant [17 x i8] c"Symbol template \00"
@.str.14176 = private unnamed_addr constant [9 x i8] c" target=\00"
@.str.14185 = private unnamed_addr constant [9 x i8] c" params=\00"
@.str.14194 = private unnamed_addr constant [3 x i8] c"\0A\00"
@.str.14204 = private unnamed_addr constant [10 x i8] c"attribute\00"
@.str.14212 = private unnamed_addr constant [18 x i8] c"Symbol attribute \00"
@.str.14221 = private unnamed_addr constant [3 x i8] c"\0A\00"
@.str.14231 = private unnamed_addr constant [9 x i8] c"external\00"
@.str.14238 = private unnamed_addr constant [18 x i8] c"external-function\00"
@.str.14245 = private unnamed_addr constant [15 x i8] c"external-class\00"
@.str.14252 = private unnamed_addr constant [16 x i8] c"external-object\00"
@.str.14260 = private unnamed_addr constant [17 x i8] c"Symbol external \00"
@.str.14269 = private unnamed_addr constant [2 x i8] c" \00"
@.str.14273 = private unnamed_addr constant [3 x i8] c"\0A\00"
@.str.14283 = private unnamed_addr constant [6 x i8] c"class\00"
@.str.14290 = private unnamed_addr constant [7 x i8] c"object\00"
@.str.14297 = private unnamed_addr constant [15 x i8] c"external-class\00"
@.str.14304 = private unnamed_addr constant [16 x i8] c"external-object\00"
@.str.14312 = private unnamed_addr constant [13 x i8] c"Symbol type \00"
@.str.14316 = private unnamed_addr constant [7 x i8] c" kind=\00"
@.str.14320 = private unnamed_addr constant [3 x i8] c"\0A\00"
@.str.14328 = private unnamed_addr constant [15 x i8] c"external-class\00"
@.str.14335 = private unnamed_addr constant [16 x i8] c"external-object\00"
@.str.14343 = private unnamed_addr constant [12 x i8] c"  External \00"
@.str.14352 = private unnamed_addr constant [2 x i8] c" \00"
@.str.14356 = private unnamed_addr constant [3 x i8] c"\0A\00"
@.str.14418 = private unnamed_addr constant [7 x i8] c"import\00"
@.str.14426 = private unnamed_addr constant [15 x i8] c"Symbol import \00"
@.str.14430 = private unnamed_addr constant [3 x i8] c"\0A\00"
@.str.14467 = private unnamed_addr constant [22 x i8] c"error: parse failed\0A\00"
@.str.14475 = private unnamed_addr constant [10 x i8] c"Program\0A\00"
@.str.14531 = private unnamed_addr constant [6 x i8] c"Decl \00"
@.str.14535 = private unnamed_addr constant [2 x i8] c" \00"
@.str.14539 = private unnamed_addr constant [3 x i8] c"\0A\00"
@.str.14547 = private unnamed_addr constant [10 x i8] c"attribute\00"
@.str.14555 = private unnamed_addr constant [11 x i8] c"Attribute \00"
@.str.14564 = private unnamed_addr constant [3 x i8] c"\0A\00"
@.str.14573 = private unnamed_addr constant [9 x i8] c"template\00"
@.str.14581 = private unnamed_addr constant [17 x i8] c"Template target \00"
@.str.14590 = private unnamed_addr constant [8 x i8] c" params\00"
@.str.14599 = private unnamed_addr constant [3 x i8] c"\0A\00"
@.str.14608 = private unnamed_addr constant [9 x i8] c"function\00"
@.str.14615 = private unnamed_addr constant [18 x i8] c"external-function\00"
@.str.14622 = private unnamed_addr constant [9 x i8] c"template\00"
@.str.14674 = private unnamed_addr constant [15 x i8] c"  Body tokens=\00"
@.str.14682 = private unnamed_addr constant [3 x i8] c"\0A\00"
@.str.14710 = private unnamed_addr constant [6 x i8] c"class\00"
@.str.14717 = private unnamed_addr constant [7 x i8] c"object\00"
@.str.14724 = private unnamed_addr constant [15 x i8] c"external-class\00"
@.str.14731 = private unnamed_addr constant [16 x i8] c"external-object\00"
@.str.14783 = private unnamed_addr constant [15 x i8] c"  Body tokens=\00"
@.str.14791 = private unnamed_addr constant [3 x i8] c"\0A\00"
@.str.15002 = private unnamed_addr constant [7 x i8] c"return\00"
@.str.15088 = private unnamed_addr constant [1 x i8] c"\00"
@.str.15137 = private unnamed_addr constant [4 x i8] c"and\00"
@.str.15145 = private unnamed_addr constant [3 x i8] c"&&\00"
@.str.15166 = private unnamed_addr constant [3 x i8] c"or\00"
@.str.15174 = private unnamed_addr constant [3 x i8] c"||\00"
@.str.15195 = private unnamed_addr constant [4 x i8] c"xor\00"
@.str.15203 = private unnamed_addr constant [2 x i8] c"^\00"
@.str.15228 = private unnamed_addr constant [2 x i8] c" \00"
@.str.15258 = private unnamed_addr constant [8 x i8] c"Boolean\00"
@.str.15263 = private unnamed_addr constant [4 x i8] c"int\00"
@.str.15272 = private unnamed_addr constant [5 x i8] c"Char\00"
@.str.15277 = private unnamed_addr constant [5 x i8] c"char\00"
@.str.15286 = private unnamed_addr constant [4 x i8] c"Int\00"
@.str.15291 = private unnamed_addr constant [4 x i8] c"int\00"
@.str.15300 = private unnamed_addr constant [5 x i8] c"Long\00"
@.str.15305 = private unnamed_addr constant [10 x i8] c"long long\00"
@.str.15314 = private unnamed_addr constant [6 x i8] c"Float\00"
@.str.15319 = private unnamed_addr constant [6 x i8] c"float\00"
@.str.15328 = private unnamed_addr constant [7 x i8] c"Double\00"
@.str.15333 = private unnamed_addr constant [7 x i8] c"double\00"
@.str.15342 = private unnamed_addr constant [7 x i8] c"String\00"
@.str.15347 = private unnamed_addr constant [12 x i8] c"const char*\00"
@.str.15356 = private unnamed_addr constant [6 x i8] c"Regex\00"
@.str.15361 = private unnamed_addr constant [12 x i8] c"const char*\00"
@.str.15370 = private unnamed_addr constant [6 x i8] c"Array\00"
@.str.15375 = private unnamed_addr constant [6 x i8] c"void*\00"
@.str.15384 = private unnamed_addr constant [5 x i8] c"Unit\00"
@.str.15389 = private unnamed_addr constant [5 x i8] c"void\00"
@.str.15393 = private unnamed_addr constant [6 x i8] c"void*\00"
@.str.15423 = private unnamed_addr constant [1 x i8] c"\00"
@.str.15491 = private unnamed_addr constant [7 x i8] c"return\00"
@.str.15501 = private unnamed_addr constant [8 x i8] c"return \00"
@.str.15514 = private unnamed_addr constant [4 x i8] c";\0A\00"
@.str.15524 = private unnamed_addr constant [6 x i8] c"value\00"
@.str.15531 = private unnamed_addr constant [9 x i8] c"variable\00"
@.str.15606 = private unnamed_addr constant [2 x i8] c" \00"
@.str.15617 = private unnamed_addr constant [4 x i8] c" = \00"
@.str.15630 = private unnamed_addr constant [4 x i8] c";\0A\00"
@.str.15646 = private unnamed_addr constant [4 x i8] c"Int\00"
@.str.15660 = private unnamed_addr constant [2 x i8] c" \00"
@.str.15671 = private unnamed_addr constant [8 x i8] c" = 0;\0A\00"
@.str.15682 = private unnamed_addr constant [3 x i8] c"if\00"
@.str.15689 = private unnamed_addr constant [6 x i8] c"while\00"
@.str.15706 = private unnamed_addr constant [2 x i8] c"(\00"
@.str.15722 = private unnamed_addr constant [2 x i8] c"(\00"
@.str.15724 = private unnamed_addr constant [2 x i8] c")\00"
@.str.15742 = private unnamed_addr constant [2 x i8] c"{\00"
@.str.15758 = private unnamed_addr constant [2 x i8] c"{\00"
@.str.15760 = private unnamed_addr constant [2 x i8] c"}\00"
@.str.15790 = private unnamed_addr constant [3 x i8] c" (\00"
@.str.15803 = private unnamed_addr constant [6 x i8] c") {\0A\00"
@.str.15817 = private unnamed_addr constant [5 x i8] c"    \00"
@.str.15822 = private unnamed_addr constant [4 x i8] c"}\0A\00"
@.str.15830 = private unnamed_addr constant [3 x i8] c"if\00"
@.str.15864 = private unnamed_addr constant [5 x i8] c"else\00"
@.str.15894 = private unnamed_addr constant [2 x i8] c"{\00"
@.str.15911 = private unnamed_addr constant [2 x i8] c"{\00"
@.str.15913 = private unnamed_addr constant [2 x i8] c"}\00"
@.str.15929 = private unnamed_addr constant [9 x i8] c"else {\0A\00"
@.str.15943 = private unnamed_addr constant [5 x i8] c"    \00"
@.str.15948 = private unnamed_addr constant [4 x i8] c"}\0A\00"
@.str.15963 = private unnamed_addr constant [4 x i8] c"for\00"
@.str.16038 = private unnamed_addr constant [3 x i8] c"<-\00"
@.str.16104 = private unnamed_addr constant [4 x i8] c" < \00"
@.str.16117 = private unnamed_addr constant [3 x i8] c"to\00"
@.str.16129 = private unnamed_addr constant [3 x i8] c"..\00"
@.str.16135 = private unnamed_addr constant [5 x i8] c" <= \00"
@.str.16158 = private unnamed_addr constant [10 x i8] c"for (int \00"
@.str.16162 = private unnamed_addr constant [4 x i8] c" = \00"
@.str.16175 = private unnamed_addr constant [3 x i8] c"; \00"
@.str.16192 = private unnamed_addr constant [3 x i8] c"; \00"
@.str.16196 = private unnamed_addr constant [8 x i8] c"++) {\0A\00"
@.str.16210 = private unnamed_addr constant [5 x i8] c"    \00"
@.str.16215 = private unnamed_addr constant [4 x i8] c"}\0A\00"
@.str.16226 = private unnamed_addr constant [9 x i8] c"/* for (\00"
@.str.16237 = private unnamed_addr constant [7 x i8] c") */\0A\00"
@.str.16277 = private unnamed_addr constant [4 x i8] c"map\00"
@.str.16284 = private unnamed_addr constant [5 x i8] c"pmap\00"
@.str.16291 = private unnamed_addr constant [7 x i8] c"reduce\00"
@.str.16298 = private unnamed_addr constant [8 x i8] c"preduce\00"
@.str.16305 = private unnamed_addr constant [7 x i8] c"filter\00"
@.str.16343 = private unnamed_addr constant [4 x i8] c"/* \00"
@.str.16347 = private unnamed_addr constant [3 x i8] c" (\00"
@.str.16358 = private unnamed_addr constant [7 x i8] c") */\0A\00"
@.str.16407 = private unnamed_addr constant [4 x i8] c";\0A\00"
@.str.16464 = private unnamed_addr constant [7 x i8] c"return\00"
@.str.16471 = private unnamed_addr constant [8 x i8] c"return \00"
@.str.16484 = private unnamed_addr constant [4 x i8] c";\0A\00"
@.str.16493 = private unnamed_addr constant [6 x i8] c"value\00"
@.str.16500 = private unnamed_addr constant [9 x i8] c"variable\00"
@.str.16572 = private unnamed_addr constant [2 x i8] c" \00"
@.str.16583 = private unnamed_addr constant [4 x i8] c" = \00"
@.str.16596 = private unnamed_addr constant [4 x i8] c";\0A\00"
@.str.16610 = private unnamed_addr constant [4 x i8] c"Int\00"
@.str.16621 = private unnamed_addr constant [2 x i8] c" \00"
@.str.16632 = private unnamed_addr constant [8 x i8] c" = 0;\0A\00"
@.str.16641 = private unnamed_addr constant [3 x i8] c"if\00"
@.str.16648 = private unnamed_addr constant [6 x i8] c"while\00"
@.str.16655 = private unnamed_addr constant [4 x i8] c"for\00"
@.str.16662 = private unnamed_addr constant [4 x i8] c"map\00"
@.str.16669 = private unnamed_addr constant [5 x i8] c"pmap\00"
@.str.16676 = private unnamed_addr constant [7 x i8] c"reduce\00"
@.str.16683 = private unnamed_addr constant [8 x i8] c"preduce\00"
@.str.16690 = private unnamed_addr constant [7 x i8] c"filter\00"
@.str.16697 = private unnamed_addr constant [33 x i8] c"/* unsupported nested block */\0A\00"
@.str.16712 = private unnamed_addr constant [4 x i8] c";\0A\00"
@.str.16758 = private unnamed_addr constant [4 x i8] c"def\00"
@.str.16773 = private unnamed_addr constant [5 x i8] c"main\00"
@.str.16788 = private unnamed_addr constant [2 x i8] c"(\00"
@.str.16803 = private unnamed_addr constant [2 x i8] c")\00"
@.str.16818 = private unnamed_addr constant [2 x i8] c":\00"
@.str.16832 = private unnamed_addr constant [4 x i8] c"Int\00"
@.str.16847 = private unnamed_addr constant [2 x i8] c"{\00"
@.str.16965 = private unnamed_addr constant [4 x i8] c"def\00"
@.str.16980 = private unnamed_addr constant [5 x i8] c"main\00"
@.str.16995 = private unnamed_addr constant [2 x i8] c"(\00"
@.str.17010 = private unnamed_addr constant [2 x i8] c")\00"
@.str.17025 = private unnamed_addr constant [2 x i8] c":\00"
@.str.17039 = private unnamed_addr constant [4 x i8] c"Int\00"
@.str.17079 = private unnamed_addr constant [36 x i8] c"int main(int argc, char** argv) {\0A\00"
@.str.17081 = private unnamed_addr constant [18 x i8] c"    (void)argc;\0A\00"
@.str.17083 = private unnamed_addr constant [18 x i8] c"    (void)argv;\0A\00"
@.str.17093 = private unnamed_addr constant [5 x i8] c"    \00"
@.str.17096 = private unnamed_addr constant [16 x i8] c"    return 0;\0A\00"
@.str.17098 = private unnamed_addr constant [4 x i8] c"}\0A\00"
@.str.17110 = private unnamed_addr constant [1 x i8] c"\00"
@.str.17129 = private unnamed_addr constant [8 x i8] c"Boolean\00"
@.str.17134 = private unnamed_addr constant [3 x i8] c"i1\00"
@.str.17143 = private unnamed_addr constant [5 x i8] c"Char\00"
@.str.17148 = private unnamed_addr constant [3 x i8] c"i8\00"
@.str.17157 = private unnamed_addr constant [4 x i8] c"Int\00"
@.str.17162 = private unnamed_addr constant [4 x i8] c"i32\00"
@.str.17171 = private unnamed_addr constant [5 x i8] c"Long\00"
@.str.17176 = private unnamed_addr constant [4 x i8] c"i64\00"
@.str.17185 = private unnamed_addr constant [6 x i8] c"Float\00"
@.str.17190 = private unnamed_addr constant [6 x i8] c"float\00"
@.str.17199 = private unnamed_addr constant [7 x i8] c"Double\00"
@.str.17204 = private unnamed_addr constant [7 x i8] c"double\00"
@.str.17213 = private unnamed_addr constant [5 x i8] c"Unit\00"
@.str.17218 = private unnamed_addr constant [5 x i8] c"void\00"
@.str.17227 = private unnamed_addr constant [7 x i8] c"String\00"
@.str.17232 = private unnamed_addr constant [4 x i8] c"ptr\00"
@.str.17241 = private unnamed_addr constant [6 x i8] c"Regex\00"
@.str.17246 = private unnamed_addr constant [4 x i8] c"ptr\00"
@.str.17255 = private unnamed_addr constant [6 x i8] c"Range\00"
@.str.17260 = private unnamed_addr constant [4 x i8] c"ptr\00"
@.str.17269 = private unnamed_addr constant [6 x i8] c"Array\00"
@.str.17274 = private unnamed_addr constant [4 x i8] c"ptr\00"
@.str.17287 = private unnamed_addr constant [4 x i8] c"ptr\00"
@.str.17291 = private unnamed_addr constant [4 x i8] c"ptr\00"
@.str.17310 = private unnamed_addr constant [2 x i8] c"+\00"
@.str.17315 = private unnamed_addr constant [4 x i8] c"add\00"
@.str.17324 = private unnamed_addr constant [2 x i8] c"-\00"
@.str.17329 = private unnamed_addr constant [4 x i8] c"sub\00"
@.str.17338 = private unnamed_addr constant [2 x i8] c"*\00"
@.str.17343 = private unnamed_addr constant [4 x i8] c"mul\00"
@.str.17352 = private unnamed_addr constant [2 x i8] c"/\00"
@.str.17357 = private unnamed_addr constant [5 x i8] c"sdiv\00"
@.str.17366 = private unnamed_addr constant [2 x i8] c"%\00"
@.str.17371 = private unnamed_addr constant [5 x i8] c"srem\00"
@.str.17380 = private unnamed_addr constant [3 x i8] c"<<\00"
@.str.17385 = private unnamed_addr constant [4 x i8] c"shl\00"
@.str.17394 = private unnamed_addr constant [3 x i8] c">>\00"
@.str.17399 = private unnamed_addr constant [5 x i8] c"ashr\00"
@.str.17408 = private unnamed_addr constant [2 x i8] c"&\00"
@.str.17413 = private unnamed_addr constant [4 x i8] c"and\00"
@.str.17422 = private unnamed_addr constant [2 x i8] c"|\00"
@.str.17427 = private unnamed_addr constant [3 x i8] c"or\00"
@.str.17436 = private unnamed_addr constant [2 x i8] c"^\00"
@.str.17443 = private unnamed_addr constant [4 x i8] c"xor\00"
@.str.17448 = private unnamed_addr constant [4 x i8] c"xor\00"
@.str.17457 = private unnamed_addr constant [4 x i8] c"and\00"
@.str.17464 = private unnamed_addr constant [3 x i8] c"&&\00"
@.str.17469 = private unnamed_addr constant [4 x i8] c"and\00"
@.str.17478 = private unnamed_addr constant [3 x i8] c"or\00"
@.str.17485 = private unnamed_addr constant [3 x i8] c"||\00"
@.str.17490 = private unnamed_addr constant [3 x i8] c"or\00"
@.str.17499 = private unnamed_addr constant [3 x i8] c"==\00"
@.str.17504 = private unnamed_addr constant [8 x i8] c"icmp_eq\00"
@.str.17513 = private unnamed_addr constant [3 x i8] c"!=\00"
@.str.17518 = private unnamed_addr constant [8 x i8] c"icmp_ne\00"
@.str.17527 = private unnamed_addr constant [2 x i8] c"<\00"
@.str.17532 = private unnamed_addr constant [9 x i8] c"icmp_slt\00"
@.str.17541 = private unnamed_addr constant [3 x i8] c"<=\00"
@.str.17546 = private unnamed_addr constant [9 x i8] c"icmp_sle\00"
@.str.17555 = private unnamed_addr constant [2 x i8] c">\00"
@.str.17560 = private unnamed_addr constant [9 x i8] c"icmp_sgt\00"
@.str.17569 = private unnamed_addr constant [3 x i8] c">=\00"
@.str.17574 = private unnamed_addr constant [9 x i8] c"icmp_sge\00"
@.str.17583 = private unnamed_addr constant [3 x i8] c"..\00"
@.str.17588 = private unnamed_addr constant [6 x i8] c"range\00"
@.str.17597 = private unnamed_addr constant [3 x i8] c"to\00"
@.str.17602 = private unnamed_addr constant [9 x i8] c"range_to\00"
@.str.17611 = private unnamed_addr constant [6 x i8] c"until\00"
@.str.17616 = private unnamed_addr constant [12 x i8] c"range_until\00"
@.str.17625 = private unnamed_addr constant [2 x i8] c"@\00"
@.str.17630 = private unnamed_addr constant [7 x i8] c"matmul\00"
@.str.17639 = private unnamed_addr constant [6 x i8] c"inner\00"
@.str.17644 = private unnamed_addr constant [6 x i8] c"inner\00"
@.str.17653 = private unnamed_addr constant [6 x i8] c"outer\00"
@.str.17658 = private unnamed_addr constant [6 x i8] c"outer\00"
@.str.17667 = private unnamed_addr constant [7 x i8] c"tensor\00"
@.str.17672 = private unnamed_addr constant [7 x i8] c"tensor\00"
@.str.18021 = private unnamed_addr constant [5 x i8] c"void\00"
@.str.18080 = private unnamed_addr constant [2 x i8] c" \00"
@.str.18084 = private unnamed_addr constant [3 x i8] c" (\00"
@.str.18095 = private unnamed_addr constant [5 x i8] c"), (\00"
@.str.18108 = private unnamed_addr constant [2 x i8] c")\00"
@.str.18142 = private unnamed_addr constant [2 x i8] c"(\00"
@.str.18155 = private unnamed_addr constant [2 x i8] c"(\00"
@.str.18157 = private unnamed_addr constant [2 x i8] c")\00"
@.str.18166 = private unnamed_addr constant [6 x i8] c"call \00"
@.str.18170 = private unnamed_addr constant [3 x i8] c" @\00"
@.str.18179 = private unnamed_addr constant [2 x i8] c"(\00"
@.str.18194 = private unnamed_addr constant [2 x i8] c")\00"
@.str.18218 = private unnamed_addr constant [6 x i8] c"load \00"
@.str.18222 = private unnamed_addr constant [8 x i8] c", ptr %\00"
@.str.18235 = private unnamed_addr constant [2 x i8] c" \00"
@.str.18300 = private unnamed_addr constant [1 x i8] c"\00"
@.str.18349 = private unnamed_addr constant [2 x i8] c"=\00"
@.str.18356 = private unnamed_addr constant [3 x i8] c"<-\00"
@.str.18361 = private unnamed_addr constant [11 x i8] c"    store \00"
@.str.18365 = private unnamed_addr constant [8 x i8] c", ptr %\00"
@.str.18369 = private unnamed_addr constant [3 x i8] c"\0A\00"
@.str.18418 = private unnamed_addr constant [3 x i8] c"%=\00"
@.str.18424 = private unnamed_addr constant [2 x i8] c"%\00"
@.str.18428 = private unnamed_addr constant [10 x i8] c"    %old.\00"
@.str.18432 = private unnamed_addr constant [9 x i8] c" = load \00"
@.str.18436 = private unnamed_addr constant [8 x i8] c", ptr %\00"
@.str.18440 = private unnamed_addr constant [3 x i8] c"\0A\00"
@.str.18442 = private unnamed_addr constant [10 x i8] c"    %new.\00"
@.str.18446 = private unnamed_addr constant [4 x i8] c" = \00"
@.str.18453 = private unnamed_addr constant [2 x i8] c" \00"
@.str.18457 = private unnamed_addr constant [7 x i8] c" %old.\00"
@.str.18461 = private unnamed_addr constant [4 x i8] c", (\00"
@.str.18483 = private unnamed_addr constant [4 x i8] c")\0A\00"
@.str.18485 = private unnamed_addr constant [11 x i8] c"    store \00"
@.str.18489 = private unnamed_addr constant [7 x i8] c" %new.\00"
@.str.18493 = private unnamed_addr constant [8 x i8] c", ptr %\00"
@.str.18497 = private unnamed_addr constant [3 x i8] c"\0A\00"
@.str.18534 = private unnamed_addr constant [1 x i8] c"\00"
@.str.18563 = private unnamed_addr constant [1 x i8] c"\00"
@.str.18609 = private unnamed_addr constant [8 x i8] c"unknown\00"
@.str.18625 = private unnamed_addr constant [2 x i8] c":\00"
@.str.18653 = private unnamed_addr constant [3 x i8] c", \00"
@.str.18665 = private unnamed_addr constant [3 x i8] c" %\00"
@.str.18696 = private unnamed_addr constant [2 x i8] c",\00"
@.str.18719 = private unnamed_addr constant [2 x i8] c",\00"
@.str.18758 = private unnamed_addr constant [1 x i8] c"\00"
@.str.18826 = private unnamed_addr constant [7 x i8] c"return\00"
@.str.18834 = private unnamed_addr constant [9 x i8] c"    ret \00"
@.str.18847 = private unnamed_addr constant [3 x i8] c"\0A\00"
@.str.18857 = private unnamed_addr constant [6 x i8] c"value\00"
@.str.18864 = private unnamed_addr constant [9 x i8] c"variable\00"
@.str.18911 = private unnamed_addr constant [6 x i8] c"    %\00"
@.str.18922 = private unnamed_addr constant [11 x i8] c" = alloca \00"
@.str.18929 = private unnamed_addr constant [3 x i8] c"\0A\00"
@.str.18931 = private unnamed_addr constant [11 x i8] c"    store \00"
@.str.18944 = private unnamed_addr constant [8 x i8] c", ptr %\00"
@.str.18955 = private unnamed_addr constant [3 x i8] c"\0A\00"
@.str.18964 = private unnamed_addr constant [6 x i8] c"    %\00"
@.str.18975 = private unnamed_addr constant [16 x i8] c" = alloca ptr\0A\00"
@.str.18986 = private unnamed_addr constant [3 x i8] c"if\00"
@.str.18993 = private unnamed_addr constant [6 x i8] c"while\00"
@.str.19000 = private unnamed_addr constant [4 x i8] c"for\00"
@.str.19007 = private unnamed_addr constant [4 x i8] c"map\00"
@.str.19014 = private unnamed_addr constant [5 x i8] c"pmap\00"
@.str.19021 = private unnamed_addr constant [7 x i8] c"reduce\00"
@.str.19028 = private unnamed_addr constant [8 x i8] c"preduce\00"
@.str.19035 = private unnamed_addr constant [7 x i8] c"filter\00"
@.str.19043 = private unnamed_addr constant [20 x i8] c"    ; nested block \00"
@.str.19047 = private unnamed_addr constant [3 x i8] c" (\00"
@.str.19058 = private unnamed_addr constant [4 x i8] c")\0A\00"
@.str.19099 = private unnamed_addr constant [5 x i8] c"    \00"
@.str.19110 = private unnamed_addr constant [3 x i8] c"\0A\00"
@.str.19157 = private unnamed_addr constant [21 x i8] c"    ; no else body\0A\00"
@.str.19186 = private unnamed_addr constant [2 x i8] c"{\00"
@.str.19203 = private unnamed_addr constant [2 x i8] c"{\00"
@.str.19205 = private unnamed_addr constant [2 x i8] c"}\00"
@.str.19241 = private unnamed_addr constant [3 x i8] c"if\00"
@.str.19246 = private unnamed_addr constant [21 x i8] c"    ; else-if body\0A\00"
@.str.19250 = private unnamed_addr constant [28 x i8] c"    ; malformed else body\0A\00"
@.str.19326 = private unnamed_addr constant [2 x i8] c"{\00"
@.str.19328 = private unnamed_addr constant [2 x i8] c"}\00"
@.str.19351 = private unnamed_addr constant [21 x i8] c"    ; malformed if\0A\00"
@.str.19359 = private unnamed_addr constant [1 x i8] c"\00"
@.str.19400 = private unnamed_addr constant [5 x i8] c"else\00"
@.str.19410 = private unnamed_addr constant [11 x i8] c"    %cond.\00"
@.str.19414 = private unnamed_addr constant [4 x i8] c" = \00"
@.str.19427 = private unnamed_addr constant [3 x i8] c"\0A\00"
@.str.19429 = private unnamed_addr constant [17 x i8] c"    br i1 %cond.\00"
@.str.19433 = private unnamed_addr constant [18 x i8] c", label %if.then.\00"
@.str.19437 = private unnamed_addr constant [18 x i8] c", label %if.else.\00"
@.str.19441 = private unnamed_addr constant [3 x i8] c"\0A\00"
@.str.19443 = private unnamed_addr constant [9 x i8] c"if.then.\00"
@.str.19447 = private unnamed_addr constant [4 x i8] c":\0A\00"
@.str.19460 = private unnamed_addr constant [22 x i8] c"    br label %if.end.\00"
@.str.19464 = private unnamed_addr constant [3 x i8] c"\0A\00"
@.str.19466 = private unnamed_addr constant [9 x i8] c"if.else.\00"
@.str.19470 = private unnamed_addr constant [4 x i8] c":\0A\00"
@.str.19483 = private unnamed_addr constant [22 x i8] c"    br label %if.end.\00"
@.str.19487 = private unnamed_addr constant [3 x i8] c"\0A\00"
@.str.19489 = private unnamed_addr constant [8 x i8] c"if.end.\00"
@.str.19493 = private unnamed_addr constant [4 x i8] c":\0A\00"
@.str.19569 = private unnamed_addr constant [2 x i8] c"{\00"
@.str.19571 = private unnamed_addr constant [2 x i8] c"}\00"
@.str.19594 = private unnamed_addr constant [24 x i8] c"    ; malformed while\0A\00"
@.str.19602 = private unnamed_addr constant [1 x i8] c"\00"
@.str.19607 = private unnamed_addr constant [26 x i8] c"    br label %while.cond.\00"
@.str.19611 = private unnamed_addr constant [3 x i8] c"\0A\00"
@.str.19613 = private unnamed_addr constant [12 x i8] c"while.cond.\00"
@.str.19617 = private unnamed_addr constant [4 x i8] c":\0A\00"
@.str.19619 = private unnamed_addr constant [16 x i8] c"    %whilecond.\00"
@.str.19623 = private unnamed_addr constant [4 x i8] c" = \00"
@.str.19636 = private unnamed_addr constant [3 x i8] c"\0A\00"
@.str.19638 = private unnamed_addr constant [22 x i8] c"    br i1 %whilecond.\00"
@.str.19642 = private unnamed_addr constant [21 x i8] c", label %while.body.\00"
@.str.19646 = private unnamed_addr constant [20 x i8] c", label %while.end.\00"
@.str.19650 = private unnamed_addr constant [3 x i8] c"\0A\00"
@.str.19652 = private unnamed_addr constant [12 x i8] c"while.body.\00"
@.str.19656 = private unnamed_addr constant [4 x i8] c":\0A\00"
@.str.19669 = private unnamed_addr constant [26 x i8] c"    br label %while.cond.\00"
@.str.19673 = private unnamed_addr constant [3 x i8] c"\0A\00"
@.str.19675 = private unnamed_addr constant [11 x i8] c"while.end.\00"
@.str.19679 = private unnamed_addr constant [4 x i8] c":\0A\00"
@.str.19755 = private unnamed_addr constant [2 x i8] c"{\00"
@.str.19757 = private unnamed_addr constant [2 x i8] c"}\00"
@.str.19780 = private unnamed_addr constant [22 x i8] c"    ; malformed for\0A\00"
@.str.19812 = private unnamed_addr constant [3 x i8] c"<-\00"
@.str.19823 = private unnamed_addr constant [29 x i8] c"    ; malformed for source\0A\00"
@.str.19831 = private unnamed_addr constant [1 x i8] c"\00"
@.str.19836 = private unnamed_addr constant [18 x i8] c"    ; for source \00"
@.str.19849 = private unnamed_addr constant [3 x i8] c"\0A\00"
@.str.19851 = private unnamed_addr constant [6 x i8] c"    %\00"
@.str.19855 = private unnamed_addr constant [16 x i8] c" = alloca ptr\0A\00"
@.str.19857 = private unnamed_addr constant [24 x i8] c"    br label %for.cond.\00"
@.str.19861 = private unnamed_addr constant [3 x i8] c"\0A\00"
@.str.19863 = private unnamed_addr constant [10 x i8] c"for.cond.\00"
@.str.19867 = private unnamed_addr constant [4 x i8] c":\0A\00"
@.str.19869 = private unnamed_addr constant [21 x i8] c"    ; iterator next \00"
@.str.19873 = private unnamed_addr constant [3 x i8] c"\0A\00"
@.str.19875 = private unnamed_addr constant [24 x i8] c"    br i1 %for.hasnext.\00"
@.str.19879 = private unnamed_addr constant [19 x i8] c", label %for.body.\00"
@.str.19883 = private unnamed_addr constant [18 x i8] c", label %for.end.\00"
@.str.19887 = private unnamed_addr constant [3 x i8] c"\0A\00"
@.str.19889 = private unnamed_addr constant [10 x i8] c"for.body.\00"
@.str.19893 = private unnamed_addr constant [4 x i8] c":\0A\00"
@.str.19906 = private unnamed_addr constant [24 x i8] c"    br label %for.cond.\00"
@.str.19910 = private unnamed_addr constant [3 x i8] c"\0A\00"
@.str.19912 = private unnamed_addr constant [9 x i8] c"for.end.\00"
@.str.19916 = private unnamed_addr constant [4 x i8] c":\0A\00"
@.str.19942 = private unnamed_addr constant [1 x i8] c"\00"
@.str.20010 = private unnamed_addr constant [7 x i8] c"return\00"
@.str.20018 = private unnamed_addr constant [9 x i8] c"    ret \00"
@.str.20031 = private unnamed_addr constant [3 x i8] c"\0A\00"
@.str.20041 = private unnamed_addr constant [6 x i8] c"value\00"
@.str.20048 = private unnamed_addr constant [9 x i8] c"variable\00"
@.str.20095 = private unnamed_addr constant [6 x i8] c"    %\00"
@.str.20106 = private unnamed_addr constant [11 x i8] c" = alloca \00"
@.str.20113 = private unnamed_addr constant [3 x i8] c"\0A\00"
@.str.20115 = private unnamed_addr constant [11 x i8] c"    store \00"
@.str.20128 = private unnamed_addr constant [8 x i8] c", ptr %\00"
@.str.20139 = private unnamed_addr constant [3 x i8] c"\0A\00"
@.str.20148 = private unnamed_addr constant [6 x i8] c"    %\00"
@.str.20159 = private unnamed_addr constant [16 x i8] c" = alloca ptr\0A\00"
@.str.20170 = private unnamed_addr constant [3 x i8] c"if\00"
@.str.20195 = private unnamed_addr constant [6 x i8] c"while\00"
@.str.20220 = private unnamed_addr constant [4 x i8] c"for\00"
@.str.20245 = private unnamed_addr constant [4 x i8] c"map\00"
@.str.20252 = private unnamed_addr constant [5 x i8] c"pmap\00"
@.str.20259 = private unnamed_addr constant [7 x i8] c"reduce\00"
@.str.20266 = private unnamed_addr constant [8 x i8] c"preduce\00"
@.str.20273 = private unnamed_addr constant [7 x i8] c"filter\00"
@.str.20281 = private unnamed_addr constant [13 x i8] c"    ; block \00"
@.str.20285 = private unnamed_addr constant [3 x i8] c" (\00"
@.str.20296 = private unnamed_addr constant [4 x i8] c")\0A\00"
@.str.20337 = private unnamed_addr constant [5 x i8] c"    \00"
@.str.20348 = private unnamed_addr constant [3 x i8] c"\0A\00"
@.str.20381 = private unnamed_addr constant [1 x i8] c"\00"
@.str.20439 = private unnamed_addr constant [9 x i8] c"function\00"
@.str.20446 = private unnamed_addr constant [18 x i8] c"external-function\00"
@.str.20454 = private unnamed_addr constant [8 x i8] c"define \00"
@.str.20466 = private unnamed_addr constant [3 x i8] c" @\00"
@.str.20470 = private unnamed_addr constant [2 x i8] c"(\00"
@.str.20479 = private unnamed_addr constant [4 x i8] c")\0A\00"
@.str.20534 = private unnamed_addr constant [13 x i8] c"end define\0A\00"
@.str.20544 = private unnamed_addr constant [6 x i8] c"class\00"
@.str.20551 = private unnamed_addr constant [7 x i8] c"object\00"
@.str.20558 = private unnamed_addr constant [15 x i8] c"external-class\00"
@.str.20565 = private unnamed_addr constant [16 x i8] c"external-object\00"
@.str.20573 = private unnamed_addr constant [7 x i8] c"%type.\00"
@.str.20577 = private unnamed_addr constant [18 x i8] c" = type opaque ; \00"
@.str.20581 = private unnamed_addr constant [3 x i8] c"\0A\00"
@.str.20591 = private unnamed_addr constant [6 x i8] c"value\00"
@.str.20598 = private unnamed_addr constant [9 x i8] c"variable\00"
@.str.20606 = private unnamed_addr constant [2 x i8] c"@\00"
@.str.20610 = private unnamed_addr constant [22 x i8] c" = global ptr null ; \00"
@.str.20614 = private unnamed_addr constant [3 x i8] c"\0A\00"
@.str.20656 = private unnamed_addr constant [22 x i8] c"error: parse failed\0A\00"
@.str.20670 = private unnamed_addr constant [23 x i8] c"module csec.selfhost\0A\00"
@.str.20677 = private unnamed_addr constant [13 x i8] c"entry main\0A\00"
@.str.20679 = private unnamed_addr constant [21 x i8] c"lowering llvm-text\0A\00"
@.str.20686 = private unnamed_addr constant [13 x i8] c"main.return \00"
@.str.20690 = private unnamed_addr constant [3 x i8] c"\0A\00"
@.str.20714 = private unnamed_addr constant [9 x i8] c"entry:\0A\00"
@.str.20716 = private unnamed_addr constant [11 x i8] c"  ret i32 \00"
@.str.20720 = private unnamed_addr constant [3 x i8] c"\0A\00"
@.str.20743 = private unnamed_addr constant [2 x i8] c"0\00"
@.str.20766 = private unnamed_addr constant [3 x i8] c"73\00"
@.str.20777 = private unnamed_addr constant [3 x i8] c"75\00"
@.str.20788 = private unnamed_addr constant [3 x i8] c"78\00"
@.str.20799 = private unnamed_addr constant [3 x i8] c"70\00"
@.str.20810 = private unnamed_addr constant [3 x i8] c"83\00"
@.str.20821 = private unnamed_addr constant [3 x i8] c"82\00"
@.str.20832 = private unnamed_addr constant [3 x i8] c"67\00"
@.str.20843 = private unnamed_addr constant [3 x i8] c"66\00"
@.str.20854 = private unnamed_addr constant [3 x i8] c"79\00"
@.str.20865 = private unnamed_addr constant [3 x i8] c"77\00"
@.str.20876 = private unnamed_addr constant [3 x i8] c"69\00"
@.str.20887 = private unnamed_addr constant [4 x i8] c"120\00"
@.str.20898 = private unnamed_addr constant [4 x i8] c"121\00"
@.str.20909 = private unnamed_addr constant [4 x i8] c"122\00"
@.str.20920 = private unnamed_addr constant [3 x i8] c"97\00"
@.str.20931 = private unnamed_addr constant [4 x i8] c"116\00"
@.str.20942 = private unnamed_addr constant [4 x i8] c"117\00"
@.str.20953 = private unnamed_addr constant [3 x i8] c"48\00"
@.str.20964 = private unnamed_addr constant [3 x i8] c"49\00"
@.str.20975 = private unnamed_addr constant [3 x i8] c"50\00"
@.str.20986 = private unnamed_addr constant [3 x i8] c"51\00"
@.str.20997 = private unnamed_addr constant [3 x i8] c"52\00"
@.str.21008 = private unnamed_addr constant [3 x i8] c"53\00"
@.str.21019 = private unnamed_addr constant [3 x i8] c"54\00"
@.str.21030 = private unnamed_addr constant [3 x i8] c"55\00"
@.str.21041 = private unnamed_addr constant [3 x i8] c"56\00"
@.str.21052 = private unnamed_addr constant [3 x i8] c"57\00"
@.str.21063 = private unnamed_addr constant [3 x i8] c"95\00"
@.str.21074 = private unnamed_addr constant [3 x i8] c"32\00"
@.str.21085 = private unnamed_addr constant [3 x i8] c"34\00"
@.str.21111 = private unnamed_addr constant [3 x i8] c"92\00"
@.str.21137 = private unnamed_addr constant [3 x i8] c"10\00"
@.str.21163 = private unnamed_addr constant [2 x i8] c"9\00"
@.str.21167 = private unnamed_addr constant [2 x i8] c"0\00"
@.str.21210 = private unnamed_addr constant [2 x i8] c"0\00"
@.str.21295 = private unnamed_addr constant [2 x i8] c"%\00"
@.str.21304 = private unnamed_addr constant [6 x i8] c".val.\00"
@.str.21310 = private unnamed_addr constant [5 x i8] c"%tmp\00"
@.str.21351 = private unnamed_addr constant [8 x i8] c"unknown\00"
@.str.21374 = private unnamed_addr constant [8 x i8] c"unknown\00"
@.str.21395 = private unnamed_addr constant [2 x i8] c"(\00"
@.str.21397 = private unnamed_addr constant [2 x i8] c")\00"
@.str.21408 = private unnamed_addr constant [8 x i8] c"unknown\00"
@.str.21478 = private unnamed_addr constant [2 x i8] c":\00"
@.str.21496 = private unnamed_addr constant [8 x i8] c"unknown\00"
@.str.21516 = private unnamed_addr constant [2 x i8] c",\00"
@.str.21535 = private unnamed_addr constant [8 x i8] c"unknown\00"
@.str.21577 = private unnamed_addr constant [8 x i8] c"unknown\00"
@.str.21633 = private unnamed_addr constant [1 x i8] c"\00"
@.str.21676 = private unnamed_addr constant [4 x i8] c"val\00"
@.str.21689 = private unnamed_addr constant [4 x i8] c"var\00"
@.str.21788 = private unnamed_addr constant [8 x i8] c"unknown\00"
@.str.21873 = private unnamed_addr constant [4 x i8] c"val\00"
@.str.21886 = private unnamed_addr constant [4 x i8] c"var\00"
@.str.21921 = private unnamed_addr constant [7 x i8] c".addr.\00"
@.str.21949 = private unnamed_addr constant [1 x i8] c"\00"
@.str.21986 = private unnamed_addr constant [4 x i8] c"val\00"
@.str.21999 = private unnamed_addr constant [4 x i8] c"var\00"
@.str.22035 = private unnamed_addr constant [7 x i8] c".addr.\00"
@.str.22099 = private unnamed_addr constant [4 x i8] c"val\00"
@.str.22112 = private unnamed_addr constant [4 x i8] c"var\00"
@.str.22147 = private unnamed_addr constant [7 x i8] c".addr.\00"
@.str.22213 = private unnamed_addr constant [8 x i8] c"Boolean\00"
@.str.22218 = private unnamed_addr constant [3 x i8] c"  \00"
@.str.22222 = private unnamed_addr constant [18 x i8] c" = load i1, ptr %\00"
@.str.22226 = private unnamed_addr constant [3 x i8] c"\0A\00"
@.str.22235 = private unnamed_addr constant [5 x i8] c"Char\00"
@.str.22240 = private unnamed_addr constant [3 x i8] c"  \00"
@.str.22244 = private unnamed_addr constant [18 x i8] c" = load i8, ptr %\00"
@.str.22248 = private unnamed_addr constant [3 x i8] c"\0A\00"
@.str.22257 = private unnamed_addr constant [7 x i8] c"Double\00"
@.str.22262 = private unnamed_addr constant [3 x i8] c"  \00"
@.str.22266 = private unnamed_addr constant [22 x i8] c" = load double, ptr %\00"
@.str.22270 = private unnamed_addr constant [3 x i8] c"\0A\00"
@.str.22279 = private unnamed_addr constant [5 x i8] c"Long\00"
@.str.22284 = private unnamed_addr constant [3 x i8] c"  \00"
@.str.22288 = private unnamed_addr constant [19 x i8] c" = load i64, ptr %\00"
@.str.22292 = private unnamed_addr constant [3 x i8] c"\0A\00"
@.str.22304 = private unnamed_addr constant [4 x i8] c"ptr\00"
@.str.22309 = private unnamed_addr constant [3 x i8] c"  \00"
@.str.22313 = private unnamed_addr constant [19 x i8] c" = load ptr, ptr %\00"
@.str.22317 = private unnamed_addr constant [3 x i8] c"\0A\00"
@.str.22321 = private unnamed_addr constant [3 x i8] c"  \00"
@.str.22325 = private unnamed_addr constant [19 x i8] c" = load i32, ptr %\00"
@.str.22329 = private unnamed_addr constant [3 x i8] c"\0A\00"
@.str.22430 = private unnamed_addr constant [5 x i8] c"Char\00"
@.str.22435 = private unnamed_addr constant [4 x i8] c"  %\00"
@.str.22439 = private unnamed_addr constant [7 x i8] c".cval.\00"
@.str.22443 = private unnamed_addr constant [18 x i8] c" = load i8, ptr %\00"
@.str.22447 = private unnamed_addr constant [3 x i8] c"\0A\00"
@.str.22449 = private unnamed_addr constant [4 x i8] c"  %\00"
@.str.22453 = private unnamed_addr constant [6 x i8] c".val.\00"
@.str.22457 = private unnamed_addr constant [13 x i8] c" = zext i8 %\00"
@.str.22461 = private unnamed_addr constant [7 x i8] c".cval.\00"
@.str.22465 = private unnamed_addr constant [10 x i8] c" to i32\0A\00"
@.str.22469 = private unnamed_addr constant [4 x i8] c"  %\00"
@.str.22473 = private unnamed_addr constant [6 x i8] c".val.\00"
@.str.22477 = private unnamed_addr constant [19 x i8] c" = load i32, ptr %\00"
@.str.22481 = private unnamed_addr constant [3 x i8] c"\0A\00"
@.str.22485 = private unnamed_addr constant [1 x i8] c"\00"
@.str.22528 = private unnamed_addr constant [6 x i8] c"false\00"
@.str.22581 = private unnamed_addr constant [2 x i8] c"%\00"
@.str.22590 = private unnamed_addr constant [6 x i8] c".bval\00"
@.str.22594 = private unnamed_addr constant [6 x i8] c"%btmp\00"
@.str.22676 = private unnamed_addr constant [4 x i8] c"  %\00"
@.str.22680 = private unnamed_addr constant [23 x i8] c".bval = load i1, ptr %\00"
@.str.22684 = private unnamed_addr constant [3 x i8] c"\0A\00"
@.str.22688 = private unnamed_addr constant [1 x i8] c"\00"
@.str.22739 = private unnamed_addr constant [2 x i8] c"0\00"
@.str.22774 = private unnamed_addr constant [5 x i8] c".arg\00"
@.str.22819 = private unnamed_addr constant [4 x i8] c"i32\00"
@.str.22843 = private unnamed_addr constant [4 x i8] c"ptr\00"
@.str.22867 = private unnamed_addr constant [3 x i8] c"i8\00"
@.str.22891 = private unnamed_addr constant [3 x i8] c"i1\00"
@.str.22949 = private unnamed_addr constant [4 x i8] c"ptr\00"
@.str.22956 = private unnamed_addr constant [3 x i8] c"i8\00"
@.str.22963 = private unnamed_addr constant [3 x i8] c"i1\00"
@.str.22970 = private unnamed_addr constant [4 x i8] c"i64\00"
@.str.22977 = private unnamed_addr constant [7 x i8] c"double\00"
@.str.23017 = private unnamed_addr constant [2 x i8] c"(\00"
@.str.23030 = private unnamed_addr constant [2 x i8] c"(\00"
@.str.23032 = private unnamed_addr constant [2 x i8] c")\00"
@.str.23066 = private unnamed_addr constant [4 x i8] c"ptr\00"
@.str.23073 = private unnamed_addr constant [3 x i8] c"i8\00"
@.str.23080 = private unnamed_addr constant [3 x i8] c"i1\00"
@.str.23087 = private unnamed_addr constant [4 x i8] c"i64\00"
@.str.23094 = private unnamed_addr constant [7 x i8] c"double\00"
@.str.23146 = private unnamed_addr constant [2 x i8] c"+\00"
@.str.23161 = private unnamed_addr constant [4 x i8] c"ptr\00"
@.str.23177 = private unnamed_addr constant [4 x i8] c"ptr\00"
@.str.23183 = private unnamed_addr constant [4 x i8] c"ptr\00"
@.str.23188 = private unnamed_addr constant [4 x i8] c"i32\00"
@.str.23239 = private unnamed_addr constant [2 x i8] c"0\00"
@.str.23335 = private unnamed_addr constant [5 x i8] c".arg\00"
@.str.23384 = private unnamed_addr constant [3 x i8] c"  \00"
@.str.23388 = private unnamed_addr constant [18 x i8] c" = add i32 0, 0\0A\00"
@.str.23435 = private unnamed_addr constant [3 x i8] c"  \00"
@.str.23439 = private unnamed_addr constant [28 x i8] c" = getelementptr inbounds [\00"
@.str.23443 = private unnamed_addr constant [19 x i8] c" x i8], ptr @.str.\00"
@.str.23447 = private unnamed_addr constant [17 x i8] c", i32 0, i32 0\0A\00"
@.str.23471 = private unnamed_addr constant [3 x i8] c"  \00"
@.str.23475 = private unnamed_addr constant [15 x i8] c" = add i32 0, \00"
@.str.23484 = private unnamed_addr constant [3 x i8] c"\0A\00"
@.str.23508 = private unnamed_addr constant [3 x i8] c"  \00"
@.str.23512 = private unnamed_addr constant [15 x i8] c" = add i32 0, \00"
@.str.23524 = private unnamed_addr constant [3 x i8] c"\0A\00"
@.str.23603 = private unnamed_addr constant [4 x i8] c"ptr\00"
@.str.23610 = private unnamed_addr constant [3 x i8] c"i8\00"
@.str.23617 = private unnamed_addr constant [3 x i8] c"i1\00"
@.str.23624 = private unnamed_addr constant [4 x i8] c"i64\00"
@.str.23631 = private unnamed_addr constant [7 x i8] c"double\00"
@.str.23636 = private unnamed_addr constant [3 x i8] c"  \00"
@.str.23640 = private unnamed_addr constant [9 x i8] c" = load \00"
@.str.23644 = private unnamed_addr constant [8 x i8] c", ptr %\00"
@.str.23648 = private unnamed_addr constant [3 x i8] c"\0A\00"
@.str.23652 = private unnamed_addr constant [3 x i8] c"  \00"
@.str.23656 = private unnamed_addr constant [19 x i8] c" = load i32, ptr %\00"
@.str.23660 = private unnamed_addr constant [3 x i8] c"\0A\00"
@.str.23694 = private unnamed_addr constant [2 x i8] c"(\00"
@.str.23707 = private unnamed_addr constant [2 x i8] c"(\00"
@.str.23709 = private unnamed_addr constant [2 x i8] c")\00"
@.str.23750 = private unnamed_addr constant [4 x i8] c"ptr\00"
@.str.23757 = private unnamed_addr constant [15 x i8] c"commandLineArg\00"
@.str.23776 = private unnamed_addr constant [6 x i8] c".arg0\00"
@.str.23779 = private unnamed_addr constant [3 x i8] c"  \00"
@.str.23783 = private unnamed_addr constant [40 x i8] c" = call ptr @csec_command_line_arg(i32 \00"
@.str.23787 = private unnamed_addr constant [9 x i8] c".arg0)\0A\00"
@.str.23796 = private unnamed_addr constant [4 x i8] c"ptr\00"
@.str.23803 = private unnamed_addr constant [12 x i8] c"tokenTextAt\00"
@.str.23824 = private unnamed_addr constant [2 x i8] c",\00"
@.str.23849 = private unnamed_addr constant [6 x i8] c".arg0\00"
@.str.23866 = private unnamed_addr constant [6 x i8] c".arg1\00"
@.str.23869 = private unnamed_addr constant [3 x i8] c"  \00"
@.str.23873 = private unnamed_addr constant [37 x i8] c" = call ptr @csec_token_text_at(ptr \00"
@.str.23877 = private unnamed_addr constant [12 x i8] c".arg0, i32 \00"
@.str.23881 = private unnamed_addr constant [9 x i8] c".arg1)\0A\00"
@.str.23891 = private unnamed_addr constant [3 x i8] c"i8\00"
@.str.23904 = private unnamed_addr constant [3 x i8] c"  \00"
@.str.23908 = private unnamed_addr constant [13 x i8] c" = call i8 @\00"
@.str.23912 = private unnamed_addr constant [5 x i8] c"()\0A\00"
@.str.23921 = private unnamed_addr constant [4 x i8] c"ptr\00"
@.str.23956 = private unnamed_addr constant [3 x i8] c"  \00"
@.str.23960 = private unnamed_addr constant [14 x i8] c" = call ptr @\00"
@.str.23964 = private unnamed_addr constant [5 x i8] c"()\0A\00"
@.str.23980 = private unnamed_addr constant [2 x i8] c",\00"
@.str.24001 = private unnamed_addr constant [6 x i8] c".arg0\00"
@.str.24004 = private unnamed_addr constant [3 x i8] c"  \00"
@.str.24008 = private unnamed_addr constant [14 x i8] c" = call ptr @\00"
@.str.24012 = private unnamed_addr constant [2 x i8] c"(\00"
@.str.24023 = private unnamed_addr constant [2 x i8] c" \00"
@.str.24027 = private unnamed_addr constant [9 x i8] c".arg0)\0A\00"
@.str.24057 = private unnamed_addr constant [2 x i8] c",\00"
@.str.24078 = private unnamed_addr constant [6 x i8] c".arg0\00"
@.str.24091 = private unnamed_addr constant [6 x i8] c".arg1\00"
@.str.24094 = private unnamed_addr constant [3 x i8] c"  \00"
@.str.24098 = private unnamed_addr constant [14 x i8] c" = call ptr @\00"
@.str.24102 = private unnamed_addr constant [2 x i8] c"(\00"
@.str.24113 = private unnamed_addr constant [2 x i8] c" \00"
@.str.24117 = private unnamed_addr constant [8 x i8] c".arg0, \00"
@.str.24128 = private unnamed_addr constant [2 x i8] c" \00"
@.str.24132 = private unnamed_addr constant [9 x i8] c".arg1)\0A\00"
@.str.24162 = private unnamed_addr constant [2 x i8] c",\00"
@.str.24183 = private unnamed_addr constant [6 x i8] c".arg0\00"
@.str.24196 = private unnamed_addr constant [6 x i8] c".arg1\00"
@.str.24209 = private unnamed_addr constant [6 x i8] c".arg2\00"
@.str.24212 = private unnamed_addr constant [3 x i8] c"  \00"
@.str.24216 = private unnamed_addr constant [14 x i8] c" = call ptr @\00"
@.str.24220 = private unnamed_addr constant [2 x i8] c"(\00"
@.str.24231 = private unnamed_addr constant [2 x i8] c" \00"
@.str.24235 = private unnamed_addr constant [8 x i8] c".arg0, \00"
@.str.24246 = private unnamed_addr constant [2 x i8] c" \00"
@.str.24250 = private unnamed_addr constant [8 x i8] c".arg1, \00"
@.str.24261 = private unnamed_addr constant [2 x i8] c" \00"
@.str.24265 = private unnamed_addr constant [9 x i8] c".arg2)\0A\00"
@.str.24293 = private unnamed_addr constant [6 x i8] c".arg0\00"
@.str.24306 = private unnamed_addr constant [6 x i8] c".arg1\00"
@.str.24319 = private unnamed_addr constant [6 x i8] c".arg2\00"
@.str.24332 = private unnamed_addr constant [6 x i8] c".arg3\00"
@.str.24335 = private unnamed_addr constant [3 x i8] c"  \00"
@.str.24339 = private unnamed_addr constant [14 x i8] c" = call ptr @\00"
@.str.24343 = private unnamed_addr constant [2 x i8] c"(\00"
@.str.24354 = private unnamed_addr constant [2 x i8] c" \00"
@.str.24358 = private unnamed_addr constant [8 x i8] c".arg0, \00"
@.str.24369 = private unnamed_addr constant [2 x i8] c" \00"
@.str.24373 = private unnamed_addr constant [8 x i8] c".arg1, \00"
@.str.24384 = private unnamed_addr constant [2 x i8] c" \00"
@.str.24388 = private unnamed_addr constant [8 x i8] c".arg2, \00"
@.str.24399 = private unnamed_addr constant [2 x i8] c" \00"
@.str.24403 = private unnamed_addr constant [9 x i8] c".arg3)\0A\00"
@.str.24438 = private unnamed_addr constant [2 x i8] c".\00"
@.str.24453 = private unnamed_addr constant [7 x i8] c"charAt\00"
@.str.24468 = private unnamed_addr constant [2 x i8] c"(\00"
@.str.24481 = private unnamed_addr constant [2 x i8] c"(\00"
@.str.24483 = private unnamed_addr constant [2 x i8] c")\00"
@.str.24552 = private unnamed_addr constant [3 x i8] c"  \00"
@.str.24556 = private unnamed_addr constant [23 x i8] c".obj = load ptr, ptr %\00"
@.str.24560 = private unnamed_addr constant [3 x i8] c"\0A\00"
@.str.24586 = private unnamed_addr constant [3 x i8] c"  \00"
@.str.24590 = private unnamed_addr constant [21 x i8] c".index = add i32 0, \00"
@.str.24599 = private unnamed_addr constant [3 x i8] c"\0A\00"
@.str.24627 = private unnamed_addr constant [3 x i8] c"  \00"
@.str.24631 = private unnamed_addr constant [25 x i8] c".index = load i32, ptr %\00"
@.str.24647 = private unnamed_addr constant [3 x i8] c"\0A\00"
@.str.24656 = private unnamed_addr constant [3 x i8] c"  \00"
@.str.24660 = private unnamed_addr constant [24 x i8] c".index = add i32 0, 0\0A\00"
@.str.24666 = private unnamed_addr constant [3 x i8] c"  \00"
@.str.24670 = private unnamed_addr constant [40 x i8] c".i8 = call i8 @csec_string_char_at(ptr \00"
@.str.24674 = private unnamed_addr constant [11 x i8] c".obj, i32 \00"
@.str.24678 = private unnamed_addr constant [10 x i8] c".index)\0A\00"
@.str.24680 = private unnamed_addr constant [3 x i8] c"  \00"
@.str.24684 = private unnamed_addr constant [12 x i8] c" = zext i8 \00"
@.str.24688 = private unnamed_addr constant [13 x i8] c".i8 to i32\0A\00"
@.str.24734 = private unnamed_addr constant [2 x i8] c"+\00"
@.str.24749 = private unnamed_addr constant [4 x i8] c"ptr\00"
@.str.24765 = private unnamed_addr constant [4 x i8] c"ptr\00"
@.str.24789 = private unnamed_addr constant [1 x i8] c"\00"
@.str.24796 = private unnamed_addr constant [1 x i8] c"\00"
@.str.24811 = private unnamed_addr constant [4 x i8] c"ptr\00"
@.str.24827 = private unnamed_addr constant [6 x i8] c".left\00"
@.str.24861 = private unnamed_addr constant [3 x i8] c"  \00"
@.str.24865 = private unnamed_addr constant [42 x i8] c".left = call ptr @csec_to_string_char(i8 \00"
@.str.24877 = private unnamed_addr constant [4 x i8] c")\0A\00"
@.str.24923 = private unnamed_addr constant [5 x i8] c"Char\00"
@.str.24929 = private unnamed_addr constant [3 x i8] c"  \00"
@.str.24933 = private unnamed_addr constant [26 x i8] c".left.i8 = load i8, ptr %\00"
@.str.24949 = private unnamed_addr constant [3 x i8] c"\0A\00"
@.str.24951 = private unnamed_addr constant [3 x i8] c"  \00"
@.str.24955 = private unnamed_addr constant [42 x i8] c".left = call ptr @csec_to_string_char(i8 \00"
@.str.24959 = private unnamed_addr constant [12 x i8] c".left.i8)\0A\00"
@.str.24976 = private unnamed_addr constant [10 x i8] c".left.i32\00"
@.str.24979 = private unnamed_addr constant [3 x i8] c"  \00"
@.str.24983 = private unnamed_addr constant [22 x i8] c".left.i64 = sext i32 \00"
@.str.24987 = private unnamed_addr constant [19 x i8] c".left.i32 to i64\0A\00"
@.str.24989 = private unnamed_addr constant [3 x i8] c"  \00"
@.str.24993 = private unnamed_addr constant [42 x i8] c".left = call ptr @csec_to_string_i64(i64 \00"
@.str.24997 = private unnamed_addr constant [13 x i8] c".left.i64)\0A\00"
@.str.25013 = private unnamed_addr constant [4 x i8] c"ptr\00"
@.str.25029 = private unnamed_addr constant [7 x i8] c".right\00"
@.str.25063 = private unnamed_addr constant [3 x i8] c"  \00"
@.str.25067 = private unnamed_addr constant [43 x i8] c".right = call ptr @csec_to_string_char(i8 \00"
@.str.25079 = private unnamed_addr constant [4 x i8] c")\0A\00"
@.str.25125 = private unnamed_addr constant [5 x i8] c"Char\00"
@.str.25131 = private unnamed_addr constant [3 x i8] c"  \00"
@.str.25135 = private unnamed_addr constant [27 x i8] c".right.i8 = load i8, ptr %\00"
@.str.25151 = private unnamed_addr constant [3 x i8] c"\0A\00"
@.str.25153 = private unnamed_addr constant [3 x i8] c"  \00"
@.str.25157 = private unnamed_addr constant [43 x i8] c".right = call ptr @csec_to_string_char(i8 \00"
@.str.25161 = private unnamed_addr constant [13 x i8] c".right.i8)\0A\00"
@.str.25178 = private unnamed_addr constant [11 x i8] c".right.i32\00"
@.str.25181 = private unnamed_addr constant [3 x i8] c"  \00"
@.str.25185 = private unnamed_addr constant [23 x i8] c".right.i64 = sext i32 \00"
@.str.25189 = private unnamed_addr constant [20 x i8] c".right.i32 to i64\0A\00"
@.str.25191 = private unnamed_addr constant [3 x i8] c"  \00"
@.str.25195 = private unnamed_addr constant [43 x i8] c".right = call ptr @csec_to_string_i64(i64 \00"
@.str.25199 = private unnamed_addr constant [14 x i8] c".right.i64)\0A\00"
@.str.25207 = private unnamed_addr constant [3 x i8] c"  \00"
@.str.25211 = private unnamed_addr constant [37 x i8] c" = call ptr @csec_string_concat(ptr \00"
@.str.25215 = private unnamed_addr constant [12 x i8] c".left, ptr \00"
@.str.25219 = private unnamed_addr constant [10 x i8] c".right)\0A\00"
@.str.25243 = private unnamed_addr constant [4 x i8] c"add\00"
@.str.25250 = private unnamed_addr constant [4 x i8] c"sub\00"
@.str.25257 = private unnamed_addr constant [4 x i8] c"mul\00"
@.str.25264 = private unnamed_addr constant [5 x i8] c"sdiv\00"
@.str.25271 = private unnamed_addr constant [5 x i8] c"srem\00"
@.str.25278 = private unnamed_addr constant [4 x i8] c"shl\00"
@.str.25285 = private unnamed_addr constant [5 x i8] c"ashr\00"
@.str.25292 = private unnamed_addr constant [4 x i8] c"and\00"
@.str.25299 = private unnamed_addr constant [3 x i8] c"or\00"
@.str.25306 = private unnamed_addr constant [4 x i8] c"xor\00"
@.str.25321 = private unnamed_addr constant [6 x i8] c".left\00"
@.str.25336 = private unnamed_addr constant [7 x i8] c".right\00"
@.str.25339 = private unnamed_addr constant [3 x i8] c"  \00"
@.str.25343 = private unnamed_addr constant [4 x i8] c" = \00"
@.str.25347 = private unnamed_addr constant [6 x i8] c" i32 \00"
@.str.25351 = private unnamed_addr constant [8 x i8] c".left, \00"
@.str.25355 = private unnamed_addr constant [9 x i8] c".right\0A\00"
@.str.25360 = private unnamed_addr constant [3 x i8] c"  \00"
@.str.25364 = private unnamed_addr constant [18 x i8] c" = add i32 0, 0\0A\00"
@.str.25423 = private unnamed_addr constant [1 x i8] c"\00"
@.str.25460 = private unnamed_addr constant [6 x i8] c".arg0\00"
@.str.25498 = private unnamed_addr constant [6 x i8] c".arg0\00"
@.str.25518 = private unnamed_addr constant [6 x i8] c".arg1\00"
@.str.25556 = private unnamed_addr constant [6 x i8] c".arg0\00"
@.str.25576 = private unnamed_addr constant [6 x i8] c".arg1\00"
@.str.25596 = private unnamed_addr constant [6 x i8] c".arg2\00"
@.str.25611 = private unnamed_addr constant [6 x i8] c".arg0\00"
@.str.25631 = private unnamed_addr constant [6 x i8] c".arg1\00"
@.str.25651 = private unnamed_addr constant [6 x i8] c".arg2\00"
@.str.25671 = private unnamed_addr constant [6 x i8] c".arg3\00"
@.str.25731 = private unnamed_addr constant [1 x i8] c"\00"
@.str.25767 = private unnamed_addr constant [2 x i8] c" \00"
@.str.25830 = private unnamed_addr constant [2 x i8] c" \00"
@.str.25845 = private unnamed_addr constant [3 x i8] c", \00"
@.str.25856 = private unnamed_addr constant [2 x i8] c" \00"
@.str.25933 = private unnamed_addr constant [2 x i8] c" \00"
@.str.25948 = private unnamed_addr constant [3 x i8] c", \00"
@.str.25959 = private unnamed_addr constant [2 x i8] c" \00"
@.str.25974 = private unnamed_addr constant [3 x i8] c", \00"
@.str.25985 = private unnamed_addr constant [2 x i8] c" \00"
@.str.26053 = private unnamed_addr constant [2 x i8] c" \00"
@.str.26068 = private unnamed_addr constant [3 x i8] c", \00"
@.str.26079 = private unnamed_addr constant [2 x i8] c" \00"
@.str.26094 = private unnamed_addr constant [3 x i8] c", \00"
@.str.26105 = private unnamed_addr constant [2 x i8] c" \00"
@.str.26120 = private unnamed_addr constant [3 x i8] c", \00"
@.str.26131 = private unnamed_addr constant [2 x i8] c" \00"
@.str.26163 = private unnamed_addr constant [20 x i8] c"commandLineArgCount\00"
@.str.26168 = private unnamed_addr constant [28 x i8] c"csec_command_line_arg_count\00"
@.str.26177 = private unnamed_addr constant [15 x i8] c"commandLineArg\00"
@.str.26182 = private unnamed_addr constant [22 x i8] c"csec_command_line_arg\00"
@.str.26209 = private unnamed_addr constant [5 x i8] c"kind\00"
@.str.26223 = private unnamed_addr constant [12 x i8] c"tokenKindAt\00"
@.str.26237 = private unnamed_addr constant [19 x i8] c"csec_token_kind_at\00"
@.str.26256 = private unnamed_addr constant [5 x i8] c"Char\00"
@.str.26312 = private unnamed_addr constant [3 x i8] c"  \00"
@.str.26316 = private unnamed_addr constant [18 x i8] c" = add i32 0, 0\0A\00"
@.str.26340 = private unnamed_addr constant [3 x i8] c"  \00"
@.str.26344 = private unnamed_addr constant [15 x i8] c" = add i32 0, \00"
@.str.26353 = private unnamed_addr constant [3 x i8] c"\0A\00"
@.str.26377 = private unnamed_addr constant [3 x i8] c"  \00"
@.str.26381 = private unnamed_addr constant [15 x i8] c" = add i32 0, \00"
@.str.26393 = private unnamed_addr constant [3 x i8] c"\0A\00"
@.str.26462 = private unnamed_addr constant [5 x i8] c"Char\00"
@.str.26467 = private unnamed_addr constant [3 x i8] c"  \00"
@.str.26471 = private unnamed_addr constant [20 x i8] c".c = load i8, ptr %\00"
@.str.26475 = private unnamed_addr constant [3 x i8] c"\0A\00"
@.str.26477 = private unnamed_addr constant [3 x i8] c"  \00"
@.str.26481 = private unnamed_addr constant [12 x i8] c" = zext i8 \00"
@.str.26485 = private unnamed_addr constant [12 x i8] c".c to i32\0A\00"
@.str.26489 = private unnamed_addr constant [3 x i8] c"  \00"
@.str.26493 = private unnamed_addr constant [19 x i8] c" = load i32, ptr %\00"
@.str.26497 = private unnamed_addr constant [3 x i8] c"\0A\00"
@.str.26531 = private unnamed_addr constant [2 x i8] c".\00"
@.str.26546 = private unnamed_addr constant [7 x i8] c"length\00"
@.str.26577 = private unnamed_addr constant [3 x i8] c"  \00"
@.str.26581 = private unnamed_addr constant [23 x i8] c".obj = load ptr, ptr %\00"
@.str.26585 = private unnamed_addr constant [3 x i8] c"\0A\00"
@.str.26587 = private unnamed_addr constant [3 x i8] c"  \00"
@.str.26591 = private unnamed_addr constant [41 x i8] c".i64 = call i64 @csec_string_length(ptr \00"
@.str.26595 = private unnamed_addr constant [8 x i8] c".obj)\0A\00"
@.str.26597 = private unnamed_addr constant [3 x i8] c"  \00"
@.str.26601 = private unnamed_addr constant [14 x i8] c" = trunc i64 \00"
@.str.26605 = private unnamed_addr constant [14 x i8] c".i64 to i32\0A\00"
@.str.26639 = private unnamed_addr constant [2 x i8] c".\00"
@.str.26654 = private unnamed_addr constant [7 x i8] c"charAt\00"
@.str.26669 = private unnamed_addr constant [2 x i8] c"(\00"
@.str.26682 = private unnamed_addr constant [2 x i8] c"(\00"
@.str.26684 = private unnamed_addr constant [2 x i8] c")\00"
@.str.26719 = private unnamed_addr constant [3 x i8] c"  \00"
@.str.26723 = private unnamed_addr constant [23 x i8] c".obj = load ptr, ptr %\00"
@.str.26727 = private unnamed_addr constant [3 x i8] c"\0A\00"
@.str.26743 = private unnamed_addr constant [7 x i8] c".index\00"
@.str.26746 = private unnamed_addr constant [3 x i8] c"  \00"
@.str.26750 = private unnamed_addr constant [40 x i8] c".i8 = call i8 @csec_string_char_at(ptr \00"
@.str.26754 = private unnamed_addr constant [11 x i8] c".obj, i32 \00"
@.str.26758 = private unnamed_addr constant [10 x i8] c".index)\0A\00"
@.str.26760 = private unnamed_addr constant [3 x i8] c"  \00"
@.str.26764 = private unnamed_addr constant [12 x i8] c" = zext i8 \00"
@.str.26768 = private unnamed_addr constant [13 x i8] c".i8 to i32\0A\00"
@.str.26802 = private unnamed_addr constant [2 x i8] c"(\00"
@.str.26815 = private unnamed_addr constant [2 x i8] c"(\00"
@.str.26817 = private unnamed_addr constant [2 x i8] c")\00"
@.str.26863 = private unnamed_addr constant [3 x i8] c"  \00"
@.str.26867 = private unnamed_addr constant [16 x i8] c".i8 = call i8 @\00"
@.str.26874 = private unnamed_addr constant [2 x i8] c"(\00"
@.str.26891 = private unnamed_addr constant [4 x i8] c")\0A\00"
@.str.26893 = private unnamed_addr constant [3 x i8] c"  \00"
@.str.26897 = private unnamed_addr constant [12 x i8] c" = zext i8 \00"
@.str.26901 = private unnamed_addr constant [13 x i8] c".i8 to i32\0A\00"
@.str.26920 = private unnamed_addr constant [3 x i8] c"  \00"
@.str.26924 = private unnamed_addr constant [14 x i8] c" = call i32 @\00"
@.str.26936 = private unnamed_addr constant [2 x i8] c"(\00"
@.str.26953 = private unnamed_addr constant [4 x i8] c")\0A\00"
@.str.27009 = private unnamed_addr constant [4 x i8] c"add\00"
@.str.27016 = private unnamed_addr constant [4 x i8] c"sub\00"
@.str.27023 = private unnamed_addr constant [4 x i8] c"mul\00"
@.str.27030 = private unnamed_addr constant [5 x i8] c"sdiv\00"
@.str.27037 = private unnamed_addr constant [5 x i8] c"srem\00"
@.str.27044 = private unnamed_addr constant [4 x i8] c"shl\00"
@.str.27051 = private unnamed_addr constant [5 x i8] c"ashr\00"
@.str.27058 = private unnamed_addr constant [4 x i8] c"and\00"
@.str.27065 = private unnamed_addr constant [3 x i8] c"or\00"
@.str.27072 = private unnamed_addr constant [4 x i8] c"xor\00"
@.str.27087 = private unnamed_addr constant [6 x i8] c".left\00"
@.str.27102 = private unnamed_addr constant [7 x i8] c".right\00"
@.str.27105 = private unnamed_addr constant [3 x i8] c"  \00"
@.str.27109 = private unnamed_addr constant [4 x i8] c" = \00"
@.str.27113 = private unnamed_addr constant [6 x i8] c" i32 \00"
@.str.27117 = private unnamed_addr constant [8 x i8] c".left, \00"
@.str.27121 = private unnamed_addr constant [9 x i8] c".right\0A\00"
@.str.27126 = private unnamed_addr constant [3 x i8] c"  \00"
@.str.27130 = private unnamed_addr constant [18 x i8] c" = add i32 0, 0\0A\00"
@.str.27188 = private unnamed_addr constant [7 x i8] c".addr.\00"
@.str.27197 = private unnamed_addr constant [2 x i8] c"%\00"
@.str.27201 = private unnamed_addr constant [7 x i8] c".init.\00"
@.str.27213 = private unnamed_addr constant [4 x i8] c"  %\00"
@.str.27217 = private unnamed_addr constant [16 x i8] c" = alloca i32\0A\00"
@.str.27232 = private unnamed_addr constant [13 x i8] c"  store i32 \00"
@.str.27236 = private unnamed_addr constant [8 x i8] c", ptr %\00"
@.str.27240 = private unnamed_addr constant [3 x i8] c"\0A\00"
@.str.27244 = private unnamed_addr constant [4 x i8] c"  %\00"
@.str.27248 = private unnamed_addr constant [16 x i8] c" = alloca i32\0A\00"
@.str.27250 = private unnamed_addr constant [21 x i8] c"  store i32 0, ptr %\00"
@.str.27254 = private unnamed_addr constant [3 x i8] c"\0A\00"
@.str.27297 = private unnamed_addr constant [2 x i8] c"0\00"
@.str.27350 = private unnamed_addr constant [2 x i8] c"%\00"
@.str.27359 = private unnamed_addr constant [7 x i8] c".lval.\00"
@.str.27365 = private unnamed_addr constant [6 x i8] c"%ltmp\00"
@.str.27447 = private unnamed_addr constant [4 x i8] c"  %\00"
@.str.27451 = private unnamed_addr constant [7 x i8] c".lval.\00"
@.str.27455 = private unnamed_addr constant [19 x i8] c" = load i64, ptr %\00"
@.str.27459 = private unnamed_addr constant [3 x i8] c"\0A\00"
@.str.27463 = private unnamed_addr constant [1 x i8] c"\00"
@.str.27510 = private unnamed_addr constant [3 x i8] c"  \00"
@.str.27514 = private unnamed_addr constant [18 x i8] c" = add i64 0, 0\0A\00"
@.str.27538 = private unnamed_addr constant [3 x i8] c"  \00"
@.str.27542 = private unnamed_addr constant [15 x i8] c" = add i64 0, \00"
@.str.27551 = private unnamed_addr constant [3 x i8] c"\0A\00"
@.str.27575 = private unnamed_addr constant [3 x i8] c"  \00"
@.str.27579 = private unnamed_addr constant [19 x i8] c" = load i64, ptr %\00"
@.str.27595 = private unnamed_addr constant [3 x i8] c"\0A\00"
@.str.27629 = private unnamed_addr constant [2 x i8] c"(\00"
@.str.27642 = private unnamed_addr constant [2 x i8] c"(\00"
@.str.27644 = private unnamed_addr constant [2 x i8] c")\00"
@.str.27668 = private unnamed_addr constant [3 x i8] c"  \00"
@.str.27672 = private unnamed_addr constant [14 x i8] c" = call i64 @\00"
@.str.27684 = private unnamed_addr constant [2 x i8] c"(\00"
@.str.27701 = private unnamed_addr constant [4 x i8] c")\0A\00"
@.str.27757 = private unnamed_addr constant [4 x i8] c"add\00"
@.str.27764 = private unnamed_addr constant [4 x i8] c"sub\00"
@.str.27771 = private unnamed_addr constant [4 x i8] c"mul\00"
@.str.27778 = private unnamed_addr constant [5 x i8] c"sdiv\00"
@.str.27785 = private unnamed_addr constant [5 x i8] c"srem\00"
@.str.27792 = private unnamed_addr constant [4 x i8] c"shl\00"
@.str.27799 = private unnamed_addr constant [5 x i8] c"ashr\00"
@.str.27806 = private unnamed_addr constant [4 x i8] c"and\00"
@.str.27813 = private unnamed_addr constant [3 x i8] c"or\00"
@.str.27820 = private unnamed_addr constant [4 x i8] c"xor\00"
@.str.27845 = private unnamed_addr constant [3 x i8] c"  \00"
@.str.27849 = private unnamed_addr constant [4 x i8] c" = \00"
@.str.27853 = private unnamed_addr constant [6 x i8] c" i64 \00"
@.str.27864 = private unnamed_addr constant [3 x i8] c", \00"
@.str.27877 = private unnamed_addr constant [3 x i8] c"\0A\00"
@.str.27882 = private unnamed_addr constant [3 x i8] c"  \00"
@.str.27886 = private unnamed_addr constant [18 x i8] c" = add i64 0, 0\0A\00"
@.str.27944 = private unnamed_addr constant [7 x i8] c".addr.\00"
@.str.27953 = private unnamed_addr constant [2 x i8] c"%\00"
@.str.27957 = private unnamed_addr constant [8 x i8] c".linit.\00"
@.str.27969 = private unnamed_addr constant [4 x i8] c"  %\00"
@.str.27973 = private unnamed_addr constant [16 x i8] c" = alloca i64\0A\00"
@.str.27988 = private unnamed_addr constant [13 x i8] c"  store i64 \00"
@.str.27992 = private unnamed_addr constant [8 x i8] c", ptr %\00"
@.str.27996 = private unnamed_addr constant [3 x i8] c"\0A\00"
@.str.28000 = private unnamed_addr constant [4 x i8] c"  %\00"
@.str.28004 = private unnamed_addr constant [16 x i8] c" = alloca i64\0A\00"
@.str.28006 = private unnamed_addr constant [21 x i8] c"  store i64 0, ptr %\00"
@.str.28010 = private unnamed_addr constant [3 x i8] c"\0A\00"
@.str.28053 = private unnamed_addr constant [13 x i8] c"0.000000e+00\00"
@.str.28119 = private unnamed_addr constant [2 x i8] c"%\00"
@.str.28128 = private unnamed_addr constant [7 x i8] c".fval.\00"
@.str.28134 = private unnamed_addr constant [6 x i8] c"%ftmp\00"
@.str.28216 = private unnamed_addr constant [4 x i8] c"  %\00"
@.str.28220 = private unnamed_addr constant [7 x i8] c".fval.\00"
@.str.28224 = private unnamed_addr constant [22 x i8] c" = load double, ptr %\00"
@.str.28228 = private unnamed_addr constant [3 x i8] c"\0A\00"
@.str.28232 = private unnamed_addr constant [1 x i8] c"\00"
@.str.28279 = private unnamed_addr constant [3 x i8] c"  \00"
@.str.28283 = private unnamed_addr constant [44 x i8] c" = fadd double 0.000000e+00, 0.000000e+00\0A\00"
@.str.28320 = private unnamed_addr constant [3 x i8] c"  \00"
@.str.28324 = private unnamed_addr constant [30 x i8] c" = fadd double 0.000000e+00, \00"
@.str.28333 = private unnamed_addr constant [3 x i8] c"\0A\00"
@.str.28357 = private unnamed_addr constant [3 x i8] c"  \00"
@.str.28361 = private unnamed_addr constant [22 x i8] c" = load double, ptr %\00"
@.str.28377 = private unnamed_addr constant [3 x i8] c"\0A\00"
@.str.28411 = private unnamed_addr constant [2 x i8] c"(\00"
@.str.28424 = private unnamed_addr constant [2 x i8] c"(\00"
@.str.28426 = private unnamed_addr constant [2 x i8] c")\00"
@.str.28450 = private unnamed_addr constant [3 x i8] c"  \00"
@.str.28454 = private unnamed_addr constant [17 x i8] c" = call double @\00"
@.str.28466 = private unnamed_addr constant [2 x i8] c"(\00"
@.str.28483 = private unnamed_addr constant [4 x i8] c")\0A\00"
@.str.28535 = private unnamed_addr constant [1 x i8] c"\00"
@.str.28543 = private unnamed_addr constant [2 x i8] c"+\00"
@.str.28549 = private unnamed_addr constant [5 x i8] c"fadd\00"
@.str.28558 = private unnamed_addr constant [2 x i8] c"-\00"
@.str.28564 = private unnamed_addr constant [5 x i8] c"fsub\00"
@.str.28573 = private unnamed_addr constant [2 x i8] c"*\00"
@.str.28579 = private unnamed_addr constant [5 x i8] c"fmul\00"
@.str.28588 = private unnamed_addr constant [2 x i8] c"/\00"
@.str.28594 = private unnamed_addr constant [5 x i8] c"fdiv\00"
@.str.28627 = private unnamed_addr constant [3 x i8] c"  \00"
@.str.28631 = private unnamed_addr constant [4 x i8] c" = \00"
@.str.28635 = private unnamed_addr constant [9 x i8] c" double \00"
@.str.28646 = private unnamed_addr constant [3 x i8] c", \00"
@.str.28659 = private unnamed_addr constant [3 x i8] c"\0A\00"
@.str.28664 = private unnamed_addr constant [3 x i8] c"  \00"
@.str.28668 = private unnamed_addr constant [44 x i8] c" = fadd double 0.000000e+00, 0.000000e+00\0A\00"
@.str.28726 = private unnamed_addr constant [7 x i8] c".addr.\00"
@.str.28735 = private unnamed_addr constant [2 x i8] c"%\00"
@.str.28739 = private unnamed_addr constant [8 x i8] c".finit.\00"
@.str.28751 = private unnamed_addr constant [4 x i8] c"  %\00"
@.str.28755 = private unnamed_addr constant [19 x i8] c" = alloca double\0A\00"
@.str.28770 = private unnamed_addr constant [16 x i8] c"  store double \00"
@.str.28774 = private unnamed_addr constant [8 x i8] c", ptr %\00"
@.str.28778 = private unnamed_addr constant [3 x i8] c"\0A\00"
@.str.28782 = private unnamed_addr constant [4 x i8] c"  %\00"
@.str.28786 = private unnamed_addr constant [19 x i8] c" = alloca double\0A\00"
@.str.28788 = private unnamed_addr constant [35 x i8] c"  store double 0.000000e+00, ptr %\00"
@.str.28792 = private unnamed_addr constant [3 x i8] c"\0A\00"
@.str.28850 = private unnamed_addr constant [7 x i8] c".addr.\00"
@.str.28859 = private unnamed_addr constant [2 x i8] c"%\00"
@.str.28863 = private unnamed_addr constant [8 x i8] c".cinit.\00"
@.str.28923 = private unnamed_addr constant [4 x i8] c"  %\00"
@.str.28927 = private unnamed_addr constant [15 x i8] c" = alloca i8\0A\00"
@.str.28929 = private unnamed_addr constant [12 x i8] c"  store i8 \00"
@.str.28941 = private unnamed_addr constant [8 x i8] c", ptr %\00"
@.str.28945 = private unnamed_addr constant [3 x i8] c"\0A\00"
@.str.28988 = private unnamed_addr constant [4 x i8] c"  %\00"
@.str.28992 = private unnamed_addr constant [15 x i8] c" = alloca i8\0A\00"
@.str.28994 = private unnamed_addr constant [3 x i8] c"  \00"
@.str.28998 = private unnamed_addr constant [18 x i8] c" = load i8, ptr %\00"
@.str.29002 = private unnamed_addr constant [3 x i8] c"\0A\00"
@.str.29004 = private unnamed_addr constant [12 x i8] c"  store i8 \00"
@.str.29008 = private unnamed_addr constant [8 x i8] c", ptr %\00"
@.str.29012 = private unnamed_addr constant [3 x i8] c"\0A\00"
@.str.29046 = private unnamed_addr constant [2 x i8] c".\00"
@.str.29061 = private unnamed_addr constant [7 x i8] c"charAt\00"
@.str.29076 = private unnamed_addr constant [2 x i8] c"(\00"
@.str.29089 = private unnamed_addr constant [2 x i8] c"(\00"
@.str.29091 = private unnamed_addr constant [2 x i8] c")\00"
@.str.29119 = private unnamed_addr constant [4 x i8] c"  %\00"
@.str.29123 = private unnamed_addr constant [15 x i8] c" = alloca i8\0A\00"
@.str.29125 = private unnamed_addr constant [3 x i8] c"  \00"
@.str.29129 = private unnamed_addr constant [23 x i8] c".obj = load ptr, ptr %\00"
@.str.29133 = private unnamed_addr constant [3 x i8] c"\0A\00"
@.str.29149 = private unnamed_addr constant [7 x i8] c".index\00"
@.str.29152 = private unnamed_addr constant [3 x i8] c"  \00"
@.str.29156 = private unnamed_addr constant [37 x i8] c" = call i8 @csec_string_char_at(ptr \00"
@.str.29160 = private unnamed_addr constant [11 x i8] c".obj, i32 \00"
@.str.29164 = private unnamed_addr constant [10 x i8] c".index)\0A\00"
@.str.29166 = private unnamed_addr constant [12 x i8] c"  store i8 \00"
@.str.29170 = private unnamed_addr constant [8 x i8] c", ptr %\00"
@.str.29174 = private unnamed_addr constant [3 x i8] c"\0A\00"
@.str.29208 = private unnamed_addr constant [2 x i8] c"(\00"
@.str.29221 = private unnamed_addr constant [2 x i8] c"(\00"
@.str.29223 = private unnamed_addr constant [2 x i8] c")\00"
@.str.29232 = private unnamed_addr constant [4 x i8] c"  %\00"
@.str.29236 = private unnamed_addr constant [15 x i8] c" = alloca i8\0A\00"
@.str.29253 = private unnamed_addr constant [3 x i8] c"  \00"
@.str.29257 = private unnamed_addr constant [13 x i8] c" = call i8 @\00"
@.str.29269 = private unnamed_addr constant [2 x i8] c"(\00"
@.str.29286 = private unnamed_addr constant [4 x i8] c")\0A\00"
@.str.29288 = private unnamed_addr constant [12 x i8] c"  store i8 \00"
@.str.29292 = private unnamed_addr constant [8 x i8] c", ptr %\00"
@.str.29296 = private unnamed_addr constant [3 x i8] c"\0A\00"
@.str.29301 = private unnamed_addr constant [4 x i8] c"  %\00"
@.str.29305 = private unnamed_addr constant [15 x i8] c" = alloca i8\0A\00"
@.str.29307 = private unnamed_addr constant [20 x i8] c"  store i8 0, ptr %\00"
@.str.29311 = private unnamed_addr constant [3 x i8] c"\0A\00"
@.str.29367 = private unnamed_addr constant [1 x i8] c"\00"
@.str.29414 = private unnamed_addr constant [2 x i8] c"=\00"
@.str.29421 = private unnamed_addr constant [3 x i8] c"<-\00"
@.str.29430 = private unnamed_addr constant [2 x i8] c"%\00"
@.str.29434 = private unnamed_addr constant [10 x i8] c".fassign.\00"
@.str.29452 = private unnamed_addr constant [16 x i8] c"  store double \00"
@.str.29456 = private unnamed_addr constant [8 x i8] c", ptr %\00"
@.str.29460 = private unnamed_addr constant [3 x i8] c"\0A\00"
@.str.29464 = private unnamed_addr constant [1 x i8] c"\00"
@.str.29520 = private unnamed_addr constant [1 x i8] c"\00"
@.str.29621 = private unnamed_addr constant [4 x i8] c"  %\00"
@.str.29625 = private unnamed_addr constant [10 x i8] c".passign.\00"
@.str.29629 = private unnamed_addr constant [28 x i8] c" = getelementptr inbounds [\00"
@.str.29633 = private unnamed_addr constant [19 x i8] c" x i8], ptr @.str.\00"
@.str.29637 = private unnamed_addr constant [17 x i8] c", i32 0, i32 0\0A\00"
@.str.29639 = private unnamed_addr constant [14 x i8] c"  store ptr %\00"
@.str.29643 = private unnamed_addr constant [10 x i8] c".passign.\00"
@.str.29647 = private unnamed_addr constant [8 x i8] c", ptr %\00"
@.str.29651 = private unnamed_addr constant [3 x i8] c"\0A\00"
@.str.29694 = private unnamed_addr constant [4 x i8] c"  %\00"
@.str.29698 = private unnamed_addr constant [10 x i8] c".passign.\00"
@.str.29702 = private unnamed_addr constant [19 x i8] c" = load ptr, ptr %\00"
@.str.29706 = private unnamed_addr constant [3 x i8] c"\0A\00"
@.str.29708 = private unnamed_addr constant [14 x i8] c"  store ptr %\00"
@.str.29712 = private unnamed_addr constant [10 x i8] c".passign.\00"
@.str.29716 = private unnamed_addr constant [8 x i8] c", ptr %\00"
@.str.29720 = private unnamed_addr constant [3 x i8] c"\0A\00"
@.str.29754 = private unnamed_addr constant [2 x i8] c"(\00"
@.str.29767 = private unnamed_addr constant [2 x i8] c"(\00"
@.str.29769 = private unnamed_addr constant [2 x i8] c")\00"
@.str.29782 = private unnamed_addr constant [2 x i8] c"%\00"
@.str.29786 = private unnamed_addr constant [10 x i8] c".passign.\00"
@.str.29806 = private unnamed_addr constant [3 x i8] c"  \00"
@.str.29810 = private unnamed_addr constant [14 x i8] c" = call ptr @\00"
@.str.29822 = private unnamed_addr constant [2 x i8] c"(\00"
@.str.29839 = private unnamed_addr constant [4 x i8] c")\0A\00"
@.str.29841 = private unnamed_addr constant [13 x i8] c"  store ptr \00"
@.str.29845 = private unnamed_addr constant [8 x i8] c", ptr %\00"
@.str.29849 = private unnamed_addr constant [3 x i8] c"\0A\00"
@.str.29882 = private unnamed_addr constant [2 x i8] c"+\00"
@.str.29902 = private unnamed_addr constant [2 x i8] c"%\00"
@.str.29906 = private unnamed_addr constant [10 x i8] c".passign.\00"
@.str.29948 = private unnamed_addr constant [1 x i8] c"\00"
@.str.29984 = private unnamed_addr constant [3 x i8] c"  \00"
@.str.29988 = private unnamed_addr constant [34 x i8] c".right = getelementptr inbounds [\00"
@.str.29998 = private unnamed_addr constant [19 x i8] c" x i8], ptr @.str.\00"
@.str.30002 = private unnamed_addr constant [17 x i8] c", i32 0, i32 0\0A\00"
@.str.30028 = private unnamed_addr constant [3 x i8] c"  \00"
@.str.30032 = private unnamed_addr constant [25 x i8] c".right = load ptr, ptr %\00"
@.str.30048 = private unnamed_addr constant [3 x i8] c"\0A\00"
@.str.30083 = private unnamed_addr constant [2 x i8] c"(\00"
@.str.30096 = private unnamed_addr constant [2 x i8] c"(\00"
@.str.30098 = private unnamed_addr constant [2 x i8] c")\00"
@.str.30123 = private unnamed_addr constant [3 x i8] c"  \00"
@.str.30127 = private unnamed_addr constant [20 x i8] c".right = call ptr @\00"
@.str.30139 = private unnamed_addr constant [2 x i8] c"(\00"
@.str.30156 = private unnamed_addr constant [4 x i8] c")\0A\00"
@.str.30169 = private unnamed_addr constant [3 x i8] c"  \00"
@.str.30173 = private unnamed_addr constant [24 x i8] c".left = load ptr, ptr %\00"
@.str.30177 = private unnamed_addr constant [3 x i8] c"\0A\00"
@.str.30181 = private unnamed_addr constant [3 x i8] c"  \00"
@.str.30185 = private unnamed_addr constant [37 x i8] c" = call ptr @csec_string_concat(ptr \00"
@.str.30189 = private unnamed_addr constant [12 x i8] c".left, ptr \00"
@.str.30193 = private unnamed_addr constant [10 x i8] c".right)\0A\00"
@.str.30195 = private unnamed_addr constant [13 x i8] c"  store ptr \00"
@.str.30199 = private unnamed_addr constant [8 x i8] c", ptr %\00"
@.str.30203 = private unnamed_addr constant [3 x i8] c"\0A\00"
@.str.30208 = private unnamed_addr constant [1 x i8] c"\00"
@.str.30264 = private unnamed_addr constant [1 x i8] c"\00"
@.str.30342 = private unnamed_addr constant [12 x i8] c"  store i8 \00"
@.str.30354 = private unnamed_addr constant [8 x i8] c", ptr %\00"
@.str.30358 = private unnamed_addr constant [3 x i8] c"\0A\00"
@.str.30401 = private unnamed_addr constant [4 x i8] c"  %\00"
@.str.30405 = private unnamed_addr constant [10 x i8] c".cassign.\00"
@.str.30409 = private unnamed_addr constant [18 x i8] c" = load i8, ptr %\00"
@.str.30413 = private unnamed_addr constant [3 x i8] c"\0A\00"
@.str.30415 = private unnamed_addr constant [13 x i8] c"  store i8 %\00"
@.str.30419 = private unnamed_addr constant [10 x i8] c".cassign.\00"
@.str.30423 = private unnamed_addr constant [8 x i8] c", ptr %\00"
@.str.30427 = private unnamed_addr constant [3 x i8] c"\0A\00"
@.str.30461 = private unnamed_addr constant [2 x i8] c".\00"
@.str.30476 = private unnamed_addr constant [7 x i8] c"charAt\00"
@.str.30491 = private unnamed_addr constant [2 x i8] c"(\00"
@.str.30504 = private unnamed_addr constant [2 x i8] c"(\00"
@.str.30506 = private unnamed_addr constant [2 x i8] c")\00"
@.str.30538 = private unnamed_addr constant [2 x i8] c"%\00"
@.str.30542 = private unnamed_addr constant [10 x i8] c".cassign.\00"
@.str.30547 = private unnamed_addr constant [3 x i8] c"  \00"
@.str.30551 = private unnamed_addr constant [23 x i8] c".obj = load ptr, ptr %\00"
@.str.30555 = private unnamed_addr constant [3 x i8] c"\0A\00"
@.str.30571 = private unnamed_addr constant [7 x i8] c".index\00"
@.str.30574 = private unnamed_addr constant [3 x i8] c"  \00"
@.str.30578 = private unnamed_addr constant [37 x i8] c" = call i8 @csec_string_char_at(ptr \00"
@.str.30582 = private unnamed_addr constant [11 x i8] c".obj, i32 \00"
@.str.30586 = private unnamed_addr constant [10 x i8] c".index)\0A\00"
@.str.30588 = private unnamed_addr constant [12 x i8] c"  store i8 \00"
@.str.30592 = private unnamed_addr constant [8 x i8] c", ptr %\00"
@.str.30596 = private unnamed_addr constant [3 x i8] c"\0A\00"
@.str.30630 = private unnamed_addr constant [2 x i8] c"(\00"
@.str.30643 = private unnamed_addr constant [2 x i8] c"(\00"
@.str.30645 = private unnamed_addr constant [2 x i8] c")\00"
@.str.30658 = private unnamed_addr constant [2 x i8] c"%\00"
@.str.30662 = private unnamed_addr constant [10 x i8] c".cassign.\00"
@.str.30682 = private unnamed_addr constant [3 x i8] c"  \00"
@.str.30686 = private unnamed_addr constant [13 x i8] c" = call i8 @\00"
@.str.30698 = private unnamed_addr constant [2 x i8] c"(\00"
@.str.30715 = private unnamed_addr constant [4 x i8] c")\0A\00"
@.str.30717 = private unnamed_addr constant [12 x i8] c"  store i8 \00"
@.str.30721 = private unnamed_addr constant [8 x i8] c", ptr %\00"
@.str.30725 = private unnamed_addr constant [3 x i8] c"\0A\00"
@.str.30729 = private unnamed_addr constant [1 x i8] c"\00"
@.str.30785 = private unnamed_addr constant [1 x i8] c"\00"
@.str.30832 = private unnamed_addr constant [2 x i8] c"=\00"
@.str.30839 = private unnamed_addr constant [3 x i8] c"<-\00"
@.str.30848 = private unnamed_addr constant [2 x i8] c"%\00"
@.str.30852 = private unnamed_addr constant [9 x i8] c".assign.\00"
@.str.30870 = private unnamed_addr constant [13 x i8] c"  store i32 \00"
@.str.30874 = private unnamed_addr constant [8 x i8] c", ptr %\00"
@.str.30878 = private unnamed_addr constant [3 x i8] c"\0A\00"
@.str.30901 = private unnamed_addr constant [3 x i8] c"%=\00"
@.str.30907 = private unnamed_addr constant [2 x i8] c"%\00"
@.str.30911 = private unnamed_addr constant [4 x i8] c"  %\00"
@.str.30915 = private unnamed_addr constant [6 x i8] c".old.\00"
@.str.30919 = private unnamed_addr constant [19 x i8] c" = load i32, ptr %\00"
@.str.30923 = private unnamed_addr constant [3 x i8] c"\0A\00"
@.str.30935 = private unnamed_addr constant [2 x i8] c"%\00"
@.str.30939 = private unnamed_addr constant [6 x i8] c".rhs.\00"
@.str.30944 = private unnamed_addr constant [4 x i8] c"  %\00"
@.str.30948 = private unnamed_addr constant [7 x i8] c".next.\00"
@.str.30952 = private unnamed_addr constant [4 x i8] c" = \00"
@.str.30959 = private unnamed_addr constant [7 x i8] c" i32 %\00"
@.str.30963 = private unnamed_addr constant [6 x i8] c".old.\00"
@.str.30967 = private unnamed_addr constant [4 x i8] c", %\00"
@.str.30971 = private unnamed_addr constant [6 x i8] c".rhs.\00"
@.str.30975 = private unnamed_addr constant [3 x i8] c"\0A\00"
@.str.30977 = private unnamed_addr constant [14 x i8] c"  store i32 %\00"
@.str.30981 = private unnamed_addr constant [7 x i8] c".next.\00"
@.str.30985 = private unnamed_addr constant [8 x i8] c", ptr %\00"
@.str.30989 = private unnamed_addr constant [3 x i8] c"\0A\00"
@.str.31045 = private unnamed_addr constant [1 x i8] c"\00"
@.str.31092 = private unnamed_addr constant [2 x i8] c"=\00"
@.str.31099 = private unnamed_addr constant [3 x i8] c"<-\00"
@.str.31108 = private unnamed_addr constant [2 x i8] c"%\00"
@.str.31112 = private unnamed_addr constant [10 x i8] c".lassign.\00"
@.str.31130 = private unnamed_addr constant [13 x i8] c"  store i64 \00"
@.str.31134 = private unnamed_addr constant [8 x i8] c", ptr %\00"
@.str.31138 = private unnamed_addr constant [3 x i8] c"\0A\00"
@.str.31161 = private unnamed_addr constant [3 x i8] c"%=\00"
@.str.31167 = private unnamed_addr constant [2 x i8] c"%\00"
@.str.31171 = private unnamed_addr constant [4 x i8] c"  %\00"
@.str.31175 = private unnamed_addr constant [7 x i8] c".lold.\00"
@.str.31179 = private unnamed_addr constant [19 x i8] c" = load i64, ptr %\00"
@.str.31183 = private unnamed_addr constant [3 x i8] c"\0A\00"
@.str.31195 = private unnamed_addr constant [2 x i8] c"%\00"
@.str.31199 = private unnamed_addr constant [7 x i8] c".lrhs.\00"
@.str.31204 = private unnamed_addr constant [4 x i8] c"  %\00"
@.str.31208 = private unnamed_addr constant [8 x i8] c".lnext.\00"
@.str.31212 = private unnamed_addr constant [4 x i8] c" = \00"
@.str.31219 = private unnamed_addr constant [7 x i8] c" i64 %\00"
@.str.31223 = private unnamed_addr constant [7 x i8] c".lold.\00"
@.str.31227 = private unnamed_addr constant [4 x i8] c", %\00"
@.str.31231 = private unnamed_addr constant [7 x i8] c".lrhs.\00"
@.str.31235 = private unnamed_addr constant [3 x i8] c"\0A\00"
@.str.31237 = private unnamed_addr constant [14 x i8] c"  store i64 %\00"
@.str.31241 = private unnamed_addr constant [8 x i8] c".lnext.\00"
@.str.31245 = private unnamed_addr constant [8 x i8] c", ptr %\00"
@.str.31249 = private unnamed_addr constant [3 x i8] c"\0A\00"
@.str.31300 = private unnamed_addr constant [2 x i8] c"(\00"
@.str.31311 = private unnamed_addr constant [2 x i8] c"(\00"
@.str.31313 = private unnamed_addr constant [2 x i8] c")\00"
@.str.31350 = private unnamed_addr constant [2 x i8] c"!\00"
@.str.31361 = private unnamed_addr constant [5 x i8] c".not\00"
@.str.31377 = private unnamed_addr constant [3 x i8] c"  \00"
@.str.31381 = private unnamed_addr constant [11 x i8] c" = xor i1 \00"
@.str.31385 = private unnamed_addr constant [13 x i8] c".not, true\0A\00"
@.str.31432 = private unnamed_addr constant [6 x i8] c"icmp_\00"
@.str.31507 = private unnamed_addr constant [3 x i8] c"  \00"
@.str.31511 = private unnamed_addr constant [26 x i8] c".left.i8 = load i8, ptr %\00"
@.str.31515 = private unnamed_addr constant [3 x i8] c"\0A\00"
@.str.31517 = private unnamed_addr constant [3 x i8] c"  \00"
@.str.31521 = private unnamed_addr constant [9 x i8] c" = icmp \00"
@.str.31525 = private unnamed_addr constant [5 x i8] c" i8 \00"
@.str.31529 = private unnamed_addr constant [11 x i8] c".left.i8, \00"
@.str.31543 = private unnamed_addr constant [3 x i8] c"\0A\00"
@.str.31609 = private unnamed_addr constant [3 x i8] c"  \00"
@.str.31613 = private unnamed_addr constant [27 x i8] c".right.i8 = load i8, ptr %\00"
@.str.31617 = private unnamed_addr constant [3 x i8] c"\0A\00"
@.str.31619 = private unnamed_addr constant [3 x i8] c"  \00"
@.str.31623 = private unnamed_addr constant [9 x i8] c" = icmp \00"
@.str.31627 = private unnamed_addr constant [5 x i8] c" i8 \00"
@.str.31639 = private unnamed_addr constant [3 x i8] c", \00"
@.str.31643 = private unnamed_addr constant [12 x i8] c".right.i8\0A\00"
@.str.31653 = private unnamed_addr constant [10 x i8] c".left.i32\00"
@.str.31662 = private unnamed_addr constant [11 x i8] c".right.i32\00"
@.str.31689 = private unnamed_addr constant [3 x i8] c"  \00"
@.str.31693 = private unnamed_addr constant [9 x i8] c" = icmp \00"
@.str.31697 = private unnamed_addr constant [6 x i8] c" i32 \00"
@.str.31701 = private unnamed_addr constant [12 x i8] c".left.i32, \00"
@.str.31705 = private unnamed_addr constant [13 x i8] c".right.i32\0A\00"
@.str.31740 = private unnamed_addr constant [5 x i8] c"true\00"
@.str.31745 = private unnamed_addr constant [3 x i8] c"  \00"
@.str.31749 = private unnamed_addr constant [27 x i8] c" = icmp eq i1 true, true\0A\00"
@.str.31753 = private unnamed_addr constant [3 x i8] c"  \00"
@.str.31757 = private unnamed_addr constant [28 x i8] c" = icmp eq i1 false, true\0A\00"
@.str.31781 = private unnamed_addr constant [3 x i8] c"  \00"
@.str.31785 = private unnamed_addr constant [18 x i8] c" = load i1, ptr %\00"
@.str.31801 = private unnamed_addr constant [3 x i8] c"\0A\00"
@.str.31835 = private unnamed_addr constant [2 x i8] c".\00"
@.str.31850 = private unnamed_addr constant [11 x i8] c"startsWith\00"
@.str.31865 = private unnamed_addr constant [2 x i8] c"(\00"
@.str.31878 = private unnamed_addr constant [2 x i8] c"(\00"
@.str.31880 = private unnamed_addr constant [2 x i8] c")\00"
@.str.31914 = private unnamed_addr constant [8 x i8] c".needle\00"
@.str.31917 = private unnamed_addr constant [3 x i8] c"  \00"
@.str.31921 = private unnamed_addr constant [23 x i8] c".obj = load ptr, ptr %\00"
@.str.31925 = private unnamed_addr constant [3 x i8] c"\0A\00"
@.str.31942 = private unnamed_addr constant [3 x i8] c"  \00"
@.str.31946 = private unnamed_addr constant [46 x i8] c".i32 = call i32 @csec_string_starts_with(ptr \00"
@.str.31950 = private unnamed_addr constant [11 x i8] c".obj, ptr \00"
@.str.31954 = private unnamed_addr constant [11 x i8] c".needle)\0A\00"
@.str.31956 = private unnamed_addr constant [3 x i8] c"  \00"
@.str.31960 = private unnamed_addr constant [16 x i8] c" = icmp ne i32 \00"
@.str.31964 = private unnamed_addr constant [10 x i8] c".i32, 0\0A\00"
@.str.31998 = private unnamed_addr constant [2 x i8] c"(\00"
@.str.32011 = private unnamed_addr constant [2 x i8] c"(\00"
@.str.32013 = private unnamed_addr constant [2 x i8] c")\00"
@.str.32037 = private unnamed_addr constant [3 x i8] c"  \00"
@.str.32041 = private unnamed_addr constant [13 x i8] c" = call i1 @\00"
@.str.32053 = private unnamed_addr constant [2 x i8] c"(\00"
@.str.32070 = private unnamed_addr constant [4 x i8] c")\0A\00"
@.str.32074 = private unnamed_addr constant [3 x i8] c"  \00"
@.str.32078 = private unnamed_addr constant [22 x i8] c" = icmp eq i32 0, 0\0A\00"
@.str.32125 = private unnamed_addr constant [3 x i8] c"  \00"
@.str.32129 = private unnamed_addr constant [28 x i8] c" = icmp eq i1 false, true\0A\00"
@.str.32144 = private unnamed_addr constant [2 x i8] c"(\00"
@.str.32155 = private unnamed_addr constant [2 x i8] c"(\00"
@.str.32157 = private unnamed_addr constant [2 x i8] c")\00"
@.str.32194 = private unnamed_addr constant [2 x i8] c"!\00"
@.str.32205 = private unnamed_addr constant [5 x i8] c".not\00"
@.str.32221 = private unnamed_addr constant [3 x i8] c"  \00"
@.str.32225 = private unnamed_addr constant [11 x i8] c" = xor i1 \00"
@.str.32229 = private unnamed_addr constant [13 x i8] c".not, true\0A\00"
@.str.32263 = private unnamed_addr constant [5 x i8] c"true\00"
@.str.32268 = private unnamed_addr constant [3 x i8] c"  \00"
@.str.32272 = private unnamed_addr constant [27 x i8] c" = icmp eq i1 true, true\0A\00"
@.str.32276 = private unnamed_addr constant [3 x i8] c"  \00"
@.str.32280 = private unnamed_addr constant [28 x i8] c" = icmp eq i1 false, true\0A\00"
@.str.32304 = private unnamed_addr constant [3 x i8] c"  \00"
@.str.32308 = private unnamed_addr constant [18 x i8] c" = load i1, ptr %\00"
@.str.32324 = private unnamed_addr constant [3 x i8] c"\0A\00"
@.str.32369 = private unnamed_addr constant [14 x i8] c"csec_token_is\00"
@.str.32384 = private unnamed_addr constant [2 x i8] c"(\00"
@.str.32397 = private unnamed_addr constant [2 x i8] c"(\00"
@.str.32399 = private unnamed_addr constant [2 x i8] c")\00"
@.str.32443 = private unnamed_addr constant [2 x i8] c",\00"
@.str.32463 = private unnamed_addr constant [2 x i8] c",\00"
@.str.32483 = private unnamed_addr constant [2 x i8] c",\00"
@.str.32606 = private unnamed_addr constant [3 x i8] c"  \00"
@.str.32610 = private unnamed_addr constant [29 x i8] c".call.arg0 = load ptr, ptr %\00"
@.str.32614 = private unnamed_addr constant [3 x i8] c"\0A\00"
@.str.32628 = private unnamed_addr constant [11 x i8] c".call.arg1\00"
@.str.32631 = private unnamed_addr constant [3 x i8] c"  \00"
@.str.32635 = private unnamed_addr constant [28 x i8] c".call.arg2 = load i8, ptr %\00"
@.str.32639 = private unnamed_addr constant [3 x i8] c"\0A\00"
@.str.32641 = private unnamed_addr constant [3 x i8] c"  \00"
@.str.32645 = private unnamed_addr constant [29 x i8] c".call.arg3 = load ptr, ptr %\00"
@.str.32649 = private unnamed_addr constant [3 x i8] c"\0A\00"
@.str.32651 = private unnamed_addr constant [3 x i8] c"  \00"
@.str.32655 = private unnamed_addr constant [37 x i8] c".call = call i32 @csec_token_is(ptr \00"
@.str.32659 = private unnamed_addr constant [17 x i8] c".call.arg0, i32 \00"
@.str.32663 = private unnamed_addr constant [16 x i8] c".call.arg1, i8 \00"
@.str.32667 = private unnamed_addr constant [17 x i8] c".call.arg2, ptr \00"
@.str.32671 = private unnamed_addr constant [14 x i8] c".call.arg3)\0A\00"
@.str.32673 = private unnamed_addr constant [3 x i8] c"  \00"
@.str.32677 = private unnamed_addr constant [9 x i8] c" = icmp \00"
@.str.32681 = private unnamed_addr constant [6 x i8] c" i32 \00"
@.str.32685 = private unnamed_addr constant [8 x i8] c".call, \00"
@.str.32696 = private unnamed_addr constant [3 x i8] c"\0A\00"
@.str.32729 = private unnamed_addr constant [2 x i8] c"(\00"
@.str.32742 = private unnamed_addr constant [2 x i8] c"(\00"
@.str.32744 = private unnamed_addr constant [2 x i8] c")\00"
@.str.32817 = private unnamed_addr constant [6 x i8] c".call\00"
@.str.32820 = private unnamed_addr constant [3 x i8] c"  \00"
@.str.32824 = private unnamed_addr constant [19 x i8] c".call = call i32 @\00"
@.str.32836 = private unnamed_addr constant [2 x i8] c"(\00"
@.str.32850 = private unnamed_addr constant [6 x i8] c".call\00"
@.str.32853 = private unnamed_addr constant [4 x i8] c")\0A\00"
@.str.32855 = private unnamed_addr constant [3 x i8] c"  \00"
@.str.32859 = private unnamed_addr constant [9 x i8] c" = icmp \00"
@.str.32863 = private unnamed_addr constant [6 x i8] c" i32 \00"
@.str.32867 = private unnamed_addr constant [8 x i8] c".call, \00"
@.str.32878 = private unnamed_addr constant [3 x i8] c"\0A\00"
@.str.32911 = private unnamed_addr constant [6 x i8] c".left\00"
@.str.32920 = private unnamed_addr constant [7 x i8] c".right\00"
@.str.32947 = private unnamed_addr constant [3 x i8] c"  \00"
@.str.32951 = private unnamed_addr constant [10 x i8] c" = or i1 \00"
@.str.32955 = private unnamed_addr constant [8 x i8] c".left, \00"
@.str.32959 = private unnamed_addr constant [9 x i8] c".right\0A\00"
@.str.32961 = private unnamed_addr constant [19 x i8] c"  ; bool operands \00"
@.str.32972 = private unnamed_addr constant [3 x i8] c", \00"
@.str.32985 = private unnamed_addr constant [3 x i8] c"\0A\00"
@.str.33015 = private unnamed_addr constant [6 x i8] c".left\00"
@.str.33024 = private unnamed_addr constant [7 x i8] c".right\00"
@.str.33051 = private unnamed_addr constant [3 x i8] c"  \00"
@.str.33055 = private unnamed_addr constant [11 x i8] c" = and i1 \00"
@.str.33059 = private unnamed_addr constant [8 x i8] c".left, \00"
@.str.33063 = private unnamed_addr constant [9 x i8] c".right\0A\00"
@.str.33065 = private unnamed_addr constant [19 x i8] c"  ; bool operands \00"
@.str.33076 = private unnamed_addr constant [3 x i8] c", \00"
@.str.33089 = private unnamed_addr constant [3 x i8] c"\0A\00"
@.str.33160 = private unnamed_addr constant [7 x i8] c".addr.\00"
@.str.33169 = private unnamed_addr constant [2 x i8] c"%\00"
@.str.33173 = private unnamed_addr constant [8 x i8] c".binit.\00"
@.str.33185 = private unnamed_addr constant [4 x i8] c"  %\00"
@.str.33189 = private unnamed_addr constant [15 x i8] c" = alloca i1\0A\00"
@.str.33204 = private unnamed_addr constant [12 x i8] c"  store i1 \00"
@.str.33208 = private unnamed_addr constant [8 x i8] c", ptr %\00"
@.str.33212 = private unnamed_addr constant [3 x i8] c"\0A\00"
@.str.33216 = private unnamed_addr constant [4 x i8] c"  %\00"
@.str.33220 = private unnamed_addr constant [15 x i8] c" = alloca i1\0A\00"
@.str.33222 = private unnamed_addr constant [24 x i8] c"  store i1 false, ptr %\00"
@.str.33226 = private unnamed_addr constant [3 x i8] c"\0A\00"
@.str.33282 = private unnamed_addr constant [1 x i8] c"\00"
@.str.33329 = private unnamed_addr constant [2 x i8] c"=\00"
@.str.33336 = private unnamed_addr constant [3 x i8] c"<-\00"
@.str.33345 = private unnamed_addr constant [2 x i8] c"%\00"
@.str.33349 = private unnamed_addr constant [10 x i8] c".bassign.\00"
@.str.33367 = private unnamed_addr constant [12 x i8] c"  store i1 \00"
@.str.33371 = private unnamed_addr constant [8 x i8] c", ptr %\00"
@.str.33375 = private unnamed_addr constant [3 x i8] c"\0A\00"
@.str.33379 = private unnamed_addr constant [1 x i8] c"\00"
@.str.33462 = private unnamed_addr constant [7 x i8] c"return\00"
@.str.33536 = private unnamed_addr constant [3 x i8] c"  \00"
@.str.33540 = private unnamed_addr constant [27 x i8] c" = inttoptr i64 0 to ptr\0A\00"
@.str.33587 = private unnamed_addr constant [3 x i8] c"  \00"
@.str.33591 = private unnamed_addr constant [28 x i8] c" = getelementptr inbounds [\00"
@.str.33595 = private unnamed_addr constant [19 x i8] c" x i8], ptr @.str.\00"
@.str.33599 = private unnamed_addr constant [17 x i8] c", i32 0, i32 0\0A\00"
@.str.33623 = private unnamed_addr constant [3 x i8] c"  \00"
@.str.33627 = private unnamed_addr constant [19 x i8] c" = load ptr, ptr %\00"
@.str.33643 = private unnamed_addr constant [3 x i8] c"\0A\00"
@.str.33677 = private unnamed_addr constant [2 x i8] c"(\00"
@.str.33690 = private unnamed_addr constant [2 x i8] c"(\00"
@.str.33692 = private unnamed_addr constant [2 x i8] c")\00"
@.str.33716 = private unnamed_addr constant [3 x i8] c"  \00"
@.str.33720 = private unnamed_addr constant [14 x i8] c" = call ptr @\00"
@.str.33732 = private unnamed_addr constant [2 x i8] c"(\00"
@.str.33749 = private unnamed_addr constant [4 x i8] c")\0A\00"
@.str.33783 = private unnamed_addr constant [2 x i8] c".\00"
@.str.33798 = private unnamed_addr constant [10 x i8] c"substring\00"
@.str.33813 = private unnamed_addr constant [2 x i8] c"(\00"
@.str.33826 = private unnamed_addr constant [2 x i8] c"(\00"
@.str.33828 = private unnamed_addr constant [2 x i8] c")\00"
@.str.33853 = private unnamed_addr constant [2 x i8] c",\00"
@.str.33892 = private unnamed_addr constant [3 x i8] c"  \00"
@.str.33896 = private unnamed_addr constant [23 x i8] c".obj = load ptr, ptr %\00"
@.str.33900 = private unnamed_addr constant [3 x i8] c"\0A\00"
@.str.33914 = private unnamed_addr constant [7 x i8] c".start\00"
@.str.33931 = private unnamed_addr constant [8 x i8] c".length\00"
@.str.33934 = private unnamed_addr constant [3 x i8] c"  \00"
@.str.33938 = private unnamed_addr constant [40 x i8] c" = call ptr @csec_string_substring(ptr \00"
@.str.33942 = private unnamed_addr constant [11 x i8] c".obj, i32 \00"
@.str.33946 = private unnamed_addr constant [13 x i8] c".start, i32 \00"
@.str.33950 = private unnamed_addr constant [11 x i8] c".length)\0A\00"
@.str.33994 = private unnamed_addr constant [2 x i8] c"+\00"
@.str.34073 = private unnamed_addr constant [1 x i8] c"\00"
@.str.34080 = private unnamed_addr constant [1 x i8] c"\00"
@.str.34140 = private unnamed_addr constant [4 x i8] c"ptr\00"
@.str.34174 = private unnamed_addr constant [2 x i8] c"(\00"
@.str.34187 = private unnamed_addr constant [2 x i8] c"(\00"
@.str.34189 = private unnamed_addr constant [2 x i8] c")\00"
@.str.34213 = private unnamed_addr constant [4 x i8] c"ptr\00"
@.str.34247 = private unnamed_addr constant [2 x i8] c".\00"
@.str.34262 = private unnamed_addr constant [10 x i8] c"substring\00"
@.str.34277 = private unnamed_addr constant [2 x i8] c"(\00"
@.str.34290 = private unnamed_addr constant [2 x i8] c"(\00"
@.str.34292 = private unnamed_addr constant [2 x i8] c")\00"
@.str.34325 = private unnamed_addr constant [2 x i8] c"+\00"
@.str.34342 = private unnamed_addr constant [6 x i8] c".left\00"
@.str.34369 = private unnamed_addr constant [3 x i8] c"  \00"
@.str.34373 = private unnamed_addr constant [42 x i8] c".left = call ptr @csec_to_string_char(i8 \00"
@.str.34385 = private unnamed_addr constant [4 x i8] c")\0A\00"
@.str.34424 = private unnamed_addr constant [5 x i8] c"Char\00"
@.str.34430 = private unnamed_addr constant [3 x i8] c"  \00"
@.str.34434 = private unnamed_addr constant [26 x i8] c".left.i8 = load i8, ptr %\00"
@.str.34450 = private unnamed_addr constant [3 x i8] c"\0A\00"
@.str.34452 = private unnamed_addr constant [3 x i8] c"  \00"
@.str.34456 = private unnamed_addr constant [42 x i8] c".left = call ptr @csec_to_string_char(i8 \00"
@.str.34460 = private unnamed_addr constant [12 x i8] c".left.i8)\0A\00"
@.str.34477 = private unnamed_addr constant [10 x i8] c".left.i32\00"
@.str.34480 = private unnamed_addr constant [3 x i8] c"  \00"
@.str.34484 = private unnamed_addr constant [22 x i8] c".left.i64 = sext i32 \00"
@.str.34488 = private unnamed_addr constant [19 x i8] c".left.i32 to i64\0A\00"
@.str.34490 = private unnamed_addr constant [3 x i8] c"  \00"
@.str.34494 = private unnamed_addr constant [42 x i8] c".left = call ptr @csec_to_string_i64(i64 \00"
@.str.34498 = private unnamed_addr constant [13 x i8] c".left.i64)\0A\00"
@.str.34559 = private unnamed_addr constant [4 x i8] c"ptr\00"
@.str.34593 = private unnamed_addr constant [2 x i8] c"(\00"
@.str.34606 = private unnamed_addr constant [2 x i8] c"(\00"
@.str.34608 = private unnamed_addr constant [2 x i8] c")\00"
@.str.34632 = private unnamed_addr constant [4 x i8] c"ptr\00"
@.str.34666 = private unnamed_addr constant [2 x i8] c".\00"
@.str.34681 = private unnamed_addr constant [10 x i8] c"substring\00"
@.str.34696 = private unnamed_addr constant [2 x i8] c"(\00"
@.str.34709 = private unnamed_addr constant [2 x i8] c"(\00"
@.str.34711 = private unnamed_addr constant [2 x i8] c")\00"
@.str.34744 = private unnamed_addr constant [2 x i8] c"+\00"
@.str.34761 = private unnamed_addr constant [7 x i8] c".right\00"
@.str.34788 = private unnamed_addr constant [3 x i8] c"  \00"
@.str.34792 = private unnamed_addr constant [43 x i8] c".right = call ptr @csec_to_string_char(i8 \00"
@.str.34804 = private unnamed_addr constant [4 x i8] c")\0A\00"
@.str.34843 = private unnamed_addr constant [5 x i8] c"Char\00"
@.str.34849 = private unnamed_addr constant [3 x i8] c"  \00"
@.str.34853 = private unnamed_addr constant [27 x i8] c".right.i8 = load i8, ptr %\00"
@.str.34869 = private unnamed_addr constant [3 x i8] c"\0A\00"
@.str.34871 = private unnamed_addr constant [3 x i8] c"  \00"
@.str.34875 = private unnamed_addr constant [43 x i8] c".right = call ptr @csec_to_string_char(i8 \00"
@.str.34879 = private unnamed_addr constant [13 x i8] c".right.i8)\0A\00"
@.str.34896 = private unnamed_addr constant [11 x i8] c".right.i32\00"
@.str.34899 = private unnamed_addr constant [3 x i8] c"  \00"
@.str.34903 = private unnamed_addr constant [23 x i8] c".right.i64 = sext i32 \00"
@.str.34907 = private unnamed_addr constant [20 x i8] c".right.i32 to i64\0A\00"
@.str.34909 = private unnamed_addr constant [3 x i8] c"  \00"
@.str.34913 = private unnamed_addr constant [43 x i8] c".right = call ptr @csec_to_string_i64(i64 \00"
@.str.34917 = private unnamed_addr constant [14 x i8] c".right.i64)\0A\00"
@.str.34925 = private unnamed_addr constant [3 x i8] c"  \00"
@.str.34929 = private unnamed_addr constant [37 x i8] c" = call ptr @csec_string_concat(ptr \00"
@.str.34933 = private unnamed_addr constant [12 x i8] c".left, ptr \00"
@.str.34937 = private unnamed_addr constant [10 x i8] c".right)\0A\00"
@.str.34941 = private unnamed_addr constant [3 x i8] c"  \00"
@.str.34945 = private unnamed_addr constant [27 x i8] c" = inttoptr i64 0 to ptr\0A\00"
@.str.35003 = private unnamed_addr constant [7 x i8] c".addr.\00"
@.str.35012 = private unnamed_addr constant [2 x i8] c"%\00"
@.str.35016 = private unnamed_addr constant [8 x i8] c".pinit.\00"
@.str.35056 = private unnamed_addr constant [4 x i8] c"  %\00"
@.str.35060 = private unnamed_addr constant [16 x i8] c" = alloca ptr\0A\00"
@.str.35073 = private unnamed_addr constant [13 x i8] c"  store ptr \00"
@.str.35077 = private unnamed_addr constant [8 x i8] c", ptr %\00"
@.str.35081 = private unnamed_addr constant [3 x i8] c"\0A\00"
@.str.35085 = private unnamed_addr constant [4 x i8] c"  %\00"
@.str.35089 = private unnamed_addr constant [16 x i8] c" = alloca ptr\0A\00"
@.str.35091 = private unnamed_addr constant [24 x i8] c"  store ptr null, ptr %\00"
@.str.35095 = private unnamed_addr constant [3 x i8] c"\0A\00"
@.str.35205 = private unnamed_addr constant [4 x i8] c"ptr\00"
@.str.35240 = private unnamed_addr constant [2 x i8] c"(\00"
@.str.35253 = private unnamed_addr constant [2 x i8] c"(\00"
@.str.35255 = private unnamed_addr constant [2 x i8] c")\00"
@.str.35281 = private unnamed_addr constant [4 x i8] c"ptr\00"
@.str.35316 = private unnamed_addr constant [2 x i8] c".\00"
@.str.35331 = private unnamed_addr constant [10 x i8] c"substring\00"
@.str.35346 = private unnamed_addr constant [2 x i8] c"(\00"
@.str.35359 = private unnamed_addr constant [2 x i8] c"(\00"
@.str.35361 = private unnamed_addr constant [2 x i8] c")\00"
@.str.35413 = private unnamed_addr constant [2 x i8] c"+\00"
@.str.35532 = private unnamed_addr constant [6 x i8] c"value\00"
@.str.35539 = private unnamed_addr constant [9 x i8] c"variable\00"
@.str.35556 = private unnamed_addr constant [4 x i8] c"Int\00"
@.str.35570 = private unnamed_addr constant [8 x i8] c"unknown\00"
@.str.35603 = private unnamed_addr constant [8 x i8] c"Boolean\00"
@.str.35636 = private unnamed_addr constant [7 x i8] c"Double\00"
@.str.35669 = private unnamed_addr constant [5 x i8] c"Long\00"
@.str.35702 = private unnamed_addr constant [5 x i8] c"Char\00"
@.str.35737 = private unnamed_addr constant [4 x i8] c"ptr\00"
@.str.35752 = private unnamed_addr constant [4 x i8] c"Int\00"
@.str.35767 = private unnamed_addr constant [8 x i8] c"Boolean\00"
@.str.35782 = private unnamed_addr constant [7 x i8] c"Double\00"
@.str.35797 = private unnamed_addr constant [5 x i8] c"Long\00"
@.str.35812 = private unnamed_addr constant [5 x i8] c"Char\00"
@.str.35839 = private unnamed_addr constant [7 x i8] c"return\00"
@.str.35870 = private unnamed_addr constant [2 x i8] c";\00"
@.str.35878 = private unnamed_addr constant [10 x i8] c"  ret i1 \00"
@.str.35889 = private unnamed_addr constant [3 x i8] c"\0A\00"
@.str.35921 = private unnamed_addr constant [2 x i8] c";\00"
@.str.35955 = private unnamed_addr constant [6 x i8] c"%ret.\00"
@.str.35963 = private unnamed_addr constant [3 x i8] c"  \00"
@.str.35967 = private unnamed_addr constant [28 x i8] c" = getelementptr inbounds [\00"
@.str.35971 = private unnamed_addr constant [19 x i8] c" x i8], ptr @.str.\00"
@.str.35979 = private unnamed_addr constant [17 x i8] c", i32 0, i32 0\0A\00"
@.str.35981 = private unnamed_addr constant [11 x i8] c"  ret ptr \00"
@.str.35985 = private unnamed_addr constant [3 x i8] c"\0A\00"
@.str.36017 = private unnamed_addr constant [2 x i8] c";\00"
@.str.36064 = private unnamed_addr constant [6 x i8] c"%ret.\00"
@.str.36074 = private unnamed_addr constant [4 x i8] c"ptr\00"
@.str.36081 = private unnamed_addr constant [3 x i8] c"i8\00"
@.str.36088 = private unnamed_addr constant [3 x i8] c"i1\00"
@.str.36095 = private unnamed_addr constant [4 x i8] c"i64\00"
@.str.36102 = private unnamed_addr constant [7 x i8] c"double\00"
@.str.36110 = private unnamed_addr constant [3 x i8] c"  \00"
@.str.36114 = private unnamed_addr constant [9 x i8] c" = load \00"
@.str.36118 = private unnamed_addr constant [8 x i8] c", ptr %\00"
@.str.36131 = private unnamed_addr constant [3 x i8] c"\0A\00"
@.str.36133 = private unnamed_addr constant [7 x i8] c"  ret \00"
@.str.36137 = private unnamed_addr constant [2 x i8] c" \00"
@.str.36141 = private unnamed_addr constant [3 x i8] c"\0A\00"
@.str.36164 = private unnamed_addr constant [11 x i8] c"  ret i32 \00"
@.str.36168 = private unnamed_addr constant [3 x i8] c"\0A\00"
@.str.36207 = private unnamed_addr constant [2 x i8] c"(\00"
@.str.36226 = private unnamed_addr constant [2 x i8] c"(\00"
@.str.36228 = private unnamed_addr constant [2 x i8] c")\00"
@.str.36265 = private unnamed_addr constant [6 x i8] c"%ret.\00"
@.str.36282 = private unnamed_addr constant [4 x i8] c"ptr\00"
@.str.36289 = private unnamed_addr constant [3 x i8] c"i8\00"
@.str.36296 = private unnamed_addr constant [3 x i8] c"i1\00"
@.str.36303 = private unnamed_addr constant [4 x i8] c"i64\00"
@.str.36310 = private unnamed_addr constant [7 x i8] c"double\00"
@.str.36332 = private unnamed_addr constant [3 x i8] c"  \00"
@.str.36336 = private unnamed_addr constant [9 x i8] c" = call \00"
@.str.36340 = private unnamed_addr constant [3 x i8] c" @\00"
@.str.36354 = private unnamed_addr constant [2 x i8] c"(\00"
@.str.36369 = private unnamed_addr constant [4 x i8] c")\0A\00"
@.str.36371 = private unnamed_addr constant [7 x i8] c"  ret \00"
@.str.36375 = private unnamed_addr constant [2 x i8] c" \00"
@.str.36379 = private unnamed_addr constant [3 x i8] c"\0A\00"
@.str.36402 = private unnamed_addr constant [11 x i8] c"  ret i32 \00"
@.str.36406 = private unnamed_addr constant [3 x i8] c"\0A\00"
@.str.36431 = private unnamed_addr constant [6 x i8] c"%ret.\00"
@.str.36452 = private unnamed_addr constant [11 x i8] c"  ret ptr \00"
@.str.36456 = private unnamed_addr constant [3 x i8] c"\0A\00"
@.str.36467 = private unnamed_addr constant [6 x i8] c"%ret.\00"
@.str.36488 = private unnamed_addr constant [11 x i8] c"  ret i32 \00"
@.str.36492 = private unnamed_addr constant [3 x i8] c"\0A\00"
@.str.36504 = private unnamed_addr constant [3 x i8] c"if\00"
@.str.36563 = private unnamed_addr constant [2 x i8] c"{\00"
@.str.36565 = private unnamed_addr constant [2 x i8] c"}\00"
@.str.36591 = private unnamed_addr constant [19 x i8] c"  ; malformed if\0A\00"
@.str.36602 = private unnamed_addr constant [1 x i8] c"\00"
@.str.36641 = private unnamed_addr constant [20 x i8] c"  br label %if.end.\00"
@.str.36645 = private unnamed_addr constant [3 x i8] c"\0A\00"
@.str.36663 = private unnamed_addr constant [1 x i8] c"\00"
@.str.36671 = private unnamed_addr constant [1 x i8] c"\00"
@.str.36678 = private unnamed_addr constant [20 x i8] c"  br label %if.end.\00"
@.str.36682 = private unnamed_addr constant [3 x i8] c"\0A\00"
@.str.36700 = private unnamed_addr constant [5 x i8] c"else\00"
@.str.36730 = private unnamed_addr constant [2 x i8] c"{\00"
@.str.36747 = private unnamed_addr constant [2 x i8] c"{\00"
@.str.36749 = private unnamed_addr constant [2 x i8] c"}\00"
@.str.36788 = private unnamed_addr constant [1 x i8] c"\00"
@.str.36808 = private unnamed_addr constant [7 x i8] c"%cond.\00"
@.str.36813 = private unnamed_addr constant [15 x i8] c"  br i1 %cond.\00"
@.str.36817 = private unnamed_addr constant [18 x i8] c", label %if.then.\00"
@.str.36821 = private unnamed_addr constant [18 x i8] c", label %if.else.\00"
@.str.36825 = private unnamed_addr constant [3 x i8] c"\0A\00"
@.str.36827 = private unnamed_addr constant [9 x i8] c"if.then.\00"
@.str.36831 = private unnamed_addr constant [4 x i8] c":\0A\00"
@.str.36837 = private unnamed_addr constant [9 x i8] c"if.else.\00"
@.str.36841 = private unnamed_addr constant [4 x i8] c":\0A\00"
@.str.36847 = private unnamed_addr constant [8 x i8] c"if.end.\00"
@.str.36851 = private unnamed_addr constant [4 x i8] c":\0A\00"
@.str.36863 = private unnamed_addr constant [6 x i8] c"while\00"
@.str.36922 = private unnamed_addr constant [2 x i8] c"{\00"
@.str.36924 = private unnamed_addr constant [2 x i8] c"}\00"
@.str.36950 = private unnamed_addr constant [22 x i8] c"  ; malformed while\0A\00"
@.str.36961 = private unnamed_addr constant [1 x i8] c"\00"
@.str.36986 = private unnamed_addr constant [24 x i8] c"  br label %while.cond.\00"
@.str.36990 = private unnamed_addr constant [3 x i8] c"\0A\00"
@.str.37008 = private unnamed_addr constant [1 x i8] c"\00"
@.str.37015 = private unnamed_addr constant [24 x i8] c"  br label %while.cond.\00"
@.str.37019 = private unnamed_addr constant [3 x i8] c"\0A\00"
@.str.37021 = private unnamed_addr constant [12 x i8] c"while.cond.\00"
@.str.37025 = private unnamed_addr constant [4 x i8] c":\0A\00"
@.str.37037 = private unnamed_addr constant [12 x i8] c"%whilecond.\00"
@.str.37042 = private unnamed_addr constant [20 x i8] c"  br i1 %whilecond.\00"
@.str.37046 = private unnamed_addr constant [21 x i8] c", label %while.body.\00"
@.str.37050 = private unnamed_addr constant [20 x i8] c", label %while.end.\00"
@.str.37054 = private unnamed_addr constant [3 x i8] c"\0A\00"
@.str.37056 = private unnamed_addr constant [12 x i8] c"while.body.\00"
@.str.37060 = private unnamed_addr constant [4 x i8] c":\0A\00"
@.str.37066 = private unnamed_addr constant [11 x i8] c"while.end.\00"
@.str.37070 = private unnamed_addr constant [4 x i8] c":\0A\00"
@.str.37082 = private unnamed_addr constant [4 x i8] c"for\00"
@.str.37141 = private unnamed_addr constant [2 x i8] c"{\00"
@.str.37143 = private unnamed_addr constant [2 x i8] c"}\00"
@.str.37169 = private unnamed_addr constant [20 x i8] c"  ; malformed for\0A\00"
@.str.37194 = private unnamed_addr constant [29 x i8] c"  ; malformed for iterator\0A\00"
@.str.37229 = private unnamed_addr constant [3 x i8] c"<-\00"
@.str.37243 = private unnamed_addr constant [27 x i8] c"  ; malformed for source\0A\00"
@.str.37278 = private unnamed_addr constant [29 x i8] c"  ; unsupported for source\0A\00"
@.str.37289 = private unnamed_addr constant [1 x i8] c"\00"
@.str.37298 = private unnamed_addr constant [4 x i8] c"slt\00"
@.str.37311 = private unnamed_addr constant [3 x i8] c"to\00"
@.str.37323 = private unnamed_addr constant [3 x i8] c"..\00"
@.str.37329 = private unnamed_addr constant [4 x i8] c"sle\00"
@.str.37353 = private unnamed_addr constant [4 x i8] c"  %\00"
@.str.37357 = private unnamed_addr constant [7 x i8] c".step.\00"
@.str.37361 = private unnamed_addr constant [19 x i8] c" = load i32, ptr %\00"
@.str.37365 = private unnamed_addr constant [3 x i8] c"\0A\00"
@.str.37367 = private unnamed_addr constant [4 x i8] c"  %\00"
@.str.37371 = private unnamed_addr constant [7 x i8] c".next.\00"
@.str.37375 = private unnamed_addr constant [13 x i8] c" = add i32 %\00"
@.str.37379 = private unnamed_addr constant [7 x i8] c".step.\00"
@.str.37383 = private unnamed_addr constant [6 x i8] c", 1\0A\00"
@.str.37385 = private unnamed_addr constant [14 x i8] c"  store i32 %\00"
@.str.37389 = private unnamed_addr constant [7 x i8] c".next.\00"
@.str.37393 = private unnamed_addr constant [8 x i8] c", ptr %\00"
@.str.37397 = private unnamed_addr constant [3 x i8] c"\0A\00"
@.str.37399 = private unnamed_addr constant [22 x i8] c"  br label %for.cond.\00"
@.str.37403 = private unnamed_addr constant [3 x i8] c"\0A\00"
@.str.37421 = private unnamed_addr constant [1 x i8] c"\00"
@.str.37428 = private unnamed_addr constant [4 x i8] c"  %\00"
@.str.37432 = private unnamed_addr constant [16 x i8] c" = alloca i32\0A\00"
@.str.37444 = private unnamed_addr constant [2 x i8] c"%\00"
@.str.37448 = private unnamed_addr constant [7 x i8] c".start\00"
@.str.37451 = private unnamed_addr constant [14 x i8] c"  store i32 %\00"
@.str.37455 = private unnamed_addr constant [14 x i8] c".start, ptr %\00"
@.str.37459 = private unnamed_addr constant [3 x i8] c"\0A\00"
@.str.37461 = private unnamed_addr constant [22 x i8] c"  br label %for.cond.\00"
@.str.37465 = private unnamed_addr constant [3 x i8] c"\0A\00"
@.str.37467 = private unnamed_addr constant [10 x i8] c"for.cond.\00"
@.str.37471 = private unnamed_addr constant [4 x i8] c":\0A\00"
@.str.37473 = private unnamed_addr constant [4 x i8] c"  %\00"
@.str.37477 = private unnamed_addr constant [23 x i8] c".val = load i32, ptr %\00"
@.str.37481 = private unnamed_addr constant [3 x i8] c"\0A\00"
@.str.37493 = private unnamed_addr constant [2 x i8] c"%\00"
@.str.37497 = private unnamed_addr constant [5 x i8] c".end\00"
@.str.37500 = private unnamed_addr constant [12 x i8] c"  %forcond.\00"
@.str.37504 = private unnamed_addr constant [9 x i8] c" = icmp \00"
@.str.37508 = private unnamed_addr constant [7 x i8] c" i32 %\00"
@.str.37512 = private unnamed_addr constant [8 x i8] c".val, %\00"
@.str.37516 = private unnamed_addr constant [7 x i8] c".end\0A\00"
@.str.37518 = private unnamed_addr constant [18 x i8] c"  br i1 %forcond.\00"
@.str.37522 = private unnamed_addr constant [19 x i8] c", label %for.body.\00"
@.str.37526 = private unnamed_addr constant [18 x i8] c", label %for.end.\00"
@.str.37530 = private unnamed_addr constant [3 x i8] c"\0A\00"
@.str.37532 = private unnamed_addr constant [10 x i8] c"for.body.\00"
@.str.37536 = private unnamed_addr constant [4 x i8] c":\0A\00"
@.str.37542 = private unnamed_addr constant [9 x i8] c"for.end.\00"
@.str.37546 = private unnamed_addr constant [4 x i8] c":\0A\00"
@.str.37586 = private unnamed_addr constant [2 x i8] c"(\00"
@.str.37598 = private unnamed_addr constant [27 x i8] c"csec_string_builder_append\00"
@.str.37617 = private unnamed_addr constant [2 x i8] c"(\00"
@.str.37619 = private unnamed_addr constant [2 x i8] c")\00"
@.str.37636 = private unnamed_addr constant [9 x i8] c"%append.\00"
@.str.37657 = private unnamed_addr constant [3 x i8] c"  \00"
@.str.37661 = private unnamed_addr constant [41 x i8] c" = call i32 @csec_string_builder_append(\00"
@.str.37676 = private unnamed_addr constant [4 x i8] c")\0A\00"
@.str.37721 = private unnamed_addr constant [8 x i8] c"Boolean\00"
@.str.37747 = private unnamed_addr constant [7 x i8] c"Double\00"
@.str.37773 = private unnamed_addr constant [5 x i8] c"Long\00"
@.str.37799 = private unnamed_addr constant [5 x i8] c"Char\00"
@.str.37828 = private unnamed_addr constant [4 x i8] c"ptr\00"
@.str.37973 = private unnamed_addr constant [2 x i8] c"{\00"
@.str.37975 = private unnamed_addr constant [2 x i8] c"}\00"
@.str.37998 = private unnamed_addr constant [19 x i8] c"  ; malformed if\0A\00"
@.str.38006 = private unnamed_addr constant [1 x i8] c"\00"
@.str.38045 = private unnamed_addr constant [20 x i8] c"  br label %if.end.\00"
@.str.38049 = private unnamed_addr constant [3 x i8] c"\0A\00"
@.str.38067 = private unnamed_addr constant [1 x i8] c"\00"
@.str.38075 = private unnamed_addr constant [1 x i8] c"\00"
@.str.38082 = private unnamed_addr constant [20 x i8] c"  br label %if.end.\00"
@.str.38086 = private unnamed_addr constant [3 x i8] c"\0A\00"
@.str.38104 = private unnamed_addr constant [5 x i8] c"else\00"
@.str.38134 = private unnamed_addr constant [3 x i8] c"if\00"
@.str.38163 = private unnamed_addr constant [2 x i8] c"{\00"
@.str.38180 = private unnamed_addr constant [2 x i8] c"{\00"
@.str.38182 = private unnamed_addr constant [2 x i8] c"}\00"
@.str.38221 = private unnamed_addr constant [1 x i8] c"\00"
@.str.38238 = private unnamed_addr constant [7 x i8] c"%cond.\00"
@.str.38243 = private unnamed_addr constant [15 x i8] c"  br i1 %cond.\00"
@.str.38247 = private unnamed_addr constant [18 x i8] c", label %if.then.\00"
@.str.38251 = private unnamed_addr constant [18 x i8] c", label %if.else.\00"
@.str.38255 = private unnamed_addr constant [3 x i8] c"\0A\00"
@.str.38257 = private unnamed_addr constant [9 x i8] c"if.then.\00"
@.str.38261 = private unnamed_addr constant [4 x i8] c":\0A\00"
@.str.38267 = private unnamed_addr constant [9 x i8] c"if.else.\00"
@.str.38271 = private unnamed_addr constant [4 x i8] c":\0A\00"
@.str.38277 = private unnamed_addr constant [8 x i8] c"if.end.\00"
@.str.38281 = private unnamed_addr constant [4 x i8] c":\0A\00"
@.str.38357 = private unnamed_addr constant [2 x i8] c"{\00"
@.str.38359 = private unnamed_addr constant [2 x i8] c"}\00"
@.str.38382 = private unnamed_addr constant [22 x i8] c"  ; malformed while\0A\00"
@.str.38390 = private unnamed_addr constant [1 x i8] c"\00"
@.str.38415 = private unnamed_addr constant [24 x i8] c"  br label %while.cond.\00"
@.str.38419 = private unnamed_addr constant [3 x i8] c"\0A\00"
@.str.38437 = private unnamed_addr constant [1 x i8] c"\00"
@.str.38441 = private unnamed_addr constant [24 x i8] c"  br label %while.cond.\00"
@.str.38445 = private unnamed_addr constant [3 x i8] c"\0A\00"
@.str.38447 = private unnamed_addr constant [12 x i8] c"while.cond.\00"
@.str.38451 = private unnamed_addr constant [4 x i8] c":\0A\00"
@.str.38463 = private unnamed_addr constant [12 x i8] c"%whilecond.\00"
@.str.38468 = private unnamed_addr constant [20 x i8] c"  br i1 %whilecond.\00"
@.str.38472 = private unnamed_addr constant [21 x i8] c", label %while.body.\00"
@.str.38476 = private unnamed_addr constant [20 x i8] c", label %while.end.\00"
@.str.38480 = private unnamed_addr constant [3 x i8] c"\0A\00"
@.str.38482 = private unnamed_addr constant [12 x i8] c"while.body.\00"
@.str.38486 = private unnamed_addr constant [4 x i8] c":\0A\00"
@.str.38492 = private unnamed_addr constant [11 x i8] c"while.end.\00"
@.str.38496 = private unnamed_addr constant [4 x i8] c":\0A\00"
@.str.38572 = private unnamed_addr constant [2 x i8] c"{\00"
@.str.38574 = private unnamed_addr constant [2 x i8] c"}\00"
@.str.38597 = private unnamed_addr constant [20 x i8] c"  ; malformed for\0A\00"
@.str.38617 = private unnamed_addr constant [29 x i8] c"  ; malformed for iterator\0A\00"
@.str.38649 = private unnamed_addr constant [3 x i8] c"<-\00"
@.str.38660 = private unnamed_addr constant [27 x i8] c"  ; malformed for source\0A\00"
@.str.38689 = private unnamed_addr constant [29 x i8] c"  ; unsupported for source\0A\00"
@.str.38697 = private unnamed_addr constant [1 x i8] c"\00"
@.str.38706 = private unnamed_addr constant [4 x i8] c"slt\00"
@.str.38719 = private unnamed_addr constant [3 x i8] c"to\00"
@.str.38731 = private unnamed_addr constant [3 x i8] c"..\00"
@.str.38737 = private unnamed_addr constant [4 x i8] c"sle\00"
@.str.38761 = private unnamed_addr constant [4 x i8] c"  %\00"
@.str.38765 = private unnamed_addr constant [7 x i8] c".step.\00"
@.str.38769 = private unnamed_addr constant [19 x i8] c" = load i32, ptr %\00"
@.str.38773 = private unnamed_addr constant [3 x i8] c"\0A\00"
@.str.38775 = private unnamed_addr constant [4 x i8] c"  %\00"
@.str.38779 = private unnamed_addr constant [7 x i8] c".next.\00"
@.str.38783 = private unnamed_addr constant [13 x i8] c" = add i32 %\00"
@.str.38787 = private unnamed_addr constant [7 x i8] c".step.\00"
@.str.38791 = private unnamed_addr constant [6 x i8] c", 1\0A\00"
@.str.38793 = private unnamed_addr constant [14 x i8] c"  store i32 %\00"
@.str.38797 = private unnamed_addr constant [7 x i8] c".next.\00"
@.str.38801 = private unnamed_addr constant [8 x i8] c", ptr %\00"
@.str.38805 = private unnamed_addr constant [3 x i8] c"\0A\00"
@.str.38807 = private unnamed_addr constant [22 x i8] c"  br label %for.cond.\00"
@.str.38811 = private unnamed_addr constant [3 x i8] c"\0A\00"
@.str.38829 = private unnamed_addr constant [1 x i8] c"\00"
@.str.38833 = private unnamed_addr constant [4 x i8] c"  %\00"
@.str.38837 = private unnamed_addr constant [16 x i8] c" = alloca i32\0A\00"
@.str.38849 = private unnamed_addr constant [2 x i8] c"%\00"
@.str.38853 = private unnamed_addr constant [7 x i8] c".start\00"
@.str.38856 = private unnamed_addr constant [14 x i8] c"  store i32 %\00"
@.str.38860 = private unnamed_addr constant [14 x i8] c".start, ptr %\00"
@.str.38864 = private unnamed_addr constant [3 x i8] c"\0A\00"
@.str.38866 = private unnamed_addr constant [22 x i8] c"  br label %for.cond.\00"
@.str.38870 = private unnamed_addr constant [3 x i8] c"\0A\00"
@.str.38872 = private unnamed_addr constant [10 x i8] c"for.cond.\00"
@.str.38876 = private unnamed_addr constant [4 x i8] c":\0A\00"
@.str.38878 = private unnamed_addr constant [4 x i8] c"  %\00"
@.str.38882 = private unnamed_addr constant [23 x i8] c".val = load i32, ptr %\00"
@.str.38886 = private unnamed_addr constant [3 x i8] c"\0A\00"
@.str.38898 = private unnamed_addr constant [2 x i8] c"%\00"
@.str.38902 = private unnamed_addr constant [5 x i8] c".end\00"
@.str.38905 = private unnamed_addr constant [12 x i8] c"  %forcond.\00"
@.str.38909 = private unnamed_addr constant [9 x i8] c" = icmp \00"
@.str.38913 = private unnamed_addr constant [7 x i8] c" i32 %\00"
@.str.38917 = private unnamed_addr constant [8 x i8] c".val, %\00"
@.str.38921 = private unnamed_addr constant [7 x i8] c".end\0A\00"
@.str.38923 = private unnamed_addr constant [18 x i8] c"  br i1 %forcond.\00"
@.str.38927 = private unnamed_addr constant [19 x i8] c", label %for.body.\00"
@.str.38931 = private unnamed_addr constant [18 x i8] c", label %for.end.\00"
@.str.38935 = private unnamed_addr constant [3 x i8] c"\0A\00"
@.str.38937 = private unnamed_addr constant [10 x i8] c"for.body.\00"
@.str.38941 = private unnamed_addr constant [4 x i8] c":\0A\00"
@.str.38947 = private unnamed_addr constant [9 x i8] c"for.end.\00"
@.str.38951 = private unnamed_addr constant [4 x i8] c":\0A\00"
@.str.39009 = private unnamed_addr constant [7 x i8] c"return\00"
@.str.39040 = private unnamed_addr constant [2 x i8] c";\00"
@.str.39045 = private unnamed_addr constant [11 x i8] c"  ret i32 \00"
@.str.39056 = private unnamed_addr constant [3 x i8] c"\0A\00"
@.str.39077 = private unnamed_addr constant [5 x i8] c"%ret\00"
@.str.39080 = private unnamed_addr constant [17 x i8] c"  ret i32 %ret\0A\00"
@.str.39091 = private unnamed_addr constant [14 x i8] c"  ret i32 0\0A\00"
@.str.39124 = private unnamed_addr constant [7 x i8] c"System\00"
@.str.39139 = private unnamed_addr constant [2 x i8] c".\00"
@.str.39154 = private unnamed_addr constant [3 x i8] c"IO\00"
@.str.39169 = private unnamed_addr constant [2 x i8] c".\00"
@.str.39184 = private unnamed_addr constant [5 x i8] c"File\00"
@.str.39199 = private unnamed_addr constant [2 x i8] c".\00"
@.str.39214 = private unnamed_addr constant [13 x i8] c"WriteAllText\00"
@.str.39229 = private unnamed_addr constant [2 x i8] c"(\00"
@.str.39248 = private unnamed_addr constant [2 x i8] c"(\00"
@.str.39250 = private unnamed_addr constant [2 x i8] c")\00"
@.str.39267 = private unnamed_addr constant [13 x i8] c"%file.write.\00"
@.str.39285 = private unnamed_addr constant [3 x i8] c"  \00"
@.str.39289 = private unnamed_addr constant [39 x i8] c" = call i32 @csec_file_write_all_text(\00"
@.str.39304 = private unnamed_addr constant [4 x i8] c")\0A\00"
@.str.39320 = private unnamed_addr constant [7 x i8] c"System\00"
@.str.39335 = private unnamed_addr constant [2 x i8] c".\00"
@.str.39350 = private unnamed_addr constant [8 x i8] c"Console\00"
@.str.39365 = private unnamed_addr constant [2 x i8] c".\00"
@.str.39380 = private unnamed_addr constant [10 x i8] c"WriteLine\00"
@.str.39395 = private unnamed_addr constant [2 x i8] c"(\00"
@.str.39414 = private unnamed_addr constant [2 x i8] c"(\00"
@.str.39416 = private unnamed_addr constant [2 x i8] c")\00"
@.str.39433 = private unnamed_addr constant [16 x i8] c"%console.write.\00"
@.str.39451 = private unnamed_addr constant [32 x i8] c"  call void @csec_print_string(\00"
@.str.39466 = private unnamed_addr constant [4 x i8] c")\0A\00"
@.str.39468 = private unnamed_addr constant [36 x i8] c"  call void @csec_print_newline()\0A\00"
@.str.39473 = private unnamed_addr constant [1 x i8] c"\00"
@.str.39565 = private unnamed_addr constant [6 x i8] c"value\00"
@.str.39572 = private unnamed_addr constant [9 x i8] c"variable\00"
@.str.39589 = private unnamed_addr constant [4 x i8] c"Int\00"
@.str.39603 = private unnamed_addr constant [8 x i8] c"unknown\00"
@.str.39635 = private unnamed_addr constant [8 x i8] c"Boolean\00"
@.str.39667 = private unnamed_addr constant [7 x i8] c"Double\00"
@.str.39699 = private unnamed_addr constant [5 x i8] c"Long\00"
@.str.39731 = private unnamed_addr constant [5 x i8] c"Char\00"
@.str.39767 = private unnamed_addr constant [4 x i8] c"ptr\00"
@.str.39793 = private unnamed_addr constant [7 x i8] c"return\00"
@.str.39824 = private unnamed_addr constant [2 x i8] c";\00"
@.str.39832 = private unnamed_addr constant [11 x i8] c"  ret i32 \00"
@.str.39843 = private unnamed_addr constant [3 x i8] c"\0A\00"
@.str.39880 = private unnamed_addr constant [2 x i8] c";\00"
@.str.39918 = private unnamed_addr constant [8 x i8] c"Boolean\00"
@.str.39936 = private unnamed_addr constant [2 x i8] c"%\00"
@.str.39940 = private unnamed_addr constant [5 x i8] c".ret\00"
@.str.39943 = private unnamed_addr constant [24 x i8] c"  %ret.bool = zext i1 %\00"
@.str.39947 = private unnamed_addr constant [14 x i8] c".ret to i32\0A\00"
@.str.39949 = private unnamed_addr constant [22 x i8] c"  ret i32 %ret.bool\0A\00"
@.str.39965 = private unnamed_addr constant [7 x i8] c"Double\00"
@.str.39983 = private unnamed_addr constant [2 x i8] c"%\00"
@.str.39987 = private unnamed_addr constant [5 x i8] c".ret\00"
@.str.39990 = private unnamed_addr constant [32 x i8] c"  %ret.double = fptosi double %\00"
@.str.39994 = private unnamed_addr constant [14 x i8] c".ret to i32\0A\00"
@.str.39996 = private unnamed_addr constant [24 x i8] c"  ret i32 %ret.double\0A\00"
@.str.40020 = private unnamed_addr constant [2 x i8] c"%\00"
@.str.40024 = private unnamed_addr constant [5 x i8] c".ret\00"
@.str.40027 = private unnamed_addr constant [12 x i8] c"  ret i32 %\00"
@.str.40031 = private unnamed_addr constant [7 x i8] c".ret\0A\00"
@.str.40055 = private unnamed_addr constant [5 x i8] c"%ret\00"
@.str.40058 = private unnamed_addr constant [17 x i8] c"  ret i32 %ret\0A\00"
@.str.40074 = private unnamed_addr constant [3 x i8] c"if\00"
@.str.40099 = private unnamed_addr constant [6 x i8] c"while\00"
@.str.40124 = private unnamed_addr constant [4 x i8] c"for\00"
@.str.40150 = private unnamed_addr constant [6 x i8] c"value\00"
@.str.40158 = private unnamed_addr constant [9 x i8] c"variable\00"
@.str.40166 = private unnamed_addr constant [7 x i8] c"return\00"
@.str.40174 = private unnamed_addr constant [3 x i8] c"if\00"
@.str.40182 = private unnamed_addr constant [6 x i8] c"while\00"
@.str.40190 = private unnamed_addr constant [4 x i8] c"for\00"
@.str.40270 = private unnamed_addr constant [8 x i8] c"Boolean\00"
@.str.40295 = private unnamed_addr constant [7 x i8] c"Double\00"
@.str.40320 = private unnamed_addr constant [5 x i8] c"Long\00"
@.str.40345 = private unnamed_addr constant [5 x i8] c"Char\00"
@.str.40373 = private unnamed_addr constant [4 x i8] c"ptr\00"
@.str.40399 = private unnamed_addr constant [8 x i8] c"Boolean\00"
@.str.40407 = private unnamed_addr constant [7 x i8] c"Double\00"
@.str.40415 = private unnamed_addr constant [5 x i8] c"Long\00"
@.str.40423 = private unnamed_addr constant [5 x i8] c"Char\00"
@.str.40434 = private unnamed_addr constant [4 x i8] c"ptr\00"
@.str.40504 = private unnamed_addr constant [14 x i8] c"  ret i32 0\0A\00"
@.str.40571 = private unnamed_addr constant [1 x i8] c"\00"
@.str.40594 = private unnamed_addr constant [1 x i8] c"\00"
@.str.40611 = private unnamed_addr constant [1 x i8] c"\00"
@.str.40657 = private unnamed_addr constant [8 x i8] c"unknown\00"
@.str.40673 = private unnamed_addr constant [2 x i8] c":\00"
@.str.40701 = private unnamed_addr constant [3 x i8] c", \00"
@.str.40713 = private unnamed_addr constant [7 x i8] c" %arg.\00"
@.str.40744 = private unnamed_addr constant [2 x i8] c",\00"
@.str.40823 = private unnamed_addr constant [1 x i8] c"\00"
@.str.40844 = private unnamed_addr constant [2 x i8] c"(\00"
@.str.40846 = private unnamed_addr constant [2 x i8] c")\00"
@.str.40857 = private unnamed_addr constant [1 x i8] c"\00"
@.str.40874 = private unnamed_addr constant [1 x i8] c"\00"
@.str.40925 = private unnamed_addr constant [8 x i8] c"unknown\00"
@.str.40941 = private unnamed_addr constant [2 x i8] c":\00"
@.str.40973 = private unnamed_addr constant [4 x i8] c"  %\00"
@.str.40977 = private unnamed_addr constant [11 x i8] c" = alloca \00"
@.str.40981 = private unnamed_addr constant [3 x i8] c"\0A\00"
@.str.40983 = private unnamed_addr constant [9 x i8] c"  store \00"
@.str.40987 = private unnamed_addr constant [7 x i8] c" %arg.\00"
@.str.40991 = private unnamed_addr constant [8 x i8] c", ptr %\00"
@.str.40995 = private unnamed_addr constant [3 x i8] c"\0A\00"
@.str.41015 = private unnamed_addr constant [2 x i8] c",\00"
@.str.41126 = private unnamed_addr constant [7 x i8] c"return\00"
@.str.41137 = private unnamed_addr constant [6 x i8] c"%ret.\00"
@.str.41262 = private unnamed_addr constant [3 x i8] c"  \00"
@.str.41266 = private unnamed_addr constant [28 x i8] c".left.i32 = load i32, ptr %\00"
@.str.41270 = private unnamed_addr constant [3 x i8] c"\0A\00"
@.str.41272 = private unnamed_addr constant [3 x i8] c"  \00"
@.str.41276 = private unnamed_addr constant [25 x i8] c".right.i32 = add i32 0, \00"
@.str.41287 = private unnamed_addr constant [3 x i8] c"\0A\00"
@.str.41289 = private unnamed_addr constant [3 x i8] c"  \00"
@.str.41293 = private unnamed_addr constant [9 x i8] c" = icmp \00"
@.str.41297 = private unnamed_addr constant [6 x i8] c" i32 \00"
@.str.41301 = private unnamed_addr constant [12 x i8] c".left.i32, \00"
@.str.41305 = private unnamed_addr constant [13 x i8] c".right.i32\0A\00"
@.str.41307 = private unnamed_addr constant [10 x i8] c"  ret i1 \00"
@.str.41311 = private unnamed_addr constant [3 x i8] c"\0A\00"
@.str.41348 = private unnamed_addr constant [2 x i8] c";\00"
@.str.41369 = private unnamed_addr constant [10 x i8] c"  ret i1 \00"
@.str.41373 = private unnamed_addr constant [3 x i8] c"\0A\00"
@.str.41410 = private unnamed_addr constant [2 x i8] c";\00"
@.str.41418 = private unnamed_addr constant [3 x i8] c"  \00"
@.str.41422 = private unnamed_addr constant [18 x i8] c" = load i1, ptr %\00"
@.str.41442 = private unnamed_addr constant [3 x i8] c"\0A\00"
@.str.41444 = private unnamed_addr constant [10 x i8] c"  ret i1 \00"
@.str.41448 = private unnamed_addr constant [3 x i8] c"\0A\00"
@.str.41475 = private unnamed_addr constant [10 x i8] c"  ret i1 \00"
@.str.41479 = private unnamed_addr constant [3 x i8] c"\0A\00"
@.str.41496 = private unnamed_addr constant [3 x i8] c"if\00"
@.str.41555 = private unnamed_addr constant [2 x i8] c"{\00"
@.str.41557 = private unnamed_addr constant [2 x i8] c"}\00"
@.str.41583 = private unnamed_addr constant [19 x i8] c"  ; malformed if\0A\00"
@.str.41594 = private unnamed_addr constant [1 x i8] c"\00"
@.str.41617 = private unnamed_addr constant [1 x i8] c"\00"
@.str.41624 = private unnamed_addr constant [20 x i8] c"  br label %if.end.\00"
@.str.41628 = private unnamed_addr constant [3 x i8] c"\0A\00"
@.str.41659 = private unnamed_addr constant [1 x i8] c"\00"
@.str.41683 = private unnamed_addr constant [1 x i8] c"\00"
@.str.41690 = private unnamed_addr constant [20 x i8] c"  br label %if.end.\00"
@.str.41694 = private unnamed_addr constant [3 x i8] c"\0A\00"
@.str.41712 = private unnamed_addr constant [5 x i8] c"else\00"
@.str.41742 = private unnamed_addr constant [3 x i8] c"if\00"
@.str.41771 = private unnamed_addr constant [2 x i8] c"{\00"
@.str.41788 = private unnamed_addr constant [2 x i8] c"{\00"
@.str.41790 = private unnamed_addr constant [2 x i8] c"}\00"
@.str.41829 = private unnamed_addr constant [1 x i8] c"\00"
@.str.41865 = private unnamed_addr constant [7 x i8] c"%cond.\00"
@.str.41870 = private unnamed_addr constant [15 x i8] c"  br i1 %cond.\00"
@.str.41874 = private unnamed_addr constant [18 x i8] c", label %if.then.\00"
@.str.41878 = private unnamed_addr constant [18 x i8] c", label %if.else.\00"
@.str.41882 = private unnamed_addr constant [3 x i8] c"\0A\00"
@.str.41884 = private unnamed_addr constant [9 x i8] c"if.then.\00"
@.str.41888 = private unnamed_addr constant [4 x i8] c":\0A\00"
@.str.41894 = private unnamed_addr constant [9 x i8] c"if.else.\00"
@.str.41898 = private unnamed_addr constant [4 x i8] c":\0A\00"
@.str.41904 = private unnamed_addr constant [8 x i8] c"if.end.\00"
@.str.41908 = private unnamed_addr constant [4 x i8] c":\0A\00"
@.str.41944 = private unnamed_addr constant [17 x i8] c"  ret i1 false\0A\00"
@.str.42036 = private unnamed_addr constant [7 x i8] c"return\00"
@.str.42067 = private unnamed_addr constant [2 x i8] c";\00"
@.str.42075 = private unnamed_addr constant [10 x i8] c"  ret i8 \00"
@.str.42089 = private unnamed_addr constant [3 x i8] c"\0A\00"
@.str.42126 = private unnamed_addr constant [2 x i8] c";\00"
@.str.42134 = private unnamed_addr constant [24 x i8] c"  %ret = load i8, ptr %\00"
@.str.42154 = private unnamed_addr constant [3 x i8] c"\0A\00"
@.str.42156 = private unnamed_addr constant [16 x i8] c"  ret i8 %ret\0A\00"
@.str.42199 = private unnamed_addr constant [2 x i8] c"(\00"
@.str.42218 = private unnamed_addr constant [2 x i8] c"(\00"
@.str.42220 = private unnamed_addr constant [2 x i8] c")\00"
@.str.42237 = private unnamed_addr constant [6 x i8] c"%ret.\00"
@.str.42258 = private unnamed_addr constant [3 x i8] c"  \00"
@.str.42262 = private unnamed_addr constant [13 x i8] c" = call i8 @\00"
@.str.42276 = private unnamed_addr constant [2 x i8] c"(\00"
@.str.42291 = private unnamed_addr constant [4 x i8] c")\0A\00"
@.str.42293 = private unnamed_addr constant [10 x i8] c"  ret i8 \00"
@.str.42297 = private unnamed_addr constant [3 x i8] c"\0A\00"
@.str.42337 = private unnamed_addr constant [13 x i8] c"  ret i8 0\0A\00"
@.str.42429 = private unnamed_addr constant [7 x i8] c"return\00"
@.str.42475 = private unnamed_addr constant [2 x i8] c";\00"
@.str.42493 = private unnamed_addr constant [5 x i8] c"%ret\00"
@.str.42496 = private unnamed_addr constant [20 x i8] c"  ret double %ret\0A\00"
@.str.42533 = private unnamed_addr constant [2 x i8] c";\00"
@.str.42541 = private unnamed_addr constant [28 x i8] c"  %ret = load double, ptr %\00"
@.str.42561 = private unnamed_addr constant [3 x i8] c"\0A\00"
@.str.42563 = private unnamed_addr constant [20 x i8] c"  ret double %ret\0A\00"
@.str.42587 = private unnamed_addr constant [5 x i8] c"%ret\00"
@.str.42590 = private unnamed_addr constant [20 x i8] c"  ret double %ret\0A\00"
@.str.42628 = private unnamed_addr constant [28 x i8] c"  ret double 0.000000e+00\0A\00"
@.str.42720 = private unnamed_addr constant [7 x i8] c"return\00"
@.str.42751 = private unnamed_addr constant [2 x i8] c";\00"
@.str.42769 = private unnamed_addr constant [5 x i8] c"%ret\00"
@.str.42772 = private unnamed_addr constant [17 x i8] c"  ret i64 %ret\0A\00"
@.str.42809 = private unnamed_addr constant [2 x i8] c";\00"
@.str.42817 = private unnamed_addr constant [25 x i8] c"  %ret = load i64, ptr %\00"
@.str.42837 = private unnamed_addr constant [3 x i8] c"\0A\00"
@.str.42839 = private unnamed_addr constant [17 x i8] c"  ret i64 %ret\0A\00"
@.str.42863 = private unnamed_addr constant [5 x i8] c"%ret\00"
@.str.42866 = private unnamed_addr constant [17 x i8] c"  ret i64 %ret\0A\00"
@.str.42904 = private unnamed_addr constant [14 x i8] c"  ret i64 0\0A\00"
@.str.43083 = private unnamed_addr constant [7 x i8] c"return\00"
@.str.43092 = private unnamed_addr constant [6 x i8] c"%ret.\00"
@.str.43123 = private unnamed_addr constant [2 x i8] c";\00"
@.str.43155 = private unnamed_addr constant [3 x i8] c"  \00"
@.str.43159 = private unnamed_addr constant [28 x i8] c" = getelementptr inbounds [\00"
@.str.43163 = private unnamed_addr constant [19 x i8] c" x i8], ptr @.str.\00"
@.str.43171 = private unnamed_addr constant [17 x i8] c", i32 0, i32 0\0A\00"
@.str.43173 = private unnamed_addr constant [11 x i8] c"  ret ptr \00"
@.str.43177 = private unnamed_addr constant [3 x i8] c"\0A\00"
@.str.43214 = private unnamed_addr constant [2 x i8] c"(\00"
@.str.43233 = private unnamed_addr constant [2 x i8] c"(\00"
@.str.43235 = private unnamed_addr constant [2 x i8] c")\00"
@.str.43264 = private unnamed_addr constant [11 x i8] c"  ret ptr \00"
@.str.43268 = private unnamed_addr constant [3 x i8] c"\0A\00"
@.str.43306 = private unnamed_addr constant [2 x i8] c";\00"
@.str.43314 = private unnamed_addr constant [3 x i8] c"  \00"
@.str.43318 = private unnamed_addr constant [19 x i8] c" = load ptr, ptr %\00"
@.str.43338 = private unnamed_addr constant [3 x i8] c"\0A\00"
@.str.43340 = private unnamed_addr constant [11 x i8] c"  ret ptr \00"
@.str.43344 = private unnamed_addr constant [3 x i8] c"\0A\00"
@.str.43385 = private unnamed_addr constant [11 x i8] c"  ret ptr \00"
@.str.43389 = private unnamed_addr constant [3 x i8] c"\0A\00"
@.str.43403 = private unnamed_addr constant [17 x i8] c"  ret ptr null\0A\00"
@.str.43420 = private unnamed_addr constant [6 x i8] c"value\00"
@.str.43427 = private unnamed_addr constant [9 x i8] c"variable\00"
@.str.43453 = private unnamed_addr constant [3 x i8] c"if\00"
@.str.43512 = private unnamed_addr constant [2 x i8] c"{\00"
@.str.43514 = private unnamed_addr constant [2 x i8] c"}\00"
@.str.43540 = private unnamed_addr constant [19 x i8] c"  ; malformed if\0A\00"
@.str.43551 = private unnamed_addr constant [1 x i8] c"\00"
@.str.43574 = private unnamed_addr constant [1 x i8] c"\00"
@.str.43581 = private unnamed_addr constant [20 x i8] c"  br label %if.end.\00"
@.str.43585 = private unnamed_addr constant [3 x i8] c"\0A\00"
@.str.43616 = private unnamed_addr constant [1 x i8] c"\00"
@.str.43640 = private unnamed_addr constant [1 x i8] c"\00"
@.str.43647 = private unnamed_addr constant [20 x i8] c"  br label %if.end.\00"
@.str.43651 = private unnamed_addr constant [3 x i8] c"\0A\00"
@.str.43669 = private unnamed_addr constant [5 x i8] c"else\00"
@.str.43699 = private unnamed_addr constant [2 x i8] c"{\00"
@.str.43716 = private unnamed_addr constant [2 x i8] c"{\00"
@.str.43718 = private unnamed_addr constant [2 x i8] c"}\00"
@.str.43757 = private unnamed_addr constant [1 x i8] c"\00"
@.str.43793 = private unnamed_addr constant [7 x i8] c"%cond.\00"
@.str.43798 = private unnamed_addr constant [15 x i8] c"  br i1 %cond.\00"
@.str.43802 = private unnamed_addr constant [18 x i8] c", label %if.then.\00"
@.str.43806 = private unnamed_addr constant [18 x i8] c", label %if.else.\00"
@.str.43810 = private unnamed_addr constant [3 x i8] c"\0A\00"
@.str.43812 = private unnamed_addr constant [9 x i8] c"if.then.\00"
@.str.43816 = private unnamed_addr constant [4 x i8] c":\0A\00"
@.str.43822 = private unnamed_addr constant [9 x i8] c"if.else.\00"
@.str.43826 = private unnamed_addr constant [4 x i8] c":\0A\00"
@.str.43832 = private unnamed_addr constant [8 x i8] c"if.end.\00"
@.str.43836 = private unnamed_addr constant [4 x i8] c":\0A\00"
@.str.43902 = private unnamed_addr constant [17 x i8] c"  ret ptr null\0A\00"
@.str.43994 = private unnamed_addr constant [7 x i8] c"return\00"
@.str.44002 = private unnamed_addr constant [13 x i8] c"  ret void\0A\00"
@.str.44040 = private unnamed_addr constant [13 x i8] c"  ret void\0A\00"
@.str.44154 = private unnamed_addr constant [7 x i8] c"@.str.\00"
@.str.44158 = private unnamed_addr constant [35 x i8] c" = private unnamed_addr constant [\00"
@.str.44162 = private unnamed_addr constant [11 x i8] c" x i8] c\22\00"
@.str.44169 = private unnamed_addr constant [5 x i8] c"\22\0A\00"
@.str.44193 = private unnamed_addr constant [3 x i8] c"\0A\00"
@.str.44243 = private unnamed_addr constant [5 x i8] c"main\00"
@.str.44249 = private unnamed_addr constant [15 x i8] c"csec_user_main\00"
@.str.44390 = private unnamed_addr constant [5 x i8] c"Char\00"
@.str.44412 = private unnamed_addr constant [12 x i8] c"define i8 @\00"
@.str.44416 = private unnamed_addr constant [15 x i8] c"() {\0Aentry:\0A\00"
@.str.44418 = private unnamed_addr constant [10 x i8] c"  ret i8 \00"
@.str.44430 = private unnamed_addr constant [8 x i8] c"\0A}\0A\0A\00"
@.str.44439 = private unnamed_addr constant [4 x i8] c"Int\00"
@.str.44461 = private unnamed_addr constant [13 x i8] c"define i32 @\00"
@.str.44465 = private unnamed_addr constant [15 x i8] c"() {\0Aentry:\0A\00"
@.str.44467 = private unnamed_addr constant [11 x i8] c"  ret i32 \00"
@.str.44476 = private unnamed_addr constant [8 x i8] c"\0A}\0A\0A\00"
@.str.44485 = private unnamed_addr constant [8 x i8] c"Boolean\00"
@.str.44507 = private unnamed_addr constant [12 x i8] c"define i1 @\00"
@.str.44511 = private unnamed_addr constant [15 x i8] c"() {\0Aentry:\0A\00"
@.str.44513 = private unnamed_addr constant [10 x i8] c"  ret i1 \00"
@.str.44522 = private unnamed_addr constant [8 x i8] c"\0A}\0A\0A\00"
@.str.44534 = private unnamed_addr constant [4 x i8] c"ptr\00"
@.str.44578 = private unnamed_addr constant [13 x i8] c"define ptr @\00"
@.str.44582 = private unnamed_addr constant [15 x i8] c"() {\0Aentry:\0A\00"
@.str.44584 = private unnamed_addr constant [34 x i8] c"  %ret = getelementptr inbounds [\00"
@.str.44588 = private unnamed_addr constant [19 x i8] c" x i8], ptr @.str.\00"
@.str.44592 = private unnamed_addr constant [17 x i8] c", i32 0, i32 0\0A\00"
@.str.44594 = private unnamed_addr constant [22 x i8] c"  ret ptr %ret\0A}\0A\0A\00"
@.str.44610 = private unnamed_addr constant [1 x i8] c"\00"
@.str.44622 = private unnamed_addr constant [4 x i8] c"ptr\00"
@.str.44702 = private unnamed_addr constant [6 x i8] c"value\00"
@.str.44714 = private unnamed_addr constant [9 x i8] c"variable\00"
@.str.44727 = private unnamed_addr constant [7 x i8] c"return\00"
@.str.44755 = private unnamed_addr constant [2 x i8] c";\00"
@.str.44794 = private unnamed_addr constant [7 x i8] c".addr.\00"
@.str.44799 = private unnamed_addr constant [13 x i8] c"define ptr @\00"
@.str.44803 = private unnamed_addr constant [2 x i8] c"(\00"
@.str.44812 = private unnamed_addr constant [6 x i8] c") {\0A\00"
@.str.44814 = private unnamed_addr constant [9 x i8] c"entry:\0A\00"
@.str.44832 = private unnamed_addr constant [25 x i8] c"  %ret = load ptr, ptr %\00"
@.str.44836 = private unnamed_addr constant [3 x i8] c"\0A\00"
@.str.44838 = private unnamed_addr constant [22 x i8] c"  ret ptr %ret\0A}\0A\0A\00"
@.str.44943 = private unnamed_addr constant [5 x i8] c"Char\00"
@.str.44950 = private unnamed_addr constant [7 x i8] c"Double\00"
@.str.44957 = private unnamed_addr constant [5 x i8] c"Long\00"
@.str.44971 = private unnamed_addr constant [6 x i8] c"value\00"
@.str.44983 = private unnamed_addr constant [9 x i8] c"variable\00"
@.str.45010 = private unnamed_addr constant [2 x i8] c"=\00"
@.str.45022 = private unnamed_addr constant [7 x i8] c"return\00"
@.str.45046 = private unnamed_addr constant [5 x i8] c"Char\00"
@.str.45051 = private unnamed_addr constant [12 x i8] c"define i8 @\00"
@.str.45055 = private unnamed_addr constant [15 x i8] c"() {\0Aentry:\0A\00"
@.str.45057 = private unnamed_addr constant [10 x i8] c"  ret i8 \00"
@.str.45071 = private unnamed_addr constant [8 x i8] c"\0A}\0A\0A\00"
@.str.45080 = private unnamed_addr constant [7 x i8] c"Double\00"
@.str.45085 = private unnamed_addr constant [16 x i8] c"define double @\00"
@.str.45089 = private unnamed_addr constant [15 x i8] c"() {\0Aentry:\0A\00"
@.str.45091 = private unnamed_addr constant [14 x i8] c"  ret double \00"
@.str.45102 = private unnamed_addr constant [8 x i8] c"\0A}\0A\0A\00"
@.str.45106 = private unnamed_addr constant [13 x i8] c"define i64 @\00"
@.str.45110 = private unnamed_addr constant [15 x i8] c"() {\0Aentry:\0A\00"
@.str.45112 = private unnamed_addr constant [11 x i8] c"  ret i64 \00"
@.str.45123 = private unnamed_addr constant [8 x i8] c"\0A}\0A\0A\00"
@.str.45132 = private unnamed_addr constant [4 x i8] c"Int\00"
@.str.45173 = private unnamed_addr constant [7 x i8] c"return\00"
@.str.45201 = private unnamed_addr constant [2 x i8] c"(\00"
@.str.45220 = private unnamed_addr constant [2 x i8] c"(\00"
@.str.45222 = private unnamed_addr constant [2 x i8] c")\00"
@.str.45239 = private unnamed_addr constant [6 x i8] c"%ret.\00"
@.str.45244 = private unnamed_addr constant [13 x i8] c"define i32 @\00"
@.str.45248 = private unnamed_addr constant [2 x i8] c"(\00"
@.str.45257 = private unnamed_addr constant [6 x i8] c") {\0A\00"
@.str.45259 = private unnamed_addr constant [9 x i8] c"entry:\0A\00"
@.str.45281 = private unnamed_addr constant [3 x i8] c"  \00"
@.str.45285 = private unnamed_addr constant [14 x i8] c" = call i32 @\00"
@.str.45299 = private unnamed_addr constant [2 x i8] c"(\00"
@.str.45314 = private unnamed_addr constant [4 x i8] c")\0A\00"
@.str.45316 = private unnamed_addr constant [11 x i8] c"  ret i32 \00"
@.str.45320 = private unnamed_addr constant [8 x i8] c"\0A}\0A\0A\00"
@.str.45339 = private unnamed_addr constant [13 x i8] c"define i32 @\00"
@.str.45343 = private unnamed_addr constant [2 x i8] c"(\00"
@.str.45352 = private unnamed_addr constant [6 x i8] c") {\0A\00"
@.str.45354 = private unnamed_addr constant [9 x i8] c"entry:\0A\00"
@.str.45365 = private unnamed_addr constant [6 x i8] c"}\0A\0A\00"
@.str.45374 = private unnamed_addr constant [8 x i8] c"Boolean\00"
@.str.45379 = private unnamed_addr constant [12 x i8] c"define i1 @\00"
@.str.45383 = private unnamed_addr constant [2 x i8] c"(\00"
@.str.45392 = private unnamed_addr constant [6 x i8] c") {\0A\00"
@.str.45394 = private unnamed_addr constant [9 x i8] c"entry:\0A\00"
@.str.45412 = private unnamed_addr constant [6 x i8] c"}\0A\0A\00"
@.str.45421 = private unnamed_addr constant [5 x i8] c"Char\00"
@.str.45426 = private unnamed_addr constant [12 x i8] c"define i8 @\00"
@.str.45430 = private unnamed_addr constant [2 x i8] c"(\00"
@.str.45439 = private unnamed_addr constant [6 x i8] c") {\0A\00"
@.str.45441 = private unnamed_addr constant [9 x i8] c"entry:\0A\00"
@.str.45459 = private unnamed_addr constant [6 x i8] c"}\0A\0A\00"
@.str.45468 = private unnamed_addr constant [7 x i8] c"Double\00"
@.str.45473 = private unnamed_addr constant [16 x i8] c"define double @\00"
@.str.45477 = private unnamed_addr constant [2 x i8] c"(\00"
@.str.45486 = private unnamed_addr constant [6 x i8] c") {\0A\00"
@.str.45488 = private unnamed_addr constant [9 x i8] c"entry:\0A\00"
@.str.45506 = private unnamed_addr constant [6 x i8] c"}\0A\0A\00"
@.str.45515 = private unnamed_addr constant [5 x i8] c"Long\00"
@.str.45520 = private unnamed_addr constant [13 x i8] c"define i64 @\00"
@.str.45524 = private unnamed_addr constant [2 x i8] c"(\00"
@.str.45533 = private unnamed_addr constant [6 x i8] c") {\0A\00"
@.str.45535 = private unnamed_addr constant [9 x i8] c"entry:\0A\00"
@.str.45553 = private unnamed_addr constant [6 x i8] c"}\0A\0A\00"
@.str.45562 = private unnamed_addr constant [5 x i8] c"Unit\00"
@.str.45567 = private unnamed_addr constant [14 x i8] c"define void @\00"
@.str.45571 = private unnamed_addr constant [2 x i8] c"(\00"
@.str.45580 = private unnamed_addr constant [6 x i8] c") {\0A\00"
@.str.45582 = private unnamed_addr constant [9 x i8] c"entry:\0A\00"
@.str.45600 = private unnamed_addr constant [6 x i8] c"}\0A\0A\00"
@.str.45612 = private unnamed_addr constant [4 x i8] c"ptr\00"
@.str.45617 = private unnamed_addr constant [13 x i8] c"define ptr @\00"
@.str.45621 = private unnamed_addr constant [2 x i8] c"(\00"
@.str.45630 = private unnamed_addr constant [6 x i8] c") {\0A\00"
@.str.45632 = private unnamed_addr constant [9 x i8] c"entry:\0A\00"
@.str.45650 = private unnamed_addr constant [6 x i8] c"}\0A\0A\00"
@.str.45654 = private unnamed_addr constant [1 x i8] c"\00"
@.str.45680 = private unnamed_addr constant [31 x i8] c"; ModuleID = 'csec.selfhost'\0A\00"
@.str.45692 = private unnamed_addr constant [40 x i8] c"source_filename = \22csec.selfhost\22\0A\0A\00"
@.str.45704 = private unnamed_addr constant [39 x i8] c"declare i64 @csec_string_length(ptr)\0A\00"
@.str.45716 = private unnamed_addr constant [46 x i8] c"declare i8 @csec_string_char_at(ptr, i32)\0A\0A\00"
@.str.45728 = private unnamed_addr constant [41 x i8] c"declare i32 @csec_lex_quoted(ptr, i32)\0A\00"
@.str.45740 = private unnamed_addr constant [41 x i8] c"declare i32 @csec_lex_number(ptr, i32)\0A\00"
@.str.45752 = private unnamed_addr constant [45 x i8] c"declare i32 @csec_lex_identifier(ptr, i32)\0A\00"
@.str.45764 = private unnamed_addr constant [47 x i8] c"declare i32 @csec_lex_line_comment(ptr, i32)\0A\00"
@.str.45776 = private unnamed_addr constant [48 x i8] c"declare i32 @csec_lex_block_comment(ptr, i32)\0A\00"
@.str.45788 = private unnamed_addr constant [36 x i8] c"declare i32 @csec_digit_value(i8)\0A\00"
@.str.45800 = private unnamed_addr constant [36 x i8] c"declare i32 @csec_is_keyword(ptr)\0A\00"
@.str.45812 = private unnamed_addr constant [32 x i8] c"declare i32 @csec_to_int(ptr)\0A\00"
@.str.45824 = private unnamed_addr constant [41 x i8] c"declare i32 @csec_line_start(ptr, i32)\0A\00"
@.str.45836 = private unnamed_addr constant [39 x i8] c"declare i32 @csec_line_end(ptr, i32)\0A\00"
@.str.45848 = private unnamed_addr constant [43 x i8] c"declare i32 @csec_validate_balanced(ptr)\0A\00"
@.str.45860 = private unnamed_addr constant [59 x i8] c"declare i32 @csec_starts_top_level_declaration(ptr, i32)\0A\00"
@.str.45872 = private unnamed_addr constant [44 x i8] c"declare i32 @csec_validate_top_level(ptr)\0A\00"
@.str.45884 = private unnamed_addr constant [50 x i8] c"declare ptr @csec_top_level_decl_kind(ptr, i32)\0A\00"
@.str.45896 = private unnamed_addr constant [50 x i8] c"declare ptr @csec_top_level_decl_name(ptr, i32)\0A\00"
@.str.45908 = private unnamed_addr constant [52 x i8] c"declare i32 @csec_count_function_params(ptr, i32)\0A\00"
@.str.45920 = private unnamed_addr constant [63 x i8] c"declare i32 @csec_token_is_top_level_operator(ptr, i32, i32)\0A\00"
@.str.45932 = private unnamed_addr constant [64 x i8] c"declare i32 @csec_find_top_level_operator(ptr, i32, i32, i32)\0A\00"
@.str.45944 = private unnamed_addr constant [56 x i8] c"declare i32 @csec_find_top_level_match(ptr, i32, i32)\0A\00"
@.str.45956 = private unnamed_addr constant [53 x i8] c"declare i32 @csec_find_lambda_arrow(ptr, i32, i32)\0A\00"
@.str.45968 = private unnamed_addr constant [47 x i8] c"declare ptr @csec_generate_symbol_table(ptr)\0A\00"
@.str.45980 = private unnamed_addr constant [59 x i8] c"declare ptr @csec_append_expression_until(ptr, i32, i32)\0A\00"
@.str.45992 = private unnamed_addr constant [59 x i8] c"declare ptr @csec_generate_expression_ast(ptr, i32, i32)\0A\00"
@.str.46004 = private unnamed_addr constant [58 x i8] c"declare ptr @csec_generate_statement_ast(ptr, i32, i32)\0A\00"
@.str.46016 = private unnamed_addr constant [53 x i8] c"declare ptr @csec_generate_body_ast(ptr, i32, i32)\0A\00"
@.str.46028 = private unnamed_addr constant [56 x i8] c"declare i32 @csec_find_function_param_start(ptr, i32)\0A\00"
@.str.46040 = private unnamed_addr constant [56 x i8] c"declare ptr @csec_generate_c_body(ptr, i32, i32, ptr)\0A\00"
@.str.46052 = private unnamed_addr constant [42 x i8] c"declare ptr @csec_ir_operator_name(ptr)\0A\00"
@.str.46064 = private unnamed_addr constant [65 x i8] c"declare i32 @csec_expression_top_level_operator(ptr, i32, i32)\0A\00"
@.str.46076 = private unnamed_addr constant [65 x i8] c"declare i32 @csec_find_token_text_in_range(ptr, i32, i32, ptr)\0A\00"
@.str.46088 = private unnamed_addr constant [64 x i8] c"declare i32 @csec_find_closing_token(ptr, i32, i32, ptr, ptr)\0A\00"
@.str.46100 = private unnamed_addr constant [62 x i8] c"declare i32 @csec_find_statement_paren_start(ptr, i32, i32)\0A\00"
@.str.46112 = private unnamed_addr constant [60 x i8] c"declare i32 @csec_find_statement_paren_end(ptr, i32, i32)\0A\00"
@.str.46124 = private unnamed_addr constant [62 x i8] c"declare i32 @csec_find_statement_block_start(ptr, i32, i32)\0A\00"
@.str.46136 = private unnamed_addr constant [60 x i8] c"declare i32 @csec_find_statement_block_end(ptr, i32, i32)\0A\00"
@.str.46148 = private unnamed_addr constant [57 x i8] c"declare i32 @csec_count_comma_separated(ptr, i32, i32)\0A\00"
@.str.46160 = private unnamed_addr constant [66 x i8] c"declare i32 @csec_find_last_top_level_token(ptr, i32, i32, ptr)\0A\00"
@.str.46172 = private unnamed_addr constant [54 x i8] c"declare ptr @csec_llvm_lexer_helper_definition(ptr)\0A\00"
@.str.46184 = private unnamed_addr constant [41 x i8] c"declare i64 @csec_string_builder_new()\0A\00"
@.str.46196 = private unnamed_addr constant [49 x i8] c"declare i64 @csec_string_builder_new_file(ptr)\0A\00"
@.str.46208 = private unnamed_addr constant [52 x i8] c"declare i32 @csec_string_builder_append(i64, ptr)\0A\00"
@.str.46220 = private unnamed_addr constant [47 x i8] c"declare ptr @csec_string_builder_finish(i64)\0A\00"
@.str.46232 = private unnamed_addr constant [59 x i8] c"declare i32 @csec_string_builder_write_to_file(i64, ptr)\0A\00"
@.str.46244 = private unnamed_addr constant [53 x i8] c"declare void @csec_set_command_line_args(i32, ptr)\0A\00"
@.str.46256 = private unnamed_addr constant [45 x i8] c"declare i32 @csec_command_line_arg_count()\0A\00"
@.str.46268 = private unnamed_addr constant [42 x i8] c"declare ptr @csec_command_line_arg(i32)\0A\00"
@.str.46280 = private unnamed_addr constant [44 x i8] c"declare ptr @csec_file_read_all_text(ptr)\0A\00"
@.str.46292 = private unnamed_addr constant [50 x i8] c"declare i32 @csec_file_write_all_text(ptr, ptr)\0A\00"
@.str.46304 = private unnamed_addr constant [39 x i8] c"declare void @csec_print_string(ptr)\0A\00"
@.str.46316 = private unnamed_addr constant [37 x i8] c"declare void @csec_print_newline()\0A\00"
@.str.46328 = private unnamed_addr constant [44 x i8] c"declare ptr @csec_string_concat(ptr, ptr)\0A\00"
@.str.46340 = private unnamed_addr constant [44 x i8] c"declare i32 @csec_string_equals(ptr, ptr)\0A\00"
@.str.46352 = private unnamed_addr constant [49 x i8] c"declare i32 @csec_string_starts_with(ptr, ptr)\0A\00"
@.str.46364 = private unnamed_addr constant [52 x i8] c"declare ptr @csec_string_substring(ptr, i32, i32)\0A\00"
@.str.46376 = private unnamed_addr constant [39 x i8] c"declare ptr @csec_to_string_i64(i64)\0A\00"
@.str.46388 = private unnamed_addr constant [39 x i8] c"declare ptr @csec_to_string_char(i8)\0A\00"
@.str.46400 = private unnamed_addr constant [53 x i8] c"declare ptr @csec_token_append_owned(ptr, i8, ptr)\0A\00"
@.str.46412 = private unnamed_addr constant [40 x i8] c"declare i64 @csec_token_builder_new()\0A\00"
@.str.46424 = private unnamed_addr constant [55 x i8] c"declare i32 @csec_token_builder_append(i64, i8, ptr)\0A\00"
@.str.46436 = private unnamed_addr constant [46 x i8] c"declare ptr @csec_token_builder_finish(i64)\0A\00"
@.str.46448 = private unnamed_addr constant [41 x i8] c"declare ptr @csec_tokenize_source(ptr)\0A\00"
@.str.46460 = private unnamed_addr constant [43 x i8] c"declare i8 @csec_token_kind_at(ptr, i32)\0A\00"
@.str.46472 = private unnamed_addr constant [44 x i8] c"declare ptr @csec_token_text_at(ptr, i32)\0A\00"
@.str.46484 = private unnamed_addr constant [48 x i8] c"declare i32 @csec_token_is(ptr, i32, i8, ptr)\0A\00"
@.str.46496 = private unnamed_addr constant [53 x i8] c"declare i32 @csec_advance_statement(ptr, i32, i32)\0A\00"
@.str.46508 = private unnamed_addr constant [53 x i8] c"declare i32 @csec_advance_top_level_decl(ptr, i32)\0A\00"
@.str.46520 = private unnamed_addr constant [51 x i8] c"declare i32 @csec_find_decl_body_start(ptr, i32)\0A\00"
@.str.46532 = private unnamed_addr constant [49 x i8] c"declare i32 @csec_find_decl_body_end(ptr, i32)\0A\00"
@.str.46544 = private unnamed_addr constant [49 x i8] c"declare i32 @csec_function_param_end(ptr, i32)\0A\00"
@.str.46556 = private unnamed_addr constant [55 x i8] c"declare ptr @csec_function_llvm_param_list(ptr, i32)\0A\00"
@.str.46568 = private unnamed_addr constant [58 x i8] c"declare ptr @csec_function_llvm_param_allocas(ptr, i32)\0A\00"
@.str.46580 = private unnamed_addr constant [52 x i8] c"declare ptr @csec_llvm_name_with_number(ptr, i32)\0A\00"
@.str.46592 = private unnamed_addr constant [51 x i8] c"declare ptr @csec_llvm_string_literal_bytes(ptr)\0A\00"
@.str.46604 = private unnamed_addr constant [54 x i8] c"declare ptr @csec_function_return_type_at(ptr, i32)\0A\00"
@.str.46616 = private unnamed_addr constant [60 x i8] c"declare i32 @csec_enclosing_function_decl_start(ptr, i32)\0A\00"
@.str.46628 = private unnamed_addr constant [60 x i8] c"declare i32 @csec_enclosing_function_body_start(ptr, i32)\0A\00"
@.str.46640 = private unnamed_addr constant [58 x i8] c"declare i32 @csec_enclosing_function_body_end(ptr, i32)\0A\00"
@.str.46652 = private unnamed_addr constant [58 x i8] c"declare ptr @csec_lookup_function_return_type(ptr, ptr)\0A\00"
@.str.46664 = private unnamed_addr constant [42 x i8] c"declare ptr @csec_expand_imports(ptr)\0A\0A\00"
@.str.46729 = private unnamed_addr constant [4 x i8] c"def\00"
@.str.46750 = private unnamed_addr constant [9 x i8] c"external\00"
@.str.46766 = private unnamed_addr constant [5 x i8] c"main\00"
@.str.46783 = private unnamed_addr constant [43 x i8] c"define i32 @main(i32 %argc, ptr %argv) {\0A\00"
@.str.46785 = private unnamed_addr constant [9 x i8] c"entry:\0A\00"
@.str.46787 = private unnamed_addr constant [64 x i8] c"  call void @csec_set_command_line_args(i32 %argc, ptr %argv)\0A\00"
@.str.46789 = private unnamed_addr constant [38 x i8] c"  %ret = call i32 @csec_user_main()\0A\00"
@.str.46791 = private unnamed_addr constant [17 x i8] c"  ret i32 %ret\0A\00"
@.str.46793 = private unnamed_addr constant [4 x i8] c"}\0A\00"
@.str.46886 = private unnamed_addr constant [23 x i8] c"define i32 @main() {\0A\00"
@.str.46893 = private unnamed_addr constant [4 x i8] c"}\0A\00"
@.str.46932 = private unnamed_addr constant [1 x i8] c"\00"
@.str.46940 = private unnamed_addr constant [31 x i8] c"; ModuleID = 'csec.selfhost'\0A\00"
@.str.46942 = private unnamed_addr constant [40 x i8] c"source_filename = \22csec.selfhost\22\0A\0A\00"
@.str.46944 = private unnamed_addr constant [39 x i8] c"declare i64 @csec_string_length(ptr)\0A\00"
@.str.46946 = private unnamed_addr constant [46 x i8] c"declare i8 @csec_string_char_at(ptr, i32)\0A\0A\00"
@.str.46948 = private unnamed_addr constant [41 x i8] c"declare i32 @csec_lex_quoted(ptr, i32)\0A\00"
@.str.46950 = private unnamed_addr constant [41 x i8] c"declare i32 @csec_lex_number(ptr, i32)\0A\00"
@.str.46952 = private unnamed_addr constant [45 x i8] c"declare i32 @csec_lex_identifier(ptr, i32)\0A\00"
@.str.46954 = private unnamed_addr constant [47 x i8] c"declare i32 @csec_lex_line_comment(ptr, i32)\0A\00"
@.str.46956 = private unnamed_addr constant [48 x i8] c"declare i32 @csec_lex_block_comment(ptr, i32)\0A\00"
@.str.46958 = private unnamed_addr constant [36 x i8] c"declare i32 @csec_digit_value(i8)\0A\00"
@.str.46960 = private unnamed_addr constant [36 x i8] c"declare i32 @csec_is_keyword(ptr)\0A\00"
@.str.46962 = private unnamed_addr constant [32 x i8] c"declare i32 @csec_to_int(ptr)\0A\00"
@.str.46964 = private unnamed_addr constant [41 x i8] c"declare i32 @csec_line_start(ptr, i32)\0A\00"
@.str.46966 = private unnamed_addr constant [39 x i8] c"declare i32 @csec_line_end(ptr, i32)\0A\00"
@.str.46968 = private unnamed_addr constant [43 x i8] c"declare i32 @csec_validate_balanced(ptr)\0A\00"
@.str.46970 = private unnamed_addr constant [59 x i8] c"declare i32 @csec_starts_top_level_declaration(ptr, i32)\0A\00"
@.str.46972 = private unnamed_addr constant [44 x i8] c"declare i32 @csec_validate_top_level(ptr)\0A\00"
@.str.46974 = private unnamed_addr constant [50 x i8] c"declare ptr @csec_top_level_decl_kind(ptr, i32)\0A\00"
@.str.46976 = private unnamed_addr constant [50 x i8] c"declare ptr @csec_top_level_decl_name(ptr, i32)\0A\00"
@.str.46978 = private unnamed_addr constant [52 x i8] c"declare i32 @csec_count_function_params(ptr, i32)\0A\00"
@.str.46980 = private unnamed_addr constant [63 x i8] c"declare i32 @csec_token_is_top_level_operator(ptr, i32, i32)\0A\00"
@.str.46982 = private unnamed_addr constant [64 x i8] c"declare i32 @csec_find_top_level_operator(ptr, i32, i32, i32)\0A\00"
@.str.46984 = private unnamed_addr constant [56 x i8] c"declare i32 @csec_find_top_level_match(ptr, i32, i32)\0A\00"
@.str.46986 = private unnamed_addr constant [53 x i8] c"declare i32 @csec_find_lambda_arrow(ptr, i32, i32)\0A\00"
@.str.46988 = private unnamed_addr constant [47 x i8] c"declare ptr @csec_generate_symbol_table(ptr)\0A\00"
@.str.46990 = private unnamed_addr constant [59 x i8] c"declare ptr @csec_append_expression_until(ptr, i32, i32)\0A\00"
@.str.46992 = private unnamed_addr constant [59 x i8] c"declare ptr @csec_generate_expression_ast(ptr, i32, i32)\0A\00"
@.str.46994 = private unnamed_addr constant [58 x i8] c"declare ptr @csec_generate_statement_ast(ptr, i32, i32)\0A\00"
@.str.46996 = private unnamed_addr constant [53 x i8] c"declare ptr @csec_generate_body_ast(ptr, i32, i32)\0A\00"
@.str.46998 = private unnamed_addr constant [56 x i8] c"declare i32 @csec_find_function_param_start(ptr, i32)\0A\00"
@.str.47000 = private unnamed_addr constant [56 x i8] c"declare ptr @csec_generate_c_body(ptr, i32, i32, ptr)\0A\00"
@.str.47002 = private unnamed_addr constant [42 x i8] c"declare ptr @csec_ir_operator_name(ptr)\0A\00"
@.str.47004 = private unnamed_addr constant [65 x i8] c"declare i32 @csec_expression_top_level_operator(ptr, i32, i32)\0A\00"
@.str.47006 = private unnamed_addr constant [65 x i8] c"declare i32 @csec_find_token_text_in_range(ptr, i32, i32, ptr)\0A\00"
@.str.47008 = private unnamed_addr constant [64 x i8] c"declare i32 @csec_find_closing_token(ptr, i32, i32, ptr, ptr)\0A\00"
@.str.47010 = private unnamed_addr constant [62 x i8] c"declare i32 @csec_find_statement_paren_start(ptr, i32, i32)\0A\00"
@.str.47012 = private unnamed_addr constant [60 x i8] c"declare i32 @csec_find_statement_paren_end(ptr, i32, i32)\0A\00"
@.str.47014 = private unnamed_addr constant [62 x i8] c"declare i32 @csec_find_statement_block_start(ptr, i32, i32)\0A\00"
@.str.47016 = private unnamed_addr constant [60 x i8] c"declare i32 @csec_find_statement_block_end(ptr, i32, i32)\0A\00"
@.str.47018 = private unnamed_addr constant [57 x i8] c"declare i32 @csec_count_comma_separated(ptr, i32, i32)\0A\00"
@.str.47020 = private unnamed_addr constant [66 x i8] c"declare i32 @csec_find_last_top_level_token(ptr, i32, i32, ptr)\0A\00"
@.str.47022 = private unnamed_addr constant [54 x i8] c"declare ptr @csec_llvm_lexer_helper_definition(ptr)\0A\00"
@.str.47024 = private unnamed_addr constant [41 x i8] c"declare i64 @csec_string_builder_new()\0A\00"
@.str.47026 = private unnamed_addr constant [49 x i8] c"declare i64 @csec_string_builder_new_file(ptr)\0A\00"
@.str.47028 = private unnamed_addr constant [52 x i8] c"declare i32 @csec_string_builder_append(i64, ptr)\0A\00"
@.str.47030 = private unnamed_addr constant [47 x i8] c"declare ptr @csec_string_builder_finish(i64)\0A\00"
@.str.47032 = private unnamed_addr constant [59 x i8] c"declare i32 @csec_string_builder_write_to_file(i64, ptr)\0A\00"
@.str.47034 = private unnamed_addr constant [53 x i8] c"declare void @csec_set_command_line_args(i32, ptr)\0A\00"
@.str.47036 = private unnamed_addr constant [45 x i8] c"declare i32 @csec_command_line_arg_count()\0A\00"
@.str.47038 = private unnamed_addr constant [42 x i8] c"declare ptr @csec_command_line_arg(i32)\0A\00"
@.str.47040 = private unnamed_addr constant [44 x i8] c"declare ptr @csec_file_read_all_text(ptr)\0A\00"
@.str.47042 = private unnamed_addr constant [50 x i8] c"declare i32 @csec_file_write_all_text(ptr, ptr)\0A\00"
@.str.47044 = private unnamed_addr constant [39 x i8] c"declare void @csec_print_string(ptr)\0A\00"
@.str.47046 = private unnamed_addr constant [37 x i8] c"declare void @csec_print_newline()\0A\00"
@.str.47048 = private unnamed_addr constant [44 x i8] c"declare ptr @csec_string_concat(ptr, ptr)\0A\00"
@.str.47050 = private unnamed_addr constant [44 x i8] c"declare i32 @csec_string_equals(ptr, ptr)\0A\00"
@.str.47052 = private unnamed_addr constant [49 x i8] c"declare i32 @csec_string_starts_with(ptr, ptr)\0A\00"
@.str.47054 = private unnamed_addr constant [52 x i8] c"declare ptr @csec_string_substring(ptr, i32, i32)\0A\00"
@.str.47056 = private unnamed_addr constant [39 x i8] c"declare ptr @csec_to_string_i64(i64)\0A\00"
@.str.47058 = private unnamed_addr constant [39 x i8] c"declare ptr @csec_to_string_char(i8)\0A\00"
@.str.47060 = private unnamed_addr constant [53 x i8] c"declare ptr @csec_token_append_owned(ptr, i8, ptr)\0A\00"
@.str.47062 = private unnamed_addr constant [40 x i8] c"declare i64 @csec_token_builder_new()\0A\00"
@.str.47064 = private unnamed_addr constant [55 x i8] c"declare i32 @csec_token_builder_append(i64, i8, ptr)\0A\00"
@.str.47066 = private unnamed_addr constant [46 x i8] c"declare ptr @csec_token_builder_finish(i64)\0A\00"
@.str.47068 = private unnamed_addr constant [41 x i8] c"declare ptr @csec_tokenize_source(ptr)\0A\00"
@.str.47070 = private unnamed_addr constant [43 x i8] c"declare i8 @csec_token_kind_at(ptr, i32)\0A\00"
@.str.47072 = private unnamed_addr constant [44 x i8] c"declare ptr @csec_token_text_at(ptr, i32)\0A\00"
@.str.47074 = private unnamed_addr constant [48 x i8] c"declare i32 @csec_token_is(ptr, i32, i8, ptr)\0A\00"
@.str.47076 = private unnamed_addr constant [53 x i8] c"declare i32 @csec_advance_statement(ptr, i32, i32)\0A\00"
@.str.47078 = private unnamed_addr constant [53 x i8] c"declare i32 @csec_advance_top_level_decl(ptr, i32)\0A\00"
@.str.47080 = private unnamed_addr constant [51 x i8] c"declare i32 @csec_find_decl_body_start(ptr, i32)\0A\00"
@.str.47082 = private unnamed_addr constant [49 x i8] c"declare i32 @csec_find_decl_body_end(ptr, i32)\0A\00"
@.str.47084 = private unnamed_addr constant [49 x i8] c"declare i32 @csec_function_param_end(ptr, i32)\0A\00"
@.str.47086 = private unnamed_addr constant [55 x i8] c"declare ptr @csec_function_llvm_param_list(ptr, i32)\0A\00"
@.str.47088 = private unnamed_addr constant [58 x i8] c"declare ptr @csec_function_llvm_param_allocas(ptr, i32)\0A\00"
@.str.47090 = private unnamed_addr constant [52 x i8] c"declare ptr @csec_llvm_name_with_number(ptr, i32)\0A\00"
@.str.47092 = private unnamed_addr constant [51 x i8] c"declare ptr @csec_llvm_string_literal_bytes(ptr)\0A\00"
@.str.47094 = private unnamed_addr constant [54 x i8] c"declare ptr @csec_function_return_type_at(ptr, i32)\0A\00"
@.str.47096 = private unnamed_addr constant [60 x i8] c"declare i32 @csec_enclosing_function_decl_start(ptr, i32)\0A\00"
@.str.47098 = private unnamed_addr constant [60 x i8] c"declare i32 @csec_enclosing_function_body_start(ptr, i32)\0A\00"
@.str.47100 = private unnamed_addr constant [58 x i8] c"declare i32 @csec_enclosing_function_body_end(ptr, i32)\0A\00"
@.str.47102 = private unnamed_addr constant [58 x i8] c"declare ptr @csec_lookup_function_return_type(ptr, ptr)\0A\00"
@.str.47104 = private unnamed_addr constant [42 x i8] c"declare ptr @csec_expand_imports(ptr)\0A\0A\00"
@.str.47158 = private unnamed_addr constant [4 x i8] c"def\00"
@.str.47173 = private unnamed_addr constant [5 x i8] c"main\00"
@.str.47267 = private unnamed_addr constant [43 x i8] c"define i32 @main(i32 %argc, ptr %argv) {\0A\00"
@.str.47269 = private unnamed_addr constant [9 x i8] c"entry:\0A\00"
@.str.47271 = private unnamed_addr constant [64 x i8] c"  call void @csec_set_command_line_args(i32 %argc, ptr %argv)\0A\00"
@.str.47273 = private unnamed_addr constant [38 x i8] c"  %ret = call i32 @csec_user_main()\0A\00"
@.str.47275 = private unnamed_addr constant [17 x i8] c"  ret i32 %ret\0A\00"
@.str.47277 = private unnamed_addr constant [4 x i8] c"}\0A\00"
@.str.47287 = private unnamed_addr constant [23 x i8] c"define i32 @main() {\0A\00"
@.str.47294 = private unnamed_addr constant [4 x i8] c"}\0A\00"
@.str.47317 = private unnamed_addr constant [1 x i8] c"\00"
@.str.47553 = private unnamed_addr constant [2 x i8] c".\00"
@.str.47578 = private unnamed_addr constant [1 x i8] c"\00"
@.str.47612 = private unnamed_addr constant [2 x i8] c"/\00"
@.str.47621 = private unnamed_addr constant [1 x i8] c"\00"
@.str.47663 = private unnamed_addr constant [3 x i8] c"//\00"
@.str.47671 = private unnamed_addr constant [7 x i8] c"import\00"
@.str.47676 = private unnamed_addr constant [1 x i8] c"\00"
@.str.47723 = private unnamed_addr constant [1 x i8] c"\00"
@.str.47883 = private unnamed_addr constant [6 x i8] c".csec\00"
@.str.47894 = private unnamed_addr constant [6 x i8] c".csec\00"
@.str.47938 = private unnamed_addr constant [2 x i8] c"/\00"
@.str.47998 = private unnamed_addr constant [2 x i8] c"/\00"
@.str.48043 = private unnamed_addr constant [2 x i8] c"|\00"
@.str.48047 = private unnamed_addr constant [2 x i8] c"|\00"
@.str.48060 = private unnamed_addr constant [1 x i8] c"\00"
@.str.48086 = private unnamed_addr constant [7 x i8] c"import\00"
@.str.48115 = private unnamed_addr constant [1 x i8] c"\00"
@.str.48230 = private unnamed_addr constant [3 x i8] c"\0A\00"
@.str.48254 = private unnamed_addr constant [3 x i8] c"\0A\00"
@.str.48280 = private unnamed_addr constant [3 x i8] c"\0A\00"
@.str.48338 = private unnamed_addr constant [9 x i8] c"tokenlen\00"
@.str.48343 = private unnamed_addr constant [8 x i8] c"tokens=\00"
@.str.48349 = private unnamed_addr constant [3 x i8] c"\0A\00"
@.str.48358 = private unnamed_addr constant [7 x i8] c"tokens\00"
@.str.48372 = private unnamed_addr constant [4 x i8] c"ast\00"
@.str.48389 = private unnamed_addr constant [8 x i8] c"symbols\00"
@.str.48406 = private unnamed_addr constant [3 x i8] c"ir\00"
@.str.48423 = private unnamed_addr constant [5 x i8] c"llvm\00"
@.str.48475 = private unnamed_addr constant [5 x i8] c"llvm\00"
@.str.48502 = private unnamed_addr constant [14 x i8] c"compile error\00"
@.str.48571 = private unnamed_addr constant [14 x i8] c"compile error\00"
@.str.48641 = private unnamed_addr constant [20 x i8] c"selfhost/input.csec\00"
@.str.48643 = private unnamed_addr constant [15 x i8] c"selfhost/out.c\00"
@.str.48645 = private unnamed_addr constant [2 x i8] c"c\00"

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

define i32 @operatorLength(ptr %arg.source, i32 %arg.index) {
entry:
  %source = alloca ptr
  store ptr %arg.source, ptr %source
  %index = alloca i32
  store i32 %arg.index, ptr %index
  ; malformed if
  ; malformed if
  ret i32 1
}

define ptr @repairLeadingRTokenText(ptr %arg.text) {
entry:
  %text = alloca ptr
  store ptr %arg.text, ptr %text
  %ret.1568 = load ptr, ptr %
  ret ptr %ret.1568
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

define ptr @statementKind(ptr %arg.tokens, i32 %arg.ordinal) {
entry:
  %tokens = alloca ptr
  store ptr %arg.tokens, ptr %tokens
  %ordinal = alloca i32
  store i32 %arg.ordinal, ptr %ordinal
  %ret.5050 = getelementptr inbounds [11 x i8], ptr @.str.0, i32 0, i32 0
  ret ptr %ret.5050
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

define ptr @expressionLeafKind(ptr %arg.tokens, i32 %arg.start, i32 %arg.end) {
entry:
  %tokens = alloca ptr
  store ptr %arg.tokens, ptr %tokens
  %start = alloca i32
  store i32 %arg.start, ptr %start
  %end = alloca i32
  store i32 %arg.end, ptr %end
  %ret.6576 = getelementptr inbounds [8 x i8], ptr @.str.0, i32 0, i32 0
  ret ptr %ret.6576
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

define ptr @statementHeaderExpression(ptr %arg.tokens, i32 %arg.start, i32 %arg.end) {
entry:
  %tokens = alloca ptr
  store ptr %arg.tokens, ptr %tokens
  %start = alloca i32
  store i32 %arg.start, ptr %start
  %end = alloca i32
  store i32 %arg.end, ptr %end
  %ret.7075 = getelementptr inbounds [1 x i8], ptr @.str.0, i32 0, i32 0
  ret ptr %ret.7075
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

define ptr @summarizePostfixExpression(ptr %arg.tokens, i32 %arg.start, i32 %arg.end) {
entry:
  %tokens = alloca ptr
  store ptr %arg.tokens, ptr %tokens
  %start = alloca i32
  store i32 %arg.start, ptr %start
  %end = alloca i32
  store i32 %arg.end, ptr %end
  %ret.7785 = getelementptr inbounds [1 x i8], ptr @.str.0, i32 0, i32 0
  ret ptr %ret.7785
}

define i32 @findLambdaArrow(ptr %arg.tokens, i32 %arg.start, i32 %arg.end) {
entry:
  %ret = call i32 @csec_find_lambda_arrow(ptr %arg.tokens, i32 %arg.start, i32 %arg.end)
  ret i32 %ret
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
  %tokens = alloca ptr
  store ptr %arg.tokens, ptr %tokens
  %start = alloca i32
  store i32 %arg.start, ptr %start
  %end = alloca i32
  store i32 %arg.end, ptr %end
  %ret.10713 = load ptr, ptr %
  ret ptr %ret.10713
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

define ptr @declaredValueType(ptr %arg.tokens, i32 %arg.declStart, i32 %arg.declEnd) {
entry:
  %tokens = alloca ptr
  store ptr %arg.tokens, ptr %tokens
  %declStart = alloca i32
  store i32 %arg.declStart, ptr %declStart
  %declEnd = alloca i32
  store i32 %arg.declEnd, ptr %declEnd
  %ret.11176 = getelementptr inbounds [6 x i8], ptr @.str.0, i32 0, i32 0
  ret ptr %ret.11176
}

define ptr @lookupFunctionReturnType(ptr %arg.tokens, ptr %arg.name) {
entry:
  %tokens = alloca ptr
  store ptr %arg.tokens, ptr %tokens
  %name = alloca ptr
  store ptr %arg.name, ptr %name
  %ret.11314 = getelementptr inbounds [8 x i8], ptr @.str.0, i32 0, i32 0
  ret ptr %ret.11314
}

define ptr @inferExpressionType(ptr %arg.tokens, i32 %arg.rawStart, i32 %arg.rawEnd) {
entry:
  %tokens = alloca ptr
  store ptr %arg.tokens, ptr %tokens
  %rawStart = alloca i32
  store i32 %arg.rawStart, ptr %rawStart
  %rawEnd = alloca i32
  store i32 %arg.rawEnd, ptr %rawEnd
  %ret.11943 = getelementptr inbounds [8 x i8], ptr @.str.0, i32 0, i32 0
  ret ptr %ret.11943
}

define ptr @declaredLocalType(ptr %arg.tokens, i32 %arg.start, i32 %arg.end) {
entry:
  %tokens = alloca ptr
  store ptr %arg.tokens, ptr %tokens
  %start = alloca i32
  store i32 %arg.start, ptr %start
  %end = alloca i32
  store i32 %arg.end, ptr %end
  %ret.12059 = getelementptr inbounds [1 x i8], ptr @.str.0, i32 0, i32 0
  ret ptr %ret.12059
}

define ptr @localDeclarationType(ptr %arg.tokens, i32 %arg.start, i32 %arg.end) {
entry:
  %tokens = alloca ptr
  store ptr %arg.tokens, ptr %tokens
  %start = alloca i32
  store i32 %arg.start, ptr %start
  %end = alloca i32
  store i32 %arg.end, ptr %end
  %ret.12144 = getelementptr inbounds [8 x i8], ptr @.str.0, i32 0, i32 0
  ret ptr %ret.12144
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
  %ret.12466 = load ptr, ptr %
  ret ptr %ret.12466
}

define ptr @generateFunctionParamSymbols(ptr %arg.tokens, ptr %arg.functionName, i32 %arg.declStart) {
entry:
  %tokens = alloca ptr
  store ptr %arg.tokens, ptr %tokens
  %functionName = alloca ptr
  store ptr %arg.functionName, ptr %functionName
  %declStart = alloca i32
  store i32 %arg.declStart, ptr %declStart
  %ret.12697 = load ptr, ptr %
  ret ptr %ret.12697
}

define i32 @classMemberStart(ptr %arg.tokens, i32 %arg.ordinal) {
entry:
  %tokens = alloca ptr
  store ptr %arg.tokens, ptr %tokens
  %ordinal = alloca i32
  store i32 %arg.ordinal, ptr %ordinal
  ; malformed if
  unknown = load ptr, ptr %ordinal
  ret i32 %ordinal.ret
}

define ptr @classMemberKind(ptr %arg.tokens, i32 %arg.ordinal) {
entry:
  %tokens = alloca ptr
  store ptr %arg.tokens, ptr %tokens
  %ordinal = alloca i32
  store i32 %arg.ordinal, ptr %ordinal
  %ret.12853 = getelementptr inbounds [7 x i8], ptr @.str.0, i32 0, i32 0
  ret ptr %ret.12853
}

define ptr @classMemberName(ptr %arg.tokens, i32 %arg.ordinal) {
entry:
  %tokens = alloca ptr
  store ptr %arg.tokens, ptr %tokens
  %ordinal = alloca i32
  store i32 %arg.ordinal, ptr %ordinal
  %ret.12981 = getelementptr inbounds [9 x i8], ptr @.str.0, i32 0, i32 0
  ret ptr %ret.12981
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
  %ret.13199 = load ptr, ptr %
  ret ptr %ret.13199
}

define ptr @generateClassMemberAST(ptr %arg.tokens, i32 %arg.bodyStart, i32 %arg.bodyEnd) {
entry:
  %tokens = alloca ptr
  store ptr %arg.tokens, ptr %tokens
  %bodyStart = alloca i32
  store i32 %arg.bodyStart, ptr %bodyStart
  %bodyEnd = alloca i32
  store i32 %arg.bodyEnd, ptr %bodyEnd
  %ret.13310 = load ptr, ptr %
  ret ptr %ret.13310
}

define ptr @templateParameterSummary(ptr %arg.tokens, i32 %arg.ordinal) {
entry:
  %tokens = alloca ptr
  store ptr %arg.tokens, ptr %tokens
  %ordinal = alloca i32
  store i32 %arg.ordinal, ptr %ordinal
  %ret.13521 = load ptr, ptr %
  ret ptr %ret.13521
}

define ptr @templateTargetKind(ptr %arg.tokens, i32 %arg.ordinal) {
entry:
  %tokens = alloca ptr
  store ptr %arg.tokens, ptr %tokens
  %ordinal = alloca i32
  store i32 %arg.ordinal, ptr %ordinal
  %ret.13697 = getelementptr inbounds [1 x i8], ptr @.str.0, i32 0, i32 0
  ret ptr %ret.13697
}

define ptr @attributeSummary(ptr %arg.tokens, i32 %arg.ordinal) {
entry:
  %tokens = alloca ptr
  store ptr %arg.tokens, ptr %tokens
  %ordinal = alloca i32
  store i32 %arg.ordinal, ptr %ordinal
  %ret.13814 = load ptr, ptr %
  ret ptr %ret.13814
}

define ptr @externalSymbolKind(ptr %arg.tokens, i32 %arg.ordinal) {
entry:
  %tokens = alloca ptr
  store ptr %arg.tokens, ptr %tokens
  %ordinal = alloca i32
  store i32 %arg.ordinal, ptr %ordinal
  %ret.13886 = load ptr, ptr %
  ret ptr %ret.13886
}

define ptr @generateSymbolTable(ptr %arg.tokens) {
entry:
  %ret = call ptr @csec_generate_symbol_table(ptr %arg.tokens)
  ret ptr %ret
}

define ptr @generateAST(ptr %arg.tokens) {
entry:
  %tokens = alloca ptr
  store ptr %arg.tokens, ptr %tokens
  %ret.14827 = load ptr, ptr %
  ret ptr %ret.14827
}

define i32 @parseReturnIntegerInRange(ptr %arg.tokens, i32 %arg.start, i32 %arg.end) {
entry:
  %tokens = alloca ptr
  store ptr %arg.tokens, ptr %tokens
  %start = alloca i32
  store i32 %arg.start, ptr %start
  %end = alloca i32
  store i32 %arg.end, ptr %end
  %cursor.addr.14965 = alloca i32
  %cursor.init.14965 = load i32, ptr %start
  store i32 %cursor.init.14965, ptr %cursor.addr.14965
  ; malformed while
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
  %ret.15238 = load ptr, ptr %
  ret ptr %ret.15238
}

define ptr @cTypeName(ptr %arg.typeName) {
entry:
  %typeName = alloca ptr
  store ptr %arg.typeName, ptr %typeName
  %ret.15392 = getelementptr inbounds [6 x i8], ptr @.str.0, i32 0, i32 0
  ret ptr %ret.15392
}

define ptr @generateCBody(ptr %arg.tokens, i32 %arg.bodyStart, i32 %arg.bodyEnd, ptr %arg.indent) {
entry:
  %ret = call ptr @csec_generate_c_body(ptr %arg.tokens, i32 %arg.bodyStart, i32 %arg.bodyEnd, ptr %arg.indent)
  ret ptr %ret
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
  %ret.16700.left.left = load ptr, ptr %indent
  %ret.16700.left = call ptr @csec_string_concat(ptr %ret.16700.left.left, ptr %ret.16700.left.right)
  %ret.16700.right = getelementptr inbounds [3 x i8], ptr @.str.16712, i32 0, i32 0
  %ret.16700 = call ptr @csec_string_concat(ptr %ret.16700.left, ptr %ret.16700.right)
  ret ptr %ret.16700
}

define i32 @parseMainReturnInt(ptr %arg.tokens) {
entry:
  %tokens = alloca ptr
  store ptr %arg.tokens, ptr %tokens
  %cursor.addr.16725 = alloca i32
  %cursor.init.16725 = add i32 0, 0
  store i32 %cursor.init.16725, ptr %cursor.addr.16725
  ; malformed while
  ret i32 0
}

define ptr @generateMainExecutionC(ptr %arg.tokens) {
entry:
  %tokens = alloca ptr
  store ptr %arg.tokens, ptr %tokens
  %ret.17109 = getelementptr inbounds [1 x i8], ptr @.str.0, i32 0, i32 0
  ret ptr %ret.17109
}

define ptr @irTypeName(ptr %arg.typeName) {
entry:
  %typeName = alloca ptr
  store ptr %arg.typeName, ptr %typeName
  %ret.17290 = getelementptr inbounds [4 x i8], ptr @.str.0, i32 0, i32 0
  ret ptr %ret.17290
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
  %tokens = alloca ptr
  store ptr %arg.tokens, ptr %tokens
  %declStart = alloca i32
  store i32 %arg.declStart, ptr %declStart
  %ret.18731 = load ptr, ptr %
  ret ptr %ret.18731
}

define ptr @generateIRFlatBody(ptr %arg.tokens, i32 %arg.bodyStart, i32 %arg.bodyEnd) {
entry:
  %tokens = alloca ptr
  store ptr %arg.tokens, ptr %tokens
  %bodyStart = alloca i32
  store i32 %arg.bodyStart, ptr %bodyStart
  %bodyEnd = alloca i32
  store i32 %arg.bodyEnd, ptr %bodyEnd
  %ret.19124 = load ptr, ptr %
  ret ptr %ret.19124
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

