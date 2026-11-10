#pragma once

#include <set>
#include <string>

// Compiler intrinsics enabled for the program being compiled.
//
// The compiler has built-in lowerings for some operations (microthreads, OS threads, futures, ...)
// but they are not visible by default. A standard-library module turns one on by declaring it:
//
//     [@Intrinsic] external def spawn(body: () => Int): Int;
//
// so the compiler author decides, per library module, which intrinsics an `import` exposes. The
// parser records every such declaration here; codegen and the type checker consult the set before
// treating a call as an intrinsic. The declaration itself emits no code.
inline std::set<std::string>& declaredIntrinsics() {
    static std::set<std::string> names;
    return names;
}

inline bool isDeclaredIntrinsic(const std::string& name) {
    return declaredIntrinsics().count(name) != 0;
}
