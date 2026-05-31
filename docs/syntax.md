# TensorScript Syntax Overview

This document summarizes the current TensorScript/CSEC syntax supported by the
compiler prototype. The language is still experimental, so this file describes
the implemented surface rather than a stable specification.

## Files And Entry Point

Source files use the `.csec` extension. Executable programs usually define a
zero-argument `main` function:

```ts
def main(): Int {
    return 0;
}
```

## Declarations

Variables are declared with `val` or `var`. Use `val` for single-assignment
bindings and `var` for values that are reassigned:

```ts
val count: Int = 3;
var scale: Double = 0.5;
val label: String = "run";
scale = scale + 1.0;
```

Functions use `def` with typed parameters and return type:

```ts
def add(left: Int, right: Int): Int {
    return left + right;
}
```

External native functions can be declared with `external def`:

```ts
external def puts(message: String): Int;
```

Native library metadata can be attached with attributes:

```ts
[@DllImport("legacy_stdio_definitions.lib", "puts")]
external def nativePuts(message: String): Int;

def main(): Int {
    nativePuts("hello");
    return 0;
}
```

## Primitive Types

Common scalar types include:

- `Int`
- `Long`
- `Double`
- `Bool`
- `Char`
- `String`

## Expressions

The compiler supports standard arithmetic, comparison, boolean, bitwise, and
assignment-style expressions:

```ts
val a: Int = 2 + 3 * 4;
val b: Bool = a >= 10 and a != 0;
val c: Int = (a << 1) | 1;
```

Supported boolean operators include `and`, `or`, and `xor`.

String literals are inferred as `String`. If either side of `+` is `String`,
the other primitive value is converted with the runtime `toString` path:

```ts
val message = "score=" + 4 + ", ok=" + true;
```

## Classes, Overloading, And Overriding

Classes can declare fields and methods. Methods can be overloaded by parameter
types:

```ts
class Formatter() {
    def show(value: Int): Int {
        return value + 1;
    }

    def show(value: String): String {
        return value + "!";
    }
}
```

Subclasses can override a superclass method with the same parameter signature:

```ts
class Child extends Formatter {
    override def show(value: String): String {
        return "child=" + value;
    }
}
```

Operator overloads are declared as `def operator <op>(...)` inside a class.
For example, `counter + 4` calls `counter.operator+(4)`:

```ts
class Counter() {
    def operator +(right: Int): Int {
        return right + 1;
    }
}
```

## Control Flow

Conditional statements:

```ts
if (value > 0) {
    return 1;
}
return 0;
```

Loops:

```ts
for (x <- xs) {
    print(x);
}

var i: Int = 0;
while (i < 5) {
    i = i + 1;
}
```

## Collections And Ranges

Array literals and ranges are used by collection transforms:

```ts
val xs = [1, 2, 3, 4];
val indices = 0..10;
```

Mapping, filtering, and reduction syntax:

```ts
val squares = map(x <- xs) {
    x * x;
};

val even = filter(x <- xs) {
    x % 2 == 0;
};

val total = reduce(acc, x <- xs, 0) {
    acc + x;
};
```

Parallel map and policy-based reduction:

```ts
val ys = pmap(openmp, x <- xs) {
    x * x;
};

val sum = preduce(simd, acc, x <- xs, 0) {
    acc + x;
};
```

Current policy names include `cpu`, `simd`, `openmp`, and `gpu`. Some policies
are parsed before full backend lowering is implemented.

## Tensors

Tensor types carry an element type and shape:

```ts
val weights: Tensor<Double, 2, 3> = tensor([[0.1, 0.2, 0.3], [0.4, 0.5, 0.6]]);
```

The current runtime includes tensor-oriented helpers such as `sum`, `mean`,
`norm`, `relu`, `softmax`, and `mse`.

## Math And Set Helpers

Scalar math helpers include:

```ts
abs(x);
sign(x);
floor(x);
ceil(x);
round(x);
lcm(a, b);
clamp(x, low, high);
between(x, low, high);
approxEq(a, b, eps);
```

Set helpers include:

```ts
emptySet();
singleton(x);
cardinality(s);
disjoint(a, b);
complement(a, universe);
```

## Native Dynamic Library Calls

Runtime dynamic loading uses handles and symbol pointers represented as `Long`:

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

Integer-like calls use `callNative0`, `callNative1`, `callNative2`, and
`callNative3`. Floating-point calls use `callNativeDouble0`,
`callNativeDouble1`, and `callNativeDouble2`.

The local name `nativeCos` is intentionally different from the imported C symbol
`"cos"`. A TensorScript call named `cos(...)` is already a built-in scalar math
call, so use a different local name when importing the C library symbol directly.

## LaTeX-Inspired Math

The parser includes experimental inline and block LaTeX-inspired math forms for
matrix, summation, product, set, and function-style notation. See the fixtures in
`tests/positive/07_math_latex` for currently supported examples.

## Notes

- Statements generally end with `;`.
- Blocks use `{ ... }`.
- The language and runtime are evolving; tests under `tests/positive`,
  `tests/semantic_positive`, `tests/negative`, and `tests/native` are the best
  reference for exact accepted syntax.
