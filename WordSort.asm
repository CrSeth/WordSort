%include "io.mac"

.DATA
		;10 words of 10bytes MAX each starts here
word1		db  	"hola", 0	;word 1
word2		db 	"Mundo", 0
word3		db 	"palindrome"	;if exactly 10 chars no need for 0
word4		db 	"Grecia", 0
word5		db 	"Nasm", 0
word6		db 	"HOLA", 0
word7		db 	"gato", 0
word8		db 	"Costa Rica", 0
word9		db 	"Arduino", 0
word10		db 	"Dota", 0	;word 10

wordArray	db 100			;load words into here
bufferWord	db 10			;used to swap word order around when doing sort

.CODE
	.STARTUP
loadWords:			;load words intro array
	xor ecx, ecx
	mov esi, wordArray
	mov ebx, word1
	
loadWordsLoop:
	mov cl, 10		;max 10 chars to copy over
movCharsLoop:			;mov all cahrs in word
	mov ah, [ebx]		;align get our char
	push ecx
	push ebx
	xor ebx, ebx
	mov bl, cl
	mov cl, ch
	xor ch, ch
	mov [esi+ ebx],ah
	pop ebx
	pop ecx	
	inc ch			;count up to 10
	cmp ch, 10		
	jne loadWordsLoop	;when 10 stop looping
	

END:
	.EXIT
