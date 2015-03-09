#include "types.h"
#include "defs.h"
#include "memlayout.h"
#include "mmu.h"

//static void startothers(void);
int main(void)  __attribute__((noreturn));
extern pde_t *kpgdir;
extern char end[]; // first address after kernel loaded from ELF file

int
main(void)
{
  cprintf("Test for printing\n");
  int i = 3;
  cprintf("%d\n",i);

  while(1);
}

 pde_t entrypgdir[];  // For entry.S

__attribute__((__aligned__(PGSIZE)))

pde_t entrypgdir[NPDENTRIES] = {
  [0] = (0) | PTE_P | PTE_W | PTE_PS,
  [KERNBASE>>PDXSHIFT] = (0) | PTE_P | PTE_W | PTE_PS,
};


