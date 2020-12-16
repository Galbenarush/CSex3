.text
pstrlen:
    movb (%rax), %rax
    ret

replaceChar:
    # rdi - pstr, rsi - oldChar, rdx - newChar
    push %r12
    leaq 1(%rax), %r  