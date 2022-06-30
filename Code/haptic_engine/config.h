#ifndef CONFIG_H
#define CONFIG_H

#include "stdint.h"

#define BCM_GPIO_28 28
#define BCM_GPIO_29 29
#define BCM_GPIO_30 30
#define BCM_GPIO_31 31
#define BCM_GPIO_32 32
#define BCM_GPIO_33 33
#define BCM_GPIO_34 34
#define BCM_GPIO_35 35
#define BCM_GPIO_36 36
#define BCM_GPIO_37 37
#define BCM_GPIO_38 38
#define BCM_GPIO_39 39
#define BCM_GPIO_40 40
#define BCM_GPIO_41 41
#define BCM_GPIO_42 42
#define BCM_GPIO_43 43
#define BCM_GPIO_44 44
#define BCM_GPIO_45 45

// PA8-12 UART1
//#define SPI1_NSS_PIN PA4    //SPI_1 Chip Select pin is PA4. //no use in
//DevTerm

#define VH_PIN BCM_GPIO_40 // ENABLE_VH required,PRT_EN

#define PH1_PIN BCM_GPIO_28
#define PH2_PIN BCM_GPIO_29
#define PH3_PIN BCM_GPIO_30
#define PH4_PIN BCM_GPIO_31

/// 0 1 3 2 mine
#define PA_PIN PH1_PIN  //
#define PNA_PIN PH2_PIN //
#define PB_PIN PH3_PIN  //
#define PNB_PIN PH4_PIN //

#define MOTOR_ENABLE1
#define MOTOR_ENABLE2

#define MOTOR_DISABLE1
#define MOTOR_DISABLE2

#define ENABLE_VH digitalWrite(VH_PIN, HIGH)
#define DISABLE_VH digitalWrite(VH_PIN, LOW)
#define READ_VH digitalRead(VH_PIN)

#define ERROR_FEED_PITCH ((uint8_t)0x01)

#define FORWARD 0x01
#define BACKWARD 0x00

#define HOT 64

#define BCoefficent 3950
#define RthNominal 30000
#define TempNominal 25
#define ADCResolution 1024
#define SeriesResistor 30000

#define ADC_FILE_PATH "/tmp/devterm_adc"
#define BAT_CAP "/sys/class/power_supply/axp20x-battery/capacity"
#define BAT_THRESHOLD 14 // %14 battery = low power

#define int16 uint16_t
#define int8 uint8_t

typedef struct _TimeRec {
  unsigned int time;
  uint8_t last_status;
  uint8_t check;

} TimeRec;


#endif
