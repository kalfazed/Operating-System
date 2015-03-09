
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
8010004e:	68 0c 1e 10 80       	push   $0x80101e0c
80100053:	e8 31 01 00 00       	call   80100189 <cprintf>
80100058:	83 c4 10             	add    $0x10,%esp
  
  kinit(end, P2V(4*1024*1024));  // 物理页的分配
8010005b:	83 ec 08             	sub    $0x8,%esp
8010005e:	68 00 00 40 80       	push   $0x80400000
80100063:	68 80 68 10 80       	push   $0x80106880
80100068:	e8 62 05 00 00       	call   801005cf <kinit>
8010006d:	83 c4 10             	add    $0x10,%esp
  kvmalloc(); 			 // 内核页表
80100070:	e8 f3 0d 00 00       	call   80100e68 <kvmalloc>
  seginit();   			 // 初始化段，这里对段的初始化是对当前cpu的gdt的初始化
80100075:	e8 78 07 00 00       	call   801007f2 <seginit>
//  segshow();   		 // 打印一些段的信息，用来验证

  picinit(); 			 // 初始化中断控制器8259A 
8010007a:	e8 8e 0e 00 00       	call   80100f0d <picinit>
  ioapicinit(); 		 // 初始化IOAAPIC中断控制器
8010007f:	e8 a2 0f 00 00       	call   80101026 <ioapicinit>
  consoleinit(); 		 // 初始化控制台
80100084:	e8 be 03 00 00       	call   80100447 <consoleinit>

  tvinit(); 			 // 初始化idt，扩充idt中中断描述符的内容
80100089:	e8 eb 1a 00 00       	call   80101b79 <tvinit>
  idtinit(); 			 // 加载idt
8010008e:	e8 a5 1c 00 00       	call   80101d38 <idtinit>
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
8010025f:	c7 45 ec 1f 1e 10 80 	movl   $0x80101e1f,-0x14(%ebp)
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
80100405:	e8 bb 19 00 00       	call   80101dc5 <uartputc>
8010040a:	83 c4 10             	add    $0x10,%esp
8010040d:	83 ec 0c             	sub    $0xc,%esp
80100410:	6a 20                	push   $0x20
80100412:	e8 ae 19 00 00       	call   80101dc5 <uartputc>
80100417:	83 c4 10             	add    $0x10,%esp
8010041a:	83 ec 0c             	sub    $0xc,%esp
8010041d:	6a 08                	push   $0x8
8010041f:	e8 a1 19 00 00       	call   80101dc5 <uartputc>
80100424:	83 c4 10             	add    $0x10,%esp
80100427:	eb 0e                	jmp    80100437 <consputc+0x46>
  } else
    uartputc(c);
80100429:	83 ec 0c             	sub    $0xc,%esp
8010042c:	ff 75 08             	pushl  0x8(%ebp)
8010042f:	e8 91 19 00 00       	call   80101dc5 <uartputc>
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
80100452:	e8 8a 0a 00 00       	call   80100ee1 <picenable>
80100457:	83 c4 10             	add    $0x10,%esp
  ioapicenable(IRQ_KBD, 0);
8010045a:	83 ec 08             	sub    $0x8,%esp
8010045d:	6a 00                	push   $0x0
8010045f:	6a 01                	push   $0x1
80100461:	e8 31 0c 00 00       	call   80101097 <ioapicenable>
80100466:	83 c4 10             	add    $0x10,%esp
}
80100469:	c9                   	leave  
8010046a:	c3                   	ret    

8010046b <consoleintr>:
  uint e;  // Edit index
} input;

void
consoleintr(int (*getc)(void))
{
8010046b:	55                   	push   %ebp
8010046c:	89 e5                	mov    %esp,%ebp
8010046e:	83 ec 18             	sub    $0x18,%esp
  int c;

  while((c = getc()) >= 0){
80100471:	8b 45 08             	mov    0x8(%ebp),%eax
80100474:	ff d0                	call   *%eax
80100476:	89 45 f4             	mov    %eax,-0xc(%ebp)
80100479:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
8010047d:	78 2b                	js     801004aa <consoleintr+0x3f>
      if(c != 0 && input.e-input.r < INPUT_BUF)
8010047f:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80100483:	74 24                	je     801004a9 <consoleintr+0x3e>
80100485:	8b 15 c8 5f 10 80    	mov    0x80105fc8,%edx
8010048b:	a1 c0 5f 10 80       	mov    0x80105fc0,%eax
80100490:	29 c2                	sub    %eax,%edx
80100492:	89 d0                	mov    %edx,%eax
80100494:	83 f8 7f             	cmp    $0x7f,%eax
80100497:	77 10                	ja     801004a9 <consoleintr+0x3e>
	  cprintf("This is a keyboard interrupt\n");
80100499:	83 ec 0c             	sub    $0xc,%esp
8010049c:	68 26 1e 10 80       	push   $0x80101e26
801004a1:	e8 e3 fc ff ff       	call   80100189 <cprintf>
801004a6:	83 c4 10             	add    $0x10,%esp
      break;
801004a9:	90                   	nop
  }
}
801004aa:	c9                   	leave  
801004ab:	c3                   	ret    

801004ac <stosb>:
               "cc");
}

static inline void
stosb(void *addr, int data, int cnt)
{
801004ac:	55                   	push   %ebp
801004ad:	89 e5                	mov    %esp,%ebp
801004af:	57                   	push   %edi
801004b0:	53                   	push   %ebx
  asm volatile("cld; rep stosb" :
801004b1:	8b 4d 08             	mov    0x8(%ebp),%ecx
801004b4:	8b 55 10             	mov    0x10(%ebp),%edx
801004b7:	8b 45 0c             	mov    0xc(%ebp),%eax
801004ba:	89 cb                	mov    %ecx,%ebx
801004bc:	89 df                	mov    %ebx,%edi
801004be:	89 d1                	mov    %edx,%ecx
801004c0:	fc                   	cld    
801004c1:	f3 aa                	rep stos %al,%es:(%edi)
801004c3:	89 ca                	mov    %ecx,%edx
801004c5:	89 fb                	mov    %edi,%ebx
801004c7:	89 5d 08             	mov    %ebx,0x8(%ebp)
801004ca:	89 55 10             	mov    %edx,0x10(%ebp)
               "=D" (addr), "=c" (cnt) :
               "0" (addr), "1" (cnt), "a" (data) :
               "memory", "cc");
}
801004cd:	5b                   	pop    %ebx
801004ce:	5f                   	pop    %edi
801004cf:	5d                   	pop    %ebp
801004d0:	c3                   	ret    

801004d1 <stosl>:

static inline void
stosl(void *addr, int data, int cnt)
{
801004d1:	55                   	push   %ebp
801004d2:	89 e5                	mov    %esp,%ebp
801004d4:	57                   	push   %edi
801004d5:	53                   	push   %ebx
  asm volatile("cld; rep stosl" :
801004d6:	8b 4d 08             	mov    0x8(%ebp),%ecx
801004d9:	8b 55 10             	mov    0x10(%ebp),%edx
801004dc:	8b 45 0c             	mov    0xc(%ebp),%eax
801004df:	89 cb                	mov    %ecx,%ebx
801004e1:	89 df                	mov    %ebx,%edi
801004e3:	89 d1                	mov    %edx,%ecx
801004e5:	fc                   	cld    
801004e6:	f3 ab                	rep stos %eax,%es:(%edi)
801004e8:	89 ca                	mov    %ecx,%edx
801004ea:	89 fb                	mov    %edi,%ebx
801004ec:	89 5d 08             	mov    %ebx,0x8(%ebp)
801004ef:	89 55 10             	mov    %edx,0x10(%ebp)
               "=D" (addr), "=c" (cnt) :
               "0" (addr), "1" (cnt), "a" (data) :
               "memory", "cc");
}
801004f2:	5b                   	pop    %ebx
801004f3:	5f                   	pop    %edi
801004f4:	5d                   	pop    %ebp
801004f5:	c3                   	ret    

801004f6 <memset>:
#include "types.h"
#include "x86.h"

void*
memset(void *dst, int c, uint n)
{
801004f6:	55                   	push   %ebp
801004f7:	89 e5                	mov    %esp,%ebp
  if ((int)dst%4 == 0 && n%4 == 0){
801004f9:	8b 45 08             	mov    0x8(%ebp),%eax
801004fc:	83 e0 03             	and    $0x3,%eax
801004ff:	85 c0                	test   %eax,%eax
80100501:	75 43                	jne    80100546 <memset+0x50>
80100503:	8b 45 10             	mov    0x10(%ebp),%eax
80100506:	83 e0 03             	and    $0x3,%eax
80100509:	85 c0                	test   %eax,%eax
8010050b:	75 39                	jne    80100546 <memset+0x50>
    c &= 0xFF;
8010050d:	81 65 0c ff 00 00 00 	andl   $0xff,0xc(%ebp)
    stosl(dst, (c<<24)|(c<<16)|(c<<8)|c, n/4);
80100514:	8b 45 10             	mov    0x10(%ebp),%eax
80100517:	c1 e8 02             	shr    $0x2,%eax
8010051a:	89 c1                	mov    %eax,%ecx
8010051c:	8b 45 0c             	mov    0xc(%ebp),%eax
8010051f:	c1 e0 18             	shl    $0x18,%eax
80100522:	89 c2                	mov    %eax,%edx
80100524:	8b 45 0c             	mov    0xc(%ebp),%eax
80100527:	c1 e0 10             	shl    $0x10,%eax
8010052a:	09 c2                	or     %eax,%edx
8010052c:	8b 45 0c             	mov    0xc(%ebp),%eax
8010052f:	c1 e0 08             	shl    $0x8,%eax
80100532:	09 d0                	or     %edx,%eax
80100534:	0b 45 0c             	or     0xc(%ebp),%eax
80100537:	51                   	push   %ecx
80100538:	50                   	push   %eax
80100539:	ff 75 08             	pushl  0x8(%ebp)
8010053c:	e8 90 ff ff ff       	call   801004d1 <stosl>
80100541:	83 c4 0c             	add    $0xc,%esp
80100544:	eb 12                	jmp    80100558 <memset+0x62>
  } else
    stosb(dst, c, n);
80100546:	8b 45 10             	mov    0x10(%ebp),%eax
80100549:	50                   	push   %eax
8010054a:	ff 75 0c             	pushl  0xc(%ebp)
8010054d:	ff 75 08             	pushl  0x8(%ebp)
80100550:	e8 57 ff ff ff       	call   801004ac <stosb>
80100555:	83 c4 0c             	add    $0xc,%esp
  return dst;
80100558:	8b 45 08             	mov    0x8(%ebp),%eax
}
8010055b:	c9                   	leave  
8010055c:	c3                   	ret    

8010055d <kfree>:


extern char end[]; // first address after kernel loaded from ELF file

void kfree(char *v)
{
8010055d:	55                   	push   %ebp
8010055e:	89 e5                	mov    %esp,%ebp
80100560:	83 ec 18             	sub    $0x18,%esp
  struct run *r;

  memset(v, 1, PGSIZE);
80100563:	83 ec 04             	sub    $0x4,%esp
80100566:	68 00 10 00 00       	push   $0x1000
8010056b:	6a 01                	push   $0x1
8010056d:	ff 75 08             	pushl  0x8(%ebp)
80100570:	e8 81 ff ff ff       	call   801004f6 <memset>
80100575:	83 c4 10             	add    $0x10,%esp

  r = (struct run*)v;
80100578:	8b 45 08             	mov    0x8(%ebp),%eax
8010057b:	89 45 f4             	mov    %eax,-0xc(%ebp)
  r->next = kmem.freelist;
8010057e:	8b 15 cc 5f 10 80    	mov    0x80105fcc,%edx
80100584:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100587:	89 10                	mov    %edx,(%eax)
  kmem.freelist = r;
80100589:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010058c:	a3 cc 5f 10 80       	mov    %eax,0x80105fcc

}
80100591:	c9                   	leave  
80100592:	c3                   	ret    

80100593 <freerange>:

void freerange(void *vstart, void *vend)
{
80100593:	55                   	push   %ebp
80100594:	89 e5                	mov    %esp,%ebp
80100596:	83 ec 18             	sub    $0x18,%esp
  char *p;
  p = (char*)PGROUNDUP((uint)vstart);
80100599:	8b 45 08             	mov    0x8(%ebp),%eax
8010059c:	05 ff 0f 00 00       	add    $0xfff,%eax
801005a1:	25 00 f0 ff ff       	and    $0xfffff000,%eax
801005a6:	89 45 f4             	mov    %eax,-0xc(%ebp)
  for(; p + PGSIZE <= (char*)vend; p += PGSIZE)
801005a9:	eb 15                	jmp    801005c0 <freerange+0x2d>
    kfree(p);
801005ab:	83 ec 0c             	sub    $0xc,%esp
801005ae:	ff 75 f4             	pushl  -0xc(%ebp)
801005b1:	e8 a7 ff ff ff       	call   8010055d <kfree>
801005b6:	83 c4 10             	add    $0x10,%esp

void freerange(void *vstart, void *vend)
{
  char *p;
  p = (char*)PGROUNDUP((uint)vstart);
  for(; p + PGSIZE <= (char*)vend; p += PGSIZE)
801005b9:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
801005c0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801005c3:	05 00 10 00 00       	add    $0x1000,%eax
801005c8:	3b 45 0c             	cmp    0xc(%ebp),%eax
801005cb:	76 de                	jbe    801005ab <freerange+0x18>
    kfree(p);
}
801005cd:	c9                   	leave  
801005ce:	c3                   	ret    

801005cf <kinit>:


void kinit(void *vstart, void *vend)
{
801005cf:	55                   	push   %ebp
801005d0:	89 e5                	mov    %esp,%ebp
801005d2:	83 ec 08             	sub    $0x8,%esp
  freerange(vstart, vend);
801005d5:	83 ec 08             	sub    $0x8,%esp
801005d8:	ff 75 0c             	pushl  0xc(%ebp)
801005db:	ff 75 08             	pushl  0x8(%ebp)
801005de:	e8 b0 ff ff ff       	call   80100593 <freerange>
801005e3:	83 c4 10             	add    $0x10,%esp
}
801005e6:	c9                   	leave  
801005e7:	c3                   	ret    

801005e8 <kalloc>:

//分配一个4096字节的物理内存页，返回内核可以使用的指针。如果无法分配，则返回0
char* kalloc(void)
{
801005e8:	55                   	push   %ebp
801005e9:	89 e5                	mov    %esp,%ebp
801005eb:	83 ec 10             	sub    $0x10,%esp
  struct run *r;
  r = kmem.freelist;
801005ee:	a1 cc 5f 10 80       	mov    0x80105fcc,%eax
801005f3:	89 45 fc             	mov    %eax,-0x4(%ebp)
  if(r)
801005f6:	83 7d fc 00          	cmpl   $0x0,-0x4(%ebp)
801005fa:	74 0a                	je     80100606 <kalloc+0x1e>
    kmem.freelist = r->next;
801005fc:	8b 45 fc             	mov    -0x4(%ebp),%eax
801005ff:	8b 00                	mov    (%eax),%eax
80100601:	a3 cc 5f 10 80       	mov    %eax,0x80105fcc
  return (char*)r;
80100606:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80100609:	c9                   	leave  
8010060a:	c3                   	ret    

8010060b <inb>:
// Routines to let C code use special x86 instructions.

static inline uchar
inb(ushort port)
{
8010060b:	55                   	push   %ebp
8010060c:	89 e5                	mov    %esp,%ebp
8010060e:	83 ec 14             	sub    $0x14,%esp
80100611:	8b 45 08             	mov    0x8(%ebp),%eax
80100614:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
  uchar data;

  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80100618:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
8010061c:	89 c2                	mov    %eax,%edx
8010061e:	ec                   	in     (%dx),%al
8010061f:	88 45 ff             	mov    %al,-0x1(%ebp)
  return data;
80100622:	0f b6 45 ff          	movzbl -0x1(%ebp),%eax
}
80100626:	c9                   	leave  
80100627:	c3                   	ret    

80100628 <kbdgetc>:
#include "defs.h"
#include "kbd.h"

int
kbdgetc(void)
{
80100628:	55                   	push   %ebp
80100629:	89 e5                	mov    %esp,%ebp
8010062b:	83 ec 10             	sub    $0x10,%esp
  static uchar *charcode[4] = {
    normalmap, shiftmap, ctlmap, ctlmap
  };
  uint st, data, c;

  st = inb(KBSTATP);
8010062e:	6a 64                	push   $0x64
80100630:	e8 d6 ff ff ff       	call   8010060b <inb>
80100635:	83 c4 04             	add    $0x4,%esp
80100638:	0f b6 c0             	movzbl %al,%eax
8010063b:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if((st & KBS_DIB) == 0)
8010063e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100641:	83 e0 01             	and    $0x1,%eax
80100644:	85 c0                	test   %eax,%eax
80100646:	75 0a                	jne    80100652 <kbdgetc+0x2a>
    return -1;
80100648:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010064d:	e9 23 01 00 00       	jmp    80100775 <kbdgetc+0x14d>
  data = inb(KBDATAP);
80100652:	6a 60                	push   $0x60
80100654:	e8 b2 ff ff ff       	call   8010060b <inb>
80100659:	83 c4 04             	add    $0x4,%esp
8010065c:	0f b6 c0             	movzbl %al,%eax
8010065f:	89 45 fc             	mov    %eax,-0x4(%ebp)

  if(data == 0xE0){
80100662:	81 7d fc e0 00 00 00 	cmpl   $0xe0,-0x4(%ebp)
80100669:	75 17                	jne    80100682 <kbdgetc+0x5a>
    shift |= E0ESC;
8010066b:	a1 00 4f 10 80       	mov    0x80104f00,%eax
80100670:	83 c8 40             	or     $0x40,%eax
80100673:	a3 00 4f 10 80       	mov    %eax,0x80104f00
    return 0;
80100678:	b8 00 00 00 00       	mov    $0x0,%eax
8010067d:	e9 f3 00 00 00       	jmp    80100775 <kbdgetc+0x14d>
  } else if(data & 0x80){
80100682:	8b 45 fc             	mov    -0x4(%ebp),%eax
80100685:	25 80 00 00 00       	and    $0x80,%eax
8010068a:	85 c0                	test   %eax,%eax
8010068c:	74 45                	je     801006d3 <kbdgetc+0xab>
    // Key released
    data = (shift & E0ESC ? data : data & 0x7F);
8010068e:	a1 00 4f 10 80       	mov    0x80104f00,%eax
80100693:	83 e0 40             	and    $0x40,%eax
80100696:	85 c0                	test   %eax,%eax
80100698:	75 08                	jne    801006a2 <kbdgetc+0x7a>
8010069a:	8b 45 fc             	mov    -0x4(%ebp),%eax
8010069d:	83 e0 7f             	and    $0x7f,%eax
801006a0:	eb 03                	jmp    801006a5 <kbdgetc+0x7d>
801006a2:	8b 45 fc             	mov    -0x4(%ebp),%eax
801006a5:	89 45 fc             	mov    %eax,-0x4(%ebp)
    shift &= ~(shiftcode[data] | E0ESC);
801006a8:	8b 45 fc             	mov    -0x4(%ebp),%eax
801006ab:	05 40 40 10 80       	add    $0x80104040,%eax
801006b0:	0f b6 00             	movzbl (%eax),%eax
801006b3:	83 c8 40             	or     $0x40,%eax
801006b6:	0f b6 c0             	movzbl %al,%eax
801006b9:	f7 d0                	not    %eax
801006bb:	89 c2                	mov    %eax,%edx
801006bd:	a1 00 4f 10 80       	mov    0x80104f00,%eax
801006c2:	21 d0                	and    %edx,%eax
801006c4:	a3 00 4f 10 80       	mov    %eax,0x80104f00
    return 0;
801006c9:	b8 00 00 00 00       	mov    $0x0,%eax
801006ce:	e9 a2 00 00 00       	jmp    80100775 <kbdgetc+0x14d>
  } else if(shift & E0ESC){
801006d3:	a1 00 4f 10 80       	mov    0x80104f00,%eax
801006d8:	83 e0 40             	and    $0x40,%eax
801006db:	85 c0                	test   %eax,%eax
801006dd:	74 14                	je     801006f3 <kbdgetc+0xcb>
    // Last character was an E0 escape; or with 0x80
    data |= 0x80;
801006df:	81 4d fc 80 00 00 00 	orl    $0x80,-0x4(%ebp)
    shift &= ~E0ESC;
801006e6:	a1 00 4f 10 80       	mov    0x80104f00,%eax
801006eb:	83 e0 bf             	and    $0xffffffbf,%eax
801006ee:	a3 00 4f 10 80       	mov    %eax,0x80104f00
  }

  shift |= shiftcode[data];
801006f3:	8b 45 fc             	mov    -0x4(%ebp),%eax
801006f6:	05 40 40 10 80       	add    $0x80104040,%eax
801006fb:	0f b6 00             	movzbl (%eax),%eax
801006fe:	0f b6 d0             	movzbl %al,%edx
80100701:	a1 00 4f 10 80       	mov    0x80104f00,%eax
80100706:	09 d0                	or     %edx,%eax
80100708:	a3 00 4f 10 80       	mov    %eax,0x80104f00
  shift ^= togglecode[data];
8010070d:	8b 45 fc             	mov    -0x4(%ebp),%eax
80100710:	05 40 41 10 80       	add    $0x80104140,%eax
80100715:	0f b6 00             	movzbl (%eax),%eax
80100718:	0f b6 d0             	movzbl %al,%edx
8010071b:	a1 00 4f 10 80       	mov    0x80104f00,%eax
80100720:	31 d0                	xor    %edx,%eax
80100722:	a3 00 4f 10 80       	mov    %eax,0x80104f00
  c = charcode[shift & (CTL | SHIFT)][data];
80100727:	a1 00 4f 10 80       	mov    0x80104f00,%eax
8010072c:	83 e0 03             	and    $0x3,%eax
8010072f:	8b 14 85 40 45 10 80 	mov    -0x7fefbac0(,%eax,4),%edx
80100736:	8b 45 fc             	mov    -0x4(%ebp),%eax
80100739:	01 d0                	add    %edx,%eax
8010073b:	0f b6 00             	movzbl (%eax),%eax
8010073e:	0f b6 c0             	movzbl %al,%eax
80100741:	89 45 f8             	mov    %eax,-0x8(%ebp)
  if(shift & CAPSLOCK){
80100744:	a1 00 4f 10 80       	mov    0x80104f00,%eax
80100749:	83 e0 08             	and    $0x8,%eax
8010074c:	85 c0                	test   %eax,%eax
8010074e:	74 22                	je     80100772 <kbdgetc+0x14a>
    if('a' <= c && c <= 'z')
80100750:	83 7d f8 60          	cmpl   $0x60,-0x8(%ebp)
80100754:	76 0c                	jbe    80100762 <kbdgetc+0x13a>
80100756:	83 7d f8 7a          	cmpl   $0x7a,-0x8(%ebp)
8010075a:	77 06                	ja     80100762 <kbdgetc+0x13a>
      c += 'A' - 'a';
8010075c:	83 6d f8 20          	subl   $0x20,-0x8(%ebp)
80100760:	eb 10                	jmp    80100772 <kbdgetc+0x14a>
    else if('A' <= c && c <= 'Z')
80100762:	83 7d f8 40          	cmpl   $0x40,-0x8(%ebp)
80100766:	76 0a                	jbe    80100772 <kbdgetc+0x14a>
80100768:	83 7d f8 5a          	cmpl   $0x5a,-0x8(%ebp)
8010076c:	77 04                	ja     80100772 <kbdgetc+0x14a>
      c += 'a' - 'A';
8010076e:	83 45 f8 20          	addl   $0x20,-0x8(%ebp)
  }
  return c;
80100772:	8b 45 f8             	mov    -0x8(%ebp),%eax
}
80100775:	c9                   	leave  
80100776:	c3                   	ret    

80100777 <kbdintr>:

void
kbdintr(void)
{
80100777:	55                   	push   %ebp
80100778:	89 e5                	mov    %esp,%ebp
8010077a:	83 ec 08             	sub    $0x8,%esp
  consoleintr(kbdgetc);
8010077d:	83 ec 0c             	sub    $0xc,%esp
80100780:	68 28 06 10 80       	push   $0x80100628
80100785:	e8 e1 fc ff ff       	call   8010046b <consoleintr>
8010078a:	83 c4 10             	add    $0x10,%esp
}
8010078d:	c9                   	leave  
8010078e:	c3                   	ret    

8010078f <lgdt>:

struct segdesc;

static inline void
lgdt(struct segdesc *p, int size)
{
8010078f:	55                   	push   %ebp
80100790:	89 e5                	mov    %esp,%ebp
80100792:	83 ec 10             	sub    $0x10,%esp
  volatile ushort pd[3];

  pd[0] = size-1;
80100795:	8b 45 0c             	mov    0xc(%ebp),%eax
80100798:	83 e8 01             	sub    $0x1,%eax
8010079b:	66 89 45 fa          	mov    %ax,-0x6(%ebp)
  pd[1] = (uint)p;
8010079f:	8b 45 08             	mov    0x8(%ebp),%eax
801007a2:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  pd[2] = (uint)p >> 16;
801007a6:	8b 45 08             	mov    0x8(%ebp),%eax
801007a9:	c1 e8 10             	shr    $0x10,%eax
801007ac:	66 89 45 fe          	mov    %ax,-0x2(%ebp)

  asm volatile("lgdt (%0)" : : "r" (pd));
801007b0:	8d 45 fa             	lea    -0x6(%ebp),%eax
801007b3:	0f 01 10             	lgdtl  (%eax)
}
801007b6:	c9                   	leave  
801007b7:	c3                   	ret    

801007b8 <loadgs>:
  return eflags;
}

static inline void
loadgs(ushort v)
{
801007b8:	55                   	push   %ebp
801007b9:	89 e5                	mov    %esp,%ebp
801007bb:	83 ec 04             	sub    $0x4,%esp
801007be:	8b 45 08             	mov    0x8(%ebp),%eax
801007c1:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  asm volatile("movw %0, %%gs" : : "r" (v));
801007c5:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
801007c9:	8e e8                	mov    %eax,%gs
}
801007cb:	c9                   	leave  
801007cc:	c3                   	ret    

801007cd <lcr3>:
  return val;
}

