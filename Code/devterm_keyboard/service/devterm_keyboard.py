#!/usr/bin/python3
import serial
import sys
import os
from os import system
from time import sleep
import devterm_gearbox

gear_dir = '/var/lib/devterm'
gear_file = gear_dir + '/gear'
gear = 3
gear_max = len(devterm_gearbox.gears)

def notify_send(s):
    system(f'/usr/local/bin/root-notify-send "{s}"')

def handle_gear(line):
    global gear
    global gear_file
    try:
        action = line[1]
        if action == "up":
            gear = gear + 1
        elif action == "down":
            gear = gear - 1
        gear = max(gear, 1)
        gear = min(gear, gear_max)
        devterm_gearbox.devterm.set_gear(gear)
        notify_send(f'Gear = {gear}')
        devterm_gearbox.echo(gear, gear_file)
    except BaseException as err:
        print(err)
        pass

def handle_joystick(line):
    try:
        notify_send(f'Joystick = {line[1]}')
    except:
        pass

def handle_powersave(line):
    try:
        notify_send(f'KBD PowerSave = {line[1]}')
    except:
        pass

def handle_selector(line):
    try:
        notify_send(f'Selector = {line[1]}')
    except:
        pass

def main_loop():
    ser = serial.Serial('/dev/serial/by-path/platform-fe380000.usb-usb-0:1.1:1.1')
    while True:
        line = ser.readline().decode('utf-8').split()
        if len(line) < 1:
            continue
        cmd = line[0]
        if cmd == 'gear':
            handle_gear(line)
        if cmd == 'joystick':
            handle_joystick(line)
        if cmd == 'powersave':
            handle_powersave(line)
        if cmd == 'mode':
            handle_selector(line)

if __name__ == "__main__":
    try:
        os.mkdir(gear_dir)
    except FileExistsError:
        pass
    try:
        with open(gear_file, "r") as f:
            gear = int(f.read().strip())
    except BaseException as err:
        print(err)
        pass
    devterm_gearbox.devterm.set_gear(gear)

    while True:
        try:
            main_loop();
        except:
            sleep(1)
