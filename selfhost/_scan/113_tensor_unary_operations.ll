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
  %tensor.malloc2 = call ptr @malloc(i64 48)
  %tensor.rank.slot = getelementptr inbounds %csec.tensor, ptr %tensor.malloc, i32 0, i32 0
  store i64 2, ptr %tensor.rank.slot, align 4
  %tensor.dims.slot = getelementptr inbounds %csec.tensor, ptr %tensor.malloc, i32 0, i32 1
  store ptr %tensor.malloc1, ptr %tensor.dims.slot, align 8
  %tensor.count.slot = getelementptr inbounds %csec.tensor, ptr %tensor.malloc, i32 0, i32 2
  store i64 6, ptr %tensor.count.slot, align 4
  %tensor.data.slot = getelementptr inbounds %csec.tensor, ptr %tensor.malloc, i32 0, i32 3
  store ptr %tensor.malloc2, ptr %tensor.data.slot, align 8
  %tensor.dims.ptr = getelementptr inbounds %csec.tensor, ptr %tensor.malloc, i32 0, i32 1
  %tensor.dims = load ptr, ptr %tensor.dims.ptr, align 8
  %tensor.data.ptr = getelementptr inbounds %csec.tensor, ptr %tensor.malloc, i32 0, i32 3
  %tensor.data = load ptr, ptr %tensor.data.ptr, align 8
  %tensor.dim.slot = getelementptr i64, ptr %tensor.dims, i64 0
  store i64 2, ptr %tensor.dim.slot, align 4
  %tensor.dim.slot3 = getelementptr i64, ptr %tensor.dims, i64 1
  store i64 3, ptr %tensor.dim.slot3, align 4
  br label %tensor.fill.cond

tensor.fill.cond:                                 ; preds = %tensor.fill.body, %entry
  %tensor.fill.i.0 = phi i64 [ 0, %entry ], [ %tensor.fill.next, %tensor.fill.body ]
  %tensor.fill.keep = icmp ult i64 %tensor.fill.i.0, 6
  br i1 %tensor.fill.keep, label %tensor.fill.body, label %tensor.fill.end

tensor.fill.body:                                 ; preds = %tensor.fill.cond
  %tensor.data.slot4 = getelementptr double, ptr %tensor.data, i64 %tensor.fill.i.0
  store double 0.000000e+00, ptr %tensor.data.slot4, align 8
  %tensor.fill.next = add i64 %tensor.fill.i.0, 1
  br label %tensor.fill.cond

tensor.fill.end:                                  ; preds = %tensor.fill.cond
  %tensor.malloc5 = call ptr @malloc(i64 32)
  %tensor.malloc6 = call ptr @malloc(i64 16)
  %tensor.malloc7 = call ptr @malloc(i64 48)
  %tensor.rank.slot8 = getelementptr inbounds %csec.tensor, ptr %tensor.malloc5, i32 0, i32 0
  store i64 2, ptr %tensor.rank.slot8, align 4
  %tensor.dims.slot9 = getelementptr inbounds %csec.tensor, ptr %tensor.malloc5, i32 0, i32 1
  store ptr %tensor.malloc6, ptr %tensor.dims.slot9, align 8
  %tensor.count.slot10 = getelementptr inbounds %csec.tensor, ptr %tensor.malloc5, i32 0, i32 2
  store i64 6, ptr %tensor.count.slot10, align 4
  %tensor.data.slot11 = getelementptr inbounds %csec.tensor, ptr %tensor.malloc5, i32 0, i32 3
  store ptr %tensor.malloc7, ptr %tensor.data.slot11, align 8
  %tensor.dims.ptr12 = getelementptr inbounds %csec.tensor, ptr %tensor.malloc5, i32 0, i32 1
  %tensor.dims13 = load ptr, ptr %tensor.dims.ptr12, align 8
  %tensor.data.ptr14 = getelementptr inbounds %csec.tensor, ptr %tensor.malloc5, i32 0, i32 3
  %tensor.data15 = load ptr, ptr %tensor.data.ptr14, align 8
  %tensor.dim.slot16 = getelementptr i64, ptr %tensor.dims13, i64 0
  store i64 2, ptr %tensor.dim.slot16, align 4
  %tensor.dim.slot17 = getelementptr i64, ptr %tensor.dims13, i64 1
  store i64 3, ptr %tensor.dim.slot17, align 4
  %tensor.fill.i18 = alloca i64, align 8
  store i64 0, ptr %tensor.fill.i18, align 4
  br label %tensor.fill.cond19

tensor.fill.cond19:                               ; preds = %tensor.fill.body20, %tensor.fill.end
  %tensor.fill.idx22 = load i64, ptr %tensor.fill.i18, align 4
  %tensor.fill.keep23 = icmp ult i64 %tensor.fill.idx22, 6
  br i1 %tensor.fill.keep23, label %tensor.fill.body20, label %tensor.fill.end21

tensor.fill.body20:                               ; preds = %tensor.fill.cond19
  %tensor.data.slot24 = getelementptr double, ptr %tensor.data15, i64 %tensor.fill.idx22
  store double 1.000000e+00, ptr %tensor.data.slot24, align 8
  %tensor.fill.current25 = load i64, ptr %tensor.fill.i18, align 4
  %tensor.fill.next26 = add i64 %tensor.fill.current25, 1
  store i64 %tensor.fill.next26, ptr %tensor.fill.i18, align 4
  br label %tensor.fill.cond19

