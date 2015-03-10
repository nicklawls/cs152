%{
	#include <stdio.h>
	#include <stdlib.h>
  #include "symbol_table.h"
  #include "codegen.h"
	void yyerror(const char *message);
  extern int yylineno;
  extern int yycolumno;
  FILE* yyin;
  int verbose = 0;
%}

%union{
	int intval;
  char* strval;
  struct expr {
    char place[8];
    char code[16384];
    } expr;
  struct stmt {
    char begin[16];
    char code[16384];
    char after[256];
    } stmt; 
  struct strlist {
    char list[256][256];
    int length;
  } strlist;

}


%error-verbose
%start input
%token <intval> NUMBER
%token <strval> IDENT
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



%type <expr> expression
%type <expr> term termA
%type <expr> m_exp relation_exp relation_expA
%type <expr> relation_and_exp bool_exp 
%type <strval> comp var  
%type <strlist> var_list stmt_list decl_list id_list
%type <stmt> statement 
%type <stmt> block  
%type <stmt> Program declaration



%%
input : Program {
          // iterate over symbol table and generate init statements, save into buffer
          // concat buffer with Program.code
          if (verbose) {printf("input -> Program\n");}
        }
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

bool_exp : relation_and_exp {
            strcpy($$.place, $1.place);
            strcpy($$.code, $1.code);
            if (verbose) {printf("bool_exp -> relation_and_exp\n");}
           }
         | bool_exp OR relation_and_exp {
            newtemp($$.place);

            char quad[16];
            gen4(quad, "||", $$.place, $1.place, $3.place);

            strcpy($$.code, $1.code);
            strcat($$.code, $3.code);
            strcat($$.code, quad);
            if (verbose) {printf("bool_exp -> bool_exp OR relation_and_exp\n");}
           }
         ;

relation_and_exp : relation_exp {
                    strcpy($$.place, $1.place);
                    strcpy($$.code, $1.code);
                    if (verbose) {printf("relation_and_exp -> relation_exp\n");}
                   }
                 | relation_and_exp AND relation_exp {
                    newtemp($$.place);

                    char quad[16];
                    gen4(quad, "&&", $$.place, $1.place, $3.place);

                    strcpy($$.code, $1.code);
                    strcat($$.code, $3.code);
                    strcat($$.code, quad);

                    if (verbose) {printf("relation_and_exp -> relation_and_exp AND relation_exp\n");}
                   }
                 ;

relation_expA : expression comp expression {
                  newtemp($$.place);

                  char quad[16];
                  gen4(quad, $2, $$.place, $1.place, $3.place);

                  strcpy($$.code, $1.code);
                  strcat($$.code, $3.code);
                  strcat($$.code, quad);

                  if (verbose) {printf("relation_exp' -> expression comp expression\n");}
                }
              | TRUE {
                  newtemp($$.place);
                  gen3i($$.code, "=", $$.place, 1);
                  if (verbose) {printf("relation_exp' -> TRUE\n");}
                }
              | FALSE { 
                newtemp($$.place);
                gen3i($$.code, "=", $$.place, 0);
                if (verbose) {printf("relation_exp' -> FALSE\n");}
              }
              | L_PAREN bool_exp R_PAREN { 
                  strcpy($$.place, $2.place);
                  strcpy($$.code, $2.code);
                  if (verbose) {printf("relation_exp' -> (bool_exp)\n");}
                }
              ;

relation_exp : NOT relation_expA { 
                strcpy($$.place, $2.place);
                strcpy($$.code, $2.code);
                
                char signswitch[16];
                gen3(signswitch, "!", $$.place, $$.place);
                
                strcat($$.code, signswitch);

                if (verbose) {printf("relation_exp -> not relation_exp'\n");}
               }
             | relation_expA {
                strcpy($$.place, $1.place);
                strcpy($$.code, $1.code);
                if (verbose) {printf("relation_exp -> relation_exp'\n");}
               }
             ;

comp : EQ  {$$ = "=="; if (verbose) {printf("comp -> ==\n");}}
     | NEQ {$$ = "!="; if (verbose) {printf("comp -> <>\n");}}
     | LTE {$$ = "<="; if (verbose) {printf("comp -> <=\n");}}
     | GTE {$$ = ">="; if (verbose) {printf("comp -> >=\n");}}
     | LT  {$$ = "<"; if (verbose) {printf("comp-> < \n");}}
     | GT  {$$ = ">"; if (verbose) {printf("comp-> > \n");}}
     ;

