PORTB = $6000
PORTA = $6001
DDRB  = $6002
DDRA  = $6003
DDRA_NORMAL = %11100000
DDRA_LOW_PA4 = %11110000
DDRA_LOW_PA3 = %11101000
ALL_IN = %00000000
ALL_OUT = %11111111

LDU = $00 ; Zero page baby
RBA = $01

E = %10000000
RW = %01000000
RS = %00100000

  .org $8000
reset:
  ; initialize stack pointer to $01FF
  ldx #$ff
  txs

  lda #ALL_OUT ; Set all pins on port B to output
  sta DDRB

  lda #DDRA_NORMAL ; Set top 3 pins on port A to output
  sta DDRA

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

  ldx #0

write_str:
  lda str,x
  beq loop       ; exit loop if str[x] is zero
  jsr print_char
  inx
  jmp write_str

loop:
  jmp loop

lcd_instruction:
  jsr lcd_wait

  sta PORTB
  lda #0         ; Clear RS/RW/E bits
  sta PORTA
  lda #E         ; Set E bit to enable display
  sta PORTA
  lda #0         ; Clear RS/RW/E bits
  sta PORTA
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


str:
  .asciiz "Hello from 6502!   1Maybe line 3?      3jacob.jkrall.net   2Guessing line 4?   4"
  ;        12345678901234567890123456789012345678901234567890123456789012345678901234567890
  ;                        xxxxxxxxxxxxxxxxxxxxxxxx                xxxxxxxxxxxxxxxxxxxxxxxx

irq_brk:
  rti

nmi:
  rti

  .org $fffa
  .word nmi
  .word reset
  .word irq_brk
