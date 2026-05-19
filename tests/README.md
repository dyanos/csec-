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
- `negative`: malformed programs that must fail in `--syntax-only` mode

`run_positive.ps1` is a convenience script that invokes the local compiler on every accepted `.csec` file.
`run_negative.ps1` invokes the local compiler on every rejected `.csec` file and fails if any program succeeds.
`run_semantic_positive.ps1` invokes semantic/codegen-positive files with `--emit-ir` so parser-only successes do not hide later failures.

Notes:
- The suite is intentionally broad. Some programs target parser coverage, some target later semantic/codegen support.
- Several files use overlapping syntax on purpose so regressions are easier to localize.
