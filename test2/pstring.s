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
	inc		%rdi
    cmpb 	$0, (%rdi)
    jne 	.isOldChar
	
	movq 	%rdi, %rax         # return value
    ret

.type	pstrijcpy, @function
pstrijcpy:
	# rdi - pstring 2, rsi - pstring 1, rdx - index i, rcx - index j
	call 	pstrlen					# find the length of pstring 2
	cmpq	%rax, %rcx				# if j is bigger than length
	jge		.errorFinish
	
    movq	$0, %r9
	cmpq	%rdx, %r9				
	jg		.errorFinish
	
	pushq	%rdi					# save pstring 2				
	movq	%rsi, %rdi
	call	pstrlen
	cmpq	%rax, %rcx				# if i is smaller than 0
	jge		.errorFinish
	
	xor     %r9, %r9
    popq	%rdi					# pop pstring 2 to rdi
	inc     %rdi
    inc     %rsi
    movq	%rdi, %r9				# save dest address
	leaq	(%rdi, %rcx), %r8		# end copy dest	
	leaq	(%rdi, %rdx), %rdi		# start copy dest
	leaq	(%rsi, %rdx), %rsi		# start copy source
	jmp		.toLoop

	.toLoop:
	cmpq	%rdi, %r8				# if start dest = source dest
	jl		.finish
	movzbq  (%rsi), %rax			# move char to rax
	movb	%al, (%rdi)				# move char to rdi
	leaq	1(%rdi), %rdi
	leaq	1(%rsi), %rsi
	jmp		.toLoop

	.finish:
	inc		%r9
	movq	%r9, %rax
	ret

	.errorFinish:
	movq 	$format_invalid, %rdi
	movq 	$0, %rax
	call 	printf
	ret

.type    swap, @function
swap:                   # in order to switch letters
    # check if letter
    movq    $123, %r9               # check if char is bigger than Z
    cmpb    0(%rdi), %r9b
    jle    .notaletter
    movq    $64, %r9                # check if char is smaller than i
    cmpb    0(%rdi), %r9b
    jge    .notaletter
    
    movq    $90, %r9                # check if upper case
    cmpb    0(%rdi), %r9b
    jge    .toLower
    movq    $97, %r9                # check if lower case
    cmpb    %r9b, 0(%rdi)
    jge    .toUpper
    jmp    .notaletter
    
	.notaletter:                    # in case of not a letter
    movb    (%rdi), %al
    ret
	.toLower:                       # from upper to lower
    movb    (%rdi), %al
    addb    $32, %al
    ret
    .toUpper:                       # from lower to upper
    movb    (%rdi), %al
    subb    $32, %al
    ret

.type    swapCase, @function
swapCase:
    movq    %rdi, %rdx
    addq    $1, %rdi
    jmp    .loop_swap

    .loop_swap:
    cmpb    $0, (%rdi)              # if rdi points to /0 - done
    je      .finish_swap
    call    swap
    movb    %al, (%rdi)
    addq    $1, %rdi
    jmp    .loop_swap
    
    .finish_swap:
    movq    %rdx, %rax
    ret

.type pstrijcmp @function
pstrijcmp:
    # rdi - pstring 2, rsi - pstring 1, rdx - index i, rcx - index j
	call 	pstrlen					# find the length of pstring 2
	cmpq	%rax, %rcx				# if j is bigger than length
	jge		.notOK
	
    movq	$0, %r9
	cmpq	%rdx, %r9				
	jg		.notOK
	
	pushq	%rdi					# save pstring 2				
	movq	%rsi, %rdi
	call	pstrlen
	cmpq	%rax, %rcx				# if i is smaller than 0
	jge		.notOK

	popq	% rdi
    inc    	%rdi
    inc    	%rsi
	leaq	(%rdi, %rcx), %r8		# end copy dest	
	leaq	(%rdi, %rdx), %rdi		# start copy dest
	leaq	(%rsi, %rdx), %rsi		# start copy source
    inc    	%r8
    jmp    .loop_cmp
    
	.p1greater:
    movq    $-1, %rax
    ret
	.p2greater:
    movq    $1, %rax
    ret
	.equals:
    movq    $0, %rax
    ret
    
	.loop_cmp:
    movzbq	(%rsi), %rax			# comparison if p1 is greater
    cmpb	%al, (%rdi)    
    jl    	.p1greater
    movzbq	(%rsi), %rax			# comparison if p1 is greater
    cmpb	%al, (%rdi)
    jg    	.p2greater
    cmpq    %rdi, %r8				# comparison if rdi reached index j
    je    	.equals
    movb    $0, %r11b
    cmpb    0(%rdi), %r11b			# in case that reached string length
    je    	.equals
    movq    $0, %r11
    cmpb    0(%rsi), %r11b
    je    	.equals
    leaq    1(%rdi), %rdi
    leaq    1(%rsi), %rsi
    jmp    	.loop_cmp
    
	.notOK:
    movq    $format_invalid, %rdi
    movq    $0, %rax
    call    printf
    movq    $-2, %rax
    ret
