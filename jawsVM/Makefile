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
all: jaws.tab.c jaws.tab.h lex.yy.c jaws

jaws.tab.c jaws.tab.h: jaws.y
	@echo "Compiling Jaws bison file..."
	@bison -d jaws.y

lex.yy.c: jaws.l jaws.tab.h
	@echo "Compiling Jaws flex file..."
	@flex jaws.l

jaws: lex.yy.c jaws.tab.c jaws.tab.h
	@echo "Compiling Jaws virtual machine..."
	@${CC} jaws.tab.c lex.jaws.c runtime.c -o jaws

windows: jaws.tab.c jaws.tab.h lex.yy.c
	@echo "Compiling Jaws virtual machine for Windows..."
	@x86_64-w64-mingw32-g++ jaws.tab.c lex.jaws.c runtime.c -o jaws.exe --static -lws2_32

clean:
	@echo "Cleaning up Jaws..."
	@-rm -f jaws.tab.c
	@-rm -f jaws.tab.h
	@-rm -f lex.jaws.c
	@-rm -f jaws
	@-rm -f jaws.exe
