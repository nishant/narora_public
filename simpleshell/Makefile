# - Header ---------------------------------------------------------------------
CC = gcc
CFLAGS = -ansi -Wall -g -O0 -Wwrite-strings -Wshadow -fstack-protector-all
PROGS = d8sh
.PHONY: all clean

all: $(PROGS)

# - Executable -----------------------------------------------------------------
d8sh: d8sh.o executor.o lexer.o parser.tab.o
	$(CC) d8sh.o executor.o lexer.o parser.tab.o -o d8sh -lreadline

# - Object Files ---------------------------------------------------------------
lexer.o: lexer.c lexer.h parser.tab.h
	$(CC) $(CFLAGS) -c lexer.c

d8sh.o: *.c executor.h lexer.h
	$(CC) $(CFLAGS) -c d8sh.c

parser.tab.o: parser.tab.c parser.tab.h command.h
	$(CC) $(CFLAGS) -c parser.tab.c

executor.o: executor.c executor.h command.h
	$(CC) $(CFLAGS) -c executor.c

# ------------------------------------------------------------------------------
clean:
	rm -f *.o $(PROGS)
