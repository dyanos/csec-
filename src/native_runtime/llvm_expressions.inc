static std::string csec_emit_ptr_expression(const char* tokens, int start, int end, const std::string& resultName) {
    end = csec_i32_expression_end(tokens, start, end);
    const std::string indexedArray = csec_emit_ptr_array_index(tokens, start, end, resultName);
    if (!indexedArray.empty()) return indexedArray;
    const int operation = csec_i32_top_level_operator(tokens, start, end);
    if (operation >= start && csec_native_token_is(tokens, operation, 'O', "+") &&
        csec_is_string_expression(tokens, start, operation) && csec_is_string_expression(tokens, operation + 1, end)) {
        const std::string left = resultName + ".left";
        const std::string right = resultName + ".right";
        return csec_emit_ptr_expression(tokens, start, operation, left) +
            csec_emit_ptr_expression(tokens, operation + 1, end, right) +
            "  " + resultName + " = call ptr @csec_string_concat(ptr " + left + ", ptr " + right + ")\n";
    }
    if (end == start + 1 && csec_token_kind_at(tokens, start) == 'S') {
        return "  " + resultName + " = getelementptr inbounds [" +
            std::to_string(csec_llvm_string_literal_byte_length(csec_token_text_at(tokens, start))) +
            " x i8], ptr @.str." + std::to_string(start) + ", i32 0, i32 0\n";
    }
    if (end == start + 1 && csec_token_kind_at(tokens, start) == 'I' &&
        (csec_is_string_local(tokens, start, csec_token_text_at(tokens, start)) ||
         csec_is_string_parameter(tokens, start, csec_token_text_at(tokens, start)) ||
         csec_is_string_class_constructor_param(tokens, start, csec_token_text_at(tokens, start)) ||
         csec_is_pointer_local(tokens, start, csec_token_text_at(tokens, start)) ||
         csec_is_pointer_parameter(tokens, start, csec_token_text_at(tokens, start)))) {
        const char* storage = csec_lookup_visible_storage_name(tokens, start, csec_token_text_at(tokens, start));
        return "  " + resultName + " = load ptr, ptr %" + std::string(storage) + "\n";
    }
    if (end == start + 1 && csec_token_kind_at(tokens, start) == 'I' &&
        (csec_visible_i32_array(tokens, start, csec_token_text_at(tokens, start)) ||
         csec_visible_i1_array(tokens, start, csec_token_text_at(tokens, start)) ||
         csec_visible_i8_array(tokens, start, csec_token_text_at(tokens, start)) ||
         csec_visible_i16_array(tokens, start, csec_token_text_at(tokens, start)) ||
         csec_visible_i64_array(tokens, start, csec_token_text_at(tokens, start)) ||
         csec_visible_f32_array(tokens, start, csec_token_text_at(tokens, start)) ||
         csec_visible_f64_array(tokens, start, csec_token_text_at(tokens, start)) ||
         csec_visible_ptr_array(tokens, start, csec_token_text_at(tokens, start)))) {
        const char* storage = csec_lookup_visible_storage_name(tokens, start, csec_token_text_at(tokens, start));
        return "  " + resultName + " = load ptr, ptr %" + std::string(storage) + "\n";
    }
    if ((csec_token_kind_at(tokens, start) == 'I' || csec_token_kind_at(tokens, start) == 'S') && start + 4 < end &&
        csec_native_token_is(tokens, start + 1, 'O', ".") && csec_token_kind_at(tokens, start + 2) == 'I' &&
        csec_native_token_is(tokens, start + 3, 'O', "(") && csec_is_string_expression(tokens, start, start + 1)) {
        const int close = csec_find_closing_token(tokens, start + 3, end, "(", ")");
        if (close == end - 1) {
            const std::string method = csec_token_text_at(tokens, start + 2);
            const std::string object = resultName + ".string";
            if ((method == "trim" || method == "toUpper" || method == "toLower" || method == "toString") && close == start + 4) {
                const char* runtime = method == "trim" ? "csec_string_trim" :
                    (method == "toUpper" ? "csec_string_to_upper" : "csec_string_to_lower");
                const std::string source = csec_emit_ptr_expression(tokens, start, start + 1, object);
                if (method == "toString") return source + "  " + resultName + " = getelementptr i8, ptr " + object + ", i32 0\n";
                return source + "  " + resultName + " = call ptr @" + runtime + "(ptr " + object + ")\n";
            }
            if (method == "substring" && close > start + 6) {
                const int comma = csec_find_token_text_in_range(tokens, start + 4, close, ",");
                if (comma > start + 4 && comma + 1 < close &&
                    csec_find_token_text_in_range(tokens, comma + 1, close, ",") < 0) {
                    const std::string offset = resultName + ".offset";
                    const std::string length = resultName + ".length";
                    return csec_emit_ptr_expression(tokens, start, start + 1, object) +
                        csec_emit_i32_expression(tokens, start + 4, comma, offset) +
                        csec_emit_i32_expression(tokens, comma + 1, close, length) +
                        "  " + resultName + " = call ptr @csec_string_substring(ptr " + object + ", i32 " + offset + ", i32 " + length + ")\n";
                }
            }
        }
    }
    std::string instanceCall;
    if (csec_emit_ptr_instance_call(tokens, start, end, resultName, instanceCall)) return instanceCall;
    if (csec_token_kind_at(tokens, start) == 'I' && start + 1 < end && csec_native_token_is(tokens, start + 1, 'O', "(")) {
        const int callee = csec_top_level_function_declaration(tokens, csec_token_text_at(tokens, start));
        const int close = csec_find_closing_token(tokens, start + 1, end, "(", ")");
        if (callee >= 0 && close == end - 1 &&
            std::strcmp(csec_llvm_type_for_name(csec_function_return_type_at(tokens, callee)), "ptr") == 0) {
            const auto parameters = csec_function_params(tokens, callee);
            std::string output, arguments;
            int argumentStart = start + 2, index = 0;
            for (int cursor = argumentStart; cursor <= close; ++cursor) {
                if (cursor == close || csec_is_argument_separator(tokens, close, cursor)) {
                    if (cursor > argumentStart) {
                        const std::string argument = resultName + ".arg" + std::to_string(index++);
                        const bool pointerArgument = index - 1 < static_cast<int>(parameters.size()) &&
                            std::strcmp(csec_llvm_type_for_name(parameters[index - 1].second), "ptr") == 0;
                        output += pointerArgument ? csec_emit_ptr_expression(tokens, argumentStart, cursor, argument)
                                                  : csec_emit_i32_expression(tokens, argumentStart, cursor, argument);
                        if (!arguments.empty()) arguments += ", ";
                        arguments += std::string(pointerArgument ? "ptr " : "i32 ") + argument;
                    }
                    argumentStart = cursor + 1;
                }
            }
            return output + "  " + resultName + " = call ptr @" + std::string(csec_token_text_at(tokens, start)) + "(" + arguments + ")\n";
        }
    }
    return "  " + resultName + " = getelementptr i8, ptr null, i32 0\n";
}

