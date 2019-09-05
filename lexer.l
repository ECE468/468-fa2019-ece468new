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
WHITESPACE [ \n\t\r\f]


%%

	/*ignore whitespace*/
{WHITESPACE}+ {
}

for|in|range|end|for|continue|break|prog|begin|end|func|read|write|if|else|endif|while|endwhile|return|int|void|str|float|true|false {
	printf("Token Type: KEYWORD\n");
	printf("Value: %s\n", yytext);
}

"="|"+"|"-"|"*"|"/"|"=="|"!="|"<"|">"|"("|")"|";"|","|"<="|">=" {
	printf("Token Type: OPERATOR\n");
	printf("Value: %s\n", yytext);
}


{DIGIT}+ {
	printf("Token Type: INTLITERAL\n");
	printf("Value: %s\n", yytext);
}

{DIGIT}*"."{DIGIT}+ {
	printf("Token Type: FLOATLITERAL\n");
	printf("Value: %s\n", yytext);
}

	/*Comments are anything started with " follow by any character but a " repeated none or any number of time and end with a "*/
\"([^\"])*\" {
	printf("Token Type: STRINGLITERAL\n");
	printf("Value: %s\n", yytext);
}

	/*Ignore comments, comments are anything started with # follow by any character but a new line repeated none or any number of time and end with a new line*/
#([^\n])*\n {
}

{LETTER}({DIGIT}|{LETTER})* {
	printf("Token Type: IDENTIFIER\n");
	printf("Value: %s\n", yytext);
}
%%
