%{
	#include <stdio.h>
	#include <stdlib.h>
	void yyerror(const char *message);
    extern int yylineno;
    extern int yycolumno;
    FILE* yyin;
%}

%union{
	int intval;
    double floatval;
    
    int* intarrayval;
    double* doublearrayval;
	
    char* stringval;
}


%error-verbose
%start input
%token <intval> NUMBER
%token <stringval> IDENT
%token SEMICOLON BEGIN_PROGRAM END_PROGRAM ASSIGN L_PAREN R_PAREN COLON
%token INTEGER PROGRAM L_BRACKET R_BRACKET
%token ARRAY OF IF THEN ENDIF ELSE ELSEIF WHILE DO BEGINLOOP BREAK CONTINUE ENDLOOP
%token EXIT READ WRITE 
%token COMMA QUESTION TRUE FALSE
%left AND OR NOT EQ NEQ LT GT LTE GTE
%left ADD SUB
%left MULT DIV
%left MOD



%type <intval> expression
%type <intval> var term

/*
%type <intval> bool_exp relation_and_exp relation_exp comp
%type <stringval> block 
%type <stringval> multiplicative_exp
%type <stringval> program statement declaration

*/

%%

input : term {printf("input -> term\n")}
      /* | term {printf("input -> term\n")}
      | var {printf("input -> var\n")} */
      ;

expression : NUMBER {$$ = $1; printf("expression -> number %i\n", $$)};

var : IDENT {$$ = $1; printf("var -> ident %s\n", $$)}
    | IDENT L_BRACKET expression R_BRACKET {
        $$ = $1; 
        printf("var -> ident[expression] %s[%i]\n", $$,$3)
    }
    ;

term : SUB term {$$ = -1 * $2;  printf("term -> SUB term %s\n", $$);}
     | var {$$ = $1; printf("term -> var %s\n", $$)}
     | NUMBER {$$ = $1; printf("term -> NUMBER %s\n", $$)}
     | L_PAREN expression R_PAREN {$$ = $2; printf("term -> (expression) (%s)\n", $$)}
     ;

%%

int main (const int argc, const char** argv) {

    if (argc > 1) {
        yyin = fopen(argv[1], "r");
        if (yyin == NULL) {
            printf("syntax: %s filename\n", argv[0]);
            exit(1);
        }
    }
    yyparse();
    return 0;
}

void yyerror(const char* msg) {
    printf("** Line %d, position %d: %s\n", yylineno, yycolumno, msg);
}