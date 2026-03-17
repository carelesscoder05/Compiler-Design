%{
/* --- Forward declarations BEFORE %union --- */
typedef struct list list;
typedef struct bnode bnode;
typedef struct snode snode;
%}

/* --- Union using the types --- */
%union {
    char *str;
    bnode b;
    snode s;
}

/* --- Tokens --- */
%token <str> ID NUM RELOP
%token IF ELSE WHILE

%type <b> B
%type <s> S

%nonassoc IFX
%nonassoc ELSE

/* --- Full C definitions injected into generated header --- */
%code requires {
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

/* --- Struct definitions --- */
struct list {
    int instr;
    struct list *next;
};

struct bnode {
    list *truelist;
    list *falselist;
};

struct snode {
    list *nextlist;
};

/* --- Globals --- */
int nextinstr = 0;
char code[200][100];

/* --- Function prototypes --- */
list* makelist(int i);
list* merge(list *l1, list *l2);
void backpatch(list *l, int addr);
int yylex();
void yyerror(const char *s);
}

/* --- Grammar --- */
%%
program:
    S {
        printf("\n=== INTERMEDIATE CODE ===\n");
        for(int i=0;i<nextinstr;i++)
            printf("%d: %s\n", i, code[i]);
    }
;

S:
      ID '=' NUM ';'
      {
          sprintf(code[nextinstr++], "%s = %s", $1, $3);
          $$.nextlist = NULL;
      }

    | IF '(' B ')' S %prec IFX
      {
          backpatch($3.truelist, nextinstr);
          $$.nextlist = merge($3.falselist, $5.nextlist);
      }

    | IF '(' B ')' S ELSE S
      {
          int l = nextinstr;
          sprintf(code[nextinstr++], "goto _");

          backpatch($3.truelist, l);
          backpatch($3.falselist, l+1);

          $$.nextlist = merge($5.nextlist,
                              merge(makelist(l), $7.nextlist));
      }

    | WHILE '(' B ')' S
      {
          int start = nextinstr;

          backpatch($3.truelist, start);
          backpatch($5.nextlist, start);

          sprintf(code[nextinstr++], "goto %d", start);
          $$.nextlist = $3.falselist;
      }
;

B:
    ID RELOP ID
    {
        sprintf(code[nextinstr], "if %s %s %s goto _", $1, $2, $3);
        $$.truelist = makelist(nextinstr++);

        sprintf(code[nextinstr], "goto _");
        $$.falselist = makelist(nextinstr++);
    }
;
%%

/* --- Function definitions --- */

list* makelist(int i) {
    list *l = (list*)malloc(sizeof(list));
    l->instr = i;
    l->next = NULL;
    return l;
}

list* merge(list *l1, list *l2) {
    if (!l1) return l2;
    list *temp = l1;
    while (temp->next) temp = temp->next;
    temp->next = l2;
    return l1;
}

void backpatch(list *l, int addr) {
    char buf[10];
    sprintf(buf, "%d", addr);

    while (l) {
        char *pos = strstr(code[l->instr], "_");
        if (pos) {
            *pos = '\0';
            strcat(code[l->instr], buf);
        }
        l = l->next;
    }
}

int main() {
    printf("Enter input:\n");
    yyparse();
    return 0;
}

void yyerror(const char *s) {
    printf("Error: %s\n", s);
}