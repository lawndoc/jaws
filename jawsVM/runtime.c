#include <ctype.h>
#include <math.h>
#include "runtime.h"
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

//-------------------------------//
// --- Variable Declarations --- //
//-------------------------------//

// Declare debug level from command line arg
extern int DEBUG;

// Declare stuff from Flex and Bison
extern int lineNum;		// for jawserror function

// Declare global variables
Program PROGRAM;		// for runtime system
int IPTR;			// for runtime system
Stack STACK;			// for runtime system
Heap HEAP;			// for runtime system
Jumptable JUMPTABLE;		// for runtime system
char IOSTREAM = 's';		// for runtime system
FILE *FILESTREAM;		// for runtime system
int JAWSLINE = 1;		// for calculating instruction line numbers
char BITSTRING[65];		// for building semantic values
long ACCUM = 0x0000000000000000;// for building semantic values
short COUNT = 0;		// for building semantic values

//----------------------------------//
// --- Data Structure Functions --- //
//----------------------------------//

//--- Instr Functions ---//
void init_Instr(Instr *instruction, char *name, long parameter) {
  instruction->param = parameter;
  if (strcmp(name, "stack_push") == 0)
    instruction->funcPtr = &stack_push;
  else if (strcmp(name, "stack_pushc") == 0)
    instruction->funcPtr = &stack_pushc;
  else if (strcmp(name, "stack_duplicate") == 0)
    instruction->funcPtr = &stack_duplicate;
  else if (strcmp(name, "stack_swap") == 0)
    instruction->funcPtr = &stack_swap;
  else if (strcmp(name, "stack_discard") == 0)
    instruction->funcPtr = &stack_discard;
  else if (strcmp(name, "arith_add") == 0)
    instruction->funcPtr = &arith_add;
  else if (strcmp(name, "arith_sub") == 0)
    instruction->funcPtr = &arith_sub;
  else if (strcmp(name, "arith_mult") == 0)
    instruction->funcPtr = &arith_mult;
  else if (strcmp(name, "arith_div") == 0)
    instruction->funcPtr = &arith_div;
  else if (strcmp(name, "arith_mod") == 0)
    instruction->funcPtr = &arith_mod;
  else if (strcmp(name, "heap_store") == 0)
    instruction->funcPtr = &heap_store;
  else if (strcmp(name, "heap_retrieve") == 0)
    instruction->funcPtr = &heap_retrieve;
  else if (strcmp(name, "flow_mark") == 0)
    instruction->funcPtr = &flow_mark;
  else if (strcmp(name, "flow_call") == 0)
    instruction->funcPtr = &flow_call;
  else if (strcmp(name, "flow_jumpu") == 0)
    instruction->funcPtr = &flow_jumpu;
  else if (strcmp(name, "flow_jumpz") == 0)
    instruction->funcPtr = &flow_jumpz;
  else if (strcmp(name, "flow_jumpn") == 0)
    instruction->funcPtr = &flow_jumpn;
  else if (strcmp(name, "flow_return") == 0)
    instruction->funcPtr = &flow_return;
  else if (strcmp(name, "ioa_outc") == 0)
    instruction->funcPtr = &ioa_outc;
  else if (strcmp(name, "ioa_outn") == 0)
    instruction->funcPtr = &ioa_outn;
  else if (strcmp(name, "ioa_inc") == 0)
    instruction->funcPtr = &ioa_inc;
  else if (strcmp(name, "ioa_inn") == 0)
    instruction->funcPtr = &ioa_inn;
  else if (strcmp(name, "ioc_file") == 0)
    instruction->funcPtr = &ioc_file;
  else if (strcmp(name, "ioc_netcon") == 0)
    instruction->funcPtr = &ioc_netcon;
  else if (strcmp(name, "ioc_stdio") == 0)
    instruction->funcPtr = &ioc_stdio;
  instruction->name = name;
  instruction->jawsLine = JAWSLINE;
} // end new_instruction


//--- Program Functions---//
void init_Program(Program *program, int capacity) {
  program->instructions = (Instr *) malloc(capacity * sizeof(Instr));
  program->size = 0;
  program->capacity = capacity;
  program->headFooters = 0;
} // end init_Program

void add_instruction(Program *program, char *name, long parameter) {
  Instr instruction;
  if (program->size >= program->capacity) {
    program->capacity *= 2;
    program->instructions = (Instr *) realloc(program->instructions, program->capacity * sizeof(Instr));
  } // end if
  init_Instr(&instruction, name, parameter);
  program->instructions[program->size] = instruction;
  program->size++;
} // end add_instruction


