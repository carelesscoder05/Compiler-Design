#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#define MAX 100

typedef struct Symbol {
    char name[50];
    char datatype[20];
    int size;
    int offset;
    int scope;
} Symbol;

Symbol table[MAX];
int count = 0;

int current_scope = 0;
int current_offset = 0;

int getSize(char *datatype) {
    if (strcmp(datatype, "int") == 0)
        return 4;
    else if (strcmp(datatype, "float") == 0)
        return 4;
    else if (strcmp(datatype, "char") == 0)
        return 1;
    else if (strcmp(datatype, "double") == 0)
        return 8;
    else
        return 0;
}

int lookup(char *name) {
    for (int i = count - 1; i >= 0; i--) {
        if (strcmp(table[i].name, name) == 0 &&
            table[i].scope == current_scope)
            return i;
    }
    return -1;
}

void insert(char *name, char *datatype) {

    if (lookup(name) != -1) {
        printf("Error: Redeclaration of variable '%s'\n", name);
        return;
    }

    strcpy(table[count].name, name);
    strcpy(table[count].datatype, datatype);

    table[count].size = getSize(datatype);
    table[count].offset = current_offset;
    table[count].scope = current_scope;

    current_offset += table[count].size;
    count++;

    printf("Inserted: %s\n", name);
}

void enterScope() {
    current_scope++;
    current_offset = 0;
    printf("\nEntered Scope %d\n", current_scope);
}

void exitScope() {
    printf("\nExiting Scope %d\n", current_scope);

    while (count > 0 && table[count - 1].scope == current_scope) {
        count--;
    }

    current_scope--;
    current_offset = 0;
}

void display() {
    printf("\n================ SYMBOL TABLE ================\n");
    printf("Name\tDatatype\tSize\tOffset\tScope\n");
    printf("------------------------------------------------\n");

    for (int i = 0; i < count; i++) {
        printf("%s\t%s\t\t%d\t%d\t%d\n",
               table[i].name,
               table[i].datatype,
               table[i].size,
               table[i].offset,
               table[i].scope);
    }

    printf("==============================================\n");
}
