; ModuleID = 'main'
source_filename = "main"

%ListNode = type { i32, ptr }

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

define i32 @_consume(ptr %0, ptr %1, ptr %2) {
entry:
  ret i32 0
}

define i32 @_main() {
entry:
  ret i32 0
}

define i32 @ListNode_get(ptr %this) {
entry:
  %value.field = getelementptr inbounds %ListNode, ptr %this, i32 0, i32 0
  %next.field = getelementptr inbounds %ListNode, ptr %this, i32 0, i32 1
  %value.load = load i32, ptr %value.field, align 4
  ret i32 %value.load
}

declare void @csec_set_command_line_args(i32, ptr)

define internal i32 @__csec_jit_entry() {
entry:
  %user.main = call i32 @_main()
  ret i32 %user.main
}
