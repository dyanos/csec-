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
  br i1 true, label %and_rhs, label %and_end

and_rhs:                                          ; preds = %entry
  br label %and_end

and_end:                                          ; preds = %and_rhs, %entry
  %r1 = alloca i1, align 1
  store i1 false, ptr %r1, align 1
  br i1 true, label %or_end, label %or_rhs

or_rhs:                                           ; preds = %and_end
  br label %or_end

or_end:                                           ; preds = %or_rhs, %and_end
  %or_result.0 = phi i1 [ true, %and_end ], [ false, %or_rhs ]
  %r2 = alloca i1, align 1
  store i1 %or_result.0, ptr %r2, align 1
  %xortmp = xor i1 true, false
  %r3 = alloca i1, align 1
  store i1 %xortmp, ptr %r3, align 1
  br i1 true, label %and_rhs7, label %and_end8

and_rhs7:                                         ; preds = %or_end
  br label %and_end8

and_end8:                                         ; preds = %and_rhs7, %or_end
  br i1 false, label %or_end13, label %or_rhs12

or_rhs12:                                         ; preds = %and_end8
  br label %or_end13

or_end13:                                         ; preds = %or_rhs12, %and_end8
  %r4 = alloca i1, align 1
  store i1 true, ptr %r4, align 1
  br i1 true, label %or_end18, label %or_rhs17

or_rhs17:                                         ; preds = %or_end13
  br label %or_end18

or_end18:                                         ; preds = %or_rhs17, %or_end13
  %or_result16.0 = phi i1 [ true, %or_end13 ], [ false, %or_rhs17 ]
  br i1 %or_result16.0, label %and_rhs22, label %and_end23

and_rhs22:                                        ; preds = %or_end18
  br i1 false, label %or_end27, label %or_rhs26

and_end23:                                        ; preds = %or_end27, %or_end18
  %and_result21.0 = phi i1 [ true, %or_end27 ], [ false, %or_end18 ]
  %r5 = alloca i1, align 1
  store i1 %and_result21.0, ptr %r5, align 1
  br i1 true, label %and_rhs33, label %and_end34

or_rhs26:                                         ; preds = %and_rhs22
  br label %or_end27

or_end27:                                         ; preds = %or_rhs26, %and_rhs22
  br label %and_end23

and_rhs33:                                        ; preds = %and_end23
  br label %and_end34

and_end34:                                        ; preds = %and_rhs33, %and_end23
  br i1 false, label %and_rhs38, label %and_end39

and_rhs38:                                        ; preds = %and_end34
  br label %and_end39

and_end39:                                        ; preds = %and_rhs38, %and_end34
  %and_result37.0 = phi i1 [ true, %and_rhs38 ], [ false, %and_end34 ]
  %r6 = alloca i1, align 1
  store i1 %and_result37.0, ptr %r6, align 1
  br i1 true, label %or_end45, label %or_rhs44

or_rhs44:                                         ; preds = %and_end39
  br label %or_end45

or_end45:                                         ; preds = %or_rhs44, %and_end39
  %or_result43.0 = phi i1 [ true, %and_end39 ], [ false, %or_rhs44 ]
  br i1 %or_result43.0, label %or_end50, label %or_rhs49

or_rhs49:                                         ; preds = %or_end45
  br label %or_end50

or_end50:                                         ; preds = %or_rhs49, %or_end45
  %r7 = alloca i1, align 1
  store i1 true, ptr %r7, align 1
  %xortmp55 = xor i1 true, false
  br i1 %xortmp55, label %and_rhs57, label %and_end58

and_rhs57:                                        ; preds = %or_end50
  %xortmp61 = xor i1 false, true
  br label %and_end58

and_end58:                                        ; preds = %and_rhs57, %or_end50
  %and_result56.0 = phi i1 [ %xortmp61, %and_rhs57 ], [ false, %or_end50 ]
  %r8 = alloca i1, align 1
  store i1 %and_result56.0, ptr %r8, align 1
  %x = alloca i32, align 4
  store i32 10, ptr %x, align 4
  %y = alloca i32, align 4
  store i32 20, ptr %y, align 4
  %z = alloca i32, align 4
  store i32 30, ptr %z, align 4
  %x.load = load i32, ptr %x, align 4
  %y.load = load i32, ptr %y, align 4
  %lttmp = icmp slt i32 %x.load, %y.load
  %cmp1 = alloca i1, align 1
  store i1 %lttmp, ptr %cmp1, align 1
  %y.load63 = load i32, ptr %y, align 4
  %z.load = load i32, ptr %z, align 4
  %letmp = icmp sle i32 %y.load63, %z.load
  %cmp2 = alloca i1, align 1
  store i1 %letmp, ptr %cmp2, align 1
  %x.load64 = load i32, ptr %x, align 4
  %z.load65 = load i32, ptr %z, align 4
  %netmp = icmp ne i32 %x.load64, %z.load65
  %cmp3 = alloca i1, align 1
  store i1 %netmp, ptr %cmp3, align 1
  %x.load66 = load i32, ptr %x, align 4
  %eqtmp = icmp eq i32 %x.load66, 10
  %cmp4 = alloca i1, align 1
  store i1 %eqtmp, ptr %cmp4, align 1
  %x.load67 = load i32, ptr %x, align 4
  %y.load68 = load i32, ptr %y, align 4
  %lttmp69 = icmp slt i32 %x.load67, %y.load68
  br i1 %lttmp69, label %and_rhs71, label %and_end72

and_rhs71:                                        ; preds = %and_end58
  %y.load73 = load i32, ptr %y, align 4
  %z.load74 = load i32, ptr %z, align 4
  %lttmp75 = icmp slt i32 %y.load73, %z.load74
  br label %and_end72

and_end72:                                        ; preds = %and_rhs71, %and_end58
  %and_result70.0 = phi i1 [ %lttmp75, %and_rhs71 ], [ false, %and_end58 ]
  %cmp5 = alloca i1, align 1
  store i1 %and_result70.0, ptr %cmp5, align 1
  %x.load77 = load i32, ptr %x, align 4
  %getmp = icmp sge i32 %x.load77, 0
  br i1 %getmp, label %or_end80, label %or_rhs79

or_rhs79:                                         ; preds = %and_end72
  %z.load81 = load i32, ptr %z, align 4
  %letmp82 = icmp sle i32 %z.load81, 100
  br label %or_end80

or_end80:                                         ; preds = %or_rhs79, %and_end72
  %or_result78.0 = phi i1 [ true, %and_end72 ], [ %letmp82, %or_rhs79 ]
  %cmp6 = alloca i1, align 1
  store i1 %or_result78.0, ptr %cmp6, align 1
  ret i32 0
}

declare void @csec_set_command_line_args(i32, ptr)

define internal i32 @__csec_jit_entry() {
entry:
  %user.main = call i32 @_main()
  ret i32 %user.main
}
