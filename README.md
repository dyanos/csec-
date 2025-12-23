아래는 **추천 옵션 기준**으로 작성한 **영문 GitHub README.md** 초안입니다. 필요하면 바로 수정/확장도 가능합니다.

---

````markdown
# TensorScript

**Status: Early Stage**  
**Language Paradigm:** Functional · Tensor-first · Safe by default

TensorScript is a next-generation programming language that integrates mathematical expressiveness with systems-level performance. It combines familiar Scala and C++ syntax with first-class support for tensor operations and math-native commands inspired by LaTeX.

---

## 🚀 About

TensorScript is an experimental, high-level language designed for researchers and machine learning developers who demand clarity, expressiveness, and computational semantics that match modern scientific workflows.

The core mission is to let developers write code that feels like math — without sacrificing rigor, performance, or safety.

---

## 🧠 Key Features

### Math-Native Syntax
TensorScript supports math equation commands similar to those in LaTeX, allowing you to express algebraic and tensor operations in a natural, readable style.

### Tensor First
At the language level, tensors are first-class citizens. Tensor computations are core to the language’s syntax and operational semantics. Under the hood, TensorScript uses the Torch C++ API for high-performance execution.

### Safety by Default
Unlike C++, pointer types are only available with the `unsafe` keyword — everything else is safe and thread-aware by default.

- Primitive types (`int`, `float`, `double`, `char`) are atomic and safe to use across threads.
- Complex types are treated as objects and passed by reference or non-reference as needed.
- All control constructs (`block`, `if`, `for`, `match`) are guaranteed thread-safe.

### Opt-In Unsafe Mode
Using the `unatomic` keyword explicitly disables thread safety for a section of code, when you need full control over performance trade-offs.

---

## 📘 Example (Illustrative)

```ts
// Compute a tensor expression using math-native operators
let A = tensor([1, 2, 3])
let B = tensor([3, 2, 1])

// Math-like syntax
let C = A ⊗ B + A²
````

> *Note: This example is illustrative. Actual syntax may evolve as the language matures.*

---

## 🛠️ Roadmap

The language is currently in its **initial development phase**:

* [x] Define core grammar: Scala + C++ influences
* [x] Math-native equations (LaTeX-inspired)
* [ ] Implement tensor type system (language support)
* [ ] Integrate Torch C++ API for tensor computations
* [ ] Unsafe pointer support (explicit only)
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
