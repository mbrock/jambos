[BITS 16]

STRUC mem_map
	.base				resq	1	
	.length				resq	1
	.type				resd	1
ENDSTRUC

E820_RAM				equ		01h
E820_RESERVED			equ		02h
E820_ACPI				equ		03h
E820_NVS				equ		04h

[SECTION .init]

start:

	call get_e820
	
	test ax,ax
	jz e820ok

	mov si, no_e820_msg
	call print_msg

e820ok:
	
	push	ds
	push	gdt
	push	(gdt_base >> 4)
	push	0
	push	gdt_end-gdt
	call	memcpy
	add		sp,10

	lgdt	[gdt]

	cli

	mov		eax,cr0
	or		eax,1h
	mov		cr0,eax

	jmp		code_selector:jumpety

jumpety:

	mov		ax,stack_selector
	mov 	ss,ax
	mov		ax,data_selector
	mov		ds,ax
	mov		es,ax

;Zero all tables
	cld
	mov		edi,pml4_base
	mov		ecx,4*1024
	xor		eax,eax
	rep		stosd

;PML4 table
	mov		ebx,		pml4_base
	mov		[ebx+4],	eax
	mov		[ebx],		dword 0x9C001

;PDP table
	mov		ebx,		pdpt_base
	mov		[ebx+4],  	eax
	mov		[ebx],		dword 0x9D001

;PD table
	mov		ebx,		pd_base
	mov		[ebx+4],	eax
	mov		[ebx],		dword 0x9E001

;Generate page table
	
	;eax zero from before
	mov		edx,0x1 	;lower dword flags n stuff
	mov		edi,pagetbl_base
	
.pt_loop:
	mov		[edi],edx
	mov		[edi+4],eax
	add		edx,0x1000
	add		edi,8
	cmp		edi,0x9F000
	jne		.pt_loop

	;Fix GDT code selector for long mode
	mov		eax,gdt_base+(gdt_patch-gdt)
	mov		[eax],byte 10101111b

	;Enable PAE
	mov		eax,cr4
	bts		eax,5
	mov		cr4,eax

	;Load PML4 address
	mov		eax,pml4_base
	mov		cr3,eax

	;Set EFER.LME
	mov		ecx,0xC0000080
	rdmsr
	bts		eax,8
	wrmsr
	
	;Set CR0.PE, thus entering Long mode
	mov		eax,cr0
	bts		eax,31
	mov		cr0,eax

	jmp		code_selector:long_mode

[BITS 64]
long_mode:

	;stack setup
	mov 	rsp,stack64_base

	;tss setup
	mov		ax,tss_selector

db	0x0f,0x00,0xC0


	;LET'S DO THIS THING!
	push	mem_map_entries
	push	memory_map
	
	extern	stage3
	call	stage3

.stop:
	jmp .stop


[BITS 16]

boot_error:
	mov		si, boot_error_msg
	call	print_msg

.stop:
	cli 
	hlt
	jmp .stop

;Args: 	word source_seg; word soruce_index;
;		word dest_seg; word dest_index;
;		word size
;near call
memcpy:

.size			equ		0+4
.dest_index		equ		2+4
.dest_seg		equ		4+4
.source_index	equ		6+4
.source_seg		equ		8+4
	
	push	bp
	mov		bp,sp

	push	ax
	push	cx
	push	ds
	push	si
	push	es
	push	di

	mov		cx,[bp+memcpy.size]
	mov		si,[bp+memcpy.source_index]
	mov		di,[bp+memcpy.dest_index]
	mov		ax,[bp+memcpy.source_seg]
	mov		ds,ax
	mov		ax,[bp+memcpy.dest_seg]
	mov		es,ax

	mov		ax,cx
	shr		cx,2
	rep		movsd

	and		ax,3
	mov		cx,ax
	rep		movsb

	pop		di
	pop 	es
	pop		si
	pop		ds
	pop		cx
	pop		ax
	pop		bp

	ret

