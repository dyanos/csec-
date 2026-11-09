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

define ptr @_linear(ptr %0, ptr %1, ptr %2) {
entry:
  %tensor.dims.ptr = getelementptr inbounds %csec.tensor, ptr %0, i32 0, i32 1
  %tensor.dims = load ptr, ptr %tensor.dims.ptr, align 8
  %tensor.dims.ptr1 = getelementptr inbounds %csec.tensor, ptr %1, i32 0, i32 1
  %tensor.dims2 = load ptr, ptr %tensor.dims.ptr1, align 8
  %tensor.matmul.rows.ptr = getelementptr i64, ptr %tensor.dims, i64 0
  %tensor.matmul.rows = load i64, ptr %tensor.matmul.rows.ptr, align 4
  %tensor.matmul.shared.ptr = getelementptr i64, ptr %tensor.dims, i64 1
  %tensor.matmul.shared = load i64, ptr %tensor.matmul.shared.ptr, align 4
  %tensor.matmul.cols.ptr = getelementptr i64, ptr %tensor.dims2, i64 1
  %tensor.matmul.cols = load i64, ptr %tensor.matmul.cols.ptr, align 4
  %tensor.matmul.count = mul i64 %tensor.matmul.rows, %tensor.matmul.cols
  %tensor.malloc = call ptr @malloc(i64 32)
  %tensor.malloc3 = call ptr @malloc(i64 16)
  %tensor.data.bytes = mul i64 %tensor.matmul.count, 8
  %tensor.malloc4 = call ptr @malloc(i64 %tensor.data.bytes)
  %tensor.rank.slot = getelementptr inbounds %csec.tensor, ptr %tensor.malloc, i32 0, i32 0
  store i64 2, ptr %tensor.rank.slot, align 4
  %tensor.dims.slot = getelementptr inbounds %csec.tensor, ptr %tensor.malloc, i32 0, i32 1
  store ptr %tensor.malloc3, ptr %tensor.dims.slot, align 8
  %tensor.count.slot = getelementptr inbounds %csec.tensor, ptr %tensor.malloc, i32 0, i32 2
  store i64 %tensor.matmul.count, ptr %tensor.count.slot, align 4
  %tensor.data.slot = getelementptr inbounds %csec.tensor, ptr %tensor.malloc, i32 0, i32 3
  store ptr %tensor.malloc4, ptr %tensor.data.slot, align 8
  %tensor.dims.ptr5 = getelementptr inbounds %csec.tensor, ptr %tensor.malloc, i32 0, i32 1
  %tensor.dims6 = load ptr, ptr %tensor.dims.ptr5, align 8
  %tensor.matmul.dst.rows = getelementptr i64, ptr %tensor.dims6, i64 0
  store i64 %tensor.matmul.rows, ptr %tensor.matmul.dst.rows, align 4
  %tensor.matmul.dst.cols = getelementptr i64, ptr %tensor.dims6, i64 1
  store i64 %tensor.matmul.cols, ptr %tensor.matmul.dst.cols, align 4
  %tensor.data.ptr = getelementptr inbounds %csec.tensor, ptr %0, i32 0, i32 3
  %tensor.data = load ptr, ptr %tensor.data.ptr, align 8
  %tensor.data.ptr7 = getelementptr inbounds %csec.tensor, ptr %1, i32 0, i32 3
  %tensor.data8 = load ptr, ptr %tensor.data.ptr7, align 8
  %tensor.data.ptr9 = getelementptr inbounds %csec.tensor, ptr %tensor.malloc, i32 0, i32 3
  %tensor.data10 = load ptr, ptr %tensor.data.ptr9, align 8
  br label %tensor.matmul.i.cond

tensor.matmul.i.cond:                             ; preds = %tensor.matmul.j.end, %entry
  %tensor.matmul.i.i.0 = phi i64 [ 0, %entry ], [ %tensor.matmul.i.next, %tensor.matmul.j.end ]
  %tensor.matmul.i.keep = icmp ult i64 %tensor.matmul.i.i.0, %tensor.matmul.rows
  br i1 %tensor.matmul.i.keep, label %tensor.matmul.i.body, label %tensor.matmul.i.end

tensor.matmul.i.body:                             ; preds = %tensor.matmul.i.cond
  %tensor.matmul.j.i = alloca i64, align 8
  store i64 0, ptr %tensor.matmul.j.i, align 4
  br label %tensor.matmul.j.cond

tensor.matmul.i.end:                              ; preds = %tensor.matmul.i.cond
  %str.concat = call ptr @csec_string_concat(ptr null, ptr null)
  ret ptr %str.concat

tensor.matmul.j.cond:                             ; preds = %tensor.matmul.k.end, %tensor.matmul.i.body
  %tensor.matmul.j.idx = load i64, ptr %tensor.matmul.j.i, align 4
  %tensor.matmul.j.keep = icmp ult i64 %tensor.matmul.j.idx, %tensor.matmul.cols
  br i1 %tensor.matmul.j.keep, label %tensor.matmul.j.body, label %tensor.matmul.j.end

tensor.matmul.j.body:                             ; preds = %tensor.matmul.j.cond
  %tensor.matmul.sum.ptr = alloca double, align 8
  store double 0.000000e+00, ptr %tensor.matmul.sum.ptr, align 8
  %tensor.matmul.k.i = alloca i64, align 8
  store i64 0, ptr %tensor.matmul.k.i, align 4
  br label %tensor.matmul.k.cond

tensor.matmul.j.end:                              ; preds = %tensor.matmul.j.cond
  %tensor.matmul.i.next = add i64 %tensor.matmul.i.i.0, 1
  br label %tensor.matmul.i.cond

tensor.matmul.k.cond:                             ; preds = %tensor.matmul.k.body, %tensor.matmul.j.body
  %tensor.matmul.k.idx = load i64, ptr %tensor.matmul.k.i, align 4
  %tensor.matmul.k.keep = icmp ult i64 %tensor.matmul.k.idx, %tensor.matmul.shared
  br i1 %tensor.matmul.k.keep, label %tensor.matmul.k.body, label %tensor.matmul.k.end

tensor.matmul.k.body:                             ; preds = %tensor.matmul.k.cond
  %3 = mul i64 %tensor.matmul.i.i.0, %tensor.matmul.shared
  %tensor.matmul.left.index = add i64 %3, %tensor.matmul.k.idx
  %4 = mul i64 %tensor.matmul.k.idx, %tensor.matmul.cols
  %tensor.matmul.right.index = add i64 %4, %tensor.matmul.j.idx
  %5 = getelementptr double, ptr %tensor.data8, i64 %tensor.matmul.right.index
  %tensor.matmul.right = load double, ptr %5, align 8
  %6 = getelementptr double, ptr %tensor.data, i64 %tensor.matmul.left.index
  %tensor.matmul.left = load double, ptr %6, align 8
  %tensor.matmul.product = fmul double %tensor.matmul.left, %tensor.matmul.right
  %tensor.matmul.current = load double, ptr %tensor.matmul.sum.ptr, align 8
  %tensor.matmul.next = fadd double %tensor.matmul.current, %tensor.matmul.product
  store double %tensor.matmul.next, ptr %tensor.matmul.sum.ptr, align 8
  %tensor.matmul.k.current = load i64, ptr %tensor.matmul.k.i, align 4
  %tensor.matmul.k.next = add i64 %tensor.matmul.k.current, 1
  store i64 %tensor.matmul.k.next, ptr %tensor.matmul.k.i, align 4
  br label %tensor.matmul.k.cond

tensor.matmul.k.end:                              ; preds = %tensor.matmul.k.cond
  %7 = mul i64 %tensor.matmul.i.i.0, %tensor.matmul.cols
  %tensor.matmul.dst.index = add i64 %7, %tensor.matmul.j.idx
  %tensor.matmul.dst = getelementptr double, ptr %tensor.data10, i64 %tensor.matmul.dst.index
  %tensor.matmul.sum = load double, ptr %tensor.matmul.sum.ptr, align 8
  store double %tensor.matmul.sum, ptr %tensor.matmul.dst, align 8
  %tensor.matmul.j.current = load i64, ptr %tensor.matmul.j.i, align 4
  %tensor.matmul.j.next = add i64 %tensor.matmul.j.current, 1
  store i64 %tensor.matmul.j.next, ptr %tensor.matmul.j.i, align 4
  br label %tensor.matmul.j.cond
}

define ptr @_feedForward(ptr %0, ptr %1, ptr %2, ptr %3, ptr %4) {
entry:
  %tensor.dims.ptr = getelementptr inbounds %csec.tensor, ptr %0, i32 0, i32 1
  %tensor.dims = load ptr, ptr %tensor.dims.ptr, align 8
  %tensor.dims.ptr1 = getelementptr inbounds %csec.tensor, ptr %1, i32 0, i32 1
  %tensor.dims2 = load ptr, ptr %tensor.dims.ptr1, align 8
  %tensor.matmul.rows.ptr = getelementptr i64, ptr %tensor.dims, i64 0
  %tensor.matmul.rows = load i64, ptr %tensor.matmul.rows.ptr, align 4
  %tensor.matmul.shared.ptr = getelementptr i64, ptr %tensor.dims, i64 1
  %tensor.matmul.shared = load i64, ptr %tensor.matmul.shared.ptr, align 4
  %tensor.matmul.cols.ptr = getelementptr i64, ptr %tensor.dims2, i64 1
  %tensor.matmul.cols = load i64, ptr %tensor.matmul.cols.ptr, align 4
  %tensor.matmul.count = mul i64 %tensor.matmul.rows, %tensor.matmul.cols
  %tensor.malloc = call ptr @malloc(i64 32)
  %tensor.malloc3 = call ptr @malloc(i64 16)
  %tensor.data.bytes = mul i64 %tensor.matmul.count, 8
  %tensor.malloc4 = call ptr @malloc(i64 %tensor.data.bytes)
  %tensor.rank.slot = getelementptr inbounds %csec.tensor, ptr %tensor.malloc, i32 0, i32 0
  store i64 2, ptr %tensor.rank.slot, align 4
  %tensor.dims.slot = getelementptr inbounds %csec.tensor, ptr %tensor.malloc, i32 0, i32 1
  store ptr %tensor.malloc3, ptr %tensor.dims.slot, align 8
  %tensor.count.slot = getelementptr inbounds %csec.tensor, ptr %tensor.malloc, i32 0, i32 2
  store i64 %tensor.matmul.count, ptr %tensor.count.slot, align 4
  %tensor.data.slot = getelementptr inbounds %csec.tensor, ptr %tensor.malloc, i32 0, i32 3
  store ptr %tensor.malloc4, ptr %tensor.data.slot, align 8
  %tensor.dims.ptr5 = getelementptr inbounds %csec.tensor, ptr %tensor.malloc, i32 0, i32 1
  %tensor.dims6 = load ptr, ptr %tensor.dims.ptr5, align 8
  %tensor.matmul.dst.rows = getelementptr i64, ptr %tensor.dims6, i64 0
  store i64 %tensor.matmul.rows, ptr %tensor.matmul.dst.rows, align 4
  %tensor.matmul.dst.cols = getelementptr i64, ptr %tensor.dims6, i64 1
  store i64 %tensor.matmul.cols, ptr %tensor.matmul.dst.cols, align 4
  %tensor.data.ptr = getelementptr inbounds %csec.tensor, ptr %0, i32 0, i32 3
  %tensor.data = load ptr, ptr %tensor.data.ptr, align 8
  %tensor.data.ptr7 = getelementptr inbounds %csec.tensor, ptr %1, i32 0, i32 3
  %tensor.data8 = load ptr, ptr %tensor.data.ptr7, align 8
  %tensor.data.ptr9 = getelementptr inbounds %csec.tensor, ptr %tensor.malloc, i32 0, i32 3
  %tensor.data10 = load ptr, ptr %tensor.data.ptr9, align 8
  br label %tensor.matmul.i.cond

tensor.matmul.i.cond:                             ; preds = %tensor.matmul.j.end, %entry
  %tensor.matmul.i.i.0 = phi i64 [ 0, %entry ], [ %tensor.matmul.i.next, %tensor.matmul.j.end ]
  %tensor.matmul.i.keep = icmp ult i64 %tensor.matmul.i.i.0, %tensor.matmul.rows
  br i1 %tensor.matmul.i.keep, label %tensor.matmul.i.body, label %tensor.matmul.i.end

tensor.matmul.i.body:                             ; preds = %tensor.matmul.i.cond
  %tensor.matmul.j.i = alloca i64, align 8
  store i64 0, ptr %tensor.matmul.j.i, align 4
  br label %tensor.matmul.j.cond

tensor.matmul.i.end:                              ; preds = %tensor.matmul.i.cond
  %str.concat = call ptr @csec_string_concat(ptr null, ptr null)
  %hidden = alloca ptr, align 8
  store ptr %str.concat, ptr %hidden, align 8
  %hidden.load = load ptr, ptr %hidden, align 8
  %tensor.dims.ptr11 = getelementptr inbounds %csec.tensor, ptr %hidden.load, i32 0, i32 1
  %tensor.dims12 = load ptr, ptr %tensor.dims.ptr11, align 8
  %tensor.dims.ptr13 = getelementptr inbounds %csec.tensor, ptr %3, i32 0, i32 1
  %tensor.dims14 = load ptr, ptr %tensor.dims.ptr13, align 8
  %tensor.matmul.rows.ptr15 = getelementptr i64, ptr %tensor.dims12, i64 0
  %tensor.matmul.rows16 = load i64, ptr %tensor.matmul.rows.ptr15, align 4
  %tensor.matmul.shared.ptr17 = getelementptr i64, ptr %tensor.dims12, i64 1
  %tensor.matmul.shared18 = load i64, ptr %tensor.matmul.shared.ptr17, align 4
  %tensor.matmul.cols.ptr19 = getelementptr i64, ptr %tensor.dims14, i64 1
  %tensor.matmul.cols20 = load i64, ptr %tensor.matmul.cols.ptr19, align 4
  %tensor.matmul.count21 = mul i64 %tensor.matmul.rows16, %tensor.matmul.cols20
  %tensor.malloc22 = call ptr @malloc(i64 32)
  %tensor.malloc23 = call ptr @malloc(i64 16)
  %tensor.data.bytes24 = mul i64 %tensor.matmul.count21, 8
  %tensor.malloc25 = call ptr @malloc(i64 %tensor.data.bytes24)
  %tensor.rank.slot26 = getelementptr inbounds %csec.tensor, ptr %tensor.malloc22, i32 0, i32 0
  store i64 2, ptr %tensor.rank.slot26, align 4
  %tensor.dims.slot27 = getelementptr inbounds %csec.tensor, ptr %tensor.malloc22, i32 0, i32 1
  store ptr %tensor.malloc23, ptr %tensor.dims.slot27, align 8
  %tensor.count.slot28 = getelementptr inbounds %csec.tensor, ptr %tensor.malloc22, i32 0, i32 2
  store i64 %tensor.matmul.count21, ptr %tensor.count.slot28, align 4
  %tensor.data.slot29 = getelementptr inbounds %csec.tensor, ptr %tensor.malloc22, i32 0, i32 3
  store ptr %tensor.malloc25, ptr %tensor.data.slot29, align 8
  %tensor.dims.ptr30 = getelementptr inbounds %csec.tensor, ptr %tensor.malloc22, i32 0, i32 1
  %tensor.dims31 = load ptr, ptr %tensor.dims.ptr30, align 8
  %tensor.matmul.dst.rows32 = getelementptr i64, ptr %tensor.dims31, i64 0
  store i64 %tensor.matmul.rows16, ptr %tensor.matmul.dst.rows32, align 4
  %tensor.matmul.dst.cols33 = getelementptr i64, ptr %tensor.dims31, i64 1
  store i64 %tensor.matmul.cols20, ptr %tensor.matmul.dst.cols33, align 4
  %tensor.data.ptr34 = getelementptr inbounds %csec.tensor, ptr %hidden.load, i32 0, i32 3
  %tensor.data35 = load ptr, ptr %tensor.data.ptr34, align 8
  %tensor.data.ptr36 = getelementptr inbounds %csec.tensor, ptr %3, i32 0, i32 3
  %tensor.data37 = load ptr, ptr %tensor.data.ptr36, align 8
  %tensor.data.ptr38 = getelementptr inbounds %csec.tensor, ptr %tensor.malloc22, i32 0, i32 3
  %tensor.data39 = load ptr, ptr %tensor.data.ptr38, align 8
  %tensor.matmul.i.i40 = alloca i64, align 8
  store i64 0, ptr %tensor.matmul.i.i40, align 4
  br label %tensor.matmul.i.cond41

tensor.matmul.j.cond:                             ; preds = %tensor.matmul.k.end, %tensor.matmul.i.body
  %tensor.matmul.j.idx = load i64, ptr %tensor.matmul.j.i, align 4
  %tensor.matmul.j.keep = icmp ult i64 %tensor.matmul.j.idx, %tensor.matmul.cols
  br i1 %tensor.matmul.j.keep, label %tensor.matmul.j.body, label %tensor.matmul.j.end

tensor.matmul.j.body:                             ; preds = %tensor.matmul.j.cond
  %tensor.matmul.sum.ptr = alloca double, align 8
  store double 0.000000e+00, ptr %tensor.matmul.sum.ptr, align 8
  %tensor.matmul.k.i = alloca i64, align 8
  store i64 0, ptr %tensor.matmul.k.i, align 4
  br label %tensor.matmul.k.cond

tensor.matmul.j.end:                              ; preds = %tensor.matmul.j.cond
  %tensor.matmul.i.next = add i64 %tensor.matmul.i.i.0, 1
  br label %tensor.matmul.i.cond

tensor.matmul.k.cond:                             ; preds = %tensor.matmul.k.body, %tensor.matmul.j.body
  %tensor.matmul.k.idx = load i64, ptr %tensor.matmul.k.i, align 4
  %tensor.matmul.k.keep = icmp ult i64 %tensor.matmul.k.idx, %tensor.matmul.shared
  br i1 %tensor.matmul.k.keep, label %tensor.matmul.k.body, label %tensor.matmul.k.end

tensor.matmul.k.body:                             ; preds = %tensor.matmul.k.cond
  %5 = mul i64 %tensor.matmul.i.i.0, %tensor.matmul.shared
  %tensor.matmul.left.index = add i64 %5, %tensor.matmul.k.idx
  %6 = mul i64 %tensor.matmul.k.idx, %tensor.matmul.cols
  %tensor.matmul.right.index = add i64 %6, %tensor.matmul.j.idx
  %7 = getelementptr double, ptr %tensor.data8, i64 %tensor.matmul.right.index
  %tensor.matmul.right = load double, ptr %7, align 8
  %8 = getelementptr double, ptr %tensor.data, i64 %tensor.matmul.left.index
  %tensor.matmul.left = load double, ptr %8, align 8
  %tensor.matmul.product = fmul double %tensor.matmul.left, %tensor.matmul.right
  %tensor.matmul.current = load double, ptr %tensor.matmul.sum.ptr, align 8
  %tensor.matmul.next = fadd double %tensor.matmul.current, %tensor.matmul.product
  store double %tensor.matmul.next, ptr %tensor.matmul.sum.ptr, align 8
  %tensor.matmul.k.current = load i64, ptr %tensor.matmul.k.i, align 4
  %tensor.matmul.k.next = add i64 %tensor.matmul.k.current, 1
  store i64 %tensor.matmul.k.next, ptr %tensor.matmul.k.i, align 4
  br label %tensor.matmul.k.cond

tensor.matmul.k.end:                              ; preds = %tensor.matmul.k.cond
  %9 = mul i64 %tensor.matmul.i.i.0, %tensor.matmul.cols
  %tensor.matmul.dst.index = add i64 %9, %tensor.matmul.j.idx
  %tensor.matmul.dst = getelementptr double, ptr %tensor.data10, i64 %tensor.matmul.dst.index
  %tensor.matmul.sum = load double, ptr %tensor.matmul.sum.ptr, align 8
  store double %tensor.matmul.sum, ptr %tensor.matmul.dst, align 8
  %tensor.matmul.j.current = load i64, ptr %tensor.matmul.j.i, align 4
  %tensor.matmul.j.next = add i64 %tensor.matmul.j.current, 1
  store i64 %tensor.matmul.j.next, ptr %tensor.matmul.j.i, align 4
  br label %tensor.matmul.j.cond

tensor.matmul.i.cond41:                           ; preds = %tensor.matmul.j.end49, %tensor.matmul.i.end
  %tensor.matmul.i.idx44 = load i64, ptr %tensor.matmul.i.i40, align 4
  %tensor.matmul.i.keep45 = icmp ult i64 %tensor.matmul.i.idx44, %tensor.matmul.rows16
  br i1 %tensor.matmul.i.keep45, label %tensor.matmul.i.body42, label %tensor.matmul.i.end43

tensor.matmul.i.body42:                           ; preds = %tensor.matmul.i.cond41
  %tensor.matmul.j.i46 = alloca i64, align 8
  store i64 0, ptr %tensor.matmul.j.i46, align 4
  br label %tensor.matmul.j.cond47

tensor.matmul.i.end43:                            ; preds = %tensor.matmul.i.cond41
  %str.concat75 = call ptr @csec_string_concat(ptr null, ptr null)
  ret ptr %str.concat75

tensor.matmul.j.cond47:                           ; preds = %tensor.matmul.k.end56, %tensor.matmul.i.body42
  %tensor.matmul.j.idx50 = load i64, ptr %tensor.matmul.j.i46, align 4
  %tensor.matmul.j.keep51 = icmp ult i64 %tensor.matmul.j.idx50, %tensor.matmul.cols20
  br i1 %tensor.matmul.j.keep51, label %tensor.matmul.j.body48, label %tensor.matmul.j.end49

tensor.matmul.j.body48:                           ; preds = %tensor.matmul.j.cond47
  %tensor.matmul.sum.ptr52 = alloca double, align 8
  store double 0.000000e+00, ptr %tensor.matmul.sum.ptr52, align 8
  %tensor.matmul.k.i53 = alloca i64, align 8
  store i64 0, ptr %tensor.matmul.k.i53, align 4
  br label %tensor.matmul.k.cond54

tensor.matmul.j.end49:                            ; preds = %tensor.matmul.j.cond47
  %tensor.matmul.i.current73 = load i64, ptr %tensor.matmul.i.i40, align 4
  %tensor.matmul.i.next74 = add i64 %tensor.matmul.i.current73, 1
  store i64 %tensor.matmul.i.next74, ptr %tensor.matmul.i.i40, align 4
  br label %tensor.matmul.i.cond41

tensor.matmul.k.cond54:                           ; preds = %tensor.matmul.k.body55, %tensor.matmul.j.body48
  %tensor.matmul.k.idx57 = load i64, ptr %tensor.matmul.k.i53, align 4
  %tensor.matmul.k.keep58 = icmp ult i64 %tensor.matmul.k.idx57, %tensor.matmul.shared18
  br i1 %tensor.matmul.k.keep58, label %tensor.matmul.k.body55, label %tensor.matmul.k.end56

tensor.matmul.k.body55:                           ; preds = %tensor.matmul.k.cond54
  %10 = mul i64 %tensor.matmul.i.idx44, %tensor.matmul.shared18
  %tensor.matmul.left.index59 = add i64 %10, %tensor.matmul.k.idx57
  %11 = mul i64 %tensor.matmul.k.idx57, %tensor.matmul.cols20
  %tensor.matmul.right.index60 = add i64 %11, %tensor.matmul.j.idx50
  %12 = getelementptr double, ptr %tensor.data37, i64 %tensor.matmul.right.index60
  %tensor.matmul.right61 = load double, ptr %12, align 8
  %13 = getelementptr double, ptr %tensor.data35, i64 %tensor.matmul.left.index59
  %tensor.matmul.left62 = load double, ptr %13, align 8
  %tensor.matmul.product63 = fmul double %tensor.matmul.left62, %tensor.matmul.right61
  %tensor.matmul.current64 = load double, ptr %tensor.matmul.sum.ptr52, align 8
  %tensor.matmul.next65 = fadd double %tensor.matmul.current64, %tensor.matmul.product63
  store double %tensor.matmul.next65, ptr %tensor.matmul.sum.ptr52, align 8
  %tensor.matmul.k.current66 = load i64, ptr %tensor.matmul.k.i53, align 4
  %tensor.matmul.k.next67 = add i64 %tensor.matmul.k.current66, 1
  store i64 %tensor.matmul.k.next67, ptr %tensor.matmul.k.i53, align 4
  br label %tensor.matmul.k.cond54

tensor.matmul.k.end56:                            ; preds = %tensor.matmul.k.cond54
  %14 = mul i64 %tensor.matmul.i.idx44, %tensor.matmul.cols20
  %tensor.matmul.dst.index68 = add i64 %14, %tensor.matmul.j.idx50
  %tensor.matmul.dst69 = getelementptr double, ptr %tensor.data39, i64 %tensor.matmul.dst.index68
  %tensor.matmul.sum70 = load double, ptr %tensor.matmul.sum.ptr52, align 8
  store double %tensor.matmul.sum70, ptr %tensor.matmul.dst69, align 8
  %tensor.matmul.j.current71 = load i64, ptr %tensor.matmul.j.i46, align 4
  %tensor.matmul.j.next72 = add i64 %tensor.matmul.j.current71, 1
  store i64 %tensor.matmul.j.next72, ptr %tensor.matmul.j.i46, align 4
  br label %tensor.matmul.j.cond47
}