//--- Stack Functions ---//
void init_Stack(Stack *stack, int capacity) {
  stack->stack = (long long *) malloc(capacity * sizeof(long long));
  stack->types = (char *) malloc(capacity * sizeof(char));
  stack->top = 0;
  stack->types[stack->top] = 'x';
  stack->capacity = capacity;
} // end init_Stack

void push_num(Stack *stack, long data) {
  stack->top++;
  if (stack->top >= stack->capacity) {
    stack->capacity *= 2;
    stack->stack = (long long *) realloc(stack->stack, stack->capacity * sizeof(long long));
    stack->types = (char *) realloc(stack->types, stack->capacity * sizeof(char));
  } // end if
  stack->stack[stack->top] = (long long) data;
  stack->types[stack->top] = 'n';
} // end push_num

void push_char(Stack *stack, long data) {
  stack->top++;
  if (stack->top >= stack->capacity) {
    stack->capacity *= 2;
    stack->stack = (long long *) realloc(stack->stack, stack->capacity * sizeof(long long));
    stack->types = (char *) realloc(stack->types, stack->capacity * sizeof(char));
  } // end if
  stack->stack[stack->top] = (long long) data;
  stack->types[stack->top] = 'c';
} // end push_char

void push_address(Stack *stack, long *pointer) {
  stack->top++;
  if (stack->top >= stack->capacity) {
    stack->capacity *= 2;
    stack->stack = (long long *) realloc(stack->stack, stack->capacity * sizeof(long long));
    stack->types = (char *) realloc(stack->types, stack->capacity * sizeof(char));
  } // end if
  stack->stack[stack->top] = (long long) pointer;
  stack->types[stack->top] = 'a';
} // end push_address

long pop_num(Stack *stack) {
  long data = (long) stack->stack[stack->top];
  if (stack->types[stack->top] != 'n') {
    if (stack->types[stack->top] == 'c')
      stackerror("Expected to pop a Number but found a Character");
    else if (stack->types[stack->top] == 'a')
      stackerror("Expected to pop a Number but found an Address");
    else if (stack->types[stack->top] == 'x')
      stackerror("Reached bottom of the stack when trying to pop a Number");
  } // end if
  stack->top--;
  return data;
} // end pop_num

long pop_char(Stack *stack) {
  long data = (long) stack->stack[stack->top];
  if (stack->types[stack->top] != 'c') {
    if (stack->types[stack->top] == 'n')
      stackerror("Expected to pop a Character but found a Number");
    else if (stack->types[stack->top] == 'a')
      stackerror("Expected to pop a Character but found an Address");
    else if (stack->types[stack->top] == 'x')
      stackerror("Reached bottom of the stack when trying to pop a Character");
  } // end if
  stack->top--;
  return data;
} // end pop_char

long *pop_address(Stack *stack) {
  long *pointer = (long *) stack->stack[stack->top];
  if (stack->types[stack->top] != 'a') {
    if (stack->types[stack->top] == 'n')
      stackerror("Expected to pop an Address but found a Number");
    else if (stack->types[stack->top] == 'c')
      stackerror("Expected to pop an Address but found a Character");
    else if (stack->types[stack->top] == 'x')
      stackerror("Reached bottom of the stack when trying to pop an Address");
  } // end if
  stack->top--;
  return pointer;
} // end pop_address


//--- Heap Functions ---//
void init_Heap(Heap *heap, int capacity) {
  heap->heap = (long *) malloc(capacity * sizeof(long));
  heap->types = (char *) malloc(capacity * sizeof(char));
  heap->capacity = capacity;
} // end init_Heap

void store_num(Heap *heap, long value, long address) {
  if (address > (long)heap->capacity) {
    heap->capacity *= 2;
    heap->heap = (long *) realloc(heap->heap, heap->capacity * sizeof(long));
    heap->types = (char *) realloc(heap->types, heap->capacity * sizeof(char));
  } // end if
  heap->heap[address] = value;
  heap->types[address] = 'n';
} // end store_num

void store_char(Heap *heap, long value, long address) {
  if (address > (long)heap->capacity) {
    heap->capacity *= 2;
    heap->heap = (long *) realloc(heap->heap, heap->capacity * sizeof(long));
    heap->types = (char *) realloc(heap->types, heap->capacity * sizeof(char));
  } // end if
  heap->heap[address] = value;
  heap->types[address] = 'c';
} // end store_num


