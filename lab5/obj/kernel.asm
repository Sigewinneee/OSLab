
bin/kernel:     file format elf64-littleriscv


Disassembly of section .text:

ffffffffc0200000 <kern_entry>:

    .section .text,"ax",%progbits
    .globl kern_entry
kern_entry:
    # t0 := 三级页表的虚拟地址
    lui     t0, %hi(boot_page_table_sv39)
ffffffffc0200000:	c020b2b7          	lui	t0,0xc020b
    # t1 := 0xffffffff40000000 即虚实映射偏移量
    li      t1, 0xffffffffc0000000 - 0x80000000
ffffffffc0200004:	ffd0031b          	addiw	t1,zero,-3
ffffffffc0200008:	037a                	slli	t1,t1,0x1e
    # t0 减去虚实映射偏移量 0xffffffff40000000，变为三级页表的物理地址
    sub     t0, t0, t1
ffffffffc020000a:	406282b3          	sub	t0,t0,t1
    # t0 >>= 12，变为三级页表的物理页号
    srli    t0, t0, 12
ffffffffc020000e:	00c2d293          	srli	t0,t0,0xc

    # t1 := 8 << 60，设置 satp 的 MODE 字段为 Sv39
    li      t1, 8 << 60
ffffffffc0200012:	fff0031b          	addiw	t1,zero,-1
ffffffffc0200016:	137e                	slli	t1,t1,0x3f
    # 将刚才计算出的预设三级页表物理页号附加到 satp 中
    or      t0, t0, t1
ffffffffc0200018:	0062e2b3          	or	t0,t0,t1
    # 将算出的 t0(即新的MODE|页表基址物理页号) 覆盖到 satp 中
    csrw    satp, t0
ffffffffc020001c:	18029073          	csrw	satp,t0
    # 使用 sfence.vma 指令刷新 TLB
    sfence.vma
ffffffffc0200020:	12000073          	sfence.vma
    # 从此，我们给内核搭建出了一个完美的虚拟内存空间！
    #nop # 可能映射的位置有些bug。。插入一个nop
    
    # 我们在虚拟内存空间中：随意将 sp 设置为虚拟地址！
    lui sp, %hi(bootstacktop)
ffffffffc0200024:	c020b137          	lui	sp,0xc020b

    # 我们在虚拟内存空间中：随意跳转到虚拟地址！
    # 跳转到 kern_init
    lui t0, %hi(kern_init)
ffffffffc0200028:	c02002b7          	lui	t0,0xc0200
    addi t0, t0, %lo(kern_init)
ffffffffc020002c:	03228293          	addi	t0,t0,50 # ffffffffc0200032 <kern_init>
    jr t0
ffffffffc0200030:	8282                	jr	t0

ffffffffc0200032 <kern_init>:
void grade_backtrace(void);

int
kern_init(void) {
    extern char edata[], end[];
    memset(edata, 0, end - edata);
ffffffffc0200032:	000a7517          	auipc	a0,0xa7
ffffffffc0200036:	37e50513          	addi	a0,a0,894 # ffffffffc02a73b0 <buf>
ffffffffc020003a:	000b3617          	auipc	a2,0xb3
ffffffffc020003e:	8d260613          	addi	a2,a2,-1838 # ffffffffc02b290c <end>
kern_init(void) {
ffffffffc0200042:	1141                	addi	sp,sp,-16
    memset(edata, 0, end - edata);
ffffffffc0200044:	8e09                	sub	a2,a2,a0
ffffffffc0200046:	4581                	li	a1,0
kern_init(void) {
ffffffffc0200048:	e406                	sd	ra,8(sp)
    memset(edata, 0, end - edata);
ffffffffc020004a:	6ba060ef          	jal	ra,ffffffffc0206704 <memset>
    cons_init();                // init the console
ffffffffc020004e:	52a000ef          	jal	ra,ffffffffc0200578 <cons_init>

    const char *message = "(THU.CST) os is loading ...";
    cprintf("%s\n\n", message);
ffffffffc0200052:	00006597          	auipc	a1,0x6
ffffffffc0200056:	6de58593          	addi	a1,a1,1758 # ffffffffc0206730 <etext+0x2>
ffffffffc020005a:	00006517          	auipc	a0,0x6
ffffffffc020005e:	6f650513          	addi	a0,a0,1782 # ffffffffc0206750 <etext+0x22>
ffffffffc0200062:	11e000ef          	jal	ra,ffffffffc0200180 <cprintf>

    print_kerninfo();
ffffffffc0200066:	1a2000ef          	jal	ra,ffffffffc0200208 <print_kerninfo>

    // grade_backtrace();

    pmm_init();                 // init physical memory management
ffffffffc020006a:	512020ef          	jal	ra,ffffffffc020257c <pmm_init>

    pic_init();                 // init interrupt controller
ffffffffc020006e:	5de000ef          	jal	ra,ffffffffc020064c <pic_init>
    idt_init();                 // init interrupt descriptor table
ffffffffc0200072:	5dc000ef          	jal	ra,ffffffffc020064e <idt_init>

    vmm_init();                 // init virtual memory management
ffffffffc0200076:	4da040ef          	jal	ra,ffffffffc0204550 <vmm_init>
    proc_init();                // init process table
ffffffffc020007a:	603050ef          	jal	ra,ffffffffc0205e7c <proc_init>
    
    ide_init();                 // init ide devices
ffffffffc020007e:	56c000ef          	jal	ra,ffffffffc02005ea <ide_init>
    swap_init();                // init swap
ffffffffc0200082:	40c030ef          	jal	ra,ffffffffc020348e <swap_init>

    clock_init();               // init clock interrupt
ffffffffc0200086:	4a0000ef          	jal	ra,ffffffffc0200526 <clock_init>
    intr_enable();              // enable irq interrupt
ffffffffc020008a:	5b6000ef          	jal	ra,ffffffffc0200640 <intr_enable>
    
    cpu_idle();                 // run idle process
ffffffffc020008e:	787050ef          	jal	ra,ffffffffc0206014 <cpu_idle>

ffffffffc0200092 <readline>:
 * The readline() function returns the text of the line read. If some errors
 * are happened, NULL is returned. The return value is a global variable,
 * thus it should be copied before it is used.
 * */
char *
readline(const char *prompt) {
ffffffffc0200092:	715d                	addi	sp,sp,-80
ffffffffc0200094:	e486                	sd	ra,72(sp)
ffffffffc0200096:	e0a6                	sd	s1,64(sp)
ffffffffc0200098:	fc4a                	sd	s2,56(sp)
ffffffffc020009a:	f84e                	sd	s3,48(sp)
ffffffffc020009c:	f452                	sd	s4,40(sp)
ffffffffc020009e:	f056                	sd	s5,32(sp)
ffffffffc02000a0:	ec5a                	sd	s6,24(sp)
ffffffffc02000a2:	e85e                	sd	s7,16(sp)
    if (prompt != NULL) {
ffffffffc02000a4:	c901                	beqz	a0,ffffffffc02000b4 <readline+0x22>
ffffffffc02000a6:	85aa                	mv	a1,a0
        cprintf("%s", prompt);
ffffffffc02000a8:	00006517          	auipc	a0,0x6
ffffffffc02000ac:	6b050513          	addi	a0,a0,1712 # ffffffffc0206758 <etext+0x2a>
ffffffffc02000b0:	0d0000ef          	jal	ra,ffffffffc0200180 <cprintf>
readline(const char *prompt) {
ffffffffc02000b4:	4481                	li	s1,0
    while (1) {
        c = getchar();
        if (c < 0) {
            return NULL;
        }
        else if (c >= ' ' && i < BUFSIZE - 1) {
ffffffffc02000b6:	497d                	li	s2,31
            cputchar(c);
            buf[i ++] = c;
        }
        else if (c == '\b' && i > 0) {
ffffffffc02000b8:	49a1                	li	s3,8
            cputchar(c);
            i --;
        }
        else if (c == '\n' || c == '\r') {
ffffffffc02000ba:	4aa9                	li	s5,10
ffffffffc02000bc:	4b35                	li	s6,13
            buf[i ++] = c;
ffffffffc02000be:	000a7b97          	auipc	s7,0xa7
ffffffffc02000c2:	2f2b8b93          	addi	s7,s7,754 # ffffffffc02a73b0 <buf>
        else if (c >= ' ' && i < BUFSIZE - 1) {
ffffffffc02000c6:	3fe00a13          	li	s4,1022
        c = getchar();
ffffffffc02000ca:	12e000ef          	jal	ra,ffffffffc02001f8 <getchar>
        if (c < 0) {
ffffffffc02000ce:	00054a63          	bltz	a0,ffffffffc02000e2 <readline+0x50>
        else if (c >= ' ' && i < BUFSIZE - 1) {
ffffffffc02000d2:	00a95a63          	bge	s2,a0,ffffffffc02000e6 <readline+0x54>
ffffffffc02000d6:	029a5263          	bge	s4,s1,ffffffffc02000fa <readline+0x68>
        c = getchar();
ffffffffc02000da:	11e000ef          	jal	ra,ffffffffc02001f8 <getchar>
        if (c < 0) {
ffffffffc02000de:	fe055ae3          	bgez	a0,ffffffffc02000d2 <readline+0x40>
            return NULL;
ffffffffc02000e2:	4501                	li	a0,0
ffffffffc02000e4:	a091                	j	ffffffffc0200128 <readline+0x96>
        else if (c == '\b' && i > 0) {
ffffffffc02000e6:	03351463          	bne	a0,s3,ffffffffc020010e <readline+0x7c>
ffffffffc02000ea:	e8a9                	bnez	s1,ffffffffc020013c <readline+0xaa>
        c = getchar();
ffffffffc02000ec:	10c000ef          	jal	ra,ffffffffc02001f8 <getchar>
        if (c < 0) {
ffffffffc02000f0:	fe0549e3          	bltz	a0,ffffffffc02000e2 <readline+0x50>
        else if (c >= ' ' && i < BUFSIZE - 1) {
ffffffffc02000f4:	fea959e3          	bge	s2,a0,ffffffffc02000e6 <readline+0x54>
ffffffffc02000f8:	4481                	li	s1,0
            cputchar(c);
ffffffffc02000fa:	e42a                	sd	a0,8(sp)
ffffffffc02000fc:	0ba000ef          	jal	ra,ffffffffc02001b6 <cputchar>
            buf[i ++] = c;
ffffffffc0200100:	6522                	ld	a0,8(sp)
ffffffffc0200102:	009b87b3          	add	a5,s7,s1
ffffffffc0200106:	2485                	addiw	s1,s1,1
ffffffffc0200108:	00a78023          	sb	a0,0(a5)
ffffffffc020010c:	bf7d                	j	ffffffffc02000ca <readline+0x38>
        else if (c == '\n' || c == '\r') {
ffffffffc020010e:	01550463          	beq	a0,s5,ffffffffc0200116 <readline+0x84>
ffffffffc0200112:	fb651ce3          	bne	a0,s6,ffffffffc02000ca <readline+0x38>
            cputchar(c);
ffffffffc0200116:	0a0000ef          	jal	ra,ffffffffc02001b6 <cputchar>
            buf[i] = '\0';
ffffffffc020011a:	000a7517          	auipc	a0,0xa7
ffffffffc020011e:	29650513          	addi	a0,a0,662 # ffffffffc02a73b0 <buf>
ffffffffc0200122:	94aa                	add	s1,s1,a0
ffffffffc0200124:	00048023          	sb	zero,0(s1)
            return buf;
        }
    }
}
ffffffffc0200128:	60a6                	ld	ra,72(sp)
ffffffffc020012a:	6486                	ld	s1,64(sp)
ffffffffc020012c:	7962                	ld	s2,56(sp)
ffffffffc020012e:	79c2                	ld	s3,48(sp)
ffffffffc0200130:	7a22                	ld	s4,40(sp)
ffffffffc0200132:	7a82                	ld	s5,32(sp)
ffffffffc0200134:	6b62                	ld	s6,24(sp)
ffffffffc0200136:	6bc2                	ld	s7,16(sp)
ffffffffc0200138:	6161                	addi	sp,sp,80
ffffffffc020013a:	8082                	ret
            cputchar(c);
ffffffffc020013c:	4521                	li	a0,8
ffffffffc020013e:	078000ef          	jal	ra,ffffffffc02001b6 <cputchar>
            i --;
ffffffffc0200142:	34fd                	addiw	s1,s1,-1
ffffffffc0200144:	b759                	j	ffffffffc02000ca <readline+0x38>

ffffffffc0200146 <cputch>:
/* *
 * cputch - writes a single character @c to stdout, and it will
 * increace the value of counter pointed by @cnt.
 * */
static void
cputch(int c, int *cnt) {
ffffffffc0200146:	1141                	addi	sp,sp,-16
ffffffffc0200148:	e022                	sd	s0,0(sp)
ffffffffc020014a:	e406                	sd	ra,8(sp)
ffffffffc020014c:	842e                	mv	s0,a1
    cons_putc(c);
ffffffffc020014e:	42c000ef          	jal	ra,ffffffffc020057a <cons_putc>
    (*cnt) ++;
ffffffffc0200152:	401c                	lw	a5,0(s0)
}
ffffffffc0200154:	60a2                	ld	ra,8(sp)
    (*cnt) ++;
ffffffffc0200156:	2785                	addiw	a5,a5,1
ffffffffc0200158:	c01c                	sw	a5,0(s0)
}
ffffffffc020015a:	6402                	ld	s0,0(sp)
ffffffffc020015c:	0141                	addi	sp,sp,16
ffffffffc020015e:	8082                	ret

ffffffffc0200160 <vcprintf>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want cprintf() instead.
 * */
int
vcprintf(const char *fmt, va_list ap) {
ffffffffc0200160:	1101                	addi	sp,sp,-32
ffffffffc0200162:	862a                	mv	a2,a0
ffffffffc0200164:	86ae                	mv	a3,a1
    int cnt = 0;
    vprintfmt((void*)cputch, &cnt, fmt, ap);
ffffffffc0200166:	00000517          	auipc	a0,0x0
ffffffffc020016a:	fe050513          	addi	a0,a0,-32 # ffffffffc0200146 <cputch>
ffffffffc020016e:	006c                	addi	a1,sp,12
vcprintf(const char *fmt, va_list ap) {
ffffffffc0200170:	ec06                	sd	ra,24(sp)
    int cnt = 0;
ffffffffc0200172:	c602                	sw	zero,12(sp)
    vprintfmt((void*)cputch, &cnt, fmt, ap);
ffffffffc0200174:	192060ef          	jal	ra,ffffffffc0206306 <vprintfmt>
    return cnt;
}
ffffffffc0200178:	60e2                	ld	ra,24(sp)
ffffffffc020017a:	4532                	lw	a0,12(sp)
ffffffffc020017c:	6105                	addi	sp,sp,32
ffffffffc020017e:	8082                	ret

ffffffffc0200180 <cprintf>:
 *
 * The return value is the number of characters which would be
 * written to stdout.
 * */
int
cprintf(const char *fmt, ...) {
ffffffffc0200180:	711d                	addi	sp,sp,-96
    va_list ap;
    int cnt;
    va_start(ap, fmt);
ffffffffc0200182:	02810313          	addi	t1,sp,40 # ffffffffc020b028 <boot_page_table_sv39+0x28>
cprintf(const char *fmt, ...) {
ffffffffc0200186:	8e2a                	mv	t3,a0
ffffffffc0200188:	f42e                	sd	a1,40(sp)
ffffffffc020018a:	f832                	sd	a2,48(sp)
ffffffffc020018c:	fc36                	sd	a3,56(sp)
    vprintfmt((void*)cputch, &cnt, fmt, ap);
ffffffffc020018e:	00000517          	auipc	a0,0x0
ffffffffc0200192:	fb850513          	addi	a0,a0,-72 # ffffffffc0200146 <cputch>
ffffffffc0200196:	004c                	addi	a1,sp,4
ffffffffc0200198:	869a                	mv	a3,t1
ffffffffc020019a:	8672                	mv	a2,t3
cprintf(const char *fmt, ...) {
ffffffffc020019c:	ec06                	sd	ra,24(sp)
ffffffffc020019e:	e0ba                	sd	a4,64(sp)
ffffffffc02001a0:	e4be                	sd	a5,72(sp)
ffffffffc02001a2:	e8c2                	sd	a6,80(sp)
ffffffffc02001a4:	ecc6                	sd	a7,88(sp)
    va_start(ap, fmt);
ffffffffc02001a6:	e41a                	sd	t1,8(sp)
    int cnt = 0;
ffffffffc02001a8:	c202                	sw	zero,4(sp)
    vprintfmt((void*)cputch, &cnt, fmt, ap);
ffffffffc02001aa:	15c060ef          	jal	ra,ffffffffc0206306 <vprintfmt>
    cnt = vcprintf(fmt, ap);
    va_end(ap);
    return cnt;
}
ffffffffc02001ae:	60e2                	ld	ra,24(sp)
ffffffffc02001b0:	4512                	lw	a0,4(sp)
ffffffffc02001b2:	6125                	addi	sp,sp,96
ffffffffc02001b4:	8082                	ret

ffffffffc02001b6 <cputchar>:

/* cputchar - writes a single character to stdout */
void
cputchar(int c) {
    cons_putc(c);
ffffffffc02001b6:	a6d1                	j	ffffffffc020057a <cons_putc>

ffffffffc02001b8 <cputs>:
/* *
 * cputs- writes the string pointed by @str to stdout and
 * appends a newline character.
 * */
int
cputs(const char *str) {
ffffffffc02001b8:	1101                	addi	sp,sp,-32
ffffffffc02001ba:	e822                	sd	s0,16(sp)
ffffffffc02001bc:	ec06                	sd	ra,24(sp)
ffffffffc02001be:	e426                	sd	s1,8(sp)
ffffffffc02001c0:	842a                	mv	s0,a0
    int cnt = 0;
    char c;
    while ((c = *str ++) != '\0') {
ffffffffc02001c2:	00054503          	lbu	a0,0(a0)
ffffffffc02001c6:	c51d                	beqz	a0,ffffffffc02001f4 <cputs+0x3c>
ffffffffc02001c8:	0405                	addi	s0,s0,1
ffffffffc02001ca:	4485                	li	s1,1
ffffffffc02001cc:	9c81                	subw	s1,s1,s0
    cons_putc(c);
ffffffffc02001ce:	3ac000ef          	jal	ra,ffffffffc020057a <cons_putc>
    while ((c = *str ++) != '\0') {
ffffffffc02001d2:	00044503          	lbu	a0,0(s0)
ffffffffc02001d6:	008487bb          	addw	a5,s1,s0
ffffffffc02001da:	0405                	addi	s0,s0,1
ffffffffc02001dc:	f96d                	bnez	a0,ffffffffc02001ce <cputs+0x16>
    (*cnt) ++;
ffffffffc02001de:	0017841b          	addiw	s0,a5,1
    cons_putc(c);
ffffffffc02001e2:	4529                	li	a0,10
ffffffffc02001e4:	396000ef          	jal	ra,ffffffffc020057a <cons_putc>
        cputch(c, &cnt);
    }
    cputch('\n', &cnt);
    return cnt;
}
ffffffffc02001e8:	60e2                	ld	ra,24(sp)
ffffffffc02001ea:	8522                	mv	a0,s0
ffffffffc02001ec:	6442                	ld	s0,16(sp)
ffffffffc02001ee:	64a2                	ld	s1,8(sp)
ffffffffc02001f0:	6105                	addi	sp,sp,32
ffffffffc02001f2:	8082                	ret
    while ((c = *str ++) != '\0') {
ffffffffc02001f4:	4405                	li	s0,1
ffffffffc02001f6:	b7f5                	j	ffffffffc02001e2 <cputs+0x2a>

ffffffffc02001f8 <getchar>:

/* getchar - reads a single non-zero character from stdin */
int
getchar(void) {
ffffffffc02001f8:	1141                	addi	sp,sp,-16
ffffffffc02001fa:	e406                	sd	ra,8(sp)
    int c;
    while ((c = cons_getc()) == 0)
ffffffffc02001fc:	3b2000ef          	jal	ra,ffffffffc02005ae <cons_getc>
ffffffffc0200200:	dd75                	beqz	a0,ffffffffc02001fc <getchar+0x4>
        /* do nothing */;
    return c;
}
ffffffffc0200202:	60a2                	ld	ra,8(sp)
ffffffffc0200204:	0141                	addi	sp,sp,16
ffffffffc0200206:	8082                	ret

ffffffffc0200208 <print_kerninfo>:
/* *
 * print_kerninfo - print the information about kernel, including the location
 * of kernel entry, the start addresses of data and text segements, the start
 * address of free memory and how many memory that kernel has used.
 * */
void print_kerninfo(void) {
ffffffffc0200208:	1141                	addi	sp,sp,-16
    extern char etext[], edata[], end[], kern_init[];
    cprintf("Special kernel symbols:\n");
ffffffffc020020a:	00006517          	auipc	a0,0x6
ffffffffc020020e:	55650513          	addi	a0,a0,1366 # ffffffffc0206760 <etext+0x32>
void print_kerninfo(void) {
ffffffffc0200212:	e406                	sd	ra,8(sp)
    cprintf("Special kernel symbols:\n");
ffffffffc0200214:	f6dff0ef          	jal	ra,ffffffffc0200180 <cprintf>
    cprintf("  entry  0x%08x (virtual)\n", kern_init);
ffffffffc0200218:	00000597          	auipc	a1,0x0
ffffffffc020021c:	e1a58593          	addi	a1,a1,-486 # ffffffffc0200032 <kern_init>
ffffffffc0200220:	00006517          	auipc	a0,0x6
ffffffffc0200224:	56050513          	addi	a0,a0,1376 # ffffffffc0206780 <etext+0x52>
ffffffffc0200228:	f59ff0ef          	jal	ra,ffffffffc0200180 <cprintf>
    cprintf("  etext  0x%08x (virtual)\n", etext);
ffffffffc020022c:	00006597          	auipc	a1,0x6
ffffffffc0200230:	50258593          	addi	a1,a1,1282 # ffffffffc020672e <etext>
ffffffffc0200234:	00006517          	auipc	a0,0x6
ffffffffc0200238:	56c50513          	addi	a0,a0,1388 # ffffffffc02067a0 <etext+0x72>
ffffffffc020023c:	f45ff0ef          	jal	ra,ffffffffc0200180 <cprintf>
    cprintf("  edata  0x%08x (virtual)\n", edata);
ffffffffc0200240:	000a7597          	auipc	a1,0xa7
ffffffffc0200244:	17058593          	addi	a1,a1,368 # ffffffffc02a73b0 <buf>
ffffffffc0200248:	00006517          	auipc	a0,0x6
ffffffffc020024c:	57850513          	addi	a0,a0,1400 # ffffffffc02067c0 <etext+0x92>
ffffffffc0200250:	f31ff0ef          	jal	ra,ffffffffc0200180 <cprintf>
    cprintf("  end    0x%08x (virtual)\n", end);
ffffffffc0200254:	000b2597          	auipc	a1,0xb2
ffffffffc0200258:	6b858593          	addi	a1,a1,1720 # ffffffffc02b290c <end>
ffffffffc020025c:	00006517          	auipc	a0,0x6
ffffffffc0200260:	58450513          	addi	a0,a0,1412 # ffffffffc02067e0 <etext+0xb2>
ffffffffc0200264:	f1dff0ef          	jal	ra,ffffffffc0200180 <cprintf>
    cprintf("Kernel executable memory footprint: %dKB\n",
            (end - kern_init + 1023) / 1024);
ffffffffc0200268:	000b3597          	auipc	a1,0xb3
ffffffffc020026c:	aa358593          	addi	a1,a1,-1373 # ffffffffc02b2d0b <end+0x3ff>
ffffffffc0200270:	00000797          	auipc	a5,0x0
ffffffffc0200274:	dc278793          	addi	a5,a5,-574 # ffffffffc0200032 <kern_init>
ffffffffc0200278:	40f587b3          	sub	a5,a1,a5
    cprintf("Kernel executable memory footprint: %dKB\n",
ffffffffc020027c:	43f7d593          	srai	a1,a5,0x3f
}
ffffffffc0200280:	60a2                	ld	ra,8(sp)
    cprintf("Kernel executable memory footprint: %dKB\n",
ffffffffc0200282:	3ff5f593          	andi	a1,a1,1023
ffffffffc0200286:	95be                	add	a1,a1,a5
ffffffffc0200288:	85a9                	srai	a1,a1,0xa
ffffffffc020028a:	00006517          	auipc	a0,0x6
ffffffffc020028e:	57650513          	addi	a0,a0,1398 # ffffffffc0206800 <etext+0xd2>
}
ffffffffc0200292:	0141                	addi	sp,sp,16
    cprintf("Kernel executable memory footprint: %dKB\n",
ffffffffc0200294:	b5f5                	j	ffffffffc0200180 <cprintf>

ffffffffc0200296 <print_stackframe>:
 * Note that, the length of ebp-chain is limited. In boot/bootasm.S, before
 * jumping
 * to the kernel entry, the value of ebp has been set to zero, that's the
 * boundary.
 * */
void print_stackframe(void) {
ffffffffc0200296:	1141                	addi	sp,sp,-16
    panic("Not Implemented!");
ffffffffc0200298:	00006617          	auipc	a2,0x6
ffffffffc020029c:	59860613          	addi	a2,a2,1432 # ffffffffc0206830 <etext+0x102>
ffffffffc02002a0:	04d00593          	li	a1,77
ffffffffc02002a4:	00006517          	auipc	a0,0x6
ffffffffc02002a8:	5a450513          	addi	a0,a0,1444 # ffffffffc0206848 <etext+0x11a>
void print_stackframe(void) {
ffffffffc02002ac:	e406                	sd	ra,8(sp)
    panic("Not Implemented!");
ffffffffc02002ae:	1cc000ef          	jal	ra,ffffffffc020047a <__panic>

ffffffffc02002b2 <mon_help>:
    }
}

/* mon_help - print the information about mon_* functions */
int
mon_help(int argc, char **argv, struct trapframe *tf) {
ffffffffc02002b2:	1141                	addi	sp,sp,-16
    int i;
    for (i = 0; i < NCOMMANDS; i ++) {
        cprintf("%s - %s\n", commands[i].name, commands[i].desc);
ffffffffc02002b4:	00006617          	auipc	a2,0x6
ffffffffc02002b8:	5ac60613          	addi	a2,a2,1452 # ffffffffc0206860 <etext+0x132>
ffffffffc02002bc:	00006597          	auipc	a1,0x6
ffffffffc02002c0:	5c458593          	addi	a1,a1,1476 # ffffffffc0206880 <etext+0x152>
ffffffffc02002c4:	00006517          	auipc	a0,0x6
ffffffffc02002c8:	5c450513          	addi	a0,a0,1476 # ffffffffc0206888 <etext+0x15a>
mon_help(int argc, char **argv, struct trapframe *tf) {
ffffffffc02002cc:	e406                	sd	ra,8(sp)
        cprintf("%s - %s\n", commands[i].name, commands[i].desc);
ffffffffc02002ce:	eb3ff0ef          	jal	ra,ffffffffc0200180 <cprintf>
ffffffffc02002d2:	00006617          	auipc	a2,0x6
ffffffffc02002d6:	5c660613          	addi	a2,a2,1478 # ffffffffc0206898 <etext+0x16a>
ffffffffc02002da:	00006597          	auipc	a1,0x6
ffffffffc02002de:	5e658593          	addi	a1,a1,1510 # ffffffffc02068c0 <etext+0x192>
ffffffffc02002e2:	00006517          	auipc	a0,0x6
ffffffffc02002e6:	5a650513          	addi	a0,a0,1446 # ffffffffc0206888 <etext+0x15a>
ffffffffc02002ea:	e97ff0ef          	jal	ra,ffffffffc0200180 <cprintf>
ffffffffc02002ee:	00006617          	auipc	a2,0x6
ffffffffc02002f2:	5e260613          	addi	a2,a2,1506 # ffffffffc02068d0 <etext+0x1a2>
ffffffffc02002f6:	00006597          	auipc	a1,0x6
ffffffffc02002fa:	5fa58593          	addi	a1,a1,1530 # ffffffffc02068f0 <etext+0x1c2>
ffffffffc02002fe:	00006517          	auipc	a0,0x6
ffffffffc0200302:	58a50513          	addi	a0,a0,1418 # ffffffffc0206888 <etext+0x15a>
ffffffffc0200306:	e7bff0ef          	jal	ra,ffffffffc0200180 <cprintf>
    }
    return 0;
}
ffffffffc020030a:	60a2                	ld	ra,8(sp)
ffffffffc020030c:	4501                	li	a0,0
ffffffffc020030e:	0141                	addi	sp,sp,16
ffffffffc0200310:	8082                	ret

ffffffffc0200312 <mon_kerninfo>:
/* *
 * mon_kerninfo - call print_kerninfo in kern/debug/kdebug.c to
 * print the memory occupancy in kernel.
 * */
int
mon_kerninfo(int argc, char **argv, struct trapframe *tf) {
ffffffffc0200312:	1141                	addi	sp,sp,-16
ffffffffc0200314:	e406                	sd	ra,8(sp)
    print_kerninfo();
ffffffffc0200316:	ef3ff0ef          	jal	ra,ffffffffc0200208 <print_kerninfo>
    return 0;
}
ffffffffc020031a:	60a2                	ld	ra,8(sp)
ffffffffc020031c:	4501                	li	a0,0
ffffffffc020031e:	0141                	addi	sp,sp,16
ffffffffc0200320:	8082                	ret

ffffffffc0200322 <mon_backtrace>:
/* *
 * mon_backtrace - call print_stackframe in kern/debug/kdebug.c to
 * print a backtrace of the stack.
 * */
int
mon_backtrace(int argc, char **argv, struct trapframe *tf) {
ffffffffc0200322:	1141                	addi	sp,sp,-16
ffffffffc0200324:	e406                	sd	ra,8(sp)
    print_stackframe();
ffffffffc0200326:	f71ff0ef          	jal	ra,ffffffffc0200296 <print_stackframe>
    return 0;
}
ffffffffc020032a:	60a2                	ld	ra,8(sp)
ffffffffc020032c:	4501                	li	a0,0
ffffffffc020032e:	0141                	addi	sp,sp,16
ffffffffc0200330:	8082                	ret

ffffffffc0200332 <kmonitor>:
kmonitor(struct trapframe *tf) {
ffffffffc0200332:	7115                	addi	sp,sp,-224
ffffffffc0200334:	ed5e                	sd	s7,152(sp)
ffffffffc0200336:	8baa                	mv	s7,a0
    cprintf("Welcome to the kernel debug monitor!!\n");
ffffffffc0200338:	00006517          	auipc	a0,0x6
ffffffffc020033c:	5c850513          	addi	a0,a0,1480 # ffffffffc0206900 <etext+0x1d2>
kmonitor(struct trapframe *tf) {
ffffffffc0200340:	ed86                	sd	ra,216(sp)
ffffffffc0200342:	e9a2                	sd	s0,208(sp)
ffffffffc0200344:	e5a6                	sd	s1,200(sp)
ffffffffc0200346:	e1ca                	sd	s2,192(sp)
ffffffffc0200348:	fd4e                	sd	s3,184(sp)
ffffffffc020034a:	f952                	sd	s4,176(sp)
ffffffffc020034c:	f556                	sd	s5,168(sp)
ffffffffc020034e:	f15a                	sd	s6,160(sp)
ffffffffc0200350:	e962                	sd	s8,144(sp)
ffffffffc0200352:	e566                	sd	s9,136(sp)
ffffffffc0200354:	e16a                	sd	s10,128(sp)
    cprintf("Welcome to the kernel debug monitor!!\n");
ffffffffc0200356:	e2bff0ef          	jal	ra,ffffffffc0200180 <cprintf>
    cprintf("Type 'help' for a list of commands.\n");
ffffffffc020035a:	00006517          	auipc	a0,0x6
ffffffffc020035e:	5ce50513          	addi	a0,a0,1486 # ffffffffc0206928 <etext+0x1fa>
ffffffffc0200362:	e1fff0ef          	jal	ra,ffffffffc0200180 <cprintf>
    if (tf != NULL) {
ffffffffc0200366:	000b8563          	beqz	s7,ffffffffc0200370 <kmonitor+0x3e>
        print_trapframe(tf);
ffffffffc020036a:	855e                	mv	a0,s7
ffffffffc020036c:	4c8000ef          	jal	ra,ffffffffc0200834 <print_trapframe>
ffffffffc0200370:	00006c17          	auipc	s8,0x6
ffffffffc0200374:	628c0c13          	addi	s8,s8,1576 # ffffffffc0206998 <commands>
        if ((buf = readline("K> ")) != NULL) {
ffffffffc0200378:	00006917          	auipc	s2,0x6
ffffffffc020037c:	5d890913          	addi	s2,s2,1496 # ffffffffc0206950 <etext+0x222>
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
ffffffffc0200380:	00006497          	auipc	s1,0x6
ffffffffc0200384:	5d848493          	addi	s1,s1,1496 # ffffffffc0206958 <etext+0x22a>
        if (argc == MAXARGS - 1) {
ffffffffc0200388:	49bd                	li	s3,15
            cprintf("Too many arguments (max %d).\n", MAXARGS);
ffffffffc020038a:	00006b17          	auipc	s6,0x6
ffffffffc020038e:	5d6b0b13          	addi	s6,s6,1494 # ffffffffc0206960 <etext+0x232>
        argv[argc ++] = buf;
ffffffffc0200392:	00006a17          	auipc	s4,0x6
ffffffffc0200396:	4eea0a13          	addi	s4,s4,1262 # ffffffffc0206880 <etext+0x152>
    for (i = 0; i < NCOMMANDS; i ++) {
ffffffffc020039a:	4a8d                	li	s5,3
        if ((buf = readline("K> ")) != NULL) {
ffffffffc020039c:	854a                	mv	a0,s2
ffffffffc020039e:	cf5ff0ef          	jal	ra,ffffffffc0200092 <readline>
ffffffffc02003a2:	842a                	mv	s0,a0
ffffffffc02003a4:	dd65                	beqz	a0,ffffffffc020039c <kmonitor+0x6a>
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
ffffffffc02003a6:	00054583          	lbu	a1,0(a0)
    int argc = 0;
ffffffffc02003aa:	4c81                	li	s9,0
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
ffffffffc02003ac:	e1bd                	bnez	a1,ffffffffc0200412 <kmonitor+0xe0>
    if (argc == 0) {
ffffffffc02003ae:	fe0c87e3          	beqz	s9,ffffffffc020039c <kmonitor+0x6a>
        if (strcmp(commands[i].name, argv[0]) == 0) {
ffffffffc02003b2:	6582                	ld	a1,0(sp)
ffffffffc02003b4:	00006d17          	auipc	s10,0x6
ffffffffc02003b8:	5e4d0d13          	addi	s10,s10,1508 # ffffffffc0206998 <commands>
        argv[argc ++] = buf;
ffffffffc02003bc:	8552                	mv	a0,s4
    for (i = 0; i < NCOMMANDS; i ++) {
ffffffffc02003be:	4401                	li	s0,0
ffffffffc02003c0:	0d61                	addi	s10,s10,24
        if (strcmp(commands[i].name, argv[0]) == 0) {
ffffffffc02003c2:	30e060ef          	jal	ra,ffffffffc02066d0 <strcmp>
ffffffffc02003c6:	c919                	beqz	a0,ffffffffc02003dc <kmonitor+0xaa>
    for (i = 0; i < NCOMMANDS; i ++) {
ffffffffc02003c8:	2405                	addiw	s0,s0,1
ffffffffc02003ca:	0b540063          	beq	s0,s5,ffffffffc020046a <kmonitor+0x138>
        if (strcmp(commands[i].name, argv[0]) == 0) {
ffffffffc02003ce:	000d3503          	ld	a0,0(s10)
ffffffffc02003d2:	6582                	ld	a1,0(sp)
    for (i = 0; i < NCOMMANDS; i ++) {
ffffffffc02003d4:	0d61                	addi	s10,s10,24
        if (strcmp(commands[i].name, argv[0]) == 0) {
ffffffffc02003d6:	2fa060ef          	jal	ra,ffffffffc02066d0 <strcmp>
ffffffffc02003da:	f57d                	bnez	a0,ffffffffc02003c8 <kmonitor+0x96>
            return commands[i].func(argc - 1, argv + 1, tf);
ffffffffc02003dc:	00141793          	slli	a5,s0,0x1
ffffffffc02003e0:	97a2                	add	a5,a5,s0
ffffffffc02003e2:	078e                	slli	a5,a5,0x3
ffffffffc02003e4:	97e2                	add	a5,a5,s8
ffffffffc02003e6:	6b9c                	ld	a5,16(a5)
ffffffffc02003e8:	865e                	mv	a2,s7
ffffffffc02003ea:	002c                	addi	a1,sp,8
ffffffffc02003ec:	fffc851b          	addiw	a0,s9,-1
ffffffffc02003f0:	9782                	jalr	a5
            if (runcmd(buf, tf) < 0) {
ffffffffc02003f2:	fa0555e3          	bgez	a0,ffffffffc020039c <kmonitor+0x6a>
}
ffffffffc02003f6:	60ee                	ld	ra,216(sp)
ffffffffc02003f8:	644e                	ld	s0,208(sp)
ffffffffc02003fa:	64ae                	ld	s1,200(sp)
ffffffffc02003fc:	690e                	ld	s2,192(sp)
ffffffffc02003fe:	79ea                	ld	s3,184(sp)
ffffffffc0200400:	7a4a                	ld	s4,176(sp)
ffffffffc0200402:	7aaa                	ld	s5,168(sp)
ffffffffc0200404:	7b0a                	ld	s6,160(sp)
ffffffffc0200406:	6bea                	ld	s7,152(sp)
ffffffffc0200408:	6c4a                	ld	s8,144(sp)
ffffffffc020040a:	6caa                	ld	s9,136(sp)
ffffffffc020040c:	6d0a                	ld	s10,128(sp)
ffffffffc020040e:	612d                	addi	sp,sp,224
ffffffffc0200410:	8082                	ret
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
ffffffffc0200412:	8526                	mv	a0,s1
ffffffffc0200414:	2da060ef          	jal	ra,ffffffffc02066ee <strchr>
ffffffffc0200418:	c901                	beqz	a0,ffffffffc0200428 <kmonitor+0xf6>
ffffffffc020041a:	00144583          	lbu	a1,1(s0)
            *buf ++ = '\0';
ffffffffc020041e:	00040023          	sb	zero,0(s0)
ffffffffc0200422:	0405                	addi	s0,s0,1
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
ffffffffc0200424:	d5c9                	beqz	a1,ffffffffc02003ae <kmonitor+0x7c>
ffffffffc0200426:	b7f5                	j	ffffffffc0200412 <kmonitor+0xe0>
        if (*buf == '\0') {
ffffffffc0200428:	00044783          	lbu	a5,0(s0)
ffffffffc020042c:	d3c9                	beqz	a5,ffffffffc02003ae <kmonitor+0x7c>
        if (argc == MAXARGS - 1) {
ffffffffc020042e:	033c8963          	beq	s9,s3,ffffffffc0200460 <kmonitor+0x12e>
        argv[argc ++] = buf;
ffffffffc0200432:	003c9793          	slli	a5,s9,0x3
ffffffffc0200436:	0118                	addi	a4,sp,128
ffffffffc0200438:	97ba                	add	a5,a5,a4
ffffffffc020043a:	f887b023          	sd	s0,-128(a5)
        while (*buf != '\0' && strchr(WHITESPACE, *buf) == NULL) {
ffffffffc020043e:	00044583          	lbu	a1,0(s0)
        argv[argc ++] = buf;
ffffffffc0200442:	2c85                	addiw	s9,s9,1
        while (*buf != '\0' && strchr(WHITESPACE, *buf) == NULL) {
ffffffffc0200444:	e591                	bnez	a1,ffffffffc0200450 <kmonitor+0x11e>
ffffffffc0200446:	b7b5                	j	ffffffffc02003b2 <kmonitor+0x80>
ffffffffc0200448:	00144583          	lbu	a1,1(s0)
            buf ++;
ffffffffc020044c:	0405                	addi	s0,s0,1
        while (*buf != '\0' && strchr(WHITESPACE, *buf) == NULL) {
ffffffffc020044e:	d1a5                	beqz	a1,ffffffffc02003ae <kmonitor+0x7c>
ffffffffc0200450:	8526                	mv	a0,s1
ffffffffc0200452:	29c060ef          	jal	ra,ffffffffc02066ee <strchr>
ffffffffc0200456:	d96d                	beqz	a0,ffffffffc0200448 <kmonitor+0x116>
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
ffffffffc0200458:	00044583          	lbu	a1,0(s0)
ffffffffc020045c:	d9a9                	beqz	a1,ffffffffc02003ae <kmonitor+0x7c>
ffffffffc020045e:	bf55                	j	ffffffffc0200412 <kmonitor+0xe0>
            cprintf("Too many arguments (max %d).\n", MAXARGS);
ffffffffc0200460:	45c1                	li	a1,16
ffffffffc0200462:	855a                	mv	a0,s6
ffffffffc0200464:	d1dff0ef          	jal	ra,ffffffffc0200180 <cprintf>
ffffffffc0200468:	b7e9                	j	ffffffffc0200432 <kmonitor+0x100>
    cprintf("Unknown command '%s'\n", argv[0]);
ffffffffc020046a:	6582                	ld	a1,0(sp)
ffffffffc020046c:	00006517          	auipc	a0,0x6
ffffffffc0200470:	51450513          	addi	a0,a0,1300 # ffffffffc0206980 <etext+0x252>
ffffffffc0200474:	d0dff0ef          	jal	ra,ffffffffc0200180 <cprintf>
    return 0;
ffffffffc0200478:	b715                	j	ffffffffc020039c <kmonitor+0x6a>

ffffffffc020047a <__panic>:
 * __panic - __panic is called on unresolvable fatal errors. it prints
 * "panic: 'message'", and then enters the kernel monitor.
 * */
void
__panic(const char *file, int line, const char *fmt, ...) {
    if (is_panic) {
ffffffffc020047a:	000b2317          	auipc	t1,0xb2
ffffffffc020047e:	3fe30313          	addi	t1,t1,1022 # ffffffffc02b2878 <is_panic>
ffffffffc0200482:	00033e03          	ld	t3,0(t1)
__panic(const char *file, int line, const char *fmt, ...) {
ffffffffc0200486:	715d                	addi	sp,sp,-80
ffffffffc0200488:	ec06                	sd	ra,24(sp)
ffffffffc020048a:	e822                	sd	s0,16(sp)
ffffffffc020048c:	f436                	sd	a3,40(sp)
ffffffffc020048e:	f83a                	sd	a4,48(sp)
ffffffffc0200490:	fc3e                	sd	a5,56(sp)
ffffffffc0200492:	e0c2                	sd	a6,64(sp)
ffffffffc0200494:	e4c6                	sd	a7,72(sp)
    if (is_panic) {
ffffffffc0200496:	020e1a63          	bnez	t3,ffffffffc02004ca <__panic+0x50>
        goto panic_dead;
    }
    is_panic = 1;
ffffffffc020049a:	4785                	li	a5,1
ffffffffc020049c:	00f33023          	sd	a5,0(t1)

    // print the 'message'
    va_list ap;
    va_start(ap, fmt);
ffffffffc02004a0:	8432                	mv	s0,a2
ffffffffc02004a2:	103c                	addi	a5,sp,40
    cprintf("kernel panic at %s:%d:\n    ", file, line);
ffffffffc02004a4:	862e                	mv	a2,a1
ffffffffc02004a6:	85aa                	mv	a1,a0
ffffffffc02004a8:	00006517          	auipc	a0,0x6
ffffffffc02004ac:	53850513          	addi	a0,a0,1336 # ffffffffc02069e0 <commands+0x48>
    va_start(ap, fmt);
ffffffffc02004b0:	e43e                	sd	a5,8(sp)
    cprintf("kernel panic at %s:%d:\n    ", file, line);
ffffffffc02004b2:	ccfff0ef          	jal	ra,ffffffffc0200180 <cprintf>
    vcprintf(fmt, ap);
ffffffffc02004b6:	65a2                	ld	a1,8(sp)
ffffffffc02004b8:	8522                	mv	a0,s0
ffffffffc02004ba:	ca7ff0ef          	jal	ra,ffffffffc0200160 <vcprintf>
    cprintf("\n");
ffffffffc02004be:	00007517          	auipc	a0,0x7
ffffffffc02004c2:	4da50513          	addi	a0,a0,1242 # ffffffffc0207998 <default_pmm_manager+0x518>
ffffffffc02004c6:	cbbff0ef          	jal	ra,ffffffffc0200180 <cprintf>
#endif
}

static inline void sbi_shutdown(void)
{
	SBI_CALL_0(SBI_SHUTDOWN);
ffffffffc02004ca:	4501                	li	a0,0
ffffffffc02004cc:	4581                	li	a1,0
ffffffffc02004ce:	4601                	li	a2,0
ffffffffc02004d0:	48a1                	li	a7,8
ffffffffc02004d2:	00000073          	ecall
    va_end(ap);

panic_dead:
    // No debug monitor here
    sbi_shutdown();
    intr_disable();
ffffffffc02004d6:	170000ef          	jal	ra,ffffffffc0200646 <intr_disable>
    while (1) {
        kmonitor(NULL);
ffffffffc02004da:	4501                	li	a0,0
ffffffffc02004dc:	e57ff0ef          	jal	ra,ffffffffc0200332 <kmonitor>
    while (1) {
ffffffffc02004e0:	bfed                	j	ffffffffc02004da <__panic+0x60>

ffffffffc02004e2 <__warn>:
    }
}

/* __warn - like panic, but don't */
void
__warn(const char *file, int line, const char *fmt, ...) {
ffffffffc02004e2:	715d                	addi	sp,sp,-80
ffffffffc02004e4:	832e                	mv	t1,a1
ffffffffc02004e6:	e822                	sd	s0,16(sp)
    va_list ap;
    va_start(ap, fmt);
    cprintf("kernel warning at %s:%d:\n    ", file, line);
ffffffffc02004e8:	85aa                	mv	a1,a0
__warn(const char *file, int line, const char *fmt, ...) {
ffffffffc02004ea:	8432                	mv	s0,a2
ffffffffc02004ec:	fc3e                	sd	a5,56(sp)
    cprintf("kernel warning at %s:%d:\n    ", file, line);
ffffffffc02004ee:	861a                	mv	a2,t1
    va_start(ap, fmt);
ffffffffc02004f0:	103c                	addi	a5,sp,40
    cprintf("kernel warning at %s:%d:\n    ", file, line);
ffffffffc02004f2:	00006517          	auipc	a0,0x6
ffffffffc02004f6:	50e50513          	addi	a0,a0,1294 # ffffffffc0206a00 <commands+0x68>
__warn(const char *file, int line, const char *fmt, ...) {
ffffffffc02004fa:	ec06                	sd	ra,24(sp)
ffffffffc02004fc:	f436                	sd	a3,40(sp)
ffffffffc02004fe:	f83a                	sd	a4,48(sp)
ffffffffc0200500:	e0c2                	sd	a6,64(sp)
ffffffffc0200502:	e4c6                	sd	a7,72(sp)
    va_start(ap, fmt);
ffffffffc0200504:	e43e                	sd	a5,8(sp)
    cprintf("kernel warning at %s:%d:\n    ", file, line);
ffffffffc0200506:	c7bff0ef          	jal	ra,ffffffffc0200180 <cprintf>
    vcprintf(fmt, ap);
ffffffffc020050a:	65a2                	ld	a1,8(sp)
ffffffffc020050c:	8522                	mv	a0,s0
ffffffffc020050e:	c53ff0ef          	jal	ra,ffffffffc0200160 <vcprintf>
    cprintf("\n");
ffffffffc0200512:	00007517          	auipc	a0,0x7
ffffffffc0200516:	48650513          	addi	a0,a0,1158 # ffffffffc0207998 <default_pmm_manager+0x518>
ffffffffc020051a:	c67ff0ef          	jal	ra,ffffffffc0200180 <cprintf>
    va_end(ap);
}
ffffffffc020051e:	60e2                	ld	ra,24(sp)
ffffffffc0200520:	6442                	ld	s0,16(sp)
ffffffffc0200522:	6161                	addi	sp,sp,80
ffffffffc0200524:	8082                	ret

ffffffffc0200526 <clock_init>:
 * and then enable IRQ_TIMER.
 * */
void clock_init(void) {
    // divided by 500 when using Spike(2MHz)
    // divided by 100 when using QEMU(10MHz)
    timebase = 1e7 / 100;
ffffffffc0200526:	67e1                	lui	a5,0x18
ffffffffc0200528:	6a078793          	addi	a5,a5,1696 # 186a0 <_binary_obj___user_exit_out_size+0xd570>
ffffffffc020052c:	000b2717          	auipc	a4,0xb2
ffffffffc0200530:	34f73e23          	sd	a5,860(a4) # ffffffffc02b2888 <timebase>
    __asm__ __volatile__("rdtime %0" : "=r"(n));
ffffffffc0200534:	c0102573          	rdtime	a0
	SBI_CALL_1(SBI_SET_TIMER, stime_value);
ffffffffc0200538:	4581                	li	a1,0
    ticks = 0;

    cprintf("++ setup timer interrupts\n");
}

void clock_set_next_event(void) { sbi_set_timer(get_cycles() + timebase); }
ffffffffc020053a:	953e                	add	a0,a0,a5
ffffffffc020053c:	4601                	li	a2,0
ffffffffc020053e:	4881                	li	a7,0
ffffffffc0200540:	00000073          	ecall
    set_csr(sie, MIP_STIP);
ffffffffc0200544:	02000793          	li	a5,32
ffffffffc0200548:	1047a7f3          	csrrs	a5,sie,a5
    cprintf("++ setup timer interrupts\n");
ffffffffc020054c:	00006517          	auipc	a0,0x6
ffffffffc0200550:	4d450513          	addi	a0,a0,1236 # ffffffffc0206a20 <commands+0x88>
    ticks = 0;
ffffffffc0200554:	000b2797          	auipc	a5,0xb2
ffffffffc0200558:	3207b623          	sd	zero,812(a5) # ffffffffc02b2880 <ticks>
    cprintf("++ setup timer interrupts\n");
ffffffffc020055c:	b115                	j	ffffffffc0200180 <cprintf>

ffffffffc020055e <clock_set_next_event>:
    __asm__ __volatile__("rdtime %0" : "=r"(n));
ffffffffc020055e:	c0102573          	rdtime	a0
void clock_set_next_event(void) { sbi_set_timer(get_cycles() + timebase); }
ffffffffc0200562:	000b2797          	auipc	a5,0xb2
ffffffffc0200566:	3267b783          	ld	a5,806(a5) # ffffffffc02b2888 <timebase>
ffffffffc020056a:	953e                	add	a0,a0,a5
ffffffffc020056c:	4581                	li	a1,0
ffffffffc020056e:	4601                	li	a2,0
ffffffffc0200570:	4881                	li	a7,0
ffffffffc0200572:	00000073          	ecall
ffffffffc0200576:	8082                	ret

ffffffffc0200578 <cons_init>:

/* serial_intr - try to feed input characters from serial port */
void serial_intr(void) {}

/* cons_init - initializes the console devices */
void cons_init(void) {}
ffffffffc0200578:	8082                	ret

ffffffffc020057a <cons_putc>:
#include <sched.h>
#include <riscv.h>
#include <assert.h>

static inline bool __intr_save(void) {
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc020057a:	100027f3          	csrr	a5,sstatus
ffffffffc020057e:	8b89                	andi	a5,a5,2
	SBI_CALL_1(SBI_CONSOLE_PUTCHAR, ch);
ffffffffc0200580:	0ff57513          	zext.b	a0,a0
ffffffffc0200584:	e799                	bnez	a5,ffffffffc0200592 <cons_putc+0x18>
ffffffffc0200586:	4581                	li	a1,0
ffffffffc0200588:	4601                	li	a2,0
ffffffffc020058a:	4885                	li	a7,1
ffffffffc020058c:	00000073          	ecall
    }
    return 0;
}

static inline void __intr_restore(bool flag) {
    if (flag) {
ffffffffc0200590:	8082                	ret

/* cons_putc - print a single character @c to console devices */
void cons_putc(int c) {
ffffffffc0200592:	1101                	addi	sp,sp,-32
ffffffffc0200594:	ec06                	sd	ra,24(sp)
ffffffffc0200596:	e42a                	sd	a0,8(sp)
        intr_disable();
ffffffffc0200598:	0ae000ef          	jal	ra,ffffffffc0200646 <intr_disable>
ffffffffc020059c:	6522                	ld	a0,8(sp)
ffffffffc020059e:	4581                	li	a1,0
ffffffffc02005a0:	4601                	li	a2,0
ffffffffc02005a2:	4885                	li	a7,1
ffffffffc02005a4:	00000073          	ecall
    local_intr_save(intr_flag);
    {
        sbi_console_putchar((unsigned char)c);
    }
    local_intr_restore(intr_flag);
}
ffffffffc02005a8:	60e2                	ld	ra,24(sp)
ffffffffc02005aa:	6105                	addi	sp,sp,32
        intr_enable();
ffffffffc02005ac:	a851                	j	ffffffffc0200640 <intr_enable>

ffffffffc02005ae <cons_getc>:
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc02005ae:	100027f3          	csrr	a5,sstatus
ffffffffc02005b2:	8b89                	andi	a5,a5,2
ffffffffc02005b4:	eb89                	bnez	a5,ffffffffc02005c6 <cons_getc+0x18>
	return SBI_CALL_0(SBI_CONSOLE_GETCHAR);
ffffffffc02005b6:	4501                	li	a0,0
ffffffffc02005b8:	4581                	li	a1,0
ffffffffc02005ba:	4601                	li	a2,0
ffffffffc02005bc:	4889                	li	a7,2
ffffffffc02005be:	00000073          	ecall
ffffffffc02005c2:	2501                	sext.w	a0,a0
    {
        c = sbi_console_getchar();
    }
    local_intr_restore(intr_flag);
    return c;
}
ffffffffc02005c4:	8082                	ret
int cons_getc(void) {
ffffffffc02005c6:	1101                	addi	sp,sp,-32
ffffffffc02005c8:	ec06                	sd	ra,24(sp)
        intr_disable();
ffffffffc02005ca:	07c000ef          	jal	ra,ffffffffc0200646 <intr_disable>
ffffffffc02005ce:	4501                	li	a0,0
ffffffffc02005d0:	4581                	li	a1,0
ffffffffc02005d2:	4601                	li	a2,0
ffffffffc02005d4:	4889                	li	a7,2
ffffffffc02005d6:	00000073          	ecall
ffffffffc02005da:	2501                	sext.w	a0,a0
ffffffffc02005dc:	e42a                	sd	a0,8(sp)
        intr_enable();
ffffffffc02005de:	062000ef          	jal	ra,ffffffffc0200640 <intr_enable>
}
ffffffffc02005e2:	60e2                	ld	ra,24(sp)
ffffffffc02005e4:	6522                	ld	a0,8(sp)
ffffffffc02005e6:	6105                	addi	sp,sp,32
ffffffffc02005e8:	8082                	ret

ffffffffc02005ea <ide_init>:
#include <stdio.h>
#include <string.h>
#include <trap.h>
#include <riscv.h>

void ide_init(void) {}
ffffffffc02005ea:	8082                	ret

ffffffffc02005ec <ide_device_valid>:

#define MAX_IDE 2
#define MAX_DISK_NSECS 56
static char ide[MAX_DISK_NSECS * SECTSIZE];

bool ide_device_valid(unsigned short ideno) { return ideno < MAX_IDE; }
ffffffffc02005ec:	00253513          	sltiu	a0,a0,2
ffffffffc02005f0:	8082                	ret

ffffffffc02005f2 <ide_device_size>:

size_t ide_device_size(unsigned short ideno) { return MAX_DISK_NSECS; }
ffffffffc02005f2:	03800513          	li	a0,56
ffffffffc02005f6:	8082                	ret

ffffffffc02005f8 <ide_read_secs>:

int ide_read_secs(unsigned short ideno, uint32_t secno, void *dst,
                  size_t nsecs) {
    int iobase = secno * SECTSIZE;
    memcpy(dst, &ide[iobase], nsecs * SECTSIZE);
ffffffffc02005f8:	000a7797          	auipc	a5,0xa7
ffffffffc02005fc:	1b878793          	addi	a5,a5,440 # ffffffffc02a77b0 <ide>
    int iobase = secno * SECTSIZE;
ffffffffc0200600:	0095959b          	slliw	a1,a1,0x9
                  size_t nsecs) {
ffffffffc0200604:	1141                	addi	sp,sp,-16
ffffffffc0200606:	8532                	mv	a0,a2
    memcpy(dst, &ide[iobase], nsecs * SECTSIZE);
ffffffffc0200608:	95be                	add	a1,a1,a5
ffffffffc020060a:	00969613          	slli	a2,a3,0x9
                  size_t nsecs) {
ffffffffc020060e:	e406                	sd	ra,8(sp)
    memcpy(dst, &ide[iobase], nsecs * SECTSIZE);
ffffffffc0200610:	106060ef          	jal	ra,ffffffffc0206716 <memcpy>
    return 0;
}
ffffffffc0200614:	60a2                	ld	ra,8(sp)
ffffffffc0200616:	4501                	li	a0,0
ffffffffc0200618:	0141                	addi	sp,sp,16
ffffffffc020061a:	8082                	ret

ffffffffc020061c <ide_write_secs>:

int ide_write_secs(unsigned short ideno, uint32_t secno, const void *src,
                   size_t nsecs) {
    int iobase = secno * SECTSIZE;
ffffffffc020061c:	0095979b          	slliw	a5,a1,0x9
    memcpy(&ide[iobase], src, nsecs * SECTSIZE);
ffffffffc0200620:	000a7517          	auipc	a0,0xa7
ffffffffc0200624:	19050513          	addi	a0,a0,400 # ffffffffc02a77b0 <ide>
                   size_t nsecs) {
ffffffffc0200628:	1141                	addi	sp,sp,-16
ffffffffc020062a:	85b2                	mv	a1,a2
    memcpy(&ide[iobase], src, nsecs * SECTSIZE);
ffffffffc020062c:	953e                	add	a0,a0,a5
ffffffffc020062e:	00969613          	slli	a2,a3,0x9
                   size_t nsecs) {
ffffffffc0200632:	e406                	sd	ra,8(sp)
    memcpy(&ide[iobase], src, nsecs * SECTSIZE);
ffffffffc0200634:	0e2060ef          	jal	ra,ffffffffc0206716 <memcpy>
    return 0;
}
ffffffffc0200638:	60a2                	ld	ra,8(sp)
ffffffffc020063a:	4501                	li	a0,0
ffffffffc020063c:	0141                	addi	sp,sp,16
ffffffffc020063e:	8082                	ret

ffffffffc0200640 <intr_enable>:
#include <intr.h>
#include <riscv.h>

/* intr_enable - enable irq interrupt */
void intr_enable(void) { set_csr(sstatus, SSTATUS_SIE); }
ffffffffc0200640:	100167f3          	csrrsi	a5,sstatus,2
ffffffffc0200644:	8082                	ret

ffffffffc0200646 <intr_disable>:

/* intr_disable - disable irq interrupt */
void intr_disable(void) { clear_csr(sstatus, SSTATUS_SIE); }
ffffffffc0200646:	100177f3          	csrrci	a5,sstatus,2
ffffffffc020064a:	8082                	ret

ffffffffc020064c <pic_init>:
#include <picirq.h>

void pic_enable(unsigned int irq) {}

/* pic_init - initialize the 8259A interrupt controllers */
void pic_init(void) {}
ffffffffc020064c:	8082                	ret

ffffffffc020064e <idt_init>:
void
idt_init(void) {
    extern void __alltraps(void);
    /* Set sscratch register to 0, indicating to exception vector that we are
     * presently executing in the kernel */
    write_csr(sscratch, 0);
ffffffffc020064e:	14005073          	csrwi	sscratch,0
    /* Set the exception vector address */
    write_csr(stvec, &__alltraps);
ffffffffc0200652:	00000797          	auipc	a5,0x0
ffffffffc0200656:	65a78793          	addi	a5,a5,1626 # ffffffffc0200cac <__alltraps>
ffffffffc020065a:	10579073          	csrw	stvec,a5
    /* Allow kernel to access user memory */
    set_csr(sstatus, SSTATUS_SUM);
ffffffffc020065e:	000407b7          	lui	a5,0x40
ffffffffc0200662:	1007a7f3          	csrrs	a5,sstatus,a5
}
ffffffffc0200666:	8082                	ret

ffffffffc0200668 <print_regs>:
    cprintf("  tval 0x%08x\n", tf->tval);
    cprintf("  cause    0x%08x\n", tf->cause);
}

void print_regs(struct pushregs* gpr) {
    cprintf("  zero     0x%08x\n", gpr->zero);
ffffffffc0200668:	610c                	ld	a1,0(a0)
void print_regs(struct pushregs* gpr) {
ffffffffc020066a:	1141                	addi	sp,sp,-16
ffffffffc020066c:	e022                	sd	s0,0(sp)
ffffffffc020066e:	842a                	mv	s0,a0
    cprintf("  zero     0x%08x\n", gpr->zero);
ffffffffc0200670:	00006517          	auipc	a0,0x6
ffffffffc0200674:	3d050513          	addi	a0,a0,976 # ffffffffc0206a40 <commands+0xa8>
void print_regs(struct pushregs* gpr) {
ffffffffc0200678:	e406                	sd	ra,8(sp)
    cprintf("  zero     0x%08x\n", gpr->zero);
ffffffffc020067a:	b07ff0ef          	jal	ra,ffffffffc0200180 <cprintf>
    cprintf("  ra       0x%08x\n", gpr->ra);
ffffffffc020067e:	640c                	ld	a1,8(s0)
ffffffffc0200680:	00006517          	auipc	a0,0x6
ffffffffc0200684:	3d850513          	addi	a0,a0,984 # ffffffffc0206a58 <commands+0xc0>
ffffffffc0200688:	af9ff0ef          	jal	ra,ffffffffc0200180 <cprintf>
    cprintf("  sp       0x%08x\n", gpr->sp);
ffffffffc020068c:	680c                	ld	a1,16(s0)
ffffffffc020068e:	00006517          	auipc	a0,0x6
ffffffffc0200692:	3e250513          	addi	a0,a0,994 # ffffffffc0206a70 <commands+0xd8>
ffffffffc0200696:	aebff0ef          	jal	ra,ffffffffc0200180 <cprintf>
    cprintf("  gp       0x%08x\n", gpr->gp);
ffffffffc020069a:	6c0c                	ld	a1,24(s0)
ffffffffc020069c:	00006517          	auipc	a0,0x6
ffffffffc02006a0:	3ec50513          	addi	a0,a0,1004 # ffffffffc0206a88 <commands+0xf0>
ffffffffc02006a4:	addff0ef          	jal	ra,ffffffffc0200180 <cprintf>
    cprintf("  tp       0x%08x\n", gpr->tp);
ffffffffc02006a8:	700c                	ld	a1,32(s0)
ffffffffc02006aa:	00006517          	auipc	a0,0x6
ffffffffc02006ae:	3f650513          	addi	a0,a0,1014 # ffffffffc0206aa0 <commands+0x108>
ffffffffc02006b2:	acfff0ef          	jal	ra,ffffffffc0200180 <cprintf>
    cprintf("  t0       0x%08x\n", gpr->t0);
ffffffffc02006b6:	740c                	ld	a1,40(s0)
ffffffffc02006b8:	00006517          	auipc	a0,0x6
ffffffffc02006bc:	40050513          	addi	a0,a0,1024 # ffffffffc0206ab8 <commands+0x120>
ffffffffc02006c0:	ac1ff0ef          	jal	ra,ffffffffc0200180 <cprintf>
    cprintf("  t1       0x%08x\n", gpr->t1);
ffffffffc02006c4:	780c                	ld	a1,48(s0)
ffffffffc02006c6:	00006517          	auipc	a0,0x6
ffffffffc02006ca:	40a50513          	addi	a0,a0,1034 # ffffffffc0206ad0 <commands+0x138>
ffffffffc02006ce:	ab3ff0ef          	jal	ra,ffffffffc0200180 <cprintf>
    cprintf("  t2       0x%08x\n", gpr->t2);
ffffffffc02006d2:	7c0c                	ld	a1,56(s0)
ffffffffc02006d4:	00006517          	auipc	a0,0x6
ffffffffc02006d8:	41450513          	addi	a0,a0,1044 # ffffffffc0206ae8 <commands+0x150>
ffffffffc02006dc:	aa5ff0ef          	jal	ra,ffffffffc0200180 <cprintf>
    cprintf("  s0       0x%08x\n", gpr->s0);
ffffffffc02006e0:	602c                	ld	a1,64(s0)
ffffffffc02006e2:	00006517          	auipc	a0,0x6
ffffffffc02006e6:	41e50513          	addi	a0,a0,1054 # ffffffffc0206b00 <commands+0x168>
ffffffffc02006ea:	a97ff0ef          	jal	ra,ffffffffc0200180 <cprintf>
    cprintf("  s1       0x%08x\n", gpr->s1);
ffffffffc02006ee:	642c                	ld	a1,72(s0)
ffffffffc02006f0:	00006517          	auipc	a0,0x6
ffffffffc02006f4:	42850513          	addi	a0,a0,1064 # ffffffffc0206b18 <commands+0x180>
ffffffffc02006f8:	a89ff0ef          	jal	ra,ffffffffc0200180 <cprintf>
    cprintf("  a0       0x%08x\n", gpr->a0);
ffffffffc02006fc:	682c                	ld	a1,80(s0)
ffffffffc02006fe:	00006517          	auipc	a0,0x6
ffffffffc0200702:	43250513          	addi	a0,a0,1074 # ffffffffc0206b30 <commands+0x198>
ffffffffc0200706:	a7bff0ef          	jal	ra,ffffffffc0200180 <cprintf>
    cprintf("  a1       0x%08x\n", gpr->a1);
ffffffffc020070a:	6c2c                	ld	a1,88(s0)
ffffffffc020070c:	00006517          	auipc	a0,0x6
ffffffffc0200710:	43c50513          	addi	a0,a0,1084 # ffffffffc0206b48 <commands+0x1b0>
ffffffffc0200714:	a6dff0ef          	jal	ra,ffffffffc0200180 <cprintf>
    cprintf("  a2       0x%08x\n", gpr->a2);
ffffffffc0200718:	702c                	ld	a1,96(s0)
ffffffffc020071a:	00006517          	auipc	a0,0x6
ffffffffc020071e:	44650513          	addi	a0,a0,1094 # ffffffffc0206b60 <commands+0x1c8>
ffffffffc0200722:	a5fff0ef          	jal	ra,ffffffffc0200180 <cprintf>
    cprintf("  a3       0x%08x\n", gpr->a3);
ffffffffc0200726:	742c                	ld	a1,104(s0)
ffffffffc0200728:	00006517          	auipc	a0,0x6
ffffffffc020072c:	45050513          	addi	a0,a0,1104 # ffffffffc0206b78 <commands+0x1e0>
ffffffffc0200730:	a51ff0ef          	jal	ra,ffffffffc0200180 <cprintf>
    cprintf("  a4       0x%08x\n", gpr->a4);
ffffffffc0200734:	782c                	ld	a1,112(s0)
ffffffffc0200736:	00006517          	auipc	a0,0x6
ffffffffc020073a:	45a50513          	addi	a0,a0,1114 # ffffffffc0206b90 <commands+0x1f8>
ffffffffc020073e:	a43ff0ef          	jal	ra,ffffffffc0200180 <cprintf>
    cprintf("  a5       0x%08x\n", gpr->a5);
ffffffffc0200742:	7c2c                	ld	a1,120(s0)
ffffffffc0200744:	00006517          	auipc	a0,0x6
ffffffffc0200748:	46450513          	addi	a0,a0,1124 # ffffffffc0206ba8 <commands+0x210>
ffffffffc020074c:	a35ff0ef          	jal	ra,ffffffffc0200180 <cprintf>
    cprintf("  a6       0x%08x\n", gpr->a6);
ffffffffc0200750:	604c                	ld	a1,128(s0)
ffffffffc0200752:	00006517          	auipc	a0,0x6
ffffffffc0200756:	46e50513          	addi	a0,a0,1134 # ffffffffc0206bc0 <commands+0x228>
ffffffffc020075a:	a27ff0ef          	jal	ra,ffffffffc0200180 <cprintf>
    cprintf("  a7       0x%08x\n", gpr->a7);
ffffffffc020075e:	644c                	ld	a1,136(s0)
ffffffffc0200760:	00006517          	auipc	a0,0x6
ffffffffc0200764:	47850513          	addi	a0,a0,1144 # ffffffffc0206bd8 <commands+0x240>
ffffffffc0200768:	a19ff0ef          	jal	ra,ffffffffc0200180 <cprintf>
    cprintf("  s2       0x%08x\n", gpr->s2);
ffffffffc020076c:	684c                	ld	a1,144(s0)
ffffffffc020076e:	00006517          	auipc	a0,0x6
ffffffffc0200772:	48250513          	addi	a0,a0,1154 # ffffffffc0206bf0 <commands+0x258>
ffffffffc0200776:	a0bff0ef          	jal	ra,ffffffffc0200180 <cprintf>
    cprintf("  s3       0x%08x\n", gpr->s3);
ffffffffc020077a:	6c4c                	ld	a1,152(s0)
ffffffffc020077c:	00006517          	auipc	a0,0x6
ffffffffc0200780:	48c50513          	addi	a0,a0,1164 # ffffffffc0206c08 <commands+0x270>
ffffffffc0200784:	9fdff0ef          	jal	ra,ffffffffc0200180 <cprintf>
    cprintf("  s4       0x%08x\n", gpr->s4);
ffffffffc0200788:	704c                	ld	a1,160(s0)
ffffffffc020078a:	00006517          	auipc	a0,0x6
ffffffffc020078e:	49650513          	addi	a0,a0,1174 # ffffffffc0206c20 <commands+0x288>
ffffffffc0200792:	9efff0ef          	jal	ra,ffffffffc0200180 <cprintf>
    cprintf("  s5       0x%08x\n", gpr->s5);
ffffffffc0200796:	744c                	ld	a1,168(s0)
ffffffffc0200798:	00006517          	auipc	a0,0x6
ffffffffc020079c:	4a050513          	addi	a0,a0,1184 # ffffffffc0206c38 <commands+0x2a0>
ffffffffc02007a0:	9e1ff0ef          	jal	ra,ffffffffc0200180 <cprintf>
    cprintf("  s6       0x%08x\n", gpr->s6);
ffffffffc02007a4:	784c                	ld	a1,176(s0)
ffffffffc02007a6:	00006517          	auipc	a0,0x6
ffffffffc02007aa:	4aa50513          	addi	a0,a0,1194 # ffffffffc0206c50 <commands+0x2b8>
ffffffffc02007ae:	9d3ff0ef          	jal	ra,ffffffffc0200180 <cprintf>
    cprintf("  s7       0x%08x\n", gpr->s7);
ffffffffc02007b2:	7c4c                	ld	a1,184(s0)
ffffffffc02007b4:	00006517          	auipc	a0,0x6
ffffffffc02007b8:	4b450513          	addi	a0,a0,1204 # ffffffffc0206c68 <commands+0x2d0>
ffffffffc02007bc:	9c5ff0ef          	jal	ra,ffffffffc0200180 <cprintf>
    cprintf("  s8       0x%08x\n", gpr->s8);
ffffffffc02007c0:	606c                	ld	a1,192(s0)
ffffffffc02007c2:	00006517          	auipc	a0,0x6
ffffffffc02007c6:	4be50513          	addi	a0,a0,1214 # ffffffffc0206c80 <commands+0x2e8>
ffffffffc02007ca:	9b7ff0ef          	jal	ra,ffffffffc0200180 <cprintf>
    cprintf("  s9       0x%08x\n", gpr->s9);
ffffffffc02007ce:	646c                	ld	a1,200(s0)
ffffffffc02007d0:	00006517          	auipc	a0,0x6
ffffffffc02007d4:	4c850513          	addi	a0,a0,1224 # ffffffffc0206c98 <commands+0x300>
ffffffffc02007d8:	9a9ff0ef          	jal	ra,ffffffffc0200180 <cprintf>
    cprintf("  s10      0x%08x\n", gpr->s10);
ffffffffc02007dc:	686c                	ld	a1,208(s0)
ffffffffc02007de:	00006517          	auipc	a0,0x6
ffffffffc02007e2:	4d250513          	addi	a0,a0,1234 # ffffffffc0206cb0 <commands+0x318>
ffffffffc02007e6:	99bff0ef          	jal	ra,ffffffffc0200180 <cprintf>
    cprintf("  s11      0x%08x\n", gpr->s11);
ffffffffc02007ea:	6c6c                	ld	a1,216(s0)
ffffffffc02007ec:	00006517          	auipc	a0,0x6
ffffffffc02007f0:	4dc50513          	addi	a0,a0,1244 # ffffffffc0206cc8 <commands+0x330>
ffffffffc02007f4:	98dff0ef          	jal	ra,ffffffffc0200180 <cprintf>
    cprintf("  t3       0x%08x\n", gpr->t3);
ffffffffc02007f8:	706c                	ld	a1,224(s0)
ffffffffc02007fa:	00006517          	auipc	a0,0x6
ffffffffc02007fe:	4e650513          	addi	a0,a0,1254 # ffffffffc0206ce0 <commands+0x348>
ffffffffc0200802:	97fff0ef          	jal	ra,ffffffffc0200180 <cprintf>
    cprintf("  t4       0x%08x\n", gpr->t4);
ffffffffc0200806:	746c                	ld	a1,232(s0)
ffffffffc0200808:	00006517          	auipc	a0,0x6
ffffffffc020080c:	4f050513          	addi	a0,a0,1264 # ffffffffc0206cf8 <commands+0x360>
ffffffffc0200810:	971ff0ef          	jal	ra,ffffffffc0200180 <cprintf>
    cprintf("  t5       0x%08x\n", gpr->t5);
ffffffffc0200814:	786c                	ld	a1,240(s0)
ffffffffc0200816:	00006517          	auipc	a0,0x6
ffffffffc020081a:	4fa50513          	addi	a0,a0,1274 # ffffffffc0206d10 <commands+0x378>
ffffffffc020081e:	963ff0ef          	jal	ra,ffffffffc0200180 <cprintf>
    cprintf("  t6       0x%08x\n", gpr->t6);
ffffffffc0200822:	7c6c                	ld	a1,248(s0)
}
ffffffffc0200824:	6402                	ld	s0,0(sp)
ffffffffc0200826:	60a2                	ld	ra,8(sp)
    cprintf("  t6       0x%08x\n", gpr->t6);
ffffffffc0200828:	00006517          	auipc	a0,0x6
ffffffffc020082c:	50050513          	addi	a0,a0,1280 # ffffffffc0206d28 <commands+0x390>
}
ffffffffc0200830:	0141                	addi	sp,sp,16
    cprintf("  t6       0x%08x\n", gpr->t6);
ffffffffc0200832:	b2b9                	j	ffffffffc0200180 <cprintf>

ffffffffc0200834 <print_trapframe>:
print_trapframe(struct trapframe *tf) {
ffffffffc0200834:	1141                	addi	sp,sp,-16
ffffffffc0200836:	e022                	sd	s0,0(sp)
    cprintf("trapframe at %p\n", tf);
ffffffffc0200838:	85aa                	mv	a1,a0
print_trapframe(struct trapframe *tf) {
ffffffffc020083a:	842a                	mv	s0,a0
    cprintf("trapframe at %p\n", tf);
ffffffffc020083c:	00006517          	auipc	a0,0x6
ffffffffc0200840:	50450513          	addi	a0,a0,1284 # ffffffffc0206d40 <commands+0x3a8>
print_trapframe(struct trapframe *tf) {
ffffffffc0200844:	e406                	sd	ra,8(sp)
    cprintf("trapframe at %p\n", tf);
ffffffffc0200846:	93bff0ef          	jal	ra,ffffffffc0200180 <cprintf>
    print_regs(&tf->gpr);
ffffffffc020084a:	8522                	mv	a0,s0
ffffffffc020084c:	e1dff0ef          	jal	ra,ffffffffc0200668 <print_regs>
    cprintf("  status   0x%08x\n", tf->status);
ffffffffc0200850:	10043583          	ld	a1,256(s0)
ffffffffc0200854:	00006517          	auipc	a0,0x6
ffffffffc0200858:	50450513          	addi	a0,a0,1284 # ffffffffc0206d58 <commands+0x3c0>
ffffffffc020085c:	925ff0ef          	jal	ra,ffffffffc0200180 <cprintf>
    cprintf("  epc      0x%08x\n", tf->epc);
ffffffffc0200860:	10843583          	ld	a1,264(s0)
ffffffffc0200864:	00006517          	auipc	a0,0x6
ffffffffc0200868:	50c50513          	addi	a0,a0,1292 # ffffffffc0206d70 <commands+0x3d8>
ffffffffc020086c:	915ff0ef          	jal	ra,ffffffffc0200180 <cprintf>
    cprintf("  tval 0x%08x\n", tf->tval);
ffffffffc0200870:	11043583          	ld	a1,272(s0)
ffffffffc0200874:	00006517          	auipc	a0,0x6
ffffffffc0200878:	51450513          	addi	a0,a0,1300 # ffffffffc0206d88 <commands+0x3f0>
ffffffffc020087c:	905ff0ef          	jal	ra,ffffffffc0200180 <cprintf>
    cprintf("  cause    0x%08x\n", tf->cause);
ffffffffc0200880:	11843583          	ld	a1,280(s0)
}
ffffffffc0200884:	6402                	ld	s0,0(sp)
ffffffffc0200886:	60a2                	ld	ra,8(sp)
    cprintf("  cause    0x%08x\n", tf->cause);
ffffffffc0200888:	00006517          	auipc	a0,0x6
ffffffffc020088c:	51050513          	addi	a0,a0,1296 # ffffffffc0206d98 <commands+0x400>
}
ffffffffc0200890:	0141                	addi	sp,sp,16
    cprintf("  cause    0x%08x\n", tf->cause);
ffffffffc0200892:	8efff06f          	j	ffffffffc0200180 <cprintf>

ffffffffc0200896 <pgfault_handler>:
            trap_in_kernel(tf) ? 'K' : 'U',
            tf->cause == CAUSE_STORE_PAGE_FAULT ? 'W' : 'R');
}

static int
pgfault_handler(struct trapframe *tf) {
ffffffffc0200896:	1101                	addi	sp,sp,-32
ffffffffc0200898:	e426                	sd	s1,8(sp)
    extern struct mm_struct *check_mm_struct;
    if(check_mm_struct !=NULL) { //used for test check_swap
ffffffffc020089a:	000b2497          	auipc	s1,0xb2
ffffffffc020089e:	04648493          	addi	s1,s1,70 # ffffffffc02b28e0 <check_mm_struct>
ffffffffc02008a2:	609c                	ld	a5,0(s1)
pgfault_handler(struct trapframe *tf) {
ffffffffc02008a4:	e822                	sd	s0,16(sp)
ffffffffc02008a6:	ec06                	sd	ra,24(sp)
ffffffffc02008a8:	842a                	mv	s0,a0
    if(check_mm_struct !=NULL) { //used for test check_swap
ffffffffc02008aa:	cbad                	beqz	a5,ffffffffc020091c <pgfault_handler+0x86>
    return (tf->status & SSTATUS_SPP) != 0;
ffffffffc02008ac:	10053783          	ld	a5,256(a0)
    cprintf("page fault at 0x%08x: %c/%c\n", tf->tval,
ffffffffc02008b0:	11053583          	ld	a1,272(a0)
ffffffffc02008b4:	04b00613          	li	a2,75
    return (tf->status & SSTATUS_SPP) != 0;
ffffffffc02008b8:	1007f793          	andi	a5,a5,256
    cprintf("page fault at 0x%08x: %c/%c\n", tf->tval,
ffffffffc02008bc:	c7b1                	beqz	a5,ffffffffc0200908 <pgfault_handler+0x72>
ffffffffc02008be:	11843703          	ld	a4,280(s0)
ffffffffc02008c2:	47bd                	li	a5,15
ffffffffc02008c4:	05700693          	li	a3,87
ffffffffc02008c8:	00f70463          	beq	a4,a5,ffffffffc02008d0 <pgfault_handler+0x3a>
ffffffffc02008cc:	05200693          	li	a3,82
ffffffffc02008d0:	00006517          	auipc	a0,0x6
ffffffffc02008d4:	4e050513          	addi	a0,a0,1248 # ffffffffc0206db0 <commands+0x418>
ffffffffc02008d8:	8a9ff0ef          	jal	ra,ffffffffc0200180 <cprintf>
            print_pgfault(tf);
        }
    struct mm_struct *mm;
    if (check_mm_struct != NULL) {
ffffffffc02008dc:	6088                	ld	a0,0(s1)
ffffffffc02008de:	cd1d                	beqz	a0,ffffffffc020091c <pgfault_handler+0x86>
        assert(current == idleproc);
ffffffffc02008e0:	000b2717          	auipc	a4,0xb2
ffffffffc02008e4:	01073703          	ld	a4,16(a4) # ffffffffc02b28f0 <current>
ffffffffc02008e8:	000b2797          	auipc	a5,0xb2
ffffffffc02008ec:	0107b783          	ld	a5,16(a5) # ffffffffc02b28f8 <idleproc>
ffffffffc02008f0:	04f71663          	bne	a4,a5,ffffffffc020093c <pgfault_handler+0xa6>
            print_pgfault(tf);
            panic("unhandled page fault.\n");
        }
        mm = current->mm;
    }
    return do_pgfault(mm, tf->cause, tf->tval);
ffffffffc02008f4:	11043603          	ld	a2,272(s0)
ffffffffc02008f8:	11843583          	ld	a1,280(s0)
}
ffffffffc02008fc:	6442                	ld	s0,16(sp)
ffffffffc02008fe:	60e2                	ld	ra,24(sp)
ffffffffc0200900:	64a2                	ld	s1,8(sp)
ffffffffc0200902:	6105                	addi	sp,sp,32
    return do_pgfault(mm, tf->cause, tf->tval);
ffffffffc0200904:	1780406f          	j	ffffffffc0204a7c <do_pgfault>
    cprintf("page fault at 0x%08x: %c/%c\n", tf->tval,
ffffffffc0200908:	11843703          	ld	a4,280(s0)
ffffffffc020090c:	47bd                	li	a5,15
ffffffffc020090e:	05500613          	li	a2,85
ffffffffc0200912:	05700693          	li	a3,87
ffffffffc0200916:	faf71be3          	bne	a4,a5,ffffffffc02008cc <pgfault_handler+0x36>
ffffffffc020091a:	bf5d                	j	ffffffffc02008d0 <pgfault_handler+0x3a>
        if (current == NULL) {
ffffffffc020091c:	000b2797          	auipc	a5,0xb2
ffffffffc0200920:	fd47b783          	ld	a5,-44(a5) # ffffffffc02b28f0 <current>
ffffffffc0200924:	cf85                	beqz	a5,ffffffffc020095c <pgfault_handler+0xc6>
    return do_pgfault(mm, tf->cause, tf->tval);
ffffffffc0200926:	11043603          	ld	a2,272(s0)
ffffffffc020092a:	11843583          	ld	a1,280(s0)
}
ffffffffc020092e:	6442                	ld	s0,16(sp)
ffffffffc0200930:	60e2                	ld	ra,24(sp)
ffffffffc0200932:	64a2                	ld	s1,8(sp)
        mm = current->mm;
ffffffffc0200934:	7788                	ld	a0,40(a5)
}
ffffffffc0200936:	6105                	addi	sp,sp,32
    return do_pgfault(mm, tf->cause, tf->tval);
ffffffffc0200938:	1440406f          	j	ffffffffc0204a7c <do_pgfault>
        assert(current == idleproc);
ffffffffc020093c:	00006697          	auipc	a3,0x6
ffffffffc0200940:	49468693          	addi	a3,a3,1172 # ffffffffc0206dd0 <commands+0x438>
ffffffffc0200944:	00006617          	auipc	a2,0x6
ffffffffc0200948:	4a460613          	addi	a2,a2,1188 # ffffffffc0206de8 <commands+0x450>
ffffffffc020094c:	06b00593          	li	a1,107
ffffffffc0200950:	00006517          	auipc	a0,0x6
ffffffffc0200954:	4b050513          	addi	a0,a0,1200 # ffffffffc0206e00 <commands+0x468>
ffffffffc0200958:	b23ff0ef          	jal	ra,ffffffffc020047a <__panic>
            print_trapframe(tf);
ffffffffc020095c:	8522                	mv	a0,s0
ffffffffc020095e:	ed7ff0ef          	jal	ra,ffffffffc0200834 <print_trapframe>
    return (tf->status & SSTATUS_SPP) != 0;
ffffffffc0200962:	10043783          	ld	a5,256(s0)
    cprintf("page fault at 0x%08x: %c/%c\n", tf->tval,
ffffffffc0200966:	11043583          	ld	a1,272(s0)
ffffffffc020096a:	04b00613          	li	a2,75
    return (tf->status & SSTATUS_SPP) != 0;
ffffffffc020096e:	1007f793          	andi	a5,a5,256
    cprintf("page fault at 0x%08x: %c/%c\n", tf->tval,
ffffffffc0200972:	e399                	bnez	a5,ffffffffc0200978 <pgfault_handler+0xe2>
ffffffffc0200974:	05500613          	li	a2,85
ffffffffc0200978:	11843703          	ld	a4,280(s0)
ffffffffc020097c:	47bd                	li	a5,15
ffffffffc020097e:	02f70663          	beq	a4,a5,ffffffffc02009aa <pgfault_handler+0x114>
ffffffffc0200982:	05200693          	li	a3,82
ffffffffc0200986:	00006517          	auipc	a0,0x6
ffffffffc020098a:	42a50513          	addi	a0,a0,1066 # ffffffffc0206db0 <commands+0x418>
ffffffffc020098e:	ff2ff0ef          	jal	ra,ffffffffc0200180 <cprintf>
            panic("unhandled page fault.\n");
ffffffffc0200992:	00006617          	auipc	a2,0x6
ffffffffc0200996:	48660613          	addi	a2,a2,1158 # ffffffffc0206e18 <commands+0x480>
ffffffffc020099a:	07200593          	li	a1,114
ffffffffc020099e:	00006517          	auipc	a0,0x6
ffffffffc02009a2:	46250513          	addi	a0,a0,1122 # ffffffffc0206e00 <commands+0x468>
ffffffffc02009a6:	ad5ff0ef          	jal	ra,ffffffffc020047a <__panic>
    cprintf("page fault at 0x%08x: %c/%c\n", tf->tval,
ffffffffc02009aa:	05700693          	li	a3,87
ffffffffc02009ae:	bfe1                	j	ffffffffc0200986 <pgfault_handler+0xf0>

ffffffffc02009b0 <interrupt_handler>:

static volatile int in_swap_tick_event = 0;
extern struct mm_struct *check_mm_struct;

void interrupt_handler(struct trapframe *tf) {
    intptr_t cause = (tf->cause << 1) >> 1;
ffffffffc02009b0:	11853783          	ld	a5,280(a0)
ffffffffc02009b4:	472d                	li	a4,11
ffffffffc02009b6:	0786                	slli	a5,a5,0x1
ffffffffc02009b8:	8385                	srli	a5,a5,0x1
ffffffffc02009ba:	08f76363          	bltu	a4,a5,ffffffffc0200a40 <interrupt_handler+0x90>
ffffffffc02009be:	00006717          	auipc	a4,0x6
ffffffffc02009c2:	51270713          	addi	a4,a4,1298 # ffffffffc0206ed0 <commands+0x538>
ffffffffc02009c6:	078a                	slli	a5,a5,0x2
ffffffffc02009c8:	97ba                	add	a5,a5,a4
ffffffffc02009ca:	439c                	lw	a5,0(a5)
ffffffffc02009cc:	97ba                	add	a5,a5,a4
ffffffffc02009ce:	8782                	jr	a5
            break;
        case IRQ_H_SOFT:
            cprintf("Hypervisor software interrupt\n");
            break;
        case IRQ_M_SOFT:
            cprintf("Machine software interrupt\n");
ffffffffc02009d0:	00006517          	auipc	a0,0x6
ffffffffc02009d4:	4c050513          	addi	a0,a0,1216 # ffffffffc0206e90 <commands+0x4f8>
ffffffffc02009d8:	fa8ff06f          	j	ffffffffc0200180 <cprintf>
            cprintf("Hypervisor software interrupt\n");
ffffffffc02009dc:	00006517          	auipc	a0,0x6
ffffffffc02009e0:	49450513          	addi	a0,a0,1172 # ffffffffc0206e70 <commands+0x4d8>
ffffffffc02009e4:	f9cff06f          	j	ffffffffc0200180 <cprintf>
            cprintf("User software interrupt\n");
ffffffffc02009e8:	00006517          	auipc	a0,0x6
ffffffffc02009ec:	44850513          	addi	a0,a0,1096 # ffffffffc0206e30 <commands+0x498>
ffffffffc02009f0:	f90ff06f          	j	ffffffffc0200180 <cprintf>
            cprintf("Supervisor software interrupt\n");
ffffffffc02009f4:	00006517          	auipc	a0,0x6
ffffffffc02009f8:	45c50513          	addi	a0,a0,1116 # ffffffffc0206e50 <commands+0x4b8>
ffffffffc02009fc:	f84ff06f          	j	ffffffffc0200180 <cprintf>
void interrupt_handler(struct trapframe *tf) {
ffffffffc0200a00:	1141                	addi	sp,sp,-16
ffffffffc0200a02:	e406                	sd	ra,8(sp)
            // "All bits besides SSIP and USIP in the sip register are
            // read-only." -- privileged spec1.9.1, 4.1.4, p59
            // In fact, Call sbi_set_timer will clear STIP, or you can clear it
            // directly.
            // clear_csr(sip, SIP_STIP);
            clock_set_next_event();
ffffffffc0200a04:	b5bff0ef          	jal	ra,ffffffffc020055e <clock_set_next_event>
            if (++ticks % TICK_NUM == 0 && current) {
ffffffffc0200a08:	000b2697          	auipc	a3,0xb2
ffffffffc0200a0c:	e7868693          	addi	a3,a3,-392 # ffffffffc02b2880 <ticks>
ffffffffc0200a10:	629c                	ld	a5,0(a3)
ffffffffc0200a12:	06400713          	li	a4,100
ffffffffc0200a16:	0785                	addi	a5,a5,1
ffffffffc0200a18:	02e7f733          	remu	a4,a5,a4
ffffffffc0200a1c:	e29c                	sd	a5,0(a3)
ffffffffc0200a1e:	eb01                	bnez	a4,ffffffffc0200a2e <interrupt_handler+0x7e>
ffffffffc0200a20:	000b2797          	auipc	a5,0xb2
ffffffffc0200a24:	ed07b783          	ld	a5,-304(a5) # ffffffffc02b28f0 <current>
ffffffffc0200a28:	c399                	beqz	a5,ffffffffc0200a2e <interrupt_handler+0x7e>
                // print_ticks();
                current->need_resched = 1;
ffffffffc0200a2a:	4705                	li	a4,1
ffffffffc0200a2c:	ef98                	sd	a4,24(a5)
            break;
        default:
            print_trapframe(tf);
            break;
    }
}
ffffffffc0200a2e:	60a2                	ld	ra,8(sp)
ffffffffc0200a30:	0141                	addi	sp,sp,16
ffffffffc0200a32:	8082                	ret
            cprintf("Supervisor external interrupt\n");
ffffffffc0200a34:	00006517          	auipc	a0,0x6
ffffffffc0200a38:	47c50513          	addi	a0,a0,1148 # ffffffffc0206eb0 <commands+0x518>
ffffffffc0200a3c:	f44ff06f          	j	ffffffffc0200180 <cprintf>
            print_trapframe(tf);
ffffffffc0200a40:	bbd5                	j	ffffffffc0200834 <print_trapframe>

ffffffffc0200a42 <exception_handler>:
void kernel_execve_ret(struct trapframe *tf,uintptr_t kstacktop);
void exception_handler(struct trapframe *tf) {
    int ret;
    switch (tf->cause) {
ffffffffc0200a42:	11853783          	ld	a5,280(a0)
void exception_handler(struct trapframe *tf) {
ffffffffc0200a46:	1101                	addi	sp,sp,-32
ffffffffc0200a48:	e822                	sd	s0,16(sp)
ffffffffc0200a4a:	ec06                	sd	ra,24(sp)
ffffffffc0200a4c:	e426                	sd	s1,8(sp)
ffffffffc0200a4e:	473d                	li	a4,15
ffffffffc0200a50:	842a                	mv	s0,a0
ffffffffc0200a52:	18f76563          	bltu	a4,a5,ffffffffc0200bdc <exception_handler+0x19a>
ffffffffc0200a56:	00006717          	auipc	a4,0x6
ffffffffc0200a5a:	64270713          	addi	a4,a4,1602 # ffffffffc0207098 <commands+0x700>
ffffffffc0200a5e:	078a                	slli	a5,a5,0x2
ffffffffc0200a60:	97ba                	add	a5,a5,a4
ffffffffc0200a62:	439c                	lw	a5,0(a5)
ffffffffc0200a64:	97ba                	add	a5,a5,a4
ffffffffc0200a66:	8782                	jr	a5
            //cprintf("Environment call from U-mode\n");
            tf->epc += 4;
            syscall();
            break;
        case CAUSE_SUPERVISOR_ECALL:
            cprintf("Environment call from S-mode\n");
ffffffffc0200a68:	00006517          	auipc	a0,0x6
ffffffffc0200a6c:	58850513          	addi	a0,a0,1416 # ffffffffc0206ff0 <commands+0x658>
ffffffffc0200a70:	f10ff0ef          	jal	ra,ffffffffc0200180 <cprintf>
            tf->epc += 4;
ffffffffc0200a74:	10843783          	ld	a5,264(s0)
            break;
        default:
            print_trapframe(tf);
            break;
    }
}
ffffffffc0200a78:	60e2                	ld	ra,24(sp)
ffffffffc0200a7a:	64a2                	ld	s1,8(sp)
            tf->epc += 4;
ffffffffc0200a7c:	0791                	addi	a5,a5,4
ffffffffc0200a7e:	10f43423          	sd	a5,264(s0)
}
ffffffffc0200a82:	6442                	ld	s0,16(sp)
ffffffffc0200a84:	6105                	addi	sp,sp,32
            syscall();
ffffffffc0200a86:	77e0506f          	j	ffffffffc0206204 <syscall>
            cprintf("Environment call from H-mode\n");
ffffffffc0200a8a:	00006517          	auipc	a0,0x6
ffffffffc0200a8e:	58650513          	addi	a0,a0,1414 # ffffffffc0207010 <commands+0x678>
}
ffffffffc0200a92:	6442                	ld	s0,16(sp)
ffffffffc0200a94:	60e2                	ld	ra,24(sp)
ffffffffc0200a96:	64a2                	ld	s1,8(sp)
ffffffffc0200a98:	6105                	addi	sp,sp,32
            cprintf("Instruction access fault\n");
ffffffffc0200a9a:	ee6ff06f          	j	ffffffffc0200180 <cprintf>
            cprintf("Environment call from M-mode\n");
ffffffffc0200a9e:	00006517          	auipc	a0,0x6
ffffffffc0200aa2:	59250513          	addi	a0,a0,1426 # ffffffffc0207030 <commands+0x698>
ffffffffc0200aa6:	b7f5                	j	ffffffffc0200a92 <exception_handler+0x50>
            cprintf("Instruction page fault\n");
ffffffffc0200aa8:	00006517          	auipc	a0,0x6
ffffffffc0200aac:	5a850513          	addi	a0,a0,1448 # ffffffffc0207050 <commands+0x6b8>
ffffffffc0200ab0:	b7cd                	j	ffffffffc0200a92 <exception_handler+0x50>
            cprintf("Load page fault\n");
ffffffffc0200ab2:	00006517          	auipc	a0,0x6
ffffffffc0200ab6:	5b650513          	addi	a0,a0,1462 # ffffffffc0207068 <commands+0x6d0>
ffffffffc0200aba:	ec6ff0ef          	jal	ra,ffffffffc0200180 <cprintf>
            if ((ret = pgfault_handler(tf)) != 0) {
ffffffffc0200abe:	8522                	mv	a0,s0
ffffffffc0200ac0:	dd7ff0ef          	jal	ra,ffffffffc0200896 <pgfault_handler>
ffffffffc0200ac4:	84aa                	mv	s1,a0
ffffffffc0200ac6:	12051d63          	bnez	a0,ffffffffc0200c00 <exception_handler+0x1be>
}
ffffffffc0200aca:	60e2                	ld	ra,24(sp)
ffffffffc0200acc:	6442                	ld	s0,16(sp)
ffffffffc0200ace:	64a2                	ld	s1,8(sp)
ffffffffc0200ad0:	6105                	addi	sp,sp,32
ffffffffc0200ad2:	8082                	ret
            cprintf("Store/AMO page fault\n");
ffffffffc0200ad4:	00006517          	auipc	a0,0x6
ffffffffc0200ad8:	5ac50513          	addi	a0,a0,1452 # ffffffffc0207080 <commands+0x6e8>
ffffffffc0200adc:	ea4ff0ef          	jal	ra,ffffffffc0200180 <cprintf>
            if ((ret = pgfault_handler(tf)) != 0) {
ffffffffc0200ae0:	8522                	mv	a0,s0
ffffffffc0200ae2:	db5ff0ef          	jal	ra,ffffffffc0200896 <pgfault_handler>
ffffffffc0200ae6:	84aa                	mv	s1,a0
ffffffffc0200ae8:	d16d                	beqz	a0,ffffffffc0200aca <exception_handler+0x88>
                print_trapframe(tf);
ffffffffc0200aea:	8522                	mv	a0,s0
ffffffffc0200aec:	d49ff0ef          	jal	ra,ffffffffc0200834 <print_trapframe>
                panic("handle pgfault failed. %e\n", ret);
ffffffffc0200af0:	86a6                	mv	a3,s1
ffffffffc0200af2:	00006617          	auipc	a2,0x6
ffffffffc0200af6:	4ae60613          	addi	a2,a2,1198 # ffffffffc0206fa0 <commands+0x608>
ffffffffc0200afa:	0f800593          	li	a1,248
ffffffffc0200afe:	00006517          	auipc	a0,0x6
ffffffffc0200b02:	30250513          	addi	a0,a0,770 # ffffffffc0206e00 <commands+0x468>
ffffffffc0200b06:	975ff0ef          	jal	ra,ffffffffc020047a <__panic>
            cprintf("Instruction address misaligned\n");
ffffffffc0200b0a:	00006517          	auipc	a0,0x6
ffffffffc0200b0e:	3f650513          	addi	a0,a0,1014 # ffffffffc0206f00 <commands+0x568>
ffffffffc0200b12:	b741                	j	ffffffffc0200a92 <exception_handler+0x50>
            cprintf("Instruction access fault\n");
ffffffffc0200b14:	00006517          	auipc	a0,0x6
ffffffffc0200b18:	40c50513          	addi	a0,a0,1036 # ffffffffc0206f20 <commands+0x588>
ffffffffc0200b1c:	bf9d                	j	ffffffffc0200a92 <exception_handler+0x50>
            cprintf("Illegal instruction\n");
ffffffffc0200b1e:	00006517          	auipc	a0,0x6
ffffffffc0200b22:	42250513          	addi	a0,a0,1058 # ffffffffc0206f40 <commands+0x5a8>
ffffffffc0200b26:	b7b5                	j	ffffffffc0200a92 <exception_handler+0x50>
            cprintf("Breakpoint\n");
ffffffffc0200b28:	00006517          	auipc	a0,0x6
ffffffffc0200b2c:	43050513          	addi	a0,a0,1072 # ffffffffc0206f58 <commands+0x5c0>
ffffffffc0200b30:	e50ff0ef          	jal	ra,ffffffffc0200180 <cprintf>
            if(tf->gpr.a7 == 10){
ffffffffc0200b34:	6458                	ld	a4,136(s0)
ffffffffc0200b36:	47a9                	li	a5,10
ffffffffc0200b38:	f8f719e3          	bne	a4,a5,ffffffffc0200aca <exception_handler+0x88>
                tf->epc += 4;
ffffffffc0200b3c:	10843783          	ld	a5,264(s0)
ffffffffc0200b40:	0791                	addi	a5,a5,4
ffffffffc0200b42:	10f43423          	sd	a5,264(s0)
                syscall();
ffffffffc0200b46:	6be050ef          	jal	ra,ffffffffc0206204 <syscall>
                kernel_execve_ret(tf,current->kstack+KSTACKSIZE);
ffffffffc0200b4a:	000b2797          	auipc	a5,0xb2
ffffffffc0200b4e:	da67b783          	ld	a5,-602(a5) # ffffffffc02b28f0 <current>
ffffffffc0200b52:	6b9c                	ld	a5,16(a5)
ffffffffc0200b54:	8522                	mv	a0,s0
}
ffffffffc0200b56:	6442                	ld	s0,16(sp)
ffffffffc0200b58:	60e2                	ld	ra,24(sp)
ffffffffc0200b5a:	64a2                	ld	s1,8(sp)
                kernel_execve_ret(tf,current->kstack+KSTACKSIZE);
ffffffffc0200b5c:	6589                	lui	a1,0x2
ffffffffc0200b5e:	95be                	add	a1,a1,a5
}
ffffffffc0200b60:	6105                	addi	sp,sp,32
                kernel_execve_ret(tf,current->kstack+KSTACKSIZE);
ffffffffc0200b62:	ac21                	j	ffffffffc0200d7a <kernel_execve_ret>
            cprintf("Load address misaligned\n");
ffffffffc0200b64:	00006517          	auipc	a0,0x6
ffffffffc0200b68:	40450513          	addi	a0,a0,1028 # ffffffffc0206f68 <commands+0x5d0>
ffffffffc0200b6c:	b71d                	j	ffffffffc0200a92 <exception_handler+0x50>
            cprintf("Load access fault\n");
ffffffffc0200b6e:	00006517          	auipc	a0,0x6
ffffffffc0200b72:	41a50513          	addi	a0,a0,1050 # ffffffffc0206f88 <commands+0x5f0>
ffffffffc0200b76:	e0aff0ef          	jal	ra,ffffffffc0200180 <cprintf>
            if ((ret = pgfault_handler(tf)) != 0) {
ffffffffc0200b7a:	8522                	mv	a0,s0
ffffffffc0200b7c:	d1bff0ef          	jal	ra,ffffffffc0200896 <pgfault_handler>
ffffffffc0200b80:	84aa                	mv	s1,a0
ffffffffc0200b82:	d521                	beqz	a0,ffffffffc0200aca <exception_handler+0x88>
                print_trapframe(tf);
ffffffffc0200b84:	8522                	mv	a0,s0
ffffffffc0200b86:	cafff0ef          	jal	ra,ffffffffc0200834 <print_trapframe>
                panic("handle pgfault failed. %e\n", ret);
ffffffffc0200b8a:	86a6                	mv	a3,s1
ffffffffc0200b8c:	00006617          	auipc	a2,0x6
ffffffffc0200b90:	41460613          	addi	a2,a2,1044 # ffffffffc0206fa0 <commands+0x608>
ffffffffc0200b94:	0cd00593          	li	a1,205
ffffffffc0200b98:	00006517          	auipc	a0,0x6
ffffffffc0200b9c:	26850513          	addi	a0,a0,616 # ffffffffc0206e00 <commands+0x468>
ffffffffc0200ba0:	8dbff0ef          	jal	ra,ffffffffc020047a <__panic>
            cprintf("Store/AMO access fault\n");
ffffffffc0200ba4:	00006517          	auipc	a0,0x6
ffffffffc0200ba8:	43450513          	addi	a0,a0,1076 # ffffffffc0206fd8 <commands+0x640>
ffffffffc0200bac:	dd4ff0ef          	jal	ra,ffffffffc0200180 <cprintf>
            if ((ret = pgfault_handler(tf)) != 0) {
ffffffffc0200bb0:	8522                	mv	a0,s0
ffffffffc0200bb2:	ce5ff0ef          	jal	ra,ffffffffc0200896 <pgfault_handler>
ffffffffc0200bb6:	84aa                	mv	s1,a0
ffffffffc0200bb8:	f00509e3          	beqz	a0,ffffffffc0200aca <exception_handler+0x88>
                print_trapframe(tf);
ffffffffc0200bbc:	8522                	mv	a0,s0
ffffffffc0200bbe:	c77ff0ef          	jal	ra,ffffffffc0200834 <print_trapframe>
                panic("handle pgfault failed. %e\n", ret);
ffffffffc0200bc2:	86a6                	mv	a3,s1
ffffffffc0200bc4:	00006617          	auipc	a2,0x6
ffffffffc0200bc8:	3dc60613          	addi	a2,a2,988 # ffffffffc0206fa0 <commands+0x608>
ffffffffc0200bcc:	0d700593          	li	a1,215
ffffffffc0200bd0:	00006517          	auipc	a0,0x6
ffffffffc0200bd4:	23050513          	addi	a0,a0,560 # ffffffffc0206e00 <commands+0x468>
ffffffffc0200bd8:	8a3ff0ef          	jal	ra,ffffffffc020047a <__panic>
            print_trapframe(tf);
ffffffffc0200bdc:	8522                	mv	a0,s0
}
ffffffffc0200bde:	6442                	ld	s0,16(sp)
ffffffffc0200be0:	60e2                	ld	ra,24(sp)
ffffffffc0200be2:	64a2                	ld	s1,8(sp)
ffffffffc0200be4:	6105                	addi	sp,sp,32
            print_trapframe(tf);
ffffffffc0200be6:	b1b9                	j	ffffffffc0200834 <print_trapframe>
            panic("AMO address misaligned\n");
ffffffffc0200be8:	00006617          	auipc	a2,0x6
ffffffffc0200bec:	3d860613          	addi	a2,a2,984 # ffffffffc0206fc0 <commands+0x628>
ffffffffc0200bf0:	0d100593          	li	a1,209
ffffffffc0200bf4:	00006517          	auipc	a0,0x6
ffffffffc0200bf8:	20c50513          	addi	a0,a0,524 # ffffffffc0206e00 <commands+0x468>
ffffffffc0200bfc:	87fff0ef          	jal	ra,ffffffffc020047a <__panic>
                print_trapframe(tf);
ffffffffc0200c00:	8522                	mv	a0,s0
ffffffffc0200c02:	c33ff0ef          	jal	ra,ffffffffc0200834 <print_trapframe>
                panic("handle pgfault failed. %e\n", ret);
ffffffffc0200c06:	86a6                	mv	a3,s1
ffffffffc0200c08:	00006617          	auipc	a2,0x6
ffffffffc0200c0c:	39860613          	addi	a2,a2,920 # ffffffffc0206fa0 <commands+0x608>
ffffffffc0200c10:	0f100593          	li	a1,241
ffffffffc0200c14:	00006517          	auipc	a0,0x6
ffffffffc0200c18:	1ec50513          	addi	a0,a0,492 # ffffffffc0206e00 <commands+0x468>
ffffffffc0200c1c:	85fff0ef          	jal	ra,ffffffffc020047a <__panic>

ffffffffc0200c20 <trap>:
 * trap - handles or dispatches an exception/interrupt. if and when trap() returns,
 * the code in kern/trap/trapentry.S restores the old CPU state saved in the
 * trapframe and then uses the iret instruction to return from the exception.
 * */
void
trap(struct trapframe *tf) {
ffffffffc0200c20:	1101                	addi	sp,sp,-32
ffffffffc0200c22:	e822                	sd	s0,16(sp)
    // dispatch based on what type of trap occurred
//    cputs("some trap");
    if (current == NULL) {
ffffffffc0200c24:	000b2417          	auipc	s0,0xb2
ffffffffc0200c28:	ccc40413          	addi	s0,s0,-820 # ffffffffc02b28f0 <current>
ffffffffc0200c2c:	6018                	ld	a4,0(s0)
trap(struct trapframe *tf) {
ffffffffc0200c2e:	ec06                	sd	ra,24(sp)
ffffffffc0200c30:	e426                	sd	s1,8(sp)
ffffffffc0200c32:	e04a                	sd	s2,0(sp)
    if ((intptr_t)tf->cause < 0) {
ffffffffc0200c34:	11853683          	ld	a3,280(a0)
    if (current == NULL) {
ffffffffc0200c38:	cf1d                	beqz	a4,ffffffffc0200c76 <trap+0x56>
    return (tf->status & SSTATUS_SPP) != 0;
ffffffffc0200c3a:	10053483          	ld	s1,256(a0)
        trap_dispatch(tf);
    } else {
        struct trapframe *otf = current->tf;
ffffffffc0200c3e:	0a073903          	ld	s2,160(a4)
        current->tf = tf;
ffffffffc0200c42:	f348                	sd	a0,160(a4)
    return (tf->status & SSTATUS_SPP) != 0;
ffffffffc0200c44:	1004f493          	andi	s1,s1,256
    if ((intptr_t)tf->cause < 0) {
ffffffffc0200c48:	0206c463          	bltz	a3,ffffffffc0200c70 <trap+0x50>
        exception_handler(tf);
ffffffffc0200c4c:	df7ff0ef          	jal	ra,ffffffffc0200a42 <exception_handler>

        bool in_kernel = trap_in_kernel(tf);

        trap_dispatch(tf);

        current->tf = otf;
ffffffffc0200c50:	601c                	ld	a5,0(s0)
ffffffffc0200c52:	0b27b023          	sd	s2,160(a5)
        if (!in_kernel) {
ffffffffc0200c56:	e499                	bnez	s1,ffffffffc0200c64 <trap+0x44>
            if (current->flags & PF_EXITING) {
ffffffffc0200c58:	0b07a703          	lw	a4,176(a5)
ffffffffc0200c5c:	8b05                	andi	a4,a4,1
ffffffffc0200c5e:	e329                	bnez	a4,ffffffffc0200ca0 <trap+0x80>
                do_exit(-E_KILLED);
            }
            if (current->need_resched) {
ffffffffc0200c60:	6f9c                	ld	a5,24(a5)
ffffffffc0200c62:	eb85                	bnez	a5,ffffffffc0200c92 <trap+0x72>
                schedule();
            }
        }
    }
}
ffffffffc0200c64:	60e2                	ld	ra,24(sp)
ffffffffc0200c66:	6442                	ld	s0,16(sp)
ffffffffc0200c68:	64a2                	ld	s1,8(sp)
ffffffffc0200c6a:	6902                	ld	s2,0(sp)
ffffffffc0200c6c:	6105                	addi	sp,sp,32
ffffffffc0200c6e:	8082                	ret
        interrupt_handler(tf);
ffffffffc0200c70:	d41ff0ef          	jal	ra,ffffffffc02009b0 <interrupt_handler>
ffffffffc0200c74:	bff1                	j	ffffffffc0200c50 <trap+0x30>
    if ((intptr_t)tf->cause < 0) {
ffffffffc0200c76:	0006c863          	bltz	a3,ffffffffc0200c86 <trap+0x66>
}
ffffffffc0200c7a:	6442                	ld	s0,16(sp)
ffffffffc0200c7c:	60e2                	ld	ra,24(sp)
ffffffffc0200c7e:	64a2                	ld	s1,8(sp)
ffffffffc0200c80:	6902                	ld	s2,0(sp)
ffffffffc0200c82:	6105                	addi	sp,sp,32
        exception_handler(tf);
ffffffffc0200c84:	bb7d                	j	ffffffffc0200a42 <exception_handler>
}
ffffffffc0200c86:	6442                	ld	s0,16(sp)
ffffffffc0200c88:	60e2                	ld	ra,24(sp)
ffffffffc0200c8a:	64a2                	ld	s1,8(sp)
ffffffffc0200c8c:	6902                	ld	s2,0(sp)
ffffffffc0200c8e:	6105                	addi	sp,sp,32
        interrupt_handler(tf);
ffffffffc0200c90:	b305                	j	ffffffffc02009b0 <interrupt_handler>
}
ffffffffc0200c92:	6442                	ld	s0,16(sp)
ffffffffc0200c94:	60e2                	ld	ra,24(sp)
ffffffffc0200c96:	64a2                	ld	s1,8(sp)
ffffffffc0200c98:	6902                	ld	s2,0(sp)
ffffffffc0200c9a:	6105                	addi	sp,sp,32
                schedule();
ffffffffc0200c9c:	47c0506f          	j	ffffffffc0206118 <schedule>
                do_exit(-E_KILLED);
ffffffffc0200ca0:	555d                	li	a0,-9
ffffffffc0200ca2:	7bc040ef          	jal	ra,ffffffffc020545e <do_exit>
            if (current->need_resched) {
ffffffffc0200ca6:	601c                	ld	a5,0(s0)
ffffffffc0200ca8:	bf65                	j	ffffffffc0200c60 <trap+0x40>
	...

ffffffffc0200cac <__alltraps>:
    LOAD x2, 2*REGBYTES(sp)
    .endm

    .globl __alltraps
__alltraps:
    SAVE_ALL
ffffffffc0200cac:	14011173          	csrrw	sp,sscratch,sp
ffffffffc0200cb0:	00011463          	bnez	sp,ffffffffc0200cb8 <__alltraps+0xc>
ffffffffc0200cb4:	14002173          	csrr	sp,sscratch
ffffffffc0200cb8:	712d                	addi	sp,sp,-288
ffffffffc0200cba:	e002                	sd	zero,0(sp)
ffffffffc0200cbc:	e406                	sd	ra,8(sp)
ffffffffc0200cbe:	ec0e                	sd	gp,24(sp)
ffffffffc0200cc0:	f012                	sd	tp,32(sp)
ffffffffc0200cc2:	f416                	sd	t0,40(sp)
ffffffffc0200cc4:	f81a                	sd	t1,48(sp)
ffffffffc0200cc6:	fc1e                	sd	t2,56(sp)
ffffffffc0200cc8:	e0a2                	sd	s0,64(sp)
ffffffffc0200cca:	e4a6                	sd	s1,72(sp)
ffffffffc0200ccc:	e8aa                	sd	a0,80(sp)
ffffffffc0200cce:	ecae                	sd	a1,88(sp)
ffffffffc0200cd0:	f0b2                	sd	a2,96(sp)
ffffffffc0200cd2:	f4b6                	sd	a3,104(sp)
ffffffffc0200cd4:	f8ba                	sd	a4,112(sp)
ffffffffc0200cd6:	fcbe                	sd	a5,120(sp)
ffffffffc0200cd8:	e142                	sd	a6,128(sp)
ffffffffc0200cda:	e546                	sd	a7,136(sp)
ffffffffc0200cdc:	e94a                	sd	s2,144(sp)
ffffffffc0200cde:	ed4e                	sd	s3,152(sp)
ffffffffc0200ce0:	f152                	sd	s4,160(sp)
ffffffffc0200ce2:	f556                	sd	s5,168(sp)
ffffffffc0200ce4:	f95a                	sd	s6,176(sp)
ffffffffc0200ce6:	fd5e                	sd	s7,184(sp)
ffffffffc0200ce8:	e1e2                	sd	s8,192(sp)
ffffffffc0200cea:	e5e6                	sd	s9,200(sp)
ffffffffc0200cec:	e9ea                	sd	s10,208(sp)
ffffffffc0200cee:	edee                	sd	s11,216(sp)
ffffffffc0200cf0:	f1f2                	sd	t3,224(sp)
ffffffffc0200cf2:	f5f6                	sd	t4,232(sp)
ffffffffc0200cf4:	f9fa                	sd	t5,240(sp)
ffffffffc0200cf6:	fdfe                	sd	t6,248(sp)
ffffffffc0200cf8:	14001473          	csrrw	s0,sscratch,zero
ffffffffc0200cfc:	100024f3          	csrr	s1,sstatus
ffffffffc0200d00:	14102973          	csrr	s2,sepc
ffffffffc0200d04:	143029f3          	csrr	s3,stval
ffffffffc0200d08:	14202a73          	csrr	s4,scause
ffffffffc0200d0c:	e822                	sd	s0,16(sp)
ffffffffc0200d0e:	e226                	sd	s1,256(sp)
ffffffffc0200d10:	e64a                	sd	s2,264(sp)
ffffffffc0200d12:	ea4e                	sd	s3,272(sp)
ffffffffc0200d14:	ee52                	sd	s4,280(sp)

    move  a0, sp
ffffffffc0200d16:	850a                	mv	a0,sp
    jal trap
ffffffffc0200d18:	f09ff0ef          	jal	ra,ffffffffc0200c20 <trap>

ffffffffc0200d1c <__trapret>:
    # sp should be the same as before "jal trap"

    .globl __trapret
__trapret:
    RESTORE_ALL
ffffffffc0200d1c:	6492                	ld	s1,256(sp)
ffffffffc0200d1e:	6932                	ld	s2,264(sp)
ffffffffc0200d20:	1004f413          	andi	s0,s1,256
ffffffffc0200d24:	e401                	bnez	s0,ffffffffc0200d2c <__trapret+0x10>
ffffffffc0200d26:	1200                	addi	s0,sp,288
ffffffffc0200d28:	14041073          	csrw	sscratch,s0
ffffffffc0200d2c:	10049073          	csrw	sstatus,s1
ffffffffc0200d30:	14191073          	csrw	sepc,s2
ffffffffc0200d34:	60a2                	ld	ra,8(sp)
ffffffffc0200d36:	61e2                	ld	gp,24(sp)
ffffffffc0200d38:	7202                	ld	tp,32(sp)
ffffffffc0200d3a:	72a2                	ld	t0,40(sp)
ffffffffc0200d3c:	7342                	ld	t1,48(sp)
ffffffffc0200d3e:	73e2                	ld	t2,56(sp)
ffffffffc0200d40:	6406                	ld	s0,64(sp)
ffffffffc0200d42:	64a6                	ld	s1,72(sp)
ffffffffc0200d44:	6546                	ld	a0,80(sp)
ffffffffc0200d46:	65e6                	ld	a1,88(sp)
ffffffffc0200d48:	7606                	ld	a2,96(sp)
ffffffffc0200d4a:	76a6                	ld	a3,104(sp)
ffffffffc0200d4c:	7746                	ld	a4,112(sp)
ffffffffc0200d4e:	77e6                	ld	a5,120(sp)
ffffffffc0200d50:	680a                	ld	a6,128(sp)
ffffffffc0200d52:	68aa                	ld	a7,136(sp)
ffffffffc0200d54:	694a                	ld	s2,144(sp)
ffffffffc0200d56:	69ea                	ld	s3,152(sp)
ffffffffc0200d58:	7a0a                	ld	s4,160(sp)
ffffffffc0200d5a:	7aaa                	ld	s5,168(sp)
ffffffffc0200d5c:	7b4a                	ld	s6,176(sp)
ffffffffc0200d5e:	7bea                	ld	s7,184(sp)
ffffffffc0200d60:	6c0e                	ld	s8,192(sp)
ffffffffc0200d62:	6cae                	ld	s9,200(sp)
ffffffffc0200d64:	6d4e                	ld	s10,208(sp)
ffffffffc0200d66:	6dee                	ld	s11,216(sp)
ffffffffc0200d68:	7e0e                	ld	t3,224(sp)
ffffffffc0200d6a:	7eae                	ld	t4,232(sp)
ffffffffc0200d6c:	7f4e                	ld	t5,240(sp)
ffffffffc0200d6e:	7fee                	ld	t6,248(sp)
ffffffffc0200d70:	6142                	ld	sp,16(sp)
    # return from supervisor call
    sret
ffffffffc0200d72:	10200073          	sret

ffffffffc0200d76 <forkrets>:
 
    .globl forkrets
forkrets:
    # set stack to this new process's trapframe
    move sp, a0
ffffffffc0200d76:	812a                	mv	sp,a0
    j __trapret
ffffffffc0200d78:	b755                	j	ffffffffc0200d1c <__trapret>

ffffffffc0200d7a <kernel_execve_ret>:

    .global kernel_execve_ret
kernel_execve_ret:
    // adjust sp to beneath kstacktop of current process
    addi a1, a1, -36*REGBYTES
ffffffffc0200d7a:	ee058593          	addi	a1,a1,-288 # 1ee0 <_binary_obj___user_faultread_out_size-0x7cd8>

    // copy from previous trapframe to new trapframe
    LOAD s1, 35*REGBYTES(a0)
ffffffffc0200d7e:	11853483          	ld	s1,280(a0)
    STORE s1, 35*REGBYTES(a1)
ffffffffc0200d82:	1095bc23          	sd	s1,280(a1)
    LOAD s1, 34*REGBYTES(a0)
ffffffffc0200d86:	11053483          	ld	s1,272(a0)
    STORE s1, 34*REGBYTES(a1)
ffffffffc0200d8a:	1095b823          	sd	s1,272(a1)
    LOAD s1, 33*REGBYTES(a0)
ffffffffc0200d8e:	10853483          	ld	s1,264(a0)
    STORE s1, 33*REGBYTES(a1)
ffffffffc0200d92:	1095b423          	sd	s1,264(a1)
    LOAD s1, 32*REGBYTES(a0)
ffffffffc0200d96:	10053483          	ld	s1,256(a0)
    STORE s1, 32*REGBYTES(a1)
ffffffffc0200d9a:	1095b023          	sd	s1,256(a1)
    LOAD s1, 31*REGBYTES(a0)
ffffffffc0200d9e:	7d64                	ld	s1,248(a0)
    STORE s1, 31*REGBYTES(a1)
ffffffffc0200da0:	fde4                	sd	s1,248(a1)
    LOAD s1, 30*REGBYTES(a0)
ffffffffc0200da2:	7964                	ld	s1,240(a0)
    STORE s1, 30*REGBYTES(a1)
ffffffffc0200da4:	f9e4                	sd	s1,240(a1)
    LOAD s1, 29*REGBYTES(a0)
ffffffffc0200da6:	7564                	ld	s1,232(a0)
    STORE s1, 29*REGBYTES(a1)
ffffffffc0200da8:	f5e4                	sd	s1,232(a1)
    LOAD s1, 28*REGBYTES(a0)
ffffffffc0200daa:	7164                	ld	s1,224(a0)
    STORE s1, 28*REGBYTES(a1)
ffffffffc0200dac:	f1e4                	sd	s1,224(a1)
    LOAD s1, 27*REGBYTES(a0)
ffffffffc0200dae:	6d64                	ld	s1,216(a0)
    STORE s1, 27*REGBYTES(a1)
ffffffffc0200db0:	ede4                	sd	s1,216(a1)
    LOAD s1, 26*REGBYTES(a0)
ffffffffc0200db2:	6964                	ld	s1,208(a0)
    STORE s1, 26*REGBYTES(a1)
ffffffffc0200db4:	e9e4                	sd	s1,208(a1)
    LOAD s1, 25*REGBYTES(a0)
ffffffffc0200db6:	6564                	ld	s1,200(a0)
    STORE s1, 25*REGBYTES(a1)
ffffffffc0200db8:	e5e4                	sd	s1,200(a1)
    LOAD s1, 24*REGBYTES(a0)
ffffffffc0200dba:	6164                	ld	s1,192(a0)
    STORE s1, 24*REGBYTES(a1)
ffffffffc0200dbc:	e1e4                	sd	s1,192(a1)
    LOAD s1, 23*REGBYTES(a0)
ffffffffc0200dbe:	7d44                	ld	s1,184(a0)
    STORE s1, 23*REGBYTES(a1)
ffffffffc0200dc0:	fdc4                	sd	s1,184(a1)
    LOAD s1, 22*REGBYTES(a0)
ffffffffc0200dc2:	7944                	ld	s1,176(a0)
    STORE s1, 22*REGBYTES(a1)
ffffffffc0200dc4:	f9c4                	sd	s1,176(a1)
    LOAD s1, 21*REGBYTES(a0)
ffffffffc0200dc6:	7544                	ld	s1,168(a0)
    STORE s1, 21*REGBYTES(a1)
ffffffffc0200dc8:	f5c4                	sd	s1,168(a1)
    LOAD s1, 20*REGBYTES(a0)
ffffffffc0200dca:	7144                	ld	s1,160(a0)
    STORE s1, 20*REGBYTES(a1)
ffffffffc0200dcc:	f1c4                	sd	s1,160(a1)
    LOAD s1, 19*REGBYTES(a0)
ffffffffc0200dce:	6d44                	ld	s1,152(a0)
    STORE s1, 19*REGBYTES(a1)
ffffffffc0200dd0:	edc4                	sd	s1,152(a1)
    LOAD s1, 18*REGBYTES(a0)
ffffffffc0200dd2:	6944                	ld	s1,144(a0)
    STORE s1, 18*REGBYTES(a1)
ffffffffc0200dd4:	e9c4                	sd	s1,144(a1)
    LOAD s1, 17*REGBYTES(a0)
ffffffffc0200dd6:	6544                	ld	s1,136(a0)
    STORE s1, 17*REGBYTES(a1)
ffffffffc0200dd8:	e5c4                	sd	s1,136(a1)
    LOAD s1, 16*REGBYTES(a0)
ffffffffc0200dda:	6144                	ld	s1,128(a0)
    STORE s1, 16*REGBYTES(a1)
ffffffffc0200ddc:	e1c4                	sd	s1,128(a1)
    LOAD s1, 15*REGBYTES(a0)
ffffffffc0200dde:	7d24                	ld	s1,120(a0)
    STORE s1, 15*REGBYTES(a1)
ffffffffc0200de0:	fda4                	sd	s1,120(a1)
    LOAD s1, 14*REGBYTES(a0)
ffffffffc0200de2:	7924                	ld	s1,112(a0)
    STORE s1, 14*REGBYTES(a1)
ffffffffc0200de4:	f9a4                	sd	s1,112(a1)
    LOAD s1, 13*REGBYTES(a0)
ffffffffc0200de6:	7524                	ld	s1,104(a0)
    STORE s1, 13*REGBYTES(a1)
ffffffffc0200de8:	f5a4                	sd	s1,104(a1)
    LOAD s1, 12*REGBYTES(a0)
ffffffffc0200dea:	7124                	ld	s1,96(a0)
    STORE s1, 12*REGBYTES(a1)
ffffffffc0200dec:	f1a4                	sd	s1,96(a1)
    LOAD s1, 11*REGBYTES(a0)
ffffffffc0200dee:	6d24                	ld	s1,88(a0)
    STORE s1, 11*REGBYTES(a1)
ffffffffc0200df0:	eda4                	sd	s1,88(a1)
    LOAD s1, 10*REGBYTES(a0)
ffffffffc0200df2:	6924                	ld	s1,80(a0)
    STORE s1, 10*REGBYTES(a1)
ffffffffc0200df4:	e9a4                	sd	s1,80(a1)
    LOAD s1, 9*REGBYTES(a0)
ffffffffc0200df6:	6524                	ld	s1,72(a0)
    STORE s1, 9*REGBYTES(a1)
ffffffffc0200df8:	e5a4                	sd	s1,72(a1)
    LOAD s1, 8*REGBYTES(a0)
ffffffffc0200dfa:	6124                	ld	s1,64(a0)
    STORE s1, 8*REGBYTES(a1)
ffffffffc0200dfc:	e1a4                	sd	s1,64(a1)
    LOAD s1, 7*REGBYTES(a0)
ffffffffc0200dfe:	7d04                	ld	s1,56(a0)
    STORE s1, 7*REGBYTES(a1)
ffffffffc0200e00:	fd84                	sd	s1,56(a1)
    LOAD s1, 6*REGBYTES(a0)
ffffffffc0200e02:	7904                	ld	s1,48(a0)
    STORE s1, 6*REGBYTES(a1)
ffffffffc0200e04:	f984                	sd	s1,48(a1)
    LOAD s1, 5*REGBYTES(a0)
ffffffffc0200e06:	7504                	ld	s1,40(a0)
    STORE s1, 5*REGBYTES(a1)
ffffffffc0200e08:	f584                	sd	s1,40(a1)
    LOAD s1, 4*REGBYTES(a0)
ffffffffc0200e0a:	7104                	ld	s1,32(a0)
    STORE s1, 4*REGBYTES(a1)
ffffffffc0200e0c:	f184                	sd	s1,32(a1)
    LOAD s1, 3*REGBYTES(a0)
ffffffffc0200e0e:	6d04                	ld	s1,24(a0)
    STORE s1, 3*REGBYTES(a1)
ffffffffc0200e10:	ed84                	sd	s1,24(a1)
    LOAD s1, 2*REGBYTES(a0)
ffffffffc0200e12:	6904                	ld	s1,16(a0)
    STORE s1, 2*REGBYTES(a1)
ffffffffc0200e14:	e984                	sd	s1,16(a1)
    LOAD s1, 1*REGBYTES(a0)
ffffffffc0200e16:	6504                	ld	s1,8(a0)
    STORE s1, 1*REGBYTES(a1)
ffffffffc0200e18:	e584                	sd	s1,8(a1)
    LOAD s1, 0*REGBYTES(a0)
ffffffffc0200e1a:	6104                	ld	s1,0(a0)
    STORE s1, 0*REGBYTES(a1)
ffffffffc0200e1c:	e184                	sd	s1,0(a1)

    // acutually adjust sp
    move sp, a1
ffffffffc0200e1e:	812e                	mv	sp,a1
ffffffffc0200e20:	bdf5                	j	ffffffffc0200d1c <__trapret>

ffffffffc0200e22 <default_init>:
 * list_init - initialize a new entry
 * @elm:        new entry to be initialized
 * */
static inline void
list_init(list_entry_t *elm) {
    elm->prev = elm->next = elm;
ffffffffc0200e22:	000ae797          	auipc	a5,0xae
ffffffffc0200e26:	98e78793          	addi	a5,a5,-1650 # ffffffffc02ae7b0 <free_area>
ffffffffc0200e2a:	e79c                	sd	a5,8(a5)
ffffffffc0200e2c:	e39c                	sd	a5,0(a5)
#define nr_free (free_area.nr_free)

static void
default_init(void) {
    list_init(&free_list);
    nr_free = 0;
ffffffffc0200e2e:	0007a823          	sw	zero,16(a5)
}
ffffffffc0200e32:	8082                	ret

ffffffffc0200e34 <default_nr_free_pages>:
}

static size_t
default_nr_free_pages(void) {
    return nr_free;
}
ffffffffc0200e34:	000ae517          	auipc	a0,0xae
ffffffffc0200e38:	98c56503          	lwu	a0,-1652(a0) # ffffffffc02ae7c0 <free_area+0x10>
ffffffffc0200e3c:	8082                	ret

ffffffffc0200e3e <default_check>:
}

// LAB2: below code is used to check the first fit allocation algorithm (your EXERCISE 1) 
// NOTICE: You SHOULD NOT CHANGE basic_check, default_check functions!
static void
default_check(void) {
ffffffffc0200e3e:	715d                	addi	sp,sp,-80
ffffffffc0200e40:	e0a2                	sd	s0,64(sp)
 * list_next - get the next entry
 * @listelm:    the list head
 **/
static inline list_entry_t *
list_next(list_entry_t *listelm) {
    return listelm->next;
ffffffffc0200e42:	000ae417          	auipc	s0,0xae
ffffffffc0200e46:	96e40413          	addi	s0,s0,-1682 # ffffffffc02ae7b0 <free_area>
ffffffffc0200e4a:	641c                	ld	a5,8(s0)
ffffffffc0200e4c:	e486                	sd	ra,72(sp)
ffffffffc0200e4e:	fc26                	sd	s1,56(sp)
ffffffffc0200e50:	f84a                	sd	s2,48(sp)
ffffffffc0200e52:	f44e                	sd	s3,40(sp)
ffffffffc0200e54:	f052                	sd	s4,32(sp)
ffffffffc0200e56:	ec56                	sd	s5,24(sp)
ffffffffc0200e58:	e85a                	sd	s6,16(sp)
ffffffffc0200e5a:	e45e                	sd	s7,8(sp)
ffffffffc0200e5c:	e062                	sd	s8,0(sp)
    int count = 0, total = 0;
    list_entry_t *le = &free_list;
    while ((le = list_next(le)) != &free_list) {
ffffffffc0200e5e:	2a878d63          	beq	a5,s0,ffffffffc0201118 <default_check+0x2da>
    int count = 0, total = 0;
ffffffffc0200e62:	4481                	li	s1,0
ffffffffc0200e64:	4901                	li	s2,0
 * test_bit - Determine whether a bit is set
 * @nr:     the bit to test
 * @addr:   the address to count from
 * */
static inline bool test_bit(int nr, volatile void *addr) {
    return (((*(volatile unsigned long *)addr) >> nr) & 1);
ffffffffc0200e66:	ff07b703          	ld	a4,-16(a5)
        struct Page *p = le2page(le, page_link);
        assert(PageProperty(p));
ffffffffc0200e6a:	8b09                	andi	a4,a4,2
ffffffffc0200e6c:	2a070a63          	beqz	a4,ffffffffc0201120 <default_check+0x2e2>
        count ++, total += p->property;
ffffffffc0200e70:	ff87a703          	lw	a4,-8(a5)
ffffffffc0200e74:	679c                	ld	a5,8(a5)
ffffffffc0200e76:	2905                	addiw	s2,s2,1
ffffffffc0200e78:	9cb9                	addw	s1,s1,a4
    while ((le = list_next(le)) != &free_list) {
ffffffffc0200e7a:	fe8796e3          	bne	a5,s0,ffffffffc0200e66 <default_check+0x28>
    }
    assert(total == nr_free_pages());
ffffffffc0200e7e:	89a6                	mv	s3,s1
ffffffffc0200e80:	733000ef          	jal	ra,ffffffffc0201db2 <nr_free_pages>
ffffffffc0200e84:	6f351e63          	bne	a0,s3,ffffffffc0201580 <default_check+0x742>
    assert((p0 = alloc_page()) != NULL);
ffffffffc0200e88:	4505                	li	a0,1
ffffffffc0200e8a:	657000ef          	jal	ra,ffffffffc0201ce0 <alloc_pages>
ffffffffc0200e8e:	8aaa                	mv	s5,a0
ffffffffc0200e90:	42050863          	beqz	a0,ffffffffc02012c0 <default_check+0x482>
    assert((p1 = alloc_page()) != NULL);
ffffffffc0200e94:	4505                	li	a0,1
ffffffffc0200e96:	64b000ef          	jal	ra,ffffffffc0201ce0 <alloc_pages>
ffffffffc0200e9a:	89aa                	mv	s3,a0
ffffffffc0200e9c:	70050263          	beqz	a0,ffffffffc02015a0 <default_check+0x762>
    assert((p2 = alloc_page()) != NULL);
ffffffffc0200ea0:	4505                	li	a0,1
ffffffffc0200ea2:	63f000ef          	jal	ra,ffffffffc0201ce0 <alloc_pages>
ffffffffc0200ea6:	8a2a                	mv	s4,a0
ffffffffc0200ea8:	48050c63          	beqz	a0,ffffffffc0201340 <default_check+0x502>
    assert(p0 != p1 && p0 != p2 && p1 != p2);
ffffffffc0200eac:	293a8a63          	beq	s5,s3,ffffffffc0201140 <default_check+0x302>
ffffffffc0200eb0:	28aa8863          	beq	s5,a0,ffffffffc0201140 <default_check+0x302>
ffffffffc0200eb4:	28a98663          	beq	s3,a0,ffffffffc0201140 <default_check+0x302>
    assert(page_ref(p0) == 0 && page_ref(p1) == 0 && page_ref(p2) == 0);
ffffffffc0200eb8:	000aa783          	lw	a5,0(s5)
ffffffffc0200ebc:	2a079263          	bnez	a5,ffffffffc0201160 <default_check+0x322>
ffffffffc0200ec0:	0009a783          	lw	a5,0(s3)
ffffffffc0200ec4:	28079e63          	bnez	a5,ffffffffc0201160 <default_check+0x322>
ffffffffc0200ec8:	411c                	lw	a5,0(a0)
ffffffffc0200eca:	28079b63          	bnez	a5,ffffffffc0201160 <default_check+0x322>
extern size_t npage;
extern uint_t va_pa_offset;

static inline ppn_t
page2ppn(struct Page *page) {
    return page - pages + nbase;
ffffffffc0200ece:	000b2797          	auipc	a5,0xb2
ffffffffc0200ed2:	9e27b783          	ld	a5,-1566(a5) # ffffffffc02b28b0 <pages>
ffffffffc0200ed6:	40fa8733          	sub	a4,s5,a5
ffffffffc0200eda:	00008617          	auipc	a2,0x8
ffffffffc0200ede:	f6663603          	ld	a2,-154(a2) # ffffffffc0208e40 <nbase>
ffffffffc0200ee2:	8719                	srai	a4,a4,0x6
ffffffffc0200ee4:	9732                	add	a4,a4,a2
    assert(page2pa(p0) < npage * PGSIZE);
ffffffffc0200ee6:	000b2697          	auipc	a3,0xb2
ffffffffc0200eea:	9c26b683          	ld	a3,-1598(a3) # ffffffffc02b28a8 <npage>
ffffffffc0200eee:	06b2                	slli	a3,a3,0xc
}

static inline uintptr_t
page2pa(struct Page *page) {
    return page2ppn(page) << PGSHIFT;
ffffffffc0200ef0:	0732                	slli	a4,a4,0xc
ffffffffc0200ef2:	28d77763          	bgeu	a4,a3,ffffffffc0201180 <default_check+0x342>
    return page - pages + nbase;
ffffffffc0200ef6:	40f98733          	sub	a4,s3,a5
ffffffffc0200efa:	8719                	srai	a4,a4,0x6
ffffffffc0200efc:	9732                	add	a4,a4,a2
    return page2ppn(page) << PGSHIFT;
ffffffffc0200efe:	0732                	slli	a4,a4,0xc
    assert(page2pa(p1) < npage * PGSIZE);
ffffffffc0200f00:	4cd77063          	bgeu	a4,a3,ffffffffc02013c0 <default_check+0x582>
    return page - pages + nbase;
ffffffffc0200f04:	40f507b3          	sub	a5,a0,a5
ffffffffc0200f08:	8799                	srai	a5,a5,0x6
ffffffffc0200f0a:	97b2                	add	a5,a5,a2
    return page2ppn(page) << PGSHIFT;
ffffffffc0200f0c:	07b2                	slli	a5,a5,0xc
    assert(page2pa(p2) < npage * PGSIZE);
ffffffffc0200f0e:	30d7f963          	bgeu	a5,a3,ffffffffc0201220 <default_check+0x3e2>
    assert(alloc_page() == NULL);
ffffffffc0200f12:	4505                	li	a0,1
    list_entry_t free_list_store = free_list;
ffffffffc0200f14:	00043c03          	ld	s8,0(s0)
ffffffffc0200f18:	00843b83          	ld	s7,8(s0)
    unsigned int nr_free_store = nr_free;
ffffffffc0200f1c:	01042b03          	lw	s6,16(s0)
    elm->prev = elm->next = elm;
ffffffffc0200f20:	e400                	sd	s0,8(s0)
ffffffffc0200f22:	e000                	sd	s0,0(s0)
    nr_free = 0;
ffffffffc0200f24:	000ae797          	auipc	a5,0xae
ffffffffc0200f28:	8807ae23          	sw	zero,-1892(a5) # ffffffffc02ae7c0 <free_area+0x10>
    assert(alloc_page() == NULL);
ffffffffc0200f2c:	5b5000ef          	jal	ra,ffffffffc0201ce0 <alloc_pages>
ffffffffc0200f30:	2c051863          	bnez	a0,ffffffffc0201200 <default_check+0x3c2>
    free_page(p0);
ffffffffc0200f34:	4585                	li	a1,1
ffffffffc0200f36:	8556                	mv	a0,s5
ffffffffc0200f38:	63b000ef          	jal	ra,ffffffffc0201d72 <free_pages>
    free_page(p1);
ffffffffc0200f3c:	4585                	li	a1,1
ffffffffc0200f3e:	854e                	mv	a0,s3
ffffffffc0200f40:	633000ef          	jal	ra,ffffffffc0201d72 <free_pages>
    free_page(p2);
ffffffffc0200f44:	4585                	li	a1,1
ffffffffc0200f46:	8552                	mv	a0,s4
ffffffffc0200f48:	62b000ef          	jal	ra,ffffffffc0201d72 <free_pages>
    assert(nr_free == 3);
ffffffffc0200f4c:	4818                	lw	a4,16(s0)
ffffffffc0200f4e:	478d                	li	a5,3
ffffffffc0200f50:	28f71863          	bne	a4,a5,ffffffffc02011e0 <default_check+0x3a2>
    assert((p0 = alloc_page()) != NULL);
ffffffffc0200f54:	4505                	li	a0,1
ffffffffc0200f56:	58b000ef          	jal	ra,ffffffffc0201ce0 <alloc_pages>
ffffffffc0200f5a:	89aa                	mv	s3,a0
ffffffffc0200f5c:	26050263          	beqz	a0,ffffffffc02011c0 <default_check+0x382>
    assert((p1 = alloc_page()) != NULL);
ffffffffc0200f60:	4505                	li	a0,1
ffffffffc0200f62:	57f000ef          	jal	ra,ffffffffc0201ce0 <alloc_pages>
ffffffffc0200f66:	8aaa                	mv	s5,a0
ffffffffc0200f68:	3a050c63          	beqz	a0,ffffffffc0201320 <default_check+0x4e2>
    assert((p2 = alloc_page()) != NULL);
ffffffffc0200f6c:	4505                	li	a0,1
ffffffffc0200f6e:	573000ef          	jal	ra,ffffffffc0201ce0 <alloc_pages>
ffffffffc0200f72:	8a2a                	mv	s4,a0
ffffffffc0200f74:	38050663          	beqz	a0,ffffffffc0201300 <default_check+0x4c2>
    assert(alloc_page() == NULL);
ffffffffc0200f78:	4505                	li	a0,1
ffffffffc0200f7a:	567000ef          	jal	ra,ffffffffc0201ce0 <alloc_pages>
ffffffffc0200f7e:	36051163          	bnez	a0,ffffffffc02012e0 <default_check+0x4a2>
    free_page(p0);
ffffffffc0200f82:	4585                	li	a1,1
ffffffffc0200f84:	854e                	mv	a0,s3
ffffffffc0200f86:	5ed000ef          	jal	ra,ffffffffc0201d72 <free_pages>
    assert(!list_empty(&free_list));
ffffffffc0200f8a:	641c                	ld	a5,8(s0)
ffffffffc0200f8c:	20878a63          	beq	a5,s0,ffffffffc02011a0 <default_check+0x362>
    assert((p = alloc_page()) == p0);
ffffffffc0200f90:	4505                	li	a0,1
ffffffffc0200f92:	54f000ef          	jal	ra,ffffffffc0201ce0 <alloc_pages>
ffffffffc0200f96:	30a99563          	bne	s3,a0,ffffffffc02012a0 <default_check+0x462>
    assert(alloc_page() == NULL);
ffffffffc0200f9a:	4505                	li	a0,1
ffffffffc0200f9c:	545000ef          	jal	ra,ffffffffc0201ce0 <alloc_pages>
ffffffffc0200fa0:	2e051063          	bnez	a0,ffffffffc0201280 <default_check+0x442>
    assert(nr_free == 0);
ffffffffc0200fa4:	481c                	lw	a5,16(s0)
ffffffffc0200fa6:	2a079d63          	bnez	a5,ffffffffc0201260 <default_check+0x422>
    free_page(p);
ffffffffc0200faa:	854e                	mv	a0,s3
ffffffffc0200fac:	4585                	li	a1,1
    free_list = free_list_store;
ffffffffc0200fae:	01843023          	sd	s8,0(s0)
ffffffffc0200fb2:	01743423          	sd	s7,8(s0)
    nr_free = nr_free_store;
ffffffffc0200fb6:	01642823          	sw	s6,16(s0)
    free_page(p);
ffffffffc0200fba:	5b9000ef          	jal	ra,ffffffffc0201d72 <free_pages>
    free_page(p1);
ffffffffc0200fbe:	4585                	li	a1,1
ffffffffc0200fc0:	8556                	mv	a0,s5
ffffffffc0200fc2:	5b1000ef          	jal	ra,ffffffffc0201d72 <free_pages>
    free_page(p2);
ffffffffc0200fc6:	4585                	li	a1,1
ffffffffc0200fc8:	8552                	mv	a0,s4
ffffffffc0200fca:	5a9000ef          	jal	ra,ffffffffc0201d72 <free_pages>

    basic_check();

    struct Page *p0 = alloc_pages(5), *p1, *p2;
ffffffffc0200fce:	4515                	li	a0,5
ffffffffc0200fd0:	511000ef          	jal	ra,ffffffffc0201ce0 <alloc_pages>
ffffffffc0200fd4:	89aa                	mv	s3,a0
    assert(p0 != NULL);
ffffffffc0200fd6:	26050563          	beqz	a0,ffffffffc0201240 <default_check+0x402>
ffffffffc0200fda:	651c                	ld	a5,8(a0)
ffffffffc0200fdc:	8385                	srli	a5,a5,0x1
ffffffffc0200fde:	8b85                	andi	a5,a5,1
    assert(!PageProperty(p0));
ffffffffc0200fe0:	54079063          	bnez	a5,ffffffffc0201520 <default_check+0x6e2>

    list_entry_t free_list_store = free_list;
    list_init(&free_list);
    assert(list_empty(&free_list));
    assert(alloc_page() == NULL);
ffffffffc0200fe4:	4505                	li	a0,1
    list_entry_t free_list_store = free_list;
ffffffffc0200fe6:	00043b03          	ld	s6,0(s0)
ffffffffc0200fea:	00843a83          	ld	s5,8(s0)
ffffffffc0200fee:	e000                	sd	s0,0(s0)
ffffffffc0200ff0:	e400                	sd	s0,8(s0)
    assert(alloc_page() == NULL);
ffffffffc0200ff2:	4ef000ef          	jal	ra,ffffffffc0201ce0 <alloc_pages>
ffffffffc0200ff6:	50051563          	bnez	a0,ffffffffc0201500 <default_check+0x6c2>

    unsigned int nr_free_store = nr_free;
    nr_free = 0;

    free_pages(p0 + 2, 3);
ffffffffc0200ffa:	08098a13          	addi	s4,s3,128
ffffffffc0200ffe:	8552                	mv	a0,s4
ffffffffc0201000:	458d                	li	a1,3
    unsigned int nr_free_store = nr_free;
ffffffffc0201002:	01042b83          	lw	s7,16(s0)
    nr_free = 0;
ffffffffc0201006:	000ad797          	auipc	a5,0xad
ffffffffc020100a:	7a07ad23          	sw	zero,1978(a5) # ffffffffc02ae7c0 <free_area+0x10>
    free_pages(p0 + 2, 3);
ffffffffc020100e:	565000ef          	jal	ra,ffffffffc0201d72 <free_pages>
    assert(alloc_pages(4) == NULL);
ffffffffc0201012:	4511                	li	a0,4
ffffffffc0201014:	4cd000ef          	jal	ra,ffffffffc0201ce0 <alloc_pages>
ffffffffc0201018:	4c051463          	bnez	a0,ffffffffc02014e0 <default_check+0x6a2>
ffffffffc020101c:	0889b783          	ld	a5,136(s3)
ffffffffc0201020:	8385                	srli	a5,a5,0x1
ffffffffc0201022:	8b85                	andi	a5,a5,1
    assert(PageProperty(p0 + 2) && p0[2].property == 3);
ffffffffc0201024:	48078e63          	beqz	a5,ffffffffc02014c0 <default_check+0x682>
ffffffffc0201028:	0909a703          	lw	a4,144(s3)
ffffffffc020102c:	478d                	li	a5,3
ffffffffc020102e:	48f71963          	bne	a4,a5,ffffffffc02014c0 <default_check+0x682>
    assert((p1 = alloc_pages(3)) != NULL);
ffffffffc0201032:	450d                	li	a0,3
ffffffffc0201034:	4ad000ef          	jal	ra,ffffffffc0201ce0 <alloc_pages>
ffffffffc0201038:	8c2a                	mv	s8,a0
ffffffffc020103a:	46050363          	beqz	a0,ffffffffc02014a0 <default_check+0x662>
    assert(alloc_page() == NULL);
ffffffffc020103e:	4505                	li	a0,1
ffffffffc0201040:	4a1000ef          	jal	ra,ffffffffc0201ce0 <alloc_pages>
ffffffffc0201044:	42051e63          	bnez	a0,ffffffffc0201480 <default_check+0x642>
    assert(p0 + 2 == p1);
ffffffffc0201048:	418a1c63          	bne	s4,s8,ffffffffc0201460 <default_check+0x622>

    p2 = p0 + 1;
    free_page(p0);
ffffffffc020104c:	4585                	li	a1,1
ffffffffc020104e:	854e                	mv	a0,s3
ffffffffc0201050:	523000ef          	jal	ra,ffffffffc0201d72 <free_pages>
    free_pages(p1, 3);
ffffffffc0201054:	458d                	li	a1,3
ffffffffc0201056:	8552                	mv	a0,s4
ffffffffc0201058:	51b000ef          	jal	ra,ffffffffc0201d72 <free_pages>
ffffffffc020105c:	0089b783          	ld	a5,8(s3)
    p2 = p0 + 1;
ffffffffc0201060:	04098c13          	addi	s8,s3,64
ffffffffc0201064:	8385                	srli	a5,a5,0x1
ffffffffc0201066:	8b85                	andi	a5,a5,1
    assert(PageProperty(p0) && p0->property == 1);
ffffffffc0201068:	3c078c63          	beqz	a5,ffffffffc0201440 <default_check+0x602>
ffffffffc020106c:	0109a703          	lw	a4,16(s3)
ffffffffc0201070:	4785                	li	a5,1
ffffffffc0201072:	3cf71763          	bne	a4,a5,ffffffffc0201440 <default_check+0x602>
ffffffffc0201076:	008a3783          	ld	a5,8(s4)
ffffffffc020107a:	8385                	srli	a5,a5,0x1
ffffffffc020107c:	8b85                	andi	a5,a5,1
    assert(PageProperty(p1) && p1->property == 3);
ffffffffc020107e:	3a078163          	beqz	a5,ffffffffc0201420 <default_check+0x5e2>
ffffffffc0201082:	010a2703          	lw	a4,16(s4)
ffffffffc0201086:	478d                	li	a5,3
ffffffffc0201088:	38f71c63          	bne	a4,a5,ffffffffc0201420 <default_check+0x5e2>

    assert((p0 = alloc_page()) == p2 - 1);
ffffffffc020108c:	4505                	li	a0,1
ffffffffc020108e:	453000ef          	jal	ra,ffffffffc0201ce0 <alloc_pages>
ffffffffc0201092:	36a99763          	bne	s3,a0,ffffffffc0201400 <default_check+0x5c2>
    free_page(p0);
ffffffffc0201096:	4585                	li	a1,1
ffffffffc0201098:	4db000ef          	jal	ra,ffffffffc0201d72 <free_pages>
    assert((p0 = alloc_pages(2)) == p2 + 1);
ffffffffc020109c:	4509                	li	a0,2
ffffffffc020109e:	443000ef          	jal	ra,ffffffffc0201ce0 <alloc_pages>
ffffffffc02010a2:	32aa1f63          	bne	s4,a0,ffffffffc02013e0 <default_check+0x5a2>

    free_pages(p0, 2);
ffffffffc02010a6:	4589                	li	a1,2
ffffffffc02010a8:	4cb000ef          	jal	ra,ffffffffc0201d72 <free_pages>
    free_page(p2);
ffffffffc02010ac:	4585                	li	a1,1
ffffffffc02010ae:	8562                	mv	a0,s8
ffffffffc02010b0:	4c3000ef          	jal	ra,ffffffffc0201d72 <free_pages>

    assert((p0 = alloc_pages(5)) != NULL);
ffffffffc02010b4:	4515                	li	a0,5
ffffffffc02010b6:	42b000ef          	jal	ra,ffffffffc0201ce0 <alloc_pages>
ffffffffc02010ba:	89aa                	mv	s3,a0
ffffffffc02010bc:	48050263          	beqz	a0,ffffffffc0201540 <default_check+0x702>
    assert(alloc_page() == NULL);
ffffffffc02010c0:	4505                	li	a0,1
ffffffffc02010c2:	41f000ef          	jal	ra,ffffffffc0201ce0 <alloc_pages>
ffffffffc02010c6:	2c051d63          	bnez	a0,ffffffffc02013a0 <default_check+0x562>

    assert(nr_free == 0);
ffffffffc02010ca:	481c                	lw	a5,16(s0)
ffffffffc02010cc:	2a079a63          	bnez	a5,ffffffffc0201380 <default_check+0x542>
    nr_free = nr_free_store;

    free_list = free_list_store;
    free_pages(p0, 5);
ffffffffc02010d0:	4595                	li	a1,5
ffffffffc02010d2:	854e                	mv	a0,s3
    nr_free = nr_free_store;
ffffffffc02010d4:	01742823          	sw	s7,16(s0)
    free_list = free_list_store;
ffffffffc02010d8:	01643023          	sd	s6,0(s0)
ffffffffc02010dc:	01543423          	sd	s5,8(s0)
    free_pages(p0, 5);
ffffffffc02010e0:	493000ef          	jal	ra,ffffffffc0201d72 <free_pages>
    return listelm->next;
ffffffffc02010e4:	641c                	ld	a5,8(s0)

    le = &free_list;
    while ((le = list_next(le)) != &free_list) {
ffffffffc02010e6:	00878963          	beq	a5,s0,ffffffffc02010f8 <default_check+0x2ba>
        struct Page *p = le2page(le, page_link);
        count --, total -= p->property;
ffffffffc02010ea:	ff87a703          	lw	a4,-8(a5)
ffffffffc02010ee:	679c                	ld	a5,8(a5)
ffffffffc02010f0:	397d                	addiw	s2,s2,-1
ffffffffc02010f2:	9c99                	subw	s1,s1,a4
    while ((le = list_next(le)) != &free_list) {
ffffffffc02010f4:	fe879be3          	bne	a5,s0,ffffffffc02010ea <default_check+0x2ac>
    }
    assert(count == 0);
ffffffffc02010f8:	26091463          	bnez	s2,ffffffffc0201360 <default_check+0x522>
    assert(total == 0);
ffffffffc02010fc:	46049263          	bnez	s1,ffffffffc0201560 <default_check+0x722>
}
ffffffffc0201100:	60a6                	ld	ra,72(sp)
ffffffffc0201102:	6406                	ld	s0,64(sp)
ffffffffc0201104:	74e2                	ld	s1,56(sp)
ffffffffc0201106:	7942                	ld	s2,48(sp)
ffffffffc0201108:	79a2                	ld	s3,40(sp)
ffffffffc020110a:	7a02                	ld	s4,32(sp)
ffffffffc020110c:	6ae2                	ld	s5,24(sp)
ffffffffc020110e:	6b42                	ld	s6,16(sp)
ffffffffc0201110:	6ba2                	ld	s7,8(sp)
ffffffffc0201112:	6c02                	ld	s8,0(sp)
ffffffffc0201114:	6161                	addi	sp,sp,80
ffffffffc0201116:	8082                	ret
    while ((le = list_next(le)) != &free_list) {
ffffffffc0201118:	4981                	li	s3,0
    int count = 0, total = 0;
ffffffffc020111a:	4481                	li	s1,0
ffffffffc020111c:	4901                	li	s2,0
ffffffffc020111e:	b38d                	j	ffffffffc0200e80 <default_check+0x42>
        assert(PageProperty(p));
ffffffffc0201120:	00006697          	auipc	a3,0x6
ffffffffc0201124:	fb868693          	addi	a3,a3,-72 # ffffffffc02070d8 <commands+0x740>
ffffffffc0201128:	00006617          	auipc	a2,0x6
ffffffffc020112c:	cc060613          	addi	a2,a2,-832 # ffffffffc0206de8 <commands+0x450>
ffffffffc0201130:	0f000593          	li	a1,240
ffffffffc0201134:	00006517          	auipc	a0,0x6
ffffffffc0201138:	fb450513          	addi	a0,a0,-76 # ffffffffc02070e8 <commands+0x750>
ffffffffc020113c:	b3eff0ef          	jal	ra,ffffffffc020047a <__panic>
    assert(p0 != p1 && p0 != p2 && p1 != p2);
ffffffffc0201140:	00006697          	auipc	a3,0x6
ffffffffc0201144:	04068693          	addi	a3,a3,64 # ffffffffc0207180 <commands+0x7e8>
ffffffffc0201148:	00006617          	auipc	a2,0x6
ffffffffc020114c:	ca060613          	addi	a2,a2,-864 # ffffffffc0206de8 <commands+0x450>
ffffffffc0201150:	0bd00593          	li	a1,189
ffffffffc0201154:	00006517          	auipc	a0,0x6
ffffffffc0201158:	f9450513          	addi	a0,a0,-108 # ffffffffc02070e8 <commands+0x750>
ffffffffc020115c:	b1eff0ef          	jal	ra,ffffffffc020047a <__panic>
    assert(page_ref(p0) == 0 && page_ref(p1) == 0 && page_ref(p2) == 0);
ffffffffc0201160:	00006697          	auipc	a3,0x6
ffffffffc0201164:	04868693          	addi	a3,a3,72 # ffffffffc02071a8 <commands+0x810>
ffffffffc0201168:	00006617          	auipc	a2,0x6
ffffffffc020116c:	c8060613          	addi	a2,a2,-896 # ffffffffc0206de8 <commands+0x450>
ffffffffc0201170:	0be00593          	li	a1,190
ffffffffc0201174:	00006517          	auipc	a0,0x6
ffffffffc0201178:	f7450513          	addi	a0,a0,-140 # ffffffffc02070e8 <commands+0x750>
ffffffffc020117c:	afeff0ef          	jal	ra,ffffffffc020047a <__panic>
    assert(page2pa(p0) < npage * PGSIZE);
ffffffffc0201180:	00006697          	auipc	a3,0x6
ffffffffc0201184:	06868693          	addi	a3,a3,104 # ffffffffc02071e8 <commands+0x850>
ffffffffc0201188:	00006617          	auipc	a2,0x6
ffffffffc020118c:	c6060613          	addi	a2,a2,-928 # ffffffffc0206de8 <commands+0x450>
ffffffffc0201190:	0c000593          	li	a1,192
ffffffffc0201194:	00006517          	auipc	a0,0x6
ffffffffc0201198:	f5450513          	addi	a0,a0,-172 # ffffffffc02070e8 <commands+0x750>
ffffffffc020119c:	adeff0ef          	jal	ra,ffffffffc020047a <__panic>
    assert(!list_empty(&free_list));
ffffffffc02011a0:	00006697          	auipc	a3,0x6
ffffffffc02011a4:	0d068693          	addi	a3,a3,208 # ffffffffc0207270 <commands+0x8d8>
ffffffffc02011a8:	00006617          	auipc	a2,0x6
ffffffffc02011ac:	c4060613          	addi	a2,a2,-960 # ffffffffc0206de8 <commands+0x450>
ffffffffc02011b0:	0d900593          	li	a1,217
ffffffffc02011b4:	00006517          	auipc	a0,0x6
ffffffffc02011b8:	f3450513          	addi	a0,a0,-204 # ffffffffc02070e8 <commands+0x750>
ffffffffc02011bc:	abeff0ef          	jal	ra,ffffffffc020047a <__panic>
    assert((p0 = alloc_page()) != NULL);
ffffffffc02011c0:	00006697          	auipc	a3,0x6
ffffffffc02011c4:	f6068693          	addi	a3,a3,-160 # ffffffffc0207120 <commands+0x788>
ffffffffc02011c8:	00006617          	auipc	a2,0x6
ffffffffc02011cc:	c2060613          	addi	a2,a2,-992 # ffffffffc0206de8 <commands+0x450>
ffffffffc02011d0:	0d200593          	li	a1,210
ffffffffc02011d4:	00006517          	auipc	a0,0x6
ffffffffc02011d8:	f1450513          	addi	a0,a0,-236 # ffffffffc02070e8 <commands+0x750>
ffffffffc02011dc:	a9eff0ef          	jal	ra,ffffffffc020047a <__panic>
    assert(nr_free == 3);
ffffffffc02011e0:	00006697          	auipc	a3,0x6
ffffffffc02011e4:	08068693          	addi	a3,a3,128 # ffffffffc0207260 <commands+0x8c8>
ffffffffc02011e8:	00006617          	auipc	a2,0x6
ffffffffc02011ec:	c0060613          	addi	a2,a2,-1024 # ffffffffc0206de8 <commands+0x450>
ffffffffc02011f0:	0d000593          	li	a1,208
ffffffffc02011f4:	00006517          	auipc	a0,0x6
ffffffffc02011f8:	ef450513          	addi	a0,a0,-268 # ffffffffc02070e8 <commands+0x750>
ffffffffc02011fc:	a7eff0ef          	jal	ra,ffffffffc020047a <__panic>
    assert(alloc_page() == NULL);
ffffffffc0201200:	00006697          	auipc	a3,0x6
ffffffffc0201204:	04868693          	addi	a3,a3,72 # ffffffffc0207248 <commands+0x8b0>
ffffffffc0201208:	00006617          	auipc	a2,0x6
ffffffffc020120c:	be060613          	addi	a2,a2,-1056 # ffffffffc0206de8 <commands+0x450>
ffffffffc0201210:	0cb00593          	li	a1,203
ffffffffc0201214:	00006517          	auipc	a0,0x6
ffffffffc0201218:	ed450513          	addi	a0,a0,-300 # ffffffffc02070e8 <commands+0x750>
ffffffffc020121c:	a5eff0ef          	jal	ra,ffffffffc020047a <__panic>
    assert(page2pa(p2) < npage * PGSIZE);
ffffffffc0201220:	00006697          	auipc	a3,0x6
ffffffffc0201224:	00868693          	addi	a3,a3,8 # ffffffffc0207228 <commands+0x890>
ffffffffc0201228:	00006617          	auipc	a2,0x6
ffffffffc020122c:	bc060613          	addi	a2,a2,-1088 # ffffffffc0206de8 <commands+0x450>
ffffffffc0201230:	0c200593          	li	a1,194
ffffffffc0201234:	00006517          	auipc	a0,0x6
ffffffffc0201238:	eb450513          	addi	a0,a0,-332 # ffffffffc02070e8 <commands+0x750>
ffffffffc020123c:	a3eff0ef          	jal	ra,ffffffffc020047a <__panic>
    assert(p0 != NULL);
ffffffffc0201240:	00006697          	auipc	a3,0x6
ffffffffc0201244:	07868693          	addi	a3,a3,120 # ffffffffc02072b8 <commands+0x920>
ffffffffc0201248:	00006617          	auipc	a2,0x6
ffffffffc020124c:	ba060613          	addi	a2,a2,-1120 # ffffffffc0206de8 <commands+0x450>
ffffffffc0201250:	0f800593          	li	a1,248
ffffffffc0201254:	00006517          	auipc	a0,0x6
ffffffffc0201258:	e9450513          	addi	a0,a0,-364 # ffffffffc02070e8 <commands+0x750>
ffffffffc020125c:	a1eff0ef          	jal	ra,ffffffffc020047a <__panic>
    assert(nr_free == 0);
ffffffffc0201260:	00006697          	auipc	a3,0x6
ffffffffc0201264:	04868693          	addi	a3,a3,72 # ffffffffc02072a8 <commands+0x910>
ffffffffc0201268:	00006617          	auipc	a2,0x6
ffffffffc020126c:	b8060613          	addi	a2,a2,-1152 # ffffffffc0206de8 <commands+0x450>
ffffffffc0201270:	0df00593          	li	a1,223
ffffffffc0201274:	00006517          	auipc	a0,0x6
ffffffffc0201278:	e7450513          	addi	a0,a0,-396 # ffffffffc02070e8 <commands+0x750>
ffffffffc020127c:	9feff0ef          	jal	ra,ffffffffc020047a <__panic>
    assert(alloc_page() == NULL);
ffffffffc0201280:	00006697          	auipc	a3,0x6
ffffffffc0201284:	fc868693          	addi	a3,a3,-56 # ffffffffc0207248 <commands+0x8b0>
ffffffffc0201288:	00006617          	auipc	a2,0x6
ffffffffc020128c:	b6060613          	addi	a2,a2,-1184 # ffffffffc0206de8 <commands+0x450>
ffffffffc0201290:	0dd00593          	li	a1,221
ffffffffc0201294:	00006517          	auipc	a0,0x6
ffffffffc0201298:	e5450513          	addi	a0,a0,-428 # ffffffffc02070e8 <commands+0x750>
ffffffffc020129c:	9deff0ef          	jal	ra,ffffffffc020047a <__panic>
    assert((p = alloc_page()) == p0);
ffffffffc02012a0:	00006697          	auipc	a3,0x6
ffffffffc02012a4:	fe868693          	addi	a3,a3,-24 # ffffffffc0207288 <commands+0x8f0>
ffffffffc02012a8:	00006617          	auipc	a2,0x6
ffffffffc02012ac:	b4060613          	addi	a2,a2,-1216 # ffffffffc0206de8 <commands+0x450>
ffffffffc02012b0:	0dc00593          	li	a1,220
ffffffffc02012b4:	00006517          	auipc	a0,0x6
ffffffffc02012b8:	e3450513          	addi	a0,a0,-460 # ffffffffc02070e8 <commands+0x750>
ffffffffc02012bc:	9beff0ef          	jal	ra,ffffffffc020047a <__panic>
    assert((p0 = alloc_page()) != NULL);
ffffffffc02012c0:	00006697          	auipc	a3,0x6
ffffffffc02012c4:	e6068693          	addi	a3,a3,-416 # ffffffffc0207120 <commands+0x788>
ffffffffc02012c8:	00006617          	auipc	a2,0x6
ffffffffc02012cc:	b2060613          	addi	a2,a2,-1248 # ffffffffc0206de8 <commands+0x450>
ffffffffc02012d0:	0b900593          	li	a1,185
ffffffffc02012d4:	00006517          	auipc	a0,0x6
ffffffffc02012d8:	e1450513          	addi	a0,a0,-492 # ffffffffc02070e8 <commands+0x750>
ffffffffc02012dc:	99eff0ef          	jal	ra,ffffffffc020047a <__panic>
    assert(alloc_page() == NULL);
ffffffffc02012e0:	00006697          	auipc	a3,0x6
ffffffffc02012e4:	f6868693          	addi	a3,a3,-152 # ffffffffc0207248 <commands+0x8b0>
ffffffffc02012e8:	00006617          	auipc	a2,0x6
ffffffffc02012ec:	b0060613          	addi	a2,a2,-1280 # ffffffffc0206de8 <commands+0x450>
ffffffffc02012f0:	0d600593          	li	a1,214
ffffffffc02012f4:	00006517          	auipc	a0,0x6
ffffffffc02012f8:	df450513          	addi	a0,a0,-524 # ffffffffc02070e8 <commands+0x750>
ffffffffc02012fc:	97eff0ef          	jal	ra,ffffffffc020047a <__panic>
    assert((p2 = alloc_page()) != NULL);
ffffffffc0201300:	00006697          	auipc	a3,0x6
ffffffffc0201304:	e6068693          	addi	a3,a3,-416 # ffffffffc0207160 <commands+0x7c8>
ffffffffc0201308:	00006617          	auipc	a2,0x6
ffffffffc020130c:	ae060613          	addi	a2,a2,-1312 # ffffffffc0206de8 <commands+0x450>
ffffffffc0201310:	0d400593          	li	a1,212
ffffffffc0201314:	00006517          	auipc	a0,0x6
ffffffffc0201318:	dd450513          	addi	a0,a0,-556 # ffffffffc02070e8 <commands+0x750>
ffffffffc020131c:	95eff0ef          	jal	ra,ffffffffc020047a <__panic>
    assert((p1 = alloc_page()) != NULL);
ffffffffc0201320:	00006697          	auipc	a3,0x6
ffffffffc0201324:	e2068693          	addi	a3,a3,-480 # ffffffffc0207140 <commands+0x7a8>
ffffffffc0201328:	00006617          	auipc	a2,0x6
ffffffffc020132c:	ac060613          	addi	a2,a2,-1344 # ffffffffc0206de8 <commands+0x450>
ffffffffc0201330:	0d300593          	li	a1,211
ffffffffc0201334:	00006517          	auipc	a0,0x6
ffffffffc0201338:	db450513          	addi	a0,a0,-588 # ffffffffc02070e8 <commands+0x750>
ffffffffc020133c:	93eff0ef          	jal	ra,ffffffffc020047a <__panic>
    assert((p2 = alloc_page()) != NULL);
ffffffffc0201340:	00006697          	auipc	a3,0x6
ffffffffc0201344:	e2068693          	addi	a3,a3,-480 # ffffffffc0207160 <commands+0x7c8>
ffffffffc0201348:	00006617          	auipc	a2,0x6
ffffffffc020134c:	aa060613          	addi	a2,a2,-1376 # ffffffffc0206de8 <commands+0x450>
ffffffffc0201350:	0bb00593          	li	a1,187
ffffffffc0201354:	00006517          	auipc	a0,0x6
ffffffffc0201358:	d9450513          	addi	a0,a0,-620 # ffffffffc02070e8 <commands+0x750>
ffffffffc020135c:	91eff0ef          	jal	ra,ffffffffc020047a <__panic>
    assert(count == 0);
ffffffffc0201360:	00006697          	auipc	a3,0x6
ffffffffc0201364:	0a868693          	addi	a3,a3,168 # ffffffffc0207408 <commands+0xa70>
ffffffffc0201368:	00006617          	auipc	a2,0x6
ffffffffc020136c:	a8060613          	addi	a2,a2,-1408 # ffffffffc0206de8 <commands+0x450>
ffffffffc0201370:	12500593          	li	a1,293
ffffffffc0201374:	00006517          	auipc	a0,0x6
ffffffffc0201378:	d7450513          	addi	a0,a0,-652 # ffffffffc02070e8 <commands+0x750>
ffffffffc020137c:	8feff0ef          	jal	ra,ffffffffc020047a <__panic>
    assert(nr_free == 0);
ffffffffc0201380:	00006697          	auipc	a3,0x6
ffffffffc0201384:	f2868693          	addi	a3,a3,-216 # ffffffffc02072a8 <commands+0x910>
ffffffffc0201388:	00006617          	auipc	a2,0x6
ffffffffc020138c:	a6060613          	addi	a2,a2,-1440 # ffffffffc0206de8 <commands+0x450>
ffffffffc0201390:	11a00593          	li	a1,282
ffffffffc0201394:	00006517          	auipc	a0,0x6
ffffffffc0201398:	d5450513          	addi	a0,a0,-684 # ffffffffc02070e8 <commands+0x750>
ffffffffc020139c:	8deff0ef          	jal	ra,ffffffffc020047a <__panic>
    assert(alloc_page() == NULL);
ffffffffc02013a0:	00006697          	auipc	a3,0x6
ffffffffc02013a4:	ea868693          	addi	a3,a3,-344 # ffffffffc0207248 <commands+0x8b0>
ffffffffc02013a8:	00006617          	auipc	a2,0x6
ffffffffc02013ac:	a4060613          	addi	a2,a2,-1472 # ffffffffc0206de8 <commands+0x450>
ffffffffc02013b0:	11800593          	li	a1,280
ffffffffc02013b4:	00006517          	auipc	a0,0x6
ffffffffc02013b8:	d3450513          	addi	a0,a0,-716 # ffffffffc02070e8 <commands+0x750>
ffffffffc02013bc:	8beff0ef          	jal	ra,ffffffffc020047a <__panic>
    assert(page2pa(p1) < npage * PGSIZE);
ffffffffc02013c0:	00006697          	auipc	a3,0x6
ffffffffc02013c4:	e4868693          	addi	a3,a3,-440 # ffffffffc0207208 <commands+0x870>
ffffffffc02013c8:	00006617          	auipc	a2,0x6
ffffffffc02013cc:	a2060613          	addi	a2,a2,-1504 # ffffffffc0206de8 <commands+0x450>
ffffffffc02013d0:	0c100593          	li	a1,193
ffffffffc02013d4:	00006517          	auipc	a0,0x6
ffffffffc02013d8:	d1450513          	addi	a0,a0,-748 # ffffffffc02070e8 <commands+0x750>
ffffffffc02013dc:	89eff0ef          	jal	ra,ffffffffc020047a <__panic>
    assert((p0 = alloc_pages(2)) == p2 + 1);
ffffffffc02013e0:	00006697          	auipc	a3,0x6
ffffffffc02013e4:	fe868693          	addi	a3,a3,-24 # ffffffffc02073c8 <commands+0xa30>
ffffffffc02013e8:	00006617          	auipc	a2,0x6
ffffffffc02013ec:	a0060613          	addi	a2,a2,-1536 # ffffffffc0206de8 <commands+0x450>
ffffffffc02013f0:	11200593          	li	a1,274
ffffffffc02013f4:	00006517          	auipc	a0,0x6
ffffffffc02013f8:	cf450513          	addi	a0,a0,-780 # ffffffffc02070e8 <commands+0x750>
ffffffffc02013fc:	87eff0ef          	jal	ra,ffffffffc020047a <__panic>
    assert((p0 = alloc_page()) == p2 - 1);
ffffffffc0201400:	00006697          	auipc	a3,0x6
ffffffffc0201404:	fa868693          	addi	a3,a3,-88 # ffffffffc02073a8 <commands+0xa10>
ffffffffc0201408:	00006617          	auipc	a2,0x6
ffffffffc020140c:	9e060613          	addi	a2,a2,-1568 # ffffffffc0206de8 <commands+0x450>
ffffffffc0201410:	11000593          	li	a1,272
ffffffffc0201414:	00006517          	auipc	a0,0x6
ffffffffc0201418:	cd450513          	addi	a0,a0,-812 # ffffffffc02070e8 <commands+0x750>
ffffffffc020141c:	85eff0ef          	jal	ra,ffffffffc020047a <__panic>
    assert(PageProperty(p1) && p1->property == 3);
ffffffffc0201420:	00006697          	auipc	a3,0x6
ffffffffc0201424:	f6068693          	addi	a3,a3,-160 # ffffffffc0207380 <commands+0x9e8>
ffffffffc0201428:	00006617          	auipc	a2,0x6
ffffffffc020142c:	9c060613          	addi	a2,a2,-1600 # ffffffffc0206de8 <commands+0x450>
ffffffffc0201430:	10e00593          	li	a1,270
ffffffffc0201434:	00006517          	auipc	a0,0x6
ffffffffc0201438:	cb450513          	addi	a0,a0,-844 # ffffffffc02070e8 <commands+0x750>
ffffffffc020143c:	83eff0ef          	jal	ra,ffffffffc020047a <__panic>
    assert(PageProperty(p0) && p0->property == 1);
ffffffffc0201440:	00006697          	auipc	a3,0x6
ffffffffc0201444:	f1868693          	addi	a3,a3,-232 # ffffffffc0207358 <commands+0x9c0>
ffffffffc0201448:	00006617          	auipc	a2,0x6
ffffffffc020144c:	9a060613          	addi	a2,a2,-1632 # ffffffffc0206de8 <commands+0x450>
ffffffffc0201450:	10d00593          	li	a1,269
ffffffffc0201454:	00006517          	auipc	a0,0x6
ffffffffc0201458:	c9450513          	addi	a0,a0,-876 # ffffffffc02070e8 <commands+0x750>
ffffffffc020145c:	81eff0ef          	jal	ra,ffffffffc020047a <__panic>
    assert(p0 + 2 == p1);
ffffffffc0201460:	00006697          	auipc	a3,0x6
ffffffffc0201464:	ee868693          	addi	a3,a3,-280 # ffffffffc0207348 <commands+0x9b0>
ffffffffc0201468:	00006617          	auipc	a2,0x6
ffffffffc020146c:	98060613          	addi	a2,a2,-1664 # ffffffffc0206de8 <commands+0x450>
ffffffffc0201470:	10800593          	li	a1,264
ffffffffc0201474:	00006517          	auipc	a0,0x6
ffffffffc0201478:	c7450513          	addi	a0,a0,-908 # ffffffffc02070e8 <commands+0x750>
ffffffffc020147c:	ffffe0ef          	jal	ra,ffffffffc020047a <__panic>
    assert(alloc_page() == NULL);
ffffffffc0201480:	00006697          	auipc	a3,0x6
ffffffffc0201484:	dc868693          	addi	a3,a3,-568 # ffffffffc0207248 <commands+0x8b0>
ffffffffc0201488:	00006617          	auipc	a2,0x6
ffffffffc020148c:	96060613          	addi	a2,a2,-1696 # ffffffffc0206de8 <commands+0x450>
ffffffffc0201490:	10700593          	li	a1,263
ffffffffc0201494:	00006517          	auipc	a0,0x6
ffffffffc0201498:	c5450513          	addi	a0,a0,-940 # ffffffffc02070e8 <commands+0x750>
ffffffffc020149c:	fdffe0ef          	jal	ra,ffffffffc020047a <__panic>
    assert((p1 = alloc_pages(3)) != NULL);
ffffffffc02014a0:	00006697          	auipc	a3,0x6
ffffffffc02014a4:	e8868693          	addi	a3,a3,-376 # ffffffffc0207328 <commands+0x990>
ffffffffc02014a8:	00006617          	auipc	a2,0x6
ffffffffc02014ac:	94060613          	addi	a2,a2,-1728 # ffffffffc0206de8 <commands+0x450>
ffffffffc02014b0:	10600593          	li	a1,262
ffffffffc02014b4:	00006517          	auipc	a0,0x6
ffffffffc02014b8:	c3450513          	addi	a0,a0,-972 # ffffffffc02070e8 <commands+0x750>
ffffffffc02014bc:	fbffe0ef          	jal	ra,ffffffffc020047a <__panic>
    assert(PageProperty(p0 + 2) && p0[2].property == 3);
ffffffffc02014c0:	00006697          	auipc	a3,0x6
ffffffffc02014c4:	e3868693          	addi	a3,a3,-456 # ffffffffc02072f8 <commands+0x960>
ffffffffc02014c8:	00006617          	auipc	a2,0x6
ffffffffc02014cc:	92060613          	addi	a2,a2,-1760 # ffffffffc0206de8 <commands+0x450>
ffffffffc02014d0:	10500593          	li	a1,261
ffffffffc02014d4:	00006517          	auipc	a0,0x6
ffffffffc02014d8:	c1450513          	addi	a0,a0,-1004 # ffffffffc02070e8 <commands+0x750>
ffffffffc02014dc:	f9ffe0ef          	jal	ra,ffffffffc020047a <__panic>
    assert(alloc_pages(4) == NULL);
ffffffffc02014e0:	00006697          	auipc	a3,0x6
ffffffffc02014e4:	e0068693          	addi	a3,a3,-512 # ffffffffc02072e0 <commands+0x948>
ffffffffc02014e8:	00006617          	auipc	a2,0x6
ffffffffc02014ec:	90060613          	addi	a2,a2,-1792 # ffffffffc0206de8 <commands+0x450>
ffffffffc02014f0:	10400593          	li	a1,260
ffffffffc02014f4:	00006517          	auipc	a0,0x6
ffffffffc02014f8:	bf450513          	addi	a0,a0,-1036 # ffffffffc02070e8 <commands+0x750>
ffffffffc02014fc:	f7ffe0ef          	jal	ra,ffffffffc020047a <__panic>
    assert(alloc_page() == NULL);
ffffffffc0201500:	00006697          	auipc	a3,0x6
ffffffffc0201504:	d4868693          	addi	a3,a3,-696 # ffffffffc0207248 <commands+0x8b0>
ffffffffc0201508:	00006617          	auipc	a2,0x6
ffffffffc020150c:	8e060613          	addi	a2,a2,-1824 # ffffffffc0206de8 <commands+0x450>
ffffffffc0201510:	0fe00593          	li	a1,254
ffffffffc0201514:	00006517          	auipc	a0,0x6
ffffffffc0201518:	bd450513          	addi	a0,a0,-1068 # ffffffffc02070e8 <commands+0x750>
ffffffffc020151c:	f5ffe0ef          	jal	ra,ffffffffc020047a <__panic>
    assert(!PageProperty(p0));
ffffffffc0201520:	00006697          	auipc	a3,0x6
ffffffffc0201524:	da868693          	addi	a3,a3,-600 # ffffffffc02072c8 <commands+0x930>
ffffffffc0201528:	00006617          	auipc	a2,0x6
ffffffffc020152c:	8c060613          	addi	a2,a2,-1856 # ffffffffc0206de8 <commands+0x450>
ffffffffc0201530:	0f900593          	li	a1,249
ffffffffc0201534:	00006517          	auipc	a0,0x6
ffffffffc0201538:	bb450513          	addi	a0,a0,-1100 # ffffffffc02070e8 <commands+0x750>
ffffffffc020153c:	f3ffe0ef          	jal	ra,ffffffffc020047a <__panic>
    assert((p0 = alloc_pages(5)) != NULL);
ffffffffc0201540:	00006697          	auipc	a3,0x6
ffffffffc0201544:	ea868693          	addi	a3,a3,-344 # ffffffffc02073e8 <commands+0xa50>
ffffffffc0201548:	00006617          	auipc	a2,0x6
ffffffffc020154c:	8a060613          	addi	a2,a2,-1888 # ffffffffc0206de8 <commands+0x450>
ffffffffc0201550:	11700593          	li	a1,279
ffffffffc0201554:	00006517          	auipc	a0,0x6
ffffffffc0201558:	b9450513          	addi	a0,a0,-1132 # ffffffffc02070e8 <commands+0x750>
ffffffffc020155c:	f1ffe0ef          	jal	ra,ffffffffc020047a <__panic>
    assert(total == 0);
ffffffffc0201560:	00006697          	auipc	a3,0x6
ffffffffc0201564:	eb868693          	addi	a3,a3,-328 # ffffffffc0207418 <commands+0xa80>
ffffffffc0201568:	00006617          	auipc	a2,0x6
ffffffffc020156c:	88060613          	addi	a2,a2,-1920 # ffffffffc0206de8 <commands+0x450>
ffffffffc0201570:	12600593          	li	a1,294
ffffffffc0201574:	00006517          	auipc	a0,0x6
ffffffffc0201578:	b7450513          	addi	a0,a0,-1164 # ffffffffc02070e8 <commands+0x750>
ffffffffc020157c:	efffe0ef          	jal	ra,ffffffffc020047a <__panic>
    assert(total == nr_free_pages());
ffffffffc0201580:	00006697          	auipc	a3,0x6
ffffffffc0201584:	b8068693          	addi	a3,a3,-1152 # ffffffffc0207100 <commands+0x768>
ffffffffc0201588:	00006617          	auipc	a2,0x6
ffffffffc020158c:	86060613          	addi	a2,a2,-1952 # ffffffffc0206de8 <commands+0x450>
ffffffffc0201590:	0f300593          	li	a1,243
ffffffffc0201594:	00006517          	auipc	a0,0x6
ffffffffc0201598:	b5450513          	addi	a0,a0,-1196 # ffffffffc02070e8 <commands+0x750>
ffffffffc020159c:	edffe0ef          	jal	ra,ffffffffc020047a <__panic>
    assert((p1 = alloc_page()) != NULL);
ffffffffc02015a0:	00006697          	auipc	a3,0x6
ffffffffc02015a4:	ba068693          	addi	a3,a3,-1120 # ffffffffc0207140 <commands+0x7a8>
ffffffffc02015a8:	00006617          	auipc	a2,0x6
ffffffffc02015ac:	84060613          	addi	a2,a2,-1984 # ffffffffc0206de8 <commands+0x450>
ffffffffc02015b0:	0ba00593          	li	a1,186
ffffffffc02015b4:	00006517          	auipc	a0,0x6
ffffffffc02015b8:	b3450513          	addi	a0,a0,-1228 # ffffffffc02070e8 <commands+0x750>
ffffffffc02015bc:	ebffe0ef          	jal	ra,ffffffffc020047a <__panic>

ffffffffc02015c0 <default_free_pages>:
default_free_pages(struct Page *base, size_t n) {
ffffffffc02015c0:	1141                	addi	sp,sp,-16
ffffffffc02015c2:	e406                	sd	ra,8(sp)
    assert(n > 0);
ffffffffc02015c4:	14058463          	beqz	a1,ffffffffc020170c <default_free_pages+0x14c>
    for (; p != base + n; p ++) {
ffffffffc02015c8:	00659693          	slli	a3,a1,0x6
ffffffffc02015cc:	96aa                	add	a3,a3,a0
ffffffffc02015ce:	87aa                	mv	a5,a0
ffffffffc02015d0:	02d50263          	beq	a0,a3,ffffffffc02015f4 <default_free_pages+0x34>
ffffffffc02015d4:	6798                	ld	a4,8(a5)
ffffffffc02015d6:	8b05                	andi	a4,a4,1
        assert(!PageReserved(p) && !PageProperty(p));
ffffffffc02015d8:	10071a63          	bnez	a4,ffffffffc02016ec <default_free_pages+0x12c>
ffffffffc02015dc:	6798                	ld	a4,8(a5)
ffffffffc02015de:	8b09                	andi	a4,a4,2
ffffffffc02015e0:	10071663          	bnez	a4,ffffffffc02016ec <default_free_pages+0x12c>
        p->flags = 0;
ffffffffc02015e4:	0007b423          	sd	zero,8(a5)
    return page->ref;
}

static inline void
set_page_ref(struct Page *page, int val) {
    page->ref = val;
ffffffffc02015e8:	0007a023          	sw	zero,0(a5)
    for (; p != base + n; p ++) {
ffffffffc02015ec:	04078793          	addi	a5,a5,64
ffffffffc02015f0:	fed792e3          	bne	a5,a3,ffffffffc02015d4 <default_free_pages+0x14>
    base->property = n;
ffffffffc02015f4:	2581                	sext.w	a1,a1
ffffffffc02015f6:	c90c                	sw	a1,16(a0)
    SetPageProperty(base);
ffffffffc02015f8:	00850893          	addi	a7,a0,8
    __op_bit(or, __NOP, nr, ((volatile unsigned long *)addr));
ffffffffc02015fc:	4789                	li	a5,2
ffffffffc02015fe:	40f8b02f          	amoor.d	zero,a5,(a7)
    nr_free += n;
ffffffffc0201602:	000ad697          	auipc	a3,0xad
ffffffffc0201606:	1ae68693          	addi	a3,a3,430 # ffffffffc02ae7b0 <free_area>
ffffffffc020160a:	4a98                	lw	a4,16(a3)
    return list->next == list;
ffffffffc020160c:	669c                	ld	a5,8(a3)
        list_add(&free_list, &(base->page_link));
ffffffffc020160e:	01850613          	addi	a2,a0,24
    nr_free += n;
ffffffffc0201612:	9db9                	addw	a1,a1,a4
ffffffffc0201614:	ca8c                	sw	a1,16(a3)
    if (list_empty(&free_list)) {
ffffffffc0201616:	0ad78463          	beq	a5,a3,ffffffffc02016be <default_free_pages+0xfe>
            struct Page* page = le2page(le, page_link);
ffffffffc020161a:	fe878713          	addi	a4,a5,-24
ffffffffc020161e:	0006b803          	ld	a6,0(a3)
    if (list_empty(&free_list)) {
ffffffffc0201622:	4581                	li	a1,0
            if (base < page) {
ffffffffc0201624:	00e56a63          	bltu	a0,a4,ffffffffc0201638 <default_free_pages+0x78>
    return listelm->next;
ffffffffc0201628:	6798                	ld	a4,8(a5)
            } else if (list_next(le) == &free_list) {
ffffffffc020162a:	04d70c63          	beq	a4,a3,ffffffffc0201682 <default_free_pages+0xc2>
    for (; p != base + n; p ++) {
ffffffffc020162e:	87ba                	mv	a5,a4
            struct Page* page = le2page(le, page_link);
ffffffffc0201630:	fe878713          	addi	a4,a5,-24
            if (base < page) {
ffffffffc0201634:	fee57ae3          	bgeu	a0,a4,ffffffffc0201628 <default_free_pages+0x68>
ffffffffc0201638:	c199                	beqz	a1,ffffffffc020163e <default_free_pages+0x7e>
ffffffffc020163a:	0106b023          	sd	a6,0(a3)
    __list_add(elm, listelm->prev, listelm);
ffffffffc020163e:	6398                	ld	a4,0(a5)
 * This is only for internal list manipulation where we know
 * the prev/next entries already!
 * */
static inline void
__list_add(list_entry_t *elm, list_entry_t *prev, list_entry_t *next) {
    prev->next = next->prev = elm;
ffffffffc0201640:	e390                	sd	a2,0(a5)
ffffffffc0201642:	e710                	sd	a2,8(a4)
    elm->next = next;
ffffffffc0201644:	f11c                	sd	a5,32(a0)
    elm->prev = prev;
ffffffffc0201646:	ed18                	sd	a4,24(a0)
    if (le != &free_list) {
ffffffffc0201648:	00d70d63          	beq	a4,a3,ffffffffc0201662 <default_free_pages+0xa2>
        if (p + p->property == base) {
ffffffffc020164c:	ff872583          	lw	a1,-8(a4)
        p = le2page(le, page_link);
ffffffffc0201650:	fe870613          	addi	a2,a4,-24
        if (p + p->property == base) {
ffffffffc0201654:	02059813          	slli	a6,a1,0x20
ffffffffc0201658:	01a85793          	srli	a5,a6,0x1a
ffffffffc020165c:	97b2                	add	a5,a5,a2
ffffffffc020165e:	02f50c63          	beq	a0,a5,ffffffffc0201696 <default_free_pages+0xd6>
    return listelm->next;
ffffffffc0201662:	711c                	ld	a5,32(a0)
    if (le != &free_list) {
ffffffffc0201664:	00d78c63          	beq	a5,a3,ffffffffc020167c <default_free_pages+0xbc>
        if (base + base->property == p) {
ffffffffc0201668:	4910                	lw	a2,16(a0)
        p = le2page(le, page_link);
ffffffffc020166a:	fe878693          	addi	a3,a5,-24
        if (base + base->property == p) {
ffffffffc020166e:	02061593          	slli	a1,a2,0x20
ffffffffc0201672:	01a5d713          	srli	a4,a1,0x1a
ffffffffc0201676:	972a                	add	a4,a4,a0
ffffffffc0201678:	04e68a63          	beq	a3,a4,ffffffffc02016cc <default_free_pages+0x10c>
}
ffffffffc020167c:	60a2                	ld	ra,8(sp)
ffffffffc020167e:	0141                	addi	sp,sp,16
ffffffffc0201680:	8082                	ret
    prev->next = next->prev = elm;
ffffffffc0201682:	e790                	sd	a2,8(a5)
    elm->next = next;
ffffffffc0201684:	f114                	sd	a3,32(a0)
    return listelm->next;
ffffffffc0201686:	6798                	ld	a4,8(a5)
    elm->prev = prev;
ffffffffc0201688:	ed1c                	sd	a5,24(a0)
        while ((le = list_next(le)) != &free_list) {
ffffffffc020168a:	02d70763          	beq	a4,a3,ffffffffc02016b8 <default_free_pages+0xf8>
    prev->next = next->prev = elm;
ffffffffc020168e:	8832                	mv	a6,a2
ffffffffc0201690:	4585                	li	a1,1
    for (; p != base + n; p ++) {
ffffffffc0201692:	87ba                	mv	a5,a4
ffffffffc0201694:	bf71                	j	ffffffffc0201630 <default_free_pages+0x70>
            p->property += base->property;
ffffffffc0201696:	491c                	lw	a5,16(a0)
ffffffffc0201698:	9dbd                	addw	a1,a1,a5
ffffffffc020169a:	feb72c23          	sw	a1,-8(a4)
    __op_bit(and, __NOT, nr, ((volatile unsigned long *)addr));
ffffffffc020169e:	57f5                	li	a5,-3
ffffffffc02016a0:	60f8b02f          	amoand.d	zero,a5,(a7)
    __list_del(listelm->prev, listelm->next);
ffffffffc02016a4:	01853803          	ld	a6,24(a0)
ffffffffc02016a8:	710c                	ld	a1,32(a0)
            base = p;
ffffffffc02016aa:	8532                	mv	a0,a2
 * This is only for internal list manipulation where we know
 * the prev/next entries already!
 * */
static inline void
__list_del(list_entry_t *prev, list_entry_t *next) {
    prev->next = next;
ffffffffc02016ac:	00b83423          	sd	a1,8(a6)
    return listelm->next;
ffffffffc02016b0:	671c                	ld	a5,8(a4)
    next->prev = prev;
ffffffffc02016b2:	0105b023          	sd	a6,0(a1)
ffffffffc02016b6:	b77d                	j	ffffffffc0201664 <default_free_pages+0xa4>
ffffffffc02016b8:	e290                	sd	a2,0(a3)
        while ((le = list_next(le)) != &free_list) {
ffffffffc02016ba:	873e                	mv	a4,a5
ffffffffc02016bc:	bf41                	j	ffffffffc020164c <default_free_pages+0x8c>
}
ffffffffc02016be:	60a2                	ld	ra,8(sp)
    prev->next = next->prev = elm;
ffffffffc02016c0:	e390                	sd	a2,0(a5)
ffffffffc02016c2:	e790                	sd	a2,8(a5)
    elm->next = next;
ffffffffc02016c4:	f11c                	sd	a5,32(a0)
    elm->prev = prev;
ffffffffc02016c6:	ed1c                	sd	a5,24(a0)
ffffffffc02016c8:	0141                	addi	sp,sp,16
ffffffffc02016ca:	8082                	ret
            base->property += p->property;
ffffffffc02016cc:	ff87a703          	lw	a4,-8(a5)
ffffffffc02016d0:	ff078693          	addi	a3,a5,-16
ffffffffc02016d4:	9e39                	addw	a2,a2,a4
ffffffffc02016d6:	c910                	sw	a2,16(a0)
ffffffffc02016d8:	5775                	li	a4,-3
ffffffffc02016da:	60e6b02f          	amoand.d	zero,a4,(a3)
    __list_del(listelm->prev, listelm->next);
ffffffffc02016de:	6398                	ld	a4,0(a5)
ffffffffc02016e0:	679c                	ld	a5,8(a5)
}
ffffffffc02016e2:	60a2                	ld	ra,8(sp)
    prev->next = next;
ffffffffc02016e4:	e71c                	sd	a5,8(a4)
    next->prev = prev;
ffffffffc02016e6:	e398                	sd	a4,0(a5)
ffffffffc02016e8:	0141                	addi	sp,sp,16
ffffffffc02016ea:	8082                	ret
        assert(!PageReserved(p) && !PageProperty(p));
ffffffffc02016ec:	00006697          	auipc	a3,0x6
ffffffffc02016f0:	d4468693          	addi	a3,a3,-700 # ffffffffc0207430 <commands+0xa98>
ffffffffc02016f4:	00005617          	auipc	a2,0x5
ffffffffc02016f8:	6f460613          	addi	a2,a2,1780 # ffffffffc0206de8 <commands+0x450>
ffffffffc02016fc:	08300593          	li	a1,131
ffffffffc0201700:	00006517          	auipc	a0,0x6
ffffffffc0201704:	9e850513          	addi	a0,a0,-1560 # ffffffffc02070e8 <commands+0x750>
ffffffffc0201708:	d73fe0ef          	jal	ra,ffffffffc020047a <__panic>
    assert(n > 0);
ffffffffc020170c:	00006697          	auipc	a3,0x6
ffffffffc0201710:	d1c68693          	addi	a3,a3,-740 # ffffffffc0207428 <commands+0xa90>
ffffffffc0201714:	00005617          	auipc	a2,0x5
ffffffffc0201718:	6d460613          	addi	a2,a2,1748 # ffffffffc0206de8 <commands+0x450>
ffffffffc020171c:	08000593          	li	a1,128
ffffffffc0201720:	00006517          	auipc	a0,0x6
ffffffffc0201724:	9c850513          	addi	a0,a0,-1592 # ffffffffc02070e8 <commands+0x750>
ffffffffc0201728:	d53fe0ef          	jal	ra,ffffffffc020047a <__panic>

ffffffffc020172c <default_alloc_pages>:
    assert(n > 0);
ffffffffc020172c:	c941                	beqz	a0,ffffffffc02017bc <default_alloc_pages+0x90>
    if (n > nr_free) {
ffffffffc020172e:	000ad597          	auipc	a1,0xad
ffffffffc0201732:	08258593          	addi	a1,a1,130 # ffffffffc02ae7b0 <free_area>
ffffffffc0201736:	0105a803          	lw	a6,16(a1)
ffffffffc020173a:	872a                	mv	a4,a0
ffffffffc020173c:	02081793          	slli	a5,a6,0x20
ffffffffc0201740:	9381                	srli	a5,a5,0x20
ffffffffc0201742:	00a7ee63          	bltu	a5,a0,ffffffffc020175e <default_alloc_pages+0x32>
    list_entry_t *le = &free_list;
ffffffffc0201746:	87ae                	mv	a5,a1
ffffffffc0201748:	a801                	j	ffffffffc0201758 <default_alloc_pages+0x2c>
        if (p->property >= n) {
ffffffffc020174a:	ff87a683          	lw	a3,-8(a5)
ffffffffc020174e:	02069613          	slli	a2,a3,0x20
ffffffffc0201752:	9201                	srli	a2,a2,0x20
ffffffffc0201754:	00e67763          	bgeu	a2,a4,ffffffffc0201762 <default_alloc_pages+0x36>
    return listelm->next;
ffffffffc0201758:	679c                	ld	a5,8(a5)
    while ((le = list_next(le)) != &free_list) {
ffffffffc020175a:	feb798e3          	bne	a5,a1,ffffffffc020174a <default_alloc_pages+0x1e>
        return NULL;
ffffffffc020175e:	4501                	li	a0,0
}
ffffffffc0201760:	8082                	ret
    return listelm->prev;
ffffffffc0201762:	0007b883          	ld	a7,0(a5)
    __list_del(listelm->prev, listelm->next);
ffffffffc0201766:	0087b303          	ld	t1,8(a5)
        struct Page *p = le2page(le, page_link);
ffffffffc020176a:	fe878513          	addi	a0,a5,-24
            p->property = page->property - n;
ffffffffc020176e:	00070e1b          	sext.w	t3,a4
    prev->next = next;
ffffffffc0201772:	0068b423          	sd	t1,8(a7)
    next->prev = prev;
ffffffffc0201776:	01133023          	sd	a7,0(t1)
        if (page->property > n) {
ffffffffc020177a:	02c77863          	bgeu	a4,a2,ffffffffc02017aa <default_alloc_pages+0x7e>
            struct Page *p = page + n;
ffffffffc020177e:	071a                	slli	a4,a4,0x6
ffffffffc0201780:	972a                	add	a4,a4,a0
            p->property = page->property - n;
ffffffffc0201782:	41c686bb          	subw	a3,a3,t3
ffffffffc0201786:	cb14                	sw	a3,16(a4)
    __op_bit(or, __NOP, nr, ((volatile unsigned long *)addr));
ffffffffc0201788:	00870613          	addi	a2,a4,8
ffffffffc020178c:	4689                	li	a3,2
ffffffffc020178e:	40d6302f          	amoor.d	zero,a3,(a2)
    __list_add(elm, listelm, listelm->next);
ffffffffc0201792:	0088b683          	ld	a3,8(a7)
            list_add(prev, &(p->page_link));
ffffffffc0201796:	01870613          	addi	a2,a4,24
        nr_free -= n;
ffffffffc020179a:	0105a803          	lw	a6,16(a1)
    prev->next = next->prev = elm;
ffffffffc020179e:	e290                	sd	a2,0(a3)
ffffffffc02017a0:	00c8b423          	sd	a2,8(a7)
    elm->next = next;
ffffffffc02017a4:	f314                	sd	a3,32(a4)
    elm->prev = prev;
ffffffffc02017a6:	01173c23          	sd	a7,24(a4)
ffffffffc02017aa:	41c8083b          	subw	a6,a6,t3
ffffffffc02017ae:	0105a823          	sw	a6,16(a1)
    __op_bit(and, __NOT, nr, ((volatile unsigned long *)addr));
ffffffffc02017b2:	5775                	li	a4,-3
ffffffffc02017b4:	17c1                	addi	a5,a5,-16
ffffffffc02017b6:	60e7b02f          	amoand.d	zero,a4,(a5)
}
ffffffffc02017ba:	8082                	ret
default_alloc_pages(size_t n) {
ffffffffc02017bc:	1141                	addi	sp,sp,-16
    assert(n > 0);
ffffffffc02017be:	00006697          	auipc	a3,0x6
ffffffffc02017c2:	c6a68693          	addi	a3,a3,-918 # ffffffffc0207428 <commands+0xa90>
ffffffffc02017c6:	00005617          	auipc	a2,0x5
ffffffffc02017ca:	62260613          	addi	a2,a2,1570 # ffffffffc0206de8 <commands+0x450>
ffffffffc02017ce:	06200593          	li	a1,98
ffffffffc02017d2:	00006517          	auipc	a0,0x6
ffffffffc02017d6:	91650513          	addi	a0,a0,-1770 # ffffffffc02070e8 <commands+0x750>
default_alloc_pages(size_t n) {
ffffffffc02017da:	e406                	sd	ra,8(sp)
    assert(n > 0);
ffffffffc02017dc:	c9ffe0ef          	jal	ra,ffffffffc020047a <__panic>

ffffffffc02017e0 <default_init_memmap>:
default_init_memmap(struct Page *base, size_t n) {
ffffffffc02017e0:	1141                	addi	sp,sp,-16
ffffffffc02017e2:	e406                	sd	ra,8(sp)
    assert(n > 0);
ffffffffc02017e4:	c5f1                	beqz	a1,ffffffffc02018b0 <default_init_memmap+0xd0>
    for (; p != base + n; p ++) {
ffffffffc02017e6:	00659693          	slli	a3,a1,0x6
ffffffffc02017ea:	96aa                	add	a3,a3,a0
ffffffffc02017ec:	87aa                	mv	a5,a0
ffffffffc02017ee:	00d50f63          	beq	a0,a3,ffffffffc020180c <default_init_memmap+0x2c>
    return (((*(volatile unsigned long *)addr) >> nr) & 1);
ffffffffc02017f2:	6798                	ld	a4,8(a5)
ffffffffc02017f4:	8b05                	andi	a4,a4,1
        assert(PageReserved(p));
ffffffffc02017f6:	cf49                	beqz	a4,ffffffffc0201890 <default_init_memmap+0xb0>
        p->flags = p->property = 0;
ffffffffc02017f8:	0007a823          	sw	zero,16(a5)
ffffffffc02017fc:	0007b423          	sd	zero,8(a5)
ffffffffc0201800:	0007a023          	sw	zero,0(a5)
    for (; p != base + n; p ++) {
ffffffffc0201804:	04078793          	addi	a5,a5,64
ffffffffc0201808:	fed795e3          	bne	a5,a3,ffffffffc02017f2 <default_init_memmap+0x12>
    base->property = n;
ffffffffc020180c:	2581                	sext.w	a1,a1
ffffffffc020180e:	c90c                	sw	a1,16(a0)
    __op_bit(or, __NOP, nr, ((volatile unsigned long *)addr));
ffffffffc0201810:	4789                	li	a5,2
ffffffffc0201812:	00850713          	addi	a4,a0,8
ffffffffc0201816:	40f7302f          	amoor.d	zero,a5,(a4)
    nr_free += n;
ffffffffc020181a:	000ad697          	auipc	a3,0xad
ffffffffc020181e:	f9668693          	addi	a3,a3,-106 # ffffffffc02ae7b0 <free_area>
ffffffffc0201822:	4a98                	lw	a4,16(a3)
    return list->next == list;
ffffffffc0201824:	669c                	ld	a5,8(a3)
        list_add(&free_list, &(base->page_link));
ffffffffc0201826:	01850613          	addi	a2,a0,24
    nr_free += n;
ffffffffc020182a:	9db9                	addw	a1,a1,a4
ffffffffc020182c:	ca8c                	sw	a1,16(a3)
    if (list_empty(&free_list)) {
ffffffffc020182e:	04d78a63          	beq	a5,a3,ffffffffc0201882 <default_init_memmap+0xa2>
            struct Page* page = le2page(le, page_link);
ffffffffc0201832:	fe878713          	addi	a4,a5,-24
ffffffffc0201836:	0006b803          	ld	a6,0(a3)
    if (list_empty(&free_list)) {
ffffffffc020183a:	4581                	li	a1,0
            if (base < page) {
ffffffffc020183c:	00e56a63          	bltu	a0,a4,ffffffffc0201850 <default_init_memmap+0x70>
    return listelm->next;
ffffffffc0201840:	6798                	ld	a4,8(a5)
            } else if (list_next(le) == &free_list) {
ffffffffc0201842:	02d70263          	beq	a4,a3,ffffffffc0201866 <default_init_memmap+0x86>
    for (; p != base + n; p ++) {
ffffffffc0201846:	87ba                	mv	a5,a4
            struct Page* page = le2page(le, page_link);
ffffffffc0201848:	fe878713          	addi	a4,a5,-24
            if (base < page) {
ffffffffc020184c:	fee57ae3          	bgeu	a0,a4,ffffffffc0201840 <default_init_memmap+0x60>
ffffffffc0201850:	c199                	beqz	a1,ffffffffc0201856 <default_init_memmap+0x76>
ffffffffc0201852:	0106b023          	sd	a6,0(a3)
    __list_add(elm, listelm->prev, listelm);
ffffffffc0201856:	6398                	ld	a4,0(a5)
}
ffffffffc0201858:	60a2                	ld	ra,8(sp)
    prev->next = next->prev = elm;
ffffffffc020185a:	e390                	sd	a2,0(a5)
ffffffffc020185c:	e710                	sd	a2,8(a4)
    elm->next = next;
ffffffffc020185e:	f11c                	sd	a5,32(a0)
    elm->prev = prev;
ffffffffc0201860:	ed18                	sd	a4,24(a0)
ffffffffc0201862:	0141                	addi	sp,sp,16
ffffffffc0201864:	8082                	ret
    prev->next = next->prev = elm;
ffffffffc0201866:	e790                	sd	a2,8(a5)
    elm->next = next;
ffffffffc0201868:	f114                	sd	a3,32(a0)
    return listelm->next;
ffffffffc020186a:	6798                	ld	a4,8(a5)
    elm->prev = prev;
ffffffffc020186c:	ed1c                	sd	a5,24(a0)
        while ((le = list_next(le)) != &free_list) {
ffffffffc020186e:	00d70663          	beq	a4,a3,ffffffffc020187a <default_init_memmap+0x9a>
    prev->next = next->prev = elm;
ffffffffc0201872:	8832                	mv	a6,a2
ffffffffc0201874:	4585                	li	a1,1
    for (; p != base + n; p ++) {
ffffffffc0201876:	87ba                	mv	a5,a4
ffffffffc0201878:	bfc1                	j	ffffffffc0201848 <default_init_memmap+0x68>
}
ffffffffc020187a:	60a2                	ld	ra,8(sp)
ffffffffc020187c:	e290                	sd	a2,0(a3)
ffffffffc020187e:	0141                	addi	sp,sp,16
ffffffffc0201880:	8082                	ret
ffffffffc0201882:	60a2                	ld	ra,8(sp)
ffffffffc0201884:	e390                	sd	a2,0(a5)
ffffffffc0201886:	e790                	sd	a2,8(a5)
    elm->next = next;
ffffffffc0201888:	f11c                	sd	a5,32(a0)
    elm->prev = prev;
ffffffffc020188a:	ed1c                	sd	a5,24(a0)
ffffffffc020188c:	0141                	addi	sp,sp,16
ffffffffc020188e:	8082                	ret
        assert(PageReserved(p));
ffffffffc0201890:	00006697          	auipc	a3,0x6
ffffffffc0201894:	bc868693          	addi	a3,a3,-1080 # ffffffffc0207458 <commands+0xac0>
ffffffffc0201898:	00005617          	auipc	a2,0x5
ffffffffc020189c:	55060613          	addi	a2,a2,1360 # ffffffffc0206de8 <commands+0x450>
ffffffffc02018a0:	04900593          	li	a1,73
ffffffffc02018a4:	00006517          	auipc	a0,0x6
ffffffffc02018a8:	84450513          	addi	a0,a0,-1980 # ffffffffc02070e8 <commands+0x750>
ffffffffc02018ac:	bcffe0ef          	jal	ra,ffffffffc020047a <__panic>
    assert(n > 0);
ffffffffc02018b0:	00006697          	auipc	a3,0x6
ffffffffc02018b4:	b7868693          	addi	a3,a3,-1160 # ffffffffc0207428 <commands+0xa90>
ffffffffc02018b8:	00005617          	auipc	a2,0x5
ffffffffc02018bc:	53060613          	addi	a2,a2,1328 # ffffffffc0206de8 <commands+0x450>
ffffffffc02018c0:	04600593          	li	a1,70
ffffffffc02018c4:	00006517          	auipc	a0,0x6
ffffffffc02018c8:	82450513          	addi	a0,a0,-2012 # ffffffffc02070e8 <commands+0x750>
ffffffffc02018cc:	baffe0ef          	jal	ra,ffffffffc020047a <__panic>

ffffffffc02018d0 <slob_free>:
static void slob_free(void *block, int size)
{
	slob_t *cur, *b = (slob_t *)block;
	unsigned long flags;

	if (!block)
ffffffffc02018d0:	c94d                	beqz	a0,ffffffffc0201982 <slob_free+0xb2>
{
ffffffffc02018d2:	1141                	addi	sp,sp,-16
ffffffffc02018d4:	e022                	sd	s0,0(sp)
ffffffffc02018d6:	e406                	sd	ra,8(sp)
ffffffffc02018d8:	842a                	mv	s0,a0
		return;

	if (size)
ffffffffc02018da:	e9c1                	bnez	a1,ffffffffc020196a <slob_free+0x9a>
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc02018dc:	100027f3          	csrr	a5,sstatus
ffffffffc02018e0:	8b89                	andi	a5,a5,2
    return 0;
ffffffffc02018e2:	4501                	li	a0,0
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc02018e4:	ebd9                	bnez	a5,ffffffffc020197a <slob_free+0xaa>
		b->units = SLOB_UNITS(size);

	/* Find reinsertion point */
	spin_lock_irqsave(&slob_lock, flags);
	for (cur = slobfree; !(b > cur && b < cur->next); cur = cur->next)
ffffffffc02018e6:	000a6617          	auipc	a2,0xa6
ffffffffc02018ea:	aba60613          	addi	a2,a2,-1350 # ffffffffc02a73a0 <slobfree>
ffffffffc02018ee:	621c                	ld	a5,0(a2)
		if (cur >= cur->next && (b > cur || b < cur->next))
ffffffffc02018f0:	873e                	mv	a4,a5
	for (cur = slobfree; !(b > cur && b < cur->next); cur = cur->next)
ffffffffc02018f2:	679c                	ld	a5,8(a5)
ffffffffc02018f4:	02877a63          	bgeu	a4,s0,ffffffffc0201928 <slob_free+0x58>
ffffffffc02018f8:	00f46463          	bltu	s0,a5,ffffffffc0201900 <slob_free+0x30>
		if (cur >= cur->next && (b > cur || b < cur->next))
ffffffffc02018fc:	fef76ae3          	bltu	a4,a5,ffffffffc02018f0 <slob_free+0x20>
			break;

	if (b + b->units == cur->next) {
ffffffffc0201900:	400c                	lw	a1,0(s0)
ffffffffc0201902:	00459693          	slli	a3,a1,0x4
ffffffffc0201906:	96a2                	add	a3,a3,s0
ffffffffc0201908:	02d78a63          	beq	a5,a3,ffffffffc020193c <slob_free+0x6c>
		b->units += cur->next->units;
		b->next = cur->next->next;
	} else
		b->next = cur->next;

	if (cur + cur->units == b) {
ffffffffc020190c:	4314                	lw	a3,0(a4)
		b->next = cur->next;
ffffffffc020190e:	e41c                	sd	a5,8(s0)
	if (cur + cur->units == b) {
ffffffffc0201910:	00469793          	slli	a5,a3,0x4
ffffffffc0201914:	97ba                	add	a5,a5,a4
ffffffffc0201916:	02f40e63          	beq	s0,a5,ffffffffc0201952 <slob_free+0x82>
		cur->units += b->units;
		cur->next = b->next;
	} else
		cur->next = b;
ffffffffc020191a:	e700                	sd	s0,8(a4)

	slobfree = cur;
ffffffffc020191c:	e218                	sd	a4,0(a2)
    if (flag) {
ffffffffc020191e:	e129                	bnez	a0,ffffffffc0201960 <slob_free+0x90>

	spin_unlock_irqrestore(&slob_lock, flags);
}
ffffffffc0201920:	60a2                	ld	ra,8(sp)
ffffffffc0201922:	6402                	ld	s0,0(sp)
ffffffffc0201924:	0141                	addi	sp,sp,16
ffffffffc0201926:	8082                	ret
		if (cur >= cur->next && (b > cur || b < cur->next))
ffffffffc0201928:	fcf764e3          	bltu	a4,a5,ffffffffc02018f0 <slob_free+0x20>
ffffffffc020192c:	fcf472e3          	bgeu	s0,a5,ffffffffc02018f0 <slob_free+0x20>
	if (b + b->units == cur->next) {
ffffffffc0201930:	400c                	lw	a1,0(s0)
ffffffffc0201932:	00459693          	slli	a3,a1,0x4
ffffffffc0201936:	96a2                	add	a3,a3,s0
ffffffffc0201938:	fcd79ae3          	bne	a5,a3,ffffffffc020190c <slob_free+0x3c>
		b->units += cur->next->units;
ffffffffc020193c:	4394                	lw	a3,0(a5)
		b->next = cur->next->next;
ffffffffc020193e:	679c                	ld	a5,8(a5)
		b->units += cur->next->units;
ffffffffc0201940:	9db5                	addw	a1,a1,a3
ffffffffc0201942:	c00c                	sw	a1,0(s0)
	if (cur + cur->units == b) {
ffffffffc0201944:	4314                	lw	a3,0(a4)
		b->next = cur->next->next;
ffffffffc0201946:	e41c                	sd	a5,8(s0)
	if (cur + cur->units == b) {
ffffffffc0201948:	00469793          	slli	a5,a3,0x4
ffffffffc020194c:	97ba                	add	a5,a5,a4
ffffffffc020194e:	fcf416e3          	bne	s0,a5,ffffffffc020191a <slob_free+0x4a>
		cur->units += b->units;
ffffffffc0201952:	401c                	lw	a5,0(s0)
		cur->next = b->next;
ffffffffc0201954:	640c                	ld	a1,8(s0)
	slobfree = cur;
ffffffffc0201956:	e218                	sd	a4,0(a2)
		cur->units += b->units;
ffffffffc0201958:	9ebd                	addw	a3,a3,a5
ffffffffc020195a:	c314                	sw	a3,0(a4)
		cur->next = b->next;
ffffffffc020195c:	e70c                	sd	a1,8(a4)
ffffffffc020195e:	d169                	beqz	a0,ffffffffc0201920 <slob_free+0x50>
}
ffffffffc0201960:	6402                	ld	s0,0(sp)
ffffffffc0201962:	60a2                	ld	ra,8(sp)
ffffffffc0201964:	0141                	addi	sp,sp,16
        intr_enable();
ffffffffc0201966:	cdbfe06f          	j	ffffffffc0200640 <intr_enable>
		b->units = SLOB_UNITS(size);
ffffffffc020196a:	25bd                	addiw	a1,a1,15
ffffffffc020196c:	8191                	srli	a1,a1,0x4
ffffffffc020196e:	c10c                	sw	a1,0(a0)
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0201970:	100027f3          	csrr	a5,sstatus
ffffffffc0201974:	8b89                	andi	a5,a5,2
    return 0;
ffffffffc0201976:	4501                	li	a0,0
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0201978:	d7bd                	beqz	a5,ffffffffc02018e6 <slob_free+0x16>
        intr_disable();
ffffffffc020197a:	ccdfe0ef          	jal	ra,ffffffffc0200646 <intr_disable>
        return 1;
ffffffffc020197e:	4505                	li	a0,1
ffffffffc0201980:	b79d                	j	ffffffffc02018e6 <slob_free+0x16>
ffffffffc0201982:	8082                	ret

ffffffffc0201984 <__slob_get_free_pages.constprop.0>:
  struct Page * page = alloc_pages(1 << order);
ffffffffc0201984:	4785                	li	a5,1
static void* __slob_get_free_pages(gfp_t gfp, int order)
ffffffffc0201986:	1141                	addi	sp,sp,-16
  struct Page * page = alloc_pages(1 << order);
ffffffffc0201988:	00a7953b          	sllw	a0,a5,a0
static void* __slob_get_free_pages(gfp_t gfp, int order)
ffffffffc020198c:	e406                	sd	ra,8(sp)
  struct Page * page = alloc_pages(1 << order);
ffffffffc020198e:	352000ef          	jal	ra,ffffffffc0201ce0 <alloc_pages>
  if(!page)
ffffffffc0201992:	c91d                	beqz	a0,ffffffffc02019c8 <__slob_get_free_pages.constprop.0+0x44>
    return page - pages + nbase;
ffffffffc0201994:	000b1697          	auipc	a3,0xb1
ffffffffc0201998:	f1c6b683          	ld	a3,-228(a3) # ffffffffc02b28b0 <pages>
ffffffffc020199c:	8d15                	sub	a0,a0,a3
ffffffffc020199e:	8519                	srai	a0,a0,0x6
ffffffffc02019a0:	00007697          	auipc	a3,0x7
ffffffffc02019a4:	4a06b683          	ld	a3,1184(a3) # ffffffffc0208e40 <nbase>
ffffffffc02019a8:	9536                	add	a0,a0,a3
    return KADDR(page2pa(page));
ffffffffc02019aa:	00c51793          	slli	a5,a0,0xc
ffffffffc02019ae:	83b1                	srli	a5,a5,0xc
ffffffffc02019b0:	000b1717          	auipc	a4,0xb1
ffffffffc02019b4:	ef873703          	ld	a4,-264(a4) # ffffffffc02b28a8 <npage>
    return page2ppn(page) << PGSHIFT;
ffffffffc02019b8:	0532                	slli	a0,a0,0xc
    return KADDR(page2pa(page));
ffffffffc02019ba:	00e7fa63          	bgeu	a5,a4,ffffffffc02019ce <__slob_get_free_pages.constprop.0+0x4a>
ffffffffc02019be:	000b1697          	auipc	a3,0xb1
ffffffffc02019c2:	f026b683          	ld	a3,-254(a3) # ffffffffc02b28c0 <va_pa_offset>
ffffffffc02019c6:	9536                	add	a0,a0,a3
}
ffffffffc02019c8:	60a2                	ld	ra,8(sp)
ffffffffc02019ca:	0141                	addi	sp,sp,16
ffffffffc02019cc:	8082                	ret
ffffffffc02019ce:	86aa                	mv	a3,a0
ffffffffc02019d0:	00006617          	auipc	a2,0x6
ffffffffc02019d4:	ae860613          	addi	a2,a2,-1304 # ffffffffc02074b8 <default_pmm_manager+0x38>
ffffffffc02019d8:	06900593          	li	a1,105
ffffffffc02019dc:	00006517          	auipc	a0,0x6
ffffffffc02019e0:	b0450513          	addi	a0,a0,-1276 # ffffffffc02074e0 <default_pmm_manager+0x60>
ffffffffc02019e4:	a97fe0ef          	jal	ra,ffffffffc020047a <__panic>

ffffffffc02019e8 <slob_alloc.constprop.0>:
static void *slob_alloc(size_t size, gfp_t gfp, int align)
ffffffffc02019e8:	1101                	addi	sp,sp,-32
ffffffffc02019ea:	ec06                	sd	ra,24(sp)
ffffffffc02019ec:	e822                	sd	s0,16(sp)
ffffffffc02019ee:	e426                	sd	s1,8(sp)
ffffffffc02019f0:	e04a                	sd	s2,0(sp)
  assert( (size + SLOB_UNIT) < PAGE_SIZE );
ffffffffc02019f2:	01050713          	addi	a4,a0,16
ffffffffc02019f6:	6785                	lui	a5,0x1
ffffffffc02019f8:	0cf77363          	bgeu	a4,a5,ffffffffc0201abe <slob_alloc.constprop.0+0xd6>
	int delta = 0, units = SLOB_UNITS(size);
ffffffffc02019fc:	00f50493          	addi	s1,a0,15
ffffffffc0201a00:	8091                	srli	s1,s1,0x4
ffffffffc0201a02:	2481                	sext.w	s1,s1
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0201a04:	10002673          	csrr	a2,sstatus
ffffffffc0201a08:	8a09                	andi	a2,a2,2
ffffffffc0201a0a:	e25d                	bnez	a2,ffffffffc0201ab0 <slob_alloc.constprop.0+0xc8>
	prev = slobfree;
ffffffffc0201a0c:	000a6917          	auipc	s2,0xa6
ffffffffc0201a10:	99490913          	addi	s2,s2,-1644 # ffffffffc02a73a0 <slobfree>
ffffffffc0201a14:	00093683          	ld	a3,0(s2)
	for (cur = prev->next; ; prev = cur, cur = cur->next) {
ffffffffc0201a18:	669c                	ld	a5,8(a3)
		if (cur->units >= units + delta) { /* room enough? */
ffffffffc0201a1a:	4398                	lw	a4,0(a5)
ffffffffc0201a1c:	08975e63          	bge	a4,s1,ffffffffc0201ab8 <slob_alloc.constprop.0+0xd0>
		if (cur == slobfree) {
ffffffffc0201a20:	00f68b63          	beq	a3,a5,ffffffffc0201a36 <slob_alloc.constprop.0+0x4e>
	for (cur = prev->next; ; prev = cur, cur = cur->next) {
ffffffffc0201a24:	6780                	ld	s0,8(a5)
		if (cur->units >= units + delta) { /* room enough? */
ffffffffc0201a26:	4018                	lw	a4,0(s0)
ffffffffc0201a28:	02975a63          	bge	a4,s1,ffffffffc0201a5c <slob_alloc.constprop.0+0x74>
		if (cur == slobfree) {
ffffffffc0201a2c:	00093683          	ld	a3,0(s2)
ffffffffc0201a30:	87a2                	mv	a5,s0
ffffffffc0201a32:	fef699e3          	bne	a3,a5,ffffffffc0201a24 <slob_alloc.constprop.0+0x3c>
    if (flag) {
ffffffffc0201a36:	ee31                	bnez	a2,ffffffffc0201a92 <slob_alloc.constprop.0+0xaa>
			cur = (slob_t *)__slob_get_free_page(gfp);
ffffffffc0201a38:	4501                	li	a0,0
ffffffffc0201a3a:	f4bff0ef          	jal	ra,ffffffffc0201984 <__slob_get_free_pages.constprop.0>
ffffffffc0201a3e:	842a                	mv	s0,a0
			if (!cur)
ffffffffc0201a40:	cd05                	beqz	a0,ffffffffc0201a78 <slob_alloc.constprop.0+0x90>
			slob_free(cur, PAGE_SIZE);
ffffffffc0201a42:	6585                	lui	a1,0x1
ffffffffc0201a44:	e8dff0ef          	jal	ra,ffffffffc02018d0 <slob_free>
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0201a48:	10002673          	csrr	a2,sstatus
ffffffffc0201a4c:	8a09                	andi	a2,a2,2
ffffffffc0201a4e:	ee05                	bnez	a2,ffffffffc0201a86 <slob_alloc.constprop.0+0x9e>
			cur = slobfree;
ffffffffc0201a50:	00093783          	ld	a5,0(s2)
	for (cur = prev->next; ; prev = cur, cur = cur->next) {
ffffffffc0201a54:	6780                	ld	s0,8(a5)
		if (cur->units >= units + delta) { /* room enough? */
ffffffffc0201a56:	4018                	lw	a4,0(s0)
ffffffffc0201a58:	fc974ae3          	blt	a4,s1,ffffffffc0201a2c <slob_alloc.constprop.0+0x44>
			if (cur->units == units) /* exact fit? */
ffffffffc0201a5c:	04e48763          	beq	s1,a4,ffffffffc0201aaa <slob_alloc.constprop.0+0xc2>
				prev->next = cur + units;
ffffffffc0201a60:	00449693          	slli	a3,s1,0x4
ffffffffc0201a64:	96a2                	add	a3,a3,s0
ffffffffc0201a66:	e794                	sd	a3,8(a5)
				prev->next->next = cur->next;
ffffffffc0201a68:	640c                	ld	a1,8(s0)
				prev->next->units = cur->units - units;
ffffffffc0201a6a:	9f05                	subw	a4,a4,s1
ffffffffc0201a6c:	c298                	sw	a4,0(a3)
				prev->next->next = cur->next;
ffffffffc0201a6e:	e68c                	sd	a1,8(a3)
				cur->units = units;
ffffffffc0201a70:	c004                	sw	s1,0(s0)
			slobfree = prev;
ffffffffc0201a72:	00f93023          	sd	a5,0(s2)
    if (flag) {
ffffffffc0201a76:	e20d                	bnez	a2,ffffffffc0201a98 <slob_alloc.constprop.0+0xb0>
}
ffffffffc0201a78:	60e2                	ld	ra,24(sp)
ffffffffc0201a7a:	8522                	mv	a0,s0
ffffffffc0201a7c:	6442                	ld	s0,16(sp)
ffffffffc0201a7e:	64a2                	ld	s1,8(sp)
ffffffffc0201a80:	6902                	ld	s2,0(sp)
ffffffffc0201a82:	6105                	addi	sp,sp,32
ffffffffc0201a84:	8082                	ret
        intr_disable();
ffffffffc0201a86:	bc1fe0ef          	jal	ra,ffffffffc0200646 <intr_disable>
			cur = slobfree;
ffffffffc0201a8a:	00093783          	ld	a5,0(s2)
        return 1;
ffffffffc0201a8e:	4605                	li	a2,1
ffffffffc0201a90:	b7d1                	j	ffffffffc0201a54 <slob_alloc.constprop.0+0x6c>
        intr_enable();
ffffffffc0201a92:	baffe0ef          	jal	ra,ffffffffc0200640 <intr_enable>
ffffffffc0201a96:	b74d                	j	ffffffffc0201a38 <slob_alloc.constprop.0+0x50>
ffffffffc0201a98:	ba9fe0ef          	jal	ra,ffffffffc0200640 <intr_enable>
}
ffffffffc0201a9c:	60e2                	ld	ra,24(sp)
ffffffffc0201a9e:	8522                	mv	a0,s0
ffffffffc0201aa0:	6442                	ld	s0,16(sp)
ffffffffc0201aa2:	64a2                	ld	s1,8(sp)
ffffffffc0201aa4:	6902                	ld	s2,0(sp)
ffffffffc0201aa6:	6105                	addi	sp,sp,32
ffffffffc0201aa8:	8082                	ret
				prev->next = cur->next; /* unlink */
ffffffffc0201aaa:	6418                	ld	a4,8(s0)
ffffffffc0201aac:	e798                	sd	a4,8(a5)
ffffffffc0201aae:	b7d1                	j	ffffffffc0201a72 <slob_alloc.constprop.0+0x8a>
        intr_disable();
ffffffffc0201ab0:	b97fe0ef          	jal	ra,ffffffffc0200646 <intr_disable>
        return 1;
ffffffffc0201ab4:	4605                	li	a2,1
ffffffffc0201ab6:	bf99                	j	ffffffffc0201a0c <slob_alloc.constprop.0+0x24>
		if (cur->units >= units + delta) { /* room enough? */
ffffffffc0201ab8:	843e                	mv	s0,a5
ffffffffc0201aba:	87b6                	mv	a5,a3
ffffffffc0201abc:	b745                	j	ffffffffc0201a5c <slob_alloc.constprop.0+0x74>
  assert( (size + SLOB_UNIT) < PAGE_SIZE );
ffffffffc0201abe:	00006697          	auipc	a3,0x6
ffffffffc0201ac2:	a3268693          	addi	a3,a3,-1486 # ffffffffc02074f0 <default_pmm_manager+0x70>
ffffffffc0201ac6:	00005617          	auipc	a2,0x5
ffffffffc0201aca:	32260613          	addi	a2,a2,802 # ffffffffc0206de8 <commands+0x450>
ffffffffc0201ace:	06400593          	li	a1,100
ffffffffc0201ad2:	00006517          	auipc	a0,0x6
ffffffffc0201ad6:	a3e50513          	addi	a0,a0,-1474 # ffffffffc0207510 <default_pmm_manager+0x90>
ffffffffc0201ada:	9a1fe0ef          	jal	ra,ffffffffc020047a <__panic>

ffffffffc0201ade <kmalloc_init>:
slob_init(void) {
  cprintf("use SLOB allocator\n");
}

inline void 
kmalloc_init(void) {
ffffffffc0201ade:	1141                	addi	sp,sp,-16
  cprintf("use SLOB allocator\n");
ffffffffc0201ae0:	00006517          	auipc	a0,0x6
ffffffffc0201ae4:	a4850513          	addi	a0,a0,-1464 # ffffffffc0207528 <default_pmm_manager+0xa8>
kmalloc_init(void) {
ffffffffc0201ae8:	e406                	sd	ra,8(sp)
  cprintf("use SLOB allocator\n");
ffffffffc0201aea:	e96fe0ef          	jal	ra,ffffffffc0200180 <cprintf>
    slob_init();
    cprintf("kmalloc_init() succeeded!\n");
}
ffffffffc0201aee:	60a2                	ld	ra,8(sp)
    cprintf("kmalloc_init() succeeded!\n");
ffffffffc0201af0:	00006517          	auipc	a0,0x6
ffffffffc0201af4:	a5050513          	addi	a0,a0,-1456 # ffffffffc0207540 <default_pmm_manager+0xc0>
}
ffffffffc0201af8:	0141                	addi	sp,sp,16
    cprintf("kmalloc_init() succeeded!\n");
ffffffffc0201afa:	e86fe06f          	j	ffffffffc0200180 <cprintf>

ffffffffc0201afe <kallocated>:
}

size_t
kallocated(void) {
   return slob_allocated();
}
ffffffffc0201afe:	4501                	li	a0,0
ffffffffc0201b00:	8082                	ret

ffffffffc0201b02 <kmalloc>:
	return 0;
}

void *
kmalloc(size_t size)
{
ffffffffc0201b02:	1101                	addi	sp,sp,-32
ffffffffc0201b04:	e04a                	sd	s2,0(sp)
	if (size < PAGE_SIZE - SLOB_UNIT) {
ffffffffc0201b06:	6905                	lui	s2,0x1
{
ffffffffc0201b08:	e822                	sd	s0,16(sp)
ffffffffc0201b0a:	ec06                	sd	ra,24(sp)
ffffffffc0201b0c:	e426                	sd	s1,8(sp)
	if (size < PAGE_SIZE - SLOB_UNIT) {
ffffffffc0201b0e:	fef90793          	addi	a5,s2,-17 # fef <_binary_obj___user_faultread_out_size-0x8bc9>
{
ffffffffc0201b12:	842a                	mv	s0,a0
	if (size < PAGE_SIZE - SLOB_UNIT) {
ffffffffc0201b14:	04a7f963          	bgeu	a5,a0,ffffffffc0201b66 <kmalloc+0x64>
	bb = slob_alloc(sizeof(bigblock_t), gfp, 0);
ffffffffc0201b18:	4561                	li	a0,24
ffffffffc0201b1a:	ecfff0ef          	jal	ra,ffffffffc02019e8 <slob_alloc.constprop.0>
ffffffffc0201b1e:	84aa                	mv	s1,a0
	if (!bb)
ffffffffc0201b20:	c929                	beqz	a0,ffffffffc0201b72 <kmalloc+0x70>
	bb->order = find_order(size);
ffffffffc0201b22:	0004079b          	sext.w	a5,s0
	int order = 0;
ffffffffc0201b26:	4501                	li	a0,0
	for ( ; size > 4096 ; size >>=1)
ffffffffc0201b28:	00f95763          	bge	s2,a5,ffffffffc0201b36 <kmalloc+0x34>
ffffffffc0201b2c:	6705                	lui	a4,0x1
ffffffffc0201b2e:	8785                	srai	a5,a5,0x1
		order++;
ffffffffc0201b30:	2505                	addiw	a0,a0,1
	for ( ; size > 4096 ; size >>=1)
ffffffffc0201b32:	fef74ee3          	blt	a4,a5,ffffffffc0201b2e <kmalloc+0x2c>
	bb->order = find_order(size);
ffffffffc0201b36:	c088                	sw	a0,0(s1)
	bb->pages = (void *)__slob_get_free_pages(gfp, bb->order);
ffffffffc0201b38:	e4dff0ef          	jal	ra,ffffffffc0201984 <__slob_get_free_pages.constprop.0>
ffffffffc0201b3c:	e488                	sd	a0,8(s1)
ffffffffc0201b3e:	842a                	mv	s0,a0
	if (bb->pages) {
ffffffffc0201b40:	c525                	beqz	a0,ffffffffc0201ba8 <kmalloc+0xa6>
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0201b42:	100027f3          	csrr	a5,sstatus
ffffffffc0201b46:	8b89                	andi	a5,a5,2
ffffffffc0201b48:	ef8d                	bnez	a5,ffffffffc0201b82 <kmalloc+0x80>
		bb->next = bigblocks;
ffffffffc0201b4a:	000b1797          	auipc	a5,0xb1
ffffffffc0201b4e:	d4678793          	addi	a5,a5,-698 # ffffffffc02b2890 <bigblocks>
ffffffffc0201b52:	6398                	ld	a4,0(a5)
		bigblocks = bb;
ffffffffc0201b54:	e384                	sd	s1,0(a5)
		bb->next = bigblocks;
ffffffffc0201b56:	e898                	sd	a4,16(s1)
  return __kmalloc(size, 0);
}
ffffffffc0201b58:	60e2                	ld	ra,24(sp)
ffffffffc0201b5a:	8522                	mv	a0,s0
ffffffffc0201b5c:	6442                	ld	s0,16(sp)
ffffffffc0201b5e:	64a2                	ld	s1,8(sp)
ffffffffc0201b60:	6902                	ld	s2,0(sp)
ffffffffc0201b62:	6105                	addi	sp,sp,32
ffffffffc0201b64:	8082                	ret
		m = slob_alloc(size + SLOB_UNIT, gfp, 0);
ffffffffc0201b66:	0541                	addi	a0,a0,16
ffffffffc0201b68:	e81ff0ef          	jal	ra,ffffffffc02019e8 <slob_alloc.constprop.0>
		return m ? (void *)(m + 1) : 0;
ffffffffc0201b6c:	01050413          	addi	s0,a0,16
ffffffffc0201b70:	f565                	bnez	a0,ffffffffc0201b58 <kmalloc+0x56>
ffffffffc0201b72:	4401                	li	s0,0
}
ffffffffc0201b74:	60e2                	ld	ra,24(sp)
ffffffffc0201b76:	8522                	mv	a0,s0
ffffffffc0201b78:	6442                	ld	s0,16(sp)
ffffffffc0201b7a:	64a2                	ld	s1,8(sp)
ffffffffc0201b7c:	6902                	ld	s2,0(sp)
ffffffffc0201b7e:	6105                	addi	sp,sp,32
ffffffffc0201b80:	8082                	ret
        intr_disable();
ffffffffc0201b82:	ac5fe0ef          	jal	ra,ffffffffc0200646 <intr_disable>
		bb->next = bigblocks;
ffffffffc0201b86:	000b1797          	auipc	a5,0xb1
ffffffffc0201b8a:	d0a78793          	addi	a5,a5,-758 # ffffffffc02b2890 <bigblocks>
ffffffffc0201b8e:	6398                	ld	a4,0(a5)
		bigblocks = bb;
ffffffffc0201b90:	e384                	sd	s1,0(a5)
		bb->next = bigblocks;
ffffffffc0201b92:	e898                	sd	a4,16(s1)
        intr_enable();
ffffffffc0201b94:	aadfe0ef          	jal	ra,ffffffffc0200640 <intr_enable>
		return bb->pages;
ffffffffc0201b98:	6480                	ld	s0,8(s1)
}
ffffffffc0201b9a:	60e2                	ld	ra,24(sp)
ffffffffc0201b9c:	64a2                	ld	s1,8(sp)
ffffffffc0201b9e:	8522                	mv	a0,s0
ffffffffc0201ba0:	6442                	ld	s0,16(sp)
ffffffffc0201ba2:	6902                	ld	s2,0(sp)
ffffffffc0201ba4:	6105                	addi	sp,sp,32
ffffffffc0201ba6:	8082                	ret
	slob_free(bb, sizeof(bigblock_t));
ffffffffc0201ba8:	45e1                	li	a1,24
ffffffffc0201baa:	8526                	mv	a0,s1
ffffffffc0201bac:	d25ff0ef          	jal	ra,ffffffffc02018d0 <slob_free>
  return __kmalloc(size, 0);
ffffffffc0201bb0:	b765                	j	ffffffffc0201b58 <kmalloc+0x56>

ffffffffc0201bb2 <kfree>:
void kfree(void *block)
{
	bigblock_t *bb, **last = &bigblocks;
	unsigned long flags;

	if (!block)
ffffffffc0201bb2:	c169                	beqz	a0,ffffffffc0201c74 <kfree+0xc2>
{
ffffffffc0201bb4:	1101                	addi	sp,sp,-32
ffffffffc0201bb6:	e822                	sd	s0,16(sp)
ffffffffc0201bb8:	ec06                	sd	ra,24(sp)
ffffffffc0201bba:	e426                	sd	s1,8(sp)
		return;

	if (!((unsigned long)block & (PAGE_SIZE-1))) {
ffffffffc0201bbc:	03451793          	slli	a5,a0,0x34
ffffffffc0201bc0:	842a                	mv	s0,a0
ffffffffc0201bc2:	e3d9                	bnez	a5,ffffffffc0201c48 <kfree+0x96>
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0201bc4:	100027f3          	csrr	a5,sstatus
ffffffffc0201bc8:	8b89                	andi	a5,a5,2
ffffffffc0201bca:	e7d9                	bnez	a5,ffffffffc0201c58 <kfree+0xa6>
		/* might be on the big block list */
		spin_lock_irqsave(&block_lock, flags);
		for (bb = bigblocks; bb; last = &bb->next, bb = bb->next) {
ffffffffc0201bcc:	000b1797          	auipc	a5,0xb1
ffffffffc0201bd0:	cc47b783          	ld	a5,-828(a5) # ffffffffc02b2890 <bigblocks>
    return 0;
ffffffffc0201bd4:	4601                	li	a2,0
ffffffffc0201bd6:	cbad                	beqz	a5,ffffffffc0201c48 <kfree+0x96>
	bigblock_t *bb, **last = &bigblocks;
ffffffffc0201bd8:	000b1697          	auipc	a3,0xb1
ffffffffc0201bdc:	cb868693          	addi	a3,a3,-840 # ffffffffc02b2890 <bigblocks>
ffffffffc0201be0:	a021                	j	ffffffffc0201be8 <kfree+0x36>
		for (bb = bigblocks; bb; last = &bb->next, bb = bb->next) {
ffffffffc0201be2:	01048693          	addi	a3,s1,16
ffffffffc0201be6:	c3a5                	beqz	a5,ffffffffc0201c46 <kfree+0x94>
			if (bb->pages == block) {
ffffffffc0201be8:	6798                	ld	a4,8(a5)
ffffffffc0201bea:	84be                	mv	s1,a5
				*last = bb->next;
ffffffffc0201bec:	6b9c                	ld	a5,16(a5)
			if (bb->pages == block) {
ffffffffc0201bee:	fe871ae3          	bne	a4,s0,ffffffffc0201be2 <kfree+0x30>
				*last = bb->next;
ffffffffc0201bf2:	e29c                	sd	a5,0(a3)
    if (flag) {
ffffffffc0201bf4:	ee2d                	bnez	a2,ffffffffc0201c6e <kfree+0xbc>
    return pa2page(PADDR(kva));
ffffffffc0201bf6:	c02007b7          	lui	a5,0xc0200
				spin_unlock_irqrestore(&block_lock, flags);
				__slob_free_pages((unsigned long)block, bb->order);
ffffffffc0201bfa:	4098                	lw	a4,0(s1)
ffffffffc0201bfc:	08f46963          	bltu	s0,a5,ffffffffc0201c8e <kfree+0xdc>
ffffffffc0201c00:	000b1697          	auipc	a3,0xb1
ffffffffc0201c04:	cc06b683          	ld	a3,-832(a3) # ffffffffc02b28c0 <va_pa_offset>
ffffffffc0201c08:	8c15                	sub	s0,s0,a3
    if (PPN(pa) >= npage) {
ffffffffc0201c0a:	8031                	srli	s0,s0,0xc
ffffffffc0201c0c:	000b1797          	auipc	a5,0xb1
ffffffffc0201c10:	c9c7b783          	ld	a5,-868(a5) # ffffffffc02b28a8 <npage>
ffffffffc0201c14:	06f47163          	bgeu	s0,a5,ffffffffc0201c76 <kfree+0xc4>
    return &pages[PPN(pa) - nbase];
ffffffffc0201c18:	00007517          	auipc	a0,0x7
ffffffffc0201c1c:	22853503          	ld	a0,552(a0) # ffffffffc0208e40 <nbase>
ffffffffc0201c20:	8c09                	sub	s0,s0,a0
ffffffffc0201c22:	041a                	slli	s0,s0,0x6
  free_pages(kva2page(kva), 1 << order);
ffffffffc0201c24:	000b1517          	auipc	a0,0xb1
ffffffffc0201c28:	c8c53503          	ld	a0,-884(a0) # ffffffffc02b28b0 <pages>
ffffffffc0201c2c:	4585                	li	a1,1
ffffffffc0201c2e:	9522                	add	a0,a0,s0
ffffffffc0201c30:	00e595bb          	sllw	a1,a1,a4
ffffffffc0201c34:	13e000ef          	jal	ra,ffffffffc0201d72 <free_pages>
		spin_unlock_irqrestore(&block_lock, flags);
	}

	slob_free((slob_t *)block - 1, 0);
	return;
}
ffffffffc0201c38:	6442                	ld	s0,16(sp)
ffffffffc0201c3a:	60e2                	ld	ra,24(sp)
				slob_free(bb, sizeof(bigblock_t));
ffffffffc0201c3c:	8526                	mv	a0,s1
}
ffffffffc0201c3e:	64a2                	ld	s1,8(sp)
				slob_free(bb, sizeof(bigblock_t));
ffffffffc0201c40:	45e1                	li	a1,24
}
ffffffffc0201c42:	6105                	addi	sp,sp,32
	slob_free((slob_t *)block - 1, 0);
ffffffffc0201c44:	b171                	j	ffffffffc02018d0 <slob_free>
ffffffffc0201c46:	e20d                	bnez	a2,ffffffffc0201c68 <kfree+0xb6>
ffffffffc0201c48:	ff040513          	addi	a0,s0,-16
}
ffffffffc0201c4c:	6442                	ld	s0,16(sp)
ffffffffc0201c4e:	60e2                	ld	ra,24(sp)
ffffffffc0201c50:	64a2                	ld	s1,8(sp)
	slob_free((slob_t *)block - 1, 0);
ffffffffc0201c52:	4581                	li	a1,0
}
ffffffffc0201c54:	6105                	addi	sp,sp,32
	slob_free((slob_t *)block - 1, 0);
ffffffffc0201c56:	b9ad                	j	ffffffffc02018d0 <slob_free>
        intr_disable();
ffffffffc0201c58:	9effe0ef          	jal	ra,ffffffffc0200646 <intr_disable>
		for (bb = bigblocks; bb; last = &bb->next, bb = bb->next) {
ffffffffc0201c5c:	000b1797          	auipc	a5,0xb1
ffffffffc0201c60:	c347b783          	ld	a5,-972(a5) # ffffffffc02b2890 <bigblocks>
        return 1;
ffffffffc0201c64:	4605                	li	a2,1
ffffffffc0201c66:	fbad                	bnez	a5,ffffffffc0201bd8 <kfree+0x26>
        intr_enable();
ffffffffc0201c68:	9d9fe0ef          	jal	ra,ffffffffc0200640 <intr_enable>
ffffffffc0201c6c:	bff1                	j	ffffffffc0201c48 <kfree+0x96>
ffffffffc0201c6e:	9d3fe0ef          	jal	ra,ffffffffc0200640 <intr_enable>
ffffffffc0201c72:	b751                	j	ffffffffc0201bf6 <kfree+0x44>
ffffffffc0201c74:	8082                	ret
        panic("pa2page called with invalid pa");
ffffffffc0201c76:	00006617          	auipc	a2,0x6
ffffffffc0201c7a:	91260613          	addi	a2,a2,-1774 # ffffffffc0207588 <default_pmm_manager+0x108>
ffffffffc0201c7e:	06200593          	li	a1,98
ffffffffc0201c82:	00006517          	auipc	a0,0x6
ffffffffc0201c86:	85e50513          	addi	a0,a0,-1954 # ffffffffc02074e0 <default_pmm_manager+0x60>
ffffffffc0201c8a:	ff0fe0ef          	jal	ra,ffffffffc020047a <__panic>
    return pa2page(PADDR(kva));
ffffffffc0201c8e:	86a2                	mv	a3,s0
ffffffffc0201c90:	00006617          	auipc	a2,0x6
ffffffffc0201c94:	8d060613          	addi	a2,a2,-1840 # ffffffffc0207560 <default_pmm_manager+0xe0>
ffffffffc0201c98:	06e00593          	li	a1,110
ffffffffc0201c9c:	00006517          	auipc	a0,0x6
ffffffffc0201ca0:	84450513          	addi	a0,a0,-1980 # ffffffffc02074e0 <default_pmm_manager+0x60>
ffffffffc0201ca4:	fd6fe0ef          	jal	ra,ffffffffc020047a <__panic>

ffffffffc0201ca8 <pa2page.part.0>:
pa2page(uintptr_t pa) {
ffffffffc0201ca8:	1141                	addi	sp,sp,-16
        panic("pa2page called with invalid pa");
ffffffffc0201caa:	00006617          	auipc	a2,0x6
ffffffffc0201cae:	8de60613          	addi	a2,a2,-1826 # ffffffffc0207588 <default_pmm_manager+0x108>
ffffffffc0201cb2:	06200593          	li	a1,98
ffffffffc0201cb6:	00006517          	auipc	a0,0x6
ffffffffc0201cba:	82a50513          	addi	a0,a0,-2006 # ffffffffc02074e0 <default_pmm_manager+0x60>
pa2page(uintptr_t pa) {
ffffffffc0201cbe:	e406                	sd	ra,8(sp)
        panic("pa2page called with invalid pa");
ffffffffc0201cc0:	fbafe0ef          	jal	ra,ffffffffc020047a <__panic>

ffffffffc0201cc4 <pte2page.part.0>:
pte2page(pte_t pte) {
ffffffffc0201cc4:	1141                	addi	sp,sp,-16
        panic("pte2page called with invalid pte");
ffffffffc0201cc6:	00006617          	auipc	a2,0x6
ffffffffc0201cca:	8e260613          	addi	a2,a2,-1822 # ffffffffc02075a8 <default_pmm_manager+0x128>
ffffffffc0201cce:	07400593          	li	a1,116
ffffffffc0201cd2:	00006517          	auipc	a0,0x6
ffffffffc0201cd6:	80e50513          	addi	a0,a0,-2034 # ffffffffc02074e0 <default_pmm_manager+0x60>
pte2page(pte_t pte) {
ffffffffc0201cda:	e406                	sd	ra,8(sp)
        panic("pte2page called with invalid pte");
ffffffffc0201cdc:	f9efe0ef          	jal	ra,ffffffffc020047a <__panic>

ffffffffc0201ce0 <alloc_pages>:
    pmm_manager->init_memmap(base, n);
}

// alloc_pages - call pmm->alloc_pages to allocate a continuous n*PAGESIZE
// memory
struct Page *alloc_pages(size_t n) {
ffffffffc0201ce0:	7139                	addi	sp,sp,-64
ffffffffc0201ce2:	f426                	sd	s1,40(sp)
ffffffffc0201ce4:	f04a                	sd	s2,32(sp)
ffffffffc0201ce6:	ec4e                	sd	s3,24(sp)
ffffffffc0201ce8:	e852                	sd	s4,16(sp)
ffffffffc0201cea:	e456                	sd	s5,8(sp)
ffffffffc0201cec:	e05a                	sd	s6,0(sp)
ffffffffc0201cee:	fc06                	sd	ra,56(sp)
ffffffffc0201cf0:	f822                	sd	s0,48(sp)
ffffffffc0201cf2:	84aa                	mv	s1,a0
ffffffffc0201cf4:	000b1917          	auipc	s2,0xb1
ffffffffc0201cf8:	bc490913          	addi	s2,s2,-1084 # ffffffffc02b28b8 <pmm_manager>
        {
            page = pmm_manager->alloc_pages(n);
        }
        local_intr_restore(intr_flag);

        if (page != NULL || n > 1 || swap_init_ok == 0) break;
ffffffffc0201cfc:	4a05                	li	s4,1
ffffffffc0201cfe:	000b1a97          	auipc	s5,0xb1
ffffffffc0201d02:	bdaa8a93          	addi	s5,s5,-1062 # ffffffffc02b28d8 <swap_init_ok>

        extern struct mm_struct *check_mm_struct;
        // cprintf("page %x, call swap_out in alloc_pages %d\n",page, n);
        swap_out(check_mm_struct, n, 0);
ffffffffc0201d06:	0005099b          	sext.w	s3,a0
ffffffffc0201d0a:	000b1b17          	auipc	s6,0xb1
ffffffffc0201d0e:	bd6b0b13          	addi	s6,s6,-1066 # ffffffffc02b28e0 <check_mm_struct>
ffffffffc0201d12:	a01d                	j	ffffffffc0201d38 <alloc_pages+0x58>
            page = pmm_manager->alloc_pages(n);
ffffffffc0201d14:	00093783          	ld	a5,0(s2)
ffffffffc0201d18:	6f9c                	ld	a5,24(a5)
ffffffffc0201d1a:	9782                	jalr	a5
ffffffffc0201d1c:	842a                	mv	s0,a0
        swap_out(check_mm_struct, n, 0);
ffffffffc0201d1e:	4601                	li	a2,0
ffffffffc0201d20:	85ce                	mv	a1,s3
        if (page != NULL || n > 1 || swap_init_ok == 0) break;
ffffffffc0201d22:	ec0d                	bnez	s0,ffffffffc0201d5c <alloc_pages+0x7c>
ffffffffc0201d24:	029a6c63          	bltu	s4,s1,ffffffffc0201d5c <alloc_pages+0x7c>
ffffffffc0201d28:	000aa783          	lw	a5,0(s5)
ffffffffc0201d2c:	2781                	sext.w	a5,a5
ffffffffc0201d2e:	c79d                	beqz	a5,ffffffffc0201d5c <alloc_pages+0x7c>
        swap_out(check_mm_struct, n, 0);
ffffffffc0201d30:	000b3503          	ld	a0,0(s6)
ffffffffc0201d34:	6b9010ef          	jal	ra,ffffffffc0203bec <swap_out>
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0201d38:	100027f3          	csrr	a5,sstatus
ffffffffc0201d3c:	8b89                	andi	a5,a5,2
            page = pmm_manager->alloc_pages(n);
ffffffffc0201d3e:	8526                	mv	a0,s1
ffffffffc0201d40:	dbf1                	beqz	a5,ffffffffc0201d14 <alloc_pages+0x34>
        intr_disable();
ffffffffc0201d42:	905fe0ef          	jal	ra,ffffffffc0200646 <intr_disable>
ffffffffc0201d46:	00093783          	ld	a5,0(s2)
ffffffffc0201d4a:	8526                	mv	a0,s1
ffffffffc0201d4c:	6f9c                	ld	a5,24(a5)
ffffffffc0201d4e:	9782                	jalr	a5
ffffffffc0201d50:	842a                	mv	s0,a0
        intr_enable();
ffffffffc0201d52:	8effe0ef          	jal	ra,ffffffffc0200640 <intr_enable>
        swap_out(check_mm_struct, n, 0);
ffffffffc0201d56:	4601                	li	a2,0
ffffffffc0201d58:	85ce                	mv	a1,s3
        if (page != NULL || n > 1 || swap_init_ok == 0) break;
ffffffffc0201d5a:	d469                	beqz	s0,ffffffffc0201d24 <alloc_pages+0x44>
    }
    // cprintf("n %d,get page %x, No %d in alloc_pages\n",n,page,(page-pages));
    return page;
}
ffffffffc0201d5c:	70e2                	ld	ra,56(sp)
ffffffffc0201d5e:	8522                	mv	a0,s0
ffffffffc0201d60:	7442                	ld	s0,48(sp)
ffffffffc0201d62:	74a2                	ld	s1,40(sp)
ffffffffc0201d64:	7902                	ld	s2,32(sp)
ffffffffc0201d66:	69e2                	ld	s3,24(sp)
ffffffffc0201d68:	6a42                	ld	s4,16(sp)
ffffffffc0201d6a:	6aa2                	ld	s5,8(sp)
ffffffffc0201d6c:	6b02                	ld	s6,0(sp)
ffffffffc0201d6e:	6121                	addi	sp,sp,64
ffffffffc0201d70:	8082                	ret

ffffffffc0201d72 <free_pages>:
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0201d72:	100027f3          	csrr	a5,sstatus
ffffffffc0201d76:	8b89                	andi	a5,a5,2
ffffffffc0201d78:	e799                	bnez	a5,ffffffffc0201d86 <free_pages+0x14>
// free_pages - call pmm->free_pages to free a continuous n*PAGESIZE memory
void free_pages(struct Page *base, size_t n) {
    bool intr_flag;
    local_intr_save(intr_flag);
    {
        pmm_manager->free_pages(base, n);
ffffffffc0201d7a:	000b1797          	auipc	a5,0xb1
ffffffffc0201d7e:	b3e7b783          	ld	a5,-1218(a5) # ffffffffc02b28b8 <pmm_manager>
ffffffffc0201d82:	739c                	ld	a5,32(a5)
ffffffffc0201d84:	8782                	jr	a5
void free_pages(struct Page *base, size_t n) {
ffffffffc0201d86:	1101                	addi	sp,sp,-32
ffffffffc0201d88:	ec06                	sd	ra,24(sp)
ffffffffc0201d8a:	e822                	sd	s0,16(sp)
ffffffffc0201d8c:	e426                	sd	s1,8(sp)
ffffffffc0201d8e:	842a                	mv	s0,a0
ffffffffc0201d90:	84ae                	mv	s1,a1
        intr_disable();
ffffffffc0201d92:	8b5fe0ef          	jal	ra,ffffffffc0200646 <intr_disable>
        pmm_manager->free_pages(base, n);
ffffffffc0201d96:	000b1797          	auipc	a5,0xb1
ffffffffc0201d9a:	b227b783          	ld	a5,-1246(a5) # ffffffffc02b28b8 <pmm_manager>
ffffffffc0201d9e:	739c                	ld	a5,32(a5)
ffffffffc0201da0:	85a6                	mv	a1,s1
ffffffffc0201da2:	8522                	mv	a0,s0
ffffffffc0201da4:	9782                	jalr	a5
    }
    local_intr_restore(intr_flag);
}
ffffffffc0201da6:	6442                	ld	s0,16(sp)
ffffffffc0201da8:	60e2                	ld	ra,24(sp)
ffffffffc0201daa:	64a2                	ld	s1,8(sp)
ffffffffc0201dac:	6105                	addi	sp,sp,32
        intr_enable();
ffffffffc0201dae:	893fe06f          	j	ffffffffc0200640 <intr_enable>

ffffffffc0201db2 <nr_free_pages>:
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0201db2:	100027f3          	csrr	a5,sstatus
ffffffffc0201db6:	8b89                	andi	a5,a5,2
ffffffffc0201db8:	e799                	bnez	a5,ffffffffc0201dc6 <nr_free_pages+0x14>
size_t nr_free_pages(void) {
    size_t ret;
    bool intr_flag;
    local_intr_save(intr_flag);
    {
        ret = pmm_manager->nr_free_pages();
ffffffffc0201dba:	000b1797          	auipc	a5,0xb1
ffffffffc0201dbe:	afe7b783          	ld	a5,-1282(a5) # ffffffffc02b28b8 <pmm_manager>
ffffffffc0201dc2:	779c                	ld	a5,40(a5)
ffffffffc0201dc4:	8782                	jr	a5
size_t nr_free_pages(void) {
ffffffffc0201dc6:	1141                	addi	sp,sp,-16
ffffffffc0201dc8:	e406                	sd	ra,8(sp)
ffffffffc0201dca:	e022                	sd	s0,0(sp)
        intr_disable();
ffffffffc0201dcc:	87bfe0ef          	jal	ra,ffffffffc0200646 <intr_disable>
        ret = pmm_manager->nr_free_pages();
ffffffffc0201dd0:	000b1797          	auipc	a5,0xb1
ffffffffc0201dd4:	ae87b783          	ld	a5,-1304(a5) # ffffffffc02b28b8 <pmm_manager>
ffffffffc0201dd8:	779c                	ld	a5,40(a5)
ffffffffc0201dda:	9782                	jalr	a5
ffffffffc0201ddc:	842a                	mv	s0,a0
        intr_enable();
ffffffffc0201dde:	863fe0ef          	jal	ra,ffffffffc0200640 <intr_enable>
    }
    local_intr_restore(intr_flag);
    return ret;
}
ffffffffc0201de2:	60a2                	ld	ra,8(sp)
ffffffffc0201de4:	8522                	mv	a0,s0
ffffffffc0201de6:	6402                	ld	s0,0(sp)
ffffffffc0201de8:	0141                	addi	sp,sp,16
ffffffffc0201dea:	8082                	ret

ffffffffc0201dec <get_pte>:
//  pgdir:  the kernel virtual base address of PDT
//  la:     the linear address need to map
//  create: a logical value to decide if alloc a page for PT
// return vaule: the kernel virtual address of this pte
pte_t *get_pte(pde_t *pgdir, uintptr_t la, bool create) {
    pde_t *pdep1 = &pgdir[PDX1(la)];
ffffffffc0201dec:	01e5d793          	srli	a5,a1,0x1e
ffffffffc0201df0:	1ff7f793          	andi	a5,a5,511
pte_t *get_pte(pde_t *pgdir, uintptr_t la, bool create) {
ffffffffc0201df4:	7139                	addi	sp,sp,-64
    pde_t *pdep1 = &pgdir[PDX1(la)];
ffffffffc0201df6:	078e                	slli	a5,a5,0x3
pte_t *get_pte(pde_t *pgdir, uintptr_t la, bool create) {
ffffffffc0201df8:	f426                	sd	s1,40(sp)
    pde_t *pdep1 = &pgdir[PDX1(la)];
ffffffffc0201dfa:	00f504b3          	add	s1,a0,a5
    if (!(*pdep1 & PTE_V)) {
ffffffffc0201dfe:	6094                	ld	a3,0(s1)
pte_t *get_pte(pde_t *pgdir, uintptr_t la, bool create) {
ffffffffc0201e00:	f04a                	sd	s2,32(sp)
ffffffffc0201e02:	ec4e                	sd	s3,24(sp)
ffffffffc0201e04:	e852                	sd	s4,16(sp)
ffffffffc0201e06:	fc06                	sd	ra,56(sp)
ffffffffc0201e08:	f822                	sd	s0,48(sp)
ffffffffc0201e0a:	e456                	sd	s5,8(sp)
ffffffffc0201e0c:	e05a                	sd	s6,0(sp)
    if (!(*pdep1 & PTE_V)) {
ffffffffc0201e0e:	0016f793          	andi	a5,a3,1
pte_t *get_pte(pde_t *pgdir, uintptr_t la, bool create) {
ffffffffc0201e12:	892e                	mv	s2,a1
ffffffffc0201e14:	89b2                	mv	s3,a2
ffffffffc0201e16:	000b1a17          	auipc	s4,0xb1
ffffffffc0201e1a:	a92a0a13          	addi	s4,s4,-1390 # ffffffffc02b28a8 <npage>
    if (!(*pdep1 & PTE_V)) {
ffffffffc0201e1e:	e7b5                	bnez	a5,ffffffffc0201e8a <get_pte+0x9e>
        struct Page *page;
        if (!create || (page = alloc_page()) == NULL) {
ffffffffc0201e20:	12060b63          	beqz	a2,ffffffffc0201f56 <get_pte+0x16a>
ffffffffc0201e24:	4505                	li	a0,1
ffffffffc0201e26:	ebbff0ef          	jal	ra,ffffffffc0201ce0 <alloc_pages>
ffffffffc0201e2a:	842a                	mv	s0,a0
ffffffffc0201e2c:	12050563          	beqz	a0,ffffffffc0201f56 <get_pte+0x16a>
    return page - pages + nbase;
ffffffffc0201e30:	000b1b17          	auipc	s6,0xb1
ffffffffc0201e34:	a80b0b13          	addi	s6,s6,-1408 # ffffffffc02b28b0 <pages>
ffffffffc0201e38:	000b3503          	ld	a0,0(s6)
ffffffffc0201e3c:	00080ab7          	lui	s5,0x80
            return NULL;
        }
        set_page_ref(page, 1);
        uintptr_t pa = page2pa(page);
        memset(KADDR(pa), 0, PGSIZE);
ffffffffc0201e40:	000b1a17          	auipc	s4,0xb1
ffffffffc0201e44:	a68a0a13          	addi	s4,s4,-1432 # ffffffffc02b28a8 <npage>
ffffffffc0201e48:	40a40533          	sub	a0,s0,a0
ffffffffc0201e4c:	8519                	srai	a0,a0,0x6
ffffffffc0201e4e:	9556                	add	a0,a0,s5
ffffffffc0201e50:	000a3703          	ld	a4,0(s4)
ffffffffc0201e54:	00c51793          	slli	a5,a0,0xc
    page->ref = val;
ffffffffc0201e58:	4685                	li	a3,1
ffffffffc0201e5a:	c014                	sw	a3,0(s0)
ffffffffc0201e5c:	83b1                	srli	a5,a5,0xc
    return page2ppn(page) << PGSHIFT;
ffffffffc0201e5e:	0532                	slli	a0,a0,0xc
ffffffffc0201e60:	14e7f263          	bgeu	a5,a4,ffffffffc0201fa4 <get_pte+0x1b8>
ffffffffc0201e64:	000b1797          	auipc	a5,0xb1
ffffffffc0201e68:	a5c7b783          	ld	a5,-1444(a5) # ffffffffc02b28c0 <va_pa_offset>
ffffffffc0201e6c:	6605                	lui	a2,0x1
ffffffffc0201e6e:	4581                	li	a1,0
ffffffffc0201e70:	953e                	add	a0,a0,a5
ffffffffc0201e72:	093040ef          	jal	ra,ffffffffc0206704 <memset>
    return page - pages + nbase;
ffffffffc0201e76:	000b3683          	ld	a3,0(s6)
ffffffffc0201e7a:	40d406b3          	sub	a3,s0,a3
ffffffffc0201e7e:	8699                	srai	a3,a3,0x6
ffffffffc0201e80:	96d6                	add	a3,a3,s5
  asm volatile("sfence.vma");
}

// construct PTE from a page and permission bits
static inline pte_t pte_create(uintptr_t ppn, int type) {
  return (ppn << PTE_PPN_SHIFT) | PTE_V | type;
ffffffffc0201e82:	06aa                	slli	a3,a3,0xa
ffffffffc0201e84:	0116e693          	ori	a3,a3,17
        *pdep1 = pte_create(page2ppn(page), PTE_U | PTE_V);
ffffffffc0201e88:	e094                	sd	a3,0(s1)
    }

    pde_t *pdep0 = &((pde_t *)KADDR(PDE_ADDR(*pdep1)))[PDX0(la)];
ffffffffc0201e8a:	77fd                	lui	a5,0xfffff
ffffffffc0201e8c:	068a                	slli	a3,a3,0x2
ffffffffc0201e8e:	000a3703          	ld	a4,0(s4)
ffffffffc0201e92:	8efd                	and	a3,a3,a5
ffffffffc0201e94:	00c6d793          	srli	a5,a3,0xc
ffffffffc0201e98:	0ce7f163          	bgeu	a5,a4,ffffffffc0201f5a <get_pte+0x16e>
ffffffffc0201e9c:	000b1a97          	auipc	s5,0xb1
ffffffffc0201ea0:	a24a8a93          	addi	s5,s5,-1500 # ffffffffc02b28c0 <va_pa_offset>
ffffffffc0201ea4:	000ab403          	ld	s0,0(s5)
ffffffffc0201ea8:	01595793          	srli	a5,s2,0x15
ffffffffc0201eac:	1ff7f793          	andi	a5,a5,511
ffffffffc0201eb0:	96a2                	add	a3,a3,s0
ffffffffc0201eb2:	00379413          	slli	s0,a5,0x3
ffffffffc0201eb6:	9436                	add	s0,s0,a3
    if (!(*pdep0 & PTE_V)) {
ffffffffc0201eb8:	6014                	ld	a3,0(s0)
ffffffffc0201eba:	0016f793          	andi	a5,a3,1
ffffffffc0201ebe:	e3ad                	bnez	a5,ffffffffc0201f20 <get_pte+0x134>
        struct Page *page;
        if (!create || (page = alloc_page()) == NULL) {
ffffffffc0201ec0:	08098b63          	beqz	s3,ffffffffc0201f56 <get_pte+0x16a>
ffffffffc0201ec4:	4505                	li	a0,1
ffffffffc0201ec6:	e1bff0ef          	jal	ra,ffffffffc0201ce0 <alloc_pages>
ffffffffc0201eca:	84aa                	mv	s1,a0
ffffffffc0201ecc:	c549                	beqz	a0,ffffffffc0201f56 <get_pte+0x16a>
    return page - pages + nbase;
ffffffffc0201ece:	000b1b17          	auipc	s6,0xb1
ffffffffc0201ed2:	9e2b0b13          	addi	s6,s6,-1566 # ffffffffc02b28b0 <pages>
ffffffffc0201ed6:	000b3503          	ld	a0,0(s6)
ffffffffc0201eda:	000809b7          	lui	s3,0x80
            return NULL;
        }
        set_page_ref(page, 1);
        uintptr_t pa = page2pa(page);
        memset(KADDR(pa), 0, PGSIZE);
ffffffffc0201ede:	000a3703          	ld	a4,0(s4)
ffffffffc0201ee2:	40a48533          	sub	a0,s1,a0
ffffffffc0201ee6:	8519                	srai	a0,a0,0x6
ffffffffc0201ee8:	954e                	add	a0,a0,s3
ffffffffc0201eea:	00c51793          	slli	a5,a0,0xc
    page->ref = val;
ffffffffc0201eee:	4685                	li	a3,1
ffffffffc0201ef0:	c094                	sw	a3,0(s1)
ffffffffc0201ef2:	83b1                	srli	a5,a5,0xc
    return page2ppn(page) << PGSHIFT;
ffffffffc0201ef4:	0532                	slli	a0,a0,0xc
ffffffffc0201ef6:	08e7fa63          	bgeu	a5,a4,ffffffffc0201f8a <get_pte+0x19e>
ffffffffc0201efa:	000ab783          	ld	a5,0(s5)
ffffffffc0201efe:	6605                	lui	a2,0x1
ffffffffc0201f00:	4581                	li	a1,0
ffffffffc0201f02:	953e                	add	a0,a0,a5
ffffffffc0201f04:	001040ef          	jal	ra,ffffffffc0206704 <memset>
    return page - pages + nbase;
ffffffffc0201f08:	000b3683          	ld	a3,0(s6)
ffffffffc0201f0c:	40d486b3          	sub	a3,s1,a3
ffffffffc0201f10:	8699                	srai	a3,a3,0x6
ffffffffc0201f12:	96ce                	add	a3,a3,s3
  return (ppn << PTE_PPN_SHIFT) | PTE_V | type;
ffffffffc0201f14:	06aa                	slli	a3,a3,0xa
ffffffffc0201f16:	0116e693          	ori	a3,a3,17
        *pdep0 = pte_create(page2ppn(page), PTE_U | PTE_V);
ffffffffc0201f1a:	e014                	sd	a3,0(s0)
        }
    return &((pte_t *)KADDR(PDE_ADDR(*pdep0)))[PTX(la)];
ffffffffc0201f1c:	000a3703          	ld	a4,0(s4)
ffffffffc0201f20:	068a                	slli	a3,a3,0x2
ffffffffc0201f22:	757d                	lui	a0,0xfffff
ffffffffc0201f24:	8ee9                	and	a3,a3,a0
ffffffffc0201f26:	00c6d793          	srli	a5,a3,0xc
ffffffffc0201f2a:	04e7f463          	bgeu	a5,a4,ffffffffc0201f72 <get_pte+0x186>
ffffffffc0201f2e:	000ab503          	ld	a0,0(s5)
ffffffffc0201f32:	00c95913          	srli	s2,s2,0xc
ffffffffc0201f36:	1ff97913          	andi	s2,s2,511
ffffffffc0201f3a:	96aa                	add	a3,a3,a0
ffffffffc0201f3c:	00391513          	slli	a0,s2,0x3
ffffffffc0201f40:	9536                	add	a0,a0,a3
}
ffffffffc0201f42:	70e2                	ld	ra,56(sp)
ffffffffc0201f44:	7442                	ld	s0,48(sp)
ffffffffc0201f46:	74a2                	ld	s1,40(sp)
ffffffffc0201f48:	7902                	ld	s2,32(sp)
ffffffffc0201f4a:	69e2                	ld	s3,24(sp)
ffffffffc0201f4c:	6a42                	ld	s4,16(sp)
ffffffffc0201f4e:	6aa2                	ld	s5,8(sp)
ffffffffc0201f50:	6b02                	ld	s6,0(sp)
ffffffffc0201f52:	6121                	addi	sp,sp,64
ffffffffc0201f54:	8082                	ret
            return NULL;
ffffffffc0201f56:	4501                	li	a0,0
ffffffffc0201f58:	b7ed                	j	ffffffffc0201f42 <get_pte+0x156>
    pde_t *pdep0 = &((pde_t *)KADDR(PDE_ADDR(*pdep1)))[PDX0(la)];
ffffffffc0201f5a:	00005617          	auipc	a2,0x5
ffffffffc0201f5e:	55e60613          	addi	a2,a2,1374 # ffffffffc02074b8 <default_pmm_manager+0x38>
ffffffffc0201f62:	0e300593          	li	a1,227
ffffffffc0201f66:	00005517          	auipc	a0,0x5
ffffffffc0201f6a:	66a50513          	addi	a0,a0,1642 # ffffffffc02075d0 <default_pmm_manager+0x150>
ffffffffc0201f6e:	d0cfe0ef          	jal	ra,ffffffffc020047a <__panic>
    return &((pte_t *)KADDR(PDE_ADDR(*pdep0)))[PTX(la)];
ffffffffc0201f72:	00005617          	auipc	a2,0x5
ffffffffc0201f76:	54660613          	addi	a2,a2,1350 # ffffffffc02074b8 <default_pmm_manager+0x38>
ffffffffc0201f7a:	0ee00593          	li	a1,238
ffffffffc0201f7e:	00005517          	auipc	a0,0x5
ffffffffc0201f82:	65250513          	addi	a0,a0,1618 # ffffffffc02075d0 <default_pmm_manager+0x150>
ffffffffc0201f86:	cf4fe0ef          	jal	ra,ffffffffc020047a <__panic>
        memset(KADDR(pa), 0, PGSIZE);
ffffffffc0201f8a:	86aa                	mv	a3,a0
ffffffffc0201f8c:	00005617          	auipc	a2,0x5
ffffffffc0201f90:	52c60613          	addi	a2,a2,1324 # ffffffffc02074b8 <default_pmm_manager+0x38>
ffffffffc0201f94:	0eb00593          	li	a1,235
ffffffffc0201f98:	00005517          	auipc	a0,0x5
ffffffffc0201f9c:	63850513          	addi	a0,a0,1592 # ffffffffc02075d0 <default_pmm_manager+0x150>
ffffffffc0201fa0:	cdafe0ef          	jal	ra,ffffffffc020047a <__panic>
        memset(KADDR(pa), 0, PGSIZE);
ffffffffc0201fa4:	86aa                	mv	a3,a0
ffffffffc0201fa6:	00005617          	auipc	a2,0x5
ffffffffc0201faa:	51260613          	addi	a2,a2,1298 # ffffffffc02074b8 <default_pmm_manager+0x38>
ffffffffc0201fae:	0df00593          	li	a1,223
ffffffffc0201fb2:	00005517          	auipc	a0,0x5
ffffffffc0201fb6:	61e50513          	addi	a0,a0,1566 # ffffffffc02075d0 <default_pmm_manager+0x150>
ffffffffc0201fba:	cc0fe0ef          	jal	ra,ffffffffc020047a <__panic>

ffffffffc0201fbe <get_page>:

// get_page - get related Page struct for linear address la using PDT pgdir
struct Page *get_page(pde_t *pgdir, uintptr_t la, pte_t **ptep_store) {
ffffffffc0201fbe:	1141                	addi	sp,sp,-16
ffffffffc0201fc0:	e022                	sd	s0,0(sp)
ffffffffc0201fc2:	8432                	mv	s0,a2
    pte_t *ptep = get_pte(pgdir, la, 0);
ffffffffc0201fc4:	4601                	li	a2,0
struct Page *get_page(pde_t *pgdir, uintptr_t la, pte_t **ptep_store) {
ffffffffc0201fc6:	e406                	sd	ra,8(sp)
    pte_t *ptep = get_pte(pgdir, la, 0);
ffffffffc0201fc8:	e25ff0ef          	jal	ra,ffffffffc0201dec <get_pte>
    if (ptep_store != NULL) {
ffffffffc0201fcc:	c011                	beqz	s0,ffffffffc0201fd0 <get_page+0x12>
        *ptep_store = ptep;
ffffffffc0201fce:	e008                	sd	a0,0(s0)
    }
    if (ptep != NULL && *ptep & PTE_V) {
ffffffffc0201fd0:	c511                	beqz	a0,ffffffffc0201fdc <get_page+0x1e>
ffffffffc0201fd2:	611c                	ld	a5,0(a0)
        return pte2page(*ptep);
    }
    return NULL;
ffffffffc0201fd4:	4501                	li	a0,0
    if (ptep != NULL && *ptep & PTE_V) {
ffffffffc0201fd6:	0017f713          	andi	a4,a5,1
ffffffffc0201fda:	e709                	bnez	a4,ffffffffc0201fe4 <get_page+0x26>
}
ffffffffc0201fdc:	60a2                	ld	ra,8(sp)
ffffffffc0201fde:	6402                	ld	s0,0(sp)
ffffffffc0201fe0:	0141                	addi	sp,sp,16
ffffffffc0201fe2:	8082                	ret
    return pa2page(PTE_ADDR(pte));
ffffffffc0201fe4:	078a                	slli	a5,a5,0x2
ffffffffc0201fe6:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0201fe8:	000b1717          	auipc	a4,0xb1
ffffffffc0201fec:	8c073703          	ld	a4,-1856(a4) # ffffffffc02b28a8 <npage>
ffffffffc0201ff0:	00e7ff63          	bgeu	a5,a4,ffffffffc020200e <get_page+0x50>
ffffffffc0201ff4:	60a2                	ld	ra,8(sp)
ffffffffc0201ff6:	6402                	ld	s0,0(sp)
    return &pages[PPN(pa) - nbase];
ffffffffc0201ff8:	fff80537          	lui	a0,0xfff80
ffffffffc0201ffc:	97aa                	add	a5,a5,a0
ffffffffc0201ffe:	079a                	slli	a5,a5,0x6
ffffffffc0202000:	000b1517          	auipc	a0,0xb1
ffffffffc0202004:	8b053503          	ld	a0,-1872(a0) # ffffffffc02b28b0 <pages>
ffffffffc0202008:	953e                	add	a0,a0,a5
ffffffffc020200a:	0141                	addi	sp,sp,16
ffffffffc020200c:	8082                	ret
ffffffffc020200e:	c9bff0ef          	jal	ra,ffffffffc0201ca8 <pa2page.part.0>

ffffffffc0202012 <unmap_range>:
        *ptep = 0;                  //(5) clear second page table entry
        tlb_invalidate(pgdir, la);  //(6) flush tlb
    }
}

void unmap_range(pde_t *pgdir, uintptr_t start, uintptr_t end) {
ffffffffc0202012:	7159                	addi	sp,sp,-112
    assert(start % PGSIZE == 0 && end % PGSIZE == 0);
ffffffffc0202014:	00c5e7b3          	or	a5,a1,a2
void unmap_range(pde_t *pgdir, uintptr_t start, uintptr_t end) {
ffffffffc0202018:	f486                	sd	ra,104(sp)
ffffffffc020201a:	f0a2                	sd	s0,96(sp)
ffffffffc020201c:	eca6                	sd	s1,88(sp)
ffffffffc020201e:	e8ca                	sd	s2,80(sp)
ffffffffc0202020:	e4ce                	sd	s3,72(sp)
ffffffffc0202022:	e0d2                	sd	s4,64(sp)
ffffffffc0202024:	fc56                	sd	s5,56(sp)
ffffffffc0202026:	f85a                	sd	s6,48(sp)
ffffffffc0202028:	f45e                	sd	s7,40(sp)
ffffffffc020202a:	f062                	sd	s8,32(sp)
ffffffffc020202c:	ec66                	sd	s9,24(sp)
ffffffffc020202e:	e86a                	sd	s10,16(sp)
    assert(start % PGSIZE == 0 && end % PGSIZE == 0);
ffffffffc0202030:	17d2                	slli	a5,a5,0x34
ffffffffc0202032:	e3ed                	bnez	a5,ffffffffc0202114 <unmap_range+0x102>
    assert(USER_ACCESS(start, end));
ffffffffc0202034:	002007b7          	lui	a5,0x200
ffffffffc0202038:	842e                	mv	s0,a1
ffffffffc020203a:	0ef5ed63          	bltu	a1,a5,ffffffffc0202134 <unmap_range+0x122>
ffffffffc020203e:	8932                	mv	s2,a2
ffffffffc0202040:	0ec5fa63          	bgeu	a1,a2,ffffffffc0202134 <unmap_range+0x122>
ffffffffc0202044:	4785                	li	a5,1
ffffffffc0202046:	07fe                	slli	a5,a5,0x1f
ffffffffc0202048:	0ec7e663          	bltu	a5,a2,ffffffffc0202134 <unmap_range+0x122>
ffffffffc020204c:	89aa                	mv	s3,a0
            continue;
        }
        if (*ptep != 0) {
            page_remove_pte(pgdir, start, ptep);
        }
        start += PGSIZE;
ffffffffc020204e:	6a05                	lui	s4,0x1
    if (PPN(pa) >= npage) {
ffffffffc0202050:	000b1c97          	auipc	s9,0xb1
ffffffffc0202054:	858c8c93          	addi	s9,s9,-1960 # ffffffffc02b28a8 <npage>
    return &pages[PPN(pa) - nbase];
ffffffffc0202058:	000b1c17          	auipc	s8,0xb1
ffffffffc020205c:	858c0c13          	addi	s8,s8,-1960 # ffffffffc02b28b0 <pages>
ffffffffc0202060:	fff80bb7          	lui	s7,0xfff80
        pmm_manager->free_pages(base, n);
ffffffffc0202064:	000b1d17          	auipc	s10,0xb1
ffffffffc0202068:	854d0d13          	addi	s10,s10,-1964 # ffffffffc02b28b8 <pmm_manager>
            start = ROUNDDOWN(start + PTSIZE, PTSIZE);
ffffffffc020206c:	00200b37          	lui	s6,0x200
ffffffffc0202070:	ffe00ab7          	lui	s5,0xffe00
        pte_t *ptep = get_pte(pgdir, start, 0);
ffffffffc0202074:	4601                	li	a2,0
ffffffffc0202076:	85a2                	mv	a1,s0
ffffffffc0202078:	854e                	mv	a0,s3
ffffffffc020207a:	d73ff0ef          	jal	ra,ffffffffc0201dec <get_pte>
ffffffffc020207e:	84aa                	mv	s1,a0
        if (ptep == NULL) {
ffffffffc0202080:	cd29                	beqz	a0,ffffffffc02020da <unmap_range+0xc8>
        if (*ptep != 0) {
ffffffffc0202082:	611c                	ld	a5,0(a0)
ffffffffc0202084:	e395                	bnez	a5,ffffffffc02020a8 <unmap_range+0x96>
        start += PGSIZE;
ffffffffc0202086:	9452                	add	s0,s0,s4
    } while (start != 0 && start < end);
ffffffffc0202088:	ff2466e3          	bltu	s0,s2,ffffffffc0202074 <unmap_range+0x62>
}
ffffffffc020208c:	70a6                	ld	ra,104(sp)
ffffffffc020208e:	7406                	ld	s0,96(sp)
ffffffffc0202090:	64e6                	ld	s1,88(sp)
ffffffffc0202092:	6946                	ld	s2,80(sp)
ffffffffc0202094:	69a6                	ld	s3,72(sp)
ffffffffc0202096:	6a06                	ld	s4,64(sp)
ffffffffc0202098:	7ae2                	ld	s5,56(sp)
ffffffffc020209a:	7b42                	ld	s6,48(sp)
ffffffffc020209c:	7ba2                	ld	s7,40(sp)
ffffffffc020209e:	7c02                	ld	s8,32(sp)
ffffffffc02020a0:	6ce2                	ld	s9,24(sp)
ffffffffc02020a2:	6d42                	ld	s10,16(sp)
ffffffffc02020a4:	6165                	addi	sp,sp,112
ffffffffc02020a6:	8082                	ret
    if (*ptep & PTE_V) {  //(1) check if this page table entry is
ffffffffc02020a8:	0017f713          	andi	a4,a5,1
ffffffffc02020ac:	df69                	beqz	a4,ffffffffc0202086 <unmap_range+0x74>
    if (PPN(pa) >= npage) {
ffffffffc02020ae:	000cb703          	ld	a4,0(s9)
    return pa2page(PTE_ADDR(pte));
ffffffffc02020b2:	078a                	slli	a5,a5,0x2
ffffffffc02020b4:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc02020b6:	08e7ff63          	bgeu	a5,a4,ffffffffc0202154 <unmap_range+0x142>
    return &pages[PPN(pa) - nbase];
ffffffffc02020ba:	000c3503          	ld	a0,0(s8)
ffffffffc02020be:	97de                	add	a5,a5,s7
ffffffffc02020c0:	079a                	slli	a5,a5,0x6
ffffffffc02020c2:	953e                	add	a0,a0,a5
    page->ref -= 1;
ffffffffc02020c4:	411c                	lw	a5,0(a0)
ffffffffc02020c6:	fff7871b          	addiw	a4,a5,-1
ffffffffc02020ca:	c118                	sw	a4,0(a0)
        if (page_ref(page) ==
ffffffffc02020cc:	cf11                	beqz	a4,ffffffffc02020e8 <unmap_range+0xd6>
        *ptep = 0;                  //(5) clear second page table entry
ffffffffc02020ce:	0004b023          	sd	zero,0(s1)
}

// invalidate a TLB entry, but only if the page tables being
// edited are the ones currently in use by the processor.
void tlb_invalidate(pde_t *pgdir, uintptr_t la) {
    asm volatile("sfence.vma %0" : : "r"(la));
ffffffffc02020d2:	12040073          	sfence.vma	s0
        start += PGSIZE;
ffffffffc02020d6:	9452                	add	s0,s0,s4
    } while (start != 0 && start < end);
ffffffffc02020d8:	bf45                	j	ffffffffc0202088 <unmap_range+0x76>
            start = ROUNDDOWN(start + PTSIZE, PTSIZE);
ffffffffc02020da:	945a                	add	s0,s0,s6
ffffffffc02020dc:	01547433          	and	s0,s0,s5
    } while (start != 0 && start < end);
ffffffffc02020e0:	d455                	beqz	s0,ffffffffc020208c <unmap_range+0x7a>
ffffffffc02020e2:	f92469e3          	bltu	s0,s2,ffffffffc0202074 <unmap_range+0x62>
ffffffffc02020e6:	b75d                	j	ffffffffc020208c <unmap_range+0x7a>
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc02020e8:	100027f3          	csrr	a5,sstatus
ffffffffc02020ec:	8b89                	andi	a5,a5,2
ffffffffc02020ee:	e799                	bnez	a5,ffffffffc02020fc <unmap_range+0xea>
        pmm_manager->free_pages(base, n);
ffffffffc02020f0:	000d3783          	ld	a5,0(s10)
ffffffffc02020f4:	4585                	li	a1,1
ffffffffc02020f6:	739c                	ld	a5,32(a5)
ffffffffc02020f8:	9782                	jalr	a5
    if (flag) {
ffffffffc02020fa:	bfd1                	j	ffffffffc02020ce <unmap_range+0xbc>
ffffffffc02020fc:	e42a                	sd	a0,8(sp)
        intr_disable();
ffffffffc02020fe:	d48fe0ef          	jal	ra,ffffffffc0200646 <intr_disable>
ffffffffc0202102:	000d3783          	ld	a5,0(s10)
ffffffffc0202106:	6522                	ld	a0,8(sp)
ffffffffc0202108:	4585                	li	a1,1
ffffffffc020210a:	739c                	ld	a5,32(a5)
ffffffffc020210c:	9782                	jalr	a5
        intr_enable();
ffffffffc020210e:	d32fe0ef          	jal	ra,ffffffffc0200640 <intr_enable>
ffffffffc0202112:	bf75                	j	ffffffffc02020ce <unmap_range+0xbc>
    assert(start % PGSIZE == 0 && end % PGSIZE == 0);
ffffffffc0202114:	00005697          	auipc	a3,0x5
ffffffffc0202118:	4cc68693          	addi	a3,a3,1228 # ffffffffc02075e0 <default_pmm_manager+0x160>
ffffffffc020211c:	00005617          	auipc	a2,0x5
ffffffffc0202120:	ccc60613          	addi	a2,a2,-820 # ffffffffc0206de8 <commands+0x450>
ffffffffc0202124:	10f00593          	li	a1,271
ffffffffc0202128:	00005517          	auipc	a0,0x5
ffffffffc020212c:	4a850513          	addi	a0,a0,1192 # ffffffffc02075d0 <default_pmm_manager+0x150>
ffffffffc0202130:	b4afe0ef          	jal	ra,ffffffffc020047a <__panic>
    assert(USER_ACCESS(start, end));
ffffffffc0202134:	00005697          	auipc	a3,0x5
ffffffffc0202138:	4dc68693          	addi	a3,a3,1244 # ffffffffc0207610 <default_pmm_manager+0x190>
ffffffffc020213c:	00005617          	auipc	a2,0x5
ffffffffc0202140:	cac60613          	addi	a2,a2,-852 # ffffffffc0206de8 <commands+0x450>
ffffffffc0202144:	11000593          	li	a1,272
ffffffffc0202148:	00005517          	auipc	a0,0x5
ffffffffc020214c:	48850513          	addi	a0,a0,1160 # ffffffffc02075d0 <default_pmm_manager+0x150>
ffffffffc0202150:	b2afe0ef          	jal	ra,ffffffffc020047a <__panic>
ffffffffc0202154:	b55ff0ef          	jal	ra,ffffffffc0201ca8 <pa2page.part.0>

ffffffffc0202158 <exit_range>:
void exit_range(pde_t *pgdir, uintptr_t start, uintptr_t end) {
ffffffffc0202158:	7119                	addi	sp,sp,-128
    assert(start % PGSIZE == 0 && end % PGSIZE == 0);
ffffffffc020215a:	00c5e7b3          	or	a5,a1,a2
void exit_range(pde_t *pgdir, uintptr_t start, uintptr_t end) {
ffffffffc020215e:	fc86                	sd	ra,120(sp)
ffffffffc0202160:	f8a2                	sd	s0,112(sp)
ffffffffc0202162:	f4a6                	sd	s1,104(sp)
ffffffffc0202164:	f0ca                	sd	s2,96(sp)
ffffffffc0202166:	ecce                	sd	s3,88(sp)
ffffffffc0202168:	e8d2                	sd	s4,80(sp)
ffffffffc020216a:	e4d6                	sd	s5,72(sp)
ffffffffc020216c:	e0da                	sd	s6,64(sp)
ffffffffc020216e:	fc5e                	sd	s7,56(sp)
ffffffffc0202170:	f862                	sd	s8,48(sp)
ffffffffc0202172:	f466                	sd	s9,40(sp)
ffffffffc0202174:	f06a                	sd	s10,32(sp)
ffffffffc0202176:	ec6e                	sd	s11,24(sp)
    assert(start % PGSIZE == 0 && end % PGSIZE == 0);
ffffffffc0202178:	17d2                	slli	a5,a5,0x34
ffffffffc020217a:	20079a63          	bnez	a5,ffffffffc020238e <exit_range+0x236>
    assert(USER_ACCESS(start, end));
ffffffffc020217e:	002007b7          	lui	a5,0x200
ffffffffc0202182:	24f5e463          	bltu	a1,a5,ffffffffc02023ca <exit_range+0x272>
ffffffffc0202186:	8ab2                	mv	s5,a2
ffffffffc0202188:	24c5f163          	bgeu	a1,a2,ffffffffc02023ca <exit_range+0x272>
ffffffffc020218c:	4785                	li	a5,1
ffffffffc020218e:	07fe                	slli	a5,a5,0x1f
ffffffffc0202190:	22c7ed63          	bltu	a5,a2,ffffffffc02023ca <exit_range+0x272>
    d1start = ROUNDDOWN(start, PDSIZE);
ffffffffc0202194:	c00009b7          	lui	s3,0xc0000
ffffffffc0202198:	0135f9b3          	and	s3,a1,s3
    d0start = ROUNDDOWN(start, PTSIZE);
ffffffffc020219c:	ffe00937          	lui	s2,0xffe00
ffffffffc02021a0:	400007b7          	lui	a5,0x40000
    return KADDR(page2pa(page));
ffffffffc02021a4:	5cfd                	li	s9,-1
ffffffffc02021a6:	8c2a                	mv	s8,a0
ffffffffc02021a8:	0125f933          	and	s2,a1,s2
ffffffffc02021ac:	99be                	add	s3,s3,a5
    if (PPN(pa) >= npage) {
ffffffffc02021ae:	000b0d17          	auipc	s10,0xb0
ffffffffc02021b2:	6fad0d13          	addi	s10,s10,1786 # ffffffffc02b28a8 <npage>
    return KADDR(page2pa(page));
ffffffffc02021b6:	00ccdc93          	srli	s9,s9,0xc
    return &pages[PPN(pa) - nbase];
ffffffffc02021ba:	000b0717          	auipc	a4,0xb0
ffffffffc02021be:	6f670713          	addi	a4,a4,1782 # ffffffffc02b28b0 <pages>
        pmm_manager->free_pages(base, n);
ffffffffc02021c2:	000b0d97          	auipc	s11,0xb0
ffffffffc02021c6:	6f6d8d93          	addi	s11,s11,1782 # ffffffffc02b28b8 <pmm_manager>
        pde1 = pgdir[PDX1(d1start)];
ffffffffc02021ca:	c0000437          	lui	s0,0xc0000
ffffffffc02021ce:	944e                	add	s0,s0,s3
ffffffffc02021d0:	8079                	srli	s0,s0,0x1e
ffffffffc02021d2:	1ff47413          	andi	s0,s0,511
ffffffffc02021d6:	040e                	slli	s0,s0,0x3
ffffffffc02021d8:	9462                	add	s0,s0,s8
ffffffffc02021da:	00043a03          	ld	s4,0(s0) # ffffffffc0000000 <_binary_obj___user_exit_out_size+0xffffffffbfff4ed0>
        if (pde1&PTE_V){
ffffffffc02021de:	001a7793          	andi	a5,s4,1
ffffffffc02021e2:	eb99                	bnez	a5,ffffffffc02021f8 <exit_range+0xa0>
    } while (d1start != 0 && d1start < end);
ffffffffc02021e4:	12098463          	beqz	s3,ffffffffc020230c <exit_range+0x1b4>
ffffffffc02021e8:	400007b7          	lui	a5,0x40000
ffffffffc02021ec:	97ce                	add	a5,a5,s3
ffffffffc02021ee:	894e                	mv	s2,s3
ffffffffc02021f0:	1159fe63          	bgeu	s3,s5,ffffffffc020230c <exit_range+0x1b4>
ffffffffc02021f4:	89be                	mv	s3,a5
ffffffffc02021f6:	bfd1                	j	ffffffffc02021ca <exit_range+0x72>
    if (PPN(pa) >= npage) {
ffffffffc02021f8:	000d3783          	ld	a5,0(s10)
    return pa2page(PDE_ADDR(pde));
ffffffffc02021fc:	0a0a                	slli	s4,s4,0x2
ffffffffc02021fe:	00ca5a13          	srli	s4,s4,0xc
    if (PPN(pa) >= npage) {
ffffffffc0202202:	1cfa7263          	bgeu	s4,a5,ffffffffc02023c6 <exit_range+0x26e>
    return &pages[PPN(pa) - nbase];
ffffffffc0202206:	fff80637          	lui	a2,0xfff80
ffffffffc020220a:	9652                	add	a2,a2,s4
    return page - pages + nbase;
ffffffffc020220c:	000806b7          	lui	a3,0x80
ffffffffc0202210:	96b2                	add	a3,a3,a2
    return KADDR(page2pa(page));
ffffffffc0202212:	0196f5b3          	and	a1,a3,s9
    return &pages[PPN(pa) - nbase];
ffffffffc0202216:	061a                	slli	a2,a2,0x6
    return page2ppn(page) << PGSHIFT;
ffffffffc0202218:	06b2                	slli	a3,a3,0xc
    return KADDR(page2pa(page));
ffffffffc020221a:	18f5fa63          	bgeu	a1,a5,ffffffffc02023ae <exit_range+0x256>
ffffffffc020221e:	000b0817          	auipc	a6,0xb0
ffffffffc0202222:	6a280813          	addi	a6,a6,1698 # ffffffffc02b28c0 <va_pa_offset>
ffffffffc0202226:	00083b03          	ld	s6,0(a6)
            free_pd0 = 1;
ffffffffc020222a:	4b85                	li	s7,1
    return &pages[PPN(pa) - nbase];
ffffffffc020222c:	fff80e37          	lui	t3,0xfff80
    return KADDR(page2pa(page));
ffffffffc0202230:	9b36                	add	s6,s6,a3
    return page - pages + nbase;
ffffffffc0202232:	00080337          	lui	t1,0x80
ffffffffc0202236:	6885                	lui	a7,0x1
ffffffffc0202238:	a819                	j	ffffffffc020224e <exit_range+0xf6>
                    free_pd0 = 0;
ffffffffc020223a:	4b81                	li	s7,0
                d0start += PTSIZE;
ffffffffc020223c:	002007b7          	lui	a5,0x200
ffffffffc0202240:	993e                	add	s2,s2,a5
            } while (d0start != 0 && d0start < d1start+PDSIZE && d0start < end);
ffffffffc0202242:	08090c63          	beqz	s2,ffffffffc02022da <exit_range+0x182>
ffffffffc0202246:	09397a63          	bgeu	s2,s3,ffffffffc02022da <exit_range+0x182>
ffffffffc020224a:	0f597063          	bgeu	s2,s5,ffffffffc020232a <exit_range+0x1d2>
                pde0 = pd0[PDX0(d0start)];
ffffffffc020224e:	01595493          	srli	s1,s2,0x15
ffffffffc0202252:	1ff4f493          	andi	s1,s1,511
ffffffffc0202256:	048e                	slli	s1,s1,0x3
ffffffffc0202258:	94da                	add	s1,s1,s6
ffffffffc020225a:	609c                	ld	a5,0(s1)
                if (pde0&PTE_V) {
ffffffffc020225c:	0017f693          	andi	a3,a5,1
ffffffffc0202260:	dee9                	beqz	a3,ffffffffc020223a <exit_range+0xe2>
    if (PPN(pa) >= npage) {
ffffffffc0202262:	000d3583          	ld	a1,0(s10)
    return pa2page(PDE_ADDR(pde));
ffffffffc0202266:	078a                	slli	a5,a5,0x2
ffffffffc0202268:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc020226a:	14b7fe63          	bgeu	a5,a1,ffffffffc02023c6 <exit_range+0x26e>
    return &pages[PPN(pa) - nbase];
ffffffffc020226e:	97f2                	add	a5,a5,t3
    return page - pages + nbase;
ffffffffc0202270:	006786b3          	add	a3,a5,t1
    return KADDR(page2pa(page));
ffffffffc0202274:	0196feb3          	and	t4,a3,s9
    return &pages[PPN(pa) - nbase];
ffffffffc0202278:	00679513          	slli	a0,a5,0x6
    return page2ppn(page) << PGSHIFT;
ffffffffc020227c:	06b2                	slli	a3,a3,0xc
    return KADDR(page2pa(page));
ffffffffc020227e:	12bef863          	bgeu	t4,a1,ffffffffc02023ae <exit_range+0x256>
ffffffffc0202282:	00083783          	ld	a5,0(a6)
ffffffffc0202286:	96be                	add	a3,a3,a5
                    for (int i = 0;i <NPTEENTRY;i++)
ffffffffc0202288:	011685b3          	add	a1,a3,a7
                        if (pt[i]&PTE_V){
ffffffffc020228c:	629c                	ld	a5,0(a3)
ffffffffc020228e:	8b85                	andi	a5,a5,1
ffffffffc0202290:	f7d5                	bnez	a5,ffffffffc020223c <exit_range+0xe4>
                    for (int i = 0;i <NPTEENTRY;i++)
ffffffffc0202292:	06a1                	addi	a3,a3,8
ffffffffc0202294:	fed59ce3          	bne	a1,a3,ffffffffc020228c <exit_range+0x134>
    return &pages[PPN(pa) - nbase];
ffffffffc0202298:	631c                	ld	a5,0(a4)
ffffffffc020229a:	953e                	add	a0,a0,a5
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc020229c:	100027f3          	csrr	a5,sstatus
ffffffffc02022a0:	8b89                	andi	a5,a5,2
ffffffffc02022a2:	e7d9                	bnez	a5,ffffffffc0202330 <exit_range+0x1d8>
        pmm_manager->free_pages(base, n);
ffffffffc02022a4:	000db783          	ld	a5,0(s11)
ffffffffc02022a8:	4585                	li	a1,1
ffffffffc02022aa:	e032                	sd	a2,0(sp)
ffffffffc02022ac:	739c                	ld	a5,32(a5)
ffffffffc02022ae:	9782                	jalr	a5
    if (flag) {
ffffffffc02022b0:	6602                	ld	a2,0(sp)
ffffffffc02022b2:	000b0817          	auipc	a6,0xb0
ffffffffc02022b6:	60e80813          	addi	a6,a6,1550 # ffffffffc02b28c0 <va_pa_offset>
ffffffffc02022ba:	fff80e37          	lui	t3,0xfff80
ffffffffc02022be:	00080337          	lui	t1,0x80
ffffffffc02022c2:	6885                	lui	a7,0x1
ffffffffc02022c4:	000b0717          	auipc	a4,0xb0
ffffffffc02022c8:	5ec70713          	addi	a4,a4,1516 # ffffffffc02b28b0 <pages>
                        pd0[PDX0(d0start)] = 0;
ffffffffc02022cc:	0004b023          	sd	zero,0(s1)
                d0start += PTSIZE;
ffffffffc02022d0:	002007b7          	lui	a5,0x200
ffffffffc02022d4:	993e                	add	s2,s2,a5
            } while (d0start != 0 && d0start < d1start+PDSIZE && d0start < end);
ffffffffc02022d6:	f60918e3          	bnez	s2,ffffffffc0202246 <exit_range+0xee>
            if (free_pd0) {
ffffffffc02022da:	f00b85e3          	beqz	s7,ffffffffc02021e4 <exit_range+0x8c>
    if (PPN(pa) >= npage) {
ffffffffc02022de:	000d3783          	ld	a5,0(s10)
ffffffffc02022e2:	0efa7263          	bgeu	s4,a5,ffffffffc02023c6 <exit_range+0x26e>
    return &pages[PPN(pa) - nbase];
ffffffffc02022e6:	6308                	ld	a0,0(a4)
ffffffffc02022e8:	9532                	add	a0,a0,a2
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc02022ea:	100027f3          	csrr	a5,sstatus
ffffffffc02022ee:	8b89                	andi	a5,a5,2
ffffffffc02022f0:	efad                	bnez	a5,ffffffffc020236a <exit_range+0x212>
        pmm_manager->free_pages(base, n);
ffffffffc02022f2:	000db783          	ld	a5,0(s11)
ffffffffc02022f6:	4585                	li	a1,1
ffffffffc02022f8:	739c                	ld	a5,32(a5)
ffffffffc02022fa:	9782                	jalr	a5
ffffffffc02022fc:	000b0717          	auipc	a4,0xb0
ffffffffc0202300:	5b470713          	addi	a4,a4,1460 # ffffffffc02b28b0 <pages>
                pgdir[PDX1(d1start)] = 0;
ffffffffc0202304:	00043023          	sd	zero,0(s0)
    } while (d1start != 0 && d1start < end);
ffffffffc0202308:	ee0990e3          	bnez	s3,ffffffffc02021e8 <exit_range+0x90>
}
ffffffffc020230c:	70e6                	ld	ra,120(sp)
ffffffffc020230e:	7446                	ld	s0,112(sp)
ffffffffc0202310:	74a6                	ld	s1,104(sp)
ffffffffc0202312:	7906                	ld	s2,96(sp)
ffffffffc0202314:	69e6                	ld	s3,88(sp)
ffffffffc0202316:	6a46                	ld	s4,80(sp)
ffffffffc0202318:	6aa6                	ld	s5,72(sp)
ffffffffc020231a:	6b06                	ld	s6,64(sp)
ffffffffc020231c:	7be2                	ld	s7,56(sp)
ffffffffc020231e:	7c42                	ld	s8,48(sp)
ffffffffc0202320:	7ca2                	ld	s9,40(sp)
ffffffffc0202322:	7d02                	ld	s10,32(sp)
ffffffffc0202324:	6de2                	ld	s11,24(sp)
ffffffffc0202326:	6109                	addi	sp,sp,128
ffffffffc0202328:	8082                	ret
            if (free_pd0) {
ffffffffc020232a:	ea0b8fe3          	beqz	s7,ffffffffc02021e8 <exit_range+0x90>
ffffffffc020232e:	bf45                	j	ffffffffc02022de <exit_range+0x186>
ffffffffc0202330:	e032                	sd	a2,0(sp)
        intr_disable();
ffffffffc0202332:	e42a                	sd	a0,8(sp)
ffffffffc0202334:	b12fe0ef          	jal	ra,ffffffffc0200646 <intr_disable>
        pmm_manager->free_pages(base, n);
ffffffffc0202338:	000db783          	ld	a5,0(s11)
ffffffffc020233c:	6522                	ld	a0,8(sp)
ffffffffc020233e:	4585                	li	a1,1
ffffffffc0202340:	739c                	ld	a5,32(a5)
ffffffffc0202342:	9782                	jalr	a5
        intr_enable();
ffffffffc0202344:	afcfe0ef          	jal	ra,ffffffffc0200640 <intr_enable>
ffffffffc0202348:	6602                	ld	a2,0(sp)
ffffffffc020234a:	000b0717          	auipc	a4,0xb0
ffffffffc020234e:	56670713          	addi	a4,a4,1382 # ffffffffc02b28b0 <pages>
ffffffffc0202352:	6885                	lui	a7,0x1
ffffffffc0202354:	00080337          	lui	t1,0x80
ffffffffc0202358:	fff80e37          	lui	t3,0xfff80
ffffffffc020235c:	000b0817          	auipc	a6,0xb0
ffffffffc0202360:	56480813          	addi	a6,a6,1380 # ffffffffc02b28c0 <va_pa_offset>
                        pd0[PDX0(d0start)] = 0;
ffffffffc0202364:	0004b023          	sd	zero,0(s1)
ffffffffc0202368:	b7a5                	j	ffffffffc02022d0 <exit_range+0x178>
ffffffffc020236a:	e02a                	sd	a0,0(sp)
        intr_disable();
ffffffffc020236c:	adafe0ef          	jal	ra,ffffffffc0200646 <intr_disable>
        pmm_manager->free_pages(base, n);
ffffffffc0202370:	000db783          	ld	a5,0(s11)
ffffffffc0202374:	6502                	ld	a0,0(sp)
ffffffffc0202376:	4585                	li	a1,1
ffffffffc0202378:	739c                	ld	a5,32(a5)
ffffffffc020237a:	9782                	jalr	a5
        intr_enable();
ffffffffc020237c:	ac4fe0ef          	jal	ra,ffffffffc0200640 <intr_enable>
ffffffffc0202380:	000b0717          	auipc	a4,0xb0
ffffffffc0202384:	53070713          	addi	a4,a4,1328 # ffffffffc02b28b0 <pages>
                pgdir[PDX1(d1start)] = 0;
ffffffffc0202388:	00043023          	sd	zero,0(s0)
ffffffffc020238c:	bfb5                	j	ffffffffc0202308 <exit_range+0x1b0>
    assert(start % PGSIZE == 0 && end % PGSIZE == 0);
ffffffffc020238e:	00005697          	auipc	a3,0x5
ffffffffc0202392:	25268693          	addi	a3,a3,594 # ffffffffc02075e0 <default_pmm_manager+0x160>
ffffffffc0202396:	00005617          	auipc	a2,0x5
ffffffffc020239a:	a5260613          	addi	a2,a2,-1454 # ffffffffc0206de8 <commands+0x450>
ffffffffc020239e:	12000593          	li	a1,288
ffffffffc02023a2:	00005517          	auipc	a0,0x5
ffffffffc02023a6:	22e50513          	addi	a0,a0,558 # ffffffffc02075d0 <default_pmm_manager+0x150>
ffffffffc02023aa:	8d0fe0ef          	jal	ra,ffffffffc020047a <__panic>
    return KADDR(page2pa(page));
ffffffffc02023ae:	00005617          	auipc	a2,0x5
ffffffffc02023b2:	10a60613          	addi	a2,a2,266 # ffffffffc02074b8 <default_pmm_manager+0x38>
ffffffffc02023b6:	06900593          	li	a1,105
ffffffffc02023ba:	00005517          	auipc	a0,0x5
ffffffffc02023be:	12650513          	addi	a0,a0,294 # ffffffffc02074e0 <default_pmm_manager+0x60>
ffffffffc02023c2:	8b8fe0ef          	jal	ra,ffffffffc020047a <__panic>
ffffffffc02023c6:	8e3ff0ef          	jal	ra,ffffffffc0201ca8 <pa2page.part.0>
    assert(USER_ACCESS(start, end));
ffffffffc02023ca:	00005697          	auipc	a3,0x5
ffffffffc02023ce:	24668693          	addi	a3,a3,582 # ffffffffc0207610 <default_pmm_manager+0x190>
ffffffffc02023d2:	00005617          	auipc	a2,0x5
ffffffffc02023d6:	a1660613          	addi	a2,a2,-1514 # ffffffffc0206de8 <commands+0x450>
ffffffffc02023da:	12100593          	li	a1,289
ffffffffc02023de:	00005517          	auipc	a0,0x5
ffffffffc02023e2:	1f250513          	addi	a0,a0,498 # ffffffffc02075d0 <default_pmm_manager+0x150>
ffffffffc02023e6:	894fe0ef          	jal	ra,ffffffffc020047a <__panic>

ffffffffc02023ea <page_remove>:
void page_remove(pde_t *pgdir, uintptr_t la) {
ffffffffc02023ea:	7179                	addi	sp,sp,-48
    pte_t *ptep = get_pte(pgdir, la, 0);
ffffffffc02023ec:	4601                	li	a2,0
void page_remove(pde_t *pgdir, uintptr_t la) {
ffffffffc02023ee:	ec26                	sd	s1,24(sp)
ffffffffc02023f0:	f406                	sd	ra,40(sp)
ffffffffc02023f2:	f022                	sd	s0,32(sp)
ffffffffc02023f4:	84ae                	mv	s1,a1
    pte_t *ptep = get_pte(pgdir, la, 0);
ffffffffc02023f6:	9f7ff0ef          	jal	ra,ffffffffc0201dec <get_pte>
    if (ptep != NULL) {
ffffffffc02023fa:	c511                	beqz	a0,ffffffffc0202406 <page_remove+0x1c>
    if (*ptep & PTE_V) {  //(1) check if this page table entry is
ffffffffc02023fc:	611c                	ld	a5,0(a0)
ffffffffc02023fe:	842a                	mv	s0,a0
ffffffffc0202400:	0017f713          	andi	a4,a5,1
ffffffffc0202404:	e711                	bnez	a4,ffffffffc0202410 <page_remove+0x26>
}
ffffffffc0202406:	70a2                	ld	ra,40(sp)
ffffffffc0202408:	7402                	ld	s0,32(sp)
ffffffffc020240a:	64e2                	ld	s1,24(sp)
ffffffffc020240c:	6145                	addi	sp,sp,48
ffffffffc020240e:	8082                	ret
    return pa2page(PTE_ADDR(pte));
ffffffffc0202410:	078a                	slli	a5,a5,0x2
ffffffffc0202412:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0202414:	000b0717          	auipc	a4,0xb0
ffffffffc0202418:	49473703          	ld	a4,1172(a4) # ffffffffc02b28a8 <npage>
ffffffffc020241c:	06e7f363          	bgeu	a5,a4,ffffffffc0202482 <page_remove+0x98>
    return &pages[PPN(pa) - nbase];
ffffffffc0202420:	fff80537          	lui	a0,0xfff80
ffffffffc0202424:	97aa                	add	a5,a5,a0
ffffffffc0202426:	079a                	slli	a5,a5,0x6
ffffffffc0202428:	000b0517          	auipc	a0,0xb0
ffffffffc020242c:	48853503          	ld	a0,1160(a0) # ffffffffc02b28b0 <pages>
ffffffffc0202430:	953e                	add	a0,a0,a5
    page->ref -= 1;
ffffffffc0202432:	411c                	lw	a5,0(a0)
ffffffffc0202434:	fff7871b          	addiw	a4,a5,-1
ffffffffc0202438:	c118                	sw	a4,0(a0)
        if (page_ref(page) ==
ffffffffc020243a:	cb11                	beqz	a4,ffffffffc020244e <page_remove+0x64>
        *ptep = 0;                  //(5) clear second page table entry
ffffffffc020243c:	00043023          	sd	zero,0(s0)
    asm volatile("sfence.vma %0" : : "r"(la));
ffffffffc0202440:	12048073          	sfence.vma	s1
}
ffffffffc0202444:	70a2                	ld	ra,40(sp)
ffffffffc0202446:	7402                	ld	s0,32(sp)
ffffffffc0202448:	64e2                	ld	s1,24(sp)
ffffffffc020244a:	6145                	addi	sp,sp,48
ffffffffc020244c:	8082                	ret
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc020244e:	100027f3          	csrr	a5,sstatus
ffffffffc0202452:	8b89                	andi	a5,a5,2
ffffffffc0202454:	eb89                	bnez	a5,ffffffffc0202466 <page_remove+0x7c>
        pmm_manager->free_pages(base, n);
ffffffffc0202456:	000b0797          	auipc	a5,0xb0
ffffffffc020245a:	4627b783          	ld	a5,1122(a5) # ffffffffc02b28b8 <pmm_manager>
ffffffffc020245e:	739c                	ld	a5,32(a5)
ffffffffc0202460:	4585                	li	a1,1
ffffffffc0202462:	9782                	jalr	a5
    if (flag) {
ffffffffc0202464:	bfe1                	j	ffffffffc020243c <page_remove+0x52>
        intr_disable();
ffffffffc0202466:	e42a                	sd	a0,8(sp)
ffffffffc0202468:	9defe0ef          	jal	ra,ffffffffc0200646 <intr_disable>
ffffffffc020246c:	000b0797          	auipc	a5,0xb0
ffffffffc0202470:	44c7b783          	ld	a5,1100(a5) # ffffffffc02b28b8 <pmm_manager>
ffffffffc0202474:	739c                	ld	a5,32(a5)
ffffffffc0202476:	6522                	ld	a0,8(sp)
ffffffffc0202478:	4585                	li	a1,1
ffffffffc020247a:	9782                	jalr	a5
        intr_enable();
ffffffffc020247c:	9c4fe0ef          	jal	ra,ffffffffc0200640 <intr_enable>
ffffffffc0202480:	bf75                	j	ffffffffc020243c <page_remove+0x52>
ffffffffc0202482:	827ff0ef          	jal	ra,ffffffffc0201ca8 <pa2page.part.0>

ffffffffc0202486 <page_insert>:
int page_insert(pde_t *pgdir, struct Page *page, uintptr_t la, uint32_t perm) {
ffffffffc0202486:	7139                	addi	sp,sp,-64
ffffffffc0202488:	e852                	sd	s4,16(sp)
ffffffffc020248a:	8a32                	mv	s4,a2
ffffffffc020248c:	f822                	sd	s0,48(sp)
    pte_t *ptep = get_pte(pgdir, la, 1);
ffffffffc020248e:	4605                	li	a2,1
int page_insert(pde_t *pgdir, struct Page *page, uintptr_t la, uint32_t perm) {
ffffffffc0202490:	842e                	mv	s0,a1
    pte_t *ptep = get_pte(pgdir, la, 1);
ffffffffc0202492:	85d2                	mv	a1,s4
int page_insert(pde_t *pgdir, struct Page *page, uintptr_t la, uint32_t perm) {
ffffffffc0202494:	f426                	sd	s1,40(sp)
ffffffffc0202496:	fc06                	sd	ra,56(sp)
ffffffffc0202498:	f04a                	sd	s2,32(sp)
ffffffffc020249a:	ec4e                	sd	s3,24(sp)
ffffffffc020249c:	e456                	sd	s5,8(sp)
ffffffffc020249e:	84b6                	mv	s1,a3
    pte_t *ptep = get_pte(pgdir, la, 1);
ffffffffc02024a0:	94dff0ef          	jal	ra,ffffffffc0201dec <get_pte>
    if (ptep == NULL) {
ffffffffc02024a4:	c961                	beqz	a0,ffffffffc0202574 <page_insert+0xee>
    page->ref += 1;
ffffffffc02024a6:	4014                	lw	a3,0(s0)
    if (*ptep & PTE_V) {
ffffffffc02024a8:	611c                	ld	a5,0(a0)
ffffffffc02024aa:	89aa                	mv	s3,a0
ffffffffc02024ac:	0016871b          	addiw	a4,a3,1
ffffffffc02024b0:	c018                	sw	a4,0(s0)
ffffffffc02024b2:	0017f713          	andi	a4,a5,1
ffffffffc02024b6:	ef05                	bnez	a4,ffffffffc02024ee <page_insert+0x68>
    return page - pages + nbase;
ffffffffc02024b8:	000b0717          	auipc	a4,0xb0
ffffffffc02024bc:	3f873703          	ld	a4,1016(a4) # ffffffffc02b28b0 <pages>
ffffffffc02024c0:	8c19                	sub	s0,s0,a4
ffffffffc02024c2:	000807b7          	lui	a5,0x80
ffffffffc02024c6:	8419                	srai	s0,s0,0x6
ffffffffc02024c8:	943e                	add	s0,s0,a5
  return (ppn << PTE_PPN_SHIFT) | PTE_V | type;
ffffffffc02024ca:	042a                	slli	s0,s0,0xa
ffffffffc02024cc:	8cc1                	or	s1,s1,s0
ffffffffc02024ce:	0014e493          	ori	s1,s1,1
    *ptep = pte_create(page2ppn(page), PTE_V | perm);
ffffffffc02024d2:	0099b023          	sd	s1,0(s3) # ffffffffc0000000 <_binary_obj___user_exit_out_size+0xffffffffbfff4ed0>
    asm volatile("sfence.vma %0" : : "r"(la));
ffffffffc02024d6:	120a0073          	sfence.vma	s4
    return 0;
ffffffffc02024da:	4501                	li	a0,0
}
ffffffffc02024dc:	70e2                	ld	ra,56(sp)
ffffffffc02024de:	7442                	ld	s0,48(sp)
ffffffffc02024e0:	74a2                	ld	s1,40(sp)
ffffffffc02024e2:	7902                	ld	s2,32(sp)
ffffffffc02024e4:	69e2                	ld	s3,24(sp)
ffffffffc02024e6:	6a42                	ld	s4,16(sp)
ffffffffc02024e8:	6aa2                	ld	s5,8(sp)
ffffffffc02024ea:	6121                	addi	sp,sp,64
ffffffffc02024ec:	8082                	ret
    return pa2page(PTE_ADDR(pte));
ffffffffc02024ee:	078a                	slli	a5,a5,0x2
ffffffffc02024f0:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc02024f2:	000b0717          	auipc	a4,0xb0
ffffffffc02024f6:	3b673703          	ld	a4,950(a4) # ffffffffc02b28a8 <npage>
ffffffffc02024fa:	06e7ff63          	bgeu	a5,a4,ffffffffc0202578 <page_insert+0xf2>
    return &pages[PPN(pa) - nbase];
ffffffffc02024fe:	000b0a97          	auipc	s5,0xb0
ffffffffc0202502:	3b2a8a93          	addi	s5,s5,946 # ffffffffc02b28b0 <pages>
ffffffffc0202506:	000ab703          	ld	a4,0(s5)
ffffffffc020250a:	fff80937          	lui	s2,0xfff80
ffffffffc020250e:	993e                	add	s2,s2,a5
ffffffffc0202510:	091a                	slli	s2,s2,0x6
ffffffffc0202512:	993a                	add	s2,s2,a4
        if (p == page) {
ffffffffc0202514:	01240c63          	beq	s0,s2,ffffffffc020252c <page_insert+0xa6>
    page->ref -= 1;
ffffffffc0202518:	00092783          	lw	a5,0(s2) # fffffffffff80000 <end+0x3fccd6f4>
ffffffffc020251c:	fff7869b          	addiw	a3,a5,-1
ffffffffc0202520:	00d92023          	sw	a3,0(s2)
        if (page_ref(page) ==
ffffffffc0202524:	c691                	beqz	a3,ffffffffc0202530 <page_insert+0xaa>
    asm volatile("sfence.vma %0" : : "r"(la));
ffffffffc0202526:	120a0073          	sfence.vma	s4
}
ffffffffc020252a:	bf59                	j	ffffffffc02024c0 <page_insert+0x3a>
ffffffffc020252c:	c014                	sw	a3,0(s0)
    return page->ref;
ffffffffc020252e:	bf49                	j	ffffffffc02024c0 <page_insert+0x3a>
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0202530:	100027f3          	csrr	a5,sstatus
ffffffffc0202534:	8b89                	andi	a5,a5,2
ffffffffc0202536:	ef91                	bnez	a5,ffffffffc0202552 <page_insert+0xcc>
        pmm_manager->free_pages(base, n);
ffffffffc0202538:	000b0797          	auipc	a5,0xb0
ffffffffc020253c:	3807b783          	ld	a5,896(a5) # ffffffffc02b28b8 <pmm_manager>
ffffffffc0202540:	739c                	ld	a5,32(a5)
ffffffffc0202542:	4585                	li	a1,1
ffffffffc0202544:	854a                	mv	a0,s2
ffffffffc0202546:	9782                	jalr	a5
    return page - pages + nbase;
ffffffffc0202548:	000ab703          	ld	a4,0(s5)
    asm volatile("sfence.vma %0" : : "r"(la));
ffffffffc020254c:	120a0073          	sfence.vma	s4
ffffffffc0202550:	bf85                	j	ffffffffc02024c0 <page_insert+0x3a>
        intr_disable();
ffffffffc0202552:	8f4fe0ef          	jal	ra,ffffffffc0200646 <intr_disable>
        pmm_manager->free_pages(base, n);
ffffffffc0202556:	000b0797          	auipc	a5,0xb0
ffffffffc020255a:	3627b783          	ld	a5,866(a5) # ffffffffc02b28b8 <pmm_manager>
ffffffffc020255e:	739c                	ld	a5,32(a5)
ffffffffc0202560:	4585                	li	a1,1
ffffffffc0202562:	854a                	mv	a0,s2
ffffffffc0202564:	9782                	jalr	a5
        intr_enable();
ffffffffc0202566:	8dafe0ef          	jal	ra,ffffffffc0200640 <intr_enable>
ffffffffc020256a:	000ab703          	ld	a4,0(s5)
    asm volatile("sfence.vma %0" : : "r"(la));
ffffffffc020256e:	120a0073          	sfence.vma	s4
ffffffffc0202572:	b7b9                	j	ffffffffc02024c0 <page_insert+0x3a>
        return -E_NO_MEM;
ffffffffc0202574:	5571                	li	a0,-4
ffffffffc0202576:	b79d                	j	ffffffffc02024dc <page_insert+0x56>
ffffffffc0202578:	f30ff0ef          	jal	ra,ffffffffc0201ca8 <pa2page.part.0>

ffffffffc020257c <pmm_init>:
    pmm_manager = &default_pmm_manager;
ffffffffc020257c:	00005797          	auipc	a5,0x5
ffffffffc0202580:	f0478793          	addi	a5,a5,-252 # ffffffffc0207480 <default_pmm_manager>
    cprintf("memory management: %s\n", pmm_manager->name);
ffffffffc0202584:	638c                	ld	a1,0(a5)
void pmm_init(void) {
ffffffffc0202586:	711d                	addi	sp,sp,-96
ffffffffc0202588:	ec5e                	sd	s7,24(sp)
    cprintf("memory management: %s\n", pmm_manager->name);
ffffffffc020258a:	00005517          	auipc	a0,0x5
ffffffffc020258e:	09e50513          	addi	a0,a0,158 # ffffffffc0207628 <default_pmm_manager+0x1a8>
    pmm_manager = &default_pmm_manager;
ffffffffc0202592:	000b0b97          	auipc	s7,0xb0
ffffffffc0202596:	326b8b93          	addi	s7,s7,806 # ffffffffc02b28b8 <pmm_manager>
void pmm_init(void) {
ffffffffc020259a:	ec86                	sd	ra,88(sp)
ffffffffc020259c:	e4a6                	sd	s1,72(sp)
ffffffffc020259e:	fc4e                	sd	s3,56(sp)
ffffffffc02025a0:	f05a                	sd	s6,32(sp)
    pmm_manager = &default_pmm_manager;
ffffffffc02025a2:	00fbb023          	sd	a5,0(s7)
void pmm_init(void) {
ffffffffc02025a6:	e8a2                	sd	s0,80(sp)
ffffffffc02025a8:	e0ca                	sd	s2,64(sp)
ffffffffc02025aa:	f852                	sd	s4,48(sp)
ffffffffc02025ac:	f456                	sd	s5,40(sp)
ffffffffc02025ae:	e862                	sd	s8,16(sp)
    cprintf("memory management: %s\n", pmm_manager->name);
ffffffffc02025b0:	bd1fd0ef          	jal	ra,ffffffffc0200180 <cprintf>
    pmm_manager->init();
ffffffffc02025b4:	000bb783          	ld	a5,0(s7)
    va_pa_offset = KERNBASE - 0x80200000;
ffffffffc02025b8:	000b0997          	auipc	s3,0xb0
ffffffffc02025bc:	30898993          	addi	s3,s3,776 # ffffffffc02b28c0 <va_pa_offset>
    npage = maxpa / PGSIZE;
ffffffffc02025c0:	000b0497          	auipc	s1,0xb0
ffffffffc02025c4:	2e848493          	addi	s1,s1,744 # ffffffffc02b28a8 <npage>
    pmm_manager->init();
ffffffffc02025c8:	679c                	ld	a5,8(a5)
    pages = (struct Page *)ROUNDUP((void *)end, PGSIZE);
ffffffffc02025ca:	000b0b17          	auipc	s6,0xb0
ffffffffc02025ce:	2e6b0b13          	addi	s6,s6,742 # ffffffffc02b28b0 <pages>
    pmm_manager->init();
ffffffffc02025d2:	9782                	jalr	a5
    va_pa_offset = KERNBASE - 0x80200000;
ffffffffc02025d4:	57f5                	li	a5,-3
ffffffffc02025d6:	07fa                	slli	a5,a5,0x1e
    cprintf("physcial memory map:\n");
ffffffffc02025d8:	00005517          	auipc	a0,0x5
ffffffffc02025dc:	06850513          	addi	a0,a0,104 # ffffffffc0207640 <default_pmm_manager+0x1c0>
    va_pa_offset = KERNBASE - 0x80200000;
ffffffffc02025e0:	00f9b023          	sd	a5,0(s3)
    cprintf("physcial memory map:\n");
ffffffffc02025e4:	b9dfd0ef          	jal	ra,ffffffffc0200180 <cprintf>
    cprintf("  memory: 0x%08lx, [0x%08lx, 0x%08lx].\n", mem_size, mem_begin,
ffffffffc02025e8:	46c5                	li	a3,17
ffffffffc02025ea:	06ee                	slli	a3,a3,0x1b
ffffffffc02025ec:	40100613          	li	a2,1025
ffffffffc02025f0:	07e005b7          	lui	a1,0x7e00
ffffffffc02025f4:	16fd                	addi	a3,a3,-1
ffffffffc02025f6:	0656                	slli	a2,a2,0x15
ffffffffc02025f8:	00005517          	auipc	a0,0x5
ffffffffc02025fc:	06050513          	addi	a0,a0,96 # ffffffffc0207658 <default_pmm_manager+0x1d8>
ffffffffc0202600:	b81fd0ef          	jal	ra,ffffffffc0200180 <cprintf>
    pages = (struct Page *)ROUNDUP((void *)end, PGSIZE);
ffffffffc0202604:	777d                	lui	a4,0xfffff
ffffffffc0202606:	000b1797          	auipc	a5,0xb1
ffffffffc020260a:	30578793          	addi	a5,a5,773 # ffffffffc02b390b <end+0xfff>
ffffffffc020260e:	8ff9                	and	a5,a5,a4
    npage = maxpa / PGSIZE;
ffffffffc0202610:	00088737          	lui	a4,0x88
ffffffffc0202614:	e098                	sd	a4,0(s1)
    pages = (struct Page *)ROUNDUP((void *)end, PGSIZE);
ffffffffc0202616:	00fb3023          	sd	a5,0(s6)
    for (size_t i = 0; i < npage - nbase; i++) {
ffffffffc020261a:	4701                	li	a4,0
ffffffffc020261c:	4585                	li	a1,1
ffffffffc020261e:	fff80837          	lui	a6,0xfff80
ffffffffc0202622:	a019                	j	ffffffffc0202628 <pmm_init+0xac>
        SetPageReserved(pages + i);
ffffffffc0202624:	000b3783          	ld	a5,0(s6)
ffffffffc0202628:	00671693          	slli	a3,a4,0x6
ffffffffc020262c:	97b6                	add	a5,a5,a3
ffffffffc020262e:	07a1                	addi	a5,a5,8
ffffffffc0202630:	40b7b02f          	amoor.d	zero,a1,(a5)
    for (size_t i = 0; i < npage - nbase; i++) {
ffffffffc0202634:	6090                	ld	a2,0(s1)
ffffffffc0202636:	0705                	addi	a4,a4,1
ffffffffc0202638:	010607b3          	add	a5,a2,a6
ffffffffc020263c:	fef764e3          	bltu	a4,a5,ffffffffc0202624 <pmm_init+0xa8>
    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * (npage - nbase));
ffffffffc0202640:	000b3503          	ld	a0,0(s6)
ffffffffc0202644:	079a                	slli	a5,a5,0x6
ffffffffc0202646:	c0200737          	lui	a4,0xc0200
ffffffffc020264a:	00f506b3          	add	a3,a0,a5
ffffffffc020264e:	60e6e563          	bltu	a3,a4,ffffffffc0202c58 <pmm_init+0x6dc>
ffffffffc0202652:	0009b583          	ld	a1,0(s3)
    if (freemem < mem_end) {
ffffffffc0202656:	4745                	li	a4,17
ffffffffc0202658:	076e                	slli	a4,a4,0x1b
    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * (npage - nbase));
ffffffffc020265a:	8e8d                	sub	a3,a3,a1
    if (freemem < mem_end) {
ffffffffc020265c:	4ae6e563          	bltu	a3,a4,ffffffffc0202b06 <pmm_init+0x58a>
    cprintf("vapaofset is %llu\n",va_pa_offset);
ffffffffc0202660:	00005517          	auipc	a0,0x5
ffffffffc0202664:	02050513          	addi	a0,a0,32 # ffffffffc0207680 <default_pmm_manager+0x200>
ffffffffc0202668:	b19fd0ef          	jal	ra,ffffffffc0200180 <cprintf>

    return page;
}

static void check_alloc_page(void) {
    pmm_manager->check();
ffffffffc020266c:	000bb783          	ld	a5,0(s7)
    boot_pgdir = (pte_t*)boot_page_table_sv39;
ffffffffc0202670:	000b0917          	auipc	s2,0xb0
ffffffffc0202674:	23090913          	addi	s2,s2,560 # ffffffffc02b28a0 <boot_pgdir>
    pmm_manager->check();
ffffffffc0202678:	7b9c                	ld	a5,48(a5)
ffffffffc020267a:	9782                	jalr	a5
    cprintf("check_alloc_page() succeeded!\n");
ffffffffc020267c:	00005517          	auipc	a0,0x5
ffffffffc0202680:	01c50513          	addi	a0,a0,28 # ffffffffc0207698 <default_pmm_manager+0x218>
ffffffffc0202684:	afdfd0ef          	jal	ra,ffffffffc0200180 <cprintf>
    boot_pgdir = (pte_t*)boot_page_table_sv39;
ffffffffc0202688:	00009697          	auipc	a3,0x9
ffffffffc020268c:	97868693          	addi	a3,a3,-1672 # ffffffffc020b000 <boot_page_table_sv39>
ffffffffc0202690:	00d93023          	sd	a3,0(s2)
    boot_cr3 = PADDR(boot_pgdir);
ffffffffc0202694:	c02007b7          	lui	a5,0xc0200
ffffffffc0202698:	5cf6ec63          	bltu	a3,a5,ffffffffc0202c70 <pmm_init+0x6f4>
ffffffffc020269c:	0009b783          	ld	a5,0(s3)
ffffffffc02026a0:	8e9d                	sub	a3,a3,a5
ffffffffc02026a2:	000b0797          	auipc	a5,0xb0
ffffffffc02026a6:	1ed7bb23          	sd	a3,502(a5) # ffffffffc02b2898 <boot_cr3>
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc02026aa:	100027f3          	csrr	a5,sstatus
ffffffffc02026ae:	8b89                	andi	a5,a5,2
ffffffffc02026b0:	48079263          	bnez	a5,ffffffffc0202b34 <pmm_init+0x5b8>
        ret = pmm_manager->nr_free_pages();
ffffffffc02026b4:	000bb783          	ld	a5,0(s7)
ffffffffc02026b8:	779c                	ld	a5,40(a5)
ffffffffc02026ba:	9782                	jalr	a5
ffffffffc02026bc:	842a                	mv	s0,a0
    // so npage is always larger than KMEMSIZE / PGSIZE
    size_t nr_free_store;

    nr_free_store=nr_free_pages();

    assert(npage <= KERNTOP / PGSIZE);
ffffffffc02026be:	6098                	ld	a4,0(s1)
ffffffffc02026c0:	c80007b7          	lui	a5,0xc8000
ffffffffc02026c4:	83b1                	srli	a5,a5,0xc
ffffffffc02026c6:	5ee7e163          	bltu	a5,a4,ffffffffc0202ca8 <pmm_init+0x72c>
    assert(boot_pgdir != NULL && (uint32_t)PGOFF(boot_pgdir) == 0);
ffffffffc02026ca:	00093503          	ld	a0,0(s2)
ffffffffc02026ce:	5a050d63          	beqz	a0,ffffffffc0202c88 <pmm_init+0x70c>
ffffffffc02026d2:	03451793          	slli	a5,a0,0x34
ffffffffc02026d6:	5a079963          	bnez	a5,ffffffffc0202c88 <pmm_init+0x70c>
    assert(get_page(boot_pgdir, 0x0, NULL) == NULL);
ffffffffc02026da:	4601                	li	a2,0
ffffffffc02026dc:	4581                	li	a1,0
ffffffffc02026de:	8e1ff0ef          	jal	ra,ffffffffc0201fbe <get_page>
ffffffffc02026e2:	62051563          	bnez	a0,ffffffffc0202d0c <pmm_init+0x790>

    struct Page *p1, *p2;
    p1 = alloc_page();
ffffffffc02026e6:	4505                	li	a0,1
ffffffffc02026e8:	df8ff0ef          	jal	ra,ffffffffc0201ce0 <alloc_pages>
ffffffffc02026ec:	8a2a                	mv	s4,a0
    assert(page_insert(boot_pgdir, p1, 0x0, 0) == 0);
ffffffffc02026ee:	00093503          	ld	a0,0(s2)
ffffffffc02026f2:	4681                	li	a3,0
ffffffffc02026f4:	4601                	li	a2,0
ffffffffc02026f6:	85d2                	mv	a1,s4
ffffffffc02026f8:	d8fff0ef          	jal	ra,ffffffffc0202486 <page_insert>
ffffffffc02026fc:	5e051863          	bnez	a0,ffffffffc0202cec <pmm_init+0x770>

    pte_t *ptep;
    assert((ptep = get_pte(boot_pgdir, 0x0, 0)) != NULL);
ffffffffc0202700:	00093503          	ld	a0,0(s2)
ffffffffc0202704:	4601                	li	a2,0
ffffffffc0202706:	4581                	li	a1,0
ffffffffc0202708:	ee4ff0ef          	jal	ra,ffffffffc0201dec <get_pte>
ffffffffc020270c:	5c050063          	beqz	a0,ffffffffc0202ccc <pmm_init+0x750>
    assert(pte2page(*ptep) == p1);
ffffffffc0202710:	611c                	ld	a5,0(a0)
    if (!(pte & PTE_V)) {
ffffffffc0202712:	0017f713          	andi	a4,a5,1
ffffffffc0202716:	5a070963          	beqz	a4,ffffffffc0202cc8 <pmm_init+0x74c>
    if (PPN(pa) >= npage) {
ffffffffc020271a:	6098                	ld	a4,0(s1)
    return pa2page(PTE_ADDR(pte));
ffffffffc020271c:	078a                	slli	a5,a5,0x2
ffffffffc020271e:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0202720:	52e7fa63          	bgeu	a5,a4,ffffffffc0202c54 <pmm_init+0x6d8>
    return &pages[PPN(pa) - nbase];
ffffffffc0202724:	000b3683          	ld	a3,0(s6)
ffffffffc0202728:	fff80637          	lui	a2,0xfff80
ffffffffc020272c:	97b2                	add	a5,a5,a2
ffffffffc020272e:	079a                	slli	a5,a5,0x6
ffffffffc0202730:	97b6                	add	a5,a5,a3
ffffffffc0202732:	10fa16e3          	bne	s4,a5,ffffffffc020303e <pmm_init+0xac2>
    assert(page_ref(p1) == 1);
ffffffffc0202736:	000a2683          	lw	a3,0(s4) # 1000 <_binary_obj___user_faultread_out_size-0x8bb8>
ffffffffc020273a:	4785                	li	a5,1
ffffffffc020273c:	12f69de3          	bne	a3,a5,ffffffffc0203076 <pmm_init+0xafa>

    ptep = (pte_t *)KADDR(PDE_ADDR(boot_pgdir[0]));
ffffffffc0202740:	00093503          	ld	a0,0(s2)
ffffffffc0202744:	77fd                	lui	a5,0xfffff
ffffffffc0202746:	6114                	ld	a3,0(a0)
ffffffffc0202748:	068a                	slli	a3,a3,0x2
ffffffffc020274a:	8efd                	and	a3,a3,a5
ffffffffc020274c:	00c6d613          	srli	a2,a3,0xc
ffffffffc0202750:	10e677e3          	bgeu	a2,a4,ffffffffc020305e <pmm_init+0xae2>
ffffffffc0202754:	0009bc03          	ld	s8,0(s3)
    ptep = (pte_t *)KADDR(PDE_ADDR(ptep[0])) + 1;
ffffffffc0202758:	96e2                	add	a3,a3,s8
ffffffffc020275a:	0006ba83          	ld	s5,0(a3)
ffffffffc020275e:	0a8a                	slli	s5,s5,0x2
ffffffffc0202760:	00fafab3          	and	s5,s5,a5
ffffffffc0202764:	00cad793          	srli	a5,s5,0xc
ffffffffc0202768:	62e7f263          	bgeu	a5,a4,ffffffffc0202d8c <pmm_init+0x810>
    assert(get_pte(boot_pgdir, PGSIZE, 0) == ptep);
ffffffffc020276c:	4601                	li	a2,0
ffffffffc020276e:	6585                	lui	a1,0x1
    ptep = (pte_t *)KADDR(PDE_ADDR(ptep[0])) + 1;
ffffffffc0202770:	9ae2                	add	s5,s5,s8
    assert(get_pte(boot_pgdir, PGSIZE, 0) == ptep);
ffffffffc0202772:	e7aff0ef          	jal	ra,ffffffffc0201dec <get_pte>
    ptep = (pte_t *)KADDR(PDE_ADDR(ptep[0])) + 1;
ffffffffc0202776:	0aa1                	addi	s5,s5,8
    assert(get_pte(boot_pgdir, PGSIZE, 0) == ptep);
ffffffffc0202778:	5f551a63          	bne	a0,s5,ffffffffc0202d6c <pmm_init+0x7f0>

    p2 = alloc_page();
ffffffffc020277c:	4505                	li	a0,1
ffffffffc020277e:	d62ff0ef          	jal	ra,ffffffffc0201ce0 <alloc_pages>
ffffffffc0202782:	8aaa                	mv	s5,a0
    assert(page_insert(boot_pgdir, p2, PGSIZE, PTE_U | PTE_W) == 0);
ffffffffc0202784:	00093503          	ld	a0,0(s2)
ffffffffc0202788:	46d1                	li	a3,20
ffffffffc020278a:	6605                	lui	a2,0x1
ffffffffc020278c:	85d6                	mv	a1,s5
ffffffffc020278e:	cf9ff0ef          	jal	ra,ffffffffc0202486 <page_insert>
ffffffffc0202792:	58051d63          	bnez	a0,ffffffffc0202d2c <pmm_init+0x7b0>
    assert((ptep = get_pte(boot_pgdir, PGSIZE, 0)) != NULL);
ffffffffc0202796:	00093503          	ld	a0,0(s2)
ffffffffc020279a:	4601                	li	a2,0
ffffffffc020279c:	6585                	lui	a1,0x1
ffffffffc020279e:	e4eff0ef          	jal	ra,ffffffffc0201dec <get_pte>
ffffffffc02027a2:	0e050ae3          	beqz	a0,ffffffffc0203096 <pmm_init+0xb1a>
    assert(*ptep & PTE_U);
ffffffffc02027a6:	611c                	ld	a5,0(a0)
ffffffffc02027a8:	0107f713          	andi	a4,a5,16
ffffffffc02027ac:	6e070d63          	beqz	a4,ffffffffc0202ea6 <pmm_init+0x92a>
    assert(*ptep & PTE_W);
ffffffffc02027b0:	8b91                	andi	a5,a5,4
ffffffffc02027b2:	6a078a63          	beqz	a5,ffffffffc0202e66 <pmm_init+0x8ea>
    assert(boot_pgdir[0] & PTE_U);
ffffffffc02027b6:	00093503          	ld	a0,0(s2)
ffffffffc02027ba:	611c                	ld	a5,0(a0)
ffffffffc02027bc:	8bc1                	andi	a5,a5,16
ffffffffc02027be:	68078463          	beqz	a5,ffffffffc0202e46 <pmm_init+0x8ca>
    assert(page_ref(p2) == 1);
ffffffffc02027c2:	000aa703          	lw	a4,0(s5)
ffffffffc02027c6:	4785                	li	a5,1
ffffffffc02027c8:	58f71263          	bne	a4,a5,ffffffffc0202d4c <pmm_init+0x7d0>

    assert(page_insert(boot_pgdir, p1, PGSIZE, 0) == 0);
ffffffffc02027cc:	4681                	li	a3,0
ffffffffc02027ce:	6605                	lui	a2,0x1
ffffffffc02027d0:	85d2                	mv	a1,s4
ffffffffc02027d2:	cb5ff0ef          	jal	ra,ffffffffc0202486 <page_insert>
ffffffffc02027d6:	62051863          	bnez	a0,ffffffffc0202e06 <pmm_init+0x88a>
    assert(page_ref(p1) == 2);
ffffffffc02027da:	000a2703          	lw	a4,0(s4)
ffffffffc02027de:	4789                	li	a5,2
ffffffffc02027e0:	60f71363          	bne	a4,a5,ffffffffc0202de6 <pmm_init+0x86a>
    assert(page_ref(p2) == 0);
ffffffffc02027e4:	000aa783          	lw	a5,0(s5)
ffffffffc02027e8:	5c079f63          	bnez	a5,ffffffffc0202dc6 <pmm_init+0x84a>
    assert((ptep = get_pte(boot_pgdir, PGSIZE, 0)) != NULL);
ffffffffc02027ec:	00093503          	ld	a0,0(s2)
ffffffffc02027f0:	4601                	li	a2,0
ffffffffc02027f2:	6585                	lui	a1,0x1
ffffffffc02027f4:	df8ff0ef          	jal	ra,ffffffffc0201dec <get_pte>
ffffffffc02027f8:	5a050763          	beqz	a0,ffffffffc0202da6 <pmm_init+0x82a>
    assert(pte2page(*ptep) == p1);
ffffffffc02027fc:	6118                	ld	a4,0(a0)
    if (!(pte & PTE_V)) {
ffffffffc02027fe:	00177793          	andi	a5,a4,1
ffffffffc0202802:	4c078363          	beqz	a5,ffffffffc0202cc8 <pmm_init+0x74c>
    if (PPN(pa) >= npage) {
ffffffffc0202806:	6094                	ld	a3,0(s1)
    return pa2page(PTE_ADDR(pte));
ffffffffc0202808:	00271793          	slli	a5,a4,0x2
ffffffffc020280c:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc020280e:	44d7f363          	bgeu	a5,a3,ffffffffc0202c54 <pmm_init+0x6d8>
    return &pages[PPN(pa) - nbase];
ffffffffc0202812:	000b3683          	ld	a3,0(s6)
ffffffffc0202816:	fff80637          	lui	a2,0xfff80
ffffffffc020281a:	97b2                	add	a5,a5,a2
ffffffffc020281c:	079a                	slli	a5,a5,0x6
ffffffffc020281e:	97b6                	add	a5,a5,a3
ffffffffc0202820:	6efa1363          	bne	s4,a5,ffffffffc0202f06 <pmm_init+0x98a>
    assert((*ptep & PTE_U) == 0);
ffffffffc0202824:	8b41                	andi	a4,a4,16
ffffffffc0202826:	6c071063          	bnez	a4,ffffffffc0202ee6 <pmm_init+0x96a>

    page_remove(boot_pgdir, 0x0);
ffffffffc020282a:	00093503          	ld	a0,0(s2)
ffffffffc020282e:	4581                	li	a1,0
ffffffffc0202830:	bbbff0ef          	jal	ra,ffffffffc02023ea <page_remove>
    assert(page_ref(p1) == 1);
ffffffffc0202834:	000a2703          	lw	a4,0(s4)
ffffffffc0202838:	4785                	li	a5,1
ffffffffc020283a:	68f71663          	bne	a4,a5,ffffffffc0202ec6 <pmm_init+0x94a>
    assert(page_ref(p2) == 0);
ffffffffc020283e:	000aa783          	lw	a5,0(s5)
ffffffffc0202842:	74079e63          	bnez	a5,ffffffffc0202f9e <pmm_init+0xa22>

    page_remove(boot_pgdir, PGSIZE);
ffffffffc0202846:	00093503          	ld	a0,0(s2)
ffffffffc020284a:	6585                	lui	a1,0x1
ffffffffc020284c:	b9fff0ef          	jal	ra,ffffffffc02023ea <page_remove>
    assert(page_ref(p1) == 0);
ffffffffc0202850:	000a2783          	lw	a5,0(s4)
ffffffffc0202854:	72079563          	bnez	a5,ffffffffc0202f7e <pmm_init+0xa02>
    assert(page_ref(p2) == 0);
ffffffffc0202858:	000aa783          	lw	a5,0(s5)
ffffffffc020285c:	70079163          	bnez	a5,ffffffffc0202f5e <pmm_init+0x9e2>

    assert(page_ref(pde2page(boot_pgdir[0])) == 1);
ffffffffc0202860:	00093a03          	ld	s4,0(s2)
    if (PPN(pa) >= npage) {
ffffffffc0202864:	6098                	ld	a4,0(s1)
    return pa2page(PDE_ADDR(pde));
ffffffffc0202866:	000a3683          	ld	a3,0(s4)
ffffffffc020286a:	068a                	slli	a3,a3,0x2
ffffffffc020286c:	82b1                	srli	a3,a3,0xc
    if (PPN(pa) >= npage) {
ffffffffc020286e:	3ee6f363          	bgeu	a3,a4,ffffffffc0202c54 <pmm_init+0x6d8>
    return &pages[PPN(pa) - nbase];
ffffffffc0202872:	fff807b7          	lui	a5,0xfff80
ffffffffc0202876:	000b3503          	ld	a0,0(s6)
ffffffffc020287a:	96be                	add	a3,a3,a5
ffffffffc020287c:	069a                	slli	a3,a3,0x6
    return page->ref;
ffffffffc020287e:	00d507b3          	add	a5,a0,a3
ffffffffc0202882:	4390                	lw	a2,0(a5)
ffffffffc0202884:	4785                	li	a5,1
ffffffffc0202886:	6af61c63          	bne	a2,a5,ffffffffc0202f3e <pmm_init+0x9c2>
    return page - pages + nbase;
ffffffffc020288a:	8699                	srai	a3,a3,0x6
ffffffffc020288c:	000805b7          	lui	a1,0x80
ffffffffc0202890:	96ae                	add	a3,a3,a1
    return KADDR(page2pa(page));
ffffffffc0202892:	00c69613          	slli	a2,a3,0xc
ffffffffc0202896:	8231                	srli	a2,a2,0xc
    return page2ppn(page) << PGSHIFT;
ffffffffc0202898:	06b2                	slli	a3,a3,0xc
    return KADDR(page2pa(page));
ffffffffc020289a:	68e67663          	bgeu	a2,a4,ffffffffc0202f26 <pmm_init+0x9aa>

    pde_t *pd1=boot_pgdir,*pd0=page2kva(pde2page(boot_pgdir[0]));
    free_page(pde2page(pd0[0]));
ffffffffc020289e:	0009b603          	ld	a2,0(s3)
ffffffffc02028a2:	96b2                	add	a3,a3,a2
    return pa2page(PDE_ADDR(pde));
ffffffffc02028a4:	629c                	ld	a5,0(a3)
ffffffffc02028a6:	078a                	slli	a5,a5,0x2
ffffffffc02028a8:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc02028aa:	3ae7f563          	bgeu	a5,a4,ffffffffc0202c54 <pmm_init+0x6d8>
    return &pages[PPN(pa) - nbase];
ffffffffc02028ae:	8f8d                	sub	a5,a5,a1
ffffffffc02028b0:	079a                	slli	a5,a5,0x6
ffffffffc02028b2:	953e                	add	a0,a0,a5
ffffffffc02028b4:	100027f3          	csrr	a5,sstatus
ffffffffc02028b8:	8b89                	andi	a5,a5,2
ffffffffc02028ba:	2c079763          	bnez	a5,ffffffffc0202b88 <pmm_init+0x60c>
        pmm_manager->free_pages(base, n);
ffffffffc02028be:	000bb783          	ld	a5,0(s7)
ffffffffc02028c2:	4585                	li	a1,1
ffffffffc02028c4:	739c                	ld	a5,32(a5)
ffffffffc02028c6:	9782                	jalr	a5
    return pa2page(PDE_ADDR(pde));
ffffffffc02028c8:	000a3783          	ld	a5,0(s4)
    if (PPN(pa) >= npage) {
ffffffffc02028cc:	6098                	ld	a4,0(s1)
    return pa2page(PDE_ADDR(pde));
ffffffffc02028ce:	078a                	slli	a5,a5,0x2
ffffffffc02028d0:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc02028d2:	38e7f163          	bgeu	a5,a4,ffffffffc0202c54 <pmm_init+0x6d8>
    return &pages[PPN(pa) - nbase];
ffffffffc02028d6:	000b3503          	ld	a0,0(s6)
ffffffffc02028da:	fff80737          	lui	a4,0xfff80
ffffffffc02028de:	97ba                	add	a5,a5,a4
ffffffffc02028e0:	079a                	slli	a5,a5,0x6
ffffffffc02028e2:	953e                	add	a0,a0,a5
ffffffffc02028e4:	100027f3          	csrr	a5,sstatus
ffffffffc02028e8:	8b89                	andi	a5,a5,2
ffffffffc02028ea:	28079363          	bnez	a5,ffffffffc0202b70 <pmm_init+0x5f4>
ffffffffc02028ee:	000bb783          	ld	a5,0(s7)
ffffffffc02028f2:	4585                	li	a1,1
ffffffffc02028f4:	739c                	ld	a5,32(a5)
ffffffffc02028f6:	9782                	jalr	a5
    free_page(pde2page(pd1[0]));
    boot_pgdir[0] = 0;
ffffffffc02028f8:	00093783          	ld	a5,0(s2)
ffffffffc02028fc:	0007b023          	sd	zero,0(a5) # fffffffffff80000 <end+0x3fccd6f4>
  asm volatile("sfence.vma");
ffffffffc0202900:	12000073          	sfence.vma
ffffffffc0202904:	100027f3          	csrr	a5,sstatus
ffffffffc0202908:	8b89                	andi	a5,a5,2
ffffffffc020290a:	24079963          	bnez	a5,ffffffffc0202b5c <pmm_init+0x5e0>
        ret = pmm_manager->nr_free_pages();
ffffffffc020290e:	000bb783          	ld	a5,0(s7)
ffffffffc0202912:	779c                	ld	a5,40(a5)
ffffffffc0202914:	9782                	jalr	a5
ffffffffc0202916:	8a2a                	mv	s4,a0
    flush_tlb();

    assert(nr_free_store==nr_free_pages());
ffffffffc0202918:	71441363          	bne	s0,s4,ffffffffc020301e <pmm_init+0xaa2>

    cprintf("check_pgdir() succeeded!\n");
ffffffffc020291c:	00005517          	auipc	a0,0x5
ffffffffc0202920:	06450513          	addi	a0,a0,100 # ffffffffc0207980 <default_pmm_manager+0x500>
ffffffffc0202924:	85dfd0ef          	jal	ra,ffffffffc0200180 <cprintf>
ffffffffc0202928:	100027f3          	csrr	a5,sstatus
ffffffffc020292c:	8b89                	andi	a5,a5,2
ffffffffc020292e:	20079d63          	bnez	a5,ffffffffc0202b48 <pmm_init+0x5cc>
        ret = pmm_manager->nr_free_pages();
ffffffffc0202932:	000bb783          	ld	a5,0(s7)
ffffffffc0202936:	779c                	ld	a5,40(a5)
ffffffffc0202938:	9782                	jalr	a5
ffffffffc020293a:	8c2a                	mv	s8,a0
    pte_t *ptep;
    int i;

    nr_free_store=nr_free_pages();

    for (i = ROUNDDOWN(KERNBASE, PGSIZE); i < npage * PGSIZE; i += PGSIZE) {
ffffffffc020293c:	6098                	ld	a4,0(s1)
ffffffffc020293e:	c0200437          	lui	s0,0xc0200
        assert((ptep = get_pte(boot_pgdir, (uintptr_t)KADDR(i), 0)) != NULL);
        assert(PTE_ADDR(*ptep) == i);
ffffffffc0202942:	7afd                	lui	s5,0xfffff
    for (i = ROUNDDOWN(KERNBASE, PGSIZE); i < npage * PGSIZE; i += PGSIZE) {
ffffffffc0202944:	00c71793          	slli	a5,a4,0xc
ffffffffc0202948:	6a05                	lui	s4,0x1
ffffffffc020294a:	02f47c63          	bgeu	s0,a5,ffffffffc0202982 <pmm_init+0x406>
        assert((ptep = get_pte(boot_pgdir, (uintptr_t)KADDR(i), 0)) != NULL);
ffffffffc020294e:	00c45793          	srli	a5,s0,0xc
ffffffffc0202952:	00093503          	ld	a0,0(s2)
ffffffffc0202956:	2ee7f263          	bgeu	a5,a4,ffffffffc0202c3a <pmm_init+0x6be>
ffffffffc020295a:	0009b583          	ld	a1,0(s3)
ffffffffc020295e:	4601                	li	a2,0
ffffffffc0202960:	95a2                	add	a1,a1,s0
ffffffffc0202962:	c8aff0ef          	jal	ra,ffffffffc0201dec <get_pte>
ffffffffc0202966:	2a050a63          	beqz	a0,ffffffffc0202c1a <pmm_init+0x69e>
        assert(PTE_ADDR(*ptep) == i);
ffffffffc020296a:	611c                	ld	a5,0(a0)
ffffffffc020296c:	078a                	slli	a5,a5,0x2
ffffffffc020296e:	0157f7b3          	and	a5,a5,s5
ffffffffc0202972:	28879463          	bne	a5,s0,ffffffffc0202bfa <pmm_init+0x67e>
    for (i = ROUNDDOWN(KERNBASE, PGSIZE); i < npage * PGSIZE; i += PGSIZE) {
ffffffffc0202976:	6098                	ld	a4,0(s1)
ffffffffc0202978:	9452                	add	s0,s0,s4
ffffffffc020297a:	00c71793          	slli	a5,a4,0xc
ffffffffc020297e:	fcf468e3          	bltu	s0,a5,ffffffffc020294e <pmm_init+0x3d2>
    }


    assert(boot_pgdir[0] == 0);
ffffffffc0202982:	00093783          	ld	a5,0(s2)
ffffffffc0202986:	639c                	ld	a5,0(a5)
ffffffffc0202988:	66079b63          	bnez	a5,ffffffffc0202ffe <pmm_init+0xa82>

    struct Page *p;
    p = alloc_page();
ffffffffc020298c:	4505                	li	a0,1
ffffffffc020298e:	b52ff0ef          	jal	ra,ffffffffc0201ce0 <alloc_pages>
ffffffffc0202992:	8aaa                	mv	s5,a0
    assert(page_insert(boot_pgdir, p, 0x100, PTE_W | PTE_R) == 0);
ffffffffc0202994:	00093503          	ld	a0,0(s2)
ffffffffc0202998:	4699                	li	a3,6
ffffffffc020299a:	10000613          	li	a2,256
ffffffffc020299e:	85d6                	mv	a1,s5
ffffffffc02029a0:	ae7ff0ef          	jal	ra,ffffffffc0202486 <page_insert>
ffffffffc02029a4:	62051d63          	bnez	a0,ffffffffc0202fde <pmm_init+0xa62>
    assert(page_ref(p) == 1);
ffffffffc02029a8:	000aa703          	lw	a4,0(s5) # fffffffffffff000 <end+0x3fd4c6f4>
ffffffffc02029ac:	4785                	li	a5,1
ffffffffc02029ae:	60f71863          	bne	a4,a5,ffffffffc0202fbe <pmm_init+0xa42>
    assert(page_insert(boot_pgdir, p, 0x100 + PGSIZE, PTE_W | PTE_R) == 0);
ffffffffc02029b2:	00093503          	ld	a0,0(s2)
ffffffffc02029b6:	6405                	lui	s0,0x1
ffffffffc02029b8:	4699                	li	a3,6
ffffffffc02029ba:	10040613          	addi	a2,s0,256 # 1100 <_binary_obj___user_faultread_out_size-0x8ab8>
ffffffffc02029be:	85d6                	mv	a1,s5
ffffffffc02029c0:	ac7ff0ef          	jal	ra,ffffffffc0202486 <page_insert>
ffffffffc02029c4:	46051163          	bnez	a0,ffffffffc0202e26 <pmm_init+0x8aa>
    assert(page_ref(p) == 2);
ffffffffc02029c8:	000aa703          	lw	a4,0(s5)
ffffffffc02029cc:	4789                	li	a5,2
ffffffffc02029ce:	72f71463          	bne	a4,a5,ffffffffc02030f6 <pmm_init+0xb7a>

    const char *str = "ucore: Hello world!!";
    strcpy((void *)0x100, str);
ffffffffc02029d2:	00005597          	auipc	a1,0x5
ffffffffc02029d6:	0e658593          	addi	a1,a1,230 # ffffffffc0207ab8 <default_pmm_manager+0x638>
ffffffffc02029da:	10000513          	li	a0,256
ffffffffc02029de:	4e1030ef          	jal	ra,ffffffffc02066be <strcpy>
    assert(strcmp((void *)0x100, (void *)(0x100 + PGSIZE)) == 0);
ffffffffc02029e2:	10040593          	addi	a1,s0,256
ffffffffc02029e6:	10000513          	li	a0,256
ffffffffc02029ea:	4e7030ef          	jal	ra,ffffffffc02066d0 <strcmp>
ffffffffc02029ee:	6e051463          	bnez	a0,ffffffffc02030d6 <pmm_init+0xb5a>
    return page - pages + nbase;
ffffffffc02029f2:	000b3683          	ld	a3,0(s6)
ffffffffc02029f6:	00080737          	lui	a4,0x80
    return KADDR(page2pa(page));
ffffffffc02029fa:	547d                	li	s0,-1
    return page - pages + nbase;
ffffffffc02029fc:	40da86b3          	sub	a3,s5,a3
ffffffffc0202a00:	8699                	srai	a3,a3,0x6
    return KADDR(page2pa(page));
ffffffffc0202a02:	609c                	ld	a5,0(s1)
    return page - pages + nbase;
ffffffffc0202a04:	96ba                	add	a3,a3,a4
    return KADDR(page2pa(page));
ffffffffc0202a06:	8031                	srli	s0,s0,0xc
ffffffffc0202a08:	0086f733          	and	a4,a3,s0
    return page2ppn(page) << PGSHIFT;
ffffffffc0202a0c:	06b2                	slli	a3,a3,0xc
    return KADDR(page2pa(page));
ffffffffc0202a0e:	50f77c63          	bgeu	a4,a5,ffffffffc0202f26 <pmm_init+0x9aa>

    *(char *)(page2kva(p) + 0x100) = '\0';
ffffffffc0202a12:	0009b783          	ld	a5,0(s3)
    assert(strlen((const char *)0x100) == 0);
ffffffffc0202a16:	10000513          	li	a0,256
    *(char *)(page2kva(p) + 0x100) = '\0';
ffffffffc0202a1a:	96be                	add	a3,a3,a5
ffffffffc0202a1c:	10068023          	sb	zero,256(a3)
    assert(strlen((const char *)0x100) == 0);
ffffffffc0202a20:	469030ef          	jal	ra,ffffffffc0206688 <strlen>
ffffffffc0202a24:	68051963          	bnez	a0,ffffffffc02030b6 <pmm_init+0xb3a>

    pde_t *pd1=boot_pgdir,*pd0=page2kva(pde2page(boot_pgdir[0]));
ffffffffc0202a28:	00093a03          	ld	s4,0(s2)
    if (PPN(pa) >= npage) {
ffffffffc0202a2c:	609c                	ld	a5,0(s1)
    return pa2page(PDE_ADDR(pde));
ffffffffc0202a2e:	000a3683          	ld	a3,0(s4) # 1000 <_binary_obj___user_faultread_out_size-0x8bb8>
ffffffffc0202a32:	068a                	slli	a3,a3,0x2
ffffffffc0202a34:	82b1                	srli	a3,a3,0xc
    if (PPN(pa) >= npage) {
ffffffffc0202a36:	20f6ff63          	bgeu	a3,a5,ffffffffc0202c54 <pmm_init+0x6d8>
    return KADDR(page2pa(page));
ffffffffc0202a3a:	8c75                	and	s0,s0,a3
    return page2ppn(page) << PGSHIFT;
ffffffffc0202a3c:	06b2                	slli	a3,a3,0xc
    return KADDR(page2pa(page));
ffffffffc0202a3e:	4ef47463          	bgeu	s0,a5,ffffffffc0202f26 <pmm_init+0x9aa>
ffffffffc0202a42:	0009b403          	ld	s0,0(s3)
ffffffffc0202a46:	9436                	add	s0,s0,a3
ffffffffc0202a48:	100027f3          	csrr	a5,sstatus
ffffffffc0202a4c:	8b89                	andi	a5,a5,2
ffffffffc0202a4e:	18079b63          	bnez	a5,ffffffffc0202be4 <pmm_init+0x668>
        pmm_manager->free_pages(base, n);
ffffffffc0202a52:	000bb783          	ld	a5,0(s7)
ffffffffc0202a56:	4585                	li	a1,1
ffffffffc0202a58:	8556                	mv	a0,s5
ffffffffc0202a5a:	739c                	ld	a5,32(a5)
ffffffffc0202a5c:	9782                	jalr	a5
    return pa2page(PDE_ADDR(pde));
ffffffffc0202a5e:	601c                	ld	a5,0(s0)
    if (PPN(pa) >= npage) {
ffffffffc0202a60:	6098                	ld	a4,0(s1)
    return pa2page(PDE_ADDR(pde));
ffffffffc0202a62:	078a                	slli	a5,a5,0x2
ffffffffc0202a64:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0202a66:	1ee7f763          	bgeu	a5,a4,ffffffffc0202c54 <pmm_init+0x6d8>
    return &pages[PPN(pa) - nbase];
ffffffffc0202a6a:	000b3503          	ld	a0,0(s6)
ffffffffc0202a6e:	fff80737          	lui	a4,0xfff80
ffffffffc0202a72:	97ba                	add	a5,a5,a4
ffffffffc0202a74:	079a                	slli	a5,a5,0x6
ffffffffc0202a76:	953e                	add	a0,a0,a5
ffffffffc0202a78:	100027f3          	csrr	a5,sstatus
ffffffffc0202a7c:	8b89                	andi	a5,a5,2
ffffffffc0202a7e:	14079763          	bnez	a5,ffffffffc0202bcc <pmm_init+0x650>
ffffffffc0202a82:	000bb783          	ld	a5,0(s7)
ffffffffc0202a86:	4585                	li	a1,1
ffffffffc0202a88:	739c                	ld	a5,32(a5)
ffffffffc0202a8a:	9782                	jalr	a5
    return pa2page(PDE_ADDR(pde));
ffffffffc0202a8c:	000a3783          	ld	a5,0(s4)
    if (PPN(pa) >= npage) {
ffffffffc0202a90:	6098                	ld	a4,0(s1)
    return pa2page(PDE_ADDR(pde));
ffffffffc0202a92:	078a                	slli	a5,a5,0x2
ffffffffc0202a94:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0202a96:	1ae7ff63          	bgeu	a5,a4,ffffffffc0202c54 <pmm_init+0x6d8>
    return &pages[PPN(pa) - nbase];
ffffffffc0202a9a:	000b3503          	ld	a0,0(s6)
ffffffffc0202a9e:	fff80737          	lui	a4,0xfff80
ffffffffc0202aa2:	97ba                	add	a5,a5,a4
ffffffffc0202aa4:	079a                	slli	a5,a5,0x6
ffffffffc0202aa6:	953e                	add	a0,a0,a5
ffffffffc0202aa8:	100027f3          	csrr	a5,sstatus
ffffffffc0202aac:	8b89                	andi	a5,a5,2
ffffffffc0202aae:	10079363          	bnez	a5,ffffffffc0202bb4 <pmm_init+0x638>
ffffffffc0202ab2:	000bb783          	ld	a5,0(s7)
ffffffffc0202ab6:	4585                	li	a1,1
ffffffffc0202ab8:	739c                	ld	a5,32(a5)
ffffffffc0202aba:	9782                	jalr	a5
    free_page(p);
    free_page(pde2page(pd0[0]));
    free_page(pde2page(pd1[0]));
    boot_pgdir[0] = 0;
ffffffffc0202abc:	00093783          	ld	a5,0(s2)
ffffffffc0202ac0:	0007b023          	sd	zero,0(a5)
  asm volatile("sfence.vma");
ffffffffc0202ac4:	12000073          	sfence.vma
ffffffffc0202ac8:	100027f3          	csrr	a5,sstatus
ffffffffc0202acc:	8b89                	andi	a5,a5,2
ffffffffc0202ace:	0c079963          	bnez	a5,ffffffffc0202ba0 <pmm_init+0x624>
        ret = pmm_manager->nr_free_pages();
ffffffffc0202ad2:	000bb783          	ld	a5,0(s7)
ffffffffc0202ad6:	779c                	ld	a5,40(a5)
ffffffffc0202ad8:	9782                	jalr	a5
ffffffffc0202ada:	842a                	mv	s0,a0
    flush_tlb();

    assert(nr_free_store==nr_free_pages());
ffffffffc0202adc:	3a8c1563          	bne	s8,s0,ffffffffc0202e86 <pmm_init+0x90a>

    cprintf("check_boot_pgdir() succeeded!\n");
ffffffffc0202ae0:	00005517          	auipc	a0,0x5
ffffffffc0202ae4:	05050513          	addi	a0,a0,80 # ffffffffc0207b30 <default_pmm_manager+0x6b0>
ffffffffc0202ae8:	e98fd0ef          	jal	ra,ffffffffc0200180 <cprintf>
}
ffffffffc0202aec:	6446                	ld	s0,80(sp)
ffffffffc0202aee:	60e6                	ld	ra,88(sp)
ffffffffc0202af0:	64a6                	ld	s1,72(sp)
ffffffffc0202af2:	6906                	ld	s2,64(sp)
ffffffffc0202af4:	79e2                	ld	s3,56(sp)
ffffffffc0202af6:	7a42                	ld	s4,48(sp)
ffffffffc0202af8:	7aa2                	ld	s5,40(sp)
ffffffffc0202afa:	7b02                	ld	s6,32(sp)
ffffffffc0202afc:	6be2                	ld	s7,24(sp)
ffffffffc0202afe:	6c42                	ld	s8,16(sp)
ffffffffc0202b00:	6125                	addi	sp,sp,96
    kmalloc_init();
ffffffffc0202b02:	fddfe06f          	j	ffffffffc0201ade <kmalloc_init>
    mem_begin = ROUNDUP(freemem, PGSIZE);
ffffffffc0202b06:	6785                	lui	a5,0x1
ffffffffc0202b08:	17fd                	addi	a5,a5,-1
ffffffffc0202b0a:	96be                	add	a3,a3,a5
ffffffffc0202b0c:	77fd                	lui	a5,0xfffff
ffffffffc0202b0e:	8ff5                	and	a5,a5,a3
    if (PPN(pa) >= npage) {
ffffffffc0202b10:	00c7d693          	srli	a3,a5,0xc
ffffffffc0202b14:	14c6f063          	bgeu	a3,a2,ffffffffc0202c54 <pmm_init+0x6d8>
    pmm_manager->init_memmap(base, n);
ffffffffc0202b18:	000bb603          	ld	a2,0(s7)
    return &pages[PPN(pa) - nbase];
ffffffffc0202b1c:	96c2                	add	a3,a3,a6
        init_memmap(pa2page(mem_begin), (mem_end - mem_begin) / PGSIZE);
ffffffffc0202b1e:	40f707b3          	sub	a5,a4,a5
    pmm_manager->init_memmap(base, n);
ffffffffc0202b22:	6a10                	ld	a2,16(a2)
ffffffffc0202b24:	069a                	slli	a3,a3,0x6
ffffffffc0202b26:	00c7d593          	srli	a1,a5,0xc
ffffffffc0202b2a:	9536                	add	a0,a0,a3
ffffffffc0202b2c:	9602                	jalr	a2
    cprintf("vapaofset is %llu\n",va_pa_offset);
ffffffffc0202b2e:	0009b583          	ld	a1,0(s3)
}
ffffffffc0202b32:	b63d                	j	ffffffffc0202660 <pmm_init+0xe4>
        intr_disable();
ffffffffc0202b34:	b13fd0ef          	jal	ra,ffffffffc0200646 <intr_disable>
        ret = pmm_manager->nr_free_pages();
ffffffffc0202b38:	000bb783          	ld	a5,0(s7)
ffffffffc0202b3c:	779c                	ld	a5,40(a5)
ffffffffc0202b3e:	9782                	jalr	a5
ffffffffc0202b40:	842a                	mv	s0,a0
        intr_enable();
ffffffffc0202b42:	afffd0ef          	jal	ra,ffffffffc0200640 <intr_enable>
ffffffffc0202b46:	bea5                	j	ffffffffc02026be <pmm_init+0x142>
        intr_disable();
ffffffffc0202b48:	afffd0ef          	jal	ra,ffffffffc0200646 <intr_disable>
ffffffffc0202b4c:	000bb783          	ld	a5,0(s7)
ffffffffc0202b50:	779c                	ld	a5,40(a5)
ffffffffc0202b52:	9782                	jalr	a5
ffffffffc0202b54:	8c2a                	mv	s8,a0
        intr_enable();
ffffffffc0202b56:	aebfd0ef          	jal	ra,ffffffffc0200640 <intr_enable>
ffffffffc0202b5a:	b3cd                	j	ffffffffc020293c <pmm_init+0x3c0>
        intr_disable();
ffffffffc0202b5c:	aebfd0ef          	jal	ra,ffffffffc0200646 <intr_disable>
ffffffffc0202b60:	000bb783          	ld	a5,0(s7)
ffffffffc0202b64:	779c                	ld	a5,40(a5)
ffffffffc0202b66:	9782                	jalr	a5
ffffffffc0202b68:	8a2a                	mv	s4,a0
        intr_enable();
ffffffffc0202b6a:	ad7fd0ef          	jal	ra,ffffffffc0200640 <intr_enable>
ffffffffc0202b6e:	b36d                	j	ffffffffc0202918 <pmm_init+0x39c>
ffffffffc0202b70:	e42a                	sd	a0,8(sp)
        intr_disable();
ffffffffc0202b72:	ad5fd0ef          	jal	ra,ffffffffc0200646 <intr_disable>
        pmm_manager->free_pages(base, n);
ffffffffc0202b76:	000bb783          	ld	a5,0(s7)
ffffffffc0202b7a:	6522                	ld	a0,8(sp)
ffffffffc0202b7c:	4585                	li	a1,1
ffffffffc0202b7e:	739c                	ld	a5,32(a5)
ffffffffc0202b80:	9782                	jalr	a5
        intr_enable();
ffffffffc0202b82:	abffd0ef          	jal	ra,ffffffffc0200640 <intr_enable>
ffffffffc0202b86:	bb8d                	j	ffffffffc02028f8 <pmm_init+0x37c>
ffffffffc0202b88:	e42a                	sd	a0,8(sp)
        intr_disable();
ffffffffc0202b8a:	abdfd0ef          	jal	ra,ffffffffc0200646 <intr_disable>
ffffffffc0202b8e:	000bb783          	ld	a5,0(s7)
ffffffffc0202b92:	6522                	ld	a0,8(sp)
ffffffffc0202b94:	4585                	li	a1,1
ffffffffc0202b96:	739c                	ld	a5,32(a5)
ffffffffc0202b98:	9782                	jalr	a5
        intr_enable();
ffffffffc0202b9a:	aa7fd0ef          	jal	ra,ffffffffc0200640 <intr_enable>
ffffffffc0202b9e:	b32d                	j	ffffffffc02028c8 <pmm_init+0x34c>
        intr_disable();
ffffffffc0202ba0:	aa7fd0ef          	jal	ra,ffffffffc0200646 <intr_disable>
        ret = pmm_manager->nr_free_pages();
ffffffffc0202ba4:	000bb783          	ld	a5,0(s7)
ffffffffc0202ba8:	779c                	ld	a5,40(a5)
ffffffffc0202baa:	9782                	jalr	a5
ffffffffc0202bac:	842a                	mv	s0,a0
        intr_enable();
ffffffffc0202bae:	a93fd0ef          	jal	ra,ffffffffc0200640 <intr_enable>
ffffffffc0202bb2:	b72d                	j	ffffffffc0202adc <pmm_init+0x560>
ffffffffc0202bb4:	e42a                	sd	a0,8(sp)
        intr_disable();
ffffffffc0202bb6:	a91fd0ef          	jal	ra,ffffffffc0200646 <intr_disable>
        pmm_manager->free_pages(base, n);
ffffffffc0202bba:	000bb783          	ld	a5,0(s7)
ffffffffc0202bbe:	6522                	ld	a0,8(sp)
ffffffffc0202bc0:	4585                	li	a1,1
ffffffffc0202bc2:	739c                	ld	a5,32(a5)
ffffffffc0202bc4:	9782                	jalr	a5
        intr_enable();
ffffffffc0202bc6:	a7bfd0ef          	jal	ra,ffffffffc0200640 <intr_enable>
ffffffffc0202bca:	bdcd                	j	ffffffffc0202abc <pmm_init+0x540>
ffffffffc0202bcc:	e42a                	sd	a0,8(sp)
        intr_disable();
ffffffffc0202bce:	a79fd0ef          	jal	ra,ffffffffc0200646 <intr_disable>
ffffffffc0202bd2:	000bb783          	ld	a5,0(s7)
ffffffffc0202bd6:	6522                	ld	a0,8(sp)
ffffffffc0202bd8:	4585                	li	a1,1
ffffffffc0202bda:	739c                	ld	a5,32(a5)
ffffffffc0202bdc:	9782                	jalr	a5
        intr_enable();
ffffffffc0202bde:	a63fd0ef          	jal	ra,ffffffffc0200640 <intr_enable>
ffffffffc0202be2:	b56d                	j	ffffffffc0202a8c <pmm_init+0x510>
        intr_disable();
ffffffffc0202be4:	a63fd0ef          	jal	ra,ffffffffc0200646 <intr_disable>
ffffffffc0202be8:	000bb783          	ld	a5,0(s7)
ffffffffc0202bec:	4585                	li	a1,1
ffffffffc0202bee:	8556                	mv	a0,s5
ffffffffc0202bf0:	739c                	ld	a5,32(a5)
ffffffffc0202bf2:	9782                	jalr	a5
        intr_enable();
ffffffffc0202bf4:	a4dfd0ef          	jal	ra,ffffffffc0200640 <intr_enable>
ffffffffc0202bf8:	b59d                	j	ffffffffc0202a5e <pmm_init+0x4e2>
        assert(PTE_ADDR(*ptep) == i);
ffffffffc0202bfa:	00005697          	auipc	a3,0x5
ffffffffc0202bfe:	de668693          	addi	a3,a3,-538 # ffffffffc02079e0 <default_pmm_manager+0x560>
ffffffffc0202c02:	00004617          	auipc	a2,0x4
ffffffffc0202c06:	1e660613          	addi	a2,a2,486 # ffffffffc0206de8 <commands+0x450>
ffffffffc0202c0a:	23000593          	li	a1,560
ffffffffc0202c0e:	00005517          	auipc	a0,0x5
ffffffffc0202c12:	9c250513          	addi	a0,a0,-1598 # ffffffffc02075d0 <default_pmm_manager+0x150>
ffffffffc0202c16:	865fd0ef          	jal	ra,ffffffffc020047a <__panic>
        assert((ptep = get_pte(boot_pgdir, (uintptr_t)KADDR(i), 0)) != NULL);
ffffffffc0202c1a:	00005697          	auipc	a3,0x5
ffffffffc0202c1e:	d8668693          	addi	a3,a3,-634 # ffffffffc02079a0 <default_pmm_manager+0x520>
ffffffffc0202c22:	00004617          	auipc	a2,0x4
ffffffffc0202c26:	1c660613          	addi	a2,a2,454 # ffffffffc0206de8 <commands+0x450>
ffffffffc0202c2a:	22f00593          	li	a1,559
ffffffffc0202c2e:	00005517          	auipc	a0,0x5
ffffffffc0202c32:	9a250513          	addi	a0,a0,-1630 # ffffffffc02075d0 <default_pmm_manager+0x150>
ffffffffc0202c36:	845fd0ef          	jal	ra,ffffffffc020047a <__panic>
ffffffffc0202c3a:	86a2                	mv	a3,s0
ffffffffc0202c3c:	00005617          	auipc	a2,0x5
ffffffffc0202c40:	87c60613          	addi	a2,a2,-1924 # ffffffffc02074b8 <default_pmm_manager+0x38>
ffffffffc0202c44:	22f00593          	li	a1,559
ffffffffc0202c48:	00005517          	auipc	a0,0x5
ffffffffc0202c4c:	98850513          	addi	a0,a0,-1656 # ffffffffc02075d0 <default_pmm_manager+0x150>
ffffffffc0202c50:	82bfd0ef          	jal	ra,ffffffffc020047a <__panic>
ffffffffc0202c54:	854ff0ef          	jal	ra,ffffffffc0201ca8 <pa2page.part.0>
    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * (npage - nbase));
ffffffffc0202c58:	00005617          	auipc	a2,0x5
ffffffffc0202c5c:	90860613          	addi	a2,a2,-1784 # ffffffffc0207560 <default_pmm_manager+0xe0>
ffffffffc0202c60:	07f00593          	li	a1,127
ffffffffc0202c64:	00005517          	auipc	a0,0x5
ffffffffc0202c68:	96c50513          	addi	a0,a0,-1684 # ffffffffc02075d0 <default_pmm_manager+0x150>
ffffffffc0202c6c:	80ffd0ef          	jal	ra,ffffffffc020047a <__panic>
    boot_cr3 = PADDR(boot_pgdir);
ffffffffc0202c70:	00005617          	auipc	a2,0x5
ffffffffc0202c74:	8f060613          	addi	a2,a2,-1808 # ffffffffc0207560 <default_pmm_manager+0xe0>
ffffffffc0202c78:	0c100593          	li	a1,193
ffffffffc0202c7c:	00005517          	auipc	a0,0x5
ffffffffc0202c80:	95450513          	addi	a0,a0,-1708 # ffffffffc02075d0 <default_pmm_manager+0x150>
ffffffffc0202c84:	ff6fd0ef          	jal	ra,ffffffffc020047a <__panic>
    assert(boot_pgdir != NULL && (uint32_t)PGOFF(boot_pgdir) == 0);
ffffffffc0202c88:	00005697          	auipc	a3,0x5
ffffffffc0202c8c:	a5068693          	addi	a3,a3,-1456 # ffffffffc02076d8 <default_pmm_manager+0x258>
ffffffffc0202c90:	00004617          	auipc	a2,0x4
ffffffffc0202c94:	15860613          	addi	a2,a2,344 # ffffffffc0206de8 <commands+0x450>
ffffffffc0202c98:	1f300593          	li	a1,499
ffffffffc0202c9c:	00005517          	auipc	a0,0x5
ffffffffc0202ca0:	93450513          	addi	a0,a0,-1740 # ffffffffc02075d0 <default_pmm_manager+0x150>
ffffffffc0202ca4:	fd6fd0ef          	jal	ra,ffffffffc020047a <__panic>
    assert(npage <= KERNTOP / PGSIZE);
ffffffffc0202ca8:	00005697          	auipc	a3,0x5
ffffffffc0202cac:	a1068693          	addi	a3,a3,-1520 # ffffffffc02076b8 <default_pmm_manager+0x238>
ffffffffc0202cb0:	00004617          	auipc	a2,0x4
ffffffffc0202cb4:	13860613          	addi	a2,a2,312 # ffffffffc0206de8 <commands+0x450>
ffffffffc0202cb8:	1f200593          	li	a1,498
ffffffffc0202cbc:	00005517          	auipc	a0,0x5
ffffffffc0202cc0:	91450513          	addi	a0,a0,-1772 # ffffffffc02075d0 <default_pmm_manager+0x150>
ffffffffc0202cc4:	fb6fd0ef          	jal	ra,ffffffffc020047a <__panic>
ffffffffc0202cc8:	ffdfe0ef          	jal	ra,ffffffffc0201cc4 <pte2page.part.0>
    assert((ptep = get_pte(boot_pgdir, 0x0, 0)) != NULL);
ffffffffc0202ccc:	00005697          	auipc	a3,0x5
ffffffffc0202cd0:	a9c68693          	addi	a3,a3,-1380 # ffffffffc0207768 <default_pmm_manager+0x2e8>
ffffffffc0202cd4:	00004617          	auipc	a2,0x4
ffffffffc0202cd8:	11460613          	addi	a2,a2,276 # ffffffffc0206de8 <commands+0x450>
ffffffffc0202cdc:	1fb00593          	li	a1,507
ffffffffc0202ce0:	00005517          	auipc	a0,0x5
ffffffffc0202ce4:	8f050513          	addi	a0,a0,-1808 # ffffffffc02075d0 <default_pmm_manager+0x150>
ffffffffc0202ce8:	f92fd0ef          	jal	ra,ffffffffc020047a <__panic>
    assert(page_insert(boot_pgdir, p1, 0x0, 0) == 0);
ffffffffc0202cec:	00005697          	auipc	a3,0x5
ffffffffc0202cf0:	a4c68693          	addi	a3,a3,-1460 # ffffffffc0207738 <default_pmm_manager+0x2b8>
ffffffffc0202cf4:	00004617          	auipc	a2,0x4
ffffffffc0202cf8:	0f460613          	addi	a2,a2,244 # ffffffffc0206de8 <commands+0x450>
ffffffffc0202cfc:	1f800593          	li	a1,504
ffffffffc0202d00:	00005517          	auipc	a0,0x5
ffffffffc0202d04:	8d050513          	addi	a0,a0,-1840 # ffffffffc02075d0 <default_pmm_manager+0x150>
ffffffffc0202d08:	f72fd0ef          	jal	ra,ffffffffc020047a <__panic>
    assert(get_page(boot_pgdir, 0x0, NULL) == NULL);
ffffffffc0202d0c:	00005697          	auipc	a3,0x5
ffffffffc0202d10:	a0468693          	addi	a3,a3,-1532 # ffffffffc0207710 <default_pmm_manager+0x290>
ffffffffc0202d14:	00004617          	auipc	a2,0x4
ffffffffc0202d18:	0d460613          	addi	a2,a2,212 # ffffffffc0206de8 <commands+0x450>
ffffffffc0202d1c:	1f400593          	li	a1,500
ffffffffc0202d20:	00005517          	auipc	a0,0x5
ffffffffc0202d24:	8b050513          	addi	a0,a0,-1872 # ffffffffc02075d0 <default_pmm_manager+0x150>
ffffffffc0202d28:	f52fd0ef          	jal	ra,ffffffffc020047a <__panic>
    assert(page_insert(boot_pgdir, p2, PGSIZE, PTE_U | PTE_W) == 0);
ffffffffc0202d2c:	00005697          	auipc	a3,0x5
ffffffffc0202d30:	ac468693          	addi	a3,a3,-1340 # ffffffffc02077f0 <default_pmm_manager+0x370>
ffffffffc0202d34:	00004617          	auipc	a2,0x4
ffffffffc0202d38:	0b460613          	addi	a2,a2,180 # ffffffffc0206de8 <commands+0x450>
ffffffffc0202d3c:	20400593          	li	a1,516
ffffffffc0202d40:	00005517          	auipc	a0,0x5
ffffffffc0202d44:	89050513          	addi	a0,a0,-1904 # ffffffffc02075d0 <default_pmm_manager+0x150>
ffffffffc0202d48:	f32fd0ef          	jal	ra,ffffffffc020047a <__panic>
    assert(page_ref(p2) == 1);
ffffffffc0202d4c:	00005697          	auipc	a3,0x5
ffffffffc0202d50:	b4468693          	addi	a3,a3,-1212 # ffffffffc0207890 <default_pmm_manager+0x410>
ffffffffc0202d54:	00004617          	auipc	a2,0x4
ffffffffc0202d58:	09460613          	addi	a2,a2,148 # ffffffffc0206de8 <commands+0x450>
ffffffffc0202d5c:	20900593          	li	a1,521
ffffffffc0202d60:	00005517          	auipc	a0,0x5
ffffffffc0202d64:	87050513          	addi	a0,a0,-1936 # ffffffffc02075d0 <default_pmm_manager+0x150>
ffffffffc0202d68:	f12fd0ef          	jal	ra,ffffffffc020047a <__panic>
    assert(get_pte(boot_pgdir, PGSIZE, 0) == ptep);
ffffffffc0202d6c:	00005697          	auipc	a3,0x5
ffffffffc0202d70:	a5c68693          	addi	a3,a3,-1444 # ffffffffc02077c8 <default_pmm_manager+0x348>
ffffffffc0202d74:	00004617          	auipc	a2,0x4
ffffffffc0202d78:	07460613          	addi	a2,a2,116 # ffffffffc0206de8 <commands+0x450>
ffffffffc0202d7c:	20100593          	li	a1,513
ffffffffc0202d80:	00005517          	auipc	a0,0x5
ffffffffc0202d84:	85050513          	addi	a0,a0,-1968 # ffffffffc02075d0 <default_pmm_manager+0x150>
ffffffffc0202d88:	ef2fd0ef          	jal	ra,ffffffffc020047a <__panic>
    ptep = (pte_t *)KADDR(PDE_ADDR(ptep[0])) + 1;
ffffffffc0202d8c:	86d6                	mv	a3,s5
ffffffffc0202d8e:	00004617          	auipc	a2,0x4
ffffffffc0202d92:	72a60613          	addi	a2,a2,1834 # ffffffffc02074b8 <default_pmm_manager+0x38>
ffffffffc0202d96:	20000593          	li	a1,512
ffffffffc0202d9a:	00005517          	auipc	a0,0x5
ffffffffc0202d9e:	83650513          	addi	a0,a0,-1994 # ffffffffc02075d0 <default_pmm_manager+0x150>
ffffffffc0202da2:	ed8fd0ef          	jal	ra,ffffffffc020047a <__panic>
    assert((ptep = get_pte(boot_pgdir, PGSIZE, 0)) != NULL);
ffffffffc0202da6:	00005697          	auipc	a3,0x5
ffffffffc0202daa:	a8268693          	addi	a3,a3,-1406 # ffffffffc0207828 <default_pmm_manager+0x3a8>
ffffffffc0202dae:	00004617          	auipc	a2,0x4
ffffffffc0202db2:	03a60613          	addi	a2,a2,58 # ffffffffc0206de8 <commands+0x450>
ffffffffc0202db6:	20e00593          	li	a1,526
ffffffffc0202dba:	00005517          	auipc	a0,0x5
ffffffffc0202dbe:	81650513          	addi	a0,a0,-2026 # ffffffffc02075d0 <default_pmm_manager+0x150>
ffffffffc0202dc2:	eb8fd0ef          	jal	ra,ffffffffc020047a <__panic>
    assert(page_ref(p2) == 0);
ffffffffc0202dc6:	00005697          	auipc	a3,0x5
ffffffffc0202dca:	b2a68693          	addi	a3,a3,-1238 # ffffffffc02078f0 <default_pmm_manager+0x470>
ffffffffc0202dce:	00004617          	auipc	a2,0x4
ffffffffc0202dd2:	01a60613          	addi	a2,a2,26 # ffffffffc0206de8 <commands+0x450>
ffffffffc0202dd6:	20d00593          	li	a1,525
ffffffffc0202dda:	00004517          	auipc	a0,0x4
ffffffffc0202dde:	7f650513          	addi	a0,a0,2038 # ffffffffc02075d0 <default_pmm_manager+0x150>
ffffffffc0202de2:	e98fd0ef          	jal	ra,ffffffffc020047a <__panic>
    assert(page_ref(p1) == 2);
ffffffffc0202de6:	00005697          	auipc	a3,0x5
ffffffffc0202dea:	af268693          	addi	a3,a3,-1294 # ffffffffc02078d8 <default_pmm_manager+0x458>
ffffffffc0202dee:	00004617          	auipc	a2,0x4
ffffffffc0202df2:	ffa60613          	addi	a2,a2,-6 # ffffffffc0206de8 <commands+0x450>
ffffffffc0202df6:	20c00593          	li	a1,524
ffffffffc0202dfa:	00004517          	auipc	a0,0x4
ffffffffc0202dfe:	7d650513          	addi	a0,a0,2006 # ffffffffc02075d0 <default_pmm_manager+0x150>
ffffffffc0202e02:	e78fd0ef          	jal	ra,ffffffffc020047a <__panic>
    assert(page_insert(boot_pgdir, p1, PGSIZE, 0) == 0);
ffffffffc0202e06:	00005697          	auipc	a3,0x5
ffffffffc0202e0a:	aa268693          	addi	a3,a3,-1374 # ffffffffc02078a8 <default_pmm_manager+0x428>
ffffffffc0202e0e:	00004617          	auipc	a2,0x4
ffffffffc0202e12:	fda60613          	addi	a2,a2,-38 # ffffffffc0206de8 <commands+0x450>
ffffffffc0202e16:	20b00593          	li	a1,523
ffffffffc0202e1a:	00004517          	auipc	a0,0x4
ffffffffc0202e1e:	7b650513          	addi	a0,a0,1974 # ffffffffc02075d0 <default_pmm_manager+0x150>
ffffffffc0202e22:	e58fd0ef          	jal	ra,ffffffffc020047a <__panic>
    assert(page_insert(boot_pgdir, p, 0x100 + PGSIZE, PTE_W | PTE_R) == 0);
ffffffffc0202e26:	00005697          	auipc	a3,0x5
ffffffffc0202e2a:	c3a68693          	addi	a3,a3,-966 # ffffffffc0207a60 <default_pmm_manager+0x5e0>
ffffffffc0202e2e:	00004617          	auipc	a2,0x4
ffffffffc0202e32:	fba60613          	addi	a2,a2,-70 # ffffffffc0206de8 <commands+0x450>
ffffffffc0202e36:	23a00593          	li	a1,570
ffffffffc0202e3a:	00004517          	auipc	a0,0x4
ffffffffc0202e3e:	79650513          	addi	a0,a0,1942 # ffffffffc02075d0 <default_pmm_manager+0x150>
ffffffffc0202e42:	e38fd0ef          	jal	ra,ffffffffc020047a <__panic>
    assert(boot_pgdir[0] & PTE_U);
ffffffffc0202e46:	00005697          	auipc	a3,0x5
ffffffffc0202e4a:	a3268693          	addi	a3,a3,-1486 # ffffffffc0207878 <default_pmm_manager+0x3f8>
ffffffffc0202e4e:	00004617          	auipc	a2,0x4
ffffffffc0202e52:	f9a60613          	addi	a2,a2,-102 # ffffffffc0206de8 <commands+0x450>
ffffffffc0202e56:	20800593          	li	a1,520
ffffffffc0202e5a:	00004517          	auipc	a0,0x4
ffffffffc0202e5e:	77650513          	addi	a0,a0,1910 # ffffffffc02075d0 <default_pmm_manager+0x150>
ffffffffc0202e62:	e18fd0ef          	jal	ra,ffffffffc020047a <__panic>
    assert(*ptep & PTE_W);
ffffffffc0202e66:	00005697          	auipc	a3,0x5
ffffffffc0202e6a:	a0268693          	addi	a3,a3,-1534 # ffffffffc0207868 <default_pmm_manager+0x3e8>
ffffffffc0202e6e:	00004617          	auipc	a2,0x4
ffffffffc0202e72:	f7a60613          	addi	a2,a2,-134 # ffffffffc0206de8 <commands+0x450>
ffffffffc0202e76:	20700593          	li	a1,519
ffffffffc0202e7a:	00004517          	auipc	a0,0x4
ffffffffc0202e7e:	75650513          	addi	a0,a0,1878 # ffffffffc02075d0 <default_pmm_manager+0x150>
ffffffffc0202e82:	df8fd0ef          	jal	ra,ffffffffc020047a <__panic>
    assert(nr_free_store==nr_free_pages());
ffffffffc0202e86:	00005697          	auipc	a3,0x5
ffffffffc0202e8a:	ada68693          	addi	a3,a3,-1318 # ffffffffc0207960 <default_pmm_manager+0x4e0>
ffffffffc0202e8e:	00004617          	auipc	a2,0x4
ffffffffc0202e92:	f5a60613          	addi	a2,a2,-166 # ffffffffc0206de8 <commands+0x450>
ffffffffc0202e96:	24b00593          	li	a1,587
ffffffffc0202e9a:	00004517          	auipc	a0,0x4
ffffffffc0202e9e:	73650513          	addi	a0,a0,1846 # ffffffffc02075d0 <default_pmm_manager+0x150>
ffffffffc0202ea2:	dd8fd0ef          	jal	ra,ffffffffc020047a <__panic>
    assert(*ptep & PTE_U);
ffffffffc0202ea6:	00005697          	auipc	a3,0x5
ffffffffc0202eaa:	9b268693          	addi	a3,a3,-1614 # ffffffffc0207858 <default_pmm_manager+0x3d8>
ffffffffc0202eae:	00004617          	auipc	a2,0x4
ffffffffc0202eb2:	f3a60613          	addi	a2,a2,-198 # ffffffffc0206de8 <commands+0x450>
ffffffffc0202eb6:	20600593          	li	a1,518
ffffffffc0202eba:	00004517          	auipc	a0,0x4
ffffffffc0202ebe:	71650513          	addi	a0,a0,1814 # ffffffffc02075d0 <default_pmm_manager+0x150>
ffffffffc0202ec2:	db8fd0ef          	jal	ra,ffffffffc020047a <__panic>
    assert(page_ref(p1) == 1);
ffffffffc0202ec6:	00005697          	auipc	a3,0x5
ffffffffc0202eca:	8ea68693          	addi	a3,a3,-1814 # ffffffffc02077b0 <default_pmm_manager+0x330>
ffffffffc0202ece:	00004617          	auipc	a2,0x4
ffffffffc0202ed2:	f1a60613          	addi	a2,a2,-230 # ffffffffc0206de8 <commands+0x450>
ffffffffc0202ed6:	21300593          	li	a1,531
ffffffffc0202eda:	00004517          	auipc	a0,0x4
ffffffffc0202ede:	6f650513          	addi	a0,a0,1782 # ffffffffc02075d0 <default_pmm_manager+0x150>
ffffffffc0202ee2:	d98fd0ef          	jal	ra,ffffffffc020047a <__panic>
    assert((*ptep & PTE_U) == 0);
ffffffffc0202ee6:	00005697          	auipc	a3,0x5
ffffffffc0202eea:	a2268693          	addi	a3,a3,-1502 # ffffffffc0207908 <default_pmm_manager+0x488>
ffffffffc0202eee:	00004617          	auipc	a2,0x4
ffffffffc0202ef2:	efa60613          	addi	a2,a2,-262 # ffffffffc0206de8 <commands+0x450>
ffffffffc0202ef6:	21000593          	li	a1,528
ffffffffc0202efa:	00004517          	auipc	a0,0x4
ffffffffc0202efe:	6d650513          	addi	a0,a0,1750 # ffffffffc02075d0 <default_pmm_manager+0x150>
ffffffffc0202f02:	d78fd0ef          	jal	ra,ffffffffc020047a <__panic>
    assert(pte2page(*ptep) == p1);
ffffffffc0202f06:	00005697          	auipc	a3,0x5
ffffffffc0202f0a:	89268693          	addi	a3,a3,-1902 # ffffffffc0207798 <default_pmm_manager+0x318>
ffffffffc0202f0e:	00004617          	auipc	a2,0x4
ffffffffc0202f12:	eda60613          	addi	a2,a2,-294 # ffffffffc0206de8 <commands+0x450>
ffffffffc0202f16:	20f00593          	li	a1,527
ffffffffc0202f1a:	00004517          	auipc	a0,0x4
ffffffffc0202f1e:	6b650513          	addi	a0,a0,1718 # ffffffffc02075d0 <default_pmm_manager+0x150>
ffffffffc0202f22:	d58fd0ef          	jal	ra,ffffffffc020047a <__panic>
    return KADDR(page2pa(page));
ffffffffc0202f26:	00004617          	auipc	a2,0x4
ffffffffc0202f2a:	59260613          	addi	a2,a2,1426 # ffffffffc02074b8 <default_pmm_manager+0x38>
ffffffffc0202f2e:	06900593          	li	a1,105
ffffffffc0202f32:	00004517          	auipc	a0,0x4
ffffffffc0202f36:	5ae50513          	addi	a0,a0,1454 # ffffffffc02074e0 <default_pmm_manager+0x60>
ffffffffc0202f3a:	d40fd0ef          	jal	ra,ffffffffc020047a <__panic>
    assert(page_ref(pde2page(boot_pgdir[0])) == 1);
ffffffffc0202f3e:	00005697          	auipc	a3,0x5
ffffffffc0202f42:	9fa68693          	addi	a3,a3,-1542 # ffffffffc0207938 <default_pmm_manager+0x4b8>
ffffffffc0202f46:	00004617          	auipc	a2,0x4
ffffffffc0202f4a:	ea260613          	addi	a2,a2,-350 # ffffffffc0206de8 <commands+0x450>
ffffffffc0202f4e:	21a00593          	li	a1,538
ffffffffc0202f52:	00004517          	auipc	a0,0x4
ffffffffc0202f56:	67e50513          	addi	a0,a0,1662 # ffffffffc02075d0 <default_pmm_manager+0x150>
ffffffffc0202f5a:	d20fd0ef          	jal	ra,ffffffffc020047a <__panic>
    assert(page_ref(p2) == 0);
ffffffffc0202f5e:	00005697          	auipc	a3,0x5
ffffffffc0202f62:	99268693          	addi	a3,a3,-1646 # ffffffffc02078f0 <default_pmm_manager+0x470>
ffffffffc0202f66:	00004617          	auipc	a2,0x4
ffffffffc0202f6a:	e8260613          	addi	a2,a2,-382 # ffffffffc0206de8 <commands+0x450>
ffffffffc0202f6e:	21800593          	li	a1,536
ffffffffc0202f72:	00004517          	auipc	a0,0x4
ffffffffc0202f76:	65e50513          	addi	a0,a0,1630 # ffffffffc02075d0 <default_pmm_manager+0x150>
ffffffffc0202f7a:	d00fd0ef          	jal	ra,ffffffffc020047a <__panic>
    assert(page_ref(p1) == 0);
ffffffffc0202f7e:	00005697          	auipc	a3,0x5
ffffffffc0202f82:	9a268693          	addi	a3,a3,-1630 # ffffffffc0207920 <default_pmm_manager+0x4a0>
ffffffffc0202f86:	00004617          	auipc	a2,0x4
ffffffffc0202f8a:	e6260613          	addi	a2,a2,-414 # ffffffffc0206de8 <commands+0x450>
ffffffffc0202f8e:	21700593          	li	a1,535
ffffffffc0202f92:	00004517          	auipc	a0,0x4
ffffffffc0202f96:	63e50513          	addi	a0,a0,1598 # ffffffffc02075d0 <default_pmm_manager+0x150>
ffffffffc0202f9a:	ce0fd0ef          	jal	ra,ffffffffc020047a <__panic>
    assert(page_ref(p2) == 0);
ffffffffc0202f9e:	00005697          	auipc	a3,0x5
ffffffffc0202fa2:	95268693          	addi	a3,a3,-1710 # ffffffffc02078f0 <default_pmm_manager+0x470>
ffffffffc0202fa6:	00004617          	auipc	a2,0x4
ffffffffc0202faa:	e4260613          	addi	a2,a2,-446 # ffffffffc0206de8 <commands+0x450>
ffffffffc0202fae:	21400593          	li	a1,532
ffffffffc0202fb2:	00004517          	auipc	a0,0x4
ffffffffc0202fb6:	61e50513          	addi	a0,a0,1566 # ffffffffc02075d0 <default_pmm_manager+0x150>
ffffffffc0202fba:	cc0fd0ef          	jal	ra,ffffffffc020047a <__panic>
    assert(page_ref(p) == 1);
ffffffffc0202fbe:	00005697          	auipc	a3,0x5
ffffffffc0202fc2:	a8a68693          	addi	a3,a3,-1398 # ffffffffc0207a48 <default_pmm_manager+0x5c8>
ffffffffc0202fc6:	00004617          	auipc	a2,0x4
ffffffffc0202fca:	e2260613          	addi	a2,a2,-478 # ffffffffc0206de8 <commands+0x450>
ffffffffc0202fce:	23900593          	li	a1,569
ffffffffc0202fd2:	00004517          	auipc	a0,0x4
ffffffffc0202fd6:	5fe50513          	addi	a0,a0,1534 # ffffffffc02075d0 <default_pmm_manager+0x150>
ffffffffc0202fda:	ca0fd0ef          	jal	ra,ffffffffc020047a <__panic>
    assert(page_insert(boot_pgdir, p, 0x100, PTE_W | PTE_R) == 0);
ffffffffc0202fde:	00005697          	auipc	a3,0x5
ffffffffc0202fe2:	a3268693          	addi	a3,a3,-1486 # ffffffffc0207a10 <default_pmm_manager+0x590>
ffffffffc0202fe6:	00004617          	auipc	a2,0x4
ffffffffc0202fea:	e0260613          	addi	a2,a2,-510 # ffffffffc0206de8 <commands+0x450>
ffffffffc0202fee:	23800593          	li	a1,568
ffffffffc0202ff2:	00004517          	auipc	a0,0x4
ffffffffc0202ff6:	5de50513          	addi	a0,a0,1502 # ffffffffc02075d0 <default_pmm_manager+0x150>
ffffffffc0202ffa:	c80fd0ef          	jal	ra,ffffffffc020047a <__panic>
    assert(boot_pgdir[0] == 0);
ffffffffc0202ffe:	00005697          	auipc	a3,0x5
ffffffffc0203002:	9fa68693          	addi	a3,a3,-1542 # ffffffffc02079f8 <default_pmm_manager+0x578>
ffffffffc0203006:	00004617          	auipc	a2,0x4
ffffffffc020300a:	de260613          	addi	a2,a2,-542 # ffffffffc0206de8 <commands+0x450>
ffffffffc020300e:	23400593          	li	a1,564
ffffffffc0203012:	00004517          	auipc	a0,0x4
ffffffffc0203016:	5be50513          	addi	a0,a0,1470 # ffffffffc02075d0 <default_pmm_manager+0x150>
ffffffffc020301a:	c60fd0ef          	jal	ra,ffffffffc020047a <__panic>
    assert(nr_free_store==nr_free_pages());
ffffffffc020301e:	00005697          	auipc	a3,0x5
ffffffffc0203022:	94268693          	addi	a3,a3,-1726 # ffffffffc0207960 <default_pmm_manager+0x4e0>
ffffffffc0203026:	00004617          	auipc	a2,0x4
ffffffffc020302a:	dc260613          	addi	a2,a2,-574 # ffffffffc0206de8 <commands+0x450>
ffffffffc020302e:	22200593          	li	a1,546
ffffffffc0203032:	00004517          	auipc	a0,0x4
ffffffffc0203036:	59e50513          	addi	a0,a0,1438 # ffffffffc02075d0 <default_pmm_manager+0x150>
ffffffffc020303a:	c40fd0ef          	jal	ra,ffffffffc020047a <__panic>
    assert(pte2page(*ptep) == p1);
ffffffffc020303e:	00004697          	auipc	a3,0x4
ffffffffc0203042:	75a68693          	addi	a3,a3,1882 # ffffffffc0207798 <default_pmm_manager+0x318>
ffffffffc0203046:	00004617          	auipc	a2,0x4
ffffffffc020304a:	da260613          	addi	a2,a2,-606 # ffffffffc0206de8 <commands+0x450>
ffffffffc020304e:	1fc00593          	li	a1,508
ffffffffc0203052:	00004517          	auipc	a0,0x4
ffffffffc0203056:	57e50513          	addi	a0,a0,1406 # ffffffffc02075d0 <default_pmm_manager+0x150>
ffffffffc020305a:	c20fd0ef          	jal	ra,ffffffffc020047a <__panic>
    ptep = (pte_t *)KADDR(PDE_ADDR(boot_pgdir[0]));
ffffffffc020305e:	00004617          	auipc	a2,0x4
ffffffffc0203062:	45a60613          	addi	a2,a2,1114 # ffffffffc02074b8 <default_pmm_manager+0x38>
ffffffffc0203066:	1ff00593          	li	a1,511
ffffffffc020306a:	00004517          	auipc	a0,0x4
ffffffffc020306e:	56650513          	addi	a0,a0,1382 # ffffffffc02075d0 <default_pmm_manager+0x150>
ffffffffc0203072:	c08fd0ef          	jal	ra,ffffffffc020047a <__panic>
    assert(page_ref(p1) == 1);
ffffffffc0203076:	00004697          	auipc	a3,0x4
ffffffffc020307a:	73a68693          	addi	a3,a3,1850 # ffffffffc02077b0 <default_pmm_manager+0x330>
ffffffffc020307e:	00004617          	auipc	a2,0x4
ffffffffc0203082:	d6a60613          	addi	a2,a2,-662 # ffffffffc0206de8 <commands+0x450>
ffffffffc0203086:	1fd00593          	li	a1,509
ffffffffc020308a:	00004517          	auipc	a0,0x4
ffffffffc020308e:	54650513          	addi	a0,a0,1350 # ffffffffc02075d0 <default_pmm_manager+0x150>
ffffffffc0203092:	be8fd0ef          	jal	ra,ffffffffc020047a <__panic>
    assert((ptep = get_pte(boot_pgdir, PGSIZE, 0)) != NULL);
ffffffffc0203096:	00004697          	auipc	a3,0x4
ffffffffc020309a:	79268693          	addi	a3,a3,1938 # ffffffffc0207828 <default_pmm_manager+0x3a8>
ffffffffc020309e:	00004617          	auipc	a2,0x4
ffffffffc02030a2:	d4a60613          	addi	a2,a2,-694 # ffffffffc0206de8 <commands+0x450>
ffffffffc02030a6:	20500593          	li	a1,517
ffffffffc02030aa:	00004517          	auipc	a0,0x4
ffffffffc02030ae:	52650513          	addi	a0,a0,1318 # ffffffffc02075d0 <default_pmm_manager+0x150>
ffffffffc02030b2:	bc8fd0ef          	jal	ra,ffffffffc020047a <__panic>
    assert(strlen((const char *)0x100) == 0);
ffffffffc02030b6:	00005697          	auipc	a3,0x5
ffffffffc02030ba:	a5268693          	addi	a3,a3,-1454 # ffffffffc0207b08 <default_pmm_manager+0x688>
ffffffffc02030be:	00004617          	auipc	a2,0x4
ffffffffc02030c2:	d2a60613          	addi	a2,a2,-726 # ffffffffc0206de8 <commands+0x450>
ffffffffc02030c6:	24200593          	li	a1,578
ffffffffc02030ca:	00004517          	auipc	a0,0x4
ffffffffc02030ce:	50650513          	addi	a0,a0,1286 # ffffffffc02075d0 <default_pmm_manager+0x150>
ffffffffc02030d2:	ba8fd0ef          	jal	ra,ffffffffc020047a <__panic>
    assert(strcmp((void *)0x100, (void *)(0x100 + PGSIZE)) == 0);
ffffffffc02030d6:	00005697          	auipc	a3,0x5
ffffffffc02030da:	9fa68693          	addi	a3,a3,-1542 # ffffffffc0207ad0 <default_pmm_manager+0x650>
ffffffffc02030de:	00004617          	auipc	a2,0x4
ffffffffc02030e2:	d0a60613          	addi	a2,a2,-758 # ffffffffc0206de8 <commands+0x450>
ffffffffc02030e6:	23f00593          	li	a1,575
ffffffffc02030ea:	00004517          	auipc	a0,0x4
ffffffffc02030ee:	4e650513          	addi	a0,a0,1254 # ffffffffc02075d0 <default_pmm_manager+0x150>
ffffffffc02030f2:	b88fd0ef          	jal	ra,ffffffffc020047a <__panic>
    assert(page_ref(p) == 2);
ffffffffc02030f6:	00005697          	auipc	a3,0x5
ffffffffc02030fa:	9aa68693          	addi	a3,a3,-1622 # ffffffffc0207aa0 <default_pmm_manager+0x620>
ffffffffc02030fe:	00004617          	auipc	a2,0x4
ffffffffc0203102:	cea60613          	addi	a2,a2,-790 # ffffffffc0206de8 <commands+0x450>
ffffffffc0203106:	23b00593          	li	a1,571
ffffffffc020310a:	00004517          	auipc	a0,0x4
ffffffffc020310e:	4c650513          	addi	a0,a0,1222 # ffffffffc02075d0 <default_pmm_manager+0x150>
ffffffffc0203112:	b68fd0ef          	jal	ra,ffffffffc020047a <__panic>

ffffffffc0203116 <copy_range>:
               bool share) {
ffffffffc0203116:	7119                	addi	sp,sp,-128
    assert(start % PGSIZE == 0 && end % PGSIZE == 0);
ffffffffc0203118:	00d667b3          	or	a5,a2,a3
               bool share) {
ffffffffc020311c:	fc86                	sd	ra,120(sp)
ffffffffc020311e:	f8a2                	sd	s0,112(sp)
ffffffffc0203120:	f4a6                	sd	s1,104(sp)
ffffffffc0203122:	f0ca                	sd	s2,96(sp)
ffffffffc0203124:	ecce                	sd	s3,88(sp)
ffffffffc0203126:	e8d2                	sd	s4,80(sp)
ffffffffc0203128:	e4d6                	sd	s5,72(sp)
ffffffffc020312a:	e0da                	sd	s6,64(sp)
ffffffffc020312c:	fc5e                	sd	s7,56(sp)
ffffffffc020312e:	f862                	sd	s8,48(sp)
ffffffffc0203130:	f466                	sd	s9,40(sp)
ffffffffc0203132:	f06a                	sd	s10,32(sp)
ffffffffc0203134:	ec6e                	sd	s11,24(sp)
    assert(start % PGSIZE == 0 && end % PGSIZE == 0);
ffffffffc0203136:	17d2                	slli	a5,a5,0x34
               bool share) {
ffffffffc0203138:	e03a                	sd	a4,0(sp)
    assert(start % PGSIZE == 0 && end % PGSIZE == 0);
ffffffffc020313a:	24079c63          	bnez	a5,ffffffffc0203392 <copy_range+0x27c>
    assert(USER_ACCESS(start, end));
ffffffffc020313e:	002007b7          	lui	a5,0x200
ffffffffc0203142:	8432                	mv	s0,a2
ffffffffc0203144:	1ef66e63          	bltu	a2,a5,ffffffffc0203340 <copy_range+0x22a>
ffffffffc0203148:	8936                	mv	s2,a3
ffffffffc020314a:	1ed67b63          	bgeu	a2,a3,ffffffffc0203340 <copy_range+0x22a>
ffffffffc020314e:	4785                	li	a5,1
ffffffffc0203150:	07fe                	slli	a5,a5,0x1f
ffffffffc0203152:	1ed7e763          	bltu	a5,a3,ffffffffc0203340 <copy_range+0x22a>
ffffffffc0203156:	5afd                	li	s5,-1
ffffffffc0203158:	8a2a                	mv	s4,a0
ffffffffc020315a:	84ae                	mv	s1,a1
        start += PGSIZE;
ffffffffc020315c:	6985                	lui	s3,0x1
    if (PPN(pa) >= npage) {
ffffffffc020315e:	000afc17          	auipc	s8,0xaf
ffffffffc0203162:	74ac0c13          	addi	s8,s8,1866 # ffffffffc02b28a8 <npage>
    return &pages[PPN(pa) - nbase];
ffffffffc0203166:	000afb97          	auipc	s7,0xaf
ffffffffc020316a:	74ab8b93          	addi	s7,s7,1866 # ffffffffc02b28b0 <pages>
    return page - pages + nbase;
ffffffffc020316e:	00080b37          	lui	s6,0x80
    return KADDR(page2pa(page));
ffffffffc0203172:	00cada93          	srli	s5,s5,0xc
ffffffffc0203176:	000afd17          	auipc	s10,0xaf
ffffffffc020317a:	74ad0d13          	addi	s10,s10,1866 # ffffffffc02b28c0 <va_pa_offset>
        pte_t *ptep = get_pte(from, start, 0), *nptep;
ffffffffc020317e:	4601                	li	a2,0
ffffffffc0203180:	85a2                	mv	a1,s0
ffffffffc0203182:	8526                	mv	a0,s1
ffffffffc0203184:	c69fe0ef          	jal	ra,ffffffffc0201dec <get_pte>
ffffffffc0203188:	8caa                	mv	s9,a0
        if (ptep == NULL) {
ffffffffc020318a:	c569                	beqz	a0,ffffffffc0203254 <copy_range+0x13e>
        if (*ptep & PTE_V) {
ffffffffc020318c:	6118                	ld	a4,0(a0)
ffffffffc020318e:	8b05                	andi	a4,a4,1
ffffffffc0203190:	e705                	bnez	a4,ffffffffc02031b8 <copy_range+0xa2>
        start += PGSIZE;
ffffffffc0203192:	944e                	add	s0,s0,s3
    } while (start != 0 && start < end);
ffffffffc0203194:	ff2465e3          	bltu	s0,s2,ffffffffc020317e <copy_range+0x68>
    return 0;
ffffffffc0203198:	4501                	li	a0,0
}
ffffffffc020319a:	70e6                	ld	ra,120(sp)
ffffffffc020319c:	7446                	ld	s0,112(sp)
ffffffffc020319e:	74a6                	ld	s1,104(sp)
ffffffffc02031a0:	7906                	ld	s2,96(sp)
ffffffffc02031a2:	69e6                	ld	s3,88(sp)
ffffffffc02031a4:	6a46                	ld	s4,80(sp)
ffffffffc02031a6:	6aa6                	ld	s5,72(sp)
ffffffffc02031a8:	6b06                	ld	s6,64(sp)
ffffffffc02031aa:	7be2                	ld	s7,56(sp)
ffffffffc02031ac:	7c42                	ld	s8,48(sp)
ffffffffc02031ae:	7ca2                	ld	s9,40(sp)
ffffffffc02031b0:	7d02                	ld	s10,32(sp)
ffffffffc02031b2:	6de2                	ld	s11,24(sp)
ffffffffc02031b4:	6109                	addi	sp,sp,128
ffffffffc02031b6:	8082                	ret
            if ((nptep = get_pte(to, start, 1)) == NULL) {
ffffffffc02031b8:	4605                	li	a2,1
ffffffffc02031ba:	85a2                	mv	a1,s0
ffffffffc02031bc:	8552                	mv	a0,s4
ffffffffc02031be:	c2ffe0ef          	jal	ra,ffffffffc0201dec <get_pte>
ffffffffc02031c2:	10050463          	beqz	a0,ffffffffc02032ca <copy_range+0x1b4>
            uint32_t perm = (*ptep & PTE_USER);
ffffffffc02031c6:	000cb783          	ld	a5,0(s9)
    if (!(pte & PTE_V)) {
ffffffffc02031ca:	0017f713          	andi	a4,a5,1
ffffffffc02031ce:	00078c9b          	sext.w	s9,a5
ffffffffc02031d2:	0e070e63          	beqz	a4,ffffffffc02032ce <copy_range+0x1b8>
    if (PPN(pa) >= npage) {
ffffffffc02031d6:	000c3603          	ld	a2,0(s8)
    return pa2page(PTE_ADDR(pte));
ffffffffc02031da:	078a                	slli	a5,a5,0x2
ffffffffc02031dc:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc02031de:	18c7f163          	bgeu	a5,a2,ffffffffc0203360 <copy_range+0x24a>
    return &pages[PPN(pa) - nbase];
ffffffffc02031e2:	000bb703          	ld	a4,0(s7)
ffffffffc02031e6:	fff806b7          	lui	a3,0xfff80
ffffffffc02031ea:	97b6                	add	a5,a5,a3
ffffffffc02031ec:	079a                	slli	a5,a5,0x6
ffffffffc02031ee:	00f70db3          	add	s11,a4,a5
            if (share) {
ffffffffc02031f2:	6702                	ld	a4,0(sp)
ffffffffc02031f4:	cb35                	beqz	a4,ffffffffc0203268 <copy_range+0x152>
    return page - pages + nbase;
ffffffffc02031f6:	8799                	srai	a5,a5,0x6
ffffffffc02031f8:	97da                	add	a5,a5,s6
    return KADDR(page2pa(page));
ffffffffc02031fa:	0157f5b3          	and	a1,a5,s5
    return page2ppn(page) << PGSHIFT;
ffffffffc02031fe:	07b2                	slli	a5,a5,0xc
    return KADDR(page2pa(page));
ffffffffc0203200:	16c5fc63          	bgeu	a1,a2,ffffffffc0203378 <copy_range+0x262>
ffffffffc0203204:	000d3583          	ld	a1,0(s10)
                cprintf("Sharing the page 0x%x\n", page2kva(page));
ffffffffc0203208:	00005517          	auipc	a0,0x5
ffffffffc020320c:	94850513          	addi	a0,a0,-1720 # ffffffffc0207b50 <default_pmm_manager+0x6d0>
                page_insert(from, page, start, perm & ~PTE_W);      // 设置父进程的页面为只读
ffffffffc0203210:	01bcfc93          	andi	s9,s9,27
                cprintf("Sharing the page 0x%x\n", page2kva(page));
ffffffffc0203214:	95be                	add	a1,a1,a5
ffffffffc0203216:	f6bfc0ef          	jal	ra,ffffffffc0200180 <cprintf>
                page_insert(from, page, start, perm & ~PTE_W);      // 设置父进程的页面为只读
ffffffffc020321a:	86e6                	mv	a3,s9
ffffffffc020321c:	8622                	mv	a2,s0
ffffffffc020321e:	85ee                	mv	a1,s11
ffffffffc0203220:	8526                	mv	a0,s1
ffffffffc0203222:	a64ff0ef          	jal	ra,ffffffffc0202486 <page_insert>
                ret = page_insert(to, page, start, perm & ~PTE_W);  // 插入父进程的页到子进程的页目录表
ffffffffc0203226:	86e6                	mv	a3,s9
ffffffffc0203228:	8622                	mv	a2,s0
ffffffffc020322a:	85ee                	mv	a1,s11
ffffffffc020322c:	8552                	mv	a0,s4
ffffffffc020322e:	a58ff0ef          	jal	ra,ffffffffc0202486 <page_insert>
            assert(ret == 0);
ffffffffc0203232:	d125                	beqz	a0,ffffffffc0203192 <copy_range+0x7c>
ffffffffc0203234:	00005697          	auipc	a3,0x5
ffffffffc0203238:	95468693          	addi	a3,a3,-1708 # ffffffffc0207b88 <default_pmm_manager+0x708>
ffffffffc020323c:	00004617          	auipc	a2,0x4
ffffffffc0203240:	bac60613          	addi	a2,a2,-1108 # ffffffffc0206de8 <commands+0x450>
ffffffffc0203244:	19400593          	li	a1,404
ffffffffc0203248:	00004517          	auipc	a0,0x4
ffffffffc020324c:	38850513          	addi	a0,a0,904 # ffffffffc02075d0 <default_pmm_manager+0x150>
ffffffffc0203250:	a2afd0ef          	jal	ra,ffffffffc020047a <__panic>
            start = ROUNDDOWN(start + PTSIZE, PTSIZE);
ffffffffc0203254:	00200637          	lui	a2,0x200
ffffffffc0203258:	9432                	add	s0,s0,a2
ffffffffc020325a:	ffe00637          	lui	a2,0xffe00
ffffffffc020325e:	8c71                	and	s0,s0,a2
    } while (start != 0 && start < end);
ffffffffc0203260:	dc05                	beqz	s0,ffffffffc0203198 <copy_range+0x82>
ffffffffc0203262:	f1246ee3          	bltu	s0,s2,ffffffffc020317e <copy_range+0x68>
ffffffffc0203266:	bf0d                	j	ffffffffc0203198 <copy_range+0x82>
                struct Page *npage = alloc_page();
ffffffffc0203268:	4505                	li	a0,1
ffffffffc020326a:	a77fe0ef          	jal	ra,ffffffffc0201ce0 <alloc_pages>
ffffffffc020326e:	882a                	mv	a6,a0
                assert(page != NULL);
ffffffffc0203270:	0a0d8863          	beqz	s11,ffffffffc0203320 <copy_range+0x20a>
                assert(npage != NULL);
ffffffffc0203274:	c551                	beqz	a0,ffffffffc0203300 <copy_range+0x1ea>
    return page - pages + nbase;
ffffffffc0203276:	000bb783          	ld	a5,0(s7)
    return KADDR(page2pa(page));
ffffffffc020327a:	000c3603          	ld	a2,0(s8)
    return page - pages + nbase;
ffffffffc020327e:	40fd8733          	sub	a4,s11,a5
ffffffffc0203282:	8719                	srai	a4,a4,0x6
ffffffffc0203284:	975a                	add	a4,a4,s6
    return KADDR(page2pa(page));
ffffffffc0203286:	015775b3          	and	a1,a4,s5
    return page2ppn(page) << PGSHIFT;
ffffffffc020328a:	0732                	slli	a4,a4,0xc
    return KADDR(page2pa(page));
ffffffffc020328c:	04c5fd63          	bgeu	a1,a2,ffffffffc02032e6 <copy_range+0x1d0>
    return page - pages + nbase;
ffffffffc0203290:	40f507b3          	sub	a5,a0,a5
ffffffffc0203294:	8799                	srai	a5,a5,0x6
    return KADDR(page2pa(page));
ffffffffc0203296:	000d3503          	ld	a0,0(s10)
    return page - pages + nbase;
ffffffffc020329a:	97da                	add	a5,a5,s6
    return KADDR(page2pa(page));
ffffffffc020329c:	0157f8b3          	and	a7,a5,s5
ffffffffc02032a0:	00a705b3          	add	a1,a4,a0
    return page2ppn(page) << PGSHIFT;
ffffffffc02032a4:	07b2                	slli	a5,a5,0xc
    return KADDR(page2pa(page));
ffffffffc02032a6:	0cc8f963          	bgeu	a7,a2,ffffffffc0203378 <copy_range+0x262>
                memcpy(dst_kvaddr, src_kvaddr, PGSIZE);
ffffffffc02032aa:	6605                	lui	a2,0x1
ffffffffc02032ac:	953e                	add	a0,a0,a5
ffffffffc02032ae:	e442                	sd	a6,8(sp)
ffffffffc02032b0:	466030ef          	jal	ra,ffffffffc0206716 <memcpy>
                ret = page_insert(to, npage, start, perm);
ffffffffc02032b4:	6822                	ld	a6,8(sp)
ffffffffc02032b6:	01fcf693          	andi	a3,s9,31
ffffffffc02032ba:	8622                	mv	a2,s0
ffffffffc02032bc:	85c2                	mv	a1,a6
ffffffffc02032be:	8552                	mv	a0,s4
ffffffffc02032c0:	9c6ff0ef          	jal	ra,ffffffffc0202486 <page_insert>
            assert(ret == 0);
ffffffffc02032c4:	ec0507e3          	beqz	a0,ffffffffc0203192 <copy_range+0x7c>
ffffffffc02032c8:	b7b5                	j	ffffffffc0203234 <copy_range+0x11e>
                return -E_NO_MEM;
ffffffffc02032ca:	5571                	li	a0,-4
ffffffffc02032cc:	b5f9                	j	ffffffffc020319a <copy_range+0x84>
        panic("pte2page called with invalid pte");
ffffffffc02032ce:	00004617          	auipc	a2,0x4
ffffffffc02032d2:	2da60613          	addi	a2,a2,730 # ffffffffc02075a8 <default_pmm_manager+0x128>
ffffffffc02032d6:	07400593          	li	a1,116
ffffffffc02032da:	00004517          	auipc	a0,0x4
ffffffffc02032de:	20650513          	addi	a0,a0,518 # ffffffffc02074e0 <default_pmm_manager+0x60>
ffffffffc02032e2:	998fd0ef          	jal	ra,ffffffffc020047a <__panic>
    return KADDR(page2pa(page));
ffffffffc02032e6:	86ba                	mv	a3,a4
ffffffffc02032e8:	00004617          	auipc	a2,0x4
ffffffffc02032ec:	1d060613          	addi	a2,a2,464 # ffffffffc02074b8 <default_pmm_manager+0x38>
ffffffffc02032f0:	06900593          	li	a1,105
ffffffffc02032f4:	00004517          	auipc	a0,0x4
ffffffffc02032f8:	1ec50513          	addi	a0,a0,492 # ffffffffc02074e0 <default_pmm_manager+0x60>
ffffffffc02032fc:	97efd0ef          	jal	ra,ffffffffc020047a <__panic>
                assert(npage != NULL);
ffffffffc0203300:	00005697          	auipc	a3,0x5
ffffffffc0203304:	87868693          	addi	a3,a3,-1928 # ffffffffc0207b78 <default_pmm_manager+0x6f8>
ffffffffc0203308:	00004617          	auipc	a2,0x4
ffffffffc020330c:	ae060613          	addi	a2,a2,-1312 # ffffffffc0206de8 <commands+0x450>
ffffffffc0203310:	17a00593          	li	a1,378
ffffffffc0203314:	00004517          	auipc	a0,0x4
ffffffffc0203318:	2bc50513          	addi	a0,a0,700 # ffffffffc02075d0 <default_pmm_manager+0x150>
ffffffffc020331c:	95efd0ef          	jal	ra,ffffffffc020047a <__panic>
                assert(page != NULL);
ffffffffc0203320:	00005697          	auipc	a3,0x5
ffffffffc0203324:	84868693          	addi	a3,a3,-1976 # ffffffffc0207b68 <default_pmm_manager+0x6e8>
ffffffffc0203328:	00004617          	auipc	a2,0x4
ffffffffc020332c:	ac060613          	addi	a2,a2,-1344 # ffffffffc0206de8 <commands+0x450>
ffffffffc0203330:	17900593          	li	a1,377
ffffffffc0203334:	00004517          	auipc	a0,0x4
ffffffffc0203338:	29c50513          	addi	a0,a0,668 # ffffffffc02075d0 <default_pmm_manager+0x150>
ffffffffc020333c:	93efd0ef          	jal	ra,ffffffffc020047a <__panic>
    assert(USER_ACCESS(start, end));
ffffffffc0203340:	00004697          	auipc	a3,0x4
ffffffffc0203344:	2d068693          	addi	a3,a3,720 # ffffffffc0207610 <default_pmm_manager+0x190>
ffffffffc0203348:	00004617          	auipc	a2,0x4
ffffffffc020334c:	aa060613          	addi	a2,a2,-1376 # ffffffffc0206de8 <commands+0x450>
ffffffffc0203350:	15e00593          	li	a1,350
ffffffffc0203354:	00004517          	auipc	a0,0x4
ffffffffc0203358:	27c50513          	addi	a0,a0,636 # ffffffffc02075d0 <default_pmm_manager+0x150>
ffffffffc020335c:	91efd0ef          	jal	ra,ffffffffc020047a <__panic>
        panic("pa2page called with invalid pa");
ffffffffc0203360:	00004617          	auipc	a2,0x4
ffffffffc0203364:	22860613          	addi	a2,a2,552 # ffffffffc0207588 <default_pmm_manager+0x108>
ffffffffc0203368:	06200593          	li	a1,98
ffffffffc020336c:	00004517          	auipc	a0,0x4
ffffffffc0203370:	17450513          	addi	a0,a0,372 # ffffffffc02074e0 <default_pmm_manager+0x60>
ffffffffc0203374:	906fd0ef          	jal	ra,ffffffffc020047a <__panic>
    return KADDR(page2pa(page));
ffffffffc0203378:	86be                	mv	a3,a5
ffffffffc020337a:	00004617          	auipc	a2,0x4
ffffffffc020337e:	13e60613          	addi	a2,a2,318 # ffffffffc02074b8 <default_pmm_manager+0x38>
ffffffffc0203382:	06900593          	li	a1,105
ffffffffc0203386:	00004517          	auipc	a0,0x4
ffffffffc020338a:	15a50513          	addi	a0,a0,346 # ffffffffc02074e0 <default_pmm_manager+0x60>
ffffffffc020338e:	8ecfd0ef          	jal	ra,ffffffffc020047a <__panic>
    assert(start % PGSIZE == 0 && end % PGSIZE == 0);
ffffffffc0203392:	00004697          	auipc	a3,0x4
ffffffffc0203396:	24e68693          	addi	a3,a3,590 # ffffffffc02075e0 <default_pmm_manager+0x160>
ffffffffc020339a:	00004617          	auipc	a2,0x4
ffffffffc020339e:	a4e60613          	addi	a2,a2,-1458 # ffffffffc0206de8 <commands+0x450>
ffffffffc02033a2:	15d00593          	li	a1,349
ffffffffc02033a6:	00004517          	auipc	a0,0x4
ffffffffc02033aa:	22a50513          	addi	a0,a0,554 # ffffffffc02075d0 <default_pmm_manager+0x150>
ffffffffc02033ae:	8ccfd0ef          	jal	ra,ffffffffc020047a <__panic>

ffffffffc02033b2 <tlb_invalidate>:
    asm volatile("sfence.vma %0" : : "r"(la));
ffffffffc02033b2:	12058073          	sfence.vma	a1
}
ffffffffc02033b6:	8082                	ret

ffffffffc02033b8 <pgdir_alloc_page>:
struct Page *pgdir_alloc_page(pde_t *pgdir, uintptr_t la, uint32_t perm) {
ffffffffc02033b8:	7179                	addi	sp,sp,-48
ffffffffc02033ba:	e84a                	sd	s2,16(sp)
ffffffffc02033bc:	892a                	mv	s2,a0
    struct Page *page = alloc_page();
ffffffffc02033be:	4505                	li	a0,1
struct Page *pgdir_alloc_page(pde_t *pgdir, uintptr_t la, uint32_t perm) {
ffffffffc02033c0:	f022                	sd	s0,32(sp)
ffffffffc02033c2:	ec26                	sd	s1,24(sp)
ffffffffc02033c4:	e44e                	sd	s3,8(sp)
ffffffffc02033c6:	f406                	sd	ra,40(sp)
ffffffffc02033c8:	84ae                	mv	s1,a1
ffffffffc02033ca:	89b2                	mv	s3,a2
    struct Page *page = alloc_page();
ffffffffc02033cc:	915fe0ef          	jal	ra,ffffffffc0201ce0 <alloc_pages>
ffffffffc02033d0:	842a                	mv	s0,a0
    if (page != NULL) {
ffffffffc02033d2:	cd05                	beqz	a0,ffffffffc020340a <pgdir_alloc_page+0x52>
        if (page_insert(pgdir, page, la, perm) != 0) {
ffffffffc02033d4:	85aa                	mv	a1,a0
ffffffffc02033d6:	86ce                	mv	a3,s3
ffffffffc02033d8:	8626                	mv	a2,s1
ffffffffc02033da:	854a                	mv	a0,s2
ffffffffc02033dc:	8aaff0ef          	jal	ra,ffffffffc0202486 <page_insert>
ffffffffc02033e0:	ed0d                	bnez	a0,ffffffffc020341a <pgdir_alloc_page+0x62>
        if (swap_init_ok) {
ffffffffc02033e2:	000af797          	auipc	a5,0xaf
ffffffffc02033e6:	4f67a783          	lw	a5,1270(a5) # ffffffffc02b28d8 <swap_init_ok>
ffffffffc02033ea:	c385                	beqz	a5,ffffffffc020340a <pgdir_alloc_page+0x52>
            if (check_mm_struct != NULL) {
ffffffffc02033ec:	000af517          	auipc	a0,0xaf
ffffffffc02033f0:	4f453503          	ld	a0,1268(a0) # ffffffffc02b28e0 <check_mm_struct>
ffffffffc02033f4:	c919                	beqz	a0,ffffffffc020340a <pgdir_alloc_page+0x52>
                swap_map_swappable(check_mm_struct, la, page, 0);
ffffffffc02033f6:	4681                	li	a3,0
ffffffffc02033f8:	8622                	mv	a2,s0
ffffffffc02033fa:	85a6                	mv	a1,s1
ffffffffc02033fc:	7e4000ef          	jal	ra,ffffffffc0203be0 <swap_map_swappable>
                assert(page_ref(page) == 1);
ffffffffc0203400:	4018                	lw	a4,0(s0)
                page->pra_vaddr = la;
ffffffffc0203402:	fc04                	sd	s1,56(s0)
                assert(page_ref(page) == 1);
ffffffffc0203404:	4785                	li	a5,1
ffffffffc0203406:	04f71663          	bne	a4,a5,ffffffffc0203452 <pgdir_alloc_page+0x9a>
}
ffffffffc020340a:	70a2                	ld	ra,40(sp)
ffffffffc020340c:	8522                	mv	a0,s0
ffffffffc020340e:	7402                	ld	s0,32(sp)
ffffffffc0203410:	64e2                	ld	s1,24(sp)
ffffffffc0203412:	6942                	ld	s2,16(sp)
ffffffffc0203414:	69a2                	ld	s3,8(sp)
ffffffffc0203416:	6145                	addi	sp,sp,48
ffffffffc0203418:	8082                	ret
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc020341a:	100027f3          	csrr	a5,sstatus
ffffffffc020341e:	8b89                	andi	a5,a5,2
ffffffffc0203420:	eb99                	bnez	a5,ffffffffc0203436 <pgdir_alloc_page+0x7e>
        pmm_manager->free_pages(base, n);
ffffffffc0203422:	000af797          	auipc	a5,0xaf
ffffffffc0203426:	4967b783          	ld	a5,1174(a5) # ffffffffc02b28b8 <pmm_manager>
ffffffffc020342a:	739c                	ld	a5,32(a5)
ffffffffc020342c:	8522                	mv	a0,s0
ffffffffc020342e:	4585                	li	a1,1
ffffffffc0203430:	9782                	jalr	a5
            return NULL;
ffffffffc0203432:	4401                	li	s0,0
ffffffffc0203434:	bfd9                	j	ffffffffc020340a <pgdir_alloc_page+0x52>
        intr_disable();
ffffffffc0203436:	a10fd0ef          	jal	ra,ffffffffc0200646 <intr_disable>
        pmm_manager->free_pages(base, n);
ffffffffc020343a:	000af797          	auipc	a5,0xaf
ffffffffc020343e:	47e7b783          	ld	a5,1150(a5) # ffffffffc02b28b8 <pmm_manager>
ffffffffc0203442:	739c                	ld	a5,32(a5)
ffffffffc0203444:	8522                	mv	a0,s0
ffffffffc0203446:	4585                	li	a1,1
ffffffffc0203448:	9782                	jalr	a5
            return NULL;
ffffffffc020344a:	4401                	li	s0,0
        intr_enable();
ffffffffc020344c:	9f4fd0ef          	jal	ra,ffffffffc0200640 <intr_enable>
ffffffffc0203450:	bf6d                	j	ffffffffc020340a <pgdir_alloc_page+0x52>
                assert(page_ref(page) == 1);
ffffffffc0203452:	00004697          	auipc	a3,0x4
ffffffffc0203456:	74668693          	addi	a3,a3,1862 # ffffffffc0207b98 <default_pmm_manager+0x718>
ffffffffc020345a:	00004617          	auipc	a2,0x4
ffffffffc020345e:	98e60613          	addi	a2,a2,-1650 # ffffffffc0206de8 <commands+0x450>
ffffffffc0203462:	1d300593          	li	a1,467
ffffffffc0203466:	00004517          	auipc	a0,0x4
ffffffffc020346a:	16a50513          	addi	a0,a0,362 # ffffffffc02075d0 <default_pmm_manager+0x150>
ffffffffc020346e:	80cfd0ef          	jal	ra,ffffffffc020047a <__panic>

ffffffffc0203472 <pa2page.part.0>:
pa2page(uintptr_t pa) {
ffffffffc0203472:	1141                	addi	sp,sp,-16
        panic("pa2page called with invalid pa");
ffffffffc0203474:	00004617          	auipc	a2,0x4
ffffffffc0203478:	11460613          	addi	a2,a2,276 # ffffffffc0207588 <default_pmm_manager+0x108>
ffffffffc020347c:	06200593          	li	a1,98
ffffffffc0203480:	00004517          	auipc	a0,0x4
ffffffffc0203484:	06050513          	addi	a0,a0,96 # ffffffffc02074e0 <default_pmm_manager+0x60>
pa2page(uintptr_t pa) {
ffffffffc0203488:	e406                	sd	ra,8(sp)
        panic("pa2page called with invalid pa");
ffffffffc020348a:	ff1fc0ef          	jal	ra,ffffffffc020047a <__panic>

ffffffffc020348e <swap_init>:

static void check_swap(void);

int
swap_init(void)
{
ffffffffc020348e:	7135                	addi	sp,sp,-160
ffffffffc0203490:	ed06                	sd	ra,152(sp)
ffffffffc0203492:	e922                	sd	s0,144(sp)
ffffffffc0203494:	e526                	sd	s1,136(sp)
ffffffffc0203496:	e14a                	sd	s2,128(sp)
ffffffffc0203498:	fcce                	sd	s3,120(sp)
ffffffffc020349a:	f8d2                	sd	s4,112(sp)
ffffffffc020349c:	f4d6                	sd	s5,104(sp)
ffffffffc020349e:	f0da                	sd	s6,96(sp)
ffffffffc02034a0:	ecde                	sd	s7,88(sp)
ffffffffc02034a2:	e8e2                	sd	s8,80(sp)
ffffffffc02034a4:	e4e6                	sd	s9,72(sp)
ffffffffc02034a6:	e0ea                	sd	s10,64(sp)
ffffffffc02034a8:	fc6e                	sd	s11,56(sp)
     swapfs_init();
ffffffffc02034aa:	05d010ef          	jal	ra,ffffffffc0204d06 <swapfs_init>

     // Since the IDE is faked, it can only store 7 pages at most to pass the test
     if (!(7 <= max_swap_offset &&
ffffffffc02034ae:	000af697          	auipc	a3,0xaf
ffffffffc02034b2:	41a6b683          	ld	a3,1050(a3) # ffffffffc02b28c8 <max_swap_offset>
ffffffffc02034b6:	010007b7          	lui	a5,0x1000
ffffffffc02034ba:	ff968713          	addi	a4,a3,-7
ffffffffc02034be:	17e1                	addi	a5,a5,-8
ffffffffc02034c0:	42e7e663          	bltu	a5,a4,ffffffffc02038ec <swap_init+0x45e>
        max_swap_offset < MAX_SWAP_OFFSET_LIMIT)) {
        panic("bad max_swap_offset %08x.\n", max_swap_offset);
     }
     

     sm = &swap_manager_fifo;
ffffffffc02034c4:	000a4797          	auipc	a5,0xa4
ffffffffc02034c8:	e9c78793          	addi	a5,a5,-356 # ffffffffc02a7360 <swap_manager_fifo>
     int r = sm->init();
ffffffffc02034cc:	6798                	ld	a4,8(a5)
     sm = &swap_manager_fifo;
ffffffffc02034ce:	000afb97          	auipc	s7,0xaf
ffffffffc02034d2:	402b8b93          	addi	s7,s7,1026 # ffffffffc02b28d0 <sm>
ffffffffc02034d6:	00fbb023          	sd	a5,0(s7)
     int r = sm->init();
ffffffffc02034da:	9702                	jalr	a4
ffffffffc02034dc:	892a                	mv	s2,a0
     
     if (r == 0)
ffffffffc02034de:	c10d                	beqz	a0,ffffffffc0203500 <swap_init+0x72>
          cprintf("SWAP: manager = %s\n", sm->name);
          check_swap();
     }

     return r;
}
ffffffffc02034e0:	60ea                	ld	ra,152(sp)
ffffffffc02034e2:	644a                	ld	s0,144(sp)
ffffffffc02034e4:	64aa                	ld	s1,136(sp)
ffffffffc02034e6:	79e6                	ld	s3,120(sp)
ffffffffc02034e8:	7a46                	ld	s4,112(sp)
ffffffffc02034ea:	7aa6                	ld	s5,104(sp)
ffffffffc02034ec:	7b06                	ld	s6,96(sp)
ffffffffc02034ee:	6be6                	ld	s7,88(sp)
ffffffffc02034f0:	6c46                	ld	s8,80(sp)
ffffffffc02034f2:	6ca6                	ld	s9,72(sp)
ffffffffc02034f4:	6d06                	ld	s10,64(sp)
ffffffffc02034f6:	7de2                	ld	s11,56(sp)
ffffffffc02034f8:	854a                	mv	a0,s2
ffffffffc02034fa:	690a                	ld	s2,128(sp)
ffffffffc02034fc:	610d                	addi	sp,sp,160
ffffffffc02034fe:	8082                	ret
          cprintf("SWAP: manager = %s\n", sm->name);
ffffffffc0203500:	000bb783          	ld	a5,0(s7)
ffffffffc0203504:	00004517          	auipc	a0,0x4
ffffffffc0203508:	6dc50513          	addi	a0,a0,1756 # ffffffffc0207be0 <default_pmm_manager+0x760>
    return listelm->next;
ffffffffc020350c:	000ab417          	auipc	s0,0xab
ffffffffc0203510:	2a440413          	addi	s0,s0,676 # ffffffffc02ae7b0 <free_area>
ffffffffc0203514:	638c                	ld	a1,0(a5)
          swap_init_ok = 1;
ffffffffc0203516:	4785                	li	a5,1
ffffffffc0203518:	000af717          	auipc	a4,0xaf
ffffffffc020351c:	3cf72023          	sw	a5,960(a4) # ffffffffc02b28d8 <swap_init_ok>
          cprintf("SWAP: manager = %s\n", sm->name);
ffffffffc0203520:	c61fc0ef          	jal	ra,ffffffffc0200180 <cprintf>
ffffffffc0203524:	641c                	ld	a5,8(s0)

static void
check_swap(void)
{
    //backup mem env
     int ret, count = 0, total = 0, i;
ffffffffc0203526:	4d01                	li	s10,0
ffffffffc0203528:	4d81                	li	s11,0
     list_entry_t *le = &free_list;
     while ((le = list_next(le)) != &free_list) {
ffffffffc020352a:	34878163          	beq	a5,s0,ffffffffc020386c <swap_init+0x3de>
    return (((*(volatile unsigned long *)addr) >> nr) & 1);
ffffffffc020352e:	ff07b703          	ld	a4,-16(a5)
        struct Page *p = le2page(le, page_link);
        assert(PageProperty(p));
ffffffffc0203532:	8b09                	andi	a4,a4,2
ffffffffc0203534:	32070e63          	beqz	a4,ffffffffc0203870 <swap_init+0x3e2>
        count ++, total += p->property;
ffffffffc0203538:	ff87a703          	lw	a4,-8(a5)
ffffffffc020353c:	679c                	ld	a5,8(a5)
ffffffffc020353e:	2d85                	addiw	s11,s11,1
ffffffffc0203540:	01a70d3b          	addw	s10,a4,s10
     while ((le = list_next(le)) != &free_list) {
ffffffffc0203544:	fe8795e3          	bne	a5,s0,ffffffffc020352e <swap_init+0xa0>
     }
     assert(total == nr_free_pages());
ffffffffc0203548:	84ea                	mv	s1,s10
ffffffffc020354a:	869fe0ef          	jal	ra,ffffffffc0201db2 <nr_free_pages>
ffffffffc020354e:	42951763          	bne	a0,s1,ffffffffc020397c <swap_init+0x4ee>
     cprintf("BEGIN check_swap: count %d, total %d\n",count,total);
ffffffffc0203552:	866a                	mv	a2,s10
ffffffffc0203554:	85ee                	mv	a1,s11
ffffffffc0203556:	00004517          	auipc	a0,0x4
ffffffffc020355a:	6a250513          	addi	a0,a0,1698 # ffffffffc0207bf8 <default_pmm_manager+0x778>
ffffffffc020355e:	c23fc0ef          	jal	ra,ffffffffc0200180 <cprintf>
     
     //now we set the phy pages env     
     struct mm_struct *mm = mm_create();
ffffffffc0203562:	457000ef          	jal	ra,ffffffffc02041b8 <mm_create>
ffffffffc0203566:	8aaa                	mv	s5,a0
     assert(mm != NULL);
ffffffffc0203568:	46050a63          	beqz	a0,ffffffffc02039dc <swap_init+0x54e>

     extern struct mm_struct *check_mm_struct;
     assert(check_mm_struct == NULL);
ffffffffc020356c:	000af797          	auipc	a5,0xaf
ffffffffc0203570:	37478793          	addi	a5,a5,884 # ffffffffc02b28e0 <check_mm_struct>
ffffffffc0203574:	6398                	ld	a4,0(a5)
ffffffffc0203576:	3e071363          	bnez	a4,ffffffffc020395c <swap_init+0x4ce>

     check_mm_struct = mm;

     pde_t *pgdir = mm->pgdir = boot_pgdir;
ffffffffc020357a:	000af717          	auipc	a4,0xaf
ffffffffc020357e:	32670713          	addi	a4,a4,806 # ffffffffc02b28a0 <boot_pgdir>
ffffffffc0203582:	00073b03          	ld	s6,0(a4)
     check_mm_struct = mm;
ffffffffc0203586:	e388                	sd	a0,0(a5)
     assert(pgdir[0] == 0);
ffffffffc0203588:	000b3783          	ld	a5,0(s6) # 80000 <_binary_obj___user_exit_out_size+0x74ed0>
     pde_t *pgdir = mm->pgdir = boot_pgdir;
ffffffffc020358c:	01653c23          	sd	s6,24(a0)
     assert(pgdir[0] == 0);
ffffffffc0203590:	42079663          	bnez	a5,ffffffffc02039bc <swap_init+0x52e>

     struct vma_struct *vma = vma_create(BEING_CHECK_VALID_VADDR, CHECK_VALID_VADDR, VM_WRITE | VM_READ);
ffffffffc0203594:	6599                	lui	a1,0x6
ffffffffc0203596:	460d                	li	a2,3
ffffffffc0203598:	6505                	lui	a0,0x1
ffffffffc020359a:	467000ef          	jal	ra,ffffffffc0204200 <vma_create>
ffffffffc020359e:	85aa                	mv	a1,a0
     assert(vma != NULL);
ffffffffc02035a0:	52050a63          	beqz	a0,ffffffffc0203ad4 <swap_init+0x646>

     insert_vma_struct(mm, vma);
ffffffffc02035a4:	8556                	mv	a0,s5
ffffffffc02035a6:	4c9000ef          	jal	ra,ffffffffc020426e <insert_vma_struct>

     //setup the temp Page Table vaddr 0~4MB
     cprintf("setup Page Table for vaddr 0X1000, so alloc a page\n");
ffffffffc02035aa:	00004517          	auipc	a0,0x4
ffffffffc02035ae:	6be50513          	addi	a0,a0,1726 # ffffffffc0207c68 <default_pmm_manager+0x7e8>
ffffffffc02035b2:	bcffc0ef          	jal	ra,ffffffffc0200180 <cprintf>
     pte_t *temp_ptep=NULL;
     temp_ptep = get_pte(mm->pgdir, BEING_CHECK_VALID_VADDR, 1);
ffffffffc02035b6:	018ab503          	ld	a0,24(s5)
ffffffffc02035ba:	4605                	li	a2,1
ffffffffc02035bc:	6585                	lui	a1,0x1
ffffffffc02035be:	82ffe0ef          	jal	ra,ffffffffc0201dec <get_pte>
     assert(temp_ptep!= NULL);
ffffffffc02035c2:	4c050963          	beqz	a0,ffffffffc0203a94 <swap_init+0x606>
     cprintf("setup Page Table vaddr 0~4MB OVER!\n");
ffffffffc02035c6:	00004517          	auipc	a0,0x4
ffffffffc02035ca:	6f250513          	addi	a0,a0,1778 # ffffffffc0207cb8 <default_pmm_manager+0x838>
ffffffffc02035ce:	000ab497          	auipc	s1,0xab
ffffffffc02035d2:	21a48493          	addi	s1,s1,538 # ffffffffc02ae7e8 <check_rp>
ffffffffc02035d6:	babfc0ef          	jal	ra,ffffffffc0200180 <cprintf>
     
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
ffffffffc02035da:	000ab997          	auipc	s3,0xab
ffffffffc02035de:	22e98993          	addi	s3,s3,558 # ffffffffc02ae808 <swap_in_seq_no>
     cprintf("setup Page Table vaddr 0~4MB OVER!\n");
ffffffffc02035e2:	8a26                	mv	s4,s1
          check_rp[i] = alloc_page();
ffffffffc02035e4:	4505                	li	a0,1
ffffffffc02035e6:	efafe0ef          	jal	ra,ffffffffc0201ce0 <alloc_pages>
ffffffffc02035ea:	00aa3023          	sd	a0,0(s4)
          assert(check_rp[i] != NULL );
ffffffffc02035ee:	2c050f63          	beqz	a0,ffffffffc02038cc <swap_init+0x43e>
ffffffffc02035f2:	651c                	ld	a5,8(a0)
          assert(!PageProperty(check_rp[i]));
ffffffffc02035f4:	8b89                	andi	a5,a5,2
ffffffffc02035f6:	34079363          	bnez	a5,ffffffffc020393c <swap_init+0x4ae>
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
ffffffffc02035fa:	0a21                	addi	s4,s4,8
ffffffffc02035fc:	ff3a14e3          	bne	s4,s3,ffffffffc02035e4 <swap_init+0x156>
     }
     list_entry_t free_list_store = free_list;
ffffffffc0203600:	601c                	ld	a5,0(s0)
     assert(list_empty(&free_list));
     
     //assert(alloc_page() == NULL);
     
     unsigned int nr_free_store = nr_free;
     nr_free = 0;
ffffffffc0203602:	000aba17          	auipc	s4,0xab
ffffffffc0203606:	1e6a0a13          	addi	s4,s4,486 # ffffffffc02ae7e8 <check_rp>
    elm->prev = elm->next = elm;
ffffffffc020360a:	e000                	sd	s0,0(s0)
     list_entry_t free_list_store = free_list;
ffffffffc020360c:	ec3e                	sd	a5,24(sp)
ffffffffc020360e:	641c                	ld	a5,8(s0)
ffffffffc0203610:	e400                	sd	s0,8(s0)
ffffffffc0203612:	f03e                	sd	a5,32(sp)
     unsigned int nr_free_store = nr_free;
ffffffffc0203614:	481c                	lw	a5,16(s0)
ffffffffc0203616:	f43e                	sd	a5,40(sp)
     nr_free = 0;
ffffffffc0203618:	000ab797          	auipc	a5,0xab
ffffffffc020361c:	1a07a423          	sw	zero,424(a5) # ffffffffc02ae7c0 <free_area+0x10>
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
        free_pages(check_rp[i],1);
ffffffffc0203620:	000a3503          	ld	a0,0(s4)
ffffffffc0203624:	4585                	li	a1,1
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
ffffffffc0203626:	0a21                	addi	s4,s4,8
        free_pages(check_rp[i],1);
ffffffffc0203628:	f4afe0ef          	jal	ra,ffffffffc0201d72 <free_pages>
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
ffffffffc020362c:	ff3a1ae3          	bne	s4,s3,ffffffffc0203620 <swap_init+0x192>
     }
     assert(nr_free==CHECK_VALID_PHY_PAGE_NUM);
ffffffffc0203630:	01042a03          	lw	s4,16(s0)
ffffffffc0203634:	4791                	li	a5,4
ffffffffc0203636:	42fa1f63          	bne	s4,a5,ffffffffc0203a74 <swap_init+0x5e6>
     
     cprintf("set up init env for check_swap begin!\n");
ffffffffc020363a:	00004517          	auipc	a0,0x4
ffffffffc020363e:	70650513          	addi	a0,a0,1798 # ffffffffc0207d40 <default_pmm_manager+0x8c0>
ffffffffc0203642:	b3ffc0ef          	jal	ra,ffffffffc0200180 <cprintf>
     *(unsigned char *)0x1000 = 0x0a;
ffffffffc0203646:	6705                	lui	a4,0x1
     //setup initial vir_page<->phy_page environment for page relpacement algorithm 

     
     pgfault_num=0;
ffffffffc0203648:	000af797          	auipc	a5,0xaf
ffffffffc020364c:	2a07a023          	sw	zero,672(a5) # ffffffffc02b28e8 <pgfault_num>
     *(unsigned char *)0x1000 = 0x0a;
ffffffffc0203650:	4629                	li	a2,10
ffffffffc0203652:	00c70023          	sb	a2,0(a4) # 1000 <_binary_obj___user_faultread_out_size-0x8bb8>
     assert(pgfault_num==1);
ffffffffc0203656:	000af697          	auipc	a3,0xaf
ffffffffc020365a:	2926a683          	lw	a3,658(a3) # ffffffffc02b28e8 <pgfault_num>
ffffffffc020365e:	4585                	li	a1,1
ffffffffc0203660:	000af797          	auipc	a5,0xaf
ffffffffc0203664:	28878793          	addi	a5,a5,648 # ffffffffc02b28e8 <pgfault_num>
ffffffffc0203668:	54b69663          	bne	a3,a1,ffffffffc0203bb4 <swap_init+0x726>
     *(unsigned char *)0x1010 = 0x0a;
ffffffffc020366c:	00c70823          	sb	a2,16(a4)
     assert(pgfault_num==1);
ffffffffc0203670:	4398                	lw	a4,0(a5)
ffffffffc0203672:	2701                	sext.w	a4,a4
ffffffffc0203674:	3ed71063          	bne	a4,a3,ffffffffc0203a54 <swap_init+0x5c6>
     *(unsigned char *)0x2000 = 0x0b;
ffffffffc0203678:	6689                	lui	a3,0x2
ffffffffc020367a:	462d                	li	a2,11
ffffffffc020367c:	00c68023          	sb	a2,0(a3) # 2000 <_binary_obj___user_faultread_out_size-0x7bb8>
     assert(pgfault_num==2);
ffffffffc0203680:	4398                	lw	a4,0(a5)
ffffffffc0203682:	4589                	li	a1,2
ffffffffc0203684:	2701                	sext.w	a4,a4
ffffffffc0203686:	4ab71763          	bne	a4,a1,ffffffffc0203b34 <swap_init+0x6a6>
     *(unsigned char *)0x2010 = 0x0b;
ffffffffc020368a:	00c68823          	sb	a2,16(a3)
     assert(pgfault_num==2);
ffffffffc020368e:	4394                	lw	a3,0(a5)
ffffffffc0203690:	2681                	sext.w	a3,a3
ffffffffc0203692:	4ce69163          	bne	a3,a4,ffffffffc0203b54 <swap_init+0x6c6>
     *(unsigned char *)0x3000 = 0x0c;
ffffffffc0203696:	668d                	lui	a3,0x3
ffffffffc0203698:	4631                	li	a2,12
ffffffffc020369a:	00c68023          	sb	a2,0(a3) # 3000 <_binary_obj___user_faultread_out_size-0x6bb8>
     assert(pgfault_num==3);
ffffffffc020369e:	4398                	lw	a4,0(a5)
ffffffffc02036a0:	458d                	li	a1,3
ffffffffc02036a2:	2701                	sext.w	a4,a4
ffffffffc02036a4:	4cb71863          	bne	a4,a1,ffffffffc0203b74 <swap_init+0x6e6>
     *(unsigned char *)0x3010 = 0x0c;
ffffffffc02036a8:	00c68823          	sb	a2,16(a3)
     assert(pgfault_num==3);
ffffffffc02036ac:	4394                	lw	a3,0(a5)
ffffffffc02036ae:	2681                	sext.w	a3,a3
ffffffffc02036b0:	4ee69263          	bne	a3,a4,ffffffffc0203b94 <swap_init+0x706>
     *(unsigned char *)0x4000 = 0x0d;
ffffffffc02036b4:	6691                	lui	a3,0x4
ffffffffc02036b6:	4635                	li	a2,13
ffffffffc02036b8:	00c68023          	sb	a2,0(a3) # 4000 <_binary_obj___user_faultread_out_size-0x5bb8>
     assert(pgfault_num==4);
ffffffffc02036bc:	4398                	lw	a4,0(a5)
ffffffffc02036be:	2701                	sext.w	a4,a4
ffffffffc02036c0:	43471a63          	bne	a4,s4,ffffffffc0203af4 <swap_init+0x666>
     *(unsigned char *)0x4010 = 0x0d;
ffffffffc02036c4:	00c68823          	sb	a2,16(a3)
     assert(pgfault_num==4);
ffffffffc02036c8:	439c                	lw	a5,0(a5)
ffffffffc02036ca:	2781                	sext.w	a5,a5
ffffffffc02036cc:	44e79463          	bne	a5,a4,ffffffffc0203b14 <swap_init+0x686>
     
     check_content_set();
     assert( nr_free == 0);         
ffffffffc02036d0:	481c                	lw	a5,16(s0)
ffffffffc02036d2:	2c079563          	bnez	a5,ffffffffc020399c <swap_init+0x50e>
ffffffffc02036d6:	000ab797          	auipc	a5,0xab
ffffffffc02036da:	13278793          	addi	a5,a5,306 # ffffffffc02ae808 <swap_in_seq_no>
ffffffffc02036de:	000ab717          	auipc	a4,0xab
ffffffffc02036e2:	15270713          	addi	a4,a4,338 # ffffffffc02ae830 <swap_out_seq_no>
ffffffffc02036e6:	000ab617          	auipc	a2,0xab
ffffffffc02036ea:	14a60613          	addi	a2,a2,330 # ffffffffc02ae830 <swap_out_seq_no>
     for(i = 0; i<MAX_SEQ_NO ; i++) 
         swap_out_seq_no[i]=swap_in_seq_no[i]=-1;
ffffffffc02036ee:	56fd                	li	a3,-1
ffffffffc02036f0:	c394                	sw	a3,0(a5)
ffffffffc02036f2:	c314                	sw	a3,0(a4)
     for(i = 0; i<MAX_SEQ_NO ; i++) 
ffffffffc02036f4:	0791                	addi	a5,a5,4
ffffffffc02036f6:	0711                	addi	a4,a4,4
ffffffffc02036f8:	fec79ce3          	bne	a5,a2,ffffffffc02036f0 <swap_init+0x262>
ffffffffc02036fc:	000ab717          	auipc	a4,0xab
ffffffffc0203700:	0cc70713          	addi	a4,a4,204 # ffffffffc02ae7c8 <check_ptep>
ffffffffc0203704:	000ab697          	auipc	a3,0xab
ffffffffc0203708:	0e468693          	addi	a3,a3,228 # ffffffffc02ae7e8 <check_rp>
ffffffffc020370c:	6585                	lui	a1,0x1
    if (PPN(pa) >= npage) {
ffffffffc020370e:	000afc17          	auipc	s8,0xaf
ffffffffc0203712:	19ac0c13          	addi	s8,s8,410 # ffffffffc02b28a8 <npage>
    return &pages[PPN(pa) - nbase];
ffffffffc0203716:	000afc97          	auipc	s9,0xaf
ffffffffc020371a:	19ac8c93          	addi	s9,s9,410 # ffffffffc02b28b0 <pages>
     
     for (i= 0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
         check_ptep[i]=0;
ffffffffc020371e:	00073023          	sd	zero,0(a4)
         check_ptep[i] = get_pte(pgdir, (i+1)*0x1000, 0);
ffffffffc0203722:	4601                	li	a2,0
ffffffffc0203724:	855a                	mv	a0,s6
ffffffffc0203726:	e836                	sd	a3,16(sp)
ffffffffc0203728:	e42e                	sd	a1,8(sp)
         check_ptep[i]=0;
ffffffffc020372a:	e03a                	sd	a4,0(sp)
         check_ptep[i] = get_pte(pgdir, (i+1)*0x1000, 0);
ffffffffc020372c:	ec0fe0ef          	jal	ra,ffffffffc0201dec <get_pte>
ffffffffc0203730:	6702                	ld	a4,0(sp)
         //cprintf("i %d, check_ptep addr %x, value %x\n", i, check_ptep[i], *check_ptep[i]);
         assert(check_ptep[i] != NULL);
ffffffffc0203732:	65a2                	ld	a1,8(sp)
ffffffffc0203734:	66c2                	ld	a3,16(sp)
         check_ptep[i] = get_pte(pgdir, (i+1)*0x1000, 0);
ffffffffc0203736:	e308                	sd	a0,0(a4)
         assert(check_ptep[i] != NULL);
ffffffffc0203738:	1c050663          	beqz	a0,ffffffffc0203904 <swap_init+0x476>
         assert(pte2page(*check_ptep[i]) == check_rp[i]);
ffffffffc020373c:	611c                	ld	a5,0(a0)
    if (!(pte & PTE_V)) {
ffffffffc020373e:	0017f613          	andi	a2,a5,1
ffffffffc0203742:	1e060163          	beqz	a2,ffffffffc0203924 <swap_init+0x496>
    if (PPN(pa) >= npage) {
ffffffffc0203746:	000c3603          	ld	a2,0(s8)
    return pa2page(PTE_ADDR(pte));
ffffffffc020374a:	078a                	slli	a5,a5,0x2
ffffffffc020374c:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc020374e:	14c7f363          	bgeu	a5,a2,ffffffffc0203894 <swap_init+0x406>
    return &pages[PPN(pa) - nbase];
ffffffffc0203752:	00005617          	auipc	a2,0x5
ffffffffc0203756:	6ee60613          	addi	a2,a2,1774 # ffffffffc0208e40 <nbase>
ffffffffc020375a:	00063a03          	ld	s4,0(a2)
ffffffffc020375e:	000cb603          	ld	a2,0(s9)
ffffffffc0203762:	6288                	ld	a0,0(a3)
ffffffffc0203764:	414787b3          	sub	a5,a5,s4
ffffffffc0203768:	079a                	slli	a5,a5,0x6
ffffffffc020376a:	97b2                	add	a5,a5,a2
ffffffffc020376c:	14f51063          	bne	a0,a5,ffffffffc02038ac <swap_init+0x41e>
     for (i= 0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
ffffffffc0203770:	6785                	lui	a5,0x1
ffffffffc0203772:	95be                	add	a1,a1,a5
ffffffffc0203774:	6795                	lui	a5,0x5
ffffffffc0203776:	0721                	addi	a4,a4,8
ffffffffc0203778:	06a1                	addi	a3,a3,8
ffffffffc020377a:	faf592e3          	bne	a1,a5,ffffffffc020371e <swap_init+0x290>
         assert((*check_ptep[i] & PTE_V));          
     }
     cprintf("set up init env for check_swap over!\n");
ffffffffc020377e:	00004517          	auipc	a0,0x4
ffffffffc0203782:	66a50513          	addi	a0,a0,1642 # ffffffffc0207de8 <default_pmm_manager+0x968>
ffffffffc0203786:	9fbfc0ef          	jal	ra,ffffffffc0200180 <cprintf>
    int ret = sm->check_swap();
ffffffffc020378a:	000bb783          	ld	a5,0(s7)
ffffffffc020378e:	7f9c                	ld	a5,56(a5)
ffffffffc0203790:	9782                	jalr	a5
     // now access the virt pages to test  page relpacement algorithm 
     ret=check_content_access();
     assert(ret==0);
ffffffffc0203792:	32051163          	bnez	a0,ffffffffc0203ab4 <swap_init+0x626>

     nr_free = nr_free_store;
ffffffffc0203796:	77a2                	ld	a5,40(sp)
ffffffffc0203798:	c81c                	sw	a5,16(s0)
     free_list = free_list_store;
ffffffffc020379a:	67e2                	ld	a5,24(sp)
ffffffffc020379c:	e01c                	sd	a5,0(s0)
ffffffffc020379e:	7782                	ld	a5,32(sp)
ffffffffc02037a0:	e41c                	sd	a5,8(s0)

     //restore kernel mem env
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
         free_pages(check_rp[i],1);
ffffffffc02037a2:	6088                	ld	a0,0(s1)
ffffffffc02037a4:	4585                	li	a1,1
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
ffffffffc02037a6:	04a1                	addi	s1,s1,8
         free_pages(check_rp[i],1);
ffffffffc02037a8:	dcafe0ef          	jal	ra,ffffffffc0201d72 <free_pages>
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
ffffffffc02037ac:	ff349be3          	bne	s1,s3,ffffffffc02037a2 <swap_init+0x314>
     } 

     //free_page(pte2page(*temp_ptep));

     mm->pgdir = NULL;
ffffffffc02037b0:	000abc23          	sd	zero,24(s5)
     mm_destroy(mm);
ffffffffc02037b4:	8556                	mv	a0,s5
ffffffffc02037b6:	389000ef          	jal	ra,ffffffffc020433e <mm_destroy>
     check_mm_struct = NULL;

     pde_t *pd1=pgdir,*pd0=page2kva(pde2page(boot_pgdir[0]));
ffffffffc02037ba:	000af797          	auipc	a5,0xaf
ffffffffc02037be:	0e678793          	addi	a5,a5,230 # ffffffffc02b28a0 <boot_pgdir>
ffffffffc02037c2:	639c                	ld	a5,0(a5)
    if (PPN(pa) >= npage) {
ffffffffc02037c4:	000c3703          	ld	a4,0(s8)
     check_mm_struct = NULL;
ffffffffc02037c8:	000af697          	auipc	a3,0xaf
ffffffffc02037cc:	1006bc23          	sd	zero,280(a3) # ffffffffc02b28e0 <check_mm_struct>
    return pa2page(PDE_ADDR(pde));
ffffffffc02037d0:	639c                	ld	a5,0(a5)
ffffffffc02037d2:	078a                	slli	a5,a5,0x2
ffffffffc02037d4:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc02037d6:	0ae7fd63          	bgeu	a5,a4,ffffffffc0203890 <swap_init+0x402>
    return &pages[PPN(pa) - nbase];
ffffffffc02037da:	414786b3          	sub	a3,a5,s4
ffffffffc02037de:	069a                	slli	a3,a3,0x6
    return page - pages + nbase;
ffffffffc02037e0:	8699                	srai	a3,a3,0x6
ffffffffc02037e2:	96d2                	add	a3,a3,s4
    return KADDR(page2pa(page));
ffffffffc02037e4:	00c69793          	slli	a5,a3,0xc
ffffffffc02037e8:	83b1                	srli	a5,a5,0xc
    return &pages[PPN(pa) - nbase];
ffffffffc02037ea:	000cb503          	ld	a0,0(s9)
    return page2ppn(page) << PGSHIFT;
ffffffffc02037ee:	06b2                	slli	a3,a3,0xc
    return KADDR(page2pa(page));
ffffffffc02037f0:	22e7f663          	bgeu	a5,a4,ffffffffc0203a1c <swap_init+0x58e>
     free_page(pde2page(pd0[0]));
ffffffffc02037f4:	000af797          	auipc	a5,0xaf
ffffffffc02037f8:	0cc7b783          	ld	a5,204(a5) # ffffffffc02b28c0 <va_pa_offset>
ffffffffc02037fc:	96be                	add	a3,a3,a5
    return pa2page(PDE_ADDR(pde));
ffffffffc02037fe:	629c                	ld	a5,0(a3)
ffffffffc0203800:	078a                	slli	a5,a5,0x2
ffffffffc0203802:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0203804:	08e7f663          	bgeu	a5,a4,ffffffffc0203890 <swap_init+0x402>
    return &pages[PPN(pa) - nbase];
ffffffffc0203808:	414787b3          	sub	a5,a5,s4
ffffffffc020380c:	079a                	slli	a5,a5,0x6
ffffffffc020380e:	953e                	add	a0,a0,a5
ffffffffc0203810:	4585                	li	a1,1
ffffffffc0203812:	d60fe0ef          	jal	ra,ffffffffc0201d72 <free_pages>
    return pa2page(PDE_ADDR(pde));
ffffffffc0203816:	000b3783          	ld	a5,0(s6)
    if (PPN(pa) >= npage) {
ffffffffc020381a:	000c3703          	ld	a4,0(s8)
    return pa2page(PDE_ADDR(pde));
ffffffffc020381e:	078a                	slli	a5,a5,0x2
ffffffffc0203820:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0203822:	06e7f763          	bgeu	a5,a4,ffffffffc0203890 <swap_init+0x402>
    return &pages[PPN(pa) - nbase];
ffffffffc0203826:	000cb503          	ld	a0,0(s9)
ffffffffc020382a:	414787b3          	sub	a5,a5,s4
ffffffffc020382e:	079a                	slli	a5,a5,0x6
     free_page(pde2page(pd1[0]));
ffffffffc0203830:	4585                	li	a1,1
ffffffffc0203832:	953e                	add	a0,a0,a5
ffffffffc0203834:	d3efe0ef          	jal	ra,ffffffffc0201d72 <free_pages>
     pgdir[0] = 0;
ffffffffc0203838:	000b3023          	sd	zero,0(s6)
  asm volatile("sfence.vma");
ffffffffc020383c:	12000073          	sfence.vma
    return listelm->next;
ffffffffc0203840:	641c                	ld	a5,8(s0)
     flush_tlb();

     le = &free_list;
     while ((le = list_next(le)) != &free_list) {
ffffffffc0203842:	00878a63          	beq	a5,s0,ffffffffc0203856 <swap_init+0x3c8>
         struct Page *p = le2page(le, page_link);
         count --, total -= p->property;
ffffffffc0203846:	ff87a703          	lw	a4,-8(a5)
ffffffffc020384a:	679c                	ld	a5,8(a5)
ffffffffc020384c:	3dfd                	addiw	s11,s11,-1
ffffffffc020384e:	40ed0d3b          	subw	s10,s10,a4
     while ((le = list_next(le)) != &free_list) {
ffffffffc0203852:	fe879ae3          	bne	a5,s0,ffffffffc0203846 <swap_init+0x3b8>
     }
     assert(count==0);
ffffffffc0203856:	1c0d9f63          	bnez	s11,ffffffffc0203a34 <swap_init+0x5a6>
     assert(total==0);
ffffffffc020385a:	1a0d1163          	bnez	s10,ffffffffc02039fc <swap_init+0x56e>

     cprintf("check_swap() succeeded!\n");
ffffffffc020385e:	00004517          	auipc	a0,0x4
ffffffffc0203862:	5da50513          	addi	a0,a0,1498 # ffffffffc0207e38 <default_pmm_manager+0x9b8>
ffffffffc0203866:	91bfc0ef          	jal	ra,ffffffffc0200180 <cprintf>
}
ffffffffc020386a:	b99d                	j	ffffffffc02034e0 <swap_init+0x52>
     while ((le = list_next(le)) != &free_list) {
ffffffffc020386c:	4481                	li	s1,0
ffffffffc020386e:	b9f1                	j	ffffffffc020354a <swap_init+0xbc>
        assert(PageProperty(p));
ffffffffc0203870:	00004697          	auipc	a3,0x4
ffffffffc0203874:	86868693          	addi	a3,a3,-1944 # ffffffffc02070d8 <commands+0x740>
ffffffffc0203878:	00003617          	auipc	a2,0x3
ffffffffc020387c:	57060613          	addi	a2,a2,1392 # ffffffffc0206de8 <commands+0x450>
ffffffffc0203880:	0bc00593          	li	a1,188
ffffffffc0203884:	00004517          	auipc	a0,0x4
ffffffffc0203888:	34c50513          	addi	a0,a0,844 # ffffffffc0207bd0 <default_pmm_manager+0x750>
ffffffffc020388c:	beffc0ef          	jal	ra,ffffffffc020047a <__panic>
ffffffffc0203890:	be3ff0ef          	jal	ra,ffffffffc0203472 <pa2page.part.0>
        panic("pa2page called with invalid pa");
ffffffffc0203894:	00004617          	auipc	a2,0x4
ffffffffc0203898:	cf460613          	addi	a2,a2,-780 # ffffffffc0207588 <default_pmm_manager+0x108>
ffffffffc020389c:	06200593          	li	a1,98
ffffffffc02038a0:	00004517          	auipc	a0,0x4
ffffffffc02038a4:	c4050513          	addi	a0,a0,-960 # ffffffffc02074e0 <default_pmm_manager+0x60>
ffffffffc02038a8:	bd3fc0ef          	jal	ra,ffffffffc020047a <__panic>
         assert(pte2page(*check_ptep[i]) == check_rp[i]);
ffffffffc02038ac:	00004697          	auipc	a3,0x4
ffffffffc02038b0:	51468693          	addi	a3,a3,1300 # ffffffffc0207dc0 <default_pmm_manager+0x940>
ffffffffc02038b4:	00003617          	auipc	a2,0x3
ffffffffc02038b8:	53460613          	addi	a2,a2,1332 # ffffffffc0206de8 <commands+0x450>
ffffffffc02038bc:	0fc00593          	li	a1,252
ffffffffc02038c0:	00004517          	auipc	a0,0x4
ffffffffc02038c4:	31050513          	addi	a0,a0,784 # ffffffffc0207bd0 <default_pmm_manager+0x750>
ffffffffc02038c8:	bb3fc0ef          	jal	ra,ffffffffc020047a <__panic>
          assert(check_rp[i] != NULL );
ffffffffc02038cc:	00004697          	auipc	a3,0x4
ffffffffc02038d0:	41468693          	addi	a3,a3,1044 # ffffffffc0207ce0 <default_pmm_manager+0x860>
ffffffffc02038d4:	00003617          	auipc	a2,0x3
ffffffffc02038d8:	51460613          	addi	a2,a2,1300 # ffffffffc0206de8 <commands+0x450>
ffffffffc02038dc:	0dc00593          	li	a1,220
ffffffffc02038e0:	00004517          	auipc	a0,0x4
ffffffffc02038e4:	2f050513          	addi	a0,a0,752 # ffffffffc0207bd0 <default_pmm_manager+0x750>
ffffffffc02038e8:	b93fc0ef          	jal	ra,ffffffffc020047a <__panic>
        panic("bad max_swap_offset %08x.\n", max_swap_offset);
ffffffffc02038ec:	00004617          	auipc	a2,0x4
ffffffffc02038f0:	2c460613          	addi	a2,a2,708 # ffffffffc0207bb0 <default_pmm_manager+0x730>
ffffffffc02038f4:	02800593          	li	a1,40
ffffffffc02038f8:	00004517          	auipc	a0,0x4
ffffffffc02038fc:	2d850513          	addi	a0,a0,728 # ffffffffc0207bd0 <default_pmm_manager+0x750>
ffffffffc0203900:	b7bfc0ef          	jal	ra,ffffffffc020047a <__panic>
         assert(check_ptep[i] != NULL);
ffffffffc0203904:	00004697          	auipc	a3,0x4
ffffffffc0203908:	4a468693          	addi	a3,a3,1188 # ffffffffc0207da8 <default_pmm_manager+0x928>
ffffffffc020390c:	00003617          	auipc	a2,0x3
ffffffffc0203910:	4dc60613          	addi	a2,a2,1244 # ffffffffc0206de8 <commands+0x450>
ffffffffc0203914:	0fb00593          	li	a1,251
ffffffffc0203918:	00004517          	auipc	a0,0x4
ffffffffc020391c:	2b850513          	addi	a0,a0,696 # ffffffffc0207bd0 <default_pmm_manager+0x750>
ffffffffc0203920:	b5bfc0ef          	jal	ra,ffffffffc020047a <__panic>
        panic("pte2page called with invalid pte");
ffffffffc0203924:	00004617          	auipc	a2,0x4
ffffffffc0203928:	c8460613          	addi	a2,a2,-892 # ffffffffc02075a8 <default_pmm_manager+0x128>
ffffffffc020392c:	07400593          	li	a1,116
ffffffffc0203930:	00004517          	auipc	a0,0x4
ffffffffc0203934:	bb050513          	addi	a0,a0,-1104 # ffffffffc02074e0 <default_pmm_manager+0x60>
ffffffffc0203938:	b43fc0ef          	jal	ra,ffffffffc020047a <__panic>
          assert(!PageProperty(check_rp[i]));
ffffffffc020393c:	00004697          	auipc	a3,0x4
ffffffffc0203940:	3bc68693          	addi	a3,a3,956 # ffffffffc0207cf8 <default_pmm_manager+0x878>
ffffffffc0203944:	00003617          	auipc	a2,0x3
ffffffffc0203948:	4a460613          	addi	a2,a2,1188 # ffffffffc0206de8 <commands+0x450>
ffffffffc020394c:	0dd00593          	li	a1,221
ffffffffc0203950:	00004517          	auipc	a0,0x4
ffffffffc0203954:	28050513          	addi	a0,a0,640 # ffffffffc0207bd0 <default_pmm_manager+0x750>
ffffffffc0203958:	b23fc0ef          	jal	ra,ffffffffc020047a <__panic>
     assert(check_mm_struct == NULL);
ffffffffc020395c:	00004697          	auipc	a3,0x4
ffffffffc0203960:	2d468693          	addi	a3,a3,724 # ffffffffc0207c30 <default_pmm_manager+0x7b0>
ffffffffc0203964:	00003617          	auipc	a2,0x3
ffffffffc0203968:	48460613          	addi	a2,a2,1156 # ffffffffc0206de8 <commands+0x450>
ffffffffc020396c:	0c700593          	li	a1,199
ffffffffc0203970:	00004517          	auipc	a0,0x4
ffffffffc0203974:	26050513          	addi	a0,a0,608 # ffffffffc0207bd0 <default_pmm_manager+0x750>
ffffffffc0203978:	b03fc0ef          	jal	ra,ffffffffc020047a <__panic>
     assert(total == nr_free_pages());
ffffffffc020397c:	00003697          	auipc	a3,0x3
ffffffffc0203980:	78468693          	addi	a3,a3,1924 # ffffffffc0207100 <commands+0x768>
ffffffffc0203984:	00003617          	auipc	a2,0x3
ffffffffc0203988:	46460613          	addi	a2,a2,1124 # ffffffffc0206de8 <commands+0x450>
ffffffffc020398c:	0bf00593          	li	a1,191
ffffffffc0203990:	00004517          	auipc	a0,0x4
ffffffffc0203994:	24050513          	addi	a0,a0,576 # ffffffffc0207bd0 <default_pmm_manager+0x750>
ffffffffc0203998:	ae3fc0ef          	jal	ra,ffffffffc020047a <__panic>
     assert( nr_free == 0);         
ffffffffc020399c:	00004697          	auipc	a3,0x4
ffffffffc02039a0:	90c68693          	addi	a3,a3,-1780 # ffffffffc02072a8 <commands+0x910>
ffffffffc02039a4:	00003617          	auipc	a2,0x3
ffffffffc02039a8:	44460613          	addi	a2,a2,1092 # ffffffffc0206de8 <commands+0x450>
ffffffffc02039ac:	0f300593          	li	a1,243
ffffffffc02039b0:	00004517          	auipc	a0,0x4
ffffffffc02039b4:	22050513          	addi	a0,a0,544 # ffffffffc0207bd0 <default_pmm_manager+0x750>
ffffffffc02039b8:	ac3fc0ef          	jal	ra,ffffffffc020047a <__panic>
     assert(pgdir[0] == 0);
ffffffffc02039bc:	00004697          	auipc	a3,0x4
ffffffffc02039c0:	28c68693          	addi	a3,a3,652 # ffffffffc0207c48 <default_pmm_manager+0x7c8>
ffffffffc02039c4:	00003617          	auipc	a2,0x3
ffffffffc02039c8:	42460613          	addi	a2,a2,1060 # ffffffffc0206de8 <commands+0x450>
ffffffffc02039cc:	0cc00593          	li	a1,204
ffffffffc02039d0:	00004517          	auipc	a0,0x4
ffffffffc02039d4:	20050513          	addi	a0,a0,512 # ffffffffc0207bd0 <default_pmm_manager+0x750>
ffffffffc02039d8:	aa3fc0ef          	jal	ra,ffffffffc020047a <__panic>
     assert(mm != NULL);
ffffffffc02039dc:	00004697          	auipc	a3,0x4
ffffffffc02039e0:	24468693          	addi	a3,a3,580 # ffffffffc0207c20 <default_pmm_manager+0x7a0>
ffffffffc02039e4:	00003617          	auipc	a2,0x3
ffffffffc02039e8:	40460613          	addi	a2,a2,1028 # ffffffffc0206de8 <commands+0x450>
ffffffffc02039ec:	0c400593          	li	a1,196
ffffffffc02039f0:	00004517          	auipc	a0,0x4
ffffffffc02039f4:	1e050513          	addi	a0,a0,480 # ffffffffc0207bd0 <default_pmm_manager+0x750>
ffffffffc02039f8:	a83fc0ef          	jal	ra,ffffffffc020047a <__panic>
     assert(total==0);
ffffffffc02039fc:	00004697          	auipc	a3,0x4
ffffffffc0203a00:	42c68693          	addi	a3,a3,1068 # ffffffffc0207e28 <default_pmm_manager+0x9a8>
ffffffffc0203a04:	00003617          	auipc	a2,0x3
ffffffffc0203a08:	3e460613          	addi	a2,a2,996 # ffffffffc0206de8 <commands+0x450>
ffffffffc0203a0c:	11e00593          	li	a1,286
ffffffffc0203a10:	00004517          	auipc	a0,0x4
ffffffffc0203a14:	1c050513          	addi	a0,a0,448 # ffffffffc0207bd0 <default_pmm_manager+0x750>
ffffffffc0203a18:	a63fc0ef          	jal	ra,ffffffffc020047a <__panic>
    return KADDR(page2pa(page));
ffffffffc0203a1c:	00004617          	auipc	a2,0x4
ffffffffc0203a20:	a9c60613          	addi	a2,a2,-1380 # ffffffffc02074b8 <default_pmm_manager+0x38>
ffffffffc0203a24:	06900593          	li	a1,105
ffffffffc0203a28:	00004517          	auipc	a0,0x4
ffffffffc0203a2c:	ab850513          	addi	a0,a0,-1352 # ffffffffc02074e0 <default_pmm_manager+0x60>
ffffffffc0203a30:	a4bfc0ef          	jal	ra,ffffffffc020047a <__panic>
     assert(count==0);
ffffffffc0203a34:	00004697          	auipc	a3,0x4
ffffffffc0203a38:	3e468693          	addi	a3,a3,996 # ffffffffc0207e18 <default_pmm_manager+0x998>
ffffffffc0203a3c:	00003617          	auipc	a2,0x3
ffffffffc0203a40:	3ac60613          	addi	a2,a2,940 # ffffffffc0206de8 <commands+0x450>
ffffffffc0203a44:	11d00593          	li	a1,285
ffffffffc0203a48:	00004517          	auipc	a0,0x4
ffffffffc0203a4c:	18850513          	addi	a0,a0,392 # ffffffffc0207bd0 <default_pmm_manager+0x750>
ffffffffc0203a50:	a2bfc0ef          	jal	ra,ffffffffc020047a <__panic>
     assert(pgfault_num==1);
ffffffffc0203a54:	00004697          	auipc	a3,0x4
ffffffffc0203a58:	31468693          	addi	a3,a3,788 # ffffffffc0207d68 <default_pmm_manager+0x8e8>
ffffffffc0203a5c:	00003617          	auipc	a2,0x3
ffffffffc0203a60:	38c60613          	addi	a2,a2,908 # ffffffffc0206de8 <commands+0x450>
ffffffffc0203a64:	09500593          	li	a1,149
ffffffffc0203a68:	00004517          	auipc	a0,0x4
ffffffffc0203a6c:	16850513          	addi	a0,a0,360 # ffffffffc0207bd0 <default_pmm_manager+0x750>
ffffffffc0203a70:	a0bfc0ef          	jal	ra,ffffffffc020047a <__panic>
     assert(nr_free==CHECK_VALID_PHY_PAGE_NUM);
ffffffffc0203a74:	00004697          	auipc	a3,0x4
ffffffffc0203a78:	2a468693          	addi	a3,a3,676 # ffffffffc0207d18 <default_pmm_manager+0x898>
ffffffffc0203a7c:	00003617          	auipc	a2,0x3
ffffffffc0203a80:	36c60613          	addi	a2,a2,876 # ffffffffc0206de8 <commands+0x450>
ffffffffc0203a84:	0ea00593          	li	a1,234
ffffffffc0203a88:	00004517          	auipc	a0,0x4
ffffffffc0203a8c:	14850513          	addi	a0,a0,328 # ffffffffc0207bd0 <default_pmm_manager+0x750>
ffffffffc0203a90:	9ebfc0ef          	jal	ra,ffffffffc020047a <__panic>
     assert(temp_ptep!= NULL);
ffffffffc0203a94:	00004697          	auipc	a3,0x4
ffffffffc0203a98:	20c68693          	addi	a3,a3,524 # ffffffffc0207ca0 <default_pmm_manager+0x820>
ffffffffc0203a9c:	00003617          	auipc	a2,0x3
ffffffffc0203aa0:	34c60613          	addi	a2,a2,844 # ffffffffc0206de8 <commands+0x450>
ffffffffc0203aa4:	0d700593          	li	a1,215
ffffffffc0203aa8:	00004517          	auipc	a0,0x4
ffffffffc0203aac:	12850513          	addi	a0,a0,296 # ffffffffc0207bd0 <default_pmm_manager+0x750>
ffffffffc0203ab0:	9cbfc0ef          	jal	ra,ffffffffc020047a <__panic>
     assert(ret==0);
ffffffffc0203ab4:	00004697          	auipc	a3,0x4
ffffffffc0203ab8:	35c68693          	addi	a3,a3,860 # ffffffffc0207e10 <default_pmm_manager+0x990>
ffffffffc0203abc:	00003617          	auipc	a2,0x3
ffffffffc0203ac0:	32c60613          	addi	a2,a2,812 # ffffffffc0206de8 <commands+0x450>
ffffffffc0203ac4:	10200593          	li	a1,258
ffffffffc0203ac8:	00004517          	auipc	a0,0x4
ffffffffc0203acc:	10850513          	addi	a0,a0,264 # ffffffffc0207bd0 <default_pmm_manager+0x750>
ffffffffc0203ad0:	9abfc0ef          	jal	ra,ffffffffc020047a <__panic>
     assert(vma != NULL);
ffffffffc0203ad4:	00004697          	auipc	a3,0x4
ffffffffc0203ad8:	18468693          	addi	a3,a3,388 # ffffffffc0207c58 <default_pmm_manager+0x7d8>
ffffffffc0203adc:	00003617          	auipc	a2,0x3
ffffffffc0203ae0:	30c60613          	addi	a2,a2,780 # ffffffffc0206de8 <commands+0x450>
ffffffffc0203ae4:	0cf00593          	li	a1,207
ffffffffc0203ae8:	00004517          	auipc	a0,0x4
ffffffffc0203aec:	0e850513          	addi	a0,a0,232 # ffffffffc0207bd0 <default_pmm_manager+0x750>
ffffffffc0203af0:	98bfc0ef          	jal	ra,ffffffffc020047a <__panic>
     assert(pgfault_num==4);
ffffffffc0203af4:	00004697          	auipc	a3,0x4
ffffffffc0203af8:	2a468693          	addi	a3,a3,676 # ffffffffc0207d98 <default_pmm_manager+0x918>
ffffffffc0203afc:	00003617          	auipc	a2,0x3
ffffffffc0203b00:	2ec60613          	addi	a2,a2,748 # ffffffffc0206de8 <commands+0x450>
ffffffffc0203b04:	09f00593          	li	a1,159
ffffffffc0203b08:	00004517          	auipc	a0,0x4
ffffffffc0203b0c:	0c850513          	addi	a0,a0,200 # ffffffffc0207bd0 <default_pmm_manager+0x750>
ffffffffc0203b10:	96bfc0ef          	jal	ra,ffffffffc020047a <__panic>
     assert(pgfault_num==4);
ffffffffc0203b14:	00004697          	auipc	a3,0x4
ffffffffc0203b18:	28468693          	addi	a3,a3,644 # ffffffffc0207d98 <default_pmm_manager+0x918>
ffffffffc0203b1c:	00003617          	auipc	a2,0x3
ffffffffc0203b20:	2cc60613          	addi	a2,a2,716 # ffffffffc0206de8 <commands+0x450>
ffffffffc0203b24:	0a100593          	li	a1,161
ffffffffc0203b28:	00004517          	auipc	a0,0x4
ffffffffc0203b2c:	0a850513          	addi	a0,a0,168 # ffffffffc0207bd0 <default_pmm_manager+0x750>
ffffffffc0203b30:	94bfc0ef          	jal	ra,ffffffffc020047a <__panic>
     assert(pgfault_num==2);
ffffffffc0203b34:	00004697          	auipc	a3,0x4
ffffffffc0203b38:	24468693          	addi	a3,a3,580 # ffffffffc0207d78 <default_pmm_manager+0x8f8>
ffffffffc0203b3c:	00003617          	auipc	a2,0x3
ffffffffc0203b40:	2ac60613          	addi	a2,a2,684 # ffffffffc0206de8 <commands+0x450>
ffffffffc0203b44:	09700593          	li	a1,151
ffffffffc0203b48:	00004517          	auipc	a0,0x4
ffffffffc0203b4c:	08850513          	addi	a0,a0,136 # ffffffffc0207bd0 <default_pmm_manager+0x750>
ffffffffc0203b50:	92bfc0ef          	jal	ra,ffffffffc020047a <__panic>
     assert(pgfault_num==2);
ffffffffc0203b54:	00004697          	auipc	a3,0x4
ffffffffc0203b58:	22468693          	addi	a3,a3,548 # ffffffffc0207d78 <default_pmm_manager+0x8f8>
ffffffffc0203b5c:	00003617          	auipc	a2,0x3
ffffffffc0203b60:	28c60613          	addi	a2,a2,652 # ffffffffc0206de8 <commands+0x450>
ffffffffc0203b64:	09900593          	li	a1,153
ffffffffc0203b68:	00004517          	auipc	a0,0x4
ffffffffc0203b6c:	06850513          	addi	a0,a0,104 # ffffffffc0207bd0 <default_pmm_manager+0x750>
ffffffffc0203b70:	90bfc0ef          	jal	ra,ffffffffc020047a <__panic>
     assert(pgfault_num==3);
ffffffffc0203b74:	00004697          	auipc	a3,0x4
ffffffffc0203b78:	21468693          	addi	a3,a3,532 # ffffffffc0207d88 <default_pmm_manager+0x908>
ffffffffc0203b7c:	00003617          	auipc	a2,0x3
ffffffffc0203b80:	26c60613          	addi	a2,a2,620 # ffffffffc0206de8 <commands+0x450>
ffffffffc0203b84:	09b00593          	li	a1,155
ffffffffc0203b88:	00004517          	auipc	a0,0x4
ffffffffc0203b8c:	04850513          	addi	a0,a0,72 # ffffffffc0207bd0 <default_pmm_manager+0x750>
ffffffffc0203b90:	8ebfc0ef          	jal	ra,ffffffffc020047a <__panic>
     assert(pgfault_num==3);
ffffffffc0203b94:	00004697          	auipc	a3,0x4
ffffffffc0203b98:	1f468693          	addi	a3,a3,500 # ffffffffc0207d88 <default_pmm_manager+0x908>
ffffffffc0203b9c:	00003617          	auipc	a2,0x3
ffffffffc0203ba0:	24c60613          	addi	a2,a2,588 # ffffffffc0206de8 <commands+0x450>
ffffffffc0203ba4:	09d00593          	li	a1,157
ffffffffc0203ba8:	00004517          	auipc	a0,0x4
ffffffffc0203bac:	02850513          	addi	a0,a0,40 # ffffffffc0207bd0 <default_pmm_manager+0x750>
ffffffffc0203bb0:	8cbfc0ef          	jal	ra,ffffffffc020047a <__panic>
     assert(pgfault_num==1);
ffffffffc0203bb4:	00004697          	auipc	a3,0x4
ffffffffc0203bb8:	1b468693          	addi	a3,a3,436 # ffffffffc0207d68 <default_pmm_manager+0x8e8>
ffffffffc0203bbc:	00003617          	auipc	a2,0x3
ffffffffc0203bc0:	22c60613          	addi	a2,a2,556 # ffffffffc0206de8 <commands+0x450>
ffffffffc0203bc4:	09300593          	li	a1,147
ffffffffc0203bc8:	00004517          	auipc	a0,0x4
ffffffffc0203bcc:	00850513          	addi	a0,a0,8 # ffffffffc0207bd0 <default_pmm_manager+0x750>
ffffffffc0203bd0:	8abfc0ef          	jal	ra,ffffffffc020047a <__panic>

ffffffffc0203bd4 <swap_init_mm>:
     return sm->init_mm(mm);
ffffffffc0203bd4:	000af797          	auipc	a5,0xaf
ffffffffc0203bd8:	cfc7b783          	ld	a5,-772(a5) # ffffffffc02b28d0 <sm>
ffffffffc0203bdc:	6b9c                	ld	a5,16(a5)
ffffffffc0203bde:	8782                	jr	a5

ffffffffc0203be0 <swap_map_swappable>:
     return sm->map_swappable(mm, addr, page, swap_in);
ffffffffc0203be0:	000af797          	auipc	a5,0xaf
ffffffffc0203be4:	cf07b783          	ld	a5,-784(a5) # ffffffffc02b28d0 <sm>
ffffffffc0203be8:	739c                	ld	a5,32(a5)
ffffffffc0203bea:	8782                	jr	a5

ffffffffc0203bec <swap_out>:
{
ffffffffc0203bec:	711d                	addi	sp,sp,-96
ffffffffc0203bee:	ec86                	sd	ra,88(sp)
ffffffffc0203bf0:	e8a2                	sd	s0,80(sp)
ffffffffc0203bf2:	e4a6                	sd	s1,72(sp)
ffffffffc0203bf4:	e0ca                	sd	s2,64(sp)
ffffffffc0203bf6:	fc4e                	sd	s3,56(sp)
ffffffffc0203bf8:	f852                	sd	s4,48(sp)
ffffffffc0203bfa:	f456                	sd	s5,40(sp)
ffffffffc0203bfc:	f05a                	sd	s6,32(sp)
ffffffffc0203bfe:	ec5e                	sd	s7,24(sp)
ffffffffc0203c00:	e862                	sd	s8,16(sp)
     for (i = 0; i != n; ++ i)
ffffffffc0203c02:	cde9                	beqz	a1,ffffffffc0203cdc <swap_out+0xf0>
ffffffffc0203c04:	8a2e                	mv	s4,a1
ffffffffc0203c06:	892a                	mv	s2,a0
ffffffffc0203c08:	8ab2                	mv	s5,a2
ffffffffc0203c0a:	4401                	li	s0,0
ffffffffc0203c0c:	000af997          	auipc	s3,0xaf
ffffffffc0203c10:	cc498993          	addi	s3,s3,-828 # ffffffffc02b28d0 <sm>
                    cprintf("swap_out: i %d, store page in vaddr 0x%x to disk swap entry %d\n", i, v, page->pra_vaddr/PGSIZE+1);
ffffffffc0203c14:	00004b17          	auipc	s6,0x4
ffffffffc0203c18:	2a4b0b13          	addi	s6,s6,676 # ffffffffc0207eb8 <default_pmm_manager+0xa38>
                    cprintf("SWAP: failed to save\n");
ffffffffc0203c1c:	00004b97          	auipc	s7,0x4
ffffffffc0203c20:	284b8b93          	addi	s7,s7,644 # ffffffffc0207ea0 <default_pmm_manager+0xa20>
ffffffffc0203c24:	a825                	j	ffffffffc0203c5c <swap_out+0x70>
                    cprintf("swap_out: i %d, store page in vaddr 0x%x to disk swap entry %d\n", i, v, page->pra_vaddr/PGSIZE+1);
ffffffffc0203c26:	67a2                	ld	a5,8(sp)
ffffffffc0203c28:	8626                	mv	a2,s1
ffffffffc0203c2a:	85a2                	mv	a1,s0
ffffffffc0203c2c:	7f94                	ld	a3,56(a5)
ffffffffc0203c2e:	855a                	mv	a0,s6
     for (i = 0; i != n; ++ i)
ffffffffc0203c30:	2405                	addiw	s0,s0,1
                    cprintf("swap_out: i %d, store page in vaddr 0x%x to disk swap entry %d\n", i, v, page->pra_vaddr/PGSIZE+1);
ffffffffc0203c32:	82b1                	srli	a3,a3,0xc
ffffffffc0203c34:	0685                	addi	a3,a3,1
ffffffffc0203c36:	d4afc0ef          	jal	ra,ffffffffc0200180 <cprintf>
                    *ptep = (page->pra_vaddr/PGSIZE+1)<<8;
ffffffffc0203c3a:	6522                	ld	a0,8(sp)
                    free_page(page);
ffffffffc0203c3c:	4585                	li	a1,1
                    *ptep = (page->pra_vaddr/PGSIZE+1)<<8;
ffffffffc0203c3e:	7d1c                	ld	a5,56(a0)
ffffffffc0203c40:	83b1                	srli	a5,a5,0xc
ffffffffc0203c42:	0785                	addi	a5,a5,1
ffffffffc0203c44:	07a2                	slli	a5,a5,0x8
ffffffffc0203c46:	00fc3023          	sd	a5,0(s8)
                    free_page(page);
ffffffffc0203c4a:	928fe0ef          	jal	ra,ffffffffc0201d72 <free_pages>
          tlb_invalidate(mm->pgdir, v);
ffffffffc0203c4e:	01893503          	ld	a0,24(s2)
ffffffffc0203c52:	85a6                	mv	a1,s1
ffffffffc0203c54:	f5eff0ef          	jal	ra,ffffffffc02033b2 <tlb_invalidate>
     for (i = 0; i != n; ++ i)
ffffffffc0203c58:	048a0d63          	beq	s4,s0,ffffffffc0203cb2 <swap_out+0xc6>
          int r = sm->swap_out_victim(mm, &page, in_tick);
ffffffffc0203c5c:	0009b783          	ld	a5,0(s3)
ffffffffc0203c60:	8656                	mv	a2,s5
ffffffffc0203c62:	002c                	addi	a1,sp,8
ffffffffc0203c64:	7b9c                	ld	a5,48(a5)
ffffffffc0203c66:	854a                	mv	a0,s2
ffffffffc0203c68:	9782                	jalr	a5
          if (r != 0) {
ffffffffc0203c6a:	e12d                	bnez	a0,ffffffffc0203ccc <swap_out+0xe0>
          v=page->pra_vaddr; 
ffffffffc0203c6c:	67a2                	ld	a5,8(sp)
          pte_t *ptep = get_pte(mm->pgdir, v, 0);
ffffffffc0203c6e:	01893503          	ld	a0,24(s2)
ffffffffc0203c72:	4601                	li	a2,0
          v=page->pra_vaddr; 
ffffffffc0203c74:	7f84                	ld	s1,56(a5)
          pte_t *ptep = get_pte(mm->pgdir, v, 0);
ffffffffc0203c76:	85a6                	mv	a1,s1
ffffffffc0203c78:	974fe0ef          	jal	ra,ffffffffc0201dec <get_pte>
          assert((*ptep & PTE_V) != 0);
ffffffffc0203c7c:	611c                	ld	a5,0(a0)
          pte_t *ptep = get_pte(mm->pgdir, v, 0);
ffffffffc0203c7e:	8c2a                	mv	s8,a0
          assert((*ptep & PTE_V) != 0);
ffffffffc0203c80:	8b85                	andi	a5,a5,1
ffffffffc0203c82:	cfb9                	beqz	a5,ffffffffc0203ce0 <swap_out+0xf4>
          if (swapfs_write( (page->pra_vaddr/PGSIZE+1)<<8, page) != 0) {
ffffffffc0203c84:	65a2                	ld	a1,8(sp)
ffffffffc0203c86:	7d9c                	ld	a5,56(a1)
ffffffffc0203c88:	83b1                	srli	a5,a5,0xc
ffffffffc0203c8a:	0785                	addi	a5,a5,1
ffffffffc0203c8c:	00879513          	slli	a0,a5,0x8
ffffffffc0203c90:	13c010ef          	jal	ra,ffffffffc0204dcc <swapfs_write>
ffffffffc0203c94:	d949                	beqz	a0,ffffffffc0203c26 <swap_out+0x3a>
                    cprintf("SWAP: failed to save\n");
ffffffffc0203c96:	855e                	mv	a0,s7
ffffffffc0203c98:	ce8fc0ef          	jal	ra,ffffffffc0200180 <cprintf>
                    sm->map_swappable(mm, v, page, 0);
ffffffffc0203c9c:	0009b783          	ld	a5,0(s3)
ffffffffc0203ca0:	6622                	ld	a2,8(sp)
ffffffffc0203ca2:	4681                	li	a3,0
ffffffffc0203ca4:	739c                	ld	a5,32(a5)
ffffffffc0203ca6:	85a6                	mv	a1,s1
ffffffffc0203ca8:	854a                	mv	a0,s2
     for (i = 0; i != n; ++ i)
ffffffffc0203caa:	2405                	addiw	s0,s0,1
                    sm->map_swappable(mm, v, page, 0);
ffffffffc0203cac:	9782                	jalr	a5
     for (i = 0; i != n; ++ i)
ffffffffc0203cae:	fa8a17e3          	bne	s4,s0,ffffffffc0203c5c <swap_out+0x70>
}
ffffffffc0203cb2:	60e6                	ld	ra,88(sp)
ffffffffc0203cb4:	8522                	mv	a0,s0
ffffffffc0203cb6:	6446                	ld	s0,80(sp)
ffffffffc0203cb8:	64a6                	ld	s1,72(sp)
ffffffffc0203cba:	6906                	ld	s2,64(sp)
ffffffffc0203cbc:	79e2                	ld	s3,56(sp)
ffffffffc0203cbe:	7a42                	ld	s4,48(sp)
ffffffffc0203cc0:	7aa2                	ld	s5,40(sp)
ffffffffc0203cc2:	7b02                	ld	s6,32(sp)
ffffffffc0203cc4:	6be2                	ld	s7,24(sp)
ffffffffc0203cc6:	6c42                	ld	s8,16(sp)
ffffffffc0203cc8:	6125                	addi	sp,sp,96
ffffffffc0203cca:	8082                	ret
                    cprintf("i %d, swap_out: call swap_out_victim failed\n",i);
ffffffffc0203ccc:	85a2                	mv	a1,s0
ffffffffc0203cce:	00004517          	auipc	a0,0x4
ffffffffc0203cd2:	18a50513          	addi	a0,a0,394 # ffffffffc0207e58 <default_pmm_manager+0x9d8>
ffffffffc0203cd6:	caafc0ef          	jal	ra,ffffffffc0200180 <cprintf>
                  break;
ffffffffc0203cda:	bfe1                	j	ffffffffc0203cb2 <swap_out+0xc6>
     for (i = 0; i != n; ++ i)
ffffffffc0203cdc:	4401                	li	s0,0
ffffffffc0203cde:	bfd1                	j	ffffffffc0203cb2 <swap_out+0xc6>
          assert((*ptep & PTE_V) != 0);
ffffffffc0203ce0:	00004697          	auipc	a3,0x4
ffffffffc0203ce4:	1a868693          	addi	a3,a3,424 # ffffffffc0207e88 <default_pmm_manager+0xa08>
ffffffffc0203ce8:	00003617          	auipc	a2,0x3
ffffffffc0203cec:	10060613          	addi	a2,a2,256 # ffffffffc0206de8 <commands+0x450>
ffffffffc0203cf0:	06800593          	li	a1,104
ffffffffc0203cf4:	00004517          	auipc	a0,0x4
ffffffffc0203cf8:	edc50513          	addi	a0,a0,-292 # ffffffffc0207bd0 <default_pmm_manager+0x750>
ffffffffc0203cfc:	f7efc0ef          	jal	ra,ffffffffc020047a <__panic>

ffffffffc0203d00 <swap_in>:
{
ffffffffc0203d00:	7179                	addi	sp,sp,-48
ffffffffc0203d02:	e84a                	sd	s2,16(sp)
ffffffffc0203d04:	892a                	mv	s2,a0
     struct Page *result = alloc_page();
ffffffffc0203d06:	4505                	li	a0,1
{
ffffffffc0203d08:	ec26                	sd	s1,24(sp)
ffffffffc0203d0a:	e44e                	sd	s3,8(sp)
ffffffffc0203d0c:	f406                	sd	ra,40(sp)
ffffffffc0203d0e:	f022                	sd	s0,32(sp)
ffffffffc0203d10:	84ae                	mv	s1,a1
ffffffffc0203d12:	89b2                	mv	s3,a2
     struct Page *result = alloc_page();
ffffffffc0203d14:	fcdfd0ef          	jal	ra,ffffffffc0201ce0 <alloc_pages>
     assert(result!=NULL);
ffffffffc0203d18:	c129                	beqz	a0,ffffffffc0203d5a <swap_in+0x5a>
     pte_t *ptep = get_pte(mm->pgdir, addr, 0);
ffffffffc0203d1a:	842a                	mv	s0,a0
ffffffffc0203d1c:	01893503          	ld	a0,24(s2)
ffffffffc0203d20:	4601                	li	a2,0
ffffffffc0203d22:	85a6                	mv	a1,s1
ffffffffc0203d24:	8c8fe0ef          	jal	ra,ffffffffc0201dec <get_pte>
ffffffffc0203d28:	892a                	mv	s2,a0
     if ((r = swapfs_read((*ptep), result)) != 0)
ffffffffc0203d2a:	6108                	ld	a0,0(a0)
ffffffffc0203d2c:	85a2                	mv	a1,s0
ffffffffc0203d2e:	010010ef          	jal	ra,ffffffffc0204d3e <swapfs_read>
     cprintf("swap_in: load disk swap entry %d with swap_page in vadr 0x%x\n", (*ptep)>>8, addr);
ffffffffc0203d32:	00093583          	ld	a1,0(s2)
ffffffffc0203d36:	8626                	mv	a2,s1
ffffffffc0203d38:	00004517          	auipc	a0,0x4
ffffffffc0203d3c:	1d050513          	addi	a0,a0,464 # ffffffffc0207f08 <default_pmm_manager+0xa88>
ffffffffc0203d40:	81a1                	srli	a1,a1,0x8
ffffffffc0203d42:	c3efc0ef          	jal	ra,ffffffffc0200180 <cprintf>
}
ffffffffc0203d46:	70a2                	ld	ra,40(sp)
     *ptr_result=result;
ffffffffc0203d48:	0089b023          	sd	s0,0(s3)
}
ffffffffc0203d4c:	7402                	ld	s0,32(sp)
ffffffffc0203d4e:	64e2                	ld	s1,24(sp)
ffffffffc0203d50:	6942                	ld	s2,16(sp)
ffffffffc0203d52:	69a2                	ld	s3,8(sp)
ffffffffc0203d54:	4501                	li	a0,0
ffffffffc0203d56:	6145                	addi	sp,sp,48
ffffffffc0203d58:	8082                	ret
     assert(result!=NULL);
ffffffffc0203d5a:	00004697          	auipc	a3,0x4
ffffffffc0203d5e:	19e68693          	addi	a3,a3,414 # ffffffffc0207ef8 <default_pmm_manager+0xa78>
ffffffffc0203d62:	00003617          	auipc	a2,0x3
ffffffffc0203d66:	08660613          	addi	a2,a2,134 # ffffffffc0206de8 <commands+0x450>
ffffffffc0203d6a:	07e00593          	li	a1,126
ffffffffc0203d6e:	00004517          	auipc	a0,0x4
ffffffffc0203d72:	e6250513          	addi	a0,a0,-414 # ffffffffc0207bd0 <default_pmm_manager+0x750>
ffffffffc0203d76:	f04fc0ef          	jal	ra,ffffffffc020047a <__panic>

ffffffffc0203d7a <_fifo_init_mm>:
    elm->prev = elm->next = elm;
ffffffffc0203d7a:	000ab797          	auipc	a5,0xab
ffffffffc0203d7e:	ade78793          	addi	a5,a5,-1314 # ffffffffc02ae858 <pra_list_head>
 */
static int
_fifo_init_mm(struct mm_struct *mm)
{     
     list_init(&pra_list_head);
     mm->sm_priv = &pra_list_head;
ffffffffc0203d82:	f51c                	sd	a5,40(a0)
ffffffffc0203d84:	e79c                	sd	a5,8(a5)
ffffffffc0203d86:	e39c                	sd	a5,0(a5)
     //cprintf(" mm->sm_priv %x in fifo_init_mm\n",mm->sm_priv);
     return 0;
}
ffffffffc0203d88:	4501                	li	a0,0
ffffffffc0203d8a:	8082                	ret

ffffffffc0203d8c <_fifo_init>:

static int
_fifo_init(void)
{
    return 0;
}
ffffffffc0203d8c:	4501                	li	a0,0
ffffffffc0203d8e:	8082                	ret

ffffffffc0203d90 <_fifo_set_unswappable>:

static int
_fifo_set_unswappable(struct mm_struct *mm, uintptr_t addr)
{
    return 0;
}
ffffffffc0203d90:	4501                	li	a0,0
ffffffffc0203d92:	8082                	ret

ffffffffc0203d94 <_fifo_tick_event>:

static int
_fifo_tick_event(struct mm_struct *mm)
{ return 0; }
ffffffffc0203d94:	4501                	li	a0,0
ffffffffc0203d96:	8082                	ret

ffffffffc0203d98 <_fifo_check_swap>:
_fifo_check_swap(void) {
ffffffffc0203d98:	711d                	addi	sp,sp,-96
ffffffffc0203d9a:	fc4e                	sd	s3,56(sp)
ffffffffc0203d9c:	f852                	sd	s4,48(sp)
    cprintf("write Virt Page c in fifo_check_swap\n");
ffffffffc0203d9e:	00004517          	auipc	a0,0x4
ffffffffc0203da2:	1aa50513          	addi	a0,a0,426 # ffffffffc0207f48 <default_pmm_manager+0xac8>
    *(unsigned char *)0x3000 = 0x0c;
ffffffffc0203da6:	698d                	lui	s3,0x3
ffffffffc0203da8:	4a31                	li	s4,12
_fifo_check_swap(void) {
ffffffffc0203daa:	e0ca                	sd	s2,64(sp)
ffffffffc0203dac:	ec86                	sd	ra,88(sp)
ffffffffc0203dae:	e8a2                	sd	s0,80(sp)
ffffffffc0203db0:	e4a6                	sd	s1,72(sp)
ffffffffc0203db2:	f456                	sd	s5,40(sp)
ffffffffc0203db4:	f05a                	sd	s6,32(sp)
ffffffffc0203db6:	ec5e                	sd	s7,24(sp)
ffffffffc0203db8:	e862                	sd	s8,16(sp)
ffffffffc0203dba:	e466                	sd	s9,8(sp)
ffffffffc0203dbc:	e06a                	sd	s10,0(sp)
    cprintf("write Virt Page c in fifo_check_swap\n");
ffffffffc0203dbe:	bc2fc0ef          	jal	ra,ffffffffc0200180 <cprintf>
    *(unsigned char *)0x3000 = 0x0c;
ffffffffc0203dc2:	01498023          	sb	s4,0(s3) # 3000 <_binary_obj___user_faultread_out_size-0x6bb8>
    assert(pgfault_num==4);
ffffffffc0203dc6:	000af917          	auipc	s2,0xaf
ffffffffc0203dca:	b2292903          	lw	s2,-1246(s2) # ffffffffc02b28e8 <pgfault_num>
ffffffffc0203dce:	4791                	li	a5,4
ffffffffc0203dd0:	14f91e63          	bne	s2,a5,ffffffffc0203f2c <_fifo_check_swap+0x194>
    cprintf("write Virt Page a in fifo_check_swap\n");
ffffffffc0203dd4:	00004517          	auipc	a0,0x4
ffffffffc0203dd8:	1b450513          	addi	a0,a0,436 # ffffffffc0207f88 <default_pmm_manager+0xb08>
    *(unsigned char *)0x1000 = 0x0a;
ffffffffc0203ddc:	6a85                	lui	s5,0x1
ffffffffc0203dde:	4b29                	li	s6,10
    cprintf("write Virt Page a in fifo_check_swap\n");
ffffffffc0203de0:	ba0fc0ef          	jal	ra,ffffffffc0200180 <cprintf>
ffffffffc0203de4:	000af417          	auipc	s0,0xaf
ffffffffc0203de8:	b0440413          	addi	s0,s0,-1276 # ffffffffc02b28e8 <pgfault_num>
    *(unsigned char *)0x1000 = 0x0a;
ffffffffc0203dec:	016a8023          	sb	s6,0(s5) # 1000 <_binary_obj___user_faultread_out_size-0x8bb8>
    assert(pgfault_num==4);
ffffffffc0203df0:	4004                	lw	s1,0(s0)
ffffffffc0203df2:	2481                	sext.w	s1,s1
ffffffffc0203df4:	2b249c63          	bne	s1,s2,ffffffffc02040ac <_fifo_check_swap+0x314>
    cprintf("write Virt Page d in fifo_check_swap\n");
ffffffffc0203df8:	00004517          	auipc	a0,0x4
ffffffffc0203dfc:	1b850513          	addi	a0,a0,440 # ffffffffc0207fb0 <default_pmm_manager+0xb30>
    *(unsigned char *)0x4000 = 0x0d;
ffffffffc0203e00:	6b91                	lui	s7,0x4
ffffffffc0203e02:	4c35                	li	s8,13
    cprintf("write Virt Page d in fifo_check_swap\n");
ffffffffc0203e04:	b7cfc0ef          	jal	ra,ffffffffc0200180 <cprintf>
    *(unsigned char *)0x4000 = 0x0d;
ffffffffc0203e08:	018b8023          	sb	s8,0(s7) # 4000 <_binary_obj___user_faultread_out_size-0x5bb8>
    assert(pgfault_num==4);
ffffffffc0203e0c:	00042903          	lw	s2,0(s0)
ffffffffc0203e10:	2901                	sext.w	s2,s2
ffffffffc0203e12:	26991d63          	bne	s2,s1,ffffffffc020408c <_fifo_check_swap+0x2f4>
    cprintf("write Virt Page b in fifo_check_swap\n");
ffffffffc0203e16:	00004517          	auipc	a0,0x4
ffffffffc0203e1a:	1c250513          	addi	a0,a0,450 # ffffffffc0207fd8 <default_pmm_manager+0xb58>
    *(unsigned char *)0x2000 = 0x0b;
ffffffffc0203e1e:	6c89                	lui	s9,0x2
ffffffffc0203e20:	4d2d                	li	s10,11
    cprintf("write Virt Page b in fifo_check_swap\n");
ffffffffc0203e22:	b5efc0ef          	jal	ra,ffffffffc0200180 <cprintf>
    *(unsigned char *)0x2000 = 0x0b;
ffffffffc0203e26:	01ac8023          	sb	s10,0(s9) # 2000 <_binary_obj___user_faultread_out_size-0x7bb8>
    assert(pgfault_num==4);
ffffffffc0203e2a:	401c                	lw	a5,0(s0)
ffffffffc0203e2c:	2781                	sext.w	a5,a5
ffffffffc0203e2e:	23279f63          	bne	a5,s2,ffffffffc020406c <_fifo_check_swap+0x2d4>
    cprintf("write Virt Page e in fifo_check_swap\n");
ffffffffc0203e32:	00004517          	auipc	a0,0x4
ffffffffc0203e36:	1ce50513          	addi	a0,a0,462 # ffffffffc0208000 <default_pmm_manager+0xb80>
ffffffffc0203e3a:	b46fc0ef          	jal	ra,ffffffffc0200180 <cprintf>
    *(unsigned char *)0x5000 = 0x0e;
ffffffffc0203e3e:	6795                	lui	a5,0x5
ffffffffc0203e40:	4739                	li	a4,14
ffffffffc0203e42:	00e78023          	sb	a4,0(a5) # 5000 <_binary_obj___user_faultread_out_size-0x4bb8>
    assert(pgfault_num==5);
ffffffffc0203e46:	4004                	lw	s1,0(s0)
ffffffffc0203e48:	4795                	li	a5,5
ffffffffc0203e4a:	2481                	sext.w	s1,s1
ffffffffc0203e4c:	20f49063          	bne	s1,a5,ffffffffc020404c <_fifo_check_swap+0x2b4>
    cprintf("write Virt Page b in fifo_check_swap\n");
ffffffffc0203e50:	00004517          	auipc	a0,0x4
ffffffffc0203e54:	18850513          	addi	a0,a0,392 # ffffffffc0207fd8 <default_pmm_manager+0xb58>
ffffffffc0203e58:	b28fc0ef          	jal	ra,ffffffffc0200180 <cprintf>
    *(unsigned char *)0x2000 = 0x0b;
ffffffffc0203e5c:	01ac8023          	sb	s10,0(s9)
    assert(pgfault_num==5);
ffffffffc0203e60:	401c                	lw	a5,0(s0)
ffffffffc0203e62:	2781                	sext.w	a5,a5
ffffffffc0203e64:	1c979463          	bne	a5,s1,ffffffffc020402c <_fifo_check_swap+0x294>
    cprintf("write Virt Page a in fifo_check_swap\n");
ffffffffc0203e68:	00004517          	auipc	a0,0x4
ffffffffc0203e6c:	12050513          	addi	a0,a0,288 # ffffffffc0207f88 <default_pmm_manager+0xb08>
ffffffffc0203e70:	b10fc0ef          	jal	ra,ffffffffc0200180 <cprintf>
    *(unsigned char *)0x1000 = 0x0a;
ffffffffc0203e74:	016a8023          	sb	s6,0(s5)
    assert(pgfault_num==6);
ffffffffc0203e78:	401c                	lw	a5,0(s0)
ffffffffc0203e7a:	4719                	li	a4,6
ffffffffc0203e7c:	2781                	sext.w	a5,a5
ffffffffc0203e7e:	18e79763          	bne	a5,a4,ffffffffc020400c <_fifo_check_swap+0x274>
    cprintf("write Virt Page b in fifo_check_swap\n");
ffffffffc0203e82:	00004517          	auipc	a0,0x4
ffffffffc0203e86:	15650513          	addi	a0,a0,342 # ffffffffc0207fd8 <default_pmm_manager+0xb58>
ffffffffc0203e8a:	af6fc0ef          	jal	ra,ffffffffc0200180 <cprintf>
    *(unsigned char *)0x2000 = 0x0b;
ffffffffc0203e8e:	01ac8023          	sb	s10,0(s9)
    assert(pgfault_num==7);
ffffffffc0203e92:	401c                	lw	a5,0(s0)
ffffffffc0203e94:	471d                	li	a4,7
ffffffffc0203e96:	2781                	sext.w	a5,a5
ffffffffc0203e98:	14e79a63          	bne	a5,a4,ffffffffc0203fec <_fifo_check_swap+0x254>
    cprintf("write Virt Page c in fifo_check_swap\n");
ffffffffc0203e9c:	00004517          	auipc	a0,0x4
ffffffffc0203ea0:	0ac50513          	addi	a0,a0,172 # ffffffffc0207f48 <default_pmm_manager+0xac8>
ffffffffc0203ea4:	adcfc0ef          	jal	ra,ffffffffc0200180 <cprintf>
    *(unsigned char *)0x3000 = 0x0c;
ffffffffc0203ea8:	01498023          	sb	s4,0(s3)
    assert(pgfault_num==8);
ffffffffc0203eac:	401c                	lw	a5,0(s0)
ffffffffc0203eae:	4721                	li	a4,8
ffffffffc0203eb0:	2781                	sext.w	a5,a5
ffffffffc0203eb2:	10e79d63          	bne	a5,a4,ffffffffc0203fcc <_fifo_check_swap+0x234>
    cprintf("write Virt Page d in fifo_check_swap\n");
ffffffffc0203eb6:	00004517          	auipc	a0,0x4
ffffffffc0203eba:	0fa50513          	addi	a0,a0,250 # ffffffffc0207fb0 <default_pmm_manager+0xb30>
ffffffffc0203ebe:	ac2fc0ef          	jal	ra,ffffffffc0200180 <cprintf>
    *(unsigned char *)0x4000 = 0x0d;
ffffffffc0203ec2:	018b8023          	sb	s8,0(s7)
    assert(pgfault_num==9);
ffffffffc0203ec6:	401c                	lw	a5,0(s0)
ffffffffc0203ec8:	4725                	li	a4,9
ffffffffc0203eca:	2781                	sext.w	a5,a5
ffffffffc0203ecc:	0ee79063          	bne	a5,a4,ffffffffc0203fac <_fifo_check_swap+0x214>
    cprintf("write Virt Page e in fifo_check_swap\n");
ffffffffc0203ed0:	00004517          	auipc	a0,0x4
ffffffffc0203ed4:	13050513          	addi	a0,a0,304 # ffffffffc0208000 <default_pmm_manager+0xb80>
ffffffffc0203ed8:	aa8fc0ef          	jal	ra,ffffffffc0200180 <cprintf>
    *(unsigned char *)0x5000 = 0x0e;
ffffffffc0203edc:	6795                	lui	a5,0x5
ffffffffc0203ede:	4739                	li	a4,14
ffffffffc0203ee0:	00e78023          	sb	a4,0(a5) # 5000 <_binary_obj___user_faultread_out_size-0x4bb8>
    assert(pgfault_num==10);
ffffffffc0203ee4:	4004                	lw	s1,0(s0)
ffffffffc0203ee6:	47a9                	li	a5,10
ffffffffc0203ee8:	2481                	sext.w	s1,s1
ffffffffc0203eea:	0af49163          	bne	s1,a5,ffffffffc0203f8c <_fifo_check_swap+0x1f4>
    cprintf("write Virt Page a in fifo_check_swap\n");
ffffffffc0203eee:	00004517          	auipc	a0,0x4
ffffffffc0203ef2:	09a50513          	addi	a0,a0,154 # ffffffffc0207f88 <default_pmm_manager+0xb08>
ffffffffc0203ef6:	a8afc0ef          	jal	ra,ffffffffc0200180 <cprintf>
    assert(*(unsigned char *)0x1000 == 0x0a);
ffffffffc0203efa:	6785                	lui	a5,0x1
ffffffffc0203efc:	0007c783          	lbu	a5,0(a5) # 1000 <_binary_obj___user_faultread_out_size-0x8bb8>
ffffffffc0203f00:	06979663          	bne	a5,s1,ffffffffc0203f6c <_fifo_check_swap+0x1d4>
    assert(pgfault_num==11);
ffffffffc0203f04:	401c                	lw	a5,0(s0)
ffffffffc0203f06:	472d                	li	a4,11
ffffffffc0203f08:	2781                	sext.w	a5,a5
ffffffffc0203f0a:	04e79163          	bne	a5,a4,ffffffffc0203f4c <_fifo_check_swap+0x1b4>
}
ffffffffc0203f0e:	60e6                	ld	ra,88(sp)
ffffffffc0203f10:	6446                	ld	s0,80(sp)
ffffffffc0203f12:	64a6                	ld	s1,72(sp)
ffffffffc0203f14:	6906                	ld	s2,64(sp)
ffffffffc0203f16:	79e2                	ld	s3,56(sp)
ffffffffc0203f18:	7a42                	ld	s4,48(sp)
ffffffffc0203f1a:	7aa2                	ld	s5,40(sp)
ffffffffc0203f1c:	7b02                	ld	s6,32(sp)
ffffffffc0203f1e:	6be2                	ld	s7,24(sp)
ffffffffc0203f20:	6c42                	ld	s8,16(sp)
ffffffffc0203f22:	6ca2                	ld	s9,8(sp)
ffffffffc0203f24:	6d02                	ld	s10,0(sp)
ffffffffc0203f26:	4501                	li	a0,0
ffffffffc0203f28:	6125                	addi	sp,sp,96
ffffffffc0203f2a:	8082                	ret
    assert(pgfault_num==4);
ffffffffc0203f2c:	00004697          	auipc	a3,0x4
ffffffffc0203f30:	e6c68693          	addi	a3,a3,-404 # ffffffffc0207d98 <default_pmm_manager+0x918>
ffffffffc0203f34:	00003617          	auipc	a2,0x3
ffffffffc0203f38:	eb460613          	addi	a2,a2,-332 # ffffffffc0206de8 <commands+0x450>
ffffffffc0203f3c:	05500593          	li	a1,85
ffffffffc0203f40:	00004517          	auipc	a0,0x4
ffffffffc0203f44:	03050513          	addi	a0,a0,48 # ffffffffc0207f70 <default_pmm_manager+0xaf0>
ffffffffc0203f48:	d32fc0ef          	jal	ra,ffffffffc020047a <__panic>
    assert(pgfault_num==11);
ffffffffc0203f4c:	00004697          	auipc	a3,0x4
ffffffffc0203f50:	16468693          	addi	a3,a3,356 # ffffffffc02080b0 <default_pmm_manager+0xc30>
ffffffffc0203f54:	00003617          	auipc	a2,0x3
ffffffffc0203f58:	e9460613          	addi	a2,a2,-364 # ffffffffc0206de8 <commands+0x450>
ffffffffc0203f5c:	07700593          	li	a1,119
ffffffffc0203f60:	00004517          	auipc	a0,0x4
ffffffffc0203f64:	01050513          	addi	a0,a0,16 # ffffffffc0207f70 <default_pmm_manager+0xaf0>
ffffffffc0203f68:	d12fc0ef          	jal	ra,ffffffffc020047a <__panic>
    assert(*(unsigned char *)0x1000 == 0x0a);
ffffffffc0203f6c:	00004697          	auipc	a3,0x4
ffffffffc0203f70:	11c68693          	addi	a3,a3,284 # ffffffffc0208088 <default_pmm_manager+0xc08>
ffffffffc0203f74:	00003617          	auipc	a2,0x3
ffffffffc0203f78:	e7460613          	addi	a2,a2,-396 # ffffffffc0206de8 <commands+0x450>
ffffffffc0203f7c:	07500593          	li	a1,117
ffffffffc0203f80:	00004517          	auipc	a0,0x4
ffffffffc0203f84:	ff050513          	addi	a0,a0,-16 # ffffffffc0207f70 <default_pmm_manager+0xaf0>
ffffffffc0203f88:	cf2fc0ef          	jal	ra,ffffffffc020047a <__panic>
    assert(pgfault_num==10);
ffffffffc0203f8c:	00004697          	auipc	a3,0x4
ffffffffc0203f90:	0ec68693          	addi	a3,a3,236 # ffffffffc0208078 <default_pmm_manager+0xbf8>
ffffffffc0203f94:	00003617          	auipc	a2,0x3
ffffffffc0203f98:	e5460613          	addi	a2,a2,-428 # ffffffffc0206de8 <commands+0x450>
ffffffffc0203f9c:	07300593          	li	a1,115
ffffffffc0203fa0:	00004517          	auipc	a0,0x4
ffffffffc0203fa4:	fd050513          	addi	a0,a0,-48 # ffffffffc0207f70 <default_pmm_manager+0xaf0>
ffffffffc0203fa8:	cd2fc0ef          	jal	ra,ffffffffc020047a <__panic>
    assert(pgfault_num==9);
ffffffffc0203fac:	00004697          	auipc	a3,0x4
ffffffffc0203fb0:	0bc68693          	addi	a3,a3,188 # ffffffffc0208068 <default_pmm_manager+0xbe8>
ffffffffc0203fb4:	00003617          	auipc	a2,0x3
ffffffffc0203fb8:	e3460613          	addi	a2,a2,-460 # ffffffffc0206de8 <commands+0x450>
ffffffffc0203fbc:	07000593          	li	a1,112
ffffffffc0203fc0:	00004517          	auipc	a0,0x4
ffffffffc0203fc4:	fb050513          	addi	a0,a0,-80 # ffffffffc0207f70 <default_pmm_manager+0xaf0>
ffffffffc0203fc8:	cb2fc0ef          	jal	ra,ffffffffc020047a <__panic>
    assert(pgfault_num==8);
ffffffffc0203fcc:	00004697          	auipc	a3,0x4
ffffffffc0203fd0:	08c68693          	addi	a3,a3,140 # ffffffffc0208058 <default_pmm_manager+0xbd8>
ffffffffc0203fd4:	00003617          	auipc	a2,0x3
ffffffffc0203fd8:	e1460613          	addi	a2,a2,-492 # ffffffffc0206de8 <commands+0x450>
ffffffffc0203fdc:	06d00593          	li	a1,109
ffffffffc0203fe0:	00004517          	auipc	a0,0x4
ffffffffc0203fe4:	f9050513          	addi	a0,a0,-112 # ffffffffc0207f70 <default_pmm_manager+0xaf0>
ffffffffc0203fe8:	c92fc0ef          	jal	ra,ffffffffc020047a <__panic>
    assert(pgfault_num==7);
ffffffffc0203fec:	00004697          	auipc	a3,0x4
ffffffffc0203ff0:	05c68693          	addi	a3,a3,92 # ffffffffc0208048 <default_pmm_manager+0xbc8>
ffffffffc0203ff4:	00003617          	auipc	a2,0x3
ffffffffc0203ff8:	df460613          	addi	a2,a2,-524 # ffffffffc0206de8 <commands+0x450>
ffffffffc0203ffc:	06a00593          	li	a1,106
ffffffffc0204000:	00004517          	auipc	a0,0x4
ffffffffc0204004:	f7050513          	addi	a0,a0,-144 # ffffffffc0207f70 <default_pmm_manager+0xaf0>
ffffffffc0204008:	c72fc0ef          	jal	ra,ffffffffc020047a <__panic>
    assert(pgfault_num==6);
ffffffffc020400c:	00004697          	auipc	a3,0x4
ffffffffc0204010:	02c68693          	addi	a3,a3,44 # ffffffffc0208038 <default_pmm_manager+0xbb8>
ffffffffc0204014:	00003617          	auipc	a2,0x3
ffffffffc0204018:	dd460613          	addi	a2,a2,-556 # ffffffffc0206de8 <commands+0x450>
ffffffffc020401c:	06700593          	li	a1,103
ffffffffc0204020:	00004517          	auipc	a0,0x4
ffffffffc0204024:	f5050513          	addi	a0,a0,-176 # ffffffffc0207f70 <default_pmm_manager+0xaf0>
ffffffffc0204028:	c52fc0ef          	jal	ra,ffffffffc020047a <__panic>
    assert(pgfault_num==5);
ffffffffc020402c:	00004697          	auipc	a3,0x4
ffffffffc0204030:	ffc68693          	addi	a3,a3,-4 # ffffffffc0208028 <default_pmm_manager+0xba8>
ffffffffc0204034:	00003617          	auipc	a2,0x3
ffffffffc0204038:	db460613          	addi	a2,a2,-588 # ffffffffc0206de8 <commands+0x450>
ffffffffc020403c:	06400593          	li	a1,100
ffffffffc0204040:	00004517          	auipc	a0,0x4
ffffffffc0204044:	f3050513          	addi	a0,a0,-208 # ffffffffc0207f70 <default_pmm_manager+0xaf0>
ffffffffc0204048:	c32fc0ef          	jal	ra,ffffffffc020047a <__panic>
    assert(pgfault_num==5);
ffffffffc020404c:	00004697          	auipc	a3,0x4
ffffffffc0204050:	fdc68693          	addi	a3,a3,-36 # ffffffffc0208028 <default_pmm_manager+0xba8>
ffffffffc0204054:	00003617          	auipc	a2,0x3
ffffffffc0204058:	d9460613          	addi	a2,a2,-620 # ffffffffc0206de8 <commands+0x450>
ffffffffc020405c:	06100593          	li	a1,97
ffffffffc0204060:	00004517          	auipc	a0,0x4
ffffffffc0204064:	f1050513          	addi	a0,a0,-240 # ffffffffc0207f70 <default_pmm_manager+0xaf0>
ffffffffc0204068:	c12fc0ef          	jal	ra,ffffffffc020047a <__panic>
    assert(pgfault_num==4);
ffffffffc020406c:	00004697          	auipc	a3,0x4
ffffffffc0204070:	d2c68693          	addi	a3,a3,-724 # ffffffffc0207d98 <default_pmm_manager+0x918>
ffffffffc0204074:	00003617          	auipc	a2,0x3
ffffffffc0204078:	d7460613          	addi	a2,a2,-652 # ffffffffc0206de8 <commands+0x450>
ffffffffc020407c:	05e00593          	li	a1,94
ffffffffc0204080:	00004517          	auipc	a0,0x4
ffffffffc0204084:	ef050513          	addi	a0,a0,-272 # ffffffffc0207f70 <default_pmm_manager+0xaf0>
ffffffffc0204088:	bf2fc0ef          	jal	ra,ffffffffc020047a <__panic>
    assert(pgfault_num==4);
ffffffffc020408c:	00004697          	auipc	a3,0x4
ffffffffc0204090:	d0c68693          	addi	a3,a3,-756 # ffffffffc0207d98 <default_pmm_manager+0x918>
ffffffffc0204094:	00003617          	auipc	a2,0x3
ffffffffc0204098:	d5460613          	addi	a2,a2,-684 # ffffffffc0206de8 <commands+0x450>
ffffffffc020409c:	05b00593          	li	a1,91
ffffffffc02040a0:	00004517          	auipc	a0,0x4
ffffffffc02040a4:	ed050513          	addi	a0,a0,-304 # ffffffffc0207f70 <default_pmm_manager+0xaf0>
ffffffffc02040a8:	bd2fc0ef          	jal	ra,ffffffffc020047a <__panic>
    assert(pgfault_num==4);
ffffffffc02040ac:	00004697          	auipc	a3,0x4
ffffffffc02040b0:	cec68693          	addi	a3,a3,-788 # ffffffffc0207d98 <default_pmm_manager+0x918>
ffffffffc02040b4:	00003617          	auipc	a2,0x3
ffffffffc02040b8:	d3460613          	addi	a2,a2,-716 # ffffffffc0206de8 <commands+0x450>
ffffffffc02040bc:	05800593          	li	a1,88
ffffffffc02040c0:	00004517          	auipc	a0,0x4
ffffffffc02040c4:	eb050513          	addi	a0,a0,-336 # ffffffffc0207f70 <default_pmm_manager+0xaf0>
ffffffffc02040c8:	bb2fc0ef          	jal	ra,ffffffffc020047a <__panic>

ffffffffc02040cc <_fifo_swap_out_victim>:
     list_entry_t *head=(list_entry_t*) mm->sm_priv;
ffffffffc02040cc:	7518                	ld	a4,40(a0)
{
ffffffffc02040ce:	1141                	addi	sp,sp,-16
ffffffffc02040d0:	e406                	sd	ra,8(sp)
         assert(head != NULL);
ffffffffc02040d2:	c731                	beqz	a4,ffffffffc020411e <_fifo_swap_out_victim+0x52>
     assert(in_tick==0);
ffffffffc02040d4:	e60d                	bnez	a2,ffffffffc02040fe <_fifo_swap_out_victim+0x32>
    return listelm->prev;
ffffffffc02040d6:	631c                	ld	a5,0(a4)
     if (entry != head) {
ffffffffc02040d8:	00f70d63          	beq	a4,a5,ffffffffc02040f2 <_fifo_swap_out_victim+0x26>
    __list_del(listelm->prev, listelm->next);
ffffffffc02040dc:	6394                	ld	a3,0(a5)
ffffffffc02040de:	6798                	ld	a4,8(a5)
}
ffffffffc02040e0:	60a2                	ld	ra,8(sp)
         *ptr_page = le2page(entry, pra_page_link);
ffffffffc02040e2:	fd878793          	addi	a5,a5,-40
    prev->next = next;
ffffffffc02040e6:	e698                	sd	a4,8(a3)
    next->prev = prev;
ffffffffc02040e8:	e314                	sd	a3,0(a4)
ffffffffc02040ea:	e19c                	sd	a5,0(a1)
}
ffffffffc02040ec:	4501                	li	a0,0
ffffffffc02040ee:	0141                	addi	sp,sp,16
ffffffffc02040f0:	8082                	ret
ffffffffc02040f2:	60a2                	ld	ra,8(sp)
         *ptr_page = NULL;
ffffffffc02040f4:	0005b023          	sd	zero,0(a1) # 1000 <_binary_obj___user_faultread_out_size-0x8bb8>
}
ffffffffc02040f8:	4501                	li	a0,0
ffffffffc02040fa:	0141                	addi	sp,sp,16
ffffffffc02040fc:	8082                	ret
     assert(in_tick==0);
ffffffffc02040fe:	00004697          	auipc	a3,0x4
ffffffffc0204102:	fd268693          	addi	a3,a3,-46 # ffffffffc02080d0 <default_pmm_manager+0xc50>
ffffffffc0204106:	00003617          	auipc	a2,0x3
ffffffffc020410a:	ce260613          	addi	a2,a2,-798 # ffffffffc0206de8 <commands+0x450>
ffffffffc020410e:	04200593          	li	a1,66
ffffffffc0204112:	00004517          	auipc	a0,0x4
ffffffffc0204116:	e5e50513          	addi	a0,a0,-418 # ffffffffc0207f70 <default_pmm_manager+0xaf0>
ffffffffc020411a:	b60fc0ef          	jal	ra,ffffffffc020047a <__panic>
         assert(head != NULL);
ffffffffc020411e:	00004697          	auipc	a3,0x4
ffffffffc0204122:	fa268693          	addi	a3,a3,-94 # ffffffffc02080c0 <default_pmm_manager+0xc40>
ffffffffc0204126:	00003617          	auipc	a2,0x3
ffffffffc020412a:	cc260613          	addi	a2,a2,-830 # ffffffffc0206de8 <commands+0x450>
ffffffffc020412e:	04100593          	li	a1,65
ffffffffc0204132:	00004517          	auipc	a0,0x4
ffffffffc0204136:	e3e50513          	addi	a0,a0,-450 # ffffffffc0207f70 <default_pmm_manager+0xaf0>
ffffffffc020413a:	b40fc0ef          	jal	ra,ffffffffc020047a <__panic>

ffffffffc020413e <_fifo_map_swappable>:
    list_entry_t *head=(list_entry_t*) mm->sm_priv;
ffffffffc020413e:	751c                	ld	a5,40(a0)
    assert(entry != NULL && head != NULL);
ffffffffc0204140:	cb91                	beqz	a5,ffffffffc0204154 <_fifo_map_swappable+0x16>
    __list_add(elm, listelm, listelm->next);
ffffffffc0204142:	6794                	ld	a3,8(a5)
ffffffffc0204144:	02860713          	addi	a4,a2,40
}
ffffffffc0204148:	4501                	li	a0,0
    prev->next = next->prev = elm;
ffffffffc020414a:	e298                	sd	a4,0(a3)
ffffffffc020414c:	e798                	sd	a4,8(a5)
    elm->next = next;
ffffffffc020414e:	fa14                	sd	a3,48(a2)
    elm->prev = prev;
ffffffffc0204150:	f61c                	sd	a5,40(a2)
ffffffffc0204152:	8082                	ret
{
ffffffffc0204154:	1141                	addi	sp,sp,-16
    assert(entry != NULL && head != NULL);
ffffffffc0204156:	00004697          	auipc	a3,0x4
ffffffffc020415a:	f8a68693          	addi	a3,a3,-118 # ffffffffc02080e0 <default_pmm_manager+0xc60>
ffffffffc020415e:	00003617          	auipc	a2,0x3
ffffffffc0204162:	c8a60613          	addi	a2,a2,-886 # ffffffffc0206de8 <commands+0x450>
ffffffffc0204166:	03200593          	li	a1,50
ffffffffc020416a:	00004517          	auipc	a0,0x4
ffffffffc020416e:	e0650513          	addi	a0,a0,-506 # ffffffffc0207f70 <default_pmm_manager+0xaf0>
{
ffffffffc0204172:	e406                	sd	ra,8(sp)
    assert(entry != NULL && head != NULL);
ffffffffc0204174:	b06fc0ef          	jal	ra,ffffffffc020047a <__panic>

ffffffffc0204178 <check_vma_overlap.part.0>:
}


// check_vma_overlap - check if vma1 overlaps vma2 ?
static inline void
check_vma_overlap(struct vma_struct *prev, struct vma_struct *next) {
ffffffffc0204178:	1141                	addi	sp,sp,-16
    assert(prev->vm_start < prev->vm_end);
    assert(prev->vm_end <= next->vm_start);
    assert(next->vm_start < next->vm_end);
ffffffffc020417a:	00004697          	auipc	a3,0x4
ffffffffc020417e:	f9e68693          	addi	a3,a3,-98 # ffffffffc0208118 <default_pmm_manager+0xc98>
ffffffffc0204182:	00003617          	auipc	a2,0x3
ffffffffc0204186:	c6660613          	addi	a2,a2,-922 # ffffffffc0206de8 <commands+0x450>
ffffffffc020418a:	06d00593          	li	a1,109
ffffffffc020418e:	00004517          	auipc	a0,0x4
ffffffffc0204192:	faa50513          	addi	a0,a0,-86 # ffffffffc0208138 <default_pmm_manager+0xcb8>
check_vma_overlap(struct vma_struct *prev, struct vma_struct *next) {
ffffffffc0204196:	e406                	sd	ra,8(sp)
    assert(next->vm_start < next->vm_end);
ffffffffc0204198:	ae2fc0ef          	jal	ra,ffffffffc020047a <__panic>

ffffffffc020419c <pa2page.part.0>:
pa2page(uintptr_t pa) {
ffffffffc020419c:	1141                	addi	sp,sp,-16
        panic("pa2page called with invalid pa");
ffffffffc020419e:	00003617          	auipc	a2,0x3
ffffffffc02041a2:	3ea60613          	addi	a2,a2,1002 # ffffffffc0207588 <default_pmm_manager+0x108>
ffffffffc02041a6:	06200593          	li	a1,98
ffffffffc02041aa:	00003517          	auipc	a0,0x3
ffffffffc02041ae:	33650513          	addi	a0,a0,822 # ffffffffc02074e0 <default_pmm_manager+0x60>
pa2page(uintptr_t pa) {
ffffffffc02041b2:	e406                	sd	ra,8(sp)
        panic("pa2page called with invalid pa");
ffffffffc02041b4:	ac6fc0ef          	jal	ra,ffffffffc020047a <__panic>

ffffffffc02041b8 <mm_create>:
mm_create(void) {
ffffffffc02041b8:	1141                	addi	sp,sp,-16
    struct mm_struct *mm = kmalloc(sizeof(struct mm_struct));
ffffffffc02041ba:	04000513          	li	a0,64
mm_create(void) {
ffffffffc02041be:	e022                	sd	s0,0(sp)
ffffffffc02041c0:	e406                	sd	ra,8(sp)
    struct mm_struct *mm = kmalloc(sizeof(struct mm_struct));
ffffffffc02041c2:	941fd0ef          	jal	ra,ffffffffc0201b02 <kmalloc>
ffffffffc02041c6:	842a                	mv	s0,a0
    if (mm != NULL) {
ffffffffc02041c8:	c505                	beqz	a0,ffffffffc02041f0 <mm_create+0x38>
    elm->prev = elm->next = elm;
ffffffffc02041ca:	e408                	sd	a0,8(s0)
ffffffffc02041cc:	e008                	sd	a0,0(s0)
        mm->mmap_cache = NULL;
ffffffffc02041ce:	00053823          	sd	zero,16(a0)
        mm->pgdir = NULL;
ffffffffc02041d2:	00053c23          	sd	zero,24(a0)
        mm->map_count = 0;
ffffffffc02041d6:	02052023          	sw	zero,32(a0)
        if (swap_init_ok) swap_init_mm(mm);
ffffffffc02041da:	000ae797          	auipc	a5,0xae
ffffffffc02041de:	6fe7a783          	lw	a5,1790(a5) # ffffffffc02b28d8 <swap_init_ok>
ffffffffc02041e2:	ef81                	bnez	a5,ffffffffc02041fa <mm_create+0x42>
        else mm->sm_priv = NULL;
ffffffffc02041e4:	02053423          	sd	zero,40(a0)
    return mm->mm_count;
}

static inline void
set_mm_count(struct mm_struct *mm, int val) {
    mm->mm_count = val;
ffffffffc02041e8:	02042823          	sw	zero,48(s0)

typedef volatile bool lock_t;

static inline void
lock_init(lock_t *lock) {
    *lock = 0;
ffffffffc02041ec:	02043c23          	sd	zero,56(s0)
}
ffffffffc02041f0:	60a2                	ld	ra,8(sp)
ffffffffc02041f2:	8522                	mv	a0,s0
ffffffffc02041f4:	6402                	ld	s0,0(sp)
ffffffffc02041f6:	0141                	addi	sp,sp,16
ffffffffc02041f8:	8082                	ret
        if (swap_init_ok) swap_init_mm(mm);
ffffffffc02041fa:	9dbff0ef          	jal	ra,ffffffffc0203bd4 <swap_init_mm>
ffffffffc02041fe:	b7ed                	j	ffffffffc02041e8 <mm_create+0x30>

ffffffffc0204200 <vma_create>:
vma_create(uintptr_t vm_start, uintptr_t vm_end, uint32_t vm_flags) {
ffffffffc0204200:	1101                	addi	sp,sp,-32
ffffffffc0204202:	e04a                	sd	s2,0(sp)
ffffffffc0204204:	892a                	mv	s2,a0
    struct vma_struct *vma = kmalloc(sizeof(struct vma_struct));
ffffffffc0204206:	03000513          	li	a0,48
vma_create(uintptr_t vm_start, uintptr_t vm_end, uint32_t vm_flags) {
ffffffffc020420a:	e822                	sd	s0,16(sp)
ffffffffc020420c:	e426                	sd	s1,8(sp)
ffffffffc020420e:	ec06                	sd	ra,24(sp)
ffffffffc0204210:	84ae                	mv	s1,a1
ffffffffc0204212:	8432                	mv	s0,a2
    struct vma_struct *vma = kmalloc(sizeof(struct vma_struct));
ffffffffc0204214:	8effd0ef          	jal	ra,ffffffffc0201b02 <kmalloc>
    if (vma != NULL) {
ffffffffc0204218:	c509                	beqz	a0,ffffffffc0204222 <vma_create+0x22>
        vma->vm_start = vm_start;
ffffffffc020421a:	01253423          	sd	s2,8(a0)
        vma->vm_end = vm_end;
ffffffffc020421e:	e904                	sd	s1,16(a0)
        vma->vm_flags = vm_flags;
ffffffffc0204220:	cd00                	sw	s0,24(a0)
}
ffffffffc0204222:	60e2                	ld	ra,24(sp)
ffffffffc0204224:	6442                	ld	s0,16(sp)
ffffffffc0204226:	64a2                	ld	s1,8(sp)
ffffffffc0204228:	6902                	ld	s2,0(sp)
ffffffffc020422a:	6105                	addi	sp,sp,32
ffffffffc020422c:	8082                	ret

ffffffffc020422e <find_vma>:
find_vma(struct mm_struct *mm, uintptr_t addr) {
ffffffffc020422e:	86aa                	mv	a3,a0
    if (mm != NULL) {
ffffffffc0204230:	c505                	beqz	a0,ffffffffc0204258 <find_vma+0x2a>
        vma = mm->mmap_cache;
ffffffffc0204232:	6908                	ld	a0,16(a0)
        if (!(vma != NULL && vma->vm_start <= addr && vma->vm_end > addr)) {
ffffffffc0204234:	c501                	beqz	a0,ffffffffc020423c <find_vma+0xe>
ffffffffc0204236:	651c                	ld	a5,8(a0)
ffffffffc0204238:	02f5f263          	bgeu	a1,a5,ffffffffc020425c <find_vma+0x2e>
    return listelm->next;
ffffffffc020423c:	669c                	ld	a5,8(a3)
                while ((le = list_next(le)) != list) {
ffffffffc020423e:	00f68d63          	beq	a3,a5,ffffffffc0204258 <find_vma+0x2a>
                    if (vma->vm_start<=addr && addr < vma->vm_end) {
ffffffffc0204242:	fe87b703          	ld	a4,-24(a5)
ffffffffc0204246:	00e5e663          	bltu	a1,a4,ffffffffc0204252 <find_vma+0x24>
ffffffffc020424a:	ff07b703          	ld	a4,-16(a5)
ffffffffc020424e:	00e5ec63          	bltu	a1,a4,ffffffffc0204266 <find_vma+0x38>
ffffffffc0204252:	679c                	ld	a5,8(a5)
                while ((le = list_next(le)) != list) {
ffffffffc0204254:	fef697e3          	bne	a3,a5,ffffffffc0204242 <find_vma+0x14>
    struct vma_struct *vma = NULL;
ffffffffc0204258:	4501                	li	a0,0
}
ffffffffc020425a:	8082                	ret
        if (!(vma != NULL && vma->vm_start <= addr && vma->vm_end > addr)) {
ffffffffc020425c:	691c                	ld	a5,16(a0)
ffffffffc020425e:	fcf5ffe3          	bgeu	a1,a5,ffffffffc020423c <find_vma+0xe>
            mm->mmap_cache = vma;
ffffffffc0204262:	ea88                	sd	a0,16(a3)
ffffffffc0204264:	8082                	ret
                    vma = le2vma(le, list_link);
ffffffffc0204266:	fe078513          	addi	a0,a5,-32
            mm->mmap_cache = vma;
ffffffffc020426a:	ea88                	sd	a0,16(a3)
ffffffffc020426c:	8082                	ret

ffffffffc020426e <insert_vma_struct>:


// insert_vma_struct -insert vma in mm's list link
void
insert_vma_struct(struct mm_struct *mm, struct vma_struct *vma) {
    assert(vma->vm_start < vma->vm_end);
ffffffffc020426e:	6590                	ld	a2,8(a1)
ffffffffc0204270:	0105b803          	ld	a6,16(a1)
insert_vma_struct(struct mm_struct *mm, struct vma_struct *vma) {
ffffffffc0204274:	1141                	addi	sp,sp,-16
ffffffffc0204276:	e406                	sd	ra,8(sp)
ffffffffc0204278:	87aa                	mv	a5,a0
    assert(vma->vm_start < vma->vm_end);
ffffffffc020427a:	01066763          	bltu	a2,a6,ffffffffc0204288 <insert_vma_struct+0x1a>
ffffffffc020427e:	a085                	j	ffffffffc02042de <insert_vma_struct+0x70>
    list_entry_t *le_prev = list, *le_next;

        list_entry_t *le = list;
        while ((le = list_next(le)) != list) {
            struct vma_struct *mmap_prev = le2vma(le, list_link);
            if (mmap_prev->vm_start > vma->vm_start) {
ffffffffc0204280:	fe87b703          	ld	a4,-24(a5)
ffffffffc0204284:	04e66863          	bltu	a2,a4,ffffffffc02042d4 <insert_vma_struct+0x66>
ffffffffc0204288:	86be                	mv	a3,a5
ffffffffc020428a:	679c                	ld	a5,8(a5)
        while ((le = list_next(le)) != list) {
ffffffffc020428c:	fef51ae3          	bne	a0,a5,ffffffffc0204280 <insert_vma_struct+0x12>
        }

    le_next = list_next(le_prev);

    /* check overlap */
    if (le_prev != list) {
ffffffffc0204290:	02a68463          	beq	a3,a0,ffffffffc02042b8 <insert_vma_struct+0x4a>
        check_vma_overlap(le2vma(le_prev, list_link), vma);
ffffffffc0204294:	ff06b703          	ld	a4,-16(a3)
    assert(prev->vm_start < prev->vm_end);
ffffffffc0204298:	fe86b883          	ld	a7,-24(a3)
ffffffffc020429c:	08e8f163          	bgeu	a7,a4,ffffffffc020431e <insert_vma_struct+0xb0>
    assert(prev->vm_end <= next->vm_start);
ffffffffc02042a0:	04e66f63          	bltu	a2,a4,ffffffffc02042fe <insert_vma_struct+0x90>
    }
    if (le_next != list) {
ffffffffc02042a4:	00f50a63          	beq	a0,a5,ffffffffc02042b8 <insert_vma_struct+0x4a>
            if (mmap_prev->vm_start > vma->vm_start) {
ffffffffc02042a8:	fe87b703          	ld	a4,-24(a5)
    assert(prev->vm_end <= next->vm_start);
ffffffffc02042ac:	05076963          	bltu	a4,a6,ffffffffc02042fe <insert_vma_struct+0x90>
    assert(next->vm_start < next->vm_end);
ffffffffc02042b0:	ff07b603          	ld	a2,-16(a5)
ffffffffc02042b4:	02c77363          	bgeu	a4,a2,ffffffffc02042da <insert_vma_struct+0x6c>
    }

    vma->vm_mm = mm;
    list_add_after(le_prev, &(vma->list_link));

    mm->map_count ++;
ffffffffc02042b8:	5118                	lw	a4,32(a0)
    vma->vm_mm = mm;
ffffffffc02042ba:	e188                	sd	a0,0(a1)
    list_add_after(le_prev, &(vma->list_link));
ffffffffc02042bc:	02058613          	addi	a2,a1,32
    prev->next = next->prev = elm;
ffffffffc02042c0:	e390                	sd	a2,0(a5)
ffffffffc02042c2:	e690                	sd	a2,8(a3)
}
ffffffffc02042c4:	60a2                	ld	ra,8(sp)
    elm->next = next;
ffffffffc02042c6:	f59c                	sd	a5,40(a1)
    elm->prev = prev;
ffffffffc02042c8:	f194                	sd	a3,32(a1)
    mm->map_count ++;
ffffffffc02042ca:	0017079b          	addiw	a5,a4,1
ffffffffc02042ce:	d11c                	sw	a5,32(a0)
}
ffffffffc02042d0:	0141                	addi	sp,sp,16
ffffffffc02042d2:	8082                	ret
    if (le_prev != list) {
ffffffffc02042d4:	fca690e3          	bne	a3,a0,ffffffffc0204294 <insert_vma_struct+0x26>
ffffffffc02042d8:	bfd1                	j	ffffffffc02042ac <insert_vma_struct+0x3e>
ffffffffc02042da:	e9fff0ef          	jal	ra,ffffffffc0204178 <check_vma_overlap.part.0>
    assert(vma->vm_start < vma->vm_end);
ffffffffc02042de:	00004697          	auipc	a3,0x4
ffffffffc02042e2:	e6a68693          	addi	a3,a3,-406 # ffffffffc0208148 <default_pmm_manager+0xcc8>
ffffffffc02042e6:	00003617          	auipc	a2,0x3
ffffffffc02042ea:	b0260613          	addi	a2,a2,-1278 # ffffffffc0206de8 <commands+0x450>
ffffffffc02042ee:	07400593          	li	a1,116
ffffffffc02042f2:	00004517          	auipc	a0,0x4
ffffffffc02042f6:	e4650513          	addi	a0,a0,-442 # ffffffffc0208138 <default_pmm_manager+0xcb8>
ffffffffc02042fa:	980fc0ef          	jal	ra,ffffffffc020047a <__panic>
    assert(prev->vm_end <= next->vm_start);
ffffffffc02042fe:	00004697          	auipc	a3,0x4
ffffffffc0204302:	e8a68693          	addi	a3,a3,-374 # ffffffffc0208188 <default_pmm_manager+0xd08>
ffffffffc0204306:	00003617          	auipc	a2,0x3
ffffffffc020430a:	ae260613          	addi	a2,a2,-1310 # ffffffffc0206de8 <commands+0x450>
ffffffffc020430e:	06c00593          	li	a1,108
ffffffffc0204312:	00004517          	auipc	a0,0x4
ffffffffc0204316:	e2650513          	addi	a0,a0,-474 # ffffffffc0208138 <default_pmm_manager+0xcb8>
ffffffffc020431a:	960fc0ef          	jal	ra,ffffffffc020047a <__panic>
    assert(prev->vm_start < prev->vm_end);
ffffffffc020431e:	00004697          	auipc	a3,0x4
ffffffffc0204322:	e4a68693          	addi	a3,a3,-438 # ffffffffc0208168 <default_pmm_manager+0xce8>
ffffffffc0204326:	00003617          	auipc	a2,0x3
ffffffffc020432a:	ac260613          	addi	a2,a2,-1342 # ffffffffc0206de8 <commands+0x450>
ffffffffc020432e:	06b00593          	li	a1,107
ffffffffc0204332:	00004517          	auipc	a0,0x4
ffffffffc0204336:	e0650513          	addi	a0,a0,-506 # ffffffffc0208138 <default_pmm_manager+0xcb8>
ffffffffc020433a:	940fc0ef          	jal	ra,ffffffffc020047a <__panic>

ffffffffc020433e <mm_destroy>:

// mm_destroy - free mm and mm internal fields
void
mm_destroy(struct mm_struct *mm) {
    assert(mm_count(mm) == 0);
ffffffffc020433e:	591c                	lw	a5,48(a0)
mm_destroy(struct mm_struct *mm) {
ffffffffc0204340:	1141                	addi	sp,sp,-16
ffffffffc0204342:	e406                	sd	ra,8(sp)
ffffffffc0204344:	e022                	sd	s0,0(sp)
    assert(mm_count(mm) == 0);
ffffffffc0204346:	e78d                	bnez	a5,ffffffffc0204370 <mm_destroy+0x32>
ffffffffc0204348:	842a                	mv	s0,a0
    return listelm->next;
ffffffffc020434a:	6508                	ld	a0,8(a0)

    list_entry_t *list = &(mm->mmap_list), *le;
    while ((le = list_next(list)) != list) {
ffffffffc020434c:	00a40c63          	beq	s0,a0,ffffffffc0204364 <mm_destroy+0x26>
    __list_del(listelm->prev, listelm->next);
ffffffffc0204350:	6118                	ld	a4,0(a0)
ffffffffc0204352:	651c                	ld	a5,8(a0)
        list_del(le);
        kfree(le2vma(le, list_link));  //kfree vma        
ffffffffc0204354:	1501                	addi	a0,a0,-32
    prev->next = next;
ffffffffc0204356:	e71c                	sd	a5,8(a4)
    next->prev = prev;
ffffffffc0204358:	e398                	sd	a4,0(a5)
ffffffffc020435a:	859fd0ef          	jal	ra,ffffffffc0201bb2 <kfree>
    return listelm->next;
ffffffffc020435e:	6408                	ld	a0,8(s0)
    while ((le = list_next(list)) != list) {
ffffffffc0204360:	fea418e3          	bne	s0,a0,ffffffffc0204350 <mm_destroy+0x12>
    }
    kfree(mm); //kfree mm
ffffffffc0204364:	8522                	mv	a0,s0
    mm=NULL;
}
ffffffffc0204366:	6402                	ld	s0,0(sp)
ffffffffc0204368:	60a2                	ld	ra,8(sp)
ffffffffc020436a:	0141                	addi	sp,sp,16
    kfree(mm); //kfree mm
ffffffffc020436c:	847fd06f          	j	ffffffffc0201bb2 <kfree>
    assert(mm_count(mm) == 0);
ffffffffc0204370:	00004697          	auipc	a3,0x4
ffffffffc0204374:	e3868693          	addi	a3,a3,-456 # ffffffffc02081a8 <default_pmm_manager+0xd28>
ffffffffc0204378:	00003617          	auipc	a2,0x3
ffffffffc020437c:	a7060613          	addi	a2,a2,-1424 # ffffffffc0206de8 <commands+0x450>
ffffffffc0204380:	09400593          	li	a1,148
ffffffffc0204384:	00004517          	auipc	a0,0x4
ffffffffc0204388:	db450513          	addi	a0,a0,-588 # ffffffffc0208138 <default_pmm_manager+0xcb8>
ffffffffc020438c:	8eefc0ef          	jal	ra,ffffffffc020047a <__panic>

ffffffffc0204390 <mm_map>:

int
mm_map(struct mm_struct *mm, uintptr_t addr, size_t len, uint32_t vm_flags,
       struct vma_struct **vma_store) {
ffffffffc0204390:	7139                	addi	sp,sp,-64
ffffffffc0204392:	f822                	sd	s0,48(sp)
    uintptr_t start = ROUNDDOWN(addr, PGSIZE), end = ROUNDUP(addr + len, PGSIZE);
ffffffffc0204394:	6405                	lui	s0,0x1
ffffffffc0204396:	147d                	addi	s0,s0,-1
ffffffffc0204398:	77fd                	lui	a5,0xfffff
ffffffffc020439a:	9622                	add	a2,a2,s0
ffffffffc020439c:	962e                	add	a2,a2,a1
       struct vma_struct **vma_store) {
ffffffffc020439e:	f426                	sd	s1,40(sp)
ffffffffc02043a0:	fc06                	sd	ra,56(sp)
    uintptr_t start = ROUNDDOWN(addr, PGSIZE), end = ROUNDUP(addr + len, PGSIZE);
ffffffffc02043a2:	00f5f4b3          	and	s1,a1,a5
       struct vma_struct **vma_store) {
ffffffffc02043a6:	f04a                	sd	s2,32(sp)
ffffffffc02043a8:	ec4e                	sd	s3,24(sp)
ffffffffc02043aa:	e852                	sd	s4,16(sp)
ffffffffc02043ac:	e456                	sd	s5,8(sp)
    if (!USER_ACCESS(start, end)) {
ffffffffc02043ae:	002005b7          	lui	a1,0x200
ffffffffc02043b2:	00f67433          	and	s0,a2,a5
ffffffffc02043b6:	06b4e363          	bltu	s1,a1,ffffffffc020441c <mm_map+0x8c>
ffffffffc02043ba:	0684f163          	bgeu	s1,s0,ffffffffc020441c <mm_map+0x8c>
ffffffffc02043be:	4785                	li	a5,1
ffffffffc02043c0:	07fe                	slli	a5,a5,0x1f
ffffffffc02043c2:	0487ed63          	bltu	a5,s0,ffffffffc020441c <mm_map+0x8c>
ffffffffc02043c6:	89aa                	mv	s3,a0
        return -E_INVAL;
    }

    assert(mm != NULL);
ffffffffc02043c8:	cd21                	beqz	a0,ffffffffc0204420 <mm_map+0x90>

    int ret = -E_INVAL;

    struct vma_struct *vma;
    if ((vma = find_vma(mm, start)) != NULL && end > vma->vm_start) {
ffffffffc02043ca:	85a6                	mv	a1,s1
ffffffffc02043cc:	8ab6                	mv	s5,a3
ffffffffc02043ce:	8a3a                	mv	s4,a4
ffffffffc02043d0:	e5fff0ef          	jal	ra,ffffffffc020422e <find_vma>
ffffffffc02043d4:	c501                	beqz	a0,ffffffffc02043dc <mm_map+0x4c>
ffffffffc02043d6:	651c                	ld	a5,8(a0)
ffffffffc02043d8:	0487e263          	bltu	a5,s0,ffffffffc020441c <mm_map+0x8c>
    struct vma_struct *vma = kmalloc(sizeof(struct vma_struct));
ffffffffc02043dc:	03000513          	li	a0,48
ffffffffc02043e0:	f22fd0ef          	jal	ra,ffffffffc0201b02 <kmalloc>
ffffffffc02043e4:	892a                	mv	s2,a0
        goto out;
    }
    ret = -E_NO_MEM;
ffffffffc02043e6:	5571                	li	a0,-4
    if (vma != NULL) {
ffffffffc02043e8:	02090163          	beqz	s2,ffffffffc020440a <mm_map+0x7a>

    if ((vma = vma_create(start, end, vm_flags)) == NULL) {
        goto out;
    }
    insert_vma_struct(mm, vma);
ffffffffc02043ec:	854e                	mv	a0,s3
        vma->vm_start = vm_start;
ffffffffc02043ee:	00993423          	sd	s1,8(s2)
        vma->vm_end = vm_end;
ffffffffc02043f2:	00893823          	sd	s0,16(s2)
        vma->vm_flags = vm_flags;
ffffffffc02043f6:	01592c23          	sw	s5,24(s2)
    insert_vma_struct(mm, vma);
ffffffffc02043fa:	85ca                	mv	a1,s2
ffffffffc02043fc:	e73ff0ef          	jal	ra,ffffffffc020426e <insert_vma_struct>
    if (vma_store != NULL) {
        *vma_store = vma;
    }
    ret = 0;
ffffffffc0204400:	4501                	li	a0,0
    if (vma_store != NULL) {
ffffffffc0204402:	000a0463          	beqz	s4,ffffffffc020440a <mm_map+0x7a>
        *vma_store = vma;
ffffffffc0204406:	012a3023          	sd	s2,0(s4)

out:
    return ret;
}
ffffffffc020440a:	70e2                	ld	ra,56(sp)
ffffffffc020440c:	7442                	ld	s0,48(sp)
ffffffffc020440e:	74a2                	ld	s1,40(sp)
ffffffffc0204410:	7902                	ld	s2,32(sp)
ffffffffc0204412:	69e2                	ld	s3,24(sp)
ffffffffc0204414:	6a42                	ld	s4,16(sp)
ffffffffc0204416:	6aa2                	ld	s5,8(sp)
ffffffffc0204418:	6121                	addi	sp,sp,64
ffffffffc020441a:	8082                	ret
        return -E_INVAL;
ffffffffc020441c:	5575                	li	a0,-3
ffffffffc020441e:	b7f5                	j	ffffffffc020440a <mm_map+0x7a>
    assert(mm != NULL);
ffffffffc0204420:	00004697          	auipc	a3,0x4
ffffffffc0204424:	80068693          	addi	a3,a3,-2048 # ffffffffc0207c20 <default_pmm_manager+0x7a0>
ffffffffc0204428:	00003617          	auipc	a2,0x3
ffffffffc020442c:	9c060613          	addi	a2,a2,-1600 # ffffffffc0206de8 <commands+0x450>
ffffffffc0204430:	0a700593          	li	a1,167
ffffffffc0204434:	00004517          	auipc	a0,0x4
ffffffffc0204438:	d0450513          	addi	a0,a0,-764 # ffffffffc0208138 <default_pmm_manager+0xcb8>
ffffffffc020443c:	83efc0ef          	jal	ra,ffffffffc020047a <__panic>

ffffffffc0204440 <dup_mmap>:

int
dup_mmap(struct mm_struct *to, struct mm_struct *from) {
ffffffffc0204440:	7139                	addi	sp,sp,-64
ffffffffc0204442:	fc06                	sd	ra,56(sp)
ffffffffc0204444:	f822                	sd	s0,48(sp)
ffffffffc0204446:	f426                	sd	s1,40(sp)
ffffffffc0204448:	f04a                	sd	s2,32(sp)
ffffffffc020444a:	ec4e                	sd	s3,24(sp)
ffffffffc020444c:	e852                	sd	s4,16(sp)
ffffffffc020444e:	e456                	sd	s5,8(sp)
    assert(to != NULL && from != NULL);
ffffffffc0204450:	c52d                	beqz	a0,ffffffffc02044ba <dup_mmap+0x7a>
ffffffffc0204452:	892a                	mv	s2,a0
ffffffffc0204454:	84ae                	mv	s1,a1
    list_entry_t *list = &(from->mmap_list), *le = list;
ffffffffc0204456:	842e                	mv	s0,a1
    assert(to != NULL && from != NULL);
ffffffffc0204458:	e595                	bnez	a1,ffffffffc0204484 <dup_mmap+0x44>
ffffffffc020445a:	a085                	j	ffffffffc02044ba <dup_mmap+0x7a>
        nvma = vma_create(vma->vm_start, vma->vm_end, vma->vm_flags);
        if (nvma == NULL) {
            return -E_NO_MEM;
        }

        insert_vma_struct(to, nvma);
ffffffffc020445c:	854a                	mv	a0,s2
        vma->vm_start = vm_start;
ffffffffc020445e:	0155b423          	sd	s5,8(a1) # 200008 <_binary_obj___user_exit_out_size+0x1f4ed8>
        vma->vm_end = vm_end;
ffffffffc0204462:	0145b823          	sd	s4,16(a1)
        vma->vm_flags = vm_flags;
ffffffffc0204466:	0135ac23          	sw	s3,24(a1)
        insert_vma_struct(to, nvma);
ffffffffc020446a:	e05ff0ef          	jal	ra,ffffffffc020426e <insert_vma_struct>

        bool share = 0;
        if (copy_range(to->pgdir, from->pgdir, vma->vm_start, vma->vm_end, share) != 0) {
ffffffffc020446e:	ff043683          	ld	a3,-16(s0) # ff0 <_binary_obj___user_faultread_out_size-0x8bc8>
ffffffffc0204472:	fe843603          	ld	a2,-24(s0)
ffffffffc0204476:	6c8c                	ld	a1,24(s1)
ffffffffc0204478:	01893503          	ld	a0,24(s2)
ffffffffc020447c:	4701                	li	a4,0
ffffffffc020447e:	c99fe0ef          	jal	ra,ffffffffc0203116 <copy_range>
ffffffffc0204482:	e105                	bnez	a0,ffffffffc02044a2 <dup_mmap+0x62>
    return listelm->prev;
ffffffffc0204484:	6000                	ld	s0,0(s0)
    while ((le = list_prev(le)) != list) {
ffffffffc0204486:	02848863          	beq	s1,s0,ffffffffc02044b6 <dup_mmap+0x76>
    struct vma_struct *vma = kmalloc(sizeof(struct vma_struct));
ffffffffc020448a:	03000513          	li	a0,48
        nvma = vma_create(vma->vm_start, vma->vm_end, vma->vm_flags);
ffffffffc020448e:	fe843a83          	ld	s5,-24(s0)
ffffffffc0204492:	ff043a03          	ld	s4,-16(s0)
ffffffffc0204496:	ff842983          	lw	s3,-8(s0)
    struct vma_struct *vma = kmalloc(sizeof(struct vma_struct));
ffffffffc020449a:	e68fd0ef          	jal	ra,ffffffffc0201b02 <kmalloc>
ffffffffc020449e:	85aa                	mv	a1,a0
    if (vma != NULL) {
ffffffffc02044a0:	fd55                	bnez	a0,ffffffffc020445c <dup_mmap+0x1c>
            return -E_NO_MEM;
ffffffffc02044a2:	5571                	li	a0,-4
            return -E_NO_MEM;
        }
    }
    return 0;
}
ffffffffc02044a4:	70e2                	ld	ra,56(sp)
ffffffffc02044a6:	7442                	ld	s0,48(sp)
ffffffffc02044a8:	74a2                	ld	s1,40(sp)
ffffffffc02044aa:	7902                	ld	s2,32(sp)
ffffffffc02044ac:	69e2                	ld	s3,24(sp)
ffffffffc02044ae:	6a42                	ld	s4,16(sp)
ffffffffc02044b0:	6aa2                	ld	s5,8(sp)
ffffffffc02044b2:	6121                	addi	sp,sp,64
ffffffffc02044b4:	8082                	ret
    return 0;
ffffffffc02044b6:	4501                	li	a0,0
ffffffffc02044b8:	b7f5                	j	ffffffffc02044a4 <dup_mmap+0x64>
    assert(to != NULL && from != NULL);
ffffffffc02044ba:	00004697          	auipc	a3,0x4
ffffffffc02044be:	d0668693          	addi	a3,a3,-762 # ffffffffc02081c0 <default_pmm_manager+0xd40>
ffffffffc02044c2:	00003617          	auipc	a2,0x3
ffffffffc02044c6:	92660613          	addi	a2,a2,-1754 # ffffffffc0206de8 <commands+0x450>
ffffffffc02044ca:	0c000593          	li	a1,192
ffffffffc02044ce:	00004517          	auipc	a0,0x4
ffffffffc02044d2:	c6a50513          	addi	a0,a0,-918 # ffffffffc0208138 <default_pmm_manager+0xcb8>
ffffffffc02044d6:	fa5fb0ef          	jal	ra,ffffffffc020047a <__panic>

ffffffffc02044da <exit_mmap>:

void
exit_mmap(struct mm_struct *mm) {
ffffffffc02044da:	1101                	addi	sp,sp,-32
ffffffffc02044dc:	ec06                	sd	ra,24(sp)
ffffffffc02044de:	e822                	sd	s0,16(sp)
ffffffffc02044e0:	e426                	sd	s1,8(sp)
ffffffffc02044e2:	e04a                	sd	s2,0(sp)
    assert(mm != NULL && mm_count(mm) == 0);
ffffffffc02044e4:	c531                	beqz	a0,ffffffffc0204530 <exit_mmap+0x56>
ffffffffc02044e6:	591c                	lw	a5,48(a0)
ffffffffc02044e8:	84aa                	mv	s1,a0
ffffffffc02044ea:	e3b9                	bnez	a5,ffffffffc0204530 <exit_mmap+0x56>
    return listelm->next;
ffffffffc02044ec:	6500                	ld	s0,8(a0)
    pde_t *pgdir = mm->pgdir;
ffffffffc02044ee:	01853903          	ld	s2,24(a0)
    list_entry_t *list = &(mm->mmap_list), *le = list;
    while ((le = list_next(le)) != list) {
ffffffffc02044f2:	02850663          	beq	a0,s0,ffffffffc020451e <exit_mmap+0x44>
        struct vma_struct *vma = le2vma(le, list_link);
        unmap_range(pgdir, vma->vm_start, vma->vm_end);
ffffffffc02044f6:	ff043603          	ld	a2,-16(s0)
ffffffffc02044fa:	fe843583          	ld	a1,-24(s0)
ffffffffc02044fe:	854a                	mv	a0,s2
ffffffffc0204500:	b13fd0ef          	jal	ra,ffffffffc0202012 <unmap_range>
ffffffffc0204504:	6400                	ld	s0,8(s0)
    while ((le = list_next(le)) != list) {
ffffffffc0204506:	fe8498e3          	bne	s1,s0,ffffffffc02044f6 <exit_mmap+0x1c>
ffffffffc020450a:	6400                	ld	s0,8(s0)
    }
    while ((le = list_next(le)) != list) {
ffffffffc020450c:	00848c63          	beq	s1,s0,ffffffffc0204524 <exit_mmap+0x4a>
        struct vma_struct *vma = le2vma(le, list_link);
        exit_range(pgdir, vma->vm_start, vma->vm_end);
ffffffffc0204510:	ff043603          	ld	a2,-16(s0)
ffffffffc0204514:	fe843583          	ld	a1,-24(s0)
ffffffffc0204518:	854a                	mv	a0,s2
ffffffffc020451a:	c3ffd0ef          	jal	ra,ffffffffc0202158 <exit_range>
ffffffffc020451e:	6400                	ld	s0,8(s0)
    while ((le = list_next(le)) != list) {
ffffffffc0204520:	fe8498e3          	bne	s1,s0,ffffffffc0204510 <exit_mmap+0x36>
    }
}
ffffffffc0204524:	60e2                	ld	ra,24(sp)
ffffffffc0204526:	6442                	ld	s0,16(sp)
ffffffffc0204528:	64a2                	ld	s1,8(sp)
ffffffffc020452a:	6902                	ld	s2,0(sp)
ffffffffc020452c:	6105                	addi	sp,sp,32
ffffffffc020452e:	8082                	ret
    assert(mm != NULL && mm_count(mm) == 0);
ffffffffc0204530:	00004697          	auipc	a3,0x4
ffffffffc0204534:	cb068693          	addi	a3,a3,-848 # ffffffffc02081e0 <default_pmm_manager+0xd60>
ffffffffc0204538:	00003617          	auipc	a2,0x3
ffffffffc020453c:	8b060613          	addi	a2,a2,-1872 # ffffffffc0206de8 <commands+0x450>
ffffffffc0204540:	0d600593          	li	a1,214
ffffffffc0204544:	00004517          	auipc	a0,0x4
ffffffffc0204548:	bf450513          	addi	a0,a0,-1036 # ffffffffc0208138 <default_pmm_manager+0xcb8>
ffffffffc020454c:	f2ffb0ef          	jal	ra,ffffffffc020047a <__panic>

ffffffffc0204550 <vmm_init>:
}

// vmm_init - initialize virtual memory management
//          - now just call check_vmm to check correctness of vmm
void
vmm_init(void) {
ffffffffc0204550:	7139                	addi	sp,sp,-64
ffffffffc0204552:	f822                	sd	s0,48(sp)
ffffffffc0204554:	f426                	sd	s1,40(sp)
ffffffffc0204556:	fc06                	sd	ra,56(sp)
ffffffffc0204558:	f04a                	sd	s2,32(sp)
ffffffffc020455a:	ec4e                	sd	s3,24(sp)
ffffffffc020455c:	e852                	sd	s4,16(sp)
ffffffffc020455e:	e456                	sd	s5,8(sp)

static void
check_vma_struct(void) {
    // size_t nr_free_pages_store = nr_free_pages();

    struct mm_struct *mm = mm_create();
ffffffffc0204560:	c59ff0ef          	jal	ra,ffffffffc02041b8 <mm_create>
    assert(mm != NULL);
ffffffffc0204564:	84aa                	mv	s1,a0
ffffffffc0204566:	03200413          	li	s0,50
ffffffffc020456a:	e919                	bnez	a0,ffffffffc0204580 <vmm_init+0x30>
ffffffffc020456c:	a991                	j	ffffffffc02049c0 <vmm_init+0x470>
        vma->vm_start = vm_start;
ffffffffc020456e:	e500                	sd	s0,8(a0)
        vma->vm_end = vm_end;
ffffffffc0204570:	e91c                	sd	a5,16(a0)
        vma->vm_flags = vm_flags;
ffffffffc0204572:	00052c23          	sw	zero,24(a0)

    int step1 = 10, step2 = step1 * 10;

    int i;
    for (i = step1; i >= 1; i --) {
ffffffffc0204576:	146d                	addi	s0,s0,-5
        struct vma_struct *vma = vma_create(i * 5, i * 5 + 2, 0);
        assert(vma != NULL);
        insert_vma_struct(mm, vma);
ffffffffc0204578:	8526                	mv	a0,s1
ffffffffc020457a:	cf5ff0ef          	jal	ra,ffffffffc020426e <insert_vma_struct>
    for (i = step1; i >= 1; i --) {
ffffffffc020457e:	c80d                	beqz	s0,ffffffffc02045b0 <vmm_init+0x60>
    struct vma_struct *vma = kmalloc(sizeof(struct vma_struct));
ffffffffc0204580:	03000513          	li	a0,48
ffffffffc0204584:	d7efd0ef          	jal	ra,ffffffffc0201b02 <kmalloc>
ffffffffc0204588:	85aa                	mv	a1,a0
ffffffffc020458a:	00240793          	addi	a5,s0,2
    if (vma != NULL) {
ffffffffc020458e:	f165                	bnez	a0,ffffffffc020456e <vmm_init+0x1e>
        assert(vma != NULL);
ffffffffc0204590:	00003697          	auipc	a3,0x3
ffffffffc0204594:	6c868693          	addi	a3,a3,1736 # ffffffffc0207c58 <default_pmm_manager+0x7d8>
ffffffffc0204598:	00003617          	auipc	a2,0x3
ffffffffc020459c:	85060613          	addi	a2,a2,-1968 # ffffffffc0206de8 <commands+0x450>
ffffffffc02045a0:	11300593          	li	a1,275
ffffffffc02045a4:	00004517          	auipc	a0,0x4
ffffffffc02045a8:	b9450513          	addi	a0,a0,-1132 # ffffffffc0208138 <default_pmm_manager+0xcb8>
ffffffffc02045ac:	ecffb0ef          	jal	ra,ffffffffc020047a <__panic>
ffffffffc02045b0:	03700413          	li	s0,55
    }

    for (i = step1 + 1; i <= step2; i ++) {
ffffffffc02045b4:	1f900913          	li	s2,505
ffffffffc02045b8:	a819                	j	ffffffffc02045ce <vmm_init+0x7e>
        vma->vm_start = vm_start;
ffffffffc02045ba:	e500                	sd	s0,8(a0)
        vma->vm_end = vm_end;
ffffffffc02045bc:	e91c                	sd	a5,16(a0)
        vma->vm_flags = vm_flags;
ffffffffc02045be:	00052c23          	sw	zero,24(a0)
    for (i = step1 + 1; i <= step2; i ++) {
ffffffffc02045c2:	0415                	addi	s0,s0,5
        struct vma_struct *vma = vma_create(i * 5, i * 5 + 2, 0);
        assert(vma != NULL);
        insert_vma_struct(mm, vma);
ffffffffc02045c4:	8526                	mv	a0,s1
ffffffffc02045c6:	ca9ff0ef          	jal	ra,ffffffffc020426e <insert_vma_struct>
    for (i = step1 + 1; i <= step2; i ++) {
ffffffffc02045ca:	03240a63          	beq	s0,s2,ffffffffc02045fe <vmm_init+0xae>
    struct vma_struct *vma = kmalloc(sizeof(struct vma_struct));
ffffffffc02045ce:	03000513          	li	a0,48
ffffffffc02045d2:	d30fd0ef          	jal	ra,ffffffffc0201b02 <kmalloc>
ffffffffc02045d6:	85aa                	mv	a1,a0
ffffffffc02045d8:	00240793          	addi	a5,s0,2
    if (vma != NULL) {
ffffffffc02045dc:	fd79                	bnez	a0,ffffffffc02045ba <vmm_init+0x6a>
        assert(vma != NULL);
ffffffffc02045de:	00003697          	auipc	a3,0x3
ffffffffc02045e2:	67a68693          	addi	a3,a3,1658 # ffffffffc0207c58 <default_pmm_manager+0x7d8>
ffffffffc02045e6:	00003617          	auipc	a2,0x3
ffffffffc02045ea:	80260613          	addi	a2,a2,-2046 # ffffffffc0206de8 <commands+0x450>
ffffffffc02045ee:	11900593          	li	a1,281
ffffffffc02045f2:	00004517          	auipc	a0,0x4
ffffffffc02045f6:	b4650513          	addi	a0,a0,-1210 # ffffffffc0208138 <default_pmm_manager+0xcb8>
ffffffffc02045fa:	e81fb0ef          	jal	ra,ffffffffc020047a <__panic>
ffffffffc02045fe:	649c                	ld	a5,8(s1)
    }

    list_entry_t *le = list_next(&(mm->mmap_list));

    for (i = 1; i <= step2; i ++) {
        assert(le != &(mm->mmap_list));
ffffffffc0204600:	471d                	li	a4,7
    for (i = 1; i <= step2; i ++) {
ffffffffc0204602:	1fb00593          	li	a1,507
        assert(le != &(mm->mmap_list));
ffffffffc0204606:	2cf48d63          	beq	s1,a5,ffffffffc02048e0 <vmm_init+0x390>
        struct vma_struct *mmap = le2vma(le, list_link);
        assert(mmap->vm_start == i * 5 && mmap->vm_end == i * 5 + 2);
ffffffffc020460a:	fe87b683          	ld	a3,-24(a5) # ffffffffffffefe8 <end+0x3fd4c6dc>
ffffffffc020460e:	ffe70613          	addi	a2,a4,-2
ffffffffc0204612:	24d61763          	bne	a2,a3,ffffffffc0204860 <vmm_init+0x310>
ffffffffc0204616:	ff07b683          	ld	a3,-16(a5)
ffffffffc020461a:	24d71363          	bne	a4,a3,ffffffffc0204860 <vmm_init+0x310>
    for (i = 1; i <= step2; i ++) {
ffffffffc020461e:	0715                	addi	a4,a4,5
ffffffffc0204620:	679c                	ld	a5,8(a5)
ffffffffc0204622:	feb712e3          	bne	a4,a1,ffffffffc0204606 <vmm_init+0xb6>
ffffffffc0204626:	4a1d                	li	s4,7
ffffffffc0204628:	4415                	li	s0,5
        le = list_next(le);
    }

    for (i = 5; i <= 5 * step2; i +=5) {
ffffffffc020462a:	1f900a93          	li	s5,505
        struct vma_struct *vma1 = find_vma(mm, i);
ffffffffc020462e:	85a2                	mv	a1,s0
ffffffffc0204630:	8526                	mv	a0,s1
ffffffffc0204632:	bfdff0ef          	jal	ra,ffffffffc020422e <find_vma>
ffffffffc0204636:	892a                	mv	s2,a0
        assert(vma1 != NULL);
ffffffffc0204638:	30050463          	beqz	a0,ffffffffc0204940 <vmm_init+0x3f0>
        struct vma_struct *vma2 = find_vma(mm, i+1);
ffffffffc020463c:	00140593          	addi	a1,s0,1
ffffffffc0204640:	8526                	mv	a0,s1
ffffffffc0204642:	bedff0ef          	jal	ra,ffffffffc020422e <find_vma>
ffffffffc0204646:	89aa                	mv	s3,a0
        assert(vma2 != NULL);
ffffffffc0204648:	2c050c63          	beqz	a0,ffffffffc0204920 <vmm_init+0x3d0>
        struct vma_struct *vma3 = find_vma(mm, i+2);
ffffffffc020464c:	85d2                	mv	a1,s4
ffffffffc020464e:	8526                	mv	a0,s1
ffffffffc0204650:	bdfff0ef          	jal	ra,ffffffffc020422e <find_vma>
        assert(vma3 == NULL);
ffffffffc0204654:	2a051663          	bnez	a0,ffffffffc0204900 <vmm_init+0x3b0>
        struct vma_struct *vma4 = find_vma(mm, i+3);
ffffffffc0204658:	00340593          	addi	a1,s0,3
ffffffffc020465c:	8526                	mv	a0,s1
ffffffffc020465e:	bd1ff0ef          	jal	ra,ffffffffc020422e <find_vma>
        assert(vma4 == NULL);
ffffffffc0204662:	30051f63          	bnez	a0,ffffffffc0204980 <vmm_init+0x430>
        struct vma_struct *vma5 = find_vma(mm, i+4);
ffffffffc0204666:	00440593          	addi	a1,s0,4
ffffffffc020466a:	8526                	mv	a0,s1
ffffffffc020466c:	bc3ff0ef          	jal	ra,ffffffffc020422e <find_vma>
        assert(vma5 == NULL);
ffffffffc0204670:	2e051863          	bnez	a0,ffffffffc0204960 <vmm_init+0x410>

        assert(vma1->vm_start == i  && vma1->vm_end == i  + 2);
ffffffffc0204674:	00893783          	ld	a5,8(s2)
ffffffffc0204678:	20f41463          	bne	s0,a5,ffffffffc0204880 <vmm_init+0x330>
ffffffffc020467c:	01093783          	ld	a5,16(s2)
ffffffffc0204680:	21479063          	bne	a5,s4,ffffffffc0204880 <vmm_init+0x330>
        assert(vma2->vm_start == i  && vma2->vm_end == i  + 2);
ffffffffc0204684:	0089b783          	ld	a5,8(s3)
ffffffffc0204688:	20f41c63          	bne	s0,a5,ffffffffc02048a0 <vmm_init+0x350>
ffffffffc020468c:	0109b783          	ld	a5,16(s3)
ffffffffc0204690:	21479863          	bne	a5,s4,ffffffffc02048a0 <vmm_init+0x350>
    for (i = 5; i <= 5 * step2; i +=5) {
ffffffffc0204694:	0415                	addi	s0,s0,5
ffffffffc0204696:	0a15                	addi	s4,s4,5
ffffffffc0204698:	f9541be3          	bne	s0,s5,ffffffffc020462e <vmm_init+0xde>
ffffffffc020469c:	4411                	li	s0,4
    }

    for (i =4; i>=0; i--) {
ffffffffc020469e:	597d                	li	s2,-1
        struct vma_struct *vma_below_5= find_vma(mm,i);
ffffffffc02046a0:	85a2                	mv	a1,s0
ffffffffc02046a2:	8526                	mv	a0,s1
ffffffffc02046a4:	b8bff0ef          	jal	ra,ffffffffc020422e <find_vma>
ffffffffc02046a8:	0004059b          	sext.w	a1,s0
        if (vma_below_5 != NULL ) {
ffffffffc02046ac:	c90d                	beqz	a0,ffffffffc02046de <vmm_init+0x18e>
           cprintf("vma_below_5: i %x, start %x, end %x\n",i, vma_below_5->vm_start, vma_below_5->vm_end); 
ffffffffc02046ae:	6914                	ld	a3,16(a0)
ffffffffc02046b0:	6510                	ld	a2,8(a0)
ffffffffc02046b2:	00004517          	auipc	a0,0x4
ffffffffc02046b6:	c4e50513          	addi	a0,a0,-946 # ffffffffc0208300 <default_pmm_manager+0xe80>
ffffffffc02046ba:	ac7fb0ef          	jal	ra,ffffffffc0200180 <cprintf>
        }
        assert(vma_below_5 == NULL);
ffffffffc02046be:	00004697          	auipc	a3,0x4
ffffffffc02046c2:	c6a68693          	addi	a3,a3,-918 # ffffffffc0208328 <default_pmm_manager+0xea8>
ffffffffc02046c6:	00002617          	auipc	a2,0x2
ffffffffc02046ca:	72260613          	addi	a2,a2,1826 # ffffffffc0206de8 <commands+0x450>
ffffffffc02046ce:	13b00593          	li	a1,315
ffffffffc02046d2:	00004517          	auipc	a0,0x4
ffffffffc02046d6:	a6650513          	addi	a0,a0,-1434 # ffffffffc0208138 <default_pmm_manager+0xcb8>
ffffffffc02046da:	da1fb0ef          	jal	ra,ffffffffc020047a <__panic>
    for (i =4; i>=0; i--) {
ffffffffc02046de:	147d                	addi	s0,s0,-1
ffffffffc02046e0:	fd2410e3          	bne	s0,s2,ffffffffc02046a0 <vmm_init+0x150>
    }

    mm_destroy(mm);
ffffffffc02046e4:	8526                	mv	a0,s1
ffffffffc02046e6:	c59ff0ef          	jal	ra,ffffffffc020433e <mm_destroy>

    cprintf("check_vma_struct() succeeded!\n");
ffffffffc02046ea:	00004517          	auipc	a0,0x4
ffffffffc02046ee:	c5650513          	addi	a0,a0,-938 # ffffffffc0208340 <default_pmm_manager+0xec0>
ffffffffc02046f2:	a8ffb0ef          	jal	ra,ffffffffc0200180 <cprintf>
struct mm_struct *check_mm_struct;

// check_pgfault - check correctness of pgfault handler
static void
check_pgfault(void) {
    size_t nr_free_pages_store = nr_free_pages();
ffffffffc02046f6:	ebcfd0ef          	jal	ra,ffffffffc0201db2 <nr_free_pages>
ffffffffc02046fa:	892a                	mv	s2,a0

    check_mm_struct = mm_create();
ffffffffc02046fc:	abdff0ef          	jal	ra,ffffffffc02041b8 <mm_create>
ffffffffc0204700:	000ae797          	auipc	a5,0xae
ffffffffc0204704:	1ea7b023          	sd	a0,480(a5) # ffffffffc02b28e0 <check_mm_struct>
ffffffffc0204708:	842a                	mv	s0,a0
    assert(check_mm_struct != NULL);
ffffffffc020470a:	28050b63          	beqz	a0,ffffffffc02049a0 <vmm_init+0x450>

    struct mm_struct *mm = check_mm_struct;
    pde_t *pgdir = mm->pgdir = boot_pgdir;
ffffffffc020470e:	000ae497          	auipc	s1,0xae
ffffffffc0204712:	1924b483          	ld	s1,402(s1) # ffffffffc02b28a0 <boot_pgdir>
    assert(pgdir[0] == 0);
ffffffffc0204716:	609c                	ld	a5,0(s1)
    pde_t *pgdir = mm->pgdir = boot_pgdir;
ffffffffc0204718:	ed04                	sd	s1,24(a0)
    assert(pgdir[0] == 0);
ffffffffc020471a:	2e079f63          	bnez	a5,ffffffffc0204a18 <vmm_init+0x4c8>
    struct vma_struct *vma = kmalloc(sizeof(struct vma_struct));
ffffffffc020471e:	03000513          	li	a0,48
ffffffffc0204722:	be0fd0ef          	jal	ra,ffffffffc0201b02 <kmalloc>
ffffffffc0204726:	89aa                	mv	s3,a0
    if (vma != NULL) {
ffffffffc0204728:	18050c63          	beqz	a0,ffffffffc02048c0 <vmm_init+0x370>
        vma->vm_end = vm_end;
ffffffffc020472c:	002007b7          	lui	a5,0x200
ffffffffc0204730:	00f9b823          	sd	a5,16(s3)
        vma->vm_flags = vm_flags;
ffffffffc0204734:	4789                	li	a5,2

    struct vma_struct *vma = vma_create(0, PTSIZE, VM_WRITE);
    assert(vma != NULL);

    insert_vma_struct(mm, vma);
ffffffffc0204736:	85aa                	mv	a1,a0
        vma->vm_flags = vm_flags;
ffffffffc0204738:	00f9ac23          	sw	a5,24(s3)
    insert_vma_struct(mm, vma);
ffffffffc020473c:	8522                	mv	a0,s0
        vma->vm_start = vm_start;
ffffffffc020473e:	0009b423          	sd	zero,8(s3)
    insert_vma_struct(mm, vma);
ffffffffc0204742:	b2dff0ef          	jal	ra,ffffffffc020426e <insert_vma_struct>

    uintptr_t addr = 0x100;
    assert(find_vma(mm, addr) == vma);
ffffffffc0204746:	10000593          	li	a1,256
ffffffffc020474a:	8522                	mv	a0,s0
ffffffffc020474c:	ae3ff0ef          	jal	ra,ffffffffc020422e <find_vma>
ffffffffc0204750:	10000793          	li	a5,256

    int i, sum = 0;

    for (i = 0; i < 100; i ++) {
ffffffffc0204754:	16400713          	li	a4,356
    assert(find_vma(mm, addr) == vma);
ffffffffc0204758:	2ea99063          	bne	s3,a0,ffffffffc0204a38 <vmm_init+0x4e8>
        *(char *)(addr + i) = i;
ffffffffc020475c:	00f78023          	sb	a5,0(a5) # 200000 <_binary_obj___user_exit_out_size+0x1f4ed0>
    for (i = 0; i < 100; i ++) {
ffffffffc0204760:	0785                	addi	a5,a5,1
ffffffffc0204762:	fee79de3          	bne	a5,a4,ffffffffc020475c <vmm_init+0x20c>
        sum += i;
ffffffffc0204766:	6705                	lui	a4,0x1
ffffffffc0204768:	10000793          	li	a5,256
ffffffffc020476c:	35670713          	addi	a4,a4,854 # 1356 <_binary_obj___user_faultread_out_size-0x8862>
    }
    for (i = 0; i < 100; i ++) {
ffffffffc0204770:	16400613          	li	a2,356
        sum -= *(char *)(addr + i);
ffffffffc0204774:	0007c683          	lbu	a3,0(a5)
    for (i = 0; i < 100; i ++) {
ffffffffc0204778:	0785                	addi	a5,a5,1
        sum -= *(char *)(addr + i);
ffffffffc020477a:	9f15                	subw	a4,a4,a3
    for (i = 0; i < 100; i ++) {
ffffffffc020477c:	fec79ce3          	bne	a5,a2,ffffffffc0204774 <vmm_init+0x224>
    }

    assert(sum == 0);
ffffffffc0204780:	2c071e63          	bnez	a4,ffffffffc0204a5c <vmm_init+0x50c>
    return pa2page(PDE_ADDR(pde));
ffffffffc0204784:	609c                	ld	a5,0(s1)
    if (PPN(pa) >= npage) {
ffffffffc0204786:	000aea97          	auipc	s5,0xae
ffffffffc020478a:	122a8a93          	addi	s5,s5,290 # ffffffffc02b28a8 <npage>
ffffffffc020478e:	000ab603          	ld	a2,0(s5)
    return pa2page(PDE_ADDR(pde));
ffffffffc0204792:	078a                	slli	a5,a5,0x2
ffffffffc0204794:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0204796:	2cc7f163          	bgeu	a5,a2,ffffffffc0204a58 <vmm_init+0x508>
    return &pages[PPN(pa) - nbase];
ffffffffc020479a:	00004a17          	auipc	s4,0x4
ffffffffc020479e:	6a6a3a03          	ld	s4,1702(s4) # ffffffffc0208e40 <nbase>
ffffffffc02047a2:	414787b3          	sub	a5,a5,s4
ffffffffc02047a6:	079a                	slli	a5,a5,0x6
    return page - pages + nbase;
ffffffffc02047a8:	8799                	srai	a5,a5,0x6
ffffffffc02047aa:	97d2                	add	a5,a5,s4
    return KADDR(page2pa(page));
ffffffffc02047ac:	00c79713          	slli	a4,a5,0xc
ffffffffc02047b0:	8331                	srli	a4,a4,0xc
    return page2ppn(page) << PGSHIFT;
ffffffffc02047b2:	00c79693          	slli	a3,a5,0xc
    return KADDR(page2pa(page));
ffffffffc02047b6:	24c77563          	bgeu	a4,a2,ffffffffc0204a00 <vmm_init+0x4b0>
ffffffffc02047ba:	000ae997          	auipc	s3,0xae
ffffffffc02047be:	1069b983          	ld	s3,262(s3) # ffffffffc02b28c0 <va_pa_offset>

    pde_t *pd1=pgdir,*pd0=page2kva(pde2page(pgdir[0]));
    page_remove(pgdir, ROUNDDOWN(addr, PGSIZE));
ffffffffc02047c2:	4581                	li	a1,0
ffffffffc02047c4:	8526                	mv	a0,s1
ffffffffc02047c6:	99b6                	add	s3,s3,a3
ffffffffc02047c8:	c23fd0ef          	jal	ra,ffffffffc02023ea <page_remove>
    return pa2page(PDE_ADDR(pde));
ffffffffc02047cc:	0009b783          	ld	a5,0(s3)
    if (PPN(pa) >= npage) {
ffffffffc02047d0:	000ab703          	ld	a4,0(s5)
    return pa2page(PDE_ADDR(pde));
ffffffffc02047d4:	078a                	slli	a5,a5,0x2
ffffffffc02047d6:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc02047d8:	28e7f063          	bgeu	a5,a4,ffffffffc0204a58 <vmm_init+0x508>
    return &pages[PPN(pa) - nbase];
ffffffffc02047dc:	000ae997          	auipc	s3,0xae
ffffffffc02047e0:	0d498993          	addi	s3,s3,212 # ffffffffc02b28b0 <pages>
ffffffffc02047e4:	0009b503          	ld	a0,0(s3)
ffffffffc02047e8:	414787b3          	sub	a5,a5,s4
ffffffffc02047ec:	079a                	slli	a5,a5,0x6
    free_page(pde2page(pd0[0]));
ffffffffc02047ee:	953e                	add	a0,a0,a5
ffffffffc02047f0:	4585                	li	a1,1
ffffffffc02047f2:	d80fd0ef          	jal	ra,ffffffffc0201d72 <free_pages>
    return pa2page(PDE_ADDR(pde));
ffffffffc02047f6:	609c                	ld	a5,0(s1)
    if (PPN(pa) >= npage) {
ffffffffc02047f8:	000ab703          	ld	a4,0(s5)
    return pa2page(PDE_ADDR(pde));
ffffffffc02047fc:	078a                	slli	a5,a5,0x2
ffffffffc02047fe:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0204800:	24e7fc63          	bgeu	a5,a4,ffffffffc0204a58 <vmm_init+0x508>
    return &pages[PPN(pa) - nbase];
ffffffffc0204804:	0009b503          	ld	a0,0(s3)
ffffffffc0204808:	414787b3          	sub	a5,a5,s4
ffffffffc020480c:	079a                	slli	a5,a5,0x6
    free_page(pde2page(pd1[0]));
ffffffffc020480e:	4585                	li	a1,1
ffffffffc0204810:	953e                	add	a0,a0,a5
ffffffffc0204812:	d60fd0ef          	jal	ra,ffffffffc0201d72 <free_pages>
    pgdir[0] = 0;
ffffffffc0204816:	0004b023          	sd	zero,0(s1)
  asm volatile("sfence.vma");
ffffffffc020481a:	12000073          	sfence.vma
    flush_tlb();

    mm->pgdir = NULL;
    mm_destroy(mm);
ffffffffc020481e:	8522                	mv	a0,s0
    mm->pgdir = NULL;
ffffffffc0204820:	00043c23          	sd	zero,24(s0)
    mm_destroy(mm);
ffffffffc0204824:	b1bff0ef          	jal	ra,ffffffffc020433e <mm_destroy>
    check_mm_struct = NULL;
ffffffffc0204828:	000ae797          	auipc	a5,0xae
ffffffffc020482c:	0a07bc23          	sd	zero,184(a5) # ffffffffc02b28e0 <check_mm_struct>

    assert(nr_free_pages_store == nr_free_pages());
ffffffffc0204830:	d82fd0ef          	jal	ra,ffffffffc0201db2 <nr_free_pages>
ffffffffc0204834:	1aa91663          	bne	s2,a0,ffffffffc02049e0 <vmm_init+0x490>

    cprintf("check_pgfault() succeeded!\n");
ffffffffc0204838:	00004517          	auipc	a0,0x4
ffffffffc020483c:	b9850513          	addi	a0,a0,-1128 # ffffffffc02083d0 <default_pmm_manager+0xf50>
ffffffffc0204840:	941fb0ef          	jal	ra,ffffffffc0200180 <cprintf>
}
ffffffffc0204844:	7442                	ld	s0,48(sp)
ffffffffc0204846:	70e2                	ld	ra,56(sp)
ffffffffc0204848:	74a2                	ld	s1,40(sp)
ffffffffc020484a:	7902                	ld	s2,32(sp)
ffffffffc020484c:	69e2                	ld	s3,24(sp)
ffffffffc020484e:	6a42                	ld	s4,16(sp)
ffffffffc0204850:	6aa2                	ld	s5,8(sp)
    cprintf("check_vmm() succeeded.\n");
ffffffffc0204852:	00004517          	auipc	a0,0x4
ffffffffc0204856:	b9e50513          	addi	a0,a0,-1122 # ffffffffc02083f0 <default_pmm_manager+0xf70>
}
ffffffffc020485a:	6121                	addi	sp,sp,64
    cprintf("check_vmm() succeeded.\n");
ffffffffc020485c:	925fb06f          	j	ffffffffc0200180 <cprintf>
        assert(mmap->vm_start == i * 5 && mmap->vm_end == i * 5 + 2);
ffffffffc0204860:	00004697          	auipc	a3,0x4
ffffffffc0204864:	9b868693          	addi	a3,a3,-1608 # ffffffffc0208218 <default_pmm_manager+0xd98>
ffffffffc0204868:	00002617          	auipc	a2,0x2
ffffffffc020486c:	58060613          	addi	a2,a2,1408 # ffffffffc0206de8 <commands+0x450>
ffffffffc0204870:	12200593          	li	a1,290
ffffffffc0204874:	00004517          	auipc	a0,0x4
ffffffffc0204878:	8c450513          	addi	a0,a0,-1852 # ffffffffc0208138 <default_pmm_manager+0xcb8>
ffffffffc020487c:	bfffb0ef          	jal	ra,ffffffffc020047a <__panic>
        assert(vma1->vm_start == i  && vma1->vm_end == i  + 2);
ffffffffc0204880:	00004697          	auipc	a3,0x4
ffffffffc0204884:	a2068693          	addi	a3,a3,-1504 # ffffffffc02082a0 <default_pmm_manager+0xe20>
ffffffffc0204888:	00002617          	auipc	a2,0x2
ffffffffc020488c:	56060613          	addi	a2,a2,1376 # ffffffffc0206de8 <commands+0x450>
ffffffffc0204890:	13200593          	li	a1,306
ffffffffc0204894:	00004517          	auipc	a0,0x4
ffffffffc0204898:	8a450513          	addi	a0,a0,-1884 # ffffffffc0208138 <default_pmm_manager+0xcb8>
ffffffffc020489c:	bdffb0ef          	jal	ra,ffffffffc020047a <__panic>
        assert(vma2->vm_start == i  && vma2->vm_end == i  + 2);
ffffffffc02048a0:	00004697          	auipc	a3,0x4
ffffffffc02048a4:	a3068693          	addi	a3,a3,-1488 # ffffffffc02082d0 <default_pmm_manager+0xe50>
ffffffffc02048a8:	00002617          	auipc	a2,0x2
ffffffffc02048ac:	54060613          	addi	a2,a2,1344 # ffffffffc0206de8 <commands+0x450>
ffffffffc02048b0:	13300593          	li	a1,307
ffffffffc02048b4:	00004517          	auipc	a0,0x4
ffffffffc02048b8:	88450513          	addi	a0,a0,-1916 # ffffffffc0208138 <default_pmm_manager+0xcb8>
ffffffffc02048bc:	bbffb0ef          	jal	ra,ffffffffc020047a <__panic>
    assert(vma != NULL);
ffffffffc02048c0:	00003697          	auipc	a3,0x3
ffffffffc02048c4:	39868693          	addi	a3,a3,920 # ffffffffc0207c58 <default_pmm_manager+0x7d8>
ffffffffc02048c8:	00002617          	auipc	a2,0x2
ffffffffc02048cc:	52060613          	addi	a2,a2,1312 # ffffffffc0206de8 <commands+0x450>
ffffffffc02048d0:	15200593          	li	a1,338
ffffffffc02048d4:	00004517          	auipc	a0,0x4
ffffffffc02048d8:	86450513          	addi	a0,a0,-1948 # ffffffffc0208138 <default_pmm_manager+0xcb8>
ffffffffc02048dc:	b9ffb0ef          	jal	ra,ffffffffc020047a <__panic>
        assert(le != &(mm->mmap_list));
ffffffffc02048e0:	00004697          	auipc	a3,0x4
ffffffffc02048e4:	92068693          	addi	a3,a3,-1760 # ffffffffc0208200 <default_pmm_manager+0xd80>
ffffffffc02048e8:	00002617          	auipc	a2,0x2
ffffffffc02048ec:	50060613          	addi	a2,a2,1280 # ffffffffc0206de8 <commands+0x450>
ffffffffc02048f0:	12000593          	li	a1,288
ffffffffc02048f4:	00004517          	auipc	a0,0x4
ffffffffc02048f8:	84450513          	addi	a0,a0,-1980 # ffffffffc0208138 <default_pmm_manager+0xcb8>
ffffffffc02048fc:	b7ffb0ef          	jal	ra,ffffffffc020047a <__panic>
        assert(vma3 == NULL);
ffffffffc0204900:	00004697          	auipc	a3,0x4
ffffffffc0204904:	97068693          	addi	a3,a3,-1680 # ffffffffc0208270 <default_pmm_manager+0xdf0>
ffffffffc0204908:	00002617          	auipc	a2,0x2
ffffffffc020490c:	4e060613          	addi	a2,a2,1248 # ffffffffc0206de8 <commands+0x450>
ffffffffc0204910:	12c00593          	li	a1,300
ffffffffc0204914:	00004517          	auipc	a0,0x4
ffffffffc0204918:	82450513          	addi	a0,a0,-2012 # ffffffffc0208138 <default_pmm_manager+0xcb8>
ffffffffc020491c:	b5ffb0ef          	jal	ra,ffffffffc020047a <__panic>
        assert(vma2 != NULL);
ffffffffc0204920:	00004697          	auipc	a3,0x4
ffffffffc0204924:	94068693          	addi	a3,a3,-1728 # ffffffffc0208260 <default_pmm_manager+0xde0>
ffffffffc0204928:	00002617          	auipc	a2,0x2
ffffffffc020492c:	4c060613          	addi	a2,a2,1216 # ffffffffc0206de8 <commands+0x450>
ffffffffc0204930:	12a00593          	li	a1,298
ffffffffc0204934:	00004517          	auipc	a0,0x4
ffffffffc0204938:	80450513          	addi	a0,a0,-2044 # ffffffffc0208138 <default_pmm_manager+0xcb8>
ffffffffc020493c:	b3ffb0ef          	jal	ra,ffffffffc020047a <__panic>
        assert(vma1 != NULL);
ffffffffc0204940:	00004697          	auipc	a3,0x4
ffffffffc0204944:	91068693          	addi	a3,a3,-1776 # ffffffffc0208250 <default_pmm_manager+0xdd0>
ffffffffc0204948:	00002617          	auipc	a2,0x2
ffffffffc020494c:	4a060613          	addi	a2,a2,1184 # ffffffffc0206de8 <commands+0x450>
ffffffffc0204950:	12800593          	li	a1,296
ffffffffc0204954:	00003517          	auipc	a0,0x3
ffffffffc0204958:	7e450513          	addi	a0,a0,2020 # ffffffffc0208138 <default_pmm_manager+0xcb8>
ffffffffc020495c:	b1ffb0ef          	jal	ra,ffffffffc020047a <__panic>
        assert(vma5 == NULL);
ffffffffc0204960:	00004697          	auipc	a3,0x4
ffffffffc0204964:	93068693          	addi	a3,a3,-1744 # ffffffffc0208290 <default_pmm_manager+0xe10>
ffffffffc0204968:	00002617          	auipc	a2,0x2
ffffffffc020496c:	48060613          	addi	a2,a2,1152 # ffffffffc0206de8 <commands+0x450>
ffffffffc0204970:	13000593          	li	a1,304
ffffffffc0204974:	00003517          	auipc	a0,0x3
ffffffffc0204978:	7c450513          	addi	a0,a0,1988 # ffffffffc0208138 <default_pmm_manager+0xcb8>
ffffffffc020497c:	afffb0ef          	jal	ra,ffffffffc020047a <__panic>
        assert(vma4 == NULL);
ffffffffc0204980:	00004697          	auipc	a3,0x4
ffffffffc0204984:	90068693          	addi	a3,a3,-1792 # ffffffffc0208280 <default_pmm_manager+0xe00>
ffffffffc0204988:	00002617          	auipc	a2,0x2
ffffffffc020498c:	46060613          	addi	a2,a2,1120 # ffffffffc0206de8 <commands+0x450>
ffffffffc0204990:	12e00593          	li	a1,302
ffffffffc0204994:	00003517          	auipc	a0,0x3
ffffffffc0204998:	7a450513          	addi	a0,a0,1956 # ffffffffc0208138 <default_pmm_manager+0xcb8>
ffffffffc020499c:	adffb0ef          	jal	ra,ffffffffc020047a <__panic>
    assert(check_mm_struct != NULL);
ffffffffc02049a0:	00004697          	auipc	a3,0x4
ffffffffc02049a4:	9c068693          	addi	a3,a3,-1600 # ffffffffc0208360 <default_pmm_manager+0xee0>
ffffffffc02049a8:	00002617          	auipc	a2,0x2
ffffffffc02049ac:	44060613          	addi	a2,a2,1088 # ffffffffc0206de8 <commands+0x450>
ffffffffc02049b0:	14b00593          	li	a1,331
ffffffffc02049b4:	00003517          	auipc	a0,0x3
ffffffffc02049b8:	78450513          	addi	a0,a0,1924 # ffffffffc0208138 <default_pmm_manager+0xcb8>
ffffffffc02049bc:	abffb0ef          	jal	ra,ffffffffc020047a <__panic>
    assert(mm != NULL);
ffffffffc02049c0:	00003697          	auipc	a3,0x3
ffffffffc02049c4:	26068693          	addi	a3,a3,608 # ffffffffc0207c20 <default_pmm_manager+0x7a0>
ffffffffc02049c8:	00002617          	auipc	a2,0x2
ffffffffc02049cc:	42060613          	addi	a2,a2,1056 # ffffffffc0206de8 <commands+0x450>
ffffffffc02049d0:	10c00593          	li	a1,268
ffffffffc02049d4:	00003517          	auipc	a0,0x3
ffffffffc02049d8:	76450513          	addi	a0,a0,1892 # ffffffffc0208138 <default_pmm_manager+0xcb8>
ffffffffc02049dc:	a9ffb0ef          	jal	ra,ffffffffc020047a <__panic>
    assert(nr_free_pages_store == nr_free_pages());
ffffffffc02049e0:	00004697          	auipc	a3,0x4
ffffffffc02049e4:	9c868693          	addi	a3,a3,-1592 # ffffffffc02083a8 <default_pmm_manager+0xf28>
ffffffffc02049e8:	00002617          	auipc	a2,0x2
ffffffffc02049ec:	40060613          	addi	a2,a2,1024 # ffffffffc0206de8 <commands+0x450>
ffffffffc02049f0:	17000593          	li	a1,368
ffffffffc02049f4:	00003517          	auipc	a0,0x3
ffffffffc02049f8:	74450513          	addi	a0,a0,1860 # ffffffffc0208138 <default_pmm_manager+0xcb8>
ffffffffc02049fc:	a7ffb0ef          	jal	ra,ffffffffc020047a <__panic>
    return KADDR(page2pa(page));
ffffffffc0204a00:	00003617          	auipc	a2,0x3
ffffffffc0204a04:	ab860613          	addi	a2,a2,-1352 # ffffffffc02074b8 <default_pmm_manager+0x38>
ffffffffc0204a08:	06900593          	li	a1,105
ffffffffc0204a0c:	00003517          	auipc	a0,0x3
ffffffffc0204a10:	ad450513          	addi	a0,a0,-1324 # ffffffffc02074e0 <default_pmm_manager+0x60>
ffffffffc0204a14:	a67fb0ef          	jal	ra,ffffffffc020047a <__panic>
    assert(pgdir[0] == 0);
ffffffffc0204a18:	00003697          	auipc	a3,0x3
ffffffffc0204a1c:	23068693          	addi	a3,a3,560 # ffffffffc0207c48 <default_pmm_manager+0x7c8>
ffffffffc0204a20:	00002617          	auipc	a2,0x2
ffffffffc0204a24:	3c860613          	addi	a2,a2,968 # ffffffffc0206de8 <commands+0x450>
ffffffffc0204a28:	14f00593          	li	a1,335
ffffffffc0204a2c:	00003517          	auipc	a0,0x3
ffffffffc0204a30:	70c50513          	addi	a0,a0,1804 # ffffffffc0208138 <default_pmm_manager+0xcb8>
ffffffffc0204a34:	a47fb0ef          	jal	ra,ffffffffc020047a <__panic>
    assert(find_vma(mm, addr) == vma);
ffffffffc0204a38:	00004697          	auipc	a3,0x4
ffffffffc0204a3c:	94068693          	addi	a3,a3,-1728 # ffffffffc0208378 <default_pmm_manager+0xef8>
ffffffffc0204a40:	00002617          	auipc	a2,0x2
ffffffffc0204a44:	3a860613          	addi	a2,a2,936 # ffffffffc0206de8 <commands+0x450>
ffffffffc0204a48:	15700593          	li	a1,343
ffffffffc0204a4c:	00003517          	auipc	a0,0x3
ffffffffc0204a50:	6ec50513          	addi	a0,a0,1772 # ffffffffc0208138 <default_pmm_manager+0xcb8>
ffffffffc0204a54:	a27fb0ef          	jal	ra,ffffffffc020047a <__panic>
ffffffffc0204a58:	f44ff0ef          	jal	ra,ffffffffc020419c <pa2page.part.0>
    assert(sum == 0);
ffffffffc0204a5c:	00004697          	auipc	a3,0x4
ffffffffc0204a60:	93c68693          	addi	a3,a3,-1732 # ffffffffc0208398 <default_pmm_manager+0xf18>
ffffffffc0204a64:	00002617          	auipc	a2,0x2
ffffffffc0204a68:	38460613          	addi	a2,a2,900 # ffffffffc0206de8 <commands+0x450>
ffffffffc0204a6c:	16300593          	li	a1,355
ffffffffc0204a70:	00003517          	auipc	a0,0x3
ffffffffc0204a74:	6c850513          	addi	a0,a0,1736 # ffffffffc0208138 <default_pmm_manager+0xcb8>
ffffffffc0204a78:	a03fb0ef          	jal	ra,ffffffffc020047a <__panic>

ffffffffc0204a7c <do_pgfault>:
 *            was a read (0) or write (1).
 *         -- The U/S flag (bit 2) indicates whether the processor was executing at user mode (1)
 *            or supervisor mode (0) at the time of the exception.
 */
int
do_pgfault(struct mm_struct *mm, uint_t error_code, uintptr_t addr) {
ffffffffc0204a7c:	715d                	addi	sp,sp,-80
    int ret = -E_INVAL;
    //try to find a vma which include addr
    struct vma_struct *vma = find_vma(mm, addr);
ffffffffc0204a7e:	85b2                	mv	a1,a2
do_pgfault(struct mm_struct *mm, uint_t error_code, uintptr_t addr) {
ffffffffc0204a80:	e0a2                	sd	s0,64(sp)
ffffffffc0204a82:	fc26                	sd	s1,56(sp)
ffffffffc0204a84:	e486                	sd	ra,72(sp)
ffffffffc0204a86:	f84a                	sd	s2,48(sp)
ffffffffc0204a88:	f44e                	sd	s3,40(sp)
ffffffffc0204a8a:	f052                	sd	s4,32(sp)
ffffffffc0204a8c:	ec56                	sd	s5,24(sp)
ffffffffc0204a8e:	8432                	mv	s0,a2
ffffffffc0204a90:	84aa                	mv	s1,a0
    struct vma_struct *vma = find_vma(mm, addr);
ffffffffc0204a92:	f9cff0ef          	jal	ra,ffffffffc020422e <find_vma>

    pgfault_num++;
ffffffffc0204a96:	000ae797          	auipc	a5,0xae
ffffffffc0204a9a:	e527a783          	lw	a5,-430(a5) # ffffffffc02b28e8 <pgfault_num>
ffffffffc0204a9e:	2785                	addiw	a5,a5,1
ffffffffc0204aa0:	000ae717          	auipc	a4,0xae
ffffffffc0204aa4:	e4f72423          	sw	a5,-440(a4) # ffffffffc02b28e8 <pgfault_num>
    //If the addr is in the range of a mm's vma?
    if (vma == NULL || vma->vm_start > addr) {
ffffffffc0204aa8:	14050463          	beqz	a0,ffffffffc0204bf0 <do_pgfault+0x174>
ffffffffc0204aac:	651c                	ld	a5,8(a0)
ffffffffc0204aae:	14f46163          	bltu	s0,a5,ffffffffc0204bf0 <do_pgfault+0x174>
     *    (read  an non_existed addr && addr is readable)
     * THEN
     *    continue process
     */
    uint32_t perm = PTE_U;
    if (vma->vm_flags & VM_WRITE) {
ffffffffc0204ab2:	4d1c                	lw	a5,24(a0)
    uint32_t perm = PTE_U;
ffffffffc0204ab4:	49c1                	li	s3,16
    if (vma->vm_flags & VM_WRITE) {
ffffffffc0204ab6:	8b89                	andi	a5,a5,2
ffffffffc0204ab8:	e7ad                	bnez	a5,ffffffffc0204b22 <do_pgfault+0xa6>
        perm |= READ_WRITE;
    }
    addr = ROUNDDOWN(addr, PGSIZE);
ffffffffc0204aba:	75fd                	lui	a1,0xfffff

    pte_t *ptep=NULL;
  
    // try to find a pte, if pte's PT(Page Table) isn't existed, then create a PT.
    // (notice the 3th parameter '1')
    if ((ptep = get_pte(mm->pgdir, addr, 1)) == NULL) {
ffffffffc0204abc:	6c88                	ld	a0,24(s1)
    addr = ROUNDDOWN(addr, PGSIZE);
ffffffffc0204abe:	8c6d                	and	s0,s0,a1
    if ((ptep = get_pte(mm->pgdir, addr, 1)) == NULL) {
ffffffffc0204ac0:	4605                	li	a2,1
ffffffffc0204ac2:	85a2                	mv	a1,s0
ffffffffc0204ac4:	b28fd0ef          	jal	ra,ffffffffc0201dec <get_pte>
ffffffffc0204ac8:	892a                	mv	s2,a0
ffffffffc0204aca:	14050563          	beqz	a0,ffffffffc0204c14 <do_pgfault+0x198>
        cprintf("get_pte in do_pgfault failed\n");
        goto failed;
    }
    
    if (*ptep == 0) { // if the phy addr isn't exist, then alloc a page & map the phy addr with logical addr
ffffffffc0204ace:	6110                	ld	a2,0(a0)
ffffffffc0204ad0:	0e060b63          	beqz	a2,ffffffffc0204bc6 <do_pgfault+0x14a>
        *    swap_in(mm, addr, &page) : 分配一个内存页，然后根据
        *    PTE中的swap条目的addr，找到磁盘页的地址，将磁盘页的内容读入这个内存页
        *    page_insert ： 建立一个Page的phy addr与线性addr la的映射
        *    swap_map_swappable ： 设置页面可交换
        */
        struct Page *page = NULL;
ffffffffc0204ad4:	e402                	sd	zero,8(sp)
        if (*ptep & PTE_V) {
ffffffffc0204ad6:	00167793          	andi	a5,a2,1
ffffffffc0204ada:	e7b1                	bnez	a5,ffffffffc0204b26 <do_pgfault+0xaa>
                memcpy(dst_kva, src_kva, PGSIZE);
            } else {
                page_insert(mm->pgdir, page, addr, perm);
            }
        } else {
            if (swap_init_ok) {
ffffffffc0204adc:	000ae797          	auipc	a5,0xae
ffffffffc0204ae0:	dfc7a783          	lw	a5,-516(a5) # ffffffffc02b28d8 <swap_init_ok>
ffffffffc0204ae4:	10078f63          	beqz	a5,ffffffffc0204c02 <do_pgfault+0x186>
                swap_in(mm, addr, &page);
ffffffffc0204ae8:	85a2                	mv	a1,s0
ffffffffc0204aea:	0030                	addi	a2,sp,8
ffffffffc0204aec:	8526                	mv	a0,s1
ffffffffc0204aee:	a12ff0ef          	jal	ra,ffffffffc0203d00 <swap_in>
                page_insert(mm->pgdir, page, addr, perm);
ffffffffc0204af2:	65a2                	ld	a1,8(sp)
ffffffffc0204af4:	6c88                	ld	a0,24(s1)
ffffffffc0204af6:	86ce                	mv	a3,s3
ffffffffc0204af8:	8622                	mv	a2,s0
ffffffffc0204afa:	98dfd0ef          	jal	ra,ffffffffc0202486 <page_insert>
            } else {
                cprintf("no swap_init_ok but ptep is %x, failed\n", *ptep);
                goto failed;
            }
        }
        swap_map_swappable(mm, addr, page, 1);
ffffffffc0204afe:	6622                	ld	a2,8(sp)
ffffffffc0204b00:	4685                	li	a3,1
ffffffffc0204b02:	85a2                	mv	a1,s0
ffffffffc0204b04:	8526                	mv	a0,s1
ffffffffc0204b06:	8daff0ef          	jal	ra,ffffffffc0203be0 <swap_map_swappable>

        page->pra_vaddr = addr;
ffffffffc0204b0a:	67a2                	ld	a5,8(sp)
   }
   ret = 0;
ffffffffc0204b0c:	4501                	li	a0,0
        page->pra_vaddr = addr;
ffffffffc0204b0e:	ff80                	sd	s0,56(a5)
failed:
    return ret;
}
ffffffffc0204b10:	60a6                	ld	ra,72(sp)
ffffffffc0204b12:	6406                	ld	s0,64(sp)
ffffffffc0204b14:	74e2                	ld	s1,56(sp)
ffffffffc0204b16:	7942                	ld	s2,48(sp)
ffffffffc0204b18:	79a2                	ld	s3,40(sp)
ffffffffc0204b1a:	7a02                	ld	s4,32(sp)
ffffffffc0204b1c:	6ae2                	ld	s5,24(sp)
ffffffffc0204b1e:	6161                	addi	sp,sp,80
ffffffffc0204b20:	8082                	ret
        perm |= READ_WRITE;
ffffffffc0204b22:	49dd                	li	s3,23
ffffffffc0204b24:	bf59                	j	ffffffffc0204aba <do_pgfault+0x3e>
            cprintf("\n\nCOW: ptep 0x%x, pte 0x%x\n", ptep, *ptep);
ffffffffc0204b26:	85aa                	mv	a1,a0
ffffffffc0204b28:	00004517          	auipc	a0,0x4
ffffffffc0204b2c:	95850513          	addi	a0,a0,-1704 # ffffffffc0208480 <default_pmm_manager+0x1000>
ffffffffc0204b30:	e50fb0ef          	jal	ra,ffffffffc0200180 <cprintf>
            page = pte2page(*ptep);
ffffffffc0204b34:	00093783          	ld	a5,0(s2)
    if (!(pte & PTE_V)) {
ffffffffc0204b38:	0017f713          	andi	a4,a5,1
ffffffffc0204b3c:	10070063          	beqz	a4,ffffffffc0204c3c <do_pgfault+0x1c0>
    if (PPN(pa) >= npage) {
ffffffffc0204b40:	000aea17          	auipc	s4,0xae
ffffffffc0204b44:	d68a0a13          	addi	s4,s4,-664 # ffffffffc02b28a8 <npage>
ffffffffc0204b48:	000a3703          	ld	a4,0(s4)
    return pa2page(PTE_ADDR(pte));
ffffffffc0204b4c:	078a                	slli	a5,a5,0x2
ffffffffc0204b4e:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0204b50:	10e7ff63          	bgeu	a5,a4,ffffffffc0204c6e <do_pgfault+0x1f2>
    return &pages[PPN(pa) - nbase];
ffffffffc0204b54:	000aea97          	auipc	s5,0xae
ffffffffc0204b58:	d5ca8a93          	addi	s5,s5,-676 # ffffffffc02b28b0 <pages>
ffffffffc0204b5c:	000ab583          	ld	a1,0(s5)
ffffffffc0204b60:	00004917          	auipc	s2,0x4
ffffffffc0204b64:	2e093903          	ld	s2,736(s2) # ffffffffc0208e40 <nbase>
ffffffffc0204b68:	412787b3          	sub	a5,a5,s2
ffffffffc0204b6c:	079a                	slli	a5,a5,0x6
ffffffffc0204b6e:	95be                	add	a1,a1,a5
            if (page_ref(page) > 1) {
ffffffffc0204b70:	4198                	lw	a4,0(a1)
ffffffffc0204b72:	4785                	li	a5,1
            page = pte2page(*ptep);
ffffffffc0204b74:	e42e                	sd	a1,8(sp)
                struct Page *new_page = pgdir_alloc_page(mm->pgdir, addr, perm);
ffffffffc0204b76:	6c88                	ld	a0,24(s1)
            if (page_ref(page) > 1) {
ffffffffc0204b78:	06e7d763          	bge	a5,a4,ffffffffc0204be6 <do_pgfault+0x16a>
                struct Page *new_page = pgdir_alloc_page(mm->pgdir, addr, perm);
ffffffffc0204b7c:	864e                	mv	a2,s3
ffffffffc0204b7e:	85a2                	mv	a1,s0
ffffffffc0204b80:	839fe0ef          	jal	ra,ffffffffc02033b8 <pgdir_alloc_page>
    return page - pages + nbase;
ffffffffc0204b84:	000ab683          	ld	a3,0(s5)
ffffffffc0204b88:	65a2                	ld	a1,8(sp)
    return KADDR(page2pa(page));
ffffffffc0204b8a:	57fd                	li	a5,-1
ffffffffc0204b8c:	000a3703          	ld	a4,0(s4)
    return page - pages + nbase;
ffffffffc0204b90:	8d95                	sub	a1,a1,a3
ffffffffc0204b92:	8599                	srai	a1,a1,0x6
ffffffffc0204b94:	95ca                	add	a1,a1,s2
    return KADDR(page2pa(page));
ffffffffc0204b96:	83b1                	srli	a5,a5,0xc
ffffffffc0204b98:	00f5f633          	and	a2,a1,a5
    return page2ppn(page) << PGSHIFT;
ffffffffc0204b9c:	05b2                	slli	a1,a1,0xc
    return KADDR(page2pa(page));
ffffffffc0204b9e:	0ae67b63          	bgeu	a2,a4,ffffffffc0204c54 <do_pgfault+0x1d8>
    return page - pages + nbase;
ffffffffc0204ba2:	40d506b3          	sub	a3,a0,a3
ffffffffc0204ba6:	8699                	srai	a3,a3,0x6
ffffffffc0204ba8:	96ca                	add	a3,a3,s2
    return KADDR(page2pa(page));
ffffffffc0204baa:	000ae517          	auipc	a0,0xae
ffffffffc0204bae:	d1653503          	ld	a0,-746(a0) # ffffffffc02b28c0 <va_pa_offset>
ffffffffc0204bb2:	8ff5                	and	a5,a5,a3
ffffffffc0204bb4:	95aa                	add	a1,a1,a0
    return page2ppn(page) << PGSHIFT;
ffffffffc0204bb6:	06b2                	slli	a3,a3,0xc
    return KADDR(page2pa(page));
ffffffffc0204bb8:	06e7f663          	bgeu	a5,a4,ffffffffc0204c24 <do_pgfault+0x1a8>
                memcpy(dst_kva, src_kva, PGSIZE);
ffffffffc0204bbc:	6605                	lui	a2,0x1
ffffffffc0204bbe:	9536                	add	a0,a0,a3
ffffffffc0204bc0:	357010ef          	jal	ra,ffffffffc0206716 <memcpy>
ffffffffc0204bc4:	bf2d                	j	ffffffffc0204afe <do_pgfault+0x82>
        if (pgdir_alloc_page(mm->pgdir, addr, perm) == NULL) {
ffffffffc0204bc6:	6c88                	ld	a0,24(s1)
ffffffffc0204bc8:	864e                	mv	a2,s3
ffffffffc0204bca:	85a2                	mv	a1,s0
ffffffffc0204bcc:	fecfe0ef          	jal	ra,ffffffffc02033b8 <pgdir_alloc_page>
ffffffffc0204bd0:	87aa                	mv	a5,a0
   ret = 0;
ffffffffc0204bd2:	4501                	li	a0,0
        if (pgdir_alloc_page(mm->pgdir, addr, perm) == NULL) {
ffffffffc0204bd4:	ff95                	bnez	a5,ffffffffc0204b10 <do_pgfault+0x94>
            cprintf("pgdir_alloc_page in do_pgfault failed\n");
ffffffffc0204bd6:	00004517          	auipc	a0,0x4
ffffffffc0204bda:	88250513          	addi	a0,a0,-1918 # ffffffffc0208458 <default_pmm_manager+0xfd8>
ffffffffc0204bde:	da2fb0ef          	jal	ra,ffffffffc0200180 <cprintf>
    ret = -E_NO_MEM;
ffffffffc0204be2:	5571                	li	a0,-4
            goto failed;
ffffffffc0204be4:	b735                	j	ffffffffc0204b10 <do_pgfault+0x94>
                page_insert(mm->pgdir, page, addr, perm);
ffffffffc0204be6:	86ce                	mv	a3,s3
ffffffffc0204be8:	8622                	mv	a2,s0
ffffffffc0204bea:	89dfd0ef          	jal	ra,ffffffffc0202486 <page_insert>
ffffffffc0204bee:	bf01                	j	ffffffffc0204afe <do_pgfault+0x82>
        cprintf("not valid addr %x, and  can not find it in vma\n", addr);
ffffffffc0204bf0:	85a2                	mv	a1,s0
ffffffffc0204bf2:	00004517          	auipc	a0,0x4
ffffffffc0204bf6:	81650513          	addi	a0,a0,-2026 # ffffffffc0208408 <default_pmm_manager+0xf88>
ffffffffc0204bfa:	d86fb0ef          	jal	ra,ffffffffc0200180 <cprintf>
    int ret = -E_INVAL;
ffffffffc0204bfe:	5575                	li	a0,-3
        goto failed;
ffffffffc0204c00:	bf01                	j	ffffffffc0204b10 <do_pgfault+0x94>
                cprintf("no swap_init_ok but ptep is %x, failed\n", *ptep);
ffffffffc0204c02:	85b2                	mv	a1,a2
ffffffffc0204c04:	00004517          	auipc	a0,0x4
ffffffffc0204c08:	89c50513          	addi	a0,a0,-1892 # ffffffffc02084a0 <default_pmm_manager+0x1020>
ffffffffc0204c0c:	d74fb0ef          	jal	ra,ffffffffc0200180 <cprintf>
    ret = -E_NO_MEM;
ffffffffc0204c10:	5571                	li	a0,-4
ffffffffc0204c12:	bdfd                	j	ffffffffc0204b10 <do_pgfault+0x94>
        cprintf("get_pte in do_pgfault failed\n");
ffffffffc0204c14:	00004517          	auipc	a0,0x4
ffffffffc0204c18:	82450513          	addi	a0,a0,-2012 # ffffffffc0208438 <default_pmm_manager+0xfb8>
ffffffffc0204c1c:	d64fb0ef          	jal	ra,ffffffffc0200180 <cprintf>
    ret = -E_NO_MEM;
ffffffffc0204c20:	5571                	li	a0,-4
        goto failed;
ffffffffc0204c22:	b5fd                	j	ffffffffc0204b10 <do_pgfault+0x94>
ffffffffc0204c24:	00003617          	auipc	a2,0x3
ffffffffc0204c28:	89460613          	addi	a2,a2,-1900 # ffffffffc02074b8 <default_pmm_manager+0x38>
ffffffffc0204c2c:	06900593          	li	a1,105
ffffffffc0204c30:	00003517          	auipc	a0,0x3
ffffffffc0204c34:	8b050513          	addi	a0,a0,-1872 # ffffffffc02074e0 <default_pmm_manager+0x60>
ffffffffc0204c38:	843fb0ef          	jal	ra,ffffffffc020047a <__panic>
        panic("pte2page called with invalid pte");
ffffffffc0204c3c:	00003617          	auipc	a2,0x3
ffffffffc0204c40:	96c60613          	addi	a2,a2,-1684 # ffffffffc02075a8 <default_pmm_manager+0x128>
ffffffffc0204c44:	07400593          	li	a1,116
ffffffffc0204c48:	00003517          	auipc	a0,0x3
ffffffffc0204c4c:	89850513          	addi	a0,a0,-1896 # ffffffffc02074e0 <default_pmm_manager+0x60>
ffffffffc0204c50:	82bfb0ef          	jal	ra,ffffffffc020047a <__panic>
    return KADDR(page2pa(page));
ffffffffc0204c54:	86ae                	mv	a3,a1
ffffffffc0204c56:	00003617          	auipc	a2,0x3
ffffffffc0204c5a:	86260613          	addi	a2,a2,-1950 # ffffffffc02074b8 <default_pmm_manager+0x38>
ffffffffc0204c5e:	06900593          	li	a1,105
ffffffffc0204c62:	00003517          	auipc	a0,0x3
ffffffffc0204c66:	87e50513          	addi	a0,a0,-1922 # ffffffffc02074e0 <default_pmm_manager+0x60>
ffffffffc0204c6a:	811fb0ef          	jal	ra,ffffffffc020047a <__panic>
ffffffffc0204c6e:	d2eff0ef          	jal	ra,ffffffffc020419c <pa2page.part.0>

ffffffffc0204c72 <user_mem_check>:

bool
user_mem_check(struct mm_struct *mm, uintptr_t addr, size_t len, bool write) {
ffffffffc0204c72:	7179                	addi	sp,sp,-48
ffffffffc0204c74:	f022                	sd	s0,32(sp)
ffffffffc0204c76:	f406                	sd	ra,40(sp)
ffffffffc0204c78:	ec26                	sd	s1,24(sp)
ffffffffc0204c7a:	e84a                	sd	s2,16(sp)
ffffffffc0204c7c:	e44e                	sd	s3,8(sp)
ffffffffc0204c7e:	e052                	sd	s4,0(sp)
ffffffffc0204c80:	842e                	mv	s0,a1
    if (mm != NULL) {
ffffffffc0204c82:	c135                	beqz	a0,ffffffffc0204ce6 <user_mem_check+0x74>
        if (!USER_ACCESS(addr, addr + len)) {
ffffffffc0204c84:	002007b7          	lui	a5,0x200
ffffffffc0204c88:	04f5e663          	bltu	a1,a5,ffffffffc0204cd4 <user_mem_check+0x62>
ffffffffc0204c8c:	00c584b3          	add	s1,a1,a2
ffffffffc0204c90:	0495f263          	bgeu	a1,s1,ffffffffc0204cd4 <user_mem_check+0x62>
ffffffffc0204c94:	4785                	li	a5,1
ffffffffc0204c96:	07fe                	slli	a5,a5,0x1f
ffffffffc0204c98:	0297ee63          	bltu	a5,s1,ffffffffc0204cd4 <user_mem_check+0x62>
ffffffffc0204c9c:	892a                	mv	s2,a0
ffffffffc0204c9e:	89b6                	mv	s3,a3
            }
            if (!(vma->vm_flags & ((write) ? VM_WRITE : VM_READ))) {
                return 0;
            }
            if (write && (vma->vm_flags & VM_STACK)) {
                if (start < vma->vm_start + PGSIZE) { //check stack start & size
ffffffffc0204ca0:	6a05                	lui	s4,0x1
ffffffffc0204ca2:	a821                	j	ffffffffc0204cba <user_mem_check+0x48>
            if (!(vma->vm_flags & ((write) ? VM_WRITE : VM_READ))) {
ffffffffc0204ca4:	0027f693          	andi	a3,a5,2
                if (start < vma->vm_start + PGSIZE) { //check stack start & size
ffffffffc0204ca8:	9752                	add	a4,a4,s4
            if (write && (vma->vm_flags & VM_STACK)) {
ffffffffc0204caa:	8ba1                	andi	a5,a5,8
            if (!(vma->vm_flags & ((write) ? VM_WRITE : VM_READ))) {
ffffffffc0204cac:	c685                	beqz	a3,ffffffffc0204cd4 <user_mem_check+0x62>
            if (write && (vma->vm_flags & VM_STACK)) {
ffffffffc0204cae:	c399                	beqz	a5,ffffffffc0204cb4 <user_mem_check+0x42>
                if (start < vma->vm_start + PGSIZE) { //check stack start & size
ffffffffc0204cb0:	02e46263          	bltu	s0,a4,ffffffffc0204cd4 <user_mem_check+0x62>
                    return 0;
                }
            }
            start = vma->vm_end;
ffffffffc0204cb4:	6900                	ld	s0,16(a0)
        while (start < end) {
ffffffffc0204cb6:	04947663          	bgeu	s0,s1,ffffffffc0204d02 <user_mem_check+0x90>
            if ((vma = find_vma(mm, start)) == NULL || start < vma->vm_start) {
ffffffffc0204cba:	85a2                	mv	a1,s0
ffffffffc0204cbc:	854a                	mv	a0,s2
ffffffffc0204cbe:	d70ff0ef          	jal	ra,ffffffffc020422e <find_vma>
ffffffffc0204cc2:	c909                	beqz	a0,ffffffffc0204cd4 <user_mem_check+0x62>
ffffffffc0204cc4:	6518                	ld	a4,8(a0)
ffffffffc0204cc6:	00e46763          	bltu	s0,a4,ffffffffc0204cd4 <user_mem_check+0x62>
            if (!(vma->vm_flags & ((write) ? VM_WRITE : VM_READ))) {
ffffffffc0204cca:	4d1c                	lw	a5,24(a0)
ffffffffc0204ccc:	fc099ce3          	bnez	s3,ffffffffc0204ca4 <user_mem_check+0x32>
ffffffffc0204cd0:	8b85                	andi	a5,a5,1
ffffffffc0204cd2:	f3ed                	bnez	a5,ffffffffc0204cb4 <user_mem_check+0x42>
            return 0;
ffffffffc0204cd4:	4501                	li	a0,0
        }
        return 1;
    }
    return KERN_ACCESS(addr, addr + len);
}
ffffffffc0204cd6:	70a2                	ld	ra,40(sp)
ffffffffc0204cd8:	7402                	ld	s0,32(sp)
ffffffffc0204cda:	64e2                	ld	s1,24(sp)
ffffffffc0204cdc:	6942                	ld	s2,16(sp)
ffffffffc0204cde:	69a2                	ld	s3,8(sp)
ffffffffc0204ce0:	6a02                	ld	s4,0(sp)
ffffffffc0204ce2:	6145                	addi	sp,sp,48
ffffffffc0204ce4:	8082                	ret
    return KERN_ACCESS(addr, addr + len);
ffffffffc0204ce6:	c02007b7          	lui	a5,0xc0200
ffffffffc0204cea:	4501                	li	a0,0
ffffffffc0204cec:	fef5e5e3          	bltu	a1,a5,ffffffffc0204cd6 <user_mem_check+0x64>
ffffffffc0204cf0:	962e                	add	a2,a2,a1
ffffffffc0204cf2:	fec5f2e3          	bgeu	a1,a2,ffffffffc0204cd6 <user_mem_check+0x64>
ffffffffc0204cf6:	c8000537          	lui	a0,0xc8000
ffffffffc0204cfa:	0505                	addi	a0,a0,1
ffffffffc0204cfc:	00a63533          	sltu	a0,a2,a0
ffffffffc0204d00:	bfd9                	j	ffffffffc0204cd6 <user_mem_check+0x64>
        return 1;
ffffffffc0204d02:	4505                	li	a0,1
ffffffffc0204d04:	bfc9                	j	ffffffffc0204cd6 <user_mem_check+0x64>

ffffffffc0204d06 <swapfs_init>:
#include <ide.h>
#include <pmm.h>
#include <assert.h>

void
swapfs_init(void) {
ffffffffc0204d06:	1141                	addi	sp,sp,-16
    static_assert((PGSIZE % SECTSIZE) == 0);
    if (!ide_device_valid(SWAP_DEV_NO)) {
ffffffffc0204d08:	4505                	li	a0,1
swapfs_init(void) {
ffffffffc0204d0a:	e406                	sd	ra,8(sp)
    if (!ide_device_valid(SWAP_DEV_NO)) {
ffffffffc0204d0c:	8e1fb0ef          	jal	ra,ffffffffc02005ec <ide_device_valid>
ffffffffc0204d10:	cd01                	beqz	a0,ffffffffc0204d28 <swapfs_init+0x22>
        panic("swap fs isn't available.\n");
    }
    max_swap_offset = ide_device_size(SWAP_DEV_NO) / (PGSIZE / SECTSIZE);
ffffffffc0204d12:	4505                	li	a0,1
ffffffffc0204d14:	8dffb0ef          	jal	ra,ffffffffc02005f2 <ide_device_size>
}
ffffffffc0204d18:	60a2                	ld	ra,8(sp)
    max_swap_offset = ide_device_size(SWAP_DEV_NO) / (PGSIZE / SECTSIZE);
ffffffffc0204d1a:	810d                	srli	a0,a0,0x3
ffffffffc0204d1c:	000ae797          	auipc	a5,0xae
ffffffffc0204d20:	baa7b623          	sd	a0,-1108(a5) # ffffffffc02b28c8 <max_swap_offset>
}
ffffffffc0204d24:	0141                	addi	sp,sp,16
ffffffffc0204d26:	8082                	ret
        panic("swap fs isn't available.\n");
ffffffffc0204d28:	00003617          	auipc	a2,0x3
ffffffffc0204d2c:	7a060613          	addi	a2,a2,1952 # ffffffffc02084c8 <default_pmm_manager+0x1048>
ffffffffc0204d30:	45b5                	li	a1,13
ffffffffc0204d32:	00003517          	auipc	a0,0x3
ffffffffc0204d36:	7b650513          	addi	a0,a0,1974 # ffffffffc02084e8 <default_pmm_manager+0x1068>
ffffffffc0204d3a:	f40fb0ef          	jal	ra,ffffffffc020047a <__panic>

ffffffffc0204d3e <swapfs_read>:

int
swapfs_read(swap_entry_t entry, struct Page *page) {
ffffffffc0204d3e:	1141                	addi	sp,sp,-16
ffffffffc0204d40:	e406                	sd	ra,8(sp)
    return ide_read_secs(SWAP_DEV_NO, swap_offset(entry) * PAGE_NSECT, page2kva(page), PAGE_NSECT);
ffffffffc0204d42:	00855793          	srli	a5,a0,0x8
ffffffffc0204d46:	cbb1                	beqz	a5,ffffffffc0204d9a <swapfs_read+0x5c>
ffffffffc0204d48:	000ae717          	auipc	a4,0xae
ffffffffc0204d4c:	b8073703          	ld	a4,-1152(a4) # ffffffffc02b28c8 <max_swap_offset>
ffffffffc0204d50:	04e7f563          	bgeu	a5,a4,ffffffffc0204d9a <swapfs_read+0x5c>
    return page - pages + nbase;
ffffffffc0204d54:	000ae617          	auipc	a2,0xae
ffffffffc0204d58:	b5c63603          	ld	a2,-1188(a2) # ffffffffc02b28b0 <pages>
ffffffffc0204d5c:	8d91                	sub	a1,a1,a2
ffffffffc0204d5e:	4065d613          	srai	a2,a1,0x6
ffffffffc0204d62:	00004717          	auipc	a4,0x4
ffffffffc0204d66:	0de73703          	ld	a4,222(a4) # ffffffffc0208e40 <nbase>
ffffffffc0204d6a:	963a                	add	a2,a2,a4
    return KADDR(page2pa(page));
ffffffffc0204d6c:	00c61713          	slli	a4,a2,0xc
ffffffffc0204d70:	8331                	srli	a4,a4,0xc
ffffffffc0204d72:	000ae697          	auipc	a3,0xae
ffffffffc0204d76:	b366b683          	ld	a3,-1226(a3) # ffffffffc02b28a8 <npage>
ffffffffc0204d7a:	0037959b          	slliw	a1,a5,0x3
    return page2ppn(page) << PGSHIFT;
ffffffffc0204d7e:	0632                	slli	a2,a2,0xc
    return KADDR(page2pa(page));
ffffffffc0204d80:	02d77963          	bgeu	a4,a3,ffffffffc0204db2 <swapfs_read+0x74>
}
ffffffffc0204d84:	60a2                	ld	ra,8(sp)
    return ide_read_secs(SWAP_DEV_NO, swap_offset(entry) * PAGE_NSECT, page2kva(page), PAGE_NSECT);
ffffffffc0204d86:	000ae797          	auipc	a5,0xae
ffffffffc0204d8a:	b3a7b783          	ld	a5,-1222(a5) # ffffffffc02b28c0 <va_pa_offset>
ffffffffc0204d8e:	46a1                	li	a3,8
ffffffffc0204d90:	963e                	add	a2,a2,a5
ffffffffc0204d92:	4505                	li	a0,1
}
ffffffffc0204d94:	0141                	addi	sp,sp,16
    return ide_read_secs(SWAP_DEV_NO, swap_offset(entry) * PAGE_NSECT, page2kva(page), PAGE_NSECT);
ffffffffc0204d96:	863fb06f          	j	ffffffffc02005f8 <ide_read_secs>
ffffffffc0204d9a:	86aa                	mv	a3,a0
ffffffffc0204d9c:	00003617          	auipc	a2,0x3
ffffffffc0204da0:	76460613          	addi	a2,a2,1892 # ffffffffc0208500 <default_pmm_manager+0x1080>
ffffffffc0204da4:	45d1                	li	a1,20
ffffffffc0204da6:	00003517          	auipc	a0,0x3
ffffffffc0204daa:	74250513          	addi	a0,a0,1858 # ffffffffc02084e8 <default_pmm_manager+0x1068>
ffffffffc0204dae:	eccfb0ef          	jal	ra,ffffffffc020047a <__panic>
ffffffffc0204db2:	86b2                	mv	a3,a2
ffffffffc0204db4:	06900593          	li	a1,105
ffffffffc0204db8:	00002617          	auipc	a2,0x2
ffffffffc0204dbc:	70060613          	addi	a2,a2,1792 # ffffffffc02074b8 <default_pmm_manager+0x38>
ffffffffc0204dc0:	00002517          	auipc	a0,0x2
ffffffffc0204dc4:	72050513          	addi	a0,a0,1824 # ffffffffc02074e0 <default_pmm_manager+0x60>
ffffffffc0204dc8:	eb2fb0ef          	jal	ra,ffffffffc020047a <__panic>

ffffffffc0204dcc <swapfs_write>:

int
swapfs_write(swap_entry_t entry, struct Page *page) {
ffffffffc0204dcc:	1141                	addi	sp,sp,-16
ffffffffc0204dce:	e406                	sd	ra,8(sp)
    return ide_write_secs(SWAP_DEV_NO, swap_offset(entry) * PAGE_NSECT, page2kva(page), PAGE_NSECT);
ffffffffc0204dd0:	00855793          	srli	a5,a0,0x8
ffffffffc0204dd4:	cbb1                	beqz	a5,ffffffffc0204e28 <swapfs_write+0x5c>
ffffffffc0204dd6:	000ae717          	auipc	a4,0xae
ffffffffc0204dda:	af273703          	ld	a4,-1294(a4) # ffffffffc02b28c8 <max_swap_offset>
ffffffffc0204dde:	04e7f563          	bgeu	a5,a4,ffffffffc0204e28 <swapfs_write+0x5c>
    return page - pages + nbase;
ffffffffc0204de2:	000ae617          	auipc	a2,0xae
ffffffffc0204de6:	ace63603          	ld	a2,-1330(a2) # ffffffffc02b28b0 <pages>
ffffffffc0204dea:	8d91                	sub	a1,a1,a2
ffffffffc0204dec:	4065d613          	srai	a2,a1,0x6
ffffffffc0204df0:	00004717          	auipc	a4,0x4
ffffffffc0204df4:	05073703          	ld	a4,80(a4) # ffffffffc0208e40 <nbase>
ffffffffc0204df8:	963a                	add	a2,a2,a4
    return KADDR(page2pa(page));
ffffffffc0204dfa:	00c61713          	slli	a4,a2,0xc
ffffffffc0204dfe:	8331                	srli	a4,a4,0xc
ffffffffc0204e00:	000ae697          	auipc	a3,0xae
ffffffffc0204e04:	aa86b683          	ld	a3,-1368(a3) # ffffffffc02b28a8 <npage>
ffffffffc0204e08:	0037959b          	slliw	a1,a5,0x3
    return page2ppn(page) << PGSHIFT;
ffffffffc0204e0c:	0632                	slli	a2,a2,0xc
    return KADDR(page2pa(page));
ffffffffc0204e0e:	02d77963          	bgeu	a4,a3,ffffffffc0204e40 <swapfs_write+0x74>
}
ffffffffc0204e12:	60a2                	ld	ra,8(sp)
    return ide_write_secs(SWAP_DEV_NO, swap_offset(entry) * PAGE_NSECT, page2kva(page), PAGE_NSECT);
ffffffffc0204e14:	000ae797          	auipc	a5,0xae
ffffffffc0204e18:	aac7b783          	ld	a5,-1364(a5) # ffffffffc02b28c0 <va_pa_offset>
ffffffffc0204e1c:	46a1                	li	a3,8
ffffffffc0204e1e:	963e                	add	a2,a2,a5
ffffffffc0204e20:	4505                	li	a0,1
}
ffffffffc0204e22:	0141                	addi	sp,sp,16
    return ide_write_secs(SWAP_DEV_NO, swap_offset(entry) * PAGE_NSECT, page2kva(page), PAGE_NSECT);
ffffffffc0204e24:	ff8fb06f          	j	ffffffffc020061c <ide_write_secs>
ffffffffc0204e28:	86aa                	mv	a3,a0
ffffffffc0204e2a:	00003617          	auipc	a2,0x3
ffffffffc0204e2e:	6d660613          	addi	a2,a2,1750 # ffffffffc0208500 <default_pmm_manager+0x1080>
ffffffffc0204e32:	45e5                	li	a1,25
ffffffffc0204e34:	00003517          	auipc	a0,0x3
ffffffffc0204e38:	6b450513          	addi	a0,a0,1716 # ffffffffc02084e8 <default_pmm_manager+0x1068>
ffffffffc0204e3c:	e3efb0ef          	jal	ra,ffffffffc020047a <__panic>
ffffffffc0204e40:	86b2                	mv	a3,a2
ffffffffc0204e42:	06900593          	li	a1,105
ffffffffc0204e46:	00002617          	auipc	a2,0x2
ffffffffc0204e4a:	67260613          	addi	a2,a2,1650 # ffffffffc02074b8 <default_pmm_manager+0x38>
ffffffffc0204e4e:	00002517          	auipc	a0,0x2
ffffffffc0204e52:	69250513          	addi	a0,a0,1682 # ffffffffc02074e0 <default_pmm_manager+0x60>
ffffffffc0204e56:	e24fb0ef          	jal	ra,ffffffffc020047a <__panic>

ffffffffc0204e5a <kernel_thread_entry>:
.text
.globl kernel_thread_entry
kernel_thread_entry:        # void kernel_thread(void)
	move a0, s1
ffffffffc0204e5a:	8526                	mv	a0,s1
	jalr s0
ffffffffc0204e5c:	9402                	jalr	s0

	jal do_exit
ffffffffc0204e5e:	600000ef          	jal	ra,ffffffffc020545e <do_exit>

ffffffffc0204e62 <alloc_proc>:
void forkrets(struct trapframe *tf);
void switch_to(struct context *from, struct context *to);

// alloc_proc - alloc a proc_struct and init all fields of proc_struct
static struct proc_struct *
alloc_proc(void) {
ffffffffc0204e62:	1141                	addi	sp,sp,-16
    struct proc_struct *proc = kmalloc(sizeof(struct proc_struct));
ffffffffc0204e64:	10800513          	li	a0,264
alloc_proc(void) {
ffffffffc0204e68:	e022                	sd	s0,0(sp)
ffffffffc0204e6a:	e406                	sd	ra,8(sp)
    struct proc_struct *proc = kmalloc(sizeof(struct proc_struct));
ffffffffc0204e6c:	c97fc0ef          	jal	ra,ffffffffc0201b02 <kmalloc>
ffffffffc0204e70:	842a                	mv	s0,a0
    if (proc != NULL) {
ffffffffc0204e72:	cd21                	beqz	a0,ffffffffc0204eca <alloc_proc+0x68>
     /*
     * below fields(add in LAB5) in proc_struct need to be initialized  
     *       uint32_t wait_state;                        // waiting state
     *       struct proc_struct *cptr, *yptr, *optr;     // relations between processes
     */
    proc->state = PROC_UNINIT;
ffffffffc0204e74:	57fd                	li	a5,-1
ffffffffc0204e76:	1782                	slli	a5,a5,0x20
ffffffffc0204e78:	e11c                	sd	a5,0(a0)
    proc->runs = 0;
    proc->kstack = 0;
    proc->need_resched = 0;
    proc->parent = NULL;
    proc->mm = NULL;
    memset(&(proc->context), 0, sizeof(struct context));
ffffffffc0204e7a:	07000613          	li	a2,112
ffffffffc0204e7e:	4581                	li	a1,0
    proc->runs = 0;
ffffffffc0204e80:	00052423          	sw	zero,8(a0)
    proc->kstack = 0;
ffffffffc0204e84:	00053823          	sd	zero,16(a0)
    proc->need_resched = 0;
ffffffffc0204e88:	00053c23          	sd	zero,24(a0)
    proc->parent = NULL;
ffffffffc0204e8c:	02053023          	sd	zero,32(a0)
    proc->mm = NULL;
ffffffffc0204e90:	02053423          	sd	zero,40(a0)
    memset(&(proc->context), 0, sizeof(struct context));
ffffffffc0204e94:	03050513          	addi	a0,a0,48
ffffffffc0204e98:	06d010ef          	jal	ra,ffffffffc0206704 <memset>
    proc->tf = NULL;
    proc->cr3 = boot_cr3;
ffffffffc0204e9c:	000ae797          	auipc	a5,0xae
ffffffffc0204ea0:	9fc7b783          	ld	a5,-1540(a5) # ffffffffc02b2898 <boot_cr3>
    proc->tf = NULL;
ffffffffc0204ea4:	0a043023          	sd	zero,160(s0)
    proc->cr3 = boot_cr3;
ffffffffc0204ea8:	f45c                	sd	a5,168(s0)
    proc->flags = 0;
ffffffffc0204eaa:	0a042823          	sw	zero,176(s0)
    memset(proc->name, 0, PROC_NAME_LEN + 1);
ffffffffc0204eae:	4641                	li	a2,16
ffffffffc0204eb0:	4581                	li	a1,0
ffffffffc0204eb2:	0b440513          	addi	a0,s0,180
ffffffffc0204eb6:	04f010ef          	jal	ra,ffffffffc0206704 <memset>

    proc->wait_state = 0;
ffffffffc0204eba:	0e042623          	sw	zero,236(s0)
    proc->cptr = proc->yptr = proc->optr = NULL;
ffffffffc0204ebe:	10043023          	sd	zero,256(s0)
ffffffffc0204ec2:	0e043c23          	sd	zero,248(s0)
ffffffffc0204ec6:	0e043823          	sd	zero,240(s0)
    }
    return proc;
}
ffffffffc0204eca:	60a2                	ld	ra,8(sp)
ffffffffc0204ecc:	8522                	mv	a0,s0
ffffffffc0204ece:	6402                	ld	s0,0(sp)
ffffffffc0204ed0:	0141                	addi	sp,sp,16
ffffffffc0204ed2:	8082                	ret

ffffffffc0204ed4 <forkret>:
// forkret -- the first kernel entry point of a new thread/process
// NOTE: the addr of forkret is setted in copy_thread function
//       after switch_to, the current proc will execute here.
static void
forkret(void) {
    forkrets(current->tf);
ffffffffc0204ed4:	000ae797          	auipc	a5,0xae
ffffffffc0204ed8:	a1c7b783          	ld	a5,-1508(a5) # ffffffffc02b28f0 <current>
ffffffffc0204edc:	73c8                	ld	a0,160(a5)
ffffffffc0204ede:	e99fb06f          	j	ffffffffc0200d76 <forkrets>

ffffffffc0204ee2 <user_main>:

// user_main - kernel thread used to exec a user program
static int
user_main(void *arg) {
#ifdef TEST
    KERNEL_EXECVE2(TEST, TESTSTART, TESTSIZE);
ffffffffc0204ee2:	000ae797          	auipc	a5,0xae
ffffffffc0204ee6:	a0e7b783          	ld	a5,-1522(a5) # ffffffffc02b28f0 <current>
ffffffffc0204eea:	43cc                	lw	a1,4(a5)
user_main(void *arg) {
ffffffffc0204eec:	7139                	addi	sp,sp,-64
    KERNEL_EXECVE2(TEST, TESTSTART, TESTSIZE);
ffffffffc0204eee:	00003617          	auipc	a2,0x3
ffffffffc0204ef2:	63260613          	addi	a2,a2,1586 # ffffffffc0208520 <default_pmm_manager+0x10a0>
ffffffffc0204ef6:	00003517          	auipc	a0,0x3
ffffffffc0204efa:	63a50513          	addi	a0,a0,1594 # ffffffffc0208530 <default_pmm_manager+0x10b0>
user_main(void *arg) {
ffffffffc0204efe:	fc06                	sd	ra,56(sp)
    KERNEL_EXECVE2(TEST, TESTSTART, TESTSIZE);
ffffffffc0204f00:	a80fb0ef          	jal	ra,ffffffffc0200180 <cprintf>
ffffffffc0204f04:	3fe06797          	auipc	a5,0x3fe06
ffffffffc0204f08:	a6c78793          	addi	a5,a5,-1428 # a970 <_binary_obj___user_forktest_out_size>
ffffffffc0204f0c:	e43e                	sd	a5,8(sp)
ffffffffc0204f0e:	00003517          	auipc	a0,0x3
ffffffffc0204f12:	61250513          	addi	a0,a0,1554 # ffffffffc0208520 <default_pmm_manager+0x10a0>
ffffffffc0204f16:	00046797          	auipc	a5,0x46
ffffffffc0204f1a:	82a78793          	addi	a5,a5,-2006 # ffffffffc024a740 <_binary_obj___user_forktest_out_start>
ffffffffc0204f1e:	f03e                	sd	a5,32(sp)
ffffffffc0204f20:	f42a                	sd	a0,40(sp)
    int64_t ret=0, len = strlen(name);
ffffffffc0204f22:	e802                	sd	zero,16(sp)
ffffffffc0204f24:	764010ef          	jal	ra,ffffffffc0206688 <strlen>
ffffffffc0204f28:	ec2a                	sd	a0,24(sp)
    asm volatile(
ffffffffc0204f2a:	4511                	li	a0,4
ffffffffc0204f2c:	55a2                	lw	a1,40(sp)
ffffffffc0204f2e:	4662                	lw	a2,24(sp)
ffffffffc0204f30:	5682                	lw	a3,32(sp)
ffffffffc0204f32:	4722                	lw	a4,8(sp)
ffffffffc0204f34:	48a9                	li	a7,10
ffffffffc0204f36:	9002                	ebreak
ffffffffc0204f38:	c82a                	sw	a0,16(sp)
    cprintf("ret = %d\n", ret);
ffffffffc0204f3a:	65c2                	ld	a1,16(sp)
ffffffffc0204f3c:	00003517          	auipc	a0,0x3
ffffffffc0204f40:	61c50513          	addi	a0,a0,1564 # ffffffffc0208558 <default_pmm_manager+0x10d8>
ffffffffc0204f44:	a3cfb0ef          	jal	ra,ffffffffc0200180 <cprintf>
#else
    KERNEL_EXECVE(exit);
#endif
    panic("user_main execve failed.\n");
ffffffffc0204f48:	00003617          	auipc	a2,0x3
ffffffffc0204f4c:	62060613          	addi	a2,a2,1568 # ffffffffc0208568 <default_pmm_manager+0x10e8>
ffffffffc0204f50:	34800593          	li	a1,840
ffffffffc0204f54:	00003517          	auipc	a0,0x3
ffffffffc0204f58:	63450513          	addi	a0,a0,1588 # ffffffffc0208588 <default_pmm_manager+0x1108>
ffffffffc0204f5c:	d1efb0ef          	jal	ra,ffffffffc020047a <__panic>

ffffffffc0204f60 <put_pgdir>:
    return pa2page(PADDR(kva));
ffffffffc0204f60:	6d14                	ld	a3,24(a0)
put_pgdir(struct mm_struct *mm) {
ffffffffc0204f62:	1141                	addi	sp,sp,-16
ffffffffc0204f64:	e406                	sd	ra,8(sp)
ffffffffc0204f66:	c02007b7          	lui	a5,0xc0200
ffffffffc0204f6a:	02f6ee63          	bltu	a3,a5,ffffffffc0204fa6 <put_pgdir+0x46>
ffffffffc0204f6e:	000ae517          	auipc	a0,0xae
ffffffffc0204f72:	95253503          	ld	a0,-1710(a0) # ffffffffc02b28c0 <va_pa_offset>
ffffffffc0204f76:	8e89                	sub	a3,a3,a0
    if (PPN(pa) >= npage) {
ffffffffc0204f78:	82b1                	srli	a3,a3,0xc
ffffffffc0204f7a:	000ae797          	auipc	a5,0xae
ffffffffc0204f7e:	92e7b783          	ld	a5,-1746(a5) # ffffffffc02b28a8 <npage>
ffffffffc0204f82:	02f6fe63          	bgeu	a3,a5,ffffffffc0204fbe <put_pgdir+0x5e>
    return &pages[PPN(pa) - nbase];
ffffffffc0204f86:	00004517          	auipc	a0,0x4
ffffffffc0204f8a:	eba53503          	ld	a0,-326(a0) # ffffffffc0208e40 <nbase>
}
ffffffffc0204f8e:	60a2                	ld	ra,8(sp)
ffffffffc0204f90:	8e89                	sub	a3,a3,a0
ffffffffc0204f92:	069a                	slli	a3,a3,0x6
    free_page(kva2page(mm->pgdir));
ffffffffc0204f94:	000ae517          	auipc	a0,0xae
ffffffffc0204f98:	91c53503          	ld	a0,-1764(a0) # ffffffffc02b28b0 <pages>
ffffffffc0204f9c:	4585                	li	a1,1
ffffffffc0204f9e:	9536                	add	a0,a0,a3
}
ffffffffc0204fa0:	0141                	addi	sp,sp,16
    free_page(kva2page(mm->pgdir));
ffffffffc0204fa2:	dd1fc06f          	j	ffffffffc0201d72 <free_pages>
    return pa2page(PADDR(kva));
ffffffffc0204fa6:	00002617          	auipc	a2,0x2
ffffffffc0204faa:	5ba60613          	addi	a2,a2,1466 # ffffffffc0207560 <default_pmm_manager+0xe0>
ffffffffc0204fae:	06e00593          	li	a1,110
ffffffffc0204fb2:	00002517          	auipc	a0,0x2
ffffffffc0204fb6:	52e50513          	addi	a0,a0,1326 # ffffffffc02074e0 <default_pmm_manager+0x60>
ffffffffc0204fba:	cc0fb0ef          	jal	ra,ffffffffc020047a <__panic>
        panic("pa2page called with invalid pa");
ffffffffc0204fbe:	00002617          	auipc	a2,0x2
ffffffffc0204fc2:	5ca60613          	addi	a2,a2,1482 # ffffffffc0207588 <default_pmm_manager+0x108>
ffffffffc0204fc6:	06200593          	li	a1,98
ffffffffc0204fca:	00002517          	auipc	a0,0x2
ffffffffc0204fce:	51650513          	addi	a0,a0,1302 # ffffffffc02074e0 <default_pmm_manager+0x60>
ffffffffc0204fd2:	ca8fb0ef          	jal	ra,ffffffffc020047a <__panic>

ffffffffc0204fd6 <proc_run>:
proc_run(struct proc_struct *proc) {
ffffffffc0204fd6:	7179                	addi	sp,sp,-48
ffffffffc0204fd8:	ec26                	sd	s1,24(sp)
    if (proc != current) {
ffffffffc0204fda:	000ae497          	auipc	s1,0xae
ffffffffc0204fde:	91648493          	addi	s1,s1,-1770 # ffffffffc02b28f0 <current>
proc_run(struct proc_struct *proc) {
ffffffffc0204fe2:	e84a                	sd	s2,16(sp)
    if (proc != current) {
ffffffffc0204fe4:	0004b903          	ld	s2,0(s1)
proc_run(struct proc_struct *proc) {
ffffffffc0204fe8:	f406                	sd	ra,40(sp)
ffffffffc0204fea:	f022                	sd	s0,32(sp)
ffffffffc0204fec:	e44e                	sd	s3,8(sp)
    if (proc != current) {
ffffffffc0204fee:	02a90863          	beq	s2,a0,ffffffffc020501e <proc_run+0x48>
ffffffffc0204ff2:	842a                	mv	s0,a0
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0204ff4:	100027f3          	csrr	a5,sstatus
ffffffffc0204ff8:	8b89                	andi	a5,a5,2
    return 0;
ffffffffc0204ffa:	4981                	li	s3,0
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0204ffc:	e3a1                	bnez	a5,ffffffffc020503c <proc_run+0x66>

#define barrier() __asm__ __volatile__ ("fence" ::: "memory")

static inline void
lcr3(unsigned long cr3) {
    write_csr(satp, 0x8000000000000000 | (cr3 >> RISCV_PGSHIFT));
ffffffffc0204ffe:	745c                	ld	a5,168(s0)
ffffffffc0205000:	577d                	li	a4,-1
ffffffffc0205002:	177e                	slli	a4,a4,0x3f
ffffffffc0205004:	83b1                	srli	a5,a5,0xc
ffffffffc0205006:	8fd9                	or	a5,a5,a4
ffffffffc0205008:	18079073          	csrw	satp,a5
            switch_to(&(prev->context), &(proc->context));
ffffffffc020500c:	03040593          	addi	a1,s0,48
ffffffffc0205010:	03090513          	addi	a0,s2,48
            current = proc;
ffffffffc0205014:	e080                	sd	s0,0(s1)
            switch_to(&(prev->context), &(proc->context));
ffffffffc0205016:	018010ef          	jal	ra,ffffffffc020602e <switch_to>
    if (flag) {
ffffffffc020501a:	00099963          	bnez	s3,ffffffffc020502c <proc_run+0x56>
}
ffffffffc020501e:	70a2                	ld	ra,40(sp)
ffffffffc0205020:	7402                	ld	s0,32(sp)
ffffffffc0205022:	64e2                	ld	s1,24(sp)
ffffffffc0205024:	6942                	ld	s2,16(sp)
ffffffffc0205026:	69a2                	ld	s3,8(sp)
ffffffffc0205028:	6145                	addi	sp,sp,48
ffffffffc020502a:	8082                	ret
ffffffffc020502c:	7402                	ld	s0,32(sp)
ffffffffc020502e:	70a2                	ld	ra,40(sp)
ffffffffc0205030:	64e2                	ld	s1,24(sp)
ffffffffc0205032:	6942                	ld	s2,16(sp)
ffffffffc0205034:	69a2                	ld	s3,8(sp)
ffffffffc0205036:	6145                	addi	sp,sp,48
        intr_enable();
ffffffffc0205038:	e08fb06f          	j	ffffffffc0200640 <intr_enable>
        intr_disable();
ffffffffc020503c:	e0afb0ef          	jal	ra,ffffffffc0200646 <intr_disable>
        return 1;
ffffffffc0205040:	4985                	li	s3,1
ffffffffc0205042:	bf75                	j	ffffffffc0204ffe <proc_run+0x28>

ffffffffc0205044 <do_fork>:
do_fork(uint32_t clone_flags, uintptr_t stack, struct trapframe *tf) {
ffffffffc0205044:	7119                	addi	sp,sp,-128
ffffffffc0205046:	f0ca                	sd	s2,96(sp)
    if (nr_process >= MAX_PROCESS) {
ffffffffc0205048:	000ae917          	auipc	s2,0xae
ffffffffc020504c:	8c090913          	addi	s2,s2,-1856 # ffffffffc02b2908 <nr_process>
ffffffffc0205050:	00092703          	lw	a4,0(s2)
do_fork(uint32_t clone_flags, uintptr_t stack, struct trapframe *tf) {
ffffffffc0205054:	fc86                	sd	ra,120(sp)
ffffffffc0205056:	f8a2                	sd	s0,112(sp)
ffffffffc0205058:	f4a6                	sd	s1,104(sp)
ffffffffc020505a:	ecce                	sd	s3,88(sp)
ffffffffc020505c:	e8d2                	sd	s4,80(sp)
ffffffffc020505e:	e4d6                	sd	s5,72(sp)
ffffffffc0205060:	e0da                	sd	s6,64(sp)
ffffffffc0205062:	fc5e                	sd	s7,56(sp)
ffffffffc0205064:	f862                	sd	s8,48(sp)
ffffffffc0205066:	f466                	sd	s9,40(sp)
ffffffffc0205068:	f06a                	sd	s10,32(sp)
ffffffffc020506a:	ec6e                	sd	s11,24(sp)
    if (nr_process >= MAX_PROCESS) {
ffffffffc020506c:	6785                	lui	a5,0x1
ffffffffc020506e:	2ef75e63          	bge	a4,a5,ffffffffc020536a <do_fork+0x326>
ffffffffc0205072:	8a2a                	mv	s4,a0
ffffffffc0205074:	89ae                	mv	s3,a1
ffffffffc0205076:	8432                	mv	s0,a2
    if ((proc = alloc_proc()) == NULL) {
ffffffffc0205078:	debff0ef          	jal	ra,ffffffffc0204e62 <alloc_proc>
ffffffffc020507c:	84aa                	mv	s1,a0
ffffffffc020507e:	2c050a63          	beqz	a0,ffffffffc0205352 <do_fork+0x30e>
    proc->parent = current;
ffffffffc0205082:	000aec17          	auipc	s8,0xae
ffffffffc0205086:	86ec0c13          	addi	s8,s8,-1938 # ffffffffc02b28f0 <current>
ffffffffc020508a:	000c3783          	ld	a5,0(s8)
    assert(current->wait_state == 0);
ffffffffc020508e:	0ec7a703          	lw	a4,236(a5) # 10ec <_binary_obj___user_faultread_out_size-0x8acc>
    proc->parent = current;
ffffffffc0205092:	f11c                	sd	a5,32(a0)
    assert(current->wait_state == 0);
ffffffffc0205094:	2e071d63          	bnez	a4,ffffffffc020538e <do_fork+0x34a>
    struct Page *page = alloc_pages(KSTACKPAGE);
ffffffffc0205098:	4509                	li	a0,2
ffffffffc020509a:	c47fc0ef          	jal	ra,ffffffffc0201ce0 <alloc_pages>
    if (page != NULL) {
ffffffffc020509e:	2a050763          	beqz	a0,ffffffffc020534c <do_fork+0x308>
    return page - pages + nbase;
ffffffffc02050a2:	000aea97          	auipc	s5,0xae
ffffffffc02050a6:	80ea8a93          	addi	s5,s5,-2034 # ffffffffc02b28b0 <pages>
ffffffffc02050aa:	000ab683          	ld	a3,0(s5)
ffffffffc02050ae:	00004b17          	auipc	s6,0x4
ffffffffc02050b2:	d92b0b13          	addi	s6,s6,-622 # ffffffffc0208e40 <nbase>
ffffffffc02050b6:	000b3783          	ld	a5,0(s6)
ffffffffc02050ba:	40d506b3          	sub	a3,a0,a3
    return KADDR(page2pa(page));
ffffffffc02050be:	000adb97          	auipc	s7,0xad
ffffffffc02050c2:	7eab8b93          	addi	s7,s7,2026 # ffffffffc02b28a8 <npage>
    return page - pages + nbase;
ffffffffc02050c6:	8699                	srai	a3,a3,0x6
    return KADDR(page2pa(page));
ffffffffc02050c8:	5dfd                	li	s11,-1
ffffffffc02050ca:	000bb703          	ld	a4,0(s7)
    return page - pages + nbase;
ffffffffc02050ce:	96be                	add	a3,a3,a5
    return KADDR(page2pa(page));
ffffffffc02050d0:	00cddd93          	srli	s11,s11,0xc
ffffffffc02050d4:	01b6f633          	and	a2,a3,s11
    return page2ppn(page) << PGSHIFT;
ffffffffc02050d8:	06b2                	slli	a3,a3,0xc
    return KADDR(page2pa(page));
ffffffffc02050da:	30e67263          	bgeu	a2,a4,ffffffffc02053de <do_fork+0x39a>
    struct mm_struct *mm, *oldmm = current->mm;
ffffffffc02050de:	000c3603          	ld	a2,0(s8)
ffffffffc02050e2:	000adc17          	auipc	s8,0xad
ffffffffc02050e6:	7dec0c13          	addi	s8,s8,2014 # ffffffffc02b28c0 <va_pa_offset>
ffffffffc02050ea:	000c3703          	ld	a4,0(s8)
ffffffffc02050ee:	02863d03          	ld	s10,40(a2)
ffffffffc02050f2:	e43e                	sd	a5,8(sp)
ffffffffc02050f4:	96ba                	add	a3,a3,a4
        proc->kstack = (uintptr_t)page2kva(page);
ffffffffc02050f6:	e894                	sd	a3,16(s1)
    if (oldmm == NULL) {
ffffffffc02050f8:	020d0863          	beqz	s10,ffffffffc0205128 <do_fork+0xe4>
    if (clone_flags & CLONE_VM) {
ffffffffc02050fc:	100a7a13          	andi	s4,s4,256
ffffffffc0205100:	180a0863          	beqz	s4,ffffffffc0205290 <do_fork+0x24c>
}

static inline int
mm_count_inc(struct mm_struct *mm) {
    mm->mm_count += 1;
ffffffffc0205104:	030d2703          	lw	a4,48(s10)
    proc->cr3 = PADDR(mm->pgdir);
ffffffffc0205108:	018d3783          	ld	a5,24(s10)
ffffffffc020510c:	c02006b7          	lui	a3,0xc0200
ffffffffc0205110:	2705                	addiw	a4,a4,1
ffffffffc0205112:	02ed2823          	sw	a4,48(s10)
    proc->mm = mm;
ffffffffc0205116:	03a4b423          	sd	s10,40(s1)
    proc->cr3 = PADDR(mm->pgdir);
ffffffffc020511a:	24d7ed63          	bltu	a5,a3,ffffffffc0205374 <do_fork+0x330>
ffffffffc020511e:	000c3703          	ld	a4,0(s8)
    proc->tf = (struct trapframe *)(proc->kstack + KSTACKSIZE) - 1;
ffffffffc0205122:	6894                	ld	a3,16(s1)
    proc->cr3 = PADDR(mm->pgdir);
ffffffffc0205124:	8f99                	sub	a5,a5,a4
ffffffffc0205126:	f4dc                	sd	a5,168(s1)
    proc->tf = (struct trapframe *)(proc->kstack + KSTACKSIZE) - 1;
ffffffffc0205128:	6789                	lui	a5,0x2
ffffffffc020512a:	ee078793          	addi	a5,a5,-288 # 1ee0 <_binary_obj___user_faultread_out_size-0x7cd8>
ffffffffc020512e:	96be                	add	a3,a3,a5
    *(proc->tf) = *tf;
ffffffffc0205130:	8622                	mv	a2,s0
    proc->tf = (struct trapframe *)(proc->kstack + KSTACKSIZE) - 1;
ffffffffc0205132:	f0d4                	sd	a3,160(s1)
    *(proc->tf) = *tf;
ffffffffc0205134:	87b6                	mv	a5,a3
ffffffffc0205136:	12040893          	addi	a7,s0,288
ffffffffc020513a:	00063803          	ld	a6,0(a2)
ffffffffc020513e:	6608                	ld	a0,8(a2)
ffffffffc0205140:	6a0c                	ld	a1,16(a2)
ffffffffc0205142:	6e18                	ld	a4,24(a2)
ffffffffc0205144:	0107b023          	sd	a6,0(a5)
ffffffffc0205148:	e788                	sd	a0,8(a5)
ffffffffc020514a:	eb8c                	sd	a1,16(a5)
ffffffffc020514c:	ef98                	sd	a4,24(a5)
ffffffffc020514e:	02060613          	addi	a2,a2,32
ffffffffc0205152:	02078793          	addi	a5,a5,32
ffffffffc0205156:	ff1612e3          	bne	a2,a7,ffffffffc020513a <do_fork+0xf6>
    proc->tf->gpr.a0 = 0;
ffffffffc020515a:	0406b823          	sd	zero,80(a3) # ffffffffc0200050 <kern_init+0x1e>
    proc->tf->gpr.sp = (esp == 0) ? (uintptr_t)proc->tf : esp;
ffffffffc020515e:	12098763          	beqz	s3,ffffffffc020528c <do_fork+0x248>
    if (++ last_pid >= MAX_PID) {
ffffffffc0205162:	000a2817          	auipc	a6,0xa2
ffffffffc0205166:	24680813          	addi	a6,a6,582 # ffffffffc02a73a8 <last_pid.1>
ffffffffc020516a:	00082783          	lw	a5,0(a6)
    proc->tf->gpr.sp = (esp == 0) ? (uintptr_t)proc->tf : esp;
ffffffffc020516e:	0136b823          	sd	s3,16(a3)
    proc->context.ra = (uintptr_t)forkret;
ffffffffc0205172:	00000717          	auipc	a4,0x0
ffffffffc0205176:	d6270713          	addi	a4,a4,-670 # ffffffffc0204ed4 <forkret>
    if (++ last_pid >= MAX_PID) {
ffffffffc020517a:	0017851b          	addiw	a0,a5,1
    proc->context.ra = (uintptr_t)forkret;
ffffffffc020517e:	f898                	sd	a4,48(s1)
    proc->context.sp = (uintptr_t)(proc->tf);
ffffffffc0205180:	fc94                	sd	a3,56(s1)
    if (++ last_pid >= MAX_PID) {
ffffffffc0205182:	00a82023          	sw	a0,0(a6)
ffffffffc0205186:	6789                	lui	a5,0x2
ffffffffc0205188:	08f55b63          	bge	a0,a5,ffffffffc020521e <do_fork+0x1da>
    if (last_pid >= next_safe) {
ffffffffc020518c:	000a2317          	auipc	t1,0xa2
ffffffffc0205190:	22030313          	addi	t1,t1,544 # ffffffffc02a73ac <next_safe.0>
ffffffffc0205194:	00032783          	lw	a5,0(t1)
ffffffffc0205198:	000ad417          	auipc	s0,0xad
ffffffffc020519c:	6d040413          	addi	s0,s0,1744 # ffffffffc02b2868 <proc_list>
ffffffffc02051a0:	08f55763          	bge	a0,a5,ffffffffc020522e <do_fork+0x1ea>
    proc->pid = get_pid();
ffffffffc02051a4:	c0c8                	sw	a0,4(s1)
    list_add(hash_list + pid_hashfn(proc->pid), &(proc->hash_link));
ffffffffc02051a6:	45a9                	li	a1,10
ffffffffc02051a8:	2501                	sext.w	a0,a0
ffffffffc02051aa:	0da010ef          	jal	ra,ffffffffc0206284 <hash32>
ffffffffc02051ae:	02051793          	slli	a5,a0,0x20
ffffffffc02051b2:	01c7d513          	srli	a0,a5,0x1c
ffffffffc02051b6:	000a9797          	auipc	a5,0xa9
ffffffffc02051ba:	6b278793          	addi	a5,a5,1714 # ffffffffc02ae868 <hash_list>
ffffffffc02051be:	953e                	add	a0,a0,a5
    __list_add(elm, listelm, listelm->next);
ffffffffc02051c0:	650c                	ld	a1,8(a0)
    if ((proc->optr = proc->parent->cptr) != NULL) {
ffffffffc02051c2:	7094                	ld	a3,32(s1)
    list_add(hash_list + pid_hashfn(proc->pid), &(proc->hash_link));
ffffffffc02051c4:	0d848793          	addi	a5,s1,216
    prev->next = next->prev = elm;
ffffffffc02051c8:	e19c                	sd	a5,0(a1)
    __list_add(elm, listelm, listelm->next);
ffffffffc02051ca:	6410                	ld	a2,8(s0)
    prev->next = next->prev = elm;
ffffffffc02051cc:	e51c                	sd	a5,8(a0)
    if ((proc->optr = proc->parent->cptr) != NULL) {
ffffffffc02051ce:	7af8                	ld	a4,240(a3)
    list_add(&proc_list, &(proc->list_link));
ffffffffc02051d0:	0c848793          	addi	a5,s1,200
    elm->next = next;
ffffffffc02051d4:	f0ec                	sd	a1,224(s1)
    elm->prev = prev;
ffffffffc02051d6:	ece8                	sd	a0,216(s1)
    prev->next = next->prev = elm;
ffffffffc02051d8:	e21c                	sd	a5,0(a2)
ffffffffc02051da:	e41c                	sd	a5,8(s0)
    elm->next = next;
ffffffffc02051dc:	e8f0                	sd	a2,208(s1)
    elm->prev = prev;
ffffffffc02051de:	e4e0                	sd	s0,200(s1)
    proc->yptr = NULL;
ffffffffc02051e0:	0e04bc23          	sd	zero,248(s1)
    if ((proc->optr = proc->parent->cptr) != NULL) {
ffffffffc02051e4:	10e4b023          	sd	a4,256(s1)
ffffffffc02051e8:	c311                	beqz	a4,ffffffffc02051ec <do_fork+0x1a8>
        proc->optr->yptr = proc;
ffffffffc02051ea:	ff64                	sd	s1,248(a4)
    nr_process ++;
ffffffffc02051ec:	00092783          	lw	a5,0(s2)
    wakeup_proc(proc);
ffffffffc02051f0:	8526                	mv	a0,s1
    proc->parent->cptr = proc;
ffffffffc02051f2:	fae4                	sd	s1,240(a3)
    nr_process ++;
ffffffffc02051f4:	2785                	addiw	a5,a5,1
ffffffffc02051f6:	00f92023          	sw	a5,0(s2)
    wakeup_proc(proc);
ffffffffc02051fa:	69f000ef          	jal	ra,ffffffffc0206098 <wakeup_proc>
    ret = proc->pid;
ffffffffc02051fe:	40c8                	lw	a0,4(s1)
}
ffffffffc0205200:	70e6                	ld	ra,120(sp)
ffffffffc0205202:	7446                	ld	s0,112(sp)
ffffffffc0205204:	74a6                	ld	s1,104(sp)
ffffffffc0205206:	7906                	ld	s2,96(sp)
ffffffffc0205208:	69e6                	ld	s3,88(sp)
ffffffffc020520a:	6a46                	ld	s4,80(sp)
ffffffffc020520c:	6aa6                	ld	s5,72(sp)
ffffffffc020520e:	6b06                	ld	s6,64(sp)
ffffffffc0205210:	7be2                	ld	s7,56(sp)
ffffffffc0205212:	7c42                	ld	s8,48(sp)
ffffffffc0205214:	7ca2                	ld	s9,40(sp)
ffffffffc0205216:	7d02                	ld	s10,32(sp)
ffffffffc0205218:	6de2                	ld	s11,24(sp)
ffffffffc020521a:	6109                	addi	sp,sp,128
ffffffffc020521c:	8082                	ret
        last_pid = 1;
ffffffffc020521e:	4785                	li	a5,1
ffffffffc0205220:	00f82023          	sw	a5,0(a6)
        goto inside;
ffffffffc0205224:	4505                	li	a0,1
ffffffffc0205226:	000a2317          	auipc	t1,0xa2
ffffffffc020522a:	18630313          	addi	t1,t1,390 # ffffffffc02a73ac <next_safe.0>
    return listelm->next;
ffffffffc020522e:	000ad417          	auipc	s0,0xad
ffffffffc0205232:	63a40413          	addi	s0,s0,1594 # ffffffffc02b2868 <proc_list>
ffffffffc0205236:	00843e03          	ld	t3,8(s0)
        next_safe = MAX_PID;
ffffffffc020523a:	6789                	lui	a5,0x2
ffffffffc020523c:	00f32023          	sw	a5,0(t1)
ffffffffc0205240:	86aa                	mv	a3,a0
ffffffffc0205242:	4581                	li	a1,0
        while ((le = list_next(le)) != list) {
ffffffffc0205244:	6e89                	lui	t4,0x2
ffffffffc0205246:	108e0d63          	beq	t3,s0,ffffffffc0205360 <do_fork+0x31c>
ffffffffc020524a:	88ae                	mv	a7,a1
ffffffffc020524c:	87f2                	mv	a5,t3
ffffffffc020524e:	6609                	lui	a2,0x2
ffffffffc0205250:	a811                	j	ffffffffc0205264 <do_fork+0x220>
            else if (proc->pid > last_pid && next_safe > proc->pid) {
ffffffffc0205252:	00e6d663          	bge	a3,a4,ffffffffc020525e <do_fork+0x21a>
ffffffffc0205256:	00c75463          	bge	a4,a2,ffffffffc020525e <do_fork+0x21a>
ffffffffc020525a:	863a                	mv	a2,a4
ffffffffc020525c:	4885                	li	a7,1
ffffffffc020525e:	679c                	ld	a5,8(a5)
        while ((le = list_next(le)) != list) {
ffffffffc0205260:	00878d63          	beq	a5,s0,ffffffffc020527a <do_fork+0x236>
            if (proc->pid == last_pid) {
ffffffffc0205264:	f3c7a703          	lw	a4,-196(a5) # 1f3c <_binary_obj___user_faultread_out_size-0x7c7c>
ffffffffc0205268:	fed715e3          	bne	a4,a3,ffffffffc0205252 <do_fork+0x20e>
                if (++ last_pid >= next_safe) {
ffffffffc020526c:	2685                	addiw	a3,a3,1
ffffffffc020526e:	0ec6d463          	bge	a3,a2,ffffffffc0205356 <do_fork+0x312>
ffffffffc0205272:	679c                	ld	a5,8(a5)
ffffffffc0205274:	4585                	li	a1,1
        while ((le = list_next(le)) != list) {
ffffffffc0205276:	fe8797e3          	bne	a5,s0,ffffffffc0205264 <do_fork+0x220>
ffffffffc020527a:	c581                	beqz	a1,ffffffffc0205282 <do_fork+0x23e>
ffffffffc020527c:	00d82023          	sw	a3,0(a6)
ffffffffc0205280:	8536                	mv	a0,a3
ffffffffc0205282:	f20881e3          	beqz	a7,ffffffffc02051a4 <do_fork+0x160>
ffffffffc0205286:	00c32023          	sw	a2,0(t1)
ffffffffc020528a:	bf29                	j	ffffffffc02051a4 <do_fork+0x160>
    proc->tf->gpr.sp = (esp == 0) ? (uintptr_t)proc->tf : esp;
ffffffffc020528c:	89b6                	mv	s3,a3
ffffffffc020528e:	bdd1                	j	ffffffffc0205162 <do_fork+0x11e>
    if ((mm = mm_create()) == NULL) {
ffffffffc0205290:	f29fe0ef          	jal	ra,ffffffffc02041b8 <mm_create>
ffffffffc0205294:	8caa                	mv	s9,a0
ffffffffc0205296:	c159                	beqz	a0,ffffffffc020531c <do_fork+0x2d8>
    if ((page = alloc_page()) == NULL) {
ffffffffc0205298:	4505                	li	a0,1
ffffffffc020529a:	a47fc0ef          	jal	ra,ffffffffc0201ce0 <alloc_pages>
ffffffffc020529e:	cd25                	beqz	a0,ffffffffc0205316 <do_fork+0x2d2>
    return page - pages + nbase;
ffffffffc02052a0:	000ab683          	ld	a3,0(s5)
ffffffffc02052a4:	67a2                	ld	a5,8(sp)
    return KADDR(page2pa(page));
ffffffffc02052a6:	000bb703          	ld	a4,0(s7)
    return page - pages + nbase;
ffffffffc02052aa:	40d506b3          	sub	a3,a0,a3
ffffffffc02052ae:	8699                	srai	a3,a3,0x6
ffffffffc02052b0:	96be                	add	a3,a3,a5
    return KADDR(page2pa(page));
ffffffffc02052b2:	01b6fdb3          	and	s11,a3,s11
    return page2ppn(page) << PGSHIFT;
ffffffffc02052b6:	06b2                	slli	a3,a3,0xc
    return KADDR(page2pa(page));
ffffffffc02052b8:	12edf363          	bgeu	s11,a4,ffffffffc02053de <do_fork+0x39a>
ffffffffc02052bc:	000c3a03          	ld	s4,0(s8)
    memcpy(pgdir, boot_pgdir, PGSIZE);
ffffffffc02052c0:	6605                	lui	a2,0x1
ffffffffc02052c2:	000ad597          	auipc	a1,0xad
ffffffffc02052c6:	5de5b583          	ld	a1,1502(a1) # ffffffffc02b28a0 <boot_pgdir>
ffffffffc02052ca:	9a36                	add	s4,s4,a3
ffffffffc02052cc:	8552                	mv	a0,s4
ffffffffc02052ce:	448010ef          	jal	ra,ffffffffc0206716 <memcpy>
}

static inline void
lock_mm(struct mm_struct *mm) {
    if (mm != NULL) {
        lock(&(mm->mm_lock));
ffffffffc02052d2:	038d0d93          	addi	s11,s10,56
    mm->pgdir = pgdir;
ffffffffc02052d6:	014cbc23          	sd	s4,24(s9)
 * test_and_set_bit - Atomically set a bit and return its old value
 * @nr:     the bit to set
 * @addr:   the address to count from
 * */
static inline bool test_and_set_bit(int nr, volatile void *addr) {
    return __test_and_op_bit(or, __NOP, nr, ((volatile unsigned long *)addr));
ffffffffc02052da:	4785                	li	a5,1
ffffffffc02052dc:	40fdb7af          	amoor.d	a5,a5,(s11)
    return !test_and_set_bit(0, lock);
}

static inline void
lock(lock_t *lock) {
    while (!try_lock(lock)) {
ffffffffc02052e0:	8b85                	andi	a5,a5,1
ffffffffc02052e2:	4a05                	li	s4,1
ffffffffc02052e4:	c799                	beqz	a5,ffffffffc02052f2 <do_fork+0x2ae>
        schedule();
ffffffffc02052e6:	633000ef          	jal	ra,ffffffffc0206118 <schedule>
ffffffffc02052ea:	414db7af          	amoor.d	a5,s4,(s11)
    while (!try_lock(lock)) {
ffffffffc02052ee:	8b85                	andi	a5,a5,1
ffffffffc02052f0:	fbfd                	bnez	a5,ffffffffc02052e6 <do_fork+0x2a2>
        ret = dup_mmap(mm, oldmm);
ffffffffc02052f2:	85ea                	mv	a1,s10
ffffffffc02052f4:	8566                	mv	a0,s9
ffffffffc02052f6:	94aff0ef          	jal	ra,ffffffffc0204440 <dup_mmap>
 * test_and_clear_bit - Atomically clear a bit and return its old value
 * @nr:     the bit to clear
 * @addr:   the address to count from
 * */
static inline bool test_and_clear_bit(int nr, volatile void *addr) {
    return __test_and_op_bit(and, __NOT, nr, ((volatile unsigned long *)addr));
ffffffffc02052fa:	57f9                	li	a5,-2
ffffffffc02052fc:	60fdb7af          	amoand.d	a5,a5,(s11)
ffffffffc0205300:	8b85                	andi	a5,a5,1
    }
}

static inline void
unlock(lock_t *lock) {
    if (!test_and_clear_bit(0, lock)) {
ffffffffc0205302:	c3f1                	beqz	a5,ffffffffc02053c6 <do_fork+0x382>
good_mm:
ffffffffc0205304:	8d66                	mv	s10,s9
    if (ret != 0) {
ffffffffc0205306:	de050fe3          	beqz	a0,ffffffffc0205104 <do_fork+0xc0>
    exit_mmap(mm);
ffffffffc020530a:	8566                	mv	a0,s9
ffffffffc020530c:	9ceff0ef          	jal	ra,ffffffffc02044da <exit_mmap>
    put_pgdir(mm);
ffffffffc0205310:	8566                	mv	a0,s9
ffffffffc0205312:	c4fff0ef          	jal	ra,ffffffffc0204f60 <put_pgdir>
    mm_destroy(mm);
ffffffffc0205316:	8566                	mv	a0,s9
ffffffffc0205318:	826ff0ef          	jal	ra,ffffffffc020433e <mm_destroy>
    free_pages(kva2page((void *)(proc->kstack)), KSTACKPAGE);
ffffffffc020531c:	6894                	ld	a3,16(s1)
    return pa2page(PADDR(kva));
ffffffffc020531e:	c02007b7          	lui	a5,0xc0200
ffffffffc0205322:	0cf6ea63          	bltu	a3,a5,ffffffffc02053f6 <do_fork+0x3b2>
ffffffffc0205326:	000c3783          	ld	a5,0(s8)
    if (PPN(pa) >= npage) {
ffffffffc020532a:	000bb703          	ld	a4,0(s7)
    return pa2page(PADDR(kva));
ffffffffc020532e:	40f687b3          	sub	a5,a3,a5
    if (PPN(pa) >= npage) {
ffffffffc0205332:	83b1                	srli	a5,a5,0xc
ffffffffc0205334:	06e7fd63          	bgeu	a5,a4,ffffffffc02053ae <do_fork+0x36a>
    return &pages[PPN(pa) - nbase];
ffffffffc0205338:	000b3703          	ld	a4,0(s6)
ffffffffc020533c:	000ab503          	ld	a0,0(s5)
ffffffffc0205340:	4589                	li	a1,2
ffffffffc0205342:	8f99                	sub	a5,a5,a4
ffffffffc0205344:	079a                	slli	a5,a5,0x6
ffffffffc0205346:	953e                	add	a0,a0,a5
ffffffffc0205348:	a2bfc0ef          	jal	ra,ffffffffc0201d72 <free_pages>
    kfree(proc);
ffffffffc020534c:	8526                	mv	a0,s1
ffffffffc020534e:	865fc0ef          	jal	ra,ffffffffc0201bb2 <kfree>
    ret = -E_NO_MEM;
ffffffffc0205352:	5571                	li	a0,-4
    return ret;
ffffffffc0205354:	b575                	j	ffffffffc0205200 <do_fork+0x1bc>
                    if (last_pid >= MAX_PID) {
ffffffffc0205356:	01d6c363          	blt	a3,t4,ffffffffc020535c <do_fork+0x318>
                        last_pid = 1;
ffffffffc020535a:	4685                	li	a3,1
                    goto repeat;
ffffffffc020535c:	4585                	li	a1,1
ffffffffc020535e:	b5e5                	j	ffffffffc0205246 <do_fork+0x202>
ffffffffc0205360:	c599                	beqz	a1,ffffffffc020536e <do_fork+0x32a>
ffffffffc0205362:	00d82023          	sw	a3,0(a6)
    return last_pid;
ffffffffc0205366:	8536                	mv	a0,a3
ffffffffc0205368:	bd35                	j	ffffffffc02051a4 <do_fork+0x160>
    int ret = -E_NO_FREE_PROC;
ffffffffc020536a:	556d                	li	a0,-5
ffffffffc020536c:	bd51                	j	ffffffffc0205200 <do_fork+0x1bc>
    return last_pid;
ffffffffc020536e:	00082503          	lw	a0,0(a6)
ffffffffc0205372:	bd0d                	j	ffffffffc02051a4 <do_fork+0x160>
    proc->cr3 = PADDR(mm->pgdir);
ffffffffc0205374:	86be                	mv	a3,a5
ffffffffc0205376:	00002617          	auipc	a2,0x2
ffffffffc020537a:	1ea60613          	addi	a2,a2,490 # ffffffffc0207560 <default_pmm_manager+0xe0>
ffffffffc020537e:	16400593          	li	a1,356
ffffffffc0205382:	00003517          	auipc	a0,0x3
ffffffffc0205386:	20650513          	addi	a0,a0,518 # ffffffffc0208588 <default_pmm_manager+0x1108>
ffffffffc020538a:	8f0fb0ef          	jal	ra,ffffffffc020047a <__panic>
    assert(current->wait_state == 0);
ffffffffc020538e:	00003697          	auipc	a3,0x3
ffffffffc0205392:	21268693          	addi	a3,a3,530 # ffffffffc02085a0 <default_pmm_manager+0x1120>
ffffffffc0205396:	00002617          	auipc	a2,0x2
ffffffffc020539a:	a5260613          	addi	a2,a2,-1454 # ffffffffc0206de8 <commands+0x450>
ffffffffc020539e:	1b100593          	li	a1,433
ffffffffc02053a2:	00003517          	auipc	a0,0x3
ffffffffc02053a6:	1e650513          	addi	a0,a0,486 # ffffffffc0208588 <default_pmm_manager+0x1108>
ffffffffc02053aa:	8d0fb0ef          	jal	ra,ffffffffc020047a <__panic>
        panic("pa2page called with invalid pa");
ffffffffc02053ae:	00002617          	auipc	a2,0x2
ffffffffc02053b2:	1da60613          	addi	a2,a2,474 # ffffffffc0207588 <default_pmm_manager+0x108>
ffffffffc02053b6:	06200593          	li	a1,98
ffffffffc02053ba:	00002517          	auipc	a0,0x2
ffffffffc02053be:	12650513          	addi	a0,a0,294 # ffffffffc02074e0 <default_pmm_manager+0x60>
ffffffffc02053c2:	8b8fb0ef          	jal	ra,ffffffffc020047a <__panic>
        panic("Unlock failed.\n");
ffffffffc02053c6:	00003617          	auipc	a2,0x3
ffffffffc02053ca:	1fa60613          	addi	a2,a2,506 # ffffffffc02085c0 <default_pmm_manager+0x1140>
ffffffffc02053ce:	03100593          	li	a1,49
ffffffffc02053d2:	00003517          	auipc	a0,0x3
ffffffffc02053d6:	1fe50513          	addi	a0,a0,510 # ffffffffc02085d0 <default_pmm_manager+0x1150>
ffffffffc02053da:	8a0fb0ef          	jal	ra,ffffffffc020047a <__panic>
    return KADDR(page2pa(page));
ffffffffc02053de:	00002617          	auipc	a2,0x2
ffffffffc02053e2:	0da60613          	addi	a2,a2,218 # ffffffffc02074b8 <default_pmm_manager+0x38>
ffffffffc02053e6:	06900593          	li	a1,105
ffffffffc02053ea:	00002517          	auipc	a0,0x2
ffffffffc02053ee:	0f650513          	addi	a0,a0,246 # ffffffffc02074e0 <default_pmm_manager+0x60>
ffffffffc02053f2:	888fb0ef          	jal	ra,ffffffffc020047a <__panic>
    return pa2page(PADDR(kva));
ffffffffc02053f6:	00002617          	auipc	a2,0x2
ffffffffc02053fa:	16a60613          	addi	a2,a2,362 # ffffffffc0207560 <default_pmm_manager+0xe0>
ffffffffc02053fe:	06e00593          	li	a1,110
ffffffffc0205402:	00002517          	auipc	a0,0x2
ffffffffc0205406:	0de50513          	addi	a0,a0,222 # ffffffffc02074e0 <default_pmm_manager+0x60>
ffffffffc020540a:	870fb0ef          	jal	ra,ffffffffc020047a <__panic>

ffffffffc020540e <kernel_thread>:
kernel_thread(int (*fn)(void *), void *arg, uint32_t clone_flags) {
ffffffffc020540e:	7129                	addi	sp,sp,-320
ffffffffc0205410:	fa22                	sd	s0,304(sp)
ffffffffc0205412:	f626                	sd	s1,296(sp)
ffffffffc0205414:	f24a                	sd	s2,288(sp)
ffffffffc0205416:	84ae                	mv	s1,a1
ffffffffc0205418:	892a                	mv	s2,a0
ffffffffc020541a:	8432                	mv	s0,a2
    memset(&tf, 0, sizeof(struct trapframe));
ffffffffc020541c:	4581                	li	a1,0
ffffffffc020541e:	12000613          	li	a2,288
ffffffffc0205422:	850a                	mv	a0,sp
kernel_thread(int (*fn)(void *), void *arg, uint32_t clone_flags) {
ffffffffc0205424:	fe06                	sd	ra,312(sp)
    memset(&tf, 0, sizeof(struct trapframe));
ffffffffc0205426:	2de010ef          	jal	ra,ffffffffc0206704 <memset>
    tf.gpr.s0 = (uintptr_t)fn;
ffffffffc020542a:	e0ca                	sd	s2,64(sp)
    tf.gpr.s1 = (uintptr_t)arg;
ffffffffc020542c:	e4a6                	sd	s1,72(sp)
    tf.status = (read_csr(sstatus) | SSTATUS_SPP | SSTATUS_SPIE) & ~SSTATUS_SIE;
ffffffffc020542e:	100027f3          	csrr	a5,sstatus
ffffffffc0205432:	edd7f793          	andi	a5,a5,-291
ffffffffc0205436:	1207e793          	ori	a5,a5,288
ffffffffc020543a:	e23e                	sd	a5,256(sp)
    return do_fork(clone_flags | CLONE_VM, 0, &tf);
ffffffffc020543c:	860a                	mv	a2,sp
ffffffffc020543e:	10046513          	ori	a0,s0,256
    tf.epc = (uintptr_t)kernel_thread_entry;
ffffffffc0205442:	00000797          	auipc	a5,0x0
ffffffffc0205446:	a1878793          	addi	a5,a5,-1512 # ffffffffc0204e5a <kernel_thread_entry>
    return do_fork(clone_flags | CLONE_VM, 0, &tf);
ffffffffc020544a:	4581                	li	a1,0
    tf.epc = (uintptr_t)kernel_thread_entry;
ffffffffc020544c:	e63e                	sd	a5,264(sp)
    return do_fork(clone_flags | CLONE_VM, 0, &tf);
ffffffffc020544e:	bf7ff0ef          	jal	ra,ffffffffc0205044 <do_fork>
}
ffffffffc0205452:	70f2                	ld	ra,312(sp)
ffffffffc0205454:	7452                	ld	s0,304(sp)
ffffffffc0205456:	74b2                	ld	s1,296(sp)
ffffffffc0205458:	7912                	ld	s2,288(sp)
ffffffffc020545a:	6131                	addi	sp,sp,320
ffffffffc020545c:	8082                	ret

ffffffffc020545e <do_exit>:
do_exit(int error_code) {
ffffffffc020545e:	7179                	addi	sp,sp,-48
ffffffffc0205460:	f022                	sd	s0,32(sp)
    if (current == idleproc) {
ffffffffc0205462:	000ad417          	auipc	s0,0xad
ffffffffc0205466:	48e40413          	addi	s0,s0,1166 # ffffffffc02b28f0 <current>
ffffffffc020546a:	601c                	ld	a5,0(s0)
do_exit(int error_code) {
ffffffffc020546c:	f406                	sd	ra,40(sp)
ffffffffc020546e:	ec26                	sd	s1,24(sp)
ffffffffc0205470:	e84a                	sd	s2,16(sp)
ffffffffc0205472:	e44e                	sd	s3,8(sp)
ffffffffc0205474:	e052                	sd	s4,0(sp)
    if (current == idleproc) {
ffffffffc0205476:	000ad717          	auipc	a4,0xad
ffffffffc020547a:	48273703          	ld	a4,1154(a4) # ffffffffc02b28f8 <idleproc>
ffffffffc020547e:	0ce78c63          	beq	a5,a4,ffffffffc0205556 <do_exit+0xf8>
    if (current == initproc) {
ffffffffc0205482:	000ad497          	auipc	s1,0xad
ffffffffc0205486:	47e48493          	addi	s1,s1,1150 # ffffffffc02b2900 <initproc>
ffffffffc020548a:	6098                	ld	a4,0(s1)
ffffffffc020548c:	0ee78b63          	beq	a5,a4,ffffffffc0205582 <do_exit+0x124>
    struct mm_struct *mm = current->mm;
ffffffffc0205490:	0287b983          	ld	s3,40(a5)
ffffffffc0205494:	892a                	mv	s2,a0
    if (mm != NULL) {
ffffffffc0205496:	02098663          	beqz	s3,ffffffffc02054c2 <do_exit+0x64>
ffffffffc020549a:	000ad797          	auipc	a5,0xad
ffffffffc020549e:	3fe7b783          	ld	a5,1022(a5) # ffffffffc02b2898 <boot_cr3>
ffffffffc02054a2:	577d                	li	a4,-1
ffffffffc02054a4:	177e                	slli	a4,a4,0x3f
ffffffffc02054a6:	83b1                	srli	a5,a5,0xc
ffffffffc02054a8:	8fd9                	or	a5,a5,a4
ffffffffc02054aa:	18079073          	csrw	satp,a5
    mm->mm_count -= 1;
ffffffffc02054ae:	0309a783          	lw	a5,48(s3)
ffffffffc02054b2:	fff7871b          	addiw	a4,a5,-1
ffffffffc02054b6:	02e9a823          	sw	a4,48(s3)
        if (mm_count_dec(mm) == 0) {
ffffffffc02054ba:	cb55                	beqz	a4,ffffffffc020556e <do_exit+0x110>
        current->mm = NULL;
ffffffffc02054bc:	601c                	ld	a5,0(s0)
ffffffffc02054be:	0207b423          	sd	zero,40(a5)
    current->state = PROC_ZOMBIE;
ffffffffc02054c2:	601c                	ld	a5,0(s0)
ffffffffc02054c4:	470d                	li	a4,3
ffffffffc02054c6:	c398                	sw	a4,0(a5)
    current->exit_code = error_code;
ffffffffc02054c8:	0f27a423          	sw	s2,232(a5)
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc02054cc:	100027f3          	csrr	a5,sstatus
ffffffffc02054d0:	8b89                	andi	a5,a5,2
    return 0;
ffffffffc02054d2:	4a01                	li	s4,0
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc02054d4:	e3f9                	bnez	a5,ffffffffc020559a <do_exit+0x13c>
        proc = current->parent;
ffffffffc02054d6:	6018                	ld	a4,0(s0)
        if (proc->wait_state == WT_CHILD) {
ffffffffc02054d8:	800007b7          	lui	a5,0x80000
ffffffffc02054dc:	0785                	addi	a5,a5,1
        proc = current->parent;
ffffffffc02054de:	7308                	ld	a0,32(a4)
        if (proc->wait_state == WT_CHILD) {
ffffffffc02054e0:	0ec52703          	lw	a4,236(a0)
ffffffffc02054e4:	0af70f63          	beq	a4,a5,ffffffffc02055a2 <do_exit+0x144>
        while (current->cptr != NULL) {
ffffffffc02054e8:	6018                	ld	a4,0(s0)
ffffffffc02054ea:	7b7c                	ld	a5,240(a4)
ffffffffc02054ec:	c3a1                	beqz	a5,ffffffffc020552c <do_exit+0xce>
                if (initproc->wait_state == WT_CHILD) {
ffffffffc02054ee:	800009b7          	lui	s3,0x80000
            if (proc->state == PROC_ZOMBIE) {
ffffffffc02054f2:	490d                	li	s2,3
                if (initproc->wait_state == WT_CHILD) {
ffffffffc02054f4:	0985                	addi	s3,s3,1
ffffffffc02054f6:	a021                	j	ffffffffc02054fe <do_exit+0xa0>
        while (current->cptr != NULL) {
ffffffffc02054f8:	6018                	ld	a4,0(s0)
ffffffffc02054fa:	7b7c                	ld	a5,240(a4)
ffffffffc02054fc:	cb85                	beqz	a5,ffffffffc020552c <do_exit+0xce>
            current->cptr = proc->optr;
ffffffffc02054fe:	1007b683          	ld	a3,256(a5) # ffffffff80000100 <_binary_obj___user_exit_out_size+0xffffffff7fff4fd0>
            if ((proc->optr = initproc->cptr) != NULL) {
ffffffffc0205502:	6088                	ld	a0,0(s1)
            current->cptr = proc->optr;
ffffffffc0205504:	fb74                	sd	a3,240(a4)
            if ((proc->optr = initproc->cptr) != NULL) {
ffffffffc0205506:	7978                	ld	a4,240(a0)
            proc->yptr = NULL;
ffffffffc0205508:	0e07bc23          	sd	zero,248(a5)
            if ((proc->optr = initproc->cptr) != NULL) {
ffffffffc020550c:	10e7b023          	sd	a4,256(a5)
ffffffffc0205510:	c311                	beqz	a4,ffffffffc0205514 <do_exit+0xb6>
                initproc->cptr->yptr = proc;
ffffffffc0205512:	ff7c                	sd	a5,248(a4)
            if (proc->state == PROC_ZOMBIE) {
ffffffffc0205514:	4398                	lw	a4,0(a5)
            proc->parent = initproc;
ffffffffc0205516:	f388                	sd	a0,32(a5)
            initproc->cptr = proc;
ffffffffc0205518:	f97c                	sd	a5,240(a0)
            if (proc->state == PROC_ZOMBIE) {
ffffffffc020551a:	fd271fe3          	bne	a4,s2,ffffffffc02054f8 <do_exit+0x9a>
                if (initproc->wait_state == WT_CHILD) {
ffffffffc020551e:	0ec52783          	lw	a5,236(a0)
ffffffffc0205522:	fd379be3          	bne	a5,s3,ffffffffc02054f8 <do_exit+0x9a>
                    wakeup_proc(initproc);
ffffffffc0205526:	373000ef          	jal	ra,ffffffffc0206098 <wakeup_proc>
ffffffffc020552a:	b7f9                	j	ffffffffc02054f8 <do_exit+0x9a>
    if (flag) {
ffffffffc020552c:	020a1263          	bnez	s4,ffffffffc0205550 <do_exit+0xf2>
    schedule();
ffffffffc0205530:	3e9000ef          	jal	ra,ffffffffc0206118 <schedule>
    panic("do_exit will not return!! %d.\n", current->pid);
ffffffffc0205534:	601c                	ld	a5,0(s0)
ffffffffc0205536:	00003617          	auipc	a2,0x3
ffffffffc020553a:	0d260613          	addi	a2,a2,210 # ffffffffc0208608 <default_pmm_manager+0x1188>
ffffffffc020553e:	1ff00593          	li	a1,511
ffffffffc0205542:	43d4                	lw	a3,4(a5)
ffffffffc0205544:	00003517          	auipc	a0,0x3
ffffffffc0205548:	04450513          	addi	a0,a0,68 # ffffffffc0208588 <default_pmm_manager+0x1108>
ffffffffc020554c:	f2ffa0ef          	jal	ra,ffffffffc020047a <__panic>
        intr_enable();
ffffffffc0205550:	8f0fb0ef          	jal	ra,ffffffffc0200640 <intr_enable>
ffffffffc0205554:	bff1                	j	ffffffffc0205530 <do_exit+0xd2>
        panic("idleproc exit.\n");
ffffffffc0205556:	00003617          	auipc	a2,0x3
ffffffffc020555a:	09260613          	addi	a2,a2,146 # ffffffffc02085e8 <default_pmm_manager+0x1168>
ffffffffc020555e:	1d300593          	li	a1,467
ffffffffc0205562:	00003517          	auipc	a0,0x3
ffffffffc0205566:	02650513          	addi	a0,a0,38 # ffffffffc0208588 <default_pmm_manager+0x1108>
ffffffffc020556a:	f11fa0ef          	jal	ra,ffffffffc020047a <__panic>
            exit_mmap(mm);
ffffffffc020556e:	854e                	mv	a0,s3
ffffffffc0205570:	f6bfe0ef          	jal	ra,ffffffffc02044da <exit_mmap>
            put_pgdir(mm);
ffffffffc0205574:	854e                	mv	a0,s3
ffffffffc0205576:	9ebff0ef          	jal	ra,ffffffffc0204f60 <put_pgdir>
            mm_destroy(mm);
ffffffffc020557a:	854e                	mv	a0,s3
ffffffffc020557c:	dc3fe0ef          	jal	ra,ffffffffc020433e <mm_destroy>
ffffffffc0205580:	bf35                	j	ffffffffc02054bc <do_exit+0x5e>
        panic("initproc exit.\n");
ffffffffc0205582:	00003617          	auipc	a2,0x3
ffffffffc0205586:	07660613          	addi	a2,a2,118 # ffffffffc02085f8 <default_pmm_manager+0x1178>
ffffffffc020558a:	1d600593          	li	a1,470
ffffffffc020558e:	00003517          	auipc	a0,0x3
ffffffffc0205592:	ffa50513          	addi	a0,a0,-6 # ffffffffc0208588 <default_pmm_manager+0x1108>
ffffffffc0205596:	ee5fa0ef          	jal	ra,ffffffffc020047a <__panic>
        intr_disable();
ffffffffc020559a:	8acfb0ef          	jal	ra,ffffffffc0200646 <intr_disable>
        return 1;
ffffffffc020559e:	4a05                	li	s4,1
ffffffffc02055a0:	bf1d                	j	ffffffffc02054d6 <do_exit+0x78>
            wakeup_proc(proc);
ffffffffc02055a2:	2f7000ef          	jal	ra,ffffffffc0206098 <wakeup_proc>
ffffffffc02055a6:	b789                	j	ffffffffc02054e8 <do_exit+0x8a>

ffffffffc02055a8 <do_wait.part.0>:
do_wait(int pid, int *code_store) {
ffffffffc02055a8:	715d                	addi	sp,sp,-80
ffffffffc02055aa:	f84a                	sd	s2,48(sp)
ffffffffc02055ac:	f44e                	sd	s3,40(sp)
        current->wait_state = WT_CHILD;
ffffffffc02055ae:	80000937          	lui	s2,0x80000
    if (0 < pid && pid < MAX_PID) {
ffffffffc02055b2:	6989                	lui	s3,0x2
do_wait(int pid, int *code_store) {
ffffffffc02055b4:	fc26                	sd	s1,56(sp)
ffffffffc02055b6:	f052                	sd	s4,32(sp)
ffffffffc02055b8:	ec56                	sd	s5,24(sp)
ffffffffc02055ba:	e85a                	sd	s6,16(sp)
ffffffffc02055bc:	e45e                	sd	s7,8(sp)
ffffffffc02055be:	e486                	sd	ra,72(sp)
ffffffffc02055c0:	e0a2                	sd	s0,64(sp)
ffffffffc02055c2:	84aa                	mv	s1,a0
ffffffffc02055c4:	8a2e                	mv	s4,a1
        proc = current->cptr;
ffffffffc02055c6:	000adb97          	auipc	s7,0xad
ffffffffc02055ca:	32ab8b93          	addi	s7,s7,810 # ffffffffc02b28f0 <current>
    if (0 < pid && pid < MAX_PID) {
ffffffffc02055ce:	00050b1b          	sext.w	s6,a0
ffffffffc02055d2:	fff50a9b          	addiw	s5,a0,-1
ffffffffc02055d6:	19f9                	addi	s3,s3,-2
        current->wait_state = WT_CHILD;
ffffffffc02055d8:	0905                	addi	s2,s2,1
    if (pid != 0) {
ffffffffc02055da:	ccbd                	beqz	s1,ffffffffc0205658 <do_wait.part.0+0xb0>
    if (0 < pid && pid < MAX_PID) {
ffffffffc02055dc:	0359e863          	bltu	s3,s5,ffffffffc020560c <do_wait.part.0+0x64>
        list_entry_t *list = hash_list + pid_hashfn(pid), *le = list;
ffffffffc02055e0:	45a9                	li	a1,10
ffffffffc02055e2:	855a                	mv	a0,s6
ffffffffc02055e4:	4a1000ef          	jal	ra,ffffffffc0206284 <hash32>
ffffffffc02055e8:	02051793          	slli	a5,a0,0x20
ffffffffc02055ec:	01c7d513          	srli	a0,a5,0x1c
ffffffffc02055f0:	000a9797          	auipc	a5,0xa9
ffffffffc02055f4:	27878793          	addi	a5,a5,632 # ffffffffc02ae868 <hash_list>
ffffffffc02055f8:	953e                	add	a0,a0,a5
ffffffffc02055fa:	842a                	mv	s0,a0
        while ((le = list_next(le)) != list) {
ffffffffc02055fc:	a029                	j	ffffffffc0205606 <do_wait.part.0+0x5e>
            if (proc->pid == pid) {
ffffffffc02055fe:	f2c42783          	lw	a5,-212(s0)
ffffffffc0205602:	02978163          	beq	a5,s1,ffffffffc0205624 <do_wait.part.0+0x7c>
ffffffffc0205606:	6400                	ld	s0,8(s0)
        while ((le = list_next(le)) != list) {
ffffffffc0205608:	fe851be3          	bne	a0,s0,ffffffffc02055fe <do_wait.part.0+0x56>
    return -E_BAD_PROC;
ffffffffc020560c:	5579                	li	a0,-2
}
ffffffffc020560e:	60a6                	ld	ra,72(sp)
ffffffffc0205610:	6406                	ld	s0,64(sp)
ffffffffc0205612:	74e2                	ld	s1,56(sp)
ffffffffc0205614:	7942                	ld	s2,48(sp)
ffffffffc0205616:	79a2                	ld	s3,40(sp)
ffffffffc0205618:	7a02                	ld	s4,32(sp)
ffffffffc020561a:	6ae2                	ld	s5,24(sp)
ffffffffc020561c:	6b42                	ld	s6,16(sp)
ffffffffc020561e:	6ba2                	ld	s7,8(sp)
ffffffffc0205620:	6161                	addi	sp,sp,80
ffffffffc0205622:	8082                	ret
        if (proc != NULL && proc->parent == current) {
ffffffffc0205624:	000bb683          	ld	a3,0(s7)
ffffffffc0205628:	f4843783          	ld	a5,-184(s0)
ffffffffc020562c:	fed790e3          	bne	a5,a3,ffffffffc020560c <do_wait.part.0+0x64>
            if (proc->state == PROC_ZOMBIE) {
ffffffffc0205630:	f2842703          	lw	a4,-216(s0)
ffffffffc0205634:	478d                	li	a5,3
ffffffffc0205636:	0ef70b63          	beq	a4,a5,ffffffffc020572c <do_wait.part.0+0x184>
        current->state = PROC_SLEEPING;
ffffffffc020563a:	4785                	li	a5,1
ffffffffc020563c:	c29c                	sw	a5,0(a3)
        current->wait_state = WT_CHILD;
ffffffffc020563e:	0f26a623          	sw	s2,236(a3)
        schedule();
ffffffffc0205642:	2d7000ef          	jal	ra,ffffffffc0206118 <schedule>
        if (current->flags & PF_EXITING) {
ffffffffc0205646:	000bb783          	ld	a5,0(s7)
ffffffffc020564a:	0b07a783          	lw	a5,176(a5)
ffffffffc020564e:	8b85                	andi	a5,a5,1
ffffffffc0205650:	d7c9                	beqz	a5,ffffffffc02055da <do_wait.part.0+0x32>
            do_exit(-E_KILLED);
ffffffffc0205652:	555d                	li	a0,-9
ffffffffc0205654:	e0bff0ef          	jal	ra,ffffffffc020545e <do_exit>
        proc = current->cptr;
ffffffffc0205658:	000bb683          	ld	a3,0(s7)
ffffffffc020565c:	7ae0                	ld	s0,240(a3)
        for (; proc != NULL; proc = proc->optr) {
ffffffffc020565e:	d45d                	beqz	s0,ffffffffc020560c <do_wait.part.0+0x64>
            if (proc->state == PROC_ZOMBIE) {
ffffffffc0205660:	470d                	li	a4,3
ffffffffc0205662:	a021                	j	ffffffffc020566a <do_wait.part.0+0xc2>
        for (; proc != NULL; proc = proc->optr) {
ffffffffc0205664:	10043403          	ld	s0,256(s0)
ffffffffc0205668:	d869                	beqz	s0,ffffffffc020563a <do_wait.part.0+0x92>
            if (proc->state == PROC_ZOMBIE) {
ffffffffc020566a:	401c                	lw	a5,0(s0)
ffffffffc020566c:	fee79ce3          	bne	a5,a4,ffffffffc0205664 <do_wait.part.0+0xbc>
    if (proc == idleproc || proc == initproc) {
ffffffffc0205670:	000ad797          	auipc	a5,0xad
ffffffffc0205674:	2887b783          	ld	a5,648(a5) # ffffffffc02b28f8 <idleproc>
ffffffffc0205678:	0c878963          	beq	a5,s0,ffffffffc020574a <do_wait.part.0+0x1a2>
ffffffffc020567c:	000ad797          	auipc	a5,0xad
ffffffffc0205680:	2847b783          	ld	a5,644(a5) # ffffffffc02b2900 <initproc>
ffffffffc0205684:	0cf40363          	beq	s0,a5,ffffffffc020574a <do_wait.part.0+0x1a2>
    if (code_store != NULL) {
ffffffffc0205688:	000a0663          	beqz	s4,ffffffffc0205694 <do_wait.part.0+0xec>
        *code_store = proc->exit_code;
ffffffffc020568c:	0e842783          	lw	a5,232(s0)
ffffffffc0205690:	00fa2023          	sw	a5,0(s4) # 1000 <_binary_obj___user_faultread_out_size-0x8bb8>
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0205694:	100027f3          	csrr	a5,sstatus
ffffffffc0205698:	8b89                	andi	a5,a5,2
    return 0;
ffffffffc020569a:	4581                	li	a1,0
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc020569c:	e7c1                	bnez	a5,ffffffffc0205724 <do_wait.part.0+0x17c>
    __list_del(listelm->prev, listelm->next);
ffffffffc020569e:	6c70                	ld	a2,216(s0)
ffffffffc02056a0:	7074                	ld	a3,224(s0)
    if (proc->optr != NULL) {
ffffffffc02056a2:	10043703          	ld	a4,256(s0)
        proc->optr->yptr = proc->yptr;
ffffffffc02056a6:	7c7c                	ld	a5,248(s0)
    prev->next = next;
ffffffffc02056a8:	e614                	sd	a3,8(a2)
    next->prev = prev;
ffffffffc02056aa:	e290                	sd	a2,0(a3)
    __list_del(listelm->prev, listelm->next);
ffffffffc02056ac:	6470                	ld	a2,200(s0)
ffffffffc02056ae:	6874                	ld	a3,208(s0)
    prev->next = next;
ffffffffc02056b0:	e614                	sd	a3,8(a2)
    next->prev = prev;
ffffffffc02056b2:	e290                	sd	a2,0(a3)
    if (proc->optr != NULL) {
ffffffffc02056b4:	c319                	beqz	a4,ffffffffc02056ba <do_wait.part.0+0x112>
        proc->optr->yptr = proc->yptr;
ffffffffc02056b6:	ff7c                	sd	a5,248(a4)
    if (proc->yptr != NULL) {
ffffffffc02056b8:	7c7c                	ld	a5,248(s0)
ffffffffc02056ba:	c3b5                	beqz	a5,ffffffffc020571e <do_wait.part.0+0x176>
        proc->yptr->optr = proc->optr;
ffffffffc02056bc:	10e7b023          	sd	a4,256(a5)
    nr_process --;
ffffffffc02056c0:	000ad717          	auipc	a4,0xad
ffffffffc02056c4:	24870713          	addi	a4,a4,584 # ffffffffc02b2908 <nr_process>
ffffffffc02056c8:	431c                	lw	a5,0(a4)
ffffffffc02056ca:	37fd                	addiw	a5,a5,-1
ffffffffc02056cc:	c31c                	sw	a5,0(a4)
    if (flag) {
ffffffffc02056ce:	e5a9                	bnez	a1,ffffffffc0205718 <do_wait.part.0+0x170>
    free_pages(kva2page((void *)(proc->kstack)), KSTACKPAGE);
ffffffffc02056d0:	6814                	ld	a3,16(s0)
ffffffffc02056d2:	c02007b7          	lui	a5,0xc0200
ffffffffc02056d6:	04f6ee63          	bltu	a3,a5,ffffffffc0205732 <do_wait.part.0+0x18a>
ffffffffc02056da:	000ad797          	auipc	a5,0xad
ffffffffc02056de:	1e67b783          	ld	a5,486(a5) # ffffffffc02b28c0 <va_pa_offset>
ffffffffc02056e2:	8e9d                	sub	a3,a3,a5
    if (PPN(pa) >= npage) {
ffffffffc02056e4:	82b1                	srli	a3,a3,0xc
ffffffffc02056e6:	000ad797          	auipc	a5,0xad
ffffffffc02056ea:	1c27b783          	ld	a5,450(a5) # ffffffffc02b28a8 <npage>
ffffffffc02056ee:	06f6fa63          	bgeu	a3,a5,ffffffffc0205762 <do_wait.part.0+0x1ba>
    return &pages[PPN(pa) - nbase];
ffffffffc02056f2:	00003517          	auipc	a0,0x3
ffffffffc02056f6:	74e53503          	ld	a0,1870(a0) # ffffffffc0208e40 <nbase>
ffffffffc02056fa:	8e89                	sub	a3,a3,a0
ffffffffc02056fc:	069a                	slli	a3,a3,0x6
ffffffffc02056fe:	000ad517          	auipc	a0,0xad
ffffffffc0205702:	1b253503          	ld	a0,434(a0) # ffffffffc02b28b0 <pages>
ffffffffc0205706:	9536                	add	a0,a0,a3
ffffffffc0205708:	4589                	li	a1,2
ffffffffc020570a:	e68fc0ef          	jal	ra,ffffffffc0201d72 <free_pages>
    kfree(proc);
ffffffffc020570e:	8522                	mv	a0,s0
ffffffffc0205710:	ca2fc0ef          	jal	ra,ffffffffc0201bb2 <kfree>
    return 0;
ffffffffc0205714:	4501                	li	a0,0
ffffffffc0205716:	bde5                	j	ffffffffc020560e <do_wait.part.0+0x66>
        intr_enable();
ffffffffc0205718:	f29fa0ef          	jal	ra,ffffffffc0200640 <intr_enable>
ffffffffc020571c:	bf55                	j	ffffffffc02056d0 <do_wait.part.0+0x128>
       proc->parent->cptr = proc->optr;
ffffffffc020571e:	701c                	ld	a5,32(s0)
ffffffffc0205720:	fbf8                	sd	a4,240(a5)
ffffffffc0205722:	bf79                	j	ffffffffc02056c0 <do_wait.part.0+0x118>
        intr_disable();
ffffffffc0205724:	f23fa0ef          	jal	ra,ffffffffc0200646 <intr_disable>
        return 1;
ffffffffc0205728:	4585                	li	a1,1
ffffffffc020572a:	bf95                	j	ffffffffc020569e <do_wait.part.0+0xf6>
            struct proc_struct *proc = le2proc(le, hash_link);
ffffffffc020572c:	f2840413          	addi	s0,s0,-216
ffffffffc0205730:	b781                	j	ffffffffc0205670 <do_wait.part.0+0xc8>
    return pa2page(PADDR(kva));
ffffffffc0205732:	00002617          	auipc	a2,0x2
ffffffffc0205736:	e2e60613          	addi	a2,a2,-466 # ffffffffc0207560 <default_pmm_manager+0xe0>
ffffffffc020573a:	06e00593          	li	a1,110
ffffffffc020573e:	00002517          	auipc	a0,0x2
ffffffffc0205742:	da250513          	addi	a0,a0,-606 # ffffffffc02074e0 <default_pmm_manager+0x60>
ffffffffc0205746:	d35fa0ef          	jal	ra,ffffffffc020047a <__panic>
        panic("wait idleproc or initproc.\n");
ffffffffc020574a:	00003617          	auipc	a2,0x3
ffffffffc020574e:	ede60613          	addi	a2,a2,-290 # ffffffffc0208628 <default_pmm_manager+0x11a8>
ffffffffc0205752:	2f600593          	li	a1,758
ffffffffc0205756:	00003517          	auipc	a0,0x3
ffffffffc020575a:	e3250513          	addi	a0,a0,-462 # ffffffffc0208588 <default_pmm_manager+0x1108>
ffffffffc020575e:	d1dfa0ef          	jal	ra,ffffffffc020047a <__panic>
        panic("pa2page called with invalid pa");
ffffffffc0205762:	00002617          	auipc	a2,0x2
ffffffffc0205766:	e2660613          	addi	a2,a2,-474 # ffffffffc0207588 <default_pmm_manager+0x108>
ffffffffc020576a:	06200593          	li	a1,98
ffffffffc020576e:	00002517          	auipc	a0,0x2
ffffffffc0205772:	d7250513          	addi	a0,a0,-654 # ffffffffc02074e0 <default_pmm_manager+0x60>
ffffffffc0205776:	d05fa0ef          	jal	ra,ffffffffc020047a <__panic>

ffffffffc020577a <init_main>:
}

// init_main - the second kernel thread used to create user_main kernel threads
static int
init_main(void *arg) {
ffffffffc020577a:	1141                	addi	sp,sp,-16
ffffffffc020577c:	e406                	sd	ra,8(sp)
    size_t nr_free_pages_store = nr_free_pages();
ffffffffc020577e:	e34fc0ef          	jal	ra,ffffffffc0201db2 <nr_free_pages>
    size_t kernel_allocated_store = kallocated();
ffffffffc0205782:	b7cfc0ef          	jal	ra,ffffffffc0201afe <kallocated>

    int pid = kernel_thread(user_main, NULL, 0);
ffffffffc0205786:	4601                	li	a2,0
ffffffffc0205788:	4581                	li	a1,0
ffffffffc020578a:	fffff517          	auipc	a0,0xfffff
ffffffffc020578e:	75850513          	addi	a0,a0,1880 # ffffffffc0204ee2 <user_main>
ffffffffc0205792:	c7dff0ef          	jal	ra,ffffffffc020540e <kernel_thread>
    if (pid <= 0) {
ffffffffc0205796:	00a04563          	bgtz	a0,ffffffffc02057a0 <init_main+0x26>
ffffffffc020579a:	a071                	j	ffffffffc0205826 <init_main+0xac>
        panic("create user_main failed.\n");
    }

    while (do_wait(0, NULL) == 0) {
        schedule();
ffffffffc020579c:	17d000ef          	jal	ra,ffffffffc0206118 <schedule>
    if (code_store != NULL) {
ffffffffc02057a0:	4581                	li	a1,0
ffffffffc02057a2:	4501                	li	a0,0
ffffffffc02057a4:	e05ff0ef          	jal	ra,ffffffffc02055a8 <do_wait.part.0>
    while (do_wait(0, NULL) == 0) {
ffffffffc02057a8:	d975                	beqz	a0,ffffffffc020579c <init_main+0x22>
    }

    cprintf("all user-mode processes have quit.\n");
ffffffffc02057aa:	00003517          	auipc	a0,0x3
ffffffffc02057ae:	ebe50513          	addi	a0,a0,-322 # ffffffffc0208668 <default_pmm_manager+0x11e8>
ffffffffc02057b2:	9cffa0ef          	jal	ra,ffffffffc0200180 <cprintf>
    assert(initproc->cptr == NULL && initproc->yptr == NULL && initproc->optr == NULL);
ffffffffc02057b6:	000ad797          	auipc	a5,0xad
ffffffffc02057ba:	14a7b783          	ld	a5,330(a5) # ffffffffc02b2900 <initproc>
ffffffffc02057be:	7bf8                	ld	a4,240(a5)
ffffffffc02057c0:	e339                	bnez	a4,ffffffffc0205806 <init_main+0x8c>
ffffffffc02057c2:	7ff8                	ld	a4,248(a5)
ffffffffc02057c4:	e329                	bnez	a4,ffffffffc0205806 <init_main+0x8c>
ffffffffc02057c6:	1007b703          	ld	a4,256(a5)
ffffffffc02057ca:	ef15                	bnez	a4,ffffffffc0205806 <init_main+0x8c>
    assert(nr_process == 2);
ffffffffc02057cc:	000ad697          	auipc	a3,0xad
ffffffffc02057d0:	13c6a683          	lw	a3,316(a3) # ffffffffc02b2908 <nr_process>
ffffffffc02057d4:	4709                	li	a4,2
ffffffffc02057d6:	0ae69463          	bne	a3,a4,ffffffffc020587e <init_main+0x104>
    return listelm->next;
ffffffffc02057da:	000ad697          	auipc	a3,0xad
ffffffffc02057de:	08e68693          	addi	a3,a3,142 # ffffffffc02b2868 <proc_list>
    assert(list_next(&proc_list) == &(initproc->list_link));
ffffffffc02057e2:	6698                	ld	a4,8(a3)
ffffffffc02057e4:	0c878793          	addi	a5,a5,200
ffffffffc02057e8:	06f71b63          	bne	a4,a5,ffffffffc020585e <init_main+0xe4>
    assert(list_prev(&proc_list) == &(initproc->list_link));
ffffffffc02057ec:	629c                	ld	a5,0(a3)
ffffffffc02057ee:	04f71863          	bne	a4,a5,ffffffffc020583e <init_main+0xc4>

    cprintf("init check memory pass.\n");
ffffffffc02057f2:	00003517          	auipc	a0,0x3
ffffffffc02057f6:	f5e50513          	addi	a0,a0,-162 # ffffffffc0208750 <default_pmm_manager+0x12d0>
ffffffffc02057fa:	987fa0ef          	jal	ra,ffffffffc0200180 <cprintf>
    return 0;
}
ffffffffc02057fe:	60a2                	ld	ra,8(sp)
ffffffffc0205800:	4501                	li	a0,0
ffffffffc0205802:	0141                	addi	sp,sp,16
ffffffffc0205804:	8082                	ret
    assert(initproc->cptr == NULL && initproc->yptr == NULL && initproc->optr == NULL);
ffffffffc0205806:	00003697          	auipc	a3,0x3
ffffffffc020580a:	e8a68693          	addi	a3,a3,-374 # ffffffffc0208690 <default_pmm_manager+0x1210>
ffffffffc020580e:	00001617          	auipc	a2,0x1
ffffffffc0205812:	5da60613          	addi	a2,a2,1498 # ffffffffc0206de8 <commands+0x450>
ffffffffc0205816:	35b00593          	li	a1,859
ffffffffc020581a:	00003517          	auipc	a0,0x3
ffffffffc020581e:	d6e50513          	addi	a0,a0,-658 # ffffffffc0208588 <default_pmm_manager+0x1108>
ffffffffc0205822:	c59fa0ef          	jal	ra,ffffffffc020047a <__panic>
        panic("create user_main failed.\n");
ffffffffc0205826:	00003617          	auipc	a2,0x3
ffffffffc020582a:	e2260613          	addi	a2,a2,-478 # ffffffffc0208648 <default_pmm_manager+0x11c8>
ffffffffc020582e:	35300593          	li	a1,851
ffffffffc0205832:	00003517          	auipc	a0,0x3
ffffffffc0205836:	d5650513          	addi	a0,a0,-682 # ffffffffc0208588 <default_pmm_manager+0x1108>
ffffffffc020583a:	c41fa0ef          	jal	ra,ffffffffc020047a <__panic>
    assert(list_prev(&proc_list) == &(initproc->list_link));
ffffffffc020583e:	00003697          	auipc	a3,0x3
ffffffffc0205842:	ee268693          	addi	a3,a3,-286 # ffffffffc0208720 <default_pmm_manager+0x12a0>
ffffffffc0205846:	00001617          	auipc	a2,0x1
ffffffffc020584a:	5a260613          	addi	a2,a2,1442 # ffffffffc0206de8 <commands+0x450>
ffffffffc020584e:	35e00593          	li	a1,862
ffffffffc0205852:	00003517          	auipc	a0,0x3
ffffffffc0205856:	d3650513          	addi	a0,a0,-714 # ffffffffc0208588 <default_pmm_manager+0x1108>
ffffffffc020585a:	c21fa0ef          	jal	ra,ffffffffc020047a <__panic>
    assert(list_next(&proc_list) == &(initproc->list_link));
ffffffffc020585e:	00003697          	auipc	a3,0x3
ffffffffc0205862:	e9268693          	addi	a3,a3,-366 # ffffffffc02086f0 <default_pmm_manager+0x1270>
ffffffffc0205866:	00001617          	auipc	a2,0x1
ffffffffc020586a:	58260613          	addi	a2,a2,1410 # ffffffffc0206de8 <commands+0x450>
ffffffffc020586e:	35d00593          	li	a1,861
ffffffffc0205872:	00003517          	auipc	a0,0x3
ffffffffc0205876:	d1650513          	addi	a0,a0,-746 # ffffffffc0208588 <default_pmm_manager+0x1108>
ffffffffc020587a:	c01fa0ef          	jal	ra,ffffffffc020047a <__panic>
    assert(nr_process == 2);
ffffffffc020587e:	00003697          	auipc	a3,0x3
ffffffffc0205882:	e6268693          	addi	a3,a3,-414 # ffffffffc02086e0 <default_pmm_manager+0x1260>
ffffffffc0205886:	00001617          	auipc	a2,0x1
ffffffffc020588a:	56260613          	addi	a2,a2,1378 # ffffffffc0206de8 <commands+0x450>
ffffffffc020588e:	35c00593          	li	a1,860
ffffffffc0205892:	00003517          	auipc	a0,0x3
ffffffffc0205896:	cf650513          	addi	a0,a0,-778 # ffffffffc0208588 <default_pmm_manager+0x1108>
ffffffffc020589a:	be1fa0ef          	jal	ra,ffffffffc020047a <__panic>

ffffffffc020589e <do_execve>:
do_execve(const char *name, size_t len, unsigned char *binary, size_t size) {
ffffffffc020589e:	7171                	addi	sp,sp,-176
ffffffffc02058a0:	e4ee                	sd	s11,72(sp)
    struct mm_struct *mm = current->mm;
ffffffffc02058a2:	000add97          	auipc	s11,0xad
ffffffffc02058a6:	04ed8d93          	addi	s11,s11,78 # ffffffffc02b28f0 <current>
ffffffffc02058aa:	000db783          	ld	a5,0(s11)
do_execve(const char *name, size_t len, unsigned char *binary, size_t size) {
ffffffffc02058ae:	e54e                	sd	s3,136(sp)
ffffffffc02058b0:	ed26                	sd	s1,152(sp)
    struct mm_struct *mm = current->mm;
ffffffffc02058b2:	0287b983          	ld	s3,40(a5)
do_execve(const char *name, size_t len, unsigned char *binary, size_t size) {
ffffffffc02058b6:	e94a                	sd	s2,144(sp)
ffffffffc02058b8:	f4de                	sd	s7,104(sp)
ffffffffc02058ba:	892a                	mv	s2,a0
ffffffffc02058bc:	8bb2                	mv	s7,a2
ffffffffc02058be:	84ae                	mv	s1,a1
    if (!user_mem_check(mm, (uintptr_t)name, len, 0)) {
ffffffffc02058c0:	862e                	mv	a2,a1
ffffffffc02058c2:	4681                	li	a3,0
ffffffffc02058c4:	85aa                	mv	a1,a0
ffffffffc02058c6:	854e                	mv	a0,s3
do_execve(const char *name, size_t len, unsigned char *binary, size_t size) {
ffffffffc02058c8:	f506                	sd	ra,168(sp)
ffffffffc02058ca:	f122                	sd	s0,160(sp)
ffffffffc02058cc:	e152                	sd	s4,128(sp)
ffffffffc02058ce:	fcd6                	sd	s5,120(sp)
ffffffffc02058d0:	f8da                	sd	s6,112(sp)
ffffffffc02058d2:	f0e2                	sd	s8,96(sp)
ffffffffc02058d4:	ece6                	sd	s9,88(sp)
ffffffffc02058d6:	e8ea                	sd	s10,80(sp)
ffffffffc02058d8:	f05e                	sd	s7,32(sp)
    if (!user_mem_check(mm, (uintptr_t)name, len, 0)) {
ffffffffc02058da:	b98ff0ef          	jal	ra,ffffffffc0204c72 <user_mem_check>
ffffffffc02058de:	40050a63          	beqz	a0,ffffffffc0205cf2 <do_execve+0x454>
    memset(local_name, 0, sizeof(local_name));
ffffffffc02058e2:	4641                	li	a2,16
ffffffffc02058e4:	4581                	li	a1,0
ffffffffc02058e6:	1808                	addi	a0,sp,48
ffffffffc02058e8:	61d000ef          	jal	ra,ffffffffc0206704 <memset>
    memcpy(local_name, name, len);
ffffffffc02058ec:	47bd                	li	a5,15
ffffffffc02058ee:	8626                	mv	a2,s1
ffffffffc02058f0:	1e97e263          	bltu	a5,s1,ffffffffc0205ad4 <do_execve+0x236>
ffffffffc02058f4:	85ca                	mv	a1,s2
ffffffffc02058f6:	1808                	addi	a0,sp,48
ffffffffc02058f8:	61f000ef          	jal	ra,ffffffffc0206716 <memcpy>
    if (mm != NULL) {
ffffffffc02058fc:	1e098363          	beqz	s3,ffffffffc0205ae2 <do_execve+0x244>
        cputs("mm != NULL");
ffffffffc0205900:	00002517          	auipc	a0,0x2
ffffffffc0205904:	32050513          	addi	a0,a0,800 # ffffffffc0207c20 <default_pmm_manager+0x7a0>
ffffffffc0205908:	8b1fa0ef          	jal	ra,ffffffffc02001b8 <cputs>
ffffffffc020590c:	000ad797          	auipc	a5,0xad
ffffffffc0205910:	f8c7b783          	ld	a5,-116(a5) # ffffffffc02b2898 <boot_cr3>
ffffffffc0205914:	577d                	li	a4,-1
ffffffffc0205916:	177e                	slli	a4,a4,0x3f
ffffffffc0205918:	83b1                	srli	a5,a5,0xc
ffffffffc020591a:	8fd9                	or	a5,a5,a4
ffffffffc020591c:	18079073          	csrw	satp,a5
ffffffffc0205920:	0309a783          	lw	a5,48(s3) # 2030 <_binary_obj___user_faultread_out_size-0x7b88>
ffffffffc0205924:	fff7871b          	addiw	a4,a5,-1
ffffffffc0205928:	02e9a823          	sw	a4,48(s3)
        if (mm_count_dec(mm) == 0) {
ffffffffc020592c:	2c070463          	beqz	a4,ffffffffc0205bf4 <do_execve+0x356>
        current->mm = NULL;
ffffffffc0205930:	000db783          	ld	a5,0(s11)
ffffffffc0205934:	0207b423          	sd	zero,40(a5)
    if ((mm = mm_create()) == NULL) {
ffffffffc0205938:	881fe0ef          	jal	ra,ffffffffc02041b8 <mm_create>
ffffffffc020593c:	84aa                	mv	s1,a0
ffffffffc020593e:	1c050d63          	beqz	a0,ffffffffc0205b18 <do_execve+0x27a>
    if ((page = alloc_page()) == NULL) {
ffffffffc0205942:	4505                	li	a0,1
ffffffffc0205944:	b9cfc0ef          	jal	ra,ffffffffc0201ce0 <alloc_pages>
ffffffffc0205948:	3a050963          	beqz	a0,ffffffffc0205cfa <do_execve+0x45c>
    return page - pages + nbase;
ffffffffc020594c:	000adc97          	auipc	s9,0xad
ffffffffc0205950:	f64c8c93          	addi	s9,s9,-156 # ffffffffc02b28b0 <pages>
ffffffffc0205954:	000cb683          	ld	a3,0(s9)
    return KADDR(page2pa(page));
ffffffffc0205958:	000adc17          	auipc	s8,0xad
ffffffffc020595c:	f50c0c13          	addi	s8,s8,-176 # ffffffffc02b28a8 <npage>
    return page - pages + nbase;
ffffffffc0205960:	00003717          	auipc	a4,0x3
ffffffffc0205964:	4e073703          	ld	a4,1248(a4) # ffffffffc0208e40 <nbase>
ffffffffc0205968:	40d506b3          	sub	a3,a0,a3
ffffffffc020596c:	8699                	srai	a3,a3,0x6
    return KADDR(page2pa(page));
ffffffffc020596e:	5afd                	li	s5,-1
ffffffffc0205970:	000c3783          	ld	a5,0(s8)
    return page - pages + nbase;
ffffffffc0205974:	96ba                	add	a3,a3,a4
ffffffffc0205976:	e83a                	sd	a4,16(sp)
    return KADDR(page2pa(page));
ffffffffc0205978:	00cad713          	srli	a4,s5,0xc
ffffffffc020597c:	ec3a                	sd	a4,24(sp)
ffffffffc020597e:	8f75                	and	a4,a4,a3
    return page2ppn(page) << PGSHIFT;
ffffffffc0205980:	06b2                	slli	a3,a3,0xc
    return KADDR(page2pa(page));
ffffffffc0205982:	38f77063          	bgeu	a4,a5,ffffffffc0205d02 <do_execve+0x464>
ffffffffc0205986:	000adb17          	auipc	s6,0xad
ffffffffc020598a:	f3ab0b13          	addi	s6,s6,-198 # ffffffffc02b28c0 <va_pa_offset>
ffffffffc020598e:	000b3903          	ld	s2,0(s6)
    memcpy(pgdir, boot_pgdir, PGSIZE);
ffffffffc0205992:	6605                	lui	a2,0x1
ffffffffc0205994:	000ad597          	auipc	a1,0xad
ffffffffc0205998:	f0c5b583          	ld	a1,-244(a1) # ffffffffc02b28a0 <boot_pgdir>
ffffffffc020599c:	9936                	add	s2,s2,a3
ffffffffc020599e:	854a                	mv	a0,s2
ffffffffc02059a0:	577000ef          	jal	ra,ffffffffc0206716 <memcpy>
    if (elf->e_magic != ELF_MAGIC) {
ffffffffc02059a4:	7782                	ld	a5,32(sp)
ffffffffc02059a6:	4398                	lw	a4,0(a5)
ffffffffc02059a8:	464c47b7          	lui	a5,0x464c4
    mm->pgdir = pgdir;
ffffffffc02059ac:	0124bc23          	sd	s2,24(s1)
    if (elf->e_magic != ELF_MAGIC) {
ffffffffc02059b0:	57f78793          	addi	a5,a5,1407 # 464c457f <_binary_obj___user_exit_out_size+0x464b944f>
ffffffffc02059b4:	14f71863          	bne	a4,a5,ffffffffc0205b04 <do_execve+0x266>
    struct proghdr *ph_end = ph + elf->e_phnum;
ffffffffc02059b8:	7682                	ld	a3,32(sp)
ffffffffc02059ba:	0386d703          	lhu	a4,56(a3)
    struct proghdr *ph = (struct proghdr *)(binary + elf->e_phoff);
ffffffffc02059be:	0206b983          	ld	s3,32(a3)
    struct proghdr *ph_end = ph + elf->e_phnum;
ffffffffc02059c2:	00371793          	slli	a5,a4,0x3
ffffffffc02059c6:	8f99                	sub	a5,a5,a4
    struct proghdr *ph = (struct proghdr *)(binary + elf->e_phoff);
ffffffffc02059c8:	99b6                	add	s3,s3,a3
    struct proghdr *ph_end = ph + elf->e_phnum;
ffffffffc02059ca:	078e                	slli	a5,a5,0x3
ffffffffc02059cc:	97ce                	add	a5,a5,s3
ffffffffc02059ce:	f43e                	sd	a5,40(sp)
    for (; ph < ph_end; ph ++) {
ffffffffc02059d0:	00f9fc63          	bgeu	s3,a5,ffffffffc02059e8 <do_execve+0x14a>
        if (ph->p_type != ELF_PT_LOAD) {
ffffffffc02059d4:	0009a783          	lw	a5,0(s3)
ffffffffc02059d8:	4705                	li	a4,1
ffffffffc02059da:	14e78163          	beq	a5,a4,ffffffffc0205b1c <do_execve+0x27e>
    for (; ph < ph_end; ph ++) {
ffffffffc02059de:	77a2                	ld	a5,40(sp)
ffffffffc02059e0:	03898993          	addi	s3,s3,56
ffffffffc02059e4:	fef9e8e3          	bltu	s3,a5,ffffffffc02059d4 <do_execve+0x136>
    if ((ret = mm_map(mm, USTACKTOP - USTACKSIZE, USTACKSIZE, vm_flags, NULL)) != 0) {
ffffffffc02059e8:	4701                	li	a4,0
ffffffffc02059ea:	46ad                	li	a3,11
ffffffffc02059ec:	00100637          	lui	a2,0x100
ffffffffc02059f0:	7ff005b7          	lui	a1,0x7ff00
ffffffffc02059f4:	8526                	mv	a0,s1
ffffffffc02059f6:	99bfe0ef          	jal	ra,ffffffffc0204390 <mm_map>
ffffffffc02059fa:	8a2a                	mv	s4,a0
ffffffffc02059fc:	1e051263          	bnez	a0,ffffffffc0205be0 <do_execve+0x342>
    assert(pgdir_alloc_page(mm->pgdir, USTACKTOP-PGSIZE , PTE_USER) != NULL);
ffffffffc0205a00:	6c88                	ld	a0,24(s1)
ffffffffc0205a02:	467d                	li	a2,31
ffffffffc0205a04:	7ffff5b7          	lui	a1,0x7ffff
ffffffffc0205a08:	9b1fd0ef          	jal	ra,ffffffffc02033b8 <pgdir_alloc_page>
ffffffffc0205a0c:	38050363          	beqz	a0,ffffffffc0205d92 <do_execve+0x4f4>
    assert(pgdir_alloc_page(mm->pgdir, USTACKTOP-2*PGSIZE , PTE_USER) != NULL);
ffffffffc0205a10:	6c88                	ld	a0,24(s1)
ffffffffc0205a12:	467d                	li	a2,31
ffffffffc0205a14:	7fffe5b7          	lui	a1,0x7fffe
ffffffffc0205a18:	9a1fd0ef          	jal	ra,ffffffffc02033b8 <pgdir_alloc_page>
ffffffffc0205a1c:	34050b63          	beqz	a0,ffffffffc0205d72 <do_execve+0x4d4>
    assert(pgdir_alloc_page(mm->pgdir, USTACKTOP-3*PGSIZE , PTE_USER) != NULL);
ffffffffc0205a20:	6c88                	ld	a0,24(s1)
ffffffffc0205a22:	467d                	li	a2,31
ffffffffc0205a24:	7fffd5b7          	lui	a1,0x7fffd
ffffffffc0205a28:	991fd0ef          	jal	ra,ffffffffc02033b8 <pgdir_alloc_page>
ffffffffc0205a2c:	32050363          	beqz	a0,ffffffffc0205d52 <do_execve+0x4b4>
    assert(pgdir_alloc_page(mm->pgdir, USTACKTOP-4*PGSIZE , PTE_USER) != NULL);
ffffffffc0205a30:	6c88                	ld	a0,24(s1)
ffffffffc0205a32:	467d                	li	a2,31
ffffffffc0205a34:	7fffc5b7          	lui	a1,0x7fffc
ffffffffc0205a38:	981fd0ef          	jal	ra,ffffffffc02033b8 <pgdir_alloc_page>
ffffffffc0205a3c:	2e050b63          	beqz	a0,ffffffffc0205d32 <do_execve+0x494>
    mm->mm_count += 1;
ffffffffc0205a40:	589c                	lw	a5,48(s1)
    current->mm = mm;
ffffffffc0205a42:	000db603          	ld	a2,0(s11)
    current->cr3 = PADDR(mm->pgdir);
ffffffffc0205a46:	6c94                	ld	a3,24(s1)
ffffffffc0205a48:	2785                	addiw	a5,a5,1
ffffffffc0205a4a:	d89c                	sw	a5,48(s1)
    current->mm = mm;
ffffffffc0205a4c:	f604                	sd	s1,40(a2)
    current->cr3 = PADDR(mm->pgdir);
ffffffffc0205a4e:	c02007b7          	lui	a5,0xc0200
ffffffffc0205a52:	2cf6e463          	bltu	a3,a5,ffffffffc0205d1a <do_execve+0x47c>
ffffffffc0205a56:	000b3783          	ld	a5,0(s6)
ffffffffc0205a5a:	577d                	li	a4,-1
ffffffffc0205a5c:	177e                	slli	a4,a4,0x3f
ffffffffc0205a5e:	8e9d                	sub	a3,a3,a5
ffffffffc0205a60:	00c6d793          	srli	a5,a3,0xc
ffffffffc0205a64:	f654                	sd	a3,168(a2)
ffffffffc0205a66:	8fd9                	or	a5,a5,a4
ffffffffc0205a68:	18079073          	csrw	satp,a5
    struct trapframe *tf = current->tf;
ffffffffc0205a6c:	7240                	ld	s0,160(a2)
    memset(tf, 0, sizeof(struct trapframe));
ffffffffc0205a6e:	4581                	li	a1,0
ffffffffc0205a70:	12000613          	li	a2,288
ffffffffc0205a74:	8522                	mv	a0,s0
    uintptr_t sstatus = tf->status;
ffffffffc0205a76:	10043483          	ld	s1,256(s0)
    memset(tf, 0, sizeof(struct trapframe));
ffffffffc0205a7a:	48b000ef          	jal	ra,ffffffffc0206704 <memset>
    tf->epc = elf->e_entry;
ffffffffc0205a7e:	7782                	ld	a5,32(sp)
    memset(proc->name, 0, sizeof(proc->name));
ffffffffc0205a80:	000db903          	ld	s2,0(s11)
    tf->status = (sstatus & ~SSTATUS_SPP) | SSTATUS_SPIE;
ffffffffc0205a84:	edf4f493          	andi	s1,s1,-289
    tf->epc = elf->e_entry;
ffffffffc0205a88:	6f98                	ld	a4,24(a5)
    tf->gpr.sp = USTACKTOP;
ffffffffc0205a8a:	4785                	li	a5,1
    memset(proc->name, 0, sizeof(proc->name));
ffffffffc0205a8c:	0b490913          	addi	s2,s2,180 # ffffffff800000b4 <_binary_obj___user_exit_out_size+0xffffffff7fff4f84>
    tf->gpr.sp = USTACKTOP;
ffffffffc0205a90:	07fe                	slli	a5,a5,0x1f
    tf->status = (sstatus & ~SSTATUS_SPP) | SSTATUS_SPIE;
ffffffffc0205a92:	0204e493          	ori	s1,s1,32
    memset(proc->name, 0, sizeof(proc->name));
ffffffffc0205a96:	4641                	li	a2,16
ffffffffc0205a98:	4581                	li	a1,0
    tf->gpr.sp = USTACKTOP;
ffffffffc0205a9a:	e81c                	sd	a5,16(s0)
    tf->epc = elf->e_entry;
ffffffffc0205a9c:	10e43423          	sd	a4,264(s0)
    tf->status = (sstatus & ~SSTATUS_SPP) | SSTATUS_SPIE;
ffffffffc0205aa0:	10943023          	sd	s1,256(s0)
    memset(proc->name, 0, sizeof(proc->name));
ffffffffc0205aa4:	854a                	mv	a0,s2
ffffffffc0205aa6:	45f000ef          	jal	ra,ffffffffc0206704 <memset>
    return memcpy(proc->name, name, PROC_NAME_LEN);
ffffffffc0205aaa:	463d                	li	a2,15
ffffffffc0205aac:	180c                	addi	a1,sp,48
ffffffffc0205aae:	854a                	mv	a0,s2
ffffffffc0205ab0:	467000ef          	jal	ra,ffffffffc0206716 <memcpy>
}
ffffffffc0205ab4:	70aa                	ld	ra,168(sp)
ffffffffc0205ab6:	740a                	ld	s0,160(sp)
ffffffffc0205ab8:	64ea                	ld	s1,152(sp)
ffffffffc0205aba:	694a                	ld	s2,144(sp)
ffffffffc0205abc:	69aa                	ld	s3,136(sp)
ffffffffc0205abe:	7ae6                	ld	s5,120(sp)
ffffffffc0205ac0:	7b46                	ld	s6,112(sp)
ffffffffc0205ac2:	7ba6                	ld	s7,104(sp)
ffffffffc0205ac4:	7c06                	ld	s8,96(sp)
ffffffffc0205ac6:	6ce6                	ld	s9,88(sp)
ffffffffc0205ac8:	6d46                	ld	s10,80(sp)
ffffffffc0205aca:	6da6                	ld	s11,72(sp)
ffffffffc0205acc:	8552                	mv	a0,s4
ffffffffc0205ace:	6a0a                	ld	s4,128(sp)
ffffffffc0205ad0:	614d                	addi	sp,sp,176
ffffffffc0205ad2:	8082                	ret
    memcpy(local_name, name, len);
ffffffffc0205ad4:	463d                	li	a2,15
ffffffffc0205ad6:	85ca                	mv	a1,s2
ffffffffc0205ad8:	1808                	addi	a0,sp,48
ffffffffc0205ada:	43d000ef          	jal	ra,ffffffffc0206716 <memcpy>
    if (mm != NULL) {
ffffffffc0205ade:	e20991e3          	bnez	s3,ffffffffc0205900 <do_execve+0x62>
    if (current->mm != NULL) {
ffffffffc0205ae2:	000db783          	ld	a5,0(s11)
ffffffffc0205ae6:	779c                	ld	a5,40(a5)
ffffffffc0205ae8:	e40788e3          	beqz	a5,ffffffffc0205938 <do_execve+0x9a>
        panic("load_icode: current->mm must be empty.\n");
ffffffffc0205aec:	00003617          	auipc	a2,0x3
ffffffffc0205af0:	c8460613          	addi	a2,a2,-892 # ffffffffc0208770 <default_pmm_manager+0x12f0>
ffffffffc0205af4:	20900593          	li	a1,521
ffffffffc0205af8:	00003517          	auipc	a0,0x3
ffffffffc0205afc:	a9050513          	addi	a0,a0,-1392 # ffffffffc0208588 <default_pmm_manager+0x1108>
ffffffffc0205b00:	97bfa0ef          	jal	ra,ffffffffc020047a <__panic>
    put_pgdir(mm);
ffffffffc0205b04:	8526                	mv	a0,s1
ffffffffc0205b06:	c5aff0ef          	jal	ra,ffffffffc0204f60 <put_pgdir>
    mm_destroy(mm);
ffffffffc0205b0a:	8526                	mv	a0,s1
ffffffffc0205b0c:	833fe0ef          	jal	ra,ffffffffc020433e <mm_destroy>
        ret = -E_INVAL_ELF;
ffffffffc0205b10:	5a61                	li	s4,-8
    do_exit(ret);
ffffffffc0205b12:	8552                	mv	a0,s4
ffffffffc0205b14:	94bff0ef          	jal	ra,ffffffffc020545e <do_exit>
    int ret = -E_NO_MEM;
ffffffffc0205b18:	5a71                	li	s4,-4
ffffffffc0205b1a:	bfe5                	j	ffffffffc0205b12 <do_execve+0x274>
        if (ph->p_filesz > ph->p_memsz) {
ffffffffc0205b1c:	0289b603          	ld	a2,40(s3)
ffffffffc0205b20:	0209b783          	ld	a5,32(s3)
ffffffffc0205b24:	1cf66d63          	bltu	a2,a5,ffffffffc0205cfe <do_execve+0x460>
        if (ph->p_flags & ELF_PF_X) vm_flags |= VM_EXEC;
ffffffffc0205b28:	0049a783          	lw	a5,4(s3)
ffffffffc0205b2c:	0017f693          	andi	a3,a5,1
ffffffffc0205b30:	c291                	beqz	a3,ffffffffc0205b34 <do_execve+0x296>
ffffffffc0205b32:	4691                	li	a3,4
        if (ph->p_flags & ELF_PF_W) vm_flags |= VM_WRITE;
ffffffffc0205b34:	0027f713          	andi	a4,a5,2
        if (ph->p_flags & ELF_PF_R) vm_flags |= VM_READ;
ffffffffc0205b38:	8b91                	andi	a5,a5,4
        if (ph->p_flags & ELF_PF_W) vm_flags |= VM_WRITE;
ffffffffc0205b3a:	e779                	bnez	a4,ffffffffc0205c08 <do_execve+0x36a>
        vm_flags = 0, perm = PTE_U | PTE_V;
ffffffffc0205b3c:	4d45                	li	s10,17
        if (ph->p_flags & ELF_PF_R) vm_flags |= VM_READ;
ffffffffc0205b3e:	c781                	beqz	a5,ffffffffc0205b46 <do_execve+0x2a8>
ffffffffc0205b40:	0016e693          	ori	a3,a3,1
        if (vm_flags & VM_READ) perm |= PTE_R;
ffffffffc0205b44:	4d4d                	li	s10,19
        if (vm_flags & VM_WRITE) perm |= (PTE_W | PTE_R);
ffffffffc0205b46:	0026f793          	andi	a5,a3,2
ffffffffc0205b4a:	e3f1                	bnez	a5,ffffffffc0205c0e <do_execve+0x370>
        if (vm_flags & VM_EXEC) perm |= PTE_X;
ffffffffc0205b4c:	0046f793          	andi	a5,a3,4
ffffffffc0205b50:	c399                	beqz	a5,ffffffffc0205b56 <do_execve+0x2b8>
ffffffffc0205b52:	008d6d13          	ori	s10,s10,8
        if ((ret = mm_map(mm, ph->p_va, ph->p_memsz, vm_flags, NULL)) != 0) {
ffffffffc0205b56:	0109b583          	ld	a1,16(s3)
ffffffffc0205b5a:	4701                	li	a4,0
ffffffffc0205b5c:	8526                	mv	a0,s1
ffffffffc0205b5e:	833fe0ef          	jal	ra,ffffffffc0204390 <mm_map>
ffffffffc0205b62:	8a2a                	mv	s4,a0
ffffffffc0205b64:	ed35                	bnez	a0,ffffffffc0205be0 <do_execve+0x342>
        uintptr_t start = ph->p_va, end, la = ROUNDDOWN(start, PGSIZE);
ffffffffc0205b66:	0109bb83          	ld	s7,16(s3)
ffffffffc0205b6a:	77fd                	lui	a5,0xfffff
        end = ph->p_va + ph->p_filesz;
ffffffffc0205b6c:	0209ba03          	ld	s4,32(s3)
        unsigned char *from = binary + ph->p_offset;
ffffffffc0205b70:	0089b903          	ld	s2,8(s3)
        uintptr_t start = ph->p_va, end, la = ROUNDDOWN(start, PGSIZE);
ffffffffc0205b74:	00fbfab3          	and	s5,s7,a5
        unsigned char *from = binary + ph->p_offset;
ffffffffc0205b78:	7782                	ld	a5,32(sp)
        end = ph->p_va + ph->p_filesz;
ffffffffc0205b7a:	9a5e                	add	s4,s4,s7
        unsigned char *from = binary + ph->p_offset;
ffffffffc0205b7c:	993e                	add	s2,s2,a5
        while (start < end) {
ffffffffc0205b7e:	054be963          	bltu	s7,s4,ffffffffc0205bd0 <do_execve+0x332>
ffffffffc0205b82:	aa95                	j	ffffffffc0205cf6 <do_execve+0x458>
            off = start - la, size = PGSIZE - off, la += PGSIZE;
ffffffffc0205b84:	6785                	lui	a5,0x1
ffffffffc0205b86:	415b8533          	sub	a0,s7,s5
ffffffffc0205b8a:	9abe                	add	s5,s5,a5
ffffffffc0205b8c:	417a8633          	sub	a2,s5,s7
            if (end < la) {
ffffffffc0205b90:	015a7463          	bgeu	s4,s5,ffffffffc0205b98 <do_execve+0x2fa>
                size -= la - end;
ffffffffc0205b94:	417a0633          	sub	a2,s4,s7
    return page - pages + nbase;
ffffffffc0205b98:	000cb683          	ld	a3,0(s9)
ffffffffc0205b9c:	67c2                	ld	a5,16(sp)
    return KADDR(page2pa(page));
ffffffffc0205b9e:	000c3583          	ld	a1,0(s8)
    return page - pages + nbase;
ffffffffc0205ba2:	40d406b3          	sub	a3,s0,a3
ffffffffc0205ba6:	8699                	srai	a3,a3,0x6
ffffffffc0205ba8:	96be                	add	a3,a3,a5
    return KADDR(page2pa(page));
ffffffffc0205baa:	67e2                	ld	a5,24(sp)
ffffffffc0205bac:	00f6f833          	and	a6,a3,a5
    return page2ppn(page) << PGSHIFT;
ffffffffc0205bb0:	06b2                	slli	a3,a3,0xc
    return KADDR(page2pa(page));
ffffffffc0205bb2:	14b87863          	bgeu	a6,a1,ffffffffc0205d02 <do_execve+0x464>
ffffffffc0205bb6:	000b3803          	ld	a6,0(s6)
            memcpy(page2kva(page) + off, from, size);
ffffffffc0205bba:	85ca                	mv	a1,s2
            start += size, from += size;
ffffffffc0205bbc:	9bb2                	add	s7,s7,a2
ffffffffc0205bbe:	96c2                	add	a3,a3,a6
            memcpy(page2kva(page) + off, from, size);
ffffffffc0205bc0:	9536                	add	a0,a0,a3
            start += size, from += size;
ffffffffc0205bc2:	e432                	sd	a2,8(sp)
            memcpy(page2kva(page) + off, from, size);
ffffffffc0205bc4:	353000ef          	jal	ra,ffffffffc0206716 <memcpy>
            start += size, from += size;
ffffffffc0205bc8:	6622                	ld	a2,8(sp)
ffffffffc0205bca:	9932                	add	s2,s2,a2
        while (start < end) {
ffffffffc0205bcc:	054bf363          	bgeu	s7,s4,ffffffffc0205c12 <do_execve+0x374>
            if ((page = pgdir_alloc_page(mm->pgdir, la, perm)) == NULL) {
ffffffffc0205bd0:	6c88                	ld	a0,24(s1)
ffffffffc0205bd2:	866a                	mv	a2,s10
ffffffffc0205bd4:	85d6                	mv	a1,s5
ffffffffc0205bd6:	fe2fd0ef          	jal	ra,ffffffffc02033b8 <pgdir_alloc_page>
ffffffffc0205bda:	842a                	mv	s0,a0
ffffffffc0205bdc:	f545                	bnez	a0,ffffffffc0205b84 <do_execve+0x2e6>
        ret = -E_NO_MEM;
ffffffffc0205bde:	5a71                	li	s4,-4
    exit_mmap(mm);
ffffffffc0205be0:	8526                	mv	a0,s1
ffffffffc0205be2:	8f9fe0ef          	jal	ra,ffffffffc02044da <exit_mmap>
    put_pgdir(mm);
ffffffffc0205be6:	8526                	mv	a0,s1
ffffffffc0205be8:	b78ff0ef          	jal	ra,ffffffffc0204f60 <put_pgdir>
    mm_destroy(mm);
ffffffffc0205bec:	8526                	mv	a0,s1
ffffffffc0205bee:	f50fe0ef          	jal	ra,ffffffffc020433e <mm_destroy>
    return ret;
ffffffffc0205bf2:	b705                	j	ffffffffc0205b12 <do_execve+0x274>
            exit_mmap(mm);
ffffffffc0205bf4:	854e                	mv	a0,s3
ffffffffc0205bf6:	8e5fe0ef          	jal	ra,ffffffffc02044da <exit_mmap>
            put_pgdir(mm);
ffffffffc0205bfa:	854e                	mv	a0,s3
ffffffffc0205bfc:	b64ff0ef          	jal	ra,ffffffffc0204f60 <put_pgdir>
            mm_destroy(mm);
ffffffffc0205c00:	854e                	mv	a0,s3
ffffffffc0205c02:	f3cfe0ef          	jal	ra,ffffffffc020433e <mm_destroy>
ffffffffc0205c06:	b32d                	j	ffffffffc0205930 <do_execve+0x92>
        if (ph->p_flags & ELF_PF_W) vm_flags |= VM_WRITE;
ffffffffc0205c08:	0026e693          	ori	a3,a3,2
        if (ph->p_flags & ELF_PF_R) vm_flags |= VM_READ;
ffffffffc0205c0c:	fb95                	bnez	a5,ffffffffc0205b40 <do_execve+0x2a2>
        if (vm_flags & VM_WRITE) perm |= (PTE_W | PTE_R);
ffffffffc0205c0e:	4d5d                	li	s10,23
ffffffffc0205c10:	bf35                	j	ffffffffc0205b4c <do_execve+0x2ae>
        end = ph->p_va + ph->p_memsz;
ffffffffc0205c12:	0109b683          	ld	a3,16(s3)
ffffffffc0205c16:	0289b903          	ld	s2,40(s3)
ffffffffc0205c1a:	9936                	add	s2,s2,a3
        if (start < la) {
ffffffffc0205c1c:	075bfd63          	bgeu	s7,s5,ffffffffc0205c96 <do_execve+0x3f8>
            if (start == end) {
ffffffffc0205c20:	db790fe3          	beq	s2,s7,ffffffffc02059de <do_execve+0x140>
            off = start + PGSIZE - la, size = PGSIZE - off;
ffffffffc0205c24:	6785                	lui	a5,0x1
ffffffffc0205c26:	00fb8533          	add	a0,s7,a5
ffffffffc0205c2a:	41550533          	sub	a0,a0,s5
                size -= la - end;
ffffffffc0205c2e:	41790a33          	sub	s4,s2,s7
            if (end < la) {
ffffffffc0205c32:	0b597d63          	bgeu	s2,s5,ffffffffc0205cec <do_execve+0x44e>
    return page - pages + nbase;
ffffffffc0205c36:	000cb683          	ld	a3,0(s9)
ffffffffc0205c3a:	67c2                	ld	a5,16(sp)
    return KADDR(page2pa(page));
ffffffffc0205c3c:	000c3603          	ld	a2,0(s8)
    return page - pages + nbase;
ffffffffc0205c40:	40d406b3          	sub	a3,s0,a3
ffffffffc0205c44:	8699                	srai	a3,a3,0x6
ffffffffc0205c46:	96be                	add	a3,a3,a5
    return KADDR(page2pa(page));
ffffffffc0205c48:	67e2                	ld	a5,24(sp)
ffffffffc0205c4a:	00f6f5b3          	and	a1,a3,a5
    return page2ppn(page) << PGSHIFT;
ffffffffc0205c4e:	06b2                	slli	a3,a3,0xc
    return KADDR(page2pa(page));
ffffffffc0205c50:	0ac5f963          	bgeu	a1,a2,ffffffffc0205d02 <do_execve+0x464>
ffffffffc0205c54:	000b3803          	ld	a6,0(s6)
            memset(page2kva(page) + off, 0, size);
ffffffffc0205c58:	8652                	mv	a2,s4
ffffffffc0205c5a:	4581                	li	a1,0
ffffffffc0205c5c:	96c2                	add	a3,a3,a6
ffffffffc0205c5e:	9536                	add	a0,a0,a3
ffffffffc0205c60:	2a5000ef          	jal	ra,ffffffffc0206704 <memset>
            start += size;
ffffffffc0205c64:	017a0733          	add	a4,s4,s7
            assert((end < la && start == end) || (end >= la && start == la));
ffffffffc0205c68:	03597463          	bgeu	s2,s5,ffffffffc0205c90 <do_execve+0x3f2>
ffffffffc0205c6c:	d6e909e3          	beq	s2,a4,ffffffffc02059de <do_execve+0x140>
ffffffffc0205c70:	00003697          	auipc	a3,0x3
ffffffffc0205c74:	b2868693          	addi	a3,a3,-1240 # ffffffffc0208798 <default_pmm_manager+0x1318>
ffffffffc0205c78:	00001617          	auipc	a2,0x1
ffffffffc0205c7c:	17060613          	addi	a2,a2,368 # ffffffffc0206de8 <commands+0x450>
ffffffffc0205c80:	25e00593          	li	a1,606
ffffffffc0205c84:	00003517          	auipc	a0,0x3
ffffffffc0205c88:	90450513          	addi	a0,a0,-1788 # ffffffffc0208588 <default_pmm_manager+0x1108>
ffffffffc0205c8c:	feefa0ef          	jal	ra,ffffffffc020047a <__panic>
ffffffffc0205c90:	ff5710e3          	bne	a4,s5,ffffffffc0205c70 <do_execve+0x3d2>
ffffffffc0205c94:	8bd6                	mv	s7,s5
        while (start < end) {
ffffffffc0205c96:	d52bf4e3          	bgeu	s7,s2,ffffffffc02059de <do_execve+0x140>
            if ((page = pgdir_alloc_page(mm->pgdir, la, perm)) == NULL) {
ffffffffc0205c9a:	6c88                	ld	a0,24(s1)
ffffffffc0205c9c:	866a                	mv	a2,s10
ffffffffc0205c9e:	85d6                	mv	a1,s5
ffffffffc0205ca0:	f18fd0ef          	jal	ra,ffffffffc02033b8 <pgdir_alloc_page>
ffffffffc0205ca4:	842a                	mv	s0,a0
ffffffffc0205ca6:	dd05                	beqz	a0,ffffffffc0205bde <do_execve+0x340>
            off = start - la, size = PGSIZE - off, la += PGSIZE;
ffffffffc0205ca8:	6785                	lui	a5,0x1
ffffffffc0205caa:	415b8533          	sub	a0,s7,s5
ffffffffc0205cae:	9abe                	add	s5,s5,a5
ffffffffc0205cb0:	417a8633          	sub	a2,s5,s7
            if (end < la) {
ffffffffc0205cb4:	01597463          	bgeu	s2,s5,ffffffffc0205cbc <do_execve+0x41e>
                size -= la - end;
ffffffffc0205cb8:	41790633          	sub	a2,s2,s7
    return page - pages + nbase;
ffffffffc0205cbc:	000cb683          	ld	a3,0(s9)
ffffffffc0205cc0:	67c2                	ld	a5,16(sp)
    return KADDR(page2pa(page));
ffffffffc0205cc2:	000c3583          	ld	a1,0(s8)
    return page - pages + nbase;
ffffffffc0205cc6:	40d406b3          	sub	a3,s0,a3
ffffffffc0205cca:	8699                	srai	a3,a3,0x6
ffffffffc0205ccc:	96be                	add	a3,a3,a5
    return KADDR(page2pa(page));
ffffffffc0205cce:	67e2                	ld	a5,24(sp)
ffffffffc0205cd0:	00f6f833          	and	a6,a3,a5
    return page2ppn(page) << PGSHIFT;
ffffffffc0205cd4:	06b2                	slli	a3,a3,0xc
    return KADDR(page2pa(page));
ffffffffc0205cd6:	02b87663          	bgeu	a6,a1,ffffffffc0205d02 <do_execve+0x464>
ffffffffc0205cda:	000b3803          	ld	a6,0(s6)
            memset(page2kva(page) + off, 0, size);
ffffffffc0205cde:	4581                	li	a1,0
            start += size;
ffffffffc0205ce0:	9bb2                	add	s7,s7,a2
ffffffffc0205ce2:	96c2                	add	a3,a3,a6
            memset(page2kva(page) + off, 0, size);
ffffffffc0205ce4:	9536                	add	a0,a0,a3
ffffffffc0205ce6:	21f000ef          	jal	ra,ffffffffc0206704 <memset>
ffffffffc0205cea:	b775                	j	ffffffffc0205c96 <do_execve+0x3f8>
            off = start + PGSIZE - la, size = PGSIZE - off;
ffffffffc0205cec:	417a8a33          	sub	s4,s5,s7
ffffffffc0205cf0:	b799                	j	ffffffffc0205c36 <do_execve+0x398>
        return -E_INVAL;
ffffffffc0205cf2:	5a75                	li	s4,-3
ffffffffc0205cf4:	b3c1                	j	ffffffffc0205ab4 <do_execve+0x216>
        while (start < end) {
ffffffffc0205cf6:	86de                	mv	a3,s7
ffffffffc0205cf8:	bf39                	j	ffffffffc0205c16 <do_execve+0x378>
    int ret = -E_NO_MEM;
ffffffffc0205cfa:	5a71                	li	s4,-4
ffffffffc0205cfc:	bdc5                	j	ffffffffc0205bec <do_execve+0x34e>
            ret = -E_INVAL_ELF;
ffffffffc0205cfe:	5a61                	li	s4,-8
ffffffffc0205d00:	b5c5                	j	ffffffffc0205be0 <do_execve+0x342>
ffffffffc0205d02:	00001617          	auipc	a2,0x1
ffffffffc0205d06:	7b660613          	addi	a2,a2,1974 # ffffffffc02074b8 <default_pmm_manager+0x38>
ffffffffc0205d0a:	06900593          	li	a1,105
ffffffffc0205d0e:	00001517          	auipc	a0,0x1
ffffffffc0205d12:	7d250513          	addi	a0,a0,2002 # ffffffffc02074e0 <default_pmm_manager+0x60>
ffffffffc0205d16:	f64fa0ef          	jal	ra,ffffffffc020047a <__panic>
    current->cr3 = PADDR(mm->pgdir);
ffffffffc0205d1a:	00002617          	auipc	a2,0x2
ffffffffc0205d1e:	84660613          	addi	a2,a2,-1978 # ffffffffc0207560 <default_pmm_manager+0xe0>
ffffffffc0205d22:	27900593          	li	a1,633
ffffffffc0205d26:	00003517          	auipc	a0,0x3
ffffffffc0205d2a:	86250513          	addi	a0,a0,-1950 # ffffffffc0208588 <default_pmm_manager+0x1108>
ffffffffc0205d2e:	f4cfa0ef          	jal	ra,ffffffffc020047a <__panic>
    assert(pgdir_alloc_page(mm->pgdir, USTACKTOP-4*PGSIZE , PTE_USER) != NULL);
ffffffffc0205d32:	00003697          	auipc	a3,0x3
ffffffffc0205d36:	b7e68693          	addi	a3,a3,-1154 # ffffffffc02088b0 <default_pmm_manager+0x1430>
ffffffffc0205d3a:	00001617          	auipc	a2,0x1
ffffffffc0205d3e:	0ae60613          	addi	a2,a2,174 # ffffffffc0206de8 <commands+0x450>
ffffffffc0205d42:	27400593          	li	a1,628
ffffffffc0205d46:	00003517          	auipc	a0,0x3
ffffffffc0205d4a:	84250513          	addi	a0,a0,-1982 # ffffffffc0208588 <default_pmm_manager+0x1108>
ffffffffc0205d4e:	f2cfa0ef          	jal	ra,ffffffffc020047a <__panic>
    assert(pgdir_alloc_page(mm->pgdir, USTACKTOP-3*PGSIZE , PTE_USER) != NULL);
ffffffffc0205d52:	00003697          	auipc	a3,0x3
ffffffffc0205d56:	b1668693          	addi	a3,a3,-1258 # ffffffffc0208868 <default_pmm_manager+0x13e8>
ffffffffc0205d5a:	00001617          	auipc	a2,0x1
ffffffffc0205d5e:	08e60613          	addi	a2,a2,142 # ffffffffc0206de8 <commands+0x450>
ffffffffc0205d62:	27300593          	li	a1,627
ffffffffc0205d66:	00003517          	auipc	a0,0x3
ffffffffc0205d6a:	82250513          	addi	a0,a0,-2014 # ffffffffc0208588 <default_pmm_manager+0x1108>
ffffffffc0205d6e:	f0cfa0ef          	jal	ra,ffffffffc020047a <__panic>
    assert(pgdir_alloc_page(mm->pgdir, USTACKTOP-2*PGSIZE , PTE_USER) != NULL);
ffffffffc0205d72:	00003697          	auipc	a3,0x3
ffffffffc0205d76:	aae68693          	addi	a3,a3,-1362 # ffffffffc0208820 <default_pmm_manager+0x13a0>
ffffffffc0205d7a:	00001617          	auipc	a2,0x1
ffffffffc0205d7e:	06e60613          	addi	a2,a2,110 # ffffffffc0206de8 <commands+0x450>
ffffffffc0205d82:	27200593          	li	a1,626
ffffffffc0205d86:	00003517          	auipc	a0,0x3
ffffffffc0205d8a:	80250513          	addi	a0,a0,-2046 # ffffffffc0208588 <default_pmm_manager+0x1108>
ffffffffc0205d8e:	eecfa0ef          	jal	ra,ffffffffc020047a <__panic>
    assert(pgdir_alloc_page(mm->pgdir, USTACKTOP-PGSIZE , PTE_USER) != NULL);
ffffffffc0205d92:	00003697          	auipc	a3,0x3
ffffffffc0205d96:	a4668693          	addi	a3,a3,-1466 # ffffffffc02087d8 <default_pmm_manager+0x1358>
ffffffffc0205d9a:	00001617          	auipc	a2,0x1
ffffffffc0205d9e:	04e60613          	addi	a2,a2,78 # ffffffffc0206de8 <commands+0x450>
ffffffffc0205da2:	27100593          	li	a1,625
ffffffffc0205da6:	00002517          	auipc	a0,0x2
ffffffffc0205daa:	7e250513          	addi	a0,a0,2018 # ffffffffc0208588 <default_pmm_manager+0x1108>
ffffffffc0205dae:	eccfa0ef          	jal	ra,ffffffffc020047a <__panic>

ffffffffc0205db2 <do_yield>:
    current->need_resched = 1;
ffffffffc0205db2:	000ad797          	auipc	a5,0xad
ffffffffc0205db6:	b3e7b783          	ld	a5,-1218(a5) # ffffffffc02b28f0 <current>
ffffffffc0205dba:	4705                	li	a4,1
ffffffffc0205dbc:	ef98                	sd	a4,24(a5)
}
ffffffffc0205dbe:	4501                	li	a0,0
ffffffffc0205dc0:	8082                	ret

ffffffffc0205dc2 <do_wait>:
do_wait(int pid, int *code_store) {
ffffffffc0205dc2:	1101                	addi	sp,sp,-32
ffffffffc0205dc4:	e822                	sd	s0,16(sp)
ffffffffc0205dc6:	e426                	sd	s1,8(sp)
ffffffffc0205dc8:	ec06                	sd	ra,24(sp)
ffffffffc0205dca:	842e                	mv	s0,a1
ffffffffc0205dcc:	84aa                	mv	s1,a0
    if (code_store != NULL) {
ffffffffc0205dce:	c999                	beqz	a1,ffffffffc0205de4 <do_wait+0x22>
    struct mm_struct *mm = current->mm;
ffffffffc0205dd0:	000ad797          	auipc	a5,0xad
ffffffffc0205dd4:	b207b783          	ld	a5,-1248(a5) # ffffffffc02b28f0 <current>
        if (!user_mem_check(mm, (uintptr_t)code_store, sizeof(int), 1)) {
ffffffffc0205dd8:	7788                	ld	a0,40(a5)
ffffffffc0205dda:	4685                	li	a3,1
ffffffffc0205ddc:	4611                	li	a2,4
ffffffffc0205dde:	e95fe0ef          	jal	ra,ffffffffc0204c72 <user_mem_check>
ffffffffc0205de2:	c909                	beqz	a0,ffffffffc0205df4 <do_wait+0x32>
ffffffffc0205de4:	85a2                	mv	a1,s0
}
ffffffffc0205de6:	6442                	ld	s0,16(sp)
ffffffffc0205de8:	60e2                	ld	ra,24(sp)
ffffffffc0205dea:	8526                	mv	a0,s1
ffffffffc0205dec:	64a2                	ld	s1,8(sp)
ffffffffc0205dee:	6105                	addi	sp,sp,32
ffffffffc0205df0:	fb8ff06f          	j	ffffffffc02055a8 <do_wait.part.0>
ffffffffc0205df4:	60e2                	ld	ra,24(sp)
ffffffffc0205df6:	6442                	ld	s0,16(sp)
ffffffffc0205df8:	64a2                	ld	s1,8(sp)
ffffffffc0205dfa:	5575                	li	a0,-3
ffffffffc0205dfc:	6105                	addi	sp,sp,32
ffffffffc0205dfe:	8082                	ret

ffffffffc0205e00 <do_kill>:
do_kill(int pid) {
ffffffffc0205e00:	1141                	addi	sp,sp,-16
    if (0 < pid && pid < MAX_PID) {
ffffffffc0205e02:	6789                	lui	a5,0x2
do_kill(int pid) {
ffffffffc0205e04:	e406                	sd	ra,8(sp)
ffffffffc0205e06:	e022                	sd	s0,0(sp)
    if (0 < pid && pid < MAX_PID) {
ffffffffc0205e08:	fff5071b          	addiw	a4,a0,-1
ffffffffc0205e0c:	17f9                	addi	a5,a5,-2
ffffffffc0205e0e:	02e7e963          	bltu	a5,a4,ffffffffc0205e40 <do_kill+0x40>
        list_entry_t *list = hash_list + pid_hashfn(pid), *le = list;
ffffffffc0205e12:	842a                	mv	s0,a0
ffffffffc0205e14:	45a9                	li	a1,10
ffffffffc0205e16:	2501                	sext.w	a0,a0
ffffffffc0205e18:	46c000ef          	jal	ra,ffffffffc0206284 <hash32>
ffffffffc0205e1c:	02051793          	slli	a5,a0,0x20
ffffffffc0205e20:	01c7d513          	srli	a0,a5,0x1c
ffffffffc0205e24:	000a9797          	auipc	a5,0xa9
ffffffffc0205e28:	a4478793          	addi	a5,a5,-1468 # ffffffffc02ae868 <hash_list>
ffffffffc0205e2c:	953e                	add	a0,a0,a5
ffffffffc0205e2e:	87aa                	mv	a5,a0
        while ((le = list_next(le)) != list) {
ffffffffc0205e30:	a029                	j	ffffffffc0205e3a <do_kill+0x3a>
            if (proc->pid == pid) {
ffffffffc0205e32:	f2c7a703          	lw	a4,-212(a5)
ffffffffc0205e36:	00870b63          	beq	a4,s0,ffffffffc0205e4c <do_kill+0x4c>
ffffffffc0205e3a:	679c                	ld	a5,8(a5)
        while ((le = list_next(le)) != list) {
ffffffffc0205e3c:	fef51be3          	bne	a0,a5,ffffffffc0205e32 <do_kill+0x32>
    return -E_INVAL;
ffffffffc0205e40:	5475                	li	s0,-3
}
ffffffffc0205e42:	60a2                	ld	ra,8(sp)
ffffffffc0205e44:	8522                	mv	a0,s0
ffffffffc0205e46:	6402                	ld	s0,0(sp)
ffffffffc0205e48:	0141                	addi	sp,sp,16
ffffffffc0205e4a:	8082                	ret
        if (!(proc->flags & PF_EXITING)) {
ffffffffc0205e4c:	fd87a703          	lw	a4,-40(a5)
ffffffffc0205e50:	00177693          	andi	a3,a4,1
ffffffffc0205e54:	e295                	bnez	a3,ffffffffc0205e78 <do_kill+0x78>
            if (proc->wait_state & WT_INTERRUPTED) {
ffffffffc0205e56:	4bd4                	lw	a3,20(a5)
            proc->flags |= PF_EXITING;
ffffffffc0205e58:	00176713          	ori	a4,a4,1
ffffffffc0205e5c:	fce7ac23          	sw	a4,-40(a5)
            return 0;
ffffffffc0205e60:	4401                	li	s0,0
            if (proc->wait_state & WT_INTERRUPTED) {
ffffffffc0205e62:	fe06d0e3          	bgez	a3,ffffffffc0205e42 <do_kill+0x42>
                wakeup_proc(proc);
ffffffffc0205e66:	f2878513          	addi	a0,a5,-216
ffffffffc0205e6a:	22e000ef          	jal	ra,ffffffffc0206098 <wakeup_proc>
}
ffffffffc0205e6e:	60a2                	ld	ra,8(sp)
ffffffffc0205e70:	8522                	mv	a0,s0
ffffffffc0205e72:	6402                	ld	s0,0(sp)
ffffffffc0205e74:	0141                	addi	sp,sp,16
ffffffffc0205e76:	8082                	ret
        return -E_KILLED;
ffffffffc0205e78:	545d                	li	s0,-9
ffffffffc0205e7a:	b7e1                	j	ffffffffc0205e42 <do_kill+0x42>

ffffffffc0205e7c <proc_init>:

// proc_init - set up the first kernel thread idleproc "idle" by itself and 
//           - create the second kernel thread init_main
void
proc_init(void) {
ffffffffc0205e7c:	1101                	addi	sp,sp,-32
ffffffffc0205e7e:	e426                	sd	s1,8(sp)
    elm->prev = elm->next = elm;
ffffffffc0205e80:	000ad797          	auipc	a5,0xad
ffffffffc0205e84:	9e878793          	addi	a5,a5,-1560 # ffffffffc02b2868 <proc_list>
ffffffffc0205e88:	ec06                	sd	ra,24(sp)
ffffffffc0205e8a:	e822                	sd	s0,16(sp)
ffffffffc0205e8c:	e04a                	sd	s2,0(sp)
ffffffffc0205e8e:	000a9497          	auipc	s1,0xa9
ffffffffc0205e92:	9da48493          	addi	s1,s1,-1574 # ffffffffc02ae868 <hash_list>
ffffffffc0205e96:	e79c                	sd	a5,8(a5)
ffffffffc0205e98:	e39c                	sd	a5,0(a5)
    int i;

    list_init(&proc_list);
    for (i = 0; i < HASH_LIST_SIZE; i ++) {
ffffffffc0205e9a:	000ad717          	auipc	a4,0xad
ffffffffc0205e9e:	9ce70713          	addi	a4,a4,-1586 # ffffffffc02b2868 <proc_list>
ffffffffc0205ea2:	87a6                	mv	a5,s1
ffffffffc0205ea4:	e79c                	sd	a5,8(a5)
ffffffffc0205ea6:	e39c                	sd	a5,0(a5)
ffffffffc0205ea8:	07c1                	addi	a5,a5,16
ffffffffc0205eaa:	fef71de3          	bne	a4,a5,ffffffffc0205ea4 <proc_init+0x28>
        list_init(hash_list + i);
    }

    if ((idleproc = alloc_proc()) == NULL) {
ffffffffc0205eae:	fb5fe0ef          	jal	ra,ffffffffc0204e62 <alloc_proc>
ffffffffc0205eb2:	000ad917          	auipc	s2,0xad
ffffffffc0205eb6:	a4690913          	addi	s2,s2,-1466 # ffffffffc02b28f8 <idleproc>
ffffffffc0205eba:	00a93023          	sd	a0,0(s2)
ffffffffc0205ebe:	0e050f63          	beqz	a0,ffffffffc0205fbc <proc_init+0x140>
        panic("cannot alloc idleproc.\n");
    }

    idleproc->pid = 0;
    idleproc->state = PROC_RUNNABLE;
ffffffffc0205ec2:	4789                	li	a5,2
ffffffffc0205ec4:	e11c                	sd	a5,0(a0)
    idleproc->kstack = (uintptr_t)bootstack;
ffffffffc0205ec6:	00003797          	auipc	a5,0x3
ffffffffc0205eca:	13a78793          	addi	a5,a5,314 # ffffffffc0209000 <bootstack>
    memset(proc->name, 0, sizeof(proc->name));
ffffffffc0205ece:	0b450413          	addi	s0,a0,180
    idleproc->kstack = (uintptr_t)bootstack;
ffffffffc0205ed2:	e91c                	sd	a5,16(a0)
    idleproc->need_resched = 1;
ffffffffc0205ed4:	4785                	li	a5,1
ffffffffc0205ed6:	ed1c                	sd	a5,24(a0)
    memset(proc->name, 0, sizeof(proc->name));
ffffffffc0205ed8:	4641                	li	a2,16
ffffffffc0205eda:	4581                	li	a1,0
ffffffffc0205edc:	8522                	mv	a0,s0
ffffffffc0205ede:	027000ef          	jal	ra,ffffffffc0206704 <memset>
    return memcpy(proc->name, name, PROC_NAME_LEN);
ffffffffc0205ee2:	463d                	li	a2,15
ffffffffc0205ee4:	00003597          	auipc	a1,0x3
ffffffffc0205ee8:	a2c58593          	addi	a1,a1,-1492 # ffffffffc0208910 <default_pmm_manager+0x1490>
ffffffffc0205eec:	8522                	mv	a0,s0
ffffffffc0205eee:	029000ef          	jal	ra,ffffffffc0206716 <memcpy>
    set_proc_name(idleproc, "idle");
    nr_process ++;
ffffffffc0205ef2:	000ad717          	auipc	a4,0xad
ffffffffc0205ef6:	a1670713          	addi	a4,a4,-1514 # ffffffffc02b2908 <nr_process>
ffffffffc0205efa:	431c                	lw	a5,0(a4)

    current = idleproc;
ffffffffc0205efc:	00093683          	ld	a3,0(s2)

    int pid = kernel_thread(init_main, NULL, 0);
ffffffffc0205f00:	4601                	li	a2,0
    nr_process ++;
ffffffffc0205f02:	2785                	addiw	a5,a5,1
    int pid = kernel_thread(init_main, NULL, 0);
ffffffffc0205f04:	4581                	li	a1,0
ffffffffc0205f06:	00000517          	auipc	a0,0x0
ffffffffc0205f0a:	87450513          	addi	a0,a0,-1932 # ffffffffc020577a <init_main>
    nr_process ++;
ffffffffc0205f0e:	c31c                	sw	a5,0(a4)
    current = idleproc;
ffffffffc0205f10:	000ad797          	auipc	a5,0xad
ffffffffc0205f14:	9ed7b023          	sd	a3,-1568(a5) # ffffffffc02b28f0 <current>
    int pid = kernel_thread(init_main, NULL, 0);
ffffffffc0205f18:	cf6ff0ef          	jal	ra,ffffffffc020540e <kernel_thread>
ffffffffc0205f1c:	842a                	mv	s0,a0
    if (pid <= 0) {
ffffffffc0205f1e:	08a05363          	blez	a0,ffffffffc0205fa4 <proc_init+0x128>
    if (0 < pid && pid < MAX_PID) {
ffffffffc0205f22:	6789                	lui	a5,0x2
ffffffffc0205f24:	fff5071b          	addiw	a4,a0,-1
ffffffffc0205f28:	17f9                	addi	a5,a5,-2
ffffffffc0205f2a:	2501                	sext.w	a0,a0
ffffffffc0205f2c:	02e7e363          	bltu	a5,a4,ffffffffc0205f52 <proc_init+0xd6>
        list_entry_t *list = hash_list + pid_hashfn(pid), *le = list;
ffffffffc0205f30:	45a9                	li	a1,10
ffffffffc0205f32:	352000ef          	jal	ra,ffffffffc0206284 <hash32>
ffffffffc0205f36:	02051793          	slli	a5,a0,0x20
ffffffffc0205f3a:	01c7d693          	srli	a3,a5,0x1c
ffffffffc0205f3e:	96a6                	add	a3,a3,s1
ffffffffc0205f40:	87b6                	mv	a5,a3
        while ((le = list_next(le)) != list) {
ffffffffc0205f42:	a029                	j	ffffffffc0205f4c <proc_init+0xd0>
            if (proc->pid == pid) {
ffffffffc0205f44:	f2c7a703          	lw	a4,-212(a5) # 1f2c <_binary_obj___user_faultread_out_size-0x7c8c>
ffffffffc0205f48:	04870b63          	beq	a4,s0,ffffffffc0205f9e <proc_init+0x122>
    return listelm->next;
ffffffffc0205f4c:	679c                	ld	a5,8(a5)
        while ((le = list_next(le)) != list) {
ffffffffc0205f4e:	fef69be3          	bne	a3,a5,ffffffffc0205f44 <proc_init+0xc8>
    return NULL;
ffffffffc0205f52:	4781                	li	a5,0
    memset(proc->name, 0, sizeof(proc->name));
ffffffffc0205f54:	0b478493          	addi	s1,a5,180
ffffffffc0205f58:	4641                	li	a2,16
ffffffffc0205f5a:	4581                	li	a1,0
        panic("create init_main failed.\n");
    }

    initproc = find_proc(pid);
ffffffffc0205f5c:	000ad417          	auipc	s0,0xad
ffffffffc0205f60:	9a440413          	addi	s0,s0,-1628 # ffffffffc02b2900 <initproc>
    memset(proc->name, 0, sizeof(proc->name));
ffffffffc0205f64:	8526                	mv	a0,s1
    initproc = find_proc(pid);
ffffffffc0205f66:	e01c                	sd	a5,0(s0)
    memset(proc->name, 0, sizeof(proc->name));
ffffffffc0205f68:	79c000ef          	jal	ra,ffffffffc0206704 <memset>
    return memcpy(proc->name, name, PROC_NAME_LEN);
ffffffffc0205f6c:	463d                	li	a2,15
ffffffffc0205f6e:	00003597          	auipc	a1,0x3
ffffffffc0205f72:	9ca58593          	addi	a1,a1,-1590 # ffffffffc0208938 <default_pmm_manager+0x14b8>
ffffffffc0205f76:	8526                	mv	a0,s1
ffffffffc0205f78:	79e000ef          	jal	ra,ffffffffc0206716 <memcpy>
    set_proc_name(initproc, "init");

    assert(idleproc != NULL && idleproc->pid == 0);
ffffffffc0205f7c:	00093783          	ld	a5,0(s2)
ffffffffc0205f80:	cbb5                	beqz	a5,ffffffffc0205ff4 <proc_init+0x178>
ffffffffc0205f82:	43dc                	lw	a5,4(a5)
ffffffffc0205f84:	eba5                	bnez	a5,ffffffffc0205ff4 <proc_init+0x178>
    assert(initproc != NULL && initproc->pid == 1);
ffffffffc0205f86:	601c                	ld	a5,0(s0)
ffffffffc0205f88:	c7b1                	beqz	a5,ffffffffc0205fd4 <proc_init+0x158>
ffffffffc0205f8a:	43d8                	lw	a4,4(a5)
ffffffffc0205f8c:	4785                	li	a5,1
ffffffffc0205f8e:	04f71363          	bne	a4,a5,ffffffffc0205fd4 <proc_init+0x158>
}
ffffffffc0205f92:	60e2                	ld	ra,24(sp)
ffffffffc0205f94:	6442                	ld	s0,16(sp)
ffffffffc0205f96:	64a2                	ld	s1,8(sp)
ffffffffc0205f98:	6902                	ld	s2,0(sp)
ffffffffc0205f9a:	6105                	addi	sp,sp,32
ffffffffc0205f9c:	8082                	ret
            struct proc_struct *proc = le2proc(le, hash_link);
ffffffffc0205f9e:	f2878793          	addi	a5,a5,-216
ffffffffc0205fa2:	bf4d                	j	ffffffffc0205f54 <proc_init+0xd8>
        panic("create init_main failed.\n");
ffffffffc0205fa4:	00003617          	auipc	a2,0x3
ffffffffc0205fa8:	97460613          	addi	a2,a2,-1676 # ffffffffc0208918 <default_pmm_manager+0x1498>
ffffffffc0205fac:	37e00593          	li	a1,894
ffffffffc0205fb0:	00002517          	auipc	a0,0x2
ffffffffc0205fb4:	5d850513          	addi	a0,a0,1496 # ffffffffc0208588 <default_pmm_manager+0x1108>
ffffffffc0205fb8:	cc2fa0ef          	jal	ra,ffffffffc020047a <__panic>
        panic("cannot alloc idleproc.\n");
ffffffffc0205fbc:	00003617          	auipc	a2,0x3
ffffffffc0205fc0:	93c60613          	addi	a2,a2,-1732 # ffffffffc02088f8 <default_pmm_manager+0x1478>
ffffffffc0205fc4:	37000593          	li	a1,880
ffffffffc0205fc8:	00002517          	auipc	a0,0x2
ffffffffc0205fcc:	5c050513          	addi	a0,a0,1472 # ffffffffc0208588 <default_pmm_manager+0x1108>
ffffffffc0205fd0:	caafa0ef          	jal	ra,ffffffffc020047a <__panic>
    assert(initproc != NULL && initproc->pid == 1);
ffffffffc0205fd4:	00003697          	auipc	a3,0x3
ffffffffc0205fd8:	99468693          	addi	a3,a3,-1644 # ffffffffc0208968 <default_pmm_manager+0x14e8>
ffffffffc0205fdc:	00001617          	auipc	a2,0x1
ffffffffc0205fe0:	e0c60613          	addi	a2,a2,-500 # ffffffffc0206de8 <commands+0x450>
ffffffffc0205fe4:	38500593          	li	a1,901
ffffffffc0205fe8:	00002517          	auipc	a0,0x2
ffffffffc0205fec:	5a050513          	addi	a0,a0,1440 # ffffffffc0208588 <default_pmm_manager+0x1108>
ffffffffc0205ff0:	c8afa0ef          	jal	ra,ffffffffc020047a <__panic>
    assert(idleproc != NULL && idleproc->pid == 0);
ffffffffc0205ff4:	00003697          	auipc	a3,0x3
ffffffffc0205ff8:	94c68693          	addi	a3,a3,-1716 # ffffffffc0208940 <default_pmm_manager+0x14c0>
ffffffffc0205ffc:	00001617          	auipc	a2,0x1
ffffffffc0206000:	dec60613          	addi	a2,a2,-532 # ffffffffc0206de8 <commands+0x450>
ffffffffc0206004:	38400593          	li	a1,900
ffffffffc0206008:	00002517          	auipc	a0,0x2
ffffffffc020600c:	58050513          	addi	a0,a0,1408 # ffffffffc0208588 <default_pmm_manager+0x1108>
ffffffffc0206010:	c6afa0ef          	jal	ra,ffffffffc020047a <__panic>

ffffffffc0206014 <cpu_idle>:

// cpu_idle - at the end of kern_init, the first kernel thread idleproc will do below works
void
cpu_idle(void) {
ffffffffc0206014:	1141                	addi	sp,sp,-16
ffffffffc0206016:	e022                	sd	s0,0(sp)
ffffffffc0206018:	e406                	sd	ra,8(sp)
ffffffffc020601a:	000ad417          	auipc	s0,0xad
ffffffffc020601e:	8d640413          	addi	s0,s0,-1834 # ffffffffc02b28f0 <current>
    while (1) {
        if (current->need_resched) {
ffffffffc0206022:	6018                	ld	a4,0(s0)
ffffffffc0206024:	6f1c                	ld	a5,24(a4)
ffffffffc0206026:	dffd                	beqz	a5,ffffffffc0206024 <cpu_idle+0x10>
            schedule();
ffffffffc0206028:	0f0000ef          	jal	ra,ffffffffc0206118 <schedule>
ffffffffc020602c:	bfdd                	j	ffffffffc0206022 <cpu_idle+0xe>

ffffffffc020602e <switch_to>:
.text
# void switch_to(struct proc_struct* from, struct proc_struct* to)
.globl switch_to
switch_to:
    # save from's registers
    STORE ra, 0*REGBYTES(a0)
ffffffffc020602e:	00153023          	sd	ra,0(a0)
    STORE sp, 1*REGBYTES(a0)
ffffffffc0206032:	00253423          	sd	sp,8(a0)
    STORE s0, 2*REGBYTES(a0)
ffffffffc0206036:	e900                	sd	s0,16(a0)
    STORE s1, 3*REGBYTES(a0)
ffffffffc0206038:	ed04                	sd	s1,24(a0)
    STORE s2, 4*REGBYTES(a0)
ffffffffc020603a:	03253023          	sd	s2,32(a0)
    STORE s3, 5*REGBYTES(a0)
ffffffffc020603e:	03353423          	sd	s3,40(a0)
    STORE s4, 6*REGBYTES(a0)
ffffffffc0206042:	03453823          	sd	s4,48(a0)
    STORE s5, 7*REGBYTES(a0)
ffffffffc0206046:	03553c23          	sd	s5,56(a0)
    STORE s6, 8*REGBYTES(a0)
ffffffffc020604a:	05653023          	sd	s6,64(a0)
    STORE s7, 9*REGBYTES(a0)
ffffffffc020604e:	05753423          	sd	s7,72(a0)
    STORE s8, 10*REGBYTES(a0)
ffffffffc0206052:	05853823          	sd	s8,80(a0)
    STORE s9, 11*REGBYTES(a0)
ffffffffc0206056:	05953c23          	sd	s9,88(a0)
    STORE s10, 12*REGBYTES(a0)
ffffffffc020605a:	07a53023          	sd	s10,96(a0)
    STORE s11, 13*REGBYTES(a0)
ffffffffc020605e:	07b53423          	sd	s11,104(a0)

    # restore to's registers
    LOAD ra, 0*REGBYTES(a1)
ffffffffc0206062:	0005b083          	ld	ra,0(a1)
    LOAD sp, 1*REGBYTES(a1)
ffffffffc0206066:	0085b103          	ld	sp,8(a1)
    LOAD s0, 2*REGBYTES(a1)
ffffffffc020606a:	6980                	ld	s0,16(a1)
    LOAD s1, 3*REGBYTES(a1)
ffffffffc020606c:	6d84                	ld	s1,24(a1)
    LOAD s2, 4*REGBYTES(a1)
ffffffffc020606e:	0205b903          	ld	s2,32(a1)
    LOAD s3, 5*REGBYTES(a1)
ffffffffc0206072:	0285b983          	ld	s3,40(a1)
    LOAD s4, 6*REGBYTES(a1)
ffffffffc0206076:	0305ba03          	ld	s4,48(a1)
    LOAD s5, 7*REGBYTES(a1)
ffffffffc020607a:	0385ba83          	ld	s5,56(a1)
    LOAD s6, 8*REGBYTES(a1)
ffffffffc020607e:	0405bb03          	ld	s6,64(a1)
    LOAD s7, 9*REGBYTES(a1)
ffffffffc0206082:	0485bb83          	ld	s7,72(a1)
    LOAD s8, 10*REGBYTES(a1)
ffffffffc0206086:	0505bc03          	ld	s8,80(a1)
    LOAD s9, 11*REGBYTES(a1)
ffffffffc020608a:	0585bc83          	ld	s9,88(a1)
    LOAD s10, 12*REGBYTES(a1)
ffffffffc020608e:	0605bd03          	ld	s10,96(a1)
    LOAD s11, 13*REGBYTES(a1)
ffffffffc0206092:	0685bd83          	ld	s11,104(a1)

    ret
ffffffffc0206096:	8082                	ret

ffffffffc0206098 <wakeup_proc>:
#include <sched.h>
#include <assert.h>

void
wakeup_proc(struct proc_struct *proc) {
    assert(proc->state != PROC_ZOMBIE);
ffffffffc0206098:	4118                	lw	a4,0(a0)
wakeup_proc(struct proc_struct *proc) {
ffffffffc020609a:	1101                	addi	sp,sp,-32
ffffffffc020609c:	ec06                	sd	ra,24(sp)
ffffffffc020609e:	e822                	sd	s0,16(sp)
ffffffffc02060a0:	e426                	sd	s1,8(sp)
    assert(proc->state != PROC_ZOMBIE);
ffffffffc02060a2:	478d                	li	a5,3
ffffffffc02060a4:	04f70b63          	beq	a4,a5,ffffffffc02060fa <wakeup_proc+0x62>
ffffffffc02060a8:	842a                	mv	s0,a0
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc02060aa:	100027f3          	csrr	a5,sstatus
ffffffffc02060ae:	8b89                	andi	a5,a5,2
    return 0;
ffffffffc02060b0:	4481                	li	s1,0
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc02060b2:	ef9d                	bnez	a5,ffffffffc02060f0 <wakeup_proc+0x58>
    bool intr_flag;
    local_intr_save(intr_flag);
    {
        if (proc->state != PROC_RUNNABLE) {
ffffffffc02060b4:	4789                	li	a5,2
ffffffffc02060b6:	02f70163          	beq	a4,a5,ffffffffc02060d8 <wakeup_proc+0x40>
            proc->state = PROC_RUNNABLE;
ffffffffc02060ba:	c01c                	sw	a5,0(s0)
            proc->wait_state = 0;
ffffffffc02060bc:	0e042623          	sw	zero,236(s0)
    if (flag) {
ffffffffc02060c0:	e491                	bnez	s1,ffffffffc02060cc <wakeup_proc+0x34>
        else {
            warn("wakeup runnable process.\n");
        }
    }
    local_intr_restore(intr_flag);
}
ffffffffc02060c2:	60e2                	ld	ra,24(sp)
ffffffffc02060c4:	6442                	ld	s0,16(sp)
ffffffffc02060c6:	64a2                	ld	s1,8(sp)
ffffffffc02060c8:	6105                	addi	sp,sp,32
ffffffffc02060ca:	8082                	ret
ffffffffc02060cc:	6442                	ld	s0,16(sp)
ffffffffc02060ce:	60e2                	ld	ra,24(sp)
ffffffffc02060d0:	64a2                	ld	s1,8(sp)
ffffffffc02060d2:	6105                	addi	sp,sp,32
        intr_enable();
ffffffffc02060d4:	d6cfa06f          	j	ffffffffc0200640 <intr_enable>
            warn("wakeup runnable process.\n");
ffffffffc02060d8:	00003617          	auipc	a2,0x3
ffffffffc02060dc:	8f060613          	addi	a2,a2,-1808 # ffffffffc02089c8 <default_pmm_manager+0x1548>
ffffffffc02060e0:	45c9                	li	a1,18
ffffffffc02060e2:	00003517          	auipc	a0,0x3
ffffffffc02060e6:	8ce50513          	addi	a0,a0,-1842 # ffffffffc02089b0 <default_pmm_manager+0x1530>
ffffffffc02060ea:	bf8fa0ef          	jal	ra,ffffffffc02004e2 <__warn>
ffffffffc02060ee:	bfc9                	j	ffffffffc02060c0 <wakeup_proc+0x28>
        intr_disable();
ffffffffc02060f0:	d56fa0ef          	jal	ra,ffffffffc0200646 <intr_disable>
        if (proc->state != PROC_RUNNABLE) {
ffffffffc02060f4:	4018                	lw	a4,0(s0)
        return 1;
ffffffffc02060f6:	4485                	li	s1,1
ffffffffc02060f8:	bf75                	j	ffffffffc02060b4 <wakeup_proc+0x1c>
    assert(proc->state != PROC_ZOMBIE);
ffffffffc02060fa:	00003697          	auipc	a3,0x3
ffffffffc02060fe:	89668693          	addi	a3,a3,-1898 # ffffffffc0208990 <default_pmm_manager+0x1510>
ffffffffc0206102:	00001617          	auipc	a2,0x1
ffffffffc0206106:	ce660613          	addi	a2,a2,-794 # ffffffffc0206de8 <commands+0x450>
ffffffffc020610a:	45a5                	li	a1,9
ffffffffc020610c:	00003517          	auipc	a0,0x3
ffffffffc0206110:	8a450513          	addi	a0,a0,-1884 # ffffffffc02089b0 <default_pmm_manager+0x1530>
ffffffffc0206114:	b66fa0ef          	jal	ra,ffffffffc020047a <__panic>

ffffffffc0206118 <schedule>:

void
schedule(void) {
ffffffffc0206118:	1141                	addi	sp,sp,-16
ffffffffc020611a:	e406                	sd	ra,8(sp)
ffffffffc020611c:	e022                	sd	s0,0(sp)
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc020611e:	100027f3          	csrr	a5,sstatus
ffffffffc0206122:	8b89                	andi	a5,a5,2
ffffffffc0206124:	4401                	li	s0,0
ffffffffc0206126:	efbd                	bnez	a5,ffffffffc02061a4 <schedule+0x8c>
    bool intr_flag;
    list_entry_t *le, *last;
    struct proc_struct *next = NULL;
    local_intr_save(intr_flag);
    {
        current->need_resched = 0;
ffffffffc0206128:	000ac897          	auipc	a7,0xac
ffffffffc020612c:	7c88b883          	ld	a7,1992(a7) # ffffffffc02b28f0 <current>
ffffffffc0206130:	0008bc23          	sd	zero,24(a7)
        last = (current == idleproc) ? &proc_list : &(current->list_link);
ffffffffc0206134:	000ac517          	auipc	a0,0xac
ffffffffc0206138:	7c453503          	ld	a0,1988(a0) # ffffffffc02b28f8 <idleproc>
ffffffffc020613c:	04a88e63          	beq	a7,a0,ffffffffc0206198 <schedule+0x80>
ffffffffc0206140:	0c888693          	addi	a3,a7,200
ffffffffc0206144:	000ac617          	auipc	a2,0xac
ffffffffc0206148:	72460613          	addi	a2,a2,1828 # ffffffffc02b2868 <proc_list>
        le = last;
ffffffffc020614c:	87b6                	mv	a5,a3
    struct proc_struct *next = NULL;
ffffffffc020614e:	4581                	li	a1,0
        do {
            if ((le = list_next(le)) != &proc_list) {
                next = le2proc(le, list_link);
                if (next->state == PROC_RUNNABLE) {
ffffffffc0206150:	4809                	li	a6,2
ffffffffc0206152:	679c                	ld	a5,8(a5)
            if ((le = list_next(le)) != &proc_list) {
ffffffffc0206154:	00c78863          	beq	a5,a2,ffffffffc0206164 <schedule+0x4c>
                if (next->state == PROC_RUNNABLE) {
ffffffffc0206158:	f387a703          	lw	a4,-200(a5)
                next = le2proc(le, list_link);
ffffffffc020615c:	f3878593          	addi	a1,a5,-200
                if (next->state == PROC_RUNNABLE) {
ffffffffc0206160:	03070163          	beq	a4,a6,ffffffffc0206182 <schedule+0x6a>
                    break;
                }
            }
        } while (le != last);
ffffffffc0206164:	fef697e3          	bne	a3,a5,ffffffffc0206152 <schedule+0x3a>
        if (next == NULL || next->state != PROC_RUNNABLE) {
ffffffffc0206168:	ed89                	bnez	a1,ffffffffc0206182 <schedule+0x6a>
            next = idleproc;
        }
        next->runs ++;
ffffffffc020616a:	451c                	lw	a5,8(a0)
ffffffffc020616c:	2785                	addiw	a5,a5,1
ffffffffc020616e:	c51c                	sw	a5,8(a0)
        if (next != current) {
ffffffffc0206170:	00a88463          	beq	a7,a0,ffffffffc0206178 <schedule+0x60>
            proc_run(next);
ffffffffc0206174:	e63fe0ef          	jal	ra,ffffffffc0204fd6 <proc_run>
    if (flag) {
ffffffffc0206178:	e819                	bnez	s0,ffffffffc020618e <schedule+0x76>
        }
    }
    local_intr_restore(intr_flag);
}
ffffffffc020617a:	60a2                	ld	ra,8(sp)
ffffffffc020617c:	6402                	ld	s0,0(sp)
ffffffffc020617e:	0141                	addi	sp,sp,16
ffffffffc0206180:	8082                	ret
        if (next == NULL || next->state != PROC_RUNNABLE) {
ffffffffc0206182:	4198                	lw	a4,0(a1)
ffffffffc0206184:	4789                	li	a5,2
ffffffffc0206186:	fef712e3          	bne	a4,a5,ffffffffc020616a <schedule+0x52>
ffffffffc020618a:	852e                	mv	a0,a1
ffffffffc020618c:	bff9                	j	ffffffffc020616a <schedule+0x52>
}
ffffffffc020618e:	6402                	ld	s0,0(sp)
ffffffffc0206190:	60a2                	ld	ra,8(sp)
ffffffffc0206192:	0141                	addi	sp,sp,16
        intr_enable();
ffffffffc0206194:	cacfa06f          	j	ffffffffc0200640 <intr_enable>
        last = (current == idleproc) ? &proc_list : &(current->list_link);
ffffffffc0206198:	000ac617          	auipc	a2,0xac
ffffffffc020619c:	6d060613          	addi	a2,a2,1744 # ffffffffc02b2868 <proc_list>
ffffffffc02061a0:	86b2                	mv	a3,a2
ffffffffc02061a2:	b76d                	j	ffffffffc020614c <schedule+0x34>
        intr_disable();
ffffffffc02061a4:	ca2fa0ef          	jal	ra,ffffffffc0200646 <intr_disable>
        return 1;
ffffffffc02061a8:	4405                	li	s0,1
ffffffffc02061aa:	bfbd                	j	ffffffffc0206128 <schedule+0x10>

ffffffffc02061ac <sys_getpid>:
    return do_kill(pid);
}

static int
sys_getpid(uint64_t arg[]) {
    return current->pid;
ffffffffc02061ac:	000ac797          	auipc	a5,0xac
ffffffffc02061b0:	7447b783          	ld	a5,1860(a5) # ffffffffc02b28f0 <current>
}
ffffffffc02061b4:	43c8                	lw	a0,4(a5)
ffffffffc02061b6:	8082                	ret

ffffffffc02061b8 <sys_pgdir>:

static int
sys_pgdir(uint64_t arg[]) {
    //print_pgdir();
    return 0;
}
ffffffffc02061b8:	4501                	li	a0,0
ffffffffc02061ba:	8082                	ret

ffffffffc02061bc <sys_putc>:
    cputchar(c);
ffffffffc02061bc:	4108                	lw	a0,0(a0)
sys_putc(uint64_t arg[]) {
ffffffffc02061be:	1141                	addi	sp,sp,-16
ffffffffc02061c0:	e406                	sd	ra,8(sp)
    cputchar(c);
ffffffffc02061c2:	ff5f90ef          	jal	ra,ffffffffc02001b6 <cputchar>
}
ffffffffc02061c6:	60a2                	ld	ra,8(sp)
ffffffffc02061c8:	4501                	li	a0,0
ffffffffc02061ca:	0141                	addi	sp,sp,16
ffffffffc02061cc:	8082                	ret

ffffffffc02061ce <sys_kill>:
    return do_kill(pid);
ffffffffc02061ce:	4108                	lw	a0,0(a0)
ffffffffc02061d0:	c31ff06f          	j	ffffffffc0205e00 <do_kill>

ffffffffc02061d4 <sys_yield>:
    return do_yield();
ffffffffc02061d4:	bdfff06f          	j	ffffffffc0205db2 <do_yield>

ffffffffc02061d8 <sys_exec>:
    return do_execve(name, len, binary, size);
ffffffffc02061d8:	6d14                	ld	a3,24(a0)
ffffffffc02061da:	6910                	ld	a2,16(a0)
ffffffffc02061dc:	650c                	ld	a1,8(a0)
ffffffffc02061de:	6108                	ld	a0,0(a0)
ffffffffc02061e0:	ebeff06f          	j	ffffffffc020589e <do_execve>

ffffffffc02061e4 <sys_wait>:
    return do_wait(pid, store);
ffffffffc02061e4:	650c                	ld	a1,8(a0)
ffffffffc02061e6:	4108                	lw	a0,0(a0)
ffffffffc02061e8:	bdbff06f          	j	ffffffffc0205dc2 <do_wait>

ffffffffc02061ec <sys_fork>:
    struct trapframe *tf = current->tf;
ffffffffc02061ec:	000ac797          	auipc	a5,0xac
ffffffffc02061f0:	7047b783          	ld	a5,1796(a5) # ffffffffc02b28f0 <current>
ffffffffc02061f4:	73d0                	ld	a2,160(a5)
    return do_fork(0, stack, tf);
ffffffffc02061f6:	4501                	li	a0,0
ffffffffc02061f8:	6a0c                	ld	a1,16(a2)
ffffffffc02061fa:	e4bfe06f          	j	ffffffffc0205044 <do_fork>

ffffffffc02061fe <sys_exit>:
    return do_exit(error_code);
ffffffffc02061fe:	4108                	lw	a0,0(a0)
ffffffffc0206200:	a5eff06f          	j	ffffffffc020545e <do_exit>

ffffffffc0206204 <syscall>:
};

#define NUM_SYSCALLS        ((sizeof(syscalls)) / (sizeof(syscalls[0])))

void
syscall(void) {
ffffffffc0206204:	715d                	addi	sp,sp,-80
ffffffffc0206206:	fc26                	sd	s1,56(sp)
    struct trapframe *tf = current->tf;
ffffffffc0206208:	000ac497          	auipc	s1,0xac
ffffffffc020620c:	6e848493          	addi	s1,s1,1768 # ffffffffc02b28f0 <current>
ffffffffc0206210:	6098                	ld	a4,0(s1)
syscall(void) {
ffffffffc0206212:	e0a2                	sd	s0,64(sp)
ffffffffc0206214:	f84a                	sd	s2,48(sp)
    struct trapframe *tf = current->tf;
ffffffffc0206216:	7340                	ld	s0,160(a4)
syscall(void) {
ffffffffc0206218:	e486                	sd	ra,72(sp)
    uint64_t arg[5];
    int num = tf->gpr.a0;
    if (num >= 0 && num < NUM_SYSCALLS) {
ffffffffc020621a:	47fd                	li	a5,31
    int num = tf->gpr.a0;
ffffffffc020621c:	05042903          	lw	s2,80(s0)
    if (num >= 0 && num < NUM_SYSCALLS) {
ffffffffc0206220:	0327ee63          	bltu	a5,s2,ffffffffc020625c <syscall+0x58>
        if (syscalls[num] != NULL) {
ffffffffc0206224:	00391713          	slli	a4,s2,0x3
ffffffffc0206228:	00003797          	auipc	a5,0x3
ffffffffc020622c:	80878793          	addi	a5,a5,-2040 # ffffffffc0208a30 <syscalls>
ffffffffc0206230:	97ba                	add	a5,a5,a4
ffffffffc0206232:	639c                	ld	a5,0(a5)
ffffffffc0206234:	c785                	beqz	a5,ffffffffc020625c <syscall+0x58>
            arg[0] = tf->gpr.a1;
ffffffffc0206236:	6c28                	ld	a0,88(s0)
            arg[1] = tf->gpr.a2;
ffffffffc0206238:	702c                	ld	a1,96(s0)
            arg[2] = tf->gpr.a3;
ffffffffc020623a:	7430                	ld	a2,104(s0)
            arg[3] = tf->gpr.a4;
ffffffffc020623c:	7834                	ld	a3,112(s0)
            arg[4] = tf->gpr.a5;
ffffffffc020623e:	7c38                	ld	a4,120(s0)
            arg[0] = tf->gpr.a1;
ffffffffc0206240:	e42a                	sd	a0,8(sp)
            arg[1] = tf->gpr.a2;
ffffffffc0206242:	e82e                	sd	a1,16(sp)
            arg[2] = tf->gpr.a3;
ffffffffc0206244:	ec32                	sd	a2,24(sp)
            arg[3] = tf->gpr.a4;
ffffffffc0206246:	f036                	sd	a3,32(sp)
            arg[4] = tf->gpr.a5;
ffffffffc0206248:	f43a                	sd	a4,40(sp)
            tf->gpr.a0 = syscalls[num](arg);
ffffffffc020624a:	0028                	addi	a0,sp,8
ffffffffc020624c:	9782                	jalr	a5
        }
    }
    print_trapframe(tf);
    panic("undefined syscall %d, pid = %d, name = %s.\n",
            num, current->pid, current->name);
}
ffffffffc020624e:	60a6                	ld	ra,72(sp)
            tf->gpr.a0 = syscalls[num](arg);
ffffffffc0206250:	e828                	sd	a0,80(s0)
}
ffffffffc0206252:	6406                	ld	s0,64(sp)
ffffffffc0206254:	74e2                	ld	s1,56(sp)
ffffffffc0206256:	7942                	ld	s2,48(sp)
ffffffffc0206258:	6161                	addi	sp,sp,80
ffffffffc020625a:	8082                	ret
    print_trapframe(tf);
ffffffffc020625c:	8522                	mv	a0,s0
ffffffffc020625e:	dd6fa0ef          	jal	ra,ffffffffc0200834 <print_trapframe>
    panic("undefined syscall %d, pid = %d, name = %s.\n",
ffffffffc0206262:	609c                	ld	a5,0(s1)
ffffffffc0206264:	86ca                	mv	a3,s2
ffffffffc0206266:	00002617          	auipc	a2,0x2
ffffffffc020626a:	78260613          	addi	a2,a2,1922 # ffffffffc02089e8 <default_pmm_manager+0x1568>
ffffffffc020626e:	43d8                	lw	a4,4(a5)
ffffffffc0206270:	06200593          	li	a1,98
ffffffffc0206274:	0b478793          	addi	a5,a5,180
ffffffffc0206278:	00002517          	auipc	a0,0x2
ffffffffc020627c:	7a050513          	addi	a0,a0,1952 # ffffffffc0208a18 <default_pmm_manager+0x1598>
ffffffffc0206280:	9fafa0ef          	jal	ra,ffffffffc020047a <__panic>

ffffffffc0206284 <hash32>:
 *
 * High bits are more random, so we use them.
 * */
uint32_t
hash32(uint32_t val, unsigned int bits) {
    uint32_t hash = val * GOLDEN_RATIO_PRIME_32;
ffffffffc0206284:	9e3707b7          	lui	a5,0x9e370
ffffffffc0206288:	2785                	addiw	a5,a5,1
ffffffffc020628a:	02a7853b          	mulw	a0,a5,a0
    return (hash >> (32 - bits));
ffffffffc020628e:	02000793          	li	a5,32
ffffffffc0206292:	9f8d                	subw	a5,a5,a1
}
ffffffffc0206294:	00f5553b          	srlw	a0,a0,a5
ffffffffc0206298:	8082                	ret

ffffffffc020629a <printnum>:
 * */
static void
printnum(void (*putch)(int, void*), void *putdat,
        unsigned long long num, unsigned base, int width, int padc) {
    unsigned long long result = num;
    unsigned mod = do_div(result, base);
ffffffffc020629a:	02069813          	slli	a6,a3,0x20
        unsigned long long num, unsigned base, int width, int padc) {
ffffffffc020629e:	7179                	addi	sp,sp,-48
    unsigned mod = do_div(result, base);
ffffffffc02062a0:	02085813          	srli	a6,a6,0x20
        unsigned long long num, unsigned base, int width, int padc) {
ffffffffc02062a4:	e052                	sd	s4,0(sp)
    unsigned mod = do_div(result, base);
ffffffffc02062a6:	03067a33          	remu	s4,a2,a6
        unsigned long long num, unsigned base, int width, int padc) {
ffffffffc02062aa:	f022                	sd	s0,32(sp)
ffffffffc02062ac:	ec26                	sd	s1,24(sp)
ffffffffc02062ae:	e84a                	sd	s2,16(sp)
ffffffffc02062b0:	f406                	sd	ra,40(sp)
ffffffffc02062b2:	e44e                	sd	s3,8(sp)
ffffffffc02062b4:	84aa                	mv	s1,a0
ffffffffc02062b6:	892e                	mv	s2,a1
    // first recursively print all preceding (more significant) digits
    if (num >= base) {
        printnum(putch, putdat, result, base, width - 1, padc);
    } else {
        // print any needed pad characters before first digit
        while (-- width > 0)
ffffffffc02062b8:	fff7041b          	addiw	s0,a4,-1
    unsigned mod = do_div(result, base);
ffffffffc02062bc:	2a01                	sext.w	s4,s4
    if (num >= base) {
ffffffffc02062be:	03067e63          	bgeu	a2,a6,ffffffffc02062fa <printnum+0x60>
ffffffffc02062c2:	89be                	mv	s3,a5
        while (-- width > 0)
ffffffffc02062c4:	00805763          	blez	s0,ffffffffc02062d2 <printnum+0x38>
ffffffffc02062c8:	347d                	addiw	s0,s0,-1
            putch(padc, putdat);
ffffffffc02062ca:	85ca                	mv	a1,s2
ffffffffc02062cc:	854e                	mv	a0,s3
ffffffffc02062ce:	9482                	jalr	s1
        while (-- width > 0)
ffffffffc02062d0:	fc65                	bnez	s0,ffffffffc02062c8 <printnum+0x2e>
    }
    // then print this (the least significant) digit
    putch("0123456789abcdef"[mod], putdat);
ffffffffc02062d2:	1a02                	slli	s4,s4,0x20
ffffffffc02062d4:	00003797          	auipc	a5,0x3
ffffffffc02062d8:	85c78793          	addi	a5,a5,-1956 # ffffffffc0208b30 <syscalls+0x100>
ffffffffc02062dc:	020a5a13          	srli	s4,s4,0x20
ffffffffc02062e0:	9a3e                	add	s4,s4,a5
    // Crashes if num >= base. No idea what going on here
    // Here is a quick fix
    // update: Stack grows downward and destory the SBI
    // sbi_console_putchar("0123456789abcdef"[mod]);
    // (*(int *)putdat)++;
}
ffffffffc02062e2:	7402                	ld	s0,32(sp)
    putch("0123456789abcdef"[mod], putdat);
ffffffffc02062e4:	000a4503          	lbu	a0,0(s4)
}
ffffffffc02062e8:	70a2                	ld	ra,40(sp)
ffffffffc02062ea:	69a2                	ld	s3,8(sp)
ffffffffc02062ec:	6a02                	ld	s4,0(sp)
    putch("0123456789abcdef"[mod], putdat);
ffffffffc02062ee:	85ca                	mv	a1,s2
ffffffffc02062f0:	87a6                	mv	a5,s1
}
ffffffffc02062f2:	6942                	ld	s2,16(sp)
ffffffffc02062f4:	64e2                	ld	s1,24(sp)
ffffffffc02062f6:	6145                	addi	sp,sp,48
    putch("0123456789abcdef"[mod], putdat);
ffffffffc02062f8:	8782                	jr	a5
        printnum(putch, putdat, result, base, width - 1, padc);
ffffffffc02062fa:	03065633          	divu	a2,a2,a6
ffffffffc02062fe:	8722                	mv	a4,s0
ffffffffc0206300:	f9bff0ef          	jal	ra,ffffffffc020629a <printnum>
ffffffffc0206304:	b7f9                	j	ffffffffc02062d2 <printnum+0x38>

ffffffffc0206306 <vprintfmt>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want printfmt() instead.
 * */
void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap) {
ffffffffc0206306:	7119                	addi	sp,sp,-128
ffffffffc0206308:	f4a6                	sd	s1,104(sp)
ffffffffc020630a:	f0ca                	sd	s2,96(sp)
ffffffffc020630c:	ecce                	sd	s3,88(sp)
ffffffffc020630e:	e8d2                	sd	s4,80(sp)
ffffffffc0206310:	e4d6                	sd	s5,72(sp)
ffffffffc0206312:	e0da                	sd	s6,64(sp)
ffffffffc0206314:	fc5e                	sd	s7,56(sp)
ffffffffc0206316:	f06a                	sd	s10,32(sp)
ffffffffc0206318:	fc86                	sd	ra,120(sp)
ffffffffc020631a:	f8a2                	sd	s0,112(sp)
ffffffffc020631c:	f862                	sd	s8,48(sp)
ffffffffc020631e:	f466                	sd	s9,40(sp)
ffffffffc0206320:	ec6e                	sd	s11,24(sp)
ffffffffc0206322:	892a                	mv	s2,a0
ffffffffc0206324:	84ae                	mv	s1,a1
ffffffffc0206326:	8d32                	mv	s10,a2
ffffffffc0206328:	8a36                	mv	s4,a3
    register int ch, err;
    unsigned long long num;
    int base, width, precision, lflag, altflag;

    while (1) {
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc020632a:	02500993          	li	s3,37
            putch(ch, putdat);
        }

        // Process a %-escape sequence
        char padc = ' ';
        width = precision = -1;
ffffffffc020632e:	5b7d                	li	s6,-1
ffffffffc0206330:	00003a97          	auipc	s5,0x3
ffffffffc0206334:	82ca8a93          	addi	s5,s5,-2004 # ffffffffc0208b5c <syscalls+0x12c>
        case 'e':
            err = va_arg(ap, int);
            if (err < 0) {
                err = -err;
            }
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
ffffffffc0206338:	00003b97          	auipc	s7,0x3
ffffffffc020633c:	a40b8b93          	addi	s7,s7,-1472 # ffffffffc0208d78 <error_string>
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc0206340:	000d4503          	lbu	a0,0(s10)
ffffffffc0206344:	001d0413          	addi	s0,s10,1
ffffffffc0206348:	01350a63          	beq	a0,s3,ffffffffc020635c <vprintfmt+0x56>
            if (ch == '\0') {
ffffffffc020634c:	c121                	beqz	a0,ffffffffc020638c <vprintfmt+0x86>
            putch(ch, putdat);
ffffffffc020634e:	85a6                	mv	a1,s1
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc0206350:	0405                	addi	s0,s0,1
            putch(ch, putdat);
ffffffffc0206352:	9902                	jalr	s2
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc0206354:	fff44503          	lbu	a0,-1(s0)
ffffffffc0206358:	ff351ae3          	bne	a0,s3,ffffffffc020634c <vprintfmt+0x46>
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc020635c:	00044603          	lbu	a2,0(s0)
        char padc = ' ';
ffffffffc0206360:	02000793          	li	a5,32
        lflag = altflag = 0;
ffffffffc0206364:	4c81                	li	s9,0
ffffffffc0206366:	4881                	li	a7,0
        width = precision = -1;
ffffffffc0206368:	5c7d                	li	s8,-1
ffffffffc020636a:	5dfd                	li	s11,-1
ffffffffc020636c:	05500513          	li	a0,85
                if (ch < '0' || ch > '9') {
ffffffffc0206370:	4825                	li	a6,9
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0206372:	fdd6059b          	addiw	a1,a2,-35
ffffffffc0206376:	0ff5f593          	zext.b	a1,a1
ffffffffc020637a:	00140d13          	addi	s10,s0,1
ffffffffc020637e:	04b56263          	bltu	a0,a1,ffffffffc02063c2 <vprintfmt+0xbc>
ffffffffc0206382:	058a                	slli	a1,a1,0x2
ffffffffc0206384:	95d6                	add	a1,a1,s5
ffffffffc0206386:	4194                	lw	a3,0(a1)
ffffffffc0206388:	96d6                	add	a3,a3,s5
ffffffffc020638a:	8682                	jr	a3
            for (fmt --; fmt[-1] != '%'; fmt --)
                /* do nothing */;
            break;
        }
    }
}
ffffffffc020638c:	70e6                	ld	ra,120(sp)
ffffffffc020638e:	7446                	ld	s0,112(sp)
ffffffffc0206390:	74a6                	ld	s1,104(sp)
ffffffffc0206392:	7906                	ld	s2,96(sp)
ffffffffc0206394:	69e6                	ld	s3,88(sp)
ffffffffc0206396:	6a46                	ld	s4,80(sp)
ffffffffc0206398:	6aa6                	ld	s5,72(sp)
ffffffffc020639a:	6b06                	ld	s6,64(sp)
ffffffffc020639c:	7be2                	ld	s7,56(sp)
ffffffffc020639e:	7c42                	ld	s8,48(sp)
ffffffffc02063a0:	7ca2                	ld	s9,40(sp)
ffffffffc02063a2:	7d02                	ld	s10,32(sp)
ffffffffc02063a4:	6de2                	ld	s11,24(sp)
ffffffffc02063a6:	6109                	addi	sp,sp,128
ffffffffc02063a8:	8082                	ret
            padc = '0';
ffffffffc02063aa:	87b2                	mv	a5,a2
            goto reswitch;
ffffffffc02063ac:	00144603          	lbu	a2,1(s0)
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc02063b0:	846a                	mv	s0,s10
ffffffffc02063b2:	00140d13          	addi	s10,s0,1
ffffffffc02063b6:	fdd6059b          	addiw	a1,a2,-35
ffffffffc02063ba:	0ff5f593          	zext.b	a1,a1
ffffffffc02063be:	fcb572e3          	bgeu	a0,a1,ffffffffc0206382 <vprintfmt+0x7c>
            putch('%', putdat);
ffffffffc02063c2:	85a6                	mv	a1,s1
ffffffffc02063c4:	02500513          	li	a0,37
ffffffffc02063c8:	9902                	jalr	s2
            for (fmt --; fmt[-1] != '%'; fmt --)
ffffffffc02063ca:	fff44783          	lbu	a5,-1(s0)
ffffffffc02063ce:	8d22                	mv	s10,s0
ffffffffc02063d0:	f73788e3          	beq	a5,s3,ffffffffc0206340 <vprintfmt+0x3a>
ffffffffc02063d4:	ffed4783          	lbu	a5,-2(s10)
ffffffffc02063d8:	1d7d                	addi	s10,s10,-1
ffffffffc02063da:	ff379de3          	bne	a5,s3,ffffffffc02063d4 <vprintfmt+0xce>
ffffffffc02063de:	b78d                	j	ffffffffc0206340 <vprintfmt+0x3a>
                precision = precision * 10 + ch - '0';
ffffffffc02063e0:	fd060c1b          	addiw	s8,a2,-48
                ch = *fmt;
ffffffffc02063e4:	00144603          	lbu	a2,1(s0)
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc02063e8:	846a                	mv	s0,s10
                if (ch < '0' || ch > '9') {
ffffffffc02063ea:	fd06069b          	addiw	a3,a2,-48
                ch = *fmt;
ffffffffc02063ee:	0006059b          	sext.w	a1,a2
                if (ch < '0' || ch > '9') {
ffffffffc02063f2:	02d86463          	bltu	a6,a3,ffffffffc020641a <vprintfmt+0x114>
                ch = *fmt;
ffffffffc02063f6:	00144603          	lbu	a2,1(s0)
                precision = precision * 10 + ch - '0';
ffffffffc02063fa:	002c169b          	slliw	a3,s8,0x2
ffffffffc02063fe:	0186873b          	addw	a4,a3,s8
ffffffffc0206402:	0017171b          	slliw	a4,a4,0x1
ffffffffc0206406:	9f2d                	addw	a4,a4,a1
                if (ch < '0' || ch > '9') {
ffffffffc0206408:	fd06069b          	addiw	a3,a2,-48
            for (precision = 0; ; ++ fmt) {
ffffffffc020640c:	0405                	addi	s0,s0,1
                precision = precision * 10 + ch - '0';
ffffffffc020640e:	fd070c1b          	addiw	s8,a4,-48
                ch = *fmt;
ffffffffc0206412:	0006059b          	sext.w	a1,a2
                if (ch < '0' || ch > '9') {
ffffffffc0206416:	fed870e3          	bgeu	a6,a3,ffffffffc02063f6 <vprintfmt+0xf0>
            if (width < 0)
ffffffffc020641a:	f40ddce3          	bgez	s11,ffffffffc0206372 <vprintfmt+0x6c>
                width = precision, precision = -1;
ffffffffc020641e:	8de2                	mv	s11,s8
ffffffffc0206420:	5c7d                	li	s8,-1
ffffffffc0206422:	bf81                	j	ffffffffc0206372 <vprintfmt+0x6c>
            if (width < 0)
ffffffffc0206424:	fffdc693          	not	a3,s11
ffffffffc0206428:	96fd                	srai	a3,a3,0x3f
ffffffffc020642a:	00ddfdb3          	and	s11,s11,a3
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc020642e:	00144603          	lbu	a2,1(s0)
ffffffffc0206432:	2d81                	sext.w	s11,s11
ffffffffc0206434:	846a                	mv	s0,s10
            goto reswitch;
ffffffffc0206436:	bf35                	j	ffffffffc0206372 <vprintfmt+0x6c>
            precision = va_arg(ap, int);
ffffffffc0206438:	000a2c03          	lw	s8,0(s4)
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc020643c:	00144603          	lbu	a2,1(s0)
            precision = va_arg(ap, int);
ffffffffc0206440:	0a21                	addi	s4,s4,8
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0206442:	846a                	mv	s0,s10
            goto process_precision;
ffffffffc0206444:	bfd9                	j	ffffffffc020641a <vprintfmt+0x114>
    if (lflag >= 2) {
ffffffffc0206446:	4705                	li	a4,1
            precision = va_arg(ap, int);
ffffffffc0206448:	008a0593          	addi	a1,s4,8
    if (lflag >= 2) {
ffffffffc020644c:	01174463          	blt	a4,a7,ffffffffc0206454 <vprintfmt+0x14e>
    else if (lflag) {
ffffffffc0206450:	1a088e63          	beqz	a7,ffffffffc020660c <vprintfmt+0x306>
        return va_arg(*ap, unsigned long);
ffffffffc0206454:	000a3603          	ld	a2,0(s4)
ffffffffc0206458:	46c1                	li	a3,16
ffffffffc020645a:	8a2e                	mv	s4,a1
            printnum(putch, putdat, num, base, width, padc);
ffffffffc020645c:	2781                	sext.w	a5,a5
ffffffffc020645e:	876e                	mv	a4,s11
ffffffffc0206460:	85a6                	mv	a1,s1
ffffffffc0206462:	854a                	mv	a0,s2
ffffffffc0206464:	e37ff0ef          	jal	ra,ffffffffc020629a <printnum>
            break;
ffffffffc0206468:	bde1                	j	ffffffffc0206340 <vprintfmt+0x3a>
            putch(va_arg(ap, int), putdat);
ffffffffc020646a:	000a2503          	lw	a0,0(s4)
ffffffffc020646e:	85a6                	mv	a1,s1
ffffffffc0206470:	0a21                	addi	s4,s4,8
ffffffffc0206472:	9902                	jalr	s2
            break;
ffffffffc0206474:	b5f1                	j	ffffffffc0206340 <vprintfmt+0x3a>
    if (lflag >= 2) {
ffffffffc0206476:	4705                	li	a4,1
            precision = va_arg(ap, int);
ffffffffc0206478:	008a0593          	addi	a1,s4,8
    if (lflag >= 2) {
ffffffffc020647c:	01174463          	blt	a4,a7,ffffffffc0206484 <vprintfmt+0x17e>
    else if (lflag) {
ffffffffc0206480:	18088163          	beqz	a7,ffffffffc0206602 <vprintfmt+0x2fc>
        return va_arg(*ap, unsigned long);
ffffffffc0206484:	000a3603          	ld	a2,0(s4)
ffffffffc0206488:	46a9                	li	a3,10
ffffffffc020648a:	8a2e                	mv	s4,a1
ffffffffc020648c:	bfc1                	j	ffffffffc020645c <vprintfmt+0x156>
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc020648e:	00144603          	lbu	a2,1(s0)
            altflag = 1;
ffffffffc0206492:	4c85                	li	s9,1
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0206494:	846a                	mv	s0,s10
            goto reswitch;
ffffffffc0206496:	bdf1                	j	ffffffffc0206372 <vprintfmt+0x6c>
            putch(ch, putdat);
ffffffffc0206498:	85a6                	mv	a1,s1
ffffffffc020649a:	02500513          	li	a0,37
ffffffffc020649e:	9902                	jalr	s2
            break;
ffffffffc02064a0:	b545                	j	ffffffffc0206340 <vprintfmt+0x3a>
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc02064a2:	00144603          	lbu	a2,1(s0)
            lflag ++;
ffffffffc02064a6:	2885                	addiw	a7,a7,1
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc02064a8:	846a                	mv	s0,s10
            goto reswitch;
ffffffffc02064aa:	b5e1                	j	ffffffffc0206372 <vprintfmt+0x6c>
    if (lflag >= 2) {
ffffffffc02064ac:	4705                	li	a4,1
            precision = va_arg(ap, int);
ffffffffc02064ae:	008a0593          	addi	a1,s4,8
    if (lflag >= 2) {
ffffffffc02064b2:	01174463          	blt	a4,a7,ffffffffc02064ba <vprintfmt+0x1b4>
    else if (lflag) {
ffffffffc02064b6:	14088163          	beqz	a7,ffffffffc02065f8 <vprintfmt+0x2f2>
        return va_arg(*ap, unsigned long);
ffffffffc02064ba:	000a3603          	ld	a2,0(s4)
ffffffffc02064be:	46a1                	li	a3,8
ffffffffc02064c0:	8a2e                	mv	s4,a1
ffffffffc02064c2:	bf69                	j	ffffffffc020645c <vprintfmt+0x156>
            putch('0', putdat);
ffffffffc02064c4:	03000513          	li	a0,48
ffffffffc02064c8:	85a6                	mv	a1,s1
ffffffffc02064ca:	e03e                	sd	a5,0(sp)
ffffffffc02064cc:	9902                	jalr	s2
            putch('x', putdat);
ffffffffc02064ce:	85a6                	mv	a1,s1
ffffffffc02064d0:	07800513          	li	a0,120
ffffffffc02064d4:	9902                	jalr	s2
            num = (unsigned long long)(uintptr_t)va_arg(ap, void *);
ffffffffc02064d6:	0a21                	addi	s4,s4,8
            goto number;
ffffffffc02064d8:	6782                	ld	a5,0(sp)
ffffffffc02064da:	46c1                	li	a3,16
            num = (unsigned long long)(uintptr_t)va_arg(ap, void *);
ffffffffc02064dc:	ff8a3603          	ld	a2,-8(s4)
            goto number;
ffffffffc02064e0:	bfb5                	j	ffffffffc020645c <vprintfmt+0x156>
            if ((p = va_arg(ap, char *)) == NULL) {
ffffffffc02064e2:	000a3403          	ld	s0,0(s4)
ffffffffc02064e6:	008a0713          	addi	a4,s4,8
ffffffffc02064ea:	e03a                	sd	a4,0(sp)
ffffffffc02064ec:	14040263          	beqz	s0,ffffffffc0206630 <vprintfmt+0x32a>
            if (width > 0 && padc != '-') {
ffffffffc02064f0:	0fb05763          	blez	s11,ffffffffc02065de <vprintfmt+0x2d8>
ffffffffc02064f4:	02d00693          	li	a3,45
ffffffffc02064f8:	0cd79163          	bne	a5,a3,ffffffffc02065ba <vprintfmt+0x2b4>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc02064fc:	00044783          	lbu	a5,0(s0)
ffffffffc0206500:	0007851b          	sext.w	a0,a5
ffffffffc0206504:	cf85                	beqz	a5,ffffffffc020653c <vprintfmt+0x236>
ffffffffc0206506:	00140a13          	addi	s4,s0,1
                if (altflag && (ch < ' ' || ch > '~')) {
ffffffffc020650a:	05e00413          	li	s0,94
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc020650e:	000c4563          	bltz	s8,ffffffffc0206518 <vprintfmt+0x212>
ffffffffc0206512:	3c7d                	addiw	s8,s8,-1
ffffffffc0206514:	036c0263          	beq	s8,s6,ffffffffc0206538 <vprintfmt+0x232>
                    putch('?', putdat);
ffffffffc0206518:	85a6                	mv	a1,s1
                if (altflag && (ch < ' ' || ch > '~')) {
ffffffffc020651a:	0e0c8e63          	beqz	s9,ffffffffc0206616 <vprintfmt+0x310>
ffffffffc020651e:	3781                	addiw	a5,a5,-32
ffffffffc0206520:	0ef47b63          	bgeu	s0,a5,ffffffffc0206616 <vprintfmt+0x310>
                    putch('?', putdat);
ffffffffc0206524:	03f00513          	li	a0,63
ffffffffc0206528:	9902                	jalr	s2
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc020652a:	000a4783          	lbu	a5,0(s4)
ffffffffc020652e:	3dfd                	addiw	s11,s11,-1
ffffffffc0206530:	0a05                	addi	s4,s4,1
ffffffffc0206532:	0007851b          	sext.w	a0,a5
ffffffffc0206536:	ffe1                	bnez	a5,ffffffffc020650e <vprintfmt+0x208>
            for (; width > 0; width --) {
ffffffffc0206538:	01b05963          	blez	s11,ffffffffc020654a <vprintfmt+0x244>
ffffffffc020653c:	3dfd                	addiw	s11,s11,-1
                putch(' ', putdat);
ffffffffc020653e:	85a6                	mv	a1,s1
ffffffffc0206540:	02000513          	li	a0,32
ffffffffc0206544:	9902                	jalr	s2
            for (; width > 0; width --) {
ffffffffc0206546:	fe0d9be3          	bnez	s11,ffffffffc020653c <vprintfmt+0x236>
            if ((p = va_arg(ap, char *)) == NULL) {
ffffffffc020654a:	6a02                	ld	s4,0(sp)
ffffffffc020654c:	bbd5                	j	ffffffffc0206340 <vprintfmt+0x3a>
    if (lflag >= 2) {
ffffffffc020654e:	4705                	li	a4,1
            precision = va_arg(ap, int);
ffffffffc0206550:	008a0c93          	addi	s9,s4,8
    if (lflag >= 2) {
ffffffffc0206554:	01174463          	blt	a4,a7,ffffffffc020655c <vprintfmt+0x256>
    else if (lflag) {
ffffffffc0206558:	08088d63          	beqz	a7,ffffffffc02065f2 <vprintfmt+0x2ec>
        return va_arg(*ap, long);
ffffffffc020655c:	000a3403          	ld	s0,0(s4)
            if ((long long)num < 0) {
ffffffffc0206560:	0a044d63          	bltz	s0,ffffffffc020661a <vprintfmt+0x314>
            num = getint(&ap, lflag);
ffffffffc0206564:	8622                	mv	a2,s0
ffffffffc0206566:	8a66                	mv	s4,s9
ffffffffc0206568:	46a9                	li	a3,10
ffffffffc020656a:	bdcd                	j	ffffffffc020645c <vprintfmt+0x156>
            err = va_arg(ap, int);
ffffffffc020656c:	000a2783          	lw	a5,0(s4)
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
ffffffffc0206570:	4761                	li	a4,24
            err = va_arg(ap, int);
ffffffffc0206572:	0a21                	addi	s4,s4,8
            if (err < 0) {
ffffffffc0206574:	41f7d69b          	sraiw	a3,a5,0x1f
ffffffffc0206578:	8fb5                	xor	a5,a5,a3
ffffffffc020657a:	40d786bb          	subw	a3,a5,a3
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
ffffffffc020657e:	02d74163          	blt	a4,a3,ffffffffc02065a0 <vprintfmt+0x29a>
ffffffffc0206582:	00369793          	slli	a5,a3,0x3
ffffffffc0206586:	97de                	add	a5,a5,s7
ffffffffc0206588:	639c                	ld	a5,0(a5)
ffffffffc020658a:	cb99                	beqz	a5,ffffffffc02065a0 <vprintfmt+0x29a>
                printfmt(putch, putdat, "%s", p);
ffffffffc020658c:	86be                	mv	a3,a5
ffffffffc020658e:	00000617          	auipc	a2,0x0
ffffffffc0206592:	1ca60613          	addi	a2,a2,458 # ffffffffc0206758 <etext+0x2a>
ffffffffc0206596:	85a6                	mv	a1,s1
ffffffffc0206598:	854a                	mv	a0,s2
ffffffffc020659a:	0ce000ef          	jal	ra,ffffffffc0206668 <printfmt>
ffffffffc020659e:	b34d                	j	ffffffffc0206340 <vprintfmt+0x3a>
                printfmt(putch, putdat, "error %d", err);
ffffffffc02065a0:	00002617          	auipc	a2,0x2
ffffffffc02065a4:	5b060613          	addi	a2,a2,1456 # ffffffffc0208b50 <syscalls+0x120>
ffffffffc02065a8:	85a6                	mv	a1,s1
ffffffffc02065aa:	854a                	mv	a0,s2
ffffffffc02065ac:	0bc000ef          	jal	ra,ffffffffc0206668 <printfmt>
ffffffffc02065b0:	bb41                	j	ffffffffc0206340 <vprintfmt+0x3a>
                p = "(null)";
ffffffffc02065b2:	00002417          	auipc	s0,0x2
ffffffffc02065b6:	59640413          	addi	s0,s0,1430 # ffffffffc0208b48 <syscalls+0x118>
                for (width -= strnlen(p, precision); width > 0; width --) {
ffffffffc02065ba:	85e2                	mv	a1,s8
ffffffffc02065bc:	8522                	mv	a0,s0
ffffffffc02065be:	e43e                	sd	a5,8(sp)
ffffffffc02065c0:	0e2000ef          	jal	ra,ffffffffc02066a2 <strnlen>
ffffffffc02065c4:	40ad8dbb          	subw	s11,s11,a0
ffffffffc02065c8:	01b05b63          	blez	s11,ffffffffc02065de <vprintfmt+0x2d8>
                    putch(padc, putdat);
ffffffffc02065cc:	67a2                	ld	a5,8(sp)
ffffffffc02065ce:	00078a1b          	sext.w	s4,a5
                for (width -= strnlen(p, precision); width > 0; width --) {
ffffffffc02065d2:	3dfd                	addiw	s11,s11,-1
                    putch(padc, putdat);
ffffffffc02065d4:	85a6                	mv	a1,s1
ffffffffc02065d6:	8552                	mv	a0,s4
ffffffffc02065d8:	9902                	jalr	s2
                for (width -= strnlen(p, precision); width > 0; width --) {
ffffffffc02065da:	fe0d9ce3          	bnez	s11,ffffffffc02065d2 <vprintfmt+0x2cc>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc02065de:	00044783          	lbu	a5,0(s0)
ffffffffc02065e2:	00140a13          	addi	s4,s0,1
ffffffffc02065e6:	0007851b          	sext.w	a0,a5
ffffffffc02065ea:	d3a5                	beqz	a5,ffffffffc020654a <vprintfmt+0x244>
                if (altflag && (ch < ' ' || ch > '~')) {
ffffffffc02065ec:	05e00413          	li	s0,94
ffffffffc02065f0:	bf39                	j	ffffffffc020650e <vprintfmt+0x208>
        return va_arg(*ap, int);
ffffffffc02065f2:	000a2403          	lw	s0,0(s4)
ffffffffc02065f6:	b7ad                	j	ffffffffc0206560 <vprintfmt+0x25a>
        return va_arg(*ap, unsigned int);
ffffffffc02065f8:	000a6603          	lwu	a2,0(s4)
ffffffffc02065fc:	46a1                	li	a3,8
ffffffffc02065fe:	8a2e                	mv	s4,a1
ffffffffc0206600:	bdb1                	j	ffffffffc020645c <vprintfmt+0x156>
ffffffffc0206602:	000a6603          	lwu	a2,0(s4)
ffffffffc0206606:	46a9                	li	a3,10
ffffffffc0206608:	8a2e                	mv	s4,a1
ffffffffc020660a:	bd89                	j	ffffffffc020645c <vprintfmt+0x156>
ffffffffc020660c:	000a6603          	lwu	a2,0(s4)
ffffffffc0206610:	46c1                	li	a3,16
ffffffffc0206612:	8a2e                	mv	s4,a1
ffffffffc0206614:	b5a1                	j	ffffffffc020645c <vprintfmt+0x156>
                    putch(ch, putdat);
ffffffffc0206616:	9902                	jalr	s2
ffffffffc0206618:	bf09                	j	ffffffffc020652a <vprintfmt+0x224>
                putch('-', putdat);
ffffffffc020661a:	85a6                	mv	a1,s1
ffffffffc020661c:	02d00513          	li	a0,45
ffffffffc0206620:	e03e                	sd	a5,0(sp)
ffffffffc0206622:	9902                	jalr	s2
                num = -(long long)num;
ffffffffc0206624:	6782                	ld	a5,0(sp)
ffffffffc0206626:	8a66                	mv	s4,s9
ffffffffc0206628:	40800633          	neg	a2,s0
ffffffffc020662c:	46a9                	li	a3,10
ffffffffc020662e:	b53d                	j	ffffffffc020645c <vprintfmt+0x156>
            if (width > 0 && padc != '-') {
ffffffffc0206630:	03b05163          	blez	s11,ffffffffc0206652 <vprintfmt+0x34c>
ffffffffc0206634:	02d00693          	li	a3,45
ffffffffc0206638:	f6d79de3          	bne	a5,a3,ffffffffc02065b2 <vprintfmt+0x2ac>
                p = "(null)";
ffffffffc020663c:	00002417          	auipc	s0,0x2
ffffffffc0206640:	50c40413          	addi	s0,s0,1292 # ffffffffc0208b48 <syscalls+0x118>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc0206644:	02800793          	li	a5,40
ffffffffc0206648:	02800513          	li	a0,40
ffffffffc020664c:	00140a13          	addi	s4,s0,1
ffffffffc0206650:	bd6d                	j	ffffffffc020650a <vprintfmt+0x204>
ffffffffc0206652:	00002a17          	auipc	s4,0x2
ffffffffc0206656:	4f7a0a13          	addi	s4,s4,1271 # ffffffffc0208b49 <syscalls+0x119>
ffffffffc020665a:	02800513          	li	a0,40
ffffffffc020665e:	02800793          	li	a5,40
                if (altflag && (ch < ' ' || ch > '~')) {
ffffffffc0206662:	05e00413          	li	s0,94
ffffffffc0206666:	b565                	j	ffffffffc020650e <vprintfmt+0x208>

ffffffffc0206668 <printfmt>:
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
ffffffffc0206668:	715d                	addi	sp,sp,-80
    va_start(ap, fmt);
ffffffffc020666a:	02810313          	addi	t1,sp,40
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
ffffffffc020666e:	f436                	sd	a3,40(sp)
    vprintfmt(putch, putdat, fmt, ap);
ffffffffc0206670:	869a                	mv	a3,t1
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
ffffffffc0206672:	ec06                	sd	ra,24(sp)
ffffffffc0206674:	f83a                	sd	a4,48(sp)
ffffffffc0206676:	fc3e                	sd	a5,56(sp)
ffffffffc0206678:	e0c2                	sd	a6,64(sp)
ffffffffc020667a:	e4c6                	sd	a7,72(sp)
    va_start(ap, fmt);
ffffffffc020667c:	e41a                	sd	t1,8(sp)
    vprintfmt(putch, putdat, fmt, ap);
ffffffffc020667e:	c89ff0ef          	jal	ra,ffffffffc0206306 <vprintfmt>
}
ffffffffc0206682:	60e2                	ld	ra,24(sp)
ffffffffc0206684:	6161                	addi	sp,sp,80
ffffffffc0206686:	8082                	ret

ffffffffc0206688 <strlen>:
 * The strlen() function returns the length of string @s.
 * */
size_t
strlen(const char *s) {
    size_t cnt = 0;
    while (*s ++ != '\0') {
ffffffffc0206688:	00054783          	lbu	a5,0(a0)
strlen(const char *s) {
ffffffffc020668c:	872a                	mv	a4,a0
    size_t cnt = 0;
ffffffffc020668e:	4501                	li	a0,0
    while (*s ++ != '\0') {
ffffffffc0206690:	cb81                	beqz	a5,ffffffffc02066a0 <strlen+0x18>
        cnt ++;
ffffffffc0206692:	0505                	addi	a0,a0,1
    while (*s ++ != '\0') {
ffffffffc0206694:	00a707b3          	add	a5,a4,a0
ffffffffc0206698:	0007c783          	lbu	a5,0(a5)
ffffffffc020669c:	fbfd                	bnez	a5,ffffffffc0206692 <strlen+0xa>
ffffffffc020669e:	8082                	ret
    }
    return cnt;
}
ffffffffc02066a0:	8082                	ret

ffffffffc02066a2 <strnlen>:
 * @len if there is no '\0' character among the first @len characters
 * pointed by @s.
 * */
size_t
strnlen(const char *s, size_t len) {
    size_t cnt = 0;
ffffffffc02066a2:	4781                	li	a5,0
    while (cnt < len && *s ++ != '\0') {
ffffffffc02066a4:	e589                	bnez	a1,ffffffffc02066ae <strnlen+0xc>
ffffffffc02066a6:	a811                	j	ffffffffc02066ba <strnlen+0x18>
        cnt ++;
ffffffffc02066a8:	0785                	addi	a5,a5,1
    while (cnt < len && *s ++ != '\0') {
ffffffffc02066aa:	00f58863          	beq	a1,a5,ffffffffc02066ba <strnlen+0x18>
ffffffffc02066ae:	00f50733          	add	a4,a0,a5
ffffffffc02066b2:	00074703          	lbu	a4,0(a4)
ffffffffc02066b6:	fb6d                	bnez	a4,ffffffffc02066a8 <strnlen+0x6>
ffffffffc02066b8:	85be                	mv	a1,a5
    }
    return cnt;
}
ffffffffc02066ba:	852e                	mv	a0,a1
ffffffffc02066bc:	8082                	ret

ffffffffc02066be <strcpy>:
char *
strcpy(char *dst, const char *src) {
#ifdef __HAVE_ARCH_STRCPY
    return __strcpy(dst, src);
#else
    char *p = dst;
ffffffffc02066be:	87aa                	mv	a5,a0
    while ((*p ++ = *src ++) != '\0')
ffffffffc02066c0:	0005c703          	lbu	a4,0(a1)
ffffffffc02066c4:	0785                	addi	a5,a5,1
ffffffffc02066c6:	0585                	addi	a1,a1,1
ffffffffc02066c8:	fee78fa3          	sb	a4,-1(a5)
ffffffffc02066cc:	fb75                	bnez	a4,ffffffffc02066c0 <strcpy+0x2>
        /* nothing */;
    return dst;
#endif /* __HAVE_ARCH_STRCPY */
}
ffffffffc02066ce:	8082                	ret

ffffffffc02066d0 <strcmp>:
int
strcmp(const char *s1, const char *s2) {
#ifdef __HAVE_ARCH_STRCMP
    return __strcmp(s1, s2);
#else
    while (*s1 != '\0' && *s1 == *s2) {
ffffffffc02066d0:	00054783          	lbu	a5,0(a0)
        s1 ++, s2 ++;
    }
    return (int)((unsigned char)*s1 - (unsigned char)*s2);
ffffffffc02066d4:	0005c703          	lbu	a4,0(a1)
    while (*s1 != '\0' && *s1 == *s2) {
ffffffffc02066d8:	cb89                	beqz	a5,ffffffffc02066ea <strcmp+0x1a>
        s1 ++, s2 ++;
ffffffffc02066da:	0505                	addi	a0,a0,1
ffffffffc02066dc:	0585                	addi	a1,a1,1
    while (*s1 != '\0' && *s1 == *s2) {
ffffffffc02066de:	fee789e3          	beq	a5,a4,ffffffffc02066d0 <strcmp>
    return (int)((unsigned char)*s1 - (unsigned char)*s2);
ffffffffc02066e2:	0007851b          	sext.w	a0,a5
#endif /* __HAVE_ARCH_STRCMP */
}
ffffffffc02066e6:	9d19                	subw	a0,a0,a4
ffffffffc02066e8:	8082                	ret
ffffffffc02066ea:	4501                	li	a0,0
ffffffffc02066ec:	bfed                	j	ffffffffc02066e6 <strcmp+0x16>

ffffffffc02066ee <strchr>:
 * The strchr() function returns a pointer to the first occurrence of
 * character in @s. If the value is not found, the function returns 'NULL'.
 * */
char *
strchr(const char *s, char c) {
    while (*s != '\0') {
ffffffffc02066ee:	00054783          	lbu	a5,0(a0)
ffffffffc02066f2:	c799                	beqz	a5,ffffffffc0206700 <strchr+0x12>
        if (*s == c) {
ffffffffc02066f4:	00f58763          	beq	a1,a5,ffffffffc0206702 <strchr+0x14>
    while (*s != '\0') {
ffffffffc02066f8:	00154783          	lbu	a5,1(a0)
            return (char *)s;
        }
        s ++;
ffffffffc02066fc:	0505                	addi	a0,a0,1
    while (*s != '\0') {
ffffffffc02066fe:	fbfd                	bnez	a5,ffffffffc02066f4 <strchr+0x6>
    }
    return NULL;
ffffffffc0206700:	4501                	li	a0,0
}
ffffffffc0206702:	8082                	ret

ffffffffc0206704 <memset>:
memset(void *s, char c, size_t n) {
#ifdef __HAVE_ARCH_MEMSET
    return __memset(s, c, n);
#else
    char *p = s;
    while (n -- > 0) {
ffffffffc0206704:	ca01                	beqz	a2,ffffffffc0206714 <memset+0x10>
ffffffffc0206706:	962a                	add	a2,a2,a0
    char *p = s;
ffffffffc0206708:	87aa                	mv	a5,a0
        *p ++ = c;
ffffffffc020670a:	0785                	addi	a5,a5,1
ffffffffc020670c:	feb78fa3          	sb	a1,-1(a5)
    while (n -- > 0) {
ffffffffc0206710:	fec79de3          	bne	a5,a2,ffffffffc020670a <memset+0x6>
    }
    return s;
#endif /* __HAVE_ARCH_MEMSET */
}
ffffffffc0206714:	8082                	ret

ffffffffc0206716 <memcpy>:
#ifdef __HAVE_ARCH_MEMCPY
    return __memcpy(dst, src, n);
#else
    const char *s = src;
    char *d = dst;
    while (n -- > 0) {
ffffffffc0206716:	ca19                	beqz	a2,ffffffffc020672c <memcpy+0x16>
ffffffffc0206718:	962e                	add	a2,a2,a1
    char *d = dst;
ffffffffc020671a:	87aa                	mv	a5,a0
        *d ++ = *s ++;
ffffffffc020671c:	0005c703          	lbu	a4,0(a1)
ffffffffc0206720:	0585                	addi	a1,a1,1
ffffffffc0206722:	0785                	addi	a5,a5,1
ffffffffc0206724:	fee78fa3          	sb	a4,-1(a5)
    while (n -- > 0) {
ffffffffc0206728:	fec59ae3          	bne	a1,a2,ffffffffc020671c <memcpy+0x6>
    }
    return dst;
#endif /* __HAVE_ARCH_MEMCPY */
}
ffffffffc020672c:	8082                	ret
