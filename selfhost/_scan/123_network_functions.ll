; ModuleID = 'main'
source_filename = "main"

@0 = private unnamed_addr constant [10 x i8] c"127.0.0.1\00", align 1
@1 = private unnamed_addr constant [19 x i8] c"GET / HTTP/1.0\0D\0A\0D\0A\00", align 1

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
  %net.connect = call i64 @csec_tcp_connect(ptr @0, i32 80)
  %net.send = call i32 @csec_tcp_send(i64 %net.connect, ptr @1)
  %net.recv = call ptr @csec_tcp_recv(i64 %net.connect, i32 1024)
  %net.close = call i32 @csec_tcp_close(i64 %net.connect)
  %math.sext = sext i32 %net.send to i64
  call void @csec_print_i64(i64 %math.sext)
  call void @csec_print_newline()
  call void @csec_print_string(ptr %net.recv)
  call void @csec_print_newline()
  %math.sext3 = sext i32 %net.close to i64
  call void @csec_print_i64(i64 %math.sext3)
  call void @csec_print_newline()
  ret i32 0
}

declare i64 @csec_tcp_connect(ptr, i32)

declare i32 @csec_tcp_send(i64, ptr)

declare ptr @csec_tcp_recv(i64, i32)

declare i32 @csec_tcp_close(i64)

declare void @csec_print_i64(i64)

declare void @csec_print_newline()

declare void @csec_print_string(ptr)

declare void @csec_set_command_line_args(i32, ptr)

define internal i32 @__csec_jit_entry() {
entry:
  %user.main = call i32 @_main()
  ret i32 %user.main
}
