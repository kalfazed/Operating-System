#include "types.h"
#include "traps.h"
#include "defs.h"

#define IOAPIC  0xFEC00000  	    // IOAPIC的默认物理地址
#define REG_VER    0x01       	    // 寄存器索引
#define REG_TABLE  0x10             // 重定向表的基地址

#define INT_DISABLED   0x00010000   // 关闭中断

volatile struct ioapic *ioapic;

int ismp;

//IOAPIC内存映射IO结构，写reg，读data
struct ioapic {
  uint reg;
  uint pad[3];
  uint data;
};

//写入reg，并写入数据
static void ioapicwrite(int reg, uint data)
{
  ioapic->reg = reg;
  ioapic->data = data;
}

//写入reg，并读取数据
static uint ioapicread(int reg)
{
  ioapic->reg = reg;
  return ioapic->data;
}

//IOAPIC的初始化
void ioapicinit(void)
{
  int i, maxintr;

  ioapic = (volatile struct ioapic*)IOAPIC;    //IOAPIC的默认的初始地址
  maxintr = (ioapicread(REG_VER) >> 16) & 0xFF;

  //标记所有的中断为边缘触发，激活高寄存器，关闭中断，不传送给CPU
  for(i = 0; i <= maxintr; i++){
    ioapicwrite(REG_TABLE+2*i, INT_DISABLED | (T_IRQ0 + i));
    ioapicwrite(REG_TABLE+2*i+1, 0);
  }
}

void ioapicenable(int irq, int cpunum)
{
  if(!ismp)
      return;

  //标记所有的中断为边缘触发，激活高寄存器，打开中断，传送给CPU
  ioapicwrite(REG_TABLE+2*irq, T_IRQ0 + irq);
  ioapicwrite(REG_TABLE+2*irq+1, cpunum << 24);
}
