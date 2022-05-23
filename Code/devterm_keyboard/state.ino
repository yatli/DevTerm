#include <cassert>
#include <algorithm>
#include <limits>

#include "devterm.h"
#include "state.h"
#include "keyboard.h"

State::State(DEVTERM* dt)
  : dv(dt),
    fn(false),
    middleClick(false),
    scrolled(false),
    joystickMode(JoystickMode::Joystick),
    selectorMode(SelectorMode::Joystick),
    currentGear(2), // gear 3
    jm_tick(0)
{
  std::fill(js_keys, js_keys + JS_KEY_MAX, false);
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
    dv->_Serial->println(_selectorModeMsgs[(int)selectorMode]);
  } else if (y) { // value adjust
    switch(selectorMode) {
      case SelectorMode::Gear:
        currentGear = _clampadd(currentGear, -y, 0, GearMax - 1);
        dv->_Serial->println(_gearMsgs[(int)currentGear]);
      break;
      case SelectorMode::Joystick:
        joystickMode = _ringadd(joystickMode, -y, JoystickMode::Max);
        dv->_Serial->println(_joystickModeMsgs[(int)joystickMode]);
      break;
      default:
      break;
    }
  }
}

void State::joystickMouseFeed(JOYSTICK_KEY key, int8_t mode) {
  js_keys[key] = mode;
  if (key == JS_KEY_B || key == JS_KEY_SEL) {
    if (mode == KEY_PRESSED) {
      dv->Mouse->press(MOUSE_LEFT);
    } else {
      dv->Mouse->release(MOUSE_LEFT);
    }
  } else if (key == JS_KEY_A || key == JS_KEY_STA) {
    if (mode == KEY_PRESSED) {
      dv->Mouse->press(MOUSE_RIGHT);
    } else {
      dv->Mouse->release(MOUSE_RIGHT);
    }
  } else if (key == JS_KEY_X) {
    if (mode == KEY_PRESSED) {
      pressMiddleClick();
    } else {
      if (!scrolled) {
        dv->Mouse->click(MOUSE_MIDDLE);
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
      dv->Joystick->Y(0);
    }
    else if (js_keys[JS_KEY_UP] == KEY_RELEASED && js_keys[JS_KEY_DOWN] == KEY_PRESSED)
    {
      dv->Joystick->Y(1023);
    } else 
    {
      dv->Joystick->Y(511);
    }
    break;
    case JS_KEY_LEFT:
    case JS_KEY_RIGHT:
    if (js_keys[JS_KEY_LEFT] == KEY_PRESSED && js_keys[JS_KEY_RIGHT] == KEY_RELEASED)
    {
      dv->Joystick->X(0);
    }
    else if (js_keys[JS_KEY_LEFT] == KEY_RELEASED && js_keys[JS_KEY_RIGHT] == KEY_PRESSED)
    {
      dv->Joystick->X(1023);
    } else 
    {
      dv->Joystick->X(511);
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
  int8_t x = 0;
  int8_t y = 0;
  int8_t w = 0;
  int8_t spd = 0; 
  int8_t ticks = 0;
  const auto mode = moveTrackball();

  if (mode == TrackballMode::Mouse) {
    spd = slow ? MOVE_SLOW : MOVE_FAST;
    ticks = 0;

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
  } else {
    spd = slow ? SCROLL_SLOW_CNT : SCROLL_FAST_CNT;
    ticks = slow ? SCROLL_SLOW_TICKS : SCROLL_FAST_TICKS;
    if (js_keys[JS_KEY_UP]) {
      w -= spd;
    }
    if (js_keys[JS_KEY_DOWN]) {
      w += spd;
    }
    bool s = getScrolled();
    setScrolled();
    if (++jm_tick < ticks && s) {
      w = 0;
    } else {
      jm_tick = 0;
    }
  }

  if(x !=0 || y != 0 || w!=0) {
    dv->Mouse->move(x, y, -w);
    return true;
  } else {
    return false;
  }
}