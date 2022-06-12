#include <cassert>
#include <algorithm>
#include <limits>

#include "devterm.h"
#include "state.h"
#include "keyboard.h"
#include "low_power.h"

static int SLEEPTICK_MAX = 2000;

extern USBHID HID;

State::State(DEVTERM* dt)
  : dv(dt),
    fn(false),
    middleClick(false),
    scrolled(false),
    joystickMode(JoystickMode::Mouse),
    selectorMode(SelectorMode::Joystick),
    powerSaveMode(PowerSaveMode::On),
    currentGear(2), // gear 3
    jm_tick(0),
    sleep_tick(0),
    usb_active(true),
    usb_resuming(false),
    usb_resume_tick(0),
    pending_actions()
{
  std::fill(js_keys, js_keys + JS_KEY_MAX, false);
  sleep_tick = 0;
}

void State::tick(millis_t delta)
{
  middleClickTimeout.updateTime(delta);
}
void State::setScrolled() {
  if(middleClick==true){
    scrolled = true;
  }
}

bool State::getScrolled() {
  return scrolled;
}

void State::pressMiddleClick() {
  middleClick = true;
  middleClickTimeout.reset();
}

bool State::releaseMiddleClick() {
  middleClick = false;
  scrolled = false;
  const auto timeout = middleClickTimeout.get();
  return !timeout;
}

TrackballMode State::moveTrackball() {
  middleClickTimeout.expire();
  if (middleClick) {
    return TrackballMode::Wheel;
  } else {
    return TrackballMode::Mouse;
  }
}

JoystickMode State::getJoystickMode() {
  return joystickMode;
}

void State::setJoystickMode(JoystickMode m) {
  joystickMode = m;
}

PowerSaveMode State::getPowerSaveMode() {
  return powerSaveMode;
}

void State::setPowerSaveMode(PowerSaveMode m) {
  powerSaveMode = m;
}


template<typename T>
T _ringadd(T tval, int delta, T tmax) {
  int ival = (int) tval;
  ival = (ival + delta + (int)tmax) % (int)tmax;
  return (T) ival;
}

int _clampadd(int val, int delta, int imin, int imax) {
  return std::max(std::min(imax, (val + delta)), imin);
}

const char* _selectorModeMsgs[(int)SelectorMode::Max] = {
  "mode joystick",
  "mode gear",
  "mode powersave",
};

const char* _powerSaveMsgs[(int)PowerSaveMode::Max] = {
  "powersave off",
  "powersave on",
};

const char* _gearMsgs[GearMax] = {
  "gear 1",
  "gear 2",
  "gear 3",
  "gear 4",
  "gear 5",
  "gear 6",
};

const char* _joystickModeMsgs[(int)JoystickMode::Max] = {
  "joystick joystick",
  "joystick keyboard",
  "joystick mouse",
};

void State::fnJoystick(int8_t x, int8_t y) {
  if (x) { // selector switch
    selectorMode = _ringadd(selectorMode, x, SelectorMode::Max);
    queueUSB(UsbAction::SerialPrint(_selectorModeMsgs[(int)selectorMode]));
  } else if (y) { // value adjust
    switch(selectorMode) {
      case SelectorMode::Gear:
        currentGear = _clampadd(currentGear, -y, 0, GearMax - 1);
        queueUSB(UsbAction::SerialPrint(_gearMsgs[(int)currentGear]));
      break;
      case SelectorMode::Joystick:
        joystickMode = _ringadd(joystickMode, -y, JoystickMode::Max);
        queueUSB(UsbAction::SerialPrint(_joystickModeMsgs[(int)joystickMode]));
      break;
      case SelectorMode::PowerSave:
        powerSaveMode = _ringadd(powerSaveMode, -y, PowerSaveMode::Max);
        queueUSB(UsbAction::SerialPrint(_powerSaveMsgs[(int)powerSaveMode]));
      default:
      break;
    }
  }
}

