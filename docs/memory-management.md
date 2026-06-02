# Memory Management Design

This document records the proposed ownership and pointer model for TensorScript.
The goal is to keep C++-level control available while making the default path
safe, deterministic, and easy for the compiler to check.

## Core Direction

TensorScript separates value types, reference types, static modules, and
explicit owned heap values.

- `struct` is a value type. `new Struct(...)` creates stack/local storage and
  should use value/copy semantics.
- `class` is a reference type. `new Class(...)` creates heap storage, but plain
  `Class` references are not themselves move-checked ownership handles.
- `object` is a static namespace/module declaration, not a heap or stack
  instance in the ownership model.
- `box T` is the explicit uniquely owned heap handle. It is the type that
  participates in move checking and future drop/destructor handling.
- Raw pointers are available only through `unsafe *T`.
- Raw pointer creation and dereference require an unsafe context.

This keeps raw pointers compatible with C++ interop, but prevents them from
becoming the normal ownership mechanism.

## Ownership Types

Recommended surface types:

```ts
T             // value or reference, depending on the declaration kind
struct T      // value type declaration
class T       // reference type declaration
object T      // static namespace/module declaration
box T         // uniquely owned heap value
&T            // immutable borrow
&mut T        // mutable borrow
unsafe *T     // raw pointer, non-owning
```

`box T` is the language-facing owned heap concept. The compiler can lower it to
`std::unique_ptr<T>` in generated C++ or an equivalent runtime representation.
Plain `class` references can be passed around without `<-`; wrapping a class in
`box` opts into explicit ownership transfer.

`unsafe *T` deliberately remains close to C++ pointer syntax. The `unsafe`
marker belongs to the pointer type so that risk stays visible in function
signatures, fields, and local variables.

## Operators

The language should avoid `move` and `borrow` as keywords. Ownership actions
should look like operators.

```ts
y <- x;          // move ownership from x into y
store(<- x);     // move ownership from x into an owning parameter
let r = &x;      // immutable borrow
let m = &mut x;  // mutable borrow
let v = *p;      // raw pointer dereference, unsafe only
```

### Move Assignment: `target <- source`

`target <- source` transfers ownership from `source` into `target` when
`source` has an ownership-checked type such as `box T`.

```ts
fn consume(value: box Image): Unit {
    ...
}

let img: box Image = box Image("input.png");
let stored: box Image;
stored <- img;
img.width(); // compile error: img was moved
```

Rules:

- `source` must be an ownership-checked value.
- `target` must be an assignable storage location.
- After `target <- source`, `source` enters the moved state.
- Reading, borrowing, assigning through, or dropping `source` after the move is a
  compile-time error unless it is reinitialized first.
- Moving from a borrowed value is not allowed.
- Plain `class` references are not ownership-checked; they use ordinary
  assignment and argument passing.
- Function calls that transfer ownership should use an explicit move assignment
  into a temporary or a call-site move form chosen later. The first design should
  avoid overloading ordinary argument passing with hidden ownership transfer.

Rationale: `target <- source` reads as "target takes from source" and keeps
movement as an operator-level action instead of a keyword. It also maps cleanly
to `target = std::move(source)` after semantic checks.

### Move Argument: `fn(<- source)`

`<- source` is allowed only in expression positions where there is an implicit
destination, such as a function argument. It transfers ownership into the
receiving parameter.

```ts
fn store(value: box Image): Unit {
    ...
}

let img: box Image = box Image("a.png");
store(<- img);
img.width(); // compile error: img was moved
```

Rules:

- `source` must be an ownership-checked value.
- The receiving parameter must be an owning parameter, not `&T` or `&mut T`.
- After `fn(<- source)`, `source` enters the moved state.
- `target <- source` remains the preferred spelling when an explicit
  destination exists.

Parser note: `<-` already exists in the current language for assignment-like
expressions and collection comprehensions such as `for (x <- xs)` and
`map(x <- xs)`. That is not a lexer problem because `<-` is already tokenized.
The parser can keep using the same token and let context decide:

- In statement/expression assignment position, `target <- source` is ownership
  transfer when `source` is non-copyable owned storage.
