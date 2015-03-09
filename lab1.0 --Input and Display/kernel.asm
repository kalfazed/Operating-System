
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
  cprintf("Test for printing\n");
8010004b:	83 ec 0c             	sub    $0xc,%esp
8010004e:	68 f0 1e 10 80       	push   $0x80101ef0
80100053:	e8 31 01 00 00       	call   80100189 <cprintf>
80100058:	83 c4 10             	add    $0x10,%esp
  
  kinit(end, P2V(4*1024*1024));  // 物理页的分配
8010005b:	83 ec 08             	sub    $0x8,%esp
8010005e:	68 00 00 40 80       	push   $0x80400000
80100063:	68 80 68 10 80       	push   $0x80106880
80100068:	e8 47 06 00 00       	call   801006b4 <kinit>
8010006d:	83 c4 10             	add    $0x10,%esp
  kvmalloc(); 			 // 内核页表
80100070:	e8 d8 0e 00 00       	call   80100f4d <kvmalloc>
  seginit();   			 // 初始化段，这里对段的初始化是对当前cpu的gdt的初始化
80100075:	e8 5d 08 00 00       	call   801008d7 <seginit>
//  segshow();   		 // 打印一些段的信息，用来验证

  picinit(); 			 // 初始化中断控制器8259A 
8010007a:	e8 73 0f 00 00       	call   80100ff2 <picinit>
  ioapicinit(); 		 // 初始化IOAAPIC中断控制器
8010007f:	e8 87 10 00 00       	call   8010110b <ioapicinit>
  consoleinit(); 		 // 初始化控制台
80100084:	e8 be 03 00 00       	call   80100447 <consoleinit>

  tvinit(); 			 // 初始化idt，扩充idt中中断描述符的内容
80100089:	e8 d0 1b 00 00       	call   80101c5e <tvinit>
  idtinit(); 			 // 加载idt
8010008e:	e8 8a 1d 00 00       	call   80101e1d <idtinit>
  sti(); 			 // 开启中断
80100093:	e8 9c ff ff ff       	call   80100034 <sti>
//  printidt(); 	         // 打印一些idt的信息，用来验证

  

 // while(1);
}
80100098:	8b 4d fc             	mov    -0x4(%ebp),%ecx
8010009b:	c9                   	leave  
8010009c:	8d 61 fc             	lea    -0x4(%ecx),%esp
8010009f:	c3                   	ret    

801000a0 <inb>:
// Routines to let C code use special x86 instructions.

static inline uchar
inb(ushort port)
{
801000a0:	55                   	push   %ebp
801000a1:	89 e5                	mov    %esp,%ebp
801000a3:	83 ec 14             	sub    $0x14,%esp
801000a6:	8b 45 08             	mov    0x8(%ebp),%eax
801000a9:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
  uchar data;

  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
801000ad:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
801000b1:	89 c2                	mov    %eax,%edx
801000b3:	ec                   	in     (%dx),%al
801000b4:	88 45 ff             	mov    %al,-0x1(%ebp)
  return data;
801000b7:	0f b6 45 ff          	movzbl -0x1(%ebp),%eax
}
801000bb:	c9                   	leave  
801000bc:	c3                   	ret    

801000bd <outb>:
               "memory", "cc");
}

static inline void
outb(ushort port, uchar data)
{
801000bd:	55                   	push   %ebp
801000be:	89 e5                	mov    %esp,%ebp
801000c0:	83 ec 08             	sub    $0x8,%esp
801000c3:	8b 55 08             	mov    0x8(%ebp),%edx
801000c6:	8b 45 0c             	mov    0xc(%ebp),%eax
801000c9:	66 89 55 fc          	mov    %dx,-0x4(%ebp)
801000cd:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
801000d0:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
801000d4:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
801000d8:	ee                   	out    %al,(%dx)
}
801000d9:	c9                   	leave  
801000da:	c3                   	ret    

801000db <printint>:
static void consputc(int);


static void
printint(int xx, int base, int sign)
{
801000db:	55                   	push   %ebp
801000dc:	89 e5                	mov    %esp,%ebp
801000de:	53                   	push   %ebx
801000df:	83 ec 24             	sub    $0x24,%esp
  static char digits[] = "0123456789abcdef";
  char buf[16];
  int i;
  uint x;

  if(sign && (sign = xx < 0))
801000e2:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
801000e6:	74 1c                	je     80100104 <printint+0x29>
801000e8:	8b 45 08             	mov    0x8(%ebp),%eax
801000eb:	c1 e8 1f             	shr    $0x1f,%eax
801000ee:	0f b6 c0             	movzbl %al,%eax
801000f1:	89 45 10             	mov    %eax,0x10(%ebp)
801000f4:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
801000f8:	74 0a                	je     80100104 <printint+0x29>
    x = -xx;
801000fa:	8b 45 08             	mov    0x8(%ebp),%eax
801000fd:	f7 d8                	neg    %eax
801000ff:	89 45 f0             	mov    %eax,-0x10(%ebp)
80100102:	eb 06                	jmp    8010010a <printint+0x2f>
  else
    x = xx;
80100104:	8b 45 08             	mov    0x8(%ebp),%eax
80100107:	89 45 f0             	mov    %eax,-0x10(%ebp)

  i = 0;
8010010a:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  do{
    buf[i++] = digits[x % base];
80100111:	8b 4d f4             	mov    -0xc(%ebp),%ecx
80100114:	8d 41 01             	lea    0x1(%ecx),%eax
80100117:	89 45 f4             	mov    %eax,-0xc(%ebp)
8010011a:	8b 5d 0c             	mov    0xc(%ebp),%ebx
8010011d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80100120:	ba 00 00 00 00       	mov    $0x0,%edx
80100125:	f7 f3                	div    %ebx
80100127:	89 d0                	mov    %edx,%eax
80100129:	0f b6 80 04 40 10 80 	movzbl -0x7fefbffc(%eax),%eax
80100130:	88 44 0d e0          	mov    %al,-0x20(%ebp,%ecx,1)
  }while((x /= base) != 0);
80100134:	8b 5d 0c             	mov    0xc(%ebp),%ebx
80100137:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010013a:	ba 00 00 00 00       	mov    $0x0,%edx
8010013f:	f7 f3                	div    %ebx
80100141:	89 45 f0             	mov    %eax,-0x10(%ebp)
80100144:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80100148:	75 c7                	jne    80100111 <printint+0x36>

  if(sign)
8010014a:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
8010014e:	74 0e                	je     8010015e <printint+0x83>
    buf[i++] = '-';
80100150:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100153:	8d 50 01             	lea    0x1(%eax),%edx
80100156:	89 55 f4             	mov    %edx,-0xc(%ebp)
80100159:	c6 44 05 e0 2d       	movb   $0x2d,-0x20(%ebp,%eax,1)

  while(--i >= 0)
8010015e:	eb 1a                	jmp    8010017a <printint+0x9f>
    consputc(buf[i]);
80100160:	8d 55 e0             	lea    -0x20(%ebp),%edx
80100163:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100166:	01 d0                	add    %edx,%eax
80100168:	0f b6 00             	movzbl (%eax),%eax
8010016b:	0f be c0             	movsbl %al,%eax
8010016e:	83 ec 0c             	sub    $0xc,%esp
80100171:	50                   	push   %eax
80100172:	e8 7a 02 00 00       	call   801003f1 <consputc>
80100177:	83 c4 10             	add    $0x10,%esp
  }while((x /= base) != 0);

  if(sign)
    buf[i++] = '-';

  while(--i >= 0)
8010017a:	83 6d f4 01          	subl   $0x1,-0xc(%ebp)
8010017e:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80100182:	79 dc                	jns    80100160 <printint+0x85>
    consputc(buf[i]);
}
80100184:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80100187:	c9                   	leave  
80100188:	c3                   	ret    

80100189 <cprintf>:

void
cprintf(char *fmt, ...)
{
80100189:	55                   	push   %ebp
8010018a:	89 e5                	mov    %esp,%ebp
8010018c:	83 ec 18             	sub    $0x18,%esp
  int i, c;
  uint *argp;
  char *s;

  argp = (uint*)(void*)(&fmt + 1);
8010018f:	8d 45 0c             	lea    0xc(%ebp),%eax
80100192:	89 45 f0             	mov    %eax,-0x10(%ebp)
  for(i = 0; (c = fmt[i] & 0xff) != 0; i++){
80100195:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
8010019c:	e9 1b 01 00 00       	jmp    801002bc <cprintf+0x133>
    if(c != '%'){
801001a1:	83 7d e8 25          	cmpl   $0x25,-0x18(%ebp)
801001a5:	74 13                	je     801001ba <cprintf+0x31>
      consputc(c);
801001a7:	83 ec 0c             	sub    $0xc,%esp
801001aa:	ff 75 e8             	pushl  -0x18(%ebp)
801001ad:	e8 3f 02 00 00       	call   801003f1 <consputc>
801001b2:	83 c4 10             	add    $0x10,%esp
      continue;
801001b5:	e9 fe 00 00 00       	jmp    801002b8 <cprintf+0x12f>
    }
    c = fmt[++i] & 0xff;
801001ba:	8b 55 08             	mov    0x8(%ebp),%edx
801001bd:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801001c1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801001c4:	01 d0                	add    %edx,%eax
801001c6:	0f b6 00             	movzbl (%eax),%eax
801001c9:	0f be c0             	movsbl %al,%eax
801001cc:	25 ff 00 00 00       	and    $0xff,%eax
801001d1:	89 45 e8             	mov    %eax,-0x18(%ebp)
    if(c == 0)
801001d4:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
801001d8:	75 05                	jne    801001df <cprintf+0x56>
      break;
801001da:	e9 fd 00 00 00       	jmp    801002dc <cprintf+0x153>
    switch(c){
801001df:	8b 45 e8             	mov    -0x18(%ebp),%eax
801001e2:	83 f8 70             	cmp    $0x70,%eax
801001e5:	74 47                	je     8010022e <cprintf+0xa5>
801001e7:	83 f8 70             	cmp    $0x70,%eax
801001ea:	7f 13                	jg     801001ff <cprintf+0x76>
801001ec:	83 f8 25             	cmp    $0x25,%eax
801001ef:	0f 84 98 00 00 00    	je     8010028d <cprintf+0x104>
801001f5:	83 f8 64             	cmp    $0x64,%eax
801001f8:	74 14                	je     8010020e <cprintf+0x85>
801001fa:	e9 9d 00 00 00       	jmp    8010029c <cprintf+0x113>
801001ff:	83 f8 73             	cmp    $0x73,%eax
80100202:	74 47                	je     8010024b <cprintf+0xc2>
80100204:	83 f8 78             	cmp    $0x78,%eax
80100207:	74 25                	je     8010022e <cprintf+0xa5>
80100209:	e9 8e 00 00 00       	jmp    8010029c <cprintf+0x113>
    case 'd':
      printint(*argp++, 10, 1);
8010020e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80100211:	8d 50 04             	lea    0x4(%eax),%edx
80100214:	89 55 f0             	mov    %edx,-0x10(%ebp)
80100217:	8b 00                	mov    (%eax),%eax
80100219:	83 ec 04             	sub    $0x4,%esp
8010021c:	6a 01                	push   $0x1
8010021e:	6a 0a                	push   $0xa
80100220:	50                   	push   %eax
80100221:	e8 b5 fe ff ff       	call   801000db <printint>
80100226:	83 c4 10             	add    $0x10,%esp
      break;
80100229:	e9 8a 00 00 00       	jmp    801002b8 <cprintf+0x12f>
    case 'x':
    case 'p':
      printint(*argp++, 16, 0);
8010022e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80100231:	8d 50 04             	lea    0x4(%eax),%edx
80100234:	89 55 f0             	mov    %edx,-0x10(%ebp)
80100237:	8b 00                	mov    (%eax),%eax
80100239:	83 ec 04             	sub    $0x4,%esp
8010023c:	6a 00                	push   $0x0
8010023e:	6a 10                	push   $0x10
80100240:	50                   	push   %eax
80100241:	e8 95 fe ff ff       	call   801000db <printint>
80100246:	83 c4 10             	add    $0x10,%esp
      break;
80100249:	eb 6d                	jmp    801002b8 <cprintf+0x12f>
    case 's':
      if((s = (char*)*argp++) == 0)
8010024b:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010024e:	8d 50 04             	lea    0x4(%eax),%edx
80100251:	89 55 f0             	mov    %edx,-0x10(%ebp)
80100254:	8b 00                	mov    (%eax),%eax
80100256:	89 45 ec             	mov    %eax,-0x14(%ebp)
80100259:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
8010025d:	75 07                	jne    80100266 <cprintf+0xdd>
        s = "(null)";
8010025f:	c7 45 ec 03 1f 10 80 	movl   $0x80101f03,-0x14(%ebp)
      for(; *s; s++)
80100266:	eb 19                	jmp    80100281 <cprintf+0xf8>
        consputc(*s);
80100268:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010026b:	0f b6 00             	movzbl (%eax),%eax
8010026e:	0f be c0             	movsbl %al,%eax
80100271:	83 ec 0c             	sub    $0xc,%esp
80100274:	50                   	push   %eax
80100275:	e8 77 01 00 00       	call   801003f1 <consputc>
8010027a:	83 c4 10             	add    $0x10,%esp
      printint(*argp++, 16, 0);
      break;
    case 's':
      if((s = (char*)*argp++) == 0)
        s = "(null)";
      for(; *s; s++)
8010027d:	83 45 ec 01          	addl   $0x1,-0x14(%ebp)
80100281:	8b 45 ec             	mov    -0x14(%ebp),%eax
80100284:	0f b6 00             	movzbl (%eax),%eax
80100287:	84 c0                	test   %al,%al
80100289:	75 dd                	jne    80100268 <cprintf+0xdf>
        consputc(*s);
      break;
8010028b:	eb 2b                	jmp    801002b8 <cprintf+0x12f>
    case '%':
      consputc('%');
8010028d:	83 ec 0c             	sub    $0xc,%esp
80100290:	6a 25                	push   $0x25
80100292:	e8 5a 01 00 00       	call   801003f1 <consputc>
80100297:	83 c4 10             	add    $0x10,%esp
      break;
8010029a:	eb 1c                	jmp    801002b8 <cprintf+0x12f>
    default:
      consputc('%');
8010029c:	83 ec 0c             	sub    $0xc,%esp
8010029f:	6a 25                	push   $0x25
801002a1:	e8 4b 01 00 00       	call   801003f1 <consputc>
801002a6:	83 c4 10             	add    $0x10,%esp
      consputc(c);
801002a9:	83 ec 0c             	sub    $0xc,%esp
801002ac:	ff 75 e8             	pushl  -0x18(%ebp)
801002af:	e8 3d 01 00 00       	call   801003f1 <consputc>
801002b4:	83 c4 10             	add    $0x10,%esp
      break;
801002b7:	90                   	nop
  int i, c;
  uint *argp;
  char *s;

  argp = (uint*)(void*)(&fmt + 1);
  for(i = 0; (c = fmt[i] & 0xff) != 0; i++){
801002b8:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801002bc:	8b 55 08             	mov    0x8(%ebp),%edx
801002bf:	8b 45 f4             	mov    -0xc(%ebp),%eax
801002c2:	01 d0                	add    %edx,%eax
801002c4:	0f b6 00             	movzbl (%eax),%eax
801002c7:	0f be c0             	movsbl %al,%eax
801002ca:	25 ff 00 00 00       	and    $0xff,%eax
801002cf:	89 45 e8             	mov    %eax,-0x18(%ebp)
801002d2:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
801002d6:	0f 85 c5 fe ff ff    	jne    801001a1 <cprintf+0x18>
      consputc(c);
      break;
    }
  }

}
801002dc:	c9                   	leave  
801002dd:	c3                   	ret    

801002de <cgaputc>:
#define CRTPORT 0x3d4
static ushort *crt = (ushort*)P2V(0xb8000);  // CGA memory

static void
cgaputc(int c)
{
801002de:	55                   	push   %ebp
801002df:	89 e5                	mov    %esp,%ebp
801002e1:	83 ec 10             	sub    $0x10,%esp
  int pos;
  
  // Cursor position: col + 80*row.
  outb(CRTPORT, 14);
801002e4:	6a 0e                	push   $0xe
801002e6:	68 d4 03 00 00       	push   $0x3d4
801002eb:	e8 cd fd ff ff       	call   801000bd <outb>
801002f0:	83 c4 08             	add    $0x8,%esp
  pos = inb(CRTPORT+1) << 8;
801002f3:	68 d5 03 00 00       	push   $0x3d5
801002f8:	e8 a3 fd ff ff       	call   801000a0 <inb>
801002fd:	83 c4 04             	add    $0x4,%esp
80100300:	0f b6 c0             	movzbl %al,%eax
80100303:	c1 e0 08             	shl    $0x8,%eax
80100306:	89 45 fc             	mov    %eax,-0x4(%ebp)
  outb(CRTPORT, 15);
80100309:	6a 0f                	push   $0xf
8010030b:	68 d4 03 00 00       	push   $0x3d4
80100310:	e8 a8 fd ff ff       	call   801000bd <outb>
80100315:	83 c4 08             	add    $0x8,%esp
  pos |= inb(CRTPORT+1);
80100318:	68 d5 03 00 00       	push   $0x3d5
8010031d:	e8 7e fd ff ff       	call   801000a0 <inb>
80100322:	83 c4 04             	add    $0x4,%esp
80100325:	0f b6 c0             	movzbl %al,%eax
80100328:	09 45 fc             	or     %eax,-0x4(%ebp)

  if(c == '\n')
8010032b:	83 7d 08 0a          	cmpl   $0xa,0x8(%ebp)
8010032f:	75 30                	jne    80100361 <cgaputc+0x83>
    pos += 80 - pos%80;
80100331:	8b 4d fc             	mov    -0x4(%ebp),%ecx
80100334:	ba 67 66 66 66       	mov    $0x66666667,%edx
80100339:	89 c8                	mov    %ecx,%eax
8010033b:	f7 ea                	imul   %edx
8010033d:	c1 fa 05             	sar    $0x5,%edx
80100340:	89 c8                	mov    %ecx,%eax
80100342:	c1 f8 1f             	sar    $0x1f,%eax
80100345:	29 c2                	sub    %eax,%edx
80100347:	89 d0                	mov    %edx,%eax
80100349:	c1 e0 02             	shl    $0x2,%eax
8010034c:	01 d0                	add    %edx,%eax
8010034e:	c1 e0 04             	shl    $0x4,%eax
80100351:	29 c1                	sub    %eax,%ecx
80100353:	89 ca                	mov    %ecx,%edx
80100355:	b8 50 00 00 00       	mov    $0x50,%eax
8010035a:	29 d0                	sub    %edx,%eax
8010035c:	01 45 fc             	add    %eax,-0x4(%ebp)
8010035f:	eb 34                	jmp    80100395 <cgaputc+0xb7>
  else if(c == BACKSPACE){
80100361:	81 7d 08 00 01 00 00 	cmpl   $0x100,0x8(%ebp)
80100368:	75 0c                	jne    80100376 <cgaputc+0x98>
    if(pos > 0) --pos;
8010036a:	83 7d fc 00          	cmpl   $0x0,-0x4(%ebp)
8010036e:	7e 25                	jle    80100395 <cgaputc+0xb7>
80100370:	83 6d fc 01          	subl   $0x1,-0x4(%ebp)
80100374:	eb 1f                	jmp    80100395 <cgaputc+0xb7>
  } else
    crt[pos++] = (c&0xff) | 0x0700;  // black on white
80100376:	8b 0d 00 40 10 80    	mov    0x80104000,%ecx
8010037c:	8b 45 fc             	mov    -0x4(%ebp),%eax
8010037f:	8d 50 01             	lea    0x1(%eax),%edx
80100382:	89 55 fc             	mov    %edx,-0x4(%ebp)
80100385:	01 c0                	add    %eax,%eax
80100387:	01 c8                	add    %ecx,%eax
80100389:	8b 55 08             	mov    0x8(%ebp),%edx
8010038c:	0f b6 d2             	movzbl %dl,%edx
8010038f:	80 ce 07             	or     $0x7,%dh
80100392:	66 89 10             	mov    %dx,(%eax)

  outb(CRTPORT, 14);
80100395:	6a 0e                	push   $0xe
80100397:	68 d4 03 00 00       	push   $0x3d4
8010039c:	e8 1c fd ff ff       	call   801000bd <outb>
801003a1:	83 c4 08             	add    $0x8,%esp
  outb(CRTPORT+1, pos>>8);
801003a4:	8b 45 fc             	mov    -0x4(%ebp),%eax
801003a7:	c1 f8 08             	sar    $0x8,%eax
801003aa:	0f b6 c0             	movzbl %al,%eax
801003ad:	50                   	push   %eax
801003ae:	68 d5 03 00 00       	push   $0x3d5
801003b3:	e8 05 fd ff ff       	call   801000bd <outb>
801003b8:	83 c4 08             	add    $0x8,%esp
  outb(CRTPORT, 15);
801003bb:	6a 0f                	push   $0xf
801003bd:	68 d4 03 00 00       	push   $0x3d4
801003c2:	e8 f6 fc ff ff       	call   801000bd <outb>
801003c7:	83 c4 08             	add    $0x8,%esp
  outb(CRTPORT+1, pos);
801003ca:	8b 45 fc             	mov    -0x4(%ebp),%eax
801003cd:	0f b6 c0             	movzbl %al,%eax
801003d0:	50                   	push   %eax
801003d1:	68 d5 03 00 00       	push   $0x3d5
801003d6:	e8 e2 fc ff ff       	call   801000bd <outb>
801003db:	83 c4 08             	add    $0x8,%esp
  crt[pos] = ' ' | 0x0700;
801003de:	a1 00 40 10 80       	mov    0x80104000,%eax
801003e3:	8b 55 fc             	mov    -0x4(%ebp),%edx
801003e6:	01 d2                	add    %edx,%edx
801003e8:	01 d0                	add    %edx,%eax
801003ea:	66 c7 00 20 07       	movw   $0x720,(%eax)
}
801003ef:	c9                   	leave  
801003f0:	c3                   	ret    

801003f1 <consputc>:

void
consputc(int c)
{
801003f1:	55                   	push   %ebp
801003f2:	89 e5                	mov    %esp,%ebp
801003f4:	83 ec 08             	sub    $0x8,%esp
  if(c == BACKSPACE){
801003f7:	81 7d 08 00 01 00 00 	cmpl   $0x100,0x8(%ebp)
801003fe:	75 29                	jne    80100429 <consputc+0x38>
    uartputc('\b'); uartputc(' '); uartputc('\b');
80100400:	83 ec 0c             	sub    $0xc,%esp
80100403:	6a 08                	push   $0x8
80100405:	e8 a0 1a 00 00       	call   80101eaa <uartputc>
8010040a:	83 c4 10             	add    $0x10,%esp
8010040d:	83 ec 0c             	sub    $0xc,%esp
80100410:	6a 20                	push   $0x20
80100412:	e8 93 1a 00 00       	call   80101eaa <uartputc>
80100417:	83 c4 10             	add    $0x10,%esp
8010041a:	83 ec 0c             	sub    $0xc,%esp
8010041d:	6a 08                	push   $0x8
8010041f:	e8 86 1a 00 00       	call   80101eaa <uartputc>
80100424:	83 c4 10             	add    $0x10,%esp
80100427:	eb 0e                	jmp    80100437 <consputc+0x46>
  } else
    uartputc(c);
80100429:	83 ec 0c             	sub    $0xc,%esp
8010042c:	ff 75 08             	pushl  0x8(%ebp)
8010042f:	e8 76 1a 00 00       	call   80101eaa <uartputc>
80100434:	83 c4 10             	add    $0x10,%esp
  cgaputc(c);
80100437:	83 ec 0c             	sub    $0xc,%esp
8010043a:	ff 75 08             	pushl  0x8(%ebp)
8010043d:	e8 9c fe ff ff       	call   801002de <cgaputc>
80100442:	83 c4 10             	add    $0x10,%esp
}
80100445:	c9                   	leave  
80100446:	c3                   	ret    

80100447 <consoleinit>:


void consoleinit(void)
{
80100447:	55                   	push   %ebp
80100448:	89 e5                	mov    %esp,%ebp
8010044a:	83 ec 08             	sub    $0x8,%esp
  picenable(IRQ_KBD);
8010044d:	83 ec 0c             	sub    $0xc,%esp
80100450:	6a 01                	push   $0x1
80100452:	e8 6f 0b 00 00       	call   80100fc6 <picenable>
80100457:	83 c4 10             	add    $0x10,%esp
  ioapicenable(IRQ_KBD, 0);
8010045a:	83 ec 08             	sub    $0x8,%esp
8010045d:	6a 00                	push   $0x0
8010045f:	6a 01                	push   $0x1
80100461:	e8 16 0d 00 00       	call   8010117c <ioapicenable>
80100466:	83 c4 10             	add    $0x10,%esp
}
80100469:	c9                   	leave  
8010046a:	c3                   	ret    

8010046b <consoleintr>:

#define C(x)  ((x)-'@')  // Control-x

void
consoleintr(int (*getc)(void))
{
8010046b:	55                   	push   %ebp
8010046c:	89 e5                	mov    %esp,%ebp
8010046e:	83 ec 18             	sub    $0x18,%esp
  int c;

  while((c = getc()) >= 0){
80100471:	e9 07 01 00 00       	jmp    8010057d <consoleintr+0x112>
   switch(c){
80100476:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100479:	83 f8 15             	cmp    $0x15,%eax
8010047c:	74 29                	je     801004a7 <consoleintr+0x3c>
8010047e:	83 f8 7f             	cmp    $0x7f,%eax
80100481:	74 4e                	je     801004d1 <consoleintr+0x66>
80100483:	83 f8 08             	cmp    $0x8,%eax
80100486:	74 49                	je     801004d1 <consoleintr+0x66>
80100488:	eb 75                	jmp    801004ff <consoleintr+0x94>
    case C('U'):  // Kill line.
      while(input.e != input.w &&
            input.buf[(input.e-1) % INPUT_BUF] != '\n'){
        input.e--;
8010048a:	a1 c8 5f 10 80       	mov    0x80105fc8,%eax
8010048f:	83 e8 01             	sub    $0x1,%eax
80100492:	a3 c8 5f 10 80       	mov    %eax,0x80105fc8
        consputc(BACKSPACE);
80100497:	83 ec 0c             	sub    $0xc,%esp
8010049a:	68 00 01 00 00       	push   $0x100
8010049f:	e8 4d ff ff ff       	call   801003f1 <consputc>
801004a4:	83 c4 10             	add    $0x10,%esp
  int c;

  while((c = getc()) >= 0){
   switch(c){
    case C('U'):  // Kill line.
      while(input.e != input.w &&
801004a7:	8b 15 c8 5f 10 80    	mov    0x80105fc8,%edx
801004ad:	a1 c4 5f 10 80       	mov    0x80105fc4,%eax
801004b2:	39 c2                	cmp    %eax,%edx
801004b4:	74 16                	je     801004cc <consoleintr+0x61>
            input.buf[(input.e-1) % INPUT_BUF] != '\n'){
801004b6:	a1 c8 5f 10 80       	mov    0x80105fc8,%eax
801004bb:	83 e8 01             	sub    $0x1,%eax
801004be:	83 e0 7f             	and    $0x7f,%eax
801004c1:	0f b6 80 40 5f 10 80 	movzbl -0x7fefa0c0(%eax),%eax
  int c;

  while((c = getc()) >= 0){
   switch(c){
    case C('U'):  // Kill line.
      while(input.e != input.w &&
801004c8:	3c 0a                	cmp    $0xa,%al
801004ca:	75 be                	jne    8010048a <consoleintr+0x1f>
            input.buf[(input.e-1) % INPUT_BUF] != '\n'){
        input.e--;
        consputc(BACKSPACE);
      }
      break;
801004cc:	e9 ac 00 00 00       	jmp    8010057d <consoleintr+0x112>
    case C('H'): case '\x7f':  // Backspace
      if(input.e != input.w){
801004d1:	8b 15 c8 5f 10 80    	mov    0x80105fc8,%edx
801004d7:	a1 c4 5f 10 80       	mov    0x80105fc4,%eax
801004dc:	39 c2                	cmp    %eax,%edx
801004de:	74 1d                	je     801004fd <consoleintr+0x92>
        input.e--;
801004e0:	a1 c8 5f 10 80       	mov    0x80105fc8,%eax
801004e5:	83 e8 01             	sub    $0x1,%eax
801004e8:	a3 c8 5f 10 80       	mov    %eax,0x80105fc8
        consputc(BACKSPACE);
801004ed:	83 ec 0c             	sub    $0xc,%esp
801004f0:	68 00 01 00 00       	push   $0x100
801004f5:	e8 f7 fe ff ff       	call   801003f1 <consputc>
801004fa:	83 c4 10             	add    $0x10,%esp
      }
      break;
801004fd:	eb 7e                	jmp    8010057d <consoleintr+0x112>
    default:
      if(c != 0 && input.e-input.r < INPUT_BUF){
801004ff:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80100503:	74 77                	je     8010057c <consoleintr+0x111>
80100505:	8b 15 c8 5f 10 80    	mov    0x80105fc8,%edx
8010050b:	a1 c0 5f 10 80       	mov    0x80105fc0,%eax
80100510:	29 c2                	sub    %eax,%edx
80100512:	89 d0                	mov    %edx,%eax
80100514:	83 f8 7f             	cmp    $0x7f,%eax
80100517:	77 63                	ja     8010057c <consoleintr+0x111>
        c = (c == '\r') ? '\n' : c;
80100519:	83 7d f4 0d          	cmpl   $0xd,-0xc(%ebp)
8010051d:	74 05                	je     80100524 <consoleintr+0xb9>
8010051f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100522:	eb 05                	jmp    80100529 <consoleintr+0xbe>
80100524:	b8 0a 00 00 00       	mov    $0xa,%eax
80100529:	89 45 f4             	mov    %eax,-0xc(%ebp)
        input.buf[input.e++ % INPUT_BUF] = c;
8010052c:	a1 c8 5f 10 80       	mov    0x80105fc8,%eax
80100531:	8d 50 01             	lea    0x1(%eax),%edx
80100534:	89 15 c8 5f 10 80    	mov    %edx,0x80105fc8
8010053a:	83 e0 7f             	and    $0x7f,%eax
8010053d:	8b 55 f4             	mov    -0xc(%ebp),%edx
80100540:	88 90 40 5f 10 80    	mov    %dl,-0x7fefa0c0(%eax)
        consputc(c);
80100546:	83 ec 0c             	sub    $0xc,%esp
80100549:	ff 75 f4             	pushl  -0xc(%ebp)
8010054c:	e8 a0 fe ff ff       	call   801003f1 <consputc>
80100551:	83 c4 10             	add    $0x10,%esp
        if(c == '\n' || c == C('D') || input.e == input.r+INPUT_BUF){
80100554:	83 7d f4 0a          	cmpl   $0xa,-0xc(%ebp)
80100558:	74 18                	je     80100572 <consoleintr+0x107>
8010055a:	83 7d f4 04          	cmpl   $0x4,-0xc(%ebp)
8010055e:	74 12                	je     80100572 <consoleintr+0x107>
80100560:	a1 c8 5f 10 80       	mov    0x80105fc8,%eax
80100565:	8b 15 c0 5f 10 80    	mov    0x80105fc0,%edx
8010056b:	83 ea 80             	sub    $0xffffff80,%edx
8010056e:	39 d0                	cmp    %edx,%eax
80100570:	75 0a                	jne    8010057c <consoleintr+0x111>
          input.w = input.e;
80100572:	a1 c8 5f 10 80       	mov    0x80105fc8,%eax
80100577:	a3 c4 5f 10 80       	mov    %eax,0x80105fc4
        }
      }
      break;
8010057c:	90                   	nop
void
consoleintr(int (*getc)(void))
{
  int c;

  while((c = getc()) >= 0){
8010057d:	8b 45 08             	mov    0x8(%ebp),%eax
80100580:	ff d0                	call   *%eax
80100582:	89 45 f4             	mov    %eax,-0xc(%ebp)
80100585:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80100589:	0f 89 e7 fe ff ff    	jns    80100476 <consoleintr+0xb>
        }
      }
      break;
    }
  }
}
8010058f:	c9                   	leave  
80100590:	c3                   	ret    

80100591 <stosb>:
               "cc");
}

static inline void
stosb(void *addr, int data, int cnt)
{
80100591:	55                   	push   %ebp
80100592:	89 e5                	mov    %esp,%ebp
80100594:	57                   	push   %edi
80100595:	53                   	push   %ebx
  asm volatile("cld; rep stosb" :
80100596:	8b 4d 08             	mov    0x8(%ebp),%ecx
80100599:	8b 55 10             	mov    0x10(%ebp),%edx
8010059c:	8b 45 0c             	mov    0xc(%ebp),%eax
8010059f:	89 cb                	mov    %ecx,%ebx
801005a1:	89 df                	mov    %ebx,%edi
801005a3:	89 d1                	mov    %edx,%ecx
801005a5:	fc                   	cld    
801005a6:	f3 aa                	rep stos %al,%es:(%edi)
801005a8:	89 ca                	mov    %ecx,%edx
801005aa:	89 fb                	mov    %edi,%ebx
801005ac:	89 5d 08             	mov    %ebx,0x8(%ebp)
801005af:	89 55 10             	mov    %edx,0x10(%ebp)
               "=D" (addr), "=c" (cnt) :
               "0" (addr), "1" (cnt), "a" (data) :
               "memory", "cc");
}
801005b2:	5b                   	pop    %ebx
801005b3:	5f                   	pop    %edi
801005b4:	5d                   	pop    %ebp
801005b5:	c3                   	ret    

801005b6 <stosl>:

static inline void
stosl(void *addr, int data, int cnt)
{
801005b6:	55                   	push   %ebp
801005b7:	89 e5                	mov    %esp,%ebp
801005b9:	57                   	push   %edi
801005ba:	53                   	push   %ebx
  asm volatile("cld; rep stosl" :
801005bb:	8b 4d 08             	mov    0x8(%ebp),%ecx
801005be:	8b 55 10             	mov    0x10(%ebp),%edx
801005c1:	8b 45 0c             	mov    0xc(%ebp),%eax
801005c4:	89 cb                	mov    %ecx,%ebx
801005c6:	89 df                	mov    %ebx,%edi
801005c8:	89 d1                	mov    %edx,%ecx
801005ca:	fc                   	cld    
801005cb:	f3 ab                	rep stos %eax,%es:(%edi)
801005cd:	89 ca                	mov    %ecx,%edx
801005cf:	89 fb                	mov    %edi,%ebx
801005d1:	89 5d 08             	mov    %ebx,0x8(%ebp)
801005d4:	89 55 10             	mov    %edx,0x10(%ebp)
               "=D" (addr), "=c" (cnt) :
               "0" (addr), "1" (cnt), "a" (data) :
               "memory", "cc");
}
801005d7:	5b                   	pop    %ebx
801005d8:	5f                   	pop    %edi
801005d9:	5d                   	pop    %ebp
801005da:	c3                   	ret    

801005db <memset>:
#include "types.h"
#include "x86.h"

void*
memset(void *dst, int c, uint n)
{
801005db:	55                   	push   %ebp
801005dc:	89 e5                	mov    %esp,%ebp
  if ((int)dst%4 == 0 && n%4 == 0){
801005de:	8b 45 08             	mov    0x8(%ebp),%eax
801005e1:	83 e0 03             	and    $0x3,%eax
801005e4:	85 c0                	test   %eax,%eax
801005e6:	75 43                	jne    8010062b <memset+0x50>
801005e8:	8b 45 10             	mov    0x10(%ebp),%eax
801005eb:	83 e0 03             	and    $0x3,%eax
801005ee:	85 c0                	test   %eax,%eax
801005f0:	75 39                	jne    8010062b <memset+0x50>
    c &= 0xFF;
801005f2:	81 65 0c ff 00 00 00 	andl   $0xff,0xc(%ebp)
    stosl(dst, (c<<24)|(c<<16)|(c<<8)|c, n/4);
801005f9:	8b 45 10             	mov    0x10(%ebp),%eax
801005fc:	c1 e8 02             	shr    $0x2,%eax
801005ff:	89 c1                	mov    %eax,%ecx
80100601:	8b 45 0c             	mov    0xc(%ebp),%eax
80100604:	c1 e0 18             	shl    $0x18,%eax
80100607:	89 c2                	mov    %eax,%edx
80100609:	8b 45 0c             	mov    0xc(%ebp),%eax
8010060c:	c1 e0 10             	shl    $0x10,%eax
8010060f:	09 c2                	or     %eax,%edx
80100611:	8b 45 0c             	mov    0xc(%ebp),%eax
80100614:	c1 e0 08             	shl    $0x8,%eax
80100617:	09 d0                	or     %edx,%eax
80100619:	0b 45 0c             	or     0xc(%ebp),%eax
8010061c:	51                   	push   %ecx
8010061d:	50                   	push   %eax
8010061e:	ff 75 08             	pushl  0x8(%ebp)
80100621:	e8 90 ff ff ff       	call   801005b6 <stosl>
80100626:	83 c4 0c             	add    $0xc,%esp
80100629:	eb 12                	jmp    8010063d <memset+0x62>
  } else
    stosb(dst, c, n);
8010062b:	8b 45 10             	mov    0x10(%ebp),%eax
8010062e:	50                   	push   %eax
8010062f:	ff 75 0c             	pushl  0xc(%ebp)
80100632:	ff 75 08             	pushl  0x8(%ebp)
80100635:	e8 57 ff ff ff       	call   80100591 <stosb>
8010063a:	83 c4 0c             	add    $0xc,%esp
  return dst;
8010063d:	8b 45 08             	mov    0x8(%ebp),%eax
}
80100640:	c9                   	leave  
80100641:	c3                   	ret    

80100642 <kfree>:


extern char end[]; // first address after kernel loaded from ELF file

void kfree(char *v)
{
80100642:	55                   	push   %ebp
80100643:	89 e5                	mov    %esp,%ebp
80100645:	83 ec 18             	sub    $0x18,%esp
  struct run *r;

  memset(v, 1, PGSIZE);
80100648:	83 ec 04             	sub    $0x4,%esp
8010064b:	68 00 10 00 00       	push   $0x1000
80100650:	6a 01                	push   $0x1
80100652:	ff 75 08             	pushl  0x8(%ebp)
80100655:	e8 81 ff ff ff       	call   801005db <memset>
8010065a:	83 c4 10             	add    $0x10,%esp

  r = (struct run*)v;
8010065d:	8b 45 08             	mov    0x8(%ebp),%eax
80100660:	89 45 f4             	mov    %eax,-0xc(%ebp)
  r->next = kmem.freelist;
80100663:	8b 15 cc 5f 10 80    	mov    0x80105fcc,%edx
80100669:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010066c:	89 10                	mov    %edx,(%eax)
  kmem.freelist = r;
8010066e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100671:	a3 cc 5f 10 80       	mov    %eax,0x80105fcc

}
80100676:	c9                   	leave  
80100677:	c3                   	ret    

80100678 <freerange>:

void freerange(void *vstart, void *vend)
{
80100678:	55                   	push   %ebp
80100679:	89 e5                	mov    %esp,%ebp
8010067b:	83 ec 18             	sub    $0x18,%esp
  char *p;
  p = (char*)PGROUNDUP((uint)vstart);
8010067e:	8b 45 08             	mov    0x8(%ebp),%eax
80100681:	05 ff 0f 00 00       	add    $0xfff,%eax
80100686:	25 00 f0 ff ff       	and    $0xfffff000,%eax
8010068b:	89 45 f4             	mov    %eax,-0xc(%ebp)
  for(; p + PGSIZE <= (char*)vend; p += PGSIZE)
8010068e:	eb 15                	jmp    801006a5 <freerange+0x2d>
    kfree(p);
80100690:	83 ec 0c             	sub    $0xc,%esp
80100693:	ff 75 f4             	pushl  -0xc(%ebp)
80100696:	e8 a7 ff ff ff       	call   80100642 <kfree>
8010069b:	83 c4 10             	add    $0x10,%esp

void freerange(void *vstart, void *vend)
{
  char *p;
  p = (char*)PGROUNDUP((uint)vstart);
  for(; p + PGSIZE <= (char*)vend; p += PGSIZE)
8010069e:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
801006a5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801006a8:	05 00 10 00 00       	add    $0x1000,%eax
801006ad:	3b 45 0c             	cmp    0xc(%ebp),%eax
801006b0:	76 de                	jbe    80100690 <freerange+0x18>
    kfree(p);
}
801006b2:	c9                   	leave  
801006b3:	c3                   	ret    

801006b4 <kinit>:


void kinit(void *vstart, void *vend)
{
801006b4:	55                   	push   %ebp
801006b5:	89 e5                	mov    %esp,%ebp
801006b7:	83 ec 08             	sub    $0x8,%esp
  freerange(vstart, vend);
801006ba:	83 ec 08             	sub    $0x8,%esp
801006bd:	ff 75 0c             	pushl  0xc(%ebp)
801006c0:	ff 75 08             	pushl  0x8(%ebp)
801006c3:	e8 b0 ff ff ff       	call   80100678 <freerange>
801006c8:	83 c4 10             	add    $0x10,%esp
}
801006cb:	c9                   	leave  
801006cc:	c3                   	ret    

801006cd <kalloc>:

//分配一个4096字节的物理内存页，返回内核可以使用的指针。如果无法分配，则返回0
char* kalloc(void)
{
801006cd:	55                   	push   %ebp
801006ce:	89 e5                	mov    %esp,%ebp
801006d0:	83 ec 10             	sub    $0x10,%esp
  struct run *r;
  r = kmem.freelist;
801006d3:	a1 cc 5f 10 80       	mov    0x80105fcc,%eax
801006d8:	89 45 fc             	mov    %eax,-0x4(%ebp)
  if(r)
801006db:	83 7d fc 00          	cmpl   $0x0,-0x4(%ebp)
801006df:	74 0a                	je     801006eb <kalloc+0x1e>
    kmem.freelist = r->next;
801006e1:	8b 45 fc             	mov    -0x4(%ebp),%eax
801006e4:	8b 00                	mov    (%eax),%eax
801006e6:	a3 cc 5f 10 80       	mov    %eax,0x80105fcc
  return (char*)r;
801006eb:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
801006ee:	c9                   	leave  
801006ef:	c3                   	ret    

801006f0 <inb>:
// Routines to let C code use special x86 instructions.

static inline uchar
inb(ushort port)
{
801006f0:	55                   	push   %ebp
801006f1:	89 e5                	mov    %esp,%ebp
801006f3:	83 ec 14             	sub    $0x14,%esp
801006f6:	8b 45 08             	mov    0x8(%ebp),%eax
801006f9:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
  uchar data;

  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
801006fd:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
80100701:	89 c2                	mov    %eax,%edx
80100703:	ec                   	in     (%dx),%al
80100704:	88 45 ff             	mov    %al,-0x1(%ebp)
  return data;
80100707:	0f b6 45 ff          	movzbl -0x1(%ebp),%eax
}
8010070b:	c9                   	leave  
8010070c:	c3                   	ret    

8010070d <kbdgetc>:
#include "defs.h"
#include "kbd.h"

int
kbdgetc(void)
{
8010070d:	55                   	push   %ebp
8010070e:	89 e5                	mov    %esp,%ebp
80100710:	83 ec 10             	sub    $0x10,%esp
  static uchar *charcode[4] = {
    normalmap, shiftmap, ctlmap, ctlmap
  };
  uint st, data, c;

  st = inb(KBSTATP);
80100713:	6a 64                	push   $0x64
80100715:	e8 d6 ff ff ff       	call   801006f0 <inb>
8010071a:	83 c4 04             	add    $0x4,%esp
8010071d:	0f b6 c0             	movzbl %al,%eax
80100720:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if((st & KBS_DIB) == 0)
80100723:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100726:	83 e0 01             	and    $0x1,%eax
80100729:	85 c0                	test   %eax,%eax
8010072b:	75 0a                	jne    80100737 <kbdgetc+0x2a>
    return -1;
8010072d:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80100732:	e9 23 01 00 00       	jmp    8010085a <kbdgetc+0x14d>
  data = inb(KBDATAP);
80100737:	6a 60                	push   $0x60
80100739:	e8 b2 ff ff ff       	call   801006f0 <inb>
8010073e:	83 c4 04             	add    $0x4,%esp
80100741:	0f b6 c0             	movzbl %al,%eax
80100744:	89 45 fc             	mov    %eax,-0x4(%ebp)

  if(data == 0xE0){
80100747:	81 7d fc e0 00 00 00 	cmpl   $0xe0,-0x4(%ebp)
8010074e:	75 17                	jne    80100767 <kbdgetc+0x5a>
    shift |= E0ESC;
80100750:	a1 00 4f 10 80       	mov    0x80104f00,%eax
80100755:	83 c8 40             	or     $0x40,%eax
80100758:	a3 00 4f 10 80       	mov    %eax,0x80104f00
    return 0;
8010075d:	b8 00 00 00 00       	mov    $0x0,%eax
80100762:	e9 f3 00 00 00       	jmp    8010085a <kbdgetc+0x14d>
  } else if(data & 0x80){
80100767:	8b 45 fc             	mov    -0x4(%ebp),%eax
8010076a:	25 80 00 00 00       	and    $0x80,%eax
8010076f:	85 c0                	test   %eax,%eax
80100771:	74 45                	je     801007b8 <kbdgetc+0xab>
    // Key released
    data = (shift & E0ESC ? data : data & 0x7F);
80100773:	a1 00 4f 10 80       	mov    0x80104f00,%eax
80100778:	83 e0 40             	and    $0x40,%eax
8010077b:	85 c0                	test   %eax,%eax
8010077d:	75 08                	jne    80100787 <kbdgetc+0x7a>
8010077f:	8b 45 fc             	mov    -0x4(%ebp),%eax
80100782:	83 e0 7f             	and    $0x7f,%eax
80100785:	eb 03                	jmp    8010078a <kbdgetc+0x7d>
80100787:	8b 45 fc             	mov    -0x4(%ebp),%eax
8010078a:	89 45 fc             	mov    %eax,-0x4(%ebp)
    shift &= ~(shiftcode[data] | E0ESC);
8010078d:	8b 45 fc             	mov    -0x4(%ebp),%eax
80100790:	05 40 40 10 80       	add    $0x80104040,%eax
80100795:	0f b6 00             	movzbl (%eax),%eax
80100798:	83 c8 40             	or     $0x40,%eax
8010079b:	0f b6 c0             	movzbl %al,%eax
8010079e:	f7 d0                	not    %eax
801007a0:	89 c2                	mov    %eax,%edx
801007a2:	a1 00 4f 10 80       	mov    0x80104f00,%eax
801007a7:	21 d0                	and    %edx,%eax
801007a9:	a3 00 4f 10 80       	mov    %eax,0x80104f00
    return 0;
801007ae:	b8 00 00 00 00       	mov    $0x0,%eax
801007b3:	e9 a2 00 00 00       	jmp    8010085a <kbdgetc+0x14d>
  } else if(shift & E0ESC){
801007b8:	a1 00 4f 10 80       	mov    0x80104f00,%eax
801007bd:	83 e0 40             	and    $0x40,%eax
801007c0:	85 c0                	test   %eax,%eax
801007c2:	74 14                	je     801007d8 <kbdgetc+0xcb>
    // Last character was an E0 escape; or with 0x80
    data |= 0x80;
801007c4:	81 4d fc 80 00 00 00 	orl    $0x80,-0x4(%ebp)
    shift &= ~E0ESC;
801007cb:	a1 00 4f 10 80       	mov    0x80104f00,%eax
801007d0:	83 e0 bf             	and    $0xffffffbf,%eax
801007d3:	a3 00 4f 10 80       	mov    %eax,0x80104f00
  }

  shift |= shiftcode[data];
801007d8:	8b 45 fc             	mov    -0x4(%ebp),%eax
801007db:	05 40 40 10 80       	add    $0x80104040,%eax
801007e0:	0f b6 00             	movzbl (%eax),%eax
801007e3:	0f b6 d0             	movzbl %al,%edx
801007e6:	a1 00 4f 10 80       	mov    0x80104f00,%eax
801007eb:	09 d0                	or     %edx,%eax
801007ed:	a3 00 4f 10 80       	mov    %eax,0x80104f00
  shift ^= togglecode[data];
801007f2:	8b 45 fc             	mov    -0x4(%ebp),%eax
801007f5:	05 40 41 10 80       	add    $0x80104140,%eax
801007fa:	0f b6 00             	movzbl (%eax),%eax
801007fd:	0f b6 d0             	movzbl %al,%edx
80100800:	a1 00 4f 10 80       	mov    0x80104f00,%eax
80100805:	31 d0                	xor    %edx,%eax
80100807:	a3 00 4f 10 80       	mov    %eax,0x80104f00
  c = charcode[shift & (CTL | SHIFT)][data];
8010080c:	a1 00 4f 10 80       	mov    0x80104f00,%eax
80100811:	83 e0 03             	and    $0x3,%eax
80100814:	8b 14 85 40 45 10 80 	mov    -0x7fefbac0(,%eax,4),%edx
8010081b:	8b 45 fc             	mov    -0x4(%ebp),%eax
8010081e:	01 d0                	add    %edx,%eax
80100820:	0f b6 00             	movzbl (%eax),%eax
80100823:	0f b6 c0             	movzbl %al,%eax
80100826:	89 45 f8             	mov    %eax,-0x8(%ebp)
  if(shift & CAPSLOCK){
80100829:	a1 00 4f 10 80       	mov    0x80104f00,%eax
8010082e:	83 e0 08             	and    $0x8,%eax
80100831:	85 c0                	test   %eax,%eax
80100833:	74 22                	je     80100857 <kbdgetc+0x14a>
    if('a' <= c && c <= 'z')
80100835:	83 7d f8 60          	cmpl   $0x60,-0x8(%ebp)
80100839:	76 0c                	jbe    80100847 <kbdgetc+0x13a>
8010083b:	83 7d f8 7a          	cmpl   $0x7a,-0x8(%ebp)
8010083f:	77 06                	ja     80100847 <kbdgetc+0x13a>
      c += 'A' - 'a';
80100841:	83 6d f8 20          	subl   $0x20,-0x8(%ebp)
80100845:	eb 10                	jmp    80100857 <kbdgetc+0x14a>
    else if('A' <= c && c <= 'Z')
80100847:	83 7d f8 40          	cmpl   $0x40,-0x8(%ebp)
8010084b:	76 0a                	jbe    80100857 <kbdgetc+0x14a>
8010084d:	83 7d f8 5a          	cmpl   $0x5a,-0x8(%ebp)
80100851:	77 04                	ja     80100857 <kbdgetc+0x14a>
      c += 'a' - 'A';
80100853:	83 45 f8 20          	addl   $0x20,-0x8(%ebp)
  }
  return c;
80100857:	8b 45 f8             	mov    -0x8(%ebp),%eax
}
8010085a:	c9                   	leave  
8010085b:	c3                   	ret    

8010085c <kbdintr>:

void
kbdintr(void)
{
8010085c:	55                   	push   %ebp
8010085d:	89 e5                	mov    %esp,%ebp
8010085f:	83 ec 08             	sub    $0x8,%esp
  consoleintr(kbdgetc);
80100862:	83 ec 0c             	sub    $0xc,%esp
80100865:	68 0d 07 10 80       	push   $0x8010070d
8010086a:	e8 fc fb ff ff       	call   8010046b <consoleintr>
8010086f:	83 c4 10             	add    $0x10,%esp
}
80100872:	c9                   	leave  
80100873:	c3                   	ret    

80100874 <lgdt>:

struct segdesc;

static inline void
lgdt(struct segdesc *p, int size)
{
80100874:	55                   	push   %ebp
80100875:	89 e5                	mov    %esp,%ebp
80100877:	83 ec 10             	sub    $0x10,%esp
  volatile ushort pd[3];

  pd[0] = size-1;
8010087a:	8b 45 0c             	mov    0xc(%ebp),%eax
8010087d:	83 e8 01             	sub    $0x1,%eax
80100880:	66 89 45 fa          	mov    %ax,-0x6(%ebp)
  pd[1] = (uint)p;
80100884:	8b 45 08             	mov    0x8(%ebp),%eax
80100887:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  pd[2] = (uint)p >> 16;
8010088b:	8b 45 08             	mov    0x8(%ebp),%eax
8010088e:	c1 e8 10             	shr    $0x10,%eax
80100891:	66 89 45 fe          	mov    %ax,-0x2(%ebp)

  asm volatile("lgdt (%0)" : : "r" (pd));
80100895:	8d 45 fa             	lea    -0x6(%ebp),%eax
80100898:	0f 01 10             	lgdtl  (%eax)
}
8010089b:	c9                   	leave  
8010089c:	c3                   	ret    

8010089d <loadgs>:
  return eflags;
}

static inline void
loadgs(ushort v)
{
8010089d:	55                   	push   %ebp
8010089e:	89 e5                	mov    %esp,%ebp
801008a0:	83 ec 04             	sub    $0x4,%esp
801008a3:	8b 45 08             	mov    0x8(%ebp),%eax
801008a6:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  asm volatile("movw %0, %%gs" : : "r" (v));
801008aa:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
801008ae:	8e e8                	mov    %eax,%gs
}
801008b0:	c9                   	leave  
801008b1:	c3                   	ret    

801008b2 <lcr3>:
  return val;
}

static inline void
lcr3(uint val) 
{
801008b2:	55                   	push   %ebp
801008b3:	89 e5                	mov    %esp,%ebp
  asm volatile("movl %0,%%cr3" : : "r" (val));
801008b5:	8b 45 08             	mov    0x8(%ebp),%eax
801008b8:	0f 22 d8             	mov    %eax,%cr3
}
801008bb:	5d                   	pop    %ebp
801008bc:	c3                   	ret    

801008bd <v2p>:
#define KERNBASE 0x80000000         // First kernel virtual address
#define KERNLINK (KERNBASE+EXTMEM)  // Address where kernel is linked

#ifndef __ASSEMBLER__

static inline uint v2p(void *a) { return ((uint) (a))  - KERNBASE; }
801008bd:	55                   	push   %ebp
801008be:	89 e5                	mov    %esp,%ebp
801008c0:	8b 45 08             	mov    0x8(%ebp),%eax
801008c3:	05 00 00 00 80       	add    $0x80000000,%eax
801008c8:	5d                   	pop    %ebp
801008c9:	c3                   	ret    

801008ca <p2v>:
static inline void *p2v(uint a) { return (void *) ((a) + KERNBASE); }
801008ca:	55                   	push   %ebp
801008cb:	89 e5                	mov    %esp,%ebp
801008cd:	8b 45 08             	mov    0x8(%ebp),%eax
801008d0:	05 00 00 00 80       	add    $0x80000000,%eax
801008d5:	5d                   	pop    %ebp
801008d6:	c3                   	ret    

801008d7 <seginit>:
struct cpu cpus[1];
extern char data[];  // 由kernel.ld来定义
pde_t *kpgdir;  // 被进程调度所使用(以后)

void seginit(void)
{
801008d7:	55                   	push   %ebp
801008d8:	89 e5                	mov    %esp,%ebp
801008da:	53                   	push   %ebx
801008db:	83 ec 10             	sub    $0x10,%esp
  struct cpu *c;
  c = &cpus[0]; 
801008de:	c7 45 f8 00 60 10 80 	movl   $0x80106000,-0x8(%ebp)
  c->gdt[SEG_KCODE] = SEG(STA_X|STA_R, 0, 0xffffffff, 0);        
801008e5:	8b 45 f8             	mov    -0x8(%ebp),%eax
801008e8:	66 c7 40 08 ff ff    	movw   $0xffff,0x8(%eax)
801008ee:	8b 45 f8             	mov    -0x8(%ebp),%eax
801008f1:	66 c7 40 0a 00 00    	movw   $0x0,0xa(%eax)
801008f7:	8b 45 f8             	mov    -0x8(%ebp),%eax
801008fa:	c6 40 0c 00          	movb   $0x0,0xc(%eax)
801008fe:	8b 45 f8             	mov    -0x8(%ebp),%eax
80100901:	0f b6 50 0d          	movzbl 0xd(%eax),%edx
80100905:	83 e2 f0             	and    $0xfffffff0,%edx
80100908:	83 ca 0a             	or     $0xa,%edx
8010090b:	88 50 0d             	mov    %dl,0xd(%eax)
8010090e:	8b 45 f8             	mov    -0x8(%ebp),%eax
80100911:	0f b6 50 0d          	movzbl 0xd(%eax),%edx
80100915:	83 ca 10             	or     $0x10,%edx
80100918:	88 50 0d             	mov    %dl,0xd(%eax)
8010091b:	8b 45 f8             	mov    -0x8(%ebp),%eax
8010091e:	0f b6 50 0d          	movzbl 0xd(%eax),%edx
80100922:	83 e2 9f             	and    $0xffffff9f,%edx
80100925:	88 50 0d             	mov    %dl,0xd(%eax)
80100928:	8b 45 f8             	mov    -0x8(%ebp),%eax
8010092b:	0f b6 50 0d          	movzbl 0xd(%eax),%edx
8010092f:	83 ca 80             	or     $0xffffff80,%edx
80100932:	88 50 0d             	mov    %dl,0xd(%eax)
80100935:	8b 45 f8             	mov    -0x8(%ebp),%eax
80100938:	0f b6 50 0e          	movzbl 0xe(%eax),%edx
8010093c:	83 ca 0f             	or     $0xf,%edx
8010093f:	88 50 0e             	mov    %dl,0xe(%eax)
80100942:	8b 45 f8             	mov    -0x8(%ebp),%eax
80100945:	0f b6 50 0e          	movzbl 0xe(%eax),%edx
80100949:	83 e2 ef             	and    $0xffffffef,%edx
8010094c:	88 50 0e             	mov    %dl,0xe(%eax)
8010094f:	8b 45 f8             	mov    -0x8(%ebp),%eax
80100952:	0f b6 50 0e          	movzbl 0xe(%eax),%edx
80100956:	83 e2 df             	and    $0xffffffdf,%edx
80100959:	88 50 0e             	mov    %dl,0xe(%eax)
8010095c:	8b 45 f8             	mov    -0x8(%ebp),%eax
8010095f:	0f b6 50 0e          	movzbl 0xe(%eax),%edx
80100963:	83 ca 40             	or     $0x40,%edx
80100966:	88 50 0e             	mov    %dl,0xe(%eax)
80100969:	8b 45 f8             	mov    -0x8(%ebp),%eax
8010096c:	0f b6 50 0e          	movzbl 0xe(%eax),%edx
80100970:	83 ca 80             	or     $0xffffff80,%edx
80100973:	88 50 0e             	mov    %dl,0xe(%eax)
80100976:	8b 45 f8             	mov    -0x8(%ebp),%eax
80100979:	c6 40 0f 00          	movb   $0x0,0xf(%eax)
  c->gdt[SEG_KDATA] = SEG(STA_W, 0, 0xffffffff, 0);
8010097d:	8b 45 f8             	mov    -0x8(%ebp),%eax
80100980:	66 c7 40 10 ff ff    	movw   $0xffff,0x10(%eax)
80100986:	8b 45 f8             	mov    -0x8(%ebp),%eax
80100989:	66 c7 40 12 00 00    	movw   $0x0,0x12(%eax)
8010098f:	8b 45 f8             	mov    -0x8(%ebp),%eax
80100992:	c6 40 14 00          	movb   $0x0,0x14(%eax)
80100996:	8b 45 f8             	mov    -0x8(%ebp),%eax
80100999:	0f b6 50 15          	movzbl 0x15(%eax),%edx
8010099d:	83 e2 f0             	and    $0xfffffff0,%edx
801009a0:	83 ca 02             	or     $0x2,%edx
801009a3:	88 50 15             	mov    %dl,0x15(%eax)
801009a6:	8b 45 f8             	mov    -0x8(%ebp),%eax
801009a9:	0f b6 50 15          	movzbl 0x15(%eax),%edx
801009ad:	83 ca 10             	or     $0x10,%edx
801009b0:	88 50 15             	mov    %dl,0x15(%eax)
801009b3:	8b 45 f8             	mov    -0x8(%ebp),%eax
801009b6:	0f b6 50 15          	movzbl 0x15(%eax),%edx
801009ba:	83 e2 9f             	and    $0xffffff9f,%edx
801009bd:	88 50 15             	mov    %dl,0x15(%eax)
801009c0:	8b 45 f8             	mov    -0x8(%ebp),%eax
801009c3:	0f b6 50 15          	movzbl 0x15(%eax),%edx
801009c7:	83 ca 80             	or     $0xffffff80,%edx
801009ca:	88 50 15             	mov    %dl,0x15(%eax)
801009cd:	8b 45 f8             	mov    -0x8(%ebp),%eax
801009d0:	0f b6 50 16          	movzbl 0x16(%eax),%edx
801009d4:	83 ca 0f             	or     $0xf,%edx
801009d7:	88 50 16             	mov    %dl,0x16(%eax)
801009da:	8b 45 f8             	mov    -0x8(%ebp),%eax
801009dd:	0f b6 50 16          	movzbl 0x16(%eax),%edx
801009e1:	83 e2 ef             	and    $0xffffffef,%edx
801009e4:	88 50 16             	mov    %dl,0x16(%eax)
801009e7:	8b 45 f8             	mov    -0x8(%ebp),%eax
801009ea:	0f b6 50 16          	movzbl 0x16(%eax),%edx
801009ee:	83 e2 df             	and    $0xffffffdf,%edx
801009f1:	88 50 16             	mov    %dl,0x16(%eax)
801009f4:	8b 45 f8             	mov    -0x8(%ebp),%eax
801009f7:	0f b6 50 16          	movzbl 0x16(%eax),%edx
801009fb:	83 ca 40             	or     $0x40,%edx
801009fe:	88 50 16             	mov    %dl,0x16(%eax)
80100a01:	8b 45 f8             	mov    -0x8(%ebp),%eax
80100a04:	0f b6 50 16          	movzbl 0x16(%eax),%edx
80100a08:	83 ca 80             	or     $0xffffff80,%edx
80100a0b:	88 50 16             	mov    %dl,0x16(%eax)
80100a0e:	8b 45 f8             	mov    -0x8(%ebp),%eax
80100a11:	c6 40 17 00          	movb   $0x0,0x17(%eax)
  c->gdt[SEG_UCODE] = SEG(STA_X|STA_R, 0, 0xffffffff, DPL_USER);
80100a15:	8b 45 f8             	mov    -0x8(%ebp),%eax
80100a18:	66 c7 40 20 ff ff    	movw   $0xffff,0x20(%eax)
80100a1e:	8b 45 f8             	mov    -0x8(%ebp),%eax
80100a21:	66 c7 40 22 00 00    	movw   $0x0,0x22(%eax)
80100a27:	8b 45 f8             	mov    -0x8(%ebp),%eax
80100a2a:	c6 40 24 00          	movb   $0x0,0x24(%eax)
80100a2e:	8b 45 f8             	mov    -0x8(%ebp),%eax
80100a31:	0f b6 50 25          	movzbl 0x25(%eax),%edx
80100a35:	83 e2 f0             	and    $0xfffffff0,%edx
80100a38:	83 ca 0a             	or     $0xa,%edx
80100a3b:	88 50 25             	mov    %dl,0x25(%eax)
80100a3e:	8b 45 f8             	mov    -0x8(%ebp),%eax
80100a41:	0f b6 50 25          	movzbl 0x25(%eax),%edx
80100a45:	83 ca 10             	or     $0x10,%edx
80100a48:	88 50 25             	mov    %dl,0x25(%eax)
80100a4b:	8b 45 f8             	mov    -0x8(%ebp),%eax
80100a4e:	0f b6 50 25          	movzbl 0x25(%eax),%edx
80100a52:	83 ca 60             	or     $0x60,%edx
80100a55:	88 50 25             	mov    %dl,0x25(%eax)
80100a58:	8b 45 f8             	mov    -0x8(%ebp),%eax
80100a5b:	0f b6 50 25          	movzbl 0x25(%eax),%edx
80100a5f:	83 ca 80             	or     $0xffffff80,%edx
80100a62:	88 50 25             	mov    %dl,0x25(%eax)
80100a65:	8b 45 f8             	mov    -0x8(%ebp),%eax
80100a68:	0f b6 50 26          	movzbl 0x26(%eax),%edx
80100a6c:	83 ca 0f             	or     $0xf,%edx
80100a6f:	88 50 26             	mov    %dl,0x26(%eax)
80100a72:	8b 45 f8             	mov    -0x8(%ebp),%eax
80100a75:	0f b6 50 26          	movzbl 0x26(%eax),%edx
80100a79:	83 e2 ef             	and    $0xffffffef,%edx
80100a7c:	88 50 26             	mov    %dl,0x26(%eax)
80100a7f:	8b 45 f8             	mov    -0x8(%ebp),%eax
80100a82:	0f b6 50 26          	movzbl 0x26(%eax),%edx
80100a86:	83 e2 df             	and    $0xffffffdf,%edx
80100a89:	88 50 26             	mov    %dl,0x26(%eax)
80100a8c:	8b 45 f8             	mov    -0x8(%ebp),%eax
80100a8f:	0f b6 50 26          	movzbl 0x26(%eax),%edx
80100a93:	83 ca 40             	or     $0x40,%edx
80100a96:	88 50 26             	mov    %dl,0x26(%eax)
80100a99:	8b 45 f8             	mov    -0x8(%ebp),%eax
80100a9c:	0f b6 50 26          	movzbl 0x26(%eax),%edx
80100aa0:	83 ca 80             	or     $0xffffff80,%edx
80100aa3:	88 50 26             	mov    %dl,0x26(%eax)
80100aa6:	8b 45 f8             	mov    -0x8(%ebp),%eax
80100aa9:	c6 40 27 00          	movb   $0x0,0x27(%eax)
  c->gdt[SEG_UDATA] = SEG(STA_W, 0, 0xffffffff, DPL_USER);
80100aad:	8b 45 f8             	mov    -0x8(%ebp),%eax
80100ab0:	66 c7 40 28 ff ff    	movw   $0xffff,0x28(%eax)
80100ab6:	8b 45 f8             	mov    -0x8(%ebp),%eax
80100ab9:	66 c7 40 2a 00 00    	movw   $0x0,0x2a(%eax)
80100abf:	8b 45 f8             	mov    -0x8(%ebp),%eax
80100ac2:	c6 40 2c 00          	movb   $0x0,0x2c(%eax)
80100ac6:	8b 45 f8             	mov    -0x8(%ebp),%eax
80100ac9:	0f b6 50 2d          	movzbl 0x2d(%eax),%edx
80100acd:	83 e2 f0             	and    $0xfffffff0,%edx
80100ad0:	83 ca 02             	or     $0x2,%edx
80100ad3:	88 50 2d             	mov    %dl,0x2d(%eax)
80100ad6:	8b 45 f8             	mov    -0x8(%ebp),%eax
80100ad9:	0f b6 50 2d          	movzbl 0x2d(%eax),%edx
80100add:	83 ca 10             	or     $0x10,%edx
80100ae0:	88 50 2d             	mov    %dl,0x2d(%eax)
80100ae3:	8b 45 f8             	mov    -0x8(%ebp),%eax
80100ae6:	0f b6 50 2d          	movzbl 0x2d(%eax),%edx
80100aea:	83 ca 60             	or     $0x60,%edx
80100aed:	88 50 2d             	mov    %dl,0x2d(%eax)
80100af0:	8b 45 f8             	mov    -0x8(%ebp),%eax
80100af3:	0f b6 50 2d          	movzbl 0x2d(%eax),%edx
80100af7:	83 ca 80             	or     $0xffffff80,%edx
80100afa:	88 50 2d             	mov    %dl,0x2d(%eax)
80100afd:	8b 45 f8             	mov    -0x8(%ebp),%eax
80100b00:	0f b6 50 2e          	movzbl 0x2e(%eax),%edx
80100b04:	83 ca 0f             	or     $0xf,%edx
80100b07:	88 50 2e             	mov    %dl,0x2e(%eax)
80100b0a:	8b 45 f8             	mov    -0x8(%ebp),%eax
80100b0d:	0f b6 50 2e          	movzbl 0x2e(%eax),%edx
80100b11:	83 e2 ef             	and    $0xffffffef,%edx
80100b14:	88 50 2e             	mov    %dl,0x2e(%eax)
80100b17:	8b 45 f8             	mov    -0x8(%ebp),%eax
80100b1a:	0f b6 50 2e          	movzbl 0x2e(%eax),%edx
80100b1e:	83 e2 df             	and    $0xffffffdf,%edx
80100b21:	88 50 2e             	mov    %dl,0x2e(%eax)
80100b24:	8b 45 f8             	mov    -0x8(%ebp),%eax
80100b27:	0f b6 50 2e          	movzbl 0x2e(%eax),%edx
80100b2b:	83 ca 40             	or     $0x40,%edx
80100b2e:	88 50 2e             	mov    %dl,0x2e(%eax)
80100b31:	8b 45 f8             	mov    -0x8(%ebp),%eax
80100b34:	0f b6 50 2e          	movzbl 0x2e(%eax),%edx
80100b38:	83 ca 80             	or     $0xffffff80,%edx
80100b3b:	88 50 2e             	mov    %dl,0x2e(%eax)
80100b3e:	8b 45 f8             	mov    -0x8(%ebp),%eax
80100b41:	c6 40 2f 00          	movb   $0x0,0x2f(%eax)
  
  c->gdt[SEG_KCPU] = SEG(STA_W, &c->cpu, 8, 0);
80100b45:	8b 45 f8             	mov    -0x8(%ebp),%eax
80100b48:	83 c0 38             	add    $0x38,%eax
80100b4b:	89 c3                	mov    %eax,%ebx
80100b4d:	8b 45 f8             	mov    -0x8(%ebp),%eax
80100b50:	83 c0 38             	add    $0x38,%eax
80100b53:	c1 e8 10             	shr    $0x10,%eax
80100b56:	89 c2                	mov    %eax,%edx
80100b58:	8b 45 f8             	mov    -0x8(%ebp),%eax
80100b5b:	83 c0 38             	add    $0x38,%eax
80100b5e:	c1 e8 18             	shr    $0x18,%eax
80100b61:	89 c1                	mov    %eax,%ecx
80100b63:	8b 45 f8             	mov    -0x8(%ebp),%eax
80100b66:	66 c7 40 18 00 00    	movw   $0x0,0x18(%eax)
80100b6c:	8b 45 f8             	mov    -0x8(%ebp),%eax
80100b6f:	66 89 58 1a          	mov    %bx,0x1a(%eax)
80100b73:	8b 45 f8             	mov    -0x8(%ebp),%eax
80100b76:	88 50 1c             	mov    %dl,0x1c(%eax)
80100b79:	8b 45 f8             	mov    -0x8(%ebp),%eax
80100b7c:	0f b6 50 1d          	movzbl 0x1d(%eax),%edx
80100b80:	83 e2 f0             	and    $0xfffffff0,%edx
80100b83:	83 ca 02             	or     $0x2,%edx
80100b86:	88 50 1d             	mov    %dl,0x1d(%eax)
80100b89:	8b 45 f8             	mov    -0x8(%ebp),%eax
80100b8c:	0f b6 50 1d          	movzbl 0x1d(%eax),%edx
80100b90:	83 ca 10             	or     $0x10,%edx
80100b93:	88 50 1d             	mov    %dl,0x1d(%eax)
80100b96:	8b 45 f8             	mov    -0x8(%ebp),%eax
80100b99:	0f b6 50 1d          	movzbl 0x1d(%eax),%edx
80100b9d:	83 e2 9f             	and    $0xffffff9f,%edx
80100ba0:	88 50 1d             	mov    %dl,0x1d(%eax)
80100ba3:	8b 45 f8             	mov    -0x8(%ebp),%eax
80100ba6:	0f b6 50 1d          	movzbl 0x1d(%eax),%edx
80100baa:	83 ca 80             	or     $0xffffff80,%edx
80100bad:	88 50 1d             	mov    %dl,0x1d(%eax)
80100bb0:	8b 45 f8             	mov    -0x8(%ebp),%eax
80100bb3:	0f b6 50 1e          	movzbl 0x1e(%eax),%edx
80100bb7:	83 e2 f0             	and    $0xfffffff0,%edx
80100bba:	88 50 1e             	mov    %dl,0x1e(%eax)
80100bbd:	8b 45 f8             	mov    -0x8(%ebp),%eax
80100bc0:	0f b6 50 1e          	movzbl 0x1e(%eax),%edx
80100bc4:	83 e2 ef             	and    $0xffffffef,%edx
80100bc7:	88 50 1e             	mov    %dl,0x1e(%eax)
80100bca:	8b 45 f8             	mov    -0x8(%ebp),%eax
80100bcd:	0f b6 50 1e          	movzbl 0x1e(%eax),%edx
80100bd1:	83 e2 df             	and    $0xffffffdf,%edx
80100bd4:	88 50 1e             	mov    %dl,0x1e(%eax)
80100bd7:	8b 45 f8             	mov    -0x8(%ebp),%eax
80100bda:	0f b6 50 1e          	movzbl 0x1e(%eax),%edx
80100bde:	83 ca 40             	or     $0x40,%edx
80100be1:	88 50 1e             	mov    %dl,0x1e(%eax)
80100be4:	8b 45 f8             	mov    -0x8(%ebp),%eax
80100be7:	0f b6 50 1e          	movzbl 0x1e(%eax),%edx
80100beb:	83 ca 80             	or     $0xffffff80,%edx
80100bee:	88 50 1e             	mov    %dl,0x1e(%eax)
80100bf1:	8b 45 f8             	mov    -0x8(%ebp),%eax
80100bf4:	88 48 1f             	mov    %cl,0x1f(%eax)
  
  lgdt(c->gdt, sizeof(c->gdt));
80100bf7:	8b 45 f8             	mov    -0x8(%ebp),%eax
80100bfa:	6a 38                	push   $0x38
80100bfc:	50                   	push   %eax
80100bfd:	e8 72 fc ff ff       	call   80100874 <lgdt>
80100c02:	83 c4 08             	add    $0x8,%esp
  loadgs(SEG_KCPU << 3);
80100c05:	6a 18                	push   $0x18
80100c07:	e8 91 fc ff ff       	call   8010089d <loadgs>
80100c0c:	83 c4 04             	add    $0x4,%esp
  
  cpu = c;
80100c0f:	8b 45 f8             	mov    -0x8(%ebp),%eax
80100c12:	65 a3 00 00 00 00    	mov    %eax,%gs:0x0
}
80100c18:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80100c1b:	c9                   	leave  
80100c1c:	c3                   	ret    

80100c1d <segshow>:


void segshow(){
80100c1d:	55                   	push   %ebp
80100c1e:	89 e5                	mov    %esp,%ebp
80100c20:	83 ec 08             	sub    $0x8,%esp

  cprintf("Kernel code segment's address bit 31~24 : %d\n",cpu->gdt[SEG_KCODE].base_31_24);
80100c23:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80100c29:	0f b6 40 0f          	movzbl 0xf(%eax),%eax
80100c2d:	0f b6 c0             	movzbl %al,%eax
80100c30:	83 ec 08             	sub    $0x8,%esp
80100c33:	50                   	push   %eax
80100c34:	68 0c 1f 10 80       	push   $0x80101f0c
80100c39:	e8 4b f5 ff ff       	call   80100189 <cprintf>
80100c3e:	83 c4 10             	add    $0x10,%esp
  cprintf("Kernel code segment's address bit 23~16 : %d\n",cpu->gdt[SEG_KCODE].base_23_16);
80100c41:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80100c47:	0f b6 40 0c          	movzbl 0xc(%eax),%eax
80100c4b:	0f b6 c0             	movzbl %al,%eax
80100c4e:	83 ec 08             	sub    $0x8,%esp
80100c51:	50                   	push   %eax
80100c52:	68 3c 1f 10 80       	push   $0x80101f3c
80100c57:	e8 2d f5 ff ff       	call   80100189 <cprintf>
80100c5c:	83 c4 10             	add    $0x10,%esp
  cprintf("Kernel code segment's address bit 15~0 : %d\n",cpu->gdt[SEG_KCODE].base_15_0);
80100c5f:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80100c65:	0f b7 40 0a          	movzwl 0xa(%eax),%eax
80100c69:	0f b7 c0             	movzwl %ax,%eax
80100c6c:	83 ec 08             	sub    $0x8,%esp
80100c6f:	50                   	push   %eax
80100c70:	68 6c 1f 10 80       	push   $0x80101f6c
80100c75:	e8 0f f5 ff ff       	call   80100189 <cprintf>
80100c7a:	83 c4 10             	add    $0x10,%esp
                                                                                          
  cprintf("Kernel data segment's address bit 31~24 : %d\n",cpu->gdt[SEG_KDATA].base_31_24);
80100c7d:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80100c83:	0f b6 40 17          	movzbl 0x17(%eax),%eax
80100c87:	0f b6 c0             	movzbl %al,%eax
80100c8a:	83 ec 08             	sub    $0x8,%esp
80100c8d:	50                   	push   %eax
80100c8e:	68 9c 1f 10 80       	push   $0x80101f9c
80100c93:	e8 f1 f4 ff ff       	call   80100189 <cprintf>
80100c98:	83 c4 10             	add    $0x10,%esp
  cprintf("Kernel data segment's address bit 23~16 : %d\n",cpu->gdt[SEG_KDATA].base_23_16);
80100c9b:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80100ca1:	0f b6 40 14          	movzbl 0x14(%eax),%eax
80100ca5:	0f b6 c0             	movzbl %al,%eax
80100ca8:	83 ec 08             	sub    $0x8,%esp
80100cab:	50                   	push   %eax
80100cac:	68 cc 1f 10 80       	push   $0x80101fcc
80100cb1:	e8 d3 f4 ff ff       	call   80100189 <cprintf>
80100cb6:	83 c4 10             	add    $0x10,%esp
  cprintf("Kernel data segment's address bit 15~0 : %d\n",cpu->gdt[SEG_KDATA].base_15_0);
80100cb9:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80100cbf:	0f b7 40 12          	movzwl 0x12(%eax),%eax
80100cc3:	0f b7 c0             	movzwl %ax,%eax
80100cc6:	83 ec 08             	sub    $0x8,%esp
80100cc9:	50                   	push   %eax
80100cca:	68 fc 1f 10 80       	push   $0x80101ffc
80100ccf:	e8 b5 f4 ff ff       	call   80100189 <cprintf>
80100cd4:	83 c4 10             	add    $0x10,%esp

  cprintf("User code segment's address bit 31~24 : %d\n",cpu->gdt[SEG_UCODE].base_31_24);
80100cd7:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80100cdd:	0f b6 40 27          	movzbl 0x27(%eax),%eax
80100ce1:	0f b6 c0             	movzbl %al,%eax
80100ce4:	83 ec 08             	sub    $0x8,%esp
80100ce7:	50                   	push   %eax
80100ce8:	68 2c 20 10 80       	push   $0x8010202c
80100ced:	e8 97 f4 ff ff       	call   80100189 <cprintf>
80100cf2:	83 c4 10             	add    $0x10,%esp
  cprintf("User code segment's address bit 23~16 : %d\n",cpu->gdt[SEG_UCODE].base_15_0);
80100cf5:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80100cfb:	0f b7 40 22          	movzwl 0x22(%eax),%eax
80100cff:	0f b7 c0             	movzwl %ax,%eax
80100d02:	83 ec 08             	sub    $0x8,%esp
80100d05:	50                   	push   %eax
80100d06:	68 58 20 10 80       	push   $0x80102058
80100d0b:	e8 79 f4 ff ff       	call   80100189 <cprintf>
80100d10:	83 c4 10             	add    $0x10,%esp
  cprintf("User code segment's address bit 15~0 : %d\n",cpu->gdt[SEG_UCODE].base_15_0);
80100d13:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80100d19:	0f b7 40 22          	movzwl 0x22(%eax),%eax
80100d1d:	0f b7 c0             	movzwl %ax,%eax
80100d20:	83 ec 08             	sub    $0x8,%esp
80100d23:	50                   	push   %eax
80100d24:	68 84 20 10 80       	push   $0x80102084
80100d29:	e8 5b f4 ff ff       	call   80100189 <cprintf>
80100d2e:	83 c4 10             	add    $0x10,%esp
  
  cprintf("User code segment's address bit 31~24 : %d\n",cpu->gdt[SEG_UDATA].base_31_24);
80100d31:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80100d37:	0f b6 40 2f          	movzbl 0x2f(%eax),%eax
80100d3b:	0f b6 c0             	movzbl %al,%eax
80100d3e:	83 ec 08             	sub    $0x8,%esp
80100d41:	50                   	push   %eax
80100d42:	68 2c 20 10 80       	push   $0x8010202c
80100d47:	e8 3d f4 ff ff       	call   80100189 <cprintf>
80100d4c:	83 c4 10             	add    $0x10,%esp
  cprintf("User code segment's address bit 23~16 : %d\n",cpu->gdt[SEG_UDATA].base_23_16);
80100d4f:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80100d55:	0f b6 40 2c          	movzbl 0x2c(%eax),%eax
80100d59:	0f b6 c0             	movzbl %al,%eax
80100d5c:	83 ec 08             	sub    $0x8,%esp
80100d5f:	50                   	push   %eax
80100d60:	68 58 20 10 80       	push   $0x80102058
80100d65:	e8 1f f4 ff ff       	call   80100189 <cprintf>
80100d6a:	83 c4 10             	add    $0x10,%esp
  cprintf("User code segment's address bit 15~0 : %d\n",cpu->gdt[SEG_UDATA].base_15_0);
80100d6d:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80100d73:	0f b7 40 2a          	movzwl 0x2a(%eax),%eax
80100d77:	0f b7 c0             	movzwl %ax,%eax
80100d7a:	83 ec 08             	sub    $0x8,%esp
80100d7d:	50                   	push   %eax
80100d7e:	68 84 20 10 80       	push   $0x80102084
80100d83:	e8 01 f4 ff ff       	call   80100189 <cprintf>
80100d88:	83 c4 10             	add    $0x10,%esp

}
80100d8b:	c9                   	leave  
80100d8c:	c3                   	ret    

80100d8d <walkpgdir>:



//返回页表pgdir中对应线性地址va的PTE(页项)的地址，如果creat!=0,那么创建请求的页项
static pte_t * walkpgdir(pde_t *pgdir, const void *va, int alloc)
{
80100d8d:	55                   	push   %ebp
80100d8e:	89 e5                	mov    %esp,%ebp
80100d90:	83 ec 18             	sub    $0x18,%esp
  pde_t *pde;
  pte_t *pgtab;

  pde = &pgdir[PDX(va)];    //根据线性地址查找其对应的页表地址
80100d93:	8b 45 0c             	mov    0xc(%ebp),%eax
80100d96:	c1 e8 16             	shr    $0x16,%eax
80100d99:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80100da0:	8b 45 08             	mov    0x8(%ebp),%eax
80100da3:	01 d0                	add    %edx,%eax
80100da5:	89 45 f0             	mov    %eax,-0x10(%ebp)
 
  if(*pde & PTE_P){
80100da8:	8b 45 f0             	mov    -0x10(%ebp),%eax
80100dab:	8b 00                	mov    (%eax),%eax
80100dad:	83 e0 01             	and    $0x1,%eax
80100db0:	85 c0                	test   %eax,%eax
80100db2:	74 18                	je     80100dcc <walkpgdir+0x3f>
    pgtab = (pte_t*)p2v(PTE_ADDR(*pde));
80100db4:	8b 45 f0             	mov    -0x10(%ebp),%eax
80100db7:	8b 00                	mov    (%eax),%eax
80100db9:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80100dbe:	50                   	push   %eax
80100dbf:	e8 06 fb ff ff       	call   801008ca <p2v>
80100dc4:	83 c4 04             	add    $0x4,%esp
80100dc7:	89 45 f4             	mov    %eax,-0xc(%ebp)
80100dca:	eb 48                	jmp    80100e14 <walkpgdir+0x87>
  } else {
    
    if(!alloc || (pgtab = (pte_t*)kalloc()) == 0)
80100dcc:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80100dd0:	74 0e                	je     80100de0 <walkpgdir+0x53>
80100dd2:	e8 f6 f8 ff ff       	call   801006cd <kalloc>
80100dd7:	89 45 f4             	mov    %eax,-0xc(%ebp)
80100dda:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80100dde:	75 07                	jne    80100de7 <walkpgdir+0x5a>
      return 0;
80100de0:	b8 00 00 00 00       	mov    $0x0,%eax
80100de5:	eb 44                	jmp    80100e2b <walkpgdir+0x9e>
    
    memset(pgtab, 0, PGSIZE);
80100de7:	83 ec 04             	sub    $0x4,%esp
80100dea:	68 00 10 00 00       	push   $0x1000
80100def:	6a 00                	push   $0x0
80100df1:	ff 75 f4             	pushl  -0xc(%ebp)
80100df4:	e8 e2 f7 ff ff       	call   801005db <memset>
80100df9:	83 c4 10             	add    $0x10,%esp
    
    *pde = v2p(pgtab) | PTE_P | PTE_W | PTE_U;
80100dfc:	83 ec 0c             	sub    $0xc,%esp
80100dff:	ff 75 f4             	pushl  -0xc(%ebp)
80100e02:	e8 b6 fa ff ff       	call   801008bd <v2p>
80100e07:	83 c4 10             	add    $0x10,%esp
80100e0a:	83 c8 07             	or     $0x7,%eax
80100e0d:	89 c2                	mov    %eax,%edx
80100e0f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80100e12:	89 10                	mov    %edx,(%eax)
  }
  return &pgtab[PTX(va)];   //返回页地址
80100e14:	8b 45 0c             	mov    0xc(%ebp),%eax
80100e17:	c1 e8 0c             	shr    $0xc,%eax
80100e1a:	25 ff 03 00 00       	and    $0x3ff,%eax
80100e1f:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80100e26:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100e29:	01 d0                	add    %edx,%eax
}
80100e2b:	c9                   	leave  
80100e2c:	c3                   	ret    

80100e2d <mappages>:

//为以va开始的线性地址创建页项，va引用pa开始处的物理地址，va和size可能没有按页对其
static int mappages(pde_t *pgdir, void *va, uint size, uint pa, int perm)
{
80100e2d:	55                   	push   %ebp
80100e2e:	89 e5                	mov    %esp,%ebp
80100e30:	83 ec 18             	sub    $0x18,%esp
  char *a, *last;
  pte_t *pte;
  
  a = (char*)PGROUNDDOWN((uint)va);                        //va所在的第一页地址
80100e33:	8b 45 0c             	mov    0xc(%ebp),%eax
80100e36:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80100e3b:	89 45 f4             	mov    %eax,-0xc(%ebp)
  last = (char*)PGROUNDDOWN(((uint)va) + size - 1);        //va所在的最后一页地址
80100e3e:	8b 55 0c             	mov    0xc(%ebp),%edx
80100e41:	8b 45 10             	mov    0x10(%ebp),%eax
80100e44:	01 d0                	add    %edx,%eax
80100e46:	83 e8 01             	sub    $0x1,%eax
80100e49:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80100e4e:	89 45 f0             	mov    %eax,-0x10(%ebp)
  
  for(;;){
    if((pte = walkpgdir(pgdir, a, 1)) == 0)      //创建页
80100e51:	83 ec 04             	sub    $0x4,%esp
80100e54:	6a 01                	push   $0x1
80100e56:	ff 75 f4             	pushl  -0xc(%ebp)
80100e59:	ff 75 08             	pushl  0x8(%ebp)
80100e5c:	e8 2c ff ff ff       	call   80100d8d <walkpgdir>
80100e61:	83 c4 10             	add    $0x10,%esp
80100e64:	89 45 ec             	mov    %eax,-0x14(%ebp)
80100e67:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80100e6b:	75 07                	jne    80100e74 <mappages+0x47>
      return -1;
80100e6d:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80100e72:	eb 30                	jmp    80100ea4 <mappages+0x77>
   
    *pte = pa | perm | PTE_P;
80100e74:	8b 45 18             	mov    0x18(%ebp),%eax
80100e77:	0b 45 14             	or     0x14(%ebp),%eax
80100e7a:	83 c8 01             	or     $0x1,%eax
80100e7d:	89 c2                	mov    %eax,%edx
80100e7f:	8b 45 ec             	mov    -0x14(%ebp),%eax
80100e82:	89 10                	mov    %edx,(%eax)
   
    if(a == last)
80100e84:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100e87:	3b 45 f0             	cmp    -0x10(%ebp),%eax
80100e8a:	75 08                	jne    80100e94 <mappages+0x67>
      break;
80100e8c:	90                   	nop
   
    a += PGSIZE;
    pa += PGSIZE;
  }
  return 0;
80100e8d:	b8 00 00 00 00       	mov    $0x0,%eax
80100e92:	eb 10                	jmp    80100ea4 <mappages+0x77>
    *pte = pa | perm | PTE_P;
   
    if(a == last)
      break;
   
    a += PGSIZE;
80100e94:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
    pa += PGSIZE;
80100e9b:	81 45 14 00 10 00 00 	addl   $0x1000,0x14(%ebp)
  }
80100ea2:	eb ad                	jmp    80100e51 <mappages+0x24>
  return 0;
}
80100ea4:	c9                   	leave  
80100ea5:	c3                   	ret    

80100ea6 <setupkvm>:
};


//设置页表的内核部分,返回此页表
pde_t* setupkvm(void)
{
80100ea6:	55                   	push   %ebp
80100ea7:	89 e5                	mov    %esp,%ebp
80100ea9:	53                   	push   %ebx
80100eaa:	83 ec 14             	sub    $0x14,%esp
  pde_t *pgdir;
  struct kmap *k;

  if((pgdir = (pde_t*)kalloc()) == 0)
80100ead:	e8 1b f8 ff ff       	call   801006cd <kalloc>
80100eb2:	89 45 f0             	mov    %eax,-0x10(%ebp)
80100eb5:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80100eb9:	75 07                	jne    80100ec2 <setupkvm+0x1c>
    return 0;
80100ebb:	b8 00 00 00 00       	mov    $0x0,%eax
80100ec0:	eb 6a                	jmp    80100f2c <setupkvm+0x86>
 
  memset(pgdir, 0, PGSIZE);
80100ec2:	83 ec 04             	sub    $0x4,%esp
80100ec5:	68 00 10 00 00       	push   $0x1000
80100eca:	6a 00                	push   $0x0
80100ecc:	ff 75 f0             	pushl  -0x10(%ebp)
80100ecf:	e8 07 f7 ff ff       	call   801005db <memset>
80100ed4:	83 c4 10             	add    $0x10,%esp
 
  //分配每一页 
  for(k = kmap; k < &kmap[NELEM(kmap)]; k++)
80100ed7:	c7 45 f4 80 45 10 80 	movl   $0x80104580,-0xc(%ebp)
80100ede:	eb 40                	jmp    80100f20 <setupkvm+0x7a>
    if(mappages(pgdir, k->virt, k->phys_end - k->phys_start, 
80100ee0:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100ee3:	8b 48 0c             	mov    0xc(%eax),%ecx
80100ee6:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100ee9:	8b 50 04             	mov    0x4(%eax),%edx
80100eec:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100eef:	8b 58 08             	mov    0x8(%eax),%ebx
80100ef2:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100ef5:	8b 40 04             	mov    0x4(%eax),%eax
80100ef8:	29 c3                	sub    %eax,%ebx
80100efa:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100efd:	8b 00                	mov    (%eax),%eax
80100eff:	83 ec 0c             	sub    $0xc,%esp
80100f02:	51                   	push   %ecx
80100f03:	52                   	push   %edx
80100f04:	53                   	push   %ebx
80100f05:	50                   	push   %eax
80100f06:	ff 75 f0             	pushl  -0x10(%ebp)
80100f09:	e8 1f ff ff ff       	call   80100e2d <mappages>
80100f0e:	83 c4 20             	add    $0x20,%esp
80100f11:	85 c0                	test   %eax,%eax
80100f13:	79 07                	jns    80100f1c <setupkvm+0x76>
		(uint)k->phys_start, k->perm) < 0)
      return 0;
80100f15:	b8 00 00 00 00       	mov    $0x0,%eax
80100f1a:	eb 10                	jmp    80100f2c <setupkvm+0x86>
    return 0;
 
  memset(pgdir, 0, PGSIZE);
 
  //分配每一页 
  for(k = kmap; k < &kmap[NELEM(kmap)]; k++)
80100f1c:	83 45 f4 10          	addl   $0x10,-0xc(%ebp)
80100f20:	81 7d f4 c0 45 10 80 	cmpl   $0x801045c0,-0xc(%ebp)
80100f27:	72 b7                	jb     80100ee0 <setupkvm+0x3a>
    if(mappages(pgdir, k->virt, k->phys_end - k->phys_start, 
		(uint)k->phys_start, k->perm) < 0)
      return 0;

  return pgdir;
80100f29:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
80100f2c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80100f2f:	c9                   	leave  
80100f30:	c3                   	ret    

80100f31 <switchkvm>:


// 切换到页表kpgdir
void switchkvm(void)
{
80100f31:	55                   	push   %ebp
80100f32:	89 e5                	mov    %esp,%ebp
  lcr3(v2p(kpgdir));   // 切换到内核页表
80100f34:	a1 e0 5f 10 80       	mov    0x80105fe0,%eax
80100f39:	50                   	push   %eax
80100f3a:	e8 7e f9 ff ff       	call   801008bd <v2p>
80100f3f:	83 c4 04             	add    $0x4,%esp
80100f42:	50                   	push   %eax
80100f43:	e8 6a f9 ff ff       	call   801008b2 <lcr3>
80100f48:	83 c4 04             	add    $0x4,%esp
}
80100f4b:	c9                   	leave  
80100f4c:	c3                   	ret    

80100f4d <kvmalloc>:

void kvmalloc(void)
{
80100f4d:	55                   	push   %ebp
80100f4e:	89 e5                	mov    %esp,%ebp
80100f50:	83 ec 08             	sub    $0x8,%esp
  kpgdir = setupkvm();  // 设置好页表
80100f53:	e8 4e ff ff ff       	call   80100ea6 <setupkvm>
80100f58:	a3 e0 5f 10 80       	mov    %eax,0x80105fe0
  switchkvm();  	// 切换到内核页表
80100f5d:	e8 cf ff ff ff       	call   80100f31 <switchkvm>
}
80100f62:	c9                   	leave  
80100f63:	c3                   	ret    

80100f64 <outb>:
               "memory", "cc");
}

static inline void
outb(ushort port, uchar data)
{
80100f64:	55                   	push   %ebp
80100f65:	89 e5                	mov    %esp,%ebp
80100f67:	83 ec 08             	sub    $0x8,%esp
80100f6a:	8b 55 08             	mov    0x8(%ebp),%edx
80100f6d:	8b 45 0c             	mov    0xc(%ebp),%eax
80100f70:	66 89 55 fc          	mov    %dx,-0x4(%ebp)
80100f74:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80100f77:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
80100f7b:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
80100f7f:	ee                   	out    %al,(%dx)
}
80100f80:	c9                   	leave  
80100f81:	c3                   	ret    

80100f82 <picsetmask>:

static ushort irqmask = 0xFFFF & ~(1<<IRQ_SLAVE);

static void
picsetmask(ushort mask)
{
80100f82:	55                   	push   %ebp
80100f83:	89 e5                	mov    %esp,%ebp
80100f85:	83 ec 04             	sub    $0x4,%esp
80100f88:	8b 45 08             	mov    0x8(%ebp),%eax
80100f8b:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  irqmask = mask;
80100f8f:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
80100f93:	66 a3 c0 45 10 80    	mov    %ax,0x801045c0
  outb(IO_PIC1+1, mask);
80100f99:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
80100f9d:	0f b6 c0             	movzbl %al,%eax
80100fa0:	50                   	push   %eax
80100fa1:	6a 21                	push   $0x21
80100fa3:	e8 bc ff ff ff       	call   80100f64 <outb>
80100fa8:	83 c4 08             	add    $0x8,%esp
  outb(IO_PIC2+1, mask >> 8);
80100fab:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
80100faf:	66 c1 e8 08          	shr    $0x8,%ax
80100fb3:	0f b6 c0             	movzbl %al,%eax
80100fb6:	50                   	push   %eax
80100fb7:	68 a1 00 00 00       	push   $0xa1
80100fbc:	e8 a3 ff ff ff       	call   80100f64 <outb>
80100fc1:	83 c4 08             	add    $0x8,%esp
}
80100fc4:	c9                   	leave  
80100fc5:	c3                   	ret    

80100fc6 <picenable>:

void
picenable(int irq)
{
80100fc6:	55                   	push   %ebp
80100fc7:	89 e5                	mov    %esp,%ebp
  picsetmask(irqmask & ~(1<<irq));
80100fc9:	8b 45 08             	mov    0x8(%ebp),%eax
80100fcc:	ba 01 00 00 00       	mov    $0x1,%edx
80100fd1:	89 c1                	mov    %eax,%ecx
80100fd3:	d3 e2                	shl    %cl,%edx
80100fd5:	89 d0                	mov    %edx,%eax
80100fd7:	f7 d0                	not    %eax
80100fd9:	89 c2                	mov    %eax,%edx
80100fdb:	0f b7 05 c0 45 10 80 	movzwl 0x801045c0,%eax
80100fe2:	21 d0                	and    %edx,%eax
80100fe4:	0f b7 c0             	movzwl %ax,%eax
80100fe7:	50                   	push   %eax
80100fe8:	e8 95 ff ff ff       	call   80100f82 <picsetmask>
80100fed:	83 c4 04             	add    $0x4,%esp
}
80100ff0:	c9                   	leave  
80100ff1:	c3                   	ret    

80100ff2 <picinit>:

//初始化8259A的中断控制器
void
picinit(void)
{
80100ff2:	55                   	push   %ebp
80100ff3:	89 e5                	mov    %esp,%ebp
  // 屏蔽掉所有的中断
  outb(IO_PIC1+1, 0xFF);
80100ff5:	68 ff 00 00 00       	push   $0xff
80100ffa:	6a 21                	push   $0x21
80100ffc:	e8 63 ff ff ff       	call   80100f64 <outb>
80101001:	83 c4 08             	add    $0x8,%esp
  outb(IO_PIC2+1, 0xFF);
80101004:	68 ff 00 00 00       	push   $0xff
80101009:	68 a1 00 00 00       	push   $0xa1
8010100e:	e8 51 ff ff ff       	call   80100f64 <outb>
80101013:	83 c4 08             	add    $0x8,%esp

  // 设置主控制器

  outb(IO_PIC1, 0x11);    	  	// ICW1
80101016:	6a 11                	push   $0x11
80101018:	6a 20                	push   $0x20
8010101a:	e8 45 ff ff ff       	call   80100f64 <outb>
8010101f:	83 c4 08             	add    $0x8,%esp
  outb(IO_PIC1+1, T_IRQ0); 		// ICW2, 设置所有中断向量偏移地址
80101022:	6a 20                	push   $0x20
80101024:	6a 21                	push   $0x21
80101026:	e8 39 ff ff ff       	call   80100f64 <outb>
8010102b:	83 c4 08             	add    $0x8,%esp
  outb(IO_PIC1+1, 1<<IRQ_SLAVE); 	// ICW3
8010102e:	6a 04                	push   $0x4
80101030:	6a 21                	push   $0x21
80101032:	e8 2d ff ff ff       	call   80100f64 <outb>
80101037:	83 c4 08             	add    $0x8,%esp
  outb(IO_PIC1+1, 0x3); 		// ICW4
8010103a:	6a 03                	push   $0x3
8010103c:	6a 21                	push   $0x21
8010103e:	e8 21 ff ff ff       	call   80100f64 <outb>
80101043:	83 c4 08             	add    $0x8,%esp

  // 设置从控制器
  
  outb(IO_PIC2, 0x11);                  // ICW1
80101046:	6a 11                	push   $0x11
80101048:	68 a0 00 00 00       	push   $0xa0
8010104d:	e8 12 ff ff ff       	call   80100f64 <outb>
80101052:	83 c4 08             	add    $0x8,%esp
  outb(IO_PIC2+1, T_IRQ0 + 8);          // ICW2
80101055:	6a 28                	push   $0x28
80101057:	68 a1 00 00 00       	push   $0xa1
8010105c:	e8 03 ff ff ff       	call   80100f64 <outb>
80101061:	83 c4 08             	add    $0x8,%esp
  outb(IO_PIC2+1, IRQ_SLAVE);           // ICW3
80101064:	6a 02                	push   $0x2
80101066:	68 a1 00 00 00       	push   $0xa1
8010106b:	e8 f4 fe ff ff       	call   80100f64 <outb>
80101070:	83 c4 08             	add    $0x8,%esp
  outb(IO_PIC2+1, 0x3);                 // ICW4
80101073:	6a 03                	push   $0x3
80101075:	68 a1 00 00 00       	push   $0xa1
8010107a:	e8 e5 fe ff ff       	call   80100f64 <outb>
8010107f:	83 c4 08             	add    $0x8,%esp
  
  //设置OCW3  
  outb(IO_PIC1, 0x68);            
80101082:	6a 68                	push   $0x68
80101084:	6a 20                	push   $0x20
80101086:	e8 d9 fe ff ff       	call   80100f64 <outb>
8010108b:	83 c4 08             	add    $0x8,%esp
  outb(IO_PIC1, 0x0a);            
8010108e:	6a 0a                	push   $0xa
80101090:	6a 20                	push   $0x20
80101092:	e8 cd fe ff ff       	call   80100f64 <outb>
80101097:	83 c4 08             	add    $0x8,%esp

  outb(IO_PIC2, 0x68);             // OCW3
8010109a:	6a 68                	push   $0x68
8010109c:	68 a0 00 00 00       	push   $0xa0
801010a1:	e8 be fe ff ff       	call   80100f64 <outb>
801010a6:	83 c4 08             	add    $0x8,%esp
  outb(IO_PIC2, 0x0a);             // OCW3
801010a9:	6a 0a                	push   $0xa
801010ab:	68 a0 00 00 00       	push   $0xa0
801010b0:	e8 af fe ff ff       	call   80100f64 <outb>
801010b5:	83 c4 08             	add    $0x8,%esp

  if(irqmask != 0xFFFF)
801010b8:	0f b7 05 c0 45 10 80 	movzwl 0x801045c0,%eax
801010bf:	66 83 f8 ff          	cmp    $0xffff,%ax
801010c3:	74 13                	je     801010d8 <picinit+0xe6>
    picsetmask(irqmask);
801010c5:	0f b7 05 c0 45 10 80 	movzwl 0x801045c0,%eax
801010cc:	0f b7 c0             	movzwl %ax,%eax
801010cf:	50                   	push   %eax
801010d0:	e8 ad fe ff ff       	call   80100f82 <picsetmask>
801010d5:	83 c4 04             	add    $0x4,%esp
}
801010d8:	c9                   	leave  
801010d9:	c3                   	ret    

801010da <ioapicwrite>:
  uint data;
};

//写入reg，并写入数据
static void ioapicwrite(int reg, uint data)
{
801010da:	55                   	push   %ebp
801010db:	89 e5                	mov    %esp,%ebp
  ioapic->reg = reg;
801010dd:	a1 3c 60 10 80       	mov    0x8010603c,%eax
801010e2:	8b 55 08             	mov    0x8(%ebp),%edx
801010e5:	89 10                	mov    %edx,(%eax)
  ioapic->data = data;
801010e7:	a1 3c 60 10 80       	mov    0x8010603c,%eax
801010ec:	8b 55 0c             	mov    0xc(%ebp),%edx
801010ef:	89 50 10             	mov    %edx,0x10(%eax)
}
801010f2:	5d                   	pop    %ebp
801010f3:	c3                   	ret    

801010f4 <ioapicread>:

//写入reg，并读取数据
static uint ioapicread(int reg)
{
801010f4:	55                   	push   %ebp
801010f5:	89 e5                	mov    %esp,%ebp
  ioapic->reg = reg;
801010f7:	a1 3c 60 10 80       	mov    0x8010603c,%eax
801010fc:	8b 55 08             	mov    0x8(%ebp),%edx
801010ff:	89 10                	mov    %edx,(%eax)
  return ioapic->data;
80101101:	a1 3c 60 10 80       	mov    0x8010603c,%eax
80101106:	8b 40 10             	mov    0x10(%eax),%eax
}
80101109:	5d                   	pop    %ebp
8010110a:	c3                   	ret    

8010110b <ioapicinit>:

//IOAPIC的初始化
void ioapicinit(void)
{
8010110b:	55                   	push   %ebp
8010110c:	89 e5                	mov    %esp,%ebp
8010110e:	83 ec 10             	sub    $0x10,%esp
  int i, maxintr;

  ioapic = (volatile struct ioapic*)IOAPIC;    //IOAPIC的默认的初始地址
80101111:	c7 05 3c 60 10 80 00 	movl   $0xfec00000,0x8010603c
80101118:	00 c0 fe 
  maxintr = (ioapicread(REG_VER) >> 16) & 0xFF;
8010111b:	6a 01                	push   $0x1
8010111d:	e8 d2 ff ff ff       	call   801010f4 <ioapicread>
80101122:	83 c4 04             	add    $0x4,%esp
80101125:	c1 e8 10             	shr    $0x10,%eax
80101128:	25 ff 00 00 00       	and    $0xff,%eax
8010112d:	89 45 f8             	mov    %eax,-0x8(%ebp)

  //标记所有的中断为边缘触发，激活高寄存器，关闭中断，不传送给CPU
  for(i = 0; i <= maxintr; i++){
80101130:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
80101137:	eb 39                	jmp    80101172 <ioapicinit+0x67>
    ioapicwrite(REG_TABLE+2*i, INT_DISABLED | (T_IRQ0 + i));
80101139:	8b 45 fc             	mov    -0x4(%ebp),%eax
8010113c:	83 c0 20             	add    $0x20,%eax
8010113f:	0d 00 00 01 00       	or     $0x10000,%eax
80101144:	89 c2                	mov    %eax,%edx
80101146:	8b 45 fc             	mov    -0x4(%ebp),%eax
80101149:	83 c0 08             	add    $0x8,%eax
8010114c:	01 c0                	add    %eax,%eax
8010114e:	52                   	push   %edx
8010114f:	50                   	push   %eax
80101150:	e8 85 ff ff ff       	call   801010da <ioapicwrite>
80101155:	83 c4 08             	add    $0x8,%esp
    ioapicwrite(REG_TABLE+2*i+1, 0);
80101158:	8b 45 fc             	mov    -0x4(%ebp),%eax
8010115b:	83 c0 08             	add    $0x8,%eax
8010115e:	01 c0                	add    %eax,%eax
80101160:	83 c0 01             	add    $0x1,%eax
80101163:	6a 00                	push   $0x0
80101165:	50                   	push   %eax
80101166:	e8 6f ff ff ff       	call   801010da <ioapicwrite>
8010116b:	83 c4 08             	add    $0x8,%esp

  ioapic = (volatile struct ioapic*)IOAPIC;    //IOAPIC的默认的初始地址
  maxintr = (ioapicread(REG_VER) >> 16) & 0xFF;

  //标记所有的中断为边缘触发，激活高寄存器，关闭中断，不传送给CPU
  for(i = 0; i <= maxintr; i++){
8010116e:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
80101172:	8b 45 fc             	mov    -0x4(%ebp),%eax
80101175:	3b 45 f8             	cmp    -0x8(%ebp),%eax
80101178:	7e bf                	jle    80101139 <ioapicinit+0x2e>
    ioapicwrite(REG_TABLE+2*i, INT_DISABLED | (T_IRQ0 + i));
    ioapicwrite(REG_TABLE+2*i+1, 0);
  }
}
8010117a:	c9                   	leave  
8010117b:	c3                   	ret    

8010117c <ioapicenable>:

void ioapicenable(int irq, int cpunum)
{
8010117c:	55                   	push   %ebp
8010117d:	89 e5                	mov    %esp,%ebp
  if(!ismp)
8010117f:	a1 40 60 10 80       	mov    0x80106040,%eax
80101184:	85 c0                	test   %eax,%eax
80101186:	75 02                	jne    8010118a <ioapicenable+0xe>
      return;
80101188:	eb 37                	jmp    801011c1 <ioapicenable+0x45>

  //标记所有的中断为边缘触发，激活高寄存器，打开中断，传送给CPU
  ioapicwrite(REG_TABLE+2*irq, T_IRQ0 + irq);
8010118a:	8b 45 08             	mov    0x8(%ebp),%eax
8010118d:	83 c0 20             	add    $0x20,%eax
80101190:	89 c2                	mov    %eax,%edx
80101192:	8b 45 08             	mov    0x8(%ebp),%eax
80101195:	83 c0 08             	add    $0x8,%eax
80101198:	01 c0                	add    %eax,%eax
8010119a:	52                   	push   %edx
8010119b:	50                   	push   %eax
8010119c:	e8 39 ff ff ff       	call   801010da <ioapicwrite>
801011a1:	83 c4 08             	add    $0x8,%esp
  ioapicwrite(REG_TABLE+2*irq+1, cpunum << 24);
801011a4:	8b 45 0c             	mov    0xc(%ebp),%eax
801011a7:	c1 e0 18             	shl    $0x18,%eax
801011aa:	89 c2                	mov    %eax,%edx
801011ac:	8b 45 08             	mov    0x8(%ebp),%eax
801011af:	83 c0 08             	add    $0x8,%eax
801011b2:	01 c0                	add    %eax,%eax
801011b4:	83 c0 01             	add    $0x1,%eax
801011b7:	52                   	push   %edx
801011b8:	50                   	push   %eax
801011b9:	e8 1c ff ff ff       	call   801010da <ioapicwrite>
801011be:	83 c4 08             	add    $0x8,%esp
}
801011c1:	c9                   	leave  
801011c2:	c3                   	ret    

801011c3 <vector0>:
# generated by vectors.pl - do not edit
# handlers
.globl alltraps
.globl vector0
vector0:
  pushl $0
801011c3:	6a 00                	push   $0x0
  pushl $0
801011c5:	6a 00                	push   $0x0
  jmp alltraps
801011c7:	e9 80 0c 00 00       	jmp    80101e4c <alltraps>

801011cc <vector1>:
.globl vector1
vector1:
  pushl $0
801011cc:	6a 00                	push   $0x0
  pushl $1
801011ce:	6a 01                	push   $0x1
  jmp alltraps
801011d0:	e9 77 0c 00 00       	jmp    80101e4c <alltraps>

801011d5 <vector2>:
.globl vector2
vector2:
  pushl $0
801011d5:	6a 00                	push   $0x0
  pushl $2
801011d7:	6a 02                	push   $0x2
  jmp alltraps
801011d9:	e9 6e 0c 00 00       	jmp    80101e4c <alltraps>

801011de <vector3>:
.globl vector3
vector3:
  pushl $0
801011de:	6a 00                	push   $0x0
  pushl $3
801011e0:	6a 03                	push   $0x3
  jmp alltraps
801011e2:	e9 65 0c 00 00       	jmp    80101e4c <alltraps>

801011e7 <vector4>:
.globl vector4
vector4:
  pushl $0
801011e7:	6a 00                	push   $0x0
  pushl $4
801011e9:	6a 04                	push   $0x4
  jmp alltraps
801011eb:	e9 5c 0c 00 00       	jmp    80101e4c <alltraps>

801011f0 <vector5>:
.globl vector5
vector5:
  pushl $0
801011f0:	6a 00                	push   $0x0
  pushl $5
801011f2:	6a 05                	push   $0x5
  jmp alltraps
801011f4:	e9 53 0c 00 00       	jmp    80101e4c <alltraps>

801011f9 <vector6>:
.globl vector6
vector6:
  pushl $0
801011f9:	6a 00                	push   $0x0
  pushl $6
801011fb:	6a 06                	push   $0x6
  jmp alltraps
801011fd:	e9 4a 0c 00 00       	jmp    80101e4c <alltraps>

80101202 <vector7>:
.globl vector7
vector7:
  pushl $0
80101202:	6a 00                	push   $0x0
  pushl $7
80101204:	6a 07                	push   $0x7
  jmp alltraps
80101206:	e9 41 0c 00 00       	jmp    80101e4c <alltraps>

8010120b <vector8>:
.globl vector8
vector8:
  pushl $8
8010120b:	6a 08                	push   $0x8
  jmp alltraps
8010120d:	e9 3a 0c 00 00       	jmp    80101e4c <alltraps>

80101212 <vector9>:
.globl vector9
vector9:
  pushl $0
80101212:	6a 00                	push   $0x0
  pushl $9
80101214:	6a 09                	push   $0x9
  jmp alltraps
80101216:	e9 31 0c 00 00       	jmp    80101e4c <alltraps>

8010121b <vector10>:
.globl vector10
vector10:
  pushl $10
8010121b:	6a 0a                	push   $0xa
  jmp alltraps
8010121d:	e9 2a 0c 00 00       	jmp    80101e4c <alltraps>

80101222 <vector11>:
.globl vector11
vector11:
  pushl $11
80101222:	6a 0b                	push   $0xb
  jmp alltraps
80101224:	e9 23 0c 00 00       	jmp    80101e4c <alltraps>

80101229 <vector12>:
.globl vector12
vector12:
  pushl $12
80101229:	6a 0c                	push   $0xc
  jmp alltraps
8010122b:	e9 1c 0c 00 00       	jmp    80101e4c <alltraps>

80101230 <vector13>:
.globl vector13
vector13:
  pushl $13
80101230:	6a 0d                	push   $0xd
  jmp alltraps
80101232:	e9 15 0c 00 00       	jmp    80101e4c <alltraps>

80101237 <vector14>:
.globl vector14
vector14:
  pushl $14
80101237:	6a 0e                	push   $0xe
  jmp alltraps
80101239:	e9 0e 0c 00 00       	jmp    80101e4c <alltraps>

8010123e <vector15>:
.globl vector15
vector15:
  pushl $0
8010123e:	6a 00                	push   $0x0
  pushl $15
80101240:	6a 0f                	push   $0xf
  jmp alltraps
80101242:	e9 05 0c 00 00       	jmp    80101e4c <alltraps>

80101247 <vector16>:
.globl vector16
vector16:
  pushl $0
80101247:	6a 00                	push   $0x0
  pushl $16
80101249:	6a 10                	push   $0x10
  jmp alltraps
8010124b:	e9 fc 0b 00 00       	jmp    80101e4c <alltraps>

80101250 <vector17>:
.globl vector17
vector17:
  pushl $17
80101250:	6a 11                	push   $0x11
  jmp alltraps
80101252:	e9 f5 0b 00 00       	jmp    80101e4c <alltraps>

80101257 <vector18>:
.globl vector18
vector18:
  pushl $0
80101257:	6a 00                	push   $0x0
  pushl $18
80101259:	6a 12                	push   $0x12
  jmp alltraps
8010125b:	e9 ec 0b 00 00       	jmp    80101e4c <alltraps>

80101260 <vector19>:
.globl vector19
vector19:
  pushl $0
80101260:	6a 00                	push   $0x0
  pushl $19
80101262:	6a 13                	push   $0x13
  jmp alltraps
80101264:	e9 e3 0b 00 00       	jmp    80101e4c <alltraps>

80101269 <vector20>:
.globl vector20
vector20:
  pushl $0
80101269:	6a 00                	push   $0x0
  pushl $20
8010126b:	6a 14                	push   $0x14
  jmp alltraps
8010126d:	e9 da 0b 00 00       	jmp    80101e4c <alltraps>

80101272 <vector21>:
.globl vector21
vector21:
  pushl $0
80101272:	6a 00                	push   $0x0
  pushl $21
80101274:	6a 15                	push   $0x15
  jmp alltraps
80101276:	e9 d1 0b 00 00       	jmp    80101e4c <alltraps>

8010127b <vector22>:
.globl vector22
vector22:
  pushl $0
8010127b:	6a 00                	push   $0x0
  pushl $22
8010127d:	6a 16                	push   $0x16
  jmp alltraps
8010127f:	e9 c8 0b 00 00       	jmp    80101e4c <alltraps>

80101284 <vector23>:
.globl vector23
vector23:
  pushl $0
80101284:	6a 00                	push   $0x0
  pushl $23
80101286:	6a 17                	push   $0x17
  jmp alltraps
80101288:	e9 bf 0b 00 00       	jmp    80101e4c <alltraps>

8010128d <vector24>:
.globl vector24
vector24:
  pushl $0
8010128d:	6a 00                	push   $0x0
  pushl $24
8010128f:	6a 18                	push   $0x18
  jmp alltraps
80101291:	e9 b6 0b 00 00       	jmp    80101e4c <alltraps>

80101296 <vector25>:
.globl vector25
vector25:
  pushl $0
80101296:	6a 00                	push   $0x0
  pushl $25
80101298:	6a 19                	push   $0x19
  jmp alltraps
8010129a:	e9 ad 0b 00 00       	jmp    80101e4c <alltraps>

8010129f <vector26>:
.globl vector26
vector26:
  pushl $0
8010129f:	6a 00                	push   $0x0
  pushl $26
801012a1:	6a 1a                	push   $0x1a
  jmp alltraps
801012a3:	e9 a4 0b 00 00       	jmp    80101e4c <alltraps>

801012a8 <vector27>:
.globl vector27
vector27:
  pushl $0
801012a8:	6a 00                	push   $0x0
  pushl $27
801012aa:	6a 1b                	push   $0x1b
  jmp alltraps
801012ac:	e9 9b 0b 00 00       	jmp    80101e4c <alltraps>

801012b1 <vector28>:
.globl vector28
vector28:
  pushl $0
801012b1:	6a 00                	push   $0x0
  pushl $28
801012b3:	6a 1c                	push   $0x1c
  jmp alltraps
801012b5:	e9 92 0b 00 00       	jmp    80101e4c <alltraps>

801012ba <vector29>:
.globl vector29
vector29:
  pushl $0
801012ba:	6a 00                	push   $0x0
  pushl $29
801012bc:	6a 1d                	push   $0x1d
  jmp alltraps
801012be:	e9 89 0b 00 00       	jmp    80101e4c <alltraps>

801012c3 <vector30>:
.globl vector30
vector30:
  pushl $0
801012c3:	6a 00                	push   $0x0
  pushl $30
801012c5:	6a 1e                	push   $0x1e
  jmp alltraps
801012c7:	e9 80 0b 00 00       	jmp    80101e4c <alltraps>

801012cc <vector31>:
.globl vector31
vector31:
  pushl $0
801012cc:	6a 00                	push   $0x0
  pushl $31
801012ce:	6a 1f                	push   $0x1f
  jmp alltraps
801012d0:	e9 77 0b 00 00       	jmp    80101e4c <alltraps>

801012d5 <vector32>:
.globl vector32
vector32:
  pushl $0
801012d5:	6a 00                	push   $0x0
  pushl $32
801012d7:	6a 20                	push   $0x20
  jmp alltraps
801012d9:	e9 6e 0b 00 00       	jmp    80101e4c <alltraps>

801012de <vector33>:
.globl vector33
vector33:
  pushl $0
801012de:	6a 00                	push   $0x0
  pushl $33
801012e0:	6a 21                	push   $0x21
  jmp alltraps
801012e2:	e9 65 0b 00 00       	jmp    80101e4c <alltraps>

801012e7 <vector34>:
.globl vector34
vector34:
  pushl $0
801012e7:	6a 00                	push   $0x0
  pushl $34
801012e9:	6a 22                	push   $0x22
  jmp alltraps
801012eb:	e9 5c 0b 00 00       	jmp    80101e4c <alltraps>

801012f0 <vector35>:
.globl vector35
vector35:
  pushl $0
801012f0:	6a 00                	push   $0x0
  pushl $35
801012f2:	6a 23                	push   $0x23
  jmp alltraps
801012f4:	e9 53 0b 00 00       	jmp    80101e4c <alltraps>

801012f9 <vector36>:
.globl vector36
vector36:
  pushl $0
801012f9:	6a 00                	push   $0x0
  pushl $36
801012fb:	6a 24                	push   $0x24
  jmp alltraps
801012fd:	e9 4a 0b 00 00       	jmp    80101e4c <alltraps>

80101302 <vector37>:
.globl vector37
vector37:
  pushl $0
80101302:	6a 00                	push   $0x0
  pushl $37
80101304:	6a 25                	push   $0x25
  jmp alltraps
80101306:	e9 41 0b 00 00       	jmp    80101e4c <alltraps>

8010130b <vector38>:
.globl vector38
vector38:
  pushl $0
8010130b:	6a 00                	push   $0x0
  pushl $38
8010130d:	6a 26                	push   $0x26
  jmp alltraps
8010130f:	e9 38 0b 00 00       	jmp    80101e4c <alltraps>

80101314 <vector39>:
.globl vector39
vector39:
  pushl $0
80101314:	6a 00                	push   $0x0
  pushl $39
80101316:	6a 27                	push   $0x27
  jmp alltraps
80101318:	e9 2f 0b 00 00       	jmp    80101e4c <alltraps>

8010131d <vector40>:
.globl vector40
vector40:
  pushl $0
8010131d:	6a 00                	push   $0x0
  pushl $40
8010131f:	6a 28                	push   $0x28
  jmp alltraps
80101321:	e9 26 0b 00 00       	jmp    80101e4c <alltraps>

80101326 <vector41>:
.globl vector41
vector41:
  pushl $0
80101326:	6a 00                	push   $0x0
  pushl $41
80101328:	6a 29                	push   $0x29
  jmp alltraps
8010132a:	e9 1d 0b 00 00       	jmp    80101e4c <alltraps>

8010132f <vector42>:
.globl vector42
vector42:
  pushl $0
8010132f:	6a 00                	push   $0x0
  pushl $42
80101331:	6a 2a                	push   $0x2a
  jmp alltraps
80101333:	e9 14 0b 00 00       	jmp    80101e4c <alltraps>

80101338 <vector43>:
.globl vector43
vector43:
  pushl $0
80101338:	6a 00                	push   $0x0
  pushl $43
8010133a:	6a 2b                	push   $0x2b
  jmp alltraps
8010133c:	e9 0b 0b 00 00       	jmp    80101e4c <alltraps>

80101341 <vector44>:
.globl vector44
vector44:
  pushl $0
80101341:	6a 00                	push   $0x0
  pushl $44
80101343:	6a 2c                	push   $0x2c
  jmp alltraps
80101345:	e9 02 0b 00 00       	jmp    80101e4c <alltraps>

8010134a <vector45>:
.globl vector45
vector45:
  pushl $0
8010134a:	6a 00                	push   $0x0
  pushl $45
8010134c:	6a 2d                	push   $0x2d
  jmp alltraps
8010134e:	e9 f9 0a 00 00       	jmp    80101e4c <alltraps>

80101353 <vector46>:
.globl vector46
vector46:
  pushl $0
80101353:	6a 00                	push   $0x0
  pushl $46
80101355:	6a 2e                	push   $0x2e
  jmp alltraps
80101357:	e9 f0 0a 00 00       	jmp    80101e4c <alltraps>

8010135c <vector47>:
.globl vector47
vector47:
  pushl $0
8010135c:	6a 00                	push   $0x0
  pushl $47
8010135e:	6a 2f                	push   $0x2f
  jmp alltraps
80101360:	e9 e7 0a 00 00       	jmp    80101e4c <alltraps>

80101365 <vector48>:
.globl vector48
vector48:
  pushl $0
80101365:	6a 00                	push   $0x0
  pushl $48
80101367:	6a 30                	push   $0x30
  jmp alltraps
80101369:	e9 de 0a 00 00       	jmp    80101e4c <alltraps>

8010136e <vector49>:
.globl vector49
vector49:
  pushl $0
8010136e:	6a 00                	push   $0x0
  pushl $49
80101370:	6a 31                	push   $0x31
  jmp alltraps
80101372:	e9 d5 0a 00 00       	jmp    80101e4c <alltraps>

80101377 <vector50>:
.globl vector50
vector50:
  pushl $0
80101377:	6a 00                	push   $0x0
  pushl $50
80101379:	6a 32                	push   $0x32
  jmp alltraps
8010137b:	e9 cc 0a 00 00       	jmp    80101e4c <alltraps>

80101380 <vector51>:
.globl vector51
vector51:
  pushl $0
80101380:	6a 00                	push   $0x0
  pushl $51
80101382:	6a 33                	push   $0x33
  jmp alltraps
80101384:	e9 c3 0a 00 00       	jmp    80101e4c <alltraps>

80101389 <vector52>:
.globl vector52
vector52:
  pushl $0
80101389:	6a 00                	push   $0x0
  pushl $52
8010138b:	6a 34                	push   $0x34
  jmp alltraps
8010138d:	e9 ba 0a 00 00       	jmp    80101e4c <alltraps>

80101392 <vector53>:
.globl vector53
vector53:
  pushl $0
80101392:	6a 00                	push   $0x0
  pushl $53
80101394:	6a 35                	push   $0x35
  jmp alltraps
80101396:	e9 b1 0a 00 00       	jmp    80101e4c <alltraps>

8010139b <vector54>:
.globl vector54
vector54:
  pushl $0
8010139b:	6a 00                	push   $0x0
  pushl $54
8010139d:	6a 36                	push   $0x36
  jmp alltraps
8010139f:	e9 a8 0a 00 00       	jmp    80101e4c <alltraps>

801013a4 <vector55>:
.globl vector55
vector55:
  pushl $0
801013a4:	6a 00                	push   $0x0
  pushl $55
801013a6:	6a 37                	push   $0x37
  jmp alltraps
801013a8:	e9 9f 0a 00 00       	jmp    80101e4c <alltraps>

801013ad <vector56>:
.globl vector56
vector56:
  pushl $0
801013ad:	6a 00                	push   $0x0
  pushl $56
801013af:	6a 38                	push   $0x38
  jmp alltraps
801013b1:	e9 96 0a 00 00       	jmp    80101e4c <alltraps>

801013b6 <vector57>:
.globl vector57
vector57:
  pushl $0
801013b6:	6a 00                	push   $0x0
  pushl $57
801013b8:	6a 39                	push   $0x39
  jmp alltraps
801013ba:	e9 8d 0a 00 00       	jmp    80101e4c <alltraps>

801013bf <vector58>:
.globl vector58
vector58:
  pushl $0
801013bf:	6a 00                	push   $0x0
  pushl $58
801013c1:	6a 3a                	push   $0x3a
  jmp alltraps
801013c3:	e9 84 0a 00 00       	jmp    80101e4c <alltraps>

801013c8 <vector59>:
.globl vector59
vector59:
  pushl $0
801013c8:	6a 00                	push   $0x0
  pushl $59
801013ca:	6a 3b                	push   $0x3b
  jmp alltraps
801013cc:	e9 7b 0a 00 00       	jmp    80101e4c <alltraps>

801013d1 <vector60>:
.globl vector60
vector60:
  pushl $0
801013d1:	6a 00                	push   $0x0
  pushl $60
801013d3:	6a 3c                	push   $0x3c
  jmp alltraps
801013d5:	e9 72 0a 00 00       	jmp    80101e4c <alltraps>

801013da <vector61>:
.globl vector61
vector61:
  pushl $0
801013da:	6a 00                	push   $0x0
  pushl $61
801013dc:	6a 3d                	push   $0x3d
  jmp alltraps
801013de:	e9 69 0a 00 00       	jmp    80101e4c <alltraps>

801013e3 <vector62>:
.globl vector62
vector62:
  pushl $0
801013e3:	6a 00                	push   $0x0
  pushl $62
801013e5:	6a 3e                	push   $0x3e
  jmp alltraps
801013e7:	e9 60 0a 00 00       	jmp    80101e4c <alltraps>

801013ec <vector63>:
.globl vector63
vector63:
  pushl $0
801013ec:	6a 00                	push   $0x0
  pushl $63
801013ee:	6a 3f                	push   $0x3f
  jmp alltraps
801013f0:	e9 57 0a 00 00       	jmp    80101e4c <alltraps>

801013f5 <vector64>:
.globl vector64
vector64:
  pushl $0
801013f5:	6a 00                	push   $0x0
  pushl $64
801013f7:	6a 40                	push   $0x40
  jmp alltraps
801013f9:	e9 4e 0a 00 00       	jmp    80101e4c <alltraps>

801013fe <vector65>:
.globl vector65
vector65:
  pushl $0
801013fe:	6a 00                	push   $0x0
  pushl $65
80101400:	6a 41                	push   $0x41
  jmp alltraps
80101402:	e9 45 0a 00 00       	jmp    80101e4c <alltraps>

80101407 <vector66>:
.globl vector66
vector66:
  pushl $0
80101407:	6a 00                	push   $0x0
  pushl $66
80101409:	6a 42                	push   $0x42
  jmp alltraps
8010140b:	e9 3c 0a 00 00       	jmp    80101e4c <alltraps>

80101410 <vector67>:
.globl vector67
vector67:
  pushl $0
80101410:	6a 00                	push   $0x0
  pushl $67
80101412:	6a 43                	push   $0x43
  jmp alltraps
80101414:	e9 33 0a 00 00       	jmp    80101e4c <alltraps>

80101419 <vector68>:
.globl vector68
vector68:
  pushl $0
80101419:	6a 00                	push   $0x0
  pushl $68
8010141b:	6a 44                	push   $0x44
  jmp alltraps
8010141d:	e9 2a 0a 00 00       	jmp    80101e4c <alltraps>

80101422 <vector69>:
.globl vector69
vector69:
  pushl $0
80101422:	6a 00                	push   $0x0
  pushl $69
80101424:	6a 45                	push   $0x45
  jmp alltraps
80101426:	e9 21 0a 00 00       	jmp    80101e4c <alltraps>

8010142b <vector70>:
.globl vector70
vector70:
  pushl $0
8010142b:	6a 00                	push   $0x0
  pushl $70
8010142d:	6a 46                	push   $0x46
  jmp alltraps
8010142f:	e9 18 0a 00 00       	jmp    80101e4c <alltraps>

80101434 <vector71>:
.globl vector71
vector71:
  pushl $0
80101434:	6a 00                	push   $0x0
  pushl $71
80101436:	6a 47                	push   $0x47
  jmp alltraps
80101438:	e9 0f 0a 00 00       	jmp    80101e4c <alltraps>

8010143d <vector72>:
.globl vector72
vector72:
  pushl $0
8010143d:	6a 00                	push   $0x0
  pushl $72
8010143f:	6a 48                	push   $0x48
  jmp alltraps
80101441:	e9 06 0a 00 00       	jmp    80101e4c <alltraps>

80101446 <vector73>:
.globl vector73
vector73:
  pushl $0
80101446:	6a 00                	push   $0x0
  pushl $73
80101448:	6a 49                	push   $0x49
  jmp alltraps
8010144a:	e9 fd 09 00 00       	jmp    80101e4c <alltraps>

8010144f <vector74>:
.globl vector74
vector74:
  pushl $0
8010144f:	6a 00                	push   $0x0
  pushl $74
80101451:	6a 4a                	push   $0x4a
  jmp alltraps
80101453:	e9 f4 09 00 00       	jmp    80101e4c <alltraps>

80101458 <vector75>:
.globl vector75
vector75:
  pushl $0
80101458:	6a 00                	push   $0x0
  pushl $75
8010145a:	6a 4b                	push   $0x4b
  jmp alltraps
8010145c:	e9 eb 09 00 00       	jmp    80101e4c <alltraps>

80101461 <vector76>:
.globl vector76
vector76:
  pushl $0
80101461:	6a 00                	push   $0x0
  pushl $76
80101463:	6a 4c                	push   $0x4c
  jmp alltraps
80101465:	e9 e2 09 00 00       	jmp    80101e4c <alltraps>

8010146a <vector77>:
.globl vector77
vector77:
  pushl $0
8010146a:	6a 00                	push   $0x0
  pushl $77
8010146c:	6a 4d                	push   $0x4d
  jmp alltraps
8010146e:	e9 d9 09 00 00       	jmp    80101e4c <alltraps>

80101473 <vector78>:
.globl vector78
vector78:
  pushl $0
80101473:	6a 00                	push   $0x0
  pushl $78
80101475:	6a 4e                	push   $0x4e
  jmp alltraps
80101477:	e9 d0 09 00 00       	jmp    80101e4c <alltraps>

8010147c <vector79>:
.globl vector79
vector79:
  pushl $0
8010147c:	6a 00                	push   $0x0
  pushl $79
8010147e:	6a 4f                	push   $0x4f
  jmp alltraps
80101480:	e9 c7 09 00 00       	jmp    80101e4c <alltraps>

80101485 <vector80>:
.globl vector80
vector80:
  pushl $0
80101485:	6a 00                	push   $0x0
  pushl $80
80101487:	6a 50                	push   $0x50
  jmp alltraps
80101489:	e9 be 09 00 00       	jmp    80101e4c <alltraps>

8010148e <vector81>:
.globl vector81
vector81:
  pushl $0
8010148e:	6a 00                	push   $0x0
  pushl $81
80101490:	6a 51                	push   $0x51
  jmp alltraps
80101492:	e9 b5 09 00 00       	jmp    80101e4c <alltraps>

80101497 <vector82>:
.globl vector82
vector82:
  pushl $0
80101497:	6a 00                	push   $0x0
  pushl $82
80101499:	6a 52                	push   $0x52
  jmp alltraps
8010149b:	e9 ac 09 00 00       	jmp    80101e4c <alltraps>

801014a0 <vector83>:
.globl vector83
vector83:
  pushl $0
801014a0:	6a 00                	push   $0x0
  pushl $83
801014a2:	6a 53                	push   $0x53
  jmp alltraps
801014a4:	e9 a3 09 00 00       	jmp    80101e4c <alltraps>

801014a9 <vector84>:
.globl vector84
vector84:
  pushl $0
801014a9:	6a 00                	push   $0x0
  pushl $84
801014ab:	6a 54                	push   $0x54
  jmp alltraps
801014ad:	e9 9a 09 00 00       	jmp    80101e4c <alltraps>

801014b2 <vector85>:
.globl vector85
vector85:
  pushl $0
801014b2:	6a 00                	push   $0x0
  pushl $85
801014b4:	6a 55                	push   $0x55
  jmp alltraps
801014b6:	e9 91 09 00 00       	jmp    80101e4c <alltraps>

801014bb <vector86>:
.globl vector86
vector86:
  pushl $0
801014bb:	6a 00                	push   $0x0
  pushl $86
801014bd:	6a 56                	push   $0x56
  jmp alltraps
801014bf:	e9 88 09 00 00       	jmp    80101e4c <alltraps>

801014c4 <vector87>:
.globl vector87
vector87:
  pushl $0
801014c4:	6a 00                	push   $0x0
  pushl $87
801014c6:	6a 57                	push   $0x57
  jmp alltraps
801014c8:	e9 7f 09 00 00       	jmp    80101e4c <alltraps>

801014cd <vector88>:
.globl vector88
vector88:
  pushl $0
801014cd:	6a 00                	push   $0x0
  pushl $88
801014cf:	6a 58                	push   $0x58
  jmp alltraps
801014d1:	e9 76 09 00 00       	jmp    80101e4c <alltraps>

801014d6 <vector89>:
.globl vector89
vector89:
  pushl $0
801014d6:	6a 00                	push   $0x0
  pushl $89
801014d8:	6a 59                	push   $0x59
  jmp alltraps
801014da:	e9 6d 09 00 00       	jmp    80101e4c <alltraps>

801014df <vector90>:
.globl vector90
vector90:
  pushl $0
801014df:	6a 00                	push   $0x0
  pushl $90
801014e1:	6a 5a                	push   $0x5a
  jmp alltraps
801014e3:	e9 64 09 00 00       	jmp    80101e4c <alltraps>

801014e8 <vector91>:
.globl vector91
vector91:
  pushl $0
801014e8:	6a 00                	push   $0x0
  pushl $91
801014ea:	6a 5b                	push   $0x5b
  jmp alltraps
801014ec:	e9 5b 09 00 00       	jmp    80101e4c <alltraps>

801014f1 <vector92>:
.globl vector92
vector92:
  pushl $0
801014f1:	6a 00                	push   $0x0
  pushl $92
801014f3:	6a 5c                	push   $0x5c
  jmp alltraps
801014f5:	e9 52 09 00 00       	jmp    80101e4c <alltraps>

801014fa <vector93>:
.globl vector93
vector93:
  pushl $0
801014fa:	6a 00                	push   $0x0
  pushl $93
801014fc:	6a 5d                	push   $0x5d
  jmp alltraps
801014fe:	e9 49 09 00 00       	jmp    80101e4c <alltraps>

80101503 <vector94>:
.globl vector94
vector94:
  pushl $0
80101503:	6a 00                	push   $0x0
  pushl $94
80101505:	6a 5e                	push   $0x5e
  jmp alltraps
80101507:	e9 40 09 00 00       	jmp    80101e4c <alltraps>

8010150c <vector95>:
.globl vector95
vector95:
  pushl $0
8010150c:	6a 00                	push   $0x0
  pushl $95
8010150e:	6a 5f                	push   $0x5f
  jmp alltraps
80101510:	e9 37 09 00 00       	jmp    80101e4c <alltraps>

80101515 <vector96>:
.globl vector96
vector96:
  pushl $0
80101515:	6a 00                	push   $0x0
  pushl $96
80101517:	6a 60                	push   $0x60
  jmp alltraps
80101519:	e9 2e 09 00 00       	jmp    80101e4c <alltraps>

8010151e <vector97>:
.globl vector97
vector97:
  pushl $0
8010151e:	6a 00                	push   $0x0
  pushl $97
80101520:	6a 61                	push   $0x61
  jmp alltraps
80101522:	e9 25 09 00 00       	jmp    80101e4c <alltraps>

80101527 <vector98>:
.globl vector98
vector98:
  pushl $0
80101527:	6a 00                	push   $0x0
  pushl $98
80101529:	6a 62                	push   $0x62
  jmp alltraps
8010152b:	e9 1c 09 00 00       	jmp    80101e4c <alltraps>

80101530 <vector99>:
.globl vector99
vector99:
  pushl $0
80101530:	6a 00                	push   $0x0
  pushl $99
80101532:	6a 63                	push   $0x63
  jmp alltraps
80101534:	e9 13 09 00 00       	jmp    80101e4c <alltraps>

80101539 <vector100>:
.globl vector100
vector100:
  pushl $0
80101539:	6a 00                	push   $0x0
  pushl $100
8010153b:	6a 64                	push   $0x64
  jmp alltraps
8010153d:	e9 0a 09 00 00       	jmp    80101e4c <alltraps>

80101542 <vector101>:
.globl vector101
vector101:
  pushl $0
80101542:	6a 00                	push   $0x0
  pushl $101
80101544:	6a 65                	push   $0x65
  jmp alltraps
80101546:	e9 01 09 00 00       	jmp    80101e4c <alltraps>

8010154b <vector102>:
.globl vector102
vector102:
  pushl $0
8010154b:	6a 00                	push   $0x0
  pushl $102
8010154d:	6a 66                	push   $0x66
  jmp alltraps
8010154f:	e9 f8 08 00 00       	jmp    80101e4c <alltraps>

80101554 <vector103>:
.globl vector103
vector103:
  pushl $0
80101554:	6a 00                	push   $0x0
  pushl $103
80101556:	6a 67                	push   $0x67
  jmp alltraps
80101558:	e9 ef 08 00 00       	jmp    80101e4c <alltraps>

8010155d <vector104>:
.globl vector104
vector104:
  pushl $0
8010155d:	6a 00                	push   $0x0
  pushl $104
8010155f:	6a 68                	push   $0x68
  jmp alltraps
80101561:	e9 e6 08 00 00       	jmp    80101e4c <alltraps>

80101566 <vector105>:
.globl vector105
vector105:
  pushl $0
80101566:	6a 00                	push   $0x0
  pushl $105
80101568:	6a 69                	push   $0x69
  jmp alltraps
8010156a:	e9 dd 08 00 00       	jmp    80101e4c <alltraps>

8010156f <vector106>:
.globl vector106
vector106:
  pushl $0
8010156f:	6a 00                	push   $0x0
  pushl $106
80101571:	6a 6a                	push   $0x6a
  jmp alltraps
80101573:	e9 d4 08 00 00       	jmp    80101e4c <alltraps>

80101578 <vector107>:
.globl vector107
vector107:
  pushl $0
80101578:	6a 00                	push   $0x0
  pushl $107
8010157a:	6a 6b                	push   $0x6b
  jmp alltraps
8010157c:	e9 cb 08 00 00       	jmp    80101e4c <alltraps>

80101581 <vector108>:
.globl vector108
vector108:
  pushl $0
80101581:	6a 00                	push   $0x0
  pushl $108
80101583:	6a 6c                	push   $0x6c
  jmp alltraps
80101585:	e9 c2 08 00 00       	jmp    80101e4c <alltraps>

8010158a <vector109>:
.globl vector109
vector109:
  pushl $0
8010158a:	6a 00                	push   $0x0
  pushl $109
8010158c:	6a 6d                	push   $0x6d
  jmp alltraps
8010158e:	e9 b9 08 00 00       	jmp    80101e4c <alltraps>

80101593 <vector110>:
.globl vector110
vector110:
  pushl $0
80101593:	6a 00                	push   $0x0
  pushl $110
80101595:	6a 6e                	push   $0x6e
  jmp alltraps
80101597:	e9 b0 08 00 00       	jmp    80101e4c <alltraps>

8010159c <vector111>:
.globl vector111
vector111:
  pushl $0
8010159c:	6a 00                	push   $0x0
  pushl $111
8010159e:	6a 6f                	push   $0x6f
  jmp alltraps
801015a0:	e9 a7 08 00 00       	jmp    80101e4c <alltraps>

801015a5 <vector112>:
.globl vector112
vector112:
  pushl $0
801015a5:	6a 00                	push   $0x0
  pushl $112
801015a7:	6a 70                	push   $0x70
  jmp alltraps
801015a9:	e9 9e 08 00 00       	jmp    80101e4c <alltraps>

801015ae <vector113>:
.globl vector113
vector113:
  pushl $0
801015ae:	6a 00                	push   $0x0
  pushl $113
801015b0:	6a 71                	push   $0x71
  jmp alltraps
801015b2:	e9 95 08 00 00       	jmp    80101e4c <alltraps>

801015b7 <vector114>:
.globl vector114
vector114:
  pushl $0
801015b7:	6a 00                	push   $0x0
  pushl $114
801015b9:	6a 72                	push   $0x72
  jmp alltraps
801015bb:	e9 8c 08 00 00       	jmp    80101e4c <alltraps>

801015c0 <vector115>:
.globl vector115
vector115:
  pushl $0
801015c0:	6a 00                	push   $0x0
  pushl $115
801015c2:	6a 73                	push   $0x73
  jmp alltraps
801015c4:	e9 83 08 00 00       	jmp    80101e4c <alltraps>

801015c9 <vector116>:
.globl vector116
vector116:
  pushl $0
801015c9:	6a 00                	push   $0x0
  pushl $116
801015cb:	6a 74                	push   $0x74
  jmp alltraps
801015cd:	e9 7a 08 00 00       	jmp    80101e4c <alltraps>

801015d2 <vector117>:
.globl vector117
vector117:
  pushl $0
801015d2:	6a 00                	push   $0x0
  pushl $117
801015d4:	6a 75                	push   $0x75
  jmp alltraps
801015d6:	e9 71 08 00 00       	jmp    80101e4c <alltraps>

801015db <vector118>:
.globl vector118
vector118:
  pushl $0
801015db:	6a 00                	push   $0x0
  pushl $118
801015dd:	6a 76                	push   $0x76
  jmp alltraps
801015df:	e9 68 08 00 00       	jmp    80101e4c <alltraps>

801015e4 <vector119>:
.globl vector119
vector119:
  pushl $0
801015e4:	6a 00                	push   $0x0
  pushl $119
801015e6:	6a 77                	push   $0x77
  jmp alltraps
801015e8:	e9 5f 08 00 00       	jmp    80101e4c <alltraps>

801015ed <vector120>:
.globl vector120
vector120:
  pushl $0
801015ed:	6a 00                	push   $0x0
  pushl $120
801015ef:	6a 78                	push   $0x78
  jmp alltraps
801015f1:	e9 56 08 00 00       	jmp    80101e4c <alltraps>

801015f6 <vector121>:
.globl vector121
vector121:
  pushl $0
801015f6:	6a 00                	push   $0x0
  pushl $121
801015f8:	6a 79                	push   $0x79
  jmp alltraps
801015fa:	e9 4d 08 00 00       	jmp    80101e4c <alltraps>

801015ff <vector122>:
.globl vector122
vector122:
  pushl $0
801015ff:	6a 00                	push   $0x0
  pushl $122
80101601:	6a 7a                	push   $0x7a
  jmp alltraps
80101603:	e9 44 08 00 00       	jmp    80101e4c <alltraps>

80101608 <vector123>:
.globl vector123
vector123:
  pushl $0
80101608:	6a 00                	push   $0x0
  pushl $123
8010160a:	6a 7b                	push   $0x7b
  jmp alltraps
8010160c:	e9 3b 08 00 00       	jmp    80101e4c <alltraps>

80101611 <vector124>:
.globl vector124
vector124:
  pushl $0
80101611:	6a 00                	push   $0x0
  pushl $124
80101613:	6a 7c                	push   $0x7c
  jmp alltraps
80101615:	e9 32 08 00 00       	jmp    80101e4c <alltraps>

8010161a <vector125>:
.globl vector125
vector125:
  pushl $0
8010161a:	6a 00                	push   $0x0
  pushl $125
8010161c:	6a 7d                	push   $0x7d
  jmp alltraps
8010161e:	e9 29 08 00 00       	jmp    80101e4c <alltraps>

80101623 <vector126>:
.globl vector126
vector126:
  pushl $0
80101623:	6a 00                	push   $0x0
  pushl $126
80101625:	6a 7e                	push   $0x7e
  jmp alltraps
80101627:	e9 20 08 00 00       	jmp    80101e4c <alltraps>

8010162c <vector127>:
.globl vector127
vector127:
  pushl $0
8010162c:	6a 00                	push   $0x0
  pushl $127
8010162e:	6a 7f                	push   $0x7f
  jmp alltraps
80101630:	e9 17 08 00 00       	jmp    80101e4c <alltraps>

80101635 <vector128>:
.globl vector128
vector128:
  pushl $0
80101635:	6a 00                	push   $0x0
  pushl $128
80101637:	68 80 00 00 00       	push   $0x80
  jmp alltraps
8010163c:	e9 0b 08 00 00       	jmp    80101e4c <alltraps>

80101641 <vector129>:
.globl vector129
vector129:
  pushl $0
80101641:	6a 00                	push   $0x0
  pushl $129
80101643:	68 81 00 00 00       	push   $0x81
  jmp alltraps
80101648:	e9 ff 07 00 00       	jmp    80101e4c <alltraps>

8010164d <vector130>:
.globl vector130
vector130:
  pushl $0
8010164d:	6a 00                	push   $0x0
  pushl $130
8010164f:	68 82 00 00 00       	push   $0x82
  jmp alltraps
80101654:	e9 f3 07 00 00       	jmp    80101e4c <alltraps>

80101659 <vector131>:
.globl vector131
vector131:
  pushl $0
80101659:	6a 00                	push   $0x0
  pushl $131
8010165b:	68 83 00 00 00       	push   $0x83
  jmp alltraps
80101660:	e9 e7 07 00 00       	jmp    80101e4c <alltraps>

80101665 <vector132>:
.globl vector132
vector132:
  pushl $0
80101665:	6a 00                	push   $0x0
  pushl $132
80101667:	68 84 00 00 00       	push   $0x84
  jmp alltraps
8010166c:	e9 db 07 00 00       	jmp    80101e4c <alltraps>

80101671 <vector133>:
.globl vector133
vector133:
  pushl $0
80101671:	6a 00                	push   $0x0
  pushl $133
80101673:	68 85 00 00 00       	push   $0x85
  jmp alltraps
80101678:	e9 cf 07 00 00       	jmp    80101e4c <alltraps>

8010167d <vector134>:
.globl vector134
vector134:
  pushl $0
8010167d:	6a 00                	push   $0x0
  pushl $134
8010167f:	68 86 00 00 00       	push   $0x86
  jmp alltraps
80101684:	e9 c3 07 00 00       	jmp    80101e4c <alltraps>

80101689 <vector135>:
.globl vector135
vector135:
  pushl $0
80101689:	6a 00                	push   $0x0
  pushl $135
8010168b:	68 87 00 00 00       	push   $0x87
  jmp alltraps
80101690:	e9 b7 07 00 00       	jmp    80101e4c <alltraps>

80101695 <vector136>:
.globl vector136
vector136:
  pushl $0
80101695:	6a 00                	push   $0x0
  pushl $136
80101697:	68 88 00 00 00       	push   $0x88
  jmp alltraps
8010169c:	e9 ab 07 00 00       	jmp    80101e4c <alltraps>

801016a1 <vector137>:
.globl vector137
vector137:
  pushl $0
801016a1:	6a 00                	push   $0x0
  pushl $137
801016a3:	68 89 00 00 00       	push   $0x89
  jmp alltraps
801016a8:	e9 9f 07 00 00       	jmp    80101e4c <alltraps>

801016ad <vector138>:
.globl vector138
vector138:
  pushl $0
801016ad:	6a 00                	push   $0x0
  pushl $138
801016af:	68 8a 00 00 00       	push   $0x8a
  jmp alltraps
801016b4:	e9 93 07 00 00       	jmp    80101e4c <alltraps>

801016b9 <vector139>:
.globl vector139
vector139:
  pushl $0
801016b9:	6a 00                	push   $0x0
  pushl $139
801016bb:	68 8b 00 00 00       	push   $0x8b
  jmp alltraps
801016c0:	e9 87 07 00 00       	jmp    80101e4c <alltraps>

801016c5 <vector140>:
.globl vector140
vector140:
  pushl $0
801016c5:	6a 00                	push   $0x0
  pushl $140
801016c7:	68 8c 00 00 00       	push   $0x8c
  jmp alltraps
801016cc:	e9 7b 07 00 00       	jmp    80101e4c <alltraps>

801016d1 <vector141>:
.globl vector141
vector141:
  pushl $0
801016d1:	6a 00                	push   $0x0
  pushl $141
801016d3:	68 8d 00 00 00       	push   $0x8d
  jmp alltraps
801016d8:	e9 6f 07 00 00       	jmp    80101e4c <alltraps>

801016dd <vector142>:
.globl vector142
vector142:
  pushl $0
801016dd:	6a 00                	push   $0x0
  pushl $142
801016df:	68 8e 00 00 00       	push   $0x8e
  jmp alltraps
801016e4:	e9 63 07 00 00       	jmp    80101e4c <alltraps>

801016e9 <vector143>:
.globl vector143
vector143:
  pushl $0
801016e9:	6a 00                	push   $0x0
  pushl $143
801016eb:	68 8f 00 00 00       	push   $0x8f
  jmp alltraps
801016f0:	e9 57 07 00 00       	jmp    80101e4c <alltraps>

801016f5 <vector144>:
.globl vector144
vector144:
  pushl $0
801016f5:	6a 00                	push   $0x0
  pushl $144
801016f7:	68 90 00 00 00       	push   $0x90
  jmp alltraps
801016fc:	e9 4b 07 00 00       	jmp    80101e4c <alltraps>

80101701 <vector145>:
.globl vector145
vector145:
  pushl $0
80101701:	6a 00                	push   $0x0
  pushl $145
80101703:	68 91 00 00 00       	push   $0x91
  jmp alltraps
80101708:	e9 3f 07 00 00       	jmp    80101e4c <alltraps>

8010170d <vector146>:
.globl vector146
vector146:
  pushl $0
8010170d:	6a 00                	push   $0x0
  pushl $146
8010170f:	68 92 00 00 00       	push   $0x92
  jmp alltraps
80101714:	e9 33 07 00 00       	jmp    80101e4c <alltraps>

80101719 <vector147>:
.globl vector147
vector147:
  pushl $0
80101719:	6a 00                	push   $0x0
  pushl $147
8010171b:	68 93 00 00 00       	push   $0x93
  jmp alltraps
80101720:	e9 27 07 00 00       	jmp    80101e4c <alltraps>

80101725 <vector148>:
.globl vector148
vector148:
  pushl $0
80101725:	6a 00                	push   $0x0
  pushl $148
80101727:	68 94 00 00 00       	push   $0x94
  jmp alltraps
8010172c:	e9 1b 07 00 00       	jmp    80101e4c <alltraps>

80101731 <vector149>:
.globl vector149
vector149:
  pushl $0
80101731:	6a 00                	push   $0x0
  pushl $149
80101733:	68 95 00 00 00       	push   $0x95
  jmp alltraps
80101738:	e9 0f 07 00 00       	jmp    80101e4c <alltraps>

8010173d <vector150>:
.globl vector150
vector150:
  pushl $0
8010173d:	6a 00                	push   $0x0
  pushl $150
8010173f:	68 96 00 00 00       	push   $0x96
  jmp alltraps
80101744:	e9 03 07 00 00       	jmp    80101e4c <alltraps>

80101749 <vector151>:
.globl vector151
vector151:
  pushl $0
80101749:	6a 00                	push   $0x0
  pushl $151
8010174b:	68 97 00 00 00       	push   $0x97
  jmp alltraps
80101750:	e9 f7 06 00 00       	jmp    80101e4c <alltraps>

80101755 <vector152>:
.globl vector152
vector152:
  pushl $0
80101755:	6a 00                	push   $0x0
  pushl $152
80101757:	68 98 00 00 00       	push   $0x98
  jmp alltraps
8010175c:	e9 eb 06 00 00       	jmp    80101e4c <alltraps>

80101761 <vector153>:
.globl vector153
vector153:
  pushl $0
80101761:	6a 00                	push   $0x0
  pushl $153
80101763:	68 99 00 00 00       	push   $0x99
  jmp alltraps
80101768:	e9 df 06 00 00       	jmp    80101e4c <alltraps>

8010176d <vector154>:
.globl vector154
vector154:
  pushl $0
8010176d:	6a 00                	push   $0x0
  pushl $154
8010176f:	68 9a 00 00 00       	push   $0x9a
  jmp alltraps
80101774:	e9 d3 06 00 00       	jmp    80101e4c <alltraps>

80101779 <vector155>:
.globl vector155
vector155:
  pushl $0
80101779:	6a 00                	push   $0x0
  pushl $155
8010177b:	68 9b 00 00 00       	push   $0x9b
  jmp alltraps
80101780:	e9 c7 06 00 00       	jmp    80101e4c <alltraps>

80101785 <vector156>:
.globl vector156
vector156:
  pushl $0
80101785:	6a 00                	push   $0x0
  pushl $156
80101787:	68 9c 00 00 00       	push   $0x9c
  jmp alltraps
8010178c:	e9 bb 06 00 00       	jmp    80101e4c <alltraps>

80101791 <vector157>:
.globl vector157
vector157:
  pushl $0
80101791:	6a 00                	push   $0x0
  pushl $157
80101793:	68 9d 00 00 00       	push   $0x9d
  jmp alltraps
80101798:	e9 af 06 00 00       	jmp    80101e4c <alltraps>

8010179d <vector158>:
.globl vector158
vector158:
  pushl $0
8010179d:	6a 00                	push   $0x0
  pushl $158
8010179f:	68 9e 00 00 00       	push   $0x9e
  jmp alltraps
801017a4:	e9 a3 06 00 00       	jmp    80101e4c <alltraps>

801017a9 <vector159>:
.globl vector159
vector159:
  pushl $0
801017a9:	6a 00                	push   $0x0
  pushl $159
801017ab:	68 9f 00 00 00       	push   $0x9f
  jmp alltraps
801017b0:	e9 97 06 00 00       	jmp    80101e4c <alltraps>

801017b5 <vector160>:
.globl vector160
vector160:
  pushl $0
801017b5:	6a 00                	push   $0x0
  pushl $160
801017b7:	68 a0 00 00 00       	push   $0xa0
  jmp alltraps
801017bc:	e9 8b 06 00 00       	jmp    80101e4c <alltraps>

801017c1 <vector161>:
.globl vector161
vector161:
  pushl $0
801017c1:	6a 00                	push   $0x0
  pushl $161
801017c3:	68 a1 00 00 00       	push   $0xa1
  jmp alltraps
801017c8:	e9 7f 06 00 00       	jmp    80101e4c <alltraps>

801017cd <vector162>:
.globl vector162
vector162:
  pushl $0
801017cd:	6a 00                	push   $0x0
  pushl $162
801017cf:	68 a2 00 00 00       	push   $0xa2
  jmp alltraps
801017d4:	e9 73 06 00 00       	jmp    80101e4c <alltraps>

801017d9 <vector163>:
.globl vector163
vector163:
  pushl $0
801017d9:	6a 00                	push   $0x0
  pushl $163
801017db:	68 a3 00 00 00       	push   $0xa3
  jmp alltraps
801017e0:	e9 67 06 00 00       	jmp    80101e4c <alltraps>

801017e5 <vector164>:
.globl vector164
vector164:
  pushl $0
801017e5:	6a 00                	push   $0x0
  pushl $164
801017e7:	68 a4 00 00 00       	push   $0xa4
  jmp alltraps
801017ec:	e9 5b 06 00 00       	jmp    80101e4c <alltraps>

801017f1 <vector165>:
.globl vector165
vector165:
  pushl $0
801017f1:	6a 00                	push   $0x0
  pushl $165
801017f3:	68 a5 00 00 00       	push   $0xa5
  jmp alltraps
801017f8:	e9 4f 06 00 00       	jmp    80101e4c <alltraps>

801017fd <vector166>:
.globl vector166
vector166:
  pushl $0
801017fd:	6a 00                	push   $0x0
  pushl $166
801017ff:	68 a6 00 00 00       	push   $0xa6
  jmp alltraps
80101804:	e9 43 06 00 00       	jmp    80101e4c <alltraps>

80101809 <vector167>:
.globl vector167
vector167:
  pushl $0
80101809:	6a 00                	push   $0x0
  pushl $167
8010180b:	68 a7 00 00 00       	push   $0xa7
  jmp alltraps
80101810:	e9 37 06 00 00       	jmp    80101e4c <alltraps>

80101815 <vector168>:
.globl vector168
vector168:
  pushl $0
80101815:	6a 00                	push   $0x0
  pushl $168
80101817:	68 a8 00 00 00       	push   $0xa8
  jmp alltraps
8010181c:	e9 2b 06 00 00       	jmp    80101e4c <alltraps>

80101821 <vector169>:
.globl vector169
vector169:
  pushl $0
80101821:	6a 00                	push   $0x0
  pushl $169
80101823:	68 a9 00 00 00       	push   $0xa9
  jmp alltraps
80101828:	e9 1f 06 00 00       	jmp    80101e4c <alltraps>

8010182d <vector170>:
.globl vector170
vector170:
  pushl $0
8010182d:	6a 00                	push   $0x0
  pushl $170
8010182f:	68 aa 00 00 00       	push   $0xaa
  jmp alltraps
80101834:	e9 13 06 00 00       	jmp    80101e4c <alltraps>

80101839 <vector171>:
.globl vector171
vector171:
  pushl $0
80101839:	6a 00                	push   $0x0
  pushl $171
8010183b:	68 ab 00 00 00       	push   $0xab
  jmp alltraps
80101840:	e9 07 06 00 00       	jmp    80101e4c <alltraps>

80101845 <vector172>:
.globl vector172
vector172:
  pushl $0
80101845:	6a 00                	push   $0x0
  pushl $172
80101847:	68 ac 00 00 00       	push   $0xac
  jmp alltraps
8010184c:	e9 fb 05 00 00       	jmp    80101e4c <alltraps>

80101851 <vector173>:
.globl vector173
vector173:
  pushl $0
80101851:	6a 00                	push   $0x0
  pushl $173
80101853:	68 ad 00 00 00       	push   $0xad
  jmp alltraps
80101858:	e9 ef 05 00 00       	jmp    80101e4c <alltraps>

8010185d <vector174>:
.globl vector174
vector174:
  pushl $0
8010185d:	6a 00                	push   $0x0
  pushl $174
8010185f:	68 ae 00 00 00       	push   $0xae
  jmp alltraps
80101864:	e9 e3 05 00 00       	jmp    80101e4c <alltraps>

80101869 <vector175>:
.globl vector175
vector175:
  pushl $0
80101869:	6a 00                	push   $0x0
  pushl $175
8010186b:	68 af 00 00 00       	push   $0xaf
  jmp alltraps
80101870:	e9 d7 05 00 00       	jmp    80101e4c <alltraps>

80101875 <vector176>:
.globl vector176
vector176:
  pushl $0
80101875:	6a 00                	push   $0x0
  pushl $176
80101877:	68 b0 00 00 00       	push   $0xb0
  jmp alltraps
8010187c:	e9 cb 05 00 00       	jmp    80101e4c <alltraps>

80101881 <vector177>:
.globl vector177
vector177:
  pushl $0
80101881:	6a 00                	push   $0x0
  pushl $177
80101883:	68 b1 00 00 00       	push   $0xb1
  jmp alltraps
80101888:	e9 bf 05 00 00       	jmp    80101e4c <alltraps>

8010188d <vector178>:
.globl vector178
vector178:
  pushl $0
8010188d:	6a 00                	push   $0x0
  pushl $178
8010188f:	68 b2 00 00 00       	push   $0xb2
  jmp alltraps
80101894:	e9 b3 05 00 00       	jmp    80101e4c <alltraps>

80101899 <vector179>:
.globl vector179
vector179:
  pushl $0
80101899:	6a 00                	push   $0x0
  pushl $179
8010189b:	68 b3 00 00 00       	push   $0xb3
  jmp alltraps
801018a0:	e9 a7 05 00 00       	jmp    80101e4c <alltraps>

801018a5 <vector180>:
.globl vector180
vector180:
  pushl $0
801018a5:	6a 00                	push   $0x0
  pushl $180
801018a7:	68 b4 00 00 00       	push   $0xb4
  jmp alltraps
801018ac:	e9 9b 05 00 00       	jmp    80101e4c <alltraps>

801018b1 <vector181>:
.globl vector181
vector181:
  pushl $0
801018b1:	6a 00                	push   $0x0
  pushl $181
801018b3:	68 b5 00 00 00       	push   $0xb5
  jmp alltraps
801018b8:	e9 8f 05 00 00       	jmp    80101e4c <alltraps>

801018bd <vector182>:
.globl vector182
vector182:
  pushl $0
801018bd:	6a 00                	push   $0x0
  pushl $182
801018bf:	68 b6 00 00 00       	push   $0xb6
  jmp alltraps
801018c4:	e9 83 05 00 00       	jmp    80101e4c <alltraps>

801018c9 <vector183>:
.globl vector183
vector183:
  pushl $0
801018c9:	6a 00                	push   $0x0
  pushl $183
801018cb:	68 b7 00 00 00       	push   $0xb7
  jmp alltraps
801018d0:	e9 77 05 00 00       	jmp    80101e4c <alltraps>

801018d5 <vector184>:
.globl vector184
vector184:
  pushl $0
801018d5:	6a 00                	push   $0x0
  pushl $184
801018d7:	68 b8 00 00 00       	push   $0xb8
  jmp alltraps
801018dc:	e9 6b 05 00 00       	jmp    80101e4c <alltraps>

801018e1 <vector185>:
.globl vector185
vector185:
  pushl $0
801018e1:	6a 00                	push   $0x0
  pushl $185
801018e3:	68 b9 00 00 00       	push   $0xb9
  jmp alltraps
801018e8:	e9 5f 05 00 00       	jmp    80101e4c <alltraps>

801018ed <vector186>:
.globl vector186
vector186:
  pushl $0
801018ed:	6a 00                	push   $0x0
  pushl $186
801018ef:	68 ba 00 00 00       	push   $0xba
  jmp alltraps
801018f4:	e9 53 05 00 00       	jmp    80101e4c <alltraps>

801018f9 <vector187>:
.globl vector187
vector187:
  pushl $0
801018f9:	6a 00                	push   $0x0
  pushl $187
801018fb:	68 bb 00 00 00       	push   $0xbb
  jmp alltraps
80101900:	e9 47 05 00 00       	jmp    80101e4c <alltraps>

80101905 <vector188>:
.globl vector188
vector188:
  pushl $0
80101905:	6a 00                	push   $0x0
  pushl $188
80101907:	68 bc 00 00 00       	push   $0xbc
  jmp alltraps
8010190c:	e9 3b 05 00 00       	jmp    80101e4c <alltraps>

80101911 <vector189>:
.globl vector189
vector189:
  pushl $0
80101911:	6a 00                	push   $0x0
  pushl $189
80101913:	68 bd 00 00 00       	push   $0xbd
  jmp alltraps
80101918:	e9 2f 05 00 00       	jmp    80101e4c <alltraps>

8010191d <vector190>:
.globl vector190
vector190:
  pushl $0
8010191d:	6a 00                	push   $0x0
  pushl $190
8010191f:	68 be 00 00 00       	push   $0xbe
  jmp alltraps
80101924:	e9 23 05 00 00       	jmp    80101e4c <alltraps>

80101929 <vector191>:
.globl vector191
vector191:
  pushl $0
80101929:	6a 00                	push   $0x0
  pushl $191
8010192b:	68 bf 00 00 00       	push   $0xbf
  jmp alltraps
80101930:	e9 17 05 00 00       	jmp    80101e4c <alltraps>

80101935 <vector192>:
.globl vector192
vector192:
  pushl $0
80101935:	6a 00                	push   $0x0
  pushl $192
80101937:	68 c0 00 00 00       	push   $0xc0
  jmp alltraps
8010193c:	e9 0b 05 00 00       	jmp    80101e4c <alltraps>

80101941 <vector193>:
.globl vector193
vector193:
  pushl $0
80101941:	6a 00                	push   $0x0
  pushl $193
80101943:	68 c1 00 00 00       	push   $0xc1
  jmp alltraps
80101948:	e9 ff 04 00 00       	jmp    80101e4c <alltraps>

8010194d <vector194>:
.globl vector194
vector194:
  pushl $0
8010194d:	6a 00                	push   $0x0
  pushl $194
8010194f:	68 c2 00 00 00       	push   $0xc2
  jmp alltraps
80101954:	e9 f3 04 00 00       	jmp    80101e4c <alltraps>

80101959 <vector195>:
.globl vector195
vector195:
  pushl $0
80101959:	6a 00                	push   $0x0
  pushl $195
8010195b:	68 c3 00 00 00       	push   $0xc3
  jmp alltraps
80101960:	e9 e7 04 00 00       	jmp    80101e4c <alltraps>

80101965 <vector196>:
.globl vector196
vector196:
  pushl $0
80101965:	6a 00                	push   $0x0
  pushl $196
80101967:	68 c4 00 00 00       	push   $0xc4
  jmp alltraps
8010196c:	e9 db 04 00 00       	jmp    80101e4c <alltraps>

80101971 <vector197>:
.globl vector197
vector197:
  pushl $0
80101971:	6a 00                	push   $0x0
  pushl $197
80101973:	68 c5 00 00 00       	push   $0xc5
  jmp alltraps
80101978:	e9 cf 04 00 00       	jmp    80101e4c <alltraps>

8010197d <vector198>:
.globl vector198
vector198:
  pushl $0
8010197d:	6a 00                	push   $0x0
  pushl $198
8010197f:	68 c6 00 00 00       	push   $0xc6
  jmp alltraps
80101984:	e9 c3 04 00 00       	jmp    80101e4c <alltraps>

80101989 <vector199>:
.globl vector199
vector199:
  pushl $0
80101989:	6a 00                	push   $0x0
  pushl $199
8010198b:	68 c7 00 00 00       	push   $0xc7
  jmp alltraps
80101990:	e9 b7 04 00 00       	jmp    80101e4c <alltraps>

80101995 <vector200>:
.globl vector200
vector200:
  pushl $0
80101995:	6a 00                	push   $0x0
  pushl $200
80101997:	68 c8 00 00 00       	push   $0xc8
  jmp alltraps
8010199c:	e9 ab 04 00 00       	jmp    80101e4c <alltraps>

801019a1 <vector201>:
.globl vector201
vector201:
  pushl $0
801019a1:	6a 00                	push   $0x0
  pushl $201
801019a3:	68 c9 00 00 00       	push   $0xc9
  jmp alltraps
801019a8:	e9 9f 04 00 00       	jmp    80101e4c <alltraps>

801019ad <vector202>:
.globl vector202
vector202:
  pushl $0
801019ad:	6a 00                	push   $0x0
  pushl $202
801019af:	68 ca 00 00 00       	push   $0xca
  jmp alltraps
801019b4:	e9 93 04 00 00       	jmp    80101e4c <alltraps>

801019b9 <vector203>:
.globl vector203
vector203:
  pushl $0
801019b9:	6a 00                	push   $0x0
  pushl $203
801019bb:	68 cb 00 00 00       	push   $0xcb
  jmp alltraps
801019c0:	e9 87 04 00 00       	jmp    80101e4c <alltraps>

801019c5 <vector204>:
.globl vector204
vector204:
  pushl $0
801019c5:	6a 00                	push   $0x0
  pushl $204
801019c7:	68 cc 00 00 00       	push   $0xcc
  jmp alltraps
801019cc:	e9 7b 04 00 00       	jmp    80101e4c <alltraps>

801019d1 <vector205>:
.globl vector205
vector205:
  pushl $0
801019d1:	6a 00                	push   $0x0
  pushl $205
801019d3:	68 cd 00 00 00       	push   $0xcd
  jmp alltraps
801019d8:	e9 6f 04 00 00       	jmp    80101e4c <alltraps>

801019dd <vector206>:
.globl vector206
vector206:
  pushl $0
801019dd:	6a 00                	push   $0x0
  pushl $206
801019df:	68 ce 00 00 00       	push   $0xce
  jmp alltraps
801019e4:	e9 63 04 00 00       	jmp    80101e4c <alltraps>

801019e9 <vector207>:
.globl vector207
vector207:
  pushl $0
801019e9:	6a 00                	push   $0x0
  pushl $207
801019eb:	68 cf 00 00 00       	push   $0xcf
  jmp alltraps
801019f0:	e9 57 04 00 00       	jmp    80101e4c <alltraps>

801019f5 <vector208>:
.globl vector208
vector208:
  pushl $0
801019f5:	6a 00                	push   $0x0
  pushl $208
801019f7:	68 d0 00 00 00       	push   $0xd0
  jmp alltraps
801019fc:	e9 4b 04 00 00       	jmp    80101e4c <alltraps>

80101a01 <vector209>:
.globl vector209
vector209:
  pushl $0
80101a01:	6a 00                	push   $0x0
  pushl $209
80101a03:	68 d1 00 00 00       	push   $0xd1
  jmp alltraps
80101a08:	e9 3f 04 00 00       	jmp    80101e4c <alltraps>

80101a0d <vector210>:
.globl vector210
vector210:
  pushl $0
80101a0d:	6a 00                	push   $0x0
  pushl $210
80101a0f:	68 d2 00 00 00       	push   $0xd2
  jmp alltraps
80101a14:	e9 33 04 00 00       	jmp    80101e4c <alltraps>

80101a19 <vector211>:
.globl vector211
vector211:
  pushl $0
80101a19:	6a 00                	push   $0x0
  pushl $211
80101a1b:	68 d3 00 00 00       	push   $0xd3
  jmp alltraps
80101a20:	e9 27 04 00 00       	jmp    80101e4c <alltraps>

80101a25 <vector212>:
.globl vector212
vector212:
  pushl $0
80101a25:	6a 00                	push   $0x0
  pushl $212
80101a27:	68 d4 00 00 00       	push   $0xd4
  jmp alltraps
80101a2c:	e9 1b 04 00 00       	jmp    80101e4c <alltraps>

80101a31 <vector213>:
.globl vector213
vector213:
  pushl $0
80101a31:	6a 00                	push   $0x0
  pushl $213
80101a33:	68 d5 00 00 00       	push   $0xd5
  jmp alltraps
80101a38:	e9 0f 04 00 00       	jmp    80101e4c <alltraps>

80101a3d <vector214>:
.globl vector214
vector214:
  pushl $0
80101a3d:	6a 00                	push   $0x0
  pushl $214
80101a3f:	68 d6 00 00 00       	push   $0xd6
  jmp alltraps
80101a44:	e9 03 04 00 00       	jmp    80101e4c <alltraps>

80101a49 <vector215>:
.globl vector215
vector215:
  pushl $0
80101a49:	6a 00                	push   $0x0
  pushl $215
80101a4b:	68 d7 00 00 00       	push   $0xd7
  jmp alltraps
80101a50:	e9 f7 03 00 00       	jmp    80101e4c <alltraps>

80101a55 <vector216>:
.globl vector216
vector216:
  pushl $0
80101a55:	6a 00                	push   $0x0
  pushl $216
80101a57:	68 d8 00 00 00       	push   $0xd8
  jmp alltraps
80101a5c:	e9 eb 03 00 00       	jmp    80101e4c <alltraps>

80101a61 <vector217>:
.globl vector217
vector217:
  pushl $0
80101a61:	6a 00                	push   $0x0
  pushl $217
80101a63:	68 d9 00 00 00       	push   $0xd9
  jmp alltraps
80101a68:	e9 df 03 00 00       	jmp    80101e4c <alltraps>

80101a6d <vector218>:
.globl vector218
vector218:
  pushl $0
80101a6d:	6a 00                	push   $0x0
  pushl $218
80101a6f:	68 da 00 00 00       	push   $0xda
  jmp alltraps
80101a74:	e9 d3 03 00 00       	jmp    80101e4c <alltraps>

80101a79 <vector219>:
.globl vector219
vector219:
  pushl $0
80101a79:	6a 00                	push   $0x0
  pushl $219
80101a7b:	68 db 00 00 00       	push   $0xdb
  jmp alltraps
80101a80:	e9 c7 03 00 00       	jmp    80101e4c <alltraps>

80101a85 <vector220>:
.globl vector220
vector220:
  pushl $0
80101a85:	6a 00                	push   $0x0
  pushl $220
80101a87:	68 dc 00 00 00       	push   $0xdc
  jmp alltraps
80101a8c:	e9 bb 03 00 00       	jmp    80101e4c <alltraps>

80101a91 <vector221>:
.globl vector221
vector221:
  pushl $0
80101a91:	6a 00                	push   $0x0
  pushl $221
80101a93:	68 dd 00 00 00       	push   $0xdd
  jmp alltraps
80101a98:	e9 af 03 00 00       	jmp    80101e4c <alltraps>

80101a9d <vector222>:
.globl vector222
vector222:
  pushl $0
80101a9d:	6a 00                	push   $0x0
  pushl $222
80101a9f:	68 de 00 00 00       	push   $0xde
  jmp alltraps
80101aa4:	e9 a3 03 00 00       	jmp    80101e4c <alltraps>

80101aa9 <vector223>:
.globl vector223
vector223:
  pushl $0
80101aa9:	6a 00                	push   $0x0
  pushl $223
80101aab:	68 df 00 00 00       	push   $0xdf
  jmp alltraps
80101ab0:	e9 97 03 00 00       	jmp    80101e4c <alltraps>

80101ab5 <vector224>:
.globl vector224
vector224:
  pushl $0
80101ab5:	6a 00                	push   $0x0
  pushl $224
80101ab7:	68 e0 00 00 00       	push   $0xe0
  jmp alltraps
80101abc:	e9 8b 03 00 00       	jmp    80101e4c <alltraps>

80101ac1 <vector225>:
.globl vector225
vector225:
  pushl $0
80101ac1:	6a 00                	push   $0x0
  pushl $225
80101ac3:	68 e1 00 00 00       	push   $0xe1
  jmp alltraps
80101ac8:	e9 7f 03 00 00       	jmp    80101e4c <alltraps>

80101acd <vector226>:
.globl vector226
vector226:
  pushl $0
80101acd:	6a 00                	push   $0x0
  pushl $226
80101acf:	68 e2 00 00 00       	push   $0xe2
  jmp alltraps
80101ad4:	e9 73 03 00 00       	jmp    80101e4c <alltraps>

80101ad9 <vector227>:
.globl vector227
vector227:
  pushl $0
80101ad9:	6a 00                	push   $0x0
  pushl $227
80101adb:	68 e3 00 00 00       	push   $0xe3
  jmp alltraps
80101ae0:	e9 67 03 00 00       	jmp    80101e4c <alltraps>

80101ae5 <vector228>:
.globl vector228
vector228:
  pushl $0
80101ae5:	6a 00                	push   $0x0
  pushl $228
80101ae7:	68 e4 00 00 00       	push   $0xe4
  jmp alltraps
80101aec:	e9 5b 03 00 00       	jmp    80101e4c <alltraps>

80101af1 <vector229>:
.globl vector229
vector229:
  pushl $0
80101af1:	6a 00                	push   $0x0
  pushl $229
80101af3:	68 e5 00 00 00       	push   $0xe5
  jmp alltraps
80101af8:	e9 4f 03 00 00       	jmp    80101e4c <alltraps>

80101afd <vector230>:
.globl vector230
vector230:
  pushl $0
80101afd:	6a 00                	push   $0x0
  pushl $230
80101aff:	68 e6 00 00 00       	push   $0xe6
  jmp alltraps
80101b04:	e9 43 03 00 00       	jmp    80101e4c <alltraps>

80101b09 <vector231>:
.globl vector231
vector231:
  pushl $0
80101b09:	6a 00                	push   $0x0
  pushl $231
80101b0b:	68 e7 00 00 00       	push   $0xe7
  jmp alltraps
80101b10:	e9 37 03 00 00       	jmp    80101e4c <alltraps>

80101b15 <vector232>:
.globl vector232
vector232:
  pushl $0
80101b15:	6a 00                	push   $0x0
  pushl $232
80101b17:	68 e8 00 00 00       	push   $0xe8
  jmp alltraps
80101b1c:	e9 2b 03 00 00       	jmp    80101e4c <alltraps>

80101b21 <vector233>:
.globl vector233
vector233:
  pushl $0
80101b21:	6a 00                	push   $0x0
  pushl $233
80101b23:	68 e9 00 00 00       	push   $0xe9
  jmp alltraps
80101b28:	e9 1f 03 00 00       	jmp    80101e4c <alltraps>

80101b2d <vector234>:
.globl vector234
vector234:
  pushl $0
80101b2d:	6a 00                	push   $0x0
  pushl $234
80101b2f:	68 ea 00 00 00       	push   $0xea
  jmp alltraps
80101b34:	e9 13 03 00 00       	jmp    80101e4c <alltraps>

80101b39 <vector235>:
.globl vector235
vector235:
  pushl $0
80101b39:	6a 00                	push   $0x0
  pushl $235
80101b3b:	68 eb 00 00 00       	push   $0xeb
  jmp alltraps
80101b40:	e9 07 03 00 00       	jmp    80101e4c <alltraps>

80101b45 <vector236>:
.globl vector236
vector236:
  pushl $0
80101b45:	6a 00                	push   $0x0
  pushl $236
80101b47:	68 ec 00 00 00       	push   $0xec
  jmp alltraps
80101b4c:	e9 fb 02 00 00       	jmp    80101e4c <alltraps>

80101b51 <vector237>:
.globl vector237
vector237:
  pushl $0
80101b51:	6a 00                	push   $0x0
  pushl $237
80101b53:	68 ed 00 00 00       	push   $0xed
  jmp alltraps
80101b58:	e9 ef 02 00 00       	jmp    80101e4c <alltraps>

80101b5d <vector238>:
.globl vector238
vector238:
  pushl $0
80101b5d:	6a 00                	push   $0x0
  pushl $238
80101b5f:	68 ee 00 00 00       	push   $0xee
  jmp alltraps
80101b64:	e9 e3 02 00 00       	jmp    80101e4c <alltraps>

80101b69 <vector239>:
.globl vector239
vector239:
  pushl $0
80101b69:	6a 00                	push   $0x0
  pushl $239
80101b6b:	68 ef 00 00 00       	push   $0xef
  jmp alltraps
80101b70:	e9 d7 02 00 00       	jmp    80101e4c <alltraps>

80101b75 <vector240>:
.globl vector240
vector240:
  pushl $0
80101b75:	6a 00                	push   $0x0
  pushl $240
80101b77:	68 f0 00 00 00       	push   $0xf0
  jmp alltraps
80101b7c:	e9 cb 02 00 00       	jmp    80101e4c <alltraps>

80101b81 <vector241>:
.globl vector241
vector241:
  pushl $0
80101b81:	6a 00                	push   $0x0
  pushl $241
80101b83:	68 f1 00 00 00       	push   $0xf1
  jmp alltraps
80101b88:	e9 bf 02 00 00       	jmp    80101e4c <alltraps>

80101b8d <vector242>:
.globl vector242
vector242:
  pushl $0
80101b8d:	6a 00                	push   $0x0
  pushl $242
80101b8f:	68 f2 00 00 00       	push   $0xf2
  jmp alltraps
80101b94:	e9 b3 02 00 00       	jmp    80101e4c <alltraps>

80101b99 <vector243>:
.globl vector243
vector243:
  pushl $0
80101b99:	6a 00                	push   $0x0
  pushl $243
80101b9b:	68 f3 00 00 00       	push   $0xf3
  jmp alltraps
80101ba0:	e9 a7 02 00 00       	jmp    80101e4c <alltraps>

80101ba5 <vector244>:
.globl vector244
vector244:
  pushl $0
80101ba5:	6a 00                	push   $0x0
  pushl $244
80101ba7:	68 f4 00 00 00       	push   $0xf4
  jmp alltraps
80101bac:	e9 9b 02 00 00       	jmp    80101e4c <alltraps>

80101bb1 <vector245>:
.globl vector245
vector245:
  pushl $0
80101bb1:	6a 00                	push   $0x0
  pushl $245
80101bb3:	68 f5 00 00 00       	push   $0xf5
  jmp alltraps
80101bb8:	e9 8f 02 00 00       	jmp    80101e4c <alltraps>

80101bbd <vector246>:
.globl vector246
vector246:
  pushl $0
80101bbd:	6a 00                	push   $0x0
  pushl $246
80101bbf:	68 f6 00 00 00       	push   $0xf6
  jmp alltraps
80101bc4:	e9 83 02 00 00       	jmp    80101e4c <alltraps>

80101bc9 <vector247>:
.globl vector247
vector247:
  pushl $0
80101bc9:	6a 00                	push   $0x0
  pushl $247
80101bcb:	68 f7 00 00 00       	push   $0xf7
  jmp alltraps
80101bd0:	e9 77 02 00 00       	jmp    80101e4c <alltraps>

80101bd5 <vector248>:
.globl vector248
vector248:
  pushl $0
80101bd5:	6a 00                	push   $0x0
  pushl $248
80101bd7:	68 f8 00 00 00       	push   $0xf8
  jmp alltraps
80101bdc:	e9 6b 02 00 00       	jmp    80101e4c <alltraps>

80101be1 <vector249>:
.globl vector249
vector249:
  pushl $0
80101be1:	6a 00                	push   $0x0
  pushl $249
80101be3:	68 f9 00 00 00       	push   $0xf9
  jmp alltraps
80101be8:	e9 5f 02 00 00       	jmp    80101e4c <alltraps>

80101bed <vector250>:
.globl vector250
vector250:
  pushl $0
80101bed:	6a 00                	push   $0x0
  pushl $250
80101bef:	68 fa 00 00 00       	push   $0xfa
  jmp alltraps
80101bf4:	e9 53 02 00 00       	jmp    80101e4c <alltraps>

80101bf9 <vector251>:
.globl vector251
vector251:
  pushl $0
80101bf9:	6a 00                	push   $0x0
  pushl $251
80101bfb:	68 fb 00 00 00       	push   $0xfb
  jmp alltraps
80101c00:	e9 47 02 00 00       	jmp    80101e4c <alltraps>

80101c05 <vector252>:
.globl vector252
vector252:
  pushl $0
80101c05:	6a 00                	push   $0x0
  pushl $252
80101c07:	68 fc 00 00 00       	push   $0xfc
  jmp alltraps
80101c0c:	e9 3b 02 00 00       	jmp    80101e4c <alltraps>

80101c11 <vector253>:
.globl vector253
vector253:
  pushl $0
80101c11:	6a 00                	push   $0x0
  pushl $253
80101c13:	68 fd 00 00 00       	push   $0xfd
  jmp alltraps
80101c18:	e9 2f 02 00 00       	jmp    80101e4c <alltraps>

80101c1d <vector254>:
.globl vector254
vector254:
  pushl $0
80101c1d:	6a 00                	push   $0x0
  pushl $254
80101c1f:	68 fe 00 00 00       	push   $0xfe
  jmp alltraps
80101c24:	e9 23 02 00 00       	jmp    80101e4c <alltraps>

80101c29 <vector255>:
.globl vector255
vector255:
  pushl $0
80101c29:	6a 00                	push   $0x0
  pushl $255
80101c2b:	68 ff 00 00 00       	push   $0xff
  jmp alltraps
80101c30:	e9 17 02 00 00       	jmp    80101e4c <alltraps>

80101c35 <lidt>:

struct gatedesc;

static inline void
lidt(struct gatedesc *p, int size)
{
80101c35:	55                   	push   %ebp
80101c36:	89 e5                	mov    %esp,%ebp
80101c38:	83 ec 10             	sub    $0x10,%esp
  volatile ushort pd[3];

  pd[0] = size-1;
80101c3b:	8b 45 0c             	mov    0xc(%ebp),%eax
80101c3e:	83 e8 01             	sub    $0x1,%eax
80101c41:	66 89 45 fa          	mov    %ax,-0x6(%ebp)
  pd[1] = (uint)p;
80101c45:	8b 45 08             	mov    0x8(%ebp),%eax
80101c48:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  pd[2] = (uint)p >> 16;
80101c4c:	8b 45 08             	mov    0x8(%ebp),%eax
80101c4f:	c1 e8 10             	shr    $0x10,%eax
80101c52:	66 89 45 fe          	mov    %ax,-0x2(%ebp)

  asm volatile("lidt (%0)" : : "r" (pd));
80101c56:	8d 45 fa             	lea    -0x6(%ebp),%eax
80101c59:	0f 01 18             	lidtl  (%eax)
}
80101c5c:	c9                   	leave  
80101c5d:	c3                   	ret    

80101c5e <tvinit>:


// 中断描述符表初始化，将IDT中的每一个中断描述符都与vector.S中256个中断的地址相对应
void
tvinit(void)
{
80101c5e:	55                   	push   %ebp
80101c5f:	89 e5                	mov    %esp,%ebp
80101c61:	83 ec 10             	sub    $0x10,%esp
  int i;
  for(i = 0; i < 256; i++)
80101c64:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
80101c6b:	e9 c3 00 00 00       	jmp    80101d33 <tvinit+0xd5>
    SETGATE(idt[i], 0, SEG_KCODE<<3, vectors[i], 0);
80101c70:	8b 45 fc             	mov    -0x4(%ebp),%eax
80101c73:	8b 04 85 c2 45 10 80 	mov    -0x7fefba3e(,%eax,4),%eax
80101c7a:	89 c2                	mov    %eax,%edx
80101c7c:	8b 45 fc             	mov    -0x4(%ebp),%eax
80101c7f:	66 89 14 c5 80 60 10 	mov    %dx,-0x7fef9f80(,%eax,8)
80101c86:	80 
80101c87:	8b 45 fc             	mov    -0x4(%ebp),%eax
80101c8a:	66 c7 04 c5 82 60 10 	movw   $0x8,-0x7fef9f7e(,%eax,8)
80101c91:	80 08 00 
80101c94:	8b 45 fc             	mov    -0x4(%ebp),%eax
80101c97:	0f b6 14 c5 84 60 10 	movzbl -0x7fef9f7c(,%eax,8),%edx
80101c9e:	80 
80101c9f:	83 e2 e0             	and    $0xffffffe0,%edx
80101ca2:	88 14 c5 84 60 10 80 	mov    %dl,-0x7fef9f7c(,%eax,8)
80101ca9:	8b 45 fc             	mov    -0x4(%ebp),%eax
80101cac:	0f b6 14 c5 84 60 10 	movzbl -0x7fef9f7c(,%eax,8),%edx
80101cb3:	80 
80101cb4:	83 e2 1f             	and    $0x1f,%edx
80101cb7:	88 14 c5 84 60 10 80 	mov    %dl,-0x7fef9f7c(,%eax,8)
80101cbe:	8b 45 fc             	mov    -0x4(%ebp),%eax
80101cc1:	0f b6 14 c5 85 60 10 	movzbl -0x7fef9f7b(,%eax,8),%edx
80101cc8:	80 
80101cc9:	83 e2 f0             	and    $0xfffffff0,%edx
80101ccc:	83 ca 0e             	or     $0xe,%edx
80101ccf:	88 14 c5 85 60 10 80 	mov    %dl,-0x7fef9f7b(,%eax,8)
80101cd6:	8b 45 fc             	mov    -0x4(%ebp),%eax
80101cd9:	0f b6 14 c5 85 60 10 	movzbl -0x7fef9f7b(,%eax,8),%edx
80101ce0:	80 
80101ce1:	83 e2 ef             	and    $0xffffffef,%edx
80101ce4:	88 14 c5 85 60 10 80 	mov    %dl,-0x7fef9f7b(,%eax,8)
80101ceb:	8b 45 fc             	mov    -0x4(%ebp),%eax
80101cee:	0f b6 14 c5 85 60 10 	movzbl -0x7fef9f7b(,%eax,8),%edx
80101cf5:	80 
80101cf6:	83 e2 9f             	and    $0xffffff9f,%edx
80101cf9:	88 14 c5 85 60 10 80 	mov    %dl,-0x7fef9f7b(,%eax,8)
80101d00:	8b 45 fc             	mov    -0x4(%ebp),%eax
80101d03:	0f b6 14 c5 85 60 10 	movzbl -0x7fef9f7b(,%eax,8),%edx
80101d0a:	80 
80101d0b:	83 ca 80             	or     $0xffffff80,%edx
80101d0e:	88 14 c5 85 60 10 80 	mov    %dl,-0x7fef9f7b(,%eax,8)
80101d15:	8b 45 fc             	mov    -0x4(%ebp),%eax
80101d18:	8b 04 85 c2 45 10 80 	mov    -0x7fefba3e(,%eax,4),%eax
80101d1f:	c1 e8 10             	shr    $0x10,%eax
80101d22:	89 c2                	mov    %eax,%edx
80101d24:	8b 45 fc             	mov    -0x4(%ebp),%eax
80101d27:	66 89 14 c5 86 60 10 	mov    %dx,-0x7fef9f7a(,%eax,8)
80101d2e:	80 
// 中断描述符表初始化，将IDT中的每一个中断描述符都与vector.S中256个中断的地址相对应
void
tvinit(void)
{
  int i;
  for(i = 0; i < 256; i++)
80101d2f:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
80101d33:	81 7d fc ff 00 00 00 	cmpl   $0xff,-0x4(%ebp)
80101d3a:	0f 8e 30 ff ff ff    	jle    80101c70 <tvinit+0x12>
    SETGATE(idt[i], 0, SEG_KCODE<<3, vectors[i], 0);
  SETGATE(idt[T_SYSCALL], 1, SEG_KCODE<<3, vectors[T_SYSCALL], DPL_USER);
80101d40:	a1 c2 46 10 80       	mov    0x801046c2,%eax
80101d45:	66 a3 80 62 10 80    	mov    %ax,0x80106280
80101d4b:	66 c7 05 82 62 10 80 	movw   $0x8,0x80106282
80101d52:	08 00 
80101d54:	0f b6 05 84 62 10 80 	movzbl 0x80106284,%eax
80101d5b:	83 e0 e0             	and    $0xffffffe0,%eax
80101d5e:	a2 84 62 10 80       	mov    %al,0x80106284
80101d63:	0f b6 05 84 62 10 80 	movzbl 0x80106284,%eax
80101d6a:	83 e0 1f             	and    $0x1f,%eax
80101d6d:	a2 84 62 10 80       	mov    %al,0x80106284
80101d72:	0f b6 05 85 62 10 80 	movzbl 0x80106285,%eax
80101d79:	83 c8 0f             	or     $0xf,%eax
80101d7c:	a2 85 62 10 80       	mov    %al,0x80106285
80101d81:	0f b6 05 85 62 10 80 	movzbl 0x80106285,%eax
80101d88:	83 e0 ef             	and    $0xffffffef,%eax
80101d8b:	a2 85 62 10 80       	mov    %al,0x80106285
80101d90:	0f b6 05 85 62 10 80 	movzbl 0x80106285,%eax
80101d97:	83 c8 60             	or     $0x60,%eax
80101d9a:	a2 85 62 10 80       	mov    %al,0x80106285
80101d9f:	0f b6 05 85 62 10 80 	movzbl 0x80106285,%eax
80101da6:	83 c8 80             	or     $0xffffff80,%eax
80101da9:	a2 85 62 10 80       	mov    %al,0x80106285
80101dae:	a1 c2 46 10 80       	mov    0x801046c2,%eax
80101db3:	c1 e8 10             	shr    $0x10,%eax
80101db6:	66 a3 86 62 10 80    	mov    %ax,0x80106286
}
80101dbc:	c9                   	leave  
80101dbd:	c3                   	ret    

80101dbe <printidt>:

// 打印一些当前IDT内中的一些信息
void 
printidt(void)
{
80101dbe:	55                   	push   %ebp
80101dbf:	89 e5                	mov    %esp,%ebp
80101dc1:	83 ec 18             	sub    $0x18,%esp
  int i = 0;
80101dc4:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  for(;i<=10;i++){
80101dcb:	eb 48                	jmp    80101e15 <printidt+0x57>
	cprintf("IDT %d: offset 31~16:%d\n", i, idt[i].off_31_16);
80101dcd:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101dd0:	0f b7 04 c5 86 60 10 	movzwl -0x7fef9f7a(,%eax,8),%eax
80101dd7:	80 
80101dd8:	0f b7 c0             	movzwl %ax,%eax
80101ddb:	83 ec 04             	sub    $0x4,%esp
80101dde:	50                   	push   %eax
80101ddf:	ff 75 f4             	pushl  -0xc(%ebp)
80101de2:	68 af 20 10 80       	push   $0x801020af
80101de7:	e8 9d e3 ff ff       	call   80100189 <cprintf>
80101dec:	83 c4 10             	add    $0x10,%esp
	cprintf("IDT %d: offset 15~0:%d\n", i, idt[i].off_15_0);
80101def:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101df2:	0f b7 04 c5 80 60 10 	movzwl -0x7fef9f80(,%eax,8),%eax
80101df9:	80 
80101dfa:	0f b7 c0             	movzwl %ax,%eax
80101dfd:	83 ec 04             	sub    $0x4,%esp
80101e00:	50                   	push   %eax
80101e01:	ff 75 f4             	pushl  -0xc(%ebp)
80101e04:	68 c8 20 10 80       	push   $0x801020c8
80101e09:	e8 7b e3 ff ff       	call   80100189 <cprintf>
80101e0e:	83 c4 10             	add    $0x10,%esp
// 打印一些当前IDT内中的一些信息
void 
printidt(void)
{
  int i = 0;
  for(;i<=10;i++){
80101e11:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80101e15:	83 7d f4 0a          	cmpl   $0xa,-0xc(%ebp)
80101e19:	7e b2                	jle    80101dcd <printidt+0xf>
	cprintf("IDT %d: offset 31~16:%d\n", i, idt[i].off_31_16);
	cprintf("IDT %d: offset 15~0:%d\n", i, idt[i].off_15_0);
  }
}
80101e1b:	c9                   	leave  
80101e1c:	c3                   	ret    

80101e1d <idtinit>:

// 加载idt，调用内联汇编
void
idtinit(void)
{
80101e1d:	55                   	push   %ebp
80101e1e:	89 e5                	mov    %esp,%ebp
  lidt(idt, sizeof(idt));
80101e20:	68 00 08 00 00       	push   $0x800
80101e25:	68 80 60 10 80       	push   $0x80106080
80101e2a:	e8 06 fe ff ff       	call   80101c35 <lidt>
80101e2f:	83 c4 08             	add    $0x8,%esp
}
80101e32:	c9                   	leave  
80101e33:	c3                   	ret    

80101e34 <trap>:

// 中断处理程序,目前什么都不做
void
trap(struct trapframe *tf)
{
80101e34:	55                   	push   %ebp
80101e35:	89 e5                	mov    %esp,%ebp
80101e37:	83 ec 08             	sub    $0x8,%esp
  uint st, data, c;
   if(tf->trapno == (T_IRQ0 + IRQ_KBD)){
80101e3a:	8b 45 08             	mov    0x8(%ebp),%eax
80101e3d:	8b 40 30             	mov    0x30(%eax),%eax
80101e40:	83 f8 21             	cmp    $0x21,%eax
80101e43:	75 05                	jne    80101e4a <trap+0x16>
       kbdintr();
80101e45:	e8 12 ea ff ff       	call   8010085c <kbdintr>
  }	
}
80101e4a:	c9                   	leave  
80101e4b:	c3                   	ret    

80101e4c <alltraps>:
  # vectors.S 会把所有的中断都掉转到这里
.globl alltraps

alltraps:
  # 建立一个中断帧，保护现场
  pushl %ds
80101e4c:	1e                   	push   %ds
  pushl %es
80101e4d:	06                   	push   %es
  pushl %fs
80101e4e:	0f a0                	push   %fs
  pushl %gs
80101e50:	0f a8                	push   %gs
  pushal
80101e52:	60                   	pusha  
  
  # 设置数据段
  movw $(SEG_KDATA<<3), %ax
80101e53:	66 b8 10 00          	mov    $0x10,%ax
  movw %ax, %ds
80101e57:	8e d8                	mov    %eax,%ds
  movw %ax, %es
80101e59:	8e c0                	mov    %eax,%es

  # 调用trap函数，执行中断服务程序，目前针对所有中断都不做任何处理
  # 定义在了trap.c中，同时压栈esp，这里的esp就代表了trap的参数tf，也就是当前的中断帧
  pushl %esp
80101e5b:	54                   	push   %esp
  call trap
80101e5c:	e8 d3 ff ff ff       	call   80101e34 <trap>
  addl $4, %esp
80101e61:	83 c4 04             	add    $0x4,%esp

80101e64 <trapret>:

  # 执行完中断服务程序以后开始恢复现场
.globl trapret
trapret:
  popal
80101e64:	61                   	popa   
  popl %gs
80101e65:	0f a9                	pop    %gs
  popl %fs
80101e67:	0f a1                	pop    %fs
  popl %es
80101e69:	07                   	pop    %es
  popl %ds
80101e6a:	1f                   	pop    %ds
  addl $0x8, %esp  # 中断号以及错误号
80101e6b:	83 c4 08             	add    $0x8,%esp
  iret
80101e6e:	cf                   	iret   

80101e6f <inb>:
// Routines to let C code use special x86 instructions.

static inline uchar
inb(ushort port)
{
80101e6f:	55                   	push   %ebp
80101e70:	89 e5                	mov    %esp,%ebp
80101e72:	83 ec 14             	sub    $0x14,%esp
80101e75:	8b 45 08             	mov    0x8(%ebp),%eax
80101e78:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
  uchar data;

  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80101e7c:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
80101e80:	89 c2                	mov    %eax,%edx
80101e82:	ec                   	in     (%dx),%al
80101e83:	88 45 ff             	mov    %al,-0x1(%ebp)
  return data;
80101e86:	0f b6 45 ff          	movzbl -0x1(%ebp),%eax
}
80101e8a:	c9                   	leave  
80101e8b:	c3                   	ret    

80101e8c <outb>:
               "memory", "cc");
}

static inline void
outb(ushort port, uchar data)
{
80101e8c:	55                   	push   %ebp
80101e8d:	89 e5                	mov    %esp,%ebp
80101e8f:	83 ec 08             	sub    $0x8,%esp
80101e92:	8b 55 08             	mov    0x8(%ebp),%edx
80101e95:	8b 45 0c             	mov    0xc(%ebp),%eax
80101e98:	66 89 55 fc          	mov    %dx,-0x4(%ebp)
80101e9c:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80101e9f:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
80101ea3:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
80101ea7:	ee                   	out    %al,(%dx)
}
80101ea8:	c9                   	leave  
80101ea9:	c3                   	ret    

80101eaa <uartputc>:

#define COM1    0x3f8

void
uartputc(int c)
{
80101eaa:	55                   	push   %ebp
80101eab:	89 e5                	mov    %esp,%ebp
80101ead:	83 ec 10             	sub    $0x10,%esp
  int i;
  for(i = 0; i < 128 && !(inb(COM1+5) & 0x20); i++)
80101eb0:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
80101eb7:	eb 18                	jmp    80101ed1 <uartputc+0x27>
  outb(COM1+0, c);
80101eb9:	8b 45 08             	mov    0x8(%ebp),%eax
80101ebc:	0f b6 c0             	movzbl %al,%eax
80101ebf:	50                   	push   %eax
80101ec0:	68 f8 03 00 00       	push   $0x3f8
80101ec5:	e8 c2 ff ff ff       	call   80101e8c <outb>
80101eca:	83 c4 08             	add    $0x8,%esp

void
uartputc(int c)
{
  int i;
  for(i = 0; i < 128 && !(inb(COM1+5) & 0x20); i++)
80101ecd:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
80101ed1:	83 7d fc 7f          	cmpl   $0x7f,-0x4(%ebp)
80101ed5:	7f 17                	jg     80101eee <uartputc+0x44>
80101ed7:	68 fd 03 00 00       	push   $0x3fd
80101edc:	e8 8e ff ff ff       	call   80101e6f <inb>
80101ee1:	83 c4 04             	add    $0x4,%esp
80101ee4:	0f b6 c0             	movzbl %al,%eax
80101ee7:	83 e0 20             	and    $0x20,%eax
80101eea:	85 c0                	test   %eax,%eax
80101eec:	74 cb                	je     80101eb9 <uartputc+0xf>
  outb(COM1+0, c);
}
80101eee:	c9                   	leave  
80101eef:	c3                   	ret    
