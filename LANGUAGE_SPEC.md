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

**Aliases.** `import a.b.c = name;` (also `import "path.csec" = name;`) imports the module as
usual and also gives it a local name:

```
import std.dataframe = df;

def main(): Int {
    val t = df.readParquet("sales.parquet");   // same as readParquet(...)
    return 0;
}
```

- In the importing file, `name.f` refers to `f` when `f` is a top-level function (`def` or
  `external def`, intrinsics included) of the aliased module. The module's names also stay
  available unqualified, since imports are textual.
- `name.x`, where `x` is not a function of the module, is left alone. So a variable that shares
  the alias name keeps its members (`val df = "abc"; df.length`).
- Aliases are per file. They are not applied inside comments or string literals, and they do
  not reach the files that the module itself imports.
- It is an error to alias a module that cannot be found, to use one alias for two modules, or
  to use an alias that is not an identifier.

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
| `std.dataframe` | Polars-style DataFrame / LazyFrame / expressions; Parquet and CSV (§8) |
| `std.process` | running OS processes (`runCommand`, `commandOutput`, `startProcess`, `waitProcess`, ...) |
| `std.math.natural` | `Nat` division/modulo/power/gcd/lcm/isqrt, primality, factorial, binomial, Fibonacci |
| `std.math.real` | constants and real-number helpers |
| `std.math.complex` | complex numbers: `imaginaryUnit()`, `conj`, `cabs`, `carg`, `cexp`, `clog`, `csqrt`, `cpow`, ... |
| `std.symbolic` | symbolic algebra: parse, simplify, expand, diff, integrate, subst, solve, evaluate, print |
| `std.pipe` | byte/line pipes between threads and microthreads; child processes with piped stdin/stdout (§6) |
| `std.shared` | shared memory: private (threads/microthreads) or named (across OS processes) (§6) |
| `std.mail` | named mailboxes with mail senders and receivers, across threads, microthreads, and processes (§6) |
| `std.io` | chunked binary file reads, memory-mapped files, `parseInt`/`parseLong` (§7) |
| `std.json` | JSON documents: parse, path queries, build, print (§9) |
| `std.net` | plain TCP sockets (§9) |
| `std.http` | HTTP(S) client, streamed bodies and Server-Sent Events, URL and HTML helpers (§9) |
| `std.openai` | client for OpenAI-compatible APIs: chat, streaming, tool calls, embeddings, models (§9) |

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

## 8. Data frames and Parquet (`import std.dataframe`)

`std.dataframe` is modelled on [Polars](https://pola.rs): eager `DataFrame`s, lazy `LazyFrame`
queries, and composable expressions. Columns have the dtypes `i64`, `f64`, `str`, and `bool`, and
any cell may be null.

```csec
import std.dataframe = pl;

def main(): Int {
    val sales = pl.readParquet("sales.parquet");
    val top = sales
        .filter((pl.col("amount") > 100) & pl.col("region").isNotNull())
        .withColumns((pl.col("qty") * pl.col("price")).alias("total"))
        .groupBy("region")
        .agg(pl.col("total").sum(), pl.col("amount").mean().alias("avg"), pl.len())
        .sort("total", true);
    println(top.toString());

    // Lazy: optimized, then run by collect().
    val q = pl.scanParquet("sales.parquet")
        .filter(pl.col("region") == "east")
        .select(pl.col("amount"), pl.col("qty"))
        .head(10);
    println(q.explain());
    val firstTen = q.collect();
    return 0;
}
```

**Expressions** (`Expr`). They are built with `col(name)`, `all()`, `lit(value)`, `len()`, and
`when(cond).then(a).otherwise(b)`.
- Arithmetic is `+ - * / %`. `/` always gives `f64`, `%` follows the divisor's sign, and `+` on two
  strings concatenates them.
- Comparisons are `== != < <= > >=`. A comparison operand may be another expression or a
  `Long`, `Double`, `String`, or `Boolean`.
- Logic is `&`, `|`, `.and()`, `.or()`, `.not()`, with Kleene nulls (false & null = false, true | null = true).
- Null handling is `isNull`, `isNotNull`, and `fillNull`.
- Math functions are `abs`, `sqrt`, `exp`, `log`, `floor`, `ceil`, `round(n)`, and `neg`.
- Other functions are `cast("i64" | "f64" | "str" | "bool")`, `isBetween(lo, hi)`, and `alias(name)`.
- String functions go through `.str()`: `contains`, `startsWith`, and `endsWith` (all literal
  matches), `lenChars`, `lenBytes`, `toUppercase`, `toLowercase`, `stripChars`, `replace`, and
  `replaceAll`.
- Aggregations are `sum`, `mean`, `min`, `max`, `count` (non-null cells), `std`, `var` (ddof 1),
  `median`, `first`, `last`, `nUnique`, and `nullCount`. In a select an aggregation is a scalar that
  broadcasts; inside `agg()` it is computed per group. `expr.over("k")` computes it per group of `k`
  and keeps one value per row (a window function).
- An output column is named after the expression's leftmost input column (`literal` for a literal,
  `len` for `len()`), or after its `alias`.

