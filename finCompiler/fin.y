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
  char *genOctet(char *octet);
  char *genPort(char *port);
  char *hexToBin(char hexDig);

  // Declare global variables
  FILE *OUTFILE;  // jaws output file
  char *BITSTR; 
  char *SUBSTR;
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
  bodies last_body
  | last_body
  ;
bodies:
  bodies body
  | body
  ;
body:
  header instructions footer
  ;
last_body:
  header instructions END_PRGM {
    fprintf(OUTFILE, "endProgram\n\n\n");
  };
header:
  HEADER {
    fprintf(OUTFILE, "header\n\t ");
  };
footer:
  FOOTER {
    fprintf(OUTFILE, "footer\n\t ");
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
  STACK_IMP { fprintf(OUTFILE, "stackIMP  "); } stack_command
  ;
arithmetic:
  ARITH_IMP { fprintf(OUTFILE, "arithIMP \t"); } arith_command
  ;
heap_access:
  HEAP_IMP { fprintf(OUTFILE, "heapIMP\t\t"); } heap_command
  ;
flow_control:
  FLOW_IMP { fprintf(OUTFILE, "flowIMP\n "); } flow_command
  ;
io_action:
  IOA_IMP { fprintf(OUTFILE, "ioaIMP\t\n"); } io_action_command
  ;
io_control:
  IOC_IMP { fprintf(OUTFILE, "iocIMP\t "); } io_control_command
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
    fprintf(OUTFILE, "pushNum %s", $<sval>2);
  }
  | STACK_PUSH character {
    fprintf(OUTFILE, "pushChar %s", $<sval>2);
  };
stack_duplicate:
  STACK_DUP {
    fprintf(OUTFILE, "duplicate\n ");
  };
stack_swap:
  STACK_SWAP {
    fprintf(OUTFILE, "swap\n\t");
  };
stack_discard:
  STACK_DEL {
    fprintf(OUTFILE, "discard\n\n");
  };
// arithmetic
addition:
  ADD {
    fprintf(OUTFILE, "addition  ");
  };
subtraction:
  SUB {
    fprintf(OUTFILE, "subtraction \t");

  };
multiplication:
  MULT {
    fprintf(OUTFILE, "multiplication \n");
  };
integer_division:
  DIV {
    fprintf(OUTFILE, "division\t ");
  };
modulo:
  MOD { 
    fprintf(OUTFILE, "modulo\t\t");
  };
// heap
heap_store:
  HEAP_STORE {
    fprintf(OUTFILE, "store ");
  };
heap_retrieve:
  HEAP_RETR {
    fprintf(OUTFILE, "retrieve\t");
  };
// flow control
new_label:
  MARK label {
    fprintf(OUTFILE, "newLabel  %s", $<sval>2);
  };
call_subroutine:
  CALL label {
    fprintf(OUTFILE, "callSubrtn \t%s", $<sval>2);
  };
uncond_jump:
  JUMPU label {
    fprintf(OUTFILE, "uJumpTo \n%s", $<sval>2);
  };
jump_if_zero:
  JUMPZ label {
    fprintf(OUTFILE, "zJumpTo\t %s", $<sval>2);
  };
jump_if_neg:
  JUMPN label {
    fprintf(OUTFILE, "nJumpTo\t\t%s", $<sval>2);
  };
end_subroutine:
  RETURN {
    fprintf(OUTFILE, "endSubrtn\t\n");
  };
// io action
output_char:
  OUTC {
    fprintf(OUTFILE, "outChar  ");
  };
output_int:
  OUTN {
    fprintf(OUTFILE, "outNum \t");
  };
read_char:
  INC {
    fprintf(OUTFILE, "inChar\t ");
  };
read_int:
  INN {
    fprintf(OUTFILE, "inNum\t\t");
  };
// io control
stream_file:
  IOC_FILE {
    fprintf(OUTFILE, "streamFile  ");
  };
stream_net:
  IOC_NET netcon {
    fprintf(OUTFILE, "streamNetCon \t%s", $<sval>2);
  };
stream_stdio:
  IOC_STD {
    fprintf(OUTFILE, "streamStdIO\t ");
  };

