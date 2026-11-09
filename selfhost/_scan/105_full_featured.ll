; ModuleID = 'main'
source_filename = "main"

@0 = private unnamed_addr constant [5 x i8] c"test\00", align 1

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

declare void @puts(ptr)

define i32 @_main() {
entry:
  %subtmp = sub i32 90, 5
  %modtmp = srem i32 %subtmp, 7
  br label %forcond

forcond:                                          ; preds = %loop, %entry
  %counter.0 = phi i32 [ 0, %entry ], [ %addtmp, %loop ]
  %i_ptr.0 = phi i32 [ 0, %entry ], [ %next_i, %loop ]
  %cond = icmp sle i32 %i_ptr.0, 10
  br i1 %cond, label %loop, label %afterloop

loop:                                             ; preds = %forcond
  %addtmp = add i32 %counter.0, %i_ptr.0
  %next_i = add i32 %i_ptr.0, 1
  br label %forcond

afterloop:                                        ; preds = %forcond
  br label %whilecond

whilecond:                                        ; preds = %whilebody, %afterloop
  %counter.1 = phi i32 [ %counter.0, %afterloop ], [ %subtmp9, %whilebody ]
  %gttmp = icmp sgt i32 %counter.1, 50
  br i1 %gttmp, label %whilebody, label %afterwhile

whilebody:                                        ; preds = %whilecond
  %subtmp9 = sub i32 %counter.1, 1
  br label %whilecond

afterwhile:                                       ; preds = %whilecond
  br i1 true, label %then, label %else

then:                                             ; preds = %afterwhile
  %addtmp12 = add i32 %counter.1, 1
  br label %ifcont

else:                                             ; preds = %afterwhile
  %subtmp15 = sub i32 %counter.1, 1
  br label %ifcont

ifcont:                                           ; preds = %else, %then
  %counter.2 = phi i32 [ %addtmp12, %then ], [ %subtmp15, %else ]
  %result = phi i32 [ %addtmp12, %then ], [ %subtmp15, %else ]
  %match.cond = icmp eq i32 %counter.2, 0
  br i1 %match.cond, label %match.case, label %match.next

match.end:                                        ; preds = %match.case20, %match.case17, %match.case
  %match.result = phi i32 [ 100, %match.case ], [ 90, %match.case17 ], [ 50, %match.case20 ]
  %grade = alloca i32, align 4
  store i32 %match.result, ptr %grade, align 4
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
  %map_arr_decay = getelementptr inbounds [5 x i32], ptr %arrlit, i32 0, i32 0
  %map_i = alloca i32, align 4
  store i32 0, ptr %map_i, align 4
  %x_ptr = alloca i32, align 4
  %mapresult = alloca i32, i32 5, align 4
  br label %mapcond

match.case:                                       ; preds = %ifcont
  br label %match.end

match.next:                                       ; preds = %ifcont
  %match.cond19 = icmp eq i32 %counter.2, 1
  br i1 %match.cond19, label %match.case17, label %match.next18

match.case17:                                     ; preds = %match.next
  br label %match.end

match.next18:                                     ; preds = %match.next
  br label %match.case20

match.case20:                                     ; preds = %match.next18
  br label %match.end

mapcond:                                          ; preds = %mapbody, %match.end
  %i21 = load i32, ptr %map_i, align 4
  %mapcmp = icmp slt i32 %i21, 5
  br i1 %mapcmp, label %mapbody, label %aftermap

mapbody:                                          ; preds = %mapcond
  %idx = load i32, ptr %map_i, align 4
  %elemptr = getelementptr i32, ptr %map_arr_decay, i32 %idx
  %elem = load i32, ptr %elemptr, align 4
  store i32 %elem, ptr %x_ptr, align 4
  %x.load = load i32, ptr %x_ptr, align 4
  %multmp = mul i32 %x.load, 2
  %resultptr = getelementptr i32, ptr %mapresult, i32 %idx
  store i32 %multmp, ptr %resultptr, align 4
  %next_i22 = add i32 %idx, 1
  store i32 %next_i22, ptr %map_i, align 4
  br label %mapcond

aftermap:                                         ; preds = %mapcond
  %filter_arr_decay = getelementptr inbounds [5 x i32], ptr %arrlit, i32 0, i32 0
  %filterresult = alloca i32, i32 5, align 4
  %filter_init_ptr = getelementptr i32, ptr %filterresult, i32 0
  store i32 0, ptr %filter_init_ptr, align 4
  %filter_init_ptr23 = getelementptr i32, ptr %filterresult, i32 1
  store i32 0, ptr %filter_init_ptr23, align 4
  %filter_init_ptr24 = getelementptr i32, ptr %filterresult, i32 2
  store i32 0, ptr %filter_init_ptr24, align 4
  %filter_init_ptr25 = getelementptr i32, ptr %filterresult, i32 3
  store i32 0, ptr %filter_init_ptr25, align 4
  %filter_init_ptr26 = getelementptr i32, ptr %filterresult, i32 4
  store i32 0, ptr %filter_init_ptr26, align 4
  %filter_count = alloca i32, align 4
  store i32 0, ptr %filter_count, align 4
  %filter_i = alloca i32, align 4
  store i32 0, ptr %filter_i, align 4
  %x_ptr27 = alloca i32, align 4
  br label %filtercond

filtercond:                                       ; preds = %filternext, %aftermap
  %i28 = load i32, ptr %filter_i, align 4
  %filtercmp = icmp slt i32 %i28, 5
  br i1 %filtercmp, label %filterbody, label %afterfilter

filterbody:                                       ; preds = %filtercond
  %idx29 = load i32, ptr %filter_i, align 4
  %elemptr30 = getelementptr i32, ptr %filter_arr_decay, i32 %idx29
  %elem31 = load i32, ptr %elemptr30, align 4
  store i32 %elem31, ptr %x_ptr27, align 4
  %x.load32 = load i32, ptr %x_ptr27, align 4
  %gttmp33 = icmp sgt i32 %x.load32, 2
  br i1 %gttmp33, label %filterstore, label %filternext

filterstore:                                      ; preds = %filterbody
  %count = load i32, ptr %filter_count, align 4
  %resultptr34 = getelementptr i32, ptr %filterresult, i32 %count
  %elem_reload = load i32, ptr %x_ptr27, align 4
  store i32 %elem_reload, ptr %resultptr34, align 4
  %next_count = add i32 %count, 1
  store i32 %next_count, ptr %filter_count, align 4
  br label %filternext

filternext:                                       ; preds = %filterstore, %filterbody
  %idx_reload = load i32, ptr %filter_i, align 4
  %next_i35 = add i32 %idx_reload, 1
  store i32 %next_i35, ptr %filter_i, align 4
  br label %filtercond

afterfilter:                                      ; preds = %filtercond
  %filter_len = load i32, ptr %filter_count, align 4
  %reduce_arr_decay = getelementptr inbounds [5 x i32], ptr %arrlit, i32 0, i32 0
  %acc = alloca i32, align 4
  store i32 0, ptr %acc, align 4
  %reduce_i = alloca i32, align 4
  store i32 0, ptr %reduce_i, align 4
  %x_ptr36 = alloca i32, align 4
  br label %reducecond

reducecond:                                       ; preds = %reducebody, %afterfilter
  %i37 = load i32, ptr %reduce_i, align 4
  %reducecmp = icmp slt i32 %i37, 5
  br i1 %reducecmp, label %reducebody, label %afterreduce

reducebody:                                       ; preds = %reducecond
  %idx38 = load i32, ptr %reduce_i, align 4
  %elemptr39 = getelementptr i32, ptr %reduce_arr_decay, i32 %idx38
  %elem40 = load i32, ptr %elemptr39, align 4
  store i32 %elem40, ptr %x_ptr36, align 4
  %x.load41 = load i32, ptr %x_ptr36, align 4
  %addtmp42 = add i32 %x.load41, 1
  store i32 %addtmp42, ptr %acc, align 4
  %next_i43 = add i32 %idx38, 1
  store i32 %next_i43, ptr %reduce_i, align 4
  br label %reducecond

afterreduce:                                      ; preds = %reducecond
  %reduceval = load i32, ptr %acc, align 4
  %lambda.env = alloca {}, align 8
  %lambda.closure = alloca { ptr, ptr }, align 8
  %closure.code = getelementptr inbounds { ptr, ptr }, ptr %lambda.closure, i32 0, i32 0
  store ptr @__lambda_0, ptr %closure.code, align 8
  %closure.env = getelementptr inbounds { ptr, ptr }, ptr %lambda.closure, i32 0, i32 1
  store ptr %lambda.env, ptr %closure.env, align 8
  %grade.load = load i32, ptr %grade, align 4
  %addtmp45 = add i32 %counter.2, %grade.load
  ret i32 %addtmp45
}

define internal i32 @__lambda_0(ptr %0, i32 %1) {
entry:
  %addtmp = add i32 %1, 1
  ret i32 %addtmp
}

declare void @csec_set_command_line_args(i32, ptr)

define internal i32 @__csec_jit_entry() {
entry:
  %user.main = call i32 @_main()
  ret i32 %user.main
}
