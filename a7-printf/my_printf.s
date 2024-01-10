.data

argument_1:    .quad 0x0
argument_2:    .quad 0x0
argument_3:    .quad 0x0
argument_4:    .quad 0x0
argument_5:    .quad 0x0

minus:        .byte '-'
.data
output:        .asciz    "Hello World! %%\n"
output1:    .asciz    "My name is %s. I am %u years old. My favourite number is %d. This is a %% sign.\n"
output2:    .asciz     "%s%s%s%s%s%s%s%s."
output3:    .asciz    "'The quick brown fox quickly jumps over the lazy dog %u%r!'"
output4:    .asciz    "%s"
output5:    .asciz    "My name is %s. I think I'll get a %u for my exam. What does %r do? And %%?\n"
piet:        .asciz    "Piet"
signed:        .asciz    "%d\n"
unsigned:    .asciz    "%u\n"

name:        .asciz    "Tobiasz"


.text
.global main
.global my_printf


# my_printf subroutine
# @param RDI - format string
# @param RSI - argument 1
# @param RDX - argument 2
# @param RCX - argument 3
# @param R8 - argument 4
# @param R9 - argument 5
# @param STACK - next arguments
my_printf:
    # prologue
    pushq    %rbp            # preserve the caller's base pointer
    movq    %rsp, %rbp        # update the base pointer for this stack frame
    
    # load the arguments
    movq    %rsi, argument_1
    movq    %rdx, argument_2
    movq    %rcx, argument_3
    movq    %r8, argument_4
    movq    %r9, argument_5

    # code goes here ...
    # @variable %RCX - counter of the number of the variable
    movq    $0, %rcx
    loop:
    movb    (%rdi), %al    # character in the string in RAX
    cmpb    $0, %al     # check if character is 0
    je    my_printf_end    # if zero, its the end of the string so end
        
    cmpb    $'%', %al    # check if its a %
    je    percent_sign_found    #jump to corresponding code
    
    push    %rdi
    pushq    %rcx
    call    print_char    # just print the character if none of the above
    popq    %rcx
    popq    %rdi
    jmp    loop_next
    
    percent_sign_found:
    incq    %rdi        # increment the character pointer
    cmpb    $'%', (%rdi)    # check if the next character is % as well
    jne    arg_found    # if not a percentage sign, print the argument
    
    #else
    pushq    %rdi
    pushq    %rcx
    call    print_char    # otherwise, just print the character
    popq    %rcx
    popq    %rdi
    jmp    loop_next

    arg_found:
    jmp    load_arg    # the argument is in %rax now
    load_arg_back:
    cmpb    $'u', (%rdi)    # check arg type
    je    uint_arg

    cmpb    $'d', (%rdi)
    je    int_arg

    cmpb    $'s', (%rdi)
    je    str_arg

    #else just print the % and the following characters
    decq    %rcx        # compensate for load_arg increment of rcx
    decq    %rdi        # move back to '%' character
    pushq    %rdi
    pushq    %rcx
    call    print_char
    popq    %rcx
    popq    %rdi
    jmp    loop_next

    
    uint_arg:
    pushq    %rdi
    pushq    %rcx
    movq    %rax, %rdi    # move the argument from rax to rdi
    call    uint_to_str    # convert the number to string and put in uint_str variable
    popq    %rcx
    popq    %rdi
    jmp    loop_next
    int_arg:
    pushq    %rdi
    pushq    %rcx
    movq    %rax, %rdi    # move the argument from rax to rdi
    call    int_to_str    # convert the in argument to stringand put to print_str variable
    popq    %rcx
    popq    %rdi
    jmp    loop_next
    str_arg:
    pushq    %rdi
    pushq    %rcx
    movq    %rax, %rdi    # move the provided string to rdi
    call    print_str    # print the string
    popq    %rcx
    popq    %rdi
    
    loop_next:
    incq    %rdi        # increment the character pointer
    jmp    loop        # proceed to the next iteration
            
my_printf_end:
    # epilogue
    movq    %rbp, %rsp        # clear the stack varialbes
    popq    %rbp            # restore the caller's base pointer
    ret


#load_arg
# @return %RAX - the value of the current argument taken from the register parameters
load_arg:
    cmpq    $4, %rcx    # check the rcx arg counter
    jle    arg_vars    # get the arguments from argument variables (registers)

    #else, get the from the stack
    movq    %rcx, %rax    # copy the counter value to rax
    subq    $3, %rax    # correct rax to properly index the stack variable
    movq    (%rbp, %rax, 8), %rax
    jmp    load_arg_end
    
    arg_vars:
    movq    %rcx, %rax    # copy the counter value to rax
    movq    $argument_1, %rax
    movq    (%rax, %rcx, 8), %rax
    
    load_arg_end:
    incq    %rcx        # increment the arg counter
    jmp    load_arg_back
