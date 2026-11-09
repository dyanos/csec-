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
  %tensor.malloc5 = call ptr @malloc(i64 8)
  %tensor.malloc6 = call ptr @malloc(i64 24)
  %tensor.rank.slot7 = getelementptr inbounds %csec.tensor, ptr %tensor.malloc4, i32 0, i32 0
  store i64 1, ptr %tensor.rank.slot7, align 4
  %tensor.dims.slot8 = getelementptr inbounds %csec.tensor, ptr %tensor.malloc4, i32 0, i32 1
  store ptr %tensor.malloc5, ptr %tensor.dims.slot8, align 8
  %tensor.count.slot9 = getelementptr inbounds %csec.tensor, ptr %tensor.malloc4, i32 0, i32 2
  store i64 3, ptr %tensor.count.slot9, align 4
  %tensor.data.slot10 = getelementptr inbounds %csec.tensor, ptr %tensor.malloc4, i32 0, i32 3
  store ptr %tensor.malloc6, ptr %tensor.data.slot10, align 8
  %tensor.dims.ptr11 = getelementptr inbounds %csec.tensor, ptr %tensor.malloc4, i32 0, i32 1
  %tensor.dims12 = load ptr, ptr %tensor.dims.ptr11, align 8
  %tensor.data.ptr13 = getelementptr inbounds %csec.tensor, ptr %tensor.malloc4, i32 0, i32 3
  %tensor.data14 = load ptr, ptr %tensor.data.ptr13, align 8
  %tensor.dim.slot15 = getelementptr i64, ptr %tensor.dims12, i64 0
  store i64 3, ptr %tensor.dim.slot15, align 4
  %tensor.fill.i16 = alloca i64, align 8
  store i64 0, ptr %tensor.fill.i16, align 4
  br label %tensor.fill.cond17

tensor.fill.cond17:                               ; preds = %tensor.fill.body18, %tensor.fill.end
  %tensor.fill.idx20 = load i64, ptr %tensor.fill.i16, align 4
  %tensor.fill.keep21 = icmp ult i64 %tensor.fill.idx20, 3
  br i1 %tensor.fill.keep21, label %tensor.fill.body18, label %tensor.fill.end19

tensor.fill.body18:                               ; preds = %tensor.fill.cond17
  %tensor.data.slot22 = getelementptr double, ptr %tensor.data14, i64 %tensor.fill.idx20
  store double 1.000000e+00, ptr %tensor.data.slot22, align 8
  %tensor.fill.current23 = load i64, ptr %tensor.fill.i16, align 4
  %tensor.fill.next24 = add i64 %tensor.fill.current23, 1
  store i64 %tensor.fill.next24, ptr %tensor.fill.i16, align 4
  br label %tensor.fill.cond17

tensor.fill.end19:                                ; preds = %tensor.fill.cond17
  %tensor.malloc25 = call ptr @malloc(i64 32)
  %tensor.malloc26 = call ptr @malloc(i64 16)
  %tensor.malloc27 = call ptr @malloc(i64 48)
  %tensor.rank.slot28 = getelementptr inbounds %csec.tensor, ptr %tensor.malloc25, i32 0, i32 0
  store i64 2, ptr %tensor.rank.slot28, align 4
  %tensor.dims.slot29 = getelementptr inbounds %csec.tensor, ptr %tensor.malloc25, i32 0, i32 1
  store ptr %tensor.malloc26, ptr %tensor.dims.slot29, align 8
  %tensor.count.slot30 = getelementptr inbounds %csec.tensor, ptr %tensor.malloc25, i32 0, i32 2
  store i64 6, ptr %tensor.count.slot30, align 4
  %tensor.data.slot31 = getelementptr inbounds %csec.tensor, ptr %tensor.malloc25, i32 0, i32 3
  store ptr %tensor.malloc27, ptr %tensor.data.slot31, align 8
  %tensor.dims.ptr32 = getelementptr inbounds %csec.tensor, ptr %tensor.malloc25, i32 0, i32 1
  %tensor.dims33 = load ptr, ptr %tensor.dims.ptr32, align 8
  %tensor.data.ptr34 = getelementptr inbounds %csec.tensor, ptr %tensor.malloc25, i32 0, i32 3
  %tensor.data35 = load ptr, ptr %tensor.data.ptr34, align 8
  %tensor.dim.slot36 = getelementptr i64, ptr %tensor.dims33, i64 0
  store i64 2, ptr %tensor.dim.slot36, align 4
  %tensor.dim.slot37 = getelementptr i64, ptr %tensor.dims33, i64 1
  store i64 3, ptr %tensor.dim.slot37, align 4
  %tensor.fill.i38 = alloca i64, align 8
  store i64 0, ptr %tensor.fill.i38, align 4
  br label %tensor.fill.cond39

tensor.fill.cond39:                               ; preds = %tensor.fill.body40, %tensor.fill.end19
  %tensor.fill.idx42 = load i64, ptr %tensor.fill.i38, align 4
  %tensor.fill.keep43 = icmp ult i64 %tensor.fill.idx42, 6
  br i1 %tensor.fill.keep43, label %tensor.fill.body40, label %tensor.fill.end41

tensor.fill.body40:                               ; preds = %tensor.fill.cond39
  %tensor.data.slot44 = getelementptr double, ptr %tensor.data35, i64 %tensor.fill.idx42
  store double 0.000000e+00, ptr %tensor.data.slot44, align 8
  %tensor.fill.current45 = load i64, ptr %tensor.fill.i38, align 4
  %tensor.fill.next46 = add i64 %tensor.fill.current45, 1
  store i64 %tensor.fill.next46, ptr %tensor.fill.i38, align 4
  br label %tensor.fill.cond39

tensor.fill.end41:                                ; preds = %tensor.fill.cond39
  %tensor.malloc47 = call ptr @malloc(i64 32)
  %tensor.malloc48 = call ptr @malloc(i64 16)
  %tensor.malloc49 = call ptr @malloc(i64 48)
  %tensor.rank.slot50 = getelementptr inbounds %csec.tensor, ptr %tensor.malloc47, i32 0, i32 0
  store i64 2, ptr %tensor.rank.slot50, align 4
  %tensor.dims.slot51 = getelementptr inbounds %csec.tensor, ptr %tensor.malloc47, i32 0, i32 1
  store ptr %tensor.malloc48, ptr %tensor.dims.slot51, align 8
  %tensor.count.slot52 = getelementptr inbounds %csec.tensor, ptr %tensor.malloc47, i32 0, i32 2
  store i64 6, ptr %tensor.count.slot52, align 4
  %tensor.data.slot53 = getelementptr inbounds %csec.tensor, ptr %tensor.malloc47, i32 0, i32 3
  store ptr %tensor.malloc49, ptr %tensor.data.slot53, align 8
  %tensor.dims.ptr54 = getelementptr inbounds %csec.tensor, ptr %tensor.malloc47, i32 0, i32 1
  %tensor.dims55 = load ptr, ptr %tensor.dims.ptr54, align 8
  %tensor.data.ptr56 = getelementptr inbounds %csec.tensor, ptr %tensor.malloc47, i32 0, i32 3
  %tensor.data57 = load ptr, ptr %tensor.data.ptr56, align 8
  %tensor.dim.slot58 = getelementptr i64, ptr %tensor.dims55, i64 0
  store i64 3, ptr %tensor.dim.slot58, align 4
  %tensor.dim.slot59 = getelementptr i64, ptr %tensor.dims55, i64 1
  store i64 2, ptr %tensor.dim.slot59, align 4
  %tensor.fill.i60 = alloca i64, align 8
  store i64 0, ptr %tensor.fill.i60, align 4
  br label %tensor.fill.cond61

