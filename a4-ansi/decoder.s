.data

#ANSI color guide at https://talyian.github.io/ansicolors/

output_string:		.asciz	"%c"
back_color:		.byte	0x0		# ANSI background color
fore_color:		.byte	0x0		# ANSI foregound color
counter:		.byte	0x0		# amount of times the character is to be printed
character:		.byte	0x0		# the character to be printed (ASCII)
relative_address:	.long	0x0		# the relative address of the next memory block
first_address:		.long	0x0

.text
.include "final.s"

.global main

# ************************************************************
# Subroutine: decode                                         *
# Description: decodes message as defined in Assignment 3    *
#   - 2 byte unknown                                         *
#   - 4 byte index                                           *
#   - 1 byte amount                                          *
#   - 1 byte character                                       *
# Parameters:                                                *
#   first: the address of the message to read                *
#   return: no return value                                  *
# ************************************************************


# Subroutine decode 
#Parameter 1 (%RDI): address of the block to read
decode:		
	# prologue
	pushq	%rbp 			# push the base pointer (and align the stack)
	movq	%rsp, %rbp		# copy stack pointer value to base pointer

	movl	%edi, first_address	#store the first address in the variable

decode_loop:
	movq	(%edi), %R8		# copy the memory block at address (%EDI) to register 8
	movb	%R8B, character		# store LSB (Byte 8) in the character variable
	shrq	$8, %R8			# shift all bytes to the right (now Byte 7 will be last)
	
	movb	%R8B, counter		# store LSB (Byte 7) to the counter variable
	shrq	$8, %R8		  	# shift right by byte (now Byte 6 is last)

	movl	%R8D, relative_address	# copy 4 LSBs (Bytes 3-6 incl) to relative_address
	shr	$32, %R8		# shift right by 4 bytes (now Byte 2 is last)

	movb	%R8B, fore_color	# copy LSB (Byte 2) to the foreground color code 
	shr	$8, %R8			# shift right by 1 byte (now Byte 1 is last)

	movb	%R8B, back_color	# copy LSB to the background color code variable

	#print loop
	movb	counter, %DL		# copy the counter variable to the lowest Byte of rdx
print_loop:
	cmpb	$0, %DL
	jle	end_loop		# if counter <= 0, end the loop

	movq	$0, %rax		# no vector registers for printf
	movq	$output_string, %rdi	# load the output string
	movzb	character, %rsi		# load the character(zero extended) to be printed
	movb	%DL, counter		# buffer the value in %DL in counter variable
	call	printf			
	movb	counter, %DL		# copy the counter back to %DL

	decb	%DL			# decrement the counter
	jmp	print_loop		# next iteration
end_loop:
	cmpl	$0, relative_address	
	je	end_decode		# if relative_address is 0, end the subroutine

	movq	$0, %rdi		# zero register D
	movl	first_address, %eax	# base for calculating the next address
	movl	relative_address, %R9D	# index for calculating the next address
	leal	(%eax, %R9D, 8), %edi 	# calculate and load the next address to %edi

	jmp	decode_loop		# go to the next iteration
	
end_decode:	
	# epilogue
	movq	%rbp, %rsp		# clear local variables from stack
	popq	%rbp			# restore base pointer location 
	ret

main:
	pushq	%rbp 			# push the base pointer (and align the stack)
	movq	%rsp, %rbp		# copy stack pointer value to base pointer

	movq	$MESSAGE, %rdi		# first parameter: address of the message
	call	decode			# call decode

	popq	%rbp			# restore base pointer location 
	movq	$0, %rdi		# load program exit code
	call	exit			# exit the program

