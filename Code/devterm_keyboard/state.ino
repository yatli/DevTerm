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
    jm_scroll_tick(0)
{
  std::fill(jm_keys, jm_keys + JM_MAX, false);
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

void State::joystickMouseFeed(JOYMOUSE_KEY key, int8_t mode) {
  jm_keys[key] = mode;
  if (key == JM_B || key == JM_SEL) {
    if (mode == KEY_PRESSED) {
      dv->Mouse->press(MOUSE_LEFT);
    } else {
      dv->Mouse->release(MOUSE_LEFT);
    }
  } else if (key == JM_A || key == JM_STA) {
    if (mode == KEY_PRESSED) {
      dv->Mouse->press(MOUSE_RIGHT);
    } else {
      dv->Mouse->release(MOUSE_RIGHT);
    }
  } else if (key == JM_X) {
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

void State::joystickMouseTask() {
  if (joystickMode != JoystickMode::Mouse) {
    return;
  }
  bool slow = jm_keys[JM_Y];
  int8_t x = 0;
  int8_t y = 0;
  int8_t w = 0;
  int8_t spd = slow ? 2 : 8;

  if (jm_keys[JM_LEFT]) {
    x -= spd;
  }
  if (jm_keys[JM_RIGHT]) {
    x += spd;
  }
  if (jm_keys[JM_UP]) {
    y -= spd;
  }
  if (jm_keys[JM_DOWN]) {
    y += spd;
  }

  if (x != 0 || y != 0) {
    const auto mode = moveTrackball();
    if (mode == TrackballMode::Wheel) {
      x = 0;
      w = y;
      y = 0;
    }
  }

  if (w != 0) {
    bool s = getScrolled();
    setScrolled();
    if (++jm_scroll_tick < 50 && s) {
      w = 0;
    } else {
      jm_scroll_tick = 0;
    }
  }

  if(x !=0 || y != 0 || -w!=0) {
    dv->Mouse->move(x, y, -w);
  }
 
}