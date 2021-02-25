%{
  #include <cstdio>
  #include <cstring>
  #include <iostream>
  #include "runtime.h"
  #include <unistd.h>
  using namespace std;

  // Debug level
  int DEBUG = 0;

  // Declare stuff from Flex that Bison needs to know about:
  extern "C" int jawslex();
  extern int jawsparse();
  extern FILE *jawsin;
  extern int lineNum;

  // Declare stuff from runtime library
  extern Program PROGRAM;		// for runtime system
  extern int IPTR;			// for runtime system
  extern Stack STACK;			// for runtime system
  extern Heap HEAP;			// for runtime system
  extern Jumptable JUMPTABLE;		// for runtime system
  extern int JAWSLINE;			// for calculating instruction line numbers
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
    if (DEBUG > 1)
      cout << "\nDone building program!" << endl;
  }
  | last_body {
    if (DEBUG > 1)
      cout << "\nDone building program!" << endl;
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
    if (DEBUG > 1)
      cout << "Started interpreting Jaws code..." << endl;
    PROGRAM.headFooters++;
    JAWSLINE++;
  }
  | LF TAB SPACE {
    if (DEBUG > 1)
      cout << "Started interpreting Jaws code..." << endl;
    PROGRAM.headFooters++;
    JAWSLINE++;
  };
footer:
  LF TAB SPACE {
    if (DEBUG > 1)
      cout << "Paused interpreting Jaws code..." << endl;
    PROGRAM.headFooters++;
    JAWSLINE++;
  };
end_program:
  end_instruction extra_lines
  | end_instruction
  ;
end_instruction:
  LF LF LF {
    if (DEBUG > 1)
      cout << "end of program" << endl;
    JAWSLINE++;
    JAWSLINE++;
    JAWSLINE++;
  };
extra_lines:
  extra_lines extra_line
  | extra_line
  ;
