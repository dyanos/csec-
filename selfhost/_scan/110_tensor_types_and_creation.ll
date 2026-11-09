; ModuleID = 'main'
source_filename = "main"

%csec.tensor = type { i64, ptr, i64, ptr }

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
  %tensor.malloc = call ptr @malloc(i64 32)
  %tensor.malloc1 = call ptr @malloc(i64 8)
  %tensor.malloc2 = call ptr @malloc(i64 24)
  %tensor.rank.slot = getelementptr inbounds %csec.tensor, ptr %tensor.malloc, i32 0, i32 0
  store i64 1, ptr %tensor.rank.slot, align 4
  %tensor.dims.slot = getelementptr inbounds %csec.tensor, ptr %tensor.malloc, i32 0, i32 1
  store ptr %tensor.malloc1, ptr %tensor.dims.slot, align 8
  %tensor.count.slot = getelementptr inbounds %csec.tensor, ptr %tensor.malloc, i32 0, i32 2
  store i64 3, ptr %tensor.count.slot, align 4
  %tensor.data.slot = getelementptr inbounds %csec.tensor, ptr %tensor.malloc, i32 0, i32 3
  store ptr %tensor.malloc2, ptr %tensor.data.slot, align 8
  %tensor.dims.ptr = getelementptr inbounds %csec.tensor, ptr %tensor.malloc, i32 0, i32 1
  %tensor.dims = load ptr, ptr %tensor.dims.ptr, align 8
  %tensor.data.ptr = getelementptr inbounds %csec.tensor, ptr %tensor.malloc, i32 0, i32 3
  %tensor.data = load ptr, ptr %tensor.data.ptr, align 8
  %tensor.dim.slot = getelementptr i64, ptr %tensor.dims, i64 0
  store i64 3, ptr %tensor.dim.slot, align 4
  br label %tensor.fill.cond

tensor.fill.cond:                                 ; preds = %tensor.fill.body, %entry
  %tensor.fill.i.0 = phi i64 [ 0, %entry ], [ %tensor.fill.next, %tensor.fill.body ]
  %tensor.fill.keep = icmp ult i64 %tensor.fill.i.0, 3
  br i1 %tensor.fill.keep, label %tensor.fill.body, label %tensor.fill.end

tensor.fill.body:                                 ; preds = %tensor.fill.cond
  %tensor.data.slot3 = getelementptr double, ptr %tensor.data, i64 %tensor.fill.i.0
  store double 0.000000e+00, ptr %tensor.data.slot3, align 8
  %tensor.fill.next = add i64 %tensor.fill.i.0, 1
  br label %tensor.fill.cond

tensor.fill.end:                                  ; preds = %tensor.fill.cond
  %tensor.malloc4 = call ptr @malloc(i64 32)
  %tensor.malloc5 = call ptr @malloc(i64 16)
  %tensor.malloc6 = call ptr @malloc(i64 48)
  %tensor.rank.slot7 = getelementptr inbounds %csec.tensor, ptr %tensor.malloc4, i32 0, i32 0
  store i64 2, ptr %tensor.rank.slot7, align 4
  %tensor.dims.slot8 = getelementptr inbounds %csec.tensor, ptr %tensor.malloc4, i32 0, i32 1
  store ptr %tensor.malloc5, ptr %tensor.dims.slot8, align 8
  %tensor.count.slot9 = getelementptr inbounds %csec.tensor, ptr %tensor.malloc4, i32 0, i32 2
  store i64 6, ptr %tensor.count.slot9, align 4
  %tensor.data.slot10 = getelementptr inbounds %csec.tensor, ptr %tensor.malloc4, i32 0, i32 3
  store ptr %tensor.malloc6, ptr %tensor.data.slot10, align 8
  %tensor.dims.ptr11 = getelementptr inbounds %csec.tensor, ptr %tensor.malloc4, i32 0, i32 1
  %tensor.dims12 = load ptr, ptr %tensor.dims.ptr11, align 8
  %tensor.data.ptr13 = getelementptr inbounds %csec.tensor, ptr %tensor.malloc4, i32 0, i32 3
  %tensor.data14 = load ptr, ptr %tensor.data.ptr13, align 8
  %tensor.dim.slot15 = getelementptr i64, ptr %tensor.dims12, i64 0
  store i64 2, ptr %tensor.dim.slot15, align 4
  %tensor.dim.slot16 = getelementptr i64, ptr %tensor.dims12, i64 1
  store i64 3, ptr %tensor.dim.slot16, align 4
  %tensor.fill.i17 = alloca i64, align 8
  store i64 0, ptr %tensor.fill.i17, align 4
  br label %tensor.fill.cond18

