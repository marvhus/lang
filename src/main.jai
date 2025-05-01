content :: #string DONE
<- + - * /
= < <= > >=
( ) { }
hello_w0rld 123
DONE;

main :: () {
    print("Lexing:\n%\n", content);

    tokens := tokenize(content);
    dump(tokens);
}

#load "lexer.jai";

#import "Basic";
