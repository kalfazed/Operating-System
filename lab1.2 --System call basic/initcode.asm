
initcode.o:     file format elf32-i386


Disassembly of section .text:

00000000 <start>:

#起初压栈参数argv以及init，同时再将SYS_exec传入eax中，表示用户的第一个进程就是执行
#一个系统调用，系统调用的编号是exec，参数是init，表示执行init操作，之后会转入到文件
#init.c中的main函数中执行操作

  pushl $argv
   0:	68 1c 00 00 00       	push   $0x1c
  pushl $init
   5:	68 13 00 00 00       	push   $0x13
  pushl $0  // 调用者pc来到的地址
   a:	6a 00                	push   $0x0
  movl $SYS_exec, %eax
   c:	b8 07 00 00 00       	mov    $0x7,%eax
  int $T_SYSCALL
  11:	cd 40                	int    $0x40

00000013 <init>:
  13:	2f                   	das    
  14:	69 6e 69 74 00 00 66 	imul   $0x66000074,0x69(%esi),%ebp
  1b:	90                   	nop

0000001c <argv>:
  1c:	13 00                	adc    (%eax),%eax
  1e:	00 00                	add    %al,(%eax)
  20:	00 00                	add    %al,(%eax)
	...
