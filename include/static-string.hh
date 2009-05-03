
#ifndef STATIC_STRING_H
#define STATIC_STRING_H

#include <common.hh>

class StaticString
{
 public:
  int          size;
  char * const bytes;
  int          fill;

  StaticString (char *s, int size);

  void clear      ();
  
  void add        (char c);
  void add	  (const StaticString &s);
  void add        (u32_t x, int radix);
  void add        (u64_t x, int radix);

  void reverse	  ();
  void pad_left	  (char pad, int width);

  int  to_i       (int radix) const;
};

#endif
