IDEAL
P386
MODEL FLAT, C
ASSUME cs:_TEXT,ds:FLAT,es:FLAT,fs:FLAT,gs:FLAT

;±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±?
; CODE
;±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±?
CODESEG


; argumenten popen op het einde 
; alles naar 32bit 
; evenveel pushen als poppen 
;behalve in het geval van een Function call sub esp 8 (gelijk aan 2 keer pop)


; Call gaat een unconditional jump doen naar een subprogramma en gaat het adres van de volgende instructie op de stack pushen
; RET gaat de adres poppen en naar dat adres jumen 
; Na return zijt je aan de volgende instructie na de call, je gaat daar verder doorgaan 
;dit is een test
;---------------Macro's--------------- 

; Grid macro's 
gridWidth	equ 10
gridHeight	equ 10
gridSize 	equ gridWidth * gridHeight ; the number of elements in the grid = the length of the gridArray
blockWidth 	equ 10
blockHeight equ 10

;video Macro's
bufferAdress	equ 0a0000h
windowWidth		equ 320  ; the window width in pixels
windowHeight	equ 200 ; the window height in pixels 
vidBuffSize		equ windowHeight * windowWidth ; the length of the videobuffer

;Color Macro's 
;colour pallet starts from 0 to 15
black		equ 0
darkBlue 	equ 1
green 		equ 2
lightBlue 	equ 3
red 		equ 4
purple 		equ 5
orange 		equ 6
lightGray 	equ 7
darkGray	equ 8
bluePurple 	equ 9
grenBright	equ 10
blueBright 	equ 11
ligtRed		equ 12
lila 		equ 13
yellow 		equ 14 
white 		equ 15

;---------------------------------------

		; Author: 
		; Function: PrintDigit
		; Parameters: 
			; number
				; Type: intiger
				; Use: The intiger that has to be printed.
				; Constraint: It has to be an intiger. 
		; Returns: N/a 
		; Use: Print the value of the intiger on the screen. 

		PROC PrintDigit
		push ebp
		mov ebp, esp 

		push eax 
		push ebx 
		push ecx
		push edx 

		mov eax, [ebp+8]
	

		mov ecx, 0
    	mov ebx, 10
		@@loop:
    	mov edx, 0
    	div ebx                          ;divide by ten
	    ; now ax <-- ax/10
	    ;     dx <-- ax % 10

	    ; print dx
	    ; this is one digit, which we have to convert to ASCII
	    ; the print routine uses dx and ax, so let's push ax
	    ; onto the stack. we clear dx at the beginning of the
		; loop anyway, so we don't care if we much around with it

    	push eax
    	add dl, '0'                     ;convert dl to ascii otherwise it wont print the value

    	pop eax                          ;restore ax
    	push edx                         ;digits are in reversed order, must use stack
    	inc ecx                          ;remember how many digits we pushed to stack
    	cmp eax, 0                       ;if ax is zero, we can quit
		jnz @@loop

   		 ;cx is already set
		mov ah, 02h                       ;2 is the function number of output char in the DOS Services.
		@@popStack:
    	pop edx                          ;restore digits from last to first
    	int 21h                         ;calls DOS Services
    	loop @@popStack

    	pop edx
    	pop ecx 
    	pop ebx 
		pop eax 

		mov esp, ebp 
		pop ebp

		ret
		ENDP PrintDigit

; Author: Asma Oualmakran
; Function: Index
; Parameters: 
	; x: 
		; Type: intiger
		; Use: x-coordinate of the cell. 
		; Constraint: larger or equal to 0 and smaller than gridWidth.
	; y:
		; Type: intiger 
		; Use: y-coordinate of the cell. 
		; Constraint: larger or equal to 0 and smaller than gridHeight.
	; Array Length: 
		; Type: Macro 
		; Use: The length of the used array. 
		; Constraint: N/a 
; Returns: An index in an array.
; Use: Converts the coordinate of an pixel or an cell into an index of the used array (formula: index = (x-1)*array-length+y).

		PROC Index

		push ebp 
		mov ebp, esp 
		; eax containts the x-coordinate
		; ebx containts the y-coordinate
		; ecx containts the width of the array, window ect 
		; We use eax to pass the return value of this function
	 
		push ebx 
		push ecx  

		mov eax, [ebp+8]
		mov ebx, [ebp+12]
		mov ecx, [ebp+16]

		; write if test here to check if the value is out of bounds 

		; apply the formula (x-1)*array_size+y
		dec eax
		mul ecx
		add eax, ebx  


		pop ecx
		pop ebx  

		mov esp, ebp 
		pop ebp

		ret
		ENDP Index

; Author: Asma Oualmakran 
; Function: InBounds 
; Parameters: 
	; Index: 
		; Type: intiger 
		; Use: The index of an element in an array. 
		; Constraint: N/a 
	; Array_size: 
		; Type: intiger 
		; Use: The size of the used array.
		; Constraint: N/a 
