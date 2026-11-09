; ModuleID = 'main'
source_filename = "main"

%"StaticArray$Int$16" = type { i32 }
%"StaticArray$Int$16.0" = type { i32 }

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

define i32 @"StaticArray$Int$16_size"(ptr %this) {
entry:
  %seed.field = getelementptr inbounds %"StaticArray$Int$16", ptr %this, i32 0, i32 0
  ret i32 16
}

define i32 @_main() {
entry:
  %newobj.malloc = call ptr @malloc(i64 4)
  %seed.init = getelementptr inbounds %"StaticArray$Int$16.0", ptr %newobj.malloc, i32 0, i32 0
  store i32 0, ptr %seed.init, align 4
  ret i32 0
}

define i32 @"StaticArray$Int$16_size.1"(ptr %this) {
entry:
  %seed.field = getelementptr inbounds %"StaticArray$Int$16.0", ptr %this, i32 0, i32 0
  ret i32 16
}

declare void @csec_set_command_line_args(i32, ptr)

define internal i32 @__csec_jit_entry() {
entry:
  %user.main = call i32 @_main()
  ret i32 %user.main
}
