%{
    #include "y.tab.h"
    #include <stdio.h>
    extern int yylineno;
%}

%%

"int"        { return INT; }
"double"     { return DOUBLE; }
"bool"       { return BOOL; }
"string"     { return STRING; }
"void"       { return VOID; }
"class"      { return CLASS; }
"if"         { return IF; }
"else"       { return ELSE; }
"while"      { return WHILE; }
"for"        { return FOR; }
"do"         { return DO; }
"break"      { return BREAK; }
"return"     { return RETURN; }
"NewArray"   { return NEWARRAY; }
"New"        { return NEW; }
"main"       { return MAIN; }

"true"       { return TRUE_CONST; }
"false"      { return FALSE_CONST; }

[a-zA-Z][a-zA-Z0-9_]{0,30} { return IDENTIFIER; }

0[xX]([0-9a-fA-F])+        { return HEXA_CONST; }
[0-9]+                     { return INT_CONST; }
[0-9]+\.[0-9]+([eE][+]?[0-9]+)? { return DOUBLE_CONST; }
["]([^"]|\\(.|\n))*["]     { return STR_CONST; }

"="      { return ASSIGN; }
"=="     { return EQ; }
"!="     { return NEQ; }
"<"      { return LT; }
"<="     { return LE; }
">"      { return GT; }
">="     { return GE; }
"&&"     { return AND; }
"||"     { return OR; }
"!"      { return NOT; }
"+"      { return PLUS; }
"-"      { return MINUS; }
"*"      { return MUL; }
"/"      { return DIV; }
"%"      { return MOD; }

"("      { return L_RND_BRC; }
")"      { return R_RND_BRC; }
"{"      { return L_CURL_BRC; }
"}"      { return R_CURL_BRC; }
"["      { return L_SQR_BRC; }
"]"      { return R_SQR_BRC; }
";"      { return SEMICOLON; }
","      { return COMMA; }
"."      { return DOT; }

"//".* { /* single-line comment */ }
"/*"([^*]|\*+[^*/])*\*+"/"  { /* multi-line comment */ }
[ \t\r]+                    { /* skip whitespace */ }
\n                          { yylineno++; }
.                           { return yytext[0]; }

%%

int yywrap(){
    return 1;
}
