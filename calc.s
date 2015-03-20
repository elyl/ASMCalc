.data
str3:
	.rept 255
	.byte 0
	.endr
str_in:	
	.rept 255
	.byte 0
	.endr
stack:
	.long 0
ptr:
	.long 0
.text
.globl main
main:
	push $str_in
	call saisir
	push $str3
	push $str_in
	call inf_to_post
	jmp split_init
	
split_init:
	movl $str3, %ecx
	movl stack, %edx
	movl $0, %eax
	movl $0, %ebx
	
split:
	cmpb $0, (%ecx)
	je end
	cmpb $'0', (%ecx)
	jl split_not_nb
	cmpb $'9', (%ecx)
	jg split_not_nb
	jmp split_nb

split_nb:
	push %edx
	push %ecx
	call matoi
	pop %edx
	pop %edx
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
	cmpb $' ', (%ecx)
	je split_espace
	jmp error

split_espace:
	cmpb $'\n', (%ecx)
	je end
	cmpb $' ', (%ecx)
	jne split
	inc %ecx
	jmp split_espace
	
split_op:
	movb (%ecx), %al
	push %eax
	inc %edx
	inc %ecx
	cmpl $3, %edx
	jl error
	jmp split_ok

split_ok:
	movl %edx, stack
	movl %ecx, ptr
	call do_op
	pop %ecx
	pop %ecx
	pop %ecx
	push %eax
	movl stack, %edx
	movl ptr, %ecx
	subl $2, %edx
	jmp split

error:
	call exit
end:
	push $str3
	call itoa
	push $str3
	call my_strlen
	push %eax
	push $str3
	call afficher
	call exit

.type inf_to_post, @function
inf_to_post:
	push %ebp
	movl %esp, %ebp
	addl $8, %ebp
	movl (%ebp), %ecx
	addl $4, %ebp
	movl (%ebp), %edx
	movl $0, %eax
	movl $0, %ebx
	jmp inf_to_post_core

inf_to_post_core:
	cmpb $'\n', (%ecx)
	je inf_to_post_end
	cmpb $'0', (%ecx)
	jl inf_to_post_notnb
	cmpb $'9', (%ecx)
	jg inf_to_post_error
	jmp inf_to_post_output

inf_to_post_output:
	push %eax
	movl $0, %eax
	movb (%ecx), %al
	movb %al, (%edx)
	pop %eax
	inc %edx
	movb $' ', (%edx)
	inc %ecx
	inc %edx
	jmp inf_to_post_core

inf_to_post_notnb:
	cmpb $'+', (%ecx)
	je inf_to_post_op
	cmpb $'-', (%ecx)
	je inf_to_post_op
	cmpb $'*', (%ecx)
	je inf_to_post_op
	cmpb $'/', (%ecx)
	je inf_to_post_op
	cmpb $' ', (%ecx)
	je inf_to_post_space
	jmp inf_to_post_error

inf_to_post_op:
	cmpl $0, %eax
	je inf_to_post_op_end
	movl $0, %ebx
	pop %ebx
	cmpb $'+', %bl
	je inf_to_post_op_pop
	cmpb $'-', %bl
	je inf_to_post_op_pop
	cmpb $'*', %bl
	je inf_to_post_op_p2
	cmpb $'/', %bl
	je inf_to_post_op_p2

inf_to_post_op_p2:
	cmpb $'*', (%ecx)
	je inf_to_post_op_pop
	cmpb $'/', (%ecx)
	je inf_to_post_op_pop
	jmp inf_to_post_op_end

inf_to_post_op_pop:
	movb %bl, (%edx)
	dec %eax
	inc %edx
	movb $' ', (%edx)
	inc %edx
	jmp inf_to_post_op

inf_to_post_op_end:
	push (%ecx)
	inc %ecx
	inc %eax
	jmp inf_to_post_core

inf_to_post_space:
	inc %ecx
	jmp inf_to_post_core

inf_to_post_error:
	call exit
	
inf_to_post_end:
	cmpl $0, %eax
	je inf_to_post_exit
	movl $0, %ebx
	pop %ebx
	movb %bl, (%edx)
	inc %edx
	dec %eax
	jmp inf_to_post_end
	
inf_to_post_exit:	
	subl $12, %ebp
	movl %ebp, %esp
	pop %ebp
	ret
	
.type itoa, @function
itoa:
	push %ebp
	movl %esp, %ebp
	addl $8, %ebp
	movl (%ebp), %ecx
	addl $4, %ebp
	movl $1, %ebx
	jmp itoa_max

itoa_max:
	movl (%ebp), %eax
	movl $0, %edx
	idiv %ebx
	cmpl $0, %eax
	je itoa_init
	imul $10, %ebx
	jmp itoa_max

itoa_init:
	movl %ebx, %eax
	movl $10, %ebx
	movl $0, %edx
	idiv %ebx
	movl %eax, %ebx
	movl (%ebp), %eax
	jmp itoa_core
	
itoa_core:
	cmpl $0, %ebx
	je itoa_end
	movl $0, %edx
	idiv %ebx
	addl $'0', %eax
	movl %eax, (%ecx)
	movl %edx, %eax
	inc %ecx
	push %eax
	movl $0, %edx
	movl %ebx, %eax
	movl $10, %ebx
	idiv %ebx
	movl %eax, %ebx
	pop %eax
	jmp itoa_core

itoa_end:
	subl $12, %ebp
	movl %ebp, %esp
	pop %ebp
	ret
	
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
	addl $8, %ebp
	movl (%ebp), %ecx
	addl $4, %ebp
	movl (%ebp), %edx
	movl $4, %eax
	movl $1, %ebx
	int $0x80
	subl $12, %ebp
	movl %ebp, %esp
	pop %ebp
	ret

.type saisir, @function
saisir:
	push %ebp
	movl %esp, %ebp
	addl $8, %ebp
	movl (%ebp), %ecx
	movl $3, %eax
	movl $0, %ebx
	movl $255, %edx
	int $0x80
	subl $8, %ebp
	movl %ebp, %esp
	pop %ebp
	ret
	
.type my_strlen, @function
my_strlen:
	push %ebp
	movl %esp, %ebp
	addl $8, %ebp
	movl (%ebp), %ecx
	movl $0, %eax
	jmp my_strlen_core

my_strlen_core:
	cmpb $0, (%ecx)
	je my_strlen_end
	inc %ecx
	inc %eax
	jmp my_strlen_core

my_strlen_end:
	subl $8, %ebp
	movl %ebp, %esp
	pop %ebp
	ret
	