# print_char subroutine
# @param RDI - address of the character
print_char:
    # prologue
    pushq    %rbp            # preserve the caller's base pointer
    movq    %rsp, %rbp        # update the base pointer for this stack frame
    
    movq    %rdi, %rsi        # address of the character
    movq    $1, %rax        # syscall code for write
    movq    $1, %rdi        # file descriptor to write - stdout
    movq    $1, %rdx        # string length - 1 character
    syscall
        
    # epilogue
    movq    %rbp, %rsp        # clear the stack varialbes
    popq    %rbp            # restore the caller's base pointer
    ret
# print_str subroutine - print a string using syscalls
# @param RDI - address of the first character
print_str:
    # prologue
    pushq    %rbp            # preserve the caller's base pointer
    movq    %rsp, %rbp        # update the base pointer for this stack frame
    
    movq    %rdi, %rdx        # copy the first address to rdx
    decq    %rdx            # compensate for the first increment in the loop
    # first find the length of the string
    print_str_loop:
        incq    %rdx        # move to the next character
        movzb    (%rdx), %rax    # move the character from the string to %rax
        cmpq    $0, %rax    # check if its null character
        jnz    print_str_loop    # continue to look for null character
    #else
    subq    %rdi, %rdx        # last_addr - first_addr = length

    movq    %rdi, %rsi        # address of the first addres in rsi for write
    movq    $1, %rax        # syscall code for write
    movq    $1, %rdi        # file desriptor to write to (stdout)
    syscall

    # epilogue
    movq    %rbp, %rsp        # clear the stack varialbes
    popq    %rbp            # restore the caller's base pointer
    ret

# uint_to_str subroutine - convert an unsigned int to string
# @param RDI - 64-bit unsigned int
# @return - updated $uint_str
uint_to_str:
    # prologue
    pushq    %rbp            # preserve the caller's base pointer
    movq    %rsp, %rbp        # update the base pointer for this stack frame
    pushq    %rbx

    movq    $0, %rbx
    
loop_uint:
    movq    $0, %rdx
    movq    %rdi, %rax        # number to rax
    movq    $10, %r8
    div    %r8            # divide the number by 10
    movq    %rax, %rdi        # move the number/10 back to %rdi
    addq    $48, %rdx
    pushq    %rdx
    pushq    %rdx            # push the remainder
    incq    %rbx
    cmpq    $0, %rdi
    jne    loop_uint

loop_uint_print:
    movq    $1, %rdi
    movq    $1, %rax
    movq    $1, %rdx

    movq    %rsp, %rsi
    syscall
    popq    %r9
    popq    %r9
    decq    %rbx
    cmpq    $0, %rbx
    jne    loop_uint_print
    
    uint_end:
    # epilogue
    popq    %rbx
    movq    %rbp, %rsp        # clear the stack varialbes
    popq    %rbp            # restore the caller's base pointer
    ret

# int_to_str subroutine - convert a signed int to string
# @param RDI - 64-bit signed int
# @return - updated $int_str
int_to_str:
    # prologue
    pushq    %rbp            # preserve the caller's base pointer
    movq    %rsp, %rbp        # update the base pointer for this stack frame


    movq    $0x8000000000000000, %rax    #mask to get the MSB
    andq    %rdi, %rax        # if the number is positive, rax is zero now
    cmpq    $0, %rax
    je    positive
negative:
    neg    %rdi            # flip sign
    pushq    %rdi
    pushq    %rdi
    movq    $minus, %rdi
    call    print_char
    popq    %rdi
    popq    %rdi
    call    uint_to_str        # convert as if positive
    jmp    int_to_str_end
positive:
    call    uint_to_str        # convert normally
int_to_str_end:
    # epilogue
    movq    %rbp, %rsp        # clear the stack varialbes
    popq    %rbp            # restore the caller's base pointer
    ret

main:
    # prologue
    pushq    %rbp            # preserve the caller's base pointer
    movq    %rsp, %rbp        # update the base pointer for this stack frame

    movq    $943021, %rdi
    call    int_to_str

    movq    $output1, %rdi
    movq    $name, %rsi
    movq    $20, %rdx
    movq    $-42, %rcx
    call    my_printf
end:
    # epilogue
    movq    %rbp, %rsp        # clear the stack varialbes
    popq    %rbp            # restore the caller's base pointer
    movq    $0, %rdi
    movq    $60, %rax
    syscall

