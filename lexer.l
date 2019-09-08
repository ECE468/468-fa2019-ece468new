%option nounput
%option noinput
%option noyywrap
%{
#include<stdlib.h>
#include<stdio.h>
#include"microparser.tab.h"
%}
	/* Regex doc http://dinosaur.compilertools.net/flex/flex_7.html */

DIGIT [0-9]
LETTER [A-Za-z]
WHITESPACE [ \t\r\f\n]

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
endif {
	return (_ENDIF);
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
	return (_WHILE);
}
endwhile {
	return (_ENDWHILE);
}
return {
	return (_RETURN);
}
int {
	return (_INT);
}
float {
	return(_FLOAT);
}
str {
	return(_STR);
}
true {
	return (_TRUE);
}
false {
	return (_FALSE);
}
void {
	return (_VOID);
}

"=" {
	return (EQUAL);
}

"+" {
	return (PLUS);
}
"-" {
	return (MINUS);
}
"*" {
	return (MULTIPLY);
}
"/" {
	return (DIVIDE);
}
"==" {
	return (EQUAL);
}
"!=" {
	return (NOT_EQUAL);
}
"<" {
	return (LESS_THAN);
}
">" {
	return (GREATER_THAN);
}
"(" {
	return (OPEN_BRACKET);
}
")" {
	return (CLOSED_BRACKET);
}
";" {
	return (SEMICOLON);
}
"," {
	return (COLON);
}
"<=" {
	return (LESS_THAN_EQUAL);
}
">=" {
	return (GREATER_THAN_EQUAL);
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
