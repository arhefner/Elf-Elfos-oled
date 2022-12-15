# Elf-Elfos-oled
SPI OLED display utilities for Elf/OS

These are various Elf/OS programs designed to be used on an 1802/Mini system with an 1802/Mini SPI adapter board connected to a 128x64 OLED display on SPI port 0.

These programs are written for the Asm-02 assembler and Link-02 linker by Mike Riley. Currently, these are forked to arhefner/Asm-02 and arhefner/Link-02. The versions on the 'updates' branch of the respective repositories are required to build this code.

The commands for building the utilities are shown in the build.sh script.

The current utilities are:

baud <rate> - If your 1802/Mini includes a hardware UART, this utility will set the baud rate. Supported rates are 300, 1200, 2400, 4800, 9600, 19200, 38400, and 57600.

show <file> - This will display a bitmap from a file on a connected SSD1305 OLED. The file should be exactly 1024 bytes and in the native OLED format. A couple of example images are in the test/images folder.

play <file> - This will play a series of bitmap images from a file in a continuous loop at 32fps on a connected SSD1305 OLED. Each image should be in the same format as those used for the show command. A sample animation is included in the test/movies folder. This utility requires the 1802/Mini RTC/Expansion board as a timing source.

clear - This will clear the connected SSD1305 OLED.

clock - Using the 1802/Mini RTC/Expansion board, this utility will display the time each second. This code will be the basis of future clock projects for the SSD1305 OLED.