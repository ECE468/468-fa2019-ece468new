#include<stdio.h>
#include<stdlib.h>
#include<string.h>
#define UNDEFINED_TYPE 0
#define INT_TYPE 1
#define FLOAT_TYPE 2
#define STRING_TYPE 3
#define MAX_STRING_LENGTH 20
#define MULTI 4
#define PLUS_TYPE 5
#define MINUS_TYPE 6
#define DIVIDE_TYPE 7
#define MULTIPLY_TYPE 8
#define EQUAL_TYPE 9
#define READ_TYPE 10
#define WRITE_TYPE 11
#define NODE_EXPR 1
#define NODE_VAR 2
#define NODE_LIT 3

typedef struct Sym_node {
	char * name;
	int int_val;
	char * string_val;
	float float_val;
	int type;
	struct Sym_node * next;
} Sym_node;

typedef struct Stack {
	char * name;
	Sym_node * node;
	struct Stack * next;
} Stack;

typedef struct AST_node {
	char * name;
	Sym_node * pointer;
	int asttype;
	struct AST_node * left;
	struct AST_node * right;
} AST_node;

Stack * stack_head = NULL;
Sym_node * sym_table = NULL;
Sym_node * curr_var_list = NULL;
Stack * curr_stack = NULL;
Stack * temp_head = NULL;
char * curr_name = NULL;
int count = 0;
char * err_var = NULL;
int var_count = 0;
Sym_node * put_int(Sym_node * head, char* var_name, int int_val);
Sym_node * put_float(Sym_node * head, char * var_name, float float_val);
//Sym_node * put_string(Sym_node * head, char * var_name, char * string_val);
Sym_node * put_string(char * var_name, char * string_val);
Sym_node * duplicate_check(Sym_node * head, char * name);
Sym_node * put_var(Sym_node * head, char* var_name, int type);
void print_var_list(Sym_node * head);
//Sym_node * vartype_decl(Sym_node * sym_table, int var_type, Sym_node * id_list);
Sym_node * vartype_decl(Sym_node * head, int var_type);
void free_list(Sym_node * head);
Sym_node * new_var(char * var_name, int type);
Stack * build_stack(Stack * head, Sym_node * table, char * name);
void print_stack(Stack * head);
Stack * head_stack(Stack * head, Sym_node * table, char * name);
Stack * connect(Stack * head, Stack * temphead);
Sym_node * print_post_tree(AST_node * tree);
AST_node * AST_node_make(char * name, Sym_node * ptr, int type, AST_node * left, AST_node * right);
Stack * pop_stack(Stack * head);
Sym_node * check_stack(Stack * head, char * name);
void print_var_node(Sym_node * head);

Sym_node * duplicate_check(Sym_node * head, char * name) {
	Sym_node * ptr = head;
	while (ptr != NULL) {
		if (strcmp(ptr->name, name) == 0) {
			err_var = malloc(strlen(name) + 1);
			strcpy(err_var, name);
			return(ptr);	
		}
		ptr = ptr->next;
	}
	return (0);
}

