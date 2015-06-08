#ifndef PAGING_HH
#define PAGING_HH
 
#include <cstdint>

struct PagingEntry {
  PagingEntry(void *base, u8_t flags, bool exb) {
    low = (reinterpret_cast<u64_t>(base) & 0xfffff000) | flags;
    high = (reinterpret_cast<u64_t>(base) >> 32) | ((static_cast<u64_t>(exb ? 1 : 0)) << 63);
  }
 
  u64_t low;
  u64_t high;
} __attribute__ ((__packed__));
 
#endif
