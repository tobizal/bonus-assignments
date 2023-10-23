.data

a: .long 0x0
b: .long 0x0
c: .long 0x0
d: .long 0x0
e: .long 0x0
f: .long 0x0
k: .long 0x0

h_base: .quad 0x0

w_base: .quad 0x0

.text


.global sha1_chunk
.global end_chunk

# rsi address of H0
# rdi address of w[0]

sha1_chunk:
	#prologue
	pushq	%rbp		# store the caller's pointer on the stack
	movq	%rsp, %rbp	# update the base pointer fot his stack frame
	pushq	%r12
	#move parameters into vars (make it more readable)
	movq    %rsi, w_base
    	movq    %rdi, h_base

    # extension for loop
    movq    $16, %rcx   #rcx is the loop counter
    extension_forloop:
        movq    w_base, %rax
        leaq    (%rax, %rcx, 4), %rax    # address of w[i] in %rax
        movl    -12(%rax), %r8d		# w[i-3]
        movl    -32(%rax), %r9d		# w[i-8]
        movl    -56(%rax), %r10d	# w[i-14]
        movl    -64(%rax), %r11d	# w[i-16]
        xorl    %r8d, %r9d
        xorl    %r9d, %r10d
        xorl    %r10d, %r11d
        roll    $1, %r11d
        movl    %r11d, (%rax)
        incq    %rcx
        cmp     $80, %rcx
        jne     extension_forloop


    #Load movsq operands
    movq    $a, %rdi
    movq    h_base, %rsi  
    movsl   #load h0 through h4 to a...e
    movsl  
    movsl  
    movsl  
    movsl  
    
    movl    a, %r8d
    movl    b, %r9d
    movl    c, %r10d
    movl    d, %r11d
    movl    e, %r12d

    movq    $0, %rcx   # rcx is counter
    for_loop:
	cmpq	$19, %rcx
	jle	case0_19

	cmpq	$39, %rcx
	jle	case20_39

	cmpq	$59, %rcx
	jle	case40_59

	cmpq	$79, %rcx
	jle	case60_79

    # for i between 0 and 19
    case0_19:
    andl    %r9d, %r10d			# (b and c) -> c
    notl    %r9d			# (not b) -> b
    andl    %r9d, %r11d			# ((not b) and d) -> d
    orl     %r10d, %r11d		# (b and c) and ((not b) and d) -> d
    movl    %r11d, f			# ->f
    movl    $0x5A827999, k
    jmp     for_loop_next

    # for i between 20 and 39
    case20_39:
    xorl    %r9d, %r10d			# (b xor c) -> c
    xorl    %r10d, %r11d		# ((b xor c) xor d) -> d
    movl    %r11d, f			# -> f
    movl    $0x6ED9EBA1, k
    jmp     for_loop_next

    # for i between 40 and 59
    case40_59:
    pushq   %r10			# push c
    pushq   %r11			# push d
    andl    %r9d, %r10d			# (b and c) -> c
    andl    %r9d, %r11d			# (b and d) -> d
    popq    %rdx    #popping d		original d -> edx
    popq    %rdi    #popping c		original c -> edi
    andl    %edi, %edx #rdx has c & d	(c and d) -> edx
    orl     %r10d, %r11d		# (b and c) or (b and d) -> d
    orl     %r11d, %edx			# (b and c) or (b and d) or (c and d) -> edx
    movl    %edx, f			# ->f
    movl    $0x8F1BBCDC, k
    jmp     for_loop_next


    # for i between 60 and 79
    case60_79:
    xorl    %r9d, %r10d			# (b xor c) -> c
    xorl    %r10d, %r11d		# ((b xor c) xor d) -> d
    movl    %r11d, f			# ->f
    movl    $0xCA62C1D6, k

    for_loop_next:
    roll    $5, %r8d
    addl    f, %r8d
    addl    e, %r8d
    addl    k, %r8d
        movq    w_base, %rax
        leaq    (%rax, %rcx, 4), %rax    # address of w[i] in %rax
    addl    (%rax), %r8d   #(%rax) is w[i]
    movl    %r8d, %eax #temp in %rax
	
    roll    $30, %r9d
	movl 	%r11d, e
	movl 	%r10d, d
	movl	%r9d, c
	movl	%r8d, b
	movl	%eax, a

    incq    %rcx
    cmp     $80, %rcx
    jne     for_loop

    movl    a, %r8d
    movl    b, %r9d
    movl    c, %r10d
    movl    d, %r11d
    movl    e, %r12d

    movq    h_base, %rdx
    addl    %r8d, (%rdx)
    addl    %r9d, 4(%rdx)
    addl    %r10d, 8(%rdx)
    addl    %r11d, 12(%rdx)
    addl    %r12d, 16(%rdx)

    end_chunk:
#epilogue
	popq	%r12
	movq	%rbp, %rsp		# clear the stack variables
	popq	%rbp			# restore the caller's poitner
	ret
