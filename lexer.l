%{
/* Newlines in the input will be output under default rule, readability hack */
#include <stdio.h>
#include <stdlib.h>

const char reserved_words[][] = {"program", "beginprogram", "endprogram"}; // array search in identifier action
const char reserved_tokens[][] = {"PROGRAM", "BEGIN_PROGRAM", "END PROGRAM"}; // token output
size_t keywords = 25;
%}

ARITHMETIC [-+*/%]

COMPARISON (==|<>|<|>|<=|>=)

DIGIT [0-9]

NUMBER {DIGIT}+

LETTER [A-z]

IDENTIFIER {LETTER}({LETTER}|{DIGIT})*(_*(LETTER|DIGIT)+)*

SPECIAL [;:,?\[\]()](:=) 

UNIDENTIFIED .
/*INVALID_IDENT*/
%%
{NUMBER} {printf("NUMBER %s/n", atoi(yytext));}

{COMPARISON}|{ARITHMETIC}|{SPECIAL} {
	
}



{IDENTIFIER} {
	int i = 0;
	for (i; i < keywords; ++i) {
		if (*yytext == reserved_words[i]) {
			printf("%s\n", reserved_tokens[i]);
			break;
		} 
	} 
	
	if (i == keywords) {
		printf("IDENT %s\n", yytext);
	}
}

[ \t\n] /* consume whitespace */
%%


