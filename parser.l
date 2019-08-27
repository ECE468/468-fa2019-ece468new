%option nounput
%option noinput
%option noyywrap
%{
#include<stdlib.h>
#include<stdio.h>
%}
	/* Regex doc http://dinosaur.compilertools.net/flex/flex_7.html */

DIGIT [0-9]
LETTER [A-Za-z]

ID [a-z][a-z0-9]*

%%

if|then|begin|end|procedure|function {
	printf("A keyword: %s\n", yytext);
}

{DIGIT}+ {
	printf("An integer: %s (%d)\n", yytext, atoi(yytext));
}

{DIGIT}*"."{DIGIT}+ {
	printf("A float: %s (%g)\n", yytext, atof(yytext));
}


{ID} {
	printf("An identifier: %s\n", yytext);
}
%%

