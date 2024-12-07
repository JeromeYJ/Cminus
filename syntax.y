%{

#include "syntax_tree.h"

extern int yylex(void);
extern int line;
extern bool error;
Tree* tree;

void yyerror(char *s);
%}

%union {
	Node *node;
}

/* 优先级设置 */
/* 注意if语句与if-else语句相关的优先级设置 */
%nonassoc <node> IF_STMT
%nonassoc <node> ELSE
%right <node> ASSIGNOP
%left <node> OR
%left <node> AND
%left <node> RELOP
%left <node> PLUS MINUS
%left <node> STAR DIV
%right <node> NOT
%left <node> LP RP LB RB DOT

%token <node> INT
%token <node> FLOAT
%token <node> SEMI
%token <node> COMMA
%token <node> TYPE
%token <node> LC
%token <node> RC
%token <node> STRUCT
%token <node> RETURN
%token <node> IF

%token <node> WHILE
%token <node> ID

%type <node> Program ExtDefList ExtDef ExtDecList 
%type <node> Specifier StructSpecifier OptTag Tag
%type <node> VarDec FunDec VarList ParamDec
%type <node> CompSt StmtList Stmt 
%type <node> DefList Def DecList Dec 
%type <node> Exp Args


%%

Program : 
    ExtDefList {
        $$=createNodeWithChild("Program",$1->line,1,$1);
        tree=newTree();
        tree->root=$$;
    }
    ;
ExtDefList : 
    ExtDef ExtDefList {
        $$=createNodeWithChild("ExtDefList",$1->line,2,$1,$2);
    }
    | /* 空串 */ {
        $$=NULL;
    }
    ;
ExtDef : 
    Specifier ExtDecList SEMI { 
        $$=createNodeWithChild("ExtDef",$1->line,3,$1,$2,$3);
    } 
    | Specifier SEMI {
        $$=createNodeWithChild("ExtDef",$1->line,2,$1,$2);
    }
    | Specifier FunDec CompSt {
        $$=createNodeWithChild("ExtDef",$1->line,3,$1,$2,$3);
    }

ExtDecList : 
    VarDec {
        $$=createNodeWithChild("ExtDecList",$1->line,1,$1);
    }
    | VarDec COMMA ExtDecList {
        $$=createNodeWithChild("ExtDecList",$1->line,3,$1,$2,$3);
    }
    | VarDec error ExtDecList {
        printf("Missing ','.\n");
    }
    ;
Specifier : 
    TYPE { 
        $$=createNodeWithChild("Specifier",$1->line,1,$1);
    }
    | StructSpecifier {
        $$=createNodeWithChild("Specifier",$1->line,1,$1);
    }
    ;
StructSpecifier : 
    STRUCT OptTag LC DefList RC {
        $$=createNodeWithChild("StructSpecifier",$1->line,5,$1,$2,$3,$4,$5);
    }
    | STRUCT Tag {
        $$=createNodeWithChild("StructSpecifier",$1->line,2,$1,$2);
    }
    ;
OptTag : 
    ID {
        $$=createNodeWithChild("OptTag",$1->line,1,$1);
    }
    | /* 空串 */ {
        $$=NULL;
    }
    ;
Tag : 
    ID {
        $$=createNodeWithChild("Tag",$1->line,1,$1);
    }
    ;

VarDec : 
    ID {
        $$=createNodeWithChild("VarDec",$1->line,1,$1);
    }
    | VarDec LB INT RB {
        $$=createNodeWithChild("VarDec",$1->line,4,$1,$2,$3,$4);
    }
    | VarDec LB error RB {
        printf("Array size should be an integer.\n");
    }
    ;
FunDec : 
    ID LP VarList RP {
        $$=createNodeWithChild("FunDec",$1->line,4,$1,$2,$3,$4);
    }
    | ID LP RP {
        $$=createNodeWithChild("FunDec",$1->line,3,$1,$2,$3);
    }
    ;
VarList : 
    ParamDec COMMA VarList {
        $$=createNodeWithChild("VarList",$1->line,3,$1,$2,$3);
    }
    | ParamDec {
        $$=createNodeWithChild("VarList",$1->line,1,$1);
    }
    ;
ParamDec : 
    Specifier VarDec {
        $$=createNodeWithChild("ParamDec",$1->line,2,$1,$2);
    }
    ;

CompSt : 
    LC DefList StmtList RC {
        $$=createNodeWithChild("CompSt",$1->line,4,$1,$2,$3,$4);
    }
    ;
