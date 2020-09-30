; tty.s: a simple line-oriented console
; uses `getch` for input, assumes 20x4 LCD for output

; zero page addresses
TTY_PUTS = $10 ; pointer to the ASCIIZ to puts()
TTY_PUTS_HI = $11 ; high byte of TTY_PUTS
TTY_CURRENT_LINE = $12 ; pointer to TTY-internal buffer
TTY_CURRENT_LINE_HI = $13 ; always TTY_BUF_HI
TTY_READLINE = $14 ; pointer to TTY readline buffer
TTY_READLINE_HI = $15


; 3-page is a TTY buffer
TTY_BUF_HI = $03 ; use Page 3 as TTY buffer
TTY_READBUF_HI = $04 ; use Page 4 as readline buffer

tty_reset:
  pha
  lda #TTY_BUF_HI
  sta TTY_CURRENT_LINE_HI
  sta TTY_PUTS_HI
  stz TTY_CURRENT_LINE
  stz TTY_PUTS
  lda #TTY_READBUF_HI
  sta TTY_READLINE_HI
  stz TTY_READLINE
  pla
  jmp tty_return

readline:
  pha
  jsr tty_return
  jsr spaceline
  jsr tty_return

  lda #'>'
  jsr putchar
  lda #' '
  jsr putchar

  stz TTY_READLINE
readline_loop:
  jsr getch
  cmp #'n'
  beq readline_complete
  sta (TTY_READLINE)
  jsr putchar
  inc TTY_READLINE
  lda TTY_READLINE
  ina ; #'>'  these are the readline prompt
  ina ; #' '
  cmp #LCD_LINE_LENGTH
  bne readline_loop
readline_complete:
  lda #0
  sta (TTY_READLINE)
  jsr tty_scroll
  pla
  rts


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
  phx
  ldx #0
_puts_loop:
  lda (TTY_PUTS)
  beq _endl
  jsr putchar
  inc TTY_PUTS
  inx
  cpx #LCD_LINE_LENGTH
  bne _puts_loop
_endl:
  plx
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
