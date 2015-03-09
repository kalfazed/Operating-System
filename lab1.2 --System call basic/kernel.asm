
kernel:     file format elf32-i386


Disassembly of section .text:

80100000 <multiboot_header>:
80100000:	02 b0 ad 1b 00 00    	add    0x1bad(%eax),%dh
80100006:	00 00                	add    %al,(%eax)
80100008:	fe 4f 52             	decb   0x52(%edi)
8010000b:	e4 0f                	in     $0xf,%al

8010000c <entry>:

# Entering xv6 on boot processor, with paging off.
.globl entry
entry:
  # Turn on page size extension for 4Mbyte pages
  movl    %cr4, %eax
8010000c:	0f 20 e0             	mov    %cr4,%eax
  orl     $(CR4_PSE), %eax
8010000f:	83 c8 10             	or     $0x10,%eax
  movl    %eax, %cr4
80100012:	0f 22 e0             	mov    %eax,%cr4
  # Set page directory
  movl    $(V2P_WO(entrypgdir)), %eax
80100015:	b8 00 30 10 00       	mov    $0x103000,%eax
  movl    %eax, %cr3
8010001a:	0f 22 d8             	mov    %eax,%cr3
  # Turn on paging.
  movl    %cr0, %eax
8010001d:	0f 20 c0             	mov    %cr0,%eax
  orl     $(CR0_PG|CR0_WP), %eax
80100020:	0d 00 00 01 80       	or     $0x80010000,%eax
  movl    %eax, %cr0
80100025:	0f 22 c0             	mov    %eax,%cr0

  # Set up the stack pointer.
  movl $(stack + KSTACKSIZE), %esp
80100028:	bc 50 5f 10 80       	mov    $0x80105f50,%esp

  # Jump to main(), and switch to executing at
  # high addresses. The indirect call is needed because
  # the assembler produces a PC-relative instruction
  # for a direct jump.
  mov $main, %eax
8010002d:	b8 3a 00 10 80       	mov    $0x8010003a,%eax
  jmp *%eax
80100032:	ff e0                	jmp    *%eax

80100034 <sti>:
  asm volatile("cli");
}

static inline void
sti(void)
{
80100034:	55                   	push   %ebp
80100035:	89 e5                	mov    %esp,%ebp
  asm volatile("sti");
80100037:	fb                   	sti    
}
80100038:	5d                   	pop    %ebp
80100039:	c3                   	ret    

8010003a <main>:
extern char end[]; // first address after kernel loaded from ELF file


int
main(void)
{
8010003a:	8d 4c 24 04          	lea    0x4(%esp),%ecx
8010003e:	83 e4 f0             	and    $0xfffffff0,%esp
80100041:	ff 71 fc             	pushl  -0x4(%ecx)
80100044:	55                   	push   %ebp
80100045:	89 e5                	mov    %esp,%ebp
80100047:	51                   	push   %ecx
80100048:	83 ec 04             	sub    $0x4,%esp
  cprintf("Welcome!!\n");
8010004b:	83 ec 0c             	sub    $0xc,%esp
8010004e:	68 80 28 10 80       	push   $0x80102880
80100053:	e8 35 01 00 00       	call   8010018d <cprintf>
80100058:	83 c4 10             	add    $0x10,%esp
 
//第一部分的实验，完成内存分配 
  kinit(end, P2V(4*1024*1024));  // 物理页的分配
8010005b:	83 ec 08             	sub    $0x8,%esp
8010005e:	68 00 00 40 80       	push   $0x80400000
80100063:	68 00 77 10 80       	push   $0x80107700
80100068:	e8 db 07 00 00       	call   80100848 <kinit>
8010006d:	83 c4 10             	add    $0x10,%esp
//  cprintf("Current pgdir is %x\n",kpgdir);
  kvmalloc(); 			 // 内核页表
80100070:	e8 ae 11 00 00       	call   80101223 <kvmalloc>
//  cprintf("Current pgdir is %x\n",kpgdir);
  seginit();   			 // 初始化段，这里对段的初始化是对当前cpu的gdt的初始化
80100075:	e8 07 0a 00 00       	call   80100a81 <seginit>
//  segshow();   		 // 打印一些段的信息，用来验证

//第二部分的实验，完成中断处理
  picinit(); 			 // 初始化中断控制器8259A 
8010007a:	e8 f0 13 00 00       	call   8010146f <picinit>
  ioapicinit(); 		 // 初始化IOAAPIC中断控制器
8010007f:	e8 f0 17 00 00       	call   80101874 <ioapicinit>
  consoleinit(); 		 // 初始化控制台
80100084:	e8 c2 03 00 00       	call   8010044b <consoleinit>
  tvinit(); 			 // 初始化idt，扩充idt中中断描述符的内容
80100089:	e8 42 25 00 00       	call   801025d0 <tvinit>
  idtinit(); 			 // 加载idt
8010008e:	e8 fc 26 00 00       	call   8010278f <idtinit>
//  printidt(); 	         // 打印一些idt的信息，用来验证

  userinit(); 			 // 初始化一个用户进程
80100093:	e8 19 16 00 00       	call   801016b1 <userinit>
  scheduler();  		 // 进程调度
80100098:	e8 e6 16 00 00       	call   80101783 <scheduler>
//  cprintf("User initial has finished!!!\n");
  sti();
8010009d:	e8 92 ff ff ff       	call   80100034 <sti>

  while(1);
801000a2:	eb fe                	jmp    801000a2 <main+0x68>

801000a4 <inb>:
// Routines to let C code use special x86 instructions.

static inline uchar
inb(ushort port)
{
801000a4:	55                   	push   %ebp
801000a5:	89 e5                	mov    %esp,%ebp
801000a7:	83 ec 14             	sub    $0x14,%esp
801000aa:	8b 45 08             	mov    0x8(%ebp),%eax
801000ad:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
  uchar data;

  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
801000b1:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
801000b5:	89 c2                	mov    %eax,%edx
801000b7:	ec                   	in     (%dx),%al
801000b8:	88 45 ff             	mov    %al,-0x1(%ebp)
  return data;
801000bb:	0f b6 45 ff          	movzbl -0x1(%ebp),%eax
}
801000bf:	c9                   	leave  
801000c0:	c3                   	ret    

801000c1 <outb>:
               "memory", "cc");
}

static inline void
outb(ushort port, uchar data)
{
801000c1:	55                   	push   %ebp
801000c2:	89 e5                	mov    %esp,%ebp
801000c4:	83 ec 08             	sub    $0x8,%esp
801000c7:	8b 55 08             	mov    0x8(%ebp),%edx
801000ca:	8b 45 0c             	mov    0xc(%ebp),%eax
801000cd:	66 89 55 fc          	mov    %dx,-0x4(%ebp)
801000d1:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
801000d4:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
801000d8:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
801000dc:	ee                   	out    %al,(%dx)
}
801000dd:	c9                   	leave  
801000de:	c3                   	ret    

801000df <printint>:
static void consputc(int);


static void
printint(int xx, int base, int sign)
{
801000df:	55                   	push   %ebp
801000e0:	89 e5                	mov    %esp,%ebp
801000e2:	53                   	push   %ebx
801000e3:	83 ec 24             	sub    $0x24,%esp
  static char digits[] = "0123456789abcdef";
  char buf[16];
  int i;
  uint x;

  if(sign && (sign = xx < 0))
801000e6:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
801000ea:	74 1c                	je     80100108 <printint+0x29>
801000ec:	8b 45 08             	mov    0x8(%ebp),%eax
801000ef:	c1 e8 1f             	shr    $0x1f,%eax
801000f2:	0f b6 c0             	movzbl %al,%eax
801000f5:	89 45 10             	mov    %eax,0x10(%ebp)
801000f8:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
801000fc:	74 0a                	je     80100108 <printint+0x29>
    x = -xx;
801000fe:	8b 45 08             	mov    0x8(%ebp),%eax
80100101:	f7 d8                	neg    %eax
80100103:	89 45 f0             	mov    %eax,-0x10(%ebp)
80100106:	eb 06                	jmp    8010010e <printint+0x2f>
  else
    x = xx;
80100108:	8b 45 08             	mov    0x8(%ebp),%eax
8010010b:	89 45 f0             	mov    %eax,-0x10(%ebp)

  i = 0;
8010010e:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  do{
    buf[i++] = digits[x % base];
80100115:	8b 4d f4             	mov    -0xc(%ebp),%ecx
80100118:	8d 41 01             	lea    0x1(%ecx),%eax
8010011b:	89 45 f4             	mov    %eax,-0xc(%ebp)
8010011e:	8b 5d 0c             	mov    0xc(%ebp),%ebx
80100121:	8b 45 f0             	mov    -0x10(%ebp),%eax
80100124:	ba 00 00 00 00       	mov    $0x0,%edx
80100129:	f7 f3                	div    %ebx
8010012b:	89 d0                	mov    %edx,%eax
8010012d:	0f b6 80 04 40 10 80 	movzbl -0x7fefbffc(%eax),%eax
80100134:	88 44 0d e0          	mov    %al,-0x20(%ebp,%ecx,1)
  }while((x /= base) != 0);
80100138:	8b 5d 0c             	mov    0xc(%ebp),%ebx
8010013b:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010013e:	ba 00 00 00 00       	mov    $0x0,%edx
80100143:	f7 f3                	div    %ebx
80100145:	89 45 f0             	mov    %eax,-0x10(%ebp)
80100148:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
8010014c:	75 c7                	jne    80100115 <printint+0x36>

  if(sign)
8010014e:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80100152:	74 0e                	je     80100162 <printint+0x83>
    buf[i++] = '-';
80100154:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100157:	8d 50 01             	lea    0x1(%eax),%edx
8010015a:	89 55 f4             	mov    %edx,-0xc(%ebp)
8010015d:	c6 44 05 e0 2d       	movb   $0x2d,-0x20(%ebp,%eax,1)

  while(--i >= 0)
80100162:	eb 1a                	jmp    8010017e <printint+0x9f>
    consputc(buf[i]);
80100164:	8d 55 e0             	lea    -0x20(%ebp),%edx
80100167:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010016a:	01 d0                	add    %edx,%eax
8010016c:	0f b6 00             	movzbl (%eax),%eax
8010016f:	0f be c0             	movsbl %al,%eax
80100172:	83 ec 0c             	sub    $0xc,%esp
80100175:	50                   	push   %eax
80100176:	e8 7a 02 00 00       	call   801003f5 <consputc>
8010017b:	83 c4 10             	add    $0x10,%esp
  }while((x /= base) != 0);

  if(sign)
    buf[i++] = '-';

  while(--i >= 0)
8010017e:	83 6d f4 01          	subl   $0x1,-0xc(%ebp)
80100182:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80100186:	79 dc                	jns    80100164 <printint+0x85>
    consputc(buf[i]);
}
80100188:	8b 5d fc             	mov    -0x4(%ebp),%ebx
8010018b:	c9                   	leave  
8010018c:	c3                   	ret    

8010018d <cprintf>:

void
cprintf(char *fmt, ...)
{
8010018d:	55                   	push   %ebp
8010018e:	89 e5                	mov    %esp,%ebp
80100190:	83 ec 18             	sub    $0x18,%esp
  int i, c;
  uint *argp;
  char *s;

  argp = (uint*)(void*)(&fmt + 1);
80100193:	8d 45 0c             	lea    0xc(%ebp),%eax
80100196:	89 45 f0             	mov    %eax,-0x10(%ebp)
  for(i = 0; (c = fmt[i] & 0xff) != 0; i++){
80100199:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801001a0:	e9 1b 01 00 00       	jmp    801002c0 <cprintf+0x133>
    if(c != '%'){
801001a5:	83 7d e8 25          	cmpl   $0x25,-0x18(%ebp)
801001a9:	74 13                	je     801001be <cprintf+0x31>
      consputc(c);
801001ab:	83 ec 0c             	sub    $0xc,%esp
801001ae:	ff 75 e8             	pushl  -0x18(%ebp)
801001b1:	e8 3f 02 00 00       	call   801003f5 <consputc>
801001b6:	83 c4 10             	add    $0x10,%esp
      continue;
801001b9:	e9 fe 00 00 00       	jmp    801002bc <cprintf+0x12f>
    }
    c = fmt[++i] & 0xff;
801001be:	8b 55 08             	mov    0x8(%ebp),%edx
801001c1:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801001c5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801001c8:	01 d0                	add    %edx,%eax
801001ca:	0f b6 00             	movzbl (%eax),%eax
801001cd:	0f be c0             	movsbl %al,%eax
801001d0:	25 ff 00 00 00       	and    $0xff,%eax
801001d5:	89 45 e8             	mov    %eax,-0x18(%ebp)
    if(c == 0)
801001d8:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
801001dc:	75 05                	jne    801001e3 <cprintf+0x56>
      break;
801001de:	e9 fd 00 00 00       	jmp    801002e0 <cprintf+0x153>
    switch(c){
801001e3:	8b 45 e8             	mov    -0x18(%ebp),%eax
801001e6:	83 f8 70             	cmp    $0x70,%eax
801001e9:	74 47                	je     80100232 <cprintf+0xa5>
801001eb:	83 f8 70             	cmp    $0x70,%eax
801001ee:	7f 13                	jg     80100203 <cprintf+0x76>
801001f0:	83 f8 25             	cmp    $0x25,%eax
801001f3:	0f 84 98 00 00 00    	je     80100291 <cprintf+0x104>
801001f9:	83 f8 64             	cmp    $0x64,%eax
801001fc:	74 14                	je     80100212 <cprintf+0x85>
801001fe:	e9 9d 00 00 00       	jmp    801002a0 <cprintf+0x113>
80100203:	83 f8 73             	cmp    $0x73,%eax
80100206:	74 47                	je     8010024f <cprintf+0xc2>
80100208:	83 f8 78             	cmp    $0x78,%eax
8010020b:	74 25                	je     80100232 <cprintf+0xa5>
8010020d:	e9 8e 00 00 00       	jmp    801002a0 <cprintf+0x113>
    case 'd':
      printint(*argp++, 10, 1);
80100212:	8b 45 f0             	mov    -0x10(%ebp),%eax
80100215:	8d 50 04             	lea    0x4(%eax),%edx
80100218:	89 55 f0             	mov    %edx,-0x10(%ebp)
8010021b:	8b 00                	mov    (%eax),%eax
8010021d:	83 ec 04             	sub    $0x4,%esp
80100220:	6a 01                	push   $0x1
80100222:	6a 0a                	push   $0xa
80100224:	50                   	push   %eax
80100225:	e8 b5 fe ff ff       	call   801000df <printint>
8010022a:	83 c4 10             	add    $0x10,%esp
      break;
8010022d:	e9 8a 00 00 00       	jmp    801002bc <cprintf+0x12f>
    case 'x':
    case 'p':
      printint(*argp++, 16, 0);
80100232:	8b 45 f0             	mov    -0x10(%ebp),%eax
80100235:	8d 50 04             	lea    0x4(%eax),%edx
80100238:	89 55 f0             	mov    %edx,-0x10(%ebp)
8010023b:	8b 00                	mov    (%eax),%eax
8010023d:	83 ec 04             	sub    $0x4,%esp
80100240:	6a 00                	push   $0x0
80100242:	6a 10                	push   $0x10
80100244:	50                   	push   %eax
80100245:	e8 95 fe ff ff       	call   801000df <printint>
8010024a:	83 c4 10             	add    $0x10,%esp
      break;
8010024d:	eb 6d                	jmp    801002bc <cprintf+0x12f>
    case 's':
      if((s = (char*)*argp++) == 0)
8010024f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80100252:	8d 50 04             	lea    0x4(%eax),%edx
80100255:	89 55 f0             	mov    %edx,-0x10(%ebp)
80100258:	8b 00                	mov    (%eax),%eax
8010025a:	89 45 ec             	mov    %eax,-0x14(%ebp)
8010025d:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80100261:	75 07                	jne    8010026a <cprintf+0xdd>
        s = "(null)";
80100263:	c7 45 ec 8b 28 10 80 	movl   $0x8010288b,-0x14(%ebp)
      for(; *s; s++)
8010026a:	eb 19                	jmp    80100285 <cprintf+0xf8>
        consputc(*s);
8010026c:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010026f:	0f b6 00             	movzbl (%eax),%eax
80100272:	0f be c0             	movsbl %al,%eax
80100275:	83 ec 0c             	sub    $0xc,%esp
80100278:	50                   	push   %eax
80100279:	e8 77 01 00 00       	call   801003f5 <consputc>
8010027e:	83 c4 10             	add    $0x10,%esp
      printint(*argp++, 16, 0);
      break;
    case 's':
      if((s = (char*)*argp++) == 0)
        s = "(null)";
      for(; *s; s++)
80100281:	83 45 ec 01          	addl   $0x1,-0x14(%ebp)
80100285:	8b 45 ec             	mov    -0x14(%ebp),%eax
80100288:	0f b6 00             	movzbl (%eax),%eax
8010028b:	84 c0                	test   %al,%al
8010028d:	75 dd                	jne    8010026c <cprintf+0xdf>
        consputc(*s);
      break;
8010028f:	eb 2b                	jmp    801002bc <cprintf+0x12f>
    case '%':
      consputc('%');
80100291:	83 ec 0c             	sub    $0xc,%esp
80100294:	6a 25                	push   $0x25
80100296:	e8 5a 01 00 00       	call   801003f5 <consputc>
8010029b:	83 c4 10             	add    $0x10,%esp
      break;
8010029e:	eb 1c                	jmp    801002bc <cprintf+0x12f>
    default:
      consputc('%');
801002a0:	83 ec 0c             	sub    $0xc,%esp
801002a3:	6a 25                	push   $0x25
801002a5:	e8 4b 01 00 00       	call   801003f5 <consputc>
801002aa:	83 c4 10             	add    $0x10,%esp
      consputc(c);
801002ad:	83 ec 0c             	sub    $0xc,%esp
801002b0:	ff 75 e8             	pushl  -0x18(%ebp)
801002b3:	e8 3d 01 00 00       	call   801003f5 <consputc>
801002b8:	83 c4 10             	add    $0x10,%esp
      break;
801002bb:	90                   	nop
  int i, c;
  uint *argp;
  char *s;

  argp = (uint*)(void*)(&fmt + 1);
  for(i = 0; (c = fmt[i] & 0xff) != 0; i++){
801002bc:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801002c0:	8b 55 08             	mov    0x8(%ebp),%edx
801002c3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801002c6:	01 d0                	add    %edx,%eax
801002c8:	0f b6 00             	movzbl (%eax),%eax
801002cb:	0f be c0             	movsbl %al,%eax
801002ce:	25 ff 00 00 00       	and    $0xff,%eax
801002d3:	89 45 e8             	mov    %eax,-0x18(%ebp)
801002d6:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
801002da:	0f 85 c5 fe ff ff    	jne    801001a5 <cprintf+0x18>
      consputc(c);
      break;
    }
  }

}
801002e0:	c9                   	leave  
801002e1:	c3                   	ret    

801002e2 <cgaputc>:

static ushort *crt = (ushort*)P2V(0xb8000);  // CGA memory

static void
cgaputc(int c)
{
801002e2:	55                   	push   %ebp
801002e3:	89 e5                	mov    %esp,%ebp
801002e5:	83 ec 10             	sub    $0x10,%esp
  int pos;
  
  // Cursor position: col + 80*row.
  outb(CRTPORT, 14);
801002e8:	6a 0e                	push   $0xe
801002ea:	68 d4 03 00 00       	push   $0x3d4
801002ef:	e8 cd fd ff ff       	call   801000c1 <outb>
801002f4:	83 c4 08             	add    $0x8,%esp
  pos = inb(CRTPORT+1) << 8;
801002f7:	68 d5 03 00 00       	push   $0x3d5
801002fc:	e8 a3 fd ff ff       	call   801000a4 <inb>
80100301:	83 c4 04             	add    $0x4,%esp
80100304:	0f b6 c0             	movzbl %al,%eax
80100307:	c1 e0 08             	shl    $0x8,%eax
8010030a:	89 45 fc             	mov    %eax,-0x4(%ebp)
  outb(CRTPORT, 15);
8010030d:	6a 0f                	push   $0xf
8010030f:	68 d4 03 00 00       	push   $0x3d4
80100314:	e8 a8 fd ff ff       	call   801000c1 <outb>
80100319:	83 c4 08             	add    $0x8,%esp
  pos |= inb(CRTPORT+1);
8010031c:	68 d5 03 00 00       	push   $0x3d5
80100321:	e8 7e fd ff ff       	call   801000a4 <inb>
80100326:	83 c4 04             	add    $0x4,%esp
80100329:	0f b6 c0             	movzbl %al,%eax
8010032c:	09 45 fc             	or     %eax,-0x4(%ebp)

  if(c == '\n')
8010032f:	83 7d 08 0a          	cmpl   $0xa,0x8(%ebp)
80100333:	75 30                	jne    80100365 <cgaputc+0x83>
  {
      pos += 80 - pos%80;
80100335:	8b 4d fc             	mov    -0x4(%ebp),%ecx
80100338:	ba 67 66 66 66       	mov    $0x66666667,%edx
8010033d:	89 c8                	mov    %ecx,%eax
8010033f:	f7 ea                	imul   %edx
80100341:	c1 fa 05             	sar    $0x5,%edx
80100344:	89 c8                	mov    %ecx,%eax
80100346:	c1 f8 1f             	sar    $0x1f,%eax
80100349:	29 c2                	sub    %eax,%edx
8010034b:	89 d0                	mov    %edx,%eax
8010034d:	c1 e0 02             	shl    $0x2,%eax
80100350:	01 d0                	add    %edx,%eax
80100352:	c1 e0 04             	shl    $0x4,%eax
80100355:	29 c1                	sub    %eax,%ecx
80100357:	89 ca                	mov    %ecx,%edx
80100359:	b8 50 00 00 00       	mov    $0x50,%eax
8010035e:	29 d0                	sub    %edx,%eax
80100360:	01 45 fc             	add    %eax,-0x4(%ebp)
80100363:	eb 34                	jmp    80100399 <cgaputc+0xb7>
  }
  else if(c == BACKSPACE){
80100365:	81 7d 08 00 01 00 00 	cmpl   $0x100,0x8(%ebp)
8010036c:	75 0c                	jne    8010037a <cgaputc+0x98>
    if(pos > 0) --pos;
8010036e:	83 7d fc 00          	cmpl   $0x0,-0x4(%ebp)
80100372:	7e 25                	jle    80100399 <cgaputc+0xb7>
80100374:	83 6d fc 01          	subl   $0x1,-0x4(%ebp)
80100378:	eb 1f                	jmp    80100399 <cgaputc+0xb7>
  } else
  {
      crt[pos++] = (c&0xff) | 0x0700;  // black on white
8010037a:	8b 0d 00 40 10 80    	mov    0x80104000,%ecx
80100380:	8b 45 fc             	mov    -0x4(%ebp),%eax
80100383:	8d 50 01             	lea    0x1(%eax),%edx
80100386:	89 55 fc             	mov    %edx,-0x4(%ebp)
80100389:	01 c0                	add    %eax,%eax
8010038b:	01 c8                	add    %ecx,%eax
8010038d:	8b 55 08             	mov    0x8(%ebp),%edx
80100390:	0f b6 d2             	movzbl %dl,%edx
80100393:	80 ce 07             	or     $0x7,%dh
80100396:	66 89 10             	mov    %dx,(%eax)
  }

  outb(CRTPORT, 14);
80100399:	6a 0e                	push   $0xe
8010039b:	68 d4 03 00 00       	push   $0x3d4
801003a0:	e8 1c fd ff ff       	call   801000c1 <outb>
801003a5:	83 c4 08             	add    $0x8,%esp
  outb(CRTPORT+1, pos>>8);
801003a8:	8b 45 fc             	mov    -0x4(%ebp),%eax
801003ab:	c1 f8 08             	sar    $0x8,%eax
801003ae:	0f b6 c0             	movzbl %al,%eax
801003b1:	50                   	push   %eax
801003b2:	68 d5 03 00 00       	push   $0x3d5
801003b7:	e8 05 fd ff ff       	call   801000c1 <outb>
801003bc:	83 c4 08             	add    $0x8,%esp
  outb(CRTPORT, 15);
801003bf:	6a 0f                	push   $0xf
801003c1:	68 d4 03 00 00       	push   $0x3d4
801003c6:	e8 f6 fc ff ff       	call   801000c1 <outb>
801003cb:	83 c4 08             	add    $0x8,%esp
  outb(CRTPORT+1, pos);
801003ce:	8b 45 fc             	mov    -0x4(%ebp),%eax
801003d1:	0f b6 c0             	movzbl %al,%eax
801003d4:	50                   	push   %eax
801003d5:	68 d5 03 00 00       	push   $0x3d5
801003da:	e8 e2 fc ff ff       	call   801000c1 <outb>
801003df:	83 c4 08             	add    $0x8,%esp
  crt[pos] = ' ' | 0x0700;
801003e2:	a1 00 40 10 80       	mov    0x80104000,%eax
801003e7:	8b 55 fc             	mov    -0x4(%ebp),%edx
801003ea:	01 d2                	add    %edx,%edx
801003ec:	01 d0                	add    %edx,%eax
801003ee:	66 c7 00 20 07       	movw   $0x720,(%eax)
}
801003f3:	c9                   	leave  
801003f4:	c3                   	ret    

801003f5 <consputc>:

void
consputc(int c)
{
801003f5:	55                   	push   %ebp
801003f6:	89 e5                	mov    %esp,%ebp
801003f8:	83 ec 08             	sub    $0x8,%esp
  if(c == BACKSPACE){
801003fb:	81 7d 08 00 01 00 00 	cmpl   $0x100,0x8(%ebp)
80100402:	75 29                	jne    8010042d <consputc+0x38>
    uartputc('\b'); uartputc(' '); uartputc('\b');
80100404:	83 ec 0c             	sub    $0xc,%esp
80100407:	6a 08                	push   $0x8
80100409:	e8 2c 24 00 00       	call   8010283a <uartputc>
8010040e:	83 c4 10             	add    $0x10,%esp
80100411:	83 ec 0c             	sub    $0xc,%esp
80100414:	6a 20                	push   $0x20
80100416:	e8 1f 24 00 00       	call   8010283a <uartputc>
8010041b:	83 c4 10             	add    $0x10,%esp
8010041e:	83 ec 0c             	sub    $0xc,%esp
80100421:	6a 08                	push   $0x8
80100423:	e8 12 24 00 00       	call   8010283a <uartputc>
80100428:	83 c4 10             	add    $0x10,%esp
8010042b:	eb 0e                	jmp    8010043b <consputc+0x46>
  } else
    uartputc(c);
8010042d:	83 ec 0c             	sub    $0xc,%esp
80100430:	ff 75 08             	pushl  0x8(%ebp)
80100433:	e8 02 24 00 00       	call   8010283a <uartputc>
80100438:	83 c4 10             	add    $0x10,%esp
  cgaputc(c);
8010043b:	83 ec 0c             	sub    $0xc,%esp
8010043e:	ff 75 08             	pushl  0x8(%ebp)
80100441:	e8 9c fe ff ff       	call   801002e2 <cgaputc>
80100446:	83 c4 10             	add    $0x10,%esp
}
80100449:	c9                   	leave  
8010044a:	c3                   	ret    

8010044b <consoleinit>:


void consoleinit(void)
{
8010044b:	55                   	push   %ebp
8010044c:	89 e5                	mov    %esp,%ebp
8010044e:	83 ec 08             	sub    $0x8,%esp
  picenable(IRQ_KBD);
80100451:	83 ec 0c             	sub    $0xc,%esp
80100454:	6a 01                	push   $0x1
80100456:	e8 e8 0f 00 00       	call   80101443 <picenable>
8010045b:	83 c4 10             	add    $0x10,%esp
  ioapicenable(IRQ_KBD, 0);
8010045e:	83 ec 08             	sub    $0x8,%esp
80100461:	6a 00                	push   $0x0
80100463:	6a 01                	push   $0x1
80100465:	e8 7b 14 00 00       	call   801018e5 <ioapicenable>
8010046a:	83 c4 10             	add    $0x10,%esp
}
8010046d:	c9                   	leave  
8010046e:	c3                   	ret    

8010046f <getcmd>:

#define C(x)  ((x)-'@')  // Control-x

int
getcmd()
{
8010046f:	55                   	push   %ebp
80100470:	89 e5                	mov    %esp,%ebp
	if((input.buf[0] == 'f')&&(input.buf[1] == 'o')&&(input.buf[2] == 'r')&&(input.buf[3] == 'k')&&(input.e == 4))
80100472:	0f b6 05 80 5f 10 80 	movzbl 0x80105f80,%eax
80100479:	3c 66                	cmp    $0x66,%al
8010047b:	75 32                	jne    801004af <getcmd+0x40>
8010047d:	0f b6 05 81 5f 10 80 	movzbl 0x80105f81,%eax
80100484:	3c 6f                	cmp    $0x6f,%al
80100486:	75 27                	jne    801004af <getcmd+0x40>
80100488:	0f b6 05 82 5f 10 80 	movzbl 0x80105f82,%eax
8010048f:	3c 72                	cmp    $0x72,%al
80100491:	75 1c                	jne    801004af <getcmd+0x40>
80100493:	0f b6 05 83 5f 10 80 	movzbl 0x80105f83,%eax
8010049a:	3c 6b                	cmp    $0x6b,%al
8010049c:	75 11                	jne    801004af <getcmd+0x40>
8010049e:	a1 08 60 10 80       	mov    0x80106008,%eax
801004a3:	83 f8 04             	cmp    $0x4,%eax
801004a6:	75 07                	jne    801004af <getcmd+0x40>
	{		
	    return 1;
801004a8:	b8 01 00 00 00       	mov    $0x1,%eax
801004ad:	eb 4d                	jmp    801004fc <getcmd+0x8d>
	}else if((input.buf[0] == 'p')&&(input.buf[1] == 'r')&&(input.buf[2] == 'i')&&(input.buf[3] == 'n')&&(input.buf[4] == 't')&&(input.e == 5))
801004af:	0f b6 05 80 5f 10 80 	movzbl 0x80105f80,%eax
801004b6:	3c 70                	cmp    $0x70,%al
801004b8:	75 3d                	jne    801004f7 <getcmd+0x88>
801004ba:	0f b6 05 81 5f 10 80 	movzbl 0x80105f81,%eax
801004c1:	3c 72                	cmp    $0x72,%al
801004c3:	75 32                	jne    801004f7 <getcmd+0x88>
801004c5:	0f b6 05 82 5f 10 80 	movzbl 0x80105f82,%eax
801004cc:	3c 69                	cmp    $0x69,%al
801004ce:	75 27                	jne    801004f7 <getcmd+0x88>
801004d0:	0f b6 05 83 5f 10 80 	movzbl 0x80105f83,%eax
801004d7:	3c 6e                	cmp    $0x6e,%al
801004d9:	75 1c                	jne    801004f7 <getcmd+0x88>
801004db:	0f b6 05 84 5f 10 80 	movzbl 0x80105f84,%eax
801004e2:	3c 74                	cmp    $0x74,%al
801004e4:	75 11                	jne    801004f7 <getcmd+0x88>
801004e6:	a1 08 60 10 80       	mov    0x80106008,%eax
801004eb:	83 f8 05             	cmp    $0x5,%eax
801004ee:	75 07                	jne    801004f7 <getcmd+0x88>
	{
	    return 2;
801004f0:	b8 02 00 00 00       	mov    $0x2,%eax
801004f5:	eb 05                	jmp    801004fc <getcmd+0x8d>
	}else return 0;
801004f7:	b8 00 00 00 00       	mov    $0x0,%eax
}
801004fc:	5d                   	pop    %ebp
801004fd:	c3                   	ret    

801004fe <consoleintr>:

void
consoleintr(int (*getc)(void))
{
801004fe:	55                   	push   %ebp
801004ff:	89 e5                	mov    %esp,%ebp
80100501:	83 ec 18             	sub    $0x18,%esp
  int c;

  while((c = getc()) >= 0){
80100504:	e9 86 01 00 00       	jmp    8010068f <consoleintr+0x191>
   switch(c){
80100509:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010050c:	83 f8 15             	cmp    $0x15,%eax
8010050f:	74 29                	je     8010053a <consoleintr+0x3c>
80100511:	83 f8 7f             	cmp    $0x7f,%eax
80100514:	74 4e                	je     80100564 <consoleintr+0x66>
80100516:	83 f8 08             	cmp    $0x8,%eax
80100519:	74 49                	je     80100564 <consoleintr+0x66>
8010051b:	eb 78                	jmp    80100595 <consoleintr+0x97>
    case C('U'):  // Kill line.
      while(input.e != input.w &&
            input.buf[(input.e-1) % INPUT_BUF] != '\n'){
        input.e--;
8010051d:	a1 08 60 10 80       	mov    0x80106008,%eax
80100522:	83 e8 01             	sub    $0x1,%eax
80100525:	a3 08 60 10 80       	mov    %eax,0x80106008
        consputc(BACKSPACE);
8010052a:	83 ec 0c             	sub    $0xc,%esp
8010052d:	68 00 01 00 00       	push   $0x100
80100532:	e8 be fe ff ff       	call   801003f5 <consputc>
80100537:	83 c4 10             	add    $0x10,%esp
  int c;

  while((c = getc()) >= 0){
   switch(c){
    case C('U'):  // Kill line.
      while(input.e != input.w &&
8010053a:	8b 15 08 60 10 80    	mov    0x80106008,%edx
80100540:	a1 04 60 10 80       	mov    0x80106004,%eax
80100545:	39 c2                	cmp    %eax,%edx
80100547:	74 16                	je     8010055f <consoleintr+0x61>
            input.buf[(input.e-1) % INPUT_BUF] != '\n'){
80100549:	a1 08 60 10 80       	mov    0x80106008,%eax
8010054e:	83 e8 01             	sub    $0x1,%eax
80100551:	83 e0 7f             	and    $0x7f,%eax
80100554:	0f b6 80 80 5f 10 80 	movzbl -0x7fefa080(%eax),%eax
  int c;

  while((c = getc()) >= 0){
   switch(c){
    case C('U'):  // Kill line.
      while(input.e != input.w &&
8010055b:	3c 0a                	cmp    $0xa,%al
8010055d:	75 be                	jne    8010051d <consoleintr+0x1f>
            input.buf[(input.e-1) % INPUT_BUF] != '\n'){
        input.e--;
        consputc(BACKSPACE);
      }
      break;
8010055f:	e9 2b 01 00 00       	jmp    8010068f <consoleintr+0x191>
    case C('H'): case '\x7f':  // Backspace
      if(input.e != input.w){
80100564:	8b 15 08 60 10 80    	mov    0x80106008,%edx
8010056a:	a1 04 60 10 80       	mov    0x80106004,%eax
8010056f:	39 c2                	cmp    %eax,%edx
80100571:	74 1d                	je     80100590 <consoleintr+0x92>
        input.e--;
80100573:	a1 08 60 10 80       	mov    0x80106008,%eax
80100578:	83 e8 01             	sub    $0x1,%eax
8010057b:	a3 08 60 10 80       	mov    %eax,0x80106008
        consputc(BACKSPACE);
80100580:	83 ec 0c             	sub    $0xc,%esp
80100583:	68 00 01 00 00       	push   $0x100
80100588:	e8 68 fe ff ff       	call   801003f5 <consputc>
8010058d:	83 c4 10             	add    $0x10,%esp
      }
      break;
80100590:	e9 fa 00 00 00       	jmp    8010068f <consoleintr+0x191>
    default:
      if(c != 0 && input.e-input.r < INPUT_BUF){
80100595:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80100599:	0f 84 ef 00 00 00    	je     8010068e <consoleintr+0x190>
8010059f:	8b 15 08 60 10 80    	mov    0x80106008,%edx
801005a5:	a1 00 60 10 80       	mov    0x80106000,%eax
801005aa:	29 c2                	sub    %eax,%edx
801005ac:	89 d0                	mov    %edx,%eax
801005ae:	83 f8 7f             	cmp    $0x7f,%eax
801005b1:	0f 87 d7 00 00 00    	ja     8010068e <consoleintr+0x190>
      	c = (c == '\r') ? '\n' : c;
801005b7:	83 7d f4 0d          	cmpl   $0xd,-0xc(%ebp)
801005bb:	74 05                	je     801005c2 <consoleintr+0xc4>
801005bd:	8b 45 f4             	mov    -0xc(%ebp),%eax
801005c0:	eb 05                	jmp    801005c7 <consoleintr+0xc9>
801005c2:	b8 0a 00 00 00       	mov    $0xa,%eax
801005c7:	89 45 f4             	mov    %eax,-0xc(%ebp)
        if(c == '\n' || c == C('D') || input.e == input.r+INPUT_BUF){
801005ca:	83 7d f4 0a          	cmpl   $0xa,-0xc(%ebp)
801005ce:	74 18                	je     801005e8 <consoleintr+0xea>
801005d0:	83 7d f4 04          	cmpl   $0x4,-0xc(%ebp)
801005d4:	74 12                	je     801005e8 <consoleintr+0xea>
801005d6:	a1 08 60 10 80       	mov    0x80106008,%eax
801005db:	8b 15 00 60 10 80    	mov    0x80106000,%edx
801005e1:	83 ea 80             	sub    $0xffffff80,%edx
801005e4:	39 d0                	cmp    %edx,%eax
801005e6:	75 7e                	jne    80100666 <consoleintr+0x168>
 		consputc(c);	   
801005e8:	83 ec 0c             	sub    $0xc,%esp
801005eb:	ff 75 f4             	pushl  -0xc(%ebp)
801005ee:	e8 02 fe ff ff       	call   801003f5 <consputc>
801005f3:	83 c4 10             	add    $0x10,%esp
		if(getcmd() == 1){
801005f6:	e8 74 fe ff ff       	call   8010046f <getcmd>
801005fb:	83 f8 01             	cmp    $0x1,%eax
801005fe:	75 17                	jne    80100617 <consoleintr+0x119>
		  cprintf("Building a process...\n");
80100600:	83 ec 0c             	sub    $0xc,%esp
80100603:	68 92 28 10 80       	push   $0x80102892
80100608:	e8 80 fb ff ff       	call   8010018d <cprintf>
8010060d:	83 c4 10             	add    $0x10,%esp
		  confirmalloc();
80100610:	e8 ef 11 00 00       	call   80101804 <confirmalloc>
80100615:	eb 43                	jmp    8010065a <consoleintr+0x15c>

		}else if(getcmd() == 2){
80100617:	e8 53 fe ff ff       	call   8010046f <getcmd>
8010061c:	83 f8 02             	cmp    $0x2,%eax
8010061f:	75 17                	jne    80100638 <consoleintr+0x13a>
		  cprintf("Showing the Process Table...\n");
80100621:	83 ec 0c             	sub    $0xc,%esp
80100624:	68 a9 28 10 80       	push   $0x801028a9
80100629:	e8 5f fb ff ff       	call   8010018d <cprintf>
8010062e:	83 c4 10             	add    $0x10,%esp
		  printproc();
80100631:	e8 f8 0f 00 00       	call   8010162e <printproc>
80100636:	eb 22                	jmp    8010065a <consoleintr+0x15c>
		}else if(getcmd() == 0){
80100638:	e8 32 fe ff ff       	call   8010046f <getcmd>
8010063d:	85 c0                	test   %eax,%eax
8010063f:	75 19                	jne    8010065a <consoleintr+0x15c>
		    if(input.e!=0)
80100641:	a1 08 60 10 80       	mov    0x80106008,%eax
80100646:	85 c0                	test   %eax,%eax
80100648:	74 10                	je     8010065a <consoleintr+0x15c>
		  	cprintf("Unknow command\n");
8010064a:	83 ec 0c             	sub    $0xc,%esp
8010064d:	68 c7 28 10 80       	push   $0x801028c7
80100652:	e8 36 fb ff ff       	call   8010018d <cprintf>
80100657:	83 c4 10             	add    $0x10,%esp
		}
		input.e = 0;
8010065a:	c7 05 08 60 10 80 00 	movl   $0x0,0x80106008
80100661:	00 00 00 
80100664:	eb 28                	jmp    8010068e <consoleintr+0x190>
	}
	else{	    
       	  input.buf[input.e++ % INPUT_BUF] = c;
80100666:	a1 08 60 10 80       	mov    0x80106008,%eax
8010066b:	8d 50 01             	lea    0x1(%eax),%edx
8010066e:	89 15 08 60 10 80    	mov    %edx,0x80106008
80100674:	83 e0 7f             	and    $0x7f,%eax
80100677:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010067a:	88 90 80 5f 10 80    	mov    %dl,-0x7fefa080(%eax)
          consputc(c);
80100680:	83 ec 0c             	sub    $0xc,%esp
80100683:	ff 75 f4             	pushl  -0xc(%ebp)
80100686:	e8 6a fd ff ff       	call   801003f5 <consputc>
8010068b:	83 c4 10             	add    $0x10,%esp
        }
      }
      break;
8010068e:	90                   	nop
void
consoleintr(int (*getc)(void))
{
  int c;

  while((c = getc()) >= 0){
8010068f:	8b 45 08             	mov    0x8(%ebp),%eax
80100692:	ff d0                	call   *%eax
80100694:	89 45 f4             	mov    %eax,-0xc(%ebp)
80100697:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
8010069b:	0f 89 68 fe ff ff    	jns    80100509 <consoleintr+0xb>
        }
      }
      break;
    }
  }
}
801006a1:	c9                   	leave  
801006a2:	c3                   	ret    

801006a3 <stosb>:
               "cc");
}

static inline void
stosb(void *addr, int data, int cnt)
{
801006a3:	55                   	push   %ebp
801006a4:	89 e5                	mov    %esp,%ebp
801006a6:	57                   	push   %edi
801006a7:	53                   	push   %ebx
  asm volatile("cld; rep stosb" :
801006a8:	8b 4d 08             	mov    0x8(%ebp),%ecx
801006ab:	8b 55 10             	mov    0x10(%ebp),%edx
801006ae:	8b 45 0c             	mov    0xc(%ebp),%eax
801006b1:	89 cb                	mov    %ecx,%ebx
801006b3:	89 df                	mov    %ebx,%edi
801006b5:	89 d1                	mov    %edx,%ecx
801006b7:	fc                   	cld    
801006b8:	f3 aa                	rep stos %al,%es:(%edi)
801006ba:	89 ca                	mov    %ecx,%edx
801006bc:	89 fb                	mov    %edi,%ebx
801006be:	89 5d 08             	mov    %ebx,0x8(%ebp)
801006c1:	89 55 10             	mov    %edx,0x10(%ebp)
               "=D" (addr), "=c" (cnt) :
               "0" (addr), "1" (cnt), "a" (data) :
               "memory", "cc");
}
801006c4:	5b                   	pop    %ebx
801006c5:	5f                   	pop    %edi
801006c6:	5d                   	pop    %ebp
801006c7:	c3                   	ret    

801006c8 <stosl>:

static inline void
stosl(void *addr, int data, int cnt)
{
801006c8:	55                   	push   %ebp
801006c9:	89 e5                	mov    %esp,%ebp
801006cb:	57                   	push   %edi
801006cc:	53                   	push   %ebx
  asm volatile("cld; rep stosl" :
801006cd:	8b 4d 08             	mov    0x8(%ebp),%ecx
801006d0:	8b 55 10             	mov    0x10(%ebp),%edx
801006d3:	8b 45 0c             	mov    0xc(%ebp),%eax
801006d6:	89 cb                	mov    %ecx,%ebx
801006d8:	89 df                	mov    %ebx,%edi
801006da:	89 d1                	mov    %edx,%ecx
801006dc:	fc                   	cld    
801006dd:	f3 ab                	rep stos %eax,%es:(%edi)
801006df:	89 ca                	mov    %ecx,%edx
801006e1:	89 fb                	mov    %edi,%ebx
801006e3:	89 5d 08             	mov    %ebx,0x8(%ebp)
801006e6:	89 55 10             	mov    %edx,0x10(%ebp)
               "=D" (addr), "=c" (cnt) :
               "0" (addr), "1" (cnt), "a" (data) :
               "memory", "cc");
}
801006e9:	5b                   	pop    %ebx
801006ea:	5f                   	pop    %edi
801006eb:	5d                   	pop    %ebp
801006ec:	c3                   	ret    

801006ed <memset>:
#include "types.h"
#include "x86.h"

void*
memset(void *dst, int c, uint n)
{
801006ed:	55                   	push   %ebp
801006ee:	89 e5                	mov    %esp,%ebp
  if ((int)dst%4 == 0 && n%4 == 0){
801006f0:	8b 45 08             	mov    0x8(%ebp),%eax
801006f3:	83 e0 03             	and    $0x3,%eax
801006f6:	85 c0                	test   %eax,%eax
801006f8:	75 43                	jne    8010073d <memset+0x50>
801006fa:	8b 45 10             	mov    0x10(%ebp),%eax
801006fd:	83 e0 03             	and    $0x3,%eax
80100700:	85 c0                	test   %eax,%eax
80100702:	75 39                	jne    8010073d <memset+0x50>
    c &= 0xFF;
80100704:	81 65 0c ff 00 00 00 	andl   $0xff,0xc(%ebp)
    stosl(dst, (c<<24)|(c<<16)|(c<<8)|c, n/4);
8010070b:	8b 45 10             	mov    0x10(%ebp),%eax
8010070e:	c1 e8 02             	shr    $0x2,%eax
80100711:	89 c1                	mov    %eax,%ecx
80100713:	8b 45 0c             	mov    0xc(%ebp),%eax
80100716:	c1 e0 18             	shl    $0x18,%eax
80100719:	89 c2                	mov    %eax,%edx
8010071b:	8b 45 0c             	mov    0xc(%ebp),%eax
8010071e:	c1 e0 10             	shl    $0x10,%eax
80100721:	09 c2                	or     %eax,%edx
80100723:	8b 45 0c             	mov    0xc(%ebp),%eax
80100726:	c1 e0 08             	shl    $0x8,%eax
80100729:	09 d0                	or     %edx,%eax
8010072b:	0b 45 0c             	or     0xc(%ebp),%eax
8010072e:	51                   	push   %ecx
8010072f:	50                   	push   %eax
80100730:	ff 75 08             	pushl  0x8(%ebp)
80100733:	e8 90 ff ff ff       	call   801006c8 <stosl>
80100738:	83 c4 0c             	add    $0xc,%esp
8010073b:	eb 12                	jmp    8010074f <memset+0x62>
  } else
    stosb(dst, c, n);
8010073d:	8b 45 10             	mov    0x10(%ebp),%eax
80100740:	50                   	push   %eax
80100741:	ff 75 0c             	pushl  0xc(%ebp)
80100744:	ff 75 08             	pushl  0x8(%ebp)
80100747:	e8 57 ff ff ff       	call   801006a3 <stosb>
8010074c:	83 c4 0c             	add    $0xc,%esp
  return dst;
8010074f:	8b 45 08             	mov    0x8(%ebp),%eax
}
80100752:	c9                   	leave  
80100753:	c3                   	ret    

80100754 <memmove>:


void*
memmove(void *dst, const void *src, uint n)
{
80100754:	55                   	push   %ebp
80100755:	89 e5                	mov    %esp,%ebp
80100757:	83 ec 10             	sub    $0x10,%esp
  const char *s;
  char *d;

  s = src;
8010075a:	8b 45 0c             	mov    0xc(%ebp),%eax
8010075d:	89 45 fc             	mov    %eax,-0x4(%ebp)
  d = dst;
80100760:	8b 45 08             	mov    0x8(%ebp),%eax
80100763:	89 45 f8             	mov    %eax,-0x8(%ebp)
  if(s < d && s + n > d){
80100766:	8b 45 fc             	mov    -0x4(%ebp),%eax
80100769:	3b 45 f8             	cmp    -0x8(%ebp),%eax
8010076c:	73 3d                	jae    801007ab <memmove+0x57>
8010076e:	8b 55 fc             	mov    -0x4(%ebp),%edx
80100771:	8b 45 10             	mov    0x10(%ebp),%eax
80100774:	01 d0                	add    %edx,%eax
80100776:	3b 45 f8             	cmp    -0x8(%ebp),%eax
80100779:	76 30                	jbe    801007ab <memmove+0x57>
    s += n;
8010077b:	8b 45 10             	mov    0x10(%ebp),%eax
8010077e:	01 45 fc             	add    %eax,-0x4(%ebp)
    d += n;
80100781:	8b 45 10             	mov    0x10(%ebp),%eax
80100784:	01 45 f8             	add    %eax,-0x8(%ebp)
    while(n-- > 0)
80100787:	eb 13                	jmp    8010079c <memmove+0x48>
      *--d = *--s;
80100789:	83 6d f8 01          	subl   $0x1,-0x8(%ebp)
8010078d:	83 6d fc 01          	subl   $0x1,-0x4(%ebp)
80100791:	8b 45 fc             	mov    -0x4(%ebp),%eax
80100794:	0f b6 10             	movzbl (%eax),%edx
80100797:	8b 45 f8             	mov    -0x8(%ebp),%eax
8010079a:	88 10                	mov    %dl,(%eax)
  s = src;
  d = dst;
  if(s < d && s + n > d){
    s += n;
    d += n;
    while(n-- > 0)
8010079c:	8b 45 10             	mov    0x10(%ebp),%eax
8010079f:	8d 50 ff             	lea    -0x1(%eax),%edx
801007a2:	89 55 10             	mov    %edx,0x10(%ebp)
801007a5:	85 c0                	test   %eax,%eax
801007a7:	75 e0                	jne    80100789 <memmove+0x35>
  const char *s;
  char *d;

  s = src;
  d = dst;
  if(s < d && s + n > d){
801007a9:	eb 26                	jmp    801007d1 <memmove+0x7d>
    s += n;
    d += n;
    while(n-- > 0)
      *--d = *--s;
  } else
    while(n-- > 0)
801007ab:	eb 17                	jmp    801007c4 <memmove+0x70>
      *d++ = *s++;
801007ad:	8b 45 f8             	mov    -0x8(%ebp),%eax
801007b0:	8d 50 01             	lea    0x1(%eax),%edx
801007b3:	89 55 f8             	mov    %edx,-0x8(%ebp)
801007b6:	8b 55 fc             	mov    -0x4(%ebp),%edx
801007b9:	8d 4a 01             	lea    0x1(%edx),%ecx
801007bc:	89 4d fc             	mov    %ecx,-0x4(%ebp)
801007bf:	0f b6 12             	movzbl (%edx),%edx
801007c2:	88 10                	mov    %dl,(%eax)
    s += n;
    d += n;
    while(n-- > 0)
      *--d = *--s;
  } else
    while(n-- > 0)
801007c4:	8b 45 10             	mov    0x10(%ebp),%eax
801007c7:	8d 50 ff             	lea    -0x1(%eax),%edx
801007ca:	89 55 10             	mov    %edx,0x10(%ebp)
801007cd:	85 c0                	test   %eax,%eax
801007cf:	75 dc                	jne    801007ad <memmove+0x59>
      *d++ = *s++;

  return dst;
801007d1:	8b 45 08             	mov    0x8(%ebp),%eax
}
801007d4:	c9                   	leave  
801007d5:	c3                   	ret    

801007d6 <kfree>:


extern char end[]; // first address after kernel loaded from ELF file

void kfree(char *v)
{
801007d6:	55                   	push   %ebp
801007d7:	89 e5                	mov    %esp,%ebp
801007d9:	83 ec 18             	sub    $0x18,%esp
  struct run *r;

  memset(v, 1, PGSIZE);
801007dc:	83 ec 04             	sub    $0x4,%esp
801007df:	68 00 10 00 00       	push   $0x1000
801007e4:	6a 01                	push   $0x1
801007e6:	ff 75 08             	pushl  0x8(%ebp)
801007e9:	e8 ff fe ff ff       	call   801006ed <memset>
801007ee:	83 c4 10             	add    $0x10,%esp

  r = (struct run*)v;
801007f1:	8b 45 08             	mov    0x8(%ebp),%eax
801007f4:	89 45 f4             	mov    %eax,-0xc(%ebp)
  r->next = kmem.freelist;
801007f7:	8b 15 84 61 10 80    	mov    0x80106184,%edx
801007fd:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100800:	89 10                	mov    %edx,(%eax)
  kmem.freelist = r;
80100802:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100805:	a3 84 61 10 80       	mov    %eax,0x80106184

}
8010080a:	c9                   	leave  
8010080b:	c3                   	ret    

8010080c <freerange>:

void freerange(void *vstart, void *vend)
{
8010080c:	55                   	push   %ebp
8010080d:	89 e5                	mov    %esp,%ebp
8010080f:	83 ec 18             	sub    $0x18,%esp
  char *p;
  p = (char*)PGROUNDUP((uint)vstart);
80100812:	8b 45 08             	mov    0x8(%ebp),%eax
80100815:	05 ff 0f 00 00       	add    $0xfff,%eax
8010081a:	25 00 f0 ff ff       	and    $0xfffff000,%eax
8010081f:	89 45 f4             	mov    %eax,-0xc(%ebp)
  for(; p + PGSIZE <= (char*)vend; p += PGSIZE)
80100822:	eb 15                	jmp    80100839 <freerange+0x2d>
    kfree(p);
80100824:	83 ec 0c             	sub    $0xc,%esp
80100827:	ff 75 f4             	pushl  -0xc(%ebp)
8010082a:	e8 a7 ff ff ff       	call   801007d6 <kfree>
8010082f:	83 c4 10             	add    $0x10,%esp

void freerange(void *vstart, void *vend)
{
  char *p;
  p = (char*)PGROUNDUP((uint)vstart);
  for(; p + PGSIZE <= (char*)vend; p += PGSIZE)
80100832:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
80100839:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010083c:	05 00 10 00 00       	add    $0x1000,%eax
80100841:	3b 45 0c             	cmp    0xc(%ebp),%eax
80100844:	76 de                	jbe    80100824 <freerange+0x18>
    kfree(p);
}
80100846:	c9                   	leave  
80100847:	c3                   	ret    

80100848 <kinit>:


void kinit(void *vstart, void *vend)
{
80100848:	55                   	push   %ebp
80100849:	89 e5                	mov    %esp,%ebp
8010084b:	83 ec 08             	sub    $0x8,%esp
  freerange(vstart, vend);
8010084e:	83 ec 08             	sub    $0x8,%esp
80100851:	ff 75 0c             	pushl  0xc(%ebp)
80100854:	ff 75 08             	pushl  0x8(%ebp)
80100857:	e8 b0 ff ff ff       	call   8010080c <freerange>
8010085c:	83 c4 10             	add    $0x10,%esp
}
8010085f:	c9                   	leave  
80100860:	c3                   	ret    

80100861 <kalloc>:

//分配一个4096字节的物理内存页，返回内核可以使用的指针。如果无法分配，则返回0
char* kalloc(void)
{
80100861:	55                   	push   %ebp
80100862:	89 e5                	mov    %esp,%ebp
80100864:	83 ec 10             	sub    $0x10,%esp
  struct run *r;
  r = kmem.freelist;
80100867:	a1 84 61 10 80       	mov    0x80106184,%eax
8010086c:	89 45 fc             	mov    %eax,-0x4(%ebp)
  if(r)
8010086f:	83 7d fc 00          	cmpl   $0x0,-0x4(%ebp)
80100873:	74 0a                	je     8010087f <kalloc+0x1e>
    kmem.freelist = r->next;
80100875:	8b 45 fc             	mov    -0x4(%ebp),%eax
80100878:	8b 00                	mov    (%eax),%eax
8010087a:	a3 84 61 10 80       	mov    %eax,0x80106184
  return (char*)r;
8010087f:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80100882:	c9                   	leave  
80100883:	c3                   	ret    

80100884 <inb>:
// Routines to let C code use special x86 instructions.

static inline uchar
inb(ushort port)
{
80100884:	55                   	push   %ebp
80100885:	89 e5                	mov    %esp,%ebp
80100887:	83 ec 14             	sub    $0x14,%esp
8010088a:	8b 45 08             	mov    0x8(%ebp),%eax
8010088d:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
  uchar data;

  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80100891:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
80100895:	89 c2                	mov    %eax,%edx
80100897:	ec                   	in     (%dx),%al
80100898:	88 45 ff             	mov    %al,-0x1(%ebp)
  return data;
8010089b:	0f b6 45 ff          	movzbl -0x1(%ebp),%eax
}
8010089f:	c9                   	leave  
801008a0:	c3                   	ret    

801008a1 <kbdgetc>:
#include "defs.h"
#include "kbd.h"

int
kbdgetc(void)
{
801008a1:	55                   	push   %ebp
801008a2:	89 e5                	mov    %esp,%ebp
801008a4:	83 ec 10             	sub    $0x10,%esp
  static uchar *charcode[4] = {
    normalmap, shiftmap, ctlmap, ctlmap
  };
  uint st, data, c;

  st = inb(KBSTATP);
801008a7:	6a 64                	push   $0x64
801008a9:	e8 d6 ff ff ff       	call   80100884 <inb>
801008ae:	83 c4 04             	add    $0x4,%esp
801008b1:	0f b6 c0             	movzbl %al,%eax
801008b4:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if((st & KBS_DIB) == 0)
801008b7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801008ba:	83 e0 01             	and    $0x1,%eax
801008bd:	85 c0                	test   %eax,%eax
801008bf:	75 0a                	jne    801008cb <kbdgetc+0x2a>
    return -1;
801008c1:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801008c6:	e9 23 01 00 00       	jmp    801009ee <kbdgetc+0x14d>
  data = inb(KBDATAP);
801008cb:	6a 60                	push   $0x60
801008cd:	e8 b2 ff ff ff       	call   80100884 <inb>
801008d2:	83 c4 04             	add    $0x4,%esp
801008d5:	0f b6 c0             	movzbl %al,%eax
801008d8:	89 45 fc             	mov    %eax,-0x4(%ebp)

  if(data == 0xE0){
801008db:	81 7d fc e0 00 00 00 	cmpl   $0xe0,-0x4(%ebp)
801008e2:	75 17                	jne    801008fb <kbdgetc+0x5a>
    shift |= E0ESC;
801008e4:	a1 40 4f 10 80       	mov    0x80104f40,%eax
801008e9:	83 c8 40             	or     $0x40,%eax
801008ec:	a3 40 4f 10 80       	mov    %eax,0x80104f40
    return 0;
801008f1:	b8 00 00 00 00       	mov    $0x0,%eax
801008f6:	e9 f3 00 00 00       	jmp    801009ee <kbdgetc+0x14d>
  } else if(data & 0x80){
801008fb:	8b 45 fc             	mov    -0x4(%ebp),%eax
801008fe:	25 80 00 00 00       	and    $0x80,%eax
80100903:	85 c0                	test   %eax,%eax
80100905:	74 45                	je     8010094c <kbdgetc+0xab>
    // Key released
    data = (shift & E0ESC ? data : data & 0x7F);
80100907:	a1 40 4f 10 80       	mov    0x80104f40,%eax
8010090c:	83 e0 40             	and    $0x40,%eax
8010090f:	85 c0                	test   %eax,%eax
80100911:	75 08                	jne    8010091b <kbdgetc+0x7a>
80100913:	8b 45 fc             	mov    -0x4(%ebp),%eax
80100916:	83 e0 7f             	and    $0x7f,%eax
80100919:	eb 03                	jmp    8010091e <kbdgetc+0x7d>
8010091b:	8b 45 fc             	mov    -0x4(%ebp),%eax
8010091e:	89 45 fc             	mov    %eax,-0x4(%ebp)
    shift &= ~(shiftcode[data] | E0ESC);
80100921:	8b 45 fc             	mov    -0x4(%ebp),%eax
80100924:	05 40 40 10 80       	add    $0x80104040,%eax
80100929:	0f b6 00             	movzbl (%eax),%eax
8010092c:	83 c8 40             	or     $0x40,%eax
8010092f:	0f b6 c0             	movzbl %al,%eax
80100932:	f7 d0                	not    %eax
80100934:	89 c2                	mov    %eax,%edx
80100936:	a1 40 4f 10 80       	mov    0x80104f40,%eax
8010093b:	21 d0                	and    %edx,%eax
8010093d:	a3 40 4f 10 80       	mov    %eax,0x80104f40
    return 0;
80100942:	b8 00 00 00 00       	mov    $0x0,%eax
80100947:	e9 a2 00 00 00       	jmp    801009ee <kbdgetc+0x14d>
  } else if(shift & E0ESC){
8010094c:	a1 40 4f 10 80       	mov    0x80104f40,%eax
80100951:	83 e0 40             	and    $0x40,%eax
80100954:	85 c0                	test   %eax,%eax
80100956:	74 14                	je     8010096c <kbdgetc+0xcb>
    // Last character was an E0 escape; or with 0x80
    data |= 0x80;
80100958:	81 4d fc 80 00 00 00 	orl    $0x80,-0x4(%ebp)
    shift &= ~E0ESC;
8010095f:	a1 40 4f 10 80       	mov    0x80104f40,%eax
80100964:	83 e0 bf             	and    $0xffffffbf,%eax
80100967:	a3 40 4f 10 80       	mov    %eax,0x80104f40
  }

  shift |= shiftcode[data];
8010096c:	8b 45 fc             	mov    -0x4(%ebp),%eax
8010096f:	05 40 40 10 80       	add    $0x80104040,%eax
80100974:	0f b6 00             	movzbl (%eax),%eax
80100977:	0f b6 d0             	movzbl %al,%edx
8010097a:	a1 40 4f 10 80       	mov    0x80104f40,%eax
8010097f:	09 d0                	or     %edx,%eax
80100981:	a3 40 4f 10 80       	mov    %eax,0x80104f40
  shift ^= togglecode[data];
80100986:	8b 45 fc             	mov    -0x4(%ebp),%eax
80100989:	05 40 41 10 80       	add    $0x80104140,%eax
8010098e:	0f b6 00             	movzbl (%eax),%eax
80100991:	0f b6 d0             	movzbl %al,%edx
80100994:	a1 40 4f 10 80       	mov    0x80104f40,%eax
80100999:	31 d0                	xor    %edx,%eax
8010099b:	a3 40 4f 10 80       	mov    %eax,0x80104f40
  c = charcode[shift & (CTL | SHIFT)][data];
801009a0:	a1 40 4f 10 80       	mov    0x80104f40,%eax
801009a5:	83 e0 03             	and    $0x3,%eax
801009a8:	8b 14 85 40 45 10 80 	mov    -0x7fefbac0(,%eax,4),%edx
801009af:	8b 45 fc             	mov    -0x4(%ebp),%eax
801009b2:	01 d0                	add    %edx,%eax
801009b4:	0f b6 00             	movzbl (%eax),%eax
801009b7:	0f b6 c0             	movzbl %al,%eax
801009ba:	89 45 f8             	mov    %eax,-0x8(%ebp)
  if(shift & CAPSLOCK){
801009bd:	a1 40 4f 10 80       	mov    0x80104f40,%eax
801009c2:	83 e0 08             	and    $0x8,%eax
801009c5:	85 c0                	test   %eax,%eax
801009c7:	74 22                	je     801009eb <kbdgetc+0x14a>
    if('a' <= c && c <= 'z')
801009c9:	83 7d f8 60          	cmpl   $0x60,-0x8(%ebp)
801009cd:	76 0c                	jbe    801009db <kbdgetc+0x13a>
801009cf:	83 7d f8 7a          	cmpl   $0x7a,-0x8(%ebp)
801009d3:	77 06                	ja     801009db <kbdgetc+0x13a>
      c += 'A' - 'a';
801009d5:	83 6d f8 20          	subl   $0x20,-0x8(%ebp)
801009d9:	eb 10                	jmp    801009eb <kbdgetc+0x14a>
    else if('A' <= c && c <= 'Z')
801009db:	83 7d f8 40          	cmpl   $0x40,-0x8(%ebp)
801009df:	76 0a                	jbe    801009eb <kbdgetc+0x14a>
801009e1:	83 7d f8 5a          	cmpl   $0x5a,-0x8(%ebp)
801009e5:	77 04                	ja     801009eb <kbdgetc+0x14a>
      c += 'a' - 'A';
801009e7:	83 45 f8 20          	addl   $0x20,-0x8(%ebp)
  }
  return c;
801009eb:	8b 45 f8             	mov    -0x8(%ebp),%eax
}
801009ee:	c9                   	leave  
801009ef:	c3                   	ret    

801009f0 <kbdintr>:

void
kbdintr(void)
{
801009f0:	55                   	push   %ebp
801009f1:	89 e5                	mov    %esp,%ebp
801009f3:	83 ec 08             	sub    $0x8,%esp
  consoleintr(kbdgetc);
801009f6:	83 ec 0c             	sub    $0xc,%esp
801009f9:	68 a1 08 10 80       	push   $0x801008a1
801009fe:	e8 fb fa ff ff       	call   801004fe <consoleintr>
80100a03:	83 c4 10             	add    $0x10,%esp
}
80100a06:	c9                   	leave  
80100a07:	c3                   	ret    

80100a08 <lgdt>:

struct segdesc;

static inline void
lgdt(struct segdesc *p, int size)
{
80100a08:	55                   	push   %ebp
80100a09:	89 e5                	mov    %esp,%ebp
80100a0b:	83 ec 10             	sub    $0x10,%esp
  volatile ushort pd[3];

  pd[0] = size-1;
80100a0e:	8b 45 0c             	mov    0xc(%ebp),%eax
80100a11:	83 e8 01             	sub    $0x1,%eax
80100a14:	66 89 45 fa          	mov    %ax,-0x6(%ebp)
  pd[1] = (uint)p;
80100a18:	8b 45 08             	mov    0x8(%ebp),%eax
80100a1b:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  pd[2] = (uint)p >> 16;
80100a1f:	8b 45 08             	mov    0x8(%ebp),%eax
80100a22:	c1 e8 10             	shr    $0x10,%eax
80100a25:	66 89 45 fe          	mov    %ax,-0x2(%ebp)

  asm volatile("lgdt (%0)" : : "r" (pd));
80100a29:	8d 45 fa             	lea    -0x6(%ebp),%eax
80100a2c:	0f 01 10             	lgdtl  (%eax)
}
80100a2f:	c9                   	leave  
80100a30:	c3                   	ret    

80100a31 <ltr>:
  asm volatile("lidt (%0)" : : "r" (pd));
}

static inline void
ltr(ushort sel)
{
80100a31:	55                   	push   %ebp
80100a32:	89 e5                	mov    %esp,%ebp
80100a34:	83 ec 04             	sub    $0x4,%esp
80100a37:	8b 45 08             	mov    0x8(%ebp),%eax
80100a3a:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  asm volatile("ltr %0" : : "r" (sel));
80100a3e:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
80100a42:	0f 00 d8             	ltr    %ax
}
80100a45:	c9                   	leave  
80100a46:	c3                   	ret    

80100a47 <loadgs>:
  return eflags;
}

static inline void
loadgs(ushort v)
{
80100a47:	55                   	push   %ebp
80100a48:	89 e5                	mov    %esp,%ebp
80100a4a:	83 ec 04             	sub    $0x4,%esp
80100a4d:	8b 45 08             	mov    0x8(%ebp),%eax
80100a50:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  asm volatile("movw %0, %%gs" : : "r" (v));
80100a54:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
80100a58:	8e e8                	mov    %eax,%gs
}
80100a5a:	c9                   	leave  
80100a5b:	c3                   	ret    

80100a5c <lcr3>:
  return val;
}

static inline void
lcr3(uint val) 
{
80100a5c:	55                   	push   %ebp
80100a5d:	89 e5                	mov    %esp,%ebp
  asm volatile("movl %0,%%cr3" : : "r" (val));
80100a5f:	8b 45 08             	mov    0x8(%ebp),%eax
80100a62:	0f 22 d8             	mov    %eax,%cr3
}
80100a65:	5d                   	pop    %ebp
80100a66:	c3                   	ret    

80100a67 <v2p>:
#define KERNBASE 0x80000000         // 第一个内核虚拟内存
#define KERNLINK (KERNBASE+EXTMEM)  // 内核被链接的地址

#ifndef __ASSEMBLER__

static inline uint v2p(void *a) { return ((uint) (a))  - KERNBASE; }
80100a67:	55                   	push   %ebp
80100a68:	89 e5                	mov    %esp,%ebp
80100a6a:	8b 45 08             	mov    0x8(%ebp),%eax
80100a6d:	05 00 00 00 80       	add    $0x80000000,%eax
80100a72:	5d                   	pop    %ebp
80100a73:	c3                   	ret    

80100a74 <p2v>:
static inline void *p2v(uint a) { return (void *) ((a) + KERNBASE); }
80100a74:	55                   	push   %ebp
80100a75:	89 e5                	mov    %esp,%ebp
80100a77:	8b 45 08             	mov    0x8(%ebp),%eax
80100a7a:	05 00 00 00 80       	add    $0x80000000,%eax
80100a7f:	5d                   	pop    %ebp
80100a80:	c3                   	ret    

80100a81 <seginit>:
struct cpu cpus[1];
extern char data[];  // 由kernel.ld来定义
pde_t *kpgdir;  // 被进程调度所使用(以后)

void seginit(void)
{
80100a81:	55                   	push   %ebp
80100a82:	89 e5                	mov    %esp,%ebp
80100a84:	53                   	push   %ebx
80100a85:	83 ec 10             	sub    $0x10,%esp
  struct cpu *c;
  c = &cpus[0]; 
80100a88:	c7 45 f8 00 62 10 80 	movl   $0x80106200,-0x8(%ebp)
  c->gdt[SEG_KCODE] = SEG(STA_X|STA_R, 0, 0xffffffff, 0);        
80100a8f:	8b 45 f8             	mov    -0x8(%ebp),%eax
80100a92:	66 c7 40 78 ff ff    	movw   $0xffff,0x78(%eax)
80100a98:	8b 45 f8             	mov    -0x8(%ebp),%eax
80100a9b:	66 c7 40 7a 00 00    	movw   $0x0,0x7a(%eax)
80100aa1:	8b 45 f8             	mov    -0x8(%ebp),%eax
80100aa4:	c6 40 7c 00          	movb   $0x0,0x7c(%eax)
80100aa8:	8b 45 f8             	mov    -0x8(%ebp),%eax
80100aab:	0f b6 50 7d          	movzbl 0x7d(%eax),%edx
80100aaf:	83 e2 f0             	and    $0xfffffff0,%edx
80100ab2:	83 ca 0a             	or     $0xa,%edx
80100ab5:	88 50 7d             	mov    %dl,0x7d(%eax)
80100ab8:	8b 45 f8             	mov    -0x8(%ebp),%eax
80100abb:	0f b6 50 7d          	movzbl 0x7d(%eax),%edx
80100abf:	83 ca 10             	or     $0x10,%edx
80100ac2:	88 50 7d             	mov    %dl,0x7d(%eax)
80100ac5:	8b 45 f8             	mov    -0x8(%ebp),%eax
80100ac8:	0f b6 50 7d          	movzbl 0x7d(%eax),%edx
80100acc:	83 e2 9f             	and    $0xffffff9f,%edx
80100acf:	88 50 7d             	mov    %dl,0x7d(%eax)
80100ad2:	8b 45 f8             	mov    -0x8(%ebp),%eax
80100ad5:	0f b6 50 7d          	movzbl 0x7d(%eax),%edx
80100ad9:	83 ca 80             	or     $0xffffff80,%edx
80100adc:	88 50 7d             	mov    %dl,0x7d(%eax)
80100adf:	8b 45 f8             	mov    -0x8(%ebp),%eax
80100ae2:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
80100ae6:	83 ca 0f             	or     $0xf,%edx
80100ae9:	88 50 7e             	mov    %dl,0x7e(%eax)
80100aec:	8b 45 f8             	mov    -0x8(%ebp),%eax
80100aef:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
80100af3:	83 e2 ef             	and    $0xffffffef,%edx
80100af6:	88 50 7e             	mov    %dl,0x7e(%eax)
80100af9:	8b 45 f8             	mov    -0x8(%ebp),%eax
80100afc:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
80100b00:	83 e2 df             	and    $0xffffffdf,%edx
80100b03:	88 50 7e             	mov    %dl,0x7e(%eax)
80100b06:	8b 45 f8             	mov    -0x8(%ebp),%eax
80100b09:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
80100b0d:	83 ca 40             	or     $0x40,%edx
80100b10:	88 50 7e             	mov    %dl,0x7e(%eax)
80100b13:	8b 45 f8             	mov    -0x8(%ebp),%eax
80100b16:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
80100b1a:	83 ca 80             	or     $0xffffff80,%edx
80100b1d:	88 50 7e             	mov    %dl,0x7e(%eax)
80100b20:	8b 45 f8             	mov    -0x8(%ebp),%eax
80100b23:	c6 40 7f 00          	movb   $0x0,0x7f(%eax)
  c->gdt[SEG_KDATA] = SEG(STA_W, 0, 0xffffffff, 0);
80100b27:	8b 45 f8             	mov    -0x8(%ebp),%eax
80100b2a:	66 c7 80 80 00 00 00 	movw   $0xffff,0x80(%eax)
80100b31:	ff ff 
80100b33:	8b 45 f8             	mov    -0x8(%ebp),%eax
80100b36:	66 c7 80 82 00 00 00 	movw   $0x0,0x82(%eax)
80100b3d:	00 00 
80100b3f:	8b 45 f8             	mov    -0x8(%ebp),%eax
80100b42:	c6 80 84 00 00 00 00 	movb   $0x0,0x84(%eax)
80100b49:	8b 45 f8             	mov    -0x8(%ebp),%eax
80100b4c:	0f b6 90 85 00 00 00 	movzbl 0x85(%eax),%edx
80100b53:	83 e2 f0             	and    $0xfffffff0,%edx
80100b56:	83 ca 02             	or     $0x2,%edx
80100b59:	88 90 85 00 00 00    	mov    %dl,0x85(%eax)
80100b5f:	8b 45 f8             	mov    -0x8(%ebp),%eax
80100b62:	0f b6 90 85 00 00 00 	movzbl 0x85(%eax),%edx
80100b69:	83 ca 10             	or     $0x10,%edx
80100b6c:	88 90 85 00 00 00    	mov    %dl,0x85(%eax)
80100b72:	8b 45 f8             	mov    -0x8(%ebp),%eax
80100b75:	0f b6 90 85 00 00 00 	movzbl 0x85(%eax),%edx
80100b7c:	83 e2 9f             	and    $0xffffff9f,%edx
80100b7f:	88 90 85 00 00 00    	mov    %dl,0x85(%eax)
80100b85:	8b 45 f8             	mov    -0x8(%ebp),%eax
80100b88:	0f b6 90 85 00 00 00 	movzbl 0x85(%eax),%edx
80100b8f:	83 ca 80             	or     $0xffffff80,%edx
80100b92:	88 90 85 00 00 00    	mov    %dl,0x85(%eax)
80100b98:	8b 45 f8             	mov    -0x8(%ebp),%eax
80100b9b:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
80100ba2:	83 ca 0f             	or     $0xf,%edx
80100ba5:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
80100bab:	8b 45 f8             	mov    -0x8(%ebp),%eax
80100bae:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
80100bb5:	83 e2 ef             	and    $0xffffffef,%edx
80100bb8:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
80100bbe:	8b 45 f8             	mov    -0x8(%ebp),%eax
80100bc1:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
80100bc8:	83 e2 df             	and    $0xffffffdf,%edx
80100bcb:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
80100bd1:	8b 45 f8             	mov    -0x8(%ebp),%eax
80100bd4:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
80100bdb:	83 ca 40             	or     $0x40,%edx
80100bde:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
80100be4:	8b 45 f8             	mov    -0x8(%ebp),%eax
80100be7:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
80100bee:	83 ca 80             	or     $0xffffff80,%edx
80100bf1:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
80100bf7:	8b 45 f8             	mov    -0x8(%ebp),%eax
80100bfa:	c6 80 87 00 00 00 00 	movb   $0x0,0x87(%eax)
  c->gdt[SEG_UCODE] = SEG(STA_X|STA_R, 0, 0xffffffff, DPL_USER);
80100c01:	8b 45 f8             	mov    -0x8(%ebp),%eax
80100c04:	66 c7 80 90 00 00 00 	movw   $0xffff,0x90(%eax)
80100c0b:	ff ff 
80100c0d:	8b 45 f8             	mov    -0x8(%ebp),%eax
80100c10:	66 c7 80 92 00 00 00 	movw   $0x0,0x92(%eax)
80100c17:	00 00 
80100c19:	8b 45 f8             	mov    -0x8(%ebp),%eax
80100c1c:	c6 80 94 00 00 00 00 	movb   $0x0,0x94(%eax)
80100c23:	8b 45 f8             	mov    -0x8(%ebp),%eax
80100c26:	0f b6 90 95 00 00 00 	movzbl 0x95(%eax),%edx
80100c2d:	83 e2 f0             	and    $0xfffffff0,%edx
80100c30:	83 ca 0a             	or     $0xa,%edx
80100c33:	88 90 95 00 00 00    	mov    %dl,0x95(%eax)
80100c39:	8b 45 f8             	mov    -0x8(%ebp),%eax
80100c3c:	0f b6 90 95 00 00 00 	movzbl 0x95(%eax),%edx
80100c43:	83 ca 10             	or     $0x10,%edx
80100c46:	88 90 95 00 00 00    	mov    %dl,0x95(%eax)
80100c4c:	8b 45 f8             	mov    -0x8(%ebp),%eax
80100c4f:	0f b6 90 95 00 00 00 	movzbl 0x95(%eax),%edx
80100c56:	83 ca 60             	or     $0x60,%edx
80100c59:	88 90 95 00 00 00    	mov    %dl,0x95(%eax)
80100c5f:	8b 45 f8             	mov    -0x8(%ebp),%eax
80100c62:	0f b6 90 95 00 00 00 	movzbl 0x95(%eax),%edx
80100c69:	83 ca 80             	or     $0xffffff80,%edx
80100c6c:	88 90 95 00 00 00    	mov    %dl,0x95(%eax)
80100c72:	8b 45 f8             	mov    -0x8(%ebp),%eax
80100c75:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
80100c7c:	83 ca 0f             	or     $0xf,%edx
80100c7f:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
80100c85:	8b 45 f8             	mov    -0x8(%ebp),%eax
80100c88:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
80100c8f:	83 e2 ef             	and    $0xffffffef,%edx
80100c92:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
80100c98:	8b 45 f8             	mov    -0x8(%ebp),%eax
80100c9b:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
80100ca2:	83 e2 df             	and    $0xffffffdf,%edx
80100ca5:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
80100cab:	8b 45 f8             	mov    -0x8(%ebp),%eax
80100cae:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
80100cb5:	83 ca 40             	or     $0x40,%edx
80100cb8:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
80100cbe:	8b 45 f8             	mov    -0x8(%ebp),%eax
80100cc1:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
80100cc8:	83 ca 80             	or     $0xffffff80,%edx
80100ccb:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
80100cd1:	8b 45 f8             	mov    -0x8(%ebp),%eax
80100cd4:	c6 80 97 00 00 00 00 	movb   $0x0,0x97(%eax)
  c->gdt[SEG_UDATA] = SEG(STA_W, 0, 0xffffffff, DPL_USER);
80100cdb:	8b 45 f8             	mov    -0x8(%ebp),%eax
80100cde:	66 c7 80 98 00 00 00 	movw   $0xffff,0x98(%eax)
80100ce5:	ff ff 
80100ce7:	8b 45 f8             	mov    -0x8(%ebp),%eax
80100cea:	66 c7 80 9a 00 00 00 	movw   $0x0,0x9a(%eax)
80100cf1:	00 00 
80100cf3:	8b 45 f8             	mov    -0x8(%ebp),%eax
80100cf6:	c6 80 9c 00 00 00 00 	movb   $0x0,0x9c(%eax)
80100cfd:	8b 45 f8             	mov    -0x8(%ebp),%eax
80100d00:	0f b6 90 9d 00 00 00 	movzbl 0x9d(%eax),%edx
80100d07:	83 e2 f0             	and    $0xfffffff0,%edx
80100d0a:	83 ca 02             	or     $0x2,%edx
80100d0d:	88 90 9d 00 00 00    	mov    %dl,0x9d(%eax)
80100d13:	8b 45 f8             	mov    -0x8(%ebp),%eax
80100d16:	0f b6 90 9d 00 00 00 	movzbl 0x9d(%eax),%edx
80100d1d:	83 ca 10             	or     $0x10,%edx
80100d20:	88 90 9d 00 00 00    	mov    %dl,0x9d(%eax)
80100d26:	8b 45 f8             	mov    -0x8(%ebp),%eax
80100d29:	0f b6 90 9d 00 00 00 	movzbl 0x9d(%eax),%edx
80100d30:	83 ca 60             	or     $0x60,%edx
80100d33:	88 90 9d 00 00 00    	mov    %dl,0x9d(%eax)
80100d39:	8b 45 f8             	mov    -0x8(%ebp),%eax
80100d3c:	0f b6 90 9d 00 00 00 	movzbl 0x9d(%eax),%edx
80100d43:	83 ca 80             	or     $0xffffff80,%edx
80100d46:	88 90 9d 00 00 00    	mov    %dl,0x9d(%eax)
80100d4c:	8b 45 f8             	mov    -0x8(%ebp),%eax
80100d4f:	0f b6 90 9e 00 00 00 	movzbl 0x9e(%eax),%edx
80100d56:	83 ca 0f             	or     $0xf,%edx
80100d59:	88 90 9e 00 00 00    	mov    %dl,0x9e(%eax)
80100d5f:	8b 45 f8             	mov    -0x8(%ebp),%eax
80100d62:	0f b6 90 9e 00 00 00 	movzbl 0x9e(%eax),%edx
80100d69:	83 e2 ef             	and    $0xffffffef,%edx
80100d6c:	88 90 9e 00 00 00    	mov    %dl,0x9e(%eax)
80100d72:	8b 45 f8             	mov    -0x8(%ebp),%eax
80100d75:	0f b6 90 9e 00 00 00 	movzbl 0x9e(%eax),%edx
80100d7c:	83 e2 df             	and    $0xffffffdf,%edx
80100d7f:	88 90 9e 00 00 00    	mov    %dl,0x9e(%eax)
80100d85:	8b 45 f8             	mov    -0x8(%ebp),%eax
80100d88:	0f b6 90 9e 00 00 00 	movzbl 0x9e(%eax),%edx
80100d8f:	83 ca 40             	or     $0x40,%edx
80100d92:	88 90 9e 00 00 00    	mov    %dl,0x9e(%eax)
80100d98:	8b 45 f8             	mov    -0x8(%ebp),%eax
80100d9b:	0f b6 90 9e 00 00 00 	movzbl 0x9e(%eax),%edx
80100da2:	83 ca 80             	or     $0xffffff80,%edx
80100da5:	88 90 9e 00 00 00    	mov    %dl,0x9e(%eax)
80100dab:	8b 45 f8             	mov    -0x8(%ebp),%eax
80100dae:	c6 80 9f 00 00 00 00 	movb   $0x0,0x9f(%eax)
  
  c->gdt[SEG_KCPU] = SEG(STA_W, &c->cpu, 8, 0);
80100db5:	8b 45 f8             	mov    -0x8(%ebp),%eax
80100db8:	05 b4 00 00 00       	add    $0xb4,%eax
80100dbd:	89 c3                	mov    %eax,%ebx
80100dbf:	8b 45 f8             	mov    -0x8(%ebp),%eax
80100dc2:	05 b4 00 00 00       	add    $0xb4,%eax
80100dc7:	c1 e8 10             	shr    $0x10,%eax
80100dca:	89 c2                	mov    %eax,%edx
80100dcc:	8b 45 f8             	mov    -0x8(%ebp),%eax
80100dcf:	05 b4 00 00 00       	add    $0xb4,%eax
80100dd4:	c1 e8 18             	shr    $0x18,%eax
80100dd7:	89 c1                	mov    %eax,%ecx
80100dd9:	8b 45 f8             	mov    -0x8(%ebp),%eax
80100ddc:	66 c7 80 88 00 00 00 	movw   $0x0,0x88(%eax)
80100de3:	00 00 
80100de5:	8b 45 f8             	mov    -0x8(%ebp),%eax
80100de8:	66 89 98 8a 00 00 00 	mov    %bx,0x8a(%eax)
80100def:	8b 45 f8             	mov    -0x8(%ebp),%eax
80100df2:	88 90 8c 00 00 00    	mov    %dl,0x8c(%eax)
80100df8:	8b 45 f8             	mov    -0x8(%ebp),%eax
80100dfb:	0f b6 90 8d 00 00 00 	movzbl 0x8d(%eax),%edx
80100e02:	83 e2 f0             	and    $0xfffffff0,%edx
80100e05:	83 ca 02             	or     $0x2,%edx
80100e08:	88 90 8d 00 00 00    	mov    %dl,0x8d(%eax)
80100e0e:	8b 45 f8             	mov    -0x8(%ebp),%eax
80100e11:	0f b6 90 8d 00 00 00 	movzbl 0x8d(%eax),%edx
80100e18:	83 ca 10             	or     $0x10,%edx
80100e1b:	88 90 8d 00 00 00    	mov    %dl,0x8d(%eax)
80100e21:	8b 45 f8             	mov    -0x8(%ebp),%eax
80100e24:	0f b6 90 8d 00 00 00 	movzbl 0x8d(%eax),%edx
80100e2b:	83 e2 9f             	and    $0xffffff9f,%edx
80100e2e:	88 90 8d 00 00 00    	mov    %dl,0x8d(%eax)
80100e34:	8b 45 f8             	mov    -0x8(%ebp),%eax
80100e37:	0f b6 90 8d 00 00 00 	movzbl 0x8d(%eax),%edx
80100e3e:	83 ca 80             	or     $0xffffff80,%edx
80100e41:	88 90 8d 00 00 00    	mov    %dl,0x8d(%eax)
80100e47:	8b 45 f8             	mov    -0x8(%ebp),%eax
80100e4a:	0f b6 90 8e 00 00 00 	movzbl 0x8e(%eax),%edx
80100e51:	83 e2 f0             	and    $0xfffffff0,%edx
80100e54:	88 90 8e 00 00 00    	mov    %dl,0x8e(%eax)
80100e5a:	8b 45 f8             	mov    -0x8(%ebp),%eax
80100e5d:	0f b6 90 8e 00 00 00 	movzbl 0x8e(%eax),%edx
80100e64:	83 e2 ef             	and    $0xffffffef,%edx
80100e67:	88 90 8e 00 00 00    	mov    %dl,0x8e(%eax)
80100e6d:	8b 45 f8             	mov    -0x8(%ebp),%eax
80100e70:	0f b6 90 8e 00 00 00 	movzbl 0x8e(%eax),%edx
80100e77:	83 e2 df             	and    $0xffffffdf,%edx
80100e7a:	88 90 8e 00 00 00    	mov    %dl,0x8e(%eax)
80100e80:	8b 45 f8             	mov    -0x8(%ebp),%eax
80100e83:	0f b6 90 8e 00 00 00 	movzbl 0x8e(%eax),%edx
80100e8a:	83 ca 40             	or     $0x40,%edx
80100e8d:	88 90 8e 00 00 00    	mov    %dl,0x8e(%eax)
80100e93:	8b 45 f8             	mov    -0x8(%ebp),%eax
80100e96:	0f b6 90 8e 00 00 00 	movzbl 0x8e(%eax),%edx
80100e9d:	83 ca 80             	or     $0xffffff80,%edx
80100ea0:	88 90 8e 00 00 00    	mov    %dl,0x8e(%eax)
80100ea6:	8b 45 f8             	mov    -0x8(%ebp),%eax
80100ea9:	88 88 8f 00 00 00    	mov    %cl,0x8f(%eax)
  
  lgdt(c->gdt, sizeof(c->gdt));
80100eaf:	8b 45 f8             	mov    -0x8(%ebp),%eax
80100eb2:	83 c0 70             	add    $0x70,%eax
80100eb5:	6a 38                	push   $0x38
80100eb7:	50                   	push   %eax
80100eb8:	e8 4b fb ff ff       	call   80100a08 <lgdt>
80100ebd:	83 c4 08             	add    $0x8,%esp
  loadgs(SEG_KCPU << 3);
80100ec0:	6a 18                	push   $0x18
80100ec2:	e8 80 fb ff ff       	call   80100a47 <loadgs>
80100ec7:	83 c4 04             	add    $0x4,%esp
  
  cpu = c;
80100eca:	8b 45 f8             	mov    -0x8(%ebp),%eax
80100ecd:	65 a3 00 00 00 00    	mov    %eax,%gs:0x0
}
80100ed3:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80100ed6:	c9                   	leave  
80100ed7:	c3                   	ret    

80100ed8 <segshow>:


void segshow(){
80100ed8:	55                   	push   %ebp
80100ed9:	89 e5                	mov    %esp,%ebp
80100edb:	83 ec 08             	sub    $0x8,%esp

  cprintf("Kernel code segment's address bit 31~24 : %d\n",cpu->gdt[SEG_KCODE].base_31_24);
80100ede:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80100ee4:	0f b6 40 7f          	movzbl 0x7f(%eax),%eax
80100ee8:	0f b6 c0             	movzbl %al,%eax
80100eeb:	83 ec 08             	sub    $0x8,%esp
80100eee:	50                   	push   %eax
80100eef:	68 d8 28 10 80       	push   $0x801028d8
80100ef4:	e8 94 f2 ff ff       	call   8010018d <cprintf>
80100ef9:	83 c4 10             	add    $0x10,%esp
  cprintf("Kernel code segment's address bit 23~16 : %d\n",cpu->gdt[SEG_KCODE].base_23_16);
80100efc:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80100f02:	0f b6 40 7c          	movzbl 0x7c(%eax),%eax
80100f06:	0f b6 c0             	movzbl %al,%eax
80100f09:	83 ec 08             	sub    $0x8,%esp
80100f0c:	50                   	push   %eax
80100f0d:	68 08 29 10 80       	push   $0x80102908
80100f12:	e8 76 f2 ff ff       	call   8010018d <cprintf>
80100f17:	83 c4 10             	add    $0x10,%esp
  cprintf("Kernel code segment's address bit 15~0 : %d\n",cpu->gdt[SEG_KCODE].base_15_0);
80100f1a:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80100f20:	0f b7 40 7a          	movzwl 0x7a(%eax),%eax
80100f24:	0f b7 c0             	movzwl %ax,%eax
80100f27:	83 ec 08             	sub    $0x8,%esp
80100f2a:	50                   	push   %eax
80100f2b:	68 38 29 10 80       	push   $0x80102938
80100f30:	e8 58 f2 ff ff       	call   8010018d <cprintf>
80100f35:	83 c4 10             	add    $0x10,%esp
                                                                                          
  cprintf("Kernel data segment's address bit 31~24 : %d\n",cpu->gdt[SEG_KDATA].base_31_24);
80100f38:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80100f3e:	0f b6 80 87 00 00 00 	movzbl 0x87(%eax),%eax
80100f45:	0f b6 c0             	movzbl %al,%eax
80100f48:	83 ec 08             	sub    $0x8,%esp
80100f4b:	50                   	push   %eax
80100f4c:	68 68 29 10 80       	push   $0x80102968
80100f51:	e8 37 f2 ff ff       	call   8010018d <cprintf>
80100f56:	83 c4 10             	add    $0x10,%esp
  cprintf("Kernel data segment's address bit 23~16 : %d\n",cpu->gdt[SEG_KDATA].base_23_16);
80100f59:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80100f5f:	0f b6 80 84 00 00 00 	movzbl 0x84(%eax),%eax
80100f66:	0f b6 c0             	movzbl %al,%eax
80100f69:	83 ec 08             	sub    $0x8,%esp
80100f6c:	50                   	push   %eax
80100f6d:	68 98 29 10 80       	push   $0x80102998
80100f72:	e8 16 f2 ff ff       	call   8010018d <cprintf>
80100f77:	83 c4 10             	add    $0x10,%esp
  cprintf("Kernel data segment's address bit 15~0 : %d\n",cpu->gdt[SEG_KDATA].base_15_0);
80100f7a:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80100f80:	0f b7 80 82 00 00 00 	movzwl 0x82(%eax),%eax
80100f87:	0f b7 c0             	movzwl %ax,%eax
80100f8a:	83 ec 08             	sub    $0x8,%esp
80100f8d:	50                   	push   %eax
80100f8e:	68 c8 29 10 80       	push   $0x801029c8
80100f93:	e8 f5 f1 ff ff       	call   8010018d <cprintf>
80100f98:	83 c4 10             	add    $0x10,%esp

  cprintf("User code segment's address bit 31~24 : %d\n",cpu->gdt[SEG_UCODE].base_31_24);
80100f9b:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80100fa1:	0f b6 80 97 00 00 00 	movzbl 0x97(%eax),%eax
80100fa8:	0f b6 c0             	movzbl %al,%eax
80100fab:	83 ec 08             	sub    $0x8,%esp
80100fae:	50                   	push   %eax
80100faf:	68 f8 29 10 80       	push   $0x801029f8
80100fb4:	e8 d4 f1 ff ff       	call   8010018d <cprintf>
80100fb9:	83 c4 10             	add    $0x10,%esp
  cprintf("User code segment's address bit 23~16 : %d\n",cpu->gdt[SEG_UCODE].base_15_0);
80100fbc:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80100fc2:	0f b7 80 92 00 00 00 	movzwl 0x92(%eax),%eax
80100fc9:	0f b7 c0             	movzwl %ax,%eax
80100fcc:	83 ec 08             	sub    $0x8,%esp
80100fcf:	50                   	push   %eax
80100fd0:	68 24 2a 10 80       	push   $0x80102a24
80100fd5:	e8 b3 f1 ff ff       	call   8010018d <cprintf>
80100fda:	83 c4 10             	add    $0x10,%esp
  cprintf("User code segment's address bit 15~0 : %d\n",cpu->gdt[SEG_UCODE].base_15_0);
80100fdd:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80100fe3:	0f b7 80 92 00 00 00 	movzwl 0x92(%eax),%eax
80100fea:	0f b7 c0             	movzwl %ax,%eax
80100fed:	83 ec 08             	sub    $0x8,%esp
80100ff0:	50                   	push   %eax
80100ff1:	68 50 2a 10 80       	push   $0x80102a50
80100ff6:	e8 92 f1 ff ff       	call   8010018d <cprintf>
80100ffb:	83 c4 10             	add    $0x10,%esp
  
  cprintf("User code segment's address bit 31~24 : %d\n",cpu->gdt[SEG_UDATA].base_31_24);
80100ffe:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80101004:	0f b6 80 9f 00 00 00 	movzbl 0x9f(%eax),%eax
8010100b:	0f b6 c0             	movzbl %al,%eax
8010100e:	83 ec 08             	sub    $0x8,%esp
80101011:	50                   	push   %eax
80101012:	68 f8 29 10 80       	push   $0x801029f8
80101017:	e8 71 f1 ff ff       	call   8010018d <cprintf>
8010101c:	83 c4 10             	add    $0x10,%esp
  cprintf("User code segment's address bit 23~16 : %d\n",cpu->gdt[SEG_UDATA].base_23_16);
8010101f:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80101025:	0f b6 80 9c 00 00 00 	movzbl 0x9c(%eax),%eax
8010102c:	0f b6 c0             	movzbl %al,%eax
8010102f:	83 ec 08             	sub    $0x8,%esp
80101032:	50                   	push   %eax
80101033:	68 24 2a 10 80       	push   $0x80102a24
80101038:	e8 50 f1 ff ff       	call   8010018d <cprintf>
8010103d:	83 c4 10             	add    $0x10,%esp
  cprintf("User code segment's address bit 15~0 : %d\n",cpu->gdt[SEG_UDATA].base_15_0);
80101040:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80101046:	0f b7 80 9a 00 00 00 	movzwl 0x9a(%eax),%eax
8010104d:	0f b7 c0             	movzwl %ax,%eax
80101050:	83 ec 08             	sub    $0x8,%esp
80101053:	50                   	push   %eax
80101054:	68 50 2a 10 80       	push   $0x80102a50
80101059:	e8 2f f1 ff ff       	call   8010018d <cprintf>
8010105e:	83 c4 10             	add    $0x10,%esp

}
80101061:	c9                   	leave  
80101062:	c3                   	ret    

80101063 <walkpgdir>:

//返回页表pgdir中对应线性地址va的PTE(页项)的地址，如果creat!=0,那么创建请求的页项
//
static pte_t * 
walkpgdir(pde_t *pgdir, const void *va, int alloc)
{
80101063:	55                   	push   %ebp
80101064:	89 e5                	mov    %esp,%ebp
80101066:	83 ec 18             	sub    $0x18,%esp
  pde_t *pde;   //页目录入口地址
  pte_t *pgtab;  //页表项入口地址

  pde = &pgdir[PDX(va)];    //根据线性地址查找其对应的页目录
80101069:	8b 45 0c             	mov    0xc(%ebp),%eax
8010106c:	c1 e8 16             	shr    $0x16,%eax
8010106f:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80101076:	8b 45 08             	mov    0x8(%ebp),%eax
80101079:	01 d0                	add    %edx,%eax
8010107b:	89 45 f0             	mov    %eax,-0x10(%ebp)
 
  if(*pde & PTE_P){   //如果这个页目录存在
8010107e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101081:	8b 00                	mov    (%eax),%eax
80101083:	83 e0 01             	and    $0x1,%eax
80101086:	85 c0                	test   %eax,%eax
80101088:	74 18                	je     801010a2 <walkpgdir+0x3f>
    pgtab = (pte_t*)p2v(PTE_ADDR(*pde));  //这个页表地址就是当前这个页目录值中的地址 (第一次映射)
8010108a:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010108d:	8b 00                	mov    (%eax),%eax
8010108f:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80101094:	50                   	push   %eax
80101095:	e8 da f9 ff ff       	call   80100a74 <p2v>
8010109a:	83 c4 04             	add    $0x4,%esp
8010109d:	89 45 f4             	mov    %eax,-0xc(%ebp)
801010a0:	eb 48                	jmp    801010ea <walkpgdir+0x87>
  } else {
    
    if(!alloc || (pgtab = (pte_t*)kalloc()) == 0) //如果没有被分配，并且分配的页表失败
801010a2:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
801010a6:	74 0e                	je     801010b6 <walkpgdir+0x53>
801010a8:	e8 b4 f7 ff ff       	call   80100861 <kalloc>
801010ad:	89 45 f4             	mov    %eax,-0xc(%ebp)
801010b0:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801010b4:	75 07                	jne    801010bd <walkpgdir+0x5a>
      return 0;
801010b6:	b8 00 00 00 00       	mov    $0x0,%eax
801010bb:	eb 44                	jmp    80101101 <walkpgdir+0x9e>
    
    memset(pgtab, 0, PGSIZE);  //为分配的页表项填充
801010bd:	83 ec 04             	sub    $0x4,%esp
801010c0:	68 00 10 00 00       	push   $0x1000
801010c5:	6a 00                	push   $0x0
801010c7:	ff 75 f4             	pushl  -0xc(%ebp)
801010ca:	e8 1e f6 ff ff       	call   801006ed <memset>
801010cf:	83 c4 10             	add    $0x10,%esp
    
    *pde = v2p(pgtab) | PTE_P | PTE_W | PTE_U; //为当前创建的页表与页目录进行映射 (第一次映射)
801010d2:	83 ec 0c             	sub    $0xc,%esp
801010d5:	ff 75 f4             	pushl  -0xc(%ebp)
801010d8:	e8 8a f9 ff ff       	call   80100a67 <v2p>
801010dd:	83 c4 10             	add    $0x10,%esp
801010e0:	83 c8 07             	or     $0x7,%eax
801010e3:	89 c2                	mov    %eax,%edx
801010e5:	8b 45 f0             	mov    -0x10(%ebp),%eax
801010e8:	89 10                	mov    %edx,(%eax)
  }
  return &pgtab[PTX(va)];   //返回页表地址
801010ea:	8b 45 0c             	mov    0xc(%ebp),%eax
801010ed:	c1 e8 0c             	shr    $0xc,%eax
801010f0:	25 ff 03 00 00       	and    $0x3ff,%eax
801010f5:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
801010fc:	8b 45 f4             	mov    -0xc(%ebp),%eax
801010ff:	01 d0                	add    %edx,%eax
}
80101101:	c9                   	leave  
80101102:	c3                   	ret    

80101103 <mappages>:

//为以va开始的线性地址创建页项，va引用pa开始处的物理地址，va和size可能没有按页对齐
static int 
mappages(pde_t *pgdir, void *va, uint size, uint pa, int perm)
{
80101103:	55                   	push   %ebp
80101104:	89 e5                	mov    %esp,%ebp
80101106:	83 ec 18             	sub    $0x18,%esp
  char *a, *last;
  pte_t *pte;
  
  a = (char*)PGROUNDDOWN((uint)va);                        //va所在的第一页地址
80101109:	8b 45 0c             	mov    0xc(%ebp),%eax
8010110c:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80101111:	89 45 f4             	mov    %eax,-0xc(%ebp)
  last = (char*)PGROUNDDOWN(((uint)va) + size - 1);        //va所在的最后一页地址
80101114:	8b 55 0c             	mov    0xc(%ebp),%edx
80101117:	8b 45 10             	mov    0x10(%ebp),%eax
8010111a:	01 d0                	add    %edx,%eax
8010111c:	83 e8 01             	sub    $0x1,%eax
8010111f:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80101124:	89 45 f0             	mov    %eax,-0x10(%ebp)
  
  for(;;){
    if((pte = walkpgdir(pgdir, a, 1)) == 0)      //创建页
80101127:	83 ec 04             	sub    $0x4,%esp
8010112a:	6a 01                	push   $0x1
8010112c:	ff 75 f4             	pushl  -0xc(%ebp)
8010112f:	ff 75 08             	pushl  0x8(%ebp)
80101132:	e8 2c ff ff ff       	call   80101063 <walkpgdir>
80101137:	83 c4 10             	add    $0x10,%esp
8010113a:	89 45 ec             	mov    %eax,-0x14(%ebp)
8010113d:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80101141:	75 07                	jne    8010114a <mappages+0x47>
	return -1;
80101143:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80101148:	eb 30                	jmp    8010117a <mappages+0x77>
    *pte = pa | perm | PTE_P;  // 为创建的这个页项分配一个物理空间进行映射(第二次映射)
8010114a:	8b 45 18             	mov    0x18(%ebp),%eax
8010114d:	0b 45 14             	or     0x14(%ebp),%eax
80101150:	83 c8 01             	or     $0x1,%eax
80101153:	89 c2                	mov    %eax,%edx
80101155:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101158:	89 10                	mov    %edx,(%eax)
    if(a == last)
8010115a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010115d:	3b 45 f0             	cmp    -0x10(%ebp),%eax
80101160:	75 08                	jne    8010116a <mappages+0x67>
      break;
80101162:	90                   	nop
    
    //至此，一级页表（页目录）到二级页表（页项）的映射，以及二级页表到物理内存的映射已经结束
    a += PGSIZE;
    pa += PGSIZE;
  }
  return 0;
80101163:	b8 00 00 00 00       	mov    $0x0,%eax
80101168:	eb 10                	jmp    8010117a <mappages+0x77>
    *pte = pa | perm | PTE_P;  // 为创建的这个页项分配一个物理空间进行映射(第二次映射)
    if(a == last)
      break;
    
    //至此，一级页表（页目录）到二级页表（页项）的映射，以及二级页表到物理内存的映射已经结束
    a += PGSIZE;
8010116a:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
    pa += PGSIZE;
80101171:	81 45 14 00 10 00 00 	addl   $0x1000,0x14(%ebp)
  }
80101178:	eb ad                	jmp    80101127 <mappages+0x24>
  return 0;
}
8010117a:	c9                   	leave  
8010117b:	c3                   	ret    

8010117c <setupkvm>:
};


//设置页表的内核部分,返回此页表
pde_t* setupkvm(void)
{
8010117c:	55                   	push   %ebp
8010117d:	89 e5                	mov    %esp,%ebp
8010117f:	53                   	push   %ebx
80101180:	83 ec 14             	sub    $0x14,%esp
  pde_t *pgdir; //先创建一个页目录
  struct kmap *k;

  if((pgdir = (pde_t*)kalloc()) == 0)  //为这个页目录分配一个空间
80101183:	e8 d9 f6 ff ff       	call   80100861 <kalloc>
80101188:	89 45 f0             	mov    %eax,-0x10(%ebp)
8010118b:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
8010118f:	75 07                	jne    80101198 <setupkvm+0x1c>
    return 0;
80101191:	b8 00 00 00 00       	mov    $0x0,%eax
80101196:	eb 6a                	jmp    80101202 <setupkvm+0x86>
 
  memset(pgdir, 0, PGSIZE);  //填充
80101198:	83 ec 04             	sub    $0x4,%esp
8010119b:	68 00 10 00 00       	push   $0x1000
801011a0:	6a 00                	push   $0x0
801011a2:	ff 75 f0             	pushl  -0x10(%ebp)
801011a5:	e8 43 f5 ff ff       	call   801006ed <memset>
801011aa:	83 c4 10             	add    $0x10,%esp
 
  //分配每一页 
  for(k = kmap; k < &kmap[NELEM(kmap)]; k++)
801011ad:	c7 45 f4 80 45 10 80 	movl   $0x80104580,-0xc(%ebp)
801011b4:	eb 40                	jmp    801011f6 <setupkvm+0x7a>
    //为每一个内核的虚拟地址进行到其所指向的物理地址的映射
    if(mappages(pgdir, k->virt, k->phys_end - k->phys_start, 
801011b6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801011b9:	8b 48 0c             	mov    0xc(%eax),%ecx
801011bc:	8b 45 f4             	mov    -0xc(%ebp),%eax
801011bf:	8b 50 04             	mov    0x4(%eax),%edx
801011c2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801011c5:	8b 58 08             	mov    0x8(%eax),%ebx
801011c8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801011cb:	8b 40 04             	mov    0x4(%eax),%eax
801011ce:	29 c3                	sub    %eax,%ebx
801011d0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801011d3:	8b 00                	mov    (%eax),%eax
801011d5:	83 ec 0c             	sub    $0xc,%esp
801011d8:	51                   	push   %ecx
801011d9:	52                   	push   %edx
801011da:	53                   	push   %ebx
801011db:	50                   	push   %eax
801011dc:	ff 75 f0             	pushl  -0x10(%ebp)
801011df:	e8 1f ff ff ff       	call   80101103 <mappages>
801011e4:	83 c4 20             	add    $0x20,%esp
801011e7:	85 c0                	test   %eax,%eax
801011e9:	79 07                	jns    801011f2 <setupkvm+0x76>
		(uint)k->phys_start, k->perm) < 0)
      return 0;
801011eb:	b8 00 00 00 00       	mov    $0x0,%eax
801011f0:	eb 10                	jmp    80101202 <setupkvm+0x86>
    return 0;
 
  memset(pgdir, 0, PGSIZE);  //填充
 
  //分配每一页 
  for(k = kmap; k < &kmap[NELEM(kmap)]; k++)
801011f2:	83 45 f4 10          	addl   $0x10,-0xc(%ebp)
801011f6:	81 7d f4 c0 45 10 80 	cmpl   $0x801045c0,-0xc(%ebp)
801011fd:	72 b7                	jb     801011b6 <setupkvm+0x3a>
    if(mappages(pgdir, k->virt, k->phys_end - k->phys_start, 
		(uint)k->phys_start, k->perm) < 0)
      return 0;

  //返回页目录
  return pgdir;
801011ff:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
80101202:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80101205:	c9                   	leave  
80101206:	c3                   	ret    

80101207 <switchkvm>:


// 切换到页表kpgdir
void switchkvm(void)
{
80101207:	55                   	push   %ebp
80101208:	89 e5                	mov    %esp,%ebp
  lcr3(v2p(kpgdir));   // 切换到内核页表
8010120a:	a1 c0 61 10 80       	mov    0x801061c0,%eax
8010120f:	50                   	push   %eax
80101210:	e8 52 f8 ff ff       	call   80100a67 <v2p>
80101215:	83 c4 04             	add    $0x4,%esp
80101218:	50                   	push   %eax
80101219:	e8 3e f8 ff ff       	call   80100a5c <lcr3>
8010121e:	83 c4 04             	add    $0x4,%esp
}
80101221:	c9                   	leave  
80101222:	c3                   	ret    

80101223 <kvmalloc>:

void kvmalloc(void)
{
80101223:	55                   	push   %ebp
80101224:	89 e5                	mov    %esp,%ebp
80101226:	83 ec 08             	sub    $0x8,%esp
  kpgdir = setupkvm();  // 设置内核页表，以及每一个页表项所指向的页
80101229:	e8 4e ff ff ff       	call   8010117c <setupkvm>
8010122e:	a3 c0 61 10 80       	mov    %eax,0x801061c0
  switchkvm();  	// 切换到内核页表
80101233:	e8 cf ff ff ff       	call   80101207 <switchkvm>
}
80101238:	c9                   	leave  
80101239:	c3                   	ret    

8010123a <inituvm>:

// 映射进程页表到物理内存
void
inituvm(pde_t *pgdir, char *init, uint sz)
{
8010123a:	55                   	push   %ebp
8010123b:	89 e5                	mov    %esp,%ebp
8010123d:	83 ec 18             	sub    $0x18,%esp
  char *mem;
  
  mem = kalloc(); //分配一段物理内存
80101240:	e8 1c f6 ff ff       	call   80100861 <kalloc>
80101245:	89 45 f4             	mov    %eax,-0xc(%ebp)
  memset(mem, 0, PGSIZE); //将这一段物理内存清空为0
80101248:	83 ec 04             	sub    $0x4,%esp
8010124b:	68 00 10 00 00       	push   $0x1000
80101250:	6a 00                	push   $0x0
80101252:	ff 75 f4             	pushl  -0xc(%ebp)
80101255:	e8 93 f4 ff ff       	call   801006ed <memset>
8010125a:	83 c4 10             	add    $0x10,%esp
  mappages(pgdir, 0, PGSIZE, v2p(mem), PTE_W|PTE_U); //映射
8010125d:	83 ec 0c             	sub    $0xc,%esp
80101260:	ff 75 f4             	pushl  -0xc(%ebp)
80101263:	e8 ff f7 ff ff       	call   80100a67 <v2p>
80101268:	83 c4 10             	add    $0x10,%esp
8010126b:	83 ec 0c             	sub    $0xc,%esp
8010126e:	6a 06                	push   $0x6
80101270:	50                   	push   %eax
80101271:	68 00 10 00 00       	push   $0x1000
80101276:	6a 00                	push   $0x0
80101278:	ff 75 08             	pushl  0x8(%ebp)
8010127b:	e8 83 fe ff ff       	call   80101103 <mappages>
80101280:	83 c4 20             	add    $0x20,%esp
  memmove(mem, init, sz);
80101283:	83 ec 04             	sub    $0x4,%esp
80101286:	ff 75 10             	pushl  0x10(%ebp)
80101289:	ff 75 0c             	pushl  0xc(%ebp)
8010128c:	ff 75 f4             	pushl  -0xc(%ebp)
8010128f:	e8 c0 f4 ff ff       	call   80100754 <memmove>
80101294:	83 c4 10             	add    $0x10,%esp
}
80101297:	c9                   	leave  
80101298:	c3                   	ret    

80101299 <switchuvm>:

//切换到用户虚拟内存
void
switchuvm(struct proc *p)
{
80101299:	55                   	push   %ebp
8010129a:	89 e5                	mov    %esp,%ebp
8010129c:	56                   	push   %esi
8010129d:	53                   	push   %ebx
  cpu->gdt[SEG_TSS] = SEG16(STS_T32A, &cpu->ts, sizeof(cpu->ts)-1, 0);
8010129e:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
801012a4:	65 8b 15 00 00 00 00 	mov    %gs:0x0,%edx
801012ab:	83 c2 08             	add    $0x8,%edx
801012ae:	89 d6                	mov    %edx,%esi
801012b0:	65 8b 15 00 00 00 00 	mov    %gs:0x0,%edx
801012b7:	83 c2 08             	add    $0x8,%edx
801012ba:	c1 ea 10             	shr    $0x10,%edx
801012bd:	89 d3                	mov    %edx,%ebx
801012bf:	65 8b 15 00 00 00 00 	mov    %gs:0x0,%edx
801012c6:	83 c2 08             	add    $0x8,%edx
801012c9:	c1 ea 18             	shr    $0x18,%edx
801012cc:	89 d1                	mov    %edx,%ecx
801012ce:	66 c7 80 a0 00 00 00 	movw   $0x67,0xa0(%eax)
801012d5:	67 00 
801012d7:	66 89 b0 a2 00 00 00 	mov    %si,0xa2(%eax)
801012de:	88 98 a4 00 00 00    	mov    %bl,0xa4(%eax)
801012e4:	0f b6 90 a5 00 00 00 	movzbl 0xa5(%eax),%edx
801012eb:	83 e2 f0             	and    $0xfffffff0,%edx
801012ee:	83 ca 09             	or     $0x9,%edx
801012f1:	88 90 a5 00 00 00    	mov    %dl,0xa5(%eax)
801012f7:	0f b6 90 a5 00 00 00 	movzbl 0xa5(%eax),%edx
801012fe:	83 ca 10             	or     $0x10,%edx
80101301:	88 90 a5 00 00 00    	mov    %dl,0xa5(%eax)
80101307:	0f b6 90 a5 00 00 00 	movzbl 0xa5(%eax),%edx
8010130e:	83 e2 9f             	and    $0xffffff9f,%edx
80101311:	88 90 a5 00 00 00    	mov    %dl,0xa5(%eax)
80101317:	0f b6 90 a5 00 00 00 	movzbl 0xa5(%eax),%edx
8010131e:	83 ca 80             	or     $0xffffff80,%edx
80101321:	88 90 a5 00 00 00    	mov    %dl,0xa5(%eax)
80101327:	0f b6 90 a6 00 00 00 	movzbl 0xa6(%eax),%edx
8010132e:	83 e2 f0             	and    $0xfffffff0,%edx
80101331:	88 90 a6 00 00 00    	mov    %dl,0xa6(%eax)
80101337:	0f b6 90 a6 00 00 00 	movzbl 0xa6(%eax),%edx
8010133e:	83 e2 ef             	and    $0xffffffef,%edx
80101341:	88 90 a6 00 00 00    	mov    %dl,0xa6(%eax)
80101347:	0f b6 90 a6 00 00 00 	movzbl 0xa6(%eax),%edx
8010134e:	83 e2 df             	and    $0xffffffdf,%edx
80101351:	88 90 a6 00 00 00    	mov    %dl,0xa6(%eax)
80101357:	0f b6 90 a6 00 00 00 	movzbl 0xa6(%eax),%edx
8010135e:	83 ca 40             	or     $0x40,%edx
80101361:	88 90 a6 00 00 00    	mov    %dl,0xa6(%eax)
80101367:	0f b6 90 a6 00 00 00 	movzbl 0xa6(%eax),%edx
8010136e:	83 e2 7f             	and    $0x7f,%edx
80101371:	88 90 a6 00 00 00    	mov    %dl,0xa6(%eax)
80101377:	88 88 a7 00 00 00    	mov    %cl,0xa7(%eax)
  cpu->gdt[SEG_TSS].s = 0;
8010137d:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80101383:	0f b6 90 a5 00 00 00 	movzbl 0xa5(%eax),%edx
8010138a:	83 e2 ef             	and    $0xffffffef,%edx
8010138d:	88 90 a5 00 00 00    	mov    %dl,0xa5(%eax)
  cpu->ts.ss0 = SEG_KDATA << 3;
80101393:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80101399:	66 c7 40 10 10 00    	movw   $0x10,0x10(%eax)
  cpu->ts.esp0 = (uint)proc->kstack + KSTACKSIZE;
8010139f:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
801013a5:	65 8b 15 04 00 00 00 	mov    %gs:0x4,%edx
801013ac:	8b 52 08             	mov    0x8(%edx),%edx
801013af:	81 c2 00 10 00 00    	add    $0x1000,%edx
801013b5:	89 50 0c             	mov    %edx,0xc(%eax)
  ltr(SEG_TSS << 3);
801013b8:	6a 30                	push   $0x30
801013ba:	e8 72 f6 ff ff       	call   80100a31 <ltr>
801013bf:	83 c4 04             	add    $0x4,%esp
  lcr3(v2p(p->pgdir));  // switch to new address space
801013c2:	8b 45 08             	mov    0x8(%ebp),%eax
801013c5:	8b 40 04             	mov    0x4(%eax),%eax
801013c8:	50                   	push   %eax
801013c9:	e8 99 f6 ff ff       	call   80100a67 <v2p>
801013ce:	83 c4 04             	add    $0x4,%esp
801013d1:	50                   	push   %eax
801013d2:	e8 85 f6 ff ff       	call   80100a5c <lcr3>
801013d7:	83 c4 04             	add    $0x4,%esp
}
801013da:	8d 65 f8             	lea    -0x8(%ebp),%esp
801013dd:	5b                   	pop    %ebx
801013de:	5e                   	pop    %esi
801013df:	5d                   	pop    %ebp
801013e0:	c3                   	ret    

801013e1 <outb>:
               "memory", "cc");
}

static inline void
outb(ushort port, uchar data)
{
801013e1:	55                   	push   %ebp
801013e2:	89 e5                	mov    %esp,%ebp
801013e4:	83 ec 08             	sub    $0x8,%esp
801013e7:	8b 55 08             	mov    0x8(%ebp),%edx
801013ea:	8b 45 0c             	mov    0xc(%ebp),%eax
801013ed:	66 89 55 fc          	mov    %dx,-0x4(%ebp)
801013f1:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
801013f4:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
801013f8:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
801013fc:	ee                   	out    %al,(%dx)
}
801013fd:	c9                   	leave  
801013fe:	c3                   	ret    

801013ff <picsetmask>:

static ushort irqmask = 0xFFFF & ~(1<<IRQ_SLAVE);

static void
picsetmask(ushort mask)
{
801013ff:	55                   	push   %ebp
80101400:	89 e5                	mov    %esp,%ebp
80101402:	83 ec 04             	sub    $0x4,%esp
80101405:	8b 45 08             	mov    0x8(%ebp),%eax
80101408:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  irqmask = mask;
8010140c:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
80101410:	66 a3 c0 45 10 80    	mov    %ax,0x801045c0
  outb(IO_PIC1+1, mask);
80101416:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
8010141a:	0f b6 c0             	movzbl %al,%eax
8010141d:	50                   	push   %eax
8010141e:	6a 21                	push   $0x21
80101420:	e8 bc ff ff ff       	call   801013e1 <outb>
80101425:	83 c4 08             	add    $0x8,%esp
  outb(IO_PIC2+1, mask >> 8);
80101428:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
8010142c:	66 c1 e8 08          	shr    $0x8,%ax
80101430:	0f b6 c0             	movzbl %al,%eax
80101433:	50                   	push   %eax
80101434:	68 a1 00 00 00       	push   $0xa1
80101439:	e8 a3 ff ff ff       	call   801013e1 <outb>
8010143e:	83 c4 08             	add    $0x8,%esp
}
80101441:	c9                   	leave  
80101442:	c3                   	ret    

80101443 <picenable>:

void
picenable(int irq)
{
80101443:	55                   	push   %ebp
80101444:	89 e5                	mov    %esp,%ebp
  picsetmask(irqmask & ~(1<<irq));
80101446:	8b 45 08             	mov    0x8(%ebp),%eax
80101449:	ba 01 00 00 00       	mov    $0x1,%edx
8010144e:	89 c1                	mov    %eax,%ecx
80101450:	d3 e2                	shl    %cl,%edx
80101452:	89 d0                	mov    %edx,%eax
80101454:	f7 d0                	not    %eax
80101456:	89 c2                	mov    %eax,%edx
80101458:	0f b7 05 c0 45 10 80 	movzwl 0x801045c0,%eax
8010145f:	21 d0                	and    %edx,%eax
80101461:	0f b7 c0             	movzwl %ax,%eax
80101464:	50                   	push   %eax
80101465:	e8 95 ff ff ff       	call   801013ff <picsetmask>
8010146a:	83 c4 04             	add    $0x4,%esp
}
8010146d:	c9                   	leave  
8010146e:	c3                   	ret    

8010146f <picinit>:

//初始化8259A的中断控制器
void
picinit(void)
{
8010146f:	55                   	push   %ebp
80101470:	89 e5                	mov    %esp,%ebp
  // 屏蔽掉所有的中断
  outb(IO_PIC1+1, 0xFF);
80101472:	68 ff 00 00 00       	push   $0xff
80101477:	6a 21                	push   $0x21
80101479:	e8 63 ff ff ff       	call   801013e1 <outb>
8010147e:	83 c4 08             	add    $0x8,%esp
  outb(IO_PIC2+1, 0xFF);
80101481:	68 ff 00 00 00       	push   $0xff
80101486:	68 a1 00 00 00       	push   $0xa1
8010148b:	e8 51 ff ff ff       	call   801013e1 <outb>
80101490:	83 c4 08             	add    $0x8,%esp

  // 设置主控制器

  outb(IO_PIC1, 0x11);    	  	// ICW1
80101493:	6a 11                	push   $0x11
80101495:	6a 20                	push   $0x20
80101497:	e8 45 ff ff ff       	call   801013e1 <outb>
8010149c:	83 c4 08             	add    $0x8,%esp
  outb(IO_PIC1+1, T_IRQ0); 		// ICW2, 设置所有中断向量偏移地址
8010149f:	6a 20                	push   $0x20
801014a1:	6a 21                	push   $0x21
801014a3:	e8 39 ff ff ff       	call   801013e1 <outb>
801014a8:	83 c4 08             	add    $0x8,%esp
  outb(IO_PIC1+1, 1<<IRQ_SLAVE); 	// ICW3
801014ab:	6a 04                	push   $0x4
801014ad:	6a 21                	push   $0x21
801014af:	e8 2d ff ff ff       	call   801013e1 <outb>
801014b4:	83 c4 08             	add    $0x8,%esp
  outb(IO_PIC1+1, 0x3); 		// ICW4
801014b7:	6a 03                	push   $0x3
801014b9:	6a 21                	push   $0x21
801014bb:	e8 21 ff ff ff       	call   801013e1 <outb>
801014c0:	83 c4 08             	add    $0x8,%esp

  // 设置从控制器
  
  outb(IO_PIC2, 0x11);                  // ICW1
801014c3:	6a 11                	push   $0x11
801014c5:	68 a0 00 00 00       	push   $0xa0
801014ca:	e8 12 ff ff ff       	call   801013e1 <outb>
801014cf:	83 c4 08             	add    $0x8,%esp
  outb(IO_PIC2+1, T_IRQ0 + 8);          // ICW2
801014d2:	6a 28                	push   $0x28
801014d4:	68 a1 00 00 00       	push   $0xa1
801014d9:	e8 03 ff ff ff       	call   801013e1 <outb>
801014de:	83 c4 08             	add    $0x8,%esp
  outb(IO_PIC2+1, IRQ_SLAVE);           // ICW3
801014e1:	6a 02                	push   $0x2
801014e3:	68 a1 00 00 00       	push   $0xa1
801014e8:	e8 f4 fe ff ff       	call   801013e1 <outb>
801014ed:	83 c4 08             	add    $0x8,%esp
  outb(IO_PIC2+1, 0x3);                 // ICW4
801014f0:	6a 03                	push   $0x3
801014f2:	68 a1 00 00 00       	push   $0xa1
801014f7:	e8 e5 fe ff ff       	call   801013e1 <outb>
801014fc:	83 c4 08             	add    $0x8,%esp
  
  //设置OCW3  
  outb(IO_PIC1, 0x68);            
801014ff:	6a 68                	push   $0x68
80101501:	6a 20                	push   $0x20
80101503:	e8 d9 fe ff ff       	call   801013e1 <outb>
80101508:	83 c4 08             	add    $0x8,%esp
  outb(IO_PIC1, 0x0a);            
8010150b:	6a 0a                	push   $0xa
8010150d:	6a 20                	push   $0x20
8010150f:	e8 cd fe ff ff       	call   801013e1 <outb>
80101514:	83 c4 08             	add    $0x8,%esp

  outb(IO_PIC2, 0x68);             // OCW3
80101517:	6a 68                	push   $0x68
80101519:	68 a0 00 00 00       	push   $0xa0
8010151e:	e8 be fe ff ff       	call   801013e1 <outb>
80101523:	83 c4 08             	add    $0x8,%esp
  outb(IO_PIC2, 0x0a);             // OCW3
80101526:	6a 0a                	push   $0xa
80101528:	68 a0 00 00 00       	push   $0xa0
8010152d:	e8 af fe ff ff       	call   801013e1 <outb>
80101532:	83 c4 08             	add    $0x8,%esp

  if(irqmask != 0xFFFF)
80101535:	0f b7 05 c0 45 10 80 	movzwl 0x801045c0,%eax
8010153c:	66 83 f8 ff          	cmp    $0xffff,%ax
80101540:	74 13                	je     80101555 <picinit+0xe6>
    picsetmask(irqmask);
80101542:	0f b7 05 c0 45 10 80 	movzwl 0x801045c0,%eax
80101549:	0f b7 c0             	movzwl %ax,%eax
8010154c:	50                   	push   %eax
8010154d:	e8 ad fe ff ff       	call   801013ff <picsetmask>
80101552:	83 c4 04             	add    $0x4,%esp
}
80101555:	c9                   	leave  
80101556:	c3                   	ret    

80101557 <sti>:
  asm volatile("cli");
}

static inline void
sti(void)
{
80101557:	55                   	push   %ebp
80101558:	89 e5                	mov    %esp,%ebp
  asm volatile("sti");
8010155a:	fb                   	sti    
}
8010155b:	5d                   	pop    %ebp
8010155c:	c3                   	ret    

8010155d <allocproc>:
extern void trapret(void);  //定义在了trapasm.S里面
extern void forkret(void);

struct proc*
allocproc(void)
{
8010155d:	55                   	push   %ebp
8010155e:	89 e5                	mov    %esp,%ebp
80101560:	83 ec 18             	sub    $0x18,%esp
  struct proc *p;
  char *sp;

  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
80101563:	c7 45 f4 c0 62 10 80 	movl   $0x801062c0,-0xc(%ebp)
8010156a:	eb 46                	jmp    801015b2 <allocproc+0x55>
    if(p->state == UNUSED)
8010156c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010156f:	8b 40 0c             	mov    0xc(%eax),%eax
80101572:	85 c0                	test   %eax,%eax
80101574:	75 38                	jne    801015ae <allocproc+0x51>
      goto found;
80101576:	90                   	nop
  return 0;

found:
  p->state = EMBRYO;  //修改进程的状态位
80101577:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010157a:	c7 40 0c 01 00 00 00 	movl   $0x1,0xc(%eax)
  p->pid = nextpid++;
80101581:	a1 c4 45 10 80       	mov    0x801045c4,%eax
80101586:	8d 50 01             	lea    0x1(%eax),%edx
80101589:	89 15 c4 45 10 80    	mov    %edx,0x801045c4
8010158f:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101592:	89 42 10             	mov    %eax,0x10(%edx)

  // 为一个进程分配一段内核栈
  if((p->kstack = kalloc()) == 0){ //分配进程内核栈失败
80101595:	e8 c7 f2 ff ff       	call   80100861 <kalloc>
8010159a:	89 c2                	mov    %eax,%edx
8010159c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010159f:	89 50 08             	mov    %edx,0x8(%eax)
801015a2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801015a5:	8b 40 08             	mov    0x8(%eax),%eax
801015a8:	85 c0                	test   %eax,%eax
801015aa:	75 27                	jne    801015d3 <allocproc+0x76>
801015ac:	eb 14                	jmp    801015c2 <allocproc+0x65>
allocproc(void)
{
  struct proc *p;
  char *sp;

  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
801015ae:	83 45 f4 30          	addl   $0x30,-0xc(%ebp)
801015b2:	81 7d f4 c0 6e 10 80 	cmpl   $0x80106ec0,-0xc(%ebp)
801015b9:	72 b1                	jb     8010156c <allocproc+0xf>
    if(p->state == UNUSED)
      goto found;
  return 0;
801015bb:	b8 00 00 00 00       	mov    $0x0,%eax
801015c0:	eb 6a                	jmp    8010162c <allocproc+0xcf>
  p->state = EMBRYO;  //修改进程的状态位
  p->pid = nextpid++;

  // 为一个进程分配一段内核栈
  if((p->kstack = kalloc()) == 0){ //分配进程内核栈失败
    p->state = UNUSED;
801015c2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801015c5:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
    return 0;
801015cc:	b8 00 00 00 00       	mov    $0x0,%eax
801015d1:	eb 59                	jmp    8010162c <allocproc+0xcf>
  }
  sp = p->kstack + KSTACKSIZE; //sp为为这个进程分配的内核栈的栈顶地址
801015d3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801015d6:	8b 40 08             	mov    0x8(%eax),%eax
801015d9:	05 00 10 00 00       	add    $0x1000,%eax
801015de:	89 45 f0             	mov    %eax,-0x10(%ebp)
  
  sp -= sizeof *p->tf;   //流出陷入帧需要的空间
801015e1:	83 6d f0 4c          	subl   $0x4c,-0x10(%ebp)
  p->tf = (struct trapframe*)sp; //当前的陷入帧
801015e5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801015e8:	8b 55 f0             	mov    -0x10(%ebp),%edx
801015eb:	89 50 14             	mov    %edx,0x14(%eax)
  
  // 设置新的上下文来开始执行forket
  // 最终返回到trapret.
  sp -= 4;
801015ee:	83 6d f0 04          	subl   $0x4,-0x10(%ebp)
  *(uint*)sp = (uint)trapret;  //压入trapret的地址供forkret返回
801015f2:	ba f4 27 10 80       	mov    $0x801027f4,%edx
801015f7:	8b 45 f0             	mov    -0x10(%ebp),%eax
801015fa:	89 10                	mov    %edx,(%eax)

  sp -= sizeof *p->context;  //留出上下文需要的空间
801015fc:	83 6d f0 14          	subl   $0x14,-0x10(%ebp)
  p->context = (struct context*)sp;   //进程的上下文
80101600:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101603:	8b 55 f0             	mov    -0x10(%ebp),%edx
80101606:	89 50 18             	mov    %edx,0x18(%eax)
  memset(p->context, 0, sizeof *p->context);  // 将上下文清空
80101609:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010160c:	8b 40 18             	mov    0x18(%eax),%eax
8010160f:	83 ec 04             	sub    $0x4,%esp
80101612:	6a 14                	push   $0x14
80101614:	6a 00                	push   $0x0
80101616:	50                   	push   %eax
80101617:	e8 d1 f0 ff ff       	call   801006ed <memset>
8010161c:	83 c4 10             	add    $0x10,%esp
  p->state = ALLOCATED;
8010161f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101622:	c7 40 0c 06 00 00 00 	movl   $0x6,0xc(%eax)
//  p->context->eip = (uint)forkret;   //把当前上下文的起始地址设置为forkret

  return p;
80101629:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
8010162c:	c9                   	leave  
8010162d:	c3                   	ret    

8010162e <printproc>:

//打印当前进程表中的所有进程的信息
void printproc(void)
{
8010162e:	55                   	push   %ebp
8010162f:	89 e5                	mov    %esp,%ebp
80101631:	83 ec 18             	sub    $0x18,%esp
  struct proc* p;
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
80101634:	c7 45 f4 c0 62 10 80 	movl   $0x801062c0,-0xc(%ebp)
8010163b:	eb 69                	jmp    801016a6 <printproc+0x78>
  {
      if(p->state == ALLOCATED)
8010163d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101640:	8b 40 0c             	mov    0xc(%eax),%eax
80101643:	83 f8 06             	cmp    $0x6,%eax
80101646:	75 5a                	jne    801016a2 <printproc+0x74>
      {
 	 cprintf("Process %d's kernelstack is %x\n",p->pid, p->kstack);  //该进程的内核栈的栈底地址
80101648:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010164b:	8b 50 08             	mov    0x8(%eax),%edx
8010164e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101651:	8b 40 10             	mov    0x10(%eax),%eax
80101654:	83 ec 04             	sub    $0x4,%esp
80101657:	52                   	push   %edx
80101658:	50                   	push   %eax
80101659:	68 7c 2a 10 80       	push   $0x80102a7c
8010165e:	e8 2a eb ff ff       	call   8010018d <cprintf>
80101663:	83 c4 10             	add    $0x10,%esp
	 cprintf("Process %d's context is %x\n",p->pid, p->context);   //该进程的上下文地址
80101666:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101669:	8b 50 18             	mov    0x18(%eax),%edx
8010166c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010166f:	8b 40 10             	mov    0x10(%eax),%eax
80101672:	83 ec 04             	sub    $0x4,%esp
80101675:	52                   	push   %edx
80101676:	50                   	push   %eax
80101677:	68 9c 2a 10 80       	push   $0x80102a9c
8010167c:	e8 0c eb ff ff       	call   8010018d <cprintf>
80101681:	83 c4 10             	add    $0x10,%esp
 	 cprintf("Process %d's trapframe is %x\n",p->pid, p->tf);   //该进程的陷入帧的地址
80101684:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101687:	8b 50 14             	mov    0x14(%eax),%edx
8010168a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010168d:	8b 40 10             	mov    0x10(%eax),%eax
80101690:	83 ec 04             	sub    $0x4,%esp
80101693:	52                   	push   %edx
80101694:	50                   	push   %eax
80101695:	68 b8 2a 10 80       	push   $0x80102ab8
8010169a:	e8 ee ea ff ff       	call   8010018d <cprintf>
8010169f:	83 c4 10             	add    $0x10,%esp

//打印当前进程表中的所有进程的信息
void printproc(void)
{
  struct proc* p;
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
801016a2:	83 45 f4 30          	addl   $0x30,-0xc(%ebp)
801016a6:	81 7d f4 c0 6e 10 80 	cmpl   $0x80106ec0,-0xc(%ebp)
801016ad:	72 8e                	jb     8010163d <printproc+0xf>
	 cprintf("Process %d's context is %x\n",p->pid, p->context);   //该进程的上下文地址
 	 cprintf("Process %d's trapframe is %x\n",p->pid, p->tf);   //该进程的陷入帧的地址
      }
  }

}
801016af:	c9                   	leave  
801016b0:	c3                   	ret    

801016b1 <userinit>:

void
userinit(void)
{
801016b1:	55                   	push   %ebp
801016b2:	89 e5                	mov    %esp,%ebp
801016b4:	83 ec 18             	sub    $0x18,%esp
  struct proc *p;
  extern char _binary_initcode_start[], _binary_initcode_size[]; //initcode的起始地址以及大小
  
  p = allocproc(); //分配一个进程
801016b7:	e8 a1 fe ff ff       	call   8010155d <allocproc>
801016bc:	89 45 f4             	mov    %eax,-0xc(%ebp)
  currentproc = p; //当前进程
801016bf:	8b 45 f4             	mov    -0xc(%ebp),%eax
801016c2:	a3 48 4f 10 80       	mov    %eax,0x80104f48
  p->pgdir = setupkvm(); //设置这个进程的页表
801016c7:	e8 b0 fa ff ff       	call   8010117c <setupkvm>
801016cc:	89 c2                	mov    %eax,%edx
801016ce:	8b 45 f4             	mov    -0xc(%ebp),%eax
801016d1:	89 50 04             	mov    %edx,0x4(%eax)
  inituvm(p->pgdir, _binary_initcode_start, (int)_binary_initcode_size);  //将initcode装载到pgdir的0地址处
801016d4:	ba 24 00 00 00       	mov    $0x24,%edx
801016d9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801016dc:	8b 40 04             	mov    0x4(%eax),%eax
801016df:	83 ec 04             	sub    $0x4,%esp
801016e2:	52                   	push   %edx
801016e3:	68 00 4f 10 80       	push   $0x80104f00
801016e8:	50                   	push   %eax
801016e9:	e8 4c fb ff ff       	call   8010123a <inituvm>
801016ee:	83 c4 10             	add    $0x10,%esp
  p->sz = PGSIZE;   //代码的最大有效虚拟地址
801016f1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801016f4:	c7 00 00 10 00 00    	movl   $0x1000,(%eax)
  memset(p->tf, 0, sizeof(*p->tf)); // 为用户进程寄存器开辟空间
801016fa:	8b 45 f4             	mov    -0xc(%ebp),%eax
801016fd:	8b 40 14             	mov    0x14(%eax),%eax
80101700:	83 ec 04             	sub    $0x4,%esp
80101703:	6a 4c                	push   $0x4c
80101705:	6a 00                	push   $0x0
80101707:	50                   	push   %eax
80101708:	e8 e0 ef ff ff       	call   801006ed <memset>
8010170d:	83 c4 10             	add    $0x10,%esp

  //设置此进程的陷入帧
  p->tf->cs = (SEG_UCODE << 3) | DPL_USER;
80101710:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101713:	8b 40 14             	mov    0x14(%eax),%eax
80101716:	66 c7 40 3c 23 00    	movw   $0x23,0x3c(%eax)
  p->tf->ds = (SEG_UDATA << 3) | DPL_USER;
8010171c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010171f:	8b 40 14             	mov    0x14(%eax),%eax
80101722:	66 c7 40 2c 2b 00    	movw   $0x2b,0x2c(%eax)
  p->tf->es = p->tf->ds;
80101728:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010172b:	8b 40 14             	mov    0x14(%eax),%eax
8010172e:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101731:	8b 52 14             	mov    0x14(%edx),%edx
80101734:	0f b7 52 2c          	movzwl 0x2c(%edx),%edx
80101738:	66 89 50 28          	mov    %dx,0x28(%eax)
  p->tf->ss = p->tf->ds;
8010173c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010173f:	8b 40 14             	mov    0x14(%eax),%eax
80101742:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101745:	8b 52 14             	mov    0x14(%edx),%edx
80101748:	0f b7 52 2c          	movzwl 0x2c(%edx),%edx
8010174c:	66 89 50 48          	mov    %dx,0x48(%eax)
  p->tf->eflags = FL_IF; 
80101750:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101753:	8b 40 14             	mov    0x14(%eax),%eax
80101756:	c7 40 40 00 02 00 00 	movl   $0x200,0x40(%eax)
  p->tf->esp = PGSIZE;
8010175d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101760:	8b 40 14             	mov    0x14(%eax),%eax
80101763:	c7 40 44 00 10 00 00 	movl   $0x1000,0x44(%eax)
  p->tf->eip = 0;  
8010176a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010176d:	8b 40 14             	mov    0x14(%eax),%eax
80101770:	c7 40 38 00 00 00 00 	movl   $0x0,0x38(%eax)

//  safestrcpy(p->name, "initcode", sizeof(p->name));
//  p->cwd = namei("/");    //指明进程目录，由于是第一个进程，所以在根目录

  p->state = RUNNABLE;    //将进程的状态改为runable
80101777:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010177a:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
}
80101781:	c9                   	leave  
80101782:	c3                   	ret    

80101783 <scheduler>:

void
scheduler(void)
{
80101783:	55                   	push   %ebp
80101784:	89 e5                	mov    %esp,%ebp
80101786:	83 ec 18             	sub    $0x18,%esp
  struct proc *p;

  //无限循环
  for(;;){
    //打开这个CPU的所有中断
      sti();
80101789:	e8 c9 fd ff ff       	call   80101557 <sti>

    // 循环遍历进程表，查找到一个进程以后就开始执行
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
8010178e:	c7 45 f4 c0 62 10 80 	movl   $0x801062c0,-0xc(%ebp)
80101795:	eb 62                	jmp    801017f9 <scheduler+0x76>
      if(p->state != RUNNABLE)
80101797:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010179a:	8b 40 0c             	mov    0xc(%eax),%eax
8010179d:	83 f8 03             	cmp    $0x3,%eax
801017a0:	74 02                	je     801017a4 <scheduler+0x21>
        continue;
801017a2:	eb 51                	jmp    801017f5 <scheduler+0x72>

      // 找到可以runable的进程，准备执行
      proc = p;
801017a4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801017a7:	65 a3 04 00 00 00    	mov    %eax,%gs:0x4
      switchuvm(p);  //切换到这个进程的页表
801017ad:	83 ec 0c             	sub    $0xc,%esp
801017b0:	ff 75 f4             	pushl  -0xc(%ebp)
801017b3:	e8 e1 fa ff ff       	call   80101299 <switchuvm>
801017b8:	83 c4 10             	add    $0x10,%esp
      p->state = RUNNING;  //将这个进程的状态更改为running
801017bb:	8b 45 f4             	mov    -0xc(%ebp),%eax
801017be:	c7 40 0c 04 00 00 00 	movl   $0x4,0xc(%eax)
      swtch(&cpu->scheduler, proc->context);  //切换到进程上下文，同时保存当前上下文
801017c5:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801017cb:	8b 40 18             	mov    0x18(%eax),%eax
801017ce:	65 8b 15 00 00 00 00 	mov    %gs:0x0,%edx
801017d5:	83 c2 04             	add    $0x4,%edx
801017d8:	83 ec 08             	sub    $0x8,%esp
801017db:	50                   	push   %eax
801017dc:	52                   	push   %edx
801017dd:	e8 b0 0d 00 00       	call   80102592 <swtch>
801017e2:	83 c4 10             	add    $0x10,%esp
      
      switchkvm(); //转回到内核页表
801017e5:	e8 1d fa ff ff       	call   80101207 <switchkvm>

      //到目前位置进程已经执行完毕，回到此处之前要更改进程的状态
      proc = 0;  //CPU当前运行进程置空
801017ea:	65 c7 05 04 00 00 00 	movl   $0x0,%gs:0x4
801017f1:	00 00 00 00 
  for(;;){
    //打开这个CPU的所有中断
      sti();

    // 循环遍历进程表，查找到一个进程以后就开始执行
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
801017f5:	83 45 f4 30          	addl   $0x30,-0xc(%ebp)
801017f9:	81 7d f4 c0 6e 10 80 	cmpl   $0x80106ec0,-0xc(%ebp)
80101800:	72 95                	jb     80101797 <scheduler+0x14>

      //到目前位置进程已经执行完毕，回到此处之前要更改进程的状态
      proc = 0;  //CPU当前运行进程置空
    }

  }
80101802:	eb 85                	jmp    80101789 <scheduler+0x6>

80101804 <confirmalloc>:
}

void 
confirmalloc()
{
80101804:	55                   	push   %ebp
80101805:	89 e5                	mov    %esp,%ebp
80101807:	83 ec 18             	sub    $0x18,%esp
  struct proc *p;
  if((p = allocproc()) == 0)  //分配一个进程
8010180a:	e8 4e fd ff ff       	call   8010155d <allocproc>
8010180f:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101812:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80101816:	75 12                	jne    8010182a <confirmalloc+0x26>
      cprintf("Faild in building\n");
80101818:	83 ec 0c             	sub    $0xc,%esp
8010181b:	68 d6 2a 10 80       	push   $0x80102ad6
80101820:	e8 68 e9 ff ff       	call   8010018d <cprintf>
80101825:	83 c4 10             	add    $0x10,%esp
80101828:	eb 17                	jmp    80101841 <confirmalloc+0x3d>
  else cprintf("Building process %d successed!!\n",p->pid);
8010182a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010182d:	8b 40 10             	mov    0x10(%eax),%eax
80101830:	83 ec 08             	sub    $0x8,%esp
80101833:	50                   	push   %eax
80101834:	68 ec 2a 10 80       	push   $0x80102aec
80101839:	e8 4f e9 ff ff       	call   8010018d <cprintf>
8010183e:	83 c4 10             	add    $0x10,%esp
//  procinit();
//  cprintf("Building process %d successed!!\n",currentproc->pid);
}
80101841:	c9                   	leave  
80101842:	c3                   	ret    

80101843 <ioapicwrite>:
  uint data;
};

//写入reg，并写入数据
static void ioapicwrite(int reg, uint data)
{
80101843:	55                   	push   %ebp
80101844:	89 e5                	mov    %esp,%ebp
  ioapic->reg = reg;
80101846:	a1 c0 6e 10 80       	mov    0x80106ec0,%eax
8010184b:	8b 55 08             	mov    0x8(%ebp),%edx
8010184e:	89 10                	mov    %edx,(%eax)
  ioapic->data = data;
80101850:	a1 c0 6e 10 80       	mov    0x80106ec0,%eax
80101855:	8b 55 0c             	mov    0xc(%ebp),%edx
80101858:	89 50 10             	mov    %edx,0x10(%eax)
}
8010185b:	5d                   	pop    %ebp
8010185c:	c3                   	ret    

8010185d <ioapicread>:

//写入reg，并读取数据
static uint ioapicread(int reg)
{
8010185d:	55                   	push   %ebp
8010185e:	89 e5                	mov    %esp,%ebp
  ioapic->reg = reg;
80101860:	a1 c0 6e 10 80       	mov    0x80106ec0,%eax
80101865:	8b 55 08             	mov    0x8(%ebp),%edx
80101868:	89 10                	mov    %edx,(%eax)
  return ioapic->data;
8010186a:	a1 c0 6e 10 80       	mov    0x80106ec0,%eax
8010186f:	8b 40 10             	mov    0x10(%eax),%eax
}
80101872:	5d                   	pop    %ebp
80101873:	c3                   	ret    

80101874 <ioapicinit>:

//IOAPIC的初始化
void ioapicinit(void)
{
80101874:	55                   	push   %ebp
80101875:	89 e5                	mov    %esp,%ebp
80101877:	83 ec 10             	sub    $0x10,%esp
  int i, maxintr;

  ioapic = (volatile struct ioapic*)IOAPIC;    //IOAPIC的默认的初始地址
8010187a:	c7 05 c0 6e 10 80 00 	movl   $0xfec00000,0x80106ec0
80101881:	00 c0 fe 
  maxintr = (ioapicread(REG_VER) >> 16) & 0xFF;
80101884:	6a 01                	push   $0x1
80101886:	e8 d2 ff ff ff       	call   8010185d <ioapicread>
8010188b:	83 c4 04             	add    $0x4,%esp
8010188e:	c1 e8 10             	shr    $0x10,%eax
80101891:	25 ff 00 00 00       	and    $0xff,%eax
80101896:	89 45 f8             	mov    %eax,-0x8(%ebp)

  //标记所有的中断为边缘触发，激活高寄存器，关闭中断，不传送给CPU
  for(i = 0; i <= maxintr; i++){
80101899:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
801018a0:	eb 39                	jmp    801018db <ioapicinit+0x67>
    ioapicwrite(REG_TABLE+2*i, INT_DISABLED | (T_IRQ0 + i));
801018a2:	8b 45 fc             	mov    -0x4(%ebp),%eax
801018a5:	83 c0 20             	add    $0x20,%eax
801018a8:	0d 00 00 01 00       	or     $0x10000,%eax
801018ad:	89 c2                	mov    %eax,%edx
801018af:	8b 45 fc             	mov    -0x4(%ebp),%eax
801018b2:	83 c0 08             	add    $0x8,%eax
801018b5:	01 c0                	add    %eax,%eax
801018b7:	52                   	push   %edx
801018b8:	50                   	push   %eax
801018b9:	e8 85 ff ff ff       	call   80101843 <ioapicwrite>
801018be:	83 c4 08             	add    $0x8,%esp
    ioapicwrite(REG_TABLE+2*i+1, 0);
801018c1:	8b 45 fc             	mov    -0x4(%ebp),%eax
801018c4:	83 c0 08             	add    $0x8,%eax
801018c7:	01 c0                	add    %eax,%eax
801018c9:	83 c0 01             	add    $0x1,%eax
801018cc:	6a 00                	push   $0x0
801018ce:	50                   	push   %eax
801018cf:	e8 6f ff ff ff       	call   80101843 <ioapicwrite>
801018d4:	83 c4 08             	add    $0x8,%esp

  ioapic = (volatile struct ioapic*)IOAPIC;    //IOAPIC的默认的初始地址
  maxintr = (ioapicread(REG_VER) >> 16) & 0xFF;

  //标记所有的中断为边缘触发，激活高寄存器，关闭中断，不传送给CPU
  for(i = 0; i <= maxintr; i++){
801018d7:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
801018db:	8b 45 fc             	mov    -0x4(%ebp),%eax
801018de:	3b 45 f8             	cmp    -0x8(%ebp),%eax
801018e1:	7e bf                	jle    801018a2 <ioapicinit+0x2e>
    ioapicwrite(REG_TABLE+2*i, INT_DISABLED | (T_IRQ0 + i));
    ioapicwrite(REG_TABLE+2*i+1, 0);
  }
}
801018e3:	c9                   	leave  
801018e4:	c3                   	ret    

801018e5 <ioapicenable>:

void ioapicenable(int irq, int cpunum)
{
801018e5:	55                   	push   %ebp
801018e6:	89 e5                	mov    %esp,%ebp
  if(!ismp)
801018e8:	a1 c4 6e 10 80       	mov    0x80106ec4,%eax
801018ed:	85 c0                	test   %eax,%eax
801018ef:	75 02                	jne    801018f3 <ioapicenable+0xe>
      return;
801018f1:	eb 37                	jmp    8010192a <ioapicenable+0x45>

  //标记所有的中断为边缘触发，激活高寄存器，打开中断，传送给CPU
  ioapicwrite(REG_TABLE+2*irq, T_IRQ0 + irq);
801018f3:	8b 45 08             	mov    0x8(%ebp),%eax
801018f6:	83 c0 20             	add    $0x20,%eax
801018f9:	89 c2                	mov    %eax,%edx
801018fb:	8b 45 08             	mov    0x8(%ebp),%eax
801018fe:	83 c0 08             	add    $0x8,%eax
80101901:	01 c0                	add    %eax,%eax
80101903:	52                   	push   %edx
80101904:	50                   	push   %eax
80101905:	e8 39 ff ff ff       	call   80101843 <ioapicwrite>
8010190a:	83 c4 08             	add    $0x8,%esp
  ioapicwrite(REG_TABLE+2*irq+1, cpunum << 24);
8010190d:	8b 45 0c             	mov    0xc(%ebp),%eax
80101910:	c1 e0 18             	shl    $0x18,%eax
80101913:	89 c2                	mov    %eax,%edx
80101915:	8b 45 08             	mov    0x8(%ebp),%eax
80101918:	83 c0 08             	add    $0x8,%eax
8010191b:	01 c0                	add    %eax,%eax
8010191d:	83 c0 01             	add    $0x1,%eax
80101920:	52                   	push   %edx
80101921:	50                   	push   %eax
80101922:	e8 1c ff ff ff       	call   80101843 <ioapicwrite>
80101927:	83 c4 08             	add    $0x8,%esp
}
8010192a:	c9                   	leave  
8010192b:	c3                   	ret    

8010192c <vector0>:
# generated by vectors.pl - do not edit
# handlers
.globl alltraps
.globl vector0
vector0:
  pushl $0
8010192c:	6a 00                	push   $0x0
  pushl $0
8010192e:	6a 00                	push   $0x0
  jmp alltraps
80101930:	e9 a7 0e 00 00       	jmp    801027dc <alltraps>

80101935 <vector1>:
.globl vector1
vector1:
  pushl $0
80101935:	6a 00                	push   $0x0
  pushl $1
80101937:	6a 01                	push   $0x1
  jmp alltraps
80101939:	e9 9e 0e 00 00       	jmp    801027dc <alltraps>

8010193e <vector2>:
.globl vector2
vector2:
  pushl $0
8010193e:	6a 00                	push   $0x0
  pushl $2
80101940:	6a 02                	push   $0x2
  jmp alltraps
80101942:	e9 95 0e 00 00       	jmp    801027dc <alltraps>

80101947 <vector3>:
.globl vector3
vector3:
  pushl $0
80101947:	6a 00                	push   $0x0
  pushl $3
80101949:	6a 03                	push   $0x3
  jmp alltraps
8010194b:	e9 8c 0e 00 00       	jmp    801027dc <alltraps>

80101950 <vector4>:
.globl vector4
vector4:
  pushl $0
80101950:	6a 00                	push   $0x0
  pushl $4
80101952:	6a 04                	push   $0x4
  jmp alltraps
80101954:	e9 83 0e 00 00       	jmp    801027dc <alltraps>

80101959 <vector5>:
.globl vector5
vector5:
  pushl $0
80101959:	6a 00                	push   $0x0
  pushl $5
8010195b:	6a 05                	push   $0x5
  jmp alltraps
8010195d:	e9 7a 0e 00 00       	jmp    801027dc <alltraps>

80101962 <vector6>:
.globl vector6
vector6:
  pushl $0
80101962:	6a 00                	push   $0x0
  pushl $6
80101964:	6a 06                	push   $0x6
  jmp alltraps
80101966:	e9 71 0e 00 00       	jmp    801027dc <alltraps>

8010196b <vector7>:
.globl vector7
vector7:
  pushl $0
8010196b:	6a 00                	push   $0x0
  pushl $7
8010196d:	6a 07                	push   $0x7
  jmp alltraps
8010196f:	e9 68 0e 00 00       	jmp    801027dc <alltraps>

80101974 <vector8>:
.globl vector8
vector8:
  pushl $8
80101974:	6a 08                	push   $0x8
  jmp alltraps
80101976:	e9 61 0e 00 00       	jmp    801027dc <alltraps>

8010197b <vector9>:
.globl vector9
vector9:
  pushl $0
8010197b:	6a 00                	push   $0x0
  pushl $9
8010197d:	6a 09                	push   $0x9
  jmp alltraps
8010197f:	e9 58 0e 00 00       	jmp    801027dc <alltraps>

80101984 <vector10>:
.globl vector10
vector10:
  pushl $10
80101984:	6a 0a                	push   $0xa
  jmp alltraps
80101986:	e9 51 0e 00 00       	jmp    801027dc <alltraps>

8010198b <vector11>:
.globl vector11
vector11:
  pushl $11
8010198b:	6a 0b                	push   $0xb
  jmp alltraps
8010198d:	e9 4a 0e 00 00       	jmp    801027dc <alltraps>

80101992 <vector12>:
.globl vector12
vector12:
  pushl $12
80101992:	6a 0c                	push   $0xc
  jmp alltraps
80101994:	e9 43 0e 00 00       	jmp    801027dc <alltraps>

80101999 <vector13>:
.globl vector13
vector13:
  pushl $13
80101999:	6a 0d                	push   $0xd
  jmp alltraps
8010199b:	e9 3c 0e 00 00       	jmp    801027dc <alltraps>

801019a0 <vector14>:
.globl vector14
vector14:
  pushl $14
801019a0:	6a 0e                	push   $0xe
  jmp alltraps
801019a2:	e9 35 0e 00 00       	jmp    801027dc <alltraps>

801019a7 <vector15>:
.globl vector15
vector15:
  pushl $0
801019a7:	6a 00                	push   $0x0
  pushl $15
801019a9:	6a 0f                	push   $0xf
  jmp alltraps
801019ab:	e9 2c 0e 00 00       	jmp    801027dc <alltraps>

801019b0 <vector16>:
.globl vector16
vector16:
  pushl $0
801019b0:	6a 00                	push   $0x0
  pushl $16
801019b2:	6a 10                	push   $0x10
  jmp alltraps
801019b4:	e9 23 0e 00 00       	jmp    801027dc <alltraps>

801019b9 <vector17>:
.globl vector17
vector17:
  pushl $17
801019b9:	6a 11                	push   $0x11
  jmp alltraps
801019bb:	e9 1c 0e 00 00       	jmp    801027dc <alltraps>

801019c0 <vector18>:
.globl vector18
vector18:
  pushl $0
801019c0:	6a 00                	push   $0x0
  pushl $18
801019c2:	6a 12                	push   $0x12
  jmp alltraps
801019c4:	e9 13 0e 00 00       	jmp    801027dc <alltraps>

801019c9 <vector19>:
.globl vector19
vector19:
  pushl $0
801019c9:	6a 00                	push   $0x0
  pushl $19
801019cb:	6a 13                	push   $0x13
  jmp alltraps
801019cd:	e9 0a 0e 00 00       	jmp    801027dc <alltraps>

801019d2 <vector20>:
.globl vector20
vector20:
  pushl $0
801019d2:	6a 00                	push   $0x0
  pushl $20
801019d4:	6a 14                	push   $0x14
  jmp alltraps
801019d6:	e9 01 0e 00 00       	jmp    801027dc <alltraps>

801019db <vector21>:
.globl vector21
vector21:
  pushl $0
801019db:	6a 00                	push   $0x0
  pushl $21
801019dd:	6a 15                	push   $0x15
  jmp alltraps
801019df:	e9 f8 0d 00 00       	jmp    801027dc <alltraps>

801019e4 <vector22>:
.globl vector22
vector22:
  pushl $0
801019e4:	6a 00                	push   $0x0
  pushl $22
801019e6:	6a 16                	push   $0x16
  jmp alltraps
801019e8:	e9 ef 0d 00 00       	jmp    801027dc <alltraps>

801019ed <vector23>:
.globl vector23
vector23:
  pushl $0
801019ed:	6a 00                	push   $0x0
  pushl $23
801019ef:	6a 17                	push   $0x17
  jmp alltraps
801019f1:	e9 e6 0d 00 00       	jmp    801027dc <alltraps>

801019f6 <vector24>:
.globl vector24
vector24:
  pushl $0
801019f6:	6a 00                	push   $0x0
  pushl $24
801019f8:	6a 18                	push   $0x18
  jmp alltraps
801019fa:	e9 dd 0d 00 00       	jmp    801027dc <alltraps>

801019ff <vector25>:
.globl vector25
vector25:
  pushl $0
801019ff:	6a 00                	push   $0x0
  pushl $25
80101a01:	6a 19                	push   $0x19
  jmp alltraps
80101a03:	e9 d4 0d 00 00       	jmp    801027dc <alltraps>

80101a08 <vector26>:
.globl vector26
vector26:
  pushl $0
80101a08:	6a 00                	push   $0x0
  pushl $26
80101a0a:	6a 1a                	push   $0x1a
  jmp alltraps
80101a0c:	e9 cb 0d 00 00       	jmp    801027dc <alltraps>

80101a11 <vector27>:
.globl vector27
vector27:
  pushl $0
80101a11:	6a 00                	push   $0x0
  pushl $27
80101a13:	6a 1b                	push   $0x1b
  jmp alltraps
80101a15:	e9 c2 0d 00 00       	jmp    801027dc <alltraps>

80101a1a <vector28>:
.globl vector28
vector28:
  pushl $0
80101a1a:	6a 00                	push   $0x0
  pushl $28
80101a1c:	6a 1c                	push   $0x1c
  jmp alltraps
80101a1e:	e9 b9 0d 00 00       	jmp    801027dc <alltraps>

80101a23 <vector29>:
.globl vector29
vector29:
  pushl $0
80101a23:	6a 00                	push   $0x0
  pushl $29
80101a25:	6a 1d                	push   $0x1d
  jmp alltraps
80101a27:	e9 b0 0d 00 00       	jmp    801027dc <alltraps>

80101a2c <vector30>:
.globl vector30
vector30:
  pushl $0
80101a2c:	6a 00                	push   $0x0
  pushl $30
80101a2e:	6a 1e                	push   $0x1e
  jmp alltraps
80101a30:	e9 a7 0d 00 00       	jmp    801027dc <alltraps>

80101a35 <vector31>:
.globl vector31
vector31:
  pushl $0
80101a35:	6a 00                	push   $0x0
  pushl $31
80101a37:	6a 1f                	push   $0x1f
  jmp alltraps
80101a39:	e9 9e 0d 00 00       	jmp    801027dc <alltraps>

80101a3e <vector32>:
.globl vector32
vector32:
  pushl $0
80101a3e:	6a 00                	push   $0x0
  pushl $32
80101a40:	6a 20                	push   $0x20
  jmp alltraps
80101a42:	e9 95 0d 00 00       	jmp    801027dc <alltraps>

80101a47 <vector33>:
.globl vector33
vector33:
  pushl $0
80101a47:	6a 00                	push   $0x0
  pushl $33
80101a49:	6a 21                	push   $0x21
  jmp alltraps
80101a4b:	e9 8c 0d 00 00       	jmp    801027dc <alltraps>

80101a50 <vector34>:
.globl vector34
vector34:
  pushl $0
80101a50:	6a 00                	push   $0x0
  pushl $34
80101a52:	6a 22                	push   $0x22
  jmp alltraps
80101a54:	e9 83 0d 00 00       	jmp    801027dc <alltraps>

80101a59 <vector35>:
.globl vector35
vector35:
  pushl $0
80101a59:	6a 00                	push   $0x0
  pushl $35
80101a5b:	6a 23                	push   $0x23
  jmp alltraps
80101a5d:	e9 7a 0d 00 00       	jmp    801027dc <alltraps>

80101a62 <vector36>:
.globl vector36
vector36:
  pushl $0
80101a62:	6a 00                	push   $0x0
  pushl $36
80101a64:	6a 24                	push   $0x24
  jmp alltraps
80101a66:	e9 71 0d 00 00       	jmp    801027dc <alltraps>

80101a6b <vector37>:
.globl vector37
vector37:
  pushl $0
80101a6b:	6a 00                	push   $0x0
  pushl $37
80101a6d:	6a 25                	push   $0x25
  jmp alltraps
80101a6f:	e9 68 0d 00 00       	jmp    801027dc <alltraps>

80101a74 <vector38>:
.globl vector38
vector38:
  pushl $0
80101a74:	6a 00                	push   $0x0
  pushl $38
80101a76:	6a 26                	push   $0x26
  jmp alltraps
80101a78:	e9 5f 0d 00 00       	jmp    801027dc <alltraps>

80101a7d <vector39>:
.globl vector39
vector39:
  pushl $0
80101a7d:	6a 00                	push   $0x0
  pushl $39
80101a7f:	6a 27                	push   $0x27
  jmp alltraps
80101a81:	e9 56 0d 00 00       	jmp    801027dc <alltraps>

80101a86 <vector40>:
.globl vector40
vector40:
  pushl $0
80101a86:	6a 00                	push   $0x0
  pushl $40
80101a88:	6a 28                	push   $0x28
  jmp alltraps
80101a8a:	e9 4d 0d 00 00       	jmp    801027dc <alltraps>

80101a8f <vector41>:
.globl vector41
vector41:
  pushl $0
80101a8f:	6a 00                	push   $0x0
  pushl $41
80101a91:	6a 29                	push   $0x29
  jmp alltraps
80101a93:	e9 44 0d 00 00       	jmp    801027dc <alltraps>

80101a98 <vector42>:
.globl vector42
vector42:
  pushl $0
80101a98:	6a 00                	push   $0x0
  pushl $42
80101a9a:	6a 2a                	push   $0x2a
  jmp alltraps
80101a9c:	e9 3b 0d 00 00       	jmp    801027dc <alltraps>

80101aa1 <vector43>:
.globl vector43
vector43:
  pushl $0
80101aa1:	6a 00                	push   $0x0
  pushl $43
80101aa3:	6a 2b                	push   $0x2b
  jmp alltraps
80101aa5:	e9 32 0d 00 00       	jmp    801027dc <alltraps>

80101aaa <vector44>:
.globl vector44
vector44:
  pushl $0
80101aaa:	6a 00                	push   $0x0
  pushl $44
80101aac:	6a 2c                	push   $0x2c
  jmp alltraps
80101aae:	e9 29 0d 00 00       	jmp    801027dc <alltraps>

80101ab3 <vector45>:
.globl vector45
vector45:
  pushl $0
80101ab3:	6a 00                	push   $0x0
  pushl $45
80101ab5:	6a 2d                	push   $0x2d
  jmp alltraps
80101ab7:	e9 20 0d 00 00       	jmp    801027dc <alltraps>

80101abc <vector46>:
.globl vector46
vector46:
  pushl $0
80101abc:	6a 00                	push   $0x0
  pushl $46
80101abe:	6a 2e                	push   $0x2e
  jmp alltraps
80101ac0:	e9 17 0d 00 00       	jmp    801027dc <alltraps>

80101ac5 <vector47>:
.globl vector47
vector47:
  pushl $0
80101ac5:	6a 00                	push   $0x0
  pushl $47
80101ac7:	6a 2f                	push   $0x2f
  jmp alltraps
80101ac9:	e9 0e 0d 00 00       	jmp    801027dc <alltraps>

80101ace <vector48>:
.globl vector48
vector48:
  pushl $0
80101ace:	6a 00                	push   $0x0
  pushl $48
80101ad0:	6a 30                	push   $0x30
  jmp alltraps
80101ad2:	e9 05 0d 00 00       	jmp    801027dc <alltraps>

80101ad7 <vector49>:
.globl vector49
vector49:
  pushl $0
80101ad7:	6a 00                	push   $0x0
  pushl $49
80101ad9:	6a 31                	push   $0x31
  jmp alltraps
80101adb:	e9 fc 0c 00 00       	jmp    801027dc <alltraps>

80101ae0 <vector50>:
.globl vector50
vector50:
  pushl $0
80101ae0:	6a 00                	push   $0x0
  pushl $50
80101ae2:	6a 32                	push   $0x32
  jmp alltraps
80101ae4:	e9 f3 0c 00 00       	jmp    801027dc <alltraps>

80101ae9 <vector51>:
.globl vector51
vector51:
  pushl $0
80101ae9:	6a 00                	push   $0x0
  pushl $51
80101aeb:	6a 33                	push   $0x33
  jmp alltraps
80101aed:	e9 ea 0c 00 00       	jmp    801027dc <alltraps>

80101af2 <vector52>:
.globl vector52
vector52:
  pushl $0
80101af2:	6a 00                	push   $0x0
  pushl $52
80101af4:	6a 34                	push   $0x34
  jmp alltraps
80101af6:	e9 e1 0c 00 00       	jmp    801027dc <alltraps>

80101afb <vector53>:
.globl vector53
vector53:
  pushl $0
80101afb:	6a 00                	push   $0x0
  pushl $53
80101afd:	6a 35                	push   $0x35
  jmp alltraps
80101aff:	e9 d8 0c 00 00       	jmp    801027dc <alltraps>

80101b04 <vector54>:
.globl vector54
vector54:
  pushl $0
80101b04:	6a 00                	push   $0x0
  pushl $54
80101b06:	6a 36                	push   $0x36
  jmp alltraps
80101b08:	e9 cf 0c 00 00       	jmp    801027dc <alltraps>

80101b0d <vector55>:
.globl vector55
vector55:
  pushl $0
80101b0d:	6a 00                	push   $0x0
  pushl $55
80101b0f:	6a 37                	push   $0x37
  jmp alltraps
80101b11:	e9 c6 0c 00 00       	jmp    801027dc <alltraps>

80101b16 <vector56>:
.globl vector56
vector56:
  pushl $0
80101b16:	6a 00                	push   $0x0
  pushl $56
80101b18:	6a 38                	push   $0x38
  jmp alltraps
80101b1a:	e9 bd 0c 00 00       	jmp    801027dc <alltraps>

80101b1f <vector57>:
.globl vector57
vector57:
  pushl $0
80101b1f:	6a 00                	push   $0x0
  pushl $57
80101b21:	6a 39                	push   $0x39
  jmp alltraps
80101b23:	e9 b4 0c 00 00       	jmp    801027dc <alltraps>

80101b28 <vector58>:
.globl vector58
vector58:
  pushl $0
80101b28:	6a 00                	push   $0x0
  pushl $58
80101b2a:	6a 3a                	push   $0x3a
  jmp alltraps
80101b2c:	e9 ab 0c 00 00       	jmp    801027dc <alltraps>

80101b31 <vector59>:
.globl vector59
vector59:
  pushl $0
80101b31:	6a 00                	push   $0x0
  pushl $59
80101b33:	6a 3b                	push   $0x3b
  jmp alltraps
80101b35:	e9 a2 0c 00 00       	jmp    801027dc <alltraps>

80101b3a <vector60>:
.globl vector60
vector60:
  pushl $0
80101b3a:	6a 00                	push   $0x0
  pushl $60
80101b3c:	6a 3c                	push   $0x3c
  jmp alltraps
80101b3e:	e9 99 0c 00 00       	jmp    801027dc <alltraps>

80101b43 <vector61>:
.globl vector61
vector61:
  pushl $0
80101b43:	6a 00                	push   $0x0
  pushl $61
80101b45:	6a 3d                	push   $0x3d
  jmp alltraps
80101b47:	e9 90 0c 00 00       	jmp    801027dc <alltraps>

80101b4c <vector62>:
.globl vector62
vector62:
  pushl $0
80101b4c:	6a 00                	push   $0x0
  pushl $62
80101b4e:	6a 3e                	push   $0x3e
  jmp alltraps
80101b50:	e9 87 0c 00 00       	jmp    801027dc <alltraps>

80101b55 <vector63>:
.globl vector63
vector63:
  pushl $0
80101b55:	6a 00                	push   $0x0
  pushl $63
80101b57:	6a 3f                	push   $0x3f
  jmp alltraps
80101b59:	e9 7e 0c 00 00       	jmp    801027dc <alltraps>

80101b5e <vector64>:
.globl vector64
vector64:
  pushl $0
80101b5e:	6a 00                	push   $0x0
  pushl $64
80101b60:	6a 40                	push   $0x40
  jmp alltraps
80101b62:	e9 75 0c 00 00       	jmp    801027dc <alltraps>

80101b67 <vector65>:
.globl vector65
vector65:
  pushl $0
80101b67:	6a 00                	push   $0x0
  pushl $65
80101b69:	6a 41                	push   $0x41
  jmp alltraps
80101b6b:	e9 6c 0c 00 00       	jmp    801027dc <alltraps>

80101b70 <vector66>:
.globl vector66
vector66:
  pushl $0
80101b70:	6a 00                	push   $0x0
  pushl $66
80101b72:	6a 42                	push   $0x42
  jmp alltraps
80101b74:	e9 63 0c 00 00       	jmp    801027dc <alltraps>

80101b79 <vector67>:
.globl vector67
vector67:
  pushl $0
80101b79:	6a 00                	push   $0x0
  pushl $67
80101b7b:	6a 43                	push   $0x43
  jmp alltraps
80101b7d:	e9 5a 0c 00 00       	jmp    801027dc <alltraps>

80101b82 <vector68>:
.globl vector68
vector68:
  pushl $0
80101b82:	6a 00                	push   $0x0
  pushl $68
80101b84:	6a 44                	push   $0x44
  jmp alltraps
80101b86:	e9 51 0c 00 00       	jmp    801027dc <alltraps>

80101b8b <vector69>:
.globl vector69
vector69:
  pushl $0
80101b8b:	6a 00                	push   $0x0
  pushl $69
80101b8d:	6a 45                	push   $0x45
  jmp alltraps
80101b8f:	e9 48 0c 00 00       	jmp    801027dc <alltraps>

80101b94 <vector70>:
.globl vector70
vector70:
  pushl $0
80101b94:	6a 00                	push   $0x0
  pushl $70
80101b96:	6a 46                	push   $0x46
  jmp alltraps
80101b98:	e9 3f 0c 00 00       	jmp    801027dc <alltraps>

80101b9d <vector71>:
.globl vector71
vector71:
  pushl $0
80101b9d:	6a 00                	push   $0x0
  pushl $71
80101b9f:	6a 47                	push   $0x47
  jmp alltraps
80101ba1:	e9 36 0c 00 00       	jmp    801027dc <alltraps>

80101ba6 <vector72>:
.globl vector72
vector72:
  pushl $0
80101ba6:	6a 00                	push   $0x0
  pushl $72
80101ba8:	6a 48                	push   $0x48
  jmp alltraps
80101baa:	e9 2d 0c 00 00       	jmp    801027dc <alltraps>

80101baf <vector73>:
.globl vector73
vector73:
  pushl $0
80101baf:	6a 00                	push   $0x0
  pushl $73
80101bb1:	6a 49                	push   $0x49
  jmp alltraps
80101bb3:	e9 24 0c 00 00       	jmp    801027dc <alltraps>

80101bb8 <vector74>:
.globl vector74
vector74:
  pushl $0
80101bb8:	6a 00                	push   $0x0
  pushl $74
80101bba:	6a 4a                	push   $0x4a
  jmp alltraps
80101bbc:	e9 1b 0c 00 00       	jmp    801027dc <alltraps>

80101bc1 <vector75>:
.globl vector75
vector75:
  pushl $0
80101bc1:	6a 00                	push   $0x0
  pushl $75
80101bc3:	6a 4b                	push   $0x4b
  jmp alltraps
80101bc5:	e9 12 0c 00 00       	jmp    801027dc <alltraps>

80101bca <vector76>:
.globl vector76
vector76:
  pushl $0
80101bca:	6a 00                	push   $0x0
  pushl $76
80101bcc:	6a 4c                	push   $0x4c
  jmp alltraps
80101bce:	e9 09 0c 00 00       	jmp    801027dc <alltraps>

80101bd3 <vector77>:
.globl vector77
vector77:
  pushl $0
80101bd3:	6a 00                	push   $0x0
  pushl $77
80101bd5:	6a 4d                	push   $0x4d
  jmp alltraps
80101bd7:	e9 00 0c 00 00       	jmp    801027dc <alltraps>

80101bdc <vector78>:
.globl vector78
vector78:
  pushl $0
80101bdc:	6a 00                	push   $0x0
  pushl $78
80101bde:	6a 4e                	push   $0x4e
  jmp alltraps
80101be0:	e9 f7 0b 00 00       	jmp    801027dc <alltraps>

80101be5 <vector79>:
.globl vector79
vector79:
  pushl $0
80101be5:	6a 00                	push   $0x0
  pushl $79
80101be7:	6a 4f                	push   $0x4f
  jmp alltraps
80101be9:	e9 ee 0b 00 00       	jmp    801027dc <alltraps>

80101bee <vector80>:
.globl vector80
vector80:
  pushl $0
80101bee:	6a 00                	push   $0x0
  pushl $80
80101bf0:	6a 50                	push   $0x50
  jmp alltraps
80101bf2:	e9 e5 0b 00 00       	jmp    801027dc <alltraps>

80101bf7 <vector81>:
.globl vector81
vector81:
  pushl $0
80101bf7:	6a 00                	push   $0x0
  pushl $81
80101bf9:	6a 51                	push   $0x51
  jmp alltraps
80101bfb:	e9 dc 0b 00 00       	jmp    801027dc <alltraps>

80101c00 <vector82>:
.globl vector82
vector82:
  pushl $0
80101c00:	6a 00                	push   $0x0
  pushl $82
80101c02:	6a 52                	push   $0x52
  jmp alltraps
80101c04:	e9 d3 0b 00 00       	jmp    801027dc <alltraps>

80101c09 <vector83>:
.globl vector83
vector83:
  pushl $0
80101c09:	6a 00                	push   $0x0
  pushl $83
80101c0b:	6a 53                	push   $0x53
  jmp alltraps
80101c0d:	e9 ca 0b 00 00       	jmp    801027dc <alltraps>

80101c12 <vector84>:
.globl vector84
vector84:
  pushl $0
80101c12:	6a 00                	push   $0x0
  pushl $84
80101c14:	6a 54                	push   $0x54
  jmp alltraps
80101c16:	e9 c1 0b 00 00       	jmp    801027dc <alltraps>

80101c1b <vector85>:
.globl vector85
vector85:
  pushl $0
80101c1b:	6a 00                	push   $0x0
  pushl $85
80101c1d:	6a 55                	push   $0x55
  jmp alltraps
80101c1f:	e9 b8 0b 00 00       	jmp    801027dc <alltraps>

80101c24 <vector86>:
.globl vector86
vector86:
  pushl $0
80101c24:	6a 00                	push   $0x0
  pushl $86
80101c26:	6a 56                	push   $0x56
  jmp alltraps
80101c28:	e9 af 0b 00 00       	jmp    801027dc <alltraps>

80101c2d <vector87>:
.globl vector87
vector87:
  pushl $0
80101c2d:	6a 00                	push   $0x0
  pushl $87
80101c2f:	6a 57                	push   $0x57
  jmp alltraps
80101c31:	e9 a6 0b 00 00       	jmp    801027dc <alltraps>

80101c36 <vector88>:
.globl vector88
vector88:
  pushl $0
80101c36:	6a 00                	push   $0x0
  pushl $88
80101c38:	6a 58                	push   $0x58
  jmp alltraps
80101c3a:	e9 9d 0b 00 00       	jmp    801027dc <alltraps>

80101c3f <vector89>:
.globl vector89
vector89:
  pushl $0
80101c3f:	6a 00                	push   $0x0
  pushl $89
80101c41:	6a 59                	push   $0x59
  jmp alltraps
80101c43:	e9 94 0b 00 00       	jmp    801027dc <alltraps>

80101c48 <vector90>:
.globl vector90
vector90:
  pushl $0
80101c48:	6a 00                	push   $0x0
  pushl $90
80101c4a:	6a 5a                	push   $0x5a
  jmp alltraps
80101c4c:	e9 8b 0b 00 00       	jmp    801027dc <alltraps>

80101c51 <vector91>:
.globl vector91
vector91:
  pushl $0
80101c51:	6a 00                	push   $0x0
  pushl $91
80101c53:	6a 5b                	push   $0x5b
  jmp alltraps
80101c55:	e9 82 0b 00 00       	jmp    801027dc <alltraps>

80101c5a <vector92>:
.globl vector92
vector92:
  pushl $0
80101c5a:	6a 00                	push   $0x0
  pushl $92
80101c5c:	6a 5c                	push   $0x5c
  jmp alltraps
80101c5e:	e9 79 0b 00 00       	jmp    801027dc <alltraps>

80101c63 <vector93>:
.globl vector93
vector93:
  pushl $0
80101c63:	6a 00                	push   $0x0
  pushl $93
80101c65:	6a 5d                	push   $0x5d
  jmp alltraps
80101c67:	e9 70 0b 00 00       	jmp    801027dc <alltraps>

80101c6c <vector94>:
.globl vector94
vector94:
  pushl $0
80101c6c:	6a 00                	push   $0x0
  pushl $94
80101c6e:	6a 5e                	push   $0x5e
  jmp alltraps
80101c70:	e9 67 0b 00 00       	jmp    801027dc <alltraps>

80101c75 <vector95>:
.globl vector95
vector95:
  pushl $0
80101c75:	6a 00                	push   $0x0
  pushl $95
80101c77:	6a 5f                	push   $0x5f
  jmp alltraps
80101c79:	e9 5e 0b 00 00       	jmp    801027dc <alltraps>

80101c7e <vector96>:
.globl vector96
vector96:
  pushl $0
80101c7e:	6a 00                	push   $0x0
  pushl $96
80101c80:	6a 60                	push   $0x60
  jmp alltraps
80101c82:	e9 55 0b 00 00       	jmp    801027dc <alltraps>

80101c87 <vector97>:
.globl vector97
vector97:
  pushl $0
80101c87:	6a 00                	push   $0x0
  pushl $97
80101c89:	6a 61                	push   $0x61
  jmp alltraps
80101c8b:	e9 4c 0b 00 00       	jmp    801027dc <alltraps>

80101c90 <vector98>:
.globl vector98
vector98:
  pushl $0
80101c90:	6a 00                	push   $0x0
  pushl $98
80101c92:	6a 62                	push   $0x62
  jmp alltraps
80101c94:	e9 43 0b 00 00       	jmp    801027dc <alltraps>

80101c99 <vector99>:
.globl vector99
vector99:
  pushl $0
80101c99:	6a 00                	push   $0x0
  pushl $99
80101c9b:	6a 63                	push   $0x63
  jmp alltraps
80101c9d:	e9 3a 0b 00 00       	jmp    801027dc <alltraps>

80101ca2 <vector100>:
.globl vector100
vector100:
  pushl $0
80101ca2:	6a 00                	push   $0x0
  pushl $100
80101ca4:	6a 64                	push   $0x64
  jmp alltraps
80101ca6:	e9 31 0b 00 00       	jmp    801027dc <alltraps>

80101cab <vector101>:
.globl vector101
vector101:
  pushl $0
80101cab:	6a 00                	push   $0x0
  pushl $101
80101cad:	6a 65                	push   $0x65
  jmp alltraps
80101caf:	e9 28 0b 00 00       	jmp    801027dc <alltraps>

80101cb4 <vector102>:
.globl vector102
vector102:
  pushl $0
80101cb4:	6a 00                	push   $0x0
  pushl $102
80101cb6:	6a 66                	push   $0x66
  jmp alltraps
80101cb8:	e9 1f 0b 00 00       	jmp    801027dc <alltraps>

80101cbd <vector103>:
.globl vector103
vector103:
  pushl $0
80101cbd:	6a 00                	push   $0x0
  pushl $103
80101cbf:	6a 67                	push   $0x67
  jmp alltraps
80101cc1:	e9 16 0b 00 00       	jmp    801027dc <alltraps>

80101cc6 <vector104>:
.globl vector104
vector104:
  pushl $0
80101cc6:	6a 00                	push   $0x0
  pushl $104
80101cc8:	6a 68                	push   $0x68
  jmp alltraps
80101cca:	e9 0d 0b 00 00       	jmp    801027dc <alltraps>

80101ccf <vector105>:
.globl vector105
vector105:
  pushl $0
80101ccf:	6a 00                	push   $0x0
  pushl $105
80101cd1:	6a 69                	push   $0x69
  jmp alltraps
80101cd3:	e9 04 0b 00 00       	jmp    801027dc <alltraps>

80101cd8 <vector106>:
.globl vector106
vector106:
  pushl $0
80101cd8:	6a 00                	push   $0x0
  pushl $106
80101cda:	6a 6a                	push   $0x6a
  jmp alltraps
80101cdc:	e9 fb 0a 00 00       	jmp    801027dc <alltraps>

80101ce1 <vector107>:
.globl vector107
vector107:
  pushl $0
80101ce1:	6a 00                	push   $0x0
  pushl $107
80101ce3:	6a 6b                	push   $0x6b
  jmp alltraps
80101ce5:	e9 f2 0a 00 00       	jmp    801027dc <alltraps>

80101cea <vector108>:
.globl vector108
vector108:
  pushl $0
80101cea:	6a 00                	push   $0x0
  pushl $108
80101cec:	6a 6c                	push   $0x6c
  jmp alltraps
80101cee:	e9 e9 0a 00 00       	jmp    801027dc <alltraps>

80101cf3 <vector109>:
.globl vector109
vector109:
  pushl $0
80101cf3:	6a 00                	push   $0x0
  pushl $109
80101cf5:	6a 6d                	push   $0x6d
  jmp alltraps
80101cf7:	e9 e0 0a 00 00       	jmp    801027dc <alltraps>

80101cfc <vector110>:
.globl vector110
vector110:
  pushl $0
80101cfc:	6a 00                	push   $0x0
  pushl $110
80101cfe:	6a 6e                	push   $0x6e
  jmp alltraps
80101d00:	e9 d7 0a 00 00       	jmp    801027dc <alltraps>

80101d05 <vector111>:
.globl vector111
vector111:
  pushl $0
80101d05:	6a 00                	push   $0x0
  pushl $111
80101d07:	6a 6f                	push   $0x6f
  jmp alltraps
80101d09:	e9 ce 0a 00 00       	jmp    801027dc <alltraps>

80101d0e <vector112>:
.globl vector112
vector112:
  pushl $0
80101d0e:	6a 00                	push   $0x0
  pushl $112
80101d10:	6a 70                	push   $0x70
  jmp alltraps
80101d12:	e9 c5 0a 00 00       	jmp    801027dc <alltraps>

80101d17 <vector113>:
.globl vector113
vector113:
  pushl $0
80101d17:	6a 00                	push   $0x0
  pushl $113
80101d19:	6a 71                	push   $0x71
  jmp alltraps
80101d1b:	e9 bc 0a 00 00       	jmp    801027dc <alltraps>

80101d20 <vector114>:
.globl vector114
vector114:
  pushl $0
80101d20:	6a 00                	push   $0x0
  pushl $114
80101d22:	6a 72                	push   $0x72
  jmp alltraps
80101d24:	e9 b3 0a 00 00       	jmp    801027dc <alltraps>

80101d29 <vector115>:
.globl vector115
vector115:
  pushl $0
80101d29:	6a 00                	push   $0x0
  pushl $115
80101d2b:	6a 73                	push   $0x73
  jmp alltraps
80101d2d:	e9 aa 0a 00 00       	jmp    801027dc <alltraps>

80101d32 <vector116>:
.globl vector116
vector116:
  pushl $0
80101d32:	6a 00                	push   $0x0
  pushl $116
80101d34:	6a 74                	push   $0x74
  jmp alltraps
80101d36:	e9 a1 0a 00 00       	jmp    801027dc <alltraps>

80101d3b <vector117>:
.globl vector117
vector117:
  pushl $0
80101d3b:	6a 00                	push   $0x0
  pushl $117
80101d3d:	6a 75                	push   $0x75
  jmp alltraps
80101d3f:	e9 98 0a 00 00       	jmp    801027dc <alltraps>

80101d44 <vector118>:
.globl vector118
vector118:
  pushl $0
80101d44:	6a 00                	push   $0x0
  pushl $118
80101d46:	6a 76                	push   $0x76
  jmp alltraps
80101d48:	e9 8f 0a 00 00       	jmp    801027dc <alltraps>

80101d4d <vector119>:
.globl vector119
vector119:
  pushl $0
80101d4d:	6a 00                	push   $0x0
  pushl $119
80101d4f:	6a 77                	push   $0x77
  jmp alltraps
80101d51:	e9 86 0a 00 00       	jmp    801027dc <alltraps>

80101d56 <vector120>:
.globl vector120
vector120:
  pushl $0
80101d56:	6a 00                	push   $0x0
  pushl $120
80101d58:	6a 78                	push   $0x78
  jmp alltraps
80101d5a:	e9 7d 0a 00 00       	jmp    801027dc <alltraps>

80101d5f <vector121>:
.globl vector121
vector121:
  pushl $0
80101d5f:	6a 00                	push   $0x0
  pushl $121
80101d61:	6a 79                	push   $0x79
  jmp alltraps
80101d63:	e9 74 0a 00 00       	jmp    801027dc <alltraps>

80101d68 <vector122>:
.globl vector122
vector122:
  pushl $0
80101d68:	6a 00                	push   $0x0
  pushl $122
80101d6a:	6a 7a                	push   $0x7a
  jmp alltraps
80101d6c:	e9 6b 0a 00 00       	jmp    801027dc <alltraps>

80101d71 <vector123>:
.globl vector123
vector123:
  pushl $0
80101d71:	6a 00                	push   $0x0
  pushl $123
80101d73:	6a 7b                	push   $0x7b
  jmp alltraps
80101d75:	e9 62 0a 00 00       	jmp    801027dc <alltraps>

80101d7a <vector124>:
.globl vector124
vector124:
  pushl $0
80101d7a:	6a 00                	push   $0x0
  pushl $124
80101d7c:	6a 7c                	push   $0x7c
  jmp alltraps
80101d7e:	e9 59 0a 00 00       	jmp    801027dc <alltraps>

80101d83 <vector125>:
.globl vector125
vector125:
  pushl $0
80101d83:	6a 00                	push   $0x0
  pushl $125
80101d85:	6a 7d                	push   $0x7d
  jmp alltraps
80101d87:	e9 50 0a 00 00       	jmp    801027dc <alltraps>

80101d8c <vector126>:
.globl vector126
vector126:
  pushl $0
80101d8c:	6a 00                	push   $0x0
  pushl $126
80101d8e:	6a 7e                	push   $0x7e
  jmp alltraps
80101d90:	e9 47 0a 00 00       	jmp    801027dc <alltraps>

80101d95 <vector127>:
.globl vector127
vector127:
  pushl $0
80101d95:	6a 00                	push   $0x0
  pushl $127
80101d97:	6a 7f                	push   $0x7f
  jmp alltraps
80101d99:	e9 3e 0a 00 00       	jmp    801027dc <alltraps>

80101d9e <vector128>:
.globl vector128
vector128:
  pushl $0
80101d9e:	6a 00                	push   $0x0
  pushl $128
80101da0:	68 80 00 00 00       	push   $0x80
  jmp alltraps
80101da5:	e9 32 0a 00 00       	jmp    801027dc <alltraps>

80101daa <vector129>:
.globl vector129
vector129:
  pushl $0
80101daa:	6a 00                	push   $0x0
  pushl $129
80101dac:	68 81 00 00 00       	push   $0x81
  jmp alltraps
80101db1:	e9 26 0a 00 00       	jmp    801027dc <alltraps>

80101db6 <vector130>:
.globl vector130
vector130:
  pushl $0
80101db6:	6a 00                	push   $0x0
  pushl $130
80101db8:	68 82 00 00 00       	push   $0x82
  jmp alltraps
80101dbd:	e9 1a 0a 00 00       	jmp    801027dc <alltraps>

80101dc2 <vector131>:
.globl vector131
vector131:
  pushl $0
80101dc2:	6a 00                	push   $0x0
  pushl $131
80101dc4:	68 83 00 00 00       	push   $0x83
  jmp alltraps
80101dc9:	e9 0e 0a 00 00       	jmp    801027dc <alltraps>

80101dce <vector132>:
.globl vector132
vector132:
  pushl $0
80101dce:	6a 00                	push   $0x0
  pushl $132
80101dd0:	68 84 00 00 00       	push   $0x84
  jmp alltraps
80101dd5:	e9 02 0a 00 00       	jmp    801027dc <alltraps>

80101dda <vector133>:
.globl vector133
vector133:
  pushl $0
80101dda:	6a 00                	push   $0x0
  pushl $133
80101ddc:	68 85 00 00 00       	push   $0x85
  jmp alltraps
80101de1:	e9 f6 09 00 00       	jmp    801027dc <alltraps>

80101de6 <vector134>:
.globl vector134
vector134:
  pushl $0
80101de6:	6a 00                	push   $0x0
  pushl $134
80101de8:	68 86 00 00 00       	push   $0x86
  jmp alltraps
80101ded:	e9 ea 09 00 00       	jmp    801027dc <alltraps>

80101df2 <vector135>:
.globl vector135
vector135:
  pushl $0
80101df2:	6a 00                	push   $0x0
  pushl $135
80101df4:	68 87 00 00 00       	push   $0x87
  jmp alltraps
80101df9:	e9 de 09 00 00       	jmp    801027dc <alltraps>

80101dfe <vector136>:
.globl vector136
vector136:
  pushl $0
80101dfe:	6a 00                	push   $0x0
  pushl $136
80101e00:	68 88 00 00 00       	push   $0x88
  jmp alltraps
80101e05:	e9 d2 09 00 00       	jmp    801027dc <alltraps>

80101e0a <vector137>:
.globl vector137
vector137:
  pushl $0
80101e0a:	6a 00                	push   $0x0
  pushl $137
80101e0c:	68 89 00 00 00       	push   $0x89
  jmp alltraps
80101e11:	e9 c6 09 00 00       	jmp    801027dc <alltraps>

80101e16 <vector138>:
.globl vector138
vector138:
  pushl $0
80101e16:	6a 00                	push   $0x0
  pushl $138
80101e18:	68 8a 00 00 00       	push   $0x8a
  jmp alltraps
80101e1d:	e9 ba 09 00 00       	jmp    801027dc <alltraps>

80101e22 <vector139>:
.globl vector139
vector139:
  pushl $0
80101e22:	6a 00                	push   $0x0
  pushl $139
80101e24:	68 8b 00 00 00       	push   $0x8b
  jmp alltraps
80101e29:	e9 ae 09 00 00       	jmp    801027dc <alltraps>

80101e2e <vector140>:
.globl vector140
vector140:
  pushl $0
80101e2e:	6a 00                	push   $0x0
  pushl $140
80101e30:	68 8c 00 00 00       	push   $0x8c
  jmp alltraps
80101e35:	e9 a2 09 00 00       	jmp    801027dc <alltraps>

80101e3a <vector141>:
.globl vector141
vector141:
  pushl $0
80101e3a:	6a 00                	push   $0x0
  pushl $141
80101e3c:	68 8d 00 00 00       	push   $0x8d
  jmp alltraps
80101e41:	e9 96 09 00 00       	jmp    801027dc <alltraps>

80101e46 <vector142>:
.globl vector142
vector142:
  pushl $0
80101e46:	6a 00                	push   $0x0
  pushl $142
80101e48:	68 8e 00 00 00       	push   $0x8e
  jmp alltraps
80101e4d:	e9 8a 09 00 00       	jmp    801027dc <alltraps>

80101e52 <vector143>:
.globl vector143
vector143:
  pushl $0
80101e52:	6a 00                	push   $0x0
  pushl $143
80101e54:	68 8f 00 00 00       	push   $0x8f
  jmp alltraps
80101e59:	e9 7e 09 00 00       	jmp    801027dc <alltraps>

80101e5e <vector144>:
.globl vector144
vector144:
  pushl $0
80101e5e:	6a 00                	push   $0x0
  pushl $144
80101e60:	68 90 00 00 00       	push   $0x90
  jmp alltraps
80101e65:	e9 72 09 00 00       	jmp    801027dc <alltraps>

80101e6a <vector145>:
.globl vector145
vector145:
  pushl $0
80101e6a:	6a 00                	push   $0x0
  pushl $145
80101e6c:	68 91 00 00 00       	push   $0x91
  jmp alltraps
80101e71:	e9 66 09 00 00       	jmp    801027dc <alltraps>

80101e76 <vector146>:
.globl vector146
vector146:
  pushl $0
80101e76:	6a 00                	push   $0x0
  pushl $146
80101e78:	68 92 00 00 00       	push   $0x92
  jmp alltraps
80101e7d:	e9 5a 09 00 00       	jmp    801027dc <alltraps>

80101e82 <vector147>:
.globl vector147
vector147:
  pushl $0
80101e82:	6a 00                	push   $0x0
  pushl $147
80101e84:	68 93 00 00 00       	push   $0x93
  jmp alltraps
80101e89:	e9 4e 09 00 00       	jmp    801027dc <alltraps>

80101e8e <vector148>:
.globl vector148
vector148:
  pushl $0
80101e8e:	6a 00                	push   $0x0
  pushl $148
80101e90:	68 94 00 00 00       	push   $0x94
  jmp alltraps
80101e95:	e9 42 09 00 00       	jmp    801027dc <alltraps>

80101e9a <vector149>:
.globl vector149
vector149:
  pushl $0
80101e9a:	6a 00                	push   $0x0
  pushl $149
80101e9c:	68 95 00 00 00       	push   $0x95
  jmp alltraps
80101ea1:	e9 36 09 00 00       	jmp    801027dc <alltraps>

80101ea6 <vector150>:
.globl vector150
vector150:
  pushl $0
80101ea6:	6a 00                	push   $0x0
  pushl $150
80101ea8:	68 96 00 00 00       	push   $0x96
  jmp alltraps
80101ead:	e9 2a 09 00 00       	jmp    801027dc <alltraps>

80101eb2 <vector151>:
.globl vector151
vector151:
  pushl $0
80101eb2:	6a 00                	push   $0x0
  pushl $151
80101eb4:	68 97 00 00 00       	push   $0x97
  jmp alltraps
80101eb9:	e9 1e 09 00 00       	jmp    801027dc <alltraps>

80101ebe <vector152>:
.globl vector152
vector152:
  pushl $0
80101ebe:	6a 00                	push   $0x0
  pushl $152
80101ec0:	68 98 00 00 00       	push   $0x98
  jmp alltraps
80101ec5:	e9 12 09 00 00       	jmp    801027dc <alltraps>

80101eca <vector153>:
.globl vector153
vector153:
  pushl $0
80101eca:	6a 00                	push   $0x0
  pushl $153
80101ecc:	68 99 00 00 00       	push   $0x99
  jmp alltraps
80101ed1:	e9 06 09 00 00       	jmp    801027dc <alltraps>

80101ed6 <vector154>:
.globl vector154
vector154:
  pushl $0
80101ed6:	6a 00                	push   $0x0
  pushl $154
80101ed8:	68 9a 00 00 00       	push   $0x9a
  jmp alltraps
80101edd:	e9 fa 08 00 00       	jmp    801027dc <alltraps>

80101ee2 <vector155>:
.globl vector155
vector155:
  pushl $0
80101ee2:	6a 00                	push   $0x0
  pushl $155
80101ee4:	68 9b 00 00 00       	push   $0x9b
  jmp alltraps
80101ee9:	e9 ee 08 00 00       	jmp    801027dc <alltraps>

80101eee <vector156>:
.globl vector156
vector156:
  pushl $0
80101eee:	6a 00                	push   $0x0
  pushl $156
80101ef0:	68 9c 00 00 00       	push   $0x9c
  jmp alltraps
80101ef5:	e9 e2 08 00 00       	jmp    801027dc <alltraps>

80101efa <vector157>:
.globl vector157
vector157:
  pushl $0
80101efa:	6a 00                	push   $0x0
  pushl $157
80101efc:	68 9d 00 00 00       	push   $0x9d
  jmp alltraps
80101f01:	e9 d6 08 00 00       	jmp    801027dc <alltraps>

80101f06 <vector158>:
.globl vector158
vector158:
  pushl $0
80101f06:	6a 00                	push   $0x0
  pushl $158
80101f08:	68 9e 00 00 00       	push   $0x9e
  jmp alltraps
80101f0d:	e9 ca 08 00 00       	jmp    801027dc <alltraps>

80101f12 <vector159>:
.globl vector159
vector159:
  pushl $0
80101f12:	6a 00                	push   $0x0
  pushl $159
80101f14:	68 9f 00 00 00       	push   $0x9f
  jmp alltraps
80101f19:	e9 be 08 00 00       	jmp    801027dc <alltraps>

80101f1e <vector160>:
.globl vector160
vector160:
  pushl $0
80101f1e:	6a 00                	push   $0x0
  pushl $160
80101f20:	68 a0 00 00 00       	push   $0xa0
  jmp alltraps
80101f25:	e9 b2 08 00 00       	jmp    801027dc <alltraps>

80101f2a <vector161>:
.globl vector161
vector161:
  pushl $0
80101f2a:	6a 00                	push   $0x0
  pushl $161
80101f2c:	68 a1 00 00 00       	push   $0xa1
  jmp alltraps
80101f31:	e9 a6 08 00 00       	jmp    801027dc <alltraps>

80101f36 <vector162>:
.globl vector162
vector162:
  pushl $0
80101f36:	6a 00                	push   $0x0
  pushl $162
80101f38:	68 a2 00 00 00       	push   $0xa2
  jmp alltraps
80101f3d:	e9 9a 08 00 00       	jmp    801027dc <alltraps>

80101f42 <vector163>:
.globl vector163
vector163:
  pushl $0
80101f42:	6a 00                	push   $0x0
  pushl $163
80101f44:	68 a3 00 00 00       	push   $0xa3
  jmp alltraps
80101f49:	e9 8e 08 00 00       	jmp    801027dc <alltraps>

80101f4e <vector164>:
.globl vector164
vector164:
  pushl $0
80101f4e:	6a 00                	push   $0x0
  pushl $164
80101f50:	68 a4 00 00 00       	push   $0xa4
  jmp alltraps
80101f55:	e9 82 08 00 00       	jmp    801027dc <alltraps>

80101f5a <vector165>:
.globl vector165
vector165:
  pushl $0
80101f5a:	6a 00                	push   $0x0
  pushl $165
80101f5c:	68 a5 00 00 00       	push   $0xa5
  jmp alltraps
80101f61:	e9 76 08 00 00       	jmp    801027dc <alltraps>

80101f66 <vector166>:
.globl vector166
vector166:
  pushl $0
80101f66:	6a 00                	push   $0x0
  pushl $166
80101f68:	68 a6 00 00 00       	push   $0xa6
  jmp alltraps
80101f6d:	e9 6a 08 00 00       	jmp    801027dc <alltraps>

80101f72 <vector167>:
.globl vector167
vector167:
  pushl $0
80101f72:	6a 00                	push   $0x0
  pushl $167
80101f74:	68 a7 00 00 00       	push   $0xa7
  jmp alltraps
80101f79:	e9 5e 08 00 00       	jmp    801027dc <alltraps>

80101f7e <vector168>:
.globl vector168
vector168:
  pushl $0
80101f7e:	6a 00                	push   $0x0
  pushl $168
80101f80:	68 a8 00 00 00       	push   $0xa8
  jmp alltraps
80101f85:	e9 52 08 00 00       	jmp    801027dc <alltraps>

80101f8a <vector169>:
.globl vector169
vector169:
  pushl $0
80101f8a:	6a 00                	push   $0x0
  pushl $169
80101f8c:	68 a9 00 00 00       	push   $0xa9
  jmp alltraps
80101f91:	e9 46 08 00 00       	jmp    801027dc <alltraps>

80101f96 <vector170>:
.globl vector170
vector170:
  pushl $0
80101f96:	6a 00                	push   $0x0
  pushl $170
80101f98:	68 aa 00 00 00       	push   $0xaa
  jmp alltraps
80101f9d:	e9 3a 08 00 00       	jmp    801027dc <alltraps>

80101fa2 <vector171>:
.globl vector171
vector171:
  pushl $0
80101fa2:	6a 00                	push   $0x0
  pushl $171
80101fa4:	68 ab 00 00 00       	push   $0xab
  jmp alltraps
80101fa9:	e9 2e 08 00 00       	jmp    801027dc <alltraps>

80101fae <vector172>:
.globl vector172
vector172:
  pushl $0
80101fae:	6a 00                	push   $0x0
  pushl $172
80101fb0:	68 ac 00 00 00       	push   $0xac
  jmp alltraps
80101fb5:	e9 22 08 00 00       	jmp    801027dc <alltraps>

80101fba <vector173>:
.globl vector173
vector173:
  pushl $0
80101fba:	6a 00                	push   $0x0
  pushl $173
80101fbc:	68 ad 00 00 00       	push   $0xad
  jmp alltraps
80101fc1:	e9 16 08 00 00       	jmp    801027dc <alltraps>

80101fc6 <vector174>:
.globl vector174
vector174:
  pushl $0
80101fc6:	6a 00                	push   $0x0
  pushl $174
80101fc8:	68 ae 00 00 00       	push   $0xae
  jmp alltraps
80101fcd:	e9 0a 08 00 00       	jmp    801027dc <alltraps>

80101fd2 <vector175>:
.globl vector175
vector175:
  pushl $0
80101fd2:	6a 00                	push   $0x0
  pushl $175
80101fd4:	68 af 00 00 00       	push   $0xaf
  jmp alltraps
80101fd9:	e9 fe 07 00 00       	jmp    801027dc <alltraps>

80101fde <vector176>:
.globl vector176
vector176:
  pushl $0
80101fde:	6a 00                	push   $0x0
  pushl $176
80101fe0:	68 b0 00 00 00       	push   $0xb0
  jmp alltraps
80101fe5:	e9 f2 07 00 00       	jmp    801027dc <alltraps>

80101fea <vector177>:
.globl vector177
vector177:
  pushl $0
80101fea:	6a 00                	push   $0x0
  pushl $177
80101fec:	68 b1 00 00 00       	push   $0xb1
  jmp alltraps
80101ff1:	e9 e6 07 00 00       	jmp    801027dc <alltraps>

80101ff6 <vector178>:
.globl vector178
vector178:
  pushl $0
80101ff6:	6a 00                	push   $0x0
  pushl $178
80101ff8:	68 b2 00 00 00       	push   $0xb2
  jmp alltraps
80101ffd:	e9 da 07 00 00       	jmp    801027dc <alltraps>

80102002 <vector179>:
.globl vector179
vector179:
  pushl $0
80102002:	6a 00                	push   $0x0
  pushl $179
80102004:	68 b3 00 00 00       	push   $0xb3
  jmp alltraps
80102009:	e9 ce 07 00 00       	jmp    801027dc <alltraps>

8010200e <vector180>:
.globl vector180
vector180:
  pushl $0
8010200e:	6a 00                	push   $0x0
  pushl $180
80102010:	68 b4 00 00 00       	push   $0xb4
  jmp alltraps
80102015:	e9 c2 07 00 00       	jmp    801027dc <alltraps>

8010201a <vector181>:
.globl vector181
vector181:
  pushl $0
8010201a:	6a 00                	push   $0x0
  pushl $181
8010201c:	68 b5 00 00 00       	push   $0xb5
  jmp alltraps
80102021:	e9 b6 07 00 00       	jmp    801027dc <alltraps>

80102026 <vector182>:
.globl vector182
vector182:
  pushl $0
80102026:	6a 00                	push   $0x0
  pushl $182
80102028:	68 b6 00 00 00       	push   $0xb6
  jmp alltraps
8010202d:	e9 aa 07 00 00       	jmp    801027dc <alltraps>

80102032 <vector183>:
.globl vector183
vector183:
  pushl $0
80102032:	6a 00                	push   $0x0
  pushl $183
80102034:	68 b7 00 00 00       	push   $0xb7
  jmp alltraps
80102039:	e9 9e 07 00 00       	jmp    801027dc <alltraps>

8010203e <vector184>:
.globl vector184
vector184:
  pushl $0
8010203e:	6a 00                	push   $0x0
  pushl $184
80102040:	68 b8 00 00 00       	push   $0xb8
  jmp alltraps
80102045:	e9 92 07 00 00       	jmp    801027dc <alltraps>

8010204a <vector185>:
.globl vector185
vector185:
  pushl $0
8010204a:	6a 00                	push   $0x0
  pushl $185
8010204c:	68 b9 00 00 00       	push   $0xb9
  jmp alltraps
80102051:	e9 86 07 00 00       	jmp    801027dc <alltraps>

80102056 <vector186>:
.globl vector186
vector186:
  pushl $0
80102056:	6a 00                	push   $0x0
  pushl $186
80102058:	68 ba 00 00 00       	push   $0xba
  jmp alltraps
8010205d:	e9 7a 07 00 00       	jmp    801027dc <alltraps>

80102062 <vector187>:
.globl vector187
vector187:
  pushl $0
80102062:	6a 00                	push   $0x0
  pushl $187
80102064:	68 bb 00 00 00       	push   $0xbb
  jmp alltraps
80102069:	e9 6e 07 00 00       	jmp    801027dc <alltraps>

8010206e <vector188>:
.globl vector188
vector188:
  pushl $0
8010206e:	6a 00                	push   $0x0
  pushl $188
80102070:	68 bc 00 00 00       	push   $0xbc
  jmp alltraps
80102075:	e9 62 07 00 00       	jmp    801027dc <alltraps>

8010207a <vector189>:
.globl vector189
vector189:
  pushl $0
8010207a:	6a 00                	push   $0x0
  pushl $189
8010207c:	68 bd 00 00 00       	push   $0xbd
  jmp alltraps
80102081:	e9 56 07 00 00       	jmp    801027dc <alltraps>

80102086 <vector190>:
.globl vector190
vector190:
  pushl $0
80102086:	6a 00                	push   $0x0
  pushl $190
80102088:	68 be 00 00 00       	push   $0xbe
  jmp alltraps
8010208d:	e9 4a 07 00 00       	jmp    801027dc <alltraps>

80102092 <vector191>:
.globl vector191
vector191:
  pushl $0
80102092:	6a 00                	push   $0x0
  pushl $191
80102094:	68 bf 00 00 00       	push   $0xbf
  jmp alltraps
80102099:	e9 3e 07 00 00       	jmp    801027dc <alltraps>

8010209e <vector192>:
.globl vector192
vector192:
  pushl $0
8010209e:	6a 00                	push   $0x0
  pushl $192
801020a0:	68 c0 00 00 00       	push   $0xc0
  jmp alltraps
801020a5:	e9 32 07 00 00       	jmp    801027dc <alltraps>

801020aa <vector193>:
.globl vector193
vector193:
  pushl $0
801020aa:	6a 00                	push   $0x0
  pushl $193
801020ac:	68 c1 00 00 00       	push   $0xc1
  jmp alltraps
801020b1:	e9 26 07 00 00       	jmp    801027dc <alltraps>

801020b6 <vector194>:
.globl vector194
vector194:
  pushl $0
801020b6:	6a 00                	push   $0x0
  pushl $194
801020b8:	68 c2 00 00 00       	push   $0xc2
  jmp alltraps
801020bd:	e9 1a 07 00 00       	jmp    801027dc <alltraps>

801020c2 <vector195>:
.globl vector195
vector195:
  pushl $0
801020c2:	6a 00                	push   $0x0
  pushl $195
801020c4:	68 c3 00 00 00       	push   $0xc3
  jmp alltraps
801020c9:	e9 0e 07 00 00       	jmp    801027dc <alltraps>

801020ce <vector196>:
.globl vector196
vector196:
  pushl $0
801020ce:	6a 00                	push   $0x0
  pushl $196
801020d0:	68 c4 00 00 00       	push   $0xc4
  jmp alltraps
801020d5:	e9 02 07 00 00       	jmp    801027dc <alltraps>

801020da <vector197>:
.globl vector197
vector197:
  pushl $0
801020da:	6a 00                	push   $0x0
  pushl $197
801020dc:	68 c5 00 00 00       	push   $0xc5
  jmp alltraps
801020e1:	e9 f6 06 00 00       	jmp    801027dc <alltraps>

801020e6 <vector198>:
.globl vector198
vector198:
  pushl $0
801020e6:	6a 00                	push   $0x0
  pushl $198
801020e8:	68 c6 00 00 00       	push   $0xc6
  jmp alltraps
801020ed:	e9 ea 06 00 00       	jmp    801027dc <alltraps>

801020f2 <vector199>:
.globl vector199
vector199:
  pushl $0
801020f2:	6a 00                	push   $0x0
  pushl $199
801020f4:	68 c7 00 00 00       	push   $0xc7
  jmp alltraps
801020f9:	e9 de 06 00 00       	jmp    801027dc <alltraps>

801020fe <vector200>:
.globl vector200
vector200:
  pushl $0
801020fe:	6a 00                	push   $0x0
  pushl $200
80102100:	68 c8 00 00 00       	push   $0xc8
  jmp alltraps
80102105:	e9 d2 06 00 00       	jmp    801027dc <alltraps>

8010210a <vector201>:
.globl vector201
vector201:
  pushl $0
8010210a:	6a 00                	push   $0x0
  pushl $201
8010210c:	68 c9 00 00 00       	push   $0xc9
  jmp alltraps
80102111:	e9 c6 06 00 00       	jmp    801027dc <alltraps>

80102116 <vector202>:
.globl vector202
vector202:
  pushl $0
80102116:	6a 00                	push   $0x0
  pushl $202
80102118:	68 ca 00 00 00       	push   $0xca
  jmp alltraps
8010211d:	e9 ba 06 00 00       	jmp    801027dc <alltraps>

80102122 <vector203>:
.globl vector203
vector203:
  pushl $0
80102122:	6a 00                	push   $0x0
  pushl $203
80102124:	68 cb 00 00 00       	push   $0xcb
  jmp alltraps
80102129:	e9 ae 06 00 00       	jmp    801027dc <alltraps>

8010212e <vector204>:
.globl vector204
vector204:
  pushl $0
8010212e:	6a 00                	push   $0x0
  pushl $204
80102130:	68 cc 00 00 00       	push   $0xcc
  jmp alltraps
80102135:	e9 a2 06 00 00       	jmp    801027dc <alltraps>

8010213a <vector205>:
.globl vector205
vector205:
  pushl $0
8010213a:	6a 00                	push   $0x0
  pushl $205
8010213c:	68 cd 00 00 00       	push   $0xcd
  jmp alltraps
80102141:	e9 96 06 00 00       	jmp    801027dc <alltraps>

80102146 <vector206>:
.globl vector206
vector206:
  pushl $0
80102146:	6a 00                	push   $0x0
  pushl $206
80102148:	68 ce 00 00 00       	push   $0xce
  jmp alltraps
8010214d:	e9 8a 06 00 00       	jmp    801027dc <alltraps>

80102152 <vector207>:
.globl vector207
vector207:
  pushl $0
80102152:	6a 00                	push   $0x0
  pushl $207
80102154:	68 cf 00 00 00       	push   $0xcf
  jmp alltraps
80102159:	e9 7e 06 00 00       	jmp    801027dc <alltraps>

8010215e <vector208>:
.globl vector208
vector208:
  pushl $0
8010215e:	6a 00                	push   $0x0
  pushl $208
80102160:	68 d0 00 00 00       	push   $0xd0
  jmp alltraps
80102165:	e9 72 06 00 00       	jmp    801027dc <alltraps>

8010216a <vector209>:
.globl vector209
vector209:
  pushl $0
8010216a:	6a 00                	push   $0x0
  pushl $209
8010216c:	68 d1 00 00 00       	push   $0xd1
  jmp alltraps
80102171:	e9 66 06 00 00       	jmp    801027dc <alltraps>

80102176 <vector210>:
.globl vector210
vector210:
  pushl $0
80102176:	6a 00                	push   $0x0
  pushl $210
80102178:	68 d2 00 00 00       	push   $0xd2
  jmp alltraps
8010217d:	e9 5a 06 00 00       	jmp    801027dc <alltraps>

80102182 <vector211>:
.globl vector211
vector211:
  pushl $0
80102182:	6a 00                	push   $0x0
  pushl $211
80102184:	68 d3 00 00 00       	push   $0xd3
  jmp alltraps
80102189:	e9 4e 06 00 00       	jmp    801027dc <alltraps>

8010218e <vector212>:
.globl vector212
vector212:
  pushl $0
8010218e:	6a 00                	push   $0x0
  pushl $212
80102190:	68 d4 00 00 00       	push   $0xd4
  jmp alltraps
80102195:	e9 42 06 00 00       	jmp    801027dc <alltraps>

8010219a <vector213>:
.globl vector213
vector213:
  pushl $0
8010219a:	6a 00                	push   $0x0
  pushl $213
8010219c:	68 d5 00 00 00       	push   $0xd5
  jmp alltraps
801021a1:	e9 36 06 00 00       	jmp    801027dc <alltraps>

801021a6 <vector214>:
.globl vector214
vector214:
  pushl $0
801021a6:	6a 00                	push   $0x0
  pushl $214
801021a8:	68 d6 00 00 00       	push   $0xd6
  jmp alltraps
801021ad:	e9 2a 06 00 00       	jmp    801027dc <alltraps>

801021b2 <vector215>:
.globl vector215
vector215:
  pushl $0
801021b2:	6a 00                	push   $0x0
  pushl $215
801021b4:	68 d7 00 00 00       	push   $0xd7
  jmp alltraps
801021b9:	e9 1e 06 00 00       	jmp    801027dc <alltraps>

801021be <vector216>:
.globl vector216
vector216:
  pushl $0
801021be:	6a 00                	push   $0x0
  pushl $216
801021c0:	68 d8 00 00 00       	push   $0xd8
  jmp alltraps
801021c5:	e9 12 06 00 00       	jmp    801027dc <alltraps>

801021ca <vector217>:
.globl vector217
vector217:
  pushl $0
801021ca:	6a 00                	push   $0x0
  pushl $217
801021cc:	68 d9 00 00 00       	push   $0xd9
  jmp alltraps
801021d1:	e9 06 06 00 00       	jmp    801027dc <alltraps>

801021d6 <vector218>:
.globl vector218
vector218:
  pushl $0
801021d6:	6a 00                	push   $0x0
  pushl $218
801021d8:	68 da 00 00 00       	push   $0xda
  jmp alltraps
801021dd:	e9 fa 05 00 00       	jmp    801027dc <alltraps>

801021e2 <vector219>:
.globl vector219
vector219:
  pushl $0
801021e2:	6a 00                	push   $0x0
  pushl $219
801021e4:	68 db 00 00 00       	push   $0xdb
  jmp alltraps
801021e9:	e9 ee 05 00 00       	jmp    801027dc <alltraps>

801021ee <vector220>:
.globl vector220
vector220:
  pushl $0
801021ee:	6a 00                	push   $0x0
  pushl $220
801021f0:	68 dc 00 00 00       	push   $0xdc
  jmp alltraps
801021f5:	e9 e2 05 00 00       	jmp    801027dc <alltraps>

801021fa <vector221>:
.globl vector221
vector221:
  pushl $0
801021fa:	6a 00                	push   $0x0
  pushl $221
801021fc:	68 dd 00 00 00       	push   $0xdd
  jmp alltraps
80102201:	e9 d6 05 00 00       	jmp    801027dc <alltraps>

80102206 <vector222>:
.globl vector222
vector222:
  pushl $0
80102206:	6a 00                	push   $0x0
  pushl $222
80102208:	68 de 00 00 00       	push   $0xde
  jmp alltraps
8010220d:	e9 ca 05 00 00       	jmp    801027dc <alltraps>

80102212 <vector223>:
.globl vector223
vector223:
  pushl $0
80102212:	6a 00                	push   $0x0
  pushl $223
80102214:	68 df 00 00 00       	push   $0xdf
  jmp alltraps
80102219:	e9 be 05 00 00       	jmp    801027dc <alltraps>

8010221e <vector224>:
.globl vector224
vector224:
  pushl $0
8010221e:	6a 00                	push   $0x0
  pushl $224
80102220:	68 e0 00 00 00       	push   $0xe0
  jmp alltraps
80102225:	e9 b2 05 00 00       	jmp    801027dc <alltraps>

8010222a <vector225>:
.globl vector225
vector225:
  pushl $0
8010222a:	6a 00                	push   $0x0
  pushl $225
8010222c:	68 e1 00 00 00       	push   $0xe1
  jmp alltraps
80102231:	e9 a6 05 00 00       	jmp    801027dc <alltraps>

80102236 <vector226>:
.globl vector226
vector226:
  pushl $0
80102236:	6a 00                	push   $0x0
  pushl $226
80102238:	68 e2 00 00 00       	push   $0xe2
  jmp alltraps
8010223d:	e9 9a 05 00 00       	jmp    801027dc <alltraps>

80102242 <vector227>:
.globl vector227
vector227:
  pushl $0
80102242:	6a 00                	push   $0x0
  pushl $227
80102244:	68 e3 00 00 00       	push   $0xe3
  jmp alltraps
80102249:	e9 8e 05 00 00       	jmp    801027dc <alltraps>

8010224e <vector228>:
.globl vector228
vector228:
  pushl $0
8010224e:	6a 00                	push   $0x0
  pushl $228
80102250:	68 e4 00 00 00       	push   $0xe4
  jmp alltraps
80102255:	e9 82 05 00 00       	jmp    801027dc <alltraps>

8010225a <vector229>:
.globl vector229
vector229:
  pushl $0
8010225a:	6a 00                	push   $0x0
  pushl $229
8010225c:	68 e5 00 00 00       	push   $0xe5
  jmp alltraps
80102261:	e9 76 05 00 00       	jmp    801027dc <alltraps>

80102266 <vector230>:
.globl vector230
vector230:
  pushl $0
80102266:	6a 00                	push   $0x0
  pushl $230
80102268:	68 e6 00 00 00       	push   $0xe6
  jmp alltraps
8010226d:	e9 6a 05 00 00       	jmp    801027dc <alltraps>

80102272 <vector231>:
.globl vector231
vector231:
  pushl $0
80102272:	6a 00                	push   $0x0
  pushl $231
80102274:	68 e7 00 00 00       	push   $0xe7
  jmp alltraps
80102279:	e9 5e 05 00 00       	jmp    801027dc <alltraps>

8010227e <vector232>:
.globl vector232
vector232:
  pushl $0
8010227e:	6a 00                	push   $0x0
  pushl $232
80102280:	68 e8 00 00 00       	push   $0xe8
  jmp alltraps
80102285:	e9 52 05 00 00       	jmp    801027dc <alltraps>

8010228a <vector233>:
.globl vector233
vector233:
  pushl $0
8010228a:	6a 00                	push   $0x0
  pushl $233
8010228c:	68 e9 00 00 00       	push   $0xe9
  jmp alltraps
80102291:	e9 46 05 00 00       	jmp    801027dc <alltraps>

80102296 <vector234>:
.globl vector234
vector234:
  pushl $0
80102296:	6a 00                	push   $0x0
  pushl $234
80102298:	68 ea 00 00 00       	push   $0xea
  jmp alltraps
8010229d:	e9 3a 05 00 00       	jmp    801027dc <alltraps>

801022a2 <vector235>:
.globl vector235
vector235:
  pushl $0
801022a2:	6a 00                	push   $0x0
  pushl $235
801022a4:	68 eb 00 00 00       	push   $0xeb
  jmp alltraps
801022a9:	e9 2e 05 00 00       	jmp    801027dc <alltraps>

801022ae <vector236>:
.globl vector236
vector236:
  pushl $0
801022ae:	6a 00                	push   $0x0
  pushl $236
801022b0:	68 ec 00 00 00       	push   $0xec
  jmp alltraps
801022b5:	e9 22 05 00 00       	jmp    801027dc <alltraps>

801022ba <vector237>:
.globl vector237
vector237:
  pushl $0
801022ba:	6a 00                	push   $0x0
  pushl $237
801022bc:	68 ed 00 00 00       	push   $0xed
  jmp alltraps
801022c1:	e9 16 05 00 00       	jmp    801027dc <alltraps>

801022c6 <vector238>:
.globl vector238
vector238:
  pushl $0
801022c6:	6a 00                	push   $0x0
  pushl $238
801022c8:	68 ee 00 00 00       	push   $0xee
  jmp alltraps
801022cd:	e9 0a 05 00 00       	jmp    801027dc <alltraps>

801022d2 <vector239>:
.globl vector239
vector239:
  pushl $0
801022d2:	6a 00                	push   $0x0
  pushl $239
801022d4:	68 ef 00 00 00       	push   $0xef
  jmp alltraps
801022d9:	e9 fe 04 00 00       	jmp    801027dc <alltraps>

801022de <vector240>:
.globl vector240
vector240:
  pushl $0
801022de:	6a 00                	push   $0x0
  pushl $240
801022e0:	68 f0 00 00 00       	push   $0xf0
  jmp alltraps
801022e5:	e9 f2 04 00 00       	jmp    801027dc <alltraps>

801022ea <vector241>:
.globl vector241
vector241:
  pushl $0
801022ea:	6a 00                	push   $0x0
  pushl $241
801022ec:	68 f1 00 00 00       	push   $0xf1
  jmp alltraps
801022f1:	e9 e6 04 00 00       	jmp    801027dc <alltraps>

801022f6 <vector242>:
.globl vector242
vector242:
  pushl $0
801022f6:	6a 00                	push   $0x0
  pushl $242
801022f8:	68 f2 00 00 00       	push   $0xf2
  jmp alltraps
801022fd:	e9 da 04 00 00       	jmp    801027dc <alltraps>

80102302 <vector243>:
.globl vector243
vector243:
  pushl $0
80102302:	6a 00                	push   $0x0
  pushl $243
80102304:	68 f3 00 00 00       	push   $0xf3
  jmp alltraps
80102309:	e9 ce 04 00 00       	jmp    801027dc <alltraps>

8010230e <vector244>:
.globl vector244
vector244:
  pushl $0
8010230e:	6a 00                	push   $0x0
  pushl $244
80102310:	68 f4 00 00 00       	push   $0xf4
  jmp alltraps
80102315:	e9 c2 04 00 00       	jmp    801027dc <alltraps>

8010231a <vector245>:
.globl vector245
vector245:
  pushl $0
8010231a:	6a 00                	push   $0x0
  pushl $245
8010231c:	68 f5 00 00 00       	push   $0xf5
  jmp alltraps
80102321:	e9 b6 04 00 00       	jmp    801027dc <alltraps>

80102326 <vector246>:
.globl vector246
vector246:
  pushl $0
80102326:	6a 00                	push   $0x0
  pushl $246
80102328:	68 f6 00 00 00       	push   $0xf6
  jmp alltraps
8010232d:	e9 aa 04 00 00       	jmp    801027dc <alltraps>

80102332 <vector247>:
.globl vector247
vector247:
  pushl $0
80102332:	6a 00                	push   $0x0
  pushl $247
80102334:	68 f7 00 00 00       	push   $0xf7
  jmp alltraps
80102339:	e9 9e 04 00 00       	jmp    801027dc <alltraps>

8010233e <vector248>:
.globl vector248
vector248:
  pushl $0
8010233e:	6a 00                	push   $0x0
  pushl $248
80102340:	68 f8 00 00 00       	push   $0xf8
  jmp alltraps
80102345:	e9 92 04 00 00       	jmp    801027dc <alltraps>

8010234a <vector249>:
.globl vector249
vector249:
  pushl $0
8010234a:	6a 00                	push   $0x0
  pushl $249
8010234c:	68 f9 00 00 00       	push   $0xf9
  jmp alltraps
80102351:	e9 86 04 00 00       	jmp    801027dc <alltraps>

80102356 <vector250>:
.globl vector250
vector250:
  pushl $0
80102356:	6a 00                	push   $0x0
  pushl $250
80102358:	68 fa 00 00 00       	push   $0xfa
  jmp alltraps
8010235d:	e9 7a 04 00 00       	jmp    801027dc <alltraps>

80102362 <vector251>:
.globl vector251
vector251:
  pushl $0
80102362:	6a 00                	push   $0x0
  pushl $251
80102364:	68 fb 00 00 00       	push   $0xfb
  jmp alltraps
80102369:	e9 6e 04 00 00       	jmp    801027dc <alltraps>

8010236e <vector252>:
.globl vector252
vector252:
  pushl $0
8010236e:	6a 00                	push   $0x0
  pushl $252
80102370:	68 fc 00 00 00       	push   $0xfc
  jmp alltraps
80102375:	e9 62 04 00 00       	jmp    801027dc <alltraps>

8010237a <vector253>:
.globl vector253
vector253:
  pushl $0
8010237a:	6a 00                	push   $0x0
  pushl $253
8010237c:	68 fd 00 00 00       	push   $0xfd
  jmp alltraps
80102381:	e9 56 04 00 00       	jmp    801027dc <alltraps>

80102386 <vector254>:
.globl vector254
vector254:
  pushl $0
80102386:	6a 00                	push   $0x0
  pushl $254
80102388:	68 fe 00 00 00       	push   $0xfe
  jmp alltraps
8010238d:	e9 4a 04 00 00       	jmp    801027dc <alltraps>

80102392 <vector255>:
.globl vector255
vector255:
  pushl $0
80102392:	6a 00                	push   $0x0
  pushl $255
80102394:	68 ff 00 00 00       	push   $0xff
  jmp alltraps
80102399:	e9 3e 04 00 00       	jmp    801027dc <alltraps>

8010239e <fetchint>:


// 获取进程p在地址addr处的整数
int
fetchint(uint addr, int *ip)
{
8010239e:	55                   	push   %ebp
8010239f:	89 e5                	mov    %esp,%ebp
  if(addr >= proc->sz || addr+4 > proc->sz)
801023a1:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801023a7:	8b 00                	mov    (%eax),%eax
801023a9:	3b 45 08             	cmp    0x8(%ebp),%eax
801023ac:	76 12                	jbe    801023c0 <fetchint+0x22>
801023ae:	8b 45 08             	mov    0x8(%ebp),%eax
801023b1:	8d 50 04             	lea    0x4(%eax),%edx
801023b4:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801023ba:	8b 00                	mov    (%eax),%eax
801023bc:	39 c2                	cmp    %eax,%edx
801023be:	76 07                	jbe    801023c7 <fetchint+0x29>
    return -1;
801023c0:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801023c5:	eb 0f                	jmp    801023d6 <fetchint+0x38>
  *ip = *(int*)(addr);
801023c7:	8b 45 08             	mov    0x8(%ebp),%eax
801023ca:	8b 10                	mov    (%eax),%edx
801023cc:	8b 45 0c             	mov    0xc(%ebp),%eax
801023cf:	89 10                	mov    %edx,(%eax)
//  cprintf("The ip is %d\n",*ip);
  return 0;
801023d1:	b8 00 00 00 00       	mov    $0x0,%eax
}
801023d6:	5d                   	pop    %ebp
801023d7:	c3                   	ret    

801023d8 <fetchstr>:
//从进程p中取出addr地址处的空终止字符串
//实际上不是复制这个字符串，只是将*pp指向该值
//返回字符串的长度，不包括空终止字符
int
fetchstr(uint addr, char **pp)
{
801023d8:	55                   	push   %ebp
801023d9:	89 e5                	mov    %esp,%ebp
801023db:	83 ec 10             	sub    $0x10,%esp
  char *s, *ep;

  if(addr >= proc->sz)
801023de:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801023e4:	8b 00                	mov    (%eax),%eax
801023e6:	3b 45 08             	cmp    0x8(%ebp),%eax
801023e9:	77 07                	ja     801023f2 <fetchstr+0x1a>
    return -1;
801023eb:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801023f0:	eb 46                	jmp    80102438 <fetchstr+0x60>
  *pp = (char*)addr;
801023f2:	8b 55 08             	mov    0x8(%ebp),%edx
801023f5:	8b 45 0c             	mov    0xc(%ebp),%eax
801023f8:	89 10                	mov    %edx,(%eax)
  ep = (char*)proc->sz;
801023fa:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80102400:	8b 00                	mov    (%eax),%eax
80102402:	89 45 f8             	mov    %eax,-0x8(%ebp)
  for(s = *pp; s < ep; s++)
80102405:	8b 45 0c             	mov    0xc(%ebp),%eax
80102408:	8b 00                	mov    (%eax),%eax
8010240a:	89 45 fc             	mov    %eax,-0x4(%ebp)
8010240d:	eb 1c                	jmp    8010242b <fetchstr+0x53>
    if(*s == 0)
8010240f:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102412:	0f b6 00             	movzbl (%eax),%eax
80102415:	84 c0                	test   %al,%al
80102417:	75 0e                	jne    80102427 <fetchstr+0x4f>
      return s - *pp;
80102419:	8b 55 fc             	mov    -0x4(%ebp),%edx
8010241c:	8b 45 0c             	mov    0xc(%ebp),%eax
8010241f:	8b 00                	mov    (%eax),%eax
80102421:	29 c2                	sub    %eax,%edx
80102423:	89 d0                	mov    %edx,%eax
80102425:	eb 11                	jmp    80102438 <fetchstr+0x60>

  if(addr >= proc->sz)
    return -1;
  *pp = (char*)addr;
  ep = (char*)proc->sz;
  for(s = *pp; s < ep; s++)
80102427:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
8010242b:	8b 45 fc             	mov    -0x4(%ebp),%eax
8010242e:	3b 45 f8             	cmp    -0x8(%ebp),%eax
80102431:	72 dc                	jb     8010240f <fetchstr+0x37>
    if(*s == 0)
      return s - *pp;
  return -1;
80102433:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80102438:	c9                   	leave  
80102439:	c3                   	ret    

8010243a <argint>:

// 获取第n个32位系统调用参数
int
argint(int n, int *ip)
{
8010243a:	55                   	push   %ebp
8010243b:	89 e5                	mov    %esp,%ebp
  return fetchint(proc->tf->esp + 4 + 4*n, ip);
8010243d:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80102443:	8b 40 14             	mov    0x14(%eax),%eax
80102446:	8b 40 44             	mov    0x44(%eax),%eax
80102449:	8b 55 08             	mov    0x8(%ebp),%edx
8010244c:	c1 e2 02             	shl    $0x2,%edx
8010244f:	01 d0                	add    %edx,%eax
80102451:	83 c0 04             	add    $0x4,%eax
80102454:	ff 75 0c             	pushl  0xc(%ebp)
80102457:	50                   	push   %eax
80102458:	e8 41 ff ff ff       	call   8010239e <fetchint>
8010245d:	83 c4 08             	add    $0x8,%esp
}
80102460:	c9                   	leave  
80102461:	c3                   	ret    

80102462 <argptr>:

//取出第n个字长的系统调用参数，返回给一个size字节大小的内存块的指针
//核实指针是否在进程地址空间范围之内
int
argptr(int n, char **pp, int size)
{
80102462:	55                   	push   %ebp
80102463:	89 e5                	mov    %esp,%ebp
80102465:	83 ec 10             	sub    $0x10,%esp
  int i;
  
  if(argint(n, &i) < 0)
80102468:	8d 45 fc             	lea    -0x4(%ebp),%eax
8010246b:	50                   	push   %eax
8010246c:	ff 75 08             	pushl  0x8(%ebp)
8010246f:	e8 c6 ff ff ff       	call   8010243a <argint>
80102474:	83 c4 08             	add    $0x8,%esp
80102477:	85 c0                	test   %eax,%eax
80102479:	79 07                	jns    80102482 <argptr+0x20>
    return -1;
8010247b:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80102480:	eb 3d                	jmp    801024bf <argptr+0x5d>
  if((uint)i >= proc->sz || (uint)i+size > proc->sz)
80102482:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102485:	89 c2                	mov    %eax,%edx
80102487:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010248d:	8b 00                	mov    (%eax),%eax
8010248f:	39 c2                	cmp    %eax,%edx
80102491:	73 16                	jae    801024a9 <argptr+0x47>
80102493:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102496:	89 c2                	mov    %eax,%edx
80102498:	8b 45 10             	mov    0x10(%ebp),%eax
8010249b:	01 c2                	add    %eax,%edx
8010249d:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801024a3:	8b 00                	mov    (%eax),%eax
801024a5:	39 c2                	cmp    %eax,%edx
801024a7:	76 07                	jbe    801024b0 <argptr+0x4e>
    return -1;
801024a9:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801024ae:	eb 0f                	jmp    801024bf <argptr+0x5d>
  *pp = (char*)i;
801024b0:	8b 45 fc             	mov    -0x4(%ebp),%eax
801024b3:	89 c2                	mov    %eax,%edx
801024b5:	8b 45 0c             	mov    0xc(%ebp),%eax
801024b8:	89 10                	mov    %edx,(%eax)
  return 0;
801024ba:	b8 00 00 00 00       	mov    $0x0,%eax
}
801024bf:	c9                   	leave  
801024c0:	c3                   	ret    

801024c1 <argstr>:
//取得第n个系统调用参数(字长),传给一个字符串指针
//检查指针的有效性，并检查字符串是否空终止
//没有共享的可写内存，因此在执行检查和内核使用的时候，字符串不能被修改
int
argstr(int n, char **pp)
{
801024c1:	55                   	push   %ebp
801024c2:	89 e5                	mov    %esp,%ebp
801024c4:	83 ec 10             	sub    $0x10,%esp
  int addr;
  if(argint(n, &addr) < 0)
801024c7:	8d 45 fc             	lea    -0x4(%ebp),%eax
801024ca:	50                   	push   %eax
801024cb:	ff 75 08             	pushl  0x8(%ebp)
801024ce:	e8 67 ff ff ff       	call   8010243a <argint>
801024d3:	83 c4 08             	add    $0x8,%esp
801024d6:	85 c0                	test   %eax,%eax
801024d8:	79 07                	jns    801024e1 <argstr+0x20>
    return -1;
801024da:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801024df:	eb 0f                	jmp    801024f0 <argstr+0x2f>
  return fetchstr(addr, pp);
801024e1:	8b 45 fc             	mov    -0x4(%ebp),%eax
801024e4:	ff 75 0c             	pushl  0xc(%ebp)
801024e7:	50                   	push   %eax
801024e8:	e8 eb fe ff ff       	call   801023d8 <fetchstr>
801024ed:	83 c4 08             	add    $0x8,%esp
}
801024f0:	c9                   	leave  
801024f1:	c3                   	ret    

801024f2 <syscall>:
[SYS_exec]    sys_exec,
};

void
syscall(void)
{
801024f2:	55                   	push   %ebp
801024f3:	89 e5                	mov    %esp,%ebp
801024f5:	53                   	push   %ebx
801024f6:	83 ec 14             	sub    $0x14,%esp
  int num;
  num = proc->tf->eax;  //系统调用编号
801024f9:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801024ff:	8b 40 14             	mov    0x14(%eax),%eax
80102502:	8b 40 1c             	mov    0x1c(%eax),%eax
80102505:	89 45 f4             	mov    %eax,-0xc(%ebp)
  cprintf("Systemcall number is %d\n",num);
80102508:	83 ec 08             	sub    $0x8,%esp
8010250b:	ff 75 f4             	pushl  -0xc(%ebp)
8010250e:	68 0d 2b 10 80       	push   $0x80102b0d
80102513:	e8 75 dc ff ff       	call   8010018d <cprintf>
80102518:	83 c4 10             	add    $0x10,%esp
  if(num > 0 && num < NELEM(syscalls) && syscalls[num]){ //编号合法并且存在
8010251b:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
8010251f:	7e 30                	jle    80102551 <syscall+0x5f>
80102521:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102524:	83 f8 07             	cmp    $0x7,%eax
80102527:	77 28                	ja     80102551 <syscall+0x5f>
80102529:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010252c:	8b 04 85 e0 49 10 80 	mov    -0x7fefb620(,%eax,4),%eax
80102533:	85 c0                	test   %eax,%eax
80102535:	74 1a                	je     80102551 <syscall+0x5f>
       proc->tf->eax = syscalls[num]();  //传入系统调用程序入口
80102537:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010253d:	8b 58 14             	mov    0x14(%eax),%ebx
80102540:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102543:	8b 04 85 e0 49 10 80 	mov    -0x7fefb620(,%eax,4),%eax
8010254a:	ff d0                	call   *%eax
8010254c:	89 43 1c             	mov    %eax,0x1c(%ebx)
8010254f:	eb 24                	jmp    80102575 <syscall+0x83>
  } else {
    cprintf("%d %s: unknown sys call %d\n", proc->pid, proc->name, num);
80102551:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80102557:	8d 50 20             	lea    0x20(%eax),%edx
8010255a:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80102560:	8b 40 10             	mov    0x10(%eax),%eax
80102563:	ff 75 f4             	pushl  -0xc(%ebp)
80102566:	52                   	push   %edx
80102567:	50                   	push   %eax
80102568:	68 26 2b 10 80       	push   $0x80102b26
8010256d:	e8 1b dc ff ff       	call   8010018d <cprintf>
80102572:	83 c4 10             	add    $0x10,%esp
  }
}
80102575:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80102578:	c9                   	leave  
80102579:	c3                   	ret    

8010257a <sys_exec>:
#include "proc.h"

//系统调用,这里让其先执行一个cprintf函数
int
sys_exec(void)
{
8010257a:	55                   	push   %ebp
8010257b:	89 e5                	mov    %esp,%ebp
8010257d:	83 ec 08             	sub    $0x8,%esp
    cprintf("A basic Systemcall\n");
80102580:	83 ec 0c             	sub    $0xc,%esp
80102583:	68 42 2b 10 80       	push   $0x80102b42
80102588:	e8 00 dc ff ff       	call   8010018d <cprintf>
8010258d:	83 c4 10             	add    $0x10,%esp
}
80102590:	c9                   	leave  
80102591:	c3                   	ret    

80102592 <swtch>:
# Save current register context in old
# and then load register context from new.

.globl swtch
swtch:
  movl 4(%esp), %eax
80102592:	8b 44 24 04          	mov    0x4(%esp),%eax
  movl 8(%esp), %edx
80102596:	8b 54 24 08          	mov    0x8(%esp),%edx

  # Save old callee-save registers
  pushl %ebp
8010259a:	55                   	push   %ebp
  pushl %ebx
8010259b:	53                   	push   %ebx
  pushl %esi
8010259c:	56                   	push   %esi
  pushl %edi
8010259d:	57                   	push   %edi

  # Switch stacks
  movl %esp, (%eax)
8010259e:	89 20                	mov    %esp,(%eax)
  movl %edx, %esp
801025a0:	89 d4                	mov    %edx,%esp

  # Load new callee-save registers
  popl %edi
801025a2:	5f                   	pop    %edi
  popl %esi
801025a3:	5e                   	pop    %esi
  popl %ebx
801025a4:	5b                   	pop    %ebx
  popl %ebp
801025a5:	5d                   	pop    %ebp
  ret
801025a6:	c3                   	ret    

801025a7 <lidt>:

struct gatedesc;

static inline void
lidt(struct gatedesc *p, int size)
{
801025a7:	55                   	push   %ebp
801025a8:	89 e5                	mov    %esp,%ebp
801025aa:	83 ec 10             	sub    $0x10,%esp
  volatile ushort pd[3];

  pd[0] = size-1;
801025ad:	8b 45 0c             	mov    0xc(%ebp),%eax
801025b0:	83 e8 01             	sub    $0x1,%eax
801025b3:	66 89 45 fa          	mov    %ax,-0x6(%ebp)
  pd[1] = (uint)p;
801025b7:	8b 45 08             	mov    0x8(%ebp),%eax
801025ba:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  pd[2] = (uint)p >> 16;
801025be:	8b 45 08             	mov    0x8(%ebp),%eax
801025c1:	c1 e8 10             	shr    $0x10,%eax
801025c4:	66 89 45 fe          	mov    %ax,-0x2(%ebp)

  asm volatile("lidt (%0)" : : "r" (pd));
801025c8:	8d 45 fa             	lea    -0x6(%ebp),%eax
801025cb:	0f 01 18             	lidtl  (%eax)
}
801025ce:	c9                   	leave  
801025cf:	c3                   	ret    

801025d0 <tvinit>:


// 中断描述符表初始化，将IDT中的每一个中断描述符都与vector.S中256个中断的地址相对应
void
tvinit(void)
{
801025d0:	55                   	push   %ebp
801025d1:	89 e5                	mov    %esp,%ebp
801025d3:	83 ec 10             	sub    $0x10,%esp
  int i;
  for(i = 0; i < 256; i++)
801025d6:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
801025dd:	e9 c3 00 00 00       	jmp    801026a5 <tvinit+0xd5>
    SETGATE(idt[i], 0, SEG_KCODE<<3, vectors[i], 0);
801025e2:	8b 45 fc             	mov    -0x4(%ebp),%eax
801025e5:	8b 04 85 c8 45 10 80 	mov    -0x7fefba38(,%eax,4),%eax
801025ec:	89 c2                	mov    %eax,%edx
801025ee:	8b 45 fc             	mov    -0x4(%ebp),%eax
801025f1:	66 89 14 c5 00 6f 10 	mov    %dx,-0x7fef9100(,%eax,8)
801025f8:	80 
801025f9:	8b 45 fc             	mov    -0x4(%ebp),%eax
801025fc:	66 c7 04 c5 02 6f 10 	movw   $0x8,-0x7fef90fe(,%eax,8)
80102603:	80 08 00 
80102606:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102609:	0f b6 14 c5 04 6f 10 	movzbl -0x7fef90fc(,%eax,8),%edx
80102610:	80 
80102611:	83 e2 e0             	and    $0xffffffe0,%edx
80102614:	88 14 c5 04 6f 10 80 	mov    %dl,-0x7fef90fc(,%eax,8)
8010261b:	8b 45 fc             	mov    -0x4(%ebp),%eax
8010261e:	0f b6 14 c5 04 6f 10 	movzbl -0x7fef90fc(,%eax,8),%edx
80102625:	80 
80102626:	83 e2 1f             	and    $0x1f,%edx
80102629:	88 14 c5 04 6f 10 80 	mov    %dl,-0x7fef90fc(,%eax,8)
80102630:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102633:	0f b6 14 c5 05 6f 10 	movzbl -0x7fef90fb(,%eax,8),%edx
8010263a:	80 
8010263b:	83 e2 f0             	and    $0xfffffff0,%edx
8010263e:	83 ca 0e             	or     $0xe,%edx
80102641:	88 14 c5 05 6f 10 80 	mov    %dl,-0x7fef90fb(,%eax,8)
80102648:	8b 45 fc             	mov    -0x4(%ebp),%eax
8010264b:	0f b6 14 c5 05 6f 10 	movzbl -0x7fef90fb(,%eax,8),%edx
80102652:	80 
80102653:	83 e2 ef             	and    $0xffffffef,%edx
80102656:	88 14 c5 05 6f 10 80 	mov    %dl,-0x7fef90fb(,%eax,8)
8010265d:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102660:	0f b6 14 c5 05 6f 10 	movzbl -0x7fef90fb(,%eax,8),%edx
80102667:	80 
80102668:	83 e2 9f             	and    $0xffffff9f,%edx
8010266b:	88 14 c5 05 6f 10 80 	mov    %dl,-0x7fef90fb(,%eax,8)
80102672:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102675:	0f b6 14 c5 05 6f 10 	movzbl -0x7fef90fb(,%eax,8),%edx
8010267c:	80 
8010267d:	83 ca 80             	or     $0xffffff80,%edx
80102680:	88 14 c5 05 6f 10 80 	mov    %dl,-0x7fef90fb(,%eax,8)
80102687:	8b 45 fc             	mov    -0x4(%ebp),%eax
8010268a:	8b 04 85 c8 45 10 80 	mov    -0x7fefba38(,%eax,4),%eax
80102691:	c1 e8 10             	shr    $0x10,%eax
80102694:	89 c2                	mov    %eax,%edx
80102696:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102699:	66 89 14 c5 06 6f 10 	mov    %dx,-0x7fef90fa(,%eax,8)
801026a0:	80 
// 中断描述符表初始化，将IDT中的每一个中断描述符都与vector.S中256个中断的地址相对应
void
tvinit(void)
{
  int i;
  for(i = 0; i < 256; i++)
801026a1:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
801026a5:	81 7d fc ff 00 00 00 	cmpl   $0xff,-0x4(%ebp)
801026ac:	0f 8e 30 ff ff ff    	jle    801025e2 <tvinit+0x12>
    SETGATE(idt[i], 0, SEG_KCODE<<3, vectors[i], 0);
  SETGATE(idt[T_SYSCALL], 1, SEG_KCODE<<3, vectors[T_SYSCALL], DPL_USER);
801026b2:	a1 c8 46 10 80       	mov    0x801046c8,%eax
801026b7:	66 a3 00 71 10 80    	mov    %ax,0x80107100
801026bd:	66 c7 05 02 71 10 80 	movw   $0x8,0x80107102
801026c4:	08 00 
801026c6:	0f b6 05 04 71 10 80 	movzbl 0x80107104,%eax
801026cd:	83 e0 e0             	and    $0xffffffe0,%eax
801026d0:	a2 04 71 10 80       	mov    %al,0x80107104
801026d5:	0f b6 05 04 71 10 80 	movzbl 0x80107104,%eax
801026dc:	83 e0 1f             	and    $0x1f,%eax
801026df:	a2 04 71 10 80       	mov    %al,0x80107104
801026e4:	0f b6 05 05 71 10 80 	movzbl 0x80107105,%eax
801026eb:	83 c8 0f             	or     $0xf,%eax
801026ee:	a2 05 71 10 80       	mov    %al,0x80107105
801026f3:	0f b6 05 05 71 10 80 	movzbl 0x80107105,%eax
801026fa:	83 e0 ef             	and    $0xffffffef,%eax
801026fd:	a2 05 71 10 80       	mov    %al,0x80107105
80102702:	0f b6 05 05 71 10 80 	movzbl 0x80107105,%eax
80102709:	83 c8 60             	or     $0x60,%eax
8010270c:	a2 05 71 10 80       	mov    %al,0x80107105
80102711:	0f b6 05 05 71 10 80 	movzbl 0x80107105,%eax
80102718:	83 c8 80             	or     $0xffffff80,%eax
8010271b:	a2 05 71 10 80       	mov    %al,0x80107105
80102720:	a1 c8 46 10 80       	mov    0x801046c8,%eax
80102725:	c1 e8 10             	shr    $0x10,%eax
80102728:	66 a3 06 71 10 80    	mov    %ax,0x80107106
}
8010272e:	c9                   	leave  
8010272f:	c3                   	ret    

80102730 <printidt>:

// 打印一些当前IDT内中的一些信息
void 
printidt(void)
{
80102730:	55                   	push   %ebp
80102731:	89 e5                	mov    %esp,%ebp
80102733:	83 ec 18             	sub    $0x18,%esp
  int i = 0;
80102736:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  for(;i<=10;i++){
8010273d:	eb 48                	jmp    80102787 <printidt+0x57>
	cprintf("IDT %d: offset 31~16:%d\n", i, idt[i].off_31_16);
8010273f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102742:	0f b7 04 c5 06 6f 10 	movzwl -0x7fef90fa(,%eax,8),%eax
80102749:	80 
8010274a:	0f b7 c0             	movzwl %ax,%eax
8010274d:	83 ec 04             	sub    $0x4,%esp
80102750:	50                   	push   %eax
80102751:	ff 75 f4             	pushl  -0xc(%ebp)
80102754:	68 56 2b 10 80       	push   $0x80102b56
80102759:	e8 2f da ff ff       	call   8010018d <cprintf>
8010275e:	83 c4 10             	add    $0x10,%esp
	cprintf("IDT %d: offset 15~0:%d\n", i, idt[i].off_15_0);
80102761:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102764:	0f b7 04 c5 00 6f 10 	movzwl -0x7fef9100(,%eax,8),%eax
8010276b:	80 
8010276c:	0f b7 c0             	movzwl %ax,%eax
8010276f:	83 ec 04             	sub    $0x4,%esp
80102772:	50                   	push   %eax
80102773:	ff 75 f4             	pushl  -0xc(%ebp)
80102776:	68 6f 2b 10 80       	push   $0x80102b6f
8010277b:	e8 0d da ff ff       	call   8010018d <cprintf>
80102780:	83 c4 10             	add    $0x10,%esp
// 打印一些当前IDT内中的一些信息
void 
printidt(void)
{
  int i = 0;
  for(;i<=10;i++){
80102783:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80102787:	83 7d f4 0a          	cmpl   $0xa,-0xc(%ebp)
8010278b:	7e b2                	jle    8010273f <printidt+0xf>
	cprintf("IDT %d: offset 31~16:%d\n", i, idt[i].off_31_16);
	cprintf("IDT %d: offset 15~0:%d\n", i, idt[i].off_15_0);
  }
}
8010278d:	c9                   	leave  
8010278e:	c3                   	ret    

8010278f <idtinit>:

// 加载idt，调用内联汇编
void
idtinit(void)
{
8010278f:	55                   	push   %ebp
80102790:	89 e5                	mov    %esp,%ebp
  lidt(idt, sizeof(idt));
80102792:	68 00 08 00 00       	push   $0x800
80102797:	68 00 6f 10 80       	push   $0x80106f00
8010279c:	e8 06 fe ff ff       	call   801025a7 <lidt>
801027a1:	83 c4 08             	add    $0x8,%esp
}
801027a4:	c9                   	leave  
801027a5:	c3                   	ret    

801027a6 <trap>:

// 中断处理程序,目前什么都不做
void
trap(struct trapframe *tf)
{
801027a6:	55                   	push   %ebp
801027a7:	89 e5                	mov    %esp,%ebp
801027a9:	83 ec 08             	sub    $0x8,%esp
  if(tf->trapno == T_SYSCALL){
801027ac:	8b 45 08             	mov    0x8(%ebp),%eax
801027af:	8b 40 30             	mov    0x30(%eax),%eax
801027b2:	83 f8 40             	cmp    $0x40,%eax
801027b5:	75 13                	jne    801027ca <trap+0x24>
	proc->tf = tf;
801027b7:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801027bd:	8b 55 08             	mov    0x8(%ebp),%edx
801027c0:	89 50 14             	mov    %edx,0x14(%eax)
	syscall();
801027c3:	e8 2a fd ff ff       	call   801024f2 <syscall>
	return;
801027c8:	eb 10                	jmp    801027da <trap+0x34>
  }
   if(tf->trapno == (T_IRQ0 + IRQ_KBD)){
801027ca:	8b 45 08             	mov    0x8(%ebp),%eax
801027cd:	8b 40 30             	mov    0x30(%eax),%eax
801027d0:	83 f8 21             	cmp    $0x21,%eax
801027d3:	75 05                	jne    801027da <trap+0x34>
       kbdintr();
801027d5:	e8 16 e2 ff ff       	call   801009f0 <kbdintr>
  }	
}
801027da:	c9                   	leave  
801027db:	c3                   	ret    

801027dc <alltraps>:
  # vectors.S 会把所有的中断都掉转到这里
.globl alltraps

alltraps:
  # 建立一个中断帧，保护现场
  pushl %ds
801027dc:	1e                   	push   %ds
  pushl %es
801027dd:	06                   	push   %es
  pushl %fs
801027de:	0f a0                	push   %fs
  pushl %gs
801027e0:	0f a8                	push   %gs
  pushal
801027e2:	60                   	pusha  
  
  # 设置数据段
  movw $(SEG_KDATA<<3), %ax
801027e3:	66 b8 10 00          	mov    $0x10,%ax
  movw %ax, %ds
801027e7:	8e d8                	mov    %eax,%ds
  movw %ax, %es
801027e9:	8e c0                	mov    %eax,%es

  # 调用trap函数，执行中断服务程序，目前针对所有中断都不做任何处理
  # 定义在了trap.c中，同时压栈esp，这里的esp就代表了trap的参数tf，也就是当前的中断帧
  pushl %esp
801027eb:	54                   	push   %esp
  call trap
801027ec:	e8 b5 ff ff ff       	call   801027a6 <trap>
  addl $4, %esp
801027f1:	83 c4 04             	add    $0x4,%esp

801027f4 <trapret>:

  # 执行完中断服务程序以后开始恢复现场
.globl trapret
trapret:
  popal
801027f4:	61                   	popa   
  popl %gs
801027f5:	0f a9                	pop    %gs
  popl %fs
801027f7:	0f a1                	pop    %fs
  popl %es
801027f9:	07                   	pop    %es
  popl %ds
801027fa:	1f                   	pop    %ds
  addl $0x8, %esp  # 中断号以及错误号
801027fb:	83 c4 08             	add    $0x8,%esp
  iret
801027fe:	cf                   	iret   

801027ff <inb>:
// Routines to let C code use special x86 instructions.

static inline uchar
inb(ushort port)
{
801027ff:	55                   	push   %ebp
80102800:	89 e5                	mov    %esp,%ebp
80102802:	83 ec 14             	sub    $0x14,%esp
80102805:	8b 45 08             	mov    0x8(%ebp),%eax
80102808:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
  uchar data;

  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
8010280c:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
80102810:	89 c2                	mov    %eax,%edx
80102812:	ec                   	in     (%dx),%al
80102813:	88 45 ff             	mov    %al,-0x1(%ebp)
  return data;
80102816:	0f b6 45 ff          	movzbl -0x1(%ebp),%eax
}
8010281a:	c9                   	leave  
8010281b:	c3                   	ret    

8010281c <outb>:
               "memory", "cc");
}

static inline void
outb(ushort port, uchar data)
{
8010281c:	55                   	push   %ebp
8010281d:	89 e5                	mov    %esp,%ebp
8010281f:	83 ec 08             	sub    $0x8,%esp
80102822:	8b 55 08             	mov    0x8(%ebp),%edx
80102825:	8b 45 0c             	mov    0xc(%ebp),%eax
80102828:	66 89 55 fc          	mov    %dx,-0x4(%ebp)
8010282c:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
8010282f:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
80102833:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
80102837:	ee                   	out    %al,(%dx)
}
80102838:	c9                   	leave  
80102839:	c3                   	ret    

8010283a <uartputc>:

#define COM1    0x3f8

void
uartputc(int c)
{
8010283a:	55                   	push   %ebp
8010283b:	89 e5                	mov    %esp,%ebp
8010283d:	83 ec 10             	sub    $0x10,%esp
  int i;
  for(i = 0; i < 128 && !(inb(COM1+5) & 0x20); i++)
80102840:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
80102847:	eb 18                	jmp    80102861 <uartputc+0x27>
  outb(COM1+0, c);
80102849:	8b 45 08             	mov    0x8(%ebp),%eax
8010284c:	0f b6 c0             	movzbl %al,%eax
8010284f:	50                   	push   %eax
80102850:	68 f8 03 00 00       	push   $0x3f8
80102855:	e8 c2 ff ff ff       	call   8010281c <outb>
8010285a:	83 c4 08             	add    $0x8,%esp

void
uartputc(int c)
{
  int i;
  for(i = 0; i < 128 && !(inb(COM1+5) & 0x20); i++)
8010285d:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
80102861:	83 7d fc 7f          	cmpl   $0x7f,-0x4(%ebp)
80102865:	7f 17                	jg     8010287e <uartputc+0x44>
80102867:	68 fd 03 00 00       	push   $0x3fd
8010286c:	e8 8e ff ff ff       	call   801027ff <inb>
80102871:	83 c4 04             	add    $0x4,%esp
80102874:	0f b6 c0             	movzbl %al,%eax
80102877:	83 e0 20             	and    $0x20,%eax
8010287a:	85 c0                	test   %eax,%eax
8010287c:	74 cb                	je     80102849 <uartputc+0xf>
  outb(COM1+0, c);
}
8010287e:	c9                   	leave  
8010287f:	c3                   	ret    