// --- Parameters ---
number:
  NUM {
    $<sval>$ = genNum($<ival>1);
    memset(BITSTR, '\0', sizeof(BITSTR));  // reset BITSTR after func. call
  }
  | UNUM { 
    $<sval>$ = genUNum($<sval>1);
    memset(BITSTR, '\0', sizeof(BITSTR));  // reset BITSTR after func. call
  };
character:
  CHAR {
    $<sval>$ = genChar($<cval>1);
    memset(BITSTR, '\0', sizeof(BITSTR));  // reset BITSTR after func. call
  }
  | UCHAR {
    $<sval>$ = genUChar($<sval>1);
    memset(BITSTR, '\0', sizeof(BITSTR));  // reset BITSTR after func. call
  };
label:
  LABEL {
    $<sval>$ = genLabel($<sval>1);
    memset(BITSTR, '\0', sizeof(BITSTR));  // reset BITSTR after func. call
  }
  | ULABEL {
    $<sval>$ = genULabel($<sval>1);
    memset(BITSTR, '\0', sizeof(BITSTR));  // reset BITSTR after func. call
  };
netcon:
  NETCON {
    $<sval>$ = genNetCon($<sval>1);
    memset(BITSTR, '\0', sizeof(BITSTR));  // reset BITSTR after func. call
  };
// done with grammar
%%

int main(int, char**) {
  BITSTR = (char *) malloc(50); // for interpreting parameters MAX=>48+2 (\n\0)
  SUBSTR = (char *) malloc(33); // for building BITSTR in genNetCon
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

  // Clean up
  free(BITSTR);
  free(SUBSTR);
  fclose(OUTFILE);
} // end main

void finerror(const char *s) {
  cout << "Whoopsie daisies! Error while parsing line " << lineNum << ".  Message: " << s << endl;
  // might as well halt now:
  exit(1);
} // end finerror

char *genNum(long num) {
  // global char *BITSTR
  char arr[33];
  long dec = num;
  int i = 0;

  while(dec > 0) {  // builds array of binary ints backwards
    arr[i] = dec % 2;
    i++;
    dec = dec / 2;
  } // end while

  for (i=31; i>=0; i--) {  // builds array of chars from flipped int array
    if (arr[i] == 1) {
//      strcat(BITSTR, "1");
      strcat(BITSTR, "\t");
    } else {
//      strcat(BITSTR, "0");
      strcat(BITSTR, " ");
    } // end if
  } // end for
  strcat(BITSTR, "\n");
  return strdup(BITSTR);  //TODO: fix memory leak
} // end genNum

char *genUNum(char *hexNum) {
  // global char *BITSTR
  char binDig;
  for (int i=2; i<10; i++) {
//    strcat(BITSTR, hexToBin(hexNum[i]));
    binDig = hexToBin(hexNum[i]);
    if binDig == '1'
      strcat(BITSTR, "\t");
    else
      strcat(BITSTR, " ");
  } // end for
  strcat(BITSTR, "\n");
  return strdup(BITSTR);  //TODO: fix memory leak
} // end genUNum

char *genChar(char character) {
  // global char *BITSTR
  for (int i=7; i>=0; --i) {
//    strcat(BITSTR, (character & (1 << i)) ? "1" : "0" );
    strcat(BITSTR, (character & (1 << i)) ? "\t" : " " );
  } // end for
  strcat(BITSTR, "\n");
  return strdup(BITSTR);  //TODO: fix memory leak
} // end genChar

char *genUChar(char *hexChar) {
  // global char *BITSTR
  char binDig;
  for (int i=2; i<4; i++) {
//    strcat(BITSTR, hexToBin(hexChar[i]));
    binDig = hexToBin(hexNum[i]);
    if binDig == '0'
      strcat(BITSTR, " ");
    else
      strcat(BITSTR, "\t");
  } // end for
  strcat(BITSTR, "\n");
  return strdup(BITSTR);  //TODO: fix memory leak
} // end genUChar

char *genLabel(char *label) {
  // global char *BITSTR
  for (int c=0; c<3; c++) {
    for (int i=7; i>=0; --i) {
//      strcat(BITSTR, (label[c] & (1 << i)) ? "1" : "0" );
      strcat(BITSTR, (label[c] & (1 << i)) ? "\t" : " " );
    } // end for (i...
  } // end for (c...
  strcat(BITSTR, "\n");
  return strdup(BITSTR);  //TODO: fix memory leak

} // end genLabel

