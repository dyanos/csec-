; ModuleID = 'main'
source_filename = "main"

%"\EB\B2\A1\ED\84\B0" = type { i32 }

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

define i32 @"_\EB\A9\B4\EC\A0\81\EA\B3\84\EC\82\B0"(i32 %0) {
entry:
  %multmp = mul i32 %0, %0
  %multmp1 = mul i32 %multmp, 3
  ret i32 %multmp1
}

define i32 @_main() {
entry:
  %calltmp = call i32 @"_\EB\A9\B4\EC\A0\81\EA\B3\84\EC\82\B0"(i32 5)
  %newobj.malloc = call ptr @malloc(i64 4)
  %"\ED\81\AC\EA\B8\B0.init" = getelementptr inbounds %"\EB\B2\A1\ED\84\B0", ptr %newobj.malloc, i32 0, i32 0
  store i32 3, ptr %"\ED\81\AC\EA\B8\B0.init", align 4
  %calltmp1 = call i32 @"\EC\88\98\ED\95\99\EC\83\81\EC\88\98#\ED\8C\8C\EC\9D\B4"()
  %addtmp = add i32 %calltmp, %calltmp1
  ret i32 %addtmp
}

define i32 @"\EB\B2\A1\ED\84\B0_\EB\85\B8\EB\A6\84"(ptr %this) {
entry:
  %"\ED\81\AC\EA\B8\B0.field" = getelementptr inbounds %"\EB\B2\A1\ED\84\B0", ptr %this, i32 0, i32 0
  %"\ED\81\AC\EA\B8\B0.load" = load i32, ptr %"\ED\81\AC\EA\B8\B0.field", align 4
  %i_ptr = alloca i32, align 4
  store i32 1, ptr %i_ptr, align 4
  br label %forcond

forcond:                                          ; preds = %loop, %entry
  %i = load i32, ptr %i_ptr, align 4
  %cond = icmp sle i32 %i, %"\ED\81\AC\EA\B8\B0.load"
  br i1 %cond, label %loop, label %afterloop

loop:                                             ; preds = %forcond
  %i.load = load float, ptr %i_ptr, align 4
  %i1 = load i32, ptr %i_ptr, align 4
  %next_i = add i32 %i1, 1
  store i32 %next_i, ptr %i_ptr, align 4
  br label %forcond

afterloop:                                        ; preds = %forcond
  %"\ED\81\AC\EA\B8\B0.load2" = load i32, ptr %"\ED\81\AC\EA\B8\B0.field", align 4
  ret i32 %"\ED\81\AC\EA\B8\B0.load2"
}

define i32 @"\EC\88\98\ED\95\99\EC\83\81\EC\88\98#\ED\8C\8C\EC\9D\B4"() {
entry:
  ret i32 3
}

define i32 @"\EC\88\98\ED\95\99\EC\83\81\EC\88\98#\EC\98\A4\EC\9D\BC\EB\9F\AC"() {
entry:
  ret i32 2
}

declare void @csec_set_command_line_args(i32, ptr)

define internal i32 @__csec_jit_entry() {
entry:
  %user.main = call i32 @_main()
  ret i32 %user.main
}
