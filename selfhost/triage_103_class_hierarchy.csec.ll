; ModuleID = 'csec.selfhost'
source_filename = "csec.selfhost"

declare ptr @csec_append_expression_until(ptr, i32, i32)
declare ptr @csec_generate_symbol_table(ptr)
declare ptr @csec_ir_type_name(ptr)
declare ptr @csec_collect_type_name(ptr, i32, i32)
declare ptr @csec_lookup_visible_value_type(ptr, i32, ptr)
declare ptr @csec_lookup_visible_storage_name(ptr, i32, ptr)
declare i32 @csec_find_function_param_start(ptr, i32)
declare i32 @csec_count_comma_separated(ptr, i32, i32)
declare i32 @csec_count_function_params(ptr, i32)
declare i32 @csec_expression_top_level_operator(ptr, i32, i32)
declare i32 @csec_find_closing_token(ptr, i32, i32, ptr, ptr)
declare i32 @csec_find_last_top_level_token(ptr, i32, i32, ptr)
declare i32 @csec_find_statement_block_end(ptr, i32, i32)
declare i32 @csec_find_statement_block_start(ptr, i32, i32)
declare i32 @csec_find_statement_paren_end(ptr, i32, i32)
declare i32 @csec_find_statement_paren_start(ptr, i32, i32)
declare i32 @csec_find_token_text_in_range(ptr, i32, i32, ptr)
declare i32 @csec_find_top_level_match(ptr, i32, i32)
declare i32 @csec_find_top_level_operator(ptr, i32, i32, i32)
declare ptr @csec_generate_body_ast(ptr, i32, i32)
declare ptr @csec_generate_c_body(ptr, i32, i32, ptr)
declare ptr @csec_generate_c_expression(ptr, i32, i32)
declare ptr @csec_generate_expression_ast(ptr, i32, i32)
declare ptr @csec_generate_statement_ast(ptr, i32, i32)
declare ptr @csec_ir_operator_name(ptr)
declare i32 @csec_is_keyword(ptr)
declare i32 @csec_line_end(ptr, i32)
declare i32 @csec_line_start(ptr, i32)
declare i32 @csec_starts_top_level_declaration(ptr, i32)
declare i8 @csec_string_char_at(ptr, i32)
declare ptr @csec_string_concat(ptr, ptr)
declare i32 @csec_string_contains(ptr, ptr)
declare i32 @csec_string_ends_with(ptr, ptr)
declare i32 @csec_string_equals(ptr, ptr)
declare i64 @csec_string_index_of(ptr, ptr)
declare i32 @csec_string_is_empty(ptr)
declare i64 @csec_string_length(ptr)
declare i32 @csec_string_starts_with(ptr, ptr)
declare ptr @csec_string_substring(ptr, i32, i32)
declare ptr @csec_string_to_lower(ptr)
declare ptr @csec_string_to_upper(ptr)
declare ptr @csec_string_trim(ptr)
declare void @csec_print_i64(i64)
declare void @csec_print_newline()
declare void @csec_print_string(ptr)
declare i32 @csec_command_line_arg_count()
declare ptr @csec_command_line_arg(i32)
declare i32 @csec_to_int(ptr)
declare ptr @csec_to_string_char(i8)
declare ptr @csec_to_string_i64(i64)
declare i32 @csec_token_is_top_level_operator(ptr, i32, i32)
declare ptr @csec_top_level_decl_kind(ptr, i32)
declare ptr @csec_top_level_decl_name(ptr, i32)
declare i32 @csec_validate_balanced(ptr)
declare i32 @csec_validate_top_level(ptr)

@.str.192 = private unnamed_addr constant [5 x i8] c"rect\00"
@.str.205 = private unnamed_addr constant [3 x i8] c"sq\00"
@.str.216 = private unnamed_addr constant [5 x i8] c"circ\00"

%class.Shape = type { ptr }

define ptr @Shape_getName(ptr %arg.this) {
entry:
  %field = getelementptr inbounds %class.Shape, ptr %arg.this, i32 0, i32 0
  %ret = load ptr, ptr %field
  ret ptr %ret
}

define i32 @Shape_area(ptr %arg.this) {
entry:
  %name = getelementptr inbounds %class.Shape, ptr %arg.this, i32 0, i32 0
  %ret = add i32 0, 0
  ret i32 %ret
}

%class.Rectangle = type { ptr, i32, i32 }

