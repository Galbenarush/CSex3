.section    .rodata
# strings for printf
format_length:     .string "first pstring length: %d, second pstring length: %d\n"
format_replace:    .string "old char: %c, new char: %c, first string: %s, second string: %s\n"
format_copy:       .string "length: %d, string: %s\n"
format_swap:       .string "length: %d, string: %s\n "
format_compare:    .string "compare result: %d\n"
format_invalid:    .string "invalid option!\n"
format_c: .string " %c"
format_d: .string " %d"

# switch cases
    .align 8
.L10:                   # base address
    .quad c_50          # i = 50 or i = 60
    .quad c_invalid     # i = 51
    .quad c_52          # i = 52
    .quad c_53          # i = 53
    .quad c_54          # i = 54
    .quad c_55          # i = 55
    .quad c_invalid     # i = 56
    .quad c_invalid     # i = 57
    .quad c_invalid     # i = 58
    .quad c_invalid     # i = 59
    .quad c_50          # i = 60

.text                   # the code
.global run_func
.type run_func, @function
run_func:
    pushq   %rbp              
    movq    %rsp, %rbp
    pushq   %r12
    movq    %rsi, %r12
    pushq   %r13
    movq    %rdx, %r13
    leaq    -50(%rdi), %rcx  # Compute xi = x - 50
    cmpq    $10, %rcx 
    ja .L9 
    jmp *.L10(,%rcx,8)

run_func_finish:
    popq    %r13
    popq    %r12
    movq    %rbp, %rsp
    popq    %rbp
    ret

c_50:
    movq %r12, %rdi             # move rsi to rdi
    call pstrlen                # call to length function with rdi
    movb %al, %sil              # save length 1
    movq %r13, %rdi             # put argument 3 to rdi - argument 2
    # leaq (%rsp, 1, 8), %rdi       # (%rsp, 1, 8)
    push %rsi
    call pstrlen
    movq $format_length, %rdi   # argument 1 as format length
    movb %al, %dl               # argument 3 as length 2
    movq $0, %rax
    popq %rsi
    call printf
    jmp run_func_finish

c_52:
    movq    $format_c, %rdi 
    subq    $8, %rsp
    movq    %rsp, %rsi
    movq    $0, %rax
    call    scanf
    movq    $format_c, %rdi
    leaq    1(%rsp), %rsi
    movq    $0, %rax
    call    scanf
    movb    (%rsp), %sil
    movb    1(%rsp), %dl
    movq    %r12, %rdi
    call    replaceChar
    movb    (%rsp), %sil
    movb    1(%rsp),%dl
    movq    %r13, %rdi
    call    replaceChar
    pushq   %rax
    movq    $format_replace, %rdi
    movb    (%rsp), %sil
    movb    1(%rsp),%dl
    popq    %rcx
    movq    %rax, %r8
    movq    $0, %rax
    call    printf
    addq    $8, %rsp
    jmp     run_func_finish

c_53:
    # scan index i
    movq $format_d, %rdi
    subq $8, %rsp
    movq %rsp, %rsi
    movq $0, %rax
    call scanf
    # scan index j
    leaq 1(%rsp), %rsi
    movq $format_c, %rdi
    movq $0, %rax
    call scanf
    movq %r13, %rdi         # pstring 2 to rdi
    movq %r12, %rsi         # pstring 1 to rsi
    movb (%rsp), %dl        # index i to dl
    movb 1(%rsp), %cl       # index j to cl
    call pstrijcpy
    movq %rax, %rdi         # new pstring 2 to rdi
    pushq %rdi              # save pstring 2 in stack
    call pstrlen
    popq %rdi               
    movq %rdi, %rdx         # pstring 2 to rdx
    movq $format_copy, %rdi 
    movq %rax, %rsi
    movq $0, %rax
    call printf
    movq %r12, %rdi
    call pstrlen
    movq $format_copy, %rdi
    movq %rax, %rsi
    movq %r12, %rdx
    movq $0, %rax
    call printf
    addq $8, %rsp
    jmp run_func_finish

c_54:
    movq %r12, %rdi         # pointer to pstring 1
    call swapCase
    pushq %rax
    movq %rax, %rdi
    call pstrlen
    # movq %rax, %rsi         # argument 2 to printf as rsi
    movq $format_swap, %rdi # argument 1 to printf as rdi
    movq %rax, %rsi
    popq %rdx
    movq $0, %rax
    call printf
    movq %r13, %rdi          # argument 1 to swap - pointer to pstring 2
    call swapCase
    pushq %rax
    call pstrlen
    movq %rax, %rsi         # argument 2 to printf as rsi
    movq $format_swap, %rdi # argument 1 to printf as rdi
    movq $0, %rax
    popq %rdx
    call printf
    jmp run_func_finish

c_55:
    # scan index i
    movq $format_d, %rdi
    subq $8, %rsp
    movq %rsp, %rsi
    movq $0, %rax
    call scanf
    # scan index j
    leaq 1(%rsp), %rsi
    movq $format_c, %rdi
    movq $0, %rax
    call scanf
    movq %r12, %rdi         # pstring 1 to rdi
    movq %r13, %rsi         # pstring 2 to rsi
    movb (%rsp), %dl        # index i to dl
    movb 1(%rsp), %cl       # index j to cl
    call pstrijcmp
    movq $format_compare, %rdi
    movq %rax, %rsi
    movq $0, %rax
    call printf
    addq $8, %rax
    jmp run_func_finish

c_invalid:
    movq $format_invalid, %rdi
    movq $0, %rax
    call printf




