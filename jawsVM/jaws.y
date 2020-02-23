%{
  #include <cstdio>
  #include <cstring>
  #include <iostream>
  #include "runtime.h"
  using namespace std;

  // Declare stuff from Flex that Bison needs to know about:
  extern "C" int jawslex();
  extern int jawsparse();
  extern FILE *jawsin;
  extern int lineNum;

  // Declare stuff from runtime library
  extern Program PROGRAM;		// for runtime system
  extern int IPTR;			// for runtime system
  extern Stack STACK;			// for runtime system
  extern Label *JUMPTABLE;		// for runtime system
  extern char BITSTRING[65];		// used for building semantic values
%}

%define api.prefix {jaws}

%union {
  long val;
}

// Declare token types 
%token SPACE
%token TAB
%token LF

%%

// Grammmar 
jaws:
  bodies last_body {
    cout << "done with a jaws file!" << endl;
  }
  | last_body {
    cout << "done with a jaws file!" << endl;
  };
bodies:
  bodies body
  | body
  ;
body:
  header instructions footer
  ;
last_body:
  header instructions end_program
  ;
header:
  extra_lines LF TAB SPACE {
    cout << "Started interpreting jaws code..." << endl;
  }
  | LF TAB SPACE {
    cout << "Started interpreting jaws code..." << endl;
  };
footer:
  LF TAB SPACE {
    cout << "Paused interpreting jaws code..." << endl;
  };
end_program:
  end_instruction extra_lines
  | end_instruction
  ;
end_instruction:
  LF LF LF {
    cout << "end of program" << endl;
  };
extra_lines:
  extra_lines extra_line
  | extra_line
  ;
extra_line:
  SPACE
  | TAB
  | LF
  ;
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
  SPACE SPACE stack_command
  ;
arithmetic:
  SPACE TAB arith_command
  ;
heap_access:
  TAB TAB heap_command
  ;
flow_control:
  LF SPACE flow_command
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
  SPACE number {
    // print value as character when 8 bits
    //cout << "strlen(BITSTRING) == " << strlen(BITSTRING) << endl;
    if (strlen(BITSTRING) == 8) {
      cout << "push " << (char)$<val>2 << " on top of the stack" << endl; 
    } else {
      cout << "push " << $<val>2 << " on top of the stack" << endl;
    } // end if
    add_instruction(&PROGRAM, (char *) "stack_push", $<val>2);
    reset_accum();
  };
stack_duplicate:
  LF SPACE {
    cout << "duplicate item on top of the stack" << endl;
    add_instruction(&PROGRAM, (char *) "stack_duplicate", 0);
  };
stack_swap:
  LF TAB {
    cout << "swap items on top of the stack" << endl;
    add_instruction(&PROGRAM, (char *) "stack_swap", 0);
  };
stack_discard:
  LF LF {
    cout << "discard item on top of the stack" << endl;
    add_instruction(&PROGRAM, (char *) "stack_discard", 0);
  };
// arithmetic
addition:
  SPACE SPACE {
    cout << "addition" << endl;
    add_instruction(&PROGRAM, (char *) "arith_add", 0);
  };
subtraction:
  SPACE TAB {
    cout << "subtraction" << endl;
    add_instruction(&PROGRAM, (char *) "arith_sub", 0);
  };
multiplication:
  SPACE LF {
    cout << "multiplication" << endl;
    add_instruction(&PROGRAM, (char *) "arith_mult", 0);
  };
integer_division:
  TAB SPACE {
    cout << "division" << endl;
    add_instruction(&PROGRAM, (char *) "arith_div", 0);
  };
modulo:
  TAB TAB { 
    cout << "modulo" << endl;
    add_instruction(&PROGRAM, (char *) "arith_mod", 0);
  };
// heap
heap_store:
  SPACE {
    cout << "heap store" << endl;
    add_instruction(&PROGRAM, (char *) "heap_store", 0);
  };
heap_retrieve:
  TAB {
    cout << "heap retrieve" << endl;
    add_instruction(&PROGRAM, (char *) "heap_retrieve", 0);
  };
