; ModuleID = 'main'
source_filename = "main"

%"\EC\A0\90" = type { i32, i32 }

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
  %newobj.malloc = call ptr @malloc(i64 8)
  %"x\EC\A2\8C\ED\91\9C.init" = getelementptr inbounds %"\EC\A0\90", ptr %newobj.malloc, i32 0, i32 0
  store i32 3, ptr %"x\EC\A2\8C\ED\91\9C.init", align 4
  %"y\EC\A2\8C\ED\91\9C.init" = getelementptr inbounds %"\EC\A0\90", ptr %newobj.malloc, i32 0, i32 1
  store i32 4, ptr %"y\EC\A2\8C\ED\91\9C.init", align 4
  %calltmp = call i32 @"\EC\A0\90_\EA\B1\B0\EB\A6\AC"(ptr %newobj.malloc)
  %calltmp1 = call i32 @"\EC\88\98\ED\95\99\EB\8F\84\EA\B5\AC#\EB\8D\94\ED\95\98\EA\B8\B0"(i32 10, i32 20)
  %addtmp = add i32 %calltmp, %calltmp1
  ret i32 %addtmp
}

define i32 @"\EC\A0\90_\EA\B1\B0\EB\A6\AC"(ptr %this) {
entry:
  %"x\EC\A2\8C\ED\91\9C.field" = getelementptr inbounds %"\EC\A0\90", ptr %this, i32 0, i32 0
  %"y\EC\A2\8C\ED\91\9C.field" = getelementptr inbounds %"\EC\A0\90", ptr %this, i32 0, i32 1
  %"x\EC\A2\8C\ED\91\9C.load" = load i32, ptr %"x\EC\A2\8C\ED\91\9C.field", align 4
  %"x\EC\A2\8C\ED\91\9C.load1" = load i32, ptr %"x\EC\A2\8C\ED\91\9C.field", align 4
  %multmp = mul i32 %"x\EC\A2\8C\ED\91\9C.load", %"x\EC\A2\8C\ED\91\9C.load1"
  %"y\EC\A2\8C\ED\91\9C.load" = load i32, ptr %"y\EC\A2\8C\ED\91\9C.field", align 4
  %"y\EC\A2\8C\ED\91\9C.load2" = load i32, ptr %"y\EC\A2\8C\ED\91\9C.field", align 4
  %multmp3 = mul i32 %"y\EC\A2\8C\ED\91\9C.load", %"y\EC\A2\8C\ED\91\9C.load2"
  %addtmp = add i32 %multmp, %multmp3
  ret i32 %addtmp
}

define i32 @"\EC\88\98\ED\95\99\EB\8F\84\EA\B5\AC#\EB\8D\94\ED\95\98\EA\B8\B0"(i32 %0, i32 %1) {
entry:
  %addtmp = add i32 %0, %1
  ret i32 %addtmp
}

define i32 @"\EC\88\98\ED\95\99\EB\8F\84\EA\B5\AC#\EA\B3\B1\ED\95\98\EA\B8\B0"(i32 %0, i32 %1) {
entry:
  %multmp = mul i32 %0, %1
  ret i32 %multmp
}

declare void @csec_set_command_line_args(i32, ptr)

define internal i32 @__csec_jit_entry() {
entry:
  %user.main = call i32 @_main()
  ret i32 %user.main
}
