/*
	Test: Console output
	Author: Sol

	Tries out ECALL instruction.  Prints 'Pass.' to the console on success.
	You must be able to pass this test in order to run the unit test suite.
*/

	.text
	li   a0, 0x50 # 'P'
	ecall
	li   a0, 0x61 # 'a'
	ecall
	li   a0, 0x73 # 's'
	ecall
	li   a0, 0x73
	ecall
	li   a0, 0x2e # '.'
	ecall
	li   a0, 0x0a # '\n'
	ecall
