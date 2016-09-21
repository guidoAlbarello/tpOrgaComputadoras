CC=gcc
CFLAGS= -Wall -O0
ASSEMBLY_FLAGS= -S -mrnames

all: main.c 
	$(CC) $(CFLAGS) -o tp0 main.c

assembly:
	$(CC) $(CFLAGS) $(ASSEMBLY_FLAGS) main.c

clean: 
	$(RM) tp0
