#include <math.h>
#include "runtime.h"
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

//-------------------------------//
// --- Variable Declarations --- //
//-------------------------------//

// Declare stuff from Flex and Bison
extern int lineNum;		// for jawserror function

// Declare global variables
Program PROGRAM;		// for runtime system
int IPTR;			// for runtime system
Stack STACK;			// for runtime system
Label *JUMPTABLE = NULL;	// for runtime system
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
} // end new_instruction


//--- Program Functions---//
void init_Program(Program *program, int capacity) {
  program->instructions = (Instr *) malloc(capacity * sizeof(Instr));
  program->size = 0;
  program->capacity = capacity;
} // end init_Program

void add_instruction(Program *program, char *name, long parameter) {
  Instr instruction;
  if (program->size >= program->capacity) {
    program->capacity *= 2;
    program->instructions = (Instr *) realloc(program->instructions, program->capacity * sizeof(Instr));
  } // end if
  init_Instr(&instruction, name, parameter);
  if (instruction.funcPtr == &flow_mark) {
    jumptable_mark(program->size, instruction.param);
  } // end if
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


//--- Jump Table Functions ---//
void init_Label(Label *record, int label, int index) {
  record->label = label;
  record->index = index;
} // end init_Label

void jumptable_mark(int index, long identifier) {
  Label record;
  init_Label(&record, (int) identifier, index);
  HASH_ADD_INT(JUMPTABLE, label, &record);
} // end jumptable_mark

int jumptable_find(long identifier) {
  Label *record;
  HASH_FIND_INT(JUMPTABLE, &identifier, record);
  return record->index;
} // end jumptable_get


//---------------------------//
// --- Runtime Functions --- //
//---------------------------//

// Instruction Functions
void stack_push(long parameter) {
  printf("Stack Push\n"); IPTR++;
  push_num(&STACK, parameter);
} // end stack_pushn
void stack_pushc(long parameter) {
  printf("Stack Push\n"); IPTR++;
  push_char(&STACK, parameter);
} // end stack_pushc

void stack_duplicate(long noParam) {
  printf("Stack Duplicate\n"); IPTR++;
  long topVal = STACK.stack[STACK.top];
  char topType = STACK.types[STACK.top];
  if (topType == 'n')
    push_num(&STACK, topVal);
  else if (topType == 'c')
    push_char(&STACK, topVal);
  else
    push_address(&STACK, (long *) topVal);
} // end stack_duplicate

void stack_swap(long noParam) {
  printf("Stack Swap\n"); IPTR++;
  long firstVal;
  long secondVal;
  char firstType = STACK.types[STACK.top];
  char secondType = STACK.types[STACK.top-1];
  // pop top element
  if (firstType == 'n')
    firstVal = pop_num(&STACK);
  else if (firstType == 'c')
    firstVal = pop_char(&STACK);
  else
    firstVal = (long) pop_address(&STACK);
  // pop second element
  if (secondType == 'n')
    secondVal = pop_num(&STACK);
  else if (secondType == 'c')
    secondVal = pop_char(&STACK);
  else
    secondVal = (long) pop_address(&STACK);
  // push top element first
  if (firstType == 'n')
    push_num(&STACK, firstVal);
  else if (firstType == 'c')
    push_char(&STACK, firstVal);
  else
    push_address(&STACK, (long *) firstVal);
  // push second element on top
  if (secondType == 'n')
    push_num(&STACK, secondVal);
  else if (secondType == 'c')
    push_char(&STACK, secondVal);
  else
    push_address(&STACK, (long *) secondVal);

} // end stack_swap

void stack_discard(long noParam) {
  printf("Stack Discard\n"); IPTR++;
  char topType = STACK.types[STACK.top];
  if (topType == 'n')
    pop_num(&STACK);
  else if (topType == 'c')
    pop_char(&STACK);
  else if (topType == 'a')
    pop_address(&STACK);
  else if (topType == 'x')
    stackerror("Stack is empty -- cannot discard top item");
  else
    stackerror("Reached unexpected type on the stack... How did this happen?");
} // end stack_discard

void arith_add(long noParam) {
  printf("Add\n"); IPTR++;
  long left = pop_num(&STACK);
  long right = pop_num(&STACK);
  push_num(&STACK, (left+right));
} // end arith_add

void arith_sub(long noParam) {
  printf("Subtract\n"); IPTR++;
  long left = pop_num(&STACK);
  long right = pop_num(&STACK);
  push_num(&STACK, (left-right));
} // end arith_sub

void arith_mult(long noParam) {
  printf("Multiply\n"); IPTR++;
  long left = pop_num(&STACK);
  long right = pop_num(&STACK);
  push_num(&STACK, (left*right));
} // end arith_mult

void arith_div(long noParam) {
  printf("Divide\n"); IPTR++;
  long left = pop_num(&STACK);
  long right = pop_num(&STACK);
  push_num(&STACK, (left/right));
} // end arith_div

void arith_mod(long noParam) {
  printf("Modulo\n"); IPTR++;
  long left = pop_num(&STACK);
  long right = pop_num(&STACK);
  push_num(&STACK, (left%right));
} // end arith_mod

void heap_store(long noParam) {
  printf("Heap Store\n"); IPTR++;
} // end heap_store

void heap_retrieve(long noParam) {
  printf("Heap Retrieve\n"); IPTR++;
} // end heap_retrieve

void flow_mark(long parameter) {
  printf("New Label\n"); IPTR++;
} // end flow_mark

void flow_call(long parameter) {
  printf("Call Subroutine\n"); IPTR++;
} // end flow_call

void flow_jumpu(long parameter) {
  printf("Unconditional Jump\n"); IPTR++;
} // end flow_jumpu

void flow_jumpz(long parameter) {
  printf("Jump if Zero\n"); IPTR++;
} // end flow_jumpz

void flow_jumpn(long parameter) {
  printf("Jump if Negative\n"); IPTR++;
} // end flow_jumpn

void flow_return(long noParam) {
  printf("Return from Subroutine\n"); IPTR++;
} // end flow_return

void ioa_outc(long noParam) {
  printf("Output Character\n"); IPTR++;
} // end ioa_outc

void ioa_outn(long noParam) {
  printf("Output Number\n"); IPTR++;
} // end ioa_outn

void ioa_inc(long noParam) {
  printf("Input Character\n"); IPTR++;
} // end ioa_inc

void ioa_inn(long noParam) {
  printf("Input Number\n"); IPTR++;
} // end ioa_inn

void ioc_file(long noParam) {
  printf("Stream File\n"); IPTR++;
} // end ioc_file

void ioc_netcon(long parameter) {
  printf("Stream Network Connection\n"); IPTR++;
} // end ioc_netcon

void ioc_stdio(long noParam) {
  printf("Stream Standard I/O\n"); IPTR++;
} // end ioc_stdio

//--------------------------//
// --- Parser Functions --- //
//--------------------------//

void jawserror(const char *s) {
  printf("Whoopsie daisies! Error while parsing line %d.  Message: %s\n", lineNum, s);
  exit(1); // might as well halt now:
} // end jawserror

void stackerror(const char *s) {
  printf("Oh dear! Type error on the stack for instruction %d. Message: %s\n", IPTR, s);
  exit(1); // might as well halt now
} // end stackerror

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