tensor.fill.cond61:                               ; preds = %tensor.fill.body62, %tensor.fill.end41
  %tensor.fill.idx64 = load i64, ptr %tensor.fill.i60, align 4
  %tensor.fill.keep65 = icmp ult i64 %tensor.fill.idx64, 6
  br i1 %tensor.fill.keep65, label %tensor.fill.body62, label %tensor.fill.end63

tensor.fill.body62:                               ; preds = %tensor.fill.cond61
  %tensor.data.slot66 = getelementptr double, ptr %tensor.data57, i64 %tensor.fill.idx64
  store double 0.000000e+00, ptr %tensor.data.slot66, align 8
  %tensor.fill.current67 = load i64, ptr %tensor.fill.i60, align 4
  %tensor.fill.next68 = add i64 %tensor.fill.current67, 1
  store i64 %tensor.fill.next68, ptr %tensor.fill.i60, align 4
  br label %tensor.fill.cond61

tensor.fill.end63:                                ; preds = %tensor.fill.cond61
  %tensor.count.ptr = getelementptr inbounds %csec.tensor, ptr %tensor.malloc, i32 0, i32 2
  %tensor.count = load i64, ptr %tensor.count.ptr, align 4
  %tensor.count.ptr69 = getelementptr inbounds %csec.tensor, ptr %tensor.malloc4, i32 0, i32 2
  %tensor.count70 = load i64, ptr %tensor.count.ptr69, align 4
  %0 = icmp ult i64 %tensor.count, %tensor.count70
  %tensor.inner.count = select i1 %0, i64 %tensor.count, i64 %tensor.count70
  %tensor.data.ptr71 = getelementptr inbounds %csec.tensor, ptr %tensor.malloc, i32 0, i32 3
  %tensor.data72 = load ptr, ptr %tensor.data.ptr71, align 8
  %tensor.data.ptr73 = getelementptr inbounds %csec.tensor, ptr %tensor.malloc4, i32 0, i32 3
  %tensor.data74 = load ptr, ptr %tensor.data.ptr73, align 8
  %tensor.inner.sum.ptr = alloca double, align 8
  store double 0.000000e+00, ptr %tensor.inner.sum.ptr, align 8
  %tensor.inner.i = alloca i64, align 8
  store i64 0, ptr %tensor.inner.i, align 4
  br label %tensor.inner.cond

tensor.inner.cond:                                ; preds = %tensor.inner.body, %tensor.fill.end63
  %tensor.inner.idx = load i64, ptr %tensor.inner.i, align 4
  %tensor.inner.keep = icmp ult i64 %tensor.inner.idx, %tensor.inner.count
  br i1 %tensor.inner.keep, label %tensor.inner.body, label %tensor.inner.end

tensor.inner.body:                                ; preds = %tensor.inner.cond
  %tensor.inner.left = getelementptr double, ptr %tensor.data72, i64 %tensor.inner.idx
  %tensor.inner.right = getelementptr double, ptr %tensor.data74, i64 %tensor.inner.idx
  %tensor.inner.r = load double, ptr %tensor.inner.right, align 8
  %tensor.inner.l = load double, ptr %tensor.inner.left, align 8
  %tensor.inner.product = fmul double %tensor.inner.l, %tensor.inner.r
  %tensor.inner.current = load double, ptr %tensor.inner.sum.ptr, align 8
  %tensor.inner.next = fadd double %tensor.inner.current, %tensor.inner.product
  store double %tensor.inner.next, ptr %tensor.inner.sum.ptr, align 8
  %tensor.inner.current75 = load i64, ptr %tensor.inner.i, align 4
  %tensor.inner.next76 = add i64 %tensor.inner.current75, 1
  store i64 %tensor.inner.next76, ptr %tensor.inner.i, align 4
  br label %tensor.inner.cond

tensor.inner.end:                                 ; preds = %tensor.inner.cond
  %tensor.inner.result = load double, ptr %tensor.inner.sum.ptr, align 8
  %dot1 = alloca double, align 8
  store double %tensor.inner.result, ptr %dot1, align 8
  %tensor.count.ptr77 = getelementptr inbounds %csec.tensor, ptr %tensor.malloc, i32 0, i32 2
  %tensor.count78 = load i64, ptr %tensor.count.ptr77, align 4
  %tensor.count.ptr79 = getelementptr inbounds %csec.tensor, ptr %tensor.malloc4, i32 0, i32 2
  %tensor.count80 = load i64, ptr %tensor.count.ptr79, align 4
  %1 = icmp ult i64 %tensor.count78, %tensor.count80
  %tensor.inner.count81 = select i1 %1, i64 %tensor.count78, i64 %tensor.count80
  %tensor.data.ptr82 = getelementptr inbounds %csec.tensor, ptr %tensor.malloc, i32 0, i32 3
  %tensor.data83 = load ptr, ptr %tensor.data.ptr82, align 8
  %tensor.data.ptr84 = getelementptr inbounds %csec.tensor, ptr %tensor.malloc4, i32 0, i32 3
  %tensor.data85 = load ptr, ptr %tensor.data.ptr84, align 8
  %tensor.inner.sum.ptr86 = alloca double, align 8
  store double 0.000000e+00, ptr %tensor.inner.sum.ptr86, align 8
  %tensor.inner.i87 = alloca i64, align 8
  store i64 0, ptr %tensor.inner.i87, align 4
  br label %tensor.inner.cond88

tensor.inner.cond88:                              ; preds = %tensor.inner.body89, %tensor.inner.end
  %tensor.inner.idx91 = load i64, ptr %tensor.inner.i87, align 4
  %tensor.inner.keep92 = icmp ult i64 %tensor.inner.idx91, %tensor.inner.count81
  br i1 %tensor.inner.keep92, label %tensor.inner.body89, label %tensor.inner.end90

tensor.inner.body89:                              ; preds = %tensor.inner.cond88
  %tensor.inner.left93 = getelementptr double, ptr %tensor.data83, i64 %tensor.inner.idx91
  %tensor.inner.right94 = getelementptr double, ptr %tensor.data85, i64 %tensor.inner.idx91
  %tensor.inner.r95 = load double, ptr %tensor.inner.right94, align 8
  %tensor.inner.l96 = load double, ptr %tensor.inner.left93, align 8
  %tensor.inner.product97 = fmul double %tensor.inner.l96, %tensor.inner.r95
  %tensor.inner.current98 = load double, ptr %tensor.inner.sum.ptr86, align 8
  %tensor.inner.next99 = fadd double %tensor.inner.current98, %tensor.inner.product97
  store double %tensor.inner.next99, ptr %tensor.inner.sum.ptr86, align 8
  %tensor.inner.current100 = load i64, ptr %tensor.inner.i87, align 4
  %tensor.inner.next101 = add i64 %tensor.inner.current100, 1
  store i64 %tensor.inner.next101, ptr %tensor.inner.i87, align 4
  br label %tensor.inner.cond88

