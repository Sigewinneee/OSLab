# Lab0.5

## 练习1: 使用GDB验证启动流程

> 为了熟悉使用 qemu 和 gdb 进行调试工作,使用 gdb 调试 QEMU 模拟的 RISC-V 计算机加电开始运行到执行应用程序的第一条指令（即跳转到 `0x80200000`）这个阶段的执行过程，说明 RISC-V 硬件加电后的几条指令在哪里？完成了哪些功能？要求在报告中简要写出练习过程和回答。

### 第一阶段：复位

首先进入 lab0 目录下，在两个终端中，分别使用 `Makefile` 文件中定义的 `make debug` 和 `make gdb` 指令，启动 qemu 和调试程序。`gdb` 终端输出如下：

```powershell
$ make gdb
...   # 这里输出了许多 gdb 程序有关的信息
0x0000000000001000 in ?? ()
(gdb)
```

可以看到，当 QEMU 模拟的 RISC-V 处理器上电/复位时，它的复位地址是 `0x1000`，这是程序计数器（PC）最初指向的位置。

查看接下来要执行的代码：

```powershell
(gdb) x/10i $pc
=> 0x1000:      auipc   t0,0x0
   0x1004:      addi    a1,t0,32
   0x1008:      csrr    a0,mhartid
   0x100c:      ld      t0,24(t0)
   0x1010:      jr      t0
   0x1014:      unimp
   0x1016:      unimp
   0x1018:      unimp
   0x101a:      0x8000
   0x101c:      unimp
```

使用 `si` 命令单步运行指令，并在每一步之后查看相关寄存器的值。`auipc t0,0x0` 将当前位置pc寄存器的值加上立即数 `0x0`（`0x0` 需要先左移 `<<` 3位，不过结果还是 `0x0`）存入 `t0` 中，然后将 `t0` 加 32（0x1000+32=0x1020）存入 `a1` 中；接下来 `csrr a0,mhartid` 命令将当前 CPU 硬件线程的 ID（0）存入 `a0`。

```powershell
(gdb) si
0x0000000000001004 in ?? ()
(gdb) info r t0
t0             0x1000   4096
(gdb) si
0x0000000000001008 in ?? ()
(gdb) info r a1
a1             0x1020   4128
(gdb) si
0x000000000000100c in ?? ()
(gdb) info r a0
a0             0x0      0
(gdb) si
0x0000000000001010 in ?? ()
(gdb) info r t0
t0             0x80000000       2147483648
(gdb) si
0x0000000080000000 in ?? ()
```

处理器在启动时只初始化了 `a0`，`a1` 两个寄存器作为参数，接下来CPU直接跳转到了 `0x80000000`，开始执行 OpenSBI 固件上的代码。

### 第二阶段：OpenSBI

从地址 `0x80000000` 开始执行的代码是 OpenSBI，它是 RISC-V 系统中的引导程序，查看`0x80000000` 位置的代码：

```powershell
(gdb) x/10i $pc
=> 0x80000000:  csrr    a6,mhartid
   0x80000004:  bgtz    a6,0x80000108
   0x80000008:  auipc   t0,0x0
   0x8000000c:  addi    t0,t0,1032
   0x80000010:  auipc   t1,0x0
   0x80000014:  addi    t1,t1,-16
   0x80000018:  sd      t1,0(t0)
   0x8000001c:  auipc   t0,0x0
   0x80000020:  addi    t0,t0,1020
   0x80000024:  ld      t0,0(t0)
```

经查阅相关资料，了解到 OpenSBI 主要负责初始化系统硬件，其执行过程会做下面这些事情：

- 初始化 CPU 的状态和特权级模式。
- 配置时钟、计时器等硬件资源。
- 初始化内存管理单元（MMU）或相关资源。
- 设置中断管理器，并初始化中断处理程序。
- 初始化其他外设，确保系统在启动操作系统之前处于稳定状态。

OpenSBI 不仅仅是一个引导程序，它还提供了一套标准的接口，称为 Supervisor Binary Interface(SBI)。操作系统可以通过这些接口进行系统级别的特权操作。
这些接口包括处理系统调用、控制台输出（如 `SBI_CONSOLE_PUTCHAR`）、管理中断等，操作系统内核在运行时可以使用这些接口与底层硬件交互。

