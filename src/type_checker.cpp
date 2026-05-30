// type_checker.cpp

#include "type_checker.h"
#include "codegen.h"
#include "symbol.h"

#include <iostream>

#include "all_ast.h"

namespace {
bool isResolvedType(const std::unique_ptr<Type>& type) {
    return type && type->getKind() != Type::Kind::UNKNOWN;
}

bool isTensorLikeType(const std::unique_ptr<Type>& type) {
    if (!type) return false;
    const std::string name = type->getName();
    return name == "Tensor" || name.rfind("Tensor$", 0) == 0;
}

std::unique_ptr<Type> collectionElementType(const std::unique_ptr<Type>& type) {
    if (!type) return std::make_unique<UnknownType>();
    if (auto* arrType = dynamic_cast<ArrayType*>(type.get())) {
        return arrType->elementType ? arrType->elementType->clone() : std::make_unique<UnknownType>();
    }
    if (auto* genType = dynamic_cast<GenericType*>(type.get())) {
        if (genType->baseType && genType->baseType->getName() == "Array" && !genType->typeArguments.empty()) {
            return genType->typeArguments[0] ? genType->typeArguments[0]->clone() : std::make_unique<UnknownType>();
        }
    }
    return std::make_unique<UnknownType>();
}

FunctionSymbol* ensureFunctionSymbol(FunctionDeclarationNode& node) {
    auto& cg = CodeGenerator::getInstance();
    auto* existing = cg.symbolTable.lookupFunction(node.name, {});
    if (existing) {
        return existing;
    }

    auto symbol = std::make_unique<FunctionSymbol>(node.name, node.getType(), nullptr, false, SymbolType::FUNCTION);
    auto* raw = symbol.get();
    cg.symbolTable.addSymbol(node.name, std::move(symbol));
    return raw;
}

TemplateSymbol* ensureTemplateSymbol(TemplateDeclarationNode& node) {
    auto& cg = CodeGenerator::getInstance();

    std::string symbolName;
    if (auto* functionDecl = dynamic_cast<FunctionDeclarationNode*>(node.declaration.get())) {
        symbolName = functionDecl->name;
    }
    else if (auto* classDecl = dynamic_cast<ClassDeclarationNode*>(node.declaration.get())) {
        symbolName = classDecl->name;
    }
    else {
        return nullptr;
    }

    auto* existing = cg.symbolTable.lookup(symbolName);
    if (existing && existing->symbolType == SymbolType::TEMPLATE) {
        auto* templateSymbol = dynamic_cast<TemplateSymbol*>(existing);
        if (templateSymbol) {
            templateSymbol->typeParameters = node.typeParameters;
            templateSymbol->templateParams.clear();
            for (const auto& param : node.templateParams) {
                templateSymbol->templateParams.push_back(TemplateParam(param));
            }
            templateSymbol->declaration = node.declaration ? node.declaration->clone() : nullptr;
        }
        return templateSymbol;
    }

    auto symbol = std::make_unique<TemplateSymbol>();
    symbol->name = symbolName;
    symbol->typeParameters = node.typeParameters;
    for (const auto& param : node.templateParams) {
        symbol->templateParams.push_back(TemplateParam(param));
    }
    symbol->declaration = node.declaration ? node.declaration->clone() : nullptr;

    auto* raw = symbol.get();
    cg.symbolTable.addSymbol(symbolName, std::move(symbol));
    return raw;
}

ClassSymbol* ensureClassSymbol(ClassDeclarationNode& node) {
    auto& cg = CodeGenerator::getInstance();
    auto* existing = cg.symbolTable.lookupClass(node.name);
    if (existing) {
        return existing;
    }

    auto* classType = llvm::StructType::create(cg.context, node.name);
    auto symbol = std::make_unique<ClassSymbol>(node.name, classType, node.superClassName);
    auto* raw = symbol.get();
    cg.symbolTable.addSymbol(node.name, std::move(symbol));
    return raw;
}

void bindVariable(const std::string& name, const std::unique_ptr<Type>& type, bool isMutable, SymbolType symbolType = SymbolType::VARIABLE) {
    auto& cg = CodeGenerator::getInstance();
    cg.symbolTable.addSymbol(name, std::make_unique<Symbol>(name, type ? type->clone() : std::make_unique<UnknownType>(), nullptr, isMutable, symbolType));
}

bool isOwnedMoveCheckedType(const Type* type) {
    return type && type->getKind() == Type::Kind::BOX;
}

bool isBorrowType(const Type* type) {
    return type && (type->getKind() == Type::Kind::BORROW || type->getKind() == Type::Kind::MUTABLE_BORROW);
}

bool canInitializeOwnershipType(const Type* declaredType, const Type* initType) {
    if (!declaredType || !initType) return false;
    if (auto* boxType = dynamic_cast<const BoxType*>(declaredType)) {
        return boxType->baseType && boxType->baseType->equals(*initType);
    }
    if (auto* borrowType = dynamic_cast<const BorrowType*>(declaredType)) {
        if (initType->getKind() != declaredType->getKind()) return false;
        auto* initBorrow = dynamic_cast<const BorrowType*>(initType);
        return initBorrow && borrowType->baseType && initBorrow->baseType &&
               borrowType->baseType->equals(*initBorrow->baseType);
    }
    return false;
}

std::unique_ptr<Type> unwrappedOwnershipType(const Type* type) {
    if (!type) return std::make_unique<UnknownType>();
    if (auto* boxType = dynamic_cast<const BoxType*>(type)) {
        return boxType->baseType ? boxType->baseType->clone() : std::make_unique<UnknownType>();
    }
    if (auto* borrowType = dynamic_cast<const BorrowType*>(type)) {
        return borrowType->baseType ? borrowType->baseType->clone() : std::make_unique<UnknownType>();
    }
    if (auto* unsafePointerType = dynamic_cast<const UnsafePointerType*>(type)) {
        return unsafePointerType->baseType ? unsafePointerType->baseType->clone() : std::make_unique<UnknownType>();
    }
    return const_cast<Type*>(type)->clone();
}

std::string identifierName(ASTNode* node) {
    if (auto* id = dynamic_cast<IdentifierNode*>(node)) {
        return id->value;
    }
    return "";
}

bool isMoveExpression(ASTNode* node) {
    auto* prefix = dynamic_cast<PrefixExpressionNode*>(node);
    return prefix && prefix->op == "<-";
}

bool isBorrowExpression(ASTNode* node, bool* isMutableBorrow = nullptr) {
    auto* prefix = dynamic_cast<PrefixExpressionNode*>(node);
    if (!prefix) return false;
    if (prefix->op == "&" || prefix->op == "&mut") {
        if (isMutableBorrow) *isMutableBorrow = prefix->op == "&mut";
        return true;
    }
    return false;
}

std::string movedOrBorrowedIdentifier(ASTNode* node) {
    if (auto* prefix = dynamic_cast<PrefixExpressionNode*>(node)) {
        return identifierName(prefix->expression.get());
    }
    return identifierName(node);
}
}