tensor.fill.end21:                                ; preds = %tensor.fill.cond19
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
  %tensor.data.ptr40 = getelementptr inbounds %csec.tensor, ptr %tensor.malloc27, i32 0, i32 3
  %tensor.data41 = load ptr, ptr %tensor.data.ptr40, align 8
  %tensor.last.dim = sub i64 %tensor.rank, 1
  %tensor.prev.dim = sub i64 %tensor.rank, 2
  %tensor.transpose.dims.i = alloca i64, align 8
  store i64 0, ptr %tensor.transpose.dims.i, align 4
  br label %tensor.transpose.dims.cond

tensor.transpose.dims.cond:                       ; preds = %tensor.transpose.dims.body, %tensor.fill.end21
  %tensor.transpose.dims.idx = load i64, ptr %tensor.transpose.dims.i, align 4
  %tensor.transpose.dims.keep = icmp ult i64 %tensor.transpose.dims.idx, %tensor.rank
  br i1 %tensor.transpose.dims.keep, label %tensor.transpose.dims.body, label %tensor.transpose.dims.end

tensor.transpose.dims.body:                       ; preds = %tensor.transpose.dims.cond
  %tensor.use.last = icmp eq i64 %tensor.transpose.dims.idx, %tensor.prev.dim
  %tensor.use.prev = icmp eq i64 %tensor.transpose.dims.idx, %tensor.last.dim
  %0 = select i1 %tensor.use.prev, i64 %tensor.prev.dim, i64 %tensor.transpose.dims.idx
  %tensor.transpose.dim.index = select i1 %tensor.use.last, i64 %tensor.last.dim, i64 %0
  %tensor.src.dim = getelementptr i64, ptr %tensor.dims35, i64 %tensor.transpose.dim.index
  %tensor.dst.dim = getelementptr i64, ptr %tensor.dims37, i64 %tensor.transpose.dims.idx
  %tensor.dim = load i64, ptr %tensor.src.dim, align 4
  store i64 %tensor.dim, ptr %tensor.dst.dim, align 4
  %tensor.transpose.dims.current = load i64, ptr %tensor.transpose.dims.i, align 4
  %tensor.transpose.dims.next = add i64 %tensor.transpose.dims.current, 1
  store i64 %tensor.transpose.dims.next, ptr %tensor.transpose.dims.i, align 4
  br label %tensor.transpose.dims.cond

tensor.transpose.dims.end:                        ; preds = %tensor.transpose.dims.cond
  %tensor.rows.slot = getelementptr i64, ptr %tensor.dims35, i64 %tensor.prev.dim
  %tensor.cols.slot = getelementptr i64, ptr %tensor.dims35, i64 %tensor.last.dim
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
  %transposeA = alloca ptr, align 8
  store ptr %tensor.malloc27, ptr %transposeA, align 8
  %tensor.rank.ptr42 = getelementptr inbounds %csec.tensor, ptr %tensor.malloc, i32 0, i32 0
  %tensor.rank43 = load i64, ptr %tensor.rank.ptr42, align 4
  %tensor.count.ptr44 = getelementptr inbounds %csec.tensor, ptr %tensor.malloc, i32 0, i32 2
  %tensor.count45 = load i64, ptr %tensor.count.ptr44, align 4
  %tensor.malloc46 = call ptr @malloc(i64 32)
  %tensor.dims.bytes47 = mul i64 %tensor.rank43, 8
  %tensor.malloc48 = call ptr @malloc(i64 %tensor.dims.bytes47)
  %tensor.data.bytes49 = mul i64 %tensor.count45, 8
  %tensor.malloc50 = call ptr @malloc(i64 %tensor.data.bytes49)
  %tensor.rank.slot51 = getelementptr inbounds %csec.tensor, ptr %tensor.malloc46, i32 0, i32 0
  store i64 %tensor.rank43, ptr %tensor.rank.slot51, align 4
  %tensor.dims.slot52 = getelementptr inbounds %csec.tensor, ptr %tensor.malloc46, i32 0, i32 1
  store ptr %tensor.malloc48, ptr %tensor.dims.slot52, align 8
  %tensor.count.slot53 = getelementptr inbounds %csec.tensor, ptr %tensor.malloc46, i32 0, i32 2
  store i64 %tensor.count45, ptr %tensor.count.slot53, align 4
  %tensor.data.slot54 = getelementptr inbounds %csec.tensor, ptr %tensor.malloc46, i32 0, i32 3
  store ptr %tensor.malloc50, ptr %tensor.data.slot54, align 8
  %tensor.dims.ptr55 = getelementptr inbounds %csec.tensor, ptr %tensor.malloc, i32 0, i32 1
  %tensor.dims56 = load ptr, ptr %tensor.dims.ptr55, align 8
  %tensor.dims.ptr57 = getelementptr inbounds %csec.tensor, ptr %tensor.malloc46, i32 0, i32 1
  %tensor.dims58 = load ptr, ptr %tensor.dims.ptr57, align 8
  %tensor.data.ptr59 = getelementptr inbounds %csec.tensor, ptr %tensor.malloc, i32 0, i32 3
  %tensor.data60 = load ptr, ptr %tensor.data.ptr59, align 8
  %tensor.data.ptr61 = getelementptr inbounds %csec.tensor, ptr %tensor.malloc46, i32 0, i32 3
  %tensor.data62 = load ptr, ptr %tensor.data.ptr61, align 8
  %tensor.clone.dims.i = alloca i64, align 8
  store i64 0, ptr %tensor.clone.dims.i, align 4
  br label %tensor.clone.dims.cond

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
  %1 = mul i64 %tensor.transpose.rows.idx, %tensor.cols
  %tensor.transpose.src.index = add i64 %1, %tensor.transpose.cols.idx
  %2 = mul i64 %tensor.transpose.cols.idx, %tensor.rows
  %tensor.transpose.dst.index = add i64 %2, %tensor.transpose.rows.idx
  %tensor.transpose.src = getelementptr double, ptr %tensor.data39, i64 %tensor.transpose.src.index
  %tensor.transpose.dst = getelementptr double, ptr %tensor.data41, i64 %tensor.transpose.dst.index
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
  %tensor.src.val = getelementptr double, ptr %tensor.data39, i64 %tensor.transpose.copy.data.idx
  %tensor.dst.val = getelementptr double, ptr %tensor.data41, i64 %tensor.transpose.copy.data.idx
  %tensor.val = load double, ptr %tensor.src.val, align 8
  store double %tensor.val, ptr %tensor.dst.val, align 8
  %tensor.transpose.copy.data.current = load i64, ptr %tensor.transpose.copy.data.i, align 4
  %tensor.transpose.copy.data.next = add i64 %tensor.transpose.copy.data.current, 1
  store i64 %tensor.transpose.copy.data.next, ptr %tensor.transpose.copy.data.i, align 4
  br label %tensor.transpose.copy.data.cond

tensor.transpose.copy.data.end:                   ; preds = %tensor.transpose.copy.data.cond
  br label %tensor.transpose.end

tensor.clone.dims.cond:                           ; preds = %tensor.clone.dims.body, %tensor.transpose.end
  %tensor.clone.dims.idx = load i64, ptr %tensor.clone.dims.i, align 4
  %tensor.clone.dims.keep = icmp ult i64 %tensor.clone.dims.idx, %tensor.rank43
  br i1 %tensor.clone.dims.keep, label %tensor.clone.dims.body, label %tensor.clone.dims.end

tensor.clone.dims.body:                           ; preds = %tensor.clone.dims.cond
  %tensor.src.dim63 = getelementptr i64, ptr %tensor.dims56, i64 %tensor.clone.dims.idx
  %tensor.dst.dim64 = getelementptr i64, ptr %tensor.dims58, i64 %tensor.clone.dims.idx
  %tensor.dim65 = load i64, ptr %tensor.src.dim63, align 4
  store i64 %tensor.dim65, ptr %tensor.dst.dim64, align 4
  %tensor.clone.dims.current = load i64, ptr %tensor.clone.dims.i, align 4
  %tensor.clone.dims.next = add i64 %tensor.clone.dims.current, 1
  store i64 %tensor.clone.dims.next, ptr %tensor.clone.dims.i, align 4
  br label %tensor.clone.dims.cond

tensor.clone.dims.end:                            ; preds = %tensor.clone.dims.cond
  %tensor.clone.data.i = alloca i64, align 8
  store i64 0, ptr %tensor.clone.data.i, align 4
  br label %tensor.clone.data.cond

tensor.clone.data.cond:                           ; preds = %tensor.clone.data.body, %tensor.clone.dims.end
  %tensor.clone.data.idx = load i64, ptr %tensor.clone.data.i, align 4
  %tensor.clone.data.keep = icmp ult i64 %tensor.clone.data.idx, %tensor.count45
  br i1 %tensor.clone.data.keep, label %tensor.clone.data.body, label %tensor.clone.data.end

tensor.clone.data.body:                           ; preds = %tensor.clone.data.cond
  %tensor.src.val66 = getelementptr double, ptr %tensor.data60, i64 %tensor.clone.data.idx
  %tensor.dst.val67 = getelementptr double, ptr %tensor.data62, i64 %tensor.clone.data.idx
  %tensor.val68 = load double, ptr %tensor.src.val66, align 8
  store double %tensor.val68, ptr %tensor.dst.val67, align 8
  %tensor.clone.data.current = load i64, ptr %tensor.clone.data.i, align 4
  %tensor.clone.data.next = add i64 %tensor.clone.data.current, 1
  store i64 %tensor.clone.data.next, ptr %tensor.clone.data.i, align 4
  br label %tensor.clone.data.cond

