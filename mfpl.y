/* 
 * Billy J Rhoades <bjrq48@mst.edu>
 * CS256 Programming Languages and Translators 
 * Section 1A
 * Homework 2
 */

%{
#include <stdio.h>

int numLines = 0; 

void printRule( int lhs, int rhs );
int yyerror( const char *s );
void printTokenInfo( int tokenType, const char* lexeme );
const char* nameLookup( int token );

enum SYMBOLS
{
  //Carryovers from lex
  IF,
  UNKNOWN,
  
  // Terminals
  START,
  IDENT,
  LPAREN,
  RPAREN,
  INTCONST,
  STRCONST,
  T,
  NIL, 
  LETSTAR,
  LAMBDA,
  PRINT,
  INPUT,
  ARITH_OP,
  MULTI,
  SUB,
  DIV,
  ADD,
  AND,
  OR,
  LT,
  GT,
  LE,
  GE,
  EQ,
  NE,
  NOT,
  EXPR,
  CONST,
  
  // Nonterminals
  PARENTHESIZED_EXPR,
  ARITHLOGIC_EXPR,
  IF_EXPR,
  LET_EXPR,
  LAMBDA_EXPR,
  PRINT_EXPR,
  INPUT_EXPR,
  EXPR_LIST,
  UN_OP,
  BIN_OP,
  ID_EXPR_LIST,
  ID_LIST,
  LOG_OP,
  REL_OP,
  
  NUM_SYMBOLS
  
};

const char* names[NUM_SYMBOLS] = 
  {
    //Carryovers from lex
    "IF",
    "UNKNOWN",
    
    //Terminals
    "START",
    "IDENT",
    "LPAREN",
    "RPAREN",
    "INTCONST",
    "STRCONST",
    "T",
    "NIL",
    "LETSTAR",
    "LAMBDA", 
    "PRINT",
    "INPUT",
    "ARITH_OP",
    "MULTI",
    "SUB",
    "DIV",
    "ADD",
    "AND",
    "OR",
    "LT",
    "GT",
    "LE",
    "GE",
    "EQ",
    "NE",
    "NOT",
    "EXPR",
    "CONST",
    
    // Nonterminals
    "( PARENTHESIZED_EXPR )",
    "ARITHLOGIC_EXPR",
    "IF_EXPR",
    "LET_EXPR",
    "LAMBDA_EXPR",
    "PRINT_EXPR",
    "INPUT_EXPR",
    "EXPR_LIST",
    "UN_OP",
    "BIN_OP",
    "ID_EXPR_LIST",
    "ID_LIST",
    "LOG_OP",
    "REL_OP"
  };

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

%start          N_START

%%
N_START:                N_EXPR
                        {
                          printRule( START, EXPR );
                          printf( "\n-- Completed parsing --\n\n" );
                          return 0;
                        };
                        
N_EXPR:                 N_CONST
                        {
                          printRule( EXPR, CONST );
                        }
                        | T_IDENT
                        {
                          printRule( EXPR, IDENT );
                        }
                        | T_LPAREN N_PARENTHESIZED_EXPR T_RPAREN
                        {
                          printRule( EXPR, PARENTHESIZED_EXPR );
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
%%

#include "lex.yy.c"
extern FILE *yyin;

void printRule( int lhs, int rhs )
{
  printf( "%s -> %s\n", names[lhs] , names[rhs] );
  return;
}

int yyerror( const char *s )
{
  printf( "%s\n", s );
  return( 1 );
}

void printTokenInfo( int tokenType, const char* lexeme )
{
  printf( "TOKEN: %s  LEXEME: %s\n", tokenType, lexeme );
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
