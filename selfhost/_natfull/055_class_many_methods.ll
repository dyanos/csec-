; ModuleID = 'main'
source_filename = "main"

%Calculator = type { i32 }

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
  %base.init = getelementptr inbounds %Calculator, ptr %newobj.malloc, i32 0, i32 0
  store i32 10, ptr %base.init, align 4
  %calltmp = call i32 @Calculator_add(ptr %newobj.malloc, i32 5)
  %calltmp1 = call i32 @Calculator_sub(ptr %newobj.malloc, i32 3)
  %calltmp2 = call i32 @Calculator_mul(ptr %newobj.malloc, i32 2)
  %calltmp3 = call i32 @Calculator_double(ptr %newobj.malloc)
  %addtmp = add i32 %calltmp, %calltmp1
  %addtmp4 = add i32 %addtmp, %calltmp2
  %addtmp5 = add i32 %addtmp4, %calltmp3
  ret i32 %addtmp5
}

define i32 @Calculator_add(ptr %this, i32 %x) {
entry:
  %base.field = getelementptr inbounds %Calculator, ptr %this, i32 0, i32 0
  %base.load = load i32, ptr %base.field, align 4
  %addtmp = add i32 %base.load, %x
  ret i32 %addtmp
}

define i32 @Calculator_sub(ptr %this, i32 %x) {
entry:
  %base.field = getelementptr inbounds %Calculator, ptr %this, i32 0, i32 0
  %base.load = load i32, ptr %base.field, align 4
  %subtmp = sub i32 %base.load, %x
  ret i32 %subtmp
}

define i32 @Calculator_mul(ptr %this, i32 %x) {
entry:
  %base.field = getelementptr inbounds %Calculator, ptr %this, i32 0, i32 0
  %base.load = load i32, ptr %base.field, align 4
  %multmp = mul i32 %base.load, %x
  ret i32 %multmp
}

define i32 @Calculator_div(ptr %this, i32 %x) {
entry:
  %base.field = getelementptr inbounds %Calculator, ptr %this, i32 0, i32 0
  %base.load = load i32, ptr %base.field, align 4
  %divtmp = sdiv i32 %base.load, %x
  ret i32 %divtmp
}

define i32 @Calculator_mod(ptr %this, i32 %x) {
entry:
  %base.field = getelementptr inbounds %Calculator, ptr %this, i32 0, i32 0
  %base.load = load i32, ptr %base.field, align 4
  %modtmp = srem i32 %base.load, %x
  ret i32 %modtmp
}

define i32 @Calculator_neg(ptr %this) {
entry:
  %base.field = getelementptr inbounds %Calculator, ptr %this, i32 0, i32 0
  %base.load = load i32, ptr %base.field, align 4
  %subtmp = sub i32 0, %base.load
  ret i32 %subtmp
}

define i1 @Calculator_isZero(ptr %this) {
entry:
  %base.field = getelementptr inbounds %Calculator, ptr %this, i32 0, i32 0
  %base.load = load i32, ptr %base.field, align 4
  %eqtmp = icmp eq i32 %base.load, 0
  ret i1 %eqtmp
}

define i1 @Calculator_isPositive(ptr %this) {
entry:
  %base.field = getelementptr inbounds %Calculator, ptr %this, i32 0, i32 0
  %base.load = load i32, ptr %base.field, align 4
  %gttmp = icmp sgt i32 %base.load, 0
  ret i1 %gttmp
}

define i32 @Calculator_double(ptr %this) {
entry:
  %base.field = getelementptr inbounds %Calculator, ptr %this, i32 0, i32 0
  %base.load = load i32, ptr %base.field, align 4
  %base.load1 = load i32, ptr %base.field, align 4
  %addtmp = add i32 %base.load, %base.load1
  ret i32 %addtmp
}

define i32 @Calculator_square(ptr %this) {
entry:
  %base.field = getelementptr inbounds %Calculator, ptr %this, i32 0, i32 0
  %base.load = load i32, ptr %base.field, align 4
  %base.load1 = load i32, ptr %base.field, align 4
  %multmp = mul i32 %base.load, %base.load1
  ret i32 %multmp
}

declare void @csec_set_command_line_args(i32, ptr)

define internal i32 @__csec_jit_entry() {
entry:
  %user.main = call i32 @_main()
  ret i32 %user.main
}
