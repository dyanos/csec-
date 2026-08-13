#include "../src/NativeRuntime.h"

#include <chrono>
#include <cstdio>
#include <cstdlib>
#include <cstring>
#include <functional>
#include <vector>

namespace {
using Clock = std::chrono::steady_clock;

long long elapsedMilliseconds(const std::function<void()>& work) {
    const auto start = Clock::now();
    work();
    return std::chrono::duration_cast<std::chrono::milliseconds>(Clock::now() - start).count();
}
}

int main() {
    char* semanticTrim = csec_string_trim("  Alpha  ");
    char* semanticUpper = csec_string_to_upper("aZ-9");
    char* semanticLower = csec_string_to_lower("Az-9");
    char* semanticInteger = csec_to_string_i64(-1234567890123456789LL);
    char* semanticDecimal = csec_to_string_double(1.5);
    const bool valid = csec_string_is_empty("") &&
        csec_string_contains("AlphaBeta", "haB") &&
        csec_string_starts_with("AlphaBeta", "Alpha") &&
        csec_string_ends_with("AlphaBeta", "Beta") &&
        csec_string_index_of("AlphaBeta", "haB") == 3 &&
        csec_string_char_at("Alpha", 4) == 'a' &&
        std::strcmp(semanticTrim, "Alpha") == 0 &&
        std::strcmp(semanticUpper, "AZ-9") == 0 &&
        std::strcmp(semanticLower, "az-9") == 0 &&
        std::strcmp(semanticInteger, "-1234567890123456789") == 0 &&
        std::strcmp(semanticDecimal, "1.500000") == 0;
    std::free(semanticTrim);
    std::free(semanticUpper);
    std::free(semanticLower);
    std::free(semanticInteger);
    std::free(semanticDecimal);
    if (!valid) {
        std::fputs("semantic_check=failed\n", stderr);
        return 1;
    }
    constexpr int kFragments = 64;
    constexpr int kFragmentBytes = 256;
    constexpr int kIterations = 4000;

    std::vector<std::vector<char>> storage(kFragments, std::vector<char>(kFragmentBytes + 1, 'x'));
    std::vector<const char*> fragments;
    fragments.reserve(kFragments);
    for (auto& fragment : storage) {
        fragment.back() = '\0';
        fragments.push_back(fragment.data());
    }

    volatile size_t checksum = 0;
    const auto chainedMs = elapsedMilliseconds([&] {
        for (int iteration = 0; iteration < kIterations; ++iteration) {
            char* value = static_cast<char*>(std::malloc(1));
            value[0] = '\0';
            for (const char* fragment : fragments) {
                char* next = csec_string_concat(value, fragment);
                std::free(value);
                value = next;
            }
            checksum += std::strlen(value);
            std::free(value);
        }
    });
    const auto batchedMs = elapsedMilliseconds([&] {
        for (int iteration = 0; iteration < kIterations; ++iteration) {
            char* value = csec_string_concat_many(fragments.data(), static_cast<long long>(fragments.size()));
            checksum += std::strlen(value);
            std::free(value);
        }
    });
    const char* text = "   AlphaBetaGammaDelta   ";
    constexpr int kOperationIterations = 1000000;
    const auto searchMs = elapsedMilliseconds([&] {
        for (int i = 0; i < kOperationIterations; ++i) {
            checksum += csec_string_contains(text, "Beta");
            checksum += csec_string_starts_with(text + 3, "Alpha");
            checksum += csec_string_ends_with(text, "   ");
            checksum += static_cast<size_t>(csec_string_char_at(text, 8));
        }
    });
    const auto transformMs = elapsedMilliseconds([&] {
        for (int i = 0; i < kOperationIterations; ++i) {
            char* trimmed = csec_string_trim(text);
            char* upper = csec_string_to_upper(trimmed);
            char* lower = csec_string_to_lower(upper);
            checksum += std::strlen(lower);
            std::free(trimmed);
            std::free(upper);
            std::free(lower);
        }
    });
    const auto formatMs = elapsedMilliseconds([&] {
        for (int i = 0; i < kOperationIterations; ++i) {
            char* integer = csec_to_string_i64(1234567890123456789LL);
            char* decimal = csec_to_string_double(1234.25);
            checksum += std::strlen(integer) + std::strlen(decimal);
            std::free(integer);
            std::free(decimal);
        }
    });

    std::printf("semantic_check=passed\n");
    std::printf("fragments=%d fragment_bytes=%d iterations=%d\n", kFragments, kFragmentBytes, kIterations);
    std::printf("binary_chain_ms=%lld\n", chainedMs);
    std::printf("batched_chain_ms=%lld\n", batchedMs);
    std::printf("speedup=%.2fx checksum=%zu\n",
        batchedMs > 0 ? static_cast<double>(chainedMs) / batchedMs : 0.0, checksum);
    std::printf("search_and_access_ms=%lld\n", searchMs);
    std::printf("trim_case_transform_ms=%lld\n", transformMs);
    std::printf("number_format_ms=%lld\n", formatMs);
    return 0;
}
