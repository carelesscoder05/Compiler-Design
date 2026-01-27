%{
#include <stdio.h>
%}

%option noyywrap

%%

"+="    printf("<ADD_ASSIGN, %s>\n", yytext);
"-="    printf("<SUB_ASSIGN, %s>\n", yytext);
"*="    printf("<MUL_ASSIGN, %s>\n", yytext);
"/="    printf("<DIV_ASSIGN, %s>\n", yytext);
"="     printf("<ASSIGN, %s>\n", yytext);

"=="    printf("<EQUAL, %s>\n", yytext);
"!="    printf("<NOT_EQUAL, %s>\n", yytext);
"<="    printf("<LESS_EQUAL, %s>\n", yytext);
">="    printf("<GREATER_EQUAL, %s>\n", yytext);
"<"     printf("<LESS_THAN, %s>\n", yytext);
">"     printf("<GREATER_THAN, %s>\n", yytext);

"&&"    printf("<LOGICAL_AND, %s>\n", yytext);
"||"    printf("<LOGICAL_OR, %s>\n", yytext);
"!"     printf("<LOGICAL_NOT, %s>\n", yytext);

"+"     printf("<ADD, %s>\n", yytext);
"-"     printf("<SUBTRACT, %s>\n", yytext);
"*"     printf("<MULTIPLY, %s>\n", yytext);
"/"     printf("<DIVIDE, %s>\n", yytext);
"%"     printf("<MODULUS, %s>\n", yytext);

[ \t\n]+    ;

.           ;
%%

int main(int argc, char *argv[])
{
    if (argc > 1)
        yyin = fopen(argv[1], "r");

    yylex();
    return 0;
}
