#!/bin/bash
set -ex

./vasm6502_oldstyle -L a.list -chklabels -wfail -x -wdc02 -Fbin -dotdir main.s
