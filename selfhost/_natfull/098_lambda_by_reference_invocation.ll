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

define i32 @_main() {
entry:
  %total = alloca i32, align 4
  store i32 10, ptr %total, align 4
  %lambda.env = alloca { ptr }, align 8
  %total.store = getelementptr inbounds { ptr }, ptr %lambda.env, i32 0, i32 0
  store ptr %total, ptr %total.store, align 8
  %lambda.closure = alloca { ptr, ptr }, align 8
  %closure.code = getelementptr inbounds { ptr, ptr }, ptr %lambda.closure, i32 0, i32 0
  store ptr @__lambda_0, ptr %closure.code, align 8
  %closure.env = getelementptr inbounds { ptr, ptr }, ptr %lambda.closure, i32 0, i32 1
  store ptr %lambda.env, ptr %closure.env, align 8
  %closure.code1 = getelementptr inbounds { ptr, ptr }, ptr %lambda.closure, i32 0, i32 0
  %closure.code.fn = load ptr, ptr %closure.code1, align 8
  %closure.env2 = getelementptr inbounds { ptr, ptr }, ptr %lambda.closure, i32 0, i32 1
  %closure.env.ptr = load ptr, ptr %closure.env2, align 8
  %closure.call = call i32 %closure.code.fn(ptr %closure.env.ptr, i32 1)
  %closure.code3 = getelementptr inbounds { ptr, ptr }, ptr %lambda.closure, i32 0, i32 0
  %closure.code.fn4 = load ptr, ptr %closure.code3, align 8
  %closure.env5 = getelementptr inbounds { ptr, ptr }, ptr %lambda.closure, i32 0, i32 1
  %closure.env.ptr6 = load ptr, ptr %closure.env5, align 8
  %closure.call7 = call i32 %closure.code.fn4(ptr %closure.env.ptr6, i32 1)
  ret i32 %closure.call7
}

define internal i32 @__lambda_0(ptr %0, i32 %1) {
entry:
  %total.cap = getelementptr inbounds { ptr }, ptr %0, i32 0, i32 0
  %total.ref = load ptr, ptr %total.cap, align 8
  %loadtmp = load i32, ptr %total.ref, align 4
  %addtmp = add i32 %loadtmp, %1
  store i32 %addtmp, ptr %total.ref, align 4
  %abi.load = load i32, ptr %total.ref, align 4
  ret i32 %abi.load
}

declare void @csec_set_command_line_args(i32, ptr)

define internal i32 @__csec_jit_entry() {
entry:
  %user.main = call i32 @_main()
  ret i32 %user.main
}
