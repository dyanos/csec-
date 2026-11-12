# TensorScript Test Suite

This directory contains source programs that the compiler should accept or reject.

Layout:
- `positive/00_smoke`: minimal entry points and basic declarations
- `positive/01_declarations`: imports, attributes, externals, objects, top-level constants
- `positive/02_expressions`: literal forms and operator coverage
- `positive/03_control_flow`: `if`, `for`, `while`, `match`
- `positive/04_collections`: arrays, lambdas, `map`, `pmap`, `reduce`, `filter`
- `positive/05_oop`: classes, inheritance, method calls, `new`
- `positive/06_templates`: generic and non-type template parameters
- `positive/07_math_latex`: inline and block LaTeX math constructs
- `positive/08_utf8`: UTF-8 identifiers and Unicode source text (Korean, Japanese, Chinese)
- `positive/09_functional`: function types, lambdas, capture modes, higher-order patterns
- `positive/10_integration`: end-to-end programs combining multiple features
- `positive/11_tensor`: Tensor type parameters, creation, indexing, and operator syntax
- `positive/12_native`, `positive/13_simulation`: native runtime calls and simulation DSL blocks
- `negative`: malformed programs that must fail in `--syntax-only` mode
- `microthread/{positive,negative}`: microthreads, `go`/`async`/`await`, share-nothing rules
- `stdlib/{positive,negative}`: the `lib/std` modules (threads, processes, pipes, shared memory, mail, I/O, math, symbolic)
- `selfhost_concurrency`: programs that must exit with 42 through both the native and the self-hosted compiler
- `async`, `strict_ownership`, `semantic_positive`, `semantic_negative`: async/borrow rules and ownership checks

`run_positive.ps1` is a convenience script that invokes the local compiler on every accepted `.csec` file.
`run_negative.ps1` invokes the local compiler on every rejected `.csec` file and fails if any program succeeds.
`run_semantic_positive.ps1` invokes semantic/codegen-positive files with `--emit-ir` so parser-only successes do not hide later failures.
`run_microthread.ps1` compiles and runs `microthread/` (`-Suite stdlib` for `stdlib/`); positives must exit 0, negatives must be rejected.
`run_selfhost_concurrency.ps1` runs every `selfhost_concurrency/` program through both compilers and requires exit code 42 from each.
`run_async.ps1` and `run_strict_ownership.ps1` cover the async/borrow and ownership rules.

Notes:
- The suite is intentionally broad. Some programs target parser coverage, some target later semantic/codegen support.
- Several files use overlapping syntax on purpose so regressions are easier to localize.
