# TensorScript

TensorScript is an experimental language for numerical computing, data analysis,
and scientific modeling. The compiler targets math-heavy programs that should be
easy to write and still have a clear path to optimized CPU, SIMD, OpenMP, and GPU
execution.

This repository contains the current C++17 compiler prototype, its native runtime,
and language regression fixtures. The compiler parses `.csec` source files, builds
LLVM IR, and can either write IR/object files, emit native executables, or run
through the configured LLVM execution backend when available.

For language syntax, see [docs/syntax.md](docs/syntax.md).

## What Is Implemented

- Lexer/parser, AST, semantic checks, and LLVM IR generation for the current
  TensorScript/CSEC syntax.
- Scalar math, set helpers, tensor runtime helpers, and transformer-oriented
  tensor test fixtures.
- Native runtime support for printing, input, math functions, sockets, POSIX-like
  file/process helpers, parallel helpers, and dynamic library interop.
- `[@DllImport("library", "symbol")] external def ...` for native symbol imports.
- `loadLibrary`, `getSymbol`, `closeLibrary`, `callNative*`, and
  `callNativeDouble*` for runtime dynamic library calls.
- `--emit-ir`, `--emit-obj`, and `--emit-exe` output modes.

## Current Focus

- Tensor-first syntax and type forms such as `Tensor<Double, 2, 3>`.
- Math-native operators and LaTeX-inspired equation syntax.
- Collection transforms: `map`, `pmap`, `filter`, and `reduce`.
- Policy-based reduction syntax with `preduce(cpu|simd, acc, x <- xs, init)`.
- Modeling sugar for ODE, molecular dynamics, CFD, and MCMC-style examples.
- Safe-by-default ownership and explicit unsafe/nonatomic escape hatches.

## Requirements

Common requirements:

- CMake 3.16 or newer.
- A C++17 compiler.
- LLVM development files and CMake package files.
- LLVM command line tools, especially `llc`, for `--emit-obj` and `--emit-exe`.
- A native C++ linker driver, usually `c++`, `clang++`, or `g++`.

Optional requirements:

- Ninja, for faster CMake builds.
- OpenMP runtime/development package, used when available by the native parallel
  runtime.
- libedit/readline-compatible development package when required by the installed
  LLVM package. Some LLVM builds link `LLVMSupport` against editline.

### Linux Packages

Ubuntu/Debian example:

```sh
sudo apt update
sudo apt install build-essential cmake ninja-build llvm-dev clang lld
sudo apt install libomp-dev libedit-dev
```

Fedora example:

```sh
sudo dnf install gcc-c++ cmake ninja-build llvm-devel clang lld
sudo dnf install libomp-devel libedit-devel
```

Arch Linux example:

```sh
sudo pacman -S base-devel cmake ninja llvm clang lld openmp libedit
```

Package names vary by distribution. The important pieces are the LLVM CMake
package (`LLVMConfig.cmake`), LLVM libraries/headers, and the `llc` executable.

### macOS Packages

Homebrew example:

```sh
brew install cmake ninja llvm libomp libedit
```

Homebrew LLVM is not always on the default compiler/linker search path. Use
`LLVM_DIR`, `LLVM_BIN`, and `PATH` as shown below if CMake or `--emit-exe` cannot
find LLVM.

## Build

Recommended CMake build:

```sh
cmake -S . -B build -G Ninja
cmake --build build
```

If LLVM was installed in a non-default prefix, point CMake at LLVM explicitly:

```sh
cmake -S . -B build -G Ninja -DLLVM_DIR=/path/to/llvm/lib/cmake/llvm
cmake --build build
```

Common macOS/Homebrew command:

```sh
cmake -S . -B build -G Ninja -DLLVM_DIR="$(brew --prefix llvm)/lib/cmake/llvm"
cmake --build build
```

The build produces:

- `csec++`: compiler executable.
- `csec_native_runtime`: shared native runtime library copied next to the
  compiler executable.

## Compiler Usage

From the build output directory:

```sh
./csec++ --syntax-only ../tests/positive/00_smoke/001_minimal_main.csec
./csec++ --emit-ir ../tests/native/003_posix_dynamic_symbol_default.csec -o out.ll
./csec++ --emit-obj ../tests/native/003_posix_dynamic_symbol_default.csec -o out.o
./csec++ --emit-exe ../tests/native/003_posix_dynamic_symbol_default.csec -o out
./out
```

`--emit-obj` and `--emit-exe` call `llc`. The compiler searches for `llc` in:

1. `LLVM_BIN`
2. `../llvm-project/build/bin`
3. `PATH`

Examples:

```sh
export LLVM_BIN="$(brew --prefix llvm)/bin"
export PATH="$LLVM_BIN:$PATH"
```

Standard runtime APIs are provided through a C#-style native system assembly.
The build emits `System.Native.dll` on Windows, `libSystem.Native.dylib` on
macOS, or `System.Native.so` on Linux. Programs that use built-in runtime APIs
automatically link `System.Native`; `[@DllImport("System.Native", "...")]` also
resolves to the platform library extension.

`--emit-exe` compiles the program and links any required `System.*` libraries.
Override the native linker driver with `CXX` when needed:

```sh
export CXX=clang++
./csec++ --emit-exe program.csec -o program
```

Additional native libraries and search paths can be passed through:

```sh
./csec++ --emit-exe program.csec -o program \
  --link-path /usr/local/lib \
  --link-lib m
```

For dynamic library interop:

```ts
[@DllImport("libm.so", "cos")]
external def nativeCos(value: Double): Double;

def main(): Int {
    val imported: Double = nativeCos(0.0);

    val handle: Long = loadLibrary("libm.so.6");
    val symbol: Long = getSymbol(handle, "cos");
    val value: Double = callNativeDouble1(symbol, 0.0);
    closeLibrary(handle);
    return 0;
}
```

On macOS, use `.dylib` names such as `libm.dylib`. On Linux, use `.so` names such
as `libm.so.6`. Passing `0` to `getSymbol` searches the default process symbol
scope on POSIX platforms.

`nativeCos` is the TensorScript name used at the call site. The actual C symbol
is the second `DllImport` argument, `"cos"`. Avoid declaring the TensorScript
function itself as `cos`, because `cos(...)` is already a built-in scalar math
helper and will normally resolve through the native runtime math path.

## Parallel API Surface

`pmap` accepts an optional backend policy:

```ts
val ys = pmap(openmp, x <- xs) {
    x * x;
};
```

Supported policy names are `cpu`, `simd`, `openmp`, and `gpu`. `openmp` lowers
capture-free `pmap` bodies to an outlined callback and executes it through the
native parallel runtime. `simd` and `gpu` are accepted as policy names, but full
SIMD/GPU lowering remains backend work.

Runtime parallel configuration helpers:

```ts
val n = parallelThreads();
setParallelThreads(8);
val hasOpenMp = parallelBackendAvailable("openmp");
val gpuReady = parallelBackendImplemented("gpu");
```

`parallelBackendAvailable` answers whether a backend is plausible on the current
platform. `parallelBackendImplemented` answers whether this compiler/runtime path
is wired today. `gpu` is reserved syntax and currently fails during semantic
analysis/code generation instead of silently falling back to CPU execution.

Reduction can name its accumulator explicitly through `preduce`:

```ts
val total = preduce(simd, acc, x <- xs, 0) {
    acc + x;
};
```

`preduce(cpu, ...)` lowers to the normal deterministic reduction loop.
`preduce(simd, ...)` emits vectorization metadata. `preduce(openmp, ...)` and
`preduce(gpu, ...)` are reserved until real parallel reduction lowering exists.

## Design Direction

The intended high-level numerical syntax includes:

- Pipeline-friendly collection expressions.
- Typed tensors with dtype and shape information.
- Broadcasting, slicing, reductions, scans, and stencils.
- Dataframe/table operations for CSV and tabular data.
- Explicit execution policies for CPU, SIMD, OpenMP, and GPU backends.
- Backend lowering to optimized libraries such as BLAS/LAPACK and GPU math
  libraries where possible.

See `docs/memory-management.md` for the proposed ownership, borrow, move, and
unsafe pointer model.
