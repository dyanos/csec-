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
  store double -2.000000e+00, ptr %tensor.data.slot4, align 8
  %tensor.fill.next = add i64 %tensor.fill.i.0, 1
  br label %tensor.fill.cond

tensor.fill.end:                                  ; preds = %tensor.fill.cond
  %tensor.rank.ptr = getelementptr inbounds %csec.tensor, ptr %tensor.malloc, i32 0, i32 0
  %tensor.rank = load i64, ptr %tensor.rank.ptr, align 4
  %tensor.count.ptr = getelementptr inbounds %csec.tensor, ptr %tensor.malloc, i32 0, i32 2
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
  %tensor.dims.ptr12 = getelementptr inbounds %csec.tensor, ptr %tensor.malloc, i32 0, i32 1
  %tensor.dims13 = load ptr, ptr %tensor.dims.ptr12, align 8
  %tensor.dims.ptr14 = getelementptr inbounds %csec.tensor, ptr %tensor.malloc5, i32 0, i32 1
  %tensor.dims15 = load ptr, ptr %tensor.dims.ptr14, align 8
  %tensor.data.ptr16 = getelementptr inbounds %csec.tensor, ptr %tensor.malloc, i32 0, i32 3
  %tensor.data17 = load ptr, ptr %tensor.data.ptr16, align 8
  %tensor.data.ptr18 = getelementptr inbounds %csec.tensor, ptr %tensor.malloc5, i32 0, i32 3
  %tensor.data19 = load ptr, ptr %tensor.data.ptr18, align 8
  %tensor.map.dims.i = alloca i64, align 8
  store i64 0, ptr %tensor.map.dims.i, align 4
  br label %tensor.map.dims.cond

tensor.map.dims.cond:                             ; preds = %tensor.map.dims.body, %tensor.fill.end
  %tensor.map.dims.idx = load i64, ptr %tensor.map.dims.i, align 4
  %tensor.map.dims.keep = icmp ult i64 %tensor.map.dims.idx, %tensor.rank
  br i1 %tensor.map.dims.keep, label %tensor.map.dims.body, label %tensor.map.dims.end

tensor.map.dims.body:                             ; preds = %tensor.map.dims.cond
  %tensor.map.src.dim = getelementptr i64, ptr %tensor.dims13, i64 %tensor.map.dims.idx
  %tensor.map.dst.dim = getelementptr i64, ptr %tensor.dims15, i64 %tensor.map.dims.idx
  %tensor.map.dim = load i64, ptr %tensor.map.src.dim, align 4
  store i64 %tensor.map.dim, ptr %tensor.map.dst.dim, align 4
  %tensor.map.dims.current = load i64, ptr %tensor.map.dims.i, align 4
  %tensor.map.dims.next = add i64 %tensor.map.dims.current, 1
  store i64 %tensor.map.dims.next, ptr %tensor.map.dims.i, align 4
  br label %tensor.map.dims.cond

tensor.map.dims.end:                              ; preds = %tensor.map.dims.cond
  %tensor.map.data.i = alloca i64, align 8
  store i64 0, ptr %tensor.map.data.i, align 4
  br label %tensor.map.data.cond

tensor.map.data.cond:                             ; preds = %tensor.map.data.body, %tensor.map.dims.end
  %tensor.map.data.idx = load i64, ptr %tensor.map.data.i, align 4
  %tensor.map.data.keep = icmp ult i64 %tensor.map.data.idx, %tensor.count
  br i1 %tensor.map.data.keep, label %tensor.map.data.body, label %tensor.map.data.end

tensor.map.data.body:                             ; preds = %tensor.map.data.cond
  %tensor.map.src = getelementptr double, ptr %tensor.data17, i64 %tensor.map.data.idx
  %tensor.map.value = load double, ptr %tensor.map.src, align 8
  %tensor.relu.gt0 = fcmp ogt double %tensor.map.value, 0.000000e+00
  %tensor.relu = select i1 %tensor.relu.gt0, double %tensor.map.value, double 0.000000e+00
  %tensor.map.dst = getelementptr double, ptr %tensor.data19, i64 %tensor.map.data.idx
  store double %tensor.relu, ptr %tensor.map.dst, align 8
  %tensor.map.data.current = load i64, ptr %tensor.map.data.i, align 4
  %tensor.map.data.next = add i64 %tensor.map.data.current, 1
  store i64 %tensor.map.data.next, ptr %tensor.map.data.i, align 4
  br label %tensor.map.data.cond

tensor.map.data.end:                              ; preds = %tensor.map.data.cond
  %zeros = alloca ptr, align 8
  store ptr %tensor.malloc5, ptr %zeros, align 8
  %zeros.load = load ptr, ptr %zeros, align 8
  %tensor.count.ptr20 = getelementptr inbounds %csec.tensor, ptr %zeros.load, i32 0, i32 2
  %tensor.count21 = load i64, ptr %tensor.count.ptr20, align 4
  %tensor.data.ptr22 = getelementptr inbounds %csec.tensor, ptr %zeros.load, i32 0, i32 3
  %tensor.data23 = load ptr, ptr %tensor.data.ptr22, align 8
  %tensor.sum.ptr = alloca double, align 8
  store double 0.000000e+00, ptr %tensor.sum.ptr, align 8
  %tensor.sum.i = alloca i64, align 8
  store i64 0, ptr %tensor.sum.i, align 4
  br label %tensor.sum.cond

