#include <stdarg.h>
#include <stdbool.h>
#include <stdio.h>

static void hexdump(unsigned num, char symb) {
	bool started = false;

	for(int shift = 28; shift >= 0; shift -= 4) {
		unsigned halfbyte = (num >> shift) & 0xf;
		if(started || halfbyte) {
			if(halfbyte < 10)
				putchar('0' + halfbyte);
			else
				putchar(symb + halfbyte - 10);

			started = true;
		}
	}

	if(!started)
		putchar('0');
}

static void decdump(unsigned num) {
	bool started = false;

	for(int div = 1000000000; div != 1; div /= 10) {
		unsigned digit = num / div;
		if(started || digit) {
			putchar('0' + num / div);

			started = true;
		}

		num %= div;
	}

	putchar('0' + num);
}

static void sdecdump(int num) {
	if(num < 0) {
		putchar('-');
		num *= -1;
	}

	decdump((unsigned) num);
}

int printf(const char *restrict format, ...) {
	va_list args;
	va_start(args, format);

	for(int chr, index = 0; (chr = format[index]); index++) {
		if(chr == '%') {
			int num = va_arg(args, int);
			switch(format[++index]) {
			case 'd':
			case 'i':
				sdecdump(num);
				break;

			case 'u':
				decdump(num);
				break;

			case 'x':
				hexdump((unsigned) num, 'a');
				break;

			case 'X':
				hexdump((unsigned) num, 'A');
				break;

			case 'c':
				putchar(num);
				break;

			case 's':
				puts((const char *) num);
				break;

			case '%':
				putchar('%');
				break;

			default:
				return 1;
			}
		} else
			putchar(chr);
	}

	va_end(args);
	return 0;
}

int putchar(int c) {
	__asm__("ecall");

	return c & 0x8f;
}

int puts(const char *s) {
	while(*s)
		putchar(*s++);

	return 0;
}
