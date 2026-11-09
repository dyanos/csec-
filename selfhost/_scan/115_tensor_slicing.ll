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
  %tensor.malloc2 = call ptr @malloc(i64 96)
  %tensor.rank.slot = getelementptr inbounds %csec.tensor, ptr %tensor.malloc, i32 0, i32 0
  store i64 2, ptr %tensor.rank.slot, align 4
  %tensor.dims.slot = getelementptr inbounds %csec.tensor, ptr %tensor.malloc, i32 0, i32 1
  store ptr %tensor.malloc1, ptr %tensor.dims.slot, align 8
  %tensor.count.slot = getelementptr inbounds %csec.tensor, ptr %tensor.malloc, i32 0, i32 2
  store i64 12, ptr %tensor.count.slot, align 4
  %tensor.data.slot = getelementptr inbounds %csec.tensor, ptr %tensor.malloc, i32 0, i32 3
  store ptr %tensor.malloc2, ptr %tensor.data.slot, align 8
  %tensor.dims.ptr = getelementptr inbounds %csec.tensor, ptr %tensor.malloc, i32 0, i32 1
  %tensor.dims = load ptr, ptr %tensor.dims.ptr, align 8
  %tensor.data.ptr = getelementptr inbounds %csec.tensor, ptr %tensor.malloc, i32 0, i32 3
  %tensor.data = load ptr, ptr %tensor.data.ptr, align 8
  %tensor.dim.slot = getelementptr i64, ptr %tensor.dims, i64 0
  store i64 3, ptr %tensor.dim.slot, align 4
  %tensor.dim.slot3 = getelementptr i64, ptr %tensor.dims, i64 1
  store i64 4, ptr %tensor.dim.slot3, align 4
  br label %tensor.fill.cond

tensor.fill.cond:                                 ; preds = %tensor.fill.body, %entry
  %tensor.fill.i.0 = phi i64 [ 0, %entry ], [ %tensor.fill.next, %tensor.fill.body ]
  %tensor.fill.keep = icmp ult i64 %tensor.fill.i.0, 12
  br i1 %tensor.fill.keep, label %tensor.fill.body, label %tensor.fill.end

tensor.fill.body:                                 ; preds = %tensor.fill.cond
  %tensor.data.slot4 = getelementptr double, ptr %tensor.data, i64 %tensor.fill.i.0
  store double 1.000000e+00, ptr %tensor.data.slot4, align 8
  %tensor.fill.next = add i64 %tensor.fill.i.0, 1
  br label %tensor.fill.cond

tensor.fill.end:                                  ; preds = %tensor.fill.cond
  %tensor.rank.ptr = getelementptr inbounds %csec.tensor, ptr %tensor.malloc, i32 0, i32 0
  %tensor.rank = load i64, ptr %tensor.rank.ptr, align 4
  %tensor.dims.ptr5 = getelementptr inbounds %csec.tensor, ptr %tensor.malloc, i32 0, i32 1
  %tensor.dims6 = load ptr, ptr %tensor.dims.ptr5, align 8
  %tensor.data.ptr7 = getelementptr inbounds %csec.tensor, ptr %tensor.malloc, i32 0, i32 3
  %tensor.data8 = load ptr, ptr %tensor.data.ptr7, align 8
  %tensor.malloc9 = call ptr @malloc(i64 32)
  %tensor.malloc10 = call ptr @malloc(i64 8)
  %tensor.malloc11 = call ptr @malloc(i64 8)
  %tensor.rank.slot12 = getelementptr inbounds %csec.tensor, ptr %tensor.malloc9, i32 0, i32 0
  store i64 1, ptr %tensor.rank.slot12, align 4
  %tensor.dims.slot13 = getelementptr inbounds %csec.tensor, ptr %tensor.malloc9, i32 0, i32 1
  store ptr %tensor.malloc10, ptr %tensor.dims.slot13, align 8
  %tensor.count.slot14 = getelementptr inbounds %csec.tensor, ptr %tensor.malloc9, i32 0, i32 2
  store i64 1, ptr %tensor.count.slot14, align 4
  %tensor.data.slot15 = getelementptr inbounds %csec.tensor, ptr %tensor.malloc9, i32 0, i32 3
  store ptr %tensor.malloc11, ptr %tensor.data.slot15, align 8
  %tensor.dims.ptr16 = getelementptr inbounds %csec.tensor, ptr %tensor.malloc9, i32 0, i32 1
  %tensor.dims17 = load ptr, ptr %tensor.dims.ptr16, align 8
  %tensor.slice.count.ptr = alloca i64, align 8
  store i64 1, ptr %tensor.slice.count.ptr, align 4
  %tensor.slice.dim.ptr = getelementptr i64, ptr %tensor.dims6, i64 1
  %tensor.slice.dim = load i64, ptr %tensor.slice.dim.ptr, align 4
  %tensor.slice.span = sub i64 %tensor.slice.dim, 0
  %0 = add i64 %tensor.slice.span, 0
  %tensor.slice.len = udiv i64 %0, 1
  %tensor.slice.dst.dim = getelementptr i64, ptr %tensor.dims17, i64 0
  store i64 %tensor.slice.len, ptr %tensor.slice.dst.dim, align 4
  %tensor.slice.count = load i64, ptr %tensor.slice.count.ptr, align 4
  %tensor.slice.next.count = mul i64 %tensor.slice.count, %tensor.slice.len
  store i64 %tensor.slice.next.count, ptr %tensor.slice.count.ptr, align 4
  %tensor.slice.total = load i64, ptr %tensor.slice.count.ptr, align 4
  %tensor.malloc18 = call ptr @malloc(i64 32)
  %tensor.malloc19 = call ptr @malloc(i64 8)
  %tensor.data.bytes = mul i64 %tensor.slice.total, 8
  %tensor.malloc20 = call ptr @malloc(i64 %tensor.data.bytes)
  %tensor.rank.slot21 = getelementptr inbounds %csec.tensor, ptr %tensor.malloc18, i32 0, i32 0
  store i64 1, ptr %tensor.rank.slot21, align 4
  %tensor.dims.slot22 = getelementptr inbounds %csec.tensor, ptr %tensor.malloc18, i32 0, i32 1
  store ptr %tensor.malloc19, ptr %tensor.dims.slot22, align 8
  %tensor.count.slot23 = getelementptr inbounds %csec.tensor, ptr %tensor.malloc18, i32 0, i32 2
  store i64 %tensor.slice.total, ptr %tensor.count.slot23, align 4
  %tensor.data.slot24 = getelementptr inbounds %csec.tensor, ptr %tensor.malloc18, i32 0, i32 3
  store ptr %tensor.malloc20, ptr %tensor.data.slot24, align 8
  %tensor.dims.ptr25 = getelementptr inbounds %csec.tensor, ptr %tensor.malloc18, i32 0, i32 1
  %tensor.dims26 = load ptr, ptr %tensor.dims.ptr25, align 8
  %tensor.data.ptr27 = getelementptr inbounds %csec.tensor, ptr %tensor.malloc18, i32 0, i32 3
  %tensor.data28 = load ptr, ptr %tensor.data.ptr27, align 8
  %1 = getelementptr i64, ptr %tensor.dims6, i64 1
  %tensor.slice.dim29 = load i64, ptr %1, align 4
  %tensor.slice.span30 = sub i64 %tensor.slice.dim29, 0
  %2 = add i64 %tensor.slice.span30, 0
  %tensor.slice.len31 = udiv i64 %2, 1
  %tensor.slice.dst.dim32 = getelementptr i64, ptr %tensor.dims26, i64 0
  store i64 %tensor.slice.len31, ptr %tensor.slice.dst.dim32, align 4
  %tensor.slice.src.coords = alloca i64, i64 %tensor.rank, align 8
  %tensor.slice.copy.i = alloca i64, align 8
  store i64 0, ptr %tensor.slice.copy.i, align 4
  br label %tensor.slice.copy.cond

