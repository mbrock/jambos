
#include <printf.hh>
#include <static-string.hh>

template <typename T>
static T next_argument (unsigned char *ptr)
{
  T x = * ((T*) (ptr));
  ptr += sizeof (T);
  return x;
}

void
ksprintf (StaticString &output,
          const char   *format,
	  va_list       argp)
{
  char bytes [1024];
  StaticString buffer (bytes, sizeof bytes);

  int zero_pad;
  int zero_pad_width;

  while (int c = *format++)
    {
      zero_pad = 0;
      zero_pad_width = 0;

      if (c != '%')
        output.add (c);
      else
        {
          c = *format++;

          if (c == '0')
            {
              zero_pad = 1;
              zero_pad_width = *format++ - '0';
              c = *format++;
            }

          if (c == 'd' || c == 'x' || c == 'p')
            {
              u32_t number (va_arg (argp, u32_t));
              int radix  ((c == 'd' ? 10 : 16));
              int pad    (zero_pad ? zero_pad_width : 8);

              buffer.add (number, radix);
              if (zero_pad || (c == 'p'))
                buffer.pad_left ('0', pad);

              output.add (buffer);
              buffer.clear ();
            }

	  if (c == 'X' || c == 'P')
	    {
	      u64_t number (va_arg (argp, u64_t));
              int radix  ((c == 'D' ? 10 : 16));
              int pad    (zero_pad ? zero_pad_width : 16);

              buffer.add (number, radix);
              if (zero_pad || (c == 'P'))
                buffer.pad_left ('0', pad);

              output.add (buffer);
              buffer.clear ();
	    }

          else if (c == 's')
            {
              char *s (va_arg (argp, char *));
              for (int i = 0; s[i]; i++)
                output.add (s[i]);
            }

          else if (c == 'c')
            {
              char c (va_arg (argp, int));
              output.add (c);
            }
        }
    }
}