//--- Jump Table Functions ---//
void init_Label(Label *record, int label, int index) {
  record->label = label;
  record->index = index;
} // end init_Label

void init_Jumptable(Jumptable *jumptable, int capacity) {
  Stack stack;
  init_Stack(&stack, capacity);
  jumptable->jumptable = NULL;
  jumptable->callStack = stack;
} // end init_Jumptable

void jumptable_mark(Jumptable *jumptable, int index, long identifier) {
  Label *record;
  HASH_FIND_INT(JUMPTABLE.jumptable, &identifier, record);
  if (record == NULL) {
    record = (Label *) malloc(sizeof(Label));
    init_Label(record, (int) identifier, index);
    HASH_ADD_INT(JUMPTABLE.jumptable, label, record);
  } else {
    runtimeerror("Tried to create label that already exists");
  } // end if
} // end jumptable_mark

int jumptable_find(Jumptable *jumptable, long identifier) {
  Label *record;
  int label = (int) identifier;
  HASH_FIND_INT(JUMPTABLE.jumptable, &label, record);
  return record->index;
} // end jumptable_get

void jumptable_call(Jumptable *jumptable, int index) {
  push_num(&(jumptable->callStack), (long)index);
} // end jumptable_call

int jumptable_return(Jumptable *jumptable) {
  int index = (int) pop_num(&(jumptable->callStack));
  return index;
} // end jumptable_return


//---------------------------//
// --- Runtime Functions --- //
//---------------------------//

// Instruction Functions
void stack_push(long parameter) {
  if (DEBUG > 0)
    printf("Stack Push: %ld\n", parameter);
  push_num(&STACK, parameter);
  IPTR++;
} // end stack_pushn
void stack_pushc(long parameter) {
  if (DEBUG > 0)
    printf("Stack Push: %c\n", (char) parameter);
  push_char(&STACK, parameter);
  IPTR++;
} // end stack_pushc

void stack_duplicate(long noParam) {
  if (DEBUG > 0)
    printf("Stack Duplicate\n");
  long topVal = STACK.stack[STACK.top];
  char topType = STACK.types[STACK.top];
  if (topType == 'n')
    push_num(&STACK, topVal);
  else if (topType == 'c')
    push_char(&STACK, topVal);
  else if (topType == 'x')
    stackerror("Stack is empty -- cannot duplicate top item");
  else
    stackerror("Reached unexpected type on the stack... How did this happen?");
  IPTR++;
} // end stack_duplicate

void stack_swap(long noParam) {
  if (DEBUG > 0)
    printf("Stack Swap\n");
  long firstVal;
  long secondVal;
  char firstType = STACK.types[STACK.top];
  char secondType = STACK.types[STACK.top-1];
  // pop top element
  if (firstType == 'n')
    firstVal = pop_num(&STACK);
  else if (firstType == 'c')
    firstVal = pop_char(&STACK);
  else if (firstType == 'x')
    stackerror("Stack is empty -- cannot swap top two items");
  else
    stackerror("Reached unexpected type on the stack... How did this happen?");
  // pop second element
  if (secondType == 'n')
    secondVal = pop_num(&STACK);
  else if (secondType == 'c')
    secondVal = pop_char(&STACK);
  else if (secondType == 'x')
    stackerror("Only one item on the stack -- cannot swap top two items");
  else
    stackerror("Reached unexpected type on the stack... How did this happen?");
  // push top element first
  if (firstType == 'n')
    push_num(&STACK, firstVal);
  else if (firstType == 'c')
    push_char(&STACK, firstVal);
  // push second element on top
  if (secondType == 'n')
    push_num(&STACK, secondVal);
  else if (secondType == 'c')
    push_char(&STACK, secondVal);
  IPTR++;

} // end stack_swap

void stack_discard(long noParam) {
  if (DEBUG > 0)
    printf("Stack Discard\n");
  char topType = STACK.types[STACK.top];
  if (topType == 'n')
    pop_num(&STACK);
  else if (topType == 'c')
    pop_char(&STACK);
  else if (topType == 'x')
    stackerror("Stack is empty -- cannot discard top item");
  else
    stackerror("Reached unexpected type on the stack... How did this happen?");
  IPTR++;
} // end stack_discard

void arith_add(long noParam) {
  if (DEBUG > 0)
    printf("Add\n");
  long left = pop_num(&STACK);
  long right = pop_num(&STACK);
  push_num(&STACK, (left+right));
  IPTR++;
} // end arith_add

