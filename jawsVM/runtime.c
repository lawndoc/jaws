#include <math.h>
#include "runtime.h"
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

// --- Variable Declarations --- //

// Declare stuff from Flex and Bison
extern int lineNum;

// Declare global variables
char BITSTRING[33];
long ACCUM = 0x00000000;
short COUNT = 0;

// Data structures
typedef struct {
  void (*funcPtr);
} instruction;

typedef struct {
  long stack[4096];
} stack;

// --- Data Structure Functions --- //
instruction* new_instr(char *name) {
  instruction* instr = (instruction *) malloc(sizeof(instruction));
  if (strcmp(name, "stack_push"))
    instr->funcPtr = stack_push;
}

// --- Runtime Functions --- //

// --- Parser Functions --- //

void jawserror(const char *s) {
  printf("Whoopsie daisies! Error while parsing line %d.  Message: %s", lineNum, s);
  // might as well halt now:
  exit(1);
} // end jawserror

void accum_add(char bit) {
  if (COUNT == 32) {
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
  ACCUM = 0x00000000;
  COUNT = 0;
} // end reset_accum