OpenSBI 的最后一步是加载和引导操作系统内核。在本次实验中，内核镜像（os.bin）已经被QEMU自动加载到物理地址 `0x80200000`，因此OpenSBI的任务是初始化完硬件之后，直接跳转到 `0x80200000`，并将控制权交给操作系统内核的入口（kern_entry），开始执行操作系统内核。

### 第三阶段：操作系统内核

查看 `0x80200000` 位置的汇编指令，可以看到和之前稍有不同，这里出现了 `kern_entry` 等标签，说明处理器已经开始执行 `entry.S` 中的内容，也就是操作系统内核。运行到这里，计算机的控制权已经从OpenSBI移交给操作系统内核。

此时的二进制代码已经能够对应上 `entry.S` 中的代码，并且通过标签标示出了对应位置属于哪个代码块，块中的代码全部通过 `<标签> + <偏移量>` 来标记。`auipc sp,0x3` 对应了第一条指令 `la sp, bootstacktop`，用来初始化栈顶；之后的代码同样能够找到它们的对应。

```powershell
(gdb) x/10i $pc
=> 0x80200000 <kern_entry>:     auipc   sp,0x3
   0x80200004 <kern_entry+4>:   mv      sp,sp
   0x80200008 <kern_entry+8>:   j       0x8020000a <kern_init>
   0x8020000a <kern_init>:      auipc   a0,0x3
   0x8020000e <kern_init+4>:    addi    a0,a0,-2
   0x80200012 <kern_init+8>:    auipc   a2,0x3
   0x80200016 <kern_init+12>:   addi    a2,a2,-10
   0x8020001a <kern_init+16>:   addi    sp,sp,-16
   0x8020001c <kern_init+18>:   li      a1,0
   0x8020001e <kern_init+20>:   sub     a2,a2,a0
```

## 本实验中重要的知识点

- OpenSBI（Open Supervisor Binary Interface）是一个用于 RISC-V 架构的开源固件，主要提供基本的启动和运行时服务。它为 RISC-V 处理器提供了一个标准的运行时环境，帮助操作系统与硬件之间进行交互，处理中断、时钟和设备管理等功能。

# Lab1

## 练习1：理解内核启动中的程序入口操作

> 阅读 kern/init/entry.S 内容代码，结合操作系统内核启动流程，说明指令 `la sp, bootstacktop` 完成了什么操作，目的是什么？`tail kern_init` 完成了什么操作，目的是什么？

```powershell
(gdb) x/10i $pc
=> 0x80200000 <kern_entry>:     auipc   sp,0x4
   0x80200004 <kern_entry+4>:   mv      sp,sp
   0x80200008 <kern_entry+8>:   j       0x8020000a <kern_init>
   ...
```

1. `la sp, bootstacktop`

这条指令是将栈顶地址 bootstacktop 加载到栈指针寄存器 sp 中。其对应的可执行代码为 `auipc sp,0x4`， `auipc` 会将立即数左移 12 位，所以这条指令的作用是将当前 PC 的值加上 `0x400` 的偏移量，并将结果存储在栈指针 `sp` 中。

下面一条可执行代码 `mv sp,sp` 可能是套用了固定的代码框架，这条指令本身相当于没做任何事情。

这条指令的目的是为后续的操作系统内核执行分配一个独立的栈空间，这个栈空间将被用于处理操作系统内核的函数调用和数据存储。

2. `tail kern_init`

`tail` 是一种优化的无条件跳转指令，它会跳转到 `kern_init`，但是在跳转之前不保存返回地址，也就是一个永远不会返回的跳转。从它对应的可执行代码来看，确实只有一条 `j 0x8020000a <kern_init>`，没有保存 `ra`。

这条指令的作用是跳转到 `kern_init` 即内核的初始化函数，一旦跳转到 `kern_init`，我们不需要再返回到 `kern_entry`。使用 `tail` 指令来跳转避免了额外的函数调用开销。

## 练习2：完善中断处理 （需要编程）

