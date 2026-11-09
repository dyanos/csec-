; ModuleID = 'main'
source_filename = "main"

%Point = type { i32, i32, i32, i32 }

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
  ret i32 0
}

define i32 @Point_sum(ptr %this) {
entry:
  %x.field = getelementptr inbounds %Point, ptr %this, i32 0, i32 0
  %y.field = getelementptr inbounds %Point, ptr %this, i32 0, i32 1
  %zero.field = getelementptr inbounds %Point, ptr %this, i32 0, i32 2
  %scale.field = getelementptr inbounds %Point, ptr %this, i32 0, i32 3
  %x.load = load i32, ptr %x.field, align 4
  %y.load = load i32, ptr %y.field, align 4
  %addtmp = add i32 %x.load, %y.load
  ret i32 %addtmp
}

define i32 @Point_shift(ptr %this, i32 %dx, i32 %dy) {
entry:
  %x.field = getelementptr inbounds %Point, ptr %this, i32 0, i32 0
  %y.field = getelementptr inbounds %Point, ptr %this, i32 0, i32 1
  %zero.field = getelementptr inbounds %Point, ptr %this, i32 0, i32 2
  %scale.field = getelementptr inbounds %Point, ptr %this, i32 0, i32 3
  %x.load = load i32, ptr %x.field, align 4
  %y.load = load i32, ptr %y.field, align 4
  %addtmp = add i32 %x.load, %y.load
  %addtmp1 = add i32 %addtmp, %dx
  %addtmp2 = add i32 %addtmp1, %dy
  ret i32 %addtmp2
}

declare void @csec_set_command_line_args(i32, ptr)

define internal i32 @__csec_jit_entry() {
entry:
  %user.main = call i32 @_main()
  ret i32 %user.main
}
