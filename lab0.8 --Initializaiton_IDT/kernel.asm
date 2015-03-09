
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
80100015:	b8 00 20 10 00       	mov    $0x102000,%eax
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
80100028:	bc 40 44 10 80       	mov    $0x80104440,%esp

  # Jump to main(), and switch to executing at
  # high addresses. The indirect call is needed because
  # the assembler produces a PC-relative instruction
  # for a direct jump.
  mov $main, %eax
8010002d:	b8 34 00 10 80       	mov    $0x80100034,%eax
  jmp *%eax
80100032:	ff e0                	jmp    *%eax

80100034 <main>:
extern char end[]; // first address after kernel loaded from ELF file


int
main(void)
{
80100034:	8d 4c 24 04          	lea    0x4(%esp),%ecx
80100038:	83 e4 f0             	and    $0xfffffff0,%esp
8010003b:	ff 71 fc             	pushl  -0x4(%ecx)
8010003e:	55                   	push   %ebp
8010003f:	89 e5                	mov    %esp,%ebp
80100041:	51                   	push   %ecx
80100042:	83 ec 04             	sub    $0x4,%esp
  cprintf("Test for printing\n");
80100045:	83 ec 0c             	sub    $0xc,%esp
80100048:	68 98 16 10 80       	push   $0x80101698
8010004d:	e8 17 01 00 00       	call   80100169 <cprintf>
80100052:	83 c4 10             	add    $0x10,%esp
  
  kinit(end, P2V(4*1024*1024));  // 物理页的分配
80100055:	83 ec 08             	sub    $0x8,%esp
80100058:	68 00 00 40 80       	push   $0x80400000
8010005d:	68 80 4c 10 80       	push   $0x80104c80
80100062:	e8 e3 04 00 00       	call   8010054a <kinit>
80100067:	83 c4 10             	add    $0x10,%esp
  seginit();   			 // 初始化段，这里对段的初始化是对当前cpu的gdt的初始化
8010006a:	e8 1d 05 00 00       	call   8010058c <seginit>
//  segshow();   		 // 打印一些段的信息，用来验证


  tvinit(); 			 // 初始化idt，扩充idt中中断描述符的内容
8010006f:	e8 a2 13 00 00       	call   80101416 <tvinit>
  idtinit(); 			 // 加载idt
80100074:	e8 5c 15 00 00       	call   801015d5 <idtinit>
  printidt(); 			 // 打印一些idt的信息，用来验证
80100079:	e8 f8 14 00 00       	call   80101576 <printidt>
  while(1);
8010007e:	eb fe                	jmp    8010007e <main+0x4a>

80100080 <inb>:
// Routines to let C code use special x86 instructions.

static inline uchar
inb(ushort port)
{
80100080:	55                   	push   %ebp
80100081:	89 e5                	mov    %esp,%ebp
80100083:	83 ec 14             	sub    $0x14,%esp
80100086:	8b 45 08             	mov    0x8(%ebp),%eax
80100089:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
  uchar data;

  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
8010008d:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
80100091:	89 c2                	mov    %eax,%edx
80100093:	ec                   	in     (%dx),%al
80100094:	88 45 ff             	mov    %al,-0x1(%ebp)
  return data;
80100097:	0f b6 45 ff          	movzbl -0x1(%ebp),%eax
}
8010009b:	c9                   	leave  
8010009c:	c3                   	ret    

8010009d <outb>:
               "memory", "cc");
}

static inline void
outb(ushort port, uchar data)
{
8010009d:	55                   	push   %ebp
8010009e:	89 e5                	mov    %esp,%ebp
801000a0:	83 ec 08             	sub    $0x8,%esp
801000a3:	8b 55 08             	mov    0x8(%ebp),%edx
801000a6:	8b 45 0c             	mov    0xc(%ebp),%eax
801000a9:	66 89 55 fc          	mov    %dx,-0x4(%ebp)
801000ad:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
801000b0:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
801000b4:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
801000b8:	ee                   	out    %al,(%dx)
}
801000b9:	c9                   	leave  
801000ba:	c3                   	ret    

801000bb <printint>:
static void consputc(int);


static void
printint(int xx, int base, int sign)
{
801000bb:	55                   	push   %ebp
801000bc:	89 e5                	mov    %esp,%ebp
801000be:	53                   	push   %ebx
801000bf:	83 ec 24             	sub    $0x24,%esp
  static char digits[] = "0123456789abcdef";
  char buf[16];
  int i;
  uint x;

  if(sign && (sign = xx < 0))
801000c2:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
801000c6:	74 1c                	je     801000e4 <printint+0x29>
801000c8:	8b 45 08             	mov    0x8(%ebp),%eax
801000cb:	c1 e8 1f             	shr    $0x1f,%eax
801000ce:	0f b6 c0             	movzbl %al,%eax
801000d1:	89 45 10             	mov    %eax,0x10(%ebp)
801000d4:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
801000d8:	74 0a                	je     801000e4 <printint+0x29>
    x = -xx;
801000da:	8b 45 08             	mov    0x8(%ebp),%eax
801000dd:	f7 d8                	neg    %eax
801000df:	89 45 f0             	mov    %eax,-0x10(%ebp)
801000e2:	eb 06                	jmp    801000ea <printint+0x2f>
  else
    x = xx;
801000e4:	8b 45 08             	mov    0x8(%ebp),%eax
801000e7:	89 45 f0             	mov    %eax,-0x10(%ebp)

  i = 0;
801000ea:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  do{
    buf[i++] = digits[x % base];
801000f1:	8b 4d f4             	mov    -0xc(%ebp),%ecx
801000f4:	8d 41 01             	lea    0x1(%ecx),%eax
801000f7:	89 45 f4             	mov    %eax,-0xc(%ebp)
801000fa:	8b 5d 0c             	mov    0xc(%ebp),%ebx
801000fd:	8b 45 f0             	mov    -0x10(%ebp),%eax
80100100:	ba 00 00 00 00       	mov    $0x0,%edx
80100105:	f7 f3                	div    %ebx
80100107:	89 d0                	mov    %edx,%eax
80100109:	0f b6 80 04 30 10 80 	movzbl -0x7fefcffc(%eax),%eax
80100110:	88 44 0d e0          	mov    %al,-0x20(%ebp,%ecx,1)
  }while((x /= base) != 0);
80100114:	8b 5d 0c             	mov    0xc(%ebp),%ebx
80100117:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010011a:	ba 00 00 00 00       	mov    $0x0,%edx
8010011f:	f7 f3                	div    %ebx
80100121:	89 45 f0             	mov    %eax,-0x10(%ebp)
80100124:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80100128:	75 c7                	jne    801000f1 <printint+0x36>

  if(sign)
8010012a:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
8010012e:	74 0e                	je     8010013e <printint+0x83>
    buf[i++] = '-';
80100130:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100133:	8d 50 01             	lea    0x1(%eax),%edx
80100136:	89 55 f4             	mov    %edx,-0xc(%ebp)
80100139:	c6 44 05 e0 2d       	movb   $0x2d,-0x20(%ebp,%eax,1)

  while(--i >= 0)
8010013e:	eb 1a                	jmp    8010015a <printint+0x9f>
    consputc(buf[i]);
80100140:	8d 55 e0             	lea    -0x20(%ebp),%edx
80100143:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100146:	01 d0                	add    %edx,%eax
80100148:	0f b6 00             	movzbl (%eax),%eax
8010014b:	0f be c0             	movsbl %al,%eax
8010014e:	83 ec 0c             	sub    $0xc,%esp
80100151:	50                   	push   %eax
80100152:	e8 7a 02 00 00       	call   801003d1 <consputc>
80100157:	83 c4 10             	add    $0x10,%esp
  }while((x /= base) != 0);

  if(sign)
    buf[i++] = '-';

  while(--i >= 0)
8010015a:	83 6d f4 01          	subl   $0x1,-0xc(%ebp)
8010015e:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80100162:	79 dc                	jns    80100140 <printint+0x85>
    consputc(buf[i]);
}
80100164:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80100167:	c9                   	leave  
80100168:	c3                   	ret    

80100169 <cprintf>:

void
cprintf(char *fmt, ...)
{
80100169:	55                   	push   %ebp
8010016a:	89 e5                	mov    %esp,%ebp
8010016c:	83 ec 18             	sub    $0x18,%esp
  int i, c;
  uint *argp;
  char *s;

  argp = (uint*)(void*)(&fmt + 1);
8010016f:	8d 45 0c             	lea    0xc(%ebp),%eax
80100172:	89 45 f0             	mov    %eax,-0x10(%ebp)
  for(i = 0; (c = fmt[i] & 0xff) != 0; i++){
80100175:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
8010017c:	e9 1b 01 00 00       	jmp    8010029c <cprintf+0x133>
    if(c != '%'){
80100181:	83 7d e8 25          	cmpl   $0x25,-0x18(%ebp)
80100185:	74 13                	je     8010019a <cprintf+0x31>
      consputc(c);
80100187:	83 ec 0c             	sub    $0xc,%esp
8010018a:	ff 75 e8             	pushl  -0x18(%ebp)
8010018d:	e8 3f 02 00 00       	call   801003d1 <consputc>
80100192:	83 c4 10             	add    $0x10,%esp
      continue;
80100195:	e9 fe 00 00 00       	jmp    80100298 <cprintf+0x12f>
    }
    c = fmt[++i] & 0xff;
8010019a:	8b 55 08             	mov    0x8(%ebp),%edx
8010019d:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801001a1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801001a4:	01 d0                	add    %edx,%eax
801001a6:	0f b6 00             	movzbl (%eax),%eax
801001a9:	0f be c0             	movsbl %al,%eax
801001ac:	25 ff 00 00 00       	and    $0xff,%eax
801001b1:	89 45 e8             	mov    %eax,-0x18(%ebp)
    if(c == 0)
801001b4:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
801001b8:	75 05                	jne    801001bf <cprintf+0x56>
      break;
801001ba:	e9 fd 00 00 00       	jmp    801002bc <cprintf+0x153>
    switch(c){
801001bf:	8b 45 e8             	mov    -0x18(%ebp),%eax
801001c2:	83 f8 70             	cmp    $0x70,%eax
801001c5:	74 47                	je     8010020e <cprintf+0xa5>
801001c7:	83 f8 70             	cmp    $0x70,%eax
801001ca:	7f 13                	jg     801001df <cprintf+0x76>
801001cc:	83 f8 25             	cmp    $0x25,%eax
801001cf:	0f 84 98 00 00 00    	je     8010026d <cprintf+0x104>
801001d5:	83 f8 64             	cmp    $0x64,%eax
801001d8:	74 14                	je     801001ee <cprintf+0x85>
801001da:	e9 9d 00 00 00       	jmp    8010027c <cprintf+0x113>
801001df:	83 f8 73             	cmp    $0x73,%eax
801001e2:	74 47                	je     8010022b <cprintf+0xc2>
801001e4:	83 f8 78             	cmp    $0x78,%eax
801001e7:	74 25                	je     8010020e <cprintf+0xa5>
801001e9:	e9 8e 00 00 00       	jmp    8010027c <cprintf+0x113>
    case 'd':
      printint(*argp++, 10, 1);
801001ee:	8b 45 f0             	mov    -0x10(%ebp),%eax
801001f1:	8d 50 04             	lea    0x4(%eax),%edx
801001f4:	89 55 f0             	mov    %edx,-0x10(%ebp)
801001f7:	8b 00                	mov    (%eax),%eax
801001f9:	83 ec 04             	sub    $0x4,%esp
801001fc:	6a 01                	push   $0x1
801001fe:	6a 0a                	push   $0xa
80100200:	50                   	push   %eax
80100201:	e8 b5 fe ff ff       	call   801000bb <printint>
80100206:	83 c4 10             	add    $0x10,%esp
      break;
80100209:	e9 8a 00 00 00       	jmp    80100298 <cprintf+0x12f>
    case 'x':
    case 'p':
      printint(*argp++, 16, 0);
8010020e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80100211:	8d 50 04             	lea    0x4(%eax),%edx
80100214:	89 55 f0             	mov    %edx,-0x10(%ebp)
80100217:	8b 00                	mov    (%eax),%eax
80100219:	83 ec 04             	sub    $0x4,%esp
8010021c:	6a 00                	push   $0x0
8010021e:	6a 10                	push   $0x10
80100220:	50                   	push   %eax
80100221:	e8 95 fe ff ff       	call   801000bb <printint>
80100226:	83 c4 10             	add    $0x10,%esp
      break;
80100229:	eb 6d                	jmp    80100298 <cprintf+0x12f>
    case 's':
      if((s = (char*)*argp++) == 0)
8010022b:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010022e:	8d 50 04             	lea    0x4(%eax),%edx
80100231:	89 55 f0             	mov    %edx,-0x10(%ebp)
80100234:	8b 00                	mov    (%eax),%eax
80100236:	89 45 ec             	mov    %eax,-0x14(%ebp)
80100239:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
8010023d:	75 07                	jne    80100246 <cprintf+0xdd>
        s = "(null)";
8010023f:	c7 45 ec ab 16 10 80 	movl   $0x801016ab,-0x14(%ebp)
      for(; *s; s++)
80100246:	eb 19                	jmp    80100261 <cprintf+0xf8>
        consputc(*s);
80100248:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010024b:	0f b6 00             	movzbl (%eax),%eax
8010024e:	0f be c0             	movsbl %al,%eax
80100251:	83 ec 0c             	sub    $0xc,%esp
80100254:	50                   	push   %eax
80100255:	e8 77 01 00 00       	call   801003d1 <consputc>
8010025a:	83 c4 10             	add    $0x10,%esp
      printint(*argp++, 16, 0);
      break;
    case 's':
      if((s = (char*)*argp++) == 0)
        s = "(null)";
      for(; *s; s++)
8010025d:	83 45 ec 01          	addl   $0x1,-0x14(%ebp)
80100261:	8b 45 ec             	mov    -0x14(%ebp),%eax
80100264:	0f b6 00             	movzbl (%eax),%eax
80100267:	84 c0                	test   %al,%al
80100269:	75 dd                	jne    80100248 <cprintf+0xdf>
        consputc(*s);
      break;
8010026b:	eb 2b                	jmp    80100298 <cprintf+0x12f>
    case '%':
      consputc('%');
8010026d:	83 ec 0c             	sub    $0xc,%esp
80100270:	6a 25                	push   $0x25
80100272:	e8 5a 01 00 00       	call   801003d1 <consputc>
80100277:	83 c4 10             	add    $0x10,%esp
      break;
8010027a:	eb 1c                	jmp    80100298 <cprintf+0x12f>
    default:
      consputc('%');
8010027c:	83 ec 0c             	sub    $0xc,%esp
8010027f:	6a 25                	push   $0x25
80100281:	e8 4b 01 00 00       	call   801003d1 <consputc>
80100286:	83 c4 10             	add    $0x10,%esp
      consputc(c);
80100289:	83 ec 0c             	sub    $0xc,%esp
8010028c:	ff 75 e8             	pushl  -0x18(%ebp)
8010028f:	e8 3d 01 00 00       	call   801003d1 <consputc>
80100294:	83 c4 10             	add    $0x10,%esp
      break;
80100297:	90                   	nop
  int i, c;
  uint *argp;
  char *s;

  argp = (uint*)(void*)(&fmt + 1);
  for(i = 0; (c = fmt[i] & 0xff) != 0; i++){
80100298:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
8010029c:	8b 55 08             	mov    0x8(%ebp),%edx
8010029f:	8b 45 f4             	mov    -0xc(%ebp),%eax
801002a2:	01 d0                	add    %edx,%eax
801002a4:	0f b6 00             	movzbl (%eax),%eax
801002a7:	0f be c0             	movsbl %al,%eax
801002aa:	25 ff 00 00 00       	and    $0xff,%eax
801002af:	89 45 e8             	mov    %eax,-0x18(%ebp)
801002b2:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
801002b6:	0f 85 c5 fe ff ff    	jne    80100181 <cprintf+0x18>
      consputc(c);
      break;
    }
  }

}
801002bc:	c9                   	leave  
801002bd:	c3                   	ret    

801002be <cgaputc>:
#define CRTPORT 0x3d4
static ushort *crt = (ushort*)P2V(0xb8000);  // CGA memory

static void
cgaputc(int c)
{
801002be:	55                   	push   %ebp
801002bf:	89 e5                	mov    %esp,%ebp
801002c1:	83 ec 10             	sub    $0x10,%esp
  int pos;
  
  // Cursor position: col + 80*row.
  outb(CRTPORT, 14);
801002c4:	6a 0e                	push   $0xe
801002c6:	68 d4 03 00 00       	push   $0x3d4
801002cb:	e8 cd fd ff ff       	call   8010009d <outb>
801002d0:	83 c4 08             	add    $0x8,%esp
  pos = inb(CRTPORT+1) << 8;
801002d3:	68 d5 03 00 00       	push   $0x3d5
801002d8:	e8 a3 fd ff ff       	call   80100080 <inb>
801002dd:	83 c4 04             	add    $0x4,%esp
801002e0:	0f b6 c0             	movzbl %al,%eax
801002e3:	c1 e0 08             	shl    $0x8,%eax
801002e6:	89 45 fc             	mov    %eax,-0x4(%ebp)
  outb(CRTPORT, 15);
801002e9:	6a 0f                	push   $0xf
801002eb:	68 d4 03 00 00       	push   $0x3d4
801002f0:	e8 a8 fd ff ff       	call   8010009d <outb>
801002f5:	83 c4 08             	add    $0x8,%esp
  pos |= inb(CRTPORT+1);
801002f8:	68 d5 03 00 00       	push   $0x3d5
801002fd:	e8 7e fd ff ff       	call   80100080 <inb>
80100302:	83 c4 04             	add    $0x4,%esp
80100305:	0f b6 c0             	movzbl %al,%eax
80100308:	09 45 fc             	or     %eax,-0x4(%ebp)

  if(c == '\n')
8010030b:	83 7d 08 0a          	cmpl   $0xa,0x8(%ebp)
8010030f:	75 30                	jne    80100341 <cgaputc+0x83>
    pos += 80 - pos%80;
80100311:	8b 4d fc             	mov    -0x4(%ebp),%ecx
80100314:	ba 67 66 66 66       	mov    $0x66666667,%edx
80100319:	89 c8                	mov    %ecx,%eax
8010031b:	f7 ea                	imul   %edx
8010031d:	c1 fa 05             	sar    $0x5,%edx
80100320:	89 c8                	mov    %ecx,%eax
80100322:	c1 f8 1f             	sar    $0x1f,%eax
80100325:	29 c2                	sub    %eax,%edx
80100327:	89 d0                	mov    %edx,%eax
80100329:	c1 e0 02             	shl    $0x2,%eax
8010032c:	01 d0                	add    %edx,%eax
8010032e:	c1 e0 04             	shl    $0x4,%eax
80100331:	29 c1                	sub    %eax,%ecx
80100333:	89 ca                	mov    %ecx,%edx
80100335:	b8 50 00 00 00       	mov    $0x50,%eax
8010033a:	29 d0                	sub    %edx,%eax
8010033c:	01 45 fc             	add    %eax,-0x4(%ebp)
8010033f:	eb 34                	jmp    80100375 <cgaputc+0xb7>
  else if(c == BACKSPACE){
80100341:	81 7d 08 00 01 00 00 	cmpl   $0x100,0x8(%ebp)
80100348:	75 0c                	jne    80100356 <cgaputc+0x98>
    if(pos > 0) --pos;
8010034a:	83 7d fc 00          	cmpl   $0x0,-0x4(%ebp)
8010034e:	7e 25                	jle    80100375 <cgaputc+0xb7>
80100350:	83 6d fc 01          	subl   $0x1,-0x4(%ebp)
80100354:	eb 1f                	jmp    80100375 <cgaputc+0xb7>
  } else
    crt[pos++] = (c&0xff) | 0x0700;  // black on white
80100356:	8b 0d 00 30 10 80    	mov    0x80103000,%ecx
8010035c:	8b 45 fc             	mov    -0x4(%ebp),%eax
8010035f:	8d 50 01             	lea    0x1(%eax),%edx
80100362:	89 55 fc             	mov    %edx,-0x4(%ebp)
80100365:	01 c0                	add    %eax,%eax
80100367:	01 c8                	add    %ecx,%eax
80100369:	8b 55 08             	mov    0x8(%ebp),%edx
8010036c:	0f b6 d2             	movzbl %dl,%edx
8010036f:	80 ce 07             	or     $0x7,%dh
80100372:	66 89 10             	mov    %dx,(%eax)

  outb(CRTPORT, 14);
80100375:	6a 0e                	push   $0xe
80100377:	68 d4 03 00 00       	push   $0x3d4
8010037c:	e8 1c fd ff ff       	call   8010009d <outb>
80100381:	83 c4 08             	add    $0x8,%esp
  outb(CRTPORT+1, pos>>8);
80100384:	8b 45 fc             	mov    -0x4(%ebp),%eax
80100387:	c1 f8 08             	sar    $0x8,%eax
8010038a:	0f b6 c0             	movzbl %al,%eax
8010038d:	50                   	push   %eax
8010038e:	68 d5 03 00 00       	push   $0x3d5
80100393:	e8 05 fd ff ff       	call   8010009d <outb>
80100398:	83 c4 08             	add    $0x8,%esp
  outb(CRTPORT, 15);
8010039b:	6a 0f                	push   $0xf
8010039d:	68 d4 03 00 00       	push   $0x3d4
801003a2:	e8 f6 fc ff ff       	call   8010009d <outb>
801003a7:	83 c4 08             	add    $0x8,%esp
  outb(CRTPORT+1, pos);
801003aa:	8b 45 fc             	mov    -0x4(%ebp),%eax
801003ad:	0f b6 c0             	movzbl %al,%eax
801003b0:	50                   	push   %eax
801003b1:	68 d5 03 00 00       	push   $0x3d5
801003b6:	e8 e2 fc ff ff       	call   8010009d <outb>
801003bb:	83 c4 08             	add    $0x8,%esp
  crt[pos] = ' ' | 0x0700;
801003be:	a1 00 30 10 80       	mov    0x80103000,%eax
801003c3:	8b 55 fc             	mov    -0x4(%ebp),%edx
801003c6:	01 d2                	add    %edx,%edx
801003c8:	01 d0                	add    %edx,%eax
801003ca:	66 c7 00 20 07       	movw   $0x720,(%eax)
}
801003cf:	c9                   	leave  
801003d0:	c3                   	ret    

801003d1 <consputc>:

void
consputc(int c)
{
801003d1:	55                   	push   %ebp
801003d2:	89 e5                	mov    %esp,%ebp
801003d4:	83 ec 08             	sub    $0x8,%esp
  if(c == BACKSPACE){
801003d7:	81 7d 08 00 01 00 00 	cmpl   $0x100,0x8(%ebp)
801003de:	75 29                	jne    80100409 <consputc+0x38>
    uartputc('\b'); uartputc(' '); uartputc('\b');
801003e0:	83 ec 0c             	sub    $0xc,%esp
801003e3:	6a 08                	push   $0x8
801003e5:	e8 65 12 00 00       	call   8010164f <uartputc>
801003ea:	83 c4 10             	add    $0x10,%esp
801003ed:	83 ec 0c             	sub    $0xc,%esp
801003f0:	6a 20                	push   $0x20
801003f2:	e8 58 12 00 00       	call   8010164f <uartputc>
801003f7:	83 c4 10             	add    $0x10,%esp
801003fa:	83 ec 0c             	sub    $0xc,%esp
801003fd:	6a 08                	push   $0x8
801003ff:	e8 4b 12 00 00       	call   8010164f <uartputc>
80100404:	83 c4 10             	add    $0x10,%esp
80100407:	eb 0e                	jmp    80100417 <consputc+0x46>
  } else
    uartputc(c);
80100409:	83 ec 0c             	sub    $0xc,%esp
8010040c:	ff 75 08             	pushl  0x8(%ebp)
8010040f:	e8 3b 12 00 00       	call   8010164f <uartputc>
80100414:	83 c4 10             	add    $0x10,%esp
  cgaputc(c);
80100417:	83 ec 0c             	sub    $0xc,%esp
8010041a:	ff 75 08             	pushl  0x8(%ebp)
8010041d:	e8 9c fe ff ff       	call   801002be <cgaputc>
80100422:	83 c4 10             	add    $0x10,%esp
}
80100425:	c9                   	leave  
80100426:	c3                   	ret    

80100427 <stosb>:
               "cc");
}

