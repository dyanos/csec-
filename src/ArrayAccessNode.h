#pragma once
#include "ast.h"

#include <memory>
#include <vector>

struct ArrayIndexSpec {
    bool isSlice = false;
    std::unique_ptr<ASTNode> index;
    std::unique_ptr<ASTNode> start;
    std::unique_ptr<ASTNode> end;
    std::unique_ptr<ASTNode> step;

    ArrayIndexSpec() = default;
    ArrayIndexSpec(const ArrayIndexSpec& other) {
        isSlice = other.isSlice;
        index = other.index ? other.index->clone() : nullptr;
        start = other.start ? other.start->clone() : nullptr;
        end = other.end ? other.end->clone() : nullptr;
        step = other.step ? other.step->clone() : nullptr;
    }
    ArrayIndexSpec& operator=(const ArrayIndexSpec& other) {
        if (this != &other) {
            isSlice = other.isSlice;
            index = other.index ? other.index->clone() : nullptr;
            start = other.start ? other.start->clone() : nullptr;
            end = other.end ? other.end->clone() : nullptr;
            step = other.step ? other.step->clone() : nullptr;
        }
        return *this;
    }
};

class ArrayAccessNode : public ASTNode {
public:
    ArrayAccessNode() {
        nodeType = ASTNodeType::ARRAY_ACCESS;
    }
    ArrayAccessNode(const ArrayAccessNode& other) {
        nodeType = ASTNodeType::ARRAY_ACCESS;
        array = other.array ? other.array->clone() : nullptr;
        index = other.index ? other.index->clone() : nullptr;
        for (const auto& spec : other.indices) {
            indices.push_back(std::make_unique<ArrayIndexSpec>(*spec));
        }
    }
    ArrayAccessNode& operator=(const ArrayAccessNode& other) {
        if (this != &other) {
            nodeType = ASTNodeType::ARRAY_ACCESS;
            array = other.array ? other.array->clone() : nullptr;
            index = other.index ? other.index->clone() : nullptr;
            indices.clear();
            for (const auto& spec : other.indices) {
                indices.push_back(std::make_unique<ArrayIndexSpec>(*spec));
            }
        }
        return *this;
    }

    std::unique_ptr<ASTNode> array;
    std::unique_ptr<ASTNode> index;
    std::vector<std::unique_ptr<ArrayIndexSpec>> indices;

    void accept(ASTVisitor& visitor) override;
    llvm::Value* codegen() override;
    llvm::Value* codegenElementPointer();
    std::unique_ptr<Type> getType() override {
        if (!array) return std::make_unique<UnknownType>();
        auto resolvedArrayType = array->getType();
        // Auto-deref: indexing a borrowed array/vector (`&Vector[T]` parameter) resolves against the
        // borrowed collection, so `ref[i]` has element type T.
        if (resolvedArrayType && (resolvedArrayType->getKind() == Type::Kind::BORROW ||
                                  resolvedArrayType->getKind() == Type::Kind::MUTABLE_BORROW)) {
            if (auto* bt = dynamic_cast<BorrowType*>(resolvedArrayType.get())) {
                if (bt->baseType) resolvedArrayType = bt->baseType->clone();
            }
        }
        if (!resolvedArrayType) return std::make_unique<UnknownType>();

        bool containsSlice = false;
        for (const auto& spec : indices) {
            if (spec && spec->isSlice) {
                containsSlice = true;
                break;
            }
        }

        if (resolvedArrayType->getName() == "Tensor") {
            if (containsSlice) {
                return resolvedArrayType->clone();
            }
            auto* tensorType = dynamic_cast<GenericType*>(resolvedArrayType.get());
            if (tensorType && !tensorType->typeArguments.empty() &&
                indices.size() + 1 >= tensorType->typeArguments.size()) {
                return tensorType->typeArguments[0]
                    ? tensorType->typeArguments[0]->clone()
                    : std::make_unique<BasicType>("Double");
            }
            return resolvedArrayType->clone();
        }

        Type* current = resolvedArrayType.get();
        size_t count = indices.empty() ? (index ? 1 : 0) : indices.size();
        for (size_t i = 0; i < count; ++i) {
            auto* arrayType = dynamic_cast<ArrayType*>(current);
            if (!arrayType || !arrayType->elementType) {
                break;
            }
            if (!indices.empty() && indices[i] && indices[i]->isSlice) {
                return current->clone();
            }
            current = arrayType->elementType.get();
        }
        if (current != resolvedArrayType.get()) {
            return current->clone();
        }

        auto arrayType = dynamic_cast<GenericType*>(resolvedArrayType.get());
        if (arrayType && arrayType->typeArguments.size() == 1) {
            return arrayType->typeArguments[0] ? arrayType->typeArguments[0]->clone() : std::make_unique<UnknownType>();
        }

        return std::make_unique<UnknownType>();
    }
    std::unique_ptr<ASTNode> clone() override {
        return std::make_unique<ArrayAccessNode>(*this);
    }
};