tensor.inner.end90:                               ; preds = %tensor.inner.cond88
  %tensor.inner.result102 = load double, ptr %tensor.inner.sum.ptr86, align 8
  %dot2 = alloca double, align 8
  store double %tensor.inner.result102, ptr %dot2, align 8
  %tensor.rank.ptr = getelementptr inbounds %csec.tensor, ptr %tensor.malloc, i32 0, i32 0
  %tensor.rank = load i64, ptr %tensor.rank.ptr, align 4
  %tensor.rank.ptr103 = getelementptr inbounds %csec.tensor, ptr %tensor.malloc4, i32 0, i32 0
  %tensor.rank104 = load i64, ptr %tensor.rank.ptr103, align 4
  %tensor.count.ptr105 = getelementptr inbounds %csec.tensor, ptr %tensor.malloc, i32 0, i32 2
  %tensor.count106 = load i64, ptr %tensor.count.ptr105, align 4
  %tensor.count.ptr107 = getelementptr inbounds %csec.tensor, ptr %tensor.malloc4, i32 0, i32 2
  %tensor.count108 = load i64, ptr %tensor.count.ptr107, align 4
  %tensor.outer.rank = add i64 %tensor.rank, %tensor.rank104
  %tensor.outer.count = mul i64 %tensor.count106, %tensor.count108
  %tensor.malloc109 = call ptr @malloc(i64 32)
  %tensor.dims.bytes = mul i64 %tensor.outer.rank, 8
  %tensor.malloc110 = call ptr @malloc(i64 %tensor.dims.bytes)
  %tensor.data.bytes = mul i64 %tensor.outer.count, 8
  %tensor.malloc111 = call ptr @malloc(i64 %tensor.data.bytes)
  %tensor.rank.slot112 = getelementptr inbounds %csec.tensor, ptr %tensor.malloc109, i32 0, i32 0
  store i64 %tensor.outer.rank, ptr %tensor.rank.slot112, align 4
  %tensor.dims.slot113 = getelementptr inbounds %csec.tensor, ptr %tensor.malloc109, i32 0, i32 1
  store ptr %tensor.malloc110, ptr %tensor.dims.slot113, align 8
  %tensor.count.slot114 = getelementptr inbounds %csec.tensor, ptr %tensor.malloc109, i32 0, i32 2
  store i64 %tensor.outer.count, ptr %tensor.count.slot114, align 4
  %tensor.data.slot115 = getelementptr inbounds %csec.tensor, ptr %tensor.malloc109, i32 0, i32 3
  store ptr %tensor.malloc111, ptr %tensor.data.slot115, align 8
  %tensor.dims.ptr116 = getelementptr inbounds %csec.tensor, ptr %tensor.malloc, i32 0, i32 1
  %tensor.dims117 = load ptr, ptr %tensor.dims.ptr116, align 8
  %tensor.dims.ptr118 = getelementptr inbounds %csec.tensor, ptr %tensor.malloc4, i32 0, i32 1
  %tensor.dims119 = load ptr, ptr %tensor.dims.ptr118, align 8
  %tensor.dims.ptr120 = getelementptr inbounds %csec.tensor, ptr %tensor.malloc109, i32 0, i32 1
  %tensor.dims121 = load ptr, ptr %tensor.dims.ptr120, align 8
  %tensor.data.ptr122 = getelementptr inbounds %csec.tensor, ptr %tensor.malloc, i32 0, i32 3
  %tensor.data123 = load ptr, ptr %tensor.data.ptr122, align 8
  %tensor.data.ptr124 = getelementptr inbounds %csec.tensor, ptr %tensor.malloc4, i32 0, i32 3
  %tensor.data125 = load ptr, ptr %tensor.data.ptr124, align 8
  %tensor.data.ptr126 = getelementptr inbounds %csec.tensor, ptr %tensor.malloc109, i32 0, i32 3
  %tensor.data127 = load ptr, ptr %tensor.data.ptr126, align 8
  %tensor.outer.left.dims.i = alloca i64, align 8
  store i64 0, ptr %tensor.outer.left.dims.i, align 4
  br label %tensor.outer.left.dims.cond

tensor.outer.left.dims.cond:                      ; preds = %tensor.outer.left.dims.body, %tensor.inner.end90
  %tensor.outer.left.dims.idx = load i64, ptr %tensor.outer.left.dims.i, align 4
  %tensor.outer.left.dims.keep = icmp ult i64 %tensor.outer.left.dims.idx, %tensor.rank
  br i1 %tensor.outer.left.dims.keep, label %tensor.outer.left.dims.body, label %tensor.outer.left.dims.end

tensor.outer.left.dims.body:                      ; preds = %tensor.outer.left.dims.cond
  %tensor.outer.left.dim = getelementptr i64, ptr %tensor.dims117, i64 %tensor.outer.left.dims.idx
  %tensor.outer.dst.dim = getelementptr i64, ptr %tensor.dims121, i64 %tensor.outer.left.dims.idx
  %tensor.outer.dim = load i64, ptr %tensor.outer.left.dim, align 4
  store i64 %tensor.outer.dim, ptr %tensor.outer.dst.dim, align 4
  %tensor.outer.left.dims.current = load i64, ptr %tensor.outer.left.dims.i, align 4
  %tensor.outer.left.dims.next = add i64 %tensor.outer.left.dims.current, 1
  store i64 %tensor.outer.left.dims.next, ptr %tensor.outer.left.dims.i, align 4
  br label %tensor.outer.left.dims.cond

tensor.outer.left.dims.end:                       ; preds = %tensor.outer.left.dims.cond
  %tensor.outer.right.dims.i = alloca i64, align 8
  store i64 0, ptr %tensor.outer.right.dims.i, align 4
  br label %tensor.outer.right.dims.cond

tensor.outer.right.dims.cond:                     ; preds = %tensor.outer.right.dims.body, %tensor.outer.left.dims.end
  %tensor.outer.right.dims.idx = load i64, ptr %tensor.outer.right.dims.i, align 4
  %tensor.outer.right.dims.keep = icmp ult i64 %tensor.outer.right.dims.idx, %tensor.rank104
  br i1 %tensor.outer.right.dims.keep, label %tensor.outer.right.dims.body, label %tensor.outer.right.dims.end

tensor.outer.right.dims.body:                     ; preds = %tensor.outer.right.dims.cond
  %tensor.outer.right.dim = getelementptr i64, ptr %tensor.dims119, i64 %tensor.outer.right.dims.idx
  %2 = add i64 %tensor.rank, %tensor.outer.right.dims.idx
  %tensor.outer.dst.dim128 = getelementptr i64, ptr %tensor.dims121, i64 %2
  %tensor.outer.dim129 = load i64, ptr %tensor.outer.right.dim, align 4
  store i64 %tensor.outer.dim129, ptr %tensor.outer.dst.dim128, align 4
  %tensor.outer.right.dims.current = load i64, ptr %tensor.outer.right.dims.i, align 4
  %tensor.outer.right.dims.next = add i64 %tensor.outer.right.dims.current, 1
  store i64 %tensor.outer.right.dims.next, ptr %tensor.outer.right.dims.i, align 4
  br label %tensor.outer.right.dims.cond

tensor.outer.right.dims.end:                      ; preds = %tensor.outer.right.dims.cond
  %tensor.outer.left.i = alloca i64, align 8
  store i64 0, ptr %tensor.outer.left.i, align 4
  br label %tensor.outer.left.cond

tensor.outer.left.cond:                           ; preds = %tensor.outer.right.end, %tensor.outer.right.dims.end
  %tensor.outer.left.idx = load i64, ptr %tensor.outer.left.i, align 4
  %tensor.outer.left.keep = icmp ult i64 %tensor.outer.left.idx, %tensor.count106
  br i1 %tensor.outer.left.keep, label %tensor.outer.left.body, label %tensor.outer.left.end

tensor.outer.left.body:                           ; preds = %tensor.outer.left.cond
  %tensor.outer.left.val = getelementptr double, ptr %tensor.data123, i64 %tensor.outer.left.idx
  %tensor.outer.l = load double, ptr %tensor.outer.left.val, align 8
  %tensor.outer.right.i = alloca i64, align 8
  store i64 0, ptr %tensor.outer.right.i, align 4
  br label %tensor.outer.right.cond