**DataFrame.**
- Shape: `height`, `width`, `shape`, `columnName(i)`, `dtype(name)`, and `schema`.
- Columns: `select(...)` (expressions, or `"a,b"`), `withColumns(...)`, `withColumn`, `drop`,
  `rename("old=new,...")`, and `withRowIndex`.
- Rows: `filter`, `head`, `tail`, `slice`, `limit`, `unique([subset])`, and `dropNulls([subset])`.
- `sort(by[, descending[, nullsLast]])` sorts by `"a,-b"` or by an expression. The sort is stable,
  and nulls come first by default, as in Polars.
- `groupBy(keys).agg(...)` (or `.len()`) keeps the groups in order of first appearance.
- `join(other, on[, how[, suffix]])` takes `on` as `"k"`, `"a,b"`, or `"l=r"`. `how` is `inner`,
  `left`, `full`, `semi`, `anti`, or `cross`.
- Summaries: `vstack`, `describe`, `nullCount`, `sum`, `mean`, `min`, `max`, `std`, and `median`.
- Cells: `getLong`, `getDouble`, `getString`, `isNull`, and `itemLong`/`itemDouble`/`itemString`.
- Output: `toString([maxRows])` gives a Polars-style table (UTF-8 box drawing, or ASCII through
  `setTableFormat("ascii")`; on a Windows console that is not in UTF-8 mode the default is ASCII).
  `writeParquet`, `writeCsv`, and `toCsv` write the frame out.
- `lazy()` turns the frame into a `LazyFrame`.

**LazyFrame.**
- Building: `scanParquet(path)`, `scanCsv(path)`, or `df.lazy()`, then the same operations as a
  DataFrame. `collect()` runs the query, `explain()` shows the optimized plan (`explain(false)`
  the plan as written), and `columns()` lists the output columns.
- Predicate pushdown: filters move below sorts, `withColumns` (when they do not read the new
  columns), group keys, and the left side of joins, down into the scan. At the scan, Parquet
  row-group min/max statistics skip row groups the filter cannot match.
- Projection pushdown: a scan reads only the columns the query uses, and unused `withColumns`
  outputs are dropped.
- Limit pushdown: `head(n)` over a scan stops reading row groups once it has `n` rows.
- `lastScanInfo()` reports what the last scan read (`row_groups=1/3 columns=2/6`).

**Input and output.** `readParquet(path[, "a,b"])`, `readCsv(path)`, `readCsvString(text)`,
`scanParquet`, `scanCsv`, and `concat(a, b)`.
- Parquet: the reader handles flat schemas, data pages v1 and v2, and the PLAIN, dictionary, RLE,
  DELTA_*, and BYTE_STREAM_SPLIT encodings.
- Compression: UNCOMPRESSED, SNAPPY, GZIP, and LZ4_RAW are built in. ZSTD, which Polars writes by
  default, needs a runtime built with libzstd (`dfZstdSupported()`; CMake `CSEC_WITH_ZSTD`, AUTO
  by default).
