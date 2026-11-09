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
declare ptr @csec_generate_c_expression(ptr, i32, i32)
declare ptr @csec_ir_operator_name(ptr)
declare ptr @csec_ir_type_name(ptr)
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
declare i32 @csec_llvm_string_literal_byte_length(ptr)
declare ptr @csec_function_return_type_at(ptr, i32)
declare ptr @csec_collect_type_name(ptr, i32, i32)
declare i32 @csec_enclosing_function_decl_start(ptr, i32)
declare i32 @csec_enclosing_function_body_start(ptr, i32)
declare i32 @csec_enclosing_function_body_end(ptr, i32)
declare ptr @csec_lookup_function_return_type(ptr, ptr)
declare ptr @csec_lookup_visible_value_type(ptr, i32, ptr)
declare ptr @csec_lookup_visible_storage_name(ptr, i32, ptr)
declare ptr @csec_expand_imports(ptr)

@.str.332 = private unnamed_addr constant [2 x i8] c"\0D\00"
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
@.str.10032 = private unnamed_addr constant [2 x i8] c"\0A\00"
@.str.10041 = private unnamed_addr constant [6 x i8] c"value\00"
@.str.10048 = private unnamed_addr constant [9 x i8] c"variable\00"
@.str.10076 = private unnamed_addr constant [8 x i8] c"  Stmt \00"
@.str.10080 = private unnamed_addr constant [2 x i8] c" \00"
@.str.10091 = private unnamed_addr constant [4 x i8] c" = \00"
@.str.10104 = private unnamed_addr constant [2 x i8] c"\0A\00"
@.str.10108 = private unnamed_addr constant [8 x i8] c"  Stmt \00"
@.str.10112 = private unnamed_addr constant [2 x i8] c" \00"
@.str.10123 = private unnamed_addr constant [2 x i8] c"\0A\00"
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
@.str.10201 = private unnamed_addr constant [3 x i8] c")\0A\00"
@.str.10210 = private unnamed_addr constant [7 x i8] c"unsafe\00"
@.str.10217 = private unnamed_addr constant [9 x i8] c"unatomic\00"
@.str.10224 = private unnamed_addr constant [10 x i8] c"constexpr\00"
@.str.10229 = private unnamed_addr constant [8 x i8] c"  Stmt \00"
@.str.10233 = private unnamed_addr constant [2 x i8] c"\0A\00"
@.str.10242 = private unnamed_addr constant [9 x i8] c"function\00"
@.str.10249 = private unnamed_addr constant [7 x i8] c"object\00"
@.str.10254 = private unnamed_addr constant [8 x i8] c"  Stmt \00"
@.str.10258 = private unnamed_addr constant [2 x i8] c" \00"
@.str.10269 = private unnamed_addr constant [2 x i8] c"\0A\00"
@.str.10273 = private unnamed_addr constant [19 x i8] c"  Stmt expression \00"
@.str.10284 = private unnamed_addr constant [2 x i8] c"\0A\00"
@.str.10310 = private unnamed_addr constant [1 x i8] c"\00"
@.str.10370 = private unnamed_addr constant [14 x i8] c"  Stmt error\0A\00"
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
@.str.12288 = private unnamed_addr constant [2 x i8] c"\0A\00"
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
@.str.12374 = private unnamed_addr constant [2 x i8] c"\0A\00"
@.str.12417 = private unnamed_addr constant [10 x i8] c"  Assign \00"
@.str.12421 = private unnamed_addr constant [2 x i8] c".\00"
@.str.12430 = private unnamed_addr constant [5 x i8] c" op=\00"
@.str.12439 = private unnamed_addr constant [7 x i8] c" type=\00"
@.str.12452 = private unnamed_addr constant [2 x i8] c"\0A\00"
@.str.12508 = private unnamed_addr constant [1 x i8] c"\00"
@.str.12529 = private unnamed_addr constant [2 x i8] c"(\00"
@.str.12531 = private unnamed_addr constant [2 x i8] c")\00"
@.str.12548 = private unnamed_addr constant [1 x i8] c"\00"
@.str.12587 = private unnamed_addr constant [8 x i8] c"unknown\00"
@.str.12603 = private unnamed_addr constant [2 x i8] c":\00"
@.str.12625 = private unnamed_addr constant [9 x i8] c"  Param \00"
@.str.12629 = private unnamed_addr constant [2 x i8] c".\00"
@.str.12638 = private unnamed_addr constant [7 x i8] c" type=\00"
@.str.12642 = private unnamed_addr constant [2 x i8] c"\0A\00"
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
@.str.13138 = private unnamed_addr constant [2 x i8] c"\0A\00"
@.str.13148 = private unnamed_addr constant [6 x i8] c"field\00"
@.str.13155 = private unnamed_addr constant [14 x i8] c"mutable-field\00"
@.str.13163 = private unnamed_addr constant [9 x i8] c"  Field \00"
@.str.13167 = private unnamed_addr constant [2 x i8] c".\00"
@.str.13171 = private unnamed_addr constant [6 x i8] c" mut=\00"
@.str.13175 = private unnamed_addr constant [7 x i8] c" type=\00"
@.str.13186 = private unnamed_addr constant [2 x i8] c"\0A\00"
@.str.13226 = private unnamed_addr constant [1 x i8] c"\00"
@.str.13280 = private unnamed_addr constant [10 x i8] c"  Member \00"
@.str.13289 = private unnamed_addr constant [2 x i8] c" \00"
@.str.13298 = private unnamed_addr constant [2 x i8] c"\0A\00"
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
@.str.13910 = private unnamed_addr constant [21 x i8] c"error: parse failed\0A\00"
@.str.13918 = private unnamed_addr constant [9 x i8] c"Symbols\0A\00"
@.str.13988 = private unnamed_addr constant [9 x i8] c"function\00"
@.str.13995 = private unnamed_addr constant [18 x i8] c"external-function\00"
@.str.14003 = private unnamed_addr constant [17 x i8] c"Symbol function \00"
@.str.14007 = private unnamed_addr constant [9 x i8] c" params=\00"
@.str.14016 = private unnamed_addr constant [10 x i8] c" returns=\00"
@.str.14025 = private unnamed_addr constant [2 x i8] c"\0A\00"
@.str.14033 = private unnamed_addr constant [18 x i8] c"external-function\00"
@.str.14041 = private unnamed_addr constant [21 x i8] c"  External function \00"
@.str.14045 = private unnamed_addr constant [2 x i8] c"\0A\00"
@.str.14120 = private unnamed_addr constant [6 x i8] c"value\00"
@.str.14127 = private unnamed_addr constant [9 x i8] c"variable\00"
@.str.14135 = private unnamed_addr constant [8 x i8] c"Symbol \00"
@.str.14139 = private unnamed_addr constant [2 x i8] c" \00"
@.str.14143 = private unnamed_addr constant [7 x i8] c" type=\00"
@.str.14154 = private unnamed_addr constant [2 x i8] c"\0A\00"
@.str.14164 = private unnamed_addr constant [9 x i8] c"template\00"
@.str.14172 = private unnamed_addr constant [17 x i8] c"Symbol template \00"
@.str.14176 = private unnamed_addr constant [9 x i8] c" target=\00"
@.str.14185 = private unnamed_addr constant [9 x i8] c" params=\00"
@.str.14194 = private unnamed_addr constant [2 x i8] c"\0A\00"
@.str.14204 = private unnamed_addr constant [10 x i8] c"attribute\00"
@.str.14212 = private unnamed_addr constant [18 x i8] c"Symbol attribute \00"
@.str.14221 = private unnamed_addr constant [2 x i8] c"\0A\00"
@.str.14231 = private unnamed_addr constant [9 x i8] c"external\00"
@.str.14238 = private unnamed_addr constant [18 x i8] c"external-function\00"
@.str.14245 = private unnamed_addr constant [15 x i8] c"external-class\00"
@.str.14252 = private unnamed_addr constant [16 x i8] c"external-object\00"
@.str.14260 = private unnamed_addr constant [17 x i8] c"Symbol external \00"
@.str.14269 = private unnamed_addr constant [2 x i8] c" \00"
@.str.14273 = private unnamed_addr constant [2 x i8] c"\0A\00"
@.str.14283 = private unnamed_addr constant [6 x i8] c"class\00"
@.str.14290 = private unnamed_addr constant [7 x i8] c"object\00"
@.str.14297 = private unnamed_addr constant [15 x i8] c"external-class\00"
@.str.14304 = private unnamed_addr constant [16 x i8] c"external-object\00"
@.str.14312 = private unnamed_addr constant [13 x i8] c"Symbol type \00"
@.str.14316 = private unnamed_addr constant [7 x i8] c" kind=\00"
@.str.14320 = private unnamed_addr constant [2 x i8] c"\0A\00"
@.str.14328 = private unnamed_addr constant [15 x i8] c"external-class\00"
@.str.14335 = private unnamed_addr constant [16 x i8] c"external-object\00"
@.str.14343 = private unnamed_addr constant [12 x i8] c"  External \00"
@.str.14352 = private unnamed_addr constant [2 x i8] c" \00"
@.str.14356 = private unnamed_addr constant [2 x i8] c"\0A\00"
@.str.14418 = private unnamed_addr constant [7 x i8] c"import\00"
@.str.14426 = private unnamed_addr constant [15 x i8] c"Symbol import \00"
@.str.14430 = private unnamed_addr constant [2 x i8] c"\0A\00"
@.str.14467 = private unnamed_addr constant [21 x i8] c"error: parse failed\0A\00"
@.str.14475 = private unnamed_addr constant [9 x i8] c"Program\0A\00"
@.str.14531 = private unnamed_addr constant [6 x i8] c"Decl \00"
@.str.14535 = private unnamed_addr constant [2 x i8] c" \00"
@.str.14539 = private unnamed_addr constant [2 x i8] c"\0A\00"
@.str.14547 = private unnamed_addr constant [10 x i8] c"attribute\00"
@.str.14555 = private unnamed_addr constant [11 x i8] c"Attribute \00"
@.str.14564 = private unnamed_addr constant [2 x i8] c"\0A\00"
@.str.14573 = private unnamed_addr constant [9 x i8] c"template\00"
@.str.14581 = private unnamed_addr constant [17 x i8] c"Template target \00"
@.str.14590 = private unnamed_addr constant [8 x i8] c" params\00"
@.str.14599 = private unnamed_addr constant [2 x i8] c"\0A\00"
@.str.14608 = private unnamed_addr constant [9 x i8] c"function\00"
@.str.14615 = private unnamed_addr constant [18 x i8] c"external-function\00"
@.str.14622 = private unnamed_addr constant [9 x i8] c"template\00"
@.str.14674 = private unnamed_addr constant [15 x i8] c"  Body tokens=\00"
@.str.14682 = private unnamed_addr constant [2 x i8] c"\0A\00"
@.str.14710 = private unnamed_addr constant [6 x i8] c"class\00"
@.str.14717 = private unnamed_addr constant [7 x i8] c"object\00"
@.str.14724 = private unnamed_addr constant [15 x i8] c"external-class\00"
@.str.14731 = private unnamed_addr constant [16 x i8] c"external-object\00"
@.str.14783 = private unnamed_addr constant [15 x i8] c"  Body tokens=\00"
@.str.14791 = private unnamed_addr constant [2 x i8] c"\0A\00"
@.str.15013 = private unnamed_addr constant [7 x i8] c"return\00"
@.str.15099 = private unnamed_addr constant [1 x i8] c"\00"
@.str.15148 = private unnamed_addr constant [4 x i8] c"and\00"
@.str.15156 = private unnamed_addr constant [3 x i8] c"&&\00"
@.str.15177 = private unnamed_addr constant [3 x i8] c"or\00"
@.str.15185 = private unnamed_addr constant [3 x i8] c"||\00"
@.str.15206 = private unnamed_addr constant [4 x i8] c"xor\00"
@.str.15214 = private unnamed_addr constant [2 x i8] c"^\00"
@.str.15239 = private unnamed_addr constant [2 x i8] c" \00"
@.str.15269 = private unnamed_addr constant [8 x i8] c"Boolean\00"
@.str.15274 = private unnamed_addr constant [4 x i8] c"int\00"
@.str.15283 = private unnamed_addr constant [5 x i8] c"Char\00"
@.str.15288 = private unnamed_addr constant [5 x i8] c"char\00"
@.str.15297 = private unnamed_addr constant [4 x i8] c"Int\00"
@.str.15302 = private unnamed_addr constant [4 x i8] c"int\00"
@.str.15311 = private unnamed_addr constant [5 x i8] c"Long\00"
@.str.15316 = private unnamed_addr constant [10 x i8] c"long long\00"
@.str.15325 = private unnamed_addr constant [6 x i8] c"Float\00"
@.str.15330 = private unnamed_addr constant [6 x i8] c"float\00"
@.str.15339 = private unnamed_addr constant [7 x i8] c"Double\00"
@.str.15344 = private unnamed_addr constant [7 x i8] c"double\00"
@.str.15353 = private unnamed_addr constant [7 x i8] c"String\00"
@.str.15358 = private unnamed_addr constant [12 x i8] c"const char*\00"
@.str.15367 = private unnamed_addr constant [6 x i8] c"Regex\00"
@.str.15372 = private unnamed_addr constant [12 x i8] c"const char*\00"
@.str.15381 = private unnamed_addr constant [6 x i8] c"Array\00"
@.str.15386 = private unnamed_addr constant [6 x i8] c"void*\00"
@.str.15395 = private unnamed_addr constant [5 x i8] c"Unit\00"
@.str.15400 = private unnamed_addr constant [5 x i8] c"void\00"
@.str.15404 = private unnamed_addr constant [6 x i8] c"void*\00"
@.str.15434 = private unnamed_addr constant [1 x i8] c"\00"
@.str.15502 = private unnamed_addr constant [7 x i8] c"return\00"
@.str.15512 = private unnamed_addr constant [8 x i8] c"return \00"
@.str.15525 = private unnamed_addr constant [3 x i8] c";\0A\00"
@.str.15535 = private unnamed_addr constant [6 x i8] c"value\00"
@.str.15542 = private unnamed_addr constant [9 x i8] c"variable\00"
@.str.15617 = private unnamed_addr constant [2 x i8] c" \00"
@.str.15628 = private unnamed_addr constant [4 x i8] c" = \00"
@.str.15641 = private unnamed_addr constant [3 x i8] c";\0A\00"
@.str.15657 = private unnamed_addr constant [4 x i8] c"Int\00"
@.str.15671 = private unnamed_addr constant [2 x i8] c" \00"
@.str.15682 = private unnamed_addr constant [7 x i8] c" = 0;\0A\00"
@.str.15693 = private unnamed_addr constant [3 x i8] c"if\00"
@.str.15700 = private unnamed_addr constant [6 x i8] c"while\00"
@.str.15717 = private unnamed_addr constant [2 x i8] c"(\00"
@.str.15733 = private unnamed_addr constant [2 x i8] c"(\00"
@.str.15735 = private unnamed_addr constant [2 x i8] c")\00"
@.str.15753 = private unnamed_addr constant [2 x i8] c"{\00"
@.str.15769 = private unnamed_addr constant [2 x i8] c"{\00"
@.str.15771 = private unnamed_addr constant [2 x i8] c"}\00"
@.str.15801 = private unnamed_addr constant [3 x i8] c" (\00"
@.str.15814 = private unnamed_addr constant [5 x i8] c") {\0A\00"
@.str.15828 = private unnamed_addr constant [5 x i8] c"    \00"
@.str.15833 = private unnamed_addr constant [3 x i8] c"}\0A\00"
@.str.15841 = private unnamed_addr constant [3 x i8] c"if\00"
@.str.15875 = private unnamed_addr constant [5 x i8] c"else\00"
@.str.15905 = private unnamed_addr constant [2 x i8] c"{\00"
@.str.15922 = private unnamed_addr constant [2 x i8] c"{\00"
@.str.15924 = private unnamed_addr constant [2 x i8] c"}\00"
@.str.15940 = private unnamed_addr constant [8 x i8] c"else {\0A\00"
@.str.15954 = private unnamed_addr constant [5 x i8] c"    \00"
@.str.15959 = private unnamed_addr constant [3 x i8] c"}\0A\00"
@.str.15974 = private unnamed_addr constant [4 x i8] c"for\00"
@.str.16049 = private unnamed_addr constant [3 x i8] c"<-\00"
@.str.16115 = private unnamed_addr constant [4 x i8] c" < \00"
@.str.16128 = private unnamed_addr constant [3 x i8] c"to\00"
@.str.16140 = private unnamed_addr constant [3 x i8] c"..\00"
@.str.16146 = private unnamed_addr constant [5 x i8] c" <= \00"
@.str.16169 = private unnamed_addr constant [10 x i8] c"for (int \00"
@.str.16173 = private unnamed_addr constant [4 x i8] c" = \00"
@.str.16186 = private unnamed_addr constant [3 x i8] c"; \00"
@.str.16203 = private unnamed_addr constant [3 x i8] c"; \00"
@.str.16207 = private unnamed_addr constant [7 x i8] c"++) {\0A\00"
@.str.16221 = private unnamed_addr constant [5 x i8] c"    \00"
@.str.16226 = private unnamed_addr constant [3 x i8] c"}\0A\00"
@.str.16237 = private unnamed_addr constant [9 x i8] c"/* for (\00"
@.str.16248 = private unnamed_addr constant [6 x i8] c") */\0A\00"
@.str.16288 = private unnamed_addr constant [4 x i8] c"map\00"
@.str.16295 = private unnamed_addr constant [5 x i8] c"pmap\00"
@.str.16302 = private unnamed_addr constant [7 x i8] c"reduce\00"
@.str.16309 = private unnamed_addr constant [8 x i8] c"preduce\00"
@.str.16316 = private unnamed_addr constant [7 x i8] c"filter\00"
@.str.16354 = private unnamed_addr constant [4 x i8] c"/* \00"
@.str.16358 = private unnamed_addr constant [3 x i8] c" (\00"
@.str.16369 = private unnamed_addr constant [6 x i8] c") */\0A\00"
@.str.16418 = private unnamed_addr constant [3 x i8] c";\0A\00"
@.str.16475 = private unnamed_addr constant [7 x i8] c"return\00"
@.str.16482 = private unnamed_addr constant [8 x i8] c"return \00"
@.str.16495 = private unnamed_addr constant [3 x i8] c";\0A\00"
@.str.16504 = private unnamed_addr constant [6 x i8] c"value\00"
@.str.16511 = private unnamed_addr constant [9 x i8] c"variable\00"
@.str.16583 = private unnamed_addr constant [2 x i8] c" \00"
@.str.16594 = private unnamed_addr constant [4 x i8] c" = \00"
@.str.16607 = private unnamed_addr constant [3 x i8] c";\0A\00"
@.str.16621 = private unnamed_addr constant [4 x i8] c"Int\00"
@.str.16632 = private unnamed_addr constant [2 x i8] c" \00"
@.str.16643 = private unnamed_addr constant [7 x i8] c" = 0;\0A\00"
@.str.16652 = private unnamed_addr constant [3 x i8] c"if\00"
@.str.16659 = private unnamed_addr constant [6 x i8] c"while\00"
@.str.16666 = private unnamed_addr constant [4 x i8] c"for\00"
@.str.16673 = private unnamed_addr constant [4 x i8] c"map\00"
@.str.16680 = private unnamed_addr constant [5 x i8] c"pmap\00"
@.str.16687 = private unnamed_addr constant [7 x i8] c"reduce\00"
@.str.16694 = private unnamed_addr constant [8 x i8] c"preduce\00"
@.str.16701 = private unnamed_addr constant [7 x i8] c"filter\00"
@.str.16708 = private unnamed_addr constant [32 x i8] c"/* unsupported nested block */\0A\00"
@.str.16723 = private unnamed_addr constant [3 x i8] c";\0A\00"
@.str.16769 = private unnamed_addr constant [4 x i8] c"def\00"
@.str.16784 = private unnamed_addr constant [5 x i8] c"main\00"
@.str.16799 = private unnamed_addr constant [2 x i8] c"(\00"
@.str.16814 = private unnamed_addr constant [2 x i8] c")\00"
@.str.16829 = private unnamed_addr constant [2 x i8] c":\00"
@.str.16843 = private unnamed_addr constant [4 x i8] c"Int\00"
@.str.16858 = private unnamed_addr constant [2 x i8] c"{\00"
@.str.16976 = private unnamed_addr constant [4 x i8] c"def\00"
@.str.16991 = private unnamed_addr constant [5 x i8] c"main\00"
@.str.17006 = private unnamed_addr constant [2 x i8] c"(\00"
@.str.17021 = private unnamed_addr constant [2 x i8] c")\00"
@.str.17036 = private unnamed_addr constant [2 x i8] c":\00"
@.str.17050 = private unnamed_addr constant [4 x i8] c"Int\00"
@.str.17090 = private unnamed_addr constant [35 x i8] c"int main(int argc, char** argv) {\0A\00"
@.str.17092 = private unnamed_addr constant [17 x i8] c"    (void)argc;\0A\00"
@.str.17094 = private unnamed_addr constant [17 x i8] c"    (void)argv;\0A\00"
@.str.17104 = private unnamed_addr constant [5 x i8] c"    \00"
@.str.17107 = private unnamed_addr constant [15 x i8] c"    return 0;\0A\00"
@.str.17109 = private unnamed_addr constant [3 x i8] c"}\0A\00"
@.str.17121 = private unnamed_addr constant [1 x i8] c"\00"
@.str.17140 = private unnamed_addr constant [8 x i8] c"Boolean\00"
@.str.17145 = private unnamed_addr constant [3 x i8] c"i1\00"
@.str.17154 = private unnamed_addr constant [5 x i8] c"Char\00"
@.str.17159 = private unnamed_addr constant [3 x i8] c"i8\00"
@.str.17168 = private unnamed_addr constant [4 x i8] c"Int\00"
@.str.17173 = private unnamed_addr constant [4 x i8] c"i32\00"
@.str.17182 = private unnamed_addr constant [5 x i8] c"Long\00"
@.str.17187 = private unnamed_addr constant [4 x i8] c"i64\00"
@.str.17196 = private unnamed_addr constant [6 x i8] c"Float\00"
@.str.17201 = private unnamed_addr constant [6 x i8] c"float\00"
@.str.17210 = private unnamed_addr constant [7 x i8] c"Double\00"
@.str.17215 = private unnamed_addr constant [7 x i8] c"double\00"
@.str.17224 = private unnamed_addr constant [5 x i8] c"Unit\00"
@.str.17229 = private unnamed_addr constant [5 x i8] c"void\00"
@.str.17238 = private unnamed_addr constant [7 x i8] c"String\00"
@.str.17243 = private unnamed_addr constant [4 x i8] c"ptr\00"
@.str.17252 = private unnamed_addr constant [6 x i8] c"Regex\00"
@.str.17257 = private unnamed_addr constant [4 x i8] c"ptr\00"
@.str.17266 = private unnamed_addr constant [6 x i8] c"Range\00"
@.str.17271 = private unnamed_addr constant [4 x i8] c"ptr\00"
@.str.17280 = private unnamed_addr constant [6 x i8] c"Array\00"
@.str.17285 = private unnamed_addr constant [4 x i8] c"ptr\00"
@.str.17298 = private unnamed_addr constant [4 x i8] c"ptr\00"
@.str.17302 = private unnamed_addr constant [4 x i8] c"ptr\00"
@.str.17321 = private unnamed_addr constant [2 x i8] c"+\00"
@.str.17326 = private unnamed_addr constant [4 x i8] c"add\00"
@.str.17335 = private unnamed_addr constant [2 x i8] c"-\00"
@.str.17340 = private unnamed_addr constant [4 x i8] c"sub\00"
@.str.17349 = private unnamed_addr constant [2 x i8] c"*\00"
@.str.17354 = private unnamed_addr constant [4 x i8] c"mul\00"
@.str.17363 = private unnamed_addr constant [2 x i8] c"/\00"
@.str.17368 = private unnamed_addr constant [5 x i8] c"sdiv\00"
@.str.17377 = private unnamed_addr constant [2 x i8] c"%\00"
@.str.17382 = private unnamed_addr constant [5 x i8] c"srem\00"
@.str.17391 = private unnamed_addr constant [3 x i8] c"<<\00"
@.str.17396 = private unnamed_addr constant [4 x i8] c"shl\00"
@.str.17405 = private unnamed_addr constant [3 x i8] c">>\00"
@.str.17410 = private unnamed_addr constant [5 x i8] c"ashr\00"
@.str.17419 = private unnamed_addr constant [2 x i8] c"&\00"
@.str.17424 = private unnamed_addr constant [4 x i8] c"and\00"
@.str.17433 = private unnamed_addr constant [2 x i8] c"|\00"
@.str.17438 = private unnamed_addr constant [3 x i8] c"or\00"
@.str.17447 = private unnamed_addr constant [2 x i8] c"^\00"
@.str.17454 = private unnamed_addr constant [4 x i8] c"xor\00"
@.str.17459 = private unnamed_addr constant [4 x i8] c"xor\00"
@.str.17468 = private unnamed_addr constant [4 x i8] c"and\00"
@.str.17475 = private unnamed_addr constant [3 x i8] c"&&\00"
@.str.17480 = private unnamed_addr constant [4 x i8] c"and\00"
@.str.17489 = private unnamed_addr constant [3 x i8] c"or\00"
@.str.17496 = private unnamed_addr constant [3 x i8] c"||\00"
@.str.17501 = private unnamed_addr constant [3 x i8] c"or\00"
@.str.17510 = private unnamed_addr constant [3 x i8] c"==\00"
@.str.17515 = private unnamed_addr constant [8 x i8] c"icmp_eq\00"
@.str.17524 = private unnamed_addr constant [3 x i8] c"!=\00"
@.str.17529 = private unnamed_addr constant [8 x i8] c"icmp_ne\00"
@.str.17538 = private unnamed_addr constant [2 x i8] c"<\00"
@.str.17543 = private unnamed_addr constant [9 x i8] c"icmp_slt\00"
@.str.17552 = private unnamed_addr constant [3 x i8] c"<=\00"
@.str.17557 = private unnamed_addr constant [9 x i8] c"icmp_sle\00"
@.str.17566 = private unnamed_addr constant [2 x i8] c">\00"
@.str.17571 = private unnamed_addr constant [9 x i8] c"icmp_sgt\00"
@.str.17580 = private unnamed_addr constant [3 x i8] c">=\00"
@.str.17585 = private unnamed_addr constant [9 x i8] c"icmp_sge\00"
@.str.17594 = private unnamed_addr constant [3 x i8] c"..\00"
@.str.17599 = private unnamed_addr constant [6 x i8] c"range\00"
@.str.17608 = private unnamed_addr constant [3 x i8] c"to\00"
@.str.17613 = private unnamed_addr constant [9 x i8] c"range_to\00"
@.str.17622 = private unnamed_addr constant [6 x i8] c"until\00"
@.str.17627 = private unnamed_addr constant [12 x i8] c"range_until\00"
@.str.17636 = private unnamed_addr constant [2 x i8] c"@\00"
@.str.17641 = private unnamed_addr constant [7 x i8] c"matmul\00"
@.str.17650 = private unnamed_addr constant [6 x i8] c"inner\00"
@.str.17655 = private unnamed_addr constant [6 x i8] c"inner\00"
@.str.17664 = private unnamed_addr constant [6 x i8] c"outer\00"
@.str.17669 = private unnamed_addr constant [6 x i8] c"outer\00"
@.str.17678 = private unnamed_addr constant [7 x i8] c"tensor\00"
@.str.17683 = private unnamed_addr constant [7 x i8] c"tensor\00"
@.str.18032 = private unnamed_addr constant [5 x i8] c"void\00"
@.str.18091 = private unnamed_addr constant [2 x i8] c" \00"
@.str.18095 = private unnamed_addr constant [3 x i8] c" (\00"
@.str.18106 = private unnamed_addr constant [5 x i8] c"), (\00"
@.str.18119 = private unnamed_addr constant [2 x i8] c")\00"
@.str.18153 = private unnamed_addr constant [2 x i8] c"(\00"
@.str.18166 = private unnamed_addr constant [2 x i8] c"(\00"
@.str.18168 = private unnamed_addr constant [2 x i8] c")\00"
@.str.18177 = private unnamed_addr constant [6 x i8] c"call \00"
@.str.18181 = private unnamed_addr constant [3 x i8] c" @\00"
@.str.18190 = private unnamed_addr constant [2 x i8] c"(\00"
@.str.18205 = private unnamed_addr constant [2 x i8] c")\00"
@.str.18229 = private unnamed_addr constant [6 x i8] c"load \00"
@.str.18233 = private unnamed_addr constant [8 x i8] c", ptr %\00"
@.str.18246 = private unnamed_addr constant [2 x i8] c" \00"
@.str.18311 = private unnamed_addr constant [1 x i8] c"\00"
@.str.18360 = private unnamed_addr constant [2 x i8] c"=\00"
@.str.18367 = private unnamed_addr constant [3 x i8] c"<-\00"
@.str.18372 = private unnamed_addr constant [11 x i8] c"    store \00"
@.str.18376 = private unnamed_addr constant [8 x i8] c", ptr %\00"
@.str.18380 = private unnamed_addr constant [2 x i8] c"\0A\00"
@.str.18429 = private unnamed_addr constant [3 x i8] c"%=\00"
@.str.18435 = private unnamed_addr constant [2 x i8] c"%\00"
@.str.18439 = private unnamed_addr constant [10 x i8] c"    %old.\00"
@.str.18443 = private unnamed_addr constant [9 x i8] c" = load \00"
@.str.18447 = private unnamed_addr constant [8 x i8] c", ptr %\00"
@.str.18451 = private unnamed_addr constant [2 x i8] c"\0A\00"
@.str.18453 = private unnamed_addr constant [10 x i8] c"    %new.\00"
@.str.18457 = private unnamed_addr constant [4 x i8] c" = \00"
@.str.18464 = private unnamed_addr constant [2 x i8] c" \00"
@.str.18468 = private unnamed_addr constant [7 x i8] c" %old.\00"
@.str.18472 = private unnamed_addr constant [4 x i8] c", (\00"
@.str.18494 = private unnamed_addr constant [3 x i8] c")\0A\00"
@.str.18496 = private unnamed_addr constant [11 x i8] c"    store \00"
@.str.18500 = private unnamed_addr constant [7 x i8] c" %new.\00"
@.str.18504 = private unnamed_addr constant [8 x i8] c", ptr %\00"
@.str.18508 = private unnamed_addr constant [2 x i8] c"\0A\00"
@.str.18545 = private unnamed_addr constant [1 x i8] c"\00"
@.str.18574 = private unnamed_addr constant [1 x i8] c"\00"
@.str.18620 = private unnamed_addr constant [8 x i8] c"unknown\00"
@.str.18636 = private unnamed_addr constant [2 x i8] c":\00"
@.str.18664 = private unnamed_addr constant [3 x i8] c", \00"
@.str.18676 = private unnamed_addr constant [3 x i8] c" %\00"
@.str.18707 = private unnamed_addr constant [2 x i8] c",\00"
@.str.18730 = private unnamed_addr constant [2 x i8] c",\00"
@.str.18769 = private unnamed_addr constant [1 x i8] c"\00"
@.str.18837 = private unnamed_addr constant [7 x i8] c"return\00"
@.str.18845 = private unnamed_addr constant [9 x i8] c"    ret \00"
@.str.18858 = private unnamed_addr constant [2 x i8] c"\0A\00"
@.str.18868 = private unnamed_addr constant [6 x i8] c"value\00"
@.str.18875 = private unnamed_addr constant [9 x i8] c"variable\00"
@.str.18922 = private unnamed_addr constant [6 x i8] c"    %\00"
@.str.18933 = private unnamed_addr constant [11 x i8] c" = alloca \00"
@.str.18940 = private unnamed_addr constant [2 x i8] c"\0A\00"
@.str.18942 = private unnamed_addr constant [11 x i8] c"    store \00"
@.str.18955 = private unnamed_addr constant [8 x i8] c", ptr %\00"
@.str.18966 = private unnamed_addr constant [2 x i8] c"\0A\00"
@.str.18975 = private unnamed_addr constant [6 x i8] c"    %\00"
@.str.18986 = private unnamed_addr constant [15 x i8] c" = alloca ptr\0A\00"
@.str.18997 = private unnamed_addr constant [3 x i8] c"if\00"
@.str.19004 = private unnamed_addr constant [6 x i8] c"while\00"
@.str.19011 = private unnamed_addr constant [4 x i8] c"for\00"
@.str.19018 = private unnamed_addr constant [4 x i8] c"map\00"
@.str.19025 = private unnamed_addr constant [5 x i8] c"pmap\00"
@.str.19032 = private unnamed_addr constant [7 x i8] c"reduce\00"
@.str.19039 = private unnamed_addr constant [8 x i8] c"preduce\00"
@.str.19046 = private unnamed_addr constant [7 x i8] c"filter\00"
@.str.19054 = private unnamed_addr constant [20 x i8] c"    ; nested block \00"
@.str.19058 = private unnamed_addr constant [3 x i8] c" (\00"
@.str.19069 = private unnamed_addr constant [3 x i8] c")\0A\00"
@.str.19110 = private unnamed_addr constant [5 x i8] c"    \00"
@.str.19121 = private unnamed_addr constant [2 x i8] c"\0A\00"
@.str.19168 = private unnamed_addr constant [20 x i8] c"    ; no else body\0A\00"
@.str.19197 = private unnamed_addr constant [2 x i8] c"{\00"
@.str.19214 = private unnamed_addr constant [2 x i8] c"{\00"
@.str.19216 = private unnamed_addr constant [2 x i8] c"}\00"
@.str.19252 = private unnamed_addr constant [3 x i8] c"if\00"
@.str.19257 = private unnamed_addr constant [20 x i8] c"    ; else-if body\0A\00"
@.str.19261 = private unnamed_addr constant [27 x i8] c"    ; malformed else body\0A\00"
@.str.19337 = private unnamed_addr constant [2 x i8] c"{\00"
@.str.19339 = private unnamed_addr constant [2 x i8] c"}\00"
@.str.19362 = private unnamed_addr constant [20 x i8] c"    ; malformed if\0A\00"
@.str.19370 = private unnamed_addr constant [1 x i8] c"\00"
@.str.19411 = private unnamed_addr constant [5 x i8] c"else\00"
@.str.19421 = private unnamed_addr constant [11 x i8] c"    %cond.\00"
@.str.19425 = private unnamed_addr constant [4 x i8] c" = \00"
@.str.19438 = private unnamed_addr constant [2 x i8] c"\0A\00"
@.str.19440 = private unnamed_addr constant [17 x i8] c"    br i1 %cond.\00"
@.str.19444 = private unnamed_addr constant [18 x i8] c", label %if.then.\00"
@.str.19448 = private unnamed_addr constant [18 x i8] c", label %if.else.\00"
@.str.19452 = private unnamed_addr constant [2 x i8] c"\0A\00"
@.str.19454 = private unnamed_addr constant [9 x i8] c"if.then.\00"
@.str.19458 = private unnamed_addr constant [3 x i8] c":\0A\00"
@.str.19471 = private unnamed_addr constant [22 x i8] c"    br label %if.end.\00"
@.str.19475 = private unnamed_addr constant [2 x i8] c"\0A\00"
@.str.19477 = private unnamed_addr constant [9 x i8] c"if.else.\00"
@.str.19481 = private unnamed_addr constant [3 x i8] c":\0A\00"
@.str.19494 = private unnamed_addr constant [22 x i8] c"    br label %if.end.\00"
@.str.19498 = private unnamed_addr constant [2 x i8] c"\0A\00"
@.str.19500 = private unnamed_addr constant [8 x i8] c"if.end.\00"
@.str.19504 = private unnamed_addr constant [3 x i8] c":\0A\00"
@.str.19580 = private unnamed_addr constant [2 x i8] c"{\00"
@.str.19582 = private unnamed_addr constant [2 x i8] c"}\00"
@.str.19605 = private unnamed_addr constant [23 x i8] c"    ; malformed while\0A\00"
@.str.19613 = private unnamed_addr constant [1 x i8] c"\00"
@.str.19618 = private unnamed_addr constant [26 x i8] c"    br label %while.cond.\00"
@.str.19622 = private unnamed_addr constant [2 x i8] c"\0A\00"
@.str.19624 = private unnamed_addr constant [12 x i8] c"while.cond.\00"
@.str.19628 = private unnamed_addr constant [3 x i8] c":\0A\00"
@.str.19630 = private unnamed_addr constant [16 x i8] c"    %whilecond.\00"
@.str.19634 = private unnamed_addr constant [4 x i8] c" = \00"
@.str.19647 = private unnamed_addr constant [2 x i8] c"\0A\00"
@.str.19649 = private unnamed_addr constant [22 x i8] c"    br i1 %whilecond.\00"
@.str.19653 = private unnamed_addr constant [21 x i8] c", label %while.body.\00"
@.str.19657 = private unnamed_addr constant [20 x i8] c", label %while.end.\00"
@.str.19661 = private unnamed_addr constant [2 x i8] c"\0A\00"
@.str.19663 = private unnamed_addr constant [12 x i8] c"while.body.\00"
@.str.19667 = private unnamed_addr constant [3 x i8] c":\0A\00"
@.str.19680 = private unnamed_addr constant [26 x i8] c"    br label %while.cond.\00"
@.str.19684 = private unnamed_addr constant [2 x i8] c"\0A\00"
@.str.19686 = private unnamed_addr constant [11 x i8] c"while.end.\00"
@.str.19690 = private unnamed_addr constant [3 x i8] c":\0A\00"
@.str.19766 = private unnamed_addr constant [2 x i8] c"{\00"
@.str.19768 = private unnamed_addr constant [2 x i8] c"}\00"
@.str.19791 = private unnamed_addr constant [21 x i8] c"    ; malformed for\0A\00"
@.str.19823 = private unnamed_addr constant [3 x i8] c"<-\00"
@.str.19834 = private unnamed_addr constant [28 x i8] c"    ; malformed for source\0A\00"
@.str.19842 = private unnamed_addr constant [1 x i8] c"\00"
@.str.19847 = private unnamed_addr constant [18 x i8] c"    ; for source \00"
@.str.19860 = private unnamed_addr constant [2 x i8] c"\0A\00"
@.str.19862 = private unnamed_addr constant [6 x i8] c"    %\00"
@.str.19866 = private unnamed_addr constant [15 x i8] c" = alloca ptr\0A\00"
@.str.19868 = private unnamed_addr constant [24 x i8] c"    br label %for.cond.\00"
@.str.19872 = private unnamed_addr constant [2 x i8] c"\0A\00"
@.str.19874 = private unnamed_addr constant [10 x i8] c"for.cond.\00"
@.str.19878 = private unnamed_addr constant [3 x i8] c":\0A\00"
@.str.19880 = private unnamed_addr constant [21 x i8] c"    ; iterator next \00"
@.str.19884 = private unnamed_addr constant [2 x i8] c"\0A\00"
@.str.19886 = private unnamed_addr constant [24 x i8] c"    br i1 %for.hasnext.\00"
@.str.19890 = private unnamed_addr constant [19 x i8] c", label %for.body.\00"
@.str.19894 = private unnamed_addr constant [18 x i8] c", label %for.end.\00"
@.str.19898 = private unnamed_addr constant [2 x i8] c"\0A\00"
@.str.19900 = private unnamed_addr constant [10 x i8] c"for.body.\00"
@.str.19904 = private unnamed_addr constant [3 x i8] c":\0A\00"
@.str.19917 = private unnamed_addr constant [24 x i8] c"    br label %for.cond.\00"
@.str.19921 = private unnamed_addr constant [2 x i8] c"\0A\00"
@.str.19923 = private unnamed_addr constant [9 x i8] c"for.end.\00"
@.str.19927 = private unnamed_addr constant [3 x i8] c":\0A\00"
@.str.19953 = private unnamed_addr constant [1 x i8] c"\00"
@.str.20021 = private unnamed_addr constant [7 x i8] c"return\00"
@.str.20029 = private unnamed_addr constant [9 x i8] c"    ret \00"
@.str.20042 = private unnamed_addr constant [2 x i8] c"\0A\00"
@.str.20052 = private unnamed_addr constant [6 x i8] c"value\00"
@.str.20059 = private unnamed_addr constant [9 x i8] c"variable\00"
@.str.20106 = private unnamed_addr constant [6 x i8] c"    %\00"
@.str.20117 = private unnamed_addr constant [11 x i8] c" = alloca \00"
@.str.20124 = private unnamed_addr constant [2 x i8] c"\0A\00"
@.str.20126 = private unnamed_addr constant [11 x i8] c"    store \00"
@.str.20139 = private unnamed_addr constant [8 x i8] c", ptr %\00"
@.str.20150 = private unnamed_addr constant [2 x i8] c"\0A\00"
@.str.20159 = private unnamed_addr constant [6 x i8] c"    %\00"
@.str.20170 = private unnamed_addr constant [15 x i8] c" = alloca ptr\0A\00"
@.str.20181 = private unnamed_addr constant [3 x i8] c"if\00"
@.str.20206 = private unnamed_addr constant [6 x i8] c"while\00"
@.str.20231 = private unnamed_addr constant [4 x i8] c"for\00"
@.str.20256 = private unnamed_addr constant [4 x i8] c"map\00"
@.str.20263 = private unnamed_addr constant [5 x i8] c"pmap\00"
@.str.20270 = private unnamed_addr constant [7 x i8] c"reduce\00"
@.str.20277 = private unnamed_addr constant [8 x i8] c"preduce\00"
@.str.20284 = private unnamed_addr constant [7 x i8] c"filter\00"
@.str.20292 = private unnamed_addr constant [13 x i8] c"    ; block \00"
@.str.20296 = private unnamed_addr constant [3 x i8] c" (\00"
@.str.20307 = private unnamed_addr constant [3 x i8] c")\0A\00"
@.str.20348 = private unnamed_addr constant [5 x i8] c"    \00"
@.str.20359 = private unnamed_addr constant [2 x i8] c"\0A\00"
@.str.20392 = private unnamed_addr constant [1 x i8] c"\00"
@.str.20450 = private unnamed_addr constant [9 x i8] c"function\00"
@.str.20457 = private unnamed_addr constant [18 x i8] c"external-function\00"
@.str.20465 = private unnamed_addr constant [8 x i8] c"define \00"
@.str.20477 = private unnamed_addr constant [3 x i8] c" @\00"
@.str.20481 = private unnamed_addr constant [2 x i8] c"(\00"
@.str.20490 = private unnamed_addr constant [3 x i8] c")\0A\00"
@.str.20545 = private unnamed_addr constant [12 x i8] c"end define\0A\00"
@.str.20555 = private unnamed_addr constant [6 x i8] c"class\00"
@.str.20562 = private unnamed_addr constant [7 x i8] c"object\00"
@.str.20569 = private unnamed_addr constant [15 x i8] c"external-class\00"
@.str.20576 = private unnamed_addr constant [16 x i8] c"external-object\00"
@.str.20584 = private unnamed_addr constant [7 x i8] c"%type.\00"
@.str.20588 = private unnamed_addr constant [18 x i8] c" = type opaque ; \00"
@.str.20592 = private unnamed_addr constant [2 x i8] c"\0A\00"
@.str.20602 = private unnamed_addr constant [6 x i8] c"value\00"
@.str.20609 = private unnamed_addr constant [9 x i8] c"variable\00"
@.str.20617 = private unnamed_addr constant [2 x i8] c"@\00"
@.str.20621 = private unnamed_addr constant [22 x i8] c" = global ptr null ; \00"
@.str.20625 = private unnamed_addr constant [2 x i8] c"\0A\00"
@.str.20667 = private unnamed_addr constant [21 x i8] c"error: parse failed\0A\00"
@.str.20681 = private unnamed_addr constant [22 x i8] c"module csec.selfhost\0A\00"
@.str.20688 = private unnamed_addr constant [12 x i8] c"entry main\0A\00"
@.str.20690 = private unnamed_addr constant [20 x i8] c"lowering llvm-text\0A\00"
@.str.20697 = private unnamed_addr constant [13 x i8] c"main.return \00"
@.str.20701 = private unnamed_addr constant [2 x i8] c"\0A\00"
@.str.20725 = private unnamed_addr constant [8 x i8] c"entry:\0A\00"
@.str.20727 = private unnamed_addr constant [11 x i8] c"  ret i32 \00"
@.str.20731 = private unnamed_addr constant [2 x i8] c"\0A\00"
@.str.20754 = private unnamed_addr constant [2 x i8] c"0\00"
@.str.20777 = private unnamed_addr constant [3 x i8] c"73\00"
@.str.20788 = private unnamed_addr constant [3 x i8] c"75\00"
@.str.20799 = private unnamed_addr constant [3 x i8] c"78\00"
@.str.20810 = private unnamed_addr constant [3 x i8] c"70\00"
@.str.20821 = private unnamed_addr constant [3 x i8] c"83\00"
@.str.20832 = private unnamed_addr constant [3 x i8] c"82\00"
@.str.20843 = private unnamed_addr constant [3 x i8] c"67\00"
@.str.20854 = private unnamed_addr constant [3 x i8] c"66\00"
@.str.20865 = private unnamed_addr constant [3 x i8] c"79\00"
@.str.20876 = private unnamed_addr constant [3 x i8] c"77\00"
@.str.20887 = private unnamed_addr constant [3 x i8] c"69\00"
@.str.20898 = private unnamed_addr constant [4 x i8] c"120\00"
@.str.20909 = private unnamed_addr constant [4 x i8] c"121\00"
@.str.20920 = private unnamed_addr constant [4 x i8] c"122\00"
@.str.20931 = private unnamed_addr constant [3 x i8] c"97\00"
@.str.20942 = private unnamed_addr constant [4 x i8] c"116\00"
@.str.20953 = private unnamed_addr constant [4 x i8] c"117\00"
@.str.20964 = private unnamed_addr constant [3 x i8] c"48\00"
@.str.20975 = private unnamed_addr constant [3 x i8] c"49\00"
@.str.20986 = private unnamed_addr constant [3 x i8] c"50\00"
@.str.20997 = private unnamed_addr constant [3 x i8] c"51\00"
@.str.21008 = private unnamed_addr constant [3 x i8] c"52\00"
@.str.21019 = private unnamed_addr constant [3 x i8] c"53\00"
@.str.21030 = private unnamed_addr constant [3 x i8] c"54\00"
@.str.21041 = private unnamed_addr constant [3 x i8] c"55\00"
@.str.21052 = private unnamed_addr constant [3 x i8] c"56\00"
@.str.21063 = private unnamed_addr constant [3 x i8] c"57\00"
@.str.21074 = private unnamed_addr constant [3 x i8] c"95\00"
@.str.21085 = private unnamed_addr constant [3 x i8] c"32\00"
@.str.21096 = private unnamed_addr constant [3 x i8] c"34\00"
@.str.21122 = private unnamed_addr constant [3 x i8] c"92\00"
@.str.21148 = private unnamed_addr constant [3 x i8] c"10\00"
@.str.21174 = private unnamed_addr constant [2 x i8] c"9\00"
@.str.21178 = private unnamed_addr constant [2 x i8] c"0\00"
@.str.21221 = private unnamed_addr constant [2 x i8] c"0\00"
@.str.21306 = private unnamed_addr constant [2 x i8] c"%\00"
@.str.21315 = private unnamed_addr constant [6 x i8] c".val.\00"
@.str.21321 = private unnamed_addr constant [5 x i8] c"%tmp\00"
@.str.21362 = private unnamed_addr constant [8 x i8] c"unknown\00"
@.str.21385 = private unnamed_addr constant [8 x i8] c"unknown\00"
@.str.21406 = private unnamed_addr constant [2 x i8] c"(\00"
@.str.21408 = private unnamed_addr constant [2 x i8] c")\00"
@.str.21419 = private unnamed_addr constant [8 x i8] c"unknown\00"
@.str.21489 = private unnamed_addr constant [2 x i8] c":\00"
@.str.21507 = private unnamed_addr constant [8 x i8] c"unknown\00"
@.str.21527 = private unnamed_addr constant [2 x i8] c",\00"
@.str.21546 = private unnamed_addr constant [8 x i8] c"unknown\00"
@.str.21588 = private unnamed_addr constant [8 x i8] c"unknown\00"
@.str.21644 = private unnamed_addr constant [1 x i8] c"\00"
@.str.21687 = private unnamed_addr constant [4 x i8] c"val\00"
@.str.21700 = private unnamed_addr constant [4 x i8] c"var\00"
@.str.21799 = private unnamed_addr constant [8 x i8] c"unknown\00"
@.str.21884 = private unnamed_addr constant [4 x i8] c"val\00"
@.str.21897 = private unnamed_addr constant [4 x i8] c"var\00"
@.str.21932 = private unnamed_addr constant [7 x i8] c".addr.\00"
@.str.21960 = private unnamed_addr constant [1 x i8] c"\00"
@.str.21997 = private unnamed_addr constant [4 x i8] c"val\00"
@.str.22010 = private unnamed_addr constant [4 x i8] c"var\00"
@.str.22046 = private unnamed_addr constant [7 x i8] c".addr.\00"
@.str.22110 = private unnamed_addr constant [4 x i8] c"val\00"
@.str.22123 = private unnamed_addr constant [4 x i8] c"var\00"
@.str.22158 = private unnamed_addr constant [7 x i8] c".addr.\00"
@.str.22224 = private unnamed_addr constant [8 x i8] c"Boolean\00"
@.str.22229 = private unnamed_addr constant [3 x i8] c"  \00"
@.str.22233 = private unnamed_addr constant [18 x i8] c" = load i1, ptr %\00"
@.str.22237 = private unnamed_addr constant [2 x i8] c"\0A\00"
@.str.22246 = private unnamed_addr constant [5 x i8] c"Char\00"
@.str.22251 = private unnamed_addr constant [3 x i8] c"  \00"
@.str.22255 = private unnamed_addr constant [18 x i8] c" = load i8, ptr %\00"
@.str.22259 = private unnamed_addr constant [2 x i8] c"\0A\00"
@.str.22268 = private unnamed_addr constant [7 x i8] c"Double\00"
@.str.22273 = private unnamed_addr constant [3 x i8] c"  \00"
@.str.22277 = private unnamed_addr constant [22 x i8] c" = load double, ptr %\00"
@.str.22281 = private unnamed_addr constant [2 x i8] c"\0A\00"
@.str.22290 = private unnamed_addr constant [5 x i8] c"Long\00"
@.str.22295 = private unnamed_addr constant [3 x i8] c"  \00"
@.str.22299 = private unnamed_addr constant [19 x i8] c" = load i64, ptr %\00"
@.str.22303 = private unnamed_addr constant [2 x i8] c"\0A\00"
@.str.22315 = private unnamed_addr constant [4 x i8] c"ptr\00"
@.str.22320 = private unnamed_addr constant [3 x i8] c"  \00"
@.str.22324 = private unnamed_addr constant [19 x i8] c" = load ptr, ptr %\00"
@.str.22328 = private unnamed_addr constant [2 x i8] c"\0A\00"
@.str.22332 = private unnamed_addr constant [3 x i8] c"  \00"
@.str.22336 = private unnamed_addr constant [19 x i8] c" = load i32, ptr %\00"
@.str.22340 = private unnamed_addr constant [2 x i8] c"\0A\00"
@.str.22441 = private unnamed_addr constant [5 x i8] c"Char\00"
@.str.22446 = private unnamed_addr constant [4 x i8] c"  %\00"
@.str.22450 = private unnamed_addr constant [7 x i8] c".cval.\00"
@.str.22454 = private unnamed_addr constant [18 x i8] c" = load i8, ptr %\00"
@.str.22458 = private unnamed_addr constant [2 x i8] c"\0A\00"
@.str.22460 = private unnamed_addr constant [4 x i8] c"  %\00"
@.str.22464 = private unnamed_addr constant [6 x i8] c".val.\00"
@.str.22468 = private unnamed_addr constant [13 x i8] c" = zext i8 %\00"
@.str.22472 = private unnamed_addr constant [7 x i8] c".cval.\00"
@.str.22476 = private unnamed_addr constant [9 x i8] c" to i32\0A\00"
@.str.22480 = private unnamed_addr constant [4 x i8] c"  %\00"
@.str.22484 = private unnamed_addr constant [6 x i8] c".val.\00"
@.str.22488 = private unnamed_addr constant [19 x i8] c" = load i32, ptr %\00"
@.str.22492 = private unnamed_addr constant [2 x i8] c"\0A\00"
@.str.22496 = private unnamed_addr constant [1 x i8] c"\00"
@.str.22539 = private unnamed_addr constant [6 x i8] c"false\00"
@.str.22592 = private unnamed_addr constant [2 x i8] c"%\00"
@.str.22601 = private unnamed_addr constant [6 x i8] c".bval\00"
@.str.22605 = private unnamed_addr constant [6 x i8] c"%btmp\00"
@.str.22687 = private unnamed_addr constant [4 x i8] c"  %\00"
@.str.22691 = private unnamed_addr constant [23 x i8] c".bval = load i1, ptr %\00"
@.str.22695 = private unnamed_addr constant [2 x i8] c"\0A\00"
@.str.22699 = private unnamed_addr constant [1 x i8] c"\00"
@.str.22750 = private unnamed_addr constant [2 x i8] c"0\00"
@.str.22785 = private unnamed_addr constant [5 x i8] c".arg\00"
@.str.22830 = private unnamed_addr constant [4 x i8] c"i32\00"
@.str.22854 = private unnamed_addr constant [4 x i8] c"ptr\00"
@.str.22878 = private unnamed_addr constant [3 x i8] c"i8\00"
@.str.22902 = private unnamed_addr constant [3 x i8] c"i1\00"
@.str.22960 = private unnamed_addr constant [4 x i8] c"ptr\00"
@.str.22967 = private unnamed_addr constant [3 x i8] c"i8\00"
@.str.22974 = private unnamed_addr constant [3 x i8] c"i1\00"
@.str.22981 = private unnamed_addr constant [4 x i8] c"i64\00"
@.str.22988 = private unnamed_addr constant [7 x i8] c"double\00"
@.str.23028 = private unnamed_addr constant [2 x i8] c"(\00"
@.str.23041 = private unnamed_addr constant [2 x i8] c"(\00"
@.str.23043 = private unnamed_addr constant [2 x i8] c")\00"
@.str.23077 = private unnamed_addr constant [4 x i8] c"ptr\00"
@.str.23084 = private unnamed_addr constant [3 x i8] c"i8\00"
@.str.23091 = private unnamed_addr constant [3 x i8] c"i1\00"
@.str.23098 = private unnamed_addr constant [4 x i8] c"i64\00"
@.str.23105 = private unnamed_addr constant [7 x i8] c"double\00"
@.str.23157 = private unnamed_addr constant [2 x i8] c"+\00"
@.str.23172 = private unnamed_addr constant [4 x i8] c"ptr\00"
@.str.23188 = private unnamed_addr constant [4 x i8] c"ptr\00"
@.str.23194 = private unnamed_addr constant [4 x i8] c"ptr\00"
@.str.23199 = private unnamed_addr constant [4 x i8] c"i32\00"
@.str.23250 = private unnamed_addr constant [2 x i8] c"0\00"
@.str.23346 = private unnamed_addr constant [5 x i8] c".arg\00"
@.str.23395 = private unnamed_addr constant [3 x i8] c"  \00"
@.str.23399 = private unnamed_addr constant [17 x i8] c" = add i32 0, 0\0A\00"
@.str.23446 = private unnamed_addr constant [3 x i8] c"  \00"
@.str.23450 = private unnamed_addr constant [28 x i8] c" = getelementptr inbounds [\00"
@.str.23454 = private unnamed_addr constant [19 x i8] c" x i8], ptr @.str.\00"
@.str.23458 = private unnamed_addr constant [16 x i8] c", i32 0, i32 0\0A\00"
@.str.23482 = private unnamed_addr constant [3 x i8] c"  \00"
@.str.23486 = private unnamed_addr constant [15 x i8] c" = add i32 0, \00"
@.str.23495 = private unnamed_addr constant [2 x i8] c"\0A\00"
@.str.23519 = private unnamed_addr constant [3 x i8] c"  \00"
@.str.23523 = private unnamed_addr constant [15 x i8] c" = add i32 0, \00"
@.str.23535 = private unnamed_addr constant [2 x i8] c"\0A\00"
@.str.23614 = private unnamed_addr constant [4 x i8] c"ptr\00"
@.str.23621 = private unnamed_addr constant [3 x i8] c"i8\00"
@.str.23628 = private unnamed_addr constant [3 x i8] c"i1\00"
@.str.23635 = private unnamed_addr constant [4 x i8] c"i64\00"
@.str.23642 = private unnamed_addr constant [7 x i8] c"double\00"
@.str.23647 = private unnamed_addr constant [3 x i8] c"  \00"
@.str.23651 = private unnamed_addr constant [9 x i8] c" = load \00"
@.str.23655 = private unnamed_addr constant [8 x i8] c", ptr %\00"
@.str.23659 = private unnamed_addr constant [2 x i8] c"\0A\00"
@.str.23663 = private unnamed_addr constant [3 x i8] c"  \00"
@.str.23667 = private unnamed_addr constant [19 x i8] c" = load i32, ptr %\00"
@.str.23671 = private unnamed_addr constant [2 x i8] c"\0A\00"
@.str.23705 = private unnamed_addr constant [2 x i8] c"(\00"
@.str.23718 = private unnamed_addr constant [2 x i8] c"(\00"
@.str.23720 = private unnamed_addr constant [2 x i8] c")\00"
@.str.23761 = private unnamed_addr constant [4 x i8] c"ptr\00"
@.str.23768 = private unnamed_addr constant [15 x i8] c"commandLineArg\00"
@.str.23787 = private unnamed_addr constant [6 x i8] c".arg0\00"
@.str.23790 = private unnamed_addr constant [3 x i8] c"  \00"
@.str.23794 = private unnamed_addr constant [40 x i8] c" = call ptr @csec_command_line_arg(i32 \00"
@.str.23798 = private unnamed_addr constant [8 x i8] c".arg0)\0A\00"
@.str.23807 = private unnamed_addr constant [4 x i8] c"ptr\00"
@.str.23814 = private unnamed_addr constant [12 x i8] c"tokenTextAt\00"
@.str.23835 = private unnamed_addr constant [2 x i8] c",\00"
@.str.23860 = private unnamed_addr constant [6 x i8] c".arg0\00"
@.str.23877 = private unnamed_addr constant [6 x i8] c".arg1\00"
@.str.23880 = private unnamed_addr constant [3 x i8] c"  \00"
@.str.23884 = private unnamed_addr constant [37 x i8] c" = call ptr @csec_token_text_at(ptr \00"
@.str.23888 = private unnamed_addr constant [12 x i8] c".arg0, i32 \00"
@.str.23892 = private unnamed_addr constant [8 x i8] c".arg1)\0A\00"
@.str.23902 = private unnamed_addr constant [3 x i8] c"i8\00"
@.str.23915 = private unnamed_addr constant [3 x i8] c"  \00"
@.str.23919 = private unnamed_addr constant [13 x i8] c" = call i8 @\00"
@.str.23923 = private unnamed_addr constant [4 x i8] c"()\0A\00"
@.str.23932 = private unnamed_addr constant [4 x i8] c"ptr\00"
@.str.23967 = private unnamed_addr constant [3 x i8] c"  \00"
@.str.23971 = private unnamed_addr constant [14 x i8] c" = call ptr @\00"
@.str.23975 = private unnamed_addr constant [4 x i8] c"()\0A\00"
@.str.23991 = private unnamed_addr constant [2 x i8] c",\00"
@.str.24012 = private unnamed_addr constant [6 x i8] c".arg0\00"
@.str.24015 = private unnamed_addr constant [3 x i8] c"  \00"
@.str.24019 = private unnamed_addr constant [14 x i8] c" = call ptr @\00"
@.str.24023 = private unnamed_addr constant [2 x i8] c"(\00"
@.str.24034 = private unnamed_addr constant [2 x i8] c" \00"
@.str.24038 = private unnamed_addr constant [8 x i8] c".arg0)\0A\00"
@.str.24068 = private unnamed_addr constant [2 x i8] c",\00"
@.str.24089 = private unnamed_addr constant [6 x i8] c".arg0\00"
@.str.24102 = private unnamed_addr constant [6 x i8] c".arg1\00"
@.str.24105 = private unnamed_addr constant [3 x i8] c"  \00"
@.str.24109 = private unnamed_addr constant [14 x i8] c" = call ptr @\00"
@.str.24113 = private unnamed_addr constant [2 x i8] c"(\00"
@.str.24124 = private unnamed_addr constant [2 x i8] c" \00"
@.str.24128 = private unnamed_addr constant [8 x i8] c".arg0, \00"
@.str.24139 = private unnamed_addr constant [2 x i8] c" \00"
@.str.24143 = private unnamed_addr constant [8 x i8] c".arg1)\0A\00"
@.str.24173 = private unnamed_addr constant [2 x i8] c",\00"
@.str.24194 = private unnamed_addr constant [6 x i8] c".arg0\00"
@.str.24207 = private unnamed_addr constant [6 x i8] c".arg1\00"
@.str.24220 = private unnamed_addr constant [6 x i8] c".arg2\00"
@.str.24223 = private unnamed_addr constant [3 x i8] c"  \00"
@.str.24227 = private unnamed_addr constant [14 x i8] c" = call ptr @\00"
@.str.24231 = private unnamed_addr constant [2 x i8] c"(\00"
@.str.24242 = private unnamed_addr constant [2 x i8] c" \00"
@.str.24246 = private unnamed_addr constant [8 x i8] c".arg0, \00"
@.str.24257 = private unnamed_addr constant [2 x i8] c" \00"
@.str.24261 = private unnamed_addr constant [8 x i8] c".arg1, \00"
@.str.24272 = private unnamed_addr constant [2 x i8] c" \00"
@.str.24276 = private unnamed_addr constant [8 x i8] c".arg2)\0A\00"
@.str.24304 = private unnamed_addr constant [6 x i8] c".arg0\00"
@.str.24317 = private unnamed_addr constant [6 x i8] c".arg1\00"
@.str.24330 = private unnamed_addr constant [6 x i8] c".arg2\00"
@.str.24343 = private unnamed_addr constant [6 x i8] c".arg3\00"
@.str.24346 = private unnamed_addr constant [3 x i8] c"  \00"
@.str.24350 = private unnamed_addr constant [14 x i8] c" = call ptr @\00"
@.str.24354 = private unnamed_addr constant [2 x i8] c"(\00"
@.str.24365 = private unnamed_addr constant [2 x i8] c" \00"
@.str.24369 = private unnamed_addr constant [8 x i8] c".arg0, \00"
@.str.24380 = private unnamed_addr constant [2 x i8] c" \00"
@.str.24384 = private unnamed_addr constant [8 x i8] c".arg1, \00"
@.str.24395 = private unnamed_addr constant [2 x i8] c" \00"
@.str.24399 = private unnamed_addr constant [8 x i8] c".arg2, \00"
@.str.24410 = private unnamed_addr constant [2 x i8] c" \00"
@.str.24414 = private unnamed_addr constant [8 x i8] c".arg3)\0A\00"
@.str.24449 = private unnamed_addr constant [2 x i8] c".\00"
@.str.24464 = private unnamed_addr constant [7 x i8] c"charAt\00"
@.str.24479 = private unnamed_addr constant [2 x i8] c"(\00"
@.str.24492 = private unnamed_addr constant [2 x i8] c"(\00"
@.str.24494 = private unnamed_addr constant [2 x i8] c")\00"
@.str.24563 = private unnamed_addr constant [3 x i8] c"  \00"
@.str.24567 = private unnamed_addr constant [23 x i8] c".obj = load ptr, ptr %\00"
@.str.24571 = private unnamed_addr constant [2 x i8] c"\0A\00"
@.str.24597 = private unnamed_addr constant [3 x i8] c"  \00"
@.str.24601 = private unnamed_addr constant [21 x i8] c".index = add i32 0, \00"
@.str.24610 = private unnamed_addr constant [2 x i8] c"\0A\00"
@.str.24638 = private unnamed_addr constant [3 x i8] c"  \00"
@.str.24642 = private unnamed_addr constant [25 x i8] c".index = load i32, ptr %\00"
@.str.24658 = private unnamed_addr constant [2 x i8] c"\0A\00"
@.str.24667 = private unnamed_addr constant [3 x i8] c"  \00"
@.str.24671 = private unnamed_addr constant [23 x i8] c".index = add i32 0, 0\0A\00"
@.str.24677 = private unnamed_addr constant [3 x i8] c"  \00"
@.str.24681 = private unnamed_addr constant [40 x i8] c".i8 = call i8 @csec_string_char_at(ptr \00"
@.str.24685 = private unnamed_addr constant [11 x i8] c".obj, i32 \00"
@.str.24689 = private unnamed_addr constant [9 x i8] c".index)\0A\00"
@.str.24691 = private unnamed_addr constant [3 x i8] c"  \00"
@.str.24695 = private unnamed_addr constant [12 x i8] c" = zext i8 \00"
@.str.24699 = private unnamed_addr constant [12 x i8] c".i8 to i32\0A\00"
@.str.24745 = private unnamed_addr constant [2 x i8] c"+\00"
@.str.24760 = private unnamed_addr constant [4 x i8] c"ptr\00"
@.str.24776 = private unnamed_addr constant [4 x i8] c"ptr\00"
@.str.24800 = private unnamed_addr constant [1 x i8] c"\00"
@.str.24807 = private unnamed_addr constant [1 x i8] c"\00"
@.str.24822 = private unnamed_addr constant [4 x i8] c"ptr\00"
@.str.24838 = private unnamed_addr constant [6 x i8] c".left\00"
@.str.24872 = private unnamed_addr constant [3 x i8] c"  \00"
@.str.24876 = private unnamed_addr constant [42 x i8] c".left = call ptr @csec_to_string_char(i8 \00"
@.str.24888 = private unnamed_addr constant [3 x i8] c")\0A\00"
@.str.24934 = private unnamed_addr constant [5 x i8] c"Char\00"
@.str.24940 = private unnamed_addr constant [3 x i8] c"  \00"
@.str.24944 = private unnamed_addr constant [26 x i8] c".left.i8 = load i8, ptr %\00"
@.str.24960 = private unnamed_addr constant [2 x i8] c"\0A\00"
@.str.24962 = private unnamed_addr constant [3 x i8] c"  \00"
@.str.24966 = private unnamed_addr constant [42 x i8] c".left = call ptr @csec_to_string_char(i8 \00"
@.str.24970 = private unnamed_addr constant [11 x i8] c".left.i8)\0A\00"
@.str.24987 = private unnamed_addr constant [10 x i8] c".left.i32\00"
@.str.24990 = private unnamed_addr constant [3 x i8] c"  \00"
@.str.24994 = private unnamed_addr constant [22 x i8] c".left.i64 = sext i32 \00"
@.str.24998 = private unnamed_addr constant [18 x i8] c".left.i32 to i64\0A\00"
@.str.25000 = private unnamed_addr constant [3 x i8] c"  \00"
@.str.25004 = private unnamed_addr constant [42 x i8] c".left = call ptr @csec_to_string_i64(i64 \00"
@.str.25008 = private unnamed_addr constant [12 x i8] c".left.i64)\0A\00"
@.str.25024 = private unnamed_addr constant [4 x i8] c"ptr\00"
@.str.25040 = private unnamed_addr constant [7 x i8] c".right\00"
@.str.25074 = private unnamed_addr constant [3 x i8] c"  \00"
@.str.25078 = private unnamed_addr constant [43 x i8] c".right = call ptr @csec_to_string_char(i8 \00"
@.str.25090 = private unnamed_addr constant [3 x i8] c")\0A\00"
@.str.25136 = private unnamed_addr constant [5 x i8] c"Char\00"
@.str.25142 = private unnamed_addr constant [3 x i8] c"  \00"
@.str.25146 = private unnamed_addr constant [27 x i8] c".right.i8 = load i8, ptr %\00"
@.str.25162 = private unnamed_addr constant [2 x i8] c"\0A\00"
@.str.25164 = private unnamed_addr constant [3 x i8] c"  \00"
@.str.25168 = private unnamed_addr constant [43 x i8] c".right = call ptr @csec_to_string_char(i8 \00"
@.str.25172 = private unnamed_addr constant [12 x i8] c".right.i8)\0A\00"
@.str.25189 = private unnamed_addr constant [11 x i8] c".right.i32\00"
@.str.25192 = private unnamed_addr constant [3 x i8] c"  \00"
@.str.25196 = private unnamed_addr constant [23 x i8] c".right.i64 = sext i32 \00"
@.str.25200 = private unnamed_addr constant [19 x i8] c".right.i32 to i64\0A\00"
@.str.25202 = private unnamed_addr constant [3 x i8] c"  \00"
@.str.25206 = private unnamed_addr constant [43 x i8] c".right = call ptr @csec_to_string_i64(i64 \00"
@.str.25210 = private unnamed_addr constant [13 x i8] c".right.i64)\0A\00"
@.str.25218 = private unnamed_addr constant [3 x i8] c"  \00"
@.str.25222 = private unnamed_addr constant [37 x i8] c" = call ptr @csec_string_concat(ptr \00"
@.str.25226 = private unnamed_addr constant [12 x i8] c".left, ptr \00"
@.str.25230 = private unnamed_addr constant [9 x i8] c".right)\0A\00"
@.str.25254 = private unnamed_addr constant [4 x i8] c"add\00"
@.str.25261 = private unnamed_addr constant [4 x i8] c"sub\00"
@.str.25268 = private unnamed_addr constant [4 x i8] c"mul\00"
@.str.25275 = private unnamed_addr constant [5 x i8] c"sdiv\00"
@.str.25282 = private unnamed_addr constant [5 x i8] c"srem\00"
@.str.25289 = private unnamed_addr constant [4 x i8] c"shl\00"
@.str.25296 = private unnamed_addr constant [5 x i8] c"ashr\00"
@.str.25303 = private unnamed_addr constant [4 x i8] c"and\00"
@.str.25310 = private unnamed_addr constant [3 x i8] c"or\00"
@.str.25317 = private unnamed_addr constant [4 x i8] c"xor\00"
@.str.25332 = private unnamed_addr constant [6 x i8] c".left\00"
@.str.25347 = private unnamed_addr constant [7 x i8] c".right\00"
@.str.25350 = private unnamed_addr constant [3 x i8] c"  \00"
@.str.25354 = private unnamed_addr constant [4 x i8] c" = \00"
@.str.25358 = private unnamed_addr constant [6 x i8] c" i32 \00"
@.str.25362 = private unnamed_addr constant [8 x i8] c".left, \00"
@.str.25366 = private unnamed_addr constant [8 x i8] c".right\0A\00"
@.str.25371 = private unnamed_addr constant [3 x i8] c"  \00"
@.str.25375 = private unnamed_addr constant [17 x i8] c" = add i32 0, 0\0A\00"
@.str.25434 = private unnamed_addr constant [1 x i8] c"\00"
@.str.25471 = private unnamed_addr constant [6 x i8] c".arg0\00"
@.str.25509 = private unnamed_addr constant [6 x i8] c".arg0\00"
@.str.25529 = private unnamed_addr constant [6 x i8] c".arg1\00"
@.str.25567 = private unnamed_addr constant [6 x i8] c".arg0\00"
@.str.25587 = private unnamed_addr constant [6 x i8] c".arg1\00"
@.str.25607 = private unnamed_addr constant [6 x i8] c".arg2\00"
@.str.25622 = private unnamed_addr constant [6 x i8] c".arg0\00"
@.str.25642 = private unnamed_addr constant [6 x i8] c".arg1\00"
@.str.25662 = private unnamed_addr constant [6 x i8] c".arg2\00"
@.str.25682 = private unnamed_addr constant [6 x i8] c".arg3\00"
@.str.25742 = private unnamed_addr constant [1 x i8] c"\00"
@.str.25778 = private unnamed_addr constant [2 x i8] c" \00"
@.str.25841 = private unnamed_addr constant [2 x i8] c" \00"
@.str.25856 = private unnamed_addr constant [3 x i8] c", \00"
@.str.25867 = private unnamed_addr constant [2 x i8] c" \00"
@.str.25944 = private unnamed_addr constant [2 x i8] c" \00"
@.str.25959 = private unnamed_addr constant [3 x i8] c", \00"
@.str.25970 = private unnamed_addr constant [2 x i8] c" \00"
@.str.25985 = private unnamed_addr constant [3 x i8] c", \00"
@.str.25996 = private unnamed_addr constant [2 x i8] c" \00"
@.str.26064 = private unnamed_addr constant [2 x i8] c" \00"
@.str.26079 = private unnamed_addr constant [3 x i8] c", \00"
@.str.26090 = private unnamed_addr constant [2 x i8] c" \00"
@.str.26105 = private unnamed_addr constant [3 x i8] c", \00"
@.str.26116 = private unnamed_addr constant [2 x i8] c" \00"
@.str.26131 = private unnamed_addr constant [3 x i8] c", \00"
@.str.26142 = private unnamed_addr constant [2 x i8] c" \00"
@.str.26174 = private unnamed_addr constant [20 x i8] c"commandLineArgCount\00"
@.str.26179 = private unnamed_addr constant [28 x i8] c"csec_command_line_arg_count\00"
@.str.26188 = private unnamed_addr constant [15 x i8] c"commandLineArg\00"
@.str.26193 = private unnamed_addr constant [22 x i8] c"csec_command_line_arg\00"
@.str.26220 = private unnamed_addr constant [5 x i8] c"kind\00"
@.str.26234 = private unnamed_addr constant [12 x i8] c"tokenKindAt\00"
@.str.26248 = private unnamed_addr constant [19 x i8] c"csec_token_kind_at\00"
@.str.26267 = private unnamed_addr constant [5 x i8] c"Char\00"
@.str.26323 = private unnamed_addr constant [3 x i8] c"  \00"
@.str.26327 = private unnamed_addr constant [17 x i8] c" = add i32 0, 0\0A\00"
@.str.26351 = private unnamed_addr constant [3 x i8] c"  \00"
@.str.26355 = private unnamed_addr constant [15 x i8] c" = add i32 0, \00"
@.str.26364 = private unnamed_addr constant [2 x i8] c"\0A\00"
@.str.26388 = private unnamed_addr constant [3 x i8] c"  \00"
@.str.26392 = private unnamed_addr constant [15 x i8] c" = add i32 0, \00"
@.str.26404 = private unnamed_addr constant [2 x i8] c"\0A\00"
@.str.26473 = private unnamed_addr constant [5 x i8] c"Char\00"
@.str.26478 = private unnamed_addr constant [3 x i8] c"  \00"
@.str.26482 = private unnamed_addr constant [20 x i8] c".c = load i8, ptr %\00"
@.str.26486 = private unnamed_addr constant [2 x i8] c"\0A\00"
@.str.26488 = private unnamed_addr constant [3 x i8] c"  \00"
@.str.26492 = private unnamed_addr constant [12 x i8] c" = zext i8 \00"
@.str.26496 = private unnamed_addr constant [11 x i8] c".c to i32\0A\00"
@.str.26500 = private unnamed_addr constant [3 x i8] c"  \00"
@.str.26504 = private unnamed_addr constant [19 x i8] c" = load i32, ptr %\00"
@.str.26508 = private unnamed_addr constant [2 x i8] c"\0A\00"
@.str.26542 = private unnamed_addr constant [2 x i8] c".\00"
@.str.26557 = private unnamed_addr constant [7 x i8] c"length\00"
@.str.26588 = private unnamed_addr constant [3 x i8] c"  \00"
@.str.26592 = private unnamed_addr constant [23 x i8] c".obj = load ptr, ptr %\00"
@.str.26596 = private unnamed_addr constant [2 x i8] c"\0A\00"
@.str.26598 = private unnamed_addr constant [3 x i8] c"  \00"
@.str.26602 = private unnamed_addr constant [41 x i8] c".i64 = call i64 @csec_string_length(ptr \00"
@.str.26606 = private unnamed_addr constant [7 x i8] c".obj)\0A\00"
@.str.26608 = private unnamed_addr constant [3 x i8] c"  \00"
@.str.26612 = private unnamed_addr constant [14 x i8] c" = trunc i64 \00"
@.str.26616 = private unnamed_addr constant [13 x i8] c".i64 to i32\0A\00"
@.str.26650 = private unnamed_addr constant [2 x i8] c".\00"
@.str.26665 = private unnamed_addr constant [7 x i8] c"charAt\00"
@.str.26680 = private unnamed_addr constant [2 x i8] c"(\00"
@.str.26693 = private unnamed_addr constant [2 x i8] c"(\00"
@.str.26695 = private unnamed_addr constant [2 x i8] c")\00"
@.str.26730 = private unnamed_addr constant [3 x i8] c"  \00"
@.str.26734 = private unnamed_addr constant [23 x i8] c".obj = load ptr, ptr %\00"
@.str.26738 = private unnamed_addr constant [2 x i8] c"\0A\00"
@.str.26754 = private unnamed_addr constant [7 x i8] c".index\00"
@.str.26757 = private unnamed_addr constant [3 x i8] c"  \00"
@.str.26761 = private unnamed_addr constant [40 x i8] c".i8 = call i8 @csec_string_char_at(ptr \00"
@.str.26765 = private unnamed_addr constant [11 x i8] c".obj, i32 \00"
@.str.26769 = private unnamed_addr constant [9 x i8] c".index)\0A\00"
@.str.26771 = private unnamed_addr constant [3 x i8] c"  \00"
@.str.26775 = private unnamed_addr constant [12 x i8] c" = zext i8 \00"
@.str.26779 = private unnamed_addr constant [12 x i8] c".i8 to i32\0A\00"
@.str.26813 = private unnamed_addr constant [2 x i8] c"(\00"
@.str.26826 = private unnamed_addr constant [2 x i8] c"(\00"
@.str.26828 = private unnamed_addr constant [2 x i8] c")\00"
@.str.26874 = private unnamed_addr constant [3 x i8] c"  \00"
@.str.26878 = private unnamed_addr constant [16 x i8] c".i8 = call i8 @\00"
@.str.26885 = private unnamed_addr constant [2 x i8] c"(\00"
@.str.26902 = private unnamed_addr constant [3 x i8] c")\0A\00"
@.str.26904 = private unnamed_addr constant [3 x i8] c"  \00"
@.str.26908 = private unnamed_addr constant [12 x i8] c" = zext i8 \00"
@.str.26912 = private unnamed_addr constant [12 x i8] c".i8 to i32\0A\00"
@.str.26931 = private unnamed_addr constant [3 x i8] c"  \00"
@.str.26935 = private unnamed_addr constant [14 x i8] c" = call i32 @\00"
@.str.26947 = private unnamed_addr constant [2 x i8] c"(\00"
@.str.26964 = private unnamed_addr constant [3 x i8] c")\0A\00"
@.str.27020 = private unnamed_addr constant [4 x i8] c"add\00"
@.str.27027 = private unnamed_addr constant [4 x i8] c"sub\00"
@.str.27034 = private unnamed_addr constant [4 x i8] c"mul\00"
@.str.27041 = private unnamed_addr constant [5 x i8] c"sdiv\00"
@.str.27048 = private unnamed_addr constant [5 x i8] c"srem\00"
@.str.27055 = private unnamed_addr constant [4 x i8] c"shl\00"
@.str.27062 = private unnamed_addr constant [5 x i8] c"ashr\00"
@.str.27069 = private unnamed_addr constant [4 x i8] c"and\00"
@.str.27076 = private unnamed_addr constant [3 x i8] c"or\00"
@.str.27083 = private unnamed_addr constant [4 x i8] c"xor\00"
@.str.27098 = private unnamed_addr constant [6 x i8] c".left\00"
@.str.27113 = private unnamed_addr constant [7 x i8] c".right\00"
@.str.27116 = private unnamed_addr constant [3 x i8] c"  \00"
@.str.27120 = private unnamed_addr constant [4 x i8] c" = \00"
@.str.27124 = private unnamed_addr constant [6 x i8] c" i32 \00"
@.str.27128 = private unnamed_addr constant [8 x i8] c".left, \00"
@.str.27132 = private unnamed_addr constant [8 x i8] c".right\0A\00"
@.str.27137 = private unnamed_addr constant [3 x i8] c"  \00"
@.str.27141 = private unnamed_addr constant [17 x i8] c" = add i32 0, 0\0A\00"
@.str.27199 = private unnamed_addr constant [7 x i8] c".addr.\00"
@.str.27208 = private unnamed_addr constant [2 x i8] c"%\00"
@.str.27212 = private unnamed_addr constant [7 x i8] c".init.\00"
@.str.27224 = private unnamed_addr constant [4 x i8] c"  %\00"
@.str.27228 = private unnamed_addr constant [15 x i8] c" = alloca i32\0A\00"
@.str.27243 = private unnamed_addr constant [13 x i8] c"  store i32 \00"
@.str.27247 = private unnamed_addr constant [8 x i8] c", ptr %\00"
@.str.27251 = private unnamed_addr constant [2 x i8] c"\0A\00"
@.str.27255 = private unnamed_addr constant [4 x i8] c"  %\00"
@.str.27259 = private unnamed_addr constant [15 x i8] c" = alloca i32\0A\00"
@.str.27261 = private unnamed_addr constant [21 x i8] c"  store i32 0, ptr %\00"
@.str.27265 = private unnamed_addr constant [2 x i8] c"\0A\00"
@.str.27308 = private unnamed_addr constant [2 x i8] c"0\00"
@.str.27361 = private unnamed_addr constant [2 x i8] c"%\00"
@.str.27370 = private unnamed_addr constant [7 x i8] c".lval.\00"
@.str.27376 = private unnamed_addr constant [6 x i8] c"%ltmp\00"
@.str.27458 = private unnamed_addr constant [4 x i8] c"  %\00"
@.str.27462 = private unnamed_addr constant [7 x i8] c".lval.\00"
@.str.27466 = private unnamed_addr constant [19 x i8] c" = load i64, ptr %\00"
@.str.27470 = private unnamed_addr constant [2 x i8] c"\0A\00"
@.str.27474 = private unnamed_addr constant [1 x i8] c"\00"
@.str.27521 = private unnamed_addr constant [3 x i8] c"  \00"
@.str.27525 = private unnamed_addr constant [17 x i8] c" = add i64 0, 0\0A\00"
@.str.27549 = private unnamed_addr constant [3 x i8] c"  \00"
@.str.27553 = private unnamed_addr constant [15 x i8] c" = add i64 0, \00"
@.str.27562 = private unnamed_addr constant [2 x i8] c"\0A\00"
@.str.27586 = private unnamed_addr constant [3 x i8] c"  \00"
@.str.27590 = private unnamed_addr constant [19 x i8] c" = load i64, ptr %\00"
@.str.27606 = private unnamed_addr constant [2 x i8] c"\0A\00"
@.str.27640 = private unnamed_addr constant [2 x i8] c"(\00"
@.str.27653 = private unnamed_addr constant [2 x i8] c"(\00"
@.str.27655 = private unnamed_addr constant [2 x i8] c")\00"
@.str.27679 = private unnamed_addr constant [3 x i8] c"  \00"
@.str.27683 = private unnamed_addr constant [14 x i8] c" = call i64 @\00"
@.str.27695 = private unnamed_addr constant [2 x i8] c"(\00"
@.str.27712 = private unnamed_addr constant [3 x i8] c")\0A\00"
@.str.27768 = private unnamed_addr constant [4 x i8] c"add\00"
@.str.27775 = private unnamed_addr constant [4 x i8] c"sub\00"
@.str.27782 = private unnamed_addr constant [4 x i8] c"mul\00"
@.str.27789 = private unnamed_addr constant [5 x i8] c"sdiv\00"
@.str.27796 = private unnamed_addr constant [5 x i8] c"srem\00"
@.str.27803 = private unnamed_addr constant [4 x i8] c"shl\00"
@.str.27810 = private unnamed_addr constant [5 x i8] c"ashr\00"
@.str.27817 = private unnamed_addr constant [4 x i8] c"and\00"
@.str.27824 = private unnamed_addr constant [3 x i8] c"or\00"
@.str.27831 = private unnamed_addr constant [4 x i8] c"xor\00"
@.str.27856 = private unnamed_addr constant [3 x i8] c"  \00"
@.str.27860 = private unnamed_addr constant [4 x i8] c" = \00"
@.str.27864 = private unnamed_addr constant [6 x i8] c" i64 \00"
@.str.27875 = private unnamed_addr constant [3 x i8] c", \00"
@.str.27888 = private unnamed_addr constant [2 x i8] c"\0A\00"
@.str.27893 = private unnamed_addr constant [3 x i8] c"  \00"
@.str.27897 = private unnamed_addr constant [17 x i8] c" = add i64 0, 0\0A\00"
@.str.27955 = private unnamed_addr constant [7 x i8] c".addr.\00"
@.str.27964 = private unnamed_addr constant [2 x i8] c"%\00"
@.str.27968 = private unnamed_addr constant [8 x i8] c".linit.\00"
@.str.27980 = private unnamed_addr constant [4 x i8] c"  %\00"
@.str.27984 = private unnamed_addr constant [15 x i8] c" = alloca i64\0A\00"
@.str.27999 = private unnamed_addr constant [13 x i8] c"  store i64 \00"
@.str.28003 = private unnamed_addr constant [8 x i8] c", ptr %\00"
@.str.28007 = private unnamed_addr constant [2 x i8] c"\0A\00"
@.str.28011 = private unnamed_addr constant [4 x i8] c"  %\00"
@.str.28015 = private unnamed_addr constant [15 x i8] c" = alloca i64\0A\00"
@.str.28017 = private unnamed_addr constant [21 x i8] c"  store i64 0, ptr %\00"
@.str.28021 = private unnamed_addr constant [2 x i8] c"\0A\00"
@.str.28064 = private unnamed_addr constant [13 x i8] c"0.000000e+00\00"
@.str.28130 = private unnamed_addr constant [2 x i8] c"%\00"
@.str.28139 = private unnamed_addr constant [7 x i8] c".fval.\00"
@.str.28145 = private unnamed_addr constant [6 x i8] c"%ftmp\00"
@.str.28227 = private unnamed_addr constant [4 x i8] c"  %\00"
@.str.28231 = private unnamed_addr constant [7 x i8] c".fval.\00"
@.str.28235 = private unnamed_addr constant [22 x i8] c" = load double, ptr %\00"
@.str.28239 = private unnamed_addr constant [2 x i8] c"\0A\00"
@.str.28243 = private unnamed_addr constant [1 x i8] c"\00"
@.str.28290 = private unnamed_addr constant [3 x i8] c"  \00"
@.str.28294 = private unnamed_addr constant [43 x i8] c" = fadd double 0.000000e+00, 0.000000e+00\0A\00"
@.str.28331 = private unnamed_addr constant [3 x i8] c"  \00"
@.str.28335 = private unnamed_addr constant [30 x i8] c" = fadd double 0.000000e+00, \00"
@.str.28344 = private unnamed_addr constant [2 x i8] c"\0A\00"
@.str.28368 = private unnamed_addr constant [3 x i8] c"  \00"
@.str.28372 = private unnamed_addr constant [22 x i8] c" = load double, ptr %\00"
@.str.28388 = private unnamed_addr constant [2 x i8] c"\0A\00"
@.str.28422 = private unnamed_addr constant [2 x i8] c"(\00"
@.str.28435 = private unnamed_addr constant [2 x i8] c"(\00"
@.str.28437 = private unnamed_addr constant [2 x i8] c")\00"
@.str.28461 = private unnamed_addr constant [3 x i8] c"  \00"
@.str.28465 = private unnamed_addr constant [17 x i8] c" = call double @\00"
@.str.28477 = private unnamed_addr constant [2 x i8] c"(\00"
@.str.28494 = private unnamed_addr constant [3 x i8] c")\0A\00"
@.str.28546 = private unnamed_addr constant [1 x i8] c"\00"
@.str.28554 = private unnamed_addr constant [2 x i8] c"+\00"
@.str.28560 = private unnamed_addr constant [5 x i8] c"fadd\00"
@.str.28569 = private unnamed_addr constant [2 x i8] c"-\00"
@.str.28575 = private unnamed_addr constant [5 x i8] c"fsub\00"
@.str.28584 = private unnamed_addr constant [2 x i8] c"*\00"
@.str.28590 = private unnamed_addr constant [5 x i8] c"fmul\00"
@.str.28599 = private unnamed_addr constant [2 x i8] c"/\00"
@.str.28605 = private unnamed_addr constant [5 x i8] c"fdiv\00"
@.str.28638 = private unnamed_addr constant [3 x i8] c"  \00"
@.str.28642 = private unnamed_addr constant [4 x i8] c" = \00"
@.str.28646 = private unnamed_addr constant [9 x i8] c" double \00"
@.str.28657 = private unnamed_addr constant [3 x i8] c", \00"
@.str.28670 = private unnamed_addr constant [2 x i8] c"\0A\00"
@.str.28675 = private unnamed_addr constant [3 x i8] c"  \00"
@.str.28679 = private unnamed_addr constant [43 x i8] c" = fadd double 0.000000e+00, 0.000000e+00\0A\00"
@.str.28737 = private unnamed_addr constant [7 x i8] c".addr.\00"
@.str.28746 = private unnamed_addr constant [2 x i8] c"%\00"
@.str.28750 = private unnamed_addr constant [8 x i8] c".finit.\00"
@.str.28762 = private unnamed_addr constant [4 x i8] c"  %\00"
@.str.28766 = private unnamed_addr constant [18 x i8] c" = alloca double\0A\00"
@.str.28781 = private unnamed_addr constant [16 x i8] c"  store double \00"
@.str.28785 = private unnamed_addr constant [8 x i8] c", ptr %\00"
@.str.28789 = private unnamed_addr constant [2 x i8] c"\0A\00"
@.str.28793 = private unnamed_addr constant [4 x i8] c"  %\00"
@.str.28797 = private unnamed_addr constant [18 x i8] c" = alloca double\0A\00"
@.str.28799 = private unnamed_addr constant [35 x i8] c"  store double 0.000000e+00, ptr %\00"
@.str.28803 = private unnamed_addr constant [2 x i8] c"\0A\00"
@.str.28861 = private unnamed_addr constant [7 x i8] c".addr.\00"
@.str.28870 = private unnamed_addr constant [2 x i8] c"%\00"
@.str.28874 = private unnamed_addr constant [8 x i8] c".cinit.\00"
@.str.28934 = private unnamed_addr constant [4 x i8] c"  %\00"
@.str.28938 = private unnamed_addr constant [14 x i8] c" = alloca i8\0A\00"
@.str.28940 = private unnamed_addr constant [12 x i8] c"  store i8 \00"
@.str.28952 = private unnamed_addr constant [8 x i8] c", ptr %\00"
@.str.28956 = private unnamed_addr constant [2 x i8] c"\0A\00"
@.str.28999 = private unnamed_addr constant [4 x i8] c"  %\00"
@.str.29003 = private unnamed_addr constant [14 x i8] c" = alloca i8\0A\00"
@.str.29005 = private unnamed_addr constant [3 x i8] c"  \00"
@.str.29009 = private unnamed_addr constant [18 x i8] c" = load i8, ptr %\00"
@.str.29013 = private unnamed_addr constant [2 x i8] c"\0A\00"
@.str.29015 = private unnamed_addr constant [12 x i8] c"  store i8 \00"
@.str.29019 = private unnamed_addr constant [8 x i8] c", ptr %\00"
@.str.29023 = private unnamed_addr constant [2 x i8] c"\0A\00"
@.str.29057 = private unnamed_addr constant [2 x i8] c".\00"
@.str.29072 = private unnamed_addr constant [7 x i8] c"charAt\00"
@.str.29087 = private unnamed_addr constant [2 x i8] c"(\00"
@.str.29100 = private unnamed_addr constant [2 x i8] c"(\00"
@.str.29102 = private unnamed_addr constant [2 x i8] c")\00"
@.str.29130 = private unnamed_addr constant [4 x i8] c"  %\00"
@.str.29134 = private unnamed_addr constant [14 x i8] c" = alloca i8\0A\00"
@.str.29136 = private unnamed_addr constant [3 x i8] c"  \00"
@.str.29140 = private unnamed_addr constant [23 x i8] c".obj = load ptr, ptr %\00"
@.str.29144 = private unnamed_addr constant [2 x i8] c"\0A\00"
@.str.29160 = private unnamed_addr constant [7 x i8] c".index\00"
@.str.29163 = private unnamed_addr constant [3 x i8] c"  \00"
@.str.29167 = private unnamed_addr constant [37 x i8] c" = call i8 @csec_string_char_at(ptr \00"
@.str.29171 = private unnamed_addr constant [11 x i8] c".obj, i32 \00"
@.str.29175 = private unnamed_addr constant [9 x i8] c".index)\0A\00"
@.str.29177 = private unnamed_addr constant [12 x i8] c"  store i8 \00"
@.str.29181 = private unnamed_addr constant [8 x i8] c", ptr %\00"
@.str.29185 = private unnamed_addr constant [2 x i8] c"\0A\00"
@.str.29219 = private unnamed_addr constant [2 x i8] c"(\00"
@.str.29232 = private unnamed_addr constant [2 x i8] c"(\00"
@.str.29234 = private unnamed_addr constant [2 x i8] c")\00"
@.str.29243 = private unnamed_addr constant [4 x i8] c"  %\00"
@.str.29247 = private unnamed_addr constant [14 x i8] c" = alloca i8\0A\00"
@.str.29264 = private unnamed_addr constant [3 x i8] c"  \00"
@.str.29268 = private unnamed_addr constant [13 x i8] c" = call i8 @\00"
@.str.29280 = private unnamed_addr constant [2 x i8] c"(\00"
@.str.29297 = private unnamed_addr constant [3 x i8] c")\0A\00"
@.str.29299 = private unnamed_addr constant [12 x i8] c"  store i8 \00"
@.str.29303 = private unnamed_addr constant [8 x i8] c", ptr %\00"
@.str.29307 = private unnamed_addr constant [2 x i8] c"\0A\00"
@.str.29312 = private unnamed_addr constant [4 x i8] c"  %\00"
@.str.29316 = private unnamed_addr constant [14 x i8] c" = alloca i8\0A\00"
@.str.29318 = private unnamed_addr constant [20 x i8] c"  store i8 0, ptr %\00"
@.str.29322 = private unnamed_addr constant [2 x i8] c"\0A\00"
@.str.29378 = private unnamed_addr constant [1 x i8] c"\00"
@.str.29425 = private unnamed_addr constant [2 x i8] c"=\00"
@.str.29432 = private unnamed_addr constant [3 x i8] c"<-\00"
@.str.29441 = private unnamed_addr constant [2 x i8] c"%\00"
@.str.29445 = private unnamed_addr constant [10 x i8] c".fassign.\00"
@.str.29463 = private unnamed_addr constant [16 x i8] c"  store double \00"
@.str.29467 = private unnamed_addr constant [8 x i8] c", ptr %\00"
@.str.29471 = private unnamed_addr constant [2 x i8] c"\0A\00"
@.str.29475 = private unnamed_addr constant [1 x i8] c"\00"
@.str.29531 = private unnamed_addr constant [1 x i8] c"\00"
@.str.29632 = private unnamed_addr constant [4 x i8] c"  %\00"
@.str.29636 = private unnamed_addr constant [10 x i8] c".passign.\00"
@.str.29640 = private unnamed_addr constant [28 x i8] c" = getelementptr inbounds [\00"
@.str.29644 = private unnamed_addr constant [19 x i8] c" x i8], ptr @.str.\00"
@.str.29648 = private unnamed_addr constant [16 x i8] c", i32 0, i32 0\0A\00"
@.str.29650 = private unnamed_addr constant [14 x i8] c"  store ptr %\00"
@.str.29654 = private unnamed_addr constant [10 x i8] c".passign.\00"
@.str.29658 = private unnamed_addr constant [8 x i8] c", ptr %\00"
@.str.29662 = private unnamed_addr constant [2 x i8] c"\0A\00"
@.str.29705 = private unnamed_addr constant [4 x i8] c"  %\00"
@.str.29709 = private unnamed_addr constant [10 x i8] c".passign.\00"
@.str.29713 = private unnamed_addr constant [19 x i8] c" = load ptr, ptr %\00"
@.str.29717 = private unnamed_addr constant [2 x i8] c"\0A\00"
@.str.29719 = private unnamed_addr constant [14 x i8] c"  store ptr %\00"
@.str.29723 = private unnamed_addr constant [10 x i8] c".passign.\00"
@.str.29727 = private unnamed_addr constant [8 x i8] c", ptr %\00"
@.str.29731 = private unnamed_addr constant [2 x i8] c"\0A\00"
@.str.29765 = private unnamed_addr constant [2 x i8] c"(\00"
@.str.29778 = private unnamed_addr constant [2 x i8] c"(\00"
@.str.29780 = private unnamed_addr constant [2 x i8] c")\00"
@.str.29793 = private unnamed_addr constant [2 x i8] c"%\00"
@.str.29797 = private unnamed_addr constant [10 x i8] c".passign.\00"
@.str.29817 = private unnamed_addr constant [3 x i8] c"  \00"
@.str.29821 = private unnamed_addr constant [14 x i8] c" = call ptr @\00"
@.str.29833 = private unnamed_addr constant [2 x i8] c"(\00"
@.str.29850 = private unnamed_addr constant [3 x i8] c")\0A\00"
@.str.29852 = private unnamed_addr constant [13 x i8] c"  store ptr \00"
@.str.29856 = private unnamed_addr constant [8 x i8] c", ptr %\00"
@.str.29860 = private unnamed_addr constant [2 x i8] c"\0A\00"
@.str.29893 = private unnamed_addr constant [2 x i8] c"+\00"
@.str.29913 = private unnamed_addr constant [2 x i8] c"%\00"
@.str.29917 = private unnamed_addr constant [10 x i8] c".passign.\00"
@.str.29959 = private unnamed_addr constant [1 x i8] c"\00"
@.str.29995 = private unnamed_addr constant [3 x i8] c"  \00"
@.str.29999 = private unnamed_addr constant [34 x i8] c".right = getelementptr inbounds [\00"
@.str.30009 = private unnamed_addr constant [19 x i8] c" x i8], ptr @.str.\00"
@.str.30013 = private unnamed_addr constant [16 x i8] c", i32 0, i32 0\0A\00"
@.str.30039 = private unnamed_addr constant [3 x i8] c"  \00"
@.str.30043 = private unnamed_addr constant [25 x i8] c".right = load ptr, ptr %\00"
@.str.30059 = private unnamed_addr constant [2 x i8] c"\0A\00"
@.str.30094 = private unnamed_addr constant [2 x i8] c"(\00"
@.str.30107 = private unnamed_addr constant [2 x i8] c"(\00"
@.str.30109 = private unnamed_addr constant [2 x i8] c")\00"
@.str.30134 = private unnamed_addr constant [3 x i8] c"  \00"
@.str.30138 = private unnamed_addr constant [20 x i8] c".right = call ptr @\00"
@.str.30150 = private unnamed_addr constant [2 x i8] c"(\00"
@.str.30167 = private unnamed_addr constant [3 x i8] c")\0A\00"
@.str.30180 = private unnamed_addr constant [3 x i8] c"  \00"
@.str.30184 = private unnamed_addr constant [24 x i8] c".left = load ptr, ptr %\00"
@.str.30188 = private unnamed_addr constant [2 x i8] c"\0A\00"
@.str.30192 = private unnamed_addr constant [3 x i8] c"  \00"
@.str.30196 = private unnamed_addr constant [37 x i8] c" = call ptr @csec_string_concat(ptr \00"
@.str.30200 = private unnamed_addr constant [12 x i8] c".left, ptr \00"
@.str.30204 = private unnamed_addr constant [9 x i8] c".right)\0A\00"
@.str.30206 = private unnamed_addr constant [13 x i8] c"  store ptr \00"
@.str.30210 = private unnamed_addr constant [8 x i8] c", ptr %\00"
@.str.30214 = private unnamed_addr constant [2 x i8] c"\0A\00"
@.str.30219 = private unnamed_addr constant [1 x i8] c"\00"
@.str.30275 = private unnamed_addr constant [1 x i8] c"\00"
@.str.30353 = private unnamed_addr constant [12 x i8] c"  store i8 \00"
@.str.30365 = private unnamed_addr constant [8 x i8] c", ptr %\00"
@.str.30369 = private unnamed_addr constant [2 x i8] c"\0A\00"
@.str.30412 = private unnamed_addr constant [4 x i8] c"  %\00"
@.str.30416 = private unnamed_addr constant [10 x i8] c".cassign.\00"
@.str.30420 = private unnamed_addr constant [18 x i8] c" = load i8, ptr %\00"
@.str.30424 = private unnamed_addr constant [2 x i8] c"\0A\00"
@.str.30426 = private unnamed_addr constant [13 x i8] c"  store i8 %\00"
@.str.30430 = private unnamed_addr constant [10 x i8] c".cassign.\00"
@.str.30434 = private unnamed_addr constant [8 x i8] c", ptr %\00"
@.str.30438 = private unnamed_addr constant [2 x i8] c"\0A\00"
@.str.30472 = private unnamed_addr constant [2 x i8] c".\00"
@.str.30487 = private unnamed_addr constant [7 x i8] c"charAt\00"
@.str.30502 = private unnamed_addr constant [2 x i8] c"(\00"
@.str.30515 = private unnamed_addr constant [2 x i8] c"(\00"
@.str.30517 = private unnamed_addr constant [2 x i8] c")\00"
@.str.30549 = private unnamed_addr constant [2 x i8] c"%\00"
@.str.30553 = private unnamed_addr constant [10 x i8] c".cassign.\00"
@.str.30558 = private unnamed_addr constant [3 x i8] c"  \00"
@.str.30562 = private unnamed_addr constant [23 x i8] c".obj = load ptr, ptr %\00"
@.str.30566 = private unnamed_addr constant [2 x i8] c"\0A\00"
@.str.30582 = private unnamed_addr constant [7 x i8] c".index\00"
@.str.30585 = private unnamed_addr constant [3 x i8] c"  \00"
@.str.30589 = private unnamed_addr constant [37 x i8] c" = call i8 @csec_string_char_at(ptr \00"
@.str.30593 = private unnamed_addr constant [11 x i8] c".obj, i32 \00"
@.str.30597 = private unnamed_addr constant [9 x i8] c".index)\0A\00"
@.str.30599 = private unnamed_addr constant [12 x i8] c"  store i8 \00"
@.str.30603 = private unnamed_addr constant [8 x i8] c", ptr %\00"
@.str.30607 = private unnamed_addr constant [2 x i8] c"\0A\00"
@.str.30641 = private unnamed_addr constant [2 x i8] c"(\00"
@.str.30654 = private unnamed_addr constant [2 x i8] c"(\00"
@.str.30656 = private unnamed_addr constant [2 x i8] c")\00"
@.str.30669 = private unnamed_addr constant [2 x i8] c"%\00"
@.str.30673 = private unnamed_addr constant [10 x i8] c".cassign.\00"
@.str.30693 = private unnamed_addr constant [3 x i8] c"  \00"
@.str.30697 = private unnamed_addr constant [13 x i8] c" = call i8 @\00"
@.str.30709 = private unnamed_addr constant [2 x i8] c"(\00"
@.str.30726 = private unnamed_addr constant [3 x i8] c")\0A\00"
@.str.30728 = private unnamed_addr constant [12 x i8] c"  store i8 \00"
@.str.30732 = private unnamed_addr constant [8 x i8] c", ptr %\00"
@.str.30736 = private unnamed_addr constant [2 x i8] c"\0A\00"
@.str.30740 = private unnamed_addr constant [1 x i8] c"\00"
@.str.30796 = private unnamed_addr constant [1 x i8] c"\00"
@.str.30843 = private unnamed_addr constant [2 x i8] c"=\00"
@.str.30850 = private unnamed_addr constant [3 x i8] c"<-\00"
@.str.30859 = private unnamed_addr constant [2 x i8] c"%\00"
@.str.30863 = private unnamed_addr constant [9 x i8] c".assign.\00"
@.str.30881 = private unnamed_addr constant [13 x i8] c"  store i32 \00"
@.str.30885 = private unnamed_addr constant [8 x i8] c", ptr %\00"
@.str.30889 = private unnamed_addr constant [2 x i8] c"\0A\00"
@.str.30912 = private unnamed_addr constant [3 x i8] c"%=\00"
@.str.30918 = private unnamed_addr constant [2 x i8] c"%\00"
@.str.30922 = private unnamed_addr constant [4 x i8] c"  %\00"
@.str.30926 = private unnamed_addr constant [6 x i8] c".old.\00"
@.str.30930 = private unnamed_addr constant [19 x i8] c" = load i32, ptr %\00"
@.str.30934 = private unnamed_addr constant [2 x i8] c"\0A\00"
@.str.30946 = private unnamed_addr constant [2 x i8] c"%\00"
@.str.30950 = private unnamed_addr constant [6 x i8] c".rhs.\00"
@.str.30955 = private unnamed_addr constant [4 x i8] c"  %\00"
@.str.30959 = private unnamed_addr constant [7 x i8] c".next.\00"
@.str.30963 = private unnamed_addr constant [4 x i8] c" = \00"
@.str.30970 = private unnamed_addr constant [7 x i8] c" i32 %\00"
@.str.30974 = private unnamed_addr constant [6 x i8] c".old.\00"
@.str.30978 = private unnamed_addr constant [4 x i8] c", %\00"
@.str.30982 = private unnamed_addr constant [6 x i8] c".rhs.\00"
@.str.30986 = private unnamed_addr constant [2 x i8] c"\0A\00"
@.str.30988 = private unnamed_addr constant [14 x i8] c"  store i32 %\00"
@.str.30992 = private unnamed_addr constant [7 x i8] c".next.\00"
@.str.30996 = private unnamed_addr constant [8 x i8] c", ptr %\00"
@.str.31000 = private unnamed_addr constant [2 x i8] c"\0A\00"
@.str.31056 = private unnamed_addr constant [1 x i8] c"\00"
@.str.31103 = private unnamed_addr constant [2 x i8] c"=\00"
@.str.31110 = private unnamed_addr constant [3 x i8] c"<-\00"
@.str.31119 = private unnamed_addr constant [2 x i8] c"%\00"
@.str.31123 = private unnamed_addr constant [10 x i8] c".lassign.\00"
@.str.31141 = private unnamed_addr constant [13 x i8] c"  store i64 \00"
@.str.31145 = private unnamed_addr constant [8 x i8] c", ptr %\00"
@.str.31149 = private unnamed_addr constant [2 x i8] c"\0A\00"
@.str.31172 = private unnamed_addr constant [3 x i8] c"%=\00"
@.str.31178 = private unnamed_addr constant [2 x i8] c"%\00"
@.str.31182 = private unnamed_addr constant [4 x i8] c"  %\00"
@.str.31186 = private unnamed_addr constant [7 x i8] c".lold.\00"
@.str.31190 = private unnamed_addr constant [19 x i8] c" = load i64, ptr %\00"
@.str.31194 = private unnamed_addr constant [2 x i8] c"\0A\00"
@.str.31206 = private unnamed_addr constant [2 x i8] c"%\00"
@.str.31210 = private unnamed_addr constant [7 x i8] c".lrhs.\00"
@.str.31215 = private unnamed_addr constant [4 x i8] c"  %\00"
@.str.31219 = private unnamed_addr constant [8 x i8] c".lnext.\00"
@.str.31223 = private unnamed_addr constant [4 x i8] c" = \00"
@.str.31230 = private unnamed_addr constant [7 x i8] c" i64 %\00"
@.str.31234 = private unnamed_addr constant [7 x i8] c".lold.\00"
@.str.31238 = private unnamed_addr constant [4 x i8] c", %\00"
@.str.31242 = private unnamed_addr constant [7 x i8] c".lrhs.\00"
@.str.31246 = private unnamed_addr constant [2 x i8] c"\0A\00"
@.str.31248 = private unnamed_addr constant [14 x i8] c"  store i64 %\00"
@.str.31252 = private unnamed_addr constant [8 x i8] c".lnext.\00"
@.str.31256 = private unnamed_addr constant [8 x i8] c", ptr %\00"
@.str.31260 = private unnamed_addr constant [2 x i8] c"\0A\00"
@.str.31311 = private unnamed_addr constant [2 x i8] c"(\00"
@.str.31322 = private unnamed_addr constant [2 x i8] c"(\00"
@.str.31324 = private unnamed_addr constant [2 x i8] c")\00"
@.str.31361 = private unnamed_addr constant [2 x i8] c"!\00"
@.str.31372 = private unnamed_addr constant [5 x i8] c".not\00"
@.str.31388 = private unnamed_addr constant [3 x i8] c"  \00"
@.str.31392 = private unnamed_addr constant [11 x i8] c" = xor i1 \00"
@.str.31396 = private unnamed_addr constant [12 x i8] c".not, true\0A\00"
@.str.31443 = private unnamed_addr constant [6 x i8] c"icmp_\00"
@.str.31518 = private unnamed_addr constant [3 x i8] c"  \00"
@.str.31522 = private unnamed_addr constant [26 x i8] c".left.i8 = load i8, ptr %\00"
@.str.31526 = private unnamed_addr constant [2 x i8] c"\0A\00"
@.str.31528 = private unnamed_addr constant [3 x i8] c"  \00"
@.str.31532 = private unnamed_addr constant [9 x i8] c" = icmp \00"
@.str.31536 = private unnamed_addr constant [5 x i8] c" i8 \00"
@.str.31540 = private unnamed_addr constant [11 x i8] c".left.i8, \00"
@.str.31554 = private unnamed_addr constant [2 x i8] c"\0A\00"
@.str.31620 = private unnamed_addr constant [3 x i8] c"  \00"
@.str.31624 = private unnamed_addr constant [27 x i8] c".right.i8 = load i8, ptr %\00"
@.str.31628 = private unnamed_addr constant [2 x i8] c"\0A\00"
@.str.31630 = private unnamed_addr constant [3 x i8] c"  \00"
@.str.31634 = private unnamed_addr constant [9 x i8] c" = icmp \00"
@.str.31638 = private unnamed_addr constant [5 x i8] c" i8 \00"
@.str.31650 = private unnamed_addr constant [3 x i8] c", \00"
@.str.31654 = private unnamed_addr constant [11 x i8] c".right.i8\0A\00"
@.str.31664 = private unnamed_addr constant [10 x i8] c".left.i32\00"
@.str.31673 = private unnamed_addr constant [11 x i8] c".right.i32\00"
@.str.31700 = private unnamed_addr constant [3 x i8] c"  \00"
@.str.31704 = private unnamed_addr constant [9 x i8] c" = icmp \00"
@.str.31708 = private unnamed_addr constant [6 x i8] c" i32 \00"
@.str.31712 = private unnamed_addr constant [12 x i8] c".left.i32, \00"
@.str.31716 = private unnamed_addr constant [12 x i8] c".right.i32\0A\00"
@.str.31751 = private unnamed_addr constant [5 x i8] c"true\00"
@.str.31756 = private unnamed_addr constant [3 x i8] c"  \00"
@.str.31760 = private unnamed_addr constant [26 x i8] c" = icmp eq i1 true, true\0A\00"
@.str.31764 = private unnamed_addr constant [3 x i8] c"  \00"
@.str.31768 = private unnamed_addr constant [27 x i8] c" = icmp eq i1 false, true\0A\00"
@.str.31792 = private unnamed_addr constant [3 x i8] c"  \00"
@.str.31796 = private unnamed_addr constant [18 x i8] c" = load i1, ptr %\00"
@.str.31812 = private unnamed_addr constant [2 x i8] c"\0A\00"
@.str.31846 = private unnamed_addr constant [2 x i8] c".\00"
@.str.31861 = private unnamed_addr constant [11 x i8] c"startsWith\00"
@.str.31876 = private unnamed_addr constant [2 x i8] c"(\00"
@.str.31889 = private unnamed_addr constant [2 x i8] c"(\00"
@.str.31891 = private unnamed_addr constant [2 x i8] c")\00"
@.str.31925 = private unnamed_addr constant [8 x i8] c".needle\00"
@.str.31928 = private unnamed_addr constant [3 x i8] c"  \00"
@.str.31932 = private unnamed_addr constant [23 x i8] c".obj = load ptr, ptr %\00"
@.str.31936 = private unnamed_addr constant [2 x i8] c"\0A\00"
@.str.31953 = private unnamed_addr constant [3 x i8] c"  \00"
@.str.31957 = private unnamed_addr constant [46 x i8] c".i32 = call i32 @csec_string_starts_with(ptr \00"
@.str.31961 = private unnamed_addr constant [11 x i8] c".obj, ptr \00"
@.str.31965 = private unnamed_addr constant [10 x i8] c".needle)\0A\00"
@.str.31967 = private unnamed_addr constant [3 x i8] c"  \00"
@.str.31971 = private unnamed_addr constant [16 x i8] c" = icmp ne i32 \00"
@.str.31975 = private unnamed_addr constant [9 x i8] c".i32, 0\0A\00"
@.str.32009 = private unnamed_addr constant [2 x i8] c"(\00"
@.str.32022 = private unnamed_addr constant [2 x i8] c"(\00"
@.str.32024 = private unnamed_addr constant [2 x i8] c")\00"
@.str.32048 = private unnamed_addr constant [3 x i8] c"  \00"
@.str.32052 = private unnamed_addr constant [13 x i8] c" = call i1 @\00"
@.str.32064 = private unnamed_addr constant [2 x i8] c"(\00"
@.str.32081 = private unnamed_addr constant [3 x i8] c")\0A\00"
@.str.32085 = private unnamed_addr constant [3 x i8] c"  \00"
@.str.32089 = private unnamed_addr constant [21 x i8] c" = icmp eq i32 0, 0\0A\00"
@.str.32136 = private unnamed_addr constant [3 x i8] c"  \00"
@.str.32140 = private unnamed_addr constant [27 x i8] c" = icmp eq i1 false, true\0A\00"
@.str.32155 = private unnamed_addr constant [2 x i8] c"(\00"
@.str.32166 = private unnamed_addr constant [2 x i8] c"(\00"
@.str.32168 = private unnamed_addr constant [2 x i8] c")\00"
@.str.32205 = private unnamed_addr constant [2 x i8] c"!\00"
@.str.32216 = private unnamed_addr constant [5 x i8] c".not\00"
@.str.32232 = private unnamed_addr constant [3 x i8] c"  \00"
@.str.32236 = private unnamed_addr constant [11 x i8] c" = xor i1 \00"
@.str.32240 = private unnamed_addr constant [12 x i8] c".not, true\0A\00"
@.str.32274 = private unnamed_addr constant [5 x i8] c"true\00"
@.str.32279 = private unnamed_addr constant [3 x i8] c"  \00"
@.str.32283 = private unnamed_addr constant [26 x i8] c" = icmp eq i1 true, true\0A\00"
@.str.32287 = private unnamed_addr constant [3 x i8] c"  \00"
@.str.32291 = private unnamed_addr constant [27 x i8] c" = icmp eq i1 false, true\0A\00"
@.str.32315 = private unnamed_addr constant [3 x i8] c"  \00"
@.str.32319 = private unnamed_addr constant [18 x i8] c" = load i1, ptr %\00"
@.str.32335 = private unnamed_addr constant [2 x i8] c"\0A\00"
@.str.32380 = private unnamed_addr constant [14 x i8] c"csec_token_is\00"
@.str.32395 = private unnamed_addr constant [2 x i8] c"(\00"
@.str.32408 = private unnamed_addr constant [2 x i8] c"(\00"
@.str.32410 = private unnamed_addr constant [2 x i8] c")\00"
@.str.32454 = private unnamed_addr constant [2 x i8] c",\00"
@.str.32474 = private unnamed_addr constant [2 x i8] c",\00"
@.str.32494 = private unnamed_addr constant [2 x i8] c",\00"
@.str.32617 = private unnamed_addr constant [3 x i8] c"  \00"
@.str.32621 = private unnamed_addr constant [29 x i8] c".call.arg0 = load ptr, ptr %\00"
@.str.32625 = private unnamed_addr constant [2 x i8] c"\0A\00"
@.str.32639 = private unnamed_addr constant [11 x i8] c".call.arg1\00"
@.str.32642 = private unnamed_addr constant [3 x i8] c"  \00"
@.str.32646 = private unnamed_addr constant [28 x i8] c".call.arg2 = load i8, ptr %\00"
@.str.32650 = private unnamed_addr constant [2 x i8] c"\0A\00"
@.str.32652 = private unnamed_addr constant [3 x i8] c"  \00"
@.str.32656 = private unnamed_addr constant [29 x i8] c".call.arg3 = load ptr, ptr %\00"
@.str.32660 = private unnamed_addr constant [2 x i8] c"\0A\00"
@.str.32662 = private unnamed_addr constant [3 x i8] c"  \00"
@.str.32666 = private unnamed_addr constant [37 x i8] c".call = call i32 @csec_token_is(ptr \00"
@.str.32670 = private unnamed_addr constant [17 x i8] c".call.arg0, i32 \00"
@.str.32674 = private unnamed_addr constant [16 x i8] c".call.arg1, i8 \00"
@.str.32678 = private unnamed_addr constant [17 x i8] c".call.arg2, ptr \00"
@.str.32682 = private unnamed_addr constant [13 x i8] c".call.arg3)\0A\00"
@.str.32684 = private unnamed_addr constant [3 x i8] c"  \00"
@.str.32688 = private unnamed_addr constant [9 x i8] c" = icmp \00"
@.str.32692 = private unnamed_addr constant [6 x i8] c" i32 \00"
@.str.32696 = private unnamed_addr constant [8 x i8] c".call, \00"
@.str.32707 = private unnamed_addr constant [2 x i8] c"\0A\00"
@.str.32740 = private unnamed_addr constant [2 x i8] c"(\00"
@.str.32753 = private unnamed_addr constant [2 x i8] c"(\00"
@.str.32755 = private unnamed_addr constant [2 x i8] c")\00"
@.str.32828 = private unnamed_addr constant [6 x i8] c".call\00"
@.str.32831 = private unnamed_addr constant [3 x i8] c"  \00"
@.str.32835 = private unnamed_addr constant [19 x i8] c".call = call i32 @\00"
@.str.32847 = private unnamed_addr constant [2 x i8] c"(\00"
@.str.32861 = private unnamed_addr constant [6 x i8] c".call\00"
@.str.32864 = private unnamed_addr constant [3 x i8] c")\0A\00"
@.str.32866 = private unnamed_addr constant [3 x i8] c"  \00"
@.str.32870 = private unnamed_addr constant [9 x i8] c" = icmp \00"
@.str.32874 = private unnamed_addr constant [6 x i8] c" i32 \00"
@.str.32878 = private unnamed_addr constant [8 x i8] c".call, \00"
@.str.32889 = private unnamed_addr constant [2 x i8] c"\0A\00"
@.str.32922 = private unnamed_addr constant [6 x i8] c".left\00"
@.str.32931 = private unnamed_addr constant [7 x i8] c".right\00"
@.str.32958 = private unnamed_addr constant [3 x i8] c"  \00"
@.str.32962 = private unnamed_addr constant [10 x i8] c" = or i1 \00"
@.str.32966 = private unnamed_addr constant [8 x i8] c".left, \00"
@.str.32970 = private unnamed_addr constant [8 x i8] c".right\0A\00"
@.str.32972 = private unnamed_addr constant [19 x i8] c"  ; bool operands \00"
@.str.32983 = private unnamed_addr constant [3 x i8] c", \00"
@.str.32996 = private unnamed_addr constant [2 x i8] c"\0A\00"
@.str.33026 = private unnamed_addr constant [6 x i8] c".left\00"
@.str.33035 = private unnamed_addr constant [7 x i8] c".right\00"
@.str.33062 = private unnamed_addr constant [3 x i8] c"  \00"
@.str.33066 = private unnamed_addr constant [11 x i8] c" = and i1 \00"
@.str.33070 = private unnamed_addr constant [8 x i8] c".left, \00"
@.str.33074 = private unnamed_addr constant [8 x i8] c".right\0A\00"
@.str.33076 = private unnamed_addr constant [19 x i8] c"  ; bool operands \00"
@.str.33087 = private unnamed_addr constant [3 x i8] c", \00"
@.str.33100 = private unnamed_addr constant [2 x i8] c"\0A\00"
@.str.33171 = private unnamed_addr constant [7 x i8] c".addr.\00"
@.str.33180 = private unnamed_addr constant [2 x i8] c"%\00"
@.str.33184 = private unnamed_addr constant [8 x i8] c".binit.\00"
@.str.33196 = private unnamed_addr constant [4 x i8] c"  %\00"
@.str.33200 = private unnamed_addr constant [14 x i8] c" = alloca i1\0A\00"
@.str.33215 = private unnamed_addr constant [12 x i8] c"  store i1 \00"
@.str.33219 = private unnamed_addr constant [8 x i8] c", ptr %\00"
@.str.33223 = private unnamed_addr constant [2 x i8] c"\0A\00"
@.str.33227 = private unnamed_addr constant [4 x i8] c"  %\00"
@.str.33231 = private unnamed_addr constant [14 x i8] c" = alloca i1\0A\00"
@.str.33233 = private unnamed_addr constant [24 x i8] c"  store i1 false, ptr %\00"
@.str.33237 = private unnamed_addr constant [2 x i8] c"\0A\00"
@.str.33293 = private unnamed_addr constant [1 x i8] c"\00"
@.str.33340 = private unnamed_addr constant [2 x i8] c"=\00"
@.str.33347 = private unnamed_addr constant [3 x i8] c"<-\00"
@.str.33356 = private unnamed_addr constant [2 x i8] c"%\00"
@.str.33360 = private unnamed_addr constant [10 x i8] c".bassign.\00"
@.str.33378 = private unnamed_addr constant [12 x i8] c"  store i1 \00"
@.str.33382 = private unnamed_addr constant [8 x i8] c", ptr %\00"
@.str.33386 = private unnamed_addr constant [2 x i8] c"\0A\00"
@.str.33390 = private unnamed_addr constant [1 x i8] c"\00"
@.str.33473 = private unnamed_addr constant [7 x i8] c"return\00"
@.str.33547 = private unnamed_addr constant [3 x i8] c"  \00"
@.str.33551 = private unnamed_addr constant [26 x i8] c" = inttoptr i64 0 to ptr\0A\00"
@.str.33598 = private unnamed_addr constant [3 x i8] c"  \00"
@.str.33602 = private unnamed_addr constant [28 x i8] c" = getelementptr inbounds [\00"
@.str.33606 = private unnamed_addr constant [19 x i8] c" x i8], ptr @.str.\00"
@.str.33610 = private unnamed_addr constant [16 x i8] c", i32 0, i32 0\0A\00"
@.str.33634 = private unnamed_addr constant [3 x i8] c"  \00"
@.str.33638 = private unnamed_addr constant [19 x i8] c" = load ptr, ptr %\00"
@.str.33654 = private unnamed_addr constant [2 x i8] c"\0A\00"
@.str.33688 = private unnamed_addr constant [2 x i8] c"(\00"
@.str.33701 = private unnamed_addr constant [2 x i8] c"(\00"
@.str.33703 = private unnamed_addr constant [2 x i8] c")\00"
@.str.33727 = private unnamed_addr constant [3 x i8] c"  \00"
@.str.33731 = private unnamed_addr constant [14 x i8] c" = call ptr @\00"
@.str.33743 = private unnamed_addr constant [2 x i8] c"(\00"
@.str.33760 = private unnamed_addr constant [3 x i8] c")\0A\00"
@.str.33794 = private unnamed_addr constant [2 x i8] c".\00"
@.str.33809 = private unnamed_addr constant [10 x i8] c"substring\00"
@.str.33824 = private unnamed_addr constant [2 x i8] c"(\00"
@.str.33837 = private unnamed_addr constant [2 x i8] c"(\00"
@.str.33839 = private unnamed_addr constant [2 x i8] c")\00"
@.str.33864 = private unnamed_addr constant [2 x i8] c",\00"
@.str.33903 = private unnamed_addr constant [3 x i8] c"  \00"
@.str.33907 = private unnamed_addr constant [23 x i8] c".obj = load ptr, ptr %\00"
@.str.33911 = private unnamed_addr constant [2 x i8] c"\0A\00"
@.str.33925 = private unnamed_addr constant [7 x i8] c".start\00"
@.str.33942 = private unnamed_addr constant [8 x i8] c".length\00"
@.str.33945 = private unnamed_addr constant [3 x i8] c"  \00"
@.str.33949 = private unnamed_addr constant [40 x i8] c" = call ptr @csec_string_substring(ptr \00"
@.str.33953 = private unnamed_addr constant [11 x i8] c".obj, i32 \00"
@.str.33957 = private unnamed_addr constant [13 x i8] c".start, i32 \00"
@.str.33961 = private unnamed_addr constant [10 x i8] c".length)\0A\00"
@.str.34005 = private unnamed_addr constant [2 x i8] c"+\00"
@.str.34084 = private unnamed_addr constant [1 x i8] c"\00"
@.str.34091 = private unnamed_addr constant [1 x i8] c"\00"
@.str.34151 = private unnamed_addr constant [4 x i8] c"ptr\00"
@.str.34185 = private unnamed_addr constant [2 x i8] c"(\00"
@.str.34198 = private unnamed_addr constant [2 x i8] c"(\00"
@.str.34200 = private unnamed_addr constant [2 x i8] c")\00"
@.str.34224 = private unnamed_addr constant [4 x i8] c"ptr\00"
@.str.34258 = private unnamed_addr constant [2 x i8] c".\00"
@.str.34273 = private unnamed_addr constant [10 x i8] c"substring\00"
@.str.34288 = private unnamed_addr constant [2 x i8] c"(\00"
@.str.34301 = private unnamed_addr constant [2 x i8] c"(\00"
@.str.34303 = private unnamed_addr constant [2 x i8] c")\00"
@.str.34336 = private unnamed_addr constant [2 x i8] c"+\00"
@.str.34353 = private unnamed_addr constant [6 x i8] c".left\00"
@.str.34380 = private unnamed_addr constant [3 x i8] c"  \00"
@.str.34384 = private unnamed_addr constant [42 x i8] c".left = call ptr @csec_to_string_char(i8 \00"
@.str.34396 = private unnamed_addr constant [3 x i8] c")\0A\00"
@.str.34435 = private unnamed_addr constant [5 x i8] c"Char\00"
@.str.34441 = private unnamed_addr constant [3 x i8] c"  \00"
@.str.34445 = private unnamed_addr constant [26 x i8] c".left.i8 = load i8, ptr %\00"
@.str.34461 = private unnamed_addr constant [2 x i8] c"\0A\00"
@.str.34463 = private unnamed_addr constant [3 x i8] c"  \00"
@.str.34467 = private unnamed_addr constant [42 x i8] c".left = call ptr @csec_to_string_char(i8 \00"
@.str.34471 = private unnamed_addr constant [11 x i8] c".left.i8)\0A\00"
@.str.34488 = private unnamed_addr constant [10 x i8] c".left.i32\00"
@.str.34491 = private unnamed_addr constant [3 x i8] c"  \00"
@.str.34495 = private unnamed_addr constant [22 x i8] c".left.i64 = sext i32 \00"
@.str.34499 = private unnamed_addr constant [18 x i8] c".left.i32 to i64\0A\00"
@.str.34501 = private unnamed_addr constant [3 x i8] c"  \00"
@.str.34505 = private unnamed_addr constant [42 x i8] c".left = call ptr @csec_to_string_i64(i64 \00"
@.str.34509 = private unnamed_addr constant [12 x i8] c".left.i64)\0A\00"
@.str.34570 = private unnamed_addr constant [4 x i8] c"ptr\00"
@.str.34604 = private unnamed_addr constant [2 x i8] c"(\00"
@.str.34617 = private unnamed_addr constant [2 x i8] c"(\00"
@.str.34619 = private unnamed_addr constant [2 x i8] c")\00"
@.str.34643 = private unnamed_addr constant [4 x i8] c"ptr\00"
@.str.34677 = private unnamed_addr constant [2 x i8] c".\00"
@.str.34692 = private unnamed_addr constant [10 x i8] c"substring\00"
@.str.34707 = private unnamed_addr constant [2 x i8] c"(\00"
@.str.34720 = private unnamed_addr constant [2 x i8] c"(\00"
@.str.34722 = private unnamed_addr constant [2 x i8] c")\00"
@.str.34755 = private unnamed_addr constant [2 x i8] c"+\00"
@.str.34772 = private unnamed_addr constant [7 x i8] c".right\00"
@.str.34799 = private unnamed_addr constant [3 x i8] c"  \00"
@.str.34803 = private unnamed_addr constant [43 x i8] c".right = call ptr @csec_to_string_char(i8 \00"
@.str.34815 = private unnamed_addr constant [3 x i8] c")\0A\00"
@.str.34854 = private unnamed_addr constant [5 x i8] c"Char\00"
@.str.34860 = private unnamed_addr constant [3 x i8] c"  \00"
@.str.34864 = private unnamed_addr constant [27 x i8] c".right.i8 = load i8, ptr %\00"
@.str.34880 = private unnamed_addr constant [2 x i8] c"\0A\00"
@.str.34882 = private unnamed_addr constant [3 x i8] c"  \00"
@.str.34886 = private unnamed_addr constant [43 x i8] c".right = call ptr @csec_to_string_char(i8 \00"
@.str.34890 = private unnamed_addr constant [12 x i8] c".right.i8)\0A\00"
@.str.34907 = private unnamed_addr constant [11 x i8] c".right.i32\00"
@.str.34910 = private unnamed_addr constant [3 x i8] c"  \00"
@.str.34914 = private unnamed_addr constant [23 x i8] c".right.i64 = sext i32 \00"
@.str.34918 = private unnamed_addr constant [19 x i8] c".right.i32 to i64\0A\00"
@.str.34920 = private unnamed_addr constant [3 x i8] c"  \00"
@.str.34924 = private unnamed_addr constant [43 x i8] c".right = call ptr @csec_to_string_i64(i64 \00"
@.str.34928 = private unnamed_addr constant [13 x i8] c".right.i64)\0A\00"
@.str.34936 = private unnamed_addr constant [3 x i8] c"  \00"
@.str.34940 = private unnamed_addr constant [37 x i8] c" = call ptr @csec_string_concat(ptr \00"
@.str.34944 = private unnamed_addr constant [12 x i8] c".left, ptr \00"
@.str.34948 = private unnamed_addr constant [9 x i8] c".right)\0A\00"
@.str.34952 = private unnamed_addr constant [3 x i8] c"  \00"
@.str.34956 = private unnamed_addr constant [26 x i8] c" = inttoptr i64 0 to ptr\0A\00"
@.str.35014 = private unnamed_addr constant [7 x i8] c".addr.\00"
@.str.35023 = private unnamed_addr constant [2 x i8] c"%\00"
@.str.35027 = private unnamed_addr constant [8 x i8] c".pinit.\00"
@.str.35067 = private unnamed_addr constant [4 x i8] c"  %\00"
@.str.35071 = private unnamed_addr constant [15 x i8] c" = alloca ptr\0A\00"
@.str.35084 = private unnamed_addr constant [13 x i8] c"  store ptr \00"
@.str.35088 = private unnamed_addr constant [8 x i8] c", ptr %\00"
@.str.35092 = private unnamed_addr constant [2 x i8] c"\0A\00"
@.str.35096 = private unnamed_addr constant [4 x i8] c"  %\00"
@.str.35100 = private unnamed_addr constant [15 x i8] c" = alloca ptr\0A\00"
@.str.35102 = private unnamed_addr constant [24 x i8] c"  store ptr null, ptr %\00"
@.str.35106 = private unnamed_addr constant [2 x i8] c"\0A\00"
@.str.35216 = private unnamed_addr constant [4 x i8] c"ptr\00"
@.str.35251 = private unnamed_addr constant [2 x i8] c"(\00"
@.str.35264 = private unnamed_addr constant [2 x i8] c"(\00"
@.str.35266 = private unnamed_addr constant [2 x i8] c")\00"
@.str.35292 = private unnamed_addr constant [4 x i8] c"ptr\00"
@.str.35327 = private unnamed_addr constant [2 x i8] c".\00"
@.str.35342 = private unnamed_addr constant [10 x i8] c"substring\00"
@.str.35357 = private unnamed_addr constant [2 x i8] c"(\00"
@.str.35370 = private unnamed_addr constant [2 x i8] c"(\00"
@.str.35372 = private unnamed_addr constant [2 x i8] c")\00"
@.str.35424 = private unnamed_addr constant [2 x i8] c"+\00"
@.str.35543 = private unnamed_addr constant [6 x i8] c"value\00"
@.str.35550 = private unnamed_addr constant [9 x i8] c"variable\00"
@.str.35567 = private unnamed_addr constant [4 x i8] c"Int\00"
@.str.35581 = private unnamed_addr constant [8 x i8] c"unknown\00"
@.str.35614 = private unnamed_addr constant [8 x i8] c"Boolean\00"
@.str.35647 = private unnamed_addr constant [7 x i8] c"Double\00"
@.str.35680 = private unnamed_addr constant [5 x i8] c"Long\00"
@.str.35713 = private unnamed_addr constant [5 x i8] c"Char\00"
@.str.35748 = private unnamed_addr constant [4 x i8] c"ptr\00"
@.str.35763 = private unnamed_addr constant [4 x i8] c"Int\00"
@.str.35778 = private unnamed_addr constant [8 x i8] c"Boolean\00"
@.str.35793 = private unnamed_addr constant [7 x i8] c"Double\00"
@.str.35808 = private unnamed_addr constant [5 x i8] c"Long\00"
@.str.35823 = private unnamed_addr constant [5 x i8] c"Char\00"
@.str.35850 = private unnamed_addr constant [7 x i8] c"return\00"
@.str.35881 = private unnamed_addr constant [2 x i8] c";\00"
@.str.35889 = private unnamed_addr constant [10 x i8] c"  ret i1 \00"
@.str.35900 = private unnamed_addr constant [2 x i8] c"\0A\00"
@.str.35932 = private unnamed_addr constant [2 x i8] c";\00"
@.str.35966 = private unnamed_addr constant [6 x i8] c"%ret.\00"
@.str.35974 = private unnamed_addr constant [3 x i8] c"  \00"
@.str.35978 = private unnamed_addr constant [28 x i8] c" = getelementptr inbounds [\00"
@.str.35982 = private unnamed_addr constant [19 x i8] c" x i8], ptr @.str.\00"
@.str.35990 = private unnamed_addr constant [16 x i8] c", i32 0, i32 0\0A\00"
@.str.35992 = private unnamed_addr constant [11 x i8] c"  ret ptr \00"
@.str.35996 = private unnamed_addr constant [2 x i8] c"\0A\00"
@.str.36028 = private unnamed_addr constant [2 x i8] c";\00"
@.str.36075 = private unnamed_addr constant [6 x i8] c"%ret.\00"
@.str.36085 = private unnamed_addr constant [4 x i8] c"ptr\00"
@.str.36092 = private unnamed_addr constant [3 x i8] c"i8\00"
@.str.36099 = private unnamed_addr constant [3 x i8] c"i1\00"
@.str.36106 = private unnamed_addr constant [4 x i8] c"i64\00"
@.str.36113 = private unnamed_addr constant [7 x i8] c"double\00"
@.str.36121 = private unnamed_addr constant [3 x i8] c"  \00"
@.str.36125 = private unnamed_addr constant [9 x i8] c" = load \00"
@.str.36129 = private unnamed_addr constant [8 x i8] c", ptr %\00"
@.str.36142 = private unnamed_addr constant [2 x i8] c"\0A\00"
@.str.36144 = private unnamed_addr constant [7 x i8] c"  ret \00"
@.str.36148 = private unnamed_addr constant [2 x i8] c" \00"
@.str.36152 = private unnamed_addr constant [2 x i8] c"\0A\00"
@.str.36175 = private unnamed_addr constant [11 x i8] c"  ret i32 \00"
@.str.36179 = private unnamed_addr constant [2 x i8] c"\0A\00"
@.str.36218 = private unnamed_addr constant [2 x i8] c"(\00"
@.str.36237 = private unnamed_addr constant [2 x i8] c"(\00"
@.str.36239 = private unnamed_addr constant [2 x i8] c")\00"
@.str.36276 = private unnamed_addr constant [6 x i8] c"%ret.\00"
@.str.36293 = private unnamed_addr constant [4 x i8] c"ptr\00"
@.str.36300 = private unnamed_addr constant [3 x i8] c"i8\00"
@.str.36307 = private unnamed_addr constant [3 x i8] c"i1\00"
@.str.36314 = private unnamed_addr constant [4 x i8] c"i64\00"
@.str.36321 = private unnamed_addr constant [7 x i8] c"double\00"
@.str.36343 = private unnamed_addr constant [3 x i8] c"  \00"
@.str.36347 = private unnamed_addr constant [9 x i8] c" = call \00"
@.str.36351 = private unnamed_addr constant [3 x i8] c" @\00"
@.str.36365 = private unnamed_addr constant [2 x i8] c"(\00"
@.str.36380 = private unnamed_addr constant [3 x i8] c")\0A\00"
@.str.36382 = private unnamed_addr constant [7 x i8] c"  ret \00"
@.str.36386 = private unnamed_addr constant [2 x i8] c" \00"
@.str.36390 = private unnamed_addr constant [2 x i8] c"\0A\00"
@.str.36413 = private unnamed_addr constant [11 x i8] c"  ret i32 \00"
@.str.36417 = private unnamed_addr constant [2 x i8] c"\0A\00"
@.str.36442 = private unnamed_addr constant [6 x i8] c"%ret.\00"
@.str.36463 = private unnamed_addr constant [11 x i8] c"  ret ptr \00"
@.str.36467 = private unnamed_addr constant [2 x i8] c"\0A\00"
@.str.36478 = private unnamed_addr constant [6 x i8] c"%ret.\00"
@.str.36499 = private unnamed_addr constant [11 x i8] c"  ret i32 \00"
@.str.36503 = private unnamed_addr constant [2 x i8] c"\0A\00"
@.str.36515 = private unnamed_addr constant [3 x i8] c"if\00"
@.str.36574 = private unnamed_addr constant [2 x i8] c"{\00"
@.str.36576 = private unnamed_addr constant [2 x i8] c"}\00"
@.str.36602 = private unnamed_addr constant [18 x i8] c"  ; malformed if\0A\00"
@.str.36613 = private unnamed_addr constant [1 x i8] c"\00"
@.str.36652 = private unnamed_addr constant [20 x i8] c"  br label %if.end.\00"
@.str.36656 = private unnamed_addr constant [2 x i8] c"\0A\00"
@.str.36674 = private unnamed_addr constant [1 x i8] c"\00"
@.str.36682 = private unnamed_addr constant [1 x i8] c"\00"
@.str.36689 = private unnamed_addr constant [20 x i8] c"  br label %if.end.\00"
@.str.36693 = private unnamed_addr constant [2 x i8] c"\0A\00"
@.str.36711 = private unnamed_addr constant [5 x i8] c"else\00"
@.str.36741 = private unnamed_addr constant [2 x i8] c"{\00"
@.str.36758 = private unnamed_addr constant [2 x i8] c"{\00"
@.str.36760 = private unnamed_addr constant [2 x i8] c"}\00"
@.str.36799 = private unnamed_addr constant [1 x i8] c"\00"
@.str.36819 = private unnamed_addr constant [7 x i8] c"%cond.\00"
@.str.36824 = private unnamed_addr constant [15 x i8] c"  br i1 %cond.\00"
@.str.36828 = private unnamed_addr constant [18 x i8] c", label %if.then.\00"
@.str.36832 = private unnamed_addr constant [18 x i8] c", label %if.else.\00"
@.str.36836 = private unnamed_addr constant [2 x i8] c"\0A\00"
@.str.36838 = private unnamed_addr constant [9 x i8] c"if.then.\00"
@.str.36842 = private unnamed_addr constant [3 x i8] c":\0A\00"
@.str.36848 = private unnamed_addr constant [9 x i8] c"if.else.\00"
@.str.36852 = private unnamed_addr constant [3 x i8] c":\0A\00"
@.str.36858 = private unnamed_addr constant [8 x i8] c"if.end.\00"
@.str.36862 = private unnamed_addr constant [3 x i8] c":\0A\00"
@.str.36874 = private unnamed_addr constant [6 x i8] c"while\00"
@.str.36933 = private unnamed_addr constant [2 x i8] c"{\00"
@.str.36935 = private unnamed_addr constant [2 x i8] c"}\00"
@.str.36961 = private unnamed_addr constant [21 x i8] c"  ; malformed while\0A\00"
@.str.36972 = private unnamed_addr constant [1 x i8] c"\00"
@.str.36997 = private unnamed_addr constant [24 x i8] c"  br label %while.cond.\00"
@.str.37001 = private unnamed_addr constant [2 x i8] c"\0A\00"
@.str.37019 = private unnamed_addr constant [1 x i8] c"\00"
@.str.37026 = private unnamed_addr constant [24 x i8] c"  br label %while.cond.\00"
@.str.37030 = private unnamed_addr constant [2 x i8] c"\0A\00"
@.str.37032 = private unnamed_addr constant [12 x i8] c"while.cond.\00"
@.str.37036 = private unnamed_addr constant [3 x i8] c":\0A\00"
@.str.37048 = private unnamed_addr constant [12 x i8] c"%whilecond.\00"
@.str.37053 = private unnamed_addr constant [20 x i8] c"  br i1 %whilecond.\00"
@.str.37057 = private unnamed_addr constant [21 x i8] c", label %while.body.\00"
@.str.37061 = private unnamed_addr constant [20 x i8] c", label %while.end.\00"
@.str.37065 = private unnamed_addr constant [2 x i8] c"\0A\00"
@.str.37067 = private unnamed_addr constant [12 x i8] c"while.body.\00"
@.str.37071 = private unnamed_addr constant [3 x i8] c":\0A\00"
@.str.37077 = private unnamed_addr constant [11 x i8] c"while.end.\00"
@.str.37081 = private unnamed_addr constant [3 x i8] c":\0A\00"
@.str.37093 = private unnamed_addr constant [4 x i8] c"for\00"
@.str.37152 = private unnamed_addr constant [2 x i8] c"{\00"
@.str.37154 = private unnamed_addr constant [2 x i8] c"}\00"
@.str.37180 = private unnamed_addr constant [19 x i8] c"  ; malformed for\0A\00"
@.str.37205 = private unnamed_addr constant [28 x i8] c"  ; malformed for iterator\0A\00"
@.str.37240 = private unnamed_addr constant [3 x i8] c"<-\00"
@.str.37254 = private unnamed_addr constant [26 x i8] c"  ; malformed for source\0A\00"
@.str.37289 = private unnamed_addr constant [28 x i8] c"  ; unsupported for source\0A\00"
@.str.37300 = private unnamed_addr constant [1 x i8] c"\00"
@.str.37309 = private unnamed_addr constant [4 x i8] c"slt\00"
@.str.37322 = private unnamed_addr constant [3 x i8] c"to\00"
@.str.37334 = private unnamed_addr constant [3 x i8] c"..\00"
@.str.37340 = private unnamed_addr constant [4 x i8] c"sle\00"
@.str.37364 = private unnamed_addr constant [4 x i8] c"  %\00"
@.str.37368 = private unnamed_addr constant [7 x i8] c".step.\00"
@.str.37372 = private unnamed_addr constant [19 x i8] c" = load i32, ptr %\00"
@.str.37376 = private unnamed_addr constant [2 x i8] c"\0A\00"
@.str.37378 = private unnamed_addr constant [4 x i8] c"  %\00"
@.str.37382 = private unnamed_addr constant [7 x i8] c".next.\00"
@.str.37386 = private unnamed_addr constant [13 x i8] c" = add i32 %\00"
@.str.37390 = private unnamed_addr constant [7 x i8] c".step.\00"
@.str.37394 = private unnamed_addr constant [5 x i8] c", 1\0A\00"
@.str.37396 = private unnamed_addr constant [14 x i8] c"  store i32 %\00"
@.str.37400 = private unnamed_addr constant [7 x i8] c".next.\00"
@.str.37404 = private unnamed_addr constant [8 x i8] c", ptr %\00"
@.str.37408 = private unnamed_addr constant [2 x i8] c"\0A\00"
@.str.37410 = private unnamed_addr constant [22 x i8] c"  br label %for.cond.\00"
@.str.37414 = private unnamed_addr constant [2 x i8] c"\0A\00"
@.str.37432 = private unnamed_addr constant [1 x i8] c"\00"
@.str.37439 = private unnamed_addr constant [4 x i8] c"  %\00"
@.str.37443 = private unnamed_addr constant [15 x i8] c" = alloca i32\0A\00"
@.str.37455 = private unnamed_addr constant [2 x i8] c"%\00"
@.str.37459 = private unnamed_addr constant [7 x i8] c".start\00"
@.str.37462 = private unnamed_addr constant [14 x i8] c"  store i32 %\00"
@.str.37466 = private unnamed_addr constant [14 x i8] c".start, ptr %\00"
@.str.37470 = private unnamed_addr constant [2 x i8] c"\0A\00"
@.str.37472 = private unnamed_addr constant [22 x i8] c"  br label %for.cond.\00"
@.str.37476 = private unnamed_addr constant [2 x i8] c"\0A\00"
@.str.37478 = private unnamed_addr constant [10 x i8] c"for.cond.\00"
@.str.37482 = private unnamed_addr constant [3 x i8] c":\0A\00"
@.str.37484 = private unnamed_addr constant [4 x i8] c"  %\00"
@.str.37488 = private unnamed_addr constant [23 x i8] c".val = load i32, ptr %\00"
@.str.37492 = private unnamed_addr constant [2 x i8] c"\0A\00"
@.str.37504 = private unnamed_addr constant [2 x i8] c"%\00"
@.str.37508 = private unnamed_addr constant [5 x i8] c".end\00"
@.str.37511 = private unnamed_addr constant [12 x i8] c"  %forcond.\00"
@.str.37515 = private unnamed_addr constant [9 x i8] c" = icmp \00"
@.str.37519 = private unnamed_addr constant [7 x i8] c" i32 %\00"
@.str.37523 = private unnamed_addr constant [8 x i8] c".val, %\00"
@.str.37527 = private unnamed_addr constant [6 x i8] c".end\0A\00"
@.str.37529 = private unnamed_addr constant [18 x i8] c"  br i1 %forcond.\00"
@.str.37533 = private unnamed_addr constant [19 x i8] c", label %for.body.\00"
@.str.37537 = private unnamed_addr constant [18 x i8] c", label %for.end.\00"
@.str.37541 = private unnamed_addr constant [2 x i8] c"\0A\00"
@.str.37543 = private unnamed_addr constant [10 x i8] c"for.body.\00"
@.str.37547 = private unnamed_addr constant [3 x i8] c":\0A\00"
@.str.37553 = private unnamed_addr constant [9 x i8] c"for.end.\00"
@.str.37557 = private unnamed_addr constant [3 x i8] c":\0A\00"
@.str.37597 = private unnamed_addr constant [2 x i8] c"(\00"
@.str.37609 = private unnamed_addr constant [27 x i8] c"csec_string_builder_append\00"
@.str.37628 = private unnamed_addr constant [2 x i8] c"(\00"
@.str.37630 = private unnamed_addr constant [2 x i8] c")\00"
@.str.37647 = private unnamed_addr constant [9 x i8] c"%append.\00"
@.str.37668 = private unnamed_addr constant [3 x i8] c"  \00"
@.str.37672 = private unnamed_addr constant [41 x i8] c" = call i32 @csec_string_builder_append(\00"
@.str.37687 = private unnamed_addr constant [3 x i8] c")\0A\00"
@.str.37732 = private unnamed_addr constant [8 x i8] c"Boolean\00"
@.str.37758 = private unnamed_addr constant [7 x i8] c"Double\00"
@.str.37784 = private unnamed_addr constant [5 x i8] c"Long\00"
@.str.37810 = private unnamed_addr constant [5 x i8] c"Char\00"
@.str.37839 = private unnamed_addr constant [4 x i8] c"ptr\00"
@.str.37984 = private unnamed_addr constant [2 x i8] c"{\00"
@.str.37986 = private unnamed_addr constant [2 x i8] c"}\00"
@.str.38009 = private unnamed_addr constant [18 x i8] c"  ; malformed if\0A\00"
@.str.38017 = private unnamed_addr constant [1 x i8] c"\00"
@.str.38056 = private unnamed_addr constant [20 x i8] c"  br label %if.end.\00"
@.str.38060 = private unnamed_addr constant [2 x i8] c"\0A\00"
@.str.38078 = private unnamed_addr constant [1 x i8] c"\00"
@.str.38086 = private unnamed_addr constant [1 x i8] c"\00"
@.str.38093 = private unnamed_addr constant [20 x i8] c"  br label %if.end.\00"
@.str.38097 = private unnamed_addr constant [2 x i8] c"\0A\00"
@.str.38115 = private unnamed_addr constant [5 x i8] c"else\00"
@.str.38145 = private unnamed_addr constant [3 x i8] c"if\00"
@.str.38174 = private unnamed_addr constant [2 x i8] c"{\00"
@.str.38191 = private unnamed_addr constant [2 x i8] c"{\00"
@.str.38193 = private unnamed_addr constant [2 x i8] c"}\00"
@.str.38232 = private unnamed_addr constant [1 x i8] c"\00"
@.str.38249 = private unnamed_addr constant [7 x i8] c"%cond.\00"
@.str.38254 = private unnamed_addr constant [15 x i8] c"  br i1 %cond.\00"
@.str.38258 = private unnamed_addr constant [18 x i8] c", label %if.then.\00"
@.str.38262 = private unnamed_addr constant [18 x i8] c", label %if.else.\00"
@.str.38266 = private unnamed_addr constant [2 x i8] c"\0A\00"
@.str.38268 = private unnamed_addr constant [9 x i8] c"if.then.\00"
@.str.38272 = private unnamed_addr constant [3 x i8] c":\0A\00"
@.str.38278 = private unnamed_addr constant [9 x i8] c"if.else.\00"
@.str.38282 = private unnamed_addr constant [3 x i8] c":\0A\00"
@.str.38288 = private unnamed_addr constant [8 x i8] c"if.end.\00"
@.str.38292 = private unnamed_addr constant [3 x i8] c":\0A\00"
@.str.38368 = private unnamed_addr constant [2 x i8] c"{\00"
@.str.38370 = private unnamed_addr constant [2 x i8] c"}\00"
@.str.38393 = private unnamed_addr constant [21 x i8] c"  ; malformed while\0A\00"
@.str.38401 = private unnamed_addr constant [1 x i8] c"\00"
@.str.38426 = private unnamed_addr constant [24 x i8] c"  br label %while.cond.\00"
@.str.38430 = private unnamed_addr constant [2 x i8] c"\0A\00"
@.str.38448 = private unnamed_addr constant [1 x i8] c"\00"
@.str.38452 = private unnamed_addr constant [24 x i8] c"  br label %while.cond.\00"
@.str.38456 = private unnamed_addr constant [2 x i8] c"\0A\00"
@.str.38458 = private unnamed_addr constant [12 x i8] c"while.cond.\00"
@.str.38462 = private unnamed_addr constant [3 x i8] c":\0A\00"
@.str.38474 = private unnamed_addr constant [12 x i8] c"%whilecond.\00"
@.str.38479 = private unnamed_addr constant [20 x i8] c"  br i1 %whilecond.\00"
@.str.38483 = private unnamed_addr constant [21 x i8] c", label %while.body.\00"
@.str.38487 = private unnamed_addr constant [20 x i8] c", label %while.end.\00"
@.str.38491 = private unnamed_addr constant [2 x i8] c"\0A\00"
@.str.38493 = private unnamed_addr constant [12 x i8] c"while.body.\00"
@.str.38497 = private unnamed_addr constant [3 x i8] c":\0A\00"
@.str.38503 = private unnamed_addr constant [11 x i8] c"while.end.\00"
@.str.38507 = private unnamed_addr constant [3 x i8] c":\0A\00"
@.str.38583 = private unnamed_addr constant [2 x i8] c"{\00"
@.str.38585 = private unnamed_addr constant [2 x i8] c"}\00"
@.str.38608 = private unnamed_addr constant [19 x i8] c"  ; malformed for\0A\00"
@.str.38628 = private unnamed_addr constant [28 x i8] c"  ; malformed for iterator\0A\00"
@.str.38660 = private unnamed_addr constant [3 x i8] c"<-\00"
@.str.38671 = private unnamed_addr constant [26 x i8] c"  ; malformed for source\0A\00"
@.str.38700 = private unnamed_addr constant [28 x i8] c"  ; unsupported for source\0A\00"
@.str.38708 = private unnamed_addr constant [1 x i8] c"\00"
@.str.38717 = private unnamed_addr constant [4 x i8] c"slt\00"
@.str.38730 = private unnamed_addr constant [3 x i8] c"to\00"
@.str.38742 = private unnamed_addr constant [3 x i8] c"..\00"
@.str.38748 = private unnamed_addr constant [4 x i8] c"sle\00"
@.str.38772 = private unnamed_addr constant [4 x i8] c"  %\00"
@.str.38776 = private unnamed_addr constant [7 x i8] c".step.\00"
@.str.38780 = private unnamed_addr constant [19 x i8] c" = load i32, ptr %\00"
@.str.38784 = private unnamed_addr constant [2 x i8] c"\0A\00"
@.str.38786 = private unnamed_addr constant [4 x i8] c"  %\00"
@.str.38790 = private unnamed_addr constant [7 x i8] c".next.\00"
@.str.38794 = private unnamed_addr constant [13 x i8] c" = add i32 %\00"
@.str.38798 = private unnamed_addr constant [7 x i8] c".step.\00"
@.str.38802 = private unnamed_addr constant [5 x i8] c", 1\0A\00"
@.str.38804 = private unnamed_addr constant [14 x i8] c"  store i32 %\00"
@.str.38808 = private unnamed_addr constant [7 x i8] c".next.\00"
@.str.38812 = private unnamed_addr constant [8 x i8] c", ptr %\00"
@.str.38816 = private unnamed_addr constant [2 x i8] c"\0A\00"
@.str.38818 = private unnamed_addr constant [22 x i8] c"  br label %for.cond.\00"
@.str.38822 = private unnamed_addr constant [2 x i8] c"\0A\00"
@.str.38840 = private unnamed_addr constant [1 x i8] c"\00"
@.str.38844 = private unnamed_addr constant [4 x i8] c"  %\00"
@.str.38848 = private unnamed_addr constant [15 x i8] c" = alloca i32\0A\00"
@.str.38860 = private unnamed_addr constant [2 x i8] c"%\00"
@.str.38864 = private unnamed_addr constant [7 x i8] c".start\00"
@.str.38867 = private unnamed_addr constant [14 x i8] c"  store i32 %\00"
@.str.38871 = private unnamed_addr constant [14 x i8] c".start, ptr %\00"
@.str.38875 = private unnamed_addr constant [2 x i8] c"\0A\00"
@.str.38877 = private unnamed_addr constant [22 x i8] c"  br label %for.cond.\00"
@.str.38881 = private unnamed_addr constant [2 x i8] c"\0A\00"
@.str.38883 = private unnamed_addr constant [10 x i8] c"for.cond.\00"
@.str.38887 = private unnamed_addr constant [3 x i8] c":\0A\00"
@.str.38889 = private unnamed_addr constant [4 x i8] c"  %\00"
@.str.38893 = private unnamed_addr constant [23 x i8] c".val = load i32, ptr %\00"
@.str.38897 = private unnamed_addr constant [2 x i8] c"\0A\00"
@.str.38909 = private unnamed_addr constant [2 x i8] c"%\00"
@.str.38913 = private unnamed_addr constant [5 x i8] c".end\00"
@.str.38916 = private unnamed_addr constant [12 x i8] c"  %forcond.\00"
@.str.38920 = private unnamed_addr constant [9 x i8] c" = icmp \00"
@.str.38924 = private unnamed_addr constant [7 x i8] c" i32 %\00"
@.str.38928 = private unnamed_addr constant [8 x i8] c".val, %\00"
@.str.38932 = private unnamed_addr constant [6 x i8] c".end\0A\00"
@.str.38934 = private unnamed_addr constant [18 x i8] c"  br i1 %forcond.\00"
@.str.38938 = private unnamed_addr constant [19 x i8] c", label %for.body.\00"
@.str.38942 = private unnamed_addr constant [18 x i8] c", label %for.end.\00"
@.str.38946 = private unnamed_addr constant [2 x i8] c"\0A\00"
@.str.38948 = private unnamed_addr constant [10 x i8] c"for.body.\00"
@.str.38952 = private unnamed_addr constant [3 x i8] c":\0A\00"
@.str.38958 = private unnamed_addr constant [9 x i8] c"for.end.\00"
@.str.38962 = private unnamed_addr constant [3 x i8] c":\0A\00"
@.str.39020 = private unnamed_addr constant [7 x i8] c"return\00"
@.str.39051 = private unnamed_addr constant [2 x i8] c";\00"
@.str.39056 = private unnamed_addr constant [11 x i8] c"  ret i32 \00"
@.str.39067 = private unnamed_addr constant [2 x i8] c"\0A\00"
@.str.39088 = private unnamed_addr constant [5 x i8] c"%ret\00"
@.str.39091 = private unnamed_addr constant [16 x i8] c"  ret i32 %ret\0A\00"
@.str.39102 = private unnamed_addr constant [13 x i8] c"  ret i32 0\0A\00"
@.str.39135 = private unnamed_addr constant [7 x i8] c"System\00"
@.str.39150 = private unnamed_addr constant [2 x i8] c".\00"
@.str.39165 = private unnamed_addr constant [3 x i8] c"IO\00"
@.str.39180 = private unnamed_addr constant [2 x i8] c".\00"
@.str.39195 = private unnamed_addr constant [5 x i8] c"File\00"
@.str.39210 = private unnamed_addr constant [2 x i8] c".\00"
@.str.39225 = private unnamed_addr constant [13 x i8] c"WriteAllText\00"
@.str.39240 = private unnamed_addr constant [2 x i8] c"(\00"
@.str.39259 = private unnamed_addr constant [2 x i8] c"(\00"
@.str.39261 = private unnamed_addr constant [2 x i8] c")\00"
@.str.39278 = private unnamed_addr constant [13 x i8] c"%file.write.\00"
@.str.39296 = private unnamed_addr constant [3 x i8] c"  \00"
@.str.39300 = private unnamed_addr constant [39 x i8] c" = call i32 @csec_file_write_all_text(\00"
@.str.39315 = private unnamed_addr constant [3 x i8] c")\0A\00"
@.str.39331 = private unnamed_addr constant [7 x i8] c"System\00"
@.str.39346 = private unnamed_addr constant [2 x i8] c".\00"
@.str.39361 = private unnamed_addr constant [8 x i8] c"Console\00"
@.str.39376 = private unnamed_addr constant [2 x i8] c".\00"
@.str.39391 = private unnamed_addr constant [10 x i8] c"WriteLine\00"
@.str.39406 = private unnamed_addr constant [2 x i8] c"(\00"
@.str.39425 = private unnamed_addr constant [2 x i8] c"(\00"
@.str.39427 = private unnamed_addr constant [2 x i8] c")\00"
@.str.39444 = private unnamed_addr constant [16 x i8] c"%console.write.\00"
@.str.39462 = private unnamed_addr constant [32 x i8] c"  call void @csec_print_string(\00"
@.str.39477 = private unnamed_addr constant [3 x i8] c")\0A\00"
@.str.39479 = private unnamed_addr constant [35 x i8] c"  call void @csec_print_newline()\0A\00"
@.str.39484 = private unnamed_addr constant [1 x i8] c"\00"
@.str.39576 = private unnamed_addr constant [6 x i8] c"value\00"
@.str.39583 = private unnamed_addr constant [9 x i8] c"variable\00"
@.str.39600 = private unnamed_addr constant [4 x i8] c"Int\00"
@.str.39614 = private unnamed_addr constant [8 x i8] c"unknown\00"
@.str.39646 = private unnamed_addr constant [8 x i8] c"Boolean\00"
@.str.39678 = private unnamed_addr constant [7 x i8] c"Double\00"
@.str.39710 = private unnamed_addr constant [5 x i8] c"Long\00"
@.str.39742 = private unnamed_addr constant [5 x i8] c"Char\00"
@.str.39778 = private unnamed_addr constant [4 x i8] c"ptr\00"
@.str.39804 = private unnamed_addr constant [7 x i8] c"return\00"
@.str.39835 = private unnamed_addr constant [2 x i8] c";\00"
@.str.39843 = private unnamed_addr constant [11 x i8] c"  ret i32 \00"
@.str.39854 = private unnamed_addr constant [2 x i8] c"\0A\00"
@.str.39891 = private unnamed_addr constant [2 x i8] c";\00"
@.str.39929 = private unnamed_addr constant [8 x i8] c"Boolean\00"
@.str.39947 = private unnamed_addr constant [2 x i8] c"%\00"
@.str.39951 = private unnamed_addr constant [5 x i8] c".ret\00"
@.str.39954 = private unnamed_addr constant [24 x i8] c"  %ret.bool = zext i1 %\00"
@.str.39958 = private unnamed_addr constant [13 x i8] c".ret to i32\0A\00"
@.str.39960 = private unnamed_addr constant [21 x i8] c"  ret i32 %ret.bool\0A\00"
@.str.39976 = private unnamed_addr constant [7 x i8] c"Double\00"
@.str.39994 = private unnamed_addr constant [2 x i8] c"%\00"
@.str.39998 = private unnamed_addr constant [5 x i8] c".ret\00"
@.str.40001 = private unnamed_addr constant [32 x i8] c"  %ret.double = fptosi double %\00"
@.str.40005 = private unnamed_addr constant [13 x i8] c".ret to i32\0A\00"
@.str.40007 = private unnamed_addr constant [23 x i8] c"  ret i32 %ret.double\0A\00"
@.str.40031 = private unnamed_addr constant [2 x i8] c"%\00"
@.str.40035 = private unnamed_addr constant [5 x i8] c".ret\00"
@.str.40038 = private unnamed_addr constant [12 x i8] c"  ret i32 %\00"
@.str.40042 = private unnamed_addr constant [6 x i8] c".ret\0A\00"
@.str.40066 = private unnamed_addr constant [5 x i8] c"%ret\00"
@.str.40069 = private unnamed_addr constant [16 x i8] c"  ret i32 %ret\0A\00"
@.str.40085 = private unnamed_addr constant [3 x i8] c"if\00"
@.str.40110 = private unnamed_addr constant [6 x i8] c"while\00"
@.str.40135 = private unnamed_addr constant [4 x i8] c"for\00"
@.str.40161 = private unnamed_addr constant [6 x i8] c"value\00"
@.str.40169 = private unnamed_addr constant [9 x i8] c"variable\00"
@.str.40177 = private unnamed_addr constant [7 x i8] c"return\00"
@.str.40185 = private unnamed_addr constant [3 x i8] c"if\00"
@.str.40193 = private unnamed_addr constant [6 x i8] c"while\00"
@.str.40201 = private unnamed_addr constant [4 x i8] c"for\00"
@.str.40281 = private unnamed_addr constant [8 x i8] c"Boolean\00"
@.str.40306 = private unnamed_addr constant [7 x i8] c"Double\00"
@.str.40331 = private unnamed_addr constant [5 x i8] c"Long\00"
@.str.40356 = private unnamed_addr constant [5 x i8] c"Char\00"
@.str.40384 = private unnamed_addr constant [4 x i8] c"ptr\00"
@.str.40410 = private unnamed_addr constant [8 x i8] c"Boolean\00"
@.str.40418 = private unnamed_addr constant [7 x i8] c"Double\00"
@.str.40426 = private unnamed_addr constant [5 x i8] c"Long\00"
@.str.40434 = private unnamed_addr constant [5 x i8] c"Char\00"
@.str.40445 = private unnamed_addr constant [4 x i8] c"ptr\00"
@.str.40515 = private unnamed_addr constant [13 x i8] c"  ret i32 0\0A\00"
@.str.40582 = private unnamed_addr constant [1 x i8] c"\00"
@.str.40605 = private unnamed_addr constant [1 x i8] c"\00"
@.str.40622 = private unnamed_addr constant [1 x i8] c"\00"
@.str.40668 = private unnamed_addr constant [8 x i8] c"unknown\00"
@.str.40684 = private unnamed_addr constant [2 x i8] c":\00"
@.str.40712 = private unnamed_addr constant [3 x i8] c", \00"
@.str.40724 = private unnamed_addr constant [7 x i8] c" %arg.\00"
@.str.40755 = private unnamed_addr constant [2 x i8] c",\00"
@.str.40834 = private unnamed_addr constant [1 x i8] c"\00"
@.str.40855 = private unnamed_addr constant [2 x i8] c"(\00"
@.str.40857 = private unnamed_addr constant [2 x i8] c")\00"
@.str.40868 = private unnamed_addr constant [1 x i8] c"\00"
@.str.40885 = private unnamed_addr constant [1 x i8] c"\00"
@.str.40936 = private unnamed_addr constant [8 x i8] c"unknown\00"
@.str.40952 = private unnamed_addr constant [2 x i8] c":\00"
@.str.40984 = private unnamed_addr constant [4 x i8] c"  %\00"
@.str.40988 = private unnamed_addr constant [11 x i8] c" = alloca \00"
@.str.40992 = private unnamed_addr constant [2 x i8] c"\0A\00"
@.str.40994 = private unnamed_addr constant [9 x i8] c"  store \00"
@.str.40998 = private unnamed_addr constant [7 x i8] c" %arg.\00"
@.str.41002 = private unnamed_addr constant [8 x i8] c", ptr %\00"
@.str.41006 = private unnamed_addr constant [2 x i8] c"\0A\00"
@.str.41026 = private unnamed_addr constant [2 x i8] c",\00"
@.str.41137 = private unnamed_addr constant [7 x i8] c"return\00"
@.str.41148 = private unnamed_addr constant [6 x i8] c"%ret.\00"
@.str.41273 = private unnamed_addr constant [3 x i8] c"  \00"
@.str.41277 = private unnamed_addr constant [28 x i8] c".left.i32 = load i32, ptr %\00"
@.str.41281 = private unnamed_addr constant [2 x i8] c"\0A\00"
@.str.41283 = private unnamed_addr constant [3 x i8] c"  \00"
@.str.41287 = private unnamed_addr constant [25 x i8] c".right.i32 = add i32 0, \00"
@.str.41298 = private unnamed_addr constant [2 x i8] c"\0A\00"
@.str.41300 = private unnamed_addr constant [3 x i8] c"  \00"
@.str.41304 = private unnamed_addr constant [9 x i8] c" = icmp \00"
@.str.41308 = private unnamed_addr constant [6 x i8] c" i32 \00"
@.str.41312 = private unnamed_addr constant [12 x i8] c".left.i32, \00"
@.str.41316 = private unnamed_addr constant [12 x i8] c".right.i32\0A\00"
@.str.41318 = private unnamed_addr constant [10 x i8] c"  ret i1 \00"
@.str.41322 = private unnamed_addr constant [2 x i8] c"\0A\00"
@.str.41359 = private unnamed_addr constant [2 x i8] c";\00"
@.str.41380 = private unnamed_addr constant [10 x i8] c"  ret i1 \00"
@.str.41384 = private unnamed_addr constant [2 x i8] c"\0A\00"
@.str.41421 = private unnamed_addr constant [2 x i8] c";\00"
@.str.41429 = private unnamed_addr constant [3 x i8] c"  \00"
@.str.41433 = private unnamed_addr constant [18 x i8] c" = load i1, ptr %\00"
@.str.41453 = private unnamed_addr constant [2 x i8] c"\0A\00"
@.str.41455 = private unnamed_addr constant [10 x i8] c"  ret i1 \00"
@.str.41459 = private unnamed_addr constant [2 x i8] c"\0A\00"
@.str.41486 = private unnamed_addr constant [10 x i8] c"  ret i1 \00"
@.str.41490 = private unnamed_addr constant [2 x i8] c"\0A\00"
@.str.41507 = private unnamed_addr constant [3 x i8] c"if\00"
@.str.41566 = private unnamed_addr constant [2 x i8] c"{\00"
@.str.41568 = private unnamed_addr constant [2 x i8] c"}\00"
@.str.41594 = private unnamed_addr constant [18 x i8] c"  ; malformed if\0A\00"
@.str.41605 = private unnamed_addr constant [1 x i8] c"\00"
@.str.41628 = private unnamed_addr constant [1 x i8] c"\00"
@.str.41635 = private unnamed_addr constant [20 x i8] c"  br label %if.end.\00"
@.str.41639 = private unnamed_addr constant [2 x i8] c"\0A\00"
@.str.41670 = private unnamed_addr constant [1 x i8] c"\00"
@.str.41694 = private unnamed_addr constant [1 x i8] c"\00"
@.str.41701 = private unnamed_addr constant [20 x i8] c"  br label %if.end.\00"
@.str.41705 = private unnamed_addr constant [2 x i8] c"\0A\00"
@.str.41723 = private unnamed_addr constant [5 x i8] c"else\00"
@.str.41753 = private unnamed_addr constant [3 x i8] c"if\00"
@.str.41782 = private unnamed_addr constant [2 x i8] c"{\00"
@.str.41799 = private unnamed_addr constant [2 x i8] c"{\00"
@.str.41801 = private unnamed_addr constant [2 x i8] c"}\00"
@.str.41840 = private unnamed_addr constant [1 x i8] c"\00"
@.str.41876 = private unnamed_addr constant [7 x i8] c"%cond.\00"
@.str.41881 = private unnamed_addr constant [15 x i8] c"  br i1 %cond.\00"
@.str.41885 = private unnamed_addr constant [18 x i8] c", label %if.then.\00"
@.str.41889 = private unnamed_addr constant [18 x i8] c", label %if.else.\00"
@.str.41893 = private unnamed_addr constant [2 x i8] c"\0A\00"
@.str.41895 = private unnamed_addr constant [9 x i8] c"if.then.\00"
@.str.41899 = private unnamed_addr constant [3 x i8] c":\0A\00"
@.str.41905 = private unnamed_addr constant [9 x i8] c"if.else.\00"
@.str.41909 = private unnamed_addr constant [3 x i8] c":\0A\00"
@.str.41915 = private unnamed_addr constant [8 x i8] c"if.end.\00"
@.str.41919 = private unnamed_addr constant [3 x i8] c":\0A\00"
@.str.41955 = private unnamed_addr constant [16 x i8] c"  ret i1 false\0A\00"
@.str.42047 = private unnamed_addr constant [7 x i8] c"return\00"
@.str.42078 = private unnamed_addr constant [2 x i8] c";\00"
@.str.42086 = private unnamed_addr constant [10 x i8] c"  ret i8 \00"
@.str.42100 = private unnamed_addr constant [2 x i8] c"\0A\00"
@.str.42137 = private unnamed_addr constant [2 x i8] c";\00"
@.str.42145 = private unnamed_addr constant [24 x i8] c"  %ret = load i8, ptr %\00"
@.str.42165 = private unnamed_addr constant [2 x i8] c"\0A\00"
@.str.42167 = private unnamed_addr constant [15 x i8] c"  ret i8 %ret\0A\00"
@.str.42210 = private unnamed_addr constant [2 x i8] c"(\00"
@.str.42229 = private unnamed_addr constant [2 x i8] c"(\00"
@.str.42231 = private unnamed_addr constant [2 x i8] c")\00"
@.str.42248 = private unnamed_addr constant [6 x i8] c"%ret.\00"
@.str.42269 = private unnamed_addr constant [3 x i8] c"  \00"
@.str.42273 = private unnamed_addr constant [13 x i8] c" = call i8 @\00"
@.str.42287 = private unnamed_addr constant [2 x i8] c"(\00"
@.str.42302 = private unnamed_addr constant [3 x i8] c")\0A\00"
@.str.42304 = private unnamed_addr constant [10 x i8] c"  ret i8 \00"
@.str.42308 = private unnamed_addr constant [2 x i8] c"\0A\00"
@.str.42348 = private unnamed_addr constant [12 x i8] c"  ret i8 0\0A\00"
@.str.42440 = private unnamed_addr constant [7 x i8] c"return\00"
@.str.42486 = private unnamed_addr constant [2 x i8] c";\00"
@.str.42504 = private unnamed_addr constant [5 x i8] c"%ret\00"
@.str.42507 = private unnamed_addr constant [19 x i8] c"  ret double %ret\0A\00"
@.str.42544 = private unnamed_addr constant [2 x i8] c";\00"
@.str.42552 = private unnamed_addr constant [28 x i8] c"  %ret = load double, ptr %\00"
@.str.42572 = private unnamed_addr constant [2 x i8] c"\0A\00"
@.str.42574 = private unnamed_addr constant [19 x i8] c"  ret double %ret\0A\00"
@.str.42598 = private unnamed_addr constant [5 x i8] c"%ret\00"
@.str.42601 = private unnamed_addr constant [19 x i8] c"  ret double %ret\0A\00"
@.str.42639 = private unnamed_addr constant [27 x i8] c"  ret double 0.000000e+00\0A\00"
@.str.42731 = private unnamed_addr constant [7 x i8] c"return\00"
@.str.42762 = private unnamed_addr constant [2 x i8] c";\00"
@.str.42780 = private unnamed_addr constant [5 x i8] c"%ret\00"
@.str.42783 = private unnamed_addr constant [16 x i8] c"  ret i64 %ret\0A\00"
@.str.42820 = private unnamed_addr constant [2 x i8] c";\00"
@.str.42828 = private unnamed_addr constant [25 x i8] c"  %ret = load i64, ptr %\00"
@.str.42848 = private unnamed_addr constant [2 x i8] c"\0A\00"
@.str.42850 = private unnamed_addr constant [16 x i8] c"  ret i64 %ret\0A\00"
@.str.42874 = private unnamed_addr constant [5 x i8] c"%ret\00"
@.str.42877 = private unnamed_addr constant [16 x i8] c"  ret i64 %ret\0A\00"
@.str.42915 = private unnamed_addr constant [13 x i8] c"  ret i64 0\0A\00"
@.str.43031 = private unnamed_addr constant [7 x i8] c"return\00"
@.str.43040 = private unnamed_addr constant [6 x i8] c"%ret.\00"
@.str.43071 = private unnamed_addr constant [2 x i8] c";\00"
@.str.43103 = private unnamed_addr constant [3 x i8] c"  \00"
@.str.43107 = private unnamed_addr constant [28 x i8] c" = getelementptr inbounds [\00"
@.str.43111 = private unnamed_addr constant [19 x i8] c" x i8], ptr @.str.\00"
@.str.43119 = private unnamed_addr constant [16 x i8] c", i32 0, i32 0\0A\00"
@.str.43121 = private unnamed_addr constant [11 x i8] c"  ret ptr \00"
@.str.43125 = private unnamed_addr constant [2 x i8] c"\0A\00"
@.str.43162 = private unnamed_addr constant [2 x i8] c"(\00"
@.str.43181 = private unnamed_addr constant [2 x i8] c"(\00"
@.str.43183 = private unnamed_addr constant [2 x i8] c")\00"
@.str.43212 = private unnamed_addr constant [11 x i8] c"  ret ptr \00"
@.str.43216 = private unnamed_addr constant [2 x i8] c"\0A\00"
@.str.43254 = private unnamed_addr constant [2 x i8] c";\00"
@.str.43262 = private unnamed_addr constant [3 x i8] c"  \00"
@.str.43266 = private unnamed_addr constant [19 x i8] c" = load ptr, ptr %\00"
@.str.43286 = private unnamed_addr constant [2 x i8] c"\0A\00"
@.str.43288 = private unnamed_addr constant [11 x i8] c"  ret ptr \00"
@.str.43292 = private unnamed_addr constant [2 x i8] c"\0A\00"
@.str.43333 = private unnamed_addr constant [11 x i8] c"  ret ptr \00"
@.str.43337 = private unnamed_addr constant [2 x i8] c"\0A\00"
@.str.43351 = private unnamed_addr constant [16 x i8] c"  ret ptr null\0A\00"
@.str.43368 = private unnamed_addr constant [6 x i8] c"value\00"
@.str.43375 = private unnamed_addr constant [9 x i8] c"variable\00"
@.str.43401 = private unnamed_addr constant [3 x i8] c"if\00"
@.str.43460 = private unnamed_addr constant [2 x i8] c"{\00"
@.str.43462 = private unnamed_addr constant [2 x i8] c"}\00"
@.str.43488 = private unnamed_addr constant [18 x i8] c"  ; malformed if\0A\00"
@.str.43499 = private unnamed_addr constant [1 x i8] c"\00"
@.str.43522 = private unnamed_addr constant [1 x i8] c"\00"
@.str.43529 = private unnamed_addr constant [20 x i8] c"  br label %if.end.\00"
@.str.43533 = private unnamed_addr constant [2 x i8] c"\0A\00"
@.str.43564 = private unnamed_addr constant [1 x i8] c"\00"
@.str.43588 = private unnamed_addr constant [1 x i8] c"\00"
@.str.43595 = private unnamed_addr constant [20 x i8] c"  br label %if.end.\00"
@.str.43599 = private unnamed_addr constant [2 x i8] c"\0A\00"
@.str.43617 = private unnamed_addr constant [5 x i8] c"else\00"
@.str.43647 = private unnamed_addr constant [2 x i8] c"{\00"
@.str.43664 = private unnamed_addr constant [2 x i8] c"{\00"
@.str.43666 = private unnamed_addr constant [2 x i8] c"}\00"
@.str.43705 = private unnamed_addr constant [1 x i8] c"\00"
@.str.43741 = private unnamed_addr constant [7 x i8] c"%cond.\00"
@.str.43746 = private unnamed_addr constant [15 x i8] c"  br i1 %cond.\00"
@.str.43750 = private unnamed_addr constant [18 x i8] c", label %if.then.\00"
@.str.43754 = private unnamed_addr constant [18 x i8] c", label %if.else.\00"
@.str.43758 = private unnamed_addr constant [2 x i8] c"\0A\00"
@.str.43760 = private unnamed_addr constant [9 x i8] c"if.then.\00"
@.str.43764 = private unnamed_addr constant [3 x i8] c":\0A\00"
@.str.43770 = private unnamed_addr constant [9 x i8] c"if.else.\00"
@.str.43774 = private unnamed_addr constant [3 x i8] c":\0A\00"
@.str.43780 = private unnamed_addr constant [8 x i8] c"if.end.\00"
@.str.43784 = private unnamed_addr constant [3 x i8] c":\0A\00"
@.str.43850 = private unnamed_addr constant [16 x i8] c"  ret ptr null\0A\00"
@.str.43942 = private unnamed_addr constant [7 x i8] c"return\00"
@.str.43950 = private unnamed_addr constant [12 x i8] c"  ret void\0A\00"
@.str.43988 = private unnamed_addr constant [12 x i8] c"  ret void\0A\00"
@.str.44102 = private unnamed_addr constant [7 x i8] c"@.str.\00"
@.str.44106 = private unnamed_addr constant [35 x i8] c" = private unnamed_addr constant [\00"
@.str.44110 = private unnamed_addr constant [10 x i8] c" x i8] c\22\00"
@.str.44117 = private unnamed_addr constant [3 x i8] c"\22\0A\00"
@.str.44141 = private unnamed_addr constant [2 x i8] c"\0A\00"
@.str.44191 = private unnamed_addr constant [5 x i8] c"main\00"
@.str.44197 = private unnamed_addr constant [15 x i8] c"csec_user_main\00"
@.str.44338 = private unnamed_addr constant [5 x i8] c"Char\00"
@.str.44360 = private unnamed_addr constant [12 x i8] c"define i8 @\00"
@.str.44364 = private unnamed_addr constant [13 x i8] c"() {\0Aentry:\0A\00"
@.str.44366 = private unnamed_addr constant [10 x i8] c"  ret i8 \00"
@.str.44378 = private unnamed_addr constant [5 x i8] c"\0A}\0A\0A\00"
@.str.44387 = private unnamed_addr constant [4 x i8] c"Int\00"
@.str.44409 = private unnamed_addr constant [13 x i8] c"define i32 @\00"
@.str.44413 = private unnamed_addr constant [13 x i8] c"() {\0Aentry:\0A\00"
@.str.44415 = private unnamed_addr constant [11 x i8] c"  ret i32 \00"
@.str.44424 = private unnamed_addr constant [5 x i8] c"\0A}\0A\0A\00"
@.str.44433 = private unnamed_addr constant [8 x i8] c"Boolean\00"
@.str.44455 = private unnamed_addr constant [12 x i8] c"define i1 @\00"
@.str.44459 = private unnamed_addr constant [13 x i8] c"() {\0Aentry:\0A\00"
@.str.44461 = private unnamed_addr constant [10 x i8] c"  ret i1 \00"
@.str.44470 = private unnamed_addr constant [5 x i8] c"\0A}\0A\0A\00"
@.str.44482 = private unnamed_addr constant [4 x i8] c"ptr\00"
@.str.44526 = private unnamed_addr constant [13 x i8] c"define ptr @\00"
@.str.44530 = private unnamed_addr constant [13 x i8] c"() {\0Aentry:\0A\00"
@.str.44532 = private unnamed_addr constant [34 x i8] c"  %ret = getelementptr inbounds [\00"
@.str.44536 = private unnamed_addr constant [19 x i8] c" x i8], ptr @.str.\00"
@.str.44540 = private unnamed_addr constant [16 x i8] c", i32 0, i32 0\0A\00"
@.str.44542 = private unnamed_addr constant [19 x i8] c"  ret ptr %ret\0A}\0A\0A\00"
@.str.44558 = private unnamed_addr constant [1 x i8] c"\00"
@.str.44570 = private unnamed_addr constant [4 x i8] c"ptr\00"
@.str.44650 = private unnamed_addr constant [6 x i8] c"value\00"
@.str.44662 = private unnamed_addr constant [9 x i8] c"variable\00"
@.str.44675 = private unnamed_addr constant [7 x i8] c"return\00"
@.str.44703 = private unnamed_addr constant [2 x i8] c";\00"
@.str.44742 = private unnamed_addr constant [7 x i8] c".addr.\00"
@.str.44747 = private unnamed_addr constant [13 x i8] c"define ptr @\00"
@.str.44751 = private unnamed_addr constant [2 x i8] c"(\00"
@.str.44760 = private unnamed_addr constant [5 x i8] c") {\0A\00"
@.str.44762 = private unnamed_addr constant [8 x i8] c"entry:\0A\00"
@.str.44780 = private unnamed_addr constant [25 x i8] c"  %ret = load ptr, ptr %\00"
@.str.44784 = private unnamed_addr constant [2 x i8] c"\0A\00"
@.str.44786 = private unnamed_addr constant [19 x i8] c"  ret ptr %ret\0A}\0A\0A\00"
@.str.44891 = private unnamed_addr constant [5 x i8] c"Char\00"
@.str.44898 = private unnamed_addr constant [7 x i8] c"Double\00"
@.str.44905 = private unnamed_addr constant [5 x i8] c"Long\00"
@.str.44919 = private unnamed_addr constant [6 x i8] c"value\00"
@.str.44931 = private unnamed_addr constant [9 x i8] c"variable\00"
@.str.44958 = private unnamed_addr constant [2 x i8] c"=\00"
@.str.44970 = private unnamed_addr constant [7 x i8] c"return\00"
@.str.44994 = private unnamed_addr constant [5 x i8] c"Char\00"
@.str.44999 = private unnamed_addr constant [12 x i8] c"define i8 @\00"
@.str.45003 = private unnamed_addr constant [13 x i8] c"() {\0Aentry:\0A\00"
@.str.45005 = private unnamed_addr constant [10 x i8] c"  ret i8 \00"
@.str.45019 = private unnamed_addr constant [5 x i8] c"\0A}\0A\0A\00"
@.str.45028 = private unnamed_addr constant [7 x i8] c"Double\00"
@.str.45033 = private unnamed_addr constant [16 x i8] c"define double @\00"
@.str.45037 = private unnamed_addr constant [13 x i8] c"() {\0Aentry:\0A\00"
@.str.45039 = private unnamed_addr constant [14 x i8] c"  ret double \00"
@.str.45050 = private unnamed_addr constant [5 x i8] c"\0A}\0A\0A\00"
@.str.45054 = private unnamed_addr constant [13 x i8] c"define i64 @\00"
@.str.45058 = private unnamed_addr constant [13 x i8] c"() {\0Aentry:\0A\00"
@.str.45060 = private unnamed_addr constant [11 x i8] c"  ret i64 \00"
@.str.45071 = private unnamed_addr constant [5 x i8] c"\0A}\0A\0A\00"
@.str.45080 = private unnamed_addr constant [4 x i8] c"Int\00"
@.str.45121 = private unnamed_addr constant [7 x i8] c"return\00"
@.str.45149 = private unnamed_addr constant [2 x i8] c"(\00"
@.str.45168 = private unnamed_addr constant [2 x i8] c"(\00"
@.str.45170 = private unnamed_addr constant [2 x i8] c")\00"
@.str.45187 = private unnamed_addr constant [6 x i8] c"%ret.\00"
@.str.45192 = private unnamed_addr constant [13 x i8] c"define i32 @\00"
@.str.45196 = private unnamed_addr constant [2 x i8] c"(\00"
@.str.45205 = private unnamed_addr constant [5 x i8] c") {\0A\00"
@.str.45207 = private unnamed_addr constant [8 x i8] c"entry:\0A\00"
@.str.45229 = private unnamed_addr constant [3 x i8] c"  \00"
@.str.45233 = private unnamed_addr constant [14 x i8] c" = call i32 @\00"
@.str.45247 = private unnamed_addr constant [2 x i8] c"(\00"
@.str.45262 = private unnamed_addr constant [3 x i8] c")\0A\00"
@.str.45264 = private unnamed_addr constant [11 x i8] c"  ret i32 \00"
@.str.45268 = private unnamed_addr constant [5 x i8] c"\0A}\0A\0A\00"
@.str.45287 = private unnamed_addr constant [13 x i8] c"define i32 @\00"
@.str.45291 = private unnamed_addr constant [2 x i8] c"(\00"
@.str.45300 = private unnamed_addr constant [5 x i8] c") {\0A\00"
@.str.45302 = private unnamed_addr constant [8 x i8] c"entry:\0A\00"
@.str.45313 = private unnamed_addr constant [4 x i8] c"}\0A\0A\00"
@.str.45322 = private unnamed_addr constant [8 x i8] c"Boolean\00"
@.str.45327 = private unnamed_addr constant [12 x i8] c"define i1 @\00"
@.str.45331 = private unnamed_addr constant [2 x i8] c"(\00"
@.str.45340 = private unnamed_addr constant [5 x i8] c") {\0A\00"
@.str.45342 = private unnamed_addr constant [8 x i8] c"entry:\0A\00"
@.str.45360 = private unnamed_addr constant [4 x i8] c"}\0A\0A\00"
@.str.45369 = private unnamed_addr constant [5 x i8] c"Char\00"
@.str.45374 = private unnamed_addr constant [12 x i8] c"define i8 @\00"
@.str.45378 = private unnamed_addr constant [2 x i8] c"(\00"
@.str.45387 = private unnamed_addr constant [5 x i8] c") {\0A\00"
@.str.45389 = private unnamed_addr constant [8 x i8] c"entry:\0A\00"
@.str.45407 = private unnamed_addr constant [4 x i8] c"}\0A\0A\00"
@.str.45416 = private unnamed_addr constant [7 x i8] c"Double\00"
@.str.45421 = private unnamed_addr constant [16 x i8] c"define double @\00"
@.str.45425 = private unnamed_addr constant [2 x i8] c"(\00"
@.str.45434 = private unnamed_addr constant [5 x i8] c") {\0A\00"
@.str.45436 = private unnamed_addr constant [8 x i8] c"entry:\0A\00"
@.str.45454 = private unnamed_addr constant [4 x i8] c"}\0A\0A\00"
@.str.45463 = private unnamed_addr constant [5 x i8] c"Long\00"
@.str.45468 = private unnamed_addr constant [13 x i8] c"define i64 @\00"
@.str.45472 = private unnamed_addr constant [2 x i8] c"(\00"
@.str.45481 = private unnamed_addr constant [5 x i8] c") {\0A\00"
@.str.45483 = private unnamed_addr constant [8 x i8] c"entry:\0A\00"
@.str.45501 = private unnamed_addr constant [4 x i8] c"}\0A\0A\00"
@.str.45510 = private unnamed_addr constant [5 x i8] c"Unit\00"
@.str.45515 = private unnamed_addr constant [14 x i8] c"define void @\00"
@.str.45519 = private unnamed_addr constant [2 x i8] c"(\00"
@.str.45528 = private unnamed_addr constant [5 x i8] c") {\0A\00"
@.str.45530 = private unnamed_addr constant [8 x i8] c"entry:\0A\00"
@.str.45548 = private unnamed_addr constant [4 x i8] c"}\0A\0A\00"
@.str.45560 = private unnamed_addr constant [4 x i8] c"ptr\00"
@.str.45565 = private unnamed_addr constant [13 x i8] c"define ptr @\00"
@.str.45569 = private unnamed_addr constant [2 x i8] c"(\00"
@.str.45578 = private unnamed_addr constant [5 x i8] c") {\0A\00"
@.str.45580 = private unnamed_addr constant [8 x i8] c"entry:\0A\00"
@.str.45598 = private unnamed_addr constant [4 x i8] c"}\0A\0A\00"
@.str.45602 = private unnamed_addr constant [1 x i8] c"\00"
@.str.45628 = private unnamed_addr constant [30 x i8] c"; ModuleID = 'csec.selfhost'\0A\00"
@.str.45640 = private unnamed_addr constant [36 x i8] c"source_filename = \22csec.selfhost\22\0A\0A\00"
@.str.45652 = private unnamed_addr constant [38 x i8] c"declare i64 @csec_string_length(ptr)\0A\00"
@.str.45664 = private unnamed_addr constant [44 x i8] c"declare i8 @csec_string_char_at(ptr, i32)\0A\0A\00"
@.str.45676 = private unnamed_addr constant [40 x i8] c"declare i32 @csec_lex_quoted(ptr, i32)\0A\00"
@.str.45688 = private unnamed_addr constant [40 x i8] c"declare i32 @csec_lex_number(ptr, i32)\0A\00"
@.str.45700 = private unnamed_addr constant [44 x i8] c"declare i32 @csec_lex_identifier(ptr, i32)\0A\00"
@.str.45712 = private unnamed_addr constant [46 x i8] c"declare i32 @csec_lex_line_comment(ptr, i32)\0A\00"
@.str.45724 = private unnamed_addr constant [47 x i8] c"declare i32 @csec_lex_block_comment(ptr, i32)\0A\00"
@.str.45736 = private unnamed_addr constant [35 x i8] c"declare i32 @csec_digit_value(i8)\0A\00"
@.str.45748 = private unnamed_addr constant [35 x i8] c"declare i32 @csec_is_keyword(ptr)\0A\00"
@.str.45760 = private unnamed_addr constant [31 x i8] c"declare i32 @csec_to_int(ptr)\0A\00"
@.str.45772 = private unnamed_addr constant [40 x i8] c"declare i32 @csec_line_start(ptr, i32)\0A\00"
@.str.45784 = private unnamed_addr constant [38 x i8] c"declare i32 @csec_line_end(ptr, i32)\0A\00"
@.str.45796 = private unnamed_addr constant [42 x i8] c"declare i32 @csec_validate_balanced(ptr)\0A\00"
@.str.45808 = private unnamed_addr constant [58 x i8] c"declare i32 @csec_starts_top_level_declaration(ptr, i32)\0A\00"
@.str.45820 = private unnamed_addr constant [43 x i8] c"declare i32 @csec_validate_top_level(ptr)\0A\00"
@.str.45832 = private unnamed_addr constant [49 x i8] c"declare ptr @csec_top_level_decl_kind(ptr, i32)\0A\00"
@.str.45844 = private unnamed_addr constant [49 x i8] c"declare ptr @csec_top_level_decl_name(ptr, i32)\0A\00"
@.str.45856 = private unnamed_addr constant [51 x i8] c"declare i32 @csec_count_function_params(ptr, i32)\0A\00"
@.str.45868 = private unnamed_addr constant [62 x i8] c"declare i32 @csec_token_is_top_level_operator(ptr, i32, i32)\0A\00"
@.str.45880 = private unnamed_addr constant [63 x i8] c"declare i32 @csec_find_top_level_operator(ptr, i32, i32, i32)\0A\00"
@.str.45892 = private unnamed_addr constant [55 x i8] c"declare i32 @csec_find_top_level_match(ptr, i32, i32)\0A\00"
@.str.45904 = private unnamed_addr constant [52 x i8] c"declare i32 @csec_find_lambda_arrow(ptr, i32, i32)\0A\00"
@.str.45916 = private unnamed_addr constant [46 x i8] c"declare ptr @csec_generate_symbol_table(ptr)\0A\00"
@.str.45928 = private unnamed_addr constant [58 x i8] c"declare ptr @csec_append_expression_until(ptr, i32, i32)\0A\00"
@.str.45940 = private unnamed_addr constant [58 x i8] c"declare ptr @csec_generate_expression_ast(ptr, i32, i32)\0A\00"
@.str.45952 = private unnamed_addr constant [57 x i8] c"declare ptr @csec_generate_statement_ast(ptr, i32, i32)\0A\00"
@.str.45964 = private unnamed_addr constant [52 x i8] c"declare ptr @csec_generate_body_ast(ptr, i32, i32)\0A\00"
@.str.45976 = private unnamed_addr constant [55 x i8] c"declare i32 @csec_find_function_param_start(ptr, i32)\0A\00"
@.str.45988 = private unnamed_addr constant [55 x i8] c"declare ptr @csec_generate_c_body(ptr, i32, i32, ptr)\0A\00"
@.str.46000 = private unnamed_addr constant [56 x i8] c"declare ptr @csec_generate_c_expression(ptr, i32, i32)\0A\00"
@.str.46012 = private unnamed_addr constant [41 x i8] c"declare ptr @csec_ir_operator_name(ptr)\0A\00"
@.str.46024 = private unnamed_addr constant [37 x i8] c"declare ptr @csec_ir_type_name(ptr)\0A\00"
@.str.46036 = private unnamed_addr constant [64 x i8] c"declare i32 @csec_expression_top_level_operator(ptr, i32, i32)\0A\00"
@.str.46048 = private unnamed_addr constant [64 x i8] c"declare i32 @csec_find_token_text_in_range(ptr, i32, i32, ptr)\0A\00"
@.str.46060 = private unnamed_addr constant [63 x i8] c"declare i32 @csec_find_closing_token(ptr, i32, i32, ptr, ptr)\0A\00"
@.str.46072 = private unnamed_addr constant [61 x i8] c"declare i32 @csec_find_statement_paren_start(ptr, i32, i32)\0A\00"
@.str.46084 = private unnamed_addr constant [59 x i8] c"declare i32 @csec_find_statement_paren_end(ptr, i32, i32)\0A\00"
@.str.46096 = private unnamed_addr constant [61 x i8] c"declare i32 @csec_find_statement_block_start(ptr, i32, i32)\0A\00"
@.str.46108 = private unnamed_addr constant [59 x i8] c"declare i32 @csec_find_statement_block_end(ptr, i32, i32)\0A\00"
@.str.46120 = private unnamed_addr constant [56 x i8] c"declare i32 @csec_count_comma_separated(ptr, i32, i32)\0A\00"
@.str.46132 = private unnamed_addr constant [65 x i8] c"declare i32 @csec_find_last_top_level_token(ptr, i32, i32, ptr)\0A\00"
@.str.46144 = private unnamed_addr constant [53 x i8] c"declare ptr @csec_llvm_lexer_helper_definition(ptr)\0A\00"
@.str.46156 = private unnamed_addr constant [40 x i8] c"declare i64 @csec_string_builder_new()\0A\00"
@.str.46168 = private unnamed_addr constant [48 x i8] c"declare i64 @csec_string_builder_new_file(ptr)\0A\00"
@.str.46180 = private unnamed_addr constant [51 x i8] c"declare i32 @csec_string_builder_append(i64, ptr)\0A\00"
@.str.46192 = private unnamed_addr constant [46 x i8] c"declare ptr @csec_string_builder_finish(i64)\0A\00"
@.str.46204 = private unnamed_addr constant [58 x i8] c"declare i32 @csec_string_builder_write_to_file(i64, ptr)\0A\00"
@.str.46216 = private unnamed_addr constant [52 x i8] c"declare void @csec_set_command_line_args(i32, ptr)\0A\00"
@.str.46228 = private unnamed_addr constant [44 x i8] c"declare i32 @csec_command_line_arg_count()\0A\00"
@.str.46240 = private unnamed_addr constant [41 x i8] c"declare ptr @csec_command_line_arg(i32)\0A\00"
@.str.46252 = private unnamed_addr constant [43 x i8] c"declare ptr @csec_file_read_all_text(ptr)\0A\00"
@.str.46264 = private unnamed_addr constant [49 x i8] c"declare i32 @csec_file_write_all_text(ptr, ptr)\0A\00"
@.str.46276 = private unnamed_addr constant [38 x i8] c"declare void @csec_print_string(ptr)\0A\00"
@.str.46288 = private unnamed_addr constant [36 x i8] c"declare void @csec_print_newline()\0A\00"
@.str.46300 = private unnamed_addr constant [43 x i8] c"declare ptr @csec_string_concat(ptr, ptr)\0A\00"
@.str.46312 = private unnamed_addr constant [43 x i8] c"declare i32 @csec_string_equals(ptr, ptr)\0A\00"
@.str.46324 = private unnamed_addr constant [48 x i8] c"declare i32 @csec_string_starts_with(ptr, ptr)\0A\00"
@.str.46336 = private unnamed_addr constant [51 x i8] c"declare ptr @csec_string_substring(ptr, i32, i32)\0A\00"
@.str.46348 = private unnamed_addr constant [38 x i8] c"declare ptr @csec_to_string_i64(i64)\0A\00"
@.str.46360 = private unnamed_addr constant [38 x i8] c"declare ptr @csec_to_string_char(i8)\0A\00"
@.str.46372 = private unnamed_addr constant [52 x i8] c"declare ptr @csec_token_append_owned(ptr, i8, ptr)\0A\00"
@.str.46384 = private unnamed_addr constant [39 x i8] c"declare i64 @csec_token_builder_new()\0A\00"
@.str.46396 = private unnamed_addr constant [54 x i8] c"declare i32 @csec_token_builder_append(i64, i8, ptr)\0A\00"
@.str.46408 = private unnamed_addr constant [45 x i8] c"declare ptr @csec_token_builder_finish(i64)\0A\00"
@.str.46420 = private unnamed_addr constant [40 x i8] c"declare ptr @csec_tokenize_source(ptr)\0A\00"
@.str.46432 = private unnamed_addr constant [42 x i8] c"declare i8 @csec_token_kind_at(ptr, i32)\0A\00"
@.str.46444 = private unnamed_addr constant [43 x i8] c"declare ptr @csec_token_text_at(ptr, i32)\0A\00"
@.str.46456 = private unnamed_addr constant [47 x i8] c"declare i32 @csec_token_is(ptr, i32, i8, ptr)\0A\00"
@.str.46468 = private unnamed_addr constant [52 x i8] c"declare i32 @csec_advance_statement(ptr, i32, i32)\0A\00"
@.str.46480 = private unnamed_addr constant [52 x i8] c"declare i32 @csec_advance_top_level_decl(ptr, i32)\0A\00"
@.str.46492 = private unnamed_addr constant [50 x i8] c"declare i32 @csec_find_decl_body_start(ptr, i32)\0A\00"
@.str.46504 = private unnamed_addr constant [48 x i8] c"declare i32 @csec_find_decl_body_end(ptr, i32)\0A\00"
@.str.46516 = private unnamed_addr constant [48 x i8] c"declare i32 @csec_function_param_end(ptr, i32)\0A\00"
@.str.46528 = private unnamed_addr constant [54 x i8] c"declare ptr @csec_function_llvm_param_list(ptr, i32)\0A\00"
@.str.46540 = private unnamed_addr constant [57 x i8] c"declare ptr @csec_function_llvm_param_allocas(ptr, i32)\0A\00"
@.str.46552 = private unnamed_addr constant [51 x i8] c"declare ptr @csec_llvm_name_with_number(ptr, i32)\0A\00"
@.str.46564 = private unnamed_addr constant [50 x i8] c"declare ptr @csec_llvm_string_literal_bytes(ptr)\0A\00"
@.str.46576 = private unnamed_addr constant [56 x i8] c"declare i32 @csec_llvm_string_literal_byte_length(ptr)\0A\00"
@.str.46588 = private unnamed_addr constant [53 x i8] c"declare ptr @csec_function_return_type_at(ptr, i32)\0A\00"
@.str.46600 = private unnamed_addr constant [52 x i8] c"declare ptr @csec_collect_type_name(ptr, i32, i32)\0A\00"
@.str.46612 = private unnamed_addr constant [59 x i8] c"declare i32 @csec_enclosing_function_decl_start(ptr, i32)\0A\00"
@.str.46624 = private unnamed_addr constant [59 x i8] c"declare i32 @csec_enclosing_function_body_start(ptr, i32)\0A\00"
@.str.46636 = private unnamed_addr constant [57 x i8] c"declare i32 @csec_enclosing_function_body_end(ptr, i32)\0A\00"
@.str.46648 = private unnamed_addr constant [57 x i8] c"declare ptr @csec_lookup_function_return_type(ptr, ptr)\0A\00"
@.str.46660 = private unnamed_addr constant [60 x i8] c"declare ptr @csec_lookup_visible_value_type(ptr, i32, ptr)\0A\00"
@.str.46672 = private unnamed_addr constant [62 x i8] c"declare ptr @csec_lookup_visible_storage_name(ptr, i32, ptr)\0A\00"
@.str.46684 = private unnamed_addr constant [40 x i8] c"declare ptr @csec_expand_imports(ptr)\0A\0A\00"
@.str.46749 = private unnamed_addr constant [4 x i8] c"def\00"
@.str.46770 = private unnamed_addr constant [9 x i8] c"external\00"
@.str.46786 = private unnamed_addr constant [5 x i8] c"main\00"
@.str.46803 = private unnamed_addr constant [42 x i8] c"define i32 @main(i32 %argc, ptr %argv) {\0A\00"
@.str.46805 = private unnamed_addr constant [8 x i8] c"entry:\0A\00"
@.str.46807 = private unnamed_addr constant [63 x i8] c"  call void @csec_set_command_line_args(i32 %argc, ptr %argv)\0A\00"
@.str.46809 = private unnamed_addr constant [37 x i8] c"  %ret = call i32 @csec_user_main()\0A\00"
@.str.46811 = private unnamed_addr constant [16 x i8] c"  ret i32 %ret\0A\00"
@.str.46813 = private unnamed_addr constant [3 x i8] c"}\0A\00"
@.str.46906 = private unnamed_addr constant [22 x i8] c"define i32 @main() {\0A\00"
@.str.46913 = private unnamed_addr constant [3 x i8] c"}\0A\00"
@.str.46952 = private unnamed_addr constant [1 x i8] c"\00"
@.str.46960 = private unnamed_addr constant [30 x i8] c"; ModuleID = 'csec.selfhost'\0A\00"
@.str.46962 = private unnamed_addr constant [36 x i8] c"source_filename = \22csec.selfhost\22\0A\0A\00"
@.str.46964 = private unnamed_addr constant [38 x i8] c"declare i64 @csec_string_length(ptr)\0A\00"
@.str.46966 = private unnamed_addr constant [44 x i8] c"declare i8 @csec_string_char_at(ptr, i32)\0A\0A\00"
@.str.46968 = private unnamed_addr constant [40 x i8] c"declare i32 @csec_lex_quoted(ptr, i32)\0A\00"
@.str.46970 = private unnamed_addr constant [40 x i8] c"declare i32 @csec_lex_number(ptr, i32)\0A\00"
@.str.46972 = private unnamed_addr constant [44 x i8] c"declare i32 @csec_lex_identifier(ptr, i32)\0A\00"
@.str.46974 = private unnamed_addr constant [46 x i8] c"declare i32 @csec_lex_line_comment(ptr, i32)\0A\00"
@.str.46976 = private unnamed_addr constant [47 x i8] c"declare i32 @csec_lex_block_comment(ptr, i32)\0A\00"
@.str.46978 = private unnamed_addr constant [35 x i8] c"declare i32 @csec_digit_value(i8)\0A\00"
@.str.46980 = private unnamed_addr constant [35 x i8] c"declare i32 @csec_is_keyword(ptr)\0A\00"
@.str.46982 = private unnamed_addr constant [31 x i8] c"declare i32 @csec_to_int(ptr)\0A\00"
@.str.46984 = private unnamed_addr constant [40 x i8] c"declare i32 @csec_line_start(ptr, i32)\0A\00"
@.str.46986 = private unnamed_addr constant [38 x i8] c"declare i32 @csec_line_end(ptr, i32)\0A\00"
@.str.46988 = private unnamed_addr constant [42 x i8] c"declare i32 @csec_validate_balanced(ptr)\0A\00"
@.str.46990 = private unnamed_addr constant [58 x i8] c"declare i32 @csec_starts_top_level_declaration(ptr, i32)\0A\00"
@.str.46992 = private unnamed_addr constant [43 x i8] c"declare i32 @csec_validate_top_level(ptr)\0A\00"
@.str.46994 = private unnamed_addr constant [49 x i8] c"declare ptr @csec_top_level_decl_kind(ptr, i32)\0A\00"
@.str.46996 = private unnamed_addr constant [49 x i8] c"declare ptr @csec_top_level_decl_name(ptr, i32)\0A\00"
@.str.46998 = private unnamed_addr constant [51 x i8] c"declare i32 @csec_count_function_params(ptr, i32)\0A\00"
@.str.47000 = private unnamed_addr constant [62 x i8] c"declare i32 @csec_token_is_top_level_operator(ptr, i32, i32)\0A\00"
@.str.47002 = private unnamed_addr constant [63 x i8] c"declare i32 @csec_find_top_level_operator(ptr, i32, i32, i32)\0A\00"
@.str.47004 = private unnamed_addr constant [55 x i8] c"declare i32 @csec_find_top_level_match(ptr, i32, i32)\0A\00"
@.str.47006 = private unnamed_addr constant [52 x i8] c"declare i32 @csec_find_lambda_arrow(ptr, i32, i32)\0A\00"
@.str.47008 = private unnamed_addr constant [46 x i8] c"declare ptr @csec_generate_symbol_table(ptr)\0A\00"
@.str.47010 = private unnamed_addr constant [58 x i8] c"declare ptr @csec_append_expression_until(ptr, i32, i32)\0A\00"
@.str.47012 = private unnamed_addr constant [58 x i8] c"declare ptr @csec_generate_expression_ast(ptr, i32, i32)\0A\00"
@.str.47014 = private unnamed_addr constant [57 x i8] c"declare ptr @csec_generate_statement_ast(ptr, i32, i32)\0A\00"
@.str.47016 = private unnamed_addr constant [52 x i8] c"declare ptr @csec_generate_body_ast(ptr, i32, i32)\0A\00"
@.str.47018 = private unnamed_addr constant [55 x i8] c"declare i32 @csec_find_function_param_start(ptr, i32)\0A\00"
@.str.47020 = private unnamed_addr constant [55 x i8] c"declare ptr @csec_generate_c_body(ptr, i32, i32, ptr)\0A\00"
@.str.47022 = private unnamed_addr constant [56 x i8] c"declare ptr @csec_generate_c_expression(ptr, i32, i32)\0A\00"
@.str.47024 = private unnamed_addr constant [41 x i8] c"declare ptr @csec_ir_operator_name(ptr)\0A\00"
@.str.47026 = private unnamed_addr constant [37 x i8] c"declare ptr @csec_ir_type_name(ptr)\0A\00"
@.str.47028 = private unnamed_addr constant [64 x i8] c"declare i32 @csec_expression_top_level_operator(ptr, i32, i32)\0A\00"
@.str.47030 = private unnamed_addr constant [64 x i8] c"declare i32 @csec_find_token_text_in_range(ptr, i32, i32, ptr)\0A\00"
@.str.47032 = private unnamed_addr constant [63 x i8] c"declare i32 @csec_find_closing_token(ptr, i32, i32, ptr, ptr)\0A\00"
@.str.47034 = private unnamed_addr constant [61 x i8] c"declare i32 @csec_find_statement_paren_start(ptr, i32, i32)\0A\00"
@.str.47036 = private unnamed_addr constant [59 x i8] c"declare i32 @csec_find_statement_paren_end(ptr, i32, i32)\0A\00"
@.str.47038 = private unnamed_addr constant [61 x i8] c"declare i32 @csec_find_statement_block_start(ptr, i32, i32)\0A\00"
@.str.47040 = private unnamed_addr constant [59 x i8] c"declare i32 @csec_find_statement_block_end(ptr, i32, i32)\0A\00"
@.str.47042 = private unnamed_addr constant [56 x i8] c"declare i32 @csec_count_comma_separated(ptr, i32, i32)\0A\00"
@.str.47044 = private unnamed_addr constant [65 x i8] c"declare i32 @csec_find_last_top_level_token(ptr, i32, i32, ptr)\0A\00"
@.str.47046 = private unnamed_addr constant [53 x i8] c"declare ptr @csec_llvm_lexer_helper_definition(ptr)\0A\00"
@.str.47048 = private unnamed_addr constant [40 x i8] c"declare i64 @csec_string_builder_new()\0A\00"
@.str.47050 = private unnamed_addr constant [48 x i8] c"declare i64 @csec_string_builder_new_file(ptr)\0A\00"
@.str.47052 = private unnamed_addr constant [51 x i8] c"declare i32 @csec_string_builder_append(i64, ptr)\0A\00"
@.str.47054 = private unnamed_addr constant [46 x i8] c"declare ptr @csec_string_builder_finish(i64)\0A\00"
@.str.47056 = private unnamed_addr constant [58 x i8] c"declare i32 @csec_string_builder_write_to_file(i64, ptr)\0A\00"
@.str.47058 = private unnamed_addr constant [52 x i8] c"declare void @csec_set_command_line_args(i32, ptr)\0A\00"
@.str.47060 = private unnamed_addr constant [44 x i8] c"declare i32 @csec_command_line_arg_count()\0A\00"
@.str.47062 = private unnamed_addr constant [41 x i8] c"declare ptr @csec_command_line_arg(i32)\0A\00"
@.str.47064 = private unnamed_addr constant [43 x i8] c"declare ptr @csec_file_read_all_text(ptr)\0A\00"
@.str.47066 = private unnamed_addr constant [49 x i8] c"declare i32 @csec_file_write_all_text(ptr, ptr)\0A\00"
@.str.47068 = private unnamed_addr constant [38 x i8] c"declare void @csec_print_string(ptr)\0A\00"
@.str.47070 = private unnamed_addr constant [36 x i8] c"declare void @csec_print_newline()\0A\00"
@.str.47072 = private unnamed_addr constant [43 x i8] c"declare ptr @csec_string_concat(ptr, ptr)\0A\00"
@.str.47074 = private unnamed_addr constant [43 x i8] c"declare i32 @csec_string_equals(ptr, ptr)\0A\00"
@.str.47076 = private unnamed_addr constant [48 x i8] c"declare i32 @csec_string_starts_with(ptr, ptr)\0A\00"
@.str.47078 = private unnamed_addr constant [51 x i8] c"declare ptr @csec_string_substring(ptr, i32, i32)\0A\00"
@.str.47080 = private unnamed_addr constant [38 x i8] c"declare ptr @csec_to_string_i64(i64)\0A\00"
@.str.47082 = private unnamed_addr constant [38 x i8] c"declare ptr @csec_to_string_char(i8)\0A\00"
@.str.47084 = private unnamed_addr constant [52 x i8] c"declare ptr @csec_token_append_owned(ptr, i8, ptr)\0A\00"
@.str.47086 = private unnamed_addr constant [39 x i8] c"declare i64 @csec_token_builder_new()\0A\00"
@.str.47088 = private unnamed_addr constant [54 x i8] c"declare i32 @csec_token_builder_append(i64, i8, ptr)\0A\00"
@.str.47090 = private unnamed_addr constant [45 x i8] c"declare ptr @csec_token_builder_finish(i64)\0A\00"
@.str.47092 = private unnamed_addr constant [40 x i8] c"declare ptr @csec_tokenize_source(ptr)\0A\00"
@.str.47094 = private unnamed_addr constant [42 x i8] c"declare i8 @csec_token_kind_at(ptr, i32)\0A\00"
@.str.47096 = private unnamed_addr constant [43 x i8] c"declare ptr @csec_token_text_at(ptr, i32)\0A\00"
@.str.47098 = private unnamed_addr constant [47 x i8] c"declare i32 @csec_token_is(ptr, i32, i8, ptr)\0A\00"
@.str.47100 = private unnamed_addr constant [52 x i8] c"declare i32 @csec_advance_statement(ptr, i32, i32)\0A\00"
@.str.47102 = private unnamed_addr constant [52 x i8] c"declare i32 @csec_advance_top_level_decl(ptr, i32)\0A\00"
@.str.47104 = private unnamed_addr constant [50 x i8] c"declare i32 @csec_find_decl_body_start(ptr, i32)\0A\00"
@.str.47106 = private unnamed_addr constant [48 x i8] c"declare i32 @csec_find_decl_body_end(ptr, i32)\0A\00"
@.str.47108 = private unnamed_addr constant [48 x i8] c"declare i32 @csec_function_param_end(ptr, i32)\0A\00"
@.str.47110 = private unnamed_addr constant [54 x i8] c"declare ptr @csec_function_llvm_param_list(ptr, i32)\0A\00"
@.str.47112 = private unnamed_addr constant [57 x i8] c"declare ptr @csec_function_llvm_param_allocas(ptr, i32)\0A\00"
@.str.47114 = private unnamed_addr constant [51 x i8] c"declare ptr @csec_llvm_name_with_number(ptr, i32)\0A\00"
@.str.47116 = private unnamed_addr constant [50 x i8] c"declare ptr @csec_llvm_string_literal_bytes(ptr)\0A\00"
@.str.47118 = private unnamed_addr constant [56 x i8] c"declare i32 @csec_llvm_string_literal_byte_length(ptr)\0A\00"
@.str.47120 = private unnamed_addr constant [53 x i8] c"declare ptr @csec_function_return_type_at(ptr, i32)\0A\00"
@.str.47122 = private unnamed_addr constant [52 x i8] c"declare ptr @csec_collect_type_name(ptr, i32, i32)\0A\00"
@.str.47124 = private unnamed_addr constant [59 x i8] c"declare i32 @csec_enclosing_function_decl_start(ptr, i32)\0A\00"
@.str.47126 = private unnamed_addr constant [59 x i8] c"declare i32 @csec_enclosing_function_body_start(ptr, i32)\0A\00"
@.str.47128 = private unnamed_addr constant [57 x i8] c"declare i32 @csec_enclosing_function_body_end(ptr, i32)\0A\00"
@.str.47130 = private unnamed_addr constant [57 x i8] c"declare ptr @csec_lookup_function_return_type(ptr, ptr)\0A\00"
@.str.47132 = private unnamed_addr constant [60 x i8] c"declare ptr @csec_lookup_visible_value_type(ptr, i32, ptr)\0A\00"
@.str.47134 = private unnamed_addr constant [62 x i8] c"declare ptr @csec_lookup_visible_storage_name(ptr, i32, ptr)\0A\00"
@.str.47136 = private unnamed_addr constant [40 x i8] c"declare ptr @csec_expand_imports(ptr)\0A\0A\00"
@.str.47190 = private unnamed_addr constant [4 x i8] c"def\00"
@.str.47205 = private unnamed_addr constant [5 x i8] c"main\00"
@.str.47299 = private unnamed_addr constant [42 x i8] c"define i32 @main(i32 %argc, ptr %argv) {\0A\00"
@.str.47301 = private unnamed_addr constant [8 x i8] c"entry:\0A\00"
@.str.47303 = private unnamed_addr constant [63 x i8] c"  call void @csec_set_command_line_args(i32 %argc, ptr %argv)\0A\00"
@.str.47305 = private unnamed_addr constant [37 x i8] c"  %ret = call i32 @csec_user_main()\0A\00"
@.str.47307 = private unnamed_addr constant [16 x i8] c"  ret i32 %ret\0A\00"
@.str.47309 = private unnamed_addr constant [3 x i8] c"}\0A\00"
@.str.47319 = private unnamed_addr constant [22 x i8] c"define i32 @main() {\0A\00"
@.str.47326 = private unnamed_addr constant [3 x i8] c"}\0A\00"
@.str.47349 = private unnamed_addr constant [1 x i8] c"\00"
@.str.47585 = private unnamed_addr constant [2 x i8] c".\00"
@.str.47610 = private unnamed_addr constant [1 x i8] c"\00"
@.str.47644 = private unnamed_addr constant [2 x i8] c"/\00"
@.str.47653 = private unnamed_addr constant [1 x i8] c"\00"
@.str.47695 = private unnamed_addr constant [3 x i8] c"//\00"
@.str.47703 = private unnamed_addr constant [7 x i8] c"import\00"
@.str.47708 = private unnamed_addr constant [1 x i8] c"\00"
@.str.47755 = private unnamed_addr constant [1 x i8] c"\00"
@.str.47915 = private unnamed_addr constant [6 x i8] c".csec\00"
@.str.47926 = private unnamed_addr constant [6 x i8] c".csec\00"
@.str.47970 = private unnamed_addr constant [2 x i8] c"/\00"
@.str.48030 = private unnamed_addr constant [2 x i8] c"/\00"
@.str.48075 = private unnamed_addr constant [2 x i8] c"|\00"
@.str.48079 = private unnamed_addr constant [2 x i8] c"|\00"
@.str.48092 = private unnamed_addr constant [1 x i8] c"\00"
@.str.48118 = private unnamed_addr constant [7 x i8] c"import\00"
@.str.48147 = private unnamed_addr constant [1 x i8] c"\00"
@.str.48262 = private unnamed_addr constant [2 x i8] c"\0A\00"
@.str.48286 = private unnamed_addr constant [2 x i8] c"\0A\00"
@.str.48312 = private unnamed_addr constant [2 x i8] c"\0A\00"
@.str.48370 = private unnamed_addr constant [9 x i8] c"tokenlen\00"
@.str.48375 = private unnamed_addr constant [8 x i8] c"tokens=\00"
@.str.48381 = private unnamed_addr constant [2 x i8] c"\0A\00"
@.str.48390 = private unnamed_addr constant [7 x i8] c"tokens\00"
@.str.48404 = private unnamed_addr constant [4 x i8] c"ast\00"
@.str.48421 = private unnamed_addr constant [8 x i8] c"symbols\00"
@.str.48438 = private unnamed_addr constant [3 x i8] c"ir\00"
@.str.48455 = private unnamed_addr constant [5 x i8] c"llvm\00"
@.str.48507 = private unnamed_addr constant [5 x i8] c"llvm\00"
@.str.48534 = private unnamed_addr constant [14 x i8] c"compile error\00"
@.str.48603 = private unnamed_addr constant [14 x i8] c"compile error\00"
@.str.48673 = private unnamed_addr constant [20 x i8] c"selfhost/input.csec\00"
@.str.48675 = private unnamed_addr constant [15 x i8] c"selfhost/out.c\00"
@.str.48677 = private unnamed_addr constant [2 x i8] c"c\00"

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

