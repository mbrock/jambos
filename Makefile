
CXXFLAGS = -nostdlib -fno-builtin -fno-rtti -fno-exceptions \
           -fno-stack-protector -W -Wall -m64 -Iinclude \
           -std=c++11

STAGE3_OBJS = lib/static-string.o lib/terminal.o lib/printf.o

BOOT_STAGES = boot/stage2.o boot/stage3.o

ifdef XCOMPILE
LDFLAGS += -m elf_x86_64
endif

all: boot.img

run: boot.img
	qemu -s -hda boot.img -boot c

boot.img: boot/bootsector.o boot/boot.o
	cat boot/bootsector.o boot/boot.o > boot/tmp.img
	dd bs=2M count=1 conv=sync if=boot/tmp.img of=boot.img
	rm boot/tmp.img

boot/bootsector.o: boot/bootsector.asm

boot/stage3.o: boot/stage3.cpp $(STAGE3_OBJS)

boot/boot.o: link.ld $(BOOT_STAGES)
	ld -T link.ld $(LDFLAGS) $(BOOT_STAGES) $(STAGE3_OBJS) -o $@
	cp boot/boot.o lala.o
	objcopy -O binary $@

boot/bootsector.o: boot/bootsector.asm
	nasm $< -o $@

boot/stage2.o: boot/stage2.asm
	nasm -f elf64 $< -o $@

clean:
	rm -f boot.img boot/*.o $(BOOT_STAGES) lib/*.o
