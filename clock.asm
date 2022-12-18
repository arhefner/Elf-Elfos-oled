            ; Include kernel API entry points

#include include/macros.inc
#include include/bios.inc
#include include/kernel.inc
#include include/sysconfig.inc
#include ssd1305_lib.inc

#define  RTC_REG         20h

#define  CLEAR_INT       10h

#define  RATE_64HZ       10h
#define  RATE_1_PER_SEC  14h
#define  RATE_1_PER_MIN  18h
#define  RATE_1_PER_HR   1ch

#define  INT_ENABLE      10h
#define  INT_MASK        11h

#define  PULSE_MODE      10h
#define  INT_MODE        12h

#define  RTC_INT_ENABLE  41h
#define  RTC_INT_DISABLE 40h

            extrn   oled_text_draw_string
            extrn   oled_text_set_pos
            extrn   printrd

            org     2000h
start:      br      main

            ; Build information

            ever

            db    'See github.com/arhefner/Elfos-clock for more info',0


            ; Main code starts here, check provided argument

main:       lda     ra                  ; move past any spaces
            smi     ' '
            lbz     main
            dec     ra                  ; move back to non-space character
            ldn     ra                  ; get byte
            lbnz    arg                 ; jump if argument given
            call    o_inmsg             ; otherwise display usage message
            db      'Usage: clock fontname',10,13,0
            rtn                         ; and return to os

arg:        mov     rf, ra              ; copy argument address to rf

loop1:      lda     ra                  ; look for first less <= space
            smi     33
            lbdf    loop1
            dec     ra                  ; backup to char
            ldi     0                   ; need proper termination
            str     ra
            mov     rd, fildes          ; get file descriptor
            ldi     4                   ; flags for append
            plo     r7
            call    o_open              ; attempt to open file
            lbnf    opened              ; jump if file opened

            mov     rf, fileerr         ; point to error message
            call    o_msg               ; display error message
            rtn                         ; return to Elf/OS

opened:     call    ssd1305_init
            call    ssd1305_clear

            mov     rd, fildes
            lda     rd                  ; check size <= 64K
            bnz     size_err
            lda     rd
            bnz     size_err
            lda     rd                  ; copy size to rc
            phi     rc
            ldn     rd
            plo     rc
            br      alloc

size_err:   mov     rf, fonterr
            call    o_msg
            lbr     done

alloc:      ldi     $02                 ; allocate permanent block of memory
            plo     r7                  ; to hold font
            ldi     0
            phi     r7
            call    o_alloc
            lbnf    load_font

            mov     rf, allocerr
            call    o_msg
            lbr     done

load_font:  mov     rd, termdes         ; copy font pointer to termdes
            inc     rd                  ; skip coordinates
            inc     rd
            ghi     rf
            str     rd
            inc     rd
            glo     rf
            str     rd

            push    rc
            mov     rd, fildes          ; seek to beginning of font
            ldi     0
            phi     r8
            plo     r8
            phi     r7
            plo     r7
            phi     rc
            plo     rc
            call    o_seek
            pop     rc
            lbnf    read

            mov     rf, seekerr
            call    o_msg
            lbr     done

read:       mov     rd, fildes
            call    o_read
            lbnf    close

            mov     rf, readerr
            call    o_msg
            lbr     done

close:      mov     rd, fildes
            call    o_close

            mov     rd, termdes         ; load font address into rf
            inc     rd
            inc     rd
            lda     rd
            phi     rf
            lda     rd
            plo     rf

            mov     rd, fontsig         ; check font signature
            call    f_strcmp
            bz      clock

            mov     rf, fonterr
            call    o_msg
            lbr     done

clock:      mov   r1, introu

;            ldi   64
            ldi   1
            plo   r7

            sex   r3

          #if RTC_GROUP
            out   EXP_PORT              ; make sure default expander group
            db    RTC_GROUP
          #endif

            out   RTC_PORT
            db    RTC_REG | 0eh
            out   RTC_PORT
;            db    RATE_64HZ | INT_MODE | INT_ENABLE
            db    RATE_1_PER_SEC | INT_MODE | INT_ENABLE

            out   RTC_PORT
            db    RTC_INT_ENABLE

          #if RTC_GROUP
            out   EXP_PORT              ; make sure default expander group
            db    NO_GROUP
          #endif

            ret
            db    23h

wait:       b4    done
            glo   r7
            bnz   wait

;            ldi   64
            ldi   1
            plo   r7

            mov   rf, time_buf
            call  f_gettod

            mov   ra, time_buf
            inc   ra
            inc   ra
            inc   ra

            mov   rf, output
            ldn   ra
            smi   12
            lsdf
            ldn   ra
            nop
            str   ra
            smi   10
            bdf   hour
            ldi   '0'
            str   rf
            inc   rf
hour:       ldi   0
            phi   rd
            lda   ra
            plo   rd
            call  f_uintout

            ldi   ':'
            str   rf
            inc   rf

            ldn   ra
            smi   10
            bdf   min
            ldi   '0'
            str   rf
            inc   rf
min:        ldi   0
            phi   rd
            lda   ra
            plo   rd
            call  f_uintout

            ldi   ':'
            str   rf
            inc   rf

            ldn   ra
            smi   10
            bdf   sec
            ldi   '0'
            str   rf
            inc   rf
sec:        ldi   0
            phi   rd
            lda   ra
            plo   rd
            call  f_uintout

            ldi   0
            str   rf

print:      mov     r8, termdes
            mov     ra, $0002
            call    oled_text_set_pos

            mov     ra, output
            call    oled_text_draw_string

            lbr     wait

done:       sex   r3
            dis
            db    23h

            sex   r3

          #if RTC_GROUP
            out   EXP_PORT              ; make sure default expander group
            db    RTC_GROUP
          #endif

            out   RTC_PORT
            db    RTC_INT_DISABLE
            out   RTC_PORT
            db    INT_MASK
            out   RTC_PORT
            db    CLEAR_INT

          #if RTC_GROUP
            out   EXP_PORT              ; make sure default expander group
            db    NO_GROUP
          #endif

            sex   r2

            ldi   0
            rtn


exiti:      ret

introu:     dec   r2
            sav
            dec   r2
            stxd
            shrc
            stxd

            sex   r1
            out   RTC_PORT
            db    RTC_REG | 0dh
            out   RTC_PORT
            db    CLEAR_INT
            sex   r2

            dec   r7

exit:       inc   r2
            lda   r2
            shl
            lda   r2
            br    exiti

fileerr:    db      'File not found.',10,13,0
seekerr:    db      'Seek error.',13,10,0
fonterr:    db      'Invalid font file.',13,10,0
allocerr:   db      'Not enough memory.',13,10,0
readerr:    db      'Read error.',13,10,0

fontsig:    db      'FON',0

            ; File descriptor for loading image data

fildes:     db      0,0,0,0
            dw      dta
            db      0,0
            db      0
            db      0,0,0,0
            dw      0,0
            db      0,0,0,0

dta:        ds      512

dbg:        ds      10

termdes:    db      0,0
            dw      0

time_buf:   ds    10
output:     ds    20

            end     start
