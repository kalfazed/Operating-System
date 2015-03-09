
// console.c
void            cprintf(char*, ...);

// uart.c
void            uartputc(int);

// vm.c
void            seginit(void);
void 		kvmalloc(void);
void 		segshow(void);

// string.c
void* 	        memset(void*, int, uint);

//kalloc.c
void  		kinit(void*, void*);


// number of elements in fixed-size array
#define NELEM(x) (sizeof(x)/sizeof((x)[0]))
