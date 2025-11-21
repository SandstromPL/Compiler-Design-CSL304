%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

void yyerror(const char *s);
int yylex(void);
extern int yylineno;
%}

/* TOKENS */
%token INT DOUBLE BOOL STRING VOID CLASS IF ELSE WHILE FOR DO BREAK RETURN
%token NEWARRAY NEW MAIN
%token ASSIGN EQ NEQ LT LE GT GE AND OR NOT
%token PLUS MINUS MUL DIV MOD
%token L_RND_BRC R_RND_BRC L_CURL_BRC R_CURL_BRC L_SQR_BRC R_SQR_BRC SEMICOLON COMMA DOT
%token IDENTIFIER HEXA_CONST INT_CONST DOUBLE_CONST STR_CONST TRUE_CONST FALSE_CONST

/* PRECEDENCE (Solves Expression Conflicts) */
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
/* Highest Priority: Fixes ambiguity between Array Access and ID inside Expr */
%left DOT L_SQR_BRC L_RND_BRC 

%start Program

%%

/* --- PROGRAM STRUCTURE --- */
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

/* --- DECLARATIONS --- */
VarDecl:
    Type IDENTIFIER SEMICOLON
    | IDENTIFIER NEWARRAY L_RND_BRC INT_CONST COMMA Type R_RND_BRC SEMICOLON
    /* FIX 1: Add this rule to allow "MathOps obj New(MathOps);" */
    | IDENTIFIER IDENTIFIER NEW L_RND_BRC IDENTIFIER R_RND_BRC SEMICOLON
    /* FIX 2: Add this rule to allow simple object decl "MathOps obj;" */
    | IDENTIFIER IDENTIFIER SEMICOLON 
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

/* --- PARAMETERS --- */
FormalsParam:
    /* empty */
    | FormalsList
    ;

FormalsList:
    Type IDENTIFIER
    | FormalsList COMMA Type IDENTIFIER
    ;

/* --- BLOCKS (The Fix for your Conflict) --- */
/* Instead of VarList then StmtList, we allow a mix of items. 
   This solves the IDENTIFIER lookahead problem. */

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

/* --- STATEMENTS --- */
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

IfStmt:
    IF L_RND_BRC Expr R_RND_BRC Stmt %prec LOWER_THAN_ELSE
    | IF L_RND_BRC Expr R_RND_BRC Stmt ELSE Stmt
    ;

WhileStmt:
    WHILE L_RND_BRC Expr R_RND_BRC Stmt
    ;

DoWhileStmt:
    DO Stmt WHILE L_RND_BRC Expr R_RND_BRC SEMICOLON
    ;

ForStmt:
    FOR L_RND_BRC ExprFor SEMICOLON ExprFor SEMICOLON ExprFor R_RND_BRC Stmt
    ;

ExprFor:
    /* empty */
    | Expr
    ;

BreakStmt:
    BREAK SEMICOLON
    ;

ReturnStmt:
    RETURN ExprOpt SEMICOLON
    ;

ExprOpt:
    /* empty */
    | Expr
    ;

/* --- TYPES --- */
Type:
    INT | DOUBLE | BOOL | STRING | VOID
    ;

/* --- EXPRESSIONS --- */
Expr:
    LValue ASSIGN Expr
    | Expr OR Expr
    | Expr AND Expr
    | Expr EQ Expr
    | Expr NEQ Expr
    | Expr LT Expr
    | Expr LE Expr
    | Expr GT Expr
    | Expr GE Expr
    | Expr PLUS Expr
    | Expr MINUS Expr
    | Expr MUL Expr
    | Expr DIV Expr
    | Expr MOD Expr
    | NOT Expr
    | MINUS Expr %prec UMINUS
    | L_RND_BRC Expr R_RND_BRC
    | LValue
    | Call
    | Constant
    | NEW L_RND_BRC IDENTIFIER R_RND_BRC
    ;

LValue:
    IDENTIFIER
    | Expr DOT IDENTIFIER
    | Expr L_SQR_BRC Expr R_SQR_BRC
    ;

Call:
    IDENTIFIER L_RND_BRC Actuals R_RND_BRC
    | Expr DOT IDENTIFIER L_RND_BRC Actuals R_RND_BRC
    ;

Actuals:
    /* empty */
    | ActualList
    ;

ActualList:
    Expr
    | ActualList COMMA Expr
    ;

Constant:
    INT_CONST
    | STR_CONST
    | HEXA_CONST
    | DOUBLE_CONST
    | TRUE_CONST
    | FALSE_CONST
    ;

%%

int main() {
    printf("Parsing Starts:\n");
    yyparse();
    printf("Parsing Complete.\n");
    return 0;
}

void yyerror(const char *s) {
    fprintf(stderr, "Error at line %d: %s\n", yylineno, s);
}
