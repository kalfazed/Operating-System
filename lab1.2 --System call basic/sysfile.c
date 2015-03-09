#include "types.h"
#include "defs.h"
#include "param.h"
#include "mmu.h"
#include "proc.h"

//系统调用,这里让其先执行一个cprintf函数
int
sys_exec(void)
{
    cprintf("A basic Systemcall\n");
}
