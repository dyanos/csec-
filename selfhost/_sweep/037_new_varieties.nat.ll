; ModuleID = 'main'
source_filename = "main"

%Point = type { i32, i32 }
%Node = type { i32 }

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

define i32 @Point_sum(ptr %this) {
entry:
  %x.field = getelementptr inbounds %Point, ptr %this, i32 0, i32 0
  %y.field = getelementptr inbounds %Point, ptr %this, i32 0, i32 1
  %x.load = load i32, ptr %x.field, align 4
  %y.load = load i32, ptr %y.field, align 4
  %addtmp = add i32 %x.load, %y.load
  ret i32 %addtmp
}

define i32 @Node_get(ptr %this) {
entry:
  %value.field = getelementptr inbounds %Node, ptr %this, i32 0, i32 0
  %value.load = load i32, ptr %value.field, align 4
  ret i32 %value.load
}

define i32 @Empty_zero(ptr %this) {
entry:
  ret i32 0
}

define i32 @_main() {
entry:
  %newobj.malloc = call ptr @malloc(i64 8)
  %x.init = getelementptr inbounds %Point, ptr %newobj.malloc, i32 0, i32 0
  store i32 3, ptr %x.init, align 4
  %y.init = getelementptr inbounds %Point, ptr %newobj.malloc, i32 0, i32 1
  store i32 4, ptr %y.init, align 4
  %newobj.malloc1 = call ptr @malloc(i64 0)
  %newobj.malloc2 = call ptr @malloc(i64 0)
  %newobj.malloc4 = call ptr @malloc(i64 4)
  %value.init = getelementptr inbounds %Node, ptr %newobj.malloc4, i32 0, i32 0
  store i32 1, ptr %value.init, align 4
  %newobj.malloc5 = call ptr @malloc(i64 4)
  %value.init6 = getelementptr inbounds %Node, ptr %newobj.malloc5, i32 0, i32 0
  store i32 2, ptr %value.init6, align 4
  %newobj.malloc7 = call ptr @malloc(i64 4)
  %value.init8 = getelementptr inbounds %Node, ptr %newobj.malloc7, i32 0, i32 0
  store i32 3, ptr %value.init8, align 4
  ret i32 0
}

declare void @csec_set_command_line_args(i32, ptr)

define internal i32 @__csec_jit_entry() {
entry:
  %user.main = call i32 @_main()
  ret i32 %user.main
}
