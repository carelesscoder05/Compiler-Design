%{
#include <stdio.h>
#include <stdlib.h>

void yyerror(const char *s);
int yylex();
%}

%token WHILE ID NUMBER
%token LT PLUS ASSIGN
%token LPAREN RPAREN LBRACE RBRACE SEMICOLON

%%

program:
      stmt_list
    ;

stmt_list:
      stmt stmt_list
    | /* empty */
    ;

stmt:
      while_stmt
    | compound_stmt
    | assignment SEMICOLON
    ;

while_stmt:
      WHILE LPAREN expr RPAREN stmt
    ;

compound_stmt:
      LBRACE stmt_list RBRACE
    ;

assignment:
      ID ASSIGN expr
    ;

expr:
      expr PLUS term
    | term
    ;

term:
      ID
    | NUMBER
    | ID LT NUMBER
    ;

%%

void yyerror(const char *s) {
    printf("Syntax Error: %s\n", s);
}

int main() {
    printf("Enter while loop construct:\n");
    
    if (yyparse() == 0)
        printf("Parsing Finished Successfully.\n");
    else
        printf("Parsing Failed.\n");

    return 0;
}