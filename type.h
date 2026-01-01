// type.h

#pragma once

#include <string>
#include <vector>
#include <memory>


class Type : public std::enable_shared_from_this<Type> {
public:
    // VARIABLE에 대해서는 검토 필요
    enum Kind { UNKNOWN=-1, BASIC=0, POINTER, ARRAY, STRUCT, CLASS, FUNCTION, GENERIC, VARIABLE };

private:
    Kind kind;

    std::vector<Type*> baseTypes; // 다중 상속 지원을 위한 기반 타입들
    // 예: BASIC이면 이름("int","float" 등)
    std::string name;
    // STRUCT/CLASS이면 멤버 필드맵
    std::vector<std::pair<std::string, Type*>> fields = {};
    // FUNCTION이면 반환타입 + 매개타입 리스트
    Type* returnType = nullptr;
    std::vector<Type*> paramTypes = {};
    // 배열이면 elementType + size
    Type* elementType = nullptr;
    int arraySize = 0;
    // 기타 제네릭이면 타입인자 리스트 등
    std::vector<Type*> typeArgs = {};

public:
	Type() : Type(Kind::UNKNOWN, "unknown") {}
    Type(Kind kind, const std::string& name, std::shared_ptr<Type> parentType = nullptr)
        : kind(kind), name(name) {
        if (parentType) {
            baseTypes.push_back(parentType.get());
		}
    }
    Type(Type* type)
        : kind(type->kind), name(type->name),
          baseTypes(type->baseTypes),
          fields(type->fields),
          returnType(type->returnType),
          paramTypes(type->paramTypes),
          elementType(type->elementType),
          arraySize(type->arraySize),
		typeArgs(type->typeArgs) {
	}

    virtual ~Type() = default;

    // 생성자들 및 접근자
    static Type* makeBasic(const std::string& name);
    static Type* makePointer(Type* base);
    static Type* makeArray(Type* base, int size);
    static Type* makeStruct(const std::string& name,
        const std::vector<std::pair<std::string, Type*>>& fields);
    static Type* makeFunction(Type* ret, const std::vector<Type*>& params);

	Kind getKind() const { return kind; }
	std::string getName() const { return name; }

    bool operator == (const Type* other) {
		// getKind()와 getName()이 모두 같은지 비교
        return this->kind == other->getKind() && this->name == other->getName();
	}

    // Ÿ�� �񱳸� ���� �Լ�
    virtual bool equals(const Type* other) {
        return this == other;
    }

    bool isTopType() const {
        // 예: Any 타입이 최상위 타입인 경우
        return getName() == "Any";
	}

    bool hasSuperClass(const Type* other) {
        for (auto base : baseTypes) {
            if (base == other) return true;
            // 재귀적으로 상위 클래스 검사
            if (base->hasSuperClass(other)) return true;
        }
        return false;
	}

    bool structuralCheck(const Type* subType, const Type* superType) {
        // TODO: 구조적 서브타입 검사 구현
        // 예: superType의 모든 필드/메서드가 subType에 존재하고 타입 호환되는지 확인
        return false; // 기본 구현 (구현 필요)
	}

    bool checkFunctionSubtype(const Type* other);

    bool checkGenericSubtype(const Type* other) {
		// TODO: 제네릭 타입 서브타입 검사 구현
        return false;
    }

    bool checkBasicConversion(const Type* fromType, const Type* toType) {
		if (fromType->getName() == "Int" && toType->getName() == "Float") return true;
		if (fromType->getName() == "Int" && toType->getName() == "Double") return true;
		if (fromType->getName() == "Float" && toType->getName() == "Double") return true;
		return false;
    }

    // ����Ÿ�� �˻� �Լ�
    virtual bool isSubtypeOf(std::vector<Type*>& others) {
        for (auto other : others) {
            if (isSubtypeOf(other)) return true;
        }
        return false;
	}

    virtual bool isSubtypeOf(const Type* other);

	// int, float, double, char, string, unit형인지 체크하는 함수입니다.
	bool isBasicType() const {
		return kind == Kind::BASIC || kind == Kind::GENERIC;
	}

    // class형인지 체크하는 함수입니다.
	bool isClassType() const {
		return kind == Kind::CLASS;
	}

	// function형인지 체크하는 함수입니다.
	bool isFunctionType() const {
		return kind == Kind::FUNCTION;
	}

    bool isIntegerTy() const {
		return this->isBasicType() && (name == "Int" || name == "Byte" || name == "Short");
    }

