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
  %sim.md = call double @csec_sim_md_lennard_jones(i32 3, i32 2, i32 25, double 0x3F50624DE0000000, double 3.000000e+02)
  %sim.cfd = call double @csec_sim_cfd_lid_cavity(i32 16, i32 16, i32 20, double 0x3F847AE140000000, double 0x3F50624DE0000000, double 1.000000e+00)
  ret i32 0
}

declare double @csec_sim_md_lennard_jones(i32, i32, i32, double, double)

declare double @csec_sim_cfd_lid_cavity(i32, i32, i32, double, double, double)

declare void @csec_set_command_line_args(i32, ptr)

define internal i32 @__csec_jit_entry() {
entry:
  %user.main = call i32 @_main()
  ret i32 %user.main
}