void TypeChecker::reportError(const std::string& message) {
    ++errorCount;
    std::cerr << message << std::endl;
}

void TypeChecker::enterOwnershipScope() {
    ownershipScopes.emplace_back();
}

void TypeChecker::exitOwnershipScope() {
    if (!ownershipScopes.empty()) {
        ownershipScopes.pop_back();
    }
}

void TypeChecker::declareOwnership(const std::string& name, const std::unique_ptr<Type>& type) {
    if (ownershipScopes.empty()) {
        enterOwnershipScope();
    }
    OwnershipState state;
    state.owned = type && isOwnedMoveCheckedType(type.get());
    ownershipScopes.back()[name] = state;
}

TypeChecker::OwnershipState* TypeChecker::findOwnership(const std::string& name) {
    for (auto it = ownershipScopes.rbegin(); it != ownershipScopes.rend(); ++it) {
        auto found = it->find(name);
        if (found != it->end()) {
            return &found->second;
        }
    }
    return nullptr;
}

void TypeChecker::checkIdentifierUse(const std::string& name) {
    auto* state = findOwnership(name);
    if (state && state->owned && state->moved) {
        reportError("Type error: use of moved value '" + name + "'");
    }
}

void TypeChecker::markMoved(const std::string& name) {
    auto* state = findOwnership(name);
    if (!state) return;
    if (state->immutableBorrows > 0 || state->mutableBorrowed) {
        reportError("Type error: cannot move '" + name + "' while it is borrowed");
    }
    if (state->owned) {
        state->moved = true;
    }
}

void TypeChecker::markBorrowed(const std::string& name, bool isMutableBorrow) {
    auto* state = findOwnership(name);
    if (!state) return;
    if (state->owned && state->moved) {
        reportError("Type error: cannot borrow moved value '" + name + "'");
        return;
    }
    if (isMutableBorrow) {
        auto* symbol = CodeGenerator::getInstance().symbolTable.lookup(name);
        if (symbol && !symbol->isMutable) {
            reportError("Type error: cannot mutably borrow immutable value '" + name + "'");
        }
        if (state->immutableBorrows > 0) {
            reportError("Type error: cannot mutably borrow '" + name + "' while immutable borrow exists");
        }
        if (state->mutableBorrowed) {
            reportError("Type error: cannot mutably borrow '" + name + "' more than once");
        }
        state->mutableBorrowed = true;
    }
    else {
        if (state->mutableBorrowed) {
            reportError("Type error: cannot immutably borrow '" + name + "' while mutable borrow exists");
        }
        ++state->immutableBorrows;
    }
}

void TypeChecker::releaseBorrow(const std::string& name, bool isMutableBorrow) {
    auto* state = findOwnership(name);
    if (!state) return;
    if (isMutableBorrow) {
        state->mutableBorrowed = false;
    }
    else if (state->immutableBorrows > 0) {
        --state->immutableBorrows;
    }
}

