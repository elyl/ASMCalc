.data
nb1:
	.long 0
nb2:
	.long 0
len:
	.long 0
str_out:
	.ascii "%c\n"
str:
	.ascii "4 4\n"
stack:
	.long 0
ptr:
	.long 4
.text
.globl main
main:
	push $str
	push $4
	push $1
	call split
#	call do_op
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
	movl (%ebp), %eax
	addl $4, %ebp
	movl (%ebp), %ebx
	addl $4, %ebp
	movl (%ebp), %ecx
	jmp do_op_switch

do_op_switch:	
	cmpb $'+', (%ecx)
	je do_op_add
	cmpb $'-', (%ecx)
	je do_op_sub
	cmpb $'*', (%ecx)
	je do_op_mult
	cmpb $'/', (%ecx)
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

.type split, @function
split:
	push %ebp
	movl %esp, %ebp
	movl $0, %edx
	movl $str, %ecx
	#addl ptr, %ecx
	jmp split_core

split_core:
	cmpb $' ', (%ecx)
	je split_space
	cmpb $'\n', (%ecx)
	je split_ret
	inc %ecx
	inc %edx
	jmp split_core

split_ret:
	cmpb $0, %eax
	je split_end
	jmp split_space
	
split_space:
	movl stack, %eax
	inc %eax
	movl %eax, stack
	decl %ecx
	movb (%ecx), %eax
	movl ptr, %ecx
	addl %ecx, %edx
	movl %ecx, ptr
	jmp split_end
	
split_end:	
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
	