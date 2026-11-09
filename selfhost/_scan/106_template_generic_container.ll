; ModuleID = 'main'
source_filename = "main"

%"Optional$Int" = type { i1, i32 }
%"Result$String" = type { i1, ptr, i32 }
%"Entry$String$Int" = type { ptr, i32 }
%"Optional$Int.0" = type { i1, i32 }
%"Result$String.1" = type { i1, ptr, i32 }
%"Entry$String$Int.2" = type { ptr, i32 }

@0 = private unnamed_addr constant [4 x i8] c"age\00", align 1

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

define i1 @"Optional$Int_isPresent"(ptr %this) {
entry:
  %hasValue.field = getelementptr inbounds %"Optional$Int", ptr %this, i32 0, i32 0
  %value.field = getelementptr inbounds %"Optional$Int", ptr %this, i32 0, i32 1
  %hasValue.load = load i1, ptr %hasValue.field, align 1
  ret i1 %hasValue.load
}

define i32 @"Optional$Int_get"(ptr %this) {
entry:
  %hasValue.field = getelementptr inbounds %"Optional$Int", ptr %this, i32 0, i32 0
  %value.field = getelementptr inbounds %"Optional$Int", ptr %this, i32 0, i32 1
  %value.load = load i32, ptr %value.field, align 4
  ret i32 %value.load
}

define i1 @"Result$String_isOk"(ptr %this) {
entry:
  %success.field = getelementptr inbounds %"Result$String", ptr %this, i32 0, i32 0
  %data.field = getelementptr inbounds %"Result$String", ptr %this, i32 0, i32 1
  %errorCode.field = getelementptr inbounds %"Result$String", ptr %this, i32 0, i32 2
  %success.load = load i1, ptr %success.field, align 1
  ret i1 %success.load
}

define i32 @"Result$String_getError"(ptr %this) {
entry:
  %success.field = getelementptr inbounds %"Result$String", ptr %this, i32 0, i32 0
  %data.field = getelementptr inbounds %"Result$String", ptr %this, i32 0, i32 1
  %errorCode.field = getelementptr inbounds %"Result$String", ptr %this, i32 0, i32 2
  %errorCode.load = load i32, ptr %errorCode.field, align 4
  ret i32 %errorCode.load
}

define ptr @"Entry$String$Int_getKey"(ptr %this) {
entry:
  %key.field = getelementptr inbounds %"Entry$String$Int", ptr %this, i32 0, i32 0
  %value.field = getelementptr inbounds %"Entry$String$Int", ptr %this, i32 0, i32 1
  %key.load = load ptr, ptr %key.field, align 8
  ret ptr %key.load
}

define i32 @"Entry$String$Int_getValue"(ptr %this) {
entry:
  %key.field = getelementptr inbounds %"Entry$String$Int", ptr %this, i32 0, i32 0
  %value.field = getelementptr inbounds %"Entry$String$Int", ptr %this, i32 0, i32 1
  %value.load = load i32, ptr %value.field, align 4
  ret i32 %value.load
}

define i32 @_main() {
entry:
  %newobj.malloc = call ptr @malloc(i64 8)
  %hasValue.init = getelementptr inbounds %"Optional$Int.0", ptr %newobj.malloc, i32 0, i32 0
  store i1 true, ptr %hasValue.init, align 1
  %value.init = getelementptr inbounds %"Optional$Int.0", ptr %newobj.malloc, i32 0, i32 1
  store i32 0, ptr %value.init, align 4
  %newobj.malloc1 = call ptr @malloc(i64 24)
  %success.init = getelementptr inbounds %"Result$String.1", ptr %newobj.malloc1, i32 0, i32 0
  store i1 true, ptr %success.init, align 1
  %data.init = getelementptr inbounds %"Result$String.1", ptr %newobj.malloc1, i32 0, i32 1
  store ptr null, ptr %data.init, align 8
  %errorCode.init = getelementptr inbounds %"Result$String.1", ptr %newobj.malloc1, i32 0, i32 2
  store i32 0, ptr %errorCode.init, align 4
  %newobj.malloc2 = call ptr @malloc(i64 16)
  %key.init = getelementptr inbounds %"Entry$String$Int.2", ptr %newobj.malloc2, i32 0, i32 0
  store ptr @0, ptr %key.init, align 8
  %value.init3 = getelementptr inbounds %"Entry$String$Int.2", ptr %newobj.malloc2, i32 0, i32 1
  store i32 25, ptr %value.init3, align 4
  ret i32 0
}

define i1 @"Optional$Int_isPresent.1"(ptr %this) {
entry:
  %hasValue.field = getelementptr inbounds %"Optional$Int.0", ptr %this, i32 0, i32 0
  %value.field = getelementptr inbounds %"Optional$Int.0", ptr %this, i32 0, i32 1
  %hasValue.load = load i1, ptr %hasValue.field, align 1
  ret i1 %hasValue.load
}

define i32 @"Optional$Int_get.2"(ptr %this) {
entry:
  %hasValue.field = getelementptr inbounds %"Optional$Int.0", ptr %this, i32 0, i32 0
  %value.field = getelementptr inbounds %"Optional$Int.0", ptr %this, i32 0, i32 1
  %value.load = load i32, ptr %value.field, align 4
  ret i32 %value.load
}

define i1 @"Result$String_isOk.3"(ptr %this) {
entry:
  %success.field = getelementptr inbounds %"Result$String.1", ptr %this, i32 0, i32 0
  %data.field = getelementptr inbounds %"Result$String.1", ptr %this, i32 0, i32 1
  %errorCode.field = getelementptr inbounds %"Result$String.1", ptr %this, i32 0, i32 2
  %success.load = load i1, ptr %success.field, align 1
  ret i1 %success.load
}

define i32 @"Result$String_getError.4"(ptr %this) {
entry:
  %success.field = getelementptr inbounds %"Result$String.1", ptr %this, i32 0, i32 0
  %data.field = getelementptr inbounds %"Result$String.1", ptr %this, i32 0, i32 1
  %errorCode.field = getelementptr inbounds %"Result$String.1", ptr %this, i32 0, i32 2
  %errorCode.load = load i32, ptr %errorCode.field, align 4
  ret i32 %errorCode.load
}

define ptr @"Entry$String$Int_getKey.5"(ptr %this) {
entry:
  %key.field = getelementptr inbounds %"Entry$String$Int.2", ptr %this, i32 0, i32 0
  %value.field = getelementptr inbounds %"Entry$String$Int.2", ptr %this, i32 0, i32 1
  %key.load = load ptr, ptr %key.field, align 8
  ret ptr %key.load
}

define i32 @"Entry$String$Int_getValue.6"(ptr %this) {
entry:
  %key.field = getelementptr inbounds %"Entry$String$Int.2", ptr %this, i32 0, i32 0
  %value.field = getelementptr inbounds %"Entry$String$Int.2", ptr %this, i32 0, i32 1
  %value.load = load i32, ptr %value.field, align 4
  ret i32 %value.load
}

declare void @csec_set_command_line_args(i32, ptr)

define internal i32 @__csec_jit_entry() {
entry:
  %user.main = call i32 @_main()
  ret i32 %user.main
}
