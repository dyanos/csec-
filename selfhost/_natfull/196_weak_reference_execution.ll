; ModuleID = 'main'
source_filename = "main"

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
  %shared.malloc = call ptr @malloc(i64 20)
  %shared.strong.ptr = getelementptr inbounds { i64, i64, i32 }, ptr %shared.malloc, i32 0, i32 0
  store i64 1, ptr %shared.strong.ptr, align 4
  %shared.weak.ptr = getelementptr inbounds { i64, i64, i32 }, ptr %shared.malloc, i32 0, i32 1
  store i64 0, ptr %shared.weak.ptr, align 4
  %shared.payload.ptr = getelementptr inbounds { i64, i64, i32 }, ptr %shared.malloc, i32 0, i32 2
  store i32 42, ptr %shared.payload.ptr, align 4
  %weak.count.ptr = getelementptr i64, ptr %shared.malloc, i64 1
  %weak.count = load i64, ptr %weak.count.ptr, align 4
  %weak.inc = add i64 %weak.count, 1
  store i64 %weak.inc, ptr %weak.count.ptr, align 4
  %shared.payload.ptr1 = getelementptr inbounds { i64, i64, i32 }, ptr %shared.malloc, i32 0, i32 2
  %shared.get = load i32, ptr %shared.payload.ptr1, align 4
  %weak.strong.ptr = getelementptr inbounds { i64, i64, i32 }, ptr %shared.malloc, i32 0, i32 0
  %weak.strong = load i64, ptr %weak.strong.ptr, align 4
  %weak.alive = icmp sgt i64 %weak.strong, 0
  %weak.get = select i1 %weak.alive, i32 %shared.get, i32 0
  %block.weak.ptr = getelementptr i64, ptr %shared.malloc, i64 1
  %refcount = load i64, ptr %block.weak.ptr, align 4
  %refcount.dec = sub i64 %refcount, 1
  store i64 %refcount.dec, ptr %block.weak.ptr, align 4
  %block.strong = load i64, ptr %shared.malloc, align 4
  %block.weak = load i64, ptr %block.weak.ptr, align 4
  %weak.zero = icmp eq i64 %block.weak, 0
  %strong.zero = icmp eq i64 %block.strong, 0
  %block.dead = and i1 %strong.zero, %weak.zero
  br i1 %block.dead, label %block.free, label %block.cont

block.free:                                       ; preds = %entry
  call void @free(ptr %shared.malloc)
  br label %block.cont

block.cont:                                       ; preds = %block.free, %entry
  %block.weak.ptr2 = getelementptr i64, ptr %shared.malloc, i64 1
  %refcount3 = load i64, ptr %shared.malloc, align 4
  %refcount.dec4 = sub i64 %refcount3, 1
  store i64 %refcount.dec4, ptr %shared.malloc, align 4
  %block.strong5 = load i64, ptr %shared.malloc, align 4
  %block.weak6 = load i64, ptr %block.weak.ptr2, align 4
  %weak.zero7 = icmp eq i64 %block.weak6, 0
  %strong.zero8 = icmp eq i64 %block.strong5, 0
  %block.dead9 = and i1 %strong.zero8, %weak.zero7
  br i1 %block.dead9, label %block.free10, label %block.cont11

block.free10:                                     ; preds = %block.cont
  call void @free(ptr %shared.malloc)
  br label %block.cont11

block.cont11:                                     ; preds = %block.free10, %block.cont
  ret i32 %weak.get
}

declare void @csec_set_command_line_args(i32, ptr)

define internal i32 @__csec_jit_entry() {
entry:
  %user.main = call i32 @_main()
  ret i32 %user.main
}
