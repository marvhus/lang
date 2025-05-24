# lang

## Building an running
(You will need access to the Jai compiler to build this.)
```console
$ jai -version
Version: beta 0.2.010, built on 4 March 2025.

$ jai first.jai
...

$ bin/lang
root ROOT
  statement PROCEDURE
    procedure `main`
      statement ASSIGN
        assign `a` (define true)
      statement ASSIGN
        assign `b` (define true)
      statement CALL
        call `exit`
```
