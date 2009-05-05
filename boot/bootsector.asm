[BITS 16]
[ORG 7C00h]

	jmp 0:start

start:

	push cs
	pop ds

	push 0B800h
	pop gs

	;clear screen
	push gs
	pop es
	mov		cx,(80*50)/2
	mov		ax,0700h
	xor		di,di
rep	stosw


	;check floppy

	stc
	mov ah,41h
	mov bx,55aah
	mov dl,80h
	int 13h
	;jmp stop

	stc
	mov ax,4200h
	mov dx,80h
	lea si,[dap]
	int 13h

	jmp 0x1000:0

; disk address packet for reading rest of first cylinder
dap:
	db 16     ; size
	db 0      ; reserved
	dw 63     ; block count
	dd 1000h  ; buffer
	dq 1      ; block offset

times 510-($-$$)	db	0
Sig					dw	0AA55h