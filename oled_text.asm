#include    include/macros.inc
#include    include/bios.inc
#include    include/sysconfig.inc
#include    oled.inc

            extrn   oled_text_set_pos

.link       .align  page

            proc oled_text_draw_string

          #if SPI_GROUP
            sex     r3
            out     EXP_PORT
            db      SPI_GROUP
            sex     r2
          #endif

            inc     r8
            inc     r8

            lda     r8                  ; r9 = font pointer
            phi     r9
            ldn     r8
            adi     4                   ; skip signature
            plo     r9
            dec     r8                  ; restore r8 = descriptor
            dec     r8
            dec     r8

            lda     r9
            bz      err                 ; no proportional fonts here

            phi     r7                  ; r7.1 = font width
            lda     r9
            phi     rc                  ; rc.1 = font height
            lda     r9
            phi     rb                  ; rb.1 = first font char
            lda     r9
            plo     rb                  ; rb.0 = last font char

            glo     r9                  ; skip proportional info
            adi     5
            plo     r9
            ghi     r9
            adci    0
            phi     r9

next:       lda     ra
            bz      done

            str     r2                  ; check if c > last
            glo     rb
            sm
            bnf     err
            ghi     rb                  ; check if c < first
            sd
            bnf     err
            plo     rd
            ldi     0
            phi     rd                  ; rd = character index
            phi     rf
            ghi     r7
            plo     rf                  ; rf = width

            push    rb                  ; save first & last

            call    f_mul16             ; rb = index * width

            ghi     rc                  ; get height
            xri     1
            bz      single              ; short circuit if height = 1

            mov     rd, rb              ; rd = index * width
            ldi     0
            phi     rf
            ghi     rc
            plo     rf                  ; rf = height
            call    f_mul16             ; rb = index * width * height

single:     ghi     rc
            plo     rc

            glo     r9                  ; set r0 to point to the glyph
            str     r2
            glo     rb
            add
            plo     r0
            ghi     r9
            str     r2
            ghi     rb
            adc
            phi     r0

            pop     rb                  ; restore first & last

write:      ghi     r7                  ; set DMA length to width
            ori     $80
            str     r2
            out     SPI_CTL
            dec     r2

            ldi     $47                 ; trigger DMA
            str     r2
            out     SPI_CTL
            dec     r2

            sex     r3

            out     SPI_CTL
            db      DATA

            sex     r2

            push    ra

            dec     rc
            glo     rc
            bnz     nextpage

            lda     r8
            str     r2
            ghi     r7
            add
            phi     ra
            ghi     rc
            smi     1
            str     r2
            ldn     r8
            sm
            plo     ra
            dec     r8
            call    oled_text_set_pos

            pop     ra
            br      next

nextpage:   lda     r8
            phi     ra
            ldn     r8
            adi     1
            plo     ra
            dec     r8
            call    oled_text_set_pos

            pop     ra
            br      write

done:       clc
            lskp
err:        stc

            sex     r3

            out     SPI_CTL
            db      IDLE

          #if SPI_GROUP
            out     EXP_PORT
            db      NO_GROUP
          #endif

            sex     r2

            rtn

            endp


            proc    oled_text_set_pos

            sex     r3

          #if SPI_GROUP
            out     EXP_PORT
            db      SPI_GROUP
          #endif

            out     SPI_CTL
            db      COMMAND

            sex     r2

            ghi     ra
            str     r8
            inc     r8

            glo     ra                  ; get new y
            str     r8
            dec     r8                  ; restore r8
            ani     $07
            str     r2
            ldi     $b0
            or                          ; D = $B0 | (y & $07)

            str     r2
            out     SPI_DATA
            dec     r2

            ghi     ra
            shr
            shr
            shr
            shr
            ani     $0f
            str     r2
            ldi     $10
            or                          ; D = $10 | (x >> 4)

            str     r2
            out     SPI_DATA
            dec     r2

            ghi     ra
            ani     $0f                 ; D = x & $0f

            str     r2
            out     SPI_DATA
            dec     r2

            sex     r3

            out     SPI_CTL
            db      IDLE

          #if SPI_GROUP
            out     EXP_PORT
            db      NO_GROUP
          #endif

            sex     r2

            rtn

            endp