void TypeChecker::checkFunctionArguments(const std::vector<std::unique_ptr<ASTNode>>& arguments,
                                         const std::vector<std::unique_ptr<Type>>& parameterTypes,
                                         const std::string& callName) {
    for (size_t i = 0; i < arguments.size(); ++i) {
        ASTNode* arg = arguments[i].get();
        Type* paramType = i < parameterTypes.size() && parameterTypes[i] ? parameterTypes[i].get() : nullptr;
        bool mutableBorrowArg = false;
        const bool argIsMove = isMoveExpression(arg);
        const bool argIsBorrow = isBorrowExpression(arg, &mutableBorrowArg);
        auto argType = arg ? arg->getType() : std::make_unique<UnknownType>();

        if (paramType && isOwnedMoveCheckedType(paramType)) {
            if (!argIsMove) {
                reportError("Type error: ownership transfer to '" + callName + "' requires '<-'");
            }
        }
        else if (paramType && paramType->getKind() == Type::Kind::BORROW) {
            if (!argIsBorrow || mutableBorrowArg) {
                reportError("Type error: argument " + std::to_string(i + 1) + " to '" + callName + "' requires '&'");
            }
        }
        else if (paramType && paramType->getKind() == Type::Kind::MUTABLE_BORROW) {
            if (!argIsBorrow || !mutableBorrowArg) {
                reportError("Type error: argument " + std::to_string(i + 1) + " to '" + callName + "' requires '&mut'");
            }
        }
        else if (argIsMove) {
            reportError("Type error: '<-' argument to '" + callName + "' requires an owning parameter");
        }
        else if (argType && isOwnedMoveCheckedType(argType.get())) {
            reportError("Type error: ownership transfer to '" + callName + "' requires '<-'");
        }

        if (argIsMove) {
            markMoved(movedOrBorrowedIdentifier(arg));
        }
    }
}

void TypeChecker::checkTypeResolved(const std::unique_ptr<Type>& type, const std::string& context) {
    if (!isResolvedType(type)) {
        reportError("Type error: Failed to resolve type for " + context);
    }
}

void TypeChecker::visit(VariableDeclarationNode& node) {
    if (node.initializer) {
        node.initializer->accept(*this);
        auto initType = node.initializer->getType();
        if (!isResolvedType(initType)) {
            if (auto* ifNode = dynamic_cast<IfStatementNode*>(node.initializer.get())) {
                auto thenType = ifNode->thenBlock ? ifNode->thenBlock->getType() : std::make_unique<UnknownType>();
                auto elseType = ifNode->elseBlock ? ifNode->elseBlock->getType() : std::make_unique<UnknownType>();
                if (isResolvedType(thenType) && isResolvedType(elseType) && thenType->equals(elseType)) {
                    initType = thenType->clone();
                }
                else if (isResolvedType(thenType)) {
                    initType = thenType->clone();
                }
                else if (isResolvedType(elseType)) {
                    initType = elseType->clone();
                }
            }
            else if (auto* matchNode = dynamic_cast<MatchExpressionNode*>(node.initializer.get())) {
                for (const auto& casePair : matchNode->cases) {
                    if (!casePair.second) {
                        continue;
                    }
                    auto caseType = casePair.second->getType();
                    if (isResolvedType(caseType)) {
                        initType = caseType ? caseType->clone() : std::make_unique<UnknownType>();
                        break;
                    }
                }
            }
        }

        if (node.type) {
            if (!node.hasExplicitType && isResolvedType(initType)) {
                node.type = initType ? initType->clone() : std::make_unique<UnknownType>();
            }
            else if (!isResolvedType(node.type) && isResolvedType(initType)) {
                node.type = initType ? initType->clone() : std::make_unique<UnknownType>();
            }
            else if (isResolvedType(node.type) && isResolvedType(initType) &&
                     !node.type->equals(initType) &&
                     !((node.type->getName() == "Bool" && initType->getName() == "Boolean") ||
                       (node.type->getName() == "Boolean" && initType->getName() == "Bool")) &&
                     !(node.type->isIntegerTy() && initType->isIntegerTy()) &&
                     !(node.type->isDoubleTy() && initType->isFloatTy()) &&
                     !((node.type->isDoubleTy() || node.type->getName() == "Real") &&
                       (initType->isIntegerTy() || initType->isFloatTy() || initType->isDoubleTy())) &&
                     !canInitializeOwnershipType(node.type.get(), initType.get()) &&
                     !(isTensorLikeType(node.type) && isTensorLikeType(initType)) &&
                     !initType->isSubtypeOf(node.type) &&
                     !node.type->isSubtypeOf(initType)) {
                reportError(
                    "Type error: Variable '" + node.name + "' declared as '" +
                    node.type->getName() + "' but initialized with '" + initType->getName() + "'");
            }
        }
        else {
            node.type = initType ? initType->clone() : std::make_unique<UnknownType>();
        }
    }
    else if (!node.type) {
        reportError("Type error: Variable '" + node.name + "' has no type and no initializer");
        node.type = std::make_unique<UnknownType>();
    }

    bindVariable(node.name, node.type, node.isMutable, node.isField ? SymbolType::FIELD : SymbolType::VARIABLE);
    declareOwnership(node.name, node.type);
}

