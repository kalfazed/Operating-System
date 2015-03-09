# boot makefile
OBJS = \
      main.o\
      console.o\

CC = gcc
LD = ld
LDFILE = boot.ld
OBJCOPY = objcopy
OBJDUMP = objdump
QEMU = qemu
CFLAGS = -fno-pic -static -fno-builtin -fno-strict-aliasing -Wall -MD -ggdb -m32 -Werror -fno-omit-frame-pointer
CFLAGS += $(shell $(CC) -fno-stack-protector -E -x c /dev/null >/dev/null 2>&1 && echo -fno-stack-protector)
ASFLAGS = -m32 -gdwarf-2 -Wa,-divide
LDFLAGS += -m $(shell $(LD) -V | grep elf_i386 2>/dev/null)

all: os.img

qemu: os.img
	$(QEMU) -parallel stdio -hda $< -serial null
TERMINAL        :=gnome-terminal
debug: boot.img
	$(QEMU) -S -s -parallel stdio -hda $< -serial null &
	sleep 2
	$(TERMINAL) -e "gdb -q -x gdbinit"

os.img: bootblock kernel
	dd if=/dev/zero of=os.img count=10000		#把os.img的前10000个块置为0
	dd if=bootblock of=os.img conv=notrunc    	#把bootblock复制到os.img（不缩减输出文件）
	dd if=kernel of=os.img seek=1 conv=notrunc	#从os.img开头跳过1个块（512字节）后开始复制kernel

bootblock: bootasm.S bootmain.c				
	$(CC) $(CFLAGS) -fno-pic -O -nostdinc -I. -c bootmain.c	
	$(CC) $(CFLAGS) -fno-pic -nostdinc -I. -c bootasm.S
	$(LD) $(LDFLAGS) -N -e start -Ttext 0x7C00 -o boot.o bootasm.o bootmain.o
	$(OBJDUMP) -S boot.o > boot.asm
	$(OBJCOPY) -S -O binary -j .text boot.o bootblock	#把boot.o中的.text拷贝到二进制文件bootblock中
	./sign.pl bootblock					#把bootblock填充为512字节

kernel : $(OBJS) entry.o kernel.ld
	$(LD) $(LDFLAGS) -T kernel.ld -o kernel entry.o $(OBJS) -b binary	#链接成kernel文件。
	$(OBJDUMP) -S kernel > kernel.asm					#kernel反汇编为kernel.asm
	$(OBJDUMP) -t kernel | sed '1,/SYMBOL TABLE/d; s/ .* / /; /^$$/d' > kernel.sym
	
	
#生成u盘启动

uboot: boot.img
	@dd if=boot.img of=/dev/sdb  bs=512 count=1  #用boot.bin生成u盘第一个扇区
clean:
	@rm -ff *.o *.img *.d bootblock kernel *.asm *.sym