tensor.outer.left.end:                            ; preds = %tensor.outer.left.cond
  %outer1 = alloca ptr, align 8
  store ptr %tensor.malloc109, ptr %outer1, align 8
  %tensor.rank.ptr130 = getelementptr inbounds %csec.tensor, ptr %tensor.malloc, i32 0, i32 0
  %tensor.rank131 = load i64, ptr %tensor.rank.ptr130, align 4
  %tensor.rank.ptr132 = getelementptr inbounds %csec.tensor, ptr %tensor.malloc4, i32 0, i32 0
  %tensor.rank133 = load i64, ptr %tensor.rank.ptr132, align 4
  %tensor.count.ptr134 = getelementptr inbounds %csec.tensor, ptr %tensor.malloc, i32 0, i32 2
  %tensor.count135 = load i64, ptr %tensor.count.ptr134, align 4
  %tensor.count.ptr136 = getelementptr inbounds %csec.tensor, ptr %tensor.malloc4, i32 0, i32 2
  %tensor.count137 = load i64, ptr %tensor.count.ptr136, align 4
  %tensor.outer.rank138 = add i64 %tensor.rank131, %tensor.rank133
  %tensor.outer.count139 = mul i64 %tensor.count135, %tensor.count137
  %tensor.malloc140 = call ptr @malloc(i64 32)
  %tensor.dims.bytes141 = mul i64 %tensor.outer.rank138, 8
  %tensor.malloc142 = call ptr @malloc(i64 %tensor.dims.bytes141)
  %tensor.data.bytes143 = mul i64 %tensor.outer.count139, 8
  %tensor.malloc144 = call ptr @malloc(i64 %tensor.data.bytes143)
  %tensor.rank.slot145 = getelementptr inbounds %csec.tensor, ptr %tensor.malloc140, i32 0, i32 0
  store i64 %tensor.outer.rank138, ptr %tensor.rank.slot145, align 4
  %tensor.dims.slot146 = getelementptr inbounds %csec.tensor, ptr %tensor.malloc140, i32 0, i32 1
  store ptr %tensor.malloc142, ptr %tensor.dims.slot146, align 8
  %tensor.count.slot147 = getelementptr inbounds %csec.tensor, ptr %tensor.malloc140, i32 0, i32 2
  store i64 %tensor.outer.count139, ptr %tensor.count.slot147, align 4
  %tensor.data.slot148 = getelementptr inbounds %csec.tensor, ptr %tensor.malloc140, i32 0, i32 3
  store ptr %tensor.malloc144, ptr %tensor.data.slot148, align 8
  %tensor.dims.ptr149 = getelementptr inbounds %csec.tensor, ptr %tensor.malloc, i32 0, i32 1
  %tensor.dims150 = load ptr, ptr %tensor.dims.ptr149, align 8
  %tensor.dims.ptr151 = getelementptr inbounds %csec.tensor, ptr %tensor.malloc4, i32 0, i32 1
  %tensor.dims152 = load ptr, ptr %tensor.dims.ptr151, align 8
  %tensor.dims.ptr153 = getelementptr inbounds %csec.tensor, ptr %tensor.malloc140, i32 0, i32 1
  %tensor.dims154 = load ptr, ptr %tensor.dims.ptr153, align 8
  %tensor.data.ptr155 = getelementptr inbounds %csec.tensor, ptr %tensor.malloc, i32 0, i32 3
  %tensor.data156 = load ptr, ptr %tensor.data.ptr155, align 8
  %tensor.data.ptr157 = getelementptr inbounds %csec.tensor, ptr %tensor.malloc4, i32 0, i32 3
  %tensor.data158 = load ptr, ptr %tensor.data.ptr157, align 8
  %tensor.data.ptr159 = getelementptr inbounds %csec.tensor, ptr %tensor.malloc140, i32 0, i32 3
  %tensor.data160 = load ptr, ptr %tensor.data.ptr159, align 8
  %tensor.outer.left.dims.i161 = alloca i64, align 8
  store i64 0, ptr %tensor.outer.left.dims.i161, align 4
  br label %tensor.outer.left.dims.cond162

tensor.outer.right.cond:                          ; preds = %tensor.outer.right.body, %tensor.outer.left.body
  %tensor.outer.right.idx = load i64, ptr %tensor.outer.right.i, align 4
  %tensor.outer.right.keep = icmp ult i64 %tensor.outer.right.idx, %tensor.count108
  br i1 %tensor.outer.right.keep, label %tensor.outer.right.body, label %tensor.outer.right.end

tensor.outer.right.body:                          ; preds = %tensor.outer.right.cond
  %tensor.outer.right.val = getelementptr double, ptr %tensor.data125, i64 %tensor.outer.right.idx
  %3 = mul i64 %tensor.outer.left.idx, %tensor.count108
  %tensor.outer.dst.index = add i64 %3, %tensor.outer.right.idx
  %tensor.outer.dst.val = getelementptr double, ptr %tensor.data127, i64 %tensor.outer.dst.index
  %tensor.outer.r = load double, ptr %tensor.outer.right.val, align 8
  %tensor.outer.product = fmul double %tensor.outer.l, %tensor.outer.r
  store double %tensor.outer.product, ptr %tensor.outer.dst.val, align 8
  %tensor.outer.right.current = load i64, ptr %tensor.outer.right.i, align 4
  %tensor.outer.right.next = add i64 %tensor.outer.right.current, 1
  store i64 %tensor.outer.right.next, ptr %tensor.outer.right.i, align 4
  br label %tensor.outer.right.cond

tensor.outer.right.end:                           ; preds = %tensor.outer.right.cond
  %tensor.outer.left.current = load i64, ptr %tensor.outer.left.i, align 4
  %tensor.outer.left.next = add i64 %tensor.outer.left.current, 1
  store i64 %tensor.outer.left.next, ptr %tensor.outer.left.i, align 4
  br label %tensor.outer.left.cond

tensor.outer.left.dims.cond162:                   ; preds = %tensor.outer.left.dims.body163, %tensor.outer.left.end
  %tensor.outer.left.dims.idx165 = load i64, ptr %tensor.outer.left.dims.i161, align 4
  %tensor.outer.left.dims.keep166 = icmp ult i64 %tensor.outer.left.dims.idx165, %tensor.rank131
  br i1 %tensor.outer.left.dims.keep166, label %tensor.outer.left.dims.body163, label %tensor.outer.left.dims.end164

tensor.outer.left.dims.body163:                   ; preds = %tensor.outer.left.dims.cond162
  %tensor.outer.left.dim167 = getelementptr i64, ptr %tensor.dims150, i64 %tensor.outer.left.dims.idx165
  %tensor.outer.dst.dim168 = getelementptr i64, ptr %tensor.dims154, i64 %tensor.outer.left.dims.idx165
  %tensor.outer.dim169 = load i64, ptr %tensor.outer.left.dim167, align 4
  store i64 %tensor.outer.dim169, ptr %tensor.outer.dst.dim168, align 4
  %tensor.outer.left.dims.current170 = load i64, ptr %tensor.outer.left.dims.i161, align 4
  %tensor.outer.left.dims.next171 = add i64 %tensor.outer.left.dims.current170, 1
  store i64 %tensor.outer.left.dims.next171, ptr %tensor.outer.left.dims.i161, align 4
  br label %tensor.outer.left.dims.cond162

tensor.outer.left.dims.end164:                    ; preds = %tensor.outer.left.dims.cond162
  %tensor.outer.right.dims.i172 = alloca i64, align 8
  store i64 0, ptr %tensor.outer.right.dims.i172, align 4
  br label %tensor.outer.right.dims.cond173

tensor.outer.right.dims.cond173:                  ; preds = %tensor.outer.right.dims.body174, %tensor.outer.left.dims.end164
  %tensor.outer.right.dims.idx176 = load i64, ptr %tensor.outer.right.dims.i172, align 4
  %tensor.outer.right.dims.keep177 = icmp ult i64 %tensor.outer.right.dims.idx176, %tensor.rank133
  br i1 %tensor.outer.right.dims.keep177, label %tensor.outer.right.dims.body174, label %tensor.outer.right.dims.end175

