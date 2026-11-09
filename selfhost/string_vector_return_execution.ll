; ModuleID = 'main'
source_filename = "main"

@0 = private unnamed_addr constant [5 x i8] c"left\00", align 1
@1 = private unnamed_addr constant [6 x i8] c"right\00", align 1

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

define ptr @_identity(ptr %0) {
entry:
  ret ptr %0
}

define i32 @_main() {
entry:
  %String = alloca ptr, i32 2, align 8
  %arrayelem = getelementptr ptr, ptr %String, i32 0
  %arrayload = load ptr, ptr %arrayelem, align 8
  %arrayelem.addr = getelementptr ptr, ptr %String, i32 0
  store ptr @0, ptr %arrayelem.addr, align 8
  %arrayelem1 = getelementptr ptr, ptr %String, i32 1
  %arrayload2 = load ptr, ptr %arrayelem1, align 8
  %arrayelem.addr3 = getelementptr ptr, ptr %String, i32 1
  store ptr @1, ptr %arrayelem.addr3, align 8
  %calltmp = call ptr @_identity(ptr %String)
  %arrayelem4 = getelementptr ptr, ptr %calltmp, i32 1
  %arrayload5 = load ptr, ptr %arrayelem4, align 8
  %str.length = call i64 @csec_string_length(ptr %arrayload5)
  %eqtmp = icmp eq i64 %str.length, 5
  %ifcond = icmp ne i1 %eqtmp, false
  br i1 %ifcond, label %then, label %ifcont

then:                                             ; preds = %entry
  ret i32 0

ifcont:                                           ; preds = %entry
  ret i32 1
}

declare i64 @csec_string_length(ptr)

declare void @csec_set_command_line_args(i32, ptr)

define internal i32 @__csec_jit_entry() {
entry:
  %user.main = call i32 @_main()
  ret i32 %user.main
}
