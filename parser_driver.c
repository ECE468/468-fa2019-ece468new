#include <stdio.h>
#include <stdlib.h>

extern int yylex();
extern FILE * yyin;

/*Doing in C because C++ don't have lots of example with flex/lex, we can also just drop this file and move the logic to the parser.l file*/
int main(int argc, char ** argv)
{
	FILE * input;
	//If supplied with 1 input argument, use it as input file name, otherwise, read from stdin
	if (argc > 1) {
		input = fopen(argv[1], "r");
		if (input == NULL) {
			fprintf(stderr, "Unable to open input file: %s", argv[1]);
			return(EXIT_FAILURE);
		}
	} else {
		input = stdin;
	}
	
	//Read the file workd by word until the file is empty
	yyin = input;
	int count = yylex();
	while (count) {
		count = yylex();
	}
	(void) count; //this is to stop the compiler from complaining count is unused
	
	return (EXIT_SUCCESS);
}
