Token :: struct {
    Kind :: enum {
        EOF :: 0;

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

        COLON;
        SEMICOLON;
        COMMA;
        PERIOD;

        L_PAREN;
        R_PAREN;

        L_BRACE;
        R_BRACE;

        IDENTIFIER;
        INTEGER_LITERAL;
        STRING_LITERAL;

        KEYWORD_PROC;
    }

    kind:   Kind;
    offset: int;
    length: int;
}
ZERO_TOKEN :: Token.{};

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

// TODO(mvh): Handle the content other than passing it to the function. Maybe eventually when we need to
//            handle more files, we should use whatever mechanism that then handles the multiple files.
dump :: (tokens: []Token, content: string) {
    push_context,defer_pop;
    context.print_style.default_format_struct.use_long_form_if_more_than_this_many_members = -1;

    for tok: tokens {
        slice := string.{
            data  = content.data + tok.offset,
            count = tok.length,
        };

        print("`%`\t", slice);
        print("%\n", tok);
    }
}

get_string_slice :: (token: Token, content: string) -> string {
    return string.{
        data  = content.data + token.offset,
        count = token.length,
    };
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
        if char > " " || char == 0 then break;

        next(lexer);
    }

    char := peek(lexer);

    if char == 0 then return Token.{ // Check EOF
        kind = .EOF,
        offset = lexer.cursor,
        length = 0,
    };

    if char == { // Symbols
        case "+"; return make_token(lexer, .ADD,       1);
        case "-"; return make_token(lexer, .SUB,       1);
        case "*"; return make_token(lexer, .MUL,       1);
        case "/"; return make_token(lexer, .DIV,       1);
        case ":"; return make_token(lexer, .COLON,     1);
        case ";"; return make_token(lexer, .SEMICOLON, 1);
        case ","; return make_token(lexer, .COMMA,     1);
        case "."; return make_token(lexer, .PERIOD,    1);
        case "("; return make_token(lexer, .L_PAREN,   1);
        case ")"; return make_token(lexer, .R_PAREN,   1);
        case "{"; return make_token(lexer, .L_BRACE,   1);
        case "}"; return make_token(lexer, .R_BRACE,   1);
        case "="; return make_token(lexer, .EQUAL,     1);
        case ">"; if peek(lexer, 1) == {
            case "="; return make_token(lexer, .GREATER_OR_EQUAL, 2);
            case;           return make_token(lexer, .GREATER,          1);
        }
        case "<"; if peek(lexer, 1) == {
            case "-"; return make_token(lexer, .SET,           2);
            case "="; return make_token(lexer, .LESS_OR_EQUAL, 2);
            case;           return make_token(lexer, .LESS,          1);
        }
    }

    if char >= "0" && char <= "9" { // Integer literals
        start := lexer.cursor;
        while true {
            char := next(lexer);
            if char < "0" || char > "9" {
                break;
            }
        }
        return Token.{
            kind   = .INTEGER_LITERAL,
            offset  = start,
            length = lexer.cursor - start,
        };
    }

    if (char >= "a" && char <= "z")
    || (char >= "A" && char <= "Z")
    || (char == "_") { // Idents
        start := lexer.cursor;
        while true {
            char := next(lexer);
            if (char >= "a" && char <= "z")
            || (char >= "A" && char <= "Z")
            || (char >= "0" && char <= "9")
            || (char == "_") {
                continue;
            }
            break;
        }

        slice := string.{
            data  = lexer.content.data + start,
            count = lexer.cursor - start,
        };
        kind := Token.Kind.IDENTIFIER;

        if slice == {
          case "proc"; kind = .KEYWORD_PROC;
        }

        return Token.{
            kind   = kind,
            offset = start,
            length = slice.count,
        };
    }

    if char == "\"" { // String
        start := lexer.cursor;
        while true {
            char := next(lexer);
            if char == "\"" {
                break;
            }
        }
        next(lexer);

        return Token.{
            kind   = .STRING_LITERAL,
            offset = start + 1,
            length = lexer.cursor - start - 2,
        };
    }

    print("Unknown token at % with char %\n", lexer.cursor, peek(lexer));
    exit(1);
    return Token.{kind = .EOF};
}
