#include "type.h"

std::unique_ptr<Type> Type::makeBasic(const std::string& name) {
    return std::make_unique<BasicType>(name);
}

std::unique_ptr<Type> Type::makePointer(std::unique_ptr<Type> base) {
    return std::make_unique<PointerType>(base);
}

std::unique_ptr<Type> Type::makeArray(std::unique_ptr<Type> base, int size) {
    return std::make_unique<ArrayType>(base, size);
}

std::unique_ptr<Type> Type::makeStruct(const std::string& name,
    const std::vector<std::pair<std::string, std::unique_ptr<Type>>>& fields) {
    auto result = std::make_unique<StructType>(name);
    for (const auto& f : fields) {
        result->fields.push_back({f.first, f.second ? f.second->clone() : nullptr});
    }
    return result;
}

std::unique_ptr<Type> Type::makeFunction(const std::unique_ptr<Type>& ret,
    const std::vector<std::unique_ptr<Type>>& params) {
    return std::make_unique<FunctionType>(params, ret);
}

bool Type::checkFunctionSubtype(const Type& other) const {
    auto otherFuncType = dynamic_cast<const FunctionType*>(&other);
    if (!otherFuncType) return false;

    if (!this->returnType || !otherFuncType->returnType) return false;
    if (this->paramTypes.size() != otherFuncType->paramTypes.size()) return false;

    for (size_t i = 0; i < this->paramTypes.size(); ++i) {
        if (!this->paramTypes[i] || !otherFuncType->paramTypes[i]) return false;
        if (!otherFuncType->paramTypes[i]->isSubtypeOf(*this->paramTypes[i])) {
            return false;
        }
    }

    if (!this->returnType->isSubtypeOf(*otherFuncType->returnType)) {
        return false;
    }
    return true;
}

bool Type::checkFunctionSubtype(const std::unique_ptr<Type>& other) const {
    return other && checkFunctionSubtype(*other);
}

bool Type::isSubtypeOf(const Type& other) const {
    if (*this == other) return true;

    if (other.isTopType()) return true;

    if (getKind() != other.getKind()) {
    }

    switch (getKind()) {
    case Kind::CLASS:
    case Kind::STRUCT:
        if (this->hasSuperClass(other)) return true;
        if (structuralCheck(other)) return true;
        return false;

    case Kind::FUNCTION:
        return this->checkFunctionSubtype(other);

    case Kind::ARRAY:
        if (!this->elementType || !other.elementType) return false;
        return this->elementType->isSubtypeOf(*other.elementType) && this->arraySize == other.arraySize;

    case Kind::POINTER:
    {
        bool flag = false;
        for (const auto& baseType : this->baseTypes) {
            if (!baseType) continue;
            if (baseType->isSubtypeOf(other)) {
                flag = true;
                break;
            }
        }

        return flag;
    }

    case Kind::BOX:
    case Kind::BORROW:
    case Kind::MUTABLE_BORROW:
    case Kind::UNSAFE_POINTER:
        return equals(other);

    case Kind::GENERIC:
        return this->checkGenericSubtype(other);

    case Kind::BASIC:
        return checkBasicConversion(other);

    default:
        return false;
    }
}

bool Type::isSubtypeOf(const std::unique_ptr<Type>& other) const {
    return other && isSubtypeOf(*other);
}
