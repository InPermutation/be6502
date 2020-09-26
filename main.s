  .org $8000
  .include 'ps2.s'
  .include 'via.s'
  .include 'lcd.s'
  .include 'vdp.s'

reset:
  ; initialize stack pointer to $01FF
  ldx #$ff
  txs

  jsr via_reset
  jsr ps2_reset
  jsr lcd_reset
  jsr vdp_reset
  cli

loop:
  jsr getch
  jsr putchar
  jmp loop

; Vector locations
  .org $fffa
  .word ps2_nmi
  .word reset
  .word ps2_irq_brk