tensor.sum.cond:                                  ; preds = %tensor.sum.body, %tensor.map.data.end
  %tensor.sum.idx = load i64, ptr %tensor.sum.i, align 4
  %tensor.sum.keep = icmp ult i64 %tensor.sum.idx, %tensor.count21
  br i1 %tensor.sum.keep, label %tensor.sum.body, label %tensor.sum.end

tensor.sum.body:                                  ; preds = %tensor.sum.cond
  %tensor.sum.slot = getelementptr double, ptr %tensor.data23, i64 %tensor.sum.idx
  %tensor.sum.value = load double, ptr %tensor.sum.slot, align 8
  %tensor.sum.current = load double, ptr %tensor.sum.ptr, align 8
  %tensor.sum.next = fadd double %tensor.sum.current, %tensor.sum.value
  store double %tensor.sum.next, ptr %tensor.sum.ptr, align 8
  %tensor.sum.current24 = load i64, ptr %tensor.sum.i, align 4
  %tensor.sum.next25 = add i64 %tensor.sum.current24, 1
  store i64 %tensor.sum.next25, ptr %tensor.sum.i, align 4
  br label %tensor.sum.cond

tensor.sum.end:                                   ; preds = %tensor.sum.cond
  %tensor.sum.result = load double, ptr %tensor.sum.ptr, align 8
  %zeroSum = alloca double, align 8
  store double %tensor.sum.result, ptr %zeroSum, align 8
  %tensor.malloc26 = call ptr @malloc(i64 32)
  %tensor.malloc27 = call ptr @malloc(i64 16)
  %tensor.malloc28 = call ptr @malloc(i64 32)
  %tensor.rank.slot29 = getelementptr inbounds %csec.tensor, ptr %tensor.malloc26, i32 0, i32 0
  store i64 2, ptr %tensor.rank.slot29, align 4
  %tensor.dims.slot30 = getelementptr inbounds %csec.tensor, ptr %tensor.malloc26, i32 0, i32 1
  store ptr %tensor.malloc27, ptr %tensor.dims.slot30, align 8
  %tensor.count.slot31 = getelementptr inbounds %csec.tensor, ptr %tensor.malloc26, i32 0, i32 2
  store i64 4, ptr %tensor.count.slot31, align 4
  %tensor.data.slot32 = getelementptr inbounds %csec.tensor, ptr %tensor.malloc26, i32 0, i32 3
  store ptr %tensor.malloc28, ptr %tensor.data.slot32, align 8
  %tensor.dims.ptr33 = getelementptr inbounds %csec.tensor, ptr %tensor.malloc26, i32 0, i32 1
  %tensor.dims34 = load ptr, ptr %tensor.dims.ptr33, align 8
  %tensor.data.ptr35 = getelementptr inbounds %csec.tensor, ptr %tensor.malloc26, i32 0, i32 3
  %tensor.data36 = load ptr, ptr %tensor.data.ptr35, align 8
  %tensor.dim.slot37 = getelementptr i64, ptr %tensor.dims34, i64 0
  store i64 1, ptr %tensor.dim.slot37, align 4
  %tensor.dim.slot38 = getelementptr i64, ptr %tensor.dims34, i64 1
  store i64 4, ptr %tensor.dim.slot38, align 4
  %tensor.fill.i39 = alloca i64, align 8
  store i64 0, ptr %tensor.fill.i39, align 4
  br label %tensor.fill.cond40

tensor.fill.cond40:                               ; preds = %tensor.fill.body41, %tensor.sum.end
  %tensor.fill.idx43 = load i64, ptr %tensor.fill.i39, align 4
  %tensor.fill.keep44 = icmp ult i64 %tensor.fill.idx43, 4
  br i1 %tensor.fill.keep44, label %tensor.fill.body41, label %tensor.fill.end42

tensor.fill.body41:                               ; preds = %tensor.fill.cond40
  %tensor.data.slot45 = getelementptr double, ptr %tensor.data36, i64 %tensor.fill.idx43
  store double 0.000000e+00, ptr %tensor.data.slot45, align 8
  %tensor.fill.current46 = load i64, ptr %tensor.fill.i39, align 4
  %tensor.fill.next47 = add i64 %tensor.fill.current46, 1
  store i64 %tensor.fill.next47, ptr %tensor.fill.i39, align 4
  br label %tensor.fill.cond40

