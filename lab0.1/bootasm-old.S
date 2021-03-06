/*
Author:	 Chen Peng <chenpeng@blcu.edu.cn>

Boot code
*/
.code16  #16位模式
  cli    #关闭中断
  cld    #关字符串操作自动增加

# 设置重要数据段寄存器

  xorw %ax, %ax  #将ax清零
  movw %ax, %ds  #初始化数据段寄存器
  movw %ax, %es  #初始化附加段寄存器
  movw %ax, %ss  #初始化堆栈段寄存器

# 通过向显存中写字节流在屏幕中打印"hello world"

  movw $0xb800, %ax #显存地址
  movw %ax, %es
  movw $msg1, %si  #存信息 堆站段数据偏移量
  movw $0xc82, %di
  movw $6, %cx  #msg1长度
  rep movsb

  movw $str, %si  #存信息
  movw $0xc94, %di
  movw $26, %cx  #str长度
  rep movsb

msg1:
  .byte 'r', 0xc,'e',0xc,'l',0xc
str:
  .byte ':',0xc,' ',0xc,'h',0xc,'e',0xc,'l',0xc,'l',0xc,'o',0xc,',',0xc,'y',0xc,'o',0xc,'u',0xc,'!',0xc

.org 510  #填充到"510"字节处
.word 0xaa55 
#结束标志 .word expression 预留两字节，并将该两字节的内容赋值为expression
