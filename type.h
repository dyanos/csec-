// type.h

#pragma once

#include <string>
#include <vector>
#include <memory>

enum class TypeKind {
    BASIC,
    CLASS,
    FUNCTION,
    GENERIC,
    VALUE,
    UNKNOWN
};

class Type : public std::enable_shared_from_this<Type> {
public:
    TypeKind kind;
    std::string name;
    std::shared_ptr<Type> parentType;  // 상위 타입 (부모 타입)

    Type(TypeKind kind, const std::string& name, std::shared_ptr<Type> parentType = nullptr)
        : kind(kind), name(name), parentType(parentType) {}

    virtual ~Type() = default;

    // 타입 비교를 위한 함수
    virtual bool equals(std::shared_ptr<Type> other) {
        return this == other.get();
    }

    // 서브타입 검사 함수
    virtual bool isSubtypeOf(std::shared_ptr<Type> other) {
        std::shared_ptr<Type> current = shared_from_this();
        while (current) {
            if (current->equals(other)) {
                return true;
            }
            current = current->parentType;
        }
        return false;
    }
};

// 기본 타입
class BasicType : public Type, public std::enable_shared_from_this<BasicType> {
public:
    BasicType(const std::string& name, std::shared_ptr<Type> parentType)
        : Type(TypeKind::BASIC, name, parentType) {}
};

class ClassType : public Type, public std::enable_shared_from_this<ClassType> {
public:
    ClassType(const std::string& name, std::shared_ptr<Type> parentType)
        : Type(TypeKind::CLASS, name, parentType) {}
};

class FunctionType : public Type {
public:
    std::vector<std::shared_ptr<Type>> parameterTypes;
    std::shared_ptr<Type> returnType;

    FunctionType(const std::vector<std::shared_ptr<Type>>& parameterTypes, std::shared_ptr<Type> returnType)
        : Type(TypeKind::FUNCTION, "function"), parameterTypes(parameterTypes), returnType(returnType) {}

    bool equals(std::shared_ptr<Type> other) override {
        if (other->kind != TypeKind::FUNCTION) return false;
        auto otherFuncType = std::dynamic_pointer_cast<FunctionType>(other);
        if (!returnType->equals(otherFuncType->returnType)) return false;
        if (parameterTypes.size() != otherFuncType->parameterTypes.size()) return false;
        for (size_t i = 0; i < parameterTypes.size(); ++i) {
            if (!parameterTypes[i]->equals(otherFuncType->parameterTypes[i])) return false;
        }
        return true;
    }
};

class UnknownType : public Type, public std::enable_shared_from_this<UnknownType> {
public:
    UnknownType()
        : Type(TypeKind::UNKNOWN, "unknown") {}

    bool equals(std::shared_ptr<Type> other) override {
        return false;
    }
};

class GenericType : public Type {
public:
    std::shared_ptr<Type> baseType;  // 기본 타입 (예: Array)
    std::vector<std::shared_ptr<Type>> typeArguments;  // 타입 인자 (예: [String])

    GenericType(std::shared_ptr<Type> baseType, const std::vector<std::shared_ptr<Type>>& typeArguments)
        : Type(TypeKind::GENERIC, baseType->name), baseType(baseType), typeArguments(typeArguments) {}

    bool equals(std::shared_ptr<Type> other) override {
        if (other->kind != TypeKind::GENERIC) return false;
        auto otherGeneric = std::dynamic_pointer_cast<GenericType>(other);
        if (!baseType->equals(otherGeneric->baseType)) return false;
        if (typeArguments.size() != otherGeneric->typeArguments.size()) return false;
        for (size_t i = 0; i < typeArguments.size(); ++i) {
            if (!typeArguments[i]->equals(otherGeneric->typeArguments[i])) return false;
        }
        return true;
    }

    bool isSubtypeOf(std::shared_ptr<Type> other) override {
        if (equals(other)) return true;
        // 추가적인 서브타입 로직을 여기에 구현할 수 있습니다.
        return false;
    }
};
