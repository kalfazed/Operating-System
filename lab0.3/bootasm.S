/*
Author:	 Han

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


#清屏
  call ClearScr
	
# 调用显示字符串例程
  
  call DispStr
  jmp .

#清屏函数
ClearScr:
  movb $0x06, %ah #功能号06
  movb $0, %al #上卷全部行，即清屏
  movb $0, %ch #左上角行
  movb $0, %cl
  movb $24, %dh
  movb $79, %dl
  movb $0x07, %bh
  int $0x10
  ret  


DispStr:
  movw $BootMessage, %ax
  movw %ax, %bp  #ES:BP = 串地址
  movw $40, %cx  #CX =  串长度
  movw $0x1301, %ax  #AH = 13, AL = 01h
  movw $0x00c, %bx  #页号为0(BH=0) 黑底红字(BL=0Ch,高亮)
  movb $0, %dl
  int $0x10  #调用10h号中断
  ret
BootMessage: .ascii "hello, BLCU OS, My name is Han"
.org 510  #填充到"510"字节处
.word 0xaa55 #结束标志
