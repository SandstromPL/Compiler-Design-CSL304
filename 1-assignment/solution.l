%{
	#include<stdio.h>
%}

%%

"void"|"int"|"double"|"bool"|"string"|"extends"|"implements"|"for"|"while"|"ReadInteger"|"ReadLine"|"class"|"interface"|"if"|"else"|"return"|"null"|"this"|"break"|"New"|"NewArray"|"Print" { printf("%s : KEYWORD\n", yytext); }

"True"|"False" { printf("%s : BOOLEAN\n", yytext); }

[a-zA-Z][a-zA-Z0-9_]{0,30} { printf("%s : IDENTIFIER\n", yytext); }

0[xX]([0-9a-fA-F])+ {printf("%s : HEXADECIMAL-INTEGER\n",yytext);}

[0-9]+ {printf("%s : INTEGER\n",yytext);}

[0-9]+\.[0-9]+([eE][+]?[0-9]+)? {printf("%s : DOUBLE\n",yytext);}

["]([^"]|\\(.|\n))*["] {printf("%s : STRING\n",yytext);}

"+"|"-"|"*"|"/"|"%"|"\\"|"<"|"<="|">"|">="|"="|"=="|"!="|"&&"|"||"|"!"|";"|","|"."|"[]"|"["|"]"|"("|")" {printf("%s : OPERATORS\n",yytext);} 

"//".* {printf("%s : SINGLE-LINE-COMMENT\n",yytext);}

"/*".*"*/" {printf("%s : MULTI-LINE-COMMENT\n",yytext);}

[ \t\n]+ { /* ignore whitespace */ }
.
%%

int yywrap(){
	return 1;
}

int main(){
	printf("start wrting : \n");
	yylex();
	return 0;
}
