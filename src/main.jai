CONTENT :: #string DONE
proc main() {
    a := 1;
    b := 2;
    exit(1);
}
DONE;

main :: () {
    tokens := tokenize(CONTENT);
    root := parse(tokens, CONTENT);
    print("root %\n", root.kind);
    for root.(*AST_Root).statements {
        print("  statement %\n", it.kind);
        if it.kind == {
          case .PROCEDURE;
            proc := it.(*AST_Procedure);
            print("    procedure `%`\n", proc.name);
            if proc.block for proc.block.(*AST_Block).statements {
                print("      statement %\n", it.kind);
                if it.kind == {
                  case .ASSIGN;
                    assign := it.(*AST_Assign);
                    print("        assign `%` (define %)\n", assign.name, assign.define);
                  case .CALL;
                    call := it.(*AST_Call);
                    print("        call `%`\n", call.name);
                }
            }
        }
    }
}

#load "lexer.jai";
#load "parser.jai";

#import "Basic";
#import "String";
