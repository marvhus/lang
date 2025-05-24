CONTENT :: #string DONE
proc main() {
    a := 1;
    b := 2;
    exit(a + b);
}
DONE;

main :: () {
    tokens := tokenize(CONTENT);
    root := parse(tokens, CONTENT);
    print("root %\n", root.kind);
    for root.(*AST_Root_Node).statements {
        print("  statement %\n", it.kind);
        if it.kind == {
          case .PROCEDURE;
            print("    procedure `%`\n", it.(*AST_Procedure_Node).name);
        }
    }
}

#load "lexer.jai";
#load "parser.jai";

#import "Basic";
