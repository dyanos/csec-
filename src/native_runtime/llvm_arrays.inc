static std::string csec_emit_i32_block_expression(const char* tokens, int start, int end, const std::string& resultName) {
    std::string output;
    int cursor = csec_expression_ast_skip_trivia(tokens, start + 1);
    const int close = end - 1;
    while (cursor >= 0 && cursor < close && csec_token_kind_at(tokens, cursor) != 'E') {
        const int next = csec_advance_statement(tokens, cursor, close);
        if (next <= cursor) break;
        const bool declaration = csec_native_token_is(tokens, cursor, 'K', "val") ||
            csec_native_token_is(tokens, cursor, 'K', "var");
        if (declaration && csec_token_kind_at(tokens, cursor + 1) == 'I') {
            const std::string name = csec_token_text_at(tokens, cursor + 1);
            const std::string storage = name + ".addr." + std::to_string(cursor);
            const int initializer = csec_find_token_text_in_range(tokens, cursor + 2, next, "=");
            output += "  %" + storage + " = alloca i32\n";
            if (initializer >= 0 && initializer + 1 < next) {
                const std::string value = "%" + name + ".init." + std::to_string(cursor);
                output += csec_emit_i32_expression(tokens, initializer + 1, next, value);
                output += "  store i32 " + value + ", ptr %" + storage + "\n";
            } else {
                output += "  store i32 0, ptr %" + storage + "\n";
            }
        } else if (next >= close) {
            output += csec_emit_i32_expression(tokens, cursor, next, resultName);
            return output;
        }
        cursor = csec_expression_ast_skip_trivia(tokens, next);
    }
    return output + "  " + resultName + " = add i32 0, 0\n";
}

static std::string csec_emit_i32_match_expression(const char* tokens, int start, int end, int matchToken, const std::string& resultName) {
    struct MatchCase { int patternStart; int expressionStart; int expressionEnd; bool fallback; };
    const int openBrace = csec_find_token_text_in_range(tokens, matchToken + 1, end, "{");
    const int closeBrace = openBrace >= 0 ? csec_find_closing_token(tokens, openBrace, end, "{", "}") : -1;
    if (openBrace < 0 || closeBrace != end - 1) return "  " + resultName + " = add i32 0, 0\n";

    std::vector<MatchCase> cases;
    for (int cursor = openBrace + 1; cursor < closeBrace;) {
        if (!csec_native_token_is(tokens, cursor, 'K', "case")) { ++cursor; continue; }
        const int arrow = csec_find_token_text_in_range(tokens, cursor + 1, closeBrace, "=>");
        if (arrow < 0) break;
        int nextCase = closeBrace;
        for (int probe = arrow + 1; probe < closeBrace; ++probe) {
            if (csec_native_token_is(tokens, probe, 'K', "case")) { nextCase = probe; break; }
        }
        cases.push_back({cursor + 1, arrow + 1, nextCase, csec_native_token_is(tokens, cursor + 1, 'I', "_")});
        cursor = nextCase;
    }
    if (cases.empty()) return "  " + resultName + " = add i32 0, 0\n";

    std::string output;
    const std::string subject = resultName + ".match.subject";
    output += csec_emit_i32_expression(tokens, start, matchToken, subject);
    const MatchCase* fallback = nullptr;
    for (const MatchCase& item : cases) if (item.fallback) { fallback = &item; break; }
    std::string value = resultName + ".match.default";
    if (fallback) output += csec_emit_i32_expression(tokens, fallback->expressionStart, fallback->expressionEnd, value);
    else output += "  " + value + " = add i32 0, 0\n";
    for (int index = static_cast<int>(cases.size()) - 1; index >= 0; --index) {
        const MatchCase& item = cases[static_cast<size_t>(index)];
        if (item.fallback) continue;
        const std::string pattern = resultName + ".match.pattern." + std::to_string(index);
        const std::string branchValue = resultName + ".match.value." + std::to_string(index);
        const std::string comparison = resultName + ".match.comparison." + std::to_string(index);
        const std::string selected = resultName + ".match.selected." + std::to_string(index);
        output += csec_emit_i32_expression(tokens, item.patternStart, item.expressionStart - 1, pattern);
        output += csec_emit_i32_expression(tokens, item.expressionStart, item.expressionEnd, branchValue);
        output += "  " + comparison + " = icmp eq i32 " + subject + ", " + pattern + "\n";
        output += "  " + selected + " = select i1 " + comparison + ", i32 " + branchValue + ", i32 " + value + "\n";
        value = selected;
    }
    return output + "  " + resultName + " = add i32 0, " + value + "\n";
}

static bool csec_i32_static_index(const char* tokens, int start, int end, int* value) {
    if (!value || end != start + 1 || csec_token_kind_at(tokens, start) != 'N') return false;
    *value = static_cast<int>(std::strtoll(csec_token_text_at(tokens, start), nullptr, 0));
    return *value >= 0;
}

static bool csec_literal_array_item(const char* tokens, int open, int close, int wanted, int* itemStart, int* itemEnd) {
    int item = 0;
    int start = open + 1;
    int paren = 0;
    int bracket = 0;
    int brace = 0;
    for (int cursor = start; cursor <= close; ++cursor) {
        const char* text = cursor < close ? csec_token_text_at(tokens, cursor) : ",";
        if (cursor < close && std::strcmp(text, "(") == 0) ++paren;
        else if (cursor < close && std::strcmp(text, ")") == 0) --paren;
        else if (cursor < close && std::strcmp(text, "[") == 0) ++bracket;
        else if (cursor < close && std::strcmp(text, "]") == 0) --bracket;
        else if (cursor < close && std::strcmp(text, "{") == 0) ++brace;
        else if (cursor < close && std::strcmp(text, "}") == 0) --brace;
        if ((cursor == close || (std::strcmp(text, ",") == 0 && paren == 0 && bracket == 0 && brace == 0)) && cursor > start) {
            if (item == wanted) {
                *itemStart = start;
                *itemEnd = cursor;
                return true;
            }
            ++item;
            start = cursor + 1;
        }
    }
    return false;
}

