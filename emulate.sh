#!/bin/bash
set -ex

# https://github.com/Kris-Sekula/EPROM-EMU-NG

python3 ~/EPROM-EMU-NG/Software/EPROM_EMU_NG_2.0rc9.py -mem 28256 -spi n -auto n a.out /dev/cu.usbserial-*
