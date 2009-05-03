
#ifndef TERMINAL_H
#define TERMINAL_H

#include <common.hh>

class Terminal
{
 public:
  u8_t *video;
  int attribute;
  int x, y;
  int columns, rows;
  char modeline [70];

  Terminal  (u8_t *video);
  ~Terminal ();

  void clear       ();
  void scroll_down ();

  void display_test   ();
  void horizontal_bar ();

  void put         (char c);
  void printf      (const char *format, ...);

  void set_modeline (const char *format, ...);
  void refresh_modeline ();

  void move_cursor (int x, int y);
};

extern Terminal *console;

#define kprintf console->printf

class TerminalAttribute
{
 public:
  Terminal &terminal;
  int old_attribute;

  TerminalAttribute (Terminal &terminal,
		     int attribute);
  ~TerminalAttribute ();
};

struct kernel_panic_t {
  TerminalAttribute normal_red;

  kernel_panic_t ()
    : normal_red (*console, 0x4)
  {
    TerminalAttribute bold_red (*console, 8 + 4);
    console->printf ("\n    Kernel panic!  ");
  }

  ~kernel_panic_t () {
    normal_red.~TerminalAttribute ();
    console->printf ("\n    Halting.");
    for (;;)
      __asm__ ("hlt");
  }
};

#endif