StmtList : 
    Stmt StmtList {
        $$=createNodeWithChild("StmtList",$1->line,2,$1,$2);
    }
    | /* empty */ {
        $$=NULL;
    }
    ;
Stmt : 
    Exp SEMI {
        $$=createNodeWithChild("Stmt",$1->line,2,$1,$2);
    }
    | Exp error SEMI {
        printf("Missing ';'.\n");
    }
    | CompSt {
        $$=createNodeWithChild("Stmt",$1->line,1,$1);
    }
    | RETURN Exp SEMI {
        $$=createNodeWithChild("Stmt",$1->line,3,$1,$2,$3);
    }
    | IF LP Exp RP Stmt ELSE Stmt {
        $$=createNodeWithChild("Stmt",$1->line,7,$1,$2,$3,$4,$5,$6,$7);
    } 
    | IF LP Exp RP Stmt %prec IF_STMT {
        $$=createNodeWithChild("Stmt",$1->line,5,$1,$2,$3,$4,$5);
    }
    | WHILE LP Exp RP Stmt {
        $$=createNodeWithChild("Stmt",$1->line,5,$1,$2,$3,$4,$5);
    }
    ;
DefList : 
    Def DefList {
        $$=createNodeWithChild("DefList",$1->line,2,$1,$2);
    }
    | /* empty */ {
        $$=NULL;
    }
    ;
Def : 
    Specifier DecList SEMI {
        $$=createNodeWithChild("Def",$1->line,3,$1,$2,$3);
    }
    ;
DecList : 
    Dec {
        $$=createNodeWithChild("DecList",$1->line,1,$1);
    }
    | Dec COMMA DecList {
        $$=createNodeWithChild("DecList",$1->line,3,$1,$2,$3);
    }
    ;
Dec : 
    VarDec {
        $$=createNodeWithChild("Dec",$1->line,1,$1);
    }
    | VarDec ASSIGNOP Exp {
        $$=createNodeWithChild("Dec",$1->line,3,$1,$2,$3);
    }
    ;

Exp : 
    Exp ASSIGNOP Exp {
        $$=createNodeWithChild("Exp",$1->line,3,$1,$2,$3);
    }
    | Exp AND Exp {
        $$=createNodeWithChild("Exp",$1->line,3,$1,$2,$3);
    }
    | Exp OR Exp {
        $$=createNodeWithChild("Exp",$1->line,3,$1,$2,$3);
    }
    | Exp RELOP Exp {
        $$=createNodeWithChild("Exp",$1->line,3,$1,$2,$3);
    }
    | Exp PLUS Exp {
        $$=createNodeWithChild("Exp",$1->line,3,$1,$2,$3);
    }
    | Exp MINUS Exp {
        $$=createNodeWithChild("Exp",$1->line,3,$1,$2,$3);
    }
    | Exp STAR Exp {
        $$=createNodeWithChild("Exp",$1->line,3,$1,$2,$3);
    }
    | Exp DIV Exp {
        $$=createNodeWithChild("Exp",$1->line,3,$1,$2,$3);
    }
    | LP Exp RP {
        $$=createNodeWithChild("Exp",$1->line,3,$1,$2,$3);
    }
    | MINUS Exp {
        $$=createNodeWithChild("Exp",$1->line,2,$1,$2);
    }
    | NOT Exp {
        $$=createNodeWithChild("Exp",$1->line,2,$1,$2);
    }
    | ID LP Args RP {
        $$=createNodeWithChild("Exp",$1->line,4,$1,$2,$3,$4);
    }
    | ID LP RP {
        $$=createNodeWithChild("Exp",$1->line,3,$1,$2,$3);
    }
    | Exp LB Exp RB {
        $$=createNodeWithChild("Exp",$1->line,4,$1,$2,$3,$4);
    }
    | Exp LB Exp error SEMI {
        yyerrok;
        printf("Missing ']'.\n");
    }
    | Exp DOT ID {
        $$=createNodeWithChild("Exp",$1->line,3,$1,$2,$3);
    }
    | ID {
        $$=createNodeWithChild("Exp",$1->line,1,$1);
    }
    | INT {
        $$=createNodeWithChild("Exp",$1->line,1,$1);
    }
    | FLOAT {
        $$=createNodeWithChild("Exp",$1->line,1,$1);
    }
    ;
Args : 
    Exp COMMA Args {
        $$=createNodeWithChild("Args",$1->line,3,$1,$2,$3);
    }
    | Exp {
        $$=createNodeWithChild("Args",$1->line,1,$1);
    }
    ;


%%

void yyerror(char *s) {
    error=true;
    printf("Error type B at Line %d: ", line);
}
