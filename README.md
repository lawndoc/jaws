# Jaws Programming Language

![Jaws Logo](resources/jawsLogo.png)

Jaws is an esoteric programming language that was created for research purposes. Tools for developing Jaws programs can be found in the various directories of this repository. The tools in this repo include:

## Jaws virtual machine

Jaws is an interpreted language, so a virtual machine has been created to run Jaws programs. The virtual machine source code as well as the language specification for Jaws can be found in the ![jawsVM](jawsVM/) directory.

## Fin-to-Jaws compiler

Because Jaws instructions are entirely composed of invisible characters, a visible version of Jaws, called Fin, has been created. Fin allows you to write Jaws programs in a visible, human-debuggable fashion. Once you have written a Fin program, you can compile it to Jaws using the 'finc' compiler. The source code for the Fin compiler can be found in the ![finCompiler](finCompiler/) directory.
