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
    a <- 2;
    exit(1, 2 * 3 + 1);
}
- Tokenizing:
`proc`	{kind = KEYWORD_PROC; offset = 0; length = 4; }
`main`	{kind = IDENTIFIER; offset = 5; length = 4; }
`(`	{kind = L_PAREN; offset = 9; length = 1; }
`)`	{kind = R_PAREN; offset = 10; length = 1; }
`{`	{kind = L_BRACE; offset = 12; length = 1; }
`a`	{kind = IDENTIFIER; offset = 18; length = 1; }
`:`	{kind = COLON; offset = 20; length = 1; }
`<-`	{kind = SET; offset = 21; length = 2; }
`1`	{kind = INTEGER_LITERAL; offset = 24; length = 1; }
`;`	{kind = SEMICOLON; offset = 25; length = 1; }
`a`	{kind = IDENTIFIER; offset = 31; length = 1; }
`<-`	{kind = SET; offset = 33; length = 2; }
`2`	{kind = INTEGER_LITERAL; offset = 36; length = 1; }
`;`	{kind = SEMICOLON; offset = 37; length = 1; }
`exit`	{kind = IDENTIFIER; offset = 43; length = 4; }
`(`	{kind = L_PAREN; offset = 47; length = 1; }
`1`	{kind = INTEGER_LITERAL; offset = 48; length = 1; }
`,`	{kind = COMMA; offset = 49; length = 1; }
`2`	{kind = INTEGER_LITERAL; offset = 51; length = 1; }
`*`	{kind = MUL; offset = 53; length = 1; }
`3`	{kind = INTEGER_LITERAL; offset = 55; length = 1; }
`+`	{kind = ADD; offset = 57; length = 1; }
`1`	{kind = INTEGER_LITERAL; offset = 59; length = 1; }
`)`	{kind = R_PAREN; offset = 60; length = 1; }
`;`	{kind = SEMICOLON; offset = 61; length = 1; }
`}`	{kind = R_BRACE; offset = 63; length = 1; }
``	{kind = EOF; offset = 65; length = 0; }
- Parsing:
proc main()
{
  a: <-
    1
  a <-
    2
  exit(
    1
    ,
    *
      2
      +
        3
        1
  )
}
```
