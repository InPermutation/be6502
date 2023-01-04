  .org $8000
  .include 'ps2.s'
  .include 'via.s'
  .include 'lcd.s'
  .include 'vdp.s'
  .include 'tty.s'
  .include 'monitor.s'

irq:
  rti

reset:
  sei
  ; initialize stack pointer to $01FF
  ldx #$ff
  txs

  jsr ps2_reset
  jsr via_reset
  jsr lcd_reset
  jsr vdp_reset
  jsr tty_reset

  cli

loop:
  wai
  bra loop

; Vector locations
  .org $fffa
  .word ps2_nmi
  .word reset
  .word irq
