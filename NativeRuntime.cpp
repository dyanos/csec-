#include "NativeRuntime.h"

#include <cmath>
#include <cstdio>
#include <cstdlib>
#include <cstring>
#include <ctime>
#include <thread>
#include <vector>

#ifdef _WIN32
#define WIN32_LEAN_AND_MEAN
#include <direct.h>
#include <fcntl.h>
#include <io.h>
#include <sys/stat.h>
#include <winsock2.h>
#include <ws2tcpip.h>
#include <windows.h>
#pragma comment(lib, "ws2_32.lib")
#else
#include <cerrno>
#include <fcntl.h>
#include <netdb.h>
#include <netinet/in.h>
#include <sys/socket.h>
#include <sys/stat.h>
#include <sys/types.h>
#include <unistd.h>
#endif

namespace {
int& configuredParallelThreads() {
    static int value = []() {
        unsigned int hardware = std::thread::hardware_concurrency();
        return hardware == 0 ? 1 : static_cast<int>(hardware);
    }();
    return value;
}

void setConfiguredParallelThreads(int count) {
    if (count < 1) count = 1;
    configuredParallelThreads() = count;
}

#ifdef _WIN32
bool ensureSocketRuntime() {
    static bool initialized = []() {
        WSADATA data;
        return WSAStartup(MAKEWORD(2, 2), &data) == 0;
    }();
    return initialized;
}

void closeSocketHandle(SOCKET socketHandle) {
    closesocket(socketHandle);
}
#else
using NativeSocket = int;
constexpr NativeSocket INVALID_SOCKET_HANDLE = -1;

void closeSocketHandle(NativeSocket socketHandle) {
    close(socketHandle);
}
#endif
}

