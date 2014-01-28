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

IDENT {LETTER}({LETTER}|{DIGIT})*
INTCONST {DIGIT}+

%%

{IDENT}
{

}

%%

int yywrap( )
{
  return 1; // one line is returned
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