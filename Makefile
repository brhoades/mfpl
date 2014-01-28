all: main

main: lex.yy.c a.out

lex.yy.c: mfpl.l
	lex mfpl.l

a.out: lex.yy.c
	g++ lex.yy.c

