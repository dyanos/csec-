// User-mode context switching for microthreads on POSIX systems (Linux, macOS, BSD).
//
// On x86-64 (System V ABI) and AArch64 (AAPCS64, including Apple Silicon) a context is just a saved
// stack pointer: csec_ctx_switch pushes the callee-saved registers and the floating-point control
// state onto the current stack, stores the stack pointer, loads the other one, and pops its
// registers. This avoids <ucontext.h>, which macOS has deprecated (it does not even compile without
// _XOPEN_SOURCE) and whose swapcontext makes a signal-mask system call on every switch. Other
// architectures fall back to ucontext. Windows uses fibers (process_runtime.inc).
//
// A new context starts in csec_ctx_trampoline, which calls csec_ctx_entry() on its own stack; that
// runs the current microthread and never returns.

#ifndef _WIN32

#include <cstdint>
#include <cstring>
#include <sys/mman.h>
#include <unistd.h>

#if defined(__x86_64__) || defined(__aarch64__)
#define CSEC_FAST_CONTEXT 1
#else
#define CSEC_FAST_CONTEXT 0
#include <ucontext.h>
#endif

#if CSEC_FAST_CONTEXT

#if defined(__APPLE__)
#define CSEC_ASM_SYMBOL(name) "_" #name
#define CSEC_ASM_FUNCTION(name) \
    ".globl " CSEC_ASM_SYMBOL(name) "\n" \
    ".private_extern " CSEC_ASM_SYMBOL(name) "\n" \
    ".p2align 4\n" \
    CSEC_ASM_SYMBOL(name) ":\n"
#else
#define CSEC_ASM_SYMBOL(name) #name
#define CSEC_ASM_FUNCTION(name) \
    ".globl " CSEC_ASM_SYMBOL(name) "\n" \
    ".hidden " CSEC_ASM_SYMBOL(name) "\n" \
    ".type " CSEC_ASM_SYMBOL(name) ", %function\n" \
    ".p2align 4\n" \
    CSEC_ASM_SYMBOL(name) ":\n"
#endif

extern "C" {
// Save the current context's stack pointer into *saveSp and resume the context whose stack pointer is
// loadSp.
void csec_ctx_switch(void** saveSp, void* loadSp);
// First "return address" of a fresh context.
void csec_ctx_trampoline(void);
// Runs the current microthread; defined in process_runtime.inc. Never returns.
__attribute__((visibility("hidden"), used)) void csec_ctx_entry(void);
}

#if defined(__x86_64__)
// Frame pushed by csec_ctx_switch, from the saved stack pointer upwards:
//   +0  MXCSR (4 bytes) and x87 control word (2 bytes)
//   +8  r15, +16 r14, +24 r13, +32 r12, +40 rbx, +48 rbp, +56 return address
asm(
    ".text\n"
    CSEC_ASM_FUNCTION(csec_ctx_switch)
    "    pushq %rbp\n"
    "    pushq %rbx\n"
    "    pushq %r12\n"
    "    pushq %r13\n"
    "    pushq %r14\n"
    "    pushq %r15\n"
    "    subq $8, %rsp\n"
    "    stmxcsr (%rsp)\n"
    "    fnstcw 4(%rsp)\n"
    "    movq %rsp, (%rdi)\n"
    "    movq %rsi, %rsp\n"
    "    ldmxcsr (%rsp)\n"
    "    fldcw 4(%rsp)\n"
    "    addq $8, %rsp\n"
    "    popq %r15\n"
    "    popq %r14\n"
    "    popq %r13\n"
    "    popq %r12\n"
    "    popq %rbx\n"
    "    popq %rbp\n"
    "    ret\n"
    CSEC_ASM_FUNCTION(csec_ctx_trampoline)
    "    xorl %ebp, %ebp\n"
    "    andq $-16, %rsp\n"
    "    call " CSEC_ASM_SYMBOL(csec_ctx_entry) "\n"
    "    ud2\n");

constexpr size_t kContextFrameBytes = 72;

