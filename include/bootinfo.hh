
#ifndef BOOTINFO_HH
#define BOOTINFO_HH

#include <common.hh>

struct MemoryMapEntry {
  u64_t base;
  u64_t length;
  u32_t type;
} __attribute__ ((__packed__));

struct BootInfo {
  u16_t memory_map_entries;
  MemoryMapEntry memory_map[32];
} __attribute__ ((__packed__));
		 
extern BootInfo bootinfo;
		 
#endif
