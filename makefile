CC = gcc
CFLAGS = -Wall -no-pie
LIBS = `pkg-config allegro-5 allegro_font-5 allegro_primitives-5 allegro_ttf-5 allegro_image-5 --libs --cflags`

all:		main.o draw.o
	$(CC) $(CFLAGS) main.o draw.o -o quadratic_d $(LIBS)

main.o:		main.c
	$(CC) $(CFLAGS) -c main.c -o main.o 

draw.o:		draw.s
	nasm -f elf64 draw.s

clean:
	rm -f *.o

