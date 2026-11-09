; ModuleID = 'main'
source_filename = "main"

%Pair = type { i32, i32 }
%Holder = type { i32 }

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
  %newstruct = alloca %Pair, align 8
  %x.init = getelementptr inbounds %Pair, ptr %newstruct, i32 0, i32 0
  store i32 1, ptr %x.init, align 4
  %y.init = getelementptr inbounds %Pair, ptr %newstruct, i32 0, i32 1
  store i32 2, ptr %y.init, align 4
  %newobj.malloc = call ptr @malloc(i64 4)
  %value.init = getelementptr inbounds %Holder, ptr %newobj.malloc, i32 0, i32 0
  store i32 3, ptr %value.init, align 4
  %calltmp = call i32 @Pair_sum(ptr %newstruct)
  %calltmp1 = call i32 @Holder_get(ptr %newobj.malloc)
  %addtmp = add i32 %calltmp, %calltmp1
  ret i32 %addtmp
}

define i32 @Pair_sum(ptr %this) {
entry:
  %x.field = getelementptr inbounds %Pair, ptr %this, i32 0, i32 0
  %y.field = getelementptr inbounds %Pair, ptr %this, i32 0, i32 1
  %x.load = load i32, ptr %x.field, align 4
  %y.load = load i32, ptr %y.field, align 4
  %addtmp = add i32 %x.load, %y.load
  ret i32 %addtmp
}

define i32 @Holder_get(ptr %this) {
entry:
  %value.field = getelementptr inbounds %Holder, ptr %this, i32 0, i32 0
  %value.load = load i32, ptr %value.field, align 4
  ret i32 %value.load
}

declare void @csec_set_command_line_args(i32, ptr)

define internal i32 @__csec_jit_entry() {
entry:
  %user.main = call i32 @_main()
  ret i32 %user.main
}
