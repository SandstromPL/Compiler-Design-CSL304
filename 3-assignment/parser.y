%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "symbol.h" 

void yyerror(const char *s);
int yylex(void);
extern int yylineno;

int temp_count = 0;
int label_count = 0;
char* new_temp();
char* new_label();
void check_scope(char* id);
%}

%union {
    char* str;
}

%token <str> INT DOUBLE BOOL STRING VOID 
%token <str> IDENTIFIER HEXA_CONST INT_CONST DOUBLE_CONST STR_CONST TRUE_CONST FALSE_CONST

%token CLASS IF ELSE WHILE FOR DO BREAK RETURN
%token NEWARRAY NEW MAIN
%token ASSIGN EQ NEQ LT LE GT GE AND OR NOT
%token PLUS MINUS MUL DIV MOD
%token L_RND_BRC R_RND_BRC L_CURL_BRC R_CURL_BRC L_SQR_BRC R_SQR_BRC SEMICOLON COMMA DOT

%type <str> Type Expr LValue Constant ExprOpt ExprFor M Call
%type <str> IfHead 

%nonassoc LOWER_THAN_ELSE
%nonassoc ELSE
%right ASSIGN
%left OR
%left AND
%nonassoc EQ NEQ
%nonassoc LT LE GT GE
%left PLUS MINUS
%left MUL DIV MOD
%right NOT UMINUS
%left DOT L_SQR_BRC L_RND_BRC 

%start Program

%%

M: /* empty */ { 
    $$ = new_label(); 
    printf("%s:\n", $$); 
} ;

Program:
    DeclList MainFunc
    ;

DeclList:
    /* empty */
    | DeclList Decl
    ;

Decl:
    VarDecl
    | FuncDecl
    | ClassDecl
    ;

VarDecl:
    Type IDENTIFIER SEMICOLON {
        insertSymbol($2, $1, 0);
    }
    | IDENTIFIER NEWARRAY L_RND_BRC INT_CONST COMMA Type R_RND_BRC SEMICOLON {
        insertSymbol($1, "Array", 0); 
        printf("%s = newArray(%s, %s)\n", $1, $4, $6);
    }
    | IDENTIFIER IDENTIFIER NEW L_RND_BRC IDENTIFIER R_RND_BRC SEMICOLON {
        insertSymbol($2, $1, 0);
        printf("%s = new %s\n", $2, $5);
    }
    | IDENTIFIER IDENTIFIER SEMICOLON {
        insertSymbol($2, $1, 0);
    }
    ;

FuncDecl:
    Type IDENTIFIER L_RND_BRC FormalsParam R_RND_BRC StmtBlock
    ;

ClassDecl:
    CLASS IDENTIFIER L_CURL_BRC Fields R_CURL_BRC
    ;

Fields:
    /* empty */
    | Fields Field
    ;

Field:
    VarDecl
    | FuncDecl
    ;

MainFunc:
    VOID MAIN L_RND_BRC R_RND_BRC StmtBlock
    ;

FormalsParam:
    /* empty */
    | FormalsList
    ;

FormalsList:
    Type IDENTIFIER
    | FormalsList COMMA Type IDENTIFIER
    ;

StmtBlock:
    L_CURL_BRC BlockContent R_CURL_BRC
    ;

BlockContent:
    /* empty */
    | BlockContent BlockItem
    ;

BlockItem:
    VarDecl
    | Stmt
    ;

Stmt:
    Expr SEMICOLON
    | IfStmt
    | WhileStmt
    | DoWhileStmt
    | ForStmt
    | BreakStmt
    | ReturnStmt
    | StmtBlock
    | SEMICOLON
    ;


IfHead: IF L_RND_BRC Expr R_RND_BRC {
    $$ = new_label(); 
    printf("ifFalse %s goto %s\n", $3, $$);
};

IfStmt:
    IfHead Stmt %prec LOWER_THAN_ELSE {
        printf("%s:\n", $1); 
    }
    | IfHead Stmt ELSE {
        char* L_EXIT = new_label();
        printf("goto %s\n", L_EXIT); 
        printf("%s:\n", $1);     
        $1 = L_EXIT;             
    } Stmt {
        printf("%s:\n", $1);     
    }
    ;

WhileStmt:
    WHILE L_RND_BRC M Expr R_RND_BRC {
        char* L_EXIT = new_label();
        printf("ifFalse %s goto %s\n", $4, L_EXIT);
        $<str>$ = L_EXIT;
    } Stmt {
        printf("goto %s\n", $3);
        printf("%s:\n", $<str>6);
    }
    ;

DoWhileStmt:
    DO M Stmt WHILE L_RND_BRC Expr R_RND_BRC SEMICOLON {
        printf("if %s goto %s\n", $6, $2);
    }
    ;

