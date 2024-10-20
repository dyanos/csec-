#include "mangling.h"
#include "utils.h"

#include <string>
#include <vector>
#include <unordered_map>


std::string mangleNamespaces(std::string name) {
    std::vector<std::string> namespaces = split(name, '.');
    std::string basename = "N";
    for (const auto& ns : namespaces) {
        basename += std::to_string(ns.length()) + ns;
    }
    return basename;
}

std::unordered_map<std::string, std::string> mangle(ClassDeclarationNode &node) {
    std::string name = node.name;
    std::string basename = mangleNamespaces(name);

    std::unordered_map<std::string, std::string> cvt_table;
    for (const auto& member : node.body->methods) {
        cvt_table[member->name] = "_Z" + basename + mangle(*member);
    }

    return cvt_table;
}

std::string mangle(ObjectDeclarationNode &node) {
}

std::string mangle(FunctionDeclarationNode &node) {
    std::string name = node.name + "E";
    for (const auto& param : node.parameters) {
        name += mangle(*param);
    }
    return name;
}

std::string mangle(ParameterNode &node) {
    if (node.type->kind == TypeKind::BASIC) {
        if (node.type->name == "void") {
            return "v";
        } 
        else if (node.type->name == "bool") {
            return "b";
        }
        else if (node.type->name == "char") {   // 1byte
            return "c";
        }
        else if (node.type->name == "byte") {   // 1byte
            return "h";
        }
        else if (node.type->name == "short") {  // 2byte
            return "s";
        }
        else if (node.type->name == "word") {   // 2byte
            return "t";
        }
        else if (node.type->name == "int") {    // 4byte
            return "i";
        }
        else if (node.type->name == "dword") {  // 4byte
            return "j";
        }
        else if (node.type->name == "long") {   // 8byte
            return "x";
        }
        else if (node.type->name == "qword") {  // 8byte
            return "y";
        }
        else if (node.type->name == "__int128") {  // 16byte
            return "n";
        }
        else if (node.type->name == "unsigned __int128") {
            return "o";
        }  // 4byte
        else if (node.type->name == "float") {
            return "f";
        }
        else if (node.type->name == "double") {
            return "d";
        }
        else if (node.type->name == "number") {
            return mangleNamespaces("System.lang.Number");
        }
    } 
    else if (node.type->kind == TypeKind::GENERIC) {
        return "G" + node.type->name;
    }   
    else if (node.type->kind == TypeKind::VALUE) {
        return "V" + node.type->name;
    }
    return "P" + node.type->name + "E";
}

#ifdef DEBUG
int main() {
    ClassDeclarationNode node;
    node.name = "a.b.c";
    auto table = mangle(node);
    for (const auto& pair : table) {
        std::cout << pair.first << " -> " << pair.second << std::endl;
    }
    std::cout << "----------------------------------------" << std::endl;
    auto func = std::make_shared<FunctionDeclarationNode>();
    func->name = "test";
    auto param = std::make_shared<ParameterNode>();
    param->name = "a";
    param->type = std::make_shared<Type>();
    param->type->name = "int";
    func->parameters.push_back(param);
    node.body->methods.push_back(func);
    auto table2 = mangle(node);
    for (const auto& pair : table2) {
        std::cout << pair.first << " -> " << pair.second << std::endl;
    }
}
#endif
