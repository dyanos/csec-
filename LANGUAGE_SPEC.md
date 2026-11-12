# Tessera Language Specification — Concurrency and Standard Library

This document records accepted syntax and semantics that both the native compiler
(`src/`) and the self-hosted compiler (`selfhost/`) implement. The broader surface
syntax is described in `docs/syntax.md` and `docs/grammar.md`.

## 1. Library imports and intrinsics

### 1.1 Import resolution

```
import a.b.c
import "relative/path.csec"
```

`import` textually includes a source file once (cycles and repeats are ignored). A
target is resolved in this order; the first existing file wins:

1. relative to the importing file, then the working directory (`a.b.c` as given, then
   as `a/b/c.csec`);
2. the **standard-library roots**, as `<root>/a/b/c.csec`:
   1. directories passed with `--lib-path <dir>` (native compiler);
   2. entries of the `CSEC_LIB_PATH` environment variable (`;`-separated on Windows,
      `:` elsewhere);
   3. `lib/` next to the runtime library (`System.Native.dll`), and `lib/` in up to two
      parent directories of it (so a build in `x64/Debug` finds the repository `lib/`).

An import that resolves to no file is left in place and ignored, as before.

Both compilers share one implementation of this lookup (`csecFindLibraryModule` in
`src/native_runtime/runtime_services.inc`).

### 1.2 Intrinsics

The compiler has built-in lowerings for some operations that cannot be written in the
language itself (they take closures, or need code generation). They are **off by
default**. A library module enables one by declaring it with the `Intrinsic` attribute:

```
[@Intrinsic] external def spawn(body: () => Int): Int;
```

The declaration emits no code; it only makes the name available, with the compiler's
built-in meaning, to the program that imports the module. So the compiler author
decides, module by module, which intrinsics an `import` exposes. Calling an intrinsic
name that no imported module declared is an ordinary unresolved call (an error).

| Intrinsic | Declared by |
| --- | --- |
| `spawn self send receive receiveTimeout yield isAlive monitor mailboxSize processCount joinProcesses` | `std.microthread` |
| `threadStart` | `std.thread` |

### 1.3 Standard library modules (`lib/std`)

| Module | Contents |
| --- | --- |
| `std.microthread` | Erlang-style processes (§2) |
| `std.thread` | OS threads, mutexes, atomics, channels |
| `std.process` | running OS processes (`runCommand`, `commandOutput`, `startProcess`, `waitProcess`, ...) |
| `std.math.natural` | `Nat` division/modulo/power/gcd/lcm/isqrt, primality, factorial, binomial, Fibonacci |
| `std.math.real` | constants and real-number helpers |
| `std.math.complex` | complex numbers: `imaginaryUnit()`, `conj`, `cabs`, `carg`, `cexp`, `clog`, `csqrt`, `cpow`, ... |
| `std.symbolic` | symbolic algebra: parse, simplify, expand, diff, integrate, subst, solve, evaluate, print |
| `std.pipe` | byte/line pipes between threads and microthreads; child processes with piped stdin/stdout (§6) |
| `std.shared` | shared memory: private (threads/microthreads) or named (across OS processes) (§6) |
| `std.mail` | named mailboxes with mail senders and receivers, across threads, microthreads, and processes (§6) |
| `std.io` | chunked binary file reads, memory-mapped files, `parseInt`/`parseLong` (§7) |

## 2. Microthreads (`import std.microthread`)

A *process* is a lightweight user-mode thread with its own stack and a private FIFO
mailbox of `Int` messages. Processes share nothing.

```
val pid = spawn([=]() -> { val n = receive(); send(parent, n * 2); return 0; });
```

- `spawn(f)`: `f` must be a zero-parameter lambda **literal** capturing by value (`[=]`
  or an explicit capture list), or the name of a zero-parameter function. `[&]`
  lambdas, lambdas with parameters, and closure-valued variables are compile errors.
  The lambda's captured values are copied into the new process at spawn time.
- Scheduling is cooperative and M:1 per OS thread. Processes run in FIFO order and
  switch only at `receive`/`receiveTimeout` with an empty mailbox, `await` of an
  unfinished future, `yield`, `joinProcesses`, and process exit.
- `main` is pid 1. When `main` returns the program ends; `joinProcesses()` first runs
  the other processes until none can make progress.
