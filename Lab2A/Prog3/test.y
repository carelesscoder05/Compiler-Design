%{
#include <stdio.h>
#include <stdlib.h>

int yylex(void);
int yyerror(char *);
%}

%union {
    int a;
}

%token IF ELSE cL cR rL rR SEMICOLON OTHER
%token <a> DIGIT

%type <a> atom prog

%%

prog:
      prog atom        { printf("Answer: %d\n", $2); $$ = 0; }
    | prog SEMICOLON   { $$ = 0; }
    | /* empty */      { $$ = 0; }
    ;

atom:
      IF rL atom rR cL atom cR ELSE cL atom cR
        {
            if ($3 != 0)
                $$ = $6;
            else
                $$ = $10;
        }
    | IF rL atom rR cL atom cR
        {
            if ($3 != 0)
                $$ = $6;
            else
                $$ = 0;
        }
    | DIGIT
        {
            $$ = $1;
        }
    ;

%%

int yyerror(char *s)
{
    printf("Error in .y file: %s\n", s);
    return 0;
}

int main()
{
    return yyparse();
}