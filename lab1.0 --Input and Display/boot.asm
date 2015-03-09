
boot.o:     file format elf32-i386


Disassembly of section .text:

00007c00 <start>:
# with %cs=0 %ip=7c00.

.code16                         # Assemble for 16-bit mode CPU刚启动为16位模式
.globl start
start:
  cli                           # BIOS enabled interrupts; disable 关中断
    7c00:	fa                   	cli    

  # Zero data segment registers DS, ES, and SS. 清空寄存器
  xorw    %ax,%ax             	# Set %ax to zero
    7c01:	31 c0                	xor    %eax,%eax
  movw    %ax,%ds             	# -> Data Segment
    7c03:	8e d8                	mov    %eax,%ds
  movw    %ax,%es             	# -> Extra Segment
    7c05:	8e c0                	mov    %eax,%es
  movw    %ax,%ss             	# -> Stack Segment
    7c07:	8e d0                	mov    %eax,%ss

00007c09 <seta20.1>:
  # 为了兼容早期的PC机，第20根地址线在实模式下不能使用  
  # 所以超过1MB的地址，默认就会返回到地址0，下面的代码打开A20地址线
  # 把A20地址线控制和键盘控制器8042的一个输出进行AND操作,这样来控制A20地址线的打开(使能)和关闭(屏蔽\禁止)

seta20.1:			  #判断键盘控制器是否繁忙
  inb     $0x64,%al               # Wait for not busy 从0x64端口读一字节数据到al寄存器中，返回i8042中状态寄存器的内容
    7c09:	e4 64                	in     $0x64,%al
  testb   $0x2,%al		  # 将al按位与0010进行AND操作并对标志寄存器进行置位,运算结果0，ZF置1，否则置0
    7c0b:	a8 02                	test   $0x2,%al
  jnz     seta20.1		  # 0x64中倒数第二位为0时程序才正常执行
    7c0d:	75 fa                	jne    7c09 <seta20.1>

  movb    $0xd1,%al               # 0xd1 -> port 0x64 如果不繁忙将端口0x64的值置为0xd1
    7c0f:	b0 d1                	mov    $0xd1,%al
  outb    %al,$0x64
    7c11:	e6 64                	out    %al,$0x64

00007c13 <seta20.2>:

seta20.2:
  inb     $0x64,%al               # Wait for not busy
    7c13:	e4 64                	in     $0x64,%al
  testb   $0x2,%al
    7c15:	a8 02                	test   $0x2,%al
  jnz     seta20.2
    7c17:	75 fa                	jne    7c13 <seta20.2>

  movb    $0xdf,%al               # 0xdf -> port 0x60 如果不繁忙将端口0x60的值置为0xdf
    7c19:	b0 df                	mov    $0xdf,%al
  outb    %al,$0x60
    7c1b:	e6 60                	out    %al,$0x60

  # Switch from real to protected mode.  Use a bootstrap GDT that makes
  # virtual addresses map directly to physical addresses so that the
  # effective memory map doesn't change during the transition.
  #加载GDTR，进入保护模式 
  lgdt    gdtdesc		  #通过lgdt汇编指令可以把GDTR全局描述符表的大小和起始位置存入gdtr寄存器中 
    7c1d:	0f 01 16             	lgdtl  (%esi)
    7c20:	a0 7c 0f 20 c0       	mov    0xc0200f7c,%al
  				  # 控制寄存器cr0中的第0位为1表示处于保护模式  第0位为0，表示处于实模式
  movl    %cr0, %eax
  orl     $CR0_PE, %eax		  #通过逻辑或操作将eax寄存器的第一位置设为1。定义在mmu.h文件中#define CR0_PE 0x00000001
    7c25:	66 83 c8 01          	or     $0x1,%ax
  movl    %eax, %cr0		  #将CR0的最后一位设置为1，进入保护模式（！！！）
    7c29:	0f 22 c0             	mov    %eax,%cr0
  # to reload %cs and %eip.  The segment descriptors are set up with no
  # translation, so that the mapping is still the identity mapping.
  # 从实模式切换到保护模式。 使用一个引导程序的GDT来将虚拟地址直接映射到物理地址，
  # 这样在转换过程中不会改变实际的内存映射。
  
  ljmp    $(SEG_KCODE<<3), $start32  #定义在mmu.h文件中#define SEG_KCODE 1  // kernel code
    7c2c:	ea 31 7c 08 00 66 b8 	ljmp   $0xb866,$0x87c31

