; ModuleID = 'main'
source_filename = "main"

%"Holder$Int" = type { i32 }
%"Holder$Float" = type { float }
%"Holder$String" = type { ptr }
%"Holder$Int.0" = type { i32 }
%"Holder$Float.1" = type { float }
%"Holder$String.2" = type { ptr }

@0 = private unnamed_addr constant [6 x i8] c"hello\00", align 1

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

define i32 @"Holder$Int_get"(ptr %this) {
entry:
  %value.field = getelementptr inbounds %"Holder$Int", ptr %this, i32 0, i32 0
  %value.load = load i32, ptr %value.field, align 4
  ret i32 %value.load
}

define float @"Holder$Float_get"(ptr %this) {
entry:
  %value.field = getelementptr inbounds %"Holder$Float", ptr %this, i32 0, i32 0
  %value.load = load float, ptr %value.field, align 4
  ret float %value.load
}

define ptr @"Holder$String_get"(ptr %this) {
entry:
  %value.field = getelementptr inbounds %"Holder$String", ptr %this, i32 0, i32 0
  %value.load = load ptr, ptr %value.field, align 8
  ret ptr %value.load
}

define i32 @_main() {
entry:
  %calltmp = call i32 @"_identity$Int"(i32 1)
  %calltmp1 = call i32 @"_identity$Int"(i32 2)
  %calltmp2 = call i32 @"_identity$Int"(i32 3)
  %calltmp3 = call float @"_identity$Float"(float 1.000000e+00)
  %calltmp4 = call double @"_identity$Double"(double 2.000000e+00)
  %newobj.malloc = call ptr @malloc(i64 4)
  %value.init = getelementptr inbounds %"Holder$Int.0", ptr %newobj.malloc, i32 0, i32 0
  store i32 10, ptr %value.init, align 4
  %newobj.malloc5 = call ptr @malloc(i64 4)
  %value.init6 = getelementptr inbounds %"Holder$Int.0", ptr %newobj.malloc5, i32 0, i32 0
  store i32 20, ptr %value.init6, align 4
  %newobj.malloc7 = call ptr @malloc(i64 4)
  %value.init8 = getelementptr inbounds %"Holder$Float.1", ptr %newobj.malloc7, i32 0, i32 0
  store float 0x40091EB860000000, ptr %value.init8, align 4
  %newobj.malloc9 = call ptr @malloc(i64 8)
  %value.init10 = getelementptr inbounds %"Holder$String.2", ptr %newobj.malloc9, i32 0, i32 0
  store ptr @0, ptr %value.init10, align 8
  %calltmp11 = call i32 @"Holder$Int_get.1"(ptr %newobj.malloc)
  %calltmp12 = call i32 @"Holder$Int_get.1"(ptr %newobj.malloc5)
  %addtmp = add i32 %calltmp, %calltmp1
  %addtmp13 = add i32 %addtmp, %calltmp2
  %addtmp14 = add i32 %addtmp13, %calltmp11
  %addtmp15 = add i32 %addtmp14, %calltmp12
  ret i32 %addtmp15
}

define i32 @"_identity$Int"(i32 %0) {
entry:
  ret i32 %0
}

define float @"_identity$Float"(float %0) {
entry:
  ret float %0
}

define double @"_identity$Double"(double %0) {
entry:
  ret double %0
}

define i32 @"Holder$Int_get.1"(ptr %this) {
entry:
  %value.field = getelementptr inbounds %"Holder$Int.0", ptr %this, i32 0, i32 0
  %value.load = load i32, ptr %value.field, align 4
  ret i32 %value.load
}

define float @"Holder$Float_get.2"(ptr %this) {
entry:
  %value.field = getelementptr inbounds %"Holder$Float.1", ptr %this, i32 0, i32 0
  %value.load = load float, ptr %value.field, align 4
  ret float %value.load
}

define ptr @"Holder$String_get.3"(ptr %this) {
entry:
  %value.field = getelementptr inbounds %"Holder$String.2", ptr %this, i32 0, i32 0
  %value.load = load ptr, ptr %value.field, align 8
  ret ptr %value.load
}

declare void @csec_set_command_line_args(i32, ptr)

define internal i32 @__csec_jit_entry() {
entry:
  %user.main = call i32 @_main()
  ret i32 %user.main
}
