#include <stdio.h>
#include <stdlib.h>
#include <allegro5/allegro5.h>
#include <allegro5/allegro_font.h>
#include <allegro5/allegro_primitives.h>
#include <allegro5/allegro_image.h>
#include <allegro5/allegro_ttf.h>
#include "f.h"

enum chosenParameter{A, B, C, D, None};



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

    ALLEGRO_DISPLAY *disp = al_create_display(1920, 1080);
    must_init(disp, "display");

    must_init(al_init_font_addon(), "font addon");
    must_init(al_init_ttf_addon(), "ttf addon");
    ALLEGRO_FONT *font = al_load_ttf_font("OpenSans-Regular.ttf", 18, 0);
    must_init(font, "font");

    must_init(al_init_image_addon(), "image addon");
   
    ALLEGRO_BITMAP* currentFunction = al_load_bitmap("output.bmp");
    must_init(currentFunction, "output");

    must_init(al_init_primitives_addon(), "primitives");

    al_register_event_source(queue, al_get_keyboard_event_source());
    al_register_event_source(queue, al_get_display_event_source(disp));
    al_register_event_source(queue, al_get_timer_event_source(timer));

    bool done = false;
    bool redraw = true;
    ALLEGRO_EVENT event;

    float a, b, c, d;
    a = 1;
    b = 2;
    c = 1;
    d = 0.1;

    enum chosenParameter keyPressed = None;
    

    al_start_timer(timer);
    while (1)
    {
        al_wait_for_event(queue, &event);

        switch (event.type)
        {
        // case ALLEGRO_EVENT_TIMER:
        //     // once again, no game logic. fishy? maybe.
        //     redraw = true;
        //     break;

        case ALLEGRO_EVENT_KEY_CHAR:
            redraw = true;
            if (event.keyboard.keycode == ALLEGRO_KEY_A)
                keyPressed = A;
            if (event.keyboard.keycode == ALLEGRO_KEY_B)
                keyPressed = B;
            if (event.keyboard.keycode == ALLEGRO_KEY_C)
                keyPressed = C;
            if (event.keyboard.keycode == ALLEGRO_KEY_D)
                keyPressed = D;
            if (event.keyboard.keycode == ALLEGRO_KEY_ENTER)
                keyPressed = None;
            if (event.keyboard.keycode == ALLEGRO_KEY_UP)
                switch (keyPressed)
                {
                case A:
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
                
                default:
                    break;
                }
            if (event.keyboard.keycode == ALLEGRO_KEY_DOWN)
                switch (keyPressed)
                {
                case A:
                    a -= 0.1;
                    break;
                case B:
                    b -= 0.1;
                    break;
                case C:
                    c -= 0.1;
                    break;
                case D:
                    if (d >= 0.2)
                        d -= 0.1;
                    break;
                
                default:
                    break;
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
            if (keyPressed == None)
            {
                FILE * file;
                file = fopen("out.bmp", "rb");
                if (file == NULL) return 1;
                fseek(file, 0, SEEK_END);
                long int size = ftell(file);
                fclose(file);

                file = fopen("out.bmp", "rb");
                unsigned char * pPixelBuffer = (unsigned char *) malloc(size);
                int bytes_read = fread(pPixelBuffer, sizeof(unsigned char), size, file);
                fclose(file);

                drawQuadratic(pPixelBuffer, 1080, 1920, a, b, c, d);

                file = fopen("output.bmp", "wb");
                int bytes_written = fwrite(pPixelBuffer, sizeof(unsigned char), size, file);
                fclose(file);
                free(pPixelBuffer);
        
                currentFunction = al_load_bitmap("output.bmp");
                must_init(currentFunction, "output");
            }
            al_clear_to_color(al_map_rgb(255, 255, 255));
            
            al_draw_bitmap(currentFunction, 0, 0, 0);
            al_draw_line(0, 540, 1920, 540, al_map_rgb_f(0, 0, 0), 1);
            al_draw_line(960, 0, 960, 1080, al_map_rgb_f(0, 0, 0), 1);
            al_draw_textf(font, al_map_rgb(0, 0, 0), 10, 0, 0, "a = %.1f", a);
            al_draw_textf(font, al_map_rgb(0, 0, 0), 10, 20, 0, "b = %.1f", b);
            al_draw_textf(font, al_map_rgb(0, 0, 0), 10, 40, 0, "c = %.1f", c);
            al_draw_textf(font, al_map_rgb(0, 0, 0), 10, 60, 0, "d = %.1f", d);
            
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