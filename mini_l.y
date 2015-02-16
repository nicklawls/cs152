%{
	#include <stdio.h>
	#include <stdlib.h>
	void yyerror(const char *message);
%}

%union{
	int intval;
	bool boolval;
	char* stringval;
	char* idval;
	char* outputval;
}


%error-verbose
%start input
%token <intval> NUMBER
%token <idval> IDENT
%token SEMICOLON BEGINPROGRAM ENDPROGRAM ASSIGN L_PAREN R_PAREN COLON
%token INTEGER PROGRAM
%token ARRAY OF IF THEN ENDIF ELSE ELSEIF WHILE DO BEGINLOOP BREAK CONTINUE
%token EXIT READ WRITE 
%token COMMA QUESTION TRUE FALSE
%left AND OR NOT EQ NEQ LT GT LTE GTE
%left PLUS MINUS
%left MULT DIV
%left MOD

%type <boolval> bool_exp relation_and_exp relation_exp comp
%type <outputval> block 
%type <outputval> multiplicative_exp
%type <intval> expression
%type <outputval> program statement declaration
%type <outputval> var term

%%

expression : NUMBER {$$ = $1;} ;