static std::string csec_emit_i32_expression(const char* tokens, int start, int end, const std::string& resultName) {
    end = csec_i32_expression_end(tokens, start, end);
    if (end <= start) return "  " + resultName + " = add i32 0, 0\n";
    if (csec_native_token_is(tokens, start, 'O', "{") &&
        csec_find_closing_token(tokens, start, end, "{", "}") == end - 1) {
        return csec_emit_i32_block_expression(tokens, start, end, resultName);
    }
    if (csec_native_token_is(tokens, start, 'O', "[")) {
        const int captureClose = csec_find_closing_token(tokens, start, end, "[", "]");
        const int parameterOpen = captureClose >= 0 ? captureClose + 1 : -1;
        const int parameterClose = parameterOpen >= 0 && csec_native_token_is(tokens, parameterOpen, 'O', "(")
            ? csec_find_closing_token(tokens, parameterOpen, end, "(", ")") : -1;
        if (parameterClose >= 0 && csec_native_token_is(tokens, parameterClose + 1, 'O', "->")) {
            return "  " + resultName + " = add i32 0, 0\n";
        }
    }
    for (int cursor = start + 1; cursor < end; ++cursor) {
        if (csec_native_token_is(tokens, cursor, 'K', "match")) {
            return csec_emit_i32_match_expression(tokens, start, end, cursor, resultName);
        }
    }
    if (csec_native_token_is(tokens, start, 'O', "(") &&
        csec_find_closing_token(tokens, start, end, "(", ")") == end - 1) {
        return csec_emit_i32_expression(tokens, start + 1, end - 1, resultName);
    }
    if (csec_native_token_is(tokens, start, 'O', "+") && start + 1 < end) {
        return csec_emit_i32_expression(tokens, start + 1, end, resultName);
    }
    if (csec_native_token_is(tokens, start, 'O', "-") && start + 1 < end) {
        const std::string valueName = resultName + ".value";
        return csec_emit_i32_expression(tokens, start + 1, end, valueName) +
            "  " + resultName + " = sub i32 0, " + valueName + "\n";
    }
    if (csec_native_token_is(tokens, start, 'O', "!") && start + 1 < end) {
        const std::string valueName = resultName + ".value";
        const std::string comparisonName = resultName + ".comparison";
        return csec_emit_i32_expression(tokens, start + 1, end, valueName) +
            "  " + comparisonName + " = icmp eq i32 " + valueName + ", 0\n" +
            "  " + resultName + " = zext i1 " + comparisonName + " to i32\n";
    }
    if (csec_native_token_is(tokens, start, 'O', "~") && start + 1 < end) {
        const std::string valueName = resultName + ".value";
        return csec_emit_i32_expression(tokens, start + 1, end, valueName) +
            "  " + resultName + " = xor i32 " + valueName + ", -1\n";
    }
    // Array postfixes are expression atoms. Split a following binary operation
    // here so the array index is lowered before the normal precedence walker.
    if (csec_token_kind_at(tokens, start) == 'I' && csec_native_token_is(tokens, start + 1, 'O', "[")) {
        const int close = csec_find_closing_token(tokens, start + 1, end, "[", "]");
        if (close >= start + 2 && close + 2 < end) {
            const char* postfixOp = csec_token_text_at(tokens, close + 1);
            const char* instruction = std::strcmp(postfixOp, "+") == 0 ? "add" :
                (std::strcmp(postfixOp, "-") == 0 ? "sub" : (std::strcmp(postfixOp, "*") == 0 ? "mul" :
                (std::strcmp(postfixOp, "/") == 0 ? "sdiv" : (std::strcmp(postfixOp, "%") == 0 ? "srem" : nullptr))));
            if (instruction) {
                const std::string leftName = resultName + ".left";
                const std::string rightName = resultName + ".right";
                return csec_emit_i32_expression(tokens, start, close + 1, leftName) +
                    csec_emit_i32_expression(tokens, close + 2, end, rightName) +
                    "  " + resultName + " = " + instruction + " i32 " + leftName + ", " + rightName + "\n";
            }
        }
    }
    const int operation = csec_i32_top_level_operator(tokens, start, end);
    if (operation >= start) {
        const std::string leftName = resultName + ".left";
        const std::string rightName = resultName + ".right";
        const char* op = csec_token_text_at(tokens, operation);
        if ((std::strcmp(op, "==") == 0 || std::strcmp(op, "!=") == 0) &&
            csec_is_string_expression(tokens, start, operation) &&
            csec_is_string_expression(tokens, operation + 1, end)) {
            const std::string equal = resultName + ".equals";
            const std::string comparison = resultName + ".comparison";
            return csec_emit_ptr_expression(tokens, start, operation, leftName) +
                csec_emit_ptr_expression(tokens, operation + 1, end, rightName) +
                "  " + equal + " = call i32 @csec_string_equals(ptr " + leftName + ", ptr " + rightName + ")\n" +
                "  " + comparison + " = icmp " + (std::strcmp(op, "==") == 0 ? "ne" : "eq") + " i32 " + equal + ", 0\n" +
                "  " + resultName + " = zext i1 " + comparison + " to i32\n";
        }
        std::string output = csec_emit_i32_expression(tokens, start, operation, leftName);
        output += csec_emit_i32_expression(tokens, operation + 1, end, rightName);
        const char* instruction = "ashr";
        if (std::strcmp(op, "+") == 0) instruction = "add";
        else if (std::strcmp(op, "-") == 0) instruction = "sub";
        else if (std::strcmp(op, "*") == 0) instruction = "mul";
        else if (std::strcmp(op, "/") == 0) instruction = "sdiv";
        else if (std::strcmp(op, "%") == 0) instruction = "srem";
        else if (std::strcmp(op, "&") == 0) instruction = "and";
        else if (std::strcmp(op, "|") == 0) instruction = "or";
        else if (std::strcmp(op, "^") == 0) instruction = "xor";
        else if (std::strcmp(op, "<<") == 0) instruction = "shl";
        else if (std::strcmp(op, "and") == 0 || std::strcmp(op, "&&") == 0) instruction = "and";
        else if (std::strcmp(op, "or") == 0 || std::strcmp(op, "||") == 0) instruction = "or";
        else if (std::strcmp(op, "xor") == 0) instruction = "xor";
        if (std::strcmp(op, "==") == 0 || std::strcmp(op, "!=") == 0 ||
            std::strcmp(op, "<") == 0 || std::strcmp(op, "<=") == 0 ||
            std::strcmp(op, ">") == 0 || std::strcmp(op, ">=") == 0) {
            const char* predicate = std::strcmp(op, "==") == 0 ? "eq" :
                (std::strcmp(op, "!=") == 0 ? "ne" : (std::strcmp(op, "<") == 0 ? "slt" :
                (std::strcmp(op, "<=") == 0 ? "sle" : (std::strcmp(op, ">") == 0 ? "sgt" : "sge"))));
            const std::string comparisonName = resultName + ".comparison";
            return output + "  " + comparisonName + " = icmp " + predicate + " i32 " + leftName + ", " + rightName + "\n" +
                "  " + resultName + " = zext i1 " + comparisonName + " to i32\n";
        }
        return output + "  " + resultName + " = " + instruction + " i32 " + leftName + ", " + rightName + "\n";
    }
    const char kind = csec_token_kind_at(tokens, start);
    if (kind == 'N') return "  " + resultName + " = add i32 0, " + csec_i32_literal(csec_token_text_at(tokens, start)) + "\n";
    if (std::strcmp(csec_token_text_at(tokens, start), "true") == 0) return "  " + resultName + " = add i32 0, 1\n";
    if (std::strcmp(csec_token_text_at(tokens, start), "false") == 0) return "  " + resultName + " = add i32 0, 0\n";
    if (csec_token_kind_at(tokens, start) == 'I' && start + 2 < end && csec_native_token_is(tokens, start + 1, 'O', ".") &&
        csec_token_kind_at(tokens, start + 2) == 'I' &&
        csec_is_string_expression(tokens, start, start + 1) &&
        (std::strcmp(csec_token_text_at(tokens, start + 2), "length") == 0 ||
         std::strcmp(csec_token_text_at(tokens, start + 2), "size") == 0)) {
        const bool property = start + 3 == end;
        const bool call = start + 5 == end && csec_native_token_is(tokens, start + 3, 'O', "(") &&
            csec_native_token_is(tokens, start + 4, 'O', ")");
        if (property || call) {
            const std::string value = resultName + ".string";
            const std::string length = resultName + ".length64";
            return csec_emit_ptr_expression(tokens, start, start + 1, value) +
                "  " + length + " = call i64 @csec_string_length(ptr " + value + ")\n" +
                "  " + resultName + " = trunc i64 " + length + " to i32\n";
        }
    }
    if (csec_token_kind_at(tokens, start) == 'I' && start + 3 < end &&
        csec_native_token_is(tokens, start + 1, 'O', ".") && csec_token_kind_at(tokens, start + 2) == 'I' &&
        csec_native_token_is(tokens, start + 3, 'O', "(") && csec_is_string_expression(tokens, start, start + 1)) {
        const int close = csec_find_closing_token(tokens, start + 3, end, "(", ")");
        if (close == end - 1) {
            const std::string method = csec_token_text_at(tokens, start + 2);
            const std::string object = resultName + ".string";
            if (method == "isEmpty" && close == start + 4) {
                return csec_emit_ptr_expression(tokens, start, start + 1, object) +
                    "  " + resultName + " = call i32 @csec_string_is_empty(ptr " + object + ")\n";
            }
            if ((method == "contains" || method == "startsWith" || method == "endsWith" || method == "indexOf") &&
                close > start + 4 && csec_find_token_text_in_range(tokens, start + 4, close, ",") < 0) {
                const std::string argument = resultName + ".needle";
                std::string output = csec_emit_ptr_expression(tokens, start, start + 1, object) +
                    csec_emit_ptr_expression(tokens, start + 4, close, argument);
                if (method == "contains") return output +
                    "  " + resultName + " = call i32 @csec_string_contains(ptr " + object + ", ptr " + argument + ")\n";
                if (method == "startsWith") return output +
                    "  " + resultName + " = call i32 @csec_string_starts_with(ptr " + object + ", ptr " + argument + ")\n";
                if (method == "endsWith") return output +
                    "  " + resultName + " = call i32 @csec_string_ends_with(ptr " + object + ", ptr " + argument + ")\n";
                const std::string index = resultName + ".index64";
                return output + "  " + index + " = call i64 @csec_string_index_of(ptr " + object + ", ptr " + argument + ")\n" +
                    "  " + resultName + " = trunc i64 " + index + " to i32\n";
            }
            if (method == "charAt" && close > start + 4 &&
                csec_find_token_text_in_range(tokens, start + 4, close, ",") < 0) {
                const std::string index = resultName + ".index";
                const std::string character = resultName + ".char";
                return csec_emit_ptr_expression(tokens, start, start + 1, object) +
                    csec_emit_i32_expression(tokens, start + 4, close, index) +
                    "  " + character + " = call i8 @csec_string_char_at(ptr " + object + ", i32 " + index + ")\n" +
                    "  " + resultName + " = zext i8 " + character + " to i32\n";
            }
        }
    }
    const std::string indexedLiteral = csec_emit_i32_literal_array_index(tokens, start, end, resultName);
    if (!indexedLiteral.empty()) return indexedLiteral;
    const std::string indexedArray = csec_emit_i32_array_index(tokens, start, end, resultName);
    if (!indexedArray.empty()) return indexedArray;
    const std::string indexedCharArray = csec_emit_i8_array_index(tokens, start, end, resultName + ".char");
    if (!indexedCharArray.empty()) {
        return indexedCharArray + "  " + resultName + " = zext i8 " + resultName + ".char to i32\n";
    }
    const std::string indexedShortArray = csec_emit_i16_array_index(tokens, start, end, resultName + ".short");
    if (!indexedShortArray.empty()) {
        return indexedShortArray + "  " + resultName + " = sext i16 " + resultName + ".short to i32\n";
    }
    const std::string indexedLongArray = csec_emit_i64_array_index(tokens, start, end, resultName + ".long");
    if (!indexedLongArray.empty()) {
        return indexedLongArray + "  " + resultName + " = trunc i64 " + resultName + ".long to i32\n";
    }
    if (csec_token_kind_at(tokens, start) == 'C' && start + 1 == end) {
        const std::string character = resultName + ".char";
        return csec_emit_i8_expression(tokens, start, end, character) +
            "  " + resultName + " = zext i8 " + character + " to i32\n";
    }
    if (csec_token_kind_at(tokens, start) == 'I' && start + 1 == end) {
        const std::string name = csec_token_text_at(tokens, start);
        const int declaration = csec_find_visible_local(tokens, start, name.c_str());
        const int declarationEnd = declaration >= 0 ? csec_advance_statement(tokens, declaration, 1000000000) : -1;
        const int initializer = declaration >= 0 ? csec_find_top_level_operator(tokens, declaration, declarationEnd, 1) : -1;
        if (declaration >= 0 && csec_c_local_type(tokens, declaration, declarationEnd, initializer) == "Char") {
            const std::string character = resultName + ".char";
            return csec_emit_i8_expression(tokens, start, end, character) +
                "  " + resultName + " = zext i8 " + character + " to i32\n";
        }
    }
    if (csec_token_kind_at(tokens, start) == 'I' && start + 1 < end && csec_native_token_is(tokens, start + 1, 'O', "(")) {
        const int callee = csec_top_level_function_declaration(tokens, csec_token_text_at(tokens, start));
        if (callee >= 0 && std::strcmp(csec_function_return_type_at(tokens, callee), "Char") == 0) {
            const std::string character = resultName + ".char";
            return csec_emit_i8_expression(tokens, start, end, character) +
                "  " + resultName + " = zext i8 " + character + " to i32\n";
        }
    }
    std::string instanceCall;
    if (csec_emit_i32_instance_call(tokens, start, end, resultName, instanceCall)) return instanceCall;
    if (csec_native_token_is(tokens, start, 'K', "this") && start + 3 == end &&
        csec_native_token_is(tokens, start + 1, 'O', ".") && csec_token_kind_at(tokens, start + 2) == 'I') {
        const std::string field = csec_token_text_at(tokens, start + 2);
        return "  " + resultName + " = load i32, ptr %" + field + "\n";
    }
    if (csec_native_token_is(tokens, start, 'K', "super") && start + 4 < end &&
        csec_native_token_is(tokens, start + 1, 'O', ".") && csec_token_kind_at(tokens, start + 2) == 'I' &&
        csec_native_token_is(tokens, start + 3, 'O', "(")) {
        const int close = csec_find_closing_token(tokens, start + 3, end, "(", ")");
        const int classStart = csec_enclosing_class_declaration(tokens, start);
        const std::string parent = classStart >= 0 ? csec_class_parent_name(tokens, classStart) : "";
        if (close == end - 1 && !parent.empty()) {
            const int parentStart = csec_find_class_declaration(tokens, parent.c_str());
            if (csec_class_uses_pointer_receiver(tokens, classStart) && parentStart >= 0 &&
                csec_class_uses_pointer_receiver(tokens, parentStart)) {
                return "  " + resultName + " = call i32 @" + parent + "_" +
                    csec_token_text_at(tokens, start + 2) + "(ptr %arg.this)\n";
            }
            std::string output;
            std::string arguments;
            int argumentIndex = 0;
            for (const auto& parameter : csec_class_constructor_params(tokens, classStart)) {
                if (std::strcmp(csec_llvm_type_for_name(parameter.second.c_str()), "i32") != 0) continue;
                const std::string value = resultName + ".super.arg" + std::to_string(argumentIndex++);
                output += "  " + value + " = load i32, ptr %" + parameter.first + "\n";
                if (!arguments.empty()) arguments += ", ";
                arguments += "i32 " + value;
            }
            return output + "  " + resultName + " = call i32 @" + parent + "_" +
                csec_token_text_at(tokens, start + 2) + "(" + arguments + ")\n";
        }
    }
    if (kind == 'I' && start + 3 < end && csec_native_token_is(tokens, start + 1, 'O', ".") &&
        csec_token_kind_at(tokens, start + 2) == 'I' && csec_native_token_is(tokens, start + 3, 'O', "(")) {
        const int close = csec_find_closing_token(tokens, start + 3, end, "(", ")");
        if (close == end - 1) {
            std::string output;
            std::string arguments;
            int argumentStart = start + 4;
            int argumentIndex = 0;
            for (int cursor = argumentStart; cursor <= close; ++cursor) {
                if (cursor == close || csec_is_argument_separator(tokens, close, cursor)) {
                    if (cursor > argumentStart) {
                        const std::string argumentName = resultName + ".arg" + std::to_string(argumentIndex++);
                        output += csec_emit_i32_expression(tokens, argumentStart, cursor, argumentName);
                        if (!arguments.empty()) arguments += ", ";
                        arguments += "i32 " + argumentName;
                    }
                    argumentStart = cursor + 1;
                }
            }
            return output + "  " + resultName + " = call i32 @" + std::string(csec_token_text_at(tokens, start)) +
                "_" + csec_token_text_at(tokens, start + 2) + "(" + arguments + ")\n";
        }
    }
    if (kind == 'I' && start + 1 < end && csec_native_token_is(tokens, start + 1, 'O', "(") &&
        csec_is_function_parameter(tokens, start, csec_token_text_at(tokens, start))) {
        const int close = csec_find_closing_token(tokens, start + 1, end, "(", ")");
        if (close == end - 1) {
            std::string output;
            std::string arguments;
            int argumentStart = start + 2;
            int argumentIndex = 0;
            for (int cursor = argumentStart; cursor <= close; ++cursor) {
                if (cursor == close || csec_is_argument_separator(tokens, close, cursor)) {
                    if (cursor > argumentStart) {
                        const std::string argumentName = resultName + ".arg" + std::to_string(argumentIndex++);
                        output += csec_emit_i32_expression(tokens, argumentStart, cursor, argumentName);
                        if (!arguments.empty()) arguments += ", ";
                        arguments += "i32 " + argumentName;
                    }
                    argumentStart = cursor + 1;
                }
            }
            const char* storage = csec_lookup_visible_storage_name(tokens, start, csec_token_text_at(tokens, start));
            const std::string closure = resultName + ".closure";
            const std::string codeField = resultName + ".code.field";
            const std::string environmentField = resultName + ".environment.field";
            const std::string functionValue = resultName + ".fn";
            const std::string environment = resultName + ".environment";
            return output + "  " + closure + " = load ptr, ptr %" + std::string(storage) + "\n" +
                "  " + codeField + " = getelementptr inbounds { ptr, ptr }, ptr " + closure + ", i32 0, i32 0\n" +
                "  " + functionValue + " = load ptr, ptr " + codeField + "\n" +
                "  " + environmentField + " = getelementptr inbounds { ptr, ptr }, ptr " + closure + ", i32 0, i32 1\n" +
                "  " + environment + " = load ptr, ptr " + environmentField + "\n" +
                "  " + resultName + " = call i32 " + functionValue + "(ptr " + environment + (arguments.empty() ? "" : ", " + arguments) + ")\n";
        }
    }
    if (kind == 'I' && start + 1 < end && csec_native_token_is(tokens, start + 1, 'O', "(")) {
        const int declaration = csec_find_visible_local(tokens, start, csec_token_text_at(tokens, start));
        const int declarationEnd = declaration >= 0 ? csec_advance_statement(tokens, declaration, 1000000000) : -1;
        if (declaration >= 0 && csec_lambda_declaration(tokens, declaration, declarationEnd)) {
            const int close = csec_find_closing_token(tokens, start + 1, end, "(", ")");
            if (close == end - 1) {
                std::string output;
                std::string arguments;
                const char* storage = csec_lookup_visible_storage_name(tokens, start, csec_token_text_at(tokens, start));
                const std::string closure = resultName + ".closure";
                const std::string codeField = resultName + ".code.field";
                const std::string environmentField = resultName + ".environment.field";
                const std::string code = resultName + ".code";
                const std::string environment = resultName + ".environment";
                const std::string closureType = csec_lambda_closure_type_name(declaration);
                output += "  " + closure + " = load ptr, ptr %" + std::string(storage) + "\n";
                output += "  " + codeField + " = getelementptr inbounds " + closureType + ", ptr " + closure + ", i32 0, i32 0\n";
                output += "  " + code + " = load ptr, ptr " + codeField + "\n";
                output += "  " + environmentField + " = getelementptr inbounds " + closureType + ", ptr " + closure + ", i32 0, i32 1\n";
                output += "  " + environment + " = load ptr, ptr " + environmentField + "\n";
                arguments = "ptr " + environment;
                int argumentStart = start + 2;
                int argumentIndex = 0;
                for (int cursor = argumentStart; cursor <= close; ++cursor) {
                    if (cursor == close || csec_is_argument_separator(tokens, close, cursor)) {
                        if (cursor > argumentStart) {
                            const std::string argumentName = resultName + ".arg" + std::to_string(argumentIndex++);
                            output += csec_emit_i32_expression(tokens, argumentStart, cursor, argumentName);
                            if (!arguments.empty()) arguments += ", ";
                            arguments += "i32 " + argumentName;
                        }
                        argumentStart = cursor + 1;
                    }
                }
                return output + "  " + resultName + " = call i32 " + code + "(" + arguments + ")\n";
            }
        }
    }
    if (kind == 'I' && start + 1 < end && csec_native_token_is(tokens, start + 1, 'O', "(")) {
        const int callee = csec_top_level_function_declaration(tokens, csec_token_text_at(tokens, start));
        const auto parameters = callee >= 0 ? csec_function_params(tokens, callee) : std::vector<std::pair<std::string, std::string>>{};
        const int close = csec_find_closing_token(tokens, start + 1, end, "(", ")");
        bool hasFunctionParameter = false;
        for (const auto& parameter : parameters) if (parameter.second == "(") hasFunctionParameter = true;
        if (close == end - 1 && hasFunctionParameter) {
            std::string output;
            std::string arguments;
            int argumentStart = start + 2;
            int argumentIndex = 0;
            for (int cursor = argumentStart; cursor <= close; ++cursor) {
                if (cursor == close || csec_is_argument_separator(tokens, close, cursor)) {
                    if (cursor > argumentStart) {
                        if (!arguments.empty()) arguments += ", ";
                        const bool functionArgument = argumentIndex < static_cast<int>(parameters.size()) && parameters[argumentIndex].second == "(";
                        if (functionArgument && csec_token_kind_at(tokens, argumentStart) == 'I' && argumentStart + 1 == cursor) {
                            const int lambdaDeclaration = csec_find_visible_local(tokens, argumentStart, csec_token_text_at(tokens, argumentStart));
                            const int lambdaEnd = lambdaDeclaration >= 0 ? csec_advance_statement(tokens, lambdaDeclaration, 1000000000) : -1;
                            if (lambdaDeclaration >= 0 && csec_lambda_declaration(tokens, lambdaDeclaration, lambdaEnd)) {
                                const std::string closure = resultName + ".closure.arg" + std::to_string(argumentIndex);
                                const char* storage = csec_lookup_visible_storage_name(tokens, argumentStart, csec_token_text_at(tokens, argumentStart));
                                output += "  " + closure + " = load ptr, ptr %" + std::string(storage) + "\n";
                                arguments += "ptr " + closure;
                            } else arguments += "ptr null";
                        } else {
                            const std::string value = resultName + ".arg" + std::to_string(argumentIndex);
                            output += csec_emit_i32_expression(tokens, argumentStart, cursor, value);
                            arguments += "i32 " + value;
                        }
                        ++argumentIndex;
                    }
                    argumentStart = cursor + 1;
                }
            }
            if (std::strcmp(csec_function_return_type_at(tokens, callee), "Boolean") == 0) {
                const std::string booleanResult = resultName + ".i1";
                return output + "  " + booleanResult + " = call i1 @" + std::string(csec_token_text_at(tokens, start)) + "(" + arguments + ")\n" +
                    "  " + resultName + " = zext i1 " + booleanResult + " to i32\n";
            }
            return output + "  " + resultName + " = call i32 @" + std::string(csec_token_text_at(tokens, start)) + "(" + arguments + ")\n";
        }
    }
    if (kind == 'I' && start + 1 < end && csec_native_token_is(tokens, start + 1, 'O', "(")) {
        const int close = csec_find_closing_token(tokens, start + 1, end, "(", ")");
        if (close > start + 1) {
            const int callee = csec_top_level_function_declaration(tokens, csec_token_text_at(tokens, start));
            const auto parameters = callee >= 0 ? csec_function_params(tokens, callee) : std::vector<std::pair<std::string, std::string>>{};
            std::string output;
            std::string arguments;
            int argumentStart = start + 2;
            int argumentIndex = 0;
            for (int cursor = argumentStart; cursor <= close; ++cursor) {
                if (cursor == close || csec_is_argument_separator(tokens, close, cursor)) {
                    if (cursor > argumentStart) {
                        const std::string argumentName = resultName + ".arg" + std::to_string(argumentIndex);
                        const bool pointerArgument = argumentIndex < static_cast<int>(parameters.size()) &&
                            std::strcmp(csec_llvm_type_for_name(parameters[argumentIndex].second), "ptr") == 0;
                        if (!arguments.empty()) arguments += ", ";
                        if (pointerArgument && csec_token_kind_at(tokens, argumentStart) == 'I' && argumentStart + 1 == cursor &&
                            csec_visible_i32_array(tokens, argumentStart, csec_token_text_at(tokens, argumentStart))) {
                            const char* storage = csec_lookup_visible_storage_name(tokens, argumentStart, csec_token_text_at(tokens, argumentStart));
                            output += "  " + argumentName + " = load ptr, ptr %" + std::string(storage) + "\n";
                            arguments += "ptr " + argumentName;
                        } else if (pointerArgument &&
                            (csec_token_kind_at(tokens, argumentStart) == 'S' ||
                             (csec_token_kind_at(tokens, argumentStart) == 'I' && argumentStart + 1 == cursor &&
                              (csec_is_string_local(tokens, argumentStart, csec_token_text_at(tokens, argumentStart)) ||
                               csec_is_string_parameter(tokens, argumentStart, csec_token_text_at(tokens, argumentStart)) ||
                               csec_is_string_class_constructor_param(tokens, argumentStart, csec_token_text_at(tokens, argumentStart)))))) {
                            output += csec_emit_ptr_expression(tokens, argumentStart, cursor, argumentName);
                            arguments += "ptr " + argumentName;
                        } else {
                            const bool booleanArgument = argumentIndex < static_cast<int>(parameters.size()) && parameters[argumentIndex].second == "Boolean";
                            output += booleanArgument
                                ? csec_emit_i1_expression(tokens, argumentStart, cursor, argumentName)
                                : csec_emit_i32_expression(tokens, argumentStart, cursor, argumentName);
                            arguments += std::string(booleanArgument ? "i1 " : "i32 ") + argumentName;
                        }
                        ++argumentIndex;
                    }
                    argumentStart = cursor + 1;
                }
            }
            if (callee >= 0 && std::strcmp(csec_function_return_type_at(tokens, callee), "Boolean") == 0) {
                const std::string booleanResult = resultName + ".i1";
                output += "  " + booleanResult + " = call i1 @" + std::string(csec_token_text_at(tokens, start)) + "(" + arguments + ")\n";
                output += "  " + resultName + " = zext i1 " + booleanResult + " to i32\n";
            } else output += "  " + resultName + " = call i32 @" + std::string(csec_token_text_at(tokens, start)) + "(" + arguments + ")\n";
            return output;
        }
    }
    if (kind == 'I') {
        const char* storage = csec_lookup_visible_storage_name(tokens, start, csec_token_text_at(tokens, start));
        if (csec_is_boolean_local(tokens, start, csec_token_text_at(tokens, start)) ||
            csec_is_boolean_class_constructor_param(tokens, start, csec_token_text_at(tokens, start))) {
            const std::string booleanValue = resultName + ".i1";
            return "  " + booleanValue + " = load i1, ptr %" + std::string(storage) + "\n" +
                "  " + resultName + " = zext i1 " + booleanValue + " to i32\n";
        }
        return "  " + resultName + " = load i32, ptr %" + std::string(storage) + "\n";
    }
    return "  " + resultName + " = add i32 0, 0\n";
}