void* csecInitialStackPointer(void* stackBase, size_t stackBytes) {
    auto top = (reinterpret_cast<uintptr_t>(stackBase) + stackBytes) & ~static_cast<uintptr_t>(15);
    auto* frame = reinterpret_cast<unsigned char*>(top - kContextFrameBytes);
    std::memset(frame, 0, kContextFrameBytes);
    const uint32_t mxcsr = 0x1F80;   // default: all exceptions masked, round to nearest
    const uint16_t fpuControl = 0x037F;
    std::memcpy(frame + 0, &mxcsr, sizeof(mxcsr));
    std::memcpy(frame + 4, &fpuControl, sizeof(fpuControl));
    void* entry = reinterpret_cast<void*>(&csec_ctx_trampoline);
    std::memcpy(frame + 56, &entry, sizeof(entry));
    return frame;
}

#elif defined(__aarch64__)
// Frame pushed by csec_ctx_switch (176 bytes, keeps sp 16-byte aligned):
//   +0..+72 x19..x28, +80 x29 (fp), +88 x30 (lr = resume address), +96..+152 d8..d15, +160 FPCR
asm(
    ".text\n"
    CSEC_ASM_FUNCTION(csec_ctx_switch)
    "    sub sp, sp, #176\n"
    "    stp x19, x20, [sp, #0]\n"
    "    stp x21, x22, [sp, #16]\n"
    "    stp x23, x24, [sp, #32]\n"
    "    stp x25, x26, [sp, #48]\n"
    "    stp x27, x28, [sp, #64]\n"
    "    stp x29, x30, [sp, #80]\n"
    "    stp d8, d9, [sp, #96]\n"
    "    stp d10, d11, [sp, #112]\n"
    "    stp d12, d13, [sp, #128]\n"
    "    stp d14, d15, [sp, #144]\n"
    "    mrs x9, fpcr\n"
    "    str x9, [sp, #160]\n"
    "    mov x9, sp\n"
    "    str x9, [x0]\n"
    "    mov sp, x1\n"
    "    ldr x9, [sp, #160]\n"
    "    msr fpcr, x9\n"
    "    ldp x19, x20, [sp, #0]\n"
    "    ldp x21, x22, [sp, #16]\n"
    "    ldp x23, x24, [sp, #32]\n"
    "    ldp x25, x26, [sp, #48]\n"
    "    ldp x27, x28, [sp, #64]\n"
    "    ldp x29, x30, [sp, #80]\n"
    "    ldp d8, d9, [sp, #96]\n"
    "    ldp d10, d11, [sp, #112]\n"
    "    ldp d12, d13, [sp, #128]\n"
    "    ldp d14, d15, [sp, #144]\n"
    "    add sp, sp, #176\n"
    "    ret\n"
    CSEC_ASM_FUNCTION(csec_ctx_trampoline)
    "    mov x29, #0\n"
    "    bl " CSEC_ASM_SYMBOL(csec_ctx_entry) "\n"
    "    brk #0\n");

constexpr size_t kContextFrameBytes = 176;

void* csecInitialStackPointer(void* stackBase, size_t stackBytes) {
    auto top = (reinterpret_cast<uintptr_t>(stackBase) + stackBytes) & ~static_cast<uintptr_t>(15);
    auto* frame = reinterpret_cast<unsigned char*>(top - kContextFrameBytes);
    std::memset(frame, 0, kContextFrameBytes);   // FPCR 0: round to nearest, no traps
    void* entry = reinterpret_cast<void*>(&csec_ctx_trampoline);
    std::memcpy(frame + 88, &entry, sizeof(entry));
    return frame;
}
#endif

#endif // CSEC_FAST_CONTEXT

// Microthread stacks are mapped, with one inaccessible guard page at the low end so a stack overflow
// faults instead of corrupting a neighbouring allocation.
size_t csecPageSize() {
    static const size_t page = [] {
        const long value = sysconf(_SC_PAGESIZE);
        return value > 0 ? static_cast<size_t>(value) : static_cast<size_t>(4096);
    }();
    return page;
}

void* csecAllocateStack(size_t usableBytes, size_t& mappedBytes) {
    const size_t page = csecPageSize();
    mappedBytes = (usableBytes + page - 1) / page * page + page;
    void* base = mmap(nullptr, mappedBytes, PROT_READ | PROT_WRITE, MAP_PRIVATE | MAP_ANON, -1, 0);
    if (base == MAP_FAILED) return nullptr;
    mprotect(base, page, PROT_NONE);
    return base;
}

void csecFreeStack(void* base, size_t mappedBytes) {
    if (base) munmap(base, mappedBytes);
}

#endif // !_WIN32
