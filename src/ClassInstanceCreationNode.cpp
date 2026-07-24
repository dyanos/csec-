#include "codegen.h"

#include "ClassInstanceCreationNode.h"
#include "ClassDeclarationNode.h"
#include "BinaryExpressionNode.h"
#include "BlockNode.h"
#include "ClassBodyNode.h"
#include "FunctionCallNode.h"
#include "FunctionDeclarationNode.h"
#include "IdentifierNode.h"
#include "IfStatementNode.h"
#include "ParameterNode.h"
#include "ReturnStatementNode.h"
#include "ASTVisitor.h"
#include "ValueNode.h"
#include "VariableDeclarationNode.h"
#include "TensorRuntime.h"
#include "type_utils.h"

#include <iostream>
#include <llvm/IR/DataLayout.h>
#include <llvm/IR/Function.h>

#include "utils.h"

namespace {
std::string mangleTemplateClassName(const std::string& className,
                                    const std::vector<std::unique_ptr<Type>>& templateArgs) {
    std::string mangledName = className;
    for (const auto& arg : templateArgs) {
        mangledName += "$" + (arg ? arg->getName() : "Unknown");
    }
    return mangledName;
}

llvm::Value* coerceForStore(llvm::Value* value, llvm::Type* targetType) {
    return coerceValueToLLVMType(value, targetType);
}

void substituteTypeVariables(std::unique_ptr<Type>& type,
                             const std::vector<std::string>& typeParams,
                             const std::vector<std::unique_ptr<Type>>& concreteArgs) {
    if (!type) {
        return;
    }

    if (type->getKind() == Type::Kind::VARIABLE) {
        for (size_t i = 0; i < typeParams.size(); ++i) {
            if (type->getName() == typeParams[i] && i < concreteArgs.size() && concreteArgs[i]) {
                type = concreteArgs[i]->clone();
                return;
            }
        }
    }

    if (type->getKind() == Type::Kind::GENERIC) {
        auto* generic = dynamic_cast<GenericType*>(type.get());
        if (generic) {
            substituteTypeVariables(generic->baseType, typeParams, concreteArgs);
            for (auto& arg : generic->typeArguments) {
                substituteTypeVariables(arg, typeParams, concreteArgs);
            }
        }
    }
}

void substituteTemplateConstants(ASTNode* node,
                                 const std::unordered_map<std::string, std::string>& constantValues) {
    if (!node) {
        return;
    }

    if (auto* identifier = dynamic_cast<IdentifierNode*>(node)) {
        auto it = constantValues.find(identifier->value);
        if (it != constantValues.end()) {
            identifier->value = it->second;
        }
        return;
    }

    if (auto* block = dynamic_cast<BlockNode*>(node)) {
        for (auto& stmt : block->statements) {
            substituteTemplateConstants(stmt.get(), constantValues);
        }
        return;
    }

    if (auto* returnStmt = dynamic_cast<ReturnStatementNode*>(node)) {
        substituteTemplateConstants(returnStmt->expression.get(), constantValues);
        return;
    }

    if (auto* binary = dynamic_cast<BinaryExpressionNode*>(node)) {
        substituteTemplateConstants(binary->left.get(), constantValues);
        substituteTemplateConstants(binary->right.get(), constantValues);
        return;
    }

    if (auto* ifStmt = dynamic_cast<IfStatementNode*>(node)) {
        substituteTemplateConstants(ifStmt->condition.get(), constantValues);
        substituteTemplateConstants(ifStmt->thenBlock.get(), constantValues);
        substituteTemplateConstants(ifStmt->elseBlock.get(), constantValues);
        return;
    }

    if (auto* varDecl = dynamic_cast<VariableDeclarationNode*>(node)) {
        substituteTemplateConstants(varDecl->initializer.get(), constantValues);
        return;
    }

    if (auto* call = dynamic_cast<FunctionCallNode*>(node)) {
        for (auto& arg : call->arguments) {
            substituteTemplateConstants(arg.get(), constantValues);
        }
        return;
    }
}

void substituteClassTemplateArguments(ClassDeclarationNode* classDecl,
                                      const std::vector<std::string>& typeParams,
                                      const std::vector<std::unique_ptr<Type>>& concreteArgs,
                                      const std::unordered_map<std::string, std::string>& constantValues) {
    if (!classDecl) {
        return;
    }

    for (auto& param : classDecl->constructorParams) {
        auto* paramNode = dynamic_cast<ParameterNode*>(param.get());
        if (paramNode) {
            substituteTypeVariables(paramNode->type, typeParams, concreteArgs);
        }
    }

    auto* classBody = dynamic_cast<ClassBodyNode*>(classDecl->body.get());
    if (!classBody) {
        return;
    }

    for (auto& field : classBody->fields) {
        auto* fieldNode = dynamic_cast<VariableDeclarationNode*>(field.get());
        if (!fieldNode) {
            continue;
        }
        substituteTypeVariables(fieldNode->type, typeParams, concreteArgs);
        substituteTemplateConstants(fieldNode->initializer.get(), constantValues);
    }

    for (auto& method : classBody->methods) {
        auto* methodNode = dynamic_cast<FunctionDeclarationNode*>(method.get());
        if (!methodNode) {
            continue;
        }
        for (auto& param : methodNode->parameters) {
            auto* paramNode = dynamic_cast<ParameterNode*>(param.get());
            if (paramNode) {
                substituteTypeVariables(paramNode->type, typeParams, concreteArgs);
            }
        }
        substituteTypeVariables(methodNode->returnType, typeParams, concreteArgs);
        substituteTemplateConstants(methodNode->body.get(), constantValues);
    }
}

ClassSymbol* ensureTemplateClassInstantiation(const std::string& className,
                                              const std::vector<std::unique_ptr<Type>>& templateArgs) {
    auto& cg = CodeGenerator::getInstance();
    auto* symbol = cg.symbolTable.lookup(className);
    if (!symbol || symbol->symbolType != SymbolType::TEMPLATE) {
        return nullptr;
    }

    auto* tmplSymbol = dynamic_cast<TemplateSymbol*>(symbol);
    auto* classDecl = tmplSymbol ? dynamic_cast<ClassDeclarationNode*>(tmplSymbol->declaration.get()) : nullptr;
    if (!tmplSymbol || !classDecl) {
        return nullptr;
    }

    std::string mangledName = mangleTemplateClassName(className, templateArgs);
    if (auto* existingClass = cg.symbolTable.lookupClass(mangledName)) {
        tmplSymbol->classInstantiations[mangledName] = existingClass;
        return existingClass;
    }

    auto clonedDecl = classDecl->clone();
    auto* clonedClass = dynamic_cast<ClassDeclarationNode*>(clonedDecl.get());
    if (!clonedClass) {
        return nullptr;
    }
    clonedClass->name = mangledName;

    std::unordered_map<std::string, std::string> constantValues;
    for (size_t i = 0; i < tmplSymbol->templateParams.size() && i < templateArgs.size(); ++i) {
        if (!tmplSymbol->templateParams[i].isType && templateArgs[i]) {
            constantValues[tmplSymbol->templateParams[i].name] = templateArgs[i]->getName();
        }
    }
    substituteClassTemplateArguments(clonedClass, tmplSymbol->typeParameters, templateArgs, constantValues);

    auto* savedInsertBlock = cg.builder.GetInsertBlock();
    auto savedInsertPoint = cg.builder.GetInsertPoint();
    auto* savedCurrentSymbol = cg.symbolTable.getCurrentSymbol();
    cg.symbolTable.saveCurrentSymbol();
    cg.symbolTable.setCurrentSymbol(nullptr);
    clonedClass->codegen();
    cg.symbolTable.popCurrentSymbol();
    cg.symbolTable.setCurrentSymbol(savedCurrentSymbol);
    if (savedInsertBlock) {
        cg.builder.SetInsertPoint(savedInsertBlock, savedInsertPoint);
    }

    auto* instantiatedSymbol = cg.symbolTable.lookupClass(mangledName);
    if (instantiatedSymbol) {
        tmplSymbol->classInstantiations[mangledName] = instantiatedSymbol;
    }
    return instantiatedSymbol;
}
}

