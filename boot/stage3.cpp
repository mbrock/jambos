
#include <terminal.hh>
#include <bootinfo.hh>

extern "C" {
  void stage3 () {
    Terminal local_console(reinterpret_cast<u8_t*>(0xb8000));
    ::console = &local_console;

    console->set_modeline("JAMBOS 0.1");

    kprintf("Memory map (%d entries):\n", (int) bootinfo.memory_map_entries);
    for (int i = 0; i < bootinfo.memory_map_entries; i++)
      kprintf ("  Type %d (%P + %D KB)\n",
	       bootinfo.memory_map[i].type,
	       bootinfo.memory_map[i].base,
	       bootinfo.memory_map[i].length / 1024);

    for (;;)
      __asm__ ("hlt");
  }
}
