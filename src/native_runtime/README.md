# Native Runtime Modules

`NativeRuntime.cpp` intentionally includes these files into one translation unit. This
keeps the existing private helper linkage and initialization order intact while giving
each compiler-runtime area a focused file.

| Module | Responsibility |
| --- | --- |
| `runtime_support.inc` | Runtime state, string builders, and LLVM helper text builders. |
| `llvm_helper_calls.inc` | LLVM helper definitions for calls and argument lowering. |
| `llvm_helper_control.inc` | LLVM helper definitions for expressions and control flow. |
| `lexer_runtime.inc` | Runtime lexer entry points and token-builder implementation. |
| `syntax_analysis.inc` | Token queries, syntax analysis, type inference, and C fallback generation. |
| `llvm_classes.inc` | Class, object, lambda, parameter, and type classification lowering helpers. |
| `llvm_arrays.inc` | Array recognition, allocation, indexing, and element access lowering. |
| `llvm_expressions.inc` | Scalar, pointer, and aggregate LLVM expression lowering. |
| `llvm_module.inc` | Flat-body and module-level LLVM generation. |
| `runtime_services.inc` | Function definition lowering and operating-system/runtime service exports. |

Keep cross-module helpers private unless they are needed by a separately compiled target.
