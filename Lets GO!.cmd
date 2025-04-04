x86_64-w64-mingw32-gcc.exe -I includes -c kernel\tty\tty.c -o build\obj\kernel\tty\tty.c.o -std=gnu99 -ffreestanding -O3 -Wall -Wextra
x86_64-w64-mingw32-gcc.exe -c arch\x86\boot.S -o build\obj\arch\x86\boot.S.o
x86_64-w64-mingw32-gcc.exe -I includes -c kernel\kernel.c -o build\obj\kernel\kernel.c.o -ffreestanding -O3 -Wall -Wextra -nostdlib -lgcc 
x86_64-w64-mingw32-gcc.exe -T libs\linker.ld -o build\bin\dinner.bin build\obj\kernel\tty\tty.c.o build\obj\kernel\kernel.c.o build\obj\arch\x86\boot.S.o -ffreestanding -O3 -nostdlib -lgcc

copy build\bin\dinner.bin iso_dir\boot\dinner.bin
.\"grub_mkimage.cmd"