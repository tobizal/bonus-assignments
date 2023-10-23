.data
output:		.asciz	"Hello World!"
uint_str:	.quad 0x0
		.quad 0x0
int_str:	.quad 0x0
		.quad 0x0

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
	ret

# print_str subroutine - print a string using syscalls
# @param RDI - address of the first character
# @param RSI - length of the string in characters
print_str:
	# prologue
	pushq	%rbp			# preserve the caller's base pointer
	movq	%rsp, %rbp		# update the base pointer for this stack frame

	pushq	%rdi
	pushq	%rsi
	
	movq	$1, %rax		# syscall code for write
	movq	$1, %rdi		# file desriptor to write to (stdout)
	popq	%rdx			# store the length of the string in rdx
	popq	%rsi			# store the address of the first character

	syscall

	# epilogue
	movq	%rbp, %rsp		# clear the stack varialbes
	popq	%rbp			# restore the caller's base pointer
	ret

# uint_to_str subroutine - convert an unsigned int to string
# @param RDI - 64-bit unsigned int
# @return - updated $uint_str
uint_to_str:
	# prologue
	pushq	%rbp			# preserve the caller's base pointer
	movq	%rsp, %rbp		# update the base pointer for this stack frame

	pushq	%rdi			# store the number on the stack
	movq	$uint_str, %rdi		# store the addres of the next free digit in rdi

	# check if the number is 0
	movq	(%rsp), %rax
	cmpq	$0, %rax
	je	uint_end_0		# jump to code that puts 0 in the uint_str and returns

	movq	$100000000000, %rcx
	movq	$1, %r8			# flag: if zero, write zeros to uint_string
	movq	$12, %r11		# counter in r11 - 64 iterations
uint_loop:
	cmpq	$0, %r11		# check if the counter is 0
	je	uint_end		# end the routine

	movq	$0, %rdx		# zero RDX
	movq	(%rsp), %rax		# move the number to RAX
	div	%rcx			# divide by rcx	
	movq	%rax, %r10		# store the result in r10	

	movq	%r10, %rax		# store the resulting digit in rax
	mul	%rcx			# multiply by rcx
	subq	%rax, (%rsp)		# subtract from the number
	
	popq	%rax			# pop the number to rax
	movq	$10, %r9		# store ten in R9
	mul	%r9			# multiply by 10
	dec 	%r11			# decrement counter
	pushq	%rax			# store back on the stack
	
	cmpq	$0, %r8			# check the write flag
	jz	uint_write		# jmp to write code

	cmpq	$0, %r10		# check if current digits is 0
	jz	uint_loop		# continue the loop if zero

uint_write:
	movq	$0, %r8			# set write flag - from now on always write 0s
	addq	$48, %r10		# store the digit in ASCII in uint_str	
	movq	%r10, %rax		# move the digit to rax
	stosb				
	jmp	uint_loop		# jumo ti the next iteration
	
uint_end_0:
	addq	$48, %rax		# convert the decimal 0 to ascii 0 
	stosb				# store zero in the first digit of uint_str
uint_end:
	# epilogue
	movq	%rbp, %rsp		# clear the stack varialbes
	popq	%rbp			# restore the caller's base pointer
	ret

# int_to_str subroutine - convert a signed int to string
# @param RDI - 64-bit signed int
# @return - updated $int_str
int_to_str:
	# prologue
	pushq	%rbp			# preserve the caller's base pointer
	movq	%rsp, %rbp		# update the base pointer for this stack frame

	# code goes here ...

	# epilogue
	movq	%rbp, %rsp		# clear the stack varialbes
	popq	%rbp			# restore the caller's base pointer
	ret

main:
	# prologue
	pushq	%rbp			# preserve the caller's base pointer
	movq	%rsp, %rbp		# update the base pointer for this stack frame

	# test of print_str
	movq	$output, %rdi		# param1 - address of the first character
	movq	$12, %rsi		# param2 - length of the string
	call 	print_str		

	# test of uint_to_str
	movq 	$12349895, %rdi
	call	uint_to_str

	movq	$uint_str, %rdi
	movq	$0, %rax
	call	printf
	# epilogue
	movq	%rbp, %rsp		# clear the stack varialbes
	popq	%rbp			# restore the caller's base pointer
end:
	movq	$0, %rdi
	call	exit


