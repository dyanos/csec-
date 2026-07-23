static int csec_i32_operator_precedence(const char* text) {
    if (std::strcmp(text, "or") == 0 || std::strcmp(text, "||") == 0) return 1;
    if (std::strcmp(text, "xor") == 0) return 2;
    if (std::strcmp(text, "and") == 0 || std::strcmp(text, "&&") == 0) return 3;
    if (std::strcmp(text, "|") == 0) return 4;
    if (std::strcmp(text, "^") == 0) return 5;
    if (std::strcmp(text, "&") == 0) return 6;
    if (std::strcmp(text, "==") == 0 || std::strcmp(text, "!=") == 0) return 7;
    if (std::strcmp(text, "<") == 0 || std::strcmp(text, "<=") == 0 ||
        std::strcmp(text, ">") == 0 || std::strcmp(text, ">=") == 0) return 8;
    if (std::strcmp(text, "<<") == 0 || std::strcmp(text, ">>") == 0) return 9;
    if (std::strcmp(text, "+") == 0 || std::strcmp(text, "-") == 0) return 10;
    if (std::strcmp(text, "*") == 0 || std::strcmp(text, "/") == 0 || std::strcmp(text, "%") == 0) return 11;
    return 0;
}

static int csec_i32_top_level_operator(const char* tokens, int start, int end) {
    int paren = 0;
    int bracket = 0;
    int brace = 0;
    int selected = -1;
    int bestPrecedence = 100;
    for (int cursor = start; cursor < end; ++cursor) {
        const char* text = csec_token_text_at(tokens, cursor);
        if (std::strcmp(text, "(") == 0) { ++paren; continue; }
        if (std::strcmp(text, ")") == 0) { --paren; continue; }
        if (std::strcmp(text, "[") == 0) { ++bracket; continue; }
        if (std::strcmp(text, "]") == 0) { --bracket; continue; }
        if (std::strcmp(text, "{") == 0) { ++brace; continue; }
        if (std::strcmp(text, "}") == 0) { --brace; continue; }
        if (paren == 0 && bracket == 0 && brace == 0) {
            const int precedence = csec_i32_operator_precedence(text);
            const bool unarySign = (std::strcmp(text, "+") == 0 || std::strcmp(text, "-") == 0) &&
                (cursor == start || (csec_token_kind_at(tokens, cursor - 1) == 'O' &&
                    !csec_native_token_is(tokens, cursor - 1, 'O', ")") &&
                    !csec_native_token_is(tokens, cursor - 1, 'O', "]") &&
                    !csec_native_token_is(tokens, cursor - 1, 'O', "}")));
            if (!unarySign && precedence > 0 && precedence <= bestPrecedence) {
                selected = cursor;
                bestPrecedence = precedence;
            }
        }
    }
    return selected;
}

static std::string csec_i32_literal(const char* text) {
    if (!text) return "0";
    if (text[0] == '0' && (text[1] == 'b' || text[1] == 'B')) {
        unsigned int value = 0;
        for (const char* cursor = text + 2; *cursor == '0' || *cursor == '1'; ++cursor) {
            value = (value << 1) | static_cast<unsigned int>(*cursor - '0');
        }
        return std::to_string(static_cast<int>(value));
    }
    char* end = nullptr;
    const long long value = std::strtoll(text, &end, 0);
    return end && *end == '\0' ? std::to_string(static_cast<int>(value)) : "0";
}

static std::string csec_llvm_float_literal(const char* text) {
    const float narrowed = static_cast<float>(std::strtod(text ? text : "0", nullptr));
    const double value = static_cast<double>(narrowed);
    std::uint64_t bits = 0;
    static_assert(sizeof(bits) == sizeof(value), "unexpected double width");
    std::memcpy(&bits, &value, sizeof(bits));
    char output[24] = {};
    std::snprintf(output, sizeof(output), "0x%016llX", static_cast<unsigned long long>(bits));
    return output;
}

static std::string csec_llvm_double_literal(const char* text) {
    const double value = std::strtod(text ? text : "0", nullptr);
    std::uint64_t bits = 0;
    std::memcpy(&bits, &value, sizeof(bits));
    char output[24] = {};
    std::snprintf(output, sizeof(output), "0x%016llX", static_cast<unsigned long long>(bits));
    return output;
}

static std::string csec_emit_i32_expression(const char* tokens, int start, int end, const std::string& resultName);
static std::string csec_emit_i1_expression(const char* tokens, int start, int end, const std::string& resultName);
static std::string csec_emit_i64_expression(const char* tokens, int start, int end, const std::string& resultName);
static std::string csec_emit_i8_expression(const char* tokens, int start, int end, const std::string& resultName);
static std::string csec_emit_i16_expression(const char* tokens, int start, int end, const std::string& resultName);
static std::string csec_emit_f32_expression(const char* tokens, int start, int end, const std::string& resultName);
static std::string csec_emit_f64_expression(const char* tokens, int start, int end, const std::string& resultName);
static std::string csec_emit_ptr_expression(const char* tokens, int start, int end, const std::string& resultName);
static bool csec_expression_is_boolean(const char* tokens, int start, int end);
static bool csec_visible_f32_array(const char* tokens, int limit, const char* name);
static bool csec_visible_f64_array(const char* tokens, int limit, const char* name);
static bool csec_visible_ptr_array(const char* tokens, int limit, const char* name);
static bool csec_visible_i16_array(const char* tokens, int limit, const char* name);
static bool csec_visible_i64_array(const char* tokens, int limit, const char* name);

static std::vector<std::pair<std::string, std::string>> csec_class_constructor_params(const char* tokens, int classStart) {
    std::vector<std::pair<std::string, std::string>> params;
    const int bodyStart = csec_find_decl_body_start(tokens, classStart);
    const int open = bodyStart >= 0 ? csec_find_token_text_in_range(tokens, classStart, bodyStart, "(") : -1;
    const int close = open >= 0 ? csec_find_closing_token(tokens, open, bodyStart, "(", ")") : -1;
    if (close <= open) return params;
    for (int cursor = open + 1; cursor < close;) {
        if (csec_token_kind_at(tokens, cursor) != 'I') { ++cursor; continue; }
        const std::string name = csec_token_text_at(tokens, cursor++);
        if (!csec_native_token_is(tokens, cursor, 'O', ":") || cursor + 1 >= close) continue;
        ++cursor;
        const std::string type = csec_token_text_at(tokens, cursor++);
        params.emplace_back(name, type);
        while (cursor < close && !csec_native_token_is(tokens, cursor, 'O', ",")) ++cursor;
        if (cursor < close) ++cursor;
    }
    return params;
}

