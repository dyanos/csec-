# Execution Support Progress

## Verified

- The checked-in `nativeflow_stage5_current.ll` and `nativeflow_stage6_current.ll` are
  byte-identical, so the compiler reached an LLVM fixed point when those artifacts were
  produced. That fixed point no longer reproduces against the current native runtime — see
  "Self-Host Bootstrap Status" below.
- Integer expressions, comparisons, boolean operations, calls, control flow, range loops,
  literal arrays with static indexing, imports, and common return paths execute through the
  self-host LLVM path.
- Dynamic `Int` arrays support `new Int[size]`, runtime indexing, element reads, writes, and
  compound assignments. The native compiler and self-host LLVM path both execute
  `tests/positive/04_collections/050_dynamic_array_indexing.csec` with exit code `45`.
- `Vector[Int]` parameters now use the pointer ABI at call sites, and indexed reads inside the
  callee use the same flat `Int` array storage. `057_vector_parameter_indexing.csec` exits with
  `42` through the self-host LLVM path.
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
- Higher-order calls compose unary lambda values without losing the nested indirect-call result.
  `101_higher_order_compose_invocation.csec` exits with `41`.
- `Boolean`-returning lambda functions and function-type parameters now retain their `i1` ABI
  through hidden lambda definitions, direct higher-order calls, and indirect calls. The result is
  widened only when an `Int` control-flow path needs it. `102_higher_order_boolean_lambda_invocation.csec`
  exits with `42`.
- Explicit by-value captures also work for directly invoked `Boolean` lambdas.
  `103_boolean_capture_invocation.csec` exits with `42`.
- Lambda values now use a `{ code, environment }` closure ABI. It preserves captured `Int`
  values through higher-order calls for both `Int` and `Boolean` function signatures.
  `104_higher_order_capture_invocation.csec` and
  `105_higher_order_boolean_capture_invocation.csec` both exit with `42`.
- By-reference captures use pointer fields in that same closure environment, preserving mutation
  across higher-order calls. `106_higher_order_by_reference_capture_invocation.csec` exits with
  `12`.
- Ordinary `Boolean` parameters and return values preserve the LLVM `i1` ABI through direct
  calls and control-flow conditions. `107_boolean_parameter_and_return.csec` exits with `42`.
- Local `Boolean` declarations and assignments now use `i1` storage in both `Int` and
  `Boolean` function bodies. `108_boolean_local_state.csec` exits with `42`.
- String locals and parameters use pointer storage in the self-host LLVM path. `length` and
  `size()` lower through `csec_string_length`; `141_string_length_execution.csec` exits with
  `10`.
- String `==` and `!=` lower through `csec_string_equals` for literals, locals, and parameters.
  `142_string_equality_execution.csec` exits with `42`.
- String concatenation lowers through `csec_string_concat`, and `String` functions return `ptr`
  values that can initialize String locals. `143_string_concat_and_return.csec` exits with `6`.
- Class layouts and pointer receivers support `String` constructor parameters and `String` fields.
  `072_string_constructor_field.csec` stores a String constructor value, invokes an instance
  method, and exits with `9` after lowering the field read through `ptr` storage.
- String-valued instance methods return class-backed pointer fields through the pointer ABI.
  `073_string_field_return.csec` returns a String from an instance method, initializes a String
  local from that call, and exits with `7`.
- String instance methods can concatenate a class-backed String field with a literal through
  `csec_string_concat`. `074_string_field_concat.csec` exits with `6`.
- String predicate members `isEmpty`, `contains`, `startsWith`, and `endsWith`, plus `indexOf`,
  lower through the runtime pointer ABI. `144_string_predicate_execution.csec` exits with `40`.
- String transformation members `trim`, `toUpper`, `toLower`, `substring`, and `toString` return
  pointer values that initialize String locals. `145_string_transform_execution.csec` exits with
  `10`.
- `String.charAt` lowers its `i8` runtime result into the `Int` expression ABI.
  `146_string_char_at_execution.csec` exits with `69`.
