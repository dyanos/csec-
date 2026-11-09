; ModuleID = 'main'
source_filename = "main"

%csec.pmap.ctx.1 = type { ptr, ptr, [3 x i32], i32 }
%csec.pmap.ctx.2 = type { ptr, ptr, i32 }

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
  %arrlit = alloca i32, i32 3, align 4
  %0 = getelementptr i32, ptr %arrlit, i32 0
  store i32 1, ptr %0, align 4
  %1 = getelementptr i32, ptr %arrlit, i32 1
  store i32 2, ptr %1, align 4
  %2 = getelementptr i32, ptr %arrlit, i32 2
  store i32 3, ptr %2, align 4
  %pmap_arr_decay = getelementptr inbounds [3 x i32], ptr %arrlit, i32 0, i32 0
  %pmapresult = alloca i32, i32 3, align 4
  %xs.pmap.capture = load [3 x i32], ptr %arrlit, align 4
  %pmap.ctx = alloca %csec.pmap.ctx.1, align 8
  %pmap.ctx.input.slot = getelementptr inbounds %csec.pmap.ctx.1, ptr %pmap.ctx, i32 0, i32 0
  store ptr %pmap_arr_decay, ptr %pmap.ctx.input.slot, align 8
  %pmap.ctx.result.slot = getelementptr inbounds %csec.pmap.ctx.1, ptr %pmap.ctx, i32 0, i32 1
  store ptr %pmapresult, ptr %pmap.ctx.result.slot, align 8
  %pmap.ctx.capture.slot = getelementptr inbounds %csec.pmap.ctx.1, ptr %pmap.ctx, i32 0, i32 2
  store [3 x i32] %xs.pmap.capture, ptr %pmap.ctx.capture.slot, align 4
  %pmap.ctx.capture.slot1 = getelementptr inbounds %csec.pmap.ctx.1, ptr %pmap.ctx, i32 0, i32 3
  store i32 2, ptr %pmap.ctx.capture.slot1, align 4
  call void @csec_parallel_for_i32(i32 0, i32 3, ptr %pmap.ctx, ptr @__csec_pmap_body_1)
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
  %xs.capture.slot = getelementptr inbounds %csec.pmap.ctx.1, ptr %ctx, i32 0, i32 2
  %xs.capture = load [3 x i32], ptr %xs.capture.slot, align 4
  %xs_capture_ptr = alloca [3 x i32], align 4
  store [3 x i32] %xs.capture, ptr %xs_capture_ptr, align 4
  %outerScale.capture.slot = getelementptr inbounds %csec.pmap.ctx.1, ptr %ctx, i32 0, i32 3
  %outerScale.capture = load i32, ptr %outerScale.capture.slot, align 4
  %pmap_arr_decay = getelementptr inbounds [3 x i32], ptr %xs_capture_ptr, i32 0, i32 0
  %pmapresult = alloca i32, i32 3, align 4
  %pmap.ctx = alloca %csec.pmap.ctx.2, align 8
  %pmap.ctx.input.slot = getelementptr inbounds %csec.pmap.ctx.2, ptr %pmap.ctx, i32 0, i32 0
  store ptr %pmap_arr_decay, ptr %pmap.ctx.input.slot, align 8
  %pmap.ctx.result.slot = getelementptr inbounds %csec.pmap.ctx.2, ptr %pmap.ctx, i32 0, i32 1
  store ptr %pmapresult, ptr %pmap.ctx.result.slot, align 8
  %pmap.ctx.capture.slot = getelementptr inbounds %csec.pmap.ctx.2, ptr %pmap.ctx, i32 0, i32 2
  store i32 %outerScale.capture, ptr %pmap.ctx.capture.slot, align 4
  call void @csec_parallel_for_i32(i32 0, i32 3, ptr %pmap.ctx, ptr @__csec_pmap_body_2)
  %addtmp = add i32 %pmap.cb.elem, %outerScale.capture
  %pmap.cb.result.ptr = getelementptr i32, ptr %pmap.cb.result, i32 %idx
  store i32 %addtmp, ptr %pmap.cb.result.ptr, align 4
  ret void
}

define internal void @__csec_pmap_body_2(ptr %ctx, i32 %idx) {
entry:
  %pmap.cb.input.slot = getelementptr inbounds %csec.pmap.ctx.2, ptr %ctx, i32 0, i32 0
  %pmap.cb.input = load ptr, ptr %pmap.cb.input.slot, align 8
  %pmap.cb.result.slot = getelementptr inbounds %csec.pmap.ctx.2, ptr %ctx, i32 0, i32 1
  %pmap.cb.result = load ptr, ptr %pmap.cb.result.slot, align 8
  %pmap.cb.elem.ptr = getelementptr i32, ptr %pmap.cb.input, i32 %idx
  %pmap.cb.elem = load i32, ptr %pmap.cb.elem.ptr, align 4
  %outerScale.capture.slot = getelementptr inbounds %csec.pmap.ctx.2, ptr %ctx, i32 0, i32 2
  %outerScale.capture = load i32, ptr %outerScale.capture.slot, align 4
  %addtmp = add i32 %pmap.cb.elem, %outerScale.capture
  %pmap.cb.result.ptr = getelementptr i32, ptr %pmap.cb.result, i32 %idx
  store i32 %addtmp, ptr %pmap.cb.result.ptr, align 4
  ret void
}

declare void @csec_parallel_for_i32(i32, i32, ptr, ptr)

declare void @csec_set_command_line_args(i32, ptr)

define internal i32 @__csec_jit_entry() {
entry:
  %user.main = call i32 @_main()
  ret i32 %user.main
}