static std::string csec_emit_i32_literal_array_index(const char* tokens, int start, int end, const std::string& resultName) {
    if (csec_token_kind_at(tokens, start) != 'I' || !csec_native_token_is(tokens, start + 1, 'O', "[")) return "";
    const int declaration = csec_find_visible_local(tokens, start, csec_token_text_at(tokens, start));
    const int declarationEnd = declaration >= 0 ? csec_advance_statement(tokens, declaration, csec_token_kind_at(tokens, declaration) == 'E' ? declaration : 1000000000) : -1;
    const int initializer = declaration >= 0 ? csec_find_token_text_in_range(tokens, declaration + 2, declarationEnd, "=") : -1;
    if (initializer < 0 || !csec_native_token_is(tokens, initializer + 1, 'O', "[")) return "";
    int itemStart = initializer + 1;
    int itemEnd = csec_find_closing_token(tokens, itemStart, declarationEnd, "[", "]");
    int cursor = start + 1;
    while (cursor < end && csec_native_token_is(tokens, cursor, 'O', "[")) {
        const int close = csec_find_closing_token(tokens, cursor, end, "[", "]");
        int index = 0;
        if (close < 0 || !csec_i32_static_index(tokens, cursor + 1, close, &index) ||
            !csec_literal_array_item(tokens, itemStart, itemEnd, index, &itemStart, &itemEnd)) return "";
        cursor = close + 1;
        if (cursor < end) {
            if (!csec_native_token_is(tokens, itemStart, 'O', "[")) return "";
            itemEnd = csec_find_closing_token(tokens, itemStart, itemEnd, "[", "]");
        }
    }
    if (cursor != end || itemStart >= itemEnd) return "";
    return csec_emit_i32_expression(tokens, itemStart, itemEnd, resultName);
}

static bool csec_is_i32_array_initializer(const char* tokens, int initializer, int end) {
    return initializer >= 0 && initializer + 1 < end &&
        (csec_native_token_is(tokens, initializer + 1, 'O', "[") ||
         (csec_native_token_is(tokens, initializer + 1, 'K', "new") &&
          csec_native_token_is(tokens, initializer + 2, 'I', "Int") &&
          csec_native_token_is(tokens, initializer + 3, 'O', "[")));
}

static bool csec_visible_i32_array(const char* tokens, int limit, const char* name) {
    const int declaration = csec_find_visible_local(tokens, limit, name);
    if (declaration < 0) return csec_is_i32_array_parameter(tokens, limit, name);
    const int declarationEnd = csec_advance_statement(tokens, declaration, 1000000000);
    const int initializer = csec_find_token_text_in_range(tokens, declaration + 2, declarationEnd, "=");
    const std::string type = csec_c_local_type(tokens, declaration, declarationEnd, initializer);
    return csec_is_i32_array_initializer(tokens, initializer, declarationEnd) || type == "Vector[Int]" || type == "Array[Int]";
}

static bool csec_is_i1_array_initializer(const char* tokens, int initializer, int end) {
    if (initializer < 0 || initializer + 1 >= end) return false;
    if (csec_native_token_is(tokens, initializer + 1, 'K', "new")) {
        return csec_native_token_is(tokens, initializer + 2, 'I', "Boolean") &&
            csec_native_token_is(tokens, initializer + 3, 'O', "[");
    }
    if (!csec_native_token_is(tokens, initializer + 1, 'O', "[")) return false;
    const int close = csec_find_closing_token(tokens, initializer + 1, end, "[", "]");
    return close > initializer + 2 && csec_token_kind_at(tokens, initializer + 2) == 'B';
}

static bool csec_visible_i1_array(const char* tokens, int limit, const char* name) {
    const int declaration = csec_find_visible_local(tokens, limit, name);
    if (declaration < 0) return csec_is_i1_array_parameter(tokens, limit, name);
    const int declarationEnd = csec_advance_statement(tokens, declaration, 1000000000);
    const int initializer = csec_find_token_text_in_range(tokens, declaration + 2, declarationEnd, "=");
    const std::string type = csec_c_local_type(tokens, declaration, declarationEnd, initializer);
    return csec_is_i1_array_initializer(tokens, initializer, declarationEnd) || type == "Vector[Boolean]" || type == "Array[Boolean]";
}

static bool csec_is_i8_array_initializer(const char* tokens, int initializer, int end) {
    if (initializer < 0 || initializer + 1 >= end) return false;
    if (csec_native_token_is(tokens, initializer + 1, 'K', "new")) {
        return (csec_native_token_is(tokens, initializer + 2, 'I', "Char") || csec_native_token_is(tokens, initializer + 2, 'I', "Byte")) &&
            csec_native_token_is(tokens, initializer + 3, 'O', "[");
    }
    return csec_native_token_is(tokens, initializer + 1, 'O', "[") && initializer + 2 < end &&
        csec_token_kind_at(tokens, initializer + 2) == 'C';
}