define i32 @parseReturnIntegerInRange(ptr %arg.tokens, i32 %arg.start, i32 %arg.end) {
entry:
  %tokens = alloca ptr
  store ptr %arg.tokens, ptr %tokens
  %start = alloca i32
  store i32 %arg.start, ptr %start
  %end = alloca i32
  store i32 %arg.end, ptr %end
  %cursor.addr.14976 = alloca i32
  %cursor.init.14976 = load i32, ptr %start
  store i32 %cursor.init.14976, ptr %cursor.addr.14976  ; malformed while
  ret i32 0
}

define ptr @appendCExpression(ptr %arg.tokens, i32 %arg.start, i32 %arg.rawEnd) {
entry:
  %ret = call ptr @csec_generate_c_expression(ptr %arg.tokens, i32 %arg.start, i32 %arg.rawEnd)
  ret ptr %ret
}

define ptr @cTypeName(ptr %arg.typeName) {
entry:
  %typeName = alloca ptr
  store ptr %arg.typeName, ptr %typeName
  %ret.15403 = getelementptr inbounds [6 x i8], ptr @.str.0, i32 0, i32 0
  ret ptr %ret.15403
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
  %tokens = alloca ptr
  store ptr %arg.tokens, ptr %tokens
  %cursor.addr.16736 = alloca i32
  %cursor.init.16736 = add i32 0, 0
  store i32 %cursor.init.16736, ptr %cursor.addr.16736  ; malformed while
  ret i32 0
}

