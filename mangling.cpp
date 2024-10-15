#include "mangling.h"
#include "utils.h"

std::string Mangling::mangle(ASTNode &node) {
    // Itanium C++ Name Mangling에 따라서 구현합니다.
    // class, object, function, method에 대해서 mangling을 진행합니다.
    // 입력 node가 class, object, function, method인지를 검토 합니다.
    
    // 입력 node가 ClassDeclarationNode인지 검토합니다.
    if (node.nodeType == ASTNodeType::CLASS_DECLARATION) {
        return visit(static_cast<ClassDeclarationNode&>(node));
    } 
    else if (node.nodeType == ASTNodeType::OBJECT_DECLARATION) {
        return visit(static_cast<ObjectDeclarationNode&>(node));
    }
    else if (node.nodeType == ASTNodeType::FUNCTION_DECLARATION) {
        return visit(static_cast<FunctionDeclarationNode&>(node));
    }
    else if (node.nodeType == ASTNodeType::PARAMETER) {
        return visit(static_cast<ParameterNode&>(node));
    }
}

std::string Mangling::visit(ClassDeclarationNode &node) {
    
}

std::string Mangling::visit(ObjectDeclarationNode &node) {
}

std::string Mangling::visit(FunctionDeclarationNode &node) {
}

std::string Mangling::visit(ParameterNode &node) {
}
