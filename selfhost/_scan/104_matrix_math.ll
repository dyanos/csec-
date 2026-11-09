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

define i32 @_dotProduct(i32 %0) {
entry:
  br label %forcond

forcond:                                          ; preds = %loop, %entry
  %i_ptr.0 = phi i32 [ 0, %entry ], [ %next_i, %loop ]
  %sum.0 = phi i32 [ 0, %entry ], [ %addtmp, %loop ]
  %cond = icmp sle i32 %i_ptr.0, %0
  br i1 %cond, label %loop, label %afterloop

loop:                                             ; preds = %forcond
  %multmp = mul i32 %i_ptr.0, %i_ptr.0
  %addtmp = add i32 %sum.0, %multmp
  %next_i = add i32 %i_ptr.0, 1
  br label %forcond

afterloop:                                        ; preds = %forcond
  ret i32 %sum.0
}

define i32 @_main() {
entry:
  %arrlit = alloca float, i32 2, align 4
  %0 = getelementptr float, ptr %arrlit, i32 0
  store float 1.000000e+00, ptr %0, align 4
  %1 = getelementptr float, ptr %arrlit, i32 1
  store float 0.000000e+00, ptr %1, align 4
  %arrlit1 = alloca ptr, i32 2, align 8
  %2 = getelementptr ptr, ptr %arrlit1, i32 0
  store ptr %arrlit, ptr %2, align 8
  %arrlit2 = alloca float, i32 2, align 4
  %3 = getelementptr float, ptr %arrlit2, i32 0
  store float 0.000000e+00, ptr %3, align 4
  %4 = getelementptr float, ptr %arrlit2, i32 1
  store float 1.000000e+00, ptr %4, align 4
  %5 = getelementptr ptr, ptr %arrlit1, i32 1
  store ptr %arrlit2, ptr %5, align 8
  %arrlit3 = alloca float, i32 3, align 4
  %6 = getelementptr float, ptr %arrlit3, i32 0
  store float 1.000000e+00, ptr %6, align 4
  %7 = getelementptr float, ptr %arrlit3, i32 1
  store float 2.000000e+00, ptr %7, align 4
  %8 = getelementptr float, ptr %arrlit3, i32 2
  store float 3.000000e+00, ptr %8, align 4
  %arrlit4 = alloca ptr, i32 3, align 8
  %9 = getelementptr ptr, ptr %arrlit4, i32 0
  store ptr %arrlit3, ptr %9, align 8
  %arrlit5 = alloca float, i32 3, align 4
  %10 = getelementptr float, ptr %arrlit5, i32 0
  store float 4.000000e+00, ptr %10, align 4
  %11 = getelementptr float, ptr %arrlit5, i32 1
  store float 5.000000e+00, ptr %11, align 4
  %12 = getelementptr float, ptr %arrlit5, i32 2
  store float 6.000000e+00, ptr %12, align 4
  %13 = getelementptr ptr, ptr %arrlit4, i32 1
  store ptr %arrlit5, ptr %13, align 8
  %arrlit6 = alloca float, i32 3, align 4
  %14 = getelementptr float, ptr %arrlit6, i32 0
  store float 7.000000e+00, ptr %14, align 4
  %15 = getelementptr float, ptr %arrlit6, i32 1
  store float 8.000000e+00, ptr %15, align 4
  %16 = getelementptr float, ptr %arrlit6, i32 2
  store float 9.000000e+00, ptr %16, align 4
  %17 = getelementptr ptr, ptr %arrlit4, i32 2
  store ptr %arrlit6, ptr %17, align 8
  %i_ptr = alloca i32, align 4
  store i32 1, ptr %i_ptr, align 4
  br label %forcond

forcond:                                          ; preds = %loop, %entry
  %i = load i32, ptr %i_ptr, align 4
  %cond = icmp sle i32 %i, 3
  br i1 %cond, label %loop, label %afterloop

loop:                                             ; preds = %forcond
  %i.load = load float, ptr %i_ptr, align 4
  %i7 = load i32, ptr %i_ptr, align 4
  %next_i = add i32 %i7, 1
  store i32 %next_i, ptr %i_ptr, align 4
  br label %forcond

afterloop:                                        ; preds = %forcond
  %calltmp = call i32 @_dotProduct(i32 5)
  %dp = alloca i32, align 4
  store i32 %calltmp, ptr %dp, align 4
  %Int = call ptr @malloc(i64 36)
  %dp.load = load i32, ptr %dp, align 4
  ret i32 %dp.load
}

declare void @csec_set_command_line_args(i32, ptr)

define internal i32 @__csec_jit_entry() {
entry:
  %user.main = call i32 @_main()
  ret i32 %user.main
}
