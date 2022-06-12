#ifndef STATE_H
#define STATE_H

#include <bitset>
#include <array>
#include <USBComposite.h>
#include <queue>

#include "debouncer.h"

class DEVTERM;

enum class TrackballMode : uint8_t {
  Wheel,
  Mouse,
};

enum class JoystickMode : uint8_t {
  Joystick,
  Keyboard,
  Mouse,
  Max,
};

enum class SelectorMode : uint8_t {
  Joystick,
  Gear,
  Max
};

enum JOYSTICK_KEY {
  JS_KEY_SEL,
  JS_KEY_STA,
  JS_KEY_UP,
  JS_KEY_DOWN,
  JS_KEY_LEFT,
  JS_KEY_RIGHT,
  JS_KEY_A,
  JS_KEY_B,
  JS_KEY_X,
  JS_KEY_Y,
  JS_KEY_MAX,
};

// 0-5
constexpr int GearMax = 6;

struct UsbAction {
  uint8_t type;
  uint8_t arg0;
  uint8_t arg1;
  uint8_t arg2;
  uint8_t arg3;
};

class State
{
  public:
    static const uint16_t MIDDLE_CLICK_TIMEOUT_MS = 0;

    State(DEVTERM*);

    void tick(uint8_t delta);

    bool fn;

    void pressMiddleClick();
    bool releaseMiddleClick();
    bool getScrolled();
    void setScrolled();
    TrackballMode moveTrackball();
    void setJoystickMode(JoystickMode);
    JoystickMode getJoystickMode();
    void fnJoystick(int8_t x, int8_t y);
    void joystickMouseFeed(JOYSTICK_KEY key, int8_t mode);
    void joystickJoyFeed(JOYSTICK_KEY key, int8_t mode);
    bool joystickMouseTask();
    bool joystickDpadActive();

    void sleepTick();
    void wakeup();
    void postAction();
    void flushActions();
  private:
    bool middleClick;
    bool scrolled;
    Timeout<uint16_t, MIDDLE_CLICK_TIMEOUT_MS> middleClickTimeout;
    int currentGear;
    DEVTERM* dv;
    SelectorMode selectorMode;
    JoystickMode joystickMode;
    bool js_keys[JS_KEY_MAX];
    int jm_tick;
    int sleep_tick;
    bool usb_active;
    std::queue<UsbAction> pending_actions;
};

#endif
