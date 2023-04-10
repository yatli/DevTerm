#include <wiringPi.h>
#include <mcp23008.h>
#include <stdio.h>
#include <stdarg.h>
#include <stdint.h>
#include <unistd.h>
#include <stdbool.h>

#define MCP23008_ADDR 0x20
#define MCP23008_PINBASE 100

// #ifdef CONFIG_CLOCKWORKPI_A06

#define ROUTE_EN 43
#define GPIO_X1 37
#define GPIO_X2 42

// maybe we should have names for these.. like, X1..X8 for internal, Y1..Y8 for external...
#define GPIO28 28
#define GPIO29 29
#define GPIO30 30
#define GPIO31 31
#define GPIO34 34
#define GPIO35 35

#define UART_TX 32
#define UART_RX 33

#define SPI_MOSI 38
#define SPI_SCL 39
#define SPI_CS 40
#define SPI_MISO 41

#define GPIO_Y1 (MCP23008_PINBASE+0)
#define GPIO_Y2 (MCP23008_PINBASE+1)
#define GPIO_Y3 (MCP23008_PINBASE+2)
#define GPIO_Y4 (MCP23008_PINBASE+3)
#define GPIO_Y5 (MCP23008_PINBASE+4)
#define GPIO_Y6 (MCP23008_PINBASE+5)
#define GPIO_Y7 (MCP23008_PINBASE+6)
#define GPIO_Y8 (MCP23008_PINBASE+7)


void die(const char* msg, ...) {
  va_list argp;
  va_start(argp, msg);
  wiringPiFailure(1, msg, argp);
  va_end(argp);
}

void resetPins() {
  pinMode(ROUTE_EN, INPUT);
  pinMode(GPIO_X1, INPUT);
  pinMode(GPIO_X2, INPUT);
  pinMode(GPIO28, INPUT);
  pinMode(GPIO29, INPUT);
  pinMode(GPIO30, INPUT);
  pinMode(GPIO31, INPUT);
  pinMode(GPIO34, INPUT);
  pinMode(GPIO35, INPUT);
  pinMode(UART_TX, INPUT);
  pinMode(UART_RX, INPUT);
  pinMode(SPI_MOSI, INPUT);
  pinMode(SPI_SCL, INPUT);
  pinMode(SPI_CS, INPUT);
  pinMode(SPI_MISO, INPUT);
  pinMode(GPIO_Y1, INPUT);
  pinMode(GPIO_Y2, INPUT);
  pinMode(GPIO_Y3, INPUT);
  pinMode(GPIO_Y4, INPUT);
  pinMode(GPIO_Y5, INPUT);
  pinMode(GPIO_Y6, INPUT);
  pinMode(GPIO_Y7, INPUT);
  pinMode(GPIO_Y8, INPUT);
}

void setup() {
  if (0 != wiringPiSetupGpio()) {
    die("Failed to setup wiringpi\n");
  }
  if (1 != mcp23008Setup(MCP23008_PINBASE, MCP23008_ADDR)) {
    die("Failed to setup mcp23008\n");
  }
}

// TODO implement wfi for wiringCPi
void waitForPin(int pin, int desired) {
  do{
    if (desired == digitalRead(pin)) {
      break;
    }
    sleep(1);
  }while(1);
}

uint32_t shift_in_cartid()
{
	int i, j;
	uint32_t cartid = 0U;
  uint8_t byte;
	
  for (i = 0; i < 4; ++i) {
    byte = 0;
    cartid >>= 8;
    digitalWrite(GPIO_X1, HIGH);
    for (j = 0; j < 8; ++j)
    {
      usleep(100U);
      digitalWrite(GPIO_X1, LOW);
      usleep(100U);
      byte >>= 1;
      byte |= (digitalRead(GPIO_X2) << 7);
      digitalWrite(GPIO_X1, HIGH);
    }
    cartid = cartid | (byte << 24);
    // byte == 0: all bits are drained from 74HC165
    // byte == ff: GPIO_X2 is floating...
    if (byte == 0 || byte == 0xff) break;
  }
  printf("the cart reported %d bytes\n", i);
  for(; i < 4; ++i) {
    cartid >>= 8;
  }
	return cartid;
}

void loop() {
  int32_t cartid;

  printf("Resetting pins to INPUT state.\n");
  resetPins();
  printf("Waiting for cart.\n");
  waitForPin(ROUTE_EN, LOW);
  printf("Cart inserted!\n");
  
  pinMode(ROUTE_EN, OUTPUT);
  pinMode(GPIO_X1, OUTPUT);
  pinMode(GPIO_X2, INPUT);
  digitalWrite(ROUTE_EN, HIGH); // load the data
  cartid = shift_in_cartid();
  digitalWrite(ROUTE_EN, LOW);
  pinMode(ROUTE_EN, INPUT);

  printf("Cart id = %08X\n", cartid);

  waitForPin(ROUTE_EN, HIGH);
  printf("Cart removed!\n");
}

void debug() {
  pinMode(ROUTE_EN, OUTPUT);
  digitalWrite(ROUTE_EN, HIGH);
  pinMode(GPIO_X1, OUTPUT);
  pinMode(GPIO_X2, OUTPUT);
  digitalWrite(GPIO_X1, LOW);
  digitalWrite(GPIO_X2, LOW);
  digitalWrite(ROUTE_EN, LOW);

  pinMode(GPIO_X1, INPUT);
  pinMode(GPIO_X2, INPUT);
  while(true) {
    digitalWrite(ROUTE_EN, LOW);
    sleep(1);
    digitalWrite(ROUTE_EN, LOW);
    sleep(1);
  }
}

int main() {
  setup();
  printf("ExtCart daemon started.\n");
  /*debug();*/
  while(1) {
    loop();
  }
}
