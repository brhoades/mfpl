/* 
 * Billy J Rhoades <bjrq48@mst.edu>
 * CS256 Programming Languages and Translators 
 * Section 1A
 * Homework 2
 */

%{
#include <stdio.h>
#include <stdarg.h>

int numLines = 0;// good = 0; 

void printRule( int, int );
void vPrintRule( int, ... );
int yyerror( const char *s );
void printTokenInfo( int tokenType, const char* lexeme );
const char* nameLookup( int token );

//Symbols enum that we use when printing out symbol information.
//This way when small formatting changes are made I only need to update
//the corresponding entry in the namea array.
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
  TOKEN_LPAREN,
  TOKEN_RPAREN,
  INTCONST,
  STRCONST,
  T,
  NIL, 
  EPSILON,
  LETSTAR,
  LAMBDA,
  PRINT,
  INPUT,
  ARITH_OP,
  MULT,
  SUB,
  DIV,
  ADD,
  TOKEN_MULT,
  TOKEN_SUB,
  TOKEN_DIV,
  TOKEN_ADD,
  AND,
  OR,
  TOKEN_LT,
  TOKEN_GT,
  TOKEN_LE,
  TOKEN_GE,
  TOKEN_EQ,
  TOKEN_NE,
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
    "(",
    ")",
    "LPAREN",
    "RPAREN",
    "INTCONST",
    "STRCONST",
    "T",
    "NIL",
    "epsilon",
    "LETSTAR",
    "LAMBDA", 
    "PRINT",
    "INPUT",
    "ARITH_OP",
    "*",
    "-",
    "/",
    "+",
    "MULT",
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
    "<",
    ">",
    "<=",
    ">=",
    "=",
    "!=",
    "NOT",
    "EXPR",
    "CONST",
    
    // Nonterminals
    "PARENTHESIZED_EXPR",
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
/* Token declarations */
%token T_IDENT T_LPAREN T_RPAREN T_INTCONST T_STRCONST T_T T_NIL
%token T_LETSTAR  T_LAMBDA T_PRINT T_INPUT T_ARITH_OP T_MULT T_SUB T_DIV T_ADD 
%token T_AND T_OR T_LT T_GT T_LE T_GE T_EQ T_NE T_NOT T_IF

%start N_START

%%
N_START:                N_EXPR
                        {
                          printRule( START, EXPR );
                          printf( "\n---- Completed parsing ----\n\n" );
                          //good = 1;
                          
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
                          vPrintRule( 4, EXPR, LPAREN, PARENTHESIZED_EXPR, RPAREN );
                        };
               
N_CONST:                T_INTCONST
                        {
                          printRule( CONST, INTCONST );
                        }
                        | T_STRCONST
                        {
                          printRule( CONST, STRCONST );
                        }
                        | T_T
                        {
                          printRule( CONST, T );
                        }
                        | T_NIL
                        {
                          printRule( CONST, NIL );
                        };

N_PARENTHESIZED_EXPR:   N_ARITHLOGIC_EXPR
                        {
                          printRule( PARENTHESIZED_EXPR, ARITHLOGIC_EXPR );
                        }
                        | N_IF_EXPR
                        {
                          printRule( PARENTHESIZED_EXPR, IF_EXPR );
                        }
                        | N_LET_EXPR
                        {
                          printRule( PARENTHESIZED_EXPR, LET_EXPR );
                        }
                        | N_LAMBDA_EXPR
                        {
                          printRule( PARENTHESIZED_EXPR, LAMBDA_EXPR );
                        }
                        | N_PRINT_EXPR
                        {
                          printRule( PARENTHESIZED_EXPR, PRINT_EXPR );
                        }
                        | N_INPUT_EXPR
                        {
                          printRule( PARENTHESIZED_EXPR, INPUT_EXPR );
                        }
                        | N_EXPR_LIST
                        {
                          printRule( PARENTHESIZED_EXPR, EXPR_LIST );
                        };

N_ARITHLOGIC_EXPR:      N_UN_OP N_EXPR
                        {
                          vPrintRule( 3, ARITHLOGIC_EXPR, UN_OP, EXPR );
                        }
                        | N_BIN_OP N_EXPR N_EXPR
                        {
                          vPrintRule( 4, ARITHLOGIC_EXPR, BIN_OP, EXPR, EXPR );
                        };
                        
N_IF_EXPR:              T_IF N_EXPR N_EXPR N_EXPR
                        {
                          vPrintRule( 5, IF_EXPR, IF, EXPR, EXPR, EXPR );
                        };

N_LET_EXPR:             T_LETSTAR T_LPAREN N_ID_EXPR_LIST T_RPAREN N_EXPR
                        {
                          vPrintRule( 6, LET_EXPR, LETSTAR, LPAREN, ID_EXPR_LIST, 
                                     RPAREN, EXPR );
                        };

N_ID_EXPR_LIST:         /* epsilon */
                        {
                          printRule( ID_EXPR_LIST, EPSILON );
                        }
                        | N_ID_EXPR_LIST T_LPAREN T_IDENT T_RPAREN N_EXPR
                        {
                          vPrintRule( 6, ID_EXPR_LIST, ID_EXPR_LIST, LPAREN, 
                                      T_IDENT, RPAREN, EXPR );
                        };

N_LAMBDA_EXPR:          T_LAMBDA T_LPAREN N_ID_LIST T_RPAREN N_EXPR
                        {
                          vPrintRule( 6, LAMBDA_EXPR, LAMBDA, LPAREN, ID_LIST,
                                      RPAREN, EXPR );
                        };

N_ID_LIST:              /* epsilon */
                        {
                          printRule( ID_LIST, NIL );
                        }
                        | N_ID_LIST T_IDENT
                        {
                          vPrintRule( 3, ID_LIST, ID_LIST, IDENT );
                        };

N_PRINT_EXPR:           T_PRINT N_EXPR
                        {
                          vPrintRule( 3, PRINT_EXPR, PRINT, EXPR );
                        };

N_INPUT_EXPR:           T_INPUT
                        {
                          printRule( INPUT_EXPR, INPUT );
                        };

N_EXPR_LIST:            N_EXPR N_EXPR_LIST
                        {
                          vPrintRule( 3, EXPR_LIST, EXPR, EXPR_LIST );
                        }
                        | N_EXPR
                        {
                          printRule( EXPR_LIST, EXPR );
                        };

N_BIN_OP:               N_ARITH_OP
                        {
                          printRule( BIN_OP, ARITH_OP );
                        }
                        | N_LOG_OP
                        {
                          printRule( BIN_OP, LOG_OP );
                        }
                        | N_REL_OP
                        {
                          printRule( BIN_OP, REL_OP );
                        };

N_ARITH_OP:             T_MULT
                        {
                          printRule( ARITH_OP, MULT );
                        }
                        | T_SUB
                        {
                          printRule( ARITH_OP, SUB );
                        }
                        | T_DIV
                        {
                          printRule( ARITH_OP, DIV );
                        }
                        | T_ADD
                        {
                          printRule( ARITH_OP, ADD );
                        };

N_LOG_OP:               T_AND
                        {
                          printRule( LOG_OP, AND );
                        }
                        | T_OR
                        {
                          printRule( LOG_OP, OR );
                        };

N_REL_OP:               T_LT
                        {
                          printRule( REL_OP, LT );
                        }
                        | T_GT
                        {
                          printRule( REL_OP, GT );
                        }
                        | T_LE
                        {
                          printRule( REL_OP, LE );
                        }
                        | T_GE
                        {
                          printRule( REL_OP, GE );
                        }
                        | T_EQ
                        {
                          printRule( REL_OP, EQ );
                        }
                        | T_NE
                        {
                          printRule( REL_OP, NE );
                        };

N_UN_OP:                T_NOT
                        {
                          printRule( UN_OP, NOT );
                        };

%%

#include "lex.yy.c"
extern FILE *yyin;

void printRule( int lhs, int rhs )
{
  printf( "%s -> %s\n", names[lhs] , names[rhs] );
  return;
}

void vPrintRule( int num, ... )
{
  char out[8192];
  va_list args;
  int i, in;
  
  //Handle our vargs
  va_start( args, num );
  
  //Base string
  strcpy( out, names[va_arg( args, int )] );
  strcat( out, " ->" );
  
  for( i=1; i<num; i++ )
  {
    in = va_arg( args, int );
    if( in >= NUM_SYMBOLS || in < 0 )
    {
      printf( "PARSE ERROR: Invalid symbol id passed in with index: %i\n", in );
      continue;
    }
    
    strcat( out, " "  );
    strcat( out, names[in] );
  }
  
  strcat( out, "\n" );
  printf( out );
  va_end( args );
}

int yyerror( const char *s )
{
  printf( "Line %i: %s\n", numLines+1, s );

  return 1;
}

void printTokenInfo( int tokenType, const char* lexeme )
{
  printf( "TOKEN: %s\tLEXEME: %s\n", names[tokenType], lexeme );
}

int main( )
{
  do
  {
    yyparse();
  } 
  while( !feof( yyin ) );
  
  //if( good )
  //  printf( "%d lines processed\n", numLines );
  
  return 0;
}
