%option yylineno
%{
#include <stdio.h>
#include <stdlib.h>
const char *reserved_words[] = {"and","array","beginloop","beginprogram","break","continue","do","else","elseif","endif","endloop","endprogram","exit","false","if","integer","not","of","or","program","read","then","true","while","write"};
const char *reserved_tokens[] = {"AND","ARRAY","BEGINLOOP","BEGIN_PROGRAM","BREAK","CONTINUE","DO","ELSE","ELSEIF","ENDIF","ENDLOOP","END_PROGRAM","EXIT","FALSE","IF","INTEGER","NOT","OF","OR","PROGRAM","READ","THEN","TRUE","WHILE","WRITE",};
size_t keywords = 25;
int yycolumno = 0;
%}

NEWLINE \n

COMMENT ##.*

WHITESPACE [ \t]

ARITHMETIC [-+*/%]

COMPARISON ==|<>|<|>|<=|>=

DIGIT [0-9]

NUMBER {DIGIT}+

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
}

{COMPARISON} {
	yycolumno += yyleng;
	if (!strcmp(yytext, "==") ) {
		printf("EQ\n");
	} else if (!strcmp(yytext, "<>") ) {
		printf("NEQ\n");
	} else if (!strcmp(yytext, ">") ) {
		printf("GT\n");
	} else if (!strcmp(yytext, "<") ) {
		printf("LT\n");
	} else if (!strcmp(yytext, "<=") ) {
		printf("LTE\n");
	} else if (!strcmp(yytext, ">=") ) {
		printf("GTE\n");
	} else {
		printf("Invalid comparison operator\n");
	}
}

{ARITHMETIC} {
	yycolumno += yyleng;
	if (!strcmp(yytext, "-") ) {
		printf("SUB\n");
	} else if (!strcmp(yytext, "+") ) {
		printf("ADD\n");
	} else if (!strcmp(yytext, "*") ) {
		printf("MULT\n");
	} else if (!strcmp(yytext, "/") ) {
		printf("DIV\n");
	} else if (!strcmp(yytext, "%") ) {
		printf("MOD\n");
	} else {
		printf("invalid arithmetic operator\n");
	}
}

{SPECIAL} {
	yycolumno += yyleng;
	if (!strcmp(yytext, ";") ) {
		printf("SEMICOLON\n");
	} else if (!strcmp(yytext, ":") ) {
		printf("COLON\n");
	} else if (!strcmp(yytext, ",") ) {
		printf("COMMA\n");
	} else if (!strcmp(yytext, "?") ) {
		printf("QUESTION\n");
	} else if (!strcmp(yytext, "[") ) {
		printf("L_BRACKET\n");
	} else if (!strcmp(yytext, "]") ) {
		printf("R_BRACKET\n");
	} else if (!strcmp(yytext, "(") ) {
		printf("L_PAREN\n");
	} else if (!strcmp(yytext, ")") ) {
		printf("R_PAREN\n");
	} else if (!strcmp(yytext, ":=") ) {
		printf("ASSIGN\n");
	} else {
		printf("invalid special character\n");
	}
}

{IDENTIFIER} {
	yycolumno += yyleng;
	int i;
	for (i = 0; i < keywords; i++) {
		if (!strcmp(yytext, reserved_words[i])) {
			printf("%s\n", reserved_tokens[i]);
			break;
		} 
	} 
	
	if (i == keywords) {
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


