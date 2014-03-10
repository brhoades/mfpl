/* 
 * Billy J Rhoades <bjrq48@mst.edu>
 * CS256 Programming Languages and Translators 
 * Section 1A
 * Homework 4
 */

%{
#include <stdio.h>
#include <stdarg.h>
#include "SymbolTable.h"
#include <stack>

stack<SYMBOL_TABLE> scopeStack;

int numLines      = 0; 
bool good         = true;
int expListLen    = 0;
int lambExprList  = 0;

void printRule( int, int );
void vPrintRule( int, ... );
int  yyerror( const char *s );
void printTokenInfo( int tokenType, const char* lexeme );
const char* nameLookup( int token );
void beginScope( );
int  findEntryInAnyScope( string, int );
bool findEntryInAnyScope( string );
int  findTypeInAnyScope( string );
void endScope( );
bool addToSymbolTable( char*, char );
void passthrough( TYPE_INFO&, char );
void passthrough( TYPE_INFO&, char, int, int );
void passthrough( TYPE_INFO&, TYPE_INFO );

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
  TOKEN_LETSTAR,
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
    "let*",
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
    "/=",
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

%union
{
  char* text;
  TYPE_INFO typeInfo;
};

/* Token declarations */
%token T_IDENT T_LPAREN T_RPAREN T_INTCONST T_STRCONST T_T T_NIL
%token T_LETSTAR  T_LAMBDA T_PRINT T_INPUT T_ARITH_OP T_MULT T_SUB T_DIV T_ADD 
%token T_AND T_OR T_LT T_GT T_LE T_GE T_EQ T_NE T_NOT T_IF

%type  <text> T_IDENT;
%type  <text> N_ID_EXPR_LIST;
%type  <text> N_ID_LIST;

%type  <typeInfo> N_EXPR N_PARENTHESIZED_EXPR N_IF_EXPR;
%type  <typeInfo> N_CONST N_ARITHLOGIC_EXPR N_BIN_OP;
%type  <typeInfo> N_PRINT_EXPR N_LAMBDA_EXPR N_INPUT_EXPR;
%type  <typeInfo> N_EXPR_LIST N_LET_EXPR;

%start N_START

%%
N_START:                N_EXPR
                        {
                          printRule( START, EXPR );
                          printf( "\n---- Completed parsing ----\n\n" );
                          
                          return 0;
                        };
                        
N_EXPR:                 N_CONST
                        {
                          printRule( EXPR, CONST );
                          
                          //printf( "===Got NEXPR type: %i\n", $1.type );

                          passthrough( $$, $1 );
                        }
                        | T_IDENT
                        { 
                          printRule( EXPR, IDENT );
                        
                          if( !findEntryInAnyScope( $1 ) )
                          {
                            yyerror( "Undefined identifier" );
                            return -1;
                          }

                          //printf( "===Found type: %i\n", findTypeInAnyScope( $1 ) );
                        
                          passthrough( $$, findTypeInAnyScope( $1 ) );
                        }
                        | T_LPAREN N_PARENTHESIZED_EXPR T_RPAREN
                        {
                          vPrintRule( 4, EXPR, LPAREN, PARENTHESIZED_EXPR, RPAREN );
                         
                          //printf( "===Got PARENEXPR type! %i\n", $2.type );
                          passthrough( $$, $2 );
                        };
               
N_CONST:                T_INTCONST
                        {
                          printRule( CONST, INTCONST );
                          
                          passthrough( $$, INT ); 
                        }
                        | T_STRCONST
                        {
                          printRule( CONST, STRCONST );
                          
                          passthrough( $$, STR );
                        }
                        | T_T
                        {
                          printRule( CONST, T );

                          passthrough( $$, BOOL );
                        }
                        | T_NIL
                        {
                          printRule( CONST, NIL );

                          passthrough( $$, BOOL );
                        };

N_PARENTHESIZED_EXPR:   N_ARITHLOGIC_EXPR
                        {
                          printRule( PARENTHESIZED_EXPR, ARITHLOGIC_EXPR );

                          passthrough( $$, $1 );
                        }
                        | N_IF_EXPR
                        {
                          printRule( PARENTHESIZED_EXPR, IF_EXPR );

                          passthrough( $$, $1 );
                        }
                        | N_LET_EXPR
                        {
                          printRule( PARENTHESIZED_EXPR, LET_EXPR );
                          
                          passthrough( $$, $1 );
                        }
                        | N_LAMBDA_EXPR
                        {
                          printRule( PARENTHESIZED_EXPR, LAMBDA_EXPR );
                          
                          passthrough( $$, $1 );
                        }
                        | N_PRINT_EXPR
                        {
                          printRule( PARENTHESIZED_EXPR, PRINT_EXPR );
                    
                          passthrough( $$, $1 );
                        }
                        | N_INPUT_EXPR
                        {
                          printRule( PARENTHESIZED_EXPR, INPUT_EXPR );

                          passthrough( $$, $1 );
                        }
                        | N_EXPR_LIST
                        {
                          printRule( PARENTHESIZED_EXPR, EXPR_LIST );
                          
                          passthrough( $$, $1 );
                        };

N_ARITHLOGIC_EXPR:      N_UN_OP N_EXPR
                        {
                          vPrintRule( 3, ARITHLOGIC_EXPR, UN_OP, EXPR );

                          if( $2.type == FUNCTION )
                            return( yyerror( "Arg 1 cannot be function" ) );

                          passthrough( $$, BOOL );
                        }
                        | N_BIN_OP N_EXPR N_EXPR
                        {
                          vPrintRule( 4, ARITHLOGIC_EXPR, BIN_OP, EXPR, EXPR );

                          passthrough( $$, BOOL );

                          // Bad when not $2 != $3 != (INT || STR )
                          if( $1.opType == OP_REL )
                          {
                            if( $2.type & INT  && !( $3.type & INT ) )
                                return( yyerror( "Arg 2 must be int" ) );
                            else if( $2.type & STR && !( $3.type & STR ) )
                                return( yyerror( "Arg 2 must be string" ) );
                            else if( $2.type & INT && !( $3.type & STR ) ) 
                              return( yyerror( "Arg 1 must be int or string" ) );
                          }
                          else if( $1.opType == OP_LOGIC ) // Bad when ($2 || $3 ) == FUNC
                          {
                            if( $2.type == FUNCTION )
                              return( yyerror( "Arg 1 cannot be function" ) );
                            else if( $3.type == FUNCTION )
                              return( yyerror( "Arg 2 cannot be function" ) );
                          }
                          else if( $1.opType == OP_ARITH ) // Bad when ( $2 || $3 ) != INT
                          {
                            //printf( "IS ACTUALLY: %i and %i\n", $2.type, $3.type );
                            if( !( $2.type & INT ) )
                              return( yyerror( "Arg 1 must be integer" ) );
                            else if( !( $3.type & INT ) )
                              return( yyerror( "Arg 2 must be integer" ) );
                            
                            passthrough( $$, INT );
                          }
                        };
                        
N_IF_EXPR:              T_IF N_EXPR N_EXPR N_EXPR
                        {
                          vPrintRule( 5, IF_EXPR, IF, EXPR, EXPR, EXPR );

                          if( $2.type == FUNCTION )
                            return( yyerror( "Arg 1 cannot be function" ) );
                          else if( $3.type == FUNCTION )
                            return( yyerror( "Arg 2 cannot be function" ) );
                          else if( $4.type == FUNCTION )
                            return( yyerror( "Arg 3 cannot be function" ) );

                          passthrough( $$, $3.type | $4.type );
                        };

N_LET_EXPR:             T_LETSTAR T_LPAREN N_ID_EXPR_LIST T_RPAREN N_EXPR
                        {
                          vPrintRule( 6, LET_EXPR, LETSTAR, LPAREN, ID_EXPR_LIST, 
                                     RPAREN, EXPR );
                          endScope( );

                          passthrough( $$, $5.type );
                        };

N_ID_EXPR_LIST:         /* epsilon */
                        {
                          printRule( ID_EXPR_LIST, EPSILON );
                        }
                        | N_ID_EXPR_LIST T_LPAREN T_IDENT N_EXPR T_RPAREN
                        { 
                          vPrintRule( 6, ID_EXPR_LIST, ID_EXPR_LIST, LPAREN, 
                                      IDENT, EXPR, RPAREN );
                          
                          if( !addToSymbolTable( $3, $4.type ) )
                            return -1;

                        };

N_LAMBDA_EXPR:          T_LAMBDA T_LPAREN N_ID_LIST T_RPAREN N_EXPR
                        {
                          vPrintRule( 6, LAMBDA_EXPR, LAMBDA, LPAREN, ID_LIST,
                                      RPAREN, EXPR );
                          endScope( );
                          
                          if( $5.type == FUNCTION )
                            return( yyerror( "Arg 2 cannot be function" ) );

                          passthrough( $$, FUNCTION, lambExprList, $5.type );
                        };

N_ID_LIST:              /* epsilon */
                        {
                          printRule( ID_LIST, EPSILON );
                          lambExprList = 0;
                        }
                        | N_ID_LIST T_IDENT
                        {
                          vPrintRule( 3, ID_LIST, ID_LIST, IDENT );
                          
                          if( !addToSymbolTable( $2, INT ) )
                            return -1;

                          lambExprList += 1;
                        };

N_PRINT_EXPR:           T_PRINT N_EXPR
                        {
                          vPrintRule( 3, PRINT_EXPR, PRINT, EXPR );

                          if( $2.type == FUNCTION )
                            return( yyerror( "Arg 1 cannot be function" ) );

                          passthrough( $$, $2.type );
                        };

N_INPUT_EXPR:           T_INPUT
                        {
                          printRule( INPUT_EXPR, INPUT );

                          passthrough( $$, INT | STR );
                        };

N_EXPR_LIST:            N_EXPR N_EXPR_LIST
                        {
                          vPrintRule( 3, EXPR_LIST, EXPR, EXPR_LIST );
                          
                          //I don' t know if I can check first here, so I'm going to leave it as is
                          if( $1.type == FUNCTION )
                          {
                            if( $1.numParams != expListLen )
                              return( $1.numParams > expListLen ? yyerror( "Too many parameters in function call" ) 
                                        : yyerror( "Too few parameters in function call" ) );
                          
                            if( $1.returnType == FUNCTION )
                              return( yyerror( "Arg 1 can't return function" ) );

                            passthrough( $$, $1.returnType );
                          }

                          expListLen += 1;
                        }
                        | N_EXPR
                        {
                          printRule( EXPR_LIST, EXPR );

                          expListLen = 1;
                        };

N_BIN_OP:               N_ARITH_OP
                        {
                          printRule( BIN_OP, ARITH_OP );

                          $$.opType = OP_ARITH;
                        }
                        | N_LOG_OP
                        {
                          printRule( BIN_OP, LOG_OP );

                          $$.opType = OP_LOGIC;
                        }
                        | N_REL_OP
                        {
                          printRule( BIN_OP, REL_OP );

                          $$.opType = OP_REL;
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
  printf( "%s", out );
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

void beginScope( )
{
  scopeStack.push( SYMBOL_TABLE( ) );
  printf("\n___Entering new scope...\n\n");
}

void endScope( )
{
  scopeStack.pop( );
  printf("\n___Exiting scope...\n\n");
}

bool addToSymbolTable( char* s, char t )
{
  int found = findEntryInAnyScope( string( s ), -1 );

  SYMBOL_TABLE_ENTRY symbol = SYMBOL_TABLE_ENTRY( string( s ), t );
  scopeStack.top( ).addEntry( symbol );
  printf( "___Adding %s to symbol table\n", s );

  if( found == 0 )
  {
    yyerror( "Multiply defined identifier" );
    return false;
  }

  return true;
}

// Wrap to pass in a -1 by default.
bool findEntryInAnyScope( string theName )
{
  if( findEntryInAnyScope( theName, -1 ) >= 0 )
    return true;
  else
    return false;
}

// Returns the scope level in which this is defined. -1 if not defined.
int findEntryInAnyScope( string theName, int level )
{
  if( scopeStack.empty( ) )
    return( -1 );
  bool found = scopeStack.top( ).findEntry( theName );
  if( found )
    return( level+1 );
  else
  { // check in "next higher" scope
    SYMBOL_TABLE symbolTable = scopeStack.top( );
    scopeStack.pop( );
    level = findEntryInAnyScope( theName, level+1 );
    if( level <= 0 )
      level = -1;
    scopeStack.push( symbolTable ); // restore the stack
  }

  return( level );
}

// Returns the scope level in which this is defined. -1 if not defined.
int findTypeInAnyScope( string theName )
{
  if( scopeStack.empty( ) )
    return( UNDEFINED );

  int found = scopeStack.top( ).getEntryType( theName );

  if( found != UNDEFINED )
    return( found );
  else
  { // check in "next higher" scope
    SYMBOL_TABLE symbolTable = scopeStack.top( );
    scopeStack.pop( );
    found = findTypeInAnyScope( theName );
    scopeStack.push( symbolTable ); // restore the stack
  }

  return( found );
}

// Replacing commonly used "TYPE NOTHING NOTHING" values everywhree
void passthrough( TYPE_INFO& typeinfo, char type )
{
  typeinfo.numParams  = NOT_APPLICABLE;
  typeinfo.returnType = NOT_APPLICABLE;
  typeinfo.type = type;
}

void passthrough( TYPE_INFO& typeinfo, char type, int numParams, int returnType )
{
  typeinfo.numParams  = numParams;
  typeinfo.returnType = returnType;
  typeinfo.type = type;
}

void passthrough( TYPE_INFO& lhs, TYPE_INFO rhs )
{ 
  lhs.numParams  = rhs.numParams;
  lhs.returnType = rhs.returnType;
  lhs.type       = rhs.type;
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
