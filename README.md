# CSV parser & twitter analyzer

> ## This repository is for homework submission, not for general use. I will not be maintained, will be closed ASAP.

## Team Members
- Xiaoshi Wu
- Tessa Van Dijk Carnicero

## Parsing

Lexical & Syntax rules are defined in hw4.l(lexical analyzer) and hw4.y(syntax analyzer). Source code is generated by flex&bison.

## Twitter analyzing

hw4.y contains the handmade c code essential for twitter analyzing.

## Generate c code (optional)

Assume that you are running on ubuntu. If you do not want to modify the program, this is not necessary, since source code and makefile has already been generated. The following rules are only necessay if you want to modify the rules and renew the c source code:

1. install flex.

>sudo apt-get install flex

2. install bison.

>sudo apt-get install bison

3. generate c files and compile them.

>./gen&compile.sh

## How to run

4. if you would like to use afl for test, you should modify the Makefile by:

- change CC to your afl-clang compiler's path
- add -g to CCFLAGS