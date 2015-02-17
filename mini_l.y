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
%type <intval> m_exp comp_exp relation_exp 
%type <intval> relation_and_exp bool_exp

/*

%type <stringval> block 

%type <stringval> program statement declaration

*/

%%

input : var {printf("input -> var\n")}
      /* | term {printf("input -> term\n")}
      | var {printf("input -> var\n")} */
      ;

bool_exp : relation_and_exp {$$ = $1; printf("bool_exp -> relation_and_exp\n")}
         | relation_and_exp OR bool_exp {
            $$ = $1 || $3; 
            printf("relation_and_exp -> relation_exp AND relation_and_exp\n");
         }
         ;

relation_and_exp : relation_exp {$$ = $1; printf("relation_and_exp -> relation_exp\n")}
                 | relation_exp AND relation_exp {
                    $$ = $1 && $3; 
                    printf("relation_and_exp -> relation_exp AND relation_and_exp\n");
                 }
                 ;

relation_exp : comp_exp {$$ = $1; printf("relation_exp -> comp_exp\n")}
             | TRUE {$$ = 1; printf("relation_exp -> TRUE\n")}
             | FALSE {$$ = 0; printf("relation_exp -> FALSE\n")}
             | L_PAREN bool_exp R_PAREN {$$ = $2; printf("relation_exp -> (bool_exp)\n")}
             | NOT relation_exp {$$ = $2 >= 1 ? 0 : 1; printf("relation_exp -> not relation_exp\n")}
             ;

comp_exp : expression EQ expression {$$ = ($1 == $3); printf("comp_exp -> expression == expression\n")}
         | expression NEQ expression {$$ = ($1 != $3); printf("comp_exp -> expression <> expression\n")}
         | expression LTE expression {$$ = ($1 <= $3); printf("comp_exp -> expression <= expression\n")}
         | expression GTE expression {$$ = ($1 >= $3); printf("comp_exp -> expression >= expression\n")}
         | expression LT expression {$$ = ($1 < $3); printf("comp_exp -> expression < expression\n")}
         | expression GT expression {$$ = ($1 > $3); printf("comp_exp -> expression > expression\n")}
         ;

m_exp : term {$$ = $1; printf("multiplicative_exp -> term\n")}
      | term MULT term {$$ = $1 * $3; printf("multiplicative_exp -> term * term\n")}
      | term DIV term {$$ = $1 / $3; printf("multiplicative_exp -> term / term\n")} // willdly unsafe
      | term MOD term {$$ = $1 % $3; printf("multiplicative_exp -> term % term\n")}
      ;

expression : m_exp {$$ = $1; printf("expression -> multiplicative_exp %i\n", $$)}
           | m_exp ADD m_exp {$$ = ($1 + $3); printf("expression -> multiplicative_exp + multiplicative_exp %i\n")}
           | m_exp SUB m_exp {$$ = ($1 - $3); printf("expression -> multiplicative_exp - multiplicative_exp %i\n")}
           ;

/* will need symbol table lookups on $$ for this one */
/* stubbing with 0 for now */

var : IDENT L_BRACKET expression R_BRACKET {
        $$ = 0; 
        printf("var -> ident[expression](%s)\n", $1)
    }

    | IDENT {
        printf("var -> ident(%s)\n", $1); // not printing $1 for some reason
        $$ = 0; 
    }

    ;

term : SUB term {$$ = -1 * $2;  printf("term -> SUB term %i\n", $$);}
     | var {$$ = $1; printf("term -> var %i\n", $$)}
     | NUMBER {$$ = $1; printf("term -> NUMBER %i\n", $$)}
     | L_PAREN expression R_PAREN {$$ = $2; printf("term -> (expression) (%i)\n", $$)}
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