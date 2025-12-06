#include "type_utils.h"


bool areTypesCompatible(const std::vector<std::shared_ptr<Type>>& paramTypes, const std::vector<std::shared_ptr<Type>>& argTypes) {
    if (paramTypes.size() != argTypes.size()) {
        return false;
    }

    for (size_t i = 0; i < paramTypes.size(); ++i) {
        if (!argTypes[i]->equals(paramTypes[i].get())) {
            return false;
        }
    }
    return true;
}