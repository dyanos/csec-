#pragma once


#include "type.h"

Type* Type::makeBasic(const std::string& name) {
	return new Type(Kind::BASIC, name);
}

Type* Type::makePointer(Type* base) {
	return new Type(Type::Kind::POINTER, base->getName() + "*");
}

Type* Type::makeArray(Type* base, int size) {
	return new Type(Type::Kind::ARRAY, base->getName() + "[]");
}

Type* Type::makeStruct(const std::string& name,
	const std::vector<std::pair<std::string, Type*>>& fields) {
	return new Type(Type::Kind::STRUCT, name);
}

Type* Type::makeFunction(Type* ret, const std::vector<Type*>& params) {
	return new Type(Type::Kind::FUNCTION, "function");
}

bool Type::checkFunctionSubtype(const Type* other) {
    auto otherFuncType = (FunctionType*)(other);
    if (!otherFuncType) return false;
    // 매개변수 개수 검사
    if (this->paramTypes.size() !=
        otherFuncType->paramTypes.size()) return false;
    // 매개변수 타입 반공변 검사
    for (size_t i = 0; i < this->paramTypes.size(); ++i) {
        if (!otherFuncType->paramTypes[i]->isSubtypeOf(this->paramTypes[i])) {
            return false;
        }
    }
    // 반환타입 공변 검사
    if (!this->returnType->isSubtypeOf(otherFuncType->returnType.get())) {
        return false;
    }
    return true;
}

bool Type::isSubtypeOf(const Type* other) {
    // 1. 동일 타입이면 true (반사성)
    if (this == other) return true;

    // 2. other가 “무종(type) 또는 최상위 타입”(예: Any)라면 true
    if (other->isTopType()) return true;

    // 3. kind가 다르면 대부분 false (하지만 예외 존재: 예컨대 기본형간 상호 변환)
    if (getKind() != other->getKind()) {
        // 예외 처리: 예컨대 배열 타입이라면 elementType 비교 etc
        // 또는 BASIC 타입간의 암묵적 변환 허용 등
    }

    // 4. kind별로 세부 검사
    switch (getKind()) {
    case Kind::CLASS:
    case Kind::STRUCT:
        // 명명적: this->name이 other->name과 같거나 this의 상위 클래스 중에 other->name이 있다
        if (this->hasSuperClass(other)) return true;
        // 구조적: other 필드/메서드가 모두 this에 존재하고 타입 호환이면 true
        if (structuralCheck(this, other)) return true;
        return false;

    case Kind::FUNCTION:
        // 함수 타입 A→B 가 C→D 의 서브타입이려면:
        // 매개변수 타입이 반공변(매개변수별로 Cparam_i <: Aparam_i)이고
        // 반환타입이 공변(Areturn <: Dreturn)
        return this->checkFunctionSubtype(other);

    case Kind::ARRAY:
        // 보통 공변 혹은 불공변depending on 언어
        return this->elementType->isSubtypeOf(other->elementType) && this->arraySize == other->arraySize;

    case Kind::POINTER:
    {
        // 언어에 따라 참조 서브타입 관계가 달라짐
        bool flag = false;
        for (auto baseType : this->baseTypes) {
            if (baseType->isSubtypeOf(other)) {
                flag = true;
                break;
            }
        }

        return flag;
    }

    case Kind::GENERIC:
        // 제네릭 타입의 경우 타입 인자별 variance 검사 필요
        return this->checkGenericSubtype(other);

    case Kind::BASIC:
        // 예: int <: float 허용하면 특별 룰 구현
        return checkBasicConversion(this, other);

    default:
        return false;
    }
}