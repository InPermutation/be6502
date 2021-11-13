; VIA ports
VIA_BASE = $6000
PORTB = VIA_BASE + 0
PORTA = VIA_BASE + 1
DDRB  = VIA_BASE + 2
DDRA  = VIA_BASE + 3
T1CL  = VIA_BASE + 4
T1CH  = VIA_BASE + 5
T1LL  = VIA_BASE + 6
T1LH  = VIA_BASE + 7
T2CL  = VIA_BASE + 8
T2CH  = VIA_BASE + 9
SHR   = VIA_BASE + $A
ACR   = VIA_BASE + $B
PCR   = VIA_BASE + $C
IFR   = VIA_BASE + $D
IER   = VIA_BASE + $E
PORTA_NO_HANDSHAKE = VIA_BASE + $F

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
