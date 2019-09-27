%{
	#include <stdio.h>
	#include <string.h>
	#include <stdlib.h>
	#include "node.h"
	int yyerror(const char *s);
	extern int yylex();
%}

%union {
	char *strv;
	int int_val;
	float float_val;
	struct Sym_node * sym_node;
	struct Stack * stack;
}
%token <int_val> INTLITERAL
%token <float_val> FLOATLITERAL
%token <strv> STRINGLITERAL
%token <strv> IDENTIFIER
%token <strv> _PROG
%token <strv> _BEGIN
%token <strv> _END
%token <strv> _ENDIF
%token <strv> _STR
%token <int_val> _FLOAT
%token <float_val> _INT
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

%type <sym_node> var_decl
%type <sym_node> string_decl
%type <sym_node> decl
%type <sym_node> pgm_body
%type <sym_node> id_list
%type <sym_node> id_tail
%type <int_val> var_type
%type <strv> str_literal
%type <strv> id
%%

program: _PROG id _BEGIN pgm_body _END {
};
id : IDENTIFIER {$$ = $1;}; 
pgm_body: decl func_declarations {
	/*Handles global declaration here */
	printf("Global statement block\n");
	stack_head = build_stack(stack_head, $1, "global");
	print_stack(stack_head);
	//print_var_list($1);
};
decl: string_decl decl {	
	/*Append string_decl to the current symbol table pointer*/
	$$ = append_list($2, $1);
}| var_decl decl {
	/*Append var_decl to the current symbol table pointer*/
	$$ = append_list($2, $1);
}
| {
	/*clear out the current symbol table */
	$$ = NULL;
};
string_decl: _STR id EQUAL str_literal SEMICOLON {
	/*Need rewriting, just return 1 Sym_table pointer that points to the Sym_table object populated with strings and type*/
	$$ = put_string($2, $4);
};
str_literal: STRINGLITERAL {$$ = $1; };

var_decl: var_type id_list SEMICOLON {
	/*Need rewritting, return 1 sym_table pointer that points to a list of Sym_table populated with types and names*/
	$$ = vartype_decl($2, $1);
};
var_type: _FLOAT {$$ = FLOAT_TYPE;} | _INT {$$= INT_TYPE;};
any_type: var_type | _VOID;
id_list: id id_tail {
	$$ = put_var($2, $1, 0);
};
id_tail: COLON id id_tail {
	$$ = put_var($3, $2, 0); 
}
| {
	$$ = NULL;
};
param_decl_list: param_decl param_decl_tail | ;
param_decl: var_type id;
param_decl_tail: COLON param_decl param_decl_tail | ;

func_declarations: func_decl func_declarations | ;
func_decl: _FUNC any_type id OPEN_BRACKET param_decl_list CLOSED_BRACKET _BEGIN func_body _END;
func_body: decl stmt_list{
	printf("Func statement block\n");
	print_var_list($1);
};

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

if_stmt: _IF OPEN_BRACKET cond CLOSED_BRACKET decl stmt_list else_part _ENDIF{
	printf("If statement decl\n");
	print_var_list($5);
};
else_part: _ELSE decl stmt_list {printf("Else statement block\n"); print_var_list($2); }| ;
cond: expr compop expr | _TRUE | _FALSE;
compop: LESS_THAN | GREATER_THAN | EQUAL | NOT_EQUAL | LESS_THAN_EQUAL | GREATER_THAN_EQUAL;
while_stmt: _WHILE OPEN_BRACKET cond CLOSED_BRACKET decl stmt_list _ENDWHILE {
	printf("While statement block\n");
	print_var_list($5);
};

control_stmt: return_stmt;
loop_stmt: while_stmt;

%%

int yyerror(const char *s) {
	printf("Not Accepted");
	exit(0);
}
