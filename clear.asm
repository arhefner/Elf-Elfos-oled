            ; Include kernel API entry points

#include include/opcodes.def
#include include/bios.inc
#include include/kernel.inc
#include ssd1305_lib.inc

            org   2000h
start:      br    main


            ; Build information
            ever
            db    'See github.com/arhefner/Elfos-clear for more info',0


            ; Main code starts here, check provided argument

main:       lda   ra                    ; move past any spaces
            smi   ' '
            lbz   main
            dec   ra                    ; move back to non-space character
            ldn   ra                    ; get byte
            lbz   clr                   ; jump if no argument given
            call  o_inmsg               ; otherwise display usage message
            db    'Usage: clear',10,13,0
            ldi   $0a
            rtn                         ; and return to os

clr:        call  ssd1305_init
            call  ssd1305_clear

done:       ldi   0
            rtn

            end   start
