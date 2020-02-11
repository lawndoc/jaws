#define INIT_PRGM_CAP 4096
#define STACK_SIZE 4096

//-------------------------//
// --- Data Structures --- //
//-------------------------//
typedef struct {
  void (*funcPtr)(long);
  long param;
} Instr;
typedef struct {
  Instr *instructions;
  int size;
  int capacity;
} Program;
typedef struct {
  long long *stack;
  char *types;
  int top;
  int capacity;
} Stack;
typedef struct {

} Jumptable;

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
// Jumptable Functions
void jumptable_mark(int index, long label);

//---------------------------------------//
// --- Runtime Function Declarations --- //
//---------------------------------------//
// Instruction Functions
void stack_push(long parameter);
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
void ioc_netcon(long parameter);
void ioc_stdio(long noParam);

//--------------------------------------//
// --- Parser Function Declarations --- //
//--------------------------------------//
void jawserror(const char *s);
void stackerror(const char *s);
void accum_add(char bit);
long calc_accum();
void reset_accum();
