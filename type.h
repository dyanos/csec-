// type.h

#pragma once

#include <string>
#include <vector>
#include <memory>


class Type {
public:
    // VARIABLE에 대해서는 검토 필요
    enum Kind { UNKNOWN=-1, BASIC=0, POINTER, ARRAY, STRUCT, CLASS, FUNCTION, GENERIC, VARIABLE };

private:
    Kind kind;

    std::vector<std::unique_ptr<Type>> baseTypes; // 다중 상속 지원을 위한 기반 타입들
    // 예: BASIC이면 이름("int","float" 등)
    std::string name;
    // STRUCT/CLASS이면 멤버 필드맵
    std::vector<std::pair<std::string, std::unique_ptr<Type>>> fields;
    // FUNCTION이면 반환타입 + 매개타입 리스트
    std::unique_ptr<Type> returnType;
    std::vector<std::unique_ptr<Type>> paramTypes;
    // 배열이면 elementType + size
    std::unique_ptr<Type> elementType;
    int arraySize = 0;
    // 기타 제네릭이면 타입인자 리스트 등
    std::vector<std::unique_ptr<Type>> typeArgs;

public:
	Type() : Type(Kind::UNKNOWN, "unknown") {}
    Type(Kind kind, const std::string& name)
		: kind(kind), name(name) {
	}
    Type(Kind kind, const std::string& name, std::unique_ptr<Type>& parentType)
        : kind(kind), name(name) {
        if (parentType) {
            this->baseTypes.push_back(parentType->clone());
        }
    }
    Type(Type* type)
        : kind(type->kind), name(type->name),
          returnType(std::move(type->returnType)),
          elementType(std::move(type->elementType)),
          arraySize(type->arraySize) {
        for (auto& b : type->baseTypes) {
            this->baseTypes.push_back(b->clone());
        }
        for (auto& f : type->fields) {
            this->fields.push_back({ f.first, f.second->clone() });
        }
        for (auto& p : type->paramTypes) {
            this->paramTypes.push_back(p->clone());
        }
        for (auto& t : type->typeArgs) {
            this->typeArgs.push_back(t->clone());
		}

	}

    virtual ~Type() = default;

    // 생성자들 및 접근자
    static std::unique_ptr<Type> makeBasic(const std::string& name);
    static std::unique_ptr<Type> makePointer(std::unique_ptr<Type> base);
    static std::unique_ptr<Type> makeArray(std::unique_ptr<Type> base, int size);
    static std::unique_ptr<Type> makeStruct(const std::string& name,
        const std::vector<std::pair<std::string, std::unique_ptr<Type>>>& fields);
    static std::unique_ptr<Type> makeFunction(std::unique_ptr<Type> ret, const std::vector<std::unique_ptr<Type>>& params);

	Kind getKind() const { return kind; }
	std::string getName() const { return name; }

    bool operator == (const std::unique_ptr<Type>& other) {
		// getKind()와 getName()이 모두 같은지 비교
        return this->kind == other->getKind() && this->name == other->getName();
	}

    // Ÿ�� �񱳸� ���� �Լ�
    virtual bool equals(const std::unique_ptr<Type>& other) {
        return *this == std::unique_ptr<Type>(other.get());
    }

    bool isTopType() const {
        // 예: Any 타입이 최상위 타입인 경우
        return getName() == "Any";
	}

    bool hasSuperClass(const std::unique_ptr<Type>& other) const {
        for (auto& base : this->baseTypes) {
            if (*base == std::unique_ptr<Type>(other.get())) return true;
            // 재귀적으로 상위 클래스 검사
            if (base->hasSuperClass(other)) return true;
        }
        return false;
	}

    bool structuralCheck(const std::unique_ptr<Type>& superType) {
        // TODO: 구조적 서브타입 검사 구현
        // 예: superType의 모든 필드/메서드가 subType에 존재하고 타입 호환되는지 확인
        return false; // 기본 구현 (구현 필요)
	}

    bool checkFunctionSubtype(const std::unique_ptr<Type>& other);

    bool checkGenericSubtype(const std::unique_ptr<Type>& other) {
		// TODO: 제네릭 타입 서브타입 검사 구현
        return false;
    }

    bool checkBasicConversion(const std::unique_ptr<Type>& toType) {
		if (this->getName() == "Int" && toType->getName() == "Float") return true;
		if (this->getName() == "Int" && toType->getName() == "Double") return true;
		if (this->getName() == "Float" && toType->getName() == "Double") return true;
		return false;
    }

    // ����Ÿ�� �˻� �Լ�
    virtual bool isSubtypeOf(std::vector<std::unique_ptr<Type>>& others) {
        for (auto& other : others) {
            if (isSubtypeOf(other)) return true;
        }
        return false;
	}

