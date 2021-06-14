CC=gcc
CFLAGS=-m32 -Wall

all:		main.o f.o
	$(CC) $(CFLAGS) main.o f.o -o fun $(pkg-config allegro-5 allegro_font-5 allegro_primitives-5 allegro_ttf-5 allegro_image-5 --libs --cflags)

main.o:		main.c
	$(CC) -m32 -Wall -c main.c -o main.o 

f.o:		f.s
	nasm -f elf f.s

clean:
	rm -f *.o