- Untyped String-transform locals retain the pointer ABI, and `println` lowers String and `Int`
  arguments to the native output runtime. The existing `120_string_members.csec` integration
  fixture now executes through the self-host LLVM path with exit code `0`.
- `Float` expressions now use LLVM `float` values end-to-end for literals, unary negation,
  `+`, `-`, `*`, `/`, direct calls, pointer-receiver class method calls, local storage, and
  comparisons in `Int` and `Boolean` control-flow conditions. Float-returning bodies support
  nested `if` and `while` CFG lowering with Float local assignment. `147_float_execution.csec`,
  `148_float_class_execution.csec`, and `112_basic_math_class.csec` all execute through the
  self-host LLVM path with exit code `0`.
- `Double` expressions now preserve their `double` ABI for literals, unary negation, arithmetic,
  direct and class-method calls, local storage, and Boolean control-flow conditions. Double-
  returning bodies support `if`/`while` CFG lowering with Double local assignment.
  `149_double_execution.csec`, `150_double_class_execution.csec`, and
  `151_double_control_flow_execution.csec` execute through the self-host LLVM path with exit
  code `0`.
- Boolean arrays now lower to stack-backed LLVM `i1` storage for literal and `new Boolean[n]`
  declarations, indexed loads, indexed assignment, and `Vector[Boolean]` parameter calls inside
  Int- and Boolean-returning functions. `152_boolean_array_execution.csec` and
  `153_boolean_vector_parameter_execution.csec` execute through the self-host LLVM path with exit
  code `0`.
- `Vector[Int]` values now preserve their pointer ABI when forwarding a parameter through a
  function return and storing that result in an explicitly typed local. The returned vector can be
  indexed by the caller; `154_vector_return_execution.csec` executes through the self-host LLVM
  path with exit code `0`.
- `Vector[String]` parameter forwarding also preserves the existing pointer storage on return.
  The caller can infer the returned vector element type when indexing it; the native and self-host
  LLVM paths both execute `158_string_vector_return_execution.csec` with exit code `0`.
- `Float` arrays now use stack-backed LLVM `float` storage for `new Float[n]`, indexed reads,
  indexed assignment, Float comparisons, and `Vector[Float]` parameter calls. The native and
  self-host LLVM paths both execute `155_float_array_execution.csec` with exit code `0`.
- `Vector[Float]` and `Vector[Double]` parameter forwarding preserve pointer storage when a
  function return initializes an explicitly typed local. The caller can index the returned vector;
  the native and self-host LLVM paths both execute `159_float_vector_return_execution.csec` and
  `160_double_vector_return_execution.csec` with exit code `0`.
- `Double` arrays now use stack-backed LLVM `double` storage for `new Double[n]`, indexed reads,
  indexed assignment, Double comparisons, and `Vector[Double]` parameter calls. The self-host
  and direct compiler LLVM paths both execute `156_double_array_execution.csec` with exit code
  `0`.
- `String` arrays now use stack-backed LLVM pointer storage for `new String[n]`, indexed reads,
  indexed assignment, and `Vector[String]` calls that return a String element. Canonical primitive
  names are also recognized during direct array creation. Local call initializers infer declared
  function return types, preserving pointer return values without an explicit annotation. The direct
  compiler and self-host LLVM paths both execute `157_string_array_execution.csec` with exit code
  `0`.
- `Char` arrays now preserve their LLVM `i8` element ABI for `new Char[n]`, indexed assignment,
  `Vector[Char]` parameter reads, Char-returning calls, and comparisons after widening to the
  integer condition ABI. `Vector[Char]` forwarding also preserves the underlying array pointer on
  return. The direct compiler and self-host LLVM paths both execute
  `161_char_array_execution.csec` and `162_char_vector_return_execution.csec` with exit code `0`.
- `Short` arrays now preserve their LLVM `i16` element ABI for `new Short[n]`, indexed
  assignment, `Vector[Short]` forwarding, Short-returning indexed reads, and comparisons. The
  direct compiler and self-host LLVM paths both execute `169_short_array_execution.csec` with
  exit code `0`.
- `Byte` arrays and `Vector[Byte]` now share the `Char` `i8` element ABI for allocation,
  indexed writes and reads, parameter calls, and comparisons. The self-host LLVM path executes
  `170_byte_array_execution.csec` with exit code `0`.
