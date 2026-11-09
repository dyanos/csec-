; ModuleID = 'main'
source_filename = "main"

@0 = private unnamed_addr constant [13 x i8] c"csec-runtime\00", align 1
@1 = private unnamed_addr constant [5 x i8] c"csec\00", align 1
@2 = private unnamed_addr constant [5 x i8] c"time\00", align 1
@3 = private unnamed_addr constant [4 x i8] c"run\00", align 1
@4 = private unnamed_addr constant [8 x i8] c"runtime\00", align 1

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
  %str.bool.i32 = call i32 @csec_string_starts_with(ptr @0, ptr @1)
  %str.bool = icmp ne i32 %str.bool.i32, 0
  br i1 %str.bool, label %and_rhs, label %and_end

and_rhs:                                          ; preds = %entry
  %str.bool.i322 = call i32 @csec_string_ends_with(ptr @0, ptr @2)
  %str.bool3 = icmp ne i32 %str.bool.i322, 0
  br label %and_end

and_end:                                          ; preds = %and_rhs, %entry
  %and_result.0 = phi i1 [ %str.bool3, %and_rhs ], [ false, %entry ]
  br i1 %and_result.0, label %and_rhs5, label %and_end6

and_rhs5:                                         ; preds = %and_end
  %str.bool.i328 = call i32 @csec_string_contains(ptr @0, ptr @3)
  %str.bool9 = icmp ne i32 %str.bool.i328, 0
  br label %and_end6

and_end6:                                         ; preds = %and_rhs5, %and_end
  %and_result4.0 = phi i1 [ %str.bool9, %and_rhs5 ], [ false, %and_end ]
  br i1 %and_result4.0, label %and_rhs12, label %and_end13

and_rhs12:                                        ; preds = %and_end6
  %str.empty.i32 = call i32 @csec_string_is_empty(ptr @0)
  %str.empty = icmp ne i32 %str.empty.i32, 0
  %nottmp = xor i1 %str.empty, true
  br label %and_end13

and_end13:                                        ; preds = %and_rhs12, %and_end6
  %and_result11.0 = phi i1 [ %nottmp, %and_rhs12 ], [ false, %and_end6 ]
  br i1 %and_result11.0, label %then, label %ifcont

then:                                             ; preds = %and_end13
  %str.index = call i64 @csec_string_index_of(ptr @0, ptr @4)
  %addtmp = add i64 %str.index, 35
  %abi.trunc = trunc i64 %addtmp to i32
  ret i32 %abi.trunc

ifcont:                                           ; preds = %and_end13
  ret i32 0
}

declare i32 @csec_string_starts_with(ptr, ptr)

declare i32 @csec_string_ends_with(ptr, ptr)

declare i32 @csec_string_contains(ptr, ptr)

declare i32 @csec_string_is_empty(ptr)

declare i64 @csec_string_index_of(ptr, ptr)

declare void @csec_set_command_line_args(i32, ptr)

define internal i32 @__csec_jit_entry() {
entry:
  %user.main = call i32 @_main()
  ret i32 %user.main
}
