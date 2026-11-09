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
  %lambda.env = alloca {}, align 8
  %lambda.closure = alloca { ptr, ptr }, align 8
  %closure.code = getelementptr inbounds { ptr, ptr }, ptr %lambda.closure, i32 0, i32 0
  store ptr @__lambda_0, ptr %closure.code, align 8
  %closure.env = getelementptr inbounds { ptr, ptr }, ptr %lambda.closure, i32 0, i32 1
  store ptr %lambda.env, ptr %closure.env, align 8
  %lambda.env1 = alloca {}, align 8
  %lambda.closure2 = alloca { ptr, ptr }, align 8
  %closure.code3 = getelementptr inbounds { ptr, ptr }, ptr %lambda.closure2, i32 0, i32 0
  store ptr @__lambda_1, ptr %closure.code3, align 8
  %closure.env4 = getelementptr inbounds { ptr, ptr }, ptr %lambda.closure2, i32 0, i32 1
  store ptr %lambda.env1, ptr %closure.env4, align 8
  %calltmp = call i32 @_compose(ptr %lambda.closure, ptr %lambda.closure2, i32 20)
  ret i32 %calltmp
}

define internal i32 @__lambda_0(ptr %0, i32 %1) {
entry:
  %addtmp = add i32 %1, 1
  ret i32 %addtmp
}

define internal i32 @__lambda_1(ptr %0, i32 %1) {
entry:
  %multmp = mul i32 %1, 2
  ret i32 %multmp
}

declare void @csec_set_command_line_args(i32, ptr)

define internal i32 @__csec_jit_entry() {
entry:
  %user.main = call i32 @_main()
  ret i32 %user.main
}
