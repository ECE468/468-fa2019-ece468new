%{
	#include <stdio.h>
	#include <stdlib.h>

	int yyerror(const char *s);
	extern int yylex();
%}

%union {
	char *strv;
}
%token <strv> INTLITERAL
%token <strv> FLOATLITERAL
%token <strv> STRINGLITERAL
%token <strv> IDENTIFIER
%token <strv> _PROG
%token <strv> _BEGIN
%token <strv> _END
%token <strv> _ENDIF
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
%token <strv> EQUAL
%token <strv> SEMICOLON
%token <strv> COLON
%token <strv> OPEN_BRACKET
%token <strv> CLOSED_BRACKET
%token <strv> PLUS
%token <strv> MINUS
%token <strv> MULTIPLY
%token <strv> DIVIDE
%token <strv> LESS_THAN
%token <strv> GREATER_THAN
%token <strv> NOT_EQUAL
%token <strv> LESS_THAN_EQUAL
%token <strv> GREATER_THAN_EQUAL

%%

program: _PROG id _BEGIN pgm_body _END {
		printf("Accepted");
	};
id : IDENTIFIER; 
pgm_body: decl func_declarations;
decl: string_decl decl | var_decl decl | ;

string_decl: _STR id EQUAL str_literal SEMICOLON;
str_literal: STRINGLITERAL;

var_decl: var_type id_list SEMICOLON;
var_type: _FLOAT | _INT;
any_type: var_type | _VOID;
id_list: id id_tail;
id_tail: COLON id id_tail | ;

param_decl_list: param_decl param_decl_tail | ;
param_decl: var_type id;
param_decl_tail: COLON param_decl param_decl_tail | ;

func_declarations: func_decl func_declarations | ;
func_decl: _FUNC any_type id OPEN_BRACKET param_decl_list CLOSED_BRACKET _BEGIN func_body _END;
func_body: decl stmt_list;

stmt_list: stmt stmt_list | ;
stmt: base_stmt | if_stmt | loop_stmt;
base_stmt: assign_stmt | read_stmt | write_stmt | control_stmt;

assign_stmt: assign_expr SEMICOLON;
assign_expr: id EQUAL expr;
read_stmt: _READ OPEN_BRACKET id_list CLOSED_BRACKET SEMICOLON;
write_stmt: _WRITE OPEN_BRACKET id_list CLOSED_BRACKET SEMICOLON;
return_stmt: _RETURN expr SEMICOLON;

expr: expr_prefix factor;
expr_prefix: expr_prefix factor addop | ;
factor: factor_prefix postfix_expr;
factor_prefix: factor_prefix postfix_expr mulop | ;
postfix_expr: primary | call_expr;
call_expr: id OPEN_BRACKET expr_list CLOSED_BRACKET;
expr_list: expr expr_list_tail | ;
expr_list_tail: COLON expr expr_list_tail | ;
primary: OPEN_BRACKET expr CLOSED_BRACKET | id | INTLITERAL | FLOATLITERAL;
addop: PLUS | MINUS;
mulop: MULTIPLY | DIVIDE;

if_stmt: _IF OPEN_BRACKET cond CLOSED_BRACKET decl stmt_list else_part _ENDIF;
else_part: _ELSE decl stmt_list | ;
cond: expr compop expr | _TRUE | _FALSE;
compop: LESS_THAN | GREATER_THAN | EQUAL | NOT_EQUAL | LESS_THAN_EQUAL | GREATER_THAN_EQUAL;
while_stmt: _WHILE OPEN_BRACKET cond CLOSED_BRACKET decl stmt_list _ENDWHILE;

control_stmt: return_stmt;
loop_stmt: while_stmt;

%%

int yyerror(const char *s) {
	printf("Not Accepted");
	exit(0);
}
