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
  %tensor.malloc1 = call ptr @malloc(i64 16)
  %tensor.malloc2 = call ptr @malloc(i64 32)
  %tensor.rank.slot = getelementptr inbounds %csec.tensor, ptr %tensor.malloc, i32 0, i32 0
  store i64 2, ptr %tensor.rank.slot, align 4
  %tensor.dims.slot = getelementptr inbounds %csec.tensor, ptr %tensor.malloc, i32 0, i32 1
  store ptr %tensor.malloc1, ptr %tensor.dims.slot, align 8
  %tensor.count.slot = getelementptr inbounds %csec.tensor, ptr %tensor.malloc, i32 0, i32 2
  store i64 4, ptr %tensor.count.slot, align 4
  %tensor.data.slot = getelementptr inbounds %csec.tensor, ptr %tensor.malloc, i32 0, i32 3
  store ptr %tensor.malloc2, ptr %tensor.data.slot, align 8
  %tensor.dims.ptr = getelementptr inbounds %csec.tensor, ptr %tensor.malloc, i32 0, i32 1
  %tensor.dims = load ptr, ptr %tensor.dims.ptr, align 8
  %tensor.data.ptr = getelementptr inbounds %csec.tensor, ptr %tensor.malloc, i32 0, i32 3
  %tensor.data = load ptr, ptr %tensor.data.ptr, align 8
  %tensor.dim.slot = getelementptr i64, ptr %tensor.dims, i64 0
  store i64 2, ptr %tensor.dim.slot, align 4
  %tensor.dim.slot3 = getelementptr i64, ptr %tensor.dims, i64 1
  store i64 2, ptr %tensor.dim.slot3, align 4
  br label %tensor.fill.cond

tensor.fill.cond:                                 ; preds = %tensor.fill.body, %entry
  %tensor.fill.i.0 = phi i64 [ 0, %entry ], [ %tensor.fill.next, %tensor.fill.body ]
  %tensor.fill.keep = icmp ult i64 %tensor.fill.i.0, 4
  br i1 %tensor.fill.keep, label %tensor.fill.body, label %tensor.fill.end

tensor.fill.body:                                 ; preds = %tensor.fill.cond
  %tensor.data.slot4 = getelementptr double, ptr %tensor.data, i64 %tensor.fill.i.0
  store double 1.000000e+00, ptr %tensor.data.slot4, align 8
  %tensor.fill.next = add i64 %tensor.fill.i.0, 1
  br label %tensor.fill.cond

tensor.fill.end:                                  ; preds = %tensor.fill.cond
  %tensor.malloc5 = call ptr @malloc(i64 32)
  %tensor.malloc6 = call ptr @malloc(i64 16)
  %tensor.malloc7 = call ptr @malloc(i64 32)
  %tensor.rank.slot8 = getelementptr inbounds %csec.tensor, ptr %tensor.malloc5, i32 0, i32 0
  store i64 2, ptr %tensor.rank.slot8, align 4
  %tensor.dims.slot9 = getelementptr inbounds %csec.tensor, ptr %tensor.malloc5, i32 0, i32 1
  store ptr %tensor.malloc6, ptr %tensor.dims.slot9, align 8
  %tensor.count.slot10 = getelementptr inbounds %csec.tensor, ptr %tensor.malloc5, i32 0, i32 2
  store i64 4, ptr %tensor.count.slot10, align 4
  %tensor.data.slot11 = getelementptr inbounds %csec.tensor, ptr %tensor.malloc5, i32 0, i32 3
  store ptr %tensor.malloc7, ptr %tensor.data.slot11, align 8
  %tensor.dims.ptr12 = getelementptr inbounds %csec.tensor, ptr %tensor.malloc5, i32 0, i32 1
  %tensor.dims13 = load ptr, ptr %tensor.dims.ptr12, align 8
  %tensor.data.ptr14 = getelementptr inbounds %csec.tensor, ptr %tensor.malloc5, i32 0, i32 3
  %tensor.data15 = load ptr, ptr %tensor.data.ptr14, align 8
  %tensor.dim.slot16 = getelementptr i64, ptr %tensor.dims13, i64 0
  store i64 2, ptr %tensor.dim.slot16, align 4
  %tensor.dim.slot17 = getelementptr i64, ptr %tensor.dims13, i64 1
  store i64 2, ptr %tensor.dim.slot17, align 4
  %tensor.fill.i18 = alloca i64, align 8
  store i64 0, ptr %tensor.fill.i18, align 4
  br label %tensor.fill.cond19