static inline void
stosb(void *addr, int data, int cnt)
{
80100427:	55                   	push   %ebp
80100428:	89 e5                	mov    %esp,%ebp
8010042a:	57                   	push   %edi
8010042b:	53                   	push   %ebx
  asm volatile("cld; rep stosb" :
8010042c:	8b 4d 08             	mov    0x8(%ebp),%ecx
8010042f:	8b 55 10             	mov    0x10(%ebp),%edx
80100432:	8b 45 0c             	mov    0xc(%ebp),%eax
80100435:	89 cb                	mov    %ecx,%ebx
80100437:	89 df                	mov    %ebx,%edi
80100439:	89 d1                	mov    %edx,%ecx
8010043b:	fc                   	cld    
8010043c:	f3 aa                	rep stos %al,%es:(%edi)
8010043e:	89 ca                	mov    %ecx,%edx
80100440:	89 fb                	mov    %edi,%ebx
80100442:	89 5d 08             	mov    %ebx,0x8(%ebp)
80100445:	89 55 10             	mov    %edx,0x10(%ebp)
               "=D" (addr), "=c" (cnt) :
               "0" (addr), "1" (cnt), "a" (data) :
               "memory", "cc");
}
80100448:	5b                   	pop    %ebx
80100449:	5f                   	pop    %edi
8010044a:	5d                   	pop    %ebp
8010044b:	c3                   	ret    

8010044c <stosl>:

static inline void
stosl(void *addr, int data, int cnt)
{
8010044c:	55                   	push   %ebp
8010044d:	89 e5                	mov    %esp,%ebp
8010044f:	57                   	push   %edi
80100450:	53                   	push   %ebx
  asm volatile("cld; rep stosl" :
80100451:	8b 4d 08             	mov    0x8(%ebp),%ecx
80100454:	8b 55 10             	mov    0x10(%ebp),%edx
80100457:	8b 45 0c             	mov    0xc(%ebp),%eax
8010045a:	89 cb                	mov    %ecx,%ebx
8010045c:	89 df                	mov    %ebx,%edi
8010045e:	89 d1                	mov    %edx,%ecx
80100460:	fc                   	cld    
80100461:	f3 ab                	rep stos %eax,%es:(%edi)
80100463:	89 ca                	mov    %ecx,%edx
80100465:	89 fb                	mov    %edi,%ebx
80100467:	89 5d 08             	mov    %ebx,0x8(%ebp)
8010046a:	89 55 10             	mov    %edx,0x10(%ebp)
               "=D" (addr), "=c" (cnt) :
               "0" (addr), "1" (cnt), "a" (data) :
               "memory", "cc");
}
8010046d:	5b                   	pop    %ebx
8010046e:	5f                   	pop    %edi
8010046f:	5d                   	pop    %ebp
80100470:	c3                   	ret    

80100471 <memset>:
#include "types.h"
#include "x86.h"

void*
memset(void *dst, int c, uint n)
{
80100471:	55                   	push   %ebp
80100472:	89 e5                	mov    %esp,%ebp
  if ((int)dst%4 == 0 && n%4 == 0){
80100474:	8b 45 08             	mov    0x8(%ebp),%eax
80100477:	83 e0 03             	and    $0x3,%eax
8010047a:	85 c0                	test   %eax,%eax
8010047c:	75 43                	jne    801004c1 <memset+0x50>
8010047e:	8b 45 10             	mov    0x10(%ebp),%eax
80100481:	83 e0 03             	and    $0x3,%eax
80100484:	85 c0                	test   %eax,%eax
80100486:	75 39                	jne    801004c1 <memset+0x50>
    c &= 0xFF;
80100488:	81 65 0c ff 00 00 00 	andl   $0xff,0xc(%ebp)
    stosl(dst, (c<<24)|(c<<16)|(c<<8)|c, n/4);
8010048f:	8b 45 10             	mov    0x10(%ebp),%eax
80100492:	c1 e8 02             	shr    $0x2,%eax
80100495:	89 c1                	mov    %eax,%ecx
80100497:	8b 45 0c             	mov    0xc(%ebp),%eax
8010049a:	c1 e0 18             	shl    $0x18,%eax
8010049d:	89 c2                	mov    %eax,%edx
8010049f:	8b 45 0c             	mov    0xc(%ebp),%eax
801004a2:	c1 e0 10             	shl    $0x10,%eax
801004a5:	09 c2                	or     %eax,%edx
801004a7:	8b 45 0c             	mov    0xc(%ebp),%eax
801004aa:	c1 e0 08             	shl    $0x8,%eax
801004ad:	09 d0                	or     %edx,%eax
801004af:	0b 45 0c             	or     0xc(%ebp),%eax
801004b2:	51                   	push   %ecx
801004b3:	50                   	push   %eax
801004b4:	ff 75 08             	pushl  0x8(%ebp)
801004b7:	e8 90 ff ff ff       	call   8010044c <stosl>
801004bc:	83 c4 0c             	add    $0xc,%esp
801004bf:	eb 12                	jmp    801004d3 <memset+0x62>
  } else
    stosb(dst, c, n);
801004c1:	8b 45 10             	mov    0x10(%ebp),%eax
801004c4:	50                   	push   %eax
801004c5:	ff 75 0c             	pushl  0xc(%ebp)
801004c8:	ff 75 08             	pushl  0x8(%ebp)
801004cb:	e8 57 ff ff ff       	call   80100427 <stosb>
801004d0:	83 c4 0c             	add    $0xc,%esp
  return dst;
801004d3:	8b 45 08             	mov    0x8(%ebp),%eax
}
801004d6:	c9                   	leave  
801004d7:	c3                   	ret    

801004d8 <kfree>:


extern char end[]; // first address after kernel loaded from ELF file

void kfree(char *v)
{
801004d8:	55                   	push   %ebp
801004d9:	89 e5                	mov    %esp,%ebp
801004db:	83 ec 18             	sub    $0x18,%esp
  struct run *r;

  memset(v, 1, PGSIZE);
801004de:	83 ec 04             	sub    $0x4,%esp
801004e1:	68 00 10 00 00       	push   $0x1000
801004e6:	6a 01                	push   $0x1
801004e8:	ff 75 08             	pushl  0x8(%ebp)
801004eb:	e8 81 ff ff ff       	call   80100471 <memset>
801004f0:	83 c4 10             	add    $0x10,%esp

  r = (struct run*)v;
801004f3:	8b 45 08             	mov    0x8(%ebp),%eax
801004f6:	89 45 f4             	mov    %eax,-0xc(%ebp)
  r->next = kmem.freelist;
801004f9:	8b 15 40 44 10 80    	mov    0x80104440,%edx
801004ff:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100502:	89 10                	mov    %edx,(%eax)
  kmem.freelist = r;
80100504:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100507:	a3 40 44 10 80       	mov    %eax,0x80104440

}
8010050c:	c9                   	leave  
8010050d:	c3                   	ret    

8010050e <freerange>:

void freerange(void *vstart, void *vend)
{
8010050e:	55                   	push   %ebp
8010050f:	89 e5                	mov    %esp,%ebp
80100511:	83 ec 18             	sub    $0x18,%esp
  char *p;
  p = (char*)PGROUNDUP((uint)vstart);
80100514:	8b 45 08             	mov    0x8(%ebp),%eax
80100517:	05 ff 0f 00 00       	add    $0xfff,%eax
8010051c:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80100521:	89 45 f4             	mov    %eax,-0xc(%ebp)
  for(; p + PGSIZE <= (char*)vend; p += PGSIZE)
80100524:	eb 15                	jmp    8010053b <freerange+0x2d>
    kfree(p);
80100526:	83 ec 0c             	sub    $0xc,%esp
80100529:	ff 75 f4             	pushl  -0xc(%ebp)
8010052c:	e8 a7 ff ff ff       	call   801004d8 <kfree>
80100531:	83 c4 10             	add    $0x10,%esp

void freerange(void *vstart, void *vend)
{
  char *p;
  p = (char*)PGROUNDUP((uint)vstart);
  for(; p + PGSIZE <= (char*)vend; p += PGSIZE)
80100534:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
8010053b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010053e:	05 00 10 00 00       	add    $0x1000,%eax
80100543:	3b 45 0c             	cmp    0xc(%ebp),%eax
80100546:	76 de                	jbe    80100526 <freerange+0x18>
    kfree(p);
}
80100548:	c9                   	leave  
80100549:	c3                   	ret    

8010054a <kinit>:


void kinit(void *vstart, void *vend)
{
8010054a:	55                   	push   %ebp
8010054b:	89 e5                	mov    %esp,%ebp
8010054d:	83 ec 08             	sub    $0x8,%esp
  freerange(vstart, vend);
80100550:	83 ec 08             	sub    $0x8,%esp
80100553:	ff 75 0c             	pushl  0xc(%ebp)
80100556:	ff 75 08             	pushl  0x8(%ebp)
80100559:	e8 b0 ff ff ff       	call   8010050e <freerange>
8010055e:	83 c4 10             	add    $0x10,%esp
}
80100561:	c9                   	leave  
80100562:	c3                   	ret    

80100563 <lgdt>:

struct segdesc;

static inline void
lgdt(struct segdesc *p, int size)
{
80100563:	55                   	push   %ebp
80100564:	89 e5                	mov    %esp,%ebp
80100566:	83 ec 10             	sub    $0x10,%esp
  volatile ushort pd[3];

  pd[0] = size-1;
80100569:	8b 45 0c             	mov    0xc(%ebp),%eax
8010056c:	83 e8 01             	sub    $0x1,%eax
8010056f:	66 89 45 fa          	mov    %ax,-0x6(%ebp)
  pd[1] = (uint)p;
80100573:	8b 45 08             	mov    0x8(%ebp),%eax
80100576:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  pd[2] = (uint)p >> 16;
8010057a:	8b 45 08             	mov    0x8(%ebp),%eax
8010057d:	c1 e8 10             	shr    $0x10,%eax
80100580:	66 89 45 fe          	mov    %ax,-0x2(%ebp)

  asm volatile("lgdt (%0)" : : "r" (pd));
80100584:	8d 45 fa             	lea    -0x6(%ebp),%eax
80100587:	0f 01 10             	lgdtl  (%eax)
}
8010058a:	c9                   	leave  
8010058b:	c3                   	ret    

8010058c <seginit>:
#include "memlayout.h"
#include "cpu.h"
#include "defs.h"

void seginit(void)
{
8010058c:	55                   	push   %ebp
8010058d:	89 e5                	mov    %esp,%ebp
8010058f:	83 ec 10             	sub    $0x10,%esp
  struct cpu *c;
  
  c->gdt[SEG_KCODE] = SEG(STA_X|STA_R, 0, 0xffffffff, 0);        
80100592:	8b 45 fc             	mov    -0x4(%ebp),%eax
80100595:	66 c7 40 08 ff ff    	movw   $0xffff,0x8(%eax)
8010059b:	8b 45 fc             	mov    -0x4(%ebp),%eax
8010059e:	66 c7 40 0a 00 00    	movw   $0x0,0xa(%eax)
801005a4:	8b 45 fc             	mov    -0x4(%ebp),%eax
801005a7:	c6 40 0c 00          	movb   $0x0,0xc(%eax)
801005ab:	8b 45 fc             	mov    -0x4(%ebp),%eax
801005ae:	0f b6 50 0d          	movzbl 0xd(%eax),%edx
801005b2:	83 e2 f0             	and    $0xfffffff0,%edx
801005b5:	83 ca 0a             	or     $0xa,%edx
801005b8:	88 50 0d             	mov    %dl,0xd(%eax)
801005bb:	8b 45 fc             	mov    -0x4(%ebp),%eax
801005be:	0f b6 50 0d          	movzbl 0xd(%eax),%edx
801005c2:	83 ca 10             	or     $0x10,%edx
801005c5:	88 50 0d             	mov    %dl,0xd(%eax)
801005c8:	8b 45 fc             	mov    -0x4(%ebp),%eax
801005cb:	0f b6 50 0d          	movzbl 0xd(%eax),%edx
801005cf:	83 e2 9f             	and    $0xffffff9f,%edx
801005d2:	88 50 0d             	mov    %dl,0xd(%eax)
801005d5:	8b 45 fc             	mov    -0x4(%ebp),%eax
801005d8:	0f b6 50 0d          	movzbl 0xd(%eax),%edx
801005dc:	83 ca 80             	or     $0xffffff80,%edx
801005df:	88 50 0d             	mov    %dl,0xd(%eax)
801005e2:	8b 45 fc             	mov    -0x4(%ebp),%eax
801005e5:	0f b6 50 0e          	movzbl 0xe(%eax),%edx
801005e9:	83 ca 0f             	or     $0xf,%edx
801005ec:	88 50 0e             	mov    %dl,0xe(%eax)
801005ef:	8b 45 fc             	mov    -0x4(%ebp),%eax
801005f2:	0f b6 50 0e          	movzbl 0xe(%eax),%edx
801005f6:	83 e2 ef             	and    $0xffffffef,%edx
801005f9:	88 50 0e             	mov    %dl,0xe(%eax)
801005fc:	8b 45 fc             	mov    -0x4(%ebp),%eax
801005ff:	0f b6 50 0e          	movzbl 0xe(%eax),%edx
80100603:	83 e2 df             	and    $0xffffffdf,%edx
80100606:	88 50 0e             	mov    %dl,0xe(%eax)
80100609:	8b 45 fc             	mov    -0x4(%ebp),%eax
8010060c:	0f b6 50 0e          	movzbl 0xe(%eax),%edx
80100610:	83 ca 40             	or     $0x40,%edx
80100613:	88 50 0e             	mov    %dl,0xe(%eax)
80100616:	8b 45 fc             	mov    -0x4(%ebp),%eax
80100619:	0f b6 50 0e          	movzbl 0xe(%eax),%edx
8010061d:	83 ca 80             	or     $0xffffff80,%edx
80100620:	88 50 0e             	mov    %dl,0xe(%eax)
80100623:	8b 45 fc             	mov    -0x4(%ebp),%eax
80100626:	c6 40 0f 00          	movb   $0x0,0xf(%eax)
  c->gdt[SEG_KDATA] = SEG(STA_W, 0, 0xffffffff, 0);
8010062a:	8b 45 fc             	mov    -0x4(%ebp),%eax
8010062d:	66 c7 40 10 ff ff    	movw   $0xffff,0x10(%eax)
80100633:	8b 45 fc             	mov    -0x4(%ebp),%eax
80100636:	66 c7 40 12 00 00    	movw   $0x0,0x12(%eax)
8010063c:	8b 45 fc             	mov    -0x4(%ebp),%eax
8010063f:	c6 40 14 00          	movb   $0x0,0x14(%eax)
80100643:	8b 45 fc             	mov    -0x4(%ebp),%eax
80100646:	0f b6 50 15          	movzbl 0x15(%eax),%edx
8010064a:	83 e2 f0             	and    $0xfffffff0,%edx
8010064d:	83 ca 02             	or     $0x2,%edx
80100650:	88 50 15             	mov    %dl,0x15(%eax)
80100653:	8b 45 fc             	mov    -0x4(%ebp),%eax
80100656:	0f b6 50 15          	movzbl 0x15(%eax),%edx
8010065a:	83 ca 10             	or     $0x10,%edx
8010065d:	88 50 15             	mov    %dl,0x15(%eax)
80100660:	8b 45 fc             	mov    -0x4(%ebp),%eax
80100663:	0f b6 50 15          	movzbl 0x15(%eax),%edx
80100667:	83 e2 9f             	and    $0xffffff9f,%edx
8010066a:	88 50 15             	mov    %dl,0x15(%eax)
8010066d:	8b 45 fc             	mov    -0x4(%ebp),%eax
80100670:	0f b6 50 15          	movzbl 0x15(%eax),%edx
80100674:	83 ca 80             	or     $0xffffff80,%edx
80100677:	88 50 15             	mov    %dl,0x15(%eax)
8010067a:	8b 45 fc             	mov    -0x4(%ebp),%eax
8010067d:	0f b6 50 16          	movzbl 0x16(%eax),%edx
80100681:	83 ca 0f             	or     $0xf,%edx
80100684:	88 50 16             	mov    %dl,0x16(%eax)
80100687:	8b 45 fc             	mov    -0x4(%ebp),%eax
8010068a:	0f b6 50 16          	movzbl 0x16(%eax),%edx
8010068e:	83 e2 ef             	and    $0xffffffef,%edx
80100691:	88 50 16             	mov    %dl,0x16(%eax)
80100694:	8b 45 fc             	mov    -0x4(%ebp),%eax
80100697:	0f b6 50 16          	movzbl 0x16(%eax),%edx
8010069b:	83 e2 df             	and    $0xffffffdf,%edx
8010069e:	88 50 16             	mov    %dl,0x16(%eax)
801006a1:	8b 45 fc             	mov    -0x4(%ebp),%eax
801006a4:	0f b6 50 16          	movzbl 0x16(%eax),%edx
801006a8:	83 ca 40             	or     $0x40,%edx
801006ab:	88 50 16             	mov    %dl,0x16(%eax)
801006ae:	8b 45 fc             	mov    -0x4(%ebp),%eax
801006b1:	0f b6 50 16          	movzbl 0x16(%eax),%edx
801006b5:	83 ca 80             	or     $0xffffff80,%edx
801006b8:	88 50 16             	mov    %dl,0x16(%eax)
801006bb:	8b 45 fc             	mov    -0x4(%ebp),%eax
801006be:	c6 40 17 00          	movb   $0x0,0x17(%eax)
  c->gdt[SEG_UCODE] = SEG(STA_X|STA_R, 0, 0xffffffff, DPL_USER);
801006c2:	8b 45 fc             	mov    -0x4(%ebp),%eax
801006c5:	66 c7 40 20 ff ff    	movw   $0xffff,0x20(%eax)
801006cb:	8b 45 fc             	mov    -0x4(%ebp),%eax
801006ce:	66 c7 40 22 00 00    	movw   $0x0,0x22(%eax)
801006d4:	8b 45 fc             	mov    -0x4(%ebp),%eax
801006d7:	c6 40 24 00          	movb   $0x0,0x24(%eax)
801006db:	8b 45 fc             	mov    -0x4(%ebp),%eax
801006de:	0f b6 50 25          	movzbl 0x25(%eax),%edx
801006e2:	83 e2 f0             	and    $0xfffffff0,%edx
801006e5:	83 ca 0a             	or     $0xa,%edx
801006e8:	88 50 25             	mov    %dl,0x25(%eax)
801006eb:	8b 45 fc             	mov    -0x4(%ebp),%eax
801006ee:	0f b6 50 25          	movzbl 0x25(%eax),%edx
801006f2:	83 ca 10             	or     $0x10,%edx
801006f5:	88 50 25             	mov    %dl,0x25(%eax)
801006f8:	8b 45 fc             	mov    -0x4(%ebp),%eax
801006fb:	0f b6 50 25          	movzbl 0x25(%eax),%edx
801006ff:	83 ca 60             	or     $0x60,%edx
80100702:	88 50 25             	mov    %dl,0x25(%eax)
80100705:	8b 45 fc             	mov    -0x4(%ebp),%eax
80100708:	0f b6 50 25          	movzbl 0x25(%eax),%edx
8010070c:	83 ca 80             	or     $0xffffff80,%edx
8010070f:	88 50 25             	mov    %dl,0x25(%eax)
80100712:	8b 45 fc             	mov    -0x4(%ebp),%eax
80100715:	0f b6 50 26          	movzbl 0x26(%eax),%edx
80100719:	83 ca 0f             	or     $0xf,%edx
8010071c:	88 50 26             	mov    %dl,0x26(%eax)
8010071f:	8b 45 fc             	mov    -0x4(%ebp),%eax
80100722:	0f b6 50 26          	movzbl 0x26(%eax),%edx
80100726:	83 e2 ef             	and    $0xffffffef,%edx
80100729:	88 50 26             	mov    %dl,0x26(%eax)
8010072c:	8b 45 fc             	mov    -0x4(%ebp),%eax
8010072f:	0f b6 50 26          	movzbl 0x26(%eax),%edx
80100733:	83 e2 df             	and    $0xffffffdf,%edx
80100736:	88 50 26             	mov    %dl,0x26(%eax)
80100739:	8b 45 fc             	mov    -0x4(%ebp),%eax
8010073c:	0f b6 50 26          	movzbl 0x26(%eax),%edx
80100740:	83 ca 40             	or     $0x40,%edx
80100743:	88 50 26             	mov    %dl,0x26(%eax)
80100746:	8b 45 fc             	mov    -0x4(%ebp),%eax
80100749:	0f b6 50 26          	movzbl 0x26(%eax),%edx
8010074d:	83 ca 80             	or     $0xffffff80,%edx
80100750:	88 50 26             	mov    %dl,0x26(%eax)
80100753:	8b 45 fc             	mov    -0x4(%ebp),%eax
80100756:	c6 40 27 00          	movb   $0x0,0x27(%eax)
  c->gdt[SEG_UDATA] = SEG(STA_W, 0, 0xffffffff, DPL_USER);
8010075a:	8b 45 fc             	mov    -0x4(%ebp),%eax
8010075d:	66 c7 40 28 ff ff    	movw   $0xffff,0x28(%eax)
80100763:	8b 45 fc             	mov    -0x4(%ebp),%eax
80100766:	66 c7 40 2a 00 00    	movw   $0x0,0x2a(%eax)
8010076c:	8b 45 fc             	mov    -0x4(%ebp),%eax
8010076f:	c6 40 2c 00          	movb   $0x0,0x2c(%eax)
80100773:	8b 45 fc             	mov    -0x4(%ebp),%eax
80100776:	0f b6 50 2d          	movzbl 0x2d(%eax),%edx
8010077a:	83 e2 f0             	and    $0xfffffff0,%edx
8010077d:	83 ca 02             	or     $0x2,%edx
80100780:	88 50 2d             	mov    %dl,0x2d(%eax)
80100783:	8b 45 fc             	mov    -0x4(%ebp),%eax
80100786:	0f b6 50 2d          	movzbl 0x2d(%eax),%edx
8010078a:	83 ca 10             	or     $0x10,%edx
8010078d:	88 50 2d             	mov    %dl,0x2d(%eax)
80100790:	8b 45 fc             	mov    -0x4(%ebp),%eax
80100793:	0f b6 50 2d          	movzbl 0x2d(%eax),%edx
80100797:	83 ca 60             	or     $0x60,%edx
8010079a:	88 50 2d             	mov    %dl,0x2d(%eax)
8010079d:	8b 45 fc             	mov    -0x4(%ebp),%eax
801007a0:	0f b6 50 2d          	movzbl 0x2d(%eax),%edx
801007a4:	83 ca 80             	or     $0xffffff80,%edx
801007a7:	88 50 2d             	mov    %dl,0x2d(%eax)
801007aa:	8b 45 fc             	mov    -0x4(%ebp),%eax
801007ad:	0f b6 50 2e          	movzbl 0x2e(%eax),%edx
801007b1:	83 ca 0f             	or     $0xf,%edx
801007b4:	88 50 2e             	mov    %dl,0x2e(%eax)
801007b7:	8b 45 fc             	mov    -0x4(%ebp),%eax
801007ba:	0f b6 50 2e          	movzbl 0x2e(%eax),%edx
801007be:	83 e2 ef             	and    $0xffffffef,%edx
801007c1:	88 50 2e             	mov    %dl,0x2e(%eax)
801007c4:	8b 45 fc             	mov    -0x4(%ebp),%eax
801007c7:	0f b6 50 2e          	movzbl 0x2e(%eax),%edx
801007cb:	83 e2 df             	and    $0xffffffdf,%edx
801007ce:	88 50 2e             	mov    %dl,0x2e(%eax)
801007d1:	8b 45 fc             	mov    -0x4(%ebp),%eax
801007d4:	0f b6 50 2e          	movzbl 0x2e(%eax),%edx
801007d8:	83 ca 40             	or     $0x40,%edx
801007db:	88 50 2e             	mov    %dl,0x2e(%eax)
801007de:	8b 45 fc             	mov    -0x4(%ebp),%eax
801007e1:	0f b6 50 2e          	movzbl 0x2e(%eax),%edx
801007e5:	83 ca 80             	or     $0xffffff80,%edx
801007e8:	88 50 2e             	mov    %dl,0x2e(%eax)
801007eb:	8b 45 fc             	mov    -0x4(%ebp),%eax
801007ee:	c6 40 2f 00          	movb   $0x0,0x2f(%eax)
  
  lgdt(c->gdt, sizeof(c->gdt));
801007f2:	8b 45 fc             	mov    -0x4(%ebp),%eax
801007f5:	6a 38                	push   $0x38
801007f7:	50                   	push   %eax
801007f8:	e8 66 fd ff ff       	call   80100563 <lgdt>
801007fd:	83 c4 08             	add    $0x8,%esp
  cpu = c;
80100800:	8b 45 fc             	mov    -0x4(%ebp),%eax
80100803:	65 a3 00 00 00 00    	mov    %eax,%gs:0x0
}
80100809:	c9                   	leave  
8010080a:	c3                   	ret    

8010080b <segshow>:


void segshow(){
8010080b:	55                   	push   %ebp
8010080c:	89 e5                	mov    %esp,%ebp
8010080e:	83 ec 08             	sub    $0x8,%esp

  cprintf("Kernel code segment's address bit 31~24 : %d\n",cpu->gdt[SEG_KCODE].base_31_24);
80100811:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80100817:	0f b6 40 0f          	movzbl 0xf(%eax),%eax
8010081b:	0f b6 c0             	movzbl %al,%eax
8010081e:	83 ec 08             	sub    $0x8,%esp
80100821:	50                   	push   %eax
80100822:	68 b4 16 10 80       	push   $0x801016b4
80100827:	e8 3d f9 ff ff       	call   80100169 <cprintf>
8010082c:	83 c4 10             	add    $0x10,%esp
  cprintf("Kernel code segment's address bit 23~16 : %d\n",cpu->gdt[SEG_KCODE].base_23_16);
8010082f:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80100835:	0f b6 40 0c          	movzbl 0xc(%eax),%eax
80100839:	0f b6 c0             	movzbl %al,%eax
8010083c:	83 ec 08             	sub    $0x8,%esp
8010083f:	50                   	push   %eax
80100840:	68 e4 16 10 80       	push   $0x801016e4
80100845:	e8 1f f9 ff ff       	call   80100169 <cprintf>
8010084a:	83 c4 10             	add    $0x10,%esp
  cprintf("Kernel code segment's address bit 15~0 : %d\n",cpu->gdt[SEG_KCODE].base_15_0);
8010084d:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80100853:	0f b7 40 0a          	movzwl 0xa(%eax),%eax
80100857:	0f b7 c0             	movzwl %ax,%eax
8010085a:	83 ec 08             	sub    $0x8,%esp
8010085d:	50                   	push   %eax
8010085e:	68 14 17 10 80       	push   $0x80101714
80100863:	e8 01 f9 ff ff       	call   80100169 <cprintf>
80100868:	83 c4 10             	add    $0x10,%esp
                                                                                          
  cprintf("Kernel data segment's address bit 31~24 : %d\n",cpu->gdt[SEG_KDATA].base_31_24);
8010086b:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80100871:	0f b6 40 17          	movzbl 0x17(%eax),%eax
80100875:	0f b6 c0             	movzbl %al,%eax
80100878:	83 ec 08             	sub    $0x8,%esp
8010087b:	50                   	push   %eax
8010087c:	68 44 17 10 80       	push   $0x80101744
80100881:	e8 e3 f8 ff ff       	call   80100169 <cprintf>
80100886:	83 c4 10             	add    $0x10,%esp
  cprintf("Kernel data segment's address bit 23~16 : %d\n",cpu->gdt[SEG_KDATA].base_23_16);
80100889:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
8010088f:	0f b6 40 14          	movzbl 0x14(%eax),%eax
80100893:	0f b6 c0             	movzbl %al,%eax
80100896:	83 ec 08             	sub    $0x8,%esp
80100899:	50                   	push   %eax
8010089a:	68 74 17 10 80       	push   $0x80101774
8010089f:	e8 c5 f8 ff ff       	call   80100169 <cprintf>
801008a4:	83 c4 10             	add    $0x10,%esp
  cprintf("Kernel data segment's address bit 15~0 : %d\n",cpu->gdt[SEG_KDATA].base_15_0);
801008a7:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
801008ad:	0f b7 40 12          	movzwl 0x12(%eax),%eax
801008b1:	0f b7 c0             	movzwl %ax,%eax
801008b4:	83 ec 08             	sub    $0x8,%esp
801008b7:	50                   	push   %eax
801008b8:	68 a4 17 10 80       	push   $0x801017a4
801008bd:	e8 a7 f8 ff ff       	call   80100169 <cprintf>
801008c2:	83 c4 10             	add    $0x10,%esp

  cprintf("User code segment's address bit 31~24 : %d\n",cpu->gdt[SEG_UCODE].base_31_24);
801008c5:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
801008cb:	0f b6 40 27          	movzbl 0x27(%eax),%eax
801008cf:	0f b6 c0             	movzbl %al,%eax
801008d2:	83 ec 08             	sub    $0x8,%esp
801008d5:	50                   	push   %eax
801008d6:	68 d4 17 10 80       	push   $0x801017d4
801008db:	e8 89 f8 ff ff       	call   80100169 <cprintf>
801008e0:	83 c4 10             	add    $0x10,%esp
  cprintf("User code segment's address bit 23~16 : %d\n",cpu->gdt[SEG_UCODE].base_15_0);
801008e3:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
801008e9:	0f b7 40 22          	movzwl 0x22(%eax),%eax
801008ed:	0f b7 c0             	movzwl %ax,%eax
801008f0:	83 ec 08             	sub    $0x8,%esp
801008f3:	50                   	push   %eax
801008f4:	68 00 18 10 80       	push   $0x80101800
801008f9:	e8 6b f8 ff ff       	call   80100169 <cprintf>
801008fe:	83 c4 10             	add    $0x10,%esp
  cprintf("User code segment's address bit 15~0 : %d\n",cpu->gdt[SEG_UCODE].base_15_0);
80100901:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80100907:	0f b7 40 22          	movzwl 0x22(%eax),%eax
8010090b:	0f b7 c0             	movzwl %ax,%eax
8010090e:	83 ec 08             	sub    $0x8,%esp
80100911:	50                   	push   %eax
80100912:	68 2c 18 10 80       	push   $0x8010182c
80100917:	e8 4d f8 ff ff       	call   80100169 <cprintf>
8010091c:	83 c4 10             	add    $0x10,%esp
  
  cprintf("User code segment's address bit 31~24 : %d\n",cpu->gdt[SEG_UDATA].base_31_24);
8010091f:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80100925:	0f b6 40 2f          	movzbl 0x2f(%eax),%eax
80100929:	0f b6 c0             	movzbl %al,%eax
8010092c:	83 ec 08             	sub    $0x8,%esp
8010092f:	50                   	push   %eax
80100930:	68 d4 17 10 80       	push   $0x801017d4
80100935:	e8 2f f8 ff ff       	call   80100169 <cprintf>
8010093a:	83 c4 10             	add    $0x10,%esp
  cprintf("User code segment's address bit 23~16 : %d\n",cpu->gdt[SEG_UDATA].base_23_16);
8010093d:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80100943:	0f b6 40 2c          	movzbl 0x2c(%eax),%eax
80100947:	0f b6 c0             	movzbl %al,%eax
8010094a:	83 ec 08             	sub    $0x8,%esp
8010094d:	50                   	push   %eax
8010094e:	68 00 18 10 80       	push   $0x80101800
80100953:	e8 11 f8 ff ff       	call   80100169 <cprintf>
80100958:	83 c4 10             	add    $0x10,%esp
  cprintf("User code segment's address bit 15~0 : %d\n",cpu->gdt[SEG_UDATA].base_15_0);
8010095b:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80100961:	0f b7 40 2a          	movzwl 0x2a(%eax),%eax
80100965:	0f b7 c0             	movzwl %ax,%eax
80100968:	83 ec 08             	sub    $0x8,%esp
8010096b:	50                   	push   %eax
8010096c:	68 2c 18 10 80       	push   $0x8010182c
80100971:	e8 f3 f7 ff ff       	call   80100169 <cprintf>
80100976:	83 c4 10             	add    $0x10,%esp

}
80100979:	c9                   	leave  
8010097a:	c3                   	ret    

8010097b <vector0>:
# generated by vectors.pl - do not edit
# handlers
.globl alltraps
.globl vector0
vector0:
  pushl $0
8010097b:	6a 00                	push   $0x0
  pushl $0
8010097d:	6a 00                	push   $0x0
  jmp alltraps
8010097f:	e9 6d 0c 00 00       	jmp    801015f1 <alltraps>

80100984 <vector1>:
.globl vector1
vector1:
  pushl $0
80100984:	6a 00                	push   $0x0
  pushl $1
80100986:	6a 01                	push   $0x1
  jmp alltraps
80100988:	e9 64 0c 00 00       	jmp    801015f1 <alltraps>

8010098d <vector2>:
.globl vector2
vector2:
  pushl $0
8010098d:	6a 00                	push   $0x0
  pushl $2
8010098f:	6a 02                	push   $0x2
  jmp alltraps
80100991:	e9 5b 0c 00 00       	jmp    801015f1 <alltraps>

80100996 <vector3>:
.globl vector3
vector3:
  pushl $0
80100996:	6a 00                	push   $0x0
  pushl $3
80100998:	6a 03                	push   $0x3
  jmp alltraps
8010099a:	e9 52 0c 00 00       	jmp    801015f1 <alltraps>

8010099f <vector4>:
.globl vector4
vector4:
  pushl $0
8010099f:	6a 00                	push   $0x0
  pushl $4
801009a1:	6a 04                	push   $0x4
  jmp alltraps
801009a3:	e9 49 0c 00 00       	jmp    801015f1 <alltraps>

801009a8 <vector5>:
.globl vector5
vector5:
  pushl $0
801009a8:	6a 00                	push   $0x0
  pushl $5
801009aa:	6a 05                	push   $0x5
  jmp alltraps
801009ac:	e9 40 0c 00 00       	jmp    801015f1 <alltraps>

801009b1 <vector6>:
.globl vector6
vector6:
  pushl $0
801009b1:	6a 00                	push   $0x0
  pushl $6
801009b3:	6a 06                	push   $0x6
  jmp alltraps
801009b5:	e9 37 0c 00 00       	jmp    801015f1 <alltraps>

801009ba <vector7>:
.globl vector7
vector7:
  pushl $0
801009ba:	6a 00                	push   $0x0
  pushl $7
801009bc:	6a 07                	push   $0x7
  jmp alltraps
801009be:	e9 2e 0c 00 00       	jmp    801015f1 <alltraps>

801009c3 <vector8>:
.globl vector8
vector8:
  pushl $8
801009c3:	6a 08                	push   $0x8
  jmp alltraps
801009c5:	e9 27 0c 00 00       	jmp    801015f1 <alltraps>

801009ca <vector9>:
.globl vector9
vector9:
  pushl $0
801009ca:	6a 00                	push   $0x0
  pushl $9
801009cc:	6a 09                	push   $0x9
  jmp alltraps
801009ce:	e9 1e 0c 00 00       	jmp    801015f1 <alltraps>

801009d3 <vector10>:
.globl vector10
vector10:
  pushl $10
801009d3:	6a 0a                	push   $0xa
  jmp alltraps
801009d5:	e9 17 0c 00 00       	jmp    801015f1 <alltraps>

801009da <vector11>:
.globl vector11
vector11:
  pushl $11
801009da:	6a 0b                	push   $0xb
  jmp alltraps
801009dc:	e9 10 0c 00 00       	jmp    801015f1 <alltraps>

801009e1 <vector12>:
.globl vector12
vector12:
  pushl $12
801009e1:	6a 0c                	push   $0xc
  jmp alltraps
801009e3:	e9 09 0c 00 00       	jmp    801015f1 <alltraps>

801009e8 <vector13>:
.globl vector13
vector13:
  pushl $13
801009e8:	6a 0d                	push   $0xd
  jmp alltraps
801009ea:	e9 02 0c 00 00       	jmp    801015f1 <alltraps>

801009ef <vector14>:
.globl vector14
vector14:
  pushl $14
801009ef:	6a 0e                	push   $0xe
  jmp alltraps
801009f1:	e9 fb 0b 00 00       	jmp    801015f1 <alltraps>

801009f6 <vector15>:
.globl vector15
vector15:
  pushl $0
801009f6:	6a 00                	push   $0x0
  pushl $15
801009f8:	6a 0f                	push   $0xf
  jmp alltraps
801009fa:	e9 f2 0b 00 00       	jmp    801015f1 <alltraps>

801009ff <vector16>:
.globl vector16
vector16:
  pushl $0
801009ff:	6a 00                	push   $0x0
  pushl $16
80100a01:	6a 10                	push   $0x10
  jmp alltraps
80100a03:	e9 e9 0b 00 00       	jmp    801015f1 <alltraps>

80100a08 <vector17>:
.globl vector17
vector17:
  pushl $17
80100a08:	6a 11                	push   $0x11
  jmp alltraps
80100a0a:	e9 e2 0b 00 00       	jmp    801015f1 <alltraps>

80100a0f <vector18>:
.globl vector18
vector18:
  pushl $0
80100a0f:	6a 00                	push   $0x0
  pushl $18
80100a11:	6a 12                	push   $0x12
  jmp alltraps
80100a13:	e9 d9 0b 00 00       	jmp    801015f1 <alltraps>

80100a18 <vector19>:
.globl vector19
vector19:
  pushl $0
80100a18:	6a 00                	push   $0x0
  pushl $19
80100a1a:	6a 13                	push   $0x13
  jmp alltraps
80100a1c:	e9 d0 0b 00 00       	jmp    801015f1 <alltraps>

80100a21 <vector20>:
.globl vector20
vector20:
  pushl $0
80100a21:	6a 00                	push   $0x0
  pushl $20
80100a23:	6a 14                	push   $0x14
  jmp alltraps
80100a25:	e9 c7 0b 00 00       	jmp    801015f1 <alltraps>

80100a2a <vector21>:
.globl vector21
vector21:
  pushl $0
80100a2a:	6a 00                	push   $0x0
  pushl $21
80100a2c:	6a 15                	push   $0x15
  jmp alltraps
80100a2e:	e9 be 0b 00 00       	jmp    801015f1 <alltraps>

80100a33 <vector22>:
.globl vector22
vector22:
  pushl $0
80100a33:	6a 00                	push   $0x0
  pushl $22
80100a35:	6a 16                	push   $0x16
  jmp alltraps
80100a37:	e9 b5 0b 00 00       	jmp    801015f1 <alltraps>

80100a3c <vector23>:
.globl vector23
vector23:
  pushl $0
80100a3c:	6a 00                	push   $0x0
  pushl $23
80100a3e:	6a 17                	push   $0x17
  jmp alltraps
80100a40:	e9 ac 0b 00 00       	jmp    801015f1 <alltraps>

80100a45 <vector24>:
.globl vector24
vector24:
  pushl $0
80100a45:	6a 00                	push   $0x0
  pushl $24
80100a47:	6a 18                	push   $0x18
  jmp alltraps
80100a49:	e9 a3 0b 00 00       	jmp    801015f1 <alltraps>

80100a4e <vector25>:
.globl vector25
vector25:
  pushl $0
80100a4e:	6a 00                	push   $0x0
  pushl $25
80100a50:	6a 19                	push   $0x19
  jmp alltraps
80100a52:	e9 9a 0b 00 00       	jmp    801015f1 <alltraps>

80100a57 <vector26>:
.globl vector26
vector26:
  pushl $0
80100a57:	6a 00                	push   $0x0
  pushl $26
80100a59:	6a 1a                	push   $0x1a
  jmp alltraps
80100a5b:	e9 91 0b 00 00       	jmp    801015f1 <alltraps>

80100a60 <vector27>:
.globl vector27
vector27:
  pushl $0
80100a60:	6a 00                	push   $0x0
  pushl $27
80100a62:	6a 1b                	push   $0x1b
  jmp alltraps
80100a64:	e9 88 0b 00 00       	jmp    801015f1 <alltraps>

80100a69 <vector28>:
.globl vector28
vector28:
  pushl $0
80100a69:	6a 00                	push   $0x0
  pushl $28
80100a6b:	6a 1c                	push   $0x1c
  jmp alltraps
80100a6d:	e9 7f 0b 00 00       	jmp    801015f1 <alltraps>

80100a72 <vector29>:
.globl vector29
vector29:
  pushl $0
80100a72:	6a 00                	push   $0x0
  pushl $29
80100a74:	6a 1d                	push   $0x1d
  jmp alltraps
80100a76:	e9 76 0b 00 00       	jmp    801015f1 <alltraps>

80100a7b <vector30>:
.globl vector30
vector30:
  pushl $0
80100a7b:	6a 00                	push   $0x0
  pushl $30
80100a7d:	6a 1e                	push   $0x1e
  jmp alltraps
80100a7f:	e9 6d 0b 00 00       	jmp    801015f1 <alltraps>

80100a84 <vector31>:
.globl vector31
vector31:
  pushl $0
80100a84:	6a 00                	push   $0x0
  pushl $31
80100a86:	6a 1f                	push   $0x1f
  jmp alltraps
80100a88:	e9 64 0b 00 00       	jmp    801015f1 <alltraps>

80100a8d <vector32>:
.globl vector32
vector32:
  pushl $0
80100a8d:	6a 00                	push   $0x0
  pushl $32
80100a8f:	6a 20                	push   $0x20
  jmp alltraps
80100a91:	e9 5b 0b 00 00       	jmp    801015f1 <alltraps>

80100a96 <vector33>:
.globl vector33
vector33:
  pushl $0
80100a96:	6a 00                	push   $0x0
  pushl $33
80100a98:	6a 21                	push   $0x21
  jmp alltraps
80100a9a:	e9 52 0b 00 00       	jmp    801015f1 <alltraps>

80100a9f <vector34>:
.globl vector34
vector34:
  pushl $0
80100a9f:	6a 00                	push   $0x0
  pushl $34
80100aa1:	6a 22                	push   $0x22
  jmp alltraps
80100aa3:	e9 49 0b 00 00       	jmp    801015f1 <alltraps>

80100aa8 <vector35>:
.globl vector35
vector35:
  pushl $0
80100aa8:	6a 00                	push   $0x0
  pushl $35
80100aaa:	6a 23                	push   $0x23
  jmp alltraps
80100aac:	e9 40 0b 00 00       	jmp    801015f1 <alltraps>

80100ab1 <vector36>:
.globl vector36
vector36:
  pushl $0
80100ab1:	6a 00                	push   $0x0
  pushl $36
80100ab3:	6a 24                	push   $0x24
  jmp alltraps
80100ab5:	e9 37 0b 00 00       	jmp    801015f1 <alltraps>

80100aba <vector37>:
.globl vector37
vector37:
  pushl $0
80100aba:	6a 00                	push   $0x0
  pushl $37
80100abc:	6a 25                	push   $0x25
  jmp alltraps
80100abe:	e9 2e 0b 00 00       	jmp    801015f1 <alltraps>

80100ac3 <vector38>:
.globl vector38
vector38:
  pushl $0
80100ac3:	6a 00                	push   $0x0
  pushl $38
80100ac5:	6a 26                	push   $0x26
  jmp alltraps
80100ac7:	e9 25 0b 00 00       	jmp    801015f1 <alltraps>

80100acc <vector39>:
.globl vector39
vector39:
  pushl $0
80100acc:	6a 00                	push   $0x0
  pushl $39
80100ace:	6a 27                	push   $0x27
  jmp alltraps
80100ad0:	e9 1c 0b 00 00       	jmp    801015f1 <alltraps>

80100ad5 <vector40>:
.globl vector40
vector40:
  pushl $0
80100ad5:	6a 00                	push   $0x0
  pushl $40
80100ad7:	6a 28                	push   $0x28
  jmp alltraps
80100ad9:	e9 13 0b 00 00       	jmp    801015f1 <alltraps>

80100ade <vector41>:
.globl vector41
vector41:
  pushl $0
80100ade:	6a 00                	push   $0x0
  pushl $41
80100ae0:	6a 29                	push   $0x29
  jmp alltraps
80100ae2:	e9 0a 0b 00 00       	jmp    801015f1 <alltraps>

80100ae7 <vector42>:
.globl vector42
vector42:
  pushl $0
80100ae7:	6a 00                	push   $0x0
  pushl $42
80100ae9:	6a 2a                	push   $0x2a
  jmp alltraps
80100aeb:	e9 01 0b 00 00       	jmp    801015f1 <alltraps>

80100af0 <vector43>:
.globl vector43
vector43:
  pushl $0
80100af0:	6a 00                	push   $0x0
  pushl $43
80100af2:	6a 2b                	push   $0x2b
  jmp alltraps
80100af4:	e9 f8 0a 00 00       	jmp    801015f1 <alltraps>

80100af9 <vector44>:
.globl vector44
vector44:
  pushl $0
80100af9:	6a 00                	push   $0x0
  pushl $44
80100afb:	6a 2c                	push   $0x2c
  jmp alltraps
80100afd:	e9 ef 0a 00 00       	jmp    801015f1 <alltraps>

80100b02 <vector45>:
.globl vector45
vector45:
  pushl $0
80100b02:	6a 00                	push   $0x0
  pushl $45
80100b04:	6a 2d                	push   $0x2d
  jmp alltraps
80100b06:	e9 e6 0a 00 00       	jmp    801015f1 <alltraps>

80100b0b <vector46>:
.globl vector46
vector46:
  pushl $0
80100b0b:	6a 00                	push   $0x0
  pushl $46
80100b0d:	6a 2e                	push   $0x2e
  jmp alltraps
80100b0f:	e9 dd 0a 00 00       	jmp    801015f1 <alltraps>

80100b14 <vector47>:
.globl vector47
vector47:
  pushl $0
80100b14:	6a 00                	push   $0x0
  pushl $47
80100b16:	6a 2f                	push   $0x2f
  jmp alltraps
80100b18:	e9 d4 0a 00 00       	jmp    801015f1 <alltraps>

80100b1d <vector48>:
.globl vector48
vector48:
  pushl $0
80100b1d:	6a 00                	push   $0x0
  pushl $48
80100b1f:	6a 30                	push   $0x30
  jmp alltraps
80100b21:	e9 cb 0a 00 00       	jmp    801015f1 <alltraps>

80100b26 <vector49>:
.globl vector49
vector49:
  pushl $0
80100b26:	6a 00                	push   $0x0
  pushl $49
80100b28:	6a 31                	push   $0x31
  jmp alltraps
80100b2a:	e9 c2 0a 00 00       	jmp    801015f1 <alltraps>

80100b2f <vector50>:
.globl vector50
vector50:
  pushl $0
80100b2f:	6a 00                	push   $0x0
  pushl $50
80100b31:	6a 32                	push   $0x32
  jmp alltraps
80100b33:	e9 b9 0a 00 00       	jmp    801015f1 <alltraps>

80100b38 <vector51>:
.globl vector51
vector51:
  pushl $0
80100b38:	6a 00                	push   $0x0
  pushl $51
80100b3a:	6a 33                	push   $0x33
  jmp alltraps
80100b3c:	e9 b0 0a 00 00       	jmp    801015f1 <alltraps>

80100b41 <vector52>:
.globl vector52
vector52:
  pushl $0
80100b41:	6a 00                	push   $0x0
  pushl $52
80100b43:	6a 34                	push   $0x34
  jmp alltraps
80100b45:	e9 a7 0a 00 00       	jmp    801015f1 <alltraps>

80100b4a <vector53>:
.globl vector53
vector53:
  pushl $0
80100b4a:	6a 00                	push   $0x0
  pushl $53
80100b4c:	6a 35                	push   $0x35
  jmp alltraps
80100b4e:	e9 9e 0a 00 00       	jmp    801015f1 <alltraps>

80100b53 <vector54>:
.globl vector54
vector54:
  pushl $0
80100b53:	6a 00                	push   $0x0
  pushl $54
80100b55:	6a 36                	push   $0x36
  jmp alltraps
80100b57:	e9 95 0a 00 00       	jmp    801015f1 <alltraps>

80100b5c <vector55>:
.globl vector55
vector55:
  pushl $0
80100b5c:	6a 00                	push   $0x0
  pushl $55
80100b5e:	6a 37                	push   $0x37
  jmp alltraps
80100b60:	e9 8c 0a 00 00       	jmp    801015f1 <alltraps>

80100b65 <vector56>:
.globl vector56
vector56:
  pushl $0
80100b65:	6a 00                	push   $0x0
  pushl $56
80100b67:	6a 38                	push   $0x38
  jmp alltraps
80100b69:	e9 83 0a 00 00       	jmp    801015f1 <alltraps>

80100b6e <vector57>:
.globl vector57
vector57:
  pushl $0
80100b6e:	6a 00                	push   $0x0
  pushl $57
80100b70:	6a 39                	push   $0x39
  jmp alltraps
80100b72:	e9 7a 0a 00 00       	jmp    801015f1 <alltraps>

80100b77 <vector58>:
.globl vector58
vector58:
  pushl $0
80100b77:	6a 00                	push   $0x0
  pushl $58
80100b79:	6a 3a                	push   $0x3a
  jmp alltraps
80100b7b:	e9 71 0a 00 00       	jmp    801015f1 <alltraps>

80100b80 <vector59>:
.globl vector59
vector59:
  pushl $0
80100b80:	6a 00                	push   $0x0
  pushl $59
80100b82:	6a 3b                	push   $0x3b
  jmp alltraps
80100b84:	e9 68 0a 00 00       	jmp    801015f1 <alltraps>

80100b89 <vector60>:
.globl vector60
vector60:
  pushl $0
80100b89:	6a 00                	push   $0x0
  pushl $60
80100b8b:	6a 3c                	push   $0x3c
  jmp alltraps
80100b8d:	e9 5f 0a 00 00       	jmp    801015f1 <alltraps>

80100b92 <vector61>:
.globl vector61
vector61:
  pushl $0
80100b92:	6a 00                	push   $0x0
  pushl $61
80100b94:	6a 3d                	push   $0x3d
  jmp alltraps
80100b96:	e9 56 0a 00 00       	jmp    801015f1 <alltraps>

80100b9b <vector62>:
.globl vector62
vector62:
  pushl $0
80100b9b:	6a 00                	push   $0x0
  pushl $62
80100b9d:	6a 3e                	push   $0x3e
  jmp alltraps
80100b9f:	e9 4d 0a 00 00       	jmp    801015f1 <alltraps>

80100ba4 <vector63>:
.globl vector63
vector63:
  pushl $0
80100ba4:	6a 00                	push   $0x0
  pushl $63
80100ba6:	6a 3f                	push   $0x3f
  jmp alltraps
80100ba8:	e9 44 0a 00 00       	jmp    801015f1 <alltraps>

80100bad <vector64>:
.globl vector64
vector64:
  pushl $0
80100bad:	6a 00                	push   $0x0
  pushl $64
80100baf:	6a 40                	push   $0x40
  jmp alltraps
80100bb1:	e9 3b 0a 00 00       	jmp    801015f1 <alltraps>

80100bb6 <vector65>:
.globl vector65
vector65:
  pushl $0
80100bb6:	6a 00                	push   $0x0
  pushl $65
80100bb8:	6a 41                	push   $0x41
  jmp alltraps
80100bba:	e9 32 0a 00 00       	jmp    801015f1 <alltraps>

80100bbf <vector66>:
.globl vector66
vector66:
  pushl $0
80100bbf:	6a 00                	push   $0x0
  pushl $66
80100bc1:	6a 42                	push   $0x42
  jmp alltraps
80100bc3:	e9 29 0a 00 00       	jmp    801015f1 <alltraps>

80100bc8 <vector67>:
.globl vector67
vector67:
  pushl $0
80100bc8:	6a 00                	push   $0x0
  pushl $67
80100bca:	6a 43                	push   $0x43
  jmp alltraps
80100bcc:	e9 20 0a 00 00       	jmp    801015f1 <alltraps>

80100bd1 <vector68>:
.globl vector68
vector68:
  pushl $0
80100bd1:	6a 00                	push   $0x0
  pushl $68
80100bd3:	6a 44                	push   $0x44
  jmp alltraps
80100bd5:	e9 17 0a 00 00       	jmp    801015f1 <alltraps>

80100bda <vector69>:
.globl vector69
vector69:
  pushl $0
80100bda:	6a 00                	push   $0x0
  pushl $69
80100bdc:	6a 45                	push   $0x45
  jmp alltraps
80100bde:	e9 0e 0a 00 00       	jmp    801015f1 <alltraps>

80100be3 <vector70>:
.globl vector70
vector70:
  pushl $0
80100be3:	6a 00                	push   $0x0
  pushl $70
80100be5:	6a 46                	push   $0x46
  jmp alltraps
80100be7:	e9 05 0a 00 00       	jmp    801015f1 <alltraps>

80100bec <vector71>:
.globl vector71
vector71:
  pushl $0
80100bec:	6a 00                	push   $0x0
  pushl $71
80100bee:	6a 47                	push   $0x47
  jmp alltraps
80100bf0:	e9 fc 09 00 00       	jmp    801015f1 <alltraps>

80100bf5 <vector72>:
.globl vector72
vector72:
  pushl $0
80100bf5:	6a 00                	push   $0x0
  pushl $72
80100bf7:	6a 48                	push   $0x48
  jmp alltraps
80100bf9:	e9 f3 09 00 00       	jmp    801015f1 <alltraps>

80100bfe <vector73>:
.globl vector73
vector73:
  pushl $0
80100bfe:	6a 00                	push   $0x0
  pushl $73
80100c00:	6a 49                	push   $0x49
  jmp alltraps
80100c02:	e9 ea 09 00 00       	jmp    801015f1 <alltraps>

80100c07 <vector74>:
.globl vector74
vector74:
  pushl $0
80100c07:	6a 00                	push   $0x0
  pushl $74
80100c09:	6a 4a                	push   $0x4a
  jmp alltraps
80100c0b:	e9 e1 09 00 00       	jmp    801015f1 <alltraps>

80100c10 <vector75>:
.globl vector75
vector75:
  pushl $0
80100c10:	6a 00                	push   $0x0
  pushl $75
80100c12:	6a 4b                	push   $0x4b
  jmp alltraps
80100c14:	e9 d8 09 00 00       	jmp    801015f1 <alltraps>

80100c19 <vector76>:
.globl vector76
vector76:
  pushl $0
80100c19:	6a 00                	push   $0x0
  pushl $76
80100c1b:	6a 4c                	push   $0x4c
  jmp alltraps
80100c1d:	e9 cf 09 00 00       	jmp    801015f1 <alltraps>

80100c22 <vector77>:
.globl vector77
vector77:
  pushl $0
80100c22:	6a 00                	push   $0x0
  pushl $77
80100c24:	6a 4d                	push   $0x4d
  jmp alltraps
80100c26:	e9 c6 09 00 00       	jmp    801015f1 <alltraps>

80100c2b <vector78>:
.globl vector78
vector78:
  pushl $0
80100c2b:	6a 00                	push   $0x0
  pushl $78
80100c2d:	6a 4e                	push   $0x4e
  jmp alltraps
80100c2f:	e9 bd 09 00 00       	jmp    801015f1 <alltraps>

80100c34 <vector79>:
.globl vector79
vector79:
  pushl $0
80100c34:	6a 00                	push   $0x0
  pushl $79
80100c36:	6a 4f                	push   $0x4f
  jmp alltraps
80100c38:	e9 b4 09 00 00       	jmp    801015f1 <alltraps>

80100c3d <vector80>:
.globl vector80
vector80:
  pushl $0
80100c3d:	6a 00                	push   $0x0
  pushl $80
80100c3f:	6a 50                	push   $0x50
  jmp alltraps
80100c41:	e9 ab 09 00 00       	jmp    801015f1 <alltraps>

80100c46 <vector81>:
.globl vector81
vector81:
  pushl $0
80100c46:	6a 00                	push   $0x0
  pushl $81
80100c48:	6a 51                	push   $0x51
  jmp alltraps
80100c4a:	e9 a2 09 00 00       	jmp    801015f1 <alltraps>

80100c4f <vector82>:
.globl vector82
vector82:
  pushl $0
80100c4f:	6a 00                	push   $0x0
  pushl $82
80100c51:	6a 52                	push   $0x52
  jmp alltraps
80100c53:	e9 99 09 00 00       	jmp    801015f1 <alltraps>

80100c58 <vector83>:
.globl vector83
vector83:
  pushl $0
80100c58:	6a 00                	push   $0x0
  pushl $83
80100c5a:	6a 53                	push   $0x53
  jmp alltraps
80100c5c:	e9 90 09 00 00       	jmp    801015f1 <alltraps>

80100c61 <vector84>:
.globl vector84
vector84:
  pushl $0
80100c61:	6a 00                	push   $0x0
  pushl $84
80100c63:	6a 54                	push   $0x54
  jmp alltraps
80100c65:	e9 87 09 00 00       	jmp    801015f1 <alltraps>

80100c6a <vector85>:
.globl vector85
vector85:
  pushl $0
80100c6a:	6a 00                	push   $0x0
  pushl $85
80100c6c:	6a 55                	push   $0x55
  jmp alltraps
80100c6e:	e9 7e 09 00 00       	jmp    801015f1 <alltraps>

80100c73 <vector86>:
.globl vector86
vector86:
  pushl $0
80100c73:	6a 00                	push   $0x0
  pushl $86
80100c75:	6a 56                	push   $0x56
  jmp alltraps
80100c77:	e9 75 09 00 00       	jmp    801015f1 <alltraps>

80100c7c <vector87>:
.globl vector87
vector87:
  pushl $0
80100c7c:	6a 00                	push   $0x0
  pushl $87
80100c7e:	6a 57                	push   $0x57
  jmp alltraps
80100c80:	e9 6c 09 00 00       	jmp    801015f1 <alltraps>

80100c85 <vector88>:
.globl vector88
vector88:
  pushl $0
80100c85:	6a 00                	push   $0x0
  pushl $88
80100c87:	6a 58                	push   $0x58
  jmp alltraps
80100c89:	e9 63 09 00 00       	jmp    801015f1 <alltraps>

80100c8e <vector89>:
.globl vector89
vector89:
  pushl $0
80100c8e:	6a 00                	push   $0x0
  pushl $89
80100c90:	6a 59                	push   $0x59
  jmp alltraps
80100c92:	e9 5a 09 00 00       	jmp    801015f1 <alltraps>

80100c97 <vector90>:
.globl vector90
vector90:
  pushl $0
80100c97:	6a 00                	push   $0x0
  pushl $90
80100c99:	6a 5a                	push   $0x5a
  jmp alltraps
80100c9b:	e9 51 09 00 00       	jmp    801015f1 <alltraps>

80100ca0 <vector91>:
.globl vector91
vector91:
  pushl $0
80100ca0:	6a 00                	push   $0x0
  pushl $91
80100ca2:	6a 5b                	push   $0x5b
  jmp alltraps
80100ca4:	e9 48 09 00 00       	jmp    801015f1 <alltraps>

80100ca9 <vector92>:
.globl vector92
vector92:
  pushl $0
80100ca9:	6a 00                	push   $0x0
  pushl $92
80100cab:	6a 5c                	push   $0x5c
  jmp alltraps
80100cad:	e9 3f 09 00 00       	jmp    801015f1 <alltraps>

80100cb2 <vector93>:
.globl vector93
vector93:
  pushl $0
80100cb2:	6a 00                	push   $0x0
  pushl $93
80100cb4:	6a 5d                	push   $0x5d
  jmp alltraps
80100cb6:	e9 36 09 00 00       	jmp    801015f1 <alltraps>

80100cbb <vector94>:
.globl vector94
vector94:
  pushl $0
80100cbb:	6a 00                	push   $0x0
  pushl $94
80100cbd:	6a 5e                	push   $0x5e
  jmp alltraps
80100cbf:	e9 2d 09 00 00       	jmp    801015f1 <alltraps>

80100cc4 <vector95>:
.globl vector95
vector95:
  pushl $0
80100cc4:	6a 00                	push   $0x0
  pushl $95
80100cc6:	6a 5f                	push   $0x5f
  jmp alltraps
80100cc8:	e9 24 09 00 00       	jmp    801015f1 <alltraps>

80100ccd <vector96>:
.globl vector96
vector96:
  pushl $0
80100ccd:	6a 00                	push   $0x0
  pushl $96
80100ccf:	6a 60                	push   $0x60
  jmp alltraps
80100cd1:	e9 1b 09 00 00       	jmp    801015f1 <alltraps>

80100cd6 <vector97>:
.globl vector97
vector97:
  pushl $0
80100cd6:	6a 00                	push   $0x0
  pushl $97
80100cd8:	6a 61                	push   $0x61
  jmp alltraps
80100cda:	e9 12 09 00 00       	jmp    801015f1 <alltraps>

80100cdf <vector98>:
.globl vector98
vector98:
  pushl $0
80100cdf:	6a 00                	push   $0x0
  pushl $98
80100ce1:	6a 62                	push   $0x62
  jmp alltraps
80100ce3:	e9 09 09 00 00       	jmp    801015f1 <alltraps>

80100ce8 <vector99>:
.globl vector99
vector99:
  pushl $0
80100ce8:	6a 00                	push   $0x0
  pushl $99
80100cea:	6a 63                	push   $0x63
  jmp alltraps
80100cec:	e9 00 09 00 00       	jmp    801015f1 <alltraps>

80100cf1 <vector100>:
.globl vector100
vector100:
  pushl $0
80100cf1:	6a 00                	push   $0x0
  pushl $100
80100cf3:	6a 64                	push   $0x64
  jmp alltraps
80100cf5:	e9 f7 08 00 00       	jmp    801015f1 <alltraps>

80100cfa <vector101>:
.globl vector101
vector101:
  pushl $0
80100cfa:	6a 00                	push   $0x0
  pushl $101
80100cfc:	6a 65                	push   $0x65
  jmp alltraps
80100cfe:	e9 ee 08 00 00       	jmp    801015f1 <alltraps>

80100d03 <vector102>:
.globl vector102
vector102:
  pushl $0
80100d03:	6a 00                	push   $0x0
  pushl $102
80100d05:	6a 66                	push   $0x66
  jmp alltraps
80100d07:	e9 e5 08 00 00       	jmp    801015f1 <alltraps>

80100d0c <vector103>:
.globl vector103
vector103:
  pushl $0
80100d0c:	6a 00                	push   $0x0
  pushl $103
80100d0e:	6a 67                	push   $0x67
  jmp alltraps
80100d10:	e9 dc 08 00 00       	jmp    801015f1 <alltraps>

80100d15 <vector104>:
.globl vector104
vector104:
  pushl $0
80100d15:	6a 00                	push   $0x0
  pushl $104
80100d17:	6a 68                	push   $0x68
  jmp alltraps
80100d19:	e9 d3 08 00 00       	jmp    801015f1 <alltraps>

80100d1e <vector105>:
.globl vector105
vector105:
  pushl $0
80100d1e:	6a 00                	push   $0x0
  pushl $105
80100d20:	6a 69                	push   $0x69
  jmp alltraps
80100d22:	e9 ca 08 00 00       	jmp    801015f1 <alltraps>

80100d27 <vector106>:
.globl vector106
vector106:
  pushl $0
80100d27:	6a 00                	push   $0x0
  pushl $106
80100d29:	6a 6a                	push   $0x6a
  jmp alltraps
80100d2b:	e9 c1 08 00 00       	jmp    801015f1 <alltraps>

80100d30 <vector107>:
.globl vector107
vector107:
  pushl $0
80100d30:	6a 00                	push   $0x0
  pushl $107
80100d32:	6a 6b                	push   $0x6b
  jmp alltraps
80100d34:	e9 b8 08 00 00       	jmp    801015f1 <alltraps>

80100d39 <vector108>:
.globl vector108
vector108:
  pushl $0
80100d39:	6a 00                	push   $0x0
  pushl $108
80100d3b:	6a 6c                	push   $0x6c
  jmp alltraps
80100d3d:	e9 af 08 00 00       	jmp    801015f1 <alltraps>

80100d42 <vector109>:
.globl vector109
vector109:
  pushl $0
80100d42:	6a 00                	push   $0x0
  pushl $109
80100d44:	6a 6d                	push   $0x6d
  jmp alltraps
80100d46:	e9 a6 08 00 00       	jmp    801015f1 <alltraps>

80100d4b <vector110>:
.globl vector110
vector110:
  pushl $0
80100d4b:	6a 00                	push   $0x0
  pushl $110
80100d4d:	6a 6e                	push   $0x6e
  jmp alltraps
80100d4f:	e9 9d 08 00 00       	jmp    801015f1 <alltraps>

80100d54 <vector111>:
.globl vector111
vector111:
  pushl $0
80100d54:	6a 00                	push   $0x0
  pushl $111
80100d56:	6a 6f                	push   $0x6f
  jmp alltraps
80100d58:	e9 94 08 00 00       	jmp    801015f1 <alltraps>

80100d5d <vector112>:
.globl vector112
vector112:
  pushl $0
80100d5d:	6a 00                	push   $0x0
  pushl $112
80100d5f:	6a 70                	push   $0x70
  jmp alltraps
80100d61:	e9 8b 08 00 00       	jmp    801015f1 <alltraps>

80100d66 <vector113>:
.globl vector113
vector113:
  pushl $0
80100d66:	6a 00                	push   $0x0
  pushl $113
80100d68:	6a 71                	push   $0x71
  jmp alltraps
80100d6a:	e9 82 08 00 00       	jmp    801015f1 <alltraps>

80100d6f <vector114>:
.globl vector114
vector114:
  pushl $0
80100d6f:	6a 00                	push   $0x0
  pushl $114
80100d71:	6a 72                	push   $0x72
  jmp alltraps
80100d73:	e9 79 08 00 00       	jmp    801015f1 <alltraps>

80100d78 <vector115>:
.globl vector115
vector115:
  pushl $0
80100d78:	6a 00                	push   $0x0
  pushl $115
80100d7a:	6a 73                	push   $0x73
  jmp alltraps
80100d7c:	e9 70 08 00 00       	jmp    801015f1 <alltraps>

80100d81 <vector116>:
.globl vector116
vector116:
  pushl $0
80100d81:	6a 00                	push   $0x0
  pushl $116
80100d83:	6a 74                	push   $0x74
  jmp alltraps
80100d85:	e9 67 08 00 00       	jmp    801015f1 <alltraps>

80100d8a <vector117>:
.globl vector117
vector117:
  pushl $0
80100d8a:	6a 00                	push   $0x0
  pushl $117
80100d8c:	6a 75                	push   $0x75
  jmp alltraps
80100d8e:	e9 5e 08 00 00       	jmp    801015f1 <alltraps>

80100d93 <vector118>:
.globl vector118
vector118:
  pushl $0
80100d93:	6a 00                	push   $0x0
  pushl $118
80100d95:	6a 76                	push   $0x76
  jmp alltraps
80100d97:	e9 55 08 00 00       	jmp    801015f1 <alltraps>

80100d9c <vector119>:
.globl vector119
vector119:
  pushl $0
80100d9c:	6a 00                	push   $0x0
  pushl $119
80100d9e:	6a 77                	push   $0x77
  jmp alltraps
80100da0:	e9 4c 08 00 00       	jmp    801015f1 <alltraps>

80100da5 <vector120>:
.globl vector120
vector120:
  pushl $0
80100da5:	6a 00                	push   $0x0
  pushl $120
80100da7:	6a 78                	push   $0x78
  jmp alltraps
80100da9:	e9 43 08 00 00       	jmp    801015f1 <alltraps>

80100dae <vector121>:
.globl vector121
vector121:
  pushl $0
80100dae:	6a 00                	push   $0x0
  pushl $121
80100db0:	6a 79                	push   $0x79
  jmp alltraps
80100db2:	e9 3a 08 00 00       	jmp    801015f1 <alltraps>

80100db7 <vector122>:
.globl vector122
vector122:
  pushl $0
80100db7:	6a 00                	push   $0x0
  pushl $122
80100db9:	6a 7a                	push   $0x7a
  jmp alltraps
80100dbb:	e9 31 08 00 00       	jmp    801015f1 <alltraps>

80100dc0 <vector123>:
.globl vector123
vector123:
  pushl $0
80100dc0:	6a 00                	push   $0x0
  pushl $123
80100dc2:	6a 7b                	push   $0x7b
  jmp alltraps
80100dc4:	e9 28 08 00 00       	jmp    801015f1 <alltraps>

80100dc9 <vector124>:
.globl vector124
vector124:
  pushl $0
80100dc9:	6a 00                	push   $0x0
  pushl $124
80100dcb:	6a 7c                	push   $0x7c
  jmp alltraps
80100dcd:	e9 1f 08 00 00       	jmp    801015f1 <alltraps>

80100dd2 <vector125>:
.globl vector125
vector125:
  pushl $0
80100dd2:	6a 00                	push   $0x0
  pushl $125
80100dd4:	6a 7d                	push   $0x7d
  jmp alltraps
80100dd6:	e9 16 08 00 00       	jmp    801015f1 <alltraps>

80100ddb <vector126>:
.globl vector126
vector126:
  pushl $0
80100ddb:	6a 00                	push   $0x0
  pushl $126
80100ddd:	6a 7e                	push   $0x7e
  jmp alltraps
80100ddf:	e9 0d 08 00 00       	jmp    801015f1 <alltraps>

80100de4 <vector127>:
.globl vector127
vector127:
  pushl $0
80100de4:	6a 00                	push   $0x0
  pushl $127
80100de6:	6a 7f                	push   $0x7f
  jmp alltraps
80100de8:	e9 04 08 00 00       	jmp    801015f1 <alltraps>

80100ded <vector128>:
.globl vector128
vector128:
  pushl $0
80100ded:	6a 00                	push   $0x0
  pushl $128
80100def:	68 80 00 00 00       	push   $0x80
  jmp alltraps
80100df4:	e9 f8 07 00 00       	jmp    801015f1 <alltraps>

80100df9 <vector129>:
.globl vector129
vector129:
  pushl $0
80100df9:	6a 00                	push   $0x0
  pushl $129
80100dfb:	68 81 00 00 00       	push   $0x81
  jmp alltraps
80100e00:	e9 ec 07 00 00       	jmp    801015f1 <alltraps>

80100e05 <vector130>:
.globl vector130
vector130:
  pushl $0
80100e05:	6a 00                	push   $0x0
  pushl $130
80100e07:	68 82 00 00 00       	push   $0x82
  jmp alltraps
80100e0c:	e9 e0 07 00 00       	jmp    801015f1 <alltraps>

80100e11 <vector131>:
.globl vector131
vector131:
  pushl $0
80100e11:	6a 00                	push   $0x0
  pushl $131
80100e13:	68 83 00 00 00       	push   $0x83
  jmp alltraps
80100e18:	e9 d4 07 00 00       	jmp    801015f1 <alltraps>

80100e1d <vector132>:
.globl vector132
vector132:
  pushl $0
80100e1d:	6a 00                	push   $0x0
  pushl $132
80100e1f:	68 84 00 00 00       	push   $0x84
  jmp alltraps
80100e24:	e9 c8 07 00 00       	jmp    801015f1 <alltraps>

80100e29 <vector133>:
.globl vector133
vector133:
  pushl $0
80100e29:	6a 00                	push   $0x0
  pushl $133
80100e2b:	68 85 00 00 00       	push   $0x85
  jmp alltraps
80100e30:	e9 bc 07 00 00       	jmp    801015f1 <alltraps>

80100e35 <vector134>:
.globl vector134
vector134:
  pushl $0
80100e35:	6a 00                	push   $0x0
  pushl $134
80100e37:	68 86 00 00 00       	push   $0x86
  jmp alltraps
80100e3c:	e9 b0 07 00 00       	jmp    801015f1 <alltraps>

80100e41 <vector135>:
.globl vector135
vector135:
  pushl $0
80100e41:	6a 00                	push   $0x0
  pushl $135
80100e43:	68 87 00 00 00       	push   $0x87
  jmp alltraps
80100e48:	e9 a4 07 00 00       	jmp    801015f1 <alltraps>

80100e4d <vector136>:
.globl vector136
vector136:
  pushl $0
80100e4d:	6a 00                	push   $0x0
  pushl $136
80100e4f:	68 88 00 00 00       	push   $0x88
  jmp alltraps
80100e54:	e9 98 07 00 00       	jmp    801015f1 <alltraps>

80100e59 <vector137>:
.globl vector137
vector137:
  pushl $0
80100e59:	6a 00                	push   $0x0
  pushl $137
80100e5b:	68 89 00 00 00       	push   $0x89
  jmp alltraps
80100e60:	e9 8c 07 00 00       	jmp    801015f1 <alltraps>

80100e65 <vector138>:
.globl vector138
vector138:
  pushl $0
80100e65:	6a 00                	push   $0x0
  pushl $138
80100e67:	68 8a 00 00 00       	push   $0x8a
  jmp alltraps
80100e6c:	e9 80 07 00 00       	jmp    801015f1 <alltraps>

80100e71 <vector139>:
.globl vector139
vector139:
  pushl $0
80100e71:	6a 00                	push   $0x0
  pushl $139
80100e73:	68 8b 00 00 00       	push   $0x8b
  jmp alltraps
80100e78:	e9 74 07 00 00       	jmp    801015f1 <alltraps>

80100e7d <vector140>:
.globl vector140
vector140:
  pushl $0
80100e7d:	6a 00                	push   $0x0
  pushl $140
80100e7f:	68 8c 00 00 00       	push   $0x8c
  jmp alltraps
80100e84:	e9 68 07 00 00       	jmp    801015f1 <alltraps>

80100e89 <vector141>:
.globl vector141
vector141:
  pushl $0
80100e89:	6a 00                	push   $0x0
  pushl $141
80100e8b:	68 8d 00 00 00       	push   $0x8d
  jmp alltraps
80100e90:	e9 5c 07 00 00       	jmp    801015f1 <alltraps>

80100e95 <vector142>:
.globl vector142
vector142:
  pushl $0
80100e95:	6a 00                	push   $0x0
  pushl $142
80100e97:	68 8e 00 00 00       	push   $0x8e
  jmp alltraps
80100e9c:	e9 50 07 00 00       	jmp    801015f1 <alltraps>

80100ea1 <vector143>:
.globl vector143
vector143:
  pushl $0
80100ea1:	6a 00                	push   $0x0
  pushl $143
80100ea3:	68 8f 00 00 00       	push   $0x8f
  jmp alltraps
80100ea8:	e9 44 07 00 00       	jmp    801015f1 <alltraps>

80100ead <vector144>:
.globl vector144
vector144:
  pushl $0
80100ead:	6a 00                	push   $0x0
  pushl $144
80100eaf:	68 90 00 00 00       	push   $0x90
  jmp alltraps
80100eb4:	e9 38 07 00 00       	jmp    801015f1 <alltraps>

80100eb9 <vector145>:
.globl vector145
vector145:
  pushl $0
80100eb9:	6a 00                	push   $0x0
  pushl $145
80100ebb:	68 91 00 00 00       	push   $0x91
  jmp alltraps
80100ec0:	e9 2c 07 00 00       	jmp    801015f1 <alltraps>

80100ec5 <vector146>:
.globl vector146
vector146:
  pushl $0
80100ec5:	6a 00                	push   $0x0
  pushl $146
80100ec7:	68 92 00 00 00       	push   $0x92
  jmp alltraps
80100ecc:	e9 20 07 00 00       	jmp    801015f1 <alltraps>

80100ed1 <vector147>:
.globl vector147
vector147:
  pushl $0
80100ed1:	6a 00                	push   $0x0
  pushl $147
80100ed3:	68 93 00 00 00       	push   $0x93
  jmp alltraps
80100ed8:	e9 14 07 00 00       	jmp    801015f1 <alltraps>

80100edd <vector148>:
.globl vector148
vector148:
  pushl $0
80100edd:	6a 00                	push   $0x0
  pushl $148
80100edf:	68 94 00 00 00       	push   $0x94
  jmp alltraps
80100ee4:	e9 08 07 00 00       	jmp    801015f1 <alltraps>

80100ee9 <vector149>:
.globl vector149
vector149:
  pushl $0
80100ee9:	6a 00                	push   $0x0
  pushl $149
80100eeb:	68 95 00 00 00       	push   $0x95
  jmp alltraps
80100ef0:	e9 fc 06 00 00       	jmp    801015f1 <alltraps>

80100ef5 <vector150>:
.globl vector150
vector150:
  pushl $0
80100ef5:	6a 00                	push   $0x0
  pushl $150
80100ef7:	68 96 00 00 00       	push   $0x96
  jmp alltraps
80100efc:	e9 f0 06 00 00       	jmp    801015f1 <alltraps>

80100f01 <vector151>:
.globl vector151
vector151:
  pushl $0
80100f01:	6a 00                	push   $0x0
  pushl $151
80100f03:	68 97 00 00 00       	push   $0x97
  jmp alltraps
80100f08:	e9 e4 06 00 00       	jmp    801015f1 <alltraps>

80100f0d <vector152>:
.globl vector152
vector152:
  pushl $0
80100f0d:	6a 00                	push   $0x0
  pushl $152
80100f0f:	68 98 00 00 00       	push   $0x98
  jmp alltraps
80100f14:	e9 d8 06 00 00       	jmp    801015f1 <alltraps>

80100f19 <vector153>:
.globl vector153
vector153:
  pushl $0
80100f19:	6a 00                	push   $0x0
  pushl $153
80100f1b:	68 99 00 00 00       	push   $0x99
  jmp alltraps
80100f20:	e9 cc 06 00 00       	jmp    801015f1 <alltraps>

80100f25 <vector154>:
.globl vector154
vector154:
  pushl $0
80100f25:	6a 00                	push   $0x0
  pushl $154
80100f27:	68 9a 00 00 00       	push   $0x9a
  jmp alltraps
80100f2c:	e9 c0 06 00 00       	jmp    801015f1 <alltraps>

80100f31 <vector155>:
.globl vector155
vector155:
  pushl $0
80100f31:	6a 00                	push   $0x0
  pushl $155
80100f33:	68 9b 00 00 00       	push   $0x9b
  jmp alltraps
80100f38:	e9 b4 06 00 00       	jmp    801015f1 <alltraps>

80100f3d <vector156>:
.globl vector156
vector156:
  pushl $0
80100f3d:	6a 00                	push   $0x0
  pushl $156
80100f3f:	68 9c 00 00 00       	push   $0x9c
  jmp alltraps
80100f44:	e9 a8 06 00 00       	jmp    801015f1 <alltraps>

80100f49 <vector157>:
.globl vector157
vector157:
  pushl $0
80100f49:	6a 00                	push   $0x0
  pushl $157
80100f4b:	68 9d 00 00 00       	push   $0x9d
  jmp alltraps
80100f50:	e9 9c 06 00 00       	jmp    801015f1 <alltraps>

80100f55 <vector158>:
.globl vector158
vector158:
  pushl $0
80100f55:	6a 00                	push   $0x0
  pushl $158
80100f57:	68 9e 00 00 00       	push   $0x9e
  jmp alltraps
80100f5c:	e9 90 06 00 00       	jmp    801015f1 <alltraps>

80100f61 <vector159>:
.globl vector159
vector159:
  pushl $0
80100f61:	6a 00                	push   $0x0
  pushl $159
80100f63:	68 9f 00 00 00       	push   $0x9f
  jmp alltraps
80100f68:	e9 84 06 00 00       	jmp    801015f1 <alltraps>

80100f6d <vector160>:
.globl vector160
vector160:
  pushl $0
80100f6d:	6a 00                	push   $0x0
  pushl $160
80100f6f:	68 a0 00 00 00       	push   $0xa0
  jmp alltraps
80100f74:	e9 78 06 00 00       	jmp    801015f1 <alltraps>

80100f79 <vector161>:
.globl vector161
vector161:
  pushl $0
80100f79:	6a 00                	push   $0x0
  pushl $161
80100f7b:	68 a1 00 00 00       	push   $0xa1
  jmp alltraps
80100f80:	e9 6c 06 00 00       	jmp    801015f1 <alltraps>

80100f85 <vector162>:
.globl vector162
vector162:
  pushl $0
80100f85:	6a 00                	push   $0x0
  pushl $162
80100f87:	68 a2 00 00 00       	push   $0xa2
  jmp alltraps
80100f8c:	e9 60 06 00 00       	jmp    801015f1 <alltraps>

80100f91 <vector163>:
.globl vector163
vector163:
  pushl $0
80100f91:	6a 00                	push   $0x0
  pushl $163
80100f93:	68 a3 00 00 00       	push   $0xa3
  jmp alltraps
80100f98:	e9 54 06 00 00       	jmp    801015f1 <alltraps>

80100f9d <vector164>:
.globl vector164
vector164:
  pushl $0
80100f9d:	6a 00                	push   $0x0
  pushl $164
80100f9f:	68 a4 00 00 00       	push   $0xa4
  jmp alltraps
80100fa4:	e9 48 06 00 00       	jmp    801015f1 <alltraps>

80100fa9 <vector165>:
.globl vector165
vector165:
  pushl $0
80100fa9:	6a 00                	push   $0x0
  pushl $165
80100fab:	68 a5 00 00 00       	push   $0xa5
  jmp alltraps
80100fb0:	e9 3c 06 00 00       	jmp    801015f1 <alltraps>

80100fb5 <vector166>:
.globl vector166
vector166:
  pushl $0
80100fb5:	6a 00                	push   $0x0
  pushl $166
80100fb7:	68 a6 00 00 00       	push   $0xa6
  jmp alltraps
80100fbc:	e9 30 06 00 00       	jmp    801015f1 <alltraps>

80100fc1 <vector167>:
.globl vector167
vector167:
  pushl $0
80100fc1:	6a 00                	push   $0x0
  pushl $167
80100fc3:	68 a7 00 00 00       	push   $0xa7
  jmp alltraps
80100fc8:	e9 24 06 00 00       	jmp    801015f1 <alltraps>

80100fcd <vector168>:
.globl vector168
vector168:
  pushl $0
80100fcd:	6a 00                	push   $0x0
  pushl $168
80100fcf:	68 a8 00 00 00       	push   $0xa8
  jmp alltraps
80100fd4:	e9 18 06 00 00       	jmp    801015f1 <alltraps>

80100fd9 <vector169>:
.globl vector169
vector169:
  pushl $0
80100fd9:	6a 00                	push   $0x0
  pushl $169
80100fdb:	68 a9 00 00 00       	push   $0xa9
  jmp alltraps
80100fe0:	e9 0c 06 00 00       	jmp    801015f1 <alltraps>

80100fe5 <vector170>:
.globl vector170
vector170:
  pushl $0
80100fe5:	6a 00                	push   $0x0
  pushl $170
80100fe7:	68 aa 00 00 00       	push   $0xaa
  jmp alltraps
80100fec:	e9 00 06 00 00       	jmp    801015f1 <alltraps>

80100ff1 <vector171>:
.globl vector171
vector171:
  pushl $0
80100ff1:	6a 00                	push   $0x0
  pushl $171
80100ff3:	68 ab 00 00 00       	push   $0xab
  jmp alltraps
80100ff8:	e9 f4 05 00 00       	jmp    801015f1 <alltraps>

80100ffd <vector172>:
.globl vector172
vector172:
  pushl $0
80100ffd:	6a 00                	push   $0x0
  pushl $172
80100fff:	68 ac 00 00 00       	push   $0xac
  jmp alltraps
80101004:	e9 e8 05 00 00       	jmp    801015f1 <alltraps>

80101009 <vector173>:
.globl vector173
vector173:
  pushl $0
80101009:	6a 00                	push   $0x0
  pushl $173
8010100b:	68 ad 00 00 00       	push   $0xad
  jmp alltraps
80101010:	e9 dc 05 00 00       	jmp    801015f1 <alltraps>

80101015 <vector174>:
.globl vector174
vector174:
  pushl $0
80101015:	6a 00                	push   $0x0
  pushl $174
80101017:	68 ae 00 00 00       	push   $0xae
  jmp alltraps
8010101c:	e9 d0 05 00 00       	jmp    801015f1 <alltraps>

80101021 <vector175>:
.globl vector175
vector175:
  pushl $0
80101021:	6a 00                	push   $0x0
  pushl $175
80101023:	68 af 00 00 00       	push   $0xaf
  jmp alltraps
80101028:	e9 c4 05 00 00       	jmp    801015f1 <alltraps>

8010102d <vector176>:
.globl vector176
vector176:
  pushl $0
8010102d:	6a 00                	push   $0x0
  pushl $176
8010102f:	68 b0 00 00 00       	push   $0xb0
  jmp alltraps
80101034:	e9 b8 05 00 00       	jmp    801015f1 <alltraps>

80101039 <vector177>:
.globl vector177
vector177:
  pushl $0
80101039:	6a 00                	push   $0x0
  pushl $177
8010103b:	68 b1 00 00 00       	push   $0xb1
  jmp alltraps
80101040:	e9 ac 05 00 00       	jmp    801015f1 <alltraps>

80101045 <vector178>:
.globl vector178
vector178:
  pushl $0
80101045:	6a 00                	push   $0x0
  pushl $178
80101047:	68 b2 00 00 00       	push   $0xb2
  jmp alltraps
8010104c:	e9 a0 05 00 00       	jmp    801015f1 <alltraps>

80101051 <vector179>:
.globl vector179
vector179:
  pushl $0
80101051:	6a 00                	push   $0x0
  pushl $179
80101053:	68 b3 00 00 00       	push   $0xb3
  jmp alltraps
80101058:	e9 94 05 00 00       	jmp    801015f1 <alltraps>

8010105d <vector180>:
.globl vector180
vector180:
  pushl $0
8010105d:	6a 00                	push   $0x0
  pushl $180
8010105f:	68 b4 00 00 00       	push   $0xb4
  jmp alltraps
80101064:	e9 88 05 00 00       	jmp    801015f1 <alltraps>

80101069 <vector181>:
.globl vector181
vector181:
  pushl $0
80101069:	6a 00                	push   $0x0
  pushl $181
8010106b:	68 b5 00 00 00       	push   $0xb5
  jmp alltraps
80101070:	e9 7c 05 00 00       	jmp    801015f1 <alltraps>

80101075 <vector182>:
.globl vector182
vector182:
  pushl $0
80101075:	6a 00                	push   $0x0
  pushl $182
80101077:	68 b6 00 00 00       	push   $0xb6
  jmp alltraps
8010107c:	e9 70 05 00 00       	jmp    801015f1 <alltraps>

80101081 <vector183>:
.globl vector183
vector183:
  pushl $0
80101081:	6a 00                	push   $0x0
  pushl $183
80101083:	68 b7 00 00 00       	push   $0xb7
  jmp alltraps
80101088:	e9 64 05 00 00       	jmp    801015f1 <alltraps>

8010108d <vector184>:
.globl vector184
vector184:
  pushl $0
8010108d:	6a 00                	push   $0x0
  pushl $184
8010108f:	68 b8 00 00 00       	push   $0xb8
  jmp alltraps
80101094:	e9 58 05 00 00       	jmp    801015f1 <alltraps>

80101099 <vector185>:
.globl vector185
vector185:
  pushl $0
80101099:	6a 00                	push   $0x0
  pushl $185
8010109b:	68 b9 00 00 00       	push   $0xb9
  jmp alltraps
801010a0:	e9 4c 05 00 00       	jmp    801015f1 <alltraps>

801010a5 <vector186>:
.globl vector186
vector186:
  pushl $0
801010a5:	6a 00                	push   $0x0
  pushl $186
801010a7:	68 ba 00 00 00       	push   $0xba
  jmp alltraps
801010ac:	e9 40 05 00 00       	jmp    801015f1 <alltraps>

801010b1 <vector187>:
.globl vector187
vector187:
  pushl $0
801010b1:	6a 00                	push   $0x0
  pushl $187
801010b3:	68 bb 00 00 00       	push   $0xbb
  jmp alltraps
801010b8:	e9 34 05 00 00       	jmp    801015f1 <alltraps>

801010bd <vector188>:
.globl vector188
vector188:
  pushl $0
801010bd:	6a 00                	push   $0x0
  pushl $188
801010bf:	68 bc 00 00 00       	push   $0xbc
  jmp alltraps
801010c4:	e9 28 05 00 00       	jmp    801015f1 <alltraps>

801010c9 <vector189>:
.globl vector189
vector189:
  pushl $0
801010c9:	6a 00                	push   $0x0
  pushl $189
801010cb:	68 bd 00 00 00       	push   $0xbd
  jmp alltraps
801010d0:	e9 1c 05 00 00       	jmp    801015f1 <alltraps>

801010d5 <vector190>:
.globl vector190
vector190:
  pushl $0
801010d5:	6a 00                	push   $0x0
  pushl $190
801010d7:	68 be 00 00 00       	push   $0xbe
  jmp alltraps
801010dc:	e9 10 05 00 00       	jmp    801015f1 <alltraps>

801010e1 <vector191>:
.globl vector191
vector191:
  pushl $0
801010e1:	6a 00                	push   $0x0
  pushl $191
801010e3:	68 bf 00 00 00       	push   $0xbf
  jmp alltraps
801010e8:	e9 04 05 00 00       	jmp    801015f1 <alltraps>

801010ed <vector192>:
.globl vector192
vector192:
  pushl $0
801010ed:	6a 00                	push   $0x0
  pushl $192
801010ef:	68 c0 00 00 00       	push   $0xc0
  jmp alltraps
801010f4:	e9 f8 04 00 00       	jmp    801015f1 <alltraps>

801010f9 <vector193>:
.globl vector193
vector193:
  pushl $0
801010f9:	6a 00                	push   $0x0
  pushl $193
801010fb:	68 c1 00 00 00       	push   $0xc1
  jmp alltraps
80101100:	e9 ec 04 00 00       	jmp    801015f1 <alltraps>

80101105 <vector194>:
.globl vector194
vector194:
  pushl $0
80101105:	6a 00                	push   $0x0
  pushl $194
80101107:	68 c2 00 00 00       	push   $0xc2
  jmp alltraps
8010110c:	e9 e0 04 00 00       	jmp    801015f1 <alltraps>

80101111 <vector195>:
.globl vector195
vector195:
  pushl $0
80101111:	6a 00                	push   $0x0
  pushl $195
80101113:	68 c3 00 00 00       	push   $0xc3
  jmp alltraps
80101118:	e9 d4 04 00 00       	jmp    801015f1 <alltraps>

8010111d <vector196>:
.globl vector196
vector196:
  pushl $0
8010111d:	6a 00                	push   $0x0
  pushl $196
8010111f:	68 c4 00 00 00       	push   $0xc4
  jmp alltraps
80101124:	e9 c8 04 00 00       	jmp    801015f1 <alltraps>

80101129 <vector197>:
.globl vector197
vector197:
  pushl $0
80101129:	6a 00                	push   $0x0
  pushl $197
8010112b:	68 c5 00 00 00       	push   $0xc5
  jmp alltraps
80101130:	e9 bc 04 00 00       	jmp    801015f1 <alltraps>

80101135 <vector198>:
.globl vector198
vector198:
  pushl $0
80101135:	6a 00                	push   $0x0
  pushl $198
80101137:	68 c6 00 00 00       	push   $0xc6
  jmp alltraps
8010113c:	e9 b0 04 00 00       	jmp    801015f1 <alltraps>

80101141 <vector199>:
.globl vector199
vector199:
  pushl $0
80101141:	6a 00                	push   $0x0
  pushl $199
80101143:	68 c7 00 00 00       	push   $0xc7
  jmp alltraps
80101148:	e9 a4 04 00 00       	jmp    801015f1 <alltraps>

8010114d <vector200>:
.globl vector200
vector200:
  pushl $0
8010114d:	6a 00                	push   $0x0
  pushl $200
8010114f:	68 c8 00 00 00       	push   $0xc8
  jmp alltraps
80101154:	e9 98 04 00 00       	jmp    801015f1 <alltraps>

80101159 <vector201>:
.globl vector201
vector201:
  pushl $0
80101159:	6a 00                	push   $0x0
  pushl $201
8010115b:	68 c9 00 00 00       	push   $0xc9
  jmp alltraps
80101160:	e9 8c 04 00 00       	jmp    801015f1 <alltraps>

80101165 <vector202>:
.globl vector202
vector202:
  pushl $0
80101165:	6a 00                	push   $0x0
  pushl $202
80101167:	68 ca 00 00 00       	push   $0xca
  jmp alltraps
8010116c:	e9 80 04 00 00       	jmp    801015f1 <alltraps>

80101171 <vector203>:
.globl vector203
vector203:
  pushl $0
80101171:	6a 00                	push   $0x0
  pushl $203
80101173:	68 cb 00 00 00       	push   $0xcb
  jmp alltraps
80101178:	e9 74 04 00 00       	jmp    801015f1 <alltraps>

8010117d <vector204>:
.globl vector204
vector204:
  pushl $0
8010117d:	6a 00                	push   $0x0
  pushl $204
8010117f:	68 cc 00 00 00       	push   $0xcc
  jmp alltraps
80101184:	e9 68 04 00 00       	jmp    801015f1 <alltraps>

80101189 <vector205>:
.globl vector205
vector205:
  pushl $0
80101189:	6a 00                	push   $0x0
  pushl $205
8010118b:	68 cd 00 00 00       	push   $0xcd
  jmp alltraps
80101190:	e9 5c 04 00 00       	jmp    801015f1 <alltraps>

80101195 <vector206>:
.globl vector206
vector206:
  pushl $0
80101195:	6a 00                	push   $0x0
  pushl $206
80101197:	68 ce 00 00 00       	push   $0xce
  jmp alltraps
8010119c:	e9 50 04 00 00       	jmp    801015f1 <alltraps>

801011a1 <vector207>:
.globl vector207
vector207:
  pushl $0
801011a1:	6a 00                	push   $0x0
  pushl $207
801011a3:	68 cf 00 00 00       	push   $0xcf
  jmp alltraps
801011a8:	e9 44 04 00 00       	jmp    801015f1 <alltraps>

801011ad <vector208>:
.globl vector208
vector208:
  pushl $0
801011ad:	6a 00                	push   $0x0
  pushl $208
801011af:	68 d0 00 00 00       	push   $0xd0
  jmp alltraps
801011b4:	e9 38 04 00 00       	jmp    801015f1 <alltraps>

801011b9 <vector209>:
.globl vector209
vector209:
  pushl $0
801011b9:	6a 00                	push   $0x0
  pushl $209
801011bb:	68 d1 00 00 00       	push   $0xd1
  jmp alltraps
801011c0:	e9 2c 04 00 00       	jmp    801015f1 <alltraps>

801011c5 <vector210>:
.globl vector210
vector210:
  pushl $0
801011c5:	6a 00                	push   $0x0
  pushl $210
801011c7:	68 d2 00 00 00       	push   $0xd2
  jmp alltraps
801011cc:	e9 20 04 00 00       	jmp    801015f1 <alltraps>

801011d1 <vector211>:
.globl vector211
vector211:
  pushl $0
801011d1:	6a 00                	push   $0x0
  pushl $211
801011d3:	68 d3 00 00 00       	push   $0xd3
  jmp alltraps
801011d8:	e9 14 04 00 00       	jmp    801015f1 <alltraps>

801011dd <vector212>:
.globl vector212
vector212:
  pushl $0
801011dd:	6a 00                	push   $0x0
  pushl $212
801011df:	68 d4 00 00 00       	push   $0xd4
  jmp alltraps
801011e4:	e9 08 04 00 00       	jmp    801015f1 <alltraps>

801011e9 <vector213>:
.globl vector213
vector213:
  pushl $0
801011e9:	6a 00                	push   $0x0
  pushl $213
801011eb:	68 d5 00 00 00       	push   $0xd5
  jmp alltraps
801011f0:	e9 fc 03 00 00       	jmp    801015f1 <alltraps>

801011f5 <vector214>:
.globl vector214
vector214:
  pushl $0
801011f5:	6a 00                	push   $0x0
  pushl $214
801011f7:	68 d6 00 00 00       	push   $0xd6
  jmp alltraps
801011fc:	e9 f0 03 00 00       	jmp    801015f1 <alltraps>

80101201 <vector215>:
.globl vector215
vector215:
  pushl $0
80101201:	6a 00                	push   $0x0
  pushl $215
80101203:	68 d7 00 00 00       	push   $0xd7
  jmp alltraps
80101208:	e9 e4 03 00 00       	jmp    801015f1 <alltraps>

8010120d <vector216>:
.globl vector216
vector216:
  pushl $0
8010120d:	6a 00                	push   $0x0
  pushl $216
8010120f:	68 d8 00 00 00       	push   $0xd8
  jmp alltraps
80101214:	e9 d8 03 00 00       	jmp    801015f1 <alltraps>

80101219 <vector217>:
.globl vector217
vector217:
  pushl $0
80101219:	6a 00                	push   $0x0
  pushl $217
8010121b:	68 d9 00 00 00       	push   $0xd9
  jmp alltraps
80101220:	e9 cc 03 00 00       	jmp    801015f1 <alltraps>

80101225 <vector218>:
.globl vector218
vector218:
  pushl $0
80101225:	6a 00                	push   $0x0
  pushl $218
80101227:	68 da 00 00 00       	push   $0xda
  jmp alltraps
8010122c:	e9 c0 03 00 00       	jmp    801015f1 <alltraps>

80101231 <vector219>:
.globl vector219
vector219:
  pushl $0
80101231:	6a 00                	push   $0x0
  pushl $219
80101233:	68 db 00 00 00       	push   $0xdb
  jmp alltraps
80101238:	e9 b4 03 00 00       	jmp    801015f1 <alltraps>

8010123d <vector220>:
.globl vector220
vector220:
  pushl $0
8010123d:	6a 00                	push   $0x0
  pushl $220
8010123f:	68 dc 00 00 00       	push   $0xdc
  jmp alltraps
80101244:	e9 a8 03 00 00       	jmp    801015f1 <alltraps>

80101249 <vector221>:
.globl vector221
vector221:
  pushl $0
80101249:	6a 00                	push   $0x0
  pushl $221
8010124b:	68 dd 00 00 00       	push   $0xdd
  jmp alltraps
80101250:	e9 9c 03 00 00       	jmp    801015f1 <alltraps>

80101255 <vector222>:
.globl vector222
vector222:
  pushl $0
80101255:	6a 00                	push   $0x0
  pushl $222
80101257:	68 de 00 00 00       	push   $0xde
  jmp alltraps
8010125c:	e9 90 03 00 00       	jmp    801015f1 <alltraps>

80101261 <vector223>:
.globl vector223
vector223:
  pushl $0
80101261:	6a 00                	push   $0x0
  pushl $223
80101263:	68 df 00 00 00       	push   $0xdf
  jmp alltraps
80101268:	e9 84 03 00 00       	jmp    801015f1 <alltraps>

8010126d <vector224>:
.globl vector224
vector224:
  pushl $0
8010126d:	6a 00                	push   $0x0
  pushl $224
8010126f:	68 e0 00 00 00       	push   $0xe0
  jmp alltraps
80101274:	e9 78 03 00 00       	jmp    801015f1 <alltraps>

80101279 <vector225>:
.globl vector225
vector225:
  pushl $0
80101279:	6a 00                	push   $0x0
  pushl $225
8010127b:	68 e1 00 00 00       	push   $0xe1
  jmp alltraps
80101280:	e9 6c 03 00 00       	jmp    801015f1 <alltraps>

80101285 <vector226>:
.globl vector226
vector226:
  pushl $0
80101285:	6a 00                	push   $0x0
  pushl $226
80101287:	68 e2 00 00 00       	push   $0xe2
  jmp alltraps
8010128c:	e9 60 03 00 00       	jmp    801015f1 <alltraps>

80101291 <vector227>:
.globl vector227
vector227:
  pushl $0
80101291:	6a 00                	push   $0x0
  pushl $227
80101293:	68 e3 00 00 00       	push   $0xe3
  jmp alltraps
80101298:	e9 54 03 00 00       	jmp    801015f1 <alltraps>

8010129d <vector228>:
.globl vector228
vector228:
  pushl $0
8010129d:	6a 00                	push   $0x0
  pushl $228
8010129f:	68 e4 00 00 00       	push   $0xe4
  jmp alltraps
801012a4:	e9 48 03 00 00       	jmp    801015f1 <alltraps>

801012a9 <vector229>:
.globl vector229
vector229:
  pushl $0
801012a9:	6a 00                	push   $0x0
  pushl $229
801012ab:	68 e5 00 00 00       	push   $0xe5
  jmp alltraps
801012b0:	e9 3c 03 00 00       	jmp    801015f1 <alltraps>

801012b5 <vector230>:
.globl vector230
vector230:
  pushl $0
801012b5:	6a 00                	push   $0x0
  pushl $230
801012b7:	68 e6 00 00 00       	push   $0xe6
  jmp alltraps
801012bc:	e9 30 03 00 00       	jmp    801015f1 <alltraps>

801012c1 <vector231>:
.globl vector231
vector231:
  pushl $0
801012c1:	6a 00                	push   $0x0
  pushl $231
801012c3:	68 e7 00 00 00       	push   $0xe7
  jmp alltraps
801012c8:	e9 24 03 00 00       	jmp    801015f1 <alltraps>

801012cd <vector232>:
.globl vector232
vector232:
  pushl $0
801012cd:	6a 00                	push   $0x0
  pushl $232
801012cf:	68 e8 00 00 00       	push   $0xe8
  jmp alltraps
801012d4:	e9 18 03 00 00       	jmp    801015f1 <alltraps>

801012d9 <vector233>:
.globl vector233
vector233:
  pushl $0
801012d9:	6a 00                	push   $0x0
  pushl $233
801012db:	68 e9 00 00 00       	push   $0xe9
  jmp alltraps
801012e0:	e9 0c 03 00 00       	jmp    801015f1 <alltraps>

801012e5 <vector234>:
.globl vector234
vector234:
  pushl $0
801012e5:	6a 00                	push   $0x0
  pushl $234
801012e7:	68 ea 00 00 00       	push   $0xea
  jmp alltraps
801012ec:	e9 00 03 00 00       	jmp    801015f1 <alltraps>

801012f1 <vector235>:
.globl vector235
vector235:
  pushl $0
801012f1:	6a 00                	push   $0x0
  pushl $235
801012f3:	68 eb 00 00 00       	push   $0xeb
  jmp alltraps
801012f8:	e9 f4 02 00 00       	jmp    801015f1 <alltraps>

801012fd <vector236>:
.globl vector236
vector236:
  pushl $0
801012fd:	6a 00                	push   $0x0
  pushl $236
801012ff:	68 ec 00 00 00       	push   $0xec
  jmp alltraps
80101304:	e9 e8 02 00 00       	jmp    801015f1 <alltraps>

80101309 <vector237>:
.globl vector237
vector237:
  pushl $0
80101309:	6a 00                	push   $0x0
  pushl $237
8010130b:	68 ed 00 00 00       	push   $0xed
  jmp alltraps
80101310:	e9 dc 02 00 00       	jmp    801015f1 <alltraps>

80101315 <vector238>:
.globl vector238
vector238:
  pushl $0
80101315:	6a 00                	push   $0x0
  pushl $238
80101317:	68 ee 00 00 00       	push   $0xee
  jmp alltraps
8010131c:	e9 d0 02 00 00       	jmp    801015f1 <alltraps>

80101321 <vector239>:
.globl vector239
vector239:
  pushl $0
80101321:	6a 00                	push   $0x0
  pushl $239
80101323:	68 ef 00 00 00       	push   $0xef
  jmp alltraps
80101328:	e9 c4 02 00 00       	jmp    801015f1 <alltraps>

8010132d <vector240>:
.globl vector240
vector240:
  pushl $0
8010132d:	6a 00                	push   $0x0
  pushl $240
8010132f:	68 f0 00 00 00       	push   $0xf0
  jmp alltraps
80101334:	e9 b8 02 00 00       	jmp    801015f1 <alltraps>

80101339 <vector241>:
.globl vector241
vector241:
  pushl $0
80101339:	6a 00                	push   $0x0
  pushl $241
8010133b:	68 f1 00 00 00       	push   $0xf1
  jmp alltraps
80101340:	e9 ac 02 00 00       	jmp    801015f1 <alltraps>

80101345 <vector242>:
.globl vector242
vector242:
  pushl $0
80101345:	6a 00                	push   $0x0
  pushl $242
80101347:	68 f2 00 00 00       	push   $0xf2
  jmp alltraps
8010134c:	e9 a0 02 00 00       	jmp    801015f1 <alltraps>

80101351 <vector243>:
.globl vector243
vector243:
  pushl $0
80101351:	6a 00                	push   $0x0
  pushl $243
80101353:	68 f3 00 00 00       	push   $0xf3
  jmp alltraps
80101358:	e9 94 02 00 00       	jmp    801015f1 <alltraps>

8010135d <vector244>:
.globl vector244
vector244:
  pushl $0
8010135d:	6a 00                	push   $0x0
  pushl $244
8010135f:	68 f4 00 00 00       	push   $0xf4
  jmp alltraps
80101364:	e9 88 02 00 00       	jmp    801015f1 <alltraps>

80101369 <vector245>:
.globl vector245
vector245:
  pushl $0
80101369:	6a 00                	push   $0x0
  pushl $245
8010136b:	68 f5 00 00 00       	push   $0xf5
  jmp alltraps
80101370:	e9 7c 02 00 00       	jmp    801015f1 <alltraps>

80101375 <vector246>:
.globl vector246
vector246:
  pushl $0
80101375:	6a 00                	push   $0x0
  pushl $246
80101377:	68 f6 00 00 00       	push   $0xf6
  jmp alltraps
8010137c:	e9 70 02 00 00       	jmp    801015f1 <alltraps>

80101381 <vector247>:
.globl vector247
vector247:
  pushl $0
80101381:	6a 00                	push   $0x0
  pushl $247
80101383:	68 f7 00 00 00       	push   $0xf7
  jmp alltraps
80101388:	e9 64 02 00 00       	jmp    801015f1 <alltraps>

8010138d <vector248>:
.globl vector248
vector248:
  pushl $0
8010138d:	6a 00                	push   $0x0
  pushl $248
8010138f:	68 f8 00 00 00       	push   $0xf8
  jmp alltraps
80101394:	e9 58 02 00 00       	jmp    801015f1 <alltraps>

80101399 <vector249>:
.globl vector249
vector249:
  pushl $0
80101399:	6a 00                	push   $0x0
  pushl $249
8010139b:	68 f9 00 00 00       	push   $0xf9
  jmp alltraps
801013a0:	e9 4c 02 00 00       	jmp    801015f1 <alltraps>

801013a5 <vector250>:
.globl vector250
vector250:
  pushl $0
801013a5:	6a 00                	push   $0x0
  pushl $250
801013a7:	68 fa 00 00 00       	push   $0xfa
  jmp alltraps
801013ac:	e9 40 02 00 00       	jmp    801015f1 <alltraps>

801013b1 <vector251>:
.globl vector251
vector251:
  pushl $0
801013b1:	6a 00                	push   $0x0
  pushl $251
801013b3:	68 fb 00 00 00       	push   $0xfb
  jmp alltraps
801013b8:	e9 34 02 00 00       	jmp    801015f1 <alltraps>

801013bd <vector252>:
.globl vector252
vector252:
  pushl $0
801013bd:	6a 00                	push   $0x0
  pushl $252
801013bf:	68 fc 00 00 00       	push   $0xfc
  jmp alltraps
801013c4:	e9 28 02 00 00       	jmp    801015f1 <alltraps>

801013c9 <vector253>:
.globl vector253
vector253:
  pushl $0
801013c9:	6a 00                	push   $0x0
  pushl $253
801013cb:	68 fd 00 00 00       	push   $0xfd
  jmp alltraps
801013d0:	e9 1c 02 00 00       	jmp    801015f1 <alltraps>

801013d5 <vector254>:
.globl vector254
vector254:
  pushl $0
801013d5:	6a 00                	push   $0x0
  pushl $254
801013d7:	68 fe 00 00 00       	push   $0xfe
  jmp alltraps
801013dc:	e9 10 02 00 00       	jmp    801015f1 <alltraps>

801013e1 <vector255>:
.globl vector255
vector255:
  pushl $0
801013e1:	6a 00                	push   $0x0
  pushl $255
801013e3:	68 ff 00 00 00       	push   $0xff
  jmp alltraps
801013e8:	e9 04 02 00 00       	jmp    801015f1 <alltraps>

801013ed <lidt>:

struct gatedesc;

static inline void
lidt(struct gatedesc *p, int size)
{
801013ed:	55                   	push   %ebp
801013ee:	89 e5                	mov    %esp,%ebp
801013f0:	83 ec 10             	sub    $0x10,%esp
  volatile ushort pd[3];

  pd[0] = size-1;
801013f3:	8b 45 0c             	mov    0xc(%ebp),%eax
801013f6:	83 e8 01             	sub    $0x1,%eax
801013f9:	66 89 45 fa          	mov    %ax,-0x6(%ebp)
  pd[1] = (uint)p;
801013fd:	8b 45 08             	mov    0x8(%ebp),%eax
80101400:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  pd[2] = (uint)p >> 16;
80101404:	8b 45 08             	mov    0x8(%ebp),%eax
80101407:	c1 e8 10             	shr    $0x10,%eax
8010140a:	66 89 45 fe          	mov    %ax,-0x2(%ebp)

  asm volatile("lidt (%0)" : : "r" (pd));
8010140e:	8d 45 fa             	lea    -0x6(%ebp),%eax
80101411:	0f 01 18             	lidtl  (%eax)
}
80101414:	c9                   	leave  
80101415:	c3                   	ret    

80101416 <tvinit>:


// 中断描述符表初始化，将IDT中的每一个中断描述符都与vector.S中256个中断的地址相对应
void
tvinit(void)
{
80101416:	55                   	push   %ebp
80101417:	89 e5                	mov    %esp,%ebp
80101419:	83 ec 10             	sub    $0x10,%esp
  int i;
  for(i = 0; i < 256; i++)
8010141c:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
80101423:	e9 c3 00 00 00       	jmp    801014eb <tvinit+0xd5>
    SETGATE(idt[i], 0, SEG_KCODE<<3, vectors[i], 0);
80101428:	8b 45 fc             	mov    -0x4(%ebp),%eax
8010142b:	8b 04 85 15 30 10 80 	mov    -0x7fefcfeb(,%eax,4),%eax
80101432:	89 c2                	mov    %eax,%edx
80101434:	8b 45 fc             	mov    -0x4(%ebp),%eax
80101437:	66 89 14 c5 80 44 10 	mov    %dx,-0x7fefbb80(,%eax,8)
8010143e:	80 
8010143f:	8b 45 fc             	mov    -0x4(%ebp),%eax
80101442:	66 c7 04 c5 82 44 10 	movw   $0x8,-0x7fefbb7e(,%eax,8)
80101449:	80 08 00 
8010144c:	8b 45 fc             	mov    -0x4(%ebp),%eax
8010144f:	0f b6 14 c5 84 44 10 	movzbl -0x7fefbb7c(,%eax,8),%edx
80101456:	80 
80101457:	83 e2 e0             	and    $0xffffffe0,%edx
8010145a:	88 14 c5 84 44 10 80 	mov    %dl,-0x7fefbb7c(,%eax,8)
80101461:	8b 45 fc             	mov    -0x4(%ebp),%eax
80101464:	0f b6 14 c5 84 44 10 	movzbl -0x7fefbb7c(,%eax,8),%edx
8010146b:	80 
8010146c:	83 e2 1f             	and    $0x1f,%edx
8010146f:	88 14 c5 84 44 10 80 	mov    %dl,-0x7fefbb7c(,%eax,8)
80101476:	8b 45 fc             	mov    -0x4(%ebp),%eax
80101479:	0f b6 14 c5 85 44 10 	movzbl -0x7fefbb7b(,%eax,8),%edx
80101480:	80 
80101481:	83 e2 f0             	and    $0xfffffff0,%edx
80101484:	83 ca 0e             	or     $0xe,%edx
80101487:	88 14 c5 85 44 10 80 	mov    %dl,-0x7fefbb7b(,%eax,8)
8010148e:	8b 45 fc             	mov    -0x4(%ebp),%eax
80101491:	0f b6 14 c5 85 44 10 	movzbl -0x7fefbb7b(,%eax,8),%edx
80101498:	80 
80101499:	83 e2 ef             	and    $0xffffffef,%edx
8010149c:	88 14 c5 85 44 10 80 	mov    %dl,-0x7fefbb7b(,%eax,8)
801014a3:	8b 45 fc             	mov    -0x4(%ebp),%eax
801014a6:	0f b6 14 c5 85 44 10 	movzbl -0x7fefbb7b(,%eax,8),%edx
801014ad:	80 
801014ae:	83 e2 9f             	and    $0xffffff9f,%edx
801014b1:	88 14 c5 85 44 10 80 	mov    %dl,-0x7fefbb7b(,%eax,8)
801014b8:	8b 45 fc             	mov    -0x4(%ebp),%eax
801014bb:	0f b6 14 c5 85 44 10 	movzbl -0x7fefbb7b(,%eax,8),%edx
801014c2:	80 
801014c3:	83 ca 80             	or     $0xffffff80,%edx
801014c6:	88 14 c5 85 44 10 80 	mov    %dl,-0x7fefbb7b(,%eax,8)
801014cd:	8b 45 fc             	mov    -0x4(%ebp),%eax
801014d0:	8b 04 85 15 30 10 80 	mov    -0x7fefcfeb(,%eax,4),%eax
801014d7:	c1 e8 10             	shr    $0x10,%eax
801014da:	89 c2                	mov    %eax,%edx
801014dc:	8b 45 fc             	mov    -0x4(%ebp),%eax
801014df:	66 89 14 c5 86 44 10 	mov    %dx,-0x7fefbb7a(,%eax,8)
801014e6:	80 
// 中断描述符表初始化，将IDT中的每一个中断描述符都与vector.S中256个中断的地址相对应
void
tvinit(void)
{
  int i;
  for(i = 0; i < 256; i++)
801014e7:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
801014eb:	81 7d fc ff 00 00 00 	cmpl   $0xff,-0x4(%ebp)
801014f2:	0f 8e 30 ff ff ff    	jle    80101428 <tvinit+0x12>
    SETGATE(idt[i], 0, SEG_KCODE<<3, vectors[i], 0);
  SETGATE(idt[T_SYSCALL], 1, SEG_KCODE<<3, vectors[T_SYSCALL], DPL_USER);
801014f8:	a1 15 31 10 80       	mov    0x80103115,%eax
801014fd:	66 a3 80 46 10 80    	mov    %ax,0x80104680
80101503:	66 c7 05 82 46 10 80 	movw   $0x8,0x80104682
8010150a:	08 00 
8010150c:	0f b6 05 84 46 10 80 	movzbl 0x80104684,%eax
80101513:	83 e0 e0             	and    $0xffffffe0,%eax
80101516:	a2 84 46 10 80       	mov    %al,0x80104684
8010151b:	0f b6 05 84 46 10 80 	movzbl 0x80104684,%eax
80101522:	83 e0 1f             	and    $0x1f,%eax
80101525:	a2 84 46 10 80       	mov    %al,0x80104684
8010152a:	0f b6 05 85 46 10 80 	movzbl 0x80104685,%eax
80101531:	83 c8 0f             	or     $0xf,%eax
80101534:	a2 85 46 10 80       	mov    %al,0x80104685
80101539:	0f b6 05 85 46 10 80 	movzbl 0x80104685,%eax
80101540:	83 e0 ef             	and    $0xffffffef,%eax
80101543:	a2 85 46 10 80       	mov    %al,0x80104685
80101548:	0f b6 05 85 46 10 80 	movzbl 0x80104685,%eax
8010154f:	83 c8 60             	or     $0x60,%eax
80101552:	a2 85 46 10 80       	mov    %al,0x80104685
80101557:	0f b6 05 85 46 10 80 	movzbl 0x80104685,%eax
8010155e:	83 c8 80             	or     $0xffffff80,%eax
80101561:	a2 85 46 10 80       	mov    %al,0x80104685
80101566:	a1 15 31 10 80       	mov    0x80103115,%eax
8010156b:	c1 e8 10             	shr    $0x10,%eax
8010156e:	66 a3 86 46 10 80    	mov    %ax,0x80104686
}
80101574:	c9                   	leave  
80101575:	c3                   	ret    

80101576 <printidt>:

// 打印一些当前IDT内中的一些信息
void 
printidt(void)
{
80101576:	55                   	push   %ebp
80101577:	89 e5                	mov    %esp,%ebp
80101579:	83 ec 18             	sub    $0x18,%esp
  int i = 0;
8010157c:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  for(;i<=10;i++){
80101583:	eb 48                	jmp    801015cd <printidt+0x57>
	cprintf("IDT %d: offset 31~16:%d\n", i, idt[i].off_31_16);
80101585:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101588:	0f b7 04 c5 86 44 10 	movzwl -0x7fefbb7a(,%eax,8),%eax
8010158f:	80 
80101590:	0f b7 c0             	movzwl %ax,%eax
80101593:	83 ec 04             	sub    $0x4,%esp
80101596:	50                   	push   %eax
80101597:	ff 75 f4             	pushl  -0xc(%ebp)
8010159a:	68 57 18 10 80       	push   $0x80101857
8010159f:	e8 c5 eb ff ff       	call   80100169 <cprintf>
801015a4:	83 c4 10             	add    $0x10,%esp
	cprintf("IDT %d: offset 15~0:%d\n", i, idt[i].off_15_0);
801015a7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801015aa:	0f b7 04 c5 80 44 10 	movzwl -0x7fefbb80(,%eax,8),%eax
801015b1:	80 
801015b2:	0f b7 c0             	movzwl %ax,%eax
801015b5:	83 ec 04             	sub    $0x4,%esp
801015b8:	50                   	push   %eax
801015b9:	ff 75 f4             	pushl  -0xc(%ebp)
801015bc:	68 70 18 10 80       	push   $0x80101870
801015c1:	e8 a3 eb ff ff       	call   80100169 <cprintf>
801015c6:	83 c4 10             	add    $0x10,%esp
// 打印一些当前IDT内中的一些信息
void 
printidt(void)
{
  int i = 0;
  for(;i<=10;i++){
801015c9:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801015cd:	83 7d f4 0a          	cmpl   $0xa,-0xc(%ebp)
801015d1:	7e b2                	jle    80101585 <printidt+0xf>
	cprintf("IDT %d: offset 31~16:%d\n", i, idt[i].off_31_16);
	cprintf("IDT %d: offset 15~0:%d\n", i, idt[i].off_15_0);
  }
}
801015d3:	c9                   	leave  
801015d4:	c3                   	ret    

801015d5 <idtinit>:

// 加载idt，调用内联汇编
void
idtinit(void)
{
801015d5:	55                   	push   %ebp
801015d6:	89 e5                	mov    %esp,%ebp
  lidt(idt, sizeof(idt));
801015d8:	68 00 08 00 00       	push   $0x800
801015dd:	68 80 44 10 80       	push   $0x80104480
801015e2:	e8 06 fe ff ff       	call   801013ed <lidt>
801015e7:	83 c4 08             	add    $0x8,%esp
}
801015ea:	c9                   	leave  
801015eb:	c3                   	ret    

801015ec <trap>:

// 中断处理程序,目前什么都不做
void
trap(struct trapframe *tf) {}
801015ec:	55                   	push   %ebp
801015ed:	89 e5                	mov    %esp,%ebp
801015ef:	5d                   	pop    %ebp
801015f0:	c3                   	ret    

801015f1 <alltraps>:
  # vectors.S 会把所有的中断都掉转到这里
.globl alltraps

alltraps:
  # 建立一个中断帧，保护现场
  pushl %ds
801015f1:	1e                   	push   %ds
  pushl %es
801015f2:	06                   	push   %es
  pushl %fs
801015f3:	0f a0                	push   %fs
  pushl %gs
801015f5:	0f a8                	push   %gs
  pushal
801015f7:	60                   	pusha  
  
  # 设置数据段
  movw $(SEG_KDATA<<3), %ax
801015f8:	66 b8 10 00          	mov    $0x10,%ax
  movw %ax, %ds
801015fc:	8e d8                	mov    %eax,%ds
  movw %ax, %es
801015fe:	8e c0                	mov    %eax,%es

  # 调用trap函数，执行中断服务程序，目前针对所有中断都不做任何处理
  # 定义在了trap.c中，同时压栈esp，这里的esp就代表了trap的参数tf，也就是当前的中断帧
  pushl %esp
80101600:	54                   	push   %esp
  call trap
80101601:	e8 e6 ff ff ff       	call   801015ec <trap>
  addl $4, %esp
80101606:	83 c4 04             	add    $0x4,%esp

80101609 <trapret>:

  # 执行完中断服务程序以后开始恢复现场
.globl trapret
trapret:
  popal
80101609:	61                   	popa   
  popl %gs
8010160a:	0f a9                	pop    %gs
  popl %fs
8010160c:	0f a1                	pop    %fs
  popl %es
8010160e:	07                   	pop    %es
  popl %ds
8010160f:	1f                   	pop    %ds
  addl $0x8, %esp  # 中断号以及错误号
80101610:	83 c4 08             	add    $0x8,%esp
  iret
80101613:	cf                   	iret   

80101614 <inb>:
// Routines to let C code use special x86 instructions.

static inline uchar
inb(ushort port)
{
80101614:	55                   	push   %ebp
80101615:	89 e5                	mov    %esp,%ebp
80101617:	83 ec 14             	sub    $0x14,%esp
8010161a:	8b 45 08             	mov    0x8(%ebp),%eax
8010161d:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
  uchar data;

  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80101621:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
80101625:	89 c2                	mov    %eax,%edx
80101627:	ec                   	in     (%dx),%al
80101628:	88 45 ff             	mov    %al,-0x1(%ebp)
  return data;
8010162b:	0f b6 45 ff          	movzbl -0x1(%ebp),%eax
}
8010162f:	c9                   	leave  
80101630:	c3                   	ret    

80101631 <outb>:
               "memory", "cc");
}

static inline void
outb(ushort port, uchar data)
{
80101631:	55                   	push   %ebp
80101632:	89 e5                	mov    %esp,%ebp
80101634:	83 ec 08             	sub    $0x8,%esp
80101637:	8b 55 08             	mov    0x8(%ebp),%edx
8010163a:	8b 45 0c             	mov    0xc(%ebp),%eax
8010163d:	66 89 55 fc          	mov    %dx,-0x4(%ebp)
80101641:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80101644:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
80101648:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
8010164c:	ee                   	out    %al,(%dx)
}
8010164d:	c9                   	leave  
8010164e:	c3                   	ret    

8010164f <uartputc>:

#define COM1    0x3f8

void
uartputc(int c)
{
8010164f:	55                   	push   %ebp
80101650:	89 e5                	mov    %esp,%ebp
80101652:	83 ec 10             	sub    $0x10,%esp
  int i;
  for(i = 0; i < 128 && !(inb(COM1+5) & 0x20); i++)
80101655:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
8010165c:	eb 18                	jmp    80101676 <uartputc+0x27>
  outb(COM1+0, c);
8010165e:	8b 45 08             	mov    0x8(%ebp),%eax
80101661:	0f b6 c0             	movzbl %al,%eax
80101664:	50                   	push   %eax
80101665:	68 f8 03 00 00       	push   $0x3f8
8010166a:	e8 c2 ff ff ff       	call   80101631 <outb>
8010166f:	83 c4 08             	add    $0x8,%esp

void
uartputc(int c)
{
  int i;
  for(i = 0; i < 128 && !(inb(COM1+5) & 0x20); i++)
80101672:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
80101676:	83 7d fc 7f          	cmpl   $0x7f,-0x4(%ebp)
8010167a:	7f 17                	jg     80101693 <uartputc+0x44>
8010167c:	68 fd 03 00 00       	push   $0x3fd
80101681:	e8 8e ff ff ff       	call   80101614 <inb>
80101686:	83 c4 04             	add    $0x4,%esp
80101689:	0f b6 c0             	movzbl %al,%eax
8010168c:	83 e0 20             	and    $0x20,%eax
8010168f:	85 c0                	test   %eax,%eax
80101691:	74 cb                	je     8010165e <uartputc+0xf>
  outb(COM1+0, c);
}
80101693:	c9                   	leave  
80101694:	c3                   	ret    