void State::joystickMouseFeed(JOYSTICK_KEY key, int8_t mode) {
  js_keys[key] = mode;
  if (key == JS_KEY_B || key == JS_KEY_SEL) {
    if (mode == KEY_PRESSED) {
      dv->state->queueUSB(UsbAction::MouseDown(MOUSE_LEFT));
    } else {
      dv->state->queueUSB(UsbAction::MouseUp(MOUSE_LEFT));
    }
  } else if (key == JS_KEY_A || key == JS_KEY_STA) {
    if (mode == KEY_PRESSED) {
      dv->state->queueUSB(UsbAction::MouseDown(MOUSE_RIGHT));
    } else {
      dv->state->queueUSB(UsbAction::MouseUp(MOUSE_RIGHT));
    }
  } else if (key == JS_KEY_X) {
    if (mode == KEY_PRESSED) {
      pressMiddleClick();
    } else {
      if (!scrolled) {
        dv->state->queueUSB(UsbAction::MouseClick(MOUSE_MIDDLE));
      }
      releaseMiddleClick();
    }
  }
}

bool State::joystickDpadActive() {
  return js_keys[JS_KEY_UP] || js_keys[JS_KEY_DOWN] || js_keys[JS_KEY_LEFT] || js_keys[JS_KEY_RIGHT];
}

void State::joystickJoyFeed(JOYSTICK_KEY key, int8_t mode) {
  bool was_active = joystickDpadActive();
  js_keys[key] = mode;
  bool is_active = joystickDpadActive();
  switch (key)
  {
  case JS_KEY_UP:
  case JS_KEY_DOWN:
    if (js_keys[JS_KEY_UP] == KEY_PRESSED && js_keys[JS_KEY_DOWN] == KEY_RELEASED)
    {
      queueUSB(UsbAction::JoystickY(0));
    }
    else if (js_keys[JS_KEY_UP] == KEY_RELEASED && js_keys[JS_KEY_DOWN] == KEY_PRESSED)
    {
      queueUSB(UsbAction::JoystickY(1023));
    } else 
    {
      queueUSB(UsbAction::JoystickY(511));
    }
    break;
    case JS_KEY_LEFT:
    case JS_KEY_RIGHT:
    if (js_keys[JS_KEY_LEFT] == KEY_PRESSED && js_keys[JS_KEY_RIGHT] == KEY_RELEASED)
    {
      queueUSB(UsbAction::JoystickX(0));
    }
    else if (js_keys[JS_KEY_LEFT] == KEY_RELEASED && js_keys[JS_KEY_RIGHT] == KEY_PRESSED)
    {
      queueUSB(UsbAction::JoystickX(1023));
    } else 
    {
      queueUSB(UsbAction::JoystickX(511));
    }
    break;
  }
  if (was_active ^ is_active) {
    jm_tick = 0;
  }
}

static const int SCROLL_SLOW_TICKS = 40;
static const int SCROLL_FAST_TICKS = 10;
static const int SCROLL_SLOW_CNT = 1;
static const int SCROLL_FAST_CNT = 1;
static const int MOVE_FAST = 8;
static const int MOVE_SLOW = 2;

bool State::joystickMouseTask() {
  bool active = joystickDpadActive();
  if (joystickMode != JoystickMode::Mouse || !active) {
    return false;
  }
  bool slow = js_keys[JS_KEY_Y];
  int8_t x = 0; int8_t y = 0; // move
  int8_t v = 0; int8_t h = 0; // wheel
  int8_t spd = 0; 
  int8_t ticks = 0;
  const auto mode = moveTrackball();

  if (mode == TrackballMode::Mouse) {
    spd = slow ? MOVE_SLOW : MOVE_FAST;
    ticks = 0;
  } else {
    spd = slow ? SCROLL_SLOW_CNT : SCROLL_FAST_CNT;
    ticks = slow ? SCROLL_SLOW_TICKS : SCROLL_FAST_TICKS;
  }

  if (js_keys[JS_KEY_LEFT]) {
    x -= spd;
  }
  if (js_keys[JS_KEY_RIGHT]) {
    x += spd;
  }
  if (js_keys[JS_KEY_UP]) {
    y -= spd;
  }
  if (js_keys[JS_KEY_DOWN]) {
    y += spd;
  }

  if (mode == TrackballMode::Wheel) {
    v = y; h = x;
    y = 0; x = 0;

    bool s = getScrolled();
    setScrolled();
    if (++jm_tick < ticks && s) {
      v = 0; h = 0;
    } else {
      jm_tick = 0;
    }
  }

  if(x != 0 || y != 0 || v!=0 || h != 0) {
    dv->state->queueUSB(UsbAction::MouseMove(x,y,-v,h));
    return true;
  } else {
    return false;
  }
}