tensor.fill.end42:                                ; preds = %tensor.fill.cond40
  %tensor.rank.ptr48 = getelementptr inbounds %csec.tensor, ptr %tensor.malloc26, i32 0, i32 0
  %tensor.rank49 = load i64, ptr %tensor.rank.ptr48, align 4
  %tensor.count.ptr50 = getelementptr inbounds %csec.tensor, ptr %tensor.malloc26, i32 0, i32 2
  %tensor.count51 = load i64, ptr %tensor.count.ptr50, align 4
  %tensor.malloc52 = call ptr @malloc(i64 32)
  %tensor.dims.bytes53 = mul i64 %tensor.rank49, 8
  %tensor.malloc54 = call ptr @malloc(i64 %tensor.dims.bytes53)
  %tensor.data.bytes55 = mul i64 %tensor.count51, 8
  %tensor.malloc56 = call ptr @malloc(i64 %tensor.data.bytes55)
  %tensor.rank.slot57 = getelementptr inbounds %csec.tensor, ptr %tensor.malloc52, i32 0, i32 0
  store i64 %tensor.rank49, ptr %tensor.rank.slot57, align 4
  %tensor.dims.slot58 = getelementptr inbounds %csec.tensor, ptr %tensor.malloc52, i32 0, i32 1
  store ptr %tensor.malloc54, ptr %tensor.dims.slot58, align 8
  %tensor.count.slot59 = getelementptr inbounds %csec.tensor, ptr %tensor.malloc52, i32 0, i32 2
  store i64 %tensor.count51, ptr %tensor.count.slot59, align 4
  %tensor.data.slot60 = getelementptr inbounds %csec.tensor, ptr %tensor.malloc52, i32 0, i32 3
  store ptr %tensor.malloc56, ptr %tensor.data.slot60, align 8
  %tensor.dims.ptr61 = getelementptr inbounds %csec.tensor, ptr %tensor.malloc26, i32 0, i32 1
  %tensor.dims62 = load ptr, ptr %tensor.dims.ptr61, align 8
  %tensor.dims.ptr63 = getelementptr inbounds %csec.tensor, ptr %tensor.malloc52, i32 0, i32 1
  %tensor.dims64 = load ptr, ptr %tensor.dims.ptr63, align 8
  %tensor.data.ptr65 = getelementptr inbounds %csec.tensor, ptr %tensor.malloc26, i32 0, i32 3
  %tensor.data66 = load ptr, ptr %tensor.data.ptr65, align 8
  %tensor.data.ptr67 = getelementptr inbounds %csec.tensor, ptr %tensor.malloc52, i32 0, i32 3
  %tensor.data68 = load ptr, ptr %tensor.data.ptr67, align 8
  %tensor.softmax.dims.i = alloca i64, align 8
  store i64 0, ptr %tensor.softmax.dims.i, align 4
  br label %tensor.softmax.dims.cond

tensor.softmax.dims.cond:                         ; preds = %tensor.softmax.dims.body, %tensor.fill.end42
  %tensor.softmax.dims.idx = load i64, ptr %tensor.softmax.dims.i, align 4
  %tensor.softmax.dims.keep = icmp ult i64 %tensor.softmax.dims.idx, %tensor.rank49
  br i1 %tensor.softmax.dims.keep, label %tensor.softmax.dims.body, label %tensor.softmax.dims.end

tensor.softmax.dims.body:                         ; preds = %tensor.softmax.dims.cond
  %tensor.softmax.src.dim = getelementptr i64, ptr %tensor.dims62, i64 %tensor.softmax.dims.idx
  %tensor.softmax.dst.dim = getelementptr i64, ptr %tensor.dims64, i64 %tensor.softmax.dims.idx
  %tensor.softmax.dim = load i64, ptr %tensor.softmax.src.dim, align 4
  store i64 %tensor.softmax.dim, ptr %tensor.softmax.dst.dim, align 4
  %tensor.softmax.dims.current = load i64, ptr %tensor.softmax.dims.i, align 4
  %tensor.softmax.dims.next = add i64 %tensor.softmax.dims.current, 1
  store i64 %tensor.softmax.dims.next, ptr %tensor.softmax.dims.i, align 4
  br label %tensor.softmax.dims.cond

tensor.softmax.dims.end:                          ; preds = %tensor.softmax.dims.cond
  %tensor.softmax.sum.ptr = alloca double, align 8
  store double 0.000000e+00, ptr %tensor.softmax.sum.ptr, align 8
  %tensor.softmax.exp.i = alloca i64, align 8
  store i64 0, ptr %tensor.softmax.exp.i, align 4
  br label %tensor.softmax.exp.cond

tensor.softmax.exp.cond:                          ; preds = %tensor.softmax.exp.body, %tensor.softmax.dims.end
  %tensor.softmax.exp.idx = load i64, ptr %tensor.softmax.exp.i, align 4
  %tensor.softmax.exp.keep = icmp ult i64 %tensor.softmax.exp.idx, %tensor.count51
  br i1 %tensor.softmax.exp.keep, label %tensor.softmax.exp.body, label %tensor.softmax.exp.end

tensor.softmax.exp.body:                          ; preds = %tensor.softmax.exp.cond
  %tensor.softmax.src = getelementptr double, ptr %tensor.data66, i64 %tensor.softmax.exp.idx
  %tensor.softmax.value = load double, ptr %tensor.softmax.src, align 8
  %tensor.softmax.exp.value = call double @csec_math_exp(double %tensor.softmax.value)
  %tensor.softmax.exp.dst = getelementptr double, ptr %tensor.data68, i64 %tensor.softmax.exp.idx
  store double %tensor.softmax.exp.value, ptr %tensor.softmax.exp.dst, align 8
  %tensor.softmax.sum.current = load double, ptr %tensor.softmax.sum.ptr, align 8
  %tensor.softmax.sum.next = fadd double %tensor.softmax.sum.current, %tensor.softmax.exp.value
  store double %tensor.softmax.sum.next, ptr %tensor.softmax.sum.ptr, align 8
  %tensor.softmax.exp.current = load i64, ptr %tensor.softmax.exp.i, align 4
  %tensor.softmax.exp.next = add i64 %tensor.softmax.exp.current, 1
  store i64 %tensor.softmax.exp.next, ptr %tensor.softmax.exp.i, align 4
  br label %tensor.softmax.exp.cond

tensor.softmax.exp.end:                           ; preds = %tensor.softmax.exp.cond
  %tensor.softmax.norm.i = alloca i64, align 8
  store i64 0, ptr %tensor.softmax.norm.i, align 4
  br label %tensor.softmax.norm.cond

