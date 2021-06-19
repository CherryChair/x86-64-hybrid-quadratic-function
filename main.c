#include <stdio.h>
#include <stdlib.h>
#include <allegro5/allegro5.h>
#include <allegro5/allegro_font.h>
#include <allegro5/allegro_primitives.h>
#include <allegro5/allegro_image.h>
#include <allegro5/allegro_ttf.h>
#include "f.h"

enum chosenParameter{A, B, C, D, Z, Enter};



void must_init(bool test, const char *description)
{
    if (test)
        return;

    printf("couldn't initialize %s\n", description);
    exit(1);
}

int main()
{
    must_init(al_init(), "allegro");
    must_init(al_install_keyboard(), "keyboard");

    ALLEGRO_TIMER *timer = al_create_timer(1.0 / 30.0);
    must_init(timer, "timer");

    ALLEGRO_EVENT_QUEUE *queue = al_create_event_queue();
    must_init(queue, "queue");

    al_set_new_display_option(ALLEGRO_SAMPLE_BUFFERS, 1, ALLEGRO_SUGGEST);
    al_set_new_display_option(ALLEGRO_SAMPLES, 8, ALLEGRO_SUGGEST);
    al_set_new_bitmap_flags(ALLEGRO_MIN_LINEAR | ALLEGRO_MAG_LINEAR);

    int height;
    int width;
    FILE * f;
    f = fopen("in.bmp", "rb");
    if (f == NULL) return 1;
    for (int i=0; i<18; i++){
        fgetc(f);
    }
    fread(&width, 4, 1, f);
    fread(&height, 4, 1, f);
    
    fclose(f);
    int widthPadding = width;
    if (widthPadding % 32 != 0)
        widthPadding += 32-widthPadding%32;
    ALLEGRO_DISPLAY *disp = al_create_display(width, height);
    must_init(disp, "display");

    must_init(al_init_font_addon(), "font addon");
    must_init(al_init_ttf_addon(), "ttf addon");
    ALLEGRO_FONT *font = al_load_ttf_font("OpenSans-Regular.ttf", 18, 0);
    must_init(font, "font");

    must_init(al_init_image_addon(), "image addon");
   
    ALLEGRO_BITMAP* currentFunction = al_load_bitmap("in.bmp");
    must_init(currentFunction, "input bmp");

    must_init(al_init_primitives_addon(), "primitives");

    al_register_event_source(queue, al_get_keyboard_event_source());
    al_register_event_source(queue, al_get_display_event_source(disp));
    al_register_event_source(queue, al_get_timer_event_source(timer));

    bool done = false;
    bool redraw = true;
    ALLEGRO_EVENT event;

    double a, b, c, d, Scale;
    a = 1;
    b = 2;
    c = 1;
    d = 1;
    Scale = 10;

    enum chosenParameter keyPressed = Enter;
    

    al_start_timer(timer);
    while (1)
    {
        al_wait_for_event(queue, &event);

        switch (event.type)
        {
        case ALLEGRO_EVENT_KEY_CHAR:
            redraw = true;
            if (event.keyboard.keycode == ALLEGRO_KEY_A)
                keyPressed = A;
            else if (event.keyboard.keycode == ALLEGRO_KEY_B)
                keyPressed = B;
            else if (event.keyboard.keycode == ALLEGRO_KEY_C)
                keyPressed = C;
            else if (event.keyboard.keycode == ALLEGRO_KEY_D)
                keyPressed = D;
            else if (event.keyboard.keycode == ALLEGRO_KEY_Z)
                keyPressed = Z;
            else if (event.keyboard.keycode == ALLEGRO_KEY_ENTER)
                keyPressed = Enter;
            else if (event.keyboard.keycode == ALLEGRO_KEY_UP)
                switch (keyPressed)
                {
                case A:
                    a += 0.1;
                    if (a > -0.05 && a < 0.05)
                        a += 0.1;
                    break;
                case B:
                    b += 0.1;
                    break;
                case C:
                    c += 0.1;
                    break;
                case D:
                    d += 0.1;
                    break;
                case Z:
                    Scale += 0.1;
                    break;
                
                default:
                    break;
                }
            else if (event.keyboard.keycode == ALLEGRO_KEY_DOWN)
                switch (keyPressed)
                {
                case A:
                    a -= 0.1;
                    if (a > -0.05 && a < 0.05)
                        a -= 0.1;
                    break;
                case B:
                    b -= 0.1;
                    break;
                case C:
                    c -= 0.1;
                    break;
                case D:
                    d -= 0.1;
                    if (d < 0.5)
                        d = 0.5;
                    break;
                case Z:
                    Scale -= 0.1;
                    if (Scale < 2)
                        Scale = 2;
                    break;
                
                default:
                    break;
                }
            else if (event.keyboard.keycode == ALLEGRO_KEY_RIGHT)
                switch (keyPressed)
                {
                case A:
                    a += 1;
                    if (a > -0.05 && a < 0.05)
                        a += 0.1;
                    break;
                case B:
                    b += 1;
                    break;
                case C:
                    c += 1;
                    break;
                case D:
                    d += 1;
                    break;
                case Z:
                    Scale += 1;
                    break;
                
                default:
                    break;
                }
            else if (event.keyboard.keycode == ALLEGRO_KEY_LEFT)
                switch (keyPressed)
                {
                case A:
                    a -= 1;
                    if (a > -0.05 && a < 0.05)
                        a -= 0.1;
                    break;
                case B:
                    b -= 1;
                    break;
                case C:
                    c -= 1;
                    break;
                case D:
                    d -= 1;
                    if (d < 0.5)
                        d = 0.5;
                    break;
                case Z:
                    Scale -= 1;
                    if (Scale < 2)
                        Scale = 2;
                    break;
                
                default:
                    break;
                }
            else
            {
                redraw = false;
            }
            if (event.keyboard.keycode != ALLEGRO_KEY_ESCAPE)
                break;
        

        case ALLEGRO_EVENT_DISPLAY_CLOSE:
            done = true;
            break;
        }

        if (done)
            break;

        if (redraw && al_is_event_queue_empty(queue))
        {
            FILE * file;
            file = fopen("in.bmp", "rb");
            if (file == NULL) return 1;
            fseek(file, 0, SEEK_END);
            long int size = ftell(file);  
            fclose(file);

            file = fopen("in.bmp", "rb");
            unsigned char * pPixelBuffer = (unsigned char *) malloc(size);
            fread(pPixelBuffer, sizeof(unsigned char), size, file);
            fclose(file);

            drawQuadratic(pPixelBuffer, widthPadding, height, a, b, c, d, Scale);

            file = fopen("output.bmp", "wb");
            fwrite(pPixelBuffer, sizeof(unsigned char), size, file);
            fclose(file);
            free(pPixelBuffer);
    
            currentFunction = al_load_bitmap("output.bmp");
            must_init(currentFunction, "output bmp");

            al_clear_to_color(al_map_rgb(255, 255, 255));
            
            al_draw_bitmap(currentFunction, 0, 0, 0);
            al_draw_line(0, height/2, width, height/2, al_map_rgb_f(0, 0, 0), 1);
            al_draw_line(width/2, 0, width/2, height, al_map_rgb_f(0, 0, 0), 1);
            int i = 0;
            while (i<width/2)
            {
                i += (int) 10 * Scale;
                al_draw_line(i+width/2, height/2-4, i+width/2, height/2+4, al_map_rgb_f(0, 0, 0), 1); 
                al_draw_line(width/2-i, height/2-4, width/2-i, height/2+4, al_map_rgb_f(0, 0, 0), 1); 
            }
            i = 0;
            while (i < height/2)
            {
                i += (int) 10 * Scale;
                al_draw_line(width/2-4, i+height/2, width/2+4, i+height/2, al_map_rgb_f(0, 0, 0), 1);
                al_draw_line(width/2-4, height/2-i, width/2+4, height/2-i, al_map_rgb_f(0, 0, 0), 1);
            }
            
            
            al_draw_textf(font, al_map_rgb(0, 0, 0), width/2+10*Scale, height/2-27, ALLEGRO_ALIGN_CENTER, "10");
            al_draw_textf(font, al_map_rgb(0, 0, 0), width/2+5, height/2-10*Scale-14, ALLEGRO_ALIGN_LEFT, "10");
            al_draw_textf(font, al_map_rgb(0, 0, 0), 10, 0, 0, "a = %.1f", a);
            al_draw_textf(font, al_map_rgb(0, 0, 0), 10, 20, 0, "b = %.1f", b);
            al_draw_textf(font, al_map_rgb(0, 0, 0), 10, 40, 0, "c = %.1f", c);
            al_draw_textf(font, al_map_rgb(0, 0, 0), 10, 60, 0, "d = %.1f", d);
            al_draw_textf(font, al_map_rgb(0, 0, 0), width - 5, 0, ALLEGRO_ALIGN_RIGHT, "Zoom = %.1f", Scale);
            
            switch (keyPressed)
            {
            case A:
                al_draw_textf(font, al_map_rgb(255, 0, 0), 10, 0, 0, "a = %.1f", a);
                break;
            case B:
                al_draw_textf(font, al_map_rgb(255, 0, 0), 10, 20, 0, "b = %.1f", b);
                break;
            case C:
                al_draw_textf(font, al_map_rgb(255, 0, 0), 10, 40, 0, "c = %.1f", c);
                break;
            case D:
                al_draw_textf(font, al_map_rgb(255, 0, 0), 10, 60, 0, "d = %.1f", d);
                break;
            case Z:
                al_draw_textf(font, al_map_rgb(255, 0, 0), width - 5, 0, ALLEGRO_ALIGN_RIGHT, "Zoom = %.1f", Scale);
                break;
            default:
                break;
            }
            al_flip_display();

            redraw = false;
        }
    }
    al_destroy_bitmap(currentFunction);
    al_destroy_font(font);
    al_destroy_display(disp);
    al_destroy_timer(timer);
    al_destroy_event_queue(queue);

    return 0;
}