- `Long` values now preserve their LLVM `i64` ABI for 32-bit-overflowing integer literals, local
  storage, arithmetic, direct function calls, and comparisons. The direct compiler and self-host
  LLVM paths both execute `163_long_execution.csec` with exit code `0`.
- `Natural` and `Integer` now share the `Long` `i64` ABI in the self-host LLVM generator for
  function parameters and returns, local storage, arithmetic, calls, and comparisons.
  The direct parser also recognizes both as basic types, rather than class names. The direct and
  self-host LLVM paths both generate and execute `164_natural_execution.csec` and
  `165_integer_execution.csec` with exit code `0`, including values above the signed `Int` range.
- `Byte` now preserves its direct compiler `i8` ABI through self-host function parameters and
  returns, local storage, arithmetic, calls, and comparisons. The direct and self-host LLVM paths
  both execute `167_byte_execution.csec` with exit code `0`.
- `Long` arrays and `Vector[Long]` now use stack-backed LLVM `i64` element storage for
  `new Long[n]` (also `Natural` and `Integer`), indexed assignment, indexed reads, parameter
  calls, comparisons, and forwarding an array pointer through a function return. `Long`-returning
  block bodies lower their `return` expression instead of falling back to a literal. The direct
  compiler and self-host LLVM paths both execute `171_long_array_execution.csec` and
  `173_long_vector_return_execution.csec` with exit code `0`.
- Call arguments split on commas that sit outside every nested group, so a nested call such as
  `addPair(addPair(1, 2), addPair(3, 4))` no longer splices the inner arguments into the outer
  call. The same depth-aware split applies to array literals, array dimension lists, and
  constructor argument lists. `172_nested_call_execution.csec` exits with `0` on both paths.
- Integer literal arrays without a type annotation stay `Int` arrays; they were previously given
  `i16` element storage and read back as `i32`. `Vector[Short]`, `Vector[Long]`,
  `Vector[Natural]`, and `Vector[Integer]` annotations select the narrower or wider element
  storage for a literal initializer. This restores `057_vector_parameter_indexing.csec` (`42`)
  and `154_vector_return_execution.csec` (`0`).
- `String` arguments passed to `Boolean`-returning functions keep the pointer ABI at the call
  site instead of being truncated to `i32`. This restores `142_string_equality_execution.csec`
  (`42`), which previously faulted.
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
- Struct-backed class receivers now support `Boolean` constructor state and `Boolean` instance
  method returns with `i1` slots and calls. `069_boolean_constructor_state.csec` exits with `42`.
- Direct class-body `Boolean` fields support literal initialization, assignment in a Boolean
  method body, and persistent reads across calls. `070_boolean_field_mutation.csec` exits with
  `42`.
- Child class layouts carry inherited `Boolean` field slots, and `super` calls preserve their
  `i1` result ABI. `071_inherited_boolean_field.csec` exits with `42`.

## Self-Host Bootstrap Status

Recompiling `selfhost/csec_compiler.csec` with `nativeflow_stage5_current.ll` no longer
reproduces `nativeflow_stage6_current.ll`; the native runtime has moved ahead of those
checked-in artifacts. The regenerated stage-6 module is not yet loadable, and the current
blocker is `generateLLVMVoidBodyFromRange` (`selfhost/csec_compiler.csec:4610`):

- `String`-returning functions with a multi-statement body only lower their first `return`
  expression. Local declarations, loops, and branches before that `return` are dropped, so the
  emitted module references allocas that were never written (`use of undefined value
  '%builder.addr.…'`).
- `runtime_services.inc` has flat-body generators for `i32`, `i1`, `float`, and `double`
  result types, but none for `ptr`. Adding `csec_generate_llvm_flat_body_ptr` is the next step;
  further blockers may follow behind it.

## Still Incomplete

- `String`-returning function bodies beyond a single `return` expression, and with them the
  self-host bootstrap fixed point (see above).
- Lambda closures: non-`Int` signatures beyond the verified `Boolean` return ABI, broader
  higher-order ABI coverage, and closure environment ownership.
