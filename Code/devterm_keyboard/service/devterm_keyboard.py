import serial
from os import system
ser = serial.Serial('/dev/ttyACM0')

def handle_gear(line):
    try:
        g = int(line[1])
        g = max(g, 1)
        g = min(g, 6)
        system(f'/usr/bin/devterm-a06-gearbox -s {g}')
        system(f'/usr/bin/sudo -u cpi /usr/bin/notify-send "Gear = {g}"')
    except:
        pass

def handle_joystick(line):
    try:
        system(f'/usr/bin/sudo -u cpi /usr/bin/notify-send "Joystick = {line[1]}"')
    except:
        pass

def handle_selector(line):
    try:
        system(f'/usr/bin/sudo -u cpi /usr/bin/notify-send "Selector = {line[1]}"')
    except:
        pass

while True:
    line = ser.readline().decode('utf-8').split()
    if len(line) < 1:
        continue
    cmd = line[0]
    if cmd == 'gear':
        handle_gear(line)
    if cmd == 'joystick':
        handle_joystick(line)
    if cmd == 'mode':
        handle_selector(line)