Sym_node * put_int(Sym_node * head, char* var_name, int int_val) {
	Sym_node * check = duplicate_check(head, var_name);
	if (check != NULL) {
		return(head);
	}
	Sym_node * ptr = malloc(sizeof(Sym_node));
	ptr->name = malloc(strlen(var_name) + 1);
	strcpy(ptr->name, var_name);
	ptr->type = INT_TYPE;
	ptr->int_val = int_val;
	ptr->next = head;
	return(ptr);
}
Sym_node * put_float(Sym_node * head, char* var_name, float float_val) {

	Sym_node * check = duplicate_check(head, var_name);
	if (check != NULL) {
		return(head);
	}
	Sym_node * ptr = (Sym_node *) malloc(sizeof(Sym_node));
	ptr->name = malloc(strlen(var_name) + 1);
	strcpy(ptr->name, var_name);
	ptr->type = FLOAT_TYPE;
	ptr->int_val = float_val;
	ptr->next = head;
	return(ptr);
}
/*
Sym_node * put_string(Sym_node * head, char* var_name, char* string_val) {
	
	Sym_node * check = duplicate_check(head, var_name);
	if (check != NULL) {
		return(head);
	}
	Sym_node * ptr = (Sym_node*) malloc(sizeof(Sym_node));
	ptr->name = (char *) malloc(strlen(var_name) + 1);
	strcpy(ptr->name, var_name);
	ptr->type = STRING_TYPE;
	ptr->string_val = (char *) malloc(sizeof(string_val) + 1);
	strcpy(ptr->string_val, string_val);
	ptr->next = head;
	return(ptr);
}
*/
Sym_node * put_string(char * var_name, char * string_val) {
	Sym_node * ptr = (Sym_node *) malloc(sizeof(Sym_node));
	ptr->name = (char *) malloc(strlen(var_name) + 1);
	strcpy(ptr->name, var_name);
	ptr->type = STRING_TYPE;
	ptr->string_val = (char *) malloc(strlen(string_val) + 1);
	strcpy(ptr->string_val, string_val);
	return (ptr);
}

void print_var_list(Sym_node * head) {
	Sym_node * ptr = head;
	while (ptr != NULL) {
		if (ptr->type == INT_TYPE) {
			printf("name %s type INT\n", ptr-> name);
		}
		else if (ptr->type == FLOAT_TYPE) {
			printf("name %s type FLOAT\n", ptr->name);
		}
		else if (ptr->type == STRING_TYPE){
			printf("name %s type STRING value %s\n", ptr-> name, ptr->string_val);
		}
		else {
			printf("name %s, undefined type no value\n", ptr->name);
		}
		ptr = ptr->next;
	}
}

void free_list(Sym_node * head) {
	Sym_node * ptr = head;
	if (ptr != NULL) {
		if (ptr->next != NULL) {
			free_list(ptr->next);
		}
		free(ptr);
	}
}

Sym_node * vartype_decl(Sym_node * head, int var_type) {
	Sym_node * ptr = head;	
	while (ptr != NULL) {
		ptr->type = var_type;
		ptr = ptr->next;
	}
	return(head);
}

Sym_node * append_list(Sym_node * head, Sym_node * tail) {
	Sym_node * ptr = head;
	if (ptr == NULL) {
		return(tail);
	}
	while (ptr != NULL) {
		Sym_node * check = duplicate_check(tail, ptr->name);
		if (check != NULL) {
			return NULL;
		}
		ptr = ptr->next;
	}
	ptr = head;
	while (ptr->next != NULL) {
		ptr = ptr->next;
	}
	ptr->next = tail;
	return(head);
}

Sym_node * put_var(Sym_node * head, char* var_name, int type) {
	Sym_node * ptr = (Sym_node*) malloc(sizeof(Sym_node));
	ptr->name = (char *) malloc(strlen(var_name) + 1);
	strcpy(ptr->name, var_name);
	ptr->type = type;
	ptr->next = head;
	return(ptr);
}

Sym_node * new_var(char * var_name, int type) {
	Sym_node * ptr = (Sym_node*) malloc(sizeof(Sym_node));
	ptr->name = (char *) malloc(strlen(var_name) + 1);
	strcpy(ptr->name, var_name);
	ptr->type = type;
	ptr->next = NULL;
	return(ptr);
}
Stack * build_stack(Stack * head, Sym_node * table, char * name) {
	Stack * ptr = head;
	if (head == NULL) {
		Stack * ptr = (Stack *) malloc(sizeof(Stack));
		ptr->name = (char *) malloc(sizeof(name) + 1);
		strcpy(ptr->name, name);
		ptr->node = table;
		return(ptr);
	}
	else {
		while (ptr->next != NULL) {
			ptr = ptr->next;
		}
		ptr->next = build_stack(NULL, table, name);
	}
	return(head);
}

