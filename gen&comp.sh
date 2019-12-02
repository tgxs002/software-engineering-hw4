#!/bin/bash
bison -d hw4.y
flex hw4.l
mv lex.yy.c maxTweeter.c
echo 'c file generated.'
make
echo 'compiled. output: maxTweeter'
rm -f hw4.tab.o maxTweeter.o