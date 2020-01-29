%{
  #include <cstdio>
  #include <cstring>
  #include <iostream>
  #include <math.h>
  using namespace std;

  // Declare stuff from Flex that Bison needs to know about:
  extern "C" int finlex();
  extern int finparse();
  extern FILE *finin;
  extern int lineNum;

  // Declare functions
  void finerror(const char *s);
  char *genNum(long num);
  char *genUNum(char *hexNum);
  char *genChar(char character);
  char *genUChar(char *hexChar);
  char *genLabel(char *label);
  char *genULabel(char *hexLabel);
  char *genNetCon(char *netcon);

  // Declare global variables
  FILE *OUTFILE;
%}

%define api.prefix {fin}

%union {
  long ival;
  char cval;
  char *sval;
}

// Declare token types 
%token HEADER
%token FOOTER
%token END_PRGM
%token STACK_IMP
%token ARITH_IMP
%token HEAP_IMP
%token FLOW_IMP
%token IOA_IMP
%token IOC_IMP
%token STACK_PUSH
%token STACK_DUP
%token STACK_SWAP
%token STACK_DEL
%token ADD
%token SUB
%token MULT
%token DIV
%token MOD
%token HEAP_STORE
%token HEAP_RETR
%token MARK
%token CALL
%token JUMPU
%token JUMPZ
%token JUMPN
%token RETURN
%token OUTC
%token OUTN
%token INC
%token INN
%token IOC_FILE
%token IOC_NET
%token IOC_STD
%token <ival> NUM
%token <sval> UNUM
%token <cval> CHAR
%token <sval> UCHAR
%token <sval> LABEL
%token <sval> ULABEL
%token <sval> NETCON

%%

// Grammmar 
fin:
  bodies last_body {
    cout << "done with a fin file!" << endl;
  }
  | last_body {
    cout << "done with a fin file!" << endl;
  };
bodies:
  bodies body
  | body
  ;
body:
  header instructions footer
  ;
last_body:
  header instructions END_PRGM {
    cout << "end of program" << endl;
    fprintf(OUTFILE, "\n\n\n")
  };
header:
  HEADER {
    cout << "header" << endl;
    fprintf(OUTFILE, "\n\t ");
  };
footer:
  FOOTER {
    cout << "footer" << endl;
    fprintf(OUTFILE, "\n\t ");
  };
instructions:
  instructions instruction
  | instruction
  ;
instruction:
  stack_manipulation
  | arithmetic
  | heap_access
  | flow_control
  | io_action
  | io_control
  ;
// ---- IMP Defs ----
stack_manipulation:
  STACK_IMP { fprintf(OUTFILE, "  "); } stack_command
  ;
arithmetic:
  ARITH_IMP { fprintf(OUTFILE, " \t"); } arith_command
  ;
heap_access:
  HEAP_IMP { fprintf(OUTFILE, "\t\t"); } heap_command
  ;
flow_control:
  FLOW_IMP { fprintf(OUTFILE, "\n "); } flow_command
  ;
io_action:
  IOA_IMP { fprintf(OUTFILE, "\t\n"); } io_action_command
  ;
io_control:
  IOC_IMP { fprintf(OUTFILE, "\t "); } io_control_command
  ;
// --- IMP Commands ---
stack_command:
  stack_push
  | stack_duplicate
  | stack_swap
  | stack_discard
  ;
arith_command:
  addition
  | subtraction
  | multiplication
  | integer_division
  | modulo
  ;
heap_command:
  heap_store
  | heap_retrieve
  ;
flow_command:
  new_label
  | call_subroutine
  | uncond_jump
  | jump_if_zero
  | jump_if_neg
  | end_subroutine
  ;
io_action_command:
  output_char
  | output_int
  | read_char
  | read_int
  ;
io_control_command:
  stream_file
  | stream_net
  | stream_stdio
  ;

// -- Command Defs --
// stack
stack_push:
  STACK_PUSH number {
    cout << "push " << $<ival>2 << " onto the stack" << endl;
    fprintf(OUTFILE, " %s", $<sval>2);
  }
  | STACK_PUSH character {
    cout << "push " << $<cval>2 << " onto the stack" << endl;
    fprintf(OUTFILE, " %s", $<sval>2);
  };
stack_duplicate:
  STACK_DUP {
    cout << "duplicate item on top of the stack" << endl;
    fprintf(OUTFILE, "\n ");
  };
stack_swap:
  STACK_SWAP {
    cout << "swap items on top of the stack" << endl;
    fprintf(OUTFILE, "\n\t");
  };
stack_discard:
  STACK_DEL {
    cout << "discard item on top of the stack" << endl;
    fprintf(OUTFILE, "\n\n");
  };
// arithmetic
addition:
  ADD {
    cout << "addition" << endl;
    fprintf(OUTFILE, "  ");
  };
subtraction:
  SUB {
    cout << "subtraction" << endl;
    fprintf(OUTFILE, " \t");

  };
multiplication:
  MULT {
    cout << "multiplication" << endl;
    fprintf(OUTFILE, " \n");
  };
integer_division:
  DIV {
    cout << "division" << endl;
    fprintf(OUTFILE, "\t ");
  };
modulo:
  MOD { 
    cout << "modulo" << endl;
    fprintf(OUTFILE, "\t\t");
  };
// heap
heap_store:
  HEAP_STORE {
    cout << "heap store" << endl;
    fprintf(OUTFILE, " ");
  };
heap_retrieve:
  HEAP_RETR {
    cout << "heap retrieve" << endl;
    fprintf(OUTFILE, "\t");
  };
// flow control
new_label:
  MARK label {
    cout << "new label '" << $<sval>2 << "'" << endl;
    fprintf(OUTFILE, "  %s", $<sval>2);
  };
call_subroutine:
  CALL label {
    cout << "call subroutine at label " << $<sval>2 << endl;
    fprintf(OUTFILE, " \t%s", $<sval>2);
  };
uncond_jump:
  JUMPU label {
    cout << "jump unconditionally to label " << $<sval>2 << endl;
    fprintf(OUTFILE, " \n%s", $<sval>2);
  };
jump_if_zero:
  JUMPZ label {
    cout << "jump to label " << $<sval>2 << " if top of stack is zero" << endl;
    fprintf(OUTFILE, "\t %s", $<sval>2);
  };
jump_if_neg:
  JUMPN label {
    cout << "jump to " << $<sval>2 << " if top of stack is negative" << endl;
    fprintf(OUTFILE, "\t\t%s", $<sval>2);
  };
end_subroutine:
  RETURN {
    cout << "end subroutine" << endl;
    fprintf(OUTFILE, "\t\n");
  };
// io action
output_char:
  OUTC {
    cout << "outputting a character to IO" << endl;
    fprintf(OUTFILE, "  ");
  };
output_int:
  OUTN {
    cout << "outputting an integer to IO" << endl;
    fprintf(OUTFILE, " \t");
  };
read_char:
  INC {
    cout << "reading a character from IO" << endl;
    fprintf(OUTFILE, "\t ");
  };
read_int:
  INN {
    cout << "reading an integer from IO" << endl;
    fprintf(OUTFILE, "\t\t");
  };
// io control
stream_file:
  IOC_FILE {
    cout << "streaming from a file" << endl;
    fprintf(OUTFILE, "  ");
  };
stream_net:
  IOC_NET netcon {
    cout << "streaming from network connection" << endl;
    fprintf(OUTFILE, " \t%s", $<sval>2);
  };
stream_stdio:
  IOC_STD {
    cout << "streaming from standard input/output" << endl;
    fprintf(OUTFILE, "\t ");
  };

// --- Parameters ---
number:
  NUM { $<sval>$ = genNum($<ival>1); }
  | UNUM { $<sval>$ = genUNum($<sval>1); }
  ;
character:
  CHAR { $<sval>$ = genChar($<sval>1); }
  | UCHAR { $<sval>$ = genUChar($<sval>1); }
  ;
label:
  LABEL { $<sval>$ = genLabel($<sval>1); }
  | ULABEL { $<sval>$ = genULabel($<sval>1); }
  ;
netcon:
  NETCON { $<sval>$ = genNetCon($<sval>1); }
  ;
// done with grammar
%%

int main(int, char**) {
  // Open a file handle to a particular file:
  FILE *infile = fopen("test.fin", "r");
  // Make sure it is valid:
  if (!infile) {
    cout << "I can't open test.fin!" << endl;
    return -1;
  } // end if

  // Open output file
  OUTFILE = fopen("out.jaws", "w");

  // Set Flex to read from input file instead of defaulting to STDIN:
  finin = infile;

  // Parse through the input:
  finparse();

  // Close output file
  fclose(outfile);
} // end main

void finerror(const char *s) {
  cout << "Whoopsie daisies! Error while parsing line " << lineNum << ".  Message: " << s << endl;
  // might as well halt now:
  exit(1);
} // end finerror

char *genNum(long num) {

} // end genNum
char *genUNum(char *hexNum) {

} // end genUNum
char *genChar(char character) {

} // end genChar
char *genUChar(char *hexChar) {

} // end genUChar
char *genLabel(char *label) {

} // end genLabel
char *genULabel(char *hexLabel) {

} // end genULabel
char *genNetCon(char *netcon) {

} // end genNetCon