tensor.softmax.norm.cond:                         ; preds = %tensor.softmax.norm.body, %tensor.softmax.exp.end
  %tensor.softmax.norm.idx = load i64, ptr %tensor.softmax.norm.i, align 4
  %tensor.softmax.norm.keep = icmp ult i64 %tensor.softmax.norm.idx, %tensor.count51
  br i1 %tensor.softmax.norm.keep, label %tensor.softmax.norm.body, label %tensor.softmax.norm.end

tensor.softmax.norm.body:                         ; preds = %tensor.softmax.norm.cond
  %tensor.softmax.norm.slot = getelementptr double, ptr %tensor.data68, i64 %tensor.softmax.norm.idx
  %tensor.softmax.exp.load = load double, ptr %tensor.softmax.norm.slot, align 8
  %tensor.softmax.sum = load double, ptr %tensor.softmax.sum.ptr, align 8
  %tensor.softmax.prob = fdiv double %tensor.softmax.exp.load, %tensor.softmax.sum
  store double %tensor.softmax.prob, ptr %tensor.softmax.norm.slot, align 8
  %tensor.softmax.norm.current = load i64, ptr %tensor.softmax.norm.i, align 4
  %tensor.softmax.norm.next = add i64 %tensor.softmax.norm.current, 1
  store i64 %tensor.softmax.norm.next, ptr %tensor.softmax.norm.i, align 4
  br label %tensor.softmax.norm.cond

tensor.softmax.norm.end:                          ; preds = %tensor.softmax.norm.cond
  %probabilities = alloca ptr, align 8
  store ptr %tensor.malloc52, ptr %probabilities, align 8
  %probabilities.load = load ptr, ptr %probabilities, align 8
  %tensor.count.ptr69 = getelementptr inbounds %csec.tensor, ptr %probabilities.load, i32 0, i32 2
  %tensor.count70 = load i64, ptr %tensor.count.ptr69, align 4
  %tensor.data.ptr71 = getelementptr inbounds %csec.tensor, ptr %probabilities.load, i32 0, i32 3
  %tensor.data72 = load ptr, ptr %tensor.data.ptr71, align 8
  %tensor.sum.ptr73 = alloca double, align 8
  store double 0.000000e+00, ptr %tensor.sum.ptr73, align 8
  %tensor.sum.i74 = alloca i64, align 8
  store i64 0, ptr %tensor.sum.i74, align 4
  br label %tensor.sum.cond75

tensor.sum.cond75:                                ; preds = %tensor.sum.body76, %tensor.softmax.norm.end
  %tensor.sum.idx78 = load i64, ptr %tensor.sum.i74, align 4
  %tensor.sum.keep79 = icmp ult i64 %tensor.sum.idx78, %tensor.count70
  br i1 %tensor.sum.keep79, label %tensor.sum.body76, label %tensor.sum.end77

tensor.sum.body76:                                ; preds = %tensor.sum.cond75
  %tensor.sum.slot80 = getelementptr double, ptr %tensor.data72, i64 %tensor.sum.idx78
  %tensor.sum.value81 = load double, ptr %tensor.sum.slot80, align 8
  %tensor.sum.current82 = load double, ptr %tensor.sum.ptr73, align 8
  %tensor.sum.next83 = fadd double %tensor.sum.current82, %tensor.sum.value81
  store double %tensor.sum.next83, ptr %tensor.sum.ptr73, align 8
  %tensor.sum.current84 = load i64, ptr %tensor.sum.i74, align 4
  %tensor.sum.next85 = add i64 %tensor.sum.current84, 1
  store i64 %tensor.sum.next85, ptr %tensor.sum.i74, align 4
  br label %tensor.sum.cond75

tensor.sum.end77:                                 ; preds = %tensor.sum.cond75
  %tensor.sum.result86 = load double, ptr %tensor.sum.ptr73, align 8
  %probabilityMass = alloca double, align 8
  store double %tensor.sum.result86, ptr %probabilityMass, align 8
  %tensor.malloc87 = call ptr @malloc(i64 32)
  %tensor.malloc88 = call ptr @malloc(i64 16)
  %tensor.malloc89 = call ptr @malloc(i64 32)
  %tensor.rank.slot90 = getelementptr inbounds %csec.tensor, ptr %tensor.malloc87, i32 0, i32 0
  store i64 2, ptr %tensor.rank.slot90, align 4
  %tensor.dims.slot91 = getelementptr inbounds %csec.tensor, ptr %tensor.malloc87, i32 0, i32 1
  store ptr %tensor.malloc88, ptr %tensor.dims.slot91, align 8
  %tensor.count.slot92 = getelementptr inbounds %csec.tensor, ptr %tensor.malloc87, i32 0, i32 2
  store i64 4, ptr %tensor.count.slot92, align 4
  %tensor.data.slot93 = getelementptr inbounds %csec.tensor, ptr %tensor.malloc87, i32 0, i32 3
  store ptr %tensor.malloc89, ptr %tensor.data.slot93, align 8
  %tensor.dims.ptr94 = getelementptr inbounds %csec.tensor, ptr %tensor.malloc87, i32 0, i32 1
  %tensor.dims95 = load ptr, ptr %tensor.dims.ptr94, align 8
  %tensor.data.ptr96 = getelementptr inbounds %csec.tensor, ptr %tensor.malloc87, i32 0, i32 3
  %tensor.data97 = load ptr, ptr %tensor.data.ptr96, align 8
  %tensor.dim.slot98 = getelementptr i64, ptr %tensor.dims95, i64 0
  store i64 2, ptr %tensor.dim.slot98, align 4
  %tensor.dim.slot99 = getelementptr i64, ptr %tensor.dims95, i64 1
  store i64 2, ptr %tensor.dim.slot99, align 4
  %tensor.fill.i100 = alloca i64, align 8
  store i64 0, ptr %tensor.fill.i100, align 4
  br label %tensor.fill.cond101

