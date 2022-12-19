#include    include/macros.inc
#include    include/bios.inc
#include    ssd1305_lib.inc

            extrn   upscale_pixie64x32

stksize:    equ     128

            org     $2000

start:      mov     r2, stkptr
            mov     r6, main
            lbr     f_initcall

main:       call    f_setbd

            call    f_inmsg
            db      "Pixie upscale test program.",13,10,0

            call    ssd1305_init
            call    ssd1305_clear

            mov     r8, starship
            mov     rf, framebuf
            call    upscale_pixie64x32

            mov     r8, framebuf
            call    ssd1305_display

            sep     r1
            idl

.align      page

starship:   db      $90, $b1, $b2, $b3, $b4, $f8, $2e, $a3
            db      $f8, $3f, $a2, $f8, $11, $a1, $d3, $72
            db      $70, $22, $78, $22, $52, $c4, $c4, $c4
            db      $f8, $11, $b0, $f8, $00, $a0, $80, $e2
            db      $e2, $20, $a0, $e2, $20, $a0, $e2, $20
            db      $a0, $3c, $1e, $30, $0f, $e2, $69, $3f
            db      $2f, $6c, $a4, $37, $33, $3f, $35, $6c
            db      $54, $14, $30, $33, $00, $69, $23, $69
            db      $00, $00, $00, $00, $00, $00, $00, $00
            db      $00, $00, $00, $00, $00, $00, $00, $00
            db      $7b, $de, $db, $de, $00, $00, $00, $00
            db      $4a, $50, $da, $52, $00, $00, $00, $00
            db      $42, $5e, $ab, $d0, $00, $00, $00, $00
            db      $4a, $42, $8a, $52, $00, $00, $00, $00
            db      $7b, $de, $8a, $5e, $00, $00, $00, $00
            db      $00, $00, $00, $00, $00, $00, $00, $00
            db      $00, $00, $00, $00, $00, $00, $07, $e0
            db      $00, $00, $00, $00, $ff, $ff, $ff, $ff
            db      $00, $06, $00, $01, $00, $00, $00, $01
            db      $00, $7f, $e0, $01, $00, $00, $00, $02
            db      $7f, $c0, $3f, $e0, $fc, $ff, $ff, $fe
            db      $40, $0f, $00, $10, $04, $80, $00, $00
            db      $7f, $c0, $3f, $e0, $04, $80, $00, $00
            db      $00, $3f, $d0, $40, $04, $80, $00, $00
            db      $00, $0f, $08, $20, $04, $80, $7a, $1e
            db      $00, $00, $07, $90, $04, $80, $42, $10
            db      $00, $00, $18, $7f, $fc, $f0, $72, $1c
            db      $00, $00, $30, $00, $00, $10, $42, $10
            db      $00, $00, $73, $fc, $00, $10, $7b, $d0
            db      $00, $00, $30, $00, $3f, $f0, $00, $00
            db      $00, $00, $18, $0f, $c0, $00, $00, $00
            db      $00, $00, $07, $f0, $00, $00, $00, $00

framebuf:   ds      1024

stack:      ds      stksize
stkptr:     equ     $-1

            end     start