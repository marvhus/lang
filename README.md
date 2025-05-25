# lang

## Building an running
(You will need access to the Jai compiler to build this.)
```console
$ jai -version
Version: beta 0.2.014, built on 24 May 2025.

$ jai first.jai
...

$ bin/lang
- Input:
proc main() {
    a :<- 1;
    b :<- 2;
    exit(1, 2 * 3 + 1);
}
- Tokenizing:
Token.[
	// `proc`
	.{kind = KEYWORD_PROC; offset = 0; length = 4; },
	// `main`
	.{kind = IDENTIFIER; offset = 5; length = 4; },
	// `(`
	.{kind = L_PAREN; offset = 9; length = 1; },
	// `)`
	.{kind = R_PAREN; offset = 10; length = 1; },
	// `{`
	.{kind = L_BRACE; offset = 12; length = 1; },
	// `a`
	.{kind = IDENTIFIER; offset = 18; length = 1; },
	// `:`
	.{kind = COLON; offset = 20; length = 1; },
	// `<-`
	.{kind = SET; offset = 21; length = 2; },
	// `1`
	.{kind = INTEGER_LITERAL; offset = 24; length = 1; },
	// `;`
	.{kind = SEMICOLON; offset = 25; length = 1; },
	// `b`
	.{kind = IDENTIFIER; offset = 31; length = 1; },
	// `:`
	.{kind = COLON; offset = 33; length = 1; },
	// `<-`
	.{kind = SET; offset = 34; length = 2; },
	// `2`
	.{kind = INTEGER_LITERAL; offset = 37; length = 1; },
	// `;`
	.{kind = SEMICOLON; offset = 38; length = 1; },
	// `exit`
	.{kind = IDENTIFIER; offset = 44; length = 4; },
	// `(`
	.{kind = L_PAREN; offset = 48; length = 1; },
	// `1`
	.{kind = INTEGER_LITERAL; offset = 49; length = 1; },
	// `,`
	.{kind = COMMA; offset = 50; length = 1; },
	// `2`
	.{kind = INTEGER_LITERAL; offset = 52; length = 1; },
	// `*`
	.{kind = MUL; offset = 54; length = 1; },
	// `3`
	.{kind = INTEGER_LITERAL; offset = 56; length = 1; },
	// `+`
	.{kind = ADD; offset = 58; length = 1; },
	// `1`
	.{kind = INTEGER_LITERAL; offset = 60; length = 1; },
	// `)`
	.{kind = R_PAREN; offset = 61; length = 1; },
	// `;`
	.{kind = SEMICOLON; offset = 62; length = 1; },
	// `}`
	.{kind = R_BRACE; offset = 64; length = 1; },
	// ``
	.{kind = EOF; offset = 66; length = 0; },
];
- Parsing:
root ROOT
  statement PROCEDURE
    procedure `main`
      statement ASSIGN
        assign `a` (define true)
      statement ASSIGN
        assign `b` (define true)
      statement CALL
        call `exit`
          parameter `LEAF`
            leaf `1`
          parameter `BINOP`
            operation `MUL`
```
