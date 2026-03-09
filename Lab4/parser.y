%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

int yylex();
void yyerror(const char *s);

int tempCount = 1;

char* newTemp()
{
    char *t = (char*)malloc(10);
    sprintf(t,"t%d",tempCount++);
    return t;
}
%}

%union{
    char *str;
}

%token <str> ID NUM

%left '+' '-'
%left '*' '/'

%type <str> expr location

%%

program:
        program stmt
      |
      ;

stmt:
      location '=' expr ';'
      {
          printf("%s = %s\n",$1,$3);
      }
      ;

location:
        ID
        {
            $$ = $1;
        }
      | ID '[' expr ']'
        {
            char *t = newTemp();
            printf("%s = %s [ %s ]\n",t,$1,$3);
            $$ = t;
        }
      ;

expr:
        expr '+' expr
        {
            char *t = newTemp();
            printf("%s = %s + %s\n",t,$1,$3);
            $$ = t;
        }
      | expr '-' expr
        {
            char *t = newTemp();
            printf("%s = %s - %s\n",t,$1,$3);
            $$ = t;
        }
      | expr '*' expr
        {
            char *t = newTemp();
            printf("%s = %s * %s\n",t,$1,$3);
            $$ = t;
        }
      | expr '/' expr
        {
            char *t = newTemp();
            printf("%s = %s / %s\n",t,$1,$3);
            $$ = t;
        }
      | '(' expr ')'
        {
            $$ = $2;
        }
      | location
        {
            $$ = $1;
        }
      | NUM
        {
            $$ = $1;
        }
      ;

%%

int main()
{
    printf("Enter statements:\n");
    yyparse();
    return 0;
}

void yyerror(const char *s)
{
    printf("Error: %s\n",s);
}