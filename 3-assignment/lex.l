%{
    #include "y.tab.h"
    #include <stdio.h>
    #include <string.h>
    extern int yylineno;
%}

%%

"int"        { yylval.str = strdup(yytext); return INT; }
"double"     { yylval.str = strdup(yytext); return DOUBLE; }
"bool"       { yylval.str = strdup(yytext); return BOOL; }
"string"     { yylval.str = strdup(yytext); return STRING; }
"void"       { yylval.str = strdup(yytext); return VOID; }
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

"true"       { yylval.str = strdup("true"); return TRUE_CONST; }
"false"      { yylval.str = strdup("false"); return FALSE_CONST; }

[a-zA-Z][a-zA-Z0-9_]{0,30} { yylval.str = strdup(yytext); return IDENTIFIER; }

0[xX]([0-9a-fA-F])+        { yylval.str = strdup(yytext); return HEXA_CONST; }
[0-9]+                     { yylval.str = strdup(yytext); return INT_CONST; }
[0-9]+\.[0-9]+([eE][+]?[0-9]+)? { yylval.str = strdup(yytext); return DOUBLE_CONST; }
["]([^"]|\\(.|\n))*["]     { yylval.str = strdup(yytext); return STR_CONST; }

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