tensor.outer.right.dims.body174:                  ; preds = %tensor.outer.right.dims.cond173
  %tensor.outer.right.dim178 = getelementptr i64, ptr %tensor.dims152, i64 %tensor.outer.right.dims.idx176
  %4 = add i64 %tensor.rank131, %tensor.outer.right.dims.idx176
  %tensor.outer.dst.dim179 = getelementptr i64, ptr %tensor.dims154, i64 %4
  %tensor.outer.dim180 = load i64, ptr %tensor.outer.right.dim178, align 4
  store i64 %tensor.outer.dim180, ptr %tensor.outer.dst.dim179, align 4
  %tensor.outer.right.dims.current181 = load i64, ptr %tensor.outer.right.dims.i172, align 4
  %tensor.outer.right.dims.next182 = add i64 %tensor.outer.right.dims.current181, 1
  store i64 %tensor.outer.right.dims.next182, ptr %tensor.outer.right.dims.i172, align 4
  br label %tensor.outer.right.dims.cond173

tensor.outer.right.dims.end175:                   ; preds = %tensor.outer.right.dims.cond173
  %tensor.outer.left.i183 = alloca i64, align 8
  store i64 0, ptr %tensor.outer.left.i183, align 4
  br label %tensor.outer.left.cond184

tensor.outer.left.cond184:                        ; preds = %tensor.outer.right.end194, %tensor.outer.right.dims.end175
  %tensor.outer.left.idx187 = load i64, ptr %tensor.outer.left.i183, align 4
  %tensor.outer.left.keep188 = icmp ult i64 %tensor.outer.left.idx187, %tensor.count135
  br i1 %tensor.outer.left.keep188, label %tensor.outer.left.body185, label %tensor.outer.left.end186

tensor.outer.left.body185:                        ; preds = %tensor.outer.left.cond184
  %tensor.outer.left.val189 = getelementptr double, ptr %tensor.data156, i64 %tensor.outer.left.idx187
  %tensor.outer.l190 = load double, ptr %tensor.outer.left.val189, align 8
  %tensor.outer.right.i191 = alloca i64, align 8
  store i64 0, ptr %tensor.outer.right.i191, align 4
  br label %tensor.outer.right.cond192

tensor.outer.left.end186:                         ; preds = %tensor.outer.left.cond184
  %outer2 = alloca ptr, align 8
  store ptr %tensor.malloc140, ptr %outer2, align 8
  %tensor.rank.ptr206 = getelementptr inbounds %csec.tensor, ptr %tensor.malloc25, i32 0, i32 0
  %tensor.rank207 = load i64, ptr %tensor.rank.ptr206, align 4
  %tensor.rank.ptr208 = getelementptr inbounds %csec.tensor, ptr %tensor.malloc47, i32 0, i32 0
  %tensor.rank209 = load i64, ptr %tensor.rank.ptr208, align 4
  %tensor.count.ptr210 = getelementptr inbounds %csec.tensor, ptr %tensor.malloc25, i32 0, i32 2
  %tensor.count211 = load i64, ptr %tensor.count.ptr210, align 4
  %tensor.count.ptr212 = getelementptr inbounds %csec.tensor, ptr %tensor.malloc47, i32 0, i32 2
  %tensor.count213 = load i64, ptr %tensor.count.ptr212, align 4
  %tensor.outer.rank214 = add i64 %tensor.rank207, %tensor.rank209
  %tensor.outer.count215 = mul i64 %tensor.count211, %tensor.count213
  %tensor.malloc216 = call ptr @malloc(i64 32)
  %tensor.dims.bytes217 = mul i64 %tensor.outer.rank214, 8
  %tensor.malloc218 = call ptr @malloc(i64 %tensor.dims.bytes217)
  %tensor.data.bytes219 = mul i64 %tensor.outer.count215, 8
  %tensor.malloc220 = call ptr @malloc(i64 %tensor.data.bytes219)
  %tensor.rank.slot221 = getelementptr inbounds %csec.tensor, ptr %tensor.malloc216, i32 0, i32 0
  store i64 %tensor.outer.rank214, ptr %tensor.rank.slot221, align 4
  %tensor.dims.slot222 = getelementptr inbounds %csec.tensor, ptr %tensor.malloc216, i32 0, i32 1
  store ptr %tensor.malloc218, ptr %tensor.dims.slot222, align 8
  %tensor.count.slot223 = getelementptr inbounds %csec.tensor, ptr %tensor.malloc216, i32 0, i32 2
  store i64 %tensor.outer.count215, ptr %tensor.count.slot223, align 4
  %tensor.data.slot224 = getelementptr inbounds %csec.tensor, ptr %tensor.malloc216, i32 0, i32 3
  store ptr %tensor.malloc220, ptr %tensor.data.slot224, align 8
  %tensor.dims.ptr225 = getelementptr inbounds %csec.tensor, ptr %tensor.malloc25, i32 0, i32 1
  %tensor.dims226 = load ptr, ptr %tensor.dims.ptr225, align 8
  %tensor.dims.ptr227 = getelementptr inbounds %csec.tensor, ptr %tensor.malloc47, i32 0, i32 1
  %tensor.dims228 = load ptr, ptr %tensor.dims.ptr227, align 8
  %tensor.dims.ptr229 = getelementptr inbounds %csec.tensor, ptr %tensor.malloc216, i32 0, i32 1
  %tensor.dims230 = load ptr, ptr %tensor.dims.ptr229, align 8
  %tensor.data.ptr231 = getelementptr inbounds %csec.tensor, ptr %tensor.malloc25, i32 0, i32 3
  %tensor.data232 = load ptr, ptr %tensor.data.ptr231, align 8
  %tensor.data.ptr233 = getelementptr inbounds %csec.tensor, ptr %tensor.malloc47, i32 0, i32 3
  %tensor.data234 = load ptr, ptr %tensor.data.ptr233, align 8
  %tensor.data.ptr235 = getelementptr inbounds %csec.tensor, ptr %tensor.malloc216, i32 0, i32 3
  %tensor.data236 = load ptr, ptr %tensor.data.ptr235, align 8
  %tensor.outer.left.dims.i237 = alloca i64, align 8
  store i64 0, ptr %tensor.outer.left.dims.i237, align 4
  br label %tensor.outer.left.dims.cond238

tensor.outer.right.cond192:                       ; preds = %tensor.outer.right.body193, %tensor.outer.left.body185
  %tensor.outer.right.idx195 = load i64, ptr %tensor.outer.right.i191, align 4
  %tensor.outer.right.keep196 = icmp ult i64 %tensor.outer.right.idx195, %tensor.count137
  br i1 %tensor.outer.right.keep196, label %tensor.outer.right.body193, label %tensor.outer.right.end194

tensor.outer.right.body193:                       ; preds = %tensor.outer.right.cond192
  %tensor.outer.right.val197 = getelementptr double, ptr %tensor.data158, i64 %tensor.outer.right.idx195
  %5 = mul i64 %tensor.outer.left.idx187, %tensor.count137
  %tensor.outer.dst.index198 = add i64 %5, %tensor.outer.right.idx195
  %tensor.outer.dst.val199 = getelementptr double, ptr %tensor.data160, i64 %tensor.outer.dst.index198
  %tensor.outer.r200 = load double, ptr %tensor.outer.right.val197, align 8
  %tensor.outer.product201 = fmul double %tensor.outer.l190, %tensor.outer.r200
  store double %tensor.outer.product201, ptr %tensor.outer.dst.val199, align 8
  %tensor.outer.right.current202 = load i64, ptr %tensor.outer.right.i191, align 4
  %tensor.outer.right.next203 = add i64 %tensor.outer.right.current202, 1
  store i64 %tensor.outer.right.next203, ptr %tensor.outer.right.i191, align 4
  br label %tensor.outer.right.cond192

tensor.outer.right.end194:                        ; preds = %tensor.outer.right.cond192
  %tensor.outer.left.current204 = load i64, ptr %tensor.outer.left.i183, align 4
  %tensor.outer.left.next205 = add i64 %tensor.outer.left.current204, 1
  store i64 %tensor.outer.left.next205, ptr %tensor.outer.left.i183, align 4
  br label %tensor.outer.left.cond184

