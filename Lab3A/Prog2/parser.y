%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

void enter(char* name, char* type, int offset);
void print_table();
int yylex();
int yyerror(const char *s);

int offset = 0;

struct Symbol {
    char name[32];
    char type[64];
    int offset;
} symbol_table[100];

int sym_count = 0;

%}

%union {
    int val;
    char name[32];
    struct {
        char type[64];
        int width;
    } t_attr;
}

%token <name> ID
%token <val> NUM
%token INTEGER REAL ARRAY OF
%token COLON SEMI LBRACK RBRACK PTR_SYM

%type <t_attr> T
%start P

%%

P : { offset = 0; } D
    ;

D : D SEMI decl
  | decl
  ;

decl :
      ID COLON T
      {
          enter($1, $3.type, offset);
          offset += $3.width;
      }
    ;

T : INTEGER
      {
          strcpy($$.type, "integer");
          $$.width = 4;
      }
  | REAL
      {
          strcpy($$.type, "real");
          $$.width = 8;
      }
  | ARRAY LBRACK NUM RBRACK OF T
      {
          sprintf($$.type, "array(%d,%s)", $3, $6.type);
          $$.width = $3 * $6.width;
      }
  | PTR_SYM T
      {
          sprintf($$.type, "pointer(%s)", $2.type);
          $$.width = 4;
      }
  ;

%%

void enter(char* name, char* type, int off) {
    strcpy(symbol_table[sym_count].name, name);
    strcpy(symbol_table[sym_count].type, type);
    symbol_table[sym_count].offset = off;
    sym_count++;
}

void print_table() {
    printf("\n%-10s %-25s %-10s\n", "ID", "Type", "Offset");
    printf("------------------------------------------------------\n");
    for(int i = 0; i < sym_count; i++) {
        printf("%-10s %-25s %-10d\n",
               symbol_table[i].name,
               symbol_table[i].type,
               symbol_table[i].offset);
    }
    printf("\nFinal Offset: %d\n", offset);
}

int main() {
    printf("Enter declarations (example: x:integer; y:real;):\n");
    if(!yyparse()) {
        print_table();
    }
    return 0;
}

int yyerror(const char *s) {
    printf("Syntax Error: %s\n", s);
    return 0;
}