tensor.clone.data.end:                            ; preds = %tensor.clone.data.cond
  %ac = alloca ptr, align 8
  store ptr %tensor.malloc46, ptr %ac, align 8
  %tensor.rank.ptr69 = getelementptr inbounds %csec.tensor, ptr %tensor.malloc, i32 0, i32 0
  %tensor.rank70 = load i64, ptr %tensor.rank.ptr69, align 4
  %tensor.count.ptr71 = getelementptr inbounds %csec.tensor, ptr %tensor.malloc, i32 0, i32 2
  %tensor.count72 = load i64, ptr %tensor.count.ptr71, align 4
  %tensor.malloc73 = call ptr @malloc(i64 32)
  %tensor.dims.bytes74 = mul i64 %tensor.rank70, 8
  %tensor.malloc75 = call ptr @malloc(i64 %tensor.dims.bytes74)
  %tensor.data.bytes76 = mul i64 %tensor.count72, 8
  %tensor.malloc77 = call ptr @malloc(i64 %tensor.data.bytes76)
  %tensor.rank.slot78 = getelementptr inbounds %csec.tensor, ptr %tensor.malloc73, i32 0, i32 0
  store i64 %tensor.rank70, ptr %tensor.rank.slot78, align 4
  %tensor.dims.slot79 = getelementptr inbounds %csec.tensor, ptr %tensor.malloc73, i32 0, i32 1
  store ptr %tensor.malloc75, ptr %tensor.dims.slot79, align 8
  %tensor.count.slot80 = getelementptr inbounds %csec.tensor, ptr %tensor.malloc73, i32 0, i32 2
  store i64 %tensor.count72, ptr %tensor.count.slot80, align 4
  %tensor.data.slot81 = getelementptr inbounds %csec.tensor, ptr %tensor.malloc73, i32 0, i32 3
  store ptr %tensor.malloc77, ptr %tensor.data.slot81, align 8
  %tensor.dims.ptr82 = getelementptr inbounds %csec.tensor, ptr %tensor.malloc, i32 0, i32 1
  %tensor.dims83 = load ptr, ptr %tensor.dims.ptr82, align 8
  %tensor.dims.ptr84 = getelementptr inbounds %csec.tensor, ptr %tensor.malloc73, i32 0, i32 1
  %tensor.dims85 = load ptr, ptr %tensor.dims.ptr84, align 8
  %tensor.data.ptr86 = getelementptr inbounds %csec.tensor, ptr %tensor.malloc, i32 0, i32 3
  %tensor.data87 = load ptr, ptr %tensor.data.ptr86, align 8
  %tensor.data.ptr88 = getelementptr inbounds %csec.tensor, ptr %tensor.malloc73, i32 0, i32 3
  %tensor.data89 = load ptr, ptr %tensor.data.ptr88, align 8
  %tensor.last.dim90 = sub i64 %tensor.rank70, 1
  %tensor.prev.dim91 = sub i64 %tensor.rank70, 2
  %tensor.transpose.dims.i92 = alloca i64, align 8
  store i64 0, ptr %tensor.transpose.dims.i92, align 4
  br label %tensor.transpose.dims.cond93

tensor.transpose.dims.cond93:                     ; preds = %tensor.transpose.dims.body94, %tensor.clone.data.end
  %tensor.transpose.dims.idx96 = load i64, ptr %tensor.transpose.dims.i92, align 4
  %tensor.transpose.dims.keep97 = icmp ult i64 %tensor.transpose.dims.idx96, %tensor.rank70
  br i1 %tensor.transpose.dims.keep97, label %tensor.transpose.dims.body94, label %tensor.transpose.dims.end95

tensor.transpose.dims.body94:                     ; preds = %tensor.transpose.dims.cond93
  %tensor.use.last98 = icmp eq i64 %tensor.transpose.dims.idx96, %tensor.prev.dim91
  %tensor.use.prev99 = icmp eq i64 %tensor.transpose.dims.idx96, %tensor.last.dim90
  %3 = select i1 %tensor.use.prev99, i64 %tensor.prev.dim91, i64 %tensor.transpose.dims.idx96
  %tensor.transpose.dim.index100 = select i1 %tensor.use.last98, i64 %tensor.last.dim90, i64 %3
  %tensor.src.dim101 = getelementptr i64, ptr %tensor.dims83, i64 %tensor.transpose.dim.index100
  %tensor.dst.dim102 = getelementptr i64, ptr %tensor.dims85, i64 %tensor.transpose.dims.idx96
  %tensor.dim103 = load i64, ptr %tensor.src.dim101, align 4
  store i64 %tensor.dim103, ptr %tensor.dst.dim102, align 4
  %tensor.transpose.dims.current104 = load i64, ptr %tensor.transpose.dims.i92, align 4
  %tensor.transpose.dims.next105 = add i64 %tensor.transpose.dims.current104, 1
  store i64 %tensor.transpose.dims.next105, ptr %tensor.transpose.dims.i92, align 4
  br label %tensor.transpose.dims.cond93

tensor.transpose.dims.end95:                      ; preds = %tensor.transpose.dims.cond93
  %tensor.rows.slot106 = getelementptr i64, ptr %tensor.dims83, i64 %tensor.prev.dim91
  %tensor.cols.slot107 = getelementptr i64, ptr %tensor.dims83, i64 %tensor.last.dim90
  %tensor.rows108 = load i64, ptr %tensor.rows.slot106, align 4
  %tensor.cols109 = load i64, ptr %tensor.cols.slot107, align 4
  %tensor.rank.ge2110 = icmp uge i64 %tensor.rank70, 2
  br i1 %tensor.rank.ge2110, label %tensor.transpose.data111, label %tensor.transpose.copy112

tensor.transpose.data111:                         ; preds = %tensor.transpose.dims.end95
  %tensor.transpose.rows.i114 = alloca i64, align 8
  store i64 0, ptr %tensor.transpose.rows.i114, align 4
  br label %tensor.transpose.rows.cond115

tensor.transpose.copy112:                         ; preds = %tensor.transpose.dims.end95
  %tensor.transpose.copy.data.i135 = alloca i64, align 8
  store i64 0, ptr %tensor.transpose.copy.data.i135, align 4
  br label %tensor.transpose.copy.data.cond136