define ptr @_scaledDotProductAttention(ptr %0, ptr %1, ptr %2) {
entry:
  %tensor.rank.ptr = getelementptr inbounds %csec.tensor, ptr %1, i32 0, i32 0
  %tensor.rank = load i64, ptr %tensor.rank.ptr, align 4
  %tensor.count.ptr = getelementptr inbounds %csec.tensor, ptr %1, i32 0, i32 2
  %tensor.count = load i64, ptr %tensor.count.ptr, align 4
  %tensor.malloc = call ptr @malloc(i64 32)
  %tensor.dims.bytes = mul i64 %tensor.rank, 8
  %tensor.malloc1 = call ptr @malloc(i64 %tensor.dims.bytes)
  %tensor.data.bytes = mul i64 %tensor.count, 8
  %tensor.malloc2 = call ptr @malloc(i64 %tensor.data.bytes)
  %tensor.rank.slot = getelementptr inbounds %csec.tensor, ptr %tensor.malloc, i32 0, i32 0
  store i64 %tensor.rank, ptr %tensor.rank.slot, align 4
  %tensor.dims.slot = getelementptr inbounds %csec.tensor, ptr %tensor.malloc, i32 0, i32 1
  store ptr %tensor.malloc1, ptr %tensor.dims.slot, align 8
  %tensor.count.slot = getelementptr inbounds %csec.tensor, ptr %tensor.malloc, i32 0, i32 2
  store i64 %tensor.count, ptr %tensor.count.slot, align 4
  %tensor.data.slot = getelementptr inbounds %csec.tensor, ptr %tensor.malloc, i32 0, i32 3
  store ptr %tensor.malloc2, ptr %tensor.data.slot, align 8
  %tensor.dims.ptr = getelementptr inbounds %csec.tensor, ptr %1, i32 0, i32 1
  %tensor.dims = load ptr, ptr %tensor.dims.ptr, align 8
  %tensor.dims.ptr3 = getelementptr inbounds %csec.tensor, ptr %tensor.malloc, i32 0, i32 1
  %tensor.dims4 = load ptr, ptr %tensor.dims.ptr3, align 8
  %tensor.data.ptr = getelementptr inbounds %csec.tensor, ptr %1, i32 0, i32 3
  %tensor.data = load ptr, ptr %tensor.data.ptr, align 8
  %tensor.data.ptr5 = getelementptr inbounds %csec.tensor, ptr %tensor.malloc, i32 0, i32 3
  %tensor.data6 = load ptr, ptr %tensor.data.ptr5, align 8
  %tensor.last.dim = sub i64 %tensor.rank, 1
  %tensor.prev.dim = sub i64 %tensor.rank, 2
  br label %tensor.transpose.dims.cond

tensor.transpose.dims.cond:                       ; preds = %tensor.transpose.dims.body, %entry
  %tensor.transpose.dims.i.0 = phi i64 [ 0, %entry ], [ %tensor.transpose.dims.next, %tensor.transpose.dims.body ]
  %tensor.transpose.dims.keep = icmp ult i64 %tensor.transpose.dims.i.0, %tensor.rank
  br i1 %tensor.transpose.dims.keep, label %tensor.transpose.dims.body, label %tensor.transpose.dims.end

tensor.transpose.dims.body:                       ; preds = %tensor.transpose.dims.cond
  %tensor.use.last = icmp eq i64 %tensor.transpose.dims.i.0, %tensor.prev.dim
  %tensor.use.prev = icmp eq i64 %tensor.transpose.dims.i.0, %tensor.last.dim
  %3 = select i1 %tensor.use.prev, i64 %tensor.prev.dim, i64 %tensor.transpose.dims.i.0
  %tensor.transpose.dim.index = select i1 %tensor.use.last, i64 %tensor.last.dim, i64 %3
  %tensor.src.dim = getelementptr i64, ptr %tensor.dims, i64 %tensor.transpose.dim.index
  %tensor.dst.dim = getelementptr i64, ptr %tensor.dims4, i64 %tensor.transpose.dims.i.0
  %tensor.dim = load i64, ptr %tensor.src.dim, align 4
  store i64 %tensor.dim, ptr %tensor.dst.dim, align 4
  %tensor.transpose.dims.next = add i64 %tensor.transpose.dims.i.0, 1
  br label %tensor.transpose.dims.cond

tensor.transpose.dims.end:                        ; preds = %tensor.transpose.dims.cond
  %tensor.rows.slot = getelementptr i64, ptr %tensor.dims, i64 %tensor.prev.dim
  %tensor.cols.slot = getelementptr i64, ptr %tensor.dims, i64 %tensor.last.dim
  %tensor.rows = load i64, ptr %tensor.rows.slot, align 4
  %tensor.cols = load i64, ptr %tensor.cols.slot, align 4
  %tensor.rank.ge2 = icmp uge i64 %tensor.rank, 2
  br i1 %tensor.rank.ge2, label %tensor.transpose.data, label %tensor.transpose.copy

tensor.transpose.data:                            ; preds = %tensor.transpose.dims.end
  %tensor.transpose.rows.i = alloca i64, align 8
  store i64 0, ptr %tensor.transpose.rows.i, align 4
  br label %tensor.transpose.rows.cond

tensor.transpose.copy:                            ; preds = %tensor.transpose.dims.end
  %tensor.transpose.copy.data.i = alloca i64, align 8
  store i64 0, ptr %tensor.transpose.copy.data.i, align 4
  br label %tensor.transpose.copy.data.cond

tensor.transpose.end:                             ; preds = %tensor.transpose.copy.data.end, %tensor.transpose.rows.end
  %tensor.dims.ptr7 = getelementptr inbounds %csec.tensor, ptr %0, i32 0, i32 1
  %tensor.dims8 = load ptr, ptr %tensor.dims.ptr7, align 8
  %tensor.dims.ptr9 = getelementptr inbounds %csec.tensor, ptr %tensor.malloc, i32 0, i32 1
  %tensor.dims10 = load ptr, ptr %tensor.dims.ptr9, align 8
  %tensor.matmul.rows.ptr = getelementptr i64, ptr %tensor.dims8, i64 0
  %tensor.matmul.rows = load i64, ptr %tensor.matmul.rows.ptr, align 4
  %tensor.matmul.shared.ptr = getelementptr i64, ptr %tensor.dims8, i64 1
  %tensor.matmul.shared = load i64, ptr %tensor.matmul.shared.ptr, align 4
  %tensor.matmul.cols.ptr = getelementptr i64, ptr %tensor.dims10, i64 1
  %tensor.matmul.cols = load i64, ptr %tensor.matmul.cols.ptr, align 4
  %tensor.matmul.count = mul i64 %tensor.matmul.rows, %tensor.matmul.cols
  %tensor.malloc11 = call ptr @malloc(i64 32)
  %tensor.malloc12 = call ptr @malloc(i64 16)
  %tensor.data.bytes13 = mul i64 %tensor.matmul.count, 8
  %tensor.malloc14 = call ptr @malloc(i64 %tensor.data.bytes13)
  %tensor.rank.slot15 = getelementptr inbounds %csec.tensor, ptr %tensor.malloc11, i32 0, i32 0
  store i64 2, ptr %tensor.rank.slot15, align 4
  %tensor.dims.slot16 = getelementptr inbounds %csec.tensor, ptr %tensor.malloc11, i32 0, i32 1
  store ptr %tensor.malloc12, ptr %tensor.dims.slot16, align 8
  %tensor.count.slot17 = getelementptr inbounds %csec.tensor, ptr %tensor.malloc11, i32 0, i32 2
  store i64 %tensor.matmul.count, ptr %tensor.count.slot17, align 4
  %tensor.data.slot18 = getelementptr inbounds %csec.tensor, ptr %tensor.malloc11, i32 0, i32 3
  store ptr %tensor.malloc14, ptr %tensor.data.slot18, align 8
  %tensor.dims.ptr19 = getelementptr inbounds %csec.tensor, ptr %tensor.malloc11, i32 0, i32 1
  %tensor.dims20 = load ptr, ptr %tensor.dims.ptr19, align 8
  %tensor.matmul.dst.rows = getelementptr i64, ptr %tensor.dims20, i64 0
  store i64 %tensor.matmul.rows, ptr %tensor.matmul.dst.rows, align 4
  %tensor.matmul.dst.cols = getelementptr i64, ptr %tensor.dims20, i64 1
  store i64 %tensor.matmul.cols, ptr %tensor.matmul.dst.cols, align 4
  %tensor.data.ptr21 = getelementptr inbounds %csec.tensor, ptr %0, i32 0, i32 3
  %tensor.data22 = load ptr, ptr %tensor.data.ptr21, align 8
  %tensor.data.ptr23 = getelementptr inbounds %csec.tensor, ptr %tensor.malloc, i32 0, i32 3
  %tensor.data24 = load ptr, ptr %tensor.data.ptr23, align 8
  %tensor.data.ptr25 = getelementptr inbounds %csec.tensor, ptr %tensor.malloc11, i32 0, i32 3
  %tensor.data26 = load ptr, ptr %tensor.data.ptr25, align 8
  %tensor.matmul.i.i = alloca i64, align 8
  store i64 0, ptr %tensor.matmul.i.i, align 4
  br label %tensor.matmul.i.cond

tensor.transpose.rows.cond:                       ; preds = %tensor.transpose.cols.end, %tensor.transpose.data
  %tensor.transpose.rows.idx = load i64, ptr %tensor.transpose.rows.i, align 4
  %tensor.transpose.rows.keep = icmp ult i64 %tensor.transpose.rows.idx, %tensor.rows
  br i1 %tensor.transpose.rows.keep, label %tensor.transpose.rows.body, label %tensor.transpose.rows.end

tensor.transpose.rows.body:                       ; preds = %tensor.transpose.rows.cond
  %tensor.transpose.cols.i = alloca i64, align 8
  store i64 0, ptr %tensor.transpose.cols.i, align 4
  br label %tensor.transpose.cols.cond

tensor.transpose.rows.end:                        ; preds = %tensor.transpose.rows.cond
  br label %tensor.transpose.end

tensor.transpose.cols.cond:                       ; preds = %tensor.transpose.cols.body, %tensor.transpose.rows.body
  %tensor.transpose.cols.idx = load i64, ptr %tensor.transpose.cols.i, align 4
  %tensor.transpose.cols.keep = icmp ult i64 %tensor.transpose.cols.idx, %tensor.cols
  br i1 %tensor.transpose.cols.keep, label %tensor.transpose.cols.body, label %tensor.transpose.cols.end

tensor.transpose.cols.body:                       ; preds = %tensor.transpose.cols.cond
  %4 = mul i64 %tensor.transpose.rows.idx, %tensor.cols
  %tensor.transpose.src.index = add i64 %4, %tensor.transpose.cols.idx
  %5 = mul i64 %tensor.transpose.cols.idx, %tensor.rows
  %tensor.transpose.dst.index = add i64 %5, %tensor.transpose.rows.idx
  %tensor.transpose.src = getelementptr double, ptr %tensor.data, i64 %tensor.transpose.src.index
  %tensor.transpose.dst = getelementptr double, ptr %tensor.data6, i64 %tensor.transpose.dst.index
  %tensor.transpose.val = load double, ptr %tensor.transpose.src, align 8
  store double %tensor.transpose.val, ptr %tensor.transpose.dst, align 8
  %tensor.transpose.cols.current = load i64, ptr %tensor.transpose.cols.i, align 4
  %tensor.transpose.cols.next = add i64 %tensor.transpose.cols.current, 1
  store i64 %tensor.transpose.cols.next, ptr %tensor.transpose.cols.i, align 4
  br label %tensor.transpose.cols.cond

tensor.transpose.cols.end:                        ; preds = %tensor.transpose.cols.cond
  %tensor.transpose.rows.current = load i64, ptr %tensor.transpose.rows.i, align 4
  %tensor.transpose.rows.next = add i64 %tensor.transpose.rows.current, 1
  store i64 %tensor.transpose.rows.next, ptr %tensor.transpose.rows.i, align 4
  br label %tensor.transpose.rows.cond

tensor.transpose.copy.data.cond:                  ; preds = %tensor.transpose.copy.data.body, %tensor.transpose.copy
  %tensor.transpose.copy.data.idx = load i64, ptr %tensor.transpose.copy.data.i, align 4
  %tensor.transpose.copy.data.keep = icmp ult i64 %tensor.transpose.copy.data.idx, %tensor.count
  br i1 %tensor.transpose.copy.data.keep, label %tensor.transpose.copy.data.body, label %tensor.transpose.copy.data.end

tensor.transpose.copy.data.body:                  ; preds = %tensor.transpose.copy.data.cond
  %tensor.src.val = getelementptr double, ptr %tensor.data, i64 %tensor.transpose.copy.data.idx
  %tensor.dst.val = getelementptr double, ptr %tensor.data6, i64 %tensor.transpose.copy.data.idx
  %tensor.val = load double, ptr %tensor.src.val, align 8
  store double %tensor.val, ptr %tensor.dst.val, align 8
  %tensor.transpose.copy.data.current = load i64, ptr %tensor.transpose.copy.data.i, align 4
  %tensor.transpose.copy.data.next = add i64 %tensor.transpose.copy.data.current, 1
  store i64 %tensor.transpose.copy.data.next, ptr %tensor.transpose.copy.data.i, align 4
  br label %tensor.transpose.copy.data.cond

tensor.transpose.copy.data.end:                   ; preds = %tensor.transpose.copy.data.cond
  br label %tensor.transpose.end

tensor.matmul.i.cond:                             ; preds = %tensor.matmul.j.end, %tensor.transpose.end
  %tensor.matmul.i.idx = load i64, ptr %tensor.matmul.i.i, align 4
  %tensor.matmul.i.keep = icmp ult i64 %tensor.matmul.i.idx, %tensor.matmul.rows
  br i1 %tensor.matmul.i.keep, label %tensor.matmul.i.body, label %tensor.matmul.i.end

tensor.matmul.i.body:                             ; preds = %tensor.matmul.i.cond
  %tensor.matmul.j.i = alloca i64, align 8
  store i64 0, ptr %tensor.matmul.j.i, align 4
  br label %tensor.matmul.j.cond

tensor.matmul.i.end:                              ; preds = %tensor.matmul.i.cond
  %tensor.rank.ptr27 = getelementptr inbounds %csec.tensor, ptr %tensor.malloc11, i32 0, i32 0
  %tensor.rank28 = load i64, ptr %tensor.rank.ptr27, align 4
  %tensor.count.ptr29 = getelementptr inbounds %csec.tensor, ptr %tensor.malloc11, i32 0, i32 2
  %tensor.count30 = load i64, ptr %tensor.count.ptr29, align 4
  %tensor.malloc31 = call ptr @malloc(i64 32)
  %tensor.dims.bytes32 = mul i64 %tensor.rank28, 8
  %tensor.malloc33 = call ptr @malloc(i64 %tensor.dims.bytes32)
  %tensor.data.bytes34 = mul i64 %tensor.count30, 8
  %tensor.malloc35 = call ptr @malloc(i64 %tensor.data.bytes34)
  %tensor.rank.slot36 = getelementptr inbounds %csec.tensor, ptr %tensor.malloc31, i32 0, i32 0
  store i64 %tensor.rank28, ptr %tensor.rank.slot36, align 4
  %tensor.dims.slot37 = getelementptr inbounds %csec.tensor, ptr %tensor.malloc31, i32 0, i32 1
  store ptr %tensor.malloc33, ptr %tensor.dims.slot37, align 8
  %tensor.count.slot38 = getelementptr inbounds %csec.tensor, ptr %tensor.malloc31, i32 0, i32 2
  store i64 %tensor.count30, ptr %tensor.count.slot38, align 4
  %tensor.data.slot39 = getelementptr inbounds %csec.tensor, ptr %tensor.malloc31, i32 0, i32 3
  store ptr %tensor.malloc35, ptr %tensor.data.slot39, align 8
  %tensor.dims.ptr40 = getelementptr inbounds %csec.tensor, ptr %tensor.malloc11, i32 0, i32 1
  %tensor.dims41 = load ptr, ptr %tensor.dims.ptr40, align 8
  %tensor.dims.ptr42 = getelementptr inbounds %csec.tensor, ptr %tensor.malloc31, i32 0, i32 1
  %tensor.dims43 = load ptr, ptr %tensor.dims.ptr42, align 8
  %tensor.data.ptr44 = getelementptr inbounds %csec.tensor, ptr %tensor.malloc11, i32 0, i32 3
  %tensor.data45 = load ptr, ptr %tensor.data.ptr44, align 8
  %tensor.data.ptr46 = getelementptr inbounds %csec.tensor, ptr %tensor.malloc31, i32 0, i32 3
  %tensor.data47 = load ptr, ptr %tensor.data.ptr46, align 8
  %tensor.fpext = fpext float 5.000000e-01 to double
  %tensor.scalar.dims.i = alloca i64, align 8
  store i64 0, ptr %tensor.scalar.dims.i, align 4
  br label %tensor.scalar.dims.cond

tensor.matmul.j.cond:                             ; preds = %tensor.matmul.k.end, %tensor.matmul.i.body
  %tensor.matmul.j.idx = load i64, ptr %tensor.matmul.j.i, align 4
  %tensor.matmul.j.keep = icmp ult i64 %tensor.matmul.j.idx, %tensor.matmul.cols
  br i1 %tensor.matmul.j.keep, label %tensor.matmul.j.body, label %tensor.matmul.j.end

tensor.matmul.j.body:                             ; preds = %tensor.matmul.j.cond
  %tensor.matmul.sum.ptr = alloca double, align 8
  store double 0.000000e+00, ptr %tensor.matmul.sum.ptr, align 8
  %tensor.matmul.k.i = alloca i64, align 8
  store i64 0, ptr %tensor.matmul.k.i, align 4
  br label %tensor.matmul.k.cond

tensor.matmul.j.end:                              ; preds = %tensor.matmul.j.cond
  %tensor.matmul.i.current = load i64, ptr %tensor.matmul.i.i, align 4
  %tensor.matmul.i.next = add i64 %tensor.matmul.i.current, 1
  store i64 %tensor.matmul.i.next, ptr %tensor.matmul.i.i, align 4
  br label %tensor.matmul.i.cond

tensor.matmul.k.cond:                             ; preds = %tensor.matmul.k.body, %tensor.matmul.j.body
  %tensor.matmul.k.idx = load i64, ptr %tensor.matmul.k.i, align 4
  %tensor.matmul.k.keep = icmp ult i64 %tensor.matmul.k.idx, %tensor.matmul.shared
  br i1 %tensor.matmul.k.keep, label %tensor.matmul.k.body, label %tensor.matmul.k.end

tensor.matmul.k.body:                             ; preds = %tensor.matmul.k.cond
  %6 = mul i64 %tensor.matmul.i.idx, %tensor.matmul.shared
  %tensor.matmul.left.index = add i64 %6, %tensor.matmul.k.idx
  %7 = mul i64 %tensor.matmul.k.idx, %tensor.matmul.cols
  %tensor.matmul.right.index = add i64 %7, %tensor.matmul.j.idx
  %8 = getelementptr double, ptr %tensor.data24, i64 %tensor.matmul.right.index
  %tensor.matmul.right = load double, ptr %8, align 8
  %9 = getelementptr double, ptr %tensor.data22, i64 %tensor.matmul.left.index
  %tensor.matmul.left = load double, ptr %9, align 8
  %tensor.matmul.product = fmul double %tensor.matmul.left, %tensor.matmul.right
  %tensor.matmul.current = load double, ptr %tensor.matmul.sum.ptr, align 8
  %tensor.matmul.next = fadd double %tensor.matmul.current, %tensor.matmul.product
  store double %tensor.matmul.next, ptr %tensor.matmul.sum.ptr, align 8
  %tensor.matmul.k.current = load i64, ptr %tensor.matmul.k.i, align 4
  %tensor.matmul.k.next = add i64 %tensor.matmul.k.current, 1
  store i64 %tensor.matmul.k.next, ptr %tensor.matmul.k.i, align 4
  br label %tensor.matmul.k.cond

tensor.matmul.k.end:                              ; preds = %tensor.matmul.k.cond
  %10 = mul i64 %tensor.matmul.i.idx, %tensor.matmul.cols
  %tensor.matmul.dst.index = add i64 %10, %tensor.matmul.j.idx
  %tensor.matmul.dst = getelementptr double, ptr %tensor.data26, i64 %tensor.matmul.dst.index
  %tensor.matmul.sum = load double, ptr %tensor.matmul.sum.ptr, align 8
  store double %tensor.matmul.sum, ptr %tensor.matmul.dst, align 8
  %tensor.matmul.j.current = load i64, ptr %tensor.matmul.j.i, align 4
  %tensor.matmul.j.next = add i64 %tensor.matmul.j.current, 1
  store i64 %tensor.matmul.j.next, ptr %tensor.matmul.j.i, align 4
  br label %tensor.matmul.j.cond

tensor.scalar.dims.cond:                          ; preds = %tensor.scalar.dims.body, %tensor.matmul.i.end
  %tensor.scalar.dims.idx = load i64, ptr %tensor.scalar.dims.i, align 4
  %tensor.scalar.dims.keep = icmp ult i64 %tensor.scalar.dims.idx, %tensor.rank28
  br i1 %tensor.scalar.dims.keep, label %tensor.scalar.dims.body, label %tensor.scalar.dims.end

tensor.scalar.dims.body:                          ; preds = %tensor.scalar.dims.cond
  %tensor.scalar.src.dim = getelementptr i64, ptr %tensor.dims41, i64 %tensor.scalar.dims.idx
  %tensor.scalar.dst.dim = getelementptr i64, ptr %tensor.dims43, i64 %tensor.scalar.dims.idx
  %tensor.scalar.dim = load i64, ptr %tensor.scalar.src.dim, align 4
  store i64 %tensor.scalar.dim, ptr %tensor.scalar.dst.dim, align 4
  %tensor.scalar.dims.current = load i64, ptr %tensor.scalar.dims.i, align 4
  %tensor.scalar.dims.next = add i64 %tensor.scalar.dims.current, 1
  store i64 %tensor.scalar.dims.next, ptr %tensor.scalar.dims.i, align 4
  br label %tensor.scalar.dims.cond

tensor.scalar.dims.end:                           ; preds = %tensor.scalar.dims.cond
  %tensor.scalar.data.i = alloca i64, align 8
  store i64 0, ptr %tensor.scalar.data.i, align 4
  br label %tensor.scalar.data.cond

tensor.scalar.data.cond:                          ; preds = %tensor.scalar.data.body, %tensor.scalar.dims.end
  %tensor.scalar.data.idx = load i64, ptr %tensor.scalar.data.i, align 4
  %tensor.scalar.data.keep = icmp ult i64 %tensor.scalar.data.idx, %tensor.count30
  br i1 %tensor.scalar.data.keep, label %tensor.scalar.data.body, label %tensor.scalar.data.end

tensor.scalar.data.body:                          ; preds = %tensor.scalar.data.cond
  %tensor.scalar.src = getelementptr double, ptr %tensor.data45, i64 %tensor.scalar.data.idx
  %tensor.scalar.tensor = load double, ptr %tensor.scalar.src, align 8
  %tensor.scalar.dst = getelementptr double, ptr %tensor.data47, i64 %tensor.scalar.data.idx
  %tensor.mul = fmul double %tensor.scalar.tensor, %tensor.fpext
  store double %tensor.mul, ptr %tensor.scalar.dst, align 8
  %tensor.scalar.data.current = load i64, ptr %tensor.scalar.data.i, align 4
  %tensor.scalar.data.next = add i64 %tensor.scalar.data.current, 1
  store i64 %tensor.scalar.data.next, ptr %tensor.scalar.data.i, align 4
  br label %tensor.scalar.data.cond

tensor.scalar.data.end:                           ; preds = %tensor.scalar.data.cond
  %scores = alloca ptr, align 8
  store ptr %tensor.malloc31, ptr %scores, align 8
  %scores.load = load ptr, ptr %scores, align 8
  %probabilities = alloca ptr, align 8
  store ptr %scores.load, ptr %probabilities, align 8
  %probabilities.load = load ptr, ptr %probabilities, align 8
  %tensor.dims.ptr48 = getelementptr inbounds %csec.tensor, ptr %probabilities.load, i32 0, i32 1
  %tensor.dims49 = load ptr, ptr %tensor.dims.ptr48, align 8
  %tensor.dims.ptr50 = getelementptr inbounds %csec.tensor, ptr %2, i32 0, i32 1
  %tensor.dims51 = load ptr, ptr %tensor.dims.ptr50, align 8
  %tensor.matmul.rows.ptr52 = getelementptr i64, ptr %tensor.dims49, i64 0
  %tensor.matmul.rows53 = load i64, ptr %tensor.matmul.rows.ptr52, align 4
  %tensor.matmul.shared.ptr54 = getelementptr i64, ptr %tensor.dims49, i64 1
  %tensor.matmul.shared55 = load i64, ptr %tensor.matmul.shared.ptr54, align 4
  %tensor.matmul.cols.ptr56 = getelementptr i64, ptr %tensor.dims51, i64 1
  %tensor.matmul.cols57 = load i64, ptr %tensor.matmul.cols.ptr56, align 4
  %tensor.matmul.count58 = mul i64 %tensor.matmul.rows53, %tensor.matmul.cols57
  %tensor.malloc59 = call ptr @malloc(i64 32)
  %tensor.malloc60 = call ptr @malloc(i64 16)
  %tensor.data.bytes61 = mul i64 %tensor.matmul.count58, 8
  %tensor.malloc62 = call ptr @malloc(i64 %tensor.data.bytes61)
  %tensor.rank.slot63 = getelementptr inbounds %csec.tensor, ptr %tensor.malloc59, i32 0, i32 0
  store i64 2, ptr %tensor.rank.slot63, align 4
  %tensor.dims.slot64 = getelementptr inbounds %csec.tensor, ptr %tensor.malloc59, i32 0, i32 1
  store ptr %tensor.malloc60, ptr %tensor.dims.slot64, align 8
  %tensor.count.slot65 = getelementptr inbounds %csec.tensor, ptr %tensor.malloc59, i32 0, i32 2
  store i64 %tensor.matmul.count58, ptr %tensor.count.slot65, align 4
  %tensor.data.slot66 = getelementptr inbounds %csec.tensor, ptr %tensor.malloc59, i32 0, i32 3
  store ptr %tensor.malloc62, ptr %tensor.data.slot66, align 8
  %tensor.dims.ptr67 = getelementptr inbounds %csec.tensor, ptr %tensor.malloc59, i32 0, i32 1
  %tensor.dims68 = load ptr, ptr %tensor.dims.ptr67, align 8
  %tensor.matmul.dst.rows69 = getelementptr i64, ptr %tensor.dims68, i64 0
  store i64 %tensor.matmul.rows53, ptr %tensor.matmul.dst.rows69, align 4
  %tensor.matmul.dst.cols70 = getelementptr i64, ptr %tensor.dims68, i64 1
  store i64 %tensor.matmul.cols57, ptr %tensor.matmul.dst.cols70, align 4
  %tensor.data.ptr71 = getelementptr inbounds %csec.tensor, ptr %probabilities.load, i32 0, i32 3
  %tensor.data72 = load ptr, ptr %tensor.data.ptr71, align 8
  %tensor.data.ptr73 = getelementptr inbounds %csec.tensor, ptr %2, i32 0, i32 3
  %tensor.data74 = load ptr, ptr %tensor.data.ptr73, align 8
  %tensor.data.ptr75 = getelementptr inbounds %csec.tensor, ptr %tensor.malloc59, i32 0, i32 3
  %tensor.data76 = load ptr, ptr %tensor.data.ptr75, align 8
  %tensor.matmul.i.i77 = alloca i64, align 8
  store i64 0, ptr %tensor.matmul.i.i77, align 4
  br label %tensor.matmul.i.cond78

tensor.matmul.i.cond78:                           ; preds = %tensor.matmul.j.end86, %tensor.scalar.data.end
  %tensor.matmul.i.idx81 = load i64, ptr %tensor.matmul.i.i77, align 4
  %tensor.matmul.i.keep82 = icmp ult i64 %tensor.matmul.i.idx81, %tensor.matmul.rows53
  br i1 %tensor.matmul.i.keep82, label %tensor.matmul.i.body79, label %tensor.matmul.i.end80

tensor.matmul.i.body79:                           ; preds = %tensor.matmul.i.cond78
  %tensor.matmul.j.i83 = alloca i64, align 8
  store i64 0, ptr %tensor.matmul.j.i83, align 4
  br label %tensor.matmul.j.cond84

tensor.matmul.i.end80:                            ; preds = %tensor.matmul.i.cond78
  ret ptr %tensor.malloc59

tensor.matmul.j.cond84:                           ; preds = %tensor.matmul.k.end93, %tensor.matmul.i.body79
  %tensor.matmul.j.idx87 = load i64, ptr %tensor.matmul.j.i83, align 4
  %tensor.matmul.j.keep88 = icmp ult i64 %tensor.matmul.j.idx87, %tensor.matmul.cols57
  br i1 %tensor.matmul.j.keep88, label %tensor.matmul.j.body85, label %tensor.matmul.j.end86

tensor.matmul.j.body85:                           ; preds = %tensor.matmul.j.cond84
  %tensor.matmul.sum.ptr89 = alloca double, align 8
  store double 0.000000e+00, ptr %tensor.matmul.sum.ptr89, align 8
  %tensor.matmul.k.i90 = alloca i64, align 8
  store i64 0, ptr %tensor.matmul.k.i90, align 4
  br label %tensor.matmul.k.cond91

tensor.matmul.j.end86:                            ; preds = %tensor.matmul.j.cond84
  %tensor.matmul.i.current110 = load i64, ptr %tensor.matmul.i.i77, align 4
  %tensor.matmul.i.next111 = add i64 %tensor.matmul.i.current110, 1
  store i64 %tensor.matmul.i.next111, ptr %tensor.matmul.i.i77, align 4
  br label %tensor.matmul.i.cond78

tensor.matmul.k.cond91:                           ; preds = %tensor.matmul.k.body92, %tensor.matmul.j.body85
  %tensor.matmul.k.idx94 = load i64, ptr %tensor.matmul.k.i90, align 4
  %tensor.matmul.k.keep95 = icmp ult i64 %tensor.matmul.k.idx94, %tensor.matmul.shared55
  br i1 %tensor.matmul.k.keep95, label %tensor.matmul.k.body92, label %tensor.matmul.k.end93

tensor.matmul.k.body92:                           ; preds = %tensor.matmul.k.cond91
  %11 = mul i64 %tensor.matmul.i.idx81, %tensor.matmul.shared55
  %tensor.matmul.left.index96 = add i64 %11, %tensor.matmul.k.idx94
  %12 = mul i64 %tensor.matmul.k.idx94, %tensor.matmul.cols57
  %tensor.matmul.right.index97 = add i64 %12, %tensor.matmul.j.idx87
  %13 = getelementptr double, ptr %tensor.data74, i64 %tensor.matmul.right.index97
  %tensor.matmul.right98 = load double, ptr %13, align 8
  %14 = getelementptr double, ptr %tensor.data72, i64 %tensor.matmul.left.index96
  %tensor.matmul.left99 = load double, ptr %14, align 8
  %tensor.matmul.product100 = fmul double %tensor.matmul.left99, %tensor.matmul.right98
  %tensor.matmul.current101 = load double, ptr %tensor.matmul.sum.ptr89, align 8
  %tensor.matmul.next102 = fadd double %tensor.matmul.current101, %tensor.matmul.product100
  store double %tensor.matmul.next102, ptr %tensor.matmul.sum.ptr89, align 8
  %tensor.matmul.k.current103 = load i64, ptr %tensor.matmul.k.i90, align 4
  %tensor.matmul.k.next104 = add i64 %tensor.matmul.k.current103, 1
  store i64 %tensor.matmul.k.next104, ptr %tensor.matmul.k.i90, align 4
  br label %tensor.matmul.k.cond91

tensor.matmul.k.end93:                            ; preds = %tensor.matmul.k.cond91
  %15 = mul i64 %tensor.matmul.i.idx81, %tensor.matmul.cols57
  %tensor.matmul.dst.index105 = add i64 %15, %tensor.matmul.j.idx87
  %tensor.matmul.dst106 = getelementptr double, ptr %tensor.data76, i64 %tensor.matmul.dst.index105
  %tensor.matmul.sum107 = load double, ptr %tensor.matmul.sum.ptr89, align 8
  store double %tensor.matmul.sum107, ptr %tensor.matmul.dst106, align 8
  %tensor.matmul.j.current108 = load i64, ptr %tensor.matmul.j.i83, align 4
  %tensor.matmul.j.next109 = add i64 %tensor.matmul.j.current108, 1
  store i64 %tensor.matmul.j.next109, ptr %tensor.matmul.j.i83, align 4
  br label %tensor.matmul.j.cond84
}

define ptr @_residualAdd(ptr %0, ptr %1) {
entry:
  %str.concat = call ptr @csec_string_concat(ptr null, ptr null)
  ret ptr %str.concat
}

define double @_randomInit(double %0) {
entry:
  %fmultmp = fmul double %0, 0x4029FAC720000000
  %math.call = call double @csec_math_sin(double %fmultmp)
  %fmultmp1 = fmul double %math.call, 0x3F947AE140000000
  ret double %fmultmp1
}

