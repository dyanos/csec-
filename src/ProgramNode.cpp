#include "ProgramNode.h"
#include "ASTVisitor.h"
#include "FunctionDeclarationNode.h"

void ProgramNode::accept(ASTVisitor& visitor) {
    visitor.visit(*this);
}

llvm::Value* ProgramNode::codegen() {
    // Declare every top-level function prototype before emitting any body, so a function can call
    // another that is declared later in the file (forward references and mutual recursion).
    for (auto& stmt : statements) {
        if (auto* function = dynamic_cast<FunctionDeclarationNode*>(stmt.get())) {
            function->declarePrototype();
        }
    }

    llvm::Value* last = nullptr;
    for (auto& stmt : statements) {
        last = stmt->codegen();
    }
    return last;
}
