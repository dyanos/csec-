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

std::unique_ptr<Type> Type::makeFunction(std::unique_ptr<Type> ret, const std::vector<std::unique_ptr<Type>>& params) {
	return std::make_unique<Type>(Type::Kind::FUNCTION, "function");
}

bool Type::checkFunctionSubtype(const std::unique_ptr<Type>& other) {
    auto otherFuncType = (FunctionType*)(other.get());
    if (!otherFuncType) return false;
    // �Ű����� ���� �˻�
    if (this->paramTypes.size() !=
        otherFuncType->paramTypes.size()) return false;
    // �Ű����� Ÿ�� �ݰ��� �˻�
    for (size_t i = 0; i < this->paramTypes.size(); ++i) {
        if (!otherFuncType->paramTypes[i]->isSubtypeOf(this->paramTypes[i])) {
            return false;
        }
    }
    // ��ȯŸ�� ���� �˻�
    if (!this->returnType->isSubtypeOf(otherFuncType->returnType)) {
        return false;
    }
    return true;
}

bool Type::isSubtypeOf(const std::unique_ptr<Type>& other) {
    // 1. ���� Ÿ���̸� true (�ݻ缺)
    if (*this == other) return true;

    // 2. other�� ������(type) �Ǵ� �ֻ��� Ÿ�ԡ�(��: Any)��� true
    if (other->isTopType()) return true;

    // 3. kind�� �ٸ��� ��κ� false (������ ���� ����: ������ �⺻���� ��ȣ ��ȯ)
    if (getKind() != other->getKind()) {
        // ���� ó��: ������ �迭 Ÿ���̶�� elementType �� etc
        // �Ǵ� BASIC Ÿ�԰��� �Ϲ��� ��ȯ ��� ��
    }

    // 4. kind���� ���� �˻�
    switch (getKind()) {
    case Kind::CLASS:
    case Kind::STRUCT:
        // ������: this->name�� other->name�� ���ų� this�� ���� Ŭ���� �߿� other->name�� �ִ�
        if (this->hasSuperClass(other)) return true;
        // ������: other �ʵ�/�޼��尡 ��� this�� �����ϰ� Ÿ�� ȣȯ�̸� true
        if (structuralCheck(other)) return true;
        return false;

    case Kind::FUNCTION:
        // �Լ� Ÿ�� A��B �� C��D �� ����Ÿ���̷���:
        // �Ű����� Ÿ���� �ݰ���(�Ű��������� Cparam_i <: Aparam_i)�̰�
        // ��ȯŸ���� ����(Areturn <: Dreturn)
        return this->checkFunctionSubtype(other);

    case Kind::ARRAY:
        // ���� ���� Ȥ�� �Ұ���depending on ���
        return this->elementType->isSubtypeOf(other->elementType) && this->arraySize == other->arraySize;

    case Kind::POINTER:
    {
        // �� ���� ���� ����Ÿ�� ���谡 �޶���
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
        // ���׸� Ÿ���� ��� Ÿ�� ���ں� variance �˻� �ʿ�
        return this->checkGenericSubtype(other);

    case Kind::BASIC:
        // ��: int <: float ����ϸ� Ư�� �� ����
        return checkBasicConversion(other);

    default:
        return false;
    }
}