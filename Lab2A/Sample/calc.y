%{
#include <stdio.h>
#include <stdlib.h>

int yylex(void);
int yyerror(const char *s);
%}


%define api.value.type {int}

%token NUMBER

/* Operator precedence */
%left '+' '-'
%left '*' '/'

%%

/* Start symbol */
input:
      /* empty */
    | input line
    ;

line:
      '\n'
    | expr '\n'   { printf("Result = %d\n", $1); }
    ;

expr:
      expr '+' expr   { $$ = $1 + $3; }
    | expr '-' expr   { $$ = $1 - $3; }
    | expr '*' expr   { $$ = $1 * $3; }
    | expr '/' expr   { $$ = $1 / $3; }
    | '(' expr ')'    { $$ = $2; }
    | NUMBER          { $$ = $1; }
    ;

%%

int main() {
    printf("Simple Calculator (Press Ctrl+D to exit)\n");
    return yyparse();
}

int yyerror(const char *s) {
    printf("Syntax Error\n");
    return 0;
}