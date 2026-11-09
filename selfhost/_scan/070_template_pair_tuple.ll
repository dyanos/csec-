; ModuleID = 'main'
source_filename = "main"

%"Pair$Int$Int" = type { i32, i32 }
%"Pair$Int$String" = type { i32, ptr }
%"Pair$String$Boolean" = type { ptr, i1 }
%"Triple$Int$Int$Int" = type { i32, i32, i32 }
%"Triple$Int$Float$Double" = type { i32, float, double }
%"Pair$Int$Int.0" = type { i32, i32 }
%"Pair$Int$String.1" = type { i32, ptr }
%"Pair$String$Boolean.2" = type { ptr, i1 }
%"Triple$Int$Int$Int.3" = type { i32, i32, i32 }
%"Triple$Int$Float$Double.4" = type { i32, float, double }

@0 = private unnamed_addr constant [6 x i8] c"hello\00", align 1
@1 = private unnamed_addr constant [5 x i8] c"test\00", align 1

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

define i32 @"Pair$Int$Int_getFirst"(ptr %this) {
entry:
  %first.field = getelementptr inbounds %"Pair$Int$Int", ptr %this, i32 0, i32 0
  %second.field = getelementptr inbounds %"Pair$Int$Int", ptr %this, i32 0, i32 1
  %first.load = load i32, ptr %first.field, align 4
  ret i32 %first.load
}

define i32 @"Pair$Int$Int_getSecond"(ptr %this) {
entry:
  %first.field = getelementptr inbounds %"Pair$Int$Int", ptr %this, i32 0, i32 0
  %second.field = getelementptr inbounds %"Pair$Int$Int", ptr %this, i32 0, i32 1
  %second.load = load i32, ptr %second.field, align 4
  ret i32 %second.load
}

define i32 @"Pair$Int$String_getFirst"(ptr %this) {
entry:
  %first.field = getelementptr inbounds %"Pair$Int$String", ptr %this, i32 0, i32 0
  %second.field = getelementptr inbounds %"Pair$Int$String", ptr %this, i32 0, i32 1
  %first.load = load i32, ptr %first.field, align 4
  ret i32 %first.load
}

define ptr @"Pair$Int$String_getSecond"(ptr %this) {
entry:
  %first.field = getelementptr inbounds %"Pair$Int$String", ptr %this, i32 0, i32 0
  %second.field = getelementptr inbounds %"Pair$Int$String", ptr %this, i32 0, i32 1
  %second.load = load ptr, ptr %second.field, align 8
  ret ptr %second.load
}

define ptr @"Pair$String$Boolean_getFirst"(ptr %this) {
entry:
  %first.field = getelementptr inbounds %"Pair$String$Boolean", ptr %this, i32 0, i32 0
  %second.field = getelementptr inbounds %"Pair$String$Boolean", ptr %this, i32 0, i32 1
  %first.load = load ptr, ptr %first.field, align 8
  ret ptr %first.load
}

define i1 @"Pair$String$Boolean_getSecond"(ptr %this) {
entry:
  %first.field = getelementptr inbounds %"Pair$String$Boolean", ptr %this, i32 0, i32 0
  %second.field = getelementptr inbounds %"Pair$String$Boolean", ptr %this, i32 0, i32 1
  %second.load = load i1, ptr %second.field, align 1
  ret i1 %second.load
}

define i32 @"Triple$Int$Int$Int_getFirst"(ptr %this) {
entry:
  %first.field = getelementptr inbounds %"Triple$Int$Int$Int", ptr %this, i32 0, i32 0
  %second.field = getelementptr inbounds %"Triple$Int$Int$Int", ptr %this, i32 0, i32 1
  %third.field = getelementptr inbounds %"Triple$Int$Int$Int", ptr %this, i32 0, i32 2
  %first.load = load i32, ptr %first.field, align 4
  ret i32 %first.load
}

define i32 @"Triple$Int$Int$Int_getSecond"(ptr %this) {
entry:
  %first.field = getelementptr inbounds %"Triple$Int$Int$Int", ptr %this, i32 0, i32 0
  %second.field = getelementptr inbounds %"Triple$Int$Int$Int", ptr %this, i32 0, i32 1
  %third.field = getelementptr inbounds %"Triple$Int$Int$Int", ptr %this, i32 0, i32 2
  %second.load = load i32, ptr %second.field, align 4
  ret i32 %second.load
}

define i32 @"Triple$Int$Int$Int_getThird"(ptr %this) {
entry:
  %first.field = getelementptr inbounds %"Triple$Int$Int$Int", ptr %this, i32 0, i32 0
  %second.field = getelementptr inbounds %"Triple$Int$Int$Int", ptr %this, i32 0, i32 1
  %third.field = getelementptr inbounds %"Triple$Int$Int$Int", ptr %this, i32 0, i32 2
  %third.load = load i32, ptr %third.field, align 4
  ret i32 %third.load
}

define i32 @"Triple$Int$Float$Double_getFirst"(ptr %this) {
entry:
  %first.field = getelementptr inbounds %"Triple$Int$Float$Double", ptr %this, i32 0, i32 0
  %second.field = getelementptr inbounds %"Triple$Int$Float$Double", ptr %this, i32 0, i32 1
  %third.field = getelementptr inbounds %"Triple$Int$Float$Double", ptr %this, i32 0, i32 2
  %first.load = load i32, ptr %first.field, align 4
  ret i32 %first.load
}

define float @"Triple$Int$Float$Double_getSecond"(ptr %this) {
entry:
  %first.field = getelementptr inbounds %"Triple$Int$Float$Double", ptr %this, i32 0, i32 0
  %second.field = getelementptr inbounds %"Triple$Int$Float$Double", ptr %this, i32 0, i32 1
  %third.field = getelementptr inbounds %"Triple$Int$Float$Double", ptr %this, i32 0, i32 2
  %second.load = load float, ptr %second.field, align 4
  ret float %second.load
}

define double @"Triple$Int$Float$Double_getThird"(ptr %this) {
entry:
  %first.field = getelementptr inbounds %"Triple$Int$Float$Double", ptr %this, i32 0, i32 0
  %second.field = getelementptr inbounds %"Triple$Int$Float$Double", ptr %this, i32 0, i32 1
  %third.field = getelementptr inbounds %"Triple$Int$Float$Double", ptr %this, i32 0, i32 2
  %third.load = load double, ptr %third.field, align 8
  ret double %third.load
}

define i32 @_main() {
entry:
  %newobj.malloc = call ptr @malloc(i64 8)
  %first.init = getelementptr inbounds %"Pair$Int$Int.0", ptr %newobj.malloc, i32 0, i32 0
  store i32 1, ptr %first.init, align 4
  %second.init = getelementptr inbounds %"Pair$Int$Int.0", ptr %newobj.malloc, i32 0, i32 1
  store i32 2, ptr %second.init, align 4
  %newobj.malloc1 = call ptr @malloc(i64 16)
  %first.init2 = getelementptr inbounds %"Pair$Int$String.1", ptr %newobj.malloc1, i32 0, i32 0
  store i32 42, ptr %first.init2, align 4
  %second.init3 = getelementptr inbounds %"Pair$Int$String.1", ptr %newobj.malloc1, i32 0, i32 1
  store ptr @0, ptr %second.init3, align 8
  %newobj.malloc4 = call ptr @malloc(i64 16)
  %first.init5 = getelementptr inbounds %"Pair$String$Boolean.2", ptr %newobj.malloc4, i32 0, i32 0
  store ptr @1, ptr %first.init5, align 8
  %second.init6 = getelementptr inbounds %"Pair$String$Boolean.2", ptr %newobj.malloc4, i32 0, i32 1
  store i1 true, ptr %second.init6, align 1
  %newobj.malloc7 = call ptr @malloc(i64 12)
  %first.init8 = getelementptr inbounds %"Triple$Int$Int$Int.3", ptr %newobj.malloc7, i32 0, i32 0
  store i32 1, ptr %first.init8, align 4
  %second.init9 = getelementptr inbounds %"Triple$Int$Int$Int.3", ptr %newobj.malloc7, i32 0, i32 1
  store i32 2, ptr %second.init9, align 4
  %third.init = getelementptr inbounds %"Triple$Int$Int$Int.3", ptr %newobj.malloc7, i32 0, i32 2
  store i32 3, ptr %third.init, align 4
  %newobj.malloc10 = call ptr @malloc(i64 16)
  %first.init11 = getelementptr inbounds %"Triple$Int$Float$Double.4", ptr %newobj.malloc10, i32 0, i32 0
  store i32 1, ptr %first.init11, align 4
  %second.init12 = getelementptr inbounds %"Triple$Int$Float$Double.4", ptr %newobj.malloc10, i32 0, i32 1
  store float 2.000000e+00, ptr %second.init12, align 4
  %third.init13 = getelementptr inbounds %"Triple$Int$Float$Double.4", ptr %newobj.malloc10, i32 0, i32 2
  store double 3.000000e+00, ptr %third.init13, align 8
  %calltmp = call i32 @"Pair$Int$Int_getFirst.1"(ptr %newobj.malloc)
  %calltmp14 = call i32 @"Pair$Int$Int_getSecond.2"(ptr %newobj.malloc)
  %addtmp = add i32 %calltmp, %calltmp14
  ret i32 %addtmp
}

define i32 @"Pair$Int$Int_getFirst.1"(ptr %this) {
entry:
  %first.field = getelementptr inbounds %"Pair$Int$Int.0", ptr %this, i32 0, i32 0
  %second.field = getelementptr inbounds %"Pair$Int$Int.0", ptr %this, i32 0, i32 1
  %first.load = load i32, ptr %first.field, align 4
  ret i32 %first.load
}

define i32 @"Pair$Int$Int_getSecond.2"(ptr %this) {
entry:
  %first.field = getelementptr inbounds %"Pair$Int$Int.0", ptr %this, i32 0, i32 0
  %second.field = getelementptr inbounds %"Pair$Int$Int.0", ptr %this, i32 0, i32 1
  %second.load = load i32, ptr %second.field, align 4
  ret i32 %second.load
}

define i32 @"Pair$Int$String_getFirst.3"(ptr %this) {
entry:
  %first.field = getelementptr inbounds %"Pair$Int$String.1", ptr %this, i32 0, i32 0
  %second.field = getelementptr inbounds %"Pair$Int$String.1", ptr %this, i32 0, i32 1
  %first.load = load i32, ptr %first.field, align 4
  ret i32 %first.load
}

define ptr @"Pair$Int$String_getSecond.4"(ptr %this) {
entry:
  %first.field = getelementptr inbounds %"Pair$Int$String.1", ptr %this, i32 0, i32 0
  %second.field = getelementptr inbounds %"Pair$Int$String.1", ptr %this, i32 0, i32 1
  %second.load = load ptr, ptr %second.field, align 8
  ret ptr %second.load
}

define ptr @"Pair$String$Boolean_getFirst.5"(ptr %this) {
entry:
  %first.field = getelementptr inbounds %"Pair$String$Boolean.2", ptr %this, i32 0, i32 0
  %second.field = getelementptr inbounds %"Pair$String$Boolean.2", ptr %this, i32 0, i32 1
  %first.load = load ptr, ptr %first.field, align 8
  ret ptr %first.load
}

define i1 @"Pair$String$Boolean_getSecond.6"(ptr %this) {
entry:
  %first.field = getelementptr inbounds %"Pair$String$Boolean.2", ptr %this, i32 0, i32 0
  %second.field = getelementptr inbounds %"Pair$String$Boolean.2", ptr %this, i32 0, i32 1
  %second.load = load i1, ptr %second.field, align 1
  ret i1 %second.load
}

define i32 @"Triple$Int$Int$Int_getFirst.7"(ptr %this) {
entry:
  %first.field = getelementptr inbounds %"Triple$Int$Int$Int.3", ptr %this, i32 0, i32 0
  %second.field = getelementptr inbounds %"Triple$Int$Int$Int.3", ptr %this, i32 0, i32 1
  %third.field = getelementptr inbounds %"Triple$Int$Int$Int.3", ptr %this, i32 0, i32 2
  %first.load = load i32, ptr %first.field, align 4
  ret i32 %first.load
}

define i32 @"Triple$Int$Int$Int_getSecond.8"(ptr %this) {
entry:
  %first.field = getelementptr inbounds %"Triple$Int$Int$Int.3", ptr %this, i32 0, i32 0
  %second.field = getelementptr inbounds %"Triple$Int$Int$Int.3", ptr %this, i32 0, i32 1
  %third.field = getelementptr inbounds %"Triple$Int$Int$Int.3", ptr %this, i32 0, i32 2
  %second.load = load i32, ptr %second.field, align 4
  ret i32 %second.load
}

define i32 @"Triple$Int$Int$Int_getThird.9"(ptr %this) {
entry:
  %first.field = getelementptr inbounds %"Triple$Int$Int$Int.3", ptr %this, i32 0, i32 0
  %second.field = getelementptr inbounds %"Triple$Int$Int$Int.3", ptr %this, i32 0, i32 1
  %third.field = getelementptr inbounds %"Triple$Int$Int$Int.3", ptr %this, i32 0, i32 2
  %third.load = load i32, ptr %third.field, align 4
  ret i32 %third.load
}

define i32 @"Triple$Int$Float$Double_getFirst.10"(ptr %this) {
entry:
  %first.field = getelementptr inbounds %"Triple$Int$Float$Double.4", ptr %this, i32 0, i32 0
  %second.field = getelementptr inbounds %"Triple$Int$Float$Double.4", ptr %this, i32 0, i32 1
  %third.field = getelementptr inbounds %"Triple$Int$Float$Double.4", ptr %this, i32 0, i32 2
  %first.load = load i32, ptr %first.field, align 4
  ret i32 %first.load
}

define float @"Triple$Int$Float$Double_getSecond.11"(ptr %this) {
entry:
  %first.field = getelementptr inbounds %"Triple$Int$Float$Double.4", ptr %this, i32 0, i32 0
  %second.field = getelementptr inbounds %"Triple$Int$Float$Double.4", ptr %this, i32 0, i32 1
  %third.field = getelementptr inbounds %"Triple$Int$Float$Double.4", ptr %this, i32 0, i32 2
  %second.load = load float, ptr %second.field, align 4
  ret float %second.load
}

define double @"Triple$Int$Float$Double_getThird.12"(ptr %this) {
entry:
  %first.field = getelementptr inbounds %"Triple$Int$Float$Double.4", ptr %this, i32 0, i32 0
  %second.field = getelementptr inbounds %"Triple$Int$Float$Double.4", ptr %this, i32 0, i32 1
  %third.field = getelementptr inbounds %"Triple$Int$Float$Double.4", ptr %this, i32 0, i32 2
  %third.load = load double, ptr %third.field, align 8
  ret double %third.load
}

declare void @csec_set_command_line_args(i32, ptr)

define internal i32 @__csec_jit_entry() {
entry:
  %user.main = call i32 @_main()
  ret i32 %user.main
}
