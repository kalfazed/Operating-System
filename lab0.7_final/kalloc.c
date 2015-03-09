#include "types.h"
#include "x86.h"
#include "mmu.h"
#include "memlayout.h"
#include "defs.h"

struct run {
  struct run *next;
};

struct {
  struct run *freelist;
} kmem;    //已分配的物理块的链


extern char end[]; // first address after kernel loaded from ELF file

void kfree(char *v)
{
  struct run *r;

  memset(v, 1, PGSIZE);  //填充1

  r = (struct run*)v;
  r->next = kmem.freelist;
  kmem.freelist = r;        //把r挂到分好块的链表的头

}

void freerange(void *vstart, void *vend)       
{
  char *p;
  p = (char*)PGROUNDUP((uint)vstart);
  for(; p + PGSIZE <= (char*)vend; p += PGSIZE)  //分成PGSIZE大小的块，对每个块kfree填充全1，然后挂到kmem的链中
    kfree(p);                                    //PGSIZE = 4096
}


void kinit(void *vstart, void *vend)
{
  freerange(vstart, vend);
}

//分配一个4096字节的物理内存页，返回内核可以使用的指针。如果无法分配，则返回0
//从kmem链中取出一个块，给页目录表做映射。
char* kalloc(void)
{
  struct run *r;
  r = kmem.freelist;
  if(r)
    kmem.freelist = r->next;
  return (char*)r;
}
