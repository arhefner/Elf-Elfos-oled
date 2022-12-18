#include    include/macros.inc
#include    include/bios.inc

;
; Name: printrd
;
; Print the contents of the rd register in hex to the console.
; A pointer to a print buffer is passed in so that this routine
; may be placed in ROM and the caller can handle memory management.
;
; Parameters: RD - value to be printed
;             RF - pointer to a buffer of at least 7 bytes
;
;             All registers are preserved.
;
; Return: None
;
            proc    printrd

            push    rf
            call    f_hexout4
            ldi     13
            str     rf
            inc     rf
            ldi     10
            str     rf
            inc     rf
            ldi     0
            str     rf
            inc     rf
            pop     rf
            push    rf
            call    f_msg
            pop     rf
            rtn

            endp


;
; Name: printd
;
; Print the contents of the D accumulator in hex to the console.
; A pointer to a print buffer is passed in so that this routine
; may be placed in ROM and the caller can handle memory management.
;
; Parameters: D  - value to be printed
;             RF - pointer to a buffer of at least 5 bytes
;
;             All registers are preserved.
;
; Return: None
;
            proc    printd

            push    rd
            push    rf
            glo     re
            plo     rd
            call    f_hexout2
            ldi     13
            str     rf
            inc     rf
            ldi     10
            str     rf
            inc     rf
            ldi     0
            str     rf
            inc     rf
            pop     rf
            push    rf
            call    f_msg
            pop     rf
            pop     rd
            glo     re
            rtn

            endp