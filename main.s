  .org $8000
  .include 'ps2.s'
  .include 'via.s'
  .include 'lcd.s'
  .include 'vdp.s'
  .include 'tty.s'
  .include 'monitor.s'
  .include 'timer.s'

  .dsect
toggle_time: reserve 1 ; the low byte of ticks when we last toggled the LED
  .dend

irq:
  jsr timer_irq
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
  jsr timer_reset

  stz toggle_time
  cli

toggle:
  lda PORTA
  eor #%00000010
  sta PORTA
  lda ticks
  sta toggle_time
loop:
  sec
  lda ticks
  sbc toggle_time
  cmp #25 ; have >=250ms passed?
  bcc loop
  wai
  bra toggle

; Vector locations
  .org $fffa
  .word ps2_nmi
  .word reset
  .word irq
