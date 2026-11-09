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
  %shared.malloc = call ptr @malloc(i64 12)
  %shared.strong.ptr = getelementptr inbounds { i64, i32 }, ptr %shared.malloc, i32 0, i32 0
  store i64 1, ptr %shared.strong.ptr, align 4
  %shared.payload.ptr = getelementptr inbounds { i64, i32 }, ptr %shared.malloc, i32 0, i32 1
  store i32 42, ptr %shared.payload.ptr, align 4
  %shared.strong.ptr1 = getelementptr inbounds { i64, i32 }, ptr %shared.malloc, i32 0, i32 0
  %shared.strong = load i64, ptr %shared.strong.ptr1, align 4
  %shared.inc = add i64 %shared.strong, 1
  store i64 %shared.inc, ptr %shared.strong.ptr1, align 4
  %shared.payload.ptr2 = getelementptr inbounds { i64, i32 }, ptr %shared.malloc, i32 0, i32 1
  %shared.get = load i32, ptr %shared.payload.ptr2, align 4
  %shared.strong3 = load i64, ptr %shared.malloc, align 4
  %shared.dec = sub i64 %shared.strong3, 1
  store i64 %shared.dec, ptr %shared.malloc, align 4
  %shared.zero = icmp eq i64 %shared.dec, 0
  br i1 %shared.zero, label %shared.free, label %shared.cont

shared.free:                                      ; preds = %entry
  call void @free(ptr %shared.malloc)
  br label %shared.cont

shared.cont:                                      ; preds = %shared.free, %entry
  %shared.strong4 = load i64, ptr %shared.malloc, align 4
  %shared.dec5 = sub i64 %shared.strong4, 1
  store i64 %shared.dec5, ptr %shared.malloc, align 4
  %shared.zero6 = icmp eq i64 %shared.dec5, 0
  br i1 %shared.zero6, label %shared.free7, label %shared.cont8

shared.free7:                                     ; preds = %shared.cont
  call void @free(ptr %shared.malloc)
  br label %shared.cont8

shared.cont8:                                     ; preds = %shared.free7, %shared.cont
  ret i32 %shared.get
}

declare void @csec_set_command_line_args(i32, ptr)

define internal i32 @__csec_jit_entry() {
entry:
  %user.main = call i32 @_main()
  ret i32 %user.main
}