extra_line:
  SPACE
  | TAB
  | LF {
  JAWSLINE++;
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
  | network_connection
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
  LF {JAWSLINE++;} SPACE flow_command
  ;
io_action:
  TAB LF {JAWSLINE++;} io_action_command
  ;
io_control:
  TAB SPACE io_control_command
  ;
network_connection:
  SPACE LF {JAWSLINE++;} netcon_command
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
  | stream_stdio
  ;
netcon_command:
  netcon_connect
  | netcon_close
  | netcon_send
  | netcon_recv
  ;

// -- Command Defs --
// stack
stack_push:
  SPACE number {
    // print value as character when 8 bits
    //cout << "strlen(BITSTRING) == " << strlen(BITSTRING) << endl;
    if (strlen(BITSTRING) == 8) {
      if (DEBUG > 1)
        if ((char)$<val>2 != '\n') {
          cout << "push " << (char)$<val>2 << " on top of the stack" << endl;
        } else {
          cout << "push \\n on top of the stack" << endl;
        } // end if
      add_instruction(&PROGRAM, (char *) "stack_pushc", $<val>2);
    } else {
      if (DEBUG > 1)
        cout << "push " << $<val>2 << " on top of the stack" << endl;
      add_instruction(&PROGRAM, (char *) "stack_push", $<val>2);
    } // end if
    reset_accum();
    JAWSLINE++;
  };
stack_duplicate:
  LF SPACE {
    if (DEBUG > 1)
      cout << "duplicate item on top of the stack" << endl;
    add_instruction(&PROGRAM, (char *) "stack_duplicate", 0);
    JAWSLINE++;
  };
stack_swap:
  LF TAB {
    if (DEBUG > 1)
      cout << "swap items on top of the stack" << endl;
    add_instruction(&PROGRAM, (char *) "stack_swap", 0);
    JAWSLINE++;
  };
stack_discard:
  LF LF {
    if (DEBUG > 1)
      cout << "discard item on top of the stack" << endl;
    add_instruction(&PROGRAM, (char *) "stack_discard", 0);
    JAWSLINE++;
    JAWSLINE++;
  };
// arithmetic
addition:
  SPACE SPACE {
    if (DEBUG > 1)
      cout << "addition" << endl;
    add_instruction(&PROGRAM, (char *) "arith_add", 0);
  };
subtraction:
  SPACE TAB {
    if (DEBUG > 1)
      cout << "subtraction" << endl;
    add_instruction(&PROGRAM, (char *) "arith_sub", 0);
  };
multiplication:
  SPACE LF {
    if (DEBUG > 1)
      cout << "multiplication" << endl;
    add_instruction(&PROGRAM, (char *) "arith_mult", 0);
    JAWSLINE++;
  };
integer_division:
  TAB SPACE {
    if (DEBUG > 1)
      cout << "division" << endl;
    add_instruction(&PROGRAM, (char *) "arith_div", 0);
  };
modulo:
  TAB TAB { 
    if (DEBUG > 1)
      cout << "modulo" << endl;
    add_instruction(&PROGRAM, (char *) "arith_mod", 0);
  };
// heap
heap_store:
  SPACE {
    if (DEBUG > 1)
      cout << "heap store" << endl;
    add_instruction(&PROGRAM, (char *) "heap_store", 0);
  };
heap_retrieve:
  TAB {
    if (DEBUG > 1)
      cout << "heap retrieve" << endl;
    add_instruction(&PROGRAM, (char *) "heap_retrieve", 0);
  };
// flow control
new_label:
  SPACE SPACE label {
    if (DEBUG > 1)
      cout << "new label '" << $<val>3 << "'" << endl;
    add_instruction(&PROGRAM, (char *) "flow_mark", $<val>3);
    jumptable_mark(&JUMPTABLE, PROGRAM.size, $<val>3);
    reset_accum();
    JAWSLINE++;
  };
call_subroutine:
  SPACE TAB label {
    if (DEBUG > 1)
      cout << "call subroutine at label " << $<val>3 << endl;
    add_instruction(&PROGRAM, (char *) "flow_call", $<val>3);
    reset_accum();
    JAWSLINE++;
  };
uncond_jump:
  SPACE LF label {
    if (DEBUG > 1)
      cout << "jump unconditionally to label " << $<val>3 << endl;
    add_instruction(&PROGRAM, (char *) "flow_jumpu", $<val>3);
    reset_accum();
    JAWSLINE++;
    JAWSLINE++;
  };
jump_if_zero:
  TAB SPACE label {
    if (DEBUG > 1)
      cout << "jump to label " << $<val>3 << " if top of stack is zero" << endl;
    add_instruction(&PROGRAM, (char *) "flow_jumpz", $<val>3);
    reset_accum();
    JAWSLINE++;
  };
jump_if_neg:
  TAB TAB label {
    if (DEBUG > 1)
      cout << "jump to " << $<val>3 << " if top of stack is negative" << endl;
    add_instruction(&PROGRAM, (char *) "flow_jumpn", $<val>3);
    reset_accum();
    JAWSLINE++;
  };
end_subroutine:
  TAB LF {
    if (DEBUG > 1)
      cout << "end subroutine" << endl;
    add_instruction(&PROGRAM, (char *) "flow_return", 0);
    JAWSLINE++;
  };
// io action
output_char:
  SPACE SPACE {
    if (DEBUG > 1)
      cout << "output a character to IO" << endl;
    add_instruction(&PROGRAM, (char *) "ioa_outc", 0);
  };
output_int:
  SPACE TAB {
    if (DEBUG > 1)
      cout << "output an integer to IO" << endl;
    add_instruction(&PROGRAM, (char *) "ioa_outn", 0);
  };
read_char:
  TAB SPACE {
    if (DEBUG > 1)
      cout << "read a character from IO" << endl;
    add_instruction(&PROGRAM, (char *) "ioa_inc", 0);
  };
read_int:
  TAB TAB {
    if (DEBUG > 1)
      cout << "read an integer from IO" << endl;
    add_instruction(&PROGRAM, (char *) "ioa_inn", 0);
  };
// io control
stream_file:
  SPACE SPACE {
    if (DEBUG > 1)
      cout << "stream from a file" << endl;
    add_instruction(&PROGRAM, (char *) "ioc_file", 0);
  };
stream_stdio:
  TAB SPACE {
    if (DEBUG > 1)
      cout << "stream from standard i/o" << endl;
    add_instruction(&PROGRAM, (char *) "ioc_stdio", 0);
  };
// network connection
netcon_connect:
  SPACE TAB ip { reset_accum(); } port { reset_accum(); } netops {
    if (DEBUG > 1) {
      int ip = $<val>3;
      cout << "network connection to IP: " << (ip>>24) << "." << ((ip<<8)>>24) << "." << ((ip<<16)>>24) << "." << ((ip<<24)>>24) << " Port: " << $<val>5 << " OpCode: " << $<val>7 << endl;
    } // end if
    // combine args into one 64 bit param (ip32:port16:ops16)
    long netcon = ($<val>3 << 32) | ($<val>4 << 16) | ($<val>5);
    add_instruction(&PROGRAM, (char *) "netcon_connect", netcon);
    reset_accum();
    JAWSLINE++;
  };
netcon_close:
  SPACE SPACE {
    if (DEBUG > 1)
      cout << "close network connection" << endl;
    add_instruction(&PROGRAM, (char *) "netcon_close", 0);
  };
netcon_send:
  TAB TAB {
    if (DEBUG > 1)
      cout << "send data over network connection" << endl;
    add_instruction(&PROGRAM, (char *) "netcon_send", 0);
  };
netcon_recv:
  TAB SPACE {
    if (DEBUG > 1)
      cout << "receive data over network connection" << endl;
    add_instruction(&PROGRAM, (char *) "netcon_recv", 0);
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
port:
  octet octet {
    $<val>$ = calc_accum();
  };
netops:
  octet octet LF {
    $<val>$ = calc_accum();
  };
octet:
  bit bit bit bit bit bit bit bit
  ;
// done with grammar
%%

int main(int argc, char** argv) {
  // Parse command line args
  int opt;
  char *infileName = NULL;
    
  while((opt = getopt(argc, argv, ":hd:")) != -1)  
  {  
    switch(opt)  
    {  
      case 'h':
        cout << "Usage: " << argv[0] << " [OPTIONS] FILE" << endl;
        cout << "  -h : display help" << endl;
        cout << "  -d <level> : debug level (0-2)" << endl; 
        return 0;
      case 'd':
        DEBUG = atoi(optarg);
        break;
      case ':':
        cout << "Option -" << optopt << " needs a value" << endl;
        break;
      case '?':
        if (sizeof(opt) == 4) {
          cout << "Unknown option '-" << (char)optopt << "'" << endl;
          cout << "Usage: " << argv[0] << " [OPTIONS] FILE" << endl;
          cout << "  -h : display help" << endl;
          cout << "  -d <level> : debug level (0-2)" << endl; 
          return -1;
        } // end if
        break;
    } // end switch
  } // end while

  for (int count=0; optind < argc; optind++){ // remaining arg should be file name
    infileName = argv[optind];
    count++;
    if (count > 1) {
      cout << "Extra option '" << argv[optind] << "'" << endl;
      cout << "Usage: " << argv[0] << " [OPTIONS] FILE" << endl;
      cout << "  -h : display help" << endl;
      cout << "  -d <level> : debug level (0-2)" << endl; 
    } // end if
  } // end for

  // Make sure input file was specified
  if (!infileName) {
    cout << "ERROR: No Jaws file specified or incorrect arguments" << endl;
    cout << "Usage: " << argv[0] << " [OPTIONS] FILE" << endl;
    cout << "  -h : display help" << endl;
    cout << "  -d <level> : debugging level (0..2)" << endl;
    return -1;
  } // end if

  // Open the input file
  FILE *infile = fopen(infileName, "r");
  // Make sure it is valid
  if (!infile) {
    cout << "I can't open " << infileName << "!" << endl;
    return -1;
  } // end if

  // Initialize the program to be built during parsing
  init_Program(&PROGRAM, INIT_PRGM_CAP);

  // Set Flex to read from input file instead of defaulting to STDIN
  jawsin = infile;

  // Initialize jump table to mark parsed labels
  init_Jumptable(&JUMPTABLE, MEM_SIZE);

  // Parse the input and build program
  if (DEBUG > 1) {
    cout << "\nParsing Jaws code from " << infileName << "...\n" << endl;
  } // end if
  jawsparse();

  // Program is now built, so execute it
  Instr instruction;			// var for current instruction
  IPTR = 0;  				// set instruction pointer
  init_Stack(&STACK, MEM_SIZE);		// initialize stack
  init_Heap(&HEAP, MEM_SIZE);		// initialize heap
  if (DEBUG > 0)
    cout << "\nExecuting Jaws program...\n" << endl;
  while (IPTR < PROGRAM.size) {		// fetch and execute instructions
    instruction = PROGRAM.instructions[IPTR];
    (*(instruction.funcPtr))(instruction.param); // (modifies IPTR)
  } // end while
} // end main

