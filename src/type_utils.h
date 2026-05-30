#pragma once

#include "type.h"
#include <vector>
#include <memory>

bool areTypesCompatible(const std::vector<std::unique_ptr<Type>>& paramTypes, const std::vector<std::unique_ptr<Type>>& argTypes);
