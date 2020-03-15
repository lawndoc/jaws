# Usage:
# make        # compile all files
# make clean  # remove ALL binaries and objects

# compiler to use
CC = g++

# check program dependencies
EXECUTABLES = bison flex g++
K := $(foreach exec,$(EXECUTABLES),\
	        $(if $(shell which $(exec)),some string,$(error "No $(exec) in PATH")))

# begin Makefile
all: fin.tab.c fin.tab.h lex.yy.c finc

fin.tab.c fin.tab.h: fin.y
	@echo "Compiling Fin bison file..."
	@bison -d fin.y

lex.yy.c: fin.l fin.tab.h
	@echo "Compiling Fin flex file..."
	@flex fin.l

finc: lex.yy.c fin.tab.c fin.tab.h
	@echo "Compiling Fin parser..."
	@${CC} fin.tab.c lex.fin.c -o finc

clean:
	@echo "Cleaning up Fin..."
	@rm fin.tab.c
	@rm fin.tab.h
	@rm lex.fin.c
	@rm finc
