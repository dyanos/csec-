; ModuleID = 'main'
source_filename = "main"

%"\EC\82\AC\EA\B0\81\ED\98\95" = type { i32, i32 }
%"\EC\9B\90" = type { i32 }

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

define i32 @"_\EC\B5\9C\EB\8C\80\EA\B0\92"(i32 %0, i32 %1) {
entry:
  %gttmp = icmp sgt i32 %0, %1
  br i1 %gttmp, label %then, label %else

then:                                             ; preds = %entry
  ret i32 %0

else:                                             ; preds = %entry
  ret i32 %1

ifcont:                                           ; No predecessors!
  ret i32 0
}

define i32 @_main() {
entry:
  %newobj.malloc = call ptr @malloc(i64 8)
  %"\EA\B0\80\EB\A1\9C.init" = getelementptr inbounds %"\EC\82\AC\EA\B0\81\ED\98\95", ptr %newobj.malloc, i32 0, i32 0
  store i32 10, ptr %"\EA\B0\80\EB\A1\9C.init", align 4
  %"\EC\84\B8\EB\A1\9C.init" = getelementptr inbounds %"\EC\82\AC\EA\B0\81\ED\98\95", ptr %newobj.malloc, i32 0, i32 1
  store i32 20, ptr %"\EC\84\B8\EB\A1\9C.init", align 4
  %newobj.malloc1 = call ptr @malloc(i64 4)
  %"\EB\B0\98\EC\A7\80\EB\A6\84.init" = getelementptr inbounds %"\EC\9B\90", ptr %newobj.malloc1, i32 0, i32 0
  store i32 5, ptr %"\EB\B0\98\EC\A7\80\EB\A6\84.init", align 4
  %calltmp = call i32 @"\EC\82\AC\EA\B0\81\ED\98\95_\EB\84\93\EC\9D\B4"(ptr %newobj.malloc)
  %calltmp2 = call i32 @"\EC\82\AC\EA\B0\81\ED\98\95_\EB\91\98\EB\A0\88"(ptr %newobj.malloc)
  %calltmp3 = call i32 @"\EC\9B\90_\EC\A7\80\EB\A6\84"(ptr %newobj.malloc1)
  %calltmp4 = call i32 @"_\EC\B5\9C\EB\8C\80\EA\B0\92"(i32 %calltmp, i32 %calltmp2)
  ret i32 %calltmp4
}

define i32 @"\EC\82\AC\EA\B0\81\ED\98\95_\EB\84\93\EC\9D\B4"(ptr %this) {
entry:
  %"\EA\B0\80\EB\A1\9C.field" = getelementptr inbounds %"\EC\82\AC\EA\B0\81\ED\98\95", ptr %this, i32 0, i32 0
  %"\EC\84\B8\EB\A1\9C.field" = getelementptr inbounds %"\EC\82\AC\EA\B0\81\ED\98\95", ptr %this, i32 0, i32 1
  %"\EA\B0\80\EB\A1\9C.load" = load i32, ptr %"\EA\B0\80\EB\A1\9C.field", align 4
  %"\EC\84\B8\EB\A1\9C.load" = load i32, ptr %"\EC\84\B8\EB\A1\9C.field", align 4
  %multmp = mul i32 %"\EA\B0\80\EB\A1\9C.load", %"\EC\84\B8\EB\A1\9C.load"
  ret i32 %multmp
}

define i32 @"\EC\82\AC\EA\B0\81\ED\98\95_\EB\91\98\EB\A0\88"(ptr %this) {
entry:
  %"\EA\B0\80\EB\A1\9C.field" = getelementptr inbounds %"\EC\82\AC\EA\B0\81\ED\98\95", ptr %this, i32 0, i32 0
  %"\EC\84\B8\EB\A1\9C.field" = getelementptr inbounds %"\EC\82\AC\EA\B0\81\ED\98\95", ptr %this, i32 0, i32 1
  %"\EA\B0\80\EB\A1\9C.load" = load i32, ptr %"\EA\B0\80\EB\A1\9C.field", align 4
  %"\EC\84\B8\EB\A1\9C.load" = load i32, ptr %"\EC\84\B8\EB\A1\9C.field", align 4
  %addtmp = add i32 %"\EA\B0\80\EB\A1\9C.load", %"\EC\84\B8\EB\A1\9C.load"
  %multmp = mul i32 2, %addtmp
  ret i32 %multmp
}

define i32 @"\EC\9B\90_\EC\A7\80\EB\A6\84"(ptr %this) {
entry:
  %"\EB\B0\98\EC\A7\80\EB\A6\84.field" = getelementptr inbounds %"\EC\9B\90", ptr %this, i32 0, i32 0
  %"\EB\B0\98\EC\A7\80\EB\A6\84.load" = load i32, ptr %"\EB\B0\98\EC\A7\80\EB\A6\84.field", align 4
  %multmp = mul i32 %"\EB\B0\98\EC\A7\80\EB\A6\84.load", 2
  ret i32 %multmp
}

define i32 @"\EB\8F\84\ED\98\95\EA\B3\B5\EC\9E\A5#\EC\A0\95\EC\82\AC\EA\B0\81\ED\98\95\EB\A7\8C\EB\93\A4\EA\B8\B0"(i32 %0) {
entry:
  %multmp = mul i32 %0, %0
  ret i32 %multmp
}

declare void @csec_set_command_line_args(i32, ptr)

define internal i32 @__csec_jit_entry() {
entry:
  %user.main = call i32 @_main()
  ret i32 %user.main
}
