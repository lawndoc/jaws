#include "uthash.h"
#define INIT_PRGM_CAP 4096
#define MEM_SIZE 4096

//-------------------------//
// --- Data Structures --- //
//-------------------------//
typedef struct {
  void (*funcPtr)(long);
  long param;
  char *name;
  int jawsLine;
} Instr;
typedef struct {
  Instr *instructions;
  int size;
  int capacity;
  int headFooters;
} Program;
typedef struct {
  long long *stack;
  char *types;
  int top;
  int capacity;
} Stack;
typedef struct {
  long *heap;
  char *types;
  int capacity;
} Heap;
typedef struct {
  int label;		// key
  int index;		// location in Program
  UT_hash_handle hh;	// makes structure hashable
} Label;
typedef struct {
  Label *jumptable;
  Stack callStack;
} Jumptable;
typedef struct {
  int socket;
} NetCon;

//----------------------------------------------//
// --- Data Structure Function Declarations --- //
//----------------------------------------------//
// Instr Functions
void init_Instr(Instr *instruction, char *name, long parameter);
// Program Functions
void init_Program(Program *program, int capacity);
void add_instruction(Program *program, char *name, long parameter);
// Stack Functions
void init_Stack(Stack *stack, int capacity);
void push_num(Stack *stack, long data);
void push_char(Stack *stack, long data);
void push_address(Stack *stack, long *address);
long pop_num(Stack *stack);
long pop_char(Stack *stack);
long *pop_address(Stack *stack);
// Heap Functions
void init_Heap(Heap *heap, int capacity);
  // retrieve (implemented in runtime function for type persistence)
void store_num(Heap *heap, long value, long address);
void store_char(Heap *heap, long value, long address);
// Jump Table Functions
void init_Label(Label *record, int label, int index);
void init_Jumptable(Jumptable *jumptable, int capacity);
void jumptable_mark(Jumptable *jumptable, int index, long identifier);
int jumptable_find(Jumptable *jumptable, long identifier);
void jumptable_call(Jumptable *jumptable, int index);
int jumptable_return(Jumptable *jumptable);
// Network Connection Functions
void init_NetCon(NetCon *netCon, long ip, long port, long ops);

//---------------------------------------//
// --- Runtime Function Declarations --- //
//---------------------------------------//
// Instruction Functions
void stack_push(long parameter);
void stack_pushc(long parameter);
void stack_duplicate(long noParam);
void stack_swap(long noParam);
void stack_discard(long noParam);
void arith_add(long noParam);
void arith_sub(long noParam);
void arith_mult(long noParam);
void arith_div(long noParam);
void arith_mod(long noParam);
void heap_store(long noParam);
void heap_retrieve(long noParam);
void flow_mark(long parameter);
void flow_call(long parameter);
void flow_jumpu(long parameter);
void flow_jumpz(long parameter);
void flow_jumpn(long parameter);
void flow_return(long noParam);
void ioa_outc(long noParam);
void ioa_outn(long noParam);
void ioa_inc(long noParam);
void ioa_inn(long noParam);
void ioc_file(long noParam);
void ioc_stdio(long noParam);
void netcon_connect(long parameter);
void netcon_close(long noParam);
void netcon_send(long noParam); // TODO: build
void netcon_recv(long noParam); // TODO: build

//-------------------------------------//
// --- Error Function Declarations --- //
//-------------------------------------//
void jawserror(const char *s);
void stackerror(const char *s);
void heaperror(const char *s);
void runtimeerror(const char *s);

//--------------------------------------//
// --- Parser Function Declarations --- //
//--------------------------------------//
void accum_add(char bit);
long calc_accum();
void reset_accum();
