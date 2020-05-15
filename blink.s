  .org $8000
reset:
  lda #$ff
  sta $6002

loop:
  lda #$55
  sta $6000

  lda #$aa
  sta $6000

  jmp loop

  .org $fffc
  .word reset
  .word $0000
