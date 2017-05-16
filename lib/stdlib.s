	.globl abs
abs:
	bgez  a0, abs_skip_
	neg   a0, a0
abs_skip_:
	ret

	.globl exit
exit:
	.long 0x0

	.globl labs
labs:
	j     abs
