#include<stdio.h>
#include<stdlib.h>
#include<string.h>
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

Sym_node * sym_table = NULL;
Sym_node * put_int(Sym_node * head, char* var_name, int int_val);
Sym_node * put_float(Sym_node * head, char * var_name, float float_val);
Sym_node * put_string(Sym_node * head, char * var_name, char * string_val);
Sym_node * duplicate_check(Sym_node * head, char * name);

void print_var_list(Sym_node * head);

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
Sym_node * put_string(Sym_node * head, char* var_name, char* string_val) {
	
	Sym_node * check = duplicate_check(head, var_name);
	if (check != NULL) {
		return(head);
	}
	Sym_node * ptr = (Sym_node*) malloc(sizeof(Sym_node));
	printf("ptr->name: %p\n", (void *) ptr->name);
	printf("var_name: %p\n", (void *) var_name);
	/*ptr->name = (char *) malloc(strlen(var_name) + 1);
	strcpy(ptr->name, var_name);*/
	ptr->type = INT_TYPE;
	/*ptr->string_val = (char *) malloc(sizeof(string_val) + 1);
	strcpy(ptr->string_val, string_val);*/
	ptr->next = head;
	return(ptr);
}

void print_var_list(Sym_node * head) {
	Sym_node * ptr = head;
	while (ptr != NULL) {
		printf("name: %s \n");
		printf("type: %d \n", ptr->type);
		/*if (ptr->type == INT_TYPE) {
			printf("int value: %d \n", ptr->int_val);
		}
		else if (ptr->type == FLOAT_TYPE) {
			printf("float value: %f \n", ptr->float_val);
		}
		else{
			printf("string value: %s \n", ptr->string_val);
		}*/
		printf("\n");
		ptr = ptr->next;
	}
}