static bool csec_visible_i8_array(const char* tokens, int limit, const char* name) {
    const int declaration = csec_find_visible_local(tokens, limit, name);
    if (declaration < 0) return csec_is_i8_array_parameter(tokens, limit, name);
    const int declarationEnd = csec_advance_statement(tokens, declaration, 1000000000);
    const int initializer = csec_find_token_text_in_range(tokens, declaration + 2, declarationEnd, "=");
    const std::string type = csec_c_local_type(tokens, declaration, declarationEnd, initializer);
    return csec_is_i8_array_initializer(tokens, initializer, declarationEnd) ||
        type == "Vector[Char]" || type == "Array[Char]" || type == "Vector[Byte]" || type == "Array[Byte]";
}

static bool csec_is_i16_array_initializer(const char* tokens, int initializer, int end) {
    if (initializer < 0 || initializer + 1 >= end) return false;
    if (csec_native_token_is(tokens, initializer + 1, 'K', "new")) {
        return csec_native_token_is(tokens, initializer + 2, 'I', "Short") &&
            csec_native_token_is(tokens, initializer + 3, 'O', "[");
    }
    return csec_native_token_is(tokens, initializer + 1, 'O', "[") && initializer + 2 < end &&
        csec_token_kind_at(tokens, initializer + 2) == 'N';
}

static bool csec_visible_i16_array(const char* tokens, int limit, const char* name) {
    const int declaration = csec_find_visible_local(tokens, limit, name);
    if (declaration < 0) return csec_is_i16_array_parameter(tokens, limit, name);
    const int declarationEnd = csec_advance_statement(tokens, declaration, 1000000000);
    const int initializer = csec_find_token_text_in_range(tokens, declaration + 2, declarationEnd, "=");
    const std::string type = csec_c_local_type(tokens, declaration, declarationEnd, initializer);
    return csec_is_i16_array_initializer(tokens, initializer, declarationEnd) || type == "Vector[Short]" || type == "Array[Short]";
}

static bool csec_is_f32_array_initializer(const char* tokens, int initializer, int end) {
    if (initializer < 0 || initializer + 1 >= end) return false;
    if (csec_native_token_is(tokens, initializer + 1, 'K', "new")) {
        return csec_native_token_is(tokens, initializer + 2, 'I', "Float") &&
            csec_native_token_is(tokens, initializer + 3, 'O', "[");
    }
    return csec_native_token_is(tokens, initializer + 1, 'O', "[") && initializer + 2 < end &&
        csec_token_kind_at(tokens, initializer + 2) == 'F';
}

static bool csec_visible_f32_array(const char* tokens, int limit, const char* name) {
    const int declaration = csec_find_visible_local(tokens, limit, name);
    if (declaration < 0) return csec_is_f32_array_parameter(tokens, limit, name);
    const int declarationEnd = csec_advance_statement(tokens, declaration, 1000000000);
    const int initializer = csec_find_token_text_in_range(tokens, declaration + 2, declarationEnd, "=");
    const std::string type = csec_c_local_type(tokens, declaration, declarationEnd, initializer);
    return csec_is_f32_array_initializer(tokens, initializer, declarationEnd) || type == "Vector[Float]" || type == "Array[Float]";
}

static bool csec_is_f64_array_initializer(const char* tokens, int initializer, int end) {
    if (initializer < 0 || initializer + 1 >= end) return false;
    if (csec_native_token_is(tokens, initializer + 1, 'K', "new")) {
        return csec_native_token_is(tokens, initializer + 2, 'I', "Double") &&
            csec_native_token_is(tokens, initializer + 3, 'O', "[");
    }
    return csec_native_token_is(tokens, initializer + 1, 'O', "[") && initializer + 2 < end &&
        csec_token_kind_at(tokens, initializer + 2) == 'F';
}

static bool csec_visible_f64_array(const char* tokens, int limit, const char* name) {
    const int declaration = csec_find_visible_local(tokens, limit, name);
    if (declaration < 0) return csec_is_f64_array_parameter(tokens, limit, name);
    const int declarationEnd = csec_advance_statement(tokens, declaration, 1000000000);
    const int initializer = csec_find_token_text_in_range(tokens, declaration + 2, declarationEnd, "=");
    const std::string type = csec_c_local_type(tokens, declaration, declarationEnd, initializer);
    return csec_is_f64_array_initializer(tokens, initializer, declarationEnd) || type == "Vector[Double]" || type == "Array[Double]";
}

static bool csec_is_ptr_array_initializer(const char* tokens, int initializer, int end) {
    if (initializer < 0 || initializer + 1 >= end) return false;
    if (csec_native_token_is(tokens, initializer + 1, 'K', "new")) {
        return csec_native_token_is(tokens, initializer + 2, 'I', "String") &&
            csec_native_token_is(tokens, initializer + 3, 'O', "[");
    }
    return csec_native_token_is(tokens, initializer + 1, 'O', "[") && initializer + 2 < end &&
        csec_token_kind_at(tokens, initializer + 2) == 'S';
}

static bool csec_visible_ptr_array(const char* tokens, int limit, const char* name) {
    const int declaration = csec_find_visible_local(tokens, limit, name);
    if (declaration < 0) return csec_is_ptr_array_parameter(tokens, limit, name);
    const int declarationEnd = csec_advance_statement(tokens, declaration, 1000000000);
    const int initializer = csec_find_token_text_in_range(tokens, declaration + 2, declarationEnd, "=");
    const std::string type = csec_c_local_type(tokens, declaration, declarationEnd, initializer);
    return csec_is_ptr_array_initializer(tokens, initializer, declarationEnd) || type == "Vector[String]" || type == "Array[String]";
}

