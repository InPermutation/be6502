; tty.s: a simple line-oriented console
; uses `getch` for input, assumes 20x4 LCD for output

; zero page addresses
TTY_PUTS = $10 ; pointer to the ASCIIZ to puts()
TTY_PUTS_HI = $11 ; high byte of TTY_PUTS
TTY_CURRENT_LINE = $12 ; pointer to TTY-internal buffer
TTY_CURRENT_LINE_HI = $13 ; always TTY_BUF_HI


; 3-page is a TTY buffer
TTY_BUF_HI = $03 ; use Page 3 as TTY buffer

tty_reset:
  pha
  lda #TTY_BUF_HI
  sta TTY_CURRENT_LINE_HI
  sta TTY_PUTS_HI
  stz TTY_CURRENT_LINE
  stz TTY_PUTS
  pla
  jmp tty_return

  .macro puts
  pha
  lda #<\1
  sta TTY_PUTS
  lda #>\1
  sta TTY_PUTS_HI
  jsr puts
  pla
  .endm

; Prints ASCIIZ string at (TTY_PUTS) to the console, followed by a newline
puts:
  pha
_puts_loop:
  lda (TTY_PUTS)
  beq _endl
  jsr putchar
  inc TTY_PUTS
  lda TTY_PUTS
  cmp #LCD_LINE_LENGTH
  bne _puts_loop
_endl:
  pla
  jmp tty_scroll

tty_scroll:
  pha
  lda #LCD_LINE1
  jsr lcd_move
  jsr copyline
  lda #LCD_LINE0
  jsr lcd_move
  jsr pasteline
  lda #LCD_LINE2
  jsr lcd_move
  jsr copyline
  lda #LCD_LINE1
  jsr lcd_move
  jsr pasteline
  lda #LCD_LINE3
  jsr lcd_move
  jsr copyline
  lda #LCD_LINE2
  jsr lcd_move
  jsr pasteline
  jsr tty_return
  jsr spaceline
  pla
  jmp tty_return

tty_return:
  pha
  lda #LCD_LINE3
  jsr lcd_move
  pla
  rts

copyline:
  pha
  phx
  stz TTY_CURRENT_LINE
  ldx #LCD_LINE_LENGTH
_copy1:
  jsr lcd_read
  sta (TTY_CURRENT_LINE)
  inc TTY_CURRENT_LINE
  dex
  bne _copy1
  plx
  pla
  rts

pasteline:
  pha
  phx
  stz TTY_CURRENT_LINE
  ldx #LCD_LINE_LENGTH
_paste1:
  lda (TTY_CURRENT_LINE)
  jsr putchar
  inc TTY_CURRENT_LINE
  dex
  bne _paste1
  plx
  pla
  rts

spaceline:
  pha
  phx
  ldx #LCD_LINE_LENGTH
  lda #' '
_space1:
  jsr putchar
  dex
  bne _space1
  plx
  pla
  rts