static inline void
lcr3(uint val) 
{
801007cd:	55                   	push   %ebp
801007ce:	89 e5                	mov    %esp,%ebp
  asm volatile("movl %0,%%cr3" : : "r" (val));
801007d0:	8b 45 08             	mov    0x8(%ebp),%eax
801007d3:	0f 22 d8             	mov    %eax,%cr3
}
801007d6:	5d                   	pop    %ebp
801007d7:	c3                   	ret    

801007d8 <v2p>:
#define KERNBASE 0x80000000         // First kernel virtual address
#define KERNLINK (KERNBASE+EXTMEM)  // Address where kernel is linked

#ifndef __ASSEMBLER__

static inline uint v2p(void *a) { return ((uint) (a))  - KERNBASE; }
801007d8:	55                   	push   %ebp
801007d9:	89 e5                	mov    %esp,%ebp
801007db:	8b 45 08             	mov    0x8(%ebp),%eax
801007de:	05 00 00 00 80       	add    $0x80000000,%eax
801007e3:	5d                   	pop    %ebp
801007e4:	c3                   	ret    

801007e5 <p2v>:
static inline void *p2v(uint a) { return (void *) ((a) + KERNBASE); }
801007e5:	55                   	push   %ebp
801007e6:	89 e5                	mov    %esp,%ebp
801007e8:	8b 45 08             	mov    0x8(%ebp),%eax
801007eb:	05 00 00 00 80       	add    $0x80000000,%eax
801007f0:	5d                   	pop    %ebp
801007f1:	c3                   	ret    

801007f2 <seginit>:
struct cpu cpus[1];
extern char data[];  // 由kernel.ld来定义
pde_t *kpgdir;  // 被进程调度所使用(以后)

void seginit(void)
{
801007f2:	55                   	push   %ebp
801007f3:	89 e5                	mov    %esp,%ebp
801007f5:	53                   	push   %ebx
801007f6:	83 ec 10             	sub    $0x10,%esp
  struct cpu *c;
  c = &cpus[0]; 
801007f9:	c7 45 f8 00 60 10 80 	movl   $0x80106000,-0x8(%ebp)
  c->gdt[SEG_KCODE] = SEG(STA_X|STA_R, 0, 0xffffffff, 0);        
80100800:	8b 45 f8             	mov    -0x8(%ebp),%eax
80100803:	66 c7 40 08 ff ff    	movw   $0xffff,0x8(%eax)
80100809:	8b 45 f8             	mov    -0x8(%ebp),%eax
8010080c:	66 c7 40 0a 00 00    	movw   $0x0,0xa(%eax)
80100812:	8b 45 f8             	mov    -0x8(%ebp),%eax
80100815:	c6 40 0c 00          	movb   $0x0,0xc(%eax)
80100819:	8b 45 f8             	mov    -0x8(%ebp),%eax
8010081c:	0f b6 50 0d          	movzbl 0xd(%eax),%edx
80100820:	83 e2 f0             	and    $0xfffffff0,%edx
80100823:	83 ca 0a             	or     $0xa,%edx
80100826:	88 50 0d             	mov    %dl,0xd(%eax)
80100829:	8b 45 f8             	mov    -0x8(%ebp),%eax
8010082c:	0f b6 50 0d          	movzbl 0xd(%eax),%edx
80100830:	83 ca 10             	or     $0x10,%edx
80100833:	88 50 0d             	mov    %dl,0xd(%eax)
80100836:	8b 45 f8             	mov    -0x8(%ebp),%eax
80100839:	0f b6 50 0d          	movzbl 0xd(%eax),%edx
8010083d:	83 e2 9f             	and    $0xffffff9f,%edx
80100840:	88 50 0d             	mov    %dl,0xd(%eax)
80100843:	8b 45 f8             	mov    -0x8(%ebp),%eax
80100846:	0f b6 50 0d          	movzbl 0xd(%eax),%edx
8010084a:	83 ca 80             	or     $0xffffff80,%edx
8010084d:	88 50 0d             	mov    %dl,0xd(%eax)
80100850:	8b 45 f8             	mov    -0x8(%ebp),%eax
80100853:	0f b6 50 0e          	movzbl 0xe(%eax),%edx
80100857:	83 ca 0f             	or     $0xf,%edx
8010085a:	88 50 0e             	mov    %dl,0xe(%eax)
8010085d:	8b 45 f8             	mov    -0x8(%ebp),%eax
80100860:	0f b6 50 0e          	movzbl 0xe(%eax),%edx
80100864:	83 e2 ef             	and    $0xffffffef,%edx
80100867:	88 50 0e             	mov    %dl,0xe(%eax)
8010086a:	8b 45 f8             	mov    -0x8(%ebp),%eax
8010086d:	0f b6 50 0e          	movzbl 0xe(%eax),%edx
80100871:	83 e2 df             	and    $0xffffffdf,%edx
80100874:	88 50 0e             	mov    %dl,0xe(%eax)
80100877:	8b 45 f8             	mov    -0x8(%ebp),%eax
8010087a:	0f b6 50 0e          	movzbl 0xe(%eax),%edx
8010087e:	83 ca 40             	or     $0x40,%edx
80100881:	88 50 0e             	mov    %dl,0xe(%eax)
80100884:	8b 45 f8             	mov    -0x8(%ebp),%eax
80100887:	0f b6 50 0e          	movzbl 0xe(%eax),%edx
8010088b:	83 ca 80             	or     $0xffffff80,%edx
8010088e:	88 50 0e             	mov    %dl,0xe(%eax)
80100891:	8b 45 f8             	mov    -0x8(%ebp),%eax
80100894:	c6 40 0f 00          	movb   $0x0,0xf(%eax)
  c->gdt[SEG_KDATA] = SEG(STA_W, 0, 0xffffffff, 0);
80100898:	8b 45 f8             	mov    -0x8(%ebp),%eax
8010089b:	66 c7 40 10 ff ff    	movw   $0xffff,0x10(%eax)
801008a1:	8b 45 f8             	mov    -0x8(%ebp),%eax
801008a4:	66 c7 40 12 00 00    	movw   $0x0,0x12(%eax)
801008aa:	8b 45 f8             	mov    -0x8(%ebp),%eax
801008ad:	c6 40 14 00          	movb   $0x0,0x14(%eax)
801008b1:	8b 45 f8             	mov    -0x8(%ebp),%eax
801008b4:	0f b6 50 15          	movzbl 0x15(%eax),%edx
801008b8:	83 e2 f0             	and    $0xfffffff0,%edx
801008bb:	83 ca 02             	or     $0x2,%edx
801008be:	88 50 15             	mov    %dl,0x15(%eax)
801008c1:	8b 45 f8             	mov    -0x8(%ebp),%eax
801008c4:	0f b6 50 15          	movzbl 0x15(%eax),%edx
801008c8:	83 ca 10             	or     $0x10,%edx
801008cb:	88 50 15             	mov    %dl,0x15(%eax)
801008ce:	8b 45 f8             	mov    -0x8(%ebp),%eax
801008d1:	0f b6 50 15          	movzbl 0x15(%eax),%edx
801008d5:	83 e2 9f             	and    $0xffffff9f,%edx
801008d8:	88 50 15             	mov    %dl,0x15(%eax)
801008db:	8b 45 f8             	mov    -0x8(%ebp),%eax
801008de:	0f b6 50 15          	movzbl 0x15(%eax),%edx
801008e2:	83 ca 80             	or     $0xffffff80,%edx
801008e5:	88 50 15             	mov    %dl,0x15(%eax)
801008e8:	8b 45 f8             	mov    -0x8(%ebp),%eax
801008eb:	0f b6 50 16          	movzbl 0x16(%eax),%edx
801008ef:	83 ca 0f             	or     $0xf,%edx
801008f2:	88 50 16             	mov    %dl,0x16(%eax)
801008f5:	8b 45 f8             	mov    -0x8(%ebp),%eax
801008f8:	0f b6 50 16          	movzbl 0x16(%eax),%edx
801008fc:	83 e2 ef             	and    $0xffffffef,%edx
801008ff:	88 50 16             	mov    %dl,0x16(%eax)
80100902:	8b 45 f8             	mov    -0x8(%ebp),%eax
80100905:	0f b6 50 16          	movzbl 0x16(%eax),%edx
80100909:	83 e2 df             	and    $0xffffffdf,%edx
8010090c:	88 50 16             	mov    %dl,0x16(%eax)
8010090f:	8b 45 f8             	mov    -0x8(%ebp),%eax
80100912:	0f b6 50 16          	movzbl 0x16(%eax),%edx
80100916:	83 ca 40             	or     $0x40,%edx
80100919:	88 50 16             	mov    %dl,0x16(%eax)
8010091c:	8b 45 f8             	mov    -0x8(%ebp),%eax
8010091f:	0f b6 50 16          	movzbl 0x16(%eax),%edx
80100923:	83 ca 80             	or     $0xffffff80,%edx
80100926:	88 50 16             	mov    %dl,0x16(%eax)
80100929:	8b 45 f8             	mov    -0x8(%ebp),%eax
8010092c:	c6 40 17 00          	movb   $0x0,0x17(%eax)
  c->gdt[SEG_UCODE] = SEG(STA_X|STA_R, 0, 0xffffffff, DPL_USER);
80100930:	8b 45 f8             	mov    -0x8(%ebp),%eax
80100933:	66 c7 40 20 ff ff    	movw   $0xffff,0x20(%eax)
80100939:	8b 45 f8             	mov    -0x8(%ebp),%eax
8010093c:	66 c7 40 22 00 00    	movw   $0x0,0x22(%eax)
80100942:	8b 45 f8             	mov    -0x8(%ebp),%eax
80100945:	c6 40 24 00          	movb   $0x0,0x24(%eax)
80100949:	8b 45 f8             	mov    -0x8(%ebp),%eax
8010094c:	0f b6 50 25          	movzbl 0x25(%eax),%edx
80100950:	83 e2 f0             	and    $0xfffffff0,%edx
80100953:	83 ca 0a             	or     $0xa,%edx
80100956:	88 50 25             	mov    %dl,0x25(%eax)
80100959:	8b 45 f8             	mov    -0x8(%ebp),%eax
8010095c:	0f b6 50 25          	movzbl 0x25(%eax),%edx
80100960:	83 ca 10             	or     $0x10,%edx
80100963:	88 50 25             	mov    %dl,0x25(%eax)
80100966:	8b 45 f8             	mov    -0x8(%ebp),%eax
80100969:	0f b6 50 25          	movzbl 0x25(%eax),%edx
8010096d:	83 ca 60             	or     $0x60,%edx
80100970:	88 50 25             	mov    %dl,0x25(%eax)
80100973:	8b 45 f8             	mov    -0x8(%ebp),%eax
80100976:	0f b6 50 25          	movzbl 0x25(%eax),%edx
8010097a:	83 ca 80             	or     $0xffffff80,%edx
8010097d:	88 50 25             	mov    %dl,0x25(%eax)
80100980:	8b 45 f8             	mov    -0x8(%ebp),%eax
80100983:	0f b6 50 26          	movzbl 0x26(%eax),%edx
80100987:	83 ca 0f             	or     $0xf,%edx
8010098a:	88 50 26             	mov    %dl,0x26(%eax)
8010098d:	8b 45 f8             	mov    -0x8(%ebp),%eax
80100990:	0f b6 50 26          	movzbl 0x26(%eax),%edx
80100994:	83 e2 ef             	and    $0xffffffef,%edx
80100997:	88 50 26             	mov    %dl,0x26(%eax)
8010099a:	8b 45 f8             	mov    -0x8(%ebp),%eax
8010099d:	0f b6 50 26          	movzbl 0x26(%eax),%edx
801009a1:	83 e2 df             	and    $0xffffffdf,%edx
801009a4:	88 50 26             	mov    %dl,0x26(%eax)
801009a7:	8b 45 f8             	mov    -0x8(%ebp),%eax
801009aa:	0f b6 50 26          	movzbl 0x26(%eax),%edx
801009ae:	83 ca 40             	or     $0x40,%edx
801009b1:	88 50 26             	mov    %dl,0x26(%eax)
801009b4:	8b 45 f8             	mov    -0x8(%ebp),%eax
801009b7:	0f b6 50 26          	movzbl 0x26(%eax),%edx
801009bb:	83 ca 80             	or     $0xffffff80,%edx
801009be:	88 50 26             	mov    %dl,0x26(%eax)
801009c1:	8b 45 f8             	mov    -0x8(%ebp),%eax
801009c4:	c6 40 27 00          	movb   $0x0,0x27(%eax)
  c->gdt[SEG_UDATA] = SEG(STA_W, 0, 0xffffffff, DPL_USER);
801009c8:	8b 45 f8             	mov    -0x8(%ebp),%eax
801009cb:	66 c7 40 28 ff ff    	movw   $0xffff,0x28(%eax)
801009d1:	8b 45 f8             	mov    -0x8(%ebp),%eax
801009d4:	66 c7 40 2a 00 00    	movw   $0x0,0x2a(%eax)
801009da:	8b 45 f8             	mov    -0x8(%ebp),%eax
801009dd:	c6 40 2c 00          	movb   $0x0,0x2c(%eax)
801009e1:	8b 45 f8             	mov    -0x8(%ebp),%eax
801009e4:	0f b6 50 2d          	movzbl 0x2d(%eax),%edx
801009e8:	83 e2 f0             	and    $0xfffffff0,%edx
801009eb:	83 ca 02             	or     $0x2,%edx
801009ee:	88 50 2d             	mov    %dl,0x2d(%eax)
801009f1:	8b 45 f8             	mov    -0x8(%ebp),%eax
801009f4:	0f b6 50 2d          	movzbl 0x2d(%eax),%edx
801009f8:	83 ca 10             	or     $0x10,%edx
801009fb:	88 50 2d             	mov    %dl,0x2d(%eax)
801009fe:	8b 45 f8             	mov    -0x8(%ebp),%eax
80100a01:	0f b6 50 2d          	movzbl 0x2d(%eax),%edx
80100a05:	83 ca 60             	or     $0x60,%edx
80100a08:	88 50 2d             	mov    %dl,0x2d(%eax)
80100a0b:	8b 45 f8             	mov    -0x8(%ebp),%eax
80100a0e:	0f b6 50 2d          	movzbl 0x2d(%eax),%edx
80100a12:	83 ca 80             	or     $0xffffff80,%edx
80100a15:	88 50 2d             	mov    %dl,0x2d(%eax)
80100a18:	8b 45 f8             	mov    -0x8(%ebp),%eax
80100a1b:	0f b6 50 2e          	movzbl 0x2e(%eax),%edx
80100a1f:	83 ca 0f             	or     $0xf,%edx
80100a22:	88 50 2e             	mov    %dl,0x2e(%eax)
80100a25:	8b 45 f8             	mov    -0x8(%ebp),%eax
80100a28:	0f b6 50 2e          	movzbl 0x2e(%eax),%edx
80100a2c:	83 e2 ef             	and    $0xffffffef,%edx
80100a2f:	88 50 2e             	mov    %dl,0x2e(%eax)
80100a32:	8b 45 f8             	mov    -0x8(%ebp),%eax
80100a35:	0f b6 50 2e          	movzbl 0x2e(%eax),%edx
80100a39:	83 e2 df             	and    $0xffffffdf,%edx
80100a3c:	88 50 2e             	mov    %dl,0x2e(%eax)
80100a3f:	8b 45 f8             	mov    -0x8(%ebp),%eax
80100a42:	0f b6 50 2e          	movzbl 0x2e(%eax),%edx
80100a46:	83 ca 40             	or     $0x40,%edx
80100a49:	88 50 2e             	mov    %dl,0x2e(%eax)
80100a4c:	8b 45 f8             	mov    -0x8(%ebp),%eax
80100a4f:	0f b6 50 2e          	movzbl 0x2e(%eax),%edx
80100a53:	83 ca 80             	or     $0xffffff80,%edx
80100a56:	88 50 2e             	mov    %dl,0x2e(%eax)
80100a59:	8b 45 f8             	mov    -0x8(%ebp),%eax
80100a5c:	c6 40 2f 00          	movb   $0x0,0x2f(%eax)
  
  c->gdt[SEG_KCPU] = SEG(STA_W, &c->cpu, 8, 0);
80100a60:	8b 45 f8             	mov    -0x8(%ebp),%eax
80100a63:	83 c0 38             	add    $0x38,%eax
80100a66:	89 c3                	mov    %eax,%ebx
80100a68:	8b 45 f8             	mov    -0x8(%ebp),%eax
80100a6b:	83 c0 38             	add    $0x38,%eax
80100a6e:	c1 e8 10             	shr    $0x10,%eax
80100a71:	89 c2                	mov    %eax,%edx
80100a73:	8b 45 f8             	mov    -0x8(%ebp),%eax
80100a76:	83 c0 38             	add    $0x38,%eax
80100a79:	c1 e8 18             	shr    $0x18,%eax
80100a7c:	89 c1                	mov    %eax,%ecx
80100a7e:	8b 45 f8             	mov    -0x8(%ebp),%eax
80100a81:	66 c7 40 18 00 00    	movw   $0x0,0x18(%eax)
80100a87:	8b 45 f8             	mov    -0x8(%ebp),%eax
80100a8a:	66 89 58 1a          	mov    %bx,0x1a(%eax)
80100a8e:	8b 45 f8             	mov    -0x8(%ebp),%eax
80100a91:	88 50 1c             	mov    %dl,0x1c(%eax)
80100a94:	8b 45 f8             	mov    -0x8(%ebp),%eax
80100a97:	0f b6 50 1d          	movzbl 0x1d(%eax),%edx
80100a9b:	83 e2 f0             	and    $0xfffffff0,%edx
80100a9e:	83 ca 02             	or     $0x2,%edx
80100aa1:	88 50 1d             	mov    %dl,0x1d(%eax)
80100aa4:	8b 45 f8             	mov    -0x8(%ebp),%eax
80100aa7:	0f b6 50 1d          	movzbl 0x1d(%eax),%edx
80100aab:	83 ca 10             	or     $0x10,%edx
80100aae:	88 50 1d             	mov    %dl,0x1d(%eax)
80100ab1:	8b 45 f8             	mov    -0x8(%ebp),%eax
80100ab4:	0f b6 50 1d          	movzbl 0x1d(%eax),%edx
80100ab8:	83 e2 9f             	and    $0xffffff9f,%edx
80100abb:	88 50 1d             	mov    %dl,0x1d(%eax)
80100abe:	8b 45 f8             	mov    -0x8(%ebp),%eax
80100ac1:	0f b6 50 1d          	movzbl 0x1d(%eax),%edx
80100ac5:	83 ca 80             	or     $0xffffff80,%edx
80100ac8:	88 50 1d             	mov    %dl,0x1d(%eax)
80100acb:	8b 45 f8             	mov    -0x8(%ebp),%eax
80100ace:	0f b6 50 1e          	movzbl 0x1e(%eax),%edx
80100ad2:	83 e2 f0             	and    $0xfffffff0,%edx
80100ad5:	88 50 1e             	mov    %dl,0x1e(%eax)
80100ad8:	8b 45 f8             	mov    -0x8(%ebp),%eax
80100adb:	0f b6 50 1e          	movzbl 0x1e(%eax),%edx
80100adf:	83 e2 ef             	and    $0xffffffef,%edx
80100ae2:	88 50 1e             	mov    %dl,0x1e(%eax)
80100ae5:	8b 45 f8             	mov    -0x8(%ebp),%eax
80100ae8:	0f b6 50 1e          	movzbl 0x1e(%eax),%edx
80100aec:	83 e2 df             	and    $0xffffffdf,%edx
80100aef:	88 50 1e             	mov    %dl,0x1e(%eax)
80100af2:	8b 45 f8             	mov    -0x8(%ebp),%eax
80100af5:	0f b6 50 1e          	movzbl 0x1e(%eax),%edx
80100af9:	83 ca 40             	or     $0x40,%edx
80100afc:	88 50 1e             	mov    %dl,0x1e(%eax)
80100aff:	8b 45 f8             	mov    -0x8(%ebp),%eax
80100b02:	0f b6 50 1e          	movzbl 0x1e(%eax),%edx
80100b06:	83 ca 80             	or     $0xffffff80,%edx
80100b09:	88 50 1e             	mov    %dl,0x1e(%eax)
80100b0c:	8b 45 f8             	mov    -0x8(%ebp),%eax
80100b0f:	88 48 1f             	mov    %cl,0x1f(%eax)
  
  lgdt(c->gdt, sizeof(c->gdt));
80100b12:	8b 45 f8             	mov    -0x8(%ebp),%eax
80100b15:	6a 38                	push   $0x38
80100b17:	50                   	push   %eax
80100b18:	e8 72 fc ff ff       	call   8010078f <lgdt>
80100b1d:	83 c4 08             	add    $0x8,%esp
  loadgs(SEG_KCPU << 3);
80100b20:	6a 18                	push   $0x18
80100b22:	e8 91 fc ff ff       	call   801007b8 <loadgs>
80100b27:	83 c4 04             	add    $0x4,%esp
  
  cpu = c;
80100b2a:	8b 45 f8             	mov    -0x8(%ebp),%eax
80100b2d:	65 a3 00 00 00 00    	mov    %eax,%gs:0x0
}
80100b33:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80100b36:	c9                   	leave  
80100b37:	c3                   	ret    

