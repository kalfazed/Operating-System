#include "asm.h"
#include "memlayout.h"
#include "mmu.h"

# Start the first CPU: switch to 32-bit protected mode, jump into C.启动CPU，切换到32位保护模式，跳转到C代码
# The BIOS loads this code from the first sector of the hard disk into
# memory at physical address 0x7c00 and starts executing in real mode
# with %cs=0 %ip=7c00.

.code16                         # Assemble for 16-bit mode CPU刚启动为16位模式
.globl start
start:
  cli                           # BIOS enabled interrupts; disable 关中断

  # Zero data segment registers DS, ES, and SS. 清空寄存器
  xorw    %ax,%ax             	# Set %ax to zero
  movw    %ax,%ds             	# -> Data Segment
  movw    %ax,%es             	# -> Extra Segment
  movw    %ax,%ss             	# -> Stack Segment

  # Physical address line A20 is tied to zero so that the first PCs 
  # with 2 MB would run software that assumed 1 MB.  Undo that.
  # 为了兼容早期的PC机，第20根地址线在实模式下不能使用  
  # 所以超过1MB的地址，默认就会返回到地址0，下面的代码打开A20地址线
  # 把A20地址线控制和键盘控制器8042的一个输出进行AND操作,这样来控制A20地址线的打开(使能)和关闭(屏蔽\禁止)

seta20.1:			  #判断键盘控制器是否繁忙
  inb     $0x64,%al               # Wait for not busy 从0x64端口读一字节数据到al寄存器中，返回i8042中状态寄存器的内容
  testb   $0x2,%al		  # 将al按位与0010进行AND操作并对标志寄存器进行置位,运算结果0，ZF置1，否则置0
  jnz     seta20.1		  # 0x64中倒数第二位为0时程序才正常执行

  movb    $0xd1,%al               # 0xd1 -> port 0x64 如果不繁忙将端口0x64的值置为0xd1
  outb    %al,$0x64

seta20.2:
  inb     $0x64,%al               # Wait for not busy
  testb   $0x2,%al
  jnz     seta20.2

  movb    $0xdf,%al               # 0xdf -> port 0x60 如果不繁忙将端口0x60的值置为0xdf
  outb    %al,$0x60

  # Switch from real to protected mode.  Use a bootstrap GDT that makes
  # virtual addresses map directly to physical addresses so that the
  # effective memory map doesn't change during the transition.
  #加载GDTR，进入保护模式 
  lgdt    gdtdesc		  #通过lgdt汇编指令可以把GDTR全局描述符表的大小和起始位置存入gdtr寄存器中 
  				  # 控制寄存器cr0中的第0位为1表示处于保护模式  第0位为0，表示处于实模式
  movl    %cr0, %eax
  orl     $CR0_PE, %eax		  #通过逻辑或操作将eax寄存器的第一位置设为1。定义在mmu.h文件中#define CR0_PE 0x00000001
  movl    %eax, %cr0		  #将CR0的最后一位设置为1，进入保护模式（！！！）

//PAGEBREAK!
  # Complete transition to 32-bit protected mode by using long jmp
  # to reload %cs and %eip.  The segment descriptors are set up with no
  # translation, so that the mapping is still the identity mapping.
  # 从实模式切换到保护模式。 使用一个引导程序的GDT来将虚拟地址直接映射到物理地址，
  # 这样在转换过程中不会改变实际的内存映射。
  
  ljmp    $(SEG_KCODE<<3), $start32  #定义在mmu.h文件中#define SEG_KCODE 1  // kernel code
  #$(SEG_KCODE << 3)即0x08会被存入寄存器cs中，代表的是段选择子，偏移地址为：$start32

.code32  # Tell assembler to generate 32-bit code now.
start32:
  # Set up the protected-mode data segment registers 下面进入保护模式的操作
  movw    $(SEG_KDATA<<3), %ax      #定义在mmu.h文件中#define SEG_KDATA 2  数据段选择子0x10
  # 将ax装入到其他数据段寄存器中，在装入的同时，数据段描述符会自动的加入到这些段寄存器对应的高速缓冲寄存器中
  movw    %ax, %ds                  # -> DS: Data Segment
  movw    %ax, %es                  # -> ES: Extra Segment
  movw    %ax, %ss                  # -> SS: Stack Segment
  movw    $0, %ax                   # Zero segments not ready for use
  movw    %ax, %fs                  # -> FS
  movw    %ax, %gs                  # -> GS

  # Set up the stack pointer and call into C.
  movl    $start, %esp		    #将栈顶指针指向$start坐在位置即(0x7c00)
  call    bootmain		    #调用bootmain.c中的bootmain函数

# If bootmain returns (it shouldn't)
  movw $BootMessage, %ax
  movw %ax, %bp  #ES:BP = 串地址
  movw $48, %cx  #CX =  串长度
  movw $0x1301, %ax  #AH = 13, AL = 01h,这里面是调用了10h号中断的13号功能
  movw $0x00c, %bx  #页号为0(BH=0) 黑底红字(BL=0Ch,高亮)
  movb $0, %dl #表示起始行号
  int  $0x10  #调用10h号中断

BootMessage: .ascii "hello, BLCU OS, My name is ChenPeng"

#spin:
#  jmp     spin

# Bootstrap GDT
.p2align 2                                # force 4 byte alignment
gdt:
  SEG_NULLASM                             # null seg 通过查找asm.h文件可知，实际此段为8个值为0的字节
  SEG_ASM(STA_X|STA_R, 0x0, 0xffffffff)	  # code seg 此段为定义代码段
  SEG_ASM(STA_W, 0x0, 0xffffffff)	        # data seg 定义数据段

gdtdesc:				  #此为段描述符表的地址
  .word   (gdtdesc - gdt - 1)             # sizeof(gdt) - 1 大小
  .long   gdt                             # address gdt     位置

