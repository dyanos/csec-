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
  %map_arr_decay = getelementptr inbounds [10 x i32], ptr %arrlit, i32 0, i32 0
  %mapresult = alloca i32, i32 10, align 4
  br label %mapcond

mapcond:                                          ; preds = %mapbody, %entry
  %map_i.0 = phi i32 [ 0, %entry ], [ %next_i, %mapbody ]
  %mapcmp = icmp slt i32 %map_i.0, 10
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
  %pmap_arr_decay = getelementptr inbounds [10 x i32], ptr %arrlit, i32 0, i32 0
  %x_typecheck_ptr = alloca i32, align 4
  %pmap_i = alloca i32, align 4
  store i32 0, ptr %pmap_i, align 4
  %x_ptr1 = alloca i32, align 4
  %pmapresult = alloca i32, i32 10, align 4
  br label %pmapcond

pmapcond:                                         ; preds = %pmapbody, %aftermap
  %i2 = load i32, ptr %pmap_i, align 4
  %pmapcmp = icmp slt i32 %i2, 10
  br i1 %pmapcmp, label %pmapbody, label %afterpmap

pmapbody:                                         ; preds = %pmapcond
  %idx3 = load i32, ptr %pmap_i, align 4
  %elemptr4 = getelementptr i32, ptr %pmap_arr_decay, i32 %idx3
  %elem5 = load i32, ptr %elemptr4, align 4
  store i32 %elem5, ptr %x_ptr1, align 4
  %x.load6 = load i32, ptr %x_ptr1, align 4
  %x.load7 = load i32, ptr %x_ptr1, align 4
  %multmp8 = mul i32 %x.load6, %x.load7
  %resultptr9 = getelementptr i32, ptr %pmapresult, i32 %idx3
  store i32 %multmp8, ptr %resultptr9, align 4
  %next_i10 = add i32 %idx3, 1
  store i32 %next_i10, ptr %pmap_i, align 4
  br label %pmapcond

afterpmap:                                        ; preds = %pmapcond
  %filter_arr_decay = getelementptr inbounds [10 x i32], ptr %arrlit, i32 0, i32 0
  %filterresult = alloca i32, i32 10, align 4
  %filter_init_ptr = getelementptr i32, ptr %filterresult, i32 0
  store i32 0, ptr %filter_init_ptr, align 4
  %filter_init_ptr11 = getelementptr i32, ptr %filterresult, i32 1
  store i32 0, ptr %filter_init_ptr11, align 4
  %filter_init_ptr12 = getelementptr i32, ptr %filterresult, i32 2
  store i32 0, ptr %filter_init_ptr12, align 4
  %filter_init_ptr13 = getelementptr i32, ptr %filterresult, i32 3
  store i32 0, ptr %filter_init_ptr13, align 4
  %filter_init_ptr14 = getelementptr i32, ptr %filterresult, i32 4
  store i32 0, ptr %filter_init_ptr14, align 4
  %filter_init_ptr15 = getelementptr i32, ptr %filterresult, i32 5
  store i32 0, ptr %filter_init_ptr15, align 4
  %filter_init_ptr16 = getelementptr i32, ptr %filterresult, i32 6
  store i32 0, ptr %filter_init_ptr16, align 4
  %filter_init_ptr17 = getelementptr i32, ptr %filterresult, i32 7
  store i32 0, ptr %filter_init_ptr17, align 4
  %filter_init_ptr18 = getelementptr i32, ptr %filterresult, i32 8
  store i32 0, ptr %filter_init_ptr18, align 4
  %filter_init_ptr19 = getelementptr i32, ptr %filterresult, i32 9
  store i32 0, ptr %filter_init_ptr19, align 4
  %filter_count = alloca i32, align 4
  store i32 0, ptr %filter_count, align 4
  %filter_i = alloca i32, align 4
  store i32 0, ptr %filter_i, align 4
  %x_ptr20 = alloca i32, align 4
  br label %filtercond

filtercond:                                       ; preds = %filternext, %afterpmap
  %i21 = load i32, ptr %filter_i, align 4
  %filtercmp = icmp slt i32 %i21, 10
  br i1 %filtercmp, label %filterbody, label %afterfilter

filterbody:                                       ; preds = %filtercond
  %idx22 = load i32, ptr %filter_i, align 4
  %elemptr23 = getelementptr i32, ptr %filter_arr_decay, i32 %idx22
  %elem24 = load i32, ptr %elemptr23, align 4
  store i32 %elem24, ptr %x_ptr20, align 4
  %x.load25 = load i32, ptr %x_ptr20, align 4
  %gttmp = icmp sgt i32 %x.load25, 5
  br i1 %gttmp, label %filterstore, label %filternext

filterstore:                                      ; preds = %filterbody
  %count = load i32, ptr %filter_count, align 4
  %resultptr26 = getelementptr i32, ptr %filterresult, i32 %count
  %elem_reload = load i32, ptr %x_ptr20, align 4
  store i32 %elem_reload, ptr %resultptr26, align 4
  %next_count = add i32 %count, 1
  store i32 %next_count, ptr %filter_count, align 4
  br label %filternext

filternext:                                       ; preds = %filterstore, %filterbody
  %idx_reload = load i32, ptr %filter_i, align 4
  %next_i27 = add i32 %idx_reload, 1
  store i32 %next_i27, ptr %filter_i, align 4
  br label %filtercond

afterfilter:                                      ; preds = %filtercond
  %reduce_arr_decay = getelementptr inbounds [10 x i32], ptr %arrlit, i32 0, i32 0
  %acc = alloca i32, align 4
  store i32 0, ptr %acc, align 4
  %reduce_i = alloca i32, align 4
  store i32 0, ptr %reduce_i, align 4
  %x_ptr28 = alloca i32, align 4
  br label %reducecond

reducecond:                                       ; preds = %reducebody, %afterfilter
  %i29 = load i32, ptr %reduce_i, align 4
  %reducecmp = icmp slt i32 %i29, 10
  br i1 %reducecmp, label %reducebody, label %afterreduce

reducebody:                                       ; preds = %reducecond
  %idx30 = load i32, ptr %reduce_i, align 4
  %elemptr31 = getelementptr i32, ptr %reduce_arr_decay, i32 %idx30
  %elem32 = load i32, ptr %elemptr31, align 4
  store i32 %elem32, ptr %x_ptr28, align 4
  %x.load33 = load i32, ptr %x_ptr28, align 4
  %addtmp = add i32 %x.load33, 1
  store i32 %addtmp, ptr %acc, align 4
  %next_i34 = add i32 %idx30, 1
  store i32 %next_i34, ptr %reduce_i, align 4
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
