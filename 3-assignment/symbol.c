/* symboltable.c */
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "symbol.h"
Symbol* symbolTable[TABLE_SIZE] = {0};

unsigned int hash(char *str) {
    unsigned int hash = 0;
    while (*str) hash = (hash << 2) + *str++;
    return hash % TABLE_SIZE;
}

void insertSymbol(char* name, char* type, int scope) {
    unsigned int idx = hash(name);
    Symbol* sym = lookupSymbol(name);
    if (sym != NULL) {
        printf("Error: Redeclaration of %s\n", name);
        return;
    }
    sym = (Symbol*)malloc(sizeof(Symbol));
    strcpy(sym->name, name);
    strcpy(sym->type, type);
    sym->scope = scope;
    sym->next = symbolTable[idx];
    symbolTable[idx] = sym;
    printf("Inserted: %s, Type: %s, Scope: %d\n", name, type, scope);
}

Symbol* lookupSymbol(char* name) {
    unsigned int idx = hash(name);
    Symbol* sym = symbolTable[idx];
    while (sym != NULL) {
        if (strcmp(sym->name, name) == 0) return sym;
        sym = sym->next;
    }
    return NULL;
}

