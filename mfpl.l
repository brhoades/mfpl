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
    T_INTCONST,
    T_IDENT,
    T_STRCONST,
    T_KEYWORD,
    T_OPERATOR,
    T_UNKNOWN

  } TYPE;
 
  int numLines = 0;
  void printTokenInfo( const char* tokenTypem, const char* lexeme );
%}

NEWLINE \n
WSPACE [ \t\r]+
DIGIT [0-9]
LETTER [a-zA-Z]

/*sequence of one or more digits, can start with +/-, no size constraint*/
INTCONST (\-|\+)?[0-9]+
/*letter/underscore, then any number of letters / digits / underscores*/
IDENT [A-Za-z_][A-Za-z0-9_]*
/*a ' followed by a ' with stuff in between, or a " followed by " with the same stuff*/
STRCONST \"[^\n]*\"|\'[^\n]*\'
/* let*, if, lambda, print, input, and, or, not, t, nil */
KEYWORD (let\*|if|lambda|print|input|and|not|t|nil)/[\n\t\r ]+
/* matches * / + - < > >= <= = /= *=  */
OPERATOR [<>/*]{0,1}=|[*/+-<>]

%%
{NEWLINE}   {
               numLines += 1 ;
            }

{WSPACE}    {
            }

{INTCONST}  {
              printTokenInfo("INTCONST", yytext);
              return T_INTCONST;
            }

{IDENT}     {
              printTokenInfo("IDENT", yytext);
              return T_IDENT;
            }

{STRCONST}  {
              printTokenInfo("STRCONST", yytext);
              return T_STRCONST;
            }

{KEYWORD}   {
              printTokenInfo("KEYWORD", yytext);
              return T_KEYWORD;
            }

{OPERATOR}   {
              printTokenInfo("OPERATOR", yytext);
              return T_OPERATOR;
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