void TypeChecker::visit(FunctionDeclarationNode& node) {
    auto& cg = CodeGenerator::getInstance();
    auto* functionSymbol = ensureFunctionSymbol(node);
    auto* savedCurrentSymbol = cg.symbolTable.getCurrentSymbol();
    cg.symbolTable.saveCurrentSymbol();
    cg.symbolTable.setCurrentSymbol(functionSymbol);
    cg.symbolTable.enterScope();
    enterOwnershipScope();

    for (auto& param : node.parameters) {
        if (param) {
            param->accept(*this);
            auto* parameterNode = dynamic_cast<ParameterNode*>(param.get());
            if (parameterNode) {
                bindVariable(parameterNode->name, parameterNode->type, false);
                declareOwnership(parameterNode->name, parameterNode->type);
            }
        }
    }

    if (node.isUnsafe) {
        ++unsafeContextDepth;
    }

    if (node.body) {
        node.body->accept(*this);
        auto bodyType = node.body->getType();

        if (node.returnType) {
            if (isResolvedType(node.returnType) && isResolvedType(bodyType) &&
                !node.returnType->isVoidTy() &&
                !node.returnType->equals(bodyType) &&
                !(isTensorLikeType(node.returnType) && isTensorLikeType(bodyType))) {
                reportError(
                    "Type error: Function '" + node.name + "' declared to return '" +
                    node.returnType->getName() + "' but returns '" + bodyType->getName() + "'");
            }
        }
        else if (isResolvedType(bodyType)) {
            node.returnType = bodyType->clone();
        }
    }

    if (node.isUnsafe) {
        --unsafeContextDepth;
    }

    exitOwnershipScope();
    cg.symbolTable.exitScope();
    cg.symbolTable.popCurrentSymbol();
    cg.symbolTable.setCurrentSymbol(savedCurrentSymbol);
}

void TypeChecker::visit(ExpressionNode& node) {
    checkTypeResolved(node.getType(), "expression");
}

void TypeChecker::visit(BinaryExpressionNode& node) {
    if (node.left) {
        node.left->accept(*this);
    }
    if (node.right) {
        node.right->accept(*this);
    }
    auto resolved = node.getType();
    if (!isResolvedType(resolved)) {
        node.type = std::make_unique<BasicType>("Real");
        return;
    }
}

void TypeChecker::visit(ProgramNode& node) {
    enterOwnershipScope();
    for (auto& stmt : node.statements) {
        if (!stmt) {
            continue;
        }

        if (auto* functionNode = dynamic_cast<FunctionDeclarationNode*>(stmt.get())) {
            ensureFunctionSymbol(*functionNode);
        }
        else if (auto* classNode = dynamic_cast<ClassDeclarationNode*>(stmt.get())) {
            ensureClassSymbol(*classNode);
        }
        else if (auto* objectNode = dynamic_cast<ObjectDeclarationNode*>(stmt.get())) {
            auto& cg = CodeGenerator::getInstance();
            if (!cg.symbolTable.lookup(objectNode->name)) {
                cg.symbolTable.addSymbol(objectNode->name, std::make_unique<NamespaceSymbol>(objectNode->name));
            }
        }
        else if (auto* templateNode = dynamic_cast<TemplateDeclarationNode*>(stmt.get())) {
            ensureTemplateSymbol(*templateNode);
        }
    }

    for (auto& stmt : node.statements) {
        if (stmt) {
            stmt->accept(*this);
        }
    }
    exitOwnershipScope();
}

void TypeChecker::visit(ClassDeclarationNode& node) {
    auto& cg = CodeGenerator::getInstance();
    auto* classSymbol = ensureClassSymbol(node);
    auto* savedCurrentSymbol = cg.symbolTable.getCurrentSymbol();
    cg.symbolTable.saveCurrentSymbol();
    cg.symbolTable.setCurrentSymbol(classSymbol);
    cg.symbolTable.enterScope();
    enterOwnershipScope();

    for (auto& param : node.constructorParams) {
        if (param) {
            param->accept(*this);
            auto* parameterNode = dynamic_cast<ParameterNode*>(param.get());
            if (!parameterNode) {
                continue;
            }
            bindVariable(parameterNode->name, parameterNode->type, false);
            declareOwnership(parameterNode->name, parameterNode->type);
            if (classSymbol && classSymbol->constructorParams.count(parameterNode->name) == 0) {
                classSymbol->constructorParams[parameterNode->name] =
                    std::make_unique<Symbol>(parameterNode->name, parameterNode->type ? parameterNode->type->clone() : std::make_unique<UnknownType>(), nullptr, false, SymbolType::FIELD);
            }
        }
    }
    auto* classBody = dynamic_cast<ClassBodyNode*>(node.body.get());
    if (classBody) {
        for (auto& field : classBody->fields) {
            if (!field) {
                continue;
            }
            auto* fieldNode = dynamic_cast<VariableDeclarationNode*>(field.get());
            if (!fieldNode) {
                continue;
            }
            fieldNode->accept(*this);
            if (classSymbol && classSymbol->fields.count(fieldNode->name) == 0) {
                classSymbol->fields[fieldNode->name] =
                    std::make_unique<Symbol>(fieldNode->name, fieldNode->type ? fieldNode->type->clone() : std::make_unique<UnknownType>(), nullptr, fieldNode->isMutable, SymbolType::FIELD);
            }
        }
        for (auto& method : classBody->methods) {
            if (!method) {
                continue;
            }
            auto* functionNode = dynamic_cast<FunctionDeclarationNode*>(method.get());
            if (functionNode && classSymbol && classSymbol->methods.count(functionNode->name) == 0) {
                classSymbol->methods[functionNode->name] =
                    std::make_unique<FunctionSymbol>(functionNode->name, functionNode->getType(), nullptr, false, SymbolType::METHOD);
            }
        }
        classBody->accept(*this);
    }
    else if (node.body) {
        node.body->accept(*this);
    }

    exitOwnershipScope();
    cg.symbolTable.exitScope();
    cg.symbolTable.popCurrentSymbol();
    cg.symbolTable.setCurrentSymbol(savedCurrentSymbol);
}

