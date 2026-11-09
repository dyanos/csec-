; ModuleID = 'main'
source_filename = "main"

%Vector2 = type { i32, i32 }
%Vector3 = type { i32, i32, i32 }
%Color = type { i32, i32, i32 }
%Rectangle = type { i32, i32 }
%Circle = type { i32 }

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
  %newobj.malloc = call ptr @malloc(i64 8)
  %x.init = getelementptr inbounds %Vector2, ptr %newobj.malloc, i32 0, i32 0
  store i32 3, ptr %x.init, align 4
  %y.init = getelementptr inbounds %Vector2, ptr %newobj.malloc, i32 0, i32 1
  store i32 4, ptr %y.init, align 4
  %newobj.malloc1 = call ptr @malloc(i64 12)
  %x.init2 = getelementptr inbounds %Vector3, ptr %newobj.malloc1, i32 0, i32 0
  store i32 1, ptr %x.init2, align 4
  %y.init3 = getelementptr inbounds %Vector3, ptr %newobj.malloc1, i32 0, i32 1
  store i32 2, ptr %y.init3, align 4
  %z.init = getelementptr inbounds %Vector3, ptr %newobj.malloc1, i32 0, i32 2
  store i32 3, ptr %z.init, align 4
  %newobj.malloc4 = call ptr @malloc(i64 12)
  %r.init = getelementptr inbounds %Color, ptr %newobj.malloc4, i32 0, i32 0
  store i32 255, ptr %r.init, align 4
  %g.init = getelementptr inbounds %Color, ptr %newobj.malloc4, i32 0, i32 1
  store i32 128, ptr %g.init, align 4
  %b.init = getelementptr inbounds %Color, ptr %newobj.malloc4, i32 0, i32 2
  store i32 0, ptr %b.init, align 4
  %newobj.malloc5 = call ptr @malloc(i64 8)
  %w.init = getelementptr inbounds %Rectangle, ptr %newobj.malloc5, i32 0, i32 0
  store i32 10, ptr %w.init, align 4
  %h.init = getelementptr inbounds %Rectangle, ptr %newobj.malloc5, i32 0, i32 1
  store i32 20, ptr %h.init, align 4
  %newobj.malloc6 = call ptr @malloc(i64 4)
  %radius.init = getelementptr inbounds %Circle, ptr %newobj.malloc6, i32 0, i32 0
  store i32 5, ptr %radius.init, align 4
  ret i32 0
}

define i32 @Vector2_magnitude(ptr %this) {
entry:
  %x.field = getelementptr inbounds %Vector2, ptr %this, i32 0, i32 0
  %y.field = getelementptr inbounds %Vector2, ptr %this, i32 0, i32 1
  %x.load = load i32, ptr %x.field, align 4
  %x.load1 = load i32, ptr %x.field, align 4
  %multmp = mul i32 %x.load, %x.load1
  %y.load = load i32, ptr %y.field, align 4
  %y.load2 = load i32, ptr %y.field, align 4
  %multmp3 = mul i32 %y.load, %y.load2
  %addtmp = add i32 %multmp, %multmp3
  ret i32 %addtmp
}

define i32 @Vector3_magnitude(ptr %this) {
entry:
  %x.field = getelementptr inbounds %Vector3, ptr %this, i32 0, i32 0
  %y.field = getelementptr inbounds %Vector3, ptr %this, i32 0, i32 1
  %z.field = getelementptr inbounds %Vector3, ptr %this, i32 0, i32 2
  %x.load = load i32, ptr %x.field, align 4
  %x.load1 = load i32, ptr %x.field, align 4
  %multmp = mul i32 %x.load, %x.load1
  %y.load = load i32, ptr %y.field, align 4
  %y.load2 = load i32, ptr %y.field, align 4
  %multmp3 = mul i32 %y.load, %y.load2
  %addtmp = add i32 %multmp, %multmp3
  %z.load = load i32, ptr %z.field, align 4
  %z.load4 = load i32, ptr %z.field, align 4
  %multmp5 = mul i32 %z.load, %z.load4
  %addtmp6 = add i32 %addtmp, %multmp5
  ret i32 %addtmp6
}

define i32 @Color_brightness(ptr %this) {
entry:
  %r.field = getelementptr inbounds %Color, ptr %this, i32 0, i32 0
  %g.field = getelementptr inbounds %Color, ptr %this, i32 0, i32 1
  %b.field = getelementptr inbounds %Color, ptr %this, i32 0, i32 2
  %r.load = load i32, ptr %r.field, align 4
  %g.load = load i32, ptr %g.field, align 4
  %addtmp = add i32 %r.load, %g.load
  %b.load = load i32, ptr %b.field, align 4
  %addtmp1 = add i32 %addtmp, %b.load
  ret i32 %addtmp1
}

define i32 @Rectangle_area(ptr %this) {
entry:
  %w.field = getelementptr inbounds %Rectangle, ptr %this, i32 0, i32 0
  %h.field = getelementptr inbounds %Rectangle, ptr %this, i32 0, i32 1
  %w.load = load i32, ptr %w.field, align 4
  %h.load = load i32, ptr %h.field, align 4
  %multmp = mul i32 %w.load, %h.load
  ret i32 %multmp
}

define i32 @Rectangle_perimeter(ptr %this) {
entry:
  %w.field = getelementptr inbounds %Rectangle, ptr %this, i32 0, i32 0
  %h.field = getelementptr inbounds %Rectangle, ptr %this, i32 0, i32 1
  %w.load = load i32, ptr %w.field, align 4
  %h.load = load i32, ptr %h.field, align 4
  %addtmp = add i32 %w.load, %h.load
  %multmp = mul i32 2, %addtmp
  ret i32 %multmp
}

define i32 @Circle_diameter(ptr %this) {
entry:
  %radius.field = getelementptr inbounds %Circle, ptr %this, i32 0, i32 0
  %radius.load = load i32, ptr %radius.field, align 4
  %multmp = mul i32 %radius.load, 2
  ret i32 %multmp
}

declare void @csec_set_command_line_args(i32, ptr)

define internal i32 @__csec_jit_entry() {
entry:
  %user.main = call i32 @_main()
  ret i32 %user.main
}
