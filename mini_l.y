%{
	#include <stdio.h>
	#include <stdlib.h>
	void yyerror(const char *message);
    extern int yylineno;
    extern int yycolumno;
%}

%union{
	int intval;
    double floatval;
	char* stringval;
}


%error-verbose
%start input
%token <intval> NUMBER
%token <stringval> IDENT
%token SEMICOLON BEGINPROGRAM ENDPROGRAM ASSIGN L_PAREN R_PAREN COLON
%token INTEGER PROGRAM
%token ARRAY OF IF THEN ENDIF ELSE ELSEIF WHILE DO BEGINLOOP BREAK CONTINUE
%token EXIT READ WRITE 
%token COMMA QUESTION TRUE FALSE
%left AND OR NOT EQ NEQ LT GT LTE GTE
%left ADD SUB
%left MULT DIV
%left MOD



%type <intval> expression
/*
%type <intval> bool_exp relation_and_exp relation_exp comp
%type <stringval> block 
%type <stringval> multiplicative_exp
%type <stringval> program statement declaration
%type <stringval> var term
*/

%%

input : expression;

expression : NUMBER {$$ = $1;} ;

%%

void yyerror(const char* msg) {
    printf("** Line %d, position %d: %s\n", yylineno, yycolumno, msg);
}