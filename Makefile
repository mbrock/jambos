
all: boot.img

boot.img: boot/bootsector.o boot/boot.o
	cat boot/bootsector.o boot/boot.o > boot/tmp.img
	dd bs=100M count=1 conv=sync if=boot/tmp.img of=boot.img
	rm tmp.img

boot/bootsector.o: boot/bootsector.asm

CXXFLAGS = -nostdlib -fno-builtin -fno-rtti -fno-exceptions \
           -fno-stack-protector -W -Wall -m64 -Iinclude

boot/stage3.o: boot/stage3.cpp lib/static-string.o lib/terminal.o lib/printf.o

BOOT_STAGES=boot/stage2.o boot/stage3.o

boot/boot.o: link.ld $(BOOT_STAGES)
	ld -T link.ld $(BOOT_STAGES) -o $@
	objcopy -O binary $@

boot/bootsector.o: boot/bootsector.asm
	nasm $< -o $@

boot/stage2.o: boot/stage2.asm
	nasm -f elf $< -o $@

clean:
	rm -f boot.img boot/*.o $(BOOT_STAGES) lib/*.o