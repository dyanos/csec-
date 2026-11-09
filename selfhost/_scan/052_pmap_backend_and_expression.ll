; ModuleID = 'main'
source_filename = "main"

%csec.pmap.ctx.1 = type { ptr, ptr, i32 }

@0 = private unnamed_addr constant [7 x i8] c"openmp\00", align 1

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
  %pmap.ctx = alloca %csec.pmap.ctx.1, align 8
  %pmap.ctx.input.slot = getelementptr inbounds %csec.pmap.ctx.1, ptr %pmap.ctx, i32 0, i32 0
  store ptr %pmap_arr_decay, ptr %pmap.ctx.input.slot, align 8
  %pmap.ctx.result.slot = getelementptr inbounds %csec.pmap.ctx.1, ptr %pmap.ctx, i32 0, i32 1
  store ptr %pmapresult, ptr %pmap.ctx.result.slot, align 8
  %pmap.ctx.capture.slot = getelementptr inbounds %csec.pmap.ctx.1, ptr %pmap.ctx, i32 0, i32 2
  store i32 2, ptr %pmap.ctx.capture.slot, align 4
  call void @csec_parallel_for_i32(i32 0, i32 4, ptr %pmap.ctx, ptr @__csec_pmap_body_1)
  %map_arr_decay = getelementptr inbounds [4 x i32], ptr %pmapresult, i32 0, i32 0
  %mapresult = alloca i32, i32 4, align 4
  br label %mapcond

mapcond:                                          ; preds = %mapbody, %entry
  %map_i.0 = phi i32 [ 0, %entry ], [ %next_i, %mapbody ]
  %mapcmp = icmp slt i32 %map_i.0, 4
  br i1 %mapcmp, label %mapbody, label %aftermap

mapbody:                                          ; preds = %mapcond
  %elemptr = getelementptr i32, ptr %map_arr_decay, i32 %map_i.0
  %elem = load i32, ptr %elemptr, align 4
  %addtmp = add i32 %elem, 1
  %resultptr = getelementptr i32, ptr %mapresult, i32 %map_i.0
  store i32 %addtmp, ptr %resultptr, align 4
  %next_i = add i32 %map_i.0, 1
  br label %mapcond

aftermap:                                         ; preds = %mapcond
  %parallel.threads = call i32 @csec_parallel_get_num_threads()
  %threads = alloca i32, align 4
  store i32 %parallel.threads, ptr %threads, align 4
  %threads.load = load i32, ptr %threads, align 4
  %math.sext = sext i32 %threads.load to i64
  %parallel.thread.count = trunc i64 %math.sext to i32
  call void @csec_parallel_set_num_threads(i32 %parallel.thread.count)
  %parallel.backend.available = call i32 @csec_parallel_backend_available(ptr @0)
  %hasOpenMp = alloca i32, align 4
  store i32 %parallel.backend.available, ptr %hasOpenMp, align 4
  ret i32 0
}

define internal void @__csec_pmap_body_1(ptr %ctx, i32 %idx) {
entry:
  %pmap.cb.input.slot = getelementptr inbounds %csec.pmap.ctx.1, ptr %ctx, i32 0, i32 0
  %pmap.cb.input = load ptr, ptr %pmap.cb.input.slot, align 8
  %pmap.cb.result.slot = getelementptr inbounds %csec.pmap.ctx.1, ptr %ctx, i32 0, i32 1
  %pmap.cb.result = load ptr, ptr %pmap.cb.result.slot, align 8
  %pmap.cb.elem.ptr = getelementptr i32, ptr %pmap.cb.input, i32 %idx
  %pmap.cb.elem = load i32, ptr %pmap.cb.elem.ptr, align 4
  %scale.capture.slot = getelementptr inbounds %csec.pmap.ctx.1, ptr %ctx, i32 0, i32 2
  %scale.capture = load i32, ptr %scale.capture.slot, align 4
  %multmp = mul i32 %pmap.cb.elem, %scale.capture
  %pmap.cb.result.ptr = getelementptr i32, ptr %pmap.cb.result, i32 %idx
  store i32 %multmp, ptr %pmap.cb.result.ptr, align 4
  ret void
}

declare void @csec_parallel_for_i32(i32, i32, ptr, ptr)

declare i32 @csec_parallel_get_num_threads()

declare void @csec_parallel_set_num_threads(i32)

declare i32 @csec_parallel_backend_available(ptr)

declare void @csec_set_command_line_args(i32, ptr)

define internal i32 @__csec_jit_entry() {
entry:
  %user.main = call i32 @_main()
  ret i32 %user.main
}
