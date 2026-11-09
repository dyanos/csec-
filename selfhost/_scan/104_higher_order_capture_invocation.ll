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

define i32 @_main() {
entry:
  %lambda.env = alloca { i32 }, align 8
  %offset.store = getelementptr inbounds { i32 }, ptr %lambda.env, i32 0, i32 0
  store i32 1, ptr %offset.store, align 4
  %lambda.closure = alloca { ptr, ptr }, align 8
  %closure.code = getelementptr inbounds { ptr, ptr }, ptr %lambda.closure, i32 0, i32 0
  store ptr @__lambda_0, ptr %closure.code, align 8
  %closure.env = getelementptr inbounds { ptr, ptr }, ptr %lambda.closure, i32 0, i32 1
  store ptr %lambda.env, ptr %closure.env, align 8
  %calltmp = call i32 @_apply(ptr %lambda.closure, i32 41)
  ret i32 %calltmp
}

define internal i32 @__lambda_0(ptr %0, i32 %1) {
entry:
  %offset.cap = getelementptr inbounds { i32 }, ptr %0, i32 0, i32 0
  %offset.val = load i32, ptr %offset.cap, align 4
  %addtmp = add i32 %1, %offset.val
  ret i32 %addtmp
}

declare void @csec_set_command_line_args(i32, ptr)

define internal i32 @__csec_jit_entry() {
entry:
  %user.main = call i32 @_main()
  ret i32 %user.main
}
