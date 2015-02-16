%option yylineno
%{
#include <stdio.h>
#include <stdlib.h>
#include "y.tab.h"
const char *reserved_words[] = {"and","array","beginloop","beginprogram","break","continue","do","else","elseif","endif","endloop","endprogram","exit","false","if","integer","not","of","or","program","read","then","true","while","write"};
YYSTYPE reserved_tokens[] = {AND,ARRAY,BEGINLOOP,BEGIN_PROGRAM,BREAK,CONTINUE,DO,ELSE,ELSEIF,ENDIF,ENDLOOP,END_PROGRAM,EXIT,FALSE,IF,INTEGER,NOT,OF,OR,PROGRAM,READ,THEN,TRUE,WHILE,WRITE};
size_t keywords = 25;
int yycolumno = 0;
%}

NEWLINE \n

COMMENT ##.*

WHITESPACE [ \t]

ARITHMETIC [-+*/%]

COMPARISON ==|<>|<|>|<=|>=

DIGIT [0-9]

NUMBER [1-9]{DIGIT}*

LETTER [A-Z]|[a-z]

IDENTIFIER ({LETTER})({LETTER}|{DIGIT})*(_*({LETTER}|{DIGIT})+)*

SPECIAL [;:,?\[\]\(\)]|(:=) 

UNIDENTIFIED .

INVALID_IDENT {DIGIT}+{IDENTIFIER}_*|{DIGIT}*{IDENTIFIER}_+
%%
{NEWLINE} {yycolumno = 0;}

{NUMBER} {
	yycolumno += yyleng;
	printf("NUMBER %s\n", yytext);
	yylval.intval = atoi(yytext);
	return NUMBER;
}

{COMPARISON} {
	yycolumno += yyleng;
	yylval.stringval = yytext;

	if (!strcmp(yytext, "==") ) {
		printf("EQ\n");
		return EQ;
	} else if (!strcmp(yytext, "<>") ) {
		printf("NEQ\n");
		return NEQ;
	} else if (!strcmp(yytext, ">") ) {
		printf("GT\n");
		return GT;
	} else if (!strcmp(yytext, "<") ) {
		printf("LT\n");
		return LT;
	} else if (!strcmp(yytext, "<=") ) {
		printf("LTE\n");
		return LTE;
	} else if (!strcmp(yytext, ">=") ) {
		printf("GTE\n");
		return GTE;
	} else {
		printf("Invalid comparison operator\n");
		exit(1);
	}
}

{ARITHMETIC} {
	yycolumno += yyleng;
	yylval.stringval = yytext;

	if (!strcmp(yytext, "-") ) {
		printf("SUB\n");
		return SUB;
	} else if (!strcmp(yytext, "+") ) {
		printf("ADD\n");
		return ADD;
	} else if (!strcmp(yytext, "*") ) {
		printf("MULT\n");
		return MULT;
	} else if (!strcmp(yytext, "/") ) {
		printf("DIV\n");
		return DIV;
	} else if (!strcmp(yytext, "%") ) {
		printf("MOD\n");
		return MOD;
	} else {
		printf("invalid arithmetic operator\n");
		exit(1);
	}
}

{SPECIAL} {
	yycolumno += yyleng;
	yylval.stringval = yytext;

	if (!strcmp(yytext, ";") ) {
		printf("SEMICOLON\n");
		return SEMICOLON;
	} else if (!strcmp(yytext, ":") ) {
		printf("COLON\n");
		return COLON;
	} else if (!strcmp(yytext, ",") ) {
		printf("COMMA\n");
		return COMMA;
	} else if (!strcmp(yytext, "?") ) {
		printf("QUESTION\n");
		return QUESTION;
	} else if (!strcmp(yytext, "[") ) {
		printf("L_BRACKET\n");
		return L_BRACKET;
	} else if (!strcmp(yytext, "]") ) {
		printf("R_BRACKET\n");
		return R_BRACKET;
	} else if (!strcmp(yytext, "(") ) {
		printf("L_PAREN\n");
		return L_PAREN;
	} else if (!strcmp(yytext, ")") ) {
		printf("R_PAREN\n");
		return R_PAREN;
	} else if (!strcmp(yytext, ":=") ) {
		printf("ASSIGN\n");
		return ASSIGN;
	} else {
		printf("invalid special character\n");
		exit(1);
	}
}

{IDENTIFIER} {
	yycolumno += yyleng;
	int i;
	for (i = 0; i < keywords; i++) {
		if (!strcmp(yytext, reserved_words[i])) {
			// printf("%s\n", reserved_tokens[i]);
			return reserved_tokens[i];
			// break;
		} 
	} 
	
	if (i == keywords) {
		yylval.stringval = yytext;
		return IDENT;
		printf("IDENT %s\n", yytext);
	}
}

{COMMENT}|{WHITESPACE} /* consume whitespace and comments */

{UNIDENTIFIED} {
	printf("Invalid character \"%s\" on line %i, column %i\n", yytext, yylineno, ++yycolumno);
	exit(1);
}

{INVALID_IDENT} {
	printf("Invalid identifier \"%s\" on line %i, column %i\n", yytext, yylineno, ++yycolumno);
	exit(1);
}

%%


