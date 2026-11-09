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
  br i1 true, label %and_rhs, label %and_end

and_rhs:                                          ; preds = %entry
  br label %and_end

and_end:                                          ; preds = %and_rhs, %entry
  %and_result.0 = phi i1 [ true, %and_rhs ], [ false, %entry ]
  br i1 %and_result.0, label %or_end, label %or_rhs

or_rhs:                                           ; preds = %and_end
  %xortmp = xor i1 true, true
  br label %or_end

or_end:                                           ; preds = %or_rhs, %and_end
  %or_result.0 = phi i1 [ true, %and_end ], [ %xortmp, %or_rhs ]
  %logic = alloca i1, align 1
  store i1 %or_result.0, ptr %logic, align 1
  %bits = alloca i32, align 4
  store i32 8, ptr %bits, align 4
  %bits.load = load i32, ptr %bits, align 4
  %bits.load1 = load i32, ptr %bits, align 4
  %ortmp = or i32 %bits.load1, 2
  store i32 %ortmp, ptr %bits, align 4
  %bits.load2 = load i32, ptr %bits, align 4
  %bits.load3 = load i32, ptr %bits, align 4
  %andtmp = and i32 %bits.load3, 15
  store i32 %andtmp, ptr %bits, align 4
  %bits.load4 = load i32, ptr %bits, align 4
  %bits.load5 = load i32, ptr %bits, align 4
  %xortmp6 = xor i32 %bits.load5, 7
  store i32 %xortmp6, ptr %bits, align 4
  %bits.load7 = load i32, ptr %bits, align 4
  ret i32 %bits.load7
}

declare void @csec_set_command_line_args(i32, ptr)

define internal i32 @__csec_jit_entry() {
entry:
  %user.main = call i32 @_main()
  ret i32 %user.main
}
