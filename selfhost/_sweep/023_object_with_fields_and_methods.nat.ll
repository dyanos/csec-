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

define i32 @"MathConstants#getPi"() {
entry:
  ret i32 0
}

define i32 @"MathConstants#getE"() {
entry:
  ret i32 0
}

define i32 @"MathConstants#sum"() {
entry:
  ret i32 0
}

define i32 @"Counter#increment"() {
entry:
  ret i32 0
}

define i32 @"Counter#reset"() {
entry:
  ret i32 0
}

define i32 @_main() {
entry:
  %calltmp = call i32 @"MathConstants#sum"()
  ret i32 %calltmp
}

declare void @csec_set_command_line_args(i32, ptr)

define internal i32 @__csec_jit_entry() {
entry:
  %user.main = call i32 @_main()
  ret i32 %user.main
}