tensor.outer.left.dims.cond238:                   ; preds = %tensor.outer.left.dims.body239, %tensor.outer.left.end186
  %tensor.outer.left.dims.idx241 = load i64, ptr %tensor.outer.left.dims.i237, align 4
  %tensor.outer.left.dims.keep242 = icmp ult i64 %tensor.outer.left.dims.idx241, %tensor.rank207
  br i1 %tensor.outer.left.dims.keep242, label %tensor.outer.left.dims.body239, label %tensor.outer.left.dims.end240

tensor.outer.left.dims.body239:                   ; preds = %tensor.outer.left.dims.cond238
  %tensor.outer.left.dim243 = getelementptr i64, ptr %tensor.dims226, i64 %tensor.outer.left.dims.idx241
  %tensor.outer.dst.dim244 = getelementptr i64, ptr %tensor.dims230, i64 %tensor.outer.left.dims.idx241
  %tensor.outer.dim245 = load i64, ptr %tensor.outer.left.dim243, align 4
  store i64 %tensor.outer.dim245, ptr %tensor.outer.dst.dim244, align 4
  %tensor.outer.left.dims.current246 = load i64, ptr %tensor.outer.left.dims.i237, align 4
  %tensor.outer.left.dims.next247 = add i64 %tensor.outer.left.dims.current246, 1
  store i64 %tensor.outer.left.dims.next247, ptr %tensor.outer.left.dims.i237, align 4
  br label %tensor.outer.left.dims.cond238

tensor.outer.left.dims.end240:                    ; preds = %tensor.outer.left.dims.cond238
  %tensor.outer.right.dims.i248 = alloca i64, align 8
  store i64 0, ptr %tensor.outer.right.dims.i248, align 4
  br label %tensor.outer.right.dims.cond249

tensor.outer.right.dims.cond249:                  ; preds = %tensor.outer.right.dims.body250, %tensor.outer.left.dims.end240
  %tensor.outer.right.dims.idx252 = load i64, ptr %tensor.outer.right.dims.i248, align 4
  %tensor.outer.right.dims.keep253 = icmp ult i64 %tensor.outer.right.dims.idx252, %tensor.rank209
  br i1 %tensor.outer.right.dims.keep253, label %tensor.outer.right.dims.body250, label %tensor.outer.right.dims.end251

tensor.outer.right.dims.body250:                  ; preds = %tensor.outer.right.dims.cond249
  %tensor.outer.right.dim254 = getelementptr i64, ptr %tensor.dims228, i64 %tensor.outer.right.dims.idx252
  %6 = add i64 %tensor.rank207, %tensor.outer.right.dims.idx252
  %tensor.outer.dst.dim255 = getelementptr i64, ptr %tensor.dims230, i64 %6
  %tensor.outer.dim256 = load i64, ptr %tensor.outer.right.dim254, align 4
  store i64 %tensor.outer.dim256, ptr %tensor.outer.dst.dim255, align 4
  %tensor.outer.right.dims.current257 = load i64, ptr %tensor.outer.right.dims.i248, align 4
  %tensor.outer.right.dims.next258 = add i64 %tensor.outer.right.dims.current257, 1
  store i64 %tensor.outer.right.dims.next258, ptr %tensor.outer.right.dims.i248, align 4
  br label %tensor.outer.right.dims.cond249

tensor.outer.right.dims.end251:                   ; preds = %tensor.outer.right.dims.cond249
  %tensor.outer.left.i259 = alloca i64, align 8
  store i64 0, ptr %tensor.outer.left.i259, align 4
  br label %tensor.outer.left.cond260

tensor.outer.left.cond260:                        ; preds = %tensor.outer.right.end270, %tensor.outer.right.dims.end251
  %tensor.outer.left.idx263 = load i64, ptr %tensor.outer.left.i259, align 4
  %tensor.outer.left.keep264 = icmp ult i64 %tensor.outer.left.idx263, %tensor.count211
  br i1 %tensor.outer.left.keep264, label %tensor.outer.left.body261, label %tensor.outer.left.end262

tensor.outer.left.body261:                        ; preds = %tensor.outer.left.cond260
  %tensor.outer.left.val265 = getelementptr double, ptr %tensor.data232, i64 %tensor.outer.left.idx263
  %tensor.outer.l266 = load double, ptr %tensor.outer.left.val265, align 8
  %tensor.outer.right.i267 = alloca i64, align 8
  store i64 0, ptr %tensor.outer.right.i267, align 4
  br label %tensor.outer.right.cond268

tensor.outer.left.end262:                         ; preds = %tensor.outer.left.cond260
  %kron1 = alloca ptr, align 8
  store ptr %tensor.malloc216, ptr %kron1, align 8
  %tensor.rank.ptr282 = getelementptr inbounds %csec.tensor, ptr %tensor.malloc25, i32 0, i32 0
  %tensor.rank283 = load i64, ptr %tensor.rank.ptr282, align 4
  %tensor.rank.ptr284 = getelementptr inbounds %csec.tensor, ptr %tensor.malloc47, i32 0, i32 0
  %tensor.rank285 = load i64, ptr %tensor.rank.ptr284, align 4
  %tensor.count.ptr286 = getelementptr inbounds %csec.tensor, ptr %tensor.malloc25, i32 0, i32 2
  %tensor.count287 = load i64, ptr %tensor.count.ptr286, align 4
  %tensor.count.ptr288 = getelementptr inbounds %csec.tensor, ptr %tensor.malloc47, i32 0, i32 2
  %tensor.count289 = load i64, ptr %tensor.count.ptr288, align 4
  %tensor.outer.rank290 = add i64 %tensor.rank283, %tensor.rank285
  %tensor.outer.count291 = mul i64 %tensor.count287, %tensor.count289
  %tensor.malloc292 = call ptr @malloc(i64 32)
  %tensor.dims.bytes293 = mul i64 %tensor.outer.rank290, 8
  %tensor.malloc294 = call ptr @malloc(i64 %tensor.dims.bytes293)
  %tensor.data.bytes295 = mul i64 %tensor.outer.count291, 8
  %tensor.malloc296 = call ptr @malloc(i64 %tensor.data.bytes295)
  %tensor.rank.slot297 = getelementptr inbounds %csec.tensor, ptr %tensor.malloc292, i32 0, i32 0
  store i64 %tensor.outer.rank290, ptr %tensor.rank.slot297, align 4
  %tensor.dims.slot298 = getelementptr inbounds %csec.tensor, ptr %tensor.malloc292, i32 0, i32 1
  store ptr %tensor.malloc294, ptr %tensor.dims.slot298, align 8
  %tensor.count.slot299 = getelementptr inbounds %csec.tensor, ptr %tensor.malloc292, i32 0, i32 2
  store i64 %tensor.outer.count291, ptr %tensor.count.slot299, align 4
  %tensor.data.slot300 = getelementptr inbounds %csec.tensor, ptr %tensor.malloc292, i32 0, i32 3
  store ptr %tensor.malloc296, ptr %tensor.data.slot300, align 8
  %tensor.dims.ptr301 = getelementptr inbounds %csec.tensor, ptr %tensor.malloc25, i32 0, i32 1
  %tensor.dims302 = load ptr, ptr %tensor.dims.ptr301, align 8
  %tensor.dims.ptr303 = getelementptr inbounds %csec.tensor, ptr %tensor.malloc47, i32 0, i32 1
  %tensor.dims304 = load ptr, ptr %tensor.dims.ptr303, align 8
  %tensor.dims.ptr305 = getelementptr inbounds %csec.tensor, ptr %tensor.malloc292, i32 0, i32 1
  %tensor.dims306 = load ptr, ptr %tensor.dims.ptr305, align 8
  %tensor.data.ptr307 = getelementptr inbounds %csec.tensor, ptr %tensor.malloc25, i32 0, i32 3
  %tensor.data308 = load ptr, ptr %tensor.data.ptr307, align 8
  %tensor.data.ptr309 = getelementptr inbounds %csec.tensor, ptr %tensor.malloc47, i32 0, i32 3
  %tensor.data310 = load ptr, ptr %tensor.data.ptr309, align 8
  %tensor.data.ptr311 = getelementptr inbounds %csec.tensor, ptr %tensor.malloc292, i32 0, i32 3
  %tensor.data312 = load ptr, ptr %tensor.data.ptr311, align 8
  %tensor.outer.left.dims.i313 = alloca i64, align 8
  store i64 0, ptr %tensor.outer.left.dims.i313, align 4
  br label %tensor.outer.left.dims.cond314

