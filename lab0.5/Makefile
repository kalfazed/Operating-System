# boot makefile

CC = gcc
LD = ld
LDFILE = boot.ld
OBJCOPY = objcopy
OBJDUMP = objdump
QEMU = qemu
CFLAGS = -fno-pic -static -fno-builtin -fno-strict-aliasing -Wall -MD -ggdb -m32 -Werror -fno-omit-frame-pointer
CFLAGS += $(shell $(CC) -fno-stack-protector -E -x c /dev/null >/dev/null 2>&1 && echo -fno-stack-protector)
LDFLAGS += -m $(shell $(LD) -V | grep elf_i386 2>/dev/null)

all: boot.img

qemu: boot.img
	$(QEMU) -parallel stdio -hda $< -serial null
TERMINAL        :=gnome-terminal
debug: boot.img
	$(QEMU) -S -s -parallel stdio -hda $< -serial null &
	sleep 2
	$(TERMINAL) -e "gdb -q -x gdbinit"
boot.img: bootasm.S bootmain.c
	$(CC) $(CFLAGS) -fno-pic -O -nostdinc -I. -c bootmain.c
	$(CC) $(CFLAGS) -fno-pic -nostdinc -I. -c bootasm.S
	$(LD) $(LDFLAGS) -N -e start -Ttext 0x7C00 -o boot.o bootasm.o bootmain.o
	$(OBJDUMP) -S boot.o > boot.asm
	$(OBJCOPY) -S -O binary -j .text boot.o boot.img
	./sign.pl boot.img	

#生成u盘启动
uboot: boot.img
	@dd if=boot.img of=/dev/sdd  bs=512 count=1  #用boot.bin生成u盘第一个扇区
clean:
	@rm -ff *.o *.img *.d
