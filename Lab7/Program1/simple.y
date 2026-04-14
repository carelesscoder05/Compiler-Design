%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
int reg_count = 0;
char* new_reg() {
    char buf[10];
    sprintf(buf, "R%d", reg_count++);
    return strdup(buf);
}

void emit(char *op, char *r, char *arg) {
    printf("%s %s, %s\n", op, r, arg);
}
%}
%union {
    char* str;
    int num;
}
%token <str> ID
%token <num> NUM
%type <str> E
%%

S : E '\n' {
    printf("Result in %s\n", $1);
 }
;

E : E '+' E { char* r
= new_reg();
emit("MOV", r, $1);
emit("ADD", r, $3);
$$ = r;
}
| E '-' E {
char* r = new_reg();
emit("MOV", r, $1);
emit("SUB",
r, $3);
$$ = r;
}
| E '*' E {
char* r = new_reg();
emit("MOV", r, $1);
emit("MUL",
r, $3);
$$ = r;
}
| E '/' E {
char* r = new_reg();
emit("MOV", r, $1);
emit("DIV",
r, $3);
$$ = r;
}
| '(' E ')' { $$ = $2; }
| ID { $$ = $1; }
| NUM { 
    char* r = new_reg();
    char buf[20];
    sprintf(buf, "%d", $1);
    emit("MOV", r, buf);
    $$ = r;
};
%%

int main() {
    printf("Enter expression:\n"); 
    yyparse();
    return 0;
}

int yyerror(char *s) {
    printf("Error: %s\n", s);
    return 0;
}