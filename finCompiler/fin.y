%{
  #include <cstdio>
  #include <cstring>
  #include <iostream>
  #include <math.h>
  #include <unistd.h>
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
  FILE *OUTFILE;	// jaws output file
  char *BITSTR; 
  char *SUBSTR;
  int SUPPRESS = 0;	// output annotation switch
%}

%define api.prefix {fin}

%union {
  long ival;
  char cval;
  char *sval;
}

// Declare token types 
%token PEEKN 		// used for debugging
%token PEEKC		// used for debugging
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
    if (SUPPRESS == 0)
      fprintf(OUTFILE, "endProgram");
    fprintf(OUTFILE, "\n\n\n");
  };
header:
  HEADER {
    if (SUPPRESS == 0)
      fprintf(OUTFILE, "header");
    fprintf(OUTFILE, "\n\t ");
  };
footer:
  FOOTER {
    if (SUPPRESS == 0)
      fprintf(OUTFILE, "footer");
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
  | peek
  ;
peek:
  PEEKN {
    if (SUPPRESS == 0)
      fprintf(OUTFILE, "duplicate");
    fprintf(OUTFILE, "\n ");
    if (SUPPRESS == 0)
      fprintf(OUTFILE, "outNum");
    fprintf(OUTFILE, " \t");
  }
  |
  PEEKC {
    if (SUPPRESS == 0)
      fprintf(OUTFILE, "duplicate");
    fprintf(OUTFILE, "\n ");
    if (SUPPRESS == 0)
      fprintf(OUTFILE, "outC");
    fprintf(OUTFILE, "  ");
  };
// ---- IMP Defs ----
stack_manipulation:
  STACK_IMP {
    if (SUPPRESS == 0)
      fprintf(OUTFILE, "stackIMP");
    fprintf(OUTFILE, "  ");
  } stack_command
  ;
arithmetic:
  ARITH_IMP {
    if (SUPPRESS == 0)
      fprintf(OUTFILE, "arithIMP");
    fprintf(OUTFILE, " \t");
  } arith_command
  ;
heap_access:
  HEAP_IMP {
    if (SUPPRESS == 0)
      fprintf(OUTFILE, "heapIMP");
    fprintf(OUTFILE, "\t\t");
  } heap_command
  ;
flow_control:
  FLOW_IMP {
    if (SUPPRESS == 0)
      fprintf(OUTFILE, "flowIMP");
    fprintf(OUTFILE, "\n ");
  } flow_command
  ;
io_action:
  IOA_IMP {
    if (SUPPRESS == 0)
      fprintf(OUTFILE, "ioaIMP");
    fprintf(OUTFILE, "\t\n");
  } io_action_command
  ;
io_control:
  IOC_IMP {
    if (SUPPRESS == 0)
      fprintf(OUTFILE, "iocIMP");
    fprintf(OUTFILE, "\t ");
  } io_control_command
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
    if (SUPPRESS == 0)
      fprintf(OUTFILE, "pushNum");
    fprintf(OUTFILE, " %s", $<sval>2);
  }
  | STACK_PUSH character {
    if (SUPPRESS == 0)
      fprintf(OUTFILE, "pushChar");
    fprintf(OUTFILE, " %s", $<sval>2);
  };
stack_duplicate:
  STACK_DUP {
    if (SUPPRESS == 0)
      fprintf(OUTFILE, "duplicate");
    fprintf(OUTFILE, "\n ");
  };
stack_swap:
  STACK_SWAP {
    if (SUPPRESS == 0)
      fprintf(OUTFILE, "swap");
    fprintf(OUTFILE, "\n\t");
  };
stack_discard:
  STACK_DEL {
    if (SUPPRESS == 0)
      fprintf(OUTFILE, "discard");
    fprintf(OUTFILE, "\n\n");
  };
// arithmetic
addition:
  ADD {
    if (SUPPRESS == 0)
      fprintf(OUTFILE, "addition");
    fprintf(OUTFILE, "  ");
  };
