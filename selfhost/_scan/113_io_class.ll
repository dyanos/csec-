; ModuleID = 'main'
source_filename = "main"

@0 = private unnamed_addr constant [7 x i8] c"value=\00", align 1
@1 = private unnamed_addr constant [2 x i8] c" \00", align 1
@2 = private unnamed_addr constant [2 x i8] c" \00", align 1
@3 = private unnamed_addr constant [5 x i8] c"done\00", align 1

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
  %newobj.malloc = call ptr @malloc(i64 0)
  call void @InOut_writeString(ptr %newobj.malloc, ptr @0)
  call void @InOut_writeInt(ptr %newobj.malloc, i32 42)
  call void @InOut_writeString(ptr %newobj.malloc, ptr @1)
  call void @InOut_writeFloat(ptr %newobj.malloc, float 3.500000e+00)
  call void @InOut_writeString(ptr %newobj.malloc, ptr @2)
  call void @InOut_writeBool(ptr %newobj.malloc, i1 true)
  call void @InOut_newLine(ptr %newobj.malloc)
  call void @InOut_writeLineString(ptr %newobj.malloc, ptr @3)
  ret i32 0
}

define void @InOut_writeString(ptr %this, ptr %value) {
entry:
  call void @csec_print_string(ptr %value)
  ret void
}

define void @InOut_writeInt(ptr %this, i32 %value) {
entry:
  %math.sext = sext i32 %value to i64
  call void @csec_print_i64(i64 %math.sext)
  ret void
}

define void @InOut_writeLong(ptr %this, i64 %value) {
entry:
  call void @csec_print_i64(i64 %value)
  ret void
}

define void @InOut_writeFloat(ptr %this, float %value) {
entry:
  %math.fpext = fpext float %value to double
  call void @csec_print_double(double %math.fpext)
  ret void
}

define void @InOut_writeDouble(ptr %this, double %value) {
entry:
  call void @csec_print_double(double %value)
  ret void
}

define void @InOut_writeBool(ptr %this, i1 %value) {
entry:
  %print.bool = zext i1 %value to i32
  call void @csec_print_bool(i32 %print.bool)
  ret void
}

define void @InOut_writeChar(ptr %this, i8 %value) {
entry:
  call void @csec_print_char(i8 %value)
  ret void
}

define void @InOut_newLine(ptr %this) {
entry:
  call void @csec_print_newline()
  ret void
}

define void @InOut_writeLineString(ptr %this, ptr %value) {
entry:
  call void @csec_print_string(ptr %value)
  call void @csec_print_newline()
  ret void
}

define void @InOut_writeLineInt(ptr %this, i32 %value) {
entry:
  %math.sext = sext i32 %value to i64
  call void @csec_print_i64(i64 %math.sext)
  call void @csec_print_newline()
  ret void
}

define void @InOut_writeLineLong(ptr %this, i64 %value) {
entry:
  call void @csec_print_i64(i64 %value)
  call void @csec_print_newline()
  ret void
}

define void @InOut_writeLineFloat(ptr %this, float %value) {
entry:
  %math.fpext = fpext float %value to double
  call void @csec_print_double(double %math.fpext)
  call void @csec_print_newline()
  ret void
}

define void @InOut_writeLineDouble(ptr %this, double %value) {
entry:
  call void @csec_print_double(double %value)
  call void @csec_print_newline()
  ret void
}

define void @InOut_writeLineBool(ptr %this, i1 %value) {
entry:
  %print.bool = zext i1 %value to i32
  call void @csec_print_bool(i32 %print.bool)
  call void @csec_print_newline()
  ret void
}

define void @InOut_writeLineChar(ptr %this, i8 %value) {
entry:
  call void @csec_print_char(i8 %value)
  call void @csec_print_newline()
  ret void
}

define ptr @InOut_readText(ptr %this) {
entry:
  %readline = call ptr @csec_read_line()
  ret ptr %readline
}

define i8 @InOut_readCharacter(ptr %this) {
entry:
  %readchar = call i8 @csec_read_char()
  ret i8 %readchar
}

define i32 @InOut_readInteger(ptr %this) {
entry:
  %readint = call i32 @csec_read_int()
  ret i32 %readint
}

define double @InOut_readReal(ptr %this) {
entry:
  %readdouble = call double @csec_read_double()
  ret double %readdouble
}

declare void @csec_print_string(ptr)

declare void @csec_print_i64(i64)

declare void @csec_print_double(double)

declare void @csec_print_bool(i32)

declare void @csec_print_char(i8)

declare void @csec_print_newline()

declare ptr @csec_read_line()

declare i8 @csec_read_char()

declare i32 @csec_read_int()

declare double @csec_read_double()

declare void @csec_set_command_line_args(i32, ptr)

define internal i32 @__csec_jit_entry() {
entry:
  %user.main = call i32 @_main()
  ret i32 %user.main
}
