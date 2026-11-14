#pragma once

#include <memory>
#include <vector>

#include "ast.h"

// A dictionary literal: `{key: value, ...}` (Python-style), or `{}` for an empty dictionary.
// With `isSet`, a set literal `{a, b, ...}` (Set<T>): the elements are in `keys`, `values` is empty.
// An empty `{}` initializing a `Set<T>` declaration is an empty set.
// Its type is Dict<K, V>, inferred from the entries: every key must unify to one key type K and every
// value to one value type V (see unifyDictElementTypes). When the literal initializes a declaration
// with an explicit `Dict<K, V>` annotation, the type checker stores that type in `type`, and the
// entries are converted to it (this is also how an empty `{}` gets its type).
class DictLiteralNode : public ASTNode {
public:
    std::vector<std::unique_ptr<ASTNode>> keys;
    std::vector<std::unique_ptr<ASTNode>> values;
    bool isSet = false;

    DictLiteralNode() {
        nodeType = ASTNodeType::DICT_LITERAL;
    }
    DictLiteralNode(const DictLiteralNode& other) {
        nodeType = ASTNodeType::DICT_LITERAL;
        for (const auto& key : other.keys) keys.push_back(key ? key->clone() : nullptr);
        for (const auto& value : other.values) values.push_back(value ? value->clone() : nullptr);
        isSet = other.isSet;
        if (other.type) type = other.type->clone();
    }
    DictLiteralNode& operator=(const DictLiteralNode& other) = delete;
    ~DictLiteralNode() override = default;

    void accept(ASTVisitor& visitor) override;
    llvm::Value* codegen() override;
    std::unique_ptr<Type> getType() override;
    std::unique_ptr<ASTNode> clone() override {
        return std::make_unique<DictLiteralNode>(*this);
    }

    // Why getType() could not infer a type (empty literal, mismatched keys/values, ...).
    std::string inferenceError();
};
