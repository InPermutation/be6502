; VIA ports
PORTB = $6000
PORTA = $6001
DDRB  = $6002
DDRA  = $6003

; VIA masks
DDRA_NORMAL = %01110000
ALL_IN = %00000000
ALL_OUT = %11111111

PS2_RESET_BIT_NUMBER = 10

; Zero page variable locations
KEY_BUF_WRITE = $00  ; producer pointer into KEY_BUF
KEY_BUF_WRITE_HI = $01 ; always KEY_BUF_HI
PS2_BIT_NUMBER = $02 ; which bit will we read next?
PS2_NEXT_BYTE = $03  ; storage to decode PS/2 bits into bytes
PS2_IGNORE_NEXT_CODE = $04
KEY_BUF_READ = $05 ; consumer pointer into KEY_BUF
KEY_BUF_READ_HI = $06 ; always KEY_BUF_HI


; 1-page is the stack
THE_STACK_HI = $01

; 2-page is a circular buffer of the raw PS/2 bits (#0 or #1)
KEY_BUF_HI = $02      ; use Page 2 as circular buffer of PS/2 bits

E = %00010000
RW = %01000000
RS = %00100000

  .org $8000
reset:
  ; initialize stack pointer to $01FF
  ldx #$ff
  txs

  stz KEY_BUF_WRITE
  stz PS2_NEXT_BYTE
  stz PS2_IGNORE_NEXT_CODE
  stz KEY_BUF_READ

  lda #PS2_RESET_BIT_NUMBER
  sta PS2_BIT_NUMBER

  lda #KEY_BUF_HI
  sta KEY_BUF_WRITE_HI
  sta KEY_BUF_READ_HI


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

loop:

ps2_check_bit:
  lda KEY_BUF_READ
  cmp KEY_BUF_WRITE
  beq loop
  lda (KEY_BUF_READ)
  inc KEY_BUF_READ
  jsr print_ps2_key
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


print_ps2_key:
  bit PS2_IGNORE_NEXT_CODE
  bmi code_ignored

  ; A is scan code.
  cmp #$F0
  beq ignore_next

  cmp #$5F
  bpl too_high

  tax
  lda ps2_scan_codes,x
  jsr print_char
  rts

too_high:
  rts
ignore_next:
  lda #$FF
  sta PS2_IGNORE_NEXT_CODE
  rts

code_ignored:
  stz PS2_IGNORE_NEXT_CODE
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

  .align 8
ps2_scan_codes:
  ;       0123456789ABCDEF
  .asc "??????????????`?" ; 0
  .asc "?????Q1???ZSAW2?" ; 1
  .asc "?CXDE43?? VFTR5?" ; 2
  .asc "?NBHGY6???MJU78?" ; 3
  .asc "?,KIO09??./L;P-?" ; 4
  .asc "??'?[=?????]?\??" ; 5
s_hex:
  .asc "0123456789ABCDEF"

irq_brk:
  pha
; Clear display
  lda #%00000001 ; Clear display
  jsr lcd_instruction

  lda KEY_BUF_WRITE
  jsr print_hex_byte
  lda #"/"
  jsr print_char
  lda KEY_BUF_READ
  jsr print_hex_byte
  lda #" "
  jsr print_char
  lda PS2_NEXT_BYTE
  jsr print_hex_byte
  lda #" "
  jsr print_char
  lda PS2_BIT_NUMBER
  jsr print_hex_byte

  pla
  rti

nmi:
  ; The PS/2 keyboard protocol is clocked by the keyboard itself
  ; Tie the CLOCK line to the NMI with a pull-up resistor, and the DATA line
  ; to the VIA, PORTA, bit 0.
  ; PS/2 clock speed is expected to be somewhere between 10kHz-16.7kHz
  ; If our CPU is running at 1MHz, that gives us 59.88 cycles per bit.
  ; The data is only valid for the first half of those, and we really
  ; should be reading in the middle of the clock cycle for accuracy's sake.
  ; That means we have about 15 cycles to read PORTA,
  ; and another few dozen to get outta here.
  ; The WDC 65C02 supposedly takes 6 cycles to process an interrupt,
  ; and will only process an interrupt at the beginning of an instruction,
  ; so we're already 8-14 cycles in. Hurry!!

  ;               Cycles  +  ==
  pha ;                   3  17
  lda PORTA ;             4  23

  ; PS2_BIT_NUMBER will be decremented to the following values:
  ; START BIT -> 9
  ; Bit 0     -> 8
  ; Bit 1     -> 7
  ; Bit 2     -> 6
  ; Bit 3     -> 5
  ; Bit 4     -> 4
  ; Bit 5     -> 3
  ; Bit 6     -> 2
  ; Bit 7     -> 1
  ; PARITY BIT-> 0
  ; STOP BIT  -> -1

  ; 0 and -1 can be tested by the BEQ and BMI branches.
  dec PS2_BIT_NUMBER ;    5  28
  beq store_ps2_byte ;    2  30
  bmi reset_bit_number ;  2  32

  ; Otherwise, rotate into the PS2_NEXT_BYTE
  ror ;                   2  34
  ror PS2_NEXT_BYTE ;     5  39
  pla               ;     4  43
  rti               ;     6  49

store_ps2_byte:     ;     1  31
  lda PS2_NEXT_BYTE ;     3  34
  sta (KEY_BUF_WRITE) ;   6  40
  inc KEY_BUF_WRITE ;     5  45
  pla               ;     4  49
  rti               ;     6  55

reset_bit_number:   ;     1  33
  lda #PS2_RESET_BIT_NUMBER ; 2 35
  sta PS2_BIT_NUMBER ;    3  39
  pla ;                   4  43
  rti ;                   6  49

; Vector locations
  .org $fffa
  .word nmi
  .word reset
  .word irq_brk
