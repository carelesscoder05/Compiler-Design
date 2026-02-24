%{
#include <stdio.h>
#include <stdlib.h>
#include "symbol_table.h"

void yyerror(const char *s);
int yylex();
%}

%union {
    char *str;
}

%token <str> ID
%token INT FLOAT CHAR DOUBLE
%token LBRACE RBRACE SEMICOLON

%type <str> type

%%

program:
      declarations
      {
          printf("\nParsing Successful!\n");
          display();
      }
    ;

declarations:
      declarations declaration
    | declaration
    ;

declaration:
      type ID SEMICOLON
      {
          insert($2, $1);
      }
    | LBRACE
      {
          enterScope();
      }
      declarations
      RBRACE
      {
          exitScope();
      }
    ;

type:
      INT     { $$ = "int"; }
    | FLOAT   { $$ = "float"; }
    | CHAR    { $$ = "char"; }
    | DOUBLE  { $$ = "double"; }
    ;

%%

void yyerror(const char *s) {
    printf("Error: %s\n", s);
}

int main() {
    return yyparse();
}