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

define i32 @_main() {
entry:
  br i1 true, label %then, label %else

then:                                             ; preds = %entry
  br label %ifcont

else:                                             ; preds = %entry
  br label %ifcont

ifcont:                                           ; preds = %else, %then
  %result = phi i32 [ 10, %then ], [ 20, %else ]
  %a = alloca i32, align 4
  store i32 %result, ptr %a, align 4
  br i1 false, label %then1, label %else2

then1:                                            ; preds = %ifcont
  br label %ifcont3

else2:                                            ; preds = %ifcont
  br label %ifcont3

ifcont3:                                          ; preds = %else2, %then1
  %result4 = phi i32 [ 100, %then1 ], [ 200, %else2 ]
  %b = alloca i32, align 4
  store i32 %result4, ptr %b, align 4
  br i1 true, label %then5, label %else6

then5:                                            ; preds = %ifcont3
  br label %ifcont7

else6:                                            ; preds = %ifcont3
  br label %ifcont7

ifcont7:                                          ; preds = %else6, %then5
  %result8 = phi i32 [ 1, %then5 ], [ 0, %else6 ]
  %c = alloca i32, align 4
  store i32 %result8, ptr %c, align 4
  %a.load = load i32, ptr %a, align 4
  %b.load = load i32, ptr %b, align 4
  %addtmp = add i32 %a.load, %b.load
  %c.load = load i32, ptr %c, align 4
  %addtmp9 = add i32 %addtmp, %c.load
  ret i32 %addtmp9
}

declare void @csec_set_command_line_args(i32, ptr)

define internal i32 @__csec_jit_entry() {
entry:
  %user.main = call i32 @_main()
  ret i32 %user.main
}
