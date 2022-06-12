#ifndef __LOW_POWER_H
#define __LOW_POWER_H

#include <libmaple/pwr.h>
#include <libmaple/scb.h>


void low_power_init(DEVTERM* _dt);
void low_power_enter_sleep();
#endif /* __LOW_POWER_H */
