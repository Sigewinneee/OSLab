/*LAB2 Challenge : YOUR CODE 2211616 */
#include <pmm.h>
#include <list.h>
#include <string.h>
#include <buddy_system_pmm.h>
#include <stdio.h>

#define MAX_ORDER 10  // 最大支持的块大小为 2^10 页

typedef struct {
    list_entry_t free_list[MAX_ORDER + 1];  // 每个order都有一个空闲列表
    unsigned int nr_free[MAX_ORDER + 1];    // 每个order对应的空闲块数量
} free_area_t_buddy;

static free_area_t_buddy free_area;

#define free_list (free_area.free_list)
#define nr_free (free_area.nr_free)

// 获取伙伴的地址
static struct Page *buddy_get_buddy(struct Page *page, size_t order) {
    size_t page_idx = page - pages;
    size_t buddy_idx = page_idx ^ (1 << order); // 通过异或计算出伙伴的位置
    return pages + buddy_idx;
}

static void
buddy_system_init(void) {
    for (int i = 0; i <= MAX_ORDER; i++) {
        list_init(&free_list[i]);
        nr_free[i] = 0;
    }
}

static void
buddy_system_init_memmap(struct Page *base, size_t n) {
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

static struct Page *
buddy_system_alloc_pages(size_t n) {
    assert(n > 0);
    size_t order = 0;
    size_t target_order = 0;

    // 找到满足请求的最小order
    while ((1 << target_order) < n) {
        target_order++;
    }

    // cprintf("Requesting %lu pages (order %lu)\n", n, target_order);
    // for (int i = 0; i <= MAX_ORDER; i++) {
    //     cprintf("Free blocks at order %d: %u\n", i, nr_free[i]);
    // }

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
    return NULL; // 找不到合适的块，返回NULL
}

static void
buddy_system_free_pages(struct Page *base, size_t n) {
    assert(n > 0);
    size_t order = 0;

    // 找到合适的order
    while ((1 << order) < n) {
        order++;
    }

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

    // cprintf("Releasing %lu pages at order %lu\n", n, order);
    // for (int i = 0; i <= MAX_ORDER; i++) {
    //     cprintf("Free blocks at order %d: %u\n", i, nr_free[i]);
    // }
}

static size_t
buddy_system_nr_free_pages(void) {
    size_t total_free = 0;
    for (int i = 0; i <= MAX_ORDER; i++) {
        total_free += nr_free[i] * (1 << i);
    }
    return total_free;
}

static void
basic_check(void) {
    struct Page *p0, *p1, *p2;
    p0 = p1 = p2 = NULL;
    assert((p0 = alloc_page()) != NULL);
    assert((p1 = alloc_page()) != NULL);
    assert((p2 = alloc_page()) != NULL);

    assert(p0 != p1 && p0 != p2 && p1 != p2);
    assert(page_ref(p0) == 0 && page_ref(p1) == 0 && page_ref(p2) == 0);

    assert(page2pa(p0) < npage * PGSIZE);
    assert(page2pa(p1) < npage * PGSIZE);
    assert(page2pa(p2) < npage * PGSIZE);

    list_entry_t free_list_store[MAX_ORDER + 1];
    unsigned int nr_free_store[MAX_ORDER + 1];
    for (int i = 0; i <= MAX_ORDER; i++) {
        free_list_store[i] = free_list[i];
        list_init(&free_list[i]);
        nr_free_store[i] = nr_free[i];
        nr_free[i] = 0;
    }

    assert(alloc_page() == NULL);

    free_page(p0);
    free_page(p1);
    free_page(p2);
    assert(nr_free_pages() == 3);

    assert((p0 = alloc_page()) != NULL);
    assert((p1 = alloc_page()) != NULL);
    assert((p2 = alloc_page()) != NULL);

    assert(alloc_page() == NULL);

    free_page(p0);
    assert(!list_empty(&free_list[0]));

    struct Page *p;
    assert((p = alloc_page()) == p0);
    assert(alloc_page() == NULL);

    assert(nr_free_pages() == 0);

    for (int i = 0; i <= MAX_ORDER; i++) {
        free_list[i] = free_list_store[i];
        nr_free[i] = nr_free_store[i];
    }

    free_page(p);
    free_page(p1);
    free_page(p2);
}

static void
buddy_system_check(void) {
    int total = 0;
    // 遍历所有的 order，计算空闲块的总数
    for (int i = 0; i <= MAX_ORDER; i++) {
        list_entry_t *le = &free_list[i];
        while ((le = list_next(le)) != &free_list[i]) {
            struct Page *p = le2page(le, page_link);
            assert(PageProperty(p));
            assert(p->property == i);
            total += (1 << i); // (1 << i) 为当前每个内存块的页数
        }
    }
    assert(total == nr_free_pages());

    // 调用基本检查
    basic_check();

    // 分配 5 页进行测试
    struct Page *p0 = alloc_pages(5), *p1, *p2;
    assert(p0 != NULL);
    assert(!PageProperty(p0));

    // 将所有空闲块暂存起来并清空
    list_entry_t free_list_store[MAX_ORDER + 1];
    unsigned int nr_free_store[MAX_ORDER + 1];
    for (int i = 0; i <= MAX_ORDER; i++) {
        free_list_store[i] = free_list[i];
        list_init(&free_list[i]); // 直接初始化
        nr_free_store[i] = nr_free[i];
        nr_free[i] = 0;
    }

    // 清空后不能再分配任何一页
    assert(alloc_page() == NULL);

    // 释放5页（实际是8页），重新进行分配测试
    free_pages(p0, 5);
    // 8页不足以分配大于8的内存
    assert(alloc_pages(9) == NULL);
    assert(alloc_pages(16) == NULL);
    assert(PageProperty(p0));
    assert((p1 = alloc_pages(3)) != NULL); // 分配 3(4) 页，成功
    assert((p2 = alloc_pages(5)) == NULL); // 再分配 5(8) 页，不成功
    assert((p2 = alloc_pages(3)) != NULL); // 再分配 3(4) 页，成功
    assert(alloc_page() == NULL); // 8-4-4=0，不能再分配
    assert(nr_free_pages() == 0);

    // 恢复之前的内存块
    for (int i = 0; i <= MAX_ORDER; i++) {
        free_list[i] = free_list_store[i];
        nr_free[i] = nr_free_store[i];
    }

    // 释放所有内存
    free_pages(p1, 3);
    free_pages(p2, 3);

    // 再次检测总数
    int count_check = 0, total_check = 0;
    for (int i = 0; i <= MAX_ORDER; i++) {
        list_entry_t *le = &free_list[i];
        while ((le = list_next(le)) != &free_list[i]) {
            struct Page *p = le2page(le, page_link);
            count_check++, total_check += (1 << i);
        }
    }
    assert(total == total_check);
}



// 这个结构体在
const struct pmm_manager buddy_system_pmm_manager = {
    .name = "buddy_system_pmm_manager",
    .init = buddy_system_init,
    .init_memmap = buddy_system_init_memmap,
    .alloc_pages = buddy_system_alloc_pages,
    .free_pages = buddy_system_free_pages,
    .nr_free_pages = buddy_system_nr_free_pages,
    .check = buddy_system_check,
};
