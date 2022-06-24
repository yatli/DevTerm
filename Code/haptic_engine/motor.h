#ifndef MOTOR_H
#define MOTOR_H

#include "config.h"
#include "portmidi.h"
#include "pmutil.h"

extern void init_motor_synth(PmQueue* queue);
extern void stop_motor_synth();

// vel is len
extern void motor_note_on(int note, int vel);
extern void motor_note_off();
extern void motor_cc(int cc, int val);
extern void poll_midi();

#endif
