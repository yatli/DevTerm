#!/usr/bin/python3

import glob
import os
import sys,getopt
import subprocess
import time
import math

cpus = []
mid_freq = 0
max_freq = 0

MIN_TEMP=52000
MAX_TEMP=65000
ONCE_TIME=30
PWM_PERIOD=50000000 # 50ms
DUTY_CYCLES=[
    42000000,
    44000000,
    46000000,
    47000000,
    47500000,
    48000000,
    48500000,
    49000000,
    49400000,
    49700000,
    50000000,
]
fan_active = False

THERMAL_ZONES = glob.glob('/sys/class/thermal/thermal_zone[0-9]/')
THERMAL_ZONES.sort()

def isDigit(x):
    try:
        float(x)
        return True
    except ValueError:
        return False

def echo(content, file):
    # print("echo %s to %s" % (str(content), file))
    with open(file, 'w') as f:
        f.write(str(content))

def init_fan_pwm():
    try:
        echo(0, "/sys/class/pwm/pwmchip0/export")
    except:
        pass
    echo(PWM_PERIOD, "/sys/class/pwm/pwmchip0/pwm0/period")
    echo(0, "/sys/class/pwm/pwmchip0/pwm0/duty_cycle")

def fan_on():
    echo(1, "/sys/class/pwm/pwmchip0/pwm0/enable")

def fan_off():
    echo(0, "/sys/class/pwm/pwmchip0/pwm0/enable")

def cpu_infos():
    global cpus
    global mid_freq
    global max_freq

    cpus = glob.glob('/sys/devices/system/cpu/cpu[0-9]')
    cpus.sort()
#/sys/devices/system/cpu/cpu0/cpufreq/scaling_available_frequencies
#/sys/devices/system/cpu/cpu0/cpufreq/scaling_governor

    scaling_available_freq = open(os.path.join(cpus[0],"cpufreq/scaling_available_frequencies"),"r").read()
    scaling_available_freq = scaling_available_freq.strip("\n")
    scaling_available_freqs = scaling_available_freq.split(" ")

    for var in scaling_available_freqs:
        if isDigit(var):
            if(int(var) > 1000000):
                if(mid_freq == 0):
                    mid_freq = int(var)
            max_freq = int(var)


def set_gov(gov):
    global cpus
    for var in cpus:
        gov_f = os.path.join(var,"cpufreq/scaling_governor")
        # print(gov_f)
        try:
            echo(gov, gov_f)
        except:
            print(f"Error: cannot set governor for {var}")
    
def set_performance(scale):
    global cpus
    global mid_freq
    global max_freq

    freq = mid_freq
    if scale =="mid":
        freq = mid_freq
    elif scale =="max":
        freq = max_freq
  
    for var in cpus:
        _f = os.path.join(var,"cpufreq/scaling_max_freq")
        #print(_f)
        try:
            echo(freq, _f)
        except:
            print(f"Error: cannot set performance for {var}")

def decide_fan_level(temp):
    """ 
    Maps temperature to a fan level of Off/[0-10]
    """
    if temp < MIN_TEMP:
        return -1
    elif temp >= MAX_TEMP:
        return 10
    else:
        percent = (temp - MIN_TEMP) / (MAX_TEMP - MIN_TEMP)
        return int(math.pow(percent, 2) * 10)

def fan_set(level):
    global DUTY_CYCLES
    cycle = DUTY_CYCLES[level]
    print(cycle)
    echo(cycle, '/sys/class/pwm/pwmchip0/pwm0/duty_cycle')
    return

def read_thermal_zone(tz) -> int:
    _f = os.path.join(tz,"temp")
    _t = open(_f).read().strip("\n")
    if isDigit(_t):
        # print(f"temp is: {_t}")
        return int(_t)
    else:
        return 0

def fan_loop() -> None:
    global THERMAL_ZONES
    global fan_active

    tz_temps = map(read_thermal_zone, THERMAL_ZONES)
    fan_levels = map(decide_fan_level, tz_temps)
    fan_level = max(fan_levels)
    if fan_level >= 0:
        if not fan_active:
            fan_active = True
            fan_on()
        fan_set(fan_level)
    else:
        if fan_active:
            fan_active = False
            fan_off()
    time.sleep(5)

def main(argv):
    global cpus
    scale = 'mid'
    gov   = 'schedutil'
    try:
        opts, args = getopt.getopt(argv,"hs:g:",["scale=","governor="])
    except getopt.GetoptError:
        print ('test.py -s <scale> -g <governor>')
        sys.exit(2)
    for opt, arg in opts:
        if opt == '-h':
            print ('test.py -s <scale>')
            sys.exit()
        elif opt in ("-s", "--scale"):
            scale = arg
        elif opt in ("-g","--governor"):
            gov = arg

    print ('Scale is ', scale,"Gov is ",gov)

    init_fan_pwm()
    cpu_infos()
    set_gov(gov)
    set_performance(scale)
    while True:
        fan_loop()

def test_temp(T):
    print(f'fan level[{T}] = {decide_fan_level(T)}')

if __name__ == "__main__":
    main(sys.argv[1:])

