all: main

main: lex.yy.c mfpl_lexer

lex.yy.c: mfpl.l
	lex mfpl.l

mfpl_lexer: lex.yy.c
	g++ lex.yy.c -o mfpl_lexer