// flow control
new_label:
  SPACE SPACE label {
    cout << "new label '" << $<val>3 << "'" << endl;
    add_instruction(&PROGRAM, (char *) "flow_mark", $<val>3);
    reset_accum();
  };
call_subroutine:
  SPACE TAB label {
    cout << "call subroutine at label " << $<val>3 << endl;
    add_instruction(&PROGRAM, (char *) "flow_call", $<val>3);
    reset_accum();
  };
uncond_jump:
  SPACE LF label {
    cout << "jump unconditionally to label " << $<val>3 << endl;
    add_instruction(&PROGRAM, (char *) "flow_jumpu", $<val>3);
    reset_accum();
  };
jump_if_zero:
  TAB SPACE label {
    cout << "jump to label " << $<val>3 << " if top of stack is zero" << endl;
    add_instruction(&PROGRAM, (char *) "flow_jumpz", $<val>3);
    reset_accum();
  };
jump_if_neg:
  TAB TAB label {
    cout << "jump to " << $<val>3 << " if top of stack is negative" << endl;
    add_instruction(&PROGRAM, (char *) "flow_jumpn", $<val>3);
    reset_accum();
  };
end_subroutine:
  TAB LF {
    cout << "end subroutine" << endl;
    add_instruction(&PROGRAM, (char *) "flow_return", 0);
  };
// io action
output_char:
  SPACE SPACE {
    cout << "outputting a character to IO" << endl;
    add_instruction(&PROGRAM, (char *) "ioa_outc", 0);
  };
output_int:
  SPACE TAB {
    cout << "outputting an integer to IO" << endl;
    add_instruction(&PROGRAM, (char *) "ioa_outn", 0);
  };
read_char:
  TAB SPACE {
    cout << "reading a character from IO" << endl;
    add_instruction(&PROGRAM, (char *) "ioa_inc", 0);
  };
read_int:
  TAB TAB {
    cout << "reading an integer from IO" << endl;
    add_instruction(&PROGRAM, (char *) "ioa_inn", 0);
  };
  ;
// io control
stream_file:
  SPACE SPACE {
    cout << "streaming from a file" << endl;
    add_instruction(&PROGRAM, (char *) "ioc_file", 0);
  };
stream_net:
  SPACE TAB ip { reset_accum(); } port {
    cout << "streaming from network connection IP: " << $<val>3 << " Port: " << $<val>4 << endl;
    long netcon = $<val>3 << 32 | $<val>4; // combine into one 64 bit parameter
    add_instruction(&PROGRAM, (char *) "ioc_netcon", netcon);
    reset_accum();
  };
stream_stdio:
  TAB SPACE {
    cout << "streaming from standard i/o" << endl;
    add_instruction(&PROGRAM, (char *) "ioc_stdio", 0);
  };

// --- Parameters ---
number:
  bits LF {
    $<val>$ = calc_accum();
  };
label:
  bits LF {
    $<val>$ = calc_accum();
  };
bits:
  bits bit
  | bit
  ;
bit:
  SPACE { accum_add('0'); }
  | TAB { accum_add('1'); }
  ;
ip:
  octet octet octet octet {
    $<val>$ = calc_accum();
  };
octet:
  bit bit bit bit bit bit bit bit
  ;
port:
  octet octet {
    $<val>$ = calc_accum();
  };
// done with grammar
%%

int main(int, char**) {
  // Open a file handle to a particular file:
  FILE *myfile = fopen("test.jaws", "r");
  // Make sure it is valid:
  if (!myfile) {
    cout << "I can't open test.jaws!" << endl;
    return -1;
  } // end if

  // Initialize the program to be built during parsing
  init_Program(&PROGRAM, INIT_PRGM_CAP);

  // Set Flex to read from input file instead of defaulting to STDIN
  jawsin = myfile;

  // Parse the input and build program
  jawsparse();

  // Program is now built, so execute it
  Instr instruction;			// var for current instruction
  IPTR = 0;  				// init instruction pointer
  init_Stack(&STACK, STACK_SIZE);	// init stack
  while (IPTR < PROGRAM.size) {		// fetch and execute instructions
    instruction = PROGRAM.instructions[IPTR];
    (*(instruction.funcPtr))(instruction.param); // (modifies IPTR)
  } // end while
} // end main

