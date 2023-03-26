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
SNAKE_DIR = $52
SNAKE_DIR_HI = $53
DELAY = $54
RNG_SEED = $55
EMPTY = $56
EMPTY_HI = $57

DELAY_VAL = 10

JOY_UP = 1
JOY_DOWN = 2
JOY_LEFT = 4
JOY_RIGHT = 8
JOY_TRIG = 16

irq:
  pha

  lda VDP_REG ; read VDP status to clear 'F', the interrupt flag.

  ; Check the joystick
.check_right:
  lda #JOY_RIGHT
  and PORTA
  bne .check_down
  lda #1
  sta SNAKE_DIR
  stz SNAKE_DIR_HI
  bra .wait_delay

.check_down:
  lda #JOY_DOWN
  and PORTA
  bne .check_left
  lda #40
  sta SNAKE_DIR
  stz SNAKE_DIR_HI
  bra .wait_delay

.check_left:
  lda #JOY_LEFT
  and PORTA
  bne .check_up
  lda #-1
  sta SNAKE_DIR
  sta SNAKE_DIR_HI
  bra .wait_delay

.check_up:
  lda #JOY_UP
  and PORTA
  bne .wait_delay
  lda #-40
  sta SNAKE_DIR
  lda #-1
  sta SNAKE_DIR_HI
  bra .wait_delay

.wait_delay
  ; Wait for delay
  dec DELAY
  bne .exit
  lda #DELAY_VAL
  sta DELAY


.move_snake:
  ; Move the snake in the SNAKE_DIR

  ; Low byte
  clc
  lda HEAD
  adc SNAKE_DIR
  sta HEAD

  ; High byte
  lda HEAD_HI
  adc SNAKE_DIR_HI
  sta HEAD_HI

  ; Set up for a VRAM read to HEAD
  lda HEAD
  sta VDP_REG
  lda HEAD_HI
  sta VDP_REG

  ; Compare with ASCII space character
  lda VDP_VRAM
  cmp #' '
  beq .continue

  cmp #'*'
  beq .eat_apple

  jmp game_over

.eat_apple:
  jsr rand_8
  sta EMPTY
  jsr rand_8
  and #3
  sta EMPTY_HI
  cmp #3
  bne .valid_vaddr
  lda EMPTY
  cmp #$C0
  bcs .eat_apple ; try again
.valid_vaddr:
  lda EMPTY
  sta VDP_REG
  lda EMPTY_HI
  sta VDP_REG
  lda VDP_VRAM
  cmp #' '
  bne .eat_apple
.empty_vaddr
  lda EMPTY
  sta VDP_REG
  lda EMPTY_HI
  ora #VDP_WRITE_VRAM_BIT
  sta VDP_REG
  lda #'*'
  sta VDP_VRAM

  ; Set up for a VRAM write to HEAD
.continue:
  lda HEAD
  sta VDP_REG
  lda HEAD_HI
  ORA #VDP_WRITE_VRAM_BIT
  sta VDP_REG

  ; Plop a new snake head into VRAM
  lda #SNAKE_PAT
  sta VDP_VRAM

.exit:
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

  lda #1
  sta SNAKE_DIR
  stz SNAKE_DIR_HI

  lda #DELAY_VAL
  sta DELAY

  lda #'H'
  jsr putchar

.seed_rng:
  lda RNG_SEED
  bne .already_seeded
  lda #42
  sta RNG_SEED
.already_seeded:

  cli

loop:
  wai
  bra loop

rand_8:
  lda RNG_SEED
  asl
  bcc .no_eor

  eor #$CF
.no_eor:
  sta RNG_SEED
  rts

game_over:
  ; Game over - write an X and wait for trigger, then restart
  lda HEAD
  sta VDP_REG
  lda HEAD_HI
  ORA #VDP_WRITE_VRAM_BIT
  sta VDP_REG
  lda #'X'
  sta VDP_VRAM
.wait_for_trig:
  lda #JOY_TRIG
  and PORTA
  bne .wait_for_trig
  jmp reset

; Vector locations
  .org $fffa
  .word ps2_nmi
  .word reset
  .word irq
