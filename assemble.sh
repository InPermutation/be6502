#!/bin/bash
set -ex

FILE="${1:-main.s}"

./vasm6502_oldstyle -L a.list -chklabels -wfail -x -wdc02 -Fbin -dotdir $FILE