	bool isCharTy() const {
		return this->isBasicType() && name == "Char";
	}

    bool isFloatTy() const {
        return this->isBasicType() && name == "Float";
    }

	bool isDoubleTy() const {
		return this->isBasicType() && name == "Double";
	}

	bool isStringTy() const {
        // string은 basic type인가?
		return this->isBasicType() && name == "String";
	}

	bool isVoidTy() const {
		return this->isBasicType() && name == "Unit";
	}
};

// �⺻ Ÿ��
class BasicType : public Type, public std::enable_shared_from_this<BasicType> {
public:
	BasicType() : Type(Kind::BASIC, "basic") {}
    BasicType(const std::string& name, std::shared_ptr<Type> parentType = nullptr)
        : Type(Kind::BASIC, name, parentType) {}

    bool equals(const Type* other) override {
        if (other->getKind() != Kind::BASIC) return false;
        return getName() == other->getName();
    }
};

class ClassType : public Type, public std::enable_shared_from_this<ClassType> {
public:
	ClassType() : Type(Kind::CLASS, "class") {}
    ClassType(const std::string& name, std::shared_ptr<Type> parentType = nullptr)
        : Type(Kind::CLASS, name, parentType) {}

    bool equals(const Type* other) override {
        if (other->getKind() != Kind::CLASS) return false;
        return getName() == other->getName();
    }
};

class FunctionType : public Type, public std::enable_shared_from_this<FunctionType> {
public:
    std::vector<std::unique_ptr<Type>> parameterTypes;
    std::unique_ptr<Type> returnType;

	FunctionType() : Type(Kind::FUNCTION, "function") {}
    FunctionType(const std::vector<Type*> parameterTypes, Type* returnType)
        : Type(Kind::FUNCTION, "function") {
        this->returnType = std::unique_ptr<Type>(returnType);
        for (auto pt : parameterTypes) {
            this->parameterTypes.push_back(std::unique_ptr<Type>(pt));
        }
    }

    bool equals(const Type* other) override {
        if (other->getKind() != Kind::FUNCTION) return false;
        auto otherFuncType = (FunctionType*)other;
        if (!returnType->equals(otherFuncType->returnType.get())) return false;
        if (parameterTypes.size() != otherFuncType->parameterTypes.size()) return false;
        for (size_t i = 0; i < parameterTypes.size(); ++i) {
            if (!parameterTypes[i]->equals(otherFuncType->parameterTypes[i].get())) return false;
        }
        return true;
    }
};

// 알 수 없는 타입: codeGen에서 추정하고, 추정이 안되면 오류 출력
class UnknownType : public Type, public std::enable_shared_from_this<UnknownType> {
public:
    UnknownType()
        : Type(Kind::UNKNOWN, "unknown") {}

    bool equals(const Type* other) override {
        return false;
    }
};

class GenericType : public Type, public std::enable_shared_from_this<GenericType> {
public:
    std::unique_ptr<Type> baseType;  // �⺻ Ÿ�� (��: Array)
    std::vector<std::unique_ptr<Type>> typeArguments;  // Ÿ�� ���� (��: [String])

	GenericType() : Type(Kind::GENERIC, "generic") {}
    GenericType(Type* baseType, const std::vector<Type*>& typeArguments)
        : Type(Kind::GENERIC, baseType->getName()) {
        this->baseType = std::unique_ptr<Type>(baseType);
        for (auto pt : typeArguments) {
            this->typeArguments.push_back(std::unique_ptr<Type>(pt));
        }
    }
    GenericType(GenericType* other)
        : Type(Kind::GENERIC, other->baseType->getName()) {
        this->baseType = std::unique_ptr<Type>(other->baseType.get());
        for (const auto& arg : other->typeArguments) {
            this->typeArguments.push_back(std::unique_ptr<Type>(arg.get()));
        }
	}

    bool equals(const Type* other) override {
        if (other->getKind() != Kind::GENERIC) return false;
        auto otherGeneric = (GenericType*)other;
        if (!baseType->equals(otherGeneric->baseType.get())) return false;
        if (typeArguments.size() != otherGeneric->typeArguments.size()) return false;
        for (size_t i = 0; i < typeArguments.size(); ++i) {
            if (!typeArguments[i]->equals(otherGeneric->typeArguments[i].get())) return false;
        }
        return true;
    }

    bool isSubtypeOf(const Type* other) override {
        if (equals(other)) return true;
        // �߰����� ����Ÿ�� ������ ���⿡ ������ �� �ֽ��ϴ�.
        return false;
    }
};
