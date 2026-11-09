; ModuleID = 'main'
source_filename = "main"

%Pair = type { i32, i32 }
%Holder = type { %Pair }

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
  store i32 2, ptr %x.init, align 4
  %y.init = getelementptr inbounds %Pair, ptr %newstruct, i32 0, i32 1
  store i32 3, ptr %y.init, align 4
  %newstruct1 = alloca %Holder, align 8
  %abi.load = load %Pair, ptr %newstruct, align 4
  %value.init = getelementptr inbounds %Holder, ptr %newstruct1, i32 0, i32 0
  store %Pair %abi.load, ptr %value.init, align 4
  %abi.load2 = load %Pair, ptr %newstruct, align 4
  %calltmp = call i32 @Holder_total(ptr %newstruct1)
  ret i32 %calltmp
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

define i32 @Holder_total(ptr %this) {
entry:
  %value.field = getelementptr inbounds %Holder, ptr %this, i32 0, i32 0
  %calltmp = call i32 @Pair_sum(ptr %value.field)
  ret i32 %calltmp
}

declare void @csec_set_command_line_args(i32, ptr)

define internal i32 @__csec_jit_entry() {
entry:
  %user.main = call i32 @_main()
  ret i32 %user.main
}
