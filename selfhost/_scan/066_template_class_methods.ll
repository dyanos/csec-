; ModuleID = 'main'
source_filename = "main"

%"Stack$Int" = type { i32, i32 }
%"Stack$Int.0" = type { i32, i32 }

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

define i32 @"Stack$Int_push"(ptr %this, i32 %item) {
entry:
  %capacity.field = getelementptr inbounds %"Stack$Int", ptr %this, i32 0, i32 0
  %size.field = getelementptr inbounds %"Stack$Int", ptr %this, i32 0, i32 1
  %size.load = load i32, ptr %size.field, align 4
  %size.load1 = load i32, ptr %size.field, align 4
  %addtmp = add i32 %size.load1, 1
  store i32 %addtmp, ptr %size.field, align 4
  %size.load2 = load i32, ptr %size.field, align 4
  ret i32 %size.load2
}

define i32 @"Stack$Int_pop"(ptr %this) {
entry:
  %capacity.field = getelementptr inbounds %"Stack$Int", ptr %this, i32 0, i32 0
  %size.field = getelementptr inbounds %"Stack$Int", ptr %this, i32 0, i32 1
  %size.load = load i32, ptr %size.field, align 4
  %size.load1 = load i32, ptr %size.field, align 4
  %subtmp = sub i32 %size.load1, 1
  store i32 %subtmp, ptr %size.field, align 4
  %size.load2 = load i32, ptr %size.field, align 4
  ret i32 %size.load2
}

define i32 @"Stack$Int_getSize"(ptr %this) {
entry:
  %capacity.field = getelementptr inbounds %"Stack$Int", ptr %this, i32 0, i32 0
  %size.field = getelementptr inbounds %"Stack$Int", ptr %this, i32 0, i32 1
  %size.load = load i32, ptr %size.field, align 4
  ret i32 %size.load
}

define i1 @"Stack$Int_isEmpty"(ptr %this) {
entry:
  %capacity.field = getelementptr inbounds %"Stack$Int", ptr %this, i32 0, i32 0
  %size.field = getelementptr inbounds %"Stack$Int", ptr %this, i32 0, i32 1
  %size.load = load i32, ptr %size.field, align 4
  %eqtmp = icmp eq i32 %size.load, 0
  ret i1 %eqtmp
}

define i1 @"Stack$Int_isFull"(ptr %this) {
entry:
  %capacity.field = getelementptr inbounds %"Stack$Int", ptr %this, i32 0, i32 0
  %size.field = getelementptr inbounds %"Stack$Int", ptr %this, i32 0, i32 1
  %size.load = load i32, ptr %size.field, align 4
  %capacity.load = load i32, ptr %capacity.field, align 4
  %eqtmp = icmp eq i32 %size.load, %capacity.load
  ret i1 %eqtmp
}

define i32 @_main() {
entry:
  %newobj.malloc = call ptr @malloc(i64 8)
  %capacity.init = getelementptr inbounds %"Stack$Int.0", ptr %newobj.malloc, i32 0, i32 0
  store i32 10, ptr %capacity.init, align 4
  %size.init = getelementptr inbounds %"Stack$Int.0", ptr %newobj.malloc, i32 0, i32 1
  store i32 0, ptr %size.init, align 4
  %calltmp = call i32 @"Stack$Int_push.1"(ptr %newobj.malloc, i32 1)
  %calltmp1 = call i32 @"Stack$Int_push.1"(ptr %newobj.malloc, i32 2)
  %calltmp2 = call i32 @"Stack$Int_push.1"(ptr %newobj.malloc, i32 3)
  %calltmp3 = call i32 @"Stack$Int_getSize.3"(ptr %newobj.malloc)
  %calltmp4 = call i32 @"Stack$Int_pop.2"(ptr %newobj.malloc)
  ret i32 %calltmp3
}

define i32 @"Stack$Int_push.1"(ptr %this, i32 %item) {
entry:
  %capacity.field = getelementptr inbounds %"Stack$Int.0", ptr %this, i32 0, i32 0
  %size.field = getelementptr inbounds %"Stack$Int.0", ptr %this, i32 0, i32 1
  %size.load = load i32, ptr %size.field, align 4
  %size.load1 = load i32, ptr %size.field, align 4
  %addtmp = add i32 %size.load1, 1
  store i32 %addtmp, ptr %size.field, align 4
  %size.load2 = load i32, ptr %size.field, align 4
  ret i32 %size.load2
}

define i32 @"Stack$Int_pop.2"(ptr %this) {
entry:
  %capacity.field = getelementptr inbounds %"Stack$Int.0", ptr %this, i32 0, i32 0
  %size.field = getelementptr inbounds %"Stack$Int.0", ptr %this, i32 0, i32 1
  %size.load = load i32, ptr %size.field, align 4
  %size.load1 = load i32, ptr %size.field, align 4
  %subtmp = sub i32 %size.load1, 1
  store i32 %subtmp, ptr %size.field, align 4
  %size.load2 = load i32, ptr %size.field, align 4
  ret i32 %size.load2
}

define i32 @"Stack$Int_getSize.3"(ptr %this) {
entry:
  %capacity.field = getelementptr inbounds %"Stack$Int.0", ptr %this, i32 0, i32 0
  %size.field = getelementptr inbounds %"Stack$Int.0", ptr %this, i32 0, i32 1
  %size.load = load i32, ptr %size.field, align 4
  ret i32 %size.load
}

define i1 @"Stack$Int_isEmpty.4"(ptr %this) {
entry:
  %capacity.field = getelementptr inbounds %"Stack$Int.0", ptr %this, i32 0, i32 0
  %size.field = getelementptr inbounds %"Stack$Int.0", ptr %this, i32 0, i32 1
  %size.load = load i32, ptr %size.field, align 4
  %eqtmp = icmp eq i32 %size.load, 0
  ret i1 %eqtmp
}

define i1 @"Stack$Int_isFull.5"(ptr %this) {
entry:
  %capacity.field = getelementptr inbounds %"Stack$Int.0", ptr %this, i32 0, i32 0
  %size.field = getelementptr inbounds %"Stack$Int.0", ptr %this, i32 0, i32 1
  %size.load = load i32, ptr %size.field, align 4
  %capacity.load = load i32, ptr %capacity.field, align 4
  %eqtmp = icmp eq i32 %size.load, %capacity.load
  ret i1 %eqtmp
}

declare void @csec_set_command_line_args(i32, ptr)

define internal i32 @__csec_jit_entry() {
entry:
  %user.main = call i32 @_main()
  ret i32 %user.main
}
