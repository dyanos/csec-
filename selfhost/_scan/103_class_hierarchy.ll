; ModuleID = 'main'
source_filename = "main"

%Rectangle = type { ptr, i32, i32 }
%Square = type { ptr, i32 }
%Circle = type { ptr, i32 }
%Shape = type { ptr }

@0 = private unnamed_addr constant [5 x i8] c"rect\00", align 1
@1 = private unnamed_addr constant [3 x i8] c"sq\00", align 1
@2 = private unnamed_addr constant [5 x i8] c"circ\00", align 1

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
  %name.init = getelementptr inbounds %Rectangle, ptr %newobj.malloc, i32 0, i32 0
  store ptr @0, ptr %name.init, align 8
  %width.init = getelementptr inbounds %Rectangle, ptr %newobj.malloc, i32 0, i32 1
  store i32 10, ptr %width.init, align 4
  %height.init = getelementptr inbounds %Rectangle, ptr %newobj.malloc, i32 0, i32 2
  store i32 20, ptr %height.init, align 4
  %newobj.malloc1 = call ptr @malloc(i64 16)
  %name.init2 = getelementptr inbounds %Square, ptr %newobj.malloc1, i32 0, i32 0
  store ptr @1, ptr %name.init2, align 8
  %side.init = getelementptr inbounds %Square, ptr %newobj.malloc1, i32 0, i32 1
  store i32 5, ptr %side.init, align 4
  %newobj.malloc3 = call ptr @malloc(i64 16)
  %name.init4 = getelementptr inbounds %Circle, ptr %newobj.malloc3, i32 0, i32 0
  store ptr @2, ptr %name.init4, align 8
  %radius.init = getelementptr inbounds %Circle, ptr %newobj.malloc3, i32 0, i32 1
  store i32 7, ptr %radius.init, align 4
  %calltmp = call i32 @Rectangle_area(ptr %newobj.malloc)
  %calltmp5 = call i32 @Circle_area(ptr %newobj.malloc3)
  %calltmp6 = call i32 @Rectangle_perimeter(ptr %newobj.malloc)
  %calltmp7 = call i32 @"ShapeFactory#createRectangle"(i32 3, i32 4)
  %calltmp8 = call i32 @"ShapeFactory#createSquare"(i32 5)
  %calltmp9 = call i32 @"ShapeFactory#createCircle"(i32 10)
  %addtmp = add i32 %calltmp, %calltmp5
  %addtmp10 = add i32 %addtmp, %calltmp6
  %addtmp11 = add i32 %addtmp10, %calltmp7
  %addtmp12 = add i32 %addtmp11, %calltmp8
  %addtmp13 = add i32 %addtmp12, %calltmp9
  ret i32 %addtmp13
}

define ptr @Shape_getName(ptr %this) {
entry:
  %name.field = getelementptr inbounds %Shape, ptr %this, i32 0, i32 0
  %name.load = load ptr, ptr %name.field, align 8
  ret ptr %name.load
}

define i32 @Shape_area(ptr %this) {
entry:
  %name.field = getelementptr inbounds %Shape, ptr %this, i32 0, i32 0
  ret i32 0
}

define i32 @Rectangle_area(ptr %this) {
entry:
  %name.field = getelementptr inbounds %Rectangle, ptr %this, i32 0, i32 0
  %width.field = getelementptr inbounds %Rectangle, ptr %this, i32 0, i32 1
  %height.field = getelementptr inbounds %Rectangle, ptr %this, i32 0, i32 2
  %width.load = load i32, ptr %width.field, align 4
  %height.load = load i32, ptr %height.field, align 4
  %multmp = mul i32 %width.load, %height.load
  ret i32 %multmp
}

define i32 @Rectangle_perimeter(ptr %this) {
entry:
  %name.field = getelementptr inbounds %Rectangle, ptr %this, i32 0, i32 0
  %width.field = getelementptr inbounds %Rectangle, ptr %this, i32 0, i32 1
  %height.field = getelementptr inbounds %Rectangle, ptr %this, i32 0, i32 2
  %width.load = load i32, ptr %width.field, align 4
  %height.load = load i32, ptr %height.field, align 4
  %addtmp = add i32 %width.load, %height.load
  %multmp = mul i32 2, %addtmp
  ret i32 %multmp
}

define i32 @Square_getSide(ptr %this) {
entry:
  %name.field = getelementptr inbounds %Square, ptr %this, i32 0, i32 0
  %side.field = getelementptr inbounds %Square, ptr %this, i32 0, i32 1
  %side.load = load i32, ptr %side.field, align 4
  ret i32 %side.load
}

define i32 @Circle_area(ptr %this) {
entry:
  %name.field = getelementptr inbounds %Circle, ptr %this, i32 0, i32 0
  %radius.field = getelementptr inbounds %Circle, ptr %this, i32 0, i32 1
  %radius.load = load i32, ptr %radius.field, align 4
  %radius.load1 = load i32, ptr %radius.field, align 4
  %multmp = mul i32 %radius.load, %radius.load1
  %multmp2 = mul i32 %multmp, 3
  ret i32 %multmp2
}

define i32 @Circle_circumference(ptr %this) {
entry:
  %name.field = getelementptr inbounds %Circle, ptr %this, i32 0, i32 0
  %radius.field = getelementptr inbounds %Circle, ptr %this, i32 0, i32 1
  %radius.load = load i32, ptr %radius.field, align 4
  %multmp = mul i32 2, %radius.load
  %multmp1 = mul i32 %multmp, 3
  ret i32 %multmp1
}

define i32 @"ShapeFactory#createRectangle"(i32 %0, i32 %1) {
entry:
  %multmp = mul i32 %0, %1
  ret i32 %multmp
}

define i32 @"ShapeFactory#createSquare"(i32 %0) {
entry:
  %multmp = mul i32 %0, %0
  ret i32 %multmp
}

define i32 @"ShapeFactory#createCircle"(i32 %0) {
entry:
  %multmp = mul i32 %0, %0
  %multmp1 = mul i32 %multmp, 3
  ret i32 %multmp1
}

declare void @csec_set_command_line_args(i32, ptr)

define internal i32 @__csec_jit_entry() {
entry:
  %user.main = call i32 @_main()
  ret i32 %user.main
}