- Arrays beyond the current `Int`/`Boolean`/`Byte`/`Char`/`Short`/`Long`/`Float`/`Double`/`String`
  flat-storage path: other element types, nested/dynamic shape semantics, newly-created array
  returns, bounds behavior, and general ownership.
- Unannotated float literal arrays default to `Float` storage rather than `Double`.
- Reference semantics beyond the current stack-backed instance path, general field access syntax,
  and non-`Int` constructor or field state in the self-host LLVM emitter. `Int` inheritance,
  including struct-backed parent fields and `super` dispatch, is supported.
- Generic/template execution, enum/union/nullable/ownership behavior, rich string/char
  interactions, complete match patterns, iterable collection loops, broad function ABI coverage,
  and mixed numeric conversion semantics remain incomplete.

## Validation Commands

The native runtime (`System.Native.dll`) must be rebuilt and copied next to `csec++.exe` after
any change under `src/native_runtime/`; `build_runtime.bat` at the repository root does both
steps.

```powershell
# Self-host Long array, Vector[Long] forwarding, and nested call paths (intentional return: 0)
.\x64\Debug\csec++.exe --run-ir .\selfhost\nativeflow_stage5_current.ll -- `
  .\tests\positive\10_integration\171_long_array_execution.csec `
  .\selfhost\long_array_selfhost_probe.ll llvm
.\x64\Debug\csec++.exe --run-ir .\selfhost\long_array_selfhost_probe.ll
.\x64\Debug\csec++.exe --run-ir .\selfhost\nativeflow_stage5_current.ll -- `
  .\tests\positive\10_integration\173_long_vector_return_execution.csec `
  .\selfhost\long_vector_return_selfhost_probe.ll llvm
.\x64\Debug\csec++.exe --run-ir .\selfhost\long_vector_return_selfhost_probe.ll
.\x64\Debug\csec++.exe --run-ir .\selfhost\nativeflow_stage5_current.ll -- `
  .\tests\positive\10_integration\172_nested_call_execution.csec `
  .\selfhost\nested_call_selfhost_probe.ll llvm
.\x64\Debug\csec++.exe --run-ir .\selfhost\nested_call_selfhost_probe.ll

# Native dynamic array path
.\x64\Debug\csec++.exe --emit-ir -o .\selfhost\dynamic_array_check.ll `
  .\tests\positive\04_collections\050_dynamic_array_indexing.csec
.\x64\Debug\csec++.exe --run-ir .\selfhost\dynamic_array_check.ll

# Self-host dynamic array path
.\x64\Debug\csec++.exe --run-ir .\selfhost\nativeflow_stage5_current.ll -- `
  .\tests\positive\04_collections\050_dynamic_array_indexing.csec `
  .\selfhost\dynamic_array_selfhost.ll llvm
.\x64\Debug\csec++.exe --run-ir .\selfhost\dynamic_array_selfhost.ll

# Self-host Vector[Int] parameter and indexed-read path (intentional return: 42)
.\x64\Debug\csec++.exe --run-ir .\selfhost\nativeflow_stage5_current.ll -- `
  .\tests\positive\04_collections\057_vector_parameter_indexing.csec `
  .\selfhost\vector_parameter_selfhost_probe.ll llvm
.\x64\Debug\csec++.exe --run-ir .\selfhost\vector_parameter_selfhost_probe.ll

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

# Self-host Boolean class constructor and instance method path (intentional return: 42)
.\x64\Debug\csec++.exe --run-ir .\selfhost\nativeflow_stage5_current.ll -- `
  .\tests\positive\05_oop\069_boolean_constructor_state.csec `
  .\selfhost\boolean_class_selfhost_probe.ll llvm
.\x64\Debug\csec++.exe --run-ir .\selfhost\boolean_class_selfhost_probe.ll

# Self-host mutable Boolean class field path (intentional return: 42)
.\x64\Debug\csec++.exe --run-ir .\selfhost\nativeflow_stage5_current.ll -- `
  .\tests\positive\05_oop\070_boolean_field_mutation.csec `
  .\selfhost\boolean_field_selfhost_probe.ll llvm
