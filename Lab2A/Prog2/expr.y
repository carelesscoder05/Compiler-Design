%{
#include <stdio.h>
int yylex(void);
int yyerror(const char *s);
%}

%token ID NUM
%token AND OR NOT
%token LT GT LE GE EQ NE

%left OR
%left AND
%right NOT
%left EQ NE
%left LT LE GT GE
%left '+' '-'
%left '*' '/'

%%
input:
    expr { printf("Valid expression\n"); }
    ;

expr:
      expr '+' expr
    | expr '-' expr
    | expr '*' expr
    | expr '/' expr
    | expr LT expr
    | expr GT expr
    | expr LE expr
    | expr GE expr
    | expr EQ expr
    | expr NE expr
    | expr AND expr
    | expr OR expr
    | NOT expr
    | '(' expr ')'
    | ID
    | NUM
    ;
%%

int yyerror(const char *s)
{
    printf("Invalid expression\n");
    return 0;
}

int main()
{
    yyparse();
    return 0;
}
