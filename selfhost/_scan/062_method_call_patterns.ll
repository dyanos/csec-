; ModuleID = 'main'
source_filename = "main"

%Builder = type { i32 }

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
  %newobj.malloc = call ptr @malloc(i64 4)
  %seed.init = getelementptr inbounds %Builder, ptr %newobj.malloc, i32 0, i32 0
  store i32 10, ptr %seed.init, align 4
  %calltmp = call i32 @Builder_step1(ptr %newobj.malloc, i32 5)
  %calltmp1 = call i32 @Builder_step2(ptr %newobj.malloc, i32 1, i32 2)
  %calltmp2 = call i32 @Builder_noArgs(ptr %newobj.malloc)
  %calltmp3 = call i32 @Builder_manyArgs(ptr %newobj.malloc, i32 1, i32 2, i32 3, i32 4)
  %calltmp4 = call i32 @"Factory#create"(i32 42)
  %calltmp5 = call i32 @"Factory#combine"(i32 10, i32 20)
  %addtmp = add i32 %calltmp, %calltmp1
  %addtmp6 = add i32 %addtmp, %calltmp2
  %addtmp7 = add i32 %addtmp6, %calltmp3
  %addtmp8 = add i32 %addtmp7, %calltmp4
  %addtmp9 = add i32 %addtmp8, %calltmp5
  ret i32 %addtmp9
}

define i32 @Builder_step1(ptr %this, i32 %x) {
entry:
  %seed.field = getelementptr inbounds %Builder, ptr %this, i32 0, i32 0
  %seed.load = load i32, ptr %seed.field, align 4
  %addtmp = add i32 %seed.load, %x
  ret i32 %addtmp
}

define i32 @Builder_step2(ptr %this, i32 %x, i32 %y) {
entry:
  %seed.field = getelementptr inbounds %Builder, ptr %this, i32 0, i32 0
  %addtmp = add i32 %x, %y
  %seed.load = load i32, ptr %seed.field, align 4
  %addtmp1 = add i32 %addtmp, %seed.load
  ret i32 %addtmp1
}

define i32 @Builder_noArgs(ptr %this) {
entry:
  %seed.field = getelementptr inbounds %Builder, ptr %this, i32 0, i32 0
  %seed.load = load i32, ptr %seed.field, align 4
  ret i32 %seed.load
}

define i32 @Builder_manyArgs(ptr %this, i32 %a, i32 %b, i32 %c, i32 %d) {
entry:
  %seed.field = getelementptr inbounds %Builder, ptr %this, i32 0, i32 0
  %addtmp = add i32 %a, %b
  %addtmp1 = add i32 %addtmp, %c
  %addtmp2 = add i32 %addtmp1, %d
  %seed.load = load i32, ptr %seed.field, align 4
  %addtmp3 = add i32 %addtmp2, %seed.load
  ret i32 %addtmp3
}

define i32 @"Factory#create"(i32 %0) {
entry:
  ret i32 %0
}

define i32 @"Factory#combine"(i32 %0, i32 %1) {
entry:
  %addtmp = add i32 %0, %1
  ret i32 %addtmp
}

declare void @csec_set_command_line_args(i32, ptr)

define internal i32 @__csec_jit_entry() {
entry:
  %user.main = call i32 @_main()
  ret i32 %user.main
}
