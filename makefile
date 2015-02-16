all: build

update:
	git pull
	touch *

push:
	git commit -am "automated commit"
	git push

run: 
	./lexer

test: 
	./test_lexer.sh

bisonfile: mini_l.y
	bison -v -d --file-prefix=y mini_l.y

parser: flexfile
	gcc -o parser y.tab.c lex.yy.c -lfl

build: update parser 

flexfile: bisonfile mini_l.lex y.tab.h
	flex mini_l.lex

clean:
	rm -rf *.c *.h *.o parser
