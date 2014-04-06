/*
      mfpl.y

 	Specifications for the MFPL language, YACC input file.

      To create syntax analyzer:

        flex mfpl.l
        bison mfpl.y
        g++ mfpl.tab.c -o mfpl_parser
        mfpl_parser < inputFileName
 */

/*
 *	Declaration section.
 */
%{
#include <stdio.h>
#include <stdlib.h>
#include <iostream>
#include <string>
#include <stack>
#include "SymbolTable.h"
  using namespace std;

#include <string.h>

#define DEBUG

#define KNRM  "\x1B[0m"
#define KRED  "\x1B[31m"
#define KGRN  "\x1B[32m"
#define KYEL  "\x1B[33m"
#define KBLU  "\x1B[34m"
#define KMAG  "\x1B[35m"
#define KCYN  "\x1B[36m"
#define KWHT  "\x1B[37m"

#define ARITHMETIC_OP	1   // classification for operators
#define LOGICAL_OP   	2
#define RELATIONAL_OP	3

  typedef struct
  {
    int type;
    char* name;
  } OP;

  int lineNum = 1;

  stack<SYMBOL_TABLE> scopeStack;    // stack of scope hashtables

  bool isIntCompatible( const int theType );
  bool isStrCompatible( const int theType );
  bool isIntOrStrCompatible( const int theType );

  void beginScope();
  void endScope();
  void cleanUp();
  void setVal( TYPE_INFO&, TYPE_INFO& );
  
  char** getVal( TYPE_INFO );

  TYPE_INFO findEntryInAnyScope( const string theName );

  void printRule( const char*, const char* );
  int yyerror( const char* s )
  {
    printf( "Line %d: %s\n", lineNum, s );
    cleanUp();
    exit( 1 );
  }

  extern "C"
  {
    int yyparse( void );
    int yylex( void );
    int yywrap()
    {
      return 1;
    }
  }
%}

%union
{
  char* text;
  TYPE_INFO typeInfo;
  OP op;
  int num;
};

/*
 *	Token declarations
*/
%token T_LPAREN T_RPAREN
%token T_IF T_LETSTAR T_PRINT T_INPUT
%token T_ADD  T_SUB  T_MULT  T_DIV
%token T_LT T_GT T_LE T_GE T_EQ T_NE T_AND T_OR T_NOT
%token T_INTCONST T_STRCONST T_T T_NIL T_IDENT T_UNKNOWN

%type	<text>     T_IDENT
%type <typeInfo> N_EXPR N_PARENTHESIZED_EXPR N_ARITHLOGIC_EXPR
%type <typeInfo> N_CONST N_IF_EXPR N_PRINT_EXPR N_INPUT_EXPR
%type <typeInfo> N_LET_EXPR N_EXPR_LIST
%type <op>       N_BIN_OP N_ARITH_OP N_LOG_OP N_REL_OP 

/*
 *	Starting point.
 */
%start  N_START

/*
 *	Translation rules.
 */
%%
N_START:       N_EXPR
               {
                 printRule( "START", "EXPR" );
                 printf( "\n---- Completed parsing ----\n\n" );
                 printf( "\nValue of the expression is: %s", getVal( $1 ) );
                 return 0;
               };

N_EXPR:        N_CONST
               {
                 printRule( "EXPR", "CONST" );
                 $$.type = $1.type;
                 setVal( $$, $1 );
               } 
               | T_IDENT
               {
                 printRule( "EXPR", "IDENT" );
                 string ident = string( $1 );
                 TYPE_INFO exprTypeInfo = findEntryInAnyScope( ident );
                 if ( exprTypeInfo.type == UNDEFINED )
                 {
                   yyerror( "Undefined identifier" );
                   return( 0 );
                 }
                 $$.type = exprTypeInfo.type;
                 setVal( $$, exprTypeInfo );
               }
               | T_LPAREN N_PARENTHESIZED_EXPR T_RPAREN
               {
                 printRule( "EXPR", "( PARENTHESIZED_EXPR )" );
                 $$.type = $2.type;
                 setVal( $$, $2 );
                 #if defined DEBUG
                 if( $2.type != STR )
                   printf( "%sDEBUG: ( PAREN ) -> (INT) %i%s\n", KRED, $$.intVal, KNRM );
                 else
                   printf( "%sDEBUG: ( PAREN ) -> (STR) %s%s\n", KRED, $$.strVal, KNRM );
                 #endif
               };
