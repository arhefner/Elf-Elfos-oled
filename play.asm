            ; Include kernel API entry points

#include include/opcodes.def
#include include/bios.inc
#include include/kernel.inc
#include include/sysconfig.inc
#include ssd1305_lib.inc

#define RTC_REG         20h

#define CLEAR_INT       10h

#define RATE_64HZ       10h
#define RATE_1_PER_SEC  14h
#define RATE_1_PER_MIN  18h
#define RATE_1_PER_HR   1ch

#define INT_ENABLE      10h
#define INT_MASK        11h

#define PULSE_MODE      10h
#define INT_MODE        12h

#define RTC_INT_ENABLE  41h
#define RTC_INT_DISABLE 40h


            org   2000h
start:      br    main


            ; Build information

            ever

            db    'See github.com/arhefner/Elfos-play for more info',0


            ; Main code starts here, check provided argument

main:       lda   ra                    ; move past any spaces
            smi   ' '
            lbz   main
            dec   ra                    ; move back to non-space character
            ldn   ra                    ; get byte
            lbnz  arg                   ; jump if argument given
            call  o_inmsg               ; otherwise display usage message
            db    'Usage: play filename',10,13,0
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

opened:     call  ssd1305_init
            call  ssd1305_clear

            lda   rd                    ; get size >> 8 in R9.0:RA
            plo   r9
            lda   rd
            phi   ra
            ldn   rd
            plo   ra

            glo   r9                    ; shift by 2 bits
            shr                         ; to get size / 1024 into RA
            plo   r9
            ghi   ra
            shrc
            phi   ra
            glo   ra
            shrc
            plo   ra

            glo   r9
            shr
            plo   r9
            ghi   ra
            shrc
            phi   ra
            glo   ra
            shrc
            plo   ra

            mov   r1, introu

            mov   r9, ra                ; set r9 = frame count

            ldi   2
            plo   rb

            sex   r3

          #if RTC_GROUP
            out   EXP_PORT              ; make sure default expander group
            db    RTC_GROUP
          #endif

            out   RTC_PORT
            db    RTC_REG | 0eh
            out   RTC_PORT
            db    RATE_64HZ | INT_MODE | INT_ENABLE

            out   RTC_PORT
            db    RTC_INT_ENABLE

          #if RTC_GROUP
            out   EXP_PORT              ; make sure default expander group
            db    NO_GROUP
          #endif

            ret                         ; enable interrupts
            db    23h

frame0:     mov   rd, fildes            ; seek to beginning
            ldi   0
            phi   r8
            plo   r8
            phi   r7
            plo   r7
            phi   rc
            plo   rc
            call  o_seek
            lbnf  wait

            mov   rf, seekerr
            call  o_msg
            lbr   done

wait:       bn4   test
            lbr   done
test:       glo   rb
            lbnz  wait

            ldi   2
            plo   rb

show:       mov   rd, fildes
            mov   rc, 1024
            mov   rf, frame_buf
            call  o_read
            lbnf  display

readerr:    call  o_inmsg
            db    'File read error.',13,10,0
            lbr   done

display:    mov   r8, frame_buf
            call  ssd1305_display

            dec   r9
            lbrnz r9, wait

            mov   r9, ra
            lbr   frame0

file_err:   call  o_inmsg
            db    'File error.',10,13,0
            ldi   $04
            rtn

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
            
            mov   rd, fildes
            call  o_close

            ldi   0
            rtn

errmsg:     db    'File not found.',10,13,0
seekerr:    db    'Seek error.',13,10,0
frame0msg:  db    'Frame 0',10,13,0

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

.align      page

exiti:      ret

introu:     dec   r2
            sav
            dec   r2
            stxd
            shrc
            stxd

            sex   r1

          #if RTC_GROUP
            out   EXP_PORT              ; make sure default expander group
            db    RTC_GROUP
          #endif

            out   RTC_PORT
            db    RTC_REG | 0dh
            out   RTC_PORT
            db    CLEAR_INT

          #if RTC_GROUP
            out   EXP_PORT              ; make sure default expander group
            db    NO_GROUP
          #endif

            sex   r2

            dec   rb

exit:       inc   r2
            lda   r2
            shl
            lda   r2
            br    exiti

            end   start
