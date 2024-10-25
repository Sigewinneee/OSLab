## 练习 1：理解 first-fit 连续物理内存分配算法（思考题）

first-fit 连续物理内存分配算法作为物理内存分配一个很基础的方法，需要同学们理解它的实现过程。请大家仔细阅读实验手册的教程并结合 `kern/mm/default_pmm.c` 中的相关代码，认真分析 `default_init`，`default_init_memmap`，`default_alloc_pages`，`default_free_pages` 等相关函数，并描述程序在进行物理内存分配的过程以及各个函数的作用。请在实验报告中简要说明你的设计实现过程。请回答如下问题：

- 你的 first fit 算法是否有进一步的改进空间？

**答：**`Page` 结构体中的 `list_entry_t page_link;` 成员可以看成一个链表。其与常规链表（由 `List` 类和 `Node` 类定义的）的联系：`list_entry` 即 `Node` 结点，包含前向指针和后向指针，仅仅有了 `Node` 类结点已经足够表示一个链表了，`List` 类只是进一步封装。所以程序只用了 `list_entry` 来记录表示空闲块的链表。

- `default_init()`：初始化 `free_list`，令其前向指针和后向指针都指向自身，并且 `nr_free` 初始化为 0。

- `default_init_memmap(...)`：由 `pmm.c` 中的 `page_init()` 函数调用，`page_init()` 会在得到所有可以分配的内存之后，将内存基地址和页的数量传递给 `default_init_memmap(...)`，继续将这些可用的页初始化到 `free_area` 中。在此之后，便可以进行内存分配的工作了。

- `default_alloc_pages(...)`：分配内存，参数 `n` 表示需要的页数，`first-fit` 算法会在链表中找到第一个满足要求的块，并将其切割下 `n` 大小后将剩余部分重新链接到空闲链表中。

- `default_free_pages(...)`：释放内存，根据物理地址的大小，首先在空闲链表中找到这块内存应该存放的位置并将其插入，然后检查这块代码与前向或后向的代码块是不是连在一起的，如果是则合并这些代码块。

## 练习 2：实现 Best-Fit 连续物理内存分配算法（需要编程）

在完成练习 1 后，参考 `kern/mm/default_pmm.c` 对 First Fit 算法的实现，编程实现 Best Fit 页面分配算法，算法的时空复杂度不做要求，能通过测试即可。请在实验报告中简要说明你的设计实现过程，阐述代码是如何对物理内存进行分配和释放，并回答如下问题：

- 你的 Best-Fit 算法是否有进一步的改进空间？

first-fit 算法和 Best-Fit 算法在内存的管理方式上是完全相同的，唯一的区别就是在分配内存时，寻找可用内存块的逻辑不同：first-fit 当找到第一个可用内存块时就直接使用，而 Best-Fit 算法会遍历当前存储的所有内存块，找到可用的、最小的内存块然后使用。

与 first-fit 算法相比，代码修改如下：
```c
// best_fit_pmm.c
size_t min_size = nr_free + 1; // 记录当前找到的满足要求、且大小最小的内存块
while ((le = list_next(le)) != &free_list) {
    struct Page *p = le2page(le, page_link);
    if (p->property >= n && p->property < min_size) {
        page = p;
        min_size = p->property;
        /* break;  // 这里找到之后并不退出，所以将 break 注释掉*/
    }
}
```

## 扩展练习 Challenge：buddy system（伙伴系统）分配算法（需要编程）

Buddy System 算法把系统中的可用存储空间划分为存储块 (Block) 来进行管理，每个存储块的大小必须是 2 的 n 次幂 (Pow(2, n))，即 1, 2, 4, 8, 16, 32, 64, 128...

- 参考伙伴分配器的一个极简实现，在 ucore 中实现 buddy system 分配算法，要求有比较充分的测试用例说明实现的正确性，需要有设计文档。

**答：**

