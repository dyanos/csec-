#pragma once

#include "type.h"
#include <vector>
#include <memory>

namespace llvm {
class Type;
class Value;
}

bool areTypesCompatible(const std::vector<std::unique_ptr<Type>>& paramTypes, const std::vector<std::unique_ptr<Type>>& argTypes);
bool isStructClassType(const Type* type);
// Auto-deref: if `type` is a borrow (`&T`/`&mut T`), return a clone of the borrowed `T`; otherwise a
// clone of `type` itself. Lets member access / indexing treat a borrowed receiver like the value.
std::unique_ptr<Type> stripBorrow(const std::unique_ptr<Type>& type);
llvm::Type* getABIStorageType(const Type* type);
llvm::Value* coerceValueToLLVMType(llvm::Value* value, llvm::Type* targetType);
