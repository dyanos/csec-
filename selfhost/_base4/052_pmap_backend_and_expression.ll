; ModuleID = 'main'
source_filename = "main"

@0 = private unnamed_addr constant [7 x i8] c"openmp\00", align 1

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
  %arrlit = alloca i32, i32 4, align 4
  %0 = getelementptr i32, ptr %arrlit, i32 0
  store i32 1, ptr %0, align 4
  %1 = getelementptr i32, ptr %arrlit, i32 1
  store i32 2, ptr %1, align 4
  %2 = getelementptr i32, ptr %arrlit, i32 2
  store i32 3, ptr %2, align 4
  %3 = getelementptr i32, ptr %arrlit, i32 3
  store i32 4, ptr %3, align 4
  %parallel.threads = call i32 @csec_parallel_get_num_threads()
  %math.sext = sext i32 %parallel.threads to i64
  %parallel.thread.count = trunc i64 %math.sext to i32
  call void @csec_parallel_set_num_threads(i32 %parallel.thread.count)
  %parallel.backend.available = call i32 @csec_parallel_backend_available(ptr @0)
  ret i32 0
}

declare i32 @csec_parallel_get_num_threads()

declare void @csec_parallel_set_num_threads(i32)

declare i32 @csec_parallel_backend_available(ptr)

declare void @csec_set_command_line_args(i32, ptr)

define internal i32 @__csec_jit_entry() {
entry:
  %user.main = call i32 @_main()
  ret i32 %user.main
}
