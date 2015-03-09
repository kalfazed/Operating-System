#include "types.h"
#include "defs.h"
#include "memlayout.h"
#include "mmu.h"
#include "cpu.h"
#include "x86.h"

int main(void)  __attribute__((noreturn));
extern pde_t *kpgdir;
extern char end[]; // first address after kernel loaded from ELF file


int
main(void)
{
  cprintf("Test for printing\n");
  
  kinit(end, P2V(4*1024*1024));  // 物理页的分配
  kvmalloc(); 			 // 内核页表
  seginit();   			 // 初始化段，这里对段的初始化是对当前cpu的gdt的初始化
//  segshow();   		 // 打印一些段的信息，用来验证

  picinit(); 			 // 初始化中断控制器8259A 
  ioapicinit(); 		 // 初始化IOAAPIC中断控制器
  consoleinit(); 		 // 初始化控制台

  tvinit(); 			 // 初始化idt，扩充idt中中断描述符的内容
  idtinit(); 			 // 加载idt
  sti(); 			 // 开启中断
//  printidt(); 	         // 打印一些idt的信息，用来验证

  

 // while(1);
}

 pde_t entrypgdir[];  // 为entry.S所提供

__attribute__((__aligned__(PGSIZE)))

pde_t entrypgdir[NPDENTRIES] = {
  [0] = (0) | PTE_P | PTE_W | PTE_PS,
  [KERNBASE>>PDXSHIFT] = (0) | PTE_P | PTE_W | PTE_PS,
};

