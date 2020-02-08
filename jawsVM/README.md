# Jaws

![Jaws Logo](../resources/jawsLogo.png)

Jaws (Just Another WhiteSpace) is an esoteric interpreted programming language strongly based on another, called [whitespace][1], with added functionality. Jaws is an imperative, stack based language. The name Jaws is an acronym, but the word itself was also intended to hold meaning because the code, being invisible to the human eye, is like a threat hidden beneath the surface.

[1]: https://en.wikipedia.org/wiki/Whitespace_(programming_language) "wikipedia"

## Lexical Tokens

Like whitespace, the only lexical tokens in Jaws are *Space* (ASCII 32), *Tab*, (ASCII 9), and *Line Feed* (ASCII 10). The original choice to use line feed only and not carraige return was to avoid DOS/Unix conversion problems.

## Starting/Stopping Interpretation

Jaws code will only interpret whitespace tokens in the section of the file between the Jaws Header and Footer. There can be any number of such sections in the same file. This gives the Jaws interpreter the ability to start and stop interpretation any number of times until the End-of-Program statement is reached. The tokens that make up the Header and the Footer are identical:

`[LF][Tab][Space]` Header/Footer

`[LF][LF][LF]` End-of-Program

## Instruction Set

Each instruction consists of two parts: The Instruction Modification Parameter (IMP) and the command. The IMP describes what type of operation the command is. The command is interpreted based on which IMP preceeded it, and it is then executed accordingly. The IMPs and their commands are listed below.

## Instruction Modification Parameter (IMP)

The IMP is the first part of a Jaws instruction. The command following it will be interpreted differently depending on which IMP is selected. The chart below illustrates each IMP:

`[Space][Space]` Stack Manipulation

`[Space][Tab]` Arithmetic

`[Tab][Tab]` Heap Access

`[LF][Space]` Flow Control

`[Tab][LF]` I/O Action

`[Tab][Space]` I/O Control

## Commands

The commands for each IMP are organized together. The characters for the command follow directly after the IMP's character(s) with no delimiter. Some commands require a parameter as a part of the instruction. In these cases, the parameter will immediately follow the command in the form of a binary number. `[Space]` represents 0, `[Tab]` represents 1, and a `[LF]` signals the end of the parameter. Read more on parameters below the commands.

### Stack Manipulation (IMP: `[Space][Space]`)

Stack manipulation is the most commonly used instruction type. There are four stack instructions.

`[Space]` (Parameter: Number) Push the number onto the stack

`[LF][Space]` Duplicate the top item on the stack

`[LF][Tab]` Swap the top two items on the stack

`[LF][LF]` Discard the top item on the stack

### Arithmetic (IMP: `[Space][Tab]`)

Arithmetic commands operate on the top two items on the stack, and replace them with the result of the operation. The first item to be popped is considered to be to the **left** of the operator.

`[Space][Space]` Addition

`[Space][Tab]` Subtraction

`[Space][LF]` Multiplication

`[Tab][Space]` Integer Division

`[Tab][Tab]` Modulo

### Heap Access (IMP: `[Tab][Tab]`)

Heap access commands look at the stack to find the address of items to be stored or retrieved. To store an item, push the address then the value and run the store command. To retrieve an item, push the address and run the retrieve command, which will replace the address at the top of the stack.

`[Space]` Store

`[Tab]` Retrieve

### Flow Control (IMP: `[LF][Space]`)

Flow control operations are also very common. Subroutines are marked by labels, as well as the targets of conditional and unconditional jumps, by which loops can be implemented. Programs must be ended with three line feeds so that the interpreter can exit cleanly.

`[Space][Space]` (Parameter: Label) Mark a location in the program

`[Space][Tab]` (Parameter: Label) Call a subroutine

`[Space][LF]` (Parameter: Label) Jump unconditionally to a label

`[Tab][Space]` (Parameter: Label) Jump to a label if the top of the stack is zero

`[Tab][Tab]` (Parameter: Label) Jump to a label if the top of the stack is negative

`[Tab][LF]` End a subroutine and jump back to caller

### I/O Action (IMP: `[Tab][LF]`)

We need to be able to interact with the user and the disk. There are I/O instructions for reading and writing numbers and individual characters. With these, string manipulation routines can be written. NOTE: the *read* instructions gets the heap address in which to store the result from the top of the stack.

`[Space][Space]` Output the character at the top of the stack

`[Space][Tab]` Output the number at the top of the stack

`[Tab][Space]` Read a character and place it in the location given by the top of the stack

`[Tab][Tab]` Read a number and place it in the location given by the top of the stack

### I/O Control (IMP `[Tab][Space]`)

We need to be able to read and write from the disk. To do that, we will change the I/O stream from standard in/out to a file.

`[Space][Space]` Get file path from the stack and change I/O stream to that file

`[Space][Tab]` (Parameters: IP, Port) Change I/O stream to TCP connection at IP, Port

`[Tab][Space]` Change I/O to standard in/out

### Command Parameters

Each parameter type is fixed-length. A binary number pushed onto the stack is either 32 bits (int) or 8 bits (char). At runtime, the type of data pushed onto the stack depends on the size of the parameter. Type checking is done at upon I/O Action, where the data involved is explicitly declared by the language. Label parameters are 16 bits long, leaving room for 65,536 different labels. Network connection parameters are 48 bits long -- 32 bits to specify the IP address, followed by 16 bits to specify the port number.