tensor.fill.cond19:                               ; preds = %tensor.fill.body20, %tensor.fill.end
  %tensor.fill.idx22 = load i64, ptr %tensor.fill.i18, align 4
  %tensor.fill.keep23 = icmp ult i64 %tensor.fill.idx22, 4
  br i1 %tensor.fill.keep23, label %tensor.fill.body20, label %tensor.fill.end21

tensor.fill.body20:                               ; preds = %tensor.fill.cond19
  %tensor.data.slot24 = getelementptr double, ptr %tensor.data15, i64 %tensor.fill.idx22
  store double 2.000000e+00, ptr %tensor.data.slot24, align 8
  %tensor.fill.current25 = load i64, ptr %tensor.fill.i18, align 4
  %tensor.fill.next26 = add i64 %tensor.fill.current25, 1
  store i64 %tensor.fill.next26, ptr %tensor.fill.i18, align 4
  br label %tensor.fill.cond19

tensor.fill.end21:                                ; preds = %tensor.fill.cond19
  %str.concat = call ptr @csec_string_concat(ptr null, ptr null)
  %sum = alloca ptr, align 8
  store ptr %str.concat, ptr %sum, align 8
  %tensor.rank.ptr = getelementptr inbounds %csec.tensor, ptr %tensor.malloc, i32 0, i32 0
  %tensor.rank = load i64, ptr %tensor.rank.ptr, align 4
  %tensor.count.ptr = getelementptr inbounds %csec.tensor, ptr %tensor.malloc, i32 0, i32 2
  %tensor.count = load i64, ptr %tensor.count.ptr, align 4
  %tensor.malloc27 = call ptr @malloc(i64 32)
  %tensor.dims.bytes = mul i64 %tensor.rank, 8
  %tensor.malloc28 = call ptr @malloc(i64 %tensor.dims.bytes)
  %tensor.data.bytes = mul i64 %tensor.count, 8
  %tensor.malloc29 = call ptr @malloc(i64 %tensor.data.bytes)
  %tensor.rank.slot30 = getelementptr inbounds %csec.tensor, ptr %tensor.malloc27, i32 0, i32 0
  store i64 %tensor.rank, ptr %tensor.rank.slot30, align 4
  %tensor.dims.slot31 = getelementptr inbounds %csec.tensor, ptr %tensor.malloc27, i32 0, i32 1
  store ptr %tensor.malloc28, ptr %tensor.dims.slot31, align 8
  %tensor.count.slot32 = getelementptr inbounds %csec.tensor, ptr %tensor.malloc27, i32 0, i32 2
  store i64 %tensor.count, ptr %tensor.count.slot32, align 4
  %tensor.data.slot33 = getelementptr inbounds %csec.tensor, ptr %tensor.malloc27, i32 0, i32 3
  store ptr %tensor.malloc29, ptr %tensor.data.slot33, align 8
  %tensor.dims.ptr34 = getelementptr inbounds %csec.tensor, ptr %tensor.malloc, i32 0, i32 1
  %tensor.dims35 = load ptr, ptr %tensor.dims.ptr34, align 8
  %tensor.dims.ptr36 = getelementptr inbounds %csec.tensor, ptr %tensor.malloc27, i32 0, i32 1
  %tensor.dims37 = load ptr, ptr %tensor.dims.ptr36, align 8
  %tensor.data.ptr38 = getelementptr inbounds %csec.tensor, ptr %tensor.malloc, i32 0, i32 3
  %tensor.data39 = load ptr, ptr %tensor.data.ptr38, align 8
  %tensor.data.ptr40 = getelementptr inbounds %csec.tensor, ptr %tensor.malloc5, i32 0, i32 3
  %tensor.data41 = load ptr, ptr %tensor.data.ptr40, align 8
  %tensor.data.ptr42 = getelementptr inbounds %csec.tensor, ptr %tensor.malloc27, i32 0, i32 3
  %tensor.data43 = load ptr, ptr %tensor.data.ptr42, align 8
  %tensor.elem.dims.i = alloca i64, align 8
  store i64 0, ptr %tensor.elem.dims.i, align 4
  br label %tensor.elem.dims.cond

