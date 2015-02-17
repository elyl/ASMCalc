#LHEUREUX Axel
.data
#Chaine convertie en postfixee
str3:
	.rept 512
	.byte 0
	.endr
#Chaine d'entree lue au clavier	
str_in:	
	.rept 255
	.byte 0
	.endr
#Sert a memoriser le nombre d'elements dans la pile
stack:
	.long 0
#Sert a memoriser l'emplacement dans la chaine 	
ptr:
	.long 0
#Fichier d'entree
file_in:
	.ascii "in.txt"
#Fichier de sortie
file_out:
	.ascii "out.txt"
#Fichier actuellement ouvert
fd:
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
	cmp $0, %edx
	je error
	push $str3
	call itoa
	push $str3
	call my_strlen
	push %eax
	push $str3
	call afficher
	call exit

#Converti un calcul en notation infixee vers une notation postfixee	
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
	je inf_to_post_output
	cmpb $'(', (%ecx)
	je inf_to_post_op_end
	cmpb $')', (%ecx)
	je inf_to_post_rp_init
	jmp inf_to_post_error

inf_to_post_rp_init:
	inc %ecx
	jmp inf_to_post_rp
	
inf_to_post_rp:
	cmp $0, %eax
	je inf_to_post_error
	movl $0, %ebx
	pop %ebx
	dec %eax
	cmpb $'(', %bl
	je inf_to_post_core
	movb $' ', (%edx)
	inc %edx
	movb %bl, (%edx)
	inc %edx
	jmp inf_to_post_rp
	
	
inf_to_post_op:
	cmpl $0, %eax
	je inf_to_post_op_end
	movl $0, %ebx
	pop %ebx
	cmpb $'(', %bl
	je inf_to_post_op_lp
	cmpb $'+', (%ecx)
	je inf_to_post_op_pop
	cmpb $'-', (%ecx)
	je inf_to_post_op_pop
	cmpb $'*', (%ecx)
	je inf_to_post_op_p2
	cmpb $'/', (%ecx)
	je inf_to_post_op_p2

inf_to_post_op_lp:
	push %ebx
	movl $0, %ebx
	movb (%ecx), %bl
	push %ebx
	movb $' ', (%edx)
	inc %edx
	inc %ecx
	inc %eax
	jmp inf_to_post_core

inf_to_post_op_p2:
	cmpb $'*', %bl
	je inf_to_post_op_pop
	cmpb $'/', %bl
	je inf_to_post_op_pop
	push %ebx
	jmp inf_to_post_op_end

inf_to_post_op_pop:
	movb $' ', (%edx)
	inc %edx
	movb %bl, (%edx)
	dec %eax
	inc %edx
	movb $' ', (%edx)
	inc %edx
	jmp inf_to_post_op

inf_to_post_op_end:
	movb $' ', (%edx)
	movl $0, %ebx
	movb (%ecx), %bl
	push %ebx
	inc %ecx
	inc %edx
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
	movb $' ', (%edx)
	inc %edx
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

#Converti un nombre en chaine de caracteres pour  pouvoir l'afficher
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

#Converti une chaine de caracteres en nombre pour effectuer des calculs	
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

#Effectue un calcul
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

#Quitte le programme	
.type exit, @function
exit:
	movl $1, %eax
	movl $0, %ebx
	int $0x80

#Affiche une chaine de caracteres sur l'entree standard
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

#Lit une chaine de caracteres au clavier
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

#Calcule la longueur d'une chaine
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
	