- If every process is blocked in `receive`/`await` and no timeout is pending, the
  runtime prints a deadlock diagnostic and exits with status 70.
- Besides `Int` messages each process has a FIFO mailbox of strings:
  `sendText(pid, text)`, `receiveText()`, `receiveTextTimeout(ms, fallback)`,
  `textMailboxSize()`. The text is copied to the receiver.

## 3. Asynchronous execution: `go`, `async`, `await`

```
PrefixExpression ::= 'go' CallExpression
                   | 'async' CallExpression
                   | 'await' PrefixExpression
```

`go` is a reserved keyword. `async` keeps its meaning as a declaration modifier when it
is directly followed by `def` (or `unsafe def`); anywhere else it starts an `async`
expression.

- `go f(a, b)` evaluates the arguments in the caller, starts the call in a new
  microthread, discards its result, and yields the new process id (`Int`).
- `async f(a, b)` does the same but yields a `Future<T>`, where `T` is the call's type.
- `await e`:
  - if `e : Future<T>`, blocks the current microthread until the task has finished and
    yields its `T` result (awaiting a future again returns the same value);
  - otherwise `e` must appear inside an `async def`, and the value is yielded unchanged
    (an `async def` still runs synchronously when called directly).
- The operand of `go`/`async` must be a call of a named function. Arguments may not be
  borrows (`&x`, `&mut x`): the task can outlive them.
- `await` keeps the ownership rule that no borrow may be live across it.
- Supported result types for `Future<T>`: integers, `Boolean`, `Double`, `Float`,
  `String`, and other pointer-represented values.
- `go`/`async`/`await` need no import; they use the same runtime scheduler as
  `std.microthread`.

## 4. Built-in number aggregates

`Complex { re: Double, im: Double }`, `Rational { numerator: Long, denominator: Long }`
and `Quaternion { w, x, y, z: Double }` are built-in **value** types (copied like
`struct`s; no `<-` needed):

- construction: `new Complex(re, im)`, `new Rational(n, d)`, `new Quaternion(w, x, y, z)`;
- fields are read with `.re`, `.im`, etc. on any expression (`conj(z).im`);
- `+ - * /` between two values of the same type (no `/` for `Quaternion`).

## 6. Communication between threads, microthreads, and processes

| Mechanism | Module | Threads | Microthreads | OS processes |
| --- | --- | --- | --- | --- |
| Int / text messages | `std.microthread` | — (one scheduler per thread) | yes | — |
| Channels (Long) | `std.thread` | yes | yes | — |
| Pipes | `std.pipe` | yes | yes | child stdin/stdout (`pipeOpenProcess`) |
| Shared memory | `std.shared` | yes | yes | named regions (`sharedOpen`) |
| Mail | `std.mail` | yes | yes | yes (named mailboxes) |

**Cooperative blocking.** Every blocking operation of `std.pipe`, `std.shared`
(`sharedLock`), `std.mail`, and `std.thread` (`mutexLock`, `channelReceive`,
`channelReceiveTimeout`, `threadJoin`) yields to the other runnable microthreads of its
OS thread while it waits, and sleeps when there are none. So a microthread waiting
on a pipe or for mail never stalls the rest of its thread, and microthread stages can be
chained into a pipeline with pipes.

**Pipes.** `pipeNew()` creates an in-process byte pipe. `pipeWrite`/`pipeWriteLine`
append; `pipeRead(max)`/`pipeReadLine()` wait for data; `pipeClose` ends the input, after
which readers drain what remains and then see end of input (`pipeAtEnd`).
`pipeOpenProcess(command)` starts a shell command whose stdin and stdout are connected to
the caller: `processWrite[Line]`, `processCloseInput`, `processReadLine`,
`processReadAll`, `processFinish` (waits; returns the exit code).

**Shared memory.** `sharedNew(bytes)` is private to the program; `sharedOpen(name,
bytes)` names a region shared by every process of the user session that opens the name.
The first opener creates it zero-filled. Memory is addressed as `Long`/`Double` slots
(`index * 8` bytes), bytes, or NUL-terminated strings at a byte offset. Out-of-range
accesses read 0 and are ignored. `sharedAddLong` and `sharedCompareExchange` are atomic.
`sharedLock`/`sharedUnlock` is a region-wide lock that also works across processes.

