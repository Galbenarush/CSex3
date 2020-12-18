.section .rodata
.align 8
format_invalid: .string "invalid input!\n"
format_end:     .string "\0"

.text
.global pstrlen, replaceChar, pstrijcmp, pstrijcpy, swapCase
.type pstrlen, @function
pstrlen:
    movzbq 0(%rdi), %rax
    ret

.type replaceChar, @function
replaceChar:
    # rdi - pstr, rsi - oldChar, rdx - newChar
    movq 	%rdi, %rax         # create a copy of pstr
    jmp 	.loop              # goto loop

	.replace:
    movb 	%dl, (%rdi)
    
	.isOldChar:
    cmpb 	%sil, 0(%rdi)
    je 		.replace           # need to be replaced
    
	.loop:
	addq	$1, %rdi
    cmpb 	$0, (%rdi)
    jne 	.isOldChar
	
	movq 	%rdi, %rax         # return value
    ret

.type	pstrijcpy, @function
pstrijcpy:
	call 	pstrlen					# find the length of pstring 2
	cmpq	%rax, %rcx				# if j is bigger than length
	jl		.errorFinish
	
	movq	$0, %r9
	cmpq	%r9, %rdx				# if i is smaller than 0
	jl		.errorFinish
	
	pushq	%rdi					# save pstring 2				
	movq	%rsi, %rdi
	call	pstrlen
	
	cmpq	%rcx, %rax
	jl		.errorFinish
	popq	%rdi					# pop pstring 2
	# movq	%rdi, %r10				# move pstring 2 to r10
	leaq	(%rdi, %rdx, 8), %rdi	# start copy dest
	leaq	(%rdi, %rcx, 8), %r8	# end copy dest	
	leaq	(%rsi, %rdx, 8), %rsi	# start copy source
	leaq	(%rsi, %rcx, 8), %r9	# end copy source
	jmp		.toLoop

	.toLoop:
	cmpq	%rdi, %r8				# if start dest = source dest
	je		.finish
	jmp		.gotoloop

	.gotoloop:
	movb	%sil, %dil
	leaq	1(%rdi), %rdi
	leaq	1(%rsi), %rsi
	# leaq	1(%r10), %r10

	.finish:
	movb	%sil, %dil
	# addq	$1, %r10
	movq	%rdi, %rax
	ret

	.errorFinish:
	movq 	$format_invalid, %rdi
	movq 	$0, %rax
	call 	printf
	ret

.type lowerUpper, @function
lowerUpper:                   	# this is a function that swap case type
	cmpb	%dil, 64           	# comparison of byte with @ - a char before A
	jle	    .notequal	        # not equal
	cmpb	$123, %dil          # comparison of byte with [ - a char after z
	jle	    .notequal
	cmpb	%dil, 90           	# is upper
	jle	    .toLower             
	cmpb	97, %dil           	# is lower
	jle	    .toUpper
	jmp	    .notequal
	.notequal: 		            # not a-z or A-Z
	movq	%rdi, %rax
	ret
	.toLower:			        # from upper to lower
	movq	32(%rdi), %rax
	ret
	.toUpper:		            # from lower to upper
	movq	-32(%rdi), %rax
	ret


.type	swapCase, @function
swapCase:
	movq	%rdi, %rsi              # put *pstring on rsi
	jmp	    .loop_swap
	.end:
	movq	%rsi, %rax              # move rsi to return value
	ret
	.loop_body:
	call	lowerUpper            
	movb	%al, %dil              # return value from LowerToUpper to byte of rdi
	leaq	1(%rdi), %rdi           # the next char
	.loop_swap:
	cmpb	$0, %dil       # end of pstring       
	je	    .end                     
	jmp		.loop_body
    ret

.type pstrijcmp @function
pstrijcmp:
    call 	pstrlen
    cmpb 	%al, %cl                 # index exception
    jl 		.error_endcmp
    cmpq 	%rdx, 0                   # index exception
    jl 		.error_endcmp
    pushq 	%rdi
    movq 	%rsi, %rdi
    call 	pstrlen
    cmpb 	%al, %cl
    jl 		.error_endcmp
    popq 	%rdi
    leaq 	(%rdi, %rdx, 8), %rdi      # start p1
    leaq 	(%rsi, %rdx, 8), %rsi      # start p2
    leaq 	(%rdi, %rcx, 8), %r8       # end copy p1
    leaq 	(%rsi, %rcx, 8), %r9       # end copy p2
    jmp 	.loop_cmp

    .p1greater:
    movq 	$1, %rax
    ret
    .p2greater:
    movq 	$-1, %rax
    .equals:
    movq    $0, %rax
    ret

    .loop_cmp:
    cmpb    %dil, %sil          	# comparison
    jg      .p1greater               # if p1 is greater
    cmpb    %dil, %sil          	# comparison again          
    jl      .p2greater               # if p2 is greater
    cmpb    %dil, %r8b          	# comparison again
    je      .equals                  # equals
    cmpb    %dil, format_end     	# end of p1
    je      .equals                  
    leaq    1(%rdi), %rdi          # p1 i + 1
    leaq    1(%rsi), %rsi          # p2 i + 1          
    jmp     .loop_cmp               # continue with loop


    .error_endcmp:
    movq 	$format_invalid, %rdi
    movq 	$0, %rax
    call 	printf
    movq 	$-2, %rax
    ret
