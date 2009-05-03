
#include <common.hh>
#include <static-string.hh>
#include <printf.hh>

#include <terminal.hh>

Terminal *console;

Terminal::Terminal (unsigned char *video)
  : video (video),
    attribute (7),
    x (0), y (1),
    columns (80),
    rows (24)
{
  clear ();
  modeline[0] = '\0';
}

Terminal::~Terminal ()
{
  clear ();
}

void
Terminal::clear ()
{
  x = y = 0;
  memset (video, 0, columns * rows * 2);
  refresh_modeline ();
  y = 1;
}

void
Terminal::scroll_down ()
{
  unsigned char *second_line (&video[2 * columns]);
  unsigned char *third_line  (&video[4 * columns]);
  unsigned char *last_line   (&video[2 * columns * (rows - 1)]);

  memmove (second_line, third_line, 2 * columns * (rows - 2));
  memset  (last_line, 0, 2 * columns);

  y = rows - 1;
  x = 0;
}

void
Terminal::display_test ()
{
  clear ();

  for (attribute = 7; attribute <= 0xFF; attribute++)
    put ('x');
}

void
Terminal::horizontal_bar ()
{
  for (int i (0); i < columns; i++)
    put ('-');
  put ('\n');
}

void
Terminal::put (char c)
{
  if (c == '\n')
    {
    newline:
      x = 0;
      y = y + 1;

      if (y >= rows)
        scroll_down ();

      return;
    }

  video[0 + 2 * (x + y * columns)] = c;
  video[1 + 2 * (x + y * columns)] = attribute;

  if (++x >= columns)
    goto newline;
}

unsigned const int printf_buffer_size = 4096;

void
Terminal::printf (const char *format, ...)
{
  va_list argp;
  char buffer [printf_buffer_size];
  StaticString string (buffer, sizeof buffer);

  va_start (argp, format);
  ksprintf (string, format, argp);
  va_end (argp);
  
  for (int i = 0; i < string.fill; i++)
    put (string.bytes[i]);
}

void
Terminal::set_modeline (const char *format,
			  ...)
{
  va_list argp;
  StaticString string (modeline, sizeof modeline - 1);

  va_start (argp, format);
  ksprintf (string, format, argp);
  va_end (argp);

  modeline[string.fill] = '\0';

  refresh_modeline ();
}

void
Terminal::refresh_modeline ()
{
  int old_y = y;
  int old_x = x;

  y = x = 0;

  {
    TerminalAttribute a (*console, 0x70);
    printf ("%s", modeline);
    for (int i = strlen (modeline); i < columns; i++)
      printf (" ");
  }

  y = old_y;
  x = old_x;
}
 
void
Terminal::move_cursor (int x, int y)
{
  u16_t crtc (0x3D4);
  u16_t offset (y * 80 + x);

  outb (crtc + 0, 14);
  outb (crtc + 1, offset >> 8);
  outb (crtc + 0, 15);
  outb (crtc + 1, offset);
}



TerminalAttribute::TerminalAttribute (Terminal &terminal,
                                            int attribute)
  : terminal (terminal)
  , old_attribute (terminal.attribute)
{
  terminal.attribute = attribute;
}

TerminalAttribute::~TerminalAttribute ()
{
  terminal.attribute = old_attribute;
}
