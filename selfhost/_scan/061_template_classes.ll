; ModuleID = 'main'
source_filename = "main"

%"Box$Int" = type { i32 }
%"Pair$Int$Int" = type { i32, i32 }
%"Box$Int.0" = type { i32 }
%"Pair$Int$Int.1" = type { i32, i32 }

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

define i32 @"Box$Int_get"(ptr %this) {
entry:
  %value.field = getelementptr inbounds %"Box$Int", ptr %this, i32 0, i32 0
  %value.load = load i32, ptr %value.field, align 4
  ret i32 %value.load
}

define i32 @"Pair$Int$Int_left"(ptr %this) {
entry:
  %first.field = getelementptr inbounds %"Pair$Int$Int", ptr %this, i32 0, i32 0
  %second.field = getelementptr inbounds %"Pair$Int$Int", ptr %this, i32 0, i32 1
  %first.load = load i32, ptr %first.field, align 4
  ret i32 %first.load
}

define i32 @"Pair$Int$Int_right"(ptr %this) {
entry:
  %first.field = getelementptr inbounds %"Pair$Int$Int", ptr %this, i32 0, i32 0
  %second.field = getelementptr inbounds %"Pair$Int$Int", ptr %this, i32 0, i32 1
  %second.load = load i32, ptr %second.field, align 4
  ret i32 %second.load
}

define i32 @_main() {
entry:
  %newobj.malloc = call ptr @malloc(i64 4)
  %value.init = getelementptr inbounds %"Box$Int.0", ptr %newobj.malloc, i32 0, i32 0
  store i32 10, ptr %value.init, align 4
  %newobj.malloc1 = call ptr @malloc(i64 8)
  %first.init = getelementptr inbounds %"Pair$Int$Int.1", ptr %newobj.malloc1, i32 0, i32 0
  store i32 1, ptr %first.init, align 4
  %second.init = getelementptr inbounds %"Pair$Int$Int.1", ptr %newobj.malloc1, i32 0, i32 1
  store i32 2, ptr %second.init, align 4
  ret i32 0
}

define i32 @"Box$Int_get.1"(ptr %this) {
entry:
  %value.field = getelementptr inbounds %"Box$Int.0", ptr %this, i32 0, i32 0
  %value.load = load i32, ptr %value.field, align 4
  ret i32 %value.load
}

define i32 @"Pair$Int$Int_left.2"(ptr %this) {
entry:
  %first.field = getelementptr inbounds %"Pair$Int$Int.1", ptr %this, i32 0, i32 0
  %second.field = getelementptr inbounds %"Pair$Int$Int.1", ptr %this, i32 0, i32 1
  %first.load = load i32, ptr %first.field, align 4
  ret i32 %first.load
}

define i32 @"Pair$Int$Int_right.3"(ptr %this) {
entry:
  %first.field = getelementptr inbounds %"Pair$Int$Int.1", ptr %this, i32 0, i32 0
  %second.field = getelementptr inbounds %"Pair$Int$Int.1", ptr %this, i32 0, i32 1
  %second.load = load i32, ptr %second.field, align 4
  ret i32 %second.load
}

declare void @csec_set_command_line_args(i32, ptr)

define internal i32 @__csec_jit_entry() {
entry:
  %user.main = call i32 @_main()
  ret i32 %user.main
}
