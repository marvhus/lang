CONTENT :: #string DONE
proc main() {
    a :<- 1;
    a <- 2;
    exit(2 / (1 + 2) * 3, 2 * 3 + 1);
}
DONE;

main :: () {
    print("- Input:\n%", CONTENT);

    print("- Tokenizing:\n");
    tokens := tokenize(CONTENT);
    dump(tokens, CONTENT);

    print("- Parsing:\n");
    root := parse(tokens, CONTENT);
    dump(root);
}

#load "lexer.jai";
#load "parser.jai";

#import "Basic";
#import "String";
