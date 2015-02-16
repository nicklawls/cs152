## Nicolas Lawler
## CS152
## Project Phase 1: Lexer

On bell/well, the follwing commands to `make` should work:

* `make all` will build the lexer
* `make run` will build the lexer and run it in interactive mode
* `make test` will build the lexer and run the *test_lexer.sh* script, which 
`cat`'s the provided .min files into the lexer and `diff`'s the output against 
the provided .tokens files. **A successful test run will have no output**
* `make clean` deletes the lexer executable and .c file generated by `flex`