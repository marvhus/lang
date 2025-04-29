# lang

## Building an running
(You will need access to the Jai compiler to build this.)
```console
$ jai -version
Version: beta 0.2.010, built on 4 March 2025.

$ jai first.jai
...

$ bin/lang
Lexing:
<- + - * /
= < <= > >=
( ) { }
hello_w0rld 123

Token: {SET, 0, 2}  `<-`
Token: {ADD, 3, 1}  `+`
Token: {SUB, 5, 1}  `-`
Token: {MUL, 7, 1}  `*`
Token: {DIV, 9, 1}  `/`
Token: {EQUAL, 11, 1}  `=`
Token: {LESS, 13, 1}  `<`
Token: {LESS_OR_EQUAL, 15, 2}  `<=`
Token: {GREATER, 18, 1}  `>`
Token: {GREATER_OR_EQUAL, 20, 2}  `>=`
Token: {L_PAREN, 23, 1}  `(`
Token: {R_PAREN, 25, 1}  `)`
Token: {L_BRACE, 27, 1}  `{`
Token: {R_BRACE, 29, 1}  `}`
Token: {IDENT, 31, 11}  `hello_w0rld`
Token: {INT_LITERAL, 43, 3}  `123`
Token: {EOF, 47, 0}  ``
```