static std::string csec_emit_f32_expression(const char* tokens, int start, int end, const std::string& resultName) {
    end = csec_i32_expression_end(tokens, start, end);
    if (end <= start) return "  " + resultName + " = fadd float 0.000000e+00, 0.000000e+00\n";
    if (csec_native_token_is(tokens, start, 'O', "(") &&
        csec_find_closing_token(tokens, start, end, "(", ")") == end - 1) {
        return csec_emit_f32_expression(tokens, start + 1, end - 1, resultName);
    }
    if (csec_native_token_is(tokens, start, 'O', "+") && start + 1 < end) {
        return csec_emit_f32_expression(tokens, start + 1, end, resultName);
    }
    if (csec_native_token_is(tokens, start, 'O', "-") && start + 1 < end) {
        const std::string value = resultName + ".value";
        return csec_emit_f32_expression(tokens, start + 1, end, value) +
            "  " + resultName + " = fsub float 0.000000e+00, " + value + "\n";
    }
    const int operation = csec_i32_top_level_operator(tokens, start, end);
    if (operation >= start) {
        const char* op = csec_token_text_at(tokens, operation);
        const char* instruction = std::strcmp(op, "+") == 0 ? "fadd" :
            (std::strcmp(op, "-") == 0 ? "fsub" : (std::strcmp(op, "*") == 0 ? "fmul" :
            (std::strcmp(op, "/") == 0 ? "fdiv" : nullptr)));
        if (instruction) {
            const std::string left = resultName + ".left";
            const std::string right = resultName + ".right";
            return csec_emit_f32_expression(tokens, start, operation, left) +
                csec_emit_f32_expression(tokens, operation + 1, end, right) +
                "  " + resultName + " = " + instruction + " float " + left + ", " + right + "\n";
        }
    }
    const char kind = csec_token_kind_at(tokens, start);
    const std::string indexedArray = csec_emit_f32_array_index(tokens, start, end, resultName);
    if (!indexedArray.empty()) return indexedArray;
    if (kind == 'F' || kind == 'N') {
        const std::string literal = csec_llvm_float_literal(csec_token_text_at(tokens, start));
        return "  " + resultName + " = fadd float 0.000000e+00, " + literal + "\n";
    }
    if (kind == 'I' && start + 1 == end) {
        const char* storage = csec_lookup_visible_storage_name(tokens, start, csec_token_text_at(tokens, start));
        return "  " + resultName + " = load float, ptr %" + std::string(storage) + "\n";
    }
    if (kind == 'I' && start + 1 < end && csec_native_token_is(tokens, start + 1, 'O', "(")) {
        const int close = csec_find_closing_token(tokens, start + 1, end, "(", ")");
        const int callee = csec_top_level_function_declaration(tokens, csec_token_text_at(tokens, start));
        if (close == end - 1 && callee >= 0 && std::strcmp(csec_function_return_type_at(tokens, callee), "Float") == 0) {
            const auto parameters = csec_function_params(tokens, callee);
            std::string output, arguments;
            int itemStart = start + 2, index = 0;
            for (int cursor = itemStart; cursor <= close; ++cursor) {
                if (cursor == close || csec_is_argument_separator(tokens, close, cursor)) {
                    if (cursor > itemStart) {
                        const std::string value = resultName + ".arg" + std::to_string(index);
                        const bool floating = index < static_cast<int>(parameters.size()) && parameters[index].second == "Float";
                        const bool pointer = index < static_cast<int>(parameters.size()) &&
                            (parameters[index].second == "Vector" || parameters[index].second == "Array");
                        output += pointer ? csec_emit_ptr_expression(tokens, itemStart, cursor, value)
                            : (floating ? csec_emit_f32_expression(tokens, itemStart, cursor, value)
                                        : csec_emit_i32_expression(tokens, itemStart, cursor, value));
                        if (!arguments.empty()) arguments += ", ";
                        arguments += std::string(pointer ? "ptr " : (floating ? "float " : "i32 ")) + value;
                        ++index;
                    }
                    itemStart = cursor + 1;
                }
            }
            return output + "  " + resultName + " = call float @" + std::string(csec_token_text_at(tokens, start)) + "(" + arguments + ")\n";
        }
    }
    if (kind == 'I' && start + 3 < end && csec_native_token_is(tokens, start + 1, 'O', ".") &&
        csec_token_kind_at(tokens, start + 2) == 'I' && csec_native_token_is(tokens, start + 3, 'O', "(")) {
        const int close = csec_find_closing_token(tokens, start + 3, end, "(", ")");
        const int declaration = csec_find_visible_local(tokens, start, csec_token_text_at(tokens, start));
        const int declarationEnd = declaration >= 0 ? csec_advance_statement(tokens, declaration, 1000000000) : -1;
        const int initializer = declaration >= 0 ? csec_find_top_level_operator(tokens, declaration, declarationEnd, 1) : -1;
        if (close == end -1 && initializer >= declaration && csec_native_token_is(tokens, initializer + 1, 'K', "new") &&
            csec_token_kind_at(tokens, initializer + 2) == 'I') {
            const std::string className = csec_token_text_at(tokens, initializer + 2);
            const int classStart = csec_find_class_declaration(tokens, className.c_str());
            const int method = classStart >= 0 ? csec_find_class_method_declaration(tokens, classStart, csec_token_text_at(tokens, start + 2)) : -1;
            if (method >= 0 && std::strcmp(csec_function_return_type_at(tokens, method), "Float") == 0) {
                const auto parameters = csec_function_params(tokens, method);
                std::string output, arguments;
                if (csec_class_uses_pointer_receiver(tokens, classStart)) {
                    const char* storage = csec_lookup_visible_storage_name(tokens, start, csec_token_text_at(tokens, start));
                    const std::string receiver = resultName + ".this";
                    output += "  " + receiver + " = load ptr, ptr %" + std::string(storage) + "\n";
                    arguments = "ptr " + receiver;
                }
                int itemStart = start + 4, index = 0;
                for (int cursor = itemStart; cursor <= close; ++cursor) {
                    if (cursor == close || csec_is_argument_separator(tokens, close, cursor)) {
                        if (cursor > itemStart) {
                            const std::string value = resultName + ".arg" + std::to_string(index);
                            const bool floating = index < static_cast<int>(parameters.size()) && parameters[index].second == "Float";
                            output += floating ? csec_emit_f32_expression(tokens, itemStart, cursor, value)
                                               : csec_emit_i32_expression(tokens, itemStart, cursor, value);
                            if (!arguments.empty()) arguments += ", ";
                            arguments += std::string(floating ? "float " : "i32 ") + value;
                            ++index;
                        }
                        itemStart = cursor + 1;
                    }
                }
                return output + "  " + resultName + " = call float @" + className + "_" + csec_token_text_at(tokens, start + 2) + "(" + arguments + ")\n";
            }
        }
    }
    return "  " + resultName + " = fadd float 0.000000e+00, 0.000000e+00\n";
}

