all: main

main: mfpl_parser

lex.tab.c:
	bison mfpl.y
	lex mfpl.l

mfpl_parser: lex.tab.c
	g++ -g -static mfpl.tab.c -o mfpl_parser

clean: 
	rm *.tab.c *.yy.c mfpl_parser &> /dev/null | :
