// Memory layout

#define EXTMEM  0x100000            // 扩展内存的入口
#define PHYSTOP 0xE000000           // 到此地址的物理内存将作为空闲池
#define DEVSPACE 0xFE000000         // 其他设备在高地址

// Key addresses for address space layout (see kmap in vm.c for layout)
#define KERNBASE 0x80000000         // 第一个内核虚拟内存
#define KERNLINK (KERNBASE+EXTMEM)  // 内核被链接的地址

#ifndef __ASSEMBLER__

static inline uint v2p(void *a) { return ((uint) (a))  - KERNBASE; }
static inline void *p2v(uint a) { return (void *) ((a) + KERNBASE); }

#endif

#define V2P(a) (((uint) (a)) - KERNBASE)  //虚拟内存到物理内存
#define P2V(a) (((void *) (a)) + KERNBASE) //物理内存到虚拟内存

#define V2P_WO(x) ((x) - KERNBASE)    // same as V2P, but without casts
#define P2V_WO(x) ((x) + KERNBASE)    // same as V2P, but without casts
