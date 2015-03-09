# 第一个用户进程，执行execs /init

#include "syscall.h"
#include "traps.h"


# exec(init, argv)
.globl start
start:

#起初压栈参数argv以及init，同时再将SYS_exec传入eax中，表示用户的第一个进程就是执行
#一个系统调用，系统调用的编号是exec，参数是init，表示执行init操作，之后会转入到文件
#init.c中的main函数中执行操作

  pushl $argv
  pushl $init
  pushl $0  // 调用者pc来到的地址
  movl $SYS_exec, %eax
  int $T_SYSCALL


# char init[] = "/init\0";
init:
  .string "/init\0"

#argv是一个字符串数组，保存了当前的所有字符串，包括命令本身以及后面的参数

# char *argv[] = { init, 0 };
.p2align 2
argv:
  .long init
  .long 0

