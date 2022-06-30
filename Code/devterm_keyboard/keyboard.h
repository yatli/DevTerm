#ifndef KEYBOARD_H
#define KEYBOARD_H

/*
 * clockworkpi devterm keyboard test2 
 * able to correct scan the 8x8 keypads re-action
 */

#include "devterm.h"

#include "keys_io_map.h"

#include <stdint.h>
#include <stdbool.h>
#include <string.h>

#define MATRIX_ROWS 8
#define MATRIX_COLS 8

#define MATRIX_KEYS 64 // 8*8

#ifndef DEBOUNCE
#   define DEBOUNCE 20
#endif

void init_rows();
void init_cols();
uint8_t read_io(uint8_t io);

void matrix_init();
uint8_t matrix_scan(void);

bool matrix_is_on(uint8_t row, uint8_t col);
uint8_t matrix_get_row(uint8_t row) ;


//void matrix_print(void);



bool keyboard_task(DEVTERM*);
void keyboard_init(DEVTERM*);


#define KEY_PRESSED 1
#define KEY_RELEASED 0

#define KEY_PRNT_SCRN 0xCE //Print screen - 0x88 == usb hut1_12v2.pdf keyboard code
#define KEY_PAUSE  0xd0 // - 0x88 == usb hut1_12v2.pdf keyboard code

#define KEY_VOLUME_UP 0x108  // - 0x88 == usb hut1_12v2.pdf keyboard code
#define KEY_VOLUME_DOWN 0x109 //  - 0x88 == usb hut1_12v2.pdf keyboard code

inline void debug_led(bool on) {
    digitalWrite(PC13, !on);
}

// Joystick button mapping
enum JS_BUTTON {
    JS_BUTTON_X   = 1,
    JS_BUTTON_Y   = 4,
    JS_BUTTON_A   = 2,
    JS_BUTTON_B   = 3,
    JS_BUTTON_SEL = 9,
    JS_BUTTON_STA = 10,

    // special mouse overlays
    JS_BUTTON_JML1 = 23,
    JS_BUTTON_JML2 = 24,

    JS_BUTTON_JML1_B = 25,
    JS_BUTTON_JML1_A = 26,
    JS_BUTTON_JML1_Y = 27,
    JS_BUTTON_JML1_X = 28,

    JS_BUTTON_JML2_B = 29,
    JS_BUTTON_JML2_A = 30,
    JS_BUTTON_JML2_Y = 31,
    JS_BUTTON_JML2_X = 32,
};

#endif