tensor.slice.copy.cond:                           ; preds = %tensor.linear.end, %tensor.fill.end
  %tensor.slice.copy.idx = load i64, ptr %tensor.slice.copy.i, align 4
  %tensor.slice.copy.keep = icmp ult i64 %tensor.slice.copy.idx, %tensor.slice.total
  br i1 %tensor.slice.copy.keep, label %tensor.slice.copy.body, label %tensor.slice.copy.end

tensor.slice.copy.body:                           ; preds = %tensor.slice.copy.cond
  %tensor.slice.remaining.ptr = alloca i64, align 8
  store i64 %tensor.slice.copy.idx, ptr %tensor.slice.remaining.ptr, align 4
  %tensor.slice.len.ptr = getelementptr i64, ptr %tensor.dims26, i64 0
  %tensor.slice.len33 = load i64, ptr %tensor.slice.len.ptr, align 4
  %tensor.slice.remaining = load i64, ptr %tensor.slice.remaining.ptr, align 4
  %tensor.slice.local = urem i64 %tensor.slice.remaining, %tensor.slice.len33
  %tensor.slice.next.remaining = udiv i64 %tensor.slice.remaining, %tensor.slice.len33
  store i64 %tensor.slice.next.remaining, ptr %tensor.slice.remaining.ptr, align 4
  %tensor.slice.offset = mul i64 %tensor.slice.local, 1
  %tensor.slice.src.coord = add i64 0, %tensor.slice.offset
  %tensor.slice.src.coord.slot = getelementptr i64, ptr %tensor.slice.src.coords, i64 1
  store i64 %tensor.slice.src.coord, ptr %tensor.slice.src.coord.slot, align 4
  %tensor.slice.src.coord.slot34 = getelementptr i64, ptr %tensor.slice.src.coords, i64 0
  store i64 1, ptr %tensor.slice.src.coord.slot34, align 4
  %tensor.linear.ptr = alloca i64, align 8
  store i64 0, ptr %tensor.linear.ptr, align 4
  %tensor.linear.i = alloca i64, align 8
  store i64 0, ptr %tensor.linear.i, align 4
  br label %tensor.linear.cond

