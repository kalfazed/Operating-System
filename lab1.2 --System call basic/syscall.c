#include "types.h"
#include "defs.h"
#include "param.h"
#include "memlayout.h"
#include "mmu.h"
#include "proc.h"
#include "x86.h"
#include "syscall.h"

//用户代码通过使用中断T_SYSCALL来使用一个系统调用
//系统调用的代码存放在了%eax中
//参数处于栈中


// 获取进程p在地址addr处的整数
int
fetchint(uint addr, int *ip)
{
  if(addr >= proc->sz || addr+4 > proc->sz)
    return -1;
  *ip = *(int*)(addr);
//  cprintf("The ip is %d\n",*ip);
  return 0;
}

//从进程p中取出addr地址处的空终止字符串
//实际上不是复制这个字符串，只是将*pp指向该值
//返回字符串的长度，不包括空终止字符
int
fetchstr(uint addr, char **pp)
{
  char *s, *ep;

  if(addr >= proc->sz)
    return -1;
  *pp = (char*)addr;
  ep = (char*)proc->sz;
  for(s = *pp; s < ep; s++)
    if(*s == 0)
      return s - *pp;
  return -1;
}

// 获取第n个32位系统调用参数
int
argint(int n, int *ip)
{
  return fetchint(proc->tf->esp + 4 + 4*n, ip);
}

//取出第n个字长的系统调用参数，返回给一个size字节大小的内存块的指针
//核实指针是否在进程地址空间范围之内
int
argptr(int n, char **pp, int size)
{
  int i;
  
  if(argint(n, &i) < 0)
    return -1;
  if((uint)i >= proc->sz || (uint)i+size > proc->sz)
    return -1;
  *pp = (char*)i;
  return 0;
}

//取得第n个系统调用参数(字长),传给一个字符串指针
//检查指针的有效性，并检查字符串是否空终止
//没有共享的可写内存，因此在执行检查和内核使用的时候，字符串不能被修改
int
argstr(int n, char **pp)
{
  int addr;
  if(argint(n, &addr) < 0)
    return -1;
  return fetchstr(addr, pp);
}

//系统调用部分
extern int sys_exec(void);

static int (*syscalls[])(void) = {
[SYS_exec]    sys_exec,
};

void
syscall(void)
{
  int num;
  num = proc->tf->eax;  //系统调用编号
  cprintf("Systemcall number is %d\n",num);
  if(num > 0 && num < NELEM(syscalls) && syscalls[num]){ //编号合法并且存在
       proc->tf->eax = syscalls[num]();  //传入系统调用程序入口
  } else {
    cprintf("%d %s: unknown sys call %d\n", proc->pid, proc->name, num);
  }
}