static std::string csec_emit_i1_array_index(const char* tokens, int start, int end, const std::string& resultName) {
    if (csec_token_kind_at(tokens, start) != 'I' || !csec_native_token_is(tokens, start + 1, 'O', "[") ||
        !csec_visible_i1_array(tokens, start, csec_token_text_at(tokens, start))) return "";
    const int close = csec_find_closing_token(tokens, start + 1, end, "[", "]");
    if (close < 0 || close + 1 != end) return "";
    const std::string name = csec_token_text_at(tokens, start);
    const std::string storage = csec_lookup_visible_storage_name(tokens, start, name.c_str());
    const std::string index = resultName + ".index";
    const std::string data = resultName + ".data";
    const std::string element = resultName + ".element";
    return csec_emit_i32_expression(tokens, start + 2, close, index) +
        "  " + data + " = load ptr, ptr %" + storage + "\n" +
        "  " + element + " = getelementptr inbounds i1, ptr " + data + ", i32 " + index + "\n" +
        "  " + resultName + " = load i1, ptr " + element + "\n";
}

static std::string csec_emit_i32_array_index(const char* tokens, int start, int end, const std::string& resultName) {
    if (csec_token_kind_at(tokens, start) != 'I' || !csec_native_token_is(tokens, start + 1, 'O', "[") ||
        !csec_visible_i32_array(tokens, start, csec_token_text_at(tokens, start))) return "";
    const int close = csec_find_closing_token(tokens, start + 1, end, "[", "]");
    if (close < 0 || close + 1 != end) return "";
    const std::string name = csec_token_text_at(tokens, start);
    const std::string storage = csec_lookup_visible_storage_name(tokens, start, name.c_str());
    const std::string index = resultName + ".index";
    const std::string data = resultName + ".data";
    const std::string element = resultName + ".element";
    return csec_emit_i32_expression(tokens, start + 2, close, index) +
        "  " + data + " = load ptr, ptr %" + storage + "\n" +
        "  " + element + " = getelementptr inbounds i32, ptr " + data + ", i32 " + index + "\n" +
        "  " + resultName + " = load i32, ptr " + element + "\n";
}

static std::string csec_emit_i8_array_index(const char* tokens, int start, int end, const std::string& resultName) {
    if (csec_token_kind_at(tokens, start) != 'I' || !csec_native_token_is(tokens, start + 1, 'O', "[") ||
        !csec_visible_i8_array(tokens, start, csec_token_text_at(tokens, start))) return "";
    const int close = csec_find_closing_token(tokens, start + 1, end, "[", "]");
    if (close < 0 || close + 1 != end) return "";
    const std::string name = csec_token_text_at(tokens, start);
    const std::string storage = csec_lookup_visible_storage_name(tokens, start, name.c_str());
    const std::string index = resultName + ".index";
    const std::string data = resultName + ".data";
    const std::string element = resultName + ".element";
    return csec_emit_i32_expression(tokens, start + 2, close, index) +
        "  " + data + " = load ptr, ptr %" + storage + "\n" +
        "  " + element + " = getelementptr inbounds i8, ptr " + data + ", i32 " + index + "\n" +
        "  " + resultName + " = load i8, ptr " + element + "\n";
}

static std::string csec_emit_i16_array_index(const char* tokens, int start, int end, const std::string& resultName) {
    if (csec_token_kind_at(tokens, start) != 'I' || !csec_native_token_is(tokens, start + 1, 'O', "[") ||
        !csec_visible_i16_array(tokens, start, csec_token_text_at(tokens, start))) return "";
    const int close = csec_find_closing_token(tokens, start + 1, end, "[", "]");
    if (close < 0 || close + 1 != end) return "";
    const std::string name = csec_token_text_at(tokens, start);
    const std::string storage = csec_lookup_visible_storage_name(tokens, start, name.c_str());
    const std::string index = resultName + ".index";
    const std::string data = resultName + ".data";
    const std::string element = resultName + ".element";
    return csec_emit_i32_expression(tokens, start + 2, close, index) +
        "  " + data + " = load ptr, ptr %" + storage + "\n" +
        "  " + element + " = getelementptr inbounds i16, ptr " + data + ", i32 " + index + "\n" +
        "  " + resultName + " = load i16, ptr " + element + "\n";
}

static std::string csec_emit_f32_array_index(const char* tokens, int start, int end, const std::string& resultName) {
    if (csec_token_kind_at(tokens, start) != 'I' || !csec_native_token_is(tokens, start + 1, 'O', "[") ||
        !csec_visible_f32_array(tokens, start, csec_token_text_at(tokens, start))) return "";
    const int close = csec_find_closing_token(tokens, start + 1, end, "[", "]");
    if (close < 0 || close + 1 != end) return "";
    const std::string name = csec_token_text_at(tokens, start);
    const std::string storage = csec_lookup_visible_storage_name(tokens, start, name.c_str());
    const std::string index = resultName + ".index";
    const std::string data = resultName + ".data";
    const std::string element = resultName + ".element";
    return csec_emit_i32_expression(tokens, start + 2, close, index) +
        "  " + data + " = load ptr, ptr %" + storage + "\n" +
        "  " + element + " = getelementptr inbounds float, ptr " + data + ", i32 " + index + "\n" +
        "  " + resultName + " = load float, ptr " + element + "\n";
}

static std::string csec_emit_f64_array_index(const char* tokens, int start, int end, const std::string& resultName) {
    if (csec_token_kind_at(tokens, start) != 'I' || !csec_native_token_is(tokens, start + 1, 'O', "[") ||
        !csec_visible_f64_array(tokens, start, csec_token_text_at(tokens, start))) return "";
    const int close = csec_find_closing_token(tokens, start + 1, end, "[", "]");
    if (close < 0 || close + 1 != end) return "";
    const std::string name = csec_token_text_at(tokens, start);
    const std::string storage = csec_lookup_visible_storage_name(tokens, start, name.c_str());
    const std::string index = resultName + ".index";
    const std::string data = resultName + ".data";
    const std::string element = resultName + ".element";
    return csec_emit_i32_expression(tokens, start + 2, close, index) +
        "  " + data + " = load ptr, ptr %" + storage + "\n" +
        "  " + element + " = getelementptr inbounds double, ptr " + data + ", i32 " + index + "\n" +
        "  " + resultName + " = load double, ptr " + element + "\n";
}

