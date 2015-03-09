#include "types.h"
#include "param.h"
#include "x86.h"
#include "mmu.h"
#include "proc.h"
#include "cpu.h"
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
  extern char _binary_initcode_start[], _binary_initcode_size[]; //initcode的起始地址以及大小
  
  p = allocproc(); //分配一个进程
  currentproc = p; //当前进程
  p->pgdir = setupkvm(); //设置这个进程的页表
  inituvm(p->pgdir, _binary_initcode_start, (int)_binary_initcode_size);  //将initcode装载到pgdir的0地址处
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
scheduler(void)
{
  struct proc *p;

  //无限循环
  for(;;){
    //打开这个CPU的所有中断
      sti();

    // 循环遍历进程表，查找到一个进程以后就开始执行
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
      if(p->state != RUNNABLE)
        continue;

      // 找到可以runable的进程，准备执行
      proc = p;
      switchuvm(p);  //切换到这个进程的页表
      p->state = RUNNING;  //将这个进程的状态更改为running
      swtch(&cpu->scheduler, proc->context);  //切换到进程上下文，同时保存当前上下文
      
      switchkvm(); //转回到内核页表

      //到目前位置进程已经执行完毕，回到此处之前要更改进程的状态
      proc = 0;  //CPU当前运行进程置空
    }

  }
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
