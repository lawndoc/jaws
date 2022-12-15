%{
  #include <stdio.h>

  #include "fin.tab.h" // to get the token types from Bison
  extern int finlex();

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
NETCON	[0-9]{1,3}"."[0-9]{1,3}"."[0-9]{1,3}"."[0-9]{1,3}":"[0-9]{1,5}":"("tcp")


%%

[ \t]				;
"//".*				;
\n				{ lineNum++; }
peekn				{ return PEEKN; }
peekc				{ return PEEKC; }
header				{ return HEADER; }
footer				{ return FOOTER; }
stack				{ return STACK_IMP; }
arith				{ return ARITH_IMP; }
heap				{ return HEAP_IMP; }
flow				{ return FLOW_IMP; }
ioa				{ return IOA_IMP; }
ioc				{ return IOC_IMP; }
netcon                          { return NETCON_IMP; }
FIN				{ return END_PRGM; }
push				{ return STACK_PUSH; }
dup				{ return STACK_DUP; }
swap				{ return STACK_SWAP; }
discard				{ return STACK_DEL; }
add				{ return ADD; }
sub				{ return SUB; }
mult				{ return MULT; }
div				{ return DIV; }
mod				{ return MOD; }
store				{ return HEAP_STORE; }
retrieve			{ return HEAP_RETR; }
mark				{ return MARK; }
call				{ return CALL; }
jumpu				{ return JUMPU; }
jumpz				{ return JUMPZ; }
jumpn				{ return JUMPN; }
return				{ return RETURN; }
outc				{ return OUTC; }
outn				{ return OUTN; }
inc				{ return INC; }
inn				{ return INN; }
fileio				{ return IOC_FILE; }
stdio				{ return IOC_STD; }
connect                         { return CONNECT; }
close                           { return CLOSE; }
send                            { return SEND; }
recv                            { return RECV; }
{DIGIT}+			{ finlval.ival = atoi(fintext);
				  return NUM; }
{UDIGIT}			{ finlval.sval = strdup(fintext);
				  return UNUM; }
{CHAR}				{ finlval.cval = fintext[0];
				  return CHAR; }
{UCHAR}				{ finlval.sval = strdup(fintext);
				  return UCHAR; }
{LABEL}				{ finlval.sval = strdup(fintext);
				  return LABEL; }
{ULABEL}			{ finlval.sval = strdup(fintext);
				  return ULABEL; }
{NETCON}			{ finlval.sval = strdup(fintext);
                                  return NETCON; }
.				;

%%

