#include "Arduino.h"
#include "low_power.h"
#include "keys_io_map.h"
#include "keyboard.h"
#include <libmaple/usart.h>

static DEVTERM* dt;

void __lowpower_isr() {
}

// see 5.4.1 PWR_CR
void low_power_init(DEVTERM* _dt) {
  dt = _dt;
  // Clear PDDS and LPDS bits
  PWR_BASE->CR &= ~(PWR_CR_LPDS | PWR_CR_PDDS | PWR_CR_CWUF);
  SCB_BASE->SCR &= ~SCB_SCR_SLEEPDEEP;

  adc_disable_all();
  timer_disable_all();
  usart_disable_all();
  pinMode(PA8, INPUT_FLOATING);
  pinMode(PA9, INPUT_FLOATING);
  pinMode(PA10, INPUT_FLOATING);
  // pinMode(PA11, INPUT_FLOATING);
  // pinMode(PA12, INPUT_FLOATING);
  pinMode(PA13, INPUT_FLOATING);
  pinMode(PA14, INPUT_FLOATING);
  pinMode(PA15, INPUT_FLOATING);
}

// see 10.2 EXTI
void low_power_enter_sleep() {
  systick_disable();
  digitalWrite(PC13, LOW);
  asm("wfi");
  digitalWrite(PC13, HIGH);
  systick_enable();
}