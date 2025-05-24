AST_Node :: struct {
    Kind :: enum {
        INVALID :: 0;
        ROOT;
        PROCEDURE;
        BLOCK;
        ASSIGN;
        CALL;
        EXPRESSION;
    };

    kind: Kind;
    offset: int;
    length: int;
}

AST_Root_Node :: struct {
    using #as base: AST_Node;
    statements: [..]*AST_Node;
}

AST_Procedure_Node :: struct {
    using #as base: AST_Node;
    name: string;
    block: *AST_Block_Node;
}

AST_Block_Node :: struct {
    using #as base: AST_Node;
    statements: [..]*AST_Node;
}

AST_Assign_Node :: struct {
    using #as base: AST_Node;
    name: string;
    value: *AST_Expression_Node;
}

AST_Call_Node :: struct {
    using #as base: AST_Node;
    name: string;
    parameters: [..]*AST_Expression_Node;
}

AST_Expression_Node :: struct {
    Thing :: enum { // TODO(mvh): Name this better?
        INVALID :: 0;
        VALUE;
    };

    using #as base: AST_Node;
    thing: Thing;
    next: *AST_Node;
}

AST_Value_Node :: struct {
    using #as base: AST_Node;
    number: int;
}

parse :: (tokens: []Token, content: string) -> root_node: *AST_Root_Node {
    parser := Parser.{
        tokens = tokens,
        cursor = 0,
        content = content,
    };
    root := New(AST_Root_Node);
    root.kind = .ROOT;

    statements: [..]*AST_Node;
    while true {
        success, node := parse_statement(*parser, is_root = true);
        if !success break;
        array_add(*statements, node);
    }
    root.statements = statements;

    return root;
}

#scope_file

Parser :: struct {
    tokens: []Token;
    cursor: int;
    content: string;
}

peek :: (using parser: Parser, offset: int = 0) -> Token {
    if tokens.count - 1 - cursor < offset {
        return ZERO_TOKEN;
    }
    return tokens[cursor + offset];
}
next :: (using parser: *Parser, offset: int = 1) -> Token {
    if tokens.count - cursor < offset {
        return ZERO_TOKEN;
    }

    token := peek(parser, offset);
    cursor += offset;
    return token;
}

expect :: (using parser: *Parser, kind: Token.Kind) -> Token {
    token := peek(parser);
    if token.kind != kind {
        log_error("Invalid token.  Expected % but got %\n", kind, token.kind);
        exit(1);
    }
    next(parser);
    return token;
}

parse_statement :: (using parser: *Parser, is_root: bool) -> success: bool, node: *AST_Node {
    start := peek(parser);
    if start.kind == {
      case .KEYWORD_PROC;
        return true, parse_procedure(parser);
      case .EOF;
        return false, null;
      case;
        log_error("Syntax error.  Statement can't begin with %\n", start.kind);
        exit(1);
        return false, null;
    }
}

parse_procedure :: (using parser: *Parser) -> *AST_Procedure_Node {
    expect(parser, .KEYWORD_PROC);
    name := expect(parser, .IDENTIFIER);
    expect(parser, .L_PAREN);

    // TODO(mvh): handle parameters

    expect(parser, .R_PAREN);

    // TODO(mvh): handle returns

    expect(parser, .L_BRACE);

    // TODO(mvh): parse statements in procedure
    while next(parser).kind != .R_BRACE {}

    expect(parser, .R_BRACE);


    procedure := New(AST_Procedure_Node);
    procedure.kind = .PROCEDURE;
    procedure.name = string.{data = content.data + name.offset, count = name.length};

    return procedure;
}