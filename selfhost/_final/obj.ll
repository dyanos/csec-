; ModuleID = 'main'
source_filename = "main"

@v = private constant i32 7

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
  %calltmp = call i32 @"Cfg#get"()
  %calltmp1 = call i32 @"Cfg#getBlock"()
  %addtmp = add i32 %calltmp, %calltmp1
  ret i32 %addtmp
}

define i32 @"Cfg#get"() {
entry:
  %v.load = load i32, ptr @v, align 4
  ret i32 %v.load
}

define i32 @"Cfg#getBlock"() {
entry:
  %v.load = load i32, ptr @v, align 4
  ret i32 %v.load
}

declare void @csec_set_command_line_args(i32, ptr)

define internal i32 @__csec_jit_entry() {
entry:
  %user.main = call i32 @_main()
  ret i32 %user.main
}