define ptr @_transformerBlock(ptr %0, ptr %1, ptr %2, ptr %3, ptr %4, ptr %5, ptr %6, ptr %7, ptr %8, ptr %9) {
entry:
  %tensor.dims.ptr = getelementptr inbounds %csec.tensor, ptr %0, i32 0, i32 1
  %tensor.dims = load ptr, ptr %tensor.dims.ptr, align 8
  %tensor.dims.ptr1 = getelementptr inbounds %csec.tensor, ptr %1, i32 0, i32 1
  %tensor.dims2 = load ptr, ptr %tensor.dims.ptr1, align 8
  %tensor.matmul.rows.ptr = getelementptr i64, ptr %tensor.dims, i64 0
  %tensor.matmul.rows = load i64, ptr %tensor.matmul.rows.ptr, align 4
  %tensor.matmul.shared.ptr = getelementptr i64, ptr %tensor.dims, i64 1
  %tensor.matmul.shared = load i64, ptr %tensor.matmul.shared.ptr, align 4
  %tensor.matmul.cols.ptr = getelementptr i64, ptr %tensor.dims2, i64 1
  %tensor.matmul.cols = load i64, ptr %tensor.matmul.cols.ptr, align 4
  %tensor.matmul.count = mul i64 %tensor.matmul.rows, %tensor.matmul.cols
  %tensor.malloc = call ptr @malloc(i64 32)
  %tensor.malloc3 = call ptr @malloc(i64 16)
  %tensor.data.bytes = mul i64 %tensor.matmul.count, 8
  %tensor.malloc4 = call ptr @malloc(i64 %tensor.data.bytes)
  %tensor.rank.slot = getelementptr inbounds %csec.tensor, ptr %tensor.malloc, i32 0, i32 0
  store i64 2, ptr %tensor.rank.slot, align 4
  %tensor.dims.slot = getelementptr inbounds %csec.tensor, ptr %tensor.malloc, i32 0, i32 1
  store ptr %tensor.malloc3, ptr %tensor.dims.slot, align 8
  %tensor.count.slot = getelementptr inbounds %csec.tensor, ptr %tensor.malloc, i32 0, i32 2
  store i64 %tensor.matmul.count, ptr %tensor.count.slot, align 4
  %tensor.data.slot = getelementptr inbounds %csec.tensor, ptr %tensor.malloc, i32 0, i32 3
  store ptr %tensor.malloc4, ptr %tensor.data.slot, align 8
  %tensor.dims.ptr5 = getelementptr inbounds %csec.tensor, ptr %tensor.malloc, i32 0, i32 1
  %tensor.dims6 = load ptr, ptr %tensor.dims.ptr5, align 8
  %tensor.matmul.dst.rows = getelementptr i64, ptr %tensor.dims6, i64 0
  store i64 %tensor.matmul.rows, ptr %tensor.matmul.dst.rows, align 4
  %tensor.matmul.dst.cols = getelementptr i64, ptr %tensor.dims6, i64 1
  store i64 %tensor.matmul.cols, ptr %tensor.matmul.dst.cols, align 4
  %tensor.data.ptr = getelementptr inbounds %csec.tensor, ptr %0, i32 0, i32 3
  %tensor.data = load ptr, ptr %tensor.data.ptr, align 8
  %tensor.data.ptr7 = getelementptr inbounds %csec.tensor, ptr %1, i32 0, i32 3
  %tensor.data8 = load ptr, ptr %tensor.data.ptr7, align 8
  %tensor.data.ptr9 = getelementptr inbounds %csec.tensor, ptr %tensor.malloc, i32 0, i32 3
  %tensor.data10 = load ptr, ptr %tensor.data.ptr9, align 8
  br label %tensor.matmul.i.cond

tensor.matmul.i.cond:                             ; preds = %tensor.matmul.j.end, %entry
  %tensor.matmul.i.i.0 = phi i64 [ 0, %entry ], [ %tensor.matmul.i.next, %tensor.matmul.j.end ]
  %tensor.matmul.i.keep = icmp ult i64 %tensor.matmul.i.i.0, %tensor.matmul.rows
  br i1 %tensor.matmul.i.keep, label %tensor.matmul.i.body, label %tensor.matmul.i.end

tensor.matmul.i.body:                             ; preds = %tensor.matmul.i.cond
  %tensor.matmul.j.i = alloca i64, align 8
  store i64 0, ptr %tensor.matmul.j.i, align 4
  br label %tensor.matmul.j.cond

tensor.matmul.i.end:                              ; preds = %tensor.matmul.i.cond
  %query = alloca ptr, align 8
  store ptr %tensor.malloc, ptr %query, align 8
  %tensor.dims.ptr11 = getelementptr inbounds %csec.tensor, ptr %0, i32 0, i32 1
  %tensor.dims12 = load ptr, ptr %tensor.dims.ptr11, align 8
  %tensor.dims.ptr13 = getelementptr inbounds %csec.tensor, ptr %2, i32 0, i32 1
  %tensor.dims14 = load ptr, ptr %tensor.dims.ptr13, align 8
  %tensor.matmul.rows.ptr15 = getelementptr i64, ptr %tensor.dims12, i64 0
  %tensor.matmul.rows16 = load i64, ptr %tensor.matmul.rows.ptr15, align 4
  %tensor.matmul.shared.ptr17 = getelementptr i64, ptr %tensor.dims12, i64 1
  %tensor.matmul.shared18 = load i64, ptr %tensor.matmul.shared.ptr17, align 4
  %tensor.matmul.cols.ptr19 = getelementptr i64, ptr %tensor.dims14, i64 1
  %tensor.matmul.cols20 = load i64, ptr %tensor.matmul.cols.ptr19, align 4
  %tensor.matmul.count21 = mul i64 %tensor.matmul.rows16, %tensor.matmul.cols20
  %tensor.malloc22 = call ptr @malloc(i64 32)
  %tensor.malloc23 = call ptr @malloc(i64 16)
  %tensor.data.bytes24 = mul i64 %tensor.matmul.count21, 8
  %tensor.malloc25 = call ptr @malloc(i64 %tensor.data.bytes24)
  %tensor.rank.slot26 = getelementptr inbounds %csec.tensor, ptr %tensor.malloc22, i32 0, i32 0
  store i64 2, ptr %tensor.rank.slot26, align 4
  %tensor.dims.slot27 = getelementptr inbounds %csec.tensor, ptr %tensor.malloc22, i32 0, i32 1
  store ptr %tensor.malloc23, ptr %tensor.dims.slot27, align 8
  %tensor.count.slot28 = getelementptr inbounds %csec.tensor, ptr %tensor.malloc22, i32 0, i32 2
  store i64 %tensor.matmul.count21, ptr %tensor.count.slot28, align 4
  %tensor.data.slot29 = getelementptr inbounds %csec.tensor, ptr %tensor.malloc22, i32 0, i32 3
  store ptr %tensor.malloc25, ptr %tensor.data.slot29, align 8
  %tensor.dims.ptr30 = getelementptr inbounds %csec.tensor, ptr %tensor.malloc22, i32 0, i32 1
  %tensor.dims31 = load ptr, ptr %tensor.dims.ptr30, align 8
  %tensor.matmul.dst.rows32 = getelementptr i64, ptr %tensor.dims31, i64 0
  store i64 %tensor.matmul.rows16, ptr %tensor.matmul.dst.rows32, align 4
  %tensor.matmul.dst.cols33 = getelementptr i64, ptr %tensor.dims31, i64 1
  store i64 %tensor.matmul.cols20, ptr %tensor.matmul.dst.cols33, align 4
  %tensor.data.ptr34 = getelementptr inbounds %csec.tensor, ptr %0, i32 0, i32 3
  %tensor.data35 = load ptr, ptr %tensor.data.ptr34, align 8
  %tensor.data.ptr36 = getelementptr inbounds %csec.tensor, ptr %2, i32 0, i32 3
  %tensor.data37 = load ptr, ptr %tensor.data.ptr36, align 8
  %tensor.data.ptr38 = getelementptr inbounds %csec.tensor, ptr %tensor.malloc22, i32 0, i32 3
  %tensor.data39 = load ptr, ptr %tensor.data.ptr38, align 8
  %tensor.matmul.i.i40 = alloca i64, align 8
  store i64 0, ptr %tensor.matmul.i.i40, align 4
  br label %tensor.matmul.i.cond41

tensor.matmul.j.cond:                             ; preds = %tensor.matmul.k.end, %tensor.matmul.i.body
  %tensor.matmul.j.idx = load i64, ptr %tensor.matmul.j.i, align 4
  %tensor.matmul.j.keep = icmp ult i64 %tensor.matmul.j.idx, %tensor.matmul.cols
  br i1 %tensor.matmul.j.keep, label %tensor.matmul.j.body, label %tensor.matmul.j.end

tensor.matmul.j.body:                             ; preds = %tensor.matmul.j.cond
  %tensor.matmul.sum.ptr = alloca double, align 8
  store double 0.000000e+00, ptr %tensor.matmul.sum.ptr, align 8
  %tensor.matmul.k.i = alloca i64, align 8
  store i64 0, ptr %tensor.matmul.k.i, align 4
  br label %tensor.matmul.k.cond

tensor.matmul.j.end:                              ; preds = %tensor.matmul.j.cond
  %tensor.matmul.i.next = add i64 %tensor.matmul.i.i.0, 1
  br label %tensor.matmul.i.cond

tensor.matmul.k.cond:                             ; preds = %tensor.matmul.k.body, %tensor.matmul.j.body
  %tensor.matmul.k.idx = load i64, ptr %tensor.matmul.k.i, align 4
  %tensor.matmul.k.keep = icmp ult i64 %tensor.matmul.k.idx, %tensor.matmul.shared
  br i1 %tensor.matmul.k.keep, label %tensor.matmul.k.body, label %tensor.matmul.k.end

tensor.matmul.k.body:                             ; preds = %tensor.matmul.k.cond
  %10 = mul i64 %tensor.matmul.i.i.0, %tensor.matmul.shared
  %tensor.matmul.left.index = add i64 %10, %tensor.matmul.k.idx
  %11 = mul i64 %tensor.matmul.k.idx, %tensor.matmul.cols
  %tensor.matmul.right.index = add i64 %11, %tensor.matmul.j.idx
  %12 = getelementptr double, ptr %tensor.data8, i64 %tensor.matmul.right.index
  %tensor.matmul.right = load double, ptr %12, align 8
  %13 = getelementptr double, ptr %tensor.data, i64 %tensor.matmul.left.index
  %tensor.matmul.left = load double, ptr %13, align 8
  %tensor.matmul.product = fmul double %tensor.matmul.left, %tensor.matmul.right
  %tensor.matmul.current = load double, ptr %tensor.matmul.sum.ptr, align 8
  %tensor.matmul.next = fadd double %tensor.matmul.current, %tensor.matmul.product
  store double %tensor.matmul.next, ptr %tensor.matmul.sum.ptr, align 8
  %tensor.matmul.k.current = load i64, ptr %tensor.matmul.k.i, align 4
  %tensor.matmul.k.next = add i64 %tensor.matmul.k.current, 1
  store i64 %tensor.matmul.k.next, ptr %tensor.matmul.k.i, align 4
  br label %tensor.matmul.k.cond

tensor.matmul.k.end:                              ; preds = %tensor.matmul.k.cond
  %14 = mul i64 %tensor.matmul.i.i.0, %tensor.matmul.cols
  %tensor.matmul.dst.index = add i64 %14, %tensor.matmul.j.idx
  %tensor.matmul.dst = getelementptr double, ptr %tensor.data10, i64 %tensor.matmul.dst.index
  %tensor.matmul.sum = load double, ptr %tensor.matmul.sum.ptr, align 8
  store double %tensor.matmul.sum, ptr %tensor.matmul.dst, align 8
  %tensor.matmul.j.current = load i64, ptr %tensor.matmul.j.i, align 4
  %tensor.matmul.j.next = add i64 %tensor.matmul.j.current, 1
  store i64 %tensor.matmul.j.next, ptr %tensor.matmul.j.i, align 4
  br label %tensor.matmul.j.cond

tensor.matmul.i.cond41:                           ; preds = %tensor.matmul.j.end49, %tensor.matmul.i.end
  %tensor.matmul.i.idx44 = load i64, ptr %tensor.matmul.i.i40, align 4
  %tensor.matmul.i.keep45 = icmp ult i64 %tensor.matmul.i.idx44, %tensor.matmul.rows16
  br i1 %tensor.matmul.i.keep45, label %tensor.matmul.i.body42, label %tensor.matmul.i.end43

tensor.matmul.i.body42:                           ; preds = %tensor.matmul.i.cond41
  %tensor.matmul.j.i46 = alloca i64, align 8
  store i64 0, ptr %tensor.matmul.j.i46, align 4
  br label %tensor.matmul.j.cond47

tensor.matmul.i.end43:                            ; preds = %tensor.matmul.i.cond41
  %key = alloca ptr, align 8
  store ptr %tensor.malloc22, ptr %key, align 8
  %tensor.dims.ptr75 = getelementptr inbounds %csec.tensor, ptr %0, i32 0, i32 1
  %tensor.dims76 = load ptr, ptr %tensor.dims.ptr75, align 8
  %tensor.dims.ptr77 = getelementptr inbounds %csec.tensor, ptr %3, i32 0, i32 1
  %tensor.dims78 = load ptr, ptr %tensor.dims.ptr77, align 8
  %tensor.matmul.rows.ptr79 = getelementptr i64, ptr %tensor.dims76, i64 0
  %tensor.matmul.rows80 = load i64, ptr %tensor.matmul.rows.ptr79, align 4
  %tensor.matmul.shared.ptr81 = getelementptr i64, ptr %tensor.dims76, i64 1
  %tensor.matmul.shared82 = load i64, ptr %tensor.matmul.shared.ptr81, align 4
  %tensor.matmul.cols.ptr83 = getelementptr i64, ptr %tensor.dims78, i64 1
  %tensor.matmul.cols84 = load i64, ptr %tensor.matmul.cols.ptr83, align 4
  %tensor.matmul.count85 = mul i64 %tensor.matmul.rows80, %tensor.matmul.cols84
  %tensor.malloc86 = call ptr @malloc(i64 32)
  %tensor.malloc87 = call ptr @malloc(i64 16)
  %tensor.data.bytes88 = mul i64 %tensor.matmul.count85, 8
  %tensor.malloc89 = call ptr @malloc(i64 %tensor.data.bytes88)
  %tensor.rank.slot90 = getelementptr inbounds %csec.tensor, ptr %tensor.malloc86, i32 0, i32 0
  store i64 2, ptr %tensor.rank.slot90, align 4
  %tensor.dims.slot91 = getelementptr inbounds %csec.tensor, ptr %tensor.malloc86, i32 0, i32 1
  store ptr %tensor.malloc87, ptr %tensor.dims.slot91, align 8
  %tensor.count.slot92 = getelementptr inbounds %csec.tensor, ptr %tensor.malloc86, i32 0, i32 2
  store i64 %tensor.matmul.count85, ptr %tensor.count.slot92, align 4
  %tensor.data.slot93 = getelementptr inbounds %csec.tensor, ptr %tensor.malloc86, i32 0, i32 3
  store ptr %tensor.malloc89, ptr %tensor.data.slot93, align 8
  %tensor.dims.ptr94 = getelementptr inbounds %csec.tensor, ptr %tensor.malloc86, i32 0, i32 1
  %tensor.dims95 = load ptr, ptr %tensor.dims.ptr94, align 8
  %tensor.matmul.dst.rows96 = getelementptr i64, ptr %tensor.dims95, i64 0
  store i64 %tensor.matmul.rows80, ptr %tensor.matmul.dst.rows96, align 4
  %tensor.matmul.dst.cols97 = getelementptr i64, ptr %tensor.dims95, i64 1
  store i64 %tensor.matmul.cols84, ptr %tensor.matmul.dst.cols97, align 4
  %tensor.data.ptr98 = getelementptr inbounds %csec.tensor, ptr %0, i32 0, i32 3
  %tensor.data99 = load ptr, ptr %tensor.data.ptr98, align 8
  %tensor.data.ptr100 = getelementptr inbounds %csec.tensor, ptr %3, i32 0, i32 3
  %tensor.data101 = load ptr, ptr %tensor.data.ptr100, align 8
  %tensor.data.ptr102 = getelementptr inbounds %csec.tensor, ptr %tensor.malloc86, i32 0, i32 3
  %tensor.data103 = load ptr, ptr %tensor.data.ptr102, align 8
  %tensor.matmul.i.i104 = alloca i64, align 8
  store i64 0, ptr %tensor.matmul.i.i104, align 4
  br label %tensor.matmul.i.cond105

tensor.matmul.j.cond47:                           ; preds = %tensor.matmul.k.end56, %tensor.matmul.i.body42
  %tensor.matmul.j.idx50 = load i64, ptr %tensor.matmul.j.i46, align 4
  %tensor.matmul.j.keep51 = icmp ult i64 %tensor.matmul.j.idx50, %tensor.matmul.cols20
  br i1 %tensor.matmul.j.keep51, label %tensor.matmul.j.body48, label %tensor.matmul.j.end49

tensor.matmul.j.body48:                           ; preds = %tensor.matmul.j.cond47
  %tensor.matmul.sum.ptr52 = alloca double, align 8
  store double 0.000000e+00, ptr %tensor.matmul.sum.ptr52, align 8
  %tensor.matmul.k.i53 = alloca i64, align 8
  store i64 0, ptr %tensor.matmul.k.i53, align 4
  br label %tensor.matmul.k.cond54

tensor.matmul.j.end49:                            ; preds = %tensor.matmul.j.cond47
  %tensor.matmul.i.current73 = load i64, ptr %tensor.matmul.i.i40, align 4
  %tensor.matmul.i.next74 = add i64 %tensor.matmul.i.current73, 1
  store i64 %tensor.matmul.i.next74, ptr %tensor.matmul.i.i40, align 4
  br label %tensor.matmul.i.cond41

tensor.matmul.k.cond54:                           ; preds = %tensor.matmul.k.body55, %tensor.matmul.j.body48
  %tensor.matmul.k.idx57 = load i64, ptr %tensor.matmul.k.i53, align 4
  %tensor.matmul.k.keep58 = icmp ult i64 %tensor.matmul.k.idx57, %tensor.matmul.shared18
  br i1 %tensor.matmul.k.keep58, label %tensor.matmul.k.body55, label %tensor.matmul.k.end56

tensor.matmul.k.body55:                           ; preds = %tensor.matmul.k.cond54
  %15 = mul i64 %tensor.matmul.i.idx44, %tensor.matmul.shared18
  %tensor.matmul.left.index59 = add i64 %15, %tensor.matmul.k.idx57
  %16 = mul i64 %tensor.matmul.k.idx57, %tensor.matmul.cols20
  %tensor.matmul.right.index60 = add i64 %16, %tensor.matmul.j.idx50
  %17 = getelementptr double, ptr %tensor.data37, i64 %tensor.matmul.right.index60
  %tensor.matmul.right61 = load double, ptr %17, align 8
  %18 = getelementptr double, ptr %tensor.data35, i64 %tensor.matmul.left.index59
  %tensor.matmul.left62 = load double, ptr %18, align 8
  %tensor.matmul.product63 = fmul double %tensor.matmul.left62, %tensor.matmul.right61
  %tensor.matmul.current64 = load double, ptr %tensor.matmul.sum.ptr52, align 8
  %tensor.matmul.next65 = fadd double %tensor.matmul.current64, %tensor.matmul.product63
  store double %tensor.matmul.next65, ptr %tensor.matmul.sum.ptr52, align 8
  %tensor.matmul.k.current66 = load i64, ptr %tensor.matmul.k.i53, align 4
  %tensor.matmul.k.next67 = add i64 %tensor.matmul.k.current66, 1
  store i64 %tensor.matmul.k.next67, ptr %tensor.matmul.k.i53, align 4
  br label %tensor.matmul.k.cond54

tensor.matmul.k.end56:                            ; preds = %tensor.matmul.k.cond54
  %19 = mul i64 %tensor.matmul.i.idx44, %tensor.matmul.cols20
  %tensor.matmul.dst.index68 = add i64 %19, %tensor.matmul.j.idx50
  %tensor.matmul.dst69 = getelementptr double, ptr %tensor.data39, i64 %tensor.matmul.dst.index68
  %tensor.matmul.sum70 = load double, ptr %tensor.matmul.sum.ptr52, align 8
  store double %tensor.matmul.sum70, ptr %tensor.matmul.dst69, align 8
  %tensor.matmul.j.current71 = load i64, ptr %tensor.matmul.j.i46, align 4
  %tensor.matmul.j.next72 = add i64 %tensor.matmul.j.current71, 1
  store i64 %tensor.matmul.j.next72, ptr %tensor.matmul.j.i46, align 4
  br label %tensor.matmul.j.cond47

tensor.matmul.i.cond105:                          ; preds = %tensor.matmul.j.end113, %tensor.matmul.i.end43
  %tensor.matmul.i.idx108 = load i64, ptr %tensor.matmul.i.i104, align 4
  %tensor.matmul.i.keep109 = icmp ult i64 %tensor.matmul.i.idx108, %tensor.matmul.rows80
  br i1 %tensor.matmul.i.keep109, label %tensor.matmul.i.body106, label %tensor.matmul.i.end107

tensor.matmul.i.body106:                          ; preds = %tensor.matmul.i.cond105
  %tensor.matmul.j.i110 = alloca i64, align 8
  store i64 0, ptr %tensor.matmul.j.i110, align 4
  br label %tensor.matmul.j.cond111

tensor.matmul.i.end107:                           ; preds = %tensor.matmul.i.cond105
  %value = alloca ptr, align 8
  store ptr %tensor.malloc86, ptr %value, align 8
  %query.load = load ptr, ptr %query, align 8
  %key.load = load ptr, ptr %key, align 8
  %value.load = load ptr, ptr %value, align 8
  %calltmp = call ptr @_scaledDotProductAttention(ptr %query.load, ptr %key.load, ptr %value.load)
  %context = alloca ptr, align 8
  store ptr %calltmp, ptr %context, align 8
  %context.load = load ptr, ptr %context, align 8
  %calltmp139 = call ptr @_linear(ptr %context.load, ptr %4, ptr %5)
  %projected = alloca ptr, align 8
  store ptr %calltmp139, ptr %projected, align 8
  %projected.load = load ptr, ptr %projected, align 8
  %calltmp140 = call ptr @_residualAdd(ptr %0, ptr %projected.load)
  %attentionResidual = alloca ptr, align 8
  store ptr %calltmp140, ptr %attentionResidual, align 8
  %attentionResidual.load = load ptr, ptr %attentionResidual, align 8
  %calltmp141 = call ptr @_feedForward(ptr %attentionResidual.load, ptr %6, ptr %7, ptr %8, ptr %9)
  %ffnUpdate = alloca ptr, align 8
  store ptr %calltmp141, ptr %ffnUpdate, align 8
  %attentionResidual.load142 = load ptr, ptr %attentionResidual, align 8
  %ffnUpdate.load = load ptr, ptr %ffnUpdate, align 8
  %calltmp143 = call ptr @_residualAdd(ptr %attentionResidual.load142, ptr %ffnUpdate.load)
  ret ptr %calltmp143

tensor.matmul.j.cond111:                          ; preds = %tensor.matmul.k.end120, %tensor.matmul.i.body106
  %tensor.matmul.j.idx114 = load i64, ptr %tensor.matmul.j.i110, align 4
  %tensor.matmul.j.keep115 = icmp ult i64 %tensor.matmul.j.idx114, %tensor.matmul.cols84
  br i1 %tensor.matmul.j.keep115, label %tensor.matmul.j.body112, label %tensor.matmul.j.end113

tensor.matmul.j.body112:                          ; preds = %tensor.matmul.j.cond111
  %tensor.matmul.sum.ptr116 = alloca double, align 8
  store double 0.000000e+00, ptr %tensor.matmul.sum.ptr116, align 8
  %tensor.matmul.k.i117 = alloca i64, align 8
  store i64 0, ptr %tensor.matmul.k.i117, align 4
  br label %tensor.matmul.k.cond118

tensor.matmul.j.end113:                           ; preds = %tensor.matmul.j.cond111
  %tensor.matmul.i.current137 = load i64, ptr %tensor.matmul.i.i104, align 4
  %tensor.matmul.i.next138 = add i64 %tensor.matmul.i.current137, 1
  store i64 %tensor.matmul.i.next138, ptr %tensor.matmul.i.i104, align 4
  br label %tensor.matmul.i.cond105

tensor.matmul.k.cond118:                          ; preds = %tensor.matmul.k.body119, %tensor.matmul.j.body112
  %tensor.matmul.k.idx121 = load i64, ptr %tensor.matmul.k.i117, align 4
  %tensor.matmul.k.keep122 = icmp ult i64 %tensor.matmul.k.idx121, %tensor.matmul.shared82
  br i1 %tensor.matmul.k.keep122, label %tensor.matmul.k.body119, label %tensor.matmul.k.end120

tensor.matmul.k.body119:                          ; preds = %tensor.matmul.k.cond118
  %20 = mul i64 %tensor.matmul.i.idx108, %tensor.matmul.shared82
  %tensor.matmul.left.index123 = add i64 %20, %tensor.matmul.k.idx121
  %21 = mul i64 %tensor.matmul.k.idx121, %tensor.matmul.cols84
  %tensor.matmul.right.index124 = add i64 %21, %tensor.matmul.j.idx114
  %22 = getelementptr double, ptr %tensor.data101, i64 %tensor.matmul.right.index124
  %tensor.matmul.right125 = load double, ptr %22, align 8
  %23 = getelementptr double, ptr %tensor.data99, i64 %tensor.matmul.left.index123
  %tensor.matmul.left126 = load double, ptr %23, align 8
  %tensor.matmul.product127 = fmul double %tensor.matmul.left126, %tensor.matmul.right125
  %tensor.matmul.current128 = load double, ptr %tensor.matmul.sum.ptr116, align 8
  %tensor.matmul.next129 = fadd double %tensor.matmul.current128, %tensor.matmul.product127
  store double %tensor.matmul.next129, ptr %tensor.matmul.sum.ptr116, align 8
  %tensor.matmul.k.current130 = load i64, ptr %tensor.matmul.k.i117, align 4
  %tensor.matmul.k.next131 = add i64 %tensor.matmul.k.current130, 1
  store i64 %tensor.matmul.k.next131, ptr %tensor.matmul.k.i117, align 4
  br label %tensor.matmul.k.cond118

tensor.matmul.k.end120:                           ; preds = %tensor.matmul.k.cond118
  %24 = mul i64 %tensor.matmul.i.idx108, %tensor.matmul.cols84
  %tensor.matmul.dst.index132 = add i64 %24, %tensor.matmul.j.idx114
  %tensor.matmul.dst133 = getelementptr double, ptr %tensor.data103, i64 %tensor.matmul.dst.index132
  %tensor.matmul.sum134 = load double, ptr %tensor.matmul.sum.ptr116, align 8
  store double %tensor.matmul.sum134, ptr %tensor.matmul.dst133, align 8
  %tensor.matmul.j.current135 = load i64, ptr %tensor.matmul.j.i110, align 4
  %tensor.matmul.j.next136 = add i64 %tensor.matmul.j.current135, 1
  store i64 %tensor.matmul.j.next136, ptr %tensor.matmul.j.i110, align 4
  br label %tensor.matmul.j.cond111
}

define ptr @_transformerEncoder2Layer(ptr %0, ptr %1, ptr %2, ptr %3, ptr %4, ptr %5, ptr %6, ptr %7, ptr %8, ptr %9, ptr %10, ptr %11, ptr %12, ptr %13, ptr %14, ptr %15, ptr %16, ptr %17, ptr %18) {
entry:
  %calltmp = call ptr @_transformerBlock(ptr %0, ptr %1, ptr %2, ptr %3, ptr %4, ptr %5, ptr %6, ptr %7, ptr %8, ptr %9)
  %calltmp1 = call ptr @_transformerBlock(ptr %calltmp, ptr %10, ptr %11, ptr %12, ptr %13, ptr %14, ptr %15, ptr %16, ptr %17, ptr %18)
  ret ptr %calltmp1
}

