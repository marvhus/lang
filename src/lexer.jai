Token :: struct {
    Kind :: enum {
        EOF;

        SET;
        ADD;
        SUB;
        MUL;
        DIV;

        EQUAL;
        GREATER;
        GREATER_OR_EQUAL;
        LESS;
        LESS_OR_EQUAL;

        L_PAREN;
        R_PAREN;

        L_BRACE;
        R_BRACE;

        IDENT;
        INT_LITERAL;
    }

    kind:   Kind;
    offset: int;
    length: int;
}

tokenize :: (text: string) -> [..]Token {
    lexer := Lexer.{
        content = text,
        cursor  = 0,
    };

    tokens: [..]Token;
    while true {
        tok := next_token(*lexer);
        array_add(*tokens, tok);

        if tok.kind == .EOF then break;
    }

    return tokens;
}

dump :: (tokens: []Token) {
    push_context,defer_pop;
    context.print_style.default_format_struct.use_long_form_if_more_than_this_many_members = -1;

    print("Token.[\n");
    for tok: tokenize(content) {
        slice := string.{
            data  = content.data + tok.offset,
            count = tok.length,
        };

        print("\t// `%`\n", slice);
        print("\t.%,\n", tok);
    }
    print("];\n");
}

#scope_file

Lexer :: struct {
    content: string;
    cursor: int;
}

peek :: (using lexer: Lexer, offset: int = 0) -> u8 {
    if content.count - 1 - cursor < offset {
        return 0;
    }
    return content[cursor + offset];
}
next :: (using lexer: *Lexer, offset: int = 1) -> u8 {
    if content.count - cursor < offset{
        return 0;
    }

    val := peek(lexer, offset);
    cursor += offset;
    return val;
}

next_token :: (lexer: *Lexer) -> Token {
    make_token :: (lexer: *Lexer, kind: Token.Kind, length: int) -> Token {
        start := lexer.cursor;
        next(lexer, length);
        return Token.{
            kind   = kind,
            offset  = start,
            length = length,
        };
    }

    while true { // Skip whitespace
        char := peek(lexer);
        if char >  #char " " || char == 0 then break;

        next(lexer);
    }

    char := peek(lexer);

    if char == 0 then return Token.{ // Check EOF
        kind = .EOF,
        offset = lexer.cursor,
        length = 0,
    };

    if char == { // Symbols
        case #char "+"; return make_token(lexer, .ADD,     1);
        case #char "-"; return make_token(lexer, .SUB,     1);
        case #char "*"; return make_token(lexer, .MUL,     1);
        case #char "/"; return make_token(lexer, .DIV,     1);
        case #char "("; return make_token(lexer, .L_PAREN, 1);
        case #char ")"; return make_token(lexer, .R_PAREN, 1);
        case #char "{"; return make_token(lexer, .L_BRACE, 1);
        case #char "}"; return make_token(lexer, .R_BRACE, 1);
        case #char "="; return make_token(lexer, .EQUAL,   1);
        case #char ">"; if peek(lexer, 1) == {
            case #char "="; return make_token(lexer, .GREATER_OR_EQUAL, 2);
            case;           return make_token(lexer, .GREATER,          1);
        }
        case #char "<"; if peek(lexer, 1) == {
            case #char "-"; return make_token(lexer, .SET,           2);
            case #char "="; return make_token(lexer, .LESS_OR_EQUAL, 2);
            case;           return make_token(lexer, .LESS,          1);
        }
    }

    if char >= #char "0" && char <= #char "9" { // Integer literals
        start := lexer.cursor;
        while true {
            char := next(lexer);
            if char < #char "0" || char > #char "9" {
                break;
            }
        }
        return Token.{
            kind   = .INT_LITERAL,
            offset  = start,
            length = lexer.cursor - start,
        };
    }

    if (char >= #char "a" && char <= #char "z")
    || (char >= #char "A" && char <= #char "Z")
    || (char == #char "_") { // Idents
        start := lexer.cursor;
        while true {
            char := next(lexer);
            if (char >= #char "a" && char <= #char "z")
            || (char >= #char "A" && char <= #char "Z")
            || (char >= #char "0" && char <= #char "9")
            || (char == #char "_") {
                continue;
            }
            break;
        }
        return Token.{
            kind   = .IDENT,
            offset  = start,
            length = lexer.cursor - start,
        };
    }

    print("Unknown token at % with char %\n", lexer.cursor, peek(lexer));
    exit(1);
    return Token.{kind = .EOF};
}
