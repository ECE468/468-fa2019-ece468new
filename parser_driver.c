#include <stdio.h>
#include <stdlib.h>

extern int yylex();
extern FILE * yyin;
int main(int argc, char ** argv)
{
	FILE * input;
	if (argc > 1) {
		input = fopen(argv[1], "r");
		if (input == NULL) {
			fprintf(stderr, "Unable to open input file: %s", argv[1]);
			return(EXIT_FAILURE);
		}
	} else {
		input = stdin;
	}
	yyin = input;
	int count = yylex();
	while (count) {
		count = yylex();
	}
	(void) count;
	return (EXIT_SUCCESS);
}
