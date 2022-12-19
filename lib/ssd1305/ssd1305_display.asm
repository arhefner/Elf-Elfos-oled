#include    include/macros.inc
#include    include/sysconfig.inc
#include    oled.inc

.link       .align  page

;
; Name: ssd1305_init
;
; Initializes OLED display using the SSD1305 controller chip connected
; to port 0 of the 1802/Mini SPI interface. The bits of the SPI control
; port are as follows:
;
; Bit 7 - If set to 0, the low 6-bits of the control port are set.
;         If set to 1, the low 6-bits of the DMA count are set.
; Bit 6 - Setting this bit to 1 starts a DMA out operation.
; Bit 5 - Setting this bit to 1 starts a DMA in operation (not used here).
; Bit 4 - The MSB of the DMA count when the count is written.
; Bit 3 - CS1 - used by the micro-SD card.
; Bit 2 - CS0 - Chip Select for the OLED port.
; Bit 1 - Active low reset for the OLED display.
; Bit 0 - 0 = Display Control, 1 = Display Data.
;
; Parameters: None
;
; Return: None
;
            proc    ssd1305_init
            push    rc

            sex     r3

          #if SPI_GROUP
            out     EXP_PORT
            db      SPI_GROUP
          #endif

            out     SPI_CTL
            db      IDLE

            ldi     83                  ; delay 1 ms
            plo     rc
delay1:     dec     rc
            glo     rc
            bnz     delay1

            out     SPI_CTL
            db      RESET

            mov     rc, 830             ; delay 10 ms
delay2:     dec     rc
            brnz    rc, delay2

            out     SPI_CTL
            db      IDLE

            mov     rc, 830             ; delay 10 ms
delay3:     dec     rc
            brnz    rc, delay3

            mov     r0, dma_init
            sex     r0

            out     SPI_CTL             ; Set DMA count
            out     SPI_CTL             ; Start control DMA out

            sex     r3

            out     SPI_CTL
            db      IDLE

          #if SPI_GROUP
            out     EXP_PORT
            db      NO_GROUP
          #endif

            sex     r2

            pop     rc

            rtn

dma_init:   db      $17 | $80                       ; set low 6-bits of count
                                                    ; = (init_end - init_start)
            db      $46                             ; enable control dma

init_start: db      SET_DISP | $00                  ; off
            ; address setting
            db      SET_MEM_ADDR_MODE, HORIZONTAL_MODE
            ; resolution and layout
            db      SET_DISP_START_LINE | $00
            db      SET_SEG_REMAP | $01             ; column addr 127 mapped to seg0
            db      SET_MUX_RATIO, DISP_HEIGHT - 1
            db      SET_COM_OUT_DIR | $08           ; scan from com[n] to com0
            db      SET_DISP_OFFSET, $00
            db      SET_COM_PIN_CFG
#if (DISP_HEIGHT == 32 || DISP_HEIGHT == 16) && (DISP_WIDTH != 64)
            db      $02
#else
            db      $12
#endif
            ; timing and driving scheme
            db      SET_DISP_CLK_DIV, $80
            db      SET_PRECHARGE, $f1
            db      SET_VCOM_DESEL, $3c             ; 0.83*vcc
            ; display
            db      SET_CONTRAST, $80
            db      SET_ENTIRE_ON
            db      SET_NORM_INV
            db      SET_DISP | $01                  ; on
init_end:

           endp


;
; Name: ssd1305_set_contrast
;
; Set contrast of the OLED display.
;
; Parameters: R8.0 - new contrast value
;
; Return: None
;
            proc    ssd1305_set_contrast

            ldi     0
            stxd

          #if SPI_GROUP
            ldi     NO_GROUP
            stxd
          #endif

            ldi     IDLE
            stxd

            ; read parameter
            glo     r8                  ; get contrast
            stxd

            ldi     SET_CONTRAST
            stxd

            ldi     COMMAND
            stxd

          #if SPI_GROUP
            ldi     SPI_GROUP
            stxd
          #endif

            irx

          #if SPI_GROUP
            out     EXP_PORT
          #endif

            out     SPI_CTL
            out     SPI_DATA
            out     SPI_DATA
            out     SPI_CTL

          #if SPI_GROUP
            out     EXP_PORT
          #endif

            rtn

            endp


