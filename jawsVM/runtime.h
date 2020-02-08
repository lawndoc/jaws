// --- Data Structure Functions --- //

// --- Runtime Function Declarations --- //
void stack_push();
void stack_duplicate();
void stack_swap();
void stack_discard();
void arith_add();
void arith_sub();
void arith_mult();
void arith_div();
void arith_mod();
void heap_store();
void heap_retrieve();
void flow_mark();
void flow_call();
void flow_jumpu();
void flow_jumpz();
void flow_jumpn();
void flow_return();
void ioa_outc();
void ioa_outn();
void ioa_inc();
void ioa_inn();
void ioc_file();
void ioc_netcon();
void ioc_stdio();

// --- Parser Functions --- //
void jawserror(const char *s);
void accum_add(char bit);
long calc_accum();
void reset_accum();