ForStmt:
    FOR L_RND_BRC ExprFor SEMICOLON M ExprFor SEMICOLON M ExprFor R_RND_BRC {
        char* L_BODY = new_label();
        char* L_EXIT = new_label();
        
        printf("ifFalse %s goto %s\n", $6, L_EXIT);
        printf("goto %s\n", L_BODY);
        
        printf("%s:\n", $8); 
        printf("goto %s\n", $5); 
        
        printf("%s:\n", L_BODY); 
        
        $<str>$ = L_EXIT; 
        $<str>0 = $8;     
    } Stmt {
        printf("goto %s\n", $8); 
        printf("%s:\n", $<str>11); 
    }
    ;

ExprFor:
    /* empty */ { $$ = "1"; }
    | Expr
    ;

BreakStmt:
    BREAK SEMICOLON { printf("goto L_BREAK\n"); }
    ;

ReturnStmt:
    RETURN ExprOpt SEMICOLON {
        printf("return %s\n", $2);
    }
    ;

ExprOpt:
    /* empty */ { $$ = ""; }
    | Expr
    ;

Type:
    INT | DOUBLE | BOOL | STRING | VOID
    ;

Expr:
    LValue ASSIGN Expr {
        printf("%s = %s\n", $1, $3);
        $$ = $1;
    }
    | Expr OR Expr {
        $$ = new_temp();
        printf("%s = %s || %s\n", $$, $1, $3);
    }
    | Expr AND Expr {
        $$ = new_temp();
        printf("%s = %s && %s\n", $$, $1, $3);
    }
    | Expr EQ Expr { $$ = new_temp(); printf("%s = %s == %s\n", $$, $1, $3); }
    | Expr NEQ Expr { $$ = new_temp(); printf("%s = %s != %s\n", $$, $1, $3); }
    | Expr LT Expr { $$ = new_temp(); printf("%s = %s < %s\n", $$, $1, $3); }
    | Expr LE Expr { $$ = new_temp(); printf("%s = %s <= %s\n", $$, $1, $3); }
    | Expr GT Expr { $$ = new_temp(); printf("%s = %s > %s\n", $$, $1, $3); }
    | Expr GE Expr { $$ = new_temp(); printf("%s = %s >= %s\n", $$, $1, $3); }
    | Expr PLUS Expr {
        $$ = new_temp();
        printf("%s = %s + %s\n", $$, $1, $3);
    }
    | Expr MINUS Expr { $$ = new_temp(); printf("%s = %s - %s\n", $$, $1, $3); }
    | Expr MUL Expr { $$ = new_temp(); printf("%s = %s * %s\n", $$, $1, $3); }
    | Expr DIV Expr { $$ = new_temp(); printf("%s = %s / %s\n", $$, $1, $3); }
    | Expr MOD Expr { $$ = new_temp(); printf("%s = %s %% %s\n", $$, $1, $3); }
    | NOT Expr { $$ = new_temp(); printf("%s = !%s\n", $$, $2); }
    | MINUS Expr %prec UMINUS { $$ = new_temp(); printf("%s = -%s\n", $$, $2); }
    | L_RND_BRC Expr R_RND_BRC { $$ = $2; }
    | LValue {
        check_scope($1); 
        $$ = $1; 
    }
    | Call { $$ = $1; }
    | Constant { $$ = $1; }
    | NEW L_RND_BRC IDENTIFIER R_RND_BRC {
        $$ = new_temp();
        printf("%s = new %s\n", $$, $3);
    }
    ;

LValue:
    IDENTIFIER { $$ = $1; }
    | Expr DOT IDENTIFIER {
        $$ = new_temp();
        printf("%s = %s.%s\n", $$, $1, $3);
    }
    | Expr L_SQR_BRC Expr R_SQR_BRC {
        $$ = new_temp();
        printf("%s = %s[%s]\n", $$, $1, $3);
    }
    ;

Call:
    IDENTIFIER L_RND_BRC Actuals R_RND_BRC {
        printf("call %s, %s\n", $1, "n");
        $$ = "call_ret"; 
    }
    | Expr DOT IDENTIFIER L_RND_BRC Actuals R_RND_BRC {
        $$ = "method_ret";
    }
    ;

Actuals:
    /* empty */
    | ActualList
    ;

ActualList:
    Expr { printf("param %s\n", $1); }
    | ActualList COMMA Expr { printf("param %s\n", $3); }
    ;

Constant:
    INT_CONST | STR_CONST | HEXA_CONST | DOUBLE_CONST | TRUE_CONST | FALSE_CONST
    ;

%%

char* new_temp() {
    char* t = (char*)malloc(20);
    sprintf(t, "t%d", temp_count++);
    return t;
}

char* new_label() {
    char* l = (char*)malloc(20);
    sprintf(l, "L%d", label_count++);
    return l;
}

void check_scope(char* id) {
    if(lookupSymbol(id) == NULL) {
        /* Warn or exit */
    }
}

int main() {
    yyparse();
    return 0;
}

void yyerror(const char *s) {
    fprintf(stderr, "Error at line %d: %s\n", yylineno, s);
}
