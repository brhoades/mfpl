/* 
 * Billy J Rhoades <bjrq48@mst.edu>
 * CS256 Programming Languages and Translators 
 * Section 1A
 * Homework 2
 */

%{
 //Constants

  typedef enum
  {
    RESERVED,   //reserved by lex
    T_COMMENT,
    T_UNKNOWN

  } TYPE;
 
  void printTokenInfo(  int tokenType, const char* lexeme );
%}

NEWLINE \n
WSPACE [ \t\r]+
AWSPACENLINE [\n\t\r ]+
DIGIT [0-9]
LETTER [a-zA-Z]

/*sequence of one or more digits, can start with +/-, no size constraint*/
INTCONST (\-|\+)?[0-9]+

/*a ' followed by a ' with stuff in between, or a " followed by " with the same stuff*/
STRCONST \"[^\n]*\"|\'[^\n]*\'

/* let*, if, lambda, print, input, and, or, not, t, nil */
LETSTAR let\*
IF if
LAMBDA lambda
PRINT print
INPUT input
AND and
OR or
NOT not
T t
NIL nil

/* matches * / + - < > >= <= = /= *=  */
ADD \+
SUB \-
MULT \*
DIV \/
LT <
GT >
LE <=
GE >=
EQ =
NE \/=

/* parenthesis */
RPAREN \)
LPAREN \(

/*letter/underscore, then any number of letters / digits / underscores*/
IDENT [A-Za-z_][A-Za-z0-9_]*

/* Comment, anything after ; */
COMMENT ;[^\n]*

%%          
{NEWLINE}   {
               numLines += 1 ;
            }

{WSPACE}    {
            }
            
{COMMENT}   {
            }
            
{INTCONST}  {
              printTokenInfo( INTCONST, yytext );
              return T_INTCONST;
            }

{T}         {
              printTokenInfo( T, yytext );
              return T_T;
            }
            
{STRCONST}  {
              printTokenInfo( STRCONST, yytext );
              return T_STRCONST;
            }

{LETSTAR}   {
              printTokenInfo( TOKEN_LETSTAR, yytext );
              beginScope( );
              
              return T_LETSTAR;
            }

{IF}        {
              printTokenInfo( IF, yytext );
              return T_IF;
            }

{LAMBDA}    {
              printTokenInfo( LAMBDA, yytext );
              beginScope( );

              return T_LAMBDA;
            }

{PRINT}     {
              printTokenInfo( PRINT, yytext );
              return T_PRINT;
            }

{INPUT}     {
              printTokenInfo( INPUT, yytext );
              return T_INPUT;
            }

{AND}       {
              printTokenInfo( AND, yytext );
              return T_AND;
            }

{OR}        {
              printTokenInfo( OR, yytext );
              return T_OR;
            }

{NOT}       {
              printTokenInfo( NOT, yytext );
              return T_NOT;
            }

{NIL}       {
              printTokenInfo( NIL, yytext );
              return T_NIL;
            }

{RPAREN}    {
              printTokenInfo( TOKEN_RPAREN, yytext );
              return T_RPAREN;
            }

{LPAREN}    {
              printTokenInfo( TOKEN_LPAREN, yytext );
              return T_LPAREN;
            }

{ADD}       {
              printTokenInfo( TOKEN_ADD, yytext );
              return T_ADD;
            }

{SUB}       {
              printTokenInfo( TOKEN_SUB, yytext );
              return T_SUB;
            }

{MULT}      {
              printTokenInfo( TOKEN_MULT, yytext );
              return T_MULT;
            }

{DIV}       {
              printTokenInfo( TOKEN_DIV, yytext );
              return T_DIV;
            }

{LT}        {
              printTokenInfo( TOKEN_LT, yytext );
              return T_LT;
            }

{GT}        {
              printTokenInfo( TOKEN_GT, yytext );
              return T_GT;
            }

{LE}        {
              printTokenInfo( TOKEN_LE, yytext );
              return T_LE;
            }

{GE}        {
              printTokenInfo( TOKEN_GE, yytext );
              return T_GE;
            }

{EQ}        {
              printTokenInfo( TOKEN_EQ, yytext );
              return T_EQ;
            }

{NE}        {
              printTokenInfo( TOKEN_NE, yytext );
              return T_NE;
            }

{IDENT}     {
              yylval.text = strdup(yytext);
              
              printTokenInfo( IDENT, yytext );
              return T_IDENT;
            }
            
.           {
               printTokenInfo( UNKNOWN, yytext );
               return T_UNKNOWN;
            }

%%
