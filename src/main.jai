main :: () {
    test := "1 + 2 - 3 * 4 / Hello_Sailor";
    root := parse(test);
    print_ast(root);
    free_ast(root);
}

#import "Basic";

#load "lexer.jai";
#load "parser.jai";