void arith_sub(long noParam) {
  if (DEBUG > 0)
    printf("Subtract\n");
  long left = pop_num(&STACK);
  long right = pop_num(&STACK);
  push_num(&STACK, (left-right));
  IPTR++;
} // end arith_sub

void arith_mult(long noParam) {
  if (DEBUG > 0)
    printf("Multiply\n");
  long left = pop_num(&STACK);
  long right = pop_num(&STACK);
  push_num(&STACK, (left*right));
  IPTR++;
} // end arith_mult

void arith_div(long noParam) {
  if (DEBUG > 0)
    printf("Divide\n");
  long left = pop_num(&STACK);
  long right = pop_num(&STACK);
  push_num(&STACK, (left/right));
  IPTR++;
} // end arith_div

void arith_mod(long noParam) {
  if (DEBUG > 0)
    printf("Modulo\n");
  long left = pop_num(&STACK);
  long right = pop_num(&STACK);
  push_num(&STACK, (left%right));
  IPTR++;
} // end arith_mod

void heap_store(long noParam) {
  if (DEBUG > 0)
    printf("Heap Store\n");
  long topVal;
  long address;
  char topType = STACK.types[STACK.top];
  if (topType == 'x')
    stackerror("Stack completely empty when attempting heap store");
  char addressType = STACK.types[STACK.top-1];
  if (addressType == 'c')
    stackerror("Address on stack is a character value, not a number");
  else if (addressType == 'x')
    stackerror("Hit bottom of the stack when reading a store address");
  else if (addressType != 'n')
    stackerror("Unknown type on the stack... How did this happen?");
  if (topType == 'n') {
    topVal = pop_num(&STACK);
    address = pop_num(&STACK);
    store_num(&HEAP, topVal, address);
  } else if (topType == 'c') {
    topVal = pop_char(&STACK);
    address = pop_num(&STACK);
    store_char(&HEAP, topVal, address);
  } else {
    stackerror("Reached unexpected type on the stack... How did this happen?");
  } // end if
  IPTR++;
} // end heap_store

void heap_retrieve(long noParam) { // note: doesn't use Heap structure functions
  if (DEBUG > 0)
    printf("Heap Retrieve\n");
  long value;
  long address;
  char valueType;
  char addressType = STACK.types[STACK.top];
  if (addressType == 'c')
    stackerror("Address value on stack is a character, not a number");
  else if (addressType == 'x')
    stackerror("Hit bottom of the stack when reading a retrieve address");
  else if (addressType != 'n')
    stackerror("Unknown type on the stack... How did this happen?");
  address = pop_num(&STACK);
  if ((int)address > HEAP.capacity)
    heaperror("Heap address out of bounds");
  valueType = HEAP.types[address];
  if (valueType == '\0')
    heaperror("Invalid heap address -- no data found");
  value = HEAP.heap[address];
  if (valueType == 'n') {
    push_num(&STACK, value);
  } else if (valueType == 'c') { 
    push_char(&STACK, value);
  } else { // this might happen if empty address is read and type is not '\0'
    heaperror("Found unexpected type on the heap... How did this happen?");
  } // end if
  IPTR++;
} // end heap_retrieve

void flow_mark(long parameter) {
  if (DEBUG > 0)
    printf("Label: %lx\n", parameter);
  IPTR++;
} // end flow_mark

void flow_call(long parameter) {
  if (DEBUG > 0)
    printf("Call Subroutine at label: 0x%lx\n", parameter);
  jumptable_call(&JUMPTABLE, IPTR+1);
  IPTR = jumptable_find(&JUMPTABLE, parameter);
} // end flow_call

void flow_jumpu(long parameter) {
  if (DEBUG > 0)
    printf("Unconditional Jump to label: 0x%lx\n", parameter);
  IPTR = jumptable_find(&JUMPTABLE, parameter);
} // end flow_jumpu

void flow_jumpz(long parameter) {
  if (DEBUG > 0)
    printf("Jump if Zero to label: 0x%lx\n", parameter);
  if (STACK.types[STACK.top] != 'n')
    stackerror("Cannot do conditional jump without a number on top of the stack");
  if (STACK.stack[STACK.top] == 0)
    IPTR = jumptable_find(&JUMPTABLE, parameter);
  else
    IPTR++;
} // end flow_jumpz

