
#ifndef PRINTF_H
#define PRINTF_H

#include <stdarg.h>

#include <static-string.hh>

void ksprintf (StaticString &output,
               const char *format,
	       va_list argp);

#endif