extern "C++" {
static std::vector<std::pair<std::string, std::pair<int, int>>> csec_class_i32_fields(const char* tokens, int classStart) {
    std::vector<std::pair<std::string, std::pair<int, int>>> fields;
    const int bodyStart = csec_find_decl_body_start(tokens, classStart);
    const int bodyEnd = csec_find_decl_body_end(tokens, bodyStart);
    int depth = 0;
    for (int cursor = bodyStart; cursor >= 0 && cursor < bodyEnd; ++cursor) {
        if (csec_native_token_is(tokens, cursor, 'O', "{")) { ++depth; continue; }
        if (csec_native_token_is(tokens, cursor, 'O', "}")) { --depth; continue; }
        if (depth != 0 || (!csec_native_token_is(tokens, cursor, 'K', "val") && !csec_native_token_is(tokens, cursor, 'K', "var"))) continue;
        if (csec_token_kind_at(tokens, cursor + 1) != 'I') continue;
        const int statementEnd = csec_advance_statement(tokens, cursor, bodyEnd);
        const int initializer = statementEnd > cursor ? csec_find_top_level_operator(tokens, cursor, statementEnd, 1) : -1;
        const int colon = statementEnd > cursor ? csec_find_token_text_in_range(tokens, cursor + 2, initializer >= 0 ? initializer : statementEnd, ":") : -1;
        if (colon < 0 || !csec_native_token_is(tokens, colon + 1, 'I', "Int")) continue;
        if (initializer < cursor || initializer + 1 >= statementEnd) continue;
        fields.emplace_back(std::string(csec_token_text_at(tokens, cursor + 1)) + ".addr." + std::to_string(cursor),
            std::make_pair(initializer + 1, statementEnd));
    }
    return fields;
}

static std::vector<std::pair<std::string, std::pair<int, int>>> csec_class_i1_fields(const char* tokens, int classStart) {
    std::vector<std::pair<std::string, std::pair<int, int>>> fields;
    const int bodyStart = csec_find_decl_body_start(tokens, classStart);
    const int bodyEnd = csec_find_decl_body_end(tokens, bodyStart);
    int depth = 0;
    for (int cursor = bodyStart; cursor >= 0 && cursor < bodyEnd; ++cursor) {
        if (csec_native_token_is(tokens, cursor, 'O', "{")) { ++depth; continue; }
        if (csec_native_token_is(tokens, cursor, 'O', "}")) { --depth; continue; }
        if (depth != 0 || (!csec_native_token_is(tokens, cursor, 'K', "val") && !csec_native_token_is(tokens, cursor, 'K', "var"))) continue;
        if (csec_token_kind_at(tokens, cursor + 1) != 'I') continue;
        const int statementEnd = csec_advance_statement(tokens, cursor, bodyEnd);
        const int initializer = statementEnd > cursor ? csec_find_top_level_operator(tokens, cursor, statementEnd, 1) : -1;
        const int colon = statementEnd > cursor ? csec_find_token_text_in_range(tokens, cursor + 2, initializer >= 0 ? initializer : statementEnd, ":") : -1;
        if (colon < 0 || !csec_native_token_is(tokens, colon + 1, 'I', "Boolean")) continue;
        if (initializer < cursor || initializer + 1 >= statementEnd) continue;
        fields.emplace_back(std::string(csec_token_text_at(tokens, cursor + 1)) + ".addr." + std::to_string(cursor),
            std::make_pair(initializer + 1, statementEnd));
    }
    return fields;
}

static std::vector<std::pair<std::string, std::pair<int, int>>> csec_class_ptr_fields(const char* tokens, int classStart) {
    std::vector<std::pair<std::string, std::pair<int, int>>> fields;
    const int bodyStart = csec_find_decl_body_start(tokens, classStart);
    const int bodyEnd = csec_find_decl_body_end(tokens, bodyStart);
    int depth = 0;
    for (int cursor = bodyStart; cursor >= 0 && cursor < bodyEnd; ++cursor) {
        if (csec_native_token_is(tokens, cursor, 'O', "{")) { ++depth; continue; }
        if (csec_native_token_is(tokens, cursor, 'O', "}")) { --depth; continue; }
        if (depth != 0 || (!csec_native_token_is(tokens, cursor, 'K', "val") && !csec_native_token_is(tokens, cursor, 'K', "var"))) continue;
        if (csec_token_kind_at(tokens, cursor + 1) != 'I') continue;
        const int statementEnd = csec_advance_statement(tokens, cursor, bodyEnd);
        const int initializer = statementEnd > cursor ? csec_find_top_level_operator(tokens, cursor, statementEnd, 1) : -1;
        const int colon = statementEnd > cursor ? csec_find_token_text_in_range(tokens, cursor + 2, initializer >= 0 ? initializer : statementEnd, ":") : -1;
        if (colon < 0 || std::strcmp(csec_llvm_type_for_name(csec_token_text_at(tokens, colon + 1)), "ptr") != 0) continue;
        if (initializer < cursor || initializer + 1 >= statementEnd) continue;
        fields.emplace_back(std::string(csec_token_text_at(tokens, cursor + 1)) + ".addr." + std::to_string(cursor),
            std::make_pair(initializer + 1, statementEnd));
    }
    return fields;
}
}

static int csec_find_class_declaration(const char* tokens, const char* className) {
    if (!className) return -1;
    for (int cursor = 0; csec_token_kind_at(tokens, cursor) != 'E'; ++cursor) {
        if (csec_native_token_is(tokens, cursor, 'K', "class") &&
            csec_native_token_is(tokens, cursor + 1, 'I', className)) return cursor;
    }
    return -1;
}

static std::string csec_class_parent_name(const char* tokens, int classStart);

static int csec_class_inherited_field_count(const char* tokens, int classStart) {
    const std::string parent = csec_class_parent_name(tokens, classStart);
    const int parentStart = parent.empty() ? -1 : csec_find_class_declaration(tokens, parent.c_str());
    if (parentStart < 0) return 0;
    return csec_class_inherited_field_count(tokens, parentStart) +
        static_cast<int>(csec_class_i32_fields(tokens, parentStart).size()) +
        static_cast<int>(csec_class_i1_fields(tokens, parentStart).size()) +
        static_cast<int>(csec_class_ptr_fields(tokens, parentStart).size());
}

static std::string csec_class_inherited_field_layout(const char* tokens, int classStart) {
    const std::string parent = csec_class_parent_name(tokens, classStart);
    const int parentStart = parent.empty() ? -1 : csec_find_class_declaration(tokens, parent.c_str());
    if (parentStart < 0) return "";
    std::string layout = csec_class_inherited_field_layout(tokens, parentStart);
    for (size_t index = 0; index < csec_class_i32_fields(tokens, parentStart).size(); ++index) {
        if (!layout.empty()) layout += ", ";
        layout += "i32";
    }
    for (size_t index = 0; index < csec_class_i1_fields(tokens, parentStart).size(); ++index) {
        if (!layout.empty()) layout += ", ";
        layout += "i1";
    }
    for (size_t index = 0; index < csec_class_ptr_fields(tokens, parentStart).size(); ++index) {
        if (!layout.empty()) layout += ", ";
        layout += "ptr";
    }
    return layout;
}

static bool csec_class_uses_pointer_receiver(const char* tokens, int classStart) {
    if (csec_class_inherited_field_count(tokens, classStart) > 0 ||
        !csec_class_i32_fields(tokens, classStart).empty() || !csec_class_i1_fields(tokens, classStart).empty() ||
        !csec_class_ptr_fields(tokens, classStart).empty()) return true;
    for (const auto& parameter : csec_class_constructor_params(tokens, classStart)) {
        if (std::strcmp(csec_llvm_type_for_name(parameter.second.c_str()), "i32") != 0) return true;
    }
    return false;
}

static std::string csec_class_i32_layout(const char* tokens, int classStart) {
    std::string layout;
    for (const auto& parameter : csec_class_constructor_params(tokens, classStart)) {
        const char* type = csec_llvm_type_for_name(parameter.second);
        if (std::strcmp(type, "i32") != 0 && std::strcmp(type, "i1") != 0 && std::strcmp(type, "ptr") != 0) continue;
        if (!layout.empty()) layout += ", ";
        layout += type;
    }
    const std::string inherited = csec_class_inherited_field_layout(tokens, classStart);
    if (!inherited.empty()) {
        if (!layout.empty()) layout += ", ";
        layout += inherited;
    }
    for (size_t index = 0; index < csec_class_i32_fields(tokens, classStart).size(); ++index) {
        if (!layout.empty()) layout += ", ";
        layout += "i32";
    }
    for (size_t index = 0; index < csec_class_i1_fields(tokens, classStart).size(); ++index) {
        if (!layout.empty()) layout += ", ";
        layout += "i1";
    }
    for (size_t index = 0; index < csec_class_ptr_fields(tokens, classStart).size(); ++index) {
        if (!layout.empty()) layout += ", ";
        layout += "ptr";
    }
    return layout;
}

static int csec_enclosing_class_declaration(const char* tokens, int ordinal) {
    for (int cursor = 0; csec_token_kind_at(tokens, cursor) != 'E'; ++cursor) {
        if (!csec_native_token_is(tokens, cursor, 'K', "class")) continue;
        const int bodyStart = csec_find_decl_body_start(tokens, cursor);
        const int bodyEnd = csec_find_decl_body_end(tokens, bodyStart);
        if (bodyStart >= 0 && ordinal >= bodyStart && ordinal < bodyEnd) return cursor;
    }
    return -1;
}

static bool csec_is_boolean_class_constructor_param(const char* tokens, int ordinal, const char* name) {
    const int classStart = csec_enclosing_class_declaration(tokens, ordinal);
    if (classStart < 0 || !name) return false;
    for (const auto& parameter : csec_class_constructor_params(tokens, classStart)) {
        if (parameter.first == name) return parameter.second == "Boolean";
    }
    for (const auto& field : csec_class_i1_fields(tokens, classStart)) {
        const size_t suffix = field.first.find(".addr.");
        if (suffix != std::string::npos && field.first.substr(0, suffix) == name) return true;
    }
    return false;
}

static std::string csec_class_parent_name(const char* tokens, int classStart) {
    const int bodyStart = csec_find_decl_body_start(tokens, classStart);
    for (int cursor = classStart + 1; bodyStart >= 0 && cursor < bodyStart; ++cursor) {
        if (csec_native_token_is(tokens, cursor, 'K', "extends") && csec_token_kind_at(tokens, cursor + 1) == 'I') {
            return csec_token_text_at(tokens, cursor + 1);
        }
    }
    return "";
}