tensor.transpose.end113:                          ; preds = %tensor.transpose.copy.data.end138, %tensor.transpose.rows.end117
  %ah = alloca ptr, align 8
  store ptr %tensor.malloc73, ptr %ah, align 8
  %tensor.rank.ptr146 = getelementptr inbounds %csec.tensor, ptr %tensor.malloc5, i32 0, i32 0
  %tensor.rank147 = load i64, ptr %tensor.rank.ptr146, align 4
  %tensor.count.ptr148 = getelementptr inbounds %csec.tensor, ptr %tensor.malloc5, i32 0, i32 2
  %tensor.count149 = load i64, ptr %tensor.count.ptr148, align 4
  %tensor.malloc150 = call ptr @malloc(i64 32)
  %tensor.dims.bytes151 = mul i64 %tensor.rank147, 8
  %tensor.malloc152 = call ptr @malloc(i64 %tensor.dims.bytes151)
  %tensor.data.bytes153 = mul i64 %tensor.count149, 8
  %tensor.malloc154 = call ptr @malloc(i64 %tensor.data.bytes153)
  %tensor.rank.slot155 = getelementptr inbounds %csec.tensor, ptr %tensor.malloc150, i32 0, i32 0
  store i64 %tensor.rank147, ptr %tensor.rank.slot155, align 4
  %tensor.dims.slot156 = getelementptr inbounds %csec.tensor, ptr %tensor.malloc150, i32 0, i32 1
  store ptr %tensor.malloc152, ptr %tensor.dims.slot156, align 8
  %tensor.count.slot157 = getelementptr inbounds %csec.tensor, ptr %tensor.malloc150, i32 0, i32 2
  store i64 %tensor.count149, ptr %tensor.count.slot157, align 4
  %tensor.data.slot158 = getelementptr inbounds %csec.tensor, ptr %tensor.malloc150, i32 0, i32 3
  store ptr %tensor.malloc154, ptr %tensor.data.slot158, align 8
  %tensor.dims.ptr159 = getelementptr inbounds %csec.tensor, ptr %tensor.malloc5, i32 0, i32 1
  %tensor.dims160 = load ptr, ptr %tensor.dims.ptr159, align 8
  %tensor.dims.ptr161 = getelementptr inbounds %csec.tensor, ptr %tensor.malloc150, i32 0, i32 1
  %tensor.dims162 = load ptr, ptr %tensor.dims.ptr161, align 8
  %tensor.data.ptr163 = getelementptr inbounds %csec.tensor, ptr %tensor.malloc5, i32 0, i32 3
  %tensor.data164 = load ptr, ptr %tensor.data.ptr163, align 8
  %tensor.data.ptr165 = getelementptr inbounds %csec.tensor, ptr %tensor.malloc150, i32 0, i32 3
  %tensor.data166 = load ptr, ptr %tensor.data.ptr165, align 8
  %tensor.clone.dims.i167 = alloca i64, align 8
  store i64 0, ptr %tensor.clone.dims.i167, align 4
  br label %tensor.clone.dims.cond168

tensor.transpose.rows.cond115:                    ; preds = %tensor.transpose.cols.end123, %tensor.transpose.data111
  %tensor.transpose.rows.idx118 = load i64, ptr %tensor.transpose.rows.i114, align 4
  %tensor.transpose.rows.keep119 = icmp ult i64 %tensor.transpose.rows.idx118, %tensor.rows108
  br i1 %tensor.transpose.rows.keep119, label %tensor.transpose.rows.body116, label %tensor.transpose.rows.end117

tensor.transpose.rows.body116:                    ; preds = %tensor.transpose.rows.cond115
  %tensor.transpose.cols.i120 = alloca i64, align 8
  store i64 0, ptr %tensor.transpose.cols.i120, align 4
  br label %tensor.transpose.cols.cond121

tensor.transpose.rows.end117:                     ; preds = %tensor.transpose.rows.cond115
  br label %tensor.transpose.end113

tensor.transpose.cols.cond121:                    ; preds = %tensor.transpose.cols.body122, %tensor.transpose.rows.body116
  %tensor.transpose.cols.idx124 = load i64, ptr %tensor.transpose.cols.i120, align 4
  %tensor.transpose.cols.keep125 = icmp ult i64 %tensor.transpose.cols.idx124, %tensor.cols109
  br i1 %tensor.transpose.cols.keep125, label %tensor.transpose.cols.body122, label %tensor.transpose.cols.end123

tensor.transpose.cols.body122:                    ; preds = %tensor.transpose.cols.cond121
  %4 = mul i64 %tensor.transpose.rows.idx118, %tensor.cols109
  %tensor.transpose.src.index126 = add i64 %4, %tensor.transpose.cols.idx124
  %5 = mul i64 %tensor.transpose.cols.idx124, %tensor.rows108
  %tensor.transpose.dst.index127 = add i64 %5, %tensor.transpose.rows.idx118
  %tensor.transpose.src128 = getelementptr double, ptr %tensor.data87, i64 %tensor.transpose.src.index126
  %tensor.transpose.dst129 = getelementptr double, ptr %tensor.data89, i64 %tensor.transpose.dst.index127
  %tensor.transpose.val130 = load double, ptr %tensor.transpose.src128, align 8
  store double %tensor.transpose.val130, ptr %tensor.transpose.dst129, align 8
  %tensor.transpose.cols.current131 = load i64, ptr %tensor.transpose.cols.i120, align 4
  %tensor.transpose.cols.next132 = add i64 %tensor.transpose.cols.current131, 1
  store i64 %tensor.transpose.cols.next132, ptr %tensor.transpose.cols.i120, align 4
  br label %tensor.transpose.cols.cond121

