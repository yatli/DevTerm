#include <math.h>
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include <wiringPi.h>
#include <wiringPiSPI.h>
#include <pthread.h>

#include "config.h"
#include "utils.h"
#include "motor.h"

static int motor_synth_terminate = 0;
static PmQueue* pm_queue;

static int batt_low = 0;
static TimeRec battery_chk_tm;

static int temp_hot = 0;
static int temp_check_time = 0;

static int motor_active = 0;
static int motor_note;
static int motor_vel;

static uint8_t haptic_forward_backward = 1;
static unsigned int haptic_time_prev_ms;

static uint16_t pitch_table[] = { 
  6300, 6100, 5650, 5350, 4900, 4550, 4250, 3950, 3670, 3370, 3070, 2770, 
  2540, 2370, 2200, 2030, 1830, 1630, 1420, 1310, 1190, 1080, 970,  860,
  710};

static float acc_time_idx;
static float acc_time_spd;
static uint16_t acc_time[] = {5459,3459,2762,2314,2028,1828,1675,1553,1456,1374,1302,1242,1191,1144,1103,1065,1031,1000,970,940,910,880,880};

#define ACCMAX 23

// {{{ batt
static void print_lowpower() {
  int i;
  char *msg = "Low Power,please charge";

  PRINTF("%s\n", msg);
}

static int read_batt_cap() {
  long ret;
  char c[12];
  FILE *fptr;
  if ((fptr = fopen(BAT_CAP, "r")) == NULL) {
    return -1;
  }

  fscanf(fptr, "%[^\n]", c);
  // printf("Data from the file:%s\n", c);
  fclose(fptr);

  ret = strtol(c, NULL, 10);

  return (int)ret;
}

static int batt_checker() {
  int bat_cap = 0;
  if (millis() - battery_chk_tm.time > 200) {
    bat_cap = read_batt_cap();
    if (bat_cap < 0) {
      batt_low = 1;
    } else if (bat_cap >= 0 && bat_cap <= BAT_THRESHOLD) {
      batt_low = 1;
    } else {
      batt_low = 0;
    }
    battery_chk_tm.time = millis();
  }
  return 0;
}

static void init_batt_checker() {
  battery_chk_tm.time = millis();
  battery_chk_tm.last_status = 0;
  battery_chk_tm.check = 0;
}

// }}}

static uint16_t read_adc(char *adc_file) {
  long ret;
  char c[16];
  FILE *fptr;
  if ((fptr = fopen(adc_file, "r")) == NULL) {
    printf("Error! ADC File cannot be opened\n");
    // Program exits if the file pointer returns NULL.
    return 0;
  }
  fscanf(fptr, "%[^\n]", c);
  // printf("Data from the file:\n%s", c);
  fclose(fptr);

  ret = strtol(c, NULL, 10);
  // printf("the number ret %d\n",ret);

  return (uint16_t)ret;
}

static double temperature() {

  double Rthermistor = 0, TempThermistor = 0;
  uint16_t ADCSamples = 0;
  int Sample = 1;
  double ADCConvertedValue;
  int NumSamples = 1;

  while (Sample <= NumSamples) {
    ADCSamples += read_adc(ADC_FILE_PATH);
    Sample++;
  }
  // Thermistor Resistance at x Kelvin
  ADCConvertedValue = (double)ADCSamples / NumSamples;
  Rthermistor = ((double)ADCResolution / ADCConvertedValue) - 1;
  Rthermistor = (double)SeriesResistor / Rthermistor;
  // Thermistor temperature in Kelvin
  TempThermistor = Rthermistor / RthNominal;
  TempThermistor = log(TempThermistor);
  TempThermistor /= BCoefficent;
  TempThermistor += (1 / (TempNominal + 273.15));
  TempThermistor = 1 / TempThermistor;

  return (TempThermistor - 273.15);
}

static void temp_checker() {
  int t = millis();
  if (t - temp_check_time > 1000) {
    // WARNING: temperature not working
    double temp = temperature();
    /*printf("%lf\n", temp);*/
    temp_check_time = t;
  }
}

uint8_t current_pos = 1;

void motor_delay_us(long T) {
  uint32_t T0 = micros();
  uint32_t T1 = micros();
  while (T1 - T0 < T) {
    poll_midi();
    delayMicroseconds(T / 4);
    T1 = micros();
  }
}

