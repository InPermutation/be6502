  .org $8000
  .include 'ps2.s'
  .include 'via.s'
  .include 'lcd.s'
  .include 'vdp.s'
  .include 'tty.s'
  .include 'monitor.s'


reset:
  ; initialize stack pointer to $01FF
  ldx #$ff
  txs

  jsr via_reset
  jsr ps2_reset
  jsr lcd_reset
  jsr vdp_reset
  jsr tty_reset

  cli
  jmp monitor


; Vector locations
  .org $fffa
  .word ps2_nmi
  .word reset
  .word ps2_irq_brk