void TypeChecker::visit(ObjectDeclarationNode& node) {
    auto& cg = CodeGenerator::getInstance();
    auto* symbol = cg.symbolTable.lookup(node.name);
    if (!symbol) {
        cg.symbolTable.addSymbol(node.name, std::make_unique<NamespaceSymbol>(node.name));
        symbol = cg.symbolTable.lookup(node.name);
    }

    auto* savedCurrentSymbol = cg.symbolTable.getCurrentSymbol();
    cg.symbolTable.saveCurrentSymbol();
    cg.symbolTable.setCurrentSymbol(symbol);
    cg.symbolTable.enterScope();
    enterOwnershipScope();

    if (node.body) {
        node.body->accept(*this);
    }

    exitOwnershipScope();
    cg.symbolTable.exitScope();
    cg.symbolTable.popCurrentSymbol();
    cg.symbolTable.setCurrentSymbol(savedCurrentSymbol);
}

void TypeChecker::visit(IfStatementNode& node) {
    if (node.condition) {
        node.condition->accept(*this);
        checkTypeResolved(node.condition->getType(), "if condition");
    }
    if (node.thenBlock) {
        node.thenBlock->accept(*this);
    }
    if (node.elseBlock) {
        node.elseBlock->accept(*this);
    }
    node.type = node.getType();
}

void TypeChecker::visit(ForStatementNode& node) {
    auto& cg = CodeGenerator::getInstance();
    if (node.iterableExpr) {
        node.iterableExpr->accept(*this);
    }
    cg.symbolTable.enterScope();
    enterOwnershipScope();
    bindVariable(node.variable, std::make_unique<BasicType>("Int"), false);
    declareOwnership(node.variable, std::make_unique<BasicType>("Int"));
    if (node.body) {
        node.body->accept(*this);
    }
    exitOwnershipScope();
    cg.symbolTable.exitScope();
}

void TypeChecker::visit(ReturnStatementNode& node) {
    if (node.expression) {
        node.expression->accept(*this);
        checkTypeResolved(node.expression->getType(), "return expression");
    }
}

void TypeChecker::visit(BlockNode& node) {
    auto& cg = CodeGenerator::getInstance();
    cg.symbolTable.enterScope();
    enterOwnershipScope();
    if (node.isUnsafeContext) {
        ++unsafeContextDepth;
    }
    std::unique_ptr<Type> lastType = std::make_unique<UnknownType>();
    for (auto& stmt : node.statements) {
        if (stmt) {
            stmt->accept(*this);
            auto stmtType = stmt->getType();
            if (stmtType) {
                lastType = stmtType->clone();
            }
        }
    }
    node.type = lastType ? lastType->clone() : std::make_unique<UnknownType>();
    if (node.isUnsafeContext) {
        --unsafeContextDepth;
    }
    exitOwnershipScope();
    cg.symbolTable.exitScope();
}

void TypeChecker::visit(AssignmentNode& node) {
    if (node.expression) {
        node.expression->accept(*this);
    }
}

void TypeChecker::visit(ClassBodyNode& node) {
    for (auto& field : node.fields) {
        if (field) {
            field->accept(*this);
        }
    }
    for (auto& method : node.methods) {
        if (method) {
            method->accept(*this);
        }
    }
}

void TypeChecker::visit(ParameterNode& node) {
    checkTypeResolved(node.getType(), "parameter");
}

void TypeChecker::visit(MatchExpressionNode& node) {
    if (node.expression) {
        node.expression->accept(*this);
    }

    std::unique_ptr<Type> matchType = node.expression ? node.expression->getType() : std::make_unique<UnknownType>();
    std::unique_ptr<Type> resultType;

    for (auto& casePair : node.cases) {
        if (casePair.first) {
            casePair.first->accept(*this);
            auto patternType = casePair.first->getType();
            const bool isWildcard = dynamic_cast<UnitNode*>(casePair.first.get()) != nullptr;
            if (!isWildcard && matchType && patternType &&
                !patternType->equals(matchType) &&
                !patternType->isSubtypeOf(matchType) &&
                !matchType->isSubtypeOf(patternType)) {
                std::cerr << "Type error: match case pattern type mismatch" << std::endl;
                errorCount++;
            }
        }
        if (casePair.second) {
            casePair.second->accept(*this);
            auto caseResultType = casePair.second->getType();
            if (!resultType) {
                resultType = caseResultType ? caseResultType->clone() : std::make_unique<UnknownType>();
            }
            else if (caseResultType &&
                     !caseResultType->equals(resultType) &&
                     !caseResultType->isSubtypeOf(resultType) &&
                     !resultType->isSubtypeOf(caseResultType)) {
                std::cerr << "Type error: match case result type mismatch" << std::endl;
                errorCount++;
            }
        }
    }

    node.type = resultType ? resultType->clone() : std::make_unique<UnknownType>();
}

