all: lexer

run: lexer
	./lexer

test: lexer
	./test_lexer.sh

lexer: lex.yy.c
	gcc -o lexer lex.yy.c -lfl

lex.yy.c: mini_l.lex
	flex mini_l.lex

clean:
	rm -rf *.c lexer
