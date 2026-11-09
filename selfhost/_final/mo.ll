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

define { ptr, ptr } @_make() {
entry:
  %box.malloc = call ptr @malloc(i64 4)
  store i32 10, ptr %box.malloc, align 4
  %box.malloc1 = call ptr @malloc(i64 4)
  store i32 20, ptr %box.malloc1, align 4
  %tuple.elt = insertvalue { ptr, ptr } undef, ptr %box.malloc, 0
  %tuple.elt2 = insertvalue { ptr, ptr } %tuple.elt, ptr %box.malloc1, 1
  call void @free(ptr %box.malloc1)
  call void @free(ptr %box.malloc)
  ret { ptr, ptr } %tuple.elt2
}

define i32 @_main() {
entry:
  %calltmp = call { ptr, ptr } @_make()
  %destr.elt = extractvalue { ptr, ptr } %calltmp, 0
  %destr.elt1 = extractvalue { ptr, ptr } %calltmp, 1
  %calltmp2 = call i32 @_take(ptr %destr.elt)
  %calltmp3 = call i32 @_take(ptr %destr.elt1)
  %addtmp = add i32 %calltmp2, %calltmp3
  ret i32 %addtmp
}

declare void @csec_set_command_line_args(i32, ptr)

define internal i32 @__csec_jit_entry() {
entry:
  %user.main = call i32 @_main()
  ret i32 %user.main
}
