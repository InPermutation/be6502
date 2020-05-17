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
  ; Let's make a D-pad
  ;    U
  ;  L   R     B   A
  ;    D
  ;
  ; Wired in a 2x3 matrix as follows:
  ;      PA3  PA4
  ; PA0   L    R
  ; PA1   D    B
  ; PA2   U    A
  ; PA0-2 are pulled high by 1k resistors.
  ; This means PA3-4 are the driving pins and PA0-2 are for reading.

  ; Set PA3 tristate (read) and PA4 low
  lda #DDRA_LOW_PA4
  sta DDRA

  ; Then read PA0-2
  lda #0
  sta PORTA
  lda PORTA
  and #%00000111 ; only care about the bottom 3 bits
  sta RBA

  ; Set PA3 low and PA4 tristate (read)
  lda #DDRA_LOW_PA3
  sta DDRA

  ; Then read PA0-2 again
  lda #0
  sta PORTA
  lda PORTA
  and #%00000111 ; only care about the bottom 3 bits
  sta LDU

  ; Restore DDRA
  lda #DDRA_NORMAL
  sta DDRA

  lda #%00000010 ; Reset home
  jsr lcd_instruction

  ldx #" "
  lda LDU
  and #%00000001
  bne p_l
  ldx #"L"
p_l:
  txa
  jsr print_char

  ldx #" "
  lda LDU
  and #%00000010
  bne p_d
  ldx #"D"
p_d:
  txa
  jsr print_char

  ldx #" "
  lda LDU
  and #%00000100
  bne p_u
  ldx #"U"
p_u:
  txa
  jsr print_char

  lda #"_"
  jsr print_char

  ldx #" "
  lda RBA
  and #%00000001
  bne p_r
  ldx #"R"
p_r:
  txa
  jsr print_char

  ldx #" "
  lda RBA
  and #%00000010
  bne p_b
  ldx #"B"
p_b:
  txa
  jsr print_char

  ldx #" "
  lda RBA
  and #%00000100
  bne p_a
  ldx #"A"
p_a:
  txa
  jsr print_char

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
  .asciiz "Hello from 6502!                        jacob.jkrall.net"
  ;        12345678901234567890123456789012345678901234567890123456789012345678901234567890
  ;                        xxxxxxxxxxxxxxxxxxxxxxxx                xxxxxxxxxxxxxxxxxxxxxxxx

  .org $fffc
  .word reset
  .word $0000