tensor.transpose.cols.end123:                     ; preds = %tensor.transpose.cols.cond121
  %tensor.transpose.rows.current133 = load i64, ptr %tensor.transpose.rows.i114, align 4
  %tensor.transpose.rows.next134 = add i64 %tensor.transpose.rows.current133, 1
  store i64 %tensor.transpose.rows.next134, ptr %tensor.transpose.rows.i114, align 4
  br label %tensor.transpose.rows.cond115

tensor.transpose.copy.data.cond136:               ; preds = %tensor.transpose.copy.data.body137, %tensor.transpose.copy112
  %tensor.transpose.copy.data.idx139 = load i64, ptr %tensor.transpose.copy.data.i135, align 4
  %tensor.transpose.copy.data.keep140 = icmp ult i64 %tensor.transpose.copy.data.idx139, %tensor.count72
  br i1 %tensor.transpose.copy.data.keep140, label %tensor.transpose.copy.data.body137, label %tensor.transpose.copy.data.end138

tensor.transpose.copy.data.body137:               ; preds = %tensor.transpose.copy.data.cond136
  %tensor.src.val141 = getelementptr double, ptr %tensor.data87, i64 %tensor.transpose.copy.data.idx139
  %tensor.dst.val142 = getelementptr double, ptr %tensor.data89, i64 %tensor.transpose.copy.data.idx139
  %tensor.val143 = load double, ptr %tensor.src.val141, align 8
  store double %tensor.val143, ptr %tensor.dst.val142, align 8
  %tensor.transpose.copy.data.current144 = load i64, ptr %tensor.transpose.copy.data.i135, align 4
  %tensor.transpose.copy.data.next145 = add i64 %tensor.transpose.copy.data.current144, 1
  store i64 %tensor.transpose.copy.data.next145, ptr %tensor.transpose.copy.data.i135, align 4
  br label %tensor.transpose.copy.data.cond136

tensor.transpose.copy.data.end138:                ; preds = %tensor.transpose.copy.data.cond136
  br label %tensor.transpose.end113

tensor.clone.dims.cond168:                        ; preds = %tensor.clone.dims.body169, %tensor.transpose.end113
  %tensor.clone.dims.idx171 = load i64, ptr %tensor.clone.dims.i167, align 4
  %tensor.clone.dims.keep172 = icmp ult i64 %tensor.clone.dims.idx171, %tensor.rank147
  br i1 %tensor.clone.dims.keep172, label %tensor.clone.dims.body169, label %tensor.clone.dims.end170

tensor.clone.dims.body169:                        ; preds = %tensor.clone.dims.cond168
  %tensor.src.dim173 = getelementptr i64, ptr %tensor.dims160, i64 %tensor.clone.dims.idx171
  %tensor.dst.dim174 = getelementptr i64, ptr %tensor.dims162, i64 %tensor.clone.dims.idx171
  %tensor.dim175 = load i64, ptr %tensor.src.dim173, align 4
  store i64 %tensor.dim175, ptr %tensor.dst.dim174, align 4
  %tensor.clone.dims.current176 = load i64, ptr %tensor.clone.dims.i167, align 4
  %tensor.clone.dims.next177 = add i64 %tensor.clone.dims.current176, 1
  store i64 %tensor.clone.dims.next177, ptr %tensor.clone.dims.i167, align 4
  br label %tensor.clone.dims.cond168

tensor.clone.dims.end170:                         ; preds = %tensor.clone.dims.cond168
  %tensor.clone.data.i178 = alloca i64, align 8
  store i64 0, ptr %tensor.clone.data.i178, align 4
  br label %tensor.clone.data.cond179

tensor.clone.data.cond179:                        ; preds = %tensor.clone.data.body180, %tensor.clone.dims.end170
  %tensor.clone.data.idx182 = load i64, ptr %tensor.clone.data.i178, align 4
  %tensor.clone.data.keep183 = icmp ult i64 %tensor.clone.data.idx182, %tensor.count149
  br i1 %tensor.clone.data.keep183, label %tensor.clone.data.body180, label %tensor.clone.data.end181

tensor.clone.data.body180:                        ; preds = %tensor.clone.data.cond179
  %tensor.src.val184 = getelementptr double, ptr %tensor.data164, i64 %tensor.clone.data.idx182
  %tensor.dst.val185 = getelementptr double, ptr %tensor.data166, i64 %tensor.clone.data.idx182
  %tensor.val186 = load double, ptr %tensor.src.val184, align 8
  store double %tensor.val186, ptr %tensor.dst.val185, align 8
  %tensor.clone.data.current187 = load i64, ptr %tensor.clone.data.i178, align 4
  %tensor.clone.data.next188 = add i64 %tensor.clone.data.current187, 1
  store i64 %tensor.clone.data.next188, ptr %tensor.clone.data.i178, align 4
  br label %tensor.clone.data.cond179

tensor.clone.data.end181:                         ; preds = %tensor.clone.data.cond179
  %tensor.rank.ptr189 = getelementptr inbounds %csec.tensor, ptr %tensor.malloc150, i32 0, i32 0
  %tensor.rank190 = load i64, ptr %tensor.rank.ptr189, align 4
  %tensor.count.ptr191 = getelementptr inbounds %csec.tensor, ptr %tensor.malloc150, i32 0, i32 2
  %tensor.count192 = load i64, ptr %tensor.count.ptr191, align 4
  %tensor.malloc193 = call ptr @malloc(i64 32)
  %tensor.dims.bytes194 = mul i64 %tensor.rank190, 8
  %tensor.malloc195 = call ptr @malloc(i64 %tensor.dims.bytes194)
  %tensor.data.bytes196 = mul i64 %tensor.count192, 8
  %tensor.malloc197 = call ptr @malloc(i64 %tensor.data.bytes196)
  %tensor.rank.slot198 = getelementptr inbounds %csec.tensor, ptr %tensor.malloc193, i32 0, i32 0
  store i64 %tensor.rank190, ptr %tensor.rank.slot198, align 4
  %tensor.dims.slot199 = getelementptr inbounds %csec.tensor, ptr %tensor.malloc193, i32 0, i32 1
  store ptr %tensor.malloc195, ptr %tensor.dims.slot199, align 8
  %tensor.count.slot200 = getelementptr inbounds %csec.tensor, ptr %tensor.malloc193, i32 0, i32 2
  store i64 %tensor.count192, ptr %tensor.count.slot200, align 4
  %tensor.data.slot201 = getelementptr inbounds %csec.tensor, ptr %tensor.malloc193, i32 0, i32 3
  store ptr %tensor.malloc197, ptr %tensor.data.slot201, align 8
  %tensor.dims.ptr202 = getelementptr inbounds %csec.tensor, ptr %tensor.malloc150, i32 0, i32 1
  %tensor.dims203 = load ptr, ptr %tensor.dims.ptr202, align 8
  %tensor.dims.ptr204 = getelementptr inbounds %csec.tensor, ptr %tensor.malloc193, i32 0, i32 1
  %tensor.dims205 = load ptr, ptr %tensor.dims.ptr204, align 8
  %tensor.data.ptr206 = getelementptr inbounds %csec.tensor, ptr %tensor.malloc150, i32 0, i32 3
  %tensor.data207 = load ptr, ptr %tensor.data.ptr206, align 8
  %tensor.data.ptr208 = getelementptr inbounds %csec.tensor, ptr %tensor.malloc193, i32 0, i32 3
  %tensor.data209 = load ptr, ptr %tensor.data.ptr208, align 8
  %tensor.last.dim210 = sub i64 %tensor.rank190, 1
  %tensor.prev.dim211 = sub i64 %tensor.rank190, 2
  %tensor.transpose.dims.i212 = alloca i64, align 8
  store i64 0, ptr %tensor.transpose.dims.i212, align 4
  br label %tensor.transpose.dims.cond213

tensor.transpose.dims.cond213:                    ; preds = %tensor.transpose.dims.body214, %tensor.clone.data.end181
  %tensor.transpose.dims.idx216 = load i64, ptr %tensor.transpose.dims.i212, align 4
  %tensor.transpose.dims.keep217 = icmp ult i64 %tensor.transpose.dims.idx216, %tensor.rank190
  br i1 %tensor.transpose.dims.keep217, label %tensor.transpose.dims.body214, label %tensor.transpose.dims.end215

tensor.transpose.dims.body214:                    ; preds = %tensor.transpose.dims.cond213
  %tensor.use.last218 = icmp eq i64 %tensor.transpose.dims.idx216, %tensor.prev.dim211
  %tensor.use.prev219 = icmp eq i64 %tensor.transpose.dims.idx216, %tensor.last.dim210
  %6 = select i1 %tensor.use.prev219, i64 %tensor.prev.dim211, i64 %tensor.transpose.dims.idx216
  %tensor.transpose.dim.index220 = select i1 %tensor.use.last218, i64 %tensor.last.dim210, i64 %6
  %tensor.src.dim221 = getelementptr i64, ptr %tensor.dims203, i64 %tensor.transpose.dim.index220
  %tensor.dst.dim222 = getelementptr i64, ptr %tensor.dims205, i64 %tensor.transpose.dims.idx216
  %tensor.dim223 = load i64, ptr %tensor.src.dim221, align 4
  store i64 %tensor.dim223, ptr %tensor.dst.dim222, align 4
  %tensor.transpose.dims.current224 = load i64, ptr %tensor.transpose.dims.i212, align 4
  %tensor.transpose.dims.next225 = add i64 %tensor.transpose.dims.current224, 1
  store i64 %tensor.transpose.dims.next225, ptr %tensor.transpose.dims.i212, align 4
  br label %tensor.transpose.dims.cond213

tensor.transpose.dims.end215:                     ; preds = %tensor.transpose.dims.cond213
  %tensor.rows.slot226 = getelementptr i64, ptr %tensor.dims203, i64 %tensor.prev.dim211
  %tensor.cols.slot227 = getelementptr i64, ptr %tensor.dims203, i64 %tensor.last.dim210
  %tensor.rows228 = load i64, ptr %tensor.rows.slot226, align 4
  %tensor.cols229 = load i64, ptr %tensor.cols.slot227, align 4
  %tensor.rank.ge2230 = icmp uge i64 %tensor.rank190, 2
  br i1 %tensor.rank.ge2230, label %tensor.transpose.data231, label %tensor.transpose.copy232

tensor.transpose.data231:                         ; preds = %tensor.transpose.dims.end215
  %tensor.transpose.rows.i234 = alloca i64, align 8
  store i64 0, ptr %tensor.transpose.rows.i234, align 4
  br label %tensor.transpose.rows.cond235

