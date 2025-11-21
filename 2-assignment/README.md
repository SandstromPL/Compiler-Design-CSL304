ASSIGNMENT-2

In this assignment we build a syntax analyzer which can identify variable declaration , function declaration, class declaration and main function.This is an extenstion of previous assignment1 , added lexical analyzer.

To execute it do the following:
```bash
lex lex.l
yacc -d parser.y
gcc lex.yy.c y.tab.c -o out
./out < input.txt
```
