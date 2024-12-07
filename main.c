#include <stdio.h>
#include <stdlib.h>
#include "syntax_tree.h"

extern FILE* yyin;
extern int line;
extern Tree* tree;

bool error=false;


int main(int argc, char *argv[]) {
    if(argc < 2) return 1;
    FILE *yyin = fopen(argv[1], "r");
    if(!yyin) {
        perror(argv[1]);
        return 1;
    }
    yyrestart(yyin);
    line = 1;
    yyparse();
    if(!error)
        printTree(tree);
    return 0;
}

