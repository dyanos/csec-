; ModuleID = 'main'
source_filename = "main"

@0 = private unnamed_addr constant [6 x i8] c"hello\00", align 1
@1 = private unnamed_addr constant [12 x i8] c"hello world\00", align 1
@2 = private unnamed_addr constant [12 x i8] c"line1\0Aline2\00", align 1
@3 = private unnamed_addr constant [10 x i8] c"col1\09col2\00", align 1
@4 = private unnamed_addr constant [14 x i8] c"she said \22hi\22\00", align 1
@5 = private unnamed_addr constant [13 x i8] c"path\\to\\file\00", align 1
@6 = private unnamed_addr constant [1 x i8] zeroinitializer, align 1

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
  ret i32 0
}

declare void @csec_set_command_line_args(i32, ptr)

define internal i32 @__csec_jit_entry() {
entry:
  %user.main = call i32 @_main()
  ret i32 %user.main
}
