#include<stdio.h>
#include<stdlib.h>
#include<string.h>
#define UNDEFINED_TYPE 0
#define INT_TYPE 1
#define FLOAT_TYPE 2
#define STRING_TYPE 3
#define MAX_STRING_LENGTH 20 
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
Stack * stack_head = NULL;
Sym_node * sym_table = NULL;
Stack * temp_head = NULL;
int count = 0;
char * err_var = NULL;
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

Sym_node * duplicate_check(Sym_node * head, char * name) {
	Sym_node * ptr = head;
	while (ptr != NULL) {
		if (strcmp(ptr->name, name) == 0) {
			err_var = malloc(strlen(name) + 1);
			strcpy(err_var, name);	
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
			printf("Undefined type no value \n");
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

/*
 * vartype_decl takes in the main sym_table list, the incomplete id_list and the type of the variable
 *
 */
/*
Sym_node * vartype_decl(Sym_node * sym_table, int var_type, Sym_node * id_list) {
	while (id_list != NULL) {
		Sym_node * new_node = id_list;
		id_list = id_list->next;
		
		Sym_node * check = duplicate_check(sym_table, new_node->name);
		if (check == NULL) {
			new_node->next = sym_table;
			new_node->type = var_type;
			sym_table = new_node;
		}
	}
	return(sym_table);
}
*/
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
}
