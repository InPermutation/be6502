  .dsect
ticks: reserve 4  ; 32-bit (little-endian) ticks since reset
  .dend

timer_reset:
  pha
  lda DDRA
  ora #%00000010 ; A1, output
  sta DDRA
  stz ticks
  stz ticks + 1
  stz ticks + 2
  stz ticks + 3
  lda #%01000000 ; T1 continuous interrupts
  sta ACR
  lda #$59
  sta T1CL
  lda #$00
  sta T1CH
  lda #%11000000 ; Set T1 interrupt enabled
  sta IER
  pla
  rts

timer_irq:
  bit IFR
  bvc .exit
  bit T1CL ; clears 'Time-Out of T1' interrupt
  inc ticks
  bne .exit
  inc ticks + 1
  bne .exit
  inc ticks + 2
  bne .exit
  inc ticks + 3
.exit:
  rts
