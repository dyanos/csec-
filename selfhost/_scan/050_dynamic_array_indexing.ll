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
  %array.count = zext i32 4 to i64
  %array.bytes = mul i64 %array.count, 4
  %Int = call ptr @malloc(i64 %array.bytes)
  br label %whilecond

whilecond:                                        ; preds = %whilebody, %entry
  %i.0 = phi i32 [ 0, %entry ], [ %addtmp, %whilebody ]
  %lttmp = icmp slt i32 %i.0, 4
  br i1 %lttmp, label %whilebody, label %afterwhile

whilebody:                                        ; preds = %whilecond
  %arrayelem = getelementptr i32, ptr %Int, i32 %i.0
  %arrayload = load i32, ptr %arrayelem, align 4
  %multmp = mul i32 %i.0, 10
  %arrayelem.addr = getelementptr i32, ptr %Int, i32 %i.0
  store i32 %multmp, ptr %arrayelem.addr, align 4
  %addtmp = add i32 %i.0, 1
  br label %whilecond

afterwhile:                                       ; preds = %whilecond
  %arrayelem7 = getelementptr i32, ptr %Int, i32 1
  %arrayload8 = load i32, ptr %arrayelem7, align 4
  %arrayelem.addr9 = getelementptr i32, ptr %Int, i32 1
  %assign.old = load i32, ptr %arrayelem.addr9, align 4
  %assign.next = add i32 %assign.old, 5
  store i32 %assign.next, ptr %arrayelem.addr9, align 4
  %arrayelem10 = getelementptr i32, ptr %Int, i32 3
  %arrayload11 = load i32, ptr %arrayelem10, align 4
  %arrayelem12 = getelementptr i32, ptr %Int, i32 1
  %arrayload13 = load i32, ptr %arrayelem12, align 4
  %addtmp14 = add i32 %arrayload11, %arrayload13
  %result = alloca i32, align 4
  store i32 %addtmp14, ptr %result, align 4
  %result.load = load i32, ptr %result, align 4
  ret i32 %result.load
}

declare void @csec_set_command_line_args(i32, ptr)

define internal i32 @__csec_jit_entry() {
entry:
  %user.main = call i32 @_main()
  ret i32 %user.main
}
