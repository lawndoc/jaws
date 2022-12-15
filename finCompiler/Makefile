# Usage:
# make        # compile all files
# make clean  # remove ALL binaries and objects

# compiler to use
CC = gcc

# check program dependencies
EXECUTABLES = bison flex gcc
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
	@echo "Compiling Fin compiler..."
	@${CC} fin.tab.c lex.fin.c -o finc

windows: fin.tab.c fin.tab.h lex.yy.c
	@echo "Compiling Fin compiler for Windows..."
	@x86_64-w64-mingw32-g++ fin.tab.c lex.fin.c -o finc.exe --static

clean:
	@echo "Cleaning up Fin..."
	@-rm -f fin.tab.c
	@-rm -f fin.tab.h
	@-rm -f lex.fin.c
	@-rm -f finc
	@-rm -f finc.exe
