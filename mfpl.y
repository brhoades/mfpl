/* 
 * Billy J Rhoades <bjrq48@mst.edu>
 * CS256 Programming Languages and Translators 
 * Section 1A
 * Homework 2
 */

%{
#include <stdio.h>

int numLines = 0; 

void printRule( const char *lhs, const char *rhs );
int yyerror( const char *s );
void printTokenInfo( const char* tokenType, const char* lexeme );

extern "C"
{
  int yyparse( void );
  int yylex( void );
  int yywrap( ) { return 1; }
}

%}
//N_EXPR N_CONST N_PARENTHESIZED_EXPR N_ARITHLOGIC_EXPR N_IF_EXPR N_LET_EXPR 
//N_LAMBDA_EXPR N_PRINT_EXPR N_INPUT_EXPR N_EXPR_LIST N_UN_OP N_BIN_OP
//N_ID_EXPR_LIST N_ID_LIST N_LOG_OP N_REL_OP
/* Token declarations */
%token T_IDENT T_LPAREN T_RPAREN T_INTCONST T_STRCONST T_T T_NIL
%token T_LETSTAR  T_LAMBDA T_PRINT T_INPUT T_ARITH_OP T_MULTI T_SUB T_DIV T_ADD 
%token T_AND T_OR T_LT T_GT T_LE T_GE T_EQ T_NE T_NOT

/* Translation rules */
%%
N_EXPR:                 N_CONST
                        {
                          printRole( "EXPR", "CONST" );
                        }
                        | T_IDENT
                        {
                          printRole( "EXPR", "IDENT" );
                        }
                        | T_LPAREN N_PARENTHESIZED_EXPR T_RPAREN
                        {
                          printRole( "EXPR", "( PARENTHESIZED_EXPR )" );
                        };
               
N_CONST:                T_INTCONST
                        {
                          
                        }
                        | T_STRCONST
                        {
                          
                        }
                        | T_T
                        {
                          
                        }
                        | T_NIL
                        {
                          
                        };

N_PARENTHESIZED_EXPR:   T_NIL;
               

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
extern FILE *yyin;

void printRule( const char *lhs, const char *rhs )
{
  printf( "%s -> %s\n", lhs, rhs );
  return;
}

int yyerror( const char *s )
{
  printf( "%s\n", s );
  return( 1 );
}

void printTokenInfo( const char* tokenType, const char* lexeme )
{
  printf("TOKEN: %s  LEXEME: %s\n", tokenType, lexeme);
}

int main( )
{
  do
  {
        yyparse();
  } 
  while( !feof( yyin ) );

  printf( "%d lines processed\n", numLines );
  return 0;
}
