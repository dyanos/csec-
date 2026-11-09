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
  %arrlit = alloca i32, i32 4, align 4
  %0 = getelementptr i32, ptr %arrlit, i32 0
  store i32 1, ptr %0, align 4
  %1 = getelementptr i32, ptr %arrlit, i32 1
  store i32 2, ptr %1, align 4
  %2 = getelementptr i32, ptr %arrlit, i32 2
  store i32 3, ptr %2, align 4
  %3 = getelementptr i32, ptr %arrlit, i32 3
  store i32 4, ptr %3, align 4
  %reduce_arr_decay = getelementptr inbounds [4 x i32], ptr %arrlit, i32 0, i32 0
  br label %reducecond

reducecond:                                       ; preds = %reducebody, %entry
  %reduce_i.0 = phi i32 [ 0, %entry ], [ %next_i, %reducebody ]
  %acc.0 = phi i32 [ 0, %entry ], [ %addtmp, %reducebody ]
  %reducecmp = icmp slt i32 %reduce_i.0, 4
  br i1 %reducecmp, label %reducebody, label %afterreduce

reducebody:                                       ; preds = %reducecond
  %elemptr = getelementptr i32, ptr %reduce_arr_decay, i32 %reduce_i.0
  %elem = load i32, ptr %elemptr, align 4
  %addtmp = add i32 %elem, 1
  %next_i = add i32 %reduce_i.0, 1
  br label %reducecond

afterreduce:                                      ; preds = %reducecond
  ret i32 0
}

declare void @csec_set_command_line_args(i32, ptr)

define internal i32 @__csec_jit_entry() {
entry:
  %user.main = call i32 @_main()
  ret i32 %user.main
}
