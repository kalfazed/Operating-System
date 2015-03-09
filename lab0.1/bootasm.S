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

# 调用显示字符串例程

  call DispStr
  jmp .

DispStr:
  movw $BootMessage, %ax
  movw %ax, %bp  #ES:BP = 串地址
  movw $31,%cx          #%cx=长度
  movw $0x1301, %ax  #AH = 13, AL = 01h  写字符串并移动光标到串结尾处
  movw $0x00F, %bx  #页号为0(BH=0) 黑底红字(BL=0Ch,高亮）改message的颜色
  movb $2, %dl  #movw $0x1110,%dx  字符串显示在第18行17列
  int $0x10#调用10h号中断 屏幕显示
  ret
BootMessage: .ascii "hello,blcu,my name is xiehaiyan"# 表示0个或多个字符，并吧每个字符串中的字符放在连续的存储单元中
.org 510#填充到510字节处
.word 0xaa55 #结束标志