subtraction:
  SUB {
    if (SUPPRESS == 0)
      fprintf(OUTFILE, "subtraction");
    fprintf(OUTFILE, " \t");

  };
multiplication:
  MULT {
    if (SUPPRESS == 0)
      fprintf(OUTFILE, "multiplication");
    fprintf(OUTFILE, " \n");
  };
integer_division:
  DIV {
    if (SUPPRESS == 0)
      fprintf(OUTFILE, "division");
    fprintf(OUTFILE, "\t ");
  };
modulo:
  MOD { 
    if (SUPPRESS == 0)
      fprintf(OUTFILE, "modulo");
    fprintf(OUTFILE, "\t\t");
  };
// heap
heap_store:
  HEAP_STORE {
    if (SUPPRESS == 0)
      fprintf(OUTFILE, "store");
    fprintf(OUTFILE, " ");
  };
heap_retrieve:
  HEAP_RETR {
    if (SUPPRESS == 0)
      fprintf(OUTFILE, "retrieve");
    fprintf(OUTFILE, "\t");
  };
// flow control
new_label:
  MARK label {
    if (SUPPRESS == 0)
      fprintf(OUTFILE, "newLabel");
    fprintf(OUTFILE, "  %s", $<sval>2);
  };
call_subroutine:
  CALL label {
    if (SUPPRESS == 0)
      fprintf(OUTFILE, "callSubrtn");
    fprintf(OUTFILE, " \t%s", $<sval>2);
  };
uncond_jump:
  JUMPU label {
    if (SUPPRESS == 0)
      fprintf(OUTFILE, "uJumpTo");
    fprintf(OUTFILE, " \n%s", $<sval>2);
  };
jump_if_zero:
  JUMPZ label {
    if (SUPPRESS == 0)
      fprintf(OUTFILE, "zJumpTo");
    fprintf(OUTFILE, "\t %s", $<sval>2);
  };
jump_if_neg:
  JUMPN label {
    if (SUPPRESS == 0)
      fprintf(OUTFILE, "nJumpTo");
    fprintf(OUTFILE, "\t\t%s", $<sval>2);
  };
end_subroutine:
  RETURN {
    if (SUPPRESS == 0)
      fprintf(OUTFILE, "endSubrtn");
    fprintf(OUTFILE, "\t\n");
  };
// io action
output_char:
  OUTC {
    if (SUPPRESS == 0)
      fprintf(OUTFILE, "outChar");
    fprintf(OUTFILE, "  ");
  };
output_int:
  OUTN {
    if (SUPPRESS == 0)
      fprintf(OUTFILE, "outNum");
    fprintf(OUTFILE, " \t");
  };
read_char:
  INC {
    if (SUPPRESS == 0)
      fprintf(OUTFILE, "inChar");
    fprintf(OUTFILE, "\t ");
  };
read_int:
  INN {
    if (SUPPRESS == 0)
      fprintf(OUTFILE, "inNum");
    fprintf(OUTFILE, "\t\t");
  };
// io control
stream_file:
  IOC_FILE {
    if (SUPPRESS == 0)
      fprintf(OUTFILE, "streamFile");
    fprintf(OUTFILE, "  ");
  };
stream_net:
  IOC_NET netcon {
    if (SUPPRESS == 0)
      fprintf(OUTFILE, "streamNetCon");
    fprintf(OUTFILE, " \t%s", $<sval>2);
  };
