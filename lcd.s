; A 20x4 LCD display.

; LCD flags
E = %10000000
RW = %01000000
RS = %00100000

; constants
LCD_LINE_LENGTH = 20
LCD_LINE0 = 0
LCD_LINE1 = $40
LCD_LINE2 = LCD_LINE_LENGTH
LCD_LINE3 = LCD_LINE1 + LCD_LINE_LENGTH

lcd_reset:
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
  rts

lcd_move:
  pha
  ora #%10000000
  jsr lcd_instruction
  pla
  rts

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
  jsr putchar
  pla
  and #$0f
  tax
  lda s_hex,x
  jsr putchar
  pla
  plx
  rts

putchar:
  jsr lcd_wait

  pha
  sta PORTB
  lda #RS        ; Set RS
  sta PORTA
  lda #(RS | E)  ; Send data to display
  sta PORTA
  lda #RS         ; Clear E bit
  sta PORTA
  pla
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

lcd_read:
  lda #ALL_IN ; Port B is input
  sta DDRB
  lda #(RW | RS)
  sta PORTA
  lda #(RW | RS | E)
  sta PORTA
  lda PORTB
  pha ; store PORTB on the stack
  lda #(RW | RS)
  sta PORTA
  lda #0
  sta PORTA
  lda #ALL_OUT
  sta DDRB
  pla ; return value of PORTB from above
  rts

s_hex:
  .asc "0123456789ABCDEF"
  .byte 0
