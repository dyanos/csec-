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
  %lambda.env = alloca { i32 }, align 8
  %offset.store = getelementptr inbounds { i32 }, ptr %lambda.env, i32 0, i32 0
  store i32 10, ptr %offset.store, align 4
  %lambda.closure = alloca { ptr, ptr }, align 8
  %closure.code = getelementptr inbounds { ptr, ptr }, ptr %lambda.closure, i32 0, i32 0
  store ptr @__lambda_0, ptr %closure.code, align 8
  %closure.env = getelementptr inbounds { ptr, ptr }, ptr %lambda.closure, i32 0, i32 1
  store ptr %lambda.env, ptr %closure.env, align 8
  %lambda.env1 = alloca { i32, i32 }, align 8
  %offset.store2 = getelementptr inbounds { i32, i32 }, ptr %lambda.env1, i32 0, i32 0
  store i32 10, ptr %offset.store2, align 4
  %scale.store = getelementptr inbounds { i32, i32 }, ptr %lambda.env1, i32 0, i32 1
  store i32 2, ptr %scale.store, align 4
  %lambda.closure4 = alloca { ptr, ptr }, align 8
  %closure.code5 = getelementptr inbounds { ptr, ptr }, ptr %lambda.closure4, i32 0, i32 0
  store ptr @__lambda_1, ptr %closure.code5, align 8
  %closure.env6 = getelementptr inbounds { ptr, ptr }, ptr %lambda.closure4, i32 0, i32 1
  store ptr %lambda.env1, ptr %closure.env6, align 8
  %lambda.env7 = alloca { i32, i32 }, align 8
  %offset.store8 = getelementptr inbounds { i32, i32 }, ptr %lambda.env7, i32 0, i32 0
  store i32 10, ptr %offset.store8, align 4
  %scale.store10 = getelementptr inbounds { i32, i32 }, ptr %lambda.env7, i32 0, i32 1
  store i32 2, ptr %scale.store10, align 4
  %lambda.closure12 = alloca { ptr, ptr }, align 8
  %closure.code13 = getelementptr inbounds { ptr, ptr }, ptr %lambda.closure12, i32 0, i32 0
  store ptr @__lambda_2, ptr %closure.code13, align 8
  %closure.env14 = getelementptr inbounds { ptr, ptr }, ptr %lambda.closure12, i32 0, i32 1
  store ptr %lambda.env7, ptr %closure.env14, align 8
  ret i32 0
}

define internal i32 @__lambda_0(ptr %0, i32 %1) {
entry:
  %offset.cap = getelementptr inbounds { i32 }, ptr %0, i32 0, i32 0
  %offset.val = load i32, ptr %offset.cap, align 4
  %addtmp = add i32 %1, %offset.val
  ret i32 %addtmp
}

define internal i32 @__lambda_1(ptr %0, i32 %1) {
entry:
  %offset.cap = getelementptr inbounds { i32, i32 }, ptr %0, i32 0, i32 0
  %offset.val = load i32, ptr %offset.cap, align 4
  %scale.cap = getelementptr inbounds { i32, i32 }, ptr %0, i32 0, i32 1
  %scale.val = load i32, ptr %scale.cap, align 4
  %multmp = mul i32 %1, %scale.val
  %addtmp = add i32 %multmp, %offset.val
  ret i32 %addtmp
}

define internal i32 @__lambda_2(ptr %0, i32 %1, i32 %2, i32 %3) {
entry:
  %offset.cap = getelementptr inbounds { i32, i32 }, ptr %0, i32 0, i32 0
  %offset.val = load i32, ptr %offset.cap, align 4
  %scale.cap = getelementptr inbounds { i32, i32 }, ptr %0, i32 0, i32 1
  %scale.val = load i32, ptr %scale.cap, align 4
  %addtmp = add i32 %1, %2
  %addtmp1 = add i32 %addtmp, %3
  ret i32 %addtmp1
}

declare void @csec_set_command_line_args(i32, ptr)

define internal i32 @__csec_jit_entry() {
entry:
  %user.main = call i32 @_main()
  ret i32 %user.main
}
