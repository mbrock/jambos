
#include <terminal.hh>

Terminal *console;

extern "C" {
  void stage3 () {
    Terminal local_console(reinterpret_cast<u8_t*>(0xb8000));
    ::console = &local_console;

    console->set_modeline("JAMBOS 0.1");
    kprintf("Hello %x!\n", 0xdeadbeef);

    for (;;)
      __asm__ ("hlt");
  }
}
