all: build

update:
	git pull

push:
	git commit -am "automated commit"
	git push

run: 
	./parser

test: 
	./test_lexer.sh

bisonfile: mini_l.y
	bison -v -d --file-prefix=y mini_l.y

parser: flexfile
	touch *
	gcc -o parser y.tab.c lex.yy.c -lfl

build: update parser 

flexfile: bisonfile mini_l.lex y.tab.h
	flex mini_l.lex

clean:
	rm -rf *.c *.h *.o *.output parser
