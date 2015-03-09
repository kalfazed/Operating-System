#define NSEGS 	7

struct cpu{
    struct segdesc gdt[NSEGS];
    struct cpu *cpu;
};

extern struct cpu *cpu asm("%gs:0");      
extern struct cpu cpus[1];
