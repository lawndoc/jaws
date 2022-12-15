# Usage:
# make		# compile all files
# make install	# install compiled binaries
# make clean	# remove ALL binaries and objects

# check program dependencies
EXECUTABLES = bison flex gcc
K := $(foreach exec,$(EXECUTABLES),\
	        $(if $(shell which $(exec)),some string,$(error "No $(exec) in PATH")))

# begin Makefile
all: jaws fin
	@echo "Done."

windows: jaws_w fin_w
	@echo "Done."

jaws:
	@cd jawsVM && make

fin:
	@cd finCompiler && make

jaws_w:
	@cd jawsVM && make windows

fin_w:
	@cd finCompiler && make windows

install:
	@sudo true
	@echo "Installing jaws..."
	@sudo cp jawsVM/jaws /usr/local/bin
	@sudo chown root:root /usr/local/bin/jaws
	@sudo chmod 755 /usr/local/bin/jaws
	@echo "Installing finc..."
	@sudo cp finCompiler/finc /usr/local/bin
	@sudo chown root:root /usr/local/bin/finc
	@sudo chmod 755 /usr/local/bin/finc
	@echo "Installing man pages..."
	@sudo mkdir -p /usr/local/share/man/man1/
	@sudo cp man/jaws.1 /usr/local/share/man/man1/
	@sudo cp man/finc.1 /usr/local/share/man/man1/
	@echo "Done."

clean:
	@cd jawsVM && make clean
	@cd finCompiler && make clean
	@echo "Done."