static std::string csec_emit_ptr_array_index(const char* tokens, int start, int end, const std::string& resultName) {
    if (csec_token_kind_at(tokens, start) != 'I' || !csec_native_token_is(tokens, start + 1, 'O', "[") ||
        !csec_visible_ptr_array(tokens, start, csec_token_text_at(tokens, start))) return "";
    const int close = csec_find_closing_token(tokens, start + 1, end, "[", "]");
    if (close < 0 || close + 1 != end) return "";
    const std::string name = csec_token_text_at(tokens, start);
    const std::string storage = csec_lookup_visible_storage_name(tokens, start, name.c_str());
    const std::string index = resultName + ".index";
    const std::string data = resultName + ".data";
    const std::string element = resultName + ".element";
    return csec_emit_i32_expression(tokens, start + 2, close, index) +
        "  " + data + " = load ptr, ptr %" + storage + "\n" +
        "  " + element + " = getelementptr inbounds ptr, ptr " + data + ", i32 " + index + "\n" +
        "  " + resultName + " = load ptr, ptr " + element + "\n";
}

static std::string csec_emit_i32_array_local(const char* tokens, int declaration, int end) {
    const std::string name = csec_token_text_at(tokens, declaration + 1);
    const std::string storage = name + ".addr." + std::to_string(declaration);
    const int initializer = csec_find_top_level_operator(tokens, declaration, end, 1);
    const int valueStart = initializer + 1;
    const bool allocated = csec_native_token_is(tokens, valueStart, 'K', "new");
    const int open = allocated ? valueStart + 2 : valueStart;
    const int close = csec_find_closing_token(tokens, open, end, "[", "]");
    if (initializer < declaration || close < open) return "";

    std::string output = "  %" + storage + " = alloca ptr\n";
    const std::string countBase = "%" + name + ".count." + std::to_string(declaration);
    std::string count = countBase;
    if (allocated) output += "  " + count + " = add i32 0, 1\n";
    int itemStart = open + 1;
    int itemIndex = 0;
    for (int cursor = itemStart; cursor <= close; ++cursor) {
        if (cursor == close || csec_native_token_is(tokens, cursor, 'O', ",")) {
            if (cursor > itemStart) {
                const std::string value = "%" + name + ".size." + std::to_string(declaration) + "." + std::to_string(itemIndex++);
                if (allocated) {
                    output += csec_emit_i32_expression(tokens, itemStart, cursor, value);
                    const std::string nextCount = countBase + "." + std::to_string(itemIndex);
                    output += "  " + nextCount + " = mul i32 " + count + ", " + value + "\n";
                    count = nextCount;
                }
            }
            itemStart = cursor + 1;
        }
    }
    if (!allocated) {
        int countItems = 0;
        for (int cursor = open + 1; cursor < close; ++cursor) if (csec_native_token_is(tokens, cursor, 'O', ",")) ++countItems;
        if (close > open + 1) ++countItems;
        output += "  " + count + " = add i32 0, " + std::to_string(countItems) + "\n";
    }
    const std::string data = "%" + name + ".data." + std::to_string(declaration);
    output += "  " + data + " = alloca i32, i32 " + count + "\n";
    output += "  store ptr " + data + ", ptr %" + storage + "\n";
    if (!allocated) {
        itemStart = open + 1;
        itemIndex = 0;
        for (int cursor = itemStart; cursor <= close; ++cursor) {
            if (cursor == close || csec_native_token_is(tokens, cursor, 'O', ",")) {
                if (cursor > itemStart) {
                    const std::string value = "%" + name + ".item." + std::to_string(declaration) + "." + std::to_string(itemIndex);
                    const std::string element = "%" + name + ".element." + std::to_string(declaration) + "." + std::to_string(itemIndex++);
                    output += csec_emit_i32_expression(tokens, itemStart, cursor, value);
                    output += "  " + element + " = getelementptr inbounds i32, ptr " + data + ", i32 " + std::to_string(itemIndex - 1) + "\n";
                    output += "  store i32 " + value + ", ptr " + element + "\n";
                }
                itemStart = cursor + 1;
            }
        }
    }
    return output;
}