> 请编程完善trap.c中的中断处理函数trap，在对时钟中断进行处理的部分填写kern/trap/trap.c函数中处理时钟中断的部分，使操作系统每遇到100次时钟中断后，调用print_ticks子程序，向屏幕上打印一行文字”100 ticks”，在打印完10行后调用sbi.h中的shut_down()函数关机。
>
> 要求完成问题1提出的相关函数实现，提交改进后的源代码包（可以编译执行），并在实验报告中简要说明实现过程和定时器中断中断处理的流程。实现要求的部分代码后，运行整个系统，大约每1秒会输出一次”100 ticks”，输出10行。

实现过程：

```C
case IRQ_S_TIMER:
   clock_set_next_event();
   if (++ticks % TICK_NUM == 0) {
         print_ticks();
         if (++num == 10) {
            sbi_shutdown();
         }
   }
   break;
```

代码逻辑十分简单，即先设置下一次中断，然后判断中断计数 `ticks` 是不是 `100`(TICK_NUM) 的整数倍，如果是则打印信息，并进行打印计数，打印 10 次后关机。

测试结果：

```powershell
~/riscv64-ucore-labcodes/lab1$ make qemu
...   # opensbi 相关信息
(THU.CST) os is loading ...


Special kernel symbols:
  entry  0x000000008020000a (virtual)
  etext  0x0000000080200998 (virtual)
  edata  0x0000000080204010 (virtual)
  end    0x0000000080204028 (virtual)
Kernel executable memory footprint: 17KB
++ setup timer interrupts
100 ticks
100 ticks
100 ticks
100 ticks
100 ticks
100 ticks
100 ticks
100 ticks
100 ticks
100 ticks
~/riscv64-ucore-labcodes/lab1$
```

下面介绍定时器中断处理的流程。

1. 中断的触发：定时器按照预定的时间间隔触发中断。在设置好的时间到达时，定时器硬件会向处理器发送一个中断请求，告知处理器它需要被处理。这种类型的中断在RISC-V架构中被称为 Supervisory Timer Interrupt (IRQ_S_TIMER)。

2. 处理器响应中断：当定时器触发中断后，处理器会自动中断当前正在执行的任务，并跳转到 `stvec` 寄存器指向的中断向量表中预定义的中断处理入口。在本实验中，采用的是 `Direct` 模式，也就是 `stvec` 保存唯一的中断处理程序的地址。

3. 进入中断处理函数：之后，`ucore` 系统会将控制权转移到一个通用的中断处理入口函数 `__alltraps`。开始正式对中断执行实际的操作。首先，会执行预定义的 `SAVE_ALL` 操作，保存所有寄存器到栈中，并将 `sp` 作为 `a0` 参数。然后进行一系列预先封装好的函数调用： `trap(tf) => trap_dispatch(tf) => interrupt_handler(tf)`，进入 `interrupt_handler` 函数，便开始执行本次实验完成的 `case` 分支的内容。

4. 完成中断处理：当中断处理完成后，系统会从中断处理程序返回到通用的中断入口函数 `__trapret`，并调用 `RESTORE_ALL` 宏恢复之前保存的寄存器状态。最后使用 `sret` 指令返回。

## 扩展练习 Challenge1：描述与理解中断流程

> 回答：描述ucore中处理中断异常的流程（从异常的产生开始），其中 `mov a0，sp` 的目的是什么？`SAVE_ALL` 中寄存器保存在栈中的位置是什么确定的？对于任何中断，`__alltraps` 中都需要保存所有寄存器吗？请说明理由。

1. `a0` 是函数参数寄存器，`trap` 的函数原型为 `void trap(struct trapframe *tf)`。`mov a0, sp` 指令把当前的栈指针（存储了中断发生时的寄存器状态和程序上下文）传递给 `trap` 函数。因为 `trap` 函数需要通过这个 `trapframe` 来访问保存的 CPU 状态，从而处理中断或异常，并决定接下来是跳转到中断处理函数还是异常处理函数。

2. `SAVE_ALL` 中寄存器保存在栈中的位置是基于当前 `sp` 确定的，也就是存储在从当前 `sp` 指向的位置向高地址依次扩展的位置上。这一点通过代码 `addi sp, sp, -36 * REGBYTES` 可以体现。

