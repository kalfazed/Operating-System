
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
80100028:	bc 10 5f 10 80       	mov    $0x80105f10,%esp

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
8010004e:	68 cc 22 10 80       	push   $0x801022cc
80100053:	e8 57 01 00 00       	call   801001af <cprintf>
80100058:	83 c4 10             	add    $0x10,%esp
  
  kinit(end, P2V(4*1024*1024));  // 物理页的分配
8010005b:	83 ec 08             	sub    $0x8,%esp
8010005e:	68 00 00 40 80       	push   $0x80400000
80100063:	68 00 76 10 80       	push   $0x80107600
80100068:	e8 7b 07 00 00       	call   801007e8 <kinit>
8010006d:	83 c4 10             	add    $0x10,%esp
  cprintf("Current pgdir is %x\n",kpgdir);
80100070:	a1 60 61 10 80       	mov    0x80106160,%eax
80100075:	83 ec 08             	sub    $0x8,%esp
80100078:	50                   	push   %eax
80100079:	68 d7 22 10 80       	push   $0x801022d7
8010007e:	e8 2c 01 00 00       	call   801001af <cprintf>
80100083:	83 c4 10             	add    $0x10,%esp
  kvmalloc(); 			 // 内核页表
80100086:	e8 f6 0f 00 00       	call   80101081 <kvmalloc>
  cprintf("Current pgdir is %x\n",kpgdir);
8010008b:	a1 60 61 10 80       	mov    0x80106160,%eax
80100090:	83 ec 08             	sub    $0x8,%esp
80100093:	50                   	push   %eax
80100094:	68 d7 22 10 80       	push   $0x801022d7
80100099:	e8 11 01 00 00       	call   801001af <cprintf>
8010009e:	83 c4 10             	add    $0x10,%esp

  seginit();   			 // 初始化段，这里对段的初始化是对当前cpu的gdt的初始化
801000a1:	e8 65 09 00 00       	call   80100a0b <seginit>
//  segshow();   		 // 打印一些段的信息，用来验证

  picinit(); 			 // 初始化中断控制器8259A 
801000a6:	e8 c6 10 00 00       	call   80101171 <picinit>
  ioapicinit(); 		 // 初始化IOAAPIC中断控制器
801000ab:	e8 34 14 00 00       	call   801014e4 <ioapicinit>
  consoleinit(); 		 // 初始化控制台
801000b0:	e8 b8 03 00 00       	call   8010046d <consoleinit>

  tvinit(); 			 // 初始化idt，扩充idt中中断描述符的内容
801000b5:	e8 7d 1f 00 00       	call   80102037 <tvinit>
  idtinit(); 			 // 加载idt
801000ba:	e8 37 21 00 00       	call   801021f6 <idtinit>
//  printidt(); 	         // 打印一些idt的信息，用来验证

//  userinit(); 			 // 初始化一个用户进程
//  cprintf("User initial has finished!!!\n");
  sti();
801000bf:	e8 70 ff ff ff       	call   80100034 <sti>

  while(1);
801000c4:	eb fe                	jmp    801000c4 <main+0x8a>

801000c6 <inb>:
// Routines to let C code use special x86 instructions.

static inline uchar
inb(ushort port)
{
801000c6:	55                   	push   %ebp
801000c7:	89 e5                	mov    %esp,%ebp
801000c9:	83 ec 14             	sub    $0x14,%esp
801000cc:	8b 45 08             	mov    0x8(%ebp),%eax
801000cf:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
  uchar data;

  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
801000d3:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
801000d7:	89 c2                	mov    %eax,%edx
801000d9:	ec                   	in     (%dx),%al
801000da:	88 45 ff             	mov    %al,-0x1(%ebp)
  return data;
801000dd:	0f b6 45 ff          	movzbl -0x1(%ebp),%eax
}
801000e1:	c9                   	leave  
801000e2:	c3                   	ret    

801000e3 <outb>:
               "memory", "cc");
}

static inline void
outb(ushort port, uchar data)
{
801000e3:	55                   	push   %ebp
801000e4:	89 e5                	mov    %esp,%ebp
801000e6:	83 ec 08             	sub    $0x8,%esp
801000e9:	8b 55 08             	mov    0x8(%ebp),%edx
801000ec:	8b 45 0c             	mov    0xc(%ebp),%eax
801000ef:	66 89 55 fc          	mov    %dx,-0x4(%ebp)
801000f3:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
801000f6:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
801000fa:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
801000fe:	ee                   	out    %al,(%dx)
}
801000ff:	c9                   	leave  
80100100:	c3                   	ret    

80100101 <printint>:
static void consputc(int);


static void
printint(int xx, int base, int sign)
{
80100101:	55                   	push   %ebp
80100102:	89 e5                	mov    %esp,%ebp
80100104:	53                   	push   %ebx
80100105:	83 ec 24             	sub    $0x24,%esp
  static char digits[] = "0123456789abcdef";
  char buf[16];
  int i;
  uint x;

  if(sign && (sign = xx < 0))
80100108:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
8010010c:	74 1c                	je     8010012a <printint+0x29>
8010010e:	8b 45 08             	mov    0x8(%ebp),%eax
80100111:	c1 e8 1f             	shr    $0x1f,%eax
80100114:	0f b6 c0             	movzbl %al,%eax
80100117:	89 45 10             	mov    %eax,0x10(%ebp)
8010011a:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
8010011e:	74 0a                	je     8010012a <printint+0x29>
    x = -xx;
80100120:	8b 45 08             	mov    0x8(%ebp),%eax
80100123:	f7 d8                	neg    %eax
80100125:	89 45 f0             	mov    %eax,-0x10(%ebp)
80100128:	eb 06                	jmp    80100130 <printint+0x2f>
  else
    x = xx;
8010012a:	8b 45 08             	mov    0x8(%ebp),%eax
8010012d:	89 45 f0             	mov    %eax,-0x10(%ebp)

  i = 0;
80100130:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  do{
    buf[i++] = digits[x % base];
80100137:	8b 4d f4             	mov    -0xc(%ebp),%ecx
8010013a:	8d 41 01             	lea    0x1(%ecx),%eax
8010013d:	89 45 f4             	mov    %eax,-0xc(%ebp)
80100140:	8b 5d 0c             	mov    0xc(%ebp),%ebx
80100143:	8b 45 f0             	mov    -0x10(%ebp),%eax
80100146:	ba 00 00 00 00       	mov    $0x0,%edx
8010014b:	f7 f3                	div    %ebx
8010014d:	89 d0                	mov    %edx,%eax
8010014f:	0f b6 80 04 40 10 80 	movzbl -0x7fefbffc(%eax),%eax
80100156:	88 44 0d e0          	mov    %al,-0x20(%ebp,%ecx,1)
  }while((x /= base) != 0);
8010015a:	8b 5d 0c             	mov    0xc(%ebp),%ebx
8010015d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80100160:	ba 00 00 00 00       	mov    $0x0,%edx
80100165:	f7 f3                	div    %ebx
80100167:	89 45 f0             	mov    %eax,-0x10(%ebp)
8010016a:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
8010016e:	75 c7                	jne    80100137 <printint+0x36>

  if(sign)
80100170:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80100174:	74 0e                	je     80100184 <printint+0x83>
    buf[i++] = '-';
80100176:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100179:	8d 50 01             	lea    0x1(%eax),%edx
8010017c:	89 55 f4             	mov    %edx,-0xc(%ebp)
8010017f:	c6 44 05 e0 2d       	movb   $0x2d,-0x20(%ebp,%eax,1)

  while(--i >= 0)
80100184:	eb 1a                	jmp    801001a0 <printint+0x9f>
    consputc(buf[i]);
80100186:	8d 55 e0             	lea    -0x20(%ebp),%edx
80100189:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010018c:	01 d0                	add    %edx,%eax
8010018e:	0f b6 00             	movzbl (%eax),%eax
80100191:	0f be c0             	movsbl %al,%eax
80100194:	83 ec 0c             	sub    $0xc,%esp
80100197:	50                   	push   %eax
80100198:	e8 7a 02 00 00       	call   80100417 <consputc>
8010019d:	83 c4 10             	add    $0x10,%esp
  }while((x /= base) != 0);

  if(sign)
    buf[i++] = '-';

  while(--i >= 0)
801001a0:	83 6d f4 01          	subl   $0x1,-0xc(%ebp)
801001a4:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801001a8:	79 dc                	jns    80100186 <printint+0x85>
    consputc(buf[i]);
}
801001aa:	8b 5d fc             	mov    -0x4(%ebp),%ebx
801001ad:	c9                   	leave  
801001ae:	c3                   	ret    

801001af <cprintf>:

void
cprintf(char *fmt, ...)
{
801001af:	55                   	push   %ebp
801001b0:	89 e5                	mov    %esp,%ebp
801001b2:	83 ec 18             	sub    $0x18,%esp
  int i, c;
  uint *argp;
  char *s;

  argp = (uint*)(void*)(&fmt + 1);
801001b5:	8d 45 0c             	lea    0xc(%ebp),%eax
801001b8:	89 45 f0             	mov    %eax,-0x10(%ebp)
  for(i = 0; (c = fmt[i] & 0xff) != 0; i++){
801001bb:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801001c2:	e9 1b 01 00 00       	jmp    801002e2 <cprintf+0x133>
    if(c != '%'){
801001c7:	83 7d e8 25          	cmpl   $0x25,-0x18(%ebp)
801001cb:	74 13                	je     801001e0 <cprintf+0x31>
      consputc(c);
801001cd:	83 ec 0c             	sub    $0xc,%esp
801001d0:	ff 75 e8             	pushl  -0x18(%ebp)
801001d3:	e8 3f 02 00 00       	call   80100417 <consputc>
801001d8:	83 c4 10             	add    $0x10,%esp
      continue;
801001db:	e9 fe 00 00 00       	jmp    801002de <cprintf+0x12f>
    }
    c = fmt[++i] & 0xff;
801001e0:	8b 55 08             	mov    0x8(%ebp),%edx
801001e3:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801001e7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801001ea:	01 d0                	add    %edx,%eax
801001ec:	0f b6 00             	movzbl (%eax),%eax
801001ef:	0f be c0             	movsbl %al,%eax
801001f2:	25 ff 00 00 00       	and    $0xff,%eax
801001f7:	89 45 e8             	mov    %eax,-0x18(%ebp)
    if(c == 0)
801001fa:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
801001fe:	75 05                	jne    80100205 <cprintf+0x56>
      break;
80100200:	e9 fd 00 00 00       	jmp    80100302 <cprintf+0x153>
    switch(c){
80100205:	8b 45 e8             	mov    -0x18(%ebp),%eax
80100208:	83 f8 70             	cmp    $0x70,%eax
8010020b:	74 47                	je     80100254 <cprintf+0xa5>
8010020d:	83 f8 70             	cmp    $0x70,%eax
80100210:	7f 13                	jg     80100225 <cprintf+0x76>
80100212:	83 f8 25             	cmp    $0x25,%eax
80100215:	0f 84 98 00 00 00    	je     801002b3 <cprintf+0x104>
8010021b:	83 f8 64             	cmp    $0x64,%eax
8010021e:	74 14                	je     80100234 <cprintf+0x85>
80100220:	e9 9d 00 00 00       	jmp    801002c2 <cprintf+0x113>
80100225:	83 f8 73             	cmp    $0x73,%eax
80100228:	74 47                	je     80100271 <cprintf+0xc2>
8010022a:	83 f8 78             	cmp    $0x78,%eax
8010022d:	74 25                	je     80100254 <cprintf+0xa5>
8010022f:	e9 8e 00 00 00       	jmp    801002c2 <cprintf+0x113>
    case 'd':
      printint(*argp++, 10, 1);
80100234:	8b 45 f0             	mov    -0x10(%ebp),%eax
80100237:	8d 50 04             	lea    0x4(%eax),%edx
8010023a:	89 55 f0             	mov    %edx,-0x10(%ebp)
8010023d:	8b 00                	mov    (%eax),%eax
8010023f:	83 ec 04             	sub    $0x4,%esp
80100242:	6a 01                	push   $0x1
80100244:	6a 0a                	push   $0xa
80100246:	50                   	push   %eax
80100247:	e8 b5 fe ff ff       	call   80100101 <printint>
8010024c:	83 c4 10             	add    $0x10,%esp
      break;
8010024f:	e9 8a 00 00 00       	jmp    801002de <cprintf+0x12f>
    case 'x':
    case 'p':
      printint(*argp++, 16, 0);
80100254:	8b 45 f0             	mov    -0x10(%ebp),%eax
80100257:	8d 50 04             	lea    0x4(%eax),%edx
8010025a:	89 55 f0             	mov    %edx,-0x10(%ebp)
8010025d:	8b 00                	mov    (%eax),%eax
8010025f:	83 ec 04             	sub    $0x4,%esp
80100262:	6a 00                	push   $0x0
80100264:	6a 10                	push   $0x10
80100266:	50                   	push   %eax
80100267:	e8 95 fe ff ff       	call   80100101 <printint>
8010026c:	83 c4 10             	add    $0x10,%esp
      break;
8010026f:	eb 6d                	jmp    801002de <cprintf+0x12f>
    case 's':
      if((s = (char*)*argp++) == 0)
80100271:	8b 45 f0             	mov    -0x10(%ebp),%eax
80100274:	8d 50 04             	lea    0x4(%eax),%edx
80100277:	89 55 f0             	mov    %edx,-0x10(%ebp)
8010027a:	8b 00                	mov    (%eax),%eax
8010027c:	89 45 ec             	mov    %eax,-0x14(%ebp)
8010027f:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80100283:	75 07                	jne    8010028c <cprintf+0xdd>
        s = "(null)";
80100285:	c7 45 ec ec 22 10 80 	movl   $0x801022ec,-0x14(%ebp)
      for(; *s; s++)
8010028c:	eb 19                	jmp    801002a7 <cprintf+0xf8>
        consputc(*s);
8010028e:	8b 45 ec             	mov    -0x14(%ebp),%eax
80100291:	0f b6 00             	movzbl (%eax),%eax
80100294:	0f be c0             	movsbl %al,%eax
80100297:	83 ec 0c             	sub    $0xc,%esp
8010029a:	50                   	push   %eax
8010029b:	e8 77 01 00 00       	call   80100417 <consputc>
801002a0:	83 c4 10             	add    $0x10,%esp
      printint(*argp++, 16, 0);
      break;
    case 's':
      if((s = (char*)*argp++) == 0)
        s = "(null)";
      for(; *s; s++)
801002a3:	83 45 ec 01          	addl   $0x1,-0x14(%ebp)
801002a7:	8b 45 ec             	mov    -0x14(%ebp),%eax
801002aa:	0f b6 00             	movzbl (%eax),%eax
801002ad:	84 c0                	test   %al,%al
801002af:	75 dd                	jne    8010028e <cprintf+0xdf>
        consputc(*s);
      break;
801002b1:	eb 2b                	jmp    801002de <cprintf+0x12f>
    case '%':
      consputc('%');
801002b3:	83 ec 0c             	sub    $0xc,%esp
801002b6:	6a 25                	push   $0x25
801002b8:	e8 5a 01 00 00       	call   80100417 <consputc>
801002bd:	83 c4 10             	add    $0x10,%esp
      break;
801002c0:	eb 1c                	jmp    801002de <cprintf+0x12f>
    default:
      consputc('%');
801002c2:	83 ec 0c             	sub    $0xc,%esp
801002c5:	6a 25                	push   $0x25
801002c7:	e8 4b 01 00 00       	call   80100417 <consputc>
801002cc:	83 c4 10             	add    $0x10,%esp
      consputc(c);
801002cf:	83 ec 0c             	sub    $0xc,%esp
801002d2:	ff 75 e8             	pushl  -0x18(%ebp)
801002d5:	e8 3d 01 00 00       	call   80100417 <consputc>
801002da:	83 c4 10             	add    $0x10,%esp
      break;
801002dd:	90                   	nop
  int i, c;
  uint *argp;
  char *s;

  argp = (uint*)(void*)(&fmt + 1);
  for(i = 0; (c = fmt[i] & 0xff) != 0; i++){
801002de:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801002e2:	8b 55 08             	mov    0x8(%ebp),%edx
801002e5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801002e8:	01 d0                	add    %edx,%eax
801002ea:	0f b6 00             	movzbl (%eax),%eax
801002ed:	0f be c0             	movsbl %al,%eax
801002f0:	25 ff 00 00 00       	and    $0xff,%eax
801002f5:	89 45 e8             	mov    %eax,-0x18(%ebp)
801002f8:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
801002fc:	0f 85 c5 fe ff ff    	jne    801001c7 <cprintf+0x18>
      consputc(c);
      break;
    }
  }

}
80100302:	c9                   	leave  
80100303:	c3                   	ret    

80100304 <cgaputc>:

static ushort *crt = (ushort*)P2V(0xb8000);  // CGA memory

static void
cgaputc(int c)
{
80100304:	55                   	push   %ebp
80100305:	89 e5                	mov    %esp,%ebp
80100307:	83 ec 10             	sub    $0x10,%esp
  int pos;
  
  // Cursor position: col + 80*row.
  outb(CRTPORT, 14);
8010030a:	6a 0e                	push   $0xe
8010030c:	68 d4 03 00 00       	push   $0x3d4
80100311:	e8 cd fd ff ff       	call   801000e3 <outb>
80100316:	83 c4 08             	add    $0x8,%esp
  pos = inb(CRTPORT+1) << 8;
80100319:	68 d5 03 00 00       	push   $0x3d5
8010031e:	e8 a3 fd ff ff       	call   801000c6 <inb>
80100323:	83 c4 04             	add    $0x4,%esp
80100326:	0f b6 c0             	movzbl %al,%eax
80100329:	c1 e0 08             	shl    $0x8,%eax
8010032c:	89 45 fc             	mov    %eax,-0x4(%ebp)
  outb(CRTPORT, 15);
8010032f:	6a 0f                	push   $0xf
80100331:	68 d4 03 00 00       	push   $0x3d4
80100336:	e8 a8 fd ff ff       	call   801000e3 <outb>
8010033b:	83 c4 08             	add    $0x8,%esp
  pos |= inb(CRTPORT+1);
8010033e:	68 d5 03 00 00       	push   $0x3d5
80100343:	e8 7e fd ff ff       	call   801000c6 <inb>
80100348:	83 c4 04             	add    $0x4,%esp
8010034b:	0f b6 c0             	movzbl %al,%eax
8010034e:	09 45 fc             	or     %eax,-0x4(%ebp)

  if(c == '\n')
80100351:	83 7d 08 0a          	cmpl   $0xa,0x8(%ebp)
80100355:	75 30                	jne    80100387 <cgaputc+0x83>
  {
      pos += 80 - pos%80;
80100357:	8b 4d fc             	mov    -0x4(%ebp),%ecx
8010035a:	ba 67 66 66 66       	mov    $0x66666667,%edx
8010035f:	89 c8                	mov    %ecx,%eax
80100361:	f7 ea                	imul   %edx
80100363:	c1 fa 05             	sar    $0x5,%edx
80100366:	89 c8                	mov    %ecx,%eax
80100368:	c1 f8 1f             	sar    $0x1f,%eax
8010036b:	29 c2                	sub    %eax,%edx
8010036d:	89 d0                	mov    %edx,%eax
8010036f:	c1 e0 02             	shl    $0x2,%eax
80100372:	01 d0                	add    %edx,%eax
80100374:	c1 e0 04             	shl    $0x4,%eax
80100377:	29 c1                	sub    %eax,%ecx
80100379:	89 ca                	mov    %ecx,%edx
8010037b:	b8 50 00 00 00       	mov    $0x50,%eax
80100380:	29 d0                	sub    %edx,%eax
80100382:	01 45 fc             	add    %eax,-0x4(%ebp)
80100385:	eb 34                	jmp    801003bb <cgaputc+0xb7>
  }
  else if(c == BACKSPACE){
80100387:	81 7d 08 00 01 00 00 	cmpl   $0x100,0x8(%ebp)
8010038e:	75 0c                	jne    8010039c <cgaputc+0x98>
    if(pos > 0) --pos;
80100390:	83 7d fc 00          	cmpl   $0x0,-0x4(%ebp)
80100394:	7e 25                	jle    801003bb <cgaputc+0xb7>
80100396:	83 6d fc 01          	subl   $0x1,-0x4(%ebp)
8010039a:	eb 1f                	jmp    801003bb <cgaputc+0xb7>
  } else
  {
      crt[pos++] = (c&0xff) | 0x0700;  // black on white
8010039c:	8b 0d 00 40 10 80    	mov    0x80104000,%ecx
801003a2:	8b 45 fc             	mov    -0x4(%ebp),%eax
801003a5:	8d 50 01             	lea    0x1(%eax),%edx
801003a8:	89 55 fc             	mov    %edx,-0x4(%ebp)
801003ab:	01 c0                	add    %eax,%eax
801003ad:	01 c8                	add    %ecx,%eax
801003af:	8b 55 08             	mov    0x8(%ebp),%edx
801003b2:	0f b6 d2             	movzbl %dl,%edx
801003b5:	80 ce 07             	or     $0x7,%dh
801003b8:	66 89 10             	mov    %dx,(%eax)
  }

  outb(CRTPORT, 14);
801003bb:	6a 0e                	push   $0xe
801003bd:	68 d4 03 00 00       	push   $0x3d4
801003c2:	e8 1c fd ff ff       	call   801000e3 <outb>
801003c7:	83 c4 08             	add    $0x8,%esp
  outb(CRTPORT+1, pos>>8);
801003ca:	8b 45 fc             	mov    -0x4(%ebp),%eax
801003cd:	c1 f8 08             	sar    $0x8,%eax
801003d0:	0f b6 c0             	movzbl %al,%eax
801003d3:	50                   	push   %eax
801003d4:	68 d5 03 00 00       	push   $0x3d5
801003d9:	e8 05 fd ff ff       	call   801000e3 <outb>
801003de:	83 c4 08             	add    $0x8,%esp
  outb(CRTPORT, 15);
801003e1:	6a 0f                	push   $0xf
801003e3:	68 d4 03 00 00       	push   $0x3d4
801003e8:	e8 f6 fc ff ff       	call   801000e3 <outb>
801003ed:	83 c4 08             	add    $0x8,%esp
  outb(CRTPORT+1, pos);
801003f0:	8b 45 fc             	mov    -0x4(%ebp),%eax
801003f3:	0f b6 c0             	movzbl %al,%eax
801003f6:	50                   	push   %eax
801003f7:	68 d5 03 00 00       	push   $0x3d5
801003fc:	e8 e2 fc ff ff       	call   801000e3 <outb>
80100401:	83 c4 08             	add    $0x8,%esp
  crt[pos] = ' ' | 0x0700;
80100404:	a1 00 40 10 80       	mov    0x80104000,%eax
80100409:	8b 55 fc             	mov    -0x4(%ebp),%edx
8010040c:	01 d2                	add    %edx,%edx
8010040e:	01 d0                	add    %edx,%eax
80100410:	66 c7 00 20 07       	movw   $0x720,(%eax)
}
80100415:	c9                   	leave  
80100416:	c3                   	ret    

80100417 <consputc>:

void
consputc(int c)
{
80100417:	55                   	push   %ebp
80100418:	89 e5                	mov    %esp,%ebp
8010041a:	83 ec 08             	sub    $0x8,%esp
  if(c == BACKSPACE){
8010041d:	81 7d 08 00 01 00 00 	cmpl   $0x100,0x8(%ebp)
80100424:	75 29                	jne    8010044f <consputc+0x38>
    uartputc('\b'); uartputc(' '); uartputc('\b');
80100426:	83 ec 0c             	sub    $0xc,%esp
80100429:	6a 08                	push   $0x8
8010042b:	e8 53 1e 00 00       	call   80102283 <uartputc>
80100430:	83 c4 10             	add    $0x10,%esp
80100433:	83 ec 0c             	sub    $0xc,%esp
80100436:	6a 20                	push   $0x20
80100438:	e8 46 1e 00 00       	call   80102283 <uartputc>
8010043d:	83 c4 10             	add    $0x10,%esp
80100440:	83 ec 0c             	sub    $0xc,%esp
80100443:	6a 08                	push   $0x8
80100445:	e8 39 1e 00 00       	call   80102283 <uartputc>
8010044a:	83 c4 10             	add    $0x10,%esp
8010044d:	eb 0e                	jmp    8010045d <consputc+0x46>
  } else
    uartputc(c);
8010044f:	83 ec 0c             	sub    $0xc,%esp
80100452:	ff 75 08             	pushl  0x8(%ebp)
80100455:	e8 29 1e 00 00       	call   80102283 <uartputc>
8010045a:	83 c4 10             	add    $0x10,%esp
  cgaputc(c);
8010045d:	83 ec 0c             	sub    $0xc,%esp
80100460:	ff 75 08             	pushl  0x8(%ebp)
80100463:	e8 9c fe ff ff       	call   80100304 <cgaputc>
80100468:	83 c4 10             	add    $0x10,%esp
}
8010046b:	c9                   	leave  
8010046c:	c3                   	ret    

8010046d <consoleinit>:


void consoleinit(void)
{
8010046d:	55                   	push   %ebp
8010046e:	89 e5                	mov    %esp,%ebp
80100470:	83 ec 08             	sub    $0x8,%esp
  picenable(IRQ_KBD);
80100473:	83 ec 0c             	sub    $0xc,%esp
80100476:	6a 01                	push   $0x1
80100478:	e8 c8 0c 00 00       	call   80101145 <picenable>
8010047d:	83 c4 10             	add    $0x10,%esp
  ioapicenable(IRQ_KBD, 0);
80100480:	83 ec 08             	sub    $0x8,%esp
80100483:	6a 00                	push   $0x0
80100485:	6a 01                	push   $0x1
80100487:	e8 c9 10 00 00       	call   80101555 <ioapicenable>
8010048c:	83 c4 10             	add    $0x10,%esp
}
8010048f:	c9                   	leave  
80100490:	c3                   	ret    

80100491 <getcmd>:

#define C(x)  ((x)-'@')  // Control-x

int
getcmd()
{
80100491:	55                   	push   %ebp
80100492:	89 e5                	mov    %esp,%ebp
	if((input.buf[0] == 'f')&&(input.buf[1] == 'o')&&(input.buf[2] == 'r')&&(input.buf[3] == 'k')&&(input.e == 4))
80100494:	0f b6 05 40 5f 10 80 	movzbl 0x80105f40,%eax
8010049b:	3c 66                	cmp    $0x66,%al
8010049d:	75 32                	jne    801004d1 <getcmd+0x40>
8010049f:	0f b6 05 41 5f 10 80 	movzbl 0x80105f41,%eax
801004a6:	3c 6f                	cmp    $0x6f,%al
801004a8:	75 27                	jne    801004d1 <getcmd+0x40>
801004aa:	0f b6 05 42 5f 10 80 	movzbl 0x80105f42,%eax
801004b1:	3c 72                	cmp    $0x72,%al
801004b3:	75 1c                	jne    801004d1 <getcmd+0x40>
801004b5:	0f b6 05 43 5f 10 80 	movzbl 0x80105f43,%eax
801004bc:	3c 6b                	cmp    $0x6b,%al
801004be:	75 11                	jne    801004d1 <getcmd+0x40>
801004c0:	a1 c8 5f 10 80       	mov    0x80105fc8,%eax
801004c5:	83 f8 04             	cmp    $0x4,%eax
801004c8:	75 07                	jne    801004d1 <getcmd+0x40>
	{		
	    return 1;
801004ca:	b8 01 00 00 00       	mov    $0x1,%eax
801004cf:	eb 4d                	jmp    8010051e <getcmd+0x8d>
	}else if((input.buf[0] == 'p')&&(input.buf[1] == 'r')&&(input.buf[2] == 'i')&&(input.buf[3] == 'n')&&(input.buf[4] == 't')&&(input.e == 5))
801004d1:	0f b6 05 40 5f 10 80 	movzbl 0x80105f40,%eax
801004d8:	3c 70                	cmp    $0x70,%al
801004da:	75 3d                	jne    80100519 <getcmd+0x88>
801004dc:	0f b6 05 41 5f 10 80 	movzbl 0x80105f41,%eax
801004e3:	3c 72                	cmp    $0x72,%al
801004e5:	75 32                	jne    80100519 <getcmd+0x88>
801004e7:	0f b6 05 42 5f 10 80 	movzbl 0x80105f42,%eax
801004ee:	3c 69                	cmp    $0x69,%al
801004f0:	75 27                	jne    80100519 <getcmd+0x88>
801004f2:	0f b6 05 43 5f 10 80 	movzbl 0x80105f43,%eax
801004f9:	3c 6e                	cmp    $0x6e,%al
801004fb:	75 1c                	jne    80100519 <getcmd+0x88>
801004fd:	0f b6 05 44 5f 10 80 	movzbl 0x80105f44,%eax
80100504:	3c 74                	cmp    $0x74,%al
80100506:	75 11                	jne    80100519 <getcmd+0x88>
80100508:	a1 c8 5f 10 80       	mov    0x80105fc8,%eax
8010050d:	83 f8 05             	cmp    $0x5,%eax
80100510:	75 07                	jne    80100519 <getcmd+0x88>
	{
	    return 2;
80100512:	b8 02 00 00 00       	mov    $0x2,%eax
80100517:	eb 05                	jmp    8010051e <getcmd+0x8d>
	}else return 0;
80100519:	b8 00 00 00 00       	mov    $0x0,%eax
}
8010051e:	5d                   	pop    %ebp
8010051f:	c3                   	ret    

80100520 <consoleintr>:

void
consoleintr(int (*getc)(void))
{
80100520:	55                   	push   %ebp
80100521:	89 e5                	mov    %esp,%ebp
80100523:	83 ec 18             	sub    $0x18,%esp
  int c;

  while((c = getc()) >= 0){
80100526:	e9 86 01 00 00       	jmp    801006b1 <consoleintr+0x191>
   switch(c){
8010052b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010052e:	83 f8 15             	cmp    $0x15,%eax
80100531:	74 29                	je     8010055c <consoleintr+0x3c>
80100533:	83 f8 7f             	cmp    $0x7f,%eax
80100536:	74 4e                	je     80100586 <consoleintr+0x66>
80100538:	83 f8 08             	cmp    $0x8,%eax
8010053b:	74 49                	je     80100586 <consoleintr+0x66>
8010053d:	eb 78                	jmp    801005b7 <consoleintr+0x97>
    case C('U'):  // Kill line.
      while(input.e != input.w &&
            input.buf[(input.e-1) % INPUT_BUF] != '\n'){
        input.e--;
8010053f:	a1 c8 5f 10 80       	mov    0x80105fc8,%eax
80100544:	83 e8 01             	sub    $0x1,%eax
80100547:	a3 c8 5f 10 80       	mov    %eax,0x80105fc8
        consputc(BACKSPACE);
8010054c:	83 ec 0c             	sub    $0xc,%esp
8010054f:	68 00 01 00 00       	push   $0x100
80100554:	e8 be fe ff ff       	call   80100417 <consputc>
80100559:	83 c4 10             	add    $0x10,%esp
  int c;

  while((c = getc()) >= 0){
   switch(c){
    case C('U'):  // Kill line.
      while(input.e != input.w &&
8010055c:	8b 15 c8 5f 10 80    	mov    0x80105fc8,%edx
80100562:	a1 c4 5f 10 80       	mov    0x80105fc4,%eax
80100567:	39 c2                	cmp    %eax,%edx
80100569:	74 16                	je     80100581 <consoleintr+0x61>
            input.buf[(input.e-1) % INPUT_BUF] != '\n'){
8010056b:	a1 c8 5f 10 80       	mov    0x80105fc8,%eax
80100570:	83 e8 01             	sub    $0x1,%eax
80100573:	83 e0 7f             	and    $0x7f,%eax
80100576:	0f b6 80 40 5f 10 80 	movzbl -0x7fefa0c0(%eax),%eax
  int c;

  while((c = getc()) >= 0){
   switch(c){
    case C('U'):  // Kill line.
      while(input.e != input.w &&
8010057d:	3c 0a                	cmp    $0xa,%al
8010057f:	75 be                	jne    8010053f <consoleintr+0x1f>
            input.buf[(input.e-1) % INPUT_BUF] != '\n'){
        input.e--;
        consputc(BACKSPACE);
      }
      break;
80100581:	e9 2b 01 00 00       	jmp    801006b1 <consoleintr+0x191>
    case C('H'): case '\x7f':  // Backspace
      if(input.e != input.w){
80100586:	8b 15 c8 5f 10 80    	mov    0x80105fc8,%edx
8010058c:	a1 c4 5f 10 80       	mov    0x80105fc4,%eax
80100591:	39 c2                	cmp    %eax,%edx
80100593:	74 1d                	je     801005b2 <consoleintr+0x92>
        input.e--;
80100595:	a1 c8 5f 10 80       	mov    0x80105fc8,%eax
8010059a:	83 e8 01             	sub    $0x1,%eax
8010059d:	a3 c8 5f 10 80       	mov    %eax,0x80105fc8
        consputc(BACKSPACE);
801005a2:	83 ec 0c             	sub    $0xc,%esp
801005a5:	68 00 01 00 00       	push   $0x100
801005aa:	e8 68 fe ff ff       	call   80100417 <consputc>
801005af:	83 c4 10             	add    $0x10,%esp
      }
      break;
801005b2:	e9 fa 00 00 00       	jmp    801006b1 <consoleintr+0x191>
    default:
      if(c != 0 && input.e-input.r < INPUT_BUF){
801005b7:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801005bb:	0f 84 ef 00 00 00    	je     801006b0 <consoleintr+0x190>
801005c1:	8b 15 c8 5f 10 80    	mov    0x80105fc8,%edx
801005c7:	a1 c0 5f 10 80       	mov    0x80105fc0,%eax
801005cc:	29 c2                	sub    %eax,%edx
801005ce:	89 d0                	mov    %edx,%eax
801005d0:	83 f8 7f             	cmp    $0x7f,%eax
801005d3:	0f 87 d7 00 00 00    	ja     801006b0 <consoleintr+0x190>
      	c = (c == '\r') ? '\n' : c;
801005d9:	83 7d f4 0d          	cmpl   $0xd,-0xc(%ebp)
801005dd:	74 05                	je     801005e4 <consoleintr+0xc4>
801005df:	8b 45 f4             	mov    -0xc(%ebp),%eax
801005e2:	eb 05                	jmp    801005e9 <consoleintr+0xc9>
801005e4:	b8 0a 00 00 00       	mov    $0xa,%eax
801005e9:	89 45 f4             	mov    %eax,-0xc(%ebp)
        if(c == '\n' || c == C('D') || input.e == input.r+INPUT_BUF){
801005ec:	83 7d f4 0a          	cmpl   $0xa,-0xc(%ebp)
801005f0:	74 18                	je     8010060a <consoleintr+0xea>
801005f2:	83 7d f4 04          	cmpl   $0x4,-0xc(%ebp)
801005f6:	74 12                	je     8010060a <consoleintr+0xea>
801005f8:	a1 c8 5f 10 80       	mov    0x80105fc8,%eax
801005fd:	8b 15 c0 5f 10 80    	mov    0x80105fc0,%edx
80100603:	83 ea 80             	sub    $0xffffff80,%edx
80100606:	39 d0                	cmp    %edx,%eax
80100608:	75 7e                	jne    80100688 <consoleintr+0x168>
 		consputc(c);	   
8010060a:	83 ec 0c             	sub    $0xc,%esp
8010060d:	ff 75 f4             	pushl  -0xc(%ebp)
80100610:	e8 02 fe ff ff       	call   80100417 <consputc>
80100615:	83 c4 10             	add    $0x10,%esp
		if(getcmd() == 1){
80100618:	e8 74 fe ff ff       	call   80100491 <getcmd>
8010061d:	83 f8 01             	cmp    $0x1,%eax
80100620:	75 17                	jne    80100639 <consoleintr+0x119>
		  cprintf("Building a process...\n");
80100622:	83 ec 0c             	sub    $0xc,%esp
80100625:	68 f3 22 10 80       	push   $0x801022f3
8010062a:	e8 80 fb ff ff       	call   801001af <cprintf>
8010062f:	83 c4 10             	add    $0x10,%esp
		  confirmalloc();
80100632:	e8 3d 0e 00 00       	call   80101474 <confirmalloc>
80100637:	eb 43                	jmp    8010067c <consoleintr+0x15c>

		}else if(getcmd() == 2){
80100639:	e8 53 fe ff ff       	call   80100491 <getcmd>
8010063e:	83 f8 02             	cmp    $0x2,%eax
80100641:	75 17                	jne    8010065a <consoleintr+0x13a>
		  cprintf("Showing the Process Table...\n");
80100643:	83 ec 0c             	sub    $0xc,%esp
80100646:	68 0a 23 10 80       	push   $0x8010230a
8010064b:	e8 5f fb ff ff       	call   801001af <cprintf>
80100650:	83 c4 10             	add    $0x10,%esp
		  printproc();
80100653:	e8 d2 0c 00 00       	call   8010132a <printproc>
80100658:	eb 22                	jmp    8010067c <consoleintr+0x15c>
		}else if(getcmd() == 0){
8010065a:	e8 32 fe ff ff       	call   80100491 <getcmd>
8010065f:	85 c0                	test   %eax,%eax
80100661:	75 19                	jne    8010067c <consoleintr+0x15c>
		    if(input.e!=0)
80100663:	a1 c8 5f 10 80       	mov    0x80105fc8,%eax
80100668:	85 c0                	test   %eax,%eax
8010066a:	74 10                	je     8010067c <consoleintr+0x15c>
		  	cprintf("Unknow command\n");
8010066c:	83 ec 0c             	sub    $0xc,%esp
8010066f:	68 28 23 10 80       	push   $0x80102328
80100674:	e8 36 fb ff ff       	call   801001af <cprintf>
80100679:	83 c4 10             	add    $0x10,%esp
		}
		input.e = 0;
8010067c:	c7 05 c8 5f 10 80 00 	movl   $0x0,0x80105fc8
80100683:	00 00 00 
80100686:	eb 28                	jmp    801006b0 <consoleintr+0x190>
	}
	else{	    
       	  input.buf[input.e++ % INPUT_BUF] = c;
80100688:	a1 c8 5f 10 80       	mov    0x80105fc8,%eax
8010068d:	8d 50 01             	lea    0x1(%eax),%edx
80100690:	89 15 c8 5f 10 80    	mov    %edx,0x80105fc8
80100696:	83 e0 7f             	and    $0x7f,%eax
80100699:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010069c:	88 90 40 5f 10 80    	mov    %dl,-0x7fefa0c0(%eax)
          consputc(c);
801006a2:	83 ec 0c             	sub    $0xc,%esp
801006a5:	ff 75 f4             	pushl  -0xc(%ebp)
801006a8:	e8 6a fd ff ff       	call   80100417 <consputc>
801006ad:	83 c4 10             	add    $0x10,%esp
        }
      }
      break;
801006b0:	90                   	nop
void
consoleintr(int (*getc)(void))
{
  int c;

  while((c = getc()) >= 0){
801006b1:	8b 45 08             	mov    0x8(%ebp),%eax
801006b4:	ff d0                	call   *%eax
801006b6:	89 45 f4             	mov    %eax,-0xc(%ebp)
801006b9:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801006bd:	0f 89 68 fe ff ff    	jns    8010052b <consoleintr+0xb>
        }
      }
      break;
    }
  }
}
801006c3:	c9                   	leave  
801006c4:	c3                   	ret    

801006c5 <stosb>:
               "cc");
}

static inline void
stosb(void *addr, int data, int cnt)
{
801006c5:	55                   	push   %ebp
801006c6:	89 e5                	mov    %esp,%ebp
801006c8:	57                   	push   %edi
801006c9:	53                   	push   %ebx
  asm volatile("cld; rep stosb" :
801006ca:	8b 4d 08             	mov    0x8(%ebp),%ecx
801006cd:	8b 55 10             	mov    0x10(%ebp),%edx
801006d0:	8b 45 0c             	mov    0xc(%ebp),%eax
801006d3:	89 cb                	mov    %ecx,%ebx
801006d5:	89 df                	mov    %ebx,%edi
801006d7:	89 d1                	mov    %edx,%ecx
801006d9:	fc                   	cld    
801006da:	f3 aa                	rep stos %al,%es:(%edi)
801006dc:	89 ca                	mov    %ecx,%edx
801006de:	89 fb                	mov    %edi,%ebx
801006e0:	89 5d 08             	mov    %ebx,0x8(%ebp)
801006e3:	89 55 10             	mov    %edx,0x10(%ebp)
               "=D" (addr), "=c" (cnt) :
               "0" (addr), "1" (cnt), "a" (data) :
               "memory", "cc");
}
801006e6:	5b                   	pop    %ebx
801006e7:	5f                   	pop    %edi
801006e8:	5d                   	pop    %ebp
801006e9:	c3                   	ret    

801006ea <stosl>:

static inline void
stosl(void *addr, int data, int cnt)
{
801006ea:	55                   	push   %ebp
801006eb:	89 e5                	mov    %esp,%ebp
801006ed:	57                   	push   %edi
801006ee:	53                   	push   %ebx
  asm volatile("cld; rep stosl" :
801006ef:	8b 4d 08             	mov    0x8(%ebp),%ecx
801006f2:	8b 55 10             	mov    0x10(%ebp),%edx
801006f5:	8b 45 0c             	mov    0xc(%ebp),%eax
801006f8:	89 cb                	mov    %ecx,%ebx
801006fa:	89 df                	mov    %ebx,%edi
801006fc:	89 d1                	mov    %edx,%ecx
801006fe:	fc                   	cld    
801006ff:	f3 ab                	rep stos %eax,%es:(%edi)
80100701:	89 ca                	mov    %ecx,%edx
80100703:	89 fb                	mov    %edi,%ebx
80100705:	89 5d 08             	mov    %ebx,0x8(%ebp)
80100708:	89 55 10             	mov    %edx,0x10(%ebp)
               "=D" (addr), "=c" (cnt) :
               "0" (addr), "1" (cnt), "a" (data) :
               "memory", "cc");
}
8010070b:	5b                   	pop    %ebx
8010070c:	5f                   	pop    %edi
8010070d:	5d                   	pop    %ebp
8010070e:	c3                   	ret    

8010070f <memset>:
#include "types.h"
#include "x86.h"

void*
memset(void *dst, int c, uint n)
{
8010070f:	55                   	push   %ebp
80100710:	89 e5                	mov    %esp,%ebp
  if ((int)dst%4 == 0 && n%4 == 0){
80100712:	8b 45 08             	mov    0x8(%ebp),%eax
80100715:	83 e0 03             	and    $0x3,%eax
80100718:	85 c0                	test   %eax,%eax
8010071a:	75 43                	jne    8010075f <memset+0x50>
8010071c:	8b 45 10             	mov    0x10(%ebp),%eax
8010071f:	83 e0 03             	and    $0x3,%eax
80100722:	85 c0                	test   %eax,%eax
80100724:	75 39                	jne    8010075f <memset+0x50>
    c &= 0xFF;
80100726:	81 65 0c ff 00 00 00 	andl   $0xff,0xc(%ebp)
    stosl(dst, (c<<24)|(c<<16)|(c<<8)|c, n/4);
8010072d:	8b 45 10             	mov    0x10(%ebp),%eax
80100730:	c1 e8 02             	shr    $0x2,%eax
80100733:	89 c1                	mov    %eax,%ecx
80100735:	8b 45 0c             	mov    0xc(%ebp),%eax
80100738:	c1 e0 18             	shl    $0x18,%eax
8010073b:	89 c2                	mov    %eax,%edx
8010073d:	8b 45 0c             	mov    0xc(%ebp),%eax
80100740:	c1 e0 10             	shl    $0x10,%eax
80100743:	09 c2                	or     %eax,%edx
80100745:	8b 45 0c             	mov    0xc(%ebp),%eax
80100748:	c1 e0 08             	shl    $0x8,%eax
8010074b:	09 d0                	or     %edx,%eax
8010074d:	0b 45 0c             	or     0xc(%ebp),%eax
80100750:	51                   	push   %ecx
80100751:	50                   	push   %eax
80100752:	ff 75 08             	pushl  0x8(%ebp)
80100755:	e8 90 ff ff ff       	call   801006ea <stosl>
8010075a:	83 c4 0c             	add    $0xc,%esp
8010075d:	eb 12                	jmp    80100771 <memset+0x62>
  } else
    stosb(dst, c, n);
8010075f:	8b 45 10             	mov    0x10(%ebp),%eax
80100762:	50                   	push   %eax
80100763:	ff 75 0c             	pushl  0xc(%ebp)
80100766:	ff 75 08             	pushl  0x8(%ebp)
80100769:	e8 57 ff ff ff       	call   801006c5 <stosb>
8010076e:	83 c4 0c             	add    $0xc,%esp
  return dst;
80100771:	8b 45 08             	mov    0x8(%ebp),%eax
}
80100774:	c9                   	leave  
80100775:	c3                   	ret    

80100776 <kfree>:


extern char end[]; // first address after kernel loaded from ELF file

void kfree(char *v)
{
80100776:	55                   	push   %ebp
80100777:	89 e5                	mov    %esp,%ebp
80100779:	83 ec 18             	sub    $0x18,%esp
  struct run *r;

  memset(v, 1, PGSIZE);
8010077c:	83 ec 04             	sub    $0x4,%esp
8010077f:	68 00 10 00 00       	push   $0x1000
80100784:	6a 01                	push   $0x1
80100786:	ff 75 08             	pushl  0x8(%ebp)
80100789:	e8 81 ff ff ff       	call   8010070f <memset>
8010078e:	83 c4 10             	add    $0x10,%esp

  r = (struct run*)v;
80100791:	8b 45 08             	mov    0x8(%ebp),%eax
80100794:	89 45 f4             	mov    %eax,-0xc(%ebp)
  r->next = kmem.freelist;
80100797:	8b 15 44 61 10 80    	mov    0x80106144,%edx
8010079d:	8b 45 f4             	mov    -0xc(%ebp),%eax
801007a0:	89 10                	mov    %edx,(%eax)
  kmem.freelist = r;
801007a2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801007a5:	a3 44 61 10 80       	mov    %eax,0x80106144

}
801007aa:	c9                   	leave  
801007ab:	c3                   	ret    

801007ac <freerange>:

void freerange(void *vstart, void *vend)
{
801007ac:	55                   	push   %ebp
801007ad:	89 e5                	mov    %esp,%ebp
801007af:	83 ec 18             	sub    $0x18,%esp
  char *p;
  p = (char*)PGROUNDUP((uint)vstart);
801007b2:	8b 45 08             	mov    0x8(%ebp),%eax
801007b5:	05 ff 0f 00 00       	add    $0xfff,%eax
801007ba:	25 00 f0 ff ff       	and    $0xfffff000,%eax
801007bf:	89 45 f4             	mov    %eax,-0xc(%ebp)
  for(; p + PGSIZE <= (char*)vend; p += PGSIZE)
801007c2:	eb 15                	jmp    801007d9 <freerange+0x2d>
    kfree(p);
801007c4:	83 ec 0c             	sub    $0xc,%esp
801007c7:	ff 75 f4             	pushl  -0xc(%ebp)
801007ca:	e8 a7 ff ff ff       	call   80100776 <kfree>
801007cf:	83 c4 10             	add    $0x10,%esp

void freerange(void *vstart, void *vend)
{
  char *p;
  p = (char*)PGROUNDUP((uint)vstart);
  for(; p + PGSIZE <= (char*)vend; p += PGSIZE)
801007d2:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
801007d9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801007dc:	05 00 10 00 00       	add    $0x1000,%eax
801007e1:	3b 45 0c             	cmp    0xc(%ebp),%eax
801007e4:	76 de                	jbe    801007c4 <freerange+0x18>
    kfree(p);
}
801007e6:	c9                   	leave  
801007e7:	c3                   	ret    

801007e8 <kinit>:


void kinit(void *vstart, void *vend)
{
801007e8:	55                   	push   %ebp
801007e9:	89 e5                	mov    %esp,%ebp
801007eb:	83 ec 08             	sub    $0x8,%esp
  freerange(vstart, vend);
801007ee:	83 ec 08             	sub    $0x8,%esp
801007f1:	ff 75 0c             	pushl  0xc(%ebp)
801007f4:	ff 75 08             	pushl  0x8(%ebp)
801007f7:	e8 b0 ff ff ff       	call   801007ac <freerange>
801007fc:	83 c4 10             	add    $0x10,%esp
}
801007ff:	c9                   	leave  
80100800:	c3                   	ret    

80100801 <kalloc>:

//分配一个4096字节的物理内存页，返回内核可以使用的指针。如果无法分配，则返回0
char* kalloc(void)
{
80100801:	55                   	push   %ebp
80100802:	89 e5                	mov    %esp,%ebp
80100804:	83 ec 10             	sub    $0x10,%esp
  struct run *r;
  r = kmem.freelist;
80100807:	a1 44 61 10 80       	mov    0x80106144,%eax
8010080c:	89 45 fc             	mov    %eax,-0x4(%ebp)
  if(r)
8010080f:	83 7d fc 00          	cmpl   $0x0,-0x4(%ebp)
80100813:	74 0a                	je     8010081f <kalloc+0x1e>
    kmem.freelist = r->next;
80100815:	8b 45 fc             	mov    -0x4(%ebp),%eax
80100818:	8b 00                	mov    (%eax),%eax
8010081a:	a3 44 61 10 80       	mov    %eax,0x80106144
  return (char*)r;
8010081f:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80100822:	c9                   	leave  
80100823:	c3                   	ret    

80100824 <inb>:
// Routines to let C code use special x86 instructions.

static inline uchar
inb(ushort port)
{
80100824:	55                   	push   %ebp
80100825:	89 e5                	mov    %esp,%ebp
80100827:	83 ec 14             	sub    $0x14,%esp
8010082a:	8b 45 08             	mov    0x8(%ebp),%eax
8010082d:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
  uchar data;

  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80100831:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
80100835:	89 c2                	mov    %eax,%edx
80100837:	ec                   	in     (%dx),%al
80100838:	88 45 ff             	mov    %al,-0x1(%ebp)
  return data;
8010083b:	0f b6 45 ff          	movzbl -0x1(%ebp),%eax
}
8010083f:	c9                   	leave  
80100840:	c3                   	ret    

80100841 <kbdgetc>:
#include "defs.h"
#include "kbd.h"

int
kbdgetc(void)
{
80100841:	55                   	push   %ebp
80100842:	89 e5                	mov    %esp,%ebp
80100844:	83 ec 10             	sub    $0x10,%esp
  static uchar *charcode[4] = {
    normalmap, shiftmap, ctlmap, ctlmap
  };
  uint st, data, c;

  st = inb(KBSTATP);
80100847:	6a 64                	push   $0x64
80100849:	e8 d6 ff ff ff       	call   80100824 <inb>
8010084e:	83 c4 04             	add    $0x4,%esp
80100851:	0f b6 c0             	movzbl %al,%eax
80100854:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if((st & KBS_DIB) == 0)
80100857:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010085a:	83 e0 01             	and    $0x1,%eax
8010085d:	85 c0                	test   %eax,%eax
8010085f:	75 0a                	jne    8010086b <kbdgetc+0x2a>
    return -1;
80100861:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80100866:	e9 23 01 00 00       	jmp    8010098e <kbdgetc+0x14d>
  data = inb(KBDATAP);
8010086b:	6a 60                	push   $0x60
8010086d:	e8 b2 ff ff ff       	call   80100824 <inb>
80100872:	83 c4 04             	add    $0x4,%esp
80100875:	0f b6 c0             	movzbl %al,%eax
80100878:	89 45 fc             	mov    %eax,-0x4(%ebp)

  if(data == 0xE0){
8010087b:	81 7d fc e0 00 00 00 	cmpl   $0xe0,-0x4(%ebp)
80100882:	75 17                	jne    8010089b <kbdgetc+0x5a>
    shift |= E0ESC;
80100884:	a1 00 4f 10 80       	mov    0x80104f00,%eax
80100889:	83 c8 40             	or     $0x40,%eax
8010088c:	a3 00 4f 10 80       	mov    %eax,0x80104f00
    return 0;
80100891:	b8 00 00 00 00       	mov    $0x0,%eax
80100896:	e9 f3 00 00 00       	jmp    8010098e <kbdgetc+0x14d>
  } else if(data & 0x80){
8010089b:	8b 45 fc             	mov    -0x4(%ebp),%eax
8010089e:	25 80 00 00 00       	and    $0x80,%eax
801008a3:	85 c0                	test   %eax,%eax
801008a5:	74 45                	je     801008ec <kbdgetc+0xab>
    // Key released
    data = (shift & E0ESC ? data : data & 0x7F);
801008a7:	a1 00 4f 10 80       	mov    0x80104f00,%eax
801008ac:	83 e0 40             	and    $0x40,%eax
801008af:	85 c0                	test   %eax,%eax
801008b1:	75 08                	jne    801008bb <kbdgetc+0x7a>
801008b3:	8b 45 fc             	mov    -0x4(%ebp),%eax
801008b6:	83 e0 7f             	and    $0x7f,%eax
801008b9:	eb 03                	jmp    801008be <kbdgetc+0x7d>
801008bb:	8b 45 fc             	mov    -0x4(%ebp),%eax
801008be:	89 45 fc             	mov    %eax,-0x4(%ebp)
    shift &= ~(shiftcode[data] | E0ESC);
801008c1:	8b 45 fc             	mov    -0x4(%ebp),%eax
801008c4:	05 40 40 10 80       	add    $0x80104040,%eax
801008c9:	0f b6 00             	movzbl (%eax),%eax
801008cc:	83 c8 40             	or     $0x40,%eax
801008cf:	0f b6 c0             	movzbl %al,%eax
801008d2:	f7 d0                	not    %eax
801008d4:	89 c2                	mov    %eax,%edx
801008d6:	a1 00 4f 10 80       	mov    0x80104f00,%eax
801008db:	21 d0                	and    %edx,%eax
801008dd:	a3 00 4f 10 80       	mov    %eax,0x80104f00
    return 0;
801008e2:	b8 00 00 00 00       	mov    $0x0,%eax
801008e7:	e9 a2 00 00 00       	jmp    8010098e <kbdgetc+0x14d>
  } else if(shift & E0ESC){
801008ec:	a1 00 4f 10 80       	mov    0x80104f00,%eax
801008f1:	83 e0 40             	and    $0x40,%eax
801008f4:	85 c0                	test   %eax,%eax
801008f6:	74 14                	je     8010090c <kbdgetc+0xcb>
    // Last character was an E0 escape; or with 0x80
    data |= 0x80;
801008f8:	81 4d fc 80 00 00 00 	orl    $0x80,-0x4(%ebp)
    shift &= ~E0ESC;
801008ff:	a1 00 4f 10 80       	mov    0x80104f00,%eax
80100904:	83 e0 bf             	and    $0xffffffbf,%eax
80100907:	a3 00 4f 10 80       	mov    %eax,0x80104f00
  }

  shift |= shiftcode[data];
8010090c:	8b 45 fc             	mov    -0x4(%ebp),%eax
8010090f:	05 40 40 10 80       	add    $0x80104040,%eax
80100914:	0f b6 00             	movzbl (%eax),%eax
80100917:	0f b6 d0             	movzbl %al,%edx
8010091a:	a1 00 4f 10 80       	mov    0x80104f00,%eax
8010091f:	09 d0                	or     %edx,%eax
80100921:	a3 00 4f 10 80       	mov    %eax,0x80104f00
  shift ^= togglecode[data];
80100926:	8b 45 fc             	mov    -0x4(%ebp),%eax
80100929:	05 40 41 10 80       	add    $0x80104140,%eax
8010092e:	0f b6 00             	movzbl (%eax),%eax
80100931:	0f b6 d0             	movzbl %al,%edx
80100934:	a1 00 4f 10 80       	mov    0x80104f00,%eax
80100939:	31 d0                	xor    %edx,%eax
8010093b:	a3 00 4f 10 80       	mov    %eax,0x80104f00
  c = charcode[shift & (CTL | SHIFT)][data];
80100940:	a1 00 4f 10 80       	mov    0x80104f00,%eax
80100945:	83 e0 03             	and    $0x3,%eax
80100948:	8b 14 85 40 45 10 80 	mov    -0x7fefbac0(,%eax,4),%edx
8010094f:	8b 45 fc             	mov    -0x4(%ebp),%eax
80100952:	01 d0                	add    %edx,%eax
80100954:	0f b6 00             	movzbl (%eax),%eax
80100957:	0f b6 c0             	movzbl %al,%eax
8010095a:	89 45 f8             	mov    %eax,-0x8(%ebp)
  if(shift & CAPSLOCK){
8010095d:	a1 00 4f 10 80       	mov    0x80104f00,%eax
80100962:	83 e0 08             	and    $0x8,%eax
80100965:	85 c0                	test   %eax,%eax
80100967:	74 22                	je     8010098b <kbdgetc+0x14a>
    if('a' <= c && c <= 'z')
80100969:	83 7d f8 60          	cmpl   $0x60,-0x8(%ebp)
8010096d:	76 0c                	jbe    8010097b <kbdgetc+0x13a>
8010096f:	83 7d f8 7a          	cmpl   $0x7a,-0x8(%ebp)
80100973:	77 06                	ja     8010097b <kbdgetc+0x13a>
      c += 'A' - 'a';
80100975:	83 6d f8 20          	subl   $0x20,-0x8(%ebp)
80100979:	eb 10                	jmp    8010098b <kbdgetc+0x14a>
    else if('A' <= c && c <= 'Z')
8010097b:	83 7d f8 40          	cmpl   $0x40,-0x8(%ebp)
8010097f:	76 0a                	jbe    8010098b <kbdgetc+0x14a>
80100981:	83 7d f8 5a          	cmpl   $0x5a,-0x8(%ebp)
80100985:	77 04                	ja     8010098b <kbdgetc+0x14a>
      c += 'a' - 'A';
80100987:	83 45 f8 20          	addl   $0x20,-0x8(%ebp)
  }
  return c;
8010098b:	8b 45 f8             	mov    -0x8(%ebp),%eax
}
8010098e:	c9                   	leave  
8010098f:	c3                   	ret    

80100990 <kbdintr>:

void
kbdintr(void)
{
80100990:	55                   	push   %ebp
80100991:	89 e5                	mov    %esp,%ebp
80100993:	83 ec 08             	sub    $0x8,%esp
  consoleintr(kbdgetc);
80100996:	83 ec 0c             	sub    $0xc,%esp
80100999:	68 41 08 10 80       	push   $0x80100841
8010099e:	e8 7d fb ff ff       	call   80100520 <consoleintr>
801009a3:	83 c4 10             	add    $0x10,%esp
}
801009a6:	c9                   	leave  
801009a7:	c3                   	ret    

801009a8 <lgdt>:

struct segdesc;

static inline void
lgdt(struct segdesc *p, int size)
{
801009a8:	55                   	push   %ebp
801009a9:	89 e5                	mov    %esp,%ebp
801009ab:	83 ec 10             	sub    $0x10,%esp
  volatile ushort pd[3];

  pd[0] = size-1;
801009ae:	8b 45 0c             	mov    0xc(%ebp),%eax
801009b1:	83 e8 01             	sub    $0x1,%eax
801009b4:	66 89 45 fa          	mov    %ax,-0x6(%ebp)
  pd[1] = (uint)p;
801009b8:	8b 45 08             	mov    0x8(%ebp),%eax
801009bb:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  pd[2] = (uint)p >> 16;
801009bf:	8b 45 08             	mov    0x8(%ebp),%eax
801009c2:	c1 e8 10             	shr    $0x10,%eax
801009c5:	66 89 45 fe          	mov    %ax,-0x2(%ebp)

  asm volatile("lgdt (%0)" : : "r" (pd));
801009c9:	8d 45 fa             	lea    -0x6(%ebp),%eax
801009cc:	0f 01 10             	lgdtl  (%eax)
}
801009cf:	c9                   	leave  
801009d0:	c3                   	ret    

801009d1 <loadgs>:
  return eflags;
}

static inline void
loadgs(ushort v)
{
801009d1:	55                   	push   %ebp
801009d2:	89 e5                	mov    %esp,%ebp
801009d4:	83 ec 04             	sub    $0x4,%esp
801009d7:	8b 45 08             	mov    0x8(%ebp),%eax
801009da:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  asm volatile("movw %0, %%gs" : : "r" (v));
801009de:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
801009e2:	8e e8                	mov    %eax,%gs
}
801009e4:	c9                   	leave  
801009e5:	c3                   	ret    

801009e6 <lcr3>:
  return val;
}

static inline void
lcr3(uint val) 
{
801009e6:	55                   	push   %ebp
801009e7:	89 e5                	mov    %esp,%ebp
  asm volatile("movl %0,%%cr3" : : "r" (val));
801009e9:	8b 45 08             	mov    0x8(%ebp),%eax
801009ec:	0f 22 d8             	mov    %eax,%cr3
}
801009ef:	5d                   	pop    %ebp
801009f0:	c3                   	ret    

801009f1 <v2p>:
#define KERNBASE 0x80000000         // 第一个内核虚拟内存
#define KERNLINK (KERNBASE+EXTMEM)  // 内核被链接的地址

#ifndef __ASSEMBLER__

static inline uint v2p(void *a) { return ((uint) (a))  - KERNBASE; }
801009f1:	55                   	push   %ebp
801009f2:	89 e5                	mov    %esp,%ebp
801009f4:	8b 45 08             	mov    0x8(%ebp),%eax
801009f7:	05 00 00 00 80       	add    $0x80000000,%eax
801009fc:	5d                   	pop    %ebp
801009fd:	c3                   	ret    

801009fe <p2v>:
static inline void *p2v(uint a) { return (void *) ((a) + KERNBASE); }
801009fe:	55                   	push   %ebp
801009ff:	89 e5                	mov    %esp,%ebp
80100a01:	8b 45 08             	mov    0x8(%ebp),%eax
80100a04:	05 00 00 00 80       	add    $0x80000000,%eax
80100a09:	5d                   	pop    %ebp
80100a0a:	c3                   	ret    

80100a0b <seginit>:
struct cpu cpus[1];
extern char data[];  // 由kernel.ld来定义
pde_t *kpgdir;  // 被进程调度所使用(以后)

void seginit(void)
{
80100a0b:	55                   	push   %ebp
80100a0c:	89 e5                	mov    %esp,%ebp
80100a0e:	53                   	push   %ebx
80100a0f:	83 ec 10             	sub    $0x10,%esp
  struct cpu *c;
  c = &cpus[0]; 
80100a12:	c7 45 f8 80 61 10 80 	movl   $0x80106180,-0x8(%ebp)
  c->gdt[SEG_KCODE] = SEG(STA_X|STA_R, 0, 0xffffffff, 0);        
80100a19:	8b 45 f8             	mov    -0x8(%ebp),%eax
80100a1c:	66 c7 40 08 ff ff    	movw   $0xffff,0x8(%eax)
80100a22:	8b 45 f8             	mov    -0x8(%ebp),%eax
80100a25:	66 c7 40 0a 00 00    	movw   $0x0,0xa(%eax)
80100a2b:	8b 45 f8             	mov    -0x8(%ebp),%eax
80100a2e:	c6 40 0c 00          	movb   $0x0,0xc(%eax)
80100a32:	8b 45 f8             	mov    -0x8(%ebp),%eax
80100a35:	0f b6 50 0d          	movzbl 0xd(%eax),%edx
80100a39:	83 e2 f0             	and    $0xfffffff0,%edx
80100a3c:	83 ca 0a             	or     $0xa,%edx
80100a3f:	88 50 0d             	mov    %dl,0xd(%eax)
80100a42:	8b 45 f8             	mov    -0x8(%ebp),%eax
80100a45:	0f b6 50 0d          	movzbl 0xd(%eax),%edx
80100a49:	83 ca 10             	or     $0x10,%edx
80100a4c:	88 50 0d             	mov    %dl,0xd(%eax)
80100a4f:	8b 45 f8             	mov    -0x8(%ebp),%eax
80100a52:	0f b6 50 0d          	movzbl 0xd(%eax),%edx
80100a56:	83 e2 9f             	and    $0xffffff9f,%edx
80100a59:	88 50 0d             	mov    %dl,0xd(%eax)
80100a5c:	8b 45 f8             	mov    -0x8(%ebp),%eax
80100a5f:	0f b6 50 0d          	movzbl 0xd(%eax),%edx
80100a63:	83 ca 80             	or     $0xffffff80,%edx
80100a66:	88 50 0d             	mov    %dl,0xd(%eax)
80100a69:	8b 45 f8             	mov    -0x8(%ebp),%eax
80100a6c:	0f b6 50 0e          	movzbl 0xe(%eax),%edx
80100a70:	83 ca 0f             	or     $0xf,%edx
80100a73:	88 50 0e             	mov    %dl,0xe(%eax)
80100a76:	8b 45 f8             	mov    -0x8(%ebp),%eax
80100a79:	0f b6 50 0e          	movzbl 0xe(%eax),%edx
80100a7d:	83 e2 ef             	and    $0xffffffef,%edx
80100a80:	88 50 0e             	mov    %dl,0xe(%eax)
80100a83:	8b 45 f8             	mov    -0x8(%ebp),%eax
80100a86:	0f b6 50 0e          	movzbl 0xe(%eax),%edx
80100a8a:	83 e2 df             	and    $0xffffffdf,%edx
80100a8d:	88 50 0e             	mov    %dl,0xe(%eax)
80100a90:	8b 45 f8             	mov    -0x8(%ebp),%eax
80100a93:	0f b6 50 0e          	movzbl 0xe(%eax),%edx
80100a97:	83 ca 40             	or     $0x40,%edx
80100a9a:	88 50 0e             	mov    %dl,0xe(%eax)
80100a9d:	8b 45 f8             	mov    -0x8(%ebp),%eax
80100aa0:	0f b6 50 0e          	movzbl 0xe(%eax),%edx
80100aa4:	83 ca 80             	or     $0xffffff80,%edx
80100aa7:	88 50 0e             	mov    %dl,0xe(%eax)
80100aaa:	8b 45 f8             	mov    -0x8(%ebp),%eax
80100aad:	c6 40 0f 00          	movb   $0x0,0xf(%eax)
  c->gdt[SEG_KDATA] = SEG(STA_W, 0, 0xffffffff, 0);
80100ab1:	8b 45 f8             	mov    -0x8(%ebp),%eax
80100ab4:	66 c7 40 10 ff ff    	movw   $0xffff,0x10(%eax)
80100aba:	8b 45 f8             	mov    -0x8(%ebp),%eax
80100abd:	66 c7 40 12 00 00    	movw   $0x0,0x12(%eax)
80100ac3:	8b 45 f8             	mov    -0x8(%ebp),%eax
80100ac6:	c6 40 14 00          	movb   $0x0,0x14(%eax)
80100aca:	8b 45 f8             	mov    -0x8(%ebp),%eax
80100acd:	0f b6 50 15          	movzbl 0x15(%eax),%edx
80100ad1:	83 e2 f0             	and    $0xfffffff0,%edx
80100ad4:	83 ca 02             	or     $0x2,%edx
80100ad7:	88 50 15             	mov    %dl,0x15(%eax)
80100ada:	8b 45 f8             	mov    -0x8(%ebp),%eax
80100add:	0f b6 50 15          	movzbl 0x15(%eax),%edx
80100ae1:	83 ca 10             	or     $0x10,%edx
80100ae4:	88 50 15             	mov    %dl,0x15(%eax)
80100ae7:	8b 45 f8             	mov    -0x8(%ebp),%eax
80100aea:	0f b6 50 15          	movzbl 0x15(%eax),%edx
80100aee:	83 e2 9f             	and    $0xffffff9f,%edx
80100af1:	88 50 15             	mov    %dl,0x15(%eax)
80100af4:	8b 45 f8             	mov    -0x8(%ebp),%eax
80100af7:	0f b6 50 15          	movzbl 0x15(%eax),%edx
80100afb:	83 ca 80             	or     $0xffffff80,%edx
80100afe:	88 50 15             	mov    %dl,0x15(%eax)
80100b01:	8b 45 f8             	mov    -0x8(%ebp),%eax
80100b04:	0f b6 50 16          	movzbl 0x16(%eax),%edx
80100b08:	83 ca 0f             	or     $0xf,%edx
80100b0b:	88 50 16             	mov    %dl,0x16(%eax)
80100b0e:	8b 45 f8             	mov    -0x8(%ebp),%eax
80100b11:	0f b6 50 16          	movzbl 0x16(%eax),%edx
80100b15:	83 e2 ef             	and    $0xffffffef,%edx
80100b18:	88 50 16             	mov    %dl,0x16(%eax)
80100b1b:	8b 45 f8             	mov    -0x8(%ebp),%eax
80100b1e:	0f b6 50 16          	movzbl 0x16(%eax),%edx
80100b22:	83 e2 df             	and    $0xffffffdf,%edx
80100b25:	88 50 16             	mov    %dl,0x16(%eax)
80100b28:	8b 45 f8             	mov    -0x8(%ebp),%eax
80100b2b:	0f b6 50 16          	movzbl 0x16(%eax),%edx
80100b2f:	83 ca 40             	or     $0x40,%edx
80100b32:	88 50 16             	mov    %dl,0x16(%eax)
80100b35:	8b 45 f8             	mov    -0x8(%ebp),%eax
80100b38:	0f b6 50 16          	movzbl 0x16(%eax),%edx
80100b3c:	83 ca 80             	or     $0xffffff80,%edx
80100b3f:	88 50 16             	mov    %dl,0x16(%eax)
80100b42:	8b 45 f8             	mov    -0x8(%ebp),%eax
80100b45:	c6 40 17 00          	movb   $0x0,0x17(%eax)
  c->gdt[SEG_UCODE] = SEG(STA_X|STA_R, 0, 0xffffffff, DPL_USER);
80100b49:	8b 45 f8             	mov    -0x8(%ebp),%eax
80100b4c:	66 c7 40 20 ff ff    	movw   $0xffff,0x20(%eax)
80100b52:	8b 45 f8             	mov    -0x8(%ebp),%eax
80100b55:	66 c7 40 22 00 00    	movw   $0x0,0x22(%eax)
80100b5b:	8b 45 f8             	mov    -0x8(%ebp),%eax
80100b5e:	c6 40 24 00          	movb   $0x0,0x24(%eax)
80100b62:	8b 45 f8             	mov    -0x8(%ebp),%eax
80100b65:	0f b6 50 25          	movzbl 0x25(%eax),%edx
80100b69:	83 e2 f0             	and    $0xfffffff0,%edx
80100b6c:	83 ca 0a             	or     $0xa,%edx
80100b6f:	88 50 25             	mov    %dl,0x25(%eax)
80100b72:	8b 45 f8             	mov    -0x8(%ebp),%eax
80100b75:	0f b6 50 25          	movzbl 0x25(%eax),%edx
80100b79:	83 ca 10             	or     $0x10,%edx
80100b7c:	88 50 25             	mov    %dl,0x25(%eax)
80100b7f:	8b 45 f8             	mov    -0x8(%ebp),%eax
80100b82:	0f b6 50 25          	movzbl 0x25(%eax),%edx
80100b86:	83 ca 60             	or     $0x60,%edx
80100b89:	88 50 25             	mov    %dl,0x25(%eax)
80100b8c:	8b 45 f8             	mov    -0x8(%ebp),%eax
80100b8f:	0f b6 50 25          	movzbl 0x25(%eax),%edx
80100b93:	83 ca 80             	or     $0xffffff80,%edx
80100b96:	88 50 25             	mov    %dl,0x25(%eax)
80100b99:	8b 45 f8             	mov    -0x8(%ebp),%eax
80100b9c:	0f b6 50 26          	movzbl 0x26(%eax),%edx
80100ba0:	83 ca 0f             	or     $0xf,%edx
80100ba3:	88 50 26             	mov    %dl,0x26(%eax)
80100ba6:	8b 45 f8             	mov    -0x8(%ebp),%eax
80100ba9:	0f b6 50 26          	movzbl 0x26(%eax),%edx
80100bad:	83 e2 ef             	and    $0xffffffef,%edx
80100bb0:	88 50 26             	mov    %dl,0x26(%eax)
80100bb3:	8b 45 f8             	mov    -0x8(%ebp),%eax
80100bb6:	0f b6 50 26          	movzbl 0x26(%eax),%edx
80100bba:	83 e2 df             	and    $0xffffffdf,%edx
80100bbd:	88 50 26             	mov    %dl,0x26(%eax)
80100bc0:	8b 45 f8             	mov    -0x8(%ebp),%eax
80100bc3:	0f b6 50 26          	movzbl 0x26(%eax),%edx
80100bc7:	83 ca 40             	or     $0x40,%edx
80100bca:	88 50 26             	mov    %dl,0x26(%eax)
80100bcd:	8b 45 f8             	mov    -0x8(%ebp),%eax
80100bd0:	0f b6 50 26          	movzbl 0x26(%eax),%edx
80100bd4:	83 ca 80             	or     $0xffffff80,%edx
80100bd7:	88 50 26             	mov    %dl,0x26(%eax)
80100bda:	8b 45 f8             	mov    -0x8(%ebp),%eax
80100bdd:	c6 40 27 00          	movb   $0x0,0x27(%eax)
  c->gdt[SEG_UDATA] = SEG(STA_W, 0, 0xffffffff, DPL_USER);
80100be1:	8b 45 f8             	mov    -0x8(%ebp),%eax
80100be4:	66 c7 40 28 ff ff    	movw   $0xffff,0x28(%eax)
80100bea:	8b 45 f8             	mov    -0x8(%ebp),%eax
80100bed:	66 c7 40 2a 00 00    	movw   $0x0,0x2a(%eax)
80100bf3:	8b 45 f8             	mov    -0x8(%ebp),%eax
80100bf6:	c6 40 2c 00          	movb   $0x0,0x2c(%eax)
80100bfa:	8b 45 f8             	mov    -0x8(%ebp),%eax
80100bfd:	0f b6 50 2d          	movzbl 0x2d(%eax),%edx
80100c01:	83 e2 f0             	and    $0xfffffff0,%edx
80100c04:	83 ca 02             	or     $0x2,%edx
80100c07:	88 50 2d             	mov    %dl,0x2d(%eax)
80100c0a:	8b 45 f8             	mov    -0x8(%ebp),%eax
80100c0d:	0f b6 50 2d          	movzbl 0x2d(%eax),%edx
80100c11:	83 ca 10             	or     $0x10,%edx
80100c14:	88 50 2d             	mov    %dl,0x2d(%eax)
80100c17:	8b 45 f8             	mov    -0x8(%ebp),%eax
80100c1a:	0f b6 50 2d          	movzbl 0x2d(%eax),%edx
80100c1e:	83 ca 60             	or     $0x60,%edx
80100c21:	88 50 2d             	mov    %dl,0x2d(%eax)
80100c24:	8b 45 f8             	mov    -0x8(%ebp),%eax
80100c27:	0f b6 50 2d          	movzbl 0x2d(%eax),%edx
80100c2b:	83 ca 80             	or     $0xffffff80,%edx
80100c2e:	88 50 2d             	mov    %dl,0x2d(%eax)
80100c31:	8b 45 f8             	mov    -0x8(%ebp),%eax
80100c34:	0f b6 50 2e          	movzbl 0x2e(%eax),%edx
80100c38:	83 ca 0f             	or     $0xf,%edx
80100c3b:	88 50 2e             	mov    %dl,0x2e(%eax)
80100c3e:	8b 45 f8             	mov    -0x8(%ebp),%eax
80100c41:	0f b6 50 2e          	movzbl 0x2e(%eax),%edx
80100c45:	83 e2 ef             	and    $0xffffffef,%edx
80100c48:	88 50 2e             	mov    %dl,0x2e(%eax)
80100c4b:	8b 45 f8             	mov    -0x8(%ebp),%eax
80100c4e:	0f b6 50 2e          	movzbl 0x2e(%eax),%edx
80100c52:	83 e2 df             	and    $0xffffffdf,%edx
80100c55:	88 50 2e             	mov    %dl,0x2e(%eax)
80100c58:	8b 45 f8             	mov    -0x8(%ebp),%eax
80100c5b:	0f b6 50 2e          	movzbl 0x2e(%eax),%edx
80100c5f:	83 ca 40             	or     $0x40,%edx
80100c62:	88 50 2e             	mov    %dl,0x2e(%eax)
80100c65:	8b 45 f8             	mov    -0x8(%ebp),%eax
80100c68:	0f b6 50 2e          	movzbl 0x2e(%eax),%edx
80100c6c:	83 ca 80             	or     $0xffffff80,%edx
80100c6f:	88 50 2e             	mov    %dl,0x2e(%eax)
80100c72:	8b 45 f8             	mov    -0x8(%ebp),%eax
80100c75:	c6 40 2f 00          	movb   $0x0,0x2f(%eax)
  
  c->gdt[SEG_KCPU] = SEG(STA_W, &c->cpu, 8, 0);
80100c79:	8b 45 f8             	mov    -0x8(%ebp),%eax
80100c7c:	83 c0 38             	add    $0x38,%eax
80100c7f:	89 c3                	mov    %eax,%ebx
80100c81:	8b 45 f8             	mov    -0x8(%ebp),%eax
80100c84:	83 c0 38             	add    $0x38,%eax
80100c87:	c1 e8 10             	shr    $0x10,%eax
80100c8a:	89 c2                	mov    %eax,%edx
80100c8c:	8b 45 f8             	mov    -0x8(%ebp),%eax
80100c8f:	83 c0 38             	add    $0x38,%eax
80100c92:	c1 e8 18             	shr    $0x18,%eax
80100c95:	89 c1                	mov    %eax,%ecx
80100c97:	8b 45 f8             	mov    -0x8(%ebp),%eax
80100c9a:	66 c7 40 18 00 00    	movw   $0x0,0x18(%eax)
80100ca0:	8b 45 f8             	mov    -0x8(%ebp),%eax
80100ca3:	66 89 58 1a          	mov    %bx,0x1a(%eax)
80100ca7:	8b 45 f8             	mov    -0x8(%ebp),%eax
80100caa:	88 50 1c             	mov    %dl,0x1c(%eax)
80100cad:	8b 45 f8             	mov    -0x8(%ebp),%eax
80100cb0:	0f b6 50 1d          	movzbl 0x1d(%eax),%edx
80100cb4:	83 e2 f0             	and    $0xfffffff0,%edx
80100cb7:	83 ca 02             	or     $0x2,%edx
80100cba:	88 50 1d             	mov    %dl,0x1d(%eax)
80100cbd:	8b 45 f8             	mov    -0x8(%ebp),%eax
80100cc0:	0f b6 50 1d          	movzbl 0x1d(%eax),%edx
80100cc4:	83 ca 10             	or     $0x10,%edx
80100cc7:	88 50 1d             	mov    %dl,0x1d(%eax)
80100cca:	8b 45 f8             	mov    -0x8(%ebp),%eax
80100ccd:	0f b6 50 1d          	movzbl 0x1d(%eax),%edx
80100cd1:	83 e2 9f             	and    $0xffffff9f,%edx
80100cd4:	88 50 1d             	mov    %dl,0x1d(%eax)
80100cd7:	8b 45 f8             	mov    -0x8(%ebp),%eax
80100cda:	0f b6 50 1d          	movzbl 0x1d(%eax),%edx
80100cde:	83 ca 80             	or     $0xffffff80,%edx
80100ce1:	88 50 1d             	mov    %dl,0x1d(%eax)
80100ce4:	8b 45 f8             	mov    -0x8(%ebp),%eax
80100ce7:	0f b6 50 1e          	movzbl 0x1e(%eax),%edx
80100ceb:	83 e2 f0             	and    $0xfffffff0,%edx
80100cee:	88 50 1e             	mov    %dl,0x1e(%eax)
80100cf1:	8b 45 f8             	mov    -0x8(%ebp),%eax
80100cf4:	0f b6 50 1e          	movzbl 0x1e(%eax),%edx
80100cf8:	83 e2 ef             	and    $0xffffffef,%edx
80100cfb:	88 50 1e             	mov    %dl,0x1e(%eax)
80100cfe:	8b 45 f8             	mov    -0x8(%ebp),%eax
80100d01:	0f b6 50 1e          	movzbl 0x1e(%eax),%edx
80100d05:	83 e2 df             	and    $0xffffffdf,%edx
80100d08:	88 50 1e             	mov    %dl,0x1e(%eax)
80100d0b:	8b 45 f8             	mov    -0x8(%ebp),%eax
80100d0e:	0f b6 50 1e          	movzbl 0x1e(%eax),%edx
80100d12:	83 ca 40             	or     $0x40,%edx
80100d15:	88 50 1e             	mov    %dl,0x1e(%eax)
80100d18:	8b 45 f8             	mov    -0x8(%ebp),%eax
80100d1b:	0f b6 50 1e          	movzbl 0x1e(%eax),%edx
80100d1f:	83 ca 80             	or     $0xffffff80,%edx
80100d22:	88 50 1e             	mov    %dl,0x1e(%eax)
80100d25:	8b 45 f8             	mov    -0x8(%ebp),%eax
80100d28:	88 48 1f             	mov    %cl,0x1f(%eax)
  
  lgdt(c->gdt, sizeof(c->gdt));
80100d2b:	8b 45 f8             	mov    -0x8(%ebp),%eax
80100d2e:	6a 38                	push   $0x38
80100d30:	50                   	push   %eax
80100d31:	e8 72 fc ff ff       	call   801009a8 <lgdt>
80100d36:	83 c4 08             	add    $0x8,%esp
  loadgs(SEG_KCPU << 3);
80100d39:	6a 18                	push   $0x18
80100d3b:	e8 91 fc ff ff       	call   801009d1 <loadgs>
80100d40:	83 c4 04             	add    $0x4,%esp
  
  cpu = c;
80100d43:	8b 45 f8             	mov    -0x8(%ebp),%eax
80100d46:	65 a3 00 00 00 00    	mov    %eax,%gs:0x0
}
80100d4c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80100d4f:	c9                   	leave  
80100d50:	c3                   	ret    

80100d51 <segshow>:


void segshow(){
80100d51:	55                   	push   %ebp
80100d52:	89 e5                	mov    %esp,%ebp
80100d54:	83 ec 08             	sub    $0x8,%esp

  cprintf("Kernel code segment's address bit 31~24 : %d\n",cpu->gdt[SEG_KCODE].base_31_24);
80100d57:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80100d5d:	0f b6 40 0f          	movzbl 0xf(%eax),%eax
80100d61:	0f b6 c0             	movzbl %al,%eax
80100d64:	83 ec 08             	sub    $0x8,%esp
80100d67:	50                   	push   %eax
80100d68:	68 38 23 10 80       	push   $0x80102338
80100d6d:	e8 3d f4 ff ff       	call   801001af <cprintf>
80100d72:	83 c4 10             	add    $0x10,%esp
  cprintf("Kernel code segment's address bit 23~16 : %d\n",cpu->gdt[SEG_KCODE].base_23_16);
80100d75:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80100d7b:	0f b6 40 0c          	movzbl 0xc(%eax),%eax
80100d7f:	0f b6 c0             	movzbl %al,%eax
80100d82:	83 ec 08             	sub    $0x8,%esp
80100d85:	50                   	push   %eax
80100d86:	68 68 23 10 80       	push   $0x80102368
80100d8b:	e8 1f f4 ff ff       	call   801001af <cprintf>
80100d90:	83 c4 10             	add    $0x10,%esp
  cprintf("Kernel code segment's address bit 15~0 : %d\n",cpu->gdt[SEG_KCODE].base_15_0);
80100d93:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80100d99:	0f b7 40 0a          	movzwl 0xa(%eax),%eax
80100d9d:	0f b7 c0             	movzwl %ax,%eax
80100da0:	83 ec 08             	sub    $0x8,%esp
80100da3:	50                   	push   %eax
80100da4:	68 98 23 10 80       	push   $0x80102398
80100da9:	e8 01 f4 ff ff       	call   801001af <cprintf>
80100dae:	83 c4 10             	add    $0x10,%esp
                                                                                          
  cprintf("Kernel data segment's address bit 31~24 : %d\n",cpu->gdt[SEG_KDATA].base_31_24);
80100db1:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80100db7:	0f b6 40 17          	movzbl 0x17(%eax),%eax
80100dbb:	0f b6 c0             	movzbl %al,%eax
80100dbe:	83 ec 08             	sub    $0x8,%esp
80100dc1:	50                   	push   %eax
80100dc2:	68 c8 23 10 80       	push   $0x801023c8
80100dc7:	e8 e3 f3 ff ff       	call   801001af <cprintf>
80100dcc:	83 c4 10             	add    $0x10,%esp
  cprintf("Kernel data segment's address bit 23~16 : %d\n",cpu->gdt[SEG_KDATA].base_23_16);
80100dcf:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80100dd5:	0f b6 40 14          	movzbl 0x14(%eax),%eax
80100dd9:	0f b6 c0             	movzbl %al,%eax
80100ddc:	83 ec 08             	sub    $0x8,%esp
80100ddf:	50                   	push   %eax
80100de0:	68 f8 23 10 80       	push   $0x801023f8
80100de5:	e8 c5 f3 ff ff       	call   801001af <cprintf>
80100dea:	83 c4 10             	add    $0x10,%esp
  cprintf("Kernel data segment's address bit 15~0 : %d\n",cpu->gdt[SEG_KDATA].base_15_0);
80100ded:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80100df3:	0f b7 40 12          	movzwl 0x12(%eax),%eax
80100df7:	0f b7 c0             	movzwl %ax,%eax
80100dfa:	83 ec 08             	sub    $0x8,%esp
80100dfd:	50                   	push   %eax
80100dfe:	68 28 24 10 80       	push   $0x80102428
80100e03:	e8 a7 f3 ff ff       	call   801001af <cprintf>
80100e08:	83 c4 10             	add    $0x10,%esp

  cprintf("User code segment's address bit 31~24 : %d\n",cpu->gdt[SEG_UCODE].base_31_24);
80100e0b:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80100e11:	0f b6 40 27          	movzbl 0x27(%eax),%eax
80100e15:	0f b6 c0             	movzbl %al,%eax
80100e18:	83 ec 08             	sub    $0x8,%esp
80100e1b:	50                   	push   %eax
80100e1c:	68 58 24 10 80       	push   $0x80102458
80100e21:	e8 89 f3 ff ff       	call   801001af <cprintf>
80100e26:	83 c4 10             	add    $0x10,%esp
  cprintf("User code segment's address bit 23~16 : %d\n",cpu->gdt[SEG_UCODE].base_15_0);
80100e29:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80100e2f:	0f b7 40 22          	movzwl 0x22(%eax),%eax
80100e33:	0f b7 c0             	movzwl %ax,%eax
80100e36:	83 ec 08             	sub    $0x8,%esp
80100e39:	50                   	push   %eax
80100e3a:	68 84 24 10 80       	push   $0x80102484
80100e3f:	e8 6b f3 ff ff       	call   801001af <cprintf>
80100e44:	83 c4 10             	add    $0x10,%esp
  cprintf("User code segment's address bit 15~0 : %d\n",cpu->gdt[SEG_UCODE].base_15_0);
80100e47:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80100e4d:	0f b7 40 22          	movzwl 0x22(%eax),%eax
80100e51:	0f b7 c0             	movzwl %ax,%eax
80100e54:	83 ec 08             	sub    $0x8,%esp
80100e57:	50                   	push   %eax
80100e58:	68 b0 24 10 80       	push   $0x801024b0
80100e5d:	e8 4d f3 ff ff       	call   801001af <cprintf>
80100e62:	83 c4 10             	add    $0x10,%esp
  
  cprintf("User code segment's address bit 31~24 : %d\n",cpu->gdt[SEG_UDATA].base_31_24);
80100e65:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80100e6b:	0f b6 40 2f          	movzbl 0x2f(%eax),%eax
80100e6f:	0f b6 c0             	movzbl %al,%eax
80100e72:	83 ec 08             	sub    $0x8,%esp
80100e75:	50                   	push   %eax
80100e76:	68 58 24 10 80       	push   $0x80102458
80100e7b:	e8 2f f3 ff ff       	call   801001af <cprintf>
80100e80:	83 c4 10             	add    $0x10,%esp
  cprintf("User code segment's address bit 23~16 : %d\n",cpu->gdt[SEG_UDATA].base_23_16);
80100e83:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80100e89:	0f b6 40 2c          	movzbl 0x2c(%eax),%eax
80100e8d:	0f b6 c0             	movzbl %al,%eax
80100e90:	83 ec 08             	sub    $0x8,%esp
80100e93:	50                   	push   %eax
80100e94:	68 84 24 10 80       	push   $0x80102484
80100e99:	e8 11 f3 ff ff       	call   801001af <cprintf>
80100e9e:	83 c4 10             	add    $0x10,%esp
  cprintf("User code segment's address bit 15~0 : %d\n",cpu->gdt[SEG_UDATA].base_15_0);
80100ea1:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80100ea7:	0f b7 40 2a          	movzwl 0x2a(%eax),%eax
80100eab:	0f b7 c0             	movzwl %ax,%eax
80100eae:	83 ec 08             	sub    $0x8,%esp
80100eb1:	50                   	push   %eax
80100eb2:	68 b0 24 10 80       	push   $0x801024b0
80100eb7:	e8 f3 f2 ff ff       	call   801001af <cprintf>
80100ebc:	83 c4 10             	add    $0x10,%esp

}
80100ebf:	c9                   	leave  
80100ec0:	c3                   	ret    

80100ec1 <walkpgdir>:

//返回页表pgdir中对应线性地址va的PTE(页项)的地址，如果creat!=0,那么创建请求的页项
//
static pte_t * 
walkpgdir(pde_t *pgdir, const void *va, int alloc)
{
80100ec1:	55                   	push   %ebp
80100ec2:	89 e5                	mov    %esp,%ebp
80100ec4:	83 ec 18             	sub    $0x18,%esp
  pde_t *pde;   //页目录入口地址
  pte_t *pgtab;  //页表项入口地址

  pde = &pgdir[PDX(va)];    //根据线性地址查找其对应的页目录
80100ec7:	8b 45 0c             	mov    0xc(%ebp),%eax
80100eca:	c1 e8 16             	shr    $0x16,%eax
80100ecd:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80100ed4:	8b 45 08             	mov    0x8(%ebp),%eax
80100ed7:	01 d0                	add    %edx,%eax
80100ed9:	89 45 f0             	mov    %eax,-0x10(%ebp)
 
  if(*pde & PTE_P){   //如果这个页目录存在
80100edc:	8b 45 f0             	mov    -0x10(%ebp),%eax
80100edf:	8b 00                	mov    (%eax),%eax
80100ee1:	83 e0 01             	and    $0x1,%eax
80100ee4:	85 c0                	test   %eax,%eax
80100ee6:	74 18                	je     80100f00 <walkpgdir+0x3f>
    pgtab = (pte_t*)p2v(PTE_ADDR(*pde));  //这个页表地址就是当前这个页目录值中的地址 (第一次映射)
80100ee8:	8b 45 f0             	mov    -0x10(%ebp),%eax
80100eeb:	8b 00                	mov    (%eax),%eax
80100eed:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80100ef2:	50                   	push   %eax
80100ef3:	e8 06 fb ff ff       	call   801009fe <p2v>
80100ef8:	83 c4 04             	add    $0x4,%esp
80100efb:	89 45 f4             	mov    %eax,-0xc(%ebp)
80100efe:	eb 48                	jmp    80100f48 <walkpgdir+0x87>
  } else {
    
    if(!alloc || (pgtab = (pte_t*)kalloc()) == 0) //如果没有被分配，并且分配的页表失败
80100f00:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80100f04:	74 0e                	je     80100f14 <walkpgdir+0x53>
80100f06:	e8 f6 f8 ff ff       	call   80100801 <kalloc>
80100f0b:	89 45 f4             	mov    %eax,-0xc(%ebp)
80100f0e:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80100f12:	75 07                	jne    80100f1b <walkpgdir+0x5a>
      return 0;
80100f14:	b8 00 00 00 00       	mov    $0x0,%eax
80100f19:	eb 44                	jmp    80100f5f <walkpgdir+0x9e>
    
    memset(pgtab, 0, PGSIZE);  //为分配的页表项填充
80100f1b:	83 ec 04             	sub    $0x4,%esp
80100f1e:	68 00 10 00 00       	push   $0x1000
80100f23:	6a 00                	push   $0x0
80100f25:	ff 75 f4             	pushl  -0xc(%ebp)
80100f28:	e8 e2 f7 ff ff       	call   8010070f <memset>
80100f2d:	83 c4 10             	add    $0x10,%esp
    
    *pde = v2p(pgtab) | PTE_P | PTE_W | PTE_U; //为当前创建的页表与页目录进行映射 (第一次映射)
80100f30:	83 ec 0c             	sub    $0xc,%esp
80100f33:	ff 75 f4             	pushl  -0xc(%ebp)
80100f36:	e8 b6 fa ff ff       	call   801009f1 <v2p>
80100f3b:	83 c4 10             	add    $0x10,%esp
80100f3e:	83 c8 07             	or     $0x7,%eax
80100f41:	89 c2                	mov    %eax,%edx
80100f43:	8b 45 f0             	mov    -0x10(%ebp),%eax
80100f46:	89 10                	mov    %edx,(%eax)
  }
  return &pgtab[PTX(va)];   //返回页表地址
80100f48:	8b 45 0c             	mov    0xc(%ebp),%eax
80100f4b:	c1 e8 0c             	shr    $0xc,%eax
80100f4e:	25 ff 03 00 00       	and    $0x3ff,%eax
80100f53:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80100f5a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100f5d:	01 d0                	add    %edx,%eax
}
80100f5f:	c9                   	leave  
80100f60:	c3                   	ret    

80100f61 <mappages>:

//为以va开始的线性地址创建页项，va引用pa开始处的物理地址，va和size可能没有按页对齐
static int 
mappages(pde_t *pgdir, void *va, uint size, uint pa, int perm)
{
80100f61:	55                   	push   %ebp
80100f62:	89 e5                	mov    %esp,%ebp
80100f64:	83 ec 18             	sub    $0x18,%esp
  char *a, *last;
  pte_t *pte;
  
  a = (char*)PGROUNDDOWN((uint)va);                        //va所在的第一页地址
80100f67:	8b 45 0c             	mov    0xc(%ebp),%eax
80100f6a:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80100f6f:	89 45 f4             	mov    %eax,-0xc(%ebp)
  last = (char*)PGROUNDDOWN(((uint)va) + size - 1);        //va所在的最后一页地址
80100f72:	8b 55 0c             	mov    0xc(%ebp),%edx
80100f75:	8b 45 10             	mov    0x10(%ebp),%eax
80100f78:	01 d0                	add    %edx,%eax
80100f7a:	83 e8 01             	sub    $0x1,%eax
80100f7d:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80100f82:	89 45 f0             	mov    %eax,-0x10(%ebp)
  
  for(;;){
    if((pte = walkpgdir(pgdir, a, 1)) == 0)      //创建页
80100f85:	83 ec 04             	sub    $0x4,%esp
80100f88:	6a 01                	push   $0x1
80100f8a:	ff 75 f4             	pushl  -0xc(%ebp)
80100f8d:	ff 75 08             	pushl  0x8(%ebp)
80100f90:	e8 2c ff ff ff       	call   80100ec1 <walkpgdir>
80100f95:	83 c4 10             	add    $0x10,%esp
80100f98:	89 45 ec             	mov    %eax,-0x14(%ebp)
80100f9b:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80100f9f:	75 07                	jne    80100fa8 <mappages+0x47>
	return -1;
80100fa1:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80100fa6:	eb 30                	jmp    80100fd8 <mappages+0x77>
    *pte = pa | perm | PTE_P;  // 为创建的这个页项分配一个物理空间进行映射(第二次映射)
80100fa8:	8b 45 18             	mov    0x18(%ebp),%eax
80100fab:	0b 45 14             	or     0x14(%ebp),%eax
80100fae:	83 c8 01             	or     $0x1,%eax
80100fb1:	89 c2                	mov    %eax,%edx
80100fb3:	8b 45 ec             	mov    -0x14(%ebp),%eax
80100fb6:	89 10                	mov    %edx,(%eax)
    if(a == last)
80100fb8:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100fbb:	3b 45 f0             	cmp    -0x10(%ebp),%eax
80100fbe:	75 08                	jne    80100fc8 <mappages+0x67>
      break;
80100fc0:	90                   	nop
    
    //至此，一级页表（页目录）到二级页表（页项）的映射，以及二级页表到物理内存的映射已经结束
    a += PGSIZE;
    pa += PGSIZE;
  }
  return 0;
80100fc1:	b8 00 00 00 00       	mov    $0x0,%eax
80100fc6:	eb 10                	jmp    80100fd8 <mappages+0x77>
    *pte = pa | perm | PTE_P;  // 为创建的这个页项分配一个物理空间进行映射(第二次映射)
    if(a == last)
      break;
    
    //至此，一级页表（页目录）到二级页表（页项）的映射，以及二级页表到物理内存的映射已经结束
    a += PGSIZE;
80100fc8:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
    pa += PGSIZE;
80100fcf:	81 45 14 00 10 00 00 	addl   $0x1000,0x14(%ebp)
  }
80100fd6:	eb ad                	jmp    80100f85 <mappages+0x24>
  return 0;
}
80100fd8:	c9                   	leave  
80100fd9:	c3                   	ret    

80100fda <setupkvm>:
};


//设置页表的内核部分,返回此页表
pde_t* setupkvm(void)
{
80100fda:	55                   	push   %ebp
80100fdb:	89 e5                	mov    %esp,%ebp
80100fdd:	53                   	push   %ebx
80100fde:	83 ec 14             	sub    $0x14,%esp
  pde_t *pgdir; //先创建一个页目录
  struct kmap *k;

  if((pgdir = (pde_t*)kalloc()) == 0)  //为这个页目录分配一个空间
80100fe1:	e8 1b f8 ff ff       	call   80100801 <kalloc>
80100fe6:	89 45 f0             	mov    %eax,-0x10(%ebp)
80100fe9:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80100fed:	75 07                	jne    80100ff6 <setupkvm+0x1c>
    return 0;
80100fef:	b8 00 00 00 00       	mov    $0x0,%eax
80100ff4:	eb 6a                	jmp    80101060 <setupkvm+0x86>
 
  memset(pgdir, 0, PGSIZE);  //填充
80100ff6:	83 ec 04             	sub    $0x4,%esp
80100ff9:	68 00 10 00 00       	push   $0x1000
80100ffe:	6a 00                	push   $0x0
80101000:	ff 75 f0             	pushl  -0x10(%ebp)
80101003:	e8 07 f7 ff ff       	call   8010070f <memset>
80101008:	83 c4 10             	add    $0x10,%esp
 
  //分配每一页 
  for(k = kmap; k < &kmap[NELEM(kmap)]; k++)
8010100b:	c7 45 f4 80 45 10 80 	movl   $0x80104580,-0xc(%ebp)
80101012:	eb 40                	jmp    80101054 <setupkvm+0x7a>
    //为每一个内核的虚拟地址进行到其所指向的物理地址的映射
    if(mappages(pgdir, k->virt, k->phys_end - k->phys_start, 
80101014:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101017:	8b 48 0c             	mov    0xc(%eax),%ecx
8010101a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010101d:	8b 50 04             	mov    0x4(%eax),%edx
80101020:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101023:	8b 58 08             	mov    0x8(%eax),%ebx
80101026:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101029:	8b 40 04             	mov    0x4(%eax),%eax
8010102c:	29 c3                	sub    %eax,%ebx
8010102e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101031:	8b 00                	mov    (%eax),%eax
80101033:	83 ec 0c             	sub    $0xc,%esp
80101036:	51                   	push   %ecx
80101037:	52                   	push   %edx
80101038:	53                   	push   %ebx
80101039:	50                   	push   %eax
8010103a:	ff 75 f0             	pushl  -0x10(%ebp)
8010103d:	e8 1f ff ff ff       	call   80100f61 <mappages>
80101042:	83 c4 20             	add    $0x20,%esp
80101045:	85 c0                	test   %eax,%eax
80101047:	79 07                	jns    80101050 <setupkvm+0x76>
		(uint)k->phys_start, k->perm) < 0)
      return 0;
80101049:	b8 00 00 00 00       	mov    $0x0,%eax
8010104e:	eb 10                	jmp    80101060 <setupkvm+0x86>
    return 0;
 
  memset(pgdir, 0, PGSIZE);  //填充
 
  //分配每一页 
  for(k = kmap; k < &kmap[NELEM(kmap)]; k++)
80101050:	83 45 f4 10          	addl   $0x10,-0xc(%ebp)
80101054:	81 7d f4 c0 45 10 80 	cmpl   $0x801045c0,-0xc(%ebp)
8010105b:	72 b7                	jb     80101014 <setupkvm+0x3a>
    if(mappages(pgdir, k->virt, k->phys_end - k->phys_start, 
		(uint)k->phys_start, k->perm) < 0)
      return 0;

  //返回页目录
  return pgdir;
8010105d:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
80101060:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80101063:	c9                   	leave  
80101064:	c3                   	ret    

80101065 <switchkvm>:


// 切换到页表kpgdir
void switchkvm(void)
{
80101065:	55                   	push   %ebp
80101066:	89 e5                	mov    %esp,%ebp
  lcr3(v2p(kpgdir));   // 切换到内核页表
80101068:	a1 60 61 10 80       	mov    0x80106160,%eax
8010106d:	50                   	push   %eax
8010106e:	e8 7e f9 ff ff       	call   801009f1 <v2p>
80101073:	83 c4 04             	add    $0x4,%esp
80101076:	50                   	push   %eax
80101077:	e8 6a f9 ff ff       	call   801009e6 <lcr3>
8010107c:	83 c4 04             	add    $0x4,%esp
}
8010107f:	c9                   	leave  
80101080:	c3                   	ret    

80101081 <kvmalloc>:

void kvmalloc(void)
{
80101081:	55                   	push   %ebp
80101082:	89 e5                	mov    %esp,%ebp
80101084:	83 ec 08             	sub    $0x8,%esp
  kpgdir = setupkvm();  // 设置内核页表，以及每一个页表项所指向的页
80101087:	e8 4e ff ff ff       	call   80100fda <setupkvm>
8010108c:	a3 60 61 10 80       	mov    %eax,0x80106160
  switchkvm();  	// 切换到内核页表
80101091:	e8 cf ff ff ff       	call   80101065 <switchkvm>
}
80101096:	c9                   	leave  
80101097:	c3                   	ret    

80101098 <inituvm>:

// 映射进程页表到物理内存
void
inituvm(pde_t *pgdir)
{
80101098:	55                   	push   %ebp
80101099:	89 e5                	mov    %esp,%ebp
8010109b:	83 ec 18             	sub    $0x18,%esp
  char *mem;
  
  mem = kalloc(); //分配一段物理内存
8010109e:	e8 5e f7 ff ff       	call   80100801 <kalloc>
801010a3:	89 45 f4             	mov    %eax,-0xc(%ebp)
  memset(mem, 0, PGSIZE); //将这一段物理内存清空为0
801010a6:	83 ec 04             	sub    $0x4,%esp
801010a9:	68 00 10 00 00       	push   $0x1000
801010ae:	6a 00                	push   $0x0
801010b0:	ff 75 f4             	pushl  -0xc(%ebp)
801010b3:	e8 57 f6 ff ff       	call   8010070f <memset>
801010b8:	83 c4 10             	add    $0x10,%esp
  mappages(pgdir, 0, PGSIZE, v2p(mem), PTE_W|PTE_U); //映射
801010bb:	83 ec 0c             	sub    $0xc,%esp
801010be:	ff 75 f4             	pushl  -0xc(%ebp)
801010c1:	e8 2b f9 ff ff       	call   801009f1 <v2p>
801010c6:	83 c4 10             	add    $0x10,%esp
801010c9:	83 ec 0c             	sub    $0xc,%esp
801010cc:	6a 06                	push   $0x6
801010ce:	50                   	push   %eax
801010cf:	68 00 10 00 00       	push   $0x1000
801010d4:	6a 00                	push   $0x0
801010d6:	ff 75 08             	pushl  0x8(%ebp)
801010d9:	e8 83 fe ff ff       	call   80100f61 <mappages>
801010de:	83 c4 20             	add    $0x20,%esp
}
801010e1:	c9                   	leave  
801010e2:	c3                   	ret    

801010e3 <outb>:
               "memory", "cc");
}

static inline void
outb(ushort port, uchar data)
{
801010e3:	55                   	push   %ebp
801010e4:	89 e5                	mov    %esp,%ebp
801010e6:	83 ec 08             	sub    $0x8,%esp
801010e9:	8b 55 08             	mov    0x8(%ebp),%edx
801010ec:	8b 45 0c             	mov    0xc(%ebp),%eax
801010ef:	66 89 55 fc          	mov    %dx,-0x4(%ebp)
801010f3:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
801010f6:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
801010fa:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
801010fe:	ee                   	out    %al,(%dx)
}
801010ff:	c9                   	leave  
80101100:	c3                   	ret    

80101101 <picsetmask>:

static ushort irqmask = 0xFFFF & ~(1<<IRQ_SLAVE);

static void
picsetmask(ushort mask)
{
80101101:	55                   	push   %ebp
80101102:	89 e5                	mov    %esp,%ebp
80101104:	83 ec 04             	sub    $0x4,%esp
80101107:	8b 45 08             	mov    0x8(%ebp),%eax
8010110a:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  irqmask = mask;
8010110e:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
80101112:	66 a3 c0 45 10 80    	mov    %ax,0x801045c0
  outb(IO_PIC1+1, mask);
80101118:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
8010111c:	0f b6 c0             	movzbl %al,%eax
8010111f:	50                   	push   %eax
80101120:	6a 21                	push   $0x21
80101122:	e8 bc ff ff ff       	call   801010e3 <outb>
80101127:	83 c4 08             	add    $0x8,%esp
  outb(IO_PIC2+1, mask >> 8);
8010112a:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
8010112e:	66 c1 e8 08          	shr    $0x8,%ax
80101132:	0f b6 c0             	movzbl %al,%eax
80101135:	50                   	push   %eax
80101136:	68 a1 00 00 00       	push   $0xa1
8010113b:	e8 a3 ff ff ff       	call   801010e3 <outb>
80101140:	83 c4 08             	add    $0x8,%esp
}
80101143:	c9                   	leave  
80101144:	c3                   	ret    

80101145 <picenable>:

void
picenable(int irq)
{
80101145:	55                   	push   %ebp
80101146:	89 e5                	mov    %esp,%ebp
  picsetmask(irqmask & ~(1<<irq));
80101148:	8b 45 08             	mov    0x8(%ebp),%eax
8010114b:	ba 01 00 00 00       	mov    $0x1,%edx
80101150:	89 c1                	mov    %eax,%ecx
80101152:	d3 e2                	shl    %cl,%edx
80101154:	89 d0                	mov    %edx,%eax
80101156:	f7 d0                	not    %eax
80101158:	89 c2                	mov    %eax,%edx
8010115a:	0f b7 05 c0 45 10 80 	movzwl 0x801045c0,%eax
80101161:	21 d0                	and    %edx,%eax
80101163:	0f b7 c0             	movzwl %ax,%eax
80101166:	50                   	push   %eax
80101167:	e8 95 ff ff ff       	call   80101101 <picsetmask>
8010116c:	83 c4 04             	add    $0x4,%esp
}
8010116f:	c9                   	leave  
80101170:	c3                   	ret    

80101171 <picinit>:

//初始化8259A的中断控制器
void
picinit(void)
{
80101171:	55                   	push   %ebp
80101172:	89 e5                	mov    %esp,%ebp
  // 屏蔽掉所有的中断
  outb(IO_PIC1+1, 0xFF);
80101174:	68 ff 00 00 00       	push   $0xff
80101179:	6a 21                	push   $0x21
8010117b:	e8 63 ff ff ff       	call   801010e3 <outb>
80101180:	83 c4 08             	add    $0x8,%esp
  outb(IO_PIC2+1, 0xFF);
80101183:	68 ff 00 00 00       	push   $0xff
80101188:	68 a1 00 00 00       	push   $0xa1
8010118d:	e8 51 ff ff ff       	call   801010e3 <outb>
80101192:	83 c4 08             	add    $0x8,%esp

  // 设置主控制器

  outb(IO_PIC1, 0x11);    	  	// ICW1
80101195:	6a 11                	push   $0x11
80101197:	6a 20                	push   $0x20
80101199:	e8 45 ff ff ff       	call   801010e3 <outb>
8010119e:	83 c4 08             	add    $0x8,%esp
  outb(IO_PIC1+1, T_IRQ0); 		// ICW2, 设置所有中断向量偏移地址
801011a1:	6a 20                	push   $0x20
801011a3:	6a 21                	push   $0x21
801011a5:	e8 39 ff ff ff       	call   801010e3 <outb>
801011aa:	83 c4 08             	add    $0x8,%esp
  outb(IO_PIC1+1, 1<<IRQ_SLAVE); 	// ICW3
801011ad:	6a 04                	push   $0x4
801011af:	6a 21                	push   $0x21
801011b1:	e8 2d ff ff ff       	call   801010e3 <outb>
801011b6:	83 c4 08             	add    $0x8,%esp
  outb(IO_PIC1+1, 0x3); 		// ICW4
801011b9:	6a 03                	push   $0x3
801011bb:	6a 21                	push   $0x21
801011bd:	e8 21 ff ff ff       	call   801010e3 <outb>
801011c2:	83 c4 08             	add    $0x8,%esp

  // 设置从控制器
  
  outb(IO_PIC2, 0x11);                  // ICW1
801011c5:	6a 11                	push   $0x11
801011c7:	68 a0 00 00 00       	push   $0xa0
801011cc:	e8 12 ff ff ff       	call   801010e3 <outb>
801011d1:	83 c4 08             	add    $0x8,%esp
  outb(IO_PIC2+1, T_IRQ0 + 8);          // ICW2
801011d4:	6a 28                	push   $0x28
801011d6:	68 a1 00 00 00       	push   $0xa1
801011db:	e8 03 ff ff ff       	call   801010e3 <outb>
801011e0:	83 c4 08             	add    $0x8,%esp
  outb(IO_PIC2+1, IRQ_SLAVE);           // ICW3
801011e3:	6a 02                	push   $0x2
801011e5:	68 a1 00 00 00       	push   $0xa1
801011ea:	e8 f4 fe ff ff       	call   801010e3 <outb>
801011ef:	83 c4 08             	add    $0x8,%esp
  outb(IO_PIC2+1, 0x3);                 // ICW4
801011f2:	6a 03                	push   $0x3
801011f4:	68 a1 00 00 00       	push   $0xa1
801011f9:	e8 e5 fe ff ff       	call   801010e3 <outb>
801011fe:	83 c4 08             	add    $0x8,%esp
  
  //设置OCW3  
  outb(IO_PIC1, 0x68);            
80101201:	6a 68                	push   $0x68
80101203:	6a 20                	push   $0x20
80101205:	e8 d9 fe ff ff       	call   801010e3 <outb>
8010120a:	83 c4 08             	add    $0x8,%esp
  outb(IO_PIC1, 0x0a);            
8010120d:	6a 0a                	push   $0xa
8010120f:	6a 20                	push   $0x20
80101211:	e8 cd fe ff ff       	call   801010e3 <outb>
80101216:	83 c4 08             	add    $0x8,%esp

  outb(IO_PIC2, 0x68);             // OCW3
80101219:	6a 68                	push   $0x68
8010121b:	68 a0 00 00 00       	push   $0xa0
80101220:	e8 be fe ff ff       	call   801010e3 <outb>
80101225:	83 c4 08             	add    $0x8,%esp
  outb(IO_PIC2, 0x0a);             // OCW3
80101228:	6a 0a                	push   $0xa
8010122a:	68 a0 00 00 00       	push   $0xa0
8010122f:	e8 af fe ff ff       	call   801010e3 <outb>
80101234:	83 c4 08             	add    $0x8,%esp

  if(irqmask != 0xFFFF)
80101237:	0f b7 05 c0 45 10 80 	movzwl 0x801045c0,%eax
8010123e:	66 83 f8 ff          	cmp    $0xffff,%ax
80101242:	74 13                	je     80101257 <picinit+0xe6>
    picsetmask(irqmask);
80101244:	0f b7 05 c0 45 10 80 	movzwl 0x801045c0,%eax
8010124b:	0f b7 c0             	movzwl %ax,%eax
8010124e:	50                   	push   %eax
8010124f:	e8 ad fe ff ff       	call   80101101 <picsetmask>
80101254:	83 c4 04             	add    $0x4,%esp
}
80101257:	c9                   	leave  
80101258:	c3                   	ret    

80101259 <allocproc>:
extern void trapret(void);  //定义在了trapasm.S里面
extern void forkret(void);

struct proc*
allocproc(void)
{
80101259:	55                   	push   %ebp
8010125a:	89 e5                	mov    %esp,%ebp
8010125c:	83 ec 18             	sub    $0x18,%esp
  struct proc *p;
  char *sp;

  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
8010125f:	c7 45 f4 c0 61 10 80 	movl   $0x801061c0,-0xc(%ebp)
80101266:	eb 46                	jmp    801012ae <allocproc+0x55>
    if(p->state == UNUSED)
80101268:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010126b:	8b 40 0c             	mov    0xc(%eax),%eax
8010126e:	85 c0                	test   %eax,%eax
80101270:	75 38                	jne    801012aa <allocproc+0x51>
      goto found;
80101272:	90                   	nop
  return 0;

found:
  p->state = EMBRYO;  //修改进程的状态位
80101273:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101276:	c7 40 0c 01 00 00 00 	movl   $0x1,0xc(%eax)
  p->pid = nextpid++;
8010127d:	a1 c4 45 10 80       	mov    0x801045c4,%eax
80101282:	8d 50 01             	lea    0x1(%eax),%edx
80101285:	89 15 c4 45 10 80    	mov    %edx,0x801045c4
8010128b:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010128e:	89 42 10             	mov    %eax,0x10(%edx)

  // 为一个进程分配一段内核栈
  if((p->kstack = kalloc()) == 0){ //分配进程内核栈失败
80101291:	e8 6b f5 ff ff       	call   80100801 <kalloc>
80101296:	89 c2                	mov    %eax,%edx
80101298:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010129b:	89 50 08             	mov    %edx,0x8(%eax)
8010129e:	8b 45 f4             	mov    -0xc(%ebp),%eax
801012a1:	8b 40 08             	mov    0x8(%eax),%eax
801012a4:	85 c0                	test   %eax,%eax
801012a6:	75 27                	jne    801012cf <allocproc+0x76>
801012a8:	eb 14                	jmp    801012be <allocproc+0x65>
allocproc(void)
{
  struct proc *p;
  char *sp;

  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
801012aa:	83 45 f4 30          	addl   $0x30,-0xc(%ebp)
801012ae:	81 7d f4 c0 6d 10 80 	cmpl   $0x80106dc0,-0xc(%ebp)
801012b5:	72 b1                	jb     80101268 <allocproc+0xf>
    if(p->state == UNUSED)
      goto found;
  return 0;
801012b7:	b8 00 00 00 00       	mov    $0x0,%eax
801012bc:	eb 6a                	jmp    80101328 <allocproc+0xcf>
  p->state = EMBRYO;  //修改进程的状态位
  p->pid = nextpid++;

  // 为一个进程分配一段内核栈
  if((p->kstack = kalloc()) == 0){ //分配进程内核栈失败
    p->state = UNUSED;
801012be:	8b 45 f4             	mov    -0xc(%ebp),%eax
801012c1:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
    return 0;
801012c8:	b8 00 00 00 00       	mov    $0x0,%eax
801012cd:	eb 59                	jmp    80101328 <allocproc+0xcf>
  }
  sp = p->kstack + KSTACKSIZE; //sp为为这个进程分配的内核栈的栈顶地址
801012cf:	8b 45 f4             	mov    -0xc(%ebp),%eax
801012d2:	8b 40 08             	mov    0x8(%eax),%eax
801012d5:	05 00 10 00 00       	add    $0x1000,%eax
801012da:	89 45 f0             	mov    %eax,-0x10(%ebp)
  
  sp -= sizeof *p->tf;   //流出陷入帧需要的空间
801012dd:	83 6d f0 4c          	subl   $0x4c,-0x10(%ebp)
  p->tf = (struct trapframe*)sp; //当前的陷入帧
801012e1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801012e4:	8b 55 f0             	mov    -0x10(%ebp),%edx
801012e7:	89 50 14             	mov    %edx,0x14(%eax)
  
  // 设置新的上下文来开始执行forket
  // 最终返回到trapret.
  sp -= 4;
801012ea:	83 6d f0 04          	subl   $0x4,-0x10(%ebp)
  *(uint*)sp = (uint)trapret;  //压入trapret的地址供forkret返回
801012ee:	ba 3d 22 10 80       	mov    $0x8010223d,%edx
801012f3:	8b 45 f0             	mov    -0x10(%ebp),%eax
801012f6:	89 10                	mov    %edx,(%eax)

  sp -= sizeof *p->context;  //留出上下文需要的空间
801012f8:	83 6d f0 14          	subl   $0x14,-0x10(%ebp)
  p->context = (struct context*)sp;   //进程的上下文
801012fc:	8b 45 f4             	mov    -0xc(%ebp),%eax
801012ff:	8b 55 f0             	mov    -0x10(%ebp),%edx
80101302:	89 50 18             	mov    %edx,0x18(%eax)
  memset(p->context, 0, sizeof *p->context);  // 将上下文清空
80101305:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101308:	8b 40 18             	mov    0x18(%eax),%eax
8010130b:	83 ec 04             	sub    $0x4,%esp
8010130e:	6a 14                	push   $0x14
80101310:	6a 00                	push   $0x0
80101312:	50                   	push   %eax
80101313:	e8 f7 f3 ff ff       	call   8010070f <memset>
80101318:	83 c4 10             	add    $0x10,%esp
  p->state = ALLOCATED;
8010131b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010131e:	c7 40 0c 06 00 00 00 	movl   $0x6,0xc(%eax)
//  p->context->eip = (uint)forkret;   //把当前上下文的起始地址设置为forkret

  return p;
80101325:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80101328:	c9                   	leave  
80101329:	c3                   	ret    

8010132a <printproc>:

//打印当前进程表中的所有进程的信息
void printproc(void)
{
8010132a:	55                   	push   %ebp
8010132b:	89 e5                	mov    %esp,%ebp
8010132d:	83 ec 18             	sub    $0x18,%esp
  struct proc* p;
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
80101330:	c7 45 f4 c0 61 10 80 	movl   $0x801061c0,-0xc(%ebp)
80101337:	eb 69                	jmp    801013a2 <printproc+0x78>
  {
      if(p->state == ALLOCATED)
80101339:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010133c:	8b 40 0c             	mov    0xc(%eax),%eax
8010133f:	83 f8 06             	cmp    $0x6,%eax
80101342:	75 5a                	jne    8010139e <printproc+0x74>
      {
 	 cprintf("Process %d's kernelstack is %x\n",p->pid, p->kstack);  //该进程的内核栈的栈底地址
80101344:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101347:	8b 50 08             	mov    0x8(%eax),%edx
8010134a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010134d:	8b 40 10             	mov    0x10(%eax),%eax
80101350:	83 ec 04             	sub    $0x4,%esp
80101353:	52                   	push   %edx
80101354:	50                   	push   %eax
80101355:	68 dc 24 10 80       	push   $0x801024dc
8010135a:	e8 50 ee ff ff       	call   801001af <cprintf>
8010135f:	83 c4 10             	add    $0x10,%esp
	 cprintf("Process %d's context is %x\n",p->pid, p->context);   //该进程的上下文地址
80101362:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101365:	8b 50 18             	mov    0x18(%eax),%edx
80101368:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010136b:	8b 40 10             	mov    0x10(%eax),%eax
8010136e:	83 ec 04             	sub    $0x4,%esp
80101371:	52                   	push   %edx
80101372:	50                   	push   %eax
80101373:	68 fc 24 10 80       	push   $0x801024fc
80101378:	e8 32 ee ff ff       	call   801001af <cprintf>
8010137d:	83 c4 10             	add    $0x10,%esp
 	 cprintf("Process %d's trapframe is %x\n",p->pid, p->tf);   //该进程的陷入帧的地址
80101380:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101383:	8b 50 14             	mov    0x14(%eax),%edx
80101386:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101389:	8b 40 10             	mov    0x10(%eax),%eax
8010138c:	83 ec 04             	sub    $0x4,%esp
8010138f:	52                   	push   %edx
80101390:	50                   	push   %eax
80101391:	68 18 25 10 80       	push   $0x80102518
80101396:	e8 14 ee ff ff       	call   801001af <cprintf>
8010139b:	83 c4 10             	add    $0x10,%esp

//打印当前进程表中的所有进程的信息
void printproc(void)
{
  struct proc* p;
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
8010139e:	83 45 f4 30          	addl   $0x30,-0xc(%ebp)
801013a2:	81 7d f4 c0 6d 10 80 	cmpl   $0x80106dc0,-0xc(%ebp)
801013a9:	72 8e                	jb     80101339 <printproc+0xf>
	 cprintf("Process %d's context is %x\n",p->pid, p->context);   //该进程的上下文地址
 	 cprintf("Process %d's trapframe is %x\n",p->pid, p->tf);   //该进程的陷入帧的地址
      }
  }

}
801013ab:	c9                   	leave  
801013ac:	c3                   	ret    

801013ad <userinit>:

void
userinit(void)
{
801013ad:	55                   	push   %ebp
801013ae:	89 e5                	mov    %esp,%ebp
801013b0:	83 ec 18             	sub    $0x18,%esp
  struct proc *p;
  
  p = allocproc(); //分配一个进程
801013b3:	e8 a1 fe ff ff       	call   80101259 <allocproc>
801013b8:	89 45 f4             	mov    %eax,-0xc(%ebp)
  currentproc = p; //当前进程
801013bb:	8b 45 f4             	mov    -0xc(%ebp),%eax
801013be:	a3 08 4f 10 80       	mov    %eax,0x80104f08
  p->pgdir = setupkvm(); //设置这个进程的页表
801013c3:	e8 12 fc ff ff       	call   80100fda <setupkvm>
801013c8:	89 c2                	mov    %eax,%edx
801013ca:	8b 45 f4             	mov    -0xc(%ebp),%eax
801013cd:	89 50 04             	mov    %edx,0x4(%eax)
  inituvm(p->pgdir);  //实现进程页表与物理内存的映射
801013d0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801013d3:	8b 40 04             	mov    0x4(%eax),%eax
801013d6:	83 ec 0c             	sub    $0xc,%esp
801013d9:	50                   	push   %eax
801013da:	e8 b9 fc ff ff       	call   80101098 <inituvm>
801013df:	83 c4 10             	add    $0x10,%esp
  p->sz = PGSIZE;   //代码的最大有效虚拟地址
801013e2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801013e5:	c7 00 00 10 00 00    	movl   $0x1000,(%eax)
  memset(p->tf, 0, sizeof(*p->tf)); // 为用户进程寄存器开辟空间
801013eb:	8b 45 f4             	mov    -0xc(%ebp),%eax
801013ee:	8b 40 14             	mov    0x14(%eax),%eax
801013f1:	83 ec 04             	sub    $0x4,%esp
801013f4:	6a 4c                	push   $0x4c
801013f6:	6a 00                	push   $0x0
801013f8:	50                   	push   %eax
801013f9:	e8 11 f3 ff ff       	call   8010070f <memset>
801013fe:	83 c4 10             	add    $0x10,%esp

  //设置此进程的陷入帧
  p->tf->cs = (SEG_UCODE << 3) | DPL_USER;
80101401:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101404:	8b 40 14             	mov    0x14(%eax),%eax
80101407:	66 c7 40 3c 23 00    	movw   $0x23,0x3c(%eax)
  p->tf->ds = (SEG_UDATA << 3) | DPL_USER;
8010140d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101410:	8b 40 14             	mov    0x14(%eax),%eax
80101413:	66 c7 40 2c 2b 00    	movw   $0x2b,0x2c(%eax)
  p->tf->es = p->tf->ds;
80101419:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010141c:	8b 40 14             	mov    0x14(%eax),%eax
8010141f:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101422:	8b 52 14             	mov    0x14(%edx),%edx
80101425:	0f b7 52 2c          	movzwl 0x2c(%edx),%edx
80101429:	66 89 50 28          	mov    %dx,0x28(%eax)
  p->tf->ss = p->tf->ds;
8010142d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101430:	8b 40 14             	mov    0x14(%eax),%eax
80101433:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101436:	8b 52 14             	mov    0x14(%edx),%edx
80101439:	0f b7 52 2c          	movzwl 0x2c(%edx),%edx
8010143d:	66 89 50 48          	mov    %dx,0x48(%eax)
  p->tf->eflags = FL_IF; 
80101441:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101444:	8b 40 14             	mov    0x14(%eax),%eax
80101447:	c7 40 40 00 02 00 00 	movl   $0x200,0x40(%eax)
  p->tf->esp = PGSIZE;
8010144e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101451:	8b 40 14             	mov    0x14(%eax),%eax
80101454:	c7 40 44 00 10 00 00 	movl   $0x1000,0x44(%eax)
  p->tf->eip = 0;  
8010145b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010145e:	8b 40 14             	mov    0x14(%eax),%eax
80101461:	c7 40 38 00 00 00 00 	movl   $0x0,0x38(%eax)

//  safestrcpy(p->name, "initcode", sizeof(p->name));
//  p->cwd = namei("/");    //指明进程目录，由于是第一个进程，所以在根目录

  p->state = RUNNABLE;    //将进程的状态改为runable
80101468:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010146b:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
}
80101472:	c9                   	leave  
80101473:	c3                   	ret    

80101474 <confirmalloc>:

void 
confirmalloc()
{
80101474:	55                   	push   %ebp
80101475:	89 e5                	mov    %esp,%ebp
80101477:	83 ec 18             	sub    $0x18,%esp
  struct proc *p;
  if((p = allocproc()) == 0)  //分配一个进程
8010147a:	e8 da fd ff ff       	call   80101259 <allocproc>
8010147f:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101482:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80101486:	75 12                	jne    8010149a <confirmalloc+0x26>
      cprintf("Faild in building\n");
80101488:	83 ec 0c             	sub    $0xc,%esp
8010148b:	68 36 25 10 80       	push   $0x80102536
80101490:	e8 1a ed ff ff       	call   801001af <cprintf>
80101495:	83 c4 10             	add    $0x10,%esp
80101498:	eb 17                	jmp    801014b1 <confirmalloc+0x3d>
  else cprintf("Building process %d successed!!\n",p->pid);
8010149a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010149d:	8b 40 10             	mov    0x10(%eax),%eax
801014a0:	83 ec 08             	sub    $0x8,%esp
801014a3:	50                   	push   %eax
801014a4:	68 4c 25 10 80       	push   $0x8010254c
801014a9:	e8 01 ed ff ff       	call   801001af <cprintf>
801014ae:	83 c4 10             	add    $0x10,%esp
//  procinit();
//  cprintf("Building process %d successed!!\n",currentproc->pid);
}
801014b1:	c9                   	leave  
801014b2:	c3                   	ret    

801014b3 <ioapicwrite>:
  uint data;
};

//写入reg，并写入数据
static void ioapicwrite(int reg, uint data)
{
801014b3:	55                   	push   %ebp
801014b4:	89 e5                	mov    %esp,%ebp
  ioapic->reg = reg;
801014b6:	a1 c0 6d 10 80       	mov    0x80106dc0,%eax
801014bb:	8b 55 08             	mov    0x8(%ebp),%edx
801014be:	89 10                	mov    %edx,(%eax)
  ioapic->data = data;
801014c0:	a1 c0 6d 10 80       	mov    0x80106dc0,%eax
801014c5:	8b 55 0c             	mov    0xc(%ebp),%edx
801014c8:	89 50 10             	mov    %edx,0x10(%eax)
}
801014cb:	5d                   	pop    %ebp
801014cc:	c3                   	ret    

801014cd <ioapicread>:

//写入reg，并读取数据
static uint ioapicread(int reg)
{
801014cd:	55                   	push   %ebp
801014ce:	89 e5                	mov    %esp,%ebp
  ioapic->reg = reg;
801014d0:	a1 c0 6d 10 80       	mov    0x80106dc0,%eax
801014d5:	8b 55 08             	mov    0x8(%ebp),%edx
801014d8:	89 10                	mov    %edx,(%eax)
  return ioapic->data;
801014da:	a1 c0 6d 10 80       	mov    0x80106dc0,%eax
801014df:	8b 40 10             	mov    0x10(%eax),%eax
}
801014e2:	5d                   	pop    %ebp
801014e3:	c3                   	ret    

801014e4 <ioapicinit>:

//IOAPIC的初始化
void ioapicinit(void)
{
801014e4:	55                   	push   %ebp
801014e5:	89 e5                	mov    %esp,%ebp
801014e7:	83 ec 10             	sub    $0x10,%esp
  int i, maxintr;

  ioapic = (volatile struct ioapic*)IOAPIC;    //IOAPIC的默认的初始地址
801014ea:	c7 05 c0 6d 10 80 00 	movl   $0xfec00000,0x80106dc0
801014f1:	00 c0 fe 
  maxintr = (ioapicread(REG_VER) >> 16) & 0xFF;
801014f4:	6a 01                	push   $0x1
801014f6:	e8 d2 ff ff ff       	call   801014cd <ioapicread>
801014fb:	83 c4 04             	add    $0x4,%esp
801014fe:	c1 e8 10             	shr    $0x10,%eax
80101501:	25 ff 00 00 00       	and    $0xff,%eax
80101506:	89 45 f8             	mov    %eax,-0x8(%ebp)

  //标记所有的中断为边缘触发，激活高寄存器，关闭中断，不传送给CPU
  for(i = 0; i <= maxintr; i++){
80101509:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
80101510:	eb 39                	jmp    8010154b <ioapicinit+0x67>
    ioapicwrite(REG_TABLE+2*i, INT_DISABLED | (T_IRQ0 + i));
80101512:	8b 45 fc             	mov    -0x4(%ebp),%eax
80101515:	83 c0 20             	add    $0x20,%eax
80101518:	0d 00 00 01 00       	or     $0x10000,%eax
8010151d:	89 c2                	mov    %eax,%edx
8010151f:	8b 45 fc             	mov    -0x4(%ebp),%eax
80101522:	83 c0 08             	add    $0x8,%eax
80101525:	01 c0                	add    %eax,%eax
80101527:	52                   	push   %edx
80101528:	50                   	push   %eax
80101529:	e8 85 ff ff ff       	call   801014b3 <ioapicwrite>
8010152e:	83 c4 08             	add    $0x8,%esp
    ioapicwrite(REG_TABLE+2*i+1, 0);
80101531:	8b 45 fc             	mov    -0x4(%ebp),%eax
80101534:	83 c0 08             	add    $0x8,%eax
80101537:	01 c0                	add    %eax,%eax
80101539:	83 c0 01             	add    $0x1,%eax
8010153c:	6a 00                	push   $0x0
8010153e:	50                   	push   %eax
8010153f:	e8 6f ff ff ff       	call   801014b3 <ioapicwrite>
80101544:	83 c4 08             	add    $0x8,%esp

  ioapic = (volatile struct ioapic*)IOAPIC;    //IOAPIC的默认的初始地址
  maxintr = (ioapicread(REG_VER) >> 16) & 0xFF;

  //标记所有的中断为边缘触发，激活高寄存器，关闭中断，不传送给CPU
  for(i = 0; i <= maxintr; i++){
80101547:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
8010154b:	8b 45 fc             	mov    -0x4(%ebp),%eax
8010154e:	3b 45 f8             	cmp    -0x8(%ebp),%eax
80101551:	7e bf                	jle    80101512 <ioapicinit+0x2e>
    ioapicwrite(REG_TABLE+2*i, INT_DISABLED | (T_IRQ0 + i));
    ioapicwrite(REG_TABLE+2*i+1, 0);
  }
}
80101553:	c9                   	leave  
80101554:	c3                   	ret    

80101555 <ioapicenable>:

void ioapicenable(int irq, int cpunum)
{
80101555:	55                   	push   %ebp
80101556:	89 e5                	mov    %esp,%ebp
  if(!ismp)
80101558:	a1 c4 6d 10 80       	mov    0x80106dc4,%eax
8010155d:	85 c0                	test   %eax,%eax
8010155f:	75 02                	jne    80101563 <ioapicenable+0xe>
      return;
80101561:	eb 37                	jmp    8010159a <ioapicenable+0x45>

  //标记所有的中断为边缘触发，激活高寄存器，打开中断，传送给CPU
  ioapicwrite(REG_TABLE+2*irq, T_IRQ0 + irq);
80101563:	8b 45 08             	mov    0x8(%ebp),%eax
80101566:	83 c0 20             	add    $0x20,%eax
80101569:	89 c2                	mov    %eax,%edx
8010156b:	8b 45 08             	mov    0x8(%ebp),%eax
8010156e:	83 c0 08             	add    $0x8,%eax
80101571:	01 c0                	add    %eax,%eax
80101573:	52                   	push   %edx
80101574:	50                   	push   %eax
80101575:	e8 39 ff ff ff       	call   801014b3 <ioapicwrite>
8010157a:	83 c4 08             	add    $0x8,%esp
  ioapicwrite(REG_TABLE+2*irq+1, cpunum << 24);
8010157d:	8b 45 0c             	mov    0xc(%ebp),%eax
80101580:	c1 e0 18             	shl    $0x18,%eax
80101583:	89 c2                	mov    %eax,%edx
80101585:	8b 45 08             	mov    0x8(%ebp),%eax
80101588:	83 c0 08             	add    $0x8,%eax
8010158b:	01 c0                	add    %eax,%eax
8010158d:	83 c0 01             	add    $0x1,%eax
80101590:	52                   	push   %edx
80101591:	50                   	push   %eax
80101592:	e8 1c ff ff ff       	call   801014b3 <ioapicwrite>
80101597:	83 c4 08             	add    $0x8,%esp
}
8010159a:	c9                   	leave  
8010159b:	c3                   	ret    

8010159c <vector0>:
# generated by vectors.pl - do not edit
# handlers
.globl alltraps
.globl vector0
vector0:
  pushl $0
8010159c:	6a 00                	push   $0x0
  pushl $0
8010159e:	6a 00                	push   $0x0
  jmp alltraps
801015a0:	e9 80 0c 00 00       	jmp    80102225 <alltraps>

801015a5 <vector1>:
.globl vector1
vector1:
  pushl $0
801015a5:	6a 00                	push   $0x0
  pushl $1
801015a7:	6a 01                	push   $0x1
  jmp alltraps
801015a9:	e9 77 0c 00 00       	jmp    80102225 <alltraps>

801015ae <vector2>:
.globl vector2
vector2:
  pushl $0
801015ae:	6a 00                	push   $0x0
  pushl $2
801015b0:	6a 02                	push   $0x2
  jmp alltraps
801015b2:	e9 6e 0c 00 00       	jmp    80102225 <alltraps>

801015b7 <vector3>:
.globl vector3
vector3:
  pushl $0
801015b7:	6a 00                	push   $0x0
  pushl $3
801015b9:	6a 03                	push   $0x3
  jmp alltraps
801015bb:	e9 65 0c 00 00       	jmp    80102225 <alltraps>

801015c0 <vector4>:
.globl vector4
vector4:
  pushl $0
801015c0:	6a 00                	push   $0x0
  pushl $4
801015c2:	6a 04                	push   $0x4
  jmp alltraps
801015c4:	e9 5c 0c 00 00       	jmp    80102225 <alltraps>

801015c9 <vector5>:
.globl vector5
vector5:
  pushl $0
801015c9:	6a 00                	push   $0x0
  pushl $5
801015cb:	6a 05                	push   $0x5
  jmp alltraps
801015cd:	e9 53 0c 00 00       	jmp    80102225 <alltraps>

801015d2 <vector6>:
.globl vector6
vector6:
  pushl $0
801015d2:	6a 00                	push   $0x0
  pushl $6
801015d4:	6a 06                	push   $0x6
  jmp alltraps
801015d6:	e9 4a 0c 00 00       	jmp    80102225 <alltraps>

801015db <vector7>:
.globl vector7
vector7:
  pushl $0
801015db:	6a 00                	push   $0x0
  pushl $7
801015dd:	6a 07                	push   $0x7
  jmp alltraps
801015df:	e9 41 0c 00 00       	jmp    80102225 <alltraps>

801015e4 <vector8>:
.globl vector8
vector8:
  pushl $8
801015e4:	6a 08                	push   $0x8
  jmp alltraps
801015e6:	e9 3a 0c 00 00       	jmp    80102225 <alltraps>

801015eb <vector9>:
.globl vector9
vector9:
  pushl $0
801015eb:	6a 00                	push   $0x0
  pushl $9
801015ed:	6a 09                	push   $0x9
  jmp alltraps
801015ef:	e9 31 0c 00 00       	jmp    80102225 <alltraps>

801015f4 <vector10>:
.globl vector10
vector10:
  pushl $10
801015f4:	6a 0a                	push   $0xa
  jmp alltraps
801015f6:	e9 2a 0c 00 00       	jmp    80102225 <alltraps>

801015fb <vector11>:
.globl vector11
vector11:
  pushl $11
801015fb:	6a 0b                	push   $0xb
  jmp alltraps
801015fd:	e9 23 0c 00 00       	jmp    80102225 <alltraps>

80101602 <vector12>:
.globl vector12
vector12:
  pushl $12
80101602:	6a 0c                	push   $0xc
  jmp alltraps
80101604:	e9 1c 0c 00 00       	jmp    80102225 <alltraps>

80101609 <vector13>:
.globl vector13
vector13:
  pushl $13
80101609:	6a 0d                	push   $0xd
  jmp alltraps
8010160b:	e9 15 0c 00 00       	jmp    80102225 <alltraps>

80101610 <vector14>:
.globl vector14
vector14:
  pushl $14
80101610:	6a 0e                	push   $0xe
  jmp alltraps
80101612:	e9 0e 0c 00 00       	jmp    80102225 <alltraps>

80101617 <vector15>:
.globl vector15
vector15:
  pushl $0
80101617:	6a 00                	push   $0x0
  pushl $15
80101619:	6a 0f                	push   $0xf
  jmp alltraps
8010161b:	e9 05 0c 00 00       	jmp    80102225 <alltraps>

80101620 <vector16>:
.globl vector16
vector16:
  pushl $0
80101620:	6a 00                	push   $0x0
  pushl $16
80101622:	6a 10                	push   $0x10
  jmp alltraps
80101624:	e9 fc 0b 00 00       	jmp    80102225 <alltraps>

80101629 <vector17>:
.globl vector17
vector17:
  pushl $17
80101629:	6a 11                	push   $0x11
  jmp alltraps
8010162b:	e9 f5 0b 00 00       	jmp    80102225 <alltraps>

80101630 <vector18>:
.globl vector18
vector18:
  pushl $0
80101630:	6a 00                	push   $0x0
  pushl $18
80101632:	6a 12                	push   $0x12
  jmp alltraps
80101634:	e9 ec 0b 00 00       	jmp    80102225 <alltraps>

80101639 <vector19>:
.globl vector19
vector19:
  pushl $0
80101639:	6a 00                	push   $0x0
  pushl $19
8010163b:	6a 13                	push   $0x13
  jmp alltraps
8010163d:	e9 e3 0b 00 00       	jmp    80102225 <alltraps>

80101642 <vector20>:
.globl vector20
vector20:
  pushl $0
80101642:	6a 00                	push   $0x0
  pushl $20
80101644:	6a 14                	push   $0x14
  jmp alltraps
80101646:	e9 da 0b 00 00       	jmp    80102225 <alltraps>

8010164b <vector21>:
.globl vector21
vector21:
  pushl $0
8010164b:	6a 00                	push   $0x0
  pushl $21
8010164d:	6a 15                	push   $0x15
  jmp alltraps
8010164f:	e9 d1 0b 00 00       	jmp    80102225 <alltraps>

80101654 <vector22>:
.globl vector22
vector22:
  pushl $0
80101654:	6a 00                	push   $0x0
  pushl $22
80101656:	6a 16                	push   $0x16
  jmp alltraps
80101658:	e9 c8 0b 00 00       	jmp    80102225 <alltraps>

8010165d <vector23>:
.globl vector23
vector23:
  pushl $0
8010165d:	6a 00                	push   $0x0
  pushl $23
8010165f:	6a 17                	push   $0x17
  jmp alltraps
80101661:	e9 bf 0b 00 00       	jmp    80102225 <alltraps>

80101666 <vector24>:
.globl vector24
vector24:
  pushl $0
80101666:	6a 00                	push   $0x0
  pushl $24
80101668:	6a 18                	push   $0x18
  jmp alltraps
8010166a:	e9 b6 0b 00 00       	jmp    80102225 <alltraps>

8010166f <vector25>:
.globl vector25
vector25:
  pushl $0
8010166f:	6a 00                	push   $0x0
  pushl $25
80101671:	6a 19                	push   $0x19
  jmp alltraps
80101673:	e9 ad 0b 00 00       	jmp    80102225 <alltraps>

80101678 <vector26>:
.globl vector26
vector26:
  pushl $0
80101678:	6a 00                	push   $0x0
  pushl $26
8010167a:	6a 1a                	push   $0x1a
  jmp alltraps
8010167c:	e9 a4 0b 00 00       	jmp    80102225 <alltraps>

80101681 <vector27>:
.globl vector27
vector27:
  pushl $0
80101681:	6a 00                	push   $0x0
  pushl $27
80101683:	6a 1b                	push   $0x1b
  jmp alltraps
80101685:	e9 9b 0b 00 00       	jmp    80102225 <alltraps>

8010168a <vector28>:
.globl vector28
vector28:
  pushl $0
8010168a:	6a 00                	push   $0x0
  pushl $28
8010168c:	6a 1c                	push   $0x1c
  jmp alltraps
8010168e:	e9 92 0b 00 00       	jmp    80102225 <alltraps>

80101693 <vector29>:
.globl vector29
vector29:
  pushl $0
80101693:	6a 00                	push   $0x0
  pushl $29
80101695:	6a 1d                	push   $0x1d
  jmp alltraps
80101697:	e9 89 0b 00 00       	jmp    80102225 <alltraps>

8010169c <vector30>:
.globl vector30
vector30:
  pushl $0
8010169c:	6a 00                	push   $0x0
  pushl $30
8010169e:	6a 1e                	push   $0x1e
  jmp alltraps
801016a0:	e9 80 0b 00 00       	jmp    80102225 <alltraps>

801016a5 <vector31>:
.globl vector31
vector31:
  pushl $0
801016a5:	6a 00                	push   $0x0
  pushl $31
801016a7:	6a 1f                	push   $0x1f
  jmp alltraps
801016a9:	e9 77 0b 00 00       	jmp    80102225 <alltraps>

801016ae <vector32>:
.globl vector32
vector32:
  pushl $0
801016ae:	6a 00                	push   $0x0
  pushl $32
801016b0:	6a 20                	push   $0x20
  jmp alltraps
801016b2:	e9 6e 0b 00 00       	jmp    80102225 <alltraps>

801016b7 <vector33>:
.globl vector33
vector33:
  pushl $0
801016b7:	6a 00                	push   $0x0
  pushl $33
801016b9:	6a 21                	push   $0x21
  jmp alltraps
801016bb:	e9 65 0b 00 00       	jmp    80102225 <alltraps>

801016c0 <vector34>:
.globl vector34
vector34:
  pushl $0
801016c0:	6a 00                	push   $0x0
  pushl $34
801016c2:	6a 22                	push   $0x22
  jmp alltraps
801016c4:	e9 5c 0b 00 00       	jmp    80102225 <alltraps>

801016c9 <vector35>:
.globl vector35
vector35:
  pushl $0
801016c9:	6a 00                	push   $0x0
  pushl $35
801016cb:	6a 23                	push   $0x23
  jmp alltraps
801016cd:	e9 53 0b 00 00       	jmp    80102225 <alltraps>

801016d2 <vector36>:
.globl vector36
vector36:
  pushl $0
801016d2:	6a 00                	push   $0x0
  pushl $36
801016d4:	6a 24                	push   $0x24
  jmp alltraps
801016d6:	e9 4a 0b 00 00       	jmp    80102225 <alltraps>

801016db <vector37>:
.globl vector37
vector37:
  pushl $0
801016db:	6a 00                	push   $0x0
  pushl $37
801016dd:	6a 25                	push   $0x25
  jmp alltraps
801016df:	e9 41 0b 00 00       	jmp    80102225 <alltraps>

801016e4 <vector38>:
.globl vector38
vector38:
  pushl $0
801016e4:	6a 00                	push   $0x0
  pushl $38
801016e6:	6a 26                	push   $0x26
  jmp alltraps
801016e8:	e9 38 0b 00 00       	jmp    80102225 <alltraps>

801016ed <vector39>:
.globl vector39
vector39:
  pushl $0
801016ed:	6a 00                	push   $0x0
  pushl $39
801016ef:	6a 27                	push   $0x27
  jmp alltraps
801016f1:	e9 2f 0b 00 00       	jmp    80102225 <alltraps>

801016f6 <vector40>:
.globl vector40
vector40:
  pushl $0
801016f6:	6a 00                	push   $0x0
  pushl $40
801016f8:	6a 28                	push   $0x28
  jmp alltraps
801016fa:	e9 26 0b 00 00       	jmp    80102225 <alltraps>

801016ff <vector41>:
.globl vector41
vector41:
  pushl $0
801016ff:	6a 00                	push   $0x0
  pushl $41
80101701:	6a 29                	push   $0x29
  jmp alltraps
80101703:	e9 1d 0b 00 00       	jmp    80102225 <alltraps>

80101708 <vector42>:
.globl vector42
vector42:
  pushl $0
80101708:	6a 00                	push   $0x0
  pushl $42
8010170a:	6a 2a                	push   $0x2a
  jmp alltraps
8010170c:	e9 14 0b 00 00       	jmp    80102225 <alltraps>

80101711 <vector43>:
.globl vector43
vector43:
  pushl $0
80101711:	6a 00                	push   $0x0
  pushl $43
80101713:	6a 2b                	push   $0x2b
  jmp alltraps
80101715:	e9 0b 0b 00 00       	jmp    80102225 <alltraps>

8010171a <vector44>:
.globl vector44
vector44:
  pushl $0
8010171a:	6a 00                	push   $0x0
  pushl $44
8010171c:	6a 2c                	push   $0x2c
  jmp alltraps
8010171e:	e9 02 0b 00 00       	jmp    80102225 <alltraps>

80101723 <vector45>:
.globl vector45
vector45:
  pushl $0
80101723:	6a 00                	push   $0x0
  pushl $45
80101725:	6a 2d                	push   $0x2d
  jmp alltraps
80101727:	e9 f9 0a 00 00       	jmp    80102225 <alltraps>

8010172c <vector46>:
.globl vector46
vector46:
  pushl $0
8010172c:	6a 00                	push   $0x0
  pushl $46
8010172e:	6a 2e                	push   $0x2e
  jmp alltraps
80101730:	e9 f0 0a 00 00       	jmp    80102225 <alltraps>

80101735 <vector47>:
.globl vector47
vector47:
  pushl $0
80101735:	6a 00                	push   $0x0
  pushl $47
80101737:	6a 2f                	push   $0x2f
  jmp alltraps
80101739:	e9 e7 0a 00 00       	jmp    80102225 <alltraps>

8010173e <vector48>:
.globl vector48
vector48:
  pushl $0
8010173e:	6a 00                	push   $0x0
  pushl $48
80101740:	6a 30                	push   $0x30
  jmp alltraps
80101742:	e9 de 0a 00 00       	jmp    80102225 <alltraps>

80101747 <vector49>:
.globl vector49
vector49:
  pushl $0
80101747:	6a 00                	push   $0x0
  pushl $49
80101749:	6a 31                	push   $0x31
  jmp alltraps
8010174b:	e9 d5 0a 00 00       	jmp    80102225 <alltraps>

80101750 <vector50>:
.globl vector50
vector50:
  pushl $0
80101750:	6a 00                	push   $0x0
  pushl $50
80101752:	6a 32                	push   $0x32
  jmp alltraps
80101754:	e9 cc 0a 00 00       	jmp    80102225 <alltraps>

80101759 <vector51>:
.globl vector51
vector51:
  pushl $0
80101759:	6a 00                	push   $0x0
  pushl $51
8010175b:	6a 33                	push   $0x33
  jmp alltraps
8010175d:	e9 c3 0a 00 00       	jmp    80102225 <alltraps>

80101762 <vector52>:
.globl vector52
vector52:
  pushl $0
80101762:	6a 00                	push   $0x0
  pushl $52
80101764:	6a 34                	push   $0x34
  jmp alltraps
80101766:	e9 ba 0a 00 00       	jmp    80102225 <alltraps>

8010176b <vector53>:
.globl vector53
vector53:
  pushl $0
8010176b:	6a 00                	push   $0x0
  pushl $53
8010176d:	6a 35                	push   $0x35
  jmp alltraps
8010176f:	e9 b1 0a 00 00       	jmp    80102225 <alltraps>

80101774 <vector54>:
.globl vector54
vector54:
  pushl $0
80101774:	6a 00                	push   $0x0
  pushl $54
80101776:	6a 36                	push   $0x36
  jmp alltraps
80101778:	e9 a8 0a 00 00       	jmp    80102225 <alltraps>

8010177d <vector55>:
.globl vector55
vector55:
  pushl $0
8010177d:	6a 00                	push   $0x0
  pushl $55
8010177f:	6a 37                	push   $0x37
  jmp alltraps
80101781:	e9 9f 0a 00 00       	jmp    80102225 <alltraps>

80101786 <vector56>:
.globl vector56
vector56:
  pushl $0
80101786:	6a 00                	push   $0x0
  pushl $56
80101788:	6a 38                	push   $0x38
  jmp alltraps
8010178a:	e9 96 0a 00 00       	jmp    80102225 <alltraps>

8010178f <vector57>:
.globl vector57
vector57:
  pushl $0
8010178f:	6a 00                	push   $0x0
  pushl $57
80101791:	6a 39                	push   $0x39
  jmp alltraps
80101793:	e9 8d 0a 00 00       	jmp    80102225 <alltraps>

80101798 <vector58>:
.globl vector58
vector58:
  pushl $0
80101798:	6a 00                	push   $0x0
  pushl $58
8010179a:	6a 3a                	push   $0x3a
  jmp alltraps
8010179c:	e9 84 0a 00 00       	jmp    80102225 <alltraps>

801017a1 <vector59>:
.globl vector59
vector59:
  pushl $0
801017a1:	6a 00                	push   $0x0
  pushl $59
801017a3:	6a 3b                	push   $0x3b
  jmp alltraps
801017a5:	e9 7b 0a 00 00       	jmp    80102225 <alltraps>

801017aa <vector60>:
.globl vector60
vector60:
  pushl $0
801017aa:	6a 00                	push   $0x0
  pushl $60
801017ac:	6a 3c                	push   $0x3c
  jmp alltraps
801017ae:	e9 72 0a 00 00       	jmp    80102225 <alltraps>

801017b3 <vector61>:
.globl vector61
vector61:
  pushl $0
801017b3:	6a 00                	push   $0x0
  pushl $61
801017b5:	6a 3d                	push   $0x3d
  jmp alltraps
801017b7:	e9 69 0a 00 00       	jmp    80102225 <alltraps>

801017bc <vector62>:
.globl vector62
vector62:
  pushl $0
801017bc:	6a 00                	push   $0x0
  pushl $62
801017be:	6a 3e                	push   $0x3e
  jmp alltraps
801017c0:	e9 60 0a 00 00       	jmp    80102225 <alltraps>

801017c5 <vector63>:
.globl vector63
vector63:
  pushl $0
801017c5:	6a 00                	push   $0x0
  pushl $63
801017c7:	6a 3f                	push   $0x3f
  jmp alltraps
801017c9:	e9 57 0a 00 00       	jmp    80102225 <alltraps>

801017ce <vector64>:
.globl vector64
vector64:
  pushl $0
801017ce:	6a 00                	push   $0x0
  pushl $64
801017d0:	6a 40                	push   $0x40
  jmp alltraps
801017d2:	e9 4e 0a 00 00       	jmp    80102225 <alltraps>

801017d7 <vector65>:
.globl vector65
vector65:
  pushl $0
801017d7:	6a 00                	push   $0x0
  pushl $65
801017d9:	6a 41                	push   $0x41
  jmp alltraps
801017db:	e9 45 0a 00 00       	jmp    80102225 <alltraps>

801017e0 <vector66>:
.globl vector66
vector66:
  pushl $0
801017e0:	6a 00                	push   $0x0
  pushl $66
801017e2:	6a 42                	push   $0x42
  jmp alltraps
801017e4:	e9 3c 0a 00 00       	jmp    80102225 <alltraps>

801017e9 <vector67>:
.globl vector67
vector67:
  pushl $0
801017e9:	6a 00                	push   $0x0
  pushl $67
801017eb:	6a 43                	push   $0x43
  jmp alltraps
801017ed:	e9 33 0a 00 00       	jmp    80102225 <alltraps>

801017f2 <vector68>:
.globl vector68
vector68:
  pushl $0
801017f2:	6a 00                	push   $0x0
  pushl $68
801017f4:	6a 44                	push   $0x44
  jmp alltraps
801017f6:	e9 2a 0a 00 00       	jmp    80102225 <alltraps>

801017fb <vector69>:
.globl vector69
vector69:
  pushl $0
801017fb:	6a 00                	push   $0x0
  pushl $69
801017fd:	6a 45                	push   $0x45
  jmp alltraps
801017ff:	e9 21 0a 00 00       	jmp    80102225 <alltraps>

80101804 <vector70>:
.globl vector70
vector70:
  pushl $0
80101804:	6a 00                	push   $0x0
  pushl $70
80101806:	6a 46                	push   $0x46
  jmp alltraps
80101808:	e9 18 0a 00 00       	jmp    80102225 <alltraps>

8010180d <vector71>:
.globl vector71
vector71:
  pushl $0
8010180d:	6a 00                	push   $0x0
  pushl $71
8010180f:	6a 47                	push   $0x47
  jmp alltraps
80101811:	e9 0f 0a 00 00       	jmp    80102225 <alltraps>

80101816 <vector72>:
.globl vector72
vector72:
  pushl $0
80101816:	6a 00                	push   $0x0
  pushl $72
80101818:	6a 48                	push   $0x48
  jmp alltraps
8010181a:	e9 06 0a 00 00       	jmp    80102225 <alltraps>

8010181f <vector73>:
.globl vector73
vector73:
  pushl $0
8010181f:	6a 00                	push   $0x0
  pushl $73
80101821:	6a 49                	push   $0x49
  jmp alltraps
80101823:	e9 fd 09 00 00       	jmp    80102225 <alltraps>

80101828 <vector74>:
.globl vector74
vector74:
  pushl $0
80101828:	6a 00                	push   $0x0
  pushl $74
8010182a:	6a 4a                	push   $0x4a
  jmp alltraps
8010182c:	e9 f4 09 00 00       	jmp    80102225 <alltraps>

80101831 <vector75>:
.globl vector75
vector75:
  pushl $0
80101831:	6a 00                	push   $0x0
  pushl $75
80101833:	6a 4b                	push   $0x4b
  jmp alltraps
80101835:	e9 eb 09 00 00       	jmp    80102225 <alltraps>

8010183a <vector76>:
.globl vector76
vector76:
  pushl $0
8010183a:	6a 00                	push   $0x0
  pushl $76
8010183c:	6a 4c                	push   $0x4c
  jmp alltraps
8010183e:	e9 e2 09 00 00       	jmp    80102225 <alltraps>

80101843 <vector77>:
.globl vector77
vector77:
  pushl $0
80101843:	6a 00                	push   $0x0
  pushl $77
80101845:	6a 4d                	push   $0x4d
  jmp alltraps
80101847:	e9 d9 09 00 00       	jmp    80102225 <alltraps>

8010184c <vector78>:
.globl vector78
vector78:
  pushl $0
8010184c:	6a 00                	push   $0x0
  pushl $78
8010184e:	6a 4e                	push   $0x4e
  jmp alltraps
80101850:	e9 d0 09 00 00       	jmp    80102225 <alltraps>

80101855 <vector79>:
.globl vector79
vector79:
  pushl $0
80101855:	6a 00                	push   $0x0
  pushl $79
80101857:	6a 4f                	push   $0x4f
  jmp alltraps
80101859:	e9 c7 09 00 00       	jmp    80102225 <alltraps>

8010185e <vector80>:
.globl vector80
vector80:
  pushl $0
8010185e:	6a 00                	push   $0x0
  pushl $80
80101860:	6a 50                	push   $0x50
  jmp alltraps
80101862:	e9 be 09 00 00       	jmp    80102225 <alltraps>

80101867 <vector81>:
.globl vector81
vector81:
  pushl $0
80101867:	6a 00                	push   $0x0
  pushl $81
80101869:	6a 51                	push   $0x51
  jmp alltraps
8010186b:	e9 b5 09 00 00       	jmp    80102225 <alltraps>

80101870 <vector82>:
.globl vector82
vector82:
  pushl $0
80101870:	6a 00                	push   $0x0
  pushl $82
80101872:	6a 52                	push   $0x52
  jmp alltraps
80101874:	e9 ac 09 00 00       	jmp    80102225 <alltraps>

80101879 <vector83>:
.globl vector83
vector83:
  pushl $0
80101879:	6a 00                	push   $0x0
  pushl $83
8010187b:	6a 53                	push   $0x53
  jmp alltraps
8010187d:	e9 a3 09 00 00       	jmp    80102225 <alltraps>

80101882 <vector84>:
.globl vector84
vector84:
  pushl $0
80101882:	6a 00                	push   $0x0
  pushl $84
80101884:	6a 54                	push   $0x54
  jmp alltraps
80101886:	e9 9a 09 00 00       	jmp    80102225 <alltraps>

8010188b <vector85>:
.globl vector85
vector85:
  pushl $0
8010188b:	6a 00                	push   $0x0
  pushl $85
8010188d:	6a 55                	push   $0x55
  jmp alltraps
8010188f:	e9 91 09 00 00       	jmp    80102225 <alltraps>

80101894 <vector86>:
.globl vector86
vector86:
  pushl $0
80101894:	6a 00                	push   $0x0
  pushl $86
80101896:	6a 56                	push   $0x56
  jmp alltraps
80101898:	e9 88 09 00 00       	jmp    80102225 <alltraps>

8010189d <vector87>:
.globl vector87
vector87:
  pushl $0
8010189d:	6a 00                	push   $0x0
  pushl $87
8010189f:	6a 57                	push   $0x57
  jmp alltraps
801018a1:	e9 7f 09 00 00       	jmp    80102225 <alltraps>

801018a6 <vector88>:
.globl vector88
vector88:
  pushl $0
801018a6:	6a 00                	push   $0x0
  pushl $88
801018a8:	6a 58                	push   $0x58
  jmp alltraps
801018aa:	e9 76 09 00 00       	jmp    80102225 <alltraps>

801018af <vector89>:
.globl vector89
vector89:
  pushl $0
801018af:	6a 00                	push   $0x0
  pushl $89
801018b1:	6a 59                	push   $0x59
  jmp alltraps
801018b3:	e9 6d 09 00 00       	jmp    80102225 <alltraps>

801018b8 <vector90>:
.globl vector90
vector90:
  pushl $0
801018b8:	6a 00                	push   $0x0
  pushl $90
801018ba:	6a 5a                	push   $0x5a
  jmp alltraps
801018bc:	e9 64 09 00 00       	jmp    80102225 <alltraps>

801018c1 <vector91>:
.globl vector91
vector91:
  pushl $0
801018c1:	6a 00                	push   $0x0
  pushl $91
801018c3:	6a 5b                	push   $0x5b
  jmp alltraps
801018c5:	e9 5b 09 00 00       	jmp    80102225 <alltraps>

801018ca <vector92>:
.globl vector92
vector92:
  pushl $0
801018ca:	6a 00                	push   $0x0
  pushl $92
801018cc:	6a 5c                	push   $0x5c
  jmp alltraps
801018ce:	e9 52 09 00 00       	jmp    80102225 <alltraps>

801018d3 <vector93>:
.globl vector93
vector93:
  pushl $0
801018d3:	6a 00                	push   $0x0
  pushl $93
801018d5:	6a 5d                	push   $0x5d
  jmp alltraps
801018d7:	e9 49 09 00 00       	jmp    80102225 <alltraps>

801018dc <vector94>:
.globl vector94
vector94:
  pushl $0
801018dc:	6a 00                	push   $0x0
  pushl $94
801018de:	6a 5e                	push   $0x5e
  jmp alltraps
801018e0:	e9 40 09 00 00       	jmp    80102225 <alltraps>

801018e5 <vector95>:
.globl vector95
vector95:
  pushl $0
801018e5:	6a 00                	push   $0x0
  pushl $95
801018e7:	6a 5f                	push   $0x5f
  jmp alltraps
801018e9:	e9 37 09 00 00       	jmp    80102225 <alltraps>

801018ee <vector96>:
.globl vector96
vector96:
  pushl $0
801018ee:	6a 00                	push   $0x0
  pushl $96
801018f0:	6a 60                	push   $0x60
  jmp alltraps
801018f2:	e9 2e 09 00 00       	jmp    80102225 <alltraps>

801018f7 <vector97>:
.globl vector97
vector97:
  pushl $0
801018f7:	6a 00                	push   $0x0
  pushl $97
801018f9:	6a 61                	push   $0x61
  jmp alltraps
801018fb:	e9 25 09 00 00       	jmp    80102225 <alltraps>

80101900 <vector98>:
.globl vector98
vector98:
  pushl $0
80101900:	6a 00                	push   $0x0
  pushl $98
80101902:	6a 62                	push   $0x62
  jmp alltraps
80101904:	e9 1c 09 00 00       	jmp    80102225 <alltraps>

80101909 <vector99>:
.globl vector99
vector99:
  pushl $0
80101909:	6a 00                	push   $0x0
  pushl $99
8010190b:	6a 63                	push   $0x63
  jmp alltraps
8010190d:	e9 13 09 00 00       	jmp    80102225 <alltraps>

80101912 <vector100>:
.globl vector100
vector100:
  pushl $0
80101912:	6a 00                	push   $0x0
  pushl $100
80101914:	6a 64                	push   $0x64
  jmp alltraps
80101916:	e9 0a 09 00 00       	jmp    80102225 <alltraps>

8010191b <vector101>:
.globl vector101
vector101:
  pushl $0
8010191b:	6a 00                	push   $0x0
  pushl $101
8010191d:	6a 65                	push   $0x65
  jmp alltraps
8010191f:	e9 01 09 00 00       	jmp    80102225 <alltraps>

80101924 <vector102>:
.globl vector102
vector102:
  pushl $0
80101924:	6a 00                	push   $0x0
  pushl $102
80101926:	6a 66                	push   $0x66
  jmp alltraps
80101928:	e9 f8 08 00 00       	jmp    80102225 <alltraps>

8010192d <vector103>:
.globl vector103
vector103:
  pushl $0
8010192d:	6a 00                	push   $0x0
  pushl $103
8010192f:	6a 67                	push   $0x67
  jmp alltraps
80101931:	e9 ef 08 00 00       	jmp    80102225 <alltraps>

80101936 <vector104>:
.globl vector104
vector104:
  pushl $0
80101936:	6a 00                	push   $0x0
  pushl $104
80101938:	6a 68                	push   $0x68
  jmp alltraps
8010193a:	e9 e6 08 00 00       	jmp    80102225 <alltraps>

8010193f <vector105>:
.globl vector105
vector105:
  pushl $0
8010193f:	6a 00                	push   $0x0
  pushl $105
80101941:	6a 69                	push   $0x69
  jmp alltraps
80101943:	e9 dd 08 00 00       	jmp    80102225 <alltraps>

80101948 <vector106>:
.globl vector106
vector106:
  pushl $0
80101948:	6a 00                	push   $0x0
  pushl $106
8010194a:	6a 6a                	push   $0x6a
  jmp alltraps
8010194c:	e9 d4 08 00 00       	jmp    80102225 <alltraps>

80101951 <vector107>:
.globl vector107
vector107:
  pushl $0
80101951:	6a 00                	push   $0x0
  pushl $107
80101953:	6a 6b                	push   $0x6b
  jmp alltraps
80101955:	e9 cb 08 00 00       	jmp    80102225 <alltraps>

8010195a <vector108>:
.globl vector108
vector108:
  pushl $0
8010195a:	6a 00                	push   $0x0
  pushl $108
8010195c:	6a 6c                	push   $0x6c
  jmp alltraps
8010195e:	e9 c2 08 00 00       	jmp    80102225 <alltraps>

80101963 <vector109>:
.globl vector109
vector109:
  pushl $0
80101963:	6a 00                	push   $0x0
  pushl $109
80101965:	6a 6d                	push   $0x6d
  jmp alltraps
80101967:	e9 b9 08 00 00       	jmp    80102225 <alltraps>

8010196c <vector110>:
.globl vector110
vector110:
  pushl $0
8010196c:	6a 00                	push   $0x0
  pushl $110
8010196e:	6a 6e                	push   $0x6e
  jmp alltraps
80101970:	e9 b0 08 00 00       	jmp    80102225 <alltraps>

80101975 <vector111>:
.globl vector111
vector111:
  pushl $0
80101975:	6a 00                	push   $0x0
  pushl $111
80101977:	6a 6f                	push   $0x6f
  jmp alltraps
80101979:	e9 a7 08 00 00       	jmp    80102225 <alltraps>

8010197e <vector112>:
.globl vector112
vector112:
  pushl $0
8010197e:	6a 00                	push   $0x0
  pushl $112
80101980:	6a 70                	push   $0x70
  jmp alltraps
80101982:	e9 9e 08 00 00       	jmp    80102225 <alltraps>

80101987 <vector113>:
.globl vector113
vector113:
  pushl $0
80101987:	6a 00                	push   $0x0
  pushl $113
80101989:	6a 71                	push   $0x71
  jmp alltraps
8010198b:	e9 95 08 00 00       	jmp    80102225 <alltraps>

80101990 <vector114>:
.globl vector114
vector114:
  pushl $0
80101990:	6a 00                	push   $0x0
  pushl $114
80101992:	6a 72                	push   $0x72
  jmp alltraps
80101994:	e9 8c 08 00 00       	jmp    80102225 <alltraps>

80101999 <vector115>:
.globl vector115
vector115:
  pushl $0
80101999:	6a 00                	push   $0x0
  pushl $115
8010199b:	6a 73                	push   $0x73
  jmp alltraps
8010199d:	e9 83 08 00 00       	jmp    80102225 <alltraps>

801019a2 <vector116>:
.globl vector116
vector116:
  pushl $0
801019a2:	6a 00                	push   $0x0
  pushl $116
801019a4:	6a 74                	push   $0x74
  jmp alltraps
801019a6:	e9 7a 08 00 00       	jmp    80102225 <alltraps>

801019ab <vector117>:
.globl vector117
vector117:
  pushl $0
801019ab:	6a 00                	push   $0x0
  pushl $117
801019ad:	6a 75                	push   $0x75
  jmp alltraps
801019af:	e9 71 08 00 00       	jmp    80102225 <alltraps>

801019b4 <vector118>:
.globl vector118
vector118:
  pushl $0
801019b4:	6a 00                	push   $0x0
  pushl $118
801019b6:	6a 76                	push   $0x76
  jmp alltraps
801019b8:	e9 68 08 00 00       	jmp    80102225 <alltraps>

801019bd <vector119>:
.globl vector119
vector119:
  pushl $0
801019bd:	6a 00                	push   $0x0
  pushl $119
801019bf:	6a 77                	push   $0x77
  jmp alltraps
801019c1:	e9 5f 08 00 00       	jmp    80102225 <alltraps>

801019c6 <vector120>:
.globl vector120
vector120:
  pushl $0
801019c6:	6a 00                	push   $0x0
  pushl $120
801019c8:	6a 78                	push   $0x78
  jmp alltraps
801019ca:	e9 56 08 00 00       	jmp    80102225 <alltraps>

801019cf <vector121>:
.globl vector121
vector121:
  pushl $0
801019cf:	6a 00                	push   $0x0
  pushl $121
801019d1:	6a 79                	push   $0x79
  jmp alltraps
801019d3:	e9 4d 08 00 00       	jmp    80102225 <alltraps>

801019d8 <vector122>:
.globl vector122
vector122:
  pushl $0
801019d8:	6a 00                	push   $0x0
  pushl $122
801019da:	6a 7a                	push   $0x7a
  jmp alltraps
801019dc:	e9 44 08 00 00       	jmp    80102225 <alltraps>

801019e1 <vector123>:
.globl vector123
vector123:
  pushl $0
801019e1:	6a 00                	push   $0x0
  pushl $123
801019e3:	6a 7b                	push   $0x7b
  jmp alltraps
801019e5:	e9 3b 08 00 00       	jmp    80102225 <alltraps>

801019ea <vector124>:
.globl vector124
vector124:
  pushl $0
801019ea:	6a 00                	push   $0x0
  pushl $124
801019ec:	6a 7c                	push   $0x7c
  jmp alltraps
801019ee:	e9 32 08 00 00       	jmp    80102225 <alltraps>

801019f3 <vector125>:
.globl vector125
vector125:
  pushl $0
801019f3:	6a 00                	push   $0x0
  pushl $125
801019f5:	6a 7d                	push   $0x7d
  jmp alltraps
801019f7:	e9 29 08 00 00       	jmp    80102225 <alltraps>

801019fc <vector126>:
.globl vector126
vector126:
  pushl $0
801019fc:	6a 00                	push   $0x0
  pushl $126
801019fe:	6a 7e                	push   $0x7e
  jmp alltraps
80101a00:	e9 20 08 00 00       	jmp    80102225 <alltraps>

80101a05 <vector127>:
.globl vector127
vector127:
  pushl $0
80101a05:	6a 00                	push   $0x0
  pushl $127
80101a07:	6a 7f                	push   $0x7f
  jmp alltraps
80101a09:	e9 17 08 00 00       	jmp    80102225 <alltraps>

80101a0e <vector128>:
.globl vector128
vector128:
  pushl $0
80101a0e:	6a 00                	push   $0x0
  pushl $128
80101a10:	68 80 00 00 00       	push   $0x80
  jmp alltraps
80101a15:	e9 0b 08 00 00       	jmp    80102225 <alltraps>

80101a1a <vector129>:
.globl vector129
vector129:
  pushl $0
80101a1a:	6a 00                	push   $0x0
  pushl $129
80101a1c:	68 81 00 00 00       	push   $0x81
  jmp alltraps
80101a21:	e9 ff 07 00 00       	jmp    80102225 <alltraps>

80101a26 <vector130>:
.globl vector130
vector130:
  pushl $0
80101a26:	6a 00                	push   $0x0
  pushl $130
80101a28:	68 82 00 00 00       	push   $0x82
  jmp alltraps
80101a2d:	e9 f3 07 00 00       	jmp    80102225 <alltraps>

80101a32 <vector131>:
.globl vector131
vector131:
  pushl $0
80101a32:	6a 00                	push   $0x0
  pushl $131
80101a34:	68 83 00 00 00       	push   $0x83
  jmp alltraps
80101a39:	e9 e7 07 00 00       	jmp    80102225 <alltraps>

80101a3e <vector132>:
.globl vector132
vector132:
  pushl $0
80101a3e:	6a 00                	push   $0x0
  pushl $132
80101a40:	68 84 00 00 00       	push   $0x84
  jmp alltraps
80101a45:	e9 db 07 00 00       	jmp    80102225 <alltraps>

80101a4a <vector133>:
.globl vector133
vector133:
  pushl $0
80101a4a:	6a 00                	push   $0x0
  pushl $133
80101a4c:	68 85 00 00 00       	push   $0x85
  jmp alltraps
80101a51:	e9 cf 07 00 00       	jmp    80102225 <alltraps>

80101a56 <vector134>:
.globl vector134
vector134:
  pushl $0
80101a56:	6a 00                	push   $0x0
  pushl $134
80101a58:	68 86 00 00 00       	push   $0x86
  jmp alltraps
80101a5d:	e9 c3 07 00 00       	jmp    80102225 <alltraps>

80101a62 <vector135>:
.globl vector135
vector135:
  pushl $0
80101a62:	6a 00                	push   $0x0
  pushl $135
80101a64:	68 87 00 00 00       	push   $0x87
  jmp alltraps
80101a69:	e9 b7 07 00 00       	jmp    80102225 <alltraps>

80101a6e <vector136>:
.globl vector136
vector136:
  pushl $0
80101a6e:	6a 00                	push   $0x0
  pushl $136
80101a70:	68 88 00 00 00       	push   $0x88
  jmp alltraps
80101a75:	e9 ab 07 00 00       	jmp    80102225 <alltraps>

80101a7a <vector137>:
.globl vector137
vector137:
  pushl $0
80101a7a:	6a 00                	push   $0x0
  pushl $137
80101a7c:	68 89 00 00 00       	push   $0x89
  jmp alltraps
80101a81:	e9 9f 07 00 00       	jmp    80102225 <alltraps>

80101a86 <vector138>:
.globl vector138
vector138:
  pushl $0
80101a86:	6a 00                	push   $0x0
  pushl $138
80101a88:	68 8a 00 00 00       	push   $0x8a
  jmp alltraps
80101a8d:	e9 93 07 00 00       	jmp    80102225 <alltraps>

80101a92 <vector139>:
.globl vector139
vector139:
  pushl $0
80101a92:	6a 00                	push   $0x0
  pushl $139
80101a94:	68 8b 00 00 00       	push   $0x8b
  jmp alltraps
80101a99:	e9 87 07 00 00       	jmp    80102225 <alltraps>

80101a9e <vector140>:
.globl vector140
vector140:
  pushl $0
80101a9e:	6a 00                	push   $0x0
  pushl $140
80101aa0:	68 8c 00 00 00       	push   $0x8c
  jmp alltraps
80101aa5:	e9 7b 07 00 00       	jmp    80102225 <alltraps>

80101aaa <vector141>:
.globl vector141
vector141:
  pushl $0
80101aaa:	6a 00                	push   $0x0
  pushl $141
80101aac:	68 8d 00 00 00       	push   $0x8d
  jmp alltraps
80101ab1:	e9 6f 07 00 00       	jmp    80102225 <alltraps>

80101ab6 <vector142>:
.globl vector142
vector142:
  pushl $0
80101ab6:	6a 00                	push   $0x0
  pushl $142
80101ab8:	68 8e 00 00 00       	push   $0x8e
  jmp alltraps
80101abd:	e9 63 07 00 00       	jmp    80102225 <alltraps>

80101ac2 <vector143>:
.globl vector143
vector143:
  pushl $0
80101ac2:	6a 00                	push   $0x0
  pushl $143
80101ac4:	68 8f 00 00 00       	push   $0x8f
  jmp alltraps
80101ac9:	e9 57 07 00 00       	jmp    80102225 <alltraps>

80101ace <vector144>:
.globl vector144
vector144:
  pushl $0
80101ace:	6a 00                	push   $0x0
  pushl $144
80101ad0:	68 90 00 00 00       	push   $0x90
  jmp alltraps
80101ad5:	e9 4b 07 00 00       	jmp    80102225 <alltraps>

80101ada <vector145>:
.globl vector145
vector145:
  pushl $0
80101ada:	6a 00                	push   $0x0
  pushl $145
80101adc:	68 91 00 00 00       	push   $0x91
  jmp alltraps
80101ae1:	e9 3f 07 00 00       	jmp    80102225 <alltraps>

80101ae6 <vector146>:
.globl vector146
vector146:
  pushl $0
80101ae6:	6a 00                	push   $0x0
  pushl $146
80101ae8:	68 92 00 00 00       	push   $0x92
  jmp alltraps
80101aed:	e9 33 07 00 00       	jmp    80102225 <alltraps>

80101af2 <vector147>:
.globl vector147
vector147:
  pushl $0
80101af2:	6a 00                	push   $0x0
  pushl $147
80101af4:	68 93 00 00 00       	push   $0x93
  jmp alltraps
80101af9:	e9 27 07 00 00       	jmp    80102225 <alltraps>

80101afe <vector148>:
.globl vector148
vector148:
  pushl $0
80101afe:	6a 00                	push   $0x0
  pushl $148
80101b00:	68 94 00 00 00       	push   $0x94
  jmp alltraps
80101b05:	e9 1b 07 00 00       	jmp    80102225 <alltraps>

80101b0a <vector149>:
.globl vector149
vector149:
  pushl $0
80101b0a:	6a 00                	push   $0x0
  pushl $149
80101b0c:	68 95 00 00 00       	push   $0x95
  jmp alltraps
80101b11:	e9 0f 07 00 00       	jmp    80102225 <alltraps>

80101b16 <vector150>:
.globl vector150
vector150:
  pushl $0
80101b16:	6a 00                	push   $0x0
  pushl $150
80101b18:	68 96 00 00 00       	push   $0x96
  jmp alltraps
80101b1d:	e9 03 07 00 00       	jmp    80102225 <alltraps>

80101b22 <vector151>:
.globl vector151
vector151:
  pushl $0
80101b22:	6a 00                	push   $0x0
  pushl $151
80101b24:	68 97 00 00 00       	push   $0x97
  jmp alltraps
80101b29:	e9 f7 06 00 00       	jmp    80102225 <alltraps>

80101b2e <vector152>:
.globl vector152
vector152:
  pushl $0
80101b2e:	6a 00                	push   $0x0
  pushl $152
80101b30:	68 98 00 00 00       	push   $0x98
  jmp alltraps
80101b35:	e9 eb 06 00 00       	jmp    80102225 <alltraps>

80101b3a <vector153>:
.globl vector153
vector153:
  pushl $0
80101b3a:	6a 00                	push   $0x0
  pushl $153
80101b3c:	68 99 00 00 00       	push   $0x99
  jmp alltraps
80101b41:	e9 df 06 00 00       	jmp    80102225 <alltraps>

80101b46 <vector154>:
.globl vector154
vector154:
  pushl $0
80101b46:	6a 00                	push   $0x0
  pushl $154
80101b48:	68 9a 00 00 00       	push   $0x9a
  jmp alltraps
80101b4d:	e9 d3 06 00 00       	jmp    80102225 <alltraps>

80101b52 <vector155>:
.globl vector155
vector155:
  pushl $0
80101b52:	6a 00                	push   $0x0
  pushl $155
80101b54:	68 9b 00 00 00       	push   $0x9b
  jmp alltraps
80101b59:	e9 c7 06 00 00       	jmp    80102225 <alltraps>

80101b5e <vector156>:
.globl vector156
vector156:
  pushl $0
80101b5e:	6a 00                	push   $0x0
  pushl $156
80101b60:	68 9c 00 00 00       	push   $0x9c
  jmp alltraps
80101b65:	e9 bb 06 00 00       	jmp    80102225 <alltraps>

80101b6a <vector157>:
.globl vector157
vector157:
  pushl $0
80101b6a:	6a 00                	push   $0x0
  pushl $157
80101b6c:	68 9d 00 00 00       	push   $0x9d
  jmp alltraps
80101b71:	e9 af 06 00 00       	jmp    80102225 <alltraps>

80101b76 <vector158>:
.globl vector158
vector158:
  pushl $0
80101b76:	6a 00                	push   $0x0
  pushl $158
80101b78:	68 9e 00 00 00       	push   $0x9e
  jmp alltraps
80101b7d:	e9 a3 06 00 00       	jmp    80102225 <alltraps>

80101b82 <vector159>:
.globl vector159
vector159:
  pushl $0
80101b82:	6a 00                	push   $0x0
  pushl $159
80101b84:	68 9f 00 00 00       	push   $0x9f
  jmp alltraps
80101b89:	e9 97 06 00 00       	jmp    80102225 <alltraps>

80101b8e <vector160>:
.globl vector160
vector160:
  pushl $0
80101b8e:	6a 00                	push   $0x0
  pushl $160
80101b90:	68 a0 00 00 00       	push   $0xa0
  jmp alltraps
80101b95:	e9 8b 06 00 00       	jmp    80102225 <alltraps>

80101b9a <vector161>:
.globl vector161
vector161:
  pushl $0
80101b9a:	6a 00                	push   $0x0
  pushl $161
80101b9c:	68 a1 00 00 00       	push   $0xa1
  jmp alltraps
80101ba1:	e9 7f 06 00 00       	jmp    80102225 <alltraps>

80101ba6 <vector162>:
.globl vector162
vector162:
  pushl $0
80101ba6:	6a 00                	push   $0x0
  pushl $162
80101ba8:	68 a2 00 00 00       	push   $0xa2
  jmp alltraps
80101bad:	e9 73 06 00 00       	jmp    80102225 <alltraps>

80101bb2 <vector163>:
.globl vector163
vector163:
  pushl $0
80101bb2:	6a 00                	push   $0x0
  pushl $163
80101bb4:	68 a3 00 00 00       	push   $0xa3
  jmp alltraps
80101bb9:	e9 67 06 00 00       	jmp    80102225 <alltraps>

80101bbe <vector164>:
.globl vector164
vector164:
  pushl $0
80101bbe:	6a 00                	push   $0x0
  pushl $164
80101bc0:	68 a4 00 00 00       	push   $0xa4
  jmp alltraps
80101bc5:	e9 5b 06 00 00       	jmp    80102225 <alltraps>

80101bca <vector165>:
.globl vector165
vector165:
  pushl $0
80101bca:	6a 00                	push   $0x0
  pushl $165
80101bcc:	68 a5 00 00 00       	push   $0xa5
  jmp alltraps
80101bd1:	e9 4f 06 00 00       	jmp    80102225 <alltraps>

80101bd6 <vector166>:
.globl vector166
vector166:
  pushl $0
80101bd6:	6a 00                	push   $0x0
  pushl $166
80101bd8:	68 a6 00 00 00       	push   $0xa6
  jmp alltraps
80101bdd:	e9 43 06 00 00       	jmp    80102225 <alltraps>

80101be2 <vector167>:
.globl vector167
vector167:
  pushl $0
80101be2:	6a 00                	push   $0x0
  pushl $167
80101be4:	68 a7 00 00 00       	push   $0xa7
  jmp alltraps
80101be9:	e9 37 06 00 00       	jmp    80102225 <alltraps>

80101bee <vector168>:
.globl vector168
vector168:
  pushl $0
80101bee:	6a 00                	push   $0x0
  pushl $168
80101bf0:	68 a8 00 00 00       	push   $0xa8
  jmp alltraps
80101bf5:	e9 2b 06 00 00       	jmp    80102225 <alltraps>

80101bfa <vector169>:
.globl vector169
vector169:
  pushl $0
80101bfa:	6a 00                	push   $0x0
  pushl $169
80101bfc:	68 a9 00 00 00       	push   $0xa9
  jmp alltraps
80101c01:	e9 1f 06 00 00       	jmp    80102225 <alltraps>

80101c06 <vector170>:
.globl vector170
vector170:
  pushl $0
80101c06:	6a 00                	push   $0x0
  pushl $170
80101c08:	68 aa 00 00 00       	push   $0xaa
  jmp alltraps
80101c0d:	e9 13 06 00 00       	jmp    80102225 <alltraps>

80101c12 <vector171>:
.globl vector171
vector171:
  pushl $0
80101c12:	6a 00                	push   $0x0
  pushl $171
80101c14:	68 ab 00 00 00       	push   $0xab
  jmp alltraps
80101c19:	e9 07 06 00 00       	jmp    80102225 <alltraps>

80101c1e <vector172>:
.globl vector172
vector172:
  pushl $0
80101c1e:	6a 00                	push   $0x0
  pushl $172
80101c20:	68 ac 00 00 00       	push   $0xac
  jmp alltraps
80101c25:	e9 fb 05 00 00       	jmp    80102225 <alltraps>

80101c2a <vector173>:
.globl vector173
vector173:
  pushl $0
80101c2a:	6a 00                	push   $0x0
  pushl $173
80101c2c:	68 ad 00 00 00       	push   $0xad
  jmp alltraps
80101c31:	e9 ef 05 00 00       	jmp    80102225 <alltraps>

80101c36 <vector174>:
.globl vector174
vector174:
  pushl $0
80101c36:	6a 00                	push   $0x0
  pushl $174
80101c38:	68 ae 00 00 00       	push   $0xae
  jmp alltraps
80101c3d:	e9 e3 05 00 00       	jmp    80102225 <alltraps>

80101c42 <vector175>:
.globl vector175
vector175:
  pushl $0
80101c42:	6a 00                	push   $0x0
  pushl $175
80101c44:	68 af 00 00 00       	push   $0xaf
  jmp alltraps
80101c49:	e9 d7 05 00 00       	jmp    80102225 <alltraps>

80101c4e <vector176>:
.globl vector176
vector176:
  pushl $0
80101c4e:	6a 00                	push   $0x0
  pushl $176
80101c50:	68 b0 00 00 00       	push   $0xb0
  jmp alltraps
80101c55:	e9 cb 05 00 00       	jmp    80102225 <alltraps>

80101c5a <vector177>:
.globl vector177
vector177:
  pushl $0
80101c5a:	6a 00                	push   $0x0
  pushl $177
80101c5c:	68 b1 00 00 00       	push   $0xb1
  jmp alltraps
80101c61:	e9 bf 05 00 00       	jmp    80102225 <alltraps>

80101c66 <vector178>:
.globl vector178
vector178:
  pushl $0
80101c66:	6a 00                	push   $0x0
  pushl $178
80101c68:	68 b2 00 00 00       	push   $0xb2
  jmp alltraps
80101c6d:	e9 b3 05 00 00       	jmp    80102225 <alltraps>

80101c72 <vector179>:
.globl vector179
vector179:
  pushl $0
80101c72:	6a 00                	push   $0x0
  pushl $179
80101c74:	68 b3 00 00 00       	push   $0xb3
  jmp alltraps
80101c79:	e9 a7 05 00 00       	jmp    80102225 <alltraps>

80101c7e <vector180>:
.globl vector180
vector180:
  pushl $0
80101c7e:	6a 00                	push   $0x0
  pushl $180
80101c80:	68 b4 00 00 00       	push   $0xb4
  jmp alltraps
80101c85:	e9 9b 05 00 00       	jmp    80102225 <alltraps>

80101c8a <vector181>:
.globl vector181
vector181:
  pushl $0
80101c8a:	6a 00                	push   $0x0
  pushl $181
80101c8c:	68 b5 00 00 00       	push   $0xb5
  jmp alltraps
80101c91:	e9 8f 05 00 00       	jmp    80102225 <alltraps>

80101c96 <vector182>:
.globl vector182
vector182:
  pushl $0
80101c96:	6a 00                	push   $0x0
  pushl $182
80101c98:	68 b6 00 00 00       	push   $0xb6
  jmp alltraps
80101c9d:	e9 83 05 00 00       	jmp    80102225 <alltraps>

80101ca2 <vector183>:
.globl vector183
vector183:
  pushl $0
80101ca2:	6a 00                	push   $0x0
  pushl $183
80101ca4:	68 b7 00 00 00       	push   $0xb7
  jmp alltraps
80101ca9:	e9 77 05 00 00       	jmp    80102225 <alltraps>

80101cae <vector184>:
.globl vector184
vector184:
  pushl $0
80101cae:	6a 00                	push   $0x0
  pushl $184
80101cb0:	68 b8 00 00 00       	push   $0xb8
  jmp alltraps
80101cb5:	e9 6b 05 00 00       	jmp    80102225 <alltraps>

80101cba <vector185>:
.globl vector185
vector185:
  pushl $0
80101cba:	6a 00                	push   $0x0
  pushl $185
80101cbc:	68 b9 00 00 00       	push   $0xb9
  jmp alltraps
80101cc1:	e9 5f 05 00 00       	jmp    80102225 <alltraps>

80101cc6 <vector186>:
.globl vector186
vector186:
  pushl $0
80101cc6:	6a 00                	push   $0x0
  pushl $186
80101cc8:	68 ba 00 00 00       	push   $0xba
  jmp alltraps
80101ccd:	e9 53 05 00 00       	jmp    80102225 <alltraps>

80101cd2 <vector187>:
.globl vector187
vector187:
  pushl $0
80101cd2:	6a 00                	push   $0x0
  pushl $187
80101cd4:	68 bb 00 00 00       	push   $0xbb
  jmp alltraps
80101cd9:	e9 47 05 00 00       	jmp    80102225 <alltraps>

80101cde <vector188>:
.globl vector188
vector188:
  pushl $0
80101cde:	6a 00                	push   $0x0
  pushl $188
80101ce0:	68 bc 00 00 00       	push   $0xbc
  jmp alltraps
80101ce5:	e9 3b 05 00 00       	jmp    80102225 <alltraps>

80101cea <vector189>:
.globl vector189
vector189:
  pushl $0
80101cea:	6a 00                	push   $0x0
  pushl $189
80101cec:	68 bd 00 00 00       	push   $0xbd
  jmp alltraps
80101cf1:	e9 2f 05 00 00       	jmp    80102225 <alltraps>

80101cf6 <vector190>:
.globl vector190
vector190:
  pushl $0
80101cf6:	6a 00                	push   $0x0
  pushl $190
80101cf8:	68 be 00 00 00       	push   $0xbe
  jmp alltraps
80101cfd:	e9 23 05 00 00       	jmp    80102225 <alltraps>

80101d02 <vector191>:
.globl vector191
vector191:
  pushl $0
80101d02:	6a 00                	push   $0x0
  pushl $191
80101d04:	68 bf 00 00 00       	push   $0xbf
  jmp alltraps
80101d09:	e9 17 05 00 00       	jmp    80102225 <alltraps>

80101d0e <vector192>:
.globl vector192
vector192:
  pushl $0
80101d0e:	6a 00                	push   $0x0
  pushl $192
80101d10:	68 c0 00 00 00       	push   $0xc0
  jmp alltraps
80101d15:	e9 0b 05 00 00       	jmp    80102225 <alltraps>

80101d1a <vector193>:
.globl vector193
vector193:
  pushl $0
80101d1a:	6a 00                	push   $0x0
  pushl $193
80101d1c:	68 c1 00 00 00       	push   $0xc1
  jmp alltraps
80101d21:	e9 ff 04 00 00       	jmp    80102225 <alltraps>

80101d26 <vector194>:
.globl vector194
vector194:
  pushl $0
80101d26:	6a 00                	push   $0x0
  pushl $194
80101d28:	68 c2 00 00 00       	push   $0xc2
  jmp alltraps
80101d2d:	e9 f3 04 00 00       	jmp    80102225 <alltraps>

80101d32 <vector195>:
.globl vector195
vector195:
  pushl $0
80101d32:	6a 00                	push   $0x0
  pushl $195
80101d34:	68 c3 00 00 00       	push   $0xc3
  jmp alltraps
80101d39:	e9 e7 04 00 00       	jmp    80102225 <alltraps>

80101d3e <vector196>:
.globl vector196
vector196:
  pushl $0
80101d3e:	6a 00                	push   $0x0
  pushl $196
80101d40:	68 c4 00 00 00       	push   $0xc4
  jmp alltraps
80101d45:	e9 db 04 00 00       	jmp    80102225 <alltraps>

80101d4a <vector197>:
.globl vector197
vector197:
  pushl $0
80101d4a:	6a 00                	push   $0x0
  pushl $197
80101d4c:	68 c5 00 00 00       	push   $0xc5
  jmp alltraps
80101d51:	e9 cf 04 00 00       	jmp    80102225 <alltraps>

80101d56 <vector198>:
.globl vector198
vector198:
  pushl $0
80101d56:	6a 00                	push   $0x0
  pushl $198
80101d58:	68 c6 00 00 00       	push   $0xc6
  jmp alltraps
80101d5d:	e9 c3 04 00 00       	jmp    80102225 <alltraps>

80101d62 <vector199>:
.globl vector199
vector199:
  pushl $0
80101d62:	6a 00                	push   $0x0
  pushl $199
80101d64:	68 c7 00 00 00       	push   $0xc7
  jmp alltraps
80101d69:	e9 b7 04 00 00       	jmp    80102225 <alltraps>

80101d6e <vector200>:
.globl vector200
vector200:
  pushl $0
80101d6e:	6a 00                	push   $0x0
  pushl $200
80101d70:	68 c8 00 00 00       	push   $0xc8
  jmp alltraps
80101d75:	e9 ab 04 00 00       	jmp    80102225 <alltraps>

80101d7a <vector201>:
.globl vector201
vector201:
  pushl $0
80101d7a:	6a 00                	push   $0x0
  pushl $201
80101d7c:	68 c9 00 00 00       	push   $0xc9
  jmp alltraps
80101d81:	e9 9f 04 00 00       	jmp    80102225 <alltraps>

80101d86 <vector202>:
.globl vector202
vector202:
  pushl $0
80101d86:	6a 00                	push   $0x0
  pushl $202
80101d88:	68 ca 00 00 00       	push   $0xca
  jmp alltraps
80101d8d:	e9 93 04 00 00       	jmp    80102225 <alltraps>

80101d92 <vector203>:
.globl vector203
vector203:
  pushl $0
80101d92:	6a 00                	push   $0x0
  pushl $203
80101d94:	68 cb 00 00 00       	push   $0xcb
  jmp alltraps
80101d99:	e9 87 04 00 00       	jmp    80102225 <alltraps>

80101d9e <vector204>:
.globl vector204
vector204:
  pushl $0
80101d9e:	6a 00                	push   $0x0
  pushl $204
80101da0:	68 cc 00 00 00       	push   $0xcc
  jmp alltraps
80101da5:	e9 7b 04 00 00       	jmp    80102225 <alltraps>

80101daa <vector205>:
.globl vector205
vector205:
  pushl $0
80101daa:	6a 00                	push   $0x0
  pushl $205
80101dac:	68 cd 00 00 00       	push   $0xcd
  jmp alltraps
80101db1:	e9 6f 04 00 00       	jmp    80102225 <alltraps>

80101db6 <vector206>:
.globl vector206
vector206:
  pushl $0
80101db6:	6a 00                	push   $0x0
  pushl $206
80101db8:	68 ce 00 00 00       	push   $0xce
  jmp alltraps
80101dbd:	e9 63 04 00 00       	jmp    80102225 <alltraps>

80101dc2 <vector207>:
.globl vector207
vector207:
  pushl $0
80101dc2:	6a 00                	push   $0x0
  pushl $207
80101dc4:	68 cf 00 00 00       	push   $0xcf
  jmp alltraps
80101dc9:	e9 57 04 00 00       	jmp    80102225 <alltraps>

80101dce <vector208>:
.globl vector208
vector208:
  pushl $0
80101dce:	6a 00                	push   $0x0
  pushl $208
80101dd0:	68 d0 00 00 00       	push   $0xd0
  jmp alltraps
80101dd5:	e9 4b 04 00 00       	jmp    80102225 <alltraps>

80101dda <vector209>:
.globl vector209
vector209:
  pushl $0
80101dda:	6a 00                	push   $0x0
  pushl $209
80101ddc:	68 d1 00 00 00       	push   $0xd1
  jmp alltraps
80101de1:	e9 3f 04 00 00       	jmp    80102225 <alltraps>

80101de6 <vector210>:
.globl vector210
vector210:
  pushl $0
80101de6:	6a 00                	push   $0x0
  pushl $210
80101de8:	68 d2 00 00 00       	push   $0xd2
  jmp alltraps
80101ded:	e9 33 04 00 00       	jmp    80102225 <alltraps>

80101df2 <vector211>:
.globl vector211
vector211:
  pushl $0
80101df2:	6a 00                	push   $0x0
  pushl $211
80101df4:	68 d3 00 00 00       	push   $0xd3
  jmp alltraps
80101df9:	e9 27 04 00 00       	jmp    80102225 <alltraps>

80101dfe <vector212>:
.globl vector212
vector212:
  pushl $0
80101dfe:	6a 00                	push   $0x0
  pushl $212
80101e00:	68 d4 00 00 00       	push   $0xd4
  jmp alltraps
80101e05:	e9 1b 04 00 00       	jmp    80102225 <alltraps>

80101e0a <vector213>:
.globl vector213
vector213:
  pushl $0
80101e0a:	6a 00                	push   $0x0
  pushl $213
80101e0c:	68 d5 00 00 00       	push   $0xd5
  jmp alltraps
80101e11:	e9 0f 04 00 00       	jmp    80102225 <alltraps>

80101e16 <vector214>:
.globl vector214
vector214:
  pushl $0
80101e16:	6a 00                	push   $0x0
  pushl $214
80101e18:	68 d6 00 00 00       	push   $0xd6
  jmp alltraps
80101e1d:	e9 03 04 00 00       	jmp    80102225 <alltraps>

80101e22 <vector215>:
.globl vector215
vector215:
  pushl $0
80101e22:	6a 00                	push   $0x0
  pushl $215
80101e24:	68 d7 00 00 00       	push   $0xd7
  jmp alltraps
80101e29:	e9 f7 03 00 00       	jmp    80102225 <alltraps>

80101e2e <vector216>:
.globl vector216
vector216:
  pushl $0
80101e2e:	6a 00                	push   $0x0
  pushl $216
80101e30:	68 d8 00 00 00       	push   $0xd8
  jmp alltraps
80101e35:	e9 eb 03 00 00       	jmp    80102225 <alltraps>

80101e3a <vector217>:
.globl vector217
vector217:
  pushl $0
80101e3a:	6a 00                	push   $0x0
  pushl $217
80101e3c:	68 d9 00 00 00       	push   $0xd9
  jmp alltraps
80101e41:	e9 df 03 00 00       	jmp    80102225 <alltraps>

80101e46 <vector218>:
.globl vector218
vector218:
  pushl $0
80101e46:	6a 00                	push   $0x0
  pushl $218
80101e48:	68 da 00 00 00       	push   $0xda
  jmp alltraps
80101e4d:	e9 d3 03 00 00       	jmp    80102225 <alltraps>

80101e52 <vector219>:
.globl vector219
vector219:
  pushl $0
80101e52:	6a 00                	push   $0x0
  pushl $219
80101e54:	68 db 00 00 00       	push   $0xdb
  jmp alltraps
80101e59:	e9 c7 03 00 00       	jmp    80102225 <alltraps>

80101e5e <vector220>:
.globl vector220
vector220:
  pushl $0
80101e5e:	6a 00                	push   $0x0
  pushl $220
80101e60:	68 dc 00 00 00       	push   $0xdc
  jmp alltraps
80101e65:	e9 bb 03 00 00       	jmp    80102225 <alltraps>

80101e6a <vector221>:
.globl vector221
vector221:
  pushl $0
80101e6a:	6a 00                	push   $0x0
  pushl $221
80101e6c:	68 dd 00 00 00       	push   $0xdd
  jmp alltraps
80101e71:	e9 af 03 00 00       	jmp    80102225 <alltraps>

80101e76 <vector222>:
.globl vector222
vector222:
  pushl $0
80101e76:	6a 00                	push   $0x0
  pushl $222
80101e78:	68 de 00 00 00       	push   $0xde
  jmp alltraps
80101e7d:	e9 a3 03 00 00       	jmp    80102225 <alltraps>

80101e82 <vector223>:
.globl vector223
vector223:
  pushl $0
80101e82:	6a 00                	push   $0x0
  pushl $223
80101e84:	68 df 00 00 00       	push   $0xdf
  jmp alltraps
80101e89:	e9 97 03 00 00       	jmp    80102225 <alltraps>

80101e8e <vector224>:
.globl vector224
vector224:
  pushl $0
80101e8e:	6a 00                	push   $0x0
  pushl $224
80101e90:	68 e0 00 00 00       	push   $0xe0
  jmp alltraps
80101e95:	e9 8b 03 00 00       	jmp    80102225 <alltraps>

80101e9a <vector225>:
.globl vector225
vector225:
  pushl $0
80101e9a:	6a 00                	push   $0x0
  pushl $225
80101e9c:	68 e1 00 00 00       	push   $0xe1
  jmp alltraps
80101ea1:	e9 7f 03 00 00       	jmp    80102225 <alltraps>

80101ea6 <vector226>:
.globl vector226
vector226:
  pushl $0
80101ea6:	6a 00                	push   $0x0
  pushl $226
80101ea8:	68 e2 00 00 00       	push   $0xe2
  jmp alltraps
80101ead:	e9 73 03 00 00       	jmp    80102225 <alltraps>

80101eb2 <vector227>:
.globl vector227
vector227:
  pushl $0
80101eb2:	6a 00                	push   $0x0
  pushl $227
80101eb4:	68 e3 00 00 00       	push   $0xe3
  jmp alltraps
80101eb9:	e9 67 03 00 00       	jmp    80102225 <alltraps>

80101ebe <vector228>:
.globl vector228
vector228:
  pushl $0
80101ebe:	6a 00                	push   $0x0
  pushl $228
80101ec0:	68 e4 00 00 00       	push   $0xe4
  jmp alltraps
80101ec5:	e9 5b 03 00 00       	jmp    80102225 <alltraps>

80101eca <vector229>:
.globl vector229
vector229:
  pushl $0
80101eca:	6a 00                	push   $0x0
  pushl $229
80101ecc:	68 e5 00 00 00       	push   $0xe5
  jmp alltraps
80101ed1:	e9 4f 03 00 00       	jmp    80102225 <alltraps>

80101ed6 <vector230>:
.globl vector230
vector230:
  pushl $0
80101ed6:	6a 00                	push   $0x0
  pushl $230
80101ed8:	68 e6 00 00 00       	push   $0xe6
  jmp alltraps
80101edd:	e9 43 03 00 00       	jmp    80102225 <alltraps>

80101ee2 <vector231>:
.globl vector231
vector231:
  pushl $0
80101ee2:	6a 00                	push   $0x0
  pushl $231
80101ee4:	68 e7 00 00 00       	push   $0xe7
  jmp alltraps
80101ee9:	e9 37 03 00 00       	jmp    80102225 <alltraps>

80101eee <vector232>:
.globl vector232
vector232:
  pushl $0
80101eee:	6a 00                	push   $0x0
  pushl $232
80101ef0:	68 e8 00 00 00       	push   $0xe8
  jmp alltraps
80101ef5:	e9 2b 03 00 00       	jmp    80102225 <alltraps>

80101efa <vector233>:
.globl vector233
vector233:
  pushl $0
80101efa:	6a 00                	push   $0x0
  pushl $233
80101efc:	68 e9 00 00 00       	push   $0xe9
  jmp alltraps
80101f01:	e9 1f 03 00 00       	jmp    80102225 <alltraps>

80101f06 <vector234>:
.globl vector234
vector234:
  pushl $0
80101f06:	6a 00                	push   $0x0
  pushl $234
80101f08:	68 ea 00 00 00       	push   $0xea
  jmp alltraps
80101f0d:	e9 13 03 00 00       	jmp    80102225 <alltraps>

80101f12 <vector235>:
.globl vector235
vector235:
  pushl $0
80101f12:	6a 00                	push   $0x0
  pushl $235
80101f14:	68 eb 00 00 00       	push   $0xeb
  jmp alltraps
80101f19:	e9 07 03 00 00       	jmp    80102225 <alltraps>

80101f1e <vector236>:
.globl vector236
vector236:
  pushl $0
80101f1e:	6a 00                	push   $0x0
  pushl $236
80101f20:	68 ec 00 00 00       	push   $0xec
  jmp alltraps
80101f25:	e9 fb 02 00 00       	jmp    80102225 <alltraps>

80101f2a <vector237>:
.globl vector237
vector237:
  pushl $0
80101f2a:	6a 00                	push   $0x0
  pushl $237
80101f2c:	68 ed 00 00 00       	push   $0xed
  jmp alltraps
80101f31:	e9 ef 02 00 00       	jmp    80102225 <alltraps>

80101f36 <vector238>:
.globl vector238
vector238:
  pushl $0
80101f36:	6a 00                	push   $0x0
  pushl $238
80101f38:	68 ee 00 00 00       	push   $0xee
  jmp alltraps
80101f3d:	e9 e3 02 00 00       	jmp    80102225 <alltraps>

80101f42 <vector239>:
.globl vector239
vector239:
  pushl $0
80101f42:	6a 00                	push   $0x0
  pushl $239
80101f44:	68 ef 00 00 00       	push   $0xef
  jmp alltraps
80101f49:	e9 d7 02 00 00       	jmp    80102225 <alltraps>

80101f4e <vector240>:
.globl vector240
vector240:
  pushl $0
80101f4e:	6a 00                	push   $0x0
  pushl $240
80101f50:	68 f0 00 00 00       	push   $0xf0
  jmp alltraps
80101f55:	e9 cb 02 00 00       	jmp    80102225 <alltraps>

80101f5a <vector241>:
.globl vector241
vector241:
  pushl $0
80101f5a:	6a 00                	push   $0x0
  pushl $241
80101f5c:	68 f1 00 00 00       	push   $0xf1
  jmp alltraps
80101f61:	e9 bf 02 00 00       	jmp    80102225 <alltraps>

80101f66 <vector242>:
.globl vector242
vector242:
  pushl $0
80101f66:	6a 00                	push   $0x0
  pushl $242
80101f68:	68 f2 00 00 00       	push   $0xf2
  jmp alltraps
80101f6d:	e9 b3 02 00 00       	jmp    80102225 <alltraps>

80101f72 <vector243>:
.globl vector243
vector243:
  pushl $0
80101f72:	6a 00                	push   $0x0
  pushl $243
80101f74:	68 f3 00 00 00       	push   $0xf3
  jmp alltraps
80101f79:	e9 a7 02 00 00       	jmp    80102225 <alltraps>

80101f7e <vector244>:
.globl vector244
vector244:
  pushl $0
80101f7e:	6a 00                	push   $0x0
  pushl $244
80101f80:	68 f4 00 00 00       	push   $0xf4
  jmp alltraps
80101f85:	e9 9b 02 00 00       	jmp    80102225 <alltraps>

80101f8a <vector245>:
.globl vector245
vector245:
  pushl $0
80101f8a:	6a 00                	push   $0x0
  pushl $245
80101f8c:	68 f5 00 00 00       	push   $0xf5
  jmp alltraps
80101f91:	e9 8f 02 00 00       	jmp    80102225 <alltraps>

80101f96 <vector246>:
.globl vector246
vector246:
  pushl $0
80101f96:	6a 00                	push   $0x0
  pushl $246
80101f98:	68 f6 00 00 00       	push   $0xf6
  jmp alltraps
80101f9d:	e9 83 02 00 00       	jmp    80102225 <alltraps>

80101fa2 <vector247>:
.globl vector247
vector247:
  pushl $0
80101fa2:	6a 00                	push   $0x0
  pushl $247
80101fa4:	68 f7 00 00 00       	push   $0xf7
  jmp alltraps
80101fa9:	e9 77 02 00 00       	jmp    80102225 <alltraps>

80101fae <vector248>:
.globl vector248
vector248:
  pushl $0
80101fae:	6a 00                	push   $0x0
  pushl $248
80101fb0:	68 f8 00 00 00       	push   $0xf8
  jmp alltraps
80101fb5:	e9 6b 02 00 00       	jmp    80102225 <alltraps>

80101fba <vector249>:
.globl vector249
vector249:
  pushl $0
80101fba:	6a 00                	push   $0x0
  pushl $249
80101fbc:	68 f9 00 00 00       	push   $0xf9
  jmp alltraps
80101fc1:	e9 5f 02 00 00       	jmp    80102225 <alltraps>

80101fc6 <vector250>:
.globl vector250
vector250:
  pushl $0
80101fc6:	6a 00                	push   $0x0
  pushl $250
80101fc8:	68 fa 00 00 00       	push   $0xfa
  jmp alltraps
80101fcd:	e9 53 02 00 00       	jmp    80102225 <alltraps>

80101fd2 <vector251>:
.globl vector251
vector251:
  pushl $0
80101fd2:	6a 00                	push   $0x0
  pushl $251
80101fd4:	68 fb 00 00 00       	push   $0xfb
  jmp alltraps
80101fd9:	e9 47 02 00 00       	jmp    80102225 <alltraps>

80101fde <vector252>:
.globl vector252
vector252:
  pushl $0
80101fde:	6a 00                	push   $0x0
  pushl $252
80101fe0:	68 fc 00 00 00       	push   $0xfc
  jmp alltraps
80101fe5:	e9 3b 02 00 00       	jmp    80102225 <alltraps>

80101fea <vector253>:
.globl vector253
vector253:
  pushl $0
80101fea:	6a 00                	push   $0x0
  pushl $253
80101fec:	68 fd 00 00 00       	push   $0xfd
  jmp alltraps
80101ff1:	e9 2f 02 00 00       	jmp    80102225 <alltraps>

80101ff6 <vector254>:
.globl vector254
vector254:
  pushl $0
80101ff6:	6a 00                	push   $0x0
  pushl $254
80101ff8:	68 fe 00 00 00       	push   $0xfe
  jmp alltraps
80101ffd:	e9 23 02 00 00       	jmp    80102225 <alltraps>

80102002 <vector255>:
.globl vector255
vector255:
  pushl $0
80102002:	6a 00                	push   $0x0
  pushl $255
80102004:	68 ff 00 00 00       	push   $0xff
  jmp alltraps
80102009:	e9 17 02 00 00       	jmp    80102225 <alltraps>

8010200e <lidt>:

struct gatedesc;

static inline void
lidt(struct gatedesc *p, int size)
{
8010200e:	55                   	push   %ebp
8010200f:	89 e5                	mov    %esp,%ebp
80102011:	83 ec 10             	sub    $0x10,%esp
  volatile ushort pd[3];

  pd[0] = size-1;
80102014:	8b 45 0c             	mov    0xc(%ebp),%eax
80102017:	83 e8 01             	sub    $0x1,%eax
8010201a:	66 89 45 fa          	mov    %ax,-0x6(%ebp)
  pd[1] = (uint)p;
8010201e:	8b 45 08             	mov    0x8(%ebp),%eax
80102021:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  pd[2] = (uint)p >> 16;
80102025:	8b 45 08             	mov    0x8(%ebp),%eax
80102028:	c1 e8 10             	shr    $0x10,%eax
8010202b:	66 89 45 fe          	mov    %ax,-0x2(%ebp)

  asm volatile("lidt (%0)" : : "r" (pd));
8010202f:	8d 45 fa             	lea    -0x6(%ebp),%eax
80102032:	0f 01 18             	lidtl  (%eax)
}
80102035:	c9                   	leave  
80102036:	c3                   	ret    

80102037 <tvinit>:


// 中断描述符表初始化，将IDT中的每一个中断描述符都与vector.S中256个中断的地址相对应
void
tvinit(void)
{
80102037:	55                   	push   %ebp
80102038:	89 e5                	mov    %esp,%ebp
8010203a:	83 ec 10             	sub    $0x10,%esp
  int i;
  for(i = 0; i < 256; i++)
8010203d:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
80102044:	e9 c3 00 00 00       	jmp    8010210c <tvinit+0xd5>
    SETGATE(idt[i], 0, SEG_KCODE<<3, vectors[i], 0);
80102049:	8b 45 fc             	mov    -0x4(%ebp),%eax
8010204c:	8b 04 85 c8 45 10 80 	mov    -0x7fefba38(,%eax,4),%eax
80102053:	89 c2                	mov    %eax,%edx
80102055:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102058:	66 89 14 c5 00 6e 10 	mov    %dx,-0x7fef9200(,%eax,8)
8010205f:	80 
80102060:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102063:	66 c7 04 c5 02 6e 10 	movw   $0x8,-0x7fef91fe(,%eax,8)
8010206a:	80 08 00 
8010206d:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102070:	0f b6 14 c5 04 6e 10 	movzbl -0x7fef91fc(,%eax,8),%edx
80102077:	80 
80102078:	83 e2 e0             	and    $0xffffffe0,%edx
8010207b:	88 14 c5 04 6e 10 80 	mov    %dl,-0x7fef91fc(,%eax,8)
80102082:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102085:	0f b6 14 c5 04 6e 10 	movzbl -0x7fef91fc(,%eax,8),%edx
8010208c:	80 
8010208d:	83 e2 1f             	and    $0x1f,%edx
80102090:	88 14 c5 04 6e 10 80 	mov    %dl,-0x7fef91fc(,%eax,8)
80102097:	8b 45 fc             	mov    -0x4(%ebp),%eax
8010209a:	0f b6 14 c5 05 6e 10 	movzbl -0x7fef91fb(,%eax,8),%edx
801020a1:	80 
801020a2:	83 e2 f0             	and    $0xfffffff0,%edx
801020a5:	83 ca 0e             	or     $0xe,%edx
801020a8:	88 14 c5 05 6e 10 80 	mov    %dl,-0x7fef91fb(,%eax,8)
801020af:	8b 45 fc             	mov    -0x4(%ebp),%eax
801020b2:	0f b6 14 c5 05 6e 10 	movzbl -0x7fef91fb(,%eax,8),%edx
801020b9:	80 
801020ba:	83 e2 ef             	and    $0xffffffef,%edx
801020bd:	88 14 c5 05 6e 10 80 	mov    %dl,-0x7fef91fb(,%eax,8)
801020c4:	8b 45 fc             	mov    -0x4(%ebp),%eax
801020c7:	0f b6 14 c5 05 6e 10 	movzbl -0x7fef91fb(,%eax,8),%edx
801020ce:	80 
801020cf:	83 e2 9f             	and    $0xffffff9f,%edx
801020d2:	88 14 c5 05 6e 10 80 	mov    %dl,-0x7fef91fb(,%eax,8)
801020d9:	8b 45 fc             	mov    -0x4(%ebp),%eax
801020dc:	0f b6 14 c5 05 6e 10 	movzbl -0x7fef91fb(,%eax,8),%edx
801020e3:	80 
801020e4:	83 ca 80             	or     $0xffffff80,%edx
801020e7:	88 14 c5 05 6e 10 80 	mov    %dl,-0x7fef91fb(,%eax,8)
801020ee:	8b 45 fc             	mov    -0x4(%ebp),%eax
801020f1:	8b 04 85 c8 45 10 80 	mov    -0x7fefba38(,%eax,4),%eax
801020f8:	c1 e8 10             	shr    $0x10,%eax
801020fb:	89 c2                	mov    %eax,%edx
801020fd:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102100:	66 89 14 c5 06 6e 10 	mov    %dx,-0x7fef91fa(,%eax,8)
80102107:	80 
// 中断描述符表初始化，将IDT中的每一个中断描述符都与vector.S中256个中断的地址相对应
void
tvinit(void)
{
  int i;
  for(i = 0; i < 256; i++)
80102108:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
8010210c:	81 7d fc ff 00 00 00 	cmpl   $0xff,-0x4(%ebp)
80102113:	0f 8e 30 ff ff ff    	jle    80102049 <tvinit+0x12>
    SETGATE(idt[i], 0, SEG_KCODE<<3, vectors[i], 0);
  SETGATE(idt[T_SYSCALL], 1, SEG_KCODE<<3, vectors[T_SYSCALL], DPL_USER);
80102119:	a1 c8 46 10 80       	mov    0x801046c8,%eax
8010211e:	66 a3 00 70 10 80    	mov    %ax,0x80107000
80102124:	66 c7 05 02 70 10 80 	movw   $0x8,0x80107002
8010212b:	08 00 
8010212d:	0f b6 05 04 70 10 80 	movzbl 0x80107004,%eax
80102134:	83 e0 e0             	and    $0xffffffe0,%eax
80102137:	a2 04 70 10 80       	mov    %al,0x80107004
8010213c:	0f b6 05 04 70 10 80 	movzbl 0x80107004,%eax
80102143:	83 e0 1f             	and    $0x1f,%eax
80102146:	a2 04 70 10 80       	mov    %al,0x80107004
8010214b:	0f b6 05 05 70 10 80 	movzbl 0x80107005,%eax
80102152:	83 c8 0f             	or     $0xf,%eax
80102155:	a2 05 70 10 80       	mov    %al,0x80107005
8010215a:	0f b6 05 05 70 10 80 	movzbl 0x80107005,%eax
80102161:	83 e0 ef             	and    $0xffffffef,%eax
80102164:	a2 05 70 10 80       	mov    %al,0x80107005
80102169:	0f b6 05 05 70 10 80 	movzbl 0x80107005,%eax
80102170:	83 c8 60             	or     $0x60,%eax
80102173:	a2 05 70 10 80       	mov    %al,0x80107005
80102178:	0f b6 05 05 70 10 80 	movzbl 0x80107005,%eax
8010217f:	83 c8 80             	or     $0xffffff80,%eax
80102182:	a2 05 70 10 80       	mov    %al,0x80107005
80102187:	a1 c8 46 10 80       	mov    0x801046c8,%eax
8010218c:	c1 e8 10             	shr    $0x10,%eax
8010218f:	66 a3 06 70 10 80    	mov    %ax,0x80107006
}
80102195:	c9                   	leave  
80102196:	c3                   	ret    

80102197 <printidt>:

// 打印一些当前IDT内中的一些信息
void 
printidt(void)
{
80102197:	55                   	push   %ebp
80102198:	89 e5                	mov    %esp,%ebp
8010219a:	83 ec 18             	sub    $0x18,%esp
  int i = 0;
8010219d:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  for(;i<=10;i++){
801021a4:	eb 48                	jmp    801021ee <printidt+0x57>
	cprintf("IDT %d: offset 31~16:%d\n", i, idt[i].off_31_16);
801021a6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801021a9:	0f b7 04 c5 06 6e 10 	movzwl -0x7fef91fa(,%eax,8),%eax
801021b0:	80 
801021b1:	0f b7 c0             	movzwl %ax,%eax
801021b4:	83 ec 04             	sub    $0x4,%esp
801021b7:	50                   	push   %eax
801021b8:	ff 75 f4             	pushl  -0xc(%ebp)
801021bb:	68 6d 25 10 80       	push   $0x8010256d
801021c0:	e8 ea df ff ff       	call   801001af <cprintf>
801021c5:	83 c4 10             	add    $0x10,%esp
	cprintf("IDT %d: offset 15~0:%d\n", i, idt[i].off_15_0);
801021c8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801021cb:	0f b7 04 c5 00 6e 10 	movzwl -0x7fef9200(,%eax,8),%eax
801021d2:	80 
801021d3:	0f b7 c0             	movzwl %ax,%eax
801021d6:	83 ec 04             	sub    $0x4,%esp
801021d9:	50                   	push   %eax
801021da:	ff 75 f4             	pushl  -0xc(%ebp)
801021dd:	68 86 25 10 80       	push   $0x80102586
801021e2:	e8 c8 df ff ff       	call   801001af <cprintf>
801021e7:	83 c4 10             	add    $0x10,%esp
// 打印一些当前IDT内中的一些信息
void 
printidt(void)
{
  int i = 0;
  for(;i<=10;i++){
801021ea:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801021ee:	83 7d f4 0a          	cmpl   $0xa,-0xc(%ebp)
801021f2:	7e b2                	jle    801021a6 <printidt+0xf>
	cprintf("IDT %d: offset 31~16:%d\n", i, idt[i].off_31_16);
	cprintf("IDT %d: offset 15~0:%d\n", i, idt[i].off_15_0);
  }
}
801021f4:	c9                   	leave  
801021f5:	c3                   	ret    

801021f6 <idtinit>:

// 加载idt，调用内联汇编
void
idtinit(void)
{
801021f6:	55                   	push   %ebp
801021f7:	89 e5                	mov    %esp,%ebp
  lidt(idt, sizeof(idt));
801021f9:	68 00 08 00 00       	push   $0x800
801021fe:	68 00 6e 10 80       	push   $0x80106e00
80102203:	e8 06 fe ff ff       	call   8010200e <lidt>
80102208:	83 c4 08             	add    $0x8,%esp
}
8010220b:	c9                   	leave  
8010220c:	c3                   	ret    

8010220d <trap>:

// 中断处理程序,目前什么都不做
void
trap(struct trapframe *tf)
{
8010220d:	55                   	push   %ebp
8010220e:	89 e5                	mov    %esp,%ebp
80102210:	83 ec 08             	sub    $0x8,%esp
  uint st, data, c;
   if(tf->trapno == (T_IRQ0 + IRQ_KBD)){
80102213:	8b 45 08             	mov    0x8(%ebp),%eax
80102216:	8b 40 30             	mov    0x30(%eax),%eax
80102219:	83 f8 21             	cmp    $0x21,%eax
8010221c:	75 05                	jne    80102223 <trap+0x16>
       kbdintr();
8010221e:	e8 6d e7 ff ff       	call   80100990 <kbdintr>
  }	
}
80102223:	c9                   	leave  
80102224:	c3                   	ret    

80102225 <alltraps>:
  # vectors.S 会把所有的中断都掉转到这里
.globl alltraps

alltraps:
  # 建立一个中断帧，保护现场
  pushl %ds
80102225:	1e                   	push   %ds
  pushl %es
80102226:	06                   	push   %es
  pushl %fs
80102227:	0f a0                	push   %fs
  pushl %gs
80102229:	0f a8                	push   %gs
  pushal
8010222b:	60                   	pusha  
  
  # 设置数据段
  movw $(SEG_KDATA<<3), %ax
8010222c:	66 b8 10 00          	mov    $0x10,%ax
  movw %ax, %ds
80102230:	8e d8                	mov    %eax,%ds
  movw %ax, %es
80102232:	8e c0                	mov    %eax,%es

  # 调用trap函数，执行中断服务程序，目前针对所有中断都不做任何处理
  # 定义在了trap.c中，同时压栈esp，这里的esp就代表了trap的参数tf，也就是当前的中断帧
  pushl %esp
80102234:	54                   	push   %esp
  call trap
80102235:	e8 d3 ff ff ff       	call   8010220d <trap>
  addl $4, %esp
8010223a:	83 c4 04             	add    $0x4,%esp

8010223d <trapret>:

  # 执行完中断服务程序以后开始恢复现场
.globl trapret
trapret:
  popal
8010223d:	61                   	popa   
  popl %gs
8010223e:	0f a9                	pop    %gs
  popl %fs
80102240:	0f a1                	pop    %fs
  popl %es
80102242:	07                   	pop    %es
  popl %ds
80102243:	1f                   	pop    %ds
  addl $0x8, %esp  # 中断号以及错误号
80102244:	83 c4 08             	add    $0x8,%esp
  iret
80102247:	cf                   	iret   

80102248 <inb>:
// Routines to let C code use special x86 instructions.

static inline uchar
inb(ushort port)
{
80102248:	55                   	push   %ebp
80102249:	89 e5                	mov    %esp,%ebp
8010224b:	83 ec 14             	sub    $0x14,%esp
8010224e:	8b 45 08             	mov    0x8(%ebp),%eax
80102251:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
  uchar data;

  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80102255:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
80102259:	89 c2                	mov    %eax,%edx
8010225b:	ec                   	in     (%dx),%al
8010225c:	88 45 ff             	mov    %al,-0x1(%ebp)
  return data;
8010225f:	0f b6 45 ff          	movzbl -0x1(%ebp),%eax
}
80102263:	c9                   	leave  
80102264:	c3                   	ret    

80102265 <outb>:
               "memory", "cc");
}

static inline void
outb(ushort port, uchar data)
{
80102265:	55                   	push   %ebp
80102266:	89 e5                	mov    %esp,%ebp
80102268:	83 ec 08             	sub    $0x8,%esp
8010226b:	8b 55 08             	mov    0x8(%ebp),%edx
8010226e:	8b 45 0c             	mov    0xc(%ebp),%eax
80102271:	66 89 55 fc          	mov    %dx,-0x4(%ebp)
80102275:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80102278:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
8010227c:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
80102280:	ee                   	out    %al,(%dx)
}
80102281:	c9                   	leave  
80102282:	c3                   	ret    

80102283 <uartputc>:

#define COM1    0x3f8

void
uartputc(int c)
{
80102283:	55                   	push   %ebp
80102284:	89 e5                	mov    %esp,%ebp
80102286:	83 ec 10             	sub    $0x10,%esp
  int i;
  for(i = 0; i < 128 && !(inb(COM1+5) & 0x20); i++)
80102289:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
80102290:	eb 18                	jmp    801022aa <uartputc+0x27>
  outb(COM1+0, c);
80102292:	8b 45 08             	mov    0x8(%ebp),%eax
80102295:	0f b6 c0             	movzbl %al,%eax
80102298:	50                   	push   %eax
80102299:	68 f8 03 00 00       	push   $0x3f8
8010229e:	e8 c2 ff ff ff       	call   80102265 <outb>
801022a3:	83 c4 08             	add    $0x8,%esp

void
uartputc(int c)
{
  int i;
  for(i = 0; i < 128 && !(inb(COM1+5) & 0x20); i++)
801022a6:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
801022aa:	83 7d fc 7f          	cmpl   $0x7f,-0x4(%ebp)
801022ae:	7f 17                	jg     801022c7 <uartputc+0x44>
801022b0:	68 fd 03 00 00       	push   $0x3fd
801022b5:	e8 8e ff ff ff       	call   80102248 <inb>
801022ba:	83 c4 04             	add    $0x4,%esp
801022bd:	0f b6 c0             	movzbl %al,%eax
801022c0:	83 e0 20             	and    $0x20,%eax
801022c3:	85 c0                	test   %eax,%eax
801022c5:	74 cb                	je     80102292 <uartputc+0xf>
  outb(COM1+0, c);
}
801022c7:	c9                   	leave  
801022c8:	c3                   	ret    
