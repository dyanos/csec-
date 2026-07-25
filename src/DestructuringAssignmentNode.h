#pragma once

#include <vector>
#include <memory>
#include <string>
#include "ast.h"

// `a, b, c = f()` (also `a, _ = f()`). Binds each destructuring target to the corresponding element
// of a tuple-typed RHS, transferring ownership. A target named "_" ignores its slot (the value is
// still materialized and then destroyed). Targets are new local bindings in the MVP.
class DestructuringAssignmentNode : public ASTNode {
public:
    struct Target {
        std::string name;      // "_" means ignore
        bool isMutable = false;
    };
    std::vector<Target> targets;
    std::unique_ptr<ASTNode> value;   // the tuple-producing RHS (typically a call)

    DestructuringAssignmentNode() {
        nodeType = ASTNodeType::DESTRUCTURING_ASSIGNMENT;
    }
    DestructuringAssignmentNode(const DestructuringAssignmentNode& other) {
        targets = other.targets;
        value = other.value ? other.value->clone() : nullptr;
        nodeType = ASTNodeType::DESTRUCTURING_ASSIGNMENT;
    }
    virtual ~DestructuringAssignmentNode() = default;

    void accept(ASTVisitor& visitor) override;
    llvm::Value* codegen() override;
    std::unique_ptr<Type> getType() override;
    std::unique_ptr<ASTNode> clone() override {
        return std::make_unique<DestructuringAssignmentNode>(*this);
    }
};