void flow_jumpn(long parameter) {
  if (DEBUG > 0)
    printf("Jump if Negative to label: 0x%lx\n", parameter);
  if (STACK.types[STACK.top] != 'n')
    stackerror("Cannot do conditional jump without a number on top of the stack");
  if (STACK.stack[STACK.top] < 0)
    IPTR = jumptable_find(&JUMPTABLE, parameter);
  else
    IPTR++;
} // end flow_jumpn

void flow_return(long noParam) {
  if (DEBUG > 0)
    printf("Return from Subroutine to instruction: %d\n", (int) JUMPTABLE.callStack.stack[JUMPTABLE.callStack.top]);
  IPTR = jumptable_return(&JUMPTABLE);
} // end flow_return

void ioa_outc(long noParam) {
  if (DEBUG > 0)
    printf("Output Character: ");
  char output = (char) pop_char(&STACK);
  // determine I/O mode
  if (IOSTREAM == 's') {
    printf("%c", output);
    if (DEBUG > 0)
      printf("\n");
  } else if (IOSTREAM == 'f') {
    if (FILESTREAM == NULL)
      runtimeerror("Tried writing character to file before it was opened, or the file was not successfully opened.");
    if (DEBUG > 0)
      printf("%c\n", output);
    fprintf(FILESTREAM, "%c", output);
  } else if (IOSTREAM == 'n') {
    // TODO : save for later
  } else {
    runtimeerror("Invalid IO Stream type... How did this happen?");
  } // end if (IOSTREAM...
  IPTR++;
} // end ioa_outc

void ioa_outn(long noParam) {
  if (DEBUG > 0)
    printf("Output Number: ");
  long output = pop_num(&STACK);
  if (IOSTREAM == 's') {
    printf("%ld", output);
    if (DEBUG > 0)
      printf("\n");
  } else if (IOSTREAM == 'f') {
    if (FILESTREAM == NULL)
      runtimeerror("Tried writing number to file before it was opened, or the file was not successfully opened.");
    if (DEBUG > 0)
      printf("%ld\n", output);
    fprintf(FILESTREAM, "%ld", output);
  } else if (IOSTREAM == 'n') {
    // TODO : save for later
  } else {
    runtimeerror("Invalid IO Stream type... How did this happen?");
  } // end if (IOSTREAM...
  IPTR++;
} // end ioa_outn

void ioa_inc(long noParam) {
  if (DEBUG > 0)
    printf("Input Character: ");
  char input;
  if (IOSTREAM == 's') {
    input = getchar();
  } else if (IOSTREAM == 'f') {
    if (FILESTREAM == NULL)
      runtimeerror("Tried writing number to file before it was opened, or the file was not successfully opened.");
    if (feof(FILESTREAM))
      runtimeerror("Tried reading a character, but reached EOF.");
    input = (char) fgetc(FILESTREAM);
  } else if (IOSTREAM == 'n') {
    // TODO : save for later
  } else {
    runtimeerror("Invalid IO Stream type... How did this happen?");
  } // end if (IOSTREAM...
  if (DEBUG > 0)
    printf("%c\n", input);
  push_char(&STACK, (long) input);
  IPTR++;
} // end ioa_inc

void ioa_inn(long noParam) {
  if (DEBUG > 0)
    printf("Input Number: ");
  long input;
  char buf[MEM_SIZE];
  char *extra;
  if (IOSTREAM == 's') {
    if (fgets(buf, sizeof(buf), stdin) != NULL) {
      input = strtol(buf, &extra, 10);
      if (buf[0] == '\n' || (*extra != '\n' && *extra != '\0')) 
        runtimeerror("Extra characters found in number input");
    } else {
      runtimeerror("Error reading number from stdin -- NULL input");
    } // end if(fgets(...
  } else if (IOSTREAM == 'f') {
    if (FILESTREAM == NULL) {
      runtimeerror("Tried writing number to file before it was opened, or the file was not successfully opened.");
    } // end if (FILESTREAM...
    if (feof(FILESTREAM))
      runtimeerror("Tried reading a number, but reached EOF.");
    if (fscanf(FILESTREAM, " %s", buf) != 1) // TODO: unsafe -- buffer overflow
      runtimeerror("Error reading number from file -- nothing was scanned");
    int length = strlen(buf);
    for (int i=0;i<length;i++) {
      if (buf[i] == '-' && i == 0)
         continue;
      if (!isdigit(buf[i])) {
	char errormsg[36+MEM_SIZE+1] = "String read from file not a number: ";
        strncat(errormsg, buf, MEM_SIZE);
        runtimeerror(errormsg);
      } // end if
      input = strtol(buf, &extra, 10);
    } // end for
  } else if (IOSTREAM == 'n') {
    // TODO : save for later
  } else {
    runtimeerror("Invalid IO Stream type... How did this happen?");
  } // end if (IOSTREAM...
  if (DEBUG > 0)
    printf("%ld\n", input);
  push_num(&STACK, input);
  IPTR++;
} // end ioa_inn