static std::string csec_emit_f64_expression(const char* tokens, int start, int end, const std::string& resultName) {
    end = csec_i32_expression_end(tokens, start, end);
    if (end <= start) return "  " + resultName + " = fadd double 0.000000e+00, 0.000000e+00\n";
    if (csec_native_token_is(tokens, start, 'O', "(") && csec_find_closing_token(tokens, start, end, "(", ")") == end - 1)
        return csec_emit_f64_expression(tokens, start + 1, end - 1, resultName);
    if (csec_native_token_is(tokens, start, 'O', "+") && start + 1 < end)
        return csec_emit_f64_expression(tokens, start + 1, end, resultName);
    if (csec_native_token_is(tokens, start, 'O', "-") && start + 1 < end) {
        const std::string value = resultName + ".value";
        return csec_emit_f64_expression(tokens, start + 1, end, value) + "  " + resultName + " = fsub double 0.000000e+00, " + value + "\n";
    }
    const int operation = csec_i32_top_level_operator(tokens, start, end);
    if (operation >= start) {
        const char* op = csec_token_text_at(tokens, operation);
        const char* instruction = std::strcmp(op, "+") == 0 ? "fadd" : (std::strcmp(op, "-") == 0 ? "fsub" :
            (std::strcmp(op, "*") == 0 ? "fmul" : (std::strcmp(op, "/") == 0 ? "fdiv" : nullptr)));
        if (instruction) {
            const std::string left = resultName + ".left";
            const std::string right = resultName + ".right";
            return csec_emit_f64_expression(tokens, start, operation, left) +
                csec_emit_f64_expression(tokens, operation + 1, end, right) +
                "  " + resultName + " = " + instruction + " double " + left + ", " + right + "\n";
        }
    }
    const char kind = csec_token_kind_at(tokens, start);
    const std::string indexedArray = csec_emit_f64_array_index(tokens, start, end, resultName);
    if (!indexedArray.empty()) return indexedArray;
    if (kind == 'F' || kind == 'N') return "  " + resultName + " = fadd double 0.000000e+00, " + csec_llvm_double_literal(csec_token_text_at(tokens, start)) + "\n";
    if (kind == 'I' && start + 1 == end) {
        const char* storage = csec_lookup_visible_storage_name(tokens, start, csec_token_text_at(tokens, start));
        return "  " + resultName + " = load double, ptr %" + std::string(storage) + "\n";
    }
    if (kind == 'I' && start + 1 < end && csec_native_token_is(tokens, start + 1, 'O', "(")) {
        const int close = csec_find_closing_token(tokens, start + 1, end, "(", ")");
        const int callee = csec_top_level_function_declaration(tokens, csec_token_text_at(tokens, start));
        if (close == end - 1 && callee >= 0 && std::strcmp(csec_function_return_type_at(tokens, callee), "Double") == 0) {
            const auto parameters = csec_function_params(tokens, callee);
            std::string output, arguments;
            int itemStart = start + 2, index = 0;
            for (int cursor = itemStart; cursor <= close; ++cursor) {
                if (cursor == close || csec_is_argument_separator(tokens, close, cursor)) {
                    if (cursor > itemStart) {
                        const std::string value = resultName + ".arg" + std::to_string(index);
                        const bool floating = index < static_cast<int>(parameters.size()) && parameters[index].second == "Double";
                        const bool pointer = index < static_cast<int>(parameters.size()) &&
                            (parameters[index].second == "Vector" || parameters[index].second == "Array");
                        output += pointer ? csec_emit_ptr_expression(tokens, itemStart, cursor, value)
                            : (floating ? csec_emit_f64_expression(tokens, itemStart, cursor, value)
                                        : csec_emit_i32_expression(tokens, itemStart, cursor, value));
                        if (!arguments.empty()) arguments += ", ";
                        arguments += std::string(pointer ? "ptr " : (floating ? "double " : "i32 ")) + value;
                        ++index;
                    }
                    itemStart = cursor + 1;
                }
            }
            return output + "  " + resultName + " = call double @" + std::string(csec_token_text_at(tokens, start)) + "(" + arguments + ")\n";
        }
    }
    if (kind == 'I' && start + 3 < end && csec_native_token_is(tokens, start + 1, 'O', ".") &&
        csec_token_kind_at(tokens, start + 2) == 'I' && csec_native_token_is(tokens, start + 3, 'O', "(")) {
        const int close = csec_find_closing_token(tokens, start + 3, end, "(", ")");
        const int declaration = csec_find_visible_local(tokens, start, csec_token_text_at(tokens, start));
        const int declarationEnd = declaration >= 0 ? csec_advance_statement(tokens, declaration, 1000000000) : -1;
        const int initializer = declaration >= 0 ? csec_find_top_level_operator(tokens, declaration, declarationEnd, 1) : -1;
        if (close == end - 1 && initializer >= declaration && csec_native_token_is(tokens, initializer + 1, 'K', "new") &&
            csec_token_kind_at(tokens, initializer + 2) == 'I') {
            const std::string className = csec_token_text_at(tokens, initializer + 2);
            const int classStart = csec_find_class_declaration(tokens, className.c_str());
            const int method = classStart >= 0 ? csec_find_class_method_declaration(tokens, classStart, csec_token_text_at(tokens, start + 2)) : -1;
            if (method >= 0 && std::strcmp(csec_function_return_type_at(tokens, method), "Double") == 0) {
                const auto parameters = csec_function_params(tokens, method);
                std::string output, arguments;
                if (csec_class_uses_pointer_receiver(tokens, classStart)) {
                    const char* storage = csec_lookup_visible_storage_name(tokens, start, csec_token_text_at(tokens, start));
                    const std::string receiver = resultName + ".this";
                    output += "  " + receiver + " = load ptr, ptr %" + std::string(storage) + "\n";
                    arguments = "ptr " + receiver;
                }
                int itemStart = start + 4, index = 0;
                for (int cursor = itemStart; cursor <= close; ++cursor) {
                    if (cursor == close || csec_is_argument_separator(tokens, close, cursor)) {
                        if (cursor > itemStart) {
                        const std::string value = resultName + ".arg" + std::to_string(index);
                        const bool doubleArgument = index < static_cast<int>(parameters.size()) && parameters[index].second == "Double";
                        const bool pointer = index < static_cast<int>(parameters.size()) &&
                            (parameters[index].second == "Vector" || parameters[index].second == "Array");
                        output += pointer ? csec_emit_ptr_expression(tokens, itemStart, cursor, value)
                            : (doubleArgument ? csec_emit_f64_expression(tokens, itemStart, cursor, value)
                                              : csec_emit_i32_expression(tokens, itemStart, cursor, value));
                        if (!arguments.empty()) arguments += ", ";
                        arguments += std::string(pointer ? "ptr " : (doubleArgument ? "double " : "i32 ")) + value;
                            ++index;
                        }
                        itemStart = cursor + 1;
                    }
                }
                return output + "  " + resultName + " = call double @" + className + "_" + csec_token_text_at(tokens, start + 2) + "(" + arguments + ")\n";
            }
        }
    }
    return "  " + resultName + " = fadd double 0.000000e+00, 0.000000e+00\n";
}

