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
| `runtime_services.inc` | Function definition lowering, operating-system/runtime service exports, and the import / standard-library resolver shared by both compilers. |
| `bigint_runtime.inc` | Arbitrary-precision `Nat` arithmetic (`csec_bigint_*`), including division, powers, gcd, isqrt, and primality. |
| `tensor_runtime.inc` | Tensor storage and operations (`csec_tensor_*`). |
| `process_runtime.inc` | Microthread scheduler (Win32 fibers; `context_switch.inc` on POSIX), Int and text mailboxes, futures for `async`/`await`. |
| `context_switch.inc` | POSIX microthread stacks (mmap + guard page) and the x86-64 / AArch64 assembly context switch (Linux, macOS incl. Apple Silicon), with a ucontext fallback. |
| `thread_runtime.inc` | OS threads, mutexes, atomics, channels, and OS processes (`std.thread`, `std.process`). |
| `ipc_runtime.inc` | Pipes, shared memory, and mail (`std.pipe`, `std.shared`, `std.mail`), all with cooperative waiting. |
| `io_runtime.inc` | Chunked binary file reads and memory-mapped files (`std.io`). |
| `parquet_codec.inc` | Parquet building blocks: Thrift compact protocol, Snappy/GZIP/LZ4_RAW (and optional ZSTD) decompression, and the Parquet value encodings. |
| `dataframe_runtime.inc` | Data frames, Parquet reading (parallel column decoding) and writing, CSV, and frame operations (`csec_df_*`, `std.dataframe`). |
| `symbolic_runtime.inc` | Symbolic algebra engine (`csec_sym_*`, `std.symbolic`). |

Keep cross-module helpers private unless they are needed by a separately compiled target.
