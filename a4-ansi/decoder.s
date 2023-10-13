.data

#ANSI color guide at https://talyian.github.io/ansicolors/
fblack:                 .asciz  "\x1b[30m"
fred:                   .asciz  "\x1b[31m"
fgreen:                 .asciz  "\x1b[32m"
fyellow:                .asciz  "\x1b[33m"
fblue:                  .asciz  "\x1b[34m"
fmagenta:               .asciz  "\x1b[35m"
fcyan:                  .asciz  "\x1b[36m"
fwhite:                 .asciz  "\x1b[37m"

bblack:                 .asciz  "\x1b[40m"
bred:                   .asciz  "\x1b[41m"
bgreen:                 .asciz  "\x1b[42m"
byellow:                .asciz  "\x1b[43m"
bblue:                  .asciz  "\x1b[44m"
bmagenta:               .asciz  "\x1b[45m"
bcyan:                  .asciz  "\x1b[46m"
bwhite:                 .asciz  "\x1b[47m"

#string definitions
output_string:          .asciz  "%c"

reset:                  .asciz  "\x1b[0m"
stop_blinking:          .asciz  "\x1b[25m"    
bold:                   .asciz  "\x1b[1m"    
faint:                  .asciz  "\x1b[2m"
conceal:                .asciz  "\x1b[8m"
reveal:                 .asciz  "\x1b[28m"
blink:                  .asciz  "\x1b[5m"

back_color:             .byte   0x0             # ANSI background color
fore_color:             .byte   0x0             # ANSI foregound color
counter:                .byte   0x0             # amount of times the character is to be printed
character:              .byte   0x0             # the character to be printed (ASCII)
relative_address:       .long   0x0             # the relative address of the next memory block
first_address:          .long   0x0 


.text
.include "helloWorld.s"

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

	

	#set background color
	movq	$0, %RDX		# zero the rdx register
	movb	back_color, %DL		# copy the background color code to DL
	shlq	$3, %RDX		# muiltiply by 8
	movq	background_color_switch(%RDX), %RDX	# load the address from the table
	call	*%RDX			# call the correspoing subroutine to the this case
	
	movq	$0, %rax		# set the background color with printf
	call	printf

	#set foreground color
	movq	$0, %RDX		# zero the rdx register
	movb	fore_color, %DL		# copy the background color code to DL
	shlq	$3, %RDX		# muiltiply by 8
	movq	foreground_color_switch(%RDX), %RDX	# load the address from the table
	call	*%RDX			# call the correspoing subroutine to the this case
	
	movq	$0, %rax		# set the foreground color with printf
	call	printf

print:
	#print loop
	movb	counter, %DL		# copy the counter variable to the lowest Byte of rdx
print_loop:
	cmpb	$0, %DL
	jle	end_loop		# if counter <= 0, end the loop

	movq	$0, %rax		# no vector registers for printf
	movq	$output_string, %rdi	# load the output string
	movzb	character, %rsi		# load the character(zero extended) to be printed
	push	%RDX			# preserve the value of RDX
	push	%RDX			# align the stack
	call	printf			
	pop	%RDX
	pop	%RDX

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




# background color switch statement

background_color_switch:
	.quad	bcase0
	.quad	bcase1
	.quad	bcase2
	.quad	bcase3
	.quad	bcase4
	.quad	bcase5
	.quad	bcase6
	.quad	bcase7
bcase0:
	movq	$bblack, %RDI
	ret
bcase1:
	movq	$bred, %RDI
	ret
bcase2:
	movq	$bgreen, %RDI
	ret
bcase3:
	movq	$byellow, %RDI
	ret
bcase4:
	movq	$bblue, %RDI
	ret
bcase5:
	movq	$bmagenta, %RDI
	ret
bcase6:
	movq	$bcyan, %RDI
	ret
bcase7:
	movq	$bwhite, %RDI
	ret

foreground_color_switch:
	.quad	fcase0
	.quad	fcase1
	.quad	fcase2
	.quad	fcase3
	.quad	fcase4
	.quad	fcase5
	.quad	fcase6
	.quad	fcase7
fcase0:
	movq	$fblack, %RDI
	ret
fcase1:
	movq	$fred, %RDI
	ret
fcase2:
	movq	$fgreen, %RDI
	ret
fcase3:
	movq	$fyellow, %RDI
	ret
fcase4:
	movq	$fblue, %RDI
	ret
fcase5:
	movq	$fmagenta, %RDI
	ret
fcase6:
	movq	$fcyan, %RDI
	ret
fcase7:
	movq	$fwhite, %RDI
	ret
