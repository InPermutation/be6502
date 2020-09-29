  .org $8000
  .include 'ps2.s'
  .include 'via.s'
  .include 'lcd.s'
  .include 'vdp.s'
  .include 'tty.s'

s_reset: .asciiz "Initialized."
s_reset_2: .asciiz "hello, world."
s_empty: .asciiz ""

reset:
  ; initialize stack pointer to $01FF
  ldx #$ff
  txs

  jsr via_reset
  jsr ps2_reset
  jsr lcd_reset
  jsr vdp_reset
  jsr tty_reset

  puts s_reset
  puts s_reset_2

  cli
  lda #0

loop:
  jsr print_hex_byte
  puts s_empty
  ina
  jmp loop

; Vector locations
  .org $fffa
  .word ps2_nmi
  .word reset
  .word ps2_irq_brk
