#include <defs.h>
#include <list.h>
#include <riscv.h>
#include <stdio.h>
#include <string.h>
#include <swap.h>

static list_entry_t pra_list_head;

static int
_lru_init_mm(struct mm_struct *mm) {
    list_init(&pra_list_head);
    mm->sm_priv = &pra_list_head;
    return 0;
}

static int
_lru_map_swappable(struct mm_struct *mm, uintptr_t addr, struct Page *page, int swap_in) {
    list_entry_t *head = (list_entry_t *)mm->sm_priv;
    list_entry_t *entry = &(page->pra_page_link);

    assert(entry != NULL && head != NULL);
    list_add_before(head, entry);  // 插入到链表末尾
    return 0;
}

static void 
_lru_access_page(struct mm_struct *mm, uintptr_t addr) {
    list_entry_t *head = (list_entry_t *)mm->sm_priv;  // LRU 头节点
    pte_t *ptep = get_pte(mm->pgdir, addr, 0);
    if (ptep == NULL || !(*ptep & PTE_V)) return;

    struct Page *page = pte2page(*ptep);
    list_entry_t *entry = &(page->pra_page_link);

    // 如果页面已经在 LRU 链表中，先将其移除
    if (!list_empty(entry)) {
        list_del(entry);  // 从当前位置移除
    }

    // 将页面插入链表尾部，表示最近访问
    list_add_before(head, entry);
}

static int
_lru_swap_out_victim(struct mm_struct *mm, struct Page **ptr_page, int in_tick) {
    list_entry_t *head = (list_entry_t *)mm->sm_priv;
    assert(head != NULL);
    assert(in_tick == 0);

    list_entry_t *victim_entry = list_next(head);
    if (victim_entry != head) {
        *ptr_page = le2page(victim_entry, pra_page_link);
        list_del(victim_entry);
    } else {
        *ptr_page = NULL;
    }
    return 0;
}

static int
_lru_check_swap(void) {
    cprintf("write Virt Page c in _lru_check_swap\n");
    *(unsigned char *)0x3000 = 0x0c;
    _lru_access_page(check_mm_struct, 0x3000);
    assert(pgfault_num == 4);

    cprintf("write Virt Page a in _lru_check_swap\n");
    *(unsigned char *)0x1000 = 0x0a;
    _lru_access_page(check_mm_struct, 0x1000);
    assert(pgfault_num == 4);

    cprintf("write Virt Page d in _lru_check_swap\n");
    *(unsigned char *)0x4000 = 0x0d;
    _lru_access_page(check_mm_struct, 0x4000);
    assert(pgfault_num == 4);

    cprintf("write Virt Page b in _lru_check_swap\n");
    *(unsigned char *)0x2000 = 0x0b;
    _lru_access_page(check_mm_struct, 0x2000);
    assert(pgfault_num == 4);

    cprintf("write Virt Page e in _lru_check_swap\n");
    *(unsigned char *)0x5000 = 0x0e;
    _lru_access_page(check_mm_struct, 0x5000);
    assert(pgfault_num == 5);

    // 再次访问页面 b, 验证 b 是最近使用的页面之一
    cprintf("write Virt Page b again in _lru_check_swap\n");
    *(unsigned char *)0x2000 = 0x0b;
    _lru_access_page(check_mm_struct, 0x2000);
    assert(pgfault_num == 5);

    // 再次访问页面 a, 验证 a 也是最近使用的页面之一
    cprintf("write Virt Page a again in _lru_check_swap\n");
    *(unsigned char *)0x1000 = 0x0a;
    _lru_access_page(check_mm_struct, 0x1000);
    assert(pgfault_num == 6);

    // 持续访问其他页面
    cprintf("write Virt Page b again in _lru_check_swap\n");
    *(unsigned char *)0x2000 = 0x0b;
    _lru_access_page(check_mm_struct, 0x2000);
    assert(pgfault_num == 7);

    cprintf("write Virt Page c again in _lru_check_swap\n");
    *(unsigned char *)0x3000 = 0x0c;
    _lru_access_page(check_mm_struct, 0x3000);
    assert(pgfault_num == 8);

    cprintf("write Virt Page d again in _lru_check_swap\n");
    *(unsigned char *)0x4000 = 0x0d;
    _lru_access_page(check_mm_struct, 0x4000);
    assert(pgfault_num == 9);

    cprintf("write Virt Page e again in _lru_check_swap\n");
    *(unsigned char *)0x5000 = 0x0e;
    _lru_access_page(check_mm_struct, 0x5000);
    assert(pgfault_num == 10);

    cprintf("write Virt Page a after swap\n");
    assert(*(unsigned char *)0x1000 == 0x0a);
    *(unsigned char *)0x1000 = 0x0a;
    _lru_access_page(check_mm_struct, 0x1000);
    assert(pgfault_num == 11);

    return 0;
}

static int
_lru_init(void) {
    return 0;
}

static int
_lru_set_unswappable(struct mm_struct *mm, uintptr_t addr) {
    return 0;
}

static int
_lru_tick_event(struct mm_struct *mm) {
    return 0;
}

struct swap_manager swap_manager_lru = {
    .name = "lru swap manager",
    .init = &_lru_init,
    .init_mm = &_lru_init_mm,
    .tick_event = &_lru_tick_event,
    .map_swappable = &_lru_map_swappable,
    .set_unswappable = &_lru_set_unswappable,
    .swap_out_victim = &_lru_swap_out_victim,
    .check_swap = &_lru_check_swap,
};