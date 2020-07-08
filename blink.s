PORTB = $6000
PORTA = $6001
DDRB  = $6002
DDRA  = $6003
DDRA_NORMAL = %11100000
ALL_IN = %00000000
ALL_OUT = %11111111

KEY_DATA = %00001000 ; which bit do we read from PORTA

; page 0
KEY_BUF_X = $00      ; producer index into KEY_BUF
KEY_READ_X = $01     ; consumer index into KEY_BUF
; page 1
THE_STACK = $0100
; page 2
KEY_BUF = $0200      ; use Page 2 as circular buffer

E = %10000000
RW = %01000000
RS = %00100000

  .org $8000
reset:
  ; initialize stack pointer to $01FF
  ldx #$ff
  txs

  stz KEY_BUF_X
  stz KEY_READ_X

  lda #ALL_OUT ; Set all pins on port B to output
  sta DDRB

  lda #DDRA_NORMAL ; Set top 3 pins on port A to output
  sta DDRA

  cli

; Set mode
  lda #%00111000 ; Set 8-bit mode; 2-line display 5x8 font
  jsr lcd_instruction

; Display on/off
  lda #%00001110 ; Display on; cursor on ; blink off
  jsr lcd_instruction

; Entry mode set
  lda #%00000110 ; I/D: move direction inc/dec, S: display shift?
  jsr lcd_instruction

; Clear display
  lda #%00000001 ; Clear display
  jsr lcd_instruction

  ldy #0

loop:
  jsr print_debug_info

  lda KEY_READ_X
  cmp KEY_BUF_X
  beq loop

  inc KEY_READ_X

  jmp loop

lcd_instruction:
  pha
  jsr lcd_wait

  sta PORTB
  lda #0         ; Clear RS/RW/E bits
  sta PORTA
  lda #E         ; Set E bit to enable display
  sta PORTA
  lda #0         ; Clear RS/RW/E bits
  sta PORTA
  pla
  rts

print_debug_info:
  pha
  lda #%00000010 ; Return home
  jsr lcd_instruction

  lda KEY_BUF_X
  jsr print_hex_byte

  lda #$20
  jsr print_char

  lda KEY_READ_X
  jsr print_hex_byte

  lda #$20
  jsr print_char

  lda #"S"
  jsr print_char

  php
  pla
  jsr print_hex_byte

  lda #" "
  jsr print_char

  tya
  iny
  jsr print_hex_byte
  pla
  rts

print_hex_byte:
  phx
  pha
  pha
  lsr
  lsr
  lsr
  lsr
  and #$0f
  tax
  lda s_hex,x
  jsr print_char
  pla
  and #$0f
  tax
  lda s_hex,x
  jsr print_char
  pla
  plx
  rts

print_char:
  jsr lcd_wait

  sta PORTB
  lda #RS        ; Set RS
  sta PORTA
  lda #(RS | E)  ; Send data to display
  sta PORTA
  lda #RS         ; Clear E bit
  sta PORTA
  rts

lcd_wait:
  pha

  lda #ALL_IN ; Port B is input
  sta DDRB

lcd_wait_loop:
  lda #RW
  sta PORTA
  lda #(RW | E)
  sta PORTA
  lda PORTB
  and #%10000000 ; check busy flag
  bne lcd_wait_loop

  lda #RW
  sta PORTA
  lda #ALL_OUT ; Restore port B to output
  sta DDRB
  pla
  rts

s_hex:
  .asciiz "0123456789ABCDEF"

irq_brk:
  rti

nmi:
  inc KEY_BUF_X
  rti

; Vector locations
  .org $fffa
  .word nmi
  .word reset
  .word irq_brk
