; ModuleID = 'main'
source_filename = "main"

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
  br i1 true, label %and_rhs, label %and_end

and_rhs:                                          ; preds = %entry
  br label %and_end

and_end:                                          ; preds = %and_rhs, %entry
  %and_result.0 = phi i1 [ true, %and_rhs ], [ false, %entry ]
  %e = alloca i1, align 1
  store i1 %and_result.0, ptr %e, align 1
  %f = alloca i32, align 4
  store i32 20, ptr %f, align 4
  %g = alloca i32, align 4
  store i32 14, ptr %g, align 4
  %h = alloca i32, align 4
  store i32 5, ptr %h, align 4
  %i = alloca i32, align 4
  store i32 5, ptr %i, align 4
  ret i32 14
}

declare void @csec_set_command_line_args(i32, ptr)

define internal i32 @__csec_jit_entry() {
entry:
  %user.main = call i32 @_main()
  ret i32 %user.main
}
