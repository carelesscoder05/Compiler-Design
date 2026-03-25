%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

/* --- DAG Node Structure --- */
typedef struct {
    int id;
    int type;       /* 0: Leaf (Var), 1: Leaf (Const), 2: Interior (Op) */
    char op;        /* '+', '-', '*', '/' */
    int left;       /* Left child Node ID */
    int right;      /* Right child Node ID */
    int val;        /* For constant nodes */
    char name[256]; /* For variable nodes */
} DAGNode;

DAGNode dag[200];
int nodeCount = 0;

/* --- Variable Environment --- */
typedef struct {
    char name[256];
    int nodeId;     /* Points to the current DAG node for this variable */
} VarEnv;

VarEnv varTable[100];
int varCount = 0;

/* --- Function Prototypes --- */
int makeConstNode(int val);
int getVarNode(char* name);
int makeOpNode(char op, int left, int right);
void assignVar(char* name, int nodeId);
void printDAG();

int yylex(void);
int yyerror(const char *s);
%}

/* The semantic value is now just an integer representing the DAG Node ID */
%union {
    int num;
    char *str;
    int nodeId; 
}

%left PLUS MINUS
%left MUL DIV

%token <str> ID
%token <num> NUM
%token PLUS MINUS MUL DIV ASSIGN SEMI

%type <nodeId> E

%%

program:
    program stmt
    | stmt
;

stmt:
    ID ASSIGN E SEMI
    {
        assignVar($1, $3);
    }
;

E:
    NUM { $$ = makeConstNode($1); }
    | ID { $$ = getVarNode($1); }
    | E PLUS E { $$ = makeOpNode('+', $1, $3); }
    | E MINUS E { $$ = makeOpNode('-', $1, $3); }
    | E MUL E { $$ = makeOpNode('*', $1, $3); }
    | E DIV E { $$ = makeOpNode('/', $1, $3); }
;

%%

/* ---------- DAG Construction Functions ---------- */

int makeConstNode(int val) {
    /* Share identical constants */
    for(int i=0; i<nodeCount; i++) {
        if(dag[i].type == 1 && dag[i].val == val) return i;
    }
    dag[nodeCount].id = nodeCount;
    dag[nodeCount].type = 1;
    dag[nodeCount].val = val;
    return nodeCount++;
}

int getVarNode(char* name) {
    /* If variable is already assigned, return its current node */
    for(int i=0; i<varCount; i++) {
        if(strcmp(varTable[i].name, name) == 0) return varTable[i].nodeId;
    }
    
    /* Otherwise, it's an uninitialized external variable. Create a leaf. */
    dag[nodeCount].id = nodeCount;
    dag[nodeCount].type = 0;
    strncpy(dag[nodeCount].name, name, 255);
    int id = nodeCount++;
    
    assignVar(name, id);
    return id;
}

int makeOpNode(char op, int left, int right) {
    /* 1. Constant Folding */
    if(dag[left].type == 1 && dag[right].type == 1) {
        int val = 0;
        if(op == '+') val = dag[left].val + dag[right].val;
        else if(op == '-') val = dag[left].val - dag[right].val;
        else if(op == '*') val = dag[left].val * dag[right].val;
        else if(op == '/') val = dag[left].val / dag[right].val; 
        return makeConstNode(val);
    }

    /* 2. Algebraic Simplification */
    if(op == '+' && dag[right].type == 1 && dag[right].val == 0) return left;
    if(op == '+' && dag[left].type == 1 && dag[left].val == 0) return right;
    if(op == '-' && dag[right].type == 1 && dag[right].val == 0) return left;
    if(op == '-' && left == right) return makeConstNode(0);
    if(op == '*' && dag[right].type == 1 && dag[right].val == 1) return left;
    if(op == '*' && dag[left].type == 1 && dag[left].val == 1) return right;
    if(op == '*' && ((dag[right].type == 1 && dag[right].val == 0) || (dag[left].type == 1 && dag[left].val == 0))) return makeConstNode(0);
    if(op == '/' && dag[right].type == 1 && dag[right].val == 1) return left;
    if(op == '/' && left == right) return makeConstNode(1); 

    /* 3. Common Subexpression Elimination (CSE) */
    for(int i=0; i<nodeCount; i++) {
        if(dag[i].type == 2 && dag[i].op == op) {
            /* Check commutativity for + and * */
            if(op == '+' || op == '*') {
                if((dag[i].left == left && dag[i].right == right) || 
                   (dag[i].left == right && dag[i].right == left)) {
                    return i; 
                }
            } else {
                if(dag[i].left == left && dag[i].right == right) return i;
            }
        }
    }

    /* 4. Create new operation node if no optimizations apply */
    dag[nodeCount].id = nodeCount;
    dag[nodeCount].type = 2;
    dag[nodeCount].op = op;
    dag[nodeCount].left = left;
    dag[nodeCount].right = right;
    return nodeCount++;
}

void assignVar(char* name, int nodeId) {
    for(int i=0; i<varCount; i++) {
        if(strcmp(varTable[i].name, name) == 0) {
            varTable[i].nodeId = nodeId;
            return;
        }
    }
    strcpy(varTable[varCount].name, name);
    varTable[varCount].nodeId = nodeId;
    varCount++;
}

void printDAG() {
    printf("\n=== DAG Structure ===\n");
    for(int i=0; i<nodeCount; i++) {
        if(dag[i].type == 1) 
            printf("Node %d:\tConst\t[%d]\n", i, dag[i].val);
        else if(dag[i].type == 0) 
            printf("Node %d:\tVar\t[%s]\n", i, dag[i].name);
        else 
            printf("Node %d:\tOp\t[%c]\tLeft: Node %d\tRight: Node %d\n", i, dag[i].op, dag[i].left, dag[i].right);
    }
    
    printf("\n=== Final Variables ===\n");
    for(int i=0; i<varCount; i++) {
        printf("%s -> Points to Node %d\n", varTable[i].name, varTable[i].nodeId);
    }
}

int main() {
    printf("Enter basic block:\n");
    yyparse();
    printDAG();
    return 0;
}

int yyerror(const char *s) {
    printf("Error: %s\n", s);
    return 0;
}