void TypeChecker::visit(RangeExpressionNode& node) {
    if (node.startExpr) {
        node.startExpr->accept(*this);
    }
    if (node.endExpr) {
        node.endExpr->accept(*this);
    }
}

void TypeChecker::visit(ImportNode& node) {
    (void)node;
}

void TypeChecker::visit(UnitNode& node) {
    (void)node;
}

void TypeChecker::visit(CallExpressionNode& node) {
    if (node.callee) {
        node.callee->accept(*this);
    }
    for (auto& arg : node.arguments) {
        if (arg) {
            arg->accept(*this);
        }
    }
    auto calleeType = node.callee ? node.callee->getType() : std::make_unique<UnknownType>();
    if (auto* functionType = dynamic_cast<FunctionType*>(calleeType.get())) {
        std::vector<std::unique_ptr<Type>> parameterTypes;
        for (const auto& parameterType : functionType->parameterTypes) {
            parameterTypes.push_back(parameterType ? parameterType->clone() : std::make_unique<UnknownType>());
        }
        checkFunctionArguments(node.arguments, parameterTypes, "call expression");
    }
    for (auto& arg : node.arguments) {
        bool mutableBorrowArg = false;
        if (isBorrowExpression(arg.get(), &mutableBorrowArg)) {
            releaseBorrow(movedOrBorrowedIdentifier(arg.get()), mutableBorrowArg);
        }
    }
    checkTypeResolved(node.getType(), "call expression");
}

void TypeChecker::visit(MethodCallNode& node) {
    if (node.object) {
        node.object->accept(*this);
    }
    for (auto& arg : node.arguments) {
        if (arg) {
            arg->accept(*this);
        }
    }
    checkTypeResolved(node.getType(), "method call");
}

void TypeChecker::visit(IdentifierNode& node) {
    checkIdentifierUse(node.value);
    auto* symbol = CodeGenerator::getInstance().symbolTable.lookup(node.value);
    if (!symbol) {
        node.type = std::make_unique<BasicType>("Real");
        return;
    }
    if (symbol->type && isResolvedType(symbol->type)) {
        return;
    }
    if (symbol->symbolType == SymbolType::NAMESPACE ||
        symbol->symbolType == SymbolType::CLASS ||
        symbol->symbolType == SymbolType::FUNCTION ||
        symbol->symbolType == SymbolType::TEMPLATE) {
        return;
    }
    checkTypeResolved(node.getType(), "identifier '" + node.value + "'");
}

void TypeChecker::visit(ValueNode& node) {
    checkTypeResolved(node.getType(), "value literal");
}

void TypeChecker::visit(FunctionCallNode& node) {
    for (auto& arg : node.arguments) {
        if (arg) {
            arg->accept(*this);
        }
    }
    std::vector<std::unique_ptr<Type>> parameterTypes;
    auto& cg = CodeGenerator::getInstance();
    if (auto* symbol = cg.symbolTable.lookup(node.functionName)) {
        if (auto* funcType = dynamic_cast<FunctionType*>(symbol->type.get())) {
            for (const auto& parameterType : funcType->parameterTypes) {
                parameterTypes.push_back(parameterType ? parameterType->clone() : std::make_unique<UnknownType>());
            }
        }
    }
    if (!parameterTypes.empty()) {
        checkFunctionArguments(node.arguments, parameterTypes, node.functionName);
    }
    for (auto& arg : node.arguments) {
        bool mutableBorrowArg = false;
        if (isBorrowExpression(arg.get(), &mutableBorrowArg)) {
            releaseBorrow(movedOrBorrowedIdentifier(arg.get()), mutableBorrowArg);
        }
    }
    checkTypeResolved(node.getType(), "function call '" + node.functionName + "'");
}

void TypeChecker::visit(ArrayAccessNode& node) {
    if (node.array) {
        node.array->accept(*this);
    }
    if (node.index) {
        node.index->accept(*this);
    }
    for (auto& spec : node.indices) {
        if (!spec) continue;
        if (spec->index) spec->index->accept(*this);
        if (spec->start) spec->start->accept(*this);
        if (spec->end) spec->end->accept(*this);
        if (spec->step) spec->step->accept(*this);
    }
    checkTypeResolved(node.getType(), "array access");
}

void TypeChecker::visit(ArrayCreationNode& node) {
    for (auto& element : node.elements) {
        if (element) {
            element->accept(*this);
        }
    }
    checkTypeResolved(node.getType(), "array creation");
}

