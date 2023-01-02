#!/bin/bash

FW_SRC="hex/devterm.kbd.yatli.v5_48mhz.bin"
FW_DST="devterm_keyboard.ino.bin"
PACK_DIR="pack"
BUILD_DIR=`mktemp -d`
BUILD_OUT="bin/yatli_custom_keyboard_fw_v5.sh"

cd $PACK_DIR
cp -r `ls` $BUILD_DIR/
cd ..
cp $FW_SRC "$BUILD_DIR/$FW_DST"
makeself --noprogress --nox11 $BUILD_DIR $BUILD_OUT "DevTerm Keyboard Firmware" ./flash.sh
rm -r $BUILD_DIR