tensor.elem.dims.cond:                            ; preds = %tensor.elem.dims.body, %tensor.fill.end21
  %tensor.elem.dims.idx = load i64, ptr %tensor.elem.dims.i, align 4
  %tensor.elem.dims.keep = icmp ult i64 %tensor.elem.dims.idx, %tensor.rank
  br i1 %tensor.elem.dims.keep, label %tensor.elem.dims.body, label %tensor.elem.dims.end

tensor.elem.dims.body:                            ; preds = %tensor.elem.dims.cond
  %tensor.elem.src.dim = getelementptr i64, ptr %tensor.dims35, i64 %tensor.elem.dims.idx
  %tensor.elem.dst.dim = getelementptr i64, ptr %tensor.dims37, i64 %tensor.elem.dims.idx
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
  %tensor.elem.left = getelementptr double, ptr %tensor.data39, i64 %tensor.elem.data.idx
  %tensor.elem.l = load double, ptr %tensor.elem.left, align 8
  %tensor.elem.right = getelementptr double, ptr %tensor.data41, i64 %tensor.elem.data.idx
  %tensor.elem.r = load double, ptr %tensor.elem.right, align 8
  %tensor.elem.dst = getelementptr double, ptr %tensor.data43, i64 %tensor.elem.data.idx
  %tensor.sub = fsub double %tensor.elem.l, %tensor.elem.r
  store double %tensor.sub, ptr %tensor.elem.dst, align 8
  %tensor.elem.data.current = load i64, ptr %tensor.elem.data.i, align 4
  %tensor.elem.data.next = add i64 %tensor.elem.data.current, 1
  store i64 %tensor.elem.data.next, ptr %tensor.elem.data.i, align 4
  br label %tensor.elem.data.cond

tensor.elem.data.end:                             ; preds = %tensor.elem.data.cond
  %diff = alloca ptr, align 8
  store ptr %tensor.malloc27, ptr %diff, align 8
  %tensor.rank.ptr44 = getelementptr inbounds %csec.tensor, ptr %tensor.malloc, i32 0, i32 0
  %tensor.rank45 = load i64, ptr %tensor.rank.ptr44, align 4
  %tensor.count.ptr46 = getelementptr inbounds %csec.tensor, ptr %tensor.malloc, i32 0, i32 2
  %tensor.count47 = load i64, ptr %tensor.count.ptr46, align 4
  %tensor.malloc48 = call ptr @malloc(i64 32)
  %tensor.dims.bytes49 = mul i64 %tensor.rank45, 8
  %tensor.malloc50 = call ptr @malloc(i64 %tensor.dims.bytes49)
  %tensor.data.bytes51 = mul i64 %tensor.count47, 8
  %tensor.malloc52 = call ptr @malloc(i64 %tensor.data.bytes51)
  %tensor.rank.slot53 = getelementptr inbounds %csec.tensor, ptr %tensor.malloc48, i32 0, i32 0
  store i64 %tensor.rank45, ptr %tensor.rank.slot53, align 4
  %tensor.dims.slot54 = getelementptr inbounds %csec.tensor, ptr %tensor.malloc48, i32 0, i32 1
  store ptr %tensor.malloc50, ptr %tensor.dims.slot54, align 8
  %tensor.count.slot55 = getelementptr inbounds %csec.tensor, ptr %tensor.malloc48, i32 0, i32 2
  store i64 %tensor.count47, ptr %tensor.count.slot55, align 4
  %tensor.data.slot56 = getelementptr inbounds %csec.tensor, ptr %tensor.malloc48, i32 0, i32 3
  store ptr %tensor.malloc52, ptr %tensor.data.slot56, align 8
  %tensor.dims.ptr57 = getelementptr inbounds %csec.tensor, ptr %tensor.malloc, i32 0, i32 1
  %tensor.dims58 = load ptr, ptr %tensor.dims.ptr57, align 8
  %tensor.dims.ptr59 = getelementptr inbounds %csec.tensor, ptr %tensor.malloc48, i32 0, i32 1
  %tensor.dims60 = load ptr, ptr %tensor.dims.ptr59, align 8
  %tensor.data.ptr61 = getelementptr inbounds %csec.tensor, ptr %tensor.malloc, i32 0, i32 3
  %tensor.data62 = load ptr, ptr %tensor.data.ptr61, align 8
  %tensor.data.ptr63 = getelementptr inbounds %csec.tensor, ptr %tensor.malloc5, i32 0, i32 3
  %tensor.data64 = load ptr, ptr %tensor.data.ptr63, align 8
  %tensor.data.ptr65 = getelementptr inbounds %csec.tensor, ptr %tensor.malloc48, i32 0, i32 3
  %tensor.data66 = load ptr, ptr %tensor.data.ptr65, align 8
  %tensor.elem.dims.i67 = alloca i64, align 8
  store i64 0, ptr %tensor.elem.dims.i67, align 4
  br label %tensor.elem.dims.cond68

