/* mfpl.l
 * Flex Homework #1
 * Billy Rhoades <bjrq48@mst.edu>
 * 12352623
 *
 *
*/

%{
 //Constants

  typedef enum
  {
    T_IDENT,
    T_INTCONST,
    T_UNKNOWN,
    T_FOO

  } TYPE;

  int numLines = 0;
  void printTokenInfo( const char* tokenTypem, const char* lexeme );
%}

WSPACE [ \t\r]+
NEWLINE \n
DIGIT [0-9]
LETTER [a-zA-Z]
/*letter/underscore, then any number of letters / digits / underscores*/
IDENT {LETTER}({LETTER}|{DIGIT})*
/*sequence of one or more digits, can start with +/-, no size constraint*/
INTCONST (\-|\+)?{DIGIT}+

%%

{IDENT} {
  printTokenInfo("IDENT", yytext);
  return T_IDENT;
}

%%

int yywrap( )
{
  return 1; // one file is taken in
}

void printTokenInfo( const char* tokenType, const char* lexeme )
{
  printf( "TOKEN: %s  LEXEME: %s\n", tokenType, lexeme );
}

int main( )
{
  while( yylex( ) );
  printf( "Processed %d lines\n", numLines );

  return 0;
}