main:   lex.l syntax.y syntax_tree.c main.c
	bison -d -v syntax.y
	flex lex.l
	gcc -w syntax_tree.c main.c syntax.tab.c lex.yy.c -lfl -o main

clean:
	-rm -f main lex.yy.c *.tab.*
