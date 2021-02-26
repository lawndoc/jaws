![Jaws Logo](resources/jawsLogo.png)

Jaws is an esoteric programming language that was created for research purposes. Tools for developing Jaws programs can be found in the various directories of this repository.

To read more about Jaws and why it was created, please refer to my blog post or my undergrad honor's thesis.

## Install

You can install all the programs by running the following command in the top level directory:

`$ make && make install`		<-- (you will be prompted for your sudo password)

## Tools

### jaws

***Jaws virtual machine***

Jaws is an interpreted language, so a virtual machine has been created to run Jaws programs. The virtual machine source code and language specification for Jaws can be found in the [jawsVM](jawsVM/) directory.

### finc 

***Fin-to-Jaws compiler***

Because Jaws instructions are entirely composed of invisible characters, a visible version of Jaws, called Fin, has been created. Fin allows you to write Jaws programs in a visible, human-debuggable fashion. Once you have written a Fin program, you can compile it to Jaws using the 'finc' compiler. The compiler source code and language specification for Fin can be found in the [finCompiler](finCompiler/) directory.
