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

define i32 @_observe(ptr %0) {
entry:
  ret i32 2
}

define i32 @_update(ptr %0) {
entry:
  ret i32 3
}

define i32 @Image_id(ptr %this) {
entry:
  ret i32 0
}

define i32 @_main() {
entry:
  %newobj.malloc = call ptr @malloc(i64 0)
  %newobj.malloc1 = call ptr @malloc(i64 0)
  %count = alloca i32, align 4
  store i32 7, ptr %count, align 4
  store ptr %newobj.malloc, ptr %newobj.malloc1, align 8
  %calltmp = call i32 @_take(ptr %newobj.malloc1)
  %count.load = load i32, ptr %count, align 4
  %calltmp2 = call i32 @_observe(ptr %count)
  %count.load3 = load i32, ptr %count, align 4
  %calltmp4 = call i32 @_update(ptr %count)
  %addtmp = add i32 %calltmp, %calltmp2
  %addtmp5 = add i32 %addtmp, %calltmp4
  call void @free(ptr %newobj.malloc1)
  call void @free(ptr %newobj.malloc)
  ret i32 %addtmp5
}

declare void @csec_set_command_line_args(i32, ptr)

define internal i32 @__csec_jit_entry() {
entry:
  %user.main = call i32 @_main()
  ret i32 %user.main
}
