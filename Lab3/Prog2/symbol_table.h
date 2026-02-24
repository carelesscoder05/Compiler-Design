#ifndef SYMBOL_TABLE_H
#define SYMBOL_TABLE_H

void insert(char *name, char *datatype);
void enterScope();
void exitScope();
void display();

#endif