tensor.transpose.copy232:                         ; preds = %tensor.transpose.dims.end215
  %tensor.transpose.copy.data.i255 = alloca i64, align 8
  store i64 0, ptr %tensor.transpose.copy.data.i255, align 4
  br label %tensor.transpose.copy.data.cond256

tensor.transpose.end233:                          ; preds = %tensor.transpose.copy.data.end258, %tensor.transpose.rows.end237
  %ct = alloca ptr, align 8
  store ptr %tensor.malloc193, ptr %ct, align 8
  ret i32 0

tensor.transpose.rows.cond235:                    ; preds = %tensor.transpose.cols.end243, %tensor.transpose.data231
  %tensor.transpose.rows.idx238 = load i64, ptr %tensor.transpose.rows.i234, align 4
  %tensor.transpose.rows.keep239 = icmp ult i64 %tensor.transpose.rows.idx238, %tensor.rows228
  br i1 %tensor.transpose.rows.keep239, label %tensor.transpose.rows.body236, label %tensor.transpose.rows.end237

tensor.transpose.rows.body236:                    ; preds = %tensor.transpose.rows.cond235
  %tensor.transpose.cols.i240 = alloca i64, align 8
  store i64 0, ptr %tensor.transpose.cols.i240, align 4
  br label %tensor.transpose.cols.cond241

tensor.transpose.rows.end237:                     ; preds = %tensor.transpose.rows.cond235
  br label %tensor.transpose.end233

tensor.transpose.cols.cond241:                    ; preds = %tensor.transpose.cols.body242, %tensor.transpose.rows.body236
  %tensor.transpose.cols.idx244 = load i64, ptr %tensor.transpose.cols.i240, align 4
  %tensor.transpose.cols.keep245 = icmp ult i64 %tensor.transpose.cols.idx244, %tensor.cols229
  br i1 %tensor.transpose.cols.keep245, label %tensor.transpose.cols.body242, label %tensor.transpose.cols.end243

tensor.transpose.cols.body242:                    ; preds = %tensor.transpose.cols.cond241
  %7 = mul i64 %tensor.transpose.rows.idx238, %tensor.cols229
  %tensor.transpose.src.index246 = add i64 %7, %tensor.transpose.cols.idx244
  %8 = mul i64 %tensor.transpose.cols.idx244, %tensor.rows228
  %tensor.transpose.dst.index247 = add i64 %8, %tensor.transpose.rows.idx238
  %tensor.transpose.src248 = getelementptr double, ptr %tensor.data207, i64 %tensor.transpose.src.index246
  %tensor.transpose.dst249 = getelementptr double, ptr %tensor.data209, i64 %tensor.transpose.dst.index247
  %tensor.transpose.val250 = load double, ptr %tensor.transpose.src248, align 8
  store double %tensor.transpose.val250, ptr %tensor.transpose.dst249, align 8
  %tensor.transpose.cols.current251 = load i64, ptr %tensor.transpose.cols.i240, align 4
  %tensor.transpose.cols.next252 = add i64 %tensor.transpose.cols.current251, 1
  store i64 %tensor.transpose.cols.next252, ptr %tensor.transpose.cols.i240, align 4
  br label %tensor.transpose.cols.cond241

tensor.transpose.cols.end243:                     ; preds = %tensor.transpose.cols.cond241
  %tensor.transpose.rows.current253 = load i64, ptr %tensor.transpose.rows.i234, align 4
  %tensor.transpose.rows.next254 = add i64 %tensor.transpose.rows.current253, 1
  store i64 %tensor.transpose.rows.next254, ptr %tensor.transpose.rows.i234, align 4
  br label %tensor.transpose.rows.cond235

tensor.transpose.copy.data.cond256:               ; preds = %tensor.transpose.copy.data.body257, %tensor.transpose.copy232
  %tensor.transpose.copy.data.idx259 = load i64, ptr %tensor.transpose.copy.data.i255, align 4
  %tensor.transpose.copy.data.keep260 = icmp ult i64 %tensor.transpose.copy.data.idx259, %tensor.count192
  br i1 %tensor.transpose.copy.data.keep260, label %tensor.transpose.copy.data.body257, label %tensor.transpose.copy.data.end258

tensor.transpose.copy.data.body257:               ; preds = %tensor.transpose.copy.data.cond256
  %tensor.src.val261 = getelementptr double, ptr %tensor.data207, i64 %tensor.transpose.copy.data.idx259
  %tensor.dst.val262 = getelementptr double, ptr %tensor.data209, i64 %tensor.transpose.copy.data.idx259
  %tensor.val263 = load double, ptr %tensor.src.val261, align 8
  store double %tensor.val263, ptr %tensor.dst.val262, align 8
  %tensor.transpose.copy.data.current264 = load i64, ptr %tensor.transpose.copy.data.i255, align 4
  %tensor.transpose.copy.data.next265 = add i64 %tensor.transpose.copy.data.current264, 1
  store i64 %tensor.transpose.copy.data.next265, ptr %tensor.transpose.copy.data.i255, align 4
  br label %tensor.transpose.copy.data.cond256

tensor.transpose.copy.data.end258:                ; preds = %tensor.transpose.copy.data.cond256
  br label %tensor.transpose.end233
}

declare void @csec_set_command_line_args(i32, ptr)

define internal i32 @__csec_jit_entry() {
entry:
  %user.main = call i32 @_main()
  ret i32 %user.main
}
