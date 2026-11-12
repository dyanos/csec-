// Reference "as fast as practical" line counter: memory-mapped file, N threads, vectorised counting.
// Build: clang++ -O3 -march=native -std=c++17 refwc.cpp -o refwc.exe
#include <windows.h>
#include <algorithm>
#include <cstdio>
#include <cstdlib>
#include <thread>
#include <vector>

int main(int argc, char** argv) {
    if (argc < 2) { std::fprintf(stderr, "usage: refwc <file> [threads]\n"); return 2; }
    unsigned threads = argc > 2 ? static_cast<unsigned>(std::atoi(argv[2])) : std::thread::hardware_concurrency();
    if (threads == 0) threads = 1;
    HANDLE file = CreateFileA(argv[1], GENERIC_READ, FILE_SHARE_READ, nullptr, OPEN_EXISTING, FILE_FLAG_SEQUENTIAL_SCAN, nullptr);
    if (file == INVALID_HANDLE_VALUE) return 1;
    LARGE_INTEGER size{};
    GetFileSizeEx(file, &size);
    HANDLE mapping = CreateFileMappingA(file, nullptr, PAGE_READONLY, 0, 0, nullptr);
    const unsigned char* base = static_cast<const unsigned char*>(MapViewOfFile(mapping, FILE_MAP_READ, 0, 0, 0));
    const unsigned long long n = static_cast<unsigned long long>(size.QuadPart);
    std::vector<unsigned long long> counts(threads, 0);
    std::vector<std::thread> workers;
    for (unsigned t = 0; t < threads; ++t) {
        workers.emplace_back([&, t] {
            const unsigned long long begin = n * t / threads, end = n * (t + 1) / threads;
            unsigned long long c = 0;
            const unsigned char* p = base + begin;
            const unsigned char* e = base + end;
            // Byte-compare loop; clang -O3 vectorises this (AVX2: 32 bytes per compare).
            for (; p < e; ++p) c += (*p == '\n');
            counts[t] = c;
        });
    }
    for (auto& w : workers) w.join();
    unsigned long long total = 0;
    for (auto c : counts) total += c;
    std::printf("%llu %s\n", total, argv[1]);
    UnmapViewOfFile(base);
    CloseHandle(mapping);
    CloseHandle(file);
    return 0;
}
