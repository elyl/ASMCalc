.data
nb1:
	.long 0
nb2:
	.long 0
str_out:
	.ascii "%c\n"
str:
	.ascii "5 + 1 +\n"
stack:
	.long 0
ptr:
	.long 0
.text
.globl main
main:
	push $str
	call matoi
	jmp end

split_init:
	movl $str, %ecx
	movl stack, %edx
	movl $0, %eax
	movl $0, %ebx
	
split:
	cmpb $'\n', (%ecx)
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
	movb (%ecx), %bl
	push %ebx
	inc %edx
	inc %ecx
	cmpl $3, %edx
	jl error
	jmp split_ok

split_ok:
	movl %edx, stack
	movl %ecx, ptr
	call do_op
	push %eax
	movl stack, %edx
	movl ptr, %ecx
	subl $2, %edx
	jmp split

error:
	call exit
end:
	pop %eax
	call afficher
	call exit

.type matoi, @function
matoi:
	push %ebp
	movl %esp, %ebp
	addl $8, %ebp
	movl (%ebp), %ecx	
	movl $1, %ebx
	jmp matoi_len

matoi_len:
	cmpb $' ', (%ecx)
	je matoi_init
	inc %ecx
	imul $10, %ebx
	jmp matoi_len

matoi_init:
	movl $0, %edx
	movl %ebx, %eax
	movl $10, %ecx
	idiv %ecx
	movl %eax, %ebx
	movl $0, %eax
	movl $0, %edx
	movl (%ebp), %ecx
	jmp matoi_core

matoi_core:
	movl $0, %eax
	cmpb $' ', (%ecx)
	je matoi_end
	cmpb $'0', (%ecx)
	jl matoi_error
	cmpb $'9', (%ecx)
	jg matoi_error
	movb (%ecx), %al
	subl $'0', %eax
	imul %ebx, %eax
	addl %eax, %edx
	push %edx
	movl %ebx, %eax
	movl $0, %edx
	movl $10, %ebx
	idiv %ebx
	movl %eax, %ebx
	pop %edx
	inc %ecx
	jmp matoi_core

matoi_error:
	call exit

matoi_end:
	movl %edx, %eax
	subl $8, %ebp
	movl %ebp, %esp
	pop %ebp
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
	