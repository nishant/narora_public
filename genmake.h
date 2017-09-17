#if !defined(GENMAKE_H)
#define GENMAKE_H

#define SUCCESS 0
#define FAILURE 1
#define MAX_LINE_SIZE 80

typedef struct Node {
  char *text;
  List *list;
  struct Node *next
} Node;

typedef struct List {
  int size;
  Node *head;
} List;

typedef enum list_type { All, C, O, X };

static List[4] Master_List;


#endif

#if 0 /* regex commands used */
ls -d *.c | sed -e 's/.*/mv & &/' -e 's/c$/x/' | sh
grep -Er --exclude='*.c.~*' 'main\s*\(' * | cut -d':' -f1
#endif

((grep -Er --exclude='*.c.~*' 'main\s*\(' * | cut -d':' -f1) && (ls -d *.c | sed -e 's/.*/mv & &/' -e 's/c$/x/' | sh
) > "all_execuables.txt")