static std::string csec_emit_i64_expression(const char* tokens, int start, int end, const std::string& resultName) {
    end = csec_i32_expression_end(tokens, start, end);
    if (end <= start) return "  " + resultName + " = add i64 0, 0\n";
    const std::string indexedArray = csec_emit_i64_array_index(tokens, start, end, resultName);
    if (!indexedArray.empty()) return indexedArray;
    if (csec_native_token_is(tokens, start, 'O', "(") && csec_find_closing_token(tokens, start, end, "(", ")") == end - 1)
        return csec_emit_i64_expression(tokens, start + 1, end - 1, resultName);
    const int operation = csec_i32_top_level_operator(tokens, start, end);
    if (operation >= start) {
        const char* op = csec_token_text_at(tokens, operation);
        const char* instruction = std::strcmp(op, "+") == 0 ? "add" : std::strcmp(op, "-") == 0 ? "sub" :
            std::strcmp(op, "*") == 0 ? "mul" : std::strcmp(op, "/") == 0 ? "sdiv" : std::strcmp(op, "%") == 0 ? "srem" : nullptr;
        if (instruction) {
            const std::string left = resultName + ".left", right = resultName + ".right";
            return csec_emit_i64_expression(tokens, start, operation, left) + csec_emit_i64_expression(tokens, operation + 1, end, right) +
                "  " + resultName + " = " + instruction + " i64 " + left + ", " + right + "\n";
        }
    }
    if (csec_token_kind_at(tokens, start) == 'N') return "  " + resultName + " = add i64 0, " + std::string(csec_token_text_at(tokens, start)) + "\n";
    if (csec_token_kind_at(tokens, start) == 'I' && start + 1 == end) {
        const std::string name = csec_token_text_at(tokens, start);
        const int declaration = csec_find_visible_local(tokens, start, name.c_str());
        const int declarationEnd = declaration >= 0 ? csec_advance_statement(tokens, declaration, 1000000000) : -1;
        const int initializer = declaration >= 0 ? csec_find_top_level_operator(tokens, declaration, declarationEnd, 1) : -1;
        if (declaration >= 0 && csec_is_i64_type_name(csec_c_local_type(tokens, declaration, declarationEnd, initializer)))
            return "  " + resultName + " = load i64, ptr %" + csec_lookup_visible_storage_name(tokens, start, name.c_str()) + "\n";
        const int function = csec_enclosing_function_declaration(tokens, start);
        if (function >= 0) for (const auto& parameter : csec_function_params(tokens, function)) if (parameter.first == name && csec_is_i64_type_name(parameter.second))
            return "  " + resultName + " = load i64, ptr %" + csec_lookup_visible_storage_name(tokens, start, name.c_str()) + "\n";
        return "  " + resultName + " = load i64, ptr %" + name + "\n";
    }
    if (csec_token_kind_at(tokens, start) == 'I' && start + 1 < end && csec_native_token_is(tokens, start + 1, 'O', "(")) {
        const int callee = csec_top_level_function_declaration(tokens, csec_token_text_at(tokens, start));
        const int close = csec_find_closing_token(tokens, start + 1, end, "(", ")");
        if (callee >= 0 && close == end - 1 && csec_is_i64_type_name(csec_function_return_type_at(tokens, callee))) {
            const auto parameters = csec_function_params(tokens, callee);
            std::string output, arguments; int itemStart = start + 2; int index = 0;
            for (int cursor = itemStart; cursor <= close; ++cursor) if (cursor == close || csec_is_argument_separator(tokens, close, cursor)) {
                if (cursor > itemStart) {
                    const std::string value = resultName + ".arg" + std::to_string(itemStart);
                    const bool pointer = index < static_cast<int>(parameters.size()) &&
                        (parameters[index].second == "Vector" || parameters[index].second == "Array");
                    if (pointer) {
                        const char* storage = csec_lookup_visible_storage_name(tokens, itemStart, csec_token_text_at(tokens, itemStart));
                        output += "  " + value + " = load ptr, ptr %" + std::string(storage) + "\n";
                        arguments += (arguments.empty() ? "" : ", ") + std::string("ptr ") + value;
                    } else {
                        output += csec_emit_i64_expression(tokens, itemStart, cursor, value);
                        arguments += (arguments.empty() ? "" : ", ") + std::string("i64 ") + value;
                    }
                    ++index;
                }
                itemStart = cursor + 1;
            }
            return output + "  " + resultName + " = call i64 @" + std::string(csec_token_text_at(tokens, start)) + "(" + arguments + ")\n";
        }
    }
    return "  " + resultName + " = add i64 0, 0\n";
}

static std::string csec_emit_i8_expression(const char* tokens, int start, int end, const std::string& resultName) {
    end = csec_i32_expression_end(tokens, start, end);
    if (end <= start) return "  " + resultName + " = add i8 0, 0\n";
    if (csec_native_token_is(tokens, start, 'O', "(") &&
        csec_find_closing_token(tokens, start, end, "(", ")") == end - 1) {
        return csec_emit_i8_expression(tokens, start + 1, end - 1, resultName);
    }
    if (csec_token_kind_at(tokens, start) == 'N') {
        return "  " + resultName + " = trunc i32 " + std::string(csec_token_text_at(tokens, start)) + " to i8\n";
    }
    if (csec_token_kind_at(tokens, start) == 'C') {
        const std::string literal = csec_token_text_at(tokens, start);
        int value = 0;
        if (literal.size() == 1) value = static_cast<unsigned char>(literal[0]);
        else if (literal.size() >= 3 && literal[0] == '\'' && literal[1] != '\\') value = static_cast<unsigned char>(literal[1]);
        else if (literal.size() >= 4 && literal[0] == '\'' && literal[1] == '\\') {
            const char escaped = literal[2];
            value = escaped == 'n' ? '\n' : escaped == 'r' ? '\r' : escaped == 't' ? '\t' : escaped == '0' ? 0 : static_cast<unsigned char>(escaped);
        }
        return "  " + resultName + " = add i8 0, " + std::to_string(value) + "\n";
    }
    const std::string indexedArray = csec_emit_i8_array_index(tokens, start, end, resultName);
    if (!indexedArray.empty()) return indexedArray;
    if (csec_token_kind_at(tokens, start) == 'I' && start + 1 == end) {
        const std::string name = csec_token_text_at(tokens, start);
        const int declaration = csec_find_visible_local(tokens, start, name.c_str());
        const int declarationEnd = declaration >= 0 ? csec_advance_statement(tokens, declaration, 1000000000) : -1;
        const int initializer = declaration >= 0 ? csec_find_top_level_operator(tokens, declaration, declarationEnd, 1) : -1;
        if (declaration >= 0 && csec_is_i8_type_name(csec_c_local_type(tokens, declaration, declarationEnd, initializer))) {
            return "  " + resultName + " = load i8, ptr %" + csec_lookup_visible_storage_name(tokens, start, name.c_str()) + "\n";
        }
        const int function = csec_enclosing_function_declaration(tokens, start);
        if (function >= 0) {
            for (const auto& parameter : csec_function_params(tokens, function)) {
                if (parameter.first == name && csec_is_i8_type_name(parameter.second)) {
                    return "  " + resultName + " = load i8, ptr %" + csec_lookup_visible_storage_name(tokens, start, name.c_str()) + "\n";
                }
            }
        }
    }
    if (csec_token_kind_at(tokens, start) == 'I' && start + 1 < end && csec_native_token_is(tokens, start + 1, 'O', "(")) {
        const int callee = csec_top_level_function_declaration(tokens, csec_token_text_at(tokens, start));
        const int close = csec_find_closing_token(tokens, start + 1, end, "(", ")");
        if (callee >= 0 && close == end - 1 && csec_is_i8_type_name(csec_function_return_type_at(tokens, callee))) {
            const auto parameters = csec_function_params(tokens, callee);
            std::string output, arguments;
            int argumentStart = start + 2;
            int index = 0;
            for (int cursor = argumentStart; cursor <= close; ++cursor) {
                if (cursor == close || csec_is_argument_separator(tokens, close, cursor)) {
                    if (cursor > argumentStart) {
                        const std::string value = resultName + ".arg" + std::to_string(index);
                        const bool pointer = index < static_cast<int>(parameters.size()) &&
                            (parameters[index].second == "Vector" || parameters[index].second == "Array");
                        if (pointer) {
                            const char* storage = csec_lookup_visible_storage_name(tokens, argumentStart, csec_token_text_at(tokens, argumentStart));
                            output += "  " + value + " = load ptr, ptr %" + std::string(storage) + "\n";
                            arguments += (arguments.empty() ? "" : ", ") + std::string("ptr ") + value;
                        } else {
                            output += csec_emit_i8_expression(tokens, argumentStart, cursor, value);
                            arguments += (arguments.empty() ? "" : ", ") + std::string("i8 ") + value;
                        }
                        ++index;
                    }
                    argumentStart = cursor + 1;
                }
            }
            return output + "  " + resultName + " = call i8 @" + std::string(csec_token_text_at(tokens, start)) + "(" + arguments + ")\n";
        }
    }
    const std::string wide = resultName + ".i32";
    return csec_emit_i32_expression(tokens, start, end, wide) +
        "  " + resultName + " = trunc i32 " + wide + " to i8\n";
}

