; ModuleID = 'main'
source_filename = "main"

@0 = private unnamed_addr constant [4 x i8] c"cpu\00", align 1
@1 = private unnamed_addr constant [7 x i8] c"openmp\00", align 1
@2 = private unnamed_addr constant [5 x i8] c"simd\00", align 1
@3 = private unnamed_addr constant [4 x i8] c"gpu\00", align 1
@4 = private unnamed_addr constant [4 x i8] c"gpu\00", align 1
@5 = private unnamed_addr constant [6 x i8] c"metal\00", align 1

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
  call void @csec_parallel_set_num_threads(i32 0)
  %parallel.threads = call i32 @csec_parallel_get_num_threads()
  call void @csec_parallel_set_num_threads(i32 4)
  %parallel.threads1 = call i32 @csec_parallel_get_num_threads()
  %parallel.backend.available = call i32 @csec_parallel_backend_available(ptr @0)
  %parallel.backend.available2 = call i32 @csec_parallel_backend_available(ptr @1)
  %parallel.backend.available3 = call i32 @csec_parallel_backend_available(ptr @2)
  %parallel.backend.available4 = call i32 @csec_parallel_backend_available(ptr @3)
  %parallel.backend.implemented = call i32 @csec_parallel_backend_implemented(ptr @4)
  %parallel.backend.available5 = call i32 @csec_parallel_backend_available(ptr @5)
  %addtmp = add i32 %parallel.threads, %parallel.threads1
  %addtmp6 = add i32 %addtmp, %parallel.backend.available
  %addtmp7 = add i32 %addtmp6, %parallel.backend.available2
  %addtmp8 = add i32 %addtmp7, %parallel.backend.available3
  %addtmp9 = add i32 %addtmp8, %parallel.backend.available4
  %addtmp10 = add i32 %addtmp9, %parallel.backend.implemented
  %addtmp11 = add i32 %addtmp10, %parallel.backend.available5
  ret i32 %addtmp11
}

declare void @csec_parallel_set_num_threads(i32)

declare i32 @csec_parallel_get_num_threads()

declare i32 @csec_parallel_backend_available(ptr)

declare i32 @csec_parallel_backend_implemented(ptr)

declare void @csec_set_command_line_args(i32, ptr)

define internal i32 @__csec_jit_entry() {
entry:
  %user.main = call i32 @_main()
  ret i32 %user.main
}
