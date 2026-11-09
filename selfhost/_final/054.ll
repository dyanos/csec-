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
  %pmap_arr_decay = getelementptr inbounds [4 x i32], ptr %arrlit, i32 0, i32 0
  %pmapresult = alloca i32, i32 4, align 4
  br label %pmapcond

pmapcond:                                         ; preds = %pmapbody, %entry
  %pmap_i.0 = phi i32 [ 0, %entry ], [ %next_i, %pmapbody ]
  %pmapcmp = icmp slt i32 %pmap_i.0, 4
  br i1 %pmapcmp, label %pmapbody, label %afterpmap

pmapbody:                                         ; preds = %pmapcond
  %elemptr = getelementptr i32, ptr %pmap_arr_decay, i32 %pmap_i.0
  %elem = load i32, ptr %elemptr, align 4
  %addtmp = add i32 %elem, 10
  %resultptr = getelementptr i32, ptr %pmapresult, i32 %pmap_i.0
  store i32 %addtmp, ptr %resultptr, align 4
  %next_i = add i32 %pmap_i.0, 1
  br label %pmapcond

afterpmap:                                        ; preds = %pmapcond
  %pmap_arr_decay1 = getelementptr inbounds [4 x i32], ptr %arrlit, i32 0, i32 0
  %x_typecheck_ptr2 = alloca i32, align 4
  %pmap_i3 = alloca i32, align 4
  store i32 0, ptr %pmap_i3, align 4
  %x_ptr4 = alloca i32, align 4
  %pmapresult5 = alloca i32, i32 4, align 4
  br label %pmapcond6

pmapcond6:                                        ; preds = %pmapbody7, %afterpmap
  %i9 = load i32, ptr %pmap_i3, align 4
  %pmapcmp10 = icmp slt i32 %i9, 4
  br i1 %pmapcmp10, label %pmapbody7, label %afterpmap8

pmapbody7:                                        ; preds = %pmapcond6
  %idx11 = load i32, ptr %pmap_i3, align 4
  %elemptr12 = getelementptr i32, ptr %pmap_arr_decay1, i32 %idx11
  %elem13 = load i32, ptr %elemptr12, align 4
  store i32 %elem13, ptr %x_ptr4, align 4
  %x.load14 = load i32, ptr %x_ptr4, align 4
  %multmp = mul i32 %x.load14, 2
  %resultptr15 = getelementptr i32, ptr %pmapresult5, i32 %idx11
  store i32 %multmp, ptr %resultptr15, align 4
  %next_i16 = add i32 %idx11, 1
  store i32 %next_i16, ptr %pmap_i3, align 4
  br label %pmapcond6, !llvm.loop !0

afterpmap8:                                       ; preds = %pmapcond6
  %pmap_arr_decay17 = getelementptr inbounds [4 x i32], ptr %arrlit, i32 0, i32 0
  %x_typecheck_ptr18 = alloca i32, align 4
  %pmap_i19 = alloca i32, align 4
  store i32 0, ptr %pmap_i19, align 4
  %x_ptr20 = alloca i32, align 4
  %pmapresult21 = alloca i32, i32 4, align 4
  br label %pmapcond22

pmapcond22:                                       ; preds = %pmapbody23, %afterpmap8
  %i25 = load i32, ptr %pmap_i19, align 4
  %pmapcmp26 = icmp slt i32 %i25, 4
  br i1 %pmapcmp26, label %pmapbody23, label %afterpmap24

pmapbody23:                                       ; preds = %pmapcond22
  %idx27 = load i32, ptr %pmap_i19, align 4
  %elemptr28 = getelementptr i32, ptr %pmap_arr_decay17, i32 %idx27
  %elem29 = load i32, ptr %elemptr28, align 4
  store i32 %elem29, ptr %x_ptr20, align 4
  %x.load30 = load i32, ptr %x_ptr20, align 4
  %subtmp = sub i32 %x.load30, 1
  %resultptr31 = getelementptr i32, ptr %pmapresult21, i32 %idx27
  store i32 %subtmp, ptr %resultptr31, align 4
  %next_i32 = add i32 %idx27, 1
  store i32 %next_i32, ptr %pmap_i19, align 4
  br label %pmapcond22, !llvm.loop !3

afterpmap24:                                      ; preds = %pmapcond22
  %pmap_arr_decay33 = getelementptr inbounds [4 x i32], ptr %arrlit, i32 0, i32 0
  %x_typecheck_ptr34 = alloca i32, align 4
  %pmap_i35 = alloca i32, align 4
  store i32 0, ptr %pmap_i35, align 4
  %x_ptr36 = alloca i32, align 4
  %pmapresult37 = alloca i32, i32 4, align 4
  br label %pmapcond38

pmapcond38:                                       ; preds = %pmapbody39, %afterpmap24
  %i41 = load i32, ptr %pmap_i35, align 4
  %pmapcmp42 = icmp slt i32 %i41, 4
  br i1 %pmapcmp42, label %pmapbody39, label %afterpmap40

pmapbody39:                                       ; preds = %pmapcond38
  %idx43 = load i32, ptr %pmap_i35, align 4
  %elemptr44 = getelementptr i32, ptr %pmap_arr_decay33, i32 %idx43
  %elem45 = load i32, ptr %elemptr44, align 4
  store i32 %elem45, ptr %x_ptr36, align 4
  %x.load46 = load i32, ptr %x_ptr36, align 4
  %addtmp47 = add i32 %x.load46, 1
  %resultptr48 = getelementptr i32, ptr %pmapresult37, i32 %idx43
  store i32 %addtmp47, ptr %resultptr48, align 4
  %next_i49 = add i32 %idx43, 1
  store i32 %next_i49, ptr %pmap_i35, align 4
  br label %pmapcond38

afterpmap40:                                      ; preds = %pmapcond38
  ret i32 0
}

declare void @csec_set_command_line_args(i32, ptr)

define internal i32 @__csec_jit_entry() {
entry:
  %user.main = call i32 @_main()
  ret i32 %user.main
}

!0 = distinct !{!0, !1, !2}
!1 = !{!"llvm.loop.vectorize.enable", i1 true}
!2 = !{!"csec.pmap.backend.simd"}
!3 = distinct !{!3, !1, !4}
!4 = !{!"csec.pmap.backend.gpu"}
