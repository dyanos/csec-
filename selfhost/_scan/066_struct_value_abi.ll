; ModuleID = 'main'
source_filename = "main"

%Pair = type { i32, i32 }

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

define i32 @_pass(%Pair %0) {
entry:
  %value.addr = alloca %Pair, align 8
  store %Pair %0, ptr %value.addr, align 4
  %calltmp = call i32 @Pair_sum(ptr %value.addr)
  ret i32 %calltmp
}

define %Pair @_makePair() {
entry:
  %newstruct = alloca %Pair, align 8
  %x.init = getelementptr inbounds %Pair, ptr %newstruct, i32 0, i32 0
  store i32 4, ptr %x.init, align 4
  %y.init = getelementptr inbounds %Pair, ptr %newstruct, i32 0, i32 1
  store i32 5, ptr %y.init, align 4
  %abi.load = load %Pair, ptr %newstruct, align 4
  ret %Pair %abi.load
}

define i32 @_main() {
entry:
  %newstruct = alloca %Pair, align 8
  %x.init = getelementptr inbounds %Pair, ptr %newstruct, i32 0, i32 0
  store i32 1, ptr %x.init, align 4
  %y.init = getelementptr inbounds %Pair, ptr %newstruct, i32 0, i32 1
  store i32 2, ptr %y.init, align 4
  %abi.load = load %Pair, ptr %newstruct, align 4
  %calltmp = call %Pair @_makePair()
  %third = alloca %Pair, align 8
  store %Pair %calltmp, ptr %third, align 4
  %abi.load1 = load %Pair, ptr %newstruct, align 4
  %calltmp2 = call i32 @_pass(%Pair %abi.load1)
  %calltmp4 = call i32 @_pass(%Pair %abi.load)
  %addtmp = add i32 %calltmp2, %calltmp4
  %calltmp5 = call i32 @Pair_sum(ptr %third)
  %addtmp6 = add i32 %addtmp, %calltmp5
  ret i32 %addtmp6
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

declare void @csec_set_command_line_args(i32, ptr)

define internal i32 @__csec_jit_entry() {
entry:
  %user.main = call i32 @_main()
  ret i32 %user.main
}
