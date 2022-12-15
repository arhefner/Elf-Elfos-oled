#include include/opcodes.def
#include include/bios.inc
#include include/sysconfig.inc

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

            org   2000h
start:      br    main


            ; Build information

            ever

            db    'See github.com/arhefner/Elfos-clock for more info',0


            ; Main code starts here, check provided argument

main:       lda   ra                    ; move past any spaces
            smi   ' '
            lbz   main

            mov   r1, introu

            ldi   64
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

            ret
            db    23h

wait:       b4    done
            glo   rb
            bnz   wait

            ldi   64
            plo   rb

            mov   rf, time_buf
            call  f_gettod

            mov   ra, time_buf
            inc   ra
            inc   ra
            inc   ra

            mov   rf, output
            ldi   0
            phi   rd
            lda   ra
            plo   rd
            call  f_uintout

            ldi   ':'
            str   rf
            inc   rf

            ldi   0
            phi   rd
            lda   ra
            plo   rd
            call  f_uintout

            ldi   ':'
            str   rf
            inc   rf

            ldi   0
            phi   rd
            lda   ra
            plo   rd
            call  f_uintout

            ldi   13
            str   rf
            inc   rf
            ldi   10
            str   rf
            inc   rf
            ldi   0
            str   rf

            mov   rf, output
            call  f_msg

            br    wait

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

            dec   rb

exit:       inc   r2
            lda   r2
            shl
            lda   r2
            br    exiti

time_buf:   ds    10
output:     ds    20

            end   start