;
; Name: ssd1305_sleep
;
; Turn off the OLED display. The contents of the memory are preserved.
;
; Parameters: None
;
; Return: None
;
            proc    ssd1305_sleep

            sex     r3

          #if SPI_GROUP
            out     EXP_PORT
            db      SPI_GROUP
          #endif

            out     SPI_CTL
            db      COMMAND

            out     SPI_CTL
            db      SET_DISP | $00

            out     SPI_CTL
            db      IDLE

          #if SPI_GROUP
            out     EXP_PORT
            db      NO_GROUP
          #endif

            sex     r2

            endp


;
; Name: ssd1305_wake
;
; Turn on the OLED display. The previous contents of the memory are displayed.
;
; Parameters: None
;
; Return: None
;
            proc    ssd1305_wake

            sex     r3

          #if SPI_GROUP
            out     EXP_PORT
            db      SPI_GROUP
          #endif

            out     SPI_CTL
            db      COMMAND

            out     SPI_CTL
            db      SET_DISP | $01

            out     SPI_CTL
            db      IDLE

          #if SPI_GROUP
            out     EXP_PORT
            db      NO_GROUP
          #endif

            sex     r2

            endp


;
; Name: ssd1305_clear
;
; Clear the memory of the OLED display.
;
; Parameters: None
;
; Return: None
;
            proc    ssd1305_clear
            push    rc

            sex     r3

          #if SPI_GROUP
            out     EXP_PORT
            db      SPI_GROUP
          #endif

            out     SPI_CTL
            db      COMMAND
            out     SPI_DATA
            db      SET_PAGE_ADDR
            out     SPI_DATA
            db      0
            out     SPI_DATA
            db      DISP_PAGES - 1
            out     SPI_DATA
            db      SET_COL_ADDR
            out     SPI_DATA
            db      0
            out     SPI_DATA
            db      DISP_WIDTH - 1

clear:      out     SPI_CTL
            db      DATA

            sex     r2

            mov     rc, 1024

            ldi     $00
            str     r2

loop:       out     SPI_DATA
            dec     r2

            dec     rc
            brnz    rc, loop

            sex     r3

            out     SPI_CTL
            db      IDLE

          #if SPI_GROUP
            out     EXP_PORT
            db      NO_GROUP
          #endif

            sex     r2

            pop     rc
            rtn

            endp


;
; Name: ssd1305_display
;
; Copy a complete image from frame buffer to display.
;
; Parameters: R8 - pointer to 1K frame buffer.
;
; Return: None
;
            proc    ssd1305_display
            push    rc

            sex     r3

          #if SPI_GROUP
            out     EXP_PORT
            db      SPI_GROUP
          #endif

            out     SPI_CTL
            db      COMMAND
            out     SPI_DATA
            db      SET_PAGE_ADDR
            out     SPI_DATA
            db      0
            out     SPI_DATA
            db      DISP_PAGES - 1
            out     SPI_DATA
            db      SET_COL_ADDR
            out     SPI_DATA
            db      0
            out     SPI_DATA
            db      DISP_WIDTH - 1

            out     SPI_CTL
            db      DATA

            mov     r0,r8

            ldi     8
            plo     rc

loop2:      out     SPI_CTL
            db      $13
            out     SPI_CTL
            db      $80
            out     SPI_CTL
            db      $47

            dec     rc
            glo     rc
            bnz     loop2

            sex     r3

            out     SPI_CTL
            db      IDLE

          #if SPI_GROUP
            out     EXP_PORT
            db      NO_GROUP
          #endif

            sex     r2

            pop     rc

            rtn

            endp