- Types: booleans become `bool`; integers, DATE (days), TIMESTAMP (the file's unit), and INT96
  (nanoseconds) become `i64`; floats and DECIMAL become `f64`; byte arrays become `str`. Nested and
  repeated columns are rejected; read the flat ones by name.
- Parallelism: columns are decoded in parallel, and `take`-style operations (filter, sort, join)
  gather columns in parallel.
- `writeParquet` writes uncompressed PLAIN files.

**Errors.** Like a Polars exception, a failing operation prints `DataFrame error: ...` and exits
with status 1. After `setRaiseErrors(false)` it instead returns an invalid frame (`isValid()` is
false) and `dfLastError()` explains why.

**Values, not owners.** `DataFrame`, `LazyFrame`, `Expr`, and the other API types are value structs
around runtime handles, so they copy freely without `<-`. A method takes up to six expressions per
call; chain `withColumns`/`select` calls for more.

**Procedural API.** The earlier handle-based functions remain for existing code: `dfFilter`,
`dfSort`, `dfGroupBy("k", "col:fn,...")`, `dfJoin`, `dfCompute`, `dfGetLong`, and the rest. Their
input and output functions are `dfReadParquet`, `dfReadParquetColumns`, `dfWriteParquet`,
`dfReadCsv`, `dfFromCsv`, `dfWriteCsv`, and `dfToCsv`. Before the Polars-style API these were named
`readParquet`, `readCsv`, ...; those names now return `DataFrame`s.

## 9. JSON, HTTP, and OpenAI-compatible clients

**`std.json`.** `parseJson(text)`, `jsonObject()`, `jsonArray()` return a `Json` handle.
Values are addressed by path: `""` is the root, `a.b` a member, `a[0]` an element, `a[-1]`
the last element, `a["x.y"]` a member with dots in its name (`jsonKey(name)` builds that
step for any string), and `a[]` (setters only) appends. Setters (`set`, `setNull`,
`setObject`, `setArray`, `setJson`, `push`) create missing containers and return the
document, so they chain. `get(path)` is a view that shares the subtree, `copy(path)` an
independent copy. Numbers keep their source text, so 64-bit integers round-trip exactly.
A failed parse gives a `Json` with `isValid()` false; `jsonLastError()` explains it.

**`std.net`.** Blocking TCP sockets for text data: `tcpListen`, `tcpAccept`, `tcpConnect`,
`tcpSend`, `tcpReceive`, `tcpClose` (handles are -1 on failure; run servers on a `std.thread`).

**`std.http`.** `httpRequest(method, url)` builds a request (`header`, `bearer`, `body`,
`json`, `timeout`); `send()` waits for the whole response, `open()` returns once the headers
are in so the body can be read with `nextLine()/line()` or as Server-Sent Events with
`nextEvent()/eventData()`. Shortcuts: `httpGet`, `httpPost`, `httpPostJson`, `fetchText`,
`fetchJson`, `fetchPageText`, `download`. A transport failure gives `status() == 0` and an
`error()` message; `ok()` means a 2xx status. HTTPS uses WinHTTP on Windows and libcurl
(loaded at run time) elsewhere; redirects and gzip/deflate are handled. Requests run on a
worker OS thread and the caller waits cooperatively, so microthreads can have many requests
in flight at once. Crawler helpers: `htmlTitle`, `htmlToText`, `htmlLinks(html, base)`,
`urlResolve`, `urlEncode`, `urlDecode`, `urlHost`, `sameHost`.

**`std.openai`.** `openai(baseUrl, apiKey, model)` or `openaiFromEnv()` (`OPENAI_BASE_URL`,
`OPENAI_API_KEY`, `OPENAI_MODEL`) give a client for any server implementing the OpenAI REST
API (OpenAI, Azure via `header`, Ollama, LM Studio, vLLM, llama.cpp, OpenRouter, ...).
`newChat().system(..).user(..).temperature(..)` builds a conversation; `ai.complete(chat)`
returns a `ChatResult` (`ok`, `error`, `status`, `text`, `finishReason`, token usage, tool
calls), `ai.stream(chat)` a `ChatStream` read with `next()/delta()`. Tool calling:
`chat.tool(name, description, jsonSchema)`; when `result.toolCallCount() > 0`, add
`chat.assistant(result)`, then `chat.toolResult(result.toolCallId(i), output)` per call, and
complete again. Also `ask`, `embeddings`, `models`, and raw `postJson`/`getJson`.

Examples: `examples/web_fetch.csec`, `examples/web_crawler.csec`,
`examples/openai_chat.csec`, `examples/openai_web_agent.csec`.

## 10. Dictionaries and declaration type inference

### 10.1 Declaration type inference

In `val name = expr` and `var name = expr` (also `constexpr val`), the annotation may be
omitted when the type of `expr` is known; the variable or constant then has that type. This
applies to locals, module-level globals, and class fields (`var total = 0`). Literals give
`Int` (or `Long` when the value does not fit 32 bits), `Float` for a plain decimal literal,
`String`, `Char`, and `Bool`; calls give the callee's declared return type; operators give
their result type (a comparison or `and`/`or` is always `Bool`, also when the operands are a
mix of `Int` and `Long`; a bitwise operator on mixed integer widths gives the wider type); a
dictionary literal gives its `Dict<K, V>` (§10.2), and `d[k]` gives `V`. An explicit annotation
always wins and the initializer is converted to it (`val wide: Long = 1`). An annotation is
required when the initializer has no type to infer, for example an empty `{}`.

### 10.2 Dictionary literals and `Dict<K, V>`

```
dict-lit = '{' [ expr ':' expr { ',' expr ':' expr } [ ',' ] ] '}' ;
type     = ... | 'Dict' '<' type ',' type '>' ;
```

```csec
val ages = {"alice": 30, "bob": 25};                  // Dict<String, Int>
val scores = {"math": [90, 85, 77], "art": [60, 70]}; // Dict<String, Vector[Int]>
val points = {"p": {"x": 1.5, "y": 2.0}};             // Dict<String, Dict<String, Float>>
var counts: Dict<String, Long> = {};
```

- **Parsing.** A `{` in expression position is a dictionary literal when its first top-level item
  is `key: value`, or when it is an empty `{}` used as a value (after `=`, `(`, `,`, `:`, `[`,
  `<-`, `return`); otherwise it is a block. `>>` closing nested type arguments is split into two
  `>`.
- **Typing.** `K` is the common type of the keys and `V` the common type of the values. Integer
  types widen to the wider one, integers mixed with `Float`/`Double` give the floating-point type,
  list literals give `Vector[T]` (whatever their lengths), and nested dictionaries unify
  entry-wise. Other types, class types included, must match exactly (there is no implicit upcast),
  so `{"a": 1, "b": "x"}` is a type error. When the literal initializes a declaration annotated `Dict<K, V>` (or is assigned to a
  `Dict` variable or dictionary element), that type is used and each entry must convert to it.
  `K` must be `Int`, `Long`, `Short`, `Byte`, `Char`, `Bool`, or `String`; `V` may be any type
  that is a scalar or a reference (not a value struct or tuple).
- **Semantics.** A dictionary is a reference value backed by the runtime (`dict_runtime.inc`):
  assignment and argument passing share it, `copy()` makes an independent shallow copy. Entries
  keep insertion order. String keys are compared by content (the dictionary keeps its own copy of
  the key text). List literal values are copied to the heap, so they outlive the function that
  built the dictionary.
- **Operations.** `d[k]` reads (a missing key prints `KeyError: <key>` and exits with status 1);
  `d[k] = v` inserts or replaces; `d[k] op= v` is `d[k] = d[k] op v`; `k in d` / `k notin d`.
  Methods: `size()`/`length()`/`count()` (`Long`), `isEmpty()`, `contains(k)`/`has(k)`/
  `containsKey(k)`, `get(k)`, `get(k, default)`, `remove(k)` (`Bool`: whether it was present),
  `keyAt(i)`, `valueAt(i)`, `copy()`, `clear()`, `toString()`. `print`/`println` and string
  concatenation render a dictionary like Python: `{'a': 1, 'b': [2, 3]}`.
- **Iteration.** `for (k <- d) { ... }` visits the keys in insertion order; `for (k, v <- d)` also
  binds each value.

## 5. Self-hosted compiler support

The self-hosted compiler (`selfhost/`, whose emitter lives in `src/native_runtime/*.inc`) implements:

- the standard-library search path (§1.1) — it shares the runtime's import resolver;
- `[@...]` attributes as their own top-level declarations, and `[@Intrinsic]` declarations,
  which emit no `declare` and enable the intrinsic lowering (§1.2);
- all `std.microthread` intrinsics and `threadStart`;
- `go`, `async`, and `await` (§3), including `async def` as a declaration modifier, with
  futures of `Int`, `Long`, `Boolean`, `Double`, and pointer-represented results;
- `text[i]` on String locals and parameters, and escaped `Char` literals (`'\n'`, `'\t'`, ...);
- dictionaries (§10.2) with scalar keys and values (`Int`, `Long`, `Short`, `Byte`, `Double`,
  `Float`, `Boolean`, `Char`, `String`): literals, `val d: Dict<K, V> = {}`, `d[k]`,
  `d[k] = v`, `d[k] op= v`, `get`, `size`, `isEmpty`, `contains`, `remove`, `clear`, `Dict`
  parameters and return types, and local type inference from `d[k]`/`d.get(..)`/`d.size()`;
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
- Dictionary values that are lists or nested dictionaries, `for` over a dictionary, `k in d`,
  `keyAt`/`valueAt`/`copy`/`toString`, printing a dictionary, and calling a method on a
  dictionary read in one expression (`d[k].length()`; bind `d[k]` to a local first) are
  native-only.

`tests/run_selfhost_concurrency.ps1` runs every fixture in `tests/selfhost_concurrency`
through both compilers and requires the same exit code (42) from each.