.\x64\Debug\csec++.exe --run-ir .\selfhost\boolean_field_selfhost_probe.ll

# Self-host inherited Boolean field and super-call path (intentional return: 42)
.\x64\Debug\csec++.exe --run-ir .\selfhost\nativeflow_stage5_current.ll -- `
  .\tests\positive\05_oop\071_inherited_boolean_field.csec `
  .\selfhost\inherited_boolean_selfhost_probe.ll llvm
.\x64\Debug\csec++.exe --run-ir .\selfhost\inherited_boolean_selfhost_probe.ll

# Self-host String constructor field and instance method path (intentional return: 9)
.\x64\Debug\csec++.exe --run-ir .\selfhost\nativeflow_stage5_current.ll -- `
  .\tests\positive\05_oop\072_string_constructor_field.csec `
  .\selfhost\string_constructor_field_selfhost_probe.ll llvm
.\x64\Debug\csec++.exe --run-ir .\selfhost\string_constructor_field_selfhost_probe.ll

# Self-host String field return and caller-local initialization path (intentional return: 7)
.\x64\Debug\csec++.exe --run-ir .\selfhost\nativeflow_stage5_current.ll -- `
  .\tests\positive\05_oop\073_string_field_return.csec `
  .\selfhost\string_field_return_selfhost_probe.ll llvm
.\x64\Debug\csec++.exe --run-ir .\selfhost\string_field_return_selfhost_probe.ll

# Self-host String field concatenation in an instance method (intentional return: 6)
.\x64\Debug\csec++.exe --run-ir .\selfhost\nativeflow_stage5_current.ll -- `
  .\tests\positive\05_oop\074_string_field_concat.csec `
  .\selfhost\string_field_concat_probe.ll llvm
.\x64\Debug\csec++.exe --run-ir .\selfhost\string_field_concat_probe.ll

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

# Self-host composed higher-order lambda path (intentional return: 41)
.\x64\Debug\csec++.exe --run-ir .\selfhost\nativeflow_stage5_current.ll -- `
  .\tests\positive\09_functional\101_higher_order_compose_invocation.csec `
  .\selfhost\higher_order_compose_selfhost_probe.ll llvm
.\x64\Debug\csec++.exe --run-ir .\selfhost\higher_order_compose_selfhost_probe.ll

# Self-host Boolean higher-order lambda path (intentional return: 42)
.\x64\Debug\csec++.exe --run-ir .\selfhost\nativeflow_stage5_current.ll -- `
  .\tests\positive\09_functional\102_higher_order_boolean_lambda_invocation.csec `
  .\selfhost\higher_order_boolean_selfhost_probe.ll llvm
.\x64\Debug\csec++.exe --run-ir .\selfhost\higher_order_boolean_selfhost_probe.ll

# Self-host direct Boolean capture lambda path (intentional return: 42)
.\x64\Debug\csec++.exe --run-ir .\selfhost\nativeflow_stage5_current.ll -- `
  .\tests\positive\09_functional\103_boolean_capture_invocation.csec `
  .\selfhost\boolean_capture_selfhost_probe.ll llvm
.\x64\Debug\csec++.exe --run-ir .\selfhost\boolean_capture_selfhost_probe.ll

# Self-host captured closure higher-order paths (intentional return: 42)
.\x64\Debug\csec++.exe --run-ir .\selfhost\nativeflow_stage5_current.ll -- `
  .\tests\positive\09_functional\104_higher_order_capture_invocation.csec `
  .\selfhost\closure_int_hof_probe.ll llvm
.\x64\Debug\csec++.exe --run-ir .\selfhost\closure_int_hof_probe.ll
.\x64\Debug\csec++.exe --run-ir .\selfhost\nativeflow_stage5_current.ll -- `
  .\tests\positive\09_functional\105_higher_order_boolean_capture_invocation.csec `
  .\selfhost\closure_bool_hof_probe.ll llvm
.\x64\Debug\csec++.exe --run-ir .\selfhost\closure_bool_hof_probe.ll

