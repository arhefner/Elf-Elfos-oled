            ; Include kernel API entry points

#include include/macros.inc
#include include/bios.inc
#include include/kernel.inc
#include ssd1305_lib.inc

            extrn   oled_text_draw_string
            extrn   oled_text_set_pos
            extrn   printrd

            org     2000h
start:      br      main


            ; Build information

            ever

            db    'See github.com/arhefner/Elfos-font for more info',0


            ; Main code starts here, check provided argument

main:       lda     ra                  ; move past any spaces
            smi     ' '
            lbz     main
            dec     ra                  ; move back to non-space character
            ldn     ra                  ; get byte
            lbnz    arg                 ; jump if argument given
            call    o_inmsg             ; otherwise display usage message
            db      'Usage: font filename',10,13,0
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
            lbnf    display

            mov     rf, readerr
            call    o_msg
            lbr     done

display:    mov     rd, termdes         ; load font address into rf
            inc     rd
            inc     rd
            lda     rd
            phi     rf
            lda     rd
            plo     rf

            mov     rd, fontsig         ; check font signature
            call    f_strcmp
            bz      print

            mov     rf, fonterr
            call    o_msg

print:      mov     r8, termdes
            mov     ra, $0800
            call    oled_text_set_pos

            mov     ra, message
            call    oled_text_draw_string

time:       mov     rf, time_buf
            call    f_gettod

            mov     ra, time_buf
            inc     ra
            inc     ra
            inc     ra

            mov     rf, output
            ldi     0
            phi     rd
            lda     ra
            plo     rd
            call    f_uintout

            ldi     ':'
            str     rf
            inc     rf

            ldi     0
            phi     rd
            lda     ra
            plo     rd
            call    f_uintout

            ldi     ':'
            str     rf
            inc     rf

            ldi     0
            phi     rd
            lda     ra
            plo     rd
            call    f_uintout

            ldi     0
            str     rf

            mov     r8, termdes
            mov     ra, $0002
            call    oled_text_set_pos

            mov     ra, output
            call    oled_text_draw_string

done:       mov     rd, fildes
            call    o_close

            rtn

fileerr:    db      'File not found.',10,13,0
seekerr:    db      'Seek error.',13,10,0
fonterr:    db      'Invalid font file.',13,10,0
allocerr:   db      'Not enough memory.',13,10,0
readerr:    db      'Read error.',13,10,0
disperr:    db      'Error printing.',13,10,0

message:    db      'Hello, world!',0

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