static std::string csec_emit_i1_array_local(const char* tokens, int declaration, int end) {
    const std::string name = csec_token_text_at(tokens, declaration + 1);
    const std::string storage = name + ".addr." + std::to_string(declaration);
    const int initializer = csec_find_top_level_operator(tokens, declaration, end, 1);
    const int valueStart = initializer + 1;
    const bool allocated = csec_native_token_is(tokens, valueStart, 'K', "new");
    const int open = allocated ? valueStart + 2 : valueStart;
    const int close = csec_find_closing_token(tokens, open, end, "[", "]");
    if (initializer < declaration || close < open) return "";

    std::string output = "  %" + storage + " = alloca ptr\n";
    const std::string countBase = "%" + name + ".count." + std::to_string(declaration);
    std::string count = countBase;
    if (allocated) output += "  " + count + " = add i32 0, 1\n";
    int itemStart = open + 1;
    int itemIndex = 0;
    for (int cursor = itemStart; cursor <= close; ++cursor) {
        if (cursor == close || csec_native_token_is(tokens, cursor, 'O', ",")) {
            if (cursor > itemStart && allocated) {
                const std::string value = "%" + name + ".size." + std::to_string(declaration) + "." + std::to_string(itemIndex++);
                output += csec_emit_i32_expression(tokens, itemStart, cursor, value);
                const std::string nextCount = countBase + "." + std::to_string(itemIndex);
                output += "  " + nextCount + " = mul i32 " + count + ", " + value + "\n";
                count = nextCount;
            }
            itemStart = cursor + 1;
        }
    }
    if (!allocated) {
        int countItems = 0;
        for (int cursor = open + 1; cursor < close; ++cursor) if (csec_native_token_is(tokens, cursor, 'O', ",")) ++countItems;
        if (close > open + 1) ++countItems;
        output += "  " + count + " = add i32 0, " + std::to_string(countItems) + "\n";
    }
    const std::string data = "%" + name + ".data." + std::to_string(declaration);
    output += "  " + data + " = alloca i1, i32 " + count + "\n";
    output += "  store ptr " + data + ", ptr %" + storage + "\n";
    if (!allocated) {
        itemStart = open + 1;
        itemIndex = 0;
        for (int cursor = itemStart; cursor <= close; ++cursor) {
            if (cursor == close || csec_native_token_is(tokens, cursor, 'O', ",")) {
                if (cursor > itemStart) {
                    const std::string value = "%" + name + ".item." + std::to_string(declaration) + "." + std::to_string(itemIndex);
                    const std::string element = "%" + name + ".element." + std::to_string(declaration) + "." + std::to_string(itemIndex++);
                    output += csec_emit_i1_expression(tokens, itemStart, cursor, value);
                    output += "  " + element + " = getelementptr inbounds i1, ptr " + data + ", i32 " + std::to_string(itemIndex - 1) + "\n";
                    output += "  store i1 " + value + ", ptr " + element + "\n";
                }
                itemStart = cursor + 1;
            }
        }
    }
    return output;
}

static std::string csec_emit_i8_array_local(const char* tokens, int declaration, int end) {
    const std::string name = csec_token_text_at(tokens, declaration + 1);
    const std::string storage = name + ".addr." + std::to_string(declaration);
    const int initializer = csec_find_top_level_operator(tokens, declaration, end, 1);
    const int valueStart = initializer + 1;
    const bool allocated = csec_native_token_is(tokens, valueStart, 'K', "new");
    const int open = allocated ? valueStart + 2 : valueStart;
    const int close = csec_find_closing_token(tokens, open, end, "[", "]");
    if (initializer < declaration || close < open) return "";

    std::string output = "  %" + storage + " = alloca ptr\n";
    const std::string countBase = "%" + name + ".count." + std::to_string(declaration);
    std::string count = countBase;
    if (allocated) output += "  " + count + " = add i32 0, 1\n";
    int itemStart = open + 1;
    int itemIndex = 0;
    for (int cursor = itemStart; cursor <= close; ++cursor) {
        if (cursor == close || csec_native_token_is(tokens, cursor, 'O', ",")) {
            if (cursor > itemStart && allocated) {
                const std::string value = "%" + name + ".size." + std::to_string(declaration) + "." + std::to_string(itemIndex++);
                output += csec_emit_i32_expression(tokens, itemStart, cursor, value);
                const std::string nextCount = countBase + "." + std::to_string(itemIndex);
                output += "  " + nextCount + " = mul i32 " + count + ", " + value + "\n";
                count = nextCount;
            }
            itemStart = cursor + 1;
        }
    }
    if (!allocated) {
        int countItems = 0;
        for (int cursor = open + 1; cursor < close; ++cursor) if (csec_native_token_is(tokens, cursor, 'O', ",")) ++countItems;
        if (close > open + 1) ++countItems;
        output += "  " + count + " = add i32 0, " + std::to_string(countItems) + "\n";
    }
    const std::string data = "%" + name + ".data." + std::to_string(declaration);
    output += "  " + data + " = alloca i8, i32 " + count + "\n";
    output += "  store ptr " + data + ", ptr %" + storage + "\n";
    if (!allocated) {
        itemStart = open + 1;
        itemIndex = 0;
        for (int cursor = itemStart; cursor <= close; ++cursor) {
            if (cursor == close || csec_native_token_is(tokens, cursor, 'O', ",")) {
                if (cursor > itemStart) {
                    const std::string value = "%" + name + ".item." + std::to_string(declaration) + "." + std::to_string(itemIndex);
                    const std::string element = "%" + name + ".element." + std::to_string(declaration) + "." + std::to_string(itemIndex++);
                    output += csec_emit_i8_expression(tokens, itemStart, cursor, value);
                    output += "  " + element + " = getelementptr inbounds i8, ptr " + data + ", i32 " + std::to_string(itemIndex - 1) + "\n";
                    output += "  store i8 " + value + ", ptr " + element + "\n";
                }
                itemStart = cursor + 1;
            }
        }
    }
    return output;
}