define ptr @generateMainExecutionC(ptr %arg.tokens) {
entry:
  %tokens = alloca ptr
  store ptr %arg.tokens, ptr %tokens
  %ret.17120 = getelementptr inbounds [1 x i8], ptr @.str.0, i32 0, i32 0
  ret ptr %ret.17120
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
  %text = alloca ptr
  store ptr %arg.text, ptr %text
  %ret.21177 = getelementptr inbounds [2 x i8], ptr @.str.0, i32 0, i32 0
  ret ptr %ret.21177
}

define ptr @llvmI32Value(ptr %arg.tokens, i32 %arg.start, i32 %arg.rawEnd) {
entry:
  %tokens = alloca ptr
  store ptr %arg.tokens, ptr %tokens
  %start = alloca i32
  store i32 %arg.start, ptr %start
  %rawEnd = alloca i32
  store i32 %arg.rawEnd, ptr %rawEnd
  %ret.21320 = getelementptr inbounds [5 x i8], ptr @.str.0, i32 0, i32 0
  ret ptr %ret.21320
}

define ptr @lookupFunctionParamType(ptr %arg.tokens, i32 %arg.limit, ptr %arg.name) {
entry:
  %tokens = alloca ptr
  store ptr %arg.tokens, ptr %tokens
  %limit = alloca i32
  store i32 %arg.limit, ptr %limit
  %name = alloca ptr
  store ptr %arg.name, ptr %name
  %ret.21545 = getelementptr inbounds [8 x i8], ptr @.str.0, i32 0, i32 0
  ret ptr %ret.21545
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
  %tokens = alloca ptr
  store ptr %arg.tokens, ptr %tokens
  %start = alloca i32
  store i32 %arg.start, ptr %start
  %rawEnd = alloca i32
  store i32 %arg.rawEnd, ptr %rawEnd
  %ret.22495 = getelementptr inbounds [1 x i8], ptr @.str.0, i32 0, i32 0
  ret ptr %ret.22495
}

