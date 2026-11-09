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
  %map_arr_decay = getelementptr inbounds [4 x i32], ptr %arrlit, i32 0, i32 0
  %mapresult = alloca i32, i32 4, align 4
  br label %mapcond

mapcond:                                          ; preds = %mapbody, %entry
  %map_i.0 = phi i32 [ 0, %entry ], [ %next_i, %mapbody ]
  %mapcmp = icmp slt i32 %map_i.0, 4
  br i1 %mapcmp, label %mapbody, label %aftermap

mapbody:                                          ; preds = %mapcond
  %elemptr = getelementptr i32, ptr %map_arr_decay, i32 %map_i.0
  %elem = load i32, ptr %elemptr, align 4
  %addtmp = add i32 %elem, 1
  %resultptr = getelementptr i32, ptr %mapresult, i32 %map_i.0
  store i32 %addtmp, ptr %resultptr, align 4
  %next_i = add i32 %map_i.0, 1
  br label %mapcond

aftermap:                                         ; preds = %mapcond
  %pmap_arr_decay = getelementptr inbounds [4 x i32], ptr %arrlit, i32 0, i32 0
  %x_typecheck_ptr = alloca i32, align 4
  %pmap_i = alloca i32, align 4
  store i32 0, ptr %pmap_i, align 4
  %x_ptr1 = alloca i32, align 4
  %pmapresult = alloca i32, i32 4, align 4
  br label %pmapcond

pmapcond:                                         ; preds = %pmapbody, %aftermap
  %i2 = load i32, ptr %pmap_i, align 4
  %pmapcmp = icmp slt i32 %i2, 4
  br i1 %pmapcmp, label %pmapbody, label %afterpmap

pmapbody:                                         ; preds = %pmapcond
  %idx3 = load i32, ptr %pmap_i, align 4
  %elemptr4 = getelementptr i32, ptr %pmap_arr_decay, i32 %idx3
  %elem5 = load i32, ptr %elemptr4, align 4
  store i32 %elem5, ptr %x_ptr1, align 4
  %x.load6 = load i32, ptr %x_ptr1, align 4
  %multmp = mul i32 %x.load6, 2
  %resultptr7 = getelementptr i32, ptr %pmapresult, i32 %idx3
  store i32 %multmp, ptr %resultptr7, align 4
  %next_i8 = add i32 %idx3, 1
  store i32 %next_i8, ptr %pmap_i, align 4
  br label %pmapcond

afterpmap:                                        ; preds = %pmapcond
  %filter_arr_decay = getelementptr inbounds [4 x i32], ptr %arrlit, i32 0, i32 0
  %filterresult = alloca i32, i32 4, align 4
  %filter_init_ptr = getelementptr i32, ptr %filterresult, i32 0
  store i32 0, ptr %filter_init_ptr, align 4
  %filter_init_ptr9 = getelementptr i32, ptr %filterresult, i32 1
  store i32 0, ptr %filter_init_ptr9, align 4
  %filter_init_ptr10 = getelementptr i32, ptr %filterresult, i32 2
  store i32 0, ptr %filter_init_ptr10, align 4
  %filter_init_ptr11 = getelementptr i32, ptr %filterresult, i32 3
  store i32 0, ptr %filter_init_ptr11, align 4
  %filter_count = alloca i32, align 4
  store i32 0, ptr %filter_count, align 4
  %filter_i = alloca i32, align 4
  store i32 0, ptr %filter_i, align 4
  %x_ptr12 = alloca i32, align 4
  br label %filtercond

filtercond:                                       ; preds = %filternext, %afterpmap
  %i13 = load i32, ptr %filter_i, align 4
  %filtercmp = icmp slt i32 %i13, 4
  br i1 %filtercmp, label %filterbody, label %afterfilter

filterbody:                                       ; preds = %filtercond
  %idx14 = load i32, ptr %filter_i, align 4
  %elemptr15 = getelementptr i32, ptr %filter_arr_decay, i32 %idx14
  %elem16 = load i32, ptr %elemptr15, align 4
  store i32 %elem16, ptr %x_ptr12, align 4
  %x.load17 = load i32, ptr %x_ptr12, align 4
  %gttmp = icmp sgt i32 %x.load17, 2
  br i1 %gttmp, label %filterstore, label %filternext

filterstore:                                      ; preds = %filterbody
  %count = load i32, ptr %filter_count, align 4
  %resultptr18 = getelementptr i32, ptr %filterresult, i32 %count
  %elem_reload = load i32, ptr %x_ptr12, align 4
  store i32 %elem_reload, ptr %resultptr18, align 4
  %next_count = add i32 %count, 1
  store i32 %next_count, ptr %filter_count, align 4
  br label %filternext

filternext:                                       ; preds = %filterstore, %filterbody
  %idx_reload = load i32, ptr %filter_i, align 4
  %next_i19 = add i32 %idx_reload, 1
  store i32 %next_i19, ptr %filter_i, align 4
  br label %filtercond

afterfilter:                                      ; preds = %filtercond
  %filter_len = load i32, ptr %filter_count, align 4
  ret i32 0
}

declare void @csec_set_command_line_args(i32, ptr)

define internal i32 @__csec_jit_entry() {
entry:
  %user.main = call i32 @_main()
  ret i32 %user.main
}