static std::string csec_emit_class_field_initializers(const char* tokens, int classStart,
    const std::string& className, const std::string& object, const std::string& variableName, int& fieldIndex) {
    std::string output;
    const std::string parent = csec_class_parent_name(tokens, classStart);
    const int parentStart = parent.empty() ? -1 : csec_find_class_declaration(tokens, parent.c_str());
    if (parentStart >= 0) output += csec_emit_class_field_initializers(tokens, parentStart, className, object, variableName, fieldIndex);
    for (const auto& field : csec_class_i32_fields(tokens, classStart)) {
        const std::string value = "%" + variableName + ".init." + std::to_string(fieldIndex);
        const std::string slot = "%" + variableName + ".field." + std::to_string(fieldIndex);
        output += csec_emit_i32_expression(tokens, field.second.first, field.second.second, value);
        output += "  " + slot + " = getelementptr inbounds %class." + className + ", ptr %" + object + ", i32 0, i32 " + std::to_string(fieldIndex++) + "\n";
        output += "  store i32 " + value + ", ptr " + slot + "\n";
    }
    for (const auto& field : csec_class_i1_fields(tokens, classStart)) {
        const std::string value = "%" + variableName + ".init." + std::to_string(fieldIndex);
        const std::string slot = "%" + variableName + ".field." + std::to_string(fieldIndex);
        output += csec_emit_i1_expression(tokens, field.second.first, field.second.second, value);
        output += "  " + slot + " = getelementptr inbounds %class." + className + ", ptr %" + object + ", i32 0, i32 " + std::to_string(fieldIndex++) + "\n";
        output += "  store i1 " + value + ", ptr " + slot + "\n";
    }
    for (const auto& field : csec_class_ptr_fields(tokens, classStart)) {
        const std::string value = "%" + variableName + ".init." + std::to_string(fieldIndex);
        const std::string slot = "%" + variableName + ".field." + std::to_string(fieldIndex);
        output += csec_emit_ptr_expression(tokens, field.second.first, field.second.second, value);
        output += "  " + slot + " = getelementptr inbounds %class." + className + ", ptr %" + object + ", i32 0, i32 " + std::to_string(fieldIndex++) + "\n";
        output += "  store ptr " + value + ", ptr " + slot + "\n";
    }
    return output;
}

static int csec_class_field_index(const char* tokens, int classStart, const char* name) {
    int index = 0;
    for (const auto& parameter : csec_class_constructor_params(tokens, classStart)) {
        const char* type = csec_llvm_type_for_name(parameter.second.c_str());
        if (std::strcmp(type, "i32") != 0 && std::strcmp(type, "i1") != 0 && std::strcmp(type, "ptr") != 0) continue;
        if (parameter.first == name) return index;
        ++index;
    }
    index += csec_class_inherited_field_count(tokens, classStart);
    for (const auto& field : csec_class_i32_fields(tokens, classStart)) {
        if (field.first.rfind(std::string(name) + ".addr.", 0) == 0) return index;
        ++index;
    }
    for (const auto& field : csec_class_i1_fields(tokens, classStart)) {
        if (field.first.rfind(std::string(name) + ".addr.", 0) == 0) return index;
        ++index;
    }
    for (const auto& field : csec_class_ptr_fields(tokens, classStart)) {
        if (field.first.rfind(std::string(name) + ".addr.", 0) == 0) return index;
        ++index;
    }
    return -1;
}

static bool csec_is_string_class_constructor_param(const char* tokens, int ordinal, const char* name);

static std::string csec_class_method_definition(const char* tokens, int classStart, int methodStart) {
    const std::string className = csec_top_level_decl_name(tokens, classStart);
    const std::string methodName = csec_top_level_decl_name(tokens, methodStart);
    const int methodEnd = csec_advance_top_level_decl(tokens, methodStart);
    const int expression = csec_find_top_level_operator(tokens, methodStart, methodEnd, 1);
    const int valueStart = expression >= methodStart ? expression + 1 : -1;
    const bool lengthProperty = valueStart >= 0 && valueStart + 2 < methodEnd &&
        csec_token_kind_at(tokens, valueStart) == 'I' && csec_native_token_is(tokens, valueStart + 1, 'O', ".") &&
        csec_native_token_is(tokens, valueStart + 2, 'I', "length") &&
        (valueStart + 3 == methodEnd || csec_native_token_is(tokens, valueStart + 3, 'O', ";"));
    bool classStringValue = false;
    if (valueStart >= 0) {
        const char* valueName = csec_token_text_at(tokens, valueStart);
        for (const auto& parameter : csec_class_constructor_params(tokens, classStart)) {
            if (parameter.first == valueName && parameter.second == "String") classStringValue = true;
        }
        for (const auto& field : csec_class_ptr_fields(tokens, classStart)) {
            if (field.first.rfind(std::string(valueName) + ".addr.", 0) == 0) classStringValue = true;
        }
    }
    if (lengthProperty && std::strcmp(csec_function_return_type_at(tokens, methodStart), "Int") == 0 &&
        classStringValue) {
        const int fieldIndex = csec_class_field_index(tokens, classStart, csec_token_text_at(tokens, valueStart));
        if (fieldIndex >= 0) {
            return "define i32 @" + className + "_" + methodName + "(ptr %arg.this) {\nentry:\n" +
                "  %field = getelementptr inbounds %class." + className + ", ptr %arg.this, i32 0, i32 " + std::to_string(fieldIndex) + "\n" +
                "  %string = load ptr, ptr %field\n" +
                "  %length64 = call i64 @csec_string_length(ptr %string)\n" +
                "  %ret = trunc i64 %length64 to i32\n" +
                "  ret i32 %ret\n}\n\n";
        }
    }
    char* raw = csec_generate_llvm_function_definition(tokens, methodStart);
    if (!raw) return "";
    std::string definition(raw);
    if (std::strcmp(csec_function_return_type_at(tokens, methodStart), "String") == 0) {
        for (const auto& parameter : csec_class_constructor_params(tokens, classStart)) {
            if (parameter.second != "String") continue;
            if (definition.find("ret ptr %ret") == std::string::npos) continue;
            const int fieldIndex = csec_class_field_index(tokens, classStart, parameter.first.c_str());
            if (fieldIndex < 0) continue;
            const int classBodyEnd = csec_find_decl_body_end(tokens, csec_find_decl_body_start(tokens, classStart));
            int methodLimit = classBodyEnd;
            for (int cursor = methodStart + 1; cursor < classBodyEnd; ++cursor) {
                if (csec_native_token_is(tokens, cursor, 'K', "def")) { methodLimit = cursor; break; }
            }
            int plus = -1;
            int literal = -1;
            for (int cursor = methodStart; cursor < methodLimit; ++cursor) {
                if (csec_native_token_is(tokens, cursor, 'O', "+")) plus = cursor;
                if (plus >= 0 && csec_token_kind_at(tokens, cursor) == 'S') { literal = cursor; break; }
            }
            if (plus >= 0 && literal >= 0) {
                return "define ptr @" + className + "_" + methodName + "(ptr %arg.this) {\nentry:\n" +
                    "  %field = getelementptr inbounds %class." + className + ", ptr %arg.this, i32 0, i32 " + std::to_string(fieldIndex) + "\n" +
                    "  %left = load ptr, ptr %field\n" +
                    "  %right = getelementptr inbounds [" + std::to_string(csec_llvm_string_literal_byte_length(csec_token_text_at(tokens, literal))) +
                    " x i8], ptr @.str." + std::to_string(literal) + ", i32 0, i32 0\n" +
                    "  %ret = call ptr @csec_string_concat(ptr %left, ptr %right)\n" +
                    "  ret ptr %ret\n}\n\n";
            }
            return "define ptr @" + className + "_" + methodName + "(ptr %arg.this) {\nentry:\n" +
                "  %field = getelementptr inbounds %class." + className + ", ptr %arg.this, i32 0, i32 " + std::to_string(fieldIndex) + "\n" +
                "  %ret = load ptr, ptr %field\n" +
                "  ret ptr %ret\n}\n\n";
        }
    }
    if (std::strcmp(csec_function_return_type_at(tokens, methodStart), "Int") == 0 && methodName == "length") {
        for (const auto& parameter : csec_class_constructor_params(tokens, classStart)) {
            if (parameter.second != "String") continue;
            const std::string integerLoad = "%ret = load i32, ptr %" + parameter.first;
            if (definition.find(integerLoad) == std::string::npos) continue;
            const int fieldIndex = csec_class_field_index(tokens, classStart, parameter.first.c_str());
            if (fieldIndex < 0) continue;
            return "define i32 @" + className + "_" + methodName + "(ptr %arg.this) {\nentry:\n" +
                "  %field = getelementptr inbounds %class." + className + ", ptr %arg.this, i32 0, i32 " + std::to_string(fieldIndex) + "\n" +
                "  %string = load ptr, ptr %field\n" +
                "  %length64 = call i64 @csec_string_length(ptr %string)\n" +
                "  %ret = trunc i64 %length64 to i32\n" +
                "  ret i32 %ret\n}\n\n";
        }
    }
    const std::string original = "@" + methodName + "(";
    const std::string replacement = "@" + className + "_" + methodName + "(";
    size_t position = 0;
    while ((position = definition.find(original, position)) != std::string::npos) {
        definition.replace(position, original.size(), replacement);
        position += replacement.size();
    }

    const auto fields = csec_class_constructor_params(tokens, classStart);
    const auto declaredFields = csec_class_i32_fields(tokens, classStart);
    const auto declaredBooleanFields = csec_class_i1_fields(tokens, classStart);
    const auto declaredPointerFields = csec_class_ptr_fields(tokens, classStart);
    if (fields.empty() && declaredFields.empty() && declaredBooleanFields.empty() && declaredPointerFields.empty() && !csec_class_uses_pointer_receiver(tokens, classStart)) return definition;
    const size_t open = definition.find(replacement);
    const size_t paramsStart = open == std::string::npos ? std::string::npos : open + replacement.size();
    const size_t paramsEnd = paramsStart == std::string::npos ? std::string::npos : definition.find(") {\nentry:\n", paramsStart);
    if (paramsEnd == std::string::npos) return definition;
    const bool pointerReceiver = csec_class_uses_pointer_receiver(tokens, classStart);
    std::string receiverParams;
    std::string receiverAllocas;
    int fieldIndex = 0;
    if (pointerReceiver) {
        receiverParams = "ptr %arg.this";
        for (const auto& field : fields) {
            const char* fieldType = csec_llvm_type_for_name(field.second);
            if (std::strcmp(fieldType, "i32") != 0 && std::strcmp(fieldType, "i1") != 0 && std::strcmp(fieldType, "ptr") != 0) continue;
            receiverAllocas += "  %" + field.first + " = getelementptr inbounds %class." + className + ", ptr %arg.this, i32 0, i32 " + std::to_string(fieldIndex++) + "\n";
        }
        fieldIndex += csec_class_inherited_field_count(tokens, classStart);
        for (const auto& field : declaredFields) {
            receiverAllocas += "  %" + field.first + " = getelementptr inbounds %class." + className + ", ptr %arg.this, i32 0, i32 " + std::to_string(fieldIndex++) + "\n";
            const size_t suffix = field.first.find(".addr.");
            if (suffix != std::string::npos) {
                receiverAllocas += "  %" + field.first.substr(0, suffix) + " = getelementptr inbounds %class." + className + ", ptr %arg.this, i32 0, i32 " + std::to_string(fieldIndex - 1) + "\n";
            }
        }
        for (const auto& field : declaredBooleanFields) {
            receiverAllocas += "  %" + field.first + " = getelementptr inbounds %class." + className + ", ptr %arg.this, i32 0, i32 " + std::to_string(fieldIndex++) + "\n";
            const size_t suffix = field.first.find(".addr.");
            if (suffix != std::string::npos) {
                receiverAllocas += "  %" + field.first.substr(0, suffix) + " = getelementptr inbounds %class." + className + ", ptr %arg.this, i32 0, i32 " + std::to_string(fieldIndex - 1) + "\n";
            }
        }
        for (const auto& field : declaredPointerFields) {
            receiverAllocas += "  %" + field.first + " = getelementptr inbounds %class." + className + ", ptr %arg.this, i32 0, i32 " + std::to_string(fieldIndex++) + "\n";
            const size_t suffix = field.first.find(".addr.");
            if (suffix != std::string::npos) {
                receiverAllocas += "  %" + field.first.substr(0, suffix) + " = getelementptr inbounds %class." + className + ", ptr %arg.this, i32 0, i32 " + std::to_string(fieldIndex - 1) + "\n";
            }
        }
    } else for (const auto& field : fields) {
        if (std::strcmp(csec_llvm_type_for_name(field.second.c_str()), "i32") != 0) return definition;
        if (!receiverParams.empty()) receiverParams += ", ";
        receiverParams += "i32 %arg.this." + field.first;
        receiverAllocas += "  %" + field.first + " = alloca i32\n";
        receiverAllocas += "  store i32 %arg.this." + field.first + ", ptr %" + field.first + "\n";
    }
    if (paramsEnd > paramsStart) receiverParams += ", ";
    definition.insert(paramsStart, receiverParams);
    const size_t entry = definition.find("entry:\n");
    if (entry != std::string::npos) {
        for (const auto& field : declaredFields) {
            if (pointerReceiver) continue;
            const std::string value = "%this." + field.first;
            receiverAllocas += "  %" + field.first + " = alloca i32\n";
            receiverAllocas += csec_emit_i32_expression(tokens, field.second.first, field.second.second, value);
            receiverAllocas += "  store i32 " + value + ", ptr %" + field.first + "\n";
        }
        definition.insert(entry + 7, receiverAllocas);
    }
    return definition;
}

