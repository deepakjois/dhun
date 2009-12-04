CC= gcc
RM= rm -f
CFLAGS= -Wall
SRC= dhun.c
OBJ= ${SRC:.c=.o}

default: $(OBJ)
	$(CC) $(OBJ) -o dhun
dhun.o:
	$(CC) -c dhun.o