static std::string csec_emit_i16_expression(const char* tokens, int start, int end, const std::string& resultName) {
    end = csec_i32_expression_end(tokens, start, end);
    if (end <= start) return "  " + resultName + " = add i16 0, 0\n";
    const std::string indexedArray = csec_emit_i16_array_index(tokens, start, end, resultName);
    if (!indexedArray.empty()) return indexedArray;
    if (csec_native_token_is(tokens, start, 'O', "(") && csec_find_closing_token(tokens, start, end, "(", ")") == end - 1)
        return csec_emit_i16_expression(tokens, start + 1, end - 1, resultName);
    if (csec_token_kind_at(tokens, start) == 'I' && start + 1 == end) {
        const std::string name = csec_token_text_at(tokens, start);
        const int declaration = csec_find_visible_local(tokens, start, name.c_str());
        const int declarationEnd = declaration >= 0 ? csec_advance_statement(tokens, declaration, 1000000000) : -1;
        const int initializer = declaration >= 0 ? csec_find_top_level_operator(tokens, declaration, declarationEnd, 1) : -1;
        if (declaration >= 0 && csec_is_i16_type_name(csec_c_local_type(tokens, declaration, declarationEnd, initializer)))
            return "  " + resultName + " = load i16, ptr %" + csec_lookup_visible_storage_name(tokens, start, name.c_str()) + "\n";
        const int function = csec_enclosing_function_declaration(tokens, start);
        if (function >= 0) for (const auto& parameter : csec_function_params(tokens, function)) if (parameter.first == name && csec_is_i16_type_name(parameter.second))
            return "  " + resultName + " = load i16, ptr %" + csec_lookup_visible_storage_name(tokens, start, name.c_str()) + "\n";
    }
    if (csec_token_kind_at(tokens, start) == 'I' && start + 1 < end && csec_native_token_is(tokens, start + 1, 'O', "(")) {
        const int callee = csec_top_level_function_declaration(tokens, csec_token_text_at(tokens, start));
        const int close = csec_find_closing_token(tokens, start + 1, end, "(", ")");
        if (callee >= 0 && close == end - 1 && csec_is_i16_type_name(csec_function_return_type_at(tokens, callee))) {
            const auto parameters = csec_function_params(tokens, callee);
            std::string output, arguments;
            int argumentStart = start + 2;
            int index = 0;
            for (int cursor = argumentStart; cursor <= close; ++cursor) if (cursor == close || csec_is_argument_separator(tokens, close, cursor)) {
                if (cursor > argumentStart) {
                    const std::string value = resultName + ".arg" + std::to_string(index);
                    const bool pointer = index < static_cast<int>(parameters.size()) &&
                        (parameters[index].second == "Vector" || parameters[index].second == "Array");
                    if (pointer) {
                        const char* storage = csec_lookup_visible_storage_name(tokens, argumentStart, csec_token_text_at(tokens, argumentStart));
                        output += "  " + value + " = load ptr, ptr %" + std::string(storage) + "\n";
                        arguments += (arguments.empty() ? "" : ", ") + std::string("ptr ") + value;
                    } else {
                        output += csec_emit_i16_expression(tokens, argumentStart, cursor, value);
                        arguments += (arguments.empty() ? "" : ", ") + std::string("i16 ") + value;
                    }
                    ++index;
                }
                argumentStart = cursor + 1;
            }
            return output + "  " + resultName + " = call i16 @" + std::string(csec_token_text_at(tokens, start)) + "(" + arguments + ")\n";
        }
    }
    const std::string wide = resultName + ".i32";
    return csec_emit_i32_expression(tokens, start, end, wide) + "  " + resultName + " = trunc i32 " + wide + " to i16\n";
}