static std::string csec_object_method_definition(const char* tokens, int objectStart, int methodStart) {
    const std::string objectName = csec_top_level_decl_name(tokens, objectStart);
    const std::string methodName = csec_top_level_decl_name(tokens, methodStart);
    char* raw = csec_generate_llvm_function_definition(tokens, methodStart);
    if (!raw) return "";
    std::string definition(raw);
    const std::string original = "@" + methodName + "(";
    const std::string replacement = "@" + objectName + "_" + methodName + "(";
    size_t position = 0;
    while ((position = definition.find(original, position)) != std::string::npos) {
        definition.replace(position, original.size(), replacement);
        position += replacement.size();
    }
    const size_t entry = definition.find("entry:\n");
    if (entry == std::string::npos) return definition;
    std::string initializers;
    for (const auto& field : csec_class_i32_fields(tokens, objectStart)) {
        const std::string value = "%object." + field.first;
        initializers += "  %" + field.first + " = alloca i32\n";
        initializers += csec_emit_i32_expression(tokens, field.second.first, field.second.second, value);
        initializers += "  store i32 " + value + ", ptr %" + field.first + "\n";
    }
    definition.insert(entry + 7, initializers);
    return definition;
}

static bool csec_lambda_declaration(const char* tokens, int declaration, int declarationEnd, int* bodyStart = nullptr, int* bodyEnd = nullptr) {
    const int initializer = csec_find_top_level_operator(tokens, declaration, declarationEnd, 1);
    const int start = initializer + 1;
    if (initializer < declaration || !csec_native_token_is(tokens, start, 'O', "[")) return false;
    const int arrow = csec_find_lambda_arrow(tokens, start, declarationEnd);
    const int open = arrow >= 0 ? csec_find_token_text_in_range(tokens, arrow + 1, declarationEnd, "{") : -1;
    const int close = open >= 0 ? csec_find_closing_token(tokens, open, declarationEnd, "{", "}") : -1;
    if (arrow < 0 || open < 0 || close < open) return false;
    if (bodyStart) *bodyStart = open + 1;
    if (bodyEnd) *bodyEnd = close;
    return true;
}

static std::string csec_lambda_function_name(int declaration) {
    return "csec_lambda_" + std::to_string(declaration);
}

extern "C++" {
static std::vector<std::string> csec_lambda_capture_names(const char* tokens, int declaration, int declarationEnd) {
    std::vector<std::string> captures;
    const int initializer = csec_find_top_level_operator(tokens, declaration, declarationEnd, 1);
    const int open = initializer + 1;
    const int close = open >= 0 ? csec_find_closing_token(tokens, open, declarationEnd, "[", "]") : -1;
    if (close <= open + 1) return captures;
    bool captureAll = false;
    for (int cursor = open + 1; cursor < close; ++cursor) {
        if (csec_native_token_is(tokens, cursor, 'O', "=") || csec_native_token_is(tokens, cursor, 'O', "&")) captureAll = true;
        if (csec_token_kind_at(tokens, cursor) == 'I') captures.emplace_back(csec_token_text_at(tokens, cursor));
    }
    if (!captureAll) return captures;

    const int arrow = csec_find_lambda_arrow(tokens, open, declarationEnd);
    const int paramOpen = arrow >= 0 ? csec_find_closing_token(tokens, open, declarationEnd, "[", "]") + 1 : -1;
    const int paramClose = paramOpen >= 0 ? csec_find_closing_token(tokens, paramOpen, declarationEnd, "(", ")") : -1;
    const int bodyOpen = arrow >= 0 ? csec_find_token_text_in_range(tokens, arrow + 1, declarationEnd, "{") : -1;
    const int bodyClose = bodyOpen >= 0 ? csec_find_closing_token(tokens, bodyOpen, declarationEnd, "{", "}") : -1;
    if (paramClose < paramOpen || bodyClose < bodyOpen) return captures;
    std::vector<std::string> parameters;
    for (int cursor = paramOpen + 1; cursor < paramClose; ++cursor) {
        if (csec_token_kind_at(tokens, cursor) == 'I') parameters.emplace_back(csec_token_text_at(tokens, cursor));
    }
    for (int cursor = bodyOpen + 1; cursor < bodyClose; ++cursor) {
        if (csec_token_kind_at(tokens, cursor) != 'I') continue;
        const std::string name = csec_token_text_at(tokens, cursor);
        if (std::find(parameters.begin(), parameters.end(), name) != parameters.end() ||
            std::find(captures.begin(), captures.end(), name) != captures.end()) continue;
        if (csec_find_visible_local(tokens, declaration, name.c_str()) >= 0) captures.push_back(name);
    }
    return captures;
}
}

