#include "types.h"
#include "defs.h"
#include "memlayout.h"
#include "mmu.h"
#include "x86.h"

static void consputc(int);

static void
printint(int xx, int base, int sign)
{
  static char digits[] = "0123456789abcdef";
  char buf[16];
  int i;
  uint x;

  if(sign && (sign = xx < 0))	
    x = -xx;
  else
    x = xx;

  i = 0;
  do{
    buf[i++] = digits[x % base];
  }while((x /= base) != 0);

  if(sign)
    buf[i++] = '-';

  while(--i >= 0)
    consputc(buf[i]);
}

void
cprintf(char *fmt, ...)
{
  int i, c;
  uint *argp;		
  char *s;

  argp = (uint*)(void*)(&fmt + 1);//字符串首字母的地址
  for(i = 0; (c = fmt[i] & 0xff) != 0; i++){
    if(c != '%'){
      consputc(c);	//如果不是%直接调用consputc()输出字符
      continue;
    }			
    c = fmt[++i] & 0xff;//如果是%那么看下一个字符
    if(c == 0)
      break;
    switch(c){
    case 'd':		//%d输出十进制整型
      printint(*argp++, 10, 1);
      break;
    case 'x':
    case 'p':		//%p输出十六进制
      printint(*argp++, 16, 0);
      break;
    case 's':		//输出字符串
      if((s = (char*)*argp++) == 0)
        s = "(null)";
      for(; *s; s++)
        consputc(*s);
      break;
//    case '%':		
//      consputc('%');
//      break;
    default:		//其余情况不是输出格式而是直接输出%和字符
      consputc('%');
      consputc(c);
      break;
    }
  }

}


//PAGEBREAK: 50
#define BACKSPACE 0x100
#define CRTPORT 0x3d4
static ushort *crt = (ushort*)P2V(0xb8000);  // CGA memory Color Graphics Adapter彩色图形适配器(CGA)			
			//彩色模式的显存起始地址为0xb8000，CRT索引寄存器端口0x3d4，CRT数据寄存器端口0x3d5
static void
cgaputc(int c)		//读取光标位置，得到光标处显存的地址，写入字符
{
  int pos;
  
  // Cursor position: col + 80*row. 每行80个字符，所以光标位置为 col + 80*row
  //先向 0x3d4 端口写入要访问的寄存器编号,再通过0x3d5端口来读写寄存器数据。
  //存放光标位置的寄存器编号为 14 和 15。两个寄存器合起来组成一个 16 位整数,这个整数就是光标的位置pos。
  outb(CRTPORT, 14);		//向索引寄存器写入14（0xE），要访问的寄存器编号为14
  pos = inb(CRTPORT+1) << 8;	//从编号为14的数据寄存器读出数据，左移8位，给pos的高八位，即光标位置的高八位
  outb(CRTPORT, 15);		//要访问的寄存器编号为14
  pos |= inb(CRTPORT+1);	//从编号为14的数据寄存读出数据给pos的低八位，即光标位置的低八位

  if(c == '\n')			//换行符
    pos += 80 - pos%80;
  else if(c == BACKSPACE){	//backspace
    if(pos > 0) --pos;
  } else
    crt[pos++] = (c&0xff) | 0x0700;  // black on white 高八位为字符，低八位为字符属性

  outb(CRTPORT, 14);
  outb(CRTPORT+1, pos>>8);	//pos的高八位写入14号寄存器
  outb(CRTPORT, 15);
  outb(CRTPORT+1, pos);		//低八位+1写入15号寄存器，即光标后移一位。
  crt[pos] = ' ' | 0x0700;	
}

void
consputc(int c)
{
  cgaputc	(c);		//向显存写字符
}




