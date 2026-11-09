; ModuleID = 'main'
source_filename = "main"

%"TypedNode$Int" = type { i32, i32 }
%"Wrapper$Int" = type { i32 }
%"TypedNode$Int.0" = type { i32, i32 }
%"Wrapper$Int.1" = type { i32 }
%Base = type { i32 }

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

define i32 @"TypedNode$Int_getValue"(ptr %this) {
entry:
  %value.field = getelementptr inbounds %"TypedNode$Int", ptr %this, i32 0, i32 0
  %id.field = getelementptr inbounds %"TypedNode$Int", ptr %this, i32 0, i32 1
  %value.load = load i32, ptr %value.field, align 4
  ret i32 %value.load
}

define i32 @"Wrapper$Int_unwrap"(ptr %this) {
entry:
  %inner.field = getelementptr inbounds %"Wrapper$Int", ptr %this, i32 0, i32 0
  %inner.load = load i32, ptr %inner.field, align 4
  ret i32 %inner.load
}

define i32 @_main() {
entry:
  %newobj.malloc = call ptr @malloc(i64 8)
  %value.init = getelementptr inbounds %"TypedNode$Int.0", ptr %newobj.malloc, i32 0, i32 0
  store i32 42, ptr %value.init, align 4
  %id.init = getelementptr inbounds %"TypedNode$Int.0", ptr %newobj.malloc, i32 0, i32 1
  store i32 1, ptr %id.init, align 4
  %newobj.malloc1 = call ptr @malloc(i64 4)
  %inner.init = getelementptr inbounds %"Wrapper$Int.1", ptr %newobj.malloc1, i32 0, i32 0
  store i32 100, ptr %inner.init, align 4
  %calltmp = call i32 @Base_getId(ptr %newobj.malloc)
  %calltmp2 = call i32 @"Wrapper$Int_unwrap.2"(ptr %newobj.malloc1)
  %addtmp = add i32 %calltmp, %calltmp2
  ret i32 %addtmp
}

define i32 @Base_getId(ptr %this) {
entry:
  %id.field = getelementptr inbounds %Base, ptr %this, i32 0, i32 0
  %id.load = load i32, ptr %id.field, align 4
  ret i32 %id.load
}

define i32 @"TypedNode$Int_getValue.1"(ptr %this) {
entry:
  %value.field = getelementptr inbounds %"TypedNode$Int.0", ptr %this, i32 0, i32 0
  %id.field = getelementptr inbounds %"TypedNode$Int.0", ptr %this, i32 0, i32 1
  %value.load = load i32, ptr %value.field, align 4
  ret i32 %value.load
}

define i32 @"Wrapper$Int_unwrap.2"(ptr %this) {
entry:
  %inner.field = getelementptr inbounds %"Wrapper$Int.1", ptr %this, i32 0, i32 0
  %inner.load = load i32, ptr %inner.field, align 4
  ret i32 %inner.load
}

declare void @csec_set_command_line_args(i32, ptr)

define internal i32 @__csec_jit_entry() {
entry:
  %user.main = call i32 @_main()
  ret i32 %user.main
}
