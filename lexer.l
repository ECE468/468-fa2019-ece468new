%option nounput
%option noinput
%option noyywrap
%{
#include<stdlib.h>
#include<stdio.h>
#include<snazzle.tab.h>
%}
	/* Regex doc http://dinosaur.compilertools.net/flex/flex_7.html */

DIGIT [0-9]
LETTER [A-Za-z]
WHITESPACE [ \n\t\r\f]


%%

	/*ignore whitespace*/
{WHITESPACE}+ {
}

for {
	return (_FOR);
}
in {
	return (_IN);
}
range {
	return (_RANGE);
}
end {
	return (_END);
}
continue {
	return (_CONTINUE);
}

break {
	return (_BREAK);
}

prog {
	return (_PROG);
}
begin {
	return (_BEGIN);
}




func {
	return (_FUNC);
}
read {
	return (_READ);
}
write {
	return (_WRITE);
}
if {
	return (_IF);
}
else {
	return (_ELSE);
}
endif {
	return (_ENDIF);
}
while {
	return (KEYWORD);
}
endwhile {
	return (KEYWORD);
}
return {
	return (KEYWORD);
}
int {
	return (KEYWORD);
}
float {
	return (KEYWORD);
}
true {
	return (KEYWORD);
}
false {
	return (KEYWORD);
}
void {
	return (KEYWORD);
}
for|in|range|end|for|continue|break|prog|begin|end|func|read|write|if|else|endif|while|endwhile|return|int|void|str|float|true|false {
	return (KEYWORD);
}
"="|"+"|"-"|"*"|"/"|"=="|"!="|"<"|">"|"("|")"|";"|","|"<="|">=" {
	printf("Token Type: OPERATOR\n");
	return (KEYWORD);
}


{DIGIT}+ {
	return (INTLITERAL);
}

{DIGIT}*"."{DIGIT}+ {
	return (FLOATLITERAL);
}

	/*Comments are anything started with " follow by any character but a " repeated none or any number of time and end with a "*/
\"([^\"])*\" {
	return (STRINGLITERAL);
}

	/*Ignore comments, comments are anything started with # follow by any character but a new line repeated none or any number of time and end with a new line*/
#([^\n])*\n {
}

{LETTER}({DIGIT}|{LETTER})* {
	return (IDENTIFIER);
}
%%
