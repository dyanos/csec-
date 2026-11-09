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

define i32 @_sumArray(ptr %0) {
entry:
  ret i32 0
}

define i32 @_main() {
entry:
  %arrlit = alloca i32, i32 3, align 4
  %0 = getelementptr i32, ptr %arrlit, i32 0
  store i32 1, ptr %0, align 4
  %1 = getelementptr i32, ptr %arrlit, i32 1
  store i32 2, ptr %1, align 4
  %2 = getelementptr i32, ptr %arrlit, i32 2
  store i32 3, ptr %2, align 4
  %arrlit1 = alloca i32, i32 5, align 4
  %3 = getelementptr i32, ptr %arrlit1, i32 0
  store i32 10, ptr %3, align 4
  %4 = getelementptr i32, ptr %arrlit1, i32 1
  store i32 20, ptr %4, align 4
  %5 = getelementptr i32, ptr %arrlit1, i32 2
  store i32 30, ptr %5, align 4
  %6 = getelementptr i32, ptr %arrlit1, i32 3
  store i32 40, ptr %6, align 4
  %7 = getelementptr i32, ptr %arrlit1, i32 4
  store i32 50, ptr %7, align 4
  %arrlit2 = alloca i32, i32 10, align 4
  %8 = getelementptr i32, ptr %arrlit2, i32 0
  store i32 1, ptr %8, align 4
  %9 = getelementptr i32, ptr %arrlit2, i32 1
  store i32 2, ptr %9, align 4
  %10 = getelementptr i32, ptr %arrlit2, i32 2
  store i32 3, ptr %10, align 4
  %11 = getelementptr i32, ptr %arrlit2, i32 3
  store i32 4, ptr %11, align 4
  %12 = getelementptr i32, ptr %arrlit2, i32 4
  store i32 5, ptr %12, align 4
  %13 = getelementptr i32, ptr %arrlit2, i32 5
  store i32 6, ptr %13, align 4
  %14 = getelementptr i32, ptr %arrlit2, i32 6
  store i32 7, ptr %14, align 4
  %15 = getelementptr i32, ptr %arrlit2, i32 7
  store i32 8, ptr %15, align 4
  %16 = getelementptr i32, ptr %arrlit2, i32 8
  store i32 9, ptr %16, align 4
  %17 = getelementptr i32, ptr %arrlit2, i32 9
  store i32 10, ptr %17, align 4
  %arrlit3 = alloca i32, i32 2, align 4
  %18 = getelementptr i32, ptr %arrlit3, i32 0
  store i32 1, ptr %18, align 4
  %19 = getelementptr i32, ptr %arrlit3, i32 1
  store i32 2, ptr %19, align 4
  %arrlit4 = alloca ptr, i32 3, align 8
  %20 = getelementptr ptr, ptr %arrlit4, i32 0
  store ptr %arrlit3, ptr %20, align 8
  %arrlit5 = alloca i32, i32 2, align 4
  %21 = getelementptr i32, ptr %arrlit5, i32 0
  store i32 3, ptr %21, align 4
  %22 = getelementptr i32, ptr %arrlit5, i32 1
  store i32 4, ptr %22, align 4
  %23 = getelementptr ptr, ptr %arrlit4, i32 1
  store ptr %arrlit5, ptr %23, align 8
  %arrlit6 = alloca i32, i32 2, align 4
  %24 = getelementptr i32, ptr %arrlit6, i32 0
  store i32 5, ptr %24, align 4
  %25 = getelementptr i32, ptr %arrlit6, i32 1
  store i32 6, ptr %25, align 4
  %26 = getelementptr ptr, ptr %arrlit4, i32 2
  store ptr %arrlit6, ptr %26, align 8
  %arrlit7 = alloca i32, i32 2, align 4
  %27 = getelementptr i32, ptr %arrlit7, i32 0
  store i32 1, ptr %27, align 4
  %28 = getelementptr i32, ptr %arrlit7, i32 1
  store i32 2, ptr %28, align 4
  %arrlit8 = alloca ptr, i32 2, align 8
  %29 = getelementptr ptr, ptr %arrlit8, i32 0
  store ptr %arrlit7, ptr %29, align 8
  %arrlit9 = alloca i32, i32 2, align 4
  %30 = getelementptr i32, ptr %arrlit9, i32 0
  store i32 3, ptr %30, align 4
  %31 = getelementptr i32, ptr %arrlit9, i32 1
  store i32 4, ptr %31, align 4
  %32 = getelementptr ptr, ptr %arrlit8, i32 1
  store ptr %arrlit9, ptr %32, align 8
  %arrlit10 = alloca ptr, i32 2, align 8
  %33 = getelementptr ptr, ptr %arrlit10, i32 0
  store ptr %arrlit8, ptr %33, align 8
  %arrlit11 = alloca i32, i32 2, align 4
  %34 = getelementptr i32, ptr %arrlit11, i32 0
  store i32 5, ptr %34, align 4
  %35 = getelementptr i32, ptr %arrlit11, i32 1
  store i32 6, ptr %35, align 4
  %arrlit12 = alloca ptr, i32 2, align 8
  %36 = getelementptr ptr, ptr %arrlit12, i32 0
  store ptr %arrlit11, ptr %36, align 8
  %arrlit13 = alloca i32, i32 2, align 4
  %37 = getelementptr i32, ptr %arrlit13, i32 0
  store i32 7, ptr %37, align 4
  %38 = getelementptr i32, ptr %arrlit13, i32 1
  store i32 8, ptr %38, align 4
  %39 = getelementptr ptr, ptr %arrlit12, i32 1
  store ptr %arrlit13, ptr %39, align 8
  %40 = getelementptr ptr, ptr %arrlit10, i32 1
  store ptr %arrlit12, ptr %40, align 8
  %Int = call ptr @malloc(i64 400)
  %Int14 = call ptr @malloc(i64 400)
  %map_arr_decay = getelementptr inbounds [3 x i32], ptr %arrlit, i32 0, i32 0
  %mapresult = alloca i32, i32 3, align 4
  br label %mapcond

mapcond:                                          ; preds = %mapbody, %entry
  %map_i.0 = phi i32 [ 0, %entry ], [ %next_i, %mapbody ]
  %mapcmp = icmp slt i32 %map_i.0, 3
  br i1 %mapcmp, label %mapbody, label %aftermap

mapbody:                                          ; preds = %mapcond
  %elemptr = getelementptr i32, ptr %map_arr_decay, i32 %map_i.0
  %elem = load i32, ptr %elemptr, align 4
  %multmp = mul i32 %elem, %elem
  %resultptr = getelementptr i32, ptr %mapresult, i32 %map_i.0
  store i32 %multmp, ptr %resultptr, align 4
  %next_i = add i32 %map_i.0, 1
  br label %mapcond

aftermap:                                         ; preds = %mapcond
  %pmap_arr_decay = getelementptr inbounds [5 x i32], ptr %arrlit1, i32 0, i32 0
  %x_typecheck_ptr = alloca i32, align 4
  %pmap_i = alloca i32, align 4
  store i32 0, ptr %pmap_i, align 4
  %x_ptr16 = alloca i32, align 4
  %pmapresult = alloca i32, i32 5, align 4
  br label %pmapcond

pmapcond:                                         ; preds = %pmapbody, %aftermap
  %i17 = load i32, ptr %pmap_i, align 4
  %pmapcmp = icmp slt i32 %i17, 5
  br i1 %pmapcmp, label %pmapbody, label %afterpmap

pmapbody:                                         ; preds = %pmapcond
  %idx18 = load i32, ptr %pmap_i, align 4
  %elemptr19 = getelementptr i32, ptr %pmap_arr_decay, i32 %idx18
  %elem20 = load i32, ptr %elemptr19, align 4
  store i32 %elem20, ptr %x_ptr16, align 4
  %x.load21 = load i32, ptr %x_ptr16, align 4
  %x.load22 = load i32, ptr %x_ptr16, align 4
  %addtmp = add i32 %x.load21, %x.load22
  %resultptr23 = getelementptr i32, ptr %pmapresult, i32 %idx18
  store i32 %addtmp, ptr %resultptr23, align 4
  %next_i24 = add i32 %idx18, 1
  store i32 %next_i24, ptr %pmap_i, align 4
  br label %pmapcond

afterpmap:                                        ; preds = %pmapcond
  %filter_arr_decay = getelementptr inbounds [10 x i32], ptr %arrlit2, i32 0, i32 0
  %filterresult = alloca i32, i32 10, align 4
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
  %filter_init_ptr29 = getelementptr i32, ptr %filterresult, i32 5
  store i32 0, ptr %filter_init_ptr29, align 4
  %filter_init_ptr30 = getelementptr i32, ptr %filterresult, i32 6
  store i32 0, ptr %filter_init_ptr30, align 4
  %filter_init_ptr31 = getelementptr i32, ptr %filterresult, i32 7
  store i32 0, ptr %filter_init_ptr31, align 4
  %filter_init_ptr32 = getelementptr i32, ptr %filterresult, i32 8
  store i32 0, ptr %filter_init_ptr32, align 4
  %filter_init_ptr33 = getelementptr i32, ptr %filterresult, i32 9
  store i32 0, ptr %filter_init_ptr33, align 4
  %filter_count = alloca i32, align 4
  store i32 0, ptr %filter_count, align 4
  %filter_i = alloca i32, align 4
  store i32 0, ptr %filter_i, align 4
  %x_ptr34 = alloca i32, align 4
  br label %filtercond

filtercond:                                       ; preds = %filternext, %afterpmap
  %i35 = load i32, ptr %filter_i, align 4
  %filtercmp = icmp slt i32 %i35, 10
  br i1 %filtercmp, label %filterbody, label %afterfilter

filterbody:                                       ; preds = %filtercond
  %idx36 = load i32, ptr %filter_i, align 4
  %elemptr37 = getelementptr i32, ptr %filter_arr_decay, i32 %idx36
  %elem38 = load i32, ptr %elemptr37, align 4
  store i32 %elem38, ptr %x_ptr34, align 4
  %x.load39 = load i32, ptr %x_ptr34, align 4
  %gttmp = icmp sgt i32 %x.load39, 5
  br i1 %gttmp, label %filterstore, label %filternext

filterstore:                                      ; preds = %filterbody
  %count = load i32, ptr %filter_count, align 4
  %resultptr40 = getelementptr i32, ptr %filterresult, i32 %count
  %elem_reload = load i32, ptr %x_ptr34, align 4
  store i32 %elem_reload, ptr %resultptr40, align 4
  %next_count = add i32 %count, 1
  store i32 %next_count, ptr %filter_count, align 4
  br label %filternext

filternext:                                       ; preds = %filterstore, %filterbody
  %idx_reload = load i32, ptr %filter_i, align 4
  %next_i41 = add i32 %idx_reload, 1
  store i32 %next_i41, ptr %filter_i, align 4
  br label %filtercond

afterfilter:                                      ; preds = %filtercond
  %filter_len = load i32, ptr %filter_count, align 4
  %reduce_arr_decay = getelementptr inbounds [10 x i32], ptr %arrlit2, i32 0, i32 0
  %acc = alloca i32, align 4
  store i32 0, ptr %acc, align 4
  %reduce_i = alloca i32, align 4
  store i32 0, ptr %reduce_i, align 4
  %x_ptr42 = alloca i32, align 4
  br label %reducecond

reducecond:                                       ; preds = %reducebody, %afterfilter
  %i43 = load i32, ptr %reduce_i, align 4
  %reducecmp = icmp slt i32 %i43, 10
  br i1 %reducecmp, label %reducebody, label %afterreduce

reducebody:                                       ; preds = %reducecond
  %idx44 = load i32, ptr %reduce_i, align 4
  %elemptr45 = getelementptr i32, ptr %reduce_arr_decay, i32 %idx44
  %elem46 = load i32, ptr %elemptr45, align 4
  store i32 %elem46, ptr %x_ptr42, align 4
  %x.load47 = load i32, ptr %x_ptr42, align 4
  %addtmp48 = add i32 %x.load47, 1
  store i32 %addtmp48, ptr %acc, align 4
  %next_i49 = add i32 %idx44, 1
  store i32 %next_i49, ptr %reduce_i, align 4
  br label %reducecond

afterreduce:                                      ; preds = %reducecond
  %reduceval = load i32, ptr %acc, align 4
  %total = alloca i32, align 4
  store i32 0, ptr %total, align 4
  %i_ptr = alloca i32, align 4
  store i32 1, ptr %i_ptr, align 4
  br label %forcond

forcond:                                          ; preds = %loop, %afterreduce
  %i50 = load i32, ptr %i_ptr, align 4
  %cond = icmp sle i32 %i50, 10
  br i1 %cond, label %loop, label %afterloop

loop:                                             ; preds = %forcond
  %total.load = load i32, ptr %total, align 4
  %total.load51 = load i32, ptr %total, align 4
  %i.load = load i32, ptr %i_ptr, align 4
  %addtmp52 = add i32 %total.load51, %i.load
  store i32 %addtmp52, ptr %total, align 4
  %i53 = load i32, ptr %i_ptr, align 4
  %next_i54 = add i32 %i53, 1
  store i32 %next_i54, ptr %i_ptr, align 4
  br label %forcond

afterloop:                                        ; preds = %forcond
  %count55 = alloca i32, align 4
  store i32 0, ptr %count55, align 4
  %j_ptr = alloca i32, align 4
  store i32 0, ptr %j_ptr, align 4
  br label %forcond56

forcond56:                                        ; preds = %loop57, %afterloop
  %j = load i32, ptr %j_ptr, align 4
  %cond59 = icmp sle i32 %j, 19
  br i1 %cond59, label %loop57, label %afterloop58

loop57:                                           ; preds = %forcond56
  %count.load = load i32, ptr %count55, align 4
  %count.load60 = load i32, ptr %count55, align 4
  %addtmp61 = add i32 %count.load60, 1
  store i32 %addtmp61, ptr %count55, align 4
  %j62 = load i32, ptr %j_ptr, align 4
  %next_i63 = add i32 %j62, 1
  store i32 %next_i63, ptr %j_ptr, align 4
  br label %forcond56

afterloop58:                                      ; preds = %forcond56
  %total.load64 = load i32, ptr %total, align 4
  %count.load65 = load i32, ptr %count55, align 4
  %addtmp66 = add i32 %total.load64, %count.load65
  ret i32 %addtmp66
}

declare void @csec_set_command_line_args(i32, ptr)

define internal i32 @__csec_jit_entry() {
entry:
  %user.main = call i32 @_main()
  ret i32 %user.main
}
