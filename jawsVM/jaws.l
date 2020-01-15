%{
  #include <cstdio>
  #include <iostream>
  using namespace std;

  #include "jaws.tab.h" // to get the token types from Bison
  extern "C" int jawslex();

  int lineNum = 1;
%}

%option noyywrap
%option outfile="lex.jaws.c"
%option prefix="jaws"

%%

" "        { return SPACE; }
\t         { return TAB; }
\n         { lineNum++; return LF; }
.          ;

%%