tensor.outer.right.cond268:                       ; preds = %tensor.outer.right.body269, %tensor.outer.left.body261
  %tensor.outer.right.idx271 = load i64, ptr %tensor.outer.right.i267, align 4
  %tensor.outer.right.keep272 = icmp ult i64 %tensor.outer.right.idx271, %tensor.count213
  br i1 %tensor.outer.right.keep272, label %tensor.outer.right.body269, label %tensor.outer.right.end270

tensor.outer.right.body269:                       ; preds = %tensor.outer.right.cond268
  %tensor.outer.right.val273 = getelementptr double, ptr %tensor.data234, i64 %tensor.outer.right.idx271
  %7 = mul i64 %tensor.outer.left.idx263, %tensor.count213
  %tensor.outer.dst.index274 = add i64 %7, %tensor.outer.right.idx271
  %tensor.outer.dst.val275 = getelementptr double, ptr %tensor.data236, i64 %tensor.outer.dst.index274
  %tensor.outer.r276 = load double, ptr %tensor.outer.right.val273, align 8
  %tensor.outer.product277 = fmul double %tensor.outer.l266, %tensor.outer.r276
  store double %tensor.outer.product277, ptr %tensor.outer.dst.val275, align 8
  %tensor.outer.right.current278 = load i64, ptr %tensor.outer.right.i267, align 4
  %tensor.outer.right.next279 = add i64 %tensor.outer.right.current278, 1
  store i64 %tensor.outer.right.next279, ptr %tensor.outer.right.i267, align 4
  br label %tensor.outer.right.cond268

tensor.outer.right.end270:                        ; preds = %tensor.outer.right.cond268
  %tensor.outer.left.current280 = load i64, ptr %tensor.outer.left.i259, align 4
  %tensor.outer.left.next281 = add i64 %tensor.outer.left.current280, 1
  store i64 %tensor.outer.left.next281, ptr %tensor.outer.left.i259, align 4
  br label %tensor.outer.left.cond260

tensor.outer.left.dims.cond314:                   ; preds = %tensor.outer.left.dims.body315, %tensor.outer.left.end262
  %tensor.outer.left.dims.idx317 = load i64, ptr %tensor.outer.left.dims.i313, align 4
  %tensor.outer.left.dims.keep318 = icmp ult i64 %tensor.outer.left.dims.idx317, %tensor.rank283
  br i1 %tensor.outer.left.dims.keep318, label %tensor.outer.left.dims.body315, label %tensor.outer.left.dims.end316

tensor.outer.left.dims.body315:                   ; preds = %tensor.outer.left.dims.cond314
  %tensor.outer.left.dim319 = getelementptr i64, ptr %tensor.dims302, i64 %tensor.outer.left.dims.idx317
  %tensor.outer.dst.dim320 = getelementptr i64, ptr %tensor.dims306, i64 %tensor.outer.left.dims.idx317
  %tensor.outer.dim321 = load i64, ptr %tensor.outer.left.dim319, align 4
  store i64 %tensor.outer.dim321, ptr %tensor.outer.dst.dim320, align 4
  %tensor.outer.left.dims.current322 = load i64, ptr %tensor.outer.left.dims.i313, align 4
  %tensor.outer.left.dims.next323 = add i64 %tensor.outer.left.dims.current322, 1
  store i64 %tensor.outer.left.dims.next323, ptr %tensor.outer.left.dims.i313, align 4
  br label %tensor.outer.left.dims.cond314

tensor.outer.left.dims.end316:                    ; preds = %tensor.outer.left.dims.cond314
  %tensor.outer.right.dims.i324 = alloca i64, align 8
  store i64 0, ptr %tensor.outer.right.dims.i324, align 4
  br label %tensor.outer.right.dims.cond325

tensor.outer.right.dims.cond325:                  ; preds = %tensor.outer.right.dims.body326, %tensor.outer.left.dims.end316
  %tensor.outer.right.dims.idx328 = load i64, ptr %tensor.outer.right.dims.i324, align 4
  %tensor.outer.right.dims.keep329 = icmp ult i64 %tensor.outer.right.dims.idx328, %tensor.rank285
  br i1 %tensor.outer.right.dims.keep329, label %tensor.outer.right.dims.body326, label %tensor.outer.right.dims.end327

tensor.outer.right.dims.body326:                  ; preds = %tensor.outer.right.dims.cond325
  %tensor.outer.right.dim330 = getelementptr i64, ptr %tensor.dims304, i64 %tensor.outer.right.dims.idx328
  %8 = add i64 %tensor.rank283, %tensor.outer.right.dims.idx328
  %tensor.outer.dst.dim331 = getelementptr i64, ptr %tensor.dims306, i64 %8
  %tensor.outer.dim332 = load i64, ptr %tensor.outer.right.dim330, align 4
  store i64 %tensor.outer.dim332, ptr %tensor.outer.dst.dim331, align 4
  %tensor.outer.right.dims.current333 = load i64, ptr %tensor.outer.right.dims.i324, align 4
  %tensor.outer.right.dims.next334 = add i64 %tensor.outer.right.dims.current333, 1
  store i64 %tensor.outer.right.dims.next334, ptr %tensor.outer.right.dims.i324, align 4
  br label %tensor.outer.right.dims.cond325

tensor.outer.right.dims.end327:                   ; preds = %tensor.outer.right.dims.cond325
  %tensor.outer.left.i335 = alloca i64, align 8
  store i64 0, ptr %tensor.outer.left.i335, align 4
  br label %tensor.outer.left.cond336

tensor.outer.left.cond336:                        ; preds = %tensor.outer.right.end346, %tensor.outer.right.dims.end327
  %tensor.outer.left.idx339 = load i64, ptr %tensor.outer.left.i335, align 4
  %tensor.outer.left.keep340 = icmp ult i64 %tensor.outer.left.idx339, %tensor.count287
  br i1 %tensor.outer.left.keep340, label %tensor.outer.left.body337, label %tensor.outer.left.end338

tensor.outer.left.body337:                        ; preds = %tensor.outer.left.cond336
  %tensor.outer.left.val341 = getelementptr double, ptr %tensor.data308, i64 %tensor.outer.left.idx339
  %tensor.outer.l342 = load double, ptr %tensor.outer.left.val341, align 8
  %tensor.outer.right.i343 = alloca i64, align 8
  store i64 0, ptr %tensor.outer.right.i343, align 4
  br label %tensor.outer.right.cond344