define double @_mseLoss(ptr %0, ptr %1) {
entry:
  %tensor.rank.ptr = getelementptr inbounds %csec.tensor, ptr %0, i32 0, i32 0
  %tensor.rank = load i64, ptr %tensor.rank.ptr, align 4
  %tensor.dims.ptr = getelementptr inbounds %csec.tensor, ptr %0, i32 0, i32 1
  %tensor.dims = load ptr, ptr %tensor.dims.ptr, align 8
  %tensor.data.ptr = getelementptr inbounds %csec.tensor, ptr %0, i32 0, i32 3
  %tensor.data = load ptr, ptr %tensor.data.ptr, align 8
  %tensor.index.coords = alloca i64, i64 %tensor.rank, align 8
  %tensor.index.coord.slot = getelementptr i64, ptr %tensor.index.coords, i64 0
  store i64 0, ptr %tensor.index.coord.slot, align 4
  %tensor.index.coord.slot1 = getelementptr i64, ptr %tensor.index.coords, i64 1
  store i64 0, ptr %tensor.index.coord.slot1, align 4
  br label %tensor.linear.cond

tensor.linear.cond:                               ; preds = %tensor.linear.body, %entry
  %tensor.linear.i.0 = phi i64 [ 0, %entry ], [ %tensor.linear.next3, %tensor.linear.body ]
  %tensor.linear.ptr.0 = phi i64 [ 0, %entry ], [ %tensor.linear.next, %tensor.linear.body ]
  %tensor.linear.keep = icmp ult i64 %tensor.linear.i.0, %tensor.rank
  br i1 %tensor.linear.keep, label %tensor.linear.body, label %tensor.linear.end

tensor.linear.body:                               ; preds = %tensor.linear.cond
  %tensor.linear.dim.ptr = getelementptr i64, ptr %tensor.dims, i64 %tensor.linear.i.0
  %tensor.linear.dim = load i64, ptr %tensor.linear.dim.ptr, align 4
  %tensor.linear.coord.ptr = getelementptr i64, ptr %tensor.index.coords, i64 %tensor.linear.i.0
  %tensor.linear.coord = load i64, ptr %tensor.linear.coord.ptr, align 4
  %tensor.linear.mul = mul i64 %tensor.linear.ptr.0, %tensor.linear.dim
  %tensor.linear.next = add i64 %tensor.linear.mul, %tensor.linear.coord
  %tensor.linear.next3 = add i64 %tensor.linear.i.0, 1
  br label %tensor.linear.cond

tensor.linear.end:                                ; preds = %tensor.linear.cond
  %tensor.index.data = getelementptr double, ptr %tensor.data, i64 %tensor.linear.ptr.0
  %tensor.index.value = load double, ptr %tensor.index.data, align 8
  %tensor.rank.ptr4 = getelementptr inbounds %csec.tensor, ptr %1, i32 0, i32 0
  %tensor.rank5 = load i64, ptr %tensor.rank.ptr4, align 4
  %tensor.dims.ptr6 = getelementptr inbounds %csec.tensor, ptr %1, i32 0, i32 1
  %tensor.dims7 = load ptr, ptr %tensor.dims.ptr6, align 8
  %tensor.data.ptr8 = getelementptr inbounds %csec.tensor, ptr %1, i32 0, i32 3
  %tensor.data9 = load ptr, ptr %tensor.data.ptr8, align 8
  %tensor.index.coords10 = alloca i64, i64 %tensor.rank5, align 8
  %tensor.index.coord.slot11 = getelementptr i64, ptr %tensor.index.coords10, i64 0
  store i64 0, ptr %tensor.index.coord.slot11, align 4
  %tensor.index.coord.slot12 = getelementptr i64, ptr %tensor.index.coords10, i64 1
  store i64 0, ptr %tensor.index.coord.slot12, align 4
  %tensor.linear.ptr13 = alloca i64, align 8
  store i64 0, ptr %tensor.linear.ptr13, align 4
  %tensor.linear.i14 = alloca i64, align 8
  store i64 0, ptr %tensor.linear.i14, align 4
  br label %tensor.linear.cond15

tensor.linear.cond15:                             ; preds = %tensor.linear.body16, %tensor.linear.end
  %tensor.linear.idx18 = load i64, ptr %tensor.linear.i14, align 4
  %tensor.linear.keep19 = icmp ult i64 %tensor.linear.idx18, %tensor.rank5
  br i1 %tensor.linear.keep19, label %tensor.linear.body16, label %tensor.linear.end17

tensor.linear.body16:                             ; preds = %tensor.linear.cond15
  %tensor.linear.dim.ptr20 = getelementptr i64, ptr %tensor.dims7, i64 %tensor.linear.idx18
  %tensor.linear.dim21 = load i64, ptr %tensor.linear.dim.ptr20, align 4
  %tensor.linear.coord.ptr22 = getelementptr i64, ptr %tensor.index.coords10, i64 %tensor.linear.idx18
  %tensor.linear.coord23 = load i64, ptr %tensor.linear.coord.ptr22, align 4
  %tensor.linear.current24 = load i64, ptr %tensor.linear.ptr13, align 4
  %tensor.linear.mul25 = mul i64 %tensor.linear.current24, %tensor.linear.dim21
  %tensor.linear.next26 = add i64 %tensor.linear.mul25, %tensor.linear.coord23
  store i64 %tensor.linear.next26, ptr %tensor.linear.ptr13, align 4
  %tensor.linear.current27 = load i64, ptr %tensor.linear.i14, align 4
  %tensor.linear.next28 = add i64 %tensor.linear.current27, 1
  store i64 %tensor.linear.next28, ptr %tensor.linear.i14, align 4
  br label %tensor.linear.cond15

tensor.linear.end17:                              ; preds = %tensor.linear.cond15
  %tensor.linear.result29 = load i64, ptr %tensor.linear.ptr13, align 4
  %tensor.index.data30 = getelementptr double, ptr %tensor.data9, i64 %tensor.linear.result29
  %tensor.index.value31 = load double, ptr %tensor.index.data30, align 8
  %fsubtmp = fsub double %tensor.index.value, %tensor.index.value31
  %d00 = alloca double, align 8
  store double %fsubtmp, ptr %d00, align 8
  %tensor.rank.ptr32 = getelementptr inbounds %csec.tensor, ptr %0, i32 0, i32 0
  %tensor.rank33 = load i64, ptr %tensor.rank.ptr32, align 4
  %tensor.dims.ptr34 = getelementptr inbounds %csec.tensor, ptr %0, i32 0, i32 1
  %tensor.dims35 = load ptr, ptr %tensor.dims.ptr34, align 8
  %tensor.data.ptr36 = getelementptr inbounds %csec.tensor, ptr %0, i32 0, i32 3
  %tensor.data37 = load ptr, ptr %tensor.data.ptr36, align 8
  %tensor.index.coords38 = alloca i64, i64 %tensor.rank33, align 8
  %tensor.index.coord.slot39 = getelementptr i64, ptr %tensor.index.coords38, i64 0
  store i64 0, ptr %tensor.index.coord.slot39, align 4
  %tensor.index.coord.slot40 = getelementptr i64, ptr %tensor.index.coords38, i64 1
  store i64 1, ptr %tensor.index.coord.slot40, align 4
  %tensor.linear.ptr41 = alloca i64, align 8
  store i64 0, ptr %tensor.linear.ptr41, align 4
  %tensor.linear.i42 = alloca i64, align 8
  store i64 0, ptr %tensor.linear.i42, align 4
  br label %tensor.linear.cond43

tensor.linear.cond43:                             ; preds = %tensor.linear.body44, %tensor.linear.end17
  %tensor.linear.idx46 = load i64, ptr %tensor.linear.i42, align 4
  %tensor.linear.keep47 = icmp ult i64 %tensor.linear.idx46, %tensor.rank33
  br i1 %tensor.linear.keep47, label %tensor.linear.body44, label %tensor.linear.end45

tensor.linear.body44:                             ; preds = %tensor.linear.cond43
  %tensor.linear.dim.ptr48 = getelementptr i64, ptr %tensor.dims35, i64 %tensor.linear.idx46
  %tensor.linear.dim49 = load i64, ptr %tensor.linear.dim.ptr48, align 4
  %tensor.linear.coord.ptr50 = getelementptr i64, ptr %tensor.index.coords38, i64 %tensor.linear.idx46
  %tensor.linear.coord51 = load i64, ptr %tensor.linear.coord.ptr50, align 4
  %tensor.linear.current52 = load i64, ptr %tensor.linear.ptr41, align 4
  %tensor.linear.mul53 = mul i64 %tensor.linear.current52, %tensor.linear.dim49
  %tensor.linear.next54 = add i64 %tensor.linear.mul53, %tensor.linear.coord51
  store i64 %tensor.linear.next54, ptr %tensor.linear.ptr41, align 4
  %tensor.linear.current55 = load i64, ptr %tensor.linear.i42, align 4
  %tensor.linear.next56 = add i64 %tensor.linear.current55, 1
  store i64 %tensor.linear.next56, ptr %tensor.linear.i42, align 4
  br label %tensor.linear.cond43

tensor.linear.end45:                              ; preds = %tensor.linear.cond43
  %tensor.linear.result57 = load i64, ptr %tensor.linear.ptr41, align 4
  %tensor.index.data58 = getelementptr double, ptr %tensor.data37, i64 %tensor.linear.result57
  %tensor.index.value59 = load double, ptr %tensor.index.data58, align 8
  %tensor.rank.ptr60 = getelementptr inbounds %csec.tensor, ptr %1, i32 0, i32 0
  %tensor.rank61 = load i64, ptr %tensor.rank.ptr60, align 4
  %tensor.dims.ptr62 = getelementptr inbounds %csec.tensor, ptr %1, i32 0, i32 1
  %tensor.dims63 = load ptr, ptr %tensor.dims.ptr62, align 8
  %tensor.data.ptr64 = getelementptr inbounds %csec.tensor, ptr %1, i32 0, i32 3
  %tensor.data65 = load ptr, ptr %tensor.data.ptr64, align 8
  %tensor.index.coords66 = alloca i64, i64 %tensor.rank61, align 8
  %tensor.index.coord.slot67 = getelementptr i64, ptr %tensor.index.coords66, i64 0
  store i64 0, ptr %tensor.index.coord.slot67, align 4
  %tensor.index.coord.slot68 = getelementptr i64, ptr %tensor.index.coords66, i64 1
  store i64 1, ptr %tensor.index.coord.slot68, align 4
  %tensor.linear.ptr69 = alloca i64, align 8
  store i64 0, ptr %tensor.linear.ptr69, align 4
  %tensor.linear.i70 = alloca i64, align 8
  store i64 0, ptr %tensor.linear.i70, align 4
  br label %tensor.linear.cond71

tensor.linear.cond71:                             ; preds = %tensor.linear.body72, %tensor.linear.end45
  %tensor.linear.idx74 = load i64, ptr %tensor.linear.i70, align 4
  %tensor.linear.keep75 = icmp ult i64 %tensor.linear.idx74, %tensor.rank61
  br i1 %tensor.linear.keep75, label %tensor.linear.body72, label %tensor.linear.end73

tensor.linear.body72:                             ; preds = %tensor.linear.cond71
  %tensor.linear.dim.ptr76 = getelementptr i64, ptr %tensor.dims63, i64 %tensor.linear.idx74
  %tensor.linear.dim77 = load i64, ptr %tensor.linear.dim.ptr76, align 4
  %tensor.linear.coord.ptr78 = getelementptr i64, ptr %tensor.index.coords66, i64 %tensor.linear.idx74
  %tensor.linear.coord79 = load i64, ptr %tensor.linear.coord.ptr78, align 4
  %tensor.linear.current80 = load i64, ptr %tensor.linear.ptr69, align 4
  %tensor.linear.mul81 = mul i64 %tensor.linear.current80, %tensor.linear.dim77
  %tensor.linear.next82 = add i64 %tensor.linear.mul81, %tensor.linear.coord79
  store i64 %tensor.linear.next82, ptr %tensor.linear.ptr69, align 4
  %tensor.linear.current83 = load i64, ptr %tensor.linear.i70, align 4
  %tensor.linear.next84 = add i64 %tensor.linear.current83, 1
  store i64 %tensor.linear.next84, ptr %tensor.linear.i70, align 4
  br label %tensor.linear.cond71

tensor.linear.end73:                              ; preds = %tensor.linear.cond71
  %tensor.linear.result85 = load i64, ptr %tensor.linear.ptr69, align 4
  %tensor.index.data86 = getelementptr double, ptr %tensor.data65, i64 %tensor.linear.result85
  %tensor.index.value87 = load double, ptr %tensor.index.data86, align 8
  %fsubtmp88 = fsub double %tensor.index.value59, %tensor.index.value87
  %d01 = alloca double, align 8
  store double %fsubtmp88, ptr %d01, align 8
  %tensor.rank.ptr89 = getelementptr inbounds %csec.tensor, ptr %0, i32 0, i32 0
  %tensor.rank90 = load i64, ptr %tensor.rank.ptr89, align 4
  %tensor.dims.ptr91 = getelementptr inbounds %csec.tensor, ptr %0, i32 0, i32 1
  %tensor.dims92 = load ptr, ptr %tensor.dims.ptr91, align 8
  %tensor.data.ptr93 = getelementptr inbounds %csec.tensor, ptr %0, i32 0, i32 3
  %tensor.data94 = load ptr, ptr %tensor.data.ptr93, align 8
  %tensor.index.coords95 = alloca i64, i64 %tensor.rank90, align 8
  %tensor.index.coord.slot96 = getelementptr i64, ptr %tensor.index.coords95, i64 0
  store i64 0, ptr %tensor.index.coord.slot96, align 4
  %tensor.index.coord.slot97 = getelementptr i64, ptr %tensor.index.coords95, i64 1
  store i64 2, ptr %tensor.index.coord.slot97, align 4
  %tensor.linear.ptr98 = alloca i64, align 8
  store i64 0, ptr %tensor.linear.ptr98, align 4
  %tensor.linear.i99 = alloca i64, align 8
  store i64 0, ptr %tensor.linear.i99, align 4
  br label %tensor.linear.cond100

tensor.linear.cond100:                            ; preds = %tensor.linear.body101, %tensor.linear.end73
  %tensor.linear.idx103 = load i64, ptr %tensor.linear.i99, align 4
  %tensor.linear.keep104 = icmp ult i64 %tensor.linear.idx103, %tensor.rank90
  br i1 %tensor.linear.keep104, label %tensor.linear.body101, label %tensor.linear.end102

tensor.linear.body101:                            ; preds = %tensor.linear.cond100
  %tensor.linear.dim.ptr105 = getelementptr i64, ptr %tensor.dims92, i64 %tensor.linear.idx103
  %tensor.linear.dim106 = load i64, ptr %tensor.linear.dim.ptr105, align 4
  %tensor.linear.coord.ptr107 = getelementptr i64, ptr %tensor.index.coords95, i64 %tensor.linear.idx103
  %tensor.linear.coord108 = load i64, ptr %tensor.linear.coord.ptr107, align 4
  %tensor.linear.current109 = load i64, ptr %tensor.linear.ptr98, align 4
  %tensor.linear.mul110 = mul i64 %tensor.linear.current109, %tensor.linear.dim106
  %tensor.linear.next111 = add i64 %tensor.linear.mul110, %tensor.linear.coord108
  store i64 %tensor.linear.next111, ptr %tensor.linear.ptr98, align 4
  %tensor.linear.current112 = load i64, ptr %tensor.linear.i99, align 4
  %tensor.linear.next113 = add i64 %tensor.linear.current112, 1
  store i64 %tensor.linear.next113, ptr %tensor.linear.i99, align 4
  br label %tensor.linear.cond100

tensor.linear.end102:                             ; preds = %tensor.linear.cond100
  %tensor.linear.result114 = load i64, ptr %tensor.linear.ptr98, align 4
  %tensor.index.data115 = getelementptr double, ptr %tensor.data94, i64 %tensor.linear.result114
  %tensor.index.value116 = load double, ptr %tensor.index.data115, align 8
  %tensor.rank.ptr117 = getelementptr inbounds %csec.tensor, ptr %1, i32 0, i32 0
  %tensor.rank118 = load i64, ptr %tensor.rank.ptr117, align 4
  %tensor.dims.ptr119 = getelementptr inbounds %csec.tensor, ptr %1, i32 0, i32 1
  %tensor.dims120 = load ptr, ptr %tensor.dims.ptr119, align 8
  %tensor.data.ptr121 = getelementptr inbounds %csec.tensor, ptr %1, i32 0, i32 3
  %tensor.data122 = load ptr, ptr %tensor.data.ptr121, align 8
  %tensor.index.coords123 = alloca i64, i64 %tensor.rank118, align 8
  %tensor.index.coord.slot124 = getelementptr i64, ptr %tensor.index.coords123, i64 0
  store i64 0, ptr %tensor.index.coord.slot124, align 4
  %tensor.index.coord.slot125 = getelementptr i64, ptr %tensor.index.coords123, i64 1
  store i64 2, ptr %tensor.index.coord.slot125, align 4
  %tensor.linear.ptr126 = alloca i64, align 8
  store i64 0, ptr %tensor.linear.ptr126, align 4
  %tensor.linear.i127 = alloca i64, align 8
  store i64 0, ptr %tensor.linear.i127, align 4
  br label %tensor.linear.cond128

tensor.linear.cond128:                            ; preds = %tensor.linear.body129, %tensor.linear.end102
  %tensor.linear.idx131 = load i64, ptr %tensor.linear.i127, align 4
  %tensor.linear.keep132 = icmp ult i64 %tensor.linear.idx131, %tensor.rank118
  br i1 %tensor.linear.keep132, label %tensor.linear.body129, label %tensor.linear.end130

tensor.linear.body129:                            ; preds = %tensor.linear.cond128
  %tensor.linear.dim.ptr133 = getelementptr i64, ptr %tensor.dims120, i64 %tensor.linear.idx131
  %tensor.linear.dim134 = load i64, ptr %tensor.linear.dim.ptr133, align 4
  %tensor.linear.coord.ptr135 = getelementptr i64, ptr %tensor.index.coords123, i64 %tensor.linear.idx131
  %tensor.linear.coord136 = load i64, ptr %tensor.linear.coord.ptr135, align 4
  %tensor.linear.current137 = load i64, ptr %tensor.linear.ptr126, align 4
  %tensor.linear.mul138 = mul i64 %tensor.linear.current137, %tensor.linear.dim134
  %tensor.linear.next139 = add i64 %tensor.linear.mul138, %tensor.linear.coord136
  store i64 %tensor.linear.next139, ptr %tensor.linear.ptr126, align 4
  %tensor.linear.current140 = load i64, ptr %tensor.linear.i127, align 4
  %tensor.linear.next141 = add i64 %tensor.linear.current140, 1
  store i64 %tensor.linear.next141, ptr %tensor.linear.i127, align 4
  br label %tensor.linear.cond128

tensor.linear.end130:                             ; preds = %tensor.linear.cond128
  %tensor.linear.result142 = load i64, ptr %tensor.linear.ptr126, align 4
  %tensor.index.data143 = getelementptr double, ptr %tensor.data122, i64 %tensor.linear.result142
  %tensor.index.value144 = load double, ptr %tensor.index.data143, align 8
  %fsubtmp145 = fsub double %tensor.index.value116, %tensor.index.value144
  %d02 = alloca double, align 8
  store double %fsubtmp145, ptr %d02, align 8
  %tensor.rank.ptr146 = getelementptr inbounds %csec.tensor, ptr %0, i32 0, i32 0
  %tensor.rank147 = load i64, ptr %tensor.rank.ptr146, align 4
  %tensor.dims.ptr148 = getelementptr inbounds %csec.tensor, ptr %0, i32 0, i32 1
  %tensor.dims149 = load ptr, ptr %tensor.dims.ptr148, align 8
  %tensor.data.ptr150 = getelementptr inbounds %csec.tensor, ptr %0, i32 0, i32 3
  %tensor.data151 = load ptr, ptr %tensor.data.ptr150, align 8
  %tensor.index.coords152 = alloca i64, i64 %tensor.rank147, align 8
  %tensor.index.coord.slot153 = getelementptr i64, ptr %tensor.index.coords152, i64 0
  store i64 0, ptr %tensor.index.coord.slot153, align 4
  %tensor.index.coord.slot154 = getelementptr i64, ptr %tensor.index.coords152, i64 1
  store i64 3, ptr %tensor.index.coord.slot154, align 4
  %tensor.linear.ptr155 = alloca i64, align 8
  store i64 0, ptr %tensor.linear.ptr155, align 4
  %tensor.linear.i156 = alloca i64, align 8
  store i64 0, ptr %tensor.linear.i156, align 4
  br label %tensor.linear.cond157

tensor.linear.cond157:                            ; preds = %tensor.linear.body158, %tensor.linear.end130
  %tensor.linear.idx160 = load i64, ptr %tensor.linear.i156, align 4
  %tensor.linear.keep161 = icmp ult i64 %tensor.linear.idx160, %tensor.rank147
  br i1 %tensor.linear.keep161, label %tensor.linear.body158, label %tensor.linear.end159

tensor.linear.body158:                            ; preds = %tensor.linear.cond157
  %tensor.linear.dim.ptr162 = getelementptr i64, ptr %tensor.dims149, i64 %tensor.linear.idx160
  %tensor.linear.dim163 = load i64, ptr %tensor.linear.dim.ptr162, align 4
  %tensor.linear.coord.ptr164 = getelementptr i64, ptr %tensor.index.coords152, i64 %tensor.linear.idx160
  %tensor.linear.coord165 = load i64, ptr %tensor.linear.coord.ptr164, align 4
  %tensor.linear.current166 = load i64, ptr %tensor.linear.ptr155, align 4
  %tensor.linear.mul167 = mul i64 %tensor.linear.current166, %tensor.linear.dim163
  %tensor.linear.next168 = add i64 %tensor.linear.mul167, %tensor.linear.coord165
  store i64 %tensor.linear.next168, ptr %tensor.linear.ptr155, align 4
  %tensor.linear.current169 = load i64, ptr %tensor.linear.i156, align 4
  %tensor.linear.next170 = add i64 %tensor.linear.current169, 1
  store i64 %tensor.linear.next170, ptr %tensor.linear.i156, align 4
  br label %tensor.linear.cond157

tensor.linear.end159:                             ; preds = %tensor.linear.cond157
  %tensor.linear.result171 = load i64, ptr %tensor.linear.ptr155, align 4
  %tensor.index.data172 = getelementptr double, ptr %tensor.data151, i64 %tensor.linear.result171
  %tensor.index.value173 = load double, ptr %tensor.index.data172, align 8
  %tensor.rank.ptr174 = getelementptr inbounds %csec.tensor, ptr %1, i32 0, i32 0
  %tensor.rank175 = load i64, ptr %tensor.rank.ptr174, align 4
  %tensor.dims.ptr176 = getelementptr inbounds %csec.tensor, ptr %1, i32 0, i32 1
  %tensor.dims177 = load ptr, ptr %tensor.dims.ptr176, align 8
  %tensor.data.ptr178 = getelementptr inbounds %csec.tensor, ptr %1, i32 0, i32 3
  %tensor.data179 = load ptr, ptr %tensor.data.ptr178, align 8
  %tensor.index.coords180 = alloca i64, i64 %tensor.rank175, align 8
  %tensor.index.coord.slot181 = getelementptr i64, ptr %tensor.index.coords180, i64 0
  store i64 0, ptr %tensor.index.coord.slot181, align 4
  %tensor.index.coord.slot182 = getelementptr i64, ptr %tensor.index.coords180, i64 1
  store i64 3, ptr %tensor.index.coord.slot182, align 4
  %tensor.linear.ptr183 = alloca i64, align 8
  store i64 0, ptr %tensor.linear.ptr183, align 4
  %tensor.linear.i184 = alloca i64, align 8
  store i64 0, ptr %tensor.linear.i184, align 4
  br label %tensor.linear.cond185

tensor.linear.cond185:                            ; preds = %tensor.linear.body186, %tensor.linear.end159
  %tensor.linear.idx188 = load i64, ptr %tensor.linear.i184, align 4
  %tensor.linear.keep189 = icmp ult i64 %tensor.linear.idx188, %tensor.rank175
  br i1 %tensor.linear.keep189, label %tensor.linear.body186, label %tensor.linear.end187

tensor.linear.body186:                            ; preds = %tensor.linear.cond185
  %tensor.linear.dim.ptr190 = getelementptr i64, ptr %tensor.dims177, i64 %tensor.linear.idx188
  %tensor.linear.dim191 = load i64, ptr %tensor.linear.dim.ptr190, align 4
  %tensor.linear.coord.ptr192 = getelementptr i64, ptr %tensor.index.coords180, i64 %tensor.linear.idx188
  %tensor.linear.coord193 = load i64, ptr %tensor.linear.coord.ptr192, align 4
  %tensor.linear.current194 = load i64, ptr %tensor.linear.ptr183, align 4
  %tensor.linear.mul195 = mul i64 %tensor.linear.current194, %tensor.linear.dim191
  %tensor.linear.next196 = add i64 %tensor.linear.mul195, %tensor.linear.coord193
  store i64 %tensor.linear.next196, ptr %tensor.linear.ptr183, align 4
  %tensor.linear.current197 = load i64, ptr %tensor.linear.i184, align 4
  %tensor.linear.next198 = add i64 %tensor.linear.current197, 1
  store i64 %tensor.linear.next198, ptr %tensor.linear.i184, align 4
  br label %tensor.linear.cond185

tensor.linear.end187:                             ; preds = %tensor.linear.cond185
  %tensor.linear.result199 = load i64, ptr %tensor.linear.ptr183, align 4
  %tensor.index.data200 = getelementptr double, ptr %tensor.data179, i64 %tensor.linear.result199
  %tensor.index.value201 = load double, ptr %tensor.index.data200, align 8
  %fsubtmp202 = fsub double %tensor.index.value173, %tensor.index.value201
  %d03 = alloca double, align 8
  store double %fsubtmp202, ptr %d03, align 8
  %tensor.rank.ptr203 = getelementptr inbounds %csec.tensor, ptr %0, i32 0, i32 0
  %tensor.rank204 = load i64, ptr %tensor.rank.ptr203, align 4
  %tensor.dims.ptr205 = getelementptr inbounds %csec.tensor, ptr %0, i32 0, i32 1
  %tensor.dims206 = load ptr, ptr %tensor.dims.ptr205, align 8
  %tensor.data.ptr207 = getelementptr inbounds %csec.tensor, ptr %0, i32 0, i32 3
  %tensor.data208 = load ptr, ptr %tensor.data.ptr207, align 8
  %tensor.index.coords209 = alloca i64, i64 %tensor.rank204, align 8
  %tensor.index.coord.slot210 = getelementptr i64, ptr %tensor.index.coords209, i64 0
  store i64 1, ptr %tensor.index.coord.slot210, align 4
  %tensor.index.coord.slot211 = getelementptr i64, ptr %tensor.index.coords209, i64 1
  store i64 0, ptr %tensor.index.coord.slot211, align 4
  %tensor.linear.ptr212 = alloca i64, align 8
  store i64 0, ptr %tensor.linear.ptr212, align 4
  %tensor.linear.i213 = alloca i64, align 8
  store i64 0, ptr %tensor.linear.i213, align 4
  br label %tensor.linear.cond214

tensor.linear.cond214:                            ; preds = %tensor.linear.body215, %tensor.linear.end187
  %tensor.linear.idx217 = load i64, ptr %tensor.linear.i213, align 4
  %tensor.linear.keep218 = icmp ult i64 %tensor.linear.idx217, %tensor.rank204
  br i1 %tensor.linear.keep218, label %tensor.linear.body215, label %tensor.linear.end216

tensor.linear.body215:                            ; preds = %tensor.linear.cond214
  %tensor.linear.dim.ptr219 = getelementptr i64, ptr %tensor.dims206, i64 %tensor.linear.idx217
  %tensor.linear.dim220 = load i64, ptr %tensor.linear.dim.ptr219, align 4
  %tensor.linear.coord.ptr221 = getelementptr i64, ptr %tensor.index.coords209, i64 %tensor.linear.idx217
  %tensor.linear.coord222 = load i64, ptr %tensor.linear.coord.ptr221, align 4
  %tensor.linear.current223 = load i64, ptr %tensor.linear.ptr212, align 4
  %tensor.linear.mul224 = mul i64 %tensor.linear.current223, %tensor.linear.dim220
  %tensor.linear.next225 = add i64 %tensor.linear.mul224, %tensor.linear.coord222
  store i64 %tensor.linear.next225, ptr %tensor.linear.ptr212, align 4
  %tensor.linear.current226 = load i64, ptr %tensor.linear.i213, align 4
  %tensor.linear.next227 = add i64 %tensor.linear.current226, 1
  store i64 %tensor.linear.next227, ptr %tensor.linear.i213, align 4
  br label %tensor.linear.cond214

tensor.linear.end216:                             ; preds = %tensor.linear.cond214
  %tensor.linear.result228 = load i64, ptr %tensor.linear.ptr212, align 4
  %tensor.index.data229 = getelementptr double, ptr %tensor.data208, i64 %tensor.linear.result228
  %tensor.index.value230 = load double, ptr %tensor.index.data229, align 8
  %tensor.rank.ptr231 = getelementptr inbounds %csec.tensor, ptr %1, i32 0, i32 0
  %tensor.rank232 = load i64, ptr %tensor.rank.ptr231, align 4
  %tensor.dims.ptr233 = getelementptr inbounds %csec.tensor, ptr %1, i32 0, i32 1
  %tensor.dims234 = load ptr, ptr %tensor.dims.ptr233, align 8
  %tensor.data.ptr235 = getelementptr inbounds %csec.tensor, ptr %1, i32 0, i32 3
  %tensor.data236 = load ptr, ptr %tensor.data.ptr235, align 8
  %tensor.index.coords237 = alloca i64, i64 %tensor.rank232, align 8
  %tensor.index.coord.slot238 = getelementptr i64, ptr %tensor.index.coords237, i64 0
  store i64 1, ptr %tensor.index.coord.slot238, align 4
  %tensor.index.coord.slot239 = getelementptr i64, ptr %tensor.index.coords237, i64 1
  store i64 0, ptr %tensor.index.coord.slot239, align 4
  %tensor.linear.ptr240 = alloca i64, align 8
  store i64 0, ptr %tensor.linear.ptr240, align 4
  %tensor.linear.i241 = alloca i64, align 8
  store i64 0, ptr %tensor.linear.i241, align 4
  br label %tensor.linear.cond242

tensor.linear.cond242:                            ; preds = %tensor.linear.body243, %tensor.linear.end216
  %tensor.linear.idx245 = load i64, ptr %tensor.linear.i241, align 4
  %tensor.linear.keep246 = icmp ult i64 %tensor.linear.idx245, %tensor.rank232
  br i1 %tensor.linear.keep246, label %tensor.linear.body243, label %tensor.linear.end244

tensor.linear.body243:                            ; preds = %tensor.linear.cond242
  %tensor.linear.dim.ptr247 = getelementptr i64, ptr %tensor.dims234, i64 %tensor.linear.idx245
  %tensor.linear.dim248 = load i64, ptr %tensor.linear.dim.ptr247, align 4
  %tensor.linear.coord.ptr249 = getelementptr i64, ptr %tensor.index.coords237, i64 %tensor.linear.idx245
  %tensor.linear.coord250 = load i64, ptr %tensor.linear.coord.ptr249, align 4
  %tensor.linear.current251 = load i64, ptr %tensor.linear.ptr240, align 4
  %tensor.linear.mul252 = mul i64 %tensor.linear.current251, %tensor.linear.dim248
  %tensor.linear.next253 = add i64 %tensor.linear.mul252, %tensor.linear.coord250
  store i64 %tensor.linear.next253, ptr %tensor.linear.ptr240, align 4
  %tensor.linear.current254 = load i64, ptr %tensor.linear.i241, align 4
  %tensor.linear.next255 = add i64 %tensor.linear.current254, 1
  store i64 %tensor.linear.next255, ptr %tensor.linear.i241, align 4
  br label %tensor.linear.cond242

tensor.linear.end244:                             ; preds = %tensor.linear.cond242
  %tensor.linear.result256 = load i64, ptr %tensor.linear.ptr240, align 4
  %tensor.index.data257 = getelementptr double, ptr %tensor.data236, i64 %tensor.linear.result256
  %tensor.index.value258 = load double, ptr %tensor.index.data257, align 8
  %fsubtmp259 = fsub double %tensor.index.value230, %tensor.index.value258
  %d10 = alloca double, align 8
  store double %fsubtmp259, ptr %d10, align 8
  %tensor.rank.ptr260 = getelementptr inbounds %csec.tensor, ptr %0, i32 0, i32 0
  %tensor.rank261 = load i64, ptr %tensor.rank.ptr260, align 4
  %tensor.dims.ptr262 = getelementptr inbounds %csec.tensor, ptr %0, i32 0, i32 1
  %tensor.dims263 = load ptr, ptr %tensor.dims.ptr262, align 8
  %tensor.data.ptr264 = getelementptr inbounds %csec.tensor, ptr %0, i32 0, i32 3
  %tensor.data265 = load ptr, ptr %tensor.data.ptr264, align 8
  %tensor.index.coords266 = alloca i64, i64 %tensor.rank261, align 8
  %tensor.index.coord.slot267 = getelementptr i64, ptr %tensor.index.coords266, i64 0
  store i64 1, ptr %tensor.index.coord.slot267, align 4
  %tensor.index.coord.slot268 = getelementptr i64, ptr %tensor.index.coords266, i64 1
  store i64 1, ptr %tensor.index.coord.slot268, align 4
  %tensor.linear.ptr269 = alloca i64, align 8
  store i64 0, ptr %tensor.linear.ptr269, align 4
  %tensor.linear.i270 = alloca i64, align 8
  store i64 0, ptr %tensor.linear.i270, align 4
  br label %tensor.linear.cond271

tensor.linear.cond271:                            ; preds = %tensor.linear.body272, %tensor.linear.end244
  %tensor.linear.idx274 = load i64, ptr %tensor.linear.i270, align 4
  %tensor.linear.keep275 = icmp ult i64 %tensor.linear.idx274, %tensor.rank261
  br i1 %tensor.linear.keep275, label %tensor.linear.body272, label %tensor.linear.end273

tensor.linear.body272:                            ; preds = %tensor.linear.cond271
  %tensor.linear.dim.ptr276 = getelementptr i64, ptr %tensor.dims263, i64 %tensor.linear.idx274
  %tensor.linear.dim277 = load i64, ptr %tensor.linear.dim.ptr276, align 4
  %tensor.linear.coord.ptr278 = getelementptr i64, ptr %tensor.index.coords266, i64 %tensor.linear.idx274
  %tensor.linear.coord279 = load i64, ptr %tensor.linear.coord.ptr278, align 4
  %tensor.linear.current280 = load i64, ptr %tensor.linear.ptr269, align 4
  %tensor.linear.mul281 = mul i64 %tensor.linear.current280, %tensor.linear.dim277
  %tensor.linear.next282 = add i64 %tensor.linear.mul281, %tensor.linear.coord279
  store i64 %tensor.linear.next282, ptr %tensor.linear.ptr269, align 4
  %tensor.linear.current283 = load i64, ptr %tensor.linear.i270, align 4
  %tensor.linear.next284 = add i64 %tensor.linear.current283, 1
  store i64 %tensor.linear.next284, ptr %tensor.linear.i270, align 4
  br label %tensor.linear.cond271

tensor.linear.end273:                             ; preds = %tensor.linear.cond271
  %tensor.linear.result285 = load i64, ptr %tensor.linear.ptr269, align 4
  %tensor.index.data286 = getelementptr double, ptr %tensor.data265, i64 %tensor.linear.result285
  %tensor.index.value287 = load double, ptr %tensor.index.data286, align 8
  %tensor.rank.ptr288 = getelementptr inbounds %csec.tensor, ptr %1, i32 0, i32 0
  %tensor.rank289 = load i64, ptr %tensor.rank.ptr288, align 4
  %tensor.dims.ptr290 = getelementptr inbounds %csec.tensor, ptr %1, i32 0, i32 1
  %tensor.dims291 = load ptr, ptr %tensor.dims.ptr290, align 8
  %tensor.data.ptr292 = getelementptr inbounds %csec.tensor, ptr %1, i32 0, i32 3
  %tensor.data293 = load ptr, ptr %tensor.data.ptr292, align 8
  %tensor.index.coords294 = alloca i64, i64 %tensor.rank289, align 8
  %tensor.index.coord.slot295 = getelementptr i64, ptr %tensor.index.coords294, i64 0
  store i64 1, ptr %tensor.index.coord.slot295, align 4
  %tensor.index.coord.slot296 = getelementptr i64, ptr %tensor.index.coords294, i64 1
  store i64 1, ptr %tensor.index.coord.slot296, align 4
  %tensor.linear.ptr297 = alloca i64, align 8
  store i64 0, ptr %tensor.linear.ptr297, align 4
  %tensor.linear.i298 = alloca i64, align 8
  store i64 0, ptr %tensor.linear.i298, align 4
  br label %tensor.linear.cond299

tensor.linear.cond299:                            ; preds = %tensor.linear.body300, %tensor.linear.end273
  %tensor.linear.idx302 = load i64, ptr %tensor.linear.i298, align 4
  %tensor.linear.keep303 = icmp ult i64 %tensor.linear.idx302, %tensor.rank289
  br i1 %tensor.linear.keep303, label %tensor.linear.body300, label %tensor.linear.end301

tensor.linear.body300:                            ; preds = %tensor.linear.cond299
  %tensor.linear.dim.ptr304 = getelementptr i64, ptr %tensor.dims291, i64 %tensor.linear.idx302
  %tensor.linear.dim305 = load i64, ptr %tensor.linear.dim.ptr304, align 4
  %tensor.linear.coord.ptr306 = getelementptr i64, ptr %tensor.index.coords294, i64 %tensor.linear.idx302
  %tensor.linear.coord307 = load i64, ptr %tensor.linear.coord.ptr306, align 4
  %tensor.linear.current308 = load i64, ptr %tensor.linear.ptr297, align 4
  %tensor.linear.mul309 = mul i64 %tensor.linear.current308, %tensor.linear.dim305
  %tensor.linear.next310 = add i64 %tensor.linear.mul309, %tensor.linear.coord307
  store i64 %tensor.linear.next310, ptr %tensor.linear.ptr297, align 4
  %tensor.linear.current311 = load i64, ptr %tensor.linear.i298, align 4
  %tensor.linear.next312 = add i64 %tensor.linear.current311, 1
  store i64 %tensor.linear.next312, ptr %tensor.linear.i298, align 4
  br label %tensor.linear.cond299

tensor.linear.end301:                             ; preds = %tensor.linear.cond299
  %tensor.linear.result313 = load i64, ptr %tensor.linear.ptr297, align 4
  %tensor.index.data314 = getelementptr double, ptr %tensor.data293, i64 %tensor.linear.result313
  %tensor.index.value315 = load double, ptr %tensor.index.data314, align 8
  %fsubtmp316 = fsub double %tensor.index.value287, %tensor.index.value315
  %d11 = alloca double, align 8
  store double %fsubtmp316, ptr %d11, align 8
  %tensor.rank.ptr317 = getelementptr inbounds %csec.tensor, ptr %0, i32 0, i32 0
  %tensor.rank318 = load i64, ptr %tensor.rank.ptr317, align 4
  %tensor.dims.ptr319 = getelementptr inbounds %csec.tensor, ptr %0, i32 0, i32 1
  %tensor.dims320 = load ptr, ptr %tensor.dims.ptr319, align 8
  %tensor.data.ptr321 = getelementptr inbounds %csec.tensor, ptr %0, i32 0, i32 3
  %tensor.data322 = load ptr, ptr %tensor.data.ptr321, align 8
  %tensor.index.coords323 = alloca i64, i64 %tensor.rank318, align 8
  %tensor.index.coord.slot324 = getelementptr i64, ptr %tensor.index.coords323, i64 0
  store i64 1, ptr %tensor.index.coord.slot324, align 4
  %tensor.index.coord.slot325 = getelementptr i64, ptr %tensor.index.coords323, i64 1
  store i64 2, ptr %tensor.index.coord.slot325, align 4
  %tensor.linear.ptr326 = alloca i64, align 8
  store i64 0, ptr %tensor.linear.ptr326, align 4
  %tensor.linear.i327 = alloca i64, align 8
  store i64 0, ptr %tensor.linear.i327, align 4
  br label %tensor.linear.cond328

tensor.linear.cond328:                            ; preds = %tensor.linear.body329, %tensor.linear.end301
  %tensor.linear.idx331 = load i64, ptr %tensor.linear.i327, align 4
  %tensor.linear.keep332 = icmp ult i64 %tensor.linear.idx331, %tensor.rank318
  br i1 %tensor.linear.keep332, label %tensor.linear.body329, label %tensor.linear.end330

tensor.linear.body329:                            ; preds = %tensor.linear.cond328
  %tensor.linear.dim.ptr333 = getelementptr i64, ptr %tensor.dims320, i64 %tensor.linear.idx331
  %tensor.linear.dim334 = load i64, ptr %tensor.linear.dim.ptr333, align 4
  %tensor.linear.coord.ptr335 = getelementptr i64, ptr %tensor.index.coords323, i64 %tensor.linear.idx331
  %tensor.linear.coord336 = load i64, ptr %tensor.linear.coord.ptr335, align 4
  %tensor.linear.current337 = load i64, ptr %tensor.linear.ptr326, align 4
  %tensor.linear.mul338 = mul i64 %tensor.linear.current337, %tensor.linear.dim334
  %tensor.linear.next339 = add i64 %tensor.linear.mul338, %tensor.linear.coord336
  store i64 %tensor.linear.next339, ptr %tensor.linear.ptr326, align 4
  %tensor.linear.current340 = load i64, ptr %tensor.linear.i327, align 4
  %tensor.linear.next341 = add i64 %tensor.linear.current340, 1
  store i64 %tensor.linear.next341, ptr %tensor.linear.i327, align 4
  br label %tensor.linear.cond328

tensor.linear.end330:                             ; preds = %tensor.linear.cond328
  %tensor.linear.result342 = load i64, ptr %tensor.linear.ptr326, align 4
  %tensor.index.data343 = getelementptr double, ptr %tensor.data322, i64 %tensor.linear.result342
  %tensor.index.value344 = load double, ptr %tensor.index.data343, align 8
  %tensor.rank.ptr345 = getelementptr inbounds %csec.tensor, ptr %1, i32 0, i32 0
  %tensor.rank346 = load i64, ptr %tensor.rank.ptr345, align 4
  %tensor.dims.ptr347 = getelementptr inbounds %csec.tensor, ptr %1, i32 0, i32 1
  %tensor.dims348 = load ptr, ptr %tensor.dims.ptr347, align 8
  %tensor.data.ptr349 = getelementptr inbounds %csec.tensor, ptr %1, i32 0, i32 3
  %tensor.data350 = load ptr, ptr %tensor.data.ptr349, align 8
  %tensor.index.coords351 = alloca i64, i64 %tensor.rank346, align 8
  %tensor.index.coord.slot352 = getelementptr i64, ptr %tensor.index.coords351, i64 0
  store i64 1, ptr %tensor.index.coord.slot352, align 4
  %tensor.index.coord.slot353 = getelementptr i64, ptr %tensor.index.coords351, i64 1
  store i64 2, ptr %tensor.index.coord.slot353, align 4
  %tensor.linear.ptr354 = alloca i64, align 8
  store i64 0, ptr %tensor.linear.ptr354, align 4
  %tensor.linear.i355 = alloca i64, align 8
  store i64 0, ptr %tensor.linear.i355, align 4
  br label %tensor.linear.cond356

tensor.linear.cond356:                            ; preds = %tensor.linear.body357, %tensor.linear.end330
  %tensor.linear.idx359 = load i64, ptr %tensor.linear.i355, align 4
  %tensor.linear.keep360 = icmp ult i64 %tensor.linear.idx359, %tensor.rank346
  br i1 %tensor.linear.keep360, label %tensor.linear.body357, label %tensor.linear.end358

tensor.linear.body357:                            ; preds = %tensor.linear.cond356
  %tensor.linear.dim.ptr361 = getelementptr i64, ptr %tensor.dims348, i64 %tensor.linear.idx359
  %tensor.linear.dim362 = load i64, ptr %tensor.linear.dim.ptr361, align 4
  %tensor.linear.coord.ptr363 = getelementptr i64, ptr %tensor.index.coords351, i64 %tensor.linear.idx359
  %tensor.linear.coord364 = load i64, ptr %tensor.linear.coord.ptr363, align 4
  %tensor.linear.current365 = load i64, ptr %tensor.linear.ptr354, align 4
  %tensor.linear.mul366 = mul i64 %tensor.linear.current365, %tensor.linear.dim362
  %tensor.linear.next367 = add i64 %tensor.linear.mul366, %tensor.linear.coord364
  store i64 %tensor.linear.next367, ptr %tensor.linear.ptr354, align 4
  %tensor.linear.current368 = load i64, ptr %tensor.linear.i355, align 4
  %tensor.linear.next369 = add i64 %tensor.linear.current368, 1
  store i64 %tensor.linear.next369, ptr %tensor.linear.i355, align 4
  br label %tensor.linear.cond356

tensor.linear.end358:                             ; preds = %tensor.linear.cond356
  %tensor.linear.result370 = load i64, ptr %tensor.linear.ptr354, align 4
  %tensor.index.data371 = getelementptr double, ptr %tensor.data350, i64 %tensor.linear.result370
  %tensor.index.value372 = load double, ptr %tensor.index.data371, align 8
  %fsubtmp373 = fsub double %tensor.index.value344, %tensor.index.value372
  %d12 = alloca double, align 8
  store double %fsubtmp373, ptr %d12, align 8
  %tensor.rank.ptr374 = getelementptr inbounds %csec.tensor, ptr %0, i32 0, i32 0
  %tensor.rank375 = load i64, ptr %tensor.rank.ptr374, align 4
  %tensor.dims.ptr376 = getelementptr inbounds %csec.tensor, ptr %0, i32 0, i32 1
  %tensor.dims377 = load ptr, ptr %tensor.dims.ptr376, align 8
  %tensor.data.ptr378 = getelementptr inbounds %csec.tensor, ptr %0, i32 0, i32 3
  %tensor.data379 = load ptr, ptr %tensor.data.ptr378, align 8
  %tensor.index.coords380 = alloca i64, i64 %tensor.rank375, align 8
  %tensor.index.coord.slot381 = getelementptr i64, ptr %tensor.index.coords380, i64 0
  store i64 1, ptr %tensor.index.coord.slot381, align 4
  %tensor.index.coord.slot382 = getelementptr i64, ptr %tensor.index.coords380, i64 1
  store i64 3, ptr %tensor.index.coord.slot382, align 4
  %tensor.linear.ptr383 = alloca i64, align 8
  store i64 0, ptr %tensor.linear.ptr383, align 4
  %tensor.linear.i384 = alloca i64, align 8
  store i64 0, ptr %tensor.linear.i384, align 4
  br label %tensor.linear.cond385

tensor.linear.cond385:                            ; preds = %tensor.linear.body386, %tensor.linear.end358
  %tensor.linear.idx388 = load i64, ptr %tensor.linear.i384, align 4
  %tensor.linear.keep389 = icmp ult i64 %tensor.linear.idx388, %tensor.rank375
  br i1 %tensor.linear.keep389, label %tensor.linear.body386, label %tensor.linear.end387

tensor.linear.body386:                            ; preds = %tensor.linear.cond385
  %tensor.linear.dim.ptr390 = getelementptr i64, ptr %tensor.dims377, i64 %tensor.linear.idx388
  %tensor.linear.dim391 = load i64, ptr %tensor.linear.dim.ptr390, align 4
  %tensor.linear.coord.ptr392 = getelementptr i64, ptr %tensor.index.coords380, i64 %tensor.linear.idx388
  %tensor.linear.coord393 = load i64, ptr %tensor.linear.coord.ptr392, align 4
  %tensor.linear.current394 = load i64, ptr %tensor.linear.ptr383, align 4
  %tensor.linear.mul395 = mul i64 %tensor.linear.current394, %tensor.linear.dim391
  %tensor.linear.next396 = add i64 %tensor.linear.mul395, %tensor.linear.coord393
  store i64 %tensor.linear.next396, ptr %tensor.linear.ptr383, align 4
  %tensor.linear.current397 = load i64, ptr %tensor.linear.i384, align 4
  %tensor.linear.next398 = add i64 %tensor.linear.current397, 1
  store i64 %tensor.linear.next398, ptr %tensor.linear.i384, align 4
  br label %tensor.linear.cond385

tensor.linear.end387:                             ; preds = %tensor.linear.cond385
  %tensor.linear.result399 = load i64, ptr %tensor.linear.ptr383, align 4
  %tensor.index.data400 = getelementptr double, ptr %tensor.data379, i64 %tensor.linear.result399
  %tensor.index.value401 = load double, ptr %tensor.index.data400, align 8
  %tensor.rank.ptr402 = getelementptr inbounds %csec.tensor, ptr %1, i32 0, i32 0
  %tensor.rank403 = load i64, ptr %tensor.rank.ptr402, align 4
  %tensor.dims.ptr404 = getelementptr inbounds %csec.tensor, ptr %1, i32 0, i32 1
  %tensor.dims405 = load ptr, ptr %tensor.dims.ptr404, align 8
  %tensor.data.ptr406 = getelementptr inbounds %csec.tensor, ptr %1, i32 0, i32 3
  %tensor.data407 = load ptr, ptr %tensor.data.ptr406, align 8
  %tensor.index.coords408 = alloca i64, i64 %tensor.rank403, align 8
  %tensor.index.coord.slot409 = getelementptr i64, ptr %tensor.index.coords408, i64 0
  store i64 1, ptr %tensor.index.coord.slot409, align 4
  %tensor.index.coord.slot410 = getelementptr i64, ptr %tensor.index.coords408, i64 1
  store i64 3, ptr %tensor.index.coord.slot410, align 4
  %tensor.linear.ptr411 = alloca i64, align 8
  store i64 0, ptr %tensor.linear.ptr411, align 4
  %tensor.linear.i412 = alloca i64, align 8
  store i64 0, ptr %tensor.linear.i412, align 4
  br label %tensor.linear.cond413

tensor.linear.cond413:                            ; preds = %tensor.linear.body414, %tensor.linear.end387
  %tensor.linear.idx416 = load i64, ptr %tensor.linear.i412, align 4
  %tensor.linear.keep417 = icmp ult i64 %tensor.linear.idx416, %tensor.rank403
  br i1 %tensor.linear.keep417, label %tensor.linear.body414, label %tensor.linear.end415

tensor.linear.body414:                            ; preds = %tensor.linear.cond413
  %tensor.linear.dim.ptr418 = getelementptr i64, ptr %tensor.dims405, i64 %tensor.linear.idx416
  %tensor.linear.dim419 = load i64, ptr %tensor.linear.dim.ptr418, align 4
  %tensor.linear.coord.ptr420 = getelementptr i64, ptr %tensor.index.coords408, i64 %tensor.linear.idx416
  %tensor.linear.coord421 = load i64, ptr %tensor.linear.coord.ptr420, align 4
  %tensor.linear.current422 = load i64, ptr %tensor.linear.ptr411, align 4
  %tensor.linear.mul423 = mul i64 %tensor.linear.current422, %tensor.linear.dim419
  %tensor.linear.next424 = add i64 %tensor.linear.mul423, %tensor.linear.coord421
  store i64 %tensor.linear.next424, ptr %tensor.linear.ptr411, align 4
  %tensor.linear.current425 = load i64, ptr %tensor.linear.i412, align 4
  %tensor.linear.next426 = add i64 %tensor.linear.current425, 1
  store i64 %tensor.linear.next426, ptr %tensor.linear.i412, align 4
  br label %tensor.linear.cond413

tensor.linear.end415:                             ; preds = %tensor.linear.cond413
  %tensor.linear.result427 = load i64, ptr %tensor.linear.ptr411, align 4
  %tensor.index.data428 = getelementptr double, ptr %tensor.data407, i64 %tensor.linear.result427
  %tensor.index.value429 = load double, ptr %tensor.index.data428, align 8
  %fsubtmp430 = fsub double %tensor.index.value401, %tensor.index.value429
  %d13 = alloca double, align 8
  store double %fsubtmp430, ptr %d13, align 8
  %d00.load = load double, ptr %d00, align 8
  %d00.load431 = load double, ptr %d00, align 8
  %fmultmp = fmul double %d00.load, %d00.load431
  %d01.load = load double, ptr %d01, align 8
  %d01.load432 = load double, ptr %d01, align 8
  %fmultmp433 = fmul double %d01.load, %d01.load432
  %faddtmp = fadd double %fmultmp, %fmultmp433
  %d02.load = load double, ptr %d02, align 8
  %d02.load434 = load double, ptr %d02, align 8
  %fmultmp435 = fmul double %d02.load, %d02.load434
  %faddtmp436 = fadd double %faddtmp, %fmultmp435
  %d03.load = load double, ptr %d03, align 8
  %d03.load437 = load double, ptr %d03, align 8
  %fmultmp438 = fmul double %d03.load, %d03.load437
  %faddtmp439 = fadd double %faddtmp436, %fmultmp438
  %d10.load = load double, ptr %d10, align 8
  %d10.load440 = load double, ptr %d10, align 8
  %fmultmp441 = fmul double %d10.load, %d10.load440
  %faddtmp442 = fadd double %faddtmp439, %fmultmp441
  %d11.load = load double, ptr %d11, align 8
  %d11.load443 = load double, ptr %d11, align 8
  %fmultmp444 = fmul double %d11.load, %d11.load443
  %faddtmp445 = fadd double %faddtmp442, %fmultmp444
  %d12.load = load double, ptr %d12, align 8
  %d12.load446 = load double, ptr %d12, align 8
  %fmultmp447 = fmul double %d12.load, %d12.load446
  %faddtmp448 = fadd double %faddtmp445, %fmultmp447
  %d13.load = load double, ptr %d13, align 8
  %d13.load449 = load double, ptr %d13, align 8
  %fmultmp450 = fmul double %d13.load, %d13.load449
  %faddtmp451 = fadd double %faddtmp448, %fmultmp450
  %fdivtmp = fdiv double %faddtmp451, 8.000000e+00
  ret double %fdivtmp
}

