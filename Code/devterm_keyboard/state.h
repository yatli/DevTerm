#ifndef STATE_H
#define STATE_H

#include <bitset>
#include <array>
#include <USBComposite.h>

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

enum JOYMOUSE_KEY {
  JM_SEL,
  JM_STA,
  JM_UP,
  JM_DOWN,
  JM_LEFT,
  JM_RIGHT,
  JM_A,
  JM_B,
  JM_X,
  JM_Y,
  JM_MAX,
};

// 0-5
constexpr int GearMax = 6;

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
    void joystickMouseFeed(JOYMOUSE_KEY key, int8_t mode);
    void joystickMouseTask();
  private:
    bool middleClick;
    bool scrolled;
    Timeout<uint16_t, MIDDLE_CLICK_TIMEOUT_MS> middleClickTimeout;
    int currentGear;
    DEVTERM* dv;
    SelectorMode selectorMode;
    JoystickMode joystickMode;
    bool jm_keys[JM_MAX];
    int jm_scroll_tick;
};

#endif