tensor.slice.copy.end:                            ; preds = %tensor.slice.copy.cond
  %row = alloca ptr, align 8
  store ptr %tensor.malloc18, ptr %row, align 8
  %tensor.rank.ptr37 = getelementptr inbounds %csec.tensor, ptr %tensor.malloc, i32 0, i32 0
  %tensor.rank38 = load i64, ptr %tensor.rank.ptr37, align 4
  %tensor.dims.ptr39 = getelementptr inbounds %csec.tensor, ptr %tensor.malloc, i32 0, i32 1
  %tensor.dims40 = load ptr, ptr %tensor.dims.ptr39, align 8
  %tensor.data.ptr41 = getelementptr inbounds %csec.tensor, ptr %tensor.malloc, i32 0, i32 3
  %tensor.data42 = load ptr, ptr %tensor.data.ptr41, align 8
  %tensor.malloc43 = call ptr @malloc(i64 32)
  %tensor.malloc44 = call ptr @malloc(i64 16)
  %tensor.malloc45 = call ptr @malloc(i64 8)
  %tensor.rank.slot46 = getelementptr inbounds %csec.tensor, ptr %tensor.malloc43, i32 0, i32 0
  store i64 2, ptr %tensor.rank.slot46, align 4
  %tensor.dims.slot47 = getelementptr inbounds %csec.tensor, ptr %tensor.malloc43, i32 0, i32 1
  store ptr %tensor.malloc44, ptr %tensor.dims.slot47, align 8
  %tensor.count.slot48 = getelementptr inbounds %csec.tensor, ptr %tensor.malloc43, i32 0, i32 2
  store i64 1, ptr %tensor.count.slot48, align 4
  %tensor.data.slot49 = getelementptr inbounds %csec.tensor, ptr %tensor.malloc43, i32 0, i32 3
  store ptr %tensor.malloc45, ptr %tensor.data.slot49, align 8
  %tensor.dims.ptr50 = getelementptr inbounds %csec.tensor, ptr %tensor.malloc43, i32 0, i32 1
  %tensor.dims51 = load ptr, ptr %tensor.dims.ptr50, align 8
  %tensor.slice.count.ptr52 = alloca i64, align 8
  store i64 1, ptr %tensor.slice.count.ptr52, align 4
  %tensor.slice.dim.ptr53 = getelementptr i64, ptr %tensor.dims40, i64 0
  %tensor.slice.dim54 = load i64, ptr %tensor.slice.dim.ptr53, align 4
  %tensor.slice.span55 = sub i64 %tensor.slice.dim54, 0
  %3 = add i64 %tensor.slice.span55, 0
  %tensor.slice.len56 = udiv i64 %3, 1
  %tensor.slice.dst.dim57 = getelementptr i64, ptr %tensor.dims51, i64 0
  store i64 %tensor.slice.len56, ptr %tensor.slice.dst.dim57, align 4
  %tensor.slice.count58 = load i64, ptr %tensor.slice.count.ptr52, align 4
  %tensor.slice.next.count59 = mul i64 %tensor.slice.count58, %tensor.slice.len56
  store i64 %tensor.slice.next.count59, ptr %tensor.slice.count.ptr52, align 4
  %tensor.slice.dim.ptr60 = getelementptr i64, ptr %tensor.dims40, i64 1
  %tensor.slice.dim61 = load i64, ptr %tensor.slice.dim.ptr60, align 4
  %tensor.slice.dst.dim62 = getelementptr i64, ptr %tensor.dims51, i64 1
  store i64 2, ptr %tensor.slice.dst.dim62, align 4
  %tensor.slice.count63 = load i64, ptr %tensor.slice.count.ptr52, align 4
  %tensor.slice.next.count64 = mul i64 %tensor.slice.count63, 2
  store i64 %tensor.slice.next.count64, ptr %tensor.slice.count.ptr52, align 4
  %tensor.slice.total65 = load i64, ptr %tensor.slice.count.ptr52, align 4
  %tensor.malloc66 = call ptr @malloc(i64 32)
  %tensor.malloc67 = call ptr @malloc(i64 16)
  %tensor.data.bytes68 = mul i64 %tensor.slice.total65, 8
  %tensor.malloc69 = call ptr @malloc(i64 %tensor.data.bytes68)
  %tensor.rank.slot70 = getelementptr inbounds %csec.tensor, ptr %tensor.malloc66, i32 0, i32 0
  store i64 2, ptr %tensor.rank.slot70, align 4
  %tensor.dims.slot71 = getelementptr inbounds %csec.tensor, ptr %tensor.malloc66, i32 0, i32 1
  store ptr %tensor.malloc67, ptr %tensor.dims.slot71, align 8
  %tensor.count.slot72 = getelementptr inbounds %csec.tensor, ptr %tensor.malloc66, i32 0, i32 2
  store i64 %tensor.slice.total65, ptr %tensor.count.slot72, align 4
  %tensor.data.slot73 = getelementptr inbounds %csec.tensor, ptr %tensor.malloc66, i32 0, i32 3
  store ptr %tensor.malloc69, ptr %tensor.data.slot73, align 8
  %tensor.dims.ptr74 = getelementptr inbounds %csec.tensor, ptr %tensor.malloc66, i32 0, i32 1
  %tensor.dims75 = load ptr, ptr %tensor.dims.ptr74, align 8
  %tensor.data.ptr76 = getelementptr inbounds %csec.tensor, ptr %tensor.malloc66, i32 0, i32 3
  %tensor.data77 = load ptr, ptr %tensor.data.ptr76, align 8
  %4 = getelementptr i64, ptr %tensor.dims40, i64 0
  %tensor.slice.dim78 = load i64, ptr %4, align 4
  %tensor.slice.span79 = sub i64 %tensor.slice.dim78, 0
  %5 = add i64 %tensor.slice.span79, 0
  %tensor.slice.len80 = udiv i64 %5, 1
  %tensor.slice.dst.dim81 = getelementptr i64, ptr %tensor.dims75, i64 0
  store i64 %tensor.slice.len80, ptr %tensor.slice.dst.dim81, align 4
  %6 = getelementptr i64, ptr %tensor.dims40, i64 1
  %tensor.slice.dim82 = load i64, ptr %6, align 4
  %tensor.slice.dst.dim83 = getelementptr i64, ptr %tensor.dims75, i64 1
  store i64 2, ptr %tensor.slice.dst.dim83, align 4
  %tensor.slice.src.coords84 = alloca i64, i64 %tensor.rank38, align 8
  %tensor.slice.copy.i85 = alloca i64, align 8
  store i64 0, ptr %tensor.slice.copy.i85, align 4
  br label %tensor.slice.copy.cond86

tensor.linear.cond:                               ; preds = %tensor.linear.body, %tensor.slice.copy.body
  %tensor.linear.idx = load i64, ptr %tensor.linear.i, align 4
  %tensor.linear.keep = icmp ult i64 %tensor.linear.idx, %tensor.rank
  br i1 %tensor.linear.keep, label %tensor.linear.body, label %tensor.linear.end

tensor.linear.body:                               ; preds = %tensor.linear.cond
  %tensor.linear.dim.ptr = getelementptr i64, ptr %tensor.dims6, i64 %tensor.linear.idx
  %tensor.linear.dim = load i64, ptr %tensor.linear.dim.ptr, align 4
  %tensor.linear.coord.ptr = getelementptr i64, ptr %tensor.slice.src.coords, i64 %tensor.linear.idx
  %tensor.linear.coord = load i64, ptr %tensor.linear.coord.ptr, align 4
  %tensor.linear.current = load i64, ptr %tensor.linear.ptr, align 4
  %tensor.linear.mul = mul i64 %tensor.linear.current, %tensor.linear.dim
  %tensor.linear.next = add i64 %tensor.linear.mul, %tensor.linear.coord
  store i64 %tensor.linear.next, ptr %tensor.linear.ptr, align 4
  %tensor.linear.current35 = load i64, ptr %tensor.linear.i, align 4
  %tensor.linear.next36 = add i64 %tensor.linear.current35, 1
  store i64 %tensor.linear.next36, ptr %tensor.linear.i, align 4
  br label %tensor.linear.cond

tensor.linear.end:                                ; preds = %tensor.linear.cond
  %tensor.linear.result = load i64, ptr %tensor.linear.ptr, align 4
  %tensor.slice.src = getelementptr double, ptr %tensor.data8, i64 %tensor.linear.result
  %tensor.slice.value = load double, ptr %tensor.slice.src, align 8
  %tensor.slice.dst = getelementptr double, ptr %tensor.data28, i64 %tensor.slice.copy.idx
  store double %tensor.slice.value, ptr %tensor.slice.dst, align 8
  %tensor.slice.copy.current = load i64, ptr %tensor.slice.copy.i, align 4
  %tensor.slice.copy.next = add i64 %tensor.slice.copy.current, 1
  store i64 %tensor.slice.copy.next, ptr %tensor.slice.copy.i, align 4
  br label %tensor.slice.copy.cond

