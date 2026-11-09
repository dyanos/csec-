; ModuleID = 'main'
source_filename = "main"

%Node = type { i32, ptr }
%List = type { ptr, i32 }

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
  %newobj.malloc = call ptr @malloc(i64 16)
  %value.init = getelementptr inbounds %Node, ptr %newobj.malloc, i32 0, i32 0
  store i32 10, ptr %value.init, align 4
  %newobj.malloc1 = call ptr @malloc(i64 16)
  %next.init = getelementptr inbounds %Node, ptr %newobj.malloc, i32 0, i32 1
  store ptr null, ptr %next.init, align 8
  %newobj.malloc2 = call ptr @malloc(i64 16)
  %value.init3 = getelementptr inbounds %Node, ptr %newobj.malloc2, i32 0, i32 0
  store i32 20, ptr %value.init3, align 4
  %newobj.malloc4 = call ptr @malloc(i64 16)
  %next.init5 = getelementptr inbounds %Node, ptr %newobj.malloc2, i32 0, i32 1
  store ptr null, ptr %next.init5, align 8
  %newobj.malloc6 = call ptr @malloc(i64 16)
  %value.init7 = getelementptr inbounds %Node, ptr %newobj.malloc6, i32 0, i32 0
  store i32 30, ptr %value.init7, align 4
  %newobj.malloc8 = call ptr @malloc(i64 16)
  %next.init9 = getelementptr inbounds %Node, ptr %newobj.malloc6, i32 0, i32 1
  store ptr null, ptr %next.init9, align 8
  %newobj.malloc10 = call ptr @malloc(i64 16)
  %head.init = getelementptr inbounds %List, ptr %newobj.malloc10, i32 0, i32 0
  store ptr %newobj.malloc, ptr %head.init, align 8
  %size.init = getelementptr inbounds %List, ptr %newobj.malloc10, i32 0, i32 1
  store i32 1, ptr %size.init, align 4
  %calltmp = call i32 @List_getSize(ptr %newobj.malloc10)
  ret i32 %calltmp
}

define i32 @Node_getValue(ptr %this) {
entry:
  %value.field = getelementptr inbounds %Node, ptr %this, i32 0, i32 0
  %next.field = getelementptr inbounds %Node, ptr %this, i32 0, i32 1
  %value.load = load i32, ptr %value.field, align 4
  ret i32 %value.load
}

define i32 @List_getSize(ptr %this) {
entry:
  %head.field = getelementptr inbounds %List, ptr %this, i32 0, i32 0
  %size.field = getelementptr inbounds %List, ptr %this, i32 0, i32 1
  %size.load = load i32, ptr %size.field, align 4
  ret i32 %size.load
}

define ptr @List_getHead(ptr %this) {
entry:
  %head.field = getelementptr inbounds %List, ptr %this, i32 0, i32 0
  %size.field = getelementptr inbounds %List, ptr %this, i32 0, i32 1
  %head.load = load ptr, ptr %head.field, align 8
  ret ptr %head.load
}

declare void @csec_set_command_line_args(i32, ptr)

define internal i32 @__csec_jit_entry() {
entry:
  %user.main = call i32 @_main()
  ret i32 %user.main
}
