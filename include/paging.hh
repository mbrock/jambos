
#ifndef PAGING_HH
#define PAGING_HH

struct PagingEntry {
  PagingEntry(void *base, u8_t flags, bool exb)
    : low ((((u32_t) base) & 0xfffff000) | flags),
      high (((u64_t) base >> 32) | ((u64_t) exb << 63))
  { }

  u32_t low;
  u32_t high;
} __attribute__ ((__packed__));

#endif
