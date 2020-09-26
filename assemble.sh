#!/bin/bash
set -ex

./vasm6502_oldstyle -chklabels -wfail -x -wdc02 -Fbin -dotdir main.s
