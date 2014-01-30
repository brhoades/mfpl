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
    T_LETSTAR,
    T_IF,
    T_LAMBDA,
    T_PRINT,
    T_INPUT,
    T_AND,
    T_OR,
    T_NOT,
    T_T,
    T_NIL,
    T_OPERATOR,
    T_UNKNOWN

  } TYPE;
 
  int numLines = 0;
  void printTokenInfo( const char* tokenTypem, const char* lexeme );
%}

NEWLINE \n
WSPACE [ \t\r]+
AWSPACENLINE [\n\t\r ]+
DIGIT [0-9]
LETTER [a-zA-Z]

/*sequence of one or more digits, can start with +/-, no size constraint*/
INTCONST (\-|\+)?[0-9]+

/*letter/underscore, then any number of letters / digits / underscores*/
IDENT [A-Za-z_][A-Za-z0-9_]*

/*a ' followed by a ' with stuff in between, or a " followed by " with the same stuff*/
STRCONST \"[^\n]*\"|\'[^\n]*\'

/* let*, if, lambda, print, input, and, or, not, t, nil */
LETSTAR let\*/{AWSPACENLINE}
IF if/{AWSPACENLINE}
LAMBDA lambda/{AWSPACENLINE}
PRINT print/{AWSPACENLINE}
INPUT input/{AWSPACENLINE}
AND and/{AWSPACENLINE}
OR or/{AWSPACENLINE}
NOT not/{AWSPACENLINE}
T t/{AWSPACENLINE}
NIL nil/{AWSPACENLINE}

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

{LETSTAR}   {
              printTokenInfo("LETSTAR", yytext);
              return T_LETSTAR;
            }

{IF}        {
              printTokenInfo("IF", yytext);
              return T_IF;
            }

{LAMBDA}    {
              printTokenInfo("LAMBDA", yytext);
              return T_LAMBDA;
            }

{PRINT}     {
              printTokenInfo("PRINT", yytext);
              return T_PRINT;
            }

{INPUT}     {
              printTokenInfo("INPUT", yytext);
              return T_INPUT;
            }

{AND}       {
              printTokenInfo("AND", yytext);
              return T_AND;
            }

{OR}        {
              printTokenInfo("OR", yytext);
              return T_OR;
            }

{NOT}       {
              printTokenInfo("NOT", yytext);
              return T_NOT;
            }

{T}         {
              printTokenInfo("T", yytext);
              return T_T;
            }

{NIL}       {
              printTokenInfo("NIL", yytext);
              return T_NIL;
            }

{OPERATOR}  {
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