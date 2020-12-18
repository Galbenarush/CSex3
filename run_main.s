.section        .rodata
format_c:       .string " %c"
format_d:       .string " %d"
format_end:     .string "\0"

.text                                       # the beggining of the code
.global run_main
.type run_main, @function
run_main:
        # scan pstring 1
        pushq   %r12                        # r12 backup
        pushq   %r13                        # r13 backup
        movq    %rsp, %rbp
        movq    $format_d, %rdi             # %d as first argument 
        subq    $8, %rsp                    # stack allocation
        movq    %rsp, %rsi              
        movq    $0, %rax                
        call    scanf                       # scan length of pstring1
        addq    $2, (%rsi)                  # add 1 to the allocation length
        leaq    (%rsi, %rsi, 8), %rsp    # string allocation length
        subq    $2, (%rsi)                  # back to pstring 1 length    
        push    (%rsi)                      # push length
        addq    $8, %rsp
        movq    %rsp, %rsi              
        movq    $format_c, %rdi             # format of string as first argument
        movq    $0, %rax
        call    scanf                       # scan string of pstring1                      
        movq    $format_end, %rsi           # add /0 as end of string
        subq    $8, %rsp
        movq    %rsp, %r12                  # save pointer to pstring 1
        # scan pstring 2
        movq    $format_d, %rdi             # %d as first argument 
        subq    $16, %rsp                   # stack allocation + 8 bytes from pstring1-length
        movq    %rsp, %rsi              
        movq    $0, %rax                
        call    scanf                       # scan length of pstring2
        addq    $2, (%rsi)                  # add 2 to the allocation length
        leaq    (%rsi, %rsi, 8), %rsp    # string allocation length
        subq    $2, (%rsi)                  # back to pstring 2 length    
        push    (%rsi)                      # push length
        addq    $8, %rsp
        movq    %rsp, %rsi              
        movq    $format_c, %rdi             # format of string as first argument
        movq    $0, %rax
        call    scanf                       # scan string of pstring2                      
        movq    $format_end, %rsi           # add /0 as end of string                      
        subq    $8, %rsp
        movq    %rsp, %r13                  # save pointer to pstring 1
        # scan the option
        movq    $format_d, %rdi             
        subq    $16, %rsp
        movq    %rsp, %rsi
        movq    $0, %rax
        call    scanf
        # switch case
        movq    (%rsp), %rdx                # option as argument 3
        movq    %r12, %rdi                  # *pstring1 as argument 1
        movq    %r13, %rsi                  # *pstring2 as argument 2
        call    run_func
        movq    (%rbp), %r13                # r13 backup
        addq    $8, %rbp
        movq    (%rbp), %r12                # r12 backup
        addq    $8, %rbp                    # rbp back to stack frame    
        ret

