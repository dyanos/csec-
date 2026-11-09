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

define i32 @_apply(ptr %0, i32 %1) {
entry:
  %closure.code = getelementptr inbounds { ptr, ptr }, ptr %0, i32 0, i32 0
  %closure.code.fn = load ptr, ptr %closure.code, align 8
  %closure.env = getelementptr inbounds { ptr, ptr }, ptr %0, i32 0, i32 1
  %closure.env.ptr = load ptr, ptr %closure.env, align 8
  %closure.call = call i32 %closure.code.fn(ptr %closure.env.ptr, i32 %1)
  ret i32 %closure.call
}

define i32 @_applyBinary(ptr %0, i32 %1, i32 %2) {
entry:
  %closure.code = getelementptr inbounds { ptr, ptr }, ptr %0, i32 0, i32 0
  %closure.code.fn = load ptr, ptr %closure.code, align 8
  %closure.env = getelementptr inbounds { ptr, ptr }, ptr %0, i32 0, i32 1
  %closure.env.ptr = load ptr, ptr %closure.env, align 8
  %closure.call = call i32 %closure.code.fn(ptr %closure.env.ptr, i32 %1, i32 %2)
  ret i32 %closure.call
}

define i1 @_applyPred(ptr %0, i32 %1) {
entry:
  %closure.code = getelementptr inbounds { ptr, ptr }, ptr %0, i32 0, i32 0
  %closure.code.fn = load ptr, ptr %closure.code, align 8
  %closure.env = getelementptr inbounds { ptr, ptr }, ptr %0, i32 0, i32 1
  %closure.env.ptr = load ptr, ptr %closure.env, align 8
  %closure.call = call i1 %closure.code.fn(ptr %closure.env.ptr, i32 %1)
  ret i1 %closure.call
}

define i32 @_compose(ptr %0, ptr %1, i32 %2) {
entry:
  %closure.code = getelementptr inbounds { ptr, ptr }, ptr %1, i32 0, i32 0
  %closure.code.fn = load ptr, ptr %closure.code, align 8
  %closure.env = getelementptr inbounds { ptr, ptr }, ptr %1, i32 0, i32 1
  %closure.env.ptr = load ptr, ptr %closure.env, align 8
  %closure.call = call i32 %closure.code.fn(ptr %closure.env.ptr, i32 %2)
  %closure.code1 = getelementptr inbounds { ptr, ptr }, ptr %0, i32 0, i32 0
  %closure.code.fn2 = load ptr, ptr %closure.code1, align 8
  %closure.env3 = getelementptr inbounds { ptr, ptr }, ptr %0, i32 0, i32 1
  %closure.env.ptr4 = load ptr, ptr %closure.env3, align 8
  %closure.call5 = call i32 %closure.code.fn2(ptr %closure.env.ptr4, i32 %closure.call)
  ret i32 %closure.call5
}

define i32 @_main() {
entry:
  ret i32 0
}

declare void @csec_set_command_line_args(i32, ptr)

define internal i32 @__csec_jit_entry() {
entry:
  %user.main = call i32 @_main()
  ret i32 %user.main
}
