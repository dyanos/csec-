; ModuleID = 'main'
source_filename = "main"

%"Box$Int" = type { i32 }
%"Counter$Int" = type { i32, i32 }
%"Box$Int.0" = type { i32 }
%"Counter$Int.1" = type { i32, i32 }

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

define i32 @"Counter$Int_get"(ptr %this) {
entry:
  %initial.field = getelementptr inbounds %"Counter$Int", ptr %this, i32 0, i32 0
  %current.field = getelementptr inbounds %"Counter$Int", ptr %this, i32 0, i32 1
  %current.load = load i32, ptr %current.field, align 4
  ret i32 %current.load
}

define i32 @_main() {
entry:
  %newobj.malloc = call ptr @malloc(i64 4)
  %value.init = getelementptr inbounds %"Box$Int.0", ptr %newobj.malloc, i32 0, i32 0
  store i32 42, ptr %value.init, align 4
  %newobj.malloc1 = call ptr @malloc(i64 8)
  %initial.init = getelementptr inbounds %"Counter$Int.1", ptr %newobj.malloc1, i32 0, i32 0
  store i32 7, ptr %initial.init, align 4
  %current.init = getelementptr inbounds %"Counter$Int.1", ptr %newobj.malloc1, i32 0, i32 1
  store i32 7, ptr %current.init, align 4
  %calltmp = call i32 @"Box$Int_get.1"(ptr %newobj.malloc)
  %math.sext = sext i32 %calltmp to i64
  call void @csec_print_i64(i64 %math.sext)
  call void @csec_print_newline()
  %calltmp2 = call i32 @"Counter$Int_get.2"(ptr %newobj.malloc1)
  %math.sext3 = sext i32 %calltmp2 to i64
  call void @csec_print_i64(i64 %math.sext3)
  call void @csec_print_newline()
  %calltmp4 = call i32 @"Box$Int_get.1"(ptr %newobj.malloc)
  %calltmp5 = call i32 @"Counter$Int_get.2"(ptr %newobj.malloc1)
  %addtmp = add i32 %calltmp4, %calltmp5
  ret i32 %addtmp
}

define i32 @"Box$Int_get.1"(ptr %this) {
entry:
  %value.field = getelementptr inbounds %"Box$Int.0", ptr %this, i32 0, i32 0
  %value.load = load i32, ptr %value.field, align 4
  ret i32 %value.load
}

define i32 @"Counter$Int_get.2"(ptr %this) {
entry:
  %initial.field = getelementptr inbounds %"Counter$Int.1", ptr %this, i32 0, i32 0
  %current.field = getelementptr inbounds %"Counter$Int.1", ptr %this, i32 0, i32 1
  %current.load = load i32, ptr %current.field, align 4
  ret i32 %current.load
}

declare void @csec_print_i64(i64)

declare void @csec_print_newline()

declare void @csec_set_command_line_args(i32, ptr)

define internal i32 @__csec_jit_entry() {
entry:
  %user.main = call i32 @_main()
  ret i32 %user.main
}
