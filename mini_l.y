%{
	#include <stdio.h>
	#include <stdlib.h>
  #include "symbol_table.h"
	void yyerror(const char *message);
  extern int yylineno;
  extern int yycolumno;
  FILE* yyin;
  int verbose = 1;

  struct symbol_table symtab;
  
%}

%union{
  int* mem;
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
%type <intval> term termA
%type <intval> m_exp relation_exp relation_expA
%type <intval> relation_and_exp bool_exp
%type <stringval> comp statement var_list stmt_list 
%type <mem> var
%type <stringval> block decl_list id_list
%type <stringval> Program declaration



%%
input : Program {if (verbose) {printf("input -> Program\n");}}
      ;

Program : PROGRAM IDENT SEMICOLON block END_PROGRAM {
            if (verbose) {printf("Program -> program ident ; block endprogram\n");}
        }
        ;

block : decl_list BEGIN_PROGRAM stmt_list {if (verbose) {printf("block -> decl_list beginprogram stmt_list\n");}}
      ;

decl_list : declaration SEMICOLON {if (verbose) {printf("decl_list -> declaration ;\n");}}
          | declaration SEMICOLON decl_list {if (verbose) {printf("decl_list -> declaration ; decl_list\n");}}
          ;

declaration : id_list COLON INTEGER {if (verbose) {printf("declaration -> id_list : integer\n");}}
            | id_list COLON ARRAY L_BRACKET NUMBER R_BRACKET OF INTEGER {
                if (verbose) {printf("declaration -> id_list : array [number] of integer\n");}
            }
            ;

id_list : IDENT {if (verbose) {printf("id_list -> ident\n");}}
        | IDENT COMMA id_list {if (verbose) {printf("id_list -> ident, id_list\n");}}
        ;

elif_list : ELSEIF bool_exp stmt_list {if (verbose) {printf("elif_list -> elseif bool_exp stmt_list\n");}}
          | ELSEIF bool_exp stmt_list elif_list {
                if (verbose) {printf("elif_list -> elseif bool_exp stmt_list elif_list\n");}
          }
          ;

stmt_list : statement SEMICOLON {if (verbose) {printf("stmt_list -> statement;\n");}}
          | statement SEMICOLON stmt_list {if (verbose) {printf("stmt_list -> statement; stmt_list\n");}}
          ;

var_list : var {if (verbose) {printf("var_list -> var\n");}}
         | var COMMA var_list {if (verbose) {printf("var_list -> var, var_list\n");}}
         ;

statement : EXIT {if (verbose) {printf("statement -> exit\n");}}
          | CONTINUE {if (verbose) {printf("statement -> continue\n");}}
          | BREAK {if (verbose) {printf("statement -> break\n");}}
          | READ var_list {if (verbose) {printf("statement -> read var_list\n");}}
          | WRITE var_list {if (verbose) {printf("statement -> write var_list\n");}}
          | DO BEGINLOOP stmt_list ENDLOOP WHILE bool_exp {
                if (verbose) {printf("statement -> do beginloop stmt_list endloop while bool_exp\n");}
          }
          | WHILE bool_exp BEGINLOOP stmt_list ENDLOOP {
                if (verbose) {printf("statement -> while bool_exp beginloop stmt_list endloop\n");}
          }
          | var ASSIGN expression {if (verbose) {printf("statement -> var := expression\n");}}
          | var ASSIGN bool_exp QUESTION expression COLON expression {
                if (verbose) {printf("statement -> var := bool_exp ? expression : expression\n");}
          }
          | IF bool_exp THEN stmt_list ENDIF {
                if (verbose) {printf("statement -> if bool_exp then stmt_list endif\n");}
          }
          | IF bool_exp THEN stmt_list ELSE stmt_list ENDIF {
                if (verbose) {printf("statement -> if bool_exp then stmt_list else stmt_list endif\n");}
          }
          | IF bool_exp THEN stmt_list elif_list ENDIF {
                if (verbose) {printf("statement -> if bool_exp then stmt_list elif_list endif\n");}
          }
          | IF bool_exp THEN stmt_list elif_list ELSE stmt_list ENDIF {
                if (verbose) {printf("statement -> if bool_exp then stmt_list elif_list else stmt_list endif\n");}
          }
          ;

bool_exp : relation_and_exp {$$ = $1; if (verbose) {printf("bool_exp -> relation_and_exp\n");}}
         | bool_exp OR relation_and_exp {
            $$ = $1 || $3; 
            if (verbose) {printf("bool_exp -> bool_exp OR relation_and_exp\n");}
         }
         ;

relation_and_exp : relation_exp {$$ = $1; if (verbose) {printf("relation_and_exp -> relation_exp\n");}}
                 | relation_and_exp AND relation_exp {
                    $$ = $1 && $3; 
                    if (verbose) {printf("relation_and_exp -> relation_and_exp AND relation_exp\n");}
                 }
                 ;

relation_expA : expression comp expression {if (verbose) {printf("relation_exp' -> expression comp expression\n");}}
              | TRUE {$$ = 1; if (verbose) {printf("relation_exp' -> TRUE\n");}}
              | FALSE {$$ = 0; if (verbose) {printf("relation_exp' -> FALSE\n");}}
              | L_PAREN bool_exp R_PAREN {$$ = $2; if (verbose) {printf("relation_exp' -> (bool_exp)\n");}}
              ;

relation_exp : NOT relation_expA {$$ = $2 >= 1 ? 0 : 1; if (verbose) {printf("relation_exp -> not relation_exp'\n");}}
             | relation_expA {if (verbose) {printf("relation_exp -> relation_exp'\n");}}
             ;

comp : EQ  {$$ = "=="; if (verbose) {printf("comp -> ==\n");}}
     | NEQ {$$ = "!="; if (verbose) {printf("comp -> <>\n");}}
     | LTE {$$ = "<="; if (verbose) {printf("comp -> <=\n");}}
     | GTE {$$ = ">="; if (verbose) {printf("comp -> >=\n");}}
     | LT  {$$ = "<"; if (verbose) {printf("comp-> < \n");}}
     | GT  {$$ = ">"; if (verbose) {printf("comp-> > \n");}}
     ;

m_exp : term {$$ = $1; if (verbose) {printf("multiplicative_exp -> term\n");}}
      | m_exp MULT term {$$ = $1 * $3; if (verbose) {printf("multiplicative_exp -> multiplicative_exp * term\n");}}
      | m_exp DIV term {/*$$ = $1 / $3*/; if (verbose) {printf("multiplicative_exp -> multiplicative_exp / term\n");}} // willdly unsafe
      | m_exp MOD term {$$ = $1 % $3; if (verbose) {printf("multiplicative_exp -> multiplicative_exp modulo term\n");}}
      ;

expression : m_exp {$$ = $1; if (verbose) {printf("expression -> multiplicative_exp\n");}}
           | expression ADD m_exp {$$ = ($1 + $3); if (verbose) {printf("expression -> expression + multiplicative_exp\n");}}
           | expression SUB m_exp {$$ = ($1 - $3); if (verbose) {printf("expression -> expression - multiplicative_exp\n");}}
           ;

/* will need symbol table lookups on $$ for this one */
/* stubbing with 0 for now */

var : IDENT L_BRACKET expression R_BRACKET {
        // $$ = address of lookup(key=$1, offset=$3)
        if (verbose) {printf("var -> ident[expression]\n");}
    }

    | IDENT {
        $$ = strdup($1); 
        if (verbose) {printf("var -> ident %s\n", $1);} // not printing $1 for some reason
    }
    ;

term : SUB termA {$$ = -1 * $2;  if (verbose) {printf("term -> SUB term'\n");}}
     | termA {$$ = $1;  if (verbose) {printf("term -> term'\n");}}
     ;

termA : var {$$ = 15; if (verbose) {printf("term' -> var \n");}}
      | NUMBER {$$ = $1; if (verbose) {printf("term' -> NUMBER \n");}}
      | L_PAREN expression R_PAREN {$$ = $2; if (verbose) {printf("term' -> (expression)\n");}}
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
  symtab_init(symtab);
  printf("%i %i", symtab.initialized, symtab.length);

  yyparse();
  return 0;
}

void yyerror(const char* msg) {
    printf("** Line %d, position %d: %s\n", yylineno, yycolumno, msg);
}