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
	struct AST_node * ast_node;
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
%token <int_val> _INT
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
%token <int_val> EQUAL
%token <strv> SEMICOLON
%token <strv> COLON
%token <strv> OPEN_BRACKET
%token <strv> CLOSED_BRACKET
%token <int_val> PLUS
%token <int_val> MINUS
%token <int_val> MULTIPLY
%token <int_val> DIVIDE
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
%type <sym_node> func_body
%type <sym_node> func_decl
%type <sym_node> param_decl_list
%type <sym_node> param_decl
%type <sym_node> param_decl_tail

%type <ast_node> base_stmt
%type <ast_node> assign_stmt
%type <ast_node> read_stmt
%type <ast_node> write_stmt
%type <ast_node> control_stmt
%type <ast_node> expr
%type <ast_node> expr_prefix
%type <ast_node> factor
%type <ast_node> factor_prefix
%type <ast_node> assign_expr
%type <ast_node> postfix_expr
%type <ast_node> primary

%type <int_val> var_type
%type <ast_node> mulop
%type <ast_node> addop
%type <strv> str_literal
%type <strv> id
%%

program: _PROG id _BEGIN pgm_body _END {
	//print_stack(stack_head);
};
id : IDENTIFIER {$$ = $1;}; 
pgm_body: decl {curr_var_list = $1; curr_stack = head_stack(curr_stack, curr_var_list, "GLOBAL");}func_declarations {
	/*Handles global declaration here */
	curr_stack = pop_stack(curr_stack);
	stack_head = head_stack(stack_head, $1, "GLOBAL");
};
decl: string_decl decl {	
	/*Append string_decl to the current symbol table pointer*/
	$$ = append_list($1, $2);
}| var_decl decl {
	/*Append var_decl to the current symbol table pointer*/
	$$ = append_list($1, $2);
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
param_decl_list: param_decl param_decl_tail {
	$$ = append_list($1, $2);
}| {
	$$ = NULL;
};
param_decl: var_type id {
	$$ = new_var($2, $1);
};
param_decl_tail: COLON param_decl param_decl_tail { 
	$$ = append_list($2, $3);
}| {
	$$ = NULL;
};

func_declarations: func_decl func_declarations | ;
func_decl: _FUNC any_type id OPEN_BRACKET param_decl_list {curr_var_list = $5; curr_name = strdup($3);} CLOSED_BRACKET _BEGIN func_body _END{
	Sym_node * table = append_list($5, $9);
	temp_head = head_stack(temp_head, table, $3);
	stack_head = connect(stack_head, temp_head);
	temp_head = NULL;
};
func_body: decl {curr_var_list = append_list(curr_var_list, $1); curr_stack = head_stack(curr_stack, curr_var_list, curr_name); print_stack(curr_stack);} stmt_list{
	$$ = $1;
	curr_stack = pop_stack(curr_stack);
	printf("sys halt");
};

stmt_list: stmt stmt_list| ;
stmt: base_stmt {
	print_post_tree($1);
}| if_stmt | loop_stmt;
base_stmt: assign_stmt {
	$$ = $1;
}| read_stmt {
	$$ = $1;
}| write_stmt{
	$$ = $1;
}| control_stmt{
	$$ = $1;
};

assign_stmt: assign_expr SEMICOLON {
	$$ = $1;
};
assign_expr: id EQUAL expr {
	Sym_node * ptr = check_stack(curr_stack, $1);
	AST_node * left = AST_node_make($1, ptr, ptr->type, NULL, NULL);
	$$ = AST_node_make("unname", NULL, EQUAL_TYPE, left, $3);
};
read_stmt: _READ OPEN_BRACKET id_list CLOSED_BRACKET SEMICOLON{
	$$ = AST_node_make("READ", $3, READ_TYPE, NULL, NULL);
};
write_stmt: _WRITE OPEN_BRACKET id_list CLOSED_BRACKET SEMICOLON {
	$$ = AST_node_make("WRITE", $3, WRITE_TYPE, NULL, NULL);
};
return_stmt: _RETURN expr SEMICOLON {};

expr: expr_prefix factor {
/* Will expr_prefix ever NULL?*/
	AST_node * head = $1;
	if (head == NULL) {
		$$ = $2; //Not sure about this....
	} else {
		head->right = $2;
		$$ = head;
	}
};
expr_prefix: expr_prefix factor addop {
	if ($1 == NULL) {
		AST_node * head = $3;
		head->left = $2;
		$$ = head;
	}
	else {
		AST_node * head = $3;
		$1->right = $2;
		head->left = $1;
		$$ = head;
	}
}| {
	$$ = NULL;
};
factor: factor_prefix postfix_expr {
	AST_node * head = $1;
	if (head != NULL) {
		head->right = $2;
		$$ = head; //Needs implementation
	} else {
		$$ = $2;
	}
};
factor_prefix: factor_prefix postfix_expr mulop {
	AST_node * head = $3;
	head->left = $2;
	$$ = head; //Needs implementation
}| {
	$$ = NULL;
};
postfix_expr: primary {
	$$ = $1;
}| call_expr {
	$$ = NULL;
};
call_expr: id OPEN_BRACKET expr_list CLOSED_BRACKET;
expr_list: expr expr_list_tail | ;
expr_list_tail: COLON expr expr_list_tail | ;
primary: OPEN_BRACKET expr CLOSED_BRACKET {
	/*What is primary?? */
	$$ = $2;
}| id {
	Sym_node * ptr = check_stack(curr_stack, $1);
	if (ptr == NULL) {
		printf("Undeclared variable\n");
	}else {
		$$ = AST_node_make($1, ptr, ptr->type, NULL, NULL);
	}
}| INTLITERAL {
	Sym_node * ptr = new_var("LITERAL", INT_TYPE);
	ptr->int_val = $1; /*Need to modify lexer for this*/
	$$ = AST_node_make("LITERAL", ptr, INT_TYPE, NULL, NULL);
}| FLOATLITERAL{
	Sym_node * ptr = new_var("LITERAL", FLOAT_TYPE);
	ptr->float_val = $1; /*Need to modify lexer for this */
	$$ = AST_node_make("LITERAL", ptr, FLOAT_TYPE, NULL, NULL);
};
addop: PLUS {
	$$ = AST_node_make("UNAMED", NULL, PLUS_TYPE, NULL, NULL);
}| MINUS {
	$$ = AST_node_make("UNAMED", NULL, MINUS_TYPE, NULL, NULL);
};
mulop: MULTIPLY {
	$$ = AST_node_make("UNAMED", NULL, MULTIPLY_TYPE, NULL, NULL);
}| DIVIDE {
	$$ = AST_node_make("UNAMED", NULL, DIVIDE_TYPE, NULL, NULL);
};

if_stmt: _IF OPEN_BRACKET cond CLOSED_BRACKET decl {curr_stack = head_stack(curr_stack, $5, "GENERIC IF");}stmt_list {curr_stack = pop_stack(curr_stack);}else_part _ENDIF{
	temp_head = head_stack(temp_head, $5, "GENERIC_BLOCK");
};
else_part: _ELSE decl {curr_stack = head_stack(curr_stack, $2, "GENERIC ELSE");} stmt_list {
	curr_stack = pop_stack(curr_stack);
	temp_head = head_stack(temp_head, $2, "GENERIC_BLOCK");
}| ;
cond: expr compop expr | _TRUE | _FALSE;
compop: LESS_THAN | GREATER_THAN | EQUAL | NOT_EQUAL | LESS_THAN_EQUAL | GREATER_THAN_EQUAL;
while_stmt: _WHILE OPEN_BRACKET cond CLOSED_BRACKET decl {curr_stack = head_stack(curr_stack, $5, "GENERIC WHILE");}stmt_list {curr_stack = pop_stack(curr_stack);} _ENDWHILE {
	temp_head = head_stack(temp_head, $5, "GENERIC_BLOCK");
};

control_stmt: return_stmt {
	$$ = NULL;
};
loop_stmt: while_stmt;

%%

int yyerror(const char *s) {
	printf("Not Accepted");
	exit(0);
}