static std::string csec_emit_i1_expression(const char* tokens, int start, int end, const std::string& resultName) {
    end = csec_i32_expression_end(tokens, start, end);
    if (end <= start) return "  " + resultName + " = icmp eq i32 0, 1\n";
    if (csec_native_token_is(tokens, start, 'O', "(") &&
        csec_find_closing_token(tokens, start, end, "(", ")") == end - 1) {
        return csec_emit_i1_expression(tokens, start + 1, end - 1, resultName);
    }
    if (csec_native_token_is(tokens, start, 'O', "!") && start + 1 < end) {
        const std::string value = resultName + ".value";
        return csec_emit_i1_expression(tokens, start + 1, end, value) +
            "  " + resultName + " = xor i1 " + value + ", true\n";
    }
    if (csec_token_kind_at(tokens, start) == 'B') {
        return "  " + resultName + " = icmp eq i32 0, " +
            std::string(std::strcmp(csec_token_text_at(tokens, start), "true") == 0 ? "0\n" : "1\n");
    }
    const int floatComparison = csec_i32_top_level_operator(tokens, start, end);
    if (floatComparison >= start) {
        const char* op = csec_token_text_at(tokens, floatComparison);
        if ((std::strcmp(op, "==") == 0 || std::strcmp(op, "!=") == 0 || std::strcmp(op, "<") == 0 ||
             std::strcmp(op, "<=") == 0 || std::strcmp(op, ">") == 0 || std::strcmp(op, ">=") == 0) &&
            csec_token_kind_at(tokens, start) == 'I') {
            const std::string name = csec_token_text_at(tokens, start);
            const int declaration = csec_find_visible_local(tokens, start, name.c_str());
            const int declarationEnd = declaration >= 0 ? csec_advance_statement(tokens, declaration, 1000000000) : -1;
            const int initializer = declaration >= 0 ? csec_find_top_level_operator(tokens, declaration, declarationEnd, 1) : -1;
            if (declaration >= 0 && csec_is_i16_type_name(csec_c_local_type(tokens, declaration, declarationEnd, initializer))) {
                const std::string left = resultName + ".left", right = resultName + ".right";
                const char* predicate = std::strcmp(op, "==") == 0 ? "eq" : std::strcmp(op, "!=") == 0 ? "ne" : std::strcmp(op, "<") == 0 ? "slt" : std::strcmp(op, "<=") == 0 ? "sle" : std::strcmp(op, ">") == 0 ? "sgt" : "sge";
                return csec_emit_i16_expression(tokens, start, floatComparison, left) + csec_emit_i16_expression(tokens, floatComparison + 1, end, right) +
                    "  " + resultName + " = icmp " + predicate + " i16 " + left + ", " + right + "\n";
            }
            if (declaration >= 0 && csec_is_i8_type_name(csec_c_local_type(tokens, declaration, declarationEnd, initializer))) {
                const std::string left = resultName + ".left", right = resultName + ".right";
                const char* predicate = std::strcmp(op, "==") == 0 ? "eq" : std::strcmp(op, "!=") == 0 ? "ne" :
                    std::strcmp(op, "<") == 0 ? "slt" : std::strcmp(op, "<=") == 0 ? "sle" : std::strcmp(op, ">") == 0 ? "sgt" : "sge";
                return csec_emit_i8_expression(tokens, start, floatComparison, left) +
                    csec_emit_i8_expression(tokens, floatComparison + 1, end, right) +
                    "  " + resultName + " = icmp " + predicate + " i8 " + left + ", " + right + "\n";
            }
            if (declaration >= 0 && csec_is_i64_type_name(csec_c_local_type(tokens, declaration, declarationEnd, initializer))) {
                const std::string left = resultName + ".left", right = resultName + ".right";
                const char* predicate = std::strcmp(op, "==") == 0 ? "eq" : std::strcmp(op, "!=") == 0 ? "ne" :
                    std::strcmp(op, "<") == 0 ? "slt" : std::strcmp(op, "<=") == 0 ? "sle" : std::strcmp(op, ">") == 0 ? "sgt" : "sge";
                return csec_emit_i64_expression(tokens, start, floatComparison, left) +
                    csec_emit_i64_expression(tokens, floatComparison + 1, end, right) +
                    "  " + resultName + " = icmp " + predicate + " i64 " + left + ", " + right + "\n";
            }
        }
        if (std::strcmp(op, "and") == 0 || std::strcmp(op, "&&") == 0 ||
            std::strcmp(op, "or") == 0 || std::strcmp(op, "||") == 0) {
            const std::string left = resultName + ".left";
            const std::string right = resultName + ".right";
            const char* instruction = (std::strcmp(op, "and") == 0 || std::strcmp(op, "&&") == 0) ? "and" : "or";
            return csec_emit_i1_expression(tokens, start, floatComparison, left) +
                csec_emit_i1_expression(tokens, floatComparison + 1, end, right) +
                "  " + resultName + " = " + instruction + " i1 " + left + ", " + right + "\n";
        }
        if ((std::strcmp(op, "==") == 0 || std::strcmp(op, "!=") == 0 || std::strcmp(op, "<") == 0 ||
             std::strcmp(op, "<=") == 0 || std::strcmp(op, ">") == 0 || std::strcmp(op, ">=") == 0) &&
            (csec_expression_is_double(tokens, start, floatComparison) || csec_expression_is_double(tokens, floatComparison + 1, end))) {
            const std::string left = resultName + ".left";
            const std::string right = resultName + ".right";
            const char* predicate = std::strcmp(op, "==") == 0 ? "oeq" : (std::strcmp(op, "!=") == 0 ? "one" :
                (std::strcmp(op, "<") == 0 ? "olt" : (std::strcmp(op, "<=") == 0 ? "ole" : (std::strcmp(op, ">") == 0 ? "ogt" : "oge"))));
            return csec_emit_f64_expression(tokens, start, floatComparison, left) +
                csec_emit_f64_expression(tokens, floatComparison + 1, end, right) +
                "  " + resultName + " = fcmp " + predicate + " double " + left + ", " + right + "\n";
        }
        if ((std::strcmp(op, "==") == 0 || std::strcmp(op, "!=") == 0 || std::strcmp(op, "<") == 0 ||
             std::strcmp(op, "<=") == 0 || std::strcmp(op, ">") == 0 || std::strcmp(op, ">=") == 0) &&
            (csec_expression_is_float(tokens, start, floatComparison) ||
             csec_expression_is_float(tokens, floatComparison + 1, end))) {
            const std::string left = resultName + ".left";
            const std::string right = resultName + ".right";
            const char* predicate = std::strcmp(op, "==") == 0 ? "oeq" :
                (std::strcmp(op, "!=") == 0 ? "one" : (std::strcmp(op, "<") == 0 ? "olt" :
                (std::strcmp(op, "<=") == 0 ? "ole" : (std::strcmp(op, ">") == 0 ? "ogt" : "oge"))));
            return csec_emit_f32_expression(tokens, start, floatComparison, left) +
                csec_emit_f32_expression(tokens, floatComparison + 1, end, right) +
                "  " + resultName + " = fcmp " + predicate + " float " + left + ", " + right + "\n";
        }
    }
    const char kind = csec_token_kind_at(tokens, start);
    if (csec_native_token_is(tokens, start, 'K', "super") && start + 4 < end &&
        csec_native_token_is(tokens, start + 1, 'O', ".") && csec_token_kind_at(tokens, start + 2) == 'I' &&
        csec_native_token_is(tokens, start + 3, 'O', "(")) {
        const int close = csec_find_closing_token(tokens, start + 3, end, "(", ")");
        const int classStart = csec_enclosing_class_declaration(tokens, start);
        const std::string parent = classStart >= 0 ? csec_class_parent_name(tokens, classStart) : "";
        const int parentStart = parent.empty() ? -1 : csec_find_class_declaration(tokens, parent.c_str());
        if (close == end - 1 && parentStart >= 0 && csec_class_uses_pointer_receiver(tokens, parentStart)) {
            return "  " + resultName + " = call i1 @" + parent + "_" +
                csec_token_text_at(tokens, start + 2) + "(ptr %arg.this)\n";
        }
    }
    if (kind == 'I' && start + 1 < end && csec_native_token_is(tokens, start + 1, 'O', "(") &&
        csec_is_function_parameter(tokens, start, csec_token_text_at(tokens, start)) &&
        csec_function_parameter_returns_boolean(tokens, start, csec_token_text_at(tokens, start))) {
        const int close = csec_find_closing_token(tokens, start + 1, end, "(", ")");
        if (close == end - 1) {
            std::string output, arguments;
            int argumentStart = start + 2, index = 0;
            for (int cursor = argumentStart; cursor <= close; ++cursor) {
                if (cursor == close || csec_is_argument_separator(tokens, close, cursor)) {
                    if (cursor > argumentStart) {
                        const std::string value = resultName + ".arg" + std::to_string(index++);
                        output += csec_emit_i32_expression(tokens, argumentStart, cursor, value);
                        if (!arguments.empty()) arguments += ", ";
                        arguments += "i32 " + value;
                    }
                    argumentStart = cursor + 1;
                }
            }
            const char* storage = csec_lookup_visible_storage_name(tokens, start, csec_token_text_at(tokens, start));
            const std::string closure = resultName + ".closure";
            const std::string codeField = resultName + ".code.field";
            const std::string environmentField = resultName + ".environment.field";
            const std::string functionValue = resultName + ".fn";
            const std::string environment = resultName + ".environment";
            return output + "  " + closure + " = load ptr, ptr %" + std::string(storage) + "\n" +
                "  " + codeField + " = getelementptr inbounds { ptr, ptr }, ptr " + closure + ", i32 0, i32 0\n" +
                "  " + functionValue + " = load ptr, ptr " + codeField + "\n" +
                "  " + environmentField + " = getelementptr inbounds { ptr, ptr }, ptr " + closure + ", i32 0, i32 1\n" +
                "  " + environment + " = load ptr, ptr " + environmentField + "\n" +
                "  " + resultName + " = call i1 " + functionValue + "(ptr " + environment + (arguments.empty() ? "" : ", " + arguments) + ")\n";
        }
    }
    if (kind == 'I' && start + 1 < end && csec_native_token_is(tokens, start + 1, 'O', "(")) {
        const int declaration = csec_find_visible_local(tokens, start, csec_token_text_at(tokens, start));
        const int declarationEnd = declaration >= 0 ? csec_advance_statement(tokens, declaration, 1000000000) : -1;
        int lambdaReturn = -1;
        if (declaration >= 0 && csec_lambda_declaration(tokens, declaration, declarationEnd)) {
            int bodyStart = -1, bodyEnd = -1;
            csec_lambda_declaration(tokens, declaration, declarationEnd, &bodyStart, &bodyEnd);
            for (int cursor = bodyStart; cursor < bodyEnd;) {
                const int next = csec_advance_statement(tokens, cursor, bodyEnd);
                if (csec_native_token_is(tokens, cursor, 'K', "return")) { lambdaReturn = cursor + 1; break; }
                if (next <= cursor) break;
                cursor = next;
            }
            if (lambdaReturn >= 0 && csec_expression_is_boolean(tokens, lambdaReturn, bodyEnd)) {
                const int close = csec_find_closing_token(tokens, start + 1, end, "(", ")");
                if (close == end - 1) {
                    std::string output, arguments;
                    const char* storage = csec_lookup_visible_storage_name(tokens, start, csec_token_text_at(tokens, start));
                    const std::string closure = resultName + ".closure";
                    const std::string codeField = resultName + ".code.field";
                    const std::string environmentField = resultName + ".environment.field";
                    const std::string code = resultName + ".code";
                    const std::string environment = resultName + ".environment";
                    const std::string closureType = csec_lambda_closure_type_name(declaration);
                    output += "  " + closure + " = load ptr, ptr %" + std::string(storage) + "\n";
                    output += "  " + codeField + " = getelementptr inbounds " + closureType + ", ptr " + closure + ", i32 0, i32 0\n";
                    output += "  " + code + " = load ptr, ptr " + codeField + "\n";
                    output += "  " + environmentField + " = getelementptr inbounds " + closureType + ", ptr " + closure + ", i32 0, i32 1\n";
                    output += "  " + environment + " = load ptr, ptr " + environmentField + "\n";
                    arguments = "ptr " + environment;
                    int argumentStart = start + 2, index = 0;
                    for (int cursor = argumentStart; cursor <= close; ++cursor) {
                        if (cursor == close || csec_is_argument_separator(tokens, close, cursor)) {
                            if (cursor > argumentStart) {
                                const std::string value = resultName + ".arg" + std::to_string(index++);
                                output += csec_emit_i32_expression(tokens, argumentStart, cursor, value);
                                if (!arguments.empty()) arguments += ", ";
                                arguments += "i32 " + value;
                            }
                            argumentStart = cursor + 1;
                        }
                    }
                    return output + "  " + resultName + " = call i1 " + code + "(" + arguments + ")\n";
                }
            }
        }
        const int callee = csec_top_level_function_declaration(tokens, csec_token_text_at(tokens, start));
        if (callee >= 0 && std::strcmp(csec_function_return_type_at(tokens, callee), "Boolean") == 0) {
            const int close = csec_find_closing_token(tokens, start + 1, end, "(", ")");
            if (close == end - 1) {
                const auto parameters = csec_function_params(tokens, callee);
                std::string output, arguments;
                int argumentStart = start + 2, index = 0;
                for (int cursor = argumentStart; cursor <= close; ++cursor) {
                    if (cursor == close || csec_is_argument_separator(tokens, close, cursor)) {
                        if (cursor > argumentStart) {
                            if (!arguments.empty()) arguments += ", ";
                            const bool functionArgument = index < static_cast<int>(parameters.size()) && parameters[index].second == "(";
                            if (functionArgument && csec_token_kind_at(tokens, argumentStart) == 'I' && argumentStart + 1 == cursor) {
                                const int lambdaDeclaration = csec_find_visible_local(tokens, argumentStart, csec_token_text_at(tokens, argumentStart));
                                const int lambdaEnd = lambdaDeclaration >= 0 ? csec_advance_statement(tokens, lambdaDeclaration, 1000000000) : -1;
                                if (lambdaDeclaration >= 0 && csec_lambda_declaration(tokens, lambdaDeclaration, lambdaEnd)) {
                                    const std::string closure = resultName + ".closure.arg" + std::to_string(index);
                                    const char* storage = csec_lookup_visible_storage_name(tokens, argumentStart, csec_token_text_at(tokens, argumentStart));
                                    output += "  " + closure + " = load ptr, ptr %" + std::string(storage) + "\n";
                                    arguments += "ptr " + closure;
                                } else arguments += "ptr null";
                            } else {
                                const std::string value = resultName + ".arg" + std::to_string(index);
                                const bool booleanArgument = index < static_cast<int>(parameters.size()) && parameters[index].second == "Boolean";
                                const bool arrayArgument = index < static_cast<int>(parameters.size()) &&
                                    csec_token_kind_at(tokens, argumentStart) == 'I' && argumentStart + 1 == cursor &&
                                    (csec_visible_i32_array(tokens, argumentStart, csec_token_text_at(tokens, argumentStart)) ||
                                     csec_visible_i1_array(tokens, argumentStart, csec_token_text_at(tokens, argumentStart)));
                                const bool pointerArgument = index < static_cast<int>(parameters.size()) &&
                                    std::strcmp(csec_llvm_type_for_name(parameters[index].second), "ptr") == 0;
                                if (arrayArgument) {
                                    const char* storage = csec_lookup_visible_storage_name(tokens, argumentStart, csec_token_text_at(tokens, argumentStart));
                                    output += "  " + value + " = load ptr, ptr %" + std::string(storage) + "\n";
                                    arguments += "ptr " + value;
                                } else if (pointerArgument) {
                                    output += csec_emit_ptr_expression(tokens, argumentStart, cursor, value);
                                    arguments += "ptr " + value;
                                } else {
                                    output += booleanArgument
                                        ? csec_emit_i1_expression(tokens, argumentStart, cursor, value)
                                        : csec_emit_i32_expression(tokens, argumentStart, cursor, value);
                                    arguments += std::string(booleanArgument ? "i1 " : "i32 ") + value;
                                }
                            }
                            ++index;
                        }
                        argumentStart = cursor + 1;
                    }
                }
                return output + "  " + resultName + " = call i1 @" + std::string(csec_token_text_at(tokens, start)) + "(" + arguments + ")\n";
            }
        }
    }
    if (kind == 'I' && start + 3 < end && csec_native_token_is(tokens, start + 1, 'O', ".") &&
        csec_token_kind_at(tokens, start + 2) == 'I' && csec_native_token_is(tokens, start + 3, 'O', "(")) {
        const int close = csec_find_closing_token(tokens, start + 3, end, "(", ")");
        const int declaration = csec_find_visible_local(tokens, start, csec_token_text_at(tokens, start));
        const int declarationEnd = declaration >= 0 ? csec_advance_statement(tokens, declaration, 1000000000) : -1;
        const int initializer = declaration >= 0 ? csec_find_top_level_operator(tokens, declaration, declarationEnd, 1) : -1;
        if (close == end - 1 && initializer >= declaration && csec_native_token_is(tokens, initializer + 1, 'K', "new") &&
            csec_token_kind_at(tokens, initializer + 2) == 'I') {
            const std::string className = csec_token_text_at(tokens, initializer + 2);
            const int classStart = csec_find_class_declaration(tokens, className.c_str());
            const int method = classStart >= 0 ? csec_find_class_method_declaration(tokens, classStart, csec_token_text_at(tokens, start + 2)) : -1;
            if (method >= 0 && std::strcmp(csec_function_return_type_at(tokens, method), "Boolean") == 0) {
                const auto parameters = csec_function_params(tokens, method);
                std::string output, arguments;
                if (csec_class_uses_pointer_receiver(tokens, classStart)) {
                    const char* storage = csec_lookup_visible_storage_name(tokens, start, csec_token_text_at(tokens, start));
                    const std::string receiver = resultName + ".this";
                    output += "  " + receiver + " = load ptr, ptr %" + std::string(storage) + "\n";
                    arguments = "ptr " + receiver;
                }
                int itemStart = start + 4, index = 0;
                for (int cursor = itemStart; cursor <= close; ++cursor) {
                    if (cursor == close || csec_is_argument_separator(tokens, close, cursor)) {
                        if (cursor > itemStart) {
                            const std::string value = resultName + ".arg" + std::to_string(index);
                            const bool floating = index < static_cast<int>(parameters.size()) && parameters[index].second == "Float";
                            output += floating ? csec_emit_f32_expression(tokens, itemStart, cursor, value)
                                               : csec_emit_i32_expression(tokens, itemStart, cursor, value);
                            if (!arguments.empty()) arguments += ", ";
                            arguments += std::string(floating ? "float " : "i32 ") + value;
                            ++index;
                        }
                        itemStart = cursor + 1;
                    }
                }
                return output + "  " + resultName + " = call i1 @" + className + "_" + csec_token_text_at(tokens, start + 2) + "(" + arguments + ")\n";
            }
        }
    }
    const std::string indexedArray = csec_emit_i1_array_index(tokens, start, end, resultName);
    if (!indexedArray.empty()) return indexedArray;
    if (kind == 'I' && start + 1 == end &&
        (csec_is_boolean_local(tokens, start, csec_token_text_at(tokens, start)) ||
         csec_is_boolean_parameter(tokens, start, csec_token_text_at(tokens, start)) ||
         csec_is_boolean_class_constructor_param(tokens, start, csec_token_text_at(tokens, start)))) {
        const char* storage = csec_lookup_visible_storage_name(tokens, start, csec_token_text_at(tokens, start));
        return "  " + resultName + " = load i1, ptr %" + std::string(storage) + "\n";
    }
    const std::string value = resultName + ".i32";
    return csec_emit_i32_expression(tokens, start, end, value) +
        "  " + resultName + " = icmp ne i32 " + value + ", 0\n";
}

