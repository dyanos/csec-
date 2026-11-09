; ModuleID = 'main'
source_filename = "main"

%Counter = type { i32 }

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
  %newobj.malloc = call ptr @malloc(i64 4)
  %seed.init = getelementptr inbounds %Counter, ptr %newobj.malloc, i32 0, i32 0
  store i32 10, ptr %seed.init, align 4
  %calltmp = call i32 @"MathOps#twice"(i32 3)
  %calltmp1 = call i32 @Counter_inc(ptr %newobj.malloc, i32 5)
  %addtmp = add i32 %calltmp, %calltmp1
  ret i32 %addtmp
}

define i32 @"MathOps#twice"(i32 %0) {
entry:
  %addtmp = add i32 %0, %0
  ret i32 %addtmp
}

define i32 @Counter_inc(ptr %this, i32 %x) {
entry:
  %seed.field = getelementptr inbounds %Counter, ptr %this, i32 0, i32 0
  %seed.load = load i32, ptr %seed.field, align 4
  %addtmp = add i32 %seed.load, %x
  ret i32 %addtmp
}

declare void @csec_set_command_line_args(i32, ptr)

define internal i32 @__csec_jit_entry() {
entry:
  %user.main = call i32 @_main()
  ret i32 %user.main
}