define ptr @llvmI1Value(ptr %arg.tokens, i32 %arg.start, i32 %arg.rawEnd) {
entry:
  %tokens = alloca ptr
  store ptr %arg.tokens, ptr %tokens
  %start = alloca i32
  store i32 %arg.start, ptr %start
  %rawEnd = alloca i32
  store i32 %arg.rawEnd, ptr %rawEnd
  %ret.22604 = getelementptr inbounds [6 x i8], ptr @.str.0, i32 0, i32 0
  ret ptr %ret.22604
}

define ptr @generateLLVMLoadBoolIfIdentifier(ptr %arg.tokens, i32 %arg.start, i32 %arg.rawEnd) {
entry:
  %tokens = alloca ptr
  store ptr %arg.tokens, ptr %tokens
  %start = alloca i32
  store i32 %arg.start, ptr %start
  %rawEnd = alloca i32
  store i32 %arg.rawEnd, ptr %rawEnd
  %ret.22698 = getelementptr inbounds [1 x i8], ptr @.str.0, i32 0, i32 0
  ret ptr %ret.22698
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
  %tokens = alloca ptr
  store ptr %arg.tokens, ptr %tokens
  %start = alloca i32
  store i32 %arg.start, ptr %start
  %rawEnd = alloca i32
  store i32 %arg.rawEnd, ptr %rawEnd
  %ret.23198 = getelementptr inbounds [4 x i8], ptr @.str.0, i32 0, i32 0
  ret ptr %ret.23198
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
  br i1 %identifier, label %identifier.return, label %expression.return
identifier.return:
  %name = call ptr @tokenTextAt(ptr %arg.tokens, i32 %arg.start)
  %value.type = call ptr @lookupVisibleValueType(ptr %arg.tokens, i32 %arg.start, ptr %name)
  %load = call ptr @llvmLoadForValueType(ptr %arg.tokens, i32 %arg.start, ptr %name, ptr %value.type, ptr %arg.resultName)
  ret ptr %load
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
  %tokens = alloca ptr
  store ptr %arg.tokens, ptr %tokens
  %name = alloca ptr
  store ptr %arg.name, ptr %name
  %ret.26275 = icmp eq i1 false, true
  ret i1 %ret.26275
}

