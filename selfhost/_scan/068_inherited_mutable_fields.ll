; ModuleID = 'main'
source_filename = "main"

%Child = type { i32, i32, i32 }
%Base = type { i32, i32 }

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
  %newobj.malloc = call ptr @malloc(i64 12)
  %value.init = getelementptr inbounds %Child, ptr %newobj.malloc, i32 0, i32 0
  store i32 10, ptr %value.init, align 4
  %count.init = getelementptr inbounds %Child, ptr %newobj.malloc, i32 0, i32 1
  store i32 1, ptr %count.init, align 4
  %bonus.init = getelementptr inbounds %Child, ptr %newobj.malloc, i32 0, i32 2
  store i32 2, ptr %bonus.init, align 4
  %calltmp = call i32 @Child_inherited(ptr %newobj.malloc)
  ret i32 %calltmp
}

define i32 @Base_current(ptr %this) {
entry:
  %value.field = getelementptr inbounds %Base, ptr %this, i32 0, i32 0
  %count.field = getelementptr inbounds %Base, ptr %this, i32 0, i32 1
  %value.load = load i32, ptr %value.field, align 4
  %count.load = load i32, ptr %count.field, align 4
  %addtmp = add i32 %value.load, %count.load
  ret i32 %addtmp
}

define i32 @Child_inherited(ptr %this) {
entry:
  %value.field = getelementptr inbounds %Child, ptr %this, i32 0, i32 0
  %count.field = getelementptr inbounds %Child, ptr %this, i32 0, i32 1
  %bonus.field = getelementptr inbounds %Child, ptr %this, i32 0, i32 2
  %calltmp = call i32 @Base_current(ptr %this)
  %bonus.load = load i32, ptr %bonus.field, align 4
  %num.sitofp = sitofp i32 %calltmp to double
  %num.sitofp1 = sitofp i32 %bonus.load to double
  %faddtmp = fadd double %num.sitofp, %num.sitofp1
  %abi.fptosi = fptosi double %faddtmp to i32
  ret i32 %abi.fptosi
}

declare void @csec_set_command_line_args(i32, ptr)

define internal i32 @__csec_jit_entry() {
entry:
  %user.main = call i32 @_main()
  ret i32 %user.main
}
