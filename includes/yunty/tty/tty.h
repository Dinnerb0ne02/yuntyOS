#ifndef __YUNTY_TTY_H
#define __YUNTY_TTY_H

typedef unsigned short vga_attributes;



#define VGA_COLOR_BLACK 0
#define VGA_COLOR_BlUE 1
#define VGA_COLOR_GREEN 2
#define VGA_COLOR_CYAN 3
#define VGA_COLOR_RED 4
#define VGA_COLOR_MAGENTA 5
#define VGA_COLOR_BROWN 6
#define VGA_COLOR_LIGHT_GREY 7
#define VGA_COLOR_DARK_GREY 8
#define VGA_COLOR_LIGHT_BlUE 9
#define VGA_COLOR_LIGHT_GREEN 10
#define VGA_COLOR_LIGHT_CYAN 11
#define VGA_COLOR_LIGHT_RED 12
#define VGA_COLOR_LIGHT_MAGENTA 13
#define VGA_COLOR_LIGHT_BROWN 14
#define VGA_COLOR_WHITE 15

#define TTY_WIDTH 80
#define TTY_HEIGHT 25

void tty_set_theme(vga_attributes fg, vga_attributes bg);
void tty_put_char(char chr);
void tty_put_str(char* str);
void tty_scroll_up();
void tty_clear();

#endif