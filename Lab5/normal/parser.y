%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

int yylex();
void yyerror(const char *s);

int tempCount = 1;
int labelCount = 1;

char* newTemp() {
    char *t = (char*)malloc(10);
    sprintf(t,"t%d",tempCount++);
    return t;
}

char* newLabel() {
    char *l = (char*)malloc(10);
    sprintf(l,"L%d",labelCount++);
    return l;
}
%}

%union {
    char *str;
}

%nonassoc IFX
%nonassoc ELSE
%token <str> ID NUM
%token IF ELSE WHILE
%token <str> RELOP

%left '+' '-'
%left '*' '/'

%type <str> expr cond

%%

program:
        program stmt
      |
      ;

stmt:
      ID '=' expr ';'
      {
          printf("%s = %s\n",$1,$3);
      }

    | IF '(' cond ')' stmt %prec IFX
      {
          char *L1 = newLabel();
          char *L2 = newLabel();

          printf("if %s goto %s\n",$3,L1);
          printf("goto %s\n",L2);
          printf("%s:\n",L1);

          /* stmt already printed */

          printf("%s:\n",L2);
      }

    | IF '(' cond ')' stmt ELSE stmt
      {
          char *L1 = newLabel();
          char *L2 = newLabel();
          char *L3 = newLabel();

          printf("if %s goto %s\n",$3,L1);
          printf("goto %s\n",L2);

          printf("%s:\n",L1);
          /* true stmt */

          printf("goto %s\n",L3);

          printf("%s:\n",L2);
          /* false stmt */

          printf("%s:\n",L3);
      }

    | WHILE '(' cond ')' stmt
      {
          char *L1 = newLabel();
          char *L2 = newLabel();
          char *L3 = newLabel();

          printf("%s:\n",L1);
          printf("if %s goto %s\n",$3,L2);
          printf("goto %s\n",L3);

          printf("%s:\n",L2);
          /* loop body */

          printf("goto %s\n",L1);
          printf("%s:\n",L3);
      }
      ;

cond:
      expr RELOP expr
      {
          char *t = (char*)malloc(50);
          sprintf(t,"%s %s %s",$1,$2,$3);
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
    | ID { $$ = $1; }
    | NUM { $$ = $1; }
    ;

%%

int main() {
    printf("Enter input:\n");
    yyparse();
    return 0;
}

void yyerror(const char *s) {
    printf("Error: %s\n", s);
}