tensor.fill.cond101:                              ; preds = %tensor.fill.body102, %tensor.sum.end77
  %tensor.fill.idx104 = load i64, ptr %tensor.fill.i100, align 4
  %tensor.fill.keep105 = icmp ult i64 %tensor.fill.idx104, 4
  br i1 %tensor.fill.keep105, label %tensor.fill.body102, label %tensor.fill.end103

tensor.fill.body102:                              ; preds = %tensor.fill.cond101
  %tensor.data.slot106 = getelementptr double, ptr %tensor.data97, i64 %tensor.fill.idx104
  store double 3.000000e+00, ptr %tensor.data.slot106, align 8
  %tensor.fill.current107 = load i64, ptr %tensor.fill.i100, align 4
  %tensor.fill.next108 = add i64 %tensor.fill.current107, 1
  store i64 %tensor.fill.next108, ptr %tensor.fill.i100, align 4
  br label %tensor.fill.cond101

tensor.fill.end103:                               ; preds = %tensor.fill.cond101
  %tensor.malloc109 = call ptr @malloc(i64 32)
  %tensor.malloc110 = call ptr @malloc(i64 16)
  %tensor.malloc111 = call ptr @malloc(i64 32)
  %tensor.rank.slot112 = getelementptr inbounds %csec.tensor, ptr %tensor.malloc109, i32 0, i32 0
  store i64 2, ptr %tensor.rank.slot112, align 4
  %tensor.dims.slot113 = getelementptr inbounds %csec.tensor, ptr %tensor.malloc109, i32 0, i32 1
  store ptr %tensor.malloc110, ptr %tensor.dims.slot113, align 8
  %tensor.count.slot114 = getelementptr inbounds %csec.tensor, ptr %tensor.malloc109, i32 0, i32 2
  store i64 4, ptr %tensor.count.slot114, align 4
  %tensor.data.slot115 = getelementptr inbounds %csec.tensor, ptr %tensor.malloc109, i32 0, i32 3
  store ptr %tensor.malloc111, ptr %tensor.data.slot115, align 8
  %tensor.dims.ptr116 = getelementptr inbounds %csec.tensor, ptr %tensor.malloc109, i32 0, i32 1
  %tensor.dims117 = load ptr, ptr %tensor.dims.ptr116, align 8
  %tensor.data.ptr118 = getelementptr inbounds %csec.tensor, ptr %tensor.malloc109, i32 0, i32 3
  %tensor.data119 = load ptr, ptr %tensor.data.ptr118, align 8
  %tensor.dim.slot120 = getelementptr i64, ptr %tensor.dims117, i64 0
  store i64 2, ptr %tensor.dim.slot120, align 4
  %tensor.dim.slot121 = getelementptr i64, ptr %tensor.dims117, i64 1
  store i64 2, ptr %tensor.dim.slot121, align 4
  %tensor.fill.i122 = alloca i64, align 8
  store i64 0, ptr %tensor.fill.i122, align 4
  br label %tensor.fill.cond123

tensor.fill.cond123:                              ; preds = %tensor.fill.body124, %tensor.fill.end103
  %tensor.fill.idx126 = load i64, ptr %tensor.fill.i122, align 4
  %tensor.fill.keep127 = icmp ult i64 %tensor.fill.idx126, 4
  br i1 %tensor.fill.keep127, label %tensor.fill.body124, label %tensor.fill.end125

tensor.fill.body124:                              ; preds = %tensor.fill.cond123
  %tensor.data.slot128 = getelementptr double, ptr %tensor.data119, i64 %tensor.fill.idx126
  store double 1.000000e+00, ptr %tensor.data.slot128, align 8
  %tensor.fill.current129 = load i64, ptr %tensor.fill.i122, align 4
  %tensor.fill.next130 = add i64 %tensor.fill.current129, 1
  store i64 %tensor.fill.next130, ptr %tensor.fill.i122, align 4
  br label %tensor.fill.cond123

