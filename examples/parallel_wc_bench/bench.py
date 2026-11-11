import os, statistics, subprocess, sys, time
here = os.path.dirname(os.path.abspath(__file__))
data = os.path.join(here, sys.argv[1] if len(sys.argv) > 1 else "data1g.txt")
wc = r"C:\Program Files\Git\usr\bin\wc.exe"
if not os.path.exists(wc):
    wc = "wc"
ref = os.path.join(here, "refwc.exe")
tess = os.path.join(here, "parallel_wc.exe")
native = os.path.join(here, "parallel_wc_native.exe")
cases = [
    ("GNU wc -l (1 thread)", [wc, "-l", data]),
    ("C++ reference (mmap, -march=native), 1 thread", [ref, data, "1"]),
    ("C++ reference (mmap, -march=native), 16 threads", [ref, data, "16"]),
    ("Tessera mmap, portable, 1 thread", [tess, data, "1"]),
    ("Tessera mmap, portable, 16 threads", [tess, data, "16"]),
    ("Tessera mmap, -march=native, 1 thread", [native, data, "1"]),
    ("Tessera mmap, -march=native, 4 threads", [native, data, "4"]),
    ("Tessera mmap, -march=native, 8 threads", [native, data, "8"]),
    ("Tessera mmap, -march=native, 16 threads", [native, data, "16"]),
    ("Tessera chunked read, -march=native, 16 thr", [native, data, "16", "4194304"]),
]
runs = int(os.environ.get("RUNS", "9"))
size = os.path.getsize(data)
with open(data, "rb") as f:   # warm the OS file cache
    while f.read(1 << 24):
        pass
results = []
for name, cmd in cases:
    out = subprocess.run(cmd, capture_output=True, text=True, cwd=here).stdout.strip()
    lines = out.split()[0] if out else "?"
    times = []
    for _ in range(runs):
        t0 = time.perf_counter()
        subprocess.run(cmd, capture_output=True, cwd=here)
        times.append(time.perf_counter() - t0)
    results.append((name, lines, min(times), statistics.median(times)))
fastest = min(r[2] for r in results)
print(f"file: {os.path.basename(data)} ({size / (1 << 20):.0f} MiB), {runs} runs each, warm page cache, process wall time")
print(f"{'tool':48} {'lines':>10} {'best s':>7} {'median':>7} {'GiB/s':>6} {'vs fastest':>10}")
for name, lines, best, med in results:
    print(f"{name:48} {lines:>10} {best:7.3f} {med:7.3f} {size / (1 << 30) / best:6.2f} {fastest / best * 100:9.1f}%")