    virtual bool isSubtypeOf(const std::unique_ptr<Type>& other);

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
    virtual std::unique_ptr<Type> clone() {
        return std::make_unique<Type>(this);
    }
};

// �⺻ Ÿ��
class BasicType : public Type {
public:
	BasicType() : Type(Kind::BASIC, "basic") {}
    BasicType(const std::string& name)
        : Type(Kind::BASIC, name) {
	}
    BasicType(const std::string& name, std::unique_ptr<Type>& parentType)
        : Type(Kind::BASIC, name, parentType) {}

    bool equals(const std::unique_ptr<Type>& other) override {
        if (other->getKind() != Kind::BASIC) return false;
        return getName() == other->getName();
    }
};

class ClassType : public Type {
public:
	ClassType() : Type(Kind::CLASS, "class") {}
    ClassType(const std::string& name)
        : Type(Kind::CLASS, name) {
    }
    ClassType(const std::string& name, std::unique_ptr<Type>& parentType)
        : Type(Kind::CLASS, name, parentType) {}

    bool equals(const std::unique_ptr<Type>& other) override {
        if (other->getKind() != Kind::CLASS) return false;
        return getName() == other->getName();
    }
};

class FunctionType : public Type {
public:
    std::vector<std::unique_ptr<Type>> parameterTypes;
    std::unique_ptr<Type> returnType;

	FunctionType() : Type(Kind::FUNCTION, "function") {}
    FunctionType(std::string& name) : Type(Kind::FUNCTION, name) {
    }
    FunctionType(std::vector<std::unique_ptr<Type>>& parameterTypes, std::unique_ptr<Type>& returnType)
        : Type(Kind::FUNCTION, "function") {
        this->returnType = std::move(returnType);
        for (auto& pt : parameterTypes) {
            this->parameterTypes.push_back(pt->clone());
        }
    }
    FunctionType(FunctionType* other) : Type(Kind::FUNCTION, "function") {
        this->returnType = std::move(other->returnType);
        for (auto& pt : other->parameterTypes) {
            this->parameterTypes.push_back(pt->clone());
        }
    }

    bool equals(const std::unique_ptr<Type>& other) override {
        if (other->getKind() != Kind::FUNCTION) return false;
        auto otherFuncType = (FunctionType*)other.get();
        if (!returnType->equals(otherFuncType->returnType)) return false;
        if (parameterTypes.size() != otherFuncType->parameterTypes.size()) return false;
        for (size_t i = 0; i < parameterTypes.size(); ++i) {
            if (!parameterTypes[i]->equals(otherFuncType->parameterTypes[i])) return false;
        }
        return true;
    }

    std::unique_ptr<Type> clone() override {
        return std::make_unique<FunctionType>(this);
    }
};

// 알 수 없는 타입: codeGen에서 추정하고, 추정이 안되면 오류 출력
class UnknownType : public Type {
public:
    UnknownType()
        : Type(Kind::UNKNOWN, "unknown") {}

    bool equals(const std::unique_ptr<Type>& other) override {
        return false;
    }
};

class GenericType : public Type {
public:
    std::unique_ptr<Type> baseType;  // �⺻ Ÿ�� (��: Array)
    std::vector<std::unique_ptr<Type>> typeArguments;  // Ÿ�� ���� (��: [String])

	GenericType() : Type(Kind::GENERIC, "generic") {}
    GenericType(std::unique_ptr<Type>& baseType, const std::vector<std::unique_ptr<Type>>& typeArguments)
        : Type(Kind::GENERIC, baseType->getName()) {
        this->baseType = std::move(baseType);
        for (auto& pt : typeArguments) {
            this->typeArguments.push_back(pt->clone());
        }
    }
    GenericType(GenericType* other)
        : Type(Kind::GENERIC, other->baseType->getName()) {
        this->baseType = std::move(other->baseType);
        for (const auto& arg : other->typeArguments) {
            this->typeArguments.push_back(arg->clone());
        }
	}

    bool equals(const std::unique_ptr<Type>& other) override {
        if (other->getKind() != Kind::GENERIC) return false;
        auto otherGeneric = (GenericType*)other.get();
        if (!baseType->equals(otherGeneric->baseType)) return false;
        if (typeArguments.size() != otherGeneric->typeArguments.size()) return false;
        for (size_t i = 0; i < typeArguments.size(); ++i) {
            if (!typeArguments[i]->equals(otherGeneric->typeArguments[i])) return false;
        }
        return true;
    }

    bool isSubtypeOf(const std::unique_ptr<Type>& other) override {
        if (equals(other)) return true;
        // �߰����� ����Ÿ�� ������ ���⿡ ������ �� �ֽ��ϴ�.
        return false;
    }

    std::unique_ptr<Type> clone() {
        return std::make_unique<GenericType>(this);
    }
};
