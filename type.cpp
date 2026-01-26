#include "type.h"

std::unique_ptr<Type> Type::makeBasic(const std::string& name) {
	return std::make_unique<Type>(Kind::BASIC, name);
}

std::unique_ptr<Type> Type::makePointer(std::unique_ptr<Type> base) {
	return std::make_unique<Type>(Type::Kind::POINTER, base->getName() + "*");
}

std::unique_ptr<Type> Type::makeArray(std::unique_ptr<Type> base, int size) {
	return std::make_unique<Type>(Type::Kind::ARRAY, base->getName() + "[]");
}

std::unique_ptr<Type> Type::makeStruct(const std::string& name,
	const std::vector<std::pair<std::string, std::unique_ptr<Type>>>& fields) {
	return std::make_unique<Type>(Type::Kind::STRUCT, name);
}

std::unique_ptr<Type> Type::makeFunction(std::unique_ptr<Type>& ret, const std::vector<std::unique_ptr<Type>>& params) {
    auto function = std::make_unique<Type>(Type::Kind::FUNCTION, "function");
    function->returnType = ret->clone();
	for (const auto& p : params) {
        function->paramTypes.push_back(p->clone());
    }
	return function;
}

bool Type::checkFunctionSubtype(const std::unique_ptr<Type>& other) {
    auto otherFuncType = (FunctionType*)(other.get());
    if (!otherFuncType) return false;

    if (this->paramTypes.size() !=
        otherFuncType->paramTypes.size()) return false;

    for (size_t i = 0; i < this->paramTypes.size(); ++i) {
        if (!otherFuncType->paramTypes[i]->isSubtypeOf(this->paramTypes[i])) {
            return false;
        }
    }

    if (!this->returnType->isSubtypeOf(otherFuncType->returnType)) {
        return false;
    }
    return true;
}

bool Type::isSubtypeOf(const std::unique_ptr<Type>& other) {
    if (*this == other) return true;

    if (other->isTopType()) return true;

    if (getKind() != other->getKind()) {
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
        return this->elementType->isSubtypeOf(other->elementType) && this->arraySize == other->arraySize;

    case Kind::POINTER:
    {
        bool flag = false;
        for (auto& baseType : this->baseTypes) {
            if (baseType->isSubtypeOf(other)) {
                flag = true;
                break;
            }
        }

        return flag;
    }

    case Kind::GENERIC:
        return this->checkGenericSubtype(other);

    case Kind::BASIC:
        return checkBasicConversion(other);

    default:
        return false;
    }
}