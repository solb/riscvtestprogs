#include <ctype.h>

int isalnum(int c) {
	return isalpha(c) || isdigit(c);
}

int isalpha(int c) {
	return isupper(c) || islower(c);
}

int isdigit(int c) {
	return '0' <= c && c <= '9';
}

int islower(int c) {
	return 'a' <= c && c <= 'z';
}

int isupper(int c) {
	return 'A' <= c && c <= 'Z';
}

int isxdigit(int c) {
	return isdigit(c) || ('A' <= c && c <= 'F') || ('a' <= c && c <= 'f');
}

int tolower(int c) {
	return isupper(c) ? c + 0x20 : c;
}

int toupper(int c) {
	return islower(c) ? c - 0x20 : c;
}
