.data


.text

.global main
.global my_printf


# my_printf subroutine
my_printf:
	# prologue
	pushq	%rbp			# preserve the caller's base pointer
	movq	%rsp, %rbp		# update the base pointer for this stack frame

	# code goes here ...	

	# epilogue
	movq	%rbp, %rsp		# clear the stack varialbes
	popq	%rbp			# restore the caller's base pointer

main:
	# prologue
	pushq	%rbp			# preserve the caller's base pointer
	movq	%rsp, %rbp		# update the base pointer for this stack frame

	# epilogue
	movq	%rbp, %rsp		# clear the stack varialbes
	popq	%rbp			# restore the caller's base pointer