static std::string csec_emit_i16_array_local(const char* tokens, int declaration, int end) {
    const std::string name = csec_token_text_at(tokens, declaration + 1);
    const std::string storage = name + ".addr." + std::to_string(declaration);
    const int initializer = csec_find_top_level_operator(tokens, declaration, end, 1);
    const int valueStart = initializer + 1;
    const bool allocated = csec_native_token_is(tokens, valueStart, 'K', "new");
    const int open = allocated ? valueStart + 2 : valueStart;
    const int close = csec_find_closing_token(tokens, open, end, "[", "]");
    if (initializer < declaration || close < open) return "";

    std::string output = "  %" + storage + " = alloca ptr\n";
    const std::string countBase = "%" + name + ".count." + std::to_string(declaration);
    std::string count = countBase;
    if (allocated) output += "  " + count + " = add i32 0, 1\n";
    int itemStart = open + 1;
    int itemIndex = 0;
    for (int cursor = itemStart; cursor <= close; ++cursor) {
        if (cursor == close || csec_native_token_is(tokens, cursor, 'O', ",")) {
            if (cursor > itemStart && allocated) {
                const std::string value = "%" + name + ".size." + std::to_string(declaration) + "." + std::to_string(itemIndex++);
                output += csec_emit_i32_expression(tokens, itemStart, cursor, value);
                const std::string nextCount = countBase + "." + std::to_string(itemIndex);
                output += "  " + nextCount + " = mul i32 " + count + ", " + value + "\n";
                count = nextCount;
            }
            itemStart = cursor + 1;
        }
    }
    if (!allocated) {
        int countItems = 0;
        for (int cursor = open + 1; cursor < close; ++cursor) if (csec_native_token_is(tokens, cursor, 'O', ",")) ++countItems;
        if (close > open + 1) ++countItems;
        output += "  " + count + " = add i32 0, " + std::to_string(countItems) + "\n";
    }
    const std::string data = "%" + name + ".data." + std::to_string(declaration);
    output += "  " + data + " = alloca i16, i32 " + count + "\n";
    output += "  store ptr " + data + ", ptr %" + storage + "\n";
    if (!allocated) {
        itemStart = open + 1;
        itemIndex = 0;
        for (int cursor = itemStart; cursor <= close; ++cursor) {
            if (cursor == close || csec_native_token_is(tokens, cursor, 'O', ",")) {
                if (cursor > itemStart) {
                    const std::string value = "%" + name + ".item." + std::to_string(declaration) + "." + std::to_string(itemIndex);
                    const std::string element = "%" + name + ".element." + std::to_string(declaration) + "." + std::to_string(itemIndex++);
                    output += csec_emit_i16_expression(tokens, itemStart, cursor, value);
                    output += "  " + element + " = getelementptr inbounds i16, ptr " + data + ", i32 " + std::to_string(itemIndex - 1) + "\n";
                    output += "  store i16 " + value + ", ptr " + element + "\n";
                }
                itemStart = cursor + 1;
            }
        }
    }
    return output;
}

static std::string csec_emit_f32_array_local(const char* tokens, int declaration, int end) {
    const std::string name = csec_token_text_at(tokens, declaration + 1);
    const std::string storage = name + ".addr." + std::to_string(declaration);
    const int initializer = csec_find_top_level_operator(tokens, declaration, end, 1);
    const int valueStart = initializer + 1;
    const bool allocated = csec_native_token_is(tokens, valueStart, 'K', "new");
    const int open = allocated ? valueStart + 2 : valueStart;
    const int close = csec_find_closing_token(tokens, open, end, "[", "]");
    if (initializer < declaration || close < open) return "";

    std::string output = "  %" + storage + " = alloca ptr\n";
    const std::string countBase = "%" + name + ".count." + std::to_string(declaration);
    std::string count = countBase;
    if (allocated) output += "  " + count + " = add i32 0, 1\n";
    int itemStart = open + 1;
    int itemIndex = 0;
    for (int cursor = itemStart; cursor <= close; ++cursor) {
        if (cursor == close || csec_native_token_is(tokens, cursor, 'O', ",")) {
            if (cursor > itemStart && allocated) {
                const std::string value = "%" + name + ".size." + std::to_string(declaration) + "." + std::to_string(itemIndex++);
                output += csec_emit_i32_expression(tokens, itemStart, cursor, value);
                const std::string nextCount = countBase + "." + std::to_string(itemIndex);
                output += "  " + nextCount + " = mul i32 " + count + ", " + value + "\n";
                count = nextCount;
            }
            itemStart = cursor + 1;
        }
    }
    if (!allocated) {
        int countItems = 0;
        for (int cursor = open + 1; cursor < close; ++cursor) if (csec_native_token_is(tokens, cursor, 'O', ",")) ++countItems;
        if (close > open + 1) ++countItems;
        output += "  " + count + " = add i32 0, " + std::to_string(countItems) + "\n";
    }
    const std::string data = "%" + name + ".data." + std::to_string(declaration);
    output += "  " + data + " = alloca float, i32 " + count + "\n";
    output += "  store ptr " + data + ", ptr %" + storage + "\n";
    if (!allocated) {
        itemStart = open + 1;
        itemIndex = 0;
        for (int cursor = itemStart; cursor <= close; ++cursor) {
            if (cursor == close || csec_native_token_is(tokens, cursor, 'O', ",")) {
                if (cursor > itemStart) {
                    const std::string value = "%" + name + ".item." + std::to_string(declaration) + "." + std::to_string(itemIndex);
                    const std::string element = "%" + name + ".element." + std::to_string(declaration) + "." + std::to_string(itemIndex++);
                    output += csec_emit_f32_expression(tokens, itemStart, cursor, value);
                    output += "  " + element + " = getelementptr inbounds float, ptr " + data + ", i32 " + std::to_string(itemIndex - 1) + "\n";
                    output += "  store float " + value + ", ptr " + element + "\n";
                }
                itemStart = cursor + 1;
            }
        }
    }
    return output;
}

