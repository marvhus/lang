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

Token.[
        // `<-`
        .{kind = SET; offset = 0; length = 2; },
        // `+`
        .{kind = ADD; offset = 3; length = 1; },
        // `-`
        .{kind = SUB; offset = 5; length = 1; },
        // `*`
        .{kind = MUL; offset = 7; length = 1; },
        // `/`
        .{kind = DIV; offset = 9; length = 1; },
        // `=`
        .{kind = EQUAL; offset = 11; length = 1; },
        // `<`
        .{kind = LESS; offset = 13; length = 1; },
        // `<=`
        .{kind = LESS_OR_EQUAL; offset = 15; length = 2; },
        // `>`
        .{kind = GREATER; offset = 18; length = 1; },
        // `>=`
        .{kind = GREATER_OR_EQUAL; offset = 20; length = 2; },
        // `(`
        .{kind = L_PAREN; offset = 23; length = 1; },
        // `)`
        .{kind = R_PAREN; offset = 25; length = 1; },
        // `{`
        .{kind = L_BRACE; offset = 27; length = 1; },
        // `}`
        .{kind = R_BRACE; offset = 29; length = 1; },
        // `hello_w0rld`
        .{kind = IDENT; offset = 31; length = 11; },
        // `123`
        .{kind = INT_LITERAL; offset = 43; length = 3; },
        // ``
        .{kind = EOF; offset = 47; length = 0; },
];
```
