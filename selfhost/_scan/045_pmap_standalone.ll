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
  %pmap_arr_decay = getelementptr inbounds [5 x i32], ptr %arrlit, i32 0, i32 0
  %pmapresult = alloca i32, i32 5, align 4
  br label %pmapcond

pmapcond:                                         ; preds = %pmapbody, %entry
  %pmap_i.0 = phi i32 [ 0, %entry ], [ %next_i, %pmapbody ]
  %pmapcmp = icmp slt i32 %pmap_i.0, 5
  br i1 %pmapcmp, label %pmapbody, label %afterpmap

pmapbody:                                         ; preds = %pmapcond
  %elemptr = getelementptr i32, ptr %pmap_arr_decay, i32 %pmap_i.0
  %elem = load i32, ptr %elemptr, align 4
  %addtmp = add i32 %elem, 1
  %resultptr = getelementptr i32, ptr %pmapresult, i32 %pmap_i.0
  store i32 %addtmp, ptr %resultptr, align 4
  %next_i = add i32 %pmap_i.0, 1
  br label %pmapcond

afterpmap:                                        ; preds = %pmapcond
  %pmap_arr_decay1 = getelementptr inbounds [5 x i32], ptr %arrlit, i32 0, i32 0
  %y_typecheck_ptr = alloca i32, align 4
  %pmap_i2 = alloca i32, align 4
  store i32 0, ptr %pmap_i2, align 4
  %y_ptr = alloca i32, align 4
  %pmapresult3 = alloca i32, i32 5, align 4
  br label %pmapcond4

pmapcond4:                                        ; preds = %pmapbody5, %afterpmap
  %i7 = load i32, ptr %pmap_i2, align 4
  %pmapcmp8 = icmp slt i32 %i7, 5
  br i1 %pmapcmp8, label %pmapbody5, label %afterpmap6

pmapbody5:                                        ; preds = %pmapcond4
  %idx9 = load i32, ptr %pmap_i2, align 4
  %elemptr10 = getelementptr i32, ptr %pmap_arr_decay1, i32 %idx9
  %elem11 = load i32, ptr %elemptr10, align 4
  store i32 %elem11, ptr %y_ptr, align 4
  %y.load = load i32, ptr %y_ptr, align 4
  %y.load12 = load i32, ptr %y_ptr, align 4
  %multmp = mul i32 %y.load, %y.load12
  %resultptr13 = getelementptr i32, ptr %pmapresult3, i32 %idx9
  store i32 %multmp, ptr %resultptr13, align 4
  %next_i14 = add i32 %idx9, 1
  store i32 %next_i14, ptr %pmap_i2, align 4
  br label %pmapcond4

afterpmap6:                                       ; preds = %pmapcond4
  %pmap_arr_decay15 = getelementptr inbounds [5 x i32], ptr %arrlit, i32 0, i32 0
  %z_typecheck_ptr = alloca i32, align 4
  %pmap_i16 = alloca i32, align 4
  store i32 0, ptr %pmap_i16, align 4
  %z_ptr = alloca i32, align 4
  %pmapresult17 = alloca i32, i32 5, align 4
  br label %pmapcond18

pmapcond18:                                       ; preds = %pmapbody19, %afterpmap6
  %i21 = load i32, ptr %pmap_i16, align 4
  %pmapcmp22 = icmp slt i32 %i21, 5
  br i1 %pmapcmp22, label %pmapbody19, label %afterpmap20

pmapbody19:                                       ; preds = %pmapcond18
  %idx23 = load i32, ptr %pmap_i16, align 4
  %elemptr24 = getelementptr i32, ptr %pmap_arr_decay15, i32 %idx23
  %elem25 = load i32, ptr %elemptr24, align 4
  store i32 %elem25, ptr %z_ptr, align 4
  %z.load = load i32, ptr %z_ptr, align 4
  %subtmp = sub i32 %z.load, 5
  %resultptr26 = getelementptr i32, ptr %pmapresult17, i32 %idx23
  store i32 %subtmp, ptr %resultptr26, align 4
  %next_i27 = add i32 %idx23, 1
  store i32 %next_i27, ptr %pmap_i16, align 4
  br label %pmapcond18

afterpmap20:                                      ; preds = %pmapcond18
  ret i32 0
}

declare void @csec_set_command_line_args(i32, ptr)

define internal i32 @__csec_jit_entry() {
entry:
  %user.main = call i32 @_main()
  ret i32 %user.main
}
