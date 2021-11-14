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
pitch: reserve 1
pitch_time: reserve 1
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
  stz pitch_time
  lda #$fe
  sta pitch
  cli

loop:
  wai
  jsr wiggle_audio
  jsr change_pitch
  bra loop

wiggle_audio:
  sec
  lda ticks
  sbc toggle_time
  cmp pitch ; * 0.1 ms
  bcc .exit
  lda ticks
  sta toggle_time
  lda PORTA
  eor #%00000010
  sta PORTA
.exit:
  rts

change_pitch:
  sec
  lda ticks + 1
  sbc pitch_time
  cmp #3
  bcc .exit
  lda ticks + 1
  sta pitch_time
  inc pitch
  lda #1
  jsr lcd_instruction
  lda pitch
  jsr print_hex_byte
.exit:
  rts


; Vector locations
  .org $fffa
  .word ps2_nmi
  .word reset
  .word irq