define ptr @_sgd4x4(ptr %0, double %1, double %2) {
entry:
  %fmultmp = fmul double %1, %2
  %tensor.malloc = call ptr @malloc(i64 32)
  %tensor.malloc1 = call ptr @malloc(i64 16)
  %tensor.malloc2 = call ptr @malloc(i64 128)
  %tensor.rank.slot = getelementptr inbounds %csec.tensor, ptr %tensor.malloc, i32 0, i32 0
  store i64 2, ptr %tensor.rank.slot, align 4
  %tensor.dims.slot = getelementptr inbounds %csec.tensor, ptr %tensor.malloc, i32 0, i32 1
  store ptr %tensor.malloc1, ptr %tensor.dims.slot, align 8
  %tensor.count.slot = getelementptr inbounds %csec.tensor, ptr %tensor.malloc, i32 0, i32 2
  store i64 16, ptr %tensor.count.slot, align 4
  %tensor.data.slot = getelementptr inbounds %csec.tensor, ptr %tensor.malloc, i32 0, i32 3
  store ptr %tensor.malloc2, ptr %tensor.data.slot, align 8
  %tensor.dims.ptr = getelementptr inbounds %csec.tensor, ptr %tensor.malloc, i32 0, i32 1
  %tensor.dims = load ptr, ptr %tensor.dims.ptr, align 8
  %tensor.data.ptr = getelementptr inbounds %csec.tensor, ptr %tensor.malloc, i32 0, i32 3
  %tensor.data = load ptr, ptr %tensor.data.ptr, align 8
  %tensor.dim.slot = getelementptr i64, ptr %tensor.dims, i64 0
  store i64 4, ptr %tensor.dim.slot, align 4
  %tensor.dim.slot3 = getelementptr i64, ptr %tensor.dims, i64 1
  store i64 4, ptr %tensor.dim.slot3, align 4
  br label %tensor.fill.cond

tensor.fill.cond:                                 ; preds = %tensor.fill.body, %entry
  %tensor.fill.i.0 = phi i64 [ 0, %entry ], [ %tensor.fill.next, %tensor.fill.body ]
  %tensor.fill.keep = icmp ult i64 %tensor.fill.i.0, 16
  br i1 %tensor.fill.keep, label %tensor.fill.body, label %tensor.fill.end

tensor.fill.body:                                 ; preds = %tensor.fill.cond
  %tensor.data.slot4 = getelementptr double, ptr %tensor.data, i64 %tensor.fill.i.0
  store double %fmultmp, ptr %tensor.data.slot4, align 8
  %tensor.fill.next = add i64 %tensor.fill.i.0, 1
  br label %tensor.fill.cond

tensor.fill.end:                                  ; preds = %tensor.fill.cond
  %tensor.rank.ptr = getelementptr inbounds %csec.tensor, ptr %0, i32 0, i32 0
  %tensor.rank = load i64, ptr %tensor.rank.ptr, align 4
  %tensor.count.ptr = getelementptr inbounds %csec.tensor, ptr %0, i32 0, i32 2
  %tensor.count = load i64, ptr %tensor.count.ptr, align 4
  %tensor.malloc5 = call ptr @malloc(i64 32)
  %tensor.dims.bytes = mul i64 %tensor.rank, 8
  %tensor.malloc6 = call ptr @malloc(i64 %tensor.dims.bytes)
  %tensor.data.bytes = mul i64 %tensor.count, 8
  %tensor.malloc7 = call ptr @malloc(i64 %tensor.data.bytes)
  %tensor.rank.slot8 = getelementptr inbounds %csec.tensor, ptr %tensor.malloc5, i32 0, i32 0
  store i64 %tensor.rank, ptr %tensor.rank.slot8, align 4
  %tensor.dims.slot9 = getelementptr inbounds %csec.tensor, ptr %tensor.malloc5, i32 0, i32 1
  store ptr %tensor.malloc6, ptr %tensor.dims.slot9, align 8
  %tensor.count.slot10 = getelementptr inbounds %csec.tensor, ptr %tensor.malloc5, i32 0, i32 2
  store i64 %tensor.count, ptr %tensor.count.slot10, align 4
  %tensor.data.slot11 = getelementptr inbounds %csec.tensor, ptr %tensor.malloc5, i32 0, i32 3
  store ptr %tensor.malloc7, ptr %tensor.data.slot11, align 8
  %tensor.dims.ptr12 = getelementptr inbounds %csec.tensor, ptr %0, i32 0, i32 1
  %tensor.dims13 = load ptr, ptr %tensor.dims.ptr12, align 8
  %tensor.dims.ptr14 = getelementptr inbounds %csec.tensor, ptr %tensor.malloc5, i32 0, i32 1
  %tensor.dims15 = load ptr, ptr %tensor.dims.ptr14, align 8
  %tensor.data.ptr16 = getelementptr inbounds %csec.tensor, ptr %0, i32 0, i32 3
  %tensor.data17 = load ptr, ptr %tensor.data.ptr16, align 8
  %tensor.data.ptr18 = getelementptr inbounds %csec.tensor, ptr %tensor.malloc, i32 0, i32 3
  %tensor.data19 = load ptr, ptr %tensor.data.ptr18, align 8
  %tensor.data.ptr20 = getelementptr inbounds %csec.tensor, ptr %tensor.malloc5, i32 0, i32 3
  %tensor.data21 = load ptr, ptr %tensor.data.ptr20, align 8
  %tensor.elem.dims.i = alloca i64, align 8
  store i64 0, ptr %tensor.elem.dims.i, align 4
  br label %tensor.elem.dims.cond

tensor.elem.dims.cond:                            ; preds = %tensor.elem.dims.body, %tensor.fill.end
  %tensor.elem.dims.idx = load i64, ptr %tensor.elem.dims.i, align 4
  %tensor.elem.dims.keep = icmp ult i64 %tensor.elem.dims.idx, %tensor.rank
  br i1 %tensor.elem.dims.keep, label %tensor.elem.dims.body, label %tensor.elem.dims.end

tensor.elem.dims.body:                            ; preds = %tensor.elem.dims.cond
  %tensor.elem.src.dim = getelementptr i64, ptr %tensor.dims13, i64 %tensor.elem.dims.idx
  %tensor.elem.dst.dim = getelementptr i64, ptr %tensor.dims15, i64 %tensor.elem.dims.idx
  %tensor.elem.dim = load i64, ptr %tensor.elem.src.dim, align 4
  store i64 %tensor.elem.dim, ptr %tensor.elem.dst.dim, align 4
  %tensor.elem.dims.current = load i64, ptr %tensor.elem.dims.i, align 4
  %tensor.elem.dims.next = add i64 %tensor.elem.dims.current, 1
  store i64 %tensor.elem.dims.next, ptr %tensor.elem.dims.i, align 4
  br label %tensor.elem.dims.cond

tensor.elem.dims.end:                             ; preds = %tensor.elem.dims.cond
  %tensor.elem.data.i = alloca i64, align 8
  store i64 0, ptr %tensor.elem.data.i, align 4
  br label %tensor.elem.data.cond

tensor.elem.data.cond:                            ; preds = %tensor.elem.data.body, %tensor.elem.dims.end
  %tensor.elem.data.idx = load i64, ptr %tensor.elem.data.i, align 4
  %tensor.elem.data.keep = icmp ult i64 %tensor.elem.data.idx, %tensor.count
  br i1 %tensor.elem.data.keep, label %tensor.elem.data.body, label %tensor.elem.data.end

tensor.elem.data.body:                            ; preds = %tensor.elem.data.cond
  %tensor.elem.left = getelementptr double, ptr %tensor.data17, i64 %tensor.elem.data.idx
  %tensor.elem.l = load double, ptr %tensor.elem.left, align 8
  %tensor.elem.right = getelementptr double, ptr %tensor.data19, i64 %tensor.elem.data.idx
  %tensor.elem.r = load double, ptr %tensor.elem.right, align 8
  %tensor.elem.dst = getelementptr double, ptr %tensor.data21, i64 %tensor.elem.data.idx
  %tensor.sub = fsub double %tensor.elem.l, %tensor.elem.r
  store double %tensor.sub, ptr %tensor.elem.dst, align 8
  %tensor.elem.data.current = load i64, ptr %tensor.elem.data.i, align 4
  %tensor.elem.data.next = add i64 %tensor.elem.data.current, 1
  store i64 %tensor.elem.data.next, ptr %tensor.elem.data.i, align 4
  br label %tensor.elem.data.cond

tensor.elem.data.end:                             ; preds = %tensor.elem.data.cond
  ret ptr %tensor.malloc5
}

