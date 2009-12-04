CC= gcc
RM= rm -f
CFLAGS= -Wall
SRC= dhun.c
OBJ= dhun.o

default: $(OBJ)
	$(CC) $(OBJ) -o dhun

dhun.o:
	$(CC) -c dhun.c

clean:
	$(RM) *.o dhun