void ioc_file(long noParam) {
  if (DEBUG > 0)
    printf("Stream File: ");
  char mode;
  char path[MEM_SIZE];
  char current;
  int pLen = 0;
  memset(path, 0, sizeof(path));
  // type checking is done in pop_char
  mode = (char) pop_char(&STACK);
  if ((char) pop_char(&STACK) != '{')
    runtimeerror("File path not enclosed in { } brackets");
  while (STACK.stack[STACK.top] != '}') {
    if (pLen >= MEM_SIZE-1)
      runtimeerror("File path is too long. Did you try to do that? R U H4X0R???");
    current = (char) pop_char(&STACK);
    strncat(path, &current, 1);
    pLen++;
  } // end while
  if (DEBUG > 0)
    printf("%s\n", path);
  pop_char(&STACK); // pop '}' char
  IOSTREAM = 'f';
  if (mode == 'r')
    FILESTREAM = fopen(path, "r+");
  else if (mode == 'w')
    FILESTREAM = fopen(path, "w+");
  else if (mode == 'a')
    FILESTREAM = fopen(path, "a+");
  else
    runtimeerror("Invalid file mode on the stack");
  if (!FILESTREAM) {
    char errormsg[21+MEM_SIZE+1] = "Could not open file: ";
    strncat(errormsg, path, MEM_SIZE);
    runtimeerror(errormsg);
  } // end if
  IPTR++;
} // end ioc_file

void ioc_netcon(long parameter) {
  if (DEBUG > 0)
    printf("Stream Network Connection\n");
  IOSTREAM = 'n';
  // TODO : save for later
  IPTR++;
} // end ioc_netcon

void ioc_stdio(long noParam) {
  if (DEBUG > 0)
    printf("Stream Standard I/O\n");
  IOSTREAM = 's';
  IPTR++;
} // end ioc_stdio

//--------------------------//
// --- Parser Functions --- //
//--------------------------//

void jawserror(const char *s) {
  printf("\nWhoopsie daisies! Error while parsing line %d.  Message: %s\n", lineNum, s);
  exit(1); // might as well halt now:
} // end jawserror

void stackerror(const char *s) {
  printf("\nOh dear! Type error on the stack.\nInstruction: %d -> %s\nJaws/Fin line: %d / %d\nMessage: %s\n", IPTR+1, PROGRAM.instructions[IPTR].name, PROGRAM.instructions[IPTR].jawsLine, IPTR+PROGRAM.headFooters+1, s);
  exit(1); // might as well halt now
} // end stackerror

void heaperror(const char *s) {
  printf("\nRats! Type error on the heap.\nInstruction: %d -> %s\nJaws/Fin line: %d / %d\nMessage: %s\n", IPTR+1, PROGRAM.instructions[IPTR].name, PROGRAM.instructions[IPTR].jawsLine, IPTR+PROGRAM.headFooters+1, s);
  exit(1); // might as well halt now
} // end heaperror

void runtimeerror(const char *s) {
  printf("\nFiddlesticks! Invalid data being used for an operation. Instruction: %d -> %s\nJaws/Fin line: %d / %d\nMessage: %s\n", IPTR+1, PROGRAM.instructions[IPTR].name, PROGRAM.instructions[IPTR].jawsLine, IPTR+PROGRAM.headFooters+1, s);
  exit(1); // might as well halt now
} // end runtimeerror 

void accum_add(char bit) {
  if (COUNT == 64) {
    jawserror("More than 32 bits have been read while parsing binary number.");
  } // end if
  BITSTRING[COUNT] = bit;
  COUNT++;
} // end accum_add

long calc_accum() {
  for (int i=0; i<COUNT; i++) {  // reads bitstring left-to-right
    if (BITSTRING[i] == '1') {
      ACCUM += pow( 2, (COUNT-1)-i );  // last bit in string is pow(2,0) 
    } // end if
  } // end for
  return ACCUM;
} // end calc_accum

void reset_accum() {
  memset(BITSTRING, 0, sizeof(BITSTRING));  // reset whole string
  ACCUM = 0x0000000000000000;
  COUNT = 0;
} // end reset_accum
