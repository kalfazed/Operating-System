#include "types.h"
#include "defs.h"
#include "memlayout.h"
#include "mmu.h"
#include "cpu.h"

//static void startothers(void);
int main(void)  __attribute__((noreturn));
extern pde_t *kpgdir;
extern char end[]; // first address after kernel loaded from ELF file


int
main(void)
{
  cprintf("Test for printing\n");
  
  ////////////////////////////////////////////////////////////
  //以下是内存管理的实现
  kinit(end, P2V(4*1024*1024));  // 物理页的分配，每页大小4096
  kvmalloc();  			 // 内核页表的初始化
  seginit();   			 // 初始化段，这里对段的初始化是对当前cpu的gdt的初始化
  ///////////////////////////////////////////////////////////
  
  //打印内存分布图
  segshow();

  while(1);
}

 pde_t entrypgdir[];  // For entry.S

__attribute__((__aligned__(PGSIZE)))

pde_t entrypgdir[NPDENTRIES] = {
  [0] = (0) | PTE_P | PTE_W | PTE_PS,
  [KERNBASE>>PDXSHIFT] = (0) | PTE_P | PTE_W | PTE_PS,
};

