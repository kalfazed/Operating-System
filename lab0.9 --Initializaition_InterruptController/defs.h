
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

// string.c
void* 	        memset(void*, int, uint);

// kalloc.c
void  		kinit(void*, void*);
char* 		kalloc(void);

// picirq.c
void 		picinit(void);
void 		picenable(int);

// ioapic.c
void 		ioapicinit(void);
void 		ioapicenable(int, int);

// kbd.c
void 		kbdintr(void);

// trap.c
void 		tvinit(void);
void 		idtinit(void);
void 		printidt(void);
extern int 	ismp;

// number of elements in fixed-size array
#define NELEM(x) (sizeof(x)/sizeof((x)[0]))
