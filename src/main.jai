CONTENT :: #string DONE
proc main() {
    a :<- 1;
    b :<- 2;
    exit(1, 2 * 3 + 1);
}
DONE;

main :: () {
    print("- Input:\n%", CONTENT);

    print("- Tokenizing:\n");
    tokens := tokenize(CONTENT);
    dump(tokens, CONTENT);

    print("- Parsing:\n");
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
                    for call.parameters {
                        print("          parameter `%`\n", it.kind);
                        if it.kind == {
                          case .BINOP;
                            binop := it.(*AST_Binop);
                            print("            operation `%`\n", binop.operation);
                          case .LEAF;
                            leaf := it.(*AST_Leaf);
                            print("            leaf `%`\n", leaf.number);
                        }
                    }
                }
            }
        }
    }
}

#load "lexer.jai";
#load "parser.jai";

#import "Basic";
#import "String";