tensor.elem.dims.cond68:                          ; preds = %tensor.elem.dims.body69, %tensor.elem.data.end
  %tensor.elem.dims.idx71 = load i64, ptr %tensor.elem.dims.i67, align 4
  %tensor.elem.dims.keep72 = icmp ult i64 %tensor.elem.dims.idx71, %tensor.rank45
  br i1 %tensor.elem.dims.keep72, label %tensor.elem.dims.body69, label %tensor.elem.dims.end70

tensor.elem.dims.body69:                          ; preds = %tensor.elem.dims.cond68
  %tensor.elem.src.dim73 = getelementptr i64, ptr %tensor.dims58, i64 %tensor.elem.dims.idx71
  %tensor.elem.dst.dim74 = getelementptr i64, ptr %tensor.dims60, i64 %tensor.elem.dims.idx71
  %tensor.elem.dim75 = load i64, ptr %tensor.elem.src.dim73, align 4
  store i64 %tensor.elem.dim75, ptr %tensor.elem.dst.dim74, align 4
  %tensor.elem.dims.current76 = load i64, ptr %tensor.elem.dims.i67, align 4
  %tensor.elem.dims.next77 = add i64 %tensor.elem.dims.current76, 1
  store i64 %tensor.elem.dims.next77, ptr %tensor.elem.dims.i67, align 4
  br label %tensor.elem.dims.cond68

tensor.elem.dims.end70:                           ; preds = %tensor.elem.dims.cond68
  %tensor.elem.data.i78 = alloca i64, align 8
  store i64 0, ptr %tensor.elem.data.i78, align 4
  br label %tensor.elem.data.cond79

tensor.elem.data.cond79:                          ; preds = %tensor.elem.data.body80, %tensor.elem.dims.end70
  %tensor.elem.data.idx82 = load i64, ptr %tensor.elem.data.i78, align 4
  %tensor.elem.data.keep83 = icmp ult i64 %tensor.elem.data.idx82, %tensor.count47
  br i1 %tensor.elem.data.keep83, label %tensor.elem.data.body80, label %tensor.elem.data.end81

tensor.elem.data.body80:                          ; preds = %tensor.elem.data.cond79
  %tensor.elem.left84 = getelementptr double, ptr %tensor.data62, i64 %tensor.elem.data.idx82
  %tensor.elem.l85 = load double, ptr %tensor.elem.left84, align 8
  %tensor.elem.right86 = getelementptr double, ptr %tensor.data64, i64 %tensor.elem.data.idx82
  %tensor.elem.r87 = load double, ptr %tensor.elem.right86, align 8
  %tensor.elem.dst88 = getelementptr double, ptr %tensor.data66, i64 %tensor.elem.data.idx82
  %tensor.mul = fmul double %tensor.elem.l85, %tensor.elem.r87
  store double %tensor.mul, ptr %tensor.elem.dst88, align 8
  %tensor.elem.data.current89 = load i64, ptr %tensor.elem.data.i78, align 4
  %tensor.elem.data.next90 = add i64 %tensor.elem.data.current89, 1
  store i64 %tensor.elem.data.next90, ptr %tensor.elem.data.i78, align 4
  br label %tensor.elem.data.cond79

