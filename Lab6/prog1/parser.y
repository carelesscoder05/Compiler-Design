%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

/* Updated structure to track variables and copies */
struct expr {
    int isConst;
    int value;
    int isId;       /* 1 if it's a raw variable, 0 if it's a composite expression */
    char *name;
    char *copyOf;   /* Tracks which variable this is a copy of */
};

/* Symbol table */
struct expr symtab[100];
int symcount = 0;

/* Function prototypes */
int lookup(char *name);
void update(char *name, int isConst, int val, char *copyOf);
int yylex(void);
int yyerror(const char *s);
%}

%union {
    int num;
    char *str;
    struct expr e;
}

%left PLUS MINUS
%left MUL DIV

%token <str> ID
%token <num> NUM
%token PLUS MINUS MUL DIV ASSIGN SEMI

%type <e> E

%%

program:
    program stmt
    | stmt
;

stmt:
    ID ASSIGN E SEMI
    {
        if($3.isConst) {
            printf("%s = %d\n", $1, $3.value);
            update($1, 1, $3.value, NULL);
        } 
        else if ($3.isId) {
            /* Copy Propagation: $3 is just another variable */
            printf("%s = %s\n", $1, $3.name);
            update($1, 0, 0, $3.name);
        } 
        else {
            printf("%s = %s\n", $1, $3.name);
            update($1, 0, 0, NULL);
        }
    }
;

E:
    NUM {
        $$.isConst = 1;
        $$.isId = 0;
        $$.value = $1;
        $$.name = malloc(20);
        sprintf($$.name, "%d", $1);
    }

    | ID {
        int i = lookup($1);
        if(i != -1 && symtab[i].isConst) {
            /* Constant Propagation */
            $$.isConst = 1;
            $$.isId = 0;
            $$.value = symtab[i].value;
            $$.name = malloc(20);
            sprintf($$.name, "%d", symtab[i].value);
        } 
        else if(i != -1 && symtab[i].copyOf != NULL) {
            /* Copy Propagation: Swap the ID for its source */
            $$.isConst = 0;
            $$.isId = 1;
            $$.name = strdup(symtab[i].copyOf);
        } 
        else {
            /* Standard Variable */
            $$.isConst = 0;
            $$.isId = 1;
            $$.name = strdup($1);
        }
    }

    | E PLUS E {
        if($1.isConst && $3.isConst) {
            $$.isConst = 1; $$.isId = 0;
            $$.value = $1.value + $3.value;
            $$.name = malloc(20); sprintf($$.name, "%d", $$.value);
        } 
        else if($3.isConst && $3.value == 0) { $$ = $1; } 
        else if($1.isConst && $1.value == 0) { $$ = $3; } 
        else {
            $$.isConst = 0; $$.isId = 0;
            $$.name = malloc(strlen($1.name) + strlen($3.name) + 4);
            sprintf($$.name, "%s + %s", $1.name, $3.name);
        }
    }

    | E MINUS E {
        if($1.isConst && $3.isConst) {
            $$.isConst = 1; $$.isId = 0;
            $$.value = $1.value - $3.value;
            $$.name = malloc(20); sprintf($$.name, "%d", $$.value);
        } 
        else if($3.isConst && $3.value == 0) { $$ = $1; } /* Simplification */
        else {
            $$.isConst = 0; $$.isId = 0;
            $$.name = malloc(strlen($1.name) + strlen($3.name) + 4);
            sprintf($$.name, "%s - %s", $1.name, $3.name);
        }
    }

    | E MUL E {
        if($1.isConst && $3.isConst) {
            $$.isConst = 1; $$.isId = 0;
            $$.value = $1.value * $3.value;
            $$.name = malloc(20); sprintf($$.name, "%d", $$.value);
        } 
        else if($3.isConst && $3.value == 1) { $$ = $1; } 
        else if($1.isConst && $1.value == 1) { $$ = $3; } 
        else if(($3.isConst && $3.value == 0) || ($1.isConst && $1.value == 0)) {
            /* Multiply by zero simplification */
            $$.isConst = 1; $$.isId = 0; $$.value = 0;
            $$.name = strdup("0");
        }
        else {
            $$.isConst = 0; $$.isId = 0;
            $$.name = malloc(strlen($1.name) + strlen($3.name) + 4);
            sprintf($$.name, "%s * %s", $1.name, $3.name);
        }
    }

    | E DIV E {
        if($1.isConst && $3.isConst && $3.value != 0) {
            $$.isConst = 1; $$.isId = 0;
            $$.value = $1.value / $3.value;
            $$.name = malloc(20); sprintf($$.name, "%d", $$.value);
        } 
        else if($3.isConst && $3.value == 1) { $$ = $1; } 
        else if($1.isConst && $1.value == 0) {
            $$.isConst = 1; $$.isId = 0; $$.value = 0;
            $$.name = strdup("0");
        }
        else {
            $$.isConst = 0; $$.isId = 0;
            $$.name = malloc(strlen($1.name) + strlen($3.name) + 4);
            sprintf($$.name, "%s / %s", $1.name, $3.name);
        }
    }
;

%%

/* ---------- Helper Functions ---------- */

int lookup(char *name) {
    for(int i=0; i<symcount; i++)
        if(strcmp(symtab[i].name, name) == 0)
            return i;
    return -1;
}

void update(char *name, int isConst, int val, char *copyOf) {
    int i = lookup(name);
    
    /* 1. Update the variable itself */
    if(i == -1) {
        symtab[symcount].name = strdup(name);
        symtab[symcount].isConst = isConst;
        symtab[symcount].value = val;
        symtab[symcount].copyOf = copyOf ? strdup(copyOf) : NULL;
        symcount++;
    } else {
        symtab[i].isConst = isConst;
        symtab[i].value = val;
        if(symtab[i].copyOf) free(symtab[i].copyOf);
        symtab[i].copyOf = copyOf ? strdup(copyOf) : NULL;
    }

    /* 2. Invalidate older copies! 
       If 'name' just got a new assignment, anything that was acting 
       as a copy of 'name' is now invalid and must be broken. */
    for(int j=0; j<symcount; j++) {
        if(symtab[j].copyOf && strcmp(symtab[j].copyOf, name) == 0) {
            free(symtab[j].copyOf);
            symtab[j].copyOf = NULL;
        }
    }
}

int main() {
    printf("Enter basic block:\n");
    yyparse();
    return 0;
}

int yyerror(const char *s) {
    printf("Error: %s\n", s);
    return 0;
}