tensor.fill.cond18:                               ; preds = %tensor.fill.body19, %tensor.fill.end
  %tensor.fill.idx21 = load i64, ptr %tensor.fill.i17, align 4
  %tensor.fill.keep22 = icmp ult i64 %tensor.fill.idx21, 6
  br i1 %tensor.fill.keep22, label %tensor.fill.body19, label %tensor.fill.end20

tensor.fill.body19:                               ; preds = %tensor.fill.cond18
  %tensor.data.slot23 = getelementptr double, ptr %tensor.data14, i64 %tensor.fill.idx21
  store double 0.000000e+00, ptr %tensor.data.slot23, align 8
  %tensor.fill.current24 = load i64, ptr %tensor.fill.i17, align 4
  %tensor.fill.next25 = add i64 %tensor.fill.current24, 1
  store i64 %tensor.fill.next25, ptr %tensor.fill.i17, align 4
  br label %tensor.fill.cond18

tensor.fill.end20:                                ; preds = %tensor.fill.cond18
  %tensor.malloc26 = call ptr @malloc(i64 32)
  %tensor.malloc27 = call ptr @malloc(i64 24)
  %tensor.malloc28 = call ptr @malloc(i64 64)
  %tensor.rank.slot29 = getelementptr inbounds %csec.tensor, ptr %tensor.malloc26, i32 0, i32 0
  store i64 3, ptr %tensor.rank.slot29, align 4
  %tensor.dims.slot30 = getelementptr inbounds %csec.tensor, ptr %tensor.malloc26, i32 0, i32 1
  store ptr %tensor.malloc27, ptr %tensor.dims.slot30, align 8
  %tensor.count.slot31 = getelementptr inbounds %csec.tensor, ptr %tensor.malloc26, i32 0, i32 2
  store i64 8, ptr %tensor.count.slot31, align 4
  %tensor.data.slot32 = getelementptr inbounds %csec.tensor, ptr %tensor.malloc26, i32 0, i32 3
  store ptr %tensor.malloc28, ptr %tensor.data.slot32, align 8
  %tensor.dims.ptr33 = getelementptr inbounds %csec.tensor, ptr %tensor.malloc26, i32 0, i32 1
  %tensor.dims34 = load ptr, ptr %tensor.dims.ptr33, align 8
  %tensor.data.ptr35 = getelementptr inbounds %csec.tensor, ptr %tensor.malloc26, i32 0, i32 3
  %tensor.data36 = load ptr, ptr %tensor.data.ptr35, align 8
  %tensor.dim.slot37 = getelementptr i64, ptr %tensor.dims34, i64 0
  store i64 2, ptr %tensor.dim.slot37, align 4
  %tensor.dim.slot38 = getelementptr i64, ptr %tensor.dims34, i64 1
  store i64 2, ptr %tensor.dim.slot38, align 4
  %tensor.dim.slot39 = getelementptr i64, ptr %tensor.dims34, i64 2
  store i64 2, ptr %tensor.dim.slot39, align 4
  %tensor.fill.i40 = alloca i64, align 8
  store i64 0, ptr %tensor.fill.i40, align 4
  br label %tensor.fill.cond41

tensor.fill.cond41:                               ; preds = %tensor.fill.body42, %tensor.fill.end20
  %tensor.fill.idx44 = load i64, ptr %tensor.fill.i40, align 4
  %tensor.fill.keep45 = icmp ult i64 %tensor.fill.idx44, 8
  br i1 %tensor.fill.keep45, label %tensor.fill.body42, label %tensor.fill.end43

tensor.fill.body42:                               ; preds = %tensor.fill.cond41
  %tensor.data.slot46 = getelementptr double, ptr %tensor.data36, i64 %tensor.fill.idx44
  store double 0.000000e+00, ptr %tensor.data.slot46, align 8
  %tensor.fill.current47 = load i64, ptr %tensor.fill.i40, align 4
  %tensor.fill.next48 = add i64 %tensor.fill.current47, 1
  store i64 %tensor.fill.next48, ptr %tensor.fill.i40, align 4
  br label %tensor.fill.cond41

tensor.fill.end43:                                ; preds = %tensor.fill.cond41
  ret i32 0
}

declare void @csec_set_command_line_args(i32, ptr)

define internal i32 @__csec_jit_entry() {
entry:
  %user.main = call i32 @_main()
  ret i32 %user.main
}
