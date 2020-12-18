.section .rodata
.align 8
format_invalid: .string "invalid input!\n"
format_end:     .string "\0"

.text
.type pstrlen, @function
pstrlen:
    movb %dil, %sil
    ret

.type replaceChar, @function
replaceChar:
    # rdi - pstr, rsi - oldChar, rdx - newChar
    .replace:
    movb %dl, %cl
    .isOldChar:
    cmpb %sil, %r12b
    je replace              # need to be replaced
    leaq 1(%r12), %r12      # index + 1

    pushq %r12
    movq %rdi, %r12         # create a copy of pstr
    jmp loop                # continue with loop
    
    .loop:
    cmpb $format_end, %cl
    je isOldChar
    movq %rdi, %rax         # return value
    popq %r12               # pop to r12
    ret

.type lowerUpper, @function
lowerUpper:                   # this is a function that swap case type
	cmpb	%dil, 64           # comparison of byte with @ - a char before A
	jle	    notequal	        # not equal
	cmpb	$123, %dil          # comparison of byte with [ - a char after z
	jle	    notequal
	cmpb	%dil, 90           # is upper
	jle	    toLower             
	cmpb	97, %dil           # is lower
	jle	    toUpper
	jmp	    notequal
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
	jmp	    loop_swap
	.end:
	movq	%rsi, %rax              # move rsi to return value
	ret
	.loop_body:
	call	lowerUpper            
	movb	%al, %dil              # return value from LowerToUpper to byte of rdi
	leaq	1(%rdi), %rdi           # the next char
	.loop_swap:
	cmpb	$format_end, %dil       # end of pstring       
	je	    end                     
	jmp	loop_body
    ret

.type	pstrijcpy, @function
pstrijcpy:
	call	pstrlen		#Start of index out of bound check
	cmpb	%al, %cl	#End index is bigger than the dest
	jl	error_end
	cmpq	%rdx, 0	#Start index is smaller than 0
	jl	error_end
	pushq	%rdi
	movq	%rsi, %rdi
	call	pstrlen
	cmpb	%al, %cl	#End index is bigger than source
	jl	    error_end
	popq	%rdi		#End of index out of bound check
	movq	%rdi, %r11	#Backing up dest string pointer
	leaq	(%rdi, %rdx, 8), %rdi	#Start of copy dest
	leaq	(%rsi, %rdx, 8), %rsi	#Start of copy source
	leaq	(%rdi, %rcx, 8), %r8	#End of copy dest
	leaq	(%rsi, %rcx, 8), %r9	#End of copy source
	jmp	    loopcpy
	.loop_bodycpy:
	movb	%sil, %dil
	leaq	1(%rdi), %rdi
	leaq	1(%rsi), %rsi
	.loopcpy:
	cmpb	%dil, %r8b
	je	    end_succ
	jmp	    loop_bodycpy
	.end_succ:
	movb	%sil, %dil
	movq	%r11, %rax
	ret
	.error_end:
	movq	$format_invalid, %rdi
	movq	$0, %rax
	call	printf

.type pstrijcmp @function
pstrijcmp:
    call pstrlen
    cmpb %al, %cl                 # index exception
    jl error_endcmp
    cmpq %rdx, 0                   # index exception
    jl error_endcmp
    pushq %rdi
    movq %rsi, %rdi
    call pstrlen
    cmpb %al, %cl
    jl error_endcmp
    popq %rdi
    leaq (%rdi, %rdx, 8), %rdi      # start p1
    leaq (%rsi, %rdx, 8), %rsi      # start p2
    leaq (%rdi, %rcx, 8), %r8       # end copy p1
    leaq (%rsi, %rcx, 8), %r9       # end copy p2
    jmp loop_cmp

    .p1greater:
    movq $1, %rax
    ret
    .p2greater:
    movq $-1, %rax
    .equals:
    movq    $0, %rax
    ret

    .loop_cmp:
    cmpb    %dil, %sil          	# comparison
    jg      p1greater               # if p1 is greater
    cmpb    %dil, %sil          	# comparison again          
    jl      p2greater               # if p2 is greater
    cmpb    %dil, %r8b          	# comparison again
    je      equals                  # equals
    cmpb    %dil, format_end     	# end of p1
    je      equals                  
    leaq    1(%rdi), %rdi          # p1 i + 1
    leaq    1(%rsi), %rsi          # p2 i + 1          
    jmp     loop_cmp               # continue with loop


    .error_endcmp:
    movq $format_invalid, %rdi
    movq $0, %rax
    call printf
    movq $-2, %rax
    ret
