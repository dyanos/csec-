; ModuleID = 'main'
source_filename = "main"

@pi = private constant i32 3
@e = private constant i32 2
@phi = private constant i32 1
@count = private global i32 0

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
  %calltmp = call i32 @"MathConstants#sum"()
  ret i32 %calltmp
}

define i32 @"MathConstants#getPi"() {
entry:
  %pi.load = load i32, ptr @pi, align 4
  ret i32 %pi.load
}

define i32 @"MathConstants#getE"() {
entry:
  %e.load = load i32, ptr @e, align 4
  ret i32 %e.load
}

define i32 @"MathConstants#sum"() {
entry:
  %pi.load = load i32, ptr @pi, align 4
  %e.load = load i32, ptr @e, align 4
  %addtmp = add i32 %pi.load, %e.load
  %phi.load = load i32, ptr @phi, align 4
  %addtmp1 = add i32 %addtmp, %phi.load
  ret i32 %addtmp1
}

define i32 @"Counter#increment"() {
entry:
  %count.load = load i32, ptr @count, align 4
  %count.load1 = load i32, ptr @count, align 4
  %addtmp = add i32 %count.load1, 1
  store i32 %addtmp, ptr @count, align 4
  %count.load2 = load i32, ptr @count, align 4
  ret i32 %count.load2
}

define i32 @"Counter#reset"() {
entry:
  %count.load = load i32, ptr @count, align 4
  store i32 0, ptr @count, align 4
  %count.load1 = load i32, ptr @count, align 4
  ret i32 %count.load1
}

declare void @csec_set_command_line_args(i32, ptr)

define internal i32 @__csec_jit_entry() {
entry:
  %user.main = call i32 @_main()
  ret i32 %user.main
}
