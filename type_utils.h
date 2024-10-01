#pragma once

#include "type.h"
#include <vector>
#include <memory>

bool areTypesCompatible(const std::vector<std::shared_ptr<Type>>& paramTypes, const std::vector<std::shared_ptr<Type>>& argTypes);
bool isTypeConvertible(const std::shared_ptr<Type>& from, const std::shared_ptr<Type>& to);