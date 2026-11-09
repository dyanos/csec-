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
  %arrlit = alloca i32, i32 5, align 4
  %0 = getelementptr i32, ptr %arrlit, i32 0
  store i32 1, ptr %0, align 4
  %1 = getelementptr i32, ptr %arrlit, i32 1
  store i32 2, ptr %1, align 4
  %2 = getelementptr i32, ptr %arrlit, i32 2
  store i32 3, ptr %2, align 4
  %3 = getelementptr i32, ptr %arrlit, i32 3
  store i32 4, ptr %3, align 4
  %4 = getelementptr i32, ptr %arrlit, i32 4
  store i32 5, ptr %4, align 4
  %reduce_arr_decay = getelementptr inbounds [5 x i32], ptr %arrlit, i32 0, i32 0
  br label %reducecond

reducecond:                                       ; preds = %reducebody, %entry
  %reduce_i.0 = phi i32 [ 0, %entry ], [ %next_i, %reducebody ]
  %acc.0 = phi i32 [ 0, %entry ], [ %addtmp, %reducebody ]
  %reducecmp = icmp slt i32 %reduce_i.0, 5
  br i1 %reducecmp, label %reducebody, label %afterreduce

reducebody:                                       ; preds = %reducecond
  %elemptr = getelementptr i32, ptr %reduce_arr_decay, i32 %reduce_i.0
  %elem = load i32, ptr %elemptr, align 4
  %addtmp = add i32 %elem, 1
  %next_i = add i32 %reduce_i.0, 1
  br label %reducecond

afterreduce:                                      ; preds = %reducecond
  %reduce_arr_decay1 = getelementptr inbounds [5 x i32], ptr %arrlit, i32 0, i32 0
  %acc2 = alloca i32, align 4
  store i32 1, ptr %acc2, align 4
  %reduce_i3 = alloca i32, align 4
  store i32 0, ptr %reduce_i3, align 4
  %y_ptr = alloca i32, align 4
  br label %reducecond4

reducecond4:                                      ; preds = %reducebody5, %afterreduce
  %i7 = load i32, ptr %reduce_i3, align 4
  %reducecmp8 = icmp slt i32 %i7, 5
  br i1 %reducecmp8, label %reducebody5, label %afterreduce6

reducebody5:                                      ; preds = %reducecond4
  %idx9 = load i32, ptr %reduce_i3, align 4
  %elemptr10 = getelementptr i32, ptr %reduce_arr_decay1, i32 %idx9
  %elem11 = load i32, ptr %elemptr10, align 4
  store i32 %elem11, ptr %y_ptr, align 4
  %y.load = load i32, ptr %y_ptr, align 4
  %multmp = mul i32 %y.load, 2
  store i32 %multmp, ptr %acc2, align 4
  %next_i12 = add i32 %idx9, 1
  store i32 %next_i12, ptr %reduce_i3, align 4
  br label %reducecond4

afterreduce6:                                     ; preds = %reducecond4
  %reduceval13 = load i32, ptr %acc2, align 4
  %reduce_arr_decay14 = getelementptr inbounds [5 x i32], ptr %arrlit, i32 0, i32 0
  %acc15 = alloca i32, align 4
  store i32 100, ptr %acc15, align 4
  %reduce_i16 = alloca i32, align 4
  store i32 0, ptr %reduce_i16, align 4
  %z_ptr = alloca i32, align 4
  br label %reducecond17

reducecond17:                                     ; preds = %reducebody18, %afterreduce6
  %i20 = load i32, ptr %reduce_i16, align 4
  %reducecmp21 = icmp slt i32 %i20, 5
  br i1 %reducecmp21, label %reducebody18, label %afterreduce19

reducebody18:                                     ; preds = %reducecond17
  %idx22 = load i32, ptr %reduce_i16, align 4
  %elemptr23 = getelementptr i32, ptr %reduce_arr_decay14, i32 %idx22
  %elem24 = load i32, ptr %elemptr23, align 4
  store i32 %elem24, ptr %z_ptr, align 4
  %z.load = load i32, ptr %z_ptr, align 4
  %addtmp25 = add i32 %z.load, 1
  store i32 %addtmp25, ptr %acc15, align 4
  %next_i26 = add i32 %idx22, 1
  store i32 %next_i26, ptr %reduce_i16, align 4
  br label %reducecond17

afterreduce19:                                    ; preds = %reducecond17
  %reduceval27 = load i32, ptr %acc15, align 4
  ret i32 0
}

declare void @csec_set_command_line_args(i32, ptr)

define internal i32 @__csec_jit_entry() {
entry:
  %user.main = call i32 @_main()
  ret i32 %user.main
}
