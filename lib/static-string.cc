
#include <common.hh>
#include <static-string.hh>

StaticString::StaticString (char *s, int size)
  : size (size),
    bytes (s),
    fill (0)
{}

void
StaticString::clear ()
{
  fill = 0;
}

void
StaticString::add (char c)
{
  bytes[fill++] = c;
}

void
StaticString::add (const StaticString &s)
{
  memcpy (bytes + fill, s.bytes, s.fill);
  fill += s.fill;
}

void
StaticString::add (u32_t x, int radix)
{
  char buffer [33];
  StaticString tmp (buffer, sizeof buffer);

  do
    {
      int r (x % radix);
      tmp.add ((r < 10) ? r + '0' : r + 'a' - 10);
    }
  while (x /= radix);

  tmp.reverse ();
  add (tmp);
}

void
StaticString::add (u64_t x, int radix)
{
  char buffer [65];
  StaticString tmp (buffer, sizeof buffer);

  do
    {
      int r (x & 0xf);
      tmp.add ((r < 10) ? r + '0' : r + 'a' - 10);
    }
  while (x >>= 4);

  tmp.reverse ();
  add (tmp);
}

void
StaticString::reverse ()
{
  char *a (bytes);
  char *b (bytes + fill - 1);

  while (a < b)
    swap (*a++, *b--);
}

void
StaticString::pad_left (char pad, int width)
{
  int padding (width - fill);
  
  if (padding <= 0)
    return;

  // Flip so we can append instead of prepending.
  reverse ();

  for (int i = 0; i < padding; i++)
    bytes[fill + i] = pad;

  // Correct size.
  fill += padding;

  // And flip it back.
  reverse ();
}

int
StaticString::to_i (int radix) const
{
  int value (0);

  for (int i (0), power (1);
       i < size;
       ++i, power *= radix)
    value += power * (bytes [size - i - 1] - '0');

  return value;
}
