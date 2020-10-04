; TMS9918A
VDP_VRAM = $4000
VDP_REG  = $4001

VDP_WRITE_VRAM_BIT = $40
VDP_REGISTER_BITS = $80

VDP_NAME_TABLE_BASE = $0000
VDP_PATTERN_TABLE_BASE = $0800

  .macro vdp_write_vram
  lda #<(\1)
  sta VDP_REG
  lda #(VDP_WRITE_VRAM_BIT | >\1)
  sta VDP_REG
  .endm

vdp_reset:
  jsr vdp_reg_reset
  jsr vdp_initialize_pattern_table
  jsr vdp_initialize_name_table
  jsr vdp_enable_display
  rts

vdp_reg_reset:
  pha
  phx

  ldx #0
vdp_reg_reset_loop:
  ; write value
  lda vdp_register_inits,x
  sta VDP_REG
  ; write reg #
  txa
  ora #VDP_REGISTER_BITS
  sta VDP_REG
  inx
  cpx #(vdp_end_register_inits - vdp_register_inits)
  bne vdp_reg_reset_loop
  plx
  pla
  rts

vdp_initialize_pattern_table:
  ; initialize the pattern table to the 16 hex digits
  pha
  phx
  vdp_write_vram VDP_PATTERN_TABLE_BASE
  ldx #0
vdp_pattern_table_loop:
  lda vdp_hex_digits,x
  sta VDP_VRAM
  inx
  cpx #(vdp_end_hex_digits - vdp_hex_digits)
  bne vdp_pattern_table_loop
  plx
  pla
  rts

vdp_initialize_name_table:
  ; initialize to "0123456789ABCDEF"
  pha
  phx
  vdp_write_vram VDP_NAME_TABLE_BASE
  lda #0
vdp_name_table_loop:
  sta VDP_VRAM
  ina
  cmp #$10
  bne vdp_name_table_loop
  plx
  pla
  rts

vdp_enable_display:
  pha
  lda vdp_register_1
  ora #%01000000 ; enable the active display
  sta VDP_REG
  lda #(VDP_REGISTER_BITS | 1)
  sta VDP_REG
  pla
  rts

vdp_register_inits:
vdp_register_0: .byte %00000000 ; 0  0  0  0  0  0  M3 EXTVDP
vdp_register_1: .byte %10010000 ;16k Bl IE M1 M2 0 Siz MAG
vdp_register_2: .byte $00       ; Name table base / $400. $00 = $0000
vdp_register_3: .byte $00       ; Color table base (currently unused)
vdp_register_4: .byte $01       ; Pattern table base / $800. $01 = $0800
vdp_register_5: .byte $00       ; Sprite attribute table base (currently unused)
vdp_register_6: .byte $00       ; Sprite pattern generator (currently unused)
vdp_register_7: .byte $B4       ; FG/BG. 4=>Dark blue, B=>Light yellow
vdp_end_register_inits:

vdp_hex_digits:
  .byte $70,$88,$98,$A8,$C8,$88,$70,$00 ; 0
  .byte $20,$60,$20,$20,$20,$20,$70,$00 ; 1
  .byte $70,$88,$08,$30,$40,$80,$F8,$00 ; 2
  .byte $F8,$08,$10,$30,$08,$88,$70,$00 ; 3
  .byte $10,$30,$50,$90,$F8,$10,$10,$00 ; 4
  .byte $F8,$80,$F0,$08,$08,$88,$70,$00 ; 5
  .byte $38,$40,$80,$F0,$88,$88,$70,$00 ; 6
  .byte $F8,$08,$10,$20,$40,$40,$40,$00 ; 7
  .byte $70,$88,$88,$70,$88,$88,$70,$00 ; 8
  .byte $70,$88,$88,$78,$08,$10,$E0,$00 ; 9
  .byte $20,$50,$88,$88,$F8,$88,$88,$00 ; A
  .byte $F0,$88,$88,$F0,$88,$88,$F0,$00 ; B
  .byte $70,$88,$80,$80,$80,$88,$70,$00 ; C
  .byte $F0,$88,$88,$88,$88,$88,$F0,$00 ; D
  .byte $F8,$80,$80,$F0,$80,$80,$F8,$00 ; E
  .byte $F8,$80,$80,$F0,$80,$80,$80,$00 ; F
vdp_end_hex_digits:
