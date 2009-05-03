[BITS 16]
[ORG 1000h]

[SECTION .init]

STRUC mem_map
	.base				resq	1	
	.length				resq	1
	.type				resd	1
ENDSTRUC

E820_RAM				equ		01h
E820_RESERVED			equ		02h
E820_ACPI				equ		03h
E820_NVS				equ		04h

start:
	call get_e820
	
	test ax,ax
	jz e820ok

	mov si, no_e820_msg
	call print_msg

e820ok:
	
	push	ds
	push	gdt
	push	0x9FF0
	push	0
	push	gdt_end-gdt
	call	memcpy
	add		sp,10

	lgdt	[gdt]

	cli

	mov		eax,cr0
	or		eax,11h
	mov		cr0,eax

	jmp 0x20:jumpety

jumpety:

	

boot_error:
		mov si, boot_error_msg
		call print_msg

.stop
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




;DATA --------------------------


boot_error_msg		db		'Unable to boot.',0
no_e820_msg			db		'No e820 support.',0

numbuf				dd		0,0
					db		0

align 8
gdt32
	dw		0x1000 			; GDTR Limit
	dd		0x0009FF00		; GDTR Base
	dw		0x0000			; Fill

times 3 	dd		0,0 			; Three zeroed entries

	db		0xFF,0xFF,0x00,0x00,0x00,0x9A,0xAF,0x00 ;Code
	db		0xFF,0xFF,0x00,0x00,0x00,0x92,0xCF,0x00 ;Data
	;64-bit TSS descriptor
	dw	0x68
	dw 	0xFE00
	db	0x09
	db  10001001b
	db	00000000b
	db	0
	dq	0

gdt32_end


mem_map_entries			dw		0

memory_map:
%rep 32
istruc mem_map
	at	mem_map.base,				dd	0,0
	at	mem_map.length,				dd	0,0
	at	mem_map.type,				dd	0
iend
%endrep
