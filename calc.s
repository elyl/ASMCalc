.data
nb1:
	.long 0
nb2:
	.long 0
len:
	.long 3
str_out:
	.ascii "%c\n"
str:
	.ascii "12+"
stack:
	.long 0
ptr:
	.long 0
.text
.globl main
main:
	push $str
	push $4
	push $1

split_init:
	movl $str, %ecx
	movl stack, %edx
	movl $0, %eax
	
split:
	movl len, %ebx
	cmpl %ebx, %edx
	je end
	cmpb $'0', (%ecx)
	jl split_not_nb
	cmpb $'9', (%ecx)
	jg split_not_nb
	jmp split_nb

split_nb:
	movb (%ecx), %al
	push %eax
	inc %edx
	inc %ecx
	jmp split

split_not_nb:
	cmpb $'+', (%ecx)
	je split_op
	cmpb $'-', (%ecx)
	je split_op
	cmpb $'*', (%ecx)
	je split_op
	cmpb $'/', (%ecx)
	je split_op
	jmp error

split_op:
	movb (%ecx), %al
	push %eax
	inc %edx
	cmpl $3, %edx
	jl error
	jmp split_ok

split_ok:
	movl %edx, stack
	call do_op
	jmp end

error:
	call exit
end:	
	call afficher
	call exit

.type matoi, @function
	push %ebp
	movl %esp, %ebp
	addl $8, %ebp
	movl (%ebp), %eax
	push %eax
	call atoi
	subl $8, %ebp
	movl %ebp, %esp
	ret
	
.type do_op, @function
do_op:	
	push %ebp
	movl %esp, %ebp
	addl $8, %ebp
	movl (%ebp), %ecx
	addl $4, %ebp
	movl (%ebp), %ebx
	addl $4, %ebp
	movl (%ebp), %eax
	jmp do_op_switch

do_op_switch:	
	cmpb $'+', %cl
	je do_op_add
	cmpb $'-', %cl
	je do_op_sub
	cmpb $'*', %cl
	je do_op_mult
	cmpb $'/', %cl
	je do_op_div

do_op_add:
	add %ebx, %eax
	jmp do_op_end
	
do_op_sub:
	sub %ebx, %eax
	jmp do_op_end

do_op_mult:
	imul %ebx, %eax
	jmp do_op_end

do_op_div:
	movl $0, %edx
	idiv %ebx
	jmp do_op_end

do_op_end:
	subl $16, %ebp
	movl %ebp, %esp
	pop %ebp
	ret

.type exit, @function
exit:
	movl $1, %eax
	movl $0, %ebx
	int $0x80
	
.type afficher, @function
afficher:
	push %ebp
	movl %esp, %ebp
	push %eax
	push $str_out
	call printf
	movl %ebp, %esp
	pop %ebp
	ret
	