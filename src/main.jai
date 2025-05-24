CONTENT :: #string DONE
<- + - * /
= < <= > >=
( ) { }
hello_w0rld 123
"hello world"
: ;
proc
DONE;

main :: () {
    tokens := tokenize(CONTENT);
    dump(tokens, CONTENT);
}

#load "lexer.jai";

#import "Basic";
