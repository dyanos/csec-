; ModuleID = 'main'
source_filename = "main"

%TreeNode = type { i32, ptr, ptr }
%LinkedNode = type { i32, ptr }

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
  %newobj.malloc = call ptr @malloc(i64 24)
  %value.init = getelementptr inbounds %TreeNode, ptr %newobj.malloc, i32 0, i32 0
  store i32 10, ptr %value.init, align 4
  %newobj.malloc1 = call ptr @malloc(i64 24)
  %value.init2 = getelementptr inbounds %TreeNode, ptr %newobj.malloc1, i32 0, i32 0
  store i32 0, ptr %value.init2, align 4
  %left.init = getelementptr inbounds %TreeNode, ptr %newobj.malloc, i32 0, i32 1
  store ptr null, ptr %left.init, align 8
  %newobj.malloc3 = call ptr @malloc(i64 24)
  %value.init4 = getelementptr inbounds %TreeNode, ptr %newobj.malloc3, i32 0, i32 0
  store i32 0, ptr %value.init4, align 4
  %right.init = getelementptr inbounds %TreeNode, ptr %newobj.malloc, i32 0, i32 2
  store ptr null, ptr %right.init, align 8
  %newobj.malloc5 = call ptr @malloc(i64 24)
  %value.init6 = getelementptr inbounds %TreeNode, ptr %newobj.malloc5, i32 0, i32 0
  store i32 5, ptr %value.init6, align 4
  %newobj.malloc7 = call ptr @malloc(i64 24)
  %value.init8 = getelementptr inbounds %TreeNode, ptr %newobj.malloc7, i32 0, i32 0
  store i32 0, ptr %value.init8, align 4
  %left.init9 = getelementptr inbounds %TreeNode, ptr %newobj.malloc5, i32 0, i32 1
  store ptr null, ptr %left.init9, align 8
  %newobj.malloc10 = call ptr @malloc(i64 24)
  %value.init11 = getelementptr inbounds %TreeNode, ptr %newobj.malloc10, i32 0, i32 0
  store i32 0, ptr %value.init11, align 4
  %right.init12 = getelementptr inbounds %TreeNode, ptr %newobj.malloc5, i32 0, i32 2
  store ptr null, ptr %right.init12, align 8
  %newobj.malloc13 = call ptr @malloc(i64 24)
  %value.init14 = getelementptr inbounds %TreeNode, ptr %newobj.malloc13, i32 0, i32 0
  store i32 15, ptr %value.init14, align 4
  %newobj.malloc15 = call ptr @malloc(i64 24)
  %value.init16 = getelementptr inbounds %TreeNode, ptr %newobj.malloc15, i32 0, i32 0
  store i32 0, ptr %value.init16, align 4
  %left.init17 = getelementptr inbounds %TreeNode, ptr %newobj.malloc13, i32 0, i32 1
  store ptr null, ptr %left.init17, align 8
  %newobj.malloc18 = call ptr @malloc(i64 24)
  %value.init19 = getelementptr inbounds %TreeNode, ptr %newobj.malloc18, i32 0, i32 0
  store i32 0, ptr %value.init19, align 4
  %right.init20 = getelementptr inbounds %TreeNode, ptr %newobj.malloc13, i32 0, i32 2
  store ptr null, ptr %right.init20, align 8
  %newobj.malloc21 = call ptr @malloc(i64 16)
  %data.init = getelementptr inbounds %LinkedNode, ptr %newobj.malloc21, i32 0, i32 0
  store i32 1, ptr %data.init, align 4
  %newobj.malloc22 = call ptr @malloc(i64 16)
  %data.init23 = getelementptr inbounds %LinkedNode, ptr %newobj.malloc22, i32 0, i32 0
  store i32 0, ptr %data.init23, align 4
  %next.init = getelementptr inbounds %LinkedNode, ptr %newobj.malloc21, i32 0, i32 1
  store ptr null, ptr %next.init, align 8
  %newobj.malloc24 = call ptr @malloc(i64 16)
  %data.init25 = getelementptr inbounds %LinkedNode, ptr %newobj.malloc24, i32 0, i32 0
  store i32 2, ptr %data.init25, align 4
  %newobj.malloc26 = call ptr @malloc(i64 16)
  %data.init27 = getelementptr inbounds %LinkedNode, ptr %newobj.malloc26, i32 0, i32 0
  store i32 0, ptr %data.init27, align 4
  %next.init28 = getelementptr inbounds %LinkedNode, ptr %newobj.malloc24, i32 0, i32 1
  store ptr null, ptr %next.init28, align 8
  %newobj.malloc29 = call ptr @malloc(i64 16)
  %data.init30 = getelementptr inbounds %LinkedNode, ptr %newobj.malloc29, i32 0, i32 0
  store i32 3, ptr %data.init30, align 4
  %newobj.malloc31 = call ptr @malloc(i64 16)
  %data.init32 = getelementptr inbounds %LinkedNode, ptr %newobj.malloc31, i32 0, i32 0
  store i32 0, ptr %data.init32, align 4
  %next.init33 = getelementptr inbounds %LinkedNode, ptr %newobj.malloc29, i32 0, i32 1
  store ptr null, ptr %next.init33, align 8
  %calltmp = call i32 @TreeNode_getValue(ptr %newobj.malloc)
  ret i32 %calltmp
}

define i32 @TreeNode_getValue(ptr %this) {
entry:
  %value.field = getelementptr inbounds %TreeNode, ptr %this, i32 0, i32 0
  %left.field = getelementptr inbounds %TreeNode, ptr %this, i32 0, i32 1
  %right.field = getelementptr inbounds %TreeNode, ptr %this, i32 0, i32 2
  %value.load = load i32, ptr %value.field, align 4
  ret i32 %value.load
}

define i32 @LinkedNode_getData(ptr %this) {
entry:
  %data.field = getelementptr inbounds %LinkedNode, ptr %this, i32 0, i32 0
  %next.field = getelementptr inbounds %LinkedNode, ptr %this, i32 0, i32 1
  %data.load = load i32, ptr %data.field, align 4
  ret i32 %data.load
}

declare void @csec_set_command_line_args(i32, ptr)

define internal i32 @__csec_jit_entry() {
entry:
  %user.main = call i32 @_main()
  ret i32 %user.main
}
