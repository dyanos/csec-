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
  br label %forcond

forcond:                                          ; preds = %loop, %entry
  %i_ptr.0 = phi i32 [ 0, %entry ], [ %next_i, %loop ]
  %sumInclusive.0 = phi i32 [ 0, %entry ], [ %addtmp, %loop ]
  %cond = icmp sle i32 %i_ptr.0, 5
  br i1 %cond, label %loop, label %afterloop

loop:                                             ; preds = %forcond
  %addtmp = add i32 %sumInclusive.0, %i_ptr.0
  %next_i = add i32 %i_ptr.0, 1
  br label %forcond

afterloop:                                        ; preds = %forcond
  %sumExclusive = alloca i32, align 4
  store i32 0, ptr %sumExclusive, align 4
  %j_ptr = alloca i32, align 4
  store i32 0, ptr %j_ptr, align 4
  br label %forcond3

forcond3:                                         ; preds = %loop4, %afterloop
  %j = load i32, ptr %j_ptr, align 4
  %cond6 = icmp sle i32 %j, 4
  br i1 %cond6, label %loop4, label %afterloop5

loop4:                                            ; preds = %forcond3
  %sumExclusive.load = load i32, ptr %sumExclusive, align 4
  %sumExclusive.load7 = load i32, ptr %sumExclusive, align 4
  %j.load = load i32, ptr %j_ptr, align 4
  %addtmp8 = add i32 %sumExclusive.load7, %j.load
  store i32 %addtmp8, ptr %sumExclusive, align 4
  %j9 = load i32, ptr %j_ptr, align 4
  %next_i10 = add i32 %j9, 1
  store i32 %next_i10, ptr %j_ptr, align 4
  br label %forcond3

afterloop5:                                       ; preds = %forcond3
  %product = alloca i32, align 4
  store i32 1, ptr %product, align 4
  %k_ptr = alloca i32, align 4
  store i32 1, ptr %k_ptr, align 4
  br label %forcond11

forcond11:                                        ; preds = %loop12, %afterloop5
  %k = load i32, ptr %k_ptr, align 4
  %cond14 = icmp sle i32 %k, 5
  br i1 %cond14, label %loop12, label %afterloop13

loop12:                                           ; preds = %forcond11
  %product.load = load i32, ptr %product, align 4
  %product.load15 = load i32, ptr %product, align 4
  %k.load = load i32, ptr %k_ptr, align 4
  %multmp = mul i32 %product.load15, %k.load
  store i32 %multmp, ptr %product, align 4
  %k16 = load i32, ptr %k_ptr, align 4
  %next_i17 = add i32 %k16, 1
  store i32 %next_i17, ptr %k_ptr, align 4
  br label %forcond11

afterloop13:                                      ; preds = %forcond11
  %countdown = alloca i32, align 4
  store i32 0, ptr %countdown, align 4
  %m_ptr = alloca i32, align 4
  store i32 10, ptr %m_ptr, align 4
  br label %forcond18

forcond18:                                        ; preds = %loop19, %afterloop13
  %m = load i32, ptr %m_ptr, align 4
  %cond21 = icmp sle i32 %m, 14
  br i1 %cond21, label %loop19, label %afterloop20

loop19:                                           ; preds = %forcond18
  %countdown.load = load i32, ptr %countdown, align 4
  %countdown.load22 = load i32, ptr %countdown, align 4
  %addtmp23 = add i32 %countdown.load22, 1
  store i32 %addtmp23, ptr %countdown, align 4
  %m24 = load i32, ptr %m_ptr, align 4
  %next_i25 = add i32 %m24, 1
  store i32 %next_i25, ptr %m_ptr, align 4
  br label %forcond18

afterloop20:                                      ; preds = %forcond18
  %sumExclusive.load27 = load i32, ptr %sumExclusive, align 4
  %addtmp28 = add i32 %sumInclusive.0, %sumExclusive.load27
  ret i32 %addtmp28
}

declare void @csec_set_command_line_args(i32, ptr)

define internal i32 @__csec_jit_entry() {
entry:
  %user.main = call i32 @_main()
  ret i32 %user.main
}
