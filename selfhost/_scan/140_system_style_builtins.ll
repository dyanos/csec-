; ModuleID = 'main'
source_filename = "main"

@0 = private unnamed_addr constant [7 x i8] c"value=\00", align 1
@1 = private unnamed_addr constant [30 x i8] c"tmp_system_style_builtins.txt\00", align 1
@2 = private unnamed_addr constant [6 x i8] c"hello\00", align 1
@3 = private unnamed_addr constant [30 x i8] c"tmp_system_style_builtins.txt\00", align 1
@4 = private unnamed_addr constant [7 x i8] c" world\00", align 1
@5 = private unnamed_addr constant [30 x i8] c"tmp_system_style_builtins.txt\00", align 1
@6 = private unnamed_addr constant [30 x i8] c"tmp_system_style_builtins.txt\00", align 1
@7 = private unnamed_addr constant [30 x i8] c"tmp_system_style_builtins.txt\00", align 1

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
  call void @csec_print_string(ptr @0)
  call void @csec_print_i64(i64 42)
  call void @csec_print_newline()
  %math.call = call double @csec_math_sqrt(double 8.100000e+01)
  %math.fold = call double @csec_math_max(double %math.call, double 1.000000e+01)
  %fsubtmp = fsub double %math.fold, 1.000000e+01
  %math.call1 = call double @csec_math_abs(double %fsubtmp)
  %lttmp = fcmp olt double %math.call1, 0x3F50624DE0000000
  %box.sitofp = sitofp i1 %lttmp to double
  %file.write_all_text = call i32 @csec_file_write_all_text(ptr @1, ptr @2)
  %file.append_all_text = call i32 @csec_file_append_all_text(ptr @3, ptr @4)
  %file.exists.i32 = call i32 @csec_file_exists(ptr @5)
  %file.exists = icmp ne i32 %file.exists.i32, 0
  %file.read_all_text = call ptr @csec_file_read_all_text(ptr @6)
  call void @csec_print_string(ptr %file.read_all_text)
  call void @csec_print_newline()
  %file.delete = call i32 @csec_file_delete(ptr @7)
  %tobool = fcmp one double %box.sitofp, 0.000000e+00
  br i1 %tobool, label %and_rhs, label %and_end

and_rhs:                                          ; preds = %entry
  br label %and_end

and_end:                                          ; preds = %and_rhs, %entry
  %and_result.0 = phi i1 [ %file.exists, %and_rhs ], [ false, %entry ]
  br i1 %and_result.0, label %and_rhs3, label %and_end4

and_rhs3:                                         ; preds = %and_end
  %str.length = call i64 @csec_string_length(ptr %file.read_all_text)
  %eqtmp = icmp eq i64 %str.length, 11
  br label %and_end4

and_end4:                                         ; preds = %and_rhs3, %and_end
  %and_result2.0 = phi i1 [ %eqtmp, %and_rhs3 ], [ false, %and_end ]
  br i1 %and_result2.0, label %then, label %ifcont

then:                                             ; preds = %and_end4
  ret i32 0

ifcont:                                           ; preds = %and_end4
  ret i32 1
}

declare void @csec_print_string(ptr)

declare void @csec_print_i64(i64)

declare void @csec_print_newline()

declare double @csec_math_sqrt(double)

declare double @csec_math_max(double, double)

declare double @csec_math_abs(double)

declare i32 @csec_file_write_all_text(ptr, ptr)

declare i32 @csec_file_append_all_text(ptr, ptr)

declare i32 @csec_file_exists(ptr)

declare ptr @csec_file_read_all_text(ptr)

declare i32 @csec_file_delete(ptr)

declare i64 @csec_string_length(ptr)

declare void @csec_set_command_line_args(i32, ptr)

define internal i32 @__csec_jit_entry() {
entry:
  %user.main = call i32 @_main()
  ret i32 %user.main
}