**Mail.** A mailbox is identified by name. `mailSender(mailbox, senderName)` and
`mailReceiver(mailbox)` open endpoints, from any thread, microthread, or process.
`mailSend[Tagged]` queues a string (with an optional `Long` tag). `mailReceive`,
`mailReceiveTimeout`, and `mailPoll` take the oldest message. `mailLastSender` and
`mailLastTag` describe the message last received through that endpoint. Messages are
copied and delivered FIFO. A mailbox holds about 1 MiB of queued mail, and a send to a
full mailbox returns `false`.

**Threads, mutexes, and channels.** `threadStart(body)` runs `body` on a new OS thread and
`threadJoin` returns its result. A thread that is never joined is abandoned when `main`
returns, and the program still exits normally. Mutexes are not recursive. Microthreads may
contend for one, and `mutexUnlock` on a mutex that is not locked returns `false`.
Channels are unbounded FIFO queues of `Long`. `channelSend` returns `false` once the channel is
closed. `channelReceive(ch, fallback)` returns `fallback` when the channel is closed and empty,
and `channelReceiveTimeout(ch, ms, fallback)` also returns it after `ms` milliseconds with no
value. `channelClosed` reports whether the channel is closed, and `channelFree` closes it and
releases the handle.

## 7. String bytes and file input

**`text[i]`.** Indexing a `String` with one integer (`Int` or `Long`) yields byte `i` as a `Char`.
It compiles to a single load, with no call and no scan, so byte loops optimise like C loops (and
are vectorised at `-O2`/`-O3`). Valid indices are `0 <= i <= text.length`, where index
`text.length` is the terminating NUL. As with C strings, other indices are out of bounds and are not
checked. Slices of strings are not supported. (`text.charAt(i)` remains available; it is bounds
safe but scans from the start, i.e. O(i).)

**`std.io`.**
- `openRead(path)`, `seekTo(file, offset)`, `readChunk(file, maxBytes)`, and `lastReadCount(file)`
  read a file in binary mode in chunks. The byte count is reported separately, so data containing
  NUL bytes is exact. Each chunk is a fresh allocation; free it with `releaseChunk`.
- `mapFile(path)` maps a whole file read-only. `mappedBytes(m)` is a view for `view[i]`,
  `0 <= i < mappedSize(m)` (use a `Long` index beyond 2 GiB). It is not NUL-terminated and stays
  valid until `unmapFile(m)`. One mapping can be scanned by several threads.
- `fileSize(path)`, `parseInt(text, fallback)`, `parseLong(text, fallback)`.

**Target.** The native compiler gives every module the host's target triple and data layout before
code generation. The default CPU is the portable baseline (SSE2 on x86-64); `-march=native` targets
the build machine's CPU (e.g. AVX2/AVX-512).

`examples/parallel_wc.csec` is a parallel `wc -l` built from these pieces.

## 5. Self-hosted compiler support

The self-hosted compiler (`selfhost/`, whose emitter lives in `src/native_runtime/*.inc`) implements:

- the standard-library search path (§1.1) — it shares the runtime's import resolver;
- `[@...]` attributes as their own top-level declarations, and `[@Intrinsic]` declarations,
  which emit no `declare` and enable the intrinsic lowering (§1.2);
- all `std.microthread` intrinsics and `threadStart`;
- `go`, `async`, and `await` (§3), including `async def` as a declaration modifier, with
  futures of `Int`, `Long`, `Boolean`, `Double`, and pointer-represented results;
- `text[i]` on String locals and parameters, and escaped `Char` literals (`'\n'`, `'\t'`, ...);
- calls through `std.io`, `std.thread`, `std.process`, `std.pipe`, `std.shared`, `std.mail`,
  `std.math.natural`, `std.math.real`, and `std.symbolic`, which are ordinary functions
  over `external def` runtime entry points. `external def` declarations are emitted with
  their declared signature, and calls to them pass arguments of the declared types.

Narrower than the native compiler:

- `spawn`, `threadStart`, `go`, and `async` take **named functions** only; lambda
  literals are native-only.
- The value aggregates of §4 (`Complex`, `Rational`, `Quaternion`) and therefore
  `std.math.complex` are native-only, because the self-host has no aggregate value
  types.
- The self-host does not type-check: the share-nothing and borrow rules of §2–§3 are
  enforced by the native compiler only.

`tests/run_selfhost_concurrency.ps1` runs every fixture in `tests/selfhost_concurrency`
through both compilers and requires the same exit code (42) from each.
