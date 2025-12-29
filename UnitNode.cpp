#include "UnitNode.h"
#include "ASTVisitor.h"

void UnitNode::accept(ASTVisitor& visitor) {
    visitor.visit(*this);
}