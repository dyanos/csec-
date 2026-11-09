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
  store i32 10, ptr %0, align 4
  %1 = getelementptr i32, ptr %arrlit, i32 1
  store i32 20, ptr %1, align 4
  %2 = getelementptr i32, ptr %arrlit, i32 2
  store i32 30, ptr %2, align 4
  %3 = getelementptr i32, ptr %arrlit, i32 3
  store i32 40, ptr %3, align 4
  %4 = getelementptr i32, ptr %arrlit, i32 4
  store i32 50, ptr %4, align 4
  %arrlit1 = alloca i32, i32 3, align 4
  %5 = getelementptr i32, ptr %arrlit1, i32 0
  store i32 1, ptr %5, align 4
  %6 = getelementptr i32, ptr %arrlit1, i32 1
  store i32 2, ptr %6, align 4
  %7 = getelementptr i32, ptr %arrlit1, i32 2
  store i32 3, ptr %7, align 4
  %map_arr_decay = getelementptr inbounds [5 x i32], ptr %arrlit, i32 0, i32 0
  %mapresult = alloca i32, i32 5, align 4
  br label %mapcond

mapcond:                                          ; preds = %mapbody, %entry
  %map_i.0 = phi i32 [ 0, %entry ], [ %next_i, %mapbody ]
  %mapcmp = icmp slt i32 %map_i.0, 5
  br i1 %mapcmp, label %mapbody, label %aftermap

mapbody:                                          ; preds = %mapcond
  %elemptr = getelementptr i32, ptr %map_arr_decay, i32 %map_i.0
  %elem = load i32, ptr %elemptr, align 4
  %multmp = mul i32 %elem, 2
  %resultptr = getelementptr i32, ptr %mapresult, i32 %map_i.0
  store i32 %multmp, ptr %resultptr, align 4
  %next_i = add i32 %map_i.0, 1
  br label %mapcond

aftermap:                                         ; preds = %mapcond
  %filter_arr_decay = getelementptr inbounds [5 x i32], ptr %arrlit, i32 0, i32 0
  %filterresult = alloca i32, i32 5, align 4
  %filter_init_ptr = getelementptr i32, ptr %filterresult, i32 0
  store i32 0, ptr %filter_init_ptr, align 4
  %filter_init_ptr2 = getelementptr i32, ptr %filterresult, i32 1
  store i32 0, ptr %filter_init_ptr2, align 4
  %filter_init_ptr3 = getelementptr i32, ptr %filterresult, i32 2
  store i32 0, ptr %filter_init_ptr3, align 4
  %filter_init_ptr4 = getelementptr i32, ptr %filterresult, i32 3
  store i32 0, ptr %filter_init_ptr4, align 4
  %filter_init_ptr5 = getelementptr i32, ptr %filterresult, i32 4
  store i32 0, ptr %filter_init_ptr5, align 4
  %filter_count = alloca i32, align 4
  store i32 0, ptr %filter_count, align 4
  %filter_i = alloca i32, align 4
  store i32 0, ptr %filter_i, align 4
  %x_ptr6 = alloca i32, align 4
  br label %filtercond

filtercond:                                       ; preds = %filternext, %aftermap
  %i7 = load i32, ptr %filter_i, align 4
  %filtercmp = icmp slt i32 %i7, 5
  br i1 %filtercmp, label %filterbody, label %afterfilter

filterbody:                                       ; preds = %filtercond
  %idx8 = load i32, ptr %filter_i, align 4
  %elemptr9 = getelementptr i32, ptr %filter_arr_decay, i32 %idx8
  %elem10 = load i32, ptr %elemptr9, align 4
  store i32 %elem10, ptr %x_ptr6, align 4
  %x.load11 = load i32, ptr %x_ptr6, align 4
  %gttmp = icmp sgt i32 %x.load11, 20
  br i1 %gttmp, label %filterstore, label %filternext

filterstore:                                      ; preds = %filterbody
  %count = load i32, ptr %filter_count, align 4
  %resultptr12 = getelementptr i32, ptr %filterresult, i32 %count
  %elem_reload = load i32, ptr %x_ptr6, align 4
  store i32 %elem_reload, ptr %resultptr12, align 4
  %next_count = add i32 %count, 1
  store i32 %next_count, ptr %filter_count, align 4
  br label %filternext

filternext:                                       ; preds = %filterstore, %filterbody
  %idx_reload = load i32, ptr %filter_i, align 4
  %next_i13 = add i32 %idx_reload, 1
  store i32 %next_i13, ptr %filter_i, align 4
  br label %filtercond

afterfilter:                                      ; preds = %filtercond
  %reduce_arr_decay = getelementptr inbounds [3 x i32], ptr %arrlit1, i32 0, i32 0
  %acc = alloca i32, align 4
  store i32 0, ptr %acc, align 4
  %reduce_i = alloca i32, align 4
  store i32 0, ptr %reduce_i, align 4
  %x_ptr14 = alloca i32, align 4
  br label %reducecond

reducecond:                                       ; preds = %reducebody, %afterfilter
  %i15 = load i32, ptr %reduce_i, align 4
  %reducecmp = icmp slt i32 %i15, 3
  br i1 %reducecmp, label %reducebody, label %afterreduce

reducebody:                                       ; preds = %reducecond
  %idx16 = load i32, ptr %reduce_i, align 4
  %elemptr17 = getelementptr i32, ptr %reduce_arr_decay, i32 %idx16
  %elem18 = load i32, ptr %elemptr17, align 4
  store i32 %elem18, ptr %x_ptr14, align 4
  %x.load19 = load i32, ptr %x_ptr14, align 4
  %addtmp = add i32 %x.load19, 1
  store i32 %addtmp, ptr %acc, align 4
  %next_i20 = add i32 %idx16, 1
  store i32 %next_i20, ptr %reduce_i, align 4
  br label %reducecond

afterreduce:                                      ; preds = %reducecond
  %reduceval = load i32, ptr %acc, align 4
  ret i32 0
}

declare void @csec_set_command_line_args(i32, ptr)

define internal i32 @__csec_jit_entry() {
entry:
  %user.main = call i32 @_main()
  ret i32 %user.main
}
