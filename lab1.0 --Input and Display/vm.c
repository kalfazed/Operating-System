#include "types.h"
#include "x86.h"
#include "mmu.h"
#include "memlayout.h"
#include "cpu.h"
#include "defs.h"

struct cpu cpus[1];
extern char data[];  // 由kernel.ld来定义
pde_t *kpgdir;  // 被进程调度所使用(以后)

void seginit(void)
{
  struct cpu *c;
  c = &cpus[0]; 
  c->gdt[SEG_KCODE] = SEG(STA_X|STA_R, 0, 0xffffffff, 0);        
  c->gdt[SEG_KDATA] = SEG(STA_W, 0, 0xffffffff, 0);
  c->gdt[SEG_UCODE] = SEG(STA_X|STA_R, 0, 0xffffffff, DPL_USER);
  c->gdt[SEG_UDATA] = SEG(STA_W, 0, 0xffffffff, DPL_USER);
  
  c->gdt[SEG_KCPU] = SEG(STA_W, &c->cpu, 8, 0);
  
  lgdt(c->gdt, sizeof(c->gdt));
  loadgs(SEG_KCPU << 3);
  
  cpu = c;
}


void segshow(){

  cprintf("Kernel code segment's address bit 31~24 : %d\n",cpu->gdt[SEG_KCODE].base_31_24);
  cprintf("Kernel code segment's address bit 23~16 : %d\n",cpu->gdt[SEG_KCODE].base_23_16);
  cprintf("Kernel code segment's address bit 15~0 : %d\n",cpu->gdt[SEG_KCODE].base_15_0);
                                                                                          
  cprintf("Kernel data segment's address bit 31~24 : %d\n",cpu->gdt[SEG_KDATA].base_31_24);
  cprintf("Kernel data segment's address bit 23~16 : %d\n",cpu->gdt[SEG_KDATA].base_23_16);
  cprintf("Kernel data segment's address bit 15~0 : %d\n",cpu->gdt[SEG_KDATA].base_15_0);

  cprintf("User code segment's address bit 31~24 : %d\n",cpu->gdt[SEG_UCODE].base_31_24);
  cprintf("User code segment's address bit 23~16 : %d\n",cpu->gdt[SEG_UCODE].base_15_0);
  cprintf("User code segment's address bit 15~0 : %d\n",cpu->gdt[SEG_UCODE].base_15_0);
  
  cprintf("User code segment's address bit 31~24 : %d\n",cpu->gdt[SEG_UDATA].base_31_24);
  cprintf("User code segment's address bit 23~16 : %d\n",cpu->gdt[SEG_UDATA].base_23_16);
  cprintf("User code segment's address bit 15~0 : %d\n",cpu->gdt[SEG_UDATA].base_15_0);

}



//返回页表pgdir中对应线性地址va的PTE(页项)的地址，如果creat!=0,那么创建请求的页项
static pte_t * walkpgdir(pde_t *pgdir, const void *va, int alloc)
{
  pde_t *pde;
  pte_t *pgtab;

  pde = &pgdir[PDX(va)];    //根据线性地址查找其对应的页表地址
 
  if(*pde & PTE_P){
    pgtab = (pte_t*)p2v(PTE_ADDR(*pde));
  } else {
    
    if(!alloc || (pgtab = (pte_t*)kalloc()) == 0)
      return 0;
    
    memset(pgtab, 0, PGSIZE);
    
    *pde = v2p(pgtab) | PTE_P | PTE_W | PTE_U;
  }
  return &pgtab[PTX(va)];   //返回页地址
}

//为以va开始的线性地址创建页项，va引用pa开始处的物理地址，va和size可能没有按页对其
static int mappages(pde_t *pgdir, void *va, uint size, uint pa, int perm)
{
  char *a, *last;
  pte_t *pte;
  
  a = (char*)PGROUNDDOWN((uint)va);                        //va所在的第一页地址
  last = (char*)PGROUNDDOWN(((uint)va) + size - 1);        //va所在的最后一页地址
  
  for(;;){
    if((pte = walkpgdir(pgdir, a, 1)) == 0)      //创建页
      return -1;
   
    *pte = pa | perm | PTE_P;
   
    if(a == last)
      break;
   
    a += PGSIZE;
    pa += PGSIZE;
  }
  return 0;
}



//逻辑到线性的映射是一对一的。
//每个进程有一个页表，没有任何进程运行时还有一个页表kpgdir。
//用户进程使用和内核同样的页表，页的保护位可以防止进程访问页之外的内存。

//setupkvm()和exec()这样设置每张页表：
//0..640K： 	用户内存（代码，数据，栈，堆）
//640K...1M： 	映射I/O空间，直接映射
//1M..end： 	只有内核可以使用的映射空间，直接映射
//end..PHYSTOP：内核堆和用户页使用，直接映射
//0xfe000000..：直接映射，到不同设备，如ioapic设备

//内核在内核end和PHYSTOP之间为自己的堆和用户内存分配内存空间。
//每个用户程序的虚地址空间包括了内核空间（用户模式下不可访问）。用户程序从0到
//640KB（USERTOP）编址。640KB也就是是I/O空间的开始（物理内存和内核虚地址空间
//中都是）。


//内核映射结构
static struct kmap {
  void *virt;  //虚拟地址
  uint phys_start; //物理地址的起始位置
  uint phys_end; //物理地址的结束位置
  int perm; //特权等级
} kmap[] = {
 { (void*)KERNBASE, 0,             EXTMEM,    PTE_W}, // IO空间
 { (void*)KERNLINK, V2P(KERNLINK), V2P(data), 0},     // 内核的text,rodata (只读数据)
 { (void*)data,     V2P(data),     PHYSTOP,   PTE_W}, // 内核数据、内存空间
 { (void*)DEVSPACE, DEVSPACE,      0,         PTE_W}, // 设备映射
};


//设置页表的内核部分,返回此页表
pde_t* setupkvm(void)
{
  pde_t *pgdir;
  struct kmap *k;

  if((pgdir = (pde_t*)kalloc()) == 0)
    return 0;
 
  memset(pgdir, 0, PGSIZE);
 
  //分配每一页 
  for(k = kmap; k < &kmap[NELEM(kmap)]; k++)
    if(mappages(pgdir, k->virt, k->phys_end - k->phys_start, 
		(uint)k->phys_start, k->perm) < 0)
      return 0;

  return pgdir;
}


// 切换到页表kpgdir
void switchkvm(void)
{
  lcr3(v2p(kpgdir));   // 切换到内核页表
}

void kvmalloc(void)
{
  kpgdir = setupkvm();  // 设置好页表
  switchkvm();  	// 切换到内核页表
}




























