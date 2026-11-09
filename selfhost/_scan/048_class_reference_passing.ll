; ModuleID = 'main'
source_filename = "main"

%Image = type { i32 }

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

define i32 @_view(ptr %0) {
entry:
  %calltmp = call i32 @Image_get(ptr %0)
  ret i32 %calltmp
}

define i32 @_main() {
entry:
  %newobj.malloc = call ptr @malloc(i64 4)
  %id.init = getelementptr inbounds %Image, ptr %newobj.malloc, i32 0, i32 0
  store i32 7, ptr %id.init, align 4
  %calltmp = call i32 @_view(ptr %newobj.malloc)
  %calltmp1 = call i32 @Image_get(ptr %newobj.malloc)
  %addtmp = add i32 %calltmp, %calltmp1
  ret i32 %addtmp
}

define i32 @Image_get(ptr %this) {
entry:
  %id.field = getelementptr inbounds %Image, ptr %this, i32 0, i32 0
  %id.load = load i32, ptr %id.field, align 4
  ret i32 %id.load
}

declare void @csec_set_command_line_args(i32, ptr)

define internal i32 @__csec_jit_entry() {
entry:
  %user.main = call i32 @_main()
  ret i32 %user.main
}
