# ASCII coes for parentheses
# (	40
# )	41
# <	60
# >	62
# [	91
# ]	93
# {	123
# }	125

.data

open_brackets:
	.ascii	"("
	.ascii	"<"
	.ascii	"["
	.ascii	"{"
closed_brackets:
	.ascii	")"
	.ascii	">"
	.ascii	"]"
	.ascii	"}"

input:		.asciz	"[]{}[()()]"

.text

.global main

main:
	#prologue
	pushq	%rbp			# store the caller's base pointer on the stack
	movq	%rsp, %rbp		# update the base pointer for this stack frame

	movq	$input, %rdi		# move the string pointer to %RDX
	leaq	open_brackets, %rsi	# move the addres of first bracket to check for

	movq	$3, %rcx		# rcx as a loop counter for LOOP
open_check:
	cmpsb				# compare ASCII characters at RSI and RDi loc
	pushf				# preserve the flags reg after cmp
	dec	%rdi			# compensate for automatic inc after cmpsb
	popf				# pop back rflags
	je	is_open_bracket		# if ZF=1 its an open bracket, jump to corresp code
	loop	open_check

	movq	$3, %rcx
closed_check:
	cmpsb
	pushf
	dec	%rdi
	popf
	je	is_closed_bracket
	loop	closed_check
	
is_open_bracket:
is_clsoed_bracket:

	# epilogue
	movq	%rbp, %rsp		# clear the stack variables
	popq	%rbp			# restore the caller's base pointer

end:
	movq	$0, %rax		# load the exit code
	call	printf			# and exit
