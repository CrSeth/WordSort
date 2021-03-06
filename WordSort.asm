;-------------------------------------------------------
;This program adds 10 words of maximum 10 chars
;to a two dimensional array. The array of words is
;shown on screen then the words are sorted alphabetically
;using select sort and displayed again in their ordered form.
;
;---
;Instituto Tecnologico de Costa Rica - 2015 
;Course: Computer Achitecture
;-------------------------------------------------------

%include "io.mac"

.DATA
nonOrderedMsg	db	"Ten unordered Words are: ",0
orderedMsg	db	"The ten words ordered alphabetically: ",0
						;10 words of 10bytes MAX each starts here
word1		db  	"zoo", 0		;word 1
word2		db 	"animal", 0		;word N
word3		db 	"car", 0		;if exactly 10 chars no need for 0
word4		db 	"zoo", 0		;word N
word5		db 	"ball", 0		;word N
word6		db 	"HOLA", 0		;word N
word7		db 	"gato", 0		;word N
word8		db 	"Costa Rica"		;word N
word9		db 	"Arduino", 0		;word N
word10		db 	"Dota", 0		;word 10
.UDATA						;Undefined data segment
wordBuffer	resb 10				;used to swap word order arround
wordArray	resb 100			;load words into here, fill with 0

.CODE						;Code segment
	.STARTUP				;Tell compiler start here
	call loadWords				;load the words into the array
	call showNonOrdered			;show the words unordered in the array

	mov esi, wordArray			;point esi to beginning of array
	call sortArrayInit			;sort the array alphabetically using selection sort
	call showOrdered			;show the ordered array

	jmp END					;end program

END:
	.EXIT					;el OS program is done running


;-------------------------------------------------------
;Procedure Save the 10 words into arrayBlock.
;-------------------------------------------------------
loadWords:					;load words intro array
	pushad					;save registers
	mov esi, wordArray			;point esi to first byte in array
	mov ebx, word1				;poit ebx to the first byte in word to copy over
	mov cx, 11				;10 words to loop over and we dec at start so 11
	sub esi, 10				;mov esi back 10 because we are going to add 10 next
loadWordsLoop:
	add esi, 10				;move esi one word forward every time we loop
	xor edx, edx				;clean the edx
	dec cx					;reduce the counter we stop at 0
	je doneLoad				;finished copying when cx 0
movCharsLoop:					;mov all cahrs in word
	mov ah, [ebx]				;align get our char
	mov [esi+edx],ah			;move the char byte over into array from ah
	inc ebx					;move to next char
	inc edx					;increment the index in the sub array(word)

	cmp edx, 10				;when index is 10 we finished copying all the bytes in the word
	je loadWordsLoop			;copy over the next word 

	cmp ah, 0				;if end of word go to next word
	je loadWordsLoop			;if we counted through 10 chars then also go to next word
	jmp movCharsLoop			;when 0 stop looping
doneLoad:
	popad					;restore registers
	ret					;return to where procedure was called from

;-------------------------------------------------------
;Procedure to sort words in the array / Uses Selection Sort
;ESI needs to point to first word in array
;-------------------------------------------------------
sortArrayInit:					;sort the words in the array alphabetically
	pushad
	sub esi, 10				;we add 10 in first run get word so we need to align
	xor ecx, ecx				;ch we use as upper 10 loop cl lower 10 loop
getWord:					;Get each word to be compared / OUTER LOOP
	add esi, 10				;move the outer loop one word foward
	mov ebx, esi				;point ebx to same word

	call compareWord			;compare word in esi with all words after and swap if order is wrong

	inc ecx					;inc the counter
	cmp ecx, 9				;times to loop outer one less than array len
	jl getWord				;loop will counter less than ecx
doneSorting:
	popad					;restore registers
	ret					;return to where procedure was called from 


compareWord:					;INNER compare loop
	push ecx				;save counter
	inc ecx					;use same
compareWordInit:
	add ebx, 10				;move through words in inner loop

	call cmpStr				;compare esi str with ebx
	cmp eax, 1				;eax 1 if ebx word comes before
	je comparingSwapStr			;we need to swap the two strings
	compareContinue:			;tag so we can jump back here after a swap
	inc ecx					;inc the counter
	cmp ecx, 10				;end of inner loop
	jl compareWordInit			;whil counter is less than 10
doneComparing:
	pop ecx					;restore outer loop counter
	ret					;return to procedure caller


comparingSwapStr:
	call swapStr				;swap esi str with ebx in array
	jmp compareContinue			;jump back to word comparing inner loop

