#pragma once

#include <string>
#include <vector>

// Built-in number aggregates registered as StructSymbols in the global scope (symbol_table.cpp).
// They are value types: `new Complex(re, im)` builds an LLVM struct value, fields are read with
// extractvalue, and + - * / are lowered in BinaryExpressionNode.
inline const std::vector<std::string>* builtinValueStructFields(const std::string& typeName) {
    static const std::vector<std::string> complexFields{ "re", "im" };
    static const std::vector<std::string> rationalFields{ "numerator", "denominator" };
    static const std::vector<std::string> quaternionFields{ "w", "x", "y", "z" };
    if (typeName == "Complex") return &complexFields;
    if (typeName == "Rational") return &rationalFields;
    if (typeName == "Quaternion") return &quaternionFields;
    return nullptr;
}

inline int builtinValueStructFieldIndex(const std::string& typeName, const std::string& field) {
    const auto* fields = builtinValueStructFields(typeName);
    if (!fields) return -1;
    for (size_t i = 0; i < fields->size(); ++i) {
        if ((*fields)[i] == field) return static_cast<int>(i);
    }
    return -1;
}

inline const char* builtinValueStructFieldType(const std::string& typeName) {
    return typeName == "Rational" ? "Long" : "Double";
}
