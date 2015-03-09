//Intel 8259A 可编程中断控制器

#include "types.h"
#include "x86.h"
#include "traps.h"

//两个可编程中断控制器的IO地址
#define IO_PIC1         0x20    // 主控制器 (IRQs 0-7)
#define IO_PIC2         0xA0    // 从控制器 (IRQs 8-15)

#define IRQ_SLAVE       2       // 从控制器级联主控制器的中断号

// 目前所屏蔽的中断号
// 起始时，只有2号中断可以被使用(为了级联从控制器8259A).

static ushort irqmask = 0xFFFF & ~(1<<IRQ_SLAVE);

static void
picsetmask(ushort mask)
{
  irqmask = mask;
  outb(IO_PIC1+1, mask);
  outb(IO_PIC2+1, mask >> 8);
}

void
picenable(int irq)
{
  picsetmask(irqmask & ~(1<<irq));
}

//初始化8259A的中断控制器
void
picinit(void)
{
  // 屏蔽掉所有的中断
  outb(IO_PIC1+1, 0xFF);
  outb(IO_PIC2+1, 0xFF);

  // 设置主控制器

  outb(IO_PIC1, 0x11);    	  	// ICW1
  outb(IO_PIC1+1, T_IRQ0); 		// ICW2, 设置所有中断向量偏移地址
  outb(IO_PIC1+1, 1<<IRQ_SLAVE); 	// ICW3
  outb(IO_PIC1+1, 0x3); 		// ICW4

  // 设置从控制器
  
  outb(IO_PIC2, 0x11);                  // ICW1
  outb(IO_PIC2+1, T_IRQ0 + 8);          // ICW2
  outb(IO_PIC2+1, IRQ_SLAVE);           // ICW3
  outb(IO_PIC2+1, 0x3);                 // ICW4
  
  //设置OCW3  
  outb(IO_PIC1, 0x68);            
  outb(IO_PIC1, 0x0a);            

  outb(IO_PIC2, 0x68);             // OCW3
  outb(IO_PIC2, 0x0a);             // OCW3

  if(irqmask != 0xFFFF)
    picsetmask(irqmask);
}