static std::string csec_emit_println_statement(const char* tokens, int start, int rawEnd) {
    const int end = csec_i32_expression_end(tokens, start, rawEnd);
    if (!csec_native_token_is(tokens, start, 'I', "println") || !csec_native_token_is(tokens, start + 1, 'O', "(")) return "";
    const int close = csec_find_closing_token(tokens, start + 1, end, "(", ")");
    if (close != end - 1) return "";
    const std::string seed = std::to_string(start);
    if (close == start + 2) return "  call void @csec_print_newline()\n";
    if (csec_is_string_expression(tokens, start + 2, close)) {
        const std::string value = "%println." + seed + ".string";
        return csec_emit_ptr_expression(tokens, start + 2, close, value) +
            "  call void @csec_print_string(ptr " + value + ")\n" +
            "  call void @csec_print_newline()\n";
    }
    const std::string value = "%println." + seed + ".value";
    const std::string wide = "%println." + seed + ".wide";
    return csec_emit_i32_expression(tokens, start + 2, close, value) +
        "  " + wide + " = sext i32 " + value + " to i64\n" +
        "  call void @csec_print_i64(i64 " + wide + ")\n" +
        "  call void @csec_print_newline()\n";
}

static std::string csec_generate_llvm_flat_body_i1(const char* tokens, int bodyStart, int bodyEnd) {
    std::string output;
    for (int cursor = csec_expression_ast_skip_trivia(tokens, bodyStart); cursor >= 0 && cursor < bodyEnd;) {
        const int next = csec_advance_statement(tokens, cursor, bodyEnd);
        if (next <= cursor) break;
        if (csec_native_token_is(tokens, cursor, 'K', "return") && cursor + 1 < next) {
            const std::string value = "%ret." + std::to_string(cursor);
            output += csec_emit_i1_expression(tokens, cursor + 1, next, value);
            output += "  ret i1 " + value + "\n";
            return output;
        }
        if (csec_native_token_is(tokens, cursor, 'K', "if")) {
            const int openParen = csec_find_statement_paren_start(tokens, cursor, next);
            const int closeParen = csec_find_statement_paren_end(tokens, cursor, next);
            const int thenOpen = csec_find_statement_block_start(tokens, cursor, next);
            const int thenClose = thenOpen >= 0 ? csec_find_closing_token(tokens, thenOpen, next, "{", "}") : -1;
            if (openParen >= 0 && closeParen > openParen && thenClose > thenOpen) {
                const std::string seed = std::to_string(cursor);
                output += csec_emit_i1_expression(tokens, openParen + 1, closeParen, "%bool.if." + seed);
                output += "  br i1 %bool.if." + seed + ", label %bool.if.then." + seed + ", label %bool.if.else." + seed + "\n";
                output += "bool.if.then." + seed + ":\n";
                const std::string thenBody = csec_generate_llvm_flat_body_i1(tokens, thenOpen + 1, thenClose);
                output += thenBody;
                const bool thenReturns = thenBody.find("ret i1") != std::string::npos;
                if (!thenReturns) output += "  br label %bool.if.end." + seed + "\n";
                output += "bool.if.else." + seed + ":\n";
                int elseOpen = -1;
                for (int pos = thenClose + 1; pos < next; ++pos) {
                    if (csec_native_token_is(tokens, pos, 'K', "else")) { elseOpen = csec_find_token_text_in_range(tokens, pos + 1, next, "{"); break; }
                }
                const int elseClose = elseOpen >= 0 ? csec_find_closing_token(tokens, elseOpen, next, "{", "}") : -1;
                const std::string elseBody = elseClose > elseOpen ? csec_generate_llvm_flat_body_i1(tokens, elseOpen + 1, elseClose) : "";
                output += elseBody;
                const bool elseReturns = elseBody.find("ret i1") != std::string::npos;
                if (!elseReturns) output += "  br label %bool.if.end." + seed + "\n";
                if (!thenReturns || !elseReturns) output += "bool.if.end." + seed + ":\n";
            }
        } else if ((csec_native_token_is(tokens, cursor, 'K', "val") || csec_native_token_is(tokens, cursor, 'K', "var")) &&
            csec_token_kind_at(tokens, cursor + 1) == 'I') {
            const std::string name = csec_token_text_at(tokens, cursor + 1);
            const std::string storage = name + ".addr." + std::to_string(cursor);
            const int initializer = csec_find_top_level_operator(tokens, cursor, next, 1);
            if (csec_is_i1_array_initializer(tokens, initializer, next)) {
                output += csec_emit_i1_array_local(tokens, cursor, next);
                cursor = csec_expression_ast_skip_trivia(tokens, next);
                continue;
            }
            const bool floating = csec_c_local_type(tokens, cursor, next, initializer) == "Float";
            output += "  %" + storage + " = alloca " + std::string(floating ? "float" : "i1") + "\n";
            if (initializer >= cursor && initializer + 1 < next) {
                const std::string value = "%" + name + ".init." + std::to_string(cursor);
                output += floating ? csec_emit_f32_expression(tokens, initializer + 1, next, value)
                                   : csec_emit_i1_expression(tokens, initializer + 1, next, value);
                output += std::string("  store ") + (floating ? "float " : "i1 ") + value + ", ptr %" + storage + "\n";
            } else output += std::string("  store ") + (floating ? "float 0.000000e+00" : "i1 false") + ", ptr %" + storage + "\n";
        }
        if (csec_token_kind_at(tokens, cursor) == 'I' && csec_native_token_is(tokens, cursor + 1, 'O', "[")) {
            const int close = csec_find_closing_token(tokens, cursor + 1, next, "[", "]");
            if (close > cursor + 1 && csec_native_token_is(tokens, close + 1, 'O', "=") &&
                csec_visible_i1_array(tokens, cursor, csec_token_text_at(tokens, cursor))) {
                const std::string name = csec_token_text_at(tokens, cursor);
                const std::string seed = std::to_string(cursor);
                const std::string storage = csec_lookup_visible_storage_name(tokens, cursor, name.c_str());
                const std::string index = "%" + name + ".index." + seed;
                const std::string data = "%" + name + ".data." + seed;
                const std::string element = "%" + name + ".element." + seed;
                const std::string value = "%" + name + ".rhs." + seed;
                output += csec_emit_i32_expression(tokens, cursor + 2, close, index);
                output += "  " + data + " = load ptr, ptr %" + storage + "\n";
                output += "  " + element + " = getelementptr inbounds i1, ptr " + data + ", i32 " + index + "\n";
                output += csec_emit_i1_expression(tokens, close + 2, next, value);
                output += "  store i1 " + value + ", ptr " + element + "\n";
            }
        } else if (csec_token_kind_at(tokens, cursor) == 'I' && csec_native_token_is(tokens, cursor + 1, 'O', "=")) {
            const std::string name = csec_token_text_at(tokens, cursor);
            const std::string storage = csec_lookup_visible_storage_name(tokens, cursor, name.c_str());
            const std::string value = "%" + name + ".assign." + std::to_string(cursor);
            const bool floating = csec_is_float_local(tokens, cursor, name.c_str()) || csec_is_float_parameter(tokens, cursor, name.c_str());
            output += floating ? csec_emit_f32_expression(tokens, cursor + 2, next, value)
                               : csec_emit_i1_expression(tokens, cursor + 2, next, value);
            output += std::string("  store ") + (floating ? "float " : "i1 ") + value + ", ptr %" + storage + "\n";
        } else if (!csec_emit_println_statement(tokens, cursor, next).empty()) {
            output += csec_emit_println_statement(tokens, cursor, next);
        } else if (csec_token_kind_at(tokens, cursor) == 'I' && cursor + 3 < next &&
                   csec_native_token_is(tokens, cursor + 1, 'O', ".") &&
                   csec_token_kind_at(tokens, cursor + 2) == 'I' &&
                   csec_native_token_is(tokens, cursor + 3, 'O', "(")) {
            output += csec_emit_i32_expression(tokens, cursor, next, "%discard." + std::to_string(cursor));
        }
        cursor = csec_expression_ast_skip_trivia(tokens, next);
    }
    return output;
}
