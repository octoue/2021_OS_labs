/* ===== code32 =========================== */
.text
	.globl 	_start		# GNU default entry point
	.globl  osStart
	.globl  ignoreIntBody

.code32
_start:
	jmp establish_stack

dead:	jmp dead			# Never here

# Set up the stack
establish_stack:
	movl	$0x80000, %eax	
	
	movl	%eax, %esp		# set stack pointer
	movl	%eax, %ebp		# set base pointer

# Zero out the BSS segment
zero_bss:
	cld				              # make direction flag count up
	movl	$_end, %ecx		      # find end of .bss
	movl	$_bss_start, %edi	  # edi = beginning of .bss
	subl	%edi, %ecx		      # ecx = size of .bss in bytes
	shrl	%ecx			      # size of .bss in longs
	shrl	%ecx
	
	xorl	%eax, %eax		      # value to clear out memory
	repne						  # while ecx != 0
	stosl				          # clear a long in the bss

setup_idtptr:
	call setup_idt
	lidt idtptr

# Transfer control to main
to_main:	
	call	osStart

shut_down:	
	jmp	shut_down	# Never here	


	.p2align 4
time_interrupt:
	cld
	pushf
	pusha
	call tick
	popa
	popf
	iret

	.p2align 4 
ignore_int1:
	cld
	pusha
	call ignoreIntBody
	popa
	iret


	#初始化中断向量表
setup_idt:
	movl $ignore_int1,%edx
	movl $0x00080000,%eax
	movw %dx,%ax
	movw $0x8E00,%dx

	movl $IDT,%edi
	mov  $256,%ecx

rp_sidt:
	movl %eax,(%edi)
	movl %edx,4(%edi)
	addl $8,%edi
	dec %ecx 
	jne rp_sidt 

	#特别初始化时钟的中断
setup_time_int_32:
	movl $time_interrupt,%edx
	movl $0x00080000,%eax
	movw %dx,%ax
	movw $0x8E00,%dx

	movl $IDT,%edi
	addl $(32*8),%edi
	movl %eax,(%edi)
	movl %edx,4(%edi)

	ret



/* ===== data =========================== */
.data

#IDT 
	.p2align 4
	.globl IDT
IDT:
	.rept 256
	.word 0,0,0,0
	.endr

idtptr:
	.word (256*8-1)
	.long IDT