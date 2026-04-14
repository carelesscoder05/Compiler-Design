%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#define MAX 100
typedef struct Node {
char op;
char left[10];
char right[10];
char reg[10];
} Node;
Node nodes[MAX]; int
node_count = 0; int
reg_count = 0; char*
new_reg() { static
char buf[10];
sprintf(buf, "R%d", reg_count++);
return strdup(buf);}
int find_node(char op, char* l, char* r) {
for (int i = 0; i < node_count; i++) {
if (nodes[i].op == op &&
strcmp(nodes[i].left, l) == 0 &&
strcmp(nodes[i].right, r) == 0)
return i;
}
return -1;
}
char* make_node(char op, char* l, char* r) {
int idx = find_node(op, l, r);
if (idx != -1)
return nodes[idx].reg;
strcpy(nodes[node_count].left, l);
strcpy(nodes[node_count].right, r); nodes[node_count].op
= op;
char* rname = new_reg();
strcpy(nodes[node_count].reg, rname);
node_count++;
return rname;
}
void generate_code() {
for (int i = 0; i < node_count; i++) {
printf("MOV %s, %s\n", nodes[i].reg, nodes[i].left);
switch(nodes[i].op) {
case '+': printf("ADD %s, %s\n",
nodes[i].reg, nodes[i].right); break;
case '-': printf("SUB %s, %s\n",
nodes[i].reg, nodes[i].right); break;
case '*': printf("MUL %s, %s\n",
nodes[i].reg, nodes[i].right); break;
case '/': printf("DIV %s, %s\n",
nodes[i].reg, nodes[i].right); break;
}
}
}
%}
%union {
char* str;
}
%token <str> ID NUM
%type <str> E
%right '+' '-'
%right '*' '/'
%%
S : E '\n' {
generate_code();
printf("Final result in %s\n", $1);
}
;E : E '+' E { $$ = make_node('+', $1, $3); }
| E '*' E { $$ = make_node('*', $1, $3); }
| E '-' E { $$ = make_node('-', $1, $3); }
| E '/' E { $$ = make_node('/', $1, $3); }
| '(' E ')' { $$ = $2; }
| ID { $$ = $1; }
;
%%
int main() {
printf("Enter expression:\n");
yyparse(); return 0;
}
int yyerror(char *s) {
printf("Error: %s\n", s);
return 0;
}