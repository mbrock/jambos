[BITS 16]
[ORG 7C00h]

	jmp 0:start

start:
	push cs
	pop ds

	mov ah,42h
	mov dl,80h
	mov si,dap
	int 13h

	call clear

	jmp 100h:0

; disk address packet for reading rest of first cylinder
dap:
	db 16     ; size
	db 0      ; reserved
	dw 32     ; block count (16k)
	dd 1000h  ; buffer offset
	dq 1      ; block offset

; clear screen
clear:
	push 0B800h
	pop gs
	push gs
	pop es
	mov		cx,(80*50)/2
	mov		ax,0700h
	xor		di,di
rep	stosw
	ret

; boot sector signature
times 510-($-$$) db 0
Sig              dw 0AA55h
