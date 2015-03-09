#include "types.h"
#include "param.h"
#include "x86.h"
#include "mmu.h"
#include "proc.h"
#include "defs.h"
  
//进程表结构
struct {
    struct proc proc[NPROC];
} ptable;

static struct proc *initproc; //初始进程
static struct proc *currentproc; //当前进程
int nextpid = 1;

extern void trapret(void);  //定义在了trapasm.S里面
extern void forkret(void);

struct proc*
allocproc(void)
{
  struct proc *p;
  char *sp;

  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
    if(p->state == UNUSED)
      goto found;
  return 0;

found:
  p->state = EMBRYO;  //修改进程的状态位
  p->pid = nextpid++;

  // 为一个进程分配一段内核栈
  if((p->kstack = kalloc()) == 0){ //分配进程内核栈失败
    p->state = UNUSED;
    return 0;
  }
  sp = p->kstack + KSTACKSIZE; //sp为为这个进程分配的内核栈的栈顶地址
  
  sp -= sizeof *p->tf;   //流出陷入帧需要的空间
  p->tf = (struct trapframe*)sp; //当前的陷入帧
  
  // 设置新的上下文来开始执行forket
  // 最终返回到trapret.
  sp -= 4;
  *(uint*)sp = (uint)trapret;  //压入trapret的地址供forkret返回

  sp -= sizeof *p->context;  //留出上下文需要的空间
  p->context = (struct context*)sp;   //进程的上下文
  memset(p->context, 0, sizeof *p->context);  // 将上下文清空
  p->state = ALLOCATED;
//  p->context->eip = (uint)forkret;   //把当前上下文的起始地址设置为forkret

  return p;
}

//打印当前进程表中的所有进程的信息
void printproc(void)
{
  struct proc* p;
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
  {
      if(p->state == ALLOCATED)
      {
 	 cprintf("Process %d's kernelstack is %x\n",p->pid, p->kstack);  //该进程的内核栈的栈底地址
	 cprintf("Process %d's context is %x\n",p->pid, p->context);   //该进程的上下文地址
 	 cprintf("Process %d's trapframe is %x\n",p->pid, p->tf);   //该进程的陷入帧的地址
      }
  }

}

void
userinit(void)
{
  struct proc *p;
  
  p = allocproc(); //分配一个进程
  currentproc = p; //当前进程
  p->pgdir = setupkvm(); //设置这个进程的页表
  inituvm(p->pgdir);  //实现进程页表与物理内存的映射
  p->sz = PGSIZE;   //代码的最大有效虚拟地址
  memset(p->tf, 0, sizeof(*p->tf)); // 为用户进程寄存器开辟空间

  //设置此进程的陷入帧
  p->tf->cs = (SEG_UCODE << 3) | DPL_USER;
  p->tf->ds = (SEG_UDATA << 3) | DPL_USER;
  p->tf->es = p->tf->ds;
  p->tf->ss = p->tf->ds;
  p->tf->eflags = FL_IF; 
  p->tf->esp = PGSIZE;
  p->tf->eip = 0;  

//  safestrcpy(p->name, "initcode", sizeof(p->name));
//  p->cwd = namei("/");    //指明进程目录，由于是第一个进程，所以在根目录

  p->state = RUNNABLE;    //将进程的状态改为runable
}

void 
confirmalloc()
{
  struct proc *p;
  if((p = allocproc()) == 0)  //分配一个进程
      cprintf("Faild in building\n");
  else cprintf("Building process %d successed!!\n",p->pid);
//  procinit();
//  cprintf("Building process %d successed!!\n",currentproc->pid);
}