tensor.outer.left.end338:                         ; preds = %tensor.outer.left.cond336
  %kron2 = alloca ptr, align 8
  store ptr %tensor.malloc292, ptr %kron2, align 8
  %tensor.dims.ptr358 = getelementptr inbounds %csec.tensor, ptr %tensor.malloc25, i32 0, i32 1
  %tensor.dims359 = load ptr, ptr %tensor.dims.ptr358, align 8
  %tensor.dims.ptr360 = getelementptr inbounds %csec.tensor, ptr %tensor.malloc47, i32 0, i32 1
  %tensor.dims361 = load ptr, ptr %tensor.dims.ptr360, align 8
  %tensor.matmul.rows.ptr = getelementptr i64, ptr %tensor.dims359, i64 0
  %tensor.matmul.rows = load i64, ptr %tensor.matmul.rows.ptr, align 4
  %tensor.matmul.shared.ptr = getelementptr i64, ptr %tensor.dims359, i64 1
  %tensor.matmul.shared = load i64, ptr %tensor.matmul.shared.ptr, align 4
  %tensor.matmul.cols.ptr = getelementptr i64, ptr %tensor.dims361, i64 1
  %tensor.matmul.cols = load i64, ptr %tensor.matmul.cols.ptr, align 4
  %tensor.matmul.count = mul i64 %tensor.matmul.rows, %tensor.matmul.cols
  %tensor.malloc362 = call ptr @malloc(i64 32)
  %tensor.malloc363 = call ptr @malloc(i64 16)
  %tensor.data.bytes364 = mul i64 %tensor.matmul.count, 8
  %tensor.malloc365 = call ptr @malloc(i64 %tensor.data.bytes364)
  %tensor.rank.slot366 = getelementptr inbounds %csec.tensor, ptr %tensor.malloc362, i32 0, i32 0
  store i64 2, ptr %tensor.rank.slot366, align 4
  %tensor.dims.slot367 = getelementptr inbounds %csec.tensor, ptr %tensor.malloc362, i32 0, i32 1
  store ptr %tensor.malloc363, ptr %tensor.dims.slot367, align 8
  %tensor.count.slot368 = getelementptr inbounds %csec.tensor, ptr %tensor.malloc362, i32 0, i32 2
  store i64 %tensor.matmul.count, ptr %tensor.count.slot368, align 4
  %tensor.data.slot369 = getelementptr inbounds %csec.tensor, ptr %tensor.malloc362, i32 0, i32 3
  store ptr %tensor.malloc365, ptr %tensor.data.slot369, align 8
  %tensor.dims.ptr370 = getelementptr inbounds %csec.tensor, ptr %tensor.malloc362, i32 0, i32 1
  %tensor.dims371 = load ptr, ptr %tensor.dims.ptr370, align 8
  %tensor.matmul.dst.rows = getelementptr i64, ptr %tensor.dims371, i64 0
  store i64 %tensor.matmul.rows, ptr %tensor.matmul.dst.rows, align 4
  %tensor.matmul.dst.cols = getelementptr i64, ptr %tensor.dims371, i64 1
  store i64 %tensor.matmul.cols, ptr %tensor.matmul.dst.cols, align 4
  %tensor.data.ptr372 = getelementptr inbounds %csec.tensor, ptr %tensor.malloc25, i32 0, i32 3
  %tensor.data373 = load ptr, ptr %tensor.data.ptr372, align 8
  %tensor.data.ptr374 = getelementptr inbounds %csec.tensor, ptr %tensor.malloc47, i32 0, i32 3
  %tensor.data375 = load ptr, ptr %tensor.data.ptr374, align 8
  %tensor.data.ptr376 = getelementptr inbounds %csec.tensor, ptr %tensor.malloc362, i32 0, i32 3
  %tensor.data377 = load ptr, ptr %tensor.data.ptr376, align 8
  %tensor.matmul.i.i = alloca i64, align 8
  store i64 0, ptr %tensor.matmul.i.i, align 4
  br label %tensor.matmul.i.cond

tensor.outer.right.cond344:                       ; preds = %tensor.outer.right.body345, %tensor.outer.left.body337
  %tensor.outer.right.idx347 = load i64, ptr %tensor.outer.right.i343, align 4
  %tensor.outer.right.keep348 = icmp ult i64 %tensor.outer.right.idx347, %tensor.count289
  br i1 %tensor.outer.right.keep348, label %tensor.outer.right.body345, label %tensor.outer.right.end346

tensor.outer.right.body345:                       ; preds = %tensor.outer.right.cond344
  %tensor.outer.right.val349 = getelementptr double, ptr %tensor.data310, i64 %tensor.outer.right.idx347
  %9 = mul i64 %tensor.outer.left.idx339, %tensor.count289
  %tensor.outer.dst.index350 = add i64 %9, %tensor.outer.right.idx347
  %tensor.outer.dst.val351 = getelementptr double, ptr %tensor.data312, i64 %tensor.outer.dst.index350
  %tensor.outer.r352 = load double, ptr %tensor.outer.right.val349, align 8
  %tensor.outer.product353 = fmul double %tensor.outer.l342, %tensor.outer.r352
  store double %tensor.outer.product353, ptr %tensor.outer.dst.val351, align 8
  %tensor.outer.right.current354 = load i64, ptr %tensor.outer.right.i343, align 4
  %tensor.outer.right.next355 = add i64 %tensor.outer.right.current354, 1
  store i64 %tensor.outer.right.next355, ptr %tensor.outer.right.i343, align 4
  br label %tensor.outer.right.cond344

tensor.outer.right.end346:                        ; preds = %tensor.outer.right.cond344
  %tensor.outer.left.current356 = load i64, ptr %tensor.outer.left.i335, align 4
  %tensor.outer.left.next357 = add i64 %tensor.outer.left.current356, 1
  store i64 %tensor.outer.left.next357, ptr %tensor.outer.left.i335, align 4
  br label %tensor.outer.left.cond336

tensor.matmul.i.cond:                             ; preds = %tensor.matmul.j.end, %tensor.outer.left.end338
  %tensor.matmul.i.idx = load i64, ptr %tensor.matmul.i.i, align 4
  %tensor.matmul.i.keep = icmp ult i64 %tensor.matmul.i.idx, %tensor.matmul.rows
  br i1 %tensor.matmul.i.keep, label %tensor.matmul.i.body, label %tensor.matmul.i.end

tensor.matmul.i.body:                             ; preds = %tensor.matmul.i.cond
  %tensor.matmul.j.i = alloca i64, align 8
  store i64 0, ptr %tensor.matmul.j.i, align 4
  br label %tensor.matmul.j.cond

tensor.matmul.i.end:                              ; preds = %tensor.matmul.i.cond
  %matmul = alloca ptr, align 8
  store ptr %tensor.malloc362, ptr %matmul, align 8
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
  %10 = mul i64 %tensor.matmul.i.idx, %tensor.matmul.shared
  %tensor.matmul.left.index = add i64 %10, %tensor.matmul.k.idx
  %11 = mul i64 %tensor.matmul.k.idx, %tensor.matmul.cols
  %tensor.matmul.right.index = add i64 %11, %tensor.matmul.j.idx
  %12 = getelementptr double, ptr %tensor.data375, i64 %tensor.matmul.right.index
  %tensor.matmul.right = load double, ptr %12, align 8
  %13 = getelementptr double, ptr %tensor.data373, i64 %tensor.matmul.left.index
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
  %14 = mul i64 %tensor.matmul.i.idx, %tensor.matmul.cols
  %tensor.matmul.dst.index = add i64 %14, %tensor.matmul.j.idx
  %tensor.matmul.dst = getelementptr double, ptr %tensor.data377, i64 %tensor.matmul.dst.index
  %tensor.matmul.sum = load double, ptr %tensor.matmul.sum.ptr, align 8
  store double %tensor.matmul.sum, ptr %tensor.matmul.dst, align 8
  %tensor.matmul.j.current = load i64, ptr %tensor.matmul.j.i, align 4
  %tensor.matmul.j.next = add i64 %tensor.matmul.j.current, 1
  store i64 %tensor.matmul.j.next, ptr %tensor.matmul.j.i, align 4
  br label %tensor.matmul.j.cond
}

declare void @csec_set_command_line_args(i32, ptr)

define internal i32 @__csec_jit_entry() {
entry:
  %user.main = call i32 @_main()
  ret i32 %user.main
}
