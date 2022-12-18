            ; Include kernel API entry points

#include include/macros.inc
#include include/bios.inc
#include include/kernel.inc

            org   2000h
start:      br    main


            ; Build information

            ever

            db    'See github.com/arhefner/Elfos-baud for more info',0


            ; Main code starts here, check provided argument

main:       mov   rf, ra
            call  f_ltrim
            call  f_atoi
            bdf   usage
            ldn   rf
            bnz   usage

            mov   ra, table

            ldi   (table_end-table)/3
            plo   rc

compare:    lda   ra
            str   r2
            ghi   rd
            xor
            bnz   hi_mis
            lda   ra
            str   r2
            glo   rd
            xor
            bnz   lo_mis
            ldn   ra
            call  f_usetbd
            ldi   0
            rtn

hi_mis:     inc   ra
lo_mis:     inc   ra

            dec   rc
            glo   rc
            bnz   compare

bad:        call  o_inmsg
            db    'Invalid baud rate.'10,13,0
            ldi   $04
            rtn

usage:      call  o_inmsg
            db    'Usage: baud <baudrate>',10,13,0
            ldi   $0c
            rtn

table:      dw    300
            db    $30
            dw    1200
            db    $31
            dw    2400
            db    $32
            dw    4800
            db    $33
            dw    9600
            db    $34
            dw    19200
            db    $35
            dw    38400
            db    $36
            dw    57600
            db    $37
table_end:

            end   start  
