; zero page addresses
MONITOR_LO = $20 ; store an address here
MONITOR_HI = $21
MONITOR_DATA = $22
MONITOR_DATA_HI = $23

monitor:
  puts s_reset
  puts s_reset_2
  puts s_reset_3
monitor_loop:
  jsr readline
  lda TTY_READLINE
  jsr print_hex_byte
  puts s_ok

  jmp monitor_loop

s_reset: .asciiz "0000<CR>->inspect"
s_reset_2: .asciiz "0000:12<CR>->set"
s_reset_3: .asciiz "0000R<CR>->run"
s_ok: .asciiz " chars read."