N_CONST:       T_INTCONST
               {
                 printRule( "CONST", "INTCONST" );
                 $$.type = INT;
                 $$.intVal = yylval.num;
               }
               | T_STRCONST
               {
                 printRule( "CONST", "STRCONST" );
                 $$.type = STR;
                 $$.strVal = &yylval.text;
               }
               | T_T
               {
                 printRule( "CONST", "t" );
                 $$.type = BOOL;
                 $$.intVal = 1;
               }
               | T_NIL
               {
                 printRule( "CONST", "nil" );
                 $$.type = BOOL;
                 $$.intVal = 0;
               };
N_PARENTHESIZED_EXPR: N_ARITHLOGIC_EXPR
                {
                  printRule( "PARENTHESIZED_EXPR",
                  "ARITHLOGIC_EXPR" );
                  $$.type = $1.type;
                  setVal( $$, $1 );
                }
                | N_IF_EXPR
                {
                  printRule( "PARENTHESIZED_EXPR", "IF_EXPR" );
                  $$.type = $1.type;
                  setVal( $$, $1 );
                }
                | N_LET_EXPR
                {
                  printRule( "PARENTHESIZED_EXPR",
                  "LET_EXPR" );
                  $$.type = $1.type;
                  setVal( $$, $1 );
                }
                | N_PRINT_EXPR
                {
                  printRule( "PARENTHESIZED_EXPR",
                  "PRINT_EXPR" );
                  $$.type = $1.type;
                  setVal( $$, $1 );
                  #if defined DEBUG
                  printf( "%sDEBUG: N_PRINT_EXPR -> %i%s\n", KRED, $1.intVal, KNRM );
                  #endif
                }
                | N_INPUT_EXPR
                {
                  printRule( "PARENTHESIZED_EXPR",
                  "INPUT_EXPR" );
                  $$.type = $1.type;
                  setVal( $$, $1 );
                }
                | N_EXPR_LIST
                {
                  printRule( "PARENTHESIZED_EXPR",
                  "EXPR_LIST" );
                  $$.type = $1.type;
                  setVal( $$, $1 );
                };
              
N_ARITHLOGIC_EXPR	:
                N_UN_OP N_EXPR
                {
                  printRule( "ARITHLOGIC_EXPR",
                  "UN_OP EXPR" );
                  $$.type = BOOL;

                  if( $2.type == BOOL )
                    $$.intVal = !$2.intVal;
                  else
                    $$.intVal = 0;
                }
                | N_BIN_OP N_EXPR N_EXPR
                {
                  printRule( "ARITHLOGIC_EXPR", "BIN_OP EXPR EXPR" );
                  $$.type = BOOL;
                  switch ( $1.type )
                  {
                  case ( ARITHMETIC_OP ):
                    $$.type = INT;
                    if ( !isIntCompatible( $2.type ) )
                    {
                      yyerror( "Arg 1 must be integer" );
                      return( 0 );
                    }
                    if ( !isIntCompatible( $3.type ) )
                    {
                      yyerror( "Arg 2 must be integer" );
                      return( 0 );
                    }

                    if( !strcmp( $1.name, "+" ) )
                    {
                      $$.intVal = $2.intVal + $3.intVal;
                      #if defined DEBUG
                      printf( "DEBUG: + %i ($2) %i ($3)\n", $2.intVal, $3.intVal );
                      #endif
                    }
                    else if( !strcmp( $1.name, "-" ) )
                      $$.intVal = $2.intVal - $3.intVal;
                    else if( !strcmp( $1.name, "*" ) )
                      $$.intVal = $2.intVal * $3.intVal;
                    else if( !strcmp( $1.name, "/" ) )
                    {
                      if( $3.intVal == 0 )
                      {
                        printf( "ERROR PLACEHOLDER: DIV / 0\n" );
                        return( 0 );
                      }
                      $$.intVal = $2.intVal / $3.intVal;
                    }
                    break;

                  case ( LOGICAL_OP ):
                    if( !strcmp( $1.name, "or" ) )
                    {
                      if( ( $2.type == BOOL && $2.intVal == 1 ) ||
                          ( $2.type != BOOL ) ||
                          ( $3.type == BOOL && $3.intVal == 1 ) ||
                          ( $3.type != BOOL ) )
                        $$.intVal = 1; 
                      else
                        $$.intVal = 0;
                    }
                    else
                    {
                      if( ( ( $2.type == BOOL && $2.intVal == 1 ) ||
                          ( $2.type != BOOL ) ) &&
                          ( ( $3.type == BOOL && $3.intVal == 1 ) ||
                          ( $3.type != BOOL ) ) )
                        $$.intVal = 1;
                      else
                        $$.intVal = 0;
                    }
                    break;

                  case ( RELATIONAL_OP ):
                    if ( !isIntOrStrCompatible( $2.type ) )
                    {
                      yyerror( "Arg 1 must be integer or string" );
                      return( 0 );
                    }
                    if ( !isIntOrStrCompatible( $3.type ) )
                    {
                      yyerror( "Arg 2 must be integer or string" );
                      return( 0 );
                    }
                    if ( isIntCompatible( $2.type ) &&
                         !isIntCompatible( $3.type ) )
                    {
                      yyerror( "Arg 2 must be integer" );
                      return( 0 );
                    }
                    else if ( isStrCompatible( $2.type ) &&
                              !isStrCompatible( $3.type ) )
                    {
                      yyerror( "Arg 2 must be string" );
                      return( 0 );
                    }
                    break;
                  }  // end switch
                };
