struct proc;
struct context;

// console.c
void            cprintf(char*, ...);
void 		consoleinit(void);
void            consoleintr(int(*)(void));

// uart.c
void            uartputc(int);

// vm.c
void            seginit(void);
void 		segshow(void);
void 		kvmalloc(void);
void 		inituvm(pde_t*, char*, uint);
pde_t* 		setupkvm(void);
void 		switchuvm(struct proc*);
void 		switchkvm();

// swtch.S
void 		swtch(struct context**, struct context*);

// string.c
void* 	        memset(void*, int, uint);
void* 		memmove(void*, const void*, uint);

// kalloc.c
void  		kinit(void*, void*);
char* 		kalloc(void);

// picirq.c
void 		picinit(void);
void 		picenable(int);

// proc.c
void  		userinit(void);
void 	  	printproc(void);
void 		confirmalloc(void);
void 		printproc();
void 		scheduler();

// ioapic.c
void 		ioapicinit(void);
void 		ioapicenable(int, int);

// kbd.c
void 		kbdintr(void);

// syscall.c
void 		syscall(void);

// trap.c
void 		tvinit(void);
void 		idtinit(void);
void 		printidt(void);
extern int 	ismp;

// number of elements in fixed-size array
#define NELEM(x) (sizeof(x)/sizeof((x)[0]))
