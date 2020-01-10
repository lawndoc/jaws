# Usage:
# make        # compile all files
# make clean  # remove ALL binaries and objects

.PHONY = all flexBison clean

# compiler to use
CC = g++

LINKERFLAG = -lfl

all: flexBison

flexBison:
	@echo "Compiling flex and bison files..."
	bison -d jaws.y
	flex jaws.l
	${CC} jaws.tab.c lex.yy.c ${LINKERFLAG} -o jaws

clean:
	@echo "Cleaning up..."
	rm jaws.tab.?
	rm lex.yy.c
	rm jaws
	@echo "Done."