define i32 @Rectangle_area(ptr %arg.this) {
entry:
  %name = getelementptr inbounds %class.Rectangle, ptr %arg.this, i32 0, i32 0
  %width = getelementptr inbounds %class.Rectangle, ptr %arg.this, i32 0, i32 1
  %height = getelementptr inbounds %class.Rectangle, ptr %arg.this, i32 0, i32 2
  %ret.left = load i32, ptr %width
  %ret.right = load i32, ptr %height
  %ret = mul i32 %ret.left, %ret.right
  ret i32 %ret
}

define i32 @Rectangle_perimeter(ptr %arg.this) {
entry:
  %name = getelementptr inbounds %class.Rectangle, ptr %arg.this, i32 0, i32 0
  %width = getelementptr inbounds %class.Rectangle, ptr %arg.this, i32 0, i32 1
  %height = getelementptr inbounds %class.Rectangle, ptr %arg.this, i32 0, i32 2
  %ret.left = add i32 0, 2
  %ret.right = add i32 0, 0
  %ret = mul i32 %ret.left, %ret.right
  ret i32 %ret
}

%class.Square = type { ptr, i32 }

define i32 @Square_getSide(ptr %arg.this) {
entry:
  %name = getelementptr inbounds %class.Square, ptr %arg.this, i32 0, i32 0
  %side = getelementptr inbounds %class.Square, ptr %arg.this, i32 0, i32 1
  %ret = load i32, ptr %side
  ret i32 %ret
}

%class.Circle = type { ptr, i32 }

define i32 @Circle_area(ptr %arg.this) {
entry:
  %name = getelementptr inbounds %class.Circle, ptr %arg.this, i32 0, i32 0
  %radius = getelementptr inbounds %class.Circle, ptr %arg.this, i32 0, i32 1
  %ret.left.left = load i32, ptr %radius
  %ret.left.right = load i32, ptr %radius
  %ret.left = mul i32 %ret.left.left, %ret.left.right
  %ret.right = add i32 0, 3
  %ret = mul i32 %ret.left, %ret.right
  ret i32 %ret
}

define i32 @Circle_circumference(ptr %arg.this) {
entry:
  %name = getelementptr inbounds %class.Circle, ptr %arg.this, i32 0, i32 0
  %radius = getelementptr inbounds %class.Circle, ptr %arg.this, i32 0, i32 1
  %ret.left.left = add i32 0, 2
  %ret.left.right = load i32, ptr %radius
  %ret.left = mul i32 %ret.left.left, %ret.left.right
  %ret.right = add i32 0, 3
  %ret = mul i32 %ret.left, %ret.right
  ret i32 %ret
}

define i32 @ShapeFactory_createRectangle(i32 %arg.w, i32 %arg.h) {
entry:
  %w = alloca i32
  store i32 %arg.w, ptr %w
  %h = alloca i32
  store i32 %arg.h, ptr %h
  %ret.left = load i32, ptr %w
  %ret.right = load i32, ptr %h
  %ret = mul i32 %ret.left, %ret.right
  ret i32 %ret
}

define i32 @ShapeFactory_createSquare(i32 %arg.s) {
entry:
  %s = alloca i32
  store i32 %arg.s, ptr %s
  %ret.left = load i32, ptr %s
  %ret.right = load i32, ptr %s
  %ret = mul i32 %ret.left, %ret.right
  ret i32 %ret
}

define i32 @ShapeFactory_createCircle(i32 %arg.r) {
entry:
  %r = alloca i32
  store i32 %arg.r, ptr %r
  %ret.left.left = load i32, ptr %r
  %ret.left.right = load i32, ptr %r
  %ret.left = mul i32 %ret.left.left, %ret.left.right
  %ret.right = add i32 0, 3
  %ret = mul i32 %ret.left, %ret.right
  ret i32 %ret
}

