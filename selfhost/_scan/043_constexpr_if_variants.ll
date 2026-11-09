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

; Function Attrs: alwaysinline
define i32 @_selectA(i1 %0) #0 {
entry:
  br i1 %0, label %then, label %else

then:                                             ; preds = %entry
  ret i32 10

else:                                             ; preds = %entry
  ret i32 20

ifcont:                                           ; No predecessors!
  ret i32 0
}

; Function Attrs: alwaysinline
define i32 @_selectB(i1 %0) #0 {
entry:
  br i1 %0, label %then, label %else

then:                                             ; preds = %entry
  ret i32 1

else:                                             ; preds = %entry
  ret i32 0

ifcont:                                           ; No predecessors!
  ret i32 0
}

define i32 @_main() {
entry:
  %calltmp = call i32 @_selectA(i1 true)
  %calltmp1 = call i32 @_selectA(i1 false)
  %calltmp2 = call i32 @_selectB(i1 true)
  %addtmp = add i32 %calltmp, %calltmp1
  %addtmp3 = add i32 %addtmp, %calltmp2
  ret i32 %addtmp3
}

declare void @csec_set_command_line_args(i32, ptr)

define internal i32 @__csec_jit_entry() {
entry:
  %user.main = call i32 @_main()
  ret i32 %user.main
}

attributes #0 = { alwaysinline }
