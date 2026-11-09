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
  store i32 10, ptr %shared.payload.ptr, align 4
  %shared.strong.ptr1 = getelementptr inbounds { i64, i64, i32 }, ptr %shared.malloc, i32 0, i32 0
  %shared.strong = load i64, ptr %shared.strong.ptr1, align 4
  %shared.inc = add i64 %shared.strong, 1
  store i64 %shared.inc, ptr %shared.strong.ptr1, align 4
  %shared.strong.ptr2 = getelementptr inbounds { i64, i64, i32 }, ptr %shared.malloc, i32 0, i32 0
  %shared.strong3 = load i64, ptr %shared.strong.ptr2, align 4
  %shared.inc4 = add i64 %shared.strong3, 1
  store i64 %shared.inc4, ptr %shared.strong.ptr2, align 4
  %shared.payload.ptr5 = getelementptr inbounds { i64, i64, i32 }, ptr %shared.malloc, i32 0, i32 2
  %shared.get = load i32, ptr %shared.payload.ptr5, align 4
  %shared.payload.ptr6 = getelementptr inbounds { i64, i64, i32 }, ptr %shared.malloc, i32 0, i32 2
  %shared.get7 = load i32, ptr %shared.payload.ptr6, align 4
  %addtmp = add i32 %shared.get, %shared.get7
  %shared.payload.ptr8 = getelementptr inbounds { i64, i64, i32 }, ptr %shared.malloc, i32 0, i32 2
  %shared.get9 = load i32, ptr %shared.payload.ptr8, align 4
  %addtmp10 = add i32 %addtmp, %shared.get9
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
  %block.weak.ptr11 = getelementptr i64, ptr %shared.malloc, i64 1
  %refcount12 = load i64, ptr %shared.malloc, align 4
  %refcount.dec13 = sub i64 %refcount12, 1
  store i64 %refcount.dec13, ptr %shared.malloc, align 4
  %block.strong14 = load i64, ptr %shared.malloc, align 4
  %block.weak15 = load i64, ptr %block.weak.ptr11, align 4
  %weak.zero16 = icmp eq i64 %block.weak15, 0
  %strong.zero17 = icmp eq i64 %block.strong14, 0
  %block.dead18 = and i1 %strong.zero17, %weak.zero16
  br i1 %block.dead18, label %block.free19, label %block.cont20

block.free19:                                     ; preds = %block.cont
  call void @free(ptr %shared.malloc)
  br label %block.cont20

block.cont20:                                     ; preds = %block.free19, %block.cont
  %block.weak.ptr21 = getelementptr i64, ptr %shared.malloc, i64 1
  %refcount22 = load i64, ptr %shared.malloc, align 4
  %refcount.dec23 = sub i64 %refcount22, 1
  store i64 %refcount.dec23, ptr %shared.malloc, align 4
  %block.strong24 = load i64, ptr %shared.malloc, align 4
  %block.weak25 = load i64, ptr %block.weak.ptr21, align 4
  %weak.zero26 = icmp eq i64 %block.weak25, 0
  %strong.zero27 = icmp eq i64 %block.strong24, 0
  %block.dead28 = and i1 %strong.zero27, %weak.zero26
  br i1 %block.dead28, label %block.free29, label %block.cont30

block.free29:                                     ; preds = %block.cont20
  call void @free(ptr %shared.malloc)
  br label %block.cont30

block.cont30:                                     ; preds = %block.free29, %block.cont20
  ret i32 %addtmp10
}

declare void @csec_set_command_line_args(i32, ptr)

define internal i32 @__csec_jit_entry() {
entry:
  %user.main = call i32 @_main()
  ret i32 %user.main
}
