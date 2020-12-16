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
.L10:          # base address
    .quad .L4 # i = 50 or i = 60
    .quad .L9 # i = 51
    .quad .L5 # i = 52
    .quad .L6 # i = 53
    .quad .L7 # i = 54
    .quad .L8 # i = 55
    .quad .L9 # i = 56
    .quad .L9 # i = 57
    .quad .L9 # i = 58
    .quad .L9 # i = 59
    .quad .L4 # i = 60

.text # the code
.global run_func
.type run_func, @function
run_func:
    leaq -50(%rdi), %rcx # compute xi = x -50
    cmpq $10, %rcx       # compare xi: 10
    ja .L9               # if >, go to default case
    jmp *.L10(,%rcx, 8)  #goto jt[xi]

    .L4:
        movq %rsi, %rdi           # move rsi to rdi
        call pstrlen              # call to length function with rdi
        movq %rax, %r8            # save length 1
        movq %rdx, %rdi           # put argument 3 to rdi - argument 2
        call pstrlen
        movq $format_length, %rdi # argument 1 as format length
        movq %r8, %rsi            # argument 2 as length 1
        movq %rax, %rdx           # argument 3 as length 2
        movq $0, %rax
        call printf

    .L5:
        movq $format_c, %rdi
        subq $8, %rsp
        movq %rsi, %r8
        movq %rsp, %rsi
        movq $0, %rax
        call scanf
        movq (%rsi), %r9 # oldChar
        movq $0, %rax
        call scanf
        movq (%rsi), %rcx # newChar
        addq $8, %rsp     # rsp points to rbp
        movq %r8, %rdi
        movq %r9, %rsi    # oldChar
        movq %rdx, %r8    # save pstring 2 at r8
        movq %rcx, %rdx   # newChar
        call replaceChar
        movq %rax, %r9    # new pstring 1
        movq %r8, %rdi
        call replaceChar
        movq %rax, %r8    # new pstring 2
        # printf - 5 arguments (string, oldChar, newChar, new string 1, new string 2)
        movq $format_replace, %rdi
        movq %r9, %rcx
        movq $0, %rax
        call printf

    .L6:
        movq $format_d, %rdi
        subq $8, %rsp
        movq %rsi, %r9   # pstring 1
        movq %rsp, %rsi
        movq $0, %rax
        call scanf
        movq (%rsi), %r8 # index i
        movq $0, %rax
        call scanf
        movq (%rsi), %rcx # argument 3 to cpy - index j
        addq $8, %rsp
        movq %rdx, %rdi   # argument 1 to cpy - pstring 2
        movq %r9, %rsi    # argument 2 to cpy - pstring 1
        movq %r8, %rdx    # argument 3 to cpy - index i
        call pstrijcpy
        movq %rax, %rdi
        call pstrlen
        # printf destination- length and string
        movq %rdi, %rdx
        movq $format_copy, %rdi
        movq %rax, %rsi
        movq $0, %rax
        call printf
        # printf destination- length and string
        movq %r9, %rdi
        call pstrlen
        movq $format_copy, %rdi
        movq %rax, %rsi
        movq %r9, %rdx
        movq $0, %rax
        call printf

    .L7:
        movq %rsi, %rdi         # pointer to pstring 1
        call swapCase
        movq %rdx, %r8          # pointer to pstring 2 in r8
        movq %rax, %rdx         # argument 3 to printf as rdx
        call pstrlen
        movq %rax, %rsi         # argument 2 to printf as rsi
        movq $format_swap, %rdi # argument 1 to printf as rdi
        movq $0, %rax
        call printf
        movq %r8, %rdi          # argument 1 to swap - pointer to pstring 2
        call swapCase
        movq %rax, %rdx
        call pstrlen
        movq %rax, %rsi         # argument 2 to printf as rsi
        movq $format_swap, %rdi # argument 1 to printf as rdi
        movq $0, %rax
        call printf

    .L8:
        pushq %rdi          # caller saver backup
        pushq %rsi          # caller saver backup
        pushq %rdx          # caller saver backup
        pushq %rcx          # caller saver backup
        # scan index i
        subq $8, %rsp
        movq %rsp, %rsi
        movq $format_d, %rdi
        movq $0, %rax
        call scanf
        pushq %r12         
        movl (%rsp), %r12d  # save index i
        # scan index j
        movq $0, %rax
        call scanf
        pushq %r13
        movl (%rsp), %r13d  # save index j
        leaq (%rsp, 6, 8), %rdi
        leaq (%rsp, 5, 8), %rsi
        movq %r12, %rdx
        movq %r13, %rcx
        call pstrijcmp
        movq $format_compare, %rdi
        movq %rax, %rsi
        call printf

        popq %r13
        popq %r12
        popq %rcx
        popq %rdx
        popq %rsi
        popq %rdi

    .L9:
        movq $format_invalid, %rdi
        call printf




