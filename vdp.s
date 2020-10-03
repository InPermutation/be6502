; TMS9918A
VDP_VRAM = $4000
VDP_REG  = $4001

VDP_REGISTER_BITS = $80

vdp_reset:
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

