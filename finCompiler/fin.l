%{
  #include <cstdio>
  #include <iostream>
  using namespace std;

//  #include "fin.tab.h" // to get the token types from Bison
  extern "C" int finlex();

  int lineNum = 1;
%}

%option noyywrap
%option outfile="lex.fin.c"
%option prefix="fin"

DIGIT	[0-9]
UDIGIT	b(0|1){32}
CHAR	[a-zA-Z]
UCHAR	b(0|1){8}
LABEL	[a-z]{1,3}
ULABEL  b(0|1){16}

%%

[ \t]				;
\n				{ lineNum++; }
header				{ cout << "Header" << endl; }
footer				{ cout << "Footer" << endl; }
stack|arith|heap|flow|ioa|ioc	{ cout << "IMP: " << yytext << endl; }
elfin				{ cout << "End of program." << endl; }
push|dup|swap|discard		{ cout << "Stack command: " << yytext << endl; }
add|sub|mult|div|mod		{ cout << "Arith command: " << yytext << endl; }
store|retrieve			{ cout << "Heap command: " << yytext << endl; }
mark|call|jumpu|jumpz|jumpn|return	{
				  cout << "Flow command: " << yytext << endl; }
outc|outn|inc|inn		{ cout << "IO Action : " << yytext << endl; }
fileio|netcon|stdio		{ cout << "IO Control : " << yytext << endl; }
{DIGIT}+			{ cout << "Number: " << yytext << endl; }
{UDIGIT}			{ cout << "Number: " << yytext << endl; }
{CHAR}				{ cout << "Character: " << yytext << endl; }
{UCHAR}				{ cout << "Character: " << yytext << endl; }
{LABEL}				{ cout << "Label: " << yytext << endl; }
{ULABEL}			{ cout << "Label: " << yytext << endl; }
.				;

%%

int main(int, char**) {
  // open a file handle to a particular file:
  FILE *myfile = fopen("test.fin", "r");
  // make sure it is valid:
  if (!myfile) {
    cout << "I can't open test.fin!" << endl;
    return -1;
  }
  // Set flex to read from it instead of defaulting to STDIN:
  finin = myfile;
  // Parse through the input:
  while(finlex());
}