extern "C" {

void csec_print_string(const char* value) {
    std::printf("%s", value ? value : "");
}

void csec_print_i64(long long value) {
    std::printf("%lld", value);
}

void csec_print_double(double value) {
    std::printf("%f", value);
}

void csec_print_bool(int value) {
    std::printf("%d", value ? 1 : 0);
}

void csec_print_char(char value) {
    std::printf("%c", value);
}

void csec_print_newline(void) {
    std::printf("\n");
}

char* csec_read_line(void) {
    char* buffer = static_cast<char*>(std::malloc(4096));
    if (!buffer) return nullptr;
    buffer[0] = '\0';
    if (!std::fgets(buffer, 4096, stdin)) {
        return buffer;
    }
    size_t len = std::strlen(buffer);
    if (len > 0 && buffer[len - 1] == '\n') {
        buffer[len - 1] = '\0';
    }
    return buffer;
}

char csec_read_char(void) {
    int ch = std::getchar();
    return ch == EOF ? '\0' : static_cast<char>(ch);
}

int csec_read_int(void) {
    int value = 0;
    std::scanf("%d", &value);
    return value;
}

double csec_read_double(void) {
    double value = 0.0;
    std::scanf("%lf", &value);
    return value;
}

double csec_math_sin(double value) { return std::sin(value); }
double csec_math_cos(double value) { return std::cos(value); }
double csec_math_tan(double value) { return std::tan(value); }
double csec_math_cot(double value) { return 1.0 / std::tan(value); }
double csec_math_sec(double value) { return 1.0 / std::cos(value); }
double csec_math_csc(double value) { return 1.0 / std::sin(value); }
double csec_math_asin(double value) { return std::asin(value); }
double csec_math_acos(double value) { return std::acos(value); }
double csec_math_atan(double value) { return std::atan(value); }
double csec_math_sinh(double value) { return std::sinh(value); }
double csec_math_cosh(double value) { return std::cosh(value); }
double csec_math_tanh(double value) { return std::tanh(value); }
double csec_math_coth(double value) { return 1.0 / std::tanh(value); }
double csec_math_sqrt(double value) { return std::sqrt(value); }
double csec_math_log(double value) { return std::log(value); }
double csec_math_log10(double value) { return std::log10(value); }
double csec_math_log_base(double base, double value) { return std::log(value) / std::log(base); }
double csec_math_exp(double value) { return std::exp(value); }
double csec_math_pow(double base, double exponent) { return std::pow(base, exponent); }
double csec_math_frac(double numerator, double denominator) { return numerator / denominator; }
double csec_math_binom(double n, double k) { return std::tgamma(n + 1.0) / (std::tgamma(k + 1.0) * std::tgamma(n - k + 1.0)); }
double csec_math_min(double left, double right) { return left < right ? left : right; }
double csec_math_max(double left, double right) { return left > right ? left : right; }

double csec_math_gcd(double left, double right) {
    long long a = static_cast<long long>(left);
    long long b = static_cast<long long>(right);
    if (a < 0) a = -a;
    if (b < 0) b = -b;
    while (b != 0) {
        long long r = a % b;
        a = b;
        b = r;
    }
    return static_cast<double>(a);
}

double csec_sim_md_lennard_jones(int atom_count, int bond_count, int steps, double dt, double temperature) {
    if (atom_count < 0) atom_count = 0;
    if (bond_count < 0) bond_count = 0;
    if (steps < 0) steps = 0;
    if (dt < 0.0) dt = 0.0;

    double kinetic = 0.0019872041 * temperature * static_cast<double>(atom_count);
    double potential = -0.05 * static_cast<double>(atom_count) - 0.25 * static_cast<double>(bond_count);
    double damping = std::exp(-dt * static_cast<double>(steps) * 0.1);
    return kinetic + potential * damping;
}

double csec_sim_cfd_lid_cavity(int width, int height, int steps, double dt, double viscosity, double lid_velocity) {
    if (width < 1) width = 1;
    if (height < 1) height = 1;
    if (steps < 0) steps = 0;
    if (dt < 0.0) dt = 0.0;
    if (viscosity < 0.0) viscosity = 0.0;

    double cells = static_cast<double>(width) * static_cast<double>(height);
    double reynolds = viscosity > 0.0 ? (lid_velocity * static_cast<double>(width)) / viscosity : 0.0;
    double stability = 1.0 / (1.0 + dt * static_cast<double>(steps));
    return (std::abs(lid_velocity) + reynolds * 1e-4) * stability / std::sqrt(cells);
}

double csec_sim_protein_mcmc(int residue_count, int steps, double temperature) {
    if (residue_count < 0) residue_count = 0;
    if (steps < 0) steps = 0;
    if (temperature < 0.0) temperature = 0.0;

    double residues = static_cast<double>(residue_count);
    double compactness = std::sqrt(residues + 1.0);
    double cooling = std::exp(-static_cast<double>(steps) / (1000.0 + temperature));
    double hydrophobicPacking = 0.035 * residues;
    return -(compactness + hydrophobicPacking) * (1.0 - cooling);
}

int csec_parallel_get_num_threads(void) {
    return configuredParallelThreads();
}

void csec_parallel_set_num_threads(int count) {
    setConfiguredParallelThreads(count);
}

int csec_parallel_backend_available(const char* name) {
    if (!name) return 0;
    if (std::strcmp(name, "cpu") == 0) return 1;
    if (std::strcmp(name, "simd") == 0) return 1;
#if defined(_OPENMP)
    if (std::strcmp(name, "openmp") == 0) return 1;
#else
    if (std::strcmp(name, "openmp") == 0) return 0;
#endif
    if (std::strcmp(name, "gpu") == 0) return 0;
    return 0;
}

int csec_parallel_backend_implemented(const char* name) {
    if (!name) return 0;
    if (std::strcmp(name, "cpu") == 0) return 1;
    if (std::strcmp(name, "simd") == 0) return 1;
#if defined(_OPENMP)
    if (std::strcmp(name, "openmp") == 0) return 1;
#else
    if (std::strcmp(name, "openmp") == 0) return 0;
#endif
    if (std::strcmp(name, "gpu") == 0) return 0;
    return 0;
}

void csec_parallel_for_i32(int start, int end, void* context, csec_parallel_for_i32_fn callback) {
    if (!callback || end <= start) return;

    int count = end - start;
    int requested = configuredParallelThreads();
    if (requested < 1) requested = 1;
    int workerCount = requested < count ? requested : count;

    if (workerCount <= 1) {
        for (int i = start; i < end; ++i) {
            callback(context, i);
        }
        return;
    }

    std::vector<std::thread> workers;
    workers.reserve(static_cast<size_t>(workerCount));
    for (int worker = 0; worker < workerCount; ++worker) {
        int chunkStart = start + (count * worker) / workerCount;
        int chunkEnd = start + (count * (worker + 1)) / workerCount;
        workers.emplace_back([=]() {
            for (int i = chunkStart; i < chunkEnd; ++i) {
                callback(context, i);
            }
        });
    }

    for (auto& worker : workers) {
        worker.join();
    }
}

long long csec_tcp_connect(const char* host, int port) {
    if (!host || port < 0 || port > 65535) return -1;
#ifdef _WIN32
    if (!ensureSocketRuntime()) return -1;
#else
    using SOCKET = NativeSocket;
    constexpr SOCKET INVALID_SOCKET = INVALID_SOCKET_HANDLE;
#endif

    addrinfo hints{};
    hints.ai_family = AF_UNSPEC;
    hints.ai_socktype = SOCK_STREAM;
    hints.ai_protocol = IPPROTO_TCP;

    char portText[16];
    std::snprintf(portText, sizeof(portText), "%d", port);

    addrinfo* results = nullptr;
    if (getaddrinfo(host, portText, &hints, &results) != 0) {
        return -1;
    }

    SOCKET connected = INVALID_SOCKET;
    for (addrinfo* item = results; item; item = item->ai_next) {
        SOCKET candidate = socket(item->ai_family, item->ai_socktype, item->ai_protocol);
        if (candidate == INVALID_SOCKET) {
            continue;
        }
        if (connect(candidate, item->ai_addr, static_cast<int>(item->ai_addrlen)) == 0) {
            connected = candidate;
            break;
        }
        closeSocketHandle(candidate);
    }

    freeaddrinfo(results);
    return connected == INVALID_SOCKET ? -1 : static_cast<long long>(connected);
}

int csec_tcp_send(long long socket_handle, const char* data) {
    if (socket_handle < 0 || !data) return -1;
#ifdef _WIN32
    return send(static_cast<SOCKET>(socket_handle), data, static_cast<int>(std::strlen(data)), 0);
#else
    return static_cast<int>(send(static_cast<int>(socket_handle), data, std::strlen(data), 0));
#endif
}

char* csec_tcp_recv(long long socket_handle, int max_bytes) {
    if (max_bytes < 0) max_bytes = 0;
    char* buffer = static_cast<char*>(std::malloc(static_cast<size_t>(max_bytes) + 1));
    if (!buffer) return nullptr;
    buffer[0] = '\0';
#ifdef _WIN32
    if (socket_handle < 0) return buffer;
    int count = recv(static_cast<SOCKET>(socket_handle), buffer, max_bytes, 0);
#else
    if (socket_handle < 0) return buffer;
    int count = static_cast<int>(recv(static_cast<int>(socket_handle), buffer, static_cast<size_t>(max_bytes), 0));
#endif
    if (count < 0) count = 0;
    buffer[count] = '\0';
    return buffer;
}

int csec_tcp_close(long long socket_handle) {
    if (socket_handle < 0) return -1;
#ifdef _WIN32
    return closesocket(static_cast<SOCKET>(socket_handle));
#else
    return close(static_cast<int>(socket_handle));
#endif
}

int csec_posix_open(const char* path, int flags, int mode) {
    if (!path) return -1;
#ifdef _WIN32
    return _open(path, flags, mode);
#else
    return open(path, flags, static_cast<mode_t>(mode));
#endif
}

char* csec_posix_read(int fd, int max_bytes) {
    if (max_bytes < 0) max_bytes = 0;
    char* buffer = static_cast<char*>(std::malloc(static_cast<size_t>(max_bytes) + 1));
    if (!buffer) return nullptr;
    buffer[0] = '\0';
    if (fd < 0) return buffer;
#ifdef _WIN32
    int count = _read(fd, buffer, static_cast<unsigned int>(max_bytes));
#else
    int count = static_cast<int>(read(fd, buffer, static_cast<size_t>(max_bytes)));
#endif
    if (count < 0) count = 0;
    buffer[count] = '\0';
    return buffer;
}

int csec_posix_write(int fd, const char* data) {
    if (fd < 0 || !data) return -1;
#ifdef _WIN32
    return _write(fd, data, static_cast<unsigned int>(std::strlen(data)));
#else
    return static_cast<int>(write(fd, data, std::strlen(data)));
#endif
}

int csec_posix_close(int fd) {
    if (fd < 0) return -1;
#ifdef _WIN32
    return _close(fd);
#else
    return close(fd);
#endif
}

long long csec_posix_lseek(int fd, long long offset, int whence) {
    if (fd < 0) return -1;
#ifdef _WIN32
    return static_cast<long long>(_lseeki64(fd, offset, whence));
#else
    return static_cast<long long>(lseek(fd, static_cast<off_t>(offset), whence));
#endif
}

int csec_posix_unlink(const char* path) {
    if (!path) return -1;
#ifdef _WIN32
    return _unlink(path);
#else
    return unlink(path);
#endif
}

int csec_posix_rename(const char* old_path, const char* new_path) {
    if (!old_path || !new_path) return -1;
    return std::rename(old_path, new_path);
}

int csec_posix_mkdir(const char* path, int mode) {
    if (!path) return -1;
#ifdef _WIN32
    (void)mode;
    return _mkdir(path);
#else
    return mkdir(path, static_cast<mode_t>(mode));
#endif
}

int csec_posix_rmdir(const char* path) {
    if (!path) return -1;
#ifdef _WIN32
    return _rmdir(path);
#else
    return rmdir(path);
#endif
}

int csec_posix_chdir(const char* path) {
    if (!path) return -1;
#ifdef _WIN32
    return _chdir(path);
#else
    return chdir(path);
#endif
}

char* csec_posix_getcwd(void) {
#ifdef _WIN32
    return _getcwd(nullptr, 0);
#else
    return getcwd(nullptr, 0);
#endif
}

int csec_posix_access(const char* path, int mode) {
    if (!path) return -1;
#ifdef _WIN32
    return _access(path, mode);
#else
    return access(path, mode);
#endif
}

char* csec_posix_getenv(const char* name) {
    if (!name) return nullptr;
    const char* value = std::getenv(name);
    if (!value) value = "";
    size_t len = std::strlen(value);
    char* copy = static_cast<char*>(std::malloc(len + 1));
    if (!copy) return nullptr;
    std::memcpy(copy, value, len + 1);
    return copy;
}

int csec_posix_setenv(const char* name, const char* value, int overwrite) {
    if (!name || !value) return -1;
#ifdef _WIN32
    if (!overwrite && std::getenv(name)) return 0;
    return _putenv_s(name, value);
#else
    return setenv(name, value, overwrite ? 1 : 0);
#endif
}

int csec_posix_unsetenv(const char* name) {
    if (!name) return -1;
#ifdef _WIN32
    return _putenv_s(name, "");
#else
    return unsetenv(name);
#endif
}

int csec_posix_sleep(int seconds) {
    if (seconds < 0) return -1;
#ifdef _WIN32
    Sleep(static_cast<DWORD>(seconds) * 1000U);
    return 0;
#else
    return static_cast<int>(sleep(static_cast<unsigned int>(seconds)));
#endif
}

long long csec_posix_time(void) {
    return static_cast<long long>(std::time(nullptr));
}

int csec_posix_errno(void) {
    return errno;
}

int csec_posix_flag_read_only(void) { return O_RDONLY; }
int csec_posix_flag_write_only(void) { return O_WRONLY; }
int csec_posix_flag_read_write(void) { return O_RDWR; }
int csec_posix_flag_create(void) { return O_CREAT; }
int csec_posix_flag_truncate(void) { return O_TRUNC; }
int csec_posix_flag_append(void) { return O_APPEND; }
int csec_posix_seek_set(void) { return SEEK_SET; }
int csec_posix_seek_cur(void) { return SEEK_CUR; }
int csec_posix_seek_end(void) { return SEEK_END; }
int csec_posix_access_exists(void) { return 0; }
int csec_posix_access_read(void) { return 4; }
int csec_posix_access_write(void) { return 2; }
int csec_posix_access_execute(void) { return 1; }

}
