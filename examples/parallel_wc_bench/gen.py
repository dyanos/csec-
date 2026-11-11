# Generate a ~1 GiB text file of variable-length lines (deterministic).
import random, sys
random.seed(1234)
path = sys.argv[1]
target = int(sys.argv[2]) if len(sys.argv) > 2 else (1 << 30)
words = ["alpha", "beta", "gamma", "delta", "epsilon", "lorem", "ipsum", "dolor", "sit", "amet",
         "tessera", "parallel", "count", "line", "buffer", "thread", "micro", "chunk", "x", "0123456789"]
lines = []
size = 0
while size < (1 << 20):
    n = random.randint(0, 18)
    line = " ".join(random.choice(words) for _ in range(n)) + "\n"
    lines.append(line)
    size += len(line)
block = "".join(lines).encode()
with open(path, "wb") as f:
    written = 0
    while written + len(block) <= target:
        f.write(block)
        written += len(block)
    f.write(block[: target - written])
print(path, target, "bytes; block newlines:", block.count(b"\n"))