- In prefix argument position, `<- source` is ownership transfer into the
  receiving parameter.
- In comprehension headers, `<-` keeps its current generator meaning.
- If the old `<-` assignment semantics remain, ownership move should be a
  stricter subtype of that assignment, enforced by the type checker.

### Immutable Borrow: `&x`

`&x` creates a temporary non-owning immutable reference.

```ts
fn inspect(value: &Image): Int {
    return value.width();
}

let img: box Image = box Image("input.png");
let width = inspect(&img);
```

Rules:

- Multiple immutable borrows may coexist.
- The owner cannot be moved while immutable borrows are alive.
- Immutable borrows cannot call mutating methods.
- The compiler should prefer lexical lifetime checks first. More precise
  non-lexical lifetimes can be added later.

### Mutable Borrow: `&mut x`

`&mut x` creates an exclusive mutable borrow.

```ts
fn normalize(value: &mut Image): Unit {
    value.normalize();
}

let img: box Image = box Image("input.png");
normalize(&mut img);
```

Rules:

- Only one mutable borrow may exist at a time.
- No immutable borrow may overlap a mutable borrow.
- The owner cannot be read or moved while mutably borrowed.
- Mutable borrow syntax follows Rust's spelling with `mut`, while keeping `&`
  as the reference operator.

## Function Passing Defaults

Function calls should make ownership transfer explicit.

```ts
fn view(img: Image): Unit;         // plain reference
fn draw(img: &Image): Unit;        // borrow
fn update(img: &mut Image): Unit;  // mutable borrow
fn store(img: box Image): Unit;    // takes ownership

let refImg: Image = new Image("a.png");
let ownedImg: box Image = new Image("a.png");

view(refImg);
draw(&ownedImg);
update(&mut ownedImg);
store(<- ownedImg);
```

Passing `box T` to an owning parameter rejects implicit ownership transfer:

```ts
store(ownedImg); // compile error: ownership transfer must be explicit
```

This keeps ownership transfer visible at call sites.

## Raw Pointers

Raw pointers are non-owning and unsafe.

```ts
fn from_c(ptr: unsafe *Image): Int {
    unsafe {
        return (*ptr).width();
    }
}
```

Rules:

- `*T` without `unsafe` is invalid.
- `unsafe *T` may be passed to and from external C/C++ functions.
- Dereferencing `unsafe *T` requires an unsafe block or unsafe function.
- Raw pointer lifetime is not checked by the safe ownership system.
- Converting `&T` or `&mut T` to `unsafe *T` requires an unsafe operation.

## Implementation Plan

1. Extend the type system with ownership qualifiers:
   `Owned`, `BoxOwned`, `Borrow`, `MutableBorrow`, and `UnsafePointer`.
2. Parse `unsafe *T`, `box T`, `&T`, and `&mut T` as distinct type forms.
3. Parse `target <- source`, `<-expr`, `&expr`, and `&mut expr` as ownership
   operators.
4. Add moved-state tracking to local variables.
5. Reject use-after-move for non-copyable owned values.
6. Add a lexical borrow table per scope:
   immutable borrow count, mutable borrow flag, and moved flag.
7. Lower `box T` to `std::unique_ptr<T>` in C++ codegen.
8. Lower `target <- source` to `target = std::move(source)` and `<-source`
   arguments to `std::move(source)` only after semantic checks pass.
9. Require unsafe context for raw pointer dereference and raw pointer
   conversions.

## Initial Compiler Errors

Recommended diagnostics:

```text
ownership transfer requires '<-'
use of moved value 'img'
cannot move 'img' while it is borrowed
cannot mutably borrow 'img' while immutable borrow exists
expected mutable borrow syntax '&mut'
raw pointer type requires 'unsafe'
raw pointer dereference requires unsafe context
```

## Open Decisions

- Whether `box T` should be a keyword form or a standard generic type such as
  `Box<T>`.
- Whether copyable primitives should silently accept `target <- source` or warn
  that the move operator is unnecessary.
- Whether the first implementation should use only lexical borrow scopes or
  introduce non-lexical lifetime shortening immediately.
