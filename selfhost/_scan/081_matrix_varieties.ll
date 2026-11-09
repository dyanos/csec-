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
  %arrlit = alloca float, i32 2, align 4
  %0 = getelementptr float, ptr %arrlit, i32 0
  store float 1.000000e+00, ptr %0, align 4
  %1 = getelementptr float, ptr %arrlit, i32 1
  store float 0.000000e+00, ptr %1, align 4
  %arrlit1 = alloca ptr, i32 2, align 8
  %2 = getelementptr ptr, ptr %arrlit1, i32 0
  store ptr %arrlit, ptr %2, align 8
  %arrlit2 = alloca float, i32 2, align 4
  %3 = getelementptr float, ptr %arrlit2, i32 0
  store float 0.000000e+00, ptr %3, align 4
  %4 = getelementptr float, ptr %arrlit2, i32 1
  store float 1.000000e+00, ptr %4, align 4
  %5 = getelementptr ptr, ptr %arrlit1, i32 1
  store ptr %arrlit2, ptr %5, align 8
  %arrlit3 = alloca double, i32 2, align 8
  %6 = getelementptr double, ptr %arrlit3, i32 0
  store double 0.000000e+00, ptr %6, align 8
  %7 = getelementptr double, ptr %arrlit3, i32 1
  store double 0.000000e+00, ptr %7, align 8
  %arrlit4 = alloca ptr, i32 2, align 8
  %8 = getelementptr ptr, ptr %arrlit4, i32 0
  store ptr %arrlit3, ptr %8, align 8
  %arrlit5 = alloca double, i32 2, align 8
  %9 = getelementptr double, ptr %arrlit5, i32 0
  store double 0.000000e+00, ptr %9, align 8
  %10 = getelementptr double, ptr %arrlit5, i32 1
  store double 0.000000e+00, ptr %10, align 8
  %11 = getelementptr ptr, ptr %arrlit4, i32 1
  store ptr %arrlit5, ptr %11, align 8
  %arrlit6 = alloca float, i32 3, align 4
  %12 = getelementptr float, ptr %arrlit6, i32 0
  store float 1.000000e+00, ptr %12, align 4
  %13 = getelementptr float, ptr %arrlit6, i32 1
  store float 2.000000e+00, ptr %13, align 4
  %14 = getelementptr float, ptr %arrlit6, i32 2
  store float 3.000000e+00, ptr %14, align 4
  %arrlit7 = alloca ptr, i32 2, align 8
  %15 = getelementptr ptr, ptr %arrlit7, i32 0
  store ptr %arrlit6, ptr %15, align 8
  %arrlit8 = alloca float, i32 3, align 4
  %16 = getelementptr float, ptr %arrlit8, i32 0
  store float 4.000000e+00, ptr %16, align 4
  %17 = getelementptr float, ptr %arrlit8, i32 1
  store float 5.000000e+00, ptr %17, align 4
  %18 = getelementptr float, ptr %arrlit8, i32 2
  store float 6.000000e+00, ptr %18, align 4
  %19 = getelementptr ptr, ptr %arrlit7, i32 1
  store ptr %arrlit8, ptr %19, align 8
  %arrlit9 = alloca double, i32 2, align 8
  %20 = getelementptr double, ptr %arrlit9, i32 0
  store double 0.000000e+00, ptr %20, align 8
  %21 = getelementptr double, ptr %arrlit9, i32 1
  store double 0.000000e+00, ptr %21, align 8
  %arrlit10 = alloca ptr, i32 2, align 8
  %22 = getelementptr ptr, ptr %arrlit10, i32 0
  store ptr %arrlit9, ptr %22, align 8
  %arrlit11 = alloca double, i32 2, align 8
  %23 = getelementptr double, ptr %arrlit11, i32 0
  store double 0.000000e+00, ptr %23, align 8
  %24 = getelementptr double, ptr %arrlit11, i32 1
  store double 0.000000e+00, ptr %24, align 8
  %25 = getelementptr ptr, ptr %arrlit10, i32 1
  store ptr %arrlit11, ptr %25, align 8
  %arrlit12 = alloca double, i32 2, align 8
  %26 = getelementptr double, ptr %arrlit12, i32 0
  store double 0.000000e+00, ptr %26, align 8
  %27 = getelementptr double, ptr %arrlit12, i32 1
  store double 0.000000e+00, ptr %27, align 8
  %arrlit13 = alloca ptr, i32 2, align 8
  %28 = getelementptr ptr, ptr %arrlit13, i32 0
  store ptr %arrlit12, ptr %28, align 8
  %arrlit14 = alloca double, i32 2, align 8
  %29 = getelementptr double, ptr %arrlit14, i32 0
  store double 0.000000e+00, ptr %29, align 8
  %30 = getelementptr double, ptr %arrlit14, i32 1
  store double 0.000000e+00, ptr %30, align 8
  %31 = getelementptr ptr, ptr %arrlit13, i32 1
  store ptr %arrlit14, ptr %31, align 8
  %arrlit15 = alloca float, i32 3, align 4
  %32 = getelementptr float, ptr %arrlit15, i32 0
  store float 1.000000e+00, ptr %32, align 4
  %33 = getelementptr float, ptr %arrlit15, i32 1
  store float 0.000000e+00, ptr %33, align 4
  %34 = getelementptr float, ptr %arrlit15, i32 2
  store float 0.000000e+00, ptr %34, align 4
  %arrlit16 = alloca ptr, i32 3, align 8
  %35 = getelementptr ptr, ptr %arrlit16, i32 0
  store ptr %arrlit15, ptr %35, align 8
  %arrlit17 = alloca float, i32 3, align 4
  %36 = getelementptr float, ptr %arrlit17, i32 0
  store float 0.000000e+00, ptr %36, align 4
  %37 = getelementptr float, ptr %arrlit17, i32 1
  store float 1.000000e+00, ptr %37, align 4
  %38 = getelementptr float, ptr %arrlit17, i32 2
  store float 0.000000e+00, ptr %38, align 4
  %39 = getelementptr ptr, ptr %arrlit16, i32 1
  store ptr %arrlit17, ptr %39, align 8
  %arrlit18 = alloca float, i32 3, align 4
  %40 = getelementptr float, ptr %arrlit18, i32 0
  store float 0.000000e+00, ptr %40, align 4
  %41 = getelementptr float, ptr %arrlit18, i32 1
  store float 0.000000e+00, ptr %41, align 4
  %42 = getelementptr float, ptr %arrlit18, i32 2
  store float 1.000000e+00, ptr %42, align 4
  %43 = getelementptr ptr, ptr %arrlit16, i32 2
  store ptr %arrlit18, ptr %43, align 8
  ret i32 0
}

declare void @csec_set_command_line_args(i32, ptr)

define internal i32 @__csec_jit_entry() {
entry:
  %user.main = call i32 @_main()
  ret i32 %user.main
}
