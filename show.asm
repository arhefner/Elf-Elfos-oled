            ; Include kernel API entry points

#include include/macros.inc
#include include/bios.inc
#include include/kernel.inc
#include include/sysconfig.inc
#include ssd1305_lib.inc

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
            ldi   0                     ; flags for open
            plo   r7
            call  o_open                ; attempt to open file
            lbnf  opened                ; jump if file opened
            mov   rf, errmsg            ; point to error message
            call  o_msg                 ; display error message
            ldi   $0c
            rtn                         ; return to Elf/OS

opened:     mov   rd, fildes
            mov   rc, 1024
            mov   rf, frame_buf
            call  o_read
            lbnf  display

readerr:    call  o_inmsg
            db    'File read error.',13,10,0
            lbr   done

display:    call  ssd1305_init

            mov   r8, frame_buf
            call  ssd1305_display

done:       call  o_close
            ldi   0
            rtn

errmsg:     db   'File not found',10,13,0

            ; File descriptor for loading image data

fildes:     db    0,0,0,0
            dw    dta
            db    0,0
            db    0
            db    0,0,0,0
            dw    0,0
            db    0,0,0,0

dta:        ds    512

            ; Buffer to hold image for display

frame_buf:  ds    1024

            end   start
