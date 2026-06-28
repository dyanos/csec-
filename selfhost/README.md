# CSEC Self-Hosting Bootstrap

This directory contains the first compiler component written in TensorScript/CSEC
itself.

`csec_compiler.csec` now has the normal compiler phases in CSEC:

- lexer for the current token surface: identifiers, keywords, numbers, strings,
  regex strings, char literals, comments, and multi-character operators;
- parser validation for balanced grouping and supported top-level declaration
  starters across the documented syntax;
- AST and symbol summaries for functions, locals, class/object members,
  templates, attributes, imports, and external declarations;
- textual selfhost IR emission, including local scope summaries and
  pseudo-LLVM control-flow lowering;
- executable C source emission for the first runnable lowering path;
- limited LLVM text emission for a `main(): Int` subset covering primitive
  locals, parameter-aware primitive type lookup, scope-aware primitive local
  assignment, direct `Int` call expressions with literal, identifier, and simple
  binary arguments, return, simple control flow, and multiple top-level
  functions returning `Int`, `Long`, `Boolean`, `Char`, `Double`, `Unit`, or
  pointer-backed types such as `String`;
- `Long`/`i64` expression, local, assignment, and return lowering;
- `Char` literal payload preservation and `i8` local, assignment, and return
  lowering for the token-kind characters used by the compiler bootstrap;
- pointer-backed local variables and assignments for `String` and similar
  lowered pointer types;
- shared flat statement lowering before returns for non-`Int` functions, so
  `Boolean`, `Char`, `Double`, `Long`, `Unit`, and pointer-backed functions keep
  local declarations and assignments emitted before their return;
- LLVM globals for string literal tokens, allowing pointer-backed string returns
  to lower to stable global addresses with preserved literal payloads for simple
  ASCII and common escaped strings.

The command-line form for a compiled selfhost compiler is:

```sh
selfhost-compiler <input.csec> <output> <tokens|ast|symbols|ir|llvm|c>
```

When run without enough arguments, it compiles `selfhost/input.csec` to
`selfhost/out.c`.

`verify_selfhost.ps1` is the fast verification path. It intentionally uses the
host compiler's `--syntax-only` and `--emit-ir` paths instead of `--run`, because
the current debug/JIT run path has been slow or has hung in this environment.
It also treats compiler diagnostics printed to stdout or stderr as failures,
even when the host process exits with code 0.

This is still a bootstrap target, not a complete replacement for the current C++
host compiler. The remaining work is full scope-aware type resolution, semantic
AST construction, complete class/template/method semantics, and verified LLVM
lowering for every currently accepted TensorScript construct.
