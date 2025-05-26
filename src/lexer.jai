Token :: struct {
    Kind :: enum {
        ERROR :: 0;
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
        token := next_token(*lexer);
        if token.kind == .ERROR {
            char := peek(lexer, -1);
            str := ifx char <= #char " "
                then tprint("ascii: %", char)
                else u8.[char].(string);
            log_error("Unexpected character: %\n", str);
            exit(1);
        }

        array_add(*tokens, token);

        if token.kind == .EOF then break;
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
    if content.count - cursor <= offset then return 0;
    return content[cursor + offset];
}

next :: (using lexer: *Lexer, offset: int = 0) -> u8 {
    val := peek(lexer, offset);
    if val == 0 then return 0;

    cursor += offset + 1;
    return val;
}

make_token :: (lexer: *Lexer, kind: Token.Kind, length: int) -> Token {
    start := lexer.cursor - 1;
    if length > 1 then next(lexer, length - 1);
    return Token.{
        kind   = kind,
        offset  = start,
        length = length,
    };
}

skip_whitespace :: (lexer: *Lexer) {
    while true {
        char := peek(lexer);
        if char > #char " " || char == 0 then break;
        next(lexer);
    }
}

is_numeric :: inline (char: u8) -> bool {
    return char >= #char "0"
        && char <= #char "9";
}

is_alphabetic :: inline (char: u8) -> bool {
    upercase_mask :: ~(1 << 5);
    upercase_char := char & upercase_mask;
    return upercase_char >= #char "A"
        && upercase_char <= #char "Z";
}

is_ident :: inline (char: u8) -> bool {
    return char == #char "_"
        || is_numeric(char)
        || is_alphabetic(char);
}

next_token :: (lexer: *Lexer) -> Token {
    skip_whitespace(lexer);

    char := next(lexer);

    if char == {
        case 0;   return make_token(lexer, .EOF,       0);
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
        case ">"; if peek(lexer) == {
            case "="; return make_token(lexer, .GREATER_OR_EQUAL, 2);
            case;     return make_token(lexer, .GREATER,          1);
        }
        case "<"; if peek(lexer) == {
            case "-"; return make_token(lexer, .SET,           2);
            case "="; return make_token(lexer, .LESS_OR_EQUAL, 2);
            case;     return make_token(lexer, .LESS,          1);
        }
    }

    if is_numeric(char) {
        start := lexer.cursor - 1;
        while true {
            char := peek(lexer);
            if !is_numeric(char) then break;
            next(lexer);
        }

        return Token.{
            kind   = .INTEGER_LITERAL,
            offset = start,
            length = lexer.cursor - start,
        };
    }

    if is_ident(char) {
        start := lexer.cursor - 1;
        while true {
            char := peek(lexer);
            if !is_ident(char) then break;
            next(lexer);
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
        start := lexer.cursor - 1;
        while true {
            char := peek(lexer);
            if char == "\"" then break;
            next(lexer);
        }

        return Token.{
            kind   = .STRING_LITERAL,
            offset = start + 1,
            length = lexer.cursor - start - 2,
        };
    }

    return Token.{kind = .ERROR};
}
