# Numerical and Parallel Design Notes

TensorScript targets numerical computing, data analysis, and modeling code that can
lower to CPU, SIMD, OpenMP, and GPU backends. This document records the near-term
language surface and the implementation rules needed to make that target honest.

## Current Baseline

- `Tensor<T, Dims...>` exists as a type form.
- Tensor indexing and slicing support scalar axes and `start:end:step` slices.
- `map`, `pmap`, `filter`, and `reduce` exist for array-style collections.
- `pmap` accepts `cpu`, `simd`, `openmp`, and `gpu` policy names.
- `cpu` and `simd` lower to local loops; `simd` currently adds vectorization
  metadata.
- `openmp` lowers to an outlined callback and uses the native parallel loop
  runtime.
- `gpu` is reserved syntax. It must fail during semantic/codegen until real GPU
  lowering exists.

## Syntax Priorities

Add tensor and data-analysis sugar in this order:

1. Tensor literals and constructors:
   - `tensor([[1.0, 2.0], [3.0, 4.0]])`
   - `zeros<Double>(1024, 1024)`
   - `ones<Float>(n)`
   - `range(0, n, step=1)`
2. Axis-aware reductions:
   - `sum(x)`
   - `sum(x, axis=0)`
   - `mean`, `var`, `std`, `min`, `max`, `argmin`, `argmax`
3. Broadcast rules:
   - scalar and tensor elementwise operations are allowed.
   - same-rank tensors must have equal dimensions or dimension `1`.
   - matrix multiplication stays explicit as `@`.
4. Better reduce syntax:
   - prefer `reduce(acc, x <- xs, init) { acc + x }`
   - keep `$acc` only as a temporary compatibility form.
5. Pipeline syntax:
   - `xs |> filter(x <- _) { x > 0 } |> map(x <- _) { x * x }`

## Parallel API Priorities

Add these APIs before deeper GPU work:

- `parallelThreads() -> Int`
- `setParallelThreads(count: Int) -> Int`
- `parallelBackendAvailable(name: String) -> Int`
- `parallelBackendImplemented(name: String) -> Int`
- `preduce(policy, acc, x <- xs, init) { ... }`
- `scan(policy, x <- xs, init) { ... }`
- `stencil(policy, i <- grid.shape) { ... }`
- `zipWith(policy, x <- xs, y <- ys) { ... }`

Backend availability means the platform can plausibly support the backend.
Backend implementation means this compiler/runtime path is currently wired.

Current `preduce` status:

- `cpu` is implemented as a deterministic reduction loop.
- `simd` is implemented as a deterministic reduction loop with vectorization
  metadata.
- `openmp` and `gpu` are reserved and rejected during semantic analysis until
  real parallel reduction lowering exists.

## Safety Rules

Parallel regions should reject or require explicit annotations for:

- writes to captured variables unless they are atomic or reductions.
- mutation through aliases that may overlap the input or output collection.
- calls to impure functions from `pmap`, `preduce`, `scan`, and GPU kernels.
- nested parallel regions unless the runtime has a defined scheduling policy.

Add `pure def`, `readonly`, `atomicAdd`, and explicit `reduction(op)` forms
before exposing high-level parallel modeling examples as production-ready.

## Tensor Runtime Requirements

The current tensor runtime stores data as `double*`. The runtime must move to a
dtype-aware layout before TensorScript can correctly support `Tensor<Int, ...>`,
`Tensor<Float, ...>`, and `Tensor<Double, ...>` as distinct memory formats.

Required fields:

- rank
- dimensions
- element count
- dtype tag
- data pointer
- device placement tag

This is a prerequisite for GPU memory movement and dataframe column storage.