tensor.fill.end125:                               ; preds = %tensor.fill.cond123
  %tensor.rank.ptr131 = getelementptr inbounds %csec.tensor, ptr %tensor.malloc87, i32 0, i32 0
  %tensor.rank132 = load i64, ptr %tensor.rank.ptr131, align 4
  %tensor.count.ptr133 = getelementptr inbounds %csec.tensor, ptr %tensor.malloc87, i32 0, i32 2
  %tensor.count134 = load i64, ptr %tensor.count.ptr133, align 4
  %tensor.malloc135 = call ptr @malloc(i64 32)
  %tensor.dims.bytes136 = mul i64 %tensor.rank132, 8
  %tensor.malloc137 = call ptr @malloc(i64 %tensor.dims.bytes136)
  %tensor.data.bytes138 = mul i64 %tensor.count134, 8
  %tensor.malloc139 = call ptr @malloc(i64 %tensor.data.bytes138)
  %tensor.rank.slot140 = getelementptr inbounds %csec.tensor, ptr %tensor.malloc135, i32 0, i32 0
  store i64 %tensor.rank132, ptr %tensor.rank.slot140, align 4
  %tensor.dims.slot141 = getelementptr inbounds %csec.tensor, ptr %tensor.malloc135, i32 0, i32 1
  store ptr %tensor.malloc137, ptr %tensor.dims.slot141, align 8
  %tensor.count.slot142 = getelementptr inbounds %csec.tensor, ptr %tensor.malloc135, i32 0, i32 2
  store i64 %tensor.count134, ptr %tensor.count.slot142, align 4
  %tensor.data.slot143 = getelementptr inbounds %csec.tensor, ptr %tensor.malloc135, i32 0, i32 3
  store ptr %tensor.malloc139, ptr %tensor.data.slot143, align 8
  %tensor.dims.ptr144 = getelementptr inbounds %csec.tensor, ptr %tensor.malloc87, i32 0, i32 1
  %tensor.dims145 = load ptr, ptr %tensor.dims.ptr144, align 8
  %tensor.dims.ptr146 = getelementptr inbounds %csec.tensor, ptr %tensor.malloc135, i32 0, i32 1
  %tensor.dims147 = load ptr, ptr %tensor.dims.ptr146, align 8
  %tensor.data.ptr148 = getelementptr inbounds %csec.tensor, ptr %tensor.malloc87, i32 0, i32 3
  %tensor.data149 = load ptr, ptr %tensor.data.ptr148, align 8
  %tensor.data.ptr150 = getelementptr inbounds %csec.tensor, ptr %tensor.malloc109, i32 0, i32 3
  %tensor.data151 = load ptr, ptr %tensor.data.ptr150, align 8
  %tensor.data.ptr152 = getelementptr inbounds %csec.tensor, ptr %tensor.malloc135, i32 0, i32 3
  %tensor.data153 = load ptr, ptr %tensor.data.ptr152, align 8
  %tensor.elem.dims.i = alloca i64, align 8
  store i64 0, ptr %tensor.elem.dims.i, align 4
  br label %tensor.elem.dims.cond

tensor.elem.dims.cond:                            ; preds = %tensor.elem.dims.body, %tensor.fill.end125
  %tensor.elem.dims.idx = load i64, ptr %tensor.elem.dims.i, align 4
  %tensor.elem.dims.keep = icmp ult i64 %tensor.elem.dims.idx, %tensor.rank132
  br i1 %tensor.elem.dims.keep, label %tensor.elem.dims.body, label %tensor.elem.dims.end

tensor.elem.dims.body:                            ; preds = %tensor.elem.dims.cond
  %tensor.elem.src.dim = getelementptr i64, ptr %tensor.dims145, i64 %tensor.elem.dims.idx
  %tensor.elem.dst.dim = getelementptr i64, ptr %tensor.dims147, i64 %tensor.elem.dims.idx
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
  %tensor.elem.data.keep = icmp ult i64 %tensor.elem.data.idx, %tensor.count134
  br i1 %tensor.elem.data.keep, label %tensor.elem.data.body, label %tensor.elem.data.end

tensor.elem.data.body:                            ; preds = %tensor.elem.data.cond
  %tensor.elem.left = getelementptr double, ptr %tensor.data149, i64 %tensor.elem.data.idx
  %tensor.elem.l = load double, ptr %tensor.elem.left, align 8
  %tensor.elem.right = getelementptr double, ptr %tensor.data151, i64 %tensor.elem.data.idx
  %tensor.elem.r = load double, ptr %tensor.elem.right, align 8
  %tensor.elem.dst = getelementptr double, ptr %tensor.data153, i64 %tensor.elem.data.idx
  %tensor.sub = fsub double %tensor.elem.l, %tensor.elem.r
  store double %tensor.sub, ptr %tensor.elem.dst, align 8
  %tensor.elem.data.current = load i64, ptr %tensor.elem.data.i, align 4
  %tensor.elem.data.next = add i64 %tensor.elem.data.current, 1
  store i64 %tensor.elem.data.next, ptr %tensor.elem.data.i, align 4
  br label %tensor.elem.data.cond

tensor.elem.data.end:                             ; preds = %tensor.elem.data.cond
  %difference = alloca ptr, align 8
  store ptr %tensor.malloc135, ptr %difference, align 8
  %tensor.count.ptr154 = getelementptr inbounds %csec.tensor, ptr %tensor.malloc87, i32 0, i32 2
  %tensor.count155 = load i64, ptr %tensor.count.ptr154, align 4
  %tensor.count.ptr156 = getelementptr inbounds %csec.tensor, ptr %tensor.malloc109, i32 0, i32 2
  %tensor.count157 = load i64, ptr %tensor.count.ptr156, align 4
  %0 = icmp ult i64 %tensor.count155, %tensor.count157
  %tensor.mse.count = select i1 %0, i64 %tensor.count155, i64 %tensor.count157
  %tensor.data.ptr158 = getelementptr inbounds %csec.tensor, ptr %tensor.malloc87, i32 0, i32 3
  %tensor.data159 = load ptr, ptr %tensor.data.ptr158, align 8
  %tensor.data.ptr160 = getelementptr inbounds %csec.tensor, ptr %tensor.malloc109, i32 0, i32 3
  %tensor.data161 = load ptr, ptr %tensor.data.ptr160, align 8
  %tensor.mse.sum.ptr = alloca double, align 8
  store double 0.000000e+00, ptr %tensor.mse.sum.ptr, align 8
  %tensor.mse.i = alloca i64, align 8
  store i64 0, ptr %tensor.mse.i, align 4
  br label %tensor.mse.cond

