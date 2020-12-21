.section	.rodata
format_string:	.string " %s"
format_number:	.string " %hhu"
 
.text
.global	run_main
.type	run_main, @function
 
run_main:
	# push callee savers
    pushq	%rbx                        	# rbx backup
	pushq	%r12                            # r12 backup
	pushq	%r13                            # r13 backup
	pushq	%rbp                            # save old stack frame
	movq	%rsp, %rbp              
    # scan length 1
	subq	$260, %rsp						# stack allocation - string + length
	subq	$260, %rsp						# stack allocation - string + length
	subq	$32, %rsp                      	# stack allocation - 4 registers
	leaq	(%rsp), %rsi                    # stack pointer as argument 2 to scan   
    movq	$format_number, %rdi            # format as argument 1 to scan  
	movq	$0, %rax
	call	scanf
    # scan string 1
	movq	%rsp, %rbx                      # save pointer to pstring 1
	movq	$format_string, %rdi            # format as argument 1 to scan
    addq	$1, %rsp
	movq	%rsp, %rsi                   # stack pointer as argument 2 to scan
	subq	$1, %rsp
	movq	$0, %rax
	call	scanf
	xor		%r12, %r12                     	# adding /0
	movb	(%rsp), %r12b
	leaq	1(%rsp, %r12), %rsi
	movb	$0, (%rsi)
    # scan length 2
    movq	$format_number, %rdi            # format as argument 1 to scan
	leaq	256(%rsp), %rsi                 # stack pointer as argument 2 to scan
	movq	%rsi, %r12                      # save pointer to pstring2
	movq	$0, %rax
	call	scanf
    # scan string 2
    movq	$format_string, %rdi            # format as argument 1 to scan
	leaq	1(%r12), %rsi                   # stack pointer as argument 2 to scan
	movq	$0, %rax
	call	scanf
	xor		%r13, %r13                      # adding /0
	movb	(%r12), %r13b
	leaq	1(%r12, %r13), %rsi
	movb	$0, (%rsi)
    # scan switch option
	movq	$format_number, %rdi            # format as argument 1 to scan
    leaq	2(%r12, %r13), %rsi             # stack pointer as argument 2 to scan   
	movq	%rsi, %r13                      # save pointer to switch option
	movq	$0, %rax
	call	scanf
        # send argument to run_func
	xor		%rsi, %rsi
	xor		%rdx, %rdx
	xor		%rdi, %rdi
	movb	(%r13), %dil
	movq	%rbx, %rsi
	movq	%r12, %rdx
	call	run_func
        # return values to callee savers
	movq	%rbp, %rsp
	popq	%rbp
	popq	%r13
	popq	%r12
	popq	%rbx
	ret