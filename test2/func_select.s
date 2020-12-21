.section    .rodata
# strings for printf
format_50:     .string "first pstring length: %d, second pstring length: %d\n"
format_52:    .string "old char: %c, new char: %c, first string: %s, second string: %s\n"
format_53:       .string "length: %d, string: %s\n"
format_54:       .string "length: %d, string: %s\n"
format_55:    .string "compare result: %d\n"
format_invalid:    .string "invalid option!\n"
format_c:          .string " %c %c"
format_d:          .string " %hhu"

# switch cases
    .align 8
.L10:                    # base address
    .quad c_50           # i = 50 or i = 60
    .quad .c_invalid     # i = 51
    .quad c_52           # i = 52
    .quad c_53           # i = 53
    .quad c_54           # i = 54
    .quad c_55           # i = 55
    .quad .c_invalid     # i = 56
    .quad .c_invalid     # i = 57
    .quad .c_invalid     # i = 58
    .quad .c_invalid     # i = 59
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
    leaq    -50(%rdi), %rcx                     # Compute xi = x - 50
    cmpq    $10, %rcx 
    ja      .c_invalid 
    jmp *.L10(,%rcx,8)

run_func_finish:
    popq    %r13
    popq    %r12
    movq    %rbp, %rsp
    popq    %rbp
    ret

c_50:
    movq    %r12, %rdi                 # move pstring1 to rdi
    call    pstrlen                    # call to length function with rdi
    movq    %rax, %rsi                 # save length 1
    movq    %r13, %rdi                 # move pstring1 to rdi
    push    %rsi
    call    pstrlen
    movq    $format_50, %rdi       # argument 1 as format length
    movq    %rax, %rdx                 # argument 3 as length 2
    movq    $0, %rax
    popq    %rsi                       # argument 2 as length 1
    call    printf
    jmp     run_func_finish

c_52:
    # scan old char
    movq    $format_c, %rdi             # string format as argument 1      
    subq    $16, %rsp                   
    leaq    (%rsp), %rsi
    leaq    1(%rsp), %rdx
    movq    $0, %rax
    call    scanf
    movb    (%rsp), %sil                # old char as argument 2 
    movb    1(%rsp), %dl                # new char as argument 3
    movq    %r12, %rdi                  # pstring 1 as argument 1
    call    replaceChar
    movb    (%rsp), %sil                # old char as argument 2
    movb    1(%rsp),%dl                 # new char as argument 3
    movq    %r13, %rdi                  # pstring2 as argument 1
    call    replaceChar
    movq    $format_52, %rdi       # format as atgument 1
    movb    (%rsp), %sil                # old char as argument 2
    movb    1(%rsp),%dl                 # new char as argument 3
    leaq    1(%r12), %rcx               # pstring 1 as argument 4
    leaq    1(%r13), %r8                # pstring 2 as argument 5
    movq    $0, %rax
    call    printf
    addq    $16, %rsp
    jmp     run_func_finish

c_53:
    # scan index i
    movq $format_d, %rdi
    subq $16, %rsp
    leaq (%rsp), %rsi
    movq $0, %rax
    call scanf
    
    # scan index j
    movq $format_d, %rdi
    leaq 1(%rsp), %rsi
    movq $0, %rax
    call scanf
    
    # send arguments to pstrijcpy
    movq %r12, %rdi         # pstring 2 to rdi
    movq %r13, %rsi         # pstring 1 to rsi
    movzbq (%rsp), %rdx        # index i to dl
    movzbq 1(%rsp), %rcx       # index j to cl
    call pstrijcpy
    
    # print pstring 2
    movq %r12, %rdi         # find length of pstring 1
    call pstrlen
    movq %rax, %rsi         
    inc  %r12
    movq %r12, %rdx         # new pstring 2 to rdx
    movq $format_53, %rdi 
    movq $0, %rax
    call printf
    # print pstring 1
    movq %r13, %rdi
    call pstrlen
    movq $format_53, %rdi
    movq %rax, %rsi
    leaq 1(%r13), %rdx
    movq $0, %rax
    call printf
    addq $16, %rsp
    jmp run_func_finish

c_54:
    movq %r12, %rdi         # pointer to pstring 1
    call swapCase
    movq %r12, %rdi
    call pstrlen
    movq $format_54, %rdi # argument 1 to printf as rdi
    movq %rax, %rsi
    addq $1, %r12
    movq %r12, %rdx
    movq $0, %rax
    call printf
    movq %r13, %rdi          # argument 1 to swap - pointer to pstring 2
    call swapCase
    movq %r13, %rdi
    call pstrlen
    movq %rax, %rsi         # argument 2 to printf as rsi
    movq $format_54, %rdi # argument 1 to printf as rdi
    addq $1, %r13
    movq %r13, %rdx
    movq $0, %rax
    call printf
    jmp run_func_finish

c_55:
    # scan index i
    movq    $format_d, %rdi
    subq    $16, %rsp
    leaq    (%rsp), %rsi
    movq    $0, %rax
    call    scanf
    
    # scan index j
    movq    $format_d, %rdi
    leaq    1(%rsp), %rsi
    movq    $0, %rax
    call    scanf

    movq    %r12, %rdi         # pstring 1 to rdi
    movq    %r13, %rsi         # pstring 2 to rsi
    movzbq  (%rsp), %rdx        # index i to dl
    movzbq  1(%rsp), %rcx       # index j to cl
    call    pstrijcmp
    movq    $format_55, %rdi
    movq    %rax, %rsi
    movq    $0, %rax
    call    printf
    addq    $16, %rax
    jmp     run_func_finish

.c_invalid:
    movq $format_invalid, %rdi
    movq $0, %rax
    call printf
    jmp run_func_finish





