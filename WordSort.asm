%include "io.mac"

.DATA
nonOrderedMsg	db	"Ten unordered Words are: ",0
orderedMsg	db	"The ten words ordered alphabetically: ",0
		;10 words of 10bytes MAX each starts here
word1		db  	"z", 0		;word 1
word2		db 	"a", 0
word3		db 	"c", 0	;if exactly 10 chars no need for 0
word4		db 	"e", 0
word5		db 	"b", 0
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

	call showOrdered

	PutStr wordArray

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
;Procedure to sort words in the array / Uses Selection Sort
;ESI needs to point to first word in array
;-------------------------------------------------------
sortArrayInit:				;sort the words in the array alphabetically
	pushad
	sub esi, 10					;we add 10 in first run get word so we need to align
	xor ecx, ecx				;ch we use as upper 10 loop cl lower 10 loop
getWord:							;Get each word to be compared / OUTER LOOP
	add esi, 10					;move the outer loop one word foward
	mov ebx, esi

	call compareWord

	inc ecx
	cmp ecx, 9					;times to loop outer one less than array len
	jl getWord
doneSorting:
	popad
	ret


compareWord:					;INNER compare loop
	push ecx
	inc ecx							;use same
compareWordInit:
	add ebx, 10					;move through words in inner loop

	call cmpStr					;compare esi str with ebx
	cmp eax, 1					;eax 1 if ebx word comes before
	je comparingSwapStr
	compareContinue:
	inc ecx
	cmp ecx, 10					;end of inner loop
	jl compareWordInit
doneComparing:
	pop ecx
	ret


comparingSwapStr:
	call swapStr				;swap esi str with ebx in array
	jmp compareContinue

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
;Procedure to swap two strings position in array
;Swaps what ebx points to with esi str
;-------------------------------------------------------
swapStr:
	pushad							;store registers

	push esi
	push ebx

	mov esi, ebx				;esi point secon str
	mov ebx, wordBuffer	;ebx to point to wordbuffer
	call movWordBuffer	;move second str to wordBuffer

	pop ebx							;get pointers back
	pop esi

											;move esi to str to second str location
	call movWordBuffer	;moves 10 char esi str to ebx location

											;move what is in buffer to esi
	push esi
	push ebx

	mov ebx, esi
	mov esi, wordBuffer
	call movWordBuffer

	pop ebx
	pop esi

	popad
	ret

;-------------------------------------------------------
;Procedure to move a word to buffer
;Moves 10char word saved being point to by ESI to ebx
;-------------------------------------------------------
movWordBuffer:
	pushad
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
	nwln
	PutStr	orderedMsg
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
