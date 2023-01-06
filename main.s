  .org $8000
  .include 'ps2.s'
  .include 'via.s'
  .include 'lcd.s'
  .include 'vdp.s'
  .include 'tty.s'
  .include 'monitor.s'

irq:
  pha

  lda VDP_REG ; read VDP status to clear 'F', the interrupt flag.

  vdp_write_vram (VDP_NAME_TABLE_BASE + VDP_COLS + 1)

  pla
  sta VDP_VRAM
  inc

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
  lda #$7F
  sta VDP_VRAM
  sta VDP_VRAM

  cli

loop:
  wai
  bra loop

; Vector locations
  .org $fffa
  .word ps2_nmi
  .word reset
  .word irq