tensor.slice.copy.cond86:                         ; preds = %tensor.linear.end112, %tensor.slice.copy.end
  %tensor.slice.copy.idx89 = load i64, ptr %tensor.slice.copy.i85, align 4
  %tensor.slice.copy.keep90 = icmp ult i64 %tensor.slice.copy.idx89, %tensor.slice.total65
  br i1 %tensor.slice.copy.keep90, label %tensor.slice.copy.body87, label %tensor.slice.copy.end88

tensor.slice.copy.body87:                         ; preds = %tensor.slice.copy.cond86
  %tensor.slice.remaining.ptr91 = alloca i64, align 8
  store i64 %tensor.slice.copy.idx89, ptr %tensor.slice.remaining.ptr91, align 4
  %tensor.slice.len.ptr92 = getelementptr i64, ptr %tensor.dims75, i64 1
  %tensor.slice.len93 = load i64, ptr %tensor.slice.len.ptr92, align 4
  %tensor.slice.remaining94 = load i64, ptr %tensor.slice.remaining.ptr91, align 4
  %tensor.slice.local95 = urem i64 %tensor.slice.remaining94, %tensor.slice.len93
  %tensor.slice.next.remaining96 = udiv i64 %tensor.slice.remaining94, %tensor.slice.len93
  store i64 %tensor.slice.next.remaining96, ptr %tensor.slice.remaining.ptr91, align 4
  %tensor.slice.offset97 = mul i64 %tensor.slice.local95, 1
  %tensor.slice.src.coord98 = add i64 1, %tensor.slice.offset97
  %tensor.slice.src.coord.slot99 = getelementptr i64, ptr %tensor.slice.src.coords84, i64 1
  store i64 %tensor.slice.src.coord98, ptr %tensor.slice.src.coord.slot99, align 4
  %tensor.slice.len.ptr100 = getelementptr i64, ptr %tensor.dims75, i64 0
  %tensor.slice.len101 = load i64, ptr %tensor.slice.len.ptr100, align 4
  %tensor.slice.remaining102 = load i64, ptr %tensor.slice.remaining.ptr91, align 4
  %tensor.slice.local103 = urem i64 %tensor.slice.remaining102, %tensor.slice.len101
  %tensor.slice.next.remaining104 = udiv i64 %tensor.slice.remaining102, %tensor.slice.len101
  store i64 %tensor.slice.next.remaining104, ptr %tensor.slice.remaining.ptr91, align 4
  %tensor.slice.offset105 = mul i64 %tensor.slice.local103, 1
  %tensor.slice.src.coord106 = add i64 0, %tensor.slice.offset105
  %tensor.slice.src.coord.slot107 = getelementptr i64, ptr %tensor.slice.src.coords84, i64 0
  store i64 %tensor.slice.src.coord106, ptr %tensor.slice.src.coord.slot107, align 4
  %tensor.linear.ptr108 = alloca i64, align 8
  store i64 0, ptr %tensor.linear.ptr108, align 4
  %tensor.linear.i109 = alloca i64, align 8
  store i64 0, ptr %tensor.linear.i109, align 4
  br label %tensor.linear.cond110

