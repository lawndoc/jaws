# Fin

The Fin programming language is meant to be a tool for developing Jaws programs. Fin is an exact copy of the Jaws grammar with different, visible tokens. If you haven't read the [Jaws language specification](../jawsVM/README.md) yet, you should do that first. The rest of this document will describe the tokens and grammar for Fin.

## Header, Footer, and End-of-Program Tokens

Jaws code will only interpret whitespace tokens in the section of the file between the Jaws Header and Footer. There can be any number of such sections in the same file. This gives the Jaws interpreter the ability to start and stop interpretation any number of times until the End-of-Program statement is reached. The token that makes up the Header, Footer, and End-of-Program statements are as follows:

`header` Header

`footer` Footer

`FIN` End-of-Program

## Instruction Set

Like Jaws, each Fin instruction consists of two parts: The Instruction Modification Parameter (IMP) and the command. The IMP describes what type of operation the command is. The command is interpreted based on which IMP preceeded it, and it is then executed accordingly. The IMPs and their commands are listed below.

## Instruction Modification Parameter (IMP)

The IMP is the first part of a Jaws instruction. The command following it will be interpreted differently depending on which IMP is selected. The chart below illustrates each IMP:

`stack` Stack Manipulation

`arith` Arithmetic

`heap` Heap Access

`flow` Flow Control

`ioa` I/O Action

`ioc` I/O Control

## Commands

The commands for each IMP are organized together. The characters for the command follow directly after the IMP's character(s) with no delimiter. Some commands require a parameter as a part of the instruction. In these cases, the parameter will immediately follow the command. Read about Fin parameters below the commands section.

### Stack Manipulation (IMP: `stack`)

Stack manipulation is the most commonly used instruction type. There are four stack instructions.

`push` (Parameter: Number) Push the number onto the stack

`dup` Duplicate the top item on the stack

`swap` Swap the top two items on the stack

`discard` Discard the top item on the stack

### Arithmetic (IMP: `arith`)

Arithmetic commands operate on the top two items on the stack, and replace them with the result of the operation. The first item to be popped is considered to be to the **left** of the operator.

`add` Addition

`sub` Subtraction

`mult` Multiplication

`div` Integer Division

`mod` Modulo

### Heap Access (IMP: `heap`)

Heap access commands look at the stack to find the address of items to be stored or retrieved. To store an item, push the address then the value and run the store command. To retrieve an item, push the address and run the retrieve command, which will replace the address at the top of the stack.

`store` Store

`retrieve` Retrieve

### Flow Control (IMP: `flow`)

Flow control operations are also very common. Subroutines are marked by labels, as well as the targets of conditional and unconditional jumps, by which loops can be implemented. Programs must be ended with three line feeds so that the interpreter can exit cleanly.

`mark` (Parameter: Label) Mark a location in the program

`call` (Parameter: Label) Call a subroutine

`jumpu` (Parameter: Label) Jump unconditionally to a label

`jumpz` (Parameter: Label) Jump to a label if the top of the stack is zero

`jumpn` (Parameter: Label) Jump to a label if the top of the stack is negative

`return` End a subroutine and jump back to caller

### I/O Action (IMP: `ioa`)

We need to be able to interact with the user and the disk. There are I/O instructions for reading and writing numbers and individual characters. With these, string manipulation routines can be written. NOTE: the *read* instructions gets the heap address in which to store the result from the top of the stack.

`outc` Output the character at the top of the stack

`outn` Output the number at the top of the stack

`inc` Read a character and place it in the location given by the top of the stack

`inn` Read a number and place it in the location given by the top of the stack

### I/O Control (IMP `ioc`)

We need to be able to read and write from the disk. To do that, we will change the I/O stream from standard in/out to a file.

`fileio` Get file path from the stack and change I/O stream to that file

`netcon` (Parameters: IP, Port) Change I/O stream to TCP connection at IP, Port

`stdio` Change I/O to standard in/out

### Command Parameters

While Jaws parameters are strictly represented in binary, parameters for Fin can be represented in the following ways:

##### Number

`100` Decimal representation

`0xdeadbeef` 32-bit Hexadecimal representation

##### Character

`c` Literal representation

`0xf4` 8-bit Hexadecimal representation

##### Label

`abc` 3-character String representation

`0x1337` 16-bit Hexadecimal representation

##### Network Connection

`192.168.1.55:22` Standard 'IP:port' representation