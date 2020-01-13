# Usage:
# make        # compile all files
# make clean  # remove ALL binaries and objects

# compiler to use
CC = g++

LINKERFLAG = -lfl

EXECUTABLES = bison flex g++
K := $(foreach exec,$(EXECUTABLES),\
	        $(if $(shell which $(exec)),some string,$(error "No $(exec) in PATH")))

all: jaws.tab.c jaws.tab.h lex.yy.c jaws

jaws.tab.c jaws.tab.h: jaws.y
	@echo "Compiling bison file..."
	@bison -d jaws.y

lex.yy.c: jaws.l jaws.tab.h
	@echo "Compiling flex file..."
	@flex jaws.l

jaws: lex.yy.c jaws.tab.c jaws.tab.h
	@echo "Compiling parser..."
	@${CC} jaws.tab.c lex.yy.c ${LINKERFLAG} -o jaws

clean:
	@echo "Cleaning up..."
	@rm jaws.tab.c
	@rm jaws.tab.h
	@rm lex.yy.c
	@rm jaws
	@echo "Done."