print_msg:
	push	ax
	push	si

	mov		ah,0Eh

	.loop:

	mov		al,[ds:si]
	test	al,al
	jz		.done

	int		10h

	inc		si

	jmp		.loop

.done:

	pop		si
	pop		ax

	ret


;EAX = number to print
;SI = offset to buffer
print_numh:
	
	push	eax
	push	si
	push	es
	push	cx

	xor		cl,cl
	
	.loop:
	rol		eax,4
	mov		dl,al
	and		dl,0Fh
	add		dl,30h
	cmp		dl,39h
	jna		.notabove_ten
	
	add		dl,7
	
	.notabove_ten:
	mov		[si],dl
	inc		si
	inc		cl
	cmp		cl,7
	jna		.loop

	mov		byte [es:si],00h

	pop		cx
	pop		es
	pop		si
	pop		eax

	ret


;Enable A20 line
enable_a20:

	push	ax

	in		al,64h
	test	al,2
	jnz		enable_a20
	mov		al,0D1h
	out		64h,al

.keybwait:
	in		al,64h
	test	al,2
	jnz		.keybwait

	mov		al,0DFh
	out		60h,al

	pop		ax
	
	ret


;retrieves map of physical memory
get_e820:

	push	ebx
	push	ecx
	push	edx
	push	es
	push	di
	
	xor		ebx,ebx
	mov		di,memory_map

.loop:
	push	ds
	pop		es
	mov		eax,0E820h
	mov		ecx,20
	mov		edx,534D4150h 
	int		15h
	jc		.no_support

	cmp 	eax,534D4150h 
	jne		.no_support

	inc		word [mem_map_entries] 

	add		di,20
	cmp		word [mem_map_entries],32
	je		.done

	test 	ebx,ebx
	jnz		.loop

.done:

	xor		ax,ax

	pop		di
	pop		es
	pop		edx
	pop		ecx
	pop		ebx

	ret

.no_support:
	
	mov		ax,1
	
	pop		di
	pop		es
	pop		edx
	pop		ecx
	pop		ebx
	
	ret


;EQU -------------------------

stack64_base	equ		0x9B000

pml4_base		equ		0x9B000
pdpt_base		equ		0x9C000
pd_base			equ		0x9D000
pagetbl_base	equ		0x9E000

gdt_base		equ		0x9F000

tss_base		equ		0x9F100

code_selector	equ		0x20
data_selector	equ		0x28
stack_selector	equ		0x28
tss_selector	equ		0x30


;DATA --------------------------


boot_error_msg		db		'Unable to boot.',0
no_e820_msg			db		'No e820 support.',0

numbuf				dd		0,0
					db		0

align 8
gdt:	
	dw		0x0100 			; GDTR Limit
	dd		gdt_base		; GDTR Base
	dw		0x0000			; Fill

times 3 	dd		0,0 			; Three zeroed entries

	;Code Segment
	dw		0xFFFF		;Limit low word
	dw		0x0000		;Base low word
	db		0x00		;Base bits 16-23
	db		10011010b	;Some flags
gdt_patch: 
	db		10001111b	;Limit bits 16-19, and some flags
	db		0x00		;Base bits 24-31

	;Data Segment
	dw		0xFFFF		;Limit low word
	dw		0x0000		;Base low word
	db		0x00		;Base bits 16-23
	db		10010010b	;Some flags
	db		10001111b	;Limit bits 16-19, and some flags
	db		0x00		;Base bits 24-31

	;64-bit TSS descriptor
	dw	0x68
	dw 	tss_base & 0xFFFF 	;0xF100
	db	tss_base & 0xFF0000	;0x09
	db  10001001b
	db	00000000b
	db	0
	dq	0

gdt_end:	

	global bootinfo
bootinfo:

mem_map_entries			dw		0

memory_map:
%rep 32
istruc mem_map
	at	mem_map.base,				dd	0,0
	at	mem_map.length,				dd	0,0
	at	mem_map.type,				dd	0
iend
%endrep

