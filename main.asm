section .data
	
	commands db "go",0,0,0,1, "move",0,1, "walk",0,1, "look",0,2, "check",2, "use",0,0,3

	nouns db "cat",0,0,1,  "dog",0,0,2, "monke",3

section .bss

	action resb 100
	
	result resb 1

section .text
	global _start
_start:
	
	mov eax, 3
	mov ebx, 2
	mov ecx, action
	mov edx, 100
	int 0x80

	call chkaction

	mov [result], al
	add [result], byte 48
		
	mov eax, 4
	mov ebx, 1
	mov ecx, result
	mov edx, 1
	int 0x80	

	; Exit the program

exit:
	mov eax, 1			; move 1 into eax reg
	xor ebx, ebx			; zero out ebx reg
	int 0x80			; call kernel

	; The clraction function sets every index of action to 0

clraction:
	push ecx			; save ecx reg value
	xor ecx, ecx			; zero out ecx reg
clrloop:
	mov [action + ecx], byte 0	; zero out nth place of action
	inc ecx				; increment ecx reg (loop counter)
	cmp ecx, 100			; compare ecx reg to 100
	jl clrloop			; if ecx reg lower, loop
	pop ecx				; restore ecx reg value
	ret				; return

	; The chkaction function compares action with the commands
	; It puts the id of any match in the eax reg

chkaction:
	push ebx			; save ebx reg value
	push ecx			; save ecx reg value
	push edx			; save edx reg value
	push edi			; save edi reg value
	xor eax, eax			; zero out the eax reg
	mov ebx, commands		; move commands address into ebx reg
	xor ecx, ecx			; zero out ecx reg
	xor edx, edx			; zero out edx reg
	mov edi, action			; move action address into edi reg
chkloop:
	mov al, [edi + ecx]		; move nth byte of action into al reg
	cmp [ebx + ecx], byte 10	; compare commands + ecx to 10
	jl chkloopend			; if commands + ecx equals 10, end
	cmp al, 32			; compare al to 32
	je nextaction			; if al equals 32, return
	cmp al, 10			; cmp al to 10
	je exit				; if al equals 10, return
	cmp al, [ebx + ecx]		; compare al reg to nth byte of commands
	jne nextcmd			; jump to next command if not equal	
	inc ecx				; increment ecx reg (loop counter)	
	jmp chkloop			; loop	
chkloopend:
	cmp [ebx+ecx], byte 0		; compare commands + ecx reg to 0
	jne chkloopres			; if commands + ecx reg doesn't equal 0, return
	inc ecx				; increment ecx
	jmp chkloopend
chkloopres:	
	movzx eax, byte [ebx+ecx] 	; move the command id to eax
	jmp chkend			; jump to chkend
nextcmd:
	mov edx, commands		; move commands address into edx reg
	add edx, 30			; add 31 to edx reg
	cmp ebx, edx			; compare ebx reg to edx reg
	je nextaction			; if ebx equals edx, jump to chkend
	add ebx, 6			; add 6 to ebx reg
	xor ecx, ecx			; zero out ecx reg
	jmp chkloop			; jump to chkloop
nextaction:
	add edi, ecx			; add ecx reg to edi reg
	inc edi				; increment edi reg
	cmp [edi], byte 0		; compare edi with 0
	je chkend			; if edi equals 0, return
	xor ecx, ecx			; zero out ecx reg
	mov ebx, commands		; mov commands into ebx reg
	jmp chkloop			; jump to chkloop
chkend:
	pop edi
	pop edx				; restore edx reg value
	pop ecx				; restore ecx reg value
	pop ebx				; restore ebx reg value
	ret				; return
