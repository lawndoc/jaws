%{
  #include <cstdio>

  #include "jaws.tab.h" // to get the token types from Bison
%}
%option noyywrap

%%

" "        { return SPACE; }
\t         { return TAB; }
\n         { return LF; }
.          ;

%%

