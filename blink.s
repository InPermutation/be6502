PORTB = $6000
PORTA = $6001
DDRB  = $6002
DDRA  = $6003

E = %10000000
RW = %01000000
RS = %00100000

  .org $8000
reset:
  ; initialize stack pointer to $01FF
  ldx #$ff
  txs

  lda #%11111111 ; Set all pins on port B to output
  sta DDRB

  lda #%11100000 ; Set top 3 pins on port A to output
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
  sta PORTB
  lda #0         ; Clear RS/RW/E bits
  sta PORTA
  lda #E         ; Set E bit to enable display
  sta PORTA
  lda #0         ; Clear RS/RW/E bits
  sta PORTA
  rts

print_char:
  sta PORTB
  lda #RS        ; Set RS
  sta PORTA
  lda #(RS | E)  ; Send data to display
  sta PORTA
  lda #RS         ; Clear E bit
  sta PORTA
  rts

str:
  .asciiz "Hello, RAM!"

  .org $fffc
  .word reset
  .word $0000
