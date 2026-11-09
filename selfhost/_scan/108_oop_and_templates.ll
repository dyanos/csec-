; ModuleID = 'main'
source_filename = "main"

%"Kennel$Dog$10" = type { ptr, i32 }
%Dog = type { ptr, i32, ptr }
%"Kennel$Dog$10.0" = type { ptr, i32 }
%Animal = type { ptr, i32 }

@totalAnimals = private constant i32 0
@0 = private unnamed_addr constant [4 x i8] c"Rex\00", align 1
@1 = private unnamed_addr constant [9 x i8] c"Labrador\00", align 1
@2 = private unnamed_addr constant [5 x i8] c"Main\00", align 1

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

define i32 @"Kennel$Dog$10_getCapacity"(ptr %this) {
entry:
  %name.field = getelementptr inbounds %"Kennel$Dog$10", ptr %this, i32 0, i32 0
  %count.field = getelementptr inbounds %"Kennel$Dog$10", ptr %this, i32 0, i32 1
  ret i32 10
}

define i32 @"Kennel$Dog$10_getCount"(ptr %this) {
entry:
  %name.field = getelementptr inbounds %"Kennel$Dog$10", ptr %this, i32 0, i32 0
  %count.field = getelementptr inbounds %"Kennel$Dog$10", ptr %this, i32 0, i32 1
  %count.load = load i32, ptr %count.field, align 4
  ret i32 %count.load
}

define i32 @"Kennel$Dog$10_add"(ptr %this) {
entry:
  %name.field = getelementptr inbounds %"Kennel$Dog$10", ptr %this, i32 0, i32 0
  %count.field = getelementptr inbounds %"Kennel$Dog$10", ptr %this, i32 0, i32 1
  %count.load = load i32, ptr %count.field, align 4
  %lttmp = icmp slt i32 %count.load, 10
  br i1 %lttmp, label %then, label %ifcont

then:                                             ; preds = %entry
  %count.load1 = load i32, ptr %count.field, align 4
  %count.load2 = load i32, ptr %count.field, align 4
  %addtmp = add i32 %count.load2, 1
  store i32 %addtmp, ptr %count.field, align 4
  br label %ifcont

ifcont:                                           ; preds = %then, %entry
  %count.load3 = load i32, ptr %count.field, align 4
  ret i32 %count.load3
}

define i32 @_main() {
entry:
  %newobj.malloc = call ptr @malloc(i64 24)
  %name.init = getelementptr inbounds %Dog, ptr %newobj.malloc, i32 0, i32 0
  store ptr @0, ptr %name.init, align 8
  %age.init = getelementptr inbounds %Dog, ptr %newobj.malloc, i32 0, i32 1
  store i32 3, ptr %age.init, align 4
  %breed.init = getelementptr inbounds %Dog, ptr %newobj.malloc, i32 0, i32 2
  store ptr @1, ptr %breed.init, align 8
  %calltmp = call i32 @Animal_getAge(ptr %newobj.malloc)
  %calltmp1 = call i32 @Dog_bark(ptr %newobj.malloc)
  %newobj.malloc2 = call ptr @malloc(i64 16)
  %name.init3 = getelementptr inbounds %"Kennel$Dog$10.0", ptr %newobj.malloc2, i32 0, i32 0
  store ptr @2, ptr %name.init3, align 8
  %count.init = getelementptr inbounds %"Kennel$Dog$10.0", ptr %newobj.malloc2, i32 0, i32 1
  store i32 0, ptr %count.init, align 4
  %calltmp4 = call i32 @"Kennel$Dog$10_add.3"(ptr %newobj.malloc2)
  %calltmp5 = call i32 @"Kennel$Dog$10_add.3"(ptr %newobj.malloc2)
  %calltmp6 = call i32 @"Kennel$Dog$10_add.3"(ptr %newobj.malloc2)
  %calltmp7 = call i32 @"Kennel$Dog$10_getCount.2"(ptr %newobj.malloc2)
  %calltmp8 = call i32 @"Kennel$Dog$10_getCapacity.1"(ptr %newobj.malloc2)
  %calltmp9 = call i32 @"Shelter#report"()
  %addtmp = add i32 %calltmp, %calltmp1
  %addtmp10 = add i32 %addtmp, %calltmp7
  %addtmp11 = add i32 %addtmp10, %calltmp8
  %addtmp12 = add i32 %addtmp11, %calltmp9
  ret i32 %addtmp12
}

define ptr @Animal_getName(ptr %this) {
entry:
  %name.field = getelementptr inbounds %Animal, ptr %this, i32 0, i32 0
  %age.field = getelementptr inbounds %Animal, ptr %this, i32 0, i32 1
  %name.load = load ptr, ptr %name.field, align 8
  ret ptr %name.load
}

define i32 @Animal_getAge(ptr %this) {
entry:
  %name.field = getelementptr inbounds %Animal, ptr %this, i32 0, i32 0
  %age.field = getelementptr inbounds %Animal, ptr %this, i32 0, i32 1
  %age.load = load i32, ptr %age.field, align 4
  ret i32 %age.load
}

define ptr @Dog_getBreed(ptr %this) {
entry:
  %name.field = getelementptr inbounds %Dog, ptr %this, i32 0, i32 0
  %age.field = getelementptr inbounds %Dog, ptr %this, i32 0, i32 1
  %breed.field = getelementptr inbounds %Dog, ptr %this, i32 0, i32 2
  %breed.load = load ptr, ptr %breed.field, align 8
  ret ptr %breed.load
}

define i32 @Dog_bark(ptr %this) {
entry:
  %name.field = getelementptr inbounds %Dog, ptr %this, i32 0, i32 0
  %age.field = getelementptr inbounds %Dog, ptr %this, i32 0, i32 1
  %breed.field = getelementptr inbounds %Dog, ptr %this, i32 0, i32 2
  ret i32 1
}

define i32 @"Shelter#report"() {
entry:
  %totalAnimals.load = load i32, ptr @totalAnimals, align 4
  ret i32 %totalAnimals.load
}

define i32 @"Kennel$Dog$10_getCapacity.1"(ptr %this) {
entry:
  %name.field = getelementptr inbounds %"Kennel$Dog$10.0", ptr %this, i32 0, i32 0
  %count.field = getelementptr inbounds %"Kennel$Dog$10.0", ptr %this, i32 0, i32 1
  ret i32 10
}

define i32 @"Kennel$Dog$10_getCount.2"(ptr %this) {
entry:
  %name.field = getelementptr inbounds %"Kennel$Dog$10.0", ptr %this, i32 0, i32 0
  %count.field = getelementptr inbounds %"Kennel$Dog$10.0", ptr %this, i32 0, i32 1
  %count.load = load i32, ptr %count.field, align 4
  ret i32 %count.load
}

define i32 @"Kennel$Dog$10_add.3"(ptr %this) {
entry:
  %name.field = getelementptr inbounds %"Kennel$Dog$10.0", ptr %this, i32 0, i32 0
  %count.field = getelementptr inbounds %"Kennel$Dog$10.0", ptr %this, i32 0, i32 1
  %count.load = load i32, ptr %count.field, align 4
  %lttmp = icmp slt i32 %count.load, 10
  br i1 %lttmp, label %then, label %ifcont

then:                                             ; preds = %entry
  %count.load1 = load i32, ptr %count.field, align 4
  %count.load2 = load i32, ptr %count.field, align 4
  %addtmp = add i32 %count.load2, 1
  store i32 %addtmp, ptr %count.field, align 4
  br label %ifcont

ifcont:                                           ; preds = %then, %entry
  %count.load3 = load i32, ptr %count.field, align 4
  ret i32 %count.load3
}

declare void @csec_set_command_line_args(i32, ptr)

define internal i32 @__csec_jit_entry() {
entry:
  %user.main = call i32 @_main()
  ret i32 %user.main
}
