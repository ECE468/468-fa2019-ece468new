#include<stdio.h>
#include<stdlib.h>
#include<string.h>
#define UNDEFINED_TYPE 0
#define INT_TYPE 1
#define FLOAT_TYPE 2
#define STRING_TYPE 3
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

Sym_node * sym_table = NULL;
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

Sym_node * duplicate_check(Sym_node * head, char * name) {
	Sym_node * ptr = head;
	while (ptr != NULL) {
		if (strcmp(ptr->name, name) == 0) {
			printf("DECLARATION ERROR %s \n", name);
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
	ptr->string_val = (char *) malloc(sizeof(string_val) + 1);
	strcpy(ptr->string_val, string_val);
	return (ptr);
}

void print_var_list(Sym_node * head) {
	Sym_node * ptr = head;
	while (ptr != NULL) {
		printf("------------------------------------\n");
		printf(" Name: %s |", ptr->name);
		printf(" Type: %d |", ptr->type);
		if (ptr->type == INT_TYPE) {
			printf(" Int value: %d \n", ptr->int_val);
		}
		else if (ptr->type == FLOAT_TYPE) {
			printf(" Float value: %f \n", ptr->float_val);
		}
		else{
			printf(" String value: %s \n", ptr->string_val);
		}
		printf("--------------------------------------\n");
		printf("v\n");
		ptr = ptr->next;
	}
	printf("NULL\n");
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

Sym_node * append_list(Sym_node * base, Sym_node * to_append) {
	while (to_append != NULL) {
		Sym_node * new_node = to_append;
		to_append = to_append->next;
		
		Sym_node * check = duplicate_check(base, new_node->name);
		if (check == NULL) {
			new_node->next = base;
			base = new_node;
		}
	}
	return(base);
}

Sym_node * put_var(Sym_node * head, char* var_name, int type) {
	Sym_node * ptr = (Sym_node*) malloc(sizeof(Sym_node));
	ptr->name = (char *) malloc(strlen(var_name) + 1);
	strcpy(ptr->name, var_name);
	ptr->type = type;
	ptr->next = head;
	return(ptr);
}
