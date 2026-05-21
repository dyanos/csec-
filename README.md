# TensorScript

TensorScript is an experimental language for numerical computing, data analysis,
and scientific modeling. The compiler targets math-heavy programs that should be
easy to write and still have a clear path to optimized CPU, SIMD, OpenMP, and GPU
execution.

## Current Focus

- Tensor-first syntax and type forms such as `Tensor<Double, 2, 3>`.
- Math-native operators and LaTeX-inspired equation syntax.
- Collection transforms: `map`, `pmap`, `filter`, and `reduce`.
- Policy-based reduction syntax with `preduce(cpu|simd, acc, x <- xs, init)`.
- Modeling sugar for ODE, molecular dynamics, CFD, and MCMC-style examples.
- Safe-by-default ownership and explicit unsafe/nonatomic escape hatches.

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
