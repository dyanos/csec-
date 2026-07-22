# Execution Support Progress

## Verified

- The self-host compiler reaches an LLVM fixed point (stage 5 and stage 6 are byte-identical).
- Integer expressions, comparisons, boolean operations, calls, control flow, range loops,
  literal arrays with static indexing, imports, and common return paths execute through the
  self-host LLVM path.
- Dynamic `Int` arrays support `new Int[size]`, runtime indexing, element reads, writes, and
  compound assignments. The native compiler and self-host LLVM path both execute
  `tests/positive/04_collections/050_dynamic_array_indexing.csec` with exit code `45`.
- Non-capturing `Int -> Int` lambdas lower to hidden LLVM functions in both native and self-host
  compilation. The regression fixture `tests/positive/09_functional/095_lambda_invocation.csec`
  exits with `42` on both paths.
- Self-host lowering supports explicit by-value `Int` captures by passing captured values to the
  hidden lambda function. `096_lambda_explicit_capture_invocation.csec` exits with `42`.
- Capture-all `[=]` lambdas infer referenced outer `Int` locals and pass them by value. The
  regression fixture `097_lambda_capture_all_invocation.csec` exits with `42`.
- By-reference `[&]` `Int` captures pass outer storage pointers to the hidden lambda function,
  preserving mutations across calls. `098_lambda_by_reference_invocation.csec` exits with `12`.
- Unary `Int -> Int` function-type parameters lower to function pointers and invoke them
  indirectly. `099_higher_order_lambda_invocation.csec` passes a lambda to `apply` and exits
  with `42`.
- Binary `Int, Int -> Int` function-type parameters correctly preserve nested parameter commas,
  lower to function pointers, and invoke them indirectly. `100_higher_order_binary_lambda_invocation.csec`
  exits with `42`.
- Struct-backed class inheritance preserves ancestor `Int` field layout and dispatches
  `super.method()` with the same receiver pointer. `068_inherited_mutable_fields.csec` exits
  with `13`.
- Self-host lowering supports `Int`-returning static object methods and qualified calls. The
  regression fixture `tests/positive/05_oop/058_object_multiple_methods.csec` executes with
  exit code `85`.
- Self-host lowering supports classes whose constructor has `Int` parameters and whose methods
  read those parameters. Constructor values are passed as explicit receiver arguments to the
  lowered method. `052_method_calls_and_paths.csec` exits with `21`, and the multi-method
  `055_class_many_methods.csec` exits with `62`.
- Class methods also initialize and read `Int` fields declared with literal expressions in the
  class body. `053_objects_and_members.csec` executes with exit code `16`.
- Classes with `Int` fields use a struct-backed pointer receiver in the self-host LLVM path, so
  mutable field updates persist across calls. `056_class_field_types.csec` executes with exit
  code `44` after two `increment()` calls.
- Scalar-receiver classes support `this.field` reads and `super.method()` dispatch through the
  declared parent class. `064_this_and_super_paths.csec` executes with exit code `1`.
- Static objects support literal `Int` fields and expression-bodied methods. Together with mixed
  String/Int constructor classes, `059_class_object_mix.csec` executes with exit code `8113`.

## Still Incomplete

- Lambda closures: non-`Int` signatures, broader higher-order ABI coverage, and closure
  environment ownership.
- Arrays beyond the current `Int` flat-storage path: other element types, nested/dynamic shape
  semantics, array parameters/returns, bounds behavior, and general ownership.
- Reference semantics beyond the current stack-backed instance path, general field access syntax,
  and non-`Int` constructor or field state in the self-host LLVM emitter. `Int` inheritance,
  including struct-backed parent fields and `super` dispatch, is supported.
- Generic/template execution, enum/union/nullable/ownership behavior, rich string/char/float
  interactions, complete match patterns, iterable collection loops, and broad function ABI
  coverage.

## Validation Commands

```powershell
# Native dynamic array path
.\x64\Debug\csec++.exe --emit-ir -o .\selfhost\dynamic_array_check.ll `
  .\tests\positive\04_collections\050_dynamic_array_indexing.csec
.\x64\Debug\csec++.exe --run-ir .\selfhost\dynamic_array_check.ll

# Self-host dynamic array path
.\x64\Debug\csec++.exe --run-ir .\selfhost\nativeflow_stage5_current.ll -- `
  .\tests\positive\04_collections\050_dynamic_array_indexing.csec `
  .\selfhost\dynamic_array_selfhost.ll llvm
.\x64\Debug\csec++.exe --run-ir .\selfhost\dynamic_array_selfhost.ll

# Self-host static object method path (the program intentionally returns 85)
.\x64\Debug\csec++.exe --run-ir .\selfhost\nativeflow_stage5_current.ll -- `
  .\tests\positive\05_oop\058_object_multiple_methods.csec `
  .\selfhost\object_selfhost_probe.ll llvm
.\x64\Debug\csec++.exe --run-ir .\selfhost\object_selfhost_probe.ll

