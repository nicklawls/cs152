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
%left ADD 
%left SUB
%left MULT 
%left DIV
%left MOD



%type <intval> expression
%type <intval> var term
%type <intval> m_exp comp_exp relation_exp 
%type <intval> relation_and_exp bool_exp
%type <stringval> statement var_list stmt_list
%type <stringval> block decl_list id_list
%type <stringval> Program declaration



%%
input : Program {printf("input -> Program\n")}
      ;

Program : PROGRAM IDENT SEMICOLON block END_PROGRAM {
            printf("Program -> program ident ; block endprogram\n");
        }
        ;

block : decl_list BEGIN_PROGRAM stmt_list {printf("block -> decl_list beginprogram stmt_list\n")}
      ;

decl_list : declaration SEMICOLON {printf("decl_list -> declaration ;\n")}
          | declaration SEMICOLON decl_list {printf("decl_list -> declaration ; decl_list\n")}
          ;

declaration : id_list COLON INTEGER {printf("declaration -> id_list : integer\n")}
            | id_list COLON ARRAY L_BRACKET NUMBER R_BRACKET OF INTEGER {
                printf("declaration -> id_list : array [number] of integer\n")
            }
            ;

id_list : IDENT {printf("id_list -> ident\n")}
        | IDENT COMMA id_list {printf("id_list -> ident, id_list\n")}
        ;

elif_list : ELSEIF bool_exp stmt_list {printf("elif_list -> elseif bool_exp stmt_list\n")}
          | ELSEIF bool_exp stmt_list elif_list {
                printf("elif_list -> elseif bool_exp stmt_list elif_list\n");
          }
          ;

stmt_list : statement SEMICOLON {printf("stmt_list -> statement;\n")}
          | statement SEMICOLON stmt_list {printf("stmt_list -> statement; stmt_list\n")}
          ;

var_list : var {printf("var_list -> var\n")}
         | var COMMA var_list {printf("var_list -> var, var_list\n")}
         ;

statement : EXIT {printf("statement -> exit\n")}
          | CONTINUE {printf("statement -> continue\n")}
          | BREAK {printf("statement -> break\n")}
          | READ var_list {printf("statement -> read var_list\n")}
          | WRITE var_list {printf("statement -> write var_list\n")}
          | DO BEGINLOOP stmt_list ENDLOOP WHILE bool_exp {
                printf("statement -> do beginloop stmt_list endloop while bool_exp\n");
          }
          | WHILE bool_exp BEGINLOOP stmt_list ENDLOOP {
                printf("statement -> while bool_exp beginloop stmt_list endloop\n");
          }
          | var ASSIGN expression {printf("statement -> var := expression\n")}
          | var ASSIGN bool_exp QUESTION expression COLON expression {
                printf("statement -> var := bool_exp ? expression : expression\n");
          }
          | IF bool_exp THEN stmt_list ENDIF {
                printf("statement -> if bool_exp then stmt_list endif\n");
          }
          | IF bool_exp THEN stmt_list ELSE stmt_list ENDIF {
                printf("statement -> if bool_exp then stmt_list else stmt_list endif\n");
          }
          | IF bool_exp THEN stmt_list elif_list ENDIF {
                printf("statement -> if bool_exp then stmt_list elif_list endif\n");
          }
          | IF bool_exp THEN stmt_list elif_list ELSE stmt_list ENDIF {
                printf("statement -> if bool_exp then stmt_list elif_list else stmt_list endif\n");
          }
          ;

bool_exp : relation_and_exp {$$ = $1; printf("bool_exp -> relation_and_exp\n")}
         | relation_and_exp OR bool_exp {
            $$ = $1 || $3; 
            printf("relation_and_exp -> relation_exp AND relation_and_exp\n");
         }
         ;

relation_and_exp : relation_exp {$$ = $1; printf("relation_and_exp -> relation_exp\n")}
                 | relation_exp AND relation_and_exp {
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
      | m_exp MULT term {$$ = $1 * $3; printf("multiplicative_exp -> multiplicative_exp * term\n")}
      | m_exp DIV term {/*$$ = $1 / $3*/; printf("multiplicative_exp -> multiplicative_exp / term\n")} // willdly unsafe
      | m_exp MOD term {$$ = $1 % $3; printf("multiplicative_exp -> multiplicative_exp modulo term\n")}
      ;

expression : m_exp {$$ = $1; printf("expression -> multiplicative_exp\n")}
           | expression ADD m_exp {$$ = ($1 + $3); printf("expression -> expression + multiplicative_exp\n")}
           | expression SUB m_exp {$$ = ($1 - $3); printf("expression -> expression - multiplicative_exp\n")}
           ;

/* will need symbol table lookups on $$ for this one */
/* stubbing with 0 for now */

var : IDENT L_BRACKET expression R_BRACKET {
        $$ = 0; 
        printf("var -> ident[expression]\n")
    }

    | IDENT {
        $$ = 0; 
        printf("var -> ident %s\n", $1); // not printing $1 for some reason
    }
    ;

term : SUB term {$$ = -1 * $2;  printf("term -> SUB term\n");}
     | var {$$ = $1; printf("term -> var \n")}
     | NUMBER {$$ = $1; printf("term -> NUMBER \n")}
     | L_PAREN expression R_PAREN {$$ = $2; printf("term -> (expression)\n")}
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