tensor.slice.copy.end88:                          ; preds = %tensor.slice.copy.cond86
  %columns = alloca ptr, align 8
  store ptr %tensor.malloc66, ptr %columns, align 8
  %tensor.rank.ptr130 = getelementptr inbounds %csec.tensor, ptr %tensor.malloc, i32 0, i32 0
  %tensor.rank131 = load i64, ptr %tensor.rank.ptr130, align 4
  %tensor.dims.ptr132 = getelementptr inbounds %csec.tensor, ptr %tensor.malloc, i32 0, i32 1
  %tensor.dims133 = load ptr, ptr %tensor.dims.ptr132, align 8
  %tensor.data.ptr134 = getelementptr inbounds %csec.tensor, ptr %tensor.malloc, i32 0, i32 3
  %tensor.data135 = load ptr, ptr %tensor.data.ptr134, align 8
  %tensor.malloc136 = call ptr @malloc(i64 32)
  %tensor.malloc137 = call ptr @malloc(i64 16)
  %tensor.malloc138 = call ptr @malloc(i64 8)
  %tensor.rank.slot139 = getelementptr inbounds %csec.tensor, ptr %tensor.malloc136, i32 0, i32 0
  store i64 2, ptr %tensor.rank.slot139, align 4
  %tensor.dims.slot140 = getelementptr inbounds %csec.tensor, ptr %tensor.malloc136, i32 0, i32 1
  store ptr %tensor.malloc137, ptr %tensor.dims.slot140, align 8
  %tensor.count.slot141 = getelementptr inbounds %csec.tensor, ptr %tensor.malloc136, i32 0, i32 2
  store i64 1, ptr %tensor.count.slot141, align 4
  %tensor.data.slot142 = getelementptr inbounds %csec.tensor, ptr %tensor.malloc136, i32 0, i32 3
  store ptr %tensor.malloc138, ptr %tensor.data.slot142, align 8
  %tensor.dims.ptr143 = getelementptr inbounds %csec.tensor, ptr %tensor.malloc136, i32 0, i32 1
  %tensor.dims144 = load ptr, ptr %tensor.dims.ptr143, align 8
  %tensor.slice.count.ptr145 = alloca i64, align 8
  store i64 1, ptr %tensor.slice.count.ptr145, align 4
  %tensor.slice.dim.ptr146 = getelementptr i64, ptr %tensor.dims133, i64 0
  %tensor.slice.dim147 = load i64, ptr %tensor.slice.dim.ptr146, align 4
  %tensor.slice.span148 = sub i64 %tensor.slice.dim147, 0
  %7 = add i64 %tensor.slice.span148, 1
  %tensor.slice.len149 = udiv i64 %7, 2
  %tensor.slice.dst.dim150 = getelementptr i64, ptr %tensor.dims144, i64 0
  store i64 %tensor.slice.len149, ptr %tensor.slice.dst.dim150, align 4
  %tensor.slice.count151 = load i64, ptr %tensor.slice.count.ptr145, align 4
  %tensor.slice.next.count152 = mul i64 %tensor.slice.count151, %tensor.slice.len149
  store i64 %tensor.slice.next.count152, ptr %tensor.slice.count.ptr145, align 4
  %tensor.slice.dim.ptr153 = getelementptr i64, ptr %tensor.dims133, i64 1
  %tensor.slice.dim154 = load i64, ptr %tensor.slice.dim.ptr153, align 4
  %tensor.slice.dst.dim155 = getelementptr i64, ptr %tensor.dims144, i64 1
  store i64 2, ptr %tensor.slice.dst.dim155, align 4
  %tensor.slice.count156 = load i64, ptr %tensor.slice.count.ptr145, align 4
  %tensor.slice.next.count157 = mul i64 %tensor.slice.count156, 2
  store i64 %tensor.slice.next.count157, ptr %tensor.slice.count.ptr145, align 4
  %tensor.slice.total158 = load i64, ptr %tensor.slice.count.ptr145, align 4
  %tensor.malloc159 = call ptr @malloc(i64 32)
  %tensor.malloc160 = call ptr @malloc(i64 16)
  %tensor.data.bytes161 = mul i64 %tensor.slice.total158, 8
  %tensor.malloc162 = call ptr @malloc(i64 %tensor.data.bytes161)
  %tensor.rank.slot163 = getelementptr inbounds %csec.tensor, ptr %tensor.malloc159, i32 0, i32 0
  store i64 2, ptr %tensor.rank.slot163, align 4
  %tensor.dims.slot164 = getelementptr inbounds %csec.tensor, ptr %tensor.malloc159, i32 0, i32 1
  store ptr %tensor.malloc160, ptr %tensor.dims.slot164, align 8
  %tensor.count.slot165 = getelementptr inbounds %csec.tensor, ptr %tensor.malloc159, i32 0, i32 2
  store i64 %tensor.slice.total158, ptr %tensor.count.slot165, align 4
  %tensor.data.slot166 = getelementptr inbounds %csec.tensor, ptr %tensor.malloc159, i32 0, i32 3
  store ptr %tensor.malloc162, ptr %tensor.data.slot166, align 8
  %tensor.dims.ptr167 = getelementptr inbounds %csec.tensor, ptr %tensor.malloc159, i32 0, i32 1
  %tensor.dims168 = load ptr, ptr %tensor.dims.ptr167, align 8
  %tensor.data.ptr169 = getelementptr inbounds %csec.tensor, ptr %tensor.malloc159, i32 0, i32 3
  %tensor.data170 = load ptr, ptr %tensor.data.ptr169, align 8
  %8 = getelementptr i64, ptr %tensor.dims133, i64 0
  %tensor.slice.dim171 = load i64, ptr %8, align 4
  %tensor.slice.span172 = sub i64 %tensor.slice.dim171, 0
  %9 = add i64 %tensor.slice.span172, 1
  %tensor.slice.len173 = udiv i64 %9, 2
  %tensor.slice.dst.dim174 = getelementptr i64, ptr %tensor.dims168, i64 0
  store i64 %tensor.slice.len173, ptr %tensor.slice.dst.dim174, align 4
  %10 = getelementptr i64, ptr %tensor.dims133, i64 1
  %tensor.slice.dim175 = load i64, ptr %10, align 4
  %tensor.slice.dst.dim176 = getelementptr i64, ptr %tensor.dims168, i64 1
  store i64 2, ptr %tensor.slice.dst.dim176, align 4
  %tensor.slice.src.coords177 = alloca i64, i64 %tensor.rank131, align 8
  %tensor.slice.copy.i178 = alloca i64, align 8
  store i64 0, ptr %tensor.slice.copy.i178, align 4
  br label %tensor.slice.copy.cond179

tensor.linear.cond110:                            ; preds = %tensor.linear.body111, %tensor.slice.copy.body87
  %tensor.linear.idx113 = load i64, ptr %tensor.linear.i109, align 4
  %tensor.linear.keep114 = icmp ult i64 %tensor.linear.idx113, %tensor.rank38
  br i1 %tensor.linear.keep114, label %tensor.linear.body111, label %tensor.linear.end112

tensor.linear.body111:                            ; preds = %tensor.linear.cond110
  %tensor.linear.dim.ptr115 = getelementptr i64, ptr %tensor.dims40, i64 %tensor.linear.idx113
  %tensor.linear.dim116 = load i64, ptr %tensor.linear.dim.ptr115, align 4
  %tensor.linear.coord.ptr117 = getelementptr i64, ptr %tensor.slice.src.coords84, i64 %tensor.linear.idx113
  %tensor.linear.coord118 = load i64, ptr %tensor.linear.coord.ptr117, align 4
  %tensor.linear.current119 = load i64, ptr %tensor.linear.ptr108, align 4
  %tensor.linear.mul120 = mul i64 %tensor.linear.current119, %tensor.linear.dim116
  %tensor.linear.next121 = add i64 %tensor.linear.mul120, %tensor.linear.coord118
  store i64 %tensor.linear.next121, ptr %tensor.linear.ptr108, align 4
  %tensor.linear.current122 = load i64, ptr %tensor.linear.i109, align 4
  %tensor.linear.next123 = add i64 %tensor.linear.current122, 1
  store i64 %tensor.linear.next123, ptr %tensor.linear.i109, align 4
  br label %tensor.linear.cond110

tensor.linear.end112:                             ; preds = %tensor.linear.cond110
  %tensor.linear.result124 = load i64, ptr %tensor.linear.ptr108, align 4
  %tensor.slice.src125 = getelementptr double, ptr %tensor.data42, i64 %tensor.linear.result124
  %tensor.slice.value126 = load double, ptr %tensor.slice.src125, align 8
  %tensor.slice.dst127 = getelementptr double, ptr %tensor.data77, i64 %tensor.slice.copy.idx89
  store double %tensor.slice.value126, ptr %tensor.slice.dst127, align 8
  %tensor.slice.copy.current128 = load i64, ptr %tensor.slice.copy.i85, align 4
  %tensor.slice.copy.next129 = add i64 %tensor.slice.copy.current128, 1
  store i64 %tensor.slice.copy.next129, ptr %tensor.slice.copy.i85, align 4
  br label %tensor.slice.copy.cond86

