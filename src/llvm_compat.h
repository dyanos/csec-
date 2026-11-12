#pragma once

// Thin wrappers over LLVM APIs whose signatures changed between LLVM 18 (the vcpkg baseline) and
// LLVM 23. Each wrapper picks the newest available overload at compile time (by expression SFINAE,
// not by version number), so the same source builds against every release in that range without
// deprecation warnings.

#include <llvm/ADT/StringMap.h>
#include <llvm/IR/Module.h>
#include <llvm/MC/TargetRegistry.h>
#include <llvm/Target/TargetMachine.h>
#include <llvm/Target/TargetOptions.h>
#include <llvm/TargetParser/Host.h>
#include <llvm/TargetParser/Triple.h>

#include <optional>
#include <string>
#include <utility>

namespace csec_llvm {
namespace detail {

// Module::setTargetTriple(Triple) (LLVM 21+) vs setTargetTriple(StringRef).
template <typename M>
auto setTargetTriple(M& module, const llvm::Triple& triple, int) -> decltype(module.setTargetTriple(triple), void()) {
    module.setTargetTriple(triple);
}
template <typename M>
void setTargetTriple(M& module, const llvm::Triple& triple, long) {
    module.setTargetTriple(triple.str());
}

// TargetRegistry::lookupTarget(const Triple&, ...) (LLVM 21+) vs lookupTarget(const std::string&, ...).
template <typename R>
auto lookupTarget(const llvm::Triple& triple, std::string& error, int)
    -> decltype(R::lookupTarget(triple, error)) {
    return R::lookupTarget(triple, error);
}
template <typename R>
const llvm::Target* lookupTarget(const llvm::Triple& triple, std::string& error, long) {
    return R::lookupTarget(triple.str(), error);
}

// Target::createTargetMachine(const Triple&, ...) (LLVM 21+) vs createTargetMachine(StringRef, ...).
template <typename T>
auto createTargetMachine(const T& target, const llvm::Triple& triple, llvm::StringRef cpu, llvm::StringRef features,
                         const llvm::TargetOptions& options, std::optional<llvm::Reloc::Model> reloc, int)
    -> decltype(target.createTargetMachine(triple, cpu, features, options, reloc)) {
    return target.createTargetMachine(triple, cpu, features, options, reloc);
}
template <typename T>
llvm::TargetMachine* createTargetMachine(const T& target, const llvm::Triple& triple, llvm::StringRef cpu,
                                         llvm::StringRef features, const llvm::TargetOptions& options,
                                         std::optional<llvm::Reloc::Model> reloc, long) {
    return target.createTargetMachine(triple.str(), cpu, features, options, reloc);
}

// sys::getHostCPUFeatures() returning the map (LLVM 19+) vs filling an out-parameter.
// The (empty) argument pack and the defaulted map type make both calls dependent, so the overload
// that does not exist in a given LLVM is never checked.
template <typename... Args>
auto hostCPUFeatures(int, Args&&... args) -> decltype(llvm::sys::getHostCPUFeatures(std::forward<Args>(args)...)) {
    return llvm::sys::getHostCPUFeatures(std::forward<Args>(args)...);
}
template <typename Map = llvm::StringMap<bool>>
Map hostCPUFeatures(long) {
    Map features;
    llvm::sys::getHostCPUFeatures(features);
    return features;
}

// LLVM 23 changed BasicBlock::getTerminator() to require a well-formed block (it asserts, and in
// release builds returns the last instruction even when that is not a terminator); the old
// "null if unterminated" behaviour moved to getTerminatorOrNull().
template <typename B>
auto terminatorOrNull(B* block, int) -> decltype(block->getTerminatorOrNull()) {
    return block->getTerminatorOrNull();
}
template <typename B>
llvm::Instruction* terminatorOrNull(B* block, long) {
    return block->getTerminator();
}

} // namespace detail

// The block's terminator, or null while the block is still open. Use this (not getTerminator) to ask
// "has this block been terminated yet?".
inline llvm::Instruction* terminatorOrNull(llvm::BasicBlock* block) {
    return block ? detail::terminatorOrNull(block, 0) : nullptr;
}

inline void setTargetTriple(llvm::Module& module, const llvm::Triple& triple) {
    detail::setTargetTriple(module, triple, 0);
}

inline const llvm::Target* lookupTarget(const llvm::Triple& triple, std::string& error) {
    return detail::lookupTarget<llvm::TargetRegistry>(triple, error, 0);
}

inline llvm::TargetMachine* createTargetMachine(const llvm::Target& target, const llvm::Triple& triple,
                                                llvm::StringRef cpu, llvm::StringRef features,
                                                const llvm::TargetOptions& options,
                                                std::optional<llvm::Reloc::Model> reloc) {
    return detail::createTargetMachine(target, triple, cpu, features, options, reloc, 0);
}

inline llvm::StringMap<bool> hostCPUFeatures() {
    return detail::hostCPUFeatures(0);
}

} // namespace csec_llvm
