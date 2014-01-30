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
    RESERVED,   //reserved by lex
    T_IDENT,
    T_INTCONST,
    T_STRCONST,
    T_NEWLINE,
    T_UNKNOWN

  } TYPE;
 
  int numLines = 0;
  void printTokenInfo( const char* tokenTypem, const char* lexeme );
%}

WSPACE [ \t\r]+
NEWLINE \n
DIGIT [0-9]
LETTER [a-zA-Z]

/*sequence of one or more digits, can start with +/-, no size constraint*/
INTCONST (\-|\+)?[0-9]+
/*letter/underscore, then any number of letters / digits / underscores*/
IDENT [A-Za-z_][A-Za-z0-9_]*
/*a ' followed by a ' with stuff in between, or a " followed by " with the same stuff*/
STRCONST \"[^\n]*\"|\'[^\n]*\'

%%

{IDENT} {
          printTokenInfo("IDENT", yytext);
          return T_IDENT;
        }
        
{STRCONST} {
              printTokenInfo("STRCONST", yytext);
              return T_STRCONST;
           }

{INTCONST} {
              printTokenInfo("INTCONST", yytext);
              return T_INTCONST;
           }
%%

int yywrap( )
{
  return 1; // one file is taken in
}

void printTokenInfo( const char* tokenType, const char* lexeme )
{
  printf( "TOKEN: %s  LEXEME: %s\n", tokenType, lexeme );
  numLines++;
}

int main( )
{
  while( yylex( ) );
  printf( "Processed %d lines\n", numLines );

  return 0;
}