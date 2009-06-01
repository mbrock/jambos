
#ifndef COMMON_H
#define COMMON_H

#define __STRINGIFY(x) #x
#define STRINGIFY(x) __STRINGIFY(x)

typedef unsigned int u32_t;
typedef unsigned short u16_t;
typedef unsigned char u8_t;
typedef unsigned long u64_t;

inline u8_t inb (u16_t io)
{
  u8_t byte;
  __asm__ ("inb %w1, %b0" : "=a" (byte) : "d" (io));
  return byte;
}

inline void outb (u16_t io, u8_t b)
{
  __asm__ ("outb %b0, %w1" :: "a" (b), "Nd" (io));
}

template <typename T>
inline void swap (T& a, T& b)
{
  T tmp = a;
  a = b;
  b = tmp;
}

inline void memset (void *dest,
                    char  c,
                    u32_t size)
{
  char *d (static_cast <char *> (dest));
  while (size--)
    *d++ = c;
}

inline void memmove (void *dest,
                     void *src,
                     u32_t size)
{
  char *d (static_cast <char *> (dest));
  char *s (static_cast <char *> (src));
  while (size--)
    *d++ = *s++;
}

inline void memcpy (void *dest,
                    void *src,
                    u32_t size)
{
  memmove (dest, src, size);
}

inline u32_t strlen (const char *s)
{
  int i = 0;
  while (*s++)
    ++i;
  return i;
}

inline void strcpy (char *dest,
                    const char *src)
{
  while ((*dest++ = *src++))
    ;
}

#endif
