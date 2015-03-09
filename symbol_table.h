#include <string.h>
#include <stdio.h>
#include <stdlib.h>

struct symbol {
    char* name;
    union {
        int intval;
        int intarrval[1024];
    } value;
};

struct symbol_table {
    struct symbol st[256];
    int length;
    int initialized;
} symtab;


void symtab_init(struct symbol_table symtab) {
    symtab.length = 0;
    symtab.initialized = 1;
}

// returns index of matching symbol, -1 if not found
int symtab_get(struct symbol_table symtab, char* key) { 
    if (symtab.initialized) {
        int length = symtab.length;
        int i = 0;
        while ( i < length) {
            if (strcmp(key,symtab.st[i].name)) { // if name found
                return i;
            }
            ++i;
        }
    } else {
        printf("symbol table uninitialized\n");
        exit(1);
    }

    return -1;
}

// insert functions will increment the length of the symbol table if not present
// and will append at the original location if it is

void symtab_put_int(struct symbol_table symtab, char* name, int value ) {
    if (symtab.initialized) {
        struct symbol newsym;
        newsym.name = strdup(name);
        newsym.value.intval = value;
        
        int index = symtab_get(symtab, name);
        int not_present = !index;
        if (not_present) {       
            symtab.st[symtab.length++] = newsym;
        } else {
            symtab.st[index] = newsym;
        }

    } else {
        printf("symbol table uninitialized\n");
        exit(1);
    }
}

// should just insert a single int at a single array index, will be called inside for loops
void symtab_put_array(struct symbol_table symtab, char* name, 
                             int values[], size_t vals_length ) {
    if (symtab.initialized) {
        struct symbol newsym;
        newsym.name = strdup(name);
        int i = 0;
        while ( i < vals_length) {    
            newsym.value.intarrval[i] = values[i];
            ++i;
        }
        
        int index = symtab_get(symtab, name);
        int not_present = !index;
        
        if (not_present) {
            symtab.st[symtab.length++] = newsym;
        } else {
            symtab.st[index] = newsym;
        }

        symtab.st[symtab.length++] = newsym;
    } else {
        printf("symbol table uninitialized\n");
        exit(1);
    }   
}