80100b38 <segshow>:


void segshow(){
80100b38:	55                   	push   %ebp
80100b39:	89 e5                	mov    %esp,%ebp
80100b3b:	83 ec 08             	sub    $0x8,%esp

  cprintf("Kernel code segment's address bit 31~24 : %d\n",cpu->gdt[SEG_KCODE].base_31_24);
80100b3e:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80100b44:	0f b6 40 0f          	movzbl 0xf(%eax),%eax
80100b48:	0f b6 c0             	movzbl %al,%eax
80100b4b:	83 ec 08             	sub    $0x8,%esp
80100b4e:	50                   	push   %eax
80100b4f:	68 44 1e 10 80       	push   $0x80101e44
80100b54:	e8 30 f6 ff ff       	call   80100189 <cprintf>
80100b59:	83 c4 10             	add    $0x10,%esp
  cprintf("Kernel code segment's address bit 23~16 : %d\n",cpu->gdt[SEG_KCODE].base_23_16);
80100b5c:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80100b62:	0f b6 40 0c          	movzbl 0xc(%eax),%eax
80100b66:	0f b6 c0             	movzbl %al,%eax
80100b69:	83 ec 08             	sub    $0x8,%esp
80100b6c:	50                   	push   %eax
80100b6d:	68 74 1e 10 80       	push   $0x80101e74
80100b72:	e8 12 f6 ff ff       	call   80100189 <cprintf>
80100b77:	83 c4 10             	add    $0x10,%esp
  cprintf("Kernel code segment's address bit 15~0 : %d\n",cpu->gdt[SEG_KCODE].base_15_0);
80100b7a:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80100b80:	0f b7 40 0a          	movzwl 0xa(%eax),%eax
80100b84:	0f b7 c0             	movzwl %ax,%eax
80100b87:	83 ec 08             	sub    $0x8,%esp
80100b8a:	50                   	push   %eax
80100b8b:	68 a4 1e 10 80       	push   $0x80101ea4
80100b90:	e8 f4 f5 ff ff       	call   80100189 <cprintf>
80100b95:	83 c4 10             	add    $0x10,%esp
                                                                                          
  cprintf("Kernel data segment's address bit 31~24 : %d\n",cpu->gdt[SEG_KDATA].base_31_24);
80100b98:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80100b9e:	0f b6 40 17          	movzbl 0x17(%eax),%eax
80100ba2:	0f b6 c0             	movzbl %al,%eax
80100ba5:	83 ec 08             	sub    $0x8,%esp
80100ba8:	50                   	push   %eax
80100ba9:	68 d4 1e 10 80       	push   $0x80101ed4
80100bae:	e8 d6 f5 ff ff       	call   80100189 <cprintf>
80100bb3:	83 c4 10             	add    $0x10,%esp
  cprintf("Kernel data segment's address bit 23~16 : %d\n",cpu->gdt[SEG_KDATA].base_23_16);
80100bb6:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80100bbc:	0f b6 40 14          	movzbl 0x14(%eax),%eax
80100bc0:	0f b6 c0             	movzbl %al,%eax
80100bc3:	83 ec 08             	sub    $0x8,%esp
80100bc6:	50                   	push   %eax
80100bc7:	68 04 1f 10 80       	push   $0x80101f04
80100bcc:	e8 b8 f5 ff ff       	call   80100189 <cprintf>
80100bd1:	83 c4 10             	add    $0x10,%esp
  cprintf("Kernel data segment's address bit 15~0 : %d\n",cpu->gdt[SEG_KDATA].base_15_0);
80100bd4:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80100bda:	0f b7 40 12          	movzwl 0x12(%eax),%eax
80100bde:	0f b7 c0             	movzwl %ax,%eax
80100be1:	83 ec 08             	sub    $0x8,%esp
80100be4:	50                   	push   %eax
80100be5:	68 34 1f 10 80       	push   $0x80101f34
80100bea:	e8 9a f5 ff ff       	call   80100189 <cprintf>
80100bef:	83 c4 10             	add    $0x10,%esp

  cprintf("User code segment's address bit 31~24 : %d\n",cpu->gdt[SEG_UCODE].base_31_24);
80100bf2:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80100bf8:	0f b6 40 27          	movzbl 0x27(%eax),%eax
80100bfc:	0f b6 c0             	movzbl %al,%eax
80100bff:	83 ec 08             	sub    $0x8,%esp
80100c02:	50                   	push   %eax
80100c03:	68 64 1f 10 80       	push   $0x80101f64
80100c08:	e8 7c f5 ff ff       	call   80100189 <cprintf>
80100c0d:	83 c4 10             	add    $0x10,%esp
  cprintf("User code segment's address bit 23~16 : %d\n",cpu->gdt[SEG_UCODE].base_15_0);
80100c10:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80100c16:	0f b7 40 22          	movzwl 0x22(%eax),%eax
80100c1a:	0f b7 c0             	movzwl %ax,%eax
80100c1d:	83 ec 08             	sub    $0x8,%esp
80100c20:	50                   	push   %eax
80100c21:	68 90 1f 10 80       	push   $0x80101f90
80100c26:	e8 5e f5 ff ff       	call   80100189 <cprintf>
80100c2b:	83 c4 10             	add    $0x10,%esp
  cprintf("User code segment's address bit 15~0 : %d\n",cpu->gdt[SEG_UCODE].base_15_0);
80100c2e:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80100c34:	0f b7 40 22          	movzwl 0x22(%eax),%eax
80100c38:	0f b7 c0             	movzwl %ax,%eax
80100c3b:	83 ec 08             	sub    $0x8,%esp
80100c3e:	50                   	push   %eax
80100c3f:	68 bc 1f 10 80       	push   $0x80101fbc
80100c44:	e8 40 f5 ff ff       	call   80100189 <cprintf>
80100c49:	83 c4 10             	add    $0x10,%esp
  
  cprintf("User code segment's address bit 31~24 : %d\n",cpu->gdt[SEG_UDATA].base_31_24);
80100c4c:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80100c52:	0f b6 40 2f          	movzbl 0x2f(%eax),%eax
80100c56:	0f b6 c0             	movzbl %al,%eax
80100c59:	83 ec 08             	sub    $0x8,%esp
80100c5c:	50                   	push   %eax
80100c5d:	68 64 1f 10 80       	push   $0x80101f64
80100c62:	e8 22 f5 ff ff       	call   80100189 <cprintf>
80100c67:	83 c4 10             	add    $0x10,%esp
  cprintf("User code segment's address bit 23~16 : %d\n",cpu->gdt[SEG_UDATA].base_23_16);
80100c6a:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80100c70:	0f b6 40 2c          	movzbl 0x2c(%eax),%eax
80100c74:	0f b6 c0             	movzbl %al,%eax
80100c77:	83 ec 08             	sub    $0x8,%esp
80100c7a:	50                   	push   %eax
80100c7b:	68 90 1f 10 80       	push   $0x80101f90
80100c80:	e8 04 f5 ff ff       	call   80100189 <cprintf>
80100c85:	83 c4 10             	add    $0x10,%esp
  cprintf("User code segment's address bit 15~0 : %d\n",cpu->gdt[SEG_UDATA].base_15_0);
80100c88:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80100c8e:	0f b7 40 2a          	movzwl 0x2a(%eax),%eax
80100c92:	0f b7 c0             	movzwl %ax,%eax
80100c95:	83 ec 08             	sub    $0x8,%esp
80100c98:	50                   	push   %eax
80100c99:	68 bc 1f 10 80       	push   $0x80101fbc
80100c9e:	e8 e6 f4 ff ff       	call   80100189 <cprintf>
80100ca3:	83 c4 10             	add    $0x10,%esp

}
80100ca6:	c9                   	leave  
80100ca7:	c3                   	ret    

80100ca8 <walkpgdir>:



//返回页表pgdir中对应线性地址va的PTE(页项)的地址，如果creat!=0,那么创建请求的页项
static pte_t * walkpgdir(pde_t *pgdir, const void *va, int alloc)
{
80100ca8:	55                   	push   %ebp
80100ca9:	89 e5                	mov    %esp,%ebp
80100cab:	83 ec 18             	sub    $0x18,%esp
  pde_t *pde;
  pte_t *pgtab;

  pde = &pgdir[PDX(va)];    //根据线性地址查找其对应的页表地址
80100cae:	8b 45 0c             	mov    0xc(%ebp),%eax
80100cb1:	c1 e8 16             	shr    $0x16,%eax
80100cb4:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80100cbb:	8b 45 08             	mov    0x8(%ebp),%eax
80100cbe:	01 d0                	add    %edx,%eax
80100cc0:	89 45 f0             	mov    %eax,-0x10(%ebp)
 
  if(*pde & PTE_P){
80100cc3:	8b 45 f0             	mov    -0x10(%ebp),%eax
80100cc6:	8b 00                	mov    (%eax),%eax
80100cc8:	83 e0 01             	and    $0x1,%eax
80100ccb:	85 c0                	test   %eax,%eax
80100ccd:	74 18                	je     80100ce7 <walkpgdir+0x3f>
    pgtab = (pte_t*)p2v(PTE_ADDR(*pde));
80100ccf:	8b 45 f0             	mov    -0x10(%ebp),%eax
80100cd2:	8b 00                	mov    (%eax),%eax
80100cd4:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80100cd9:	50                   	push   %eax
80100cda:	e8 06 fb ff ff       	call   801007e5 <p2v>
80100cdf:	83 c4 04             	add    $0x4,%esp
80100ce2:	89 45 f4             	mov    %eax,-0xc(%ebp)
80100ce5:	eb 48                	jmp    80100d2f <walkpgdir+0x87>
  } else {
    
    if(!alloc || (pgtab = (pte_t*)kalloc()) == 0)
80100ce7:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80100ceb:	74 0e                	je     80100cfb <walkpgdir+0x53>
80100ced:	e8 f6 f8 ff ff       	call   801005e8 <kalloc>
80100cf2:	89 45 f4             	mov    %eax,-0xc(%ebp)
80100cf5:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80100cf9:	75 07                	jne    80100d02 <walkpgdir+0x5a>
      return 0;
80100cfb:	b8 00 00 00 00       	mov    $0x0,%eax
80100d00:	eb 44                	jmp    80100d46 <walkpgdir+0x9e>
    
    memset(pgtab, 0, PGSIZE);
80100d02:	83 ec 04             	sub    $0x4,%esp
80100d05:	68 00 10 00 00       	push   $0x1000
80100d0a:	6a 00                	push   $0x0
80100d0c:	ff 75 f4             	pushl  -0xc(%ebp)
80100d0f:	e8 e2 f7 ff ff       	call   801004f6 <memset>
80100d14:	83 c4 10             	add    $0x10,%esp
    
    *pde = v2p(pgtab) | PTE_P | PTE_W | PTE_U;
80100d17:	83 ec 0c             	sub    $0xc,%esp
80100d1a:	ff 75 f4             	pushl  -0xc(%ebp)
80100d1d:	e8 b6 fa ff ff       	call   801007d8 <v2p>
80100d22:	83 c4 10             	add    $0x10,%esp
80100d25:	83 c8 07             	or     $0x7,%eax
80100d28:	89 c2                	mov    %eax,%edx
80100d2a:	8b 45 f0             	mov    -0x10(%ebp),%eax
80100d2d:	89 10                	mov    %edx,(%eax)
  }
  return &pgtab[PTX(va)];   //返回页地址
80100d2f:	8b 45 0c             	mov    0xc(%ebp),%eax
80100d32:	c1 e8 0c             	shr    $0xc,%eax
80100d35:	25 ff 03 00 00       	and    $0x3ff,%eax
80100d3a:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80100d41:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100d44:	01 d0                	add    %edx,%eax
}
80100d46:	c9                   	leave  
80100d47:	c3                   	ret    

80100d48 <mappages>:

//为以va开始的线性地址创建页项，va引用pa开始处的物理地址，va和size可能没有按页对其
static int mappages(pde_t *pgdir, void *va, uint size, uint pa, int perm)
{
80100d48:	55                   	push   %ebp
80100d49:	89 e5                	mov    %esp,%ebp
80100d4b:	83 ec 18             	sub    $0x18,%esp
  char *a, *last;
  pte_t *pte;
  
  a = (char*)PGROUNDDOWN((uint)va);                        //va所在的第一页地址
80100d4e:	8b 45 0c             	mov    0xc(%ebp),%eax
80100d51:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80100d56:	89 45 f4             	mov    %eax,-0xc(%ebp)
  last = (char*)PGROUNDDOWN(((uint)va) + size - 1);        //va所在的最后一页地址
80100d59:	8b 55 0c             	mov    0xc(%ebp),%edx
80100d5c:	8b 45 10             	mov    0x10(%ebp),%eax
80100d5f:	01 d0                	add    %edx,%eax
80100d61:	83 e8 01             	sub    $0x1,%eax
80100d64:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80100d69:	89 45 f0             	mov    %eax,-0x10(%ebp)
  
  for(;;){
    if((pte = walkpgdir(pgdir, a, 1)) == 0)      //创建页
80100d6c:	83 ec 04             	sub    $0x4,%esp
80100d6f:	6a 01                	push   $0x1
80100d71:	ff 75 f4             	pushl  -0xc(%ebp)
80100d74:	ff 75 08             	pushl  0x8(%ebp)
80100d77:	e8 2c ff ff ff       	call   80100ca8 <walkpgdir>
80100d7c:	83 c4 10             	add    $0x10,%esp
80100d7f:	89 45 ec             	mov    %eax,-0x14(%ebp)
80100d82:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80100d86:	75 07                	jne    80100d8f <mappages+0x47>
      return -1;
80100d88:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80100d8d:	eb 30                	jmp    80100dbf <mappages+0x77>
   
    *pte = pa | perm | PTE_P;
80100d8f:	8b 45 18             	mov    0x18(%ebp),%eax
80100d92:	0b 45 14             	or     0x14(%ebp),%eax
80100d95:	83 c8 01             	or     $0x1,%eax
80100d98:	89 c2                	mov    %eax,%edx
80100d9a:	8b 45 ec             	mov    -0x14(%ebp),%eax
80100d9d:	89 10                	mov    %edx,(%eax)
   
    if(a == last)
80100d9f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100da2:	3b 45 f0             	cmp    -0x10(%ebp),%eax
80100da5:	75 08                	jne    80100daf <mappages+0x67>
      break;
80100da7:	90                   	nop
   
    a += PGSIZE;
    pa += PGSIZE;
  }
  return 0;
80100da8:	b8 00 00 00 00       	mov    $0x0,%eax
80100dad:	eb 10                	jmp    80100dbf <mappages+0x77>
    *pte = pa | perm | PTE_P;
   
    if(a == last)
      break;
   
    a += PGSIZE;
80100daf:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
    pa += PGSIZE;
80100db6:	81 45 14 00 10 00 00 	addl   $0x1000,0x14(%ebp)
  }
80100dbd:	eb ad                	jmp    80100d6c <mappages+0x24>
  return 0;
}
80100dbf:	c9                   	leave  
80100dc0:	c3                   	ret    

80100dc1 <setupkvm>:
};


//设置页表的内核部分,返回此页表
pde_t* setupkvm(void)
{
80100dc1:	55                   	push   %ebp
80100dc2:	89 e5                	mov    %esp,%ebp
80100dc4:	53                   	push   %ebx
80100dc5:	83 ec 14             	sub    $0x14,%esp
  pde_t *pgdir;
  struct kmap *k;

  if((pgdir = (pde_t*)kalloc()) == 0)
80100dc8:	e8 1b f8 ff ff       	call   801005e8 <kalloc>
80100dcd:	89 45 f0             	mov    %eax,-0x10(%ebp)
80100dd0:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80100dd4:	75 07                	jne    80100ddd <setupkvm+0x1c>
    return 0;
80100dd6:	b8 00 00 00 00       	mov    $0x0,%eax
80100ddb:	eb 6a                	jmp    80100e47 <setupkvm+0x86>
 
  memset(pgdir, 0, PGSIZE);
80100ddd:	83 ec 04             	sub    $0x4,%esp
80100de0:	68 00 10 00 00       	push   $0x1000
80100de5:	6a 00                	push   $0x0
80100de7:	ff 75 f0             	pushl  -0x10(%ebp)
80100dea:	e8 07 f7 ff ff       	call   801004f6 <memset>
80100def:	83 c4 10             	add    $0x10,%esp
 
  //分配每一页 
  for(k = kmap; k < &kmap[NELEM(kmap)]; k++)
80100df2:	c7 45 f4 80 45 10 80 	movl   $0x80104580,-0xc(%ebp)
80100df9:	eb 40                	jmp    80100e3b <setupkvm+0x7a>
    if(mappages(pgdir, k->virt, k->phys_end - k->phys_start, 
80100dfb:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100dfe:	8b 48 0c             	mov    0xc(%eax),%ecx
80100e01:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100e04:	8b 50 04             	mov    0x4(%eax),%edx
80100e07:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100e0a:	8b 58 08             	mov    0x8(%eax),%ebx
80100e0d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100e10:	8b 40 04             	mov    0x4(%eax),%eax
80100e13:	29 c3                	sub    %eax,%ebx
80100e15:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100e18:	8b 00                	mov    (%eax),%eax
80100e1a:	83 ec 0c             	sub    $0xc,%esp
80100e1d:	51                   	push   %ecx
80100e1e:	52                   	push   %edx
80100e1f:	53                   	push   %ebx
80100e20:	50                   	push   %eax
80100e21:	ff 75 f0             	pushl  -0x10(%ebp)
80100e24:	e8 1f ff ff ff       	call   80100d48 <mappages>
80100e29:	83 c4 20             	add    $0x20,%esp
80100e2c:	85 c0                	test   %eax,%eax
80100e2e:	79 07                	jns    80100e37 <setupkvm+0x76>
		(uint)k->phys_start, k->perm) < 0)
      return 0;
80100e30:	b8 00 00 00 00       	mov    $0x0,%eax
80100e35:	eb 10                	jmp    80100e47 <setupkvm+0x86>
    return 0;
 
  memset(pgdir, 0, PGSIZE);
 
  //分配每一页 
  for(k = kmap; k < &kmap[NELEM(kmap)]; k++)
80100e37:	83 45 f4 10          	addl   $0x10,-0xc(%ebp)
80100e3b:	81 7d f4 c0 45 10 80 	cmpl   $0x801045c0,-0xc(%ebp)
80100e42:	72 b7                	jb     80100dfb <setupkvm+0x3a>
    if(mappages(pgdir, k->virt, k->phys_end - k->phys_start, 
		(uint)k->phys_start, k->perm) < 0)
      return 0;

  return pgdir;
80100e44:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
80100e47:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80100e4a:	c9                   	leave  
80100e4b:	c3                   	ret    

80100e4c <switchkvm>:


// 切换到页表kpgdir
void switchkvm(void)
{
80100e4c:	55                   	push   %ebp
80100e4d:	89 e5                	mov    %esp,%ebp
  lcr3(v2p(kpgdir));   // 切换到内核页表
80100e4f:	a1 e0 5f 10 80       	mov    0x80105fe0,%eax
80100e54:	50                   	push   %eax
80100e55:	e8 7e f9 ff ff       	call   801007d8 <v2p>
80100e5a:	83 c4 04             	add    $0x4,%esp
80100e5d:	50                   	push   %eax
80100e5e:	e8 6a f9 ff ff       	call   801007cd <lcr3>
80100e63:	83 c4 04             	add    $0x4,%esp
}
80100e66:	c9                   	leave  
80100e67:	c3                   	ret    

80100e68 <kvmalloc>:

void kvmalloc(void)
{
80100e68:	55                   	push   %ebp
80100e69:	89 e5                	mov    %esp,%ebp
80100e6b:	83 ec 08             	sub    $0x8,%esp
  kpgdir = setupkvm();  // 设置好页表
80100e6e:	e8 4e ff ff ff       	call   80100dc1 <setupkvm>
80100e73:	a3 e0 5f 10 80       	mov    %eax,0x80105fe0
  switchkvm();  	// 切换到内核页表
80100e78:	e8 cf ff ff ff       	call   80100e4c <switchkvm>
}
80100e7d:	c9                   	leave  
80100e7e:	c3                   	ret    

80100e7f <outb>:
               "memory", "cc");
}

static inline void
outb(ushort port, uchar data)
{
80100e7f:	55                   	push   %ebp
80100e80:	89 e5                	mov    %esp,%ebp
80100e82:	83 ec 08             	sub    $0x8,%esp
80100e85:	8b 55 08             	mov    0x8(%ebp),%edx
80100e88:	8b 45 0c             	mov    0xc(%ebp),%eax
80100e8b:	66 89 55 fc          	mov    %dx,-0x4(%ebp)
80100e8f:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80100e92:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
80100e96:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
80100e9a:	ee                   	out    %al,(%dx)
}
80100e9b:	c9                   	leave  
80100e9c:	c3                   	ret    

80100e9d <picsetmask>:

static ushort irqmask = 0xFFFF & ~(1<<IRQ_SLAVE);

static void
picsetmask(ushort mask)
{
80100e9d:	55                   	push   %ebp
80100e9e:	89 e5                	mov    %esp,%ebp
80100ea0:	83 ec 04             	sub    $0x4,%esp
80100ea3:	8b 45 08             	mov    0x8(%ebp),%eax
80100ea6:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  irqmask = mask;
80100eaa:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
80100eae:	66 a3 c0 45 10 80    	mov    %ax,0x801045c0
  outb(IO_PIC1+1, mask);
80100eb4:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
80100eb8:	0f b6 c0             	movzbl %al,%eax
80100ebb:	50                   	push   %eax
80100ebc:	6a 21                	push   $0x21
80100ebe:	e8 bc ff ff ff       	call   80100e7f <outb>
80100ec3:	83 c4 08             	add    $0x8,%esp
  outb(IO_PIC2+1, mask >> 8);
80100ec6:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
80100eca:	66 c1 e8 08          	shr    $0x8,%ax
80100ece:	0f b6 c0             	movzbl %al,%eax
80100ed1:	50                   	push   %eax
80100ed2:	68 a1 00 00 00       	push   $0xa1
80100ed7:	e8 a3 ff ff ff       	call   80100e7f <outb>
80100edc:	83 c4 08             	add    $0x8,%esp
}
80100edf:	c9                   	leave  
80100ee0:	c3                   	ret    

80100ee1 <picenable>:

void
picenable(int irq)
{
80100ee1:	55                   	push   %ebp
80100ee2:	89 e5                	mov    %esp,%ebp
  picsetmask(irqmask & ~(1<<irq));
80100ee4:	8b 45 08             	mov    0x8(%ebp),%eax
80100ee7:	ba 01 00 00 00       	mov    $0x1,%edx
80100eec:	89 c1                	mov    %eax,%ecx
80100eee:	d3 e2                	shl    %cl,%edx
80100ef0:	89 d0                	mov    %edx,%eax
80100ef2:	f7 d0                	not    %eax
80100ef4:	89 c2                	mov    %eax,%edx
80100ef6:	0f b7 05 c0 45 10 80 	movzwl 0x801045c0,%eax
80100efd:	21 d0                	and    %edx,%eax
80100eff:	0f b7 c0             	movzwl %ax,%eax
80100f02:	50                   	push   %eax
80100f03:	e8 95 ff ff ff       	call   80100e9d <picsetmask>
80100f08:	83 c4 04             	add    $0x4,%esp
}
80100f0b:	c9                   	leave  
80100f0c:	c3                   	ret    

80100f0d <picinit>:

//初始化8259A的中断控制器
void
picinit(void)
{
80100f0d:	55                   	push   %ebp
80100f0e:	89 e5                	mov    %esp,%ebp
  // 屏蔽掉所有的中断
  outb(IO_PIC1+1, 0xFF);
80100f10:	68 ff 00 00 00       	push   $0xff
80100f15:	6a 21                	push   $0x21
80100f17:	e8 63 ff ff ff       	call   80100e7f <outb>
80100f1c:	83 c4 08             	add    $0x8,%esp
  outb(IO_PIC2+1, 0xFF);
80100f1f:	68 ff 00 00 00       	push   $0xff
80100f24:	68 a1 00 00 00       	push   $0xa1
80100f29:	e8 51 ff ff ff       	call   80100e7f <outb>
80100f2e:	83 c4 08             	add    $0x8,%esp

  // 设置主控制器

  outb(IO_PIC1, 0x11);    	  	// ICW1
80100f31:	6a 11                	push   $0x11
80100f33:	6a 20                	push   $0x20
80100f35:	e8 45 ff ff ff       	call   80100e7f <outb>
80100f3a:	83 c4 08             	add    $0x8,%esp
  outb(IO_PIC1+1, T_IRQ0); 		// ICW2, 设置所有中断向量偏移地址
80100f3d:	6a 20                	push   $0x20
80100f3f:	6a 21                	push   $0x21
80100f41:	e8 39 ff ff ff       	call   80100e7f <outb>
80100f46:	83 c4 08             	add    $0x8,%esp
  outb(IO_PIC1+1, 1<<IRQ_SLAVE); 	// ICW3
80100f49:	6a 04                	push   $0x4
80100f4b:	6a 21                	push   $0x21
80100f4d:	e8 2d ff ff ff       	call   80100e7f <outb>
80100f52:	83 c4 08             	add    $0x8,%esp
  outb(IO_PIC1+1, 0x3); 		// ICW4
80100f55:	6a 03                	push   $0x3
80100f57:	6a 21                	push   $0x21
80100f59:	e8 21 ff ff ff       	call   80100e7f <outb>
80100f5e:	83 c4 08             	add    $0x8,%esp

  // 设置从控制器
  
  outb(IO_PIC2, 0x11);                  // ICW1
80100f61:	6a 11                	push   $0x11
80100f63:	68 a0 00 00 00       	push   $0xa0
80100f68:	e8 12 ff ff ff       	call   80100e7f <outb>
80100f6d:	83 c4 08             	add    $0x8,%esp
  outb(IO_PIC2+1, T_IRQ0 + 8);          // ICW2
80100f70:	6a 28                	push   $0x28
80100f72:	68 a1 00 00 00       	push   $0xa1
80100f77:	e8 03 ff ff ff       	call   80100e7f <outb>
80100f7c:	83 c4 08             	add    $0x8,%esp
  outb(IO_PIC2+1, IRQ_SLAVE);           // ICW3
80100f7f:	6a 02                	push   $0x2
80100f81:	68 a1 00 00 00       	push   $0xa1
80100f86:	e8 f4 fe ff ff       	call   80100e7f <outb>
80100f8b:	83 c4 08             	add    $0x8,%esp
  outb(IO_PIC2+1, 0x3);                 // ICW4
80100f8e:	6a 03                	push   $0x3
80100f90:	68 a1 00 00 00       	push   $0xa1
80100f95:	e8 e5 fe ff ff       	call   80100e7f <outb>
80100f9a:	83 c4 08             	add    $0x8,%esp
  
  //设置OCW3  
  outb(IO_PIC1, 0x68);            
80100f9d:	6a 68                	push   $0x68
80100f9f:	6a 20                	push   $0x20
80100fa1:	e8 d9 fe ff ff       	call   80100e7f <outb>
80100fa6:	83 c4 08             	add    $0x8,%esp
  outb(IO_PIC1, 0x0a);            
80100fa9:	6a 0a                	push   $0xa
80100fab:	6a 20                	push   $0x20
80100fad:	e8 cd fe ff ff       	call   80100e7f <outb>
80100fb2:	83 c4 08             	add    $0x8,%esp

  outb(IO_PIC2, 0x68);             // OCW3
80100fb5:	6a 68                	push   $0x68
80100fb7:	68 a0 00 00 00       	push   $0xa0
80100fbc:	e8 be fe ff ff       	call   80100e7f <outb>
80100fc1:	83 c4 08             	add    $0x8,%esp
  outb(IO_PIC2, 0x0a);             // OCW3
80100fc4:	6a 0a                	push   $0xa
80100fc6:	68 a0 00 00 00       	push   $0xa0
80100fcb:	e8 af fe ff ff       	call   80100e7f <outb>
80100fd0:	83 c4 08             	add    $0x8,%esp

  if(irqmask != 0xFFFF)
80100fd3:	0f b7 05 c0 45 10 80 	movzwl 0x801045c0,%eax
80100fda:	66 83 f8 ff          	cmp    $0xffff,%ax
80100fde:	74 13                	je     80100ff3 <picinit+0xe6>
    picsetmask(irqmask);
80100fe0:	0f b7 05 c0 45 10 80 	movzwl 0x801045c0,%eax
80100fe7:	0f b7 c0             	movzwl %ax,%eax
80100fea:	50                   	push   %eax
80100feb:	e8 ad fe ff ff       	call   80100e9d <picsetmask>
80100ff0:	83 c4 04             	add    $0x4,%esp
}
80100ff3:	c9                   	leave  
80100ff4:	c3                   	ret    

80100ff5 <ioapicwrite>:
  uint data;
};

//写入reg，并写入数据
static void ioapicwrite(int reg, uint data)
{
80100ff5:	55                   	push   %ebp
80100ff6:	89 e5                	mov    %esp,%ebp
  ioapic->reg = reg;
80100ff8:	a1 3c 60 10 80       	mov    0x8010603c,%eax
80100ffd:	8b 55 08             	mov    0x8(%ebp),%edx
80101000:	89 10                	mov    %edx,(%eax)
  ioapic->data = data;
80101002:	a1 3c 60 10 80       	mov    0x8010603c,%eax
80101007:	8b 55 0c             	mov    0xc(%ebp),%edx
8010100a:	89 50 10             	mov    %edx,0x10(%eax)
}
8010100d:	5d                   	pop    %ebp
8010100e:	c3                   	ret    

8010100f <ioapicread>:

//写入reg，并读取数据
static uint ioapicread(int reg)
{
8010100f:	55                   	push   %ebp
80101010:	89 e5                	mov    %esp,%ebp
  ioapic->reg = reg;
80101012:	a1 3c 60 10 80       	mov    0x8010603c,%eax
80101017:	8b 55 08             	mov    0x8(%ebp),%edx
8010101a:	89 10                	mov    %edx,(%eax)
  return ioapic->data;
8010101c:	a1 3c 60 10 80       	mov    0x8010603c,%eax
80101021:	8b 40 10             	mov    0x10(%eax),%eax
}
80101024:	5d                   	pop    %ebp
80101025:	c3                   	ret    

80101026 <ioapicinit>:

//IOAPIC的初始化
void ioapicinit(void)
{
80101026:	55                   	push   %ebp
80101027:	89 e5                	mov    %esp,%ebp
80101029:	83 ec 10             	sub    $0x10,%esp
  int i, maxintr;

  ioapic = (volatile struct ioapic*)IOAPIC;    //IOAPIC的默认的初始地址
8010102c:	c7 05 3c 60 10 80 00 	movl   $0xfec00000,0x8010603c
80101033:	00 c0 fe 
  maxintr = (ioapicread(REG_VER) >> 16) & 0xFF;
80101036:	6a 01                	push   $0x1
80101038:	e8 d2 ff ff ff       	call   8010100f <ioapicread>
8010103d:	83 c4 04             	add    $0x4,%esp
80101040:	c1 e8 10             	shr    $0x10,%eax
80101043:	25 ff 00 00 00       	and    $0xff,%eax
80101048:	89 45 f8             	mov    %eax,-0x8(%ebp)

  //标记所有的中断为边缘触发，激活高寄存器，关闭中断，不传送给CPU
  for(i = 0; i <= maxintr; i++){
8010104b:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
80101052:	eb 39                	jmp    8010108d <ioapicinit+0x67>
    ioapicwrite(REG_TABLE+2*i, INT_DISABLED | (T_IRQ0 + i));
80101054:	8b 45 fc             	mov    -0x4(%ebp),%eax
80101057:	83 c0 20             	add    $0x20,%eax
8010105a:	0d 00 00 01 00       	or     $0x10000,%eax
8010105f:	89 c2                	mov    %eax,%edx
80101061:	8b 45 fc             	mov    -0x4(%ebp),%eax
80101064:	83 c0 08             	add    $0x8,%eax
80101067:	01 c0                	add    %eax,%eax
80101069:	52                   	push   %edx
8010106a:	50                   	push   %eax
8010106b:	e8 85 ff ff ff       	call   80100ff5 <ioapicwrite>
80101070:	83 c4 08             	add    $0x8,%esp
    ioapicwrite(REG_TABLE+2*i+1, 0);
80101073:	8b 45 fc             	mov    -0x4(%ebp),%eax
80101076:	83 c0 08             	add    $0x8,%eax
80101079:	01 c0                	add    %eax,%eax
8010107b:	83 c0 01             	add    $0x1,%eax
8010107e:	6a 00                	push   $0x0
80101080:	50                   	push   %eax
80101081:	e8 6f ff ff ff       	call   80100ff5 <ioapicwrite>
80101086:	83 c4 08             	add    $0x8,%esp

  ioapic = (volatile struct ioapic*)IOAPIC;    //IOAPIC的默认的初始地址
  maxintr = (ioapicread(REG_VER) >> 16) & 0xFF;

  //标记所有的中断为边缘触发，激活高寄存器，关闭中断，不传送给CPU
  for(i = 0; i <= maxintr; i++){
80101089:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
8010108d:	8b 45 fc             	mov    -0x4(%ebp),%eax
80101090:	3b 45 f8             	cmp    -0x8(%ebp),%eax
80101093:	7e bf                	jle    80101054 <ioapicinit+0x2e>
    ioapicwrite(REG_TABLE+2*i, INT_DISABLED | (T_IRQ0 + i));
    ioapicwrite(REG_TABLE+2*i+1, 0);
  }
}
80101095:	c9                   	leave  
80101096:	c3                   	ret    

80101097 <ioapicenable>:

void ioapicenable(int irq, int cpunum)
{
80101097:	55                   	push   %ebp
80101098:	89 e5                	mov    %esp,%ebp
  if(!ismp)
8010109a:	a1 40 60 10 80       	mov    0x80106040,%eax
8010109f:	85 c0                	test   %eax,%eax
801010a1:	75 02                	jne    801010a5 <ioapicenable+0xe>
      return;
801010a3:	eb 37                	jmp    801010dc <ioapicenable+0x45>

  //标记所有的中断为边缘触发，激活高寄存器，打开中断，传送给CPU
  ioapicwrite(REG_TABLE+2*irq, T_IRQ0 + irq);
801010a5:	8b 45 08             	mov    0x8(%ebp),%eax
801010a8:	83 c0 20             	add    $0x20,%eax
801010ab:	89 c2                	mov    %eax,%edx
801010ad:	8b 45 08             	mov    0x8(%ebp),%eax
801010b0:	83 c0 08             	add    $0x8,%eax
801010b3:	01 c0                	add    %eax,%eax
801010b5:	52                   	push   %edx
801010b6:	50                   	push   %eax
801010b7:	e8 39 ff ff ff       	call   80100ff5 <ioapicwrite>
801010bc:	83 c4 08             	add    $0x8,%esp
  ioapicwrite(REG_TABLE+2*irq+1, cpunum << 24);
801010bf:	8b 45 0c             	mov    0xc(%ebp),%eax
801010c2:	c1 e0 18             	shl    $0x18,%eax
801010c5:	89 c2                	mov    %eax,%edx
801010c7:	8b 45 08             	mov    0x8(%ebp),%eax
801010ca:	83 c0 08             	add    $0x8,%eax
801010cd:	01 c0                	add    %eax,%eax
801010cf:	83 c0 01             	add    $0x1,%eax
801010d2:	52                   	push   %edx
801010d3:	50                   	push   %eax
801010d4:	e8 1c ff ff ff       	call   80100ff5 <ioapicwrite>
801010d9:	83 c4 08             	add    $0x8,%esp
}
801010dc:	c9                   	leave  
801010dd:	c3                   	ret    

801010de <vector0>:
# generated by vectors.pl - do not edit
# handlers
.globl alltraps
.globl vector0
vector0:
  pushl $0
801010de:	6a 00                	push   $0x0
  pushl $0
801010e0:	6a 00                	push   $0x0
  jmp alltraps
801010e2:	e9 80 0c 00 00       	jmp    80101d67 <alltraps>

801010e7 <vector1>:
.globl vector1
vector1:
  pushl $0
801010e7:	6a 00                	push   $0x0
  pushl $1
801010e9:	6a 01                	push   $0x1
  jmp alltraps
801010eb:	e9 77 0c 00 00       	jmp    80101d67 <alltraps>

801010f0 <vector2>:
.globl vector2
vector2:
  pushl $0
801010f0:	6a 00                	push   $0x0
  pushl $2
801010f2:	6a 02                	push   $0x2
  jmp alltraps
801010f4:	e9 6e 0c 00 00       	jmp    80101d67 <alltraps>

801010f9 <vector3>:
.globl vector3
vector3:
  pushl $0
801010f9:	6a 00                	push   $0x0
  pushl $3
801010fb:	6a 03                	push   $0x3
  jmp alltraps
801010fd:	e9 65 0c 00 00       	jmp    80101d67 <alltraps>

80101102 <vector4>:
.globl vector4
vector4:
  pushl $0
80101102:	6a 00                	push   $0x0
  pushl $4
80101104:	6a 04                	push   $0x4
  jmp alltraps
80101106:	e9 5c 0c 00 00       	jmp    80101d67 <alltraps>

8010110b <vector5>:
.globl vector5
vector5:
  pushl $0
8010110b:	6a 00                	push   $0x0
  pushl $5
8010110d:	6a 05                	push   $0x5
  jmp alltraps
8010110f:	e9 53 0c 00 00       	jmp    80101d67 <alltraps>

80101114 <vector6>:
.globl vector6
vector6:
  pushl $0
80101114:	6a 00                	push   $0x0
  pushl $6
80101116:	6a 06                	push   $0x6
  jmp alltraps
80101118:	e9 4a 0c 00 00       	jmp    80101d67 <alltraps>

8010111d <vector7>:
.globl vector7
vector7:
  pushl $0
8010111d:	6a 00                	push   $0x0
  pushl $7
8010111f:	6a 07                	push   $0x7
  jmp alltraps
80101121:	e9 41 0c 00 00       	jmp    80101d67 <alltraps>

80101126 <vector8>:
.globl vector8
vector8:
  pushl $8
80101126:	6a 08                	push   $0x8
  jmp alltraps
80101128:	e9 3a 0c 00 00       	jmp    80101d67 <alltraps>

8010112d <vector9>:
.globl vector9
vector9:
  pushl $0
8010112d:	6a 00                	push   $0x0
  pushl $9
8010112f:	6a 09                	push   $0x9
  jmp alltraps
80101131:	e9 31 0c 00 00       	jmp    80101d67 <alltraps>

80101136 <vector10>:
.globl vector10
vector10:
  pushl $10
80101136:	6a 0a                	push   $0xa
  jmp alltraps
80101138:	e9 2a 0c 00 00       	jmp    80101d67 <alltraps>

8010113d <vector11>:
.globl vector11
vector11:
  pushl $11
8010113d:	6a 0b                	push   $0xb
  jmp alltraps
8010113f:	e9 23 0c 00 00       	jmp    80101d67 <alltraps>

80101144 <vector12>:
.globl vector12
vector12:
  pushl $12
80101144:	6a 0c                	push   $0xc
  jmp alltraps
80101146:	e9 1c 0c 00 00       	jmp    80101d67 <alltraps>

8010114b <vector13>:
.globl vector13
vector13:
  pushl $13
8010114b:	6a 0d                	push   $0xd
  jmp alltraps
8010114d:	e9 15 0c 00 00       	jmp    80101d67 <alltraps>

80101152 <vector14>:
.globl vector14
vector14:
  pushl $14
80101152:	6a 0e                	push   $0xe
  jmp alltraps
80101154:	e9 0e 0c 00 00       	jmp    80101d67 <alltraps>

80101159 <vector15>:
.globl vector15
vector15:
  pushl $0
80101159:	6a 00                	push   $0x0
  pushl $15
8010115b:	6a 0f                	push   $0xf
  jmp alltraps
8010115d:	e9 05 0c 00 00       	jmp    80101d67 <alltraps>

80101162 <vector16>:
.globl vector16
vector16:
  pushl $0
80101162:	6a 00                	push   $0x0
  pushl $16
80101164:	6a 10                	push   $0x10
  jmp alltraps
80101166:	e9 fc 0b 00 00       	jmp    80101d67 <alltraps>

8010116b <vector17>:
.globl vector17
vector17:
  pushl $17
8010116b:	6a 11                	push   $0x11
  jmp alltraps
8010116d:	e9 f5 0b 00 00       	jmp    80101d67 <alltraps>

80101172 <vector18>:
.globl vector18
vector18:
  pushl $0
80101172:	6a 00                	push   $0x0
  pushl $18
80101174:	6a 12                	push   $0x12
  jmp alltraps
80101176:	e9 ec 0b 00 00       	jmp    80101d67 <alltraps>

8010117b <vector19>:
.globl vector19
vector19:
  pushl $0
8010117b:	6a 00                	push   $0x0
  pushl $19
8010117d:	6a 13                	push   $0x13
  jmp alltraps
8010117f:	e9 e3 0b 00 00       	jmp    80101d67 <alltraps>

80101184 <vector20>:
.globl vector20
vector20:
  pushl $0
80101184:	6a 00                	push   $0x0
  pushl $20
80101186:	6a 14                	push   $0x14
  jmp alltraps
80101188:	e9 da 0b 00 00       	jmp    80101d67 <alltraps>

8010118d <vector21>:
.globl vector21
vector21:
  pushl $0
8010118d:	6a 00                	push   $0x0
  pushl $21
8010118f:	6a 15                	push   $0x15
  jmp alltraps
80101191:	e9 d1 0b 00 00       	jmp    80101d67 <alltraps>

80101196 <vector22>:
.globl vector22
vector22:
  pushl $0
80101196:	6a 00                	push   $0x0
  pushl $22
80101198:	6a 16                	push   $0x16
  jmp alltraps
8010119a:	e9 c8 0b 00 00       	jmp    80101d67 <alltraps>

8010119f <vector23>:
.globl vector23
vector23:
  pushl $0
8010119f:	6a 00                	push   $0x0
  pushl $23
801011a1:	6a 17                	push   $0x17
  jmp alltraps
801011a3:	e9 bf 0b 00 00       	jmp    80101d67 <alltraps>

801011a8 <vector24>:
.globl vector24
vector24:
  pushl $0
801011a8:	6a 00                	push   $0x0
  pushl $24
801011aa:	6a 18                	push   $0x18
  jmp alltraps
801011ac:	e9 b6 0b 00 00       	jmp    80101d67 <alltraps>

801011b1 <vector25>:
.globl vector25
vector25:
  pushl $0
801011b1:	6a 00                	push   $0x0
  pushl $25
801011b3:	6a 19                	push   $0x19
  jmp alltraps
801011b5:	e9 ad 0b 00 00       	jmp    80101d67 <alltraps>

801011ba <vector26>:
.globl vector26
vector26:
  pushl $0
801011ba:	6a 00                	push   $0x0
  pushl $26
801011bc:	6a 1a                	push   $0x1a
  jmp alltraps
801011be:	e9 a4 0b 00 00       	jmp    80101d67 <alltraps>

801011c3 <vector27>:
.globl vector27
vector27:
  pushl $0
801011c3:	6a 00                	push   $0x0
  pushl $27
801011c5:	6a 1b                	push   $0x1b
  jmp alltraps
801011c7:	e9 9b 0b 00 00       	jmp    80101d67 <alltraps>

801011cc <vector28>:
.globl vector28
vector28:
  pushl $0
801011cc:	6a 00                	push   $0x0
  pushl $28
801011ce:	6a 1c                	push   $0x1c
  jmp alltraps
801011d0:	e9 92 0b 00 00       	jmp    80101d67 <alltraps>

801011d5 <vector29>:
.globl vector29
vector29:
  pushl $0
801011d5:	6a 00                	push   $0x0
  pushl $29
801011d7:	6a 1d                	push   $0x1d
  jmp alltraps
801011d9:	e9 89 0b 00 00       	jmp    80101d67 <alltraps>

801011de <vector30>:
.globl vector30
vector30:
  pushl $0
801011de:	6a 00                	push   $0x0
  pushl $30
801011e0:	6a 1e                	push   $0x1e
  jmp alltraps
801011e2:	e9 80 0b 00 00       	jmp    80101d67 <alltraps>

801011e7 <vector31>:
.globl vector31
vector31:
  pushl $0
801011e7:	6a 00                	push   $0x0
  pushl $31
801011e9:	6a 1f                	push   $0x1f
  jmp alltraps
801011eb:	e9 77 0b 00 00       	jmp    80101d67 <alltraps>

801011f0 <vector32>:
.globl vector32
vector32:
  pushl $0
801011f0:	6a 00                	push   $0x0
  pushl $32
801011f2:	6a 20                	push   $0x20
  jmp alltraps
801011f4:	e9 6e 0b 00 00       	jmp    80101d67 <alltraps>

801011f9 <vector33>:
.globl vector33
vector33:
  pushl $0
801011f9:	6a 00                	push   $0x0
  pushl $33
801011fb:	6a 21                	push   $0x21
  jmp alltraps
801011fd:	e9 65 0b 00 00       	jmp    80101d67 <alltraps>

80101202 <vector34>:
.globl vector34
vector34:
  pushl $0
80101202:	6a 00                	push   $0x0
  pushl $34
80101204:	6a 22                	push   $0x22
  jmp alltraps
80101206:	e9 5c 0b 00 00       	jmp    80101d67 <alltraps>

8010120b <vector35>:
.globl vector35
vector35:
  pushl $0
8010120b:	6a 00                	push   $0x0
  pushl $35
8010120d:	6a 23                	push   $0x23
  jmp alltraps
8010120f:	e9 53 0b 00 00       	jmp    80101d67 <alltraps>

80101214 <vector36>:
.globl vector36
vector36:
  pushl $0
80101214:	6a 00                	push   $0x0
  pushl $36
80101216:	6a 24                	push   $0x24
  jmp alltraps
80101218:	e9 4a 0b 00 00       	jmp    80101d67 <alltraps>

8010121d <vector37>:
.globl vector37
vector37:
  pushl $0
8010121d:	6a 00                	push   $0x0
  pushl $37
8010121f:	6a 25                	push   $0x25
  jmp alltraps
80101221:	e9 41 0b 00 00       	jmp    80101d67 <alltraps>

80101226 <vector38>:
.globl vector38
vector38:
  pushl $0
80101226:	6a 00                	push   $0x0
  pushl $38
80101228:	6a 26                	push   $0x26
  jmp alltraps
8010122a:	e9 38 0b 00 00       	jmp    80101d67 <alltraps>

8010122f <vector39>:
.globl vector39
vector39:
  pushl $0
8010122f:	6a 00                	push   $0x0
  pushl $39
80101231:	6a 27                	push   $0x27
  jmp alltraps
80101233:	e9 2f 0b 00 00       	jmp    80101d67 <alltraps>

80101238 <vector40>:
.globl vector40
vector40:
  pushl $0
80101238:	6a 00                	push   $0x0
  pushl $40
8010123a:	6a 28                	push   $0x28
  jmp alltraps
8010123c:	e9 26 0b 00 00       	jmp    80101d67 <alltraps>

80101241 <vector41>:
.globl vector41
vector41:
  pushl $0
80101241:	6a 00                	push   $0x0
  pushl $41
80101243:	6a 29                	push   $0x29
  jmp alltraps
80101245:	e9 1d 0b 00 00       	jmp    80101d67 <alltraps>

8010124a <vector42>:
.globl vector42
vector42:
  pushl $0
8010124a:	6a 00                	push   $0x0
  pushl $42
8010124c:	6a 2a                	push   $0x2a
  jmp alltraps
8010124e:	e9 14 0b 00 00       	jmp    80101d67 <alltraps>

80101253 <vector43>:
.globl vector43
vector43:
  pushl $0
80101253:	6a 00                	push   $0x0
  pushl $43
80101255:	6a 2b                	push   $0x2b
  jmp alltraps
80101257:	e9 0b 0b 00 00       	jmp    80101d67 <alltraps>

8010125c <vector44>:
.globl vector44
vector44:
  pushl $0
8010125c:	6a 00                	push   $0x0
  pushl $44
8010125e:	6a 2c                	push   $0x2c
  jmp alltraps
80101260:	e9 02 0b 00 00       	jmp    80101d67 <alltraps>

80101265 <vector45>:
.globl vector45
vector45:
  pushl $0
80101265:	6a 00                	push   $0x0
  pushl $45
80101267:	6a 2d                	push   $0x2d
  jmp alltraps
80101269:	e9 f9 0a 00 00       	jmp    80101d67 <alltraps>

8010126e <vector46>:
.globl vector46
vector46:
  pushl $0
8010126e:	6a 00                	push   $0x0
  pushl $46
80101270:	6a 2e                	push   $0x2e
  jmp alltraps
80101272:	e9 f0 0a 00 00       	jmp    80101d67 <alltraps>

80101277 <vector47>:
.globl vector47
vector47:
  pushl $0
80101277:	6a 00                	push   $0x0
  pushl $47
80101279:	6a 2f                	push   $0x2f
  jmp alltraps
8010127b:	e9 e7 0a 00 00       	jmp    80101d67 <alltraps>

80101280 <vector48>:
.globl vector48
vector48:
  pushl $0
80101280:	6a 00                	push   $0x0
  pushl $48
80101282:	6a 30                	push   $0x30
  jmp alltraps
80101284:	e9 de 0a 00 00       	jmp    80101d67 <alltraps>

80101289 <vector49>:
.globl vector49
vector49:
  pushl $0
80101289:	6a 00                	push   $0x0
  pushl $49
8010128b:	6a 31                	push   $0x31
  jmp alltraps
8010128d:	e9 d5 0a 00 00       	jmp    80101d67 <alltraps>

80101292 <vector50>:
.globl vector50
vector50:
  pushl $0
80101292:	6a 00                	push   $0x0
  pushl $50
80101294:	6a 32                	push   $0x32
  jmp alltraps
80101296:	e9 cc 0a 00 00       	jmp    80101d67 <alltraps>

8010129b <vector51>:
.globl vector51
vector51:
  pushl $0
8010129b:	6a 00                	push   $0x0
  pushl $51
8010129d:	6a 33                	push   $0x33
  jmp alltraps
8010129f:	e9 c3 0a 00 00       	jmp    80101d67 <alltraps>

801012a4 <vector52>:
.globl vector52
vector52:
  pushl $0
801012a4:	6a 00                	push   $0x0
  pushl $52
801012a6:	6a 34                	push   $0x34
  jmp alltraps
801012a8:	e9 ba 0a 00 00       	jmp    80101d67 <alltraps>

801012ad <vector53>:
.globl vector53
vector53:
  pushl $0
801012ad:	6a 00                	push   $0x0
  pushl $53
801012af:	6a 35                	push   $0x35
  jmp alltraps
801012b1:	e9 b1 0a 00 00       	jmp    80101d67 <alltraps>

801012b6 <vector54>:
.globl vector54
vector54:
  pushl $0
801012b6:	6a 00                	push   $0x0
  pushl $54
801012b8:	6a 36                	push   $0x36
  jmp alltraps
801012ba:	e9 a8 0a 00 00       	jmp    80101d67 <alltraps>

801012bf <vector55>:
.globl vector55
vector55:
  pushl $0
801012bf:	6a 00                	push   $0x0
  pushl $55
801012c1:	6a 37                	push   $0x37
  jmp alltraps
801012c3:	e9 9f 0a 00 00       	jmp    80101d67 <alltraps>

801012c8 <vector56>:
.globl vector56
vector56:
  pushl $0
801012c8:	6a 00                	push   $0x0
  pushl $56
801012ca:	6a 38                	push   $0x38
  jmp alltraps
801012cc:	e9 96 0a 00 00       	jmp    80101d67 <alltraps>

801012d1 <vector57>:
.globl vector57
vector57:
  pushl $0
801012d1:	6a 00                	push   $0x0
  pushl $57
801012d3:	6a 39                	push   $0x39
  jmp alltraps
801012d5:	e9 8d 0a 00 00       	jmp    80101d67 <alltraps>

801012da <vector58>:
.globl vector58
vector58:
  pushl $0
801012da:	6a 00                	push   $0x0
  pushl $58
801012dc:	6a 3a                	push   $0x3a
  jmp alltraps
801012de:	e9 84 0a 00 00       	jmp    80101d67 <alltraps>

801012e3 <vector59>:
.globl vector59
vector59:
  pushl $0
801012e3:	6a 00                	push   $0x0
  pushl $59
801012e5:	6a 3b                	push   $0x3b
  jmp alltraps
801012e7:	e9 7b 0a 00 00       	jmp    80101d67 <alltraps>

801012ec <vector60>:
.globl vector60
vector60:
  pushl $0
801012ec:	6a 00                	push   $0x0
  pushl $60
801012ee:	6a 3c                	push   $0x3c
  jmp alltraps
801012f0:	e9 72 0a 00 00       	jmp    80101d67 <alltraps>

801012f5 <vector61>:
.globl vector61
vector61:
  pushl $0
801012f5:	6a 00                	push   $0x0
  pushl $61
801012f7:	6a 3d                	push   $0x3d
  jmp alltraps
801012f9:	e9 69 0a 00 00       	jmp    80101d67 <alltraps>

801012fe <vector62>:
.globl vector62
vector62:
  pushl $0
801012fe:	6a 00                	push   $0x0
  pushl $62
80101300:	6a 3e                	push   $0x3e
  jmp alltraps
80101302:	e9 60 0a 00 00       	jmp    80101d67 <alltraps>

80101307 <vector63>:
.globl vector63
vector63:
  pushl $0
80101307:	6a 00                	push   $0x0
  pushl $63
80101309:	6a 3f                	push   $0x3f
  jmp alltraps
8010130b:	e9 57 0a 00 00       	jmp    80101d67 <alltraps>

80101310 <vector64>:
.globl vector64
vector64:
  pushl $0
80101310:	6a 00                	push   $0x0
  pushl $64
80101312:	6a 40                	push   $0x40
  jmp alltraps
80101314:	e9 4e 0a 00 00       	jmp    80101d67 <alltraps>

80101319 <vector65>:
.globl vector65
vector65:
  pushl $0
80101319:	6a 00                	push   $0x0
  pushl $65
8010131b:	6a 41                	push   $0x41
  jmp alltraps
8010131d:	e9 45 0a 00 00       	jmp    80101d67 <alltraps>

80101322 <vector66>:
.globl vector66
vector66:
  pushl $0
80101322:	6a 00                	push   $0x0
  pushl $66
80101324:	6a 42                	push   $0x42
  jmp alltraps
80101326:	e9 3c 0a 00 00       	jmp    80101d67 <alltraps>

8010132b <vector67>:
.globl vector67
vector67:
  pushl $0
8010132b:	6a 00                	push   $0x0
  pushl $67
8010132d:	6a 43                	push   $0x43
  jmp alltraps
8010132f:	e9 33 0a 00 00       	jmp    80101d67 <alltraps>

80101334 <vector68>:
.globl vector68
vector68:
  pushl $0
80101334:	6a 00                	push   $0x0
  pushl $68
80101336:	6a 44                	push   $0x44
  jmp alltraps
80101338:	e9 2a 0a 00 00       	jmp    80101d67 <alltraps>

8010133d <vector69>:
.globl vector69
vector69:
  pushl $0
8010133d:	6a 00                	push   $0x0
  pushl $69
8010133f:	6a 45                	push   $0x45
  jmp alltraps
80101341:	e9 21 0a 00 00       	jmp    80101d67 <alltraps>

80101346 <vector70>:
.globl vector70
vector70:
  pushl $0
80101346:	6a 00                	push   $0x0
  pushl $70
80101348:	6a 46                	push   $0x46
  jmp alltraps
8010134a:	e9 18 0a 00 00       	jmp    80101d67 <alltraps>

8010134f <vector71>:
.globl vector71
vector71:
  pushl $0
8010134f:	6a 00                	push   $0x0
  pushl $71
80101351:	6a 47                	push   $0x47
  jmp alltraps
80101353:	e9 0f 0a 00 00       	jmp    80101d67 <alltraps>

80101358 <vector72>:
.globl vector72
vector72:
  pushl $0
80101358:	6a 00                	push   $0x0
  pushl $72
8010135a:	6a 48                	push   $0x48
  jmp alltraps
8010135c:	e9 06 0a 00 00       	jmp    80101d67 <alltraps>

80101361 <vector73>:
.globl vector73
vector73:
  pushl $0
80101361:	6a 00                	push   $0x0
  pushl $73
80101363:	6a 49                	push   $0x49
  jmp alltraps
80101365:	e9 fd 09 00 00       	jmp    80101d67 <alltraps>

8010136a <vector74>:
.globl vector74
vector74:
  pushl $0
8010136a:	6a 00                	push   $0x0
  pushl $74
8010136c:	6a 4a                	push   $0x4a
  jmp alltraps
8010136e:	e9 f4 09 00 00       	jmp    80101d67 <alltraps>

80101373 <vector75>:
.globl vector75
vector75:
  pushl $0
80101373:	6a 00                	push   $0x0
  pushl $75
80101375:	6a 4b                	push   $0x4b
  jmp alltraps
80101377:	e9 eb 09 00 00       	jmp    80101d67 <alltraps>

8010137c <vector76>:
.globl vector76
vector76:
  pushl $0
8010137c:	6a 00                	push   $0x0
  pushl $76
8010137e:	6a 4c                	push   $0x4c
  jmp alltraps
80101380:	e9 e2 09 00 00       	jmp    80101d67 <alltraps>

80101385 <vector77>:
.globl vector77
vector77:
  pushl $0
80101385:	6a 00                	push   $0x0
  pushl $77
80101387:	6a 4d                	push   $0x4d
  jmp alltraps
80101389:	e9 d9 09 00 00       	jmp    80101d67 <alltraps>

8010138e <vector78>:
.globl vector78
vector78:
  pushl $0
8010138e:	6a 00                	push   $0x0
  pushl $78
80101390:	6a 4e                	push   $0x4e
  jmp alltraps
80101392:	e9 d0 09 00 00       	jmp    80101d67 <alltraps>

80101397 <vector79>:
.globl vector79
vector79:
  pushl $0
80101397:	6a 00                	push   $0x0
  pushl $79
80101399:	6a 4f                	push   $0x4f
  jmp alltraps
8010139b:	e9 c7 09 00 00       	jmp    80101d67 <alltraps>

801013a0 <vector80>:
.globl vector80
vector80:
  pushl $0
801013a0:	6a 00                	push   $0x0
  pushl $80
801013a2:	6a 50                	push   $0x50
  jmp alltraps
801013a4:	e9 be 09 00 00       	jmp    80101d67 <alltraps>

801013a9 <vector81>:
.globl vector81
vector81:
  pushl $0
801013a9:	6a 00                	push   $0x0
  pushl $81
801013ab:	6a 51                	push   $0x51
  jmp alltraps
801013ad:	e9 b5 09 00 00       	jmp    80101d67 <alltraps>

801013b2 <vector82>:
.globl vector82
vector82:
  pushl $0
801013b2:	6a 00                	push   $0x0
  pushl $82
801013b4:	6a 52                	push   $0x52
  jmp alltraps
801013b6:	e9 ac 09 00 00       	jmp    80101d67 <alltraps>

801013bb <vector83>:
.globl vector83
vector83:
  pushl $0
801013bb:	6a 00                	push   $0x0
  pushl $83
801013bd:	6a 53                	push   $0x53
  jmp alltraps
801013bf:	e9 a3 09 00 00       	jmp    80101d67 <alltraps>

801013c4 <vector84>:
.globl vector84
vector84:
  pushl $0
801013c4:	6a 00                	push   $0x0
  pushl $84
801013c6:	6a 54                	push   $0x54
  jmp alltraps
801013c8:	e9 9a 09 00 00       	jmp    80101d67 <alltraps>

801013cd <vector85>:
.globl vector85
vector85:
  pushl $0
801013cd:	6a 00                	push   $0x0
  pushl $85
801013cf:	6a 55                	push   $0x55
  jmp alltraps
801013d1:	e9 91 09 00 00       	jmp    80101d67 <alltraps>

801013d6 <vector86>:
.globl vector86
vector86:
  pushl $0
801013d6:	6a 00                	push   $0x0
  pushl $86
801013d8:	6a 56                	push   $0x56
  jmp alltraps
801013da:	e9 88 09 00 00       	jmp    80101d67 <alltraps>

801013df <vector87>:
.globl vector87
vector87:
  pushl $0
801013df:	6a 00                	push   $0x0
  pushl $87
801013e1:	6a 57                	push   $0x57
  jmp alltraps
801013e3:	e9 7f 09 00 00       	jmp    80101d67 <alltraps>

801013e8 <vector88>:
.globl vector88
vector88:
  pushl $0
801013e8:	6a 00                	push   $0x0
  pushl $88
801013ea:	6a 58                	push   $0x58
  jmp alltraps
801013ec:	e9 76 09 00 00       	jmp    80101d67 <alltraps>

801013f1 <vector89>:
.globl vector89
vector89:
  pushl $0
801013f1:	6a 00                	push   $0x0
  pushl $89
801013f3:	6a 59                	push   $0x59
  jmp alltraps
801013f5:	e9 6d 09 00 00       	jmp    80101d67 <alltraps>

801013fa <vector90>:
.globl vector90
vector90:
  pushl $0
801013fa:	6a 00                	push   $0x0
  pushl $90
801013fc:	6a 5a                	push   $0x5a
  jmp alltraps
801013fe:	e9 64 09 00 00       	jmp    80101d67 <alltraps>

80101403 <vector91>:
.globl vector91
vector91:
  pushl $0
80101403:	6a 00                	push   $0x0
  pushl $91
80101405:	6a 5b                	push   $0x5b
  jmp alltraps
80101407:	e9 5b 09 00 00       	jmp    80101d67 <alltraps>

8010140c <vector92>:
.globl vector92
vector92:
  pushl $0
8010140c:	6a 00                	push   $0x0
  pushl $92
8010140e:	6a 5c                	push   $0x5c
  jmp alltraps
80101410:	e9 52 09 00 00       	jmp    80101d67 <alltraps>

80101415 <vector93>:
.globl vector93
vector93:
  pushl $0
80101415:	6a 00                	push   $0x0
  pushl $93
80101417:	6a 5d                	push   $0x5d
  jmp alltraps
80101419:	e9 49 09 00 00       	jmp    80101d67 <alltraps>

8010141e <vector94>:
.globl vector94
vector94:
  pushl $0
8010141e:	6a 00                	push   $0x0
  pushl $94
80101420:	6a 5e                	push   $0x5e
  jmp alltraps
80101422:	e9 40 09 00 00       	jmp    80101d67 <alltraps>

80101427 <vector95>:
.globl vector95
vector95:
  pushl $0
80101427:	6a 00                	push   $0x0
  pushl $95
80101429:	6a 5f                	push   $0x5f
  jmp alltraps
8010142b:	e9 37 09 00 00       	jmp    80101d67 <alltraps>

80101430 <vector96>:
.globl vector96
vector96:
  pushl $0
80101430:	6a 00                	push   $0x0
  pushl $96
80101432:	6a 60                	push   $0x60
  jmp alltraps
80101434:	e9 2e 09 00 00       	jmp    80101d67 <alltraps>

80101439 <vector97>:
.globl vector97
vector97:
  pushl $0
80101439:	6a 00                	push   $0x0
  pushl $97
8010143b:	6a 61                	push   $0x61
  jmp alltraps
8010143d:	e9 25 09 00 00       	jmp    80101d67 <alltraps>

80101442 <vector98>:
.globl vector98
vector98:
  pushl $0
80101442:	6a 00                	push   $0x0
  pushl $98
80101444:	6a 62                	push   $0x62
  jmp alltraps
80101446:	e9 1c 09 00 00       	jmp    80101d67 <alltraps>

8010144b <vector99>:
.globl vector99
vector99:
  pushl $0
8010144b:	6a 00                	push   $0x0
  pushl $99
8010144d:	6a 63                	push   $0x63
  jmp alltraps
8010144f:	e9 13 09 00 00       	jmp    80101d67 <alltraps>

80101454 <vector100>:
.globl vector100
vector100:
  pushl $0
80101454:	6a 00                	push   $0x0
  pushl $100
80101456:	6a 64                	push   $0x64
  jmp alltraps
80101458:	e9 0a 09 00 00       	jmp    80101d67 <alltraps>

8010145d <vector101>:
.globl vector101
vector101:
  pushl $0
8010145d:	6a 00                	push   $0x0
  pushl $101
8010145f:	6a 65                	push   $0x65
  jmp alltraps
80101461:	e9 01 09 00 00       	jmp    80101d67 <alltraps>

80101466 <vector102>:
.globl vector102
vector102:
  pushl $0
80101466:	6a 00                	push   $0x0
  pushl $102
80101468:	6a 66                	push   $0x66
  jmp alltraps
8010146a:	e9 f8 08 00 00       	jmp    80101d67 <alltraps>

8010146f <vector103>:
.globl vector103
vector103:
  pushl $0
8010146f:	6a 00                	push   $0x0
  pushl $103
80101471:	6a 67                	push   $0x67
  jmp alltraps
80101473:	e9 ef 08 00 00       	jmp    80101d67 <alltraps>

80101478 <vector104>:
.globl vector104
vector104:
  pushl $0
80101478:	6a 00                	push   $0x0
  pushl $104
8010147a:	6a 68                	push   $0x68
  jmp alltraps
8010147c:	e9 e6 08 00 00       	jmp    80101d67 <alltraps>

80101481 <vector105>:
.globl vector105
vector105:
  pushl $0
80101481:	6a 00                	push   $0x0
  pushl $105
80101483:	6a 69                	push   $0x69
  jmp alltraps
80101485:	e9 dd 08 00 00       	jmp    80101d67 <alltraps>

8010148a <vector106>:
.globl vector106
vector106:
  pushl $0
8010148a:	6a 00                	push   $0x0
  pushl $106
8010148c:	6a 6a                	push   $0x6a
  jmp alltraps
8010148e:	e9 d4 08 00 00       	jmp    80101d67 <alltraps>

80101493 <vector107>:
.globl vector107
vector107:
  pushl $0
80101493:	6a 00                	push   $0x0
  pushl $107
80101495:	6a 6b                	push   $0x6b
  jmp alltraps
80101497:	e9 cb 08 00 00       	jmp    80101d67 <alltraps>

8010149c <vector108>:
.globl vector108
vector108:
  pushl $0
8010149c:	6a 00                	push   $0x0
  pushl $108
8010149e:	6a 6c                	push   $0x6c
  jmp alltraps
801014a0:	e9 c2 08 00 00       	jmp    80101d67 <alltraps>

801014a5 <vector109>:
.globl vector109
vector109:
  pushl $0
801014a5:	6a 00                	push   $0x0
  pushl $109
801014a7:	6a 6d                	push   $0x6d
  jmp alltraps
801014a9:	e9 b9 08 00 00       	jmp    80101d67 <alltraps>

801014ae <vector110>:
.globl vector110
vector110:
  pushl $0
801014ae:	6a 00                	push   $0x0
  pushl $110
801014b0:	6a 6e                	push   $0x6e
  jmp alltraps
801014b2:	e9 b0 08 00 00       	jmp    80101d67 <alltraps>

801014b7 <vector111>:
.globl vector111
vector111:
  pushl $0
801014b7:	6a 00                	push   $0x0
  pushl $111
801014b9:	6a 6f                	push   $0x6f
  jmp alltraps
801014bb:	e9 a7 08 00 00       	jmp    80101d67 <alltraps>

801014c0 <vector112>:
.globl vector112
vector112:
  pushl $0
801014c0:	6a 00                	push   $0x0
  pushl $112
801014c2:	6a 70                	push   $0x70
  jmp alltraps
801014c4:	e9 9e 08 00 00       	jmp    80101d67 <alltraps>

801014c9 <vector113>:
.globl vector113
vector113:
  pushl $0
801014c9:	6a 00                	push   $0x0
  pushl $113
801014cb:	6a 71                	push   $0x71
  jmp alltraps
801014cd:	e9 95 08 00 00       	jmp    80101d67 <alltraps>

801014d2 <vector114>:
.globl vector114
vector114:
  pushl $0
801014d2:	6a 00                	push   $0x0
  pushl $114
801014d4:	6a 72                	push   $0x72
  jmp alltraps
801014d6:	e9 8c 08 00 00       	jmp    80101d67 <alltraps>

801014db <vector115>:
.globl vector115
vector115:
  pushl $0
801014db:	6a 00                	push   $0x0
  pushl $115
801014dd:	6a 73                	push   $0x73
  jmp alltraps
801014df:	e9 83 08 00 00       	jmp    80101d67 <alltraps>

801014e4 <vector116>:
.globl vector116
vector116:
  pushl $0
801014e4:	6a 00                	push   $0x0
  pushl $116
801014e6:	6a 74                	push   $0x74
  jmp alltraps
801014e8:	e9 7a 08 00 00       	jmp    80101d67 <alltraps>

801014ed <vector117>:
.globl vector117
vector117:
  pushl $0
801014ed:	6a 00                	push   $0x0
  pushl $117
801014ef:	6a 75                	push   $0x75
  jmp alltraps
801014f1:	e9 71 08 00 00       	jmp    80101d67 <alltraps>

801014f6 <vector118>:
.globl vector118
vector118:
  pushl $0
801014f6:	6a 00                	push   $0x0
  pushl $118
801014f8:	6a 76                	push   $0x76
  jmp alltraps
801014fa:	e9 68 08 00 00       	jmp    80101d67 <alltraps>

801014ff <vector119>:
.globl vector119
vector119:
  pushl $0
801014ff:	6a 00                	push   $0x0
  pushl $119
80101501:	6a 77                	push   $0x77
  jmp alltraps
80101503:	e9 5f 08 00 00       	jmp    80101d67 <alltraps>

80101508 <vector120>:
.globl vector120
vector120:
  pushl $0
80101508:	6a 00                	push   $0x0
  pushl $120
8010150a:	6a 78                	push   $0x78
  jmp alltraps
8010150c:	e9 56 08 00 00       	jmp    80101d67 <alltraps>

80101511 <vector121>:
.globl vector121
vector121:
  pushl $0
80101511:	6a 00                	push   $0x0
  pushl $121
80101513:	6a 79                	push   $0x79
  jmp alltraps
80101515:	e9 4d 08 00 00       	jmp    80101d67 <alltraps>

8010151a <vector122>:
.globl vector122
vector122:
  pushl $0
8010151a:	6a 00                	push   $0x0
  pushl $122
8010151c:	6a 7a                	push   $0x7a
  jmp alltraps
8010151e:	e9 44 08 00 00       	jmp    80101d67 <alltraps>

80101523 <vector123>:
.globl vector123
vector123:
  pushl $0
80101523:	6a 00                	push   $0x0
  pushl $123
80101525:	6a 7b                	push   $0x7b
  jmp alltraps
80101527:	e9 3b 08 00 00       	jmp    80101d67 <alltraps>

8010152c <vector124>:
.globl vector124
vector124:
  pushl $0
8010152c:	6a 00                	push   $0x0
  pushl $124
8010152e:	6a 7c                	push   $0x7c
  jmp alltraps
80101530:	e9 32 08 00 00       	jmp    80101d67 <alltraps>

80101535 <vector125>:
.globl vector125
vector125:
  pushl $0
80101535:	6a 00                	push   $0x0
  pushl $125
80101537:	6a 7d                	push   $0x7d
  jmp alltraps
80101539:	e9 29 08 00 00       	jmp    80101d67 <alltraps>

8010153e <vector126>:
.globl vector126
vector126:
  pushl $0
8010153e:	6a 00                	push   $0x0
  pushl $126
80101540:	6a 7e                	push   $0x7e
  jmp alltraps
80101542:	e9 20 08 00 00       	jmp    80101d67 <alltraps>

80101547 <vector127>:
.globl vector127
vector127:
  pushl $0
80101547:	6a 00                	push   $0x0
  pushl $127
80101549:	6a 7f                	push   $0x7f
  jmp alltraps
8010154b:	e9 17 08 00 00       	jmp    80101d67 <alltraps>

80101550 <vector128>:
.globl vector128
vector128:
  pushl $0
80101550:	6a 00                	push   $0x0
  pushl $128
80101552:	68 80 00 00 00       	push   $0x80
  jmp alltraps
80101557:	e9 0b 08 00 00       	jmp    80101d67 <alltraps>

8010155c <vector129>:
.globl vector129
vector129:
  pushl $0
8010155c:	6a 00                	push   $0x0
  pushl $129
8010155e:	68 81 00 00 00       	push   $0x81
  jmp alltraps
80101563:	e9 ff 07 00 00       	jmp    80101d67 <alltraps>

80101568 <vector130>:
.globl vector130
vector130:
  pushl $0
80101568:	6a 00                	push   $0x0
  pushl $130
8010156a:	68 82 00 00 00       	push   $0x82
  jmp alltraps
8010156f:	e9 f3 07 00 00       	jmp    80101d67 <alltraps>

80101574 <vector131>:
.globl vector131
vector131:
  pushl $0
80101574:	6a 00                	push   $0x0
  pushl $131
80101576:	68 83 00 00 00       	push   $0x83
  jmp alltraps
8010157b:	e9 e7 07 00 00       	jmp    80101d67 <alltraps>

80101580 <vector132>:
.globl vector132
vector132:
  pushl $0
80101580:	6a 00                	push   $0x0
  pushl $132
80101582:	68 84 00 00 00       	push   $0x84
  jmp alltraps
80101587:	e9 db 07 00 00       	jmp    80101d67 <alltraps>

8010158c <vector133>:
.globl vector133
vector133:
  pushl $0
8010158c:	6a 00                	push   $0x0
  pushl $133
8010158e:	68 85 00 00 00       	push   $0x85
  jmp alltraps
80101593:	e9 cf 07 00 00       	jmp    80101d67 <alltraps>

80101598 <vector134>:
.globl vector134
vector134:
  pushl $0
80101598:	6a 00                	push   $0x0
  pushl $134
8010159a:	68 86 00 00 00       	push   $0x86
  jmp alltraps
8010159f:	e9 c3 07 00 00       	jmp    80101d67 <alltraps>

801015a4 <vector135>:
.globl vector135
vector135:
  pushl $0
801015a4:	6a 00                	push   $0x0
  pushl $135
801015a6:	68 87 00 00 00       	push   $0x87
  jmp alltraps
801015ab:	e9 b7 07 00 00       	jmp    80101d67 <alltraps>

801015b0 <vector136>:
.globl vector136
vector136:
  pushl $0
801015b0:	6a 00                	push   $0x0
  pushl $136
801015b2:	68 88 00 00 00       	push   $0x88
  jmp alltraps
801015b7:	e9 ab 07 00 00       	jmp    80101d67 <alltraps>

801015bc <vector137>:
.globl vector137
vector137:
  pushl $0
801015bc:	6a 00                	push   $0x0
  pushl $137
801015be:	68 89 00 00 00       	push   $0x89
  jmp alltraps
801015c3:	e9 9f 07 00 00       	jmp    80101d67 <alltraps>

801015c8 <vector138>:
.globl vector138
vector138:
  pushl $0
801015c8:	6a 00                	push   $0x0
  pushl $138
801015ca:	68 8a 00 00 00       	push   $0x8a
  jmp alltraps
801015cf:	e9 93 07 00 00       	jmp    80101d67 <alltraps>

801015d4 <vector139>:
.globl vector139
vector139:
  pushl $0
801015d4:	6a 00                	push   $0x0
  pushl $139
801015d6:	68 8b 00 00 00       	push   $0x8b
  jmp alltraps
801015db:	e9 87 07 00 00       	jmp    80101d67 <alltraps>

801015e0 <vector140>:
.globl vector140
vector140:
  pushl $0
801015e0:	6a 00                	push   $0x0
  pushl $140
801015e2:	68 8c 00 00 00       	push   $0x8c
  jmp alltraps
801015e7:	e9 7b 07 00 00       	jmp    80101d67 <alltraps>

801015ec <vector141>:
.globl vector141
vector141:
  pushl $0
801015ec:	6a 00                	push   $0x0
  pushl $141
801015ee:	68 8d 00 00 00       	push   $0x8d
  jmp alltraps
801015f3:	e9 6f 07 00 00       	jmp    80101d67 <alltraps>

801015f8 <vector142>:
.globl vector142
vector142:
  pushl $0
801015f8:	6a 00                	push   $0x0
  pushl $142
801015fa:	68 8e 00 00 00       	push   $0x8e
  jmp alltraps
801015ff:	e9 63 07 00 00       	jmp    80101d67 <alltraps>

80101604 <vector143>:
.globl vector143
vector143:
  pushl $0
80101604:	6a 00                	push   $0x0
  pushl $143
80101606:	68 8f 00 00 00       	push   $0x8f
  jmp alltraps
8010160b:	e9 57 07 00 00       	jmp    80101d67 <alltraps>

80101610 <vector144>:
.globl vector144
vector144:
  pushl $0
80101610:	6a 00                	push   $0x0
  pushl $144
80101612:	68 90 00 00 00       	push   $0x90
  jmp alltraps
80101617:	e9 4b 07 00 00       	jmp    80101d67 <alltraps>

8010161c <vector145>:
.globl vector145
vector145:
  pushl $0
8010161c:	6a 00                	push   $0x0
  pushl $145
8010161e:	68 91 00 00 00       	push   $0x91
  jmp alltraps
80101623:	e9 3f 07 00 00       	jmp    80101d67 <alltraps>

80101628 <vector146>:
.globl vector146
vector146:
  pushl $0
80101628:	6a 00                	push   $0x0
  pushl $146
8010162a:	68 92 00 00 00       	push   $0x92
  jmp alltraps
8010162f:	e9 33 07 00 00       	jmp    80101d67 <alltraps>

80101634 <vector147>:
.globl vector147
vector147:
  pushl $0
80101634:	6a 00                	push   $0x0
  pushl $147
80101636:	68 93 00 00 00       	push   $0x93
  jmp alltraps
8010163b:	e9 27 07 00 00       	jmp    80101d67 <alltraps>

80101640 <vector148>:
.globl vector148
vector148:
  pushl $0
80101640:	6a 00                	push   $0x0
  pushl $148
80101642:	68 94 00 00 00       	push   $0x94
  jmp alltraps
80101647:	e9 1b 07 00 00       	jmp    80101d67 <alltraps>

8010164c <vector149>:
.globl vector149
vector149:
  pushl $0
8010164c:	6a 00                	push   $0x0
  pushl $149
8010164e:	68 95 00 00 00       	push   $0x95
  jmp alltraps
80101653:	e9 0f 07 00 00       	jmp    80101d67 <alltraps>

80101658 <vector150>:
.globl vector150
vector150:
  pushl $0
80101658:	6a 00                	push   $0x0
  pushl $150
8010165a:	68 96 00 00 00       	push   $0x96
  jmp alltraps
8010165f:	e9 03 07 00 00       	jmp    80101d67 <alltraps>

80101664 <vector151>:
.globl vector151
vector151:
  pushl $0
80101664:	6a 00                	push   $0x0
  pushl $151
80101666:	68 97 00 00 00       	push   $0x97
  jmp alltraps
8010166b:	e9 f7 06 00 00       	jmp    80101d67 <alltraps>

80101670 <vector152>:
.globl vector152
vector152:
  pushl $0
80101670:	6a 00                	push   $0x0
  pushl $152
80101672:	68 98 00 00 00       	push   $0x98
  jmp alltraps
80101677:	e9 eb 06 00 00       	jmp    80101d67 <alltraps>

8010167c <vector153>:
.globl vector153
vector153:
  pushl $0
8010167c:	6a 00                	push   $0x0
  pushl $153
8010167e:	68 99 00 00 00       	push   $0x99
  jmp alltraps
80101683:	e9 df 06 00 00       	jmp    80101d67 <alltraps>

80101688 <vector154>:
.globl vector154
vector154:
  pushl $0
80101688:	6a 00                	push   $0x0
  pushl $154
8010168a:	68 9a 00 00 00       	push   $0x9a
  jmp alltraps
8010168f:	e9 d3 06 00 00       	jmp    80101d67 <alltraps>

80101694 <vector155>:
.globl vector155
vector155:
  pushl $0
80101694:	6a 00                	push   $0x0
  pushl $155
80101696:	68 9b 00 00 00       	push   $0x9b
  jmp alltraps
8010169b:	e9 c7 06 00 00       	jmp    80101d67 <alltraps>

801016a0 <vector156>:
.globl vector156
vector156:
  pushl $0
801016a0:	6a 00                	push   $0x0
  pushl $156
801016a2:	68 9c 00 00 00       	push   $0x9c
  jmp alltraps
801016a7:	e9 bb 06 00 00       	jmp    80101d67 <alltraps>

801016ac <vector157>:
.globl vector157
vector157:
  pushl $0
801016ac:	6a 00                	push   $0x0
  pushl $157
801016ae:	68 9d 00 00 00       	push   $0x9d
  jmp alltraps
801016b3:	e9 af 06 00 00       	jmp    80101d67 <alltraps>

801016b8 <vector158>:
.globl vector158
vector158:
  pushl $0
801016b8:	6a 00                	push   $0x0
  pushl $158
801016ba:	68 9e 00 00 00       	push   $0x9e
  jmp alltraps
801016bf:	e9 a3 06 00 00       	jmp    80101d67 <alltraps>

801016c4 <vector159>:
.globl vector159
vector159:
  pushl $0
801016c4:	6a 00                	push   $0x0
  pushl $159
801016c6:	68 9f 00 00 00       	push   $0x9f
  jmp alltraps
801016cb:	e9 97 06 00 00       	jmp    80101d67 <alltraps>

801016d0 <vector160>:
.globl vector160
vector160:
  pushl $0
801016d0:	6a 00                	push   $0x0
  pushl $160
801016d2:	68 a0 00 00 00       	push   $0xa0
  jmp alltraps
801016d7:	e9 8b 06 00 00       	jmp    80101d67 <alltraps>

801016dc <vector161>:
.globl vector161
vector161:
  pushl $0
801016dc:	6a 00                	push   $0x0
  pushl $161
801016de:	68 a1 00 00 00       	push   $0xa1
  jmp alltraps
801016e3:	e9 7f 06 00 00       	jmp    80101d67 <alltraps>

801016e8 <vector162>:
.globl vector162
vector162:
  pushl $0
801016e8:	6a 00                	push   $0x0
  pushl $162
801016ea:	68 a2 00 00 00       	push   $0xa2
  jmp alltraps
801016ef:	e9 73 06 00 00       	jmp    80101d67 <alltraps>

801016f4 <vector163>:
.globl vector163
vector163:
  pushl $0
801016f4:	6a 00                	push   $0x0
  pushl $163
801016f6:	68 a3 00 00 00       	push   $0xa3
  jmp alltraps
801016fb:	e9 67 06 00 00       	jmp    80101d67 <alltraps>

80101700 <vector164>:
.globl vector164
vector164:
  pushl $0
80101700:	6a 00                	push   $0x0
  pushl $164
80101702:	68 a4 00 00 00       	push   $0xa4
  jmp alltraps
80101707:	e9 5b 06 00 00       	jmp    80101d67 <alltraps>

8010170c <vector165>:
.globl vector165
vector165:
  pushl $0
8010170c:	6a 00                	push   $0x0
  pushl $165
8010170e:	68 a5 00 00 00       	push   $0xa5
  jmp alltraps
80101713:	e9 4f 06 00 00       	jmp    80101d67 <alltraps>

80101718 <vector166>:
.globl vector166
vector166:
  pushl $0
80101718:	6a 00                	push   $0x0
  pushl $166
8010171a:	68 a6 00 00 00       	push   $0xa6
  jmp alltraps
8010171f:	e9 43 06 00 00       	jmp    80101d67 <alltraps>

80101724 <vector167>:
.globl vector167
vector167:
  pushl $0
80101724:	6a 00                	push   $0x0
  pushl $167
80101726:	68 a7 00 00 00       	push   $0xa7
  jmp alltraps
8010172b:	e9 37 06 00 00       	jmp    80101d67 <alltraps>

80101730 <vector168>:
.globl vector168
vector168:
  pushl $0
80101730:	6a 00                	push   $0x0
  pushl $168
80101732:	68 a8 00 00 00       	push   $0xa8
  jmp alltraps
80101737:	e9 2b 06 00 00       	jmp    80101d67 <alltraps>

8010173c <vector169>:
.globl vector169
vector169:
  pushl $0
8010173c:	6a 00                	push   $0x0
  pushl $169
8010173e:	68 a9 00 00 00       	push   $0xa9
  jmp alltraps
80101743:	e9 1f 06 00 00       	jmp    80101d67 <alltraps>

80101748 <vector170>:
.globl vector170
vector170:
  pushl $0
80101748:	6a 00                	push   $0x0
  pushl $170
8010174a:	68 aa 00 00 00       	push   $0xaa
  jmp alltraps
8010174f:	e9 13 06 00 00       	jmp    80101d67 <alltraps>

80101754 <vector171>:
.globl vector171
vector171:
  pushl $0
80101754:	6a 00                	push   $0x0
  pushl $171
80101756:	68 ab 00 00 00       	push   $0xab
  jmp alltraps
8010175b:	e9 07 06 00 00       	jmp    80101d67 <alltraps>

80101760 <vector172>:
.globl vector172
vector172:
  pushl $0
80101760:	6a 00                	push   $0x0
  pushl $172
80101762:	68 ac 00 00 00       	push   $0xac
  jmp alltraps
80101767:	e9 fb 05 00 00       	jmp    80101d67 <alltraps>

8010176c <vector173>:
.globl vector173
vector173:
  pushl $0
8010176c:	6a 00                	push   $0x0
  pushl $173
8010176e:	68 ad 00 00 00       	push   $0xad
  jmp alltraps
80101773:	e9 ef 05 00 00       	jmp    80101d67 <alltraps>

80101778 <vector174>:
.globl vector174
vector174:
  pushl $0
80101778:	6a 00                	push   $0x0
  pushl $174
8010177a:	68 ae 00 00 00       	push   $0xae
  jmp alltraps
8010177f:	e9 e3 05 00 00       	jmp    80101d67 <alltraps>

80101784 <vector175>:
.globl vector175
vector175:
  pushl $0
80101784:	6a 00                	push   $0x0
  pushl $175
80101786:	68 af 00 00 00       	push   $0xaf
  jmp alltraps
8010178b:	e9 d7 05 00 00       	jmp    80101d67 <alltraps>

80101790 <vector176>:
.globl vector176
vector176:
  pushl $0
80101790:	6a 00                	push   $0x0
  pushl $176
80101792:	68 b0 00 00 00       	push   $0xb0
  jmp alltraps
80101797:	e9 cb 05 00 00       	jmp    80101d67 <alltraps>

8010179c <vector177>:
.globl vector177
vector177:
  pushl $0
8010179c:	6a 00                	push   $0x0
  pushl $177
8010179e:	68 b1 00 00 00       	push   $0xb1
  jmp alltraps
801017a3:	e9 bf 05 00 00       	jmp    80101d67 <alltraps>

801017a8 <vector178>:
.globl vector178
vector178:
  pushl $0
801017a8:	6a 00                	push   $0x0
  pushl $178
801017aa:	68 b2 00 00 00       	push   $0xb2
  jmp alltraps
801017af:	e9 b3 05 00 00       	jmp    80101d67 <alltraps>

801017b4 <vector179>:
.globl vector179
vector179:
  pushl $0
801017b4:	6a 00                	push   $0x0
  pushl $179
801017b6:	68 b3 00 00 00       	push   $0xb3
  jmp alltraps
801017bb:	e9 a7 05 00 00       	jmp    80101d67 <alltraps>

801017c0 <vector180>:
.globl vector180
vector180:
  pushl $0
801017c0:	6a 00                	push   $0x0
  pushl $180
801017c2:	68 b4 00 00 00       	push   $0xb4
  jmp alltraps
801017c7:	e9 9b 05 00 00       	jmp    80101d67 <alltraps>

801017cc <vector181>:
.globl vector181
vector181:
  pushl $0
801017cc:	6a 00                	push   $0x0
  pushl $181
801017ce:	68 b5 00 00 00       	push   $0xb5
  jmp alltraps
801017d3:	e9 8f 05 00 00       	jmp    80101d67 <alltraps>

801017d8 <vector182>:
.globl vector182
vector182:
  pushl $0
801017d8:	6a 00                	push   $0x0
  pushl $182
801017da:	68 b6 00 00 00       	push   $0xb6
  jmp alltraps
801017df:	e9 83 05 00 00       	jmp    80101d67 <alltraps>

801017e4 <vector183>:
.globl vector183
vector183:
  pushl $0
801017e4:	6a 00                	push   $0x0
  pushl $183
801017e6:	68 b7 00 00 00       	push   $0xb7
  jmp alltraps
801017eb:	e9 77 05 00 00       	jmp    80101d67 <alltraps>

801017f0 <vector184>:
.globl vector184
vector184:
  pushl $0
801017f0:	6a 00                	push   $0x0
  pushl $184
801017f2:	68 b8 00 00 00       	push   $0xb8
  jmp alltraps
801017f7:	e9 6b 05 00 00       	jmp    80101d67 <alltraps>

801017fc <vector185>:
.globl vector185
vector185:
  pushl $0
801017fc:	6a 00                	push   $0x0
  pushl $185
801017fe:	68 b9 00 00 00       	push   $0xb9
  jmp alltraps
80101803:	e9 5f 05 00 00       	jmp    80101d67 <alltraps>

80101808 <vector186>:
.globl vector186
vector186:
  pushl $0
80101808:	6a 00                	push   $0x0
  pushl $186
8010180a:	68 ba 00 00 00       	push   $0xba
  jmp alltraps
8010180f:	e9 53 05 00 00       	jmp    80101d67 <alltraps>

80101814 <vector187>:
.globl vector187
vector187:
  pushl $0
80101814:	6a 00                	push   $0x0
  pushl $187
80101816:	68 bb 00 00 00       	push   $0xbb
  jmp alltraps
8010181b:	e9 47 05 00 00       	jmp    80101d67 <alltraps>

80101820 <vector188>:
.globl vector188
vector188:
  pushl $0
80101820:	6a 00                	push   $0x0
  pushl $188
80101822:	68 bc 00 00 00       	push   $0xbc
  jmp alltraps
80101827:	e9 3b 05 00 00       	jmp    80101d67 <alltraps>

8010182c <vector189>:
.globl vector189
vector189:
  pushl $0
8010182c:	6a 00                	push   $0x0
  pushl $189
8010182e:	68 bd 00 00 00       	push   $0xbd
  jmp alltraps
80101833:	e9 2f 05 00 00       	jmp    80101d67 <alltraps>

80101838 <vector190>:
.globl vector190
vector190:
  pushl $0
80101838:	6a 00                	push   $0x0
  pushl $190
8010183a:	68 be 00 00 00       	push   $0xbe
  jmp alltraps
8010183f:	e9 23 05 00 00       	jmp    80101d67 <alltraps>

80101844 <vector191>:
.globl vector191
vector191:
  pushl $0
80101844:	6a 00                	push   $0x0
  pushl $191
80101846:	68 bf 00 00 00       	push   $0xbf
  jmp alltraps
8010184b:	e9 17 05 00 00       	jmp    80101d67 <alltraps>

80101850 <vector192>:
.globl vector192
vector192:
  pushl $0
80101850:	6a 00                	push   $0x0
  pushl $192
80101852:	68 c0 00 00 00       	push   $0xc0
  jmp alltraps
80101857:	e9 0b 05 00 00       	jmp    80101d67 <alltraps>

8010185c <vector193>:
.globl vector193
vector193:
  pushl $0
8010185c:	6a 00                	push   $0x0
  pushl $193
8010185e:	68 c1 00 00 00       	push   $0xc1
  jmp alltraps
80101863:	e9 ff 04 00 00       	jmp    80101d67 <alltraps>

80101868 <vector194>:
.globl vector194
vector194:
  pushl $0
80101868:	6a 00                	push   $0x0
  pushl $194
8010186a:	68 c2 00 00 00       	push   $0xc2
  jmp alltraps
8010186f:	e9 f3 04 00 00       	jmp    80101d67 <alltraps>

80101874 <vector195>:
.globl vector195
vector195:
  pushl $0
80101874:	6a 00                	push   $0x0
  pushl $195
80101876:	68 c3 00 00 00       	push   $0xc3
  jmp alltraps
8010187b:	e9 e7 04 00 00       	jmp    80101d67 <alltraps>

80101880 <vector196>:
.globl vector196
vector196:
  pushl $0
80101880:	6a 00                	push   $0x0
  pushl $196
80101882:	68 c4 00 00 00       	push   $0xc4
  jmp alltraps
80101887:	e9 db 04 00 00       	jmp    80101d67 <alltraps>

8010188c <vector197>:
.globl vector197
vector197:
  pushl $0
8010188c:	6a 00                	push   $0x0
  pushl $197
8010188e:	68 c5 00 00 00       	push   $0xc5
  jmp alltraps
80101893:	e9 cf 04 00 00       	jmp    80101d67 <alltraps>

80101898 <vector198>:
.globl vector198
vector198:
  pushl $0
80101898:	6a 00                	push   $0x0
  pushl $198
8010189a:	68 c6 00 00 00       	push   $0xc6
  jmp alltraps
8010189f:	e9 c3 04 00 00       	jmp    80101d67 <alltraps>

801018a4 <vector199>:
.globl vector199
vector199:
  pushl $0
801018a4:	6a 00                	push   $0x0
  pushl $199
801018a6:	68 c7 00 00 00       	push   $0xc7
  jmp alltraps
801018ab:	e9 b7 04 00 00       	jmp    80101d67 <alltraps>

801018b0 <vector200>:
.globl vector200
vector200:
  pushl $0
801018b0:	6a 00                	push   $0x0
  pushl $200
801018b2:	68 c8 00 00 00       	push   $0xc8
  jmp alltraps
801018b7:	e9 ab 04 00 00       	jmp    80101d67 <alltraps>

801018bc <vector201>:
.globl vector201
vector201:
  pushl $0
801018bc:	6a 00                	push   $0x0
  pushl $201
801018be:	68 c9 00 00 00       	push   $0xc9
  jmp alltraps
801018c3:	e9 9f 04 00 00       	jmp    80101d67 <alltraps>

801018c8 <vector202>:
.globl vector202
vector202:
  pushl $0
801018c8:	6a 00                	push   $0x0
  pushl $202
801018ca:	68 ca 00 00 00       	push   $0xca
  jmp alltraps
801018cf:	e9 93 04 00 00       	jmp    80101d67 <alltraps>

801018d4 <vector203>:
.globl vector203
vector203:
  pushl $0
801018d4:	6a 00                	push   $0x0
  pushl $203
801018d6:	68 cb 00 00 00       	push   $0xcb
  jmp alltraps
801018db:	e9 87 04 00 00       	jmp    80101d67 <alltraps>

801018e0 <vector204>:
.globl vector204
vector204:
  pushl $0
801018e0:	6a 00                	push   $0x0
  pushl $204
801018e2:	68 cc 00 00 00       	push   $0xcc
  jmp alltraps
801018e7:	e9 7b 04 00 00       	jmp    80101d67 <alltraps>

801018ec <vector205>:
.globl vector205
vector205:
  pushl $0
801018ec:	6a 00                	push   $0x0
  pushl $205
801018ee:	68 cd 00 00 00       	push   $0xcd
  jmp alltraps
801018f3:	e9 6f 04 00 00       	jmp    80101d67 <alltraps>

801018f8 <vector206>:
.globl vector206
vector206:
  pushl $0
801018f8:	6a 00                	push   $0x0
  pushl $206
801018fa:	68 ce 00 00 00       	push   $0xce
  jmp alltraps
801018ff:	e9 63 04 00 00       	jmp    80101d67 <alltraps>

80101904 <vector207>:
.globl vector207
vector207:
  pushl $0
80101904:	6a 00                	push   $0x0
  pushl $207
80101906:	68 cf 00 00 00       	push   $0xcf
  jmp alltraps
8010190b:	e9 57 04 00 00       	jmp    80101d67 <alltraps>

80101910 <vector208>:
.globl vector208
vector208:
  pushl $0
80101910:	6a 00                	push   $0x0
  pushl $208
80101912:	68 d0 00 00 00       	push   $0xd0
  jmp alltraps
80101917:	e9 4b 04 00 00       	jmp    80101d67 <alltraps>

8010191c <vector209>:
.globl vector209
vector209:
  pushl $0
8010191c:	6a 00                	push   $0x0
  pushl $209
8010191e:	68 d1 00 00 00       	push   $0xd1
  jmp alltraps
80101923:	e9 3f 04 00 00       	jmp    80101d67 <alltraps>

80101928 <vector210>:
.globl vector210
vector210:
  pushl $0
80101928:	6a 00                	push   $0x0
  pushl $210
8010192a:	68 d2 00 00 00       	push   $0xd2
  jmp alltraps
8010192f:	e9 33 04 00 00       	jmp    80101d67 <alltraps>

80101934 <vector211>:
.globl vector211
vector211:
  pushl $0
80101934:	6a 00                	push   $0x0
  pushl $211
80101936:	68 d3 00 00 00       	push   $0xd3
  jmp alltraps
8010193b:	e9 27 04 00 00       	jmp    80101d67 <alltraps>

80101940 <vector212>:
.globl vector212
vector212:
  pushl $0
80101940:	6a 00                	push   $0x0
  pushl $212
80101942:	68 d4 00 00 00       	push   $0xd4
  jmp alltraps
80101947:	e9 1b 04 00 00       	jmp    80101d67 <alltraps>

8010194c <vector213>:
.globl vector213
vector213:
  pushl $0
8010194c:	6a 00                	push   $0x0
  pushl $213
8010194e:	68 d5 00 00 00       	push   $0xd5
  jmp alltraps
80101953:	e9 0f 04 00 00       	jmp    80101d67 <alltraps>

80101958 <vector214>:
.globl vector214
vector214:
  pushl $0
80101958:	6a 00                	push   $0x0
  pushl $214
8010195a:	68 d6 00 00 00       	push   $0xd6
  jmp alltraps
8010195f:	e9 03 04 00 00       	jmp    80101d67 <alltraps>

80101964 <vector215>:
.globl vector215
vector215:
  pushl $0
80101964:	6a 00                	push   $0x0
  pushl $215
80101966:	68 d7 00 00 00       	push   $0xd7
  jmp alltraps
8010196b:	e9 f7 03 00 00       	jmp    80101d67 <alltraps>

80101970 <vector216>:
.globl vector216
vector216:
  pushl $0
80101970:	6a 00                	push   $0x0
  pushl $216
80101972:	68 d8 00 00 00       	push   $0xd8
  jmp alltraps
80101977:	e9 eb 03 00 00       	jmp    80101d67 <alltraps>

8010197c <vector217>:
.globl vector217
vector217:
  pushl $0
8010197c:	6a 00                	push   $0x0
  pushl $217
8010197e:	68 d9 00 00 00       	push   $0xd9
  jmp alltraps
80101983:	e9 df 03 00 00       	jmp    80101d67 <alltraps>

80101988 <vector218>:
.globl vector218
vector218:
  pushl $0
80101988:	6a 00                	push   $0x0
  pushl $218
8010198a:	68 da 00 00 00       	push   $0xda
  jmp alltraps
8010198f:	e9 d3 03 00 00       	jmp    80101d67 <alltraps>

80101994 <vector219>:
.globl vector219
vector219:
  pushl $0
80101994:	6a 00                	push   $0x0
  pushl $219
80101996:	68 db 00 00 00       	push   $0xdb
  jmp alltraps
8010199b:	e9 c7 03 00 00       	jmp    80101d67 <alltraps>

801019a0 <vector220>:
.globl vector220
vector220:
  pushl $0
801019a0:	6a 00                	push   $0x0
  pushl $220
801019a2:	68 dc 00 00 00       	push   $0xdc
  jmp alltraps
801019a7:	e9 bb 03 00 00       	jmp    80101d67 <alltraps>

801019ac <vector221>:
.globl vector221
vector221:
  pushl $0
801019ac:	6a 00                	push   $0x0
  pushl $221
801019ae:	68 dd 00 00 00       	push   $0xdd
  jmp alltraps
801019b3:	e9 af 03 00 00       	jmp    80101d67 <alltraps>

801019b8 <vector222>:
.globl vector222
vector222:
  pushl $0
801019b8:	6a 00                	push   $0x0
  pushl $222
801019ba:	68 de 00 00 00       	push   $0xde
  jmp alltraps
801019bf:	e9 a3 03 00 00       	jmp    80101d67 <alltraps>

801019c4 <vector223>:
.globl vector223
vector223:
  pushl $0
801019c4:	6a 00                	push   $0x0
  pushl $223
801019c6:	68 df 00 00 00       	push   $0xdf
  jmp alltraps
801019cb:	e9 97 03 00 00       	jmp    80101d67 <alltraps>

801019d0 <vector224>:
.globl vector224
vector224:
  pushl $0
801019d0:	6a 00                	push   $0x0
  pushl $224
801019d2:	68 e0 00 00 00       	push   $0xe0
  jmp alltraps
801019d7:	e9 8b 03 00 00       	jmp    80101d67 <alltraps>

801019dc <vector225>:
.globl vector225
vector225:
  pushl $0
801019dc:	6a 00                	push   $0x0
  pushl $225
801019de:	68 e1 00 00 00       	push   $0xe1
  jmp alltraps
801019e3:	e9 7f 03 00 00       	jmp    80101d67 <alltraps>

801019e8 <vector226>:
.globl vector226
vector226:
  pushl $0
801019e8:	6a 00                	push   $0x0
  pushl $226
801019ea:	68 e2 00 00 00       	push   $0xe2
  jmp alltraps
801019ef:	e9 73 03 00 00       	jmp    80101d67 <alltraps>

801019f4 <vector227>:
.globl vector227
vector227:
  pushl $0
801019f4:	6a 00                	push   $0x0
  pushl $227
801019f6:	68 e3 00 00 00       	push   $0xe3
  jmp alltraps
801019fb:	e9 67 03 00 00       	jmp    80101d67 <alltraps>

80101a00 <vector228>:
.globl vector228
vector228:
  pushl $0
80101a00:	6a 00                	push   $0x0
  pushl $228
80101a02:	68 e4 00 00 00       	push   $0xe4
  jmp alltraps
80101a07:	e9 5b 03 00 00       	jmp    80101d67 <alltraps>

80101a0c <vector229>:
.globl vector229
vector229:
  pushl $0
80101a0c:	6a 00                	push   $0x0
  pushl $229
80101a0e:	68 e5 00 00 00       	push   $0xe5
  jmp alltraps
80101a13:	e9 4f 03 00 00       	jmp    80101d67 <alltraps>

80101a18 <vector230>:
.globl vector230
vector230:
  pushl $0
80101a18:	6a 00                	push   $0x0
  pushl $230
80101a1a:	68 e6 00 00 00       	push   $0xe6
  jmp alltraps
80101a1f:	e9 43 03 00 00       	jmp    80101d67 <alltraps>

80101a24 <vector231>:
.globl vector231
vector231:
  pushl $0
80101a24:	6a 00                	push   $0x0
  pushl $231
80101a26:	68 e7 00 00 00       	push   $0xe7
  jmp alltraps
80101a2b:	e9 37 03 00 00       	jmp    80101d67 <alltraps>

80101a30 <vector232>:
.globl vector232
vector232:
  pushl $0
80101a30:	6a 00                	push   $0x0
  pushl $232
80101a32:	68 e8 00 00 00       	push   $0xe8
  jmp alltraps
80101a37:	e9 2b 03 00 00       	jmp    80101d67 <alltraps>

80101a3c <vector233>:
.globl vector233
vector233:
  pushl $0
80101a3c:	6a 00                	push   $0x0
  pushl $233
80101a3e:	68 e9 00 00 00       	push   $0xe9
  jmp alltraps
80101a43:	e9 1f 03 00 00       	jmp    80101d67 <alltraps>

80101a48 <vector234>:
.globl vector234
vector234:
  pushl $0
80101a48:	6a 00                	push   $0x0
  pushl $234
80101a4a:	68 ea 00 00 00       	push   $0xea
  jmp alltraps
80101a4f:	e9 13 03 00 00       	jmp    80101d67 <alltraps>

80101a54 <vector235>:
.globl vector235
vector235:
  pushl $0
80101a54:	6a 00                	push   $0x0
  pushl $235
80101a56:	68 eb 00 00 00       	push   $0xeb
  jmp alltraps
80101a5b:	e9 07 03 00 00       	jmp    80101d67 <alltraps>

80101a60 <vector236>:
.globl vector236
vector236:
  pushl $0
80101a60:	6a 00                	push   $0x0
  pushl $236
80101a62:	68 ec 00 00 00       	push   $0xec
  jmp alltraps
80101a67:	e9 fb 02 00 00       	jmp    80101d67 <alltraps>

80101a6c <vector237>:
.globl vector237
vector237:
  pushl $0
80101a6c:	6a 00                	push   $0x0
  pushl $237
80101a6e:	68 ed 00 00 00       	push   $0xed
  jmp alltraps
80101a73:	e9 ef 02 00 00       	jmp    80101d67 <alltraps>

80101a78 <vector238>:
.globl vector238
vector238:
  pushl $0
80101a78:	6a 00                	push   $0x0
  pushl $238
80101a7a:	68 ee 00 00 00       	push   $0xee
  jmp alltraps
80101a7f:	e9 e3 02 00 00       	jmp    80101d67 <alltraps>

80101a84 <vector239>:
.globl vector239
vector239:
  pushl $0
80101a84:	6a 00                	push   $0x0
  pushl $239
80101a86:	68 ef 00 00 00       	push   $0xef
  jmp alltraps
80101a8b:	e9 d7 02 00 00       	jmp    80101d67 <alltraps>

80101a90 <vector240>:
.globl vector240
vector240:
  pushl $0
80101a90:	6a 00                	push   $0x0
  pushl $240
80101a92:	68 f0 00 00 00       	push   $0xf0
  jmp alltraps
80101a97:	e9 cb 02 00 00       	jmp    80101d67 <alltraps>

80101a9c <vector241>:
.globl vector241
vector241:
  pushl $0
80101a9c:	6a 00                	push   $0x0
  pushl $241
80101a9e:	68 f1 00 00 00       	push   $0xf1
  jmp alltraps
80101aa3:	e9 bf 02 00 00       	jmp    80101d67 <alltraps>

80101aa8 <vector242>:
.globl vector242
vector242:
  pushl $0
80101aa8:	6a 00                	push   $0x0
  pushl $242
80101aaa:	68 f2 00 00 00       	push   $0xf2
  jmp alltraps
80101aaf:	e9 b3 02 00 00       	jmp    80101d67 <alltraps>

80101ab4 <vector243>:
.globl vector243
vector243:
  pushl $0
80101ab4:	6a 00                	push   $0x0
  pushl $243
80101ab6:	68 f3 00 00 00       	push   $0xf3
  jmp alltraps
80101abb:	e9 a7 02 00 00       	jmp    80101d67 <alltraps>

80101ac0 <vector244>:
.globl vector244
vector244:
  pushl $0
80101ac0:	6a 00                	push   $0x0
  pushl $244
80101ac2:	68 f4 00 00 00       	push   $0xf4
  jmp alltraps
80101ac7:	e9 9b 02 00 00       	jmp    80101d67 <alltraps>

80101acc <vector245>:
.globl vector245
vector245:
  pushl $0
80101acc:	6a 00                	push   $0x0
  pushl $245
80101ace:	68 f5 00 00 00       	push   $0xf5
  jmp alltraps
80101ad3:	e9 8f 02 00 00       	jmp    80101d67 <alltraps>

80101ad8 <vector246>:
.globl vector246
vector246:
  pushl $0
80101ad8:	6a 00                	push   $0x0
  pushl $246
80101ada:	68 f6 00 00 00       	push   $0xf6
  jmp alltraps
80101adf:	e9 83 02 00 00       	jmp    80101d67 <alltraps>

80101ae4 <vector247>:
.globl vector247
vector247:
  pushl $0
80101ae4:	6a 00                	push   $0x0
  pushl $247
80101ae6:	68 f7 00 00 00       	push   $0xf7
  jmp alltraps
80101aeb:	e9 77 02 00 00       	jmp    80101d67 <alltraps>

80101af0 <vector248>:
.globl vector248
vector248:
  pushl $0
80101af0:	6a 00                	push   $0x0
  pushl $248
80101af2:	68 f8 00 00 00       	push   $0xf8
  jmp alltraps
80101af7:	e9 6b 02 00 00       	jmp    80101d67 <alltraps>

80101afc <vector249>:
.globl vector249
vector249:
  pushl $0
80101afc:	6a 00                	push   $0x0
  pushl $249
80101afe:	68 f9 00 00 00       	push   $0xf9
  jmp alltraps
80101b03:	e9 5f 02 00 00       	jmp    80101d67 <alltraps>

80101b08 <vector250>:
.globl vector250
vector250:
  pushl $0
80101b08:	6a 00                	push   $0x0
  pushl $250
80101b0a:	68 fa 00 00 00       	push   $0xfa
  jmp alltraps
80101b0f:	e9 53 02 00 00       	jmp    80101d67 <alltraps>

80101b14 <vector251>:
.globl vector251
vector251:
  pushl $0
80101b14:	6a 00                	push   $0x0
  pushl $251
80101b16:	68 fb 00 00 00       	push   $0xfb
  jmp alltraps
80101b1b:	e9 47 02 00 00       	jmp    80101d67 <alltraps>

80101b20 <vector252>:
.globl vector252
vector252:
  pushl $0
80101b20:	6a 00                	push   $0x0
  pushl $252
80101b22:	68 fc 00 00 00       	push   $0xfc
  jmp alltraps
80101b27:	e9 3b 02 00 00       	jmp    80101d67 <alltraps>

80101b2c <vector253>:
.globl vector253
vector253:
  pushl $0
80101b2c:	6a 00                	push   $0x0
  pushl $253
80101b2e:	68 fd 00 00 00       	push   $0xfd
  jmp alltraps
80101b33:	e9 2f 02 00 00       	jmp    80101d67 <alltraps>

80101b38 <vector254>:
.globl vector254
vector254:
  pushl $0
80101b38:	6a 00                	push   $0x0
  pushl $254
80101b3a:	68 fe 00 00 00       	push   $0xfe
  jmp alltraps
80101b3f:	e9 23 02 00 00       	jmp    80101d67 <alltraps>

80101b44 <vector255>:
.globl vector255
vector255:
  pushl $0
80101b44:	6a 00                	push   $0x0
  pushl $255
80101b46:	68 ff 00 00 00       	push   $0xff
  jmp alltraps
80101b4b:	e9 17 02 00 00       	jmp    80101d67 <alltraps>

80101b50 <lidt>:

struct gatedesc;

static inline void
lidt(struct gatedesc *p, int size)
{
80101b50:	55                   	push   %ebp
80101b51:	89 e5                	mov    %esp,%ebp
80101b53:	83 ec 10             	sub    $0x10,%esp
  volatile ushort pd[3];

  pd[0] = size-1;
80101b56:	8b 45 0c             	mov    0xc(%ebp),%eax
80101b59:	83 e8 01             	sub    $0x1,%eax
80101b5c:	66 89 45 fa          	mov    %ax,-0x6(%ebp)
  pd[1] = (uint)p;
80101b60:	8b 45 08             	mov    0x8(%ebp),%eax
80101b63:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  pd[2] = (uint)p >> 16;
80101b67:	8b 45 08             	mov    0x8(%ebp),%eax
80101b6a:	c1 e8 10             	shr    $0x10,%eax
80101b6d:	66 89 45 fe          	mov    %ax,-0x2(%ebp)

  asm volatile("lidt (%0)" : : "r" (pd));
80101b71:	8d 45 fa             	lea    -0x6(%ebp),%eax
80101b74:	0f 01 18             	lidtl  (%eax)
}
80101b77:	c9                   	leave  
80101b78:	c3                   	ret    

80101b79 <tvinit>:


// 中断描述符表初始化，将IDT中的每一个中断描述符都与vector.S中256个中断的地址相对应
void
tvinit(void)
{
80101b79:	55                   	push   %ebp
80101b7a:	89 e5                	mov    %esp,%ebp
80101b7c:	83 ec 10             	sub    $0x10,%esp
  int i;
  for(i = 0; i < 256; i++)
80101b7f:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
80101b86:	e9 c3 00 00 00       	jmp    80101c4e <tvinit+0xd5>
    SETGATE(idt[i], 0, SEG_KCODE<<3, vectors[i], 0);
80101b8b:	8b 45 fc             	mov    -0x4(%ebp),%eax
80101b8e:	8b 04 85 c2 45 10 80 	mov    -0x7fefba3e(,%eax,4),%eax
80101b95:	89 c2                	mov    %eax,%edx
80101b97:	8b 45 fc             	mov    -0x4(%ebp),%eax
80101b9a:	66 89 14 c5 80 60 10 	mov    %dx,-0x7fef9f80(,%eax,8)
80101ba1:	80 
80101ba2:	8b 45 fc             	mov    -0x4(%ebp),%eax
80101ba5:	66 c7 04 c5 82 60 10 	movw   $0x8,-0x7fef9f7e(,%eax,8)
80101bac:	80 08 00 
80101baf:	8b 45 fc             	mov    -0x4(%ebp),%eax
80101bb2:	0f b6 14 c5 84 60 10 	movzbl -0x7fef9f7c(,%eax,8),%edx
80101bb9:	80 
80101bba:	83 e2 e0             	and    $0xffffffe0,%edx
80101bbd:	88 14 c5 84 60 10 80 	mov    %dl,-0x7fef9f7c(,%eax,8)
80101bc4:	8b 45 fc             	mov    -0x4(%ebp),%eax
80101bc7:	0f b6 14 c5 84 60 10 	movzbl -0x7fef9f7c(,%eax,8),%edx
80101bce:	80 
80101bcf:	83 e2 1f             	and    $0x1f,%edx
80101bd2:	88 14 c5 84 60 10 80 	mov    %dl,-0x7fef9f7c(,%eax,8)
80101bd9:	8b 45 fc             	mov    -0x4(%ebp),%eax
80101bdc:	0f b6 14 c5 85 60 10 	movzbl -0x7fef9f7b(,%eax,8),%edx
80101be3:	80 
80101be4:	83 e2 f0             	and    $0xfffffff0,%edx
80101be7:	83 ca 0e             	or     $0xe,%edx
80101bea:	88 14 c5 85 60 10 80 	mov    %dl,-0x7fef9f7b(,%eax,8)
80101bf1:	8b 45 fc             	mov    -0x4(%ebp),%eax
80101bf4:	0f b6 14 c5 85 60 10 	movzbl -0x7fef9f7b(,%eax,8),%edx
80101bfb:	80 
80101bfc:	83 e2 ef             	and    $0xffffffef,%edx
80101bff:	88 14 c5 85 60 10 80 	mov    %dl,-0x7fef9f7b(,%eax,8)
80101c06:	8b 45 fc             	mov    -0x4(%ebp),%eax
80101c09:	0f b6 14 c5 85 60 10 	movzbl -0x7fef9f7b(,%eax,8),%edx
80101c10:	80 
80101c11:	83 e2 9f             	and    $0xffffff9f,%edx
80101c14:	88 14 c5 85 60 10 80 	mov    %dl,-0x7fef9f7b(,%eax,8)
80101c1b:	8b 45 fc             	mov    -0x4(%ebp),%eax
80101c1e:	0f b6 14 c5 85 60 10 	movzbl -0x7fef9f7b(,%eax,8),%edx
80101c25:	80 
80101c26:	83 ca 80             	or     $0xffffff80,%edx
80101c29:	88 14 c5 85 60 10 80 	mov    %dl,-0x7fef9f7b(,%eax,8)
80101c30:	8b 45 fc             	mov    -0x4(%ebp),%eax
80101c33:	8b 04 85 c2 45 10 80 	mov    -0x7fefba3e(,%eax,4),%eax
80101c3a:	c1 e8 10             	shr    $0x10,%eax
80101c3d:	89 c2                	mov    %eax,%edx
80101c3f:	8b 45 fc             	mov    -0x4(%ebp),%eax
80101c42:	66 89 14 c5 86 60 10 	mov    %dx,-0x7fef9f7a(,%eax,8)
80101c49:	80 
// 中断描述符表初始化，将IDT中的每一个中断描述符都与vector.S中256个中断的地址相对应
void
tvinit(void)
{
  int i;
  for(i = 0; i < 256; i++)
80101c4a:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
80101c4e:	81 7d fc ff 00 00 00 	cmpl   $0xff,-0x4(%ebp)
80101c55:	0f 8e 30 ff ff ff    	jle    80101b8b <tvinit+0x12>
    SETGATE(idt[i], 0, SEG_KCODE<<3, vectors[i], 0);
  SETGATE(idt[T_SYSCALL], 1, SEG_KCODE<<3, vectors[T_SYSCALL], DPL_USER);
80101c5b:	a1 c2 46 10 80       	mov    0x801046c2,%eax
80101c60:	66 a3 80 62 10 80    	mov    %ax,0x80106280
80101c66:	66 c7 05 82 62 10 80 	movw   $0x8,0x80106282
80101c6d:	08 00 
80101c6f:	0f b6 05 84 62 10 80 	movzbl 0x80106284,%eax
80101c76:	83 e0 e0             	and    $0xffffffe0,%eax
80101c79:	a2 84 62 10 80       	mov    %al,0x80106284
80101c7e:	0f b6 05 84 62 10 80 	movzbl 0x80106284,%eax
80101c85:	83 e0 1f             	and    $0x1f,%eax
80101c88:	a2 84 62 10 80       	mov    %al,0x80106284
80101c8d:	0f b6 05 85 62 10 80 	movzbl 0x80106285,%eax
80101c94:	83 c8 0f             	or     $0xf,%eax
80101c97:	a2 85 62 10 80       	mov    %al,0x80106285
80101c9c:	0f b6 05 85 62 10 80 	movzbl 0x80106285,%eax
80101ca3:	83 e0 ef             	and    $0xffffffef,%eax
80101ca6:	a2 85 62 10 80       	mov    %al,0x80106285
80101cab:	0f b6 05 85 62 10 80 	movzbl 0x80106285,%eax
80101cb2:	83 c8 60             	or     $0x60,%eax
80101cb5:	a2 85 62 10 80       	mov    %al,0x80106285
80101cba:	0f b6 05 85 62 10 80 	movzbl 0x80106285,%eax
80101cc1:	83 c8 80             	or     $0xffffff80,%eax
80101cc4:	a2 85 62 10 80       	mov    %al,0x80106285
80101cc9:	a1 c2 46 10 80       	mov    0x801046c2,%eax
80101cce:	c1 e8 10             	shr    $0x10,%eax
80101cd1:	66 a3 86 62 10 80    	mov    %ax,0x80106286
}
80101cd7:	c9                   	leave  
80101cd8:	c3                   	ret    

80101cd9 <printidt>:

// 打印一些当前IDT内中的一些信息
void 
printidt(void)
{
80101cd9:	55                   	push   %ebp
80101cda:	89 e5                	mov    %esp,%ebp
80101cdc:	83 ec 18             	sub    $0x18,%esp
  int i = 0;
80101cdf:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  for(;i<=10;i++){
80101ce6:	eb 48                	jmp    80101d30 <printidt+0x57>
	cprintf("IDT %d: offset 31~16:%d\n", i, idt[i].off_31_16);
80101ce8:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101ceb:	0f b7 04 c5 86 60 10 	movzwl -0x7fef9f7a(,%eax,8),%eax
80101cf2:	80 
80101cf3:	0f b7 c0             	movzwl %ax,%eax
80101cf6:	83 ec 04             	sub    $0x4,%esp
80101cf9:	50                   	push   %eax
80101cfa:	ff 75 f4             	pushl  -0xc(%ebp)
80101cfd:	68 e7 1f 10 80       	push   $0x80101fe7
80101d02:	e8 82 e4 ff ff       	call   80100189 <cprintf>
80101d07:	83 c4 10             	add    $0x10,%esp
	cprintf("IDT %d: offset 15~0:%d\n", i, idt[i].off_15_0);
80101d0a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101d0d:	0f b7 04 c5 80 60 10 	movzwl -0x7fef9f80(,%eax,8),%eax
80101d14:	80 
80101d15:	0f b7 c0             	movzwl %ax,%eax
80101d18:	83 ec 04             	sub    $0x4,%esp
80101d1b:	50                   	push   %eax
80101d1c:	ff 75 f4             	pushl  -0xc(%ebp)
80101d1f:	68 00 20 10 80       	push   $0x80102000
80101d24:	e8 60 e4 ff ff       	call   80100189 <cprintf>
80101d29:	83 c4 10             	add    $0x10,%esp
// 打印一些当前IDT内中的一些信息
void 
printidt(void)
{
  int i = 0;
  for(;i<=10;i++){
80101d2c:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80101d30:	83 7d f4 0a          	cmpl   $0xa,-0xc(%ebp)
80101d34:	7e b2                	jle    80101ce8 <printidt+0xf>
	cprintf("IDT %d: offset 31~16:%d\n", i, idt[i].off_31_16);
	cprintf("IDT %d: offset 15~0:%d\n", i, idt[i].off_15_0);
  }
}
80101d36:	c9                   	leave  
80101d37:	c3                   	ret    

80101d38 <idtinit>:

// 加载idt，调用内联汇编
void
idtinit(void)
{
80101d38:	55                   	push   %ebp
80101d39:	89 e5                	mov    %esp,%ebp
  lidt(idt, sizeof(idt));
80101d3b:	68 00 08 00 00       	push   $0x800
80101d40:	68 80 60 10 80       	push   $0x80106080
80101d45:	e8 06 fe ff ff       	call   80101b50 <lidt>
80101d4a:	83 c4 08             	add    $0x8,%esp
}
80101d4d:	c9                   	leave  
80101d4e:	c3                   	ret    

80101d4f <trap>:

// 中断处理程序,目前什么都不做
void
trap(struct trapframe *tf)
{
80101d4f:	55                   	push   %ebp
80101d50:	89 e5                	mov    %esp,%ebp
80101d52:	83 ec 08             	sub    $0x8,%esp
  uint st, data, c;
   if(tf->trapno == (T_IRQ0 + IRQ_KBD)){
80101d55:	8b 45 08             	mov    0x8(%ebp),%eax
80101d58:	8b 40 30             	mov    0x30(%eax),%eax
80101d5b:	83 f8 21             	cmp    $0x21,%eax
80101d5e:	75 05                	jne    80101d65 <trap+0x16>
       kbdintr();
80101d60:	e8 12 ea ff ff       	call   80100777 <kbdintr>
  }	
}
80101d65:	c9                   	leave  
80101d66:	c3                   	ret    

80101d67 <alltraps>:
  # vectors.S 会把所有的中断都掉转到这里
.globl alltraps

alltraps:
  # 建立一个中断帧，保护现场
  pushl %ds
80101d67:	1e                   	push   %ds
  pushl %es
80101d68:	06                   	push   %es
  pushl %fs
80101d69:	0f a0                	push   %fs
  pushl %gs
80101d6b:	0f a8                	push   %gs
  pushal
80101d6d:	60                   	pusha  
  
  # 设置数据段
  movw $(SEG_KDATA<<3), %ax
80101d6e:	66 b8 10 00          	mov    $0x10,%ax
  movw %ax, %ds
80101d72:	8e d8                	mov    %eax,%ds
  movw %ax, %es
80101d74:	8e c0                	mov    %eax,%es

  # 调用trap函数，执行中断服务程序，目前针对所有中断都不做任何处理
  # 定义在了trap.c中，同时压栈esp，这里的esp就代表了trap的参数tf，也就是当前的中断帧
  pushl %esp
80101d76:	54                   	push   %esp
  call trap
80101d77:	e8 d3 ff ff ff       	call   80101d4f <trap>
  addl $4, %esp
80101d7c:	83 c4 04             	add    $0x4,%esp

80101d7f <trapret>:

  # 执行完中断服务程序以后开始恢复现场
.globl trapret
trapret:
  popal
80101d7f:	61                   	popa   
  popl %gs
80101d80:	0f a9                	pop    %gs
  popl %fs
80101d82:	0f a1                	pop    %fs
  popl %es
80101d84:	07                   	pop    %es
  popl %ds
80101d85:	1f                   	pop    %ds
  addl $0x8, %esp  # 中断号以及错误号
80101d86:	83 c4 08             	add    $0x8,%esp
  iret
80101d89:	cf                   	iret   

80101d8a <inb>:
// Routines to let C code use special x86 instructions.

static inline uchar
inb(ushort port)
{
80101d8a:	55                   	push   %ebp
80101d8b:	89 e5                	mov    %esp,%ebp
80101d8d:	83 ec 14             	sub    $0x14,%esp
80101d90:	8b 45 08             	mov    0x8(%ebp),%eax
80101d93:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
  uchar data;

  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80101d97:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
80101d9b:	89 c2                	mov    %eax,%edx
80101d9d:	ec                   	in     (%dx),%al
80101d9e:	88 45 ff             	mov    %al,-0x1(%ebp)
  return data;
80101da1:	0f b6 45 ff          	movzbl -0x1(%ebp),%eax
}
80101da5:	c9                   	leave  
80101da6:	c3                   	ret    

80101da7 <outb>:
               "memory", "cc");
}

static inline void
outb(ushort port, uchar data)
{
80101da7:	55                   	push   %ebp
80101da8:	89 e5                	mov    %esp,%ebp
80101daa:	83 ec 08             	sub    $0x8,%esp
80101dad:	8b 55 08             	mov    0x8(%ebp),%edx
80101db0:	8b 45 0c             	mov    0xc(%ebp),%eax
80101db3:	66 89 55 fc          	mov    %dx,-0x4(%ebp)
80101db7:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80101dba:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
80101dbe:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
80101dc2:	ee                   	out    %al,(%dx)
}
80101dc3:	c9                   	leave  
80101dc4:	c3                   	ret    

80101dc5 <uartputc>:

#define COM1    0x3f8

void
uartputc(int c)
{
80101dc5:	55                   	push   %ebp
80101dc6:	89 e5                	mov    %esp,%ebp
80101dc8:	83 ec 10             	sub    $0x10,%esp
  int i;
  for(i = 0; i < 128 && !(inb(COM1+5) & 0x20); i++)
80101dcb:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
80101dd2:	eb 18                	jmp    80101dec <uartputc+0x27>
  outb(COM1+0, c);
80101dd4:	8b 45 08             	mov    0x8(%ebp),%eax
80101dd7:	0f b6 c0             	movzbl %al,%eax
80101dda:	50                   	push   %eax
80101ddb:	68 f8 03 00 00       	push   $0x3f8
80101de0:	e8 c2 ff ff ff       	call   80101da7 <outb>
80101de5:	83 c4 08             	add    $0x8,%esp

void
uartputc(int c)
{
  int i;
  for(i = 0; i < 128 && !(inb(COM1+5) & 0x20); i++)
80101de8:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
80101dec:	83 7d fc 7f          	cmpl   $0x7f,-0x4(%ebp)
80101df0:	7f 17                	jg     80101e09 <uartputc+0x44>
80101df2:	68 fd 03 00 00       	push   $0x3fd
80101df7:	e8 8e ff ff ff       	call   80101d8a <inb>
80101dfc:	83 c4 04             	add    $0x4,%esp
80101dff:	0f b6 c0             	movzbl %al,%eax
80101e02:	83 e0 20             	and    $0x20,%eax
80101e05:	85 c0                	test   %eax,%eax
80101e07:	74 cb                	je     80101dd4 <uartputc+0xf>
  outb(COM1+0, c);
}
80101e09:	c9                   	leave  
80101e0a:	c3                   	ret    
