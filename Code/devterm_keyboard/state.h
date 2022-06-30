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

enum class PowerSaveMode : uint8_t {
  Off,
  On,
  Max,
};

enum class JSMouseOverlay : uint8_t {
  None,
  Layer1,
  Layer2,
  Max
};

enum class SelectorMode : uint8_t {
  Joystick,
  Gear,
  PowerSave,
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

enum UsbActionType : uint8_t {
  KeyDown,
  KeyUp,
  SetAdjustForHostCapsLock,
  MouseDown,
  MouseUp,
  MouseClick,
  MouseMove,
  CSMDown,
  CSMUp,
  JoystickX,
  JoystickY,
  JoystickKey,
  SerialPrint,
};

struct UsbAction {
  UsbActionType type;
  int32_t arg0;
  int8_t arg1;
  int8_t arg2;
  int8_t arg3;

  UsbAction(UsbActionType ty) : type(ty) {}
  UsbAction(UsbActionType ty, const char* _arg0) : type(ty), arg0((int32_t)_arg0) {}
  UsbAction(UsbActionType ty, int16_t _arg0) : type(ty), arg0(_arg0) {}
  UsbAction(UsbActionType ty, int16_t _arg0, int8_t _arg1) : type(ty), arg0(_arg0), arg1(_arg1) {}
  UsbAction(UsbActionType ty, int16_t _arg0, int8_t _arg1, int8_t _arg2, int8_t _arg3) : type(ty), arg0(_arg0), arg1(_arg1), arg2(_arg2), arg3(_arg3) {}

  static UsbAction KeyDown(char x) {
    return UsbAction(UsbActionType::KeyDown, x);
  }
  static UsbAction KeyUp(char x) {
    return UsbAction(UsbActionType::KeyUp, x);
  }
  static UsbAction MouseUp(uint8_t x) {
    return UsbAction(UsbActionType::MouseUp, x);
  }
  static UsbAction MouseDown(uint8_t x) {
    return UsbAction(UsbActionType::MouseDown, x);
  }
  static UsbAction MouseClick(uint8_t x) {
    return UsbAction(UsbActionType::MouseClick, x);
  }
  static UsbAction MouseMove(int8_t x, int8_t y, int8_t v, int8_t h) {
    return UsbAction(UsbActionType::MouseMove, x, y, v, h);
  }
  static UsbAction CSMUp() {
    return UsbAction(UsbActionType::CSMUp);
  }
  static UsbAction CSMDown(uint8_t x) {
    return UsbAction(UsbActionType::CSMDown, x);
  }
  static UsbAction SetAdjustForHostCapsLock(bool x) {
    return UsbAction(UsbActionType::SetAdjustForHostCapsLock, (int8_t) x);
  }
  static UsbAction JoystickX(int16_t x) {
    return UsbAction(UsbActionType::JoystickX, x);
  }
  static UsbAction JoystickY(int16_t x) {
    return UsbAction(UsbActionType::JoystickY, x);
  }
  static UsbAction JoystickKey(int8_t x, int8_t mode) {
    return UsbAction(UsbActionType::JoystickKey, x, mode);
  }
  static UsbAction SerialPrint(const char* pmsg) {
    return UsbAction(UsbActionType::SerialPrint, pmsg);
  }
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
    void setPowerSaveMode(PowerSaveMode);
    PowerSaveMode getPowerSaveMode();
    void fnJoystick(int8_t x, int8_t y);
    void joystickMouseFeed(JOYSTICK_KEY key, int8_t mode);
    void joystickJoyFeed(JOYSTICK_KEY key, int8_t mode);
    bool joystickMouseTask();
    bool joystickDpadActive();

    void queueUSB(UsbAction action);
    void flushUSB();
  private:
    bool middleClick;
    bool scrolled;
    Timeout<uint16_t, MIDDLE_CLICK_TIMEOUT_MS> middleClickTimeout;
    DEVTERM* dv;
    SelectorMode selectorMode;
    JoystickMode joystickMode;
    PowerSaveMode powerSaveMode;
    JSMouseOverlay jsmouseOverlay;
    bool js_keys[JS_KEY_MAX];
    bool js_mouse_slow;
    int jm_tick;
    int sleep_tick;
    bool usb_inactive_mouse;
    bool usb_active;
    bool usb_resuming;
    bool serial_active;
    int usb_resume_loops;
    std::queue<UsbAction> pending_actions;
};

#endif
