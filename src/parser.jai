AST_Node :: struct {
    Kind :: enum {
        INVALID :: 0;
        ROOT;
        PROCEDURE;
        BLOCK;
        ASSIGN;
        CALL;
        EXPRESSION;
        VALUE;
    };

    kind: Kind;
    offset: int;
    length: int;
}

AST_Root :: struct {
    using #as base: AST_Node;
    statements: [..]*AST_Node;
}

AST_Procedure :: struct {
    using #as base: AST_Node;
    name: string;
    block: *AST_Block;
}

AST_Block :: struct {
    using #as base: AST_Node;
    statements: [..]*AST_Node;
}

AST_Assign :: struct {
    using #as base: AST_Node;
    name: string;
    define: bool;
    value: *AST_Expression;
}

AST_Call :: struct {
    using #as base: AST_Node;
    name: string;
    parameters: [..]*AST_Expression;
}

AST_Expression :: struct {
    Thing :: enum { // TODO(mvh): Name this better?
        INVALID :: 0;
        VALUE;
    };

    using #as base: AST_Node;
    thing: Thing;
    next: *AST_Node;
}

AST_Value :: struct {
    using #as base: AST_Node;
    number: int;
}

parse :: (tokens: []Token, content: string) -> root_node: *AST_Root {
    parser := Parser.{
        tokens = tokens,
        cursor = 0,
        content = content,
    };
    root := New(AST_Root);
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
      case .IDENTIFIER;
        if peek(parser, 1).kind == {
          case .L_PAREN;
            return true, parse_call(parser);
          case .COLON;
            return true, parse_assign(parser);
          case;
            log_error("Syntax error.  Unexpected token after identifier.\n");
            exit(1);
            return false, null;
        }
      case .EOF;
        return false, null;
      case;
        log_error("Syntax error.  Statement can't begin with %\n", start.kind);
        exit(1);
        return false, null;
    }
}

parse_procedure :: (using parser: *Parser) -> *AST_Procedure {
    procedure := New(AST_Procedure);
    procedure.kind = .PROCEDURE;

    expect(parser, .KEYWORD_PROC);
    { // Procedure name
        name := expect(parser, .IDENTIFIER);
        procedure.name = get_string_slice(name, content);
    }
    expect(parser, .L_PAREN);

    // TODO(mvh): handle parameters

    expect(parser, .R_PAREN);

    // TODO(mvh): handle returns

    { // Procedure block
        if peek(parser).kind != .L_BRACE {
            log_error("Syntax error.  Expected body of procedure to be block.\n");
            exit(1);
        }
        procedure.block = parse_block(parser);
    }

    return procedure;
}

parse_block :: (using parser: *Parser) -> *AST_Block {
    block := New(AST_Block);
    block.kind = .BLOCK;

    expect(parser, .L_BRACE);

    statements: [..]*AST_Node;
    while peek(parser).kind != .R_BRACE {
        success, node := parse_statement(parser, is_root = false);
        if !success {
            log_error("Unexpected end to block.  Got %\n", peek(parser).kind);
            exit(1);
        }
        array_add(*statements, node);
    }
    block.statements = statements;
    expect(parser, .R_BRACE);

    return block;
}

parse_call :: (using parser: *Parser) -> *AST_Call {
    call := New(AST_Call);
    call.kind = .CALL;

    { // Name
        name := expect(parser, .IDENTIFIER);
        call.name = get_string_slice(name, content);
    }
    expect(parser, .L_PAREN);

    // TODO(mvh): Handle more than one parameter
    parameters: [..]*AST_Expression;
    array_add(*parameters, parse_expression(parser));
    call.parameters = parameters;

    expect(parser, .R_PAREN);
    expect(parser, .SEMICOLON);

    return call;
}

parse_assign :: (using parser: *Parser) -> *AST_Assign {
    assign := New(AST_Assign);
    assign.kind = .ASSIGN;

    { // Name
        name := expect(parser, .IDENTIFIER);
        assign.name = get_string_slice(name, content);
    }

    if peek(parser).kind == .COLON {
        assign.define = true;
        next(parser);
        // TODO(mvh): Handle types;
    }

    expect(parser, .EQUAL);

    assign.value = parse_expression(parser);

    expect(parser, .SEMICOLON);

    return assign;
}

// TODO(mvh): Propper expression parsing.
parse_expression :: (using parser: *Parser) -> *AST_Expression {
    expression := New(AST_Expression);
    expression.kind = .EXPRESSION;

    token := peek(parser);
    if token.kind == {
      case .INTEGER_LITERAL;
        expression.thing = .VALUE;
        expression.next = parse_value(parser);
      case;
        log_error("Syntax error.  Unexpected token in expression %\n", token.kind);
        exit(1);
    }

    return expression;
}

// TODO(mvh): Handle more than just number.  Maybe rename AST_Value to AST_Leaf or something like it?
parse_value :: (using parser: *Parser) -> *AST_Value {
    value := New(AST_Value);
    value.kind = .VALUE;

    integer := expect(parser, .INTEGER_LITERAL);
    slice := get_string_slice(integer, content);
    value.number = parse_int(*slice, int);

    return value;
}
