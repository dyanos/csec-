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

define i32 @_take(ptr %0) {
entry:
  ret i32 1
}

define i32 @_main() {
entry:
  %box.malloc = call ptr @malloc(i64 4)
  store i32 20, ptr %box.malloc, align 4
  %clone.malloc = call ptr @malloc(i64 4)
  call void @llvm.memcpy.p0.p0.i64(ptr %clone.malloc, ptr %box.malloc, i64 4, i1 false)
  %calltmp = call i32 @_take(ptr %box.malloc)
  %calltmp1 = call i32 @_take(ptr %clone.malloc)
  %addtmp = add i32 %calltmp, %calltmp1
  call void @free(ptr %clone.malloc)
  call void @free(ptr %box.malloc)
  ret i32 %addtmp
}

; Function Attrs: nocallback nofree nounwind willreturn memory(argmem: readwrite)
declare void @llvm.memcpy.p0.p0.i64(ptr noalias nocapture writeonly, ptr noalias nocapture readonly, i64, i1 immarg) #0

declare void @csec_set_command_line_args(i32, ptr)

define internal i32 @__csec_jit_entry() {
entry:
  %user.main = call i32 @_main()
  ret i32 %user.main
}

attributes #0 = { nocallback nofree nounwind willreturn memory(argmem: readwrite) }