char *genULabel(char *hexLabel) {
  // global char *BITSTR
  char binDig;
  for (int i=2; i<6; i++) {
    binDig = hexToBin(hexNum[i]);
    if binDig == '0'
      strcat(BITSTR, " ");
    else
      strcat(BITSTR, "\t");
//    strcat(BITSTR, hexToBin(hexLabel[i]));
  } // end for
  strcat(BITSTR, "\n");
  return strdup(BITSTR);  //TODO: fix memory leak
} // end genULabel

char *genNetCon(char *netcon) {
  int i = 0;
  char *octet = (char *) malloc(4);
  char *port = (char *) malloc(6);
  // generate IPv4 bitstring
  do {
    if (netcon[i] == '.' || netcon[i] == ':') {
      strcat(BITSTR, genOctet(octet));
      memset(octet, '\0', sizeof(octet));
      memset(SUBSTR, '\0', sizeof(SUBSTR));
    } else {
      strncat(octet, &netcon[i], 1);
    } // end if
    i++;
  } while (netcon[i-1] != ':'); // end do-while
  // generate port  bitstring
  while (netcon[i] != '\0') {
    strncat(port, &netcon[i], 1);
    i++;
  } // end while
  strcat(BITSTR, genPort(port));
  memset(SUBSTR, '\0', sizeof(SUBSTR));
  strcat(BITSTR, "\n");

  free(octet);
  free(port);
  return strdup(BITSTR);  //TODO: fix memory leak
} // end genNetCon

char *genOctet(char *octet) {
  // calling fn char *SUBSTR
  int arr[8];
  int dec = atoi(octet);
  int i = 0;

  while(dec > 0) {  // builds array of binary ints backwards
    arr[i] = dec % 2;
    i++;
    dec = dec / 2;
  } // end while
  while(i<8) {  // fill the rest of the array with 0's
    arr[i] = 0;
    i++;
  }
 
  for (i=7; i>=0; i--) {  // builds array of chars from flipped int array
    if (arr[i] == 1) {
//      strcat(SUBSTR, "1");
      strcat(SUBSTR, "\t");
    } else {
//      strcat(SUBSTR, "0");
      strcat(SUBSTR, " ");
    } // end if
  } // end for
  return SUBSTR;
} // end genOctet

char *genPort(char *port) {
  // calling fn char *SUBSTR
  int arr[16];
  int dec = atoi(port);
  int i = 0;

  while(dec > 0) {  // builds array of binary ints backwards
    arr[i] = dec % 2;
    i++;
    dec = dec / 2;
  } // end while
  while(i<16) {  // fill the rest of the array with 0's
    arr[i] = 0;
    i++;
  }

  for (i=15; i>=0; i--) {  // builds array of chars from flipped int array
    if (arr[i] == 1) {
//      strcat(SUBSTR, "1");
      strcat(SUBSTR, "\t");
    } else {
//      strcat(SUBSTR, "0");
      strcat(SUBSTR, " ");
    } // end if
  } // end for
  return SUBSTR;
} // end genPort

char *hexToBin(char hexDig) {
  if (hexDig == '0')
    return (char *) "0000";
  else if (hexDig == '1')
    return (char *) "0001";
  else if (hexDig == '2')
    return (char *) "0010";
  else if (hexDig == '3')
    return (char *) "0011";
  else if (hexDig == '4')
    return (char *) "0100";
  else if (hexDig == '5')
    return (char *) "0101";
  else if (hexDig == '6')
    return (char *) "0110";
  else if (hexDig == '7')
    return (char *) "0111";
  else if (hexDig == '8')
    return (char *) "1000";
  else if (hexDig == '9')
    return (char *) "1001";
  else if (hexDig == 'a')
    return (char *) "1010";
  else if (hexDig == 'b')
    return (char *) "1011";
  else if (hexDig == 'c')
    return (char *) "1100";
  else if (hexDig == 'd')
    return (char *) "1101";
  else if (hexDig == 'e')
    return (char *) "1110";
  else if (hexDig == 'f')
    return (char *) "1111";
  else
    exit(1);
} // end hexToBin
