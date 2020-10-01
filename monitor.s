; zero page addresses
MONITOR_READ = $20 ; store a word read from TTY_READLINE here
MONITOR_READ_HI = $21
MONITOR_WRITE = $22
MONITOR_WRITE_HI = $23

monitor:
  puts s_reset
  puts s_reset_2
  puts s_reset_3
monitor_loop:
  jsr readline
  stz TTY_READLINE
  jsr monitor_read_word
  lda MONITOR_READ_HI
  jsr print_hex_byte
  lda MONITOR_READ
  jsr print_hex_byte
  lda #':'
  jsr putchar
  lda #' '
  jsr putchar
  lda (MONITOR_READ)
  jsr print_hex_byte
  lda (TTY_READLINE)
  cmp #'='
  beq monitor_write_mem
  cmp #'R'
  beq monitor_run
_monitor_done:
  jsr tty_scroll
  jmp monitor_loop

monitor_run:
  jsr putchar
  jsr tty_scroll
  jmp (MONITOR_READ)

monitor_write_mem:
  inc TTY_READLINE
  lda MONITOR_READ
  sta MONITOR_WRITE
  lda MONITOR_READ_HI
  sta MONITOR_WRITE_HI
  jsr monitor_read_word
  lda MONITOR_READ
  sta (MONITOR_WRITE)
  jmp _monitor_done

monitor_read_word:
  pha
  phx
  stz MONITOR_READ
  stz MONITOR_READ_HI
_read_next_char:
  lda (TTY_READLINE)
  ldx #0
_hex_loop:
  cpx #$10
  beq _nomatch
  cmp s_hex,x
  beq _match
  inx
  jmp _hex_loop
_match:
_shift_nibble:
  .rept 4
  asl MONITOR_READ
  rol MONITOR_READ_HI
  .endr
  txa
  clc
  adc MONITOR_READ
  sta MONITOR_READ
  inc TTY_READLINE
  jmp _read_next_char
_nomatch:
  plx
  pla
  rts

  .align 8
s_reset: .asciiz "0000<CR>->inspect"
s_reset_2: .asciiz "0000=12<CR>->set"
s_reset_3: .asciiz "0000R<CR>->run"

