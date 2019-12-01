%{
  #include <cstdio>
  #include "jaws.tab.h" // to get the token types from Bison
  extern int yylex();
%}
%option noyywrap
%%
" "        { return SPACE; }
\t         { return TAB; }
\n         { return NEWLINE; }
.          ;
%% 
