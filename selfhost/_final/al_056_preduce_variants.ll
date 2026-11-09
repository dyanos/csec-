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
  %arrlit1 = alloca i32, i32 5, align 4
  %5 = getelementptr i32, ptr %arrlit1, i32 0
  store i32 2, ptr %5, align 4
  %6 = getelementptr i32, ptr %arrlit1, i32 1
  store i32 4, ptr %6, align 4
  %7 = getelementptr i32, ptr %arrlit1, i32 2
  store i32 6, ptr %7, align 4
  %8 = getelementptr i32, ptr %arrlit1, i32 3
  store i32 8, ptr %8, align 4
  %9 = getelementptr i32, ptr %arrlit1, i32 4
  store i32 10, ptr %9, align 4
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
  %addtmp = add i32 %acc.0, %elem
  %next_i = add i32 %reduce_i.0, 1
  br label %reducecond

afterreduce:                                      ; preds = %reducecond
  %sum = alloca i32, align 4
  store i32 %acc.0, ptr %sum, align 4
  %reduce_arr_decay2 = getelementptr inbounds [5 x i32], ptr %arrlit1, i32 0, i32 0
  %acc3 = alloca i32, align 4
  store i32 10, ptr %acc3, align 4
  %reduce_i4 = alloca i32, align 4
  store i32 0, ptr %reduce_i4, align 4
  %w_ptr = alloca i32, align 4
  br label %reducecond5

reducecond5:                                      ; preds = %reducebody6, %afterreduce
  %i8 = load i32, ptr %reduce_i4, align 4
  %reducecmp9 = icmp slt i32 %i8, 5
  br i1 %reducecmp9, label %reducebody6, label %afterreduce7

reducebody6:                                      ; preds = %reducecond5
  %idx10 = load i32, ptr %reduce_i4, align 4
  %elemptr11 = getelementptr i32, ptr %reduce_arr_decay2, i32 %idx10
  %elem12 = load i32, ptr %elemptr11, align 4
  store i32 %elem12, ptr %w_ptr, align 4
  %total.load = load i32, ptr %acc3, align 4
  %w.load = load i32, ptr %w_ptr, align 4
  %multmp = mul i32 %w.load, 2
  %addtmp13 = add i32 %total.load, %multmp
  store i32 %addtmp13, ptr %acc3, align 4
  %next_i14 = add i32 %idx10, 1
  store i32 %next_i14, ptr %reduce_i4, align 4
  br label %reducecond5, !llvm.loop !0

afterreduce7:                                     ; preds = %reducecond5
  %reduceval15 = load i32, ptr %acc3, align 4
  %weighted = alloca i32, align 4
  store i32 %reduceval15, ptr %weighted, align 4
  %map_arr_decay = getelementptr inbounds [5 x i32], ptr %arrlit, i32 0, i32 0
  %map_i = alloca i32, align 4
  store i32 0, ptr %map_i, align 4
  %x_ptr16 = alloca i32, align 4
  %mapresult = alloca i32, i32 5, align 4
  br label %mapcond

mapcond:                                          ; preds = %mapbody, %afterreduce7
  %i17 = load i32, ptr %map_i, align 4
  %mapcmp = icmp slt i32 %i17, 5
  br i1 %mapcmp, label %mapbody, label %aftermap

mapbody:                                          ; preds = %mapcond
  %idx18 = load i32, ptr %map_i, align 4
  %elemptr19 = getelementptr i32, ptr %map_arr_decay, i32 %idx18
  %elem20 = load i32, ptr %elemptr19, align 4
  store i32 %elem20, ptr %x_ptr16, align 4
  %x.load21 = load i32, ptr %x_ptr16, align 4
  %x.load22 = load i32, ptr %x_ptr16, align 4
  %multmp23 = mul i32 %x.load21, %x.load22
  %resultptr = getelementptr i32, ptr %mapresult, i32 %idx18
  store i32 %multmp23, ptr %resultptr, align 4
  %next_i24 = add i32 %idx18, 1
  store i32 %next_i24, ptr %map_i, align 4
  br label %mapcond

