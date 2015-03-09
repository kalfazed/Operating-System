#include "types.h"
#include "defs.h"
#include "memlayout.h"
#include "mmu.h"
#include "traps.h"
#include "x86.h"
#include "kbd.h"
#include "proc.h"

struct gatedesc idt[256];
extern uint vectors[];  // 定义在vectors.S中，是256个中断的入口指针


// 中断描述符表初始化，将IDT中的每一个中断描述符都与vector.S中256个中断的地址相对应
void
tvinit(void)
{
  int i;
  for(i = 0; i < 256; i++)
    SETGATE(idt[i], 0, SEG_KCODE<<3, vectors[i], 0);
  SETGATE(idt[T_SYSCALL], 1, SEG_KCODE<<3, vectors[T_SYSCALL], DPL_USER);
}

// 打印一些当前IDT内中的一些信息
void 
printidt(void)
{
  int i = 0;
  for(;i<=10;i++){
	cprintf("IDT %d: offset 31~16:%d\n", i, idt[i].off_31_16);
	cprintf("IDT %d: offset 15~0:%d\n", i, idt[i].off_15_0);
  }
}

// 加载idt，调用内联汇编
void
idtinit(void)
{
  lidt(idt, sizeof(idt));
}

// 中断处理程序,目前什么都不做
void
trap(struct trapframe *tf)
{
  if(tf->trapno == T_SYSCALL){
	proc->tf = tf;
	syscall();
	return;
  }
   if(tf->trapno == (T_IRQ0 + IRQ_KBD)){
       kbdintr();
  }	
}
