#!/usr/bin/python3
import sys
import os
from os import system
from time import sleep
import evdev
from evdev import ecodes, UInput

def L1(val):
    pass
def L2(val):
    pass

def send_key(mod, key):
    global ui
    if mod != None:
        ui.write(ecodes.EV_KEY, mod, 1)
    ui.write(ecodes.EV_KEY, key, 1)
    ui.syn()
    ui.write(ecodes.EV_KEY, key, 0)
    if mod != None:
        ui.write(ecodes.EV_KEY, mod, 0)
    ui.syn()

# Layer 1: Data manipulation
def L1B(val):
    if val:
        send_key(ecodes.KEY_LEFTCTRL, ecodes.KEY_C)
def L1A(val):
    if val:
        send_key(ecodes.KEY_LEFTCTRL, ecodes.KEY_V)
def L1Y(val):
    if val:
        send_key(ecodes.KEY_LEFTCTRL, ecodes.KEY_A)
def L1X(val):
    if val:
        send_key(ecodes.KEY_LEFTCTRL, ecodes.KEY_X)

# Layer 2: Window manipulation
def L2B(val): # Maximize
    if val:
        send_key(ecodes.KEY_LEFTALT, ecodes.KEY_F11)
def L2Y(val): # Move window
    if val:
        send_key(ecodes.KEY_LEFTALT, ecodes.KEY_SPACE)
        sleep(0.2)
        send_key(None, ecodes.KEY_M)
def L2X(val): # Resize window
    if val:
        send_key(ecodes.KEY_LEFTALT, ecodes.KEY_SPACE)
        sleep(0.2)
        send_key(None, ecodes.KEY_R)
def L2A(val): # Close window
    if val:
        send_key(ecodes.KEY_LEFTALT, ecodes.KEY_F4)

def main_loop():
    devs = [evdev.InputDevice(d) for d in evdev.list_devices()]
    devs = list(filter(lambda x: x.name == "ClockworkPI DevTerm", devs))
    if len(devs) != 1:
        return
    dev = devs[0]
    global win_L1
    global win_L2
    global ui
    ui = UInput()
    try:
        for ev in dev.read_loop():
            # code type value
            if ev.type != ecodes.EV_KEY:
                continue
            if ev.code == 710:
                L1(ev.value)
            elif ev.code == 711:
                L2(ev.value)
            # L1 buttons
            elif ev.code == 712:
                L1B(ev.value)
            elif ev.code == 713:
                L1A(ev.value)
            elif ev.code == 714:
                L1Y(ev.value)
            elif ev.code == 715:
                L1X(ev.value)
            # L2 buttons
            elif ev.code == 716:
                L2B(ev.value)
            elif ev.code == 717:
                L2A(ev.value)
            elif ev.code == 718:
                L2Y(ev.value)
            elif ev.code == 719:
                L2X(ev.value)
    except BaseException as err:
        print(err)
        ui.close()
        return

if __name__ == "__main__":
    while True:
        try:
            main_loop();
        except BaseException as err:
            print(err)
            pass
        sleep(1)
