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

  // Declare global variables
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
  header instructions footer {
    cout << "footer" << endl;
  };

last_body:
  header instructions END_PRGM {
    cout << "end of program" << endl;
  };
header:
  HEADER {
    cout << "header" << endl;
  };
footer:
  FOOTER {
    cout << "footer" << endl;
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
  STACK_IMP stack_command
  ;
arithmetic:
  ARITH_IMP arith_command
  ;
heap_access:
  HEAP_IMP heap_command
  ;
flow_control:
  FLOW_IMP flow_command
  ;
io_action:
  IOA_IMP io_action_command
  ;
io_control:
  IOC_IMP io_control_command
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
  }
  | STACK_PUSH character {
    cout << "push " << $<cval>2 << " onto the stack" << endl;
  };
stack_duplicate:
  STACK_DUP {
    cout << "duplicate item on top of the stack" << endl;
  };
stack_swap:
  STACK_SWAP {
    cout << "swap items on top of the stack" << endl;
  };
stack_discard:
  STACK_DEL {
    cout << "discard item on top of the stack" << endl;
  };
// arithmetic
addition:
  ADD {
    cout << "addition" << endl;
  };
subtraction:
  SUB {
    cout << "subtraction" << endl;
  };
multiplication:
  MULT {
    cout << "multiplication" << endl;
  };
integer_division:
  DIV {
    cout << "division" << endl;
  };
modulo:
  MOD { 
    cout << "modulo" << endl;
  };
// heap
heap_store:
  HEAP_STORE {
    cout << "heap store" << endl;
  };
heap_retrieve:
  HEAP_RETR {
    cout << "heap retrieve" << endl;
  };
// flow control
new_label:
  MARK label {
    cout << "new label '" << $<sval>2 << "'" << endl;
  };
call_subroutine:
  CALL label {
    cout << "call subroutine at label " << $<sval>2 << endl;
  };
uncond_jump:
  JUMPU label {
    cout << "jump unconditionally to label " << $<sval>2 << endl;
  };
jump_if_zero:
  JUMPZ label {
    cout << "jump to label " << $<sval>2 << " if top of stack is zero" << endl;
  };
jump_if_neg:
  JUMPN label {
    cout << "jump to " << $<sval>2 << " if top of stack is negative" << endl;
  };
end_subroutine:
  RETURN {
    cout << "end subroutine" << endl;
  };
// io action
output_char:
  OUTC {
    cout << "outputting a character to IO" << endl;
  };
output_int:
  OUTN {
    cout << "outputting an integer to IO" << endl;
  };
read_char:
  INC {
    cout << "reading a character from IO" << endl;
  };
read_int:
  INN {
    cout << "reading an integer from IO" << endl;
  };
// io control
stream_file:
  IOC_FILE {
    cout << "streaming from a file" << endl;
  };
stream_net:
  IOC_NET netcon {
    cout << "streaming from network connection" << endl;
  };
stream_stdio:
  IOC_STD {
    cout << "streaming from standard input/output" << endl;
  };

// --- Parameters ---
number:
  NUM
  | UNUM
  ;
character:
  CHAR
  | UCHAR
  ;
label:
  LABEL
  | ULABEL
  ;
netcon:
  NETCON
  ;
// done with grammar
%%

int main(int, char**) {
  // Open a file handle to a particular file:
  FILE *myfile = fopen("test.fin", "r");
  // Make sure it is valid:
  if (!myfile) {
    cout << "I can't open test.fin!" << endl;
    return -1;
  } // end if
  // Set Flex to read from it instead of defaulting to STDIN:
  finin = myfile;

  // Parse through the input:
  finparse();

} // end main

void finerror(const char *s) {
  cout << "Whoopsie daisies! Error while parsing line " << lineNum << ".  Message: " << s << endl;
  // might as well halt now:
  exit(1);
} // end finerror

