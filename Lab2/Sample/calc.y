%{
#include <stdio.h>
#include <stdlib.h>


int yylex(void);
int yyerror(const char *s);
%}


%token NUMBER
%left '+' '-'
%left '*' '/'

%%
expr :
      expr '+' expr   { $$ = $1 + $3; }
    | expr '-' expr   { $$ = $1 - $3; }
    | expr '*' expr   { $$ = $1 * $3; }
    | expr '/' expr   { $$ = $1 / $3; }
    | '(' expr ')'    { $$ = $2; }
    | NUMBER          { $$ = $1; }
    ;
%%
int main() {
    printf("Enter expression: ");
    yyparse();
    return 0;
}

int yyerror(const char *s) {
    printf("Syntax Error\n");
    return 0;
}

