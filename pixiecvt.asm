#include    include/macros.inc
#include    include/bios.inc

#define     NUM_PAGES       8
#define     BYTES_PER_PAGE  8
#define     PIXELS_PER_BYTE 8

            extrn   dbltbl

            proc upscale_pixie64x32

            glo     r8                  ; input buffer must be page-aligned
            lbnz    err

            ghi     r8                  ; set r8-rb to point to first 4 rows
            phi     r9                  ; of Pixie image buffer
            phi     ra
            phi     rb

            ldi     8
            plo     r9
            ldi     16
            plo     ra
            ldi     24
            plo     rb

            mov     r7, dbltbl          ; r7 -> row doubling table

            ldi     NUM_PAGES           ; for each OLED page
            stxd

page:       ldi     BYTES_PER_PAGE      ; for each byte on an input row
            plo     rc

byte:       ldi     PIXELS_PER_BYTE     ; for each bit in byte
            plo     rd

            ldi     0                   ; initialize output nybble
            phi     rd

            ldi     $80                 ; initialize mask to MSB
            phi     rc

bit:        ghi     rc                  ; r(X) -> mask
            str     r2

            ldn     r8                  ; get byte from row 1 input buffer
            and                         ; mask off current bit
            sdi     $0                  ; if bit = 1, DF = 0, else DF = 1
            ghi     rd
            shlc
            phi     rd

            ldn     r9                  ; get byte from row 2 input buffer
            and                         ; mask off current bit
            sdi     $0                  ; if bit = 1, DF = 0, else DF = 1
            ghi     rd
            shlc
            phi     rd

            ldn     ra                  ; get byte from row 3 input buffer
            and                         ; mask off current bit
            sdi     $0                  ; if bit = 1, DF = 0, else DF = 1
            ghi     rd
            shlc
            phi     rd

            ldn     rb                  ; get byte from row 4 input buffer
            and                         ; mask off current bit
            sdi     $0                  ; if bit = 1, DF = 0, else DF = 1
            ghi     rd
            shlc
            phi     rd

            ani     $0f
            str     r2                  ; use nybble in rd.1 to look up
            glo     r7                  ; doubled row byte in dbltbl
            ani     $f0
            add
            plo     r7
            ldn     r7
            str     rf                  ; store doubled value in output
            inc     rf
            str     rf                  ; store again to double column
            inc     rf

            ghi     rc                  ; move mask to next bit in byte
            shr
            phi     rc

            dec     rd                  ; go to next bit
            glo     rd
            lbnz    bit

            inc     r8
            inc     r9
            inc     ra
            inc     rb

            dec     rc                  ; go to next byte on row
            glo     rc
            lbnz    byte

            glo     r8
            adi     24
            plo     r8
            glo     r9
            adi     24
            plo     r9
            glo     ra
            adi     24
            plo     ra
            glo     rb
            adi     24
            plo     rb

            irx
            ldx
            smi     1
            lbz     done
            stxd
            lbr     page                ; go to next oled page

done:       clc
            lskp
err:        stc

            rtn

            endp

.link       .align  para

            proc    dbltbl

            db      $ff, $3f, $cf, $0f
            db      $f3, $33, $c3, $03
            db      $fc, $3c, $cc, $0c
            db      $f0, $30, $c0, $00

            endp