%{
#include <stdio.h>
#include <string.h>

#define MAX_ID_LEN 32
%}

%option noyywrap


LETTER      [a-zA-Z_]
DIGIT       [0-9]
ID          {LETTER}({LETTER}|{DIGIT})*
INTNUM      {DIGIT}+
FLOATNUM    {DIGIT}+"."{DIGIT}+

%%

"int"       printf("<KEYWORD, %s>\n", yytext);
"float"     printf("<KEYWORD, %s>\n", yytext);
"char"      printf("<KEYWORD, %s>\n", yytext);
"if"        printf("<KEYWORD, %s>\n", yytext);
"else"      printf("<KEYWORD, %s>\n", yytext);
"while"     printf("<KEYWORD, %s>\n", yytext);
"return"    printf("<KEYWORD, %s>\n", yytext);


{ID} {
        if (strlen(yytext) > MAX_ID_LEN)
            printf("ERROR: Identifier too long (%s)\n", yytext);
        else
            printf("<IDENTIFIER, %s>\n", yytext);
     }


{FLOATNUM}  printf("<FLOAT_CONST, %s>\n", yytext);
{INTNUM}    printf("<INT_CONST, %s>\n", yytext);


{DIGIT}+{LETTER}+   printf("ERROR: Invalid identifier (%s)\n", yytext);


[ \t\n]+    ;
"//".*      ;


.           ;

%%

int main(int argc, char *argv[])
{
    if (argc > 1)
        yyin = fopen(argv[1], "r");

    yylex();
    return 0;
}