; Returns: 0 or 1, 0 if the element is out of bounds of the array. 1 if the element is in bounds of the array. 
; Use: Print an message if the element is to large or the small. Used as a boolean. 

		PROC InBounds

		push ebp
		mov ebp, esp

		push ebx

		mov eax, [ebp+8]
		mov ebx, [ebp+12]

		cmp eax, ebx    ; Make sure that the Index is in bounds of the array. 
		jge @@toLarge

		cmp eax, 0
		jl @@toSmall

		jmp @@inBounds 	; If you reach here, your index is in bounds of the array 

		@@toLarge:
		mov ah, 09h                     ; AH=09h - Print DOS Message
        mov edx, offset _msgL            ; DS:EDX -> $ Terminated String
        int 21h                         ; DOS INT 21h

        mov eax, 0

		jmp @@stop						; make sure we don't print the other message, jump to the end of the code 

		@@toSmall:						; The element is to large if you jump to this label
		mov ah, 09h                     
        mov edx, offset _msgS           
        int 21h  

        mov eax, 0
        jmp @@stop

        @@inBounds:						; if you jump to here, the element is in bounds 

        mov eax, 1

        @@stop:

		pop ebx 
		mov esp, ebp
		pop ebp
		ret
		ENDP InBounds

; Author: Asma Oualmakran
; Function: SetArraySize
; Parameters: 
	; ArrayAdres
		; Type: Adres 
		; Use: The adres of the used array 
		; containts: N/a 
; Returns: The size of the used array 
; Use: Select the right array size 

; This function enables automatic size selection 
; we could adjust the function and make it calculate the 
; length of the array by ending the array with an end symbol 
; by looping over the array until you reach that symbol and count every entry 
; end result is the length of the array (end -> at array-length +1)
; we can't use this method for the buffer arrays, this is why we 
; chose for this solution

		PROC SetArraySize

		push ebp
		mov ebp, esp

		mov eax, [ebp+8]

		cmp eax, bufferAdress
		je @@bufferAdress

		cmp al, [gridArray]
		je @@gridArray

		cmp al, [gridArray2]
		je @@gridArray2

		@@bufferAdress: 
		mov eax, vidBuffSize
		jmp @@stop

		@@gridArray:
		mov eax, gridSize
		jmp @@stop 

		@@gridArray2:
		mov eax, gridSize

		@@stop: 

		mov esp, ebp
		pop ebp

		ret 
		ENDP SetArraySize 

; Author: Asma Oualmakran
; Function: GetValue 
; Parameters: 

	; Index: 
		; Type: intiger
		; Use: The index of an element in the array 
		; Constraint: Larger or equal to 0 and smaller than the length of the array. 
	; Array adres: 
		; Type: adres
		; Use: The adres of the array 
		; Constraint: Must be an adres of a byte array. 
	
; Returns: The value on a location in a array.
; Use: Get the value of an element from an array.

		PROC GetValue 
 
		push ebp 
		mov ebp, esp 
				 ; eax containts the index of the element 
	;	push ecx ; contains the array-length
		push edx 
		push esi ; contains the memory adres

		mov edx, [ebp+8]	; index 
		mov esi, [ebp+12]	; memory adres 
		
		; you need to mov the index of eax to ebx
		; the value will be lost otherwise (or to another register)


		push esi 
		call SetArraySize		; set the size of the array to check the bounds 
		sub esp, 4


		push eax		; contains the array size 
		push edx 		; contains the index 
		call InBounds
		sub esp, 8

		; the index may be overwritten, it's no longer needed 

		cmp eax, 0		; check if the index is in bounds of the array 
		je @@stop		; if the returnvalue of the boolean is false, jump to the end 
		
	
		add esi, edx 
		lodsb

		; debug 
		push eax 
		call PrintDigit
		sub esp, 4
		;--------

		@@stop:

		pop esi 
		pop edx 

				; eax is used to return the value of the element. 

		mov esp, ebp 
		pop ebp

		ret
		ENDP GetValue



; Author: Asma Oualmakran
; Function: SetValue 
; Parameters: 
	; Index: 
		; Type: intiger
		; Use: The index of an element in the array 
		; Constraint: Larger or equal to 0 and smaller than the length of the array 
	; Array adres: 
		; Type: adres
		; Use: The adres of the array 
		; Constraint: Must be an adres of a byte array. 
	; value: 
		; Type: Intiger
		; User: The value to be set in the array.
		; Constraint: N/a 