00007c31 <start32>:
  #$(SEG_KCODE << 3)即0x08会被存入寄存器cs中，代表的是段选择子，偏移地址为：$start32

.code32  # Tell assembler to generate 32-bit code now.
start32:
  # Set up the protected-mode data segment registers 下面进入保护模式的操作
  movw    $(SEG_KDATA<<3), %ax      #定义在mmu.h文件中#define SEG_KDATA 2  数据段选择子0x10
    7c31:	66 b8 10 00          	mov    $0x10,%ax
  # 将ax装入到其他数据段寄存器中，在装入的同时，数据段描述符会自动的加入到这些段寄存器对应的高速缓冲寄存器中
  movw    %ax, %ds                  # -> DS: Data Segment
    7c35:	8e d8                	mov    %eax,%ds
  movw    %ax, %es                  # -> ES: Extra Segment
    7c37:	8e c0                	mov    %eax,%es
  movw    %ax, %ss                  # -> SS: Stack Segment
    7c39:	8e d0                	mov    %eax,%ss
  movw    $0, %ax                   # Zero segments not ready for use
    7c3b:	66 b8 00 00          	mov    $0x0,%ax
  movw    %ax, %fs                  # -> FS
    7c3f:	8e e0                	mov    %eax,%fs
  movw    %ax, %gs                  # -> GS
    7c41:	8e e8                	mov    %eax,%gs

  # Set up the stack pointer and call into C.
  movl    $start, %esp		    #将栈顶指针指向$start坐在位置即(0x7c00)
    7c43:	bc 00 7c 00 00       	mov    $0x7c00,%esp
  call    bootmain		    #调用bootmain.c中的bootmain函数
    7c48:	e8 07 01 00 00       	call   7d54 <bootmain>

# If bootmain returns (it shouldn't)
  movw $BootMessage, %ax
    7c4d:	66 b8 64 7c          	mov    $0x7c64,%ax
  movw %ax, %bp  #ES:BP = 串地址
    7c51:	66 89 c5             	mov    %ax,%bp
  movw $48, %cx  #CX =  串长度
    7c54:	66 b9 30 00          	mov    $0x30,%cx
  movw $0x1301, %ax  #AH = 13, AL = 01h,这里面是调用了10h号中断的13号功能
    7c58:	66 b8 01 13          	mov    $0x1301,%ax
  movw $0x00c, %bx  #页号为0(BH=0) 黑底红字(BL=0Ch,高亮)
    7c5c:	66 bb 0c 00          	mov    $0xc,%bx
  movb $0, %dl #表示起始行号
    7c60:	b2 00                	mov    $0x0,%dl
  int  $0x10  #调用10h号中断
    7c62:	cd 10                	int    $0x10

00007c64 <BootMessage>:
    7c64:	68 65 6c 6c 6f       	push   $0x6f6c6c65
    7c69:	2c 20                	sub    $0x20,%al
    7c6b:	42                   	inc    %edx
    7c6c:	4c                   	dec    %esp
    7c6d:	43                   	inc    %ebx
    7c6e:	55                   	push   %ebp
    7c6f:	20 4f 53             	and    %cl,0x53(%edi)
    7c72:	2c 20                	sub    $0x20,%al
    7c74:	4d                   	dec    %ebp
    7c75:	79 20                	jns    7c97 <gdt+0xf>
    7c77:	6e                   	outsb  %ds:(%esi),(%dx)
    7c78:	61                   	popa   
    7c79:	6d                   	insl   (%dx),%es:(%edi)
    7c7a:	65 20 69 73          	and    %ch,%gs:0x73(%ecx)
    7c7e:	20 43 68             	and    %al,0x68(%ebx)
    7c81:	65 6e                	outsb  %gs:(%esi),(%dx)
    7c83:	50                   	push   %eax
    7c84:	65 6e                	outsb  %gs:(%esi),(%dx)
    7c86:	67 90                	addr16 nop

