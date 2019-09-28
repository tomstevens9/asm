.equ SYS_WRITE, 1
.equ STD_OUT, 1
.equ SYS_EXIT, 60
.equ ASCII_OFFSET, 48
.equ FPU_CW_MASK, 0b11110000

.section .data
    FORMAT_STRING: .ascii "%d\0"
    NEWLINE: .ascii "\n\0"
    FPU_CW_OLD: .word 0
    FPU_CW_NEW: .word 0x0400
    RESULT: .double 0

.section .bss
    .lcomm CONVERT_BUFFER 20
    .lcomm TEMP_CONVERT_BUFFER 20

.section .text

.globl _start
_start:
    # ---------- START FPU SETUP ----------
    # change FPU round mode and precision
    # The round mode should be set to round down
    # bits 8/9 represent the precision. 00 is single precision
    # bits 10/11 represent the rounding mode. 01 is round down
    fstcw FPU_CW_OLD        # pull out the current control word
    mov FPU_CW_OLD, %ax     # move the control word into a register
    andb $FPU_CW_MASK, %ah  # mask the control word to zero out bits 8-11
    orw %ax, FPU_CW_NEW     # xor control word with FPU_CW_NEW to set 
                            # bits 10/11 to 01. FPU_CW_NEW already has 
                            # the correct bits set for bits 8/9
                            # Nothing needs to be done for bits 8/9 as the
                            # masking process already set them to 00
    fldcw FPU_CW_NEW
    # ---------- END FPU SETUP ----------

    mov 16(%rsp), %rdi      # move pointer to first command
                            # line argument to rdi
    call str_to_int         # call atoi to convert command
                            # line argument to int
    mov %rax, %r12          # r12 is how many primes we want to count
    xor %r13, %r13          # r13 is how many prime numbers that have been found
    xor %r15, %r15          # r15 is the current number being checked

    start_loop:
    inc %r15

    mov %r15, %rdi
    call is_prime           # call is_prime 

    cmp $0, %rax            # restart loop if not prime
    je start_loop
    
    inc %r13                # have we found enough primes?
    cmp %r13, %r12         
    jne start_loop

    mov %r15, %rdi
    call print_integer
    
    # exit successfully
    xor %rdi, %rdi          
    mov $SYS_EXIT, %rax
    syscall

#   %rdi - string of an integer
.type str_to_int,@function
str_to_int:
    call count_characters
    mov %rax, %r13          # move number of characters in string to %r13
                            # %r13 acts as a string index
    mov $1, %rcx            # %rcx is multiplication factor. Multiplied
                            # by 10 for each iteration of the loop
    xor %r12, %r12            # %r12 is our running total
    my_loop_start:
    xor %rdx, %rdx            # clear rdx
    dec %r13                # start by deincrementing index as first index
                            # is one less than the string length
    movb (%rdi, %r13, 1), %dl
    sub $ASCII_OFFSET, %rdx 
    mov %rcx, %rax
    mul %rdx
    mov %rax, %rdx
    add %rdx, %r12
    mov $10, %rax
    mul %rcx
    mov %rax, %rcx
    cmp $0, %r13
    jne my_loop_start
    mov %r12, %rax
    ret

# Convert an integer to it's base 10 ASCII representation
# rdi - number to be converted
.type int_to_str,@function
int_to_str:
    # convert input to reverse string
    push %rbx
    push %r12 
    push %r13
    push %r14

    mov %rdi, %r12
    mov $10, %rbx           # move 10 into rcx to be used as dividor
    xor %rcx, %rcx

    its_loop_start:
    cmp $0, %r12
    je its_end_loop
    xor %rdx, %rdx          # clear rdx
    mov %r12, %rax          # move running value into rax
    div %rbx                # divide by 10

    mov %rax, %r12          # move the result into r12

    add $ASCII_OFFSET, %rdx # convert the remainder to ascii and add to buffer
    movb %dl, TEMP_CONVERT_BUFFER(%rcx, 1)

    inc %rcx
    jmp its_loop_start
    its_end_loop:

    dec %rcx
    xor %r13, %r13

    reverse_loop_start:
    cmp $0, %rcx 
    jl reverse_loop_end
    xor %r14, %r14
    movb TEMP_CONVERT_BUFFER(%rcx, 1), %r14b
    movb %r14b, CONVERT_BUFFER(%r13, 1)
    dec %rcx
    inc %r13
    jmp reverse_loop_start
    reverse_loop_end:

    movb $0, CONVERT_BUFFER(%r13, 1)

    pop %r14
    pop %r13
    pop %r12
    pop %rbx
    ret


#   %rdi - Number tested, Integer
.type print_integer,@function
print_integer:
    # convert number to ascii representation
    call int_to_str
    
    mov $CONVERT_BUFFER, %rdi
    call count_characters   # count number length for write
                            # syscall
    mov %rax, %rdx          # make write syscall to write
    mov $SYS_WRITE, %rax    # number to STDOUT
    mov $STD_OUT, %rdi
    mov $CONVERT_BUFFER, %rsi
    syscall

    end:
    mov $NEWLINE, %rsi      # print a newline
    mov $1, %rdx
    mov $SYS_WRITE, %rax
    mov $STD_OUT, %rdi
    syscall

    ret

.type count_characters,@function
count_characters:
    mov $-1, %rax    
    loop_start: 
    inc %rax
    mov (%rax, %rdi, 1), %cl
    cmpb $0, %cl
    jne loop_start
    ret

.type is_prime,@function
is_prime:
    # put argument on the stack
    sub $8, %rsp
    mov %rdi, (%rsp)

    cmp $2, %rdi 
    jl ret_false
    je ret_true

    mov %rdi, %r10

    # calculate the square root of argument and round down 
    fildq (%rsp)
    fsqrt
    fistp RESULT
    mov RESULT, %r11

    mov $2, %rcx
    prime_loop:
    cmp %r11, %rcx
    jg end_func
    xor %rdx, %rdx
    mov %r10, %rax
    div %rcx
    cmp $0, %rdx
    je ret_false
    inc %rcx
    jmp prime_loop

    ret_true:
    mov $1, %rax
    jmp end_func
    
    ret_false:
    xor %rax, %rax

    end_func:
    add $8, %rsp
    ret
