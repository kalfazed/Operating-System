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

# 调用显示字符串例程

call Clear
call DispStr
call Typing
jmp .

Clear: 	 movb $0x07, %ah #功能号07，这里调用07和06结果一样，上卷下卷都是一样的。
  	 movb $0, %al    #上卷全部行，即清屏
  	 movb $0, %ch    #左上角行
  	 movb $0, %cl    #左上角列
  	 movb $24, %dh   #右下角行
  	 movb $79, %dl   #右下角列
  	 movb $0x07, %bh #卷入行的属性 
  	 int  $0x10      
  	 movb $0x02, %ah #这时候光标的位置是在中间的位置，需要重置一下位置
	 movw $0x00, %dx #光标的行与列都是0和0
	 movb $0x00, %bh #页号是0
	 int  $0x10
	 ret  

DispStr: movw $BootMessage, %ax
 	 movw %ax, %bp  #ES:BP = 串地址
	 movw $16, %cx  #CX =  串长度
  	 movw $0x1301, %ax  #AH = 13, AL = 01h,这里面是调用了10h号中断的13号功能
  	 movw $0x00c, %bx  #页号为0(BH=0) 黑底红字(BL=0Ch,高亮)
  	 movb $0, %dl #表示起始行号
  	 int  $0x10  #调用10h号中断
	 call Fill
  	 ret
BootMessage: .ascii "hello, BLCU OS, My name is ChenPeng"

Typing:  movb $0x02, %ah #ah = 00h，从键盘读取字符，读取的内容保存到al中
    	 int  $0x16   	 #调用BIOS16h中断，是键盘控制中断
	cmpb $0x, %al #
	jz Break

	 movb $0x00, %ah #ah = 00h，从键盘读取字符，读取的内容保存到al中
    	 int  $0x16   	 #调用BIOS16h中断，是键盘控制中断
  	 
	#比较字符的ascii码
	 cmpb $0x08, %al #比较输入的字符是不是Backspace键
	 jz   Back   
	 cmpb $0x0D, %al #比较输入的字符是不是Enter键
	 jz   Enter   
	
	#上下左右键, 包括其他的光标移动键和功能键, 都是没有 ascii 码的, 只有通过扫描码来判别究竟是哪个键
	 cmpb $0x48, %ah #比较输入的字符是不是Up键
	 jz   Up   
	 cmpb $0x50, %ah #比较输入的字符是不是Down键
	 jz   Down   
	 cmpb $0x4b, %ah #比较输入的字符是不是Left键
	 jz   Left  
	 cmpb $0x4d, %ah #比较输入的字符是不是Right键
	 jz   Right 
	 cmpb $0x4b, %ah #比较输入的字符是不是Right键
	 jz   Break  
	 
	 movb $0x0e, %ah #ah = 0eh，在光标处显示字符。光标随着字符而移动
	 int  $0x10      #调用BIOS10h中断，显示字符
	 
         call Typing
         ret 

Back:    movb $0x0e, %ah #ah = 0eh，在光标处显示字符。光标随着字符而移动	
	 movb $0x08, %al #先后退一个字符
	 int  $0x10
 	 movb $0x20, %al #输出空格
	 int  $0x10     
	 movb $0x08, %al #再后退一个字符
	 int  $0x10
	 call Typing                                                      	 

Enter:   call Fill 
	 call Typing
	 
Fill: 	 movb $0x0e,%ah   #ah = 0eh，在光标处显示字符。光标随着字符而移动
	 movb $0x0a,%al   #换行，这时候光标在垂直位置上保持当前值。
   	 int $0x10
  	 movb $0x0d,%al   #归位 回车
  	 int $0x10      
  	 ret
Break:	 movb $0x00, %ah #ah = 00h，从键盘读取字符，读取的内容保存到al中
    	 int  $0x16
	 cmpb $0x52, %ah
	 jz re
	 call Typing
re:	 int $0x19
	 ret
	call Typing

Left: 	 movb $0x0e, %ah #ah = 0eh，在光标处显示字符。光标随着字符而移动	
        movb $0x08, %al #先后退一个字符
        int  $0x10	 
	call Typing

.org 510  #填充到"510"字节处
.word 0xaa55 #结束标志
