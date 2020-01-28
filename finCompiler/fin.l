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
UDIGIT	0x[0-9a-f]{8}
CHAR	[a-zA-Z]
UCHAR	0x[0-9a-f]{2}
LABEL	[a-z]{1,3}
ULABEL  0x[0-9a-f]{4}
NETCON	ip[0-9a-f]{8}pt[0-9a-f]{4}


%%

[ \t]				;
\n				{ lineNum++; }
header				{ cout << "Header" << endl; }
footer				{ cout << "Footer" << endl; }
stack				{ cout << "Stack IMP" << endl; }
arith				{ cout << "Arithmetic IMP" << endl; }
heap				{ cout << "Heap IMP" << endl; }
flow				{ cout << "Flow IMP" << endl; }
ioa				{ cout << "IO Action IMP" << endl; }
ioc				{ cout << "IO Control IMP" << endl; }
FIN				{ cout << "End of program." << endl; }
push				{ cout << "Stack Push" << endl; }
dup				{ cout << "Stack Duplicate" << endl; }
swap				{ cout << "Stack Swap" << endl; }
discard				{ cout << "Stack Discard" << endl; }
add				{ cout << "Addition" << endl; }
sub				{ cout << "Subraction" << endl; }
mult				{ cout << "Multiplication" << endl; }
div				{ cout << "Division" << endl; }
mod				{ cout << "Modulo" << endl; }
store				{ cout << "Heap Store" << endl; }
retrieve			{ cout << "Heap Retrieve" << endl; }
mark				{ cout << "New Label" << endl; }
call				{ cout << "Call Subroutine" << endl; }
jumpu				{ cout << "Unconditional Jump" << endl; }
jumpz				{ cout << "Jump if Zero" << endl; }
jumpn				{ cout << "Jump if Negative" << endl; }
return				{ cout << "End-Subroutine" << endl; }
outc				{ cout << "Output Character" << endl; }
outn				{ cout << "Output Number" << endl; }
inc				{ cout << "Input Character" << endl; }
inn				{ cout << "Input Number" << endl; }
fileio				{ cout << "Stream FileIO" << endl; }
netcon				{ cout << "Stream NetworkIO" << endl; }
stdio				{ cout << "Stream StdIO" << endl; }
{DIGIT}+			{ cout << "Number: " << yytext << endl; }
{UDIGIT}			{ cout << "Number: " << yytext << endl; }
{CHAR}				{ cout << "Character: " << yytext << endl; }
{UCHAR}				{ cout << "Character: " << yytext << endl; }
{LABEL}				{ cout << "Label: " << yytext << endl; }
{ULABEL}			{ cout << "Label: " << yytext << endl; }
{NETCON}			{ cout << "IP:Port :" << yytext << endl; }
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