Stack * head_stack(Stack * head, Sym_node * table, char * name) {
	Stack * ptr = (Stack *) malloc(sizeof(Stack));
	ptr->name = (char *) malloc(sizeof(name) + 1);
	strcpy(ptr->name, name);
	ptr->node = table;
	ptr->next = head;
	return(ptr);
}

Stack * connect(Stack * head, Stack * temphead) {
	Stack * ptr = head;
	if (ptr == NULL) {
		return(temphead);
	}
	else {
		while (ptr->next != NULL) {
			ptr = ptr->next;
		}
		ptr->next = temphead;
		return(head);
	}
}
void print_stack(Stack * head) {
	if (err_var != NULL) {
		printf("DECLARATION ERROR %s\n", err_var);
		return;		
	}
	Stack * ptr = head;
	int track = 1;
	int count = 0;
	while (ptr != NULL) {
		if (strcmp(ptr->name, "GENERIC_BLOCK") == 0) {
			char str[MAX_STRING_LENGTH];
			sprintf(str, "BLOCK %d", ++count);
			ptr->name = str;
		}
		printf("Symbol table %s\n", ptr->name);
		print_var_list(ptr->node);
		printf("\n");
		ptr = ptr->next;
	}
	printf("-------------------------\n");
}

Stack * pop_stack(Stack * head) {
	if (head == NULL) {
		return(NULL);
	}
	Stack * ptr = head->next;
	head->next = NULL;
	return (ptr);
}

AST_node * AST_node_make(char * name, Sym_node * ptr, int type, AST_node * left, AST_node * right) {
	AST_node * node = (AST_node *) malloc(sizeof(AST_node));
	//node->name = (char *) malloc(sizeof(name) + 1);
	//if (ptr != NULL) {
	//	strcpy(ptr->name, name);
	//}
	node->name = name;
	node->pointer = ptr;
	node->asttype = type;
	node->left = left;
	node->right = right;
	return(node);
}