static bool csec_lambda_captures_by_reference(const char* tokens, int declaration, int declarationEnd) {
    const int initializer = csec_find_top_level_operator(tokens, declaration, declarationEnd, 1);
    const int open = initializer + 1;
    const int close = open >= 0 ? csec_find_closing_token(tokens, open, declarationEnd, "[", "]") : -1;
    for (int cursor = open + 1; close > open && cursor < close; ++cursor) {
        if (csec_native_token_is(tokens, cursor, 'O', "&")) return true;
    }
    return false;
}

static std::string csec_lambda_closure_type_name(int declaration) {
    return "%csec.lambda.closure." + std::to_string(declaration);
}

static std::string csec_lambda_environment_type_name(int declaration) {
    return "%csec.lambda.environment." + std::to_string(declaration);
}

static std::string csec_lambda_type_definitions(const char* tokens) {
    std::string output;
    for (int cursor = 0; csec_token_kind_at(tokens, cursor) != 'E'; ++cursor) {
        if (!csec_native_token_is(tokens, cursor, 'K', "val") && !csec_native_token_is(tokens, cursor, 'K', "var")) continue;
        const int end = csec_advance_statement(tokens, cursor, 1000000000);
        if (!csec_lambda_declaration(tokens, cursor, end)) continue;
        output += csec_lambda_closure_type_name(cursor) + " = type { ptr, ptr }\n";
        const auto captures = csec_lambda_capture_names(tokens, cursor, end);
        if (!captures.empty()) {
            output += csec_lambda_environment_type_name(cursor) + " = type { ";
            for (size_t index = 0; index < captures.size(); ++index) {
                if (index != 0) output += ", ";
                output += csec_lambda_captures_by_reference(tokens, cursor, end) ? "ptr" : "i32";
            }
            output += " }\n";
        }
    }
    return output.empty() ? output : output + "\n";
}

static std::string csec_lambda_definition(const char* tokens, int declaration, int declarationEnd) {
    int bodyStart = -1, bodyEnd = -1;
    if (!csec_lambda_declaration(tokens, declaration, declarationEnd, &bodyStart, &bodyEnd)) return "";
    const int initializer = csec_find_top_level_operator(tokens, declaration, declarationEnd, 1);
    const int captureClose = csec_find_closing_token(tokens, initializer + 1, declarationEnd, "[", "]");
    const int paramOpen = captureClose >= 0 ? captureClose + 1 : -1;
    const int paramClose = paramOpen >= 0 ? csec_find_closing_token(tokens, paramOpen, declarationEnd, "(", ")") : -1;
    if (paramClose < paramOpen) return "";
    std::string parameters = "ptr %arg.env";
    std::string allocas;
    const bool byReference = csec_lambda_captures_by_reference(tokens, declaration, declarationEnd);
    int captureIndex = 0;
    for (const std::string& capture : csec_lambda_capture_names(tokens, declaration, declarationEnd)) {
        const int sourceDeclaration = csec_find_visible_local(tokens, declaration, capture.c_str());
        const std::string storage = sourceDeclaration >= 0
            ? capture + ".addr." + std::to_string(sourceDeclaration)
            : capture;
        const std::string environmentField = "%capture.env." + std::to_string(captureIndex++);
        allocas += "  " + environmentField + " = getelementptr inbounds " + csec_lambda_environment_type_name(declaration) +
            ", ptr %arg.env, i32 0, i32 " + std::to_string(captureIndex - 1) + "\n";
        if (byReference) {
            allocas += "  %" + storage + " = load ptr, ptr " + environmentField + "\n";
        } else {
            allocas += "  %" + storage + " = alloca i32\n";
            allocas += "  %capture.value." + std::to_string(captureIndex - 1) + " = load i32, ptr " + environmentField + "\n";
            allocas += "  store i32 %capture.value." + std::to_string(captureIndex - 1) + ", ptr %" + storage + "\n";
        }
    }
    for (int cursor = paramOpen + 1; cursor < paramClose;) {
        if (csec_token_kind_at(tokens, cursor) != 'I') { ++cursor; continue; }
        const std::string name = csec_token_text_at(tokens, cursor++);
        parameters += ", ";
        parameters += "i32 %arg." + name;
        allocas += "  %" + name + " = alloca i32\n  store i32 %arg." + name + ", ptr %" + name + "\n";
        while (cursor < paramClose && !csec_native_token_is(tokens, cursor, 'O', ",")) ++cursor;
        if (cursor < paramClose) ++cursor;
    }
    int returnStart = -1;
    int returnEnd = -1;
    for (int cursor = bodyStart; cursor < bodyEnd;) {
        const int next = csec_advance_statement(tokens, cursor, bodyEnd);
        if (csec_native_token_is(tokens, cursor, 'K', "return")) {
            returnStart = cursor + 1;
            returnEnd = next;
            break;
        }
        if (next <= cursor) break;
        cursor = next;
    }
    const bool returnsBoolean = returnStart >= 0 && csec_expression_is_boolean(tokens, returnStart, returnEnd);
    std::string definition = "define " + std::string(returnsBoolean ? "i1" : "i32") + " @" +
        csec_lambda_function_name(declaration) + "(" + parameters + ") {\nentry:\n" + allocas;
    if (returnsBoolean) {
        definition += csec_emit_i1_expression(tokens, returnStart, returnEnd, "%ret");
        definition += "  ret i1 %ret\n";
    } else {
        char* body = csec_generate_llvm_flat_body_i32(tokens, bodyStart, bodyEnd);
        if (body) definition += body;
        if (definition.find("ret i32") == std::string::npos) definition += "  ret i32 0\n";
    }
    definition += "}\n\n";
    return definition;
}

static std::string csec_lambda_definitions(const char* tokens) {
    std::string output;
    for (int cursor = 0; csec_token_kind_at(tokens, cursor) != 'E'; ++cursor) {
        if (!csec_native_token_is(tokens, cursor, 'K', "val") && !csec_native_token_is(tokens, cursor, 'K', "var")) continue;
        const int end = csec_advance_statement(tokens, cursor, 1000000000);
        if (end <= cursor) continue;
        output += csec_lambda_definition(tokens, cursor, end);
    }
    return output;
}

static int csec_enclosing_function_declaration(const char* tokens, int ordinal) {
    for (int cursor = 0; csec_token_kind_at(tokens, cursor) != 'E'; ++cursor) {
        if (!csec_native_token_is(tokens, cursor, 'K', "def")) continue;
        const int bodyStart = csec_find_decl_body_start(tokens, cursor);
        const int bodyEnd = csec_find_decl_body_end(tokens, bodyStart);
        if (bodyStart >= 0 && ordinal >= bodyStart && ordinal < bodyEnd) return cursor;
    }
    return -1;
}

static bool csec_is_function_parameter(const char* tokens, int ordinal, const char* name) {
    const int function = csec_enclosing_function_declaration(tokens, ordinal);
    if (function < 0 || !name) return false;
    for (const auto& parameter : csec_function_params(tokens, function)) {
        if (parameter.first == name) return parameter.second == "(";
    }
    return false;
}

static bool csec_is_i32_array_parameter(const char* tokens, int ordinal, const char* name) {
    const int function = csec_enclosing_function_declaration(tokens, ordinal);
    if (function < 0 || !name) return false;
    for (const auto& parameter : csec_function_params(tokens, function)) {
        if (parameter.first == name) return parameter.second == "Vector" || parameter.second == "Array";
    }
    return false;
}

static bool csec_is_i1_array_parameter(const char* tokens, int ordinal, const char* name) {
    const int function = csec_enclosing_function_declaration(tokens, ordinal);
    const int paramEnd = function >= 0 ? csec_function_param_end(tokens, function) : -1;
    if (paramEnd < 0 || !name) return false;
    for (int cursor = function; cursor < paramEnd; ++cursor) {
        if (csec_token_kind_at(tokens, cursor) != 'I' || std::strcmp(csec_token_text_at(tokens, cursor), name) != 0 ||
            !csec_native_token_is(tokens, cursor + 1, 'O', ":") ||
            !(csec_native_token_is(tokens, cursor + 2, 'I', "Vector") || csec_native_token_is(tokens, cursor + 2, 'I', "Array"))) continue;
        return csec_native_token_is(tokens, cursor + 3, 'O', "[") &&
            csec_native_token_is(tokens, cursor + 4, 'I', "Boolean") &&
            csec_native_token_is(tokens, cursor + 5, 'O', "]");
    }
    return false;
}

