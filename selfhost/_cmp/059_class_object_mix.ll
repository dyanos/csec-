; ModuleID = 'main'
source_filename = "main"

%Client = type { ptr, i32 }
%Server = type { i32 }

@maxRetries = private constant i32 3
@timeout = private constant i32 30
@0 = private unnamed_addr constant [5 x i8] c"test\00", align 1

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
  %newobj.malloc = call ptr @malloc(i64 16)
  %name.init = getelementptr inbounds %Client, ptr %newobj.malloc, i32 0, i32 0
  store ptr @0, ptr %name.init, align 8
  %retries.init = getelementptr inbounds %Client, ptr %newobj.malloc, i32 0, i32 1
  store i32 0, ptr %retries.init, align 4
  %newobj.malloc1 = call ptr @malloc(i64 4)
  %port.init = getelementptr inbounds %Server, ptr %newobj.malloc1, i32 0, i32 0
  store i32 8080, ptr %port.init, align 4
  %calltmp = call i32 @Client_connect(ptr %newobj.malloc)
  %calltmp2 = call i32 @Server_start(ptr %newobj.malloc1)
  %addtmp = add i32 %calltmp, %calltmp2
  ret i32 %addtmp
}

define i32 @"Config#getMaxRetries"() {
entry:
  ret i32 0
}

define i32 @"Config#getTimeout"() {
entry:
  ret i32 0
}

define i32 @Client_connect(ptr %this) {
entry:
  %name.field = getelementptr inbounds %Client, ptr %this, i32 0, i32 0
  %retries.field = getelementptr inbounds %Client, ptr %this, i32 0, i32 1
  %calltmp = call i32 @"Config#getMaxRetries"()
  %calltmp1 = call i32 @"Config#getTimeout"()
  %addtmp = add i32 %calltmp, %calltmp1
  ret i32 %addtmp
}

define i32 @Server_start(ptr %this) {
entry:
  %port.field = getelementptr inbounds %Server, ptr %this, i32 0, i32 0
  %port.load = load i32, ptr %port.field, align 4
  ret i32 %port.load
}

define i32 @Server_configure(ptr %this) {
entry:
  %port.field = getelementptr inbounds %Server, ptr %this, i32 0, i32 0
  %calltmp = call i32 @"Config#getTimeout"()
  ret i32 %calltmp
}

declare void @csec_set_command_line_args(i32, ptr)

define internal i32 @__csec_jit_entry() {
entry:
  %user.main = call i32 @_main()
  ret i32 %user.main
}
