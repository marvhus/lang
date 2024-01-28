#scope_export

AST_Node_Kind :: enum {
    BINARY_OPERATOR;
    LEAF_NUMBER;
}

AST_Node :: struct {
    kind: AST_Node_Kind;
    using value: union {
        number_value: u64;
        char_value: u8;
    } = ---;

    left, right: *AST_Node = null;
}

free_ast :: (using node: *AST_Node) {
    if node == null return;
    if left then free_ast(left);
    if right then free_ast(right);
    free(node);
}

print_ast :: (using node: *AST_Node, indent: s64 = 0) {
    indent_spaces :: (indent: s64) {
        for 0..indent-1 print(" ");
    }
    indent_spaces(indent);
    print_node(node);
    print("\n");
    if left then print_ast(left, indent + 1);
    if right then print_ast(right, indent + 1);
}
print_node :: (using node: *AST_Node) {
    print("%", kind);
    if kind == {
        case .BINARY_OPERATOR; print(": %", cast(string) u8.[char_value]);
        case .LEAF_NUMBER; print(": %", number_value);
    }
}

parse :: (content: string) -> *AST_Node {
    lexer := new_lexer(content);
    return parse_expression(*lexer);
}

#scope_file

new_ast_node :: (kind: AST_Node_Kind) -> *AST_Node {
    node: *AST_Node = alloc(size_of(AST_Node));
    node.kind = kind;
    return node;
}

new_leaf_number :: (value: u64) -> *AST_Node {
    node := new_ast_node(.LEAF_NUMBER);
    node.number_value = value;
    return node;
}

new_binary :: (left: *AST_Node, op: u8, right: *AST_Node) -> *AST_Node {
    node := new_ast_node(.BINARY_OPERATOR);
    node.char_value = op;
    node.left = left;
    node.right = right;
    return node;
}

parse_leaf :: (lexer: *Lexer) -> *AST_Node {
    next := lex_next_token(lexer);
    if next.kind == {
        case .NUMBER; return new_leaf_number(next.number_value);
    }
    return null;
}

parse_expression :: (lexer: *Lexer) -> *AST_Node {
    left := parse_leaf(lexer);
    next := lex_next_token(lexer);
    if next.kind == {
        case .OPERATOR; return new_binary(left, next.char_value, parse_expression(lexer));
    }
    return left;
}
