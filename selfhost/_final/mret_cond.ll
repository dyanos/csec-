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

define { i32, i32 } @_f() {
entry:
  ret { i32, i32 } { i32 10, i32 20 }
}

define { i32, i32 } @_g() {
entry:
  ret { i32, i32 } { i32 5, i32 7 }
}

define i32 @_main() {
entry:
  br i1 true, label %then, label %else

then:                                             ; preds = %entry
  %calltmp = call { i32, i32 } @_f()
  br label %ifcont

else:                                             ; preds = %entry
  %calltmp1 = call { i32, i32 } @_g()
  br label %ifcont

ifcont:                                           ; preds = %else, %then
  %result = phi { i32, i32 } [ %calltmp, %then ], [ %calltmp1, %else ]
  %destr.elt = extractvalue { i32, i32 } %result, 0
  %a = alloca i32, align 4
  store i32 %destr.elt, ptr %a, align 4
  %destr.elt2 = extractvalue { i32, i32 } %result, 1
  %b = alloca i32, align 4
  store i32 %destr.elt2, ptr %b, align 4
  %a.load = load i32, ptr %a, align 4
  %b.load = load i32, ptr %b, align 4
  %addtmp = add i32 %a.load, %b.load
  ret i32 %addtmp
}

declare void @csec_set_command_line_args(i32, ptr)

define internal i32 @__csec_jit_entry() {
entry:
  %user.main = call i32 @_main()
  ret i32 %user.main
}