tensor.slice.copy.cond179:                        ; preds = %tensor.linear.end205, %tensor.slice.copy.end88
  %tensor.slice.copy.idx182 = load i64, ptr %tensor.slice.copy.i178, align 4
  %tensor.slice.copy.keep183 = icmp ult i64 %tensor.slice.copy.idx182, %tensor.slice.total158
  br i1 %tensor.slice.copy.keep183, label %tensor.slice.copy.body180, label %tensor.slice.copy.end181

tensor.slice.copy.body180:                        ; preds = %tensor.slice.copy.cond179
  %tensor.slice.remaining.ptr184 = alloca i64, align 8
  store i64 %tensor.slice.copy.idx182, ptr %tensor.slice.remaining.ptr184, align 4
  %tensor.slice.len.ptr185 = getelementptr i64, ptr %tensor.dims168, i64 1
  %tensor.slice.len186 = load i64, ptr %tensor.slice.len.ptr185, align 4
  %tensor.slice.remaining187 = load i64, ptr %tensor.slice.remaining.ptr184, align 4
  %tensor.slice.local188 = urem i64 %tensor.slice.remaining187, %tensor.slice.len186
  %tensor.slice.next.remaining189 = udiv i64 %tensor.slice.remaining187, %tensor.slice.len186
  store i64 %tensor.slice.next.remaining189, ptr %tensor.slice.remaining.ptr184, align 4
  %tensor.slice.offset190 = mul i64 %tensor.slice.local188, 2
  %tensor.slice.src.coord191 = add i64 0, %tensor.slice.offset190
  %tensor.slice.src.coord.slot192 = getelementptr i64, ptr %tensor.slice.src.coords177, i64 1
  store i64 %tensor.slice.src.coord191, ptr %tensor.slice.src.coord.slot192, align 4
  %tensor.slice.len.ptr193 = getelementptr i64, ptr %tensor.dims168, i64 0
  %tensor.slice.len194 = load i64, ptr %tensor.slice.len.ptr193, align 4
  %tensor.slice.remaining195 = load i64, ptr %tensor.slice.remaining.ptr184, align 4
  %tensor.slice.local196 = urem i64 %tensor.slice.remaining195, %tensor.slice.len194
  %tensor.slice.next.remaining197 = udiv i64 %tensor.slice.remaining195, %tensor.slice.len194
  store i64 %tensor.slice.next.remaining197, ptr %tensor.slice.remaining.ptr184, align 4
  %tensor.slice.offset198 = mul i64 %tensor.slice.local196, 2
  %tensor.slice.src.coord199 = add i64 0, %tensor.slice.offset198
  %tensor.slice.src.coord.slot200 = getelementptr i64, ptr %tensor.slice.src.coords177, i64 0
  store i64 %tensor.slice.src.coord199, ptr %tensor.slice.src.coord.slot200, align 4
  %tensor.linear.ptr201 = alloca i64, align 8
  store i64 0, ptr %tensor.linear.ptr201, align 4
  %tensor.linear.i202 = alloca i64, align 8
  store i64 0, ptr %tensor.linear.i202, align 4
  br label %tensor.linear.cond203

