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

define i1 @_allEnabled() {
entry:
  %arrlit = alloca i1, i32 3, align 1
  %0 = getelementptr i1, ptr %arrlit, i32 0
  store i1 true, ptr %0, align 1
  %1 = getelementptr i1, ptr %arrlit, i32 1
  store i1 false, ptr %1, align 1
  %2 = getelementptr i1, ptr %arrlit, i32 2
  store i1 true, ptr %2, align 1
  %Boolean = call ptr @malloc(i64 2)
  %arrayelem = getelementptr i1, ptr %arrlit, i32 1
  %arrayload = load i1, ptr %arrayelem, align 1
  %arrayelem.addr = getelementptr i1, ptr %arrlit, i32 1
  store i1 true, ptr %arrayelem.addr, align 1
  %arrayelem1 = getelementptr i1, ptr %Boolean, i32 0
  %arrayload2 = load i1, ptr %arrayelem1, align 1
  %arrayelem.addr3 = getelementptr i1, ptr %Boolean, i32 0
  store i1 true, ptr %arrayelem.addr3, align 1
  %arrayelem4 = getelementptr i1, ptr %Boolean, i32 1
  %arrayload5 = load i1, ptr %arrayelem4, align 1
  %arrayelem.addr6 = getelementptr i1, ptr %Boolean, i32 1
  store i1 true, ptr %arrayelem.addr6, align 1
  %arrayelem7 = getelementptr i1, ptr %arrlit, i32 0
  %arrayload8 = load i1, ptr %arrayelem7, align 1
  br i1 %arrayload8, label %and_rhs, label %and_end

and_rhs:                                          ; preds = %entry
  %arrayelem9 = getelementptr i1, ptr %arrlit, i32 1
  %arrayload10 = load i1, ptr %arrayelem9, align 1
  br label %and_end

and_end:                                          ; preds = %and_rhs, %entry
  %and_result.0 = phi i1 [ %arrayload10, %and_rhs ], [ false, %entry ]
  br i1 %and_result.0, label %and_rhs12, label %and_end13

and_rhs12:                                        ; preds = %and_end
  %arrayelem14 = getelementptr i1, ptr %arrlit, i32 2
  %arrayload15 = load i1, ptr %arrayelem14, align 1
  br label %and_end13

and_end13:                                        ; preds = %and_rhs12, %and_end
  %and_result11.0 = phi i1 [ %arrayload15, %and_rhs12 ], [ false, %and_end ]
  br i1 %and_result11.0, label %and_rhs18, label %and_end19

and_rhs18:                                        ; preds = %and_end13
  %arrayelem20 = getelementptr i1, ptr %Boolean, i32 0
  %arrayload21 = load i1, ptr %arrayelem20, align 1
  br label %and_end19

and_end19:                                        ; preds = %and_rhs18, %and_end13
  %and_result17.0 = phi i1 [ %arrayload21, %and_rhs18 ], [ false, %and_end13 ]
  br i1 %and_result17.0, label %and_rhs24, label %and_end25

and_rhs24:                                        ; preds = %and_end19
  %arrayelem26 = getelementptr i1, ptr %Boolean, i32 1
  %arrayload27 = load i1, ptr %arrayelem26, align 1
  br label %and_end25

and_end25:                                        ; preds = %and_rhs24, %and_end19
  %and_result23.0 = phi i1 [ %arrayload27, %and_rhs24 ], [ false, %and_end19 ]
  ret i1 %and_result23.0
}

define i32 @_main() {
entry:
  %calltmp = call i1 @_allEnabled()
  br i1 %calltmp, label %then, label %ifcont

then:                                             ; preds = %entry
  ret i32 0

ifcont:                                           ; preds = %entry
  ret i32 1
}

declare void @csec_set_command_line_args(i32, ptr)

define internal i32 @__csec_jit_entry() {
entry:
  %user.main = call i32 @_main()
  ret i32 %user.main
}