define ptr @_sgd4x8(ptr %0, double %1, double %2) {
entry:
  %fmultmp = fmul double %1, %2
  %tensor.malloc = call ptr @malloc(i64 32)
  %tensor.malloc1 = call ptr @malloc(i64 16)
  %tensor.malloc2 = call ptr @malloc(i64 256)
  %tensor.rank.slot = getelementptr inbounds %csec.tensor, ptr %tensor.malloc, i32 0, i32 0
  store i64 2, ptr %tensor.rank.slot, align 4
  %tensor.dims.slot = getelementptr inbounds %csec.tensor, ptr %tensor.malloc, i32 0, i32 1
  store ptr %tensor.malloc1, ptr %tensor.dims.slot, align 8
  %tensor.count.slot = getelementptr inbounds %csec.tensor, ptr %tensor.malloc, i32 0, i32 2
  store i64 32, ptr %tensor.count.slot, align 4
  %tensor.data.slot = getelementptr inbounds %csec.tensor, ptr %tensor.malloc, i32 0, i32 3
  store ptr %tensor.malloc2, ptr %tensor.data.slot, align 8
  %tensor.dims.ptr = getelementptr inbounds %csec.tensor, ptr %tensor.malloc, i32 0, i32 1
  %tensor.dims = load ptr, ptr %tensor.dims.ptr, align 8
  %tensor.data.ptr = getelementptr inbounds %csec.tensor, ptr %tensor.malloc, i32 0, i32 3
  %tensor.data = load ptr, ptr %tensor.data.ptr, align 8
  %tensor.dim.slot = getelementptr i64, ptr %tensor.dims, i64 0
  store i64 4, ptr %tensor.dim.slot, align 4
  %tensor.dim.slot3 = getelementptr i64, ptr %tensor.dims, i64 1
  store i64 8, ptr %tensor.dim.slot3, align 4
  br label %tensor.fill.cond

tensor.fill.cond:                                 ; preds = %tensor.fill.body, %entry
  %tensor.fill.i.0 = phi i64 [ 0, %entry ], [ %tensor.fill.next, %tensor.fill.body ]
  %tensor.fill.keep = icmp ult i64 %tensor.fill.i.0, 32
  br i1 %tensor.fill.keep, label %tensor.fill.body, label %tensor.fill.end

tensor.fill.body:                                 ; preds = %tensor.fill.cond
  %tensor.data.slot4 = getelementptr double, ptr %tensor.data, i64 %tensor.fill.i.0
  store double %fmultmp, ptr %tensor.data.slot4, align 8
  %tensor.fill.next = add i64 %tensor.fill.i.0, 1
  br label %tensor.fill.cond

tensor.fill.end:                                  ; preds = %tensor.fill.cond
  %tensor.rank.ptr = getelementptr inbounds %csec.tensor, ptr %0, i32 0, i32 0
  %tensor.rank = load i64, ptr %tensor.rank.ptr, align 4
  %tensor.count.ptr = getelementptr inbounds %csec.tensor, ptr %0, i32 0, i32 2
  %tensor.count = load i64, ptr %tensor.count.ptr, align 4
  %tensor.malloc5 = call ptr @malloc(i64 32)
  %tensor.dims.bytes = mul i64 %tensor.rank, 8
  %tensor.malloc6 = call ptr @malloc(i64 %tensor.dims.bytes)
  %tensor.data.bytes = mul i64 %tensor.count, 8
  %tensor.malloc7 = call ptr @malloc(i64 %tensor.data.bytes)
  %tensor.rank.slot8 = getelementptr inbounds %csec.tensor, ptr %tensor.malloc5, i32 0, i32 0
  store i64 %tensor.rank, ptr %tensor.rank.slot8, align 4
  %tensor.dims.slot9 = getelementptr inbounds %csec.tensor, ptr %tensor.malloc5, i32 0, i32 1
  store ptr %tensor.malloc6, ptr %tensor.dims.slot9, align 8
  %tensor.count.slot10 = getelementptr inbounds %csec.tensor, ptr %tensor.malloc5, i32 0, i32 2
  store i64 %tensor.count, ptr %tensor.count.slot10, align 4
  %tensor.data.slot11 = getelementptr inbounds %csec.tensor, ptr %tensor.malloc5, i32 0, i32 3
  store ptr %tensor.malloc7, ptr %tensor.data.slot11, align 8
  %tensor.dims.ptr12 = getelementptr inbounds %csec.tensor, ptr %0, i32 0, i32 1
  %tensor.dims13 = load ptr, ptr %tensor.dims.ptr12, align 8
  %tensor.dims.ptr14 = getelementptr inbounds %csec.tensor, ptr %tensor.malloc5, i32 0, i32 1
  %tensor.dims15 = load ptr, ptr %tensor.dims.ptr14, align 8
  %tensor.data.ptr16 = getelementptr inbounds %csec.tensor, ptr %0, i32 0, i32 3
  %tensor.data17 = load ptr, ptr %tensor.data.ptr16, align 8
  %tensor.data.ptr18 = getelementptr inbounds %csec.tensor, ptr %tensor.malloc, i32 0, i32 3
  %tensor.data19 = load ptr, ptr %tensor.data.ptr18, align 8
  %tensor.data.ptr20 = getelementptr inbounds %csec.tensor, ptr %tensor.malloc5, i32 0, i32 3
  %tensor.data21 = load ptr, ptr %tensor.data.ptr20, align 8
  %tensor.elem.dims.i = alloca i64, align 8
  store i64 0, ptr %tensor.elem.dims.i, align 4
  br label %tensor.elem.dims.cond

tensor.elem.dims.cond:                            ; preds = %tensor.elem.dims.body, %tensor.fill.end
  %tensor.elem.dims.idx = load i64, ptr %tensor.elem.dims.i, align 4
  %tensor.elem.dims.keep = icmp ult i64 %tensor.elem.dims.idx, %tensor.rank
  br i1 %tensor.elem.dims.keep, label %tensor.elem.dims.body, label %tensor.elem.dims.end

tensor.elem.dims.body:                            ; preds = %tensor.elem.dims.cond
  %tensor.elem.src.dim = getelementptr i64, ptr %tensor.dims13, i64 %tensor.elem.dims.idx
  %tensor.elem.dst.dim = getelementptr i64, ptr %tensor.dims15, i64 %tensor.elem.dims.idx
  %tensor.elem.dim = load i64, ptr %tensor.elem.src.dim, align 4
  store i64 %tensor.elem.dim, ptr %tensor.elem.dst.dim, align 4
  %tensor.elem.dims.current = load i64, ptr %tensor.elem.dims.i, align 4
  %tensor.elem.dims.next = add i64 %tensor.elem.dims.current, 1
  store i64 %tensor.elem.dims.next, ptr %tensor.elem.dims.i, align 4
  br label %tensor.elem.dims.cond

tensor.elem.dims.end:                             ; preds = %tensor.elem.dims.cond
  %tensor.elem.data.i = alloca i64, align 8
  store i64 0, ptr %tensor.elem.data.i, align 4
  br label %tensor.elem.data.cond

tensor.elem.data.cond:                            ; preds = %tensor.elem.data.body, %tensor.elem.dims.end
  %tensor.elem.data.idx = load i64, ptr %tensor.elem.data.i, align 4
  %tensor.elem.data.keep = icmp ult i64 %tensor.elem.data.idx, %tensor.count
  br i1 %tensor.elem.data.keep, label %tensor.elem.data.body, label %tensor.elem.data.end

tensor.elem.data.body:                            ; preds = %tensor.elem.data.cond
  %tensor.elem.left = getelementptr double, ptr %tensor.data17, i64 %tensor.elem.data.idx
  %tensor.elem.l = load double, ptr %tensor.elem.left, align 8
  %tensor.elem.right = getelementptr double, ptr %tensor.data19, i64 %tensor.elem.data.idx
  %tensor.elem.r = load double, ptr %tensor.elem.right, align 8
  %tensor.elem.dst = getelementptr double, ptr %tensor.data21, i64 %tensor.elem.data.idx
  %tensor.sub = fsub double %tensor.elem.l, %tensor.elem.r
  store double %tensor.sub, ptr %tensor.elem.dst, align 8
  %tensor.elem.data.current = load i64, ptr %tensor.elem.data.i, align 4
  %tensor.elem.data.next = add i64 %tensor.elem.data.current, 1
  store i64 %tensor.elem.data.next, ptr %tensor.elem.data.i, align 4
  br label %tensor.elem.data.cond

tensor.elem.data.end:                             ; preds = %tensor.elem.data.cond
  ret ptr %tensor.malloc5
}

define ptr @_sgd8x4(ptr %0, double %1, double %2) {
entry:
  %fmultmp = fmul double %1, %2
  %tensor.malloc = call ptr @malloc(i64 32)
  %tensor.malloc1 = call ptr @malloc(i64 16)
  %tensor.malloc2 = call ptr @malloc(i64 256)
  %tensor.rank.slot = getelementptr inbounds %csec.tensor, ptr %tensor.malloc, i32 0, i32 0
  store i64 2, ptr %tensor.rank.slot, align 4
  %tensor.dims.slot = getelementptr inbounds %csec.tensor, ptr %tensor.malloc, i32 0, i32 1
  store ptr %tensor.malloc1, ptr %tensor.dims.slot, align 8
  %tensor.count.slot = getelementptr inbounds %csec.tensor, ptr %tensor.malloc, i32 0, i32 2
  store i64 32, ptr %tensor.count.slot, align 4
  %tensor.data.slot = getelementptr inbounds %csec.tensor, ptr %tensor.malloc, i32 0, i32 3
  store ptr %tensor.malloc2, ptr %tensor.data.slot, align 8
  %tensor.dims.ptr = getelementptr inbounds %csec.tensor, ptr %tensor.malloc, i32 0, i32 1
  %tensor.dims = load ptr, ptr %tensor.dims.ptr, align 8
  %tensor.data.ptr = getelementptr inbounds %csec.tensor, ptr %tensor.malloc, i32 0, i32 3
  %tensor.data = load ptr, ptr %tensor.data.ptr, align 8
  %tensor.dim.slot = getelementptr i64, ptr %tensor.dims, i64 0
  store i64 8, ptr %tensor.dim.slot, align 4
  %tensor.dim.slot3 = getelementptr i64, ptr %tensor.dims, i64 1
  store i64 4, ptr %tensor.dim.slot3, align 4
  br label %tensor.fill.cond

tensor.fill.cond:                                 ; preds = %tensor.fill.body, %entry
  %tensor.fill.i.0 = phi i64 [ 0, %entry ], [ %tensor.fill.next, %tensor.fill.body ]
  %tensor.fill.keep = icmp ult i64 %tensor.fill.i.0, 32
  br i1 %tensor.fill.keep, label %tensor.fill.body, label %tensor.fill.end

tensor.fill.body:                                 ; preds = %tensor.fill.cond
  %tensor.data.slot4 = getelementptr double, ptr %tensor.data, i64 %tensor.fill.i.0
  store double %fmultmp, ptr %tensor.data.slot4, align 8
  %tensor.fill.next = add i64 %tensor.fill.i.0, 1
  br label %tensor.fill.cond

tensor.fill.end:                                  ; preds = %tensor.fill.cond
  %tensor.rank.ptr = getelementptr inbounds %csec.tensor, ptr %0, i32 0, i32 0
  %tensor.rank = load i64, ptr %tensor.rank.ptr, align 4
  %tensor.count.ptr = getelementptr inbounds %csec.tensor, ptr %0, i32 0, i32 2
  %tensor.count = load i64, ptr %tensor.count.ptr, align 4
  %tensor.malloc5 = call ptr @malloc(i64 32)
  %tensor.dims.bytes = mul i64 %tensor.rank, 8
  %tensor.malloc6 = call ptr @malloc(i64 %tensor.dims.bytes)
  %tensor.data.bytes = mul i64 %tensor.count, 8
  %tensor.malloc7 = call ptr @malloc(i64 %tensor.data.bytes)
  %tensor.rank.slot8 = getelementptr inbounds %csec.tensor, ptr %tensor.malloc5, i32 0, i32 0
  store i64 %tensor.rank, ptr %tensor.rank.slot8, align 4
  %tensor.dims.slot9 = getelementptr inbounds %csec.tensor, ptr %tensor.malloc5, i32 0, i32 1
  store ptr %tensor.malloc6, ptr %tensor.dims.slot9, align 8
  %tensor.count.slot10 = getelementptr inbounds %csec.tensor, ptr %tensor.malloc5, i32 0, i32 2
  store i64 %tensor.count, ptr %tensor.count.slot10, align 4
  %tensor.data.slot11 = getelementptr inbounds %csec.tensor, ptr %tensor.malloc5, i32 0, i32 3
  store ptr %tensor.malloc7, ptr %tensor.data.slot11, align 8
  %tensor.dims.ptr12 = getelementptr inbounds %csec.tensor, ptr %0, i32 0, i32 1
  %tensor.dims13 = load ptr, ptr %tensor.dims.ptr12, align 8
  %tensor.dims.ptr14 = getelementptr inbounds %csec.tensor, ptr %tensor.malloc5, i32 0, i32 1
  %tensor.dims15 = load ptr, ptr %tensor.dims.ptr14, align 8
  %tensor.data.ptr16 = getelementptr inbounds %csec.tensor, ptr %0, i32 0, i32 3
  %tensor.data17 = load ptr, ptr %tensor.data.ptr16, align 8
  %tensor.data.ptr18 = getelementptr inbounds %csec.tensor, ptr %tensor.malloc, i32 0, i32 3
  %tensor.data19 = load ptr, ptr %tensor.data.ptr18, align 8
  %tensor.data.ptr20 = getelementptr inbounds %csec.tensor, ptr %tensor.malloc5, i32 0, i32 3
  %tensor.data21 = load ptr, ptr %tensor.data.ptr20, align 8
  %tensor.elem.dims.i = alloca i64, align 8
  store i64 0, ptr %tensor.elem.dims.i, align 4
  br label %tensor.elem.dims.cond

tensor.elem.dims.cond:                            ; preds = %tensor.elem.dims.body, %tensor.fill.end
  %tensor.elem.dims.idx = load i64, ptr %tensor.elem.dims.i, align 4
  %tensor.elem.dims.keep = icmp ult i64 %tensor.elem.dims.idx, %tensor.rank
  br i1 %tensor.elem.dims.keep, label %tensor.elem.dims.body, label %tensor.elem.dims.end

tensor.elem.dims.body:                            ; preds = %tensor.elem.dims.cond
  %tensor.elem.src.dim = getelementptr i64, ptr %tensor.dims13, i64 %tensor.elem.dims.idx
  %tensor.elem.dst.dim = getelementptr i64, ptr %tensor.dims15, i64 %tensor.elem.dims.idx
  %tensor.elem.dim = load i64, ptr %tensor.elem.src.dim, align 4
  store i64 %tensor.elem.dim, ptr %tensor.elem.dst.dim, align 4
  %tensor.elem.dims.current = load i64, ptr %tensor.elem.dims.i, align 4
  %tensor.elem.dims.next = add i64 %tensor.elem.dims.current, 1
  store i64 %tensor.elem.dims.next, ptr %tensor.elem.dims.i, align 4
  br label %tensor.elem.dims.cond

tensor.elem.dims.end:                             ; preds = %tensor.elem.dims.cond
  %tensor.elem.data.i = alloca i64, align 8
  store i64 0, ptr %tensor.elem.data.i, align 4
  br label %tensor.elem.data.cond

tensor.elem.data.cond:                            ; preds = %tensor.elem.data.body, %tensor.elem.dims.end
  %tensor.elem.data.idx = load i64, ptr %tensor.elem.data.i, align 4
  %tensor.elem.data.keep = icmp ult i64 %tensor.elem.data.idx, %tensor.count
  br i1 %tensor.elem.data.keep, label %tensor.elem.data.body, label %tensor.elem.data.end

tensor.elem.data.body:                            ; preds = %tensor.elem.data.cond
  %tensor.elem.left = getelementptr double, ptr %tensor.data17, i64 %tensor.elem.data.idx
  %tensor.elem.l = load double, ptr %tensor.elem.left, align 8
  %tensor.elem.right = getelementptr double, ptr %tensor.data19, i64 %tensor.elem.data.idx
  %tensor.elem.r = load double, ptr %tensor.elem.right, align 8
  %tensor.elem.dst = getelementptr double, ptr %tensor.data21, i64 %tensor.elem.data.idx
  %tensor.sub = fsub double %tensor.elem.l, %tensor.elem.r
  store double %tensor.sub, ptr %tensor.elem.dst, align 8
  %tensor.elem.data.current = load i64, ptr %tensor.elem.data.i, align 4
  %tensor.elem.data.next = add i64 %tensor.elem.data.current, 1
  store i64 %tensor.elem.data.next, ptr %tensor.elem.data.i, align 4
  br label %tensor.elem.data.cond

tensor.elem.data.end:                             ; preds = %tensor.elem.data.cond
  ret ptr %tensor.malloc5
}

define i32 @_main() {
entry:
  %calltmp = call double @_randomInit(double 1.000000e+00)
  %tensor.malloc = call ptr @malloc(i64 32)
  %tensor.malloc1 = call ptr @malloc(i64 16)
  %tensor.malloc2 = call ptr @malloc(i64 64)
  %tensor.rank.slot = getelementptr inbounds %csec.tensor, ptr %tensor.malloc, i32 0, i32 0
  store i64 2, ptr %tensor.rank.slot, align 4
  %tensor.dims.slot = getelementptr inbounds %csec.tensor, ptr %tensor.malloc, i32 0, i32 1
  store ptr %tensor.malloc1, ptr %tensor.dims.slot, align 8
  %tensor.count.slot = getelementptr inbounds %csec.tensor, ptr %tensor.malloc, i32 0, i32 2
  store i64 8, ptr %tensor.count.slot, align 4
  %tensor.data.slot = getelementptr inbounds %csec.tensor, ptr %tensor.malloc, i32 0, i32 3
  store ptr %tensor.malloc2, ptr %tensor.data.slot, align 8
  %tensor.dims.ptr = getelementptr inbounds %csec.tensor, ptr %tensor.malloc, i32 0, i32 1
  %tensor.dims = load ptr, ptr %tensor.dims.ptr, align 8
  %tensor.data.ptr = getelementptr inbounds %csec.tensor, ptr %tensor.malloc, i32 0, i32 3
  %tensor.data = load ptr, ptr %tensor.data.ptr, align 8
  %tensor.dim.slot = getelementptr i64, ptr %tensor.dims, i64 0
  store i64 2, ptr %tensor.dim.slot, align 4
  %tensor.dim.slot3 = getelementptr i64, ptr %tensor.dims, i64 1
  store i64 4, ptr %tensor.dim.slot3, align 4
  br label %tensor.fill.cond

tensor.fill.cond:                                 ; preds = %tensor.fill.body, %entry
  %tensor.fill.i.0 = phi i64 [ 0, %entry ], [ %tensor.fill.next, %tensor.fill.body ]
  %tensor.fill.keep = icmp ult i64 %tensor.fill.i.0, 8
  br i1 %tensor.fill.keep, label %tensor.fill.body, label %tensor.fill.end

tensor.fill.body:                                 ; preds = %tensor.fill.cond
  %tensor.data.slot4 = getelementptr double, ptr %tensor.data, i64 %tensor.fill.i.0
  store double %calltmp, ptr %tensor.data.slot4, align 8
  %tensor.fill.next = add i64 %tensor.fill.i.0, 1
  br label %tensor.fill.cond

tensor.fill.end:                                  ; preds = %tensor.fill.cond
  %tensor.malloc5 = call ptr @malloc(i64 32)
  %tensor.malloc6 = call ptr @malloc(i64 16)
  %tensor.malloc7 = call ptr @malloc(i64 64)
  %tensor.rank.slot8 = getelementptr inbounds %csec.tensor, ptr %tensor.malloc5, i32 0, i32 0
  store i64 2, ptr %tensor.rank.slot8, align 4
  %tensor.dims.slot9 = getelementptr inbounds %csec.tensor, ptr %tensor.malloc5, i32 0, i32 1
  store ptr %tensor.malloc6, ptr %tensor.dims.slot9, align 8
  %tensor.count.slot10 = getelementptr inbounds %csec.tensor, ptr %tensor.malloc5, i32 0, i32 2
  store i64 8, ptr %tensor.count.slot10, align 4
  %tensor.data.slot11 = getelementptr inbounds %csec.tensor, ptr %tensor.malloc5, i32 0, i32 3
  store ptr %tensor.malloc7, ptr %tensor.data.slot11, align 8
  %tensor.dims.ptr12 = getelementptr inbounds %csec.tensor, ptr %tensor.malloc5, i32 0, i32 1
  %tensor.dims13 = load ptr, ptr %tensor.dims.ptr12, align 8
  %tensor.data.ptr14 = getelementptr inbounds %csec.tensor, ptr %tensor.malloc5, i32 0, i32 3
  %tensor.data15 = load ptr, ptr %tensor.data.ptr14, align 8
  %tensor.dim.slot16 = getelementptr i64, ptr %tensor.dims13, i64 0
  store i64 2, ptr %tensor.dim.slot16, align 4
  %tensor.dim.slot17 = getelementptr i64, ptr %tensor.dims13, i64 1
  store i64 4, ptr %tensor.dim.slot17, align 4
  %tensor.fill.i18 = alloca i64, align 8
  store i64 0, ptr %tensor.fill.i18, align 4
  br label %tensor.fill.cond19

tensor.fill.cond19:                               ; preds = %tensor.fill.body20, %tensor.fill.end
  %tensor.fill.idx22 = load i64, ptr %tensor.fill.i18, align 4
  %tensor.fill.keep23 = icmp ult i64 %tensor.fill.idx22, 8
  br i1 %tensor.fill.keep23, label %tensor.fill.body20, label %tensor.fill.end21

tensor.fill.body20:                               ; preds = %tensor.fill.cond19
  %tensor.data.slot24 = getelementptr double, ptr %tensor.data15, i64 %tensor.fill.idx22
  store double 2.500000e-01, ptr %tensor.data.slot24, align 8
  %tensor.fill.current25 = load i64, ptr %tensor.fill.i18, align 4
  %tensor.fill.next26 = add i64 %tensor.fill.current25, 1
  store i64 %tensor.fill.next26, ptr %tensor.fill.i18, align 4
  br label %tensor.fill.cond19

tensor.fill.end21:                                ; preds = %tensor.fill.cond19
  %learningRate = alloca float, align 4
  store float 0x3F50624DE0000000, ptr %learningRate, align 4
  %epoch = alloca i32, align 4
  store i32 0, ptr %epoch, align 4
  %loss = alloca double, align 8
  store double 0.000000e+00, ptr %loss, align 8
  %calltmp27 = call double @_randomInit(double 2.000000e+00)
  %tensor.malloc28 = call ptr @malloc(i64 32)
  %tensor.malloc29 = call ptr @malloc(i64 16)
  %tensor.malloc30 = call ptr @malloc(i64 128)
  %tensor.rank.slot31 = getelementptr inbounds %csec.tensor, ptr %tensor.malloc28, i32 0, i32 0
  store i64 2, ptr %tensor.rank.slot31, align 4
  %tensor.dims.slot32 = getelementptr inbounds %csec.tensor, ptr %tensor.malloc28, i32 0, i32 1
  store ptr %tensor.malloc29, ptr %tensor.dims.slot32, align 8
  %tensor.count.slot33 = getelementptr inbounds %csec.tensor, ptr %tensor.malloc28, i32 0, i32 2
  store i64 16, ptr %tensor.count.slot33, align 4
  %tensor.data.slot34 = getelementptr inbounds %csec.tensor, ptr %tensor.malloc28, i32 0, i32 3
  store ptr %tensor.malloc30, ptr %tensor.data.slot34, align 8
  %tensor.dims.ptr35 = getelementptr inbounds %csec.tensor, ptr %tensor.malloc28, i32 0, i32 1
  %tensor.dims36 = load ptr, ptr %tensor.dims.ptr35, align 8
  %tensor.data.ptr37 = getelementptr inbounds %csec.tensor, ptr %tensor.malloc28, i32 0, i32 3
  %tensor.data38 = load ptr, ptr %tensor.data.ptr37, align 8
  %tensor.dim.slot39 = getelementptr i64, ptr %tensor.dims36, i64 0
  store i64 4, ptr %tensor.dim.slot39, align 4
  %tensor.dim.slot40 = getelementptr i64, ptr %tensor.dims36, i64 1
  store i64 4, ptr %tensor.dim.slot40, align 4
  %tensor.fill.i41 = alloca i64, align 8
  store i64 0, ptr %tensor.fill.i41, align 4
  br label %tensor.fill.cond42

tensor.fill.cond42:                               ; preds = %tensor.fill.body43, %tensor.fill.end21
  %tensor.fill.idx45 = load i64, ptr %tensor.fill.i41, align 4
  %tensor.fill.keep46 = icmp ult i64 %tensor.fill.idx45, 16
  br i1 %tensor.fill.keep46, label %tensor.fill.body43, label %tensor.fill.end44

tensor.fill.body43:                               ; preds = %tensor.fill.cond42
  %tensor.data.slot47 = getelementptr double, ptr %tensor.data38, i64 %tensor.fill.idx45
  store double %calltmp27, ptr %tensor.data.slot47, align 8
  %tensor.fill.current48 = load i64, ptr %tensor.fill.i41, align 4
  %tensor.fill.next49 = add i64 %tensor.fill.current48, 1
  store i64 %tensor.fill.next49, ptr %tensor.fill.i41, align 4
  br label %tensor.fill.cond42

tensor.fill.end44:                                ; preds = %tensor.fill.cond42
  %layer1Wq = alloca ptr, align 8
  store ptr %tensor.malloc28, ptr %layer1Wq, align 8
  %calltmp50 = call double @_randomInit(double 3.000000e+00)
  %tensor.malloc51 = call ptr @malloc(i64 32)
  %tensor.malloc52 = call ptr @malloc(i64 16)
  %tensor.malloc53 = call ptr @malloc(i64 128)
  %tensor.rank.slot54 = getelementptr inbounds %csec.tensor, ptr %tensor.malloc51, i32 0, i32 0
  store i64 2, ptr %tensor.rank.slot54, align 4
  %tensor.dims.slot55 = getelementptr inbounds %csec.tensor, ptr %tensor.malloc51, i32 0, i32 1
  store ptr %tensor.malloc52, ptr %tensor.dims.slot55, align 8
  %tensor.count.slot56 = getelementptr inbounds %csec.tensor, ptr %tensor.malloc51, i32 0, i32 2
  store i64 16, ptr %tensor.count.slot56, align 4
  %tensor.data.slot57 = getelementptr inbounds %csec.tensor, ptr %tensor.malloc51, i32 0, i32 3
  store ptr %tensor.malloc53, ptr %tensor.data.slot57, align 8
  %tensor.dims.ptr58 = getelementptr inbounds %csec.tensor, ptr %tensor.malloc51, i32 0, i32 1
  %tensor.dims59 = load ptr, ptr %tensor.dims.ptr58, align 8
  %tensor.data.ptr60 = getelementptr inbounds %csec.tensor, ptr %tensor.malloc51, i32 0, i32 3
  %tensor.data61 = load ptr, ptr %tensor.data.ptr60, align 8
  %tensor.dim.slot62 = getelementptr i64, ptr %tensor.dims59, i64 0
  store i64 4, ptr %tensor.dim.slot62, align 4
  %tensor.dim.slot63 = getelementptr i64, ptr %tensor.dims59, i64 1
  store i64 4, ptr %tensor.dim.slot63, align 4
  %tensor.fill.i64 = alloca i64, align 8
  store i64 0, ptr %tensor.fill.i64, align 4
  br label %tensor.fill.cond65

tensor.fill.cond65:                               ; preds = %tensor.fill.body66, %tensor.fill.end44
  %tensor.fill.idx68 = load i64, ptr %tensor.fill.i64, align 4
  %tensor.fill.keep69 = icmp ult i64 %tensor.fill.idx68, 16
  br i1 %tensor.fill.keep69, label %tensor.fill.body66, label %tensor.fill.end67

tensor.fill.body66:                               ; preds = %tensor.fill.cond65
  %tensor.data.slot70 = getelementptr double, ptr %tensor.data61, i64 %tensor.fill.idx68
  store double %calltmp50, ptr %tensor.data.slot70, align 8
  %tensor.fill.current71 = load i64, ptr %tensor.fill.i64, align 4
  %tensor.fill.next72 = add i64 %tensor.fill.current71, 1
  store i64 %tensor.fill.next72, ptr %tensor.fill.i64, align 4
  br label %tensor.fill.cond65

tensor.fill.end67:                                ; preds = %tensor.fill.cond65
  %layer1Wk = alloca ptr, align 8
  store ptr %tensor.malloc51, ptr %layer1Wk, align 8
  %calltmp73 = call double @_randomInit(double 4.000000e+00)
  %tensor.malloc74 = call ptr @malloc(i64 32)
  %tensor.malloc75 = call ptr @malloc(i64 16)
  %tensor.malloc76 = call ptr @malloc(i64 128)
  %tensor.rank.slot77 = getelementptr inbounds %csec.tensor, ptr %tensor.malloc74, i32 0, i32 0
  store i64 2, ptr %tensor.rank.slot77, align 4
  %tensor.dims.slot78 = getelementptr inbounds %csec.tensor, ptr %tensor.malloc74, i32 0, i32 1
  store ptr %tensor.malloc75, ptr %tensor.dims.slot78, align 8
  %tensor.count.slot79 = getelementptr inbounds %csec.tensor, ptr %tensor.malloc74, i32 0, i32 2
  store i64 16, ptr %tensor.count.slot79, align 4
  %tensor.data.slot80 = getelementptr inbounds %csec.tensor, ptr %tensor.malloc74, i32 0, i32 3
  store ptr %tensor.malloc76, ptr %tensor.data.slot80, align 8
  %tensor.dims.ptr81 = getelementptr inbounds %csec.tensor, ptr %tensor.malloc74, i32 0, i32 1
  %tensor.dims82 = load ptr, ptr %tensor.dims.ptr81, align 8
  %tensor.data.ptr83 = getelementptr inbounds %csec.tensor, ptr %tensor.malloc74, i32 0, i32 3
  %tensor.data84 = load ptr, ptr %tensor.data.ptr83, align 8
  %tensor.dim.slot85 = getelementptr i64, ptr %tensor.dims82, i64 0
  store i64 4, ptr %tensor.dim.slot85, align 4
  %tensor.dim.slot86 = getelementptr i64, ptr %tensor.dims82, i64 1
  store i64 4, ptr %tensor.dim.slot86, align 4
  %tensor.fill.i87 = alloca i64, align 8
  store i64 0, ptr %tensor.fill.i87, align 4
  br label %tensor.fill.cond88

tensor.fill.cond88:                               ; preds = %tensor.fill.body89, %tensor.fill.end67
  %tensor.fill.idx91 = load i64, ptr %tensor.fill.i87, align 4
  %tensor.fill.keep92 = icmp ult i64 %tensor.fill.idx91, 16
  br i1 %tensor.fill.keep92, label %tensor.fill.body89, label %tensor.fill.end90

tensor.fill.body89:                               ; preds = %tensor.fill.cond88
  %tensor.data.slot93 = getelementptr double, ptr %tensor.data84, i64 %tensor.fill.idx91
  store double %calltmp73, ptr %tensor.data.slot93, align 8
  %tensor.fill.current94 = load i64, ptr %tensor.fill.i87, align 4
  %tensor.fill.next95 = add i64 %tensor.fill.current94, 1
  store i64 %tensor.fill.next95, ptr %tensor.fill.i87, align 4
  br label %tensor.fill.cond88

tensor.fill.end90:                                ; preds = %tensor.fill.cond88
  %layer1Wv = alloca ptr, align 8
  store ptr %tensor.malloc74, ptr %layer1Wv, align 8
  %calltmp96 = call double @_randomInit(double 5.000000e+00)
  %tensor.malloc97 = call ptr @malloc(i64 32)
  %tensor.malloc98 = call ptr @malloc(i64 16)
  %tensor.malloc99 = call ptr @malloc(i64 128)
  %tensor.rank.slot100 = getelementptr inbounds %csec.tensor, ptr %tensor.malloc97, i32 0, i32 0
  store i64 2, ptr %tensor.rank.slot100, align 4
  %tensor.dims.slot101 = getelementptr inbounds %csec.tensor, ptr %tensor.malloc97, i32 0, i32 1
  store ptr %tensor.malloc98, ptr %tensor.dims.slot101, align 8
  %tensor.count.slot102 = getelementptr inbounds %csec.tensor, ptr %tensor.malloc97, i32 0, i32 2
  store i64 16, ptr %tensor.count.slot102, align 4
  %tensor.data.slot103 = getelementptr inbounds %csec.tensor, ptr %tensor.malloc97, i32 0, i32 3
  store ptr %tensor.malloc99, ptr %tensor.data.slot103, align 8
  %tensor.dims.ptr104 = getelementptr inbounds %csec.tensor, ptr %tensor.malloc97, i32 0, i32 1
  %tensor.dims105 = load ptr, ptr %tensor.dims.ptr104, align 8
  %tensor.data.ptr106 = getelementptr inbounds %csec.tensor, ptr %tensor.malloc97, i32 0, i32 3
  %tensor.data107 = load ptr, ptr %tensor.data.ptr106, align 8
  %tensor.dim.slot108 = getelementptr i64, ptr %tensor.dims105, i64 0
  store i64 4, ptr %tensor.dim.slot108, align 4
  %tensor.dim.slot109 = getelementptr i64, ptr %tensor.dims105, i64 1
  store i64 4, ptr %tensor.dim.slot109, align 4
  %tensor.fill.i110 = alloca i64, align 8
  store i64 0, ptr %tensor.fill.i110, align 4
  br label %tensor.fill.cond111

tensor.fill.cond111:                              ; preds = %tensor.fill.body112, %tensor.fill.end90
  %tensor.fill.idx114 = load i64, ptr %tensor.fill.i110, align 4
  %tensor.fill.keep115 = icmp ult i64 %tensor.fill.idx114, 16
  br i1 %tensor.fill.keep115, label %tensor.fill.body112, label %tensor.fill.end113

tensor.fill.body112:                              ; preds = %tensor.fill.cond111
  %tensor.data.slot116 = getelementptr double, ptr %tensor.data107, i64 %tensor.fill.idx114
  store double %calltmp96, ptr %tensor.data.slot116, align 8
  %tensor.fill.current117 = load i64, ptr %tensor.fill.i110, align 4
  %tensor.fill.next118 = add i64 %tensor.fill.current117, 1
  store i64 %tensor.fill.next118, ptr %tensor.fill.i110, align 4
  br label %tensor.fill.cond111

tensor.fill.end113:                               ; preds = %tensor.fill.cond111
  %layer1Wo = alloca ptr, align 8
  store ptr %tensor.malloc97, ptr %layer1Wo, align 8
  %tensor.malloc119 = call ptr @malloc(i64 32)
  %tensor.malloc120 = call ptr @malloc(i64 16)
  %tensor.malloc121 = call ptr @malloc(i64 64)
  %tensor.rank.slot122 = getelementptr inbounds %csec.tensor, ptr %tensor.malloc119, i32 0, i32 0
  store i64 2, ptr %tensor.rank.slot122, align 4
  %tensor.dims.slot123 = getelementptr inbounds %csec.tensor, ptr %tensor.malloc119, i32 0, i32 1
  store ptr %tensor.malloc120, ptr %tensor.dims.slot123, align 8
  %tensor.count.slot124 = getelementptr inbounds %csec.tensor, ptr %tensor.malloc119, i32 0, i32 2
  store i64 8, ptr %tensor.count.slot124, align 4
  %tensor.data.slot125 = getelementptr inbounds %csec.tensor, ptr %tensor.malloc119, i32 0, i32 3
  store ptr %tensor.malloc121, ptr %tensor.data.slot125, align 8
  %tensor.dims.ptr126 = getelementptr inbounds %csec.tensor, ptr %tensor.malloc119, i32 0, i32 1
  %tensor.dims127 = load ptr, ptr %tensor.dims.ptr126, align 8
  %tensor.data.ptr128 = getelementptr inbounds %csec.tensor, ptr %tensor.malloc119, i32 0, i32 3
  %tensor.data129 = load ptr, ptr %tensor.data.ptr128, align 8
  %tensor.dim.slot130 = getelementptr i64, ptr %tensor.dims127, i64 0
  store i64 2, ptr %tensor.dim.slot130, align 4
  %tensor.dim.slot131 = getelementptr i64, ptr %tensor.dims127, i64 1
  store i64 4, ptr %tensor.dim.slot131, align 4
  %tensor.fill.i132 = alloca i64, align 8
  store i64 0, ptr %tensor.fill.i132, align 4
  br label %tensor.fill.cond133

tensor.fill.cond133:                              ; preds = %tensor.fill.body134, %tensor.fill.end113
  %tensor.fill.idx136 = load i64, ptr %tensor.fill.i132, align 4
  %tensor.fill.keep137 = icmp ult i64 %tensor.fill.idx136, 8
  br i1 %tensor.fill.keep137, label %tensor.fill.body134, label %tensor.fill.end135

tensor.fill.body134:                              ; preds = %tensor.fill.cond133
  %tensor.data.slot138 = getelementptr double, ptr %tensor.data129, i64 %tensor.fill.idx136
  store double 0.000000e+00, ptr %tensor.data.slot138, align 8
  %tensor.fill.current139 = load i64, ptr %tensor.fill.i132, align 4
  %tensor.fill.next140 = add i64 %tensor.fill.current139, 1
  store i64 %tensor.fill.next140, ptr %tensor.fill.i132, align 4
  br label %tensor.fill.cond133

tensor.fill.end135:                               ; preds = %tensor.fill.cond133
  %calltmp141 = call double @_randomInit(double 6.000000e+00)
  %tensor.malloc142 = call ptr @malloc(i64 32)
  %tensor.malloc143 = call ptr @malloc(i64 16)
  %tensor.malloc144 = call ptr @malloc(i64 256)
  %tensor.rank.slot145 = getelementptr inbounds %csec.tensor, ptr %tensor.malloc142, i32 0, i32 0
  store i64 2, ptr %tensor.rank.slot145, align 4
  %tensor.dims.slot146 = getelementptr inbounds %csec.tensor, ptr %tensor.malloc142, i32 0, i32 1
  store ptr %tensor.malloc143, ptr %tensor.dims.slot146, align 8
  %tensor.count.slot147 = getelementptr inbounds %csec.tensor, ptr %tensor.malloc142, i32 0, i32 2
  store i64 32, ptr %tensor.count.slot147, align 4
  %tensor.data.slot148 = getelementptr inbounds %csec.tensor, ptr %tensor.malloc142, i32 0, i32 3
  store ptr %tensor.malloc144, ptr %tensor.data.slot148, align 8
  %tensor.dims.ptr149 = getelementptr inbounds %csec.tensor, ptr %tensor.malloc142, i32 0, i32 1
  %tensor.dims150 = load ptr, ptr %tensor.dims.ptr149, align 8
  %tensor.data.ptr151 = getelementptr inbounds %csec.tensor, ptr %tensor.malloc142, i32 0, i32 3
  %tensor.data152 = load ptr, ptr %tensor.data.ptr151, align 8
  %tensor.dim.slot153 = getelementptr i64, ptr %tensor.dims150, i64 0
  store i64 4, ptr %tensor.dim.slot153, align 4
  %tensor.dim.slot154 = getelementptr i64, ptr %tensor.dims150, i64 1
  store i64 8, ptr %tensor.dim.slot154, align 4
  %tensor.fill.i155 = alloca i64, align 8
  store i64 0, ptr %tensor.fill.i155, align 4
  br label %tensor.fill.cond156

tensor.fill.cond156:                              ; preds = %tensor.fill.body157, %tensor.fill.end135
  %tensor.fill.idx159 = load i64, ptr %tensor.fill.i155, align 4
  %tensor.fill.keep160 = icmp ult i64 %tensor.fill.idx159, 32
  br i1 %tensor.fill.keep160, label %tensor.fill.body157, label %tensor.fill.end158

tensor.fill.body157:                              ; preds = %tensor.fill.cond156
  %tensor.data.slot161 = getelementptr double, ptr %tensor.data152, i64 %tensor.fill.idx159
  store double %calltmp141, ptr %tensor.data.slot161, align 8
  %tensor.fill.current162 = load i64, ptr %tensor.fill.i155, align 4
  %tensor.fill.next163 = add i64 %tensor.fill.current162, 1
  store i64 %tensor.fill.next163, ptr %tensor.fill.i155, align 4
  br label %tensor.fill.cond156

tensor.fill.end158:                               ; preds = %tensor.fill.cond156
  %layer1FfnW1 = alloca ptr, align 8
  store ptr %tensor.malloc142, ptr %layer1FfnW1, align 8
  %tensor.malloc164 = call ptr @malloc(i64 32)
  %tensor.malloc165 = call ptr @malloc(i64 16)
  %tensor.malloc166 = call ptr @malloc(i64 128)
  %tensor.rank.slot167 = getelementptr inbounds %csec.tensor, ptr %tensor.malloc164, i32 0, i32 0
  store i64 2, ptr %tensor.rank.slot167, align 4
  %tensor.dims.slot168 = getelementptr inbounds %csec.tensor, ptr %tensor.malloc164, i32 0, i32 1
  store ptr %tensor.malloc165, ptr %tensor.dims.slot168, align 8
  %tensor.count.slot169 = getelementptr inbounds %csec.tensor, ptr %tensor.malloc164, i32 0, i32 2
  store i64 16, ptr %tensor.count.slot169, align 4
  %tensor.data.slot170 = getelementptr inbounds %csec.tensor, ptr %tensor.malloc164, i32 0, i32 3
  store ptr %tensor.malloc166, ptr %tensor.data.slot170, align 8
  %tensor.dims.ptr171 = getelementptr inbounds %csec.tensor, ptr %tensor.malloc164, i32 0, i32 1
  %tensor.dims172 = load ptr, ptr %tensor.dims.ptr171, align 8
  %tensor.data.ptr173 = getelementptr inbounds %csec.tensor, ptr %tensor.malloc164, i32 0, i32 3
  %tensor.data174 = load ptr, ptr %tensor.data.ptr173, align 8
  %tensor.dim.slot175 = getelementptr i64, ptr %tensor.dims172, i64 0
  store i64 2, ptr %tensor.dim.slot175, align 4
  %tensor.dim.slot176 = getelementptr i64, ptr %tensor.dims172, i64 1
  store i64 8, ptr %tensor.dim.slot176, align 4
  %tensor.fill.i177 = alloca i64, align 8
  store i64 0, ptr %tensor.fill.i177, align 4
  br label %tensor.fill.cond178

tensor.fill.cond178:                              ; preds = %tensor.fill.body179, %tensor.fill.end158
  %tensor.fill.idx181 = load i64, ptr %tensor.fill.i177, align 4
  %tensor.fill.keep182 = icmp ult i64 %tensor.fill.idx181, 16
  br i1 %tensor.fill.keep182, label %tensor.fill.body179, label %tensor.fill.end180

tensor.fill.body179:                              ; preds = %tensor.fill.cond178
  %tensor.data.slot183 = getelementptr double, ptr %tensor.data174, i64 %tensor.fill.idx181
  store double 0.000000e+00, ptr %tensor.data.slot183, align 8
  %tensor.fill.current184 = load i64, ptr %tensor.fill.i177, align 4
  %tensor.fill.next185 = add i64 %tensor.fill.current184, 1
  store i64 %tensor.fill.next185, ptr %tensor.fill.i177, align 4
  br label %tensor.fill.cond178

tensor.fill.end180:                               ; preds = %tensor.fill.cond178
  %calltmp186 = call double @_randomInit(double 7.000000e+00)
  %tensor.malloc187 = call ptr @malloc(i64 32)
  %tensor.malloc188 = call ptr @malloc(i64 16)
  %tensor.malloc189 = call ptr @malloc(i64 256)
  %tensor.rank.slot190 = getelementptr inbounds %csec.tensor, ptr %tensor.malloc187, i32 0, i32 0
  store i64 2, ptr %tensor.rank.slot190, align 4
  %tensor.dims.slot191 = getelementptr inbounds %csec.tensor, ptr %tensor.malloc187, i32 0, i32 1
  store ptr %tensor.malloc188, ptr %tensor.dims.slot191, align 8
  %tensor.count.slot192 = getelementptr inbounds %csec.tensor, ptr %tensor.malloc187, i32 0, i32 2
  store i64 32, ptr %tensor.count.slot192, align 4
  %tensor.data.slot193 = getelementptr inbounds %csec.tensor, ptr %tensor.malloc187, i32 0, i32 3
  store ptr %tensor.malloc189, ptr %tensor.data.slot193, align 8
  %tensor.dims.ptr194 = getelementptr inbounds %csec.tensor, ptr %tensor.malloc187, i32 0, i32 1
  %tensor.dims195 = load ptr, ptr %tensor.dims.ptr194, align 8
  %tensor.data.ptr196 = getelementptr inbounds %csec.tensor, ptr %tensor.malloc187, i32 0, i32 3
  %tensor.data197 = load ptr, ptr %tensor.data.ptr196, align 8
  %tensor.dim.slot198 = getelementptr i64, ptr %tensor.dims195, i64 0
  store i64 8, ptr %tensor.dim.slot198, align 4
  %tensor.dim.slot199 = getelementptr i64, ptr %tensor.dims195, i64 1
  store i64 4, ptr %tensor.dim.slot199, align 4
  %tensor.fill.i200 = alloca i64, align 8
  store i64 0, ptr %tensor.fill.i200, align 4
  br label %tensor.fill.cond201

tensor.fill.cond201:                              ; preds = %tensor.fill.body202, %tensor.fill.end180
  %tensor.fill.idx204 = load i64, ptr %tensor.fill.i200, align 4
  %tensor.fill.keep205 = icmp ult i64 %tensor.fill.idx204, 32
  br i1 %tensor.fill.keep205, label %tensor.fill.body202, label %tensor.fill.end203

tensor.fill.body202:                              ; preds = %tensor.fill.cond201
  %tensor.data.slot206 = getelementptr double, ptr %tensor.data197, i64 %tensor.fill.idx204
  store double %calltmp186, ptr %tensor.data.slot206, align 8
  %tensor.fill.current207 = load i64, ptr %tensor.fill.i200, align 4
  %tensor.fill.next208 = add i64 %tensor.fill.current207, 1
  store i64 %tensor.fill.next208, ptr %tensor.fill.i200, align 4
  br label %tensor.fill.cond201

tensor.fill.end203:                               ; preds = %tensor.fill.cond201
  %layer1FfnW2 = alloca ptr, align 8
  store ptr %tensor.malloc187, ptr %layer1FfnW2, align 8
  %tensor.malloc209 = call ptr @malloc(i64 32)
  %tensor.malloc210 = call ptr @malloc(i64 16)
  %tensor.malloc211 = call ptr @malloc(i64 64)
  %tensor.rank.slot212 = getelementptr inbounds %csec.tensor, ptr %tensor.malloc209, i32 0, i32 0
  store i64 2, ptr %tensor.rank.slot212, align 4
  %tensor.dims.slot213 = getelementptr inbounds %csec.tensor, ptr %tensor.malloc209, i32 0, i32 1
  store ptr %tensor.malloc210, ptr %tensor.dims.slot213, align 8
  %tensor.count.slot214 = getelementptr inbounds %csec.tensor, ptr %tensor.malloc209, i32 0, i32 2
  store i64 8, ptr %tensor.count.slot214, align 4
  %tensor.data.slot215 = getelementptr inbounds %csec.tensor, ptr %tensor.malloc209, i32 0, i32 3
  store ptr %tensor.malloc211, ptr %tensor.data.slot215, align 8
  %tensor.dims.ptr216 = getelementptr inbounds %csec.tensor, ptr %tensor.malloc209, i32 0, i32 1
  %tensor.dims217 = load ptr, ptr %tensor.dims.ptr216, align 8
  %tensor.data.ptr218 = getelementptr inbounds %csec.tensor, ptr %tensor.malloc209, i32 0, i32 3
  %tensor.data219 = load ptr, ptr %tensor.data.ptr218, align 8
  %tensor.dim.slot220 = getelementptr i64, ptr %tensor.dims217, i64 0
  store i64 2, ptr %tensor.dim.slot220, align 4
  %tensor.dim.slot221 = getelementptr i64, ptr %tensor.dims217, i64 1
  store i64 4, ptr %tensor.dim.slot221, align 4
  %tensor.fill.i222 = alloca i64, align 8
  store i64 0, ptr %tensor.fill.i222, align 4
  br label %tensor.fill.cond223

tensor.fill.cond223:                              ; preds = %tensor.fill.body224, %tensor.fill.end203
  %tensor.fill.idx226 = load i64, ptr %tensor.fill.i222, align 4
  %tensor.fill.keep227 = icmp ult i64 %tensor.fill.idx226, 8
  br i1 %tensor.fill.keep227, label %tensor.fill.body224, label %tensor.fill.end225

tensor.fill.body224:                              ; preds = %tensor.fill.cond223
  %tensor.data.slot228 = getelementptr double, ptr %tensor.data219, i64 %tensor.fill.idx226
  store double 0.000000e+00, ptr %tensor.data.slot228, align 8
  %tensor.fill.current229 = load i64, ptr %tensor.fill.i222, align 4
  %tensor.fill.next230 = add i64 %tensor.fill.current229, 1
  store i64 %tensor.fill.next230, ptr %tensor.fill.i222, align 4
  br label %tensor.fill.cond223

tensor.fill.end225:                               ; preds = %tensor.fill.cond223
  %calltmp231 = call double @_randomInit(double 8.000000e+00)
  %tensor.malloc232 = call ptr @malloc(i64 32)
  %tensor.malloc233 = call ptr @malloc(i64 16)
  %tensor.malloc234 = call ptr @malloc(i64 128)
  %tensor.rank.slot235 = getelementptr inbounds %csec.tensor, ptr %tensor.malloc232, i32 0, i32 0
  store i64 2, ptr %tensor.rank.slot235, align 4
  %tensor.dims.slot236 = getelementptr inbounds %csec.tensor, ptr %tensor.malloc232, i32 0, i32 1
  store ptr %tensor.malloc233, ptr %tensor.dims.slot236, align 8
  %tensor.count.slot237 = getelementptr inbounds %csec.tensor, ptr %tensor.malloc232, i32 0, i32 2
  store i64 16, ptr %tensor.count.slot237, align 4
  %tensor.data.slot238 = getelementptr inbounds %csec.tensor, ptr %tensor.malloc232, i32 0, i32 3
  store ptr %tensor.malloc234, ptr %tensor.data.slot238, align 8
  %tensor.dims.ptr239 = getelementptr inbounds %csec.tensor, ptr %tensor.malloc232, i32 0, i32 1
  %tensor.dims240 = load ptr, ptr %tensor.dims.ptr239, align 8
  %tensor.data.ptr241 = getelementptr inbounds %csec.tensor, ptr %tensor.malloc232, i32 0, i32 3
  %tensor.data242 = load ptr, ptr %tensor.data.ptr241, align 8
  %tensor.dim.slot243 = getelementptr i64, ptr %tensor.dims240, i64 0
  store i64 4, ptr %tensor.dim.slot243, align 4
  %tensor.dim.slot244 = getelementptr i64, ptr %tensor.dims240, i64 1
  store i64 4, ptr %tensor.dim.slot244, align 4
  %tensor.fill.i245 = alloca i64, align 8
  store i64 0, ptr %tensor.fill.i245, align 4
  br label %tensor.fill.cond246

tensor.fill.cond246:                              ; preds = %tensor.fill.body247, %tensor.fill.end225
  %tensor.fill.idx249 = load i64, ptr %tensor.fill.i245, align 4
  %tensor.fill.keep250 = icmp ult i64 %tensor.fill.idx249, 16
  br i1 %tensor.fill.keep250, label %tensor.fill.body247, label %tensor.fill.end248

tensor.fill.body247:                              ; preds = %tensor.fill.cond246
  %tensor.data.slot251 = getelementptr double, ptr %tensor.data242, i64 %tensor.fill.idx249
  store double %calltmp231, ptr %tensor.data.slot251, align 8
  %tensor.fill.current252 = load i64, ptr %tensor.fill.i245, align 4
  %tensor.fill.next253 = add i64 %tensor.fill.current252, 1
  store i64 %tensor.fill.next253, ptr %tensor.fill.i245, align 4
  br label %tensor.fill.cond246

tensor.fill.end248:                               ; preds = %tensor.fill.cond246
  %layer2Wq = alloca ptr, align 8
  store ptr %tensor.malloc232, ptr %layer2Wq, align 8
  %calltmp254 = call double @_randomInit(double 9.000000e+00)
  %tensor.malloc255 = call ptr @malloc(i64 32)
  %tensor.malloc256 = call ptr @malloc(i64 16)
  %tensor.malloc257 = call ptr @malloc(i64 128)
  %tensor.rank.slot258 = getelementptr inbounds %csec.tensor, ptr %tensor.malloc255, i32 0, i32 0
  store i64 2, ptr %tensor.rank.slot258, align 4
  %tensor.dims.slot259 = getelementptr inbounds %csec.tensor, ptr %tensor.malloc255, i32 0, i32 1
  store ptr %tensor.malloc256, ptr %tensor.dims.slot259, align 8
  %tensor.count.slot260 = getelementptr inbounds %csec.tensor, ptr %tensor.malloc255, i32 0, i32 2
  store i64 16, ptr %tensor.count.slot260, align 4
  %tensor.data.slot261 = getelementptr inbounds %csec.tensor, ptr %tensor.malloc255, i32 0, i32 3
  store ptr %tensor.malloc257, ptr %tensor.data.slot261, align 8
  %tensor.dims.ptr262 = getelementptr inbounds %csec.tensor, ptr %tensor.malloc255, i32 0, i32 1
  %tensor.dims263 = load ptr, ptr %tensor.dims.ptr262, align 8
  %tensor.data.ptr264 = getelementptr inbounds %csec.tensor, ptr %tensor.malloc255, i32 0, i32 3
  %tensor.data265 = load ptr, ptr %tensor.data.ptr264, align 8
  %tensor.dim.slot266 = getelementptr i64, ptr %tensor.dims263, i64 0
  store i64 4, ptr %tensor.dim.slot266, align 4
  %tensor.dim.slot267 = getelementptr i64, ptr %tensor.dims263, i64 1
  store i64 4, ptr %tensor.dim.slot267, align 4
  %tensor.fill.i268 = alloca i64, align 8
  store i64 0, ptr %tensor.fill.i268, align 4
  br label %tensor.fill.cond269

tensor.fill.cond269:                              ; preds = %tensor.fill.body270, %tensor.fill.end248
  %tensor.fill.idx272 = load i64, ptr %tensor.fill.i268, align 4
  %tensor.fill.keep273 = icmp ult i64 %tensor.fill.idx272, 16
  br i1 %tensor.fill.keep273, label %tensor.fill.body270, label %tensor.fill.end271

tensor.fill.body270:                              ; preds = %tensor.fill.cond269
  %tensor.data.slot274 = getelementptr double, ptr %tensor.data265, i64 %tensor.fill.idx272
  store double %calltmp254, ptr %tensor.data.slot274, align 8
  %tensor.fill.current275 = load i64, ptr %tensor.fill.i268, align 4
  %tensor.fill.next276 = add i64 %tensor.fill.current275, 1
  store i64 %tensor.fill.next276, ptr %tensor.fill.i268, align 4
  br label %tensor.fill.cond269

tensor.fill.end271:                               ; preds = %tensor.fill.cond269
  %layer2Wk = alloca ptr, align 8
  store ptr %tensor.malloc255, ptr %layer2Wk, align 8
  %calltmp277 = call double @_randomInit(double 1.000000e+01)
  %tensor.malloc278 = call ptr @malloc(i64 32)
  %tensor.malloc279 = call ptr @malloc(i64 16)
  %tensor.malloc280 = call ptr @malloc(i64 128)
  %tensor.rank.slot281 = getelementptr inbounds %csec.tensor, ptr %tensor.malloc278, i32 0, i32 0
  store i64 2, ptr %tensor.rank.slot281, align 4
  %tensor.dims.slot282 = getelementptr inbounds %csec.tensor, ptr %tensor.malloc278, i32 0, i32 1
  store ptr %tensor.malloc279, ptr %tensor.dims.slot282, align 8
  %tensor.count.slot283 = getelementptr inbounds %csec.tensor, ptr %tensor.malloc278, i32 0, i32 2
  store i64 16, ptr %tensor.count.slot283, align 4
  %tensor.data.slot284 = getelementptr inbounds %csec.tensor, ptr %tensor.malloc278, i32 0, i32 3
  store ptr %tensor.malloc280, ptr %tensor.data.slot284, align 8
  %tensor.dims.ptr285 = getelementptr inbounds %csec.tensor, ptr %tensor.malloc278, i32 0, i32 1
  %tensor.dims286 = load ptr, ptr %tensor.dims.ptr285, align 8
  %tensor.data.ptr287 = getelementptr inbounds %csec.tensor, ptr %tensor.malloc278, i32 0, i32 3
  %tensor.data288 = load ptr, ptr %tensor.data.ptr287, align 8
  %tensor.dim.slot289 = getelementptr i64, ptr %tensor.dims286, i64 0
  store i64 4, ptr %tensor.dim.slot289, align 4
  %tensor.dim.slot290 = getelementptr i64, ptr %tensor.dims286, i64 1
  store i64 4, ptr %tensor.dim.slot290, align 4
  %tensor.fill.i291 = alloca i64, align 8
  store i64 0, ptr %tensor.fill.i291, align 4
  br label %tensor.fill.cond292

tensor.fill.cond292:                              ; preds = %tensor.fill.body293, %tensor.fill.end271
  %tensor.fill.idx295 = load i64, ptr %tensor.fill.i291, align 4
  %tensor.fill.keep296 = icmp ult i64 %tensor.fill.idx295, 16
  br i1 %tensor.fill.keep296, label %tensor.fill.body293, label %tensor.fill.end294

tensor.fill.body293:                              ; preds = %tensor.fill.cond292
  %tensor.data.slot297 = getelementptr double, ptr %tensor.data288, i64 %tensor.fill.idx295
  store double %calltmp277, ptr %tensor.data.slot297, align 8
  %tensor.fill.current298 = load i64, ptr %tensor.fill.i291, align 4
  %tensor.fill.next299 = add i64 %tensor.fill.current298, 1
  store i64 %tensor.fill.next299, ptr %tensor.fill.i291, align 4
  br label %tensor.fill.cond292

tensor.fill.end294:                               ; preds = %tensor.fill.cond292
  %layer2Wv = alloca ptr, align 8
  store ptr %tensor.malloc278, ptr %layer2Wv, align 8
  %calltmp300 = call double @_randomInit(double 1.100000e+01)
  %tensor.malloc301 = call ptr @malloc(i64 32)
  %tensor.malloc302 = call ptr @malloc(i64 16)
  %tensor.malloc303 = call ptr @malloc(i64 128)
  %tensor.rank.slot304 = getelementptr inbounds %csec.tensor, ptr %tensor.malloc301, i32 0, i32 0
  store i64 2, ptr %tensor.rank.slot304, align 4
  %tensor.dims.slot305 = getelementptr inbounds %csec.tensor, ptr %tensor.malloc301, i32 0, i32 1
  store ptr %tensor.malloc302, ptr %tensor.dims.slot305, align 8
  %tensor.count.slot306 = getelementptr inbounds %csec.tensor, ptr %tensor.malloc301, i32 0, i32 2
  store i64 16, ptr %tensor.count.slot306, align 4
  %tensor.data.slot307 = getelementptr inbounds %csec.tensor, ptr %tensor.malloc301, i32 0, i32 3
  store ptr %tensor.malloc303, ptr %tensor.data.slot307, align 8
  %tensor.dims.ptr308 = getelementptr inbounds %csec.tensor, ptr %tensor.malloc301, i32 0, i32 1
  %tensor.dims309 = load ptr, ptr %tensor.dims.ptr308, align 8
  %tensor.data.ptr310 = getelementptr inbounds %csec.tensor, ptr %tensor.malloc301, i32 0, i32 3
  %tensor.data311 = load ptr, ptr %tensor.data.ptr310, align 8
  %tensor.dim.slot312 = getelementptr i64, ptr %tensor.dims309, i64 0
  store i64 4, ptr %tensor.dim.slot312, align 4
  %tensor.dim.slot313 = getelementptr i64, ptr %tensor.dims309, i64 1
  store i64 4, ptr %tensor.dim.slot313, align 4
  %tensor.fill.i314 = alloca i64, align 8
  store i64 0, ptr %tensor.fill.i314, align 4
  br label %tensor.fill.cond315

tensor.fill.cond315:                              ; preds = %tensor.fill.body316, %tensor.fill.end294
  %tensor.fill.idx318 = load i64, ptr %tensor.fill.i314, align 4
  %tensor.fill.keep319 = icmp ult i64 %tensor.fill.idx318, 16
  br i1 %tensor.fill.keep319, label %tensor.fill.body316, label %tensor.fill.end317

tensor.fill.body316:                              ; preds = %tensor.fill.cond315
  %tensor.data.slot320 = getelementptr double, ptr %tensor.data311, i64 %tensor.fill.idx318
  store double %calltmp300, ptr %tensor.data.slot320, align 8
  %tensor.fill.current321 = load i64, ptr %tensor.fill.i314, align 4
  %tensor.fill.next322 = add i64 %tensor.fill.current321, 1
  store i64 %tensor.fill.next322, ptr %tensor.fill.i314, align 4
  br label %tensor.fill.cond315

tensor.fill.end317:                               ; preds = %tensor.fill.cond315
  %layer2Wo = alloca ptr, align 8
  store ptr %tensor.malloc301, ptr %layer2Wo, align 8
  %tensor.malloc323 = call ptr @malloc(i64 32)
  %tensor.malloc324 = call ptr @malloc(i64 16)
  %tensor.malloc325 = call ptr @malloc(i64 64)
  %tensor.rank.slot326 = getelementptr inbounds %csec.tensor, ptr %tensor.malloc323, i32 0, i32 0
  store i64 2, ptr %tensor.rank.slot326, align 4
  %tensor.dims.slot327 = getelementptr inbounds %csec.tensor, ptr %tensor.malloc323, i32 0, i32 1
  store ptr %tensor.malloc324, ptr %tensor.dims.slot327, align 8
  %tensor.count.slot328 = getelementptr inbounds %csec.tensor, ptr %tensor.malloc323, i32 0, i32 2
  store i64 8, ptr %tensor.count.slot328, align 4
  %tensor.data.slot329 = getelementptr inbounds %csec.tensor, ptr %tensor.malloc323, i32 0, i32 3
  store ptr %tensor.malloc325, ptr %tensor.data.slot329, align 8
  %tensor.dims.ptr330 = getelementptr inbounds %csec.tensor, ptr %tensor.malloc323, i32 0, i32 1
  %tensor.dims331 = load ptr, ptr %tensor.dims.ptr330, align 8
  %tensor.data.ptr332 = getelementptr inbounds %csec.tensor, ptr %tensor.malloc323, i32 0, i32 3
  %tensor.data333 = load ptr, ptr %tensor.data.ptr332, align 8
  %tensor.dim.slot334 = getelementptr i64, ptr %tensor.dims331, i64 0
  store i64 2, ptr %tensor.dim.slot334, align 4
  %tensor.dim.slot335 = getelementptr i64, ptr %tensor.dims331, i64 1
  store i64 4, ptr %tensor.dim.slot335, align 4
  %tensor.fill.i336 = alloca i64, align 8
  store i64 0, ptr %tensor.fill.i336, align 4
  br label %tensor.fill.cond337

tensor.fill.cond337:                              ; preds = %tensor.fill.body338, %tensor.fill.end317
  %tensor.fill.idx340 = load i64, ptr %tensor.fill.i336, align 4
  %tensor.fill.keep341 = icmp ult i64 %tensor.fill.idx340, 8
  br i1 %tensor.fill.keep341, label %tensor.fill.body338, label %tensor.fill.end339

tensor.fill.body338:                              ; preds = %tensor.fill.cond337
  %tensor.data.slot342 = getelementptr double, ptr %tensor.data333, i64 %tensor.fill.idx340
  store double 0.000000e+00, ptr %tensor.data.slot342, align 8
  %tensor.fill.current343 = load i64, ptr %tensor.fill.i336, align 4
  %tensor.fill.next344 = add i64 %tensor.fill.current343, 1
  store i64 %tensor.fill.next344, ptr %tensor.fill.i336, align 4
  br label %tensor.fill.cond337

tensor.fill.end339:                               ; preds = %tensor.fill.cond337
  %calltmp345 = call double @_randomInit(double 1.200000e+01)
  %tensor.malloc346 = call ptr @malloc(i64 32)
  %tensor.malloc347 = call ptr @malloc(i64 16)
  %tensor.malloc348 = call ptr @malloc(i64 256)
  %tensor.rank.slot349 = getelementptr inbounds %csec.tensor, ptr %tensor.malloc346, i32 0, i32 0
  store i64 2, ptr %tensor.rank.slot349, align 4
  %tensor.dims.slot350 = getelementptr inbounds %csec.tensor, ptr %tensor.malloc346, i32 0, i32 1
  store ptr %tensor.malloc347, ptr %tensor.dims.slot350, align 8
  %tensor.count.slot351 = getelementptr inbounds %csec.tensor, ptr %tensor.malloc346, i32 0, i32 2
  store i64 32, ptr %tensor.count.slot351, align 4
  %tensor.data.slot352 = getelementptr inbounds %csec.tensor, ptr %tensor.malloc346, i32 0, i32 3
  store ptr %tensor.malloc348, ptr %tensor.data.slot352, align 8
  %tensor.dims.ptr353 = getelementptr inbounds %csec.tensor, ptr %tensor.malloc346, i32 0, i32 1
  %tensor.dims354 = load ptr, ptr %tensor.dims.ptr353, align 8
  %tensor.data.ptr355 = getelementptr inbounds %csec.tensor, ptr %tensor.malloc346, i32 0, i32 3
  %tensor.data356 = load ptr, ptr %tensor.data.ptr355, align 8
  %tensor.dim.slot357 = getelementptr i64, ptr %tensor.dims354, i64 0
  store i64 4, ptr %tensor.dim.slot357, align 4
  %tensor.dim.slot358 = getelementptr i64, ptr %tensor.dims354, i64 1
  store i64 8, ptr %tensor.dim.slot358, align 4
  %tensor.fill.i359 = alloca i64, align 8
  store i64 0, ptr %tensor.fill.i359, align 4
  br label %tensor.fill.cond360

tensor.fill.cond360:                              ; preds = %tensor.fill.body361, %tensor.fill.end339
  %tensor.fill.idx363 = load i64, ptr %tensor.fill.i359, align 4
  %tensor.fill.keep364 = icmp ult i64 %tensor.fill.idx363, 32
  br i1 %tensor.fill.keep364, label %tensor.fill.body361, label %tensor.fill.end362

tensor.fill.body361:                              ; preds = %tensor.fill.cond360
  %tensor.data.slot365 = getelementptr double, ptr %tensor.data356, i64 %tensor.fill.idx363
  store double %calltmp345, ptr %tensor.data.slot365, align 8
  %tensor.fill.current366 = load i64, ptr %tensor.fill.i359, align 4
  %tensor.fill.next367 = add i64 %tensor.fill.current366, 1
  store i64 %tensor.fill.next367, ptr %tensor.fill.i359, align 4
  br label %tensor.fill.cond360

tensor.fill.end362:                               ; preds = %tensor.fill.cond360
  %layer2FfnW1 = alloca ptr, align 8
  store ptr %tensor.malloc346, ptr %layer2FfnW1, align 8
  %tensor.malloc368 = call ptr @malloc(i64 32)
  %tensor.malloc369 = call ptr @malloc(i64 16)
  %tensor.malloc370 = call ptr @malloc(i64 128)
  %tensor.rank.slot371 = getelementptr inbounds %csec.tensor, ptr %tensor.malloc368, i32 0, i32 0
  store i64 2, ptr %tensor.rank.slot371, align 4
  %tensor.dims.slot372 = getelementptr inbounds %csec.tensor, ptr %tensor.malloc368, i32 0, i32 1
  store ptr %tensor.malloc369, ptr %tensor.dims.slot372, align 8
  %tensor.count.slot373 = getelementptr inbounds %csec.tensor, ptr %tensor.malloc368, i32 0, i32 2
  store i64 16, ptr %tensor.count.slot373, align 4
  %tensor.data.slot374 = getelementptr inbounds %csec.tensor, ptr %tensor.malloc368, i32 0, i32 3
  store ptr %tensor.malloc370, ptr %tensor.data.slot374, align 8
  %tensor.dims.ptr375 = getelementptr inbounds %csec.tensor, ptr %tensor.malloc368, i32 0, i32 1
  %tensor.dims376 = load ptr, ptr %tensor.dims.ptr375, align 8
  %tensor.data.ptr377 = getelementptr inbounds %csec.tensor, ptr %tensor.malloc368, i32 0, i32 3
  %tensor.data378 = load ptr, ptr %tensor.data.ptr377, align 8
  %tensor.dim.slot379 = getelementptr i64, ptr %tensor.dims376, i64 0
  store i64 2, ptr %tensor.dim.slot379, align 4
  %tensor.dim.slot380 = getelementptr i64, ptr %tensor.dims376, i64 1
  store i64 8, ptr %tensor.dim.slot380, align 4
  %tensor.fill.i381 = alloca i64, align 8
  store i64 0, ptr %tensor.fill.i381, align 4
  br label %tensor.fill.cond382

tensor.fill.cond382:                              ; preds = %tensor.fill.body383, %tensor.fill.end362
  %tensor.fill.idx385 = load i64, ptr %tensor.fill.i381, align 4
  %tensor.fill.keep386 = icmp ult i64 %tensor.fill.idx385, 16
  br i1 %tensor.fill.keep386, label %tensor.fill.body383, label %tensor.fill.end384

tensor.fill.body383:                              ; preds = %tensor.fill.cond382
  %tensor.data.slot387 = getelementptr double, ptr %tensor.data378, i64 %tensor.fill.idx385
  store double 0.000000e+00, ptr %tensor.data.slot387, align 8
  %tensor.fill.current388 = load i64, ptr %tensor.fill.i381, align 4
  %tensor.fill.next389 = add i64 %tensor.fill.current388, 1
  store i64 %tensor.fill.next389, ptr %tensor.fill.i381, align 4
  br label %tensor.fill.cond382

tensor.fill.end384:                               ; preds = %tensor.fill.cond382
  %calltmp390 = call double @_randomInit(double 1.300000e+01)
  %tensor.malloc391 = call ptr @malloc(i64 32)
  %tensor.malloc392 = call ptr @malloc(i64 16)
  %tensor.malloc393 = call ptr @malloc(i64 256)
  %tensor.rank.slot394 = getelementptr inbounds %csec.tensor, ptr %tensor.malloc391, i32 0, i32 0
  store i64 2, ptr %tensor.rank.slot394, align 4
  %tensor.dims.slot395 = getelementptr inbounds %csec.tensor, ptr %tensor.malloc391, i32 0, i32 1
  store ptr %tensor.malloc392, ptr %tensor.dims.slot395, align 8
  %tensor.count.slot396 = getelementptr inbounds %csec.tensor, ptr %tensor.malloc391, i32 0, i32 2
  store i64 32, ptr %tensor.count.slot396, align 4
  %tensor.data.slot397 = getelementptr inbounds %csec.tensor, ptr %tensor.malloc391, i32 0, i32 3
  store ptr %tensor.malloc393, ptr %tensor.data.slot397, align 8
  %tensor.dims.ptr398 = getelementptr inbounds %csec.tensor, ptr %tensor.malloc391, i32 0, i32 1
  %tensor.dims399 = load ptr, ptr %tensor.dims.ptr398, align 8
  %tensor.data.ptr400 = getelementptr inbounds %csec.tensor, ptr %tensor.malloc391, i32 0, i32 3
  %tensor.data401 = load ptr, ptr %tensor.data.ptr400, align 8
  %tensor.dim.slot402 = getelementptr i64, ptr %tensor.dims399, i64 0
  store i64 8, ptr %tensor.dim.slot402, align 4
  %tensor.dim.slot403 = getelementptr i64, ptr %tensor.dims399, i64 1
  store i64 4, ptr %tensor.dim.slot403, align 4
  %tensor.fill.i404 = alloca i64, align 8
  store i64 0, ptr %tensor.fill.i404, align 4
  br label %tensor.fill.cond405

tensor.fill.cond405:                              ; preds = %tensor.fill.body406, %tensor.fill.end384
  %tensor.fill.idx408 = load i64, ptr %tensor.fill.i404, align 4
  %tensor.fill.keep409 = icmp ult i64 %tensor.fill.idx408, 32
  br i1 %tensor.fill.keep409, label %tensor.fill.body406, label %tensor.fill.end407

tensor.fill.body406:                              ; preds = %tensor.fill.cond405
  %tensor.data.slot410 = getelementptr double, ptr %tensor.data401, i64 %tensor.fill.idx408
  store double %calltmp390, ptr %tensor.data.slot410, align 8
  %tensor.fill.current411 = load i64, ptr %tensor.fill.i404, align 4
  %tensor.fill.next412 = add i64 %tensor.fill.current411, 1
  store i64 %tensor.fill.next412, ptr %tensor.fill.i404, align 4
  br label %tensor.fill.cond405

tensor.fill.end407:                               ; preds = %tensor.fill.cond405
  %layer2FfnW2 = alloca ptr, align 8
  store ptr %tensor.malloc391, ptr %layer2FfnW2, align 8
  %tensor.malloc413 = call ptr @malloc(i64 32)
  %tensor.malloc414 = call ptr @malloc(i64 16)
  %tensor.malloc415 = call ptr @malloc(i64 64)
  %tensor.rank.slot416 = getelementptr inbounds %csec.tensor, ptr %tensor.malloc413, i32 0, i32 0
  store i64 2, ptr %tensor.rank.slot416, align 4
  %tensor.dims.slot417 = getelementptr inbounds %csec.tensor, ptr %tensor.malloc413, i32 0, i32 1
  store ptr %tensor.malloc414, ptr %tensor.dims.slot417, align 8
  %tensor.count.slot418 = getelementptr inbounds %csec.tensor, ptr %tensor.malloc413, i32 0, i32 2
  store i64 8, ptr %tensor.count.slot418, align 4
  %tensor.data.slot419 = getelementptr inbounds %csec.tensor, ptr %tensor.malloc413, i32 0, i32 3
  store ptr %tensor.malloc415, ptr %tensor.data.slot419, align 8
  %tensor.dims.ptr420 = getelementptr inbounds %csec.tensor, ptr %tensor.malloc413, i32 0, i32 1
  %tensor.dims421 = load ptr, ptr %tensor.dims.ptr420, align 8
  %tensor.data.ptr422 = getelementptr inbounds %csec.tensor, ptr %tensor.malloc413, i32 0, i32 3
  %tensor.data423 = load ptr, ptr %tensor.data.ptr422, align 8
  %tensor.dim.slot424 = getelementptr i64, ptr %tensor.dims421, i64 0
  store i64 2, ptr %tensor.dim.slot424, align 4
  %tensor.dim.slot425 = getelementptr i64, ptr %tensor.dims421, i64 1
  store i64 4, ptr %tensor.dim.slot425, align 4
  %tensor.fill.i426 = alloca i64, align 8
  store i64 0, ptr %tensor.fill.i426, align 4
  br label %tensor.fill.cond427

tensor.fill.cond427:                              ; preds = %tensor.fill.body428, %tensor.fill.end407
  %tensor.fill.idx430 = load i64, ptr %tensor.fill.i426, align 4
  %tensor.fill.keep431 = icmp ult i64 %tensor.fill.idx430, 8
  br i1 %tensor.fill.keep431, label %tensor.fill.body428, label %tensor.fill.end429

tensor.fill.body428:                              ; preds = %tensor.fill.cond427
  %tensor.data.slot432 = getelementptr double, ptr %tensor.data423, i64 %tensor.fill.idx430
  store double 0.000000e+00, ptr %tensor.data.slot432, align 8
  %tensor.fill.current433 = load i64, ptr %tensor.fill.i426, align 4
  %tensor.fill.next434 = add i64 %tensor.fill.current433, 1
  store i64 %tensor.fill.next434, ptr %tensor.fill.i426, align 4
  br label %tensor.fill.cond427

tensor.fill.end429:                               ; preds = %tensor.fill.cond427
  %layer1Wq.load = load ptr, ptr %layer1Wq, align 8
  %layer1Wk.load = load ptr, ptr %layer1Wk, align 8
  %layer1Wv.load = load ptr, ptr %layer1Wv, align 8
  %layer1Wo.load = load ptr, ptr %layer1Wo, align 8
  %layer1FfnW1.load = load ptr, ptr %layer1FfnW1, align 8
  %layer1FfnW2.load = load ptr, ptr %layer1FfnW2, align 8
  %layer2Wq.load = load ptr, ptr %layer2Wq, align 8
  %layer2Wk.load = load ptr, ptr %layer2Wk, align 8
  %layer2Wv.load = load ptr, ptr %layer2Wv, align 8
  %layer2Wo.load = load ptr, ptr %layer2Wo, align 8
  %layer2FfnW1.load = load ptr, ptr %layer2FfnW1, align 8
  %layer2FfnW2.load = load ptr, ptr %layer2FfnW2, align 8
  %calltmp435 = call ptr @_transformerEncoder2Layer(ptr %tensor.malloc, ptr %layer1Wq.load, ptr %layer1Wk.load, ptr %layer1Wv.load, ptr %layer1Wo.load, ptr %tensor.malloc119, ptr %layer1FfnW1.load, ptr %tensor.malloc164, ptr %layer1FfnW2.load, ptr %tensor.malloc209, ptr %layer2Wq.load, ptr %layer2Wk.load, ptr %layer2Wv.load, ptr %layer2Wo.load, ptr %tensor.malloc323, ptr %layer2FfnW1.load, ptr %tensor.malloc368, ptr %layer2FfnW2.load, ptr %tensor.malloc413)
  %encoded = alloca ptr, align 8
  store ptr %calltmp435, ptr %encoded, align 8
  br label %whilecond

whilecond:                                        ; preds = %whilebody, %tensor.fill.end429
  %epoch.load = load i32, ptr %epoch, align 4
  %lttmp = icmp slt i32 %epoch.load, 3
  br i1 %lttmp, label %whilebody, label %afterwhile

whilebody:                                        ; preds = %whilecond
  %encoded.load = load ptr, ptr %encoded, align 8
  %layer1Wq.load436 = load ptr, ptr %layer1Wq, align 8
  %layer1Wk.load437 = load ptr, ptr %layer1Wk, align 8
  %layer1Wv.load438 = load ptr, ptr %layer1Wv, align 8
  %layer1Wo.load439 = load ptr, ptr %layer1Wo, align 8
  %layer1FfnW1.load440 = load ptr, ptr %layer1FfnW1, align 8
  %layer1FfnW2.load441 = load ptr, ptr %layer1FfnW2, align 8
  %layer2Wq.load442 = load ptr, ptr %layer2Wq, align 8
  %layer2Wk.load443 = load ptr, ptr %layer2Wk, align 8
  %layer2Wv.load444 = load ptr, ptr %layer2Wv, align 8
  %layer2Wo.load445 = load ptr, ptr %layer2Wo, align 8
  %layer2FfnW1.load446 = load ptr, ptr %layer2FfnW1, align 8
  %layer2FfnW2.load447 = load ptr, ptr %layer2FfnW2, align 8
  %calltmp448 = call ptr @_transformerEncoder2Layer(ptr %tensor.malloc, ptr %layer1Wq.load436, ptr %layer1Wk.load437, ptr %layer1Wv.load438, ptr %layer1Wo.load439, ptr %tensor.malloc119, ptr %layer1FfnW1.load440, ptr %tensor.malloc164, ptr %layer1FfnW2.load441, ptr %tensor.malloc209, ptr %layer2Wq.load442, ptr %layer2Wk.load443, ptr %layer2Wv.load444, ptr %layer2Wo.load445, ptr %tensor.malloc323, ptr %layer2FfnW1.load446, ptr %tensor.malloc368, ptr %layer2FfnW2.load447, ptr %tensor.malloc413)
  store ptr %calltmp448, ptr %encoded, align 8
  %loss.load = load double, ptr %loss, align 8
  %encoded.load449 = load ptr, ptr %encoded, align 8
  %calltmp450 = call double @_mseLoss(ptr %encoded.load449, ptr %tensor.malloc5)
  store double %calltmp450, ptr %loss, align 8
  %layer1Wq.load451 = load ptr, ptr %layer1Wq, align 8
  %layer1Wq.load452 = load ptr, ptr %layer1Wq, align 8
  %learningRate.load = load float, ptr %learningRate, align 4
  %loss.load453 = load double, ptr %loss, align 8
  %abi.fpcast = fpext float %learningRate.load to double
  %calltmp454 = call ptr @_sgd4x4(ptr %layer1Wq.load452, double %abi.fpcast, double %loss.load453)
  store ptr %calltmp454, ptr %layer1Wq, align 8
  %layer1Wk.load455 = load ptr, ptr %layer1Wk, align 8
  %layer1Wk.load456 = load ptr, ptr %layer1Wk, align 8
  %learningRate.load457 = load float, ptr %learningRate, align 4
  %loss.load458 = load double, ptr %loss, align 8
  %abi.fpcast459 = fpext float %learningRate.load457 to double
  %calltmp460 = call ptr @_sgd4x4(ptr %layer1Wk.load456, double %abi.fpcast459, double %loss.load458)
  store ptr %calltmp460, ptr %layer1Wk, align 8
  %layer1Wv.load461 = load ptr, ptr %layer1Wv, align 8
  %layer1Wv.load462 = load ptr, ptr %layer1Wv, align 8
  %learningRate.load463 = load float, ptr %learningRate, align 4
  %loss.load464 = load double, ptr %loss, align 8
  %abi.fpcast465 = fpext float %learningRate.load463 to double
  %calltmp466 = call ptr @_sgd4x4(ptr %layer1Wv.load462, double %abi.fpcast465, double %loss.load464)
  store ptr %calltmp466, ptr %layer1Wv, align 8
  %layer1Wo.load467 = load ptr, ptr %layer1Wo, align 8
  %layer1Wo.load468 = load ptr, ptr %layer1Wo, align 8
  %learningRate.load469 = load float, ptr %learningRate, align 4
  %loss.load470 = load double, ptr %loss, align 8
  %abi.fpcast471 = fpext float %learningRate.load469 to double
  %calltmp472 = call ptr @_sgd4x4(ptr %layer1Wo.load468, double %abi.fpcast471, double %loss.load470)
  store ptr %calltmp472, ptr %layer1Wo, align 8
  %layer1FfnW1.load473 = load ptr, ptr %layer1FfnW1, align 8
  %layer1FfnW1.load474 = load ptr, ptr %layer1FfnW1, align 8
  %learningRate.load475 = load float, ptr %learningRate, align 4
  %loss.load476 = load double, ptr %loss, align 8
  %abi.fpcast477 = fpext float %learningRate.load475 to double
  %calltmp478 = call ptr @_sgd4x8(ptr %layer1FfnW1.load474, double %abi.fpcast477, double %loss.load476)
  store ptr %calltmp478, ptr %layer1FfnW1, align 8
  %layer1FfnW2.load479 = load ptr, ptr %layer1FfnW2, align 8
  %layer1FfnW2.load480 = load ptr, ptr %layer1FfnW2, align 8
  %learningRate.load481 = load float, ptr %learningRate, align 4
  %loss.load482 = load double, ptr %loss, align 8
  %abi.fpcast483 = fpext float %learningRate.load481 to double
  %calltmp484 = call ptr @_sgd8x4(ptr %layer1FfnW2.load480, double %abi.fpcast483, double %loss.load482)
  store ptr %calltmp484, ptr %layer1FfnW2, align 8
  %layer2Wq.load485 = load ptr, ptr %layer2Wq, align 8
  %layer2Wq.load486 = load ptr, ptr %layer2Wq, align 8
  %learningRate.load487 = load float, ptr %learningRate, align 4
  %loss.load488 = load double, ptr %loss, align 8
  %abi.fpcast489 = fpext float %learningRate.load487 to double
  %calltmp490 = call ptr @_sgd4x4(ptr %layer2Wq.load486, double %abi.fpcast489, double %loss.load488)
  store ptr %calltmp490, ptr %layer2Wq, align 8
  %layer2Wk.load491 = load ptr, ptr %layer2Wk, align 8
  %layer2Wk.load492 = load ptr, ptr %layer2Wk, align 8
  %learningRate.load493 = load float, ptr %learningRate, align 4
  %loss.load494 = load double, ptr %loss, align 8
  %abi.fpcast495 = fpext float %learningRate.load493 to double
  %calltmp496 = call ptr @_sgd4x4(ptr %layer2Wk.load492, double %abi.fpcast495, double %loss.load494)
  store ptr %calltmp496, ptr %layer2Wk, align 8
  %layer2Wv.load497 = load ptr, ptr %layer2Wv, align 8
  %layer2Wv.load498 = load ptr, ptr %layer2Wv, align 8
  %learningRate.load499 = load float, ptr %learningRate, align 4
  %loss.load500 = load double, ptr %loss, align 8
  %abi.fpcast501 = fpext float %learningRate.load499 to double
  %calltmp502 = call ptr @_sgd4x4(ptr %layer2Wv.load498, double %abi.fpcast501, double %loss.load500)
  store ptr %calltmp502, ptr %layer2Wv, align 8
  %layer2Wo.load503 = load ptr, ptr %layer2Wo, align 8
  %layer2Wo.load504 = load ptr, ptr %layer2Wo, align 8
  %learningRate.load505 = load float, ptr %learningRate, align 4
  %loss.load506 = load double, ptr %loss, align 8
  %abi.fpcast507 = fpext float %learningRate.load505 to double
  %calltmp508 = call ptr @_sgd4x4(ptr %layer2Wo.load504, double %abi.fpcast507, double %loss.load506)
  store ptr %calltmp508, ptr %layer2Wo, align 8
  %layer2FfnW1.load509 = load ptr, ptr %layer2FfnW1, align 8
  %layer2FfnW1.load510 = load ptr, ptr %layer2FfnW1, align 8
  %learningRate.load511 = load float, ptr %learningRate, align 4
  %loss.load512 = load double, ptr %loss, align 8
  %abi.fpcast513 = fpext float %learningRate.load511 to double
  %calltmp514 = call ptr @_sgd4x8(ptr %layer2FfnW1.load510, double %abi.fpcast513, double %loss.load512)
  store ptr %calltmp514, ptr %layer2FfnW1, align 8
  %layer2FfnW2.load515 = load ptr, ptr %layer2FfnW2, align 8
  %layer2FfnW2.load516 = load ptr, ptr %layer2FfnW2, align 8
  %learningRate.load517 = load float, ptr %learningRate, align 4
  %loss.load518 = load double, ptr %loss, align 8
  %abi.fpcast519 = fpext float %learningRate.load517 to double
  %calltmp520 = call ptr @_sgd8x4(ptr %layer2FfnW2.load516, double %abi.fpcast519, double %loss.load518)
  store ptr %calltmp520, ptr %layer2FfnW2, align 8
  %epoch.load521 = load i32, ptr %epoch, align 4
  %epoch.load522 = load i32, ptr %epoch, align 4
  %addtmp = add i32 %epoch.load522, 1
  store i32 %addtmp, ptr %epoch, align 4
  br label %whilecond

afterwhile:                                       ; preds = %whilecond
  %encoded.load523 = load ptr, ptr %encoded, align 8
  %tensor.rank.ptr = getelementptr inbounds %csec.tensor, ptr %encoded.load523, i32 0, i32 0
  %tensor.rank = load i64, ptr %tensor.rank.ptr, align 4
  %tensor.dims.ptr524 = getelementptr inbounds %csec.tensor, ptr %encoded.load523, i32 0, i32 1
  %tensor.dims525 = load ptr, ptr %tensor.dims.ptr524, align 8
  %tensor.data.ptr526 = getelementptr inbounds %csec.tensor, ptr %encoded.load523, i32 0, i32 3
  %tensor.data527 = load ptr, ptr %tensor.data.ptr526, align 8
  %tensor.index.coords = alloca i64, i64 %tensor.rank, align 8
  %tensor.index.coord.slot = getelementptr i64, ptr %tensor.index.coords, i64 0
  store i64 0, ptr %tensor.index.coord.slot, align 4
  %tensor.index.coord.slot528 = getelementptr i64, ptr %tensor.index.coords, i64 1
  store i64 0, ptr %tensor.index.coord.slot528, align 4
  %tensor.linear.ptr = alloca i64, align 8
  store i64 0, ptr %tensor.linear.ptr, align 4
  %tensor.linear.i = alloca i64, align 8
  store i64 0, ptr %tensor.linear.i, align 4
  br label %tensor.linear.cond

tensor.linear.cond:                               ; preds = %tensor.linear.body, %afterwhile
  %tensor.linear.idx = load i64, ptr %tensor.linear.i, align 4
  %tensor.linear.keep = icmp ult i64 %tensor.linear.idx, %tensor.rank
  br i1 %tensor.linear.keep, label %tensor.linear.body, label %tensor.linear.end

tensor.linear.body:                               ; preds = %tensor.linear.cond
  %tensor.linear.dim.ptr = getelementptr i64, ptr %tensor.dims525, i64 %tensor.linear.idx
  %tensor.linear.dim = load i64, ptr %tensor.linear.dim.ptr, align 4
  %tensor.linear.coord.ptr = getelementptr i64, ptr %tensor.index.coords, i64 %tensor.linear.idx
  %tensor.linear.coord = load i64, ptr %tensor.linear.coord.ptr, align 4
  %tensor.linear.current = load i64, ptr %tensor.linear.ptr, align 4
  %tensor.linear.mul = mul i64 %tensor.linear.current, %tensor.linear.dim
  %tensor.linear.next = add i64 %tensor.linear.mul, %tensor.linear.coord
  store i64 %tensor.linear.next, ptr %tensor.linear.ptr, align 4
  %tensor.linear.current529 = load i64, ptr %tensor.linear.i, align 4
  %tensor.linear.next530 = add i64 %tensor.linear.current529, 1
  store i64 %tensor.linear.next530, ptr %tensor.linear.i, align 4
  br label %tensor.linear.cond

tensor.linear.end:                                ; preds = %tensor.linear.cond
  %tensor.linear.result = load i64, ptr %tensor.linear.ptr, align 4
  %tensor.index.data = getelementptr double, ptr %tensor.data527, i64 %tensor.linear.result
  %tensor.index.value = load double, ptr %tensor.index.data, align 8
  %firstTokenFirstChannel = alloca double, align 8
  store double %tensor.index.value, ptr %firstTokenFirstChannel, align 8
  ret i32 0
}

declare ptr @csec_string_concat(ptr, ptr)

declare double @csec_math_sin(double)

declare void @csec_set_command_line_args(i32, ptr)

define internal i32 @__csec_jit_entry() {
entry:
  %user.main = call i32 @_main()
  ret i32 %user.main
}
