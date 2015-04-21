%include "io.mac"

.DATA
nonOrderedMsg	db	"Ten unordered Words are: ",0
orderedMsg	db	"The ten words ordered alphabetically: ",0
		;10 words of 10bytes MAX each starts here
word1		db  	"new", 0		;word 1
word2		db 	"mundo", 0
word3		db 	"palindrome"	;if exactly 10 chars no need for 0
word4		db 	"Grecia", 0
word5		db 	"nasm", 0
word6		db 	"HOLA", 0
word7		db 	"gato", 0
word8		db 	"Costa Rica"
word9		db 	"Arduino", 0
word10		db 	"Dota", 0		;word 10
.UDATA
wordBuffer	resb 10				;used to swap word order arround
wordArray	resb 100				;load words into here, fill with 0

.CODE
	.STARTUP
	call loadWords
	call showNonOrdered

	mov esi, wordArray
	call sortArrayInit



	jmp END

END:
	.EXIT


;-------------------------------------------------------
;Procedure Save the 10 words into arrayBlock.
;-------------------------------------------------------
loadWords:					;load words intro array
	pushad						;save registers
	mov esi, wordArray
	mov ebx, word1
	mov cx, 11				;10 words to loop over and we dec at start so 11
	sub esi, 10
loadWordsLoop:
	add esi, 10
	xor edx, edx
	dec cx
	je doneLoad
movCharsLoop:				;mov all cahrs in word
	mov ah, [ebx]			;align get our char
	mov [esi+edx],ah
	inc ebx						;move to next char
	inc edx

	cmp edx, 10
	je loadWordsLoop

	cmp ah, 0					;if end of word go to next word
	je loadWordsLoop	;if we counted through 10 chars then also go to next word
	jmp movCharsLoop	;when 0 stop looping
doneLoad:
	popad							;restore registers
	ret

;-------------------------------------------------------
;Procedure to sort words in the array
;ESI needs to point to first word in array
;-------------------------------------------------------
sortArrayInit:			;sort the words in the array alphabetically
	pushad

	xor ecx, ecx			;ch we use as upper 10 loop cl lower 10 loop
	xor edx, edx			;we going to compare first letter
getWord:						;Get each word to be compared
	xor eax, eax
	mov al, cl
	imul eax, 10			;mul displacement by word calculating
	add esi, eax			;add displacement
	inc ecx
	cmp ecx, 10
	je showOrdered
	push esi
	jmp movWordBuffer
compareWord:
	inc ecx
	add esi, 10
	mov ah, [esi]
	mov al, [ebx]

	cmp ecx, 1
	je showOrdered		;need change for get Word
	push esi
	cmp al, ah
	jge movWordBuffer
	pop esi
	popad
	ret

;-------------------------------------------------------
;Procedure to compare two strings alphabetically
;ESI needs to point to first word, EBX to second word
;RETURN EAX: 0 (are equal), 1 EBX comes first, -1 ESI comes first
;-------------------------------------------------------
cmpStr:
	push esi
	push ebx
	push ecx
	xor ecx, ecx
cmpStrLoop:
	mov ah, [esi]
	mov al, [ebx]

	inc esi
	inc ebx
	inc ecx

	or	al, 20h		;change 5bit to 1 | Lower Case ASCII
	or	ah, 20h

	PutCh ah
	PutCh al

	cmp ah, al		;compare the two chars
	jg  ebxFirst
	jl	esiFirst

								;if we chececk all the chars in both strings
	cmp ecx, 10
	je areEqual
	jmp	cmpStrLoop;if we make it here both chars are equal
esiFirst:
	mov eax, -1
	jmp endCmp
ebxFirst:
	mov eax, 1
	jmp endCmp
areEqual:
	mov eax, 0
endCmp:
	pop ecx
	pop ebx
	pop esi
	ret



;-------------------------------------------------------
;Procedure to move a word to buffer
;Moves 10char word saved being point to by ESI
;-------------------------------------------------------
movWordBuffer:
	pushad
	mov ebx, wordBuffer
	xor cx, cx
movWordBufferLoop:
	mov ah,[esi]
	mov [ebx], ah
	inc ebx
	inc esi
	inc cx
	cmp cx, 10
	jne movWordBufferLoop
finishWordBufferMov:
	nwln
	PutStr wordBuffer
	nwln
	popad
	ret

;-------------------------------------------------------
;Procedure to show what is in the array
;-------------------------------------------------------
showNonOrdered:
	nwln
	PutStr nonOrderedMsg
	nwln
	jmp showWordsInit

showOrdered:
	PutStr	orderedMsg
	nwln
	PutStr	wordBuffer
	nwln

showWordsInit:
	pushad							;save all the registers
	mov cx, 11					;10 words to display
	mov esi, wordArray	;point esi to beginning of esi
	sub esi, 10
showWords:
	xor edx, edx				;use as index
	add esi, 10
showChars:
	PutCh	[esi+edx]
	inc edx
	cmp edx ,10
	jne showChars
	nwln
	dec cx
	jne showWords
	popad								;restore registers
	ret									;en precedure
