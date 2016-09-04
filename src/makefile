#/bin/bash
CC=gcc
CFLAGS=-I./include -O0
SOURCE=source/%.c
$(shell mkdir -p object/lib)


object/lib/%.o: source/%.c
	$(CC) $(CFLAGS) -c -o $@ $^

object/%.o: %.c include/juliaSet.h include/complex.h
	$(CC) $(CFLAGS) -c -o $@ $<

tp0: object/main.o object/lib/juliaSet.o
	$(CC) $(CFLAGS) $^ -o $@

.PHONY: clean

clean:
	rm -f object/*.o tp0 object/lib/*.o