00007c88 <gdt>:
	...
    7c90:	ff                   	(bad)  
    7c91:	ff 00                	incl   (%eax)
    7c93:	00 00                	add    %al,(%eax)
    7c95:	9a cf 00 ff ff 00 00 	lcall  $0x0,$0xffff00cf
    7c9c:	00 92 cf 00 17 00    	add    %dl,0x1700cf(%edx)

00007ca0 <gdtdesc>:
    7ca0:	17                   	pop    %ss
    7ca1:	00 88 7c 00 00 55    	add    %cl,0x5500007c(%eax)

00007ca6 <waitdisk>:

}

void
waitdisk(void)
{
    7ca6:	55                   	push   %ebp
    7ca7:	89 e5                	mov    %esp,%ebp
static inline uchar
inb(ushort port)
{
  uchar data;

  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
    7ca9:	ba f7 01 00 00       	mov    $0x1f7,%edx
    7cae:	ec                   	in     (%dx),%al
  // Wait for disk ready. // 等待磁盘就绪
  while((inb(0x1F7) & 0xC0) != 0x40) //不断从0x1f7端口读取磁盘状态
    7caf:	83 e0 c0             	and    $0xffffffc0,%eax
    7cb2:	3c 40                	cmp    $0x40,%al
    7cb4:	75 f8                	jne    7cae <waitdisk+0x8>
    ;
}
    7cb6:	5d                   	pop    %ebp
    7cb7:	c3                   	ret    

00007cb8 <readsect>:

// Read a single sector at offset into dst. 读取偏移offset处一个扇区到 dst
void
readsect(void *dst, uint offset)
{
    7cb8:	55                   	push   %ebp
    7cb9:	89 e5                	mov    %esp,%ebp
    7cbb:	57                   	push   %edi
    7cbc:	53                   	push   %ebx
    7cbd:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  // Issue command. 发出读命令
  waitdisk();		//首先等待磁盘
    7cc0:	e8 e1 ff ff ff       	call   7ca6 <waitdisk>
}

static inline void
outb(ushort port, uchar data)
{
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
    7cc5:	ba f2 01 00 00       	mov    $0x1f2,%edx
    7cca:	b8 01 00 00 00       	mov    $0x1,%eax
    7ccf:	ee                   	out    %al,(%dx)
    7cd0:	b2 f3                	mov    $0xf3,%dl
    7cd2:	89 d8                	mov    %ebx,%eax
    7cd4:	ee                   	out    %al,(%dx)
  outb(0x1F2, 1);	// count = 1
  outb(0x1F3, offset);
  outb(0x1F4, offset >> 8);
    7cd5:	89 d8                	mov    %ebx,%eax
    7cd7:	c1 e8 08             	shr    $0x8,%eax
    7cda:	b2 f4                	mov    $0xf4,%dl
    7cdc:	ee                   	out    %al,(%dx)
  outb(0x1F5, offset >> 16);
    7cdd:	89 d8                	mov    %ebx,%eax
    7cdf:	c1 e8 10             	shr    $0x10,%eax
    7ce2:	b2 f5                	mov    $0xf5,%dl
    7ce4:	ee                   	out    %al,(%dx)
  outb(0x1F6, (offset >> 24) | 0xE0); //传送地址
    7ce5:	89 d8                	mov    %ebx,%eax
    7ce7:	c1 e8 18             	shr    $0x18,%eax
    7cea:	83 c8 e0             	or     $0xffffffe0,%eax
    7ced:	b2 f6                	mov    $0xf6,%dl
    7cef:	ee                   	out    %al,(%dx)
    7cf0:	b2 f7                	mov    $0xf7,%dl
    7cf2:	b8 20 00 00 00       	mov    $0x20,%eax
    7cf7:	ee                   	out    %al,(%dx)
  outb(0x1F7, 0x20);  // cmd 0x20 - read sectors 命令 0x20 –读扇区

  // Read data.
  waitdisk();
    7cf8:	e8 a9 ff ff ff       	call   7ca6 <waitdisk>
}

static inline void
insl(int port, void *addr, int cnt)
{
  asm volatile("cld; rep insl" :
    7cfd:	8b 7d 08             	mov    0x8(%ebp),%edi
    7d00:	b9 80 00 00 00       	mov    $0x80,%ecx
    7d05:	ba f0 01 00 00       	mov    $0x1f0,%edx
    7d0a:	fc                   	cld    
    7d0b:	f3 6d                	rep insl (%dx),%es:(%edi)
  insl(0x1F0, dst, SECTSIZE/4);	//读取数据到dst
}
    7d0d:	5b                   	pop    %ebx
    7d0e:	5f                   	pop    %edi
    7d0f:	5d                   	pop    %ebp
    7d10:	c3                   	ret    

00007d11 <readseg>:
// Read 'count' bytes at 'offset' from kernel into physical address 'pa'.
// 读取内核偏移offset处的count个字节到虚地址va
// Might copy more than asked. 可能复制的数据比请求的多。
void
readseg(uchar* pa, uint count, uint offset)
{
    7d11:	55                   	push   %ebp
    7d12:	89 e5                	mov    %esp,%ebp
    7d14:	57                   	push   %edi
    7d15:	56                   	push   %esi
    7d16:	53                   	push   %ebx
    7d17:	8b 5d 08             	mov    0x8(%ebp),%ebx
    7d1a:	8b 75 10             	mov    0x10(%ebp),%esi
  uchar* epa;	//结尾虚地址
  epa = pa + count;
    7d1d:	89 df                	mov    %ebx,%edi
    7d1f:	03 7d 0c             	add    0xc(%ebp),%edi

  // Round down to sector boundary. 下舍入到扇区边界下舍入到扇区边界
  pa -= offset % SECTSIZE;
    7d22:	89 f0                	mov    %esi,%eax
    7d24:	25 ff 01 00 00       	and    $0x1ff,%eax
    7d29:	29 c3                	sub    %eax,%ebx

  // Translate from bytes to sectors; kernel starts at sector 1.
  // 将字节转化为扇区;内核开始于第2扇区（扇区号1）。按扇区读取
  offset = (offset / SECTSIZE) + 1;
    7d2b:	c1 ee 09             	shr    $0x9,%esi
    7d2e:	83 c6 01             	add    $0x1,%esi
  // If this is too slow, we could read lots of sectors at a time.
  // 如果这样很慢，我们可以一次读取多个扇区
  // We'd write more to memory than asked, but it doesn't matter --
  // 我们写入的会比请求的多，但是这样不会产生任何问题。
  // we load in increasing order. 以递增的顺序读取
  for(; pa < epa; pa += SECTSIZE, offset++)
    7d31:	39 df                	cmp    %ebx,%edi
    7d33:	76 17                	jbe    7d4c <readseg+0x3b>
    readsect(pa, offset);
    7d35:	56                   	push   %esi
    7d36:	53                   	push   %ebx
    7d37:	e8 7c ff ff ff       	call   7cb8 <readsect>
  // If this is too slow, we could read lots of sectors at a time.
  // 如果这样很慢，我们可以一次读取多个扇区
  // We'd write more to memory than asked, but it doesn't matter --
  // 我们写入的会比请求的多，但是这样不会产生任何问题。
  // we load in increasing order. 以递增的顺序读取
  for(; pa < epa; pa += SECTSIZE, offset++)
    7d3c:	81 c3 00 02 00 00    	add    $0x200,%ebx
    7d42:	83 c6 01             	add    $0x1,%esi
    7d45:	83 c4 08             	add    $0x8,%esp
    7d48:	39 df                	cmp    %ebx,%edi
    7d4a:	77 e9                	ja     7d35 <readseg+0x24>
    readsect(pa, offset);
}
    7d4c:	8d 65 f4             	lea    -0xc(%ebp),%esp
    7d4f:	5b                   	pop    %ebx
    7d50:	5e                   	pop    %esi
    7d51:	5f                   	pop    %edi
    7d52:	5d                   	pop    %ebp
    7d53:	c3                   	ret    

00007d54 <bootmain>:

void readseg(uchar*, uint, uint);

void
bootmain(void)
{
    7d54:	55                   	push   %ebp
    7d55:	89 e5                	mov    %esp,%ebp
    7d57:	57                   	push   %edi
    7d58:	56                   	push   %esi
    7d59:	53                   	push   %ebx
    7d5a:	83 ec 0c             	sub    $0xc,%esp


  elf = (struct elfhdr*)0x10000;  // scratch space 暂存空间

  // Read 1st page off disk 从磁盘读取第一页
  readseg((uchar*)elf, 4096, 0);
    7d5d:	6a 00                	push   $0x0
    7d5f:	68 00 10 00 00       	push   $0x1000
    7d64:	68 00 00 01 00       	push   $0x10000
    7d69:	e8 a3 ff ff ff       	call   7d11 <readseg>
  // Is this an ELF executable? 判断是否十一个elf可执行代码段
  if(elf->magic != ELF_MAGIC){
    7d6e:	83 c4 0c             	add    $0xc,%esp
    7d71:	81 3d 00 00 01 00 7f 	cmpl   $0x464c457f,0x10000
    7d78:	45 4c 46 
    7d7b:	75 50                	jne    7dcd <bootmain+0x79>
	return;  // let bootasm.S handle error返回bootasm.s
  }
  // Load each program segment (ignores ph flags).  装载每个程序段(忽略 ph的标志位)
  ph = (struct proghdr*)((uchar*)elf + elf->phoff);
    7d7d:	a1 1c 00 01 00       	mov    0x1001c,%eax
    7d82:	8d 98 00 00 01 00    	lea    0x10000(%eax),%ebx
  eph = ph + elf->phnum;			//根据elf中的值来设置ph和eph
    7d88:	0f b7 35 2c 00 01 00 	movzwl 0x1002c,%esi
    7d8f:	c1 e6 05             	shl    $0x5,%esi
    7d92:	01 de                	add    %ebx,%esi
  for(; ph < eph; ph++){			//循环读取数据
    7d94:	39 f3                	cmp    %esi,%ebx
    7d96:	73 2f                	jae    7dc7 <bootmain+0x73>
    pa = (uchar*)ph->paddr;			//pa为ph的虚拟地址
    7d98:	8b 7b 0c             	mov    0xc(%ebx),%edi
    readseg(pa, ph->filesz, ph->off);		//读取代码段
    7d9b:	ff 73 04             	pushl  0x4(%ebx)
    7d9e:	ff 73 10             	pushl  0x10(%ebx)
    7da1:	57                   	push   %edi
    7da2:	e8 6a ff ff ff       	call   7d11 <readseg>
    if(ph->memsz > ph->filesz)
    7da7:	8b 4b 14             	mov    0x14(%ebx),%ecx
    7daa:	8b 43 10             	mov    0x10(%ebx),%eax
    7dad:	83 c4 0c             	add    $0xc,%esp
    7db0:	39 c1                	cmp    %eax,%ecx
    7db2:	76 0c                	jbe    7dc0 <bootmain+0x6c>
      stosb(pa + ph->filesz, 0, ph->memsz - ph->filesz); //这些多余字节置零
    7db4:	01 c7                	add    %eax,%edi
    7db6:	29 c1                	sub    %eax,%ecx
}

static inline void
stosb(void *addr, int data, int cnt)
{
  asm volatile("cld; rep stosb" :
    7db8:	b8 00 00 00 00       	mov    $0x0,%eax
    7dbd:	fc                   	cld    
    7dbe:	f3 aa                	rep stos %al,%es:(%edi)
	return;  // let bootasm.S handle error返回bootasm.s
  }
  // Load each program segment (ignores ph flags).  装载每个程序段(忽略 ph的标志位)
  ph = (struct proghdr*)((uchar*)elf + elf->phoff);
  eph = ph + elf->phnum;			//根据elf中的值来设置ph和eph
  for(; ph < eph; ph++){			//循环读取数据
    7dc0:	83 c3 20             	add    $0x20,%ebx
    7dc3:	39 de                	cmp    %ebx,%esi
    7dc5:	77 d1                	ja     7d98 <bootmain+0x44>
  }

  // Call the entry point from the ELF header. 调用ELF头中的入口点函数entry()
  // Does not return!  如果存在ELF文件，这个函数就不会返回 ！！！
  entry = (void(*)(void))(elf->entry);
  entry();
    7dc7:	ff 15 18 00 01 00    	call   *0x10018

}
    7dcd:	8d 65 f4             	lea    -0xc(%ebp),%esp
    7dd0:	5b                   	pop    %ebx
    7dd1:	5e                   	pop    %esi
    7dd2:	5f                   	pop    %edi
    7dd3:	5d                   	pop    %ebp
    7dd4:	c3                   	ret    