aftermap:                                         ; preds = %mapcond
  %filter_arr_decay = getelementptr inbounds [5 x i32], ptr %arrlit, i32 0, i32 0
  %filterresult = alloca i32, i32 5, align 4
  %filter_init_ptr = getelementptr i32, ptr %filterresult, i32 0
  store i32 0, ptr %filter_init_ptr, align 4
  %filter_init_ptr25 = getelementptr i32, ptr %filterresult, i32 1
  store i32 0, ptr %filter_init_ptr25, align 4
  %filter_init_ptr26 = getelementptr i32, ptr %filterresult, i32 2
  store i32 0, ptr %filter_init_ptr26, align 4
  %filter_init_ptr27 = getelementptr i32, ptr %filterresult, i32 3
  store i32 0, ptr %filter_init_ptr27, align 4
  %filter_init_ptr28 = getelementptr i32, ptr %filterresult, i32 4
  store i32 0, ptr %filter_init_ptr28, align 4
  %filter_count = alloca i32, align 4
  store i32 0, ptr %filter_count, align 4
  %filter_i = alloca i32, align 4
  store i32 0, ptr %filter_i, align 4
  %x_ptr29 = alloca i32, align 4
  br label %filtercond

filtercond:                                       ; preds = %filternext, %aftermap
  %i30 = load i32, ptr %filter_i, align 4
  %filtercmp = icmp slt i32 %i30, 5
  br i1 %filtercmp, label %filterbody, label %afterfilter

filterbody:                                       ; preds = %filtercond
  %idx31 = load i32, ptr %filter_i, align 4
  %elemptr32 = getelementptr i32, ptr %filter_arr_decay, i32 %idx31
  %elem33 = load i32, ptr %elemptr32, align 4
  store i32 %elem33, ptr %x_ptr29, align 4
  %x.load34 = load i32, ptr %x_ptr29, align 4
  %gttmp = icmp sgt i32 %x.load34, 2
  br i1 %gttmp, label %filterstore, label %filternext

filterstore:                                      ; preds = %filterbody
  %count = load i32, ptr %filter_count, align 4
  %resultptr35 = getelementptr i32, ptr %filterresult, i32 %count
  %elem_reload = load i32, ptr %x_ptr29, align 4
  store i32 %elem_reload, ptr %resultptr35, align 4
  %next_count = add i32 %count, 1
  store i32 %next_count, ptr %filter_count, align 4
  br label %filternext

filternext:                                       ; preds = %filterstore, %filterbody
  %idx_reload = load i32, ptr %filter_i, align 4
  %next_i36 = add i32 %idx_reload, 1
  store i32 %next_i36, ptr %filter_i, align 4
  br label %filtercond

afterfilter:                                      ; preds = %filtercond
  %filtered = alloca ptr, align 8
  store ptr %filterresult, ptr %filtered, align 8
  %sum.load = load i32, ptr %sum, align 4
  %weighted.load = load i32, ptr %weighted, align 4
  %addtmp37 = add i32 %sum.load, %weighted.load
  %num.sitofp = sitofp i32 %addtmp37 to double
  %faddtmp = fadd double %num.sitofp, 0.000000e+00
  %faddtmp38 = fadd double %faddtmp, 0.000000e+00
  %abi.fptosi = fptosi double %faddtmp38 to i32
  ret i32 %abi.fptosi
}

declare void @csec_set_command_line_args(i32, ptr)

define internal i32 @__csec_jit_entry() {
entry:
  %user.main = call i32 @_main()
  ret i32 %user.main
}

!0 = distinct !{!0, !1, !2}
!1 = !{!"llvm.loop.vectorize.enable", i1 true}
!2 = !{!"csec.preduce.backend.simd"}
