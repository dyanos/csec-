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
  %i_ptr = alloca i32, align 4
  store i32 0, ptr %i_ptr, align 4
  br label %forcond

forcond:                                          ; preds = %loop, %entry
  %i = load i32, ptr %i_ptr, align 4
  %cond = icmp sle i32 %i, 10
  br i1 %cond, label %loop, label %afterloop

loop:                                             ; preds = %forcond
  %i.load = load float, ptr %i_ptr, align 4
  %i1 = load i32, ptr %i_ptr, align 4
  %next_i = add i32 %i1, 1
  store i32 %next_i, ptr %i_ptr, align 4
  br label %forcond

afterloop:                                        ; preds = %forcond
  %k_ptr = alloca i32, align 4
  store i32 1, ptr %k_ptr, align 4
  br label %forcond2

forcond2:                                         ; preds = %loop3, %afterloop
  %k = load i32, ptr %k_ptr, align 4
  %cond5 = icmp sle i32 %k, 100
  br i1 %cond5, label %loop3, label %afterloop4

loop3:                                            ; preds = %forcond2
  %k.load = load float, ptr %k_ptr, align 4
  %k6 = load i32, ptr %k_ptr, align 4
  %next_i7 = add i32 %k6, 1
  store i32 %next_i7, ptr %k_ptr, align 4
  br label %forcond2

afterloop4:                                       ; preds = %forcond2
  %p1 = alloca double, align 8
  store double 0.000000e+00, ptr %p1, align 8
  %p2 = alloca double, align 8
  store double 0.000000e+00, ptr %p2, align 8
  %i18 = alloca double, align 8
  store double 0.000000e+00, ptr %i18, align 8
  %i2 = alloca double, align 8
  store double 0.000000e+00, ptr %i2, align 8
  ret i32 0
}

declare void @csec_set_command_line_args(i32, ptr)

define internal i32 @__csec_jit_entry() {
entry:
  %user.main = call i32 @_main()
  ret i32 %user.main
}
