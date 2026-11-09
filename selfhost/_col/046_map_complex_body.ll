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

define i32 @_square(i32 %0) {
entry:
  %multmp = mul i32 %0, %0
  ret i32 %multmp
}

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
  %addtmp = add i32 %elem, %elem
  %doubled = alloca i32, align 4
  store i32 %addtmp, ptr %doubled, align 4
  %doubled.load = load i32, ptr %doubled, align 4
  %addtmp2 = add i32 %doubled.load, 1
  %incremented = alloca i32, align 4
  store i32 %addtmp2, ptr %incremented, align 4
  %incremented.load = load i32, ptr %incremented, align 4
  %resultptr = getelementptr i32, ptr %mapresult, i32 %map_i.0
  store i32 %incremented.load, ptr %resultptr, align 4
  %next_i = add i32 %map_i.0, 1
  br label %mapcond

aftermap:                                         ; preds = %mapcond
  %map_arr_decay3 = getelementptr inbounds [5 x i32], ptr %arrlit, i32 0, i32 0
  %map_i4 = alloca i32, align 4
  store i32 0, ptr %map_i4, align 4
  %y_ptr = alloca i32, align 4
  %mapresult5 = alloca i32, i32 5, align 4
  br label %mapcond6

mapcond6:                                         ; preds = %ifcont, %aftermap
  %i9 = load i32, ptr %map_i4, align 4
  %mapcmp10 = icmp slt i32 %i9, 5
  br i1 %mapcmp10, label %mapbody7, label %aftermap8

mapbody7:                                         ; preds = %mapcond6
  %idx11 = load i32, ptr %map_i4, align 4
  %elemptr12 = getelementptr i32, ptr %map_arr_decay3, i32 %idx11
  %elem13 = load i32, ptr %elemptr12, align 4
  store i32 %elem13, ptr %y_ptr, align 4
  %y.load = load i32, ptr %y_ptr, align 4
  %gttmp = icmp sgt i32 %y.load, 3
  br i1 %gttmp, label %then, label %else

aftermap8:                                        ; preds = %mapcond6
  ret i32 0

then:                                             ; preds = %mapbody7
  %y.load14 = load i32, ptr %y_ptr, align 4
  %multmp = mul i32 %y.load14, 10
  br label %ifcont

else:                                             ; preds = %mapbody7
  %y.load15 = load i32, ptr %y_ptr, align 4
  br label %ifcont

ifcont:                                           ; preds = %else, %then
  %result = phi i32 [ %multmp, %then ], [ %y.load15, %else ]
  %resultptr16 = getelementptr i32, ptr %mapresult5, i32 %idx11
  store i32 %result, ptr %resultptr16, align 4
  %next_i17 = add i32 %idx11, 1
  store i32 %next_i17, ptr %map_i4, align 4
  br label %mapcond6
}

declare void @csec_set_command_line_args(i32, ptr)

define internal i32 @__csec_jit_entry() {
entry:
  %user.main = call i32 @_main()
  ret i32 %user.main
}
