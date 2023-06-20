##################################################################
#
#	Makefile -- P Parser
#
##################################################################
YACCFILE = 'parser.y'
LEXFILE = 'scanner.l'

OUTPUT_FILENAME = 'a.out'
INPUT_FILENAME = 'testinputfile.txt'


all:
	make clean

	make lex.yy.c

	make y.tab.c_y.tab.h

	make lex.yy.o

	make y.tab.o

	gcc -g -w lex.yy.o y.tab.o $(OTHER_SOURCE) -o $(OUTPUT_FILENAME)
	cat $(INPUT_FILENAME) |./a.out 
lex.yy.c:
	lex $(LEXFILE)
	#generate lex.yy.c

y.tab.c_y.tab.h:
	yacc -d $(YACCFILE)
	#generate y.tab.c and y.tab.h


lex.yy.o:
	gcc -g -c -w lex.yy.c
	#generate lex.yy.o


y.tab.o:
	gcc -g -c -w y.tab.c 
	#generate y.tab.o


run:
	./a.out $(INPUT_FILENAME)

clean:
	rm -f p *.o lex.yy.* y.tab.* a.out
