%{
  #include <cstdio>
  #include <iostream>
  #include "lex.yy.c"
  using namespace std;

  // Declare stuff from Flex that Bison needs to know about:
  extern int yylex();
  extern int yyparse();
  extern FILE *yyin;
 
  void yyerror(const char *s);
%}

// Bison fundamentally works by asking flex to get the next token, which it
// returns as an object of type "yystype".  Initially (by default), yystype
// is merely a typedef of "int", but for non-trivial projects, tokens could
// be of any arbitrary data type.  So, to deal with that, the idea is to
// override yystype's default typedef to be a C union instead.  Unions can
// hold all of the types of tokens that Flex could return, and this this means
// we can return ints or floats or strings cleanly.  Bison implements this
// mechanism with the %union directive:

// Define the "terminal symbol" token types I'm going to use (in CAPS
// by convention), and associate each with a field of the %union:
%token SPACE
%token TAB
%token LF

%%
// This is the actual grammar that bison will parse, but for right now it's just
// something silly to echo to the screen what bison gets from flex.  We'll
// make a real one shortly:
jaws:
//  header body_section footer {
  body_section {
    cout << "done with a jaws file!" << endl;
  };
//header:
//  SPACE SPACE TAB TAB TAB LF {
//    cout << "started parsing jaws code!" << endl;
//  };
body_section:
  body_instructions
  ;
body_instructions: 
  body_instructions body_instruction
  | body_instruction 
  ;
body_instruction:
  stack_manipulation
  | arithmetic
  | heap_access
  | flow_control
  | io_action
  | io_control
  ;

// ---- IMP Defs ----
stack_manipulation:
  SPACE SPACE stack_command
  ;
arithmetic:
  SPACE TAB arith_command
  ;
heap_access:
  TAB TAB heap_command
  ;
flow_control:
  LF flow_command
  ;
io_action:
  TAB LF io_action_command
  ;
io_control:
  TAB SPACE io_control_command
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
  | end_program
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
  SPACE number
  ;
stack_duplicate:
  LF SPACE
  ;
stack_swap:
  LF TAB
  ;
stack_discard:
  LF LF
  ;
// arithmetic
addition:
  SPACE SPACE
  ;
subtraction:
  SPACE TAB
  ;
multiplication:
  SPACE LF
  ;
integer_division:
  TAB SPACE
  ;
modulo:
  TAB TAB
  ;
// heap
heap_store:
  SPACE
  ;
heap_retrieve:
  TAB
  ;
// flow control
new_label:
  SPACE SPACE label
  ;
call_subroutine:
  SPACE TAB label
  ;
uncond_jump:
  SPACE LF label
  ;
jump_if_zero:
  TAB SPACE label
  ;
jump_if_neg:
  TAB TAB label
  ;
end_subroutine:
  TAB LF
  ;
end_program:
  LF LF
  ;
// io action
output_char:
  SPACE SPACE
  ;
output_int:
  SPACE TAB
  ;
read_char:
  TAB SPACE
  ;
read_int:
  TAB TAB {
    cout << "reading an integer from io" << endl;
  };
  ;
// io control
stream_file:
  SPACE SPACE {
    cout << "streaming from a file" << endl;
  };
stream_net:
  SPACE TAB ip port {
    cout << "streaming from network connection: " << endl;
  };
stream_stdio:
  TAB SPACE
  ;

// --- Parameters ---
number:
  bits LF {
    cout << "<number> " << endl;
  };
label:
  bits LF {
    cout << "<label> " << endl;
  };
bits:
  bits bit
  | bit
  ;
bit:
  SPACE
  | TAB
  ;
ip:
  octet octet octet octet {
    cout << "<ip> " << endl;
  };
octet:
  bit bit bit bit bit bit bit bit
  ;
port:
  octet octet {
    cout << "<port> " << endl;
  };

// --- Footer ---
//footer:
//  LF LF LF
//  ;

%%

int main(int, char**) {
  // Open a file handle to a particular file:
  FILE *myfile = fopen("test.jaws", "r");
  // Make sure it is valid:
  if (!myfile) {
    cout << "I can't open test.jaws!" << endl;
    return -1;
  }
  // Set Flex to read from it instead of defaulting to STDIN:
  yyin = myfile;
  
  // Parse through the input:
  yyparse();
  
}

void yyerror(const char *s) {
  cout << "Whoopsie daisies, parse error!  Message: " << s << endl;
  // might as well halt now:
  exit(-1);
}
