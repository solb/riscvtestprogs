/*
	Test: Arithmetic instructions
	Author: Sol

	Tries out the OP and OP-IMM classes of instuctions.  Leaves a 0 in $a0 on success.
*/

	.text
	addi  t0, zero, 1 # Set t0 to 1.
	add   t0, t0, t0  # Double t0 to 2.
	xori  t1, t0, -1  # NOT t0 into t1.
	sub   t2, t0, t1  # Subtract -3 from 2 into t2.

	xori  t2, t2, 5   # Check whether correct so far.
	sltiu a0, t2, 1   # SEQZ into a0.

	or    t2, t0, t1  # Set ALL THE BITS!

	xori  t2, t2, -1  # Check again.
	sltiu t2, t2, 1   # SEQZ the truth...
	and   a0, a0, t2  # Update running a0.

	and   t2, t0, t1  # Le zéro.

	xor   t2, t2, zero # No?
	sltiu t2, t2, 1    # Let's find out.
	and   a0, a0, t2   # Here's our result.

	srai  t1, t1, 1  # Halve t1.
	slli  t1, t1, 31 # Set the t1 sign bit.
	srli  t2, t1, 1  # Unsigned shift into t2.
	srai  t3, t1, 1  # Signed shift into t3.

	xor   t3, t2, t3 # Show me a *sign* they did something different!
	xor   t2, t1, t3 # Look Mom, no problem!
	sltiu t2, t2, 1  # Is there?
	and   a0, a0, t2 # Either way, remember it.

	xori  a0, a0, 1    # Generate a proper exit status.