# Self-host by-reference closure higher-order path (intentional return: 12)
.\x64\Debug\csec++.exe --run-ir .\selfhost\nativeflow_stage5_current.ll -- `
  .\tests\positive\09_functional\106_higher_order_by_reference_capture_invocation.csec `
  .\selfhost\closure_byref_hof_probe.ll llvm
.\x64\Debug\csec++.exe --run-ir .\selfhost\closure_byref_hof_probe.ll

# Self-host Boolean parameter and return ABI path (intentional return: 42)
.\x64\Debug\csec++.exe --run-ir .\selfhost\nativeflow_stage5_current.ll -- `
  .\tests\positive\09_functional\107_boolean_parameter_and_return.csec `
  .\selfhost\boolean_param_selfhost_probe.ll llvm
.\x64\Debug\csec++.exe --run-ir .\selfhost\boolean_param_selfhost_probe.ll

# Self-host Boolean local declaration and assignment path (intentional return: 42)
.\x64\Debug\csec++.exe --run-ir .\selfhost\nativeflow_stage5_current.ll -- `
  .\tests\positive\09_functional\108_boolean_local_state.csec `
  .\selfhost\boolean_local_selfhost_probe.ll llvm
.\x64\Debug\csec++.exe --run-ir .\selfhost\boolean_local_selfhost_probe.ll

# Self-host String local, parameter, length and size path (intentional return: 10)
.\x64\Debug\csec++.exe --run-ir .\selfhost\nativeflow_stage5_current.ll -- `
  .\tests\positive\10_integration\141_string_length_execution.csec `
  .\selfhost\string_length_selfhost_probe.ll llvm
.\x64\Debug\csec++.exe --run-ir .\selfhost\string_length_selfhost_probe.ll

# Self-host String equality and inequality path (intentional return: 42)
.\x64\Debug\csec++.exe --run-ir .\selfhost\nativeflow_stage5_current.ll -- `
  .\tests\positive\10_integration\142_string_equality_execution.csec `
  .\selfhost\string_equality_selfhost_probe.ll llvm
.\x64\Debug\csec++.exe --run-ir .\selfhost\string_equality_selfhost_probe.ll

# Self-host String concatenation and return-value path (intentional return: 6)
.\x64\Debug\csec++.exe --run-ir .\selfhost\nativeflow_stage5_current.ll -- `
  .\tests\positive\10_integration\143_string_concat_and_return.csec `
  .\selfhost\string_concat_selfhost_probe.ll llvm
.\x64\Debug\csec++.exe --run-ir .\selfhost\string_concat_selfhost_probe.ll

# Self-host String predicate and index member path (intentional return: 40)
.\x64\Debug\csec++.exe --run-ir .\selfhost\nativeflow_stage5_current.ll -- `
  .\tests\positive\10_integration\144_string_predicate_execution.csec `
  .\selfhost\string_predicate_probe.ll llvm
.\x64\Debug\csec++.exe --run-ir .\selfhost\string_predicate_probe.ll

# Self-host String transform member path (intentional return: 10)
.\x64\Debug\csec++.exe --run-ir .\selfhost\nativeflow_stage5_current.ll -- `
  .\tests\positive\10_integration\145_string_transform_execution.csec `
  .\selfhost\string_transform_probe.ll llvm
.\x64\Debug\csec++.exe --run-ir .\selfhost\string_transform_probe.ll

# Self-host String character access path (intentional return: 69)
.\x64\Debug\csec++.exe --run-ir .\selfhost\nativeflow_stage5_current.ll -- `
  .\tests\positive\10_integration\146_string_char_at_execution.csec `
  .\selfhost\string_char_at_probe.ll llvm
.\x64\Debug\csec++.exe --run-ir .\selfhost\string_char_at_probe.ll

# Self-host full String-member and println integration path (intentional return: 0)
.\x64\Debug\csec++.exe --run-ir .\selfhost\nativeflow_stage5_current.ll -- `
  .\tests\positive\10_integration\120_string_members.csec `
  .\selfhost\string_members_probe.ll llvm
.\x64\Debug\csec++.exe --run-ir .\selfhost\string_members_probe.ll
```
