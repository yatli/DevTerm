#include "keyboard.h"
#include "keys.h"
#include "trackball.h"
#include "devterm.h"
#include "tickwaiter.h"

#include <USBComposite.h>
#include "low_power.h"

#define SER_NUM_STR "20210531"

USBHID HID;
DEVTERM dev_term;

const uint8_t reportDescription[] = { 
   HID_CONSUMER_REPORT_DESCRIPTOR(),
   HID_KEYBOARD_REPORT_DESCRIPTOR(),
   HID_JOYSTICK_REPORT_DESCRIPTOR(),
   HID_MOUSE_2WHEEL_REPORT_DESCRIPTOR()
};

static const uint32_t LOOP_INTERVAL_MS = 0;
static TickWaiter<LOOP_INTERVAL_MS> waiter;

uint8_t check_pd2(){ // if swtich 2 in back is set to on(HIGH)
  return digitalRead(PD2);
}

void setup() {

  USBComposite.setManufacturerString("ClockworkPI");
  USBComposite.setProductString("DevTerm");
  USBComposite.setSerialString(SER_NUM_STR);

  dev_term.Keyboard = new HIDKeyboard(HID);
  dev_term.Joystick = new HIDJoystick(HID);
  dev_term.Mouse    = new HIDMouse(HID);
  dev_term.Consumer = new HIDConsumer(HID);

  dev_term.Keyboard->setAdjustForHostCapsLock(false);

  dev_term.state = new State(&dev_term);

  dev_term.Keyboard_state.layer = 0;
  dev_term.Keyboard_state.prev_layer = 0;
  dev_term.Keyboard_state.fn_on = 0;
  dev_term.Keyboard_state.shift = 0;
  
  dev_term._Serial = new  USBCompositeSerial;
  
  HID.begin(*dev_term._Serial,reportDescription, sizeof(reportDescription));

  while(!USBComposite);//wait until usb port been plugged in to PC
  

  keyboard_init(&dev_term);
  keys_init(&dev_term);
  trackball_init(&dev_term);
  
  dev_term._Serial->println("setup done");

  pinMode(PD2,INPUT);// switch 2 in back 
  if (check_pd2() == HIGH) {
    // backward compat
    dev_term.state->setJoystickMode(JoystickMode::Keyboard);
  }
  
  delay(1000);
  // note, don't initialize low-power mode before delay(1000) -- it is that one gives you a chance to re-program the device
  low_power_init(&dev_term);
}

int inactive_cnt = 0;
int sleep_cnt = 0;

void loop() {
  dev_term.delta = waiter.waitForNextTick();
  dev_term.state->tick(dev_term.delta);

  bool active = false;
  
  active = active || trackball_task(&dev_term);
  active = active || keys_task(&dev_term); //keys above keyboard
  active = active || keyboard_task(&dev_term);

  if (!active) {
    low_power_enter_sleep();
  }
}