tensor.slice.copy.end181:                         ; preds = %tensor.slice.copy.cond179
  %stepped = alloca ptr, align 8
  store ptr %tensor.malloc159, ptr %stepped, align 8
  %tensor.rank.ptr223 = getelementptr inbounds %csec.tensor, ptr %tensor.malloc, i32 0, i32 0
  %tensor.rank224 = load i64, ptr %tensor.rank.ptr223, align 4
  %tensor.dims.ptr225 = getelementptr inbounds %csec.tensor, ptr %tensor.malloc, i32 0, i32 1
  %tensor.dims226 = load ptr, ptr %tensor.dims.ptr225, align 8
  %tensor.data.ptr227 = getelementptr inbounds %csec.tensor, ptr %tensor.malloc, i32 0, i32 3
  %tensor.data228 = load ptr, ptr %tensor.data.ptr227, align 8
  %tensor.malloc229 = call ptr @malloc(i64 32)
  %tensor.malloc230 = call ptr @malloc(i64 16)
  %tensor.malloc231 = call ptr @malloc(i64 8)
  %tensor.rank.slot232 = getelementptr inbounds %csec.tensor, ptr %tensor.malloc229, i32 0, i32 0
  store i64 2, ptr %tensor.rank.slot232, align 4
  %tensor.dims.slot233 = getelementptr inbounds %csec.tensor, ptr %tensor.malloc229, i32 0, i32 1
  store ptr %tensor.malloc230, ptr %tensor.dims.slot233, align 8
  %tensor.count.slot234 = getelementptr inbounds %csec.tensor, ptr %tensor.malloc229, i32 0, i32 2
  store i64 1, ptr %tensor.count.slot234, align 4
  %tensor.data.slot235 = getelementptr inbounds %csec.tensor, ptr %tensor.malloc229, i32 0, i32 3
  store ptr %tensor.malloc231, ptr %tensor.data.slot235, align 8
  %tensor.dims.ptr236 = getelementptr inbounds %csec.tensor, ptr %tensor.malloc229, i32 0, i32 1
  %tensor.dims237 = load ptr, ptr %tensor.dims.ptr236, align 8
  %tensor.slice.count.ptr238 = alloca i64, align 8
  store i64 1, ptr %tensor.slice.count.ptr238, align 4
  %tensor.slice.dim.ptr239 = getelementptr i64, ptr %tensor.dims226, i64 0
  %tensor.slice.dim240 = load i64, ptr %tensor.slice.dim.ptr239, align 4
  %tensor.slice.span241 = sub i64 %tensor.slice.dim240, 1
  %11 = add i64 %tensor.slice.span241, 0
  %tensor.slice.len242 = udiv i64 %11, 1
  %tensor.slice.dst.dim243 = getelementptr i64, ptr %tensor.dims237, i64 0
  store i64 %tensor.slice.len242, ptr %tensor.slice.dst.dim243, align 4
  %tensor.slice.count244 = load i64, ptr %tensor.slice.count.ptr238, align 4
  %tensor.slice.next.count245 = mul i64 %tensor.slice.count244, %tensor.slice.len242
  store i64 %tensor.slice.next.count245, ptr %tensor.slice.count.ptr238, align 4
  %tensor.slice.dim.ptr246 = getelementptr i64, ptr %tensor.dims226, i64 1
  %tensor.slice.dim247 = load i64, ptr %tensor.slice.dim.ptr246, align 4
  %tensor.slice.span248 = sub i64 %tensor.slice.dim247, 0
  %12 = add i64 %tensor.slice.span248, 0
  %tensor.slice.len249 = udiv i64 %12, 1
  %tensor.slice.dst.dim250 = getelementptr i64, ptr %tensor.dims237, i64 1
  store i64 %tensor.slice.len249, ptr %tensor.slice.dst.dim250, align 4
  %tensor.slice.count251 = load i64, ptr %tensor.slice.count.ptr238, align 4
  %tensor.slice.next.count252 = mul i64 %tensor.slice.count251, %tensor.slice.len249
  store i64 %tensor.slice.next.count252, ptr %tensor.slice.count.ptr238, align 4
  %tensor.slice.total253 = load i64, ptr %tensor.slice.count.ptr238, align 4
  %tensor.malloc254 = call ptr @malloc(i64 32)
  %tensor.malloc255 = call ptr @malloc(i64 16)
  %tensor.data.bytes256 = mul i64 %tensor.slice.total253, 8
  %tensor.malloc257 = call ptr @malloc(i64 %tensor.data.bytes256)
  %tensor.rank.slot258 = getelementptr inbounds %csec.tensor, ptr %tensor.malloc254, i32 0, i32 0
  store i64 2, ptr %tensor.rank.slot258, align 4
  %tensor.dims.slot259 = getelementptr inbounds %csec.tensor, ptr %tensor.malloc254, i32 0, i32 1
  store ptr %tensor.malloc255, ptr %tensor.dims.slot259, align 8
  %tensor.count.slot260 = getelementptr inbounds %csec.tensor, ptr %tensor.malloc254, i32 0, i32 2
  store i64 %tensor.slice.total253, ptr %tensor.count.slot260, align 4
  %tensor.data.slot261 = getelementptr inbounds %csec.tensor, ptr %tensor.malloc254, i32 0, i32 3
  store ptr %tensor.malloc257, ptr %tensor.data.slot261, align 8
  %tensor.dims.ptr262 = getelementptr inbounds %csec.tensor, ptr %tensor.malloc254, i32 0, i32 1
  %tensor.dims263 = load ptr, ptr %tensor.dims.ptr262, align 8
  %tensor.data.ptr264 = getelementptr inbounds %csec.tensor, ptr %tensor.malloc254, i32 0, i32 3
  %tensor.data265 = load ptr, ptr %tensor.data.ptr264, align 8
  %13 = getelementptr i64, ptr %tensor.dims226, i64 0
  %tensor.slice.dim266 = load i64, ptr %13, align 4
  %tensor.slice.span267 = sub i64 %tensor.slice.dim266, 1
  %14 = add i64 %tensor.slice.span267, 0
  %tensor.slice.len268 = udiv i64 %14, 1
  %tensor.slice.dst.dim269 = getelementptr i64, ptr %tensor.dims263, i64 0
  store i64 %tensor.slice.len268, ptr %tensor.slice.dst.dim269, align 4
  %15 = getelementptr i64, ptr %tensor.dims226, i64 1
  %tensor.slice.dim270 = load i64, ptr %15, align 4
  %tensor.slice.span271 = sub i64 %tensor.slice.dim270, 0
  %16 = add i64 %tensor.slice.span271, 0
  %tensor.slice.len272 = udiv i64 %16, 1
  %tensor.slice.dst.dim273 = getelementptr i64, ptr %tensor.dims263, i64 1
  store i64 %tensor.slice.len272, ptr %tensor.slice.dst.dim273, align 4
  %tensor.slice.src.coords274 = alloca i64, i64 %tensor.rank224, align 8
  %tensor.slice.copy.i275 = alloca i64, align 8
  store i64 0, ptr %tensor.slice.copy.i275, align 4
  br label %tensor.slice.copy.cond276

tensor.linear.cond203:                            ; preds = %tensor.linear.body204, %tensor.slice.copy.body180
  %tensor.linear.idx206 = load i64, ptr %tensor.linear.i202, align 4
  %tensor.linear.keep207 = icmp ult i64 %tensor.linear.idx206, %tensor.rank131
  br i1 %tensor.linear.keep207, label %tensor.linear.body204, label %tensor.linear.end205

tensor.linear.body204:                            ; preds = %tensor.linear.cond203
  %tensor.linear.dim.ptr208 = getelementptr i64, ptr %tensor.dims133, i64 %tensor.linear.idx206
  %tensor.linear.dim209 = load i64, ptr %tensor.linear.dim.ptr208, align 4
  %tensor.linear.coord.ptr210 = getelementptr i64, ptr %tensor.slice.src.coords177, i64 %tensor.linear.idx206
  %tensor.linear.coord211 = load i64, ptr %tensor.linear.coord.ptr210, align 4
  %tensor.linear.current212 = load i64, ptr %tensor.linear.ptr201, align 4
  %tensor.linear.mul213 = mul i64 %tensor.linear.current212, %tensor.linear.dim209
  %tensor.linear.next214 = add i64 %tensor.linear.mul213, %tensor.linear.coord211
  store i64 %tensor.linear.next214, ptr %tensor.linear.ptr201, align 4
  %tensor.linear.current215 = load i64, ptr %tensor.linear.i202, align 4
  %tensor.linear.next216 = add i64 %tensor.linear.current215, 1
  store i64 %tensor.linear.next216, ptr %tensor.linear.i202, align 4
  br label %tensor.linear.cond203

tensor.linear.end205:                             ; preds = %tensor.linear.cond203
  %tensor.linear.result217 = load i64, ptr %tensor.linear.ptr201, align 4
  %tensor.slice.src218 = getelementptr double, ptr %tensor.data135, i64 %tensor.linear.result217
  %tensor.slice.value219 = load double, ptr %tensor.slice.src218, align 8
  %tensor.slice.dst220 = getelementptr double, ptr %tensor.data170, i64 %tensor.slice.copy.idx182
  store double %tensor.slice.value219, ptr %tensor.slice.dst220, align 8
  %tensor.slice.copy.current221 = load i64, ptr %tensor.slice.copy.i178, align 4
  %tensor.slice.copy.next222 = add i64 %tensor.slice.copy.current221, 1
  store i64 %tensor.slice.copy.next222, ptr %tensor.slice.copy.i178, align 4
  br label %tensor.slice.copy.cond179