void State::queueUSB(UsbAction action)
{
  if (pending_actions.size() >= 64) {
    return;
  }
  pending_actions.push(action);
}

void State::flushUSB() {
  if (usb_resume_tick > 0) {
    --usb_resume_tick;
    return;
  }
  if (pending_actions.size() == 0) { // idle
    if (sleep_tick >= SLEEPTICK_MAX)
    {
      // power down now
      if (usb_active)
      {
        usb_active = false;
        usb_resuming = false;
        HID.end();

        //  disconnects USBDP
        gpio_set_mode(GPIOA, 12, GPIO_OUTPUT_PP);
        gpio_write_bit(GPIOA, 12, 0);
        //  disconnect USBDM
        gpio_set_mode(GPIOA, 11, GPIO_OUTPUT_PP);
        gpio_write_bit(GPIOA, 11, 0);
      }
      else
      {
        // TODO really low power. currently does not wake up.
        // low_power_enter_sleep();
      }
    }
    else if (!usb_resuming && joystickMode != JoystickMode::Joystick && powerSaveMode != PowerSaveMode::Off)
    {
      ++sleep_tick;
    }
    return;
  }
  // has pending, check usb status and try wakeup if usb not active
  sleep_tick = 0;
  int dequeue_cnt = 0;
  if (!usb_active) {
    if (usb_resuming) {
      if (USBComposite) {
        debug_led(false);
        usb_resume_tick = 120;
        usb_resuming = false;
        usb_active = true;
      }
    } else {
      debug_led(true);
      HID.begin();
      usb_resuming = true;
    }
    return;
  }

  const char* pmsg;
  while (dequeue_cnt < 20 && pending_actions.size()) {
    UsbAction action = pending_actions.front();
    pending_actions.pop();
    ++dequeue_cnt;
    switch (action.type)
    {
    case KeyDown:
      dv->Keyboard->press(action.arg0);
      break;
    case KeyUp:
      dv->Keyboard->release(action.arg0);
      break;
    case SetAdjustForHostCapsLock:
      dv->Keyboard->setAdjustForHostCapsLock(action.arg0);
      break;
    case MouseDown:
      dv->Mouse->press(action.arg0);
      break;
    case MouseUp:
      dv->Mouse->release(action.arg0);
      break;
    case MouseClick:
      dv->Mouse->click(action.arg0);
      break;
    case MouseMove:
      dv->Mouse->move(action.arg0, action.arg1, action.arg2, action.arg3);
      break;
    case CSMDown:
      dv->Consumer->press(action.arg0);
      break;
    case CSMUp:
      dv->Consumer->release();
      break;
    case JoystickX:
      dv->Joystick->X(action.arg0);
      break;
    case JoystickY:
      dv->Joystick->Y(action.arg0);
      break;
    case JoystickKey:
      dv->Joystick->button(action.arg0, action.arg1);
      break;
    case SerialPrint:
      pmsg = (const char*)action.arg0;
      dv->_Serial->println(pmsg);
      break;
    }
  }
}

// https://eleccelerator.com/usbdescreqparser/
// https://www.usb.org/sites/default/files/hut1_2.pdf
// https://eleccelerator.com/tutorial-about-usb-hid-report-descriptors/
// https://www.usb.org/sites/default/files/hid1_11.pdf