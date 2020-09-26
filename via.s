; VIA ports
PORTB = $6000
PORTA = $6001
DDRB  = $6002
DDRA  = $6003

; VIA masks
DDRA_NORMAL = %11100000
ALL_IN = %00000000
ALL_OUT = %11111111

via_reset:
  lda #ALL_OUT ; Set all pins on port B to output
  sta DDRB

  lda #DDRA_NORMAL ; Set top 3 pins on port A to output
  sta DDRA
  rts
