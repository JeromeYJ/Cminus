%{

#include "syntax_tree.h"
#include "syntax.tab.h"

int line;
extern bool error;
void createTokenNode(const char* token, char *text){
    yylval.node = newNode(token, line, yytext, true);
}
%}

%%

[0-9]|[1-9][0-9]+ {createTokenNode("INT",yytext); return INT;}
0([0-7]|[1-7][0-7]+) {createTokenNode("INT",yytext); return INT;}
0x([0-9a-fA-F]|[1-9a-fA-F][0-9a-fA-F]+) {createTokenNode("INT",yytext); return INT;}
([0-9]|[1-9][0-9]+)\.[0-9]+  {createTokenNode("FLOAT",yytext); return FLOAT;}
[0-9]*\.[0-9]*[eE][+-]?[0-9]+ {createTokenNode("FLOAT",yytext); return FLOAT;}
0([0-7]|[1-7][0-7]+)?[8-9]+[0-7]* {
    error=true; 
    printf("Error type A at line %d: Illegal octal number \'%s\'\n", line, yytext);
}
0x([0-9a-fA-F]|[1-9a-fA-F][0-9a-fA-F]+)?[g-zG-Z]+[0-9a-fA-F]* {
    error=true; 
    printf("Error type A at line %d: Illegal hexadecimal number \'%s\'\n", line, yytext);
}
[0-9]*\.[0-9]*[eE][+-]? {
    error=true; 
    printf("Error type A at line %d: Illegal floating point number \'%s\'\n", line, yytext);
}

"//" {
    char c=input(); 
    while(c!='\n')
        c=input();
}

\/\*\/*([^\/]*[^\/\*]\/[\/]*)*[^\/]*\*\/ {
    for(int i=2;yytext[i]!='*' || yytext[i+1]!='/';i++)
    {  			
        if(yytext[i]=='\n')
            line++;
    }
}

";" {createTokenNode("SEMI",yytext); return SEMI;}
"," {createTokenNode("COMMA",yytext); return COMMA;}
"=" {createTokenNode("ASSIGNOP",yytext); return ASSIGNOP;}
">"|"<"|">="|"<="|"=="|"!=" {createTokenNode("RELOP",yytext); return RELOP;}
"+" {createTokenNode("PLUS",yytext); return PLUS;}
"-" {createTokenNode("MINUS",yytext); return MINUS;}
"*" {createTokenNode("STAR",yytext); return STAR;}
"/" {createTokenNode("DIV",yytext); return DIV;}
"&&" {createTokenNode("AND",yytext); return AND;}
"||" {createTokenNode("OR",yytext); return OR;}
"." {createTokenNode("DOT",yytext); return DOT;}
"!" {createTokenNode("NOT",yytext); return NOT;}
"int"|"float" {createTokenNode("TYPE",yytext); return TYPE;}
"(" {createTokenNode("LP",yytext); return LP;}
")" {createTokenNode("RP",yytext); return RP;}
"[" {createTokenNode("LB",yytext); return LB;}
"]" {createTokenNode("RB",yytext); return RB;}
"{" {createTokenNode("LC",yytext); return LC;}
"}" {createTokenNode("RC",yytext); return RC;}
"struct" {createTokenNode("STRUCT",yytext); return STRUCT;}
"return" {createTokenNode("RETURN",yytext); return RETURN;}
"if" {createTokenNode("IF",yytext); return IF;}
"else" {createTokenNode("ELSE",yytext); return ELSE;}
"while" {createTokenNode("WHILE",yytext); return WHILE;}
[_a-zA-Z][_a-zA-Z0-9]* {createTokenNode("ID",yytext); return ID;}
\n {line++;}
[ \f\v\s\t\r] {}
. {
    error=true; 
    printf("Error type A at line %d: Mysterious characters \'%s\'.\n", line, yytext);
}

%%

