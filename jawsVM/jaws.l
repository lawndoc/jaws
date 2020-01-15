%{
  #include <cstdio>
  #include <iostream>
  using namespace std;

  #include "jaws.tab.h" // to get the token types from Bison
  extern "C" int yylex();

  int lineNum = 1;
%}
%option noyywrap

%%

" "        { return SPACE; }
\t         { return TAB; }
\n         { lineNum++; return LF; }
.          ;

%%