# Self-host class instance method path (intentional returns: 21 and 62)
.\x64\Debug\csec++.exe --run-ir .\selfhost\nativeflow_stage5_current.ll -- `
  .\tests\positive\05_oop\052_method_calls_and_paths.csec `
  .\selfhost\oop_selfhost_probe.ll llvm
.\x64\Debug\csec++.exe --run-ir .\selfhost\oop_selfhost_probe.ll
.\x64\Debug\csec++.exe --run-ir .\selfhost\nativeflow_stage5_current.ll -- `
  .\tests\positive\05_oop\055_class_many_methods.csec `
  .\selfhost\class_methods_selfhost_probe.ll llvm
.\x64\Debug\csec++.exe --run-ir .\selfhost\class_methods_selfhost_probe.ll
.\x64\Debug\csec++.exe --run-ir .\selfhost\nativeflow_stage5_current.ll -- `
  .\tests\positive\05_oop\053_objects_and_members.csec `
  .\selfhost\class_fields_selfhost_probe.ll llvm
.\x64\Debug\csec++.exe --run-ir .\selfhost\class_fields_selfhost_probe.ll
.\x64\Debug\csec++.exe --run-ir .\selfhost\nativeflow_stage5_current.ll -- `
  .\tests\positive\05_oop\056_class_field_types.csec `
  .\selfhost\class_mutable_selfhost_probe.ll llvm
.\x64\Debug\csec++.exe --run-ir .\selfhost\class_mutable_selfhost_probe.ll
.\x64\Debug\csec++.exe --run-ir .\selfhost\nativeflow_stage5_current.ll -- `
  .\tests\positive\05_oop\064_this_and_super_paths.csec `
  .\selfhost\inheritance_selfhost_probe.ll llvm
.\x64\Debug\csec++.exe --run-ir .\selfhost\inheritance_selfhost_probe.ll
.\x64\Debug\csec++.exe --run-ir .\selfhost\nativeflow_stage5_current.ll -- `
  .\tests\positive\05_oop\059_class_object_mix.csec `
  .\selfhost\class_object_mix_probe.ll llvm
.\x64\Debug\csec++.exe --run-ir .\selfhost\class_object_mix_probe.ll

# Self-host non-capturing lambda path (intentional return: 42)
.\x64\Debug\csec++.exe --run-ir .\selfhost\nativeflow_stage5_current.ll -- `
  .\tests\positive\09_functional\095_lambda_invocation.csec `
  .\selfhost\lambda_selfhost_probe.ll llvm
.\x64\Debug\csec++.exe --run-ir .\selfhost\lambda_selfhost_probe.ll
.\x64\Debug\csec++.exe --run-ir .\selfhost\nativeflow_stage5_current.ll -- `
  .\tests\positive\09_functional\096_lambda_explicit_capture_invocation.csec `
  .\selfhost\lambda_capture_selfhost_probe.ll llvm
.\x64\Debug\csec++.exe --run-ir .\selfhost\lambda_capture_selfhost_probe.ll
.\x64\Debug\csec++.exe --run-ir .\selfhost\nativeflow_stage5_current.ll -- `
  .\tests\positive\09_functional\097_lambda_capture_all_invocation.csec `
  .\selfhost\lambda_capture_all_selfhost_probe.ll llvm
.\x64\Debug\csec++.exe --run-ir .\selfhost\lambda_capture_all_selfhost_probe.ll

# Self-host struct-backed inheritance path (intentional return: 13)
.\x64\Debug\csec++.exe --run-ir .\selfhost\nativeflow_stage5_current.ll -- `
  .\tests\positive\05_oop\068_inherited_mutable_fields.csec `
  .\selfhost\inheritance_mutable_selfhost_probe.ll llvm
.\x64\Debug\csec++.exe --run-ir .\selfhost\inheritance_mutable_selfhost_probe.ll

# Self-host by-reference lambda capture path (intentional return: 12)
.\x64\Debug\csec++.exe --run-ir .\selfhost\nativeflow_stage5_current.ll -- `
  .\tests\positive\09_functional\098_lambda_by_reference_invocation.csec `
  .\selfhost\lambda_byref_selfhost_probe.ll llvm
.\x64\Debug\csec++.exe --run-ir .\selfhost\lambda_byref_selfhost_probe.ll

# Self-host higher-order lambda path (intentional return: 42)
.\x64\Debug\csec++.exe --run-ir .\selfhost\nativeflow_stage5_current.ll -- `
  .\tests\positive\09_functional\099_higher_order_lambda_invocation.csec `
  .\selfhost\higher_order_selfhost_probe.ll llvm
.\x64\Debug\csec++.exe --run-ir .\selfhost\higher_order_selfhost_probe.ll

# Self-host binary higher-order lambda path (intentional return: 42)
.\x64\Debug\csec++.exe --run-ir .\selfhost\nativeflow_stage5_current.ll -- `
  .\tests\positive\09_functional\100_higher_order_binary_lambda_invocation.csec `
  .\selfhost\higher_order_binary_selfhost_probe.ll llvm
.\x64\Debug\csec++.exe --run-ir .\selfhost\higher_order_binary_selfhost_probe.ll
```
