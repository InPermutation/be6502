  .org $8000
  .include 'ps2.s'
  .include 'via.s'
  .include 'lcd.s'
  .include 'vdp.s'
  .include 'tty.s'
  .include 'monitor.s'

SNAKE_PAT = $7F
SNAKE_INIT_X = 20
SNAKE_INIT_Y = 10
HEAD = $50
HEAD_HI = $51

irq:
  pha

  lda VDP_REG ; read VDP status to clear 'F', the interrupt flag.

  ; Move the snake to the right, and set the VDP address register

  ; Low byte
  clc
  lda HEAD
  adc #1
  sta HEAD
  ; Also write low byte to VRAM address register
  sta VDP_REG

  ; High byte
  lda HEAD_HI
  adc #0
  sta HEAD_HI
  ; Also write high byte, with WRITE bit set, to VRAM address register
  ORA #VDP_WRITE_VRAM_BIT
  sta VDP_REG

  ; Plop a new snake head into VRAM
  lda #SNAKE_PAT
  sta VDP_VRAM

  pla

  rti

reset:
  sei
  ; initialize stack pointer to $01FF
  ldx #$ff
  txs

  jsr ps2_reset
  jsr via_reset
  jsr lcd_reset
  jsr vdp_reset
  jsr tty_reset

.clear_board:
  vdp_write_vram VDP_NAME_TABLE_BASE
.top_border:
  lda #3
  sta VDP_VRAM
  ldx #(VDP_COLS - 2)
  lda #0
.top_border_horiz:
  sta VDP_VRAM
  dex
  bne .top_border_horiz
  lda #2
  sta VDP_VRAM

  ldy #(VDP_ROWS - 2)
.mid_board:
  lda #1
  sta VDP_VRAM
  ldx #(VDP_COLS - 2)
  lda #' '
.mid_board_horiz
  sta VDP_VRAM
  dex
  bne .mid_board_horiz
  lda #1
  sta VDP_VRAM
  dey
  bne .mid_board

.bottom_border:
  lda #5
  sta VDP_VRAM
  ldx #(VDP_COLS - 2)
  lda #0
.bottom_border_horiz:
  sta VDP_VRAM
  dex
  bne .bottom_border_horiz
  lda #4
  sta VDP_VRAM

.snake:
  vdp_write_vram (VDP_NAME_TABLE_BASE + (5 * VDP_COLS) + 30)
  lda #'*'
  sta VDP_VRAM

  vdp_write_vram (VDP_NAME_TABLE_BASE + (10 * VDP_COLS) + 20)
  lda #SNAKE_PAT
  sta VDP_VRAM
  sta VDP_VRAM
  ; store the snake head's current location in HEAD (2 bytes)
  lda #<(VDP_NAME_TABLE_BASE + (SNAKE_INIT_Y * VDP_COLS) + SNAKE_INIT_X + 1)
  sta HEAD

  lda #>(VDP_NAME_TABLE_BASE + (SNAKE_INIT_Y * VDP_COLS) + SNAKE_INIT_X + 1)
  sta HEAD_HI

  cli

loop:
  wai
  bra loop

; Vector locations
  .org $fffa
  .word ps2_nmi
  .word reset
  .word irq