;-------------------------------------------------------
;Procedure to compare two strings alphabetically
;ESI needs to point to first word, EBX to second word
;RETURN EAX: 0 (are equal), 1 EBX comes first, -1 ESI comes first
;-------------------------------------------------------
cmpStr:													
	push esi				;save outer loop word pointer
	push ebx				;save inner loop word pointer
	push ecx				;save counter
	xor ecx, ecx				;zero out counter
cmpStrLoop:
	mov ah, [esi]				;move first char in esi
	mov al, [ebx]				;move first char in ebx

	inc esi					;inc the pointer to next char
	inc ebx					;inc the ebx pointer to next char in word
	inc ecx					;inc the loop counter

	or	al, 20h				;change 5bit to 1 | Lower Case ASCII
	or	ah, 20h				;do same to other char

	cmp ah, al				;compare the two chars
	jg  ebxFirst				;if ah is greater than we need to swap
	jl  esiFirst				;if al is greater than we are fine
						;word ESI points to needs to be smaller it is first in array

						;if we checked all the chars in both strings
	cmp ecx, 10				;reach end of both words?
	je areEqual				;then both are equal

	jmp	cmpStrLoop			;if we make it here both chars are equal
esiFirst:					
	mov eax, -1				;mov -1 to eax to let caller know esi is smaller
	jmp endCmp				;we are done
ebxFirst:
	mov eax, 1				;mov 1 to eax to let caller know esi is greate, need swap
	jmp endCmp				;we are done
areEqual:
	mov eax, 0				;mov 0 to eax because both words are equal
endCmp:
	pop ecx					;give these back
	pop ebx
	pop esi
	ret					;end procedure

;-------------------------------------------------------
;Procedure to swap two strings position in array
;Swaps what ebx points to with esi str
;-------------------------------------------------------
swapStr:
	pushad					;store registers

	push esi				;save pointer to first word
	push ebx				;save pointer to second word

	mov esi, ebx				;esi point secon str
	mov ebx, wordBuffer			;ebx to point to wordbuffer
	call movWordBuffer			;move second str to wordBuffer

	pop ebx					;get pointers back
	pop esi

						;move esi to str to second str location
	call movWordBuffer			;moves 10 char esi str to ebx location

						;move what is in buffer to esi
	push esi
	push ebx

	mov ebx, esi				;now we move to beginning of array, "smaller" word
	mov esi, wordBuffer			;point esi to buffer space
	call movWordBuffer			;mov whats in the buffer to ebx

	pop ebx					;restore these
	pop esi

	popad					;restore all registers and end procedure
	ret					;return to caller

;-------------------------------------------------------
;Procedure to move a word to buffer
;Moves 10char word saved being point to by ESI to ebx
;-------------------------------------------------------
movWordBuffer:					;move a 10 char word pointed to by esi to ebx
	pushad					
	xor cx, cx				;save registers and clear counter
movWordBufferLoop:
	mov ah,[esi]				;copy over each char
	mov [ebx], ah				
	inc ebx					;inc pointer to next char
	inc esi					;inc pointer to next char
	inc cx					;inc loop counter
	cmp cx, 10				;loop 10 times because 10 chars in each word
	jne movWordBufferLoop			;while not 10 keep looping
finishWordBufferMov:				;end procedure and restore registers
	popad					
	ret					;retun to caller

;-------------------------------------------------------
;Procedure to show what is in the array
;-------------------------------------------------------
showNonOrdered:					;show undored msg then jump to procedure to show array
	nwln					;a new line on print
	PutStr nonOrderedMsg			;print Ordered Msg
	nwln					;print a new line
	jmp showWordsInit			;now print what is in the array

showOrdered:					;show ordered msg then proceed to showWords
	nwln					;print a new line
	PutStr	orderedMsg			;print the Ordered msg to user
	nwln					;print a new line

showWordsInit:					;shows all the words in the array
	pushad					;save all the registers
	mov cx, 11				;10 words to display
	mov esi, wordArray			;point esi to beginning of esi
	sub esi, 10				;move esi back one word because we add 10 next
showWords:
	xor edx, edx				;use as index
	add esi, 10				;move esi foward one word every time we loop
showChars:
	PutCh	[esi+edx]			;show char in word (esi) + index (edx) char
	inc edx					;inc the index /char pointer
	cmp edx ,10				;did we reach en of word?
	jne showChars				;if not keep printing
	nwln					;print a new line
	dec cx					;dec our loop counter
	jne showWords				;if not done print another word
	popad					;restore registers
	ret					;end precedure
