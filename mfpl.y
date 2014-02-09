/*
      example.y

        Example of a yacc specification file.

      Grammar is:

        <expr> -> intconst | ident | foo <identList> <intconstList>
        <identList> -> epsilon | <identList> ident
        <intconstList> -> intconst | <intconstList> intconst

      To create the syntax analyzer:

        flex example.l
        bison example.y
        g++ example.tab.c -o parser
        parser < inputFileName
*/

%{
#include <stdio.h>

int numLines = 0; 

void printRule(const char *lhs, const char *rhs);
int yyerror(const char *s);
void printTokenInfo(const char* tokenType, const char* lexeme);

extern "C"
{
  int yyparse(void);
  int yylex(void);
  int yywrap() { return 1; }
}

%}

/* Token declarations */
%token N_EXPR N_CONST T_IDENT T_LPAREN N_PARENTHESIZED_EXPR T_RPAREN
%token T_INTCONST T_STRCONST T_T T_NIL N_ARITHLOGIC_EXPR N_IF_EXPR N_LET_EXPR 
%token N_LAMBDA_EXPR N_PRINT_EXPR N_INPUT_EXPR N_EXPR_LIST N_UN_OP N_BIN_OP 
%token T_LETSTAR N_ID_EXPR_LIST N_ID_LIST T_LAMBDA T_PRINT T_INPUT T_ARITH_OP
%token N_LOG_OP N_REL_OP T_MULTI T_SUB T_DIV T_ADD T_AND T_OR T_LT T_GT T_LE 
%token T_GE T_EQ T_NE T_NOT

/* Translation rules */
%%


/*N_EXPR			: T_INTCONST
                                        {
                                        printRule("EXPR", "INTCONST");
                                        }
                        | T_IDENT
                              {
                                        printRule("EXPR", "IDENT");
                                        }
                        | T_FOO N_IDENT_LIST N_INTCONST_LIST
                              {
                                        printRule("EXPR", 
                                      "foo IDENT_LIST INTCONST_LIST");
                                        }
                                ;
N_IDENT_LIST       	: //epsilon
                                        {
                                        printRule("IDENT_LIST", "epsilon");
                                        }
                        | N_IDENT_LIST T_IDENT
                                        {
                                        printRule("IDENT_LIST", 
                                        "IDENT_LIST IDENT");
                                        }
                                ;
N_INTCONST_LIST         : T_INTCONST
                                        {
                                        printRule("INTCONST_LIST", "INTCONST");
                                        }
                        | N_INTCONST_LIST T_INTCONST
                                        {
                                        printRule("INTCONST_LIST", 
                                        "INTCONST_LIST INTCONST");
                                        }
                                ;*/
%%

#include "lex.yy.c"
extern FILE	*yyin;

void printRule(const char *lhs, const char *rhs) {
  printf("%s -> %s\n", lhs, rhs);
  return;
}

int yyerror(const char *s) {
  printf("%s\n", s);
  return(1);
}

void printTokenInfo(const char* tokenType, const char* lexeme) {
  printf("TOKEN: %s  LEXEME: %s\n", tokenType, lexeme);
}

int main() {
  do {
        yyparse();
  } while (!feof(yyin));

  printf("%d lines processed\n", numLines);
  return 0;
}
