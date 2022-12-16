# Usage:
# make        # compile jaws elf executable
# make ape    # compile jaws αcτµαlly pδrταblε εxεcµταblε
# make clean  # remove ALL binaries and objects

# compiler to use
CC = gcc

# check program dependencies
EXECUTABLES = bison flex gcc wget unzip
K := $(foreach exec,$(EXECUTABLES),\
	        $(if $(shell which $(exec)),some string,$(error "No $(exec) in PATH")))

# begin Makefile
all: jaws

ape: jaws.com cosmoclean

jaws.tab.c jaws.tab.h: jaws.y
	@echo "Compiling Jaws bison file..."
	@bison -d jaws.y

lex.yy.c: jaws.l jaws.tab.h
	@echo "Compiling Jaws flex file..."
	@flex jaws.l

jaws: lex.yy.c jaws.tab.c jaws.tab.h
	@echo "Compiling Jaws virtual machine..."
	@${CC} jaws.tab.c lex.jaws.c runtime.c -o jaws -lm

jaws.com: cosmopolitan.h lex.yy.c jaws.tab.c jaws.tab.h cosmopatch
	@echo "Compiling Jaws virtual machine as an αcτµαlly pδrταblε εxεcµταblε..."
	@${CC} -g -Os -static -nostdlib -nostdinc -fno-pie -no-pie -mno-red-zone \
  	-fno-omit-frame-pointer -pg -mnop-mcount -mno-tls-direct-seg-refs -gdwarf-4 \
  	-o jaws.com.dbg jaws.tab.c lex.jaws.c runtime.c -fuse-ld=bfd -Wl,-T,ape.lds \
	-Wl,--gc-sections -include cosmopolitan.h crt.o ape-no-modify-self.o \
	cosmopolitan.a
	@objcopy -S -O binary jaws.com.dbg jaws.com

cosmopolitan.h:
	@echo "Downloading Cosmopolitan LibC..."
	@wget https://justine.lol/cosmopolitan/cosmopolitan-amalgamation-2.2.zip
	@unzip cosmopolitan-amalgamation-2.2.zip

cosmopatch:
	@echo "Patching source for Cosmopolitan LibC..."
	@sed -i 's/#include </\/\/#include </g' jaws.y
	@sed -i 's/#include </\/\/#include </g' runtime.c
	@sed -i 's/#include </\/\/#include </g' uthash.h
	@sed -i 's/#include </\/\/#include </g' jaws.tab.c
	@sed -i 's/#include </\/\/#include </g' lex.jaws.c

cosmoclean:
	@echo "Cleaning Cosmopolitan LibC patch..."
	@sed -i 's/\/\/#include </#include </g' jaws.y
	@sed -i 's/\/\/#include </#include </g' runtime.c
	@sed -i 's/\/\/#include </#include </g' uthash.h
	@sed -i 's/\/\/#include </#include </g' jaws.tab.c
	@sed -i 's/\/\/#include </#include </g' lex.jaws.c

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
	@-rm -f jaws.com*
	@-rm -f cosmopolitan*
	@-rm -f ape*
	@-rm -f crt.o
