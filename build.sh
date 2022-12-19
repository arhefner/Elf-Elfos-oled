#!/bin/sh

asm02 -L baud.asm
link02 -e baud.prg

asm02 -L -D1802MAX ssd1305_lib.asm

asm02 -L -D1802MAX clear.asm
link02 -e clear.prg ssd1305_lib.prg

asm02 -L -D1802MAX play.asm
link02 -e play.prg ssd1305_lib.prg

asm02 -L -D1802MAX show.asm
asm02 -L pixiecvt.asm
link02 -e show.prg pixiecvt.prg ssd1305_lib.prg

asm02 -L -D1802MAX clock.asm
asm02 -L -D1802MAX oled_text.asm
link02 -e clock.prg ssd1305_lib.prg oled_text.prg