define i32 @csec_user_main() {
entry:
  %rect.object.186 = alloca %class.Rectangle
  %rect.addr.186 = alloca ptr
  store ptr %rect.object.186, ptr %rect.addr.186
  %rect.ctor.0 = getelementptr inbounds [5 x i8], ptr @.str.192, i32 0, i32 0
  %rect.field.0 = getelementptr inbounds %class.Rectangle, ptr %rect.object.186, i32 0, i32 0
  store ptr %rect.ctor.0, ptr %rect.field.0
  %rect.ctor.1 = add i32 0, 10
  %rect.field.1 = getelementptr inbounds %class.Rectangle, ptr %rect.object.186, i32 0, i32 1
  store i32 %rect.ctor.1, ptr %rect.field.1
  %rect.ctor.2 = add i32 0, 20
  %rect.field.2 = getelementptr inbounds %class.Rectangle, ptr %rect.object.186, i32 0, i32 2
  store i32 %rect.ctor.2, ptr %rect.field.2
  %sq.object.199 = alloca %class.Square
  %sq.addr.199 = alloca ptr
  store ptr %sq.object.199, ptr %sq.addr.199
  %sq.ctor.0 = getelementptr inbounds [3 x i8], ptr @.str.205, i32 0, i32 0
  %sq.field.0 = getelementptr inbounds %class.Square, ptr %sq.object.199, i32 0, i32 0
  store ptr %sq.ctor.0, ptr %sq.field.0
  %sq.ctor.1 = add i32 0, 5
  %sq.field.1 = getelementptr inbounds %class.Square, ptr %sq.object.199, i32 0, i32 1
  store i32 %sq.ctor.1, ptr %sq.field.1
  %circ.object.210 = alloca %class.Circle
  %circ.addr.210 = alloca ptr
  store ptr %circ.object.210, ptr %circ.addr.210
  %circ.ctor.0 = getelementptr inbounds [5 x i8], ptr @.str.216, i32 0, i32 0
  %circ.field.0 = getelementptr inbounds %class.Circle, ptr %circ.object.210, i32 0, i32 0
  store ptr %circ.ctor.0, ptr %circ.field.0
  %circ.ctor.1 = add i32 0, 7
  %circ.field.1 = getelementptr inbounds %class.Circle, ptr %circ.object.210, i32 0, i32 1
  store i32 %circ.ctor.1, ptr %circ.field.1
  %a1.addr.221 = alloca i32
  %a1.init.221.this = load ptr, ptr %rect.addr.186
  %a1.init.221 = call i32 @Rectangle_area(ptr %a1.init.221.this)
  store i32 %a1.init.221, ptr %a1.addr.221
  %a2.addr.230 = alloca i32
  %a2.init.230.this = load ptr, ptr %circ.addr.210
  %a2.init.230 = call i32 @Circle_area(ptr %a2.init.230.this)
  store i32 %a2.init.230, ptr %a2.addr.230
  %p.addr.239 = alloca i32
  %p.init.239.this = load ptr, ptr %rect.addr.186
  %p.init.239 = call i32 @Rectangle_perimeter(ptr %p.init.239.this)
  store i32 %p.init.239, ptr %p.addr.239
  %f1.addr.248 = alloca i32
  %f1.init.248.arg0 = add i32 0, 3
  %f1.init.248.arg1 = add i32 0, 4
  %f1.init.248 = call i32 @ShapeFactory_createRectangle(i32 %f1.init.248.arg0, i32 %f1.init.248.arg1)
  store i32 %f1.init.248, ptr %f1.addr.248
  %f2.addr.260 = alloca i32
  %f2.init.260.arg0 = add i32 0, 5
  %f2.init.260 = call i32 @ShapeFactory_createSquare(i32 %f2.init.260.arg0)
  store i32 %f2.init.260, ptr %f2.addr.260
  %f3.addr.270 = alloca i32
  %f3.init.270.arg0 = add i32 0, 10
  %f3.init.270 = call i32 @ShapeFactory_createCircle(i32 %f3.init.270.arg0)
  store i32 %f3.init.270, ptr %f3.addr.270
  %ret.280.left.left.left.left.left = load i32, ptr %a1.addr.221
  %ret.280.left.left.left.left.right = load i32, ptr %a2.addr.230
  %ret.280.left.left.left.left = add i32 %ret.280.left.left.left.left.left, %ret.280.left.left.left.left.right
  %ret.280.left.left.left.right = load i32, ptr %p.addr.239
  %ret.280.left.left.left = add i32 %ret.280.left.left.left.left, %ret.280.left.left.left.right
  %ret.280.left.left.right = load i32, ptr %f1.addr.248
  %ret.280.left.left = add i32 %ret.280.left.left.left, %ret.280.left.left.right
  %ret.280.left.right = load i32, ptr %f2.addr.260
  %ret.280.left = add i32 %ret.280.left.left, %ret.280.left.right
  %ret.280.right = load i32, ptr %f3.addr.270
  %ret.280 = add i32 %ret.280.left, %ret.280.right
  ret i32 %ret.280
}

define i32 @main() {
entry:
  %ret = call i32 @csec_user_main()
  ret i32 %ret
}

