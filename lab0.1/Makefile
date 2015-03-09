#first boot makefile

CC = gcc
LD = ld
LDFILE = boot.ld
OBJCOPY = objcopy
QEMU = qemu

all: boot.img

qemu: boot.img
	$(QEMU) -parallel stdio -hda $< -serial null

# 第一步：gcc调用as将bootasm.S编译成目标文件文件 boot.o
boot.o: bootasm-old.S
	$(CC) -c bootasm-old.S -o boot.o
#第二步:ld调用连接脚本boot.ld将boot.o连接成可执行文件boot.elf
boot.elf: boot.o
	$(LD) boot.o -o boot.elf -e c -T$(LDFILE)

#第三步：objcopy移除boot.elf中没有用的section(.pdr .comment .note)
#       去除所有符号信息，输出为二进制文件boot.bin
boot.bin: boot.elf
	@$(OBJCOPY) -R .pdr -R .comment -R .note -S -O binary boot.elf boot.bin
#第四步：生成可启动的软盘镜像
boot.img: boot.bin
	@dd if=boot.bin of=boot.img bs=512 count=1  #用boot.bin生成镜像文件的第一个扇区
	@dd if=/dev/zero of=boot.img skip=1 seek=1 bs=512 count=2879 #在bin生成镜像文件后补上空白，最后成为合适大小的软盘镜像
uboot: boot.bin
	@dd if=boot.bin of=/dev/sdb bs=512 count=1  #用boot.bin生成u盘第一个扇区

clean:
	@rm -ff boot.o boot.elf boot.bin boot.img
