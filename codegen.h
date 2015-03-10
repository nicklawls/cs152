#include <string.h>
#include <stdio.h>
#include <stdlib.h>
#include "symbol_table.h"

void gen4(char* buff, char* op, char* dst, char* src1, char* src2) {
    snprintf(buff, 64, "%s %s, %s, %s\n", op, dst, src1, src2);
}

void gen3(char* buff, char* op, char* dst, char* src) {
    snprintf(buff, 64, "%s %s, %s\n", op, dst, src);
}

void gen3i(char* buff, char* op, char* dst, int imm) {
    snprintf(buff, 64, "%s %s, %i\n", op, dst, imm);
}

void gen2(char* buff, char* op, char* dst) {
    snprintf(buff, 64, "%s %s\n", op, dst);
}

static char tmpname = 't';
static int tmpcount = 0;

static int labelcount = 0;

void newtemp(char* dst) {
    char temp[16];

    do {
        ++tmpcount;
        sprintf(temp, "%c%i", tmpname,tmpcount);
    } while(symtab_get(temp));

    symtab_put_int(temp, 0);
    sprintf(dst, "%s", temp);
}

void newlabel(char* dst) {
    sprintf(dst, "L%i", labelcount++);
}
