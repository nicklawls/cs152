all: lexer

lexer: lex.yy.c
	gcc -o lexer lex.yy.c -lfl

lex.yy.c: mini_l.lex
	flex mini_l.lex

clean:
	rm -rf *.c lexer *.tokens
