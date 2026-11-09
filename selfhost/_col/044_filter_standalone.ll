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
  %arrlit = alloca i32, i32 10, align 4
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
  %5 = getelementptr i32, ptr %arrlit, i32 5
  store i32 6, ptr %5, align 4
  %6 = getelementptr i32, ptr %arrlit, i32 6
  store i32 7, ptr %6, align 4
  %7 = getelementptr i32, ptr %arrlit, i32 7
  store i32 8, ptr %7, align 4
  %8 = getelementptr i32, ptr %arrlit, i32 8
  store i32 9, ptr %8, align 4
  %9 = getelementptr i32, ptr %arrlit, i32 9
  store i32 10, ptr %9, align 4
  %filter_arr_decay = getelementptr inbounds [10 x i32], ptr %arrlit, i32 0, i32 0
  %filterresult = alloca i32, i32 10, align 4
  %filter_init_ptr = getelementptr i32, ptr %filterresult, i32 0
  store i32 0, ptr %filter_init_ptr, align 4
  %filter_init_ptr1 = getelementptr i32, ptr %filterresult, i32 1
  store i32 0, ptr %filter_init_ptr1, align 4
  %filter_init_ptr2 = getelementptr i32, ptr %filterresult, i32 2
  store i32 0, ptr %filter_init_ptr2, align 4
  %filter_init_ptr3 = getelementptr i32, ptr %filterresult, i32 3
  store i32 0, ptr %filter_init_ptr3, align 4
  %filter_init_ptr4 = getelementptr i32, ptr %filterresult, i32 4
  store i32 0, ptr %filter_init_ptr4, align 4
  %filter_init_ptr5 = getelementptr i32, ptr %filterresult, i32 5
  store i32 0, ptr %filter_init_ptr5, align 4
  %filter_init_ptr6 = getelementptr i32, ptr %filterresult, i32 6
  store i32 0, ptr %filter_init_ptr6, align 4
  %filter_init_ptr7 = getelementptr i32, ptr %filterresult, i32 7
  store i32 0, ptr %filter_init_ptr7, align 4
  %filter_init_ptr8 = getelementptr i32, ptr %filterresult, i32 8
  store i32 0, ptr %filter_init_ptr8, align 4
  %filter_init_ptr9 = getelementptr i32, ptr %filterresult, i32 9
  store i32 0, ptr %filter_init_ptr9, align 4
  br label %filtercond

filtercond:                                       ; preds = %filternext, %entry
  %filter_i.0 = phi i32 [ 0, %entry ], [ %next_i, %filternext ]
  %filter_count.0 = phi i32 [ 0, %entry ], [ %filter_count.1, %filternext ]
  %filtercmp = icmp slt i32 %filter_i.0, 10
  br i1 %filtercmp, label %filterbody, label %afterfilter

filterbody:                                       ; preds = %filtercond
  %elemptr = getelementptr i32, ptr %filter_arr_decay, i32 %filter_i.0
  %elem = load i32, ptr %elemptr, align 4
  %gttmp = icmp sgt i32 %elem, 5
  br i1 %gttmp, label %filterstore, label %filternext

filterstore:                                      ; preds = %filterbody
  %resultptr = getelementptr i32, ptr %filterresult, i32 %filter_count.0
  store i32 %elem, ptr %resultptr, align 4
  %next_count = add i32 %filter_count.0, 1
  br label %filternext

filternext:                                       ; preds = %filterstore, %filterbody
  %filter_count.1 = phi i32 [ %next_count, %filterstore ], [ %filter_count.0, %filterbody ]
  %next_i = add i32 %filter_i.0, 1
  br label %filtercond

afterfilter:                                      ; preds = %filtercond
  %filter_arr_decay10 = getelementptr inbounds [10 x i32], ptr %arrlit, i32 0, i32 0
  %filterresult11 = alloca i32, i32 10, align 4
  %filter_init_ptr12 = getelementptr i32, ptr %filterresult11, i32 0
  store i32 0, ptr %filter_init_ptr12, align 4
  %filter_init_ptr13 = getelementptr i32, ptr %filterresult11, i32 1
  store i32 0, ptr %filter_init_ptr13, align 4
  %filter_init_ptr14 = getelementptr i32, ptr %filterresult11, i32 2
  store i32 0, ptr %filter_init_ptr14, align 4
  %filter_init_ptr15 = getelementptr i32, ptr %filterresult11, i32 3
  store i32 0, ptr %filter_init_ptr15, align 4
  %filter_init_ptr16 = getelementptr i32, ptr %filterresult11, i32 4
  store i32 0, ptr %filter_init_ptr16, align 4
  %filter_init_ptr17 = getelementptr i32, ptr %filterresult11, i32 5
  store i32 0, ptr %filter_init_ptr17, align 4
  %filter_init_ptr18 = getelementptr i32, ptr %filterresult11, i32 6
  store i32 0, ptr %filter_init_ptr18, align 4
  %filter_init_ptr19 = getelementptr i32, ptr %filterresult11, i32 7
  store i32 0, ptr %filter_init_ptr19, align 4
  %filter_init_ptr20 = getelementptr i32, ptr %filterresult11, i32 8
  store i32 0, ptr %filter_init_ptr20, align 4
  %filter_init_ptr21 = getelementptr i32, ptr %filterresult11, i32 9
  store i32 0, ptr %filter_init_ptr21, align 4
  %filter_count22 = alloca i32, align 4
  store i32 0, ptr %filter_count22, align 4
  %filter_i23 = alloca i32, align 4
  store i32 0, ptr %filter_i23, align 4
  %y_ptr = alloca i32, align 4
  br label %filtercond24

filtercond24:                                     ; preds = %filternext27, %afterfilter
  %i29 = load i32, ptr %filter_i23, align 4
  %filtercmp30 = icmp slt i32 %i29, 10
  br i1 %filtercmp30, label %filterbody25, label %afterfilter28

filterbody25:                                     ; preds = %filtercond24
  %idx31 = load i32, ptr %filter_i23, align 4
  %elemptr32 = getelementptr i32, ptr %filter_arr_decay10, i32 %idx31
  %elem33 = load i32, ptr %elemptr32, align 4
  store i32 %elem33, ptr %y_ptr, align 4
  %y.load = load i32, ptr %y_ptr, align 4
  %eqtmp = icmp eq i32 %y.load, 3
  br i1 %eqtmp, label %filterstore26, label %filternext27

filterstore26:                                    ; preds = %filterbody25
  %count34 = load i32, ptr %filter_count22, align 4
  %resultptr35 = getelementptr i32, ptr %filterresult11, i32 %count34
  %elem_reload36 = load i32, ptr %y_ptr, align 4
  store i32 %elem_reload36, ptr %resultptr35, align 4
  %next_count37 = add i32 %count34, 1
  store i32 %next_count37, ptr %filter_count22, align 4
  br label %filternext27

filternext27:                                     ; preds = %filterstore26, %filterbody25
  %idx_reload38 = load i32, ptr %filter_i23, align 4
  %next_i39 = add i32 %idx_reload38, 1
  store i32 %next_i39, ptr %filter_i23, align 4
  br label %filtercond24

afterfilter28:                                    ; preds = %filtercond24
  ret i32 0
}

declare void @csec_set_command_line_args(i32, ptr)

define internal i32 @__csec_jit_entry() {
entry:
  %user.main = call i32 @_main()
  ret i32 %user.main
}
