#scope_export

Token_Kind :: enum {
    NUMBER;
    OPERATOR;
    IDENT;
    EOF;
    ERROR;
}

Token :: struct {
    kind: Token_Kind;
    using value: union {
        string_value: string;
        // @NOTE: figuring out if the number is negative is figured out at a later stage
        number_value: u64; 
        char_value:   u8;
    } = ---;
}

Lexer :: struct {
    content: string;
    column:  s64;
    line:    s64;
    idx:     s64;
}

new_lexer :: (content: string) -> Lexer {
    return .{
        content = content,
        column = 0,
        line = 1,
        idx = 0,
    };
}

lex_next_token :: (using lexer: *Lexer) -> Token {
    if content.count - idx == 0 return .{kind = .EOF};
    eat_spaces(lexer);
    if content.count - idx == 0 return .{kind = .EOF};

    chr := content[idx];

    if is_digit(chr) {
        return lex_number(lexer);
    }
    if is_operator(chr) {
        advance_lexer(lexer);
        return .{kind = .OPERATOR, char_value = chr};
    }
    if is_ident_start(chr) {
        return lex_ident(lexer);
    }

    return .{kind = .ERROR, string_value = sprint("Unknown token: %", cast(string) u8.[chr])};
}

print_token :: (using token: Token) {
    print("%", kind);
    if kind == {
        case .NUMBER; print(": %", string_value);
        case .OPERATOR; print(": %", cast(string) u8.[char_value]);
    }
}

#scope_file

is_space :: (chr: u8) -> bool {
    return chr == #char " "
        || chr == #char "\n"
        || chr == #char "\t"
        || chr == #char "\r";
}

is_operator :: (chr: u8) -> bool {
    return chr == #char "+"
        || chr == #char "-"
        || chr == #char "/"
        || chr == #char "*";
}

is_digit :: (chr: u8) -> bool {
    return (chr >= #char "0")
        && (chr <= #char "9");
}

is_ident_start :: (chr: u8) -> bool {
    return ((chr >= #char "a") && (chr <= #char "z"))
        || ((chr >= #char "A") && (chr <= #char "Z"));
}

is_ident :: (chr: u8) -> bool {
    return is_ident_start(chr)
        || is_digit(chr)
        || chr == #char "_";
}

advance_lexer :: (using lexer: *Lexer) {
    idx += 1;
    column += 1;
}

eat_spaces :: (using lexer: *Lexer) {
    while content.count - idx > 0 {
        chr := content[idx];
        if !is_space(chr) break;

        advance_lexer(lexer);

        // Unix LN newline
        if chr == #char "\n" {
            column = 0;
            line += 1;
        }
        // DOS CRLN newline
        else if  chr == #char "\r" && content[idx] == #char "\n" {
            if content.count - idx > 0 then idx += 1;
            column = 0;
            line += 1;
        }
    }
}

lex_number :: (using lexer: *Lexer) -> Token {
    token := Token.{kind = .NUMBER};
    builder: String_Builder;
    init_string_builder(*builder);
    
    while content.count - idx > 0 {
        chr := content[idx];
        if !is_digit(chr) break;

        append(*builder, chr);
        
        advance_lexer(lexer);
    }

    number_text := builder_to_string(*builder);
    number, success := string_to_int(number_text, 10, u64);
    assert(success, "Something has gone terribly wrong!");

    token.number_value = number;
    return token;
}

lex_ident :: (using lexer: *Lexer) -> Token {
    token := Token.{kind = .IDENT};
    builder: String_Builder;
    init_string_builder(*builder);

    while content.count - idx > 0 {
        chr := content[idx];
        if !is_ident(chr) break;

        append(*builder, chr);

        advance_lexer(lexer);
    }

    token.string_value = builder_to_string(*builder);
    return token;
}
