#include "types.h"
#include "defs.h"
#include "mmu.h"
#include "x86.h"

#define COM1    0x3f8

void
uartputc(int c)
{
  int i;
  for(i = 0; i < 128 && !(inb(COM1+5) & 0x20); i++)
  outb(COM1+0, c);
}




