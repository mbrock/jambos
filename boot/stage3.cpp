#include <terminal.hh>
#include <bootinfo.hh>
#include <paging.hh>
#include <common.hh>


void paging_init();
void create_page_table(void *base_address);

extern "C" {

void stage3 () {
	Terminal local_console(reinterpret_cast<u8_t*>(0xb8000));
	::console = &local_console;

	console->set_modeline("JAMBOS 0.1 (with %d bit long type!)", 8 * sizeof (long));

	kprintf("Memory map (%d entries):\n", (int) bootinfo.memory_map_entries);

	//PagingEntry *entry = 10 * 1024 * 1024;

	for (int i = 0; i < bootinfo.memory_map_entries; i++) {
		kprintf("  Type %d (%P + %D KB)\n",
				bootinfo.memory_map[i].type,
				bootinfo.memory_map[i].base,
				bootinfo.memory_map[i].length / 1024);
	}

	for (;;) {
		__asm__ ("hlt");
    }
}

}



void paging_init() {
	PagingEntry *pml4 = reinterpret_cast<PagingEntry*>(0x100000);
	PagingEntry *pml3 = reinterpret_cast<PagingEntry*>(0x100000 + 0x1000);

	memset(reinterpret_cast<void*>(0x100000), 0, 0x2000);

	*pml4 = PagingEntry(reinterpret_cast<void*>(0x101000), 1, false);
	*pml3 = PagingEntry(reinterpret_cast<void*>(0x102000), 1, false);

    /*
	MemoryMapEntry &mme = bootinfo.memory_map[bootinfo.memory_map_entries];

	u8_t *last_addr = reinterpret_cast<u8_t*>(mme.base + mme.length);

	u8_t *phys_base = 0;

	PagingEntry *page_dir_entry = reinterpret_cast<PagingEntry*>(0x100000 + 0x2000);
	PagingEntry *page_table_entry = reinterpret_cast<PagingEntry*>(0x100000 );
    */
    
	for (;;) {
		
	}
}


void create_page_table(PagingEntry *table_base, void *phys_base) {
	u8_t *b = reinterpret_cast<u8_t*>(phys_base);

	for (PagingEntry *p = table_base; p - table_base < 512; p++) {
		*p = PagingEntry(reinterpret_cast<void*>(b), 1, false);
		b += 0x1000;
	}
}