void motor_stepper_pos2(uint8_t position) // forward
{
  if(haptic_time_prev_ms == 0) {
    if (acc_time_spd > 0) {
      acc_time_idx = 0;
    } else if (acc_time_spd < 0) {
      acc_time_idx = ACCMAX - 1;
    }
  } else {
    acc_time_idx += acc_time_spd;
    if (acc_time_spd >= 0) {
      if(acc_time_idx > ACCMAX-1) {
        acc_time_idx = ACCMAX-1;
      }
    } else {
      if(acc_time_idx < 0 ) {
        acc_time_idx = 0;
      }
    }
  }

  int note = motor_note - 36; // start from C3
  if (note < 0) {
    note = 0;
  }
  if (note >= sizeof(pitch_table) / sizeof(pitch_table[0])) {
    note = sizeof(pitch_table) / sizeof(pitch_table[0]) - 1;
  }

  double T = pitch_table[note];
  if (acc_time_spd != 0) {
    T += acc_time[(int)acc_time_idx];
  }

  haptic_time_prev_ms = millis();

  /*motor_delay_us(T);*/
  delayMicroseconds(T);
  position = position % 6;
  if (batt_low) {
    position = 0;
  }
  /*printf("pos %d \n", position);*/
  switch (position) {
  case 0:
    digitalWrite(PA_PIN, LOW);
    digitalWrite(PNA_PIN, LOW);
    digitalWrite(PB_PIN, LOW);
    digitalWrite(PNB_PIN, LOW);
    break;
  case 1:
    digitalWrite(PA_PIN, HIGH);
    digitalWrite(PNA_PIN, LOW);
    digitalWrite(PB_PIN, LOW);
    digitalWrite(PNB_PIN, HIGH);
    break;
  case 2:
    digitalWrite(PA_PIN, HIGH);
    digitalWrite(PNA_PIN, LOW);
    digitalWrite(PB_PIN, HIGH);
    digitalWrite(PNB_PIN, LOW);
    break;
  case 3:
    digitalWrite(PA_PIN, LOW);
    digitalWrite(PNA_PIN, HIGH);
    digitalWrite(PB_PIN, HIGH);
    digitalWrite(PNB_PIN, LOW);
    break;
  case 4:
    digitalWrite(PA_PIN, LOW);
    digitalWrite(PNA_PIN, HIGH);
    digitalWrite(PB_PIN, LOW);
    digitalWrite(PNB_PIN, HIGH);
    break;
  }
}

uint8_t haptic_engine() {
  uint8_t pos = current_pos;
  uint8_t restor = ~haptic_forward_backward;

  restor &= 0x01;

  motor_stepper_pos2(pos); /* 0.0625mm */

  if (pos >= 1 && pos <= 4)
    pos = pos + (1 - 2 * haptic_forward_backward); // adding or subtracting
  if (pos < 1 || pos > 4)
    pos = pos + (4 - 8 * restor); // restoring pos

  current_pos = pos;
  --motor_active;
  return 0;
}

void poll_midi() {
  int32_t message;
  if (1 != Pm_Dequeue(pm_queue, &message)) {
    return;
  }
  int status = Pm_MessageStatus(message);
  int data1 = Pm_MessageData1(message);
  int data2 = Pm_MessageData2(message);
  if ((status & 0xf0) == 0xf0) { // ignore system messages
    ;
  } else if ((status & 0xf0) == 0x90) { // note on
    motor_note_on(data1, data2);
  } else if ((status & 0xf0) == 0x80) { // note off
    motor_note_off();
  } else if ((status & 0xf0) == 0xa0) {
    printf("%02x\n", status);
  } else if ((status & 0xf0) == 0xb0) { // cc
    motor_cc(data1, data2);
  } else if ((status & 0xf0) == 0xc0) {
    printf("%02x\n", status);
  } else if ((status & 0xf0) == 0xd0) {
  }
}


PI_THREAD(motor_synth_proc) {
  while (!motor_synth_terminate) {
    batt_checker();
    temp_checker();
    poll_midi();


    if (!batt_low && motor_active) {
      ENABLE_VH;
    } else {
      DISABLE_VH;
    }
    if (motor_active) {
      haptic_engine();
    }
    delay(1);
  }
  return NULL;
}

void init_motor_synth(PmQueue* queue) {
  pm_queue = queue;
  pinMode(VH_PIN, OUTPUT);
  digitalWrite(VH_PIN, LOW);

  pinMode(PA_PIN, OUTPUT);
  pinMode(PNA_PIN, OUTPUT);
  pinMode(PB_PIN, OUTPUT);
  pinMode(PNB_PIN, OUTPUT);

  haptic_time_prev_ms = 0;
  acc_time_idx  = 0;
  acc_time_spd = 0;

  init_batt_checker();
  piThreadCreate(motor_synth_proc);
}

void stop_motor_synth() {
  motor_synth_terminate = 1;
  DISABLE_VH;
  delay(1);
}

void motor_note_on(int note, int vel) {
  motor_active = vel;
  motor_note = note;
  haptic_time_prev_ms = 0;
}

void motor_note_off() {
  // motor_active = 0;
}

void motor_cc(int cc, int val) {
  if (cc == 32) {
    acc_time_spd = ((float)val) / 127.0f - 0.5f;
    if (fabs(acc_time_spd) < 0.005) {
      acc_time_spd = 0;
    }
  } else if (cc == 33) {
    haptic_forward_backward = val;
  }
}