static std::string csec_emit_f64_array_local(const char* tokens, int declaration, int end) {
    const std::string name = csec_token_text_at(tokens, declaration + 1);
    const std::string storage = name + ".addr." + std::to_string(declaration);
    const int initializer = csec_find_top_level_operator(tokens, declaration, end, 1);
    const int valueStart = initializer + 1;
    const bool allocated = csec_native_token_is(tokens, valueStart, 'K', "new");
    const int open = allocated ? valueStart + 2 : valueStart;
    const int close = csec_find_closing_token(tokens, open, end, "[", "]");
    if (initializer < declaration || close < open) return "";

    std::string output = "  %" + storage + " = alloca ptr\n";
    const std::string countBase = "%" + name + ".count." + std::to_string(declaration);
    std::string count = countBase;
    if (allocated) output += "  " + count + " = add i32 0, 1\n";
    int itemStart = open + 1;
    int itemIndex = 0;
    for (int cursor = itemStart; cursor <= close; ++cursor) {
        if (cursor == close || csec_native_token_is(tokens, cursor, 'O', ",")) {
            if (cursor > itemStart && allocated) {
                const std::string value = "%" + name + ".size." + std::to_string(declaration) + "." + std::to_string(itemIndex++);
                output += csec_emit_i32_expression(tokens, itemStart, cursor, value);
                const std::string nextCount = countBase + "." + std::to_string(itemIndex);
                output += "  " + nextCount + " = mul i32 " + count + ", " + value + "\n";
                count = nextCount;
            }
            itemStart = cursor + 1;
        }
    }
    if (!allocated) {
        int countItems = 0;
        for (int cursor = open + 1; cursor < close; ++cursor) if (csec_native_token_is(tokens, cursor, 'O', ",")) ++countItems;
        if (close > open + 1) ++countItems;
        output += "  " + count + " = add i32 0, " + std::to_string(countItems) + "\n";
    }
    const std::string data = "%" + name + ".data." + std::to_string(declaration);
    output += "  " + data + " = alloca double, i32 " + count + "\n";
    output += "  store ptr " + data + ", ptr %" + storage + "\n";
    if (!allocated) {
        itemStart = open + 1;
        itemIndex = 0;
        for (int cursor = itemStart; cursor <= close; ++cursor) {
            if (cursor == close || csec_native_token_is(tokens, cursor, 'O', ",")) {
                if (cursor > itemStart) {
                    const std::string value = "%" + name + ".item." + std::to_string(declaration) + "." + std::to_string(itemIndex);
                    const std::string element = "%" + name + ".element." + std::to_string(declaration) + "." + std::to_string(itemIndex++);
                    output += csec_emit_f64_expression(tokens, itemStart, cursor, value);
                    output += "  " + element + " = getelementptr inbounds double, ptr " + data + ", i32 " + std::to_string(itemIndex - 1) + "\n";
                    output += "  store double " + value + ", ptr " + element + "\n";
                }
                itemStart = cursor + 1;
            }
        }
    }
    return output;
}

static std::string csec_emit_ptr_array_local(const char* tokens, int declaration, int end) {
    const std::string name = csec_token_text_at(tokens, declaration + 1);
    const std::string storage = name + ".addr." + std::to_string(declaration);
    const int initializer = csec_find_top_level_operator(tokens, declaration, end, 1);
    const int valueStart = initializer + 1;
    const bool allocated = csec_native_token_is(tokens, valueStart, 'K', "new");
    const int open = allocated ? valueStart + 2 : valueStart;
    const int close = csec_find_closing_token(tokens, open, end, "[", "]");
    if (initializer < declaration || close < open) return "";
    std::string output = "  %" + storage + " = alloca ptr\n";
    const std::string countBase = "%" + name + ".count." + std::to_string(declaration);
    std::string count = countBase;
    if (allocated) output += "  " + count + " = add i32 0, 1\n";
    int itemStart = open + 1;
    int itemIndex = 0;
    for (int cursor = itemStart; cursor <= close; ++cursor) {
        if (cursor == close || csec_native_token_is(tokens, cursor, 'O', ",")) {
            if (cursor > itemStart && allocated) {
                const std::string value = "%" + name + ".size." + std::to_string(declaration) + "." + std::to_string(itemIndex++);
                output += csec_emit_i32_expression(tokens, itemStart, cursor, value);
                const std::string nextCount = countBase + "." + std::to_string(itemIndex);
                output += "  " + nextCount + " = mul i32 " + count + ", " + value + "\n";
                count = nextCount;
            }
            itemStart = cursor + 1;
        }
    }
    if (!allocated) {
        int countItems = 0;
        for (int cursor = open + 1; cursor < close; ++cursor) if (csec_native_token_is(tokens, cursor, 'O', ",")) ++countItems;
        if (close > open + 1) ++countItems;
        output += "  " + count + " = add i32 0, " + std::to_string(countItems) + "\n";
    }
    const std::string data = "%" + name + ".data." + std::to_string(declaration);
    output += "  " + data + " = alloca ptr, i32 " + count + "\n";
    output += "  store ptr " + data + ", ptr %" + storage + "\n";
    if (!allocated) {
        itemStart = open + 1;
        itemIndex = 0;
        for (int cursor = itemStart; cursor <= close; ++cursor) {
            if (cursor == close || csec_native_token_is(tokens, cursor, 'O', ",")) {
                if (cursor > itemStart) {
                    const std::string value = "%" + name + ".item." + std::to_string(declaration) + "." + std::to_string(itemIndex);
                    const std::string element = "%" + name + ".element." + std::to_string(declaration) + "." + std::to_string(itemIndex++);
                    output += csec_emit_ptr_expression(tokens, itemStart, cursor, value);
                    output += "  " + element + " = getelementptr inbounds ptr, ptr " + data + ", i32 " + std::to_string(itemIndex - 1) + "\n";
                    output += "  store ptr " + value + ", ptr " + element + "\n";
                }
                itemStart = cursor + 1;
            }
        }
    }
    return output;
}