Sym_node * print_post_tree(AST_node * tree) {
	if (tree == NULL) {
		return (NULL);
	}
	Sym_node * left = print_post_tree(tree->left);
	Sym_node * right = print_post_tree(tree->right);
	char temp[MAX_STRING_LENGTH];
	char * temp_var = NULL;
	Sym_node * ptr = tree->pointer;
	//printf("%s\n", tree->name);
	switch (tree->asttype)
	{
	case INT_TYPE: 
		//printf("int type, %d\n", tree->pointer->int_val);
		//print_var_node(tree->pointer);
		if (!strcmp("LITERAL", ptr->name)){
			sprintf(temp, "!T%d", var_count++);
			temp_var = strdup(temp);
			printf(";STOREI %d %s\n", ptr->int_val, temp_var);
			ptr->name = temp;
			return(ptr);
		}
		return(ptr);
		break;
	case FLOAT_TYPE: 
		//printf("float type, %f\n", tree->pointer->float_val);
		//print_var_node(tree->pointer);
		if (!strcmp("LITERAL", ptr->name)){
			sprintf(temp, "!T%d", var_count++);
			temp_var = strdup(temp);
			printf(";STOREF %f %s\n", ptr->float_val, temp_var);
			ptr->name = temp;	
		}
		return(ptr);
		break;
	case STRING_TYPE: 
		printf("string type, %s\n", tree->pointer->string_val);
		print_var_node(tree->pointer);
		return(ptr);
		break;
	case PLUS_TYPE: 
		//printf("plus type\n");
		//print_var_node(tree->pointer);

		sprintf(temp, "!T%d", var_count++);
		temp_var = strdup(temp);
	
		if (left->type == INT_TYPE) {
			ptr = new_var(temp_var, INT_TYPE);
			printf(";ADDI %s %s %s\n", left->name,right->name, temp_var);
		} else {
			ptr = new_var(temp_var, FLOAT_TYPE);
			printf(";ADDF %s %s %s\n", left->name,right->name, temp_var);
		}
		ptr->name = temp_var;
		return(ptr);
		break;
	case MINUS_TYPE: 
		//printf("minus type\n");
		//print_var_node(tree->pointer);

		sprintf(temp, "!T%d", var_count++);
		temp_var = strdup(temp);
		if (left->type == INT_TYPE) {
			ptr = new_var(temp_var, INT_TYPE);
			printf(";SUBI %s %s %s\n", left->name,right->name, temp_var);
		} else {
			ptr = new_var(temp_var, FLOAT_TYPE);
			printf(";SUBF %s %s %s\n", left->name,right->name, temp_var);
		}
		ptr->name = temp_var;
		return(ptr);
		break;
	case DIVIDE_TYPE: 
		//printf("divide type\n");
		//print_var_node(tree->pointer);
	
		sprintf(temp, "!T%d", var_count++);
		temp_var = strdup(temp);
		if (left->type == INT_TYPE) {
			ptr = new_var(temp_var, INT_TYPE);
			printf(";DIVI %s %s %s\n", left->name,right->name, temp_var);
		} else {
			ptr = new_var(temp_var, FLOAT_TYPE);
			printf(";DIVF %s %s %s\n", left->name,right->name, temp_var);
		}
		ptr->name = temp_var;
		return(ptr);
		break;
	case MULTIPLY_TYPE: 
		//printf("multiply type\n");
		//print_var_node(tree->pointer);
			
		sprintf(temp, "!T%d", var_count++);
		temp_var = strdup(temp);
		if (left->type == INT_TYPE) {
			ptr = new_var(temp_var, INT_TYPE);
			printf(";MULI %s %s %s\n", left->name,right->name, temp_var);
		} else {
			ptr = new_var(temp_var, FLOAT_TYPE);	
			printf(";MULF %s %s %s\n", left->name,right->name, temp_var);
		}
		ptr->name = temp_var;
		return(ptr);
		
		break;
	case EQUAL_TYPE: 
		//printf("equal type\n");
		//print_var_node(tree->pointer);
		if (left->type == INT_TYPE) {
			printf(";STOREI %s %s\n", right->name,left->name);
		} else {
			printf(";STOREF %s %s\n", right->name,left->name);
		}
		return(ptr);
		break;
	case READ_TYPE: 
		//printf("read type\n");
		//print_var_list(tree->pointer);
		while (ptr!= NULL) {
			Sym_node * node = check_stack(curr_stack, ptr->name);
			if (node->type == INT_TYPE) {
				printf(";READI %s\n", ptr->name);
			} else if (node->type == FLOAT_TYPE){
				printf(";READF %s\n", ptr->name);
			} else {
				printf(";READS %s\n", ptr->name);
			}
			ptr = ptr->next;
		}
		break;
	case WRITE_TYPE: 
		//printf("write type\n");
		//print_var_list(tree->pointer);
		while (ptr!= NULL) {
			Sym_node * node = check_stack(curr_stack, ptr->name);
			if (node->type == INT_TYPE) {
				printf(";WRITEI %s\n", ptr->name);
			} else if (node->type == FLOAT_TYPE) {
				printf(";WRITEF %s\n", ptr->name);
			} else {
				printf(";WRITES %s\n", ptr->name);
			}
			ptr = ptr->next;
		}
		break;
	}
	return(NULL);
}

Sym_node * check_stack(Stack * head, char * name) {
	Stack * ptr = head;
	Sym_node * track = duplicate_check(head->node, name);
	if (track != 0) {
		return track;
	}
	else if (ptr->next != NULL) {
		check_stack(ptr->next, name);
	}
}

void print_var_node(Sym_node * head) {
	Sym_node * ptr = head;
	if (ptr != NULL) {
		if (ptr->type == INT_TYPE) {
			printf("name %s type INT\n", ptr-> name);
		}
		else if (ptr->type == FLOAT_TYPE) {
			printf("name %s type FLOAT\n", ptr->name);
		}
		else if (ptr->type == STRING_TYPE){
			printf("name %s type STRING value %s\n", ptr-> name, ptr->string_val);
		}
		else {
			printf("name %s, Undefined type no value \n");
		}
		ptr = ptr->next;
	}
}
