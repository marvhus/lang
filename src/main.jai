main :: () {
    test := "1 2 3 b";
    lexer := new_lexer(test);
    token := lex_next_token(*lexer);
    while token.kind != .EOF && token.kind != .ERROR {
        print_token(token);
        print("\n");

        token = lex_next_token(*lexer);
    }

    if token.kind == .ERROR {
        log_error(
            "a:%:%: %\n",
            lexer.line,
            lexer.column,
            token.string_value
        );
    }
}

#import "Basic";

#load "lexer.jai";
