/*
	Test: Fill memory
	Author: Sol

	Fills the lowest 1024 bytes of memory with those locations' own addresses, then verifies
	this block contains the intended values.  Leaves a 0 in $a0 on success.
*/

#define LIMIT 256 # Process locations LT this address.

#define addr  t0
#define limit t1

	.text
	.align 8                         # Align to 256-byte boundary.
main:
	xor  addr, addr, addr            # Zero addr.
	li   limit, LIMIT
populate_loop:
	sb   addr, (addr)
	addi addr, addr, 1
	blt  addr, limit, populate_loop

#define val t2
#define cmp t3

	xor  addr, addr, addr
verify_loop:
	lbu  val, (addr)
	xor  val, val, addr
	seqz val, val
	slt  cmp, addr, limit
	and  cmp, val, cmp
	addi addr, addr, 1
	bne  cmp, zero, verify_loop

	xor  a0, a0, a0
	addi addr, addr, -1
	beq  addr, limit, fin
	li   a0, 1
fin:
