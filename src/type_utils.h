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
llvm::Type* getABIStorageType(const Type* type);
llvm::Value* coerceValueToLLVMType(llvm::Value* value, llvm::Type* targetType);
