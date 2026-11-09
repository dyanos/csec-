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
  %left.init = getelementptr inbounds %TreeNode, ptr %newobj.malloc, i32 0, i32 1
  store ptr null, ptr %left.init, align 8
  %newobj.malloc2 = call ptr @malloc(i64 24)
  %right.init = getelementptr inbounds %TreeNode, ptr %newobj.malloc, i32 0, i32 2
  store ptr null, ptr %right.init, align 8
  %newobj.malloc3 = call ptr @malloc(i64 24)
  %value.init4 = getelementptr inbounds %TreeNode, ptr %newobj.malloc3, i32 0, i32 0
  store i32 5, ptr %value.init4, align 4
  %newobj.malloc5 = call ptr @malloc(i64 24)
  %left.init6 = getelementptr inbounds %TreeNode, ptr %newobj.malloc3, i32 0, i32 1
  store ptr null, ptr %left.init6, align 8
  %newobj.malloc7 = call ptr @malloc(i64 24)
  %right.init8 = getelementptr inbounds %TreeNode, ptr %newobj.malloc3, i32 0, i32 2
  store ptr null, ptr %right.init8, align 8
  %newobj.malloc9 = call ptr @malloc(i64 24)
  %value.init10 = getelementptr inbounds %TreeNode, ptr %newobj.malloc9, i32 0, i32 0
  store i32 15, ptr %value.init10, align 4
  %newobj.malloc11 = call ptr @malloc(i64 24)
  %left.init12 = getelementptr inbounds %TreeNode, ptr %newobj.malloc9, i32 0, i32 1
  store ptr null, ptr %left.init12, align 8
  %newobj.malloc13 = call ptr @malloc(i64 24)
  %right.init14 = getelementptr inbounds %TreeNode, ptr %newobj.malloc9, i32 0, i32 2
  store ptr null, ptr %right.init14, align 8
  %newobj.malloc15 = call ptr @malloc(i64 16)
  %data.init = getelementptr inbounds %LinkedNode, ptr %newobj.malloc15, i32 0, i32 0
  store i32 1, ptr %data.init, align 4
  %newobj.malloc16 = call ptr @malloc(i64 16)
  %next.init = getelementptr inbounds %LinkedNode, ptr %newobj.malloc15, i32 0, i32 1
  store ptr null, ptr %next.init, align 8
  %newobj.malloc17 = call ptr @malloc(i64 16)
  %data.init18 = getelementptr inbounds %LinkedNode, ptr %newobj.malloc17, i32 0, i32 0
  store i32 2, ptr %data.init18, align 4
  %newobj.malloc19 = call ptr @malloc(i64 16)
  %next.init20 = getelementptr inbounds %LinkedNode, ptr %newobj.malloc17, i32 0, i32 1
  store ptr null, ptr %next.init20, align 8
  %newobj.malloc21 = call ptr @malloc(i64 16)
  %data.init22 = getelementptr inbounds %LinkedNode, ptr %newobj.malloc21, i32 0, i32 0
  store i32 3, ptr %data.init22, align 4
  %newobj.malloc23 = call ptr @malloc(i64 16)
  %next.init24 = getelementptr inbounds %LinkedNode, ptr %newobj.malloc21, i32 0, i32 1
  store ptr null, ptr %next.init24, align 8
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
