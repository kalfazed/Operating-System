# boot makefile
OBJS = \
      main.o\
      console.o\
      string.o\
      kalloc.o\
      vm.o\
      vectors.o\
      trap.o\
      trapasm.o\
      uart.o\

CC = gcc
LD = ld
LDFILE = boot.ld
OBJCOPY = objcopy
OBJDUMP = objdump
QEMU = qemu
CFLAGS = -fno-pic -static -fno-builtin -fno-strict-aliasing -Wall -MD -ggdb -m32 -fno-omit-frame-pointer
CFLAGS += $(shell $(CC) -fno-stack-protector -E -x c /dev/null >/dev/null 2>&1 && echo -fno-stack-protector)
ASFLAGS = -m32 -gdwarf-2 -Wa,-divide
LDFLAGS += -m $(shell $(LD) -V | grep elf_i386 2>/dev/null)

all: os.img

qemu: os.img
	$(QEMU) -parallel stdio -hda $< -serial null
TERMINAL        :=gnome-terminal
debug: os.img
	$(QEMU) -S -s -parallel stdio -hda $< -serial null &
	sleep 2
	$(TERMINAL) -e "gdb -q -x gdbinit"

os.img: bootblock kernel
	dd if=/dev/zero of=os.img count=10000
	dd if=bootblock of=os.img conv=notrunc    	
	dd if=kernel of=os.img seek=1 conv=notrunc	

bootblock: bootasm.S bootmain.c
	$(CC) $(CFLAGS) -fno-pic -O -nostdinc -I. -c bootmain.c
	$(CC) $(CFLAGS) -fno-pic -nostdinc -I. -c bootasm.S
	$(LD) $(LDFLAGS) -N -e start -Ttext 0x7C00 -o boot.o bootasm.o bootmain.o
	$(OBJDUMP) -S boot.o > boot.asm
	$(OBJCOPY) -S -O binary -j .text boot.o bootblock
	./sign.pl bootblock

kernel : $(OBJS) entry.o kernel.ld
	$(LD) $(LDFLAGS) -T kernel.ld -o kernel entry.o $(OBJS) -b binary
	$(OBJDUMP) -S kernel > kernel.asm
	$(OBJDUMP) -t kernel | sed '1,/SYMBOL TABLE/d; s/ .* / /; /^$$/d' > kernel.sym
	

#调用一个perl脚本来动态实现256个中断的入口地址
vectors.S: vectors.pl
	perl vectors.pl > vectors.S


#生成u盘启动

uboot: boot.img
	@dd if=boot.img of=/dev/sdb  bs=512 count=1  #用boot.bin生成u盘第一个扇区
clean:
	@rm -ff *.o *.img *.d bootblock kernel vectors.S
