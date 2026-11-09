; ModuleID = 'main'
source_filename = "main"

@0 = private unnamed_addr constant [6 x i8] c"hello\00", align 1
@1 = private unnamed_addr constant [6 x i8] c"hello\00", align 1
@2 = private unnamed_addr constant [6 x i8] c"world\00", align 1

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

define i1 @_isHello(ptr %0) {
entry:
  %eqtmp = icmp eq ptr %0, @0
  ret i1 %eqtmp
}

define i32 @_main() {
entry:
  %calltmp = call i1 @_isHello(ptr @1)
  br i1 %calltmp, label %and_rhs, label %and_end

and_rhs:                                          ; preds = %entry
  %netmp = icmp ne ptr @1, @2
  br label %and_end

and_end:                                          ; preds = %and_rhs, %entry
  %and_result.0 = phi i1 [ %netmp, %and_rhs ], [ false, %entry ]
  br i1 %and_result.0, label %then, label %ifcont

then:                                             ; preds = %and_end
  ret i32 42

ifcont:                                           ; preds = %and_end
  ret i32 0
}

declare void @csec_set_command_line_args(i32, ptr)

define internal i32 @__csec_jit_entry() {
entry:
  %user.main = call i32 @_main()
  ret i32 %user.main
}