stream_stdio:
  IOC_STD {
    if (SUPPRESS == 0)
      fprintf(OUTFILE, "streamStdIO");
    fprintf(OUTFILE, "\t ");
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

int main(int argc, char** argv) {
  BITSTR = (char *) malloc(50); // for interpreting parameters MAX=>48+2 (\n\0)
  SUBSTR = (char *) malloc(33); // for building BITSTR in genNetCon

  // Parse command line args
  int opt;
  char *outfileName = (char *) "out.jaws";
  char *infileName = NULL;
    
  while((opt = getopt(argc, argv, ":ho:s")) != -1)  
  {  
    switch(opt)  
    {  
      case 'h':
        cout << "Usage: " << argv[0] << " [OPTIONS] FILE" << endl;
        cout << "  -h : display help" << endl;
        cout << "  -o <file> : specify outfile" << endl;
        cout << "  -s : suppress output file annotation" << endl;
        return 0;
      case 'o':
        outfileName = optarg;
        break;
      case 's':
        SUPPRESS = 1;
	printf("Suppressing output file annotation\n");
        break;
      case ':':
        cout << "Option -" << optopt << " needs a value" << endl;
        break;
      case '?':
        if (sizeof(opt) == 4) {
          cout << "Unknown option '-" << (char)optopt << "'" << endl;
          cout << "Usage: " << argv[0] << " [OPTIONS] FILE" << endl;
          cout << "  -h : display help" << endl;
          cout << "  -o <file> : specify outfile" << endl; 
          cout << "  -s : suppress output file annotation" << endl;
          return -1;
        } // end if
        break;
    } // end switch
  } // end while

  for (int count=0; optind < argc; optind++){ // extra arg should be file name
    infileName = argv[optind];
    count++;
    if (count > 1) {
      cout << "Extra option '" << argv[optind] << "'" << endl;
      cout << "Usage: " << argv[0] << " [OPTIONS] FILE" << endl;
      cout << "  -h : display help" << endl;
      cout << "  -o <file> : specify outfile" << endl;
      cout << "  -s : suppress output file annotation" << endl;
    } // end if
  } // end for

  // Make sure input file was specified
  if (!infileName) {
    cout << "ERROR: No Fin file specified." << endl;
    cout << "Usage: " << argv[0] << " [OPTIONS] FILE" << endl;
    cout << "  -h : display help" << endl;
    cout << "  -o <file> : specify outfile" << endl;
    cout << "  -s : suppress output file annotation" << endl;
    return -1;
  } // end if
  // Open the input file
  FILE *infile = fopen(infileName, "r");
  // Make sure it is valid
  if (!infile) {
    cout << "I can't open " << infileName << "!" << endl;
    return -1;
  } // end if

  // Open the output file
  OUTFILE = fopen(outfileName, "w");
  // Make sure it is valid
  if (!OUTFILE) {
    cout << "I can't open " << outfileName << "!" << endl;
    return -1;
  } // end if

  // Set Flex to read from input file instead of defaulting to STDIN
  finin = infile;

  // Parse through the input
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
  char *binDig = (char *) malloc(33);
  for (int i=2; i<10; i++) {
//    strcat(BITSTR, hexToBin(hexNum[i]));
    strcat(binDig, hexToBin(hexNum[i]));
  } // end for
  for (int i=0; i<32; i++) {
    if (binDig[i] == '1')
      strcat(BITSTR, "\t");
    else
      strcat(BITSTR, " ");  strcat(BITSTR, "\n");
  } // end for
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
  char *binDig = (char *) malloc(5);
  for (int i=2; i<4; i++) {
//    strcat(BITSTR, hexToBin(hexChar[i]));
    strcat(binDig, hexToBin(hexChar[i]));
  } // end for
  for (int i=0; i<8; i++) {
    if (binDig[i] == '1')
      strcat(BITSTR, "\t");
    else
      strcat(BITSTR, " ");  strcat(BITSTR, "\n");
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
  char *binDig = (char *) malloc(5);
  for (int i=2; i<6; i++) {
//    strcat(BITSTR, hexToBin(hexLabel[i]));
    strcat(binDig, hexToBin(hexLabel[i]));
  } // end for
  for (int i=0; i<16; i++) {
    if (binDig[i] == '1')
      strcat(BITSTR, "\t");
    else
      strcat(BITSTR, " ");  strcat(BITSTR, "\n");
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
