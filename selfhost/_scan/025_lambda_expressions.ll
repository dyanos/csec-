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
  %lambda.env5 = alloca {}, align 8
  %lambda.closure6 = alloca { ptr, ptr }, align 8
  %closure.code7 = getelementptr inbounds { ptr, ptr }, ptr %lambda.closure6, i32 0, i32 0
  store ptr @__lambda_2, ptr %closure.code7, align 8
  %closure.env8 = getelementptr inbounds { ptr, ptr }, ptr %lambda.closure6, i32 0, i32 1
  store ptr %lambda.env5, ptr %closure.env8, align 8
  ret i32 0
}

define internal i32 @__lambda_0(ptr %0, i32 %1) {
entry:
  %addtmp = add i32 %1, 1
  ret i32 %addtmp
}

define internal i32 @__lambda_1(ptr %0, i32 %1) {
entry:
  %num.sitofp = sitofp i32 %1 to double
  %faddtmp = fadd double %num.sitofp, 0.000000e+00
  %faddtmp1 = fadd double %faddtmp, 0.000000e+00
  %abi.fptosi = fptosi double %faddtmp1 to i32
  ret i32 %abi.fptosi
}

define internal i32 @__lambda_2(ptr %0, i32 %1) {
entry:
  ret i32 %1
}

declare void @csec_set_command_line_args(i32, ptr)

define internal i32 @__csec_jit_entry() {
entry:
  %user.main = call i32 @_main()
  ret i32 %user.main
}