3. 是的，对于任何中断，`__alltraps` 中都需要保存所有寄存器。因为中断的处理是异步的，CPU 随时可能会暂停工作而去处理中断，所以需要保存所有寄存器以便中断结束能够恢复之前的状态。这样同时简化了处理流程，也就是不必依照 CPU 的不同工作状态来保存不同的寄存器集合。

## 扩增练习 Challenge2：理解上下文切换机制

> 回答：在trapentry.S中汇编代码 `csrw sscratch, sp`；`csrrw s0, sscratch, x0`实现了什么操作，目的是什么？save all里面保存了stval scause这些csr，而在restore all里面却不还原它们？那这样store的意义何在呢？

`csrw` 和 `csrrw` 是与控制状态寄存器交互的指令，用于读取和写入 `CSR`。`csrw sscratch, sp` 指令表示将当前栈指针 `sp` 写入 `sscratch` 寄存器，目的是备份当前栈指针，以便在中断处理完成后能够恢复栈的状态。

`csrrw s0, sscratch, x0` 实现了读取 `sscratch` 的值，并存入寄存器 `s0` 中，同时将 `x0` 的值（恒为0）写入 `sscratch`。这样做是为了之后如果在中断处理过程中再次发生异常或中断，可以通过 `sscratch` 判断它是来自内核的中断。

`stval` 和 `scause` 是用于保存中断和异常信息的寄存器，它们的值在处理中断时已经使用。当中断处理完毕之后，中断发生前的状态已经失去了存在的意义，所以不需要恢复。如果之后又发生了中断，只需将这些值直接覆盖即可。store 的意义就是为了给中断处理函数提供信息，比如 `trap_dispatch(struct trapframe *tf)` 函数中根据 `tf->cause` 判断中断类型。

## 扩展练习Challenge3：完善异常中断

> 编程完善在触发一条非法指令异常mret和，在kern/trap/trap.c的异常处理函数中捕获，并对其进行处理，简单输出异常类型和异常指令触发地址，即“Illegal instruction caught at 0x(地址)”，“ebreak caught at 0x（地址）”与“Exception type:Illegal instruction"，“Exception type: breakpoint”。

实验代码如下：

```c
case CAUSE_ILLEGAL_INSTRUCTION:
   // 非法指令异常处理
   cprintf("Exception type: Illegal instruction\n");
   cprintf("Illegal instruction caught at 0x%08x\n", tf->epc);
   tf->epc += 4;
   break;
case CAUSE_BREAKPOINT:
   // 断点异常处理
   cprintf("Exception type: breakpoint\n");
   cprintf("ebreak caught at 0x%08x\n", tf->epc);
   tf->epc += 2;
   break;
```

通过查询RISC-V标准手册，可以得知 `ebreak` 的长度是 2 个字节，而非法指令 `mret` 的长度是 4 个字节，这一点通过使用 `x/10i $pc` 调试指令也能够得知：

```powershell
...
0x80200046 <kern_init+60>:   ebreak             # ..48 - ..46 = 2
0x80200048 <kern_init+62>:   mret               # ..4c - ..48 = 4
0x8020004c <kern_init+66>:   jal     ra,0x80200134 <clock_init>
...
```

所以要在非法指令异常处理中将 `tf->epc` 的值加 4，而在断点异常处理中要将 `tf->epc` 的值加 2。

处理器输出结果如下：

```powershell
...
Kernel executable memory footprint: 17KB
Exception type: breakpoint
ebreak caught at 0x80200046
sbi_emulate_csr_read: hartid0: invalid csr_num=0x302
Exception type: Illegal instruction
Illegal instruction caught at 0x80200048
++ setup timer interrupts
100 ticks
100 ticks
...
```

> 非法指令可以加在任意位置，比如在通过内联汇编加入，也可以直接修改汇编。但是要注意，什么时候时候异常触发了才会被处理？

非法指令可以加在任意位置，因为处理器拥有随时处理异常的功能。但是处理器必须先初始化中断描述符表（执行 `idt_init()` 函数），只有在设置了 `stvec` 寄存器的值为异常和中断处理的入口点 `__alltraps` 之后，处理器才具备处理异常和中断的功能。