void TypeChecker::visit(AccessFieldNode& node) {
    if (node.base) {
        node.base->accept(*this);
    }
    if (node.field) {
        node.field->accept(*this);
    }
    checkTypeResolved(node.getType(), "field access");
}

void TypeChecker::visit(ClassInstanceCreationNode& node) {
    for (auto& arg : node.arguments) {
        if (arg) {
            arg->accept(*this);
        }
    }
    checkTypeResolved(node.getType(), "class instance creation");
}

void TypeChecker::visit(ArrayCreationExpressionNode& node) {
    for (auto& sizeExpr : node.sizes) {
        if (sizeExpr) {
            sizeExpr->accept(*this);
        }
    }
    checkTypeResolved(node.getType(), "array creation expression");
}

void TypeChecker::visit(AssignmentExpressionNode& node) {
    if (node.left) {
        node.left->accept(*this);
    }
    if (node.right) {
        node.right->accept(*this);
    }
    auto rightType = node.right ? node.right->getType() : std::make_unique<UnknownType>();
    const std::string leftName = identifierName(node.left.get());
    const std::string rightName = movedOrBorrowedIdentifier(node.right.get());
    const bool rightIsMoveChecked = rightType && isOwnedMoveCheckedType(rightType.get());
    if (node.op == "<-") {
        if (!rightName.empty()) {
            markMoved(rightName);
        }
        if (!leftName.empty()) {
            auto* leftState = findOwnership(leftName);
            if (leftState) {
                leftState->moved = false;
            }
        }
    }
    else if (rightIsMoveChecked && !rightName.empty()) {
        reportError("Type error: ownership transfer requires '<-'");
    }
    checkTypeResolved(node.getType(), "assignment expression");
}

void TypeChecker::visit(UnaryExpressionNode& node) {
    if (node.expression) {
        node.expression->accept(*this);
    }
    if (node.op == "*") {
        auto exprType = node.expression ? node.expression->getType() : std::make_unique<UnknownType>();
        if (!exprType || exprType->getKind() != Type::Kind::UNSAFE_POINTER) {
            reportError("Type error: raw pointer dereference requires unsafe pointer");
        }
        else if (unsafeContextDepth == 0) {
            reportError("Type error: raw pointer dereference requires unsafe context");
        }
    }
    checkTypeResolved(node.getType(), "unary expression");
}

void TypeChecker::visit(CastingExpressionNode& node) {
    if (node.expression) {
        node.expression->accept(*this);
    }
    if (node.typeNode) {
        node.typeNode->accept(*this);
    }
    checkTypeResolved(node.getType(), "casting expression");
}

void TypeChecker::visit(PostfixExpressionNode& node) {
    if (node.expression) {
        node.expression->accept(*this);
    }
    node.type = node.expression ? node.expression->getType() : std::make_unique<UnknownType>();
    checkTypeResolved(node.type, "postfix expression");
}

void TypeChecker::visit(PrefixExpressionNode& node) {
    if (node.expression) {
        node.expression->accept(*this);
    }
    const std::string sourceName = movedOrBorrowedIdentifier(&node);
    if (node.op == "<-") {
        if (!sourceName.empty()) {
            markMoved(sourceName);
        }
    }
    else if (node.op == "&" || node.op == "&mut") {
        if (!sourceName.empty()) {
            markBorrowed(sourceName, node.op == "&mut");
        }
    }
    node.type = node.expression ? node.expression->getType() : std::make_unique<UnknownType>();
    if (node.op == "&") {
        node.type = std::make_unique<BorrowType>(node.type, false);
    }
    else if (node.op == "&mut") {
        node.type = std::make_unique<BorrowType>(node.type, true);
    }
    checkTypeResolved(node.type, "prefix expression");
}

void TypeChecker::visit(AttributeNode& node) {
    if (node.target) {
        node.target->accept(*this);
    }
}

void TypeChecker::visit(LambdaExpressionNode& node) {
    auto& cg = CodeGenerator::getInstance();
    cg.symbolTable.enterScope();
    enterOwnershipScope();
    for (auto& capture : node.captureVariables) {
        if (capture.empty() || capture == "&" || capture == "=") {
            continue;
        }
        bindVariable(capture, std::make_unique<BasicType>("Int"), false);
    }
    for (auto& arg : node.arguments) {
        if (arg) {
            auto* paramNode = dynamic_cast<ParameterNode*>(arg.get());
            if (paramNode && !isResolvedType(paramNode->type)) {
                paramNode->type = std::make_unique<BasicType>("Int");
            }
            arg->accept(*this);
            if (paramNode) {
                bindVariable(paramNode->name, paramNode->type, false);
                declareOwnership(paramNode->name, paramNode->type);
            }
        }
    }
    if (node.body) {
        node.body->accept(*this);
    }
    exitOwnershipScope();
    cg.symbolTable.exitScope();
    node.type = node.getType();
}

