// Boot loader.
// 
// Part of the boot sector, along with bootasm.S, which calls bootmain().
// bootasm.S has put the processor into protected 32-bit mode.
// bootmain() loads an ELF kernel image from the disk starting at
// sector 1 and then jumps to the kernel entry routine.
//bootmain从磁盘第二个扇区开始装载ELF内核镜像，然后跳转到内核入口程序。

#include "types.h"
#include "elf.h"
#include "x86.h"
#include "memlayout.h"

#define SECTSIZE  512	//扇区的大小

void readseg(uchar*, uint, uint);

void
bootmain(void)
{
   struct elfhdr *elf;			//定义一个elfhdr结构体指针*elf  (elf.h)t
   struct proghdr *ph, *eph;		//定义两个proghdr结构体指针*ph和*eph (elf.h)
   void (*entry)(void);
   uchar* pa;				//临时指针（虚地址）


  elf = (struct elfhdr*)0x10000;  // scratch space 暂存空间

  // Read 1st page off disk 从磁盘读取第一页
  readseg((uchar*)elf, 4096, 0);
  // Is this an ELF executable? 判断是否十一个elf可执行代码段
  if(elf->magic != ELF_MAGIC){
	return;  // let bootasm.S handle error返回bootasm.s
  }
  // Load each program segment (ignores ph flags).  装载每个程序段(忽略 ph的标志位)
  ph = (struct proghdr*)((uchar*)elf + elf->phoff);
  eph = ph + elf->phnum;			//根据elf中的值来设置ph和eph
  for(; ph < eph; ph++){			//循环读取数据
    pa = (uchar*)ph->paddr;			//pa为ph的虚拟地址
    readseg(pa, ph->filesz, ph->off);		//读取代码段
    if(ph->memsz > ph->filesz)
      stosb(pa + ph->filesz, 0, ph->memsz - ph->filesz); //这些多余字节置零
  }

  // Call the entry point from the ELF header. 调用ELF头中的入口点函数entry()
  // Does not return!  如果存在ELF文件，这个函数就不会返回 ！！！
  entry = (void(*)(void))(elf->entry);
  entry();

}

void
waitdisk(void)
{
  // Wait for disk ready. // 等待磁盘就绪
  while((inb(0x1F7) & 0xC0) != 0x40) //不断从0x1f7端口读取磁盘状态
    ;
}

// Read a single sector at offset into dst. 读取偏移offset处一个扇区到 dst
void
readsect(void *dst, uint offset)
{
  // Issue command. 发出读命令
  waitdisk();		//首先等待磁盘
  outb(0x1F2, 1);	// count = 1
  outb(0x1F3, offset);
  outb(0x1F4, offset >> 8);
  outb(0x1F5, offset >> 16);
  outb(0x1F6, (offset >> 24) | 0xE0); //传送地址
  outb(0x1F7, 0x20);  // cmd 0x20 - read sectors 命令 0x20 –读扇区

  // Read data.
  waitdisk();
  insl(0x1F0, dst, SECTSIZE/4);	//读取数据到dst
}

// Read 'count' bytes at 'offset' from kernel into physical address 'pa'.
// 读取内核偏移offset处的count个字节到虚地址va
// Might copy more than asked. 可能复制的数据比请求的多。
void
readseg(uchar* pa, uint count, uint offset)
{
  uchar* epa;	//结尾虚地址
  epa = pa + count;

  // Round down to sector boundary. 下舍入到扇区边界下舍入到扇区边界
  pa -= offset % SECTSIZE;

  // Translate from bytes to sectors; kernel starts at sector 1.
  // 将字节转化为扇区;内核开始于第2扇区（扇区号1）。按扇区读取
  offset = (offset / SECTSIZE) + 1;

  // If this is too slow, we could read lots of sectors at a time.
  // 如果这样很慢，我们可以一次读取多个扇区
  // We'd write more to memory than asked, but it doesn't matter --
  // 我们写入的会比请求的多，但是这样不会产生任何问题。
  // we load in increasing order. 以递增的顺序读取
  for(; pa < epa; pa += SECTSIZE, offset++)
    readsect(pa, offset);
}
