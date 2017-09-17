#include <stdio.h>
#include <string.h>
#include <stdlib.h>
/* grep -Er 'main\s*\(' * | cut -d':' -f1 */
int main(int argc, char const *argv[]) {
  List list;

  init(&list);

  return SUCCESS;
}

int init_list(List *list) {
  if(list != NULL) {
    list->size = 0;
    list->head = NULL;
    return SUCCESS;
  }
  return FAILURE;
}

int add_to_list(List *list, char *text) {
  Node *to_add, *curr;

  /* text validity check? */

  if(list == NULL) { /* adding to empty list */
    list = malloc(sizeof(List));
    to_add = malloc(sizeof(Node));
    to_add->text = malloc(strlen(text) + 1);

    if(list == NULL || to_add == NULL || to_add->text == NULL) {
      return FAILURE;
    }

    strcpy(to_add->text, text);
    to_add->next = NULL;
    to_add->list = NULL;
    list->head = to_add;
    list->size++;

  } else { /* add to end of list */
    *curr = list->head;

    while (curr != NULL) {
      curr = curr->next;
    }

    to_add = malloc(sizeof(Node));
    to_add->text = malloc(strlen(text) + 1);

    if(to_add == NULL || to_add->text == NULL) {
      return FAILURE;
    }

    strcpy(to_add->text, text);
    to_add->next = NULL;
    to_add->list = NULL;
    curr->next = to_add;
    list->size++;
  }
  return SUCCESS;
}
int ends_with(const char *str, const char *suffix) {
    if(!str || !suffix)
      return 0;
    size_t len_str = strlen(str);
    size_t len_suffix = strlen(suffix);
    if (len_suffix >  len_str)
        return 0;
    return strncmp(str + len_str - len_suffix, suffix, len_suffix) == 0;
}

int ends_with_dot_c(const char *str) {
  return ends_with(str, ".c");
}

int ends_with_dot_o(const char *str) {
  return ends_with(str, ".o");
}

int get_executable_files() {
  char *line, *executable_line;
  int i;
  FILE *c_to_x, *all_x;

  system("rm -f c_to_x.txt"); /* lists files with main */
  system("rm -f all_x.txt"); /* lists files with main */
  system("grep -Er --exclude='*.c.~*' 'main\s*\(' * | cut -d':' -f1 > c_to_x.txt"); /* lists files with main */

  c_to_x = fopen("c_to_x.txt", "r");
  all_x = fopen("all_x.txt", "w");

  while(fgets(line, MAX_LINE_SIZE, c_to_x) != NULL) {
    strcpy(executable_line, line);

    for(i = 0; i < MAX_LINE_SIZE; i++) {
      if(line[i] == '.' && line[i + 1] == 'c' && line[i + 2] == '\0') { /* ends in .c */
        executable_line[i + 1] = 'x';
        break;
      }
    }
    fprintf(all_x, "%s\n", executable_line);
  }
}

int get_object_files() {
  char *line;
  FILE *executable_files;
  FILE *object_files;


  file = fopen("all_execuables.txt", "r");
  while(fgets(line, MAX_LINE_SIZE, FILE *stream) != NULL) {
    if(ends_with_dot_c(line) == 0) {

    }
  }