m_exp : term { 
          strcpy($$.place, $1.place);
          strcpy($$.code, $1.code);
          if (verbose) {printf("multiplicative_exp -> term\n");}
        }
      | m_exp MULT term { 
          newtemp($$.place);
          char quad[16];
          gen4(quad, "*", $$.place, $1.place, $3.place);
          
          strcpy($$.code, $1.code);
          strcat($$.code, $3.code);
          strcat($$.code, quad);

          if (verbose) {printf("multiplicative_exp -> multiplicative_exp * term\n");}
        }
      | m_exp DIV term { 
          newtemp($$.place);
          char quad[16];
          gen4(quad, "/", $$.place, $1.place, $3.place);
          
          strcpy($$.code, $1.code);
          strcat($$.code, $3.code);
          strcat($$.code, quad);
          if (verbose) {printf("multiplicative_exp -> multiplicative_exp / term\n");}
        }
      | m_exp MOD term { 
          newtemp($$.place);
          char quad[16];
          gen4(quad, "%", $$.place, $1.place, $3.place);
          
          strcpy($$.code, $1.code);
          strcat($$.code, $3.code);
          strcat($$.code, quad);
          if (verbose) {printf("multiplicative_exp -> multiplicative_exp modulo term\n");}
        }
      ;

expression : m_exp { 
              strcpy($$.place, $1.place);
              strcpy($$.code, $1.code);
              if (verbose) {printf("expression -> multiplicative_exp\n");}
             }
           | expression ADD m_exp {
              newtemp($$.place);

              char quad[16];
              gen4(quad, "+", $$.place, $1.place, $3.place); 

              strcpy($$.code, $1.code);
              strcat($$.code, $3.code);
              strcat($$.code, quad);
              if (verbose) {printf("expression -> expression + multiplicative_exp\n");}
             }
           | expression SUB m_exp {
                newtemp($$.place);
                
                char quad[16];
                gen4(quad, "-", $$.place, $1.place, $3.place); 

                strcpy($$.code, $1.code);
                strcat($$.code, $3.code);
                strcat($$.code, quad);
                if (verbose) {printf("expression -> expression - multiplicative_exp\n");}
             }
           ;


var : IDENT L_BRACKET expression R_BRACKET {
        // name and type will already be in symtab, pass (name,index) along as string
        sprintf($$, "%s,%s", $1, $3.place); // id, index
        if (verbose) {printf("var -> ident[expression]\n");}
      }

    | IDENT {
        // name and type will already be in symtab, pass name along
        strcpy($$, $1);
        printf("%s\n",$$); // id
        if (verbose) {printf("var -> ident %s\n", $1);} // not printing $1 for some reason
      }
    ;

term : SUB termA {
          strcpy($$.place, $2.place);
          // code to calculate the term plus `concat` sign switch
          strcpy($$.code, $2.code);
          char signswitch[16];
          gen4i(signswitch, "*", $$.place, $$.place, -1);
          strcat($$.code, signswitch);

          if (verbose) {printf("term -> SUB term'\n");}
       }
     | termA {
          strcpy($$.place, $1.place);
          strcpy($$.code, $1.code);
          if (verbose) {printf("term -> term'\n");}
       }
     ;

termA : var { // when var becomes a term, we only want the value currently in it
          int index = symtab_get($$)
          // handle both the int and array cases
          if (index) {
            if (symtab_entry_is_int(index)) {
              // avoid making new temp since variable already declared
              strcpy($$.place,$1);
              strcpy($$.code,"");
            } else {
              // newtemp to extract value at index
              newtemp($$.place);
              gen3($$.code, "=[]", $$.place, $1 ); // $1 has "name,index"
            }
          } else {
            // handle error
          }

          if (verbose) {printf("term' -> var \n");}
        }
      | NUMBER {
          int imm = $1;
          newtemp($$.place);
          gen3i($$.code, "=", $$.place, imm);
          //printf("%s", $$.code);
          if (verbose) {printf("term' -> NUMBER \n");}
        }
      | L_PAREN expression R_PAREN {
          strcpy($$.place, $2.place);
          strcpy($$.code,$2.code);
          if (verbose) {printf("term' -> (expression)\n");}
        }
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
  // symtab_init(&symtab);
  // printf("%i\n", symtab.initialized);
  // printf("%i\n", symtab.length);

  yyparse();
  return 0; 
}

void yyerror(const char* msg) {
    printf("** Line %d, position %d: %s\n", yylineno, yycolumno, msg);  
}