tensor.mse.cond:                                  ; preds = %tensor.mse.body, %tensor.elem.data.end
  %tensor.mse.idx = load i64, ptr %tensor.mse.i, align 4
  %tensor.mse.keep = icmp ult i64 %tensor.mse.idx, %tensor.mse.count
  br i1 %tensor.mse.keep, label %tensor.mse.body, label %tensor.mse.end

tensor.mse.body:                                  ; preds = %tensor.mse.cond
  %tensor.mse.pred = getelementptr double, ptr %tensor.data159, i64 %tensor.mse.idx
  %tensor.mse.pred.value = load double, ptr %tensor.mse.pred, align 8
  %tensor.mse.target = getelementptr double, ptr %tensor.data161, i64 %tensor.mse.idx
  %tensor.mse.target.value = load double, ptr %tensor.mse.target, align 8
  %tensor.mse.diff = fsub double %tensor.mse.pred.value, %tensor.mse.target.value
  %tensor.mse.square = fmul double %tensor.mse.diff, %tensor.mse.diff
  %tensor.mse.current = load double, ptr %tensor.mse.sum.ptr, align 8
  %tensor.mse.next = fadd double %tensor.mse.current, %tensor.mse.square
  store double %tensor.mse.next, ptr %tensor.mse.sum.ptr, align 8
  %tensor.mse.current162 = load i64, ptr %tensor.mse.i, align 4
  %tensor.mse.next163 = add i64 %tensor.mse.current162, 1
  store i64 %tensor.mse.next163, ptr %tensor.mse.i, align 4
  br label %tensor.mse.cond

tensor.mse.end:                                   ; preds = %tensor.mse.cond
  %tensor.mse.count.fp = uitofp i64 %tensor.mse.count to double
  %tensor.mse.sum = load double, ptr %tensor.mse.sum.ptr, align 8
  %tensor.mse.result = fdiv double %tensor.mse.sum, %tensor.mse.count.fp
  %loss = alloca double, align 8
  store double %tensor.mse.result, ptr %loss, align 8
  %tensor.count.ptr164 = getelementptr inbounds %csec.tensor, ptr %tensor.malloc87, i32 0, i32 2
  %tensor.count165 = load i64, ptr %tensor.count.ptr164, align 4
  %tensor.mean.count = uitofp i64 %tensor.count165 to double
  %tensor.count.ptr166 = getelementptr inbounds %csec.tensor, ptr %tensor.malloc87, i32 0, i32 2
  %tensor.count167 = load i64, ptr %tensor.count.ptr166, align 4
  %tensor.data.ptr168 = getelementptr inbounds %csec.tensor, ptr %tensor.malloc87, i32 0, i32 3
  %tensor.data169 = load ptr, ptr %tensor.data.ptr168, align 8
  %tensor.sum.ptr170 = alloca double, align 8
  store double 0.000000e+00, ptr %tensor.sum.ptr170, align 8
  %tensor.sum.i171 = alloca i64, align 8
  store i64 0, ptr %tensor.sum.i171, align 4
  br label %tensor.sum.cond172

tensor.sum.cond172:                               ; preds = %tensor.sum.body173, %tensor.mse.end
  %tensor.sum.idx175 = load i64, ptr %tensor.sum.i171, align 4
  %tensor.sum.keep176 = icmp ult i64 %tensor.sum.idx175, %tensor.count167
  br i1 %tensor.sum.keep176, label %tensor.sum.body173, label %tensor.sum.end174

tensor.sum.body173:                               ; preds = %tensor.sum.cond172
  %tensor.sum.slot177 = getelementptr double, ptr %tensor.data169, i64 %tensor.sum.idx175
  %tensor.sum.value178 = load double, ptr %tensor.sum.slot177, align 8
  %tensor.sum.current179 = load double, ptr %tensor.sum.ptr170, align 8
  %tensor.sum.next180 = fadd double %tensor.sum.current179, %tensor.sum.value178
  store double %tensor.sum.next180, ptr %tensor.sum.ptr170, align 8
  %tensor.sum.current181 = load i64, ptr %tensor.sum.i171, align 4
  %tensor.sum.next182 = add i64 %tensor.sum.current181, 1
  store i64 %tensor.sum.next182, ptr %tensor.sum.i171, align 4
  br label %tensor.sum.cond172

tensor.sum.end174:                                ; preds = %tensor.sum.cond172
  %tensor.sum.result183 = load double, ptr %tensor.sum.ptr170, align 8
  %tensor.mean = fdiv double %tensor.sum.result183, %tensor.mean.count
  %average = alloca double, align 8
  store double %tensor.mean, ptr %average, align 8
  %difference.load = load ptr, ptr %difference, align 8
  %tensor.count.ptr184 = getelementptr inbounds %csec.tensor, ptr %difference.load, i32 0, i32 2
  %tensor.count185 = load i64, ptr %tensor.count.ptr184, align 4
  %tensor.data.ptr186 = getelementptr inbounds %csec.tensor, ptr %difference.load, i32 0, i32 3
  %tensor.data187 = load ptr, ptr %tensor.data.ptr186, align 8
  %tensor.norm.sum.ptr = alloca double, align 8
  store double 0.000000e+00, ptr %tensor.norm.sum.ptr, align 8
  %tensor.norm.i = alloca i64, align 8
  store i64 0, ptr %tensor.norm.i, align 4
  br label %tensor.norm.cond