; Returns: N/a
; Use: Set an value in the array.

		PROC SetValue 
 
		push ebp 
		mov ebp, esp 
		push eax ; containts the value to be set.
		push ecx ; containts the size -> to be set by SetArraySize.
		push edx ; containts the index. 
		push edi ; containts the adres of the array 

		mov eax, [ebp+8]
		mov edx, [ebp+12]
		mov edi, [ebp+16]

		push edi 
		push eax ; store eax to not overwrite is by the called functions
				 ; you store it afther edi, so it's on top of the stack and not used by the fuction SetArraySize
		call SetArraySize
		sub esp, 4 		; eax now containts the array size 

		mov ecx, eax 	; mov the array size from eax into ecx 
		pop eax 		; restore the value of eax to use it for the boolean InBounds

		push ecx 
		push edx 
		call InBounds 	; check if the index is in bounds of the array 
		sub esp, 8 

		cmp eax, 0		; if it is out of bounds, you stop. 
		je @@stop

		add edi, edx 	; the value must be stored at array adres + index 
		stosb 			; save the value from AL into the array 

		@@stop:
																		
		pop esi 
		pop edx
		pop ecx 
		pop ebx 
		pop eax 

		mov esp, ebp 
		pop ebp

		ret
		ENDP SetValue

; Author: Asma Oualmakran
; Function: InitVideo 
; Parameters: 
; Returns: N/a 
; Use: Initialize the video mode 

		PROC InitVideo
		push ebp
		mov ebp, esp 

		push ax 
		
		mov ax , 13h ; specify AH=0 (set video mode) , AL=13h (320x200 )
		int 10h 	 ; call VGA BIOS

		pop ax 

		mov esp, ebp 
		pop ebp

		ret 
		ENDP InitVideo


; Author: Asma Oualmakran
; Function: ExitVideo
; Parameters: N/a
; Returns: N/a 
; Use: Return to text mode 

		PROC ExitVideo 
		push ebp 
		mov ebp, esp 

		push ax 

		mov ax , 03h ; specify AH=0 (set text mode) , AL=3h (text)
		int 10h 	 ; call VGA BIOS

		pop ax 

		mov esp, ebp 
		pop ebp 

		ret
		ENDP ExitVideo


; Author: Asma Oualmakran
; Function: InitWindow
; Parameters: N/a 
; Returns: N/a 
; Use: Initialize the window, make the background one colour 

		PROC InitWindow 
		push ebp 
		mov ebp, esp 
		push eax 
		push ecx
		push edi 

		call InitVideo	; open the video mode 
		

		mov al, white		; place the color in al 
		mov ecx, vidBuffSize
		mov edi, bufferAdress ; the index where stosb needs to start 
		rep stosb	; loops over the video buffer to set every pixel to a value 

		pop edi 
		pop ecx 
		pop eax 

		mov esp, ebp 
		pop ebp 

		ret 
		ENDP InitWindow


; Author: Asma Oualmakran
; Function: DrawSquare 
; Parameters: 
	; Index: 
		; Type: Intiger
		; Use: The index in the video buffer where we need to start wriring
		; Constraint: N/a
	; Array: 
		; Type: Adres 
		; Use: The array that needs to be adjusted. 
		; Constraint: N/a
	; Color:
		; Type: Intiger
		; Use: The color of the pixel. 
		; Constraint: larger or equal to 0 and smaller or equal to 15.
; Use: Set the elements of the video buffer, and form a square 
; Returns: N/a 

		PROC DrawSquare

		push ebp 
		mov ebp, esp 

		push eax 
		push ebx 
		push esi

		pop esi 
		pop ebx 
		pop eax 
		
		mov esp, ebp 
		pop ebp

		ret 
		ENDP DrawSquare




	main:

        sti                             ; Set The Interrupt Flag
        cld                             ; Clear The Direction Flag

        push ds 						; Put value of DS register on the stack
        pop es 							; And write this value to ES

       ; call InitWindow
     



    	;Pause 
        mov ah,00h 						; these two lines make the code stop here 
        int 16h							; you stay in video and can go to exit by pressing a key

 

	;	call ExitVideo					; you alwas need to call exit video afther you call init 

        mov eax, 4c00h                  ; AH = 4Ch - Exit To DOS
        int 21h                         ; DOS INT 21h


;±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±?
; DATA
;±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±?
DATASEG

	; Your data comes here
	gridArray db gridSize dup (0)	; dd -> 32-bit
									; db -> 8-bit, byte array
	gridArray2 db gridSize dup (0)	; second array to be able to compare the old data
	generation dd 0 				; het tellen van generaties dd -> een intiger of floating point getal 
	colorArray dd 000 				; hier moeten er nog de kleuren in komen  

	; errors and information strings
	_msg1 db 'equal 1', 10, 13, '$'
	_msg0 db 'equal 0', 10, 13, '$'
	_msgS db 'Index is to small', 10, 13, '$'
	_msgL db 'Index is to large', 10, 13, '$'

;±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±?
; STACK
;±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±?
STACK 1000h

END main