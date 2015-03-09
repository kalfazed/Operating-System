//上下文
struct context {
  uint edi;
  uint esi;
  uint ebx;
  uint ebp;
  uint eip;
};

//每一个进程的状态
enum procstate { UNUSED, EMBRYO, SLEEPING, RUNNABLE, RUNNING, ZOMBIE, ALLOCATED };

//进程结构
struct proc {
  uint sz;                     // 进程所需要的最大内存空间
  pde_t* pgdir;                // 页表
  char *kstack;                // 该进程所指向的内核栈的栈底指针
  enum procstate state;        // 进程状态
  volatile int pid;            // 进程ID
  struct trapframe *tf;        // 陷入帧
  struct context *context;     // 上下文，swtch()函数会到这里来执行
  struct inode *cwd;           // 当前目录
  char name[16];               // 进程名字
};
