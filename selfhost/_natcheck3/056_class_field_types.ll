; ModuleID = 'main'
source_filename = "main"

%DataHolder = type { i32, ptr, float, i1, i32, double }

@0 = private unnamed_addr constant [8 x i8] c"default\00", align 1

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
  %newobj.malloc = call ptr @malloc(i64 40)
  %id.init = getelementptr inbounds %DataHolder, ptr %newobj.malloc, i32 0, i32 0
  store i32 42, ptr %id.init, align 4
  %name.init = getelementptr inbounds %DataHolder, ptr %newobj.malloc, i32 0, i32 1
  store ptr @0, ptr %name.init, align 8
  %score.init = getelementptr inbounds %DataHolder, ptr %newobj.malloc, i32 0, i32 2
  store float 0.000000e+00, ptr %score.init, align 4
  %active.init = getelementptr inbounds %DataHolder, ptr %newobj.malloc, i32 0, i32 3
  store i1 true, ptr %active.init, align 1
  %count.init = getelementptr inbounds %DataHolder, ptr %newobj.malloc, i32 0, i32 4
  store i32 0, ptr %count.init, align 4
  %factor.init = getelementptr inbounds %DataHolder, ptr %newobj.malloc, i32 0, i32 5
  store double 1.000000e+00, ptr %factor.init, align 8
  %calltmp = call i32 @DataHolder_getId(ptr %newobj.malloc)
  %calltmp1 = call i32 @DataHolder_increment(ptr %newobj.malloc)
  %calltmp2 = call i32 @DataHolder_increment(ptr %newobj.malloc)
  %calltmp3 = call i32 @DataHolder_getCount(ptr %newobj.malloc)
  %addtmp = add i32 %calltmp, %calltmp3
  ret i32 %addtmp
}

define i32 @DataHolder_getId(ptr %this) {
entry:
  %id.field = getelementptr inbounds %DataHolder, ptr %this, i32 0, i32 0
  %name.field = getelementptr inbounds %DataHolder, ptr %this, i32 0, i32 1
  %score.field = getelementptr inbounds %DataHolder, ptr %this, i32 0, i32 2
  %active.field = getelementptr inbounds %DataHolder, ptr %this, i32 0, i32 3
  %count.field = getelementptr inbounds %DataHolder, ptr %this, i32 0, i32 4
  %factor.field = getelementptr inbounds %DataHolder, ptr %this, i32 0, i32 5
  %id.load = load i32, ptr %id.field, align 4
  ret i32 %id.load
}

define i32 @DataHolder_getCount(ptr %this) {
entry:
  %id.field = getelementptr inbounds %DataHolder, ptr %this, i32 0, i32 0
  %name.field = getelementptr inbounds %DataHolder, ptr %this, i32 0, i32 1
  %score.field = getelementptr inbounds %DataHolder, ptr %this, i32 0, i32 2
  %active.field = getelementptr inbounds %DataHolder, ptr %this, i32 0, i32 3
  %count.field = getelementptr inbounds %DataHolder, ptr %this, i32 0, i32 4
  %factor.field = getelementptr inbounds %DataHolder, ptr %this, i32 0, i32 5
  %count.load = load i32, ptr %count.field, align 4
  ret i32 %count.load
}

define i32 @DataHolder_increment(ptr %this) {
entry:
  %id.field = getelementptr inbounds %DataHolder, ptr %this, i32 0, i32 0
  %name.field = getelementptr inbounds %DataHolder, ptr %this, i32 0, i32 1
  %score.field = getelementptr inbounds %DataHolder, ptr %this, i32 0, i32 2
  %active.field = getelementptr inbounds %DataHolder, ptr %this, i32 0, i32 3
  %count.field = getelementptr inbounds %DataHolder, ptr %this, i32 0, i32 4
  %factor.field = getelementptr inbounds %DataHolder, ptr %this, i32 0, i32 5
  %count.load = load i32, ptr %count.field, align 4
  %count.load1 = load i32, ptr %count.field, align 4
  %addtmp = add i32 %count.load1, 1
  store i32 %addtmp, ptr %count.field, align 4
  %count.load2 = load i32, ptr %count.field, align 4
  ret i32 %count.load2
}

declare void @csec_set_command_line_args(i32, ptr)

define internal i32 @__csec_jit_entry() {
entry:
  %user.main = call i32 @_main()
  ret i32 %user.main
}
