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
%type <sym_node> expr_list
%type <sym_node> expr_list_tail

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
%type <ast_node> compop
%type <ast_node> cond
%type <ast_node> call_expr

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
pgm_body: decl {
	curr_var_list = $1; curr_stack = head_stack(curr_stack, curr_var_list, "GLOBAL"); print_stack(curr_stack);
	stack_head = head_stack(stack_head, $1, "GLOBAL");
	printf("push\n");
	printf("push r0\n");
	printf("push r1\n");
	printf("push r2\n");
	printf("push r3\n");
	printf("jsr FUNC_main\n");
	printf("sys halt\n");
}func_declarations {
	/*Handles global declaration here */
	curr_stack = pop_stack(curr_stack);
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
	Sym_node * ptr = put_var($2, $1, 0);
	ptr->fp_offset = fp_local--;
	$$ = ptr;
};
id_tail: COLON id id_tail {
	Sym_node * ptr = put_var($3, $2, 0); 
	ptr->fp_offset = fp_local--;
	$$ = ptr;
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
	Sym_node * ptr = new_var($2, $1);
	ptr->fp_offset = fp_arg++;
	$$ = ptr;
};
param_decl_tail: COLON param_decl param_decl_tail { 
	$$ = append_list($2, $3);
}| {
	$$ = NULL;
};

func_declarations: func_decl func_declarations | ;
func_decl: {fp_arg = 2; fp_local = -1;} _FUNC any_type id OPEN_BRACKET param_decl_list {
	curr_var_list = $6; curr_name = strdup($4);
} CLOSED_BRACKET _BEGIN func_body _END{};
func_body: decl {
	curr_var_list = append_list(curr_var_list, $1); 
	curr_stack = head_stack(curr_stack, curr_var_list, curr_name); 
	stack_head = head_stack(stack_head, curr_var_list, curr_name); 
	int num = stack_local_count(curr_stack, curr_name);
	printf("label FUNC_%s\n", curr_name);
	printf("link %d\n", num);
} stmt_list{
	$$ = $1;
	curr_stack = pop_stack(curr_stack);
	printf("unlnk\n");
	printf("ret\n");
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
return_stmt: _RETURN expr SEMICOLON {
	print_post_tree($2);
	AST_node * ptr = $2;
	printf("move %s r%d\n", ptr->name,  var_count);
	printf("move r%d $%d\n", var_count++, fp_arg + 4);
};

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
	$$ = $1;
};
call_expr: id OPEN_BRACKET expr_list CLOSED_BRACKET {
	//int count = stack_local_count(stack_head, $1);
	char * buffer = malloc(sizeof(*buffer) * 5);
	sprintf(buffer, "r%d", var_count++);
	Sym_node * ptr = new_var(buffer, INT_TYPE); //The type is dodgy
	ptr->fp_offset = 0;
	$$ = AST_node_make(buffer, ptr, INT_TYPE, NULL, NULL); //The type is also dodgy
	printf("push\n");
	printf("push r0\n");
	printf("push r1\n");
	printf("push r2\n");
	printf("push r3\n");
	ptr = $3;
	while(ptr != NULL){
		printf("push %s\n", ptr->name);
		ptr = ptr->next;
	}
	printf("jsr FUNC_%s\n", $1);
	ptr = $3;
	while(ptr != NULL){
		printf("pop\n");
		ptr = ptr->next;
	}
	printf("pop r3\n");
	printf("pop r2\n");
	printf("pop r1\n");
	printf("pop r0\n");
	printf("pop %s\n", buffer);
};
expr_list: expr expr_list_tail {
	print_post_tree($1);
	AST_node * expr = $1;
	Sym_node * ptr = put_var($2, expr->name, 0);
	$$ = ptr;
}| {$$ = NULL;};
expr_list_tail: COLON expr expr_list_tail {
	print_post_tree($2);
	AST_node * expr = $2;
	Sym_node * ptr = put_var($3, expr->name, 0);
	$$ = ptr;
}| {$$ = NULL;};
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

if_stmt: _IF OPEN_BRACKET cond {
	char * label = malloc(sizeof(int));
	*label = (char) max_label;
	curr_label = head_stack(curr_label, NULL, label);
	print_cond($3, IF_BLOCK, (int) *label);
	max_label += 2;
}CLOSED_BRACKET decl {curr_stack = head_stack(curr_stack, $6, "GENERIC IF");stack_head = head_stack(stack_head, $6, "GENERIC IF");}stmt_list {
	curr_stack = pop_stack(curr_stack);
	printf("jmp END_IF_ELSE%d\n", (int) *(curr_label->name) + 1);
	printf("label ELSE_%d\n", (int) *(curr_label->name));
} else_part {printf("label END_IF_ELSE%d\n", (int) *(curr_label->name) + 1); curr_label = pop_stack(curr_label);} _ENDIF;
else_part: _ELSE decl {curr_stack = head_stack(curr_stack, $2, "GENERIC ELSE");stack_head = head_stack(stack_head, $2, "GENERIC ELSE");} stmt_list {
	curr_stack = pop_stack(curr_stack);
}| ;
cond: expr compop expr {
	AST_node * head = $2;
	head->left = $1;
	head->right = $3;
	$$ = head;
}| _TRUE {
	$$ = AST_node_make("UNAMED", NULL, TRUE_TYPE, NULL, NULL);
}| _FALSE{
	$$ = AST_node_make("UNAMED", NULL, FALSE_TYPE, NULL, NULL);
};
compop: LESS_THAN {
	$$ = AST_node_make("UNAMED", NULL, LT_TYPE, NULL, NULL);
}| GREATER_THAN {
	$$ = AST_node_make("UNAMED", NULL, GT_TYPE, NULL, NULL);
}| EQUAL {
	$$ = AST_node_make("UNAMED", NULL, EQ_TYPE, NULL, NULL);
}| NOT_EQUAL {
	$$ = AST_node_make("UNAMED", NULL, NE_TYPE, NULL, NULL);
}| LESS_THAN_EQUAL {
	$$ = AST_node_make("UNAMED", NULL, LE_TYPE, NULL, NULL);
}| GREATER_THAN_EQUAL{
	$$ = AST_node_make("UNAMED", NULL, GE_TYPE, NULL, NULL);
};
while_stmt: _WHILE OPEN_BRACKET {
	char * label = malloc(sizeof(int));
	*label = (char) max_label;
	curr_label = head_stack(curr_label, NULL, label);
	printf("label WHILE_START_%d\n", (int) *label);
	max_label += 2;
}cond {print_cond($4, WHILE_BLOCK, (int) *(curr_label->name));} CLOSED_BRACKET decl {
	curr_stack = head_stack(curr_stack, $7, "GENERIC WHILE");
	stack_head = head_stack(stack_head, $7, "GENERIC WHILE");
}stmt_list {curr_stack = pop_stack(curr_stack);} _ENDWHILE {
	printf("jmp WHILE_START_%d\n", (int) *(curr_label->name));
	printf("label WHILE_END_%d\n", (int) *(curr_label->name) + 1);
	curr_label = pop_stack(curr_label);
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
