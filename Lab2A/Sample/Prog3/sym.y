%{
#include <stdio.h>
#include <string.h>

/* symbol table entry */
struct symtab {
    char name[30];
    char type[10];
    int size;
    int offset;
    int scope;
};

struct symtab table[100];
int symcount = 0;

/* shared variables */
int current_scope = 0;
int offset = 0;
char current_type[10];

void insert(char *name);
int yylex(void);
int yyerror(const char *s);
%}

%union {
    char id[30];
}

%token <id> ID
%token INT FLOAT CHAR

%%
program:
    declarations
    ;

declarations:
      declarations declaration
    | declaration
    ;

declaration:
    type id_list ';'
    ;

type:
      INT   { strcpy(current_type, "int"); }
    | FLOAT { strcpy(current_type, "float"); }
    | CHAR  { strcpy(current_type, "char"); }
    ;

id_list:
      id_list ',' ID   { insert($3); }
    | ID               { insert($1); }
    ;
%%
void insert(char *name)
{
    int size;

    if (strcmp(current_type, "int") == 0)
        size = 4;
    else if (strcmp(current_type, "float") == 0)
        size = 4;
    else
        size = 1;

    strcpy(table[symcount].name, name);
    strcpy(table[symcount].type, current_type);
    table[symcount].size = size;
    table[symcount].offset = offset;
    table[symcount].scope = current_scope;

    offset += size;
    symcount++;
}

int main()
{
    yyparse();

    printf("\nSYMBOL TABLE\n");
    printf("Name\tType\tSize\tOffset\tScope\n");

    for (int i = 0; i < symcount; i++) {
        printf("%s\t%s\t%d\t%d\t%d\n",
               table[i].name,
               table[i].type,
               table[i].size,
               table[i].offset,
               table[i].scope);
    }
    return 0;
}

int yyerror(const char *s)
{
    printf("Syntax Error\n");
    return 0;
}