void TypeChecker::visit(MapStatementNode& node) {
    auto& cg = CodeGenerator::getInstance();
    std::unique_ptr<Type> elementType = std::make_unique<UnknownType>();
    if (node.iterableExpr) {
        node.iterableExpr->accept(*this);
        elementType = collectionElementType(node.iterableExpr->getType());
    }
    cg.symbolTable.enterScope();
    enterOwnershipScope();
    bindVariable(node.variable, elementType, false);
    declareOwnership(node.variable, elementType);
    if (node.body) {
        node.body->accept(*this);
    }
    auto resolved = node.getType();
    if (!isResolvedType(resolved)) {
        std::vector<std::unique_ptr<Type>> typeArgs;
        typeArgs.push_back(std::make_unique<BasicType>("Real"));
        node.type = std::make_unique<GenericType>(std::make_unique<BasicType>("Array"), typeArgs);
    }
    exitOwnershipScope();
    cg.symbolTable.exitScope();
}

void TypeChecker::visit(PMapStatementNode& node) {
    auto& cg = CodeGenerator::getInstance();
    std::unique_ptr<Type> elementType = std::make_unique<UnknownType>();
    if (node.iterableExpr) {
        node.iterableExpr->accept(*this);
        elementType = collectionElementType(node.iterableExpr->getType());
    }
    if (node.backend != "cpu" && node.backend != "openmp" && node.backend != "gpu" && node.backend != "simd") {
        reportError("Type error: unsupported pmap backend '" + node.backend + "'");
    }
    if (node.backend == "gpu") {
        reportError("Type error: pmap(gpu) is reserved but GPU lowering is not implemented yet");
    }
    cg.symbolTable.enterScope();
    enterOwnershipScope();
    bindVariable(node.variable, elementType, false);
    declareOwnership(node.variable, elementType);
    if (node.body) {
        node.body->accept(*this);
    }
    auto resolved = node.getType();
    if (!isResolvedType(resolved)) {
        std::vector<std::unique_ptr<Type>> typeArgs;
        typeArgs.push_back(std::make_unique<BasicType>("Real"));
        node.type = std::make_unique<GenericType>(std::make_unique<BasicType>("Array"), typeArgs);
    }
    exitOwnershipScope();
    cg.symbolTable.exitScope();
}

void TypeChecker::visit(ReduceStatementNode& node) {
    auto& cg = CodeGenerator::getInstance();
    std::unique_ptr<Type> elementType = std::make_unique<UnknownType>();
    if (node.iterableExpr) {
        node.iterableExpr->accept(*this);
        elementType = collectionElementType(node.iterableExpr->getType());
    }
    if (node.isParallel) {
        if (node.backend != "cpu" && node.backend != "simd" && node.backend != "openmp" && node.backend != "gpu") {
            reportError("Type error: unsupported preduce backend '" + node.backend + "'");
        }
        if (node.backend == "openmp" || node.backend == "gpu") {
            reportError("Type error: preduce(" + node.backend + ") is reserved but parallel reduction lowering is not implemented yet");
        }
    }
    cg.symbolTable.enterScope();
    enterOwnershipScope();
    bindVariable(node.variable, elementType, false);
    declareOwnership(node.variable, elementType);
    std::unique_ptr<Type> accType = node.initialValue ? node.initialValue->getType() : std::make_unique<UnknownType>();
    bindVariable(node.accumulatorVariable, accType, true);
    declareOwnership(node.accumulatorVariable, accType);
    if (node.body) {
        node.body->accept(*this);
    }
    if (node.initialValue) {
        node.initialValue->accept(*this);
    }
    checkTypeResolved(node.getType(), "reduce statement");
    exitOwnershipScope();
    cg.symbolTable.exitScope();
}

void TypeChecker::visit(FilterStatementNode& node) {
    auto& cg = CodeGenerator::getInstance();
    std::unique_ptr<Type> elementType = std::make_unique<UnknownType>();
    if (node.iterableExpr) {
        node.iterableExpr->accept(*this);
        elementType = collectionElementType(node.iterableExpr->getType());
    }
    cg.symbolTable.enterScope();
    enterOwnershipScope();
    bindVariable(node.variable, elementType, false);
    declareOwnership(node.variable, elementType);
    if (node.body) {
        node.body->accept(*this);
    }
    auto resolved = node.getType();
    if (!isResolvedType(resolved)) {
        std::vector<std::unique_ptr<Type>> typeArgs;
        typeArgs.push_back(std::make_unique<BasicType>("Real"));
        node.type = std::make_unique<GenericType>(std::make_unique<BasicType>("Array"), typeArgs);
    }
    exitOwnershipScope();
    cg.symbolTable.exitScope();
}

void TypeChecker::visit(WhileStatementNode& node) {
    if (node.condition) {
        node.condition->accept(*this);
        checkTypeResolved(node.condition->getType(), "while condition");
    }
    if (node.body) {
        node.body->accept(*this);
    }
}

void TypeChecker::visit(ArrayLiteralNode& node) {
    for (auto& element : node.elements) {
        if (element) {
            element->accept(*this);
        }
    }
    checkTypeResolved(node.getType(), "array literal");
}

void TypeChecker::visit(TemplateDeclarationNode& node) {
    if (node.templateParams.empty() && node.typeParameters.empty()) {
        reportError("Type error: Template declaration has no type parameters");
    }
    ensureTemplateSymbol(node);
}
