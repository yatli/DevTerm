#!/bin/bash


while true; do
    read -p "Do you wish to flash the devterm keyboard firmware at your own risk?(y|n)" yn
    case $yn in
        [Yy]* ) sleep 2; ./maple_upload ttyACM0 2 1EAF:0003 devterm_keyboard.ino.bin ; break;;
        [Nn]* ) exit;;
        * ) echo "Please answer yes or no.";;
    esac
done

