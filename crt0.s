	.text
_start:
	call main
	.long 0x0

	.weak main
main:
