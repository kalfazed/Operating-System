#include "mmu.h"

  # vectors.S 会把所有的中断都掉转到这里
.globl alltraps

alltraps:
  # 建立一个中断帧，保护现场
  pushl %ds
  pushl %es
  pushl %fs
  pushl %gs
  pushal
  
  # 设置数据段
  movw $(SEG_KDATA<<3), %ax
  movw %ax, %ds
  movw %ax, %es

  # 调用trap函数，执行中断服务程序，目前针对所有中断都不做任何处理
  # 定义在了trap.c中，同时压栈esp，这里的esp就代表了trap的参数tf，也就是当前的中断帧
  pushl %esp
  call trap
  addl $4, %esp

  # 执行完中断服务程序以后开始恢复现场
.globl trapret
trapret:
  popal
  popl %gs
  popl %fs
  popl %es
  popl %ds
  addl $0x8, %esp  # 中断号以及错误号
  iret