tensor.slice.copy.cond276:                        ; preds = %tensor.linear.end302, %tensor.slice.copy.end181
  %tensor.slice.copy.idx279 = load i64, ptr %tensor.slice.copy.i275, align 4
  %tensor.slice.copy.keep280 = icmp ult i64 %tensor.slice.copy.idx279, %tensor.slice.total253
  br i1 %tensor.slice.copy.keep280, label %tensor.slice.copy.body277, label %tensor.slice.copy.end278

tensor.slice.copy.body277:                        ; preds = %tensor.slice.copy.cond276
  %tensor.slice.remaining.ptr281 = alloca i64, align 8
  store i64 %tensor.slice.copy.idx279, ptr %tensor.slice.remaining.ptr281, align 4
  %tensor.slice.len.ptr282 = getelementptr i64, ptr %tensor.dims263, i64 1
  %tensor.slice.len283 = load i64, ptr %tensor.slice.len.ptr282, align 4
  %tensor.slice.remaining284 = load i64, ptr %tensor.slice.remaining.ptr281, align 4
  %tensor.slice.local285 = urem i64 %tensor.slice.remaining284, %tensor.slice.len283
  %tensor.slice.next.remaining286 = udiv i64 %tensor.slice.remaining284, %tensor.slice.len283
  store i64 %tensor.slice.next.remaining286, ptr %tensor.slice.remaining.ptr281, align 4
  %tensor.slice.offset287 = mul i64 %tensor.slice.local285, 1
  %tensor.slice.src.coord288 = add i64 0, %tensor.slice.offset287
  %tensor.slice.src.coord.slot289 = getelementptr i64, ptr %tensor.slice.src.coords274, i64 1
  store i64 %tensor.slice.src.coord288, ptr %tensor.slice.src.coord.slot289, align 4
  %tensor.slice.len.ptr290 = getelementptr i64, ptr %tensor.dims263, i64 0
  %tensor.slice.len291 = load i64, ptr %tensor.slice.len.ptr290, align 4
  %tensor.slice.remaining292 = load i64, ptr %tensor.slice.remaining.ptr281, align 4
  %tensor.slice.local293 = urem i64 %tensor.slice.remaining292, %tensor.slice.len291
  %tensor.slice.next.remaining294 = udiv i64 %tensor.slice.remaining292, %tensor.slice.len291
  store i64 %tensor.slice.next.remaining294, ptr %tensor.slice.remaining.ptr281, align 4
  %tensor.slice.offset295 = mul i64 %tensor.slice.local293, 1
  %tensor.slice.src.coord296 = add i64 1, %tensor.slice.offset295
  %tensor.slice.src.coord.slot297 = getelementptr i64, ptr %tensor.slice.src.coords274, i64 0
  store i64 %tensor.slice.src.coord296, ptr %tensor.slice.src.coord.slot297, align 4
  %tensor.linear.ptr298 = alloca i64, align 8
  store i64 0, ptr %tensor.linear.ptr298, align 4
  %tensor.linear.i299 = alloca i64, align 8
  store i64 0, ptr %tensor.linear.i299, align 4
  br label %tensor.linear.cond300

tensor.slice.copy.end278:                         ; preds = %tensor.slice.copy.cond276
  %tail = alloca ptr, align 8
  store ptr %tensor.malloc254, ptr %tail, align 8
  ret i32 0

tensor.linear.cond300:                            ; preds = %tensor.linear.body301, %tensor.slice.copy.body277
  %tensor.linear.idx303 = load i64, ptr %tensor.linear.i299, align 4
  %tensor.linear.keep304 = icmp ult i64 %tensor.linear.idx303, %tensor.rank224
  br i1 %tensor.linear.keep304, label %tensor.linear.body301, label %tensor.linear.end302

tensor.linear.body301:                            ; preds = %tensor.linear.cond300
  %tensor.linear.dim.ptr305 = getelementptr i64, ptr %tensor.dims226, i64 %tensor.linear.idx303
  %tensor.linear.dim306 = load i64, ptr %tensor.linear.dim.ptr305, align 4
  %tensor.linear.coord.ptr307 = getelementptr i64, ptr %tensor.slice.src.coords274, i64 %tensor.linear.idx303
  %tensor.linear.coord308 = load i64, ptr %tensor.linear.coord.ptr307, align 4
  %tensor.linear.current309 = load i64, ptr %tensor.linear.ptr298, align 4
  %tensor.linear.mul310 = mul i64 %tensor.linear.current309, %tensor.linear.dim306
  %tensor.linear.next311 = add i64 %tensor.linear.mul310, %tensor.linear.coord308
  store i64 %tensor.linear.next311, ptr %tensor.linear.ptr298, align 4
  %tensor.linear.current312 = load i64, ptr %tensor.linear.i299, align 4
  %tensor.linear.next313 = add i64 %tensor.linear.current312, 1
  store i64 %tensor.linear.next313, ptr %tensor.linear.i299, align 4
  br label %tensor.linear.cond300

tensor.linear.end302:                             ; preds = %tensor.linear.cond300
  %tensor.linear.result314 = load i64, ptr %tensor.linear.ptr298, align 4
  %tensor.slice.src315 = getelementptr double, ptr %tensor.data228, i64 %tensor.linear.result314
  %tensor.slice.value316 = load double, ptr %tensor.slice.src315, align 8
  %tensor.slice.dst317 = getelementptr double, ptr %tensor.data265, i64 %tensor.slice.copy.idx279
  store double %tensor.slice.value316, ptr %tensor.slice.dst317, align 8
  %tensor.slice.copy.current318 = load i64, ptr %tensor.slice.copy.i275, align 4
  %tensor.slice.copy.next319 = add i64 %tensor.slice.copy.current318, 1
  store i64 %tensor.slice.copy.next319, ptr %tensor.slice.copy.i275, align 4
  br label %tensor.slice.copy.cond276
}

declare void @csec_set_command_line_args(i32, ptr)

define internal i32 @__csec_jit_entry() {
entry:
  %user.main = call i32 @_main()
  ret i32 %user.main
}
