/*
 * Billy J Rhoades <bjrq48@mst.edu>
 * CS256 Programming Languages and Translators
 * Section 1A
 * Homework 4
 */

#ifndef SYMBOL_TABLE_ENTRY_H
#define SYMBOL_TABLE_ENTRY_H

#include <string>
using namespace std;

#define UNDEFINED  -1
#define FUNCTION 0
#define INT 1
#define STR 2
#define INT_OR_STR 3
#define BOOL 4
#define INT_OR_BOOL 5
#define STR_OR_BOOL 6
#define INT_OR_STR_OR_BOOL 7

#define NOT_APPLICABLE  -1

typedef struct
{
  int type;        // one of the above type codes
  int numParams;   // numParams and returnType only applicable
  int returnType;  // if type == FUNCTION
} TYPE_INFO;


class SYMBOL_TABLE_ENTRY
{
  private:
    // Member variables
    string name;
    int typeCode;

  public:
    // Constructors
    SYMBOL_TABLE_ENTRY( )
    {
      name = "";
      typeCode = UNDEFINED;
    }

    SYMBOL_TABLE_ENTRY( const string theName, const int theType )
    {
      name = theName;
      typeCode = theType;
    }

    // Accessors
    string getName() const
    {
      return name;
    }
    int getTypeCode() const
    {
      return typeCode;
    }
};

#endif  // SYMBOL_TABLE_ENTRY_H