tensor.elem.data.end81:                           ; preds = %tensor.elem.data.cond79
  %product = alloca ptr, align 8
  store ptr %tensor.malloc48, ptr %product, align 8
  %tensor.rank.ptr91 = getelementptr inbounds %csec.tensor, ptr %tensor.malloc, i32 0, i32 0
  %tensor.rank92 = load i64, ptr %tensor.rank.ptr91, align 4
  %tensor.count.ptr93 = getelementptr inbounds %csec.tensor, ptr %tensor.malloc, i32 0, i32 2
  %tensor.count94 = load i64, ptr %tensor.count.ptr93, align 4
  %tensor.malloc95 = call ptr @malloc(i64 32)
  %tensor.dims.bytes96 = mul i64 %tensor.rank92, 8
  %tensor.malloc97 = call ptr @malloc(i64 %tensor.dims.bytes96)
  %tensor.data.bytes98 = mul i64 %tensor.count94, 8
  %tensor.malloc99 = call ptr @malloc(i64 %tensor.data.bytes98)
  %tensor.rank.slot100 = getelementptr inbounds %csec.tensor, ptr %tensor.malloc95, i32 0, i32 0
  store i64 %tensor.rank92, ptr %tensor.rank.slot100, align 4
  %tensor.dims.slot101 = getelementptr inbounds %csec.tensor, ptr %tensor.malloc95, i32 0, i32 1
  store ptr %tensor.malloc97, ptr %tensor.dims.slot101, align 8
  %tensor.count.slot102 = getelementptr inbounds %csec.tensor, ptr %tensor.malloc95, i32 0, i32 2
  store i64 %tensor.count94, ptr %tensor.count.slot102, align 4
  %tensor.data.slot103 = getelementptr inbounds %csec.tensor, ptr %tensor.malloc95, i32 0, i32 3
  store ptr %tensor.malloc99, ptr %tensor.data.slot103, align 8
  %tensor.dims.ptr104 = getelementptr inbounds %csec.tensor, ptr %tensor.malloc, i32 0, i32 1
  %tensor.dims105 = load ptr, ptr %tensor.dims.ptr104, align 8
  %tensor.dims.ptr106 = getelementptr inbounds %csec.tensor, ptr %tensor.malloc95, i32 0, i32 1
  %tensor.dims107 = load ptr, ptr %tensor.dims.ptr106, align 8
  %tensor.data.ptr108 = getelementptr inbounds %csec.tensor, ptr %tensor.malloc, i32 0, i32 3
  %tensor.data109 = load ptr, ptr %tensor.data.ptr108, align 8
  %tensor.data.ptr110 = getelementptr inbounds %csec.tensor, ptr %tensor.malloc95, i32 0, i32 3
  %tensor.data111 = load ptr, ptr %tensor.data.ptr110, align 8
  %tensor.scalar.dims.i = alloca i64, align 8
  store i64 0, ptr %tensor.scalar.dims.i, align 4
  br label %tensor.scalar.dims.cond

tensor.scalar.dims.cond:                          ; preds = %tensor.scalar.dims.body, %tensor.elem.data.end81
  %tensor.scalar.dims.idx = load i64, ptr %tensor.scalar.dims.i, align 4
  %tensor.scalar.dims.keep = icmp ult i64 %tensor.scalar.dims.idx, %tensor.rank92
  br i1 %tensor.scalar.dims.keep, label %tensor.scalar.dims.body, label %tensor.scalar.dims.end

tensor.scalar.dims.body:                          ; preds = %tensor.scalar.dims.cond
  %tensor.scalar.src.dim = getelementptr i64, ptr %tensor.dims105, i64 %tensor.scalar.dims.idx
  %tensor.scalar.dst.dim = getelementptr i64, ptr %tensor.dims107, i64 %tensor.scalar.dims.idx
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
  %tensor.scalar.data.keep = icmp ult i64 %tensor.scalar.data.idx, %tensor.count94
  br i1 %tensor.scalar.data.keep, label %tensor.scalar.data.body, label %tensor.scalar.data.end

tensor.scalar.data.body:                          ; preds = %tensor.scalar.data.cond
  %tensor.scalar.src = getelementptr double, ptr %tensor.data109, i64 %tensor.scalar.data.idx
  %tensor.scalar.tensor = load double, ptr %tensor.scalar.src, align 8
  %tensor.scalar.dst = getelementptr double, ptr %tensor.data111, i64 %tensor.scalar.data.idx
  %tensor.mul112 = fmul double %tensor.scalar.tensor, 3.000000e+00
  store double %tensor.mul112, ptr %tensor.scalar.dst, align 8
  %tensor.scalar.data.current = load i64, ptr %tensor.scalar.data.i, align 4
  %tensor.scalar.data.next = add i64 %tensor.scalar.data.current, 1
  store i64 %tensor.scalar.data.next, ptr %tensor.scalar.data.i, align 4
  br label %tensor.scalar.data.cond

tensor.scalar.data.end:                           ; preds = %tensor.scalar.data.cond
  %scaled = alloca ptr, align 8
  store ptr %tensor.malloc95, ptr %scaled, align 8
  %tensor.dims.ptr113 = getelementptr inbounds %csec.tensor, ptr %tensor.malloc, i32 0, i32 1
  %tensor.dims114 = load ptr, ptr %tensor.dims.ptr113, align 8
  %tensor.dims.ptr115 = getelementptr inbounds %csec.tensor, ptr %tensor.malloc5, i32 0, i32 1
  %tensor.dims116 = load ptr, ptr %tensor.dims.ptr115, align 8
  %tensor.matmul.rows.ptr = getelementptr i64, ptr %tensor.dims114, i64 0
  %tensor.matmul.rows = load i64, ptr %tensor.matmul.rows.ptr, align 4
  %tensor.matmul.shared.ptr = getelementptr i64, ptr %tensor.dims114, i64 1
  %tensor.matmul.shared = load i64, ptr %tensor.matmul.shared.ptr, align 4
  %tensor.matmul.cols.ptr = getelementptr i64, ptr %tensor.dims116, i64 1
  %tensor.matmul.cols = load i64, ptr %tensor.matmul.cols.ptr, align 4
  %tensor.matmul.count = mul i64 %tensor.matmul.rows, %tensor.matmul.cols
  %tensor.malloc117 = call ptr @malloc(i64 32)
  %tensor.malloc118 = call ptr @malloc(i64 16)
  %tensor.data.bytes119 = mul i64 %tensor.matmul.count, 8
  %tensor.malloc120 = call ptr @malloc(i64 %tensor.data.bytes119)
  %tensor.rank.slot121 = getelementptr inbounds %csec.tensor, ptr %tensor.malloc117, i32 0, i32 0
  store i64 2, ptr %tensor.rank.slot121, align 4
  %tensor.dims.slot122 = getelementptr inbounds %csec.tensor, ptr %tensor.malloc117, i32 0, i32 1
  store ptr %tensor.malloc118, ptr %tensor.dims.slot122, align 8
  %tensor.count.slot123 = getelementptr inbounds %csec.tensor, ptr %tensor.malloc117, i32 0, i32 2
  store i64 %tensor.matmul.count, ptr %tensor.count.slot123, align 4
  %tensor.data.slot124 = getelementptr inbounds %csec.tensor, ptr %tensor.malloc117, i32 0, i32 3
  store ptr %tensor.malloc120, ptr %tensor.data.slot124, align 8
  %tensor.dims.ptr125 = getelementptr inbounds %csec.tensor, ptr %tensor.malloc117, i32 0, i32 1
  %tensor.dims126 = load ptr, ptr %tensor.dims.ptr125, align 8
  %tensor.matmul.dst.rows = getelementptr i64, ptr %tensor.dims126, i64 0
  store i64 %tensor.matmul.rows, ptr %tensor.matmul.dst.rows, align 4
  %tensor.matmul.dst.cols = getelementptr i64, ptr %tensor.dims126, i64 1
  store i64 %tensor.matmul.cols, ptr %tensor.matmul.dst.cols, align 4
  %tensor.data.ptr127 = getelementptr inbounds %csec.tensor, ptr %tensor.malloc, i32 0, i32 3
  %tensor.data128 = load ptr, ptr %tensor.data.ptr127, align 8
  %tensor.data.ptr129 = getelementptr inbounds %csec.tensor, ptr %tensor.malloc5, i32 0, i32 3
  %tensor.data130 = load ptr, ptr %tensor.data.ptr129, align 8
  %tensor.data.ptr131 = getelementptr inbounds %csec.tensor, ptr %tensor.malloc117, i32 0, i32 3
  %tensor.data132 = load ptr, ptr %tensor.data.ptr131, align 8
  %tensor.matmul.i.i = alloca i64, align 8
  store i64 0, ptr %tensor.matmul.i.i, align 4
  br label %tensor.matmul.i.cond

tensor.matmul.i.cond:                             ; preds = %tensor.matmul.j.end, %tensor.scalar.data.end
  %tensor.matmul.i.idx = load i64, ptr %tensor.matmul.i.i, align 4
  %tensor.matmul.i.keep = icmp ult i64 %tensor.matmul.i.idx, %tensor.matmul.rows
  br i1 %tensor.matmul.i.keep, label %tensor.matmul.i.body, label %tensor.matmul.i.end

tensor.matmul.i.body:                             ; preds = %tensor.matmul.i.cond
  %tensor.matmul.j.i = alloca i64, align 8
  store i64 0, ptr %tensor.matmul.j.i, align 4
  br label %tensor.matmul.j.cond

tensor.matmul.i.end:                              ; preds = %tensor.matmul.i.cond
  %matmul = alloca ptr, align 8
  store ptr %tensor.malloc117, ptr %matmul, align 8
  ret i32 0

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
  %0 = mul i64 %tensor.matmul.i.idx, %tensor.matmul.shared
  %tensor.matmul.left.index = add i64 %0, %tensor.matmul.k.idx
  %1 = mul i64 %tensor.matmul.k.idx, %tensor.matmul.cols
  %tensor.matmul.right.index = add i64 %1, %tensor.matmul.j.idx
  %2 = getelementptr double, ptr %tensor.data130, i64 %tensor.matmul.right.index
  %tensor.matmul.right = load double, ptr %2, align 8
  %3 = getelementptr double, ptr %tensor.data128, i64 %tensor.matmul.left.index
  %tensor.matmul.left = load double, ptr %3, align 8
  %tensor.matmul.product = fmul double %tensor.matmul.left, %tensor.matmul.right
  %tensor.matmul.current = load double, ptr %tensor.matmul.sum.ptr, align 8
  %tensor.matmul.next = fadd double %tensor.matmul.current, %tensor.matmul.product
  store double %tensor.matmul.next, ptr %tensor.matmul.sum.ptr, align 8
  %tensor.matmul.k.current = load i64, ptr %tensor.matmul.k.i, align 4
  %tensor.matmul.k.next = add i64 %tensor.matmul.k.current, 1
  store i64 %tensor.matmul.k.next, ptr %tensor.matmul.k.i, align 4
  br label %tensor.matmul.k.cond

tensor.matmul.k.end:                              ; preds = %tensor.matmul.k.cond
  %4 = mul i64 %tensor.matmul.i.idx, %tensor.matmul.cols
  %tensor.matmul.dst.index = add i64 %4, %tensor.matmul.j.idx
  %tensor.matmul.dst = getelementptr double, ptr %tensor.data132, i64 %tensor.matmul.dst.index
  %tensor.matmul.sum = load double, ptr %tensor.matmul.sum.ptr, align 8
  store double %tensor.matmul.sum, ptr %tensor.matmul.dst, align 8
  %tensor.matmul.j.current = load i64, ptr %tensor.matmul.j.i, align 4
  %tensor.matmul.j.next = add i64 %tensor.matmul.j.current, 1
  store i64 %tensor.matmul.j.next, ptr %tensor.matmul.j.i, align 4
  br label %tensor.matmul.j.cond
}

declare ptr @csec_string_concat(ptr, ptr)

declare void @csec_set_command_line_args(i32, ptr)

define internal i32 @__csec_jit_entry() {
entry:
  %user.main = call i32 @_main()
  ret i32 %user.main
}
