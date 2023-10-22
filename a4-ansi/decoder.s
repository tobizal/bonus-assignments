.data

#ANSI color guide at https://talyian.github.io/ansicolors/
color:			.asciz	"\x1b[38;5;%ldm\x1b[48;5;%ldm"
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
	shrq	$32, %R8		# shift right by 4 bytes (now Byte 2 is last)

	movb	%R8B, fore_color	# copy LSB (Byte 2) to the foreground color code 
	shrq	$8, %R8			# shift right by 1 byte (now Byte 1 is last)

	movb	%R8B, back_color	# copy LSB to the background color code variable

	#check if special effects apply
	movq	$0, %RDX		# zero RDX
	movb	fore_color, %DL
	movb	back_color, %R8B
	cmp	%DL, %R8B
	je	special_effects

	#set foreground and background colors
	movq	$0, %rax		# set the background color with printf
	movq	$color, %rdi		# first arg: output string
	movzb	fore_color, %rsi	# second arg: foreground color code
	movzb	back_color, %rdx	# third arg: background color code
	call	printf
	jmp	print

	#special effects
special_effects:
	cmp	$0, %DL
	je	scase0

	cmp	$37, %DL
	je	scase37

	cmp	$42, %DL
	je	scase42

	cmp	$66, %DL
	je	scase66

	cmp	$105, %DL
	je	scase105

	cmp	$153, %DL
	je	scase153

	cmp	$182, %DL
	je	scase182

scase0:
	movq	$reset, %RDI
	jmp	apply_special_effects
scase37:
	movq	$stop_blinking, %RDI
	jmp	apply_special_effects
scase42:
	movq	$bold, %RDI
	jmp	apply_special_effects
scase66:
	movq	$faint, %RDI
	jmp	apply_special_effects
scase105:
	movq	$conceal, %RDI
	jmp	apply_special_effects
scase153:
	movq	$reveal, %RDI
	jmp	apply_special_effects
scase182:
	movq	$blink, %RDI
	jmp	apply_special_effects

apply_special_effects:
	movq	$0, %RAX
	call printf

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




