
bin/kernel:     file format elf64-littleriscv


Disassembly of section .text:

ffffffffc0200000 <kern_entry>:

    .section .text,"ax",%progbits
    .globl kern_entry
kern_entry:
    # t0 := 三级页表的虚拟地址
    lui     t0, %hi(boot_page_table_sv39)
ffffffffc0200000:	c02052b7          	lui	t0,0xc0205
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
ffffffffc0200024:	c0205137          	lui	sp,0xc0205

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


int kern_init(void) {
    extern char edata[], end[];
    memset(edata, 0, end - edata);
ffffffffc0200032:	00006517          	auipc	a0,0x6
ffffffffc0200036:	fe650513          	addi	a0,a0,-26 # ffffffffc0206018 <free_area>
ffffffffc020003a:	00006617          	auipc	a2,0x6
ffffffffc020003e:	44660613          	addi	a2,a2,1094 # ffffffffc0206480 <end>
int kern_init(void) {
ffffffffc0200042:	1141                	addi	sp,sp,-16
    memset(edata, 0, end - edata);
ffffffffc0200044:	8e09                	sub	a2,a2,a0
ffffffffc0200046:	4581                	li	a1,0
int kern_init(void) {
ffffffffc0200048:	e406                	sd	ra,8(sp)
    memset(edata, 0, end - edata);
ffffffffc020004a:	189010ef          	jal	ra,ffffffffc02019d2 <memset>
    cons_init();  // init the console
ffffffffc020004e:	3fc000ef          	jal	ra,ffffffffc020044a <cons_init>
    const char *message = "(THU.CST) os is loading ...\0";
    //cprintf("%s\n\n", message);
    cputs(message);
ffffffffc0200052:	00002517          	auipc	a0,0x2
ffffffffc0200056:	99650513          	addi	a0,a0,-1642 # ffffffffc02019e8 <etext+0x4>
ffffffffc020005a:	090000ef          	jal	ra,ffffffffc02000ea <cputs>

    print_kerninfo();
ffffffffc020005e:	0dc000ef          	jal	ra,ffffffffc020013a <print_kerninfo>

    // grade_backtrace();
    idt_init();  // init interrupt descriptor table
ffffffffc0200062:	402000ef          	jal	ra,ffffffffc0200464 <idt_init>

    pmm_init();  // init physical memory management
ffffffffc0200066:	27c010ef          	jal	ra,ffffffffc02012e2 <pmm_init>

    idt_init();  // init interrupt descriptor table
ffffffffc020006a:	3fa000ef          	jal	ra,ffffffffc0200464 <idt_init>

    clock_init();   // init clock interrupt
ffffffffc020006e:	39a000ef          	jal	ra,ffffffffc0200408 <clock_init>
    intr_enable();  // enable irq interrupt
ffffffffc0200072:	3e6000ef          	jal	ra,ffffffffc0200458 <intr_enable>



    /* do nothing */
    while (1)
ffffffffc0200076:	a001                	j	ffffffffc0200076 <kern_init+0x44>

ffffffffc0200078 <cputch>:
/* *
 * cputch - writes a single character @c to stdout, and it will
 * increace the value of counter pointed by @cnt.
 * */
static void
cputch(int c, int *cnt) {
ffffffffc0200078:	1141                	addi	sp,sp,-16
ffffffffc020007a:	e022                	sd	s0,0(sp)
ffffffffc020007c:	e406                	sd	ra,8(sp)
ffffffffc020007e:	842e                	mv	s0,a1
    cons_putc(c);
ffffffffc0200080:	3cc000ef          	jal	ra,ffffffffc020044c <cons_putc>
    (*cnt) ++;
ffffffffc0200084:	401c                	lw	a5,0(s0)
}
ffffffffc0200086:	60a2                	ld	ra,8(sp)
    (*cnt) ++;
ffffffffc0200088:	2785                	addiw	a5,a5,1
ffffffffc020008a:	c01c                	sw	a5,0(s0)
}
ffffffffc020008c:	6402                	ld	s0,0(sp)
ffffffffc020008e:	0141                	addi	sp,sp,16
ffffffffc0200090:	8082                	ret

ffffffffc0200092 <vcprintf>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want cprintf() instead.
 * */
int
vcprintf(const char *fmt, va_list ap) {
ffffffffc0200092:	1101                	addi	sp,sp,-32
ffffffffc0200094:	862a                	mv	a2,a0
ffffffffc0200096:	86ae                	mv	a3,a1
    int cnt = 0;
    vprintfmt((void*)cputch, &cnt, fmt, ap);
ffffffffc0200098:	00000517          	auipc	a0,0x0
ffffffffc020009c:	fe050513          	addi	a0,a0,-32 # ffffffffc0200078 <cputch>
ffffffffc02000a0:	006c                	addi	a1,sp,12
vcprintf(const char *fmt, va_list ap) {
ffffffffc02000a2:	ec06                	sd	ra,24(sp)
    int cnt = 0;
ffffffffc02000a4:	c602                	sw	zero,12(sp)
    vprintfmt((void*)cputch, &cnt, fmt, ap);
ffffffffc02000a6:	43c010ef          	jal	ra,ffffffffc02014e2 <vprintfmt>
    return cnt;
}
ffffffffc02000aa:	60e2                	ld	ra,24(sp)
ffffffffc02000ac:	4532                	lw	a0,12(sp)
ffffffffc02000ae:	6105                	addi	sp,sp,32
ffffffffc02000b0:	8082                	ret

ffffffffc02000b2 <cprintf>:
 *
 * The return value is the number of characters which would be
 * written to stdout.
 * */
int
cprintf(const char *fmt, ...) {
ffffffffc02000b2:	711d                	addi	sp,sp,-96
    va_list ap;
    int cnt;
    va_start(ap, fmt);
ffffffffc02000b4:	02810313          	addi	t1,sp,40 # ffffffffc0205028 <boot_page_table_sv39+0x28>
cprintf(const char *fmt, ...) {
ffffffffc02000b8:	8e2a                	mv	t3,a0
ffffffffc02000ba:	f42e                	sd	a1,40(sp)
ffffffffc02000bc:	f832                	sd	a2,48(sp)
ffffffffc02000be:	fc36                	sd	a3,56(sp)
    vprintfmt((void*)cputch, &cnt, fmt, ap);
ffffffffc02000c0:	00000517          	auipc	a0,0x0
ffffffffc02000c4:	fb850513          	addi	a0,a0,-72 # ffffffffc0200078 <cputch>
ffffffffc02000c8:	004c                	addi	a1,sp,4
ffffffffc02000ca:	869a                	mv	a3,t1
ffffffffc02000cc:	8672                	mv	a2,t3
cprintf(const char *fmt, ...) {
ffffffffc02000ce:	ec06                	sd	ra,24(sp)
ffffffffc02000d0:	e0ba                	sd	a4,64(sp)
ffffffffc02000d2:	e4be                	sd	a5,72(sp)
ffffffffc02000d4:	e8c2                	sd	a6,80(sp)
ffffffffc02000d6:	ecc6                	sd	a7,88(sp)
    va_start(ap, fmt);
ffffffffc02000d8:	e41a                	sd	t1,8(sp)
    int cnt = 0;
ffffffffc02000da:	c202                	sw	zero,4(sp)
    vprintfmt((void*)cputch, &cnt, fmt, ap);
ffffffffc02000dc:	406010ef          	jal	ra,ffffffffc02014e2 <vprintfmt>
    cnt = vcprintf(fmt, ap);
    va_end(ap);
    return cnt;
}
ffffffffc02000e0:	60e2                	ld	ra,24(sp)
ffffffffc02000e2:	4512                	lw	a0,4(sp)
ffffffffc02000e4:	6125                	addi	sp,sp,96
ffffffffc02000e6:	8082                	ret

ffffffffc02000e8 <cputchar>:

/* cputchar - writes a single character to stdout */
void
cputchar(int c) {
    cons_putc(c);
ffffffffc02000e8:	a695                	j	ffffffffc020044c <cons_putc>

ffffffffc02000ea <cputs>:
/* *
 * cputs- writes the string pointed by @str to stdout and
 * appends a newline character.
 * */
int
cputs(const char *str) {
ffffffffc02000ea:	1101                	addi	sp,sp,-32
ffffffffc02000ec:	e822                	sd	s0,16(sp)
ffffffffc02000ee:	ec06                	sd	ra,24(sp)
ffffffffc02000f0:	e426                	sd	s1,8(sp)
ffffffffc02000f2:	842a                	mv	s0,a0
    int cnt = 0;
    char c;
    while ((c = *str ++) != '\0') {
ffffffffc02000f4:	00054503          	lbu	a0,0(a0)
ffffffffc02000f8:	c51d                	beqz	a0,ffffffffc0200126 <cputs+0x3c>
ffffffffc02000fa:	0405                	addi	s0,s0,1
ffffffffc02000fc:	4485                	li	s1,1
ffffffffc02000fe:	9c81                	subw	s1,s1,s0
    cons_putc(c);
ffffffffc0200100:	34c000ef          	jal	ra,ffffffffc020044c <cons_putc>
    while ((c = *str ++) != '\0') {
ffffffffc0200104:	00044503          	lbu	a0,0(s0)
ffffffffc0200108:	008487bb          	addw	a5,s1,s0
ffffffffc020010c:	0405                	addi	s0,s0,1
ffffffffc020010e:	f96d                	bnez	a0,ffffffffc0200100 <cputs+0x16>
    (*cnt) ++;
ffffffffc0200110:	0017841b          	addiw	s0,a5,1
    cons_putc(c);
ffffffffc0200114:	4529                	li	a0,10
ffffffffc0200116:	336000ef          	jal	ra,ffffffffc020044c <cons_putc>
        cputch(c, &cnt);
    }
    cputch('\n', &cnt);
    return cnt;
}
ffffffffc020011a:	60e2                	ld	ra,24(sp)
ffffffffc020011c:	8522                	mv	a0,s0
ffffffffc020011e:	6442                	ld	s0,16(sp)
ffffffffc0200120:	64a2                	ld	s1,8(sp)
ffffffffc0200122:	6105                	addi	sp,sp,32
ffffffffc0200124:	8082                	ret
    while ((c = *str ++) != '\0') {
ffffffffc0200126:	4405                	li	s0,1
ffffffffc0200128:	b7f5                	j	ffffffffc0200114 <cputs+0x2a>

ffffffffc020012a <getchar>:

/* getchar - reads a single non-zero character from stdin */
int
getchar(void) {
ffffffffc020012a:	1141                	addi	sp,sp,-16
ffffffffc020012c:	e406                	sd	ra,8(sp)
    int c;
    while ((c = cons_getc()) == 0)
ffffffffc020012e:	326000ef          	jal	ra,ffffffffc0200454 <cons_getc>
ffffffffc0200132:	dd75                	beqz	a0,ffffffffc020012e <getchar+0x4>
        /* do nothing */;
    return c;
}
ffffffffc0200134:	60a2                	ld	ra,8(sp)
ffffffffc0200136:	0141                	addi	sp,sp,16
ffffffffc0200138:	8082                	ret

ffffffffc020013a <print_kerninfo>:
/* *
 * print_kerninfo - print the information about kernel, including the location
 * of kernel entry, the start addresses of data and text segements, the start
 * address of free memory and how many memory that kernel has used.
 * */
void print_kerninfo(void) {
ffffffffc020013a:	1141                	addi	sp,sp,-16
    extern char etext[], edata[], end[], kern_init[];
    cprintf("Special kernel symbols:\n");
ffffffffc020013c:	00002517          	auipc	a0,0x2
ffffffffc0200140:	8cc50513          	addi	a0,a0,-1844 # ffffffffc0201a08 <etext+0x24>
void print_kerninfo(void) {
ffffffffc0200144:	e406                	sd	ra,8(sp)
    cprintf("Special kernel symbols:\n");
ffffffffc0200146:	f6dff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  entry  0x%016lx (virtual)\n", kern_init);
ffffffffc020014a:	00000597          	auipc	a1,0x0
ffffffffc020014e:	ee858593          	addi	a1,a1,-280 # ffffffffc0200032 <kern_init>
ffffffffc0200152:	00002517          	auipc	a0,0x2
ffffffffc0200156:	8d650513          	addi	a0,a0,-1834 # ffffffffc0201a28 <etext+0x44>
ffffffffc020015a:	f59ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  etext  0x%016lx (virtual)\n", etext);
ffffffffc020015e:	00002597          	auipc	a1,0x2
ffffffffc0200162:	88658593          	addi	a1,a1,-1914 # ffffffffc02019e4 <etext>
ffffffffc0200166:	00002517          	auipc	a0,0x2
ffffffffc020016a:	8e250513          	addi	a0,a0,-1822 # ffffffffc0201a48 <etext+0x64>
ffffffffc020016e:	f45ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  edata  0x%016lx (virtual)\n", edata);
ffffffffc0200172:	00006597          	auipc	a1,0x6
ffffffffc0200176:	ea658593          	addi	a1,a1,-346 # ffffffffc0206018 <free_area>
ffffffffc020017a:	00002517          	auipc	a0,0x2
ffffffffc020017e:	8ee50513          	addi	a0,a0,-1810 # ffffffffc0201a68 <etext+0x84>
ffffffffc0200182:	f31ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  end    0x%016lx (virtual)\n", end);
ffffffffc0200186:	00006597          	auipc	a1,0x6
ffffffffc020018a:	2fa58593          	addi	a1,a1,762 # ffffffffc0206480 <end>
ffffffffc020018e:	00002517          	auipc	a0,0x2
ffffffffc0200192:	8fa50513          	addi	a0,a0,-1798 # ffffffffc0201a88 <etext+0xa4>
ffffffffc0200196:	f1dff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("Kernel executable memory footprint: %dKB\n",
            (end - kern_init + 1023) / 1024);
ffffffffc020019a:	00006597          	auipc	a1,0x6
ffffffffc020019e:	6e558593          	addi	a1,a1,1765 # ffffffffc020687f <end+0x3ff>
ffffffffc02001a2:	00000797          	auipc	a5,0x0
ffffffffc02001a6:	e9078793          	addi	a5,a5,-368 # ffffffffc0200032 <kern_init>
ffffffffc02001aa:	40f587b3          	sub	a5,a1,a5
    cprintf("Kernel executable memory footprint: %dKB\n",
ffffffffc02001ae:	43f7d593          	srai	a1,a5,0x3f
}
ffffffffc02001b2:	60a2                	ld	ra,8(sp)
    cprintf("Kernel executable memory footprint: %dKB\n",
ffffffffc02001b4:	3ff5f593          	andi	a1,a1,1023
ffffffffc02001b8:	95be                	add	a1,a1,a5
ffffffffc02001ba:	85a9                	srai	a1,a1,0xa
ffffffffc02001bc:	00002517          	auipc	a0,0x2
ffffffffc02001c0:	8ec50513          	addi	a0,a0,-1812 # ffffffffc0201aa8 <etext+0xc4>
}
ffffffffc02001c4:	0141                	addi	sp,sp,16
    cprintf("Kernel executable memory footprint: %dKB\n",
ffffffffc02001c6:	b5f5                	j	ffffffffc02000b2 <cprintf>

ffffffffc02001c8 <print_stackframe>:
 * Note that, the length of ebp-chain is limited. In boot/bootasm.S, before
 * jumping
 * to the kernel entry, the value of ebp has been set to zero, that's the
 * boundary.
 * */
void print_stackframe(void) {
ffffffffc02001c8:	1141                	addi	sp,sp,-16

    panic("Not Implemented!");
ffffffffc02001ca:	00002617          	auipc	a2,0x2
ffffffffc02001ce:	90e60613          	addi	a2,a2,-1778 # ffffffffc0201ad8 <etext+0xf4>
ffffffffc02001d2:	04e00593          	li	a1,78
ffffffffc02001d6:	00002517          	auipc	a0,0x2
ffffffffc02001da:	91a50513          	addi	a0,a0,-1766 # ffffffffc0201af0 <etext+0x10c>
void print_stackframe(void) {
ffffffffc02001de:	e406                	sd	ra,8(sp)
    panic("Not Implemented!");
ffffffffc02001e0:	1cc000ef          	jal	ra,ffffffffc02003ac <__panic>

ffffffffc02001e4 <mon_help>:
    }
}

/* mon_help - print the information about mon_* functions */
int
mon_help(int argc, char **argv, struct trapframe *tf) {
ffffffffc02001e4:	1141                	addi	sp,sp,-16
    int i;
    for (i = 0; i < NCOMMANDS; i ++) {
        cprintf("%s - %s\n", commands[i].name, commands[i].desc);
ffffffffc02001e6:	00002617          	auipc	a2,0x2
ffffffffc02001ea:	92260613          	addi	a2,a2,-1758 # ffffffffc0201b08 <etext+0x124>
ffffffffc02001ee:	00002597          	auipc	a1,0x2
ffffffffc02001f2:	93a58593          	addi	a1,a1,-1734 # ffffffffc0201b28 <etext+0x144>
ffffffffc02001f6:	00002517          	auipc	a0,0x2
ffffffffc02001fa:	93a50513          	addi	a0,a0,-1734 # ffffffffc0201b30 <etext+0x14c>
mon_help(int argc, char **argv, struct trapframe *tf) {
ffffffffc02001fe:	e406                	sd	ra,8(sp)
        cprintf("%s - %s\n", commands[i].name, commands[i].desc);
ffffffffc0200200:	eb3ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
ffffffffc0200204:	00002617          	auipc	a2,0x2
ffffffffc0200208:	93c60613          	addi	a2,a2,-1732 # ffffffffc0201b40 <etext+0x15c>
ffffffffc020020c:	00002597          	auipc	a1,0x2
ffffffffc0200210:	95c58593          	addi	a1,a1,-1700 # ffffffffc0201b68 <etext+0x184>
ffffffffc0200214:	00002517          	auipc	a0,0x2
ffffffffc0200218:	91c50513          	addi	a0,a0,-1764 # ffffffffc0201b30 <etext+0x14c>
ffffffffc020021c:	e97ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
ffffffffc0200220:	00002617          	auipc	a2,0x2
ffffffffc0200224:	95860613          	addi	a2,a2,-1704 # ffffffffc0201b78 <etext+0x194>
ffffffffc0200228:	00002597          	auipc	a1,0x2
ffffffffc020022c:	97058593          	addi	a1,a1,-1680 # ffffffffc0201b98 <etext+0x1b4>
ffffffffc0200230:	00002517          	auipc	a0,0x2
ffffffffc0200234:	90050513          	addi	a0,a0,-1792 # ffffffffc0201b30 <etext+0x14c>
ffffffffc0200238:	e7bff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    }
    return 0;
}
ffffffffc020023c:	60a2                	ld	ra,8(sp)
ffffffffc020023e:	4501                	li	a0,0
ffffffffc0200240:	0141                	addi	sp,sp,16
ffffffffc0200242:	8082                	ret

ffffffffc0200244 <mon_kerninfo>:
/* *
 * mon_kerninfo - call print_kerninfo in kern/debug/kdebug.c to
 * print the memory occupancy in kernel.
 * */
int
mon_kerninfo(int argc, char **argv, struct trapframe *tf) {
ffffffffc0200244:	1141                	addi	sp,sp,-16
ffffffffc0200246:	e406                	sd	ra,8(sp)
    print_kerninfo();
ffffffffc0200248:	ef3ff0ef          	jal	ra,ffffffffc020013a <print_kerninfo>
    return 0;
}
ffffffffc020024c:	60a2                	ld	ra,8(sp)
ffffffffc020024e:	4501                	li	a0,0
ffffffffc0200250:	0141                	addi	sp,sp,16
ffffffffc0200252:	8082                	ret

ffffffffc0200254 <mon_backtrace>:
/* *
 * mon_backtrace - call print_stackframe in kern/debug/kdebug.c to
 * print a backtrace of the stack.
 * */
int
mon_backtrace(int argc, char **argv, struct trapframe *tf) {
ffffffffc0200254:	1141                	addi	sp,sp,-16
ffffffffc0200256:	e406                	sd	ra,8(sp)
    print_stackframe();
ffffffffc0200258:	f71ff0ef          	jal	ra,ffffffffc02001c8 <print_stackframe>
    return 0;
}
ffffffffc020025c:	60a2                	ld	ra,8(sp)
ffffffffc020025e:	4501                	li	a0,0
ffffffffc0200260:	0141                	addi	sp,sp,16
ffffffffc0200262:	8082                	ret

ffffffffc0200264 <kmonitor>:
kmonitor(struct trapframe *tf) {
ffffffffc0200264:	7115                	addi	sp,sp,-224
ffffffffc0200266:	ed5e                	sd	s7,152(sp)
ffffffffc0200268:	8baa                	mv	s7,a0
    cprintf("Welcome to the kernel debug monitor!!\n");
ffffffffc020026a:	00002517          	auipc	a0,0x2
ffffffffc020026e:	93e50513          	addi	a0,a0,-1730 # ffffffffc0201ba8 <etext+0x1c4>
kmonitor(struct trapframe *tf) {
ffffffffc0200272:	ed86                	sd	ra,216(sp)
ffffffffc0200274:	e9a2                	sd	s0,208(sp)
ffffffffc0200276:	e5a6                	sd	s1,200(sp)
ffffffffc0200278:	e1ca                	sd	s2,192(sp)
ffffffffc020027a:	fd4e                	sd	s3,184(sp)
ffffffffc020027c:	f952                	sd	s4,176(sp)
ffffffffc020027e:	f556                	sd	s5,168(sp)
ffffffffc0200280:	f15a                	sd	s6,160(sp)
ffffffffc0200282:	e962                	sd	s8,144(sp)
ffffffffc0200284:	e566                	sd	s9,136(sp)
ffffffffc0200286:	e16a                	sd	s10,128(sp)
    cprintf("Welcome to the kernel debug monitor!!\n");
ffffffffc0200288:	e2bff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("Type 'help' for a list of commands.\n");
ffffffffc020028c:	00002517          	auipc	a0,0x2
ffffffffc0200290:	94450513          	addi	a0,a0,-1724 # ffffffffc0201bd0 <etext+0x1ec>
ffffffffc0200294:	e1fff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    if (tf != NULL) {
ffffffffc0200298:	000b8563          	beqz	s7,ffffffffc02002a2 <kmonitor+0x3e>
        print_trapframe(tf);
ffffffffc020029c:	855e                	mv	a0,s7
ffffffffc020029e:	3a4000ef          	jal	ra,ffffffffc0200642 <print_trapframe>
ffffffffc02002a2:	00002c17          	auipc	s8,0x2
ffffffffc02002a6:	99ec0c13          	addi	s8,s8,-1634 # ffffffffc0201c40 <commands>
        if ((buf = readline("K> ")) != NULL) {
ffffffffc02002aa:	00002917          	auipc	s2,0x2
ffffffffc02002ae:	94e90913          	addi	s2,s2,-1714 # ffffffffc0201bf8 <etext+0x214>
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
ffffffffc02002b2:	00002497          	auipc	s1,0x2
ffffffffc02002b6:	94e48493          	addi	s1,s1,-1714 # ffffffffc0201c00 <etext+0x21c>
        if (argc == MAXARGS - 1) {
ffffffffc02002ba:	49bd                	li	s3,15
            cprintf("Too many arguments (max %d).\n", MAXARGS);
ffffffffc02002bc:	00002b17          	auipc	s6,0x2
ffffffffc02002c0:	94cb0b13          	addi	s6,s6,-1716 # ffffffffc0201c08 <etext+0x224>
        argv[argc ++] = buf;
ffffffffc02002c4:	00002a17          	auipc	s4,0x2
ffffffffc02002c8:	864a0a13          	addi	s4,s4,-1948 # ffffffffc0201b28 <etext+0x144>
    for (i = 0; i < NCOMMANDS; i ++) {
ffffffffc02002cc:	4a8d                	li	s5,3
        if ((buf = readline("K> ")) != NULL) {
ffffffffc02002ce:	854a                	mv	a0,s2
ffffffffc02002d0:	594010ef          	jal	ra,ffffffffc0201864 <readline>
ffffffffc02002d4:	842a                	mv	s0,a0
ffffffffc02002d6:	dd65                	beqz	a0,ffffffffc02002ce <kmonitor+0x6a>
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
ffffffffc02002d8:	00054583          	lbu	a1,0(a0)
    int argc = 0;
ffffffffc02002dc:	4c81                	li	s9,0
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
ffffffffc02002de:	e1bd                	bnez	a1,ffffffffc0200344 <kmonitor+0xe0>
    if (argc == 0) {
ffffffffc02002e0:	fe0c87e3          	beqz	s9,ffffffffc02002ce <kmonitor+0x6a>
        if (strcmp(commands[i].name, argv[0]) == 0) {
ffffffffc02002e4:	6582                	ld	a1,0(sp)
ffffffffc02002e6:	00002d17          	auipc	s10,0x2
ffffffffc02002ea:	95ad0d13          	addi	s10,s10,-1702 # ffffffffc0201c40 <commands>
        argv[argc ++] = buf;
ffffffffc02002ee:	8552                	mv	a0,s4
    for (i = 0; i < NCOMMANDS; i ++) {
ffffffffc02002f0:	4401                	li	s0,0
ffffffffc02002f2:	0d61                	addi	s10,s10,24
        if (strcmp(commands[i].name, argv[0]) == 0) {
ffffffffc02002f4:	6aa010ef          	jal	ra,ffffffffc020199e <strcmp>
ffffffffc02002f8:	c919                	beqz	a0,ffffffffc020030e <kmonitor+0xaa>
    for (i = 0; i < NCOMMANDS; i ++) {
ffffffffc02002fa:	2405                	addiw	s0,s0,1
ffffffffc02002fc:	0b540063          	beq	s0,s5,ffffffffc020039c <kmonitor+0x138>
        if (strcmp(commands[i].name, argv[0]) == 0) {
ffffffffc0200300:	000d3503          	ld	a0,0(s10)
ffffffffc0200304:	6582                	ld	a1,0(sp)
    for (i = 0; i < NCOMMANDS; i ++) {
ffffffffc0200306:	0d61                	addi	s10,s10,24
        if (strcmp(commands[i].name, argv[0]) == 0) {
ffffffffc0200308:	696010ef          	jal	ra,ffffffffc020199e <strcmp>
ffffffffc020030c:	f57d                	bnez	a0,ffffffffc02002fa <kmonitor+0x96>
            return commands[i].func(argc - 1, argv + 1, tf);
ffffffffc020030e:	00141793          	slli	a5,s0,0x1
ffffffffc0200312:	97a2                	add	a5,a5,s0
ffffffffc0200314:	078e                	slli	a5,a5,0x3
ffffffffc0200316:	97e2                	add	a5,a5,s8
ffffffffc0200318:	6b9c                	ld	a5,16(a5)
ffffffffc020031a:	865e                	mv	a2,s7
ffffffffc020031c:	002c                	addi	a1,sp,8
ffffffffc020031e:	fffc851b          	addiw	a0,s9,-1
ffffffffc0200322:	9782                	jalr	a5
            if (runcmd(buf, tf) < 0) {
ffffffffc0200324:	fa0555e3          	bgez	a0,ffffffffc02002ce <kmonitor+0x6a>
}
ffffffffc0200328:	60ee                	ld	ra,216(sp)
ffffffffc020032a:	644e                	ld	s0,208(sp)
ffffffffc020032c:	64ae                	ld	s1,200(sp)
ffffffffc020032e:	690e                	ld	s2,192(sp)
ffffffffc0200330:	79ea                	ld	s3,184(sp)
ffffffffc0200332:	7a4a                	ld	s4,176(sp)
ffffffffc0200334:	7aaa                	ld	s5,168(sp)
ffffffffc0200336:	7b0a                	ld	s6,160(sp)
ffffffffc0200338:	6bea                	ld	s7,152(sp)
ffffffffc020033a:	6c4a                	ld	s8,144(sp)
ffffffffc020033c:	6caa                	ld	s9,136(sp)
ffffffffc020033e:	6d0a                	ld	s10,128(sp)
ffffffffc0200340:	612d                	addi	sp,sp,224
ffffffffc0200342:	8082                	ret
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
ffffffffc0200344:	8526                	mv	a0,s1
ffffffffc0200346:	676010ef          	jal	ra,ffffffffc02019bc <strchr>
ffffffffc020034a:	c901                	beqz	a0,ffffffffc020035a <kmonitor+0xf6>
ffffffffc020034c:	00144583          	lbu	a1,1(s0)
            *buf ++ = '\0';
ffffffffc0200350:	00040023          	sb	zero,0(s0)
ffffffffc0200354:	0405                	addi	s0,s0,1
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
ffffffffc0200356:	d5c9                	beqz	a1,ffffffffc02002e0 <kmonitor+0x7c>
ffffffffc0200358:	b7f5                	j	ffffffffc0200344 <kmonitor+0xe0>
        if (*buf == '\0') {
ffffffffc020035a:	00044783          	lbu	a5,0(s0)
ffffffffc020035e:	d3c9                	beqz	a5,ffffffffc02002e0 <kmonitor+0x7c>
        if (argc == MAXARGS - 1) {
ffffffffc0200360:	033c8963          	beq	s9,s3,ffffffffc0200392 <kmonitor+0x12e>
        argv[argc ++] = buf;
ffffffffc0200364:	003c9793          	slli	a5,s9,0x3
ffffffffc0200368:	0118                	addi	a4,sp,128
ffffffffc020036a:	97ba                	add	a5,a5,a4
ffffffffc020036c:	f887b023          	sd	s0,-128(a5)
        while (*buf != '\0' && strchr(WHITESPACE, *buf) == NULL) {
ffffffffc0200370:	00044583          	lbu	a1,0(s0)
        argv[argc ++] = buf;
ffffffffc0200374:	2c85                	addiw	s9,s9,1
        while (*buf != '\0' && strchr(WHITESPACE, *buf) == NULL) {
ffffffffc0200376:	e591                	bnez	a1,ffffffffc0200382 <kmonitor+0x11e>
ffffffffc0200378:	b7b5                	j	ffffffffc02002e4 <kmonitor+0x80>
ffffffffc020037a:	00144583          	lbu	a1,1(s0)
            buf ++;
ffffffffc020037e:	0405                	addi	s0,s0,1
        while (*buf != '\0' && strchr(WHITESPACE, *buf) == NULL) {
ffffffffc0200380:	d1a5                	beqz	a1,ffffffffc02002e0 <kmonitor+0x7c>
ffffffffc0200382:	8526                	mv	a0,s1
ffffffffc0200384:	638010ef          	jal	ra,ffffffffc02019bc <strchr>
ffffffffc0200388:	d96d                	beqz	a0,ffffffffc020037a <kmonitor+0x116>
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
ffffffffc020038a:	00044583          	lbu	a1,0(s0)
ffffffffc020038e:	d9a9                	beqz	a1,ffffffffc02002e0 <kmonitor+0x7c>
ffffffffc0200390:	bf55                	j	ffffffffc0200344 <kmonitor+0xe0>
            cprintf("Too many arguments (max %d).\n", MAXARGS);
ffffffffc0200392:	45c1                	li	a1,16
ffffffffc0200394:	855a                	mv	a0,s6
ffffffffc0200396:	d1dff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
ffffffffc020039a:	b7e9                	j	ffffffffc0200364 <kmonitor+0x100>
    cprintf("Unknown command '%s'\n", argv[0]);
ffffffffc020039c:	6582                	ld	a1,0(sp)
ffffffffc020039e:	00002517          	auipc	a0,0x2
ffffffffc02003a2:	88a50513          	addi	a0,a0,-1910 # ffffffffc0201c28 <etext+0x244>
ffffffffc02003a6:	d0dff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    return 0;
ffffffffc02003aa:	b715                	j	ffffffffc02002ce <kmonitor+0x6a>

ffffffffc02003ac <__panic>:
 * __panic - __panic is called on unresolvable fatal errors. it prints
 * "panic: 'message'", and then enters the kernel monitor.
 * */
void
__panic(const char *file, int line, const char *fmt, ...) {
    if (is_panic) {
ffffffffc02003ac:	00006317          	auipc	t1,0x6
ffffffffc02003b0:	08430313          	addi	t1,t1,132 # ffffffffc0206430 <is_panic>
ffffffffc02003b4:	00032e03          	lw	t3,0(t1)
__panic(const char *file, int line, const char *fmt, ...) {
ffffffffc02003b8:	715d                	addi	sp,sp,-80
ffffffffc02003ba:	ec06                	sd	ra,24(sp)
ffffffffc02003bc:	e822                	sd	s0,16(sp)
ffffffffc02003be:	f436                	sd	a3,40(sp)
ffffffffc02003c0:	f83a                	sd	a4,48(sp)
ffffffffc02003c2:	fc3e                	sd	a5,56(sp)
ffffffffc02003c4:	e0c2                	sd	a6,64(sp)
ffffffffc02003c6:	e4c6                	sd	a7,72(sp)
    if (is_panic) {
ffffffffc02003c8:	020e1a63          	bnez	t3,ffffffffc02003fc <__panic+0x50>
        goto panic_dead;
    }
    is_panic = 1;
ffffffffc02003cc:	4785                	li	a5,1
ffffffffc02003ce:	00f32023          	sw	a5,0(t1)

    // print the 'message'
    va_list ap;
    va_start(ap, fmt);
ffffffffc02003d2:	8432                	mv	s0,a2
ffffffffc02003d4:	103c                	addi	a5,sp,40
    cprintf("kernel panic at %s:%d:\n    ", file, line);
ffffffffc02003d6:	862e                	mv	a2,a1
ffffffffc02003d8:	85aa                	mv	a1,a0
ffffffffc02003da:	00002517          	auipc	a0,0x2
ffffffffc02003de:	8ae50513          	addi	a0,a0,-1874 # ffffffffc0201c88 <commands+0x48>
    va_start(ap, fmt);
ffffffffc02003e2:	e43e                	sd	a5,8(sp)
    cprintf("kernel panic at %s:%d:\n    ", file, line);
ffffffffc02003e4:	ccfff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    vcprintf(fmt, ap);
ffffffffc02003e8:	65a2                	ld	a1,8(sp)
ffffffffc02003ea:	8522                	mv	a0,s0
ffffffffc02003ec:	ca7ff0ef          	jal	ra,ffffffffc0200092 <vcprintf>
    cprintf("\n");
ffffffffc02003f0:	00001517          	auipc	a0,0x1
ffffffffc02003f4:	6e050513          	addi	a0,a0,1760 # ffffffffc0201ad0 <etext+0xec>
ffffffffc02003f8:	cbbff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    va_end(ap);

panic_dead:
    intr_disable();
ffffffffc02003fc:	062000ef          	jal	ra,ffffffffc020045e <intr_disable>
    while (1) {
        kmonitor(NULL);
ffffffffc0200400:	4501                	li	a0,0
ffffffffc0200402:	e63ff0ef          	jal	ra,ffffffffc0200264 <kmonitor>
    while (1) {
ffffffffc0200406:	bfed                	j	ffffffffc0200400 <__panic+0x54>

ffffffffc0200408 <clock_init>:

/* *
 * clock_init - initialize 8253 clock to interrupt 100 times per second,
 * and then enable IRQ_TIMER.
 * */
void clock_init(void) {
ffffffffc0200408:	1141                	addi	sp,sp,-16
ffffffffc020040a:	e406                	sd	ra,8(sp)
    // enable timer interrupt in sie
    set_csr(sie, MIP_STIP);
ffffffffc020040c:	02000793          	li	a5,32
ffffffffc0200410:	1047a7f3          	csrrs	a5,sie,a5
    __asm__ __volatile__("rdtime %0" : "=r"(n));
ffffffffc0200414:	c0102573          	rdtime	a0
    ticks = 0;

    cprintf("++ setup timer interrupts\n");
}

void clock_set_next_event(void) { sbi_set_timer(get_cycles() + timebase); }
ffffffffc0200418:	67e1                	lui	a5,0x18
ffffffffc020041a:	6a078793          	addi	a5,a5,1696 # 186a0 <kern_entry-0xffffffffc01e7960>
ffffffffc020041e:	953e                	add	a0,a0,a5
ffffffffc0200420:	512010ef          	jal	ra,ffffffffc0201932 <sbi_set_timer>
}
ffffffffc0200424:	60a2                	ld	ra,8(sp)
    ticks = 0;
ffffffffc0200426:	00006797          	auipc	a5,0x6
ffffffffc020042a:	0007b923          	sd	zero,18(a5) # ffffffffc0206438 <ticks>
    cprintf("++ setup timer interrupts\n");
ffffffffc020042e:	00002517          	auipc	a0,0x2
ffffffffc0200432:	87a50513          	addi	a0,a0,-1926 # ffffffffc0201ca8 <commands+0x68>
}
ffffffffc0200436:	0141                	addi	sp,sp,16
    cprintf("++ setup timer interrupts\n");
ffffffffc0200438:	b9ad                	j	ffffffffc02000b2 <cprintf>

ffffffffc020043a <clock_set_next_event>:
    __asm__ __volatile__("rdtime %0" : "=r"(n));
ffffffffc020043a:	c0102573          	rdtime	a0
void clock_set_next_event(void) { sbi_set_timer(get_cycles() + timebase); }
ffffffffc020043e:	67e1                	lui	a5,0x18
ffffffffc0200440:	6a078793          	addi	a5,a5,1696 # 186a0 <kern_entry-0xffffffffc01e7960>
ffffffffc0200444:	953e                	add	a0,a0,a5
ffffffffc0200446:	4ec0106f          	j	ffffffffc0201932 <sbi_set_timer>

ffffffffc020044a <cons_init>:

/* serial_intr - try to feed input characters from serial port */
void serial_intr(void) {}

/* cons_init - initializes the console devices */
void cons_init(void) {}
ffffffffc020044a:	8082                	ret

ffffffffc020044c <cons_putc>:

/* cons_putc - print a single character @c to console devices */
void cons_putc(int c) { sbi_console_putchar((unsigned char)c); }
ffffffffc020044c:	0ff57513          	zext.b	a0,a0
ffffffffc0200450:	4c80106f          	j	ffffffffc0201918 <sbi_console_putchar>

ffffffffc0200454 <cons_getc>:
 * cons_getc - return the next input character from console,
 * or 0 if none waiting.
 * */
int cons_getc(void) {
    int c = 0;
    c = sbi_console_getchar();
ffffffffc0200454:	4f80106f          	j	ffffffffc020194c <sbi_console_getchar>

ffffffffc0200458 <intr_enable>:
#include <intr.h>
#include <riscv.h>

/* intr_enable - enable irq interrupt */
void intr_enable(void) { set_csr(sstatus, SSTATUS_SIE); }
ffffffffc0200458:	100167f3          	csrrsi	a5,sstatus,2
ffffffffc020045c:	8082                	ret

ffffffffc020045e <intr_disable>:

/* intr_disable - disable irq interrupt */
void intr_disable(void) { clear_csr(sstatus, SSTATUS_SIE); }
ffffffffc020045e:	100177f3          	csrrci	a5,sstatus,2
ffffffffc0200462:	8082                	ret

ffffffffc0200464 <idt_init>:
     */

    extern void __alltraps(void);
    /* Set sup0 scratch register to 0, indicating to exception vector
       that we are presently executing in the kernel */
    write_csr(sscratch, 0);
ffffffffc0200464:	14005073          	csrwi	sscratch,0
    /* Set the exception vector address */
    write_csr(stvec, &__alltraps);
ffffffffc0200468:	00000797          	auipc	a5,0x0
ffffffffc020046c:	30078793          	addi	a5,a5,768 # ffffffffc0200768 <__alltraps>
ffffffffc0200470:	10579073          	csrw	stvec,a5
}
ffffffffc0200474:	8082                	ret

ffffffffc0200476 <print_regs>:
    cprintf("  badvaddr 0x%08x\n", tf->badvaddr);
    cprintf("  cause    0x%08x\n", tf->cause);
}

void print_regs(struct pushregs *gpr) {
    cprintf("  zero     0x%08x\n", gpr->zero);
ffffffffc0200476:	610c                	ld	a1,0(a0)
void print_regs(struct pushregs *gpr) {
ffffffffc0200478:	1141                	addi	sp,sp,-16
ffffffffc020047a:	e022                	sd	s0,0(sp)
ffffffffc020047c:	842a                	mv	s0,a0
    cprintf("  zero     0x%08x\n", gpr->zero);
ffffffffc020047e:	00002517          	auipc	a0,0x2
ffffffffc0200482:	84a50513          	addi	a0,a0,-1974 # ffffffffc0201cc8 <commands+0x88>
void print_regs(struct pushregs *gpr) {
ffffffffc0200486:	e406                	sd	ra,8(sp)
    cprintf("  zero     0x%08x\n", gpr->zero);
ffffffffc0200488:	c2bff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  ra       0x%08x\n", gpr->ra);
ffffffffc020048c:	640c                	ld	a1,8(s0)
ffffffffc020048e:	00002517          	auipc	a0,0x2
ffffffffc0200492:	85250513          	addi	a0,a0,-1966 # ffffffffc0201ce0 <commands+0xa0>
ffffffffc0200496:	c1dff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  sp       0x%08x\n", gpr->sp);
ffffffffc020049a:	680c                	ld	a1,16(s0)
ffffffffc020049c:	00002517          	auipc	a0,0x2
ffffffffc02004a0:	85c50513          	addi	a0,a0,-1956 # ffffffffc0201cf8 <commands+0xb8>
ffffffffc02004a4:	c0fff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  gp       0x%08x\n", gpr->gp);
ffffffffc02004a8:	6c0c                	ld	a1,24(s0)
ffffffffc02004aa:	00002517          	auipc	a0,0x2
ffffffffc02004ae:	86650513          	addi	a0,a0,-1946 # ffffffffc0201d10 <commands+0xd0>
ffffffffc02004b2:	c01ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  tp       0x%08x\n", gpr->tp);
ffffffffc02004b6:	700c                	ld	a1,32(s0)
ffffffffc02004b8:	00002517          	auipc	a0,0x2
ffffffffc02004bc:	87050513          	addi	a0,a0,-1936 # ffffffffc0201d28 <commands+0xe8>
ffffffffc02004c0:	bf3ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  t0       0x%08x\n", gpr->t0);
ffffffffc02004c4:	740c                	ld	a1,40(s0)
ffffffffc02004c6:	00002517          	auipc	a0,0x2
ffffffffc02004ca:	87a50513          	addi	a0,a0,-1926 # ffffffffc0201d40 <commands+0x100>
ffffffffc02004ce:	be5ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  t1       0x%08x\n", gpr->t1);
ffffffffc02004d2:	780c                	ld	a1,48(s0)
ffffffffc02004d4:	00002517          	auipc	a0,0x2
ffffffffc02004d8:	88450513          	addi	a0,a0,-1916 # ffffffffc0201d58 <commands+0x118>
ffffffffc02004dc:	bd7ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  t2       0x%08x\n", gpr->t2);
ffffffffc02004e0:	7c0c                	ld	a1,56(s0)
ffffffffc02004e2:	00002517          	auipc	a0,0x2
ffffffffc02004e6:	88e50513          	addi	a0,a0,-1906 # ffffffffc0201d70 <commands+0x130>
ffffffffc02004ea:	bc9ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  s0       0x%08x\n", gpr->s0);
ffffffffc02004ee:	602c                	ld	a1,64(s0)
ffffffffc02004f0:	00002517          	auipc	a0,0x2
ffffffffc02004f4:	89850513          	addi	a0,a0,-1896 # ffffffffc0201d88 <commands+0x148>
ffffffffc02004f8:	bbbff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  s1       0x%08x\n", gpr->s1);
ffffffffc02004fc:	642c                	ld	a1,72(s0)
ffffffffc02004fe:	00002517          	auipc	a0,0x2
ffffffffc0200502:	8a250513          	addi	a0,a0,-1886 # ffffffffc0201da0 <commands+0x160>
ffffffffc0200506:	badff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  a0       0x%08x\n", gpr->a0);
ffffffffc020050a:	682c                	ld	a1,80(s0)
ffffffffc020050c:	00002517          	auipc	a0,0x2
ffffffffc0200510:	8ac50513          	addi	a0,a0,-1876 # ffffffffc0201db8 <commands+0x178>
ffffffffc0200514:	b9fff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  a1       0x%08x\n", gpr->a1);
ffffffffc0200518:	6c2c                	ld	a1,88(s0)
ffffffffc020051a:	00002517          	auipc	a0,0x2
ffffffffc020051e:	8b650513          	addi	a0,a0,-1866 # ffffffffc0201dd0 <commands+0x190>
ffffffffc0200522:	b91ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  a2       0x%08x\n", gpr->a2);
ffffffffc0200526:	702c                	ld	a1,96(s0)
ffffffffc0200528:	00002517          	auipc	a0,0x2
ffffffffc020052c:	8c050513          	addi	a0,a0,-1856 # ffffffffc0201de8 <commands+0x1a8>
ffffffffc0200530:	b83ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  a3       0x%08x\n", gpr->a3);
ffffffffc0200534:	742c                	ld	a1,104(s0)
ffffffffc0200536:	00002517          	auipc	a0,0x2
ffffffffc020053a:	8ca50513          	addi	a0,a0,-1846 # ffffffffc0201e00 <commands+0x1c0>
ffffffffc020053e:	b75ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  a4       0x%08x\n", gpr->a4);
ffffffffc0200542:	782c                	ld	a1,112(s0)
ffffffffc0200544:	00002517          	auipc	a0,0x2
ffffffffc0200548:	8d450513          	addi	a0,a0,-1836 # ffffffffc0201e18 <commands+0x1d8>
ffffffffc020054c:	b67ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  a5       0x%08x\n", gpr->a5);
ffffffffc0200550:	7c2c                	ld	a1,120(s0)
ffffffffc0200552:	00002517          	auipc	a0,0x2
ffffffffc0200556:	8de50513          	addi	a0,a0,-1826 # ffffffffc0201e30 <commands+0x1f0>
ffffffffc020055a:	b59ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  a6       0x%08x\n", gpr->a6);
ffffffffc020055e:	604c                	ld	a1,128(s0)
ffffffffc0200560:	00002517          	auipc	a0,0x2
ffffffffc0200564:	8e850513          	addi	a0,a0,-1816 # ffffffffc0201e48 <commands+0x208>
ffffffffc0200568:	b4bff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  a7       0x%08x\n", gpr->a7);
ffffffffc020056c:	644c                	ld	a1,136(s0)
ffffffffc020056e:	00002517          	auipc	a0,0x2
ffffffffc0200572:	8f250513          	addi	a0,a0,-1806 # ffffffffc0201e60 <commands+0x220>
ffffffffc0200576:	b3dff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  s2       0x%08x\n", gpr->s2);
ffffffffc020057a:	684c                	ld	a1,144(s0)
ffffffffc020057c:	00002517          	auipc	a0,0x2
ffffffffc0200580:	8fc50513          	addi	a0,a0,-1796 # ffffffffc0201e78 <commands+0x238>
ffffffffc0200584:	b2fff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  s3       0x%08x\n", gpr->s3);
ffffffffc0200588:	6c4c                	ld	a1,152(s0)
ffffffffc020058a:	00002517          	auipc	a0,0x2
ffffffffc020058e:	90650513          	addi	a0,a0,-1786 # ffffffffc0201e90 <commands+0x250>
ffffffffc0200592:	b21ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  s4       0x%08x\n", gpr->s4);
ffffffffc0200596:	704c                	ld	a1,160(s0)
ffffffffc0200598:	00002517          	auipc	a0,0x2
ffffffffc020059c:	91050513          	addi	a0,a0,-1776 # ffffffffc0201ea8 <commands+0x268>
ffffffffc02005a0:	b13ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  s5       0x%08x\n", gpr->s5);
ffffffffc02005a4:	744c                	ld	a1,168(s0)
ffffffffc02005a6:	00002517          	auipc	a0,0x2
ffffffffc02005aa:	91a50513          	addi	a0,a0,-1766 # ffffffffc0201ec0 <commands+0x280>
ffffffffc02005ae:	b05ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  s6       0x%08x\n", gpr->s6);
ffffffffc02005b2:	784c                	ld	a1,176(s0)
ffffffffc02005b4:	00002517          	auipc	a0,0x2
ffffffffc02005b8:	92450513          	addi	a0,a0,-1756 # ffffffffc0201ed8 <commands+0x298>
ffffffffc02005bc:	af7ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  s7       0x%08x\n", gpr->s7);
ffffffffc02005c0:	7c4c                	ld	a1,184(s0)
ffffffffc02005c2:	00002517          	auipc	a0,0x2
ffffffffc02005c6:	92e50513          	addi	a0,a0,-1746 # ffffffffc0201ef0 <commands+0x2b0>
ffffffffc02005ca:	ae9ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  s8       0x%08x\n", gpr->s8);
ffffffffc02005ce:	606c                	ld	a1,192(s0)
ffffffffc02005d0:	00002517          	auipc	a0,0x2
ffffffffc02005d4:	93850513          	addi	a0,a0,-1736 # ffffffffc0201f08 <commands+0x2c8>
ffffffffc02005d8:	adbff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  s9       0x%08x\n", gpr->s9);
ffffffffc02005dc:	646c                	ld	a1,200(s0)
ffffffffc02005de:	00002517          	auipc	a0,0x2
ffffffffc02005e2:	94250513          	addi	a0,a0,-1726 # ffffffffc0201f20 <commands+0x2e0>
ffffffffc02005e6:	acdff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  s10      0x%08x\n", gpr->s10);
ffffffffc02005ea:	686c                	ld	a1,208(s0)
ffffffffc02005ec:	00002517          	auipc	a0,0x2
ffffffffc02005f0:	94c50513          	addi	a0,a0,-1716 # ffffffffc0201f38 <commands+0x2f8>
ffffffffc02005f4:	abfff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  s11      0x%08x\n", gpr->s11);
ffffffffc02005f8:	6c6c                	ld	a1,216(s0)
ffffffffc02005fa:	00002517          	auipc	a0,0x2
ffffffffc02005fe:	95650513          	addi	a0,a0,-1706 # ffffffffc0201f50 <commands+0x310>
ffffffffc0200602:	ab1ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  t3       0x%08x\n", gpr->t3);
ffffffffc0200606:	706c                	ld	a1,224(s0)
ffffffffc0200608:	00002517          	auipc	a0,0x2
ffffffffc020060c:	96050513          	addi	a0,a0,-1696 # ffffffffc0201f68 <commands+0x328>
ffffffffc0200610:	aa3ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  t4       0x%08x\n", gpr->t4);
ffffffffc0200614:	746c                	ld	a1,232(s0)
ffffffffc0200616:	00002517          	auipc	a0,0x2
ffffffffc020061a:	96a50513          	addi	a0,a0,-1686 # ffffffffc0201f80 <commands+0x340>
ffffffffc020061e:	a95ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  t5       0x%08x\n", gpr->t5);
ffffffffc0200622:	786c                	ld	a1,240(s0)
ffffffffc0200624:	00002517          	auipc	a0,0x2
ffffffffc0200628:	97450513          	addi	a0,a0,-1676 # ffffffffc0201f98 <commands+0x358>
ffffffffc020062c:	a87ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  t6       0x%08x\n", gpr->t6);
ffffffffc0200630:	7c6c                	ld	a1,248(s0)
}
ffffffffc0200632:	6402                	ld	s0,0(sp)
ffffffffc0200634:	60a2                	ld	ra,8(sp)
    cprintf("  t6       0x%08x\n", gpr->t6);
ffffffffc0200636:	00002517          	auipc	a0,0x2
ffffffffc020063a:	97a50513          	addi	a0,a0,-1670 # ffffffffc0201fb0 <commands+0x370>
}
ffffffffc020063e:	0141                	addi	sp,sp,16
    cprintf("  t6       0x%08x\n", gpr->t6);
ffffffffc0200640:	bc8d                	j	ffffffffc02000b2 <cprintf>

ffffffffc0200642 <print_trapframe>:
void print_trapframe(struct trapframe *tf) {
ffffffffc0200642:	1141                	addi	sp,sp,-16
ffffffffc0200644:	e022                	sd	s0,0(sp)
    cprintf("trapframe at %p\n", tf);
ffffffffc0200646:	85aa                	mv	a1,a0
void print_trapframe(struct trapframe *tf) {
ffffffffc0200648:	842a                	mv	s0,a0
    cprintf("trapframe at %p\n", tf);
ffffffffc020064a:	00002517          	auipc	a0,0x2
ffffffffc020064e:	97e50513          	addi	a0,a0,-1666 # ffffffffc0201fc8 <commands+0x388>
void print_trapframe(struct trapframe *tf) {
ffffffffc0200652:	e406                	sd	ra,8(sp)
    cprintf("trapframe at %p\n", tf);
ffffffffc0200654:	a5fff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    print_regs(&tf->gpr);
ffffffffc0200658:	8522                	mv	a0,s0
ffffffffc020065a:	e1dff0ef          	jal	ra,ffffffffc0200476 <print_regs>
    cprintf("  status   0x%08x\n", tf->status);
ffffffffc020065e:	10043583          	ld	a1,256(s0)
ffffffffc0200662:	00002517          	auipc	a0,0x2
ffffffffc0200666:	97e50513          	addi	a0,a0,-1666 # ffffffffc0201fe0 <commands+0x3a0>
ffffffffc020066a:	a49ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  epc      0x%08x\n", tf->epc);
ffffffffc020066e:	10843583          	ld	a1,264(s0)
ffffffffc0200672:	00002517          	auipc	a0,0x2
ffffffffc0200676:	98650513          	addi	a0,a0,-1658 # ffffffffc0201ff8 <commands+0x3b8>
ffffffffc020067a:	a39ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  badvaddr 0x%08x\n", tf->badvaddr);
ffffffffc020067e:	11043583          	ld	a1,272(s0)
ffffffffc0200682:	00002517          	auipc	a0,0x2
ffffffffc0200686:	98e50513          	addi	a0,a0,-1650 # ffffffffc0202010 <commands+0x3d0>
ffffffffc020068a:	a29ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  cause    0x%08x\n", tf->cause);
ffffffffc020068e:	11843583          	ld	a1,280(s0)
}
ffffffffc0200692:	6402                	ld	s0,0(sp)
ffffffffc0200694:	60a2                	ld	ra,8(sp)
    cprintf("  cause    0x%08x\n", tf->cause);
ffffffffc0200696:	00002517          	auipc	a0,0x2
ffffffffc020069a:	99250513          	addi	a0,a0,-1646 # ffffffffc0202028 <commands+0x3e8>
}
ffffffffc020069e:	0141                	addi	sp,sp,16
    cprintf("  cause    0x%08x\n", tf->cause);
ffffffffc02006a0:	bc09                	j	ffffffffc02000b2 <cprintf>

ffffffffc02006a2 <interrupt_handler>:

void interrupt_handler(struct trapframe *tf) {
    intptr_t cause = (tf->cause << 1) >> 1;
ffffffffc02006a2:	11853783          	ld	a5,280(a0)
ffffffffc02006a6:	472d                	li	a4,11
ffffffffc02006a8:	0786                	slli	a5,a5,0x1
ffffffffc02006aa:	8385                	srli	a5,a5,0x1
ffffffffc02006ac:	06f76c63          	bltu	a4,a5,ffffffffc0200724 <interrupt_handler+0x82>
ffffffffc02006b0:	00002717          	auipc	a4,0x2
ffffffffc02006b4:	a5870713          	addi	a4,a4,-1448 # ffffffffc0202108 <commands+0x4c8>
ffffffffc02006b8:	078a                	slli	a5,a5,0x2
ffffffffc02006ba:	97ba                	add	a5,a5,a4
ffffffffc02006bc:	439c                	lw	a5,0(a5)
ffffffffc02006be:	97ba                	add	a5,a5,a4
ffffffffc02006c0:	8782                	jr	a5
            break;
        case IRQ_H_SOFT:
            cprintf("Hypervisor software interrupt\n");
            break;
        case IRQ_M_SOFT:
            cprintf("Machine software interrupt\n");
ffffffffc02006c2:	00002517          	auipc	a0,0x2
ffffffffc02006c6:	9de50513          	addi	a0,a0,-1570 # ffffffffc02020a0 <commands+0x460>
ffffffffc02006ca:	b2e5                	j	ffffffffc02000b2 <cprintf>
            cprintf("Hypervisor software interrupt\n");
ffffffffc02006cc:	00002517          	auipc	a0,0x2
ffffffffc02006d0:	9b450513          	addi	a0,a0,-1612 # ffffffffc0202080 <commands+0x440>
ffffffffc02006d4:	baf9                	j	ffffffffc02000b2 <cprintf>
            cprintf("User software interrupt\n");
ffffffffc02006d6:	00002517          	auipc	a0,0x2
ffffffffc02006da:	96a50513          	addi	a0,a0,-1686 # ffffffffc0202040 <commands+0x400>
ffffffffc02006de:	bad1                	j	ffffffffc02000b2 <cprintf>
            break;
        case IRQ_U_TIMER:
            cprintf("User Timer interrupt\n");
ffffffffc02006e0:	00002517          	auipc	a0,0x2
ffffffffc02006e4:	9e050513          	addi	a0,a0,-1568 # ffffffffc02020c0 <commands+0x480>
ffffffffc02006e8:	b2e9                	j	ffffffffc02000b2 <cprintf>
void interrupt_handler(struct trapframe *tf) {
ffffffffc02006ea:	1141                	addi	sp,sp,-16
ffffffffc02006ec:	e406                	sd	ra,8(sp)
            // read-only." -- privileged spec1.9.1, 4.1.4, p59
            // In fact, Call sbi_set_timer will clear STIP, or you can clear it
            // directly.
            // cprintf("Supervisor timer interrupt\n");
            // clear_csr(sip, SIP_STIP);
            clock_set_next_event();
ffffffffc02006ee:	d4dff0ef          	jal	ra,ffffffffc020043a <clock_set_next_event>
            if (++ticks % TICK_NUM == 0) {
ffffffffc02006f2:	00006697          	auipc	a3,0x6
ffffffffc02006f6:	d4668693          	addi	a3,a3,-698 # ffffffffc0206438 <ticks>
ffffffffc02006fa:	629c                	ld	a5,0(a3)
ffffffffc02006fc:	06400713          	li	a4,100
ffffffffc0200700:	0785                	addi	a5,a5,1
ffffffffc0200702:	02e7f733          	remu	a4,a5,a4
ffffffffc0200706:	e29c                	sd	a5,0(a3)
ffffffffc0200708:	cf19                	beqz	a4,ffffffffc0200726 <interrupt_handler+0x84>
            break;
        default:
            print_trapframe(tf);
            break;
    }
}
ffffffffc020070a:	60a2                	ld	ra,8(sp)
ffffffffc020070c:	0141                	addi	sp,sp,16
ffffffffc020070e:	8082                	ret
            cprintf("Supervisor external interrupt\n");
ffffffffc0200710:	00002517          	auipc	a0,0x2
ffffffffc0200714:	9d850513          	addi	a0,a0,-1576 # ffffffffc02020e8 <commands+0x4a8>
ffffffffc0200718:	ba69                	j	ffffffffc02000b2 <cprintf>
            cprintf("Supervisor software interrupt\n");
ffffffffc020071a:	00002517          	auipc	a0,0x2
ffffffffc020071e:	94650513          	addi	a0,a0,-1722 # ffffffffc0202060 <commands+0x420>
ffffffffc0200722:	ba41                	j	ffffffffc02000b2 <cprintf>
            print_trapframe(tf);
ffffffffc0200724:	bf39                	j	ffffffffc0200642 <print_trapframe>
    cprintf("%d ticks\n", TICK_NUM);
ffffffffc0200726:	06400593          	li	a1,100
ffffffffc020072a:	00002517          	auipc	a0,0x2
ffffffffc020072e:	9ae50513          	addi	a0,a0,-1618 # ffffffffc02020d8 <commands+0x498>
ffffffffc0200732:	981ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
                if (++num == 10) {
ffffffffc0200736:	00006717          	auipc	a4,0x6
ffffffffc020073a:	d0a70713          	addi	a4,a4,-758 # ffffffffc0206440 <num>
ffffffffc020073e:	631c                	ld	a5,0(a4)
ffffffffc0200740:	46a9                	li	a3,10
ffffffffc0200742:	0785                	addi	a5,a5,1
ffffffffc0200744:	e31c                	sd	a5,0(a4)
ffffffffc0200746:	fcd792e3          	bne	a5,a3,ffffffffc020070a <interrupt_handler+0x68>
}
ffffffffc020074a:	60a2                	ld	ra,8(sp)
ffffffffc020074c:	0141                	addi	sp,sp,16
                    sbi_shutdown();
ffffffffc020074e:	21a0106f          	j	ffffffffc0201968 <sbi_shutdown>

ffffffffc0200752 <trap>:
            break;
    }
}

static inline void trap_dispatch(struct trapframe *tf) {
    if ((intptr_t)tf->cause < 0) {
ffffffffc0200752:	11853783          	ld	a5,280(a0)
ffffffffc0200756:	0007c763          	bltz	a5,ffffffffc0200764 <trap+0x12>
    switch (tf->cause) {
ffffffffc020075a:	472d                	li	a4,11
ffffffffc020075c:	00f76363          	bltu	a4,a5,ffffffffc0200762 <trap+0x10>
 * trapframe and then uses the iret instruction to return from the exception.
 * */
void trap(struct trapframe *tf) {
    // dispatch based on what type of trap occurred
    trap_dispatch(tf);
}
ffffffffc0200760:	8082                	ret
            print_trapframe(tf);
ffffffffc0200762:	b5c5                	j	ffffffffc0200642 <print_trapframe>
        interrupt_handler(tf);
ffffffffc0200764:	bf3d                	j	ffffffffc02006a2 <interrupt_handler>
	...

ffffffffc0200768 <__alltraps>:
    .endm

    .globl __alltraps
    .align(2)
__alltraps:
    SAVE_ALL
ffffffffc0200768:	14011073          	csrw	sscratch,sp
ffffffffc020076c:	712d                	addi	sp,sp,-288
ffffffffc020076e:	e002                	sd	zero,0(sp)
ffffffffc0200770:	e406                	sd	ra,8(sp)
ffffffffc0200772:	ec0e                	sd	gp,24(sp)
ffffffffc0200774:	f012                	sd	tp,32(sp)
ffffffffc0200776:	f416                	sd	t0,40(sp)
ffffffffc0200778:	f81a                	sd	t1,48(sp)
ffffffffc020077a:	fc1e                	sd	t2,56(sp)
ffffffffc020077c:	e0a2                	sd	s0,64(sp)
ffffffffc020077e:	e4a6                	sd	s1,72(sp)
ffffffffc0200780:	e8aa                	sd	a0,80(sp)
ffffffffc0200782:	ecae                	sd	a1,88(sp)
ffffffffc0200784:	f0b2                	sd	a2,96(sp)
ffffffffc0200786:	f4b6                	sd	a3,104(sp)
ffffffffc0200788:	f8ba                	sd	a4,112(sp)
ffffffffc020078a:	fcbe                	sd	a5,120(sp)
ffffffffc020078c:	e142                	sd	a6,128(sp)
ffffffffc020078e:	e546                	sd	a7,136(sp)
ffffffffc0200790:	e94a                	sd	s2,144(sp)
ffffffffc0200792:	ed4e                	sd	s3,152(sp)
ffffffffc0200794:	f152                	sd	s4,160(sp)
ffffffffc0200796:	f556                	sd	s5,168(sp)
ffffffffc0200798:	f95a                	sd	s6,176(sp)
ffffffffc020079a:	fd5e                	sd	s7,184(sp)
ffffffffc020079c:	e1e2                	sd	s8,192(sp)
ffffffffc020079e:	e5e6                	sd	s9,200(sp)
ffffffffc02007a0:	e9ea                	sd	s10,208(sp)
ffffffffc02007a2:	edee                	sd	s11,216(sp)
ffffffffc02007a4:	f1f2                	sd	t3,224(sp)
ffffffffc02007a6:	f5f6                	sd	t4,232(sp)
ffffffffc02007a8:	f9fa                	sd	t5,240(sp)
ffffffffc02007aa:	fdfe                	sd	t6,248(sp)
ffffffffc02007ac:	14001473          	csrrw	s0,sscratch,zero
ffffffffc02007b0:	100024f3          	csrr	s1,sstatus
ffffffffc02007b4:	14102973          	csrr	s2,sepc
ffffffffc02007b8:	143029f3          	csrr	s3,stval
ffffffffc02007bc:	14202a73          	csrr	s4,scause
ffffffffc02007c0:	e822                	sd	s0,16(sp)
ffffffffc02007c2:	e226                	sd	s1,256(sp)
ffffffffc02007c4:	e64a                	sd	s2,264(sp)
ffffffffc02007c6:	ea4e                	sd	s3,272(sp)
ffffffffc02007c8:	ee52                	sd	s4,280(sp)

    move  a0, sp
ffffffffc02007ca:	850a                	mv	a0,sp
    jal trap
ffffffffc02007cc:	f87ff0ef          	jal	ra,ffffffffc0200752 <trap>

ffffffffc02007d0 <__trapret>:
    # sp should be the same as before "jal trap"

    .globl __trapret
__trapret:
    RESTORE_ALL
ffffffffc02007d0:	6492                	ld	s1,256(sp)
ffffffffc02007d2:	6932                	ld	s2,264(sp)
ffffffffc02007d4:	10049073          	csrw	sstatus,s1
ffffffffc02007d8:	14191073          	csrw	sepc,s2
ffffffffc02007dc:	60a2                	ld	ra,8(sp)
ffffffffc02007de:	61e2                	ld	gp,24(sp)
ffffffffc02007e0:	7202                	ld	tp,32(sp)
ffffffffc02007e2:	72a2                	ld	t0,40(sp)
ffffffffc02007e4:	7342                	ld	t1,48(sp)
ffffffffc02007e6:	73e2                	ld	t2,56(sp)
ffffffffc02007e8:	6406                	ld	s0,64(sp)
ffffffffc02007ea:	64a6                	ld	s1,72(sp)
ffffffffc02007ec:	6546                	ld	a0,80(sp)
ffffffffc02007ee:	65e6                	ld	a1,88(sp)
ffffffffc02007f0:	7606                	ld	a2,96(sp)
ffffffffc02007f2:	76a6                	ld	a3,104(sp)
ffffffffc02007f4:	7746                	ld	a4,112(sp)
ffffffffc02007f6:	77e6                	ld	a5,120(sp)
ffffffffc02007f8:	680a                	ld	a6,128(sp)
ffffffffc02007fa:	68aa                	ld	a7,136(sp)
ffffffffc02007fc:	694a                	ld	s2,144(sp)
ffffffffc02007fe:	69ea                	ld	s3,152(sp)
ffffffffc0200800:	7a0a                	ld	s4,160(sp)
ffffffffc0200802:	7aaa                	ld	s5,168(sp)
ffffffffc0200804:	7b4a                	ld	s6,176(sp)
ffffffffc0200806:	7bea                	ld	s7,184(sp)
ffffffffc0200808:	6c0e                	ld	s8,192(sp)
ffffffffc020080a:	6cae                	ld	s9,200(sp)
ffffffffc020080c:	6d4e                	ld	s10,208(sp)
ffffffffc020080e:	6dee                	ld	s11,216(sp)
ffffffffc0200810:	7e0e                	ld	t3,224(sp)
ffffffffc0200812:	7eae                	ld	t4,232(sp)
ffffffffc0200814:	7f4e                	ld	t5,240(sp)
ffffffffc0200816:	7fee                	ld	t6,248(sp)
ffffffffc0200818:	6142                	ld	sp,16(sp)
    # return from supervisor call
    sret
ffffffffc020081a:	10200073          	sret

ffffffffc020081e <best_fit_init>:
 * list_init - initialize a new entry
 * @elm:        new entry to be initialized
 * */
static inline void
list_init(list_entry_t *elm) {
    elm->prev = elm->next = elm;
ffffffffc020081e:	00005797          	auipc	a5,0x5
ffffffffc0200822:	7fa78793          	addi	a5,a5,2042 # ffffffffc0206018 <free_area>
ffffffffc0200826:	e79c                	sd	a5,8(a5)
ffffffffc0200828:	e39c                	sd	a5,0(a5)
#define nr_free (free_area.nr_free)

static void
best_fit_init(void) {
    list_init(&free_list);
    nr_free = 0;
ffffffffc020082a:	0007a823          	sw	zero,16(a5)
}
ffffffffc020082e:	8082                	ret

ffffffffc0200830 <best_fit_nr_free_pages>:
}

static size_t
best_fit_nr_free_pages(void) {
    return nr_free;
}
ffffffffc0200830:	00005517          	auipc	a0,0x5
ffffffffc0200834:	7f856503          	lwu	a0,2040(a0) # ffffffffc0206028 <free_area+0x10>
ffffffffc0200838:	8082                	ret

ffffffffc020083a <best_fit_alloc_pages>:
    assert(n > 0);
ffffffffc020083a:	c14d                	beqz	a0,ffffffffc02008dc <best_fit_alloc_pages+0xa2>
    if (n > nr_free) {
ffffffffc020083c:	00005617          	auipc	a2,0x5
ffffffffc0200840:	7dc60613          	addi	a2,a2,2012 # ffffffffc0206018 <free_area>
ffffffffc0200844:	01062803          	lw	a6,16(a2)
ffffffffc0200848:	86aa                	mv	a3,a0
ffffffffc020084a:	02081793          	slli	a5,a6,0x20
ffffffffc020084e:	9381                	srli	a5,a5,0x20
ffffffffc0200850:	08a7e463          	bltu	a5,a0,ffffffffc02008d8 <best_fit_alloc_pages+0x9e>
 * list_next - get the next entry
 * @listelm:    the list head
 **/
static inline list_entry_t *
list_next(list_entry_t *listelm) {
    return listelm->next;
ffffffffc0200854:	661c                	ld	a5,8(a2)
    size_t min_size = nr_free + 1;
ffffffffc0200856:	0018059b          	addiw	a1,a6,1
ffffffffc020085a:	1582                	slli	a1,a1,0x20
ffffffffc020085c:	9181                	srli	a1,a1,0x20
    struct Page *page = NULL;
ffffffffc020085e:	4501                	li	a0,0
    while ((le = list_next(le)) != &free_list) {
ffffffffc0200860:	06c78b63          	beq	a5,a2,ffffffffc02008d6 <best_fit_alloc_pages+0x9c>
        if (p->property >= n && p->property < min_size) {
ffffffffc0200864:	ff87e703          	lwu	a4,-8(a5)
ffffffffc0200868:	00d76763          	bltu	a4,a3,ffffffffc0200876 <best_fit_alloc_pages+0x3c>
ffffffffc020086c:	00b77563          	bgeu	a4,a1,ffffffffc0200876 <best_fit_alloc_pages+0x3c>
        struct Page *p = le2page(le, page_link);
ffffffffc0200870:	fe878513          	addi	a0,a5,-24
ffffffffc0200874:	85ba                	mv	a1,a4
ffffffffc0200876:	679c                	ld	a5,8(a5)
    while ((le = list_next(le)) != &free_list) {
ffffffffc0200878:	fec796e3          	bne	a5,a2,ffffffffc0200864 <best_fit_alloc_pages+0x2a>
    if (page != NULL) {
ffffffffc020087c:	cd29                	beqz	a0,ffffffffc02008d6 <best_fit_alloc_pages+0x9c>
    __list_del(listelm->prev, listelm->next);
ffffffffc020087e:	711c                	ld	a5,32(a0)
 * list_prev - get the previous entry
 * @listelm:    the list head
 **/
static inline list_entry_t *
list_prev(list_entry_t *listelm) {
    return listelm->prev;
ffffffffc0200880:	6d18                	ld	a4,24(a0)
        if (page->property > n) {
ffffffffc0200882:	490c                	lw	a1,16(a0)
            p->property = page->property - n;
ffffffffc0200884:	0006889b          	sext.w	a7,a3
 * This is only for internal list manipulation where we know
 * the prev/next entries already!
 * */
static inline void
__list_del(list_entry_t *prev, list_entry_t *next) {
    prev->next = next;
ffffffffc0200888:	e71c                	sd	a5,8(a4)
    next->prev = prev;
ffffffffc020088a:	e398                	sd	a4,0(a5)
        if (page->property > n) {
ffffffffc020088c:	02059793          	slli	a5,a1,0x20
ffffffffc0200890:	9381                	srli	a5,a5,0x20
ffffffffc0200892:	02f6f863          	bgeu	a3,a5,ffffffffc02008c2 <best_fit_alloc_pages+0x88>
            struct Page *p = page + n;
ffffffffc0200896:	00269793          	slli	a5,a3,0x2
ffffffffc020089a:	97b6                	add	a5,a5,a3
ffffffffc020089c:	078e                	slli	a5,a5,0x3
ffffffffc020089e:	97aa                	add	a5,a5,a0
            p->property = page->property - n;
ffffffffc02008a0:	411585bb          	subw	a1,a1,a7
ffffffffc02008a4:	cb8c                	sw	a1,16(a5)
 *
 * Note that @nr may be almost arbitrarily large; this function is not
 * restricted to acting on a single-word quantity.
 * */
static inline void set_bit(int nr, volatile void *addr) {
    __op_bit(or, __NOP, nr, ((volatile unsigned long *)addr));
ffffffffc02008a6:	4689                	li	a3,2
ffffffffc02008a8:	00878593          	addi	a1,a5,8
ffffffffc02008ac:	40d5b02f          	amoor.d	zero,a3,(a1)
    __list_add(elm, listelm, listelm->next);
ffffffffc02008b0:	6714                	ld	a3,8(a4)
            list_add(prev, &(p->page_link));
ffffffffc02008b2:	01878593          	addi	a1,a5,24
        nr_free -= n;
ffffffffc02008b6:	01062803          	lw	a6,16(a2)
    prev->next = next->prev = elm;
ffffffffc02008ba:	e28c                	sd	a1,0(a3)
ffffffffc02008bc:	e70c                	sd	a1,8(a4)
    elm->next = next;
ffffffffc02008be:	f394                	sd	a3,32(a5)
    elm->prev = prev;
ffffffffc02008c0:	ef98                	sd	a4,24(a5)
ffffffffc02008c2:	4118083b          	subw	a6,a6,a7
ffffffffc02008c6:	01062823          	sw	a6,16(a2)
 * clear_bit - Atomically clears a bit in memory
 * @nr:     the bit to clear
 * @addr:   the address to start counting from
 * */
static inline void clear_bit(int nr, volatile void *addr) {
    __op_bit(and, __NOT, nr, ((volatile unsigned long *)addr));
ffffffffc02008ca:	57f5                	li	a5,-3
ffffffffc02008cc:	00850713          	addi	a4,a0,8
ffffffffc02008d0:	60f7302f          	amoand.d	zero,a5,(a4)
}
ffffffffc02008d4:	8082                	ret
}
ffffffffc02008d6:	8082                	ret
        return NULL;
ffffffffc02008d8:	4501                	li	a0,0
ffffffffc02008da:	8082                	ret
best_fit_alloc_pages(size_t n) {
ffffffffc02008dc:	1141                	addi	sp,sp,-16
    assert(n > 0);
ffffffffc02008de:	00002697          	auipc	a3,0x2
ffffffffc02008e2:	85a68693          	addi	a3,a3,-1958 # ffffffffc0202138 <commands+0x4f8>
ffffffffc02008e6:	00002617          	auipc	a2,0x2
ffffffffc02008ea:	85a60613          	addi	a2,a2,-1958 # ffffffffc0202140 <commands+0x500>
ffffffffc02008ee:	07000593          	li	a1,112
ffffffffc02008f2:	00002517          	auipc	a0,0x2
ffffffffc02008f6:	86650513          	addi	a0,a0,-1946 # ffffffffc0202158 <commands+0x518>
best_fit_alloc_pages(size_t n) {
ffffffffc02008fa:	e406                	sd	ra,8(sp)
    assert(n > 0);
ffffffffc02008fc:	ab1ff0ef          	jal	ra,ffffffffc02003ac <__panic>

ffffffffc0200900 <best_fit_check>:
}

// LAB2: below code is used to check the best fit allocation algorithm 
// NOTICE: You SHOULD NOT CHANGE basic_check, default_check functions!
static void
best_fit_check(void) {
ffffffffc0200900:	715d                	addi	sp,sp,-80
ffffffffc0200902:	e0a2                	sd	s0,64(sp)
    return listelm->next;
ffffffffc0200904:	00005417          	auipc	s0,0x5
ffffffffc0200908:	71440413          	addi	s0,s0,1812 # ffffffffc0206018 <free_area>
ffffffffc020090c:	641c                	ld	a5,8(s0)
ffffffffc020090e:	e486                	sd	ra,72(sp)
ffffffffc0200910:	fc26                	sd	s1,56(sp)
ffffffffc0200912:	f84a                	sd	s2,48(sp)
ffffffffc0200914:	f44e                	sd	s3,40(sp)
ffffffffc0200916:	f052                	sd	s4,32(sp)
ffffffffc0200918:	ec56                	sd	s5,24(sp)
ffffffffc020091a:	e85a                	sd	s6,16(sp)
ffffffffc020091c:	e45e                	sd	s7,8(sp)
ffffffffc020091e:	e062                	sd	s8,0(sp)
    int score = 0 ,sumscore = 6;
    int count = 0, total = 0;
    list_entry_t *le = &free_list;
    while ((le = list_next(le)) != &free_list) {
ffffffffc0200920:	26878b63          	beq	a5,s0,ffffffffc0200b96 <best_fit_check+0x296>
    int count = 0, total = 0;
ffffffffc0200924:	4481                	li	s1,0
ffffffffc0200926:	4901                	li	s2,0
 * test_bit - Determine whether a bit is set
 * @nr:     the bit to test
 * @addr:   the address to count from
 * */
static inline bool test_bit(int nr, volatile void *addr) {
    return (((*(volatile unsigned long *)addr) >> nr) & 1);
ffffffffc0200928:	ff07b703          	ld	a4,-16(a5)
        struct Page *p = le2page(le, page_link);
        assert(PageProperty(p));
ffffffffc020092c:	8b09                	andi	a4,a4,2
ffffffffc020092e:	26070863          	beqz	a4,ffffffffc0200b9e <best_fit_check+0x29e>
        count ++, total += p->property;
ffffffffc0200932:	ff87a703          	lw	a4,-8(a5)
ffffffffc0200936:	679c                	ld	a5,8(a5)
ffffffffc0200938:	2905                	addiw	s2,s2,1
ffffffffc020093a:	9cb9                	addw	s1,s1,a4
    while ((le = list_next(le)) != &free_list) {
ffffffffc020093c:	fe8796e3          	bne	a5,s0,ffffffffc0200928 <best_fit_check+0x28>
    }
    assert(total == nr_free_pages());
ffffffffc0200940:	89a6                	mv	s3,s1
ffffffffc0200942:	167000ef          	jal	ra,ffffffffc02012a8 <nr_free_pages>
ffffffffc0200946:	33351c63          	bne	a0,s3,ffffffffc0200c7e <best_fit_check+0x37e>
    assert((p0 = alloc_page()) != NULL);
ffffffffc020094a:	4505                	li	a0,1
ffffffffc020094c:	0df000ef          	jal	ra,ffffffffc020122a <alloc_pages>
ffffffffc0200950:	8a2a                	mv	s4,a0
ffffffffc0200952:	36050663          	beqz	a0,ffffffffc0200cbe <best_fit_check+0x3be>
    assert((p1 = alloc_page()) != NULL);
ffffffffc0200956:	4505                	li	a0,1
ffffffffc0200958:	0d3000ef          	jal	ra,ffffffffc020122a <alloc_pages>
ffffffffc020095c:	89aa                	mv	s3,a0
ffffffffc020095e:	34050063          	beqz	a0,ffffffffc0200c9e <best_fit_check+0x39e>
    assert((p2 = alloc_page()) != NULL);
ffffffffc0200962:	4505                	li	a0,1
ffffffffc0200964:	0c7000ef          	jal	ra,ffffffffc020122a <alloc_pages>
ffffffffc0200968:	8aaa                	mv	s5,a0
ffffffffc020096a:	2c050a63          	beqz	a0,ffffffffc0200c3e <best_fit_check+0x33e>
    assert(p0 != p1 && p0 != p2 && p1 != p2);
ffffffffc020096e:	253a0863          	beq	s4,s3,ffffffffc0200bbe <best_fit_check+0x2be>
ffffffffc0200972:	24aa0663          	beq	s4,a0,ffffffffc0200bbe <best_fit_check+0x2be>
ffffffffc0200976:	24a98463          	beq	s3,a0,ffffffffc0200bbe <best_fit_check+0x2be>
    assert(page_ref(p0) == 0 && page_ref(p1) == 0 && page_ref(p2) == 0);
ffffffffc020097a:	000a2783          	lw	a5,0(s4)
ffffffffc020097e:	26079063          	bnez	a5,ffffffffc0200bde <best_fit_check+0x2de>
ffffffffc0200982:	0009a783          	lw	a5,0(s3)
ffffffffc0200986:	24079c63          	bnez	a5,ffffffffc0200bde <best_fit_check+0x2de>
ffffffffc020098a:	411c                	lw	a5,0(a0)
ffffffffc020098c:	24079963          	bnez	a5,ffffffffc0200bde <best_fit_check+0x2de>
extern struct Page *pages;
extern size_t npage;
extern const size_t nbase;
extern uint64_t va_pa_offset;

static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0200990:	00006797          	auipc	a5,0x6
ffffffffc0200994:	ac07b783          	ld	a5,-1344(a5) # ffffffffc0206450 <pages>
ffffffffc0200998:	40fa0733          	sub	a4,s4,a5
ffffffffc020099c:	870d                	srai	a4,a4,0x3
ffffffffc020099e:	00002597          	auipc	a1,0x2
ffffffffc02009a2:	e8a5b583          	ld	a1,-374(a1) # ffffffffc0202828 <error_string+0x38>
ffffffffc02009a6:	02b70733          	mul	a4,a4,a1
ffffffffc02009aa:	00002617          	auipc	a2,0x2
ffffffffc02009ae:	e8663603          	ld	a2,-378(a2) # ffffffffc0202830 <nbase>
    assert(page2pa(p0) < npage * PGSIZE);
ffffffffc02009b2:	00006697          	auipc	a3,0x6
ffffffffc02009b6:	a966b683          	ld	a3,-1386(a3) # ffffffffc0206448 <npage>
ffffffffc02009ba:	06b2                	slli	a3,a3,0xc
ffffffffc02009bc:	9732                	add	a4,a4,a2

static inline uintptr_t page2pa(struct Page *page) {
    return page2ppn(page) << PGSHIFT;
ffffffffc02009be:	0732                	slli	a4,a4,0xc
ffffffffc02009c0:	22d77f63          	bgeu	a4,a3,ffffffffc0200bfe <best_fit_check+0x2fe>
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc02009c4:	40f98733          	sub	a4,s3,a5
ffffffffc02009c8:	870d                	srai	a4,a4,0x3
ffffffffc02009ca:	02b70733          	mul	a4,a4,a1
ffffffffc02009ce:	9732                	add	a4,a4,a2
    return page2ppn(page) << PGSHIFT;
ffffffffc02009d0:	0732                	slli	a4,a4,0xc
    assert(page2pa(p1) < npage * PGSIZE);
ffffffffc02009d2:	3ed77663          	bgeu	a4,a3,ffffffffc0200dbe <best_fit_check+0x4be>
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc02009d6:	40f507b3          	sub	a5,a0,a5
ffffffffc02009da:	878d                	srai	a5,a5,0x3
ffffffffc02009dc:	02b787b3          	mul	a5,a5,a1
ffffffffc02009e0:	97b2                	add	a5,a5,a2
    return page2ppn(page) << PGSHIFT;
ffffffffc02009e2:	07b2                	slli	a5,a5,0xc
    assert(page2pa(p2) < npage * PGSIZE);
ffffffffc02009e4:	3ad7fd63          	bgeu	a5,a3,ffffffffc0200d9e <best_fit_check+0x49e>
    assert(alloc_page() == NULL);
ffffffffc02009e8:	4505                	li	a0,1
    list_entry_t free_list_store = free_list;
ffffffffc02009ea:	00043c03          	ld	s8,0(s0)
ffffffffc02009ee:	00843b83          	ld	s7,8(s0)
    unsigned int nr_free_store = nr_free;
ffffffffc02009f2:	01042b03          	lw	s6,16(s0)
    elm->prev = elm->next = elm;
ffffffffc02009f6:	e400                	sd	s0,8(s0)
ffffffffc02009f8:	e000                	sd	s0,0(s0)
    nr_free = 0;
ffffffffc02009fa:	00005797          	auipc	a5,0x5
ffffffffc02009fe:	6207a723          	sw	zero,1582(a5) # ffffffffc0206028 <free_area+0x10>
    assert(alloc_page() == NULL);
ffffffffc0200a02:	029000ef          	jal	ra,ffffffffc020122a <alloc_pages>
ffffffffc0200a06:	36051c63          	bnez	a0,ffffffffc0200d7e <best_fit_check+0x47e>
    free_page(p0);
ffffffffc0200a0a:	4585                	li	a1,1
ffffffffc0200a0c:	8552                	mv	a0,s4
ffffffffc0200a0e:	05b000ef          	jal	ra,ffffffffc0201268 <free_pages>
    free_page(p1);
ffffffffc0200a12:	4585                	li	a1,1
ffffffffc0200a14:	854e                	mv	a0,s3
ffffffffc0200a16:	053000ef          	jal	ra,ffffffffc0201268 <free_pages>
    free_page(p2);
ffffffffc0200a1a:	4585                	li	a1,1
ffffffffc0200a1c:	8556                	mv	a0,s5
ffffffffc0200a1e:	04b000ef          	jal	ra,ffffffffc0201268 <free_pages>
    assert(nr_free == 3);
ffffffffc0200a22:	4818                	lw	a4,16(s0)
ffffffffc0200a24:	478d                	li	a5,3
ffffffffc0200a26:	32f71c63          	bne	a4,a5,ffffffffc0200d5e <best_fit_check+0x45e>
    assert((p0 = alloc_page()) != NULL);
ffffffffc0200a2a:	4505                	li	a0,1
ffffffffc0200a2c:	7fe000ef          	jal	ra,ffffffffc020122a <alloc_pages>
ffffffffc0200a30:	89aa                	mv	s3,a0
ffffffffc0200a32:	30050663          	beqz	a0,ffffffffc0200d3e <best_fit_check+0x43e>
    assert((p1 = alloc_page()) != NULL);
ffffffffc0200a36:	4505                	li	a0,1
ffffffffc0200a38:	7f2000ef          	jal	ra,ffffffffc020122a <alloc_pages>
ffffffffc0200a3c:	8aaa                	mv	s5,a0
ffffffffc0200a3e:	2e050063          	beqz	a0,ffffffffc0200d1e <best_fit_check+0x41e>
    assert((p2 = alloc_page()) != NULL);
ffffffffc0200a42:	4505                	li	a0,1
ffffffffc0200a44:	7e6000ef          	jal	ra,ffffffffc020122a <alloc_pages>
ffffffffc0200a48:	8a2a                	mv	s4,a0
ffffffffc0200a4a:	2a050a63          	beqz	a0,ffffffffc0200cfe <best_fit_check+0x3fe>
    assert(alloc_page() == NULL);
ffffffffc0200a4e:	4505                	li	a0,1
ffffffffc0200a50:	7da000ef          	jal	ra,ffffffffc020122a <alloc_pages>
ffffffffc0200a54:	28051563          	bnez	a0,ffffffffc0200cde <best_fit_check+0x3de>
    free_page(p0);
ffffffffc0200a58:	4585                	li	a1,1
ffffffffc0200a5a:	854e                	mv	a0,s3
ffffffffc0200a5c:	00d000ef          	jal	ra,ffffffffc0201268 <free_pages>
    assert(!list_empty(&free_list));
ffffffffc0200a60:	641c                	ld	a5,8(s0)
ffffffffc0200a62:	1a878e63          	beq	a5,s0,ffffffffc0200c1e <best_fit_check+0x31e>
    assert((p = alloc_page()) == p0);
ffffffffc0200a66:	4505                	li	a0,1
ffffffffc0200a68:	7c2000ef          	jal	ra,ffffffffc020122a <alloc_pages>
ffffffffc0200a6c:	52a99963          	bne	s3,a0,ffffffffc0200f9e <best_fit_check+0x69e>
    assert(alloc_page() == NULL);
ffffffffc0200a70:	4505                	li	a0,1
ffffffffc0200a72:	7b8000ef          	jal	ra,ffffffffc020122a <alloc_pages>
ffffffffc0200a76:	50051463          	bnez	a0,ffffffffc0200f7e <best_fit_check+0x67e>
    assert(nr_free == 0);
ffffffffc0200a7a:	481c                	lw	a5,16(s0)
ffffffffc0200a7c:	4e079163          	bnez	a5,ffffffffc0200f5e <best_fit_check+0x65e>
    free_page(p);
ffffffffc0200a80:	854e                	mv	a0,s3
ffffffffc0200a82:	4585                	li	a1,1
    free_list = free_list_store;
ffffffffc0200a84:	01843023          	sd	s8,0(s0)
ffffffffc0200a88:	01743423          	sd	s7,8(s0)
    nr_free = nr_free_store;
ffffffffc0200a8c:	01642823          	sw	s6,16(s0)
    free_page(p);
ffffffffc0200a90:	7d8000ef          	jal	ra,ffffffffc0201268 <free_pages>
    free_page(p1);
ffffffffc0200a94:	4585                	li	a1,1
ffffffffc0200a96:	8556                	mv	a0,s5
ffffffffc0200a98:	7d0000ef          	jal	ra,ffffffffc0201268 <free_pages>
    free_page(p2);
ffffffffc0200a9c:	4585                	li	a1,1
ffffffffc0200a9e:	8552                	mv	a0,s4
ffffffffc0200aa0:	7c8000ef          	jal	ra,ffffffffc0201268 <free_pages>

    #ifdef ucore_test
    score += 1;
    cprintf("grading: %d / %d points\n",score, sumscore);
    #endif
    struct Page *p0 = alloc_pages(5), *p1, *p2;
ffffffffc0200aa4:	4515                	li	a0,5
ffffffffc0200aa6:	784000ef          	jal	ra,ffffffffc020122a <alloc_pages>
ffffffffc0200aaa:	89aa                	mv	s3,a0
    assert(p0 != NULL);
ffffffffc0200aac:	48050963          	beqz	a0,ffffffffc0200f3e <best_fit_check+0x63e>
ffffffffc0200ab0:	651c                	ld	a5,8(a0)
ffffffffc0200ab2:	8385                	srli	a5,a5,0x1
    assert(!PageProperty(p0));
ffffffffc0200ab4:	8b85                	andi	a5,a5,1
ffffffffc0200ab6:	46079463          	bnez	a5,ffffffffc0200f1e <best_fit_check+0x61e>
    cprintf("grading: %d / %d points\n",score, sumscore);
    #endif
    list_entry_t free_list_store = free_list;
    list_init(&free_list);
    assert(list_empty(&free_list));
    assert(alloc_page() == NULL);
ffffffffc0200aba:	4505                	li	a0,1
    list_entry_t free_list_store = free_list;
ffffffffc0200abc:	00043a83          	ld	s5,0(s0)
ffffffffc0200ac0:	00843a03          	ld	s4,8(s0)
ffffffffc0200ac4:	e000                	sd	s0,0(s0)
ffffffffc0200ac6:	e400                	sd	s0,8(s0)
    assert(alloc_page() == NULL);
ffffffffc0200ac8:	762000ef          	jal	ra,ffffffffc020122a <alloc_pages>
ffffffffc0200acc:	42051963          	bnez	a0,ffffffffc0200efe <best_fit_check+0x5fe>
    #endif
    unsigned int nr_free_store = nr_free;
    nr_free = 0;

    // * - - * -
    free_pages(p0 + 1, 2);
ffffffffc0200ad0:	4589                	li	a1,2
ffffffffc0200ad2:	02898513          	addi	a0,s3,40
    unsigned int nr_free_store = nr_free;
ffffffffc0200ad6:	01042b03          	lw	s6,16(s0)
    free_pages(p0 + 4, 1);
ffffffffc0200ada:	0a098c13          	addi	s8,s3,160
    nr_free = 0;
ffffffffc0200ade:	00005797          	auipc	a5,0x5
ffffffffc0200ae2:	5407a523          	sw	zero,1354(a5) # ffffffffc0206028 <free_area+0x10>
    free_pages(p0 + 1, 2);
ffffffffc0200ae6:	782000ef          	jal	ra,ffffffffc0201268 <free_pages>
    free_pages(p0 + 4, 1);
ffffffffc0200aea:	8562                	mv	a0,s8
ffffffffc0200aec:	4585                	li	a1,1
ffffffffc0200aee:	77a000ef          	jal	ra,ffffffffc0201268 <free_pages>
    assert(alloc_pages(4) == NULL);
ffffffffc0200af2:	4511                	li	a0,4
ffffffffc0200af4:	736000ef          	jal	ra,ffffffffc020122a <alloc_pages>
ffffffffc0200af8:	3e051363          	bnez	a0,ffffffffc0200ede <best_fit_check+0x5de>
ffffffffc0200afc:	0309b783          	ld	a5,48(s3)
ffffffffc0200b00:	8385                	srli	a5,a5,0x1
    assert(PageProperty(p0 + 1) && p0[1].property == 2);
ffffffffc0200b02:	8b85                	andi	a5,a5,1
ffffffffc0200b04:	3a078d63          	beqz	a5,ffffffffc0200ebe <best_fit_check+0x5be>
ffffffffc0200b08:	0389a703          	lw	a4,56(s3)
ffffffffc0200b0c:	4789                	li	a5,2
ffffffffc0200b0e:	3af71863          	bne	a4,a5,ffffffffc0200ebe <best_fit_check+0x5be>
    // * - - * *
    assert((p1 = alloc_pages(1)) != NULL);
ffffffffc0200b12:	4505                	li	a0,1
ffffffffc0200b14:	716000ef          	jal	ra,ffffffffc020122a <alloc_pages>
ffffffffc0200b18:	8baa                	mv	s7,a0
ffffffffc0200b1a:	38050263          	beqz	a0,ffffffffc0200e9e <best_fit_check+0x59e>
    assert(alloc_pages(2) != NULL);      // best fit feature
ffffffffc0200b1e:	4509                	li	a0,2
ffffffffc0200b20:	70a000ef          	jal	ra,ffffffffc020122a <alloc_pages>
ffffffffc0200b24:	34050d63          	beqz	a0,ffffffffc0200e7e <best_fit_check+0x57e>
    assert(p0 + 4 == p1);
ffffffffc0200b28:	337c1b63          	bne	s8,s7,ffffffffc0200e5e <best_fit_check+0x55e>
    #ifdef ucore_test
    score += 1;
    cprintf("grading: %d / %d points\n",score, sumscore);
    #endif
    p2 = p0 + 1;
    free_pages(p0, 5);
ffffffffc0200b2c:	854e                	mv	a0,s3
ffffffffc0200b2e:	4595                	li	a1,5
ffffffffc0200b30:	738000ef          	jal	ra,ffffffffc0201268 <free_pages>
    assert((p0 = alloc_pages(5)) != NULL);
ffffffffc0200b34:	4515                	li	a0,5
ffffffffc0200b36:	6f4000ef          	jal	ra,ffffffffc020122a <alloc_pages>
ffffffffc0200b3a:	89aa                	mv	s3,a0
ffffffffc0200b3c:	30050163          	beqz	a0,ffffffffc0200e3e <best_fit_check+0x53e>
    assert(alloc_page() == NULL);
ffffffffc0200b40:	4505                	li	a0,1
ffffffffc0200b42:	6e8000ef          	jal	ra,ffffffffc020122a <alloc_pages>
ffffffffc0200b46:	2c051c63          	bnez	a0,ffffffffc0200e1e <best_fit_check+0x51e>

    #ifdef ucore_test
    score += 1;
    cprintf("grading: %d / %d points\n",score, sumscore);
    #endif
    assert(nr_free == 0);
ffffffffc0200b4a:	481c                	lw	a5,16(s0)
ffffffffc0200b4c:	2a079963          	bnez	a5,ffffffffc0200dfe <best_fit_check+0x4fe>
    nr_free = nr_free_store;

    free_list = free_list_store;
    free_pages(p0, 5);
ffffffffc0200b50:	4595                	li	a1,5
ffffffffc0200b52:	854e                	mv	a0,s3
    nr_free = nr_free_store;
ffffffffc0200b54:	01642823          	sw	s6,16(s0)
    free_list = free_list_store;
ffffffffc0200b58:	01543023          	sd	s5,0(s0)
ffffffffc0200b5c:	01443423          	sd	s4,8(s0)
    free_pages(p0, 5);
ffffffffc0200b60:	708000ef          	jal	ra,ffffffffc0201268 <free_pages>
    return listelm->next;
ffffffffc0200b64:	641c                	ld	a5,8(s0)

    le = &free_list;
    while ((le = list_next(le)) != &free_list) {
ffffffffc0200b66:	00878963          	beq	a5,s0,ffffffffc0200b78 <best_fit_check+0x278>
        struct Page *p = le2page(le, page_link);
        count --, total -= p->property;
ffffffffc0200b6a:	ff87a703          	lw	a4,-8(a5)
ffffffffc0200b6e:	679c                	ld	a5,8(a5)
ffffffffc0200b70:	397d                	addiw	s2,s2,-1
ffffffffc0200b72:	9c99                	subw	s1,s1,a4
    while ((le = list_next(le)) != &free_list) {
ffffffffc0200b74:	fe879be3          	bne	a5,s0,ffffffffc0200b6a <best_fit_check+0x26a>
    }
    assert(count == 0);
ffffffffc0200b78:	26091363          	bnez	s2,ffffffffc0200dde <best_fit_check+0x4de>
    assert(total == 0);
ffffffffc0200b7c:	e0ed                	bnez	s1,ffffffffc0200c5e <best_fit_check+0x35e>
    #ifdef ucore_test
    score += 1;
    cprintf("grading: %d / %d points\n",score, sumscore);
    #endif
}
ffffffffc0200b7e:	60a6                	ld	ra,72(sp)
ffffffffc0200b80:	6406                	ld	s0,64(sp)
ffffffffc0200b82:	74e2                	ld	s1,56(sp)
ffffffffc0200b84:	7942                	ld	s2,48(sp)
ffffffffc0200b86:	79a2                	ld	s3,40(sp)
ffffffffc0200b88:	7a02                	ld	s4,32(sp)
ffffffffc0200b8a:	6ae2                	ld	s5,24(sp)
ffffffffc0200b8c:	6b42                	ld	s6,16(sp)
ffffffffc0200b8e:	6ba2                	ld	s7,8(sp)
ffffffffc0200b90:	6c02                	ld	s8,0(sp)
ffffffffc0200b92:	6161                	addi	sp,sp,80
ffffffffc0200b94:	8082                	ret
    while ((le = list_next(le)) != &free_list) {
ffffffffc0200b96:	4981                	li	s3,0
    int count = 0, total = 0;
ffffffffc0200b98:	4481                	li	s1,0
ffffffffc0200b9a:	4901                	li	s2,0
ffffffffc0200b9c:	b35d                	j	ffffffffc0200942 <best_fit_check+0x42>
        assert(PageProperty(p));
ffffffffc0200b9e:	00001697          	auipc	a3,0x1
ffffffffc0200ba2:	5d268693          	addi	a3,a3,1490 # ffffffffc0202170 <commands+0x530>
ffffffffc0200ba6:	00001617          	auipc	a2,0x1
ffffffffc0200baa:	59a60613          	addi	a2,a2,1434 # ffffffffc0202140 <commands+0x500>
ffffffffc0200bae:	11000593          	li	a1,272
ffffffffc0200bb2:	00001517          	auipc	a0,0x1
ffffffffc0200bb6:	5a650513          	addi	a0,a0,1446 # ffffffffc0202158 <commands+0x518>
ffffffffc0200bba:	ff2ff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert(p0 != p1 && p0 != p2 && p1 != p2);
ffffffffc0200bbe:	00001697          	auipc	a3,0x1
ffffffffc0200bc2:	64268693          	addi	a3,a3,1602 # ffffffffc0202200 <commands+0x5c0>
ffffffffc0200bc6:	00001617          	auipc	a2,0x1
ffffffffc0200bca:	57a60613          	addi	a2,a2,1402 # ffffffffc0202140 <commands+0x500>
ffffffffc0200bce:	0dc00593          	li	a1,220
ffffffffc0200bd2:	00001517          	auipc	a0,0x1
ffffffffc0200bd6:	58650513          	addi	a0,a0,1414 # ffffffffc0202158 <commands+0x518>
ffffffffc0200bda:	fd2ff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert(page_ref(p0) == 0 && page_ref(p1) == 0 && page_ref(p2) == 0);
ffffffffc0200bde:	00001697          	auipc	a3,0x1
ffffffffc0200be2:	64a68693          	addi	a3,a3,1610 # ffffffffc0202228 <commands+0x5e8>
ffffffffc0200be6:	00001617          	auipc	a2,0x1
ffffffffc0200bea:	55a60613          	addi	a2,a2,1370 # ffffffffc0202140 <commands+0x500>
ffffffffc0200bee:	0dd00593          	li	a1,221
ffffffffc0200bf2:	00001517          	auipc	a0,0x1
ffffffffc0200bf6:	56650513          	addi	a0,a0,1382 # ffffffffc0202158 <commands+0x518>
ffffffffc0200bfa:	fb2ff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert(page2pa(p0) < npage * PGSIZE);
ffffffffc0200bfe:	00001697          	auipc	a3,0x1
ffffffffc0200c02:	66a68693          	addi	a3,a3,1642 # ffffffffc0202268 <commands+0x628>
ffffffffc0200c06:	00001617          	auipc	a2,0x1
ffffffffc0200c0a:	53a60613          	addi	a2,a2,1338 # ffffffffc0202140 <commands+0x500>
ffffffffc0200c0e:	0df00593          	li	a1,223
ffffffffc0200c12:	00001517          	auipc	a0,0x1
ffffffffc0200c16:	54650513          	addi	a0,a0,1350 # ffffffffc0202158 <commands+0x518>
ffffffffc0200c1a:	f92ff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert(!list_empty(&free_list));
ffffffffc0200c1e:	00001697          	auipc	a3,0x1
ffffffffc0200c22:	6d268693          	addi	a3,a3,1746 # ffffffffc02022f0 <commands+0x6b0>
ffffffffc0200c26:	00001617          	auipc	a2,0x1
ffffffffc0200c2a:	51a60613          	addi	a2,a2,1306 # ffffffffc0202140 <commands+0x500>
ffffffffc0200c2e:	0f800593          	li	a1,248
ffffffffc0200c32:	00001517          	auipc	a0,0x1
ffffffffc0200c36:	52650513          	addi	a0,a0,1318 # ffffffffc0202158 <commands+0x518>
ffffffffc0200c3a:	f72ff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert((p2 = alloc_page()) != NULL);
ffffffffc0200c3e:	00001697          	auipc	a3,0x1
ffffffffc0200c42:	5a268693          	addi	a3,a3,1442 # ffffffffc02021e0 <commands+0x5a0>
ffffffffc0200c46:	00001617          	auipc	a2,0x1
ffffffffc0200c4a:	4fa60613          	addi	a2,a2,1274 # ffffffffc0202140 <commands+0x500>
ffffffffc0200c4e:	0da00593          	li	a1,218
ffffffffc0200c52:	00001517          	auipc	a0,0x1
ffffffffc0200c56:	50650513          	addi	a0,a0,1286 # ffffffffc0202158 <commands+0x518>
ffffffffc0200c5a:	f52ff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert(total == 0);
ffffffffc0200c5e:	00001697          	auipc	a3,0x1
ffffffffc0200c62:	7c268693          	addi	a3,a3,1986 # ffffffffc0202420 <commands+0x7e0>
ffffffffc0200c66:	00001617          	auipc	a2,0x1
ffffffffc0200c6a:	4da60613          	addi	a2,a2,1242 # ffffffffc0202140 <commands+0x500>
ffffffffc0200c6e:	15200593          	li	a1,338
ffffffffc0200c72:	00001517          	auipc	a0,0x1
ffffffffc0200c76:	4e650513          	addi	a0,a0,1254 # ffffffffc0202158 <commands+0x518>
ffffffffc0200c7a:	f32ff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert(total == nr_free_pages());
ffffffffc0200c7e:	00001697          	auipc	a3,0x1
ffffffffc0200c82:	50268693          	addi	a3,a3,1282 # ffffffffc0202180 <commands+0x540>
ffffffffc0200c86:	00001617          	auipc	a2,0x1
ffffffffc0200c8a:	4ba60613          	addi	a2,a2,1210 # ffffffffc0202140 <commands+0x500>
ffffffffc0200c8e:	11300593          	li	a1,275
ffffffffc0200c92:	00001517          	auipc	a0,0x1
ffffffffc0200c96:	4c650513          	addi	a0,a0,1222 # ffffffffc0202158 <commands+0x518>
ffffffffc0200c9a:	f12ff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert((p1 = alloc_page()) != NULL);
ffffffffc0200c9e:	00001697          	auipc	a3,0x1
ffffffffc0200ca2:	52268693          	addi	a3,a3,1314 # ffffffffc02021c0 <commands+0x580>
ffffffffc0200ca6:	00001617          	auipc	a2,0x1
ffffffffc0200caa:	49a60613          	addi	a2,a2,1178 # ffffffffc0202140 <commands+0x500>
ffffffffc0200cae:	0d900593          	li	a1,217
ffffffffc0200cb2:	00001517          	auipc	a0,0x1
ffffffffc0200cb6:	4a650513          	addi	a0,a0,1190 # ffffffffc0202158 <commands+0x518>
ffffffffc0200cba:	ef2ff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert((p0 = alloc_page()) != NULL);
ffffffffc0200cbe:	00001697          	auipc	a3,0x1
ffffffffc0200cc2:	4e268693          	addi	a3,a3,1250 # ffffffffc02021a0 <commands+0x560>
ffffffffc0200cc6:	00001617          	auipc	a2,0x1
ffffffffc0200cca:	47a60613          	addi	a2,a2,1146 # ffffffffc0202140 <commands+0x500>
ffffffffc0200cce:	0d800593          	li	a1,216
ffffffffc0200cd2:	00001517          	auipc	a0,0x1
ffffffffc0200cd6:	48650513          	addi	a0,a0,1158 # ffffffffc0202158 <commands+0x518>
ffffffffc0200cda:	ed2ff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert(alloc_page() == NULL);
ffffffffc0200cde:	00001697          	auipc	a3,0x1
ffffffffc0200ce2:	5ea68693          	addi	a3,a3,1514 # ffffffffc02022c8 <commands+0x688>
ffffffffc0200ce6:	00001617          	auipc	a2,0x1
ffffffffc0200cea:	45a60613          	addi	a2,a2,1114 # ffffffffc0202140 <commands+0x500>
ffffffffc0200cee:	0f500593          	li	a1,245
ffffffffc0200cf2:	00001517          	auipc	a0,0x1
ffffffffc0200cf6:	46650513          	addi	a0,a0,1126 # ffffffffc0202158 <commands+0x518>
ffffffffc0200cfa:	eb2ff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert((p2 = alloc_page()) != NULL);
ffffffffc0200cfe:	00001697          	auipc	a3,0x1
ffffffffc0200d02:	4e268693          	addi	a3,a3,1250 # ffffffffc02021e0 <commands+0x5a0>
ffffffffc0200d06:	00001617          	auipc	a2,0x1
ffffffffc0200d0a:	43a60613          	addi	a2,a2,1082 # ffffffffc0202140 <commands+0x500>
ffffffffc0200d0e:	0f300593          	li	a1,243
ffffffffc0200d12:	00001517          	auipc	a0,0x1
ffffffffc0200d16:	44650513          	addi	a0,a0,1094 # ffffffffc0202158 <commands+0x518>
ffffffffc0200d1a:	e92ff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert((p1 = alloc_page()) != NULL);
ffffffffc0200d1e:	00001697          	auipc	a3,0x1
ffffffffc0200d22:	4a268693          	addi	a3,a3,1186 # ffffffffc02021c0 <commands+0x580>
ffffffffc0200d26:	00001617          	auipc	a2,0x1
ffffffffc0200d2a:	41a60613          	addi	a2,a2,1050 # ffffffffc0202140 <commands+0x500>
ffffffffc0200d2e:	0f200593          	li	a1,242
ffffffffc0200d32:	00001517          	auipc	a0,0x1
ffffffffc0200d36:	42650513          	addi	a0,a0,1062 # ffffffffc0202158 <commands+0x518>
ffffffffc0200d3a:	e72ff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert((p0 = alloc_page()) != NULL);
ffffffffc0200d3e:	00001697          	auipc	a3,0x1
ffffffffc0200d42:	46268693          	addi	a3,a3,1122 # ffffffffc02021a0 <commands+0x560>
ffffffffc0200d46:	00001617          	auipc	a2,0x1
ffffffffc0200d4a:	3fa60613          	addi	a2,a2,1018 # ffffffffc0202140 <commands+0x500>
ffffffffc0200d4e:	0f100593          	li	a1,241
ffffffffc0200d52:	00001517          	auipc	a0,0x1
ffffffffc0200d56:	40650513          	addi	a0,a0,1030 # ffffffffc0202158 <commands+0x518>
ffffffffc0200d5a:	e52ff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert(nr_free == 3);
ffffffffc0200d5e:	00001697          	auipc	a3,0x1
ffffffffc0200d62:	58268693          	addi	a3,a3,1410 # ffffffffc02022e0 <commands+0x6a0>
ffffffffc0200d66:	00001617          	auipc	a2,0x1
ffffffffc0200d6a:	3da60613          	addi	a2,a2,986 # ffffffffc0202140 <commands+0x500>
ffffffffc0200d6e:	0ef00593          	li	a1,239
ffffffffc0200d72:	00001517          	auipc	a0,0x1
ffffffffc0200d76:	3e650513          	addi	a0,a0,998 # ffffffffc0202158 <commands+0x518>
ffffffffc0200d7a:	e32ff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert(alloc_page() == NULL);
ffffffffc0200d7e:	00001697          	auipc	a3,0x1
ffffffffc0200d82:	54a68693          	addi	a3,a3,1354 # ffffffffc02022c8 <commands+0x688>
ffffffffc0200d86:	00001617          	auipc	a2,0x1
ffffffffc0200d8a:	3ba60613          	addi	a2,a2,954 # ffffffffc0202140 <commands+0x500>
ffffffffc0200d8e:	0ea00593          	li	a1,234
ffffffffc0200d92:	00001517          	auipc	a0,0x1
ffffffffc0200d96:	3c650513          	addi	a0,a0,966 # ffffffffc0202158 <commands+0x518>
ffffffffc0200d9a:	e12ff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert(page2pa(p2) < npage * PGSIZE);
ffffffffc0200d9e:	00001697          	auipc	a3,0x1
ffffffffc0200da2:	50a68693          	addi	a3,a3,1290 # ffffffffc02022a8 <commands+0x668>
ffffffffc0200da6:	00001617          	auipc	a2,0x1
ffffffffc0200daa:	39a60613          	addi	a2,a2,922 # ffffffffc0202140 <commands+0x500>
ffffffffc0200dae:	0e100593          	li	a1,225
ffffffffc0200db2:	00001517          	auipc	a0,0x1
ffffffffc0200db6:	3a650513          	addi	a0,a0,934 # ffffffffc0202158 <commands+0x518>
ffffffffc0200dba:	df2ff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert(page2pa(p1) < npage * PGSIZE);
ffffffffc0200dbe:	00001697          	auipc	a3,0x1
ffffffffc0200dc2:	4ca68693          	addi	a3,a3,1226 # ffffffffc0202288 <commands+0x648>
ffffffffc0200dc6:	00001617          	auipc	a2,0x1
ffffffffc0200dca:	37a60613          	addi	a2,a2,890 # ffffffffc0202140 <commands+0x500>
ffffffffc0200dce:	0e000593          	li	a1,224
ffffffffc0200dd2:	00001517          	auipc	a0,0x1
ffffffffc0200dd6:	38650513          	addi	a0,a0,902 # ffffffffc0202158 <commands+0x518>
ffffffffc0200dda:	dd2ff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert(count == 0);
ffffffffc0200dde:	00001697          	auipc	a3,0x1
ffffffffc0200de2:	63268693          	addi	a3,a3,1586 # ffffffffc0202410 <commands+0x7d0>
ffffffffc0200de6:	00001617          	auipc	a2,0x1
ffffffffc0200dea:	35a60613          	addi	a2,a2,858 # ffffffffc0202140 <commands+0x500>
ffffffffc0200dee:	15100593          	li	a1,337
ffffffffc0200df2:	00001517          	auipc	a0,0x1
ffffffffc0200df6:	36650513          	addi	a0,a0,870 # ffffffffc0202158 <commands+0x518>
ffffffffc0200dfa:	db2ff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert(nr_free == 0);
ffffffffc0200dfe:	00001697          	auipc	a3,0x1
ffffffffc0200e02:	52a68693          	addi	a3,a3,1322 # ffffffffc0202328 <commands+0x6e8>
ffffffffc0200e06:	00001617          	auipc	a2,0x1
ffffffffc0200e0a:	33a60613          	addi	a2,a2,826 # ffffffffc0202140 <commands+0x500>
ffffffffc0200e0e:	14600593          	li	a1,326
ffffffffc0200e12:	00001517          	auipc	a0,0x1
ffffffffc0200e16:	34650513          	addi	a0,a0,838 # ffffffffc0202158 <commands+0x518>
ffffffffc0200e1a:	d92ff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert(alloc_page() == NULL);
ffffffffc0200e1e:	00001697          	auipc	a3,0x1
ffffffffc0200e22:	4aa68693          	addi	a3,a3,1194 # ffffffffc02022c8 <commands+0x688>
ffffffffc0200e26:	00001617          	auipc	a2,0x1
ffffffffc0200e2a:	31a60613          	addi	a2,a2,794 # ffffffffc0202140 <commands+0x500>
ffffffffc0200e2e:	14000593          	li	a1,320
ffffffffc0200e32:	00001517          	auipc	a0,0x1
ffffffffc0200e36:	32650513          	addi	a0,a0,806 # ffffffffc0202158 <commands+0x518>
ffffffffc0200e3a:	d72ff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert((p0 = alloc_pages(5)) != NULL);
ffffffffc0200e3e:	00001697          	auipc	a3,0x1
ffffffffc0200e42:	5b268693          	addi	a3,a3,1458 # ffffffffc02023f0 <commands+0x7b0>
ffffffffc0200e46:	00001617          	auipc	a2,0x1
ffffffffc0200e4a:	2fa60613          	addi	a2,a2,762 # ffffffffc0202140 <commands+0x500>
ffffffffc0200e4e:	13f00593          	li	a1,319
ffffffffc0200e52:	00001517          	auipc	a0,0x1
ffffffffc0200e56:	30650513          	addi	a0,a0,774 # ffffffffc0202158 <commands+0x518>
ffffffffc0200e5a:	d52ff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert(p0 + 4 == p1);
ffffffffc0200e5e:	00001697          	auipc	a3,0x1
ffffffffc0200e62:	58268693          	addi	a3,a3,1410 # ffffffffc02023e0 <commands+0x7a0>
ffffffffc0200e66:	00001617          	auipc	a2,0x1
ffffffffc0200e6a:	2da60613          	addi	a2,a2,730 # ffffffffc0202140 <commands+0x500>
ffffffffc0200e6e:	13700593          	li	a1,311
ffffffffc0200e72:	00001517          	auipc	a0,0x1
ffffffffc0200e76:	2e650513          	addi	a0,a0,742 # ffffffffc0202158 <commands+0x518>
ffffffffc0200e7a:	d32ff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert(alloc_pages(2) != NULL);      // best fit feature
ffffffffc0200e7e:	00001697          	auipc	a3,0x1
ffffffffc0200e82:	54a68693          	addi	a3,a3,1354 # ffffffffc02023c8 <commands+0x788>
ffffffffc0200e86:	00001617          	auipc	a2,0x1
ffffffffc0200e8a:	2ba60613          	addi	a2,a2,698 # ffffffffc0202140 <commands+0x500>
ffffffffc0200e8e:	13600593          	li	a1,310
ffffffffc0200e92:	00001517          	auipc	a0,0x1
ffffffffc0200e96:	2c650513          	addi	a0,a0,710 # ffffffffc0202158 <commands+0x518>
ffffffffc0200e9a:	d12ff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert((p1 = alloc_pages(1)) != NULL);
ffffffffc0200e9e:	00001697          	auipc	a3,0x1
ffffffffc0200ea2:	50a68693          	addi	a3,a3,1290 # ffffffffc02023a8 <commands+0x768>
ffffffffc0200ea6:	00001617          	auipc	a2,0x1
ffffffffc0200eaa:	29a60613          	addi	a2,a2,666 # ffffffffc0202140 <commands+0x500>
ffffffffc0200eae:	13500593          	li	a1,309
ffffffffc0200eb2:	00001517          	auipc	a0,0x1
ffffffffc0200eb6:	2a650513          	addi	a0,a0,678 # ffffffffc0202158 <commands+0x518>
ffffffffc0200eba:	cf2ff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert(PageProperty(p0 + 1) && p0[1].property == 2);
ffffffffc0200ebe:	00001697          	auipc	a3,0x1
ffffffffc0200ec2:	4ba68693          	addi	a3,a3,1210 # ffffffffc0202378 <commands+0x738>
ffffffffc0200ec6:	00001617          	auipc	a2,0x1
ffffffffc0200eca:	27a60613          	addi	a2,a2,634 # ffffffffc0202140 <commands+0x500>
ffffffffc0200ece:	13300593          	li	a1,307
ffffffffc0200ed2:	00001517          	auipc	a0,0x1
ffffffffc0200ed6:	28650513          	addi	a0,a0,646 # ffffffffc0202158 <commands+0x518>
ffffffffc0200eda:	cd2ff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert(alloc_pages(4) == NULL);
ffffffffc0200ede:	00001697          	auipc	a3,0x1
ffffffffc0200ee2:	48268693          	addi	a3,a3,1154 # ffffffffc0202360 <commands+0x720>
ffffffffc0200ee6:	00001617          	auipc	a2,0x1
ffffffffc0200eea:	25a60613          	addi	a2,a2,602 # ffffffffc0202140 <commands+0x500>
ffffffffc0200eee:	13200593          	li	a1,306
ffffffffc0200ef2:	00001517          	auipc	a0,0x1
ffffffffc0200ef6:	26650513          	addi	a0,a0,614 # ffffffffc0202158 <commands+0x518>
ffffffffc0200efa:	cb2ff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert(alloc_page() == NULL);
ffffffffc0200efe:	00001697          	auipc	a3,0x1
ffffffffc0200f02:	3ca68693          	addi	a3,a3,970 # ffffffffc02022c8 <commands+0x688>
ffffffffc0200f06:	00001617          	auipc	a2,0x1
ffffffffc0200f0a:	23a60613          	addi	a2,a2,570 # ffffffffc0202140 <commands+0x500>
ffffffffc0200f0e:	12600593          	li	a1,294
ffffffffc0200f12:	00001517          	auipc	a0,0x1
ffffffffc0200f16:	24650513          	addi	a0,a0,582 # ffffffffc0202158 <commands+0x518>
ffffffffc0200f1a:	c92ff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert(!PageProperty(p0));
ffffffffc0200f1e:	00001697          	auipc	a3,0x1
ffffffffc0200f22:	42a68693          	addi	a3,a3,1066 # ffffffffc0202348 <commands+0x708>
ffffffffc0200f26:	00001617          	auipc	a2,0x1
ffffffffc0200f2a:	21a60613          	addi	a2,a2,538 # ffffffffc0202140 <commands+0x500>
ffffffffc0200f2e:	11d00593          	li	a1,285
ffffffffc0200f32:	00001517          	auipc	a0,0x1
ffffffffc0200f36:	22650513          	addi	a0,a0,550 # ffffffffc0202158 <commands+0x518>
ffffffffc0200f3a:	c72ff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert(p0 != NULL);
ffffffffc0200f3e:	00001697          	auipc	a3,0x1
ffffffffc0200f42:	3fa68693          	addi	a3,a3,1018 # ffffffffc0202338 <commands+0x6f8>
ffffffffc0200f46:	00001617          	auipc	a2,0x1
ffffffffc0200f4a:	1fa60613          	addi	a2,a2,506 # ffffffffc0202140 <commands+0x500>
ffffffffc0200f4e:	11c00593          	li	a1,284
ffffffffc0200f52:	00001517          	auipc	a0,0x1
ffffffffc0200f56:	20650513          	addi	a0,a0,518 # ffffffffc0202158 <commands+0x518>
ffffffffc0200f5a:	c52ff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert(nr_free == 0);
ffffffffc0200f5e:	00001697          	auipc	a3,0x1
ffffffffc0200f62:	3ca68693          	addi	a3,a3,970 # ffffffffc0202328 <commands+0x6e8>
ffffffffc0200f66:	00001617          	auipc	a2,0x1
ffffffffc0200f6a:	1da60613          	addi	a2,a2,474 # ffffffffc0202140 <commands+0x500>
ffffffffc0200f6e:	0fe00593          	li	a1,254
ffffffffc0200f72:	00001517          	auipc	a0,0x1
ffffffffc0200f76:	1e650513          	addi	a0,a0,486 # ffffffffc0202158 <commands+0x518>
ffffffffc0200f7a:	c32ff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert(alloc_page() == NULL);
ffffffffc0200f7e:	00001697          	auipc	a3,0x1
ffffffffc0200f82:	34a68693          	addi	a3,a3,842 # ffffffffc02022c8 <commands+0x688>
ffffffffc0200f86:	00001617          	auipc	a2,0x1
ffffffffc0200f8a:	1ba60613          	addi	a2,a2,442 # ffffffffc0202140 <commands+0x500>
ffffffffc0200f8e:	0fc00593          	li	a1,252
ffffffffc0200f92:	00001517          	auipc	a0,0x1
ffffffffc0200f96:	1c650513          	addi	a0,a0,454 # ffffffffc0202158 <commands+0x518>
ffffffffc0200f9a:	c12ff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert((p = alloc_page()) == p0);
ffffffffc0200f9e:	00001697          	auipc	a3,0x1
ffffffffc0200fa2:	36a68693          	addi	a3,a3,874 # ffffffffc0202308 <commands+0x6c8>
ffffffffc0200fa6:	00001617          	auipc	a2,0x1
ffffffffc0200faa:	19a60613          	addi	a2,a2,410 # ffffffffc0202140 <commands+0x500>
ffffffffc0200fae:	0fb00593          	li	a1,251
ffffffffc0200fb2:	00001517          	auipc	a0,0x1
ffffffffc0200fb6:	1a650513          	addi	a0,a0,422 # ffffffffc0202158 <commands+0x518>
ffffffffc0200fba:	bf2ff0ef          	jal	ra,ffffffffc02003ac <__panic>

ffffffffc0200fbe <best_fit_free_pages>:
best_fit_free_pages(struct Page *base, size_t n) {
ffffffffc0200fbe:	1141                	addi	sp,sp,-16
ffffffffc0200fc0:	e406                	sd	ra,8(sp)
    assert(n > 0);
ffffffffc0200fc2:	14058a63          	beqz	a1,ffffffffc0201116 <best_fit_free_pages+0x158>
    for (; p != base + n; p ++) {
ffffffffc0200fc6:	00259693          	slli	a3,a1,0x2
ffffffffc0200fca:	96ae                	add	a3,a3,a1
ffffffffc0200fcc:	068e                	slli	a3,a3,0x3
ffffffffc0200fce:	96aa                	add	a3,a3,a0
ffffffffc0200fd0:	87aa                	mv	a5,a0
ffffffffc0200fd2:	02d50263          	beq	a0,a3,ffffffffc0200ff6 <best_fit_free_pages+0x38>
ffffffffc0200fd6:	6798                	ld	a4,8(a5)
        assert(!PageReserved(p) && !PageProperty(p));
ffffffffc0200fd8:	8b05                	andi	a4,a4,1
ffffffffc0200fda:	10071e63          	bnez	a4,ffffffffc02010f6 <best_fit_free_pages+0x138>
ffffffffc0200fde:	6798                	ld	a4,8(a5)
ffffffffc0200fe0:	8b09                	andi	a4,a4,2
ffffffffc0200fe2:	10071a63          	bnez	a4,ffffffffc02010f6 <best_fit_free_pages+0x138>
        p->flags = 0;
ffffffffc0200fe6:	0007b423          	sd	zero,8(a5)



static inline int page_ref(struct Page *page) { return page->ref; }

static inline void set_page_ref(struct Page *page, int val) { page->ref = val; }
ffffffffc0200fea:	0007a023          	sw	zero,0(a5)
    for (; p != base + n; p ++) {
ffffffffc0200fee:	02878793          	addi	a5,a5,40
ffffffffc0200ff2:	fed792e3          	bne	a5,a3,ffffffffc0200fd6 <best_fit_free_pages+0x18>
    base->property = n;
ffffffffc0200ff6:	2581                	sext.w	a1,a1
ffffffffc0200ff8:	c90c                	sw	a1,16(a0)
    SetPageProperty(base);
ffffffffc0200ffa:	00850893          	addi	a7,a0,8
    __op_bit(or, __NOP, nr, ((volatile unsigned long *)addr));
ffffffffc0200ffe:	4789                	li	a5,2
ffffffffc0201000:	40f8b02f          	amoor.d	zero,a5,(a7)
    nr_free += n;
ffffffffc0201004:	00005697          	auipc	a3,0x5
ffffffffc0201008:	01468693          	addi	a3,a3,20 # ffffffffc0206018 <free_area>
ffffffffc020100c:	4a98                	lw	a4,16(a3)
    return list->next == list;
ffffffffc020100e:	669c                	ld	a5,8(a3)
        list_add(&free_list, &(base->page_link));
ffffffffc0201010:	01850613          	addi	a2,a0,24
    nr_free += n;
ffffffffc0201014:	9db9                	addw	a1,a1,a4
ffffffffc0201016:	ca8c                	sw	a1,16(a3)
    if (list_empty(&free_list)) {
ffffffffc0201018:	0ad78863          	beq	a5,a3,ffffffffc02010c8 <best_fit_free_pages+0x10a>
            struct Page* page = le2page(le, page_link);
ffffffffc020101c:	fe878713          	addi	a4,a5,-24
ffffffffc0201020:	0006b803          	ld	a6,0(a3)
    if (list_empty(&free_list)) {
ffffffffc0201024:	4581                	li	a1,0
            if (base < page) {
ffffffffc0201026:	00e56a63          	bltu	a0,a4,ffffffffc020103a <best_fit_free_pages+0x7c>
    return listelm->next;
ffffffffc020102a:	6798                	ld	a4,8(a5)
            } else if (list_next(le) == &free_list) {
ffffffffc020102c:	06d70263          	beq	a4,a3,ffffffffc0201090 <best_fit_free_pages+0xd2>
    for (; p != base + n; p ++) {
ffffffffc0201030:	87ba                	mv	a5,a4
            struct Page* page = le2page(le, page_link);
ffffffffc0201032:	fe878713          	addi	a4,a5,-24
            if (base < page) {
ffffffffc0201036:	fee57ae3          	bgeu	a0,a4,ffffffffc020102a <best_fit_free_pages+0x6c>
ffffffffc020103a:	c199                	beqz	a1,ffffffffc0201040 <best_fit_free_pages+0x82>
ffffffffc020103c:	0106b023          	sd	a6,0(a3)
    __list_add(elm, listelm->prev, listelm);
ffffffffc0201040:	6398                	ld	a4,0(a5)
    prev->next = next->prev = elm;
ffffffffc0201042:	e390                	sd	a2,0(a5)
ffffffffc0201044:	e710                	sd	a2,8(a4)
    elm->next = next;
ffffffffc0201046:	f11c                	sd	a5,32(a0)
    elm->prev = prev;
ffffffffc0201048:	ed18                	sd	a4,24(a0)
    if (le != &free_list) {
ffffffffc020104a:	02d70063          	beq	a4,a3,ffffffffc020106a <best_fit_free_pages+0xac>
        if (p + p->property == base) {
ffffffffc020104e:	ff872803          	lw	a6,-8(a4)
        p = le2page(le, page_link);
ffffffffc0201052:	fe870593          	addi	a1,a4,-24
        if (p + p->property == base) {
ffffffffc0201056:	02081613          	slli	a2,a6,0x20
ffffffffc020105a:	9201                	srli	a2,a2,0x20
ffffffffc020105c:	00261793          	slli	a5,a2,0x2
ffffffffc0201060:	97b2                	add	a5,a5,a2
ffffffffc0201062:	078e                	slli	a5,a5,0x3
ffffffffc0201064:	97ae                	add	a5,a5,a1
ffffffffc0201066:	02f50f63          	beq	a0,a5,ffffffffc02010a4 <best_fit_free_pages+0xe6>
    return listelm->next;
ffffffffc020106a:	7118                	ld	a4,32(a0)
    if (le != &free_list) {
ffffffffc020106c:	00d70f63          	beq	a4,a3,ffffffffc020108a <best_fit_free_pages+0xcc>
        if (base + base->property == p) {
ffffffffc0201070:	490c                	lw	a1,16(a0)
        p = le2page(le, page_link);
ffffffffc0201072:	fe870693          	addi	a3,a4,-24
        if (base + base->property == p) {
ffffffffc0201076:	02059613          	slli	a2,a1,0x20
ffffffffc020107a:	9201                	srli	a2,a2,0x20
ffffffffc020107c:	00261793          	slli	a5,a2,0x2
ffffffffc0201080:	97b2                	add	a5,a5,a2
ffffffffc0201082:	078e                	slli	a5,a5,0x3
ffffffffc0201084:	97aa                	add	a5,a5,a0
ffffffffc0201086:	04f68863          	beq	a3,a5,ffffffffc02010d6 <best_fit_free_pages+0x118>
}
ffffffffc020108a:	60a2                	ld	ra,8(sp)
ffffffffc020108c:	0141                	addi	sp,sp,16
ffffffffc020108e:	8082                	ret
    prev->next = next->prev = elm;
ffffffffc0201090:	e790                	sd	a2,8(a5)
    elm->next = next;
ffffffffc0201092:	f114                	sd	a3,32(a0)
    return listelm->next;
ffffffffc0201094:	6798                	ld	a4,8(a5)
    elm->prev = prev;
ffffffffc0201096:	ed1c                	sd	a5,24(a0)
        while ((le = list_next(le)) != &free_list) {
ffffffffc0201098:	02d70563          	beq	a4,a3,ffffffffc02010c2 <best_fit_free_pages+0x104>
    prev->next = next->prev = elm;
ffffffffc020109c:	8832                	mv	a6,a2
ffffffffc020109e:	4585                	li	a1,1
    for (; p != base + n; p ++) {
ffffffffc02010a0:	87ba                	mv	a5,a4
ffffffffc02010a2:	bf41                	j	ffffffffc0201032 <best_fit_free_pages+0x74>
            p->property += base->property;
ffffffffc02010a4:	491c                	lw	a5,16(a0)
ffffffffc02010a6:	0107883b          	addw	a6,a5,a6
ffffffffc02010aa:	ff072c23          	sw	a6,-8(a4)
    __op_bit(and, __NOT, nr, ((volatile unsigned long *)addr));
ffffffffc02010ae:	57f5                	li	a5,-3
ffffffffc02010b0:	60f8b02f          	amoand.d	zero,a5,(a7)
    __list_del(listelm->prev, listelm->next);
ffffffffc02010b4:	6d10                	ld	a2,24(a0)
ffffffffc02010b6:	711c                	ld	a5,32(a0)
            base = p;
ffffffffc02010b8:	852e                	mv	a0,a1
    prev->next = next;
ffffffffc02010ba:	e61c                	sd	a5,8(a2)
    return listelm->next;
ffffffffc02010bc:	6718                	ld	a4,8(a4)
    next->prev = prev;
ffffffffc02010be:	e390                	sd	a2,0(a5)
ffffffffc02010c0:	b775                	j	ffffffffc020106c <best_fit_free_pages+0xae>
ffffffffc02010c2:	e290                	sd	a2,0(a3)
        while ((le = list_next(le)) != &free_list) {
ffffffffc02010c4:	873e                	mv	a4,a5
ffffffffc02010c6:	b761                	j	ffffffffc020104e <best_fit_free_pages+0x90>
}
ffffffffc02010c8:	60a2                	ld	ra,8(sp)
    prev->next = next->prev = elm;
ffffffffc02010ca:	e390                	sd	a2,0(a5)
ffffffffc02010cc:	e790                	sd	a2,8(a5)
    elm->next = next;
ffffffffc02010ce:	f11c                	sd	a5,32(a0)
    elm->prev = prev;
ffffffffc02010d0:	ed1c                	sd	a5,24(a0)
ffffffffc02010d2:	0141                	addi	sp,sp,16
ffffffffc02010d4:	8082                	ret
            base->property += p->property;
ffffffffc02010d6:	ff872783          	lw	a5,-8(a4)
ffffffffc02010da:	ff070693          	addi	a3,a4,-16
ffffffffc02010de:	9dbd                	addw	a1,a1,a5
ffffffffc02010e0:	c90c                	sw	a1,16(a0)
ffffffffc02010e2:	57f5                	li	a5,-3
ffffffffc02010e4:	60f6b02f          	amoand.d	zero,a5,(a3)
    __list_del(listelm->prev, listelm->next);
ffffffffc02010e8:	6314                	ld	a3,0(a4)
ffffffffc02010ea:	671c                	ld	a5,8(a4)
}
ffffffffc02010ec:	60a2                	ld	ra,8(sp)
    prev->next = next;
ffffffffc02010ee:	e69c                	sd	a5,8(a3)
    next->prev = prev;
ffffffffc02010f0:	e394                	sd	a3,0(a5)
ffffffffc02010f2:	0141                	addi	sp,sp,16
ffffffffc02010f4:	8082                	ret
        assert(!PageReserved(p) && !PageProperty(p));
ffffffffc02010f6:	00001697          	auipc	a3,0x1
ffffffffc02010fa:	33a68693          	addi	a3,a3,826 # ffffffffc0202430 <commands+0x7f0>
ffffffffc02010fe:	00001617          	auipc	a2,0x1
ffffffffc0201102:	04260613          	addi	a2,a2,66 # ffffffffc0202140 <commands+0x500>
ffffffffc0201106:	09800593          	li	a1,152
ffffffffc020110a:	00001517          	auipc	a0,0x1
ffffffffc020110e:	04e50513          	addi	a0,a0,78 # ffffffffc0202158 <commands+0x518>
ffffffffc0201112:	a9aff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert(n > 0);
ffffffffc0201116:	00001697          	auipc	a3,0x1
ffffffffc020111a:	02268693          	addi	a3,a3,34 # ffffffffc0202138 <commands+0x4f8>
ffffffffc020111e:	00001617          	auipc	a2,0x1
ffffffffc0201122:	02260613          	addi	a2,a2,34 # ffffffffc0202140 <commands+0x500>
ffffffffc0201126:	09500593          	li	a1,149
ffffffffc020112a:	00001517          	auipc	a0,0x1
ffffffffc020112e:	02e50513          	addi	a0,a0,46 # ffffffffc0202158 <commands+0x518>
ffffffffc0201132:	a7aff0ef          	jal	ra,ffffffffc02003ac <__panic>

ffffffffc0201136 <best_fit_init_memmap>:
best_fit_init_memmap(struct Page *base, size_t n) {
ffffffffc0201136:	1141                	addi	sp,sp,-16
ffffffffc0201138:	e406                	sd	ra,8(sp)
    assert(n > 0);
ffffffffc020113a:	c9e1                	beqz	a1,ffffffffc020120a <best_fit_init_memmap+0xd4>
    for (; p != base + n; p ++) {
ffffffffc020113c:	00259693          	slli	a3,a1,0x2
ffffffffc0201140:	96ae                	add	a3,a3,a1
ffffffffc0201142:	068e                	slli	a3,a3,0x3
ffffffffc0201144:	96aa                	add	a3,a3,a0
ffffffffc0201146:	87aa                	mv	a5,a0
ffffffffc0201148:	00d50f63          	beq	a0,a3,ffffffffc0201166 <best_fit_init_memmap+0x30>
    return (((*(volatile unsigned long *)addr) >> nr) & 1);
ffffffffc020114c:	6798                	ld	a4,8(a5)
        assert(PageReserved(p));
ffffffffc020114e:	8b05                	andi	a4,a4,1
ffffffffc0201150:	cf49                	beqz	a4,ffffffffc02011ea <best_fit_init_memmap+0xb4>
        p->flags = p->property = 0;
ffffffffc0201152:	0007a823          	sw	zero,16(a5)
ffffffffc0201156:	0007b423          	sd	zero,8(a5)
ffffffffc020115a:	0007a023          	sw	zero,0(a5)
    for (; p != base + n; p ++) {
ffffffffc020115e:	02878793          	addi	a5,a5,40
ffffffffc0201162:	fed795e3          	bne	a5,a3,ffffffffc020114c <best_fit_init_memmap+0x16>
    base->property = n;
ffffffffc0201166:	2581                	sext.w	a1,a1
ffffffffc0201168:	c90c                	sw	a1,16(a0)
    __op_bit(or, __NOP, nr, ((volatile unsigned long *)addr));
ffffffffc020116a:	4789                	li	a5,2
ffffffffc020116c:	00850713          	addi	a4,a0,8
ffffffffc0201170:	40f7302f          	amoor.d	zero,a5,(a4)
    nr_free += n;
ffffffffc0201174:	00005697          	auipc	a3,0x5
ffffffffc0201178:	ea468693          	addi	a3,a3,-348 # ffffffffc0206018 <free_area>
ffffffffc020117c:	4a98                	lw	a4,16(a3)
    return list->next == list;
ffffffffc020117e:	669c                	ld	a5,8(a3)
        list_add(&free_list, &(base->page_link));
ffffffffc0201180:	01850613          	addi	a2,a0,24
    nr_free += n;
ffffffffc0201184:	9db9                	addw	a1,a1,a4
ffffffffc0201186:	ca8c                	sw	a1,16(a3)
    if (list_empty(&free_list)) {
ffffffffc0201188:	04d78a63          	beq	a5,a3,ffffffffc02011dc <best_fit_init_memmap+0xa6>
            struct Page* page = le2page(le, page_link);
ffffffffc020118c:	fe878713          	addi	a4,a5,-24
ffffffffc0201190:	0006b803          	ld	a6,0(a3)
    if (list_empty(&free_list)) {
ffffffffc0201194:	4581                	li	a1,0
            if (base < page) {
ffffffffc0201196:	00e56a63          	bltu	a0,a4,ffffffffc02011aa <best_fit_init_memmap+0x74>
    return listelm->next;
ffffffffc020119a:	6798                	ld	a4,8(a5)
            else if (list_next(le) == &free_list) {
ffffffffc020119c:	02d70263          	beq	a4,a3,ffffffffc02011c0 <best_fit_init_memmap+0x8a>
    for (; p != base + n; p ++) {
ffffffffc02011a0:	87ba                	mv	a5,a4
            struct Page* page = le2page(le, page_link);
ffffffffc02011a2:	fe878713          	addi	a4,a5,-24
            if (base < page) {
ffffffffc02011a6:	fee57ae3          	bgeu	a0,a4,ffffffffc020119a <best_fit_init_memmap+0x64>
ffffffffc02011aa:	c199                	beqz	a1,ffffffffc02011b0 <best_fit_init_memmap+0x7a>
ffffffffc02011ac:	0106b023          	sd	a6,0(a3)
    __list_add(elm, listelm->prev, listelm);
ffffffffc02011b0:	6398                	ld	a4,0(a5)
}
ffffffffc02011b2:	60a2                	ld	ra,8(sp)
    prev->next = next->prev = elm;
ffffffffc02011b4:	e390                	sd	a2,0(a5)
ffffffffc02011b6:	e710                	sd	a2,8(a4)
    elm->next = next;
ffffffffc02011b8:	f11c                	sd	a5,32(a0)
    elm->prev = prev;
ffffffffc02011ba:	ed18                	sd	a4,24(a0)
ffffffffc02011bc:	0141                	addi	sp,sp,16
ffffffffc02011be:	8082                	ret
    prev->next = next->prev = elm;
ffffffffc02011c0:	e790                	sd	a2,8(a5)
    elm->next = next;
ffffffffc02011c2:	f114                	sd	a3,32(a0)
    return listelm->next;
ffffffffc02011c4:	6798                	ld	a4,8(a5)
    elm->prev = prev;
ffffffffc02011c6:	ed1c                	sd	a5,24(a0)
        while ((le = list_next(le)) != &free_list) {
ffffffffc02011c8:	00d70663          	beq	a4,a3,ffffffffc02011d4 <best_fit_init_memmap+0x9e>
    prev->next = next->prev = elm;
ffffffffc02011cc:	8832                	mv	a6,a2
ffffffffc02011ce:	4585                	li	a1,1
    for (; p != base + n; p ++) {
ffffffffc02011d0:	87ba                	mv	a5,a4
ffffffffc02011d2:	bfc1                	j	ffffffffc02011a2 <best_fit_init_memmap+0x6c>
}
ffffffffc02011d4:	60a2                	ld	ra,8(sp)
ffffffffc02011d6:	e290                	sd	a2,0(a3)
ffffffffc02011d8:	0141                	addi	sp,sp,16
ffffffffc02011da:	8082                	ret
ffffffffc02011dc:	60a2                	ld	ra,8(sp)
ffffffffc02011de:	e390                	sd	a2,0(a5)
ffffffffc02011e0:	e790                	sd	a2,8(a5)
    elm->next = next;
ffffffffc02011e2:	f11c                	sd	a5,32(a0)
    elm->prev = prev;
ffffffffc02011e4:	ed1c                	sd	a5,24(a0)
ffffffffc02011e6:	0141                	addi	sp,sp,16
ffffffffc02011e8:	8082                	ret
        assert(PageReserved(p));
ffffffffc02011ea:	00001697          	auipc	a3,0x1
ffffffffc02011ee:	26e68693          	addi	a3,a3,622 # ffffffffc0202458 <commands+0x818>
ffffffffc02011f2:	00001617          	auipc	a2,0x1
ffffffffc02011f6:	f4e60613          	addi	a2,a2,-178 # ffffffffc0202140 <commands+0x500>
ffffffffc02011fa:	05000593          	li	a1,80
ffffffffc02011fe:	00001517          	auipc	a0,0x1
ffffffffc0201202:	f5a50513          	addi	a0,a0,-166 # ffffffffc0202158 <commands+0x518>
ffffffffc0201206:	9a6ff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert(n > 0);
ffffffffc020120a:	00001697          	auipc	a3,0x1
ffffffffc020120e:	f2e68693          	addi	a3,a3,-210 # ffffffffc0202138 <commands+0x4f8>
ffffffffc0201212:	00001617          	auipc	a2,0x1
ffffffffc0201216:	f2e60613          	addi	a2,a2,-210 # ffffffffc0202140 <commands+0x500>
ffffffffc020121a:	04d00593          	li	a1,77
ffffffffc020121e:	00001517          	auipc	a0,0x1
ffffffffc0201222:	f3a50513          	addi	a0,a0,-198 # ffffffffc0202158 <commands+0x518>
ffffffffc0201226:	986ff0ef          	jal	ra,ffffffffc02003ac <__panic>

ffffffffc020122a <alloc_pages>:
#include <defs.h>
#include <intr.h>
#include <riscv.h>

static inline bool __intr_save(void) {
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc020122a:	100027f3          	csrr	a5,sstatus
ffffffffc020122e:	8b89                	andi	a5,a5,2
ffffffffc0201230:	e799                	bnez	a5,ffffffffc020123e <alloc_pages+0x14>
struct Page *alloc_pages(size_t n) {
    struct Page *page = NULL;
    bool intr_flag;
    local_intr_save(intr_flag);
    {
        page = pmm_manager->alloc_pages(n);
ffffffffc0201232:	00005797          	auipc	a5,0x5
ffffffffc0201236:	2267b783          	ld	a5,550(a5) # ffffffffc0206458 <pmm_manager>
ffffffffc020123a:	6f9c                	ld	a5,24(a5)
ffffffffc020123c:	8782                	jr	a5
struct Page *alloc_pages(size_t n) {
ffffffffc020123e:	1141                	addi	sp,sp,-16
ffffffffc0201240:	e406                	sd	ra,8(sp)
ffffffffc0201242:	e022                	sd	s0,0(sp)
ffffffffc0201244:	842a                	mv	s0,a0
        intr_disable();
ffffffffc0201246:	a18ff0ef          	jal	ra,ffffffffc020045e <intr_disable>
        page = pmm_manager->alloc_pages(n);
ffffffffc020124a:	00005797          	auipc	a5,0x5
ffffffffc020124e:	20e7b783          	ld	a5,526(a5) # ffffffffc0206458 <pmm_manager>
ffffffffc0201252:	6f9c                	ld	a5,24(a5)
ffffffffc0201254:	8522                	mv	a0,s0
ffffffffc0201256:	9782                	jalr	a5
ffffffffc0201258:	842a                	mv	s0,a0
    return 0;
}

static inline void __intr_restore(bool flag) {
    if (flag) {
        intr_enable();
ffffffffc020125a:	9feff0ef          	jal	ra,ffffffffc0200458 <intr_enable>
    }
    local_intr_restore(intr_flag);
    return page;
}
ffffffffc020125e:	60a2                	ld	ra,8(sp)
ffffffffc0201260:	8522                	mv	a0,s0
ffffffffc0201262:	6402                	ld	s0,0(sp)
ffffffffc0201264:	0141                	addi	sp,sp,16
ffffffffc0201266:	8082                	ret

ffffffffc0201268 <free_pages>:
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0201268:	100027f3          	csrr	a5,sstatus
ffffffffc020126c:	8b89                	andi	a5,a5,2
ffffffffc020126e:	e799                	bnez	a5,ffffffffc020127c <free_pages+0x14>
// free_pages - call pmm->free_pages to free a continuous n*PAGESIZE memory
void free_pages(struct Page *base, size_t n) {
    bool intr_flag;
    local_intr_save(intr_flag);
    {
        pmm_manager->free_pages(base, n);
ffffffffc0201270:	00005797          	auipc	a5,0x5
ffffffffc0201274:	1e87b783          	ld	a5,488(a5) # ffffffffc0206458 <pmm_manager>
ffffffffc0201278:	739c                	ld	a5,32(a5)
ffffffffc020127a:	8782                	jr	a5
void free_pages(struct Page *base, size_t n) {
ffffffffc020127c:	1101                	addi	sp,sp,-32
ffffffffc020127e:	ec06                	sd	ra,24(sp)
ffffffffc0201280:	e822                	sd	s0,16(sp)
ffffffffc0201282:	e426                	sd	s1,8(sp)
ffffffffc0201284:	842a                	mv	s0,a0
ffffffffc0201286:	84ae                	mv	s1,a1
        intr_disable();
ffffffffc0201288:	9d6ff0ef          	jal	ra,ffffffffc020045e <intr_disable>
        pmm_manager->free_pages(base, n);
ffffffffc020128c:	00005797          	auipc	a5,0x5
ffffffffc0201290:	1cc7b783          	ld	a5,460(a5) # ffffffffc0206458 <pmm_manager>
ffffffffc0201294:	739c                	ld	a5,32(a5)
ffffffffc0201296:	85a6                	mv	a1,s1
ffffffffc0201298:	8522                	mv	a0,s0
ffffffffc020129a:	9782                	jalr	a5
    }
    local_intr_restore(intr_flag);
}
ffffffffc020129c:	6442                	ld	s0,16(sp)
ffffffffc020129e:	60e2                	ld	ra,24(sp)
ffffffffc02012a0:	64a2                	ld	s1,8(sp)
ffffffffc02012a2:	6105                	addi	sp,sp,32
        intr_enable();
ffffffffc02012a4:	9b4ff06f          	j	ffffffffc0200458 <intr_enable>

ffffffffc02012a8 <nr_free_pages>:
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc02012a8:	100027f3          	csrr	a5,sstatus
ffffffffc02012ac:	8b89                	andi	a5,a5,2
ffffffffc02012ae:	e799                	bnez	a5,ffffffffc02012bc <nr_free_pages+0x14>
size_t nr_free_pages(void) {
    size_t ret;
    bool intr_flag;
    local_intr_save(intr_flag);
    {
        ret = pmm_manager->nr_free_pages();
ffffffffc02012b0:	00005797          	auipc	a5,0x5
ffffffffc02012b4:	1a87b783          	ld	a5,424(a5) # ffffffffc0206458 <pmm_manager>
ffffffffc02012b8:	779c                	ld	a5,40(a5)
ffffffffc02012ba:	8782                	jr	a5
size_t nr_free_pages(void) {
ffffffffc02012bc:	1141                	addi	sp,sp,-16
ffffffffc02012be:	e406                	sd	ra,8(sp)
ffffffffc02012c0:	e022                	sd	s0,0(sp)
        intr_disable();
ffffffffc02012c2:	99cff0ef          	jal	ra,ffffffffc020045e <intr_disable>
        ret = pmm_manager->nr_free_pages();
ffffffffc02012c6:	00005797          	auipc	a5,0x5
ffffffffc02012ca:	1927b783          	ld	a5,402(a5) # ffffffffc0206458 <pmm_manager>
ffffffffc02012ce:	779c                	ld	a5,40(a5)
ffffffffc02012d0:	9782                	jalr	a5
ffffffffc02012d2:	842a                	mv	s0,a0
        intr_enable();
ffffffffc02012d4:	984ff0ef          	jal	ra,ffffffffc0200458 <intr_enable>
    }
    local_intr_restore(intr_flag);
    return ret;
}
ffffffffc02012d8:	60a2                	ld	ra,8(sp)
ffffffffc02012da:	8522                	mv	a0,s0
ffffffffc02012dc:	6402                	ld	s0,0(sp)
ffffffffc02012de:	0141                	addi	sp,sp,16
ffffffffc02012e0:	8082                	ret

ffffffffc02012e2 <pmm_init>:
    pmm_manager = &best_fit_pmm_manager;
ffffffffc02012e2:	00001797          	auipc	a5,0x1
ffffffffc02012e6:	19e78793          	addi	a5,a5,414 # ffffffffc0202480 <best_fit_pmm_manager>
    cprintf("memory management: %s\n", pmm_manager->name);
ffffffffc02012ea:	638c                	ld	a1,0(a5)
        init_memmap(pa2page(mem_begin), (mem_end - mem_begin) / PGSIZE);
    }
}

/* pmm_init - initialize the physical memory management */
void pmm_init(void) {
ffffffffc02012ec:	1101                	addi	sp,sp,-32
ffffffffc02012ee:	e426                	sd	s1,8(sp)
    cprintf("memory management: %s\n", pmm_manager->name);
ffffffffc02012f0:	00001517          	auipc	a0,0x1
ffffffffc02012f4:	1c850513          	addi	a0,a0,456 # ffffffffc02024b8 <best_fit_pmm_manager+0x38>
    pmm_manager = &best_fit_pmm_manager;
ffffffffc02012f8:	00005497          	auipc	s1,0x5
ffffffffc02012fc:	16048493          	addi	s1,s1,352 # ffffffffc0206458 <pmm_manager>
void pmm_init(void) {
ffffffffc0201300:	ec06                	sd	ra,24(sp)
ffffffffc0201302:	e822                	sd	s0,16(sp)
    pmm_manager = &best_fit_pmm_manager;
ffffffffc0201304:	e09c                	sd	a5,0(s1)
    cprintf("memory management: %s\n", pmm_manager->name);
ffffffffc0201306:	dadfe0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    pmm_manager->init();
ffffffffc020130a:	609c                	ld	a5,0(s1)
    va_pa_offset = PHYSICAL_MEMORY_OFFSET;
ffffffffc020130c:	00005417          	auipc	s0,0x5
ffffffffc0201310:	16440413          	addi	s0,s0,356 # ffffffffc0206470 <va_pa_offset>
    pmm_manager->init();
ffffffffc0201314:	679c                	ld	a5,8(a5)
ffffffffc0201316:	9782                	jalr	a5
    va_pa_offset = PHYSICAL_MEMORY_OFFSET;
ffffffffc0201318:	57f5                	li	a5,-3
ffffffffc020131a:	07fa                	slli	a5,a5,0x1e
    cprintf("physcial memory map:\n");
ffffffffc020131c:	00001517          	auipc	a0,0x1
ffffffffc0201320:	1b450513          	addi	a0,a0,436 # ffffffffc02024d0 <best_fit_pmm_manager+0x50>
    va_pa_offset = PHYSICAL_MEMORY_OFFSET;
ffffffffc0201324:	e01c                	sd	a5,0(s0)
    cprintf("physcial memory map:\n");
ffffffffc0201326:	d8dfe0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  memory: 0x%016lx, [0x%016lx, 0x%016lx].\n", mem_size, mem_begin,
ffffffffc020132a:	46c5                	li	a3,17
ffffffffc020132c:	06ee                	slli	a3,a3,0x1b
ffffffffc020132e:	40100613          	li	a2,1025
ffffffffc0201332:	16fd                	addi	a3,a3,-1
ffffffffc0201334:	07e005b7          	lui	a1,0x7e00
ffffffffc0201338:	0656                	slli	a2,a2,0x15
ffffffffc020133a:	00001517          	auipc	a0,0x1
ffffffffc020133e:	1ae50513          	addi	a0,a0,430 # ffffffffc02024e8 <best_fit_pmm_manager+0x68>
ffffffffc0201342:	d71fe0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    pages = (struct Page *)ROUNDUP((void *)end, PGSIZE);
ffffffffc0201346:	777d                	lui	a4,0xfffff
ffffffffc0201348:	00006797          	auipc	a5,0x6
ffffffffc020134c:	13778793          	addi	a5,a5,311 # ffffffffc020747f <end+0xfff>
ffffffffc0201350:	8ff9                	and	a5,a5,a4
    npage = maxpa / PGSIZE;
ffffffffc0201352:	00005517          	auipc	a0,0x5
ffffffffc0201356:	0f650513          	addi	a0,a0,246 # ffffffffc0206448 <npage>
ffffffffc020135a:	00088737          	lui	a4,0x88
    pages = (struct Page *)ROUNDUP((void *)end, PGSIZE);
ffffffffc020135e:	00005597          	auipc	a1,0x5
ffffffffc0201362:	0f258593          	addi	a1,a1,242 # ffffffffc0206450 <pages>
    npage = maxpa / PGSIZE;
ffffffffc0201366:	e118                	sd	a4,0(a0)
    pages = (struct Page *)ROUNDUP((void *)end, PGSIZE);
ffffffffc0201368:	e19c                	sd	a5,0(a1)
ffffffffc020136a:	4681                	li	a3,0
    for (size_t i = 0; i < npage - nbase; i++) {
ffffffffc020136c:	4701                	li	a4,0
ffffffffc020136e:	4885                	li	a7,1
ffffffffc0201370:	fff80837          	lui	a6,0xfff80
ffffffffc0201374:	a011                	j	ffffffffc0201378 <pmm_init+0x96>
        SetPageReserved(pages + i);
ffffffffc0201376:	619c                	ld	a5,0(a1)
ffffffffc0201378:	97b6                	add	a5,a5,a3
ffffffffc020137a:	07a1                	addi	a5,a5,8
ffffffffc020137c:	4117b02f          	amoor.d	zero,a7,(a5)
    for (size_t i = 0; i < npage - nbase; i++) {
ffffffffc0201380:	611c                	ld	a5,0(a0)
ffffffffc0201382:	0705                	addi	a4,a4,1
ffffffffc0201384:	02868693          	addi	a3,a3,40
ffffffffc0201388:	01078633          	add	a2,a5,a6
ffffffffc020138c:	fec765e3          	bltu	a4,a2,ffffffffc0201376 <pmm_init+0x94>
    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * (npage - nbase));
ffffffffc0201390:	6190                	ld	a2,0(a1)
ffffffffc0201392:	00279713          	slli	a4,a5,0x2
ffffffffc0201396:	973e                	add	a4,a4,a5
ffffffffc0201398:	fec006b7          	lui	a3,0xfec00
ffffffffc020139c:	070e                	slli	a4,a4,0x3
ffffffffc020139e:	96b2                	add	a3,a3,a2
ffffffffc02013a0:	96ba                	add	a3,a3,a4
ffffffffc02013a2:	c0200737          	lui	a4,0xc0200
ffffffffc02013a6:	08e6ef63          	bltu	a3,a4,ffffffffc0201444 <pmm_init+0x162>
ffffffffc02013aa:	6018                	ld	a4,0(s0)
    if (freemem < mem_end) {
ffffffffc02013ac:	45c5                	li	a1,17
ffffffffc02013ae:	05ee                	slli	a1,a1,0x1b
    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * (npage - nbase));
ffffffffc02013b0:	8e99                	sub	a3,a3,a4
    if (freemem < mem_end) {
ffffffffc02013b2:	04b6e863          	bltu	a3,a1,ffffffffc0201402 <pmm_init+0x120>
    satp_physical = PADDR(satp_virtual);
    cprintf("satp virtual address: 0x%016lx\nsatp physical address: 0x%016lx\n", satp_virtual, satp_physical);
}

static void check_alloc_page(void) {
    pmm_manager->check();
ffffffffc02013b6:	609c                	ld	a5,0(s1)
ffffffffc02013b8:	7b9c                	ld	a5,48(a5)
ffffffffc02013ba:	9782                	jalr	a5
    cprintf("check_alloc_page() succeeded!\n");
ffffffffc02013bc:	00001517          	auipc	a0,0x1
ffffffffc02013c0:	1c450513          	addi	a0,a0,452 # ffffffffc0202580 <best_fit_pmm_manager+0x100>
ffffffffc02013c4:	ceffe0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    satp_virtual = (pte_t*)boot_page_table_sv39;
ffffffffc02013c8:	00004597          	auipc	a1,0x4
ffffffffc02013cc:	c3858593          	addi	a1,a1,-968 # ffffffffc0205000 <boot_page_table_sv39>
ffffffffc02013d0:	00005797          	auipc	a5,0x5
ffffffffc02013d4:	08b7bc23          	sd	a1,152(a5) # ffffffffc0206468 <satp_virtual>
    satp_physical = PADDR(satp_virtual);
ffffffffc02013d8:	c02007b7          	lui	a5,0xc0200
ffffffffc02013dc:	08f5e063          	bltu	a1,a5,ffffffffc020145c <pmm_init+0x17a>
ffffffffc02013e0:	6010                	ld	a2,0(s0)
}
ffffffffc02013e2:	6442                	ld	s0,16(sp)
ffffffffc02013e4:	60e2                	ld	ra,24(sp)
ffffffffc02013e6:	64a2                	ld	s1,8(sp)
    satp_physical = PADDR(satp_virtual);
ffffffffc02013e8:	40c58633          	sub	a2,a1,a2
ffffffffc02013ec:	00005797          	auipc	a5,0x5
ffffffffc02013f0:	06c7ba23          	sd	a2,116(a5) # ffffffffc0206460 <satp_physical>
    cprintf("satp virtual address: 0x%016lx\nsatp physical address: 0x%016lx\n", satp_virtual, satp_physical);
ffffffffc02013f4:	00001517          	auipc	a0,0x1
ffffffffc02013f8:	1ac50513          	addi	a0,a0,428 # ffffffffc02025a0 <best_fit_pmm_manager+0x120>
}
ffffffffc02013fc:	6105                	addi	sp,sp,32
    cprintf("satp virtual address: 0x%016lx\nsatp physical address: 0x%016lx\n", satp_virtual, satp_physical);
ffffffffc02013fe:	cb5fe06f          	j	ffffffffc02000b2 <cprintf>
    mem_begin = ROUNDUP(freemem, PGSIZE);
ffffffffc0201402:	6705                	lui	a4,0x1
ffffffffc0201404:	177d                	addi	a4,a4,-1
ffffffffc0201406:	96ba                	add	a3,a3,a4
ffffffffc0201408:	777d                	lui	a4,0xfffff
ffffffffc020140a:	8ef9                	and	a3,a3,a4
static inline int page_ref_dec(struct Page *page) {
    page->ref -= 1;
    return page->ref;
}
static inline struct Page *pa2page(uintptr_t pa) {
    if (PPN(pa) >= npage) {
ffffffffc020140c:	00c6d513          	srli	a0,a3,0xc
ffffffffc0201410:	00f57e63          	bgeu	a0,a5,ffffffffc020142c <pmm_init+0x14a>
    pmm_manager->init_memmap(base, n);
ffffffffc0201414:	609c                	ld	a5,0(s1)
        panic("pa2page called with invalid pa");
    }
    return &pages[PPN(pa) - nbase];
ffffffffc0201416:	982a                	add	a6,a6,a0
ffffffffc0201418:	00281513          	slli	a0,a6,0x2
ffffffffc020141c:	9542                	add	a0,a0,a6
ffffffffc020141e:	6b9c                	ld	a5,16(a5)
        init_memmap(pa2page(mem_begin), (mem_end - mem_begin) / PGSIZE);
ffffffffc0201420:	8d95                	sub	a1,a1,a3
ffffffffc0201422:	050e                	slli	a0,a0,0x3
    pmm_manager->init_memmap(base, n);
ffffffffc0201424:	81b1                	srli	a1,a1,0xc
ffffffffc0201426:	9532                	add	a0,a0,a2
ffffffffc0201428:	9782                	jalr	a5
}
ffffffffc020142a:	b771                	j	ffffffffc02013b6 <pmm_init+0xd4>
        panic("pa2page called with invalid pa");
ffffffffc020142c:	00001617          	auipc	a2,0x1
ffffffffc0201430:	12460613          	addi	a2,a2,292 # ffffffffc0202550 <best_fit_pmm_manager+0xd0>
ffffffffc0201434:	06b00593          	li	a1,107
ffffffffc0201438:	00001517          	auipc	a0,0x1
ffffffffc020143c:	13850513          	addi	a0,a0,312 # ffffffffc0202570 <best_fit_pmm_manager+0xf0>
ffffffffc0201440:	f6dfe0ef          	jal	ra,ffffffffc02003ac <__panic>
    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * (npage - nbase));
ffffffffc0201444:	00001617          	auipc	a2,0x1
ffffffffc0201448:	0d460613          	addi	a2,a2,212 # ffffffffc0202518 <best_fit_pmm_manager+0x98>
ffffffffc020144c:	07000593          	li	a1,112
ffffffffc0201450:	00001517          	auipc	a0,0x1
ffffffffc0201454:	0f050513          	addi	a0,a0,240 # ffffffffc0202540 <best_fit_pmm_manager+0xc0>
ffffffffc0201458:	f55fe0ef          	jal	ra,ffffffffc02003ac <__panic>
    satp_physical = PADDR(satp_virtual);
ffffffffc020145c:	86ae                	mv	a3,a1
ffffffffc020145e:	00001617          	auipc	a2,0x1
ffffffffc0201462:	0ba60613          	addi	a2,a2,186 # ffffffffc0202518 <best_fit_pmm_manager+0x98>
ffffffffc0201466:	08b00593          	li	a1,139
ffffffffc020146a:	00001517          	auipc	a0,0x1
ffffffffc020146e:	0d650513          	addi	a0,a0,214 # ffffffffc0202540 <best_fit_pmm_manager+0xc0>
ffffffffc0201472:	f3bfe0ef          	jal	ra,ffffffffc02003ac <__panic>

ffffffffc0201476 <printnum>:
 * */
static void
printnum(void (*putch)(int, void*), void *putdat,
        unsigned long long num, unsigned base, int width, int padc) {
    unsigned long long result = num;
    unsigned mod = do_div(result, base);
ffffffffc0201476:	02069813          	slli	a6,a3,0x20
        unsigned long long num, unsigned base, int width, int padc) {
ffffffffc020147a:	7179                	addi	sp,sp,-48
    unsigned mod = do_div(result, base);
ffffffffc020147c:	02085813          	srli	a6,a6,0x20
        unsigned long long num, unsigned base, int width, int padc) {
ffffffffc0201480:	e052                	sd	s4,0(sp)
    unsigned mod = do_div(result, base);
ffffffffc0201482:	03067a33          	remu	s4,a2,a6
        unsigned long long num, unsigned base, int width, int padc) {
ffffffffc0201486:	f022                	sd	s0,32(sp)
ffffffffc0201488:	ec26                	sd	s1,24(sp)
ffffffffc020148a:	e84a                	sd	s2,16(sp)
ffffffffc020148c:	f406                	sd	ra,40(sp)
ffffffffc020148e:	e44e                	sd	s3,8(sp)
ffffffffc0201490:	84aa                	mv	s1,a0
ffffffffc0201492:	892e                	mv	s2,a1
    // first recursively print all preceding (more significant) digits
    if (num >= base) {
        printnum(putch, putdat, result, base, width - 1, padc);
    } else {
        // print any needed pad characters before first digit
        while (-- width > 0)
ffffffffc0201494:	fff7041b          	addiw	s0,a4,-1
    unsigned mod = do_div(result, base);
ffffffffc0201498:	2a01                	sext.w	s4,s4
    if (num >= base) {
ffffffffc020149a:	03067e63          	bgeu	a2,a6,ffffffffc02014d6 <printnum+0x60>
ffffffffc020149e:	89be                	mv	s3,a5
        while (-- width > 0)
ffffffffc02014a0:	00805763          	blez	s0,ffffffffc02014ae <printnum+0x38>
ffffffffc02014a4:	347d                	addiw	s0,s0,-1
            putch(padc, putdat);
ffffffffc02014a6:	85ca                	mv	a1,s2
ffffffffc02014a8:	854e                	mv	a0,s3
ffffffffc02014aa:	9482                	jalr	s1
        while (-- width > 0)
ffffffffc02014ac:	fc65                	bnez	s0,ffffffffc02014a4 <printnum+0x2e>
    }
    // then print this (the least significant) digit
    putch("0123456789abcdef"[mod], putdat);
ffffffffc02014ae:	1a02                	slli	s4,s4,0x20
ffffffffc02014b0:	00001797          	auipc	a5,0x1
ffffffffc02014b4:	13078793          	addi	a5,a5,304 # ffffffffc02025e0 <best_fit_pmm_manager+0x160>
ffffffffc02014b8:	020a5a13          	srli	s4,s4,0x20
ffffffffc02014bc:	9a3e                	add	s4,s4,a5
}
ffffffffc02014be:	7402                	ld	s0,32(sp)
    putch("0123456789abcdef"[mod], putdat);
ffffffffc02014c0:	000a4503          	lbu	a0,0(s4)
}
ffffffffc02014c4:	70a2                	ld	ra,40(sp)
ffffffffc02014c6:	69a2                	ld	s3,8(sp)
ffffffffc02014c8:	6a02                	ld	s4,0(sp)
    putch("0123456789abcdef"[mod], putdat);
ffffffffc02014ca:	85ca                	mv	a1,s2
ffffffffc02014cc:	87a6                	mv	a5,s1
}
ffffffffc02014ce:	6942                	ld	s2,16(sp)
ffffffffc02014d0:	64e2                	ld	s1,24(sp)
ffffffffc02014d2:	6145                	addi	sp,sp,48
    putch("0123456789abcdef"[mod], putdat);
ffffffffc02014d4:	8782                	jr	a5
        printnum(putch, putdat, result, base, width - 1, padc);
ffffffffc02014d6:	03065633          	divu	a2,a2,a6
ffffffffc02014da:	8722                	mv	a4,s0
ffffffffc02014dc:	f9bff0ef          	jal	ra,ffffffffc0201476 <printnum>
ffffffffc02014e0:	b7f9                	j	ffffffffc02014ae <printnum+0x38>

ffffffffc02014e2 <vprintfmt>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want printfmt() instead.
 * */
void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap) {
ffffffffc02014e2:	7119                	addi	sp,sp,-128
ffffffffc02014e4:	f4a6                	sd	s1,104(sp)
ffffffffc02014e6:	f0ca                	sd	s2,96(sp)
ffffffffc02014e8:	ecce                	sd	s3,88(sp)
ffffffffc02014ea:	e8d2                	sd	s4,80(sp)
ffffffffc02014ec:	e4d6                	sd	s5,72(sp)
ffffffffc02014ee:	e0da                	sd	s6,64(sp)
ffffffffc02014f0:	fc5e                	sd	s7,56(sp)
ffffffffc02014f2:	f06a                	sd	s10,32(sp)
ffffffffc02014f4:	fc86                	sd	ra,120(sp)
ffffffffc02014f6:	f8a2                	sd	s0,112(sp)
ffffffffc02014f8:	f862                	sd	s8,48(sp)
ffffffffc02014fa:	f466                	sd	s9,40(sp)
ffffffffc02014fc:	ec6e                	sd	s11,24(sp)
ffffffffc02014fe:	892a                	mv	s2,a0
ffffffffc0201500:	84ae                	mv	s1,a1
ffffffffc0201502:	8d32                	mv	s10,a2
ffffffffc0201504:	8a36                	mv	s4,a3
    register int ch, err;
    unsigned long long num;
    int base, width, precision, lflag, altflag;

    while (1) {
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc0201506:	02500993          	li	s3,37
            putch(ch, putdat);
        }

        // Process a %-escape sequence
        char padc = ' ';
        width = precision = -1;
ffffffffc020150a:	5b7d                	li	s6,-1
ffffffffc020150c:	00001a97          	auipc	s5,0x1
ffffffffc0201510:	108a8a93          	addi	s5,s5,264 # ffffffffc0202614 <best_fit_pmm_manager+0x194>
        case 'e':
            err = va_arg(ap, int);
            if (err < 0) {
                err = -err;
            }
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
ffffffffc0201514:	00001b97          	auipc	s7,0x1
ffffffffc0201518:	2dcb8b93          	addi	s7,s7,732 # ffffffffc02027f0 <error_string>
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc020151c:	000d4503          	lbu	a0,0(s10)
ffffffffc0201520:	001d0413          	addi	s0,s10,1
ffffffffc0201524:	01350a63          	beq	a0,s3,ffffffffc0201538 <vprintfmt+0x56>
            if (ch == '\0') {
ffffffffc0201528:	c121                	beqz	a0,ffffffffc0201568 <vprintfmt+0x86>
            putch(ch, putdat);
ffffffffc020152a:	85a6                	mv	a1,s1
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc020152c:	0405                	addi	s0,s0,1
            putch(ch, putdat);
ffffffffc020152e:	9902                	jalr	s2
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc0201530:	fff44503          	lbu	a0,-1(s0)
ffffffffc0201534:	ff351ae3          	bne	a0,s3,ffffffffc0201528 <vprintfmt+0x46>
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0201538:	00044603          	lbu	a2,0(s0)
        char padc = ' ';
ffffffffc020153c:	02000793          	li	a5,32
        lflag = altflag = 0;
ffffffffc0201540:	4c81                	li	s9,0
ffffffffc0201542:	4881                	li	a7,0
        width = precision = -1;
ffffffffc0201544:	5c7d                	li	s8,-1
ffffffffc0201546:	5dfd                	li	s11,-1
ffffffffc0201548:	05500513          	li	a0,85
                if (ch < '0' || ch > '9') {
ffffffffc020154c:	4825                	li	a6,9
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc020154e:	fdd6059b          	addiw	a1,a2,-35
ffffffffc0201552:	0ff5f593          	zext.b	a1,a1
ffffffffc0201556:	00140d13          	addi	s10,s0,1
ffffffffc020155a:	04b56263          	bltu	a0,a1,ffffffffc020159e <vprintfmt+0xbc>
ffffffffc020155e:	058a                	slli	a1,a1,0x2
ffffffffc0201560:	95d6                	add	a1,a1,s5
ffffffffc0201562:	4194                	lw	a3,0(a1)
ffffffffc0201564:	96d6                	add	a3,a3,s5
ffffffffc0201566:	8682                	jr	a3
            for (fmt --; fmt[-1] != '%'; fmt --)
                /* do nothing */;
            break;
        }
    }
}
ffffffffc0201568:	70e6                	ld	ra,120(sp)
ffffffffc020156a:	7446                	ld	s0,112(sp)
ffffffffc020156c:	74a6                	ld	s1,104(sp)
ffffffffc020156e:	7906                	ld	s2,96(sp)
ffffffffc0201570:	69e6                	ld	s3,88(sp)
ffffffffc0201572:	6a46                	ld	s4,80(sp)
ffffffffc0201574:	6aa6                	ld	s5,72(sp)
ffffffffc0201576:	6b06                	ld	s6,64(sp)
ffffffffc0201578:	7be2                	ld	s7,56(sp)
ffffffffc020157a:	7c42                	ld	s8,48(sp)
ffffffffc020157c:	7ca2                	ld	s9,40(sp)
ffffffffc020157e:	7d02                	ld	s10,32(sp)
ffffffffc0201580:	6de2                	ld	s11,24(sp)
ffffffffc0201582:	6109                	addi	sp,sp,128
ffffffffc0201584:	8082                	ret
            padc = '0';
ffffffffc0201586:	87b2                	mv	a5,a2
            goto reswitch;
ffffffffc0201588:	00144603          	lbu	a2,1(s0)
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc020158c:	846a                	mv	s0,s10
ffffffffc020158e:	00140d13          	addi	s10,s0,1
ffffffffc0201592:	fdd6059b          	addiw	a1,a2,-35
ffffffffc0201596:	0ff5f593          	zext.b	a1,a1
ffffffffc020159a:	fcb572e3          	bgeu	a0,a1,ffffffffc020155e <vprintfmt+0x7c>
            putch('%', putdat);
ffffffffc020159e:	85a6                	mv	a1,s1
ffffffffc02015a0:	02500513          	li	a0,37
ffffffffc02015a4:	9902                	jalr	s2
            for (fmt --; fmt[-1] != '%'; fmt --)
ffffffffc02015a6:	fff44783          	lbu	a5,-1(s0)
ffffffffc02015aa:	8d22                	mv	s10,s0
ffffffffc02015ac:	f73788e3          	beq	a5,s3,ffffffffc020151c <vprintfmt+0x3a>
ffffffffc02015b0:	ffed4783          	lbu	a5,-2(s10)
ffffffffc02015b4:	1d7d                	addi	s10,s10,-1
ffffffffc02015b6:	ff379de3          	bne	a5,s3,ffffffffc02015b0 <vprintfmt+0xce>
ffffffffc02015ba:	b78d                	j	ffffffffc020151c <vprintfmt+0x3a>
                precision = precision * 10 + ch - '0';
ffffffffc02015bc:	fd060c1b          	addiw	s8,a2,-48
                ch = *fmt;
ffffffffc02015c0:	00144603          	lbu	a2,1(s0)
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc02015c4:	846a                	mv	s0,s10
                if (ch < '0' || ch > '9') {
ffffffffc02015c6:	fd06069b          	addiw	a3,a2,-48
                ch = *fmt;
ffffffffc02015ca:	0006059b          	sext.w	a1,a2
                if (ch < '0' || ch > '9') {
ffffffffc02015ce:	02d86463          	bltu	a6,a3,ffffffffc02015f6 <vprintfmt+0x114>
                ch = *fmt;
ffffffffc02015d2:	00144603          	lbu	a2,1(s0)
                precision = precision * 10 + ch - '0';
ffffffffc02015d6:	002c169b          	slliw	a3,s8,0x2
ffffffffc02015da:	0186873b          	addw	a4,a3,s8
ffffffffc02015de:	0017171b          	slliw	a4,a4,0x1
ffffffffc02015e2:	9f2d                	addw	a4,a4,a1
                if (ch < '0' || ch > '9') {
ffffffffc02015e4:	fd06069b          	addiw	a3,a2,-48
            for (precision = 0; ; ++ fmt) {
ffffffffc02015e8:	0405                	addi	s0,s0,1
                precision = precision * 10 + ch - '0';
ffffffffc02015ea:	fd070c1b          	addiw	s8,a4,-48
                ch = *fmt;
ffffffffc02015ee:	0006059b          	sext.w	a1,a2
                if (ch < '0' || ch > '9') {
ffffffffc02015f2:	fed870e3          	bgeu	a6,a3,ffffffffc02015d2 <vprintfmt+0xf0>
            if (width < 0)
ffffffffc02015f6:	f40ddce3          	bgez	s11,ffffffffc020154e <vprintfmt+0x6c>
                width = precision, precision = -1;
ffffffffc02015fa:	8de2                	mv	s11,s8
ffffffffc02015fc:	5c7d                	li	s8,-1
ffffffffc02015fe:	bf81                	j	ffffffffc020154e <vprintfmt+0x6c>
            if (width < 0)
ffffffffc0201600:	fffdc693          	not	a3,s11
ffffffffc0201604:	96fd                	srai	a3,a3,0x3f
ffffffffc0201606:	00ddfdb3          	and	s11,s11,a3
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc020160a:	00144603          	lbu	a2,1(s0)
ffffffffc020160e:	2d81                	sext.w	s11,s11
ffffffffc0201610:	846a                	mv	s0,s10
            goto reswitch;
ffffffffc0201612:	bf35                	j	ffffffffc020154e <vprintfmt+0x6c>
            precision = va_arg(ap, int);
ffffffffc0201614:	000a2c03          	lw	s8,0(s4)
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0201618:	00144603          	lbu	a2,1(s0)
            precision = va_arg(ap, int);
ffffffffc020161c:	0a21                	addi	s4,s4,8
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc020161e:	846a                	mv	s0,s10
            goto process_precision;
ffffffffc0201620:	bfd9                	j	ffffffffc02015f6 <vprintfmt+0x114>
    if (lflag >= 2) {
ffffffffc0201622:	4705                	li	a4,1
            precision = va_arg(ap, int);
ffffffffc0201624:	008a0593          	addi	a1,s4,8
    if (lflag >= 2) {
ffffffffc0201628:	01174463          	blt	a4,a7,ffffffffc0201630 <vprintfmt+0x14e>
    else if (lflag) {
ffffffffc020162c:	1a088e63          	beqz	a7,ffffffffc02017e8 <vprintfmt+0x306>
        return va_arg(*ap, unsigned long);
ffffffffc0201630:	000a3603          	ld	a2,0(s4)
ffffffffc0201634:	46c1                	li	a3,16
ffffffffc0201636:	8a2e                	mv	s4,a1
            printnum(putch, putdat, num, base, width, padc);
ffffffffc0201638:	2781                	sext.w	a5,a5
ffffffffc020163a:	876e                	mv	a4,s11
ffffffffc020163c:	85a6                	mv	a1,s1
ffffffffc020163e:	854a                	mv	a0,s2
ffffffffc0201640:	e37ff0ef          	jal	ra,ffffffffc0201476 <printnum>
            break;
ffffffffc0201644:	bde1                	j	ffffffffc020151c <vprintfmt+0x3a>
            putch(va_arg(ap, int), putdat);
ffffffffc0201646:	000a2503          	lw	a0,0(s4)
ffffffffc020164a:	85a6                	mv	a1,s1
ffffffffc020164c:	0a21                	addi	s4,s4,8
ffffffffc020164e:	9902                	jalr	s2
            break;
ffffffffc0201650:	b5f1                	j	ffffffffc020151c <vprintfmt+0x3a>
    if (lflag >= 2) {
ffffffffc0201652:	4705                	li	a4,1
            precision = va_arg(ap, int);
ffffffffc0201654:	008a0593          	addi	a1,s4,8
    if (lflag >= 2) {
ffffffffc0201658:	01174463          	blt	a4,a7,ffffffffc0201660 <vprintfmt+0x17e>
    else if (lflag) {
ffffffffc020165c:	18088163          	beqz	a7,ffffffffc02017de <vprintfmt+0x2fc>
        return va_arg(*ap, unsigned long);
ffffffffc0201660:	000a3603          	ld	a2,0(s4)
ffffffffc0201664:	46a9                	li	a3,10
ffffffffc0201666:	8a2e                	mv	s4,a1
ffffffffc0201668:	bfc1                	j	ffffffffc0201638 <vprintfmt+0x156>
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc020166a:	00144603          	lbu	a2,1(s0)
            altflag = 1;
ffffffffc020166e:	4c85                	li	s9,1
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0201670:	846a                	mv	s0,s10
            goto reswitch;
ffffffffc0201672:	bdf1                	j	ffffffffc020154e <vprintfmt+0x6c>
            putch(ch, putdat);
ffffffffc0201674:	85a6                	mv	a1,s1
ffffffffc0201676:	02500513          	li	a0,37
ffffffffc020167a:	9902                	jalr	s2
            break;
ffffffffc020167c:	b545                	j	ffffffffc020151c <vprintfmt+0x3a>
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc020167e:	00144603          	lbu	a2,1(s0)
            lflag ++;
ffffffffc0201682:	2885                	addiw	a7,a7,1
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0201684:	846a                	mv	s0,s10
            goto reswitch;
ffffffffc0201686:	b5e1                	j	ffffffffc020154e <vprintfmt+0x6c>
    if (lflag >= 2) {
ffffffffc0201688:	4705                	li	a4,1
            precision = va_arg(ap, int);
ffffffffc020168a:	008a0593          	addi	a1,s4,8
    if (lflag >= 2) {
ffffffffc020168e:	01174463          	blt	a4,a7,ffffffffc0201696 <vprintfmt+0x1b4>
    else if (lflag) {
ffffffffc0201692:	14088163          	beqz	a7,ffffffffc02017d4 <vprintfmt+0x2f2>
        return va_arg(*ap, unsigned long);
ffffffffc0201696:	000a3603          	ld	a2,0(s4)
ffffffffc020169a:	46a1                	li	a3,8
ffffffffc020169c:	8a2e                	mv	s4,a1
ffffffffc020169e:	bf69                	j	ffffffffc0201638 <vprintfmt+0x156>
            putch('0', putdat);
ffffffffc02016a0:	03000513          	li	a0,48
ffffffffc02016a4:	85a6                	mv	a1,s1
ffffffffc02016a6:	e03e                	sd	a5,0(sp)
ffffffffc02016a8:	9902                	jalr	s2
            putch('x', putdat);
ffffffffc02016aa:	85a6                	mv	a1,s1
ffffffffc02016ac:	07800513          	li	a0,120
ffffffffc02016b0:	9902                	jalr	s2
            num = (unsigned long long)(uintptr_t)va_arg(ap, void *);
ffffffffc02016b2:	0a21                	addi	s4,s4,8
            goto number;
ffffffffc02016b4:	6782                	ld	a5,0(sp)
ffffffffc02016b6:	46c1                	li	a3,16
            num = (unsigned long long)(uintptr_t)va_arg(ap, void *);
ffffffffc02016b8:	ff8a3603          	ld	a2,-8(s4)
            goto number;
ffffffffc02016bc:	bfb5                	j	ffffffffc0201638 <vprintfmt+0x156>
            if ((p = va_arg(ap, char *)) == NULL) {
ffffffffc02016be:	000a3403          	ld	s0,0(s4)
ffffffffc02016c2:	008a0713          	addi	a4,s4,8
ffffffffc02016c6:	e03a                	sd	a4,0(sp)
ffffffffc02016c8:	14040263          	beqz	s0,ffffffffc020180c <vprintfmt+0x32a>
            if (width > 0 && padc != '-') {
ffffffffc02016cc:	0fb05763          	blez	s11,ffffffffc02017ba <vprintfmt+0x2d8>
ffffffffc02016d0:	02d00693          	li	a3,45
ffffffffc02016d4:	0cd79163          	bne	a5,a3,ffffffffc0201796 <vprintfmt+0x2b4>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc02016d8:	00044783          	lbu	a5,0(s0)
ffffffffc02016dc:	0007851b          	sext.w	a0,a5
ffffffffc02016e0:	cf85                	beqz	a5,ffffffffc0201718 <vprintfmt+0x236>
ffffffffc02016e2:	00140a13          	addi	s4,s0,1
                if (altflag && (ch < ' ' || ch > '~')) {
ffffffffc02016e6:	05e00413          	li	s0,94
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc02016ea:	000c4563          	bltz	s8,ffffffffc02016f4 <vprintfmt+0x212>
ffffffffc02016ee:	3c7d                	addiw	s8,s8,-1
ffffffffc02016f0:	036c0263          	beq	s8,s6,ffffffffc0201714 <vprintfmt+0x232>
                    putch('?', putdat);
ffffffffc02016f4:	85a6                	mv	a1,s1
                if (altflag && (ch < ' ' || ch > '~')) {
ffffffffc02016f6:	0e0c8e63          	beqz	s9,ffffffffc02017f2 <vprintfmt+0x310>
ffffffffc02016fa:	3781                	addiw	a5,a5,-32
ffffffffc02016fc:	0ef47b63          	bgeu	s0,a5,ffffffffc02017f2 <vprintfmt+0x310>
                    putch('?', putdat);
ffffffffc0201700:	03f00513          	li	a0,63
ffffffffc0201704:	9902                	jalr	s2
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc0201706:	000a4783          	lbu	a5,0(s4)
ffffffffc020170a:	3dfd                	addiw	s11,s11,-1
ffffffffc020170c:	0a05                	addi	s4,s4,1
ffffffffc020170e:	0007851b          	sext.w	a0,a5
ffffffffc0201712:	ffe1                	bnez	a5,ffffffffc02016ea <vprintfmt+0x208>
            for (; width > 0; width --) {
ffffffffc0201714:	01b05963          	blez	s11,ffffffffc0201726 <vprintfmt+0x244>
ffffffffc0201718:	3dfd                	addiw	s11,s11,-1
                putch(' ', putdat);
ffffffffc020171a:	85a6                	mv	a1,s1
ffffffffc020171c:	02000513          	li	a0,32
ffffffffc0201720:	9902                	jalr	s2
            for (; width > 0; width --) {
ffffffffc0201722:	fe0d9be3          	bnez	s11,ffffffffc0201718 <vprintfmt+0x236>
            if ((p = va_arg(ap, char *)) == NULL) {
ffffffffc0201726:	6a02                	ld	s4,0(sp)
ffffffffc0201728:	bbd5                	j	ffffffffc020151c <vprintfmt+0x3a>
    if (lflag >= 2) {
ffffffffc020172a:	4705                	li	a4,1
            precision = va_arg(ap, int);
ffffffffc020172c:	008a0c93          	addi	s9,s4,8
    if (lflag >= 2) {
ffffffffc0201730:	01174463          	blt	a4,a7,ffffffffc0201738 <vprintfmt+0x256>
    else if (lflag) {
ffffffffc0201734:	08088d63          	beqz	a7,ffffffffc02017ce <vprintfmt+0x2ec>
        return va_arg(*ap, long);
ffffffffc0201738:	000a3403          	ld	s0,0(s4)
            if ((long long)num < 0) {
ffffffffc020173c:	0a044d63          	bltz	s0,ffffffffc02017f6 <vprintfmt+0x314>
            num = getint(&ap, lflag);
ffffffffc0201740:	8622                	mv	a2,s0
ffffffffc0201742:	8a66                	mv	s4,s9
ffffffffc0201744:	46a9                	li	a3,10
ffffffffc0201746:	bdcd                	j	ffffffffc0201638 <vprintfmt+0x156>
            err = va_arg(ap, int);
ffffffffc0201748:	000a2783          	lw	a5,0(s4)
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
ffffffffc020174c:	4719                	li	a4,6
            err = va_arg(ap, int);
ffffffffc020174e:	0a21                	addi	s4,s4,8
            if (err < 0) {
ffffffffc0201750:	41f7d69b          	sraiw	a3,a5,0x1f
ffffffffc0201754:	8fb5                	xor	a5,a5,a3
ffffffffc0201756:	40d786bb          	subw	a3,a5,a3
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
ffffffffc020175a:	02d74163          	blt	a4,a3,ffffffffc020177c <vprintfmt+0x29a>
ffffffffc020175e:	00369793          	slli	a5,a3,0x3
ffffffffc0201762:	97de                	add	a5,a5,s7
ffffffffc0201764:	639c                	ld	a5,0(a5)
ffffffffc0201766:	cb99                	beqz	a5,ffffffffc020177c <vprintfmt+0x29a>
                printfmt(putch, putdat, "%s", p);
ffffffffc0201768:	86be                	mv	a3,a5
ffffffffc020176a:	00001617          	auipc	a2,0x1
ffffffffc020176e:	ea660613          	addi	a2,a2,-346 # ffffffffc0202610 <best_fit_pmm_manager+0x190>
ffffffffc0201772:	85a6                	mv	a1,s1
ffffffffc0201774:	854a                	mv	a0,s2
ffffffffc0201776:	0ce000ef          	jal	ra,ffffffffc0201844 <printfmt>
ffffffffc020177a:	b34d                	j	ffffffffc020151c <vprintfmt+0x3a>
                printfmt(putch, putdat, "error %d", err);
ffffffffc020177c:	00001617          	auipc	a2,0x1
ffffffffc0201780:	e8460613          	addi	a2,a2,-380 # ffffffffc0202600 <best_fit_pmm_manager+0x180>
ffffffffc0201784:	85a6                	mv	a1,s1
ffffffffc0201786:	854a                	mv	a0,s2
ffffffffc0201788:	0bc000ef          	jal	ra,ffffffffc0201844 <printfmt>
ffffffffc020178c:	bb41                	j	ffffffffc020151c <vprintfmt+0x3a>
                p = "(null)";
ffffffffc020178e:	00001417          	auipc	s0,0x1
ffffffffc0201792:	e6a40413          	addi	s0,s0,-406 # ffffffffc02025f8 <best_fit_pmm_manager+0x178>
                for (width -= strnlen(p, precision); width > 0; width --) {
ffffffffc0201796:	85e2                	mv	a1,s8
ffffffffc0201798:	8522                	mv	a0,s0
ffffffffc020179a:	e43e                	sd	a5,8(sp)
ffffffffc020179c:	1e6000ef          	jal	ra,ffffffffc0201982 <strnlen>
ffffffffc02017a0:	40ad8dbb          	subw	s11,s11,a0
ffffffffc02017a4:	01b05b63          	blez	s11,ffffffffc02017ba <vprintfmt+0x2d8>
                    putch(padc, putdat);
ffffffffc02017a8:	67a2                	ld	a5,8(sp)
ffffffffc02017aa:	00078a1b          	sext.w	s4,a5
                for (width -= strnlen(p, precision); width > 0; width --) {
ffffffffc02017ae:	3dfd                	addiw	s11,s11,-1
                    putch(padc, putdat);
ffffffffc02017b0:	85a6                	mv	a1,s1
ffffffffc02017b2:	8552                	mv	a0,s4
ffffffffc02017b4:	9902                	jalr	s2
                for (width -= strnlen(p, precision); width > 0; width --) {
ffffffffc02017b6:	fe0d9ce3          	bnez	s11,ffffffffc02017ae <vprintfmt+0x2cc>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc02017ba:	00044783          	lbu	a5,0(s0)
ffffffffc02017be:	00140a13          	addi	s4,s0,1
ffffffffc02017c2:	0007851b          	sext.w	a0,a5
ffffffffc02017c6:	d3a5                	beqz	a5,ffffffffc0201726 <vprintfmt+0x244>
                if (altflag && (ch < ' ' || ch > '~')) {
ffffffffc02017c8:	05e00413          	li	s0,94
ffffffffc02017cc:	bf39                	j	ffffffffc02016ea <vprintfmt+0x208>
        return va_arg(*ap, int);
ffffffffc02017ce:	000a2403          	lw	s0,0(s4)
ffffffffc02017d2:	b7ad                	j	ffffffffc020173c <vprintfmt+0x25a>
        return va_arg(*ap, unsigned int);
ffffffffc02017d4:	000a6603          	lwu	a2,0(s4)
ffffffffc02017d8:	46a1                	li	a3,8
ffffffffc02017da:	8a2e                	mv	s4,a1
ffffffffc02017dc:	bdb1                	j	ffffffffc0201638 <vprintfmt+0x156>
ffffffffc02017de:	000a6603          	lwu	a2,0(s4)
ffffffffc02017e2:	46a9                	li	a3,10
ffffffffc02017e4:	8a2e                	mv	s4,a1
ffffffffc02017e6:	bd89                	j	ffffffffc0201638 <vprintfmt+0x156>
ffffffffc02017e8:	000a6603          	lwu	a2,0(s4)
ffffffffc02017ec:	46c1                	li	a3,16
ffffffffc02017ee:	8a2e                	mv	s4,a1
ffffffffc02017f0:	b5a1                	j	ffffffffc0201638 <vprintfmt+0x156>
                    putch(ch, putdat);
ffffffffc02017f2:	9902                	jalr	s2
ffffffffc02017f4:	bf09                	j	ffffffffc0201706 <vprintfmt+0x224>
                putch('-', putdat);
ffffffffc02017f6:	85a6                	mv	a1,s1
ffffffffc02017f8:	02d00513          	li	a0,45
ffffffffc02017fc:	e03e                	sd	a5,0(sp)
ffffffffc02017fe:	9902                	jalr	s2
                num = -(long long)num;
ffffffffc0201800:	6782                	ld	a5,0(sp)
ffffffffc0201802:	8a66                	mv	s4,s9
ffffffffc0201804:	40800633          	neg	a2,s0
ffffffffc0201808:	46a9                	li	a3,10
ffffffffc020180a:	b53d                	j	ffffffffc0201638 <vprintfmt+0x156>
            if (width > 0 && padc != '-') {
ffffffffc020180c:	03b05163          	blez	s11,ffffffffc020182e <vprintfmt+0x34c>
ffffffffc0201810:	02d00693          	li	a3,45
ffffffffc0201814:	f6d79de3          	bne	a5,a3,ffffffffc020178e <vprintfmt+0x2ac>
                p = "(null)";
ffffffffc0201818:	00001417          	auipc	s0,0x1
ffffffffc020181c:	de040413          	addi	s0,s0,-544 # ffffffffc02025f8 <best_fit_pmm_manager+0x178>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc0201820:	02800793          	li	a5,40
ffffffffc0201824:	02800513          	li	a0,40
ffffffffc0201828:	00140a13          	addi	s4,s0,1
ffffffffc020182c:	bd6d                	j	ffffffffc02016e6 <vprintfmt+0x204>
ffffffffc020182e:	00001a17          	auipc	s4,0x1
ffffffffc0201832:	dcba0a13          	addi	s4,s4,-565 # ffffffffc02025f9 <best_fit_pmm_manager+0x179>
ffffffffc0201836:	02800513          	li	a0,40
ffffffffc020183a:	02800793          	li	a5,40
                if (altflag && (ch < ' ' || ch > '~')) {
ffffffffc020183e:	05e00413          	li	s0,94
ffffffffc0201842:	b565                	j	ffffffffc02016ea <vprintfmt+0x208>

ffffffffc0201844 <printfmt>:
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
ffffffffc0201844:	715d                	addi	sp,sp,-80
    va_start(ap, fmt);
ffffffffc0201846:	02810313          	addi	t1,sp,40
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
ffffffffc020184a:	f436                	sd	a3,40(sp)
    vprintfmt(putch, putdat, fmt, ap);
ffffffffc020184c:	869a                	mv	a3,t1
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
ffffffffc020184e:	ec06                	sd	ra,24(sp)
ffffffffc0201850:	f83a                	sd	a4,48(sp)
ffffffffc0201852:	fc3e                	sd	a5,56(sp)
ffffffffc0201854:	e0c2                	sd	a6,64(sp)
ffffffffc0201856:	e4c6                	sd	a7,72(sp)
    va_start(ap, fmt);
ffffffffc0201858:	e41a                	sd	t1,8(sp)
    vprintfmt(putch, putdat, fmt, ap);
ffffffffc020185a:	c89ff0ef          	jal	ra,ffffffffc02014e2 <vprintfmt>
}
ffffffffc020185e:	60e2                	ld	ra,24(sp)
ffffffffc0201860:	6161                	addi	sp,sp,80
ffffffffc0201862:	8082                	ret

ffffffffc0201864 <readline>:
 * The readline() function returns the text of the line read. If some errors
 * are happened, NULL is returned. The return value is a global variable,
 * thus it should be copied before it is used.
 * */
char *
readline(const char *prompt) {
ffffffffc0201864:	715d                	addi	sp,sp,-80
ffffffffc0201866:	e486                	sd	ra,72(sp)
ffffffffc0201868:	e0a6                	sd	s1,64(sp)
ffffffffc020186a:	fc4a                	sd	s2,56(sp)
ffffffffc020186c:	f84e                	sd	s3,48(sp)
ffffffffc020186e:	f452                	sd	s4,40(sp)
ffffffffc0201870:	f056                	sd	s5,32(sp)
ffffffffc0201872:	ec5a                	sd	s6,24(sp)
ffffffffc0201874:	e85e                	sd	s7,16(sp)
    if (prompt != NULL) {
ffffffffc0201876:	c901                	beqz	a0,ffffffffc0201886 <readline+0x22>
ffffffffc0201878:	85aa                	mv	a1,a0
        cprintf("%s", prompt);
ffffffffc020187a:	00001517          	auipc	a0,0x1
ffffffffc020187e:	d9650513          	addi	a0,a0,-618 # ffffffffc0202610 <best_fit_pmm_manager+0x190>
ffffffffc0201882:	831fe0ef          	jal	ra,ffffffffc02000b2 <cprintf>
readline(const char *prompt) {
ffffffffc0201886:	4481                	li	s1,0
    while (1) {
        c = getchar();
        if (c < 0) {
            return NULL;
        }
        else if (c >= ' ' && i < BUFSIZE - 1) {
ffffffffc0201888:	497d                	li	s2,31
            cputchar(c);
            buf[i ++] = c;
        }
        else if (c == '\b' && i > 0) {
ffffffffc020188a:	49a1                	li	s3,8
            cputchar(c);
            i --;
        }
        else if (c == '\n' || c == '\r') {
ffffffffc020188c:	4aa9                	li	s5,10
ffffffffc020188e:	4b35                	li	s6,13
            buf[i ++] = c;
ffffffffc0201890:	00004b97          	auipc	s7,0x4
ffffffffc0201894:	7a0b8b93          	addi	s7,s7,1952 # ffffffffc0206030 <buf>
        else if (c >= ' ' && i < BUFSIZE - 1) {
ffffffffc0201898:	3fe00a13          	li	s4,1022
        c = getchar();
ffffffffc020189c:	88ffe0ef          	jal	ra,ffffffffc020012a <getchar>
        if (c < 0) {
ffffffffc02018a0:	00054a63          	bltz	a0,ffffffffc02018b4 <readline+0x50>
        else if (c >= ' ' && i < BUFSIZE - 1) {
ffffffffc02018a4:	00a95a63          	bge	s2,a0,ffffffffc02018b8 <readline+0x54>
ffffffffc02018a8:	029a5263          	bge	s4,s1,ffffffffc02018cc <readline+0x68>
        c = getchar();
ffffffffc02018ac:	87ffe0ef          	jal	ra,ffffffffc020012a <getchar>
        if (c < 0) {
ffffffffc02018b0:	fe055ae3          	bgez	a0,ffffffffc02018a4 <readline+0x40>
            return NULL;
ffffffffc02018b4:	4501                	li	a0,0
ffffffffc02018b6:	a091                	j	ffffffffc02018fa <readline+0x96>
        else if (c == '\b' && i > 0) {
ffffffffc02018b8:	03351463          	bne	a0,s3,ffffffffc02018e0 <readline+0x7c>
ffffffffc02018bc:	e8a9                	bnez	s1,ffffffffc020190e <readline+0xaa>
        c = getchar();
ffffffffc02018be:	86dfe0ef          	jal	ra,ffffffffc020012a <getchar>
        if (c < 0) {
ffffffffc02018c2:	fe0549e3          	bltz	a0,ffffffffc02018b4 <readline+0x50>
        else if (c >= ' ' && i < BUFSIZE - 1) {
ffffffffc02018c6:	fea959e3          	bge	s2,a0,ffffffffc02018b8 <readline+0x54>
ffffffffc02018ca:	4481                	li	s1,0
            cputchar(c);
ffffffffc02018cc:	e42a                	sd	a0,8(sp)
ffffffffc02018ce:	81bfe0ef          	jal	ra,ffffffffc02000e8 <cputchar>
            buf[i ++] = c;
ffffffffc02018d2:	6522                	ld	a0,8(sp)
ffffffffc02018d4:	009b87b3          	add	a5,s7,s1
ffffffffc02018d8:	2485                	addiw	s1,s1,1
ffffffffc02018da:	00a78023          	sb	a0,0(a5)
ffffffffc02018de:	bf7d                	j	ffffffffc020189c <readline+0x38>
        else if (c == '\n' || c == '\r') {
ffffffffc02018e0:	01550463          	beq	a0,s5,ffffffffc02018e8 <readline+0x84>
ffffffffc02018e4:	fb651ce3          	bne	a0,s6,ffffffffc020189c <readline+0x38>
            cputchar(c);
ffffffffc02018e8:	801fe0ef          	jal	ra,ffffffffc02000e8 <cputchar>
            buf[i] = '\0';
ffffffffc02018ec:	00004517          	auipc	a0,0x4
ffffffffc02018f0:	74450513          	addi	a0,a0,1860 # ffffffffc0206030 <buf>
ffffffffc02018f4:	94aa                	add	s1,s1,a0
ffffffffc02018f6:	00048023          	sb	zero,0(s1)
            return buf;
        }
    }
}
ffffffffc02018fa:	60a6                	ld	ra,72(sp)
ffffffffc02018fc:	6486                	ld	s1,64(sp)
ffffffffc02018fe:	7962                	ld	s2,56(sp)
ffffffffc0201900:	79c2                	ld	s3,48(sp)
ffffffffc0201902:	7a22                	ld	s4,40(sp)
ffffffffc0201904:	7a82                	ld	s5,32(sp)
ffffffffc0201906:	6b62                	ld	s6,24(sp)
ffffffffc0201908:	6bc2                	ld	s7,16(sp)
ffffffffc020190a:	6161                	addi	sp,sp,80
ffffffffc020190c:	8082                	ret
            cputchar(c);
ffffffffc020190e:	4521                	li	a0,8
ffffffffc0201910:	fd8fe0ef          	jal	ra,ffffffffc02000e8 <cputchar>
            i --;
ffffffffc0201914:	34fd                	addiw	s1,s1,-1
ffffffffc0201916:	b759                	j	ffffffffc020189c <readline+0x38>

ffffffffc0201918 <sbi_console_putchar>:
uint64_t SBI_REMOTE_SFENCE_VMA_ASID = 7;
uint64_t SBI_SHUTDOWN = 8;

uint64_t sbi_call(uint64_t sbi_type, uint64_t arg0, uint64_t arg1, uint64_t arg2) {
    uint64_t ret_val;
    __asm__ volatile (
ffffffffc0201918:	4781                	li	a5,0
ffffffffc020191a:	00004717          	auipc	a4,0x4
ffffffffc020191e:	6ee73703          	ld	a4,1774(a4) # ffffffffc0206008 <SBI_CONSOLE_PUTCHAR>
ffffffffc0201922:	88ba                	mv	a7,a4
ffffffffc0201924:	852a                	mv	a0,a0
ffffffffc0201926:	85be                	mv	a1,a5
ffffffffc0201928:	863e                	mv	a2,a5
ffffffffc020192a:	00000073          	ecall
ffffffffc020192e:	87aa                	mv	a5,a0
    return ret_val;
}

void sbi_console_putchar(unsigned char ch) {
    sbi_call(SBI_CONSOLE_PUTCHAR, ch, 0, 0);
}
ffffffffc0201930:	8082                	ret

ffffffffc0201932 <sbi_set_timer>:
    __asm__ volatile (
ffffffffc0201932:	4781                	li	a5,0
ffffffffc0201934:	00005717          	auipc	a4,0x5
ffffffffc0201938:	b4473703          	ld	a4,-1212(a4) # ffffffffc0206478 <SBI_SET_TIMER>
ffffffffc020193c:	88ba                	mv	a7,a4
ffffffffc020193e:	852a                	mv	a0,a0
ffffffffc0201940:	85be                	mv	a1,a5
ffffffffc0201942:	863e                	mv	a2,a5
ffffffffc0201944:	00000073          	ecall
ffffffffc0201948:	87aa                	mv	a5,a0

void sbi_set_timer(unsigned long long stime_value) {
    sbi_call(SBI_SET_TIMER, stime_value, 0, 0);
}
ffffffffc020194a:	8082                	ret

ffffffffc020194c <sbi_console_getchar>:
    __asm__ volatile (
ffffffffc020194c:	4501                	li	a0,0
ffffffffc020194e:	00004797          	auipc	a5,0x4
ffffffffc0201952:	6b27b783          	ld	a5,1714(a5) # ffffffffc0206000 <SBI_CONSOLE_GETCHAR>
ffffffffc0201956:	88be                	mv	a7,a5
ffffffffc0201958:	852a                	mv	a0,a0
ffffffffc020195a:	85aa                	mv	a1,a0
ffffffffc020195c:	862a                	mv	a2,a0
ffffffffc020195e:	00000073          	ecall
ffffffffc0201962:	852a                	mv	a0,a0

int sbi_console_getchar(void) {
    return sbi_call(SBI_CONSOLE_GETCHAR, 0, 0, 0);
}
ffffffffc0201964:	2501                	sext.w	a0,a0
ffffffffc0201966:	8082                	ret

ffffffffc0201968 <sbi_shutdown>:
    __asm__ volatile (
ffffffffc0201968:	4781                	li	a5,0
ffffffffc020196a:	00004717          	auipc	a4,0x4
ffffffffc020196e:	6a673703          	ld	a4,1702(a4) # ffffffffc0206010 <SBI_SHUTDOWN>
ffffffffc0201972:	88ba                	mv	a7,a4
ffffffffc0201974:	853e                	mv	a0,a5
ffffffffc0201976:	85be                	mv	a1,a5
ffffffffc0201978:	863e                	mv	a2,a5
ffffffffc020197a:	00000073          	ecall
ffffffffc020197e:	87aa                	mv	a5,a0

void sbi_shutdown(void)
{
    sbi_call(SBI_SHUTDOWN, 0, 0, 0);
ffffffffc0201980:	8082                	ret

ffffffffc0201982 <strnlen>:
 * @len if there is no '\0' character among the first @len characters
 * pointed by @s.
 * */
size_t
strnlen(const char *s, size_t len) {
    size_t cnt = 0;
ffffffffc0201982:	4781                	li	a5,0
    while (cnt < len && *s ++ != '\0') {
ffffffffc0201984:	e589                	bnez	a1,ffffffffc020198e <strnlen+0xc>
ffffffffc0201986:	a811                	j	ffffffffc020199a <strnlen+0x18>
        cnt ++;
ffffffffc0201988:	0785                	addi	a5,a5,1
    while (cnt < len && *s ++ != '\0') {
ffffffffc020198a:	00f58863          	beq	a1,a5,ffffffffc020199a <strnlen+0x18>
ffffffffc020198e:	00f50733          	add	a4,a0,a5
ffffffffc0201992:	00074703          	lbu	a4,0(a4)
ffffffffc0201996:	fb6d                	bnez	a4,ffffffffc0201988 <strnlen+0x6>
ffffffffc0201998:	85be                	mv	a1,a5
    }
    return cnt;
}
ffffffffc020199a:	852e                	mv	a0,a1
ffffffffc020199c:	8082                	ret

ffffffffc020199e <strcmp>:
int
strcmp(const char *s1, const char *s2) {
#ifdef __HAVE_ARCH_STRCMP
    return __strcmp(s1, s2);
#else
    while (*s1 != '\0' && *s1 == *s2) {
ffffffffc020199e:	00054783          	lbu	a5,0(a0)
        s1 ++, s2 ++;
    }
    return (int)((unsigned char)*s1 - (unsigned char)*s2);
ffffffffc02019a2:	0005c703          	lbu	a4,0(a1)
    while (*s1 != '\0' && *s1 == *s2) {
ffffffffc02019a6:	cb89                	beqz	a5,ffffffffc02019b8 <strcmp+0x1a>
        s1 ++, s2 ++;
ffffffffc02019a8:	0505                	addi	a0,a0,1
ffffffffc02019aa:	0585                	addi	a1,a1,1
    while (*s1 != '\0' && *s1 == *s2) {
ffffffffc02019ac:	fee789e3          	beq	a5,a4,ffffffffc020199e <strcmp>
    return (int)((unsigned char)*s1 - (unsigned char)*s2);
ffffffffc02019b0:	0007851b          	sext.w	a0,a5
#endif /* __HAVE_ARCH_STRCMP */
}
ffffffffc02019b4:	9d19                	subw	a0,a0,a4
ffffffffc02019b6:	8082                	ret
ffffffffc02019b8:	4501                	li	a0,0
ffffffffc02019ba:	bfed                	j	ffffffffc02019b4 <strcmp+0x16>

ffffffffc02019bc <strchr>:
 * The strchr() function returns a pointer to the first occurrence of
 * character in @s. If the value is not found, the function returns 'NULL'.
 * */
char *
strchr(const char *s, char c) {
    while (*s != '\0') {
ffffffffc02019bc:	00054783          	lbu	a5,0(a0)
ffffffffc02019c0:	c799                	beqz	a5,ffffffffc02019ce <strchr+0x12>
        if (*s == c) {
ffffffffc02019c2:	00f58763          	beq	a1,a5,ffffffffc02019d0 <strchr+0x14>
    while (*s != '\0') {
ffffffffc02019c6:	00154783          	lbu	a5,1(a0)
            return (char *)s;
        }
        s ++;
ffffffffc02019ca:	0505                	addi	a0,a0,1
    while (*s != '\0') {
ffffffffc02019cc:	fbfd                	bnez	a5,ffffffffc02019c2 <strchr+0x6>
    }
    return NULL;
ffffffffc02019ce:	4501                	li	a0,0
}
ffffffffc02019d0:	8082                	ret

ffffffffc02019d2 <memset>:
memset(void *s, char c, size_t n) {
#ifdef __HAVE_ARCH_MEMSET
    return __memset(s, c, n);
#else
    char *p = s;
    while (n -- > 0) {
ffffffffc02019d2:	ca01                	beqz	a2,ffffffffc02019e2 <memset+0x10>
ffffffffc02019d4:	962a                	add	a2,a2,a0
    char *p = s;
ffffffffc02019d6:	87aa                	mv	a5,a0
        *p ++ = c;
ffffffffc02019d8:	0785                	addi	a5,a5,1
ffffffffc02019da:	feb78fa3          	sb	a1,-1(a5)
    while (n -- > 0) {
ffffffffc02019de:	fec79de3          	bne	a5,a2,ffffffffc02019d8 <memset+0x6>
    }
    return s;
#endif /* __HAVE_ARCH_MEMSET */
}
ffffffffc02019e2:	8082                	ret