void ClassInstanceCreationNode::accept(ASTVisitor& visitor) {
    visitor.visit(*this);
}

llvm::Value* ClassInstanceCreationNode::codegen() {
    auto& cg = CodeGenerator::getInstance();

    // Primitive allocation: return typed pointer from malloc.
    if (isPrimitiveType(className)) {
        BasicType basicType(className);
        llvm::Type* type = cg.getLLVMType(&basicType);
        if (!type) {
            std::cerr << "Error: Unsupported primitive type '" << className << "'" << std::endl;
            return nullptr;
        }

        const llvm::DataLayout& dl = cg.module->getDataLayout();
        uint64_t typeSize = dl.getTypeAllocSize(type);
        llvm::Value* allocSize = llvm::ConstantInt::get(llvm::Type::getInt64Ty(cg.context), typeSize);
        llvm::Value* rawPtr = cg.builder.CreateCall(cg.mallocFunction, allocSize, "malloc");
        return cg.builder.CreateBitCast(rawPtr, llvm::PointerType::getUnqual(type), "newptr");
    }

    if (className == "Tensor") {
        std::vector<int64_t> dims = TensorRuntime::dimensionsFromTemplateArgs(templateArgs);
        if (dims.empty()) {
            std::cerr << "Error: Tensor requires at least one positive dimension" << std::endl;
            return nullptr;
        }

        llvm::Value* fillValue = nullptr;
        if (!arguments.empty()) {
            fillValue = arguments.front()->codegen();
        }
        return TensorRuntime::createTensor(cg, dims, fillValue);
    }

    std::string resolvedClassName = className;

    // Template Class instantiation: new ClassName<Type>(args)
    if (!templateArgs.empty()) {
        if (auto* instantiatedClass = ensureTemplateClassInstantiation(className, templateArgs)) {
            resolvedClassName = instantiatedClass->name;
        }
    }

    auto classSymbolOpt = cg.symbolTable.lookupClass(resolvedClassName);
    if (!classSymbolOpt) {
        std::cerr << "Error: Class '" << resolvedClassName << "' not found" << std::endl;
        return nullptr;
    }

    auto* classSymbol = classSymbolOpt;
    llvm::StructType* classType = llvm::dyn_cast<llvm::StructType>(classSymbol->classType);
    if (!classType) {
        std::cerr << "Error: Unknown type about class '" << resolvedClassName << "'" << std::endl;
        return nullptr;
    }

    llvm::Value* instance = nullptr;
    if (classSymbol->isStruct) {
        instance = cg.builder.CreateAlloca(classType, nullptr, "newstruct");
    }
    else {
        const llvm::DataLayout& dl = cg.module->getDataLayout();
        uint64_t typeSize = dl.getTypeAllocSize(classType);
        llvm::Value* allocSize = llvm::ConstantInt::get(llvm::Type::getInt64Ty(cg.context), typeSize);
        llvm::Value* rawPtr = cg.builder.CreateCall(cg.mallocFunction, allocSize, "newobj.malloc");
        instance = cg.builder.CreateBitCast(rawPtr, llvm::PointerType::getUnqual(classType), "newobj");
    }

    unsigned fieldIndex = 0;
    auto initializeField = [&](const std::string& fieldName, const std::unique_ptr<Type>& fieldType, llvm::Value* value) -> bool {
        llvm::Type* targetType = getABIStorageType(fieldType.get());
        if (!targetType) {
            std::cerr << "Error: Unsupported field type in class '" << resolvedClassName << "'" << std::endl;
            return false;
        }
        if (!value) {
            value = llvm::Constant::getNullValue(targetType);
        }
        value = coerceForStore(value, targetType);
        if (!value || value->getType() != targetType) {
            std::cerr << "Error: Constructor value for field '" << fieldName << "' has incompatible type" << std::endl;
            return false;
        }
        if (fieldIndex >= classType->getNumElements()) {
            std::cerr << "Error: Field layout for '" << resolvedClassName << "' does not match initializer '" << fieldName << "'" << std::endl;
            return false;
        }
        llvm::Value* fieldPtr = cg.builder.CreateStructGEP(classType, instance, fieldIndex, fieldName + ".init");
        cg.builder.CreateStore(value, fieldPtr);
        fieldIndex += 1;
        return true;
    };

    // Prefer the declaration order preserved in the instantiated ClassSymbol's
    // struct body by re-reading the original class declaration when possible.
    if (!templateArgs.empty()) {
        auto* symbol = cg.symbolTable.lookup(className);
        auto* tmplSymbol = symbol && symbol->symbolType == SymbolType::TEMPLATE ? dynamic_cast<TemplateSymbol*>(symbol) : nullptr;
        auto* originalClass = tmplSymbol ? dynamic_cast<ClassDeclarationNode*>(tmplSymbol->declaration.get()) : nullptr;
        if (originalClass) {
            if (arguments.size() > originalClass->constructorParams.size()) {
                std::cerr << "Error: Too many constructor arguments for class '" << resolvedClassName << "'" << std::endl;
                return nullptr;
            }

            std::unordered_map<std::string, std::string> constantValues;
            for (size_t i = 0; i < tmplSymbol->templateParams.size() && i < templateArgs.size(); ++i) {
                if (!tmplSymbol->templateParams[i].isType && templateArgs[i]) {
                    constantValues[tmplSymbol->templateParams[i].name] = templateArgs[i]->getName();
                }
            }

            std::vector<std::unique_ptr<Type>> concreteTypes;
            concreteTypes.reserve(templateArgs.size());
            for (const auto& arg : templateArgs) {
                concreteTypes.push_back(arg ? arg->clone() : std::make_unique<UnknownType>());
            }

            cg.symbolTable.enterScope();
            auto failTemplateInitialization = [&]() -> llvm::Value* {
                cg.symbolTable.exitScope();
                return nullptr;
            };

            std::vector<std::unique_ptr<ASTNode>> clonedCtorParams;
            clonedCtorParams.reserve(originalClass->constructorParams.size());
            for (const auto& param : originalClass->constructorParams) {
                clonedCtorParams.push_back(param ? param->clone() : nullptr);
            }

            for (size_t i = 0; i < clonedCtorParams.size(); ++i) {
                auto* param = dynamic_cast<ParameterNode*>(clonedCtorParams[i].get());
                if (!param) {
                    continue;
                }
                substituteTypeVariables(param->type, tmplSymbol->typeParameters, concreteTypes);
                llvm::Value* argValue = i < arguments.size() ? arguments[i]->codegen() : nullptr;
                if (!initializeField(param->name, param->type, argValue)) {
                    return failTemplateInitialization();
                }
                llvm::Type* targetType = getABIStorageType(param->type.get());
                if (!argValue && targetType) {
                    argValue = llvm::Constant::getNullValue(targetType);
                }
                argValue = coerceForStore(argValue, targetType);
                cg.symbolTable.addSymbol(
                    param->name,
                    std::make_unique<Symbol>(param->name, param->type ? param->type->clone() : std::make_unique<UnknownType>(), argValue, false, SymbolType::VARIABLE));
            }

            if (auto* originalBody = dynamic_cast<ClassBodyNode*>(originalClass->body.get())) {
                for (const auto& fieldAst : originalBody->fields) {
                    auto clonedField = fieldAst ? fieldAst->clone() : nullptr;
                    auto* fieldNode = dynamic_cast<VariableDeclarationNode*>(clonedField.get());
                    if (!fieldNode) {
                        continue;
                    }
                    substituteTypeVariables(fieldNode->type, tmplSymbol->typeParameters, concreteTypes);
                    substituteTemplateConstants(fieldNode->initializer.get(), constantValues);
                    llvm::Value* initValue = fieldNode->initializer ? fieldNode->initializer->codegen() : nullptr;
                    if (!initializeField(fieldNode->name, fieldNode->type, initValue)) {
                        return failTemplateInitialization();
                    }
                }
            }

            cg.symbolTable.exitScope();
            return instance;
        }
    }

    if (arguments.size() != classSymbol->constructorParamOrder.size()) {
        std::cerr << "Error: Constructor for class '" << resolvedClassName << "' expects "
                  << classSymbol->constructorParamOrder.size() << " argument(s), got "
                  << arguments.size() << std::endl;
        return nullptr;
    }

    cg.symbolTable.enterScope();
    auto failInitialization = [&]() -> llvm::Value* {
        cg.symbolTable.exitScope();
        return nullptr;
    };

    for (size_t i = 0; i < classSymbol->constructorParamOrder.size(); ++i) {
        const std::string& paramName = classSymbol->constructorParamOrder[i];
        auto paramIt = classSymbol->constructorParams.find(paramName);
        if (paramIt == classSymbol->constructorParams.end() || !paramIt->second || !paramIt->second->type) {
            std::cerr << "Error: Missing constructor parameter metadata for '" << paramName << "'" << std::endl;
            return failInitialization();
        }

        llvm::Value* argValue = arguments[i]->codegen();
        if (!initializeField(paramName, paramIt->second->type, argValue)) {
            return failInitialization();
        }

        llvm::Type* targetType = getABIStorageType(paramIt->second->type.get());
        argValue = coerceForStore(argValue, targetType);
        cg.symbolTable.addSymbol(
            paramName,
            std::make_unique<Symbol>(paramName, paramIt->second->type->clone(), argValue, false, SymbolType::VARIABLE));
    }

    // Constructor field initializers are emitted inline, so a class that eagerly constructs its own
    // type in a field default (`var next: Node = new Node(0)`) recurses forever at codegen. Detect
    // re-entry into the same class's field initialization and fail with a diagnostic rather than
    // overflowing the stack. The guard sits after the constructor-argument loop above so a
    // legitimate same-class argument (`new A(new A(5))`) is not caught.
    if (cg.classesUnderConstruction.count(resolvedClassName)) {
        std::cerr << "Error: class '" << resolvedClassName
                  << "' eagerly constructs its own type in a field initializer (infinite "
                     "construction); reference or nullable fields are not yet supported" << std::endl;
        return failInitialization();
    }
    cg.classesUnderConstruction.insert(resolvedClassName);
    struct ConstructionGuard {
        std::unordered_set<std::string>& set;
        std::string name;
        ~ConstructionGuard() { set.erase(name); }
    } constructionGuard{cg.classesUnderConstruction, resolvedClassName};

    for (const auto& fieldName : classSymbol->fieldOrder) {
        auto fieldIt = classSymbol->fields.find(fieldName);
        if (fieldIt == classSymbol->fields.end() || !fieldIt->second || !fieldIt->second->type) {
            std::cerr << "Error: Missing field metadata for '" << fieldName << "'" << std::endl;
            return failInitialization();
        }

        auto initIt = classSymbol->fieldInitializers.find(fieldName);
        ASTNode* initializer = initIt != classSymbol->fieldInitializers.end() ? initIt->second.get() : nullptr;
        if (!initializer) {
            std::cerr << "Error: Field '" << fieldName << "' in class '" << resolvedClassName
                      << "' is not initialized" << std::endl;
            return failInitialization();
        }

        llvm::Value* initValue = initializer->codegen();
        if (!initializeField(fieldName, fieldIt->second->type, initValue)) {
            return failInitialization();
        }
        llvm::Type* targetType = getABIStorageType(fieldIt->second->type.get());
        initValue = coerceForStore(initValue, targetType);
        cg.symbolTable.addSymbol(
            fieldName,
            std::make_unique<Symbol>(fieldName, fieldIt->second->type->clone(), initValue, fieldIt->second->isMutable, SymbolType::VARIABLE));
    }

    cg.symbolTable.exitScope();

    return instance;
}

std::unique_ptr<Type> ClassInstanceCreationNode::getType() {
    if (!templateArgs.empty()) {
        if (className == "Tensor") {
            std::vector<std::unique_ptr<Type>> clonedArgs;
            clonedArgs.reserve(templateArgs.size());
            for (const auto& arg : templateArgs) {
                clonedArgs.push_back(arg ? arg->clone() : std::make_unique<UnknownType>());
            }
            return std::make_unique<GenericType>(std::make_unique<BasicType>("Tensor"), clonedArgs);
        }
        if (className != "Tensor") {
            ensureTemplateClassInstantiation(className, templateArgs);
        }
        std::string mangledName = mangleTemplateClassName(className, templateArgs);
        return std::make_unique<ClassType>(mangledName);
    }

    return std::make_unique<ClassType>(className);
}
