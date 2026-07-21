# Execution Support Progress

## Verified

- The self-host compiler reaches an LLVM fixed point (stage 5 and stage 6 are byte-identical).
- Integer expressions, comparisons, boolean operations, calls, control flow, range loops,
  literal arrays with static indexing, imports, and common return paths execute through the
  self-host LLVM path.
- Dynamic `Int` arrays support `new Int[size]`, runtime indexing, element reads, writes, and
  compound assignments. The native compiler and self-host LLVM path both execute
  `tests/positive/04_collections/050_dynamic_array_indexing.csec` with exit code `45`.
- Native compilation supports invocation of a non-capturing lambda. The regression fixture
  `tests/positive/09_functional/095_lambda_invocation.csec` exits with `42`.
- Self-host lowering supports `Int`-returning static object methods and qualified calls. The
  regression fixture `tests/positive/05_oop/058_object_multiple_methods.csec` executes with
  exit code `85`.
- Self-host lowering supports classes whose constructor has `Int` parameters and whose methods
  read those parameters. Constructor values are passed as explicit receiver arguments to the
  lowered method. `052_method_calls_and_paths.csec` exits with `21`, and the multi-method
  `055_class_many_methods.csec` exits with `62`.
- Class methods also initialize and read `Int` fields declared with literal expressions in the
  class body. `053_objects_and_members.csec` executes with exit code `16`.

## Still Incomplete

- Lambda closures: explicit captures, by-reference captures, and self-host lambda lowering.
- Arrays beyond the current `Int` flat-storage path: other element types, nested/dynamic shape
  semantics, array parameters/returns, bounds behavior, and general ownership.
- Mutable class fields, mutation persistence across calls, inheritance, reference semantics,
  and non-`Int` constructor state in the self-host LLVM emitter. Static object methods,
  constructor-parameter-backed methods, and literal `Int` fields currently cover the `Int` path.
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
```