Buddy System 算法和前两个算法在管理方式上完全不同，首先要确定谁和谁是伙伴关系。

之前提到，`page_init()` 会在得到所有可以分配的内存之后，将内存基地址和页的数量传递给 `default_init_memmap(...)`。在这个算法中，我们假定给从内存基地址开始的每一页内存分配一个 index（从 0 开始）。那么：
- 大小为 1 的内存块，0（`0b0000`）和 1（`0b0001`）为伙伴，20（`0b0001_0100`）和 21（`0b0001_0101`）为伙伴；
- 大小为 4 的内存块，0（`0b0000`）和 4（`0b0100`）为伙伴，16（`0b0001_0000`）和 20（`0b0001_0100`）为伙伴.

不难发现，对于大小为 n 的内存块，拥有伙伴关系的两个地址（index）以二进制的形式表示时，只有第 n 位是恰好相反的，那么就得到了寻找伙伴内存块的算法：给定一个 index 和内存块大小 n，只需将 index 的第 n 位取反，便得到伙伴内存块的 index。算法如下：
```c
// buddy_system_pmm.c
static struct Page *buddy_get_buddy(struct Page *page, size_t order) {
    size_t page_idx = page - pages; // 计算 index
    size_t buddy_idx = page_idx ^ (1 << order); // 通过异或计算出伙伴的位置
    return pages + buddy_idx;
}
```
其中 `order` 是 2 的指数，`1 << order` 即得到 `00...0100...0`，通过在特定 bit 上与 1 的异或运算，实现了那一位上的取反。

接下来要考虑怎么管理内存块。

前两个算法都使用 1 个空闲链表来管理。为了加速寻找满足条件的内存块，我们实现的 Buddy System 算法为每一个数量级的内存块分别提供了一个链表，将它们以数组的形式声明：
```c
// buddy_system_pmm.c
typedef struct {
    list_entry_t free_list[MAX_ORDER + 1];  // 每个order都有一个空闲列表
    unsigned int nr_free[MAX_ORDER + 1];    // 每个order对应的空闲块数量
} free_area_t_buddy;
```

接下来就可以实现主要函数了。

- `buddy_system_init()`：与前两个算法类似，不过改成初始化数组 `free_list[]` 和 `nr_free[]`。

- `buddy_system_init_memmap(...)`：在得到所有可用页的数量 n 之后，首先计算不大于 n 的最大的 2 的幂数 `2^order`，切割下相应大小并插入到对应的 `free_list[order]` 中；之后递归地将剩下大小的页块以 2 的幂数插入到对应链表中（因为传入的页块可能不是规整的 2 的幂数，要处理可能存在的零散的页块）。<br>代码实现与原理叙述类似，唯一的区别是第一次计算最大的内存块也是在递归循环中进行的。
```c
// buddy_system_pmm.c
static void buddy_system_init_memmap(struct Page *base, size_t n) {
    assert(n > 0);
    size_t order = MAX_ORDER;
    struct Page *p = base;

    // 将初始化的内存块分解为2^order大小的块，依次加入到空闲列表
    while (n > 0) {
        while ((1 << order) > n) {
            order--;
        }
        p->property = order;
        SetPageProperty(p);
        list_add(&free_list[order], &(p->page_link));
        nr_free[order]++;
        n -= (1 << order);
        p += (1 << order);
    }
}
```

- `buddy_system_alloc_pages(...)`：分配内存。得到请求的内存大小 n 后，首先计算不小于 n 的最小的内存块，其指数大小为 target_order。然后从 target_order 开始，依次在越来越大的空闲链表中查找，如果找到指数为 order 的空闲内存块，则把它从链表中摘出。如果 order > target_order，则先切割内存块并将不需要使用的伙伴存入空闲链表，直到 target_order 大小，最后返回。
```c
// buddy_system_pmm.c
for (order = target_order; order <= MAX_ORDER; order++) {
    if (!list_empty(&free_list[order])) {
        // 找到满足条件的块
        struct Page *page = le2page(list_next(&free_list[order]), page_link);
        list_del(&page->page_link);
        ClearPageProperty(page);
        nr_free[order]--;

        // 拆分成更小的块，直到达到目标order
        while (order > target_order) {
            order--;
            struct Page *buddy = page + (1 << order);
            buddy->property = order;
            SetPageProperty(buddy);
            list_add(&free_list[order], &buddy->page_link);
            nr_free[order]++;
        }
        return page;
    }
}
```

- `buddy_system_free_pages(...)`：释放内存。与分配内存相同，得到需要释放的内存大小 n 后，首先计算不小于 n 的最小的内存块，其指数大小为 order，这是它请求分配时得到的大小。然后计算释放内存的伙伴，如果它的 `PG_property` 标记为 1 且 `property == order`，说明释放内存的伙伴是空闲的，那么执行递归操作：先将两个内存块合并，然后以同样方式检查合并之后内存块的伙伴，直到所有涉及到的内存块合并完成。
```c
struct Page *p = base;
// 合并可能的伙伴
while (order < MAX_ORDER) {
    struct Page *buddy = buddy_get_buddy(p, order);
    if (PageProperty(buddy) && buddy->property == order) {
        if (list_empty(&free_list[order])) {
            break;
        }
        // 从空闲列表中删除伙伴
        list_del(&buddy->page_link);
        ClearPageProperty(buddy);
        nr_free[order]--;
        // 选择更小地址的页作为新块
        if (buddy < p) {
            p = buddy;
        }
        order++;
    } else {
        break;
    }
}
// 将合并后的块重新加入到空闲列表
p->property = order;
SetPageProperty(p);
list_add(&free_list[order], &p->page_link);
nr_free[order]++;
```

### 测试用例

测试用例的的代码和注释请在 `buddy_system_pmm.c`中查看。

## 扩展练习 Challenge：任意大小的内存单元 slub 分配算法（需要编程）

slub 算法，实现两层架构的高效内存单元分配，第一层是基于页大小的内存分配，第二层是在第一层基础上实现基于任意大小的内存分配。可简化实现，能够体现其主体思想即可。
- 参考 linux 的 slub 分配算法，在 ucore 中实现 slub 分配算法。要求有比较充分的测试用例说明实现的正确性，需要有设计文档。

## 扩展练习 Challenge：硬件的可用物理内存范围的获取方法（思考题）

- 如果 OS 无法提前知道当前硬件的可用物理内存范围，请问你有何办法让 OS 获取可用物理内存范围？

**答：**

1. 80386 架构：

    - CPU 主动探测：通过向目标地址写入数据然后读取。这种方法有一定的风险，因为可能会覆盖到某些特殊硬件或设备使用的内存区域。

    - 通过 BIOS 帮助探索：OS 可以通过 BIOS 提供的 `INT 0x15` 中断调用（如 `e820` 调用）来获取物理内存映射信息。这些信息描述了每个内存区域的类型（可用、保留、ACPI 等）。<br>在较新的 x86 和其他平台上，UEFI 是替代 BIOS 的一种启动固件。通过 UEFI 的 `GetMemoryMap` 函数，操作系统可以获取内存的详细布局。这包括所有可用的内存块和已分配的内存区域，使 OS 能够决定如何使用这些内存区域。

2. RISC-V：

    - 设备树（device tree）：在启动时，Bootloader（如 U-Boot 或 OpenSBI）将设备树传递给操作系统，设备树中包含了关于内存的信息，如可用的内存范围、地址和大小。<br>OS 可以解析设备树中的 `/memory` 节点，从中获取物理内存的起始地址和长度，进而知道哪些内存区域是可用的。

    - SBI：在 RISC-V 平台上，OpenSBI 提供了一个标准化的接口。OS 可以通过 SBI 调用获取内存布局信息。`sbi_query_memory()` 函数完成内存探测。
