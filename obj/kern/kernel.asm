
obj/kern/kernel:     file format elf32-i386


Disassembly of section .text:

f0100000 <_start+0xeffffff4>:
.globl		_start
_start = RELOC(entry)

.globl entry
entry:
	movw	$0x1234,0x472			# warm boot
f0100000:	02 b0 ad 1b 00 00    	add    0x1bad(%eax),%dh
f0100006:	00 00                	add    %al,(%eax)
f0100008:	fe 4f 52             	decb   0x52(%edi)
f010000b:	e4                   	.byte 0xe4

f010000c <entry>:
f010000c:	66 c7 05 72 04 00 00 	movw   $0x1234,0x472
f0100013:	34 12 
	# sufficient until we set up our real page table in mem_init
	# in lab 2.

	# Load the physical address of entry_pgdir into cr3.  entry_pgdir
	# is defined in entrypgdir.c.
	movl	$(RELOC(entry_pgdir)), %eax
f0100015:	b8 00 20 11 00       	mov    $0x112000,%eax
	movl	%eax, %cr3
f010001a:	0f 22 d8             	mov    %eax,%cr3
	# Turn on paging.
	movl	%cr0, %eax
f010001d:	0f 20 c0             	mov    %cr0,%eax
	orl	$(CR0_PE|CR0_PG|CR0_WP), %eax
f0100020:	0d 01 00 01 80       	or     $0x80010001,%eax
	movl	%eax, %cr0
f0100025:	0f 22 c0             	mov    %eax,%cr0

	# Now paging is enabled, but we're still running at a low EIP
	# (why is this okay?).  Jump up above KERNBASE before entering
	# C code.
	mov	$relocated, %eax
f0100028:	b8 2f 00 10 f0       	mov    $0xf010002f,%eax
	jmp	*%eax
f010002d:	ff e0                	jmp    *%eax

f010002f <relocated>:
relocated:

	# Clear the frame pointer register (EBP)
	# so that once we get into debugging C code,
	# stack backtraces will be terminated properly.
	movl	$0x0,%ebp			# nuke frame pointer
f010002f:	bd 00 00 00 00       	mov    $0x0,%ebp

	# Set the stack pointer
	movl	$(bootstacktop),%esp
f0100034:	bc 00 00 11 f0       	mov    $0xf0110000,%esp

	# now to C code
	call	i386_init
f0100039:	e8 68 00 00 00       	call   f01000a6 <i386_init>

f010003e <spin>:

	# Should never get here, but in case we do, just spin.
spin:	jmp	spin
f010003e:	eb fe                	jmp    f010003e <spin>

f0100040 <test_backtrace>:
#include <kern/console.h>

// Test the stack backtrace function (lab 1 only)
void
test_backtrace(int x)
{
f0100040:	55                   	push   %ebp
f0100041:	89 e5                	mov    %esp,%ebp
f0100043:	56                   	push   %esi
f0100044:	53                   	push   %ebx
f0100045:	e8 72 01 00 00       	call   f01001bc <__x86.get_pc_thunk.bx>
f010004a:	81 c3 be 12 01 00    	add    $0x112be,%ebx
f0100050:	8b 75 08             	mov    0x8(%ebp),%esi
	cprintf("entering test_backtrace %d\n", x);
f0100053:	83 ec 08             	sub    $0x8,%esp
f0100056:	56                   	push   %esi
f0100057:	8d 83 18 08 ff ff    	lea    -0xf7e8(%ebx),%eax
f010005d:	50                   	push   %eax
f010005e:	e8 75 0a 00 00       	call   f0100ad8 <cprintf>
	if (x > 0)
f0100063:	83 c4 10             	add    $0x10,%esp
f0100066:	85 f6                	test   %esi,%esi
f0100068:	7e 29                	jle    f0100093 <test_backtrace+0x53>
		test_backtrace(x-1);
f010006a:	83 ec 0c             	sub    $0xc,%esp
f010006d:	8d 46 ff             	lea    -0x1(%esi),%eax
f0100070:	50                   	push   %eax
f0100071:	e8 ca ff ff ff       	call   f0100040 <test_backtrace>
f0100076:	83 c4 10             	add    $0x10,%esp
	else
		mon_backtrace(0, 0, 0);
	cprintf("leaving test_backtrace %d\n", x);
f0100079:	83 ec 08             	sub    $0x8,%esp
f010007c:	56                   	push   %esi
f010007d:	8d 83 34 08 ff ff    	lea    -0xf7cc(%ebx),%eax
f0100083:	50                   	push   %eax
f0100084:	e8 4f 0a 00 00       	call   f0100ad8 <cprintf>
}
f0100089:	83 c4 10             	add    $0x10,%esp
f010008c:	8d 65 f8             	lea    -0x8(%ebp),%esp
f010008f:	5b                   	pop    %ebx
f0100090:	5e                   	pop    %esi
f0100091:	5d                   	pop    %ebp
f0100092:	c3                   	ret    
		mon_backtrace(0, 0, 0);
f0100093:	83 ec 04             	sub    $0x4,%esp
f0100096:	6a 00                	push   $0x0
f0100098:	6a 00                	push   $0x0
f010009a:	6a 00                	push   $0x0
f010009c:	e8 ed 07 00 00       	call   f010088e <mon_backtrace>
f01000a1:	83 c4 10             	add    $0x10,%esp
f01000a4:	eb d3                	jmp    f0100079 <test_backtrace+0x39>

f01000a6 <i386_init>:

void
i386_init(void)
{
f01000a6:	55                   	push   %ebp
f01000a7:	89 e5                	mov    %esp,%ebp
f01000a9:	53                   	push   %ebx
f01000aa:	83 ec 08             	sub    $0x8,%esp
f01000ad:	e8 0a 01 00 00       	call   f01001bc <__x86.get_pc_thunk.bx>
f01000b2:	81 c3 56 12 01 00    	add    $0x11256,%ebx
	extern char edata[], end[];

	// Before doing anything else, complete the ELF loading process.
	// Clear the uninitialized global data (BSS) section of our program.
	// This ensures that all static/global variables start out zero.
	memset(edata, 0, end - edata);
f01000b8:	c7 c2 60 30 11 f0    	mov    $0xf0113060,%edx
f01000be:	c7 c0 c0 36 11 f0    	mov    $0xf01136c0,%eax
f01000c4:	29 d0                	sub    %edx,%eax
f01000c6:	50                   	push   %eax
f01000c7:	6a 00                	push   $0x0
f01000c9:	52                   	push   %edx
f01000ca:	e8 09 16 00 00       	call   f01016d8 <memset>

	// Initialize the console.
	// Can't call cprintf until after we do this!
	cons_init();
f01000cf:	e8 3e 05 00 00       	call   f0100612 <cons_init>

	cprintf("6828 decimal is %o octal!\n", 6828);
f01000d4:	83 c4 08             	add    $0x8,%esp
f01000d7:	68 ac 1a 00 00       	push   $0x1aac
f01000dc:	8d 83 4f 08 ff ff    	lea    -0xf7b1(%ebx),%eax
f01000e2:	50                   	push   %eax
f01000e3:	e8 f0 09 00 00       	call   f0100ad8 <cprintf>

	// Test the stack backtrace function (lab 1 only)
	test_backtrace(5);
f01000e8:	c7 04 24 05 00 00 00 	movl   $0x5,(%esp)
f01000ef:	e8 4c ff ff ff       	call   f0100040 <test_backtrace>
f01000f4:	83 c4 10             	add    $0x10,%esp

	// Drop into the kernel monitor.
	while (1)
		monitor(NULL);
f01000f7:	83 ec 0c             	sub    $0xc,%esp
f01000fa:	6a 00                	push   $0x0
f01000fc:	e8 1e 08 00 00       	call   f010091f <monitor>
f0100101:	83 c4 10             	add    $0x10,%esp
f0100104:	eb f1                	jmp    f01000f7 <i386_init+0x51>

f0100106 <_panic>:
 * Panic is called on unresolvable fatal errors.
 * It prints "panic: mesg", and then enters the kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt,...)
{
f0100106:	55                   	push   %ebp
f0100107:	89 e5                	mov    %esp,%ebp
f0100109:	56                   	push   %esi
f010010a:	53                   	push   %ebx
f010010b:	e8 ac 00 00 00       	call   f01001bc <__x86.get_pc_thunk.bx>
f0100110:	81 c3 f8 11 01 00    	add    $0x111f8,%ebx
	va_list ap;

	if (panicstr)
f0100116:	83 bb 58 1d 00 00 00 	cmpl   $0x0,0x1d58(%ebx)
f010011d:	74 0f                	je     f010012e <_panic+0x28>
	va_end(ap);

dead:
	/* break into the kernel monitor */
	while (1)
		monitor(NULL);
f010011f:	83 ec 0c             	sub    $0xc,%esp
f0100122:	6a 00                	push   $0x0
f0100124:	e8 f6 07 00 00       	call   f010091f <monitor>
f0100129:	83 c4 10             	add    $0x10,%esp
f010012c:	eb f1                	jmp    f010011f <_panic+0x19>
	panicstr = fmt;
f010012e:	8b 45 10             	mov    0x10(%ebp),%eax
f0100131:	89 83 58 1d 00 00    	mov    %eax,0x1d58(%ebx)
	asm volatile("cli; cld");
f0100137:	fa                   	cli    
f0100138:	fc                   	cld    
	va_start(ap, fmt);
f0100139:	8d 75 14             	lea    0x14(%ebp),%esi
	cprintf("kernel panic at %s:%d: ", file, line);
f010013c:	83 ec 04             	sub    $0x4,%esp
f010013f:	ff 75 0c             	push   0xc(%ebp)
f0100142:	ff 75 08             	push   0x8(%ebp)
f0100145:	8d 83 6a 08 ff ff    	lea    -0xf796(%ebx),%eax
f010014b:	50                   	push   %eax
f010014c:	e8 87 09 00 00       	call   f0100ad8 <cprintf>
	vcprintf(fmt, ap);
f0100151:	83 c4 08             	add    $0x8,%esp
f0100154:	56                   	push   %esi
f0100155:	ff 75 10             	push   0x10(%ebp)
f0100158:	e8 44 09 00 00       	call   f0100aa1 <vcprintf>
	cprintf("\n");
f010015d:	8d 83 a6 08 ff ff    	lea    -0xf75a(%ebx),%eax
f0100163:	89 04 24             	mov    %eax,(%esp)
f0100166:	e8 6d 09 00 00       	call   f0100ad8 <cprintf>
f010016b:	83 c4 10             	add    $0x10,%esp
f010016e:	eb af                	jmp    f010011f <_panic+0x19>

f0100170 <_warn>:
}

/* like panic, but don't */
void
_warn(const char *file, int line, const char *fmt,...)
{
f0100170:	55                   	push   %ebp
f0100171:	89 e5                	mov    %esp,%ebp
f0100173:	56                   	push   %esi
f0100174:	53                   	push   %ebx
f0100175:	e8 42 00 00 00       	call   f01001bc <__x86.get_pc_thunk.bx>
f010017a:	81 c3 8e 11 01 00    	add    $0x1118e,%ebx
	va_list ap;

	va_start(ap, fmt);
f0100180:	8d 75 14             	lea    0x14(%ebp),%esi
	cprintf("kernel warning at %s:%d: ", file, line);
f0100183:	83 ec 04             	sub    $0x4,%esp
f0100186:	ff 75 0c             	push   0xc(%ebp)
f0100189:	ff 75 08             	push   0x8(%ebp)
f010018c:	8d 83 82 08 ff ff    	lea    -0xf77e(%ebx),%eax
f0100192:	50                   	push   %eax
f0100193:	e8 40 09 00 00       	call   f0100ad8 <cprintf>
	vcprintf(fmt, ap);
f0100198:	83 c4 08             	add    $0x8,%esp
f010019b:	56                   	push   %esi
f010019c:	ff 75 10             	push   0x10(%ebp)
f010019f:	e8 fd 08 00 00       	call   f0100aa1 <vcprintf>
	cprintf("\n");
f01001a4:	8d 83 a6 08 ff ff    	lea    -0xf75a(%ebx),%eax
f01001aa:	89 04 24             	mov    %eax,(%esp)
f01001ad:	e8 26 09 00 00       	call   f0100ad8 <cprintf>
	va_end(ap);
}
f01001b2:	83 c4 10             	add    $0x10,%esp
f01001b5:	8d 65 f8             	lea    -0x8(%ebp),%esp
f01001b8:	5b                   	pop    %ebx
f01001b9:	5e                   	pop    %esi
f01001ba:	5d                   	pop    %ebp
f01001bb:	c3                   	ret    

f01001bc <__x86.get_pc_thunk.bx>:
f01001bc:	8b 1c 24             	mov    (%esp),%ebx
f01001bf:	c3                   	ret    

f01001c0 <serial_proc_data>:

static inline uint8_t
inb(int port)
{
	uint8_t data;
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f01001c0:	ba fd 03 00 00       	mov    $0x3fd,%edx
f01001c5:	ec                   	in     (%dx),%al
static bool serial_exists;

static int
serial_proc_data(void)
{
	if (!(inb(COM1+COM_LSR) & COM_LSR_DATA))
f01001c6:	a8 01                	test   $0x1,%al
f01001c8:	74 0a                	je     f01001d4 <serial_proc_data+0x14>
f01001ca:	ba f8 03 00 00       	mov    $0x3f8,%edx
f01001cf:	ec                   	in     (%dx),%al
		return -1;
	return inb(COM1+COM_RX);
f01001d0:	0f b6 c0             	movzbl %al,%eax
f01001d3:	c3                   	ret    
		return -1;
f01001d4:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
f01001d9:	c3                   	ret    

f01001da <cons_intr>:

// called by device interrupt routines to feed input characters
// into the circular console input buffer.
static void
cons_intr(int (*proc)(void))
{
f01001da:	55                   	push   %ebp
f01001db:	89 e5                	mov    %esp,%ebp
f01001dd:	57                   	push   %edi
f01001de:	56                   	push   %esi
f01001df:	53                   	push   %ebx
f01001e0:	83 ec 1c             	sub    $0x1c,%esp
f01001e3:	e8 6a 05 00 00       	call   f0100752 <__x86.get_pc_thunk.si>
f01001e8:	81 c6 20 11 01 00    	add    $0x11120,%esi
f01001ee:	89 c7                	mov    %eax,%edi
	int c;

	while ((c = (*proc)()) != -1) {
		if (c == 0)
			continue;
		cons.buf[cons.wpos++] = c;
f01001f0:	8d 1d 98 1d 00 00    	lea    0x1d98,%ebx
f01001f6:	8d 04 1e             	lea    (%esi,%ebx,1),%eax
f01001f9:	89 45 e0             	mov    %eax,-0x20(%ebp)
f01001fc:	89 7d e4             	mov    %edi,-0x1c(%ebp)
	while ((c = (*proc)()) != -1) {
f01001ff:	eb 25                	jmp    f0100226 <cons_intr+0x4c>
		cons.buf[cons.wpos++] = c;
f0100201:	8b 8c 1e 04 02 00 00 	mov    0x204(%esi,%ebx,1),%ecx
f0100208:	8d 51 01             	lea    0x1(%ecx),%edx
f010020b:	8b 7d e0             	mov    -0x20(%ebp),%edi
f010020e:	88 04 0f             	mov    %al,(%edi,%ecx,1)
		if (cons.wpos == CONSBUFSIZE)
f0100211:	81 fa 00 02 00 00    	cmp    $0x200,%edx
			cons.wpos = 0;
f0100217:	b8 00 00 00 00       	mov    $0x0,%eax
f010021c:	0f 44 d0             	cmove  %eax,%edx
f010021f:	89 94 1e 04 02 00 00 	mov    %edx,0x204(%esi,%ebx,1)
	while ((c = (*proc)()) != -1) {
f0100226:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0100229:	ff d0                	call   *%eax
f010022b:	83 f8 ff             	cmp    $0xffffffff,%eax
f010022e:	74 06                	je     f0100236 <cons_intr+0x5c>
		if (c == 0)
f0100230:	85 c0                	test   %eax,%eax
f0100232:	75 cd                	jne    f0100201 <cons_intr+0x27>
f0100234:	eb f0                	jmp    f0100226 <cons_intr+0x4c>
	}
}
f0100236:	83 c4 1c             	add    $0x1c,%esp
f0100239:	5b                   	pop    %ebx
f010023a:	5e                   	pop    %esi
f010023b:	5f                   	pop    %edi
f010023c:	5d                   	pop    %ebp
f010023d:	c3                   	ret    

f010023e <kbd_proc_data>:
{
f010023e:	55                   	push   %ebp
f010023f:	89 e5                	mov    %esp,%ebp
f0100241:	56                   	push   %esi
f0100242:	53                   	push   %ebx
f0100243:	e8 74 ff ff ff       	call   f01001bc <__x86.get_pc_thunk.bx>
f0100248:	81 c3 c0 10 01 00    	add    $0x110c0,%ebx
f010024e:	ba 64 00 00 00       	mov    $0x64,%edx
f0100253:	ec                   	in     (%dx),%al
	if ((stat & KBS_DIB) == 0)
f0100254:	a8 01                	test   $0x1,%al
f0100256:	0f 84 f7 00 00 00    	je     f0100353 <kbd_proc_data+0x115>
	if (stat & KBS_TERR)
f010025c:	a8 20                	test   $0x20,%al
f010025e:	0f 85 f6 00 00 00    	jne    f010035a <kbd_proc_data+0x11c>
f0100264:	ba 60 00 00 00       	mov    $0x60,%edx
f0100269:	ec                   	in     (%dx),%al
f010026a:	89 c2                	mov    %eax,%edx
	if (data == 0xE0) {
f010026c:	3c e0                	cmp    $0xe0,%al
f010026e:	74 64                	je     f01002d4 <kbd_proc_data+0x96>
	} else if (data & 0x80) {
f0100270:	84 c0                	test   %al,%al
f0100272:	78 75                	js     f01002e9 <kbd_proc_data+0xab>
	} else if (shift & E0ESC) {
f0100274:	8b 8b 78 1d 00 00    	mov    0x1d78(%ebx),%ecx
f010027a:	f6 c1 40             	test   $0x40,%cl
f010027d:	74 0e                	je     f010028d <kbd_proc_data+0x4f>
		data |= 0x80;
f010027f:	83 c8 80             	or     $0xffffff80,%eax
f0100282:	89 c2                	mov    %eax,%edx
		shift &= ~E0ESC;
f0100284:	83 e1 bf             	and    $0xffffffbf,%ecx
f0100287:	89 8b 78 1d 00 00    	mov    %ecx,0x1d78(%ebx)
	shift |= shiftcode[data];
f010028d:	0f b6 d2             	movzbl %dl,%edx
f0100290:	0f b6 84 13 d8 09 ff 	movzbl -0xf628(%ebx,%edx,1),%eax
f0100297:	ff 
f0100298:	0b 83 78 1d 00 00    	or     0x1d78(%ebx),%eax
	shift ^= togglecode[data];
f010029e:	0f b6 8c 13 d8 08 ff 	movzbl -0xf728(%ebx,%edx,1),%ecx
f01002a5:	ff 
f01002a6:	31 c8                	xor    %ecx,%eax
f01002a8:	89 83 78 1d 00 00    	mov    %eax,0x1d78(%ebx)
	c = charcode[shift & (CTL | SHIFT)][data];
f01002ae:	89 c1                	mov    %eax,%ecx
f01002b0:	83 e1 03             	and    $0x3,%ecx
f01002b3:	8b 8c 8b f8 1c 00 00 	mov    0x1cf8(%ebx,%ecx,4),%ecx
f01002ba:	0f b6 14 11          	movzbl (%ecx,%edx,1),%edx
f01002be:	0f b6 f2             	movzbl %dl,%esi
	if (shift & CAPSLOCK) {
f01002c1:	a8 08                	test   $0x8,%al
f01002c3:	74 61                	je     f0100326 <kbd_proc_data+0xe8>
		if ('a' <= c && c <= 'z')
f01002c5:	89 f2                	mov    %esi,%edx
f01002c7:	8d 4e 9f             	lea    -0x61(%esi),%ecx
f01002ca:	83 f9 19             	cmp    $0x19,%ecx
f01002cd:	77 4b                	ja     f010031a <kbd_proc_data+0xdc>
			c += 'A' - 'a';
f01002cf:	83 ee 20             	sub    $0x20,%esi
f01002d2:	eb 0c                	jmp    f01002e0 <kbd_proc_data+0xa2>
		shift |= E0ESC;
f01002d4:	83 8b 78 1d 00 00 40 	orl    $0x40,0x1d78(%ebx)
		return 0;
f01002db:	be 00 00 00 00       	mov    $0x0,%esi
}
f01002e0:	89 f0                	mov    %esi,%eax
f01002e2:	8d 65 f8             	lea    -0x8(%ebp),%esp
f01002e5:	5b                   	pop    %ebx
f01002e6:	5e                   	pop    %esi
f01002e7:	5d                   	pop    %ebp
f01002e8:	c3                   	ret    
		data = (shift & E0ESC ? data : data & 0x7F);
f01002e9:	8b 8b 78 1d 00 00    	mov    0x1d78(%ebx),%ecx
f01002ef:	83 e0 7f             	and    $0x7f,%eax
f01002f2:	f6 c1 40             	test   $0x40,%cl
f01002f5:	0f 44 d0             	cmove  %eax,%edx
		shift &= ~(shiftcode[data] | E0ESC);
f01002f8:	0f b6 d2             	movzbl %dl,%edx
f01002fb:	0f b6 84 13 d8 09 ff 	movzbl -0xf628(%ebx,%edx,1),%eax
f0100302:	ff 
f0100303:	83 c8 40             	or     $0x40,%eax
f0100306:	0f b6 c0             	movzbl %al,%eax
f0100309:	f7 d0                	not    %eax
f010030b:	21 c8                	and    %ecx,%eax
f010030d:	89 83 78 1d 00 00    	mov    %eax,0x1d78(%ebx)
		return 0;
f0100313:	be 00 00 00 00       	mov    $0x0,%esi
f0100318:	eb c6                	jmp    f01002e0 <kbd_proc_data+0xa2>
		else if ('A' <= c && c <= 'Z')
f010031a:	83 ea 41             	sub    $0x41,%edx
			c += 'a' - 'A';
f010031d:	8d 4e 20             	lea    0x20(%esi),%ecx
f0100320:	83 fa 1a             	cmp    $0x1a,%edx
f0100323:	0f 42 f1             	cmovb  %ecx,%esi
	if (!(~shift & (CTL | ALT)) && c == KEY_DEL) {
f0100326:	f7 d0                	not    %eax
f0100328:	a8 06                	test   $0x6,%al
f010032a:	75 b4                	jne    f01002e0 <kbd_proc_data+0xa2>
f010032c:	81 fe e9 00 00 00    	cmp    $0xe9,%esi
f0100332:	75 ac                	jne    f01002e0 <kbd_proc_data+0xa2>
		cprintf("Rebooting!\n");
f0100334:	83 ec 0c             	sub    $0xc,%esp
f0100337:	8d 83 9c 08 ff ff    	lea    -0xf764(%ebx),%eax
f010033d:	50                   	push   %eax
f010033e:	e8 95 07 00 00       	call   f0100ad8 <cprintf>
}

static inline void
outb(int port, uint8_t data)
{
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0100343:	b8 03 00 00 00       	mov    $0x3,%eax
f0100348:	ba 92 00 00 00       	mov    $0x92,%edx
f010034d:	ee                   	out    %al,(%dx)
}
f010034e:	83 c4 10             	add    $0x10,%esp
f0100351:	eb 8d                	jmp    f01002e0 <kbd_proc_data+0xa2>
		return -1;
f0100353:	be ff ff ff ff       	mov    $0xffffffff,%esi
f0100358:	eb 86                	jmp    f01002e0 <kbd_proc_data+0xa2>
		return -1;
f010035a:	be ff ff ff ff       	mov    $0xffffffff,%esi
f010035f:	e9 7c ff ff ff       	jmp    f01002e0 <kbd_proc_data+0xa2>

f0100364 <cons_putc>:
}

// output a character to the console
static void
cons_putc(int c)
{
f0100364:	55                   	push   %ebp
f0100365:	89 e5                	mov    %esp,%ebp
f0100367:	57                   	push   %edi
f0100368:	56                   	push   %esi
f0100369:	53                   	push   %ebx
f010036a:	83 ec 1c             	sub    $0x1c,%esp
f010036d:	e8 4a fe ff ff       	call   f01001bc <__x86.get_pc_thunk.bx>
f0100372:	81 c3 96 0f 01 00    	add    $0x10f96,%ebx
f0100378:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	for (i = 0;
f010037b:	be 00 00 00 00       	mov    $0x0,%esi
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0100380:	bf fd 03 00 00       	mov    $0x3fd,%edi
f0100385:	b9 84 00 00 00       	mov    $0x84,%ecx
f010038a:	89 fa                	mov    %edi,%edx
f010038c:	ec                   	in     (%dx),%al
	     !(inb(COM1 + COM_LSR) & COM_LSR_TXRDY) && i < 12800;
f010038d:	a8 20                	test   $0x20,%al
f010038f:	75 13                	jne    f01003a4 <cons_putc+0x40>
f0100391:	81 fe ff 31 00 00    	cmp    $0x31ff,%esi
f0100397:	7f 0b                	jg     f01003a4 <cons_putc+0x40>
f0100399:	89 ca                	mov    %ecx,%edx
f010039b:	ec                   	in     (%dx),%al
f010039c:	ec                   	in     (%dx),%al
f010039d:	ec                   	in     (%dx),%al
f010039e:	ec                   	in     (%dx),%al
	     i++)
f010039f:	83 c6 01             	add    $0x1,%esi
f01003a2:	eb e6                	jmp    f010038a <cons_putc+0x26>
	outb(COM1 + COM_TX, c);
f01003a4:	0f b6 45 e4          	movzbl -0x1c(%ebp),%eax
f01003a8:	88 45 e3             	mov    %al,-0x1d(%ebp)
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f01003ab:	ba f8 03 00 00       	mov    $0x3f8,%edx
f01003b0:	ee                   	out    %al,(%dx)
	for (i = 0; !(inb(0x378+1) & 0x80) && i < 12800; i++)
f01003b1:	be 00 00 00 00       	mov    $0x0,%esi
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f01003b6:	bf 79 03 00 00       	mov    $0x379,%edi
f01003bb:	b9 84 00 00 00       	mov    $0x84,%ecx
f01003c0:	89 fa                	mov    %edi,%edx
f01003c2:	ec                   	in     (%dx),%al
f01003c3:	81 fe ff 31 00 00    	cmp    $0x31ff,%esi
f01003c9:	7f 0f                	jg     f01003da <cons_putc+0x76>
f01003cb:	84 c0                	test   %al,%al
f01003cd:	78 0b                	js     f01003da <cons_putc+0x76>
f01003cf:	89 ca                	mov    %ecx,%edx
f01003d1:	ec                   	in     (%dx),%al
f01003d2:	ec                   	in     (%dx),%al
f01003d3:	ec                   	in     (%dx),%al
f01003d4:	ec                   	in     (%dx),%al
f01003d5:	83 c6 01             	add    $0x1,%esi
f01003d8:	eb e6                	jmp    f01003c0 <cons_putc+0x5c>
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f01003da:	ba 78 03 00 00       	mov    $0x378,%edx
f01003df:	0f b6 45 e3          	movzbl -0x1d(%ebp),%eax
f01003e3:	ee                   	out    %al,(%dx)
f01003e4:	ba 7a 03 00 00       	mov    $0x37a,%edx
f01003e9:	b8 0d 00 00 00       	mov    $0xd,%eax
f01003ee:	ee                   	out    %al,(%dx)
f01003ef:	b8 08 00 00 00       	mov    $0x8,%eax
f01003f4:	ee                   	out    %al,(%dx)
		c |= 0x0700;
f01003f5:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f01003f8:	89 f8                	mov    %edi,%eax
f01003fa:	80 cc 07             	or     $0x7,%ah
f01003fd:	f7 c7 00 ff ff ff    	test   $0xffffff00,%edi
f0100403:	0f 45 c7             	cmovne %edi,%eax
f0100406:	89 c7                	mov    %eax,%edi
f0100408:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	switch (c & 0xff) {
f010040b:	0f b6 c0             	movzbl %al,%eax
f010040e:	89 f9                	mov    %edi,%ecx
f0100410:	80 f9 0a             	cmp    $0xa,%cl
f0100413:	0f 84 e4 00 00 00    	je     f01004fd <cons_putc+0x199>
f0100419:	83 f8 0a             	cmp    $0xa,%eax
f010041c:	7f 46                	jg     f0100464 <cons_putc+0x100>
f010041e:	83 f8 08             	cmp    $0x8,%eax
f0100421:	0f 84 a8 00 00 00    	je     f01004cf <cons_putc+0x16b>
f0100427:	83 f8 09             	cmp    $0x9,%eax
f010042a:	0f 85 da 00 00 00    	jne    f010050a <cons_putc+0x1a6>
		cons_putc(' ');
f0100430:	b8 20 00 00 00       	mov    $0x20,%eax
f0100435:	e8 2a ff ff ff       	call   f0100364 <cons_putc>
		cons_putc(' ');
f010043a:	b8 20 00 00 00       	mov    $0x20,%eax
f010043f:	e8 20 ff ff ff       	call   f0100364 <cons_putc>
		cons_putc(' ');
f0100444:	b8 20 00 00 00       	mov    $0x20,%eax
f0100449:	e8 16 ff ff ff       	call   f0100364 <cons_putc>
		cons_putc(' ');
f010044e:	b8 20 00 00 00       	mov    $0x20,%eax
f0100453:	e8 0c ff ff ff       	call   f0100364 <cons_putc>
		cons_putc(' ');
f0100458:	b8 20 00 00 00       	mov    $0x20,%eax
f010045d:	e8 02 ff ff ff       	call   f0100364 <cons_putc>
		break;
f0100462:	eb 26                	jmp    f010048a <cons_putc+0x126>
	switch (c & 0xff) {
f0100464:	83 f8 0d             	cmp    $0xd,%eax
f0100467:	0f 85 9d 00 00 00    	jne    f010050a <cons_putc+0x1a6>
		crt_pos -= (crt_pos % CRT_COLS);
f010046d:	0f b7 83 a0 1f 00 00 	movzwl 0x1fa0(%ebx),%eax
f0100474:	69 c0 cd cc 00 00    	imul   $0xcccd,%eax,%eax
f010047a:	c1 e8 16             	shr    $0x16,%eax
f010047d:	8d 04 80             	lea    (%eax,%eax,4),%eax
f0100480:	c1 e0 04             	shl    $0x4,%eax
f0100483:	66 89 83 a0 1f 00 00 	mov    %ax,0x1fa0(%ebx)
	if (crt_pos >= CRT_SIZE) {
f010048a:	66 81 bb a0 1f 00 00 	cmpw   $0x7cf,0x1fa0(%ebx)
f0100491:	cf 07 
f0100493:	0f 87 98 00 00 00    	ja     f0100531 <cons_putc+0x1cd>
	outb(addr_6845, 14);
f0100499:	8b 8b a8 1f 00 00    	mov    0x1fa8(%ebx),%ecx
f010049f:	b8 0e 00 00 00       	mov    $0xe,%eax
f01004a4:	89 ca                	mov    %ecx,%edx
f01004a6:	ee                   	out    %al,(%dx)
	outb(addr_6845 + 1, crt_pos >> 8);
f01004a7:	0f b7 9b a0 1f 00 00 	movzwl 0x1fa0(%ebx),%ebx
f01004ae:	8d 71 01             	lea    0x1(%ecx),%esi
f01004b1:	89 d8                	mov    %ebx,%eax
f01004b3:	66 c1 e8 08          	shr    $0x8,%ax
f01004b7:	89 f2                	mov    %esi,%edx
f01004b9:	ee                   	out    %al,(%dx)
f01004ba:	b8 0f 00 00 00       	mov    $0xf,%eax
f01004bf:	89 ca                	mov    %ecx,%edx
f01004c1:	ee                   	out    %al,(%dx)
f01004c2:	89 d8                	mov    %ebx,%eax
f01004c4:	89 f2                	mov    %esi,%edx
f01004c6:	ee                   	out    %al,(%dx)
	serial_putc(c);
	lpt_putc(c);
	cga_putc(c);
}
f01004c7:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01004ca:	5b                   	pop    %ebx
f01004cb:	5e                   	pop    %esi
f01004cc:	5f                   	pop    %edi
f01004cd:	5d                   	pop    %ebp
f01004ce:	c3                   	ret    
		if (crt_pos > 0) {
f01004cf:	0f b7 83 a0 1f 00 00 	movzwl 0x1fa0(%ebx),%eax
f01004d6:	66 85 c0             	test   %ax,%ax
f01004d9:	74 be                	je     f0100499 <cons_putc+0x135>
			crt_pos--;
f01004db:	83 e8 01             	sub    $0x1,%eax
f01004de:	66 89 83 a0 1f 00 00 	mov    %ax,0x1fa0(%ebx)
			crt_buf[crt_pos] = (c & ~0xff) | ' ';
f01004e5:	0f b7 c0             	movzwl %ax,%eax
f01004e8:	0f b7 55 e4          	movzwl -0x1c(%ebp),%edx
f01004ec:	b2 00                	mov    $0x0,%dl
f01004ee:	83 ca 20             	or     $0x20,%edx
f01004f1:	8b 8b a4 1f 00 00    	mov    0x1fa4(%ebx),%ecx
f01004f7:	66 89 14 41          	mov    %dx,(%ecx,%eax,2)
f01004fb:	eb 8d                	jmp    f010048a <cons_putc+0x126>
		crt_pos += CRT_COLS;
f01004fd:	66 83 83 a0 1f 00 00 	addw   $0x50,0x1fa0(%ebx)
f0100504:	50 
f0100505:	e9 63 ff ff ff       	jmp    f010046d <cons_putc+0x109>
		crt_buf[crt_pos++] = c;		/* write the character */
f010050a:	0f b7 83 a0 1f 00 00 	movzwl 0x1fa0(%ebx),%eax
f0100511:	8d 50 01             	lea    0x1(%eax),%edx
f0100514:	66 89 93 a0 1f 00 00 	mov    %dx,0x1fa0(%ebx)
f010051b:	0f b7 c0             	movzwl %ax,%eax
f010051e:	8b 93 a4 1f 00 00    	mov    0x1fa4(%ebx),%edx
f0100524:	0f b7 7d e4          	movzwl -0x1c(%ebp),%edi
f0100528:	66 89 3c 42          	mov    %di,(%edx,%eax,2)
		break;
f010052c:	e9 59 ff ff ff       	jmp    f010048a <cons_putc+0x126>
		memmove(crt_buf, crt_buf + CRT_COLS, (CRT_SIZE - CRT_COLS) * sizeof(uint16_t));
f0100531:	8b 83 a4 1f 00 00    	mov    0x1fa4(%ebx),%eax
f0100537:	83 ec 04             	sub    $0x4,%esp
f010053a:	68 00 0f 00 00       	push   $0xf00
f010053f:	8d 90 a0 00 00 00    	lea    0xa0(%eax),%edx
f0100545:	52                   	push   %edx
f0100546:	50                   	push   %eax
f0100547:	e8 d2 11 00 00       	call   f010171e <memmove>
			crt_buf[i] = 0x0700 | ' ';
f010054c:	8b 93 a4 1f 00 00    	mov    0x1fa4(%ebx),%edx
f0100552:	8d 82 00 0f 00 00    	lea    0xf00(%edx),%eax
f0100558:	81 c2 a0 0f 00 00    	add    $0xfa0,%edx
f010055e:	83 c4 10             	add    $0x10,%esp
f0100561:	66 c7 00 20 07       	movw   $0x720,(%eax)
		for (i = CRT_SIZE - CRT_COLS; i < CRT_SIZE; i++)
f0100566:	83 c0 02             	add    $0x2,%eax
f0100569:	39 d0                	cmp    %edx,%eax
f010056b:	75 f4                	jne    f0100561 <cons_putc+0x1fd>
		crt_pos -= CRT_COLS;
f010056d:	66 83 ab a0 1f 00 00 	subw   $0x50,0x1fa0(%ebx)
f0100574:	50 
f0100575:	e9 1f ff ff ff       	jmp    f0100499 <cons_putc+0x135>

f010057a <serial_intr>:
{
f010057a:	e8 cf 01 00 00       	call   f010074e <__x86.get_pc_thunk.ax>
f010057f:	05 89 0d 01 00       	add    $0x10d89,%eax
	if (serial_exists)
f0100584:	80 b8 ac 1f 00 00 00 	cmpb   $0x0,0x1fac(%eax)
f010058b:	75 01                	jne    f010058e <serial_intr+0x14>
f010058d:	c3                   	ret    
{
f010058e:	55                   	push   %ebp
f010058f:	89 e5                	mov    %esp,%ebp
f0100591:	83 ec 08             	sub    $0x8,%esp
		cons_intr(serial_proc_data);
f0100594:	8d 80 b8 ee fe ff    	lea    -0x11148(%eax),%eax
f010059a:	e8 3b fc ff ff       	call   f01001da <cons_intr>
}
f010059f:	c9                   	leave  
f01005a0:	c3                   	ret    

f01005a1 <kbd_intr>:
{
f01005a1:	55                   	push   %ebp
f01005a2:	89 e5                	mov    %esp,%ebp
f01005a4:	83 ec 08             	sub    $0x8,%esp
f01005a7:	e8 a2 01 00 00       	call   f010074e <__x86.get_pc_thunk.ax>
f01005ac:	05 5c 0d 01 00       	add    $0x10d5c,%eax
	cons_intr(kbd_proc_data);
f01005b1:	8d 80 36 ef fe ff    	lea    -0x110ca(%eax),%eax
f01005b7:	e8 1e fc ff ff       	call   f01001da <cons_intr>
}
f01005bc:	c9                   	leave  
f01005bd:	c3                   	ret    

f01005be <cons_getc>:
{
f01005be:	55                   	push   %ebp
f01005bf:	89 e5                	mov    %esp,%ebp
f01005c1:	53                   	push   %ebx
f01005c2:	83 ec 04             	sub    $0x4,%esp
f01005c5:	e8 f2 fb ff ff       	call   f01001bc <__x86.get_pc_thunk.bx>
f01005ca:	81 c3 3e 0d 01 00    	add    $0x10d3e,%ebx
	serial_intr();
f01005d0:	e8 a5 ff ff ff       	call   f010057a <serial_intr>
	kbd_intr();
f01005d5:	e8 c7 ff ff ff       	call   f01005a1 <kbd_intr>
	if (cons.rpos != cons.wpos) {
f01005da:	8b 83 98 1f 00 00    	mov    0x1f98(%ebx),%eax
	return 0;
f01005e0:	ba 00 00 00 00       	mov    $0x0,%edx
	if (cons.rpos != cons.wpos) {
f01005e5:	3b 83 9c 1f 00 00    	cmp    0x1f9c(%ebx),%eax
f01005eb:	74 1e                	je     f010060b <cons_getc+0x4d>
		c = cons.buf[cons.rpos++];
f01005ed:	8d 48 01             	lea    0x1(%eax),%ecx
f01005f0:	0f b6 94 03 98 1d 00 	movzbl 0x1d98(%ebx,%eax,1),%edx
f01005f7:	00 
			cons.rpos = 0;
f01005f8:	3d ff 01 00 00       	cmp    $0x1ff,%eax
f01005fd:	b8 00 00 00 00       	mov    $0x0,%eax
f0100602:	0f 45 c1             	cmovne %ecx,%eax
f0100605:	89 83 98 1f 00 00    	mov    %eax,0x1f98(%ebx)
}
f010060b:	89 d0                	mov    %edx,%eax
f010060d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0100610:	c9                   	leave  
f0100611:	c3                   	ret    

f0100612 <cons_init>:

// initialize the console devices
void
cons_init(void)
{
f0100612:	55                   	push   %ebp
f0100613:	89 e5                	mov    %esp,%ebp
f0100615:	57                   	push   %edi
f0100616:	56                   	push   %esi
f0100617:	53                   	push   %ebx
f0100618:	83 ec 1c             	sub    $0x1c,%esp
f010061b:	e8 9c fb ff ff       	call   f01001bc <__x86.get_pc_thunk.bx>
f0100620:	81 c3 e8 0c 01 00    	add    $0x10ce8,%ebx
	was = *cp;
f0100626:	0f b7 15 00 80 0b f0 	movzwl 0xf00b8000,%edx
	*cp = (uint16_t) 0xA55A;
f010062d:	66 c7 05 00 80 0b f0 	movw   $0xa55a,0xf00b8000
f0100634:	5a a5 
	if (*cp != 0xA55A) {
f0100636:	0f b7 05 00 80 0b f0 	movzwl 0xf00b8000,%eax
f010063d:	b9 b4 03 00 00       	mov    $0x3b4,%ecx
		cp = (uint16_t*) (KERNBASE + MONO_BUF);
f0100642:	bf 00 00 0b f0       	mov    $0xf00b0000,%edi
	if (*cp != 0xA55A) {
f0100647:	66 3d 5a a5          	cmp    $0xa55a,%ax
f010064b:	0f 84 ac 00 00 00    	je     f01006fd <cons_init+0xeb>
		addr_6845 = MONO_BASE;
f0100651:	89 8b a8 1f 00 00    	mov    %ecx,0x1fa8(%ebx)
f0100657:	b8 0e 00 00 00       	mov    $0xe,%eax
f010065c:	89 ca                	mov    %ecx,%edx
f010065e:	ee                   	out    %al,(%dx)
	pos = inb(addr_6845 + 1) << 8;
f010065f:	8d 71 01             	lea    0x1(%ecx),%esi
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0100662:	89 f2                	mov    %esi,%edx
f0100664:	ec                   	in     (%dx),%al
f0100665:	0f b6 c0             	movzbl %al,%eax
f0100668:	c1 e0 08             	shl    $0x8,%eax
f010066b:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f010066e:	b8 0f 00 00 00       	mov    $0xf,%eax
f0100673:	89 ca                	mov    %ecx,%edx
f0100675:	ee                   	out    %al,(%dx)
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0100676:	89 f2                	mov    %esi,%edx
f0100678:	ec                   	in     (%dx),%al
	crt_buf = (uint16_t*) cp;
f0100679:	89 bb a4 1f 00 00    	mov    %edi,0x1fa4(%ebx)
	pos |= inb(addr_6845 + 1);
f010067f:	0f b6 c0             	movzbl %al,%eax
f0100682:	0b 45 e4             	or     -0x1c(%ebp),%eax
	crt_pos = pos;
f0100685:	66 89 83 a0 1f 00 00 	mov    %ax,0x1fa0(%ebx)
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f010068c:	b9 00 00 00 00       	mov    $0x0,%ecx
f0100691:	89 c8                	mov    %ecx,%eax
f0100693:	ba fa 03 00 00       	mov    $0x3fa,%edx
f0100698:	ee                   	out    %al,(%dx)
f0100699:	bf fb 03 00 00       	mov    $0x3fb,%edi
f010069e:	b8 80 ff ff ff       	mov    $0xffffff80,%eax
f01006a3:	89 fa                	mov    %edi,%edx
f01006a5:	ee                   	out    %al,(%dx)
f01006a6:	b8 0c 00 00 00       	mov    $0xc,%eax
f01006ab:	ba f8 03 00 00       	mov    $0x3f8,%edx
f01006b0:	ee                   	out    %al,(%dx)
f01006b1:	be f9 03 00 00       	mov    $0x3f9,%esi
f01006b6:	89 c8                	mov    %ecx,%eax
f01006b8:	89 f2                	mov    %esi,%edx
f01006ba:	ee                   	out    %al,(%dx)
f01006bb:	b8 03 00 00 00       	mov    $0x3,%eax
f01006c0:	89 fa                	mov    %edi,%edx
f01006c2:	ee                   	out    %al,(%dx)
f01006c3:	ba fc 03 00 00       	mov    $0x3fc,%edx
f01006c8:	89 c8                	mov    %ecx,%eax
f01006ca:	ee                   	out    %al,(%dx)
f01006cb:	b8 01 00 00 00       	mov    $0x1,%eax
f01006d0:	89 f2                	mov    %esi,%edx
f01006d2:	ee                   	out    %al,(%dx)
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f01006d3:	ba fd 03 00 00       	mov    $0x3fd,%edx
f01006d8:	ec                   	in     (%dx),%al
f01006d9:	89 c1                	mov    %eax,%ecx
	serial_exists = (inb(COM1+COM_LSR) != 0xFF);
f01006db:	3c ff                	cmp    $0xff,%al
f01006dd:	0f 95 83 ac 1f 00 00 	setne  0x1fac(%ebx)
f01006e4:	ba fa 03 00 00       	mov    $0x3fa,%edx
f01006e9:	ec                   	in     (%dx),%al
f01006ea:	ba f8 03 00 00       	mov    $0x3f8,%edx
f01006ef:	ec                   	in     (%dx),%al
	cga_init();
	kbd_init();
	serial_init();

	if (!serial_exists)
f01006f0:	80 f9 ff             	cmp    $0xff,%cl
f01006f3:	74 1e                	je     f0100713 <cons_init+0x101>
		cprintf("Serial port does not exist!\n");
}
f01006f5:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01006f8:	5b                   	pop    %ebx
f01006f9:	5e                   	pop    %esi
f01006fa:	5f                   	pop    %edi
f01006fb:	5d                   	pop    %ebp
f01006fc:	c3                   	ret    
		*cp = was;
f01006fd:	66 89 15 00 80 0b f0 	mov    %dx,0xf00b8000
f0100704:	b9 d4 03 00 00       	mov    $0x3d4,%ecx
	cp = (uint16_t*) (KERNBASE + CGA_BUF);
f0100709:	bf 00 80 0b f0       	mov    $0xf00b8000,%edi
f010070e:	e9 3e ff ff ff       	jmp    f0100651 <cons_init+0x3f>
		cprintf("Serial port does not exist!\n");
f0100713:	83 ec 0c             	sub    $0xc,%esp
f0100716:	8d 83 a8 08 ff ff    	lea    -0xf758(%ebx),%eax
f010071c:	50                   	push   %eax
f010071d:	e8 b6 03 00 00       	call   f0100ad8 <cprintf>
f0100722:	83 c4 10             	add    $0x10,%esp
}
f0100725:	eb ce                	jmp    f01006f5 <cons_init+0xe3>

f0100727 <cputchar>:

// `High'-level console I/O.  Used by readline and cprintf.

void
cputchar(int c)
{
f0100727:	55                   	push   %ebp
f0100728:	89 e5                	mov    %esp,%ebp
f010072a:	83 ec 08             	sub    $0x8,%esp
	cons_putc(c);
f010072d:	8b 45 08             	mov    0x8(%ebp),%eax
f0100730:	e8 2f fc ff ff       	call   f0100364 <cons_putc>
}
f0100735:	c9                   	leave  
f0100736:	c3                   	ret    

f0100737 <getchar>:

int
getchar(void)
{
f0100737:	55                   	push   %ebp
f0100738:	89 e5                	mov    %esp,%ebp
f010073a:	83 ec 08             	sub    $0x8,%esp
	int c;

	while ((c = cons_getc()) == 0)
f010073d:	e8 7c fe ff ff       	call   f01005be <cons_getc>
f0100742:	85 c0                	test   %eax,%eax
f0100744:	74 f7                	je     f010073d <getchar+0x6>
		/* do nothing */;
	return c;
}
f0100746:	c9                   	leave  
f0100747:	c3                   	ret    

f0100748 <iscons>:
int
iscons(int fdnum)
{
	// used by readline
	return 1;
}
f0100748:	b8 01 00 00 00       	mov    $0x1,%eax
f010074d:	c3                   	ret    

f010074e <__x86.get_pc_thunk.ax>:
f010074e:	8b 04 24             	mov    (%esp),%eax
f0100751:	c3                   	ret    

f0100752 <__x86.get_pc_thunk.si>:
f0100752:	8b 34 24             	mov    (%esp),%esi
f0100755:	c3                   	ret    

f0100756 <mon_help>:

/***** Implementations of basic kernel monitor commands *****/

int
mon_help(int argc, char **argv, struct Trapframe *tf)
{
f0100756:	55                   	push   %ebp
f0100757:	89 e5                	mov    %esp,%ebp
f0100759:	56                   	push   %esi
f010075a:	53                   	push   %ebx
f010075b:	e8 5c fa ff ff       	call   f01001bc <__x86.get_pc_thunk.bx>
f0100760:	81 c3 a8 0b 01 00    	add    $0x10ba8,%ebx
	int i;

	for (i = 0; i < ARRAY_SIZE(commands); i++)
		cprintf("%s - %s\n", commands[i].name, commands[i].desc);
f0100766:	83 ec 04             	sub    $0x4,%esp
f0100769:	8d 83 d8 0a ff ff    	lea    -0xf528(%ebx),%eax
f010076f:	50                   	push   %eax
f0100770:	8d 83 f6 0a ff ff    	lea    -0xf50a(%ebx),%eax
f0100776:	50                   	push   %eax
f0100777:	8d b3 fb 0a ff ff    	lea    -0xf505(%ebx),%esi
f010077d:	56                   	push   %esi
f010077e:	e8 55 03 00 00       	call   f0100ad8 <cprintf>
f0100783:	83 c4 0c             	add    $0xc,%esp
f0100786:	8d 83 a8 0b ff ff    	lea    -0xf458(%ebx),%eax
f010078c:	50                   	push   %eax
f010078d:	8d 83 04 0b ff ff    	lea    -0xf4fc(%ebx),%eax
f0100793:	50                   	push   %eax
f0100794:	56                   	push   %esi
f0100795:	e8 3e 03 00 00       	call   f0100ad8 <cprintf>
f010079a:	83 c4 0c             	add    $0xc,%esp
f010079d:	8d 83 0d 0b ff ff    	lea    -0xf4f3(%ebx),%eax
f01007a3:	50                   	push   %eax
f01007a4:	8d 83 1b 0b ff ff    	lea    -0xf4e5(%ebx),%eax
f01007aa:	50                   	push   %eax
f01007ab:	56                   	push   %esi
f01007ac:	e8 27 03 00 00       	call   f0100ad8 <cprintf>
	return 0;
}
f01007b1:	b8 00 00 00 00       	mov    $0x0,%eax
f01007b6:	8d 65 f8             	lea    -0x8(%ebp),%esp
f01007b9:	5b                   	pop    %ebx
f01007ba:	5e                   	pop    %esi
f01007bb:	5d                   	pop    %ebp
f01007bc:	c3                   	ret    

f01007bd <mon_kerninfo>:

int
mon_kerninfo(int argc, char **argv, struct Trapframe *tf)
{
f01007bd:	55                   	push   %ebp
f01007be:	89 e5                	mov    %esp,%ebp
f01007c0:	57                   	push   %edi
f01007c1:	56                   	push   %esi
f01007c2:	53                   	push   %ebx
f01007c3:	83 ec 18             	sub    $0x18,%esp
f01007c6:	e8 f1 f9 ff ff       	call   f01001bc <__x86.get_pc_thunk.bx>
f01007cb:	81 c3 3d 0b 01 00    	add    $0x10b3d,%ebx
	extern char _start[], entry[], etext[], edata[], end[];

	cprintf("Special kernel symbols:\n");
f01007d1:	8d 83 25 0b ff ff    	lea    -0xf4db(%ebx),%eax
f01007d7:	50                   	push   %eax
f01007d8:	e8 fb 02 00 00       	call   f0100ad8 <cprintf>
	cprintf("  _start                  %08x (phys)\n", _start);
f01007dd:	83 c4 08             	add    $0x8,%esp
f01007e0:	ff b3 f8 ff ff ff    	push   -0x8(%ebx)
f01007e6:	8d 83 d0 0b ff ff    	lea    -0xf430(%ebx),%eax
f01007ec:	50                   	push   %eax
f01007ed:	e8 e6 02 00 00       	call   f0100ad8 <cprintf>
	cprintf("  entry  %08x (virt)  %08x (phys)\n", entry, entry - KERNBASE);
f01007f2:	83 c4 0c             	add    $0xc,%esp
f01007f5:	c7 c7 0c 00 10 f0    	mov    $0xf010000c,%edi
f01007fb:	8d 87 00 00 00 10    	lea    0x10000000(%edi),%eax
f0100801:	50                   	push   %eax
f0100802:	57                   	push   %edi
f0100803:	8d 83 f8 0b ff ff    	lea    -0xf408(%ebx),%eax
f0100809:	50                   	push   %eax
f010080a:	e8 c9 02 00 00       	call   f0100ad8 <cprintf>
	cprintf("  etext  %08x (virt)  %08x (phys)\n", etext, etext - KERNBASE);
f010080f:	83 c4 0c             	add    $0xc,%esp
f0100812:	c7 c0 01 1b 10 f0    	mov    $0xf0101b01,%eax
f0100818:	8d 90 00 00 00 10    	lea    0x10000000(%eax),%edx
f010081e:	52                   	push   %edx
f010081f:	50                   	push   %eax
f0100820:	8d 83 1c 0c ff ff    	lea    -0xf3e4(%ebx),%eax
f0100826:	50                   	push   %eax
f0100827:	e8 ac 02 00 00       	call   f0100ad8 <cprintf>
	cprintf("  edata  %08x (virt)  %08x (phys)\n", edata, edata - KERNBASE);
f010082c:	83 c4 0c             	add    $0xc,%esp
f010082f:	c7 c0 60 30 11 f0    	mov    $0xf0113060,%eax
f0100835:	8d 90 00 00 00 10    	lea    0x10000000(%eax),%edx
f010083b:	52                   	push   %edx
f010083c:	50                   	push   %eax
f010083d:	8d 83 40 0c ff ff    	lea    -0xf3c0(%ebx),%eax
f0100843:	50                   	push   %eax
f0100844:	e8 8f 02 00 00       	call   f0100ad8 <cprintf>
	cprintf("  end    %08x (virt)  %08x (phys)\n", end, end - KERNBASE);
f0100849:	83 c4 0c             	add    $0xc,%esp
f010084c:	c7 c6 c0 36 11 f0    	mov    $0xf01136c0,%esi
f0100852:	8d 86 00 00 00 10    	lea    0x10000000(%esi),%eax
f0100858:	50                   	push   %eax
f0100859:	56                   	push   %esi
f010085a:	8d 83 64 0c ff ff    	lea    -0xf39c(%ebx),%eax
f0100860:	50                   	push   %eax
f0100861:	e8 72 02 00 00       	call   f0100ad8 <cprintf>
	cprintf("Kernel executable memory footprint: %dKB\n",
f0100866:	83 c4 08             	add    $0x8,%esp
		ROUNDUP(end - entry, 1024) / 1024);
f0100869:	29 fe                	sub    %edi,%esi
f010086b:	81 c6 ff 03 00 00    	add    $0x3ff,%esi
	cprintf("Kernel executable memory footprint: %dKB\n",
f0100871:	c1 fe 0a             	sar    $0xa,%esi
f0100874:	56                   	push   %esi
f0100875:	8d 83 88 0c ff ff    	lea    -0xf378(%ebx),%eax
f010087b:	50                   	push   %eax
f010087c:	e8 57 02 00 00       	call   f0100ad8 <cprintf>
	return 0;
}
f0100881:	b8 00 00 00 00       	mov    $0x0,%eax
f0100886:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0100889:	5b                   	pop    %ebx
f010088a:	5e                   	pop    %esi
f010088b:	5f                   	pop    %edi
f010088c:	5d                   	pop    %ebp
f010088d:	c3                   	ret    

f010088e <mon_backtrace>:

int
mon_backtrace(int argc, char **argv, struct Trapframe *tf)
{
f010088e:	55                   	push   %ebp
f010088f:	89 e5                	mov    %esp,%ebp
f0100891:	57                   	push   %edi
f0100892:	56                   	push   %esi
f0100893:	53                   	push   %ebx
f0100894:	83 ec 48             	sub    $0x48,%esp
f0100897:	e8 20 f9 ff ff       	call   f01001bc <__x86.get_pc_thunk.bx>
f010089c:	81 c3 6c 0a 01 00    	add    $0x10a6c,%ebx
	cprintf ("Stack backtrace:\n");
f01008a2:	8d 83 3e 0b ff ff    	lea    -0xf4c2(%ebx),%eax
f01008a8:	50                   	push   %eax
f01008a9:	e8 2a 02 00 00       	call   f0100ad8 <cprintf>

static inline uint32_t
read_ebp(void)
{
	uint32_t ebp;
	asm volatile("movl %%ebp,%0" : "=r" (ebp));
f01008ae:	89 ee                	mov    %ebp,%esi
f01008b0:	83 c4 10             	add    $0x10,%esp
        	args[0] = ((uint32_t *)ebp)[2];
        	args[1] = ((uint32_t *)ebp)[3];
        	args[2] = ((uint32_t *)ebp)[4];
        	args[3] = ((uint32_t *)ebp)[5];
        	args[4] = ((uint32_t *)ebp)[6];
        	cprintf("  ebp %08x  eip %08x  args %08x %08x %08x %08x %08x\n",
f01008b3:	8d 83 b4 0c ff ff    	lea    -0xf34c(%ebx),%eax
f01008b9:	89 45 c4             	mov    %eax,-0x3c(%ebp)
                	ebp, eip, args[0], args[1], args[2], args[3], args[4]);
                
        	debuginfo_eip (eip, &dbinfo);
        	cprintf("         %s:%d: %.*s+%d\n",
f01008bc:	8d 83 50 0b ff ff    	lea    -0xf4b0(%ebx),%eax
f01008c2:	89 45 c0             	mov    %eax,-0x40(%ebp)
        	eip = ((uint32_t *)ebp)[1];
f01008c5:	8b 7e 04             	mov    0x4(%esi),%edi
        	cprintf("  ebp %08x  eip %08x  args %08x %08x %08x %08x %08x\n",
f01008c8:	ff 76 18             	push   0x18(%esi)
f01008cb:	ff 76 14             	push   0x14(%esi)
f01008ce:	ff 76 10             	push   0x10(%esi)
f01008d1:	ff 76 0c             	push   0xc(%esi)
f01008d4:	ff 76 08             	push   0x8(%esi)
f01008d7:	57                   	push   %edi
f01008d8:	56                   	push   %esi
f01008d9:	ff 75 c4             	push   -0x3c(%ebp)
f01008dc:	e8 f7 01 00 00       	call   f0100ad8 <cprintf>
        	debuginfo_eip (eip, &dbinfo);
f01008e1:	83 c4 18             	add    $0x18,%esp
f01008e4:	8d 45 d0             	lea    -0x30(%ebp),%eax
f01008e7:	50                   	push   %eax
f01008e8:	57                   	push   %edi
f01008e9:	e8 f3 02 00 00       	call   f0100be1 <debuginfo_eip>
        	cprintf("         %s:%d: %.*s+%d\n",
f01008ee:	83 c4 08             	add    $0x8,%esp
f01008f1:	2b 7d e0             	sub    -0x20(%ebp),%edi
f01008f4:	57                   	push   %edi
f01008f5:	ff 75 d8             	push   -0x28(%ebp)
f01008f8:	ff 75 dc             	push   -0x24(%ebp)
f01008fb:	ff 75 d4             	push   -0x2c(%ebp)
f01008fe:	ff 75 d0             	push   -0x30(%ebp)
f0100901:	ff 75 c0             	push   -0x40(%ebp)
f0100904:	e8 cf 01 00 00       	call   f0100ad8 <cprintf>
                	dbinfo.eip_file, dbinfo.eip_line, dbinfo.eip_fn_namelen,
                	dbinfo.eip_fn_name, eip - dbinfo.eip_fn_addr);
                
        	ebp = *(uint32_t *)ebp;
f0100909:	8b 36                	mov    (%esi),%esi
    	} while (ebp);
f010090b:	83 c4 20             	add    $0x20,%esp
f010090e:	85 f6                	test   %esi,%esi
f0100910:	75 b3                	jne    f01008c5 <mon_backtrace+0x37>

	return 0;
}
f0100912:	b8 00 00 00 00       	mov    $0x0,%eax
f0100917:	8d 65 f4             	lea    -0xc(%ebp),%esp
f010091a:	5b                   	pop    %ebx
f010091b:	5e                   	pop    %esi
f010091c:	5f                   	pop    %edi
f010091d:	5d                   	pop    %ebp
f010091e:	c3                   	ret    

f010091f <monitor>:
	return 0;
}

void
monitor(struct Trapframe *tf)
{
f010091f:	55                   	push   %ebp
f0100920:	89 e5                	mov    %esp,%ebp
f0100922:	57                   	push   %edi
f0100923:	56                   	push   %esi
f0100924:	53                   	push   %ebx
f0100925:	83 ec 68             	sub    $0x68,%esp
f0100928:	e8 8f f8 ff ff       	call   f01001bc <__x86.get_pc_thunk.bx>
f010092d:	81 c3 db 09 01 00    	add    $0x109db,%ebx
	char *buf;

	cprintf("Welcome to the JOS kernel monitor!\n");
f0100933:	8d 83 ec 0c ff ff    	lea    -0xf314(%ebx),%eax
f0100939:	50                   	push   %eax
f010093a:	e8 99 01 00 00       	call   f0100ad8 <cprintf>
	cprintf("Type 'help' for a list of commands.\n");
f010093f:	8d 83 10 0d ff ff    	lea    -0xf2f0(%ebx),%eax
f0100945:	89 04 24             	mov    %eax,(%esp)
f0100948:	e8 8b 01 00 00       	call   f0100ad8 <cprintf>
f010094d:	83 c4 10             	add    $0x10,%esp
		while (*buf && strchr(WHITESPACE, *buf))
f0100950:	8d bb 6d 0b ff ff    	lea    -0xf493(%ebx),%edi
f0100956:	eb 4a                	jmp    f01009a2 <monitor+0x83>
f0100958:	83 ec 08             	sub    $0x8,%esp
f010095b:	0f be c0             	movsbl %al,%eax
f010095e:	50                   	push   %eax
f010095f:	57                   	push   %edi
f0100960:	e8 34 0d 00 00       	call   f0101699 <strchr>
f0100965:	83 c4 10             	add    $0x10,%esp
f0100968:	85 c0                	test   %eax,%eax
f010096a:	74 08                	je     f0100974 <monitor+0x55>
			*buf++ = 0;
f010096c:	c6 06 00             	movb   $0x0,(%esi)
f010096f:	8d 76 01             	lea    0x1(%esi),%esi
f0100972:	eb 76                	jmp    f01009ea <monitor+0xcb>
		if (*buf == 0)
f0100974:	80 3e 00             	cmpb   $0x0,(%esi)
f0100977:	74 7c                	je     f01009f5 <monitor+0xd6>
		if (argc == MAXARGS-1) {
f0100979:	83 7d a4 0f          	cmpl   $0xf,-0x5c(%ebp)
f010097d:	74 0f                	je     f010098e <monitor+0x6f>
		argv[argc++] = buf;
f010097f:	8b 45 a4             	mov    -0x5c(%ebp),%eax
f0100982:	8d 48 01             	lea    0x1(%eax),%ecx
f0100985:	89 4d a4             	mov    %ecx,-0x5c(%ebp)
f0100988:	89 74 85 a8          	mov    %esi,-0x58(%ebp,%eax,4)
		while (*buf && !strchr(WHITESPACE, *buf))
f010098c:	eb 41                	jmp    f01009cf <monitor+0xb0>
			cprintf("Too many arguments (max %d)\n", MAXARGS);
f010098e:	83 ec 08             	sub    $0x8,%esp
f0100991:	6a 10                	push   $0x10
f0100993:	8d 83 72 0b ff ff    	lea    -0xf48e(%ebx),%eax
f0100999:	50                   	push   %eax
f010099a:	e8 39 01 00 00       	call   f0100ad8 <cprintf>
			return 0;
f010099f:	83 c4 10             	add    $0x10,%esp


	while (1) {
		buf = readline("K> ");
f01009a2:	8d 83 69 0b ff ff    	lea    -0xf497(%ebx),%eax
f01009a8:	89 c6                	mov    %eax,%esi
f01009aa:	83 ec 0c             	sub    $0xc,%esp
f01009ad:	56                   	push   %esi
f01009ae:	e8 95 0a 00 00       	call   f0101448 <readline>
		if (buf != NULL)
f01009b3:	83 c4 10             	add    $0x10,%esp
f01009b6:	85 c0                	test   %eax,%eax
f01009b8:	74 f0                	je     f01009aa <monitor+0x8b>
	argv[argc] = 0;
f01009ba:	89 c6                	mov    %eax,%esi
f01009bc:	c7 45 a8 00 00 00 00 	movl   $0x0,-0x58(%ebp)
	argc = 0;
f01009c3:	c7 45 a4 00 00 00 00 	movl   $0x0,-0x5c(%ebp)
f01009ca:	eb 1e                	jmp    f01009ea <monitor+0xcb>
			buf++;
f01009cc:	83 c6 01             	add    $0x1,%esi
		while (*buf && !strchr(WHITESPACE, *buf))
f01009cf:	0f b6 06             	movzbl (%esi),%eax
f01009d2:	84 c0                	test   %al,%al
f01009d4:	74 14                	je     f01009ea <monitor+0xcb>
f01009d6:	83 ec 08             	sub    $0x8,%esp
f01009d9:	0f be c0             	movsbl %al,%eax
f01009dc:	50                   	push   %eax
f01009dd:	57                   	push   %edi
f01009de:	e8 b6 0c 00 00       	call   f0101699 <strchr>
f01009e3:	83 c4 10             	add    $0x10,%esp
f01009e6:	85 c0                	test   %eax,%eax
f01009e8:	74 e2                	je     f01009cc <monitor+0xad>
		while (*buf && strchr(WHITESPACE, *buf))
f01009ea:	0f b6 06             	movzbl (%esi),%eax
f01009ed:	84 c0                	test   %al,%al
f01009ef:	0f 85 63 ff ff ff    	jne    f0100958 <monitor+0x39>
	argv[argc] = 0;
f01009f5:	8b 45 a4             	mov    -0x5c(%ebp),%eax
f01009f8:	c7 44 85 a8 00 00 00 	movl   $0x0,-0x58(%ebp,%eax,4)
f01009ff:	00 
	if (argc == 0)
f0100a00:	85 c0                	test   %eax,%eax
f0100a02:	74 9e                	je     f01009a2 <monitor+0x83>
f0100a04:	8d b3 18 1d 00 00    	lea    0x1d18(%ebx),%esi
	for (i = 0; i < ARRAY_SIZE(commands); i++) {
f0100a0a:	b8 00 00 00 00       	mov    $0x0,%eax
f0100a0f:	89 7d a0             	mov    %edi,-0x60(%ebp)
f0100a12:	89 c7                	mov    %eax,%edi
		if (strcmp(argv[0], commands[i].name) == 0)
f0100a14:	83 ec 08             	sub    $0x8,%esp
f0100a17:	ff 36                	push   (%esi)
f0100a19:	ff 75 a8             	push   -0x58(%ebp)
f0100a1c:	e8 18 0c 00 00       	call   f0101639 <strcmp>
f0100a21:	83 c4 10             	add    $0x10,%esp
f0100a24:	85 c0                	test   %eax,%eax
f0100a26:	74 28                	je     f0100a50 <monitor+0x131>
	for (i = 0; i < ARRAY_SIZE(commands); i++) {
f0100a28:	83 c7 01             	add    $0x1,%edi
f0100a2b:	83 c6 0c             	add    $0xc,%esi
f0100a2e:	83 ff 03             	cmp    $0x3,%edi
f0100a31:	75 e1                	jne    f0100a14 <monitor+0xf5>
	cprintf("Unknown command '%s'\n", argv[0]);
f0100a33:	8b 7d a0             	mov    -0x60(%ebp),%edi
f0100a36:	83 ec 08             	sub    $0x8,%esp
f0100a39:	ff 75 a8             	push   -0x58(%ebp)
f0100a3c:	8d 83 8f 0b ff ff    	lea    -0xf471(%ebx),%eax
f0100a42:	50                   	push   %eax
f0100a43:	e8 90 00 00 00       	call   f0100ad8 <cprintf>
	return 0;
f0100a48:	83 c4 10             	add    $0x10,%esp
f0100a4b:	e9 52 ff ff ff       	jmp    f01009a2 <monitor+0x83>
			return commands[i].func(argc, argv, tf);
f0100a50:	89 f8                	mov    %edi,%eax
f0100a52:	8b 7d a0             	mov    -0x60(%ebp),%edi
f0100a55:	83 ec 04             	sub    $0x4,%esp
f0100a58:	8d 04 40             	lea    (%eax,%eax,2),%eax
f0100a5b:	ff 75 08             	push   0x8(%ebp)
f0100a5e:	8d 55 a8             	lea    -0x58(%ebp),%edx
f0100a61:	52                   	push   %edx
f0100a62:	ff 75 a4             	push   -0x5c(%ebp)
f0100a65:	ff 94 83 20 1d 00 00 	call   *0x1d20(%ebx,%eax,4)
			if (runcmd(buf, tf) < 0)
f0100a6c:	83 c4 10             	add    $0x10,%esp
f0100a6f:	85 c0                	test   %eax,%eax
f0100a71:	0f 89 2b ff ff ff    	jns    f01009a2 <monitor+0x83>
				break;
	}
}
f0100a77:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0100a7a:	5b                   	pop    %ebx
f0100a7b:	5e                   	pop    %esi
f0100a7c:	5f                   	pop    %edi
f0100a7d:	5d                   	pop    %ebp
f0100a7e:	c3                   	ret    

f0100a7f <putch>:
#include <inc/stdarg.h>


static void
putch(int ch, int *cnt)
{
f0100a7f:	55                   	push   %ebp
f0100a80:	89 e5                	mov    %esp,%ebp
f0100a82:	53                   	push   %ebx
f0100a83:	83 ec 10             	sub    $0x10,%esp
f0100a86:	e8 31 f7 ff ff       	call   f01001bc <__x86.get_pc_thunk.bx>
f0100a8b:	81 c3 7d 08 01 00    	add    $0x1087d,%ebx
	cputchar(ch);
f0100a91:	ff 75 08             	push   0x8(%ebp)
f0100a94:	e8 8e fc ff ff       	call   f0100727 <cputchar>
	*cnt++;
}
f0100a99:	83 c4 10             	add    $0x10,%esp
f0100a9c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0100a9f:	c9                   	leave  
f0100aa0:	c3                   	ret    

f0100aa1 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
f0100aa1:	55                   	push   %ebp
f0100aa2:	89 e5                	mov    %esp,%ebp
f0100aa4:	53                   	push   %ebx
f0100aa5:	83 ec 14             	sub    $0x14,%esp
f0100aa8:	e8 0f f7 ff ff       	call   f01001bc <__x86.get_pc_thunk.bx>
f0100aad:	81 c3 5b 08 01 00    	add    $0x1085b,%ebx
	int cnt = 0;
f0100ab3:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	vprintfmt((void*)putch, &cnt, fmt, ap);
f0100aba:	ff 75 0c             	push   0xc(%ebp)
f0100abd:	ff 75 08             	push   0x8(%ebp)
f0100ac0:	8d 45 f4             	lea    -0xc(%ebp),%eax
f0100ac3:	50                   	push   %eax
f0100ac4:	8d 83 77 f7 fe ff    	lea    -0x10889(%ebx),%eax
f0100aca:	50                   	push   %eax
f0100acb:	e8 57 04 00 00       	call   f0100f27 <vprintfmt>
	return cnt;
}
f0100ad0:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0100ad3:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0100ad6:	c9                   	leave  
f0100ad7:	c3                   	ret    

f0100ad8 <cprintf>:

int
cprintf(const char *fmt, ...)
{
f0100ad8:	55                   	push   %ebp
f0100ad9:	89 e5                	mov    %esp,%ebp
f0100adb:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
f0100ade:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
f0100ae1:	50                   	push   %eax
f0100ae2:	ff 75 08             	push   0x8(%ebp)
f0100ae5:	e8 b7 ff ff ff       	call   f0100aa1 <vcprintf>
	va_end(ap);

	return cnt;
}
f0100aea:	c9                   	leave  
f0100aeb:	c3                   	ret    

f0100aec <stab_binsearch>:
//	will exit setting left = 118, right = 554.
//
static void
stab_binsearch(const struct Stab *stabs, int *region_left, int *region_right,
	       int type, uintptr_t addr)
{
f0100aec:	55                   	push   %ebp
f0100aed:	89 e5                	mov    %esp,%ebp
f0100aef:	57                   	push   %edi
f0100af0:	56                   	push   %esi
f0100af1:	53                   	push   %ebx
f0100af2:	83 ec 14             	sub    $0x14,%esp
f0100af5:	89 45 ec             	mov    %eax,-0x14(%ebp)
f0100af8:	89 55 e4             	mov    %edx,-0x1c(%ebp)
f0100afb:	89 4d e0             	mov    %ecx,-0x20(%ebp)
f0100afe:	8b 75 08             	mov    0x8(%ebp),%esi
	int l = *region_left, r = *region_right, any_matches = 0;
f0100b01:	8b 1a                	mov    (%edx),%ebx
f0100b03:	8b 01                	mov    (%ecx),%eax
f0100b05:	89 45 f0             	mov    %eax,-0x10(%ebp)
f0100b08:	c7 45 e8 00 00 00 00 	movl   $0x0,-0x18(%ebp)

	while (l <= r) {
f0100b0f:	eb 2f                	jmp    f0100b40 <stab_binsearch+0x54>
		int true_m = (l + r) / 2, m = true_m;

		// search for earliest stab with right type
		while (m >= l && stabs[m].n_type != type)
			m--;
f0100b11:	83 e8 01             	sub    $0x1,%eax
		while (m >= l && stabs[m].n_type != type)
f0100b14:	39 c3                	cmp    %eax,%ebx
f0100b16:	7f 4e                	jg     f0100b66 <stab_binsearch+0x7a>
f0100b18:	0f b6 0a             	movzbl (%edx),%ecx
f0100b1b:	83 ea 0c             	sub    $0xc,%edx
f0100b1e:	39 f1                	cmp    %esi,%ecx
f0100b20:	75 ef                	jne    f0100b11 <stab_binsearch+0x25>
			continue;
		}

		// actual binary search
		any_matches = 1;
		if (stabs[m].n_value < addr) {
f0100b22:	8d 14 40             	lea    (%eax,%eax,2),%edx
f0100b25:	8b 4d ec             	mov    -0x14(%ebp),%ecx
f0100b28:	8b 54 91 08          	mov    0x8(%ecx,%edx,4),%edx
f0100b2c:	3b 55 0c             	cmp    0xc(%ebp),%edx
f0100b2f:	73 3a                	jae    f0100b6b <stab_binsearch+0x7f>
			*region_left = m;
f0100b31:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
f0100b34:	89 03                	mov    %eax,(%ebx)
			l = true_m + 1;
f0100b36:	8d 5f 01             	lea    0x1(%edi),%ebx
		any_matches = 1;
f0100b39:	c7 45 e8 01 00 00 00 	movl   $0x1,-0x18(%ebp)
	while (l <= r) {
f0100b40:	3b 5d f0             	cmp    -0x10(%ebp),%ebx
f0100b43:	7f 53                	jg     f0100b98 <stab_binsearch+0xac>
		int true_m = (l + r) / 2, m = true_m;
f0100b45:	8b 45 f0             	mov    -0x10(%ebp),%eax
f0100b48:	8d 14 03             	lea    (%ebx,%eax,1),%edx
f0100b4b:	89 d0                	mov    %edx,%eax
f0100b4d:	c1 e8 1f             	shr    $0x1f,%eax
f0100b50:	01 d0                	add    %edx,%eax
f0100b52:	89 c7                	mov    %eax,%edi
f0100b54:	d1 ff                	sar    %edi
f0100b56:	83 e0 fe             	and    $0xfffffffe,%eax
f0100b59:	01 f8                	add    %edi,%eax
f0100b5b:	8b 4d ec             	mov    -0x14(%ebp),%ecx
f0100b5e:	8d 54 81 04          	lea    0x4(%ecx,%eax,4),%edx
f0100b62:	89 f8                	mov    %edi,%eax
		while (m >= l && stabs[m].n_type != type)
f0100b64:	eb ae                	jmp    f0100b14 <stab_binsearch+0x28>
			l = true_m + 1;
f0100b66:	8d 5f 01             	lea    0x1(%edi),%ebx
			continue;
f0100b69:	eb d5                	jmp    f0100b40 <stab_binsearch+0x54>
		} else if (stabs[m].n_value > addr) {
f0100b6b:	3b 55 0c             	cmp    0xc(%ebp),%edx
f0100b6e:	76 14                	jbe    f0100b84 <stab_binsearch+0x98>
			*region_right = m - 1;
f0100b70:	83 e8 01             	sub    $0x1,%eax
f0100b73:	89 45 f0             	mov    %eax,-0x10(%ebp)
f0100b76:	8b 7d e0             	mov    -0x20(%ebp),%edi
f0100b79:	89 07                	mov    %eax,(%edi)
		any_matches = 1;
f0100b7b:	c7 45 e8 01 00 00 00 	movl   $0x1,-0x18(%ebp)
f0100b82:	eb bc                	jmp    f0100b40 <stab_binsearch+0x54>
			r = m - 1;
		} else {
			// exact match for 'addr', but continue loop to find
			// *region_right
			*region_left = m;
f0100b84:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0100b87:	89 07                	mov    %eax,(%edi)
			l = m;
			addr++;
f0100b89:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
f0100b8d:	89 c3                	mov    %eax,%ebx
		any_matches = 1;
f0100b8f:	c7 45 e8 01 00 00 00 	movl   $0x1,-0x18(%ebp)
f0100b96:	eb a8                	jmp    f0100b40 <stab_binsearch+0x54>
		}
	}

	if (!any_matches)
f0100b98:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
f0100b9c:	75 15                	jne    f0100bb3 <stab_binsearch+0xc7>
		*region_right = *region_left - 1;
f0100b9e:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0100ba1:	8b 00                	mov    (%eax),%eax
f0100ba3:	83 e8 01             	sub    $0x1,%eax
f0100ba6:	8b 7d e0             	mov    -0x20(%ebp),%edi
f0100ba9:	89 07                	mov    %eax,(%edi)
		     l > *region_left && stabs[l].n_type != type;
		     l--)
			/* do nothing */;
		*region_left = l;
	}
}
f0100bab:	83 c4 14             	add    $0x14,%esp
f0100bae:	5b                   	pop    %ebx
f0100baf:	5e                   	pop    %esi
f0100bb0:	5f                   	pop    %edi
f0100bb1:	5d                   	pop    %ebp
f0100bb2:	c3                   	ret    
		for (l = *region_right;
f0100bb3:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0100bb6:	8b 00                	mov    (%eax),%eax
		     l > *region_left && stabs[l].n_type != type;
f0100bb8:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0100bbb:	8b 0f                	mov    (%edi),%ecx
f0100bbd:	8d 14 40             	lea    (%eax,%eax,2),%edx
f0100bc0:	8b 7d ec             	mov    -0x14(%ebp),%edi
f0100bc3:	8d 54 97 04          	lea    0x4(%edi,%edx,4),%edx
f0100bc7:	39 c1                	cmp    %eax,%ecx
f0100bc9:	7d 0f                	jge    f0100bda <stab_binsearch+0xee>
f0100bcb:	0f b6 1a             	movzbl (%edx),%ebx
f0100bce:	83 ea 0c             	sub    $0xc,%edx
f0100bd1:	39 f3                	cmp    %esi,%ebx
f0100bd3:	74 05                	je     f0100bda <stab_binsearch+0xee>
		     l--)
f0100bd5:	83 e8 01             	sub    $0x1,%eax
f0100bd8:	eb ed                	jmp    f0100bc7 <stab_binsearch+0xdb>
		*region_left = l;
f0100bda:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0100bdd:	89 07                	mov    %eax,(%edi)
}
f0100bdf:	eb ca                	jmp    f0100bab <stab_binsearch+0xbf>

f0100be1 <debuginfo_eip>:
//	negative if not.  But even if it returns negative it has stored some
//	information into '*info'.
//
int
debuginfo_eip(uintptr_t addr, struct Eipdebuginfo *info)
{
f0100be1:	55                   	push   %ebp
f0100be2:	89 e5                	mov    %esp,%ebp
f0100be4:	57                   	push   %edi
f0100be5:	56                   	push   %esi
f0100be6:	53                   	push   %ebx
f0100be7:	83 ec 3c             	sub    $0x3c,%esp
f0100bea:	e8 cd f5 ff ff       	call   f01001bc <__x86.get_pc_thunk.bx>
f0100bef:	81 c3 19 07 01 00    	add    $0x10719,%ebx
f0100bf5:	8b 7d 08             	mov    0x8(%ebp),%edi
f0100bf8:	8b 75 0c             	mov    0xc(%ebp),%esi
	const struct Stab *stabs, *stab_end;
	const char *stabstr, *stabstr_end;
	int lfile, rfile, lfun, rfun, lline, rline;

	// Initialize *info
	info->eip_file = "<unknown>";
f0100bfb:	8d 83 35 0d ff ff    	lea    -0xf2cb(%ebx),%eax
f0100c01:	89 06                	mov    %eax,(%esi)
	info->eip_line = 0;
f0100c03:	c7 46 04 00 00 00 00 	movl   $0x0,0x4(%esi)
	info->eip_fn_name = "<unknown>";
f0100c0a:	89 46 08             	mov    %eax,0x8(%esi)
	info->eip_fn_namelen = 9;
f0100c0d:	c7 46 0c 09 00 00 00 	movl   $0x9,0xc(%esi)
	info->eip_fn_addr = addr;
f0100c14:	89 7e 10             	mov    %edi,0x10(%esi)
	info->eip_fn_narg = 0;
f0100c17:	c7 46 14 00 00 00 00 	movl   $0x0,0x14(%esi)

	// Find the relevant set of stabs
	if (addr >= ULIM) {
f0100c1e:	81 ff ff ff 7f ef    	cmp    $0xef7fffff,%edi
f0100c24:	0f 86 3c 01 00 00    	jbe    f0100d66 <debuginfo_eip+0x185>
		// Can't search for user-level addresses yet!
  	        panic("User address");
	}

	// String table validity checks
	if (stabstr_end <= stabstr || stabstr_end[-1] != 0)
f0100c2a:	c7 c0 35 5b 10 f0    	mov    $0xf0105b35,%eax
f0100c30:	39 83 fc ff ff ff    	cmp    %eax,-0x4(%ebx)
f0100c36:	0f 86 c3 01 00 00    	jbe    f0100dff <debuginfo_eip+0x21e>
f0100c3c:	c7 c0 6d 71 10 f0    	mov    $0xf010716d,%eax
f0100c42:	80 78 ff 00          	cmpb   $0x0,-0x1(%eax)
f0100c46:	0f 85 ba 01 00 00    	jne    f0100e06 <debuginfo_eip+0x225>
	// 'eip'.  First, we find the basic source file containing 'eip'.
	// Then, we look in that source file for the function.  Then we look
	// for the line number.

	// Search the entire set of stabs for the source file (type N_SO).
	lfile = 0;
f0100c4c:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
	rfile = (stab_end - stabs) - 1;
f0100c53:	c7 c0 58 22 10 f0    	mov    $0xf0102258,%eax
f0100c59:	c7 c2 34 5b 10 f0    	mov    $0xf0105b34,%edx
f0100c5f:	29 c2                	sub    %eax,%edx
f0100c61:	c1 fa 02             	sar    $0x2,%edx
f0100c64:	69 d2 ab aa aa aa    	imul   $0xaaaaaaab,%edx,%edx
f0100c6a:	83 ea 01             	sub    $0x1,%edx
f0100c6d:	89 55 e0             	mov    %edx,-0x20(%ebp)
	stab_binsearch(stabs, &lfile, &rfile, N_SO, addr);
f0100c70:	8d 4d e0             	lea    -0x20(%ebp),%ecx
f0100c73:	8d 55 e4             	lea    -0x1c(%ebp),%edx
f0100c76:	83 ec 08             	sub    $0x8,%esp
f0100c79:	57                   	push   %edi
f0100c7a:	6a 64                	push   $0x64
f0100c7c:	e8 6b fe ff ff       	call   f0100aec <stab_binsearch>
	if (lfile == 0)
f0100c81:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0100c84:	89 45 bc             	mov    %eax,-0x44(%ebp)
f0100c87:	83 c4 10             	add    $0x10,%esp
f0100c8a:	85 c0                	test   %eax,%eax
f0100c8c:	0f 84 7b 01 00 00    	je     f0100e0d <debuginfo_eip+0x22c>
		return -1;

	// Search within that file's stabs for the function definition
	// (N_FUN).
	lfun = lfile;
f0100c92:	89 45 dc             	mov    %eax,-0x24(%ebp)
	rfun = rfile;
f0100c95:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0100c98:	89 45 d8             	mov    %eax,-0x28(%ebp)
	stab_binsearch(stabs, &lfun, &rfun, N_FUN, addr);
f0100c9b:	8d 4d d8             	lea    -0x28(%ebp),%ecx
f0100c9e:	8d 55 dc             	lea    -0x24(%ebp),%edx
f0100ca1:	83 ec 08             	sub    $0x8,%esp
f0100ca4:	57                   	push   %edi
f0100ca5:	6a 24                	push   $0x24
f0100ca7:	c7 c0 58 22 10 f0    	mov    $0xf0102258,%eax
f0100cad:	e8 3a fe ff ff       	call   f0100aec <stab_binsearch>

	if (lfun <= rfun) {
f0100cb2:	8b 45 dc             	mov    -0x24(%ebp),%eax
f0100cb5:	89 45 c0             	mov    %eax,-0x40(%ebp)
f0100cb8:	8b 4d d8             	mov    -0x28(%ebp),%ecx
f0100cbb:	89 4d c4             	mov    %ecx,-0x3c(%ebp)
f0100cbe:	83 c4 10             	add    $0x10,%esp
f0100cc1:	39 c8                	cmp    %ecx,%eax
f0100cc3:	0f 8f 4b 01 00 00    	jg     f0100e14 <debuginfo_eip+0x233>
		// stabs[lfun] points to the function name
		// in the string table, but check bounds just in case.
		if (stabs[lfun].n_strx < stabstr_end - stabstr)
f0100cc9:	8d 04 40             	lea    (%eax,%eax,2),%eax
f0100ccc:	c7 c2 58 22 10 f0    	mov    $0xf0102258,%edx
f0100cd2:	8d 04 82             	lea    (%edx,%eax,4),%eax
f0100cd5:	8b 10                	mov    (%eax),%edx
f0100cd7:	c7 c1 6d 71 10 f0    	mov    $0xf010716d,%ecx
f0100cdd:	81 e9 35 5b 10 f0    	sub    $0xf0105b35,%ecx
f0100ce3:	89 4d b8             	mov    %ecx,-0x48(%ebp)
f0100ce6:	39 ca                	cmp    %ecx,%edx
f0100ce8:	73 09                	jae    f0100cf3 <debuginfo_eip+0x112>
			info->eip_fn_name = stabstr + stabs[lfun].n_strx;
f0100cea:	81 c2 35 5b 10 f0    	add    $0xf0105b35,%edx
f0100cf0:	89 56 08             	mov    %edx,0x8(%esi)
		info->eip_fn_addr = stabs[lfun].n_value;
f0100cf3:	8b 50 08             	mov    0x8(%eax),%edx
f0100cf6:	89 56 10             	mov    %edx,0x10(%esi)
		addr -= info->eip_fn_addr;
f0100cf9:	29 d7                	sub    %edx,%edi
		// Search within the function definition for the line number.
		lline = lfun;
f0100cfb:	8b 55 c0             	mov    -0x40(%ebp),%edx
f0100cfe:	89 55 d4             	mov    %edx,-0x2c(%ebp)
		rline = rfun;
f0100d01:	8b 55 c4             	mov    -0x3c(%ebp),%edx
f0100d04:	89 55 d0             	mov    %edx,-0x30(%ebp)
		info->eip_line = stabs[lline].n_desc;
f0100d07:	0f b7 40 06          	movzwl 0x6(%eax),%eax
f0100d0b:	89 46 04             	mov    %eax,0x4(%esi)
		lline = lfile;
		rline = rfile;
		return -1; 
	}
	// Ignore stuff after the colon.
	info->eip_fn_namelen = strfind(info->eip_fn_name, ':') - info->eip_fn_name;
f0100d0e:	83 ec 08             	sub    $0x8,%esp
f0100d11:	6a 3a                	push   $0x3a
f0100d13:	ff 76 08             	push   0x8(%esi)
f0100d16:	e8 a1 09 00 00       	call   f01016bc <strfind>
f0100d1b:	2b 46 08             	sub    0x8(%esi),%eax
f0100d1e:	89 46 0c             	mov    %eax,0xc(%esi)
	//
	// Hint:
	//	There's a particular stabs type used for line numbers.
	//	Look at the STABS documentation and <inc/stab.h> to find
	//	which one.
	stab_binsearch(stabs, &lline, &rline, N_SLINE, addr);
f0100d21:	8d 4d d0             	lea    -0x30(%ebp),%ecx
f0100d24:	8d 55 d4             	lea    -0x2c(%ebp),%edx
f0100d27:	83 c4 08             	add    $0x8,%esp
f0100d2a:	57                   	push   %edi
f0100d2b:	6a 44                	push   $0x44
f0100d2d:	c7 c0 58 22 10 f0    	mov    $0xf0102258,%eax
f0100d33:	e8 b4 fd ff ff       	call   f0100aec <stab_binsearch>
	if (lline <= rline) 
f0100d38:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0100d3b:	83 c4 10             	add    $0x10,%esp
f0100d3e:	3b 45 d0             	cmp    -0x30(%ebp),%eax
f0100d41:	0f 8f d4 00 00 00    	jg     f0100e1b <debuginfo_eip+0x23a>
	{
    		info->eip_line = stabs[lline].n_desc;
f0100d47:	89 c2                	mov    %eax,%edx
f0100d49:	8d 0c 40             	lea    (%eax,%eax,2),%ecx
f0100d4c:	c7 c0 58 22 10 f0    	mov    $0xf0102258,%eax
f0100d52:	0f b7 7c 88 06       	movzwl 0x6(%eax,%ecx,4),%edi
f0100d57:	89 7e 04             	mov    %edi,0x4(%esi)
f0100d5a:	8d 44 88 04          	lea    0x4(%eax,%ecx,4),%eax
f0100d5e:	8b 7d bc             	mov    -0x44(%ebp),%edi
f0100d61:	89 75 0c             	mov    %esi,0xc(%ebp)
	// Search backwards from the line number for the relevant filename
	// stab.
	// We can't just use the "lfile" stab because inlined functions
	// can interpolate code from a different file!
	// Such included source files use the N_SOL stab type.
	while (lline >= lfile
f0100d64:	eb 1e                	jmp    f0100d84 <debuginfo_eip+0x1a3>
  	        panic("User address");
f0100d66:	83 ec 04             	sub    $0x4,%esp
f0100d69:	8d 83 3f 0d ff ff    	lea    -0xf2c1(%ebx),%eax
f0100d6f:	50                   	push   %eax
f0100d70:	6a 7f                	push   $0x7f
f0100d72:	8d 83 4c 0d ff ff    	lea    -0xf2b4(%ebx),%eax
f0100d78:	50                   	push   %eax
f0100d79:	e8 88 f3 ff ff       	call   f0100106 <_panic>
f0100d7e:	83 ea 01             	sub    $0x1,%edx
f0100d81:	83 e8 0c             	sub    $0xc,%eax
	       && stabs[lline].n_type != N_SOL
	       && (stabs[lline].n_type != N_SO || !stabs[lline].n_value))
f0100d84:	39 d7                	cmp    %edx,%edi
f0100d86:	7f 31                	jg     f0100db9 <debuginfo_eip+0x1d8>
	       && stabs[lline].n_type != N_SOL
f0100d88:	0f b6 08             	movzbl (%eax),%ecx
f0100d8b:	80 f9 84             	cmp    $0x84,%cl
f0100d8e:	74 0b                	je     f0100d9b <debuginfo_eip+0x1ba>
	       && (stabs[lline].n_type != N_SO || !stabs[lline].n_value))
f0100d90:	80 f9 64             	cmp    $0x64,%cl
f0100d93:	75 e9                	jne    f0100d7e <debuginfo_eip+0x19d>
f0100d95:	83 78 04 00          	cmpl   $0x0,0x4(%eax)
f0100d99:	74 e3                	je     f0100d7e <debuginfo_eip+0x19d>
		lline--;
	if (lline >= lfile && stabs[lline].n_strx < stabstr_end - stabstr)
f0100d9b:	8b 75 0c             	mov    0xc(%ebp),%esi
f0100d9e:	8d 14 52             	lea    (%edx,%edx,2),%edx
f0100da1:	c7 c0 58 22 10 f0    	mov    $0xf0102258,%eax
f0100da7:	8b 04 90             	mov    (%eax,%edx,4),%eax
f0100daa:	39 45 b8             	cmp    %eax,-0x48(%ebp)
f0100dad:	76 0d                	jbe    f0100dbc <debuginfo_eip+0x1db>
		info->eip_file = stabstr + stabs[lline].n_strx;
f0100daf:	81 c0 35 5b 10 f0    	add    $0xf0105b35,%eax
f0100db5:	89 06                	mov    %eax,(%esi)
f0100db7:	eb 03                	jmp    f0100dbc <debuginfo_eip+0x1db>
f0100db9:	8b 75 0c             	mov    0xc(%ebp),%esi
		for (lline = lfun + 1;
		     lline < rfun && stabs[lline].n_type == N_PSYM;
		     lline++)
			info->eip_fn_narg++;

	return 0;
f0100dbc:	b8 00 00 00 00       	mov    $0x0,%eax
	if (lfun < rfun)
f0100dc1:	8b 7d c0             	mov    -0x40(%ebp),%edi
f0100dc4:	8b 55 c4             	mov    -0x3c(%ebp),%edx
f0100dc7:	39 d7                	cmp    %edx,%edi
f0100dc9:	7d 5c                	jge    f0100e27 <debuginfo_eip+0x246>
		for (lline = lfun + 1;
f0100dcb:	83 c7 01             	add    $0x1,%edi
f0100dce:	89 f8                	mov    %edi,%eax
f0100dd0:	8d 0c 7f             	lea    (%edi,%edi,2),%ecx
f0100dd3:	c7 c2 58 22 10 f0    	mov    $0xf0102258,%edx
f0100dd9:	8d 54 8a 04          	lea    0x4(%edx,%ecx,4),%edx
f0100ddd:	8b 5d c4             	mov    -0x3c(%ebp),%ebx
f0100de0:	eb 04                	jmp    f0100de6 <debuginfo_eip+0x205>
			info->eip_fn_narg++;
f0100de2:	83 46 14 01          	addl   $0x1,0x14(%esi)
		     lline < rfun && stabs[lline].n_type == N_PSYM;
f0100de6:	39 c3                	cmp    %eax,%ebx
f0100de8:	7e 38                	jle    f0100e22 <debuginfo_eip+0x241>
f0100dea:	0f b6 0a             	movzbl (%edx),%ecx
f0100ded:	83 c0 01             	add    $0x1,%eax
f0100df0:	83 c2 0c             	add    $0xc,%edx
f0100df3:	80 f9 a0             	cmp    $0xa0,%cl
f0100df6:	74 ea                	je     f0100de2 <debuginfo_eip+0x201>
	return 0;
f0100df8:	b8 00 00 00 00       	mov    $0x0,%eax
f0100dfd:	eb 28                	jmp    f0100e27 <debuginfo_eip+0x246>
		return -1;
f0100dff:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0100e04:	eb 21                	jmp    f0100e27 <debuginfo_eip+0x246>
f0100e06:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0100e0b:	eb 1a                	jmp    f0100e27 <debuginfo_eip+0x246>
		return -1;
f0100e0d:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0100e12:	eb 13                	jmp    f0100e27 <debuginfo_eip+0x246>
		return -1; 
f0100e14:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0100e19:	eb 0c                	jmp    f0100e27 <debuginfo_eip+0x246>
		return -1; 
f0100e1b:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0100e20:	eb 05                	jmp    f0100e27 <debuginfo_eip+0x246>
	return 0;
f0100e22:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0100e27:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0100e2a:	5b                   	pop    %ebx
f0100e2b:	5e                   	pop    %esi
f0100e2c:	5f                   	pop    %edi
f0100e2d:	5d                   	pop    %ebp
f0100e2e:	c3                   	ret    

f0100e2f <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
f0100e2f:	55                   	push   %ebp
f0100e30:	89 e5                	mov    %esp,%ebp
f0100e32:	57                   	push   %edi
f0100e33:	56                   	push   %esi
f0100e34:	53                   	push   %ebx
f0100e35:	83 ec 2c             	sub    $0x2c,%esp
f0100e38:	e8 07 06 00 00       	call   f0101444 <__x86.get_pc_thunk.cx>
f0100e3d:	81 c1 cb 04 01 00    	add    $0x104cb,%ecx
f0100e43:	89 4d dc             	mov    %ecx,-0x24(%ebp)
f0100e46:	89 c7                	mov    %eax,%edi
f0100e48:	89 d6                	mov    %edx,%esi
f0100e4a:	8b 45 08             	mov    0x8(%ebp),%eax
f0100e4d:	8b 55 0c             	mov    0xc(%ebp),%edx
f0100e50:	89 d1                	mov    %edx,%ecx
f0100e52:	89 c2                	mov    %eax,%edx
f0100e54:	89 45 d0             	mov    %eax,-0x30(%ebp)
f0100e57:	89 4d d4             	mov    %ecx,-0x2c(%ebp)
f0100e5a:	8b 45 10             	mov    0x10(%ebp),%eax
f0100e5d:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
f0100e60:	89 45 e0             	mov    %eax,-0x20(%ebp)
f0100e63:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
f0100e6a:	39 c2                	cmp    %eax,%edx
f0100e6c:	1b 4d e4             	sbb    -0x1c(%ebp),%ecx
f0100e6f:	72 41                	jb     f0100eb2 <printnum+0x83>
		printnum(putch, putdat, num / base, base, width - 1, padc);
f0100e71:	83 ec 0c             	sub    $0xc,%esp
f0100e74:	ff 75 18             	push   0x18(%ebp)
f0100e77:	83 eb 01             	sub    $0x1,%ebx
f0100e7a:	53                   	push   %ebx
f0100e7b:	50                   	push   %eax
f0100e7c:	83 ec 08             	sub    $0x8,%esp
f0100e7f:	ff 75 e4             	push   -0x1c(%ebp)
f0100e82:	ff 75 e0             	push   -0x20(%ebp)
f0100e85:	ff 75 d4             	push   -0x2c(%ebp)
f0100e88:	ff 75 d0             	push   -0x30(%ebp)
f0100e8b:	8b 5d dc             	mov    -0x24(%ebp),%ebx
f0100e8e:	e8 3d 0a 00 00       	call   f01018d0 <__udivdi3>
f0100e93:	83 c4 18             	add    $0x18,%esp
f0100e96:	52                   	push   %edx
f0100e97:	50                   	push   %eax
f0100e98:	89 f2                	mov    %esi,%edx
f0100e9a:	89 f8                	mov    %edi,%eax
f0100e9c:	e8 8e ff ff ff       	call   f0100e2f <printnum>
f0100ea1:	83 c4 20             	add    $0x20,%esp
f0100ea4:	eb 13                	jmp    f0100eb9 <printnum+0x8a>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
f0100ea6:	83 ec 08             	sub    $0x8,%esp
f0100ea9:	56                   	push   %esi
f0100eaa:	ff 75 18             	push   0x18(%ebp)
f0100ead:	ff d7                	call   *%edi
f0100eaf:	83 c4 10             	add    $0x10,%esp
		while (--width > 0)
f0100eb2:	83 eb 01             	sub    $0x1,%ebx
f0100eb5:	85 db                	test   %ebx,%ebx
f0100eb7:	7f ed                	jg     f0100ea6 <printnum+0x77>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
f0100eb9:	83 ec 08             	sub    $0x8,%esp
f0100ebc:	56                   	push   %esi
f0100ebd:	83 ec 04             	sub    $0x4,%esp
f0100ec0:	ff 75 e4             	push   -0x1c(%ebp)
f0100ec3:	ff 75 e0             	push   -0x20(%ebp)
f0100ec6:	ff 75 d4             	push   -0x2c(%ebp)
f0100ec9:	ff 75 d0             	push   -0x30(%ebp)
f0100ecc:	8b 5d dc             	mov    -0x24(%ebp),%ebx
f0100ecf:	e8 1c 0b 00 00       	call   f01019f0 <__umoddi3>
f0100ed4:	83 c4 14             	add    $0x14,%esp
f0100ed7:	0f be 84 03 5a 0d ff 	movsbl -0xf2a6(%ebx,%eax,1),%eax
f0100ede:	ff 
f0100edf:	50                   	push   %eax
f0100ee0:	ff d7                	call   *%edi
}
f0100ee2:	83 c4 10             	add    $0x10,%esp
f0100ee5:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0100ee8:	5b                   	pop    %ebx
f0100ee9:	5e                   	pop    %esi
f0100eea:	5f                   	pop    %edi
f0100eeb:	5d                   	pop    %ebp
f0100eec:	c3                   	ret    

f0100eed <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
f0100eed:	55                   	push   %ebp
f0100eee:	89 e5                	mov    %esp,%ebp
f0100ef0:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
f0100ef3:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
f0100ef7:	8b 10                	mov    (%eax),%edx
f0100ef9:	3b 50 04             	cmp    0x4(%eax),%edx
f0100efc:	73 0a                	jae    f0100f08 <sprintputch+0x1b>
		*b->buf++ = ch;
f0100efe:	8d 4a 01             	lea    0x1(%edx),%ecx
f0100f01:	89 08                	mov    %ecx,(%eax)
f0100f03:	8b 45 08             	mov    0x8(%ebp),%eax
f0100f06:	88 02                	mov    %al,(%edx)
}
f0100f08:	5d                   	pop    %ebp
f0100f09:	c3                   	ret    

f0100f0a <printfmt>:
{
f0100f0a:	55                   	push   %ebp
f0100f0b:	89 e5                	mov    %esp,%ebp
f0100f0d:	83 ec 08             	sub    $0x8,%esp
	va_start(ap, fmt);
f0100f10:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
f0100f13:	50                   	push   %eax
f0100f14:	ff 75 10             	push   0x10(%ebp)
f0100f17:	ff 75 0c             	push   0xc(%ebp)
f0100f1a:	ff 75 08             	push   0x8(%ebp)
f0100f1d:	e8 05 00 00 00       	call   f0100f27 <vprintfmt>
}
f0100f22:	83 c4 10             	add    $0x10,%esp
f0100f25:	c9                   	leave  
f0100f26:	c3                   	ret    

f0100f27 <vprintfmt>:
{
f0100f27:	55                   	push   %ebp
f0100f28:	89 e5                	mov    %esp,%ebp
f0100f2a:	57                   	push   %edi
f0100f2b:	56                   	push   %esi
f0100f2c:	53                   	push   %ebx
f0100f2d:	83 ec 3c             	sub    $0x3c,%esp
f0100f30:	e8 19 f8 ff ff       	call   f010074e <__x86.get_pc_thunk.ax>
f0100f35:	05 d3 03 01 00       	add    $0x103d3,%eax
f0100f3a:	89 45 e0             	mov    %eax,-0x20(%ebp)
f0100f3d:	8b 75 08             	mov    0x8(%ebp),%esi
f0100f40:	8b 7d 0c             	mov    0xc(%ebp),%edi
f0100f43:	8b 5d 10             	mov    0x10(%ebp),%ebx
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
f0100f46:	8d 80 3c 1d 00 00    	lea    0x1d3c(%eax),%eax
f0100f4c:	89 45 c4             	mov    %eax,-0x3c(%ebp)
f0100f4f:	eb 0a                	jmp    f0100f5b <vprintfmt+0x34>
			putch(ch, putdat);
f0100f51:	83 ec 08             	sub    $0x8,%esp
f0100f54:	57                   	push   %edi
f0100f55:	50                   	push   %eax
f0100f56:	ff d6                	call   *%esi
f0100f58:	83 c4 10             	add    $0x10,%esp
		while ((ch = *(unsigned char *) fmt++) != '%') {
f0100f5b:	83 c3 01             	add    $0x1,%ebx
f0100f5e:	0f b6 43 ff          	movzbl -0x1(%ebx),%eax
f0100f62:	83 f8 25             	cmp    $0x25,%eax
f0100f65:	74 0c                	je     f0100f73 <vprintfmt+0x4c>
			if (ch == '\0')
f0100f67:	85 c0                	test   %eax,%eax
f0100f69:	75 e6                	jne    f0100f51 <vprintfmt+0x2a>
}
f0100f6b:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0100f6e:	5b                   	pop    %ebx
f0100f6f:	5e                   	pop    %esi
f0100f70:	5f                   	pop    %edi
f0100f71:	5d                   	pop    %ebp
f0100f72:	c3                   	ret    
		padc = ' ';
f0100f73:	c6 45 cf 20          	movb   $0x20,-0x31(%ebp)
		altflag = 0;
f0100f77:	c7 45 d0 00 00 00 00 	movl   $0x0,-0x30(%ebp)
		precision = -1;
f0100f7e:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
		width = -1;
f0100f85:	c7 45 d4 ff ff ff ff 	movl   $0xffffffff,-0x2c(%ebp)
		lflag = 0;
f0100f8c:	b9 00 00 00 00       	mov    $0x0,%ecx
f0100f91:	89 4d c8             	mov    %ecx,-0x38(%ebp)
f0100f94:	89 75 08             	mov    %esi,0x8(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
f0100f97:	8d 43 01             	lea    0x1(%ebx),%eax
f0100f9a:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f0100f9d:	0f b6 13             	movzbl (%ebx),%edx
f0100fa0:	8d 42 dd             	lea    -0x23(%edx),%eax
f0100fa3:	3c 55                	cmp    $0x55,%al
f0100fa5:	0f 87 fd 03 00 00    	ja     f01013a8 <.L20>
f0100fab:	0f b6 c0             	movzbl %al,%eax
f0100fae:	8b 4d e0             	mov    -0x20(%ebp),%ecx
f0100fb1:	89 ce                	mov    %ecx,%esi
f0100fb3:	03 b4 81 e8 0d ff ff 	add    -0xf218(%ecx,%eax,4),%esi
f0100fba:	ff e6                	jmp    *%esi

f0100fbc <.L68>:
f0100fbc:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
			padc = '-';
f0100fbf:	c6 45 cf 2d          	movb   $0x2d,-0x31(%ebp)
f0100fc3:	eb d2                	jmp    f0100f97 <vprintfmt+0x70>

f0100fc5 <.L32>:
		switch (ch = *(unsigned char *) fmt++) {
f0100fc5:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
f0100fc8:	c6 45 cf 30          	movb   $0x30,-0x31(%ebp)
f0100fcc:	eb c9                	jmp    f0100f97 <vprintfmt+0x70>

f0100fce <.L31>:
f0100fce:	0f b6 d2             	movzbl %dl,%edx
f0100fd1:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
			for (precision = 0; ; ++fmt) {
f0100fd4:	b8 00 00 00 00       	mov    $0x0,%eax
f0100fd9:	8b 75 08             	mov    0x8(%ebp),%esi
				precision = precision * 10 + ch - '0';
f0100fdc:	8d 04 80             	lea    (%eax,%eax,4),%eax
f0100fdf:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
f0100fe3:	0f be 13             	movsbl (%ebx),%edx
				if (ch < '0' || ch > '9')
f0100fe6:	8d 4a d0             	lea    -0x30(%edx),%ecx
f0100fe9:	83 f9 09             	cmp    $0x9,%ecx
f0100fec:	77 58                	ja     f0101046 <.L36+0xf>
			for (precision = 0; ; ++fmt) {
f0100fee:	83 c3 01             	add    $0x1,%ebx
				precision = precision * 10 + ch - '0';
f0100ff1:	eb e9                	jmp    f0100fdc <.L31+0xe>

f0100ff3 <.L34>:
			precision = va_arg(ap, int);
f0100ff3:	8b 45 14             	mov    0x14(%ebp),%eax
f0100ff6:	8b 00                	mov    (%eax),%eax
f0100ff8:	89 45 d8             	mov    %eax,-0x28(%ebp)
f0100ffb:	8b 45 14             	mov    0x14(%ebp),%eax
f0100ffe:	8d 40 04             	lea    0x4(%eax),%eax
f0101001:	89 45 14             	mov    %eax,0x14(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
f0101004:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
			if (width < 0)
f0101007:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
f010100b:	79 8a                	jns    f0100f97 <vprintfmt+0x70>
				width = precision, precision = -1;
f010100d:	8b 45 d8             	mov    -0x28(%ebp),%eax
f0101010:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f0101013:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
f010101a:	e9 78 ff ff ff       	jmp    f0100f97 <vprintfmt+0x70>

f010101f <.L33>:
f010101f:	8b 55 d4             	mov    -0x2c(%ebp),%edx
f0101022:	85 d2                	test   %edx,%edx
f0101024:	b8 00 00 00 00       	mov    $0x0,%eax
f0101029:	0f 49 c2             	cmovns %edx,%eax
f010102c:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
f010102f:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
			goto reswitch;
f0101032:	e9 60 ff ff ff       	jmp    f0100f97 <vprintfmt+0x70>

f0101037 <.L36>:
		switch (ch = *(unsigned char *) fmt++) {
f0101037:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
			altflag = 1;
f010103a:	c7 45 d0 01 00 00 00 	movl   $0x1,-0x30(%ebp)
			goto reswitch;
f0101041:	e9 51 ff ff ff       	jmp    f0100f97 <vprintfmt+0x70>
f0101046:	89 45 d8             	mov    %eax,-0x28(%ebp)
f0101049:	89 75 08             	mov    %esi,0x8(%ebp)
f010104c:	eb b9                	jmp    f0101007 <.L34+0x14>

f010104e <.L27>:
			lflag++;
f010104e:	83 45 c8 01          	addl   $0x1,-0x38(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
f0101052:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
			goto reswitch;
f0101055:	e9 3d ff ff ff       	jmp    f0100f97 <vprintfmt+0x70>

f010105a <.L30>:
			putch(va_arg(ap, int), putdat);
f010105a:	8b 75 08             	mov    0x8(%ebp),%esi
f010105d:	8b 45 14             	mov    0x14(%ebp),%eax
f0101060:	8d 58 04             	lea    0x4(%eax),%ebx
f0101063:	83 ec 08             	sub    $0x8,%esp
f0101066:	57                   	push   %edi
f0101067:	ff 30                	push   (%eax)
f0101069:	ff d6                	call   *%esi
			break;
f010106b:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
f010106e:	89 5d 14             	mov    %ebx,0x14(%ebp)
			break;
f0101071:	e9 c8 02 00 00       	jmp    f010133e <.L25+0x45>

f0101076 <.L28>:
			err = va_arg(ap, int);
f0101076:	8b 75 08             	mov    0x8(%ebp),%esi
f0101079:	8b 45 14             	mov    0x14(%ebp),%eax
f010107c:	8d 58 04             	lea    0x4(%eax),%ebx
f010107f:	8b 10                	mov    (%eax),%edx
f0101081:	89 d0                	mov    %edx,%eax
f0101083:	f7 d8                	neg    %eax
f0101085:	0f 48 c2             	cmovs  %edx,%eax
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
f0101088:	83 f8 06             	cmp    $0x6,%eax
f010108b:	7f 27                	jg     f01010b4 <.L28+0x3e>
f010108d:	8b 55 c4             	mov    -0x3c(%ebp),%edx
f0101090:	8b 14 82             	mov    (%edx,%eax,4),%edx
f0101093:	85 d2                	test   %edx,%edx
f0101095:	74 1d                	je     f01010b4 <.L28+0x3e>
				printfmt(putch, putdat, "%s", p);
f0101097:	52                   	push   %edx
f0101098:	8b 45 e0             	mov    -0x20(%ebp),%eax
f010109b:	8d 80 7b 0d ff ff    	lea    -0xf285(%eax),%eax
f01010a1:	50                   	push   %eax
f01010a2:	57                   	push   %edi
f01010a3:	56                   	push   %esi
f01010a4:	e8 61 fe ff ff       	call   f0100f0a <printfmt>
f01010a9:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
f01010ac:	89 5d 14             	mov    %ebx,0x14(%ebp)
f01010af:	e9 8a 02 00 00       	jmp    f010133e <.L25+0x45>
				printfmt(putch, putdat, "error %d", err);
f01010b4:	50                   	push   %eax
f01010b5:	8b 45 e0             	mov    -0x20(%ebp),%eax
f01010b8:	8d 80 72 0d ff ff    	lea    -0xf28e(%eax),%eax
f01010be:	50                   	push   %eax
f01010bf:	57                   	push   %edi
f01010c0:	56                   	push   %esi
f01010c1:	e8 44 fe ff ff       	call   f0100f0a <printfmt>
f01010c6:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
f01010c9:	89 5d 14             	mov    %ebx,0x14(%ebp)
				printfmt(putch, putdat, "error %d", err);
f01010cc:	e9 6d 02 00 00       	jmp    f010133e <.L25+0x45>

f01010d1 <.L24>:
			if ((p = va_arg(ap, char *)) == NULL)
f01010d1:	8b 75 08             	mov    0x8(%ebp),%esi
f01010d4:	8b 45 14             	mov    0x14(%ebp),%eax
f01010d7:	83 c0 04             	add    $0x4,%eax
f01010da:	89 45 c0             	mov    %eax,-0x40(%ebp)
f01010dd:	8b 45 14             	mov    0x14(%ebp),%eax
f01010e0:	8b 10                	mov    (%eax),%edx
				p = "(null)";
f01010e2:	85 d2                	test   %edx,%edx
f01010e4:	8b 45 e0             	mov    -0x20(%ebp),%eax
f01010e7:	8d 80 6b 0d ff ff    	lea    -0xf295(%eax),%eax
f01010ed:	0f 45 c2             	cmovne %edx,%eax
f01010f0:	89 45 c8             	mov    %eax,-0x38(%ebp)
			if (width > 0 && padc != '-')
f01010f3:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
f01010f7:	7e 06                	jle    f01010ff <.L24+0x2e>
f01010f9:	80 7d cf 2d          	cmpb   $0x2d,-0x31(%ebp)
f01010fd:	75 0d                	jne    f010110c <.L24+0x3b>
				for (width -= strnlen(p, precision); width > 0; width--)
f01010ff:	8b 45 c8             	mov    -0x38(%ebp),%eax
f0101102:	89 c3                	mov    %eax,%ebx
f0101104:	03 45 d4             	add    -0x2c(%ebp),%eax
f0101107:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f010110a:	eb 58                	jmp    f0101164 <.L24+0x93>
f010110c:	83 ec 08             	sub    $0x8,%esp
f010110f:	ff 75 d8             	push   -0x28(%ebp)
f0101112:	ff 75 c8             	push   -0x38(%ebp)
f0101115:	8b 5d e0             	mov    -0x20(%ebp),%ebx
f0101118:	e8 48 04 00 00       	call   f0101565 <strnlen>
f010111d:	8b 55 d4             	mov    -0x2c(%ebp),%edx
f0101120:	29 c2                	sub    %eax,%edx
f0101122:	89 55 bc             	mov    %edx,-0x44(%ebp)
f0101125:	83 c4 10             	add    $0x10,%esp
f0101128:	89 d3                	mov    %edx,%ebx
					putch(padc, putdat);
f010112a:	0f be 45 cf          	movsbl -0x31(%ebp),%eax
f010112e:	89 45 d4             	mov    %eax,-0x2c(%ebp)
				for (width -= strnlen(p, precision); width > 0; width--)
f0101131:	eb 0f                	jmp    f0101142 <.L24+0x71>
					putch(padc, putdat);
f0101133:	83 ec 08             	sub    $0x8,%esp
f0101136:	57                   	push   %edi
f0101137:	ff 75 d4             	push   -0x2c(%ebp)
f010113a:	ff d6                	call   *%esi
				for (width -= strnlen(p, precision); width > 0; width--)
f010113c:	83 eb 01             	sub    $0x1,%ebx
f010113f:	83 c4 10             	add    $0x10,%esp
f0101142:	85 db                	test   %ebx,%ebx
f0101144:	7f ed                	jg     f0101133 <.L24+0x62>
f0101146:	8b 55 bc             	mov    -0x44(%ebp),%edx
f0101149:	85 d2                	test   %edx,%edx
f010114b:	b8 00 00 00 00       	mov    $0x0,%eax
f0101150:	0f 49 c2             	cmovns %edx,%eax
f0101153:	29 c2                	sub    %eax,%edx
f0101155:	89 55 d4             	mov    %edx,-0x2c(%ebp)
f0101158:	eb a5                	jmp    f01010ff <.L24+0x2e>
					putch(ch, putdat);
f010115a:	83 ec 08             	sub    $0x8,%esp
f010115d:	57                   	push   %edi
f010115e:	52                   	push   %edx
f010115f:	ff d6                	call   *%esi
f0101161:	83 c4 10             	add    $0x10,%esp
f0101164:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
f0101167:	29 d9                	sub    %ebx,%ecx
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
f0101169:	83 c3 01             	add    $0x1,%ebx
f010116c:	0f b6 43 ff          	movzbl -0x1(%ebx),%eax
f0101170:	0f be d0             	movsbl %al,%edx
f0101173:	85 d2                	test   %edx,%edx
f0101175:	74 4b                	je     f01011c2 <.L24+0xf1>
f0101177:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
f010117b:	78 06                	js     f0101183 <.L24+0xb2>
f010117d:	83 6d d8 01          	subl   $0x1,-0x28(%ebp)
f0101181:	78 1e                	js     f01011a1 <.L24+0xd0>
				if (altflag && (ch < ' ' || ch > '~'))
f0101183:	83 7d d0 00          	cmpl   $0x0,-0x30(%ebp)
f0101187:	74 d1                	je     f010115a <.L24+0x89>
f0101189:	0f be c0             	movsbl %al,%eax
f010118c:	83 e8 20             	sub    $0x20,%eax
f010118f:	83 f8 5e             	cmp    $0x5e,%eax
f0101192:	76 c6                	jbe    f010115a <.L24+0x89>
					putch('?', putdat);
f0101194:	83 ec 08             	sub    $0x8,%esp
f0101197:	57                   	push   %edi
f0101198:	6a 3f                	push   $0x3f
f010119a:	ff d6                	call   *%esi
f010119c:	83 c4 10             	add    $0x10,%esp
f010119f:	eb c3                	jmp    f0101164 <.L24+0x93>
f01011a1:	89 cb                	mov    %ecx,%ebx
f01011a3:	eb 0e                	jmp    f01011b3 <.L24+0xe2>
				putch(' ', putdat);
f01011a5:	83 ec 08             	sub    $0x8,%esp
f01011a8:	57                   	push   %edi
f01011a9:	6a 20                	push   $0x20
f01011ab:	ff d6                	call   *%esi
			for (; width > 0; width--)
f01011ad:	83 eb 01             	sub    $0x1,%ebx
f01011b0:	83 c4 10             	add    $0x10,%esp
f01011b3:	85 db                	test   %ebx,%ebx
f01011b5:	7f ee                	jg     f01011a5 <.L24+0xd4>
			if ((p = va_arg(ap, char *)) == NULL)
f01011b7:	8b 45 c0             	mov    -0x40(%ebp),%eax
f01011ba:	89 45 14             	mov    %eax,0x14(%ebp)
f01011bd:	e9 7c 01 00 00       	jmp    f010133e <.L25+0x45>
f01011c2:	89 cb                	mov    %ecx,%ebx
f01011c4:	eb ed                	jmp    f01011b3 <.L24+0xe2>

f01011c6 <.L29>:
	if (lflag >= 2)
f01011c6:	8b 4d c8             	mov    -0x38(%ebp),%ecx
f01011c9:	8b 75 08             	mov    0x8(%ebp),%esi
f01011cc:	83 f9 01             	cmp    $0x1,%ecx
f01011cf:	7f 1b                	jg     f01011ec <.L29+0x26>
	else if (lflag)
f01011d1:	85 c9                	test   %ecx,%ecx
f01011d3:	74 63                	je     f0101238 <.L29+0x72>
		return va_arg(*ap, long);
f01011d5:	8b 45 14             	mov    0x14(%ebp),%eax
f01011d8:	8b 00                	mov    (%eax),%eax
f01011da:	89 45 d8             	mov    %eax,-0x28(%ebp)
f01011dd:	99                   	cltd   
f01011de:	89 55 dc             	mov    %edx,-0x24(%ebp)
f01011e1:	8b 45 14             	mov    0x14(%ebp),%eax
f01011e4:	8d 40 04             	lea    0x4(%eax),%eax
f01011e7:	89 45 14             	mov    %eax,0x14(%ebp)
f01011ea:	eb 17                	jmp    f0101203 <.L29+0x3d>
		return va_arg(*ap, long long);
f01011ec:	8b 45 14             	mov    0x14(%ebp),%eax
f01011ef:	8b 50 04             	mov    0x4(%eax),%edx
f01011f2:	8b 00                	mov    (%eax),%eax
f01011f4:	89 45 d8             	mov    %eax,-0x28(%ebp)
f01011f7:	89 55 dc             	mov    %edx,-0x24(%ebp)
f01011fa:	8b 45 14             	mov    0x14(%ebp),%eax
f01011fd:	8d 40 08             	lea    0x8(%eax),%eax
f0101200:	89 45 14             	mov    %eax,0x14(%ebp)
			if ((long long) num < 0) {
f0101203:	8b 4d d8             	mov    -0x28(%ebp),%ecx
f0101206:	8b 5d dc             	mov    -0x24(%ebp),%ebx
			base = 10;
f0101209:	ba 0a 00 00 00       	mov    $0xa,%edx
			if ((long long) num < 0) {
f010120e:	85 db                	test   %ebx,%ebx
f0101210:	0f 89 0e 01 00 00    	jns    f0101324 <.L25+0x2b>
				putch('-', putdat);
f0101216:	83 ec 08             	sub    $0x8,%esp
f0101219:	57                   	push   %edi
f010121a:	6a 2d                	push   $0x2d
f010121c:	ff d6                	call   *%esi
				num = -(long long) num;
f010121e:	8b 4d d8             	mov    -0x28(%ebp),%ecx
f0101221:	8b 5d dc             	mov    -0x24(%ebp),%ebx
f0101224:	f7 d9                	neg    %ecx
f0101226:	83 d3 00             	adc    $0x0,%ebx
f0101229:	f7 db                	neg    %ebx
f010122b:	83 c4 10             	add    $0x10,%esp
			base = 10;
f010122e:	ba 0a 00 00 00       	mov    $0xa,%edx
f0101233:	e9 ec 00 00 00       	jmp    f0101324 <.L25+0x2b>
		return va_arg(*ap, int);
f0101238:	8b 45 14             	mov    0x14(%ebp),%eax
f010123b:	8b 00                	mov    (%eax),%eax
f010123d:	89 45 d8             	mov    %eax,-0x28(%ebp)
f0101240:	99                   	cltd   
f0101241:	89 55 dc             	mov    %edx,-0x24(%ebp)
f0101244:	8b 45 14             	mov    0x14(%ebp),%eax
f0101247:	8d 40 04             	lea    0x4(%eax),%eax
f010124a:	89 45 14             	mov    %eax,0x14(%ebp)
f010124d:	eb b4                	jmp    f0101203 <.L29+0x3d>

f010124f <.L23>:
	if (lflag >= 2)
f010124f:	8b 4d c8             	mov    -0x38(%ebp),%ecx
f0101252:	8b 75 08             	mov    0x8(%ebp),%esi
f0101255:	83 f9 01             	cmp    $0x1,%ecx
f0101258:	7f 1e                	jg     f0101278 <.L23+0x29>
	else if (lflag)
f010125a:	85 c9                	test   %ecx,%ecx
f010125c:	74 32                	je     f0101290 <.L23+0x41>
		return va_arg(*ap, unsigned long);
f010125e:	8b 45 14             	mov    0x14(%ebp),%eax
f0101261:	8b 08                	mov    (%eax),%ecx
f0101263:	bb 00 00 00 00       	mov    $0x0,%ebx
f0101268:	8d 40 04             	lea    0x4(%eax),%eax
f010126b:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
f010126e:	ba 0a 00 00 00       	mov    $0xa,%edx
		return va_arg(*ap, unsigned long);
f0101273:	e9 ac 00 00 00       	jmp    f0101324 <.L25+0x2b>
		return va_arg(*ap, unsigned long long);
f0101278:	8b 45 14             	mov    0x14(%ebp),%eax
f010127b:	8b 08                	mov    (%eax),%ecx
f010127d:	8b 58 04             	mov    0x4(%eax),%ebx
f0101280:	8d 40 08             	lea    0x8(%eax),%eax
f0101283:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
f0101286:	ba 0a 00 00 00       	mov    $0xa,%edx
		return va_arg(*ap, unsigned long long);
f010128b:	e9 94 00 00 00       	jmp    f0101324 <.L25+0x2b>
		return va_arg(*ap, unsigned int);
f0101290:	8b 45 14             	mov    0x14(%ebp),%eax
f0101293:	8b 08                	mov    (%eax),%ecx
f0101295:	bb 00 00 00 00       	mov    $0x0,%ebx
f010129a:	8d 40 04             	lea    0x4(%eax),%eax
f010129d:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
f01012a0:	ba 0a 00 00 00       	mov    $0xa,%edx
		return va_arg(*ap, unsigned int);
f01012a5:	eb 7d                	jmp    f0101324 <.L25+0x2b>

f01012a7 <.L26>:
	if (lflag >= 2)
f01012a7:	8b 4d c8             	mov    -0x38(%ebp),%ecx
f01012aa:	8b 75 08             	mov    0x8(%ebp),%esi
f01012ad:	83 f9 01             	cmp    $0x1,%ecx
f01012b0:	7f 1b                	jg     f01012cd <.L26+0x26>
	else if (lflag)
f01012b2:	85 c9                	test   %ecx,%ecx
f01012b4:	74 2c                	je     f01012e2 <.L26+0x3b>
		return va_arg(*ap, unsigned long);
f01012b6:	8b 45 14             	mov    0x14(%ebp),%eax
f01012b9:	8b 08                	mov    (%eax),%ecx
f01012bb:	bb 00 00 00 00       	mov    $0x0,%ebx
f01012c0:	8d 40 04             	lea    0x4(%eax),%eax
f01012c3:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 8;
f01012c6:	ba 08 00 00 00       	mov    $0x8,%edx
		return va_arg(*ap, unsigned long);
f01012cb:	eb 57                	jmp    f0101324 <.L25+0x2b>
		return va_arg(*ap, unsigned long long);
f01012cd:	8b 45 14             	mov    0x14(%ebp),%eax
f01012d0:	8b 08                	mov    (%eax),%ecx
f01012d2:	8b 58 04             	mov    0x4(%eax),%ebx
f01012d5:	8d 40 08             	lea    0x8(%eax),%eax
f01012d8:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 8;
f01012db:	ba 08 00 00 00       	mov    $0x8,%edx
		return va_arg(*ap, unsigned long long);
f01012e0:	eb 42                	jmp    f0101324 <.L25+0x2b>
		return va_arg(*ap, unsigned int);
f01012e2:	8b 45 14             	mov    0x14(%ebp),%eax
f01012e5:	8b 08                	mov    (%eax),%ecx
f01012e7:	bb 00 00 00 00       	mov    $0x0,%ebx
f01012ec:	8d 40 04             	lea    0x4(%eax),%eax
f01012ef:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 8;
f01012f2:	ba 08 00 00 00       	mov    $0x8,%edx
		return va_arg(*ap, unsigned int);
f01012f7:	eb 2b                	jmp    f0101324 <.L25+0x2b>

f01012f9 <.L25>:
			putch('0', putdat);
f01012f9:	8b 75 08             	mov    0x8(%ebp),%esi
f01012fc:	83 ec 08             	sub    $0x8,%esp
f01012ff:	57                   	push   %edi
f0101300:	6a 30                	push   $0x30
f0101302:	ff d6                	call   *%esi
			putch('x', putdat);
f0101304:	83 c4 08             	add    $0x8,%esp
f0101307:	57                   	push   %edi
f0101308:	6a 78                	push   $0x78
f010130a:	ff d6                	call   *%esi
			num = (unsigned long long)
f010130c:	8b 45 14             	mov    0x14(%ebp),%eax
f010130f:	8b 08                	mov    (%eax),%ecx
f0101311:	bb 00 00 00 00       	mov    $0x0,%ebx
			goto number;
f0101316:	83 c4 10             	add    $0x10,%esp
				(uintptr_t) va_arg(ap, void *);
f0101319:	8d 40 04             	lea    0x4(%eax),%eax
f010131c:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
f010131f:	ba 10 00 00 00       	mov    $0x10,%edx
			printnum(putch, putdat, num, base, width, padc);
f0101324:	83 ec 0c             	sub    $0xc,%esp
f0101327:	0f be 45 cf          	movsbl -0x31(%ebp),%eax
f010132b:	50                   	push   %eax
f010132c:	ff 75 d4             	push   -0x2c(%ebp)
f010132f:	52                   	push   %edx
f0101330:	53                   	push   %ebx
f0101331:	51                   	push   %ecx
f0101332:	89 fa                	mov    %edi,%edx
f0101334:	89 f0                	mov    %esi,%eax
f0101336:	e8 f4 fa ff ff       	call   f0100e2f <printnum>
			break;
f010133b:	83 c4 20             	add    $0x20,%esp
			err = va_arg(ap, int);
f010133e:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
		while ((ch = *(unsigned char *) fmt++) != '%') {
f0101341:	e9 15 fc ff ff       	jmp    f0100f5b <vprintfmt+0x34>

f0101346 <.L21>:
	if (lflag >= 2)
f0101346:	8b 4d c8             	mov    -0x38(%ebp),%ecx
f0101349:	8b 75 08             	mov    0x8(%ebp),%esi
f010134c:	83 f9 01             	cmp    $0x1,%ecx
f010134f:	7f 1b                	jg     f010136c <.L21+0x26>
	else if (lflag)
f0101351:	85 c9                	test   %ecx,%ecx
f0101353:	74 2c                	je     f0101381 <.L21+0x3b>
		return va_arg(*ap, unsigned long);
f0101355:	8b 45 14             	mov    0x14(%ebp),%eax
f0101358:	8b 08                	mov    (%eax),%ecx
f010135a:	bb 00 00 00 00       	mov    $0x0,%ebx
f010135f:	8d 40 04             	lea    0x4(%eax),%eax
f0101362:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
f0101365:	ba 10 00 00 00       	mov    $0x10,%edx
		return va_arg(*ap, unsigned long);
f010136a:	eb b8                	jmp    f0101324 <.L25+0x2b>
		return va_arg(*ap, unsigned long long);
f010136c:	8b 45 14             	mov    0x14(%ebp),%eax
f010136f:	8b 08                	mov    (%eax),%ecx
f0101371:	8b 58 04             	mov    0x4(%eax),%ebx
f0101374:	8d 40 08             	lea    0x8(%eax),%eax
f0101377:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
f010137a:	ba 10 00 00 00       	mov    $0x10,%edx
		return va_arg(*ap, unsigned long long);
f010137f:	eb a3                	jmp    f0101324 <.L25+0x2b>
		return va_arg(*ap, unsigned int);
f0101381:	8b 45 14             	mov    0x14(%ebp),%eax
f0101384:	8b 08                	mov    (%eax),%ecx
f0101386:	bb 00 00 00 00       	mov    $0x0,%ebx
f010138b:	8d 40 04             	lea    0x4(%eax),%eax
f010138e:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
f0101391:	ba 10 00 00 00       	mov    $0x10,%edx
		return va_arg(*ap, unsigned int);
f0101396:	eb 8c                	jmp    f0101324 <.L25+0x2b>

f0101398 <.L35>:
			putch(ch, putdat);
f0101398:	8b 75 08             	mov    0x8(%ebp),%esi
f010139b:	83 ec 08             	sub    $0x8,%esp
f010139e:	57                   	push   %edi
f010139f:	6a 25                	push   $0x25
f01013a1:	ff d6                	call   *%esi
			break;
f01013a3:	83 c4 10             	add    $0x10,%esp
f01013a6:	eb 96                	jmp    f010133e <.L25+0x45>

f01013a8 <.L20>:
			putch('%', putdat);
f01013a8:	8b 75 08             	mov    0x8(%ebp),%esi
f01013ab:	83 ec 08             	sub    $0x8,%esp
f01013ae:	57                   	push   %edi
f01013af:	6a 25                	push   $0x25
f01013b1:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
f01013b3:	83 c4 10             	add    $0x10,%esp
f01013b6:	89 d8                	mov    %ebx,%eax
f01013b8:	80 78 ff 25          	cmpb   $0x25,-0x1(%eax)
f01013bc:	74 05                	je     f01013c3 <.L20+0x1b>
f01013be:	83 e8 01             	sub    $0x1,%eax
f01013c1:	eb f5                	jmp    f01013b8 <.L20+0x10>
f01013c3:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f01013c6:	e9 73 ff ff ff       	jmp    f010133e <.L25+0x45>

f01013cb <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
f01013cb:	55                   	push   %ebp
f01013cc:	89 e5                	mov    %esp,%ebp
f01013ce:	53                   	push   %ebx
f01013cf:	83 ec 14             	sub    $0x14,%esp
f01013d2:	e8 e5 ed ff ff       	call   f01001bc <__x86.get_pc_thunk.bx>
f01013d7:	81 c3 31 ff 00 00    	add    $0xff31,%ebx
f01013dd:	8b 45 08             	mov    0x8(%ebp),%eax
f01013e0:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
f01013e3:	89 45 ec             	mov    %eax,-0x14(%ebp)
f01013e6:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
f01013ea:	89 4d f0             	mov    %ecx,-0x10(%ebp)
f01013ed:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
f01013f4:	85 c0                	test   %eax,%eax
f01013f6:	74 2b                	je     f0101423 <vsnprintf+0x58>
f01013f8:	85 d2                	test   %edx,%edx
f01013fa:	7e 27                	jle    f0101423 <vsnprintf+0x58>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
f01013fc:	ff 75 14             	push   0x14(%ebp)
f01013ff:	ff 75 10             	push   0x10(%ebp)
f0101402:	8d 45 ec             	lea    -0x14(%ebp),%eax
f0101405:	50                   	push   %eax
f0101406:	8d 83 e5 fb fe ff    	lea    -0x1041b(%ebx),%eax
f010140c:	50                   	push   %eax
f010140d:	e8 15 fb ff ff       	call   f0100f27 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
f0101412:	8b 45 ec             	mov    -0x14(%ebp),%eax
f0101415:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
f0101418:	8b 45 f4             	mov    -0xc(%ebp),%eax
f010141b:	83 c4 10             	add    $0x10,%esp
}
f010141e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0101421:	c9                   	leave  
f0101422:	c3                   	ret    
		return -E_INVAL;
f0101423:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
f0101428:	eb f4                	jmp    f010141e <vsnprintf+0x53>

f010142a <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
f010142a:	55                   	push   %ebp
f010142b:	89 e5                	mov    %esp,%ebp
f010142d:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
f0101430:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
f0101433:	50                   	push   %eax
f0101434:	ff 75 10             	push   0x10(%ebp)
f0101437:	ff 75 0c             	push   0xc(%ebp)
f010143a:	ff 75 08             	push   0x8(%ebp)
f010143d:	e8 89 ff ff ff       	call   f01013cb <vsnprintf>
	va_end(ap);

	return rc;
}
f0101442:	c9                   	leave  
f0101443:	c3                   	ret    

f0101444 <__x86.get_pc_thunk.cx>:
f0101444:	8b 0c 24             	mov    (%esp),%ecx
f0101447:	c3                   	ret    

f0101448 <readline>:
#define BUFLEN 1024
static char buf[BUFLEN];

char *
readline(const char *prompt)
{
f0101448:	55                   	push   %ebp
f0101449:	89 e5                	mov    %esp,%ebp
f010144b:	57                   	push   %edi
f010144c:	56                   	push   %esi
f010144d:	53                   	push   %ebx
f010144e:	83 ec 1c             	sub    $0x1c,%esp
f0101451:	e8 66 ed ff ff       	call   f01001bc <__x86.get_pc_thunk.bx>
f0101456:	81 c3 b2 fe 00 00    	add    $0xfeb2,%ebx
f010145c:	8b 45 08             	mov    0x8(%ebp),%eax
	int i, c, echoing;

	if (prompt != NULL)
f010145f:	85 c0                	test   %eax,%eax
f0101461:	74 13                	je     f0101476 <readline+0x2e>
		cprintf("%s", prompt);
f0101463:	83 ec 08             	sub    $0x8,%esp
f0101466:	50                   	push   %eax
f0101467:	8d 83 7b 0d ff ff    	lea    -0xf285(%ebx),%eax
f010146d:	50                   	push   %eax
f010146e:	e8 65 f6 ff ff       	call   f0100ad8 <cprintf>
f0101473:	83 c4 10             	add    $0x10,%esp

	i = 0;
	echoing = iscons(0);
f0101476:	83 ec 0c             	sub    $0xc,%esp
f0101479:	6a 00                	push   $0x0
f010147b:	e8 c8 f2 ff ff       	call   f0100748 <iscons>
f0101480:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f0101483:	83 c4 10             	add    $0x10,%esp
	i = 0;
f0101486:	bf 00 00 00 00       	mov    $0x0,%edi
				cputchar('\b');
			i--;
		} else if (c >= ' ' && i < BUFLEN-1) {
			if (echoing)
				cputchar(c);
			buf[i++] = c;
f010148b:	8d 83 b8 1f 00 00    	lea    0x1fb8(%ebx),%eax
f0101491:	89 45 e0             	mov    %eax,-0x20(%ebp)
f0101494:	eb 45                	jmp    f01014db <readline+0x93>
			cprintf("read error: %e\n", c);
f0101496:	83 ec 08             	sub    $0x8,%esp
f0101499:	50                   	push   %eax
f010149a:	8d 83 40 0f ff ff    	lea    -0xf0c0(%ebx),%eax
f01014a0:	50                   	push   %eax
f01014a1:	e8 32 f6 ff ff       	call   f0100ad8 <cprintf>
			return NULL;
f01014a6:	83 c4 10             	add    $0x10,%esp
f01014a9:	b8 00 00 00 00       	mov    $0x0,%eax
				cputchar('\n');
			buf[i] = 0;
			return buf;
		}
	}
}
f01014ae:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01014b1:	5b                   	pop    %ebx
f01014b2:	5e                   	pop    %esi
f01014b3:	5f                   	pop    %edi
f01014b4:	5d                   	pop    %ebp
f01014b5:	c3                   	ret    
			if (echoing)
f01014b6:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
f01014ba:	75 05                	jne    f01014c1 <readline+0x79>
			i--;
f01014bc:	83 ef 01             	sub    $0x1,%edi
f01014bf:	eb 1a                	jmp    f01014db <readline+0x93>
				cputchar('\b');
f01014c1:	83 ec 0c             	sub    $0xc,%esp
f01014c4:	6a 08                	push   $0x8
f01014c6:	e8 5c f2 ff ff       	call   f0100727 <cputchar>
f01014cb:	83 c4 10             	add    $0x10,%esp
f01014ce:	eb ec                	jmp    f01014bc <readline+0x74>
			buf[i++] = c;
f01014d0:	8b 4d e0             	mov    -0x20(%ebp),%ecx
f01014d3:	89 f0                	mov    %esi,%eax
f01014d5:	88 04 39             	mov    %al,(%ecx,%edi,1)
f01014d8:	8d 7f 01             	lea    0x1(%edi),%edi
		c = getchar();
f01014db:	e8 57 f2 ff ff       	call   f0100737 <getchar>
f01014e0:	89 c6                	mov    %eax,%esi
		if (c < 0) {
f01014e2:	85 c0                	test   %eax,%eax
f01014e4:	78 b0                	js     f0101496 <readline+0x4e>
		} else if ((c == '\b' || c == '\x7f') && i > 0) {
f01014e6:	83 f8 08             	cmp    $0x8,%eax
f01014e9:	0f 94 c0             	sete   %al
f01014ec:	83 fe 7f             	cmp    $0x7f,%esi
f01014ef:	0f 94 c2             	sete   %dl
f01014f2:	08 d0                	or     %dl,%al
f01014f4:	74 04                	je     f01014fa <readline+0xb2>
f01014f6:	85 ff                	test   %edi,%edi
f01014f8:	7f bc                	jg     f01014b6 <readline+0x6e>
		} else if (c >= ' ' && i < BUFLEN-1) {
f01014fa:	83 fe 1f             	cmp    $0x1f,%esi
f01014fd:	7e 1c                	jle    f010151b <readline+0xd3>
f01014ff:	81 ff fe 03 00 00    	cmp    $0x3fe,%edi
f0101505:	7f 14                	jg     f010151b <readline+0xd3>
			if (echoing)
f0101507:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
f010150b:	74 c3                	je     f01014d0 <readline+0x88>
				cputchar(c);
f010150d:	83 ec 0c             	sub    $0xc,%esp
f0101510:	56                   	push   %esi
f0101511:	e8 11 f2 ff ff       	call   f0100727 <cputchar>
f0101516:	83 c4 10             	add    $0x10,%esp
f0101519:	eb b5                	jmp    f01014d0 <readline+0x88>
		} else if (c == '\n' || c == '\r') {
f010151b:	83 fe 0a             	cmp    $0xa,%esi
f010151e:	74 05                	je     f0101525 <readline+0xdd>
f0101520:	83 fe 0d             	cmp    $0xd,%esi
f0101523:	75 b6                	jne    f01014db <readline+0x93>
			if (echoing)
f0101525:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
f0101529:	75 13                	jne    f010153e <readline+0xf6>
			buf[i] = 0;
f010152b:	c6 84 3b b8 1f 00 00 	movb   $0x0,0x1fb8(%ebx,%edi,1)
f0101532:	00 
			return buf;
f0101533:	8d 83 b8 1f 00 00    	lea    0x1fb8(%ebx),%eax
f0101539:	e9 70 ff ff ff       	jmp    f01014ae <readline+0x66>
				cputchar('\n');
f010153e:	83 ec 0c             	sub    $0xc,%esp
f0101541:	6a 0a                	push   $0xa
f0101543:	e8 df f1 ff ff       	call   f0100727 <cputchar>
f0101548:	83 c4 10             	add    $0x10,%esp
f010154b:	eb de                	jmp    f010152b <readline+0xe3>

f010154d <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
f010154d:	55                   	push   %ebp
f010154e:	89 e5                	mov    %esp,%ebp
f0101550:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
f0101553:	b8 00 00 00 00       	mov    $0x0,%eax
f0101558:	eb 03                	jmp    f010155d <strlen+0x10>
		n++;
f010155a:	83 c0 01             	add    $0x1,%eax
	for (n = 0; *s != '\0'; s++)
f010155d:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
f0101561:	75 f7                	jne    f010155a <strlen+0xd>
	return n;
}
f0101563:	5d                   	pop    %ebp
f0101564:	c3                   	ret    

f0101565 <strnlen>:

int
strnlen(const char *s, size_t size)
{
f0101565:	55                   	push   %ebp
f0101566:	89 e5                	mov    %esp,%ebp
f0101568:	8b 4d 08             	mov    0x8(%ebp),%ecx
f010156b:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
f010156e:	b8 00 00 00 00       	mov    $0x0,%eax
f0101573:	eb 03                	jmp    f0101578 <strnlen+0x13>
		n++;
f0101575:	83 c0 01             	add    $0x1,%eax
	for (n = 0; size > 0 && *s != '\0'; s++, size--)
f0101578:	39 d0                	cmp    %edx,%eax
f010157a:	74 08                	je     f0101584 <strnlen+0x1f>
f010157c:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
f0101580:	75 f3                	jne    f0101575 <strnlen+0x10>
f0101582:	89 c2                	mov    %eax,%edx
	return n;
}
f0101584:	89 d0                	mov    %edx,%eax
f0101586:	5d                   	pop    %ebp
f0101587:	c3                   	ret    

f0101588 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
f0101588:	55                   	push   %ebp
f0101589:	89 e5                	mov    %esp,%ebp
f010158b:	53                   	push   %ebx
f010158c:	8b 4d 08             	mov    0x8(%ebp),%ecx
f010158f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
f0101592:	b8 00 00 00 00       	mov    $0x0,%eax
f0101597:	0f b6 14 03          	movzbl (%ebx,%eax,1),%edx
f010159b:	88 14 01             	mov    %dl,(%ecx,%eax,1)
f010159e:	83 c0 01             	add    $0x1,%eax
f01015a1:	84 d2                	test   %dl,%dl
f01015a3:	75 f2                	jne    f0101597 <strcpy+0xf>
		/* do nothing */;
	return ret;
}
f01015a5:	89 c8                	mov    %ecx,%eax
f01015a7:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f01015aa:	c9                   	leave  
f01015ab:	c3                   	ret    

f01015ac <strcat>:

char *
strcat(char *dst, const char *src)
{
f01015ac:	55                   	push   %ebp
f01015ad:	89 e5                	mov    %esp,%ebp
f01015af:	53                   	push   %ebx
f01015b0:	83 ec 10             	sub    $0x10,%esp
f01015b3:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
f01015b6:	53                   	push   %ebx
f01015b7:	e8 91 ff ff ff       	call   f010154d <strlen>
f01015bc:	83 c4 08             	add    $0x8,%esp
	strcpy(dst + len, src);
f01015bf:	ff 75 0c             	push   0xc(%ebp)
f01015c2:	01 d8                	add    %ebx,%eax
f01015c4:	50                   	push   %eax
f01015c5:	e8 be ff ff ff       	call   f0101588 <strcpy>
	return dst;
}
f01015ca:	89 d8                	mov    %ebx,%eax
f01015cc:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f01015cf:	c9                   	leave  
f01015d0:	c3                   	ret    

f01015d1 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
f01015d1:	55                   	push   %ebp
f01015d2:	89 e5                	mov    %esp,%ebp
f01015d4:	56                   	push   %esi
f01015d5:	53                   	push   %ebx
f01015d6:	8b 75 08             	mov    0x8(%ebp),%esi
f01015d9:	8b 55 0c             	mov    0xc(%ebp),%edx
f01015dc:	89 f3                	mov    %esi,%ebx
f01015de:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
f01015e1:	89 f0                	mov    %esi,%eax
f01015e3:	eb 0f                	jmp    f01015f4 <strncpy+0x23>
		*dst++ = *src;
f01015e5:	83 c0 01             	add    $0x1,%eax
f01015e8:	0f b6 0a             	movzbl (%edx),%ecx
f01015eb:	88 48 ff             	mov    %cl,-0x1(%eax)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
f01015ee:	80 f9 01             	cmp    $0x1,%cl
f01015f1:	83 da ff             	sbb    $0xffffffff,%edx
	for (i = 0; i < size; i++) {
f01015f4:	39 d8                	cmp    %ebx,%eax
f01015f6:	75 ed                	jne    f01015e5 <strncpy+0x14>
	}
	return ret;
}
f01015f8:	89 f0                	mov    %esi,%eax
f01015fa:	5b                   	pop    %ebx
f01015fb:	5e                   	pop    %esi
f01015fc:	5d                   	pop    %ebp
f01015fd:	c3                   	ret    

f01015fe <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
f01015fe:	55                   	push   %ebp
f01015ff:	89 e5                	mov    %esp,%ebp
f0101601:	56                   	push   %esi
f0101602:	53                   	push   %ebx
f0101603:	8b 75 08             	mov    0x8(%ebp),%esi
f0101606:	8b 4d 0c             	mov    0xc(%ebp),%ecx
f0101609:	8b 55 10             	mov    0x10(%ebp),%edx
f010160c:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
f010160e:	85 d2                	test   %edx,%edx
f0101610:	74 21                	je     f0101633 <strlcpy+0x35>
f0101612:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
f0101616:	89 f2                	mov    %esi,%edx
f0101618:	eb 09                	jmp    f0101623 <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
f010161a:	83 c1 01             	add    $0x1,%ecx
f010161d:	83 c2 01             	add    $0x1,%edx
f0101620:	88 5a ff             	mov    %bl,-0x1(%edx)
		while (--size > 0 && *src != '\0')
f0101623:	39 c2                	cmp    %eax,%edx
f0101625:	74 09                	je     f0101630 <strlcpy+0x32>
f0101627:	0f b6 19             	movzbl (%ecx),%ebx
f010162a:	84 db                	test   %bl,%bl
f010162c:	75 ec                	jne    f010161a <strlcpy+0x1c>
f010162e:	89 d0                	mov    %edx,%eax
		*dst = '\0';
f0101630:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
f0101633:	29 f0                	sub    %esi,%eax
}
f0101635:	5b                   	pop    %ebx
f0101636:	5e                   	pop    %esi
f0101637:	5d                   	pop    %ebp
f0101638:	c3                   	ret    

f0101639 <strcmp>:

int
strcmp(const char *p, const char *q)
{
f0101639:	55                   	push   %ebp
f010163a:	89 e5                	mov    %esp,%ebp
f010163c:	8b 4d 08             	mov    0x8(%ebp),%ecx
f010163f:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
f0101642:	eb 06                	jmp    f010164a <strcmp+0x11>
		p++, q++;
f0101644:	83 c1 01             	add    $0x1,%ecx
f0101647:	83 c2 01             	add    $0x1,%edx
	while (*p && *p == *q)
f010164a:	0f b6 01             	movzbl (%ecx),%eax
f010164d:	84 c0                	test   %al,%al
f010164f:	74 04                	je     f0101655 <strcmp+0x1c>
f0101651:	3a 02                	cmp    (%edx),%al
f0101653:	74 ef                	je     f0101644 <strcmp+0xb>
	return (int) ((unsigned char) *p - (unsigned char) *q);
f0101655:	0f b6 c0             	movzbl %al,%eax
f0101658:	0f b6 12             	movzbl (%edx),%edx
f010165b:	29 d0                	sub    %edx,%eax
}
f010165d:	5d                   	pop    %ebp
f010165e:	c3                   	ret    

f010165f <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
f010165f:	55                   	push   %ebp
f0101660:	89 e5                	mov    %esp,%ebp
f0101662:	53                   	push   %ebx
f0101663:	8b 45 08             	mov    0x8(%ebp),%eax
f0101666:	8b 55 0c             	mov    0xc(%ebp),%edx
f0101669:	89 c3                	mov    %eax,%ebx
f010166b:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
f010166e:	eb 06                	jmp    f0101676 <strncmp+0x17>
		n--, p++, q++;
f0101670:	83 c0 01             	add    $0x1,%eax
f0101673:	83 c2 01             	add    $0x1,%edx
	while (n > 0 && *p && *p == *q)
f0101676:	39 d8                	cmp    %ebx,%eax
f0101678:	74 18                	je     f0101692 <strncmp+0x33>
f010167a:	0f b6 08             	movzbl (%eax),%ecx
f010167d:	84 c9                	test   %cl,%cl
f010167f:	74 04                	je     f0101685 <strncmp+0x26>
f0101681:	3a 0a                	cmp    (%edx),%cl
f0101683:	74 eb                	je     f0101670 <strncmp+0x11>
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
f0101685:	0f b6 00             	movzbl (%eax),%eax
f0101688:	0f b6 12             	movzbl (%edx),%edx
f010168b:	29 d0                	sub    %edx,%eax
}
f010168d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0101690:	c9                   	leave  
f0101691:	c3                   	ret    
		return 0;
f0101692:	b8 00 00 00 00       	mov    $0x0,%eax
f0101697:	eb f4                	jmp    f010168d <strncmp+0x2e>

f0101699 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
f0101699:	55                   	push   %ebp
f010169a:	89 e5                	mov    %esp,%ebp
f010169c:	8b 45 08             	mov    0x8(%ebp),%eax
f010169f:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
f01016a3:	eb 03                	jmp    f01016a8 <strchr+0xf>
f01016a5:	83 c0 01             	add    $0x1,%eax
f01016a8:	0f b6 10             	movzbl (%eax),%edx
f01016ab:	84 d2                	test   %dl,%dl
f01016ad:	74 06                	je     f01016b5 <strchr+0x1c>
		if (*s == c)
f01016af:	38 ca                	cmp    %cl,%dl
f01016b1:	75 f2                	jne    f01016a5 <strchr+0xc>
f01016b3:	eb 05                	jmp    f01016ba <strchr+0x21>
			return (char *) s;
	return 0;
f01016b5:	b8 00 00 00 00       	mov    $0x0,%eax
}
f01016ba:	5d                   	pop    %ebp
f01016bb:	c3                   	ret    

f01016bc <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
f01016bc:	55                   	push   %ebp
f01016bd:	89 e5                	mov    %esp,%ebp
f01016bf:	8b 45 08             	mov    0x8(%ebp),%eax
f01016c2:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
f01016c6:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
f01016c9:	38 ca                	cmp    %cl,%dl
f01016cb:	74 09                	je     f01016d6 <strfind+0x1a>
f01016cd:	84 d2                	test   %dl,%dl
f01016cf:	74 05                	je     f01016d6 <strfind+0x1a>
	for (; *s; s++)
f01016d1:	83 c0 01             	add    $0x1,%eax
f01016d4:	eb f0                	jmp    f01016c6 <strfind+0xa>
			break;
	return (char *) s;
}
f01016d6:	5d                   	pop    %ebp
f01016d7:	c3                   	ret    

f01016d8 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
f01016d8:	55                   	push   %ebp
f01016d9:	89 e5                	mov    %esp,%ebp
f01016db:	57                   	push   %edi
f01016dc:	56                   	push   %esi
f01016dd:	53                   	push   %ebx
f01016de:	8b 7d 08             	mov    0x8(%ebp),%edi
f01016e1:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
f01016e4:	85 c9                	test   %ecx,%ecx
f01016e6:	74 2f                	je     f0101717 <memset+0x3f>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
f01016e8:	89 f8                	mov    %edi,%eax
f01016ea:	09 c8                	or     %ecx,%eax
f01016ec:	a8 03                	test   $0x3,%al
f01016ee:	75 21                	jne    f0101711 <memset+0x39>
		c &= 0xFF;
f01016f0:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
f01016f4:	89 d0                	mov    %edx,%eax
f01016f6:	c1 e0 08             	shl    $0x8,%eax
f01016f9:	89 d3                	mov    %edx,%ebx
f01016fb:	c1 e3 18             	shl    $0x18,%ebx
f01016fe:	89 d6                	mov    %edx,%esi
f0101700:	c1 e6 10             	shl    $0x10,%esi
f0101703:	09 f3                	or     %esi,%ebx
f0101705:	09 da                	or     %ebx,%edx
f0101707:	09 d0                	or     %edx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
f0101709:	c1 e9 02             	shr    $0x2,%ecx
		asm volatile("cld; rep stosl\n"
f010170c:	fc                   	cld    
f010170d:	f3 ab                	rep stos %eax,%es:(%edi)
f010170f:	eb 06                	jmp    f0101717 <memset+0x3f>
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
f0101711:	8b 45 0c             	mov    0xc(%ebp),%eax
f0101714:	fc                   	cld    
f0101715:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
f0101717:	89 f8                	mov    %edi,%eax
f0101719:	5b                   	pop    %ebx
f010171a:	5e                   	pop    %esi
f010171b:	5f                   	pop    %edi
f010171c:	5d                   	pop    %ebp
f010171d:	c3                   	ret    

f010171e <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
f010171e:	55                   	push   %ebp
f010171f:	89 e5                	mov    %esp,%ebp
f0101721:	57                   	push   %edi
f0101722:	56                   	push   %esi
f0101723:	8b 45 08             	mov    0x8(%ebp),%eax
f0101726:	8b 75 0c             	mov    0xc(%ebp),%esi
f0101729:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
f010172c:	39 c6                	cmp    %eax,%esi
f010172e:	73 32                	jae    f0101762 <memmove+0x44>
f0101730:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
f0101733:	39 c2                	cmp    %eax,%edx
f0101735:	76 2b                	jbe    f0101762 <memmove+0x44>
		s += n;
		d += n;
f0101737:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
f010173a:	89 d6                	mov    %edx,%esi
f010173c:	09 fe                	or     %edi,%esi
f010173e:	09 ce                	or     %ecx,%esi
f0101740:	f7 c6 03 00 00 00    	test   $0x3,%esi
f0101746:	75 0e                	jne    f0101756 <memmove+0x38>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
f0101748:	83 ef 04             	sub    $0x4,%edi
f010174b:	8d 72 fc             	lea    -0x4(%edx),%esi
f010174e:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("std; rep movsl\n"
f0101751:	fd                   	std    
f0101752:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
f0101754:	eb 09                	jmp    f010175f <memmove+0x41>
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
f0101756:	83 ef 01             	sub    $0x1,%edi
f0101759:	8d 72 ff             	lea    -0x1(%edx),%esi
			asm volatile("std; rep movsb\n"
f010175c:	fd                   	std    
f010175d:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
f010175f:	fc                   	cld    
f0101760:	eb 1a                	jmp    f010177c <memmove+0x5e>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
f0101762:	89 f2                	mov    %esi,%edx
f0101764:	09 c2                	or     %eax,%edx
f0101766:	09 ca                	or     %ecx,%edx
f0101768:	f6 c2 03             	test   $0x3,%dl
f010176b:	75 0a                	jne    f0101777 <memmove+0x59>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
f010176d:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("cld; rep movsl\n"
f0101770:	89 c7                	mov    %eax,%edi
f0101772:	fc                   	cld    
f0101773:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
f0101775:	eb 05                	jmp    f010177c <memmove+0x5e>
		else
			asm volatile("cld; rep movsb\n"
f0101777:	89 c7                	mov    %eax,%edi
f0101779:	fc                   	cld    
f010177a:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
f010177c:	5e                   	pop    %esi
f010177d:	5f                   	pop    %edi
f010177e:	5d                   	pop    %ebp
f010177f:	c3                   	ret    

f0101780 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
f0101780:	55                   	push   %ebp
f0101781:	89 e5                	mov    %esp,%ebp
f0101783:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
f0101786:	ff 75 10             	push   0x10(%ebp)
f0101789:	ff 75 0c             	push   0xc(%ebp)
f010178c:	ff 75 08             	push   0x8(%ebp)
f010178f:	e8 8a ff ff ff       	call   f010171e <memmove>
}
f0101794:	c9                   	leave  
f0101795:	c3                   	ret    

f0101796 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
f0101796:	55                   	push   %ebp
f0101797:	89 e5                	mov    %esp,%ebp
f0101799:	56                   	push   %esi
f010179a:	53                   	push   %ebx
f010179b:	8b 45 08             	mov    0x8(%ebp),%eax
f010179e:	8b 55 0c             	mov    0xc(%ebp),%edx
f01017a1:	89 c6                	mov    %eax,%esi
f01017a3:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
f01017a6:	eb 06                	jmp    f01017ae <memcmp+0x18>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
f01017a8:	83 c0 01             	add    $0x1,%eax
f01017ab:	83 c2 01             	add    $0x1,%edx
	while (n-- > 0) {
f01017ae:	39 f0                	cmp    %esi,%eax
f01017b0:	74 14                	je     f01017c6 <memcmp+0x30>
		if (*s1 != *s2)
f01017b2:	0f b6 08             	movzbl (%eax),%ecx
f01017b5:	0f b6 1a             	movzbl (%edx),%ebx
f01017b8:	38 d9                	cmp    %bl,%cl
f01017ba:	74 ec                	je     f01017a8 <memcmp+0x12>
			return (int) *s1 - (int) *s2;
f01017bc:	0f b6 c1             	movzbl %cl,%eax
f01017bf:	0f b6 db             	movzbl %bl,%ebx
f01017c2:	29 d8                	sub    %ebx,%eax
f01017c4:	eb 05                	jmp    f01017cb <memcmp+0x35>
	}

	return 0;
f01017c6:	b8 00 00 00 00       	mov    $0x0,%eax
}
f01017cb:	5b                   	pop    %ebx
f01017cc:	5e                   	pop    %esi
f01017cd:	5d                   	pop    %ebp
f01017ce:	c3                   	ret    

f01017cf <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
f01017cf:	55                   	push   %ebp
f01017d0:	89 e5                	mov    %esp,%ebp
f01017d2:	8b 45 08             	mov    0x8(%ebp),%eax
f01017d5:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
f01017d8:	89 c2                	mov    %eax,%edx
f01017da:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
f01017dd:	eb 03                	jmp    f01017e2 <memfind+0x13>
f01017df:	83 c0 01             	add    $0x1,%eax
f01017e2:	39 d0                	cmp    %edx,%eax
f01017e4:	73 04                	jae    f01017ea <memfind+0x1b>
		if (*(const unsigned char *) s == (unsigned char) c)
f01017e6:	38 08                	cmp    %cl,(%eax)
f01017e8:	75 f5                	jne    f01017df <memfind+0x10>
			break;
	return (void *) s;
}
f01017ea:	5d                   	pop    %ebp
f01017eb:	c3                   	ret    

f01017ec <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
f01017ec:	55                   	push   %ebp
f01017ed:	89 e5                	mov    %esp,%ebp
f01017ef:	57                   	push   %edi
f01017f0:	56                   	push   %esi
f01017f1:	53                   	push   %ebx
f01017f2:	8b 55 08             	mov    0x8(%ebp),%edx
f01017f5:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
f01017f8:	eb 03                	jmp    f01017fd <strtol+0x11>
		s++;
f01017fa:	83 c2 01             	add    $0x1,%edx
	while (*s == ' ' || *s == '\t')
f01017fd:	0f b6 02             	movzbl (%edx),%eax
f0101800:	3c 20                	cmp    $0x20,%al
f0101802:	74 f6                	je     f01017fa <strtol+0xe>
f0101804:	3c 09                	cmp    $0x9,%al
f0101806:	74 f2                	je     f01017fa <strtol+0xe>

	// plus/minus sign
	if (*s == '+')
f0101808:	3c 2b                	cmp    $0x2b,%al
f010180a:	74 2a                	je     f0101836 <strtol+0x4a>
	int neg = 0;
f010180c:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
f0101811:	3c 2d                	cmp    $0x2d,%al
f0101813:	74 2b                	je     f0101840 <strtol+0x54>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
f0101815:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
f010181b:	75 0f                	jne    f010182c <strtol+0x40>
f010181d:	80 3a 30             	cmpb   $0x30,(%edx)
f0101820:	74 28                	je     f010184a <strtol+0x5e>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
		s++, base = 8;
	else if (base == 0)
		base = 10;
f0101822:	85 db                	test   %ebx,%ebx
f0101824:	b8 0a 00 00 00       	mov    $0xa,%eax
f0101829:	0f 44 d8             	cmove  %eax,%ebx
f010182c:	b9 00 00 00 00       	mov    $0x0,%ecx
f0101831:	89 5d 10             	mov    %ebx,0x10(%ebp)
f0101834:	eb 46                	jmp    f010187c <strtol+0x90>
		s++;
f0101836:	83 c2 01             	add    $0x1,%edx
	int neg = 0;
f0101839:	bf 00 00 00 00       	mov    $0x0,%edi
f010183e:	eb d5                	jmp    f0101815 <strtol+0x29>
		s++, neg = 1;
f0101840:	83 c2 01             	add    $0x1,%edx
f0101843:	bf 01 00 00 00       	mov    $0x1,%edi
f0101848:	eb cb                	jmp    f0101815 <strtol+0x29>
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
f010184a:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
f010184e:	74 0e                	je     f010185e <strtol+0x72>
	else if (base == 0 && s[0] == '0')
f0101850:	85 db                	test   %ebx,%ebx
f0101852:	75 d8                	jne    f010182c <strtol+0x40>
		s++, base = 8;
f0101854:	83 c2 01             	add    $0x1,%edx
f0101857:	bb 08 00 00 00       	mov    $0x8,%ebx
f010185c:	eb ce                	jmp    f010182c <strtol+0x40>
		s += 2, base = 16;
f010185e:	83 c2 02             	add    $0x2,%edx
f0101861:	bb 10 00 00 00       	mov    $0x10,%ebx
f0101866:	eb c4                	jmp    f010182c <strtol+0x40>
	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
f0101868:	0f be c0             	movsbl %al,%eax
f010186b:	83 e8 30             	sub    $0x30,%eax
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
f010186e:	3b 45 10             	cmp    0x10(%ebp),%eax
f0101871:	7d 3a                	jge    f01018ad <strtol+0xc1>
			break;
		s++, val = (val * base) + dig;
f0101873:	83 c2 01             	add    $0x1,%edx
f0101876:	0f af 4d 10          	imul   0x10(%ebp),%ecx
f010187a:	01 c1                	add    %eax,%ecx
		if (*s >= '0' && *s <= '9')
f010187c:	0f b6 02             	movzbl (%edx),%eax
f010187f:	8d 70 d0             	lea    -0x30(%eax),%esi
f0101882:	89 f3                	mov    %esi,%ebx
f0101884:	80 fb 09             	cmp    $0x9,%bl
f0101887:	76 df                	jbe    f0101868 <strtol+0x7c>
		else if (*s >= 'a' && *s <= 'z')
f0101889:	8d 70 9f             	lea    -0x61(%eax),%esi
f010188c:	89 f3                	mov    %esi,%ebx
f010188e:	80 fb 19             	cmp    $0x19,%bl
f0101891:	77 08                	ja     f010189b <strtol+0xaf>
			dig = *s - 'a' + 10;
f0101893:	0f be c0             	movsbl %al,%eax
f0101896:	83 e8 57             	sub    $0x57,%eax
f0101899:	eb d3                	jmp    f010186e <strtol+0x82>
		else if (*s >= 'A' && *s <= 'Z')
f010189b:	8d 70 bf             	lea    -0x41(%eax),%esi
f010189e:	89 f3                	mov    %esi,%ebx
f01018a0:	80 fb 19             	cmp    $0x19,%bl
f01018a3:	77 08                	ja     f01018ad <strtol+0xc1>
			dig = *s - 'A' + 10;
f01018a5:	0f be c0             	movsbl %al,%eax
f01018a8:	83 e8 37             	sub    $0x37,%eax
f01018ab:	eb c1                	jmp    f010186e <strtol+0x82>
		// we don't properly detect overflow!
	}

	if (endptr)
f01018ad:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
f01018b1:	74 05                	je     f01018b8 <strtol+0xcc>
		*endptr = (char *) s;
f01018b3:	8b 45 0c             	mov    0xc(%ebp),%eax
f01018b6:	89 10                	mov    %edx,(%eax)
	return (neg ? -val : val);
f01018b8:	89 c8                	mov    %ecx,%eax
f01018ba:	f7 d8                	neg    %eax
f01018bc:	85 ff                	test   %edi,%edi
f01018be:	0f 45 c8             	cmovne %eax,%ecx
}
f01018c1:	89 c8                	mov    %ecx,%eax
f01018c3:	5b                   	pop    %ebx
f01018c4:	5e                   	pop    %esi
f01018c5:	5f                   	pop    %edi
f01018c6:	5d                   	pop    %ebp
f01018c7:	c3                   	ret    
f01018c8:	66 90                	xchg   %ax,%ax
f01018ca:	66 90                	xchg   %ax,%ax
f01018cc:	66 90                	xchg   %ax,%ax
f01018ce:	66 90                	xchg   %ax,%ax

f01018d0 <__udivdi3>:
f01018d0:	f3 0f 1e fb          	endbr32 
f01018d4:	55                   	push   %ebp
f01018d5:	57                   	push   %edi
f01018d6:	56                   	push   %esi
f01018d7:	53                   	push   %ebx
f01018d8:	83 ec 1c             	sub    $0x1c,%esp
f01018db:	8b 44 24 3c          	mov    0x3c(%esp),%eax
f01018df:	8b 6c 24 30          	mov    0x30(%esp),%ebp
f01018e3:	8b 74 24 34          	mov    0x34(%esp),%esi
f01018e7:	8b 5c 24 38          	mov    0x38(%esp),%ebx
f01018eb:	85 c0                	test   %eax,%eax
f01018ed:	75 19                	jne    f0101908 <__udivdi3+0x38>
f01018ef:	39 f3                	cmp    %esi,%ebx
f01018f1:	76 4d                	jbe    f0101940 <__udivdi3+0x70>
f01018f3:	31 ff                	xor    %edi,%edi
f01018f5:	89 e8                	mov    %ebp,%eax
f01018f7:	89 f2                	mov    %esi,%edx
f01018f9:	f7 f3                	div    %ebx
f01018fb:	89 fa                	mov    %edi,%edx
f01018fd:	83 c4 1c             	add    $0x1c,%esp
f0101900:	5b                   	pop    %ebx
f0101901:	5e                   	pop    %esi
f0101902:	5f                   	pop    %edi
f0101903:	5d                   	pop    %ebp
f0101904:	c3                   	ret    
f0101905:	8d 76 00             	lea    0x0(%esi),%esi
f0101908:	39 f0                	cmp    %esi,%eax
f010190a:	76 14                	jbe    f0101920 <__udivdi3+0x50>
f010190c:	31 ff                	xor    %edi,%edi
f010190e:	31 c0                	xor    %eax,%eax
f0101910:	89 fa                	mov    %edi,%edx
f0101912:	83 c4 1c             	add    $0x1c,%esp
f0101915:	5b                   	pop    %ebx
f0101916:	5e                   	pop    %esi
f0101917:	5f                   	pop    %edi
f0101918:	5d                   	pop    %ebp
f0101919:	c3                   	ret    
f010191a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
f0101920:	0f bd f8             	bsr    %eax,%edi
f0101923:	83 f7 1f             	xor    $0x1f,%edi
f0101926:	75 48                	jne    f0101970 <__udivdi3+0xa0>
f0101928:	39 f0                	cmp    %esi,%eax
f010192a:	72 06                	jb     f0101932 <__udivdi3+0x62>
f010192c:	31 c0                	xor    %eax,%eax
f010192e:	39 eb                	cmp    %ebp,%ebx
f0101930:	77 de                	ja     f0101910 <__udivdi3+0x40>
f0101932:	b8 01 00 00 00       	mov    $0x1,%eax
f0101937:	eb d7                	jmp    f0101910 <__udivdi3+0x40>
f0101939:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
f0101940:	89 d9                	mov    %ebx,%ecx
f0101942:	85 db                	test   %ebx,%ebx
f0101944:	75 0b                	jne    f0101951 <__udivdi3+0x81>
f0101946:	b8 01 00 00 00       	mov    $0x1,%eax
f010194b:	31 d2                	xor    %edx,%edx
f010194d:	f7 f3                	div    %ebx
f010194f:	89 c1                	mov    %eax,%ecx
f0101951:	31 d2                	xor    %edx,%edx
f0101953:	89 f0                	mov    %esi,%eax
f0101955:	f7 f1                	div    %ecx
f0101957:	89 c6                	mov    %eax,%esi
f0101959:	89 e8                	mov    %ebp,%eax
f010195b:	89 f7                	mov    %esi,%edi
f010195d:	f7 f1                	div    %ecx
f010195f:	89 fa                	mov    %edi,%edx
f0101961:	83 c4 1c             	add    $0x1c,%esp
f0101964:	5b                   	pop    %ebx
f0101965:	5e                   	pop    %esi
f0101966:	5f                   	pop    %edi
f0101967:	5d                   	pop    %ebp
f0101968:	c3                   	ret    
f0101969:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
f0101970:	89 f9                	mov    %edi,%ecx
f0101972:	ba 20 00 00 00       	mov    $0x20,%edx
f0101977:	29 fa                	sub    %edi,%edx
f0101979:	d3 e0                	shl    %cl,%eax
f010197b:	89 44 24 08          	mov    %eax,0x8(%esp)
f010197f:	89 d1                	mov    %edx,%ecx
f0101981:	89 d8                	mov    %ebx,%eax
f0101983:	d3 e8                	shr    %cl,%eax
f0101985:	8b 4c 24 08          	mov    0x8(%esp),%ecx
f0101989:	09 c1                	or     %eax,%ecx
f010198b:	89 f0                	mov    %esi,%eax
f010198d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
f0101991:	89 f9                	mov    %edi,%ecx
f0101993:	d3 e3                	shl    %cl,%ebx
f0101995:	89 d1                	mov    %edx,%ecx
f0101997:	d3 e8                	shr    %cl,%eax
f0101999:	89 f9                	mov    %edi,%ecx
f010199b:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
f010199f:	89 eb                	mov    %ebp,%ebx
f01019a1:	d3 e6                	shl    %cl,%esi
f01019a3:	89 d1                	mov    %edx,%ecx
f01019a5:	d3 eb                	shr    %cl,%ebx
f01019a7:	09 f3                	or     %esi,%ebx
f01019a9:	89 c6                	mov    %eax,%esi
f01019ab:	89 f2                	mov    %esi,%edx
f01019ad:	89 d8                	mov    %ebx,%eax
f01019af:	f7 74 24 08          	divl   0x8(%esp)
f01019b3:	89 d6                	mov    %edx,%esi
f01019b5:	89 c3                	mov    %eax,%ebx
f01019b7:	f7 64 24 0c          	mull   0xc(%esp)
f01019bb:	39 d6                	cmp    %edx,%esi
f01019bd:	72 19                	jb     f01019d8 <__udivdi3+0x108>
f01019bf:	89 f9                	mov    %edi,%ecx
f01019c1:	d3 e5                	shl    %cl,%ebp
f01019c3:	39 c5                	cmp    %eax,%ebp
f01019c5:	73 04                	jae    f01019cb <__udivdi3+0xfb>
f01019c7:	39 d6                	cmp    %edx,%esi
f01019c9:	74 0d                	je     f01019d8 <__udivdi3+0x108>
f01019cb:	89 d8                	mov    %ebx,%eax
f01019cd:	31 ff                	xor    %edi,%edi
f01019cf:	e9 3c ff ff ff       	jmp    f0101910 <__udivdi3+0x40>
f01019d4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f01019d8:	8d 43 ff             	lea    -0x1(%ebx),%eax
f01019db:	31 ff                	xor    %edi,%edi
f01019dd:	e9 2e ff ff ff       	jmp    f0101910 <__udivdi3+0x40>
f01019e2:	66 90                	xchg   %ax,%ax
f01019e4:	66 90                	xchg   %ax,%ax
f01019e6:	66 90                	xchg   %ax,%ax
f01019e8:	66 90                	xchg   %ax,%ax
f01019ea:	66 90                	xchg   %ax,%ax
f01019ec:	66 90                	xchg   %ax,%ax
f01019ee:	66 90                	xchg   %ax,%ax

f01019f0 <__umoddi3>:
f01019f0:	f3 0f 1e fb          	endbr32 
f01019f4:	55                   	push   %ebp
f01019f5:	57                   	push   %edi
f01019f6:	56                   	push   %esi
f01019f7:	53                   	push   %ebx
f01019f8:	83 ec 1c             	sub    $0x1c,%esp
f01019fb:	8b 74 24 30          	mov    0x30(%esp),%esi
f01019ff:	8b 5c 24 34          	mov    0x34(%esp),%ebx
f0101a03:	8b 7c 24 3c          	mov    0x3c(%esp),%edi
f0101a07:	8b 6c 24 38          	mov    0x38(%esp),%ebp
f0101a0b:	89 f0                	mov    %esi,%eax
f0101a0d:	89 da                	mov    %ebx,%edx
f0101a0f:	85 ff                	test   %edi,%edi
f0101a11:	75 15                	jne    f0101a28 <__umoddi3+0x38>
f0101a13:	39 dd                	cmp    %ebx,%ebp
f0101a15:	76 39                	jbe    f0101a50 <__umoddi3+0x60>
f0101a17:	f7 f5                	div    %ebp
f0101a19:	89 d0                	mov    %edx,%eax
f0101a1b:	31 d2                	xor    %edx,%edx
f0101a1d:	83 c4 1c             	add    $0x1c,%esp
f0101a20:	5b                   	pop    %ebx
f0101a21:	5e                   	pop    %esi
f0101a22:	5f                   	pop    %edi
f0101a23:	5d                   	pop    %ebp
f0101a24:	c3                   	ret    
f0101a25:	8d 76 00             	lea    0x0(%esi),%esi
f0101a28:	39 df                	cmp    %ebx,%edi
f0101a2a:	77 f1                	ja     f0101a1d <__umoddi3+0x2d>
f0101a2c:	0f bd cf             	bsr    %edi,%ecx
f0101a2f:	83 f1 1f             	xor    $0x1f,%ecx
f0101a32:	89 4c 24 04          	mov    %ecx,0x4(%esp)
f0101a36:	75 40                	jne    f0101a78 <__umoddi3+0x88>
f0101a38:	39 df                	cmp    %ebx,%edi
f0101a3a:	72 04                	jb     f0101a40 <__umoddi3+0x50>
f0101a3c:	39 f5                	cmp    %esi,%ebp
f0101a3e:	77 dd                	ja     f0101a1d <__umoddi3+0x2d>
f0101a40:	89 da                	mov    %ebx,%edx
f0101a42:	89 f0                	mov    %esi,%eax
f0101a44:	29 e8                	sub    %ebp,%eax
f0101a46:	19 fa                	sbb    %edi,%edx
f0101a48:	eb d3                	jmp    f0101a1d <__umoddi3+0x2d>
f0101a4a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
f0101a50:	89 e9                	mov    %ebp,%ecx
f0101a52:	85 ed                	test   %ebp,%ebp
f0101a54:	75 0b                	jne    f0101a61 <__umoddi3+0x71>
f0101a56:	b8 01 00 00 00       	mov    $0x1,%eax
f0101a5b:	31 d2                	xor    %edx,%edx
f0101a5d:	f7 f5                	div    %ebp
f0101a5f:	89 c1                	mov    %eax,%ecx
f0101a61:	89 d8                	mov    %ebx,%eax
f0101a63:	31 d2                	xor    %edx,%edx
f0101a65:	f7 f1                	div    %ecx
f0101a67:	89 f0                	mov    %esi,%eax
f0101a69:	f7 f1                	div    %ecx
f0101a6b:	89 d0                	mov    %edx,%eax
f0101a6d:	31 d2                	xor    %edx,%edx
f0101a6f:	eb ac                	jmp    f0101a1d <__umoddi3+0x2d>
f0101a71:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
f0101a78:	8b 44 24 04          	mov    0x4(%esp),%eax
f0101a7c:	ba 20 00 00 00       	mov    $0x20,%edx
f0101a81:	29 c2                	sub    %eax,%edx
f0101a83:	89 c1                	mov    %eax,%ecx
f0101a85:	89 e8                	mov    %ebp,%eax
f0101a87:	d3 e7                	shl    %cl,%edi
f0101a89:	89 d1                	mov    %edx,%ecx
f0101a8b:	89 54 24 0c          	mov    %edx,0xc(%esp)
f0101a8f:	d3 e8                	shr    %cl,%eax
f0101a91:	89 c1                	mov    %eax,%ecx
f0101a93:	8b 44 24 04          	mov    0x4(%esp),%eax
f0101a97:	09 f9                	or     %edi,%ecx
f0101a99:	89 df                	mov    %ebx,%edi
f0101a9b:	89 4c 24 08          	mov    %ecx,0x8(%esp)
f0101a9f:	89 c1                	mov    %eax,%ecx
f0101aa1:	d3 e5                	shl    %cl,%ebp
f0101aa3:	89 d1                	mov    %edx,%ecx
f0101aa5:	d3 ef                	shr    %cl,%edi
f0101aa7:	89 c1                	mov    %eax,%ecx
f0101aa9:	89 f0                	mov    %esi,%eax
f0101aab:	d3 e3                	shl    %cl,%ebx
f0101aad:	89 d1                	mov    %edx,%ecx
f0101aaf:	89 fa                	mov    %edi,%edx
f0101ab1:	d3 e8                	shr    %cl,%eax
f0101ab3:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
f0101ab8:	09 d8                	or     %ebx,%eax
f0101aba:	f7 74 24 08          	divl   0x8(%esp)
f0101abe:	89 d3                	mov    %edx,%ebx
f0101ac0:	d3 e6                	shl    %cl,%esi
f0101ac2:	f7 e5                	mul    %ebp
f0101ac4:	89 c7                	mov    %eax,%edi
f0101ac6:	89 d1                	mov    %edx,%ecx
f0101ac8:	39 d3                	cmp    %edx,%ebx
f0101aca:	72 06                	jb     f0101ad2 <__umoddi3+0xe2>
f0101acc:	75 0e                	jne    f0101adc <__umoddi3+0xec>
f0101ace:	39 c6                	cmp    %eax,%esi
f0101ad0:	73 0a                	jae    f0101adc <__umoddi3+0xec>
f0101ad2:	29 e8                	sub    %ebp,%eax
f0101ad4:	1b 54 24 08          	sbb    0x8(%esp),%edx
f0101ad8:	89 d1                	mov    %edx,%ecx
f0101ada:	89 c7                	mov    %eax,%edi
f0101adc:	89 f5                	mov    %esi,%ebp
f0101ade:	8b 74 24 04          	mov    0x4(%esp),%esi
f0101ae2:	29 fd                	sub    %edi,%ebp
f0101ae4:	19 cb                	sbb    %ecx,%ebx
f0101ae6:	0f b6 4c 24 0c       	movzbl 0xc(%esp),%ecx
f0101aeb:	89 d8                	mov    %ebx,%eax
f0101aed:	d3 e0                	shl    %cl,%eax
f0101aef:	89 f1                	mov    %esi,%ecx
f0101af1:	d3 ed                	shr    %cl,%ebp
f0101af3:	d3 eb                	shr    %cl,%ebx
f0101af5:	09 e8                	or     %ebp,%eax
f0101af7:	89 da                	mov    %ebx,%edx
f0101af9:	83 c4 1c             	add    $0x1c,%esp
f0101afc:	5b                   	pop    %ebx
f0101afd:	5e                   	pop    %esi
f0101afe:	5f                   	pop    %edi
f0101aff:	5d                   	pop    %ebp
f0101b00:	c3                   	ret    
