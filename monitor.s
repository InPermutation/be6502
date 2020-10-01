; zero page addresses
MONITOR = $20 ; store a word read from TTY_READLINE here
MONITOR_HI = $21
MONITOR_DATA = $22
MONITOR_DATA_HI = $23

monitor:
  puts s_reset
  puts s_reset_2
  puts s_reset_3
monitor_loop:
  jsr readline
  stz TTY_READLINE
  jsr monitor_read_word
  lda MONITOR_HI
  jsr print_hex_byte
  lda MONITOR
  jsr print_hex_byte
  jsr tty_scroll
  jmp monitor_loop

monitor_read_word:
  pha
  phx
  stz MONITOR
  stz MONITOR_HI
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
  asl MONITOR
  rol MONITOR_HI
  .endr
  txa
  clc
  adc MONITOR
  sta MONITOR
  inc TTY_READLINE
  jmp _read_next_char
_nomatch:
  plx
  pla
  rts

  .align 8
s_reset: .asciiz "0000<CR>->inspect"
s_reset_2: .asciiz "0000:12<CR>->set"
s_reset_3: .asciiz "0000R<CR>->run"

