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

define { i32, i32 } @_load() {
entry:
  ret { i32, i32 } { i32 20, i32 22 }
}

define i32 @_main() {
entry:
  %calltmp = call { i32, i32 } @_load()
  %destr.elt = extractvalue { i32, i32 } %calltmp, 0
  %destr.elt1 = extractvalue { i32, i32 } %calltmp, 1
  %addtmp = add i32 %destr.elt, %destr.elt1
  ret i32 %addtmp
}

declare void @csec_set_command_line_args(i32, ptr)

define internal i32 @__csec_jit_entry() {
entry:
  %user.main = call i32 @_main()
  ret i32 %user.main
}
