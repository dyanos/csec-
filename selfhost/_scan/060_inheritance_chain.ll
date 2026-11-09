; ModuleID = 'main'
source_filename = "main"

%Base = type { i32 }
%Middle = type { i32 }
%Leaf = type { i32 }
%Polygon = type { ptr, i32 }
%RegularPolygon = type { ptr, i32, i32 }
%Shape = type { ptr }

@0 = private unnamed_addr constant [9 x i8] c"triangle\00", align 1
@1 = private unnamed_addr constant [7 x i8] c"square\00", align 1

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
  %id.init = getelementptr inbounds %Base, ptr %newobj.malloc, i32 0, i32 0
  store i32 1, ptr %id.init, align 4
  %newobj.malloc1 = call ptr @malloc(i64 4)
  %id.init2 = getelementptr inbounds %Middle, ptr %newobj.malloc1, i32 0, i32 0
  store i32 2, ptr %id.init2, align 4
  %newobj.malloc3 = call ptr @malloc(i64 4)
  %id.init4 = getelementptr inbounds %Leaf, ptr %newobj.malloc3, i32 0, i32 0
  store i32 3, ptr %id.init4, align 4
  %newobj.malloc5 = call ptr @malloc(i64 16)
  %name.init = getelementptr inbounds %Polygon, ptr %newobj.malloc5, i32 0, i32 0
  store ptr @0, ptr %name.init, align 8
  %sides.init = getelementptr inbounds %Polygon, ptr %newobj.malloc5, i32 0, i32 1
  store i32 3, ptr %sides.init, align 4
  %newobj.malloc6 = call ptr @malloc(i64 16)
  %name.init7 = getelementptr inbounds %RegularPolygon, ptr %newobj.malloc6, i32 0, i32 0
  store ptr @1, ptr %name.init7, align 8
  %sides.init8 = getelementptr inbounds %RegularPolygon, ptr %newobj.malloc6, i32 0, i32 1
  store i32 4, ptr %sides.init8, align 4
  %length.init = getelementptr inbounds %RegularPolygon, ptr %newobj.malloc6, i32 0, i32 2
  store i32 5, ptr %length.init, align 4
  ret i32 0
}

define i32 @Base_getId(ptr %this) {
entry:
  %id.field = getelementptr inbounds %Base, ptr %this, i32 0, i32 0
  %id.load = load i32, ptr %id.field, align 4
  ret i32 %id.load
}

define i32 @Middle_getMiddle(ptr %this) {
entry:
  %id.field = getelementptr inbounds %Middle, ptr %this, i32 0, i32 0
  %id.load = load i32, ptr %id.field, align 4
  %addtmp = add i32 %id.load, 10
  ret i32 %addtmp
}

define i32 @Leaf_getLeaf(ptr %this) {
entry:
  %id.field = getelementptr inbounds %Leaf, ptr %this, i32 0, i32 0
  %id.load = load i32, ptr %id.field, align 4
  %addtmp = add i32 %id.load, 100
  ret i32 %addtmp
}

define i32 @Shape_describe(ptr %this) {
entry:
  %name.field = getelementptr inbounds %Shape, ptr %this, i32 0, i32 0
  ret i32 0
}

define i32 @Polygon_getSides(ptr %this) {
entry:
  %name.field = getelementptr inbounds %Polygon, ptr %this, i32 0, i32 0
  %sides.field = getelementptr inbounds %Polygon, ptr %this, i32 0, i32 1
  %sides.load = load i32, ptr %sides.field, align 4
  ret i32 %sides.load
}

define i32 @RegularPolygon_perimeter(ptr %this) {
entry:
  %name.field = getelementptr inbounds %RegularPolygon, ptr %this, i32 0, i32 0
  %sides.field = getelementptr inbounds %RegularPolygon, ptr %this, i32 0, i32 1
  %length.field = getelementptr inbounds %RegularPolygon, ptr %this, i32 0, i32 2
  %sides.load = load i32, ptr %sides.field, align 4
  %length.load = load i32, ptr %length.field, align 4
  %multmp = mul i32 %sides.load, %length.load
  ret i32 %multmp
}

declare void @csec_set_command_line_args(i32, ptr)

define internal i32 @__csec_jit_entry() {
entry:
  %user.main = call i32 @_main()
  ret i32 %user.main
}
