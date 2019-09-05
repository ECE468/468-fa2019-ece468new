%{
	#include <cstdio>
	#include <iostream>

	void yyerror(const char *s)
%}

%union {
	char *strv;
}

%token <strv> _PROG
%token <strv> _BEGIN
%token <strv> _END
%token <strv> _STR
%token <strv> _FLOAT
%token <strv> _INT
%token <strv> _VOID
%token <strv> _FUNC
%token <strv> _READ
%token <strv> _WRITE
%token <strv> _RETURN
%token <strv> _IF
%token <strv> _ELSE
%token <strv> _TRUE
%token <strv> _FALSE
%token <strv> _WHILE
%token <strv> _ENDWHILE
%token <strv> _CONTINUE
%token <strv> _BREAK
%token <strv> _FOR
%token <strv> _IN
%token <strv> _RANGE
%token <strv> _ENDFOR
program: _PROG id _BEGIN pgm_body _END {
		printf("Valid program");
	}
id : IDENTIFIER {
	
}
pgm_body: decl func_declarations {

}
	| BEGIN {
		;
	}
	| END {
		;
	}
	| STR {
		;
	}
	| FLOAT {
		;
	}
	| INT {
		;
	}
	| VOID {
		;
	}
	| FUNC {
		;
	}
	| READ {
		;
	|

void yyerror(const char *s) {
	cout << "Error" << s << endl;
	exit(-1);
}
