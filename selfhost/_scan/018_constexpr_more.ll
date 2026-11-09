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
define i32 @_double(i32 %0) #0 {
entry:
  %addtmp = add i32 %0, %0
  ret i32 %addtmp
}

; Function Attrs: alwaysinline
define i32 @_square(i32 %0) #0 {
entry:
  %multmp = mul i32 %0, %0
  ret i32 %multmp
}

; Function Attrs: alwaysinline
define i32 @_cube(i32 %0) #0 {
entry:
  %multmp = mul i32 %0, %0
  %multmp1 = mul i32 %multmp, %0
  ret i32 %multmp1
}

; Function Attrs: alwaysinline
define i1 @_isPositive(i32 %0) #0 {
entry:
  %gttmp = icmp sgt i32 %0, 0
  br i1 %gttmp, label %then, label %else

then:                                             ; preds = %entry
  ret i1 true

else:                                             ; preds = %entry
  ret i1 false

ifcont:                                           ; No predecessors!
  ret i1 false
}

define i32 @_main() {
entry:
  %calltmp = call i32 @_double(i32 5)
  %calltmp1 = call i32 @_square(i32 4)
  %calltmp2 = call i32 @_cube(i32 3)
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
