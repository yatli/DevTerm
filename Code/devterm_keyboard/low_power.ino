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
  pinMode(PA11, INPUT_FLOATING);
  pinMode(PA12, INPUT_FLOATING);
  pinMode(PA13, INPUT_FLOATING);
  pinMode(PA14, INPUT_FLOATING);
  pinMode(PA15, INPUT_FLOATING);

  digitalWrite(PC13, HIGH);

  // TODO:
  //  wakeup sources:
  //  ROW1-ROW8   = PA0-PA7   : matrix input lines
  //  KEY1-KEY16  = PB0-PB15  : keypad
  //  KEY0        = PC12      : trackball pushbutton
  //  HO1-HO4     = PC8-PC11  : already handled by trackball interrupts

  // attachInterrupt(ROW1, &__lowpower_isr, ExtIntTriggerMode::CHANGE); // doesn't trigger
  // attachInterrupt(ROW2, &__lowpower_isr, ExtIntTriggerMode::CHANGE); // doesn't trigger
  // attachInterrupt(ROW3, &__lowpower_isr, ExtIntTriggerMode::CHANGE); // doesn't trigger
  // attachInterrupt(ROW4, &__lowpower_isr, ExtIntTriggerMode::CHANGE); // doesn't trigger
  // attachInterrupt(ROW5, &__lowpower_isr, ExtIntTriggerMode::CHANGE); // doesn't trigger
  // attachInterrupt(ROW6, &__lowpower_isr, ExtIntTriggerMode::CHANGE); // doesn't trigger
  // attachInterrupt(ROW7, &__lowpower_isr, ExtIntTriggerMode::CHANGE); // doesn't trigger
  // attachInterrupt(ROW8, &__lowpower_isr, ExtIntTriggerMode::CHANGE); // doesn't trigger

  // attachInterrupt(KEY0, &__lowpower_isr, ExtIntTriggerMode::CHANGE); // doesn't trigger
  // attachInterrupt(KEY1, &__lowpower_isr, ExtIntTriggerMode::CHANGE);
  // attachInterrupt(KEY2, &__lowpower_isr, ExtIntTriggerMode::CHANGE);
  // attachInterrupt(KEY3, &__lowpower_isr, ExtIntTriggerMode::CHANGE);
  // attachInterrupt(KEY4, &__lowpower_isr, ExtIntTriggerMode::CHANGE);
  // attachInterrupt(KEY5, &__lowpower_isr, ExtIntTriggerMode::CHANGE);
  // attachInterrupt(KEY6, &__lowpower_isr, ExtIntTriggerMode::CHANGE);
  // attachInterrupt(KEY7, &__lowpower_isr, ExtIntTriggerMode::CHANGE);
  // attachInterrupt(KEY8, &__lowpower_isr, ExtIntTriggerMode::CHANGE);
  // attachInterrupt(KEY9, &__lowpower_isr, ExtIntTriggerMode::CHANGE);
  // attachInterrupt(KEY10, &__lowpower_isr, ExtIntTriggerMode::CHANGE);
  // attachInterrupt(KEY11, &__lowpower_isr, ExtIntTriggerMode::CHANGE);
  // attachInterrupt(KEY12, &__lowpower_isr, ExtIntTriggerMode::CHANGE);
  // attachInterrupt(KEY13, &__lowpower_isr, ExtIntTriggerMode::CHANGE);
  // attachInterrupt(KEY14, &__lowpower_isr, ExtIntTriggerMode::CHANGE);
  // attachInterrupt(KEY15, &__lowpower_isr, ExtIntTriggerMode::CHANGE);
  // attachInterrupt(KEY16, &__lowpower_isr, ExtIntTriggerMode::CHANGE);
}

// see 10.2 EXTI
void low_power_enter_sleep() {
  systick_disable();
  digitalWrite(PC13, LOW);
  asm("wfi");
  digitalWrite(PC13, HIGH);
  systick_enable();
}