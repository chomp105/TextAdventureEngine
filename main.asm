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

	; The ParseAction subroutine searches through "action" for commands and nouns
	; The address list that "action" will be tested against must be put in the ebx register
	; The id of any match will be returned in the eax register

ParseAction:
	push ecx			; save ecx reg value
	push edx			; save edx reg value
	push edi			; save edi reg value
	xor eax, eax			; zero out the eax reg
	xor ecx, ecx			; zero out ecx reg
	xor edx, edx			; zero out edx reg
	mov edi, action			; move action address into edi reg
ParseActionLoop:
	mov al, [edi + ecx]		; move nth byte of action into al reg
	cmp [ebx + ecx], byte 10	; compare ebx + ecx to 10
	jl ParseLoopEnd			; if ebx + ecx equals 10, jump to loop end
	cmp al, 32			; compare al to 32
	je ParseActionNextAction	; if al equals 32, jump to next action
	cmp al, 10			; cmp al to 10
	je ParseActionEnd		; if al equals 10, jump to end
	cmp al, [ebx + ecx]		; compare al reg to nth byte of ebx
	jne ParseActionNextCommand	; if al doesn't equal nth byte of ebx, jump to next command	
	inc ecx				; increment ecx reg (loop counter)	
	jmp ParseActionLoop		; loop	
ParseActionLoopEnd:
	cmp [ebx+ecx], byte 0		; compare ebx + ecx reg to 0
	jne ParseLoopResult		; if ebx + ecx reg doesn't equal 0, return
	inc ecx				; increment ecx (loop counter)
	jmp ParseActionEnd		; jump to end
ParseActionResult:	
	movzx eax, byte [ebx+ecx] 	; move the id to eax
	jmp ParseActionEnd		; jump to end
ParseActionNextCommand:
	mov edx, commands		; move ebx address into edx reg
	add edx, 30			; add 31 to edx reg
	cmp ebx, edx			; compare ebx reg to edx reg
	je ParseActionNextAction	; if ebx equals edx, jump to end
	add ebx, 6			; add 6 to ebx reg
	xor ecx, ecx			; zero out ecx reg
	jmp ParseActionLoop		; jump to main loop
ParseActionNextAction:
	add edi, ecx			; add ecx reg to edi reg
	inc edi				; increment edi reg
	cmp [edi], byte 0		; compare edi with 0
	je ParseActionEnd		; if edi equals 0, jump to end
	xor ecx, ecx			; zero out ecx reg
	mov ebx, commands		; mov commands into ebx reg
	jmp ParseActionLoop		; jump to main loop
ParseActionEnd:
	pop edi				; restore edi reg value
	pop edx				; restore edx reg value
	pop ecx				; restore ecx reg value
	ret				; return
