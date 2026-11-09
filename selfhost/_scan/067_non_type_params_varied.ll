; ModuleID = 'main'
source_filename = "main"

%"Matrix2D$Double$3$4" = type { double }
%"Matrix2D$Double$3$4.0" = type { double }

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

define i32 @"Matrix2D$Double$3$4_rows"(ptr %this) {
entry:
  %fill.field = getelementptr inbounds %"Matrix2D$Double$3$4", ptr %this, i32 0, i32 0
  ret i32 3
}

define i32 @"Matrix2D$Double$3$4_cols"(ptr %this) {
entry:
  %fill.field = getelementptr inbounds %"Matrix2D$Double$3$4", ptr %this, i32 0, i32 0
  ret i32 4
}

define i32 @"Matrix2D$Double$3$4_total"(ptr %this) {
entry:
  %fill.field = getelementptr inbounds %"Matrix2D$Double$3$4", ptr %this, i32 0, i32 0
  ret i32 12
}

define i32 @_main() {
entry:
  %calltmp = call i32 @"_repeatSum$Int$5"()
  %newobj.malloc = call ptr @malloc(i64 8)
  %fill.init = getelementptr inbounds %"Matrix2D$Double$3$4.0", ptr %newobj.malloc, i32 0, i32 0
  store double 0.000000e+00, ptr %fill.init, align 8
  %calltmp1 = call i32 @"Matrix2D$Double$3$4_rows.1"(ptr %newobj.malloc)
  %calltmp2 = call i32 @"Matrix2D$Double$3$4_cols.2"(ptr %newobj.malloc)
  %calltmp3 = call i32 @"Matrix2D$Double$3$4_total.3"(ptr %newobj.malloc)
  %calltmp4 = call i32 @"_bufferSize$128"()
  %addtmp = add i32 %calltmp, %calltmp1
  %addtmp5 = add i32 %addtmp, %calltmp2
  %addtmp6 = add i32 %addtmp5, %calltmp3
  %addtmp7 = add i32 %addtmp6, %calltmp4
  ret i32 %addtmp7
}

define i32 @"_repeatSum$Int$5"() {
entry:
  ret i32 10
}

define i32 @"Matrix2D$Double$3$4_rows.1"(ptr %this) {
entry:
  %fill.field = getelementptr inbounds %"Matrix2D$Double$3$4.0", ptr %this, i32 0, i32 0
  ret i32 3
}

define i32 @"Matrix2D$Double$3$4_cols.2"(ptr %this) {
entry:
  %fill.field = getelementptr inbounds %"Matrix2D$Double$3$4.0", ptr %this, i32 0, i32 0
  ret i32 4
}

define i32 @"Matrix2D$Double$3$4_total.3"(ptr %this) {
entry:
  %fill.field = getelementptr inbounds %"Matrix2D$Double$3$4.0", ptr %this, i32 0, i32 0
  ret i32 12
}

define i32 @"_bufferSize$128"() {
entry:
  ret i32 256
}

declare void @csec_set_command_line_args(i32, ptr)

define internal i32 @__csec_jit_entry() {
entry:
  %user.main = call i32 @_main()
  ret i32 %user.main
}
