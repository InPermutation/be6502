; TMS9918A
VDP_VRAM = $4000
VDP_REG  = $4001

vdp_reset:
; Set TV background "Light yellow"
  lda #$0B
  sta VDP_REG
  lda #%10000111 ; Register 7
  sta VDP_REG
  rts
