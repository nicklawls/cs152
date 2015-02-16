all: build

update:
	git pull

run: 
	./lexer

test: 
	./test_lexer.sh

bisonfile: mini_l.y
	bison -v -d --file-prefix=y mini_l.y

lexer: flexfile
	gcc -o lexer lex.yy.c -lfl

build: update lexer 

flexfile: mini_l.lex
	flex mini_l.lex

clean:
	rm -rf *.c *.h lexer
