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
} kmem;


extern char end[]; // first address after kernel loaded from ELF file

void kfree(char *v)
{
  struct run *r;

  memset(v, 1, PGSIZE);

  r = (struct run*)v;
  r->next = kmem.freelist;
  kmem.freelist = r;

}

void freerange(void *vstart, void *vend)
{
  char *p;
  p = (char*)PGROUNDUP((uint)vstart);
  for(; p + PGSIZE <= (char*)vend; p += PGSIZE)
    kfree(p);
}


void kinit(void *vstart, void *vend)
{
  freerange(vstart, vend);
}
