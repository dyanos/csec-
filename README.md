# TensorScript

**Status: Early Stage**  
**Language Paradigm:** Functional · Tensor-first · Safe by default

TensorScript is a next-generation programming language that integrates mathematical expressiveness with systems-level performance. It combines familiar Scala and C++ syntax with first-class support for tensor operations and LaTeX-style math equation commands.

---

## 🚀 About

TensorScript is an experimental, high-level language designed for researchers and machine learning developers who demand clarity, expressiveness, and computational semantics that match modern scientific workflows.

The core mission is to let developers write code that feels like math — without sacrificing rigor, performance, or safety.

---

## 🧠 Key Features

### Math-Native Syntax with LaTeX Support
TensorScript makes mathematical code highly expressive by supporting **LaTeX-style math equation commands** directly in the language. This allows developers to write formulas in a syntax that closely mirrors their LaTeX representations.

For example, operators and expressions like `\sum`, `\prod`, `\frac{}`, and other commonly used LaTeX math commands are supported where logically applicable.

### Tensor First
At the language level, tensors are first-class citizens. Tensor computations are core to the language’s syntax and operational semantics. Under the hood, TensorScript uses the Torch C++ API for high-performance execution.

### Safety by Default
Unlike C++, pointer types are only available with the `unsafe` keyword — everything else is safe and thread-aware by default.

- Primitive types (`int`, `float`, `double`, `char`) are atomic and safe to use across threads.
- Complex types are treated as objects and passed by reference or non-reference as needed.
- Owned heap values are intended to use unique ownership by default, with explicit operator-style transfer (`target <- source`, `fn(<- source)`) and borrows (`&x`, `&mut x`).
- See [`docs/memory-management.md`](docs/memory-management.md) for the proposed ownership, borrow, move, and unsafe pointer model.
- All control constructs (`block`, `if`, `for`, `match`) are guaranteed thread-safe.

### Opt-In Unsafe Mode
Using the `unatomic` keyword explicitly disables thread safety for a section of code, when you need full control over performance trade-offs.

---

## 📘 Example (Illustrative)

```ts
// Compute a tensor expression using LaTeX-inspired math syntax
let A = tensor([1, 2, 3])
let B = tensor([3, 2, 1])

// LaTeX-style operators
let C = A ⊗ B + A²         // tensor product and power
let D = \sum_i (A_i * B_i) // summation using LaTeX-style command
````

> *Note: This example is illustrative. Actual syntax may evolve as the language matures.*

---

## 🛠️ Roadmap

The language is currently in its **initial development phase**:

* [ ] Define core grammar: Scala + C++ influences
* [ ] LaTeX-style math equation support
* [ ] Implement tensor type system (language support)
* [ ] Integrate Torch C++ API for tensor computations
* [ ] Unsafe pointer support (explicit only)
* [ ] Unique ownership and operator-style move/borrow checking
* [ ] Thread-safe primitives and control constructs
* [ ] `unatomic` keyword to disable safety guarantees

---

## 🧩 Contribution

TensorScript is early but open for collaboration.

If you’d like to contribute:

1. Fork the repository
2. Create your feature branch
3. Send a pull request with a clear description

See `CONTRIBUTING.md` for detailed guidelines.

---

## ⚖️ License

TensorScript is licensed under the **MIT License**.

---
