# ASCII codes for parentheses
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

invalid_msg:	.asciz	"invalid"
valid_msg:	.asciz	"valid"
.text

.include "basic.s"

.global main

# *******************************************************************************************
# Subroutine: check_validity                                                                *
# Description: checks the validity of a string of parentheses as defined in Assignment 6.   *
# Parameters:                                                                               *
#   first: the string that should be check_validity                                         *
#   return: the result of the check, either "valid" or "invalid"                            *
# *******************************************************************************************
check_validity:
	# prologue
	pushq	%rbp 			# push the base pointer (and align the stack)
	movq	%rsp, %rbp		# copy stack pointer value to base pointer

main_loop:
	cmpb	$0, (%rdi)		# check if its the end of the string
	je	stack_check		# proceed to stack check
	movq	$open_brackets, %rsi	# move the addres of first bracket to check for
	movq	$4, %rcx		# rcx as a loop counter for LOOP
open_check:
	cmpsb				# compare ASCII characters at RSI and RDi loc
	pushf				# preserve the flags reg after cmp
	dec	%rdi			# compensate for automatic inc after cmpsb
	popf				# pop back rflags
	je	is_open_bracket		# if ZF=1 its an open bracket, jump to corresp code
	loop	open_check		# loop as long as rcx != 0

	movq	$closed_brackets, %rsi	# move the check string to closed_brackets
	movq	$4, %rcx		# rcx as a loop counter for LOOP
closed_check:
	cmpsb				# compare the string at the given locations
	pushf				# push the rflags register
	dec	%rdi			# compensate for automatic inc after cmpsb
	popf				# pop back rflasg
	je	is_closed_bracket	# if ZF=1 its a closed bracket, jmp to coreesp code
	loop	closed_check		# loop as long as rcx != 0
	
	# jmp	invalid_character_error	# if code went this far, no bracket match was found-err
	# just ignore the character
	inc	%rdi			# increment the main pointer
	jmp	main_loop

is_open_bracket:
	dec	%rsi			# compensate for the automatic inc of cmpsb
	pushq	%rsi			# push the address string of the bracket on the stack
	inc	%rdi			# increment the main string pointer
	jmp 	main_loop
is_closed_bracket:
	#first check if anything is on the stack
	cmpq	%rsp, %rbp		# compare rsp and rbp
	je	invalid			# if equal this closed bracket has not match -> invalid
	dec	%rsi			# compensate for automatic inc of cmpsb
	popq	%rax			# pop the address string of the bracket on the stack
	sub	%rax, %rsi		# calculate now_closed - latest_open, should be 4
	cmpq	$4, %rsi		# check if the result is actually 4
	jnz	invalid			# if ZF=0 then the brackets dont match, ->invalid

	inc	%rdi			# increment the main string pointer
	jmp	main_loop

stack_check:
	#check if any open bracket was left on the stack
	cmpq	%rbp, %rsp		# compare rsp and rbp
	je	valid			# if equal, all brackets had a matching pair -> valid
	jmp	invalid			# else -> invalid

invalid:
	movq	%rbp, %rsp		# clear the stack to align
	movq	$invalid_msg, %rdi
	movq	$0, %rax
	call 	printf
	movq	$invalid_msg, %rax
	jmp	end
valid:
	movq	$valid_msg, %rdi
	movq	$0, %rax
	call 	printf
	movq	$valid_msg, %rax
	jmp	end
	
end:
	# epilogue
	movq	%rbp, %rsp		# clear local variables from stack
	popq	%rbp			# restore base pointer location 
	ret

main:
	pushq	%rbp 			# push the base pointer (and align the stack)
	movq	%rsp, %rbp		# copy stack pointer value to base pointer

	movq	$MESSAGE, %rdi		# first parameter: address of the message
	call	check_validity		# call check_validity

	popq	%rbp			# restore base pointer location 
	movq	$0, %rdi		# load program exit code
	call	exit			# exit the program