static bool csec_is_i8_array_parameter(const char* tokens, int ordinal, const char* name) {
    const int function = csec_enclosing_function_declaration(tokens, ordinal);
    const int paramEnd = function >= 0 ? csec_function_param_end(tokens, function) : -1;
    if (paramEnd < 0 || !name) return false;
    for (int cursor = function; cursor < paramEnd; ++cursor) {
        if (csec_token_kind_at(tokens, cursor) != 'I' || std::strcmp(csec_token_text_at(tokens, cursor), name) != 0 ||
            !csec_native_token_is(tokens, cursor + 1, 'O', ":") ||
            !(csec_native_token_is(tokens, cursor + 2, 'I', "Vector") || csec_native_token_is(tokens, cursor + 2, 'I', "Array"))) continue;
        return csec_native_token_is(tokens, cursor + 3, 'O', "[") &&
            (csec_native_token_is(tokens, cursor + 4, 'I', "Char") || csec_native_token_is(tokens, cursor + 4, 'I', "Byte")) &&
            csec_native_token_is(tokens, cursor + 5, 'O', "]");
    }
    return false;
}

static bool csec_is_i16_array_parameter(const char* tokens, int ordinal, const char* name) {
    const int function = csec_enclosing_function_declaration(tokens, ordinal);
    const int paramEnd = function >= 0 ? csec_function_param_end(tokens, function) : -1;
    if (paramEnd < 0 || !name) return false;
    for (int cursor = function; cursor < paramEnd; ++cursor) {
        if (csec_token_kind_at(tokens, cursor) != 'I' || std::strcmp(csec_token_text_at(tokens, cursor), name) != 0 ||
            !csec_native_token_is(tokens, cursor + 1, 'O', ":") ||
            !(csec_native_token_is(tokens, cursor + 2, 'I', "Vector") || csec_native_token_is(tokens, cursor + 2, 'I', "Array"))) continue;
        return csec_native_token_is(tokens, cursor + 3, 'O', "[") &&
            csec_native_token_is(tokens, cursor + 4, 'I', "Short") &&
            csec_native_token_is(tokens, cursor + 5, 'O', "]");
    }
    return false;
}

static bool csec_is_i64_array_parameter(const char* tokens, int ordinal, const char* name) {
    const int function = csec_enclosing_function_declaration(tokens, ordinal);
    const int paramEnd = function >= 0 ? csec_function_param_end(tokens, function) : -1;
    if (paramEnd < 0 || !name) return false;
    for (int cursor = function; cursor < paramEnd; ++cursor) {
        if (csec_token_kind_at(tokens, cursor) != 'I' || std::strcmp(csec_token_text_at(tokens, cursor), name) != 0 ||
            !csec_native_token_is(tokens, cursor + 1, 'O', ":") ||
            !(csec_native_token_is(tokens, cursor + 2, 'I', "Vector") || csec_native_token_is(tokens, cursor + 2, 'I', "Array"))) continue;
        return csec_native_token_is(tokens, cursor + 3, 'O', "[") &&
            (csec_native_token_is(tokens, cursor + 4, 'I', "Long") ||
             csec_native_token_is(tokens, cursor + 4, 'I', "Natural") ||
             csec_native_token_is(tokens, cursor + 4, 'I', "Integer")) &&
            csec_native_token_is(tokens, cursor + 5, 'O', "]");
    }
    return false;
}

static bool csec_is_f32_array_parameter(const char* tokens, int ordinal, const char* name) {
    const int function = csec_enclosing_function_declaration(tokens, ordinal);
    const int paramEnd = function >= 0 ? csec_function_param_end(tokens, function) : -1;
    if (paramEnd < 0 || !name) return false;
    for (int cursor = function; cursor < paramEnd; ++cursor) {
        if (csec_token_kind_at(tokens, cursor) != 'I' || std::strcmp(csec_token_text_at(tokens, cursor), name) != 0 ||
            !csec_native_token_is(tokens, cursor + 1, 'O', ":") ||
            !(csec_native_token_is(tokens, cursor + 2, 'I', "Vector") || csec_native_token_is(tokens, cursor + 2, 'I', "Array"))) continue;
        return csec_native_token_is(tokens, cursor + 3, 'O', "[") &&
            csec_native_token_is(tokens, cursor + 4, 'I', "Float") &&
            csec_native_token_is(tokens, cursor + 5, 'O', "]");
    }
    return false;
}

static bool csec_is_f64_array_parameter(const char* tokens, int ordinal, const char* name) {
    const int function = csec_enclosing_function_declaration(tokens, ordinal);
    const int paramEnd = function >= 0 ? csec_function_param_end(tokens, function) : -1;
    if (paramEnd < 0 || !name) return false;
    for (int cursor = function; cursor < paramEnd; ++cursor) {
        if (csec_token_kind_at(tokens, cursor) != 'I' || std::strcmp(csec_token_text_at(tokens, cursor), name) != 0 ||
            !csec_native_token_is(tokens, cursor + 1, 'O', ":") ||
            !(csec_native_token_is(tokens, cursor + 2, 'I', "Vector") || csec_native_token_is(tokens, cursor + 2, 'I', "Array"))) continue;
        return csec_native_token_is(tokens, cursor + 3, 'O', "[") &&
            csec_native_token_is(tokens, cursor + 4, 'I', "Double") &&
            csec_native_token_is(tokens, cursor + 5, 'O', "]");
    }
    return false;
}

static bool csec_is_ptr_array_parameter(const char* tokens, int ordinal, const char* name) {
    const int function = csec_enclosing_function_declaration(tokens, ordinal);
    const int paramEnd = function >= 0 ? csec_function_param_end(tokens, function) : -1;
    if (paramEnd < 0 || !name) return false;
    for (int cursor = function; cursor < paramEnd; ++cursor) {
        if (csec_token_kind_at(tokens, cursor) != 'I' || std::strcmp(csec_token_text_at(tokens, cursor), name) != 0 ||
            !csec_native_token_is(tokens, cursor + 1, 'O', ":") ||
            !(csec_native_token_is(tokens, cursor + 2, 'I', "Vector") || csec_native_token_is(tokens, cursor + 2, 'I', "Array"))) continue;
        return csec_native_token_is(tokens, cursor + 3, 'O', "[") &&
            csec_native_token_is(tokens, cursor + 4, 'I', "String") &&
            csec_native_token_is(tokens, cursor + 5, 'O', "]");
    }
    return false;
}

static bool csec_is_pointer_parameter(const char* tokens, int ordinal, const char* name) {
    if (!name) return false;
    int function = csec_enclosing_function_declaration(tokens, ordinal);
    if (function < 0) {
        for (int cursor = 0; csec_token_kind_at(tokens, cursor) != 'E';) {
            const int next = csec_advance_top_level_decl(tokens, cursor);
            if (next <= cursor) break;
            if (csec_native_token_is(tokens, cursor, 'K', "def") && ordinal >= cursor && ordinal < next) {
                function = cursor;
                break;
            }
            cursor = next;
        }
    }
    if (function < 0) return false;
    for (const auto& parameter : csec_function_params(tokens, function)) {
        if (parameter.first == name) return std::strcmp(csec_llvm_type_for_name(parameter.second), "ptr") == 0;
    }
    return false;
}

static bool csec_is_pointer_local(const char* tokens, int ordinal, const char* name) {
    const int declaration = csec_find_visible_local(tokens, ordinal, name);
    if (declaration < 0) return false;
    const int end = csec_advance_statement(tokens, declaration, 1000000000);
    const int initializer = csec_find_top_level_operator(tokens, declaration, end, 1);
    return std::strcmp(csec_llvm_type_for_name(csec_c_local_type(tokens, declaration, end, initializer)), "ptr") == 0;
}

static bool csec_is_boolean_parameter(const char* tokens, int ordinal, const char* name) {
    const int function = csec_enclosing_function_declaration(tokens, ordinal);
    if (function < 0 || !name) return false;
    for (const auto& parameter : csec_function_params(tokens, function)) {
        if (parameter.first == name) return parameter.second == "Boolean";
    }
    return false;
}

static bool csec_is_boolean_local(const char* tokens, int ordinal, const char* name) {
    const int declaration = csec_find_visible_local(tokens, ordinal, name);
    if (declaration < 0) return false;
    const int end = csec_advance_statement(tokens, declaration, 1000000000);
    const int initializer = csec_find_top_level_operator(tokens, declaration, end, 1);
    return csec_c_local_type(tokens, declaration, end, initializer) == "Boolean";
}

static bool csec_is_float_parameter(const char* tokens, int ordinal, const char* name) {
    const int function = csec_enclosing_function_declaration(tokens, ordinal);
    if (function < 0 || !name) return false;
    for (const auto& parameter : csec_function_params(tokens, function)) {
        if (parameter.first == name) return parameter.second == "Float";
    }
    return false;
}

static bool csec_is_float_local(const char* tokens, int ordinal, const char* name) {
    const int declaration = csec_find_visible_local(tokens, ordinal, name);
    if (declaration < 0) return false;
    const int end = csec_advance_statement(tokens, declaration, 1000000000);
    const int initializer = csec_find_top_level_operator(tokens, declaration, end, 1);
    return csec_c_local_type(tokens, declaration, end, initializer) == "Float";
}

static bool csec_is_double_parameter(const char* tokens, int ordinal, const char* name) {
    const int function = csec_enclosing_function_declaration(tokens, ordinal);
    if (function < 0 || !name) return false;
    for (const auto& parameter : csec_function_params(tokens, function)) {
        if (parameter.first == name) return parameter.second == "Double";
    }
    return false;
}

static bool csec_is_double_local(const char* tokens, int ordinal, const char* name) {
    const int declaration = csec_find_visible_local(tokens, ordinal, name);
    if (declaration < 0) return false;
    const int end = csec_advance_statement(tokens, declaration, 1000000000);
    const int initializer = csec_find_top_level_operator(tokens, declaration, end, 1);
    return csec_c_local_type(tokens, declaration, end, initializer) == "Double";
}

static bool csec_is_string_parameter(const char* tokens, int ordinal, const char* name) {
    const int function = csec_enclosing_function_declaration(tokens, ordinal);
    if (function < 0 || !name) return false;
    for (const auto& parameter : csec_function_params(tokens, function)) {
        if (parameter.first == name) return parameter.second == "String";
    }
    return false;
}

static bool csec_is_string_class_constructor_param(const char* tokens, int ordinal, const char* name) {
    const int classStart = csec_enclosing_class_declaration(tokens, ordinal);
    if (classStart < 0 || !name) return false;
    for (const auto& parameter : csec_class_constructor_params(tokens, classStart)) {
        if (parameter.first == name) return parameter.second == "String";
    }
    for (const auto& field : csec_class_ptr_fields(tokens, classStart)) {
        const size_t suffix = field.first.find(".addr.");
        if (suffix != std::string::npos && field.first.substr(0, suffix) == name) return true;
    }
    return false;
}

static bool csec_is_string_local(const char* tokens, int ordinal, const char* name) {
    const int declaration = csec_find_visible_local(tokens, ordinal, name);
    if (declaration < 0) return false;
    const int end = csec_advance_statement(tokens, declaration, 1000000000);
    const int initializer = csec_find_top_level_operator(tokens, declaration, end, 1);
    return csec_c_local_type(tokens, declaration, end, initializer) == "String";
}

static bool csec_is_string_expression(const char* tokens, int start, int end) {
    end = csec_i32_expression_end(tokens, start, end);
    if (end == start + 1) {
        if (csec_token_kind_at(tokens, start) == 'S') return true;
        return csec_token_kind_at(tokens, start) == 'I' &&
            (csec_is_string_local(tokens, start, csec_token_text_at(tokens, start)) ||
            csec_is_string_parameter(tokens, start, csec_token_text_at(tokens, start)) ||
            csec_is_string_class_constructor_param(tokens, start, csec_token_text_at(tokens, start)));
    }
    if (csec_token_kind_at(tokens, start) == 'I' && start + 4 < end &&
        csec_native_token_is(tokens, start + 1, 'O', ".") && csec_token_kind_at(tokens, start + 2) == 'I' &&
        csec_native_token_is(tokens, start + 3, 'O', "(") &&
        csec_find_closing_token(tokens, start + 3, end, "(", ")") == end - 1 &&
        csec_is_string_expression(tokens, start, start + 1)) {
        const char* method = csec_token_text_at(tokens, start + 2);
        return std::strcmp(method, "trim") == 0 || std::strcmp(method, "toUpper") == 0 ||
            std::strcmp(method, "toLower") == 0 || std::strcmp(method, "toString") == 0 ||
            std::strcmp(method, "substring") == 0;
    }
    const int operation = csec_i32_top_level_operator(tokens, start, end);
    return operation >= start && std::strcmp(csec_token_text_at(tokens, operation), "+") == 0 &&
        csec_is_string_expression(tokens, start, operation) &&
        csec_is_string_expression(tokens, operation + 1, end);
}

static bool csec_function_parameter_returns_boolean(const char* tokens, int ordinal, const char* name) {
    const int function = csec_enclosing_function_declaration(tokens, ordinal);
    const int paramEnd = function >= 0 ? csec_function_param_end(tokens, function) : -1;
    if (paramEnd < 0 || !name) return false;
    for (int cursor = function; cursor < paramEnd; ++cursor) {
        if (csec_token_kind_at(tokens, cursor) != 'I' || std::strcmp(csec_token_text_at(tokens, cursor), name) != 0 ||
            !csec_native_token_is(tokens, cursor + 1, 'O', ":") ||
            !csec_native_token_is(tokens, cursor + 2, 'O', "(")) continue;
        const int close = csec_find_closing_token(tokens, cursor + 2, paramEnd, "(", ")");
        return close >= 0 && csec_native_token_is(tokens, close + 1, 'O', "=>") &&
            std::strcmp(csec_token_text_at(tokens, close + 2), "Boolean") == 0;
    }
    return false;
}

static int csec_top_level_function_declaration(const char* tokens, const char* name) {
    for (int cursor = 0; csec_token_kind_at(tokens, cursor) != 'E';) {
        const int next = csec_advance_top_level_decl(tokens, cursor);
        if (next <= cursor) break;
        if (std::strcmp(csec_top_level_decl_kind(tokens, cursor), "function") == 0 &&
            std::strcmp(csec_top_level_decl_name(tokens, cursor), name ? name : "") == 0) return cursor;
        cursor = next;
    }
    return -1;
}

static bool csec_expression_is_boolean(const char* tokens, int start, int end) {
    end = csec_i32_expression_end(tokens, start, end);
    if (end <= start) return false;
    if (csec_native_token_is(tokens, start, 'O', "(") &&
        csec_find_closing_token(tokens, start, end, "(", ")") == end - 1) {
        return csec_expression_is_boolean(tokens, start + 1, end - 1);
    }
    if (csec_native_token_is(tokens, start, 'O', "!")) return true;
    if (csec_token_kind_at(tokens, start) == 'B') return true;
    for (int cursor = start; cursor < end; ++cursor) {
        const char* text = csec_token_text_at(tokens, cursor);
        if (std::strcmp(text, "==") == 0 || std::strcmp(text, "!=") == 0 ||
            std::strcmp(text, "<") == 0 || std::strcmp(text, "<=") == 0 ||
            std::strcmp(text, ">") == 0 || std::strcmp(text, ">=") == 0 ||
            std::strcmp(text, "&&") == 0 || std::strcmp(text, "||") == 0 ||
            std::strcmp(text, "and") == 0 || std::strcmp(text, "or") == 0) return true;
    }
    if (csec_token_kind_at(tokens, start) == 'I' && start + 1 < end && csec_native_token_is(tokens, start + 1, 'O', "(")) {
        if (csec_function_parameter_returns_boolean(tokens, start, csec_token_text_at(tokens, start))) return true;
        const int function = csec_top_level_function_declaration(tokens, csec_token_text_at(tokens, start));
        return function >= 0 && std::strcmp(csec_function_return_type_at(tokens, function), "Boolean") == 0;
    }
    return false;
}

static int csec_find_class_method_declaration(const char* tokens, int classStart, const char* methodName) {
    const int bodyStart = csec_find_decl_body_start(tokens, classStart);
    const int bodyEnd = csec_find_decl_body_end(tokens, bodyStart);
    for (int cursor = bodyStart; cursor >= 0 && cursor < bodyEnd; ++cursor) {
        if (csec_native_token_is(tokens, cursor, 'K', "def") &&
            std::strcmp(csec_top_level_decl_name(tokens, cursor), methodName ? methodName : "") == 0) return cursor;
    }
    return -1;
}

static bool csec_expression_is_float(const char* tokens, int start, int end) {
    end = csec_i32_expression_end(tokens, start, end);
    if (end <= start) return false;
    if (csec_native_token_is(tokens, start, 'O', "(") &&
        csec_find_closing_token(tokens, start, end, "(", ")") == end - 1) {
        return csec_expression_is_float(tokens, start + 1, end - 1);
    }
    if ((csec_native_token_is(tokens, start, 'O', "+") || csec_native_token_is(tokens, start, 'O', "-")) && start + 1 < end) {
        return csec_expression_is_float(tokens, start + 1, end);
    }
    if (csec_token_kind_at(tokens, start) == 'F') return true;
    const int operation = csec_i32_top_level_operator(tokens, start, end);
    if (operation >= start) {
        return csec_expression_is_float(tokens, start, operation) ||
            csec_expression_is_float(tokens, operation + 1, end);
    }
    if (csec_token_kind_at(tokens, start) != 'I') return false;
    if (start + 1 < end && csec_native_token_is(tokens, start + 1, 'O', "[") &&
        csec_visible_f32_array(tokens, start, csec_token_text_at(tokens, start))) return true;
    if (start + 1 == end) {
        return csec_is_float_local(tokens, start, csec_token_text_at(tokens, start)) ||
            csec_is_float_parameter(tokens, start, csec_token_text_at(tokens, start));
    }
    if (csec_native_token_is(tokens, start + 1, 'O', "(")) {
        const int function = csec_top_level_function_declaration(tokens, csec_token_text_at(tokens, start));
        return function >= 0 && std::strcmp(csec_function_return_type_at(tokens, function), "Float") == 0;
    }
    if (start + 3 < end && csec_native_token_is(tokens, start + 1, 'O', ".") &&
        csec_token_kind_at(tokens, start + 2) == 'I' && csec_native_token_is(tokens, start + 3, 'O', "(")) {
        const int declaration = csec_find_visible_local(tokens, start, csec_token_text_at(tokens, start));
        const int declarationEnd = declaration >= 0 ? csec_advance_statement(tokens, declaration, 1000000000) : -1;
        const int initializer = declaration >= 0 ? csec_find_top_level_operator(tokens, declaration, declarationEnd, 1) : -1;
        if (initializer >= declaration && csec_native_token_is(tokens, initializer + 1, 'K', "new") &&
            csec_token_kind_at(tokens, initializer + 2) == 'I') {
            const int classStart = csec_find_class_declaration(tokens, csec_token_text_at(tokens, initializer + 2));
            const int method = classStart >= 0 ? csec_find_class_method_declaration(tokens, classStart, csec_token_text_at(tokens, start + 2)) : -1;
            return method >= 0 && std::strcmp(csec_function_return_type_at(tokens, method), "Float") == 0;
        }
    }
    return false;
}

static bool csec_expression_is_double(const char* tokens, int start, int end) {
    end = csec_i32_expression_end(tokens, start, end);
    if (end <= start) return false;
    if (csec_native_token_is(tokens, start, 'O', "(") && csec_find_closing_token(tokens, start, end, "(", ")") == end - 1)
        return csec_expression_is_double(tokens, start + 1, end - 1);
    if ((csec_native_token_is(tokens, start, 'O', "+") || csec_native_token_is(tokens, start, 'O', "-")) && start + 1 < end)
        return csec_expression_is_double(tokens, start + 1, end);
    const int operation = csec_i32_top_level_operator(tokens, start, end);
    if (operation >= start)
        return csec_expression_is_double(tokens, start, operation) || csec_expression_is_double(tokens, operation + 1, end);
    if (csec_token_kind_at(tokens, start) != 'I') return false;
    if (start + 1 < end && csec_native_token_is(tokens, start + 1, 'O', "[") &&
        csec_visible_f64_array(tokens, start, csec_token_text_at(tokens, start))) return true;
    if (start + 1 == end)
        return csec_is_double_local(tokens, start, csec_token_text_at(tokens, start)) || csec_is_double_parameter(tokens, start, csec_token_text_at(tokens, start));
    if (csec_native_token_is(tokens, start + 1, 'O', "(")) {
        const int function = csec_top_level_function_declaration(tokens, csec_token_text_at(tokens, start));
        return function >= 0 && std::strcmp(csec_function_return_type_at(tokens, function), "Double") == 0;
    }
    return false;
}

static bool csec_emit_i32_instance_call(const char* tokens, int start, int end, const std::string& resultName, std::string& output) {
    if (csec_token_kind_at(tokens, start) != 'I' || start + 3 >= end ||
        !csec_native_token_is(tokens, start + 1, 'O', ".") || csec_token_kind_at(tokens, start + 2) != 'I' ||
        !csec_native_token_is(tokens, start + 3, 'O', "(")) return false;
    const int callClose = csec_find_closing_token(tokens, start + 3, end, "(", ")");
    if (callClose != end - 1) return false;
    const int declaration = csec_find_visible_local(tokens, start, csec_token_text_at(tokens, start));
    const int declarationEnd = declaration >= 0 ? csec_advance_statement(tokens, declaration, 1000000000) : -1;
    const int initializer = declaration >= 0 ? csec_find_top_level_operator(tokens, declaration, declarationEnd, 1) : -1;
    const int instanceStart = initializer + 1;
    if (initializer < declaration || !csec_native_token_is(tokens, instanceStart, 'K', "new") ||
        csec_token_kind_at(tokens, instanceStart + 1) != 'I' || !csec_native_token_is(tokens, instanceStart + 2, 'O', "(")) return false;
    const int constructorClose = csec_find_closing_token(tokens, instanceStart + 2, declarationEnd, "(", ")");
    if (constructorClose < instanceStart + 2) return false;

    std::string arguments;
    int argumentIndex = 0;
    auto appendArguments = [&](int first, int close) {
        for (int cursor = first, itemStart = first; cursor <= close; ++cursor) {
            if (cursor == close || csec_is_argument_separator(tokens, close, cursor)) {
                if (cursor > itemStart) {
                    const std::string value = resultName + ".arg" + std::to_string(argumentIndex++);
                    output += csec_emit_i32_expression(tokens, itemStart, cursor, value);
                    if (!arguments.empty()) arguments += ", ";
                    arguments += "i32 " + value;
                }
                itemStart = cursor + 1;
            }
        }
    };
    const char* className = csec_token_text_at(tokens, instanceStart + 1);
    const int classStart = csec_find_class_declaration(tokens, className);
    if (classStart >= 0 && csec_class_uses_pointer_receiver(tokens, classStart)) {
        const std::string receiver = resultName + ".this";
        const char* storage = csec_lookup_visible_storage_name(tokens, start, csec_token_text_at(tokens, start));
        output += "  " + receiver + " = load ptr, ptr %" + std::string(storage) + "\n";
        arguments = "ptr " + receiver;
    } else appendArguments(instanceStart + 3, constructorClose);
    appendArguments(start + 4, callClose);
    const int methodStart = classStart >= 0 ? csec_find_class_method_declaration(tokens, classStart, csec_token_text_at(tokens, start + 2)) : -1;
    if (methodStart >= 0 && std::strcmp(csec_function_return_type_at(tokens, methodStart), "Boolean") == 0) {
        const std::string booleanResult = resultName + ".i1";
        output += "  " + booleanResult + " = call i1 @" + std::string(className) +
            "_" + csec_token_text_at(tokens, start + 2) + "(" + arguments + ")\n";
        output += "  " + resultName + " = zext i1 " + booleanResult + " to i32\n";
    } else output += "  " + resultName + " = call i32 @" + std::string(className) +
        "_" + csec_token_text_at(tokens, start + 2) + "(" + arguments + ")\n";
    return true;
}

static bool csec_emit_ptr_instance_call(const char* tokens, int start, int end, const std::string& resultName, std::string& output) {
    if (csec_token_kind_at(tokens, start) != 'I' || start + 5 != end ||
        !csec_native_token_is(tokens, start + 1, 'O', ".") || csec_token_kind_at(tokens, start + 2) != 'I' ||
        !csec_native_token_is(tokens, start + 3, 'O', "(") || !csec_native_token_is(tokens, start + 4, 'O', ")")) return false;
    const int declaration = csec_find_visible_local(tokens, start, csec_token_text_at(tokens, start));
    const int declarationEnd = declaration >= 0 ? csec_advance_statement(tokens, declaration, 1000000000) : -1;
    const int initializer = declaration >= 0 ? csec_find_top_level_operator(tokens, declaration, declarationEnd, 1) : -1;
    const int instanceStart = initializer + 1;
    if (initializer < declaration || !csec_native_token_is(tokens, instanceStart, 'K', "new") ||
        csec_token_kind_at(tokens, instanceStart + 1) != 'I') return false;
    const char* className = csec_token_text_at(tokens, instanceStart + 1);
    const int classStart = csec_find_class_declaration(tokens, className);
    const int methodStart = classStart >= 0 ? csec_find_class_method_declaration(tokens, classStart, csec_token_text_at(tokens, start + 2)) : -1;
    if (methodStart < 0 || std::strcmp(csec_function_return_type_at(tokens, methodStart), "String") != 0 ||
        !csec_class_uses_pointer_receiver(tokens, classStart)) return false;
    const char* storage = csec_lookup_visible_storage_name(tokens, start, csec_token_text_at(tokens, start));
    const std::string receiver = resultName + ".this";
    output = "  " + receiver + " = load ptr, ptr %" + std::string(storage) + "\n" +
        "  " + resultName + " = call ptr @" + std::string(className) + "_" + csec_token_text_at(tokens, start + 2) + "(ptr " + receiver + ")\n";
    return true;
}
