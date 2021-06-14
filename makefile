CC=gcc
CFLAGS= -Wall

all:		main.o
	$(CC) $(CFLAGS) main.o -o fun $(pkg-config allegro-5 allegro_font-5 allegro_primitives-5 allegro_ttf-5 allegro_image-5 --libs --cflags)

main.o:		main.c
	$(CC) $(CFLAGS) -c main.c -o main.o $(pkg-config allegro-5 allegro_font-5 allegro_primitives-5 allegro_ttf-5 allegro_image-5 --libs --cflags)

f.o:		f.s
	nasm -f elf64 f.s

clean:
	rm -f *.o

