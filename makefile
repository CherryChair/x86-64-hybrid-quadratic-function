CC = gcc
CFLAGS = -Wall -no-pie
LIBS = `pkg-config allegro-5 allegro_font-5 allegro_primitives-5 allegro_ttf-5 allegro_image-5 --libs --cflags`

all:		main.o f.o
	$(CC) $(CFLAGS) main.o f.o -o quadratic $(LIBS)

main.o:		main.c
	$(CC) $(CFLAGS) -c main.c -o main.o 

f.o:		f.s
	nasm -f elf64 f.s

clean:
	rm -f *.o

