            ; Include kernel API entry points

#include include/macros.inc
#include include/bios.inc
#include include/kernel.inc
#include include/sysconfig.inc
#include ssd1305_lib.inc

            extrn upscale_pixie64x32

            org   2000h
start:      br    main

            ; Build information

            ever

            db    'See github.com/arhefner/Elfos-show for more info',0


            ; Main code starts here, check provided argument

main:       lda   ra                    ; move past any spaces
            smi   ' '
            lbz   main
            dec   ra                    ; move back to non-space character
            ldn   ra                    ; get byte
            lbnz  arg                   ; jump if argument given
            call  o_inmsg               ; otherwise display usage message
            db    'Usage: show filename',10,13,0
            ldi   $0a
            rtn                         ; and return to os

arg:        mov   rf, ra                ; copy argument address to rf

loop1:      lda   ra                    ; look for first less <= space
            smi   33
            lbdf  loop1
            dec   ra                    ; backup to char
            ldi   0                     ; need proper termination
            str   ra
            mov   rd, fildes            ; get file descriptor
            ldi   4                     ; flags for append
            plo   r7
            call  o_open                ; attempt to open file
            lbnf  opened                ; jump if file opened

            mov   rf, errmsg            ; point to error message
            call  o_msg                 ; display error message
            ldi   $0c
            rtn                         ; return to Elf/OS

opened:     mov   rd, fildes
            lda   rd                    ; check size
            bnz   size_err
            lda   rd
            bnz   size_err
            lda   rd                    ; copy size to rc
            phi   rc
            ldn   rd
            bnz   size_err
            plo   rc
            br    check

size_err:   mov   rf, sizeerr
            call  o_msg
            lbr   done

check:      ghi   rc
            smi   1
            lbz   pixie
            smi   3
            lbz   bitmap
            br    size_err

pixie:      mov   rd, fildes            ; seek to beginning of image
            ldi   0
            phi   r8
            plo   r8
            phi   r7
            plo   r7
            phi   rc
            plo   rc
            call  o_seek
            lbnf  read_pix

            mov   rf, seekerr
            call  o_msg
            lbr   done

read_pix:   mov   rd, fildes
            mov   rc, 256
            mov   rf, pix_buf
            call  o_read
            lbnf  upscale

            mov   rf, readerr
            call  o_msg
            lbr   done

upscale:    mov   r8, pix_buf
            mov   rf, frame_buf
            call  upscale_pixie64x32
            br    display

bitmap:     push  rc
            mov   rd, fildes            ; seek to beginning of image
            ldi   0
            phi   r8
            plo   r8
            phi   r7
            plo   r7
            phi   rc
            plo   rc
            call  o_seek
            pop   rc
            lbnf  read_bmp

            mov   rf, seekerr
            call  o_msg
            lbr   done

read_bmp:   mov   rd, fildes
            mov   rf, frame_buf
            call  o_read
            lbnf  display

            mov   rf, readerr
            call  o_msg
            lbr   done

display:    call  ssd1305_init

            mov   r8, frame_buf
            call  ssd1305_display

done:       mov   rd, fildes
            call  o_close

            ldi   0
            rtn

errmsg:     db   'File not found.',10,13,0
sizeerr:    db   'Invalid bitmap.',13,10,0
seekerr:    db   'Seek error.',13,10,0
readerr:    db   'File read error.',13,10,0

dta:        ds    512

dbg:        ds    15

.align      page

            ; Buffer to hold pixie image

pix_buf:    ds    256

            ; Buffer to hold image for display

frame_buf:  ds    1024

            ; File descriptor for loading image data

fildes:     db    0,0,0,0
            dw    dta
            db    0,0
            db    0
            db    0,0,0,0
            dw    0,0
            db    0,0,0,0

            end   start
