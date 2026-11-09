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
  %shared.strong.ptr1 = getelementptr inbounds { i64, i64, i32 }, ptr %shared.malloc, i32 0, i32 0
  %shared.strong = load i64, ptr %shared.strong.ptr1, align 4
  %shared.inc = add i64 %shared.strong, 1
  store i64 %shared.inc, ptr %shared.strong.ptr1, align 4
  %shared.payload.ptr2 = getelementptr inbounds { i64, i64, i32 }, ptr %shared.malloc, i32 0, i32 2
  %shared.get = load i32, ptr %shared.payload.ptr2, align 4
  %block.weak.ptr = getelementptr i64, ptr %shared.malloc, i64 1
  %refcount = load i64, ptr %shared.malloc, align 4
  %refcount.dec = sub i64 %refcount, 1
  store i64 %refcount.dec, ptr %shared.malloc, align 4
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
  %block.weak.ptr3 = getelementptr i64, ptr %shared.malloc, i64 1
  %refcount4 = load i64, ptr %shared.malloc, align 4
  %refcount.dec5 = sub i64 %refcount4, 1
  store i64 %refcount.dec5, ptr %shared.malloc, align 4
  %block.strong6 = load i64, ptr %shared.malloc, align 4
  %block.weak7 = load i64, ptr %block.weak.ptr3, align 4
  %weak.zero8 = icmp eq i64 %block.weak7, 0
  %strong.zero9 = icmp eq i64 %block.strong6, 0
  %block.dead10 = and i1 %strong.zero9, %weak.zero8
  br i1 %block.dead10, label %block.free11, label %block.cont12

block.free11:                                     ; preds = %block.cont
  call void @free(ptr %shared.malloc)
  br label %block.cont12

block.cont12:                                     ; preds = %block.free11, %block.cont
  ret i32 %shared.get
}

declare void @csec_set_command_line_args(i32, ptr)

define internal i32 @__csec_jit_entry() {
entry:
  %user.main = call i32 @_main()
  ret i32 %user.main
}
