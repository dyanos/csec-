; ModuleID = 'main'
source_filename = "main"

@0 = private unnamed_addr constant [7 x i8] c"value=\00", align 1
@1 = private unnamed_addr constant [2 x i8] c" \00", align 1
@2 = private unnamed_addr constant [2 x i8] c" \00", align 1
@3 = private unnamed_addr constant [5 x i8] c"done\00", align 1

define i32 @main(i32 %0, ptr %1) {
entry:
  call void @csec_set_command_line_args(i32 %0, ptr %1)
  %user.main = call i32 @_main()
  ret i32 %user.main
}

declare ptr @malloc(i64)

declare void @free(ptr)

declare ptr @toString(ptr)

declare ptr @"operator+"(ptr, ptr)

declare void @print(ptr)

declare void @println(ptr)

define i32 @_main() {
entry:
  call void @"Out#print"(ptr @0)
  call void @"Out#print.Int"(i32 42)
  call void @"Out#print"(ptr @1)
  call void @"Out#print.Float"(float 3.500000e+00)
  call void @"Out#print"(ptr @2)
  call void @"Out#print.Boolean"(i1 true)
  call void @"Out#println"()
  call void @"Out#println.String"(ptr @3)
  ret i32 0
}

define void @"Out#print"(ptr %0) {
entry:
  call void @csec_print_string(ptr %0)
  ret void
}

declare void @csec_print_string(ptr)

define void @"Out#print.Int"(i32 %0) {
entry:
  %math.sext = sext i32 %0 to i64
  call void @csec_print_i64(i64 %math.sext)
  ret void
}

declare void @csec_print_i64(i64)

define void @"Out#print.Long"(i64 %0) {
entry:
  call void @csec_print_i64(i64 %0)
  ret void
}

define void @"Out#print.Float"(float %0) {
entry:
  %math.fpext = fpext float %0 to double
  call void @csec_print_double(double %math.fpext)
  ret void
}

declare void @csec_print_double(double)

define void @"Out#print.Double"(double %0) {
entry:
  call void @csec_print_double(double %0)
  ret void
}

define void @"Out#print.Boolean"(i1 %0) {
entry:
  %print.bool = zext i1 %0 to i32
  call void @csec_print_bool(i32 %print.bool)
  ret void
}

declare void @csec_print_bool(i32)

define void @"Out#print.Char"(i8 %0) {
entry:
  call void @csec_print_char(i8 %0)
  ret void
}

declare void @csec_print_char(i8)

define void @"Out#println"() {
entry:
  call void @csec_print_newline()
  ret void
}

declare void @csec_print_newline()

define void @"Out#println.String"(ptr %0) {
entry:
  call void @csec_print_string(ptr %0)
  call void @csec_print_newline()
  ret void
}

define void @"Out#println.Int"(i32 %0) {
entry:
  %math.sext = sext i32 %0 to i64
  call void @csec_print_i64(i64 %math.sext)
  call void @csec_print_newline()
  ret void
}

define void @"Out#println.Long"(i64 %0) {
entry:
  call void @csec_print_i64(i64 %0)
  call void @csec_print_newline()
  ret void
}

define void @"Out#println.Float"(float %0) {
entry:
  %math.fpext = fpext float %0 to double
  call void @csec_print_double(double %math.fpext)
  call void @csec_print_newline()
  ret void
}

define void @"Out#println.Double"(double %0) {
entry:
  call void @csec_print_double(double %0)
  call void @csec_print_newline()
  ret void
}

define void @"Out#println.Boolean"(i1 %0) {
entry:
  %print.bool = zext i1 %0 to i32
  call void @csec_print_bool(i32 %print.bool)
  call void @csec_print_newline()
  ret void
}

define void @"Out#println.Char"(i8 %0) {
entry:
  call void @csec_print_char(i8 %0)
  call void @csec_print_newline()
  ret void
}

declare void @csec_set_command_line_args(i32, ptr)

define internal i32 @__csec_jit_entry() {
entry:
  %user.main = call i32 @_main()
  ret i32 %user.main
}
