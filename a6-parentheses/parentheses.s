.data

input:		.asciz	"[]{}[()()]"

.text

.global main

main:
	#prologue
	pushq	%rbp			# store the caller's base pointer on the stack
	movq	%rsp, %rbp		# update the base pointer for this stack frame

	movq	$input, %rdx		# move the string pointer to %RDX

	movzb	(%rdx), %eax 		# zero extend the character (byte) to 32-bit eax
	pushw	(%eax)			# so that it can be pushed onto the stack
	incq	%rdx			# increment rdx to point to the next character

loop:
	movzb	(%rdx), %eax 		# zero extend the next character (byte) to 32-bit eax
	popq	%rcx			# pop the character from the top of the stack

	
	

	# epilogue
	movq	%rbp, %rsp		# clear the stack variables
	popq	%rbp			# restore the caller's base pointer

end:
	movq	$0, %rax		# load the exit code
	call	printf			# and exit