N_IF_EXPR: T_IF N_EXPR N_EXPR N_EXPR
                {
                  printRule( "IF_EXPR", "if EXPR EXPR EXPR" );
                  $$.type = $3.type | $4.type;
                };
N_LET_EXPR: T_LETSTAR T_LPAREN N_ID_EXPR_LIST T_RPAREN N_EXPR
                {
                  printRule( "LET_EXPR",
                  "let* ( ID_EXPR_LIST ) EXPR" );
                  endScope();
                  $$.type = $5.type;
                };
N_ID_EXPR_LIST: /* epsilon */
                {
                  printRule( "ID_EXPR_LIST", "epsilon" );
                }
                | N_ID_EXPR_LIST T_LPAREN T_IDENT N_EXPR T_RPAREN
                {
                  printRule( "ID_EXPR_LIST",
                  "ID_EXPR_LIST ( IDENT EXPR )" );
                  string lexeme = string( $3 );
                  TYPE_INFO exprTypeInfo = $4;
                  printf( "___Adding %s to symbol table\n", $3 );
                  bool success = scopeStack.top().addEntry
                  ( SYMBOL_TABLE_ENTRY( lexeme,
                  exprTypeInfo ) );
                  if ( ! success )
                  {
                    yyerror( "Multiply defined identifier" );
                    return( 0 );
                  }
                };
N_PRINT_EXPR: T_PRINT N_EXPR
                {
                  printRule( "PRINT_EXPR", "print EXPR" );
                  $$.type = $2.type;
                  setVal( $$, $2 );
                  printf( "%sDEBUG: EXPR -> %i%s\n ", KRED, $2.intVal, KNRM );
                  printf( "%s\n", getVal( $2 ) );
                };
N_INPUT_EXPR: T_INPUT
                {
                  printRule( "INPUT_EXPR", "input" );
                  $$.type = INT_OR_STR;
                };
N_EXPR_LIST: N_EXPR N_EXPR_LIST
                {
                  printRule( "EXPR_LIST", "EXPR EXPR_LIST" );
                  $$.type = $2.type;
                }
                | N_EXPR
                {
                  printRule( "EXPR_LIST", "EXPR" );
                  $$.type = $1.type;
                };
N_BIN_OP: N_ARITH_OP
                {
                  printRule( "BIN_OP", "ARITH_OP" );
                  $$ = $1;
                  $$.type = ARITHMETIC_OP;
                }
                |
                N_LOG_OP
                {
                  printRule( "BIN_OP", "LOG_OP" );
                  $$ = $1;
                  $$.type = LOGICAL_OP;
                }
                |
                N_REL_OP
                {
                  printRule( "BIN_OP", "REL_OP" );
                  $$ = $1;
                  $$.type = RELATIONAL_OP;
                };
N_ARITH_OP:
                T_ADD
                {
                  printRule( "ARITH_OP", "+" );
                  $$.name = (char*)"+";
                }
                | T_SUB
                {
                  printRule( "ARITH_OP", "-" );
                  $$.name = (char*)"-";
                }
                | T_MULT
                {
                  printRule( "ARITH_OP", "*" );
                  $$.name = (char*)"*";
                }
                | T_DIV
                {
                  printRule( "ARITH_OP", "/" );
                  $$.name = (char*)"/";
                };
N_REL_OP: T_LT
                {
                  printRule( "REL_OP", "<" );
                  $$.name = (char*)"<";
                }
                | T_GT
                {
                  printRule( "REL_OP", ">" );
                  $$.name = (char*)">";
                }
                | T_LE
                {
                  printRule( "REL_OP", "<=" );
                  $$.name = (char*)"<=";
                }
                | T_GE
                {
                  printRule( "REL_OP", ">=" );
                  $$.name = (char*)">=";
                }
                | T_EQ
                {
                  printRule( "REL_OP", "=" );
                  $$.name = (char*)"=";
                }
                | T_NE
                {
                  printRule( "REL_OP", "/=" );
                  $$.name = (char*)"/=";
                };
N_LOG_OP:
                T_AND
                {
                  printRule( "LOG_OP", "and" );
                  $$.name = (char*)"and";
                }
                | T_OR
                {
                  printRule( "LOG_OP", "or" );
                  $$.name = (char*)"or";
                };
N_UN_OP:
                T_NOT
                {
                  printRule( "UN_OP", "not" );
                };
%%

#include "lex.yy.c"
extern FILE *yyin;

bool isIntCompatible( const int theType )
{
  return( ( theType == INT ) || ( theType == INT_OR_STR ) ||
          ( theType == INT_OR_BOOL ) ||
          ( theType == INT_OR_STR_OR_BOOL ) );
}

bool isStrCompatible( const int theType )
{
  return( ( theType == STR ) || ( theType == INT_OR_STR ) ||
          ( theType == STR_OR_BOOL ) ||
          ( theType == INT_OR_STR_OR_BOOL ) );
}

bool isIntOrStrCompatible( const int theType )
{
  return( isStrCompatible( theType ) || isIntCompatible( theType ) );
}

void printRule( const char* lhs, const char* rhs )
{
  printf( "%s -> %s\n", lhs, rhs );
  return;
}

void beginScope()
{
  scopeStack.push( SYMBOL_TABLE() );
  printf( "\n___Entering new scope...\n\n" );
}

void endScope()
{
  scopeStack.pop();
  printf( "\n___Exiting scope...\n\n" );
}

TYPE_INFO findEntryInAnyScope( const string theName )
{
  TYPE_INFO info = {UNDEFINED};
  if( scopeStack.empty( ) ) return( info );
  info = scopeStack.top().findEntry( theName );
  if( info.type != UNDEFINED )
    return( info );
  else   // check in "next higher" scope
  {
    SYMBOL_TABLE symbolTable = scopeStack.top( );
    scopeStack.pop( );
    info = findEntryInAnyScope( theName );
    scopeStack.push( symbolTable ); // restore the stack
    return( info );
  }
}

void cleanUp()
{
  if ( scopeStack.empty() )
    return;
  else
  {
    scopeStack.pop();
    cleanUp();
  }
}

void setVal( TYPE_INFO& lhs, TYPE_INFO& rhs )
{
  if( rhs.type == BOOL || rhs.type == INT )
    lhs.intVal = rhs.intVal;
  else
    lhs.strVal = rhs.strVal;
}

char** getVal( TYPE_INFO var )
{
  if( var.type == BOOL )
  {
    if( var.intVal == 0 )
      return (char**)"nil";
    else
      return (char**)"t";
  }
  else if( var.type == INT )
  {
    static char buffer[1024];

    sprintf( buffer, "%d", var.intVal );
    return (char**)buffer;
  }
  else
    return var.strVal;
}

int main( int argc, char** argv )
{
  if( argc < 2 )
  {
    printf( "You must specify a file in the command line!\n" );
    exit( 1 );
  }
  
  yyin = fopen( argv[1], "r" );

  do
  {
    yyparse();
  }
  while ( !feof( yyin ) );

  cleanUp();
  return 0;
}
