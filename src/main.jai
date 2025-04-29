content :: #string DONE
<- + - * /
= < <= > >=
( ) { }
hello_w0rld 123
DONE;

main :: () {
    print("Lexing:\n%\n", content);

    lexer: Lexer;
    init(*lexer, content);

    while true {
        tok := next_token(*lexer);
        print("Token: %  `%`\n", tok, string.{data = lexer.content.data + tok.start, count = tok.length});
        if tok.kind == .EOF break;
    }
}

#load "lexer.jai";

#import "Basic";