tensor.norm.cond:                                 ; preds = %tensor.norm.body, %tensor.sum.end174
  %tensor.norm.idx = load i64, ptr %tensor.norm.i, align 4
  %tensor.norm.keep = icmp ult i64 %tensor.norm.idx, %tensor.count185
  br i1 %tensor.norm.keep, label %tensor.norm.body, label %tensor.norm.end

tensor.norm.body:                                 ; preds = %tensor.norm.cond
  %tensor.norm.slot = getelementptr double, ptr %tensor.data187, i64 %tensor.norm.idx
  %tensor.norm.value = load double, ptr %tensor.norm.slot, align 8
  %tensor.norm.square = fmul double %tensor.norm.value, %tensor.norm.value
  %tensor.norm.current = load double, ptr %tensor.norm.sum.ptr, align 8
  %tensor.norm.next = fadd double %tensor.norm.current, %tensor.norm.square
  store double %tensor.norm.next, ptr %tensor.norm.sum.ptr, align 8
  %tensor.norm.current188 = load i64, ptr %tensor.norm.i, align 4
  %tensor.norm.next189 = add i64 %tensor.norm.current188, 1
  store i64 %tensor.norm.next189, ptr %tensor.norm.i, align 4
  br label %tensor.norm.cond

tensor.norm.end:                                  ; preds = %tensor.norm.cond
  %tensor.norm.sum = load double, ptr %tensor.norm.sum.ptr, align 8
  %tensor.norm.result = call double @csec_math_sqrt(double %tensor.norm.sum)
  %length = alloca double, align 8
  store double %tensor.norm.result, ptr %length, align 8
  %zeroSum.load = load ptr, ptr %zeroSum, align 8
  %math.arg.load = load double, ptr %zeroSum.load, align 8
  %approx.diff = fsub double %math.arg.load, 0.000000e+00
  %approx.abs = call double @csec_math_abs(double %approx.diff)
  %approx.eq = fcmp ole double %approx.abs, 0x3EB0C6F7A0000000
  br i1 %approx.eq, label %and_rhs, label %and_end

and_rhs:                                          ; preds = %tensor.norm.end
  %probabilityMass.load = load ptr, ptr %probabilityMass, align 8
  %math.arg.load190 = load double, ptr %probabilityMass.load, align 8
  %approx.diff191 = fsub double %math.arg.load190, 1.000000e+00
  %approx.abs192 = call double @csec_math_abs(double %approx.diff191)
  %approx.eq193 = fcmp ole double %approx.abs192, 0x3EB0C6F7A0000000
  br label %and_end

and_end:                                          ; preds = %and_rhs, %tensor.norm.end
  %and_result.0 = phi i1 [ %approx.eq193, %and_rhs ], [ false, %tensor.norm.end ]
  br i1 %and_result.0, label %and_rhs195, label %and_end196

and_rhs195:                                       ; preds = %and_end
  %loss.load = load ptr, ptr %loss, align 8
  %math.arg.load197 = load double, ptr %loss.load, align 8
  %approx.diff198 = fsub double %math.arg.load197, 4.000000e+00
  %approx.abs199 = call double @csec_math_abs(double %approx.diff198)
  %approx.eq200 = fcmp ole double %approx.abs199, 0x3EB0C6F7A0000000
  br label %and_end196

and_end196:                                       ; preds = %and_rhs195, %and_end
  %and_result194.0 = phi i1 [ %approx.eq200, %and_rhs195 ], [ false, %and_end ]
  br i1 %and_result194.0, label %and_rhs203, label %and_end204

and_rhs203:                                       ; preds = %and_end196
  %average.load = load ptr, ptr %average, align 8
  %math.arg.load205 = load double, ptr %average.load, align 8
  %approx.diff206 = fsub double %math.arg.load205, 3.000000e+00
  %approx.abs207 = call double @csec_math_abs(double %approx.diff206)
  %approx.eq208 = fcmp ole double %approx.abs207, 0x3EB0C6F7A0000000
  br label %and_end204

and_end204:                                       ; preds = %and_rhs203, %and_end196
  %and_result202.0 = phi i1 [ %approx.eq208, %and_rhs203 ], [ false, %and_end196 ]
  br i1 %and_result202.0, label %and_rhs211, label %and_end212

and_rhs211:                                       ; preds = %and_end204
  %length.load = load ptr, ptr %length, align 8
  %math.arg.load213 = load double, ptr %length.load, align 8
  %approx.diff214 = fsub double %math.arg.load213, 4.000000e+00
  %approx.abs215 = call double @csec_math_abs(double %approx.diff214)
  %approx.eq216 = fcmp ole double %approx.abs215, 0x3EB0C6F7A0000000
  br label %and_end212

and_end212:                                       ; preds = %and_rhs211, %and_end204
  %and_result210.0 = phi i1 [ %approx.eq216, %and_rhs211 ], [ false, %and_end204 ]
  br i1 %and_result210.0, label %then, label %ifcont

then:                                             ; preds = %and_end212
  ret i32 0

ifcont:                                           ; preds = %and_end212
  ret i32 1
}

declare double @csec_math_exp(double)

declare double @csec_math_sqrt(double)

declare double @csec_math_abs(double)

declare void @csec_set_command_line_args(i32, ptr)

define internal i32 @__csec_jit_entry() {
entry:
  %user.main = call i32 @_main()
  ret i32 %user.main
}
