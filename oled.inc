#define DISP_WIDTH      128
#define DISP_HEIGHT     64

DISP_PAGES:             EQU     (DISP_HEIGHT / 8)

IDLE:                   EQU     $02             ; SPI bus is idle
RESET:                  EQU     $01             ; Display reset active
COMMAND:                EQU     $06             ; Write command
DATA:                   EQU     $07             ; Write data

SET_CONTRAST:           EQU     $81
SET_ENTIRE_ON:          EQU     $A4
SET_NORM_INV:           EQU     $A6
SET_DISP:               EQU     $AE
SET_MEM_ADDR_MODE:      EQU     $20
SET_COL_ADDR:           EQU     $21
SET_PAGE_ADDR:          EQU     $22
SET_DISP_START_LINE:    EQU     $40
SET_SEG_REMAP:          EQU     $A0
SET_MUX_RATIO:          EQU     $A8
SET_COM_OUT_DIR:        EQU     $C0
SET_DISP_OFFSET:        EQU     $D3
SET_COM_PIN_CFG:        EQU     $DA
SET_DISP_CLK_DIV:       EQU     $D5
SET_PRECHARGE:          EQU     $D9
SET_VCOM_DESEL:         EQU     $DB
SET_PAGE:               EQU     $B0
SET_COL_LOW:            EQU     $00
SET_COL_HIGH:           EQU     $10
DEACTIVATE_SCROLL:      EQU     $2E

HORIZONTAL_MODE:        EQU     $00
VERTICAL_MODE:          EQU     $01
PAGE_MODE:              EQU     $02
