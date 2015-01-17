all: build

update:
	git pull

run: 
	./lexer

test: 
	./test_lexer.sh

lexer: lex.yy.c
	gcc -o lexer lex.yy.c -lfl

build: update lexer 

lex.yy.c: mini_l.lex
	flex mini_l.lex

clean:
	